# Product Requirements Document (PRD)
## RootAppNews — Backend API

| Field        | Value                             |
|--------------|-----------------------------------|
| Version      | 1.0.0                             |
| Author       | RootAppNews Team                  |
| Last Updated | 2026-04-01                        |
| Status       | Draft                             |

---

## 1. Latar Belakang & Konteks Produk

RootAppNews adalah aplikasi mobile berita berbasis Flutter yang mengusung konsep *Editorial Premium* — sebuah antarmuka layaknya majalah digital bergaya Apple News / Flipboard. Untuk menghidupkan UI tersebut, backend harus mampu:

1. Menyajikan berita dari berbagai kategori (Teknologi, Keuangan, Olahraga, Dunia, dsb).
2. Mengotentikasi pengguna — fitur ini **sudah selesai** pada iterasi sebelumnya.
3. Mendukung fitur *personalisasi* (fase berikutnya): menyimpan preferensi kategori pengguna dan riwayat artikel yang disimpan (*bookmark*).

Backend dibangun menggunakan **Go** dengan arsitektur Clean Architecture (handler → service → repository), database **PostgreSQL**, dan framework HTTP **Fiber/Echo/Chi** (sesuai yang sudah terpasang di `go.mod`).

---

## 2. Tujuan & Sasaran

### Tujuan Utama (Fase 1 — News Feature)
- Menyediakan endpoint untuk daftar kategori berita.
- Menyediakan endpoint untuk feed berita berdasarkan kategori dengan struktur data yang memungkinkan klien Flutter menampilkan UI "Hero + Grid".
- Menyediakan endpoint untuk detail artikel.

### Definisi Sukses
- Aplikasi Flutter bisa menampilkan homepage berita dengan **0 hardcode list** di sisi klien.
- Seluruh data berita bersumber dari API backend.
- Response time < 300ms untuk endpoint list berita (tanpa CDN) di jaringan lokal.

---

## 3. Cakupan Fitur (Scope)

### ✅ Dalam Scope (Fase 1)
| #  | Fitur                            | Prioritas |
|----|----------------------------------|-----------|
| 1  | CRUD Kategori (Admin Only)       | High      |
| 2  | CRUD Artikel (Admin Only)        | High      |
| 3  | GET Daftar Kategori (Public)     | High      |
| 4  | GET Feed Berita (Public)         | High      |
| 5  | GET Detail Artikel (Public)      | High      |
| 6  | GET Profil Pengguna (Auth)       | Medium    |
| 7  | PUT Update Profil (Auth)         | Medium    |

### ❌ Di Luar Scope (Fase 2 — Mendatang)
- Sistem *Bookmark/Saved Articles*
- Sistem *Personalized Feed* berbasis riwayat baca
- Push Notification
- Search artikel full-text

---

## 4. Spesifikasi Fitur

### 4.1. Manajemen Kategori
**Aktor:** Admin (user dengan role `admin`)\
**Kebutuhan:**
- Admin bisa membuat, mengubah, dan menonaktifkan kategori.
- Kategori memiliki `slug` unik (e.g., `technology`, `sports`) yang digunakan sebagai filter query parameter.
- Endpoint publik `GET /categories` mengembalikan hanya kategori yang aktif.

### 4.2. Manajemen Artikel
**Aktor:** Admin\
**Kebutuhan:**
- Admin bisa membuat, mengubah, dan meng-arsipkan artikel.
- Setiap artikel wajib terhubung ke minimal satu kategori.
- Sistem secara otomatis menghitung `read_time_minutes` berdasarkan jumlah kata dalam konten (standar: **200 kata = 1 menit**).
- Status artikel: `draft` | `published` | `archived`. Hanya `published` yang muncul di feed publik.

### 4.3. Endpoint Feed Berita
**Aktor:** Pengguna publik (tanpa autentikasi)\
**Kebutuhan:**
- Feed mendukung paginasi via `page` dan `limit`.
- Feed bisa difilter berdasarkan `category` (slug).
- Parameter `include_hero=true` membungkus response: artikel pertama dipisah sebagai `hero_article`, sisanya masuk ke `feed_articles`.
- Urutan artikel default: terbaru berdasarkan `published_at`.

### 4.4. Endpoint Detail Artikel
**Aktor:** Pengguna publik\
**Kebutuhan:**
- Mengembalikan konten artikel lengkap (termasuk `content` / body teks).
- Mengembalikan informasi penulis, kategori, dan waktu baca.

### 4.5. Profil Pengguna
**Aktor:** Pengguna terotentikasi (Bearer JWT)\
**Kebutuhan:**
- GET profil: mengembalikan data `name`, `email`, `created_at`.
- PUT profil: memperbolehkan memperbarui `name`.

---

## 5. User Stories

```
[FEAT-01] Sebagai pengguna, saya ingin melihat daftar kategori berita
          agar saya bisa memfilter berita sesuai minat saya.

[FEAT-02] Sebagai pengguna, saya ingin melihat feed berita utama
          dengan satu berita hero besar di atas dan grid berita di bawahnya.

[FEAT-03] Sebagai pengguna, saya ingin membaca detail berita lengkap
          saat saya mengetuk salah satu kartu berita di feed.

[FEAT-04] Sebagai admin, saya ingin menambah artikel baru
          agar konten aplikasi terus diperbarui.

[FEAT-05] Sebagai pengguna terotentikasi, saya ingin melihat dan memperbarui profil saya.
```

---

## 6. Batasan & Asumsi
- Backend beroperasi di lingkungan VPS Linux (Ubuntu 22.04).
- Gambar artikel **tidak dihosting di backend ini** — disimpan di Cloud Storage (misalnya: Supabase Storage, Cloudinary, atau S3 kompatibel); backend hanya menyimpan URL-nya.
- Fase 1 tidak memiliki sistem role yang kompleks. Cukup dua level: `user` (default) dan `admin`.
- Autentikasi menggunakan JWT yang sudah dibangun pada iterasi sebelumnya.
