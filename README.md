# Tesla Recon Automation Tool

A simple Bash script that automates reconnaissance on `tesla.com`. It performs subdomain enumeration, checks for alive domains, and scans them for open ports.

---

## Features

- Subdomain discovery using Subfinder and Assetfinder
- Alive domain detection using Httprobe
- Fast port scanning with Nmap
- Saves all results in a clean folder structure
- Generates a summary file for quick review

---

## Requirements

Install the following tools before running the script:

### Install Go and Tools

```bash
sudo apt install golang -y

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/httprobe@latest
```

Add Go binaries to PATH:

```bash
echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Install Nmap

```bash
sudo apt install nmap -y
```

---

## Usage

```bash
chmod +x recorn.sh
./recorn.sh
```

---

## Output

All scan results are stored in a folder named `tesla/`. It contains:

- `subdomains_subfinder.txt` — Subdomains from Subfinder  
- `subdomains_assetfinder.txt` — Subdomains from Assetfinder  
- `all_subdomains.txt` — Merged subdomains  
- `cleaned_subs.txt` — Cleaned entries (no http/https)  
- `alive_subdomains.txt` — Subdomains that are alive  
- `nmap_scans/` — Folder with Nmap output per domain  
- `summary.txt` — Final report of alive hosts and open ports  

---

## Notes

- Script is optimized for fast execution.
- Best run in Kali Linux or any Debian-based distro.
- Internet connection is required.