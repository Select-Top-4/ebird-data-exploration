import requests
import pandas as pd
from datetime import date, timedelta
import time

PUBLIC_KEY = "obk3lno5ptmj"
TODAY = date.today()
# YEAR_START = date(TODAY.year, 1, 1)
YEAR_START = date(TODAY.year, 2, 12)
DAYS = (TODAY - YEAR_START).days
SUBREGIONS = ["US-AL", "US-AK", "US-AZ", "US-AR", "US-CA", "US-CO", "US-CT", "US-DE",
"US-DC", "US-FL", "US-GA", "US-HI", "US-ID", "US-IL", "US-IN", "US-IA", "US-KS",
"US-KY", "US-LA", "US-ME", "US-MD", "US-MA", "US-MI", "US-MN", "US-MS", "US-MO",
"US-MT", "US-NE", "US-NV", "US-NH", "US-NJ", "US-NM", "US-NY", "US-NC", "US-ND",
"US-OH", "US-OK", "US-OR", "US-PA", "US-RI", "US-SC", "US-SD", "US-TN", "US-TX",
"US-UT", "US-VT", "US-VA", "US-WA", "US-WV", "US-WI","US-WY"]

# this function may take up to 6-7 hours
def get_obs_current_year():
    data = []
    start_date = YEAR_START
    for _ in range(DAYS):
        for subregion in SUBREGIONS: 
            print(start_date, "&", subregion, " collecting...")
            try: 
                res = requests.get(f"https://api.ebird.org/v2/data/obs/{subregion}/historic/" \
                    + f"{start_date.year}/{start_date.month}/{start_date.day}?detail=full", 
                    headers = {"x-ebirdapitoken": PUBLIC_KEY}, timeout=85)
                if res.ok:
                    data.extend(res.json())
                    print("success!")
                else:
                    print("server error")
            except Exception:
                print(start_date, "&", subregion,  " unavailable or timed out")
            finally:
                time.sleep(5)
        start_date += timedelta(days=1)
    return data

# ## without details
# def get_obs_current_year():
#     data = []
#     start_date = YEAR_START
#     for _ in range(DAYS):
#         print(start_date, " collecting")
#         try: 
#             res = requests.get(f"https://api.ebird.org/v2/data/obs/US/historic/" \
#                 + f"{start_date.year}/{start_date.month}/{start_date.day}", 
#                 headers = {"x-ebirdapitoken": PUBLIC_KEY}, timeout=90)
#             if res.ok:
#                 data.extend(res.json())
#                 print("success!")
#             else:
#                 print("server error")
#         except Exception:
#             print(start_date, " unavailable or timed out")
#         finally:
#             start_date += timedelta(days=1)
#             time.sleep(5)
#     return data

# ## for testing purpose
# def test():
#     data = []
#     print("collecting...")
#     try: 
#         res = requests.get("https://api.ebird.org/v2/data/obs/US/historic/2023/1/5",
#             headers = {"x-ebirdapitoken": PUBLIC_KEY}, timeout=80)
#         if res.ok:
#             print(res.json())
#             data.extend(res.json())
#     except Exception:
#         print("unavailable or timed out")
#     finally:
#         time.sleep(5)
#     return data

def convert_json_to_csv(data):
    df = pd.DataFrame(data)
    df.to_csv('current_year_obs2.csv', encoding='utf-8', index=False)

data = get_obs_current_year()
convert_json_to_csv(data)