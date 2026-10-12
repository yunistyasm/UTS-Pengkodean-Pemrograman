# Soal 2.2 — Penanganan Concurrency (Race Condition)

## Skenario Masalah
Dua kasir memproses penjualan untuk item yang sama pada detik yang bersamaan, ketika stok hanya tersisa 1 unit. Tanpa penguncian, keduanya bisa lolos pengecekan stok dan terjadi overselling (stok jadi minus / phantom stock).

## Penyebab
Pada PostgreSQL default (READ COMMITTED), dua transaksi bisa membaca nilai stock_qty yang sama sebelum salah satunya melakukan UPDATE. Akibatnya, pengecekan stok tidak akurat.

---

## Solusi 1: SELECT ... FOR UPDATE

Teknik ini mengunci baris item yang sedang diakses, sehingga transaksi lain harus menunggu sampai transaksi pertama selesai (COMMIT atau ROLLBACK).

### Contoh Kode (di dalam function trigger):

    SELECT stock_qty INTO stok_sekarang
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

Dengan FOR UPDATE, transaksi kedua akan menunggu di baris ini sampai transaksi pertama selesai. Setelah selesai, transaksi kedua baru membaca nilai stock_qty yang sudah ter-update.

### Contoh Skenario Kasir:

    -- Kasir A
    BEGIN;
    SELECT stock_qty FROM inventory_items WHERE item_id = 'ITM01' FOR UPDATE;
    -- A baca stok = 1, lolos cek, update stok jadi 0, COMMIT

    -- Kasir B (datang bersamaan)
    BEGIN;
    SELECT stock_qty FROM inventory_items WHERE item_id = 'ITM01' FOR UPDATE;
    -- B HARUS MENUNGGU sampai A selesai COMMIT

    -- Setelah A commit, B baru lanjut:
    -- B baca stok = 0, cek gagal (0 - 1 < 0), RAISE EXCEPTION
    -- Transaksi B dibatalkan, tidak terjadi overselling

---

## Solusi 2: Isolasi Transaksi SERIALIZABLE

Alternatif lain: set level isolasi transaksi ke SERIALIZABLE. PostgreSQL akan otomatis membatalkan transaksi yang konflik.

### Contoh:

    BEGIN ISOLATION LEVEL SERIALIZABLE;

    SELECT stock_qty FROM inventory_items WHERE item_id = 'ITM01';
    -- Kalau ada konflik, PostgreSQL akan rollback salah satu transaksi
    -- dan mengeluarkan error: could not serialize access

    UPDATE inventory_items SET stock_qty = stock_qty - 1 WHERE item_id = 'ITM01';

    COMMIT;

---

## Perbandingan

| Metode | Kelebihan | Kekurangan |
|---|---|---|
| SELECT ... FOR UPDATE | Kunci spesifik per baris, ringan, cepat | Harus eksplisit di kode |
| SERIALIZABLE | Otomatis deteksi konflik | Lebih sering rollback, cocok untuk transaksi kritikal |

---

## Kesimpulan
Untuk sistem persediaan retail dengan traffic tinggi, SELECT ... FOR UPDATE lebih cocok karena:

1. Hanya mengunci baris item yang benar-benar diakses.
2. Tidak mengganggu transaksi item lain.
3. Cukup ringan untuk aplikasi kasir.

Kombinasi FOR UPDATE di trigger + CHECK (stock_qty >= 0) di tabel memberi perlindungan ganda terhadap overselling.