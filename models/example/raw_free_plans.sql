{{ config(materialized='table') }}

select * from read_csv_auto('data/fee_plans.csv');