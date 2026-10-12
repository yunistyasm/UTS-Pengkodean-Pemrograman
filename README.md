# 📊 Proyek UTS Coding Akuntansi

Repositori ini berisi pengerjaan UTS Coding Akuntansi, meliputi perancangan database *General Ledger*, otomasi persediaan perpetual dengan penanganan *concurrency*, serta dokumentasi audit trail dan immutability.

## 👤 Identitas Mahasiswa

- **Nama:** Yunistya Salwa Maharani
- **NIM:** 12030124120042
- **Mata Kuliah / Kelas:** Pengkodean dan Pemrograman / D
- **Dosen Pengampu:** Dr. Totok Dewayanto, S.E., M.Si., Akt., CA
- **Program Studi:** S1 Akuntansi
- **Fakultas:** Ekonomika dan Bisnis
- **Universitas:** Universitas Diponegoro
- **Tahun:** 2026

## 🚀 Ringkasan Isi

### Soal 1 — Skema Database General Ledger

Folder [`soal1/`](./soal1/) berisi skema General Ledger dengan tabel `chart_of_accounts`, `journal_headers`, dan `journal_lines`. Script SQL dilengkapi constraint dan trigger untuk memeriksa keseimbangan debit-kredit. Dokumentasi folder ini juga membahas ERD serta audit trail dan bentuk normal ketiga (3NF).

### Soal 2 — Persediaan Perpetual dan Concurrency

Folder [`soal 2/`](./soal%202/) berisi implementasi pembaruan stok untuk transaksi `PURCHASE`, `SALE`, dan `ADJUSTMENT`. Trigger menggunakan `SELECT ... FOR UPDATE` untuk mengunci baris barang selama transaksi dan memeriksa ketersediaan stok sebelum penjualan.

### Soal 3 — Voucher Entri Kas Keluar dan Audit Trail

Folder [`soal3/`](./soal3/) berisi materi antarmuka voucher dan dokumentasi audit trail:

- [`soal3/3.1/`](./soal3/3.1/) — materi bagian 3.1, termasuk purwarupa voucher dan ringkasan NotebookLM.
- [`soal3/3.2/audit trail.md`](./soal3/3.2/audit%20trail.md) — SQL dan penjelasan audit trail, immutability, serta hash checksum.
- Gambar pendukung soal 3 disimpan langsung di folder `soal3/`.

## 🛠️ Teknologi dan Konsep

- PostgreSQL / Supabase SQL Editor
- SQL: DDL, DML, constraint, dan trigger
- Double-entry bookkeeping dan General Ledger
- Persediaan perpetual dan pengendalian concurrency
- Audit trail, immutability, dan hash checksum
- HTML untuk dokumen jawaban UTS

## 📂 Struktur Repositori

```text
.
├── README.md
├── Jawaban UTS - Yunistya Salwa Maharani.pdf
├── jawaban_uts.html
├── soal1/
│   ├── Gambar 1.1.png
│   ├── Gambar 1.2.png
│   ├── erd.md
│   ├── penjelasan.md
│   └── soal1.sql
├── soal 2/
│   ├── Gambar 2.1.png
│   ├── Gambar 2.2.png
│   ├── penjelasan.md
│   └── soal2.sql
└── soal3/
    ├── 3.1/
    │   ├── 3.1a
    │   └── 3.1b
    ├── 3.2/
    │   └── audit trail.md
    ├── Gambar 3.1.png
    ├── Gambar 3.2.png
    ├── Gambar 3.3.png
    ├── Gambar 3.4.png
    ├── Gambar 3.5.png
```

## 💻 Cara Membaca dan Menjalankan

### Script SQL

1. Buka PostgreSQL atau SQL Editor di Supabase.
2. Jalankan [`soal1/soal1.sql`](./soal1/soal1.sql) untuk skema General Ledger.
3. Jalankan [`soal 2/soal2.sql`](./soal%202/soal2.sql) untuk skema persediaan perpetual.
4. Untuk soal 3.2, buka [`soal3/3.2/audit trail.md`](./soal3/3.2/audit%20trail.md) dan jalankan bagian SQL di dalamnya.

Script soal 1, soal 2, dan soal 3 merupakan contoh untuk topik masing-masing. Periksa perintah `DROP TABLE` pada script sebelum menjalankannya, terutama jika database berisi data yang ingin dipertahankan.

## 📜 Lisensi

**Copyright (c) 2026 Yunistya Salwa Maharani.**

Materi ini dibuat untuk keperluan pembelajaran dan tugas akademik.

---

*Dibuat untuk memenuhi UTS Coding Akuntansi FEB Universitas Diponegoro 2026.*
