truncate analysis.tmp_rfm_recency;
insert into analysis.tmp_rfm_recency 
WITH status AS(
    SELECT id
    FROM analysis.orderstatuses
    WHERE key = 'Closed'
)
SELECT 
    u.id AS user_id,
    NTILE(5) OVER (ORDER BY max(o.order_ts) NULLS FIRST) AS recency
FROM 
    analysis.users AS u
LEFT JOIN
    analysis.orders AS o 
        ON u.id = o.user_id
        AND o.status = (SELECT * FROM status)
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY u.id;
