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
