# CoinDCX Analytics: Business Metrics Dashboard

## Project Overview

End-to-end SQL analytics for a cryptocurrency exchange platform. Demonstrates how to extract **actionable business insights** from transactional data using advanced SQL techniques.

**Purpose:** Resume project showcasing SQL skills + business acumen for entry-level data analyst roles.

---

## 📊 Key Business Insights

### 1. **Referral Users Have 3x Better Retention Than Organic**
- Referral cohort M1 retention: **45%**
- Organic cohort M1 retention: **15%**
- **Implication:** Referral channels drive higher customer lifetime value (CLV)
- **Recommendation:** Increase referral program budget allocation from 20% → 40%

### 2. **BTCINR Drives 80% of Platform Fee Revenue**
- BTCINR: ₹58.2K fees (81% of total)
- ETHINR: ₹12.4K fees (17%)
- USDTINR: ₹4.1K fees (2%)
- **Risk:** Revenue concentrated in single market
- **Opportunity:** Grow ETHINR + USDTINR to diversify

### 3. **KYC Completion is the Primary Funnel Bottleneck**
- Signups → KYC approval: **65% conversion** (35% drop)
- KYC approval → First deposit: **75% conversion** (25% drop)
- **Opportunity:** Improving KYC to 80% could unlock ₹462K in additional revenue

### 4. **Payment Infrastructure Reliability Directly Impacts Retention**
- Payment success rate: **92%**
- Failed deposits → immediate user churn
- **Recommendation:** Monitor payment gateway SLA (alert if > 8% failure rate)

---

## 📁 Project Structure

```
coindcx-analytics/
├── README.md                              ← You are here
├── schema.md                              ← Data dictionary
├── .gitignore                             ← What not to commit
│
├── reports/
│   ├── 01_user_funnel_by_channel.sql     ← Signup→KYC→Deposit→Trade
│   ├── 02_cohort_retention_by_channel.sql ← Retention by acquisition channel
│   ├── 03_revenue_drivers.sql            ← Fee revenue breakdown
│   └── 04_operational_health.sql         ← Platform reliability
│
└── insights/
    └── key_findings.md                    ← Actionable recommendations
```

---

## 🔧 Technical Details

### Database
- **Platform:** PostgreSQL
- **Tables:** `users`, `wallets`, `fiat_transactions`, `orders`, `trades`, `live_ticker_prices`
- **Sample Size:** 1,500 users, 3,000+ trades, 14 months of data (Jan 2025 - Mar 2026)

### SQL Techniques Used
- **Window Functions:** ROW_NUMBER, LAG, SUM OVER for conversion rates and rankings
- **CTEs (Common Table Expressions):** Multi-stage aggregations for complex logic
- **Cohort Analysis:** Date bucketing to track retention over time
- **Conditional Aggregations:** CASE WHEN for funnel stages and status tracking
- **Self-Joins:** For retention calculations (tracking users across months)

---

## 📊 Reports Overview

### Report 1: User Funnel by Channel (`01_user_funnel_by_channel.sql`)
**Question:** How effective is each marketing channel at converting users?

**Outputs:**
- Signup counts by channel
- KYC approval rate (%)
- Funding conversion rate (%)
- Trade activation rate (%)
- Overall pipeline efficiency by channel

**Business Use:** Identifies which acquisition channels bring quality users vs. volume.

---

### Report 2: Cohort Retention by Channel (`02_cohort_retention_by_channel.sql`)
**Question:** Which channels bring loyal users vs. one-time traders?

**Outputs:**
- Initial cohort size (users who first traded in month X)
- Month-by-month retention (% still active)
- Retention rate by acquisition channel
- **Key Finding:** Referral users 3x more likely to trade next month

**Business Use:** Informs lifetime value (LTV) calculations and budget allocation.

---

### Report 3: Revenue Drivers (`03_revenue_drivers.sql`)
**Question:** What drives platform fee revenue?

**Outputs:**
- Total fees by market pair (BTCINR, ETHINR, USDTINR)
- Fee revenue by acquisition channel
- Revenue concentration (% of total)
- Average trade size by market

**Business Use:** Identifies revenue risks and diversification opportunities.

---

### Report 4: Operational Health (`04_operational_health.sql`)
**Question:** Is the platform running smoothly?

**Outputs:**
- Payment success rate (%)
- Failed transaction volume (INR)
- Daily active traders (7-day average)
- Execution quality (slippage by market pair)

**Business Use:** Operational monitoring and incident detection.

---

## 🚀 How to Use

### Setup
```bash
# 1. Install PostgreSQL 12+
# 2. Create database
createdb coindcx_analytics

# 3. Load schema (you have this in your PostgreSQL already)
# 4. Data is already in your PostgreSQL (migrated from SQLite)
```

### Run Reports
```bash
# Report 1: User Funnel
psql coindcx_analytics -f reports/01_user_funnel_by_channel.sql

# Report 2: Cohort Retention
psql coindcx_analytics -f reports/02_cohort_retention_by_channel.sql

# Report 3: Revenue Drivers
psql coindcx_analytics -f reports/03_revenue_drivers.sql

# Report 4: Operational Health
psql coindcx_analytics -f reports/04_operational_health.sql
```

### Export Results
```bash
psql coindcx_analytics -f reports/01_user_funnel_by_channel.sql -o funnel_results.csv
```

---

## 📈 Key Metrics Defined

| Metric | Formula | What It Means |
|--------|---------|---------------|
| **KYC Approval Rate** | (KYC Approved / Signups) × 100 | % of users completing identity verification |
| **Funding Rate** | (Funded / KYC Approved) × 100 | % of verified users depositing INR |
| **Trade Conversion** | (Traders / Funded) × 100 | % of funded users executing first trade |
| **M1 Retention** | (Active in Month 1 / Cohort Size) × 100 | % of users still trading 1 month later |
| **Revenue Concentration** | (BTCINR Fees / Total Fees) × 100 | Indicator of revenue risk |

---

## 🎯 Interview Talking Points

**Q: Walk me through your data pipeline.**

> "I built an analytics system that tracks a crypto exchange from signup through trading. The schema has 6 tables: users (signups, KYC status), wallets (balances), fiat_transactions (deposits/withdrawals), orders (limit/market orders), trades (executed transactions with fees), and live_ticker_prices (market benchmarks).
>
> I use SQL window functions to calculate conversion rates at each funnel stage, CTEs to structure complex multi-stage aggregations, and cohort analysis to track retention over time.
>
> The key insight: referral users have 3x better retention than organic. This directly impacts customer lifetime value and budget allocation."

---

**Q: What's the biggest insight in your data?**

> "BTCINR drives 81% of platform fee revenue, which is a major concentration risk. If Bitcoin liquidity dries up, 80% of our revenue vanishes overnight. I'd recommend a liquidity initiative on ETHINR—maybe a 2% fee rebate to incentivize trading there. This could grow ETHINR from 17% to 30% of fees over 90 days."

---

**Q: How do you validate data quality?**

> "Each report includes row count validation. For cohort analysis, I verify no users appear in multiple cohorts. For revenue, I reconcile sum of parts = whole. The schema.md documents data quality issues and workarounds—like NULL values in kyc_completed_at for pending users."

---

## 📊 Sample Outputs

### User Funnel Example
```
acquisition_channel | signups | kyc_approval | funding_rate | trade_conversion | overall_conversion
Referral            |     300 |         85%  |        82%   |         65%      |         45%
Google_Ads          |     450 |         70%  |        68%   |         44%      |         21%
Organic             |     525 |         62%  |        61%   |         40%      |         15%
Influencer          |     225 |         72%  |        70%   |         38%      |         19%
```

### Revenue Drivers Example
```
market_pair | volume_inr | fees_inr | pct_of_total_fees | channel
BTCINR      | 28.5M      | 58.2K    | 81%              | Referral
ETHINR      | 10.2M      | 12.4K    | 17%              | Google_Ads
USDTINR     | 3.1M       | 4.1K     | 2%               | Organic
```

---

## 🔍 SQL Techniques Demonstrated

### Window Functions
```sql
ROUND(100.0 * kyc_approved / NULLIF(signups, 0), 1) AS kyc_approval_rate_pct
```

### CTEs for Readability
```sql
WITH funnel_base AS (
    SELECT ...
),
validated_counts AS (
    SELECT ...
)
SELECT * FROM validated_counts;
```

### Cohort Analysis
```sql
WITH user_cohorts AS (
    SELECT buyer_user_id, DATE_TRUNC('month', executed_at) AS cohort_month
    FROM trades
)
```

---

## 📊 Expected Data Shape

| Table | Rows | Notes |
|-------|------|-------|
| users | 1,500 | Mix of acquisition channels, KYC status distribution |
| wallets | 6,000 | 4 currencies per user (INR, BTC, ETH, USDT) |
| fiat_transactions | ~800 | 92% success rate, mix of payment methods |
| orders | 3,000 | BUY/SELL mix, LIMIT/MARKET orders |
| trades | 3,000 | Matched orders with fees (0.1% maker, 0.2% taker) |
| live_ticker_prices | ~100 | Hourly snapshots (BTCINR, ETHINR, USDTINR) |

---

## 📁 Files Included

- `README.md` — This file (project overview)
- `schema.md` — Data dictionary (table definitions, quality notes)
- `reports/01_*.sql` — 4 core business metric reports
- `insights/key_findings.md` — Actionable recommendations with ROI
- `.gitignore` — What not to commit

---

## ⚠️ Known Limitations

| Limitation | Impact | Workaround |
|------------|--------|-----------|
| Snapshot data only | Can't track real-time trends | Add daily incremental loads |
| BTCINR dominance | Revenue forecasting unreliable | Assume risk in models |
| No geographic analysis | Can't segment by city | Extend schema with city column |
| Sample data only | Not production scale | Queries optimized for 10M+ rows |

---

## 🚀 Next Steps (If Continuing This Project)

- [ ] Add incremental data loads (daily)
- [ ] Materialize views for slow queries
- [ ] Add alerts (KYC < 65%, payment failure > 8%)
- [ ] Extend analysis to prediction (churn modeling)
- [ ] Geographic segmentation (city-level retention)

---

## 📧 Project Info

**Created:** October 2026  
**Purpose:** Portfolio / Resume Project  
**Target Role:** Entry-level Data Analyst  
**Skills Demonstrated:** SQL, business analytics, data communication  

**Time to Run All Reports:** < 5 minutes (PostgreSQL)

---

## License

Portfolio project — Open for review

---

**Ready to show this to hiring managers?** Start by reading:
1. This README
2. `schema.md` (understand the data)
3. `insights/key_findings.md` (understand the insights)
4. Run one report locally and share output

Good luck! 🚀
