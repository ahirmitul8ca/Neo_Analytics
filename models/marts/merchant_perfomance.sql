with merchants as (
    select * 
    from {{ ref('stg_merchants') }}
),
transactions as (
    select * 
    from {{ ref('stg_transactions') }}
),
payment as (
    select * 
    from {{ ref('fct_payments') }}
)

select
    m.merchant_id,
    m.merchant_name,
    date_trunc(date(t.created_at), month) as performance_month,

    sum( case when t.status = 'completed' then t.amount_cad else 0 end ) as gmc_cad,
    sum(p.net_amount_cad) as net_revenue_cad,
    sum(p.total_fee_cad) as total_fee_cad,
    count(distinct case when t.status = 'completed' then t.transaction_id end) as completed_tx_count,
    count(distinct case when  t.status = 'failed' then t.transaction_id end) as failed_tx_count, 

    safe_divide(
        count(distinct case when t.status = 'completed' then t.transaction_id end),
        count(distinct t.transaction_id)
    ) as authorization_rate,

    safe_divide(
        sum(p.total_fee_cad),
        sum(case when t.status = 'completed' then t.amount_cad else 0 end)
    ) as take_rate





from  merchants m 
left join transactions t on m.merchant_id = t.merchant_id
left join payment p on m.merchant_id = p.merchant_id
group by 1,2,3
