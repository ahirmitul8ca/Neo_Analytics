with raw_transactions as (
    select * from {{ ref('transactions') }}
)
select
    cast(transaction_id as varchar(50)) as transaction_id,
    cast(merchant_id as varchar(50)) as merchant_id,
    cast(amount as numeric(18,2)) as amount,
    upper(cast(currency as varchar(10))) as currency,
    cast(amount_cad as numeric(18,2)) as amount_cad,
    cast(created_at as datetime2) as created_at,
    lower(cast(status as varchar(20))) as status,
    cast(is_retry as bit) as is_retry,
    coalesce(cast(card_last4 as varchar(4)), 'N/A') as card_last4
from raw_transactions