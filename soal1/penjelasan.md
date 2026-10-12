# Soal 1.3 — Analisis Audit & Keamanan Finansial

## Pertanyaan
Jelaskan mengapa pemisahan tabel Header-Line lebih andal dari sudut pandang jejak audit (audit trail) dan bentuk normal ketiga (3NF) dibandingkan model tabel tunggal (flat journal table).

---

## Jawaban

### A. Kelemahan Model Tabel Tunggal (Flat Journal Table)

Model tabel tunggal artinya semua data jurnal — tanggal, nomor bukti, deskripsi, akun, debit, kredit — dimasukkan ke dalam satu tabel besar. Contoh:

| tanggal    | no_bukti | deskripsi       | akun            | debit  | kredit |
|------------|----------|-----------------|-----------------|--------|--------|
| 2026-10-19 | JV-001   | Penerimaan jasa | Kas             | 500000 | 0      |
| 2026-10-19 | JV-001   | Penerimaan jasa | Pendapatan Jasa | 0      | 500000 |

Kelemahannya:

1. **Redundansi data tinggi** — tanggal, nomor bukti, dan deskripsi diulang di setiap baris. Kalau ada 10 baris jurnal, data header ikut terulang 10 kali.
2. **Rawan inkonsistensi** — kalau ada perubahan tanggal, harus update banyak baris. Kalau satu baris terlewat, data jadi tidak konsisten.
3. **Anomali update, insert, dan delete** — menghapus satu baris bisa menghilangkan info header yang seharusnya masih dipakai.
4. **Sulit diaudit** — tidak jelas mana "kepala transaksi" dan mana "detail". Auditor sulit melacak satu transaksi secara utuh.
5. **Tidak memenuhi 3NF** — ada ketergantungan transitif (misalnya nama akun tergantung pada kode akun, bukan langsung pada primary key).

---

### B. Kelebihan Model Header-Line

#### 1. Dari Sudut Pandang Audit Trail

- **Pemisahan jelas antara kepala dan detail transaksi.** Header menyimpan informasi transaksi (tanggal, nomor bukti, deskripsi, status posting, siapa buat, kapan dibuat). Line hanya menyimpan detail debit/kredit.
- **Pelacakan transaksi lebih mudah.** Auditor cukup melihat satu `header_id` untuk mendapatkan seluruh baris jurnal terkait.
- **Field audit terpusat.** `created_by`, `created_at`, dan `status_posting` tersimpan sekali di header, tidak duplikatif, sehingga jejak siapa-dan-kapan lebih terpercaya.
- **Mendukung immutability.** Header berstatus `POSTED` bisa dikunci agar tidak bisa diubah/dihapus; koreksi harus melalui jurnal pembalik (reversing entry).
- **Mendukung validasi double-entry.** Total debit dan kredit bisa dicek per header dengan mudah, baik lewat query maupun trigger.

#### 2. Dari Sudut Pandang 3NF (Third Normal Form)

| Bentuk Normal | Syarat | Pemenuhan di Desain Header-Line |
|---|---|---|
| **1NF** | Semua kolom atomik, tidak ada nilai berulang | Setiap kolom berisi satu nilai saja |
| **2NF** | Tidak ada ketergantungan parsial terhadap primary key | Primary key single column (`line_id`, `header_id`, `account_id`), tidak ada composite key parsial |
| **3NF** | Tidak ada ketergantungan transitif antar kolom non-key | Nama akun hanya ada di `chart_of_accounts`; data header hanya ada di `journal_headers` |

Contoh ketergantungan transitif yang dihindari:
- Di tabel tunggal: `line_id → account_code → account_name` (nama akun tergantung kode akun, bukan langsung ke line_id).
- Di desain Header-Line: `account_name` hanya ada di `chart_of_accounts`, dan `journal_lines` hanya menyimpan `account_id` sebagai foreign key.

---

### C. Kesimpulan

Model Header-Line lebih andal karena:

1. **Audit trail lebih kuat** — setiap perubahan bisa dilacak per header, termasuk siapa dan kapan.
2. **Konsistensi data terjaga** — tidak ada duplikasi data header di setiap baris.
3. **Memenuhi 3NF** — tidak ada ketergantungan parsial maupun transitif.
4. **Mendukung validasi double-entry** — total debit dan kredit dapat dicek per header.
5. **Mendukung immutability** — status `POSTED` bisa dikunci, koreksi lewat jurnal pembalik.
6. **Mencegah anomali** — tidak ada risiko satu transaksi memiliki tanggal berbeda karena semua baris terikat ke satu header.

Dengan demikian, desain Header-Line secara langsung menjawab masalah di konteks soal: mencegah anomali saldo tidak seimbang (unbalanced balance sheet) yang timbul karena validasi hanya dilakukan di frontend.