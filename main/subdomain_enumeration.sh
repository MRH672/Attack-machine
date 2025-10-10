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
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║    ███████╗██╗   ██╗██████╗ ██████╗  ██████╗ ███╗   ███╗    ║
    ║    ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔═══██╗████╗ ████║    ║
    ║    ███████╗██║   ██║██║  ██║██████╔╝██║   ██║██╔████╔██║    ║
    ║    ╚════██║██║   ██║██║  ██║██╔══██╗██║   ██║██║╚██╔╝██║    ║
    ║    ███████║╚██████╔╝██████╔╝██║  ██║╚██████╔╝██║ ╚═╝ ██║    ║
    ║    ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝    ║
    ║                                                              ║
    ║              Subdomain Enumeration Tool                      ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === Check if command exists ===
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# === Check if running as root ===
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_status "ERROR" "This script must be run as root!"
        print_status "INFO" "Use: sudo $0"
        exit 1
    fi
}

# === Remove Kali httpx ===
remove_kali_httpx() {
    print_status "STEP" "Checking and removing Kali httpx package..."
    
    # Check if httpx is installed via apt
    if dpkg -l | grep -q "^ii.*httpx "; then
        print_status "INFO" "Removing httpx package from Kali repositories..."
        apt-get remove -y httpx >/dev/null 2>&1
        apt-get purge -y httpx >/dev/null 2>&1
        print_status "SUCCESS" "Kali httpx package removed"
    else
        print_status "INFO" "No httpx package found in Kali repositories"
    fi
    
    # Remove any existing httpx binaries only if they exist
    if [ -f "/usr/bin/httpx" ] || [ -f "/usr/local/bin/httpx" ]; then
        rm -f "/usr/bin/httpx" 2>/dev/null || true
        rm -f "/usr/local/bin/httpx" 2>/dev/null || true
        print_status "SUCCESS" "Existing httpx binaries removed"
    else
        print_status "INFO" "No existing httpx binaries found"
    fi
}

# === Install system dependencies ===
install_dependencies() {
    print_status "STEP" "Installing system dependencies..."
    
    # Update package list
    apt-get update -qq
    
    # Install required packages
    local packages=(
        "git"
        "curl"
        "wget"
        "unzip"
        "build-essential"
        "golang-go"
        "python3"
        "python3-pip"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$package "; then
            print_status "INFO" "Installing $package..."
            apt-get install -y "$package" >/dev/null 2>&1
        else
            print_status "SUCCESS" "$package already installed"
        fi
    done
}

# === Install Go tool ===
install_go_tool() {
    local tool_name="$1"
    local tool_path="$2"
    local binary_name="${3:-$tool_name}"
    local force_install="${4:-false}"
    
    # Check if tool exists and is not httpx (httpx needs special handling)
    if command_exists "$binary_name" && [ "$force_install" != "true" ]; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi
    
    # Only remove existing installation for httpx (force install)
    if [ "$force_install" = "true" ] && command_exists "$binary_name" && [ "$tool_name" = "httpx" ]; then
        print_status "INFO" "Removing existing $tool_name installation..."
        apt-get remove -y "$binary_name" 2>/dev/null || true
        rm -f "/usr/bin/$binary_name" 2>/dev/null || true
        rm -f "/usr/local/bin/$binary_name" 2>/dev/null || true
    fi
    
    print_status "INFO" "Installing $tool_name..."
    
    # Set GOPATH if not set
    export GOPATH="${GOPATH:-$HOME/go}"
    export PATH="$PATH:$GOPATH/bin"
    
    # Install the tool
    if go install "$tool_path@latest" >/dev/null 2>&1; then
        # Copy to /usr/local/bin
        if [ -f "$GOPATH/bin/$binary_name" ]; then
            cp "$GOPATH/bin/$binary_name" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$binary_name"
            print_status "SUCCESS" "$tool_name installed successfully"
        else
            print_status "ERROR" "Failed to find $binary_name binary"
            return 1
        fi
    else
        print_status "ERROR" "Failed to install $tool_name"
        return 1
    fi
}

# === Install Python tool from GitHub ===
install_python_tool() {
    local tool_name="$1"
    local repo="$2"
    local script_name="$3"
    
    # Check if tool exists
    if command_exists "$script_name"; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi
    
    print_status "INFO" "Installing $tool_name..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local original_dir=$(pwd)
    
    # Change to temp directory
    cd "$temp_dir" || {
        print_status "ERROR" "Failed to change to temp directory"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Clone repository with timeout
    print_status "INFO" "Cloning repository: $repo"
    if timeout 300 git clone "https://github.com/$repo" . >/dev/null 2>&1; then
        print_status "SUCCESS" "Repository cloned successfully"
        
        # Install requirements if exists
        if [ -f "requirements.txt" ]; then
            print_status "INFO" "Installing Python requirements..."
            pip3 install -r requirements.txt >/dev/null 2>&1 || {
                print_status "WARNING" "Some requirements failed to install, continuing..."
            }
        fi
        
        # Copy script to /usr/local/bin
        if [ -f "$script_name" ]; then
            cp "$script_name" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$script_name"
            print_status "SUCCESS" "$tool_name installed successfully"
        else
            print_status "ERROR" "Script $script_name not found in repository"
            cd "$original_dir"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_status "ERROR" "Failed to clone $tool_name repository (timeout or network issue)"
        cd "$original_dir"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Return to original directory and cleanup
    cd "$original_dir"
    rm -rf "$temp_dir"
}

# === Install binary from GitHub releases ===
install_binary_tool() {
    local tool_name="$1"
    local repo="$2"
    local binary_name="$3"
    local asset_pattern="$4"
    
    # Check if tool exists
    if command_exists "$binary_name"; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi
    
    print_status "INFO" "Installing $tool_name..."
    
    # Get latest release info
    local release_info=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
    local download_url=$(echo "$release_info" | grep "browser_download_url.*$asset_pattern" | cut -d '"' -f 4 | head -1)
    
    if [ -z "$download_url" ]; then
        print_status "ERROR" "Could not find download URL for $tool_name"
        return 1
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download and extract
    local filename=$(basename "$download_url")
    if wget -q "$download_url"; then
        if [[ "$filename" == *.zip ]]; then
            unzip -q "$filename"
        elif [[ "$filename" == *.tar.gz ]]; then
            tar -xzf "$filename"
        fi
        
        # Find and copy binary
        local binary_path=$(find . -name "$binary_name" -type f | head -1)
        if [ -n "$binary_path" ]; then
            cp "$binary_path" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$binary_name"
            print_status "SUCCESS" "$tool_name installed successfully"
        else
            print_status "ERROR" "Binary $binary_name not found in archive"
            return 1
        fi
    else
        print_status "ERROR" "Failed to download $tool_name"
        return 1
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
}

# === Check existing tools ===
check_existing_tools() {
    print_status "STEP" "Checking existing subdomain enumeration tools..."
    
    local tools=(
        "subfinder"
        "assetfinder"
        "httpx"
        "anew"
        "waybackurls"
        "gau"
        "sublist3r.py"
        "amass"
    )
    
    local existing_tools=()
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            existing_tools+=("$tool")
            print_status "SUCCESS" "$tool is already installed"
        else
            missing_tools+=("$tool")
            print_status "INFO" "$tool is not installed"
        fi
    done
    
    echo
    print_status "INFO" "Found ${#existing_tools[@]} existing tools"
    print_status "INFO" "Need to install ${#missing_tools[@]} tools"
    echo
    
    if [ ${#existing_tools[@]} -eq ${#tools[@]} ]; then
        print_status "SUCCESS" "All tools are already installed!"
        return 1  # All tools exist, no need to install
    fi
    
    return 0  # Some tools missing, need to install
}

# === Install missing tools ===
install_missing_tools() {
    print_status "STEP" "Installing missing subdomain enumeration tools..."
    
    # Remove Kali httpx first (only if httpx needs to be installed)
    remove_kali_httpx
    
    # Install dependencies
    install_dependencies
    
    # Go tools
    print_status "INFO" "Installing Go-based tools..."
    install_go_tool "subfinder" "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"
    install_go_tool "httpx" "github.com/projectdiscovery/httpx/cmd/httpx" "httpx" "true"
    install_go_tool "anew" "github.com/tomnomnom/anew"
    install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"
    install_go_tool "gau" "github.com/lc/gau/v2/cmd/gau"
    
    # Python tools
    print_status "INFO" "Installing Python-based tools..."
    if ! install_python_tool "Sublist3r" "aboul3la/Sublist3r" "sublist3r.py"; then
        print_status "WARNING" "Sublist3r installation failed, continuing without it..."
        print_status "INFO" "You can install it manually later if needed"
    fi
    
    # Binary tools
    print_status "INFO" "Installing binary tools..."
    install_binary_tool "amass" "OWASP/Amass" "amass" "linux_amd64.zip"
    
    print_status "SUCCESS" "Tool installation phase completed!"
}

# === Verify installations ===
verify_installations() {
    print_status "STEP" "Verifying installations..."
    
    local essential_tools=(
        "subfinder"
        "assetfinder"
        "httpx"
        "amass"
    )
    
    local optional_tools=(
        "anew"
        "waybackurls"
        "gau"
        "sublist3r.py"
    )
    
    local essential_available=true
    local available_tools=()
    
    # Check essential tools
    for tool in "${essential_tools[@]}"; do
        if command_exists "$tool"; then
            print_status "SUCCESS" "$tool is available"
            available_tools+=("$tool")
        else
            print_status "ERROR" "$tool is not available (ESSENTIAL)"
            essential_available=false
        fi
    done
    
    # Check optional tools
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            print_status "SUCCESS" "$tool is available"
            available_tools+=("$tool")
        else
            print_status "WARNING" "$tool is not available (OPTIONAL)"
        fi
    done
    
    if [ "$essential_available" = true ]; then
        print_status "SUCCESS" "Essential tools are ready! (${#available_tools[@]} tools available)"
        return 0
    else
        print_status "ERROR" "Some essential tools are missing. Cannot proceed."
        return 1
    fi
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

# === Get domain input from user ===
get_domain_input() {
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
    
    echo "$domain"
}

# === Run subdomain enumeration tools ===
run_enumeration_tools() {
    local domain="$1"
    local domain_name=$(extract_domain_name "$domain")
    local output_file="${domain_name}_subdomains.txt"
    local temp_dir=$(mktemp -d)
    
    print_status "STEP" "Starting subdomain enumeration for: $domain"
    print_status "INFO" "Output file: $output_file"
    
    # Create or clear output file
    > "$output_file"
    
    # Run subfinder
    print_status "INFO" "Running subfinder..."
    if timeout 300 subfinder -d "$domain" -silent > "$temp_dir/subfinder.txt" 2>/dev/null; then
        cat "$temp_dir/subfinder.txt" >> "$output_file"
        print_status "SUCCESS" "subfinder completed: $(wc -l < "$temp_dir/subfinder.txt") subdomains"
    else
        print_status "WARNING" "subfinder failed or timed out"
    fi
    
    # Run assetfinder
    print_status "INFO" "Running assetfinder..."
    if timeout 180 assetfinder --subs-only "$domain" > "$temp_dir/assetfinder.txt" 2>/dev/null; then
        cat "$temp_dir/assetfinder.txt" >> "$output_file"
        print_status "SUCCESS" "assetfinder completed: $(wc -l < "$temp_dir/assetfinder.txt") subdomains"
    else
        print_status "WARNING" "assetfinder failed or timed out"
    fi
    
    # Run amass
    print_status "INFO" "Running amass..."
    if timeout 600 amass enum -d "$domain" -silent > "$temp_dir/amass.txt" 2>/dev/null; then
        cat "$temp_dir/amass.txt" >> "$output_file"
        print_status "SUCCESS" "amass completed: $(wc -l < "$temp_dir/amass.txt") subdomains"
    else
        print_status "WARNING" "amass failed or timed out"
    fi
    
    # Run sublist3r (if available)
    if command_exists "sublist3r.py"; then
        print_status "INFO" "Running sublist3r..."
        if timeout 300 python3 /usr/local/bin/sublist3r.py -d "$domain" -o "$temp_dir/sublist3r.txt" >/dev/null 2>&1; then
            if [ -f "$temp_dir/sublist3r.txt" ]; then
                cat "$temp_dir/sublist3r.txt" >> "$output_file"
                print_status "SUCCESS" "sublist3r completed: $(wc -l < "$temp_dir/sublist3r.txt") subdomains"
            else
                print_status "WARNING" "sublist3r produced no output"
            fi
        else
            print_status "WARNING" "sublist3r failed or timed out"
        fi
    else
        print_status "INFO" "Skipping sublist3r (not available)"
    fi
    
    # Remove duplicates and sort
    print_status "INFO" "Removing duplicates and sorting..."
    sort -u "$output_file" > "$temp_dir/final.txt"
    mv "$temp_dir/final.txt" "$output_file"
    
    # Get final count
    local final_count=$(wc -l < "$output_file")
    
    # Cleanup temp directory
    rm -rf "$temp_dir"
    
    print_status "SUCCESS" "Enumeration completed!"
    print_status "SUCCESS" "Total unique subdomains found: $final_count"
    print_status "INFO" "Results saved to: $output_file"
    
    # Show some examples
    if [ "$final_count" -gt 0 ]; then
        echo
        print_status "INFO" "Sample subdomains found:"
        head -5 "$output_file" | while read -r subdomain; do
            echo -e "  ${CYAN}$subdomain${NC}"
        done
        if [ "$final_count" -gt 5 ]; then
            echo -e "  ${CYAN}... and $((final_count - 5)) more${NC}"
        fi
    fi
    
    return 0
}

# === Main function ===
main() {
    show_banner
    
    # Check if running as root
    check_root
    
    # Step 1: Check existing tools
    if ! check_existing_tools; then
        # All tools exist, just verify
        if ! verify_installations; then
            exit 1
        fi
    else
        # Some tools missing, install them
        install_missing_tools
        if ! verify_installations; then
            exit 1
        fi
    fi
    
    echo
    print_status "SUCCESS" "Essential tools are ready for subdomain enumeration!"
    print_status "INFO" "Proceeding with domain input..."
    echo
    
    # Step 2: Get domain input from user
    domain=$(get_domain_input)
    
    # Step 3: Run enumeration tools
    run_enumeration_tools "$domain"
    
    echo
    print_status "SUCCESS" "Subdomain enumeration completed successfully!"
}

# === Run main function ===
main "$@"
