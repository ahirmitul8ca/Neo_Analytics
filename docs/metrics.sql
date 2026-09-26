
-- total of all merchandise volume
select 
    sum(amount_cad) as gmv_cad
 from {{ref('stg_transactions')}}
 where status = 'completed'


 select 
    sum(net_amount_cad) as net_revenue_cad
    from {{ref('fct_payments')}}

select 
    count(distinct r.transaction_id) * 1.0 / NULLIF(COUNT(DISTINCT T.transaction_id),0) as refund rate
    
    from {{ref('stg_transactions')}} t
    left join {{('stg_refunds')}} r

        on t.transaction_id = r.transaction_id
        where t.status = 'completed'

-- average transaction value in CAD
select
    avg(amount_cad) as atv_cad
    from {{ref('stg_transaction')}} 
    where status = 'completed'

select

    countif(status = 'completed') * 1.0 / NULLIF(COUNTIF(status IN ('completed,failed')),0) as authorization_rate

    from {{ref('stg_transaction')}}


select sum(total_fee_cad) * 1.0 / NULLIF(SUM(amount_cad),0) as take_rate

from {{ref('fct_payments')}}


