with merchants as (
    select * 
    from {{ ref('stg_merchants') }}
),


monthly_transactions as (
    select
        merchant_id,
        date_trunc(date(created_at), month) as performance_month,
        sum(case when status = 'completed' then amount_cad else 0 end) as gmc_cad,
        count(distinct case when status = 'completed' then transaction_id end) as completed_tx_count,
        count(distinct case when status = 'failed' then transaction_id end) as failed_tx_count,
        count(distinct transaction_id) as total_tx_count
    from {{ ref('stg_transactions') }}
    group by 1, 2
),

monthly_payments as (
    select
        merchant_id,
        date_trunc(date(created_at), month) as performance_month,
        sum(total_fee_cad) as total_fee_cad,
        sum(net_amount_cad) as total_net_payout_cad
    from {{ ref('fct_payments') }}
    group by 1, 2
)


select
    m.merchant_id,
    m.merchant_name,
    t.performance_month,

    coalesce(t.gmc_cad, 0) as gmc_cad,
    -- Net revenue retained by platform is total fees earned
    coalesce(p.total_fee_cad, 0) as net_revenue_cad,
    coalesce(p.total_fee_cad, 0) as total_fee_cad,
    
    coalesce(t.completed_tx_count, 0) as completed_tx_count,
    coalesce(t.failed_tx_count, 0) as failed_tx_count, 

    safe_divide(
        t.completed_tx_count,
        t.total_tx_count
    ) as authorization_rate,

    safe_divide(
        p.total_fee_cad,
        t.gmc_cad
    ) as take_rate

from merchants m 
inner join monthly_transactions t 
    on m.merchant_id = t.merchant_id
left join monthly_payments p 
    on t.merchant_id = p.merchant_id 
   and t.performance_month = p.performance_month