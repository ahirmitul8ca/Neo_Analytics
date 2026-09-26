

select
    merchant_id,
    performance_month,
    authorization_rate

from {{ref('merchant_perfomance')}} mf
where mf.authorization_rate < 0.0
or mf.authorization_rate > 1.0
