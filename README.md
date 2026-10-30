# Ujian Online (PWA) – GitHub Pages + Firebase

## 1. Siapkan Firebase (gratis)
1. https://console.firebase.google.com → **Add project**.
2. **Build → Firestore Database → Create database** (mode production).
3. **Build → Authentication → Sign-in method**: aktifkan **Anonymous** dan **Google**.
4. **Authentication → Settings → Authorized domains**: tambahkan `USERNAME.github.io`.
5. **Project settings → Your apps → Web (</>)** → salin `firebaseConfig` ke `firebase-config.js`, dan isi `ADMIN_EMAILS` dengan email Google Anda.
6. **Firestore → Rules**: tempel isi `firestore.rules` (ganti email admin), lalu **Publish**.

## 2. Deploy ke GitHub Pages
1. Buat repo baru di GitHub, unggah semua file di folder ini ke root repo.
2. **Settings → Pages → Build and deployment → Deploy from a branch → main / (root)** → Save.
3. Buka `https://USERNAME.github.io/NAMA-REPO/`.

## 3. Pakai
- Admin: klik **Masuk admin** (akun Google yang terdaftar) → buat ujian → centang **Dibuka** → **Salin tautan** dan bagikan.
- Peserta: buka tautan, isi nama dan NIS, kerjakan, lalu Kirim. Tidak perlu akun.
- Android/Chrome: menu ⋮ → **Install app**. iPhone: Share → **Add to Home Screen**.


## 4. Sistem Multi-Guru (rilis Oktober 2026)
- Super Admin ditentukan oleh email pada `ADMIN_EMAILS` di `firebase-config.js` dan harus sama dengan email pada fungsi `isSuperAdmin()` di `firestore.rules`.
- Guru masuk dengan Google. Profil baru dibuat dengan status `pending`.
- Super Admin membuka Panel Guru → **Persetujuan Guru** → Setujui/Tolak.
- Guru yang disetujui dapat mengisi profil, mata pelajaran, dan sekolah, lalu membuat ujian sendiri.
- Setiap ujian memiliki tautan langsung `https://USERNAME.github.io/NAMA-REPO/#f-ID_UJIAN`.
- Dokumen ujian menyimpan `ownerUid`; kunci jawaban dan tanggapan dibatasi untuk pemilik ujian dan Super Admin.

### WAJIB: terapkan aturan Firestore terbaru
1. Buka Firebase Console → Firestore Database → Rules.
2. Buka file `firestore.rules` pada repositori ini.
3. Salin seluruh isinya ke editor Rules di Firebase Console.
4. Klik **Publish**. Perubahan file di GitHub saja tidak otomatis mengubah aturan database.
5. Pastikan Authentication → Sign-in method mengaktifkan **Google** dan **Anonymous**.

Email Super Admin pada `firebase-config.js` dan `firestore.rules` harus sama. Jangan menghapus akun Super Admin tersebut sebelum menyiapkan pengganti.

Catatan migrasi: ujian lama tanpa `ownerUid` tetap dapat dilihat Super Admin. Ujian tersebut perlu dibuka dan disimpan ulang oleh Super Admin agar memiliki metadata kepemilikan. Tanggapan lama dengan format dokumen gabungan tetap tersimpan, tetapi tampilan tanggapan multi-guru yang baru membaca format dokumen per ujian untuk kiriman baru.
