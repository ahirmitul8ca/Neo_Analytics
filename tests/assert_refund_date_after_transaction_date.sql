select 
    r.refund_id,
    r.refunded_at as refund_created_at,
    t.created_at as tx_created_at, 
    from {{ref('stg_refunds')}} r
    join {{ref('stg_transactions')}} t
    on r.transaction_id = t.transaction_id
    where r.refunded_at < t.created_at


    