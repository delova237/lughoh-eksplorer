# Al-Lughah Explorer

LMS gamifikasi pembelajaran bahasa Arab. Dibangun dengan React, TypeScript, Vite, CSS responsif, Supabase, dan Vercel.

## Fitur yang tersedia

- Landing page dan autentikasi murid/guru.
- Dashboard murid dengan XP, streak, dan progres enam tema.
- Enam materi Nahwu-Shorof.
- 20 butir evaluasi per tema (15 latihan gramatika/tarjamah dan 5 pemahaman Qira'ah).
- Navigasi sebelumnya/lanjut, penyimpanan jawaban, dan pembahasan.
- Word Scramble 10 level.
- Latihan Istima dengan Text-to-Speech browser.
- Latihan Kalam dengan perekaman mikrofon browser dan pemutaran rekaman.
- Dashboard guru. Dengan Supabase aktif, daftar progres murid diambil dari database dan diperbarui melalui Realtime.
- LocalStorage sebagai cache dan mode demo offline.

## Jalankan di komputer

Persyaratan: Node.js 20.19+ atau 22.12+ dan npm.

```bash
npm install
npm run dev
```

Buka URL lokal yang diberikan Vite.

## Akun demo

Mode demo aktif jika file `.env` belum diisi.

- Murid: `murid@allughah.id`
- Guru: `guru@allughah.id`
- Kata sandi keduanya: `belajar123`

Akun demo hanya untuk pratinjau lokal. Data demo tidak dibagikan antarpengguna/perangkat.

## Mengaktifkan Supabase

1. Buat project di https://supabase.com.
2. Buka SQL Editor dan jalankan seluruh isi `supabase/schema.sql`.
3. Salin `.env.example` menjadi `.env`.
4. Isi `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` dari Project Settings > API.
5. Jalankan ulang `npm run dev`.
6. Buat akun murid dari halaman daftar.
7. Untuk akun guru, buat akun terlebih dahulu, lalu promosikan role-nya melalui SQL Editor:

```sql
update public.profiles set role = 'teacher'
where id = 'UUID_AKUN_GURU';
```

Jangan pernah menaruh `service_role` key di frontend. Gunakan hanya anon/publishable key. Kebijakan RLS membatasi murid ke progres miliknya sendiri dan mengizinkan guru membaca progres murid.

### Catatan sinkronisasi

Saat Supabase aktif, progres murid disinkronkan ke tabel `student_progress`. Dashboard guru berlangganan perubahan tabel tersebut melalui Supabase Realtime. Data progres yang tersimpan di browser juga tetap digunakan sebagai cache. Saat login dari perangkat lain, data cloud akan dimuat.

## Deploy ke GitHub dan Vercel

1. Buat repository GitHub baru.
2. Ekstrak ZIP ini, lalu unggah seluruh isi folder proyek ke repository (file `package.json` harus berada di root repository).
3. Di Vercel pilih **Add New > Project**, lalu impor repository GitHub.
4. Framework preset: Vite. Build command: `npm run build`. Output directory: `dist`.
5. Jika memakai Supabase, tambahkan Environment Variables `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` pada Project Settings Vercel.
6. Klik Deploy.

`vercel.json` sudah disertakan untuk mengarahkan rute aplikasi kembali ke `index.html`.

## Batasan yang perlu diketahui

- Web Speech API bergantung pada dukungan browser dan ketersediaan suara Arab di perangkat. TTS browser bukan penilaian pelafalan.
- Rekaman Kalam saat ini diproses di browser dan tidak diunggah ke server. Penilaian otomatis/pengiriman ke guru memerlukan layanan tambahan dan penyimpanan audio.
- Soal disediakan sebagai bank awal untuk demonstrasi dan perlu ditinjau guru bahasa Arab sebelum digunakan sebagai asesmen resmi.
- XP dan jawaban pada implementasi awal divalidasi di sisi aplikasi. Untuk penggunaan berisiko tinggi atau ujian resmi, pindahkan evaluasi skor ke fungsi backend/database yang tervalidasi agar tidak dapat dimanipulasi melalui browser.
- Pengaturan role guru dilakukan administrator. Jangan membuka pendaftaran role guru untuk publik.
