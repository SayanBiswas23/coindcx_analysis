---funnel
WITH funnel_base AS (
    SELECT 
        u.acquisition_channel,
        COUNT(DISTINCT u.user_id) AS signups,
        COUNT(DISTINCT CASE WHEN u.kyc_status = 'APPROVED' THEN u.user_id END) AS kyc_done,
        COUNT(DISTINCT CASE WHEN f.status = 'SUCCESS' THEN u.user_id END) AS funded,
        COUNT(DISTINCT t.buyer_user_id) AS traded
    FROM users u
    LEFT JOIN fiat_transactions f ON u.user_id = f.user_id AND f.type = 'DEPOSIT'
    LEFT JOIN trades t ON u.user_id = t.buyer_user_id
    GROUP BY u.acquisition_channel
)
SELECT 
    acquisition_channel,
    signups,
    ROUND((signups - kyc_done) * 100.0 / signups, 2) AS kyc_drop_rate_pct,
    ROUND((kyc_done - funded) * 100.0 / NULLIF(kyc_done, 0), 2) AS funding_drop_rate_pct,
    ROUND((funded - traded) * 100.0 / NULLIF(funded, 0), 2) AS trade_drop_rate_pct,
    ROUND(traded * 100.0 / signups, 2) AS overall_conversion_pct
FROM funnel_base
ORDER BY overall_conversion_pct DESC;

----cust-pct
SELECT 
	acquisition_channel,
	count(user_id) as total_custs,
	ROUND(
        100.0 * COUNT(user_id) / SUM(COUNT(user_id)) OVER (), 
        2
    ) AS pct_of_customers
FROM public.users
group by
	acquisition_channel
order by 
	3 desc;
----
WITH funnel_stages AS (
    SELECT
        COUNT(DISTINCT u.user_id) AS total_signups,
        COUNT(DISTINCT CASE WHEN u.kyc_status = 'APPROVED' THEN u.user_id END) AS kyc_approved,
        COUNT(DISTINCT CASE WHEN ft.status = 'SUCCESS' THEN ft.user_id END) AS funded_users,
        COUNT(DISTINCT t.trader_id) AS active_traders
    FROM users u
    LEFT JOIN fiat_transactions ft 
        ON u.user_id = ft.user_id 
       AND ft.status = 'SUCCESS'
    LEFT JOIN (
        SELECT buyer_user_id AS trader_id FROM trades
        UNION
        SELECT seller_user_id AS trader_id FROM trades
    ) t ON u.user_id = t.trader_id
),
unpivoted_funnel AS (
    SELECT 1 AS stage_order, '1. Total Signups' AS stage_name, total_signups AS user_count FROM funnel_stages
    UNION ALL
    SELECT 2, '2. KYC Approved', kyc_approved FROM funnel_stages
    UNION ALL
    SELECT 3, '3. First INR Deposit', funded_users FROM funnel_stages
    UNION ALL
    SELECT 4, '4. First Trade Executed', active_traders FROM funnel_stages
)
SELECT
    stage_order,
    stage_name,
    user_count,
    ROUND(100.0 * user_count / FIRST_VALUE(user_count) OVER (ORDER BY stage_order), 2) AS overall_conversion_pct,
    ROUND(
        100.0 * (1.0 - (user_count::NUMERIC / NULLIF(LAG(user_count) OVER (ORDER BY stage_order), 0))),
        2
    ) AS stage_dropoff_pct
FROM unpivoted_funnel
ORDER BY stage_order;
----------------------------
WITH user_milestones AS (
    SELECT
        u.user_id,
        u.signup_timestamp,
        u.kyc_completed_at,
        MIN(ft.created_at) AS first_deposit_at,
        MIN(t.executed_at) AS first_trade_at
    FROM users u
    LEFT JOIN fiat_transactions ft 
        ON u.user_id = ft.user_id 
        AND ft.status = 'SUCCESS'
    LEFT JOIN (
        SELECT buyer_user_id AS trader_id, executed_at FROM trades
        UNION ALL
        SELECT seller_user_id AS trader_id, executed_at FROM trades
    ) t ON u.user_id = t.trader_id
    WHERE u.kyc_status = 'APPROVED'
    GROUP BY u.user_id, u.signup_timestamp, u.kyc_completed_at
),
latency_intervals AS (
    SELECT
        user_id,
        -- Signup to KYC (Hours)
        EXTRACT(EPOCH FROM (kyc_completed_at - signup_timestamp)) / 3600.0 AS signup_to_kyc_hrs,
        -- KYC to First Deposit (TTFD in Hours)
        EXTRACT(EPOCH FROM (first_deposit_at - kyc_completed_at)) / 3600.0 AS kyc_to_deposit_hrs,
        -- First Deposit to First Trade (TTFT in Hours)
        EXTRACT(EPOCH FROM (first_trade_at - first_deposit_at)) / 3600.0 AS deposit_to_trade_hrs
    FROM user_milestones
)
SELECT
    'Signup -> KYC Approval' AS funnel_step,
    COUNT(signup_to_kyc_hrs) AS sample_size,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY signup_to_kyc_hrs)::NUMERIC, 2) AS median_latency_hrs,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY signup_to_kyc_hrs)::NUMERIC, 2) AS p90_latency_hrs
FROM latency_intervals
WHERE signup_to_kyc_hrs >= 0

UNION ALL

SELECT
    'KYC Approval -> First Deposit (TTFD)',
    COUNT(kyc_to_deposit_hrs),
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY kyc_to_deposit_hrs)::NUMERIC, 2),
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY kyc_to_deposit_hrs)::NUMERIC, 2)
FROM latency_intervals
WHERE kyc_to_deposit_hrs >= 0

UNION ALL

SELECT
    'First Deposit -> First Trade (TTFT)',
    COUNT(deposit_to_trade_hrs),
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY deposit_to_trade_hrs)::NUMERIC, 2),
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY deposit_to_trade_hrs)::NUMERIC, 2)
FROM latency_intervals
WHERE deposit_to_trade_hrs >= 0;
-------------------------
--cohort retention month
WITH user_first_month AS (
    SELECT 
        buyer_user_id AS user_id,
        TO_CHAR(MIN(executed_at::timestamp), 'YYYY-MM') AS cohort_month
    FROM trades
    GROUP BY buyer_user_id
),
user_activity AS (
    SELECT DISTINCT 
        buyer_user_id AS user_id,
        TO_CHAR(executed_at::timestamp, 'YYYY-MM') AS active_month
    FROM trades
)
SELECT 
   TO_CHAR(TO_DATE(cohort_month, 'YYYY-MM'), 'Month YYYY') AS cohort_month,
   TO_CHAR(TO_DATE(active_month, 'YYYY-MM'), 'Month YYYY') AS active_month,
    -- a.active_month,
    COUNT(DISTINCT a.user_id) AS active_traders
FROM user_first_month c
JOIN user_activity a ON c.user_id = a.user_id
WHERE a.active_month >= c.cohort_month
GROUP BY c.cohort_month, a.active_month
ORDER BY c.cohort_month, a.active_month;
-------------------------------------------Track payment failure rates to isolate infrastructure bottlenecks before they impact trade volume.

SELECT 
	count(case when status = 'SUCCESS' then 1 end) as succss_txn,
	count(case when status = 'FAILED' then 1 end) as failed_txn,
	round(
		count(case when status='FAILED' then 1 end) * 100.00/ count(transaction_id)
	,2) AS faild_txn_pct,
	round(
		count(case when status='SUCCESS' then 1 end) * 100.00/ count(transaction_id)
	,2) as Success_txn_pct,
	ROUND(SUM(CASE WHEN status = 'SUCCESS' THEN amount_inr ELSE 0 END)::numeric, 2) AS successful_volume_inr,
    ROUND(SUM(CASE WHEN status = 'FAILED' THEN amount_inr ELSE 0 END)::numeric, 2) AS lost_volume_inr
FROM public.fiat_transactions;
-----------------------------------Asset Liquidity & Platform Fee Contribution (Financial Analytics)
SELECT
	market_pair,
	round(sum(maker_fee_inr + taker_fee_inr)::numeric,2) as platform_fee_inr,
	round(sum(volume_inr)::numeric ,2)as volume_inr,
	round(avg(volume_inr)::numeric,2) as avg_volume,
	round(
		sum((maker_fee_inr + taker_fee_inr)::numeric) * 100 /
		sum(sum((maker_fee_inr + taker_fee_inr)::numeric)) over()	
	,2) as revenue_pct_share
FROM
	public.trades
group by
	market_pair
order by 
	volume_inr desc;

	------------------------------------
--	Whale Concentration & Revenue Risk (Pareto Analysis)
with trade_volume as (
select
	trader_id,
	sum(volume_inr) as user_volume_inr,
	ntile(100) over(order by sum(volume_inr) desc) as percentile_tier
from(
	select buyer_user_id as trader_id,volume_inr from trades
	union all
	select seller_user_id as trader_id,volume_inr from trades
) t
group by
	trader_id
)
select
	case 
		when percentile_tier = 1 then 'Top 1%(Whales)'
		when percentile_tier <= 5 then 'Top 2-5%(High Net Worth)'
		when percentile_tier <= 20 then 'Top 6-20%(Active)'
	else 'Remaining 80% (Retails)'
	end as user_segmentation,
	count(trader_id) as trader_count,
	ROUND(SUM(user_volume_inr)::NUMERIC, 2) AS total_volume_inr,
	Round((
		100.0 * sum(user_volume_inr) / sum(sum(user_volume_inr)) over())::numeric
	,2) as user_volume_pct
from
	trade_volume
group by
	1
order by
	total_volume_inr desc;
------7 day rolling avg of traders and trade volume
WITH daily_metrics AS (
    SELECT
        (executed_at::TIMESTAMP)::DATE AS trade_date,
        COUNT(DISTINCT buyer_user_id) AS daily_active_users,
        SUM(volume_inr) AS daily_trade_volume
    FROM trades
    GROUP BY 1 
)
SELECT 	
    trade_date,
    ROUND(daily_trade_volume::NUMERIC, 2) AS daily_trade_volume,
    daily_active_users,
    ROUND(
        AVG(daily_trade_volume) OVER (
            ORDER BY trade_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 
        2
    ) AS rolling_7_day_avg_volume,
    ROUND(
        AVG(daily_active_users) OVER (
            ORDER BY trade_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 
        1
    ) AS avg_7_day_active_buyers
FROM daily_metrics
ORDER BY trade_date ASC;

-----------------
--Bridging Live API Data with Execution Quality (Slippage)
-------------------------
WITH latest_ticker_price AS (
    SELECT DISTINCT ON (market)
        market,
        last_price AS benchmark_price,
        fetched_at::TIMESTAMP AS benchmark_time
    FROM live_ticker_prices
    ORDER BY market, fetched_at::TIMESTAMP DESC
)
SELECT 
    t.market_pair,
    COUNT(t.trade_id) AS analyzed_trades,
    ROUND(AVG(t.execution_price)::NUMERIC, 2) AS avg_execution_price,
    ROUND(AVG(p.benchmark_price)::NUMERIC, 2) AS benchmark_price,
    ROUND(AVG(ABS(t.execution_price - p.benchmark_price) * 100.0 / p.benchmark_price)::NUMERIC, 3) AS avg_slippage_pct,
    ROUND(MAX(ABS(t.execution_price - p.benchmark_price) * 100.0 / p.benchmark_price)::NUMERIC, 3) AS max_slippage_pct
FROM trades t
JOIN latest_ticker_price p 
  ON t.market_pair = p.market
GROUP BY t.market_pair
ORDER BY avg_slippage_pct DESC;