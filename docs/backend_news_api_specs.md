# Backend API Requirements: News Dashboard UI

Berdasarkan prototipe UI bergaya *Editorial Premium* (kiblat Apple News/Flipboard), Backend harus menyajikan JSON yang bersih agar *frontend* (Flutter) tidak perlu kerepotan melakukan *heavy computation* memilah dan memilah berita secara manual. UI menuntut pemisahan antara 1 *Hero Article* raksasa di atas dan jejeran *Grid Articles* di bawahnya.

Berikut adalah 4 poin krusial yang wajib dipersiapkan oleh Backend Engineer (Go/PostgreSQL):

## 1. Flagging "Hero Article" (Headline Utama)
Karena tampilan UI butuh spesifik 1 berita sebagai *header full-bleed*, backend sangat disarankan untuk menyediakan struktur json yang sudah mengkotakkan antara headline utama dan *feed* di bawahnya.

**Contoh Response Ideal `/api/v1/news?include_hero=true`:**
```json
{
  "status": "success",
  "data": {
    "hero_article": { 
      "id": 99, 
      "title": "Global Markets Surge as Tech Leaders Chart Future.",
      ...
    },
    "feed_articles": [ 
      { "id": 100, "title": "Apple's AI Leap", ... },
      { "id": 101, "title": "Fed Chair Signals...", ... }
    ],
    "meta": { "total_pages": 5, "current_page": 1 }
  }
}
```

## 2. Struktur Metadata Artikel
Tabel `articles` atau response JSON wajib mengirimkan atribut-atribut ekstra ini:
*   `category_name`: (String) e.g., `"Technology"`, `"Finance"` (Untuk Label kecil / Chip di atas gambar grid).
*   `author_name`: (String) e.g., `"By Eleanor Vance"` (Ditampilkan di deskripsi Hero).
*   `read_time_minutes`: (Integer) e.g., `2`. Backend mengestimasi menit baca (Misal: 1 menit = 200 kata konten). UI cukup mencetak `2m read`.
*   `published_at`: (ISO 8601 Datetime). Wajib dikirim mentah format UTC agar Flutter bisa mengubahnya menjadi relativitas waktu lokal seperti `"4m ago"` atau `"2h ago"` menggunakan *package* `timeago`.

## 3. Optimasi Image URL (Thumbnail vs High-Resolution)
Karena kita memiliki porsi gambar besar dan list grid kecil, direkomendasikan memiliki variasi ukuran agar memori HP pengguna tidak terkuras memuat foto *4K* untuk bentuk grid yang kecil.
*   `image_url`: Resolusi rasio besar (*high-res*) khusus untuk Hero Banner.
*   `thumbnail_url` *(Opsional)*: Resolusi *compressed/cropped* khusus untuk Feed/Grid Thumbnail.

## 4. Endpoint Kategori & Personalization (Navigasi Atas)
Untuk mendukung *Horizontal Filter Chips* di bawah Search bar, backend wajib menyiapkan endpoint kategori yang sedang hot atau *personalized*:

**Endpoint:** `GET /api/v1/categories`
```json
{
  "status": "success",
  "data": [
    {"id": 1, "slug": "for-you", "name": "For You", "is_personalized": true},
    {"id": 2, "slug": "technology", "name": "Technology", "is_personalized": false},
    {"id": 3, "slug": "finance", "name": "Finance", "is_personalized": false},
    {"id": 4, "slug": "sports", "name": "Sports", "is_personalized": false}
  ]
}
```

## Kesimpulan Rekap Pekerjaan BE
Fase selanjutnya bagi BE adalah mendesain/memodifikasi dua buah *endpoint* ini agar patuh pada kontrak JSON terstruktur di atas:
1. `GET /api/v1/categories` -> Kontrak parameter *filter chips*.
2. `GET /api/v1/news` -> Kontrak isi yang memuat objek terotentikasi `hero_article` dan array `feed_articles`.

Jika pondasi Backend ini *solid*, developer Frontend (Flutter) akan dengan mudah dan cepat memasangkan antarmuka Premium dan dinamis tanpa harus membuat *workaround* data yang berantakan!
