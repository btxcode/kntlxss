#!/bin/bash

# Fungsi untuk menampilkan bantuan penggunaan
function usage() {
    echo "Usage: $0 [-u domain | -l domain_list] -o output_file"
    exit 1
}

# Memeriksa jika tidak ada argumen yang diberikan
if [ $# -eq 0 ]; then
    usage
fi

# Mendapatkan nilai argumen
while getopts "u:l:o:" opt; do
    case "$opt" in
    u) domain=$OPTARG ;;
    l) domain_list=$OPTARG ;;
    o) output_file=$OPTARG ;;
    *) usage ;;
    esac
done

# Memeriksa apakah domain atau domain_list dan output file diberikan
if { [ -z "$domain" ] && [ -z "$domain_list" ]; } || [ -z "$output_file" ]; then
    usage
fi

# Fungsi untuk memproses domain
function process_domain() {
    echo "$1" | waybackurls | gf xss | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u
}

# Memproses domain tunggal
if [ -n "$domain" ]; then
    process_domain "$domain" | tee "$output_file"
fi

# Memproses daftar domain
if [ -n "$domain_list" ]; then
    while IFS= read -r domain; do
        process_domain "$domain"
    done < "$domain_list" | uniq | sort -u | tee "$output_file"
fi
