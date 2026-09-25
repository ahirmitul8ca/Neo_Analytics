with source as (
    select * from {{ ref('transactions') }}
),

renamed as (
    select
        cast(transaction_id as string) as transaction_id,
        cast(merchant_id as string) as merchant_id,
        cast(customer_id as string) as customer_id,
        cast(created_at as timestamp) as created_at,
        lower(cast(status as string)) as status,
        upper(cast(currency as string)) as currency,
        cast(amount as numeric) as amount,
        cast(amount_cad as numeric) as amount_cad,
        cast(payment_method as string) as payment_method,
        coalesce(cast(card_last4 as string), 'N/A') as card_last4,
        cast(is_retry as bool) as is_retry,
        cast(description as string) as description,
        cast(processor_response_code as string) as processor_response_code
    from source
)

select * from renamed