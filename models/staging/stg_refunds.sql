with source as (
    select * from {{ ref('refunds') }}
),

renamed as (
    select
        cast(refund_id as string) as refund_id,
        cast(transaction_id as string) as transaction_id,
        cast(merchant_id as string) as merchant_id,
        cast(created_at as timestamp) as refunded_at,
        cast(refund_amount_cad as numeric) as refund_amount_cad,
        cast(same_day_refund as bool) as same_day_refund
    from source
)

select * from renamed