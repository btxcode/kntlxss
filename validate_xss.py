from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time

def validate_xss_popup(url, payload, user_agent=None):
    driver = None
    try:
        chrome_options = Options()
        chrome_options.add_argument("--headless")  # Mode headless diaktifkan
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--disable-software-rasterizer")  # Mengatasi masalah grafis
        #chrome_options.add_argument("--remote-debugging-port=9222")
        if user_agent:
            chrome_options.add_argument(f"user-agent={user_agent}")

        # Inisialisasi driver untuk Chrome
        driver = webdriver.Chrome(service=Service('/usr/local/bin/chromedriver'), options=chrome_options)

        # Mengakses URL yang berisi payload
        driver.get(url)

        # Tambahkan jeda untuk memastikan halaman termuat dengan benar
        time.sleep(2)

        # Tunggu sampai popup muncul dengan timeout 5 detik
        try:
            WebDriverWait(driver, 5).until(EC.alert_is_present())
            alert = driver.switch_to.alert
            alert_text = alert.text
            alert.accept()  # Menutup popup

            print(f"[SUCCESS] XSS popup detected! Alert text: '{alert_text}'")
            return True

        except TimeoutException:
            print(f"[FAILED] No XSS popup detected for {url}")
            return False

    except Exception as e:
        print(f"[ERROR] Failed to validate XSS popup for {url} with error: {e}")
        return False

    finally:
        if driver:
            driver.quit()
