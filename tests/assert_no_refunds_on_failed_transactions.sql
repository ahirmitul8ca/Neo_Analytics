select 
    r.refund_id,
    r.transaction_id,
    t.status as refund_status,

from {{ref('stg_refunds')}} r
join {{ref('stg_transactions')}} t
 on r.transaction_id = t.transaction_id

 where t.status != 'completed'
 