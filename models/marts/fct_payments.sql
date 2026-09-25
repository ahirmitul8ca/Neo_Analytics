with transaction as (
    select * from {{ ref('stg_transactions') }}
),

merchant as (
    select * from {{ ref('stg_merchants') }}
),

fee_plan as (
    select * from {{ ref('stg_fee_plans') }}
),

aggregated_refunds as (
    select
    transaction_id,
    sum(refund_amount_cad) as total_refunded_cad,
    count(refund_id) as total_refund_count
    from {{ ref('stg_refunds') }}
    group by transaction_id

)

select 

    t.transaction_id,
    t.merchant_id,
    t.created_at,
    t.amount_cad,
    t.currency,
    coalesce(r.total_refunded_cad, 0) as total_refunded_cad,
    (t.amount_cad - coalesce(r.total_refunded_cad, 0)) as net_amount_cad,

    (t.amount_cad * (fp.base_rate_pct / 100.0))+ fp.flat_fee_cad as base_fee_cad,
    case 
        when t.currency != 'CAD' then (t.amount_cad * (fp.fx_markup_pct / 100.0))
        else 0.00
    end as fx_fee_cad,
        ((t.amount_cad * (fp.base_rate_pct / 100.0)) + fp.flat_fee_cad) + 
        (case when t.currency != 'CAD' then (t.amount_cad * (fp.fx_markup_pct / 100.0)) else 0.00 end) as total_fee_cad


from transaction t
join merchant m on t.merchant_id = m.merchant_id
join fee_plan fp on m.plan_id = fp.plan_id
left join aggregated_refunds r on t.transaction_id = r.transaction_id
where t.status = 'completed'
