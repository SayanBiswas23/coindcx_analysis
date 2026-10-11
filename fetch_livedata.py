import requests
import json

def get_live_ticker_data():
    url = "https://api.coindcx.com/exchange/ticker"
    print(f"Connecting to {url}...")
    
    response = requests.get(url)
    
    # 200 means the request was successful
    if response.status_code == 200:
        data = response.json()
        print(f"Success! Fetched live data for {len(data)} trading pairs.\n")
        
        # Print the first 5 pairs to understand the JSON structure
        for item in data[:5]:
            print(f"Market: {item.get('market')}")
            print(f"Last Price: {item.get('last_price')}")
            print(f"24h Volume: {item.get('volume')}")
            print("-" * 25)
    else:
        print(f"Failed to fetch data. Status code: {response.status_code}")

if __name__ == "__main__":
    get_live_ticker_data()