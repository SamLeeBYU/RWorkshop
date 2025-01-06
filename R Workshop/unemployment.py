#Scrape unemployment rates for MN counties from 2016-2024

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

from bs4 import BeautifulSoup

class Scraper:

    def __init__(self):
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service)

    def load(self, state_index=23):

        self.driver.get("https://data.bls.gov/PDQWeb/la")

        state_selection = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, "select#select-0"))
                )

        states = state_selection.find_elements(By.TAG_NAME, "option")
        states[state_index].click()

        area_selection = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, "select#select-1"))
                )
        areas = area_selection.find_elements(By.TAG_NAME, "option")
        areas[4].click()

        county_selection = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, "select#select-2"))
                )
        counties = county_selection.find_elements(By.TAG_NAME, "option")
        C = len(counties)

        for i in range(C // 5 + 1):

            for j in range(i*5, i*5+5):

                counties[j].click()

            add_button = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, "button[type='submit']"))
                )
            add_button.click()

            submit_button = self.driver.find_elements(By.CSS_SELECTOR, "button[type='submit']")

            self.driver.execute_script(
                "arguments[0].form.setAttribute('target', '_self');",
                submit_button[1]
            )

            submit_button[1].click()
            submit_button[1].click()

            time.sleep(1)

            tabs = self.driver.window_handles
            self.driver.switch_to.window(tabs[0])
            self.driver.switch_to.window(tabs[2])
        
            time.sleep(3)

            html = self.driver.page_source

            self.parse_data(html)
            
    def parse_data(self, html):
        DATA = pd.DataFrame()
        soup = BeautifulSoup(html, "html.parser")
        tables = soup.find_all("table")
        county_names = [
            pd.read_html(tables[i].prettify())[0].iloc[2, 1].replace("Area: ", "").strip()
            for i in range(0, len(tables), 2)  # Step through even indices
        ]
        for i in range(len(tables)):
            if i % 2 == 1:  # Process tables at odd indices
                county_data = pd.read_html(tables[i].prettify())[0]  # Parse the table
                county_data["County"] = county_names[(i - 1) // 2]  # Assign the corresponding county name
                if DATA.empty:  # Check if DATA is empty
                    DATA = county_data
                else:
                    DATA = pd.concat([DATA, county_data], ignore_index=True)

        DATA.to_csv("data/unemployment-mn.csv", index=False)        


if __name__ == "__main__":

    scraper = Scraper()
    with open("data/unemployment-mn.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    scraper.parse_data(html_content)