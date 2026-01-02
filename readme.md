# Snappos - Modern Point of Sale System

![Snappos Banner](https://via.placeholder.com/1200x400/673AB7/ffffff?text=Snappos+POS)

**Snappos** adalah aplikasi Point of Sale (Kasir) modern yang dirancang untuk efisiensi bisnis ritel kecil hingga menengah. Aplikasi ini terdiri dari *Backend* berbasis PHP Native yang ringan dan *Frontend* mobile/web berbasis Flutter dengan desain Material 3 yang elegan.

---

## 🛠️ Tech Stack

### Frontend (Mobile/Web App)
Built with **Flutter** for a beautiful, natively compiled application.
- ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) **Flutter SDK**: UI Toolkit utama.
- ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white) **Dart Language**: Bahasa pemrograman untuk Flutter.
- **Material 3**: Design system terbaru dari Google.
- **Provider / State Management**: Manajemen state aplikasi.

### Backend (API)
Built with **PHP Native** for speed and simplicity.
- ![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white) **PHP 8.0+**: Bahasa server-side.
- ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white) **MySQL / MariaDB**: Database relasional.
- ![Apache](https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white) **Apache Server**: Web server (via XAMPP/LAMPP).
- **RESTful API**: Arsitektur komunikasi data JSON.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Keamanan
- **Login & Register**: Sistem akun untuk Admin dan Kasir.
- **Token Based Auth**: Autentikasi aman menggunakan Bearer Token.
- **Auto Logout**: Keamanan sesi otomatis jika token kadaluarsa.

### 📦 Manajemen Produk
- **Katalog Produk**: Tampilan grid modern dengan informasi stok dan harga.
- **Stok Real-time**: Indikator stok dan pencegahan penjualan jika stok habis.
- **Pencarian & Filter**: (Coming soon) Memudahkan pencarian barang.

### 🛒 Transaksi & Kasir
- **Keranjang Belanja**: Tambah/Kurang item dengan mudah.
- **Kalkulasi Otomatis**: Menghitung total dan kembalian secara instan.
- **Checkout Cepat**: Proses pembayaran yang ringkas dan intuitif.
- **Dialog Sukses**: Konfirmasi visual saat transaksi berhasil.

### 📜 Riwayat & Laporan
- **Riwayat Transaksi**: Daftar transaksi lengkap dengan detail waktu dan kasir.
- **Detail Struk**: Tampilan detail transaksi mirip struk belanja digital.

---

## 🚀 Cara Install & Menjalankan

### Persiapan (Prerequisites)
1.  **XAMPP** (atau web server lain dengan PHP & MySQL).
2.  **Flutter SDK** (sudah terinstall dan dikonfigurasi).
3.  **Git** (untuk clone proyek).

### 1️⃣ Setup Backend & Database
1.  Clone repository ini ke dalam folder `htdocs` XAMPP Anda.
    ```bash
    cd /opt/lampp/htdocs
    git clone https://github.com/rizkipr05/Snappos-app.git snappos_api
    ```
2.  Nyalakan **Apache** dan **MySQL** di XAMPP.
3.  Buka **phpMyAdmin** (`http://localhost/phpmyadmin`).
4.  Buat database baru dengan nama **`snappos_db`**.
5.  Import file **`database.sql`** yang ada di root folder proyek ini ke dalam database tersebut.
    - *File ini sudah berisi tabel `users`, `products`, `transactions`, dll serta user admin default.*
6.  (Opsional) Cek konfigurasi database di `config/db.php` jika Anda menggunakan password root yang berbeda.

### 2️⃣ Konfigurasi Frontend
1.  Masuk ke folder Flutter:
    ```bash
    cd snappos_flutter
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  **Penting**: Buka file `lib/core/api.dart` dan sesuaikan `baseUrl` dengan IP Address komputer Anda (jangan gunakan `localhost` jika menjalankan di emulator HP, gunakan IP LAN seperti `192.168.x.x`).
    ```dart
    static const String baseUrl = "http://192.168.1.5/snappos_api/public/index.php";
    ```
    *Jika menjalankan di Chrome/Web, `localhost` mungkin bisa digunakan tergantung konfigurasi CORS.*

### 3️⃣ Jalankan Aplikasi
Jalankan perintah berikut untuk membuka aplikasi di Google Chrome (Web) atau Emulator:

```bash
flutter run -d chrome
```

---

## 👤 Akun Default
Setelah import database, Anda bisa login dengan akun admin berikut:
- **Email**: `admin@snappos.com`
- **Password**: `password123`

---

## 📂 Struktur Folder
```
snappos_api/
├── config/              # Konfigurasi Database & CORS
├── core/                # Helper function (Auth, Response)
├── modules/             # Logika API (Login, Product, Transaction)
├── public/              # Entry point (index.php)
├── snappos_flutter/     # Source Code Frontend Flutter
│   ├── lib/
│   │   ├── core/        # API Client & Storage SharedPrefs
│   │   ├── features/    # Halaman (Auth, Product, Cart, History)
│   │   └── main.dart    # Entry point & Tema Aplikasi
└── database.sql         # File Schema Database
```
