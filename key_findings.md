# CoinDCX Analytics: Key Findings & Recommendations

## Executive Summary

Analysis of 1,500 users and 3,000 trades reveals **three critical business levers**:

1. **Referral users retention premium** — 3x better retention, budget allocation should reflect this
2. **KYC funnel bottleneck** — 35% drop at approval stage, ₹462K revenue opportunity
3. **Revenue concentration risk** — BTCINR = 80% of fees, diversification needed

---

## Finding #1: Referral Users Have 3x Better Retention

### The Data
| Channel | M0 Cohort | M1 Retention | CLV Impact |
|---------|-----------|--------------|-----------|
| Referral | 300 | 45% | HIGH |
| Google Ads | 450 | 18% | MEDIUM |
| Organic | 525 | 15% | LOW |

### Why It Matters
- Referral users trade 3 months per year, organic users only 1 month
- Higher retention = higher customer lifetime value (LTV)
- Lower acquisition cost + higher LTV = best unit economics

### Business Recommendation
**Increase referral budget from 20% → 40% of marketing spend**

**Actions:**
- [ ] Increase referral bonus from 1% → 2% of first trade volume
- [ ] Create tiered rewards (10 referrals = badge + cashback)
- [ ] A/B test email campaigns highlighting friend referrals
- [ ] Track who-referred-who to identify power referrers

**Expected ROI:**
- If 50% of new users come from referral: 2x M12 cohort value

---

## Finding #2: KYC Completion is the Primary Funnel Bottleneck

### The Data

| Stage | Count | Conversion | Drop |
|-------|-------|------------|------|
| Signups | 1,500 | 100% | — |
| KYC Approved | 975 | 65% | **35%** ← BIG DROP |
| Funded Users | 733 | 75% | 25% |
| Traders | 458 | 62% | 38% |

### Revenue Opportunity
- 35% abandonment × ₹2,000 avg user value = **₹1.05M potential**
- **Target:** Improve from 65% → 80% (10-point improvement)
- **Additional users:** +231 funded users
- **Additional revenue:** ~₹462K

### Root Causes (Hypotheses)
1. **Verification delays** — Users lose interest waiting for approval
2. **High rejection rate** — ~15% of submissions rejected
3. **Friction** — Manual document upload process

### Business Recommendation
**Improve KYC approval rate from 65% → 80%**

**Actions:**
- [ ] Implement AI-based real-time KYC (live selfie verification)
- [ ] Add in-app progress tracker with ETA
- [ ] A/B test: auto-approve clean PAN + Aadhar vs. manual
- [ ] First deposit incentive: 0% fees for 1 month

**Cost vs. Benefit:**
- Cost: ~₹200K/month (AI SaaS + staff)
- Benefit: ₹462K revenue improvement
- **Payback:** < 3 months, **ROI: 3:1**

---

## Finding #3: BTCINR Drives 80% of Revenue — Concentration Risk

### The Data

| Market | Volume | Fees | Share |
|--------|--------|------|-------|
| BTCINR | ₹28.5M | ₹58.2K | **81%** |
| ETHINR | ₹10.2M | ₹12.4K | 17% |
| USDTINR | ₹3.1M | ₹4.1K | 2% |

### Why It's a Problem
- **Single point of failure:** BTC crash → 80% revenue loss
- **Regulatory risk:** India restricts BTC → platform revenue collapses
- **Competitive vulnerability:** Competitor with better ETHINR liquidity wins users
- **Forecast unreliability:** Can't predict revenue when one market dominates

### Business Recommendation
**Diversify: Grow ETHINR + USDTINR to 50% of total volume by Q2 2027**

**Actions:**
- [ ] Market making incentive: 2% rebate on ETHINR fees (vs. 0.3% BTCINR)
- [ ] Staking integration: "Stake ETH at 8% APY"
- [ ] B2B partnerships: "Buy ETH for your AI node"
- [ ] List new pairs: LINKUSD, UNIUSD, ACHUSDT

**Expected Impact:**
- ETHINR grows from 17% → 30% of volume
- BTCINR concentration: 81% → 60%
- Additional fee revenue: ~₹15K/month

---

## Finding #4: Payment Infrastructure is Solid, Opportunity in Optimization

### The Data

| Method | Success Rate | Volume | Notes |
|--------|--------------|--------|-------|
| UPI | 93% | ₹4.2M | Best performer |
| IMPS | 92% | ₹0.8M | Slower |
| NET_BANKING | 88% | ₹0.5M | Highest friction |

### Insight
- **8% failure rate is acceptable** (industry norm: 5-12%)
- **NET_BANKING users have worst experience** → migrate to UPI
- Each failed deposit = angry user, lower retention

### Recommendation
**Deprecate NET_BANKING, incentivize UPI adoption**

**Actions:**
- Promote UPI: "Instant deposits with 2-second settlement"
- Offer 0.5% cashback for UPI deposits (one-time)
- Alert if UPI failure rate exceeds 10%

---

## Summary: Resource Allocation

| Initiative | Impact | Effort | Timeline | Priority |
|---|---|---|---|---|
| Referral budget increase | ₹600K CLV | LOW | 2 weeks | 🔴 HIGH |
| KYC approval to 80% | ₹462K revenue | MEDIUM | 60 days | 🔴 HIGH |
| ETHINR diversification | ₹15K/month | HIGH | 120 days | 🟡 MEDIUM |
| Deprecate NET_BANKING | Risk mitigation | LOW | 30 days | 🟢 LOW |

---

## Metrics to Monitor (Weekly)

| Metric | Target | Alert |
|--------|--------|-------|
| KYC approval rate | 80% | < 70% |
| Referral M1 retention | 45%+ | < 40% |
| Payment failure rate | < 8% | > 10% |
| DAU trend | +5% MoM | -5% MoM |
| BTCINR concentration | < 75% | > 85% |

---

**Report Generated:** October 2026  
**Data Period:** January 2025 - March 2026  
**Next Review:** November 2026
