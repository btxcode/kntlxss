import requests
import argparse
from urllib.parse import urlparse
from termcolor import colored
from fake_useragent import UserAgent

# Fungsi untuk membaca payloads dari file payloadsql.txt
def load_payloads(payload_file):
    with open(payload_file, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Fungsi untuk menyimpan hasil sukses ke dalam file
def log_success_to_txt(txt_file, url, payload, status_code, response_time, response_content, db_type, user_agent=None):
    with open(txt_file, mode='a') as file:
        file.write(f"[SUCCESS] URL: {url}\n")
        file.write(f"Payload: {payload}\n")
        file.write(f"Database Type: {db_type}\n")
        file.write(f"Status Code: {status_code}\n")
        file.write(f"Response Time: {response_time}ms\n")
        file.write(f"Response Content: {response_content[:200]}...\n")  # Log sebagian isi konten respons
        if user_agent:
            file.write(f"User-Agent: {user_agent}\n")
        file.write("\n")

# Fungsi untuk melakukan pengujian SQLi
def test_sqli(url, payloads, output_file, use_random_user_agent):
    domain = get_domain(url)
    success_txt_file = f"sql_{domain}.txt"

    ua = UserAgent() if use_random_user_agent else None

    for payload in payloads:
        try:
            target_url = f"{url}{payload}"
            headers = {}
            if use_random_user_agent:
                headers["User-Agent"] = ua.random
            else:
                headers["User-Agent"] = "Mozilla/5.0"
            
            response = requests.get(target_url, timeout=5, headers=headers)

            db_type = detect_sql_error(response)
            if db_type:
                user_agent = headers.get("User-Agent")
                print(colored(f"[SUCCESS] SQLi found on: {target_url}", "green"))
                print(f"Payload: {payload}")
                print(f"Database Type: {db_type}")
                print(f"Status Code: {response.status_code}")
                print(f"Response Time: {response.elapsed.total_seconds() * 1000}ms")
                log_success_to_txt(success_txt_file, target_url, payload, response.status_code, response.elapsed.total_seconds() * 1000, response.text, db_type, user_agent)
            else:
                print(colored(f"[FAILED] No SQL error detected: {target_url}", "red"))

        except Exception as e:
            print(colored(f"[ERROR] Failed to test {url} with error: {e}", "red"))

# Fungsi untuk mendeteksi jenis database berdasarkan pola error SQL
def detect_sql_error(response):
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
    
    for db_type, patterns in sql_errors.items():
        for pattern in patterns:
            if pattern.lower() in response.text.lower():
                return db_type
    return None

# Fungsi untuk mendapatkan domain tanpa subdomain
def get_domain(url):
    parsed_url = urlparse(url)
    domain = parsed_url.netloc.split('.')[-2] + '.' + parsed_url.netloc.split('.')[-1]
    return domain

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
