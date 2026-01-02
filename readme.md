# Snappos API

**Deskripsi:**
- Snappos API adalah RESTful API sederhana untuk manajemen produk dan transaksi (checkout), dilengkapi fitur autentikasi token. Proyek ditulis sebagai PHP micro-API tanpa framework besar, cocok untuk penggunaan ringan atau pembelajaran.

**Bahasa & Persyaratan:**
- **Bahasa pemrograman:** PHP (disarankan PHP 8.0+ karena penggunaan `str_starts_with` dan fitur modern lainnya)
- **Database:** MySQL / MariaDB (terhubung lewat PDO)
- **Server web:** Apache (biasanya dijalankan lewat XAMPP/LAMPP di lingkungan pengembangan)
- **File token:** penyimpanan token sederhana menggunakan `storage_tokens.json`

**Fitur utama:**
- Register / Login / Me (autentikasi berbasis token)
- CRUD Produk (list, simpan, update, hapus)
- Transaksi (checkout, riwayat, detail transaksi)
- Endpoint health untuk pengecekan layanan

**Struktur proyek (singkat):**
- `public/` : entrypoint `index.php` dan routing sederhana
- `modules/` : handler endpoint (auth, products, transactions)
- `config/` : konfigurasi (CORS, DB)
- `core/` : utilitas bersama (auth, response, utils)
- `storage_tokens.json` : penyimpanan token sederhana

**Autentikasi:**
- Menggunakan token (Bearer) yang di-generate oleh fungsi `make_token()` dan disimpan di `storage_tokens.json`.
- Middleware ringan `require_auth()` dan `require_role()` di `core/auth.php`.

**Database:**
- Koneksi dibuat dengan PDO di `config/db.php`.
- Sesuaikan kredensial DB pada `config/db.php` (host, user, pass, dbname).

**Icon / Tech Stack (ikon):**

Berikut daftar teknologi yang digunakan dan contoh ikon/badge yang bisa dipakai pada README atau dokumentasi:

- PHP 8+:  
  ![PHP](https://img.shields.io/badge/PHP-8.0-blue?logo=php&logoColor=white)
- MySQL:  
  ![MySQL](https://img.shields.io/badge/MySQL-5.7-brightgreen?logo=mysql&logoColor=white)
- Apache / XAMPP:  
  ![Apache](https://img.shields.io/badge/Apache-server-orange?logo=apache&logoColor=white)
- PDO (PHP Data Objects):  
  ![PDO](https://img.shields.io/badge/PDO-PHP-yellow)
- JSON (payloads & penyimpanan token):  
  ![JSON](https://img.shields.io/badge/JSON-data-lightgrey)
- REST API (HTTP endpoints):  
  ![REST](https://img.shields.io/badge/REST-API-blueviolet)

Catatan: ikon di atas menggunakan layanan Shields.io dan parameter `logo` dari Simple Icons. Ganti versi/warna sesuai preferensi.

**Cara jalankan (dev, contoh):**
1. Letakkan folder proyek di `htdocs` (XAMPP/LAMP) atau set virtual host ke folder root proyek.
2. Pastikan MySQL berjalan dan buat database `snappos_db` (atau ubah nama DB di `config/db.php`).
3. Akses endpoint melalui browser atau API client (contoh): `http://localhost/snappos_api/public/index.php/api/health` atau `http://localhost/snappos_api/api/health`.

**Endpoint singkat:**
- `POST /api/auth/register` — registrasi pengguna
- `POST /api/auth/login` — login dan terima token
- `GET /api/auth/me` — info user (butuh Authorization: Bearer <token>)
- `GET /api/products` — list produk
- `POST /api/products` — simpan produk (butuh auth jika dikonfigurasi)
- `PUT /api/products/:id` — update produk
- `DELETE /api/products/:id` — hapus produk
- `POST /api/checkout` — proses checkout
- `GET /api/transactions` — riwayat transaksi
- `GET /api/transactions/:id` — detail transaksi

**Catatan pengembangan / keamanan:**
- Penyimpanan token saat ini menggunakan file JSON — untuk produksi, gunakan penyimpanan yang lebih aman (database atau cache terproteksi).
- Sanitasi masukan dan validasi lebih ketat direkomendasikan untuk endpoint yang menerima input user.

---

Jika mau, saya bisa:
- menambahkan badge/ikon yang berbeda, atau
- menyiapkan contoh `curl`/Postman collection untuk semua endpoint.
