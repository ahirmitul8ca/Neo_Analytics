-- Even if a single payment receives multiple partial refunds over time, 
-- the total sum of refunds for a single transaction can never exceed the original charge amount. #

select 
    t.transaction_id,
    t.amount_cad,
    sum(r.refund_amount_cad) as total_refunded_cad


from {{ ref ('stg_transactions') }} as t
join {{ ref ('stg_refunds' ) }} r
on t.transaction = r.transaction_id
group by 1,2
having sum(r.refund_amount_cad) > t.amount_cad