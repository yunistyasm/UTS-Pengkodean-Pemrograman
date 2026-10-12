-- =========================================================
-- SOAL 2: Otomasi Persediaan Perpetual
-- =========================================================

DROP TRIGGER IF EXISTS trg_update_stock_and_journal ON inventory_transactions;
DROP FUNCTION IF EXISTS trg_update_stock_and_journal();
DROP TABLE IF EXISTS inventory_transactions CASCADE;
DROP TABLE IF EXISTS inventory_items CASCADE;

CREATE TABLE inventory_items (
    item_id    VARCHAR(10) PRIMARY KEY,
    item_name  VARCHAR(100),
    stock_qty  INT NOT NULL DEFAULT 0,
    unit_cost  NUMERIC(15, 2) NOT NULL
);

CREATE TABLE inventory_transactions (
    trx_id    SERIAL PRIMARY KEY,
    item_id   VARCHAR(10) REFERENCES inventory_items(item_id),
    trx_type  VARCHAR(10) CHECK (trx_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT')),
    qty       INT NOT NULL,
    trx_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    stok_sekarang INT;
BEGIN
    SELECT stock_qty INTO stok_sekarang
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item % tidak ditemukan di inventory_items', NEW.item_id;
    END IF;

    IF NEW.trx_type = 'PURCHASE' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'SALE' THEN
        IF stok_sekarang - NEW.qty < 0 THEN
            RAISE EXCEPTION 'Stok tidak cukup untuk item %. Stok tersedia = %, diminta = %',
                NEW.item_id, stok_sekarang, NEW.qty;
        END IF;

        UPDATE inventory_items
        SET stock_qty = stock_qty - NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_and_journal
AFTER INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_and_journal();

INSERT INTO inventory_items (item_id, item_name, stock_qty, unit_cost)
VALUES ('ITM01', 'Kertas A4', 0, 50000);

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM01', 'PURCHASE', 10);

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM01', 'SALE', 3);

SELECT * FROM inventory_items WHERE item_id = 'ITM01';

-- INSERT INTO inventory_transactions (item_id, trx_type, qty)
-- VALUES ('ITM01', 'SALE', 100);