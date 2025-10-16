#!/usr/bin/env bash

set -euo pipefail

# === Color settings ===
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
    ║              Subdomain Tools Installer                       ║
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
    cd "$temp_dir"
    
    # Clone repository
    if git clone "https://github.com/$repo" . >/dev/null 2>&1; then
        # Install requirements if exists
        if [ -f "requirements.txt" ]; then
            pip3 install -r requirements.txt >/dev/null 2>&1
        fi
        
        # Copy script to /usr/local/bin
        if [ -f "$script_name" ]; then
            cp "$script_name" "/usr/local/bin/"
            chmod +x "/usr/local/bin/$script_name"
            print_status "SUCCESS" "$tool_name installed successfully"
        else
            print_status "ERROR" "Script $script_name not found in repository"
            return 1
        fi
    else
        print_status "ERROR" "Failed to clone $tool_name repository"
        return 1
    fi
    
    # Cleanup
    cd /
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

# === Main installation function ===
install_tools() {
    print_status "STEP" "Installing missing subdomain enumeration tools..."
    
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
    install_python_tool "Sublist3r" "aboul3la/Sublist3r" "sublist3r.py"
    
    # Binary tools
    print_status "INFO" "Installing binary tools..."
    install_binary_tool "amass" "OWASP/Amass" "amass" "linux_amd64.zip"
}

# === Verify installations ===
verify_installations() {
    print_status "STEP" "Verifying installations..."
    
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
        print_status "INFO" "You can now use these tools:"
        echo -e "  ${CYAN}subfinder -d example.com${NC}"
        echo -e "  ${CYAN}assetfinder --subs-only example.com${NC}"
        echo -e "  ${CYAN}httpx -l subdomains.txt${NC}"
        echo -e "  ${CYAN}amass enum -d example.com${NC}"
        echo -e "  ${CYAN}sublist3r.py -d example.com${NC}"
    else
        print_status "WARNING" "Some tools failed to install"
        exit 1
    fi
}

# === Main function ===
main() {
    show_banner
    
    # Check if running as root
    check_root
    
    # Check existing tools first
    if ! check_existing_tools; then
        # All tools exist, just verify and exit
        verify_installations
        echo
        print_status "SUCCESS" "All tools are already installed and working!"
        exit 0
    fi
    
    # Remove Kali httpx first (only if httpx needs to be installed)
    remove_kali_httpx
    
    # Install dependencies
    install_dependencies
    
    # Install missing tools
    install_tools
    
    # Verify installations
    verify_installations
    
    echo
    print_status "SUCCESS" "Installation completed!"
}

# === Run main function ===
main "$@"