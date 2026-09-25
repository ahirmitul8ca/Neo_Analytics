with source as (
    select * from {{ ref('fee_plans') }}
),

renamed as (
    select
        cast(fee_plan_id as string) as plan_id,
        cast(plan_name as string) as plan_name,
        cast(base_rate_pct as numeric) as base_rate_pct,
        cast(fixed_fee_cad as numeric) as flat_fee_cad,
        cast(fx_markup_pct as numeric) as fx_markup_pct,
        cast(monthly_cap_cad as numeric) as monthly_cap_cad
    from source
)

select * from renamed