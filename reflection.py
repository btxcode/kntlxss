import requests
import threading
import argparse
from termcolor import colored
from bs4 import BeautifulSoup
from urllib.parse import quote, urlparse
import os
from fake_useragent import UserAgent
from validate_xss import validate_xss_popup  # Import fungsi validasi XSS dari file terpisah

# Membaca payloads dari file
def load_payloads(payload_file):
    with open(payload_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Fungsi untuk menulis hasil sukses ke file log txt
def log_success_to_txt(txt_file, url, payload, status_code, title, waf, user_agent=None):
    with open(txt_file, mode='a') as file:
        file.write(f"[SUCCESS] URL: {url}\n")
        file.write(f"Payload: {payload}\n")
        file.write(f"Status Code: {status_code}\n")
        file.write(f"Page Title: {title}\n")
        file.write(f"WAF Protection: {waf}\n")
        if user_agent:
            file.write(f"UA: {user_agent}\n")
        file.write("\n")

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

# Cek XSS pada URL
def check_xss(url, payload, success_txt_file, use_random_user_agent=False, validated_urls=set()):
    try:
        # Pilih user agent secara random jika opsi --rua diaktifkan
        headers = {}
        user_agent = None
        if use_random_user_agent:
            ua = UserAgent()
            user_agent = ua.random
            headers["User-Agent"] = user_agent
        else:
            headers["User-Agent"] = "Mozilla/5.0"

        # Buat URL dengan payload
        if 'INJECT_HERE' in url:
            full_url = url.replace("INJECT_HERE", quote(payload))
        else:
            full_url = f"{url}{quote(payload)}"

        # Cek apakah URL dengan payload sudah divalidasi sebelumnya
        if (full_url, payload) in validated_urls:
            print(colored(f"[INFO] Skipping duplicate test for {full_url} with payload {payload}", "yellow"))
            return

        # Lakukan permintaan GET ke URL dengan payload
        response = requests.get(full_url, timeout=5, headers=headers)

        # Cek apakah payload tercermin di respons
        if payload in response.text:
            soup = BeautifulSoup(response.text, 'html.parser')
            title = soup.title.string if soup.title else 'No Title'
            waf = detect_waf(response)

            # Jika payload sukses memunculkan alert, tampilkan dan log
            print("=" * 50)  # Garis pemisah di CLI
            print(colored(f"[SUCCESS] Alert found on: {full_url}", "cyan"))
            print(f"Payload: {payload}")
            print(f"Status Code: {response.status_code}")
            print(f"Page Title: {title}")
            print(f"WAF Protection: {waf}")
            if user_agent:
                print(f"UA: {user_agent}")

            # Validasi apakah popup XSS muncul
            print(colored(f"[INFO] Validating XSS popup for {full_url}...", "yellow"))
            if validate_xss_popup(full_url, payload, user_agent):
                print(colored(f"[SUCCESS] XSS validated with popup at {full_url}", "green"))
                # Log ke file txt hanya jika validasi berhasil
                log_success_to_txt(success_txt_file, full_url, payload, response.status_code, title, waf, user_agent)
                validated_urls.add((full_url, payload))  # Simpan URL dan payload yang berhasil divalidasi
            else:
                print(colored(f"[FAILED] XSS reflected but no popup detected at {full_url}", "red"))

        else:
            # Jika gagal, tetap tampilkan full URL dengan payload
            print("=" * 50)  # Garis pemisah di CLI
            print(colored(f"[FAILED] URL: {full_url}", "red"))
            print(f"Payload: {payload}")

    except Exception as e:
        print(colored(f"[ERROR] Failed to test {url} with error: {e}", "red"))

# Fungsi untuk mendapatkan domain tanpa subdomain
def get_domain(url):
    parsed_url = urlparse(url)
    domain = parsed_url.netloc.split('.')[-2] + '.' + parsed_url.netloc.split('.')[-1]
    return domain

# Fungsi utama untuk menjalankan pengujian sequentially dengan semua payload untuk satu URL
def xss_reflection_test(urls, payloads, threads, use_random_user_agent):
    validated_urls = set()  # Set untuk melacak URL yang sudah divalidasi
    for url in urls:
        domain = get_domain(url)
        success_txt_file = f"reflection_{domain}.txt"
        for payload in payloads:
            check_xss(url, payload, success_txt_file, use_random_user_agent, validated_urls)

# Fungsi untuk membaca URL dari file
def load_urls(url_file):
    with open(url_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Main function to parse arguments and start the tests
def main():
    parser = argparse.ArgumentParser(description="XSS Reflection Checker with Logging and Random User Agent")
    parser.add_argument('-l', '--list', required=True, help="File berisi daftar URL (url.txt)")
    parser.add_argument('--threads', type=int, default=5, help="Jumlah thread yang digunakan")
    parser.add_argument('--rua', action='store_true', help="Gunakan Random User Agent")
    args = parser.parse_args()

    urls = load_urls(args.list)
    payloads = load_payloads('payloads.txt')

    # Mulai tes sequential dengan semua payload di setiap URL
    xss_reflection_test(urls, payloads, args.threads, args.rua)

if __name__ == "__main__":
    main()
