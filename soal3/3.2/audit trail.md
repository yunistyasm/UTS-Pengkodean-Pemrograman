# Soal 3.2 — Mekanisme Jejak Audit (Audit Trail & Immutability)

## A. SQL Lengkap (untuk dijalankan di Supabase)

```sql
-- =========================================================
-- SOAL 3.2: Audit Trail & Immutability
-- =========================================================

-- ---------- 0. Bersihkan (kalau sudah ada dari run sebelumnya) ----------

DROP TRIGGER IF EXISTS trg_prevent_posted_change ON journal_headers;
DROP TRIGGER IF EXISTS trg_generate_hash_checksum ON journal_headers;
DROP FUNCTION IF EXISTS prevent_posted_change();
DROP FUNCTION IF EXISTS generate_hash_checksum();
DROP TABLE IF EXISTS journal_lines CASCADE;
DROP TABLE IF EXISTS journal_headers CASCADE;
DROP TABLE IF EXISTS chart_of_accounts CASCADE;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------- 1. Buat Tabel dengan Kolom Audit Lengkap ----------

CREATE TABLE chart_of_accounts (
    account_id            SERIAL PRIMARY KEY,
    account_code          VARCHAR(20)  NOT NULL UNIQUE,
    account_name          VARCHAR(100) NOT NULL,
    normal_balance        VARCHAR(10)  NOT NULL
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    report_classification VARCHAR(50)  NOT NULL
);

CREATE TABLE journal_headers (
    header_id      SERIAL PRIMARY KEY,
    trx_date       DATE         NOT NULL,
    reference_no   VARCHAR(50)  NOT NULL UNIQUE,
    description    TEXT,
    status_posting VARCHAR(10)  NOT NULL DEFAULT 'DRAFT'
        CHECK (status_posting IN ('DRAFT', 'POSTED', 'VOID')),
    created_by     VARCHAR(50),
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_by     VARCHAR(50),
    updated_at     TIMESTAMP,
    hash_checksum  VARCHAR(64)
);

CREATE TABLE journal_lines (
    line_id    SERIAL PRIMARY KEY,
    header_id  INT            NOT NULL,
    account_id INT            NOT NULL,
    debit      NUMERIC(15,2)  NOT NULL DEFAULT 0 CHECK (debit >= 0),
    credit     NUMERIC(15,2)  NOT NULL DEFAULT 0 CHECK (credit >= 0),
    CONSTRAINT chk_tidak_nol CHECK (NOT (debit = 0 AND credit = 0)),
    CONSTRAINT fk_line_header FOREIGN KEY (header_id)
        REFERENCES journal_headers(header_id) ON DELETE RESTRICT,
    CONSTRAINT fk_line_account FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts(account_id) ON DELETE RESTRICT
);

-- ---------- 2. Trigger: Blokir UPDATE/DELETE pada POSTED ----------

CREATE OR REPLACE FUNCTION prevent_posted_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        IF OLD.status_posting = 'POSTED' THEN
            RAISE EXCEPTION 'Transaksi POSTED (header_id=%) tidak boleh dihapus. Buat jurnal pembalik.',
                OLD.header_id;
        END IF;
        RETURN OLD;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF OLD.status_posting = 'POSTED' THEN
            RAISE EXCEPTION 'Transaksi POSTED (header_id=%) tidak boleh diubah. Buat jurnal pembalik.',
                OLD.header_id;
        END IF;
        NEW.updated_by := CURRENT_USER;
        NEW.updated_at := CURRENT_TIMESTAMP;
        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_posted_change
BEFORE UPDATE OR DELETE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION prevent_posted_change();

-- ---------- 3. Trigger: Auto-Generate Hash Checksum ----------

CREATE OR REPLACE FUNCTION generate_hash_checksum()
RETURNS TRIGGER AS $$
DECLARE
    v_content TEXT;
BEGIN
    IF NEW.status_posting = 'POSTED'
       AND (OLD.hash_checksum IS NULL OR OLD.status_posting <> 'POSTED') THEN
        v_content := COALESCE(NEW.header_id::TEXT, '') ||
                     COALESCE(NEW.trx_date::TEXT, '') ||
                     COALESCE(NEW.reference_no, '') ||
                     COALESCE(NEW.description, '') ||
                     COALESCE(NEW.created_by, '') ||
                     COALESCE(NEW.created_at::TEXT, '');
        NEW.hash_checksum := encode(digest(v_content, 'sha256'), 'hex');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generate_hash_checksum
BEFORE UPDATE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION generate_hash_checksum();

-- ---------- 4. Insert Data Uji ----------

INSERT INTO chart_of_accounts (account_code, account_name, normal_balance, report_classification)
VALUES
    ('101', 'Kas',           'DEBIT', 'Aset Lancar'),
    ('501', 'Beban Listrik', 'DEBIT', 'Beban');

INSERT INTO journal_headers (trx_date, reference_no, description, status_posting, created_by)
VALUES ('2026-10-19', 'KK-001', 'Pembayaran beban listrik', 'DRAFT', 'admin');

INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES
    (1, 2, 500000, 0),
    (1, 1, 0, 500000);

-- ---------- 5. Ubah DRAFT → POSTED (auto-generate hash) ----------

UPDATE journal_headers
SET status_posting = 'POSTED'
WHERE reference_no = 'KK-001';

-- ---------- 6. Cek hash_checksum ----------

SELECT header_id,
       reference_no,
       status_posting,
       created_by,
       created_at,
       hash_checksum
FROM journal_headers
WHERE reference_no = 'KK-001';

-- ---------- 7. Uji UPDATE jurnal POSTED (harus ERROR) ----------

-- UPDATE journal_headers
-- SET description = 'Diubah paksa'
-- WHERE reference_no = 'KK-001';

-- ---------- 8. Uji DELETE jurnal POSTED (harus ERROR) ----------

-- DELETE FROM journal_headers WHERE reference_no = 'KK-001';