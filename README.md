# 💳 Neo Analytics: FinTech Analytics Engineering Pipeline

A portfolio-grade, end-to-end analytics engineering pipeline built for **NorthPay** (a fictional Canadian FinTech payment processor). This repository transforms raw payment, refund, merchant, and fee plan data into production-ready dimensional models, core business metrics, and automated data quality test suites deployed using **dbt Core**.

---

## 🛠 Tech Stack

* **Data Warehouse:** Google Cloud BigQuery
* **Transformation & Modeling:** dbt Core (`dbt-bigquery`)
* **SQL Dialect:** Standard SQL / T-SQL
* **Data Ingestion:** dbt Seeds (Native CSV Loaders)
* **Version Control:** Git & GitHub

---

## 📂 Project Structure

```text
Neo_Analytics/
├── analyses/                     # Ad-hoc analytical queries and exploratory SQL
├── data/                         # Raw seed CSV backups
├── docs/                         # Project documentation and metric definitions
│   └── metrics.sql               # Production SQL logic for core business metrics
├── logs/                         # Execution and dbt log outputs
├── macros/                       # Reusable SQL macros and utility logging scripts
│   ├── .gitkeep
│   ├── grant_select.sql
│   └── log_tests_results.sql
├── models/
│   ├── marts/                    # Medallion Gold Layer: Star schema fact & dimension models
│   │   ├── fct_payments.sql
│   │   └── merchant_performance.sql
│   ├── staging/                  # Medallion Silver Layer: Views, type casting, & cleaning
│   │   ├── stg_fee_plans.sql
│   │   ├── stg_merchants.sql
│   │   ├── stg_refunds.sql
│   │   └── stg_transactions.sql
│   └── schema.yml                # Generic test assertions & column-level documentation
├── seeds/                        # Raw CSV seeds loaded via dbt
│   ├── .gitkeep
│   ├── fee_plans.csv             # 4 fee structures
│   ├── merchants.csv             # 10 merchant records
│   ├── refunds.csv               # ~3,500 refund transaction records
│   └── transactions.csv          # 50,000 core payment attempts
├── snapshots/                    # Type-2 slowly changing dimensions (SCD2)
├── tests/                        # Singular SQL custom tests & assertion rules
│   ├── .gitkeep
│   ├── assert_fx_fee.sql
│   ├── assert_no_refunds_on_failed_transactions.sql
│   ├── assert_refund_date_after_transaction_date.sql
│   ├── authorization_rate_bounds.sql
│   ├── cumulative_payment_refund_bounds.sql
│   └── monthly_fee_cap.sql
├── .gitignore                    # Local environment exclusion rules
├── dbt_project.yml               # Main dbt configuration and schema settings
├── README.md                     # Repository documentation & project brief
└── requirements.txt              # Python dependencies (dbt-core, adapters)
