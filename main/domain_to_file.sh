#!/usr/bin/env bash

set -euo pipefail

# === إعدادات الألوان ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === Colored output function ===
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "STEP") echo -e "${PURPLE}[STEP]${NC} $message" ;;
    esac
}

# === Banner display function ===
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║           ███╗   ███╗██████╗  ██╗  ██╗                ║
    ║           ████╗ ████║██╔══██╗ ██║  ██║                ║
    ║           ██╔████╔██║██████╔╝ ███████║                ║
    ║           ██║╚██╔╝██║██╔══██╗ ██║  ██║                ║
    ║           ██║ ╚═╝ ██║██║  ██║ ██║  ██║                ║
    ║           ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═╝  ╚═╝                ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === Usage display function ===
show_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0"
    echo
    echo -e "${YELLOW}How to use:${NC}"
    echo -e "  1. Run the script: $0"
    echo -e "  2. Enter domain when asked"
    echo -e "  3. File will be created automatically"
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0"
    echo -e "  > zdev.net"
    echo -e "  > example.com"
    echo -e "  > subdomain.example.com"
    echo
    echo -e "${YELLOW}Description:${NC}"
    echo -e "  Converts domain or subdomain to text file with same name"
    echo -e "  Example: zdev.net → zdev.txt"
}

# === Domain name extraction function ===
extract_domain_name() {
    local domain="$1"
    # Remove protocol if present
    domain="${domain#http://}"
    domain="${domain#https://}"
    domain="${domain#www.}"
    
    # Extract first part before dot
    local domain_name="${domain%%.*}"
    echo "$domain_name"
}

# === File creation function ===
create_domain_file() {
    local domain="$1"
    local domain_name=$(extract_domain_name "$domain")
    local output_file="${domain_name}.txt"
    
    print_status "INFO" "Input domain: $domain"
    print_status "INFO" "Output file: $output_file"
    
    # Create file
    if [ -f "$output_file" ]; then
        print_status "WARNING" "File $output_file already exists"
        read -p "Do you want to replace it? (y/n): " replace
        if [[ "$replace" =~ ^[Yy]$ ]]; then
            rm -f "$output_file"
            print_status "INFO" "Old file deleted"
        else
            print_status "INFO" "Operation cancelled"
            exit 0
        fi
    fi
    
    # Create empty file
    touch "$output_file"
}

# === Main function ===
main() {
    show_banner
    
    # Ask user for domain input
    echo -e "${YELLOW}Enter domain or subdomain:${NC}"
    read -p "> " domain
    
    # Check if user entered something
    if [ -z "$domain" ]; then
        print_status "ERROR" "No domain entered"
        print_status "INFO" "Please enter a valid domain"
        exit 1
    fi
    
    # Check domain format
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_status "ERROR" "Invalid domain format: $domain"
        print_status "INFO" "Make sure domain has dot and valid extension"
        print_status "INFO" "Example: example.com or subdomain.example.com"
        exit 1
    fi
    
    # Create file
    create_domain_file "$domain"
}

# === Run main function ===
main
