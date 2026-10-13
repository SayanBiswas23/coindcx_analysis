/**
 * REPORT 4: Operational Health Dashboard
 * 
 * Business Question: Is the platform running smoothly?
 * 
 * Monitored Metrics:
 * - Payment success rate (infrastructure reliability)
 * - Daily active traders (platform engagement)
 * - 7-day rolling volume (trend detection)
 * - Slippage by market (execution quality)
 * 
 * Red Flags:
 * - Payment failure > 10% indicates payment gateway issues
 * - Declining daily active traders = user churn
 * - High slippage = poor liquidity or matching issues
 */

-- METRIC 1: Payment Reliability
SELECT 
    'Payment Processing' AS metric_name,
    COUNT(CASE WHEN ft.status = 'SUCCESS' THEN 1 END) AS successful_transactions,
    COUNT(CASE WHEN ft.status = 'FAILED' THEN 1 END) AS failed_transactions,
    ROUND(
        100.0 * COUNT(CASE WHEN ft.status = 'FAILED' THEN 1 END) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN ft.status = 'SUCCESS' THEN ft.amount_inr ELSE 0 END)::NUMERIC, 2) AS successful_volume_inr,
    ROUND(SUM(CASE WHEN ft.status = 'FAILED' THEN ft.amount_inr ELSE 0 END)::NUMERIC, 2) AS lost_volume_inr
FROM fiat_transactions ft

UNION ALL

-- METRIC 2: Payment Methods Distribution
SELECT 
    'Payment Method: ' || ft.payment_method AS metric_name,
    COUNT(CASE WHEN ft.status = 'SUCCESS' THEN 1 END) AS successful_transactions,
    COUNT(CASE WHEN ft.status = 'FAILED' THEN 1 END) AS failed_transactions,
    ROUND(
        100.0 * COUNT(CASE WHEN ft.status = 'FAILED' THEN 1 END) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN ft.status = 'SUCCESS' THEN ft.amount_inr ELSE 0 END)::NUMERIC, 2),
    ROUND(SUM(CASE WHEN ft.status = 'FAILED' THEN ft.amount_inr ELSE 0 END)::NUMERIC, 2)
FROM fiat_transactions ft
GROUP BY ft.payment_method

UNION ALL

--METRIC 3: Daily Active Traders (Last 30 Days)
SELECT 
    'Daily Active Traders (30D Avg)' AS metric_name,
    ROUND(AVG(dm.daily_active_users), 0)::INT AS successful_transactions,
    0::INT AS failed_transactions,
    0.0::NUMERIC AS failure_rate_pct,
    NULL::NUMERIC AS successful_volume_inr,
    NULL::NUMERIC AS lost_volume_inr
FROM (
    SELECT 
        DATE(t.executed_at) AS trade_date,
        COUNT(DISTINCT t.buyer_user_id) AS daily_active_users
    FROM trades t
    WHERE t.executed_at >= NOW() - INTERVAL '30 days'
    GROUP BY DATE(t.executed_at)
) dm;

-- BONUS: 7-Day Rolling Average (uncomment to use)
-- WITH daily_metrics AS (
--     SELECT
--         (t.executed_at::TIMESTAMP)::DATE AS trade_date,
--         COUNT(DISTINCT t.buyer_user_id) AS daily_active_users,
--         SUM(t.volume_inr) AS daily_trade_volume
--     FROM trades t
--     GROUP BY (t.executed_at::TIMESTAMP)::DATE
-- )
-- SELECT 	
--     dm.trade_date,
--     ROUND(dm.daily_trade_volume::NUMERIC, 2) AS daily_volume_inr,
--     dm.daily_active_users,
--     ROUND(
--         AVG(dm.daily_trade_volume) OVER (
--             ORDER BY dm.trade_date 
--             ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
--         )::NUMERIC, 
--         2
--     ) AS rolling_7day_avg_volume,
--     ROUND(
--         AVG(dm.daily_active_users) OVER (
--             ORDER BY dm.trade_date 
--             ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
--         )::NUMERIC, 
--         1
--     ) AS rolling_7day_avg_dau
-- FROM daily_metrics dm
-- ORDER BY dm.trade_date DESC
-- LIMIT 30;
