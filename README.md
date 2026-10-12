<div align="center">

# 📊 UTS Coding Akuntansi

### Sistem General Ledger, Persediaan Perpetual & Audit Trail

<img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
<img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
<img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" alt="HTML5" />
<img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge" alt="Status: Completed" />

**Repositori pengerjaan UTS Coding Akuntansi** — mencakup perancangan skema database *General Ledger*, otomasi persediaan *perpetual* dengan penanganan *concurrency*, serta implementasi *audit trail* dan *immutability*.

</div>

---

## 👤 Identitas Mahasiswa

| Informasi | Detail |
|---|---|
| **Nama** | Yunistya Salwa Maharani |
| **NIM** | 12030124120042 |
| **Mata Kuliah / Kelas** | Pengkodean dan Pemrograman / D |
| **Dosen Pengampu** | Dr. Totok Dewayanto, S.E., M.Si., Akt., CA |
| **Program Studi** | S1 Akuntansi |
| **Fakultas** | Ekonomika dan Bisnis |
| **Universitas** | Universitas Diponegoro |
| **Tahun** | 2026 |

---

## 🎯 Highlight Proyek

| 🧾 General Ledger | 📦 Persediaan Perpetual | 🖥️ Voucher Kas Keluar | 🔐 Audit Trail |
|---|---|---|---|
| Model Header-Line, 3NF, dan double-entry | Pengendalian concurrency dengan `FOR UPDATE` | Purwarupa form voucher interaktif | Immutability dan hash checksum SHA-256 |

---

## 📁 Struktur Repositori

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
    │   ├── 3.1a/
    │   │   ├── audit_log.png
    │   │   ├── balance.png
    │   │   ├── index.html
    │   │   ├── prompt.md
    │   │   └── tidak balance.png
    │   └── 3.1b/
    │       └── ringkasan notebooklm.md
    ├── 3.2/
    │   └── audit trail.md
    ├── Gambar 3.1.png
    ├── Gambar 3.2.png
    ├── Gambar 3.3.png
    ├── Gambar 3.4.png
    └── Gambar 3.5.png
```

---

## 🧩 Detail Pengerjaan

### 🔹 Soal 1 — Skema Database General Ledger

📁 [`soal1/`](./soal1/)

Merancang skema General Ledger menggunakan model **Header-Line** dan constraint database untuk mendukung pencatatan double-entry.

| Objek | Fungsi |
|---|---|
| `chart_of_accounts` | Master akun, saldo normal, dan klasifikasi laporan |
| `journal_headers` | Informasi utama transaksi jurnal |
| `journal_lines` | Detail akun dan nilai debit/kredit |
| `check_journal_balance()` | Memvalidasi keseimbangan debit dan kredit |

📎 Dokumentasi: [`erd.md`](./soal1/erd.md) · [`penjelasan.md`](./soal1/penjelasan.md) · [`soal1.sql`](./soal1/soal1.sql)

### 🔹 Soal 2 — Persediaan Perpetual & Concurrency

📁 [`soal 2/`](./soal%202/)

Trigger `trg_update_stock_and_journal()` memperbarui stok sesuai jenis transaksi:

| Transaksi | Efek pada Stok |
|---|---|
| `PURCHASE` | Menambah stok |
| `SALE` | Mengurangi stok setelah memeriksa jumlah yang tersedia |
| `ADJUSTMENT` | Menyesuaikan stok sesuai nilai transaksi |

**Penanganan race condition** dilakukan dengan `SELECT ... FOR UPDATE` untuk mengunci baris barang selama transaksi, sehingga transaksi lain harus menunggu sebelum memeriksa dan mengubah stok barang yang sama.

📎 Dokumentasi: [`soal2.sql`](./soal%202/soal2.sql) · [`penjelasan.md`](./soal%202/penjelasan.md)

### 🔹 Soal 3 — Voucher Entri Kas Keluar & Audit Trail

📁 [`soal3/`](./soal3/)

| Bagian | Isi | Berkas |
|---|---|---|
| **3.1a** | Purwarupa voucher, tampilan balance, dan audit log | [`index.html`](./soal3/3.1/3.1a/index.html) |
| **3.1b** | Ringkasan verifikasi aturan bisnis melalui NotebookLM | [`ringkasan notebooklm.md`](./soal3/3.1/3.1b/ringkasan%20notebooklm.md) |
| **3.2** | SQL dan penjelasan audit trail, immutability, dan hash checksum | [`audit trail.md`](./soal3/3.2/audit%20trail.md) |

**Mekanisme audit trail pada bagian 3.2:**

- Trigger `prevent_posted_change()` mencegah `UPDATE` atau `DELETE` pada jurnal berstatus `POSTED`.
- Hash checksum SHA-256 dibuat saat jurnal diposting.
- Koreksi transaksi yang sudah diposting dilakukan melalui jurnal pembalik.

---

## ⚙️ Cara Menjalankan SQL

1. Buka PostgreSQL atau SQL Editor Supabase.
2. Jalankan [`soal1/soal1.sql`](./soal1/soal1.sql) untuk skema General Ledger.
3. Jalankan [`soal 2/soal2.sql`](./soal%202/soal2.sql) untuk skema persediaan perpetual.
4. Untuk soal 3.2, buka [`soal3/3.2/audit trail.md`](./soal3/3.2/audit%20trail.md) dan jalankan bagian SQL di dalamnya.

> ⚠️ Periksa perintah `DROP TABLE` pada script soal 3.2 sebelum menjalankannya. Script tersebut menghapus dan membuat ulang tabel terkait, sehingga dapat menghapus data yang sudah ada.

---

## 🧠 Konsep Kunci

- **Double-Entry Bookkeeping** — validasi debit dan kredit pada jurnal.
- **Third Normal Form (3NF)** — pemisahan data akun, header jurnal, dan baris jurnal.
- **Concurrency Control** — penggunaan `SELECT ... FOR UPDATE` untuk mengendalikan akses stok bersamaan.
- **Immutability** — perlindungan terhadap perubahan jurnal yang sudah `POSTED`.
- **Hash Checksum** — penggunaan SHA-256 sebagai checksum pada proses posting.

---

## 🛠️ Teknologi

| Kategori | Teknologi |
|---|---|
| Database | PostgreSQL, Supabase SQL Editor |
| Bahasa dan fitur database | SQL, PL/pgSQL, trigger, constraint |
| Frontend | HTML5, Tailwind CSS, Vanilla JavaScript |
| AI verification | NotebookLM, Gemini Canvas |

---

<div align="center">

### 📜 Lisensi

**Copyright (c) 2026 Yunistya Salwa Maharani**

Materi ini dibuat untuk keperluan pembelajaran dan tugas akademik.

---

*Dibuat untuk memenuhi UTS Coding Akuntansi*  
*Fakultas Ekonomika dan Bisnis · Universitas Diponegoro · 2026*

</div>
