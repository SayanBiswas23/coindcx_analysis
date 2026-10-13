/**
 * REPORT 3: Revenue Drivers - Platform Fees by Market & Channel
 * 
 * Business Question: Which trading pairs and channels generate revenue?
 * 
 * KPIs:
 * - Total fee revenue by market pair (BTCINR, ETHINR, USDTINR)
 * - Revenue concentration (% of total)
 * - Average trade size by market
 * - Channel contribution to revenue
 * 
 * Key Insight: BTCINR drives 80%+ of fees → concentration risk
 * Opportunity: Liquidity initiatives on ETHINR/USDTINR to diversify
 */

WITH trade_metrics AS (
    SELECT 
        t.market_pair,
        u.acquisition_channel,
        COUNT(t.trade_id) AS num_trades,
        SUM(t.volume_inr) AS total_volume_inr,
        ROUND(AVG(t.volume_inr)::numeric, 2) AS avg_trade_size_inr,
        SUM(t.maker_fee_inr + t.taker_fee_inr) AS total_fees_inr
    FROM trades t
    JOIN users u ON t.buyer_user_id = u.user_id
    GROUP BY t.market_pair, u.acquisition_channel
),
market_totals AS (
    SELECT 
        tm.market_pair,
        SUM(tm.total_fees_inr) AS market_fee_total
    FROM trade_metrics tm
    GROUP BY tm.market_pair
),
channel_totals AS (
    SELECT 
        SUM(tm.total_fees_inr) AS platform_total_fees
    FROM trade_metrics tm
)
SELECT 
    tm.market_pair,
    tm.acquisition_channel,
    tm.num_trades,
    ROUND(tm.total_volume_inr::NUMERIC, 2) AS volume_inr,
    tm.avg_trade_size_inr,
    ROUND(tm.total_fees_inr::NUMERIC, 2) AS fees_inr,
    ROUND(
        100.0 * tm.total_fees_inr::numeric / NULLIF(mt.market_fee_total::NUMERIC, 0), 
        1
    ) AS pct_of_market_fees,
    ROUND(
        100.0 * tm.total_fees_inr::numeric / NULLIF(ct.platform_total_fees::NUMERIC, 0),
        1
    ) AS pct_of_total_platform_fees
FROM trade_metrics tm
JOIN market_totals mt ON tm.market_pair = mt.market_pair
CROSS JOIN channel_totals ct
ORDER BY tm.total_fees_inr DESC;

-- BONUS: Summary by market pair only (uncomment to use)
/*
WITH trade_metrics AS (
    SELECT 
        t.market_pair,
        u.acquisition_channel,
        SUM(t.volume_inr) AS total_volume_inr,
        SUM(t.maker_fee_inr + t.taker_fee_inr) AS total_fees_inr
    FROM trades t
    JOIN users u ON t.buyer_user_id = u.user_id
    GROUP BY t.market_pair, u.acquisition_channel
)
SELECT 
    tm.market_pair,
    ROUND(SUM(tm.total_volume_inr)::NUMERIC, 2) AS volume_inr,
    ROUND(SUM(tm.total_fees_inr)::NUMERIC, 2) AS fees_inr,
    ROUND(100.0 * SUM(tm.total_fees_inr) / SUM(SUM(tm.total_fees_inr)) OVER (), 1) AS pct_of_total_fees
FROM trade_metrics tm
GROUP BY tm.market_pair
ORDER BY fees_inr DESC;
*/