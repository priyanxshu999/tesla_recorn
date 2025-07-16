#!/bin/bash

# 10B# Tobo is a red teamer and the team captain asked Tobo to create an automated recon tool in bash
# which can scan tesla.com and dump the scan results in a separate folder named tesla.

# Tools used:
# a) Subfinder & Assetfinder - for finding subdomains (fast)
# b) Httprobe - to check if subdomains are alive
# c) Nmap - to scan live subdomains

domain="tesla.com"
output_dir="tesla"

echo "[+] Creating output directory: $output_dir"
mkdir -p "$output_dir"

# Step 1: Subdomain Enumeration
echo "[+] Step 1: Enumerating subdomains with Subfinder & Assetfinder..."
subfinder -d "$domain" -silent > "$output_dir/subdomains_subfinder.txt"
if [ -x "$HOME/go/bin/assetfinder" ]; then
    "$HOME/go/bin/assetfinder" --subs-only "$domain" > "$output_dir/subdomains_assetfinder.txt"
else
    echo "[-] assetfinder not found. Skipping assetfinder subdomains..."
    touch "$output_dir/subdomains_assetfinder.txt"
fi

# Step 2: Merge and Clean
echo "[+] Step 2: Merging and cleaning subdomains..."
cat "$output_dir"/subdomains_*.txt | sort -u > "$output_dir/all_subdomains.txt"
cat "$output_dir/all_subdomains.txt" | sed 's|http[s]*://||g' | sort -u > "$output_dir/cleaned_subs.txt"

# Step 3: Alive Check
echo "[+] Step 3: Probing for alive domains with Httprobe..."
cat "$output_dir/cleaned_subs.txt" | httprobe | sort -u > "$output_dir/alive_subdomains.txt"

# Step 4: Fast Parallel Nmap Scanning
echo "[+] Step 4: Parallel Nmap scan (fast mode)..."
cat "$output_dir/alive_subdomains.txt" | sed 's|http[s]*://||g' | xargs -P10 -I {} sh -c '
    echo "[*] Scanning: {}"
    nmap -Pn -n -T5 -F {} -oN '"$output_dir"'/nmap_{}.txt > /dev/null 2>&1
'

echo "[+] ✅ Recon Complete. All results saved to $output_dir/"
