select
    p.transaction_id,
    p.currency,
    p.fx_fee_cad
    from    {{ ref ('fct_payments') }} p
    where (currency = 'CAD' and fx_fee_cad>0) 
    or (currency != 'CAD' and fx_fee_cad <=0)