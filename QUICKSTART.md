# Quick Start Guide

## Project Ready ✅

You now have a complete, GitHub-ready data analytics project with:

```
coindcx-analytics/
├── README.md                    ← Start here
├── schema.md                    ← Data dictionary
├── QUICKSTART.md               ← This file
├── .gitignore
├── reports/
│   ├── 01_user_funnel_by_channel.sql
│   ├── 02_cohort_retention_by_channel.sql
│   ├── 03_revenue_drivers.sql
│   └── 04_operational_health.sql
└── insights/
    └── key_findings.md
```

**Total Size:** < 100 KB (no data files included)

---

## Step 1: Copy to Your Machine

```bash
# Clone or download the project files to your local machine
# Replace /path/to with your actual location
cd /path/to/coindcx-analytics
```

---

## Step 2: Set Up Git (First Time Only)

```bash
# Initialize git repo
git init

# Add all files
git add .

# First commit
git commit -m "Initial commit: CoinDCX analytics with 4 business reports

- 01_user_funnel_by_channel: Marketing channel effectiveness
- 02_cohort_retention_by_channel: Referral 3x better retention
- 03_revenue_drivers: BTCINR concentration analysis
- 04_operational_health: Platform reliability monitoring

Key insight: Referral users have 3x better retention than organic.
BTCINR drives 81% of revenue (concentration risk).
KYC approval at 65% (opportunity: improve to 80% = ₹462K)."

# Add remote (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/coindcx-analytics.git
git branch -M main
git push -u origin main
```

---

## Step 3: Run Reports Against Your PostgreSQL

### Make sure PostgreSQL is running:
```bash
# Start PostgreSQL
brew services start postgresql
# or
sudo systemctl start postgresql

# Verify
psql postgres -c "SELECT 1;"
```

### Run each report:
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

### Export to CSV (optional):
```bash
psql coindcx_analytics -f reports/01_user_funnel_by_channel.sql -o funnel_results.csv
```

---

## Step 4: Share During Interviews

### GitHub Setup
1. Create GitHub repo: `https://github.com/YOUR_USERNAME/coindcx-analytics`
2. Push your code (follow Step 2 above)
3. Share link in your resume/portfolio

### Your Elevator Pitch (60 seconds)
> "I built an analytics dashboard for a crypto exchange using SQL. The project analyzes 1,500 users and 3,000 trades to show business metrics. Key findings: referral users have 3x better retention than organic—which drives customer lifetime value. BTCINR drives 81% of fees, creating revenue concentration risk. And KYC completion is the funnel bottleneck at 65%—fixing it could unlock ₹462K in revenue.
>
> I used SQL window functions for conversion rates, CTEs for multi-stage aggregations, and cohort analysis to track retention. Each report comes with business context and recommendations."

### Technical Talking Points
**Q: Tell me about your SQL approach.**
> "I used CTEs to break complex logic into readable stages. Window functions to calculate rates (no need for GROUP BY then JOIN). Cohort analysis with DATE_TRUNC to bucket users by first trade month. Conditional aggregations (CASE WHEN) to count users by status without multiple passes."

**Q: What's your biggest insight?**
> "Referral users have 45% month-1 retention vs. 15% for organic. That's not just a metric—it's actionable. It tells us where to invest marketing budget. We should allocate 3-4x more to referral programs than organic because CLV is 3x higher."

**Q: How would you validate this?**
> "Each report includes row count aggregations. For retention, I verify no users appear in multiple cohorts. For revenue, I reconcile: sum of parts = whole. I also documented data quality issues in schema.md—like NULL values in kyc_completed_at for pending users."

---

## What NOT to Do

❌ Don't commit:
- `.db` or `.sqlite` files (data files)
- `.pyc` or `__pycache__` (compiled Python)
- `.log` files (temporary logs)
- `.env` (secrets/credentials)

✅ Do commit:
- `.sql` files (reports)
- `.md` files (documentation)
- `.gitignore` (safety)

---

## File Purposes

| File | What It Does | When to Use |
|------|----------|-----------|
| README.md | Project overview + interview talking points | First thing you read |
| schema.md | Data dictionary (table definitions) | When you need to understand data |
| 01_*.sql | User funnel analysis | Show marketing effectiveness |
| 02_*.sql | Cohort retention analysis | Prove Referral quality |
| 03_*.sql | Revenue drivers | Show business acumen |
| 04_*.sql | Operational health | Operational awareness |
| key_findings.md | Business recommendations | When presenting to non-technical |

---

## Expected Results

### Report 1 Output (Sample)
```
acquisition_channel | signups | kyc_approval_pct | overall_conversion_pct
Referral            | 300     | 85%              | 45%
Google_Ads          | 450     | 70%              | 21%
Organic             | 525     | 62%              | 15%
Influencer          | 225     | 72%              | 19%
```

### Report 2 Output (Sample)
```
cohort_month | acquisition_channel | cohort_users | retention_pct_month_1
2025-01      | Referral            | 50           | 45%
2025-01      | Organic             | 80           | 15%
2025-02      | Referral            | 55           | 46%
2025-02      | Organic             | 95           | 16%
```

### Report 3 Output (Sample)
```
market_pair | acquisition_channel | fees_inr | pct_of_total_platform_fees
BTCINR      | Referral            | 28000    | 47%
BTCINR      | Google_Ads          | 18000    | 31%
ETHINR      | Organic             | 8000     | 14%
USDTINR     | Influencer          | 3000     | 5%
```

---

## Troubleshooting

### PostgreSQL Connection Error
```bash
# Make sure PostgreSQL is running
brew services start postgresql

# Check connection
psql postgres -c "SELECT 1;"

# If still fails, check credentials in your connection
psql -U postgres -h localhost -d coindcx_analytics
```

### SQL Syntax Error
- Check that your PostgreSQL version is 12+
- Verify table names match your schema (case-sensitive)
- Try running one report at a time to isolate issues

### Results Look Wrong
- Verify data is in PostgreSQL (SELECT COUNT(*) FROM users;)
- Check for NULL values (some reports skip NULLs)
- Refer to schema.md for data quality notes

---

## Next Steps After This Project

1. ✅ **Push to GitHub** — Share link on resume
2. ✅ **Prepare talking points** — Practice your 60-second pitch
3. ✅ **Run reports locally** — Screenshot successful output (blur credentials)
4. ✅ **Tell a story** — Every metric answers a business question
5. 🔲 **Extend analysis** — Add geographic segmentation, churn prediction
6. 🔲 **Build dashboard** — Tableau, Metabase, or Looker visualization
7. 🔲 **Add A/B testing analysis** — If you run experiments later

---

## Quick Checklist for Interviews

- [ ] Can you explain what each report does? (60 seconds each)
- [ ] Can you name 3 SQL techniques you used? (Window functions, CTEs, cohort analysis)
- [ ] Can you back up your insights with numbers? (45% vs. 15%, ₹462K opportunity)
- [ ] Can you recommend an action based on the data? (Increase referral budget)
- [ ] Can you explain your data validation approach? (Row counts, reconciliation)

---

**You're ready to go. Push to GitHub, share the link, and own the conversation.**

Good luck! 🚀
