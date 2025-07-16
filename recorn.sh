#!/bin/bash

# Task 10B: Auto Recon Tool for tesla.com
# Tools:
# a) Subfinder & Assetfinder - Subdomain enumeration
# b) Httprobe - Alive domain check
# c) Nmap - Port scanning of alive domains

domain="tesla.com"
output_dir="tesla"
mkdir -p "$output_dir"

echo "[+] Step 1: Subdomain Enumeration"
subfinder -d "$domain" -silent > "$output_dir/subdomains_subfinder.txt"

if command -v assetfinder >/dev/null 2>&1; then
    assetfinder --subs-only "$domain" > "$output_dir/subdomains_assetfinder.txt"
else
    echo "[-] Assetfinder not found, skipping..."
    touch "$output_dir/subdomains_assetfinder.txt"
fi

echo "[+] Step 2: Merging and Cleaning Subdomains"
cat "$output_dir"/subdomains_*.txt | sort -u > "$output_dir/all_subdomains.txt"
cat "$output_dir/all_subdomains.txt" | sed 's|http[s]*://||g' | sort -u > "$output_dir/cleaned_subs.txt"

echo "[+] Step 3: Probing for Alive Domains"
cat "$output_dir/cleaned_subs.txt" | httprobe -c 20 | sort -u > "$output_dir/alive_subdomains.txt"

echo "[+] Step 4: Fast Nmap Scanning (Parallel)"
mkdir -p "$output_dir/nmap_scans"

cat "$output_dir/alive_subdomains.txt" | sed 's|http[s]*://||g' | sort -u | \
xargs -P20 -I{} sh -c '
    echo "[*] Scanning: {}"
    nmap -Pn -n -T5 -F {} -oN '"$output_dir"'/nmap_scans/nmap_{}.txt > /dev/null 2>&1
'

echo "[+] Step 5: Creating Summary"
{
    echo "Recon Summary for $domain"
    echo ""
    echo "[*] Subdomains:"
    cat "$output_dir/all_subdomains.txt"
    echo ""
    echo "[*] Alive Subdomains:"
    cat "$output_dir/alive_subdomains.txt"
    echo ""
    echo "[*] Open Ports Summary:"
    grep -H "open" "$output_dir/nmap_scans/"* | sed 's/^/    /'
} > "$output_dir/summary.txt"

echo "[+] Done. All outputs saved in '$output_dir/'"
