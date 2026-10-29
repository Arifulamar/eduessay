# EduEssay — Supabase setup

This repository is a static GitHub Pages frontend with a Supabase backend scaffold.

## Current status
- `index.html` includes Email/password sign-in and sign-up using `@supabase/supabase-js` from jsDelivr.
- The Project URL and publishable/anon key are entered in the app and saved in that browser's local storage. They are public client configuration, not service secrets.
- `supabase/schema.sql` creates teacher profiles, exams, questions, submissions and AI evaluation tables with row-level security.
- `supabase/functions/grade-essay/index.ts` is a server-side AI grading function. It is not deployed until you deploy it from your Supabase project.
- The current form builder and student answer demo still use browser localStorage. Login alone does not yet sync form data or student submissions to the database.

## 1. Apply the database schema
1. Open the Supabase dashboard and select your EduEssay project.
2. Open **SQL Editor** → **New query**.
3. Open `supabase/schema.sql` in this repository, copy its full contents into the editor and run it.
4. Confirm the query completes successfully.

If you already ran an older schema, run this version too; it is written to be repeatable for the tables and policies it defines.

## 2. Configure authentication
1. Open **Authentication → URL Configuration**.
2. Set Site URL to `https://arifulamar.github.io/eduessay/`.
3. Add Redirect URL `https://arifulamar.github.io/eduessay/**`.
4. Under **Authentication → Sign In / Providers → Email**, keep Email enabled.
5. For initial testing, you may keep email confirmation enabled. If enabled, new teachers must click the confirmation link before signing in.

## 3. Connect the frontend
1. Open `https://arifulamar.github.io/eduessay/`.
2. Enter the Project URL and the publishable key (or legacy anon public key).
3. Click **Simpan konfigurasi di browser ini**.
4. Register a test teacher using an email you control and a strong password.
5. If confirmation is enabled, confirm the email, then sign in.

Never put `service_role` `OPENAI_API_KEY`, database passwords, or other server secrets into `index.html`, browser storage, or GitHub.

## 4. Configure and deploy AI grading
The grading function requires these Supabase Edge Function secrets:
- `OPENAI_API_KEY` — your OpenAI API key
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are normally supplied to deployed Supabase Edge Functions by the platform.

Deploy from a local Supabase CLI setup:
1. Install and log in to Supabase CLI.
2. Link the local project to your Supabase project.
3. Set the secret using the CLI's secret command; do not paste the value into GitHub.
4. Deploy function `grade-essay`.
5. Test only with a test submission. Review logs and confirm the function only returns a suggested score.

The AI function expects the caller to be an authenticated teacher and uses RLS to verify that the teacher owns the exam. It stores an AI recommendation; it does not make that recommendation the final teacher grade.

## 5. Important production gap
The current frontend is not yet wired to `exams`, `questions`, or `submissions`. Public student submission must be implemented through a separate server-side endpoint that validates an exam's public token and limits abuse. Do not weaken RLS by allowing anonymous clients to insert arbitrary submissions. Complete that integration before using real student data.
