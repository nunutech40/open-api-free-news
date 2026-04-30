-- Migration: 012_make_phone_unique_for_otp.sql

-- 1. Ubah nomor HP kosong ('') menjadi NULL agar constraint UNIQUE tidak bertabrakan (karena banyak user belum isi nomor HP)
UPDATE users SET phone = NULL WHERE phone = '';

-- 2. Hapus default string kosong
ALTER TABLE users ALTER COLUMN phone DROP DEFAULT;

-- 3. Tambahkan constraint UNIQUE pada kolom phone
ALTER TABLE users ADD CONSTRAINT users_phone_unique UNIQUE (phone);
