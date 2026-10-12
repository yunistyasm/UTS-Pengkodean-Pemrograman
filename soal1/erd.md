┌─────────────────────────────┐
│    chart_of_accounts        │
├─────────────────────────────┤
│ PK  account_id              │
│     account_code (UNIQUE)   │
│     account_name            │
│     normal_balance          │
│     report_classification   │
└──────────────┬──────────────┘
               │ 1
               │
               │ N
┌──────────────▼──────────────┐         ┌─────────────────────────────┐
│       journal_lines         │ N     1 │     journal_headers         │
├─────────────────────────────┤◄────────├─────────────────────────────┤
│ PK  line_id                 │         │ PK  header_id               │
│ FK  header_id               │         │     trx_date                │
│ FK  account_id              │         │     reference_no (UNIQUE)   │
│     debit                   │         │     description             │
│     credit                  │         │     status_posting          │
└─────────────────────────────┘         │     created_by              │
                                        │     created_at              │
                                        └─────────────────────────────┘