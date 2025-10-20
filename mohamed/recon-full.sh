#!/usr/bin/env bash
# recon-full.sh
# جامع Subdomains + Live check + Historical URLs pipeline (supports single domain, wildcard like *.example.com, or file of targets)
# Usage:
#   ./recon-full.sh example.com
#   ./recon-full.sh *.example.com
#   ./recon-full.sh -f targets.txt
#
# Requirements (install these and make sure in PATH):
# subfinder, assetfinder, amass, sublist3r, httpx, gau, waybackurls, anew, wget, curl, jq
#
# Author: ChatGPT (user provided explicit permission)
set -euo pipefail
IFS=$'\n\t'

##########################
# Config (عدل القيم هنا)
##########################
HTTPX_THREADS=30
HTTPX_TIMEOUT=8
GAU_CONCURRENCY=8
AMASS_ACTIVE=false   # true => amass active enum (مزيد من الزيارات)
TOP_HEADERS=30       # عدد الـ hosts اللي نجلب عنها headers
WGET_MIRROR=false    # false افتراضيًا (تأثير عالي) — فعّل لو متأكد
RESULTS_BASE="results"
DATESTAMP=$(date +%Y%m%d-%H%M%S)

# Tool names (غير إذا الأدوات في مسارات مختلفة)
SUBFINDER_BIN="subfinder"
ASSETFINDER_BIN="assetfinder"
AMASS_BIN="amass"
SUBLIST3R_BIN="sublist3r"
HTTPX_BIN="httpx"
GAU_BIN="gau"
WAYBACK_BIN="waybackurls"
ANEW_BIN="anew"
WGET_BIN="wget"
CURL_BIN="curl"
JQ_BIN="jq"

##########################
# Helpers
##########################
usage() {
  cat <<EOF
Usage:
  $0 domain.com
  $0 *.domain.com
  $0 -f targets.txt

Examples:
  $0 example.com
  $0 *.example.com
  $0 -f mytargets.txt
