#Scrape 2020 and 2024 election results by county

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

import pandas as pd
import numpy as np
import random
import time

urls = ["https://www.cnn.com/election/2024/results/minnesota/president"]

class Scraper:

    def __init__(self):
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service)

    def scrape(self, url, state="MN", year=2024):

        self.driver.get(url)

        header = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//*[contains(text(), 'Results by county')]"))
                )
        section = header.find_element(By.XPATH, "..")

        data_table = section.find_element(By.TAG_NAME, "table")
        rows = data_table.text.split("\n")[5:]
        chunk_size = 28
        partitioned = [rows[i:i + chunk_size] for i in range(0, len(rows), chunk_size)]
        data = [[subarray[0], subarray[2], subarray[10]] for subarray in partitioned if len(subarray) >= 11]

        df = pd.DataFrame(data, columns=["County", "D", "R"])

        #Convert the percentages to decimals
        for col in ["D", "R"]:
            df[col] = (df[col].str.replace("%", "").astype(float) / 100).round(3)

        df[["State", "Year"]] = [state, year]

        return(df)


if __name__ == '__main__':
    scraper = Scraper()
    for url in urls:
        election_results = scraper.scrape(url)
        election_results.to_csv("data/election-data-2024.csv", index=False)
