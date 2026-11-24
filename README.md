# 🚀 DevOps Management Mobile App
> **Pocket DevOps Companion & Work Log Hub for Engineering Teams**  
> Aplikasi mobile berbasis Flutter untuk pemantauan alur kerja, catatan tugas harian (*work log*), dan estafet rilis cepat antara peran **Lead**, **Developer**, dan **QA Engineer**.

---

## 📌 Latar Belakang & Pemecahan Masalah

Di lingkungan tim pengembang perangkat lunak (*software engineering*), koordinasi rilis dan pencatatan kerja sering mengalami hambatan:
1. **Mis-komunikasi Antar Role**: Developer sudah selesai koding tetapi QA belum tahu versi mana yang siap diuji, atau Lead kesulitan memantau apakah rilis sudah aman untuk dipublikasikan.
2. **Ketergantungan pada Laptop**: Platform seperti GitHub atau Jira berbasis web di desktop. Saat Lead atau QA sedang *mobile* (di jalan, rapat, atau luar kantor), mereka tidak dapat meninjau atau menyetujui rilis mendesak secara cepat.
3. **Catatan Kerja Tercecer**: Developer membutuhkan catatan harian yang tetap bisa diakses dan disimpan meskipun perangkat sedang *offline* (tanpa koneksi internet).

**Solusi Aplikasi Ini:**  
Menjadi **"Pocket Companion"** yang menyatukan alur kerja 3 pilar IT dalam genggaman ponsel, mendukung mode *offline-first* dengan SQLite, serta integrasi notifikasi dan pengingat berjadwal.

---

## 👥 Hak Akses Berbasis Peran (Role-Based Access Control)

Aplikasi memiliki sistem hak akses terkunci (*strictly locked RBAC*), di mana setiap peran hanya dapat melihat dan melakukan aksi sesuai wewenangnya:

| Peran | Warna Aksen | Tanggung Jawab & Fitur Utama |
| :--- | :---: | :--- |
| **Lead (Ketua Tim)** | Ungu (`#8B5CF6`) | • Memantau ringkasan metrik dan progres pengerjaan seluruh tim.<br>• Menerima/menolak permintaan persetujuan rilis (*Deploy Approval*).<br>• Menandai tugas selesai secara final. |
| **Developer (Programmer)** | Sian (`#06B6D4`) | • Melacak kompilasi dan riwayat *push* kode terakhir pada Git branch.<br>• Mengelola catatan kerja harian (*Work Notes*) di SQLite lokal.<br>• Mengajukan fitur yang sudah selesai ke QA dengan tombol **"Ajukan ke QA"**. |
| **QA Engineer (Penguji)** | Hijau (`#10B981`) | • Menerima daftar fitur yang siap diuji dari Developer.<br>• Menjalankan *checklist* verifikasi pengujian rilis.<br>• Memberikan tanda lolos uji dengan tombol **"Lolos Uji QA ✓"** atau mengembalikan tiket jika ada bug. |

---

## 📋 Matriks Pemenuhan 7 Fitur Wajib Tugas

Aplikasi ini dirancang untuk memenuhi secara lengkap 7 kriteria penilaian teknis pengembangan aplikasi mobile:

| No | Kriteria Tugas | Implementasi di Aplikasi | Status |
| :-: | :--- | :--- | :-: |
| **1** | **Authentication** | Login akun dan pemilihan hak akses terkunci (Lead / Dev / QA) dengan proteksi sesi. | ✅ **Selesai** |
| **2** | **Local Database SQLite** | Database lokal `sqflite` untuk menyimpan Catatan Kerja tim (CRUD lengkap) secara *offline-first*. | ✅ **Selesai** |
| **3** | **Alarm and Scheduler** | Pengingat jam kerja harian (*Daily Standup / Log Reminder*) dengan alarm berjadwal di memori OS. | ✅ **Selesai** |
| **4** | **Notification** | Notifikasi pop-up di status bar HP saat tugas diajukan ke QA, rilis disetujui, atau alarm berbunyi. | ✅ **Selesai** |
| **5** | **Preference and Setting** | Pengaturan tema (Dark/Light mode) dan preferensi alarm menggunakan `SharedPreferences`. | ✅ **Selesai** |
| **6** | **Background Task** | Eksekusi tugas berkala di latar belakang menggunakan `WorkManager` untuk memantau tugas tertunda. | ⏳ *Tahap 5 (Akan Datang)* |
| **7** | **Online App** | Sinkronisasi dua arah data catatan kerja ke server REST API / Cloud Database saat online. | ⏳ *Tahap 5 (Akan Datang)* |

---

## 🛠️ Tech Stack & Dependensi

* **Framework**: [Flutter](https://flutter.dev) (SDK `>=3.0.0 <4.0.0` / Dart 3)
* **Local Database**: `sqflite` & `sqflite_common_ffi` (Kompatibel untuk Android, iOS, dan Windows Desktop)
* **Notifications & Scheduler**: `flutter_local_notifications` & `timezone`
* **Local Storage / Preferences**: `shared_preferences`
* **Networking**: `http`
* **Typography**: `google_fonts` (Inter & JetBrains Mono)
* **Path Management**: `path`

---

## 📂 Struktur Proyek

```text
lib/
├── core/
│   ├── database/
│   │   └── db_helper.dart             # SQLite singleton, skema tabel, dan operasi CRUD
│   └── theme/
│       └── app_theme.dart             # Tema warna DevOps gelap (Mint, Charcoal, Role Colors)
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_session.dart      # State sesi login & hak akses peran
│   │   └── presentation/
│   │       ├── welcome_screen.dart    # Layar sambutan & tombol akses passwordless
│   │       ├── github_auth_screen.dart# Otorisasi akun & token GitHub
│   │       ├── workspace_selection_screen.dart # Pemilihan workspace & repositori
│   │       └── role_selection_screen.dart      # Pemilihan peran (Lead / Dev / QA)
│   ├── home/
│   │   └── presentation/
│   │       └── role_dashboard_preview.dart     # Dashboard utama terkunci per peran & navigasi
│   └── work_notes/
│       ├── models/
│       │   └── work_note.dart         # Model entitas catatan tugas
│       └── presentation/
│           └── work_notes_screen.dart # Halaman CRUD catatan kerja SQLite & filter
└── main.dart                          # Titik masuk aplikasi
```

---

## 🚀 Panduan Menjalankan Proyek

### 1. Kloning Repository
```bash
git clone https://github.com/irfanzakaria-dev/Devops-manajemen-app.git
cd Devops-manajemen-app
```

### 2. Unduh Dependensi
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
* **Di HP Android / Emulator**:
  ```bash
  flutter run
  ```
* **Di Windows Desktop**:
  ```bash
  flutter run -d windows
  ```

---

## 📅 Roadmap Pengembangan

- [x] **Tahap 1**: UI/UX Autentikasi, Otomasi Workspace & Pemisahan 3 Peran (RBAC).
- [x] **Tahap 2**: Integrasi Database SQLite Lokal (`sqflite`), Skema Catatan Kerja, dan CRUD Interaktif.
- [x] **Tahap 3**: Fitur Pengingat Harian & Alarm Berjadwal + Notifikasi Lokal di Status Bar Android.
- [x] **Tahap 4**: Halaman Pengaturan, Tema Gelap/Terang, dan Persistensi Preferensi Pengguna.
- [ ] **Tahap 5**: Integrasi Background Task (`WorkManager`) & Sinkronisasi Online REST API.

---

**Dibuat oleh**: Irfan Zakaria (`@irfanzakaria-dev`)  
Lisensi: MIT
