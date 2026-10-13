# CoinDCX Database Schema

## Table Definitions

### `users`
**Purpose:** Core user identity and onboarding tracking  
**Refresh:** One-time on signup

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `user_id` | INTEGER | No | Primary key |
| `email` | TEXT | No | Unique per user |
| `signup_timestamp` | TEXT (ISO 8601) | No | When user registered |
| `acquisition_channel` | TEXT | No | `Organic`, `Google_Ads`, `Referral`, `Influencer` |
| `kyc_status` | TEXT | No | `PENDING`, `APPROVED`, `REJECTED` |
| `kyc_completed_at` | TEXT (ISO 8601) | Yes | NULL if PENDING |
| `city_tier` | TEXT | No | `Tier-1`, `Tier-2`, `Tier-3` |

---

### `wallets`
**Purpose:** Cryptocurrency balances per user  
**Refresh:** Real-time (after each trade)

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `wallet_id` | INTEGER | No | Primary key |
| `user_id` | INTEGER | No | Foreign key to `users` |
| `currency` | TEXT | No | `INR`, `BTC`, `ETH`, `USDT` |
| `available_balance` | REAL | No | Unlocked funds available to trade |
| `locked_balance` | REAL | No | Funds locked in open orders |
| `updated_at` | TEXT (ISO 8601) | No | Last update time |

---

### `fiat_transactions`
**Purpose:** INR deposits and withdrawals  
**Refresh:** Real-time (on transaction completion)

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `transaction_id` | INTEGER | No | Primary key |
| `user_id` | INTEGER | No | Foreign key to `users` |
| `type` | TEXT | No | `DEPOSIT`, `WITHDRAWAL` |
| `amount_inr` | REAL | No | Amount in Indian Rupees |
| `payment_method` | TEXT | No | `UPI`, `IMPS`, `NET_BANKING` |
| `status` | TEXT | No | `SUCCESS`, `FAILED` |
| `created_at` | TEXT (ISO 8601) | No | Transaction timestamp |

---

### `orders`
**Purpose:** Buy/sell orders placed by users  
**Refresh:** Real-time (when placed)

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `order_id` | INTEGER | No | Primary key |
| `user_id` | INTEGER | No | Foreign key to `users` |
| `market_pair` | TEXT | No | `BTCINR`, `ETHINR`, `USDTINR` |
| `side` | TEXT | No | `BUY`, `SELL` |
| `order_type` | TEXT | No | `LIMIT`, `MARKET` |
| `price` | REAL | No | Limit price |
| `quantity` | REAL | No | Amount of asset |
| `status` | TEXT | No | `FILLED`, `PARTIAL`, `CANCELLED` |
| `created_at` | TEXT (ISO 8601) | No | When placed |

---

### `trades`
**Purpose:** Matched orders (completed transactions)  
**Refresh:** Real-time

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `trade_id` | INTEGER | No | Primary key |
| `market_pair` | TEXT | No | E.g., `BTCINR` |
| `maker_order_id` | INTEGER | No | Foreign key to `orders` |
| `taker_order_id` | INTEGER | No | Foreign key to `orders` |
| `buyer_user_id` | INTEGER | No | Foreign key to `users` |
| `seller_user_id` | INTEGER | No | Foreign key to `users` |
| `execution_price` | REAL | No | Price executed |
| `quantity` | REAL | No | Amount traded |
| `volume_inr` | REAL | No | `execution_price × quantity` |
| `maker_fee_inr` | REAL | No | 0.1% of volume |
| `taker_fee_inr` | REAL | No | 0.2% of volume |
| `executed_at` | TEXT (ISO 8601) | No | Execution time |

---

### `live_ticker_prices`
**Purpose:** Market price benchmarks  
**Refresh:** Every 60 seconds

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `id` | INTEGER | No | Primary key |
| `market` | TEXT | No | `BTCINR`, `ETHINR`, `USDTINR` |
| `last_price` | REAL | No | Current market price |
| `volume` | REAL | No | 24h trading volume |
| `fetched_at` | TIMESTAMP | Yes | When fetched |

---

## Data Quality Notes

### Known Issues & Workarounds

| Issue | Workaround |
|-------|-----------|
| NULL `kyc_completed_at` | Use `COALESCE(kyc_completed_at, NOW())` in latency queries |
| REJECTED users not in funnel | Track separately with `kyc_status IN ('APPROVED', 'REJECTED')` |
| No user_id on trades | Always join: `trades t → orders o → users u` |
| Stale ticker prices | Add freshness check: `fetched_at > NOW() - INTERVAL '1 hour'` |

---

## Query Performance

### Indexes
```sql
CREATE INDEX idx_market ON live_ticker_prices(market);
CREATE INDEX idx_user_id ON wallets(user_id);
CREATE INDEX idx_buyer_user_id ON trades(buyer_user_id);
```

### Expected Runtime
- Report 1 (Funnel): < 1 second
- Report 2 (Retention): 5-10 seconds
- Report 3 (Revenue): < 1 second
- Report 4 (Health): < 2 seconds

---

## Sample Data Characteristics

| Table | Count | Notes |
|-------|-------|-------|
| users | 1,500 | Channels: 35% Organic, 30% Google Ads, 20% Referral, 15% Influencer |
| wallets | 6,000 | 4 currencies per user |
| fiat_transactions | ~800 | 92% success rate, 70% UPI |
| orders | 3,000 | 55% LIMIT, 45% MARKET |
| trades | 3,000 | 55% BTCINR, 30% ETHINR, 15% USDTINR |
| live_ticker_prices | ~100 | Hourly snapshots |

---

## Key Relationships

```
users (1) ──→ (many) wallets
users (1) ──→ (many) fiat_transactions
users (1) ──→ (many) orders
users (1) ──→ (many) trades (buyer_user_id, seller_user_id)
orders (1) ──→ (1) trades (maker_order_id, taker_order_id)
```

---

**Last Updated:** October 2026
