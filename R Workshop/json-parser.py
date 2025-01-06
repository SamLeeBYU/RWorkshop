import requests
import pandas as pd

url = "https://politics.data.api.cnn.io/results/view/2020-county-races-PG-MN.json"

response = requests.get(url)
data = response.json()

results = []

# Iterate over each county's data
for county in data:
    county_name = county['countyName']

    results.append({
        'County': county_name,
        'R': county['candidates'][0]['votePercentStr'],
        'D': county['candidates'][1]['votePercentStr']
    })

election_results = pd.DataFrame(results)
election_results[["State", "Year"]] = ["MN", 2020]
for col in ["D", "R"]:
    election_results[col] = (election_results[col].str.replace("%", "").astype(float) / 100).round(3)

election_results.to_csv("data/election-data-2020.csv", index=False)