-- =========================================================
-- SOAL 1: Skema Database General Ledger
-- =========================================================

-- ---------- 1. DDL: Buat Tabel ----------

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
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE journal_lines (
    line_id    SERIAL PRIMARY KEY,
    header_id  INT            NOT NULL,
    account_id INT            NOT NULL,
    debit      NUMERIC(15,2)  NOT NULL DEFAULT 0 CHECK (debit >= 0),
    credit     NUMERIC(15,2)  NOT NULL DEFAULT 0 CHECK (credit >= 0),

    CONSTRAINT chk_tidak_nol_dua_duanya
        CHECK (NOT (debit = 0 AND credit = 0)),

    CONSTRAINT chk_debit_atau_kredit
        CHECK (debit = 0 OR credit = 0),

    CONSTRAINT fk_line_header
        FOREIGN KEY (header_id)
        REFERENCES journal_headers(header_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_line_account
        FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts(account_id)
        ON DELETE RESTRICT
);

-- ---------- 2. Trigger Double-Entry ----------

CREATE OR REPLACE FUNCTION check_journal_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_header_id INT;
    v_debit     NUMERIC(15,2);
    v_credit    NUMERIC(15,2);
BEGIN
    v_header_id := COALESCE(NEW.header_id, OLD.header_id);

    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0)
    INTO v_debit, v_credit
    FROM journal_lines
    WHERE header_id = v_header_id;

    IF v_debit <> v_credit THEN
        RAISE EXCEPTION 'Jurnal tidak balance. Debit = %, Kredit = %',
            v_debit, v_credit;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_journal_balance
AFTER INSERT OR UPDATE OR DELETE ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION check_journal_balance();

-- ---------- 3. Uji Coba: Data Master ----------

INSERT INTO chart_of_accounts (account_code, account_name, normal_balance, report_classification)
VALUES
    ('101', 'Kas',             'DEBIT',  'Aset Lancar'),
    ('401', 'Pendapatan Jasa', 'CREDIT', 'Pendapatan');

-- ---------- 4. Uji Coba: Jurnal BALANCE (harus SUKSES) ----------

BEGIN;

INSERT INTO journal_headers (trx_date, reference_no, description, status_posting, created_by)
VALUES ('2026-10-19', 'JV-001', 'Penerimaan kas jasa', 'POSTED', 'admin');

INSERT INTO journal_lines (header_id, account_id, debit, credit)
SELECT h.header_id, a.account_id, v.debit, v.credit
FROM journal_headers h
JOIN (VALUES
    ('101', 500000::NUMERIC, 0::NUMERIC),
    ('401', 0::NUMERIC,      500000::NUMERIC)
) AS v(account_code, debit, credit) ON TRUE
JOIN chart_of_accounts a ON a.account_code = v.account_code
WHERE h.reference_no = 'JV-001';

COMMIT;

-- Hasil: berhasil, tidak ada error.

-- ---------- 5. Uji Coba: Jurnal TIDAK BALANCE (harus GAGAL) ----------
-- Jalankan blok ini untuk membuktikan trigger bekerja.
-- Akan muncul: ERROR: Jurnal tidak balance. Debit = 500000.00, Kredit = 400000.00

BEGIN;

INSERT INTO journal_headers (trx_date, reference_no, description, status_posting, created_by)
VALUES ('2026-10-19', 'JV-002', 'Jurnal sengaja salah', 'POSTED', 'admin');

INSERT INTO journal_lines (header_id, account_id, debit, credit)
SELECT h.header_id, a.account_id, v.debit, v.credit
FROM journal_headers h
JOIN (VALUES
    ('101', 500000::NUMERIC, 0::NUMERIC),
    ('401', 0::NUMERIC,      400000::NUMERIC)
) AS v(account_code, debit, credit) ON TRUE
JOIN chart_of_accounts a ON a.account_code = v.account_code
WHERE h.reference_no = 'JV-002';

COMMIT;
-- COMMIT tidak akan tercapai karena RAISE EXCEPTION di trigger.

-- ---------- 6. Query Cek Keseimbangan ----------

SELECT h.header_id,
       h.reference_no,
       SUM(l.debit)  AS total_debit,
       SUM(l.credit) AS total_credit,
       CASE
           WHEN SUM(l.debit) = SUM(l.credit) THEN 'BALANCE'
           ELSE 'TIDAK BALANCE'
       END AS status
FROM journal_headers h
JOIN journal_lines l ON h.header_id = l.header_id
GROUP BY h.header_id, h.reference_no
ORDER BY h.header_id;