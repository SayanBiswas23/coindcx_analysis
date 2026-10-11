
import time
import requests
import pandas as pd
from sqlalchemy import create_engine

PG_URL = "postgresql+psycopg2://postgres:Password23@localhost:5432/coindcx_analytics"
engine = create_engine(PG_URL)

TICKER_API = "https://api.coindcx.com/exchange/ticker"
TARGET_MARKETS = {"BTCINR", "ETHINR", "USDTINR"}

def fetch_and_save():
    response = requests.get(TICKER_API, timeout=5)
    data = response.json()
    
    rows = []
    now = pd.Timestamp.now()
    for item in data:
        if item.get("market") in TARGET_MARKETS:
            rows.append({
                "market": item["market"],
                "last_price": float(item["last_price"]),
                "volume": float(item.get("volume", 0)),
                "fetched_at": now
            })
            
    if rows:
        df = pd.DataFrame(rows)
        df.to_sql("live_ticker_prices", con=engine, if_exists="append", index=False)
        print(f"Logged {len(rows)} live ticks to PostgreSQL at {now}")

if __name__ == "__main__":
    while True:
        try:
            fetch_and_save()
        except Exception as e:
            print("Error logging tick:", e)
































            
# import requests
# import sqlite3
# from datetime import datetime
# import time

# DB_NAME = "coindcx_analytics.db"
# API_URL = "https://api.coindcx.com/exchange/ticker"

# def init_db():
#     with sqlite3.connect(DB_NAME) as conn:
#         cursor = conn.cursor()
#         cursor.execute("PRAGMA journal_mode=WAL;")
#         cursor.execute("""
#             CREATE TABLE IF NOT EXISTS live_ticker_prices (
#                 id INTEGER PRIMARY KEY AUTOINCREMENT,
#                 market TEXT NOT NULL,
#                 last_price REAL NOT NULL,
#                 volume REAL,
#                 fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
#             );
#         """)
#         cursor.execute("CREATE INDEX IF NOT EXISTS idx_market ON live_ticker_prices(market);")
#         conn.commit()

# def fetch_and_save():
#     init_db()
#     response = requests.get(API_URL)
    
#     if response.status_code != 200:
#         print(f"Failed to fetch data: HTTP {response.status_code}")
#         return

#     data = response.json()
#     records = []
    
#     for item in data:
#         market = item.get("market")
#         price = item.get("last_price")
#         volume = item.get("volume")
        
#         if market and price:
#             try:
#                 records.append((market, float(price), float(volume) if volume else 0.0))
#             except ValueError:
#                 continue

#     with sqlite3.connect(DB_NAME) as conn:
#         conn.executemany("""
#             INSERT INTO live_ticker_prices (market, last_price, volume)
#             VALUES (?, ?, ?);
#         """, records)
#         conn.commit()

#     print(f"Inserted {len(records)} records into {DB_NAME}")


# if __name__ == "__main__":
#     print("Starting automated ETL pipeline. Press Ctrl+C to stop.")
#     try:
#         while True:
#             fetch_and_save()
#             print("Waiting 60 seconds for the next batch...")
#             time.sleep(60)
#     except KeyboardInterrupt:
#         print("\nPipeline stopped by user.")
        time.sleep(30)