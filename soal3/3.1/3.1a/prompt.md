# Log Prompt — Pembuatan Form Voucher Kas Keluar

## Prompt yang Digunakan:

"Buatkan form entri jurnal kas keluar menggunakan HTML + Tailwind CSS
dengan desain pastel blue aesthetic. Fitur:
- Input header: tanggal, nomor bukti, deskripsi
- Tabel baris jurnal dinamis: akun, debit, kredit (bisa tambah/hapus baris)
- Total debit dan total kredit dihitung otomatis (live)
- Indikator visual BALANCE (hijau) / TIDAK BALANCE (merah)
- Tombol Submit hanya aktif kalau total debit = total kredit dan > 0
- Audit log JSON muncul setelah submit
Gunakan font Plus Jakarta Sans, glassmorphism card, dan gradient title."

## Hasil:
Form HTML single-file yang dapat dibuka langsung di browser tanpa instalasi.
Validasi zero-discrepancy diterapkan di sisi klien (frontend).

## Catatan:
Kode diadaptasi dari output AI untuk memenuhi kebutuhan purwarupa
modul Voucher Entri Kas Keluar.