import sqlite3
import pandas as pd
from sqlalchemy import create_engine

# 1. Connections
sqlite_conn = sqlite3.connect("coindcx_analytics.db")

# Update with your Postgres username, password, host, port, and db
PG_URL = "postgresql+psycopg2://postgres:Password23@localhost:5432/coindcx_analytics"
pg_engine = create_engine(PG_URL)

# 2. List tables to transfer
tables = ["users", "wallets", "fiat_transactions", "orders", "trades", "live_ticker_prices"]

# 3. Read from SQLite and write directly to PostgreSQL
for table in tables:
    print(f"Migrating {table}...")
    df = pd.read_sql_query(f"SELECT * FROM {table}", sqlite_conn)
    df.to_sql(table, con=pg_engine, if_exists="replace", index=False, chunksize=1000)
    print(f" Successfully transferred {len(df)} rows to PostgreSQL table '{table}'")

sqlite_conn.close()
print("All tables successfully migrated to PostgreSQL!")