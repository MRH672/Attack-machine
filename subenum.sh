#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage: subenum.sh [-d DOMAIN|-f FILE] [-o OUTDIR] [--httpx-codes CODES] [--no-resolve]

Description:
  Enumerate subdomains using subfinder and assetfinder, deduplicate, optionally
  resolve/probe with httpx, and write organized outputs.

Options:
  -d, --domain DOMAIN     Single root domain or wildcard (e.g. example.com)
  -f, --file FILE         File path containing a list of domains (one per line)
  -o, --out OUTDIR        Output directory (default: ./output)
      --httpx-codes CODES Comma-separated status codes to keep (default: 200)
      --no-resolve        Skip httpx probing (only produce subdomain lists)
  -h, --help              Show this help

Dependencies:
  Requires: subfinder, assetfinder, anew, httpx (unless --no-resolve)
EOF
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

require_cmd() {
    local cmd="$1"
    local hint="$2"
    if ! command_exists "$cmd"; then
        echo "Error: required command '$cmd' not found. $hint" >&2
        exit 1
    fi
}

INPUT_DOMAIN=""
INPUT_FILE=""
OUTDIR="output"
HTTPCODES="200"
DO_HTTPX=1

ARGS=("$@")
i=0
while [ $i -lt ${#ARGS[@]} ]; do
    case "${ARGS[$i]}" in
        -d|--domain)
            i=$((i+1)); INPUT_DOMAIN="${ARGS[$i]:-}" ;;
        -f|--file)
            i=$((i+1)); INPUT_FILE="${ARGS[$i]:-}" ;;
        -o|--out)
            i=$((i+1)); OUTDIR="${ARGS[$i]:-}" ;;
        --httpx-codes)
            i=$((i+1)); HTTPCODES="${ARGS[$i]:-}" ;;
        --no-resolve)
            DO_HTTPX=0 ;;
        -h|--help)
            print_usage; exit 0 ;;
        *)
            echo "Unknown option: ${ARGS[$i]}" >&2
            print_usage; exit 1 ;;
    esac
    i=$((i+1))
done

if [ -z "$INPUT_DOMAIN" ] && [ -z "$INPUT_FILE" ]; then
    echo "Error: specify either --domain or --file" >&2
    print_usage
    exit 1
fi

if [ -n "$INPUT_DOMAIN" ] && [ -n "$INPUT_FILE" ]; then
    echo "Error: use only one of --domain or --file" >&2
    exit 1
fi

require_cmd subfinder "Install: https://github.com/projectdiscovery/subfinder"
require_cmd assetfinder "Install: go install github.com/tomnomnom/assetfinder@latest"
require_cmd anew "Install: go install github.com/tomnomnom/anew@latest"
if [ $DO_HTTPX -eq 1 ]; then
    require_cmd httpx "Install: https://github.com/projectdiscovery/httpx"
fi

mkdir -p "$OUTDIR"

timestamp() { date +"%Y%m%d-%H%M%S"; }

domains_file=""
if [ -n "$INPUT_FILE" ]; then
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: file not found: $INPUT_FILE" >&2
        exit 1
    fi
    domains_file="$INPUT_FILE"
else
    domains_file="$(mktemp)"
    printf "%s\n" "$INPUT_DOMAIN" > "$domains_file"
fi

SUBS_COMBINED="$OUTDIR/subs_all.txt"
SUBS_DEDUP="$OUTDIR/subs_unique.txt"
HTTPOUT="$OUTDIR/httpx.txt"
RUN_ID="$(timestamp)"

touch "$SUBS_COMBINED" "$SUBS_DEDUP"

while IFS= read -r domain || [ -n "$domain" ]; do
    [ -z "$domain" ] && continue
    tmpdir="$(mktemp -d)"
    subs_subfinder="$tmpdir/subfinder.txt"
    subs_assetfinder="$tmpdir/assetfinder.txt"

    subfinder -d "$domain" -all -silent > "$subs_subfinder" || true
    echo "$domain" | assetfinder --subs-only > "$subs_assetfinder" || true

    cat "$subs_subfinder" "$subs_assetfinder" | anew "$SUBS_COMBINED" >/dev/null
    rm -rf "$tmpdir"
done < "$domains_file"

sort -u "$SUBS_COMBINED" > "$SUBS_DEDUP"

if [ $DO_HTTPX -eq 1 ]; then
    < "$SUBS_DEDUP" httpx -silent -status-code -fc "$HTTPCODES" -o "$HTTPOUT"
    echo "Done. Outputs:"
    echo "  All subs:     $SUBS_COMBINED"
    echo "  Unique subs:  $SUBS_DEDUP"
    echo "  httpx result: $HTTPOUT (filtered codes: $HTTPCODES)"
else
    echo "Done. Outputs:"
    echo "  All subs:     $SUBS_COMBINED"
    echo "  Unique subs:  $SUBS_DEDUP"
fi

if [ -z "$INPUT_FILE" ]; then
    rm -f "$domains_file"
fi
