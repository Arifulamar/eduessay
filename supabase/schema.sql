-- EduEssay Supabase schema
-- Run this entire file in Supabase SQL Editor for the EduEssay project.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'teacher' check (role in ('teacher','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  subject text not null default '',
  duration_minutes integer not null default 60 check (duration_minutes between 1 and 1440),
  max_score integer not null default 100 check (max_score between 1 and 1000),
  is_published boolean not null default false,
  public_token text not null unique default replace(gen_random_uuid()::text, '-', ''),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  prompt text not null,
  rubric text not null,
  extra_criteria text not null default '',
  position integer not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  student_name text not null,
  student_answer text not null,
  submitted_at timestamptz not null default now(),
  status text not null default 'submitted' check (status in ('submitted','ai_reviewed','graded')),
  ai_score numeric,
  ai_feedback text,
  final_score numeric,
  teacher_feedback text,
  graded_by uuid references auth.users(id) on delete set null,
  graded_at timestamptz,
  check (ai_score is null or ai_score >= 0),
  check (final_score is null or final_score >= 0)
);

create table if not exists public.ai_evaluations (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions(id) on delete cascade,
  teacher_id uuid not null references auth.users(id) on delete cascade,
  suggested_score numeric not null check (suggested_score >= 0),
  feedback text not null default '',
  rubric_breakdown jsonb not null default '{}'::jsonb,
  model text not null default 'gpt-4o-mini',
  created_at timestamptz not null default now()
);

create index if not exists exams_owner_id_idx on public.exams(owner_id);
create index if not exists questions_exam_id_idx on public.questions(exam_id);
create index if not exists submissions_exam_id_idx on public.submissions(exam_id);
create index if not exists ai_evaluations_submission_id_idx on public.ai_evaluations(submission_id);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists exams_set_updated_at on public.exams;
create trigger exams_set_updated_at before update on public.exams
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, role)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, ''), '@', 1)), 'teacher')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.exams enable row level security;
alter table public.questions enable row level security;
alter table public.submissions enable row level security;
alter table public.ai_evaluations enable row level security;

drop policy if exists "Teachers can read own profile" on public.profiles;
create policy "Teachers can read own profile" on public.profiles
for select to authenticated using (id = (select auth.uid()));

-- No client-side profile UPDATE policy is created: users must not be able to promote
-- themselves from teacher to admin by editing their own role.
drop policy if exists "Teachers manage own exams" on public.exams;
create policy "Teachers manage own exams" on public.exams
for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

drop policy if exists "Teachers manage questions in own exams" on public.questions;
create policy "Teachers manage questions in own exams" on public.questions
for all to authenticated
using (exists (select 1 from public.exams e where e.id = questions.exam_id and e.owner_id = (select auth.uid())))
with check (exists (select 1 from public.exams e where e.id = questions.exam_id and e.owner_id = (select auth.uid())));

drop policy if exists "Teachers read submissions for own exams" on public.submissions;
create policy "Teachers read submissions for own exams" on public.submissions
for select to authenticated
using (exists (select 1 from public.exams e where e.id = submissions.exam_id and e.owner_id = (select auth.uid())));

drop policy if exists "Teachers grade submissions for own exams" on public.submissions;
create policy "Teachers grade submissions for own exams" on public.submissions
for update to authenticated
using (exists (select 1 from public.exams e where e.id = submissions.exam_id and e.owner_id = (select auth.uid())))
with check (exists (select 1 from public.exams e where e.id = submissions.exam_id and e.owner_id = (select auth.uid())));

drop policy if exists "Teachers read AI evaluations for own exams" on public.ai_evaluations;
create policy "Teachers read AI evaluations for own exams" on public.ai_evaluations
for select to authenticated
using (
  teacher_id = (select auth.uid()) and
  exists (
    select 1 from public.submissions s
    join public.exams e on e.id = s.exam_id
    where s.id = ai_evaluations.submission_id and e.owner_id = (select auth.uid())
  )
);

-- Inserts into submissions are intentionally not granted to browser clients.
-- A secure Edge Function will accept public student submissions and validate the exam token.
