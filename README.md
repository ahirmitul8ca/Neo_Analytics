# 💳 Neo Analytics: FinTech Analytics Engineering Pipeline

A portfolio-grade, end-to-end analytics engineering pipeline built for NorthPay (a fictional Canadian FinTech payment processor). This repository transforms raw payment, refund, merchant, and fee plan data into production-ready dimensional models, core business metrics, and automated data quality test suites deployed using dbt Core.

---

## 🛠 Tech Stack

| Component | Technology / Specification |
| :--- | :--- |
| **Data Warehouse** | Google Cloud BigQuery |
| **Transformation & Modeling** | dbt Core (`dbt-bigquery`) |
| **SQL Dialect** | Standard SQL / T-SQL |
| **Data Ingestion** | dbt Seeds (Native CSV Loaders) |
| **Version Control** | Git & GitHub |

---

## ☁️ Google BigQuery GCP Setup

Before running dbt commands, set up your Google Cloud Platform (GCP) environment and authenticate locally:

### 1. Create GCP Project & Dataset

- Log in to the [Google Cloud Console](https://console.cloud.google.com/).
- Create a new GCP project (e.g., `neo-analytics-508618`).
- Navigate to **BigQuery** and click **Create Dataset**. Set the **Dataset ID** to `neoanalyticsdb` and **Data location** to `US`.

### 2. Install Google Cloud SDK & Authenticate

- Download and install the [Google Cloud SDK](https://cloud.google.com/sdk).
- Open your terminal inside your active Python virtual environment and run:

  ```bash
  gcloud auth application-default login
  ```

- Complete the OAuth browser prompt to authenticate your local machine.

### 3. Configure Local Profile (`~/.dbt/profiles.yml`)

- Create or open your local dbt profile at `~/.dbt/profiles.yml` (or `%USERPROFILE%\.dbt\profiles.yml` on Windows).
- Add the `neo_analytics` connection configuration:

  ```yaml
  neo_analytics:
    target: dev
    outputs:
      dev:
        type: bigquery
        method: oauth                  # Authenticates using gcloud ADC
        project: neo-analytics-508618  # Your GCP Project ID
        dataset: neoanalyticsdb        # Target BigQuery Dataset ID
        threads: 4
        location: US                   # BigQuery location region
  ```

---

## 📂 Project Structure

```text
Neo_Analytics/
├── analyses/
├── data/
├── docs/                          # Project documentation and metric definitions
│   └── metrics.sql                # Production SQL logic for core business metrics
├── logs/                          # Execution and dbt log outputs
├── macros/                        # Reusable SQL macros and utility logging scripts
│   ├── .gitkeep
│   ├── grant_select.sql
│   └── log_tests_results.sql
├── models/
│   ├── marts/
│   │   ├── fct_payments.sql
│   │   └── merchant_performance.sql
│   ├── staging/
│   │   ├── stg_fee_plans.sql
│   │   ├── stg_merchants.sql
│   │   ├── stg_refunds.sql
│   │   └── stg_transactions.sql
│   └── schema.yml                 # Generic test assertions & column-level documentation
├── seeds/                         # Raw CSV seeds loaded via dbt
│   ├── .gitkeep
│   ├── fee_plans.csv              # 4 fee structures
│   ├── merchants.csv              # 10 merchant records
│   ├── refunds.csv                # ~3,500 refund transaction records
│   └── transactions.csv           # 50,000 core payment attempts
├── snapshots/
├── tests/                         # Singular SQL custom tests & assertion rules
│   ├── .gitkeep
│   ├── assert_fx_fee.sql
│   ├── assert_no_refunds_on_failed_transactions.sql
│   ├── assert_refund_date_after_transaction_date.sql
│   ├── authorization_rate_bounds.sql
│   ├── cumulative_payment_refund_bounds.sql
│   └── monthly_fee_cap.sql
├── .gitignore                     # Local environment exclusion rules
├── dbt_project.yml                # Main dbt configuration and schema settings
├── README.md                      # Repository documentation & project brief
└── requirements.txt               # Python dependencies (dbt-core, adapters)
```

---

## 📐 Data Architecture & Modeling (Medallion Pattern)

### 1. Seed / Raw Layer (`seeds/`)

Raw CSV files (`fee_plans.csv`, `merchants.csv`, `refunds.csv`, `transactions.csv`) are ingested directly into the target database using `dbt seed`.

### 2. Staging Layer (`models/staging/` — Materialized as Views)

The staging layer transforms raw source data into clean, standardized views:

- **Type Casting & Precision:** Enforces exact data types across key identifiers (`transaction_id`, `merchant_id`) and converts monetary fields into explicit numeric types to prevent floating-point rounding issues.
- **Timestamp Parsing:** Standardizes datetime strings into proper database `TIMESTAMP` objects.
- **Field Standardization:** Harmonizes field naming conventions (`fixed_fee_cad` → `flat_fee_cad`), normalizes casing (`LOWER(status)`), and handles missing values via `COALESCE`.

### 3. Marts Layer (`models/marts/` — Materialized as Tables)

- **`fct_payments`** — Transaction-grain fact table built on completed transactions. Calculates payment processing fees, FX markup, net CAD volume, and associated refund metrics.
- **`merchant_performance`** — Monthly aggregate reporting table summarizing volume, revenues, fee earnings, authorization rates, and refund counts per merchant.

---

## 📊 Core Business Metrics (`docs/metrics.sql`)

All 6 core business metrics are defined and queryable in `docs/metrics.sql`:

| Metric | Business Definition | Calculation Logic |
| :--- | :--- | :--- |
| **Gross Merchandise Volume (GMV)** | Total completed payment volume in CAD | `SUM(amount_cad) WHERE status = 'completed'` |
| **Net Revenue** | Total GMV minus processed refund amounts | `GMV - SUM(total_refunded_cad)` |
| **Refund Rate** | Percentage of completed transactions that were refunded | `COUNT(refunds) / COUNT(completed_transactions)` |
| **Average Transaction Value (ATV)** | Average order value per completed transaction | `GMV / COUNT(completed_transactions)` |
| **Authorization Rate** | System approval rate across all payment attempts | `COUNT(completed) / (COUNT(completed) + COUNT(failed))` |
| **Take Rate** | Platform fee capture efficiency relative to GMV | `SUM(total_fees_cad) / GMV` |

---

## 🧪 Data Quality & Custom Test Suite (`tests/`)

The pipeline executes automated generic schema tests (defined in `models/schema.yml`) and 6 custom singular SQL business logic assertions:

1. **`assert_fx_fee.sql`** — Validates foreign exchange fee calculations on non-CAD transactions.
2. **`assert_no_refunds_on_failed_transactions.sql`** — Confirms no refund records are associated with failed transaction attempts.
3. **`assert_refund_date_after_transaction_date.sql`** — Ensures refund timestamps occur after original transaction creation dates.
4. **`authorization_rate_bounds.sql`** — Verifies authorization rates stay within 0% to 100% boundaries.
5. **`cumulative_payment_refund_bounds.sql`** — Asserts cumulative refund amounts do not exceed initial transaction values.
6. **`monthly_fee_cap.sql`** — Validates monthly tier caps on fee structures.

---

## 🧩 Custom dbt Macros (`macros/`)

This repository contains custom Jinja/SQL macros in the `macros/` directory to handle database permissions, access governance, and dynamic audit logging in Google Cloud BigQuery.

### 1. `log_test_results.sql` (Automated Test Audit Logging)

An on-run-end hook macro that captures execution metadata across generic schema assertions and singular custom SQL tests, automatically logging audit records directly into a dedicated BigQuery dataset.

**Functionality:**

- Filters execution results specifically for node resource types matching `test`.
- Dynamically targets the destination database (`{{ target.project }}`) and dataset (`{{ target.schema }}_dbt_test_audit`) based on the active target profile.
- Automatically constructs the target table `audit_test_history` if it does not already exist.
- Inserts execution records capturing `test_name`, `model_tested`, `status` (pass/fail/warn), `execution_time_seconds`, `failures_detected`, `test_type`, and `executed_at` timestamps.

**Project Configuration (`dbt_project.yml`)** — triggered automatically upon test suite execution:

```yaml
on-run-end:
  - "{{ log_test_results(results) }}"
```

### 2. `grant_select.sql` (Database Access Control & Governance)

An operational macro that automates schema-level permissions and access control for downstream users and teams.

**How It Works:**

- **Default Values:** Uses the active target schema (`target.schema`) and defaults to BigQuery's `roles/bigquery.dataViewer` role.
- **Automated DDL:** Constructs and executes dynamic SQL `GRANT` statements to give read-only viewer privileges to `analytics-team@example.com` without requiring manual GCP console updates.

**CLI Execution Commands:**

Default execution (grants viewer access on current target schema):

```bash
dbt run-operation grant_select
```

Passing dynamic arguments (override target dataset or role):

```bash
dbt run-operation grant_select --args "{schema: 'neoanalyticsdb', role: 'roles/bigquery.dataViewer'}"
```
