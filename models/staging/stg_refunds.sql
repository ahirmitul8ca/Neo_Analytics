with raw_refunds as (
    select * from {{ ref('refunds') }}
)
select
    cast(refund_id as varchar(50)) as refund_id,
    cast(transaction_id as varchar(50)) as transaction_id,
    cast(refund_amount_cad as numeric(18,2)) as refund_amount_cad,
    cast(refunded_at as datetime2) as refunded_at,
    cast(is_same_day as bit) as is_same_day
from raw_refunds