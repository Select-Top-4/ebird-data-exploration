import requests
import pandas as pd
from datetime import date, timedelta
import time

PUBLIC_KEY = "obk3lno5ptmj"
TODAY = date.today()
YEAR_START = date(TODAY.year, 1, 1)
DAYS = (TODAY - YEAR_START).days

def get_obs_current_year():
    data = []
    start_date = YEAR_START
    for _ in range(DAYS):
        print(start_date, " collecting")
        try: 
            res = requests.get(f"https://api.ebird.org/v2/data/obs/US/historic/" \
                + f"{start_date.year}/{start_date.month}/{start_date.day}", 
                headers = {"x-ebirdapitoken": PUBLIC_KEY}, timeout=90)
            if res.ok:
                data.extend(res.json())
                print("success!")
            else:
                print("server error")
        except Exception:
            print(start_date, " unavailable or timed out")
        finally:
            start_date += timedelta(days=1)
            time.sleep(5)
    return data

def convert_json_to_csv(data):
    df = pd.DataFrame(data)
    df.to_csv('current_year_obs.csv', encoding='utf-8', index=False)

def test():
    data = []
    print("collecting...")
    try: 
        res = requests.get("https://api.ebird.org/v2/data/obs/US/historic/2023/1/5",
            headers = {"x-ebirdapitoken": PUBLIC_KEY}, timeout=80)
        if res.ok:
            print(res.json())
            data.extend(res.json())
    except Exception:
        print("unavailable or timed out")
    finally:
        time.sleep(5)
    return data

# data = test()
data = get_obs_current_year()
convert_json_to_csv(data)