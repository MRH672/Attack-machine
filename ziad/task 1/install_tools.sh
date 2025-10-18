#!/bin/bash

# =============================================================================
# سكريبت التثبيت التلقائي لأدوات Subdomain Enumeration
# Auto Installation Script for Subdomain Enumeration Tools
# =============================================================================

set -euo pipefail

# === إعدادات الألوان ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === دالة عرض الحالة ===
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

# === دالة عرض البانر ===
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
    ║              Subdomain Tools Auto Installer                  ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأمر ===
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# === دالة التحقق من الصلاحيات ===
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_status "ERROR" "This script must be run as root!"
        print_status "INFO" "Use: sudo $0"
        exit 1
    fi
}

# === دالة تحديث النظام ===
update_system() {
    print_status "STEP" "Updating system packages..."
    
    apt-get update -qq
    print_status "SUCCESS" "System packages updated"
}

# === دالة تثبيت المتطلبات الأساسية ===
install_dependencies() {
    print_status "STEP" "Installing basic dependencies..."
    
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

# === دالة تثبيت أداة Go ===
install_go_tool() {
    local tool_name="$1"
    local tool_path="$2"
    local binary_name="${3:-$tool_name}"
    
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

# === دالة تثبيت Sublist3r ===
install_sublist3r() {
    print_status "INFO" "Installing Sublist3r..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local original_dir=$(pwd)
    
    cd "$temp_dir"
    
    # Clone repository
    if git clone "https://github.com/aboul3la/Sublist3r.git" . >/dev/null 2>&1; then
        # Install requirements
        if [ -f "requirements.txt" ]; then
            pip3 install -r requirements.txt >/dev/null 2>&1
        fi
        
        # Copy script to /usr/local/bin
        if [ -f "sublist3r.py" ]; then
            cp "sublist3r.py" "/usr/local/bin/"
            chmod +x "/usr/local/bin/sublist3r.py"
            print_status "SUCCESS" "Sublist3r installed successfully"
        else
            print_status "ERROR" "Sublist3r script not found"
            return 1
        fi
    else
        print_status "ERROR" "Failed to clone Sublist3r repository"
        return 1
    fi
    
    # Return to original directory and cleanup
    cd "$original_dir"
    rm -rf "$temp_dir"
}

# === دالة تثبيت جميع الأدوات ===
install_all_tools() {
    print_status "STEP" "Installing subdomain enumeration tools..."
    
    # Go tools
    print_status "INFO" "Installing Go-based tools..."
    install_go_tool "subfinder" "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"
    install_go_tool "httpx" "github.com/projectdiscovery/httpx/cmd/httpx"
    install_go_tool "anew" "github.com/tomnomnom/anew"
    install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"
    install_go_tool "gau" "github.com/lc/gau/v2/cmd/gau"
    
    # Python tools
    print_status "INFO" "Installing Python-based tools..."
    install_sublist3r
    
    # Binary tools (Amass)
    print_status "INFO" "Installing Amass..."
    local release_info=$(curl -s "https://api.github.com/repos/OWASP/Amass/releases/latest")
    local download_url=$(echo "$release_info" | grep "browser_download_url.*linux_amd64.zip" | cut -d '"' -f 4 | head -1)
    
    if [ -n "$download_url" ]; then
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        if wget -q "$download_url"; then
            unzip -q *.zip
            local binary_path=$(find . -name "amass" -type f | head -1)
            if [ -n "$binary_path" ]; then
                cp "$binary_path" "/usr/local/bin/"
                chmod +x "/usr/local/bin/amass"
                print_status "SUCCESS" "Amass installed successfully"
            fi
        fi
        
        cd /
        rm -rf "$temp_dir"
    fi
}

# === دالة التحقق من التثبيت ===
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
        return 0
    else
        print_status "WARNING" "Some tools failed to install"
        return 1
    fi
}

# === دالة إنشاء سكريبتات الاختبار ===
create_test_scripts() {
    print_status "STEP" "Creating test scripts..."
    
    # Create test scripts for each tool
    cat > "test_all_tools.sh" << 'EOF'
#!/bin/bash
echo "=== Testing All Tools ==="
echo "Testing subfinder..."
subfinder -d example.com -silent | head -5
echo "Testing assetfinder..."
assetfinder --subs-only example.com | head -5
echo "Testing httpx..."
echo "http://example.com" | httpx -silent
echo "Testing gau..."
gau example.com | head -5
echo "Testing waybackurls..."
waybackurls example.com | head -5
echo "Testing anew..."
echo -e "test1.com\ntest2.com" | anew
echo "Testing amass..."
amass enum -d example.com -silent | head -5
echo "Testing sublist3r..."
python3 /usr/local/bin/sublist3r.py -d example.com -o test.txt
echo "All tests completed!"
EOF
    
    chmod +x "test_all_tools.sh"
    print_status "SUCCESS" "Test scripts created"
}

# === الدالة الرئيسية ===
main() {
    show_banner
    
    # Check if running as root
    check_root
    
    # Update system
    update_system
    
    # Install dependencies
    install_dependencies
    
    # Install all tools
    install_all_tools
    
    # Verify installations
    if verify_installations; then
        print_status "SUCCESS" "Installation completed successfully!"
        
        # Create test scripts
        create_test_scripts
        
        echo
        print_status "INFO" "You can now use these tools:"
        echo -e "  ${CYAN}subfinder -d example.com${NC}"
        echo -e "  ${CYAN}assetfinder --subs-only example.com${NC}"
        echo -e "  ${CYAN}httpx -l subdomains.txt${NC}"
        echo -e "  ${CYAN}amass enum -d example.com${NC}"
        echo -e "  ${CYAN}sublist3r.py -d example.com${NC}"
        echo
        print_status "INFO" "Run './test_all_tools.sh' to test all tools"
    else
        print_status "ERROR" "Installation failed. Please check the errors above."
        exit 1
    fi
}

# === تشغيل الدالة الرئيسية ===
main "$@"
