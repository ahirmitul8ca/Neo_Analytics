with raw_merchants as (
    select * from {{ ref('merchants') }}
)
select
    cast(merchant_id as varchar(50)) as merchant_id,
    cast(merchant_name as varchar(100)) as merchant_name,
    cast(fee_plan_id as varchar(50)) as fee_plan_id,
    cast(status as varchar(20)) as merchant_status
from raw_merchants