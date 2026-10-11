import sqlite3
import random
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from faker import Faker

fake = Faker('en_IN')
np.random.seed(42)
random.seed(42)

DB_FILE = "coindcx_analytics.db"
NUM_USERS = 1500
START_DATE = datetime(2025, 1, 1)
END_DATE = datetime(2026, 3, 1)

def random_date(start, end):
    delta = end - start
    return start + timedelta(seconds=random.randint(0, int(delta.total_seconds())))

print("1/4 Generating simulated users and onboarding funnel...")
users = []
for i in range(1, NUM_USERS + 1):
    signup_time = random_date(START_DATE, END_DATE - timedelta(days=30))
    channel = np.random.choice(['Organic', 'Google_Ads', 'Referral', 'Influencer'], p=[0.35, 0.30, 0.20, 0.15])
    city_tier = np.random.choice(['Tier-1', 'Tier-2', 'Tier-3'], p=[0.45, 0.35, 0.20])
    
    # Realistic KYC distribution: 65% approve, 15% reject, 20% abandon
    kyc_outcome = np.random.choice(['APPROVED', 'REJECTED', 'PENDING'], p=[0.65, 0.15, 0.20])
    kyc_time = None
    if kyc_outcome == 'APPROVED':
        kyc_time = signup_time + timedelta(minutes=random.randint(10, 2880))
    elif kyc_outcome == 'REJECTED':
        kyc_time = signup_time + timedelta(hours=random.randint(2, 48))

    users.append({
        "user_id": i,
        "email": fake.unique.email(),
        "signup_timestamp": signup_time.isoformat(),
        "acquisition_channel": channel,
        "kyc_status": kyc_outcome,
        "kyc_completed_at": kyc_time.isoformat() if kyc_time else None,
        "city_tier": city_tier
    })

df_users = pd.DataFrame(users)

print("2/4 Generating wallets and UPI/IMPS deposits...")
wallets = []
fiat_txns = []
txn_id = 1
wallet_id = 1

for u in users:
    for cur in ['INR', 'BTC', 'ETH', 'USDT']:
        wallets.append({
            "wallet_id": wallet_id,
            "user_id": u["user_id"],
            "currency": cur,
            "available_balance": 0.0,
            "locked_balance": 0.0,
            "updated_at": u["signup_timestamp"]
        })
        wallet_id += 1

approved_users = [u for u in users if u["kyc_status"] == 'APPROVED']
funded_user_ids = set()

for u in approved_users:
    # 75% of approved users attempt a deposit
    if np.random.rand() < 0.75:
        num_deposits = np.random.choice([1, 2, 3, 5], p=[0.55, 0.25, 0.15, 0.05])
        kyc_dt = datetime.fromisoformat(u["kyc_completed_at"])
        
        for _ in range(num_deposits):
            dep_time = kyc_dt + timedelta(hours=random.randint(1, 240))
            if dep_time > END_DATE:
                continue
            
            method = np.random.choice(['UPI', 'IMPS', 'NET_BANKING'], p=[0.70, 0.20, 0.10])
            amount = float(np.random.choice([500, 1000, 2500, 5000, 15000, 50000], p=[0.25, 0.35, 0.20, 0.10, 0.07, 0.03]))
            status = np.random.choice(['SUCCESS', 'FAILED'], p=[0.92, 0.08])

            fiat_txns.append({
                "transaction_id": txn_id,
                "user_id": u["user_id"],
                "type": 'DEPOSIT',
                "amount_inr": amount,
                "payment_method": method,
                "status": status,
                "created_at": dep_time.isoformat()
            })
            txn_id += 1
            if status == 'SUCCESS':
                funded_user_ids.add(u["user_id"])

df_wallets = pd.DataFrame(wallets)
df_fiat = pd.DataFrame(fiat_txns)

print("3/4 Simulating order books and executed trades...")
orders = []
trades = []
order_id = 1
trade_id = 1

PAIRS = {
    'BTCINR': {'base_price': 5800000.0, 'qty_range': (0.0005, 0.02)},
    'ETHINR': {'base_price': 270000.0,  'qty_range': (0.01, 0.35)},
    'USDTINR': {'base_price': 88.5,     'qty_range': (25.0, 500.0)}
}

active_traders = list(funded_user_ids)

for _ in range(3000):
    if len(active_traders) < 2:
        break
    
    buyer_id, seller_id = random.sample(active_traders, 2)
    pair = np.random.choice(list(PAIRS.keys()), p=[0.55, 0.30, 0.15])
    cfg = PAIRS[pair]
    
    price = round(cfg['base_price'] * np.random.uniform(0.92, 1.08), 2)
    qty = round(np.random.uniform(cfg['qty_range'][0], cfg['qty_range'][1]), 6)
    vol_inr = round(price * qty, 2)
    trade_time = random_date(START_DATE + timedelta(days=20), END_DATE)

    # Limit maker order
    orders.append({
        "order_id": order_id,
        "user_id": buyer_id,
        "market_pair": pair,
        "side": 'BUY',
        "order_type": 'LIMIT',
        "price": price,
        "quantity": qty,
        "status": 'FILLED',
        "created_at": (trade_time - timedelta(minutes=random.randint(5, 180))).isoformat()
    })
    maker_order_id = order_id
    order_id += 1

    # Market taker order
    orders.append({
        "order_id": order_id,
        "user_id": seller_id,
        "market_pair": pair,
        "side": 'SELL',
        "order_type": 'MARKET',
        "price": price,
        "quantity": qty,
        "status": 'FILLED',
        "created_at": trade_time.isoformat()
    })
    taker_order_id = order_id
    order_id += 1

    # Matched Trade
    trades.append({
        "trade_id": trade_id,
        "market_pair": pair,
        "maker_order_id": maker_order_id,
        "taker_order_id": taker_order_id,
        "buyer_user_id": buyer_id,
        "seller_user_id": seller_id,
        "execution_price": price,
        "quantity": qty,
        "volume_inr": vol_inr,
        "maker_fee_inr": round(vol_inr * 0.001, 2),
        "taker_fee_inr": round(vol_inr * 0.002, 2),
        "executed_at": trade_time.isoformat()
    })
    trade_id += 1

df_orders = pd.DataFrame(orders)
df_trades = pd.DataFrame(trades)

print("4/4 Writing tables to SQLite...")
conn = sqlite3.connect(DB_FILE)
cur = conn.cursor()

cur.executescript("""
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    signup_timestamp TEXT,
    acquisition_channel TEXT,
    kyc_status TEXT,
    kyc_completed_at TEXT,
    city_tier TEXT
);

CREATE TABLE IF NOT EXISTS wallets (
    wallet_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    currency TEXT,
    available_balance REAL,
    locked_balance REAL,
    updated_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS fiat_transactions (
    transaction_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    type TEXT,
    amount_inr REAL,
    payment_method TEXT,
    status TEXT,
    created_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    market_pair TEXT,
    side TEXT,
    order_type TEXT,
    price REAL,
    quantity REAL,
    status TEXT,
    created_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS trades (
    trade_id INTEGER PRIMARY KEY,
    market_pair TEXT,
    maker_order_id INTEGER,
    taker_order_id INTEGER,
    buyer_user_id INTEGER,
    seller_user_id INTEGER,
    execution_price REAL,
    quantity REAL,
    volume_inr REAL,
    maker_fee_inr REAL,
    taker_fee_inr REAL,
    executed_at TEXT,
    FOREIGN KEY(buyer_user_id) REFERENCES users(user_id),
    FOREIGN KEY(seller_user_id) REFERENCES users(user_id)
);
""")

df_users.to_sql('users', conn, if_exists='replace', index=False)
df_wallets.to_sql('wallets', conn, if_exists='replace', index=False)
df_fiat.to_sql('fiat_transactions', conn, if_exists='replace', index=False)
df_orders.to_sql('orders', conn, if_exists='replace', index=False)
df_trades.to_sql('trades', conn, if_exists='replace', index=False)

conn.commit()
conn.close()

print(f"Data ingestion successful into {DB_FILE}!")