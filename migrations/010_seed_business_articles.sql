-- Migration: 010_seed_business_articles.sql
-- Run: psql -U postgres -d free_api_news -f migrations/010_seed_business_articles.sql

-- 1. Pastikan kategori Business ada
INSERT INTO categories (name, slug, is_active)
VALUES ('Business', 'business', true)
ON CONFLICT (slug) DO NOTHING;

-- Ambil ID Kategori Business dan ID Admin (User 1) untuk artikel
DO $$
DECLARE
    biz_cat_id BIGINT;
    admin_id BIGINT;
BEGIN
    SELECT id INTO biz_cat_id FROM categories WHERE slug = 'business' LIMIT 1;
    -- Anggap aja user admin id-nya 1 (bawaan seed_users sebelumnya, atau fallback ke 1)
    SELECT id INTO admin_id FROM users WHERE email = 'nunu@example.com' LIMIT 1;
    IF admin_id IS NULL THEN
        SELECT id INTO admin_id FROM users ORDER BY id ASC LIMIT 1;
    END IF;

    -- 2. Memasukkan artikel kualitas tinggi
    INSERT INTO articles (category_id, author_id, title, slug, excerpt, content, image_url, status, published_at)
    VALUES
    (
        biz_cat_id, admin_id,
        'Saham Startup Asia Tenggara Menggeliat di Kuartal Ketiga',
        'saham-startup-asean-q3',
        'Menyusul penurunan bunga dari the Fed, sektor startup digital di ASEAN mengalami lonjakan investasi baru yang signifikan.',
        '<div><p>Setelah mengalami musim dingin pendanaan yang panjang sepanjang tahun lalu, kuartal ketiga tahun ini memberikan secercah harapan bagi ekosistem startup di Asia Tenggara.</p><p>Data terbaru menunjukkan peningkatan suntikan dana segar hingga 45% di sektor teknologi finansial (Fintech) dan kecerdasan buatan (AI) di regional ini. Dominasi pendanaan terbesar masih dipegang oleh investor berbasis di Singapura dan disusul oleh konglomerasi lokal Indonesia.</p></div>',
        'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&q=80&w=1000',
        'published', NOW()
    ),
    (
        biz_cat_id, admin_id,
        'Transaksi Digital Melampaui Rekor, Tinggalkan Uang Kartal',
        'transaksi-digital-rekor-2026',
        'Bank Sentral melaporkan volume transaksi menggunakan QRIS dan dompet digital memecahkan rekor tertinggi sepanjang sejarah pada bulan lalu.',
        '<div><p>Adopsi penetrasi dompet pintar serta infrastruktur internet yang merata berhasil mendorong masyarakat beralih dari pembayaran tunai ke digital secara masif.</p><p>Gubernur Bank Sentral mencatat bahwa ada pergeseran perilaku konsumen, di mana lebih dari 70% transaksi ritel di kota-kota besar kini sepenuhnya *cashless*.</p></div>',
        'https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&q=80&w=1000',
        'published', NOW() - INTERVAL '1 day'
    ),
    (
        biz_cat_id, admin_id,
        'Akuisisi Raksasa E-Commerce: Babak Baru Kompetisi',
        'akuisisi-ecommerce-raksasa',
        'Salah satu pemain terbesar e-commerce resmi mengakuisisi perusahaan logistik ternama demi mengamankan rantai pasok global.',
        '<div><p>Langkah strategis kembali diambil oleh pemain utama *e-commerce*. Dengan akuisisi senilai triliunan rupiah ini, mereka tidak hanya mengakuisisi ratusan armada kargo, melainkan hak guna atas gudang-gudang pintar (*smart warehouse*) di pesisir Asia.</p></div>',
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=1000',
        'published', NOW() - INTERVAL '2 days'
    ),
    (
        biz_cat_id, admin_id,
        'Harga Emas Diprediksi Sentuh Angka Psikologis Baru',
        'harga-emas-psikologis-baru',
        'Analis memperkirakan ketidakpastian geopolitik akan menggemukkan kembali nilai lindung emas menjelang akhir tahun.',
        '<div><p>Investasi pada *safe haven* kembali dilirik. Emas kini diincar oleh berbagai institusi perbankan sentral di dunia.</p><p>Ketegangan perdagangan antara wilayah barat dan timur memberikan insentif psikologis pada investor ritel untuk menimbun logam mulia ini sebagai portofolio defensif mereka.</p></div>',
        'https://images.unsplash.com/photo-1610375461246-83df859d849d?auto=format&fit=crop&q=80&w=1000',
        'published', NOW() - INTERVAL '3 days'
    ),
    (
        biz_cat_id, admin_id,
        'Perpindahan Industri Manufaktur Baterai EV ke Indonesia',
        'manufaktur-baterai-ev-indonesia',
        'Pemerintah meresmikan mega-pabrik pengolahan nikel dan produksi sel baterai kendaraan listrik fase kedua.',
        '<div><p>Dengan memegang cadangan nikel terbesar, Indonesia berhasil merayu tiga produsen otomotif kelas dunia untuk sepenuhnya menanamkan pabrik baterai mereka di wilayah kawasan industri terpadu.</p></div>',
        'https://images.unsplash.com/photo-1620912189851-f7ee339890ea?auto=format&fit=crop&q=80&w=1000',
        'published', NOW() - INTERVAL '4 days'
    )
    ON CONFLICT (slug) DO NOTHING;

END $$;
