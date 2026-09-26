-- Returns failing rows if a merchant's total fees in a month exceed their monthly cap

with monthly_merchant_fee as (

    select 
    p.merchant_id,
    date_trunc(date(p.created_at),month) as fee_month,
    sum(p.total_fee_cad) as total_fees_charged
    from {{ref('fct_payments') }} p
    group by 1,2
) 


select 
    f.merchant_id,
    f.fee_month,
    f.total_fees_charged,
    fp.monthly_cap_cad
from monthly_merchant_fee f

join {{ref ('stg_merchants')}} m
    on f.merchant_id=m.merchant_id
join  {{ref('stg_fee_plans')}} fp
on m.plan_id = fp.plan_id

where fp.monthly_cap_cad is not null
    and f.total_fees_charged > fp.monthly_cap_cad


