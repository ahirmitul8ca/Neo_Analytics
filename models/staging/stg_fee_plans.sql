with raw_fee_plans as (
    select * from {{ ref('fee_plans') }}
)
select
    cast(fee_plan_id as varchar(50)) as fee_plan_id,
    cast(plan_name as varchar(50)) as plan_name,
    cast(base_rate_pct as float) as base_rate_pct,
    cast(fixed_fee_cad as numeric(18,2)) as fixed_fee_cad,
    cast(fx_markup_pct as float) as fx_markup_pct,
    cast(monthly_cap_cad as numeric(18,2)) as monthly_cap_cad
from raw_fee_plans