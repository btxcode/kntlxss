import requests
import argparse
from termcolor import colored
from fake_useragent import UserAgent
from urllib.parse import urlparse
import re

# Membaca payloads dari file
def load_payloads(payload_file):
    with open(payload_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Deteksi error berdasarkan pola error SQL yang umum
def detect_sql_error(response_text):
    sql_errors = {
        "MySQL": [
            "You have an error in your SQL syntax",
            "Warning: mysql_",
            "MySQL server version for the right syntax",
            "check the manual that corresponds to your MySQL server version",
            "supplied argument is not a valid MySQL result resource"
        ],
        "PostgreSQL": [
            "pg_query()",
            "PostgreSQL query failed",
            "unterminated quoted string at or near",
            "syntax error at or near",
            "invalid input syntax for"
        ],
        "MSSQL": [
            "Unclosed quotation mark after the character string",
            "Microsoft OLE DB Provider for SQL Server",
            "Incorrect syntax near",
            "The multi-part identifier could not be bound",
            "Procedure expects parameter"
        ],
        "Oracle": [
            "ORA-",
            "ORA-00933: SQL command not properly ended",
            "ORA-01756: quoted string not properly terminated",
            "PLS-00905: object is invalid"
        ],
        "SQLite": [
            "SQLite Error",
            "unrecognized token",
            "SQLite3::SQLException",
            "SQLITE_ERROR"
        ],
        "Generic": [
            "SQL syntax",
            "unexpected end of SQL command",
            "quoted string not properly terminated",
            "Invalid Query"
        ]
    }

    # Periksa setiap pola error di respons
    for db, patterns in sql_errors.items():
        for pattern in patterns:
            if re.search(pattern, response_text, re.IGNORECASE):
                return db, pattern
    return None, None

# Fungsi untuk mengirimkan payload dan mengecek SQLi
def test_sql_injection(url, payload, headers):
    try:
        # Buat URL dengan payload
        if 'INJECT_HERE' in url:
            target_url = url.replace("INJECT_HERE", payload)
        else:
            target_url = f"{url}{payload}"

        # Kirim request GET ke URL
        response = requests.get(target_url, headers=headers, timeout=5)

        # Periksa apakah ada error SQL di respons
        db_type, error_pattern = detect_sql_error(response.text)
        if db_type:
            print(colored(f"[SUCCESS] Potential SQLi detected on: {target_url}", "green"))
            print(f"Database: {db_type}")
            print(f"Error Pattern: {error_pattern}")
            print(f"Status Code: {response.status_code}")
        else:
            print(colored(f"[FAILED] No SQLi detected on: {target_url}", "red"))
    except Exception as e:
        print(colored(f"[ERROR] Failed to test {url} with error: {e}", "red"))

# Fungsi utama untuk menjalankan pengujian SQLi
def sqli_test(urls, payloads, use_random_user_agent):
    ua = UserAgent() if use_random_user_agent else None

    for url in urls:
        print(colored(f"[INFO] Testing URL: {url}", "blue"))

        for payload in payloads:
            headers = {}
            if use_random_user_agent:
                headers["User-Agent"] = ua.random
            else:
                headers["User-Agent"] = "Mozilla/5.0"

            test_sql_injection(url, payload, headers)

# Fungsi untuk membaca URL dari file
def load_urls(url_file):
    with open(url_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Main function to parse arguments and start the tests
def main():
    parser = argparse.ArgumentParser(description="SQL Injection Tester with Error Detection and Random User Agent")
    parser.add_argument('-l', '--list', required=True, help="File berisi daftar URL (url.txt)")
    parser.add_argument('--payload', default='payloads.txt', help="File berisi daftar payload SQLi (default: payloads.txt)")
    parser.add_argument('--rua', action='store_true', help="Gunakan Random User Agent")
    args = parser.parse_args()

    urls = load_urls(args.list)
    payloads = load_payloads(args.payload)

    # Mulai pengujian SQLi
    sqli_test(urls, payloads, args.rua)

if __name__ == "__main__":
    main()
