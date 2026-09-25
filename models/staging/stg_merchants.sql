with source as (
    select * from {{ ref('merchants') }}
),

renamed as (
    select
        cast(merchant_id as string) as merchant_id,
        cast(merchant_name as string) as merchant_name,
        cast(category as string) as category,
        cast(fee_plan_id as string) as plan_id,
        lower(cast(status as string)) as status,
        cast(onboarded_date as timestamp) as created_at,
        cast(country as string) as country,
        cast(province as string) as province
    from source
)

select * from renamed