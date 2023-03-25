from bs4 import BeautifulSoup
import csv
import re
import requests
import sys

# Get family descriptions and output to csv, script takes a command line arg for file output name
# Run like this:         python family_scraper.py family_descriptions.csv

def scrapeFamily(family_url):
    """Scrape family description from wiki"""
    print(family_url)
    fam_response = requests.get(
		url=family_url
    )
    fam_soup = BeautifulSoup(fam_response.content, 'html.parser')
    descriptions = fam_soup.find(id="mw-content-text").find_all("p")
    for description in descriptions:
        if "." in description:
            return(str(description))
    return("NA")

def extractDescription(d):
    clean = re.compile('<.*?>|\[.*?\]')
    return re.sub(clean, '', d)



# output file is arg 1
csv_name = sys.argv[1]

# find links
response = requests.get(
    url="https://en.wikipedia.org/wiki/Category:Bird_families"
)
soup = BeautifulSoup(response.content, 'html.parser')
links = soup.find(id="mw-pages").find_all("a")
on = 0
with open(csv_name, 'w', newline='') as csvfile:
    w = csv.writer(csvfile, delimiter=',')
    w.writerow(["family_scientific_name", "family_description"])
    for link in links:
        if link['href'].find("/wiki/") == -1 or link['href'].find("_") != -1:
            continue
        #time to scrape
        on += 1
        description = scrapeFamily("https://en.wikipedia.org" + link['href'])
        extracted_description = extractDescription(description)
        family = link['href'].rsplit('/', 1)[-1]
        try:
                w = csv.writer(csvfile, delimiter=',')
                w.writerow([family, extracted_description])
        except:
            #oops
            continue