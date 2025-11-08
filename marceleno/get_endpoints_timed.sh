#!/usr/bin/env zsh

# === Color settings ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === Timing functions ===
start_timer() {
    echo $(date +%s)
}

end_timer() {
    local start_time=$1
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo $duration
}

format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%02d:%02d:%02d" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%02d:%02d" $minutes $secs
    else
        printf "%02d seconds" $secs
    fi
}

print_status() {
    local type=$1
    local message=$2
    case $type in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "====================================================="
    echo "  Advanced Subdomain & Endpoint Discovery Tool"
    echo "  With Complete Timing Metrics"
    echo "====================================================="
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
    print_status "INFO" "Checking and removing Kali httpx package..."
    local step_start=$(start_timer)

    if dpkg -l | grep -q "^ii.*httpx "; then
        print_status "INFO" "Removing httpx package from Kali repositories..."
        apt-get remove -y httpx >/dev/null 2>&1
        apt-get purge -y httpx >/dev/null 2>&1
        print_status "SUCCESS" "Kali httpx package removed"
    else
        print_status "INFO" "No httpx package found in Kali repositories"
    fi

    if [ -f "/usr/bin/httpx" ] || [ -f "/usr/local/bin/httpx" ]; then
        rm -f "/usr/bin/httpx" 2>/dev/null || true
        rm -f "/usr/local/bin/httpx" 2>/dev/null || true
        print_status "SUCCESS" "Existing httpx binaries removed"
    else
        print_status "INFO" "No existing httpx binaries found"
    fi
    
    local duration=$(end_timer $step_start)
    print_status "INFO" "Time taken: $(format_time $duration)"
}

# === Install system dependencies ===
install_dependencies() {
    print_status "INFO" "Installing system dependencies..."
    local step_start=$(start_timer)

    apt-get update -qq

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
    
    local duration=$(end_timer $step_start)
    print_status "SUCCESS" "Dependencies installed in $(format_time $duration)"
}

# === Install Go tool ===
install_go_tool() {
    local tool_name="$1"
    local tool_path="$2"
    local binary_name="${3:-$tool_name}"
    local force_install="${4:-false}"

    if command_exists "$binary_name" && [ "$force_install" != "true" ]; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi

    if [ "$force_install" = "true" ] && command_exists "$binary_name" && [ "$tool_name" = "httpx" ]; then
        print_status "INFO" "Removing existing $tool_name installation..."
        apt-get remove -y "$binary_name" 2>/dev/null || true
        rm -f "/usr/bin/$binary_name" 2>/dev/null || true
        rm -f "/usr/local/bin/$binary_name" 2>/dev/null || true
    fi

    print_status "INFO" "Installing $tool_name..."
    local install_start=$(start_timer)

    export GOPATH="${GOPATH:-$HOME/go}"
    export PATH="$PATH:$GOPATH/bin"

    if go install "$tool_path@latest" >/dev/null 2>&1; then
        if [ -f "$GOPATH/bin/$binary_name" ]; then
            cp "$GOPATH/bin/$binary_name" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$binary_name"
            local duration=$(end_timer $install_start)
            print_status "SUCCESS" "$tool_name installed in $(format_time $duration)"
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

    if command_exists "$script_name"; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi

    print_status "INFO" "Installing $tool_name..."
    local install_start=$(start_timer)

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    if git clone "https://github.com/$repo" . >/dev/null 2>&1; then
        if [ -f "requirements.txt" ]; then
            pip3 install -r requirements.txt >/dev/null 2>&1
        fi

        if [ -f "$script_name" ]; then
            cp "$script_name" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$script_name"
            local duration=$(end_timer $install_start)
            print_status "SUCCESS" "$tool_name installed in $(format_time $duration)"
        else
            print_status "ERROR" "Script $script_name not found in repository"
            return 1
        fi
    else
        print_status "ERROR" "Failed to clone $tool_name repository"
        return 1
    fi

    cd /
    rm -rf "$temp_dir"
}

# === Install binary from GitHub releases ===
install_binary_tool() {
    local tool_name="$1"
    local repo="$2"
    local binary_name="$3"
    local asset_pattern="$4"

    if command_exists "$binary_name"; then
        print_status "SUCCESS" "$tool_name is already installed"
        return 0
    fi

    print_status "INFO" "Installing $tool_name..."
    local install_start=$(start_timer)

    local release_info=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
    local download_url=$(echo "$release_info" | grep "browser_download_url.*$asset_pattern" | cut -d '"' -f 4 | head -1)

    if [ -z "$download_url" ]; then
        print_status "ERROR" "Could not find download URL for $tool_name"
        return 1
    fi

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    local filename=$(basename "$download_url")
    if wget -q "$download_url"; then
        if [[ "$filename" == *.zip ]]; then
            unzip -q "$filename"
        elif [[ "$filename" == *.tar.gz ]]; then
            tar -xzf "$filename"
        fi

        local binary_path=$(find . -name "$binary_name" -type f | head -1)
        if [ -n "$binary_path" ]; then
            cp "$binary_path" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$binary_name"
            local duration=$(end_timer $install_start)
            print_status "SUCCESS" "$tool_name installed in $(format_time $duration)"
        else
            print_status "ERROR" "Binary $binary_name not found in archive"
            return 1
        fi
    else
        print_status "ERROR" "Failed to download $tool_name"
        return 1
    fi

    cd /
    rm -rf "$temp_dir"
}

# === Check existing tools ===
check_existing_tools() {
    print_status "INFO" "Checking existing subdomain enumeration tools..."

    local tools=(
        "subfinder"
        "assetfinder"
        "httpx"
        "anew"
        "waybackurls"
        "gau"
        "katana"
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
        return 1
    fi

    return 0
}

# === Main installation function ===
install_tools() {
    print_status "INFO" "Installing missing subdomain enumeration tools..."
    local install_start=$(start_timer)

    print_status "INFO" "Installing Go-based tools..."
    install_go_tool "subfinder" "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"
    install_go_tool "httpx" "github.com/projectdiscovery/httpx/cmd/httpx" "httpx" "true"
    install_go_tool "anew" "github.com/tomnomnom/anew"
    install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"
    install_go_tool "gau" "github.com/lc/gau/v2/cmd/gau"
    install_go_tool "katana" "github.com/projectdiscovery/katana/cmd/katana"

    print_status "INFO" "Installing Python-based tools..."
    install_python_tool "Sublist3r" "aboul3la/Sublist3r" "sublist3r.py"

    print_status "INFO" "Installing binary tools..."
    install_binary_tool "amass" "OWASP/Amass" "amass" "linux_amd64.zip"
    
    local duration=$(end_timer $install_start)
    print_status "SUCCESS" "All tools installed in $(format_time $duration)"
}

# === Verify installations ===
verify_installations() {
    print_status "INFO" "Verifying installations..."

    local tools=(
        "subfinder"
        "assetfinder"
        "httpx"
        "anew"
        "waybackurls"
        "gau"
        "katana"
        "sublist3r.py"
        "amass"
    )

    local all_installed=true

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_status "SUCCESS" "$tool is available"
        else
            print_status "ERROR" "$tool is not available"
            all_installed=false
        fi
    done

    if [ "$all_installed" = true ]; then
        print_status "SUCCESS" "All tools installed successfully!"
        echo
    else
        print_status "WARNING" "Some tools failed to install"
        exit 1
    fi
}

get_subdomains() {
    local domain=$1
    local step_start=$(start_timer)

    print_status "INFO" "Running subfinder..."
    local subfinder_start=$(start_timer)
    local subfinder_output=$(subfinder -d "$domain" -silent)
    local subfinder_time=$(end_timer $subfinder_start)
    print_status "SUCCESS" "Subfinder found $(echo "$subfinder_output" | wc -l | tr -d ' ') subdomains in $(format_time $subfinder_time)"

    print_status "INFO" "Running assetfinder..."
    local assetfinder_start=$(start_timer)
    local assetfinder_output=$(echo "$domain" | assetfinder --subs-only)
    local assetfinder_time=$(end_timer $assetfinder_start)
    print_status "SUCCESS" "Assetfinder completed in $(format_time $assetfinder_time)"
    
    print_status "INFO" "Running amass passive..."
    local amass_start=$(start_timer)
    local amass_output=$(amass enum -passive -d "$domain" -silent 2>/dev/null)
    local amass_time=$(end_timer $amass_start)
    print_status "SUCCESS" "Amass completed in $(format_time $amass_time)"
    
    print_status "INFO" "Running sublist3r..."
    local sublist3r_start=$(start_timer)
    local sublist3r_output=$(sublist3r -d "$domain" -t 10 2>/dev/null || echo "")
    local sublist3r_time=$(end_timer $sublist3r_start)
    print_status "SUCCESS" "Sublist3r completed in $(format_time $sublist3r_time)"

    # Combine results
    local subdomains="$subfinder_output$assetfinder_output$amass_output$sublist3r_output"

    # Remove duplicates
    local anew_output=$(echo "$subdomains" | anew)
    subdomains="$anew_output"

    local step_duration=$(end_timer $step_start)
    print_status "SUCCESS" "Total subdomain enumeration time: $(format_time $step_duration)"
    
    echo "$subdomains"
}

test_subdomains(){
    local subdomains=$1
    local step_start=$(start_timer)

    local httpx_output=$(echo "$subdomains" | httpx -fc 200 -silent -threads 50)

    local step_duration=$(end_timer $step_start)
    print_status "SUCCESS" "HTTP probing completed in $(format_time $step_duration)"

    echo "$httpx_output"
}

katana_endpoints(){
    local subdomains=$1
    local step_start=$(start_timer)

    local katana_output=$(echo "$subdomains" | katana -silent -depth 3 -concurrency 20)

    local step_duration=$(end_timer $step_start)
    print_status "SUCCESS" "Katana crawling completed in $(format_time $step_duration)"

    echo "$katana_output"
}

waybackurls_endpoints(){
    local subdomains=$1
    local step_start=$(start_timer)

    local waybackurls_urls=$(echo "$subdomains" | waybackurls)

    local step_duration=$(end_timer $step_start)
    print_status "SUCCESS" "Waybackurls completed in $(format_time $step_duration)"

    echo "$waybackurls_urls"
}

gau_endpoints(){
    local subdomains=$1
    local step_start=$(start_timer)

    local gau_urls=$(echo "$subdomains" | gau --threads 5)

    local step_duration=$(end_timer $step_start)
    print_status "SUCCESS" "GAU completed in $(format_time $step_duration)"

    echo "$gau_urls"
}

# === Main function ===
main() {
    # Start overall timer
    local overall_start=$(start_timer)
    
    show_banner
    
    print_status "INFO" "Starting complete reconnaissance scan"
    echo

    # Check if running as root
    check_root

    # Check existing tools first
    if ! check_existing_tools; then
        verify_installations
        echo
        print_status "SUCCESS" "All tools are already installed and working!"
    else
        remove_kali_httpx
        install_dependencies
        install_tools
        verify_installations
        print_status "SUCCESS" "Installation completed!"
    fi

    # START GET SUBDOMAINS
    local domain=$1

    if [ -z "$domain" ]; then
        print_status "ERROR" "Domain is required"
        exit 1
    fi

    echo
    print_status "INFO" "=== Starting Active Reconnaissance ==="
    echo
    print_status "INFO" "Target Domain: $domain"
    print_status "INFO" "Starting subdomain enumeration..."
    
    local recon_start=$(start_timer)
    local subdomains=$(get_subdomains "$domain")

    if [ -z "$subdomains" ]; then
        print_status "ERROR" "No subdomains found for $domain"
        exit 1
    else
        local subdomain_count=$(echo "$subdomains" | wc -l | tr -d ' ')
        print_status "SUCCESS" "Found $subdomain_count unique subdomains!"
    fi

    echo
    print_status "INFO" "Testing subdomains with httpx..."
    local httpx_subdomains=$(test_subdomains "$subdomains")

    if [ -z "$httpx_subdomains" ]; then
        print_status "ERROR" "No working subdomains found (all returned non-200 status)"
        exit 1
    else
        local working_count=$(echo "$httpx_subdomains" | wc -l | tr -d ' ')
        print_status "SUCCESS" "Working subdomains: $working_count"
    fi

    echo
    print_status "INFO" "=== Starting Endpoint Discovery ==="
    print_status "INFO" "Getting endpoints from $working_count working subdomains..."
    print_status "WARNING" "This may take a while!"

    print_status "INFO" "Katana crawling started..."
    local katana_output=$(katana_endpoints "$httpx_subdomains")

    print_status "INFO" "Waybackurls started..."
    local waybackurls_output=$(waybackurls_endpoints "$httpx_subdomains")

    print_status "INFO" "GAU started..."
    local gau_output=$(gau_endpoints "$httpx_subdomains")

    # Combine all endpoints
    local endpoints_raw="$katana_output$waybackurls_output$gau_output"
    
    # Remove duplicates
    local endpoints=$(echo "$endpoints_raw" | anew)

    # Count endpoints
    local endpoint_count=$(echo "$endpoints" | wc -l | tr -d ' ')
    local recon_duration=$(end_timer $recon_start)
    print_status "SUCCESS" "Found $endpoint_count unique endpoints in $(format_time $recon_duration)!"

    echo
    print_status "INFO" "=== Saving Results ==="
    
    # Create output directory
    mkdir -p "$domain"
    cd "$domain"

    # Save all endpoints
    echo "$endpoints" > all_endpoints.txt
    print_status "SUCCESS" "Saved all endpoints to all_endpoints.txt"

    # Filter and save by type
    print_status "INFO" "Filtering endpoints by file type..."

    if echo "$endpoints" | grep -qE "\.js"; then
        echo "$endpoints" | grep -E "\.js" > js.txt
        local js_count=$(wc -l < js.txt | tr -d ' ')
        print_status "SUCCESS" "Saved $js_count JavaScript files to js.txt"
    fi

    if echo "$endpoints" | grep -qE "\.php"; then
        echo "$endpoints" | grep -E "\.php" > php.txt
        local php_count=$(wc -l < php.txt | tr -d ' ')
        print_status "SUCCESS" "Saved $php_count PHP files to php.txt"
    fi

    if echo "$endpoints" | grep -qE "\.json"; then
        echo "$endpoints" | grep -E "\.json" > json.txt
        local json_count=$(wc -l < json.txt | tr -d ' ')
        print_status "SUCCESS" "Saved $json_count JSON files to json.txt"
    fi

    if echo "$endpoints" | grep -qE "\.css"; then
        echo "$endpoints" | grep -E "\.css" > css.txt
        local css_count=$(wc -l < css.txt | tr -d ' ')
        print_status "SUCCESS" "Saved $css_count CSS files to css.txt"
    fi

    if echo "$endpoints" | grep -qE "\.xml"; then
        echo "$endpoints" | grep -E "\.xml" > xml.txt
        local xml_count=$(wc -l < xml.txt | tr -d ' ')
        print_status "SUCCESS" "Saved $xml_count XML files to xml.txt"
    fi

    echo
    print_status "SUCCESS" "All results saved in directory: $domain/"
    print_status "INFO" "Run 'cd $domain' to view results"
    
    # === Display Final Statistics ===
    echo
    echo -e "${CYAN}====================================================="
    echo "  FINAL STATISTICS"
    echo "=====================================================${NC}"
    
    local overall_duration=$(end_timer $overall_start)
    
    echo -e "${GREEN}✓ Total Subdomains Found:${NC} $subdomain_count"
    echo -e "${GREEN}✓ Working Subdomains:${NC} $working_count"
    echo -e "${GREEN}✓ Total Endpoints Found:${NC} $endpoint_count"
    echo -e "${YELLOW}⚡ Total Execution Time:${NC} $(format_time $overall_duration)"
    
    echo
    echo -e "${CYAN}=====================================================${NC}"
    
    # Save statistics
    cat > "$domain/statistics.txt" << EOF
=====================================================
  RECONNAISSANCE STATISTICS
=====================================================
Target Domain: $domain
Scan Date: $(date)

RESULTS:
- Total Subdomains Found: $subdomain_count
- Working Subdomains: $working_count
- Total Endpoints Found: $endpoint_count

TIMING:
- Total Execution Time: $(format_time $overall_duration)

FILES GENERATED:
- all_endpoints.txt
EOF

    [ -f js.txt ] && echo "- js.txt" >> "$domain/statistics.txt"
    [ -f php.txt ] && echo "- php.txt" >> "$domain/statistics.txt"
    [ -f json.txt ] && echo "- json.txt" >> "$domain/statistics.txt"
    [ -f css.txt ] && echo "- css.txt" >> "$domain/statistics.txt"
    [ -f xml.txt ] && echo "- xml.txt" >> "$domain/statistics.txt"
    
    echo "=====================================================" >> "$domain/statistics.txt"
    
    print_status "SUCCESS" "Statistics saved to statistics.txt"
}

# === Run main function ===
main "$@"


