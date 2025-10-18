#!/bin/bash

# =============================================================================
# Amass Test Script
# سكريبت اختبار أداة Amass
# =============================================================================

# === إعدادات الألوان ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    esac
}

# === دالة عرض البانر ===
show_banner() {
    clear
    echo -e "${BLUE}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║                      Amass Test Script                      ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "amass" >/dev/null 2>&1; then
        print_status "SUCCESS" "Amass is installed"
        return 0
    else
        print_status "ERROR" "Amass is not installed"
        print_status "INFO" "Installing Amass..."
        install_amass
        return $?
    fi
}

# === دالة تثبيت Amass ===
install_amass() {
    print_status "INFO" "Installing Amass..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y wget unzip
    
    # تحميل Amass من GitHub Releases
    local release_info=$(curl -s "https://api.github.com/repos/OWASP/Amass/releases/latest")
    local download_url=$(echo "$release_info" | grep "browser_download_url.*linux_amd64.zip" | cut -d '"' -f 4 | head -1)
    
    if [ -n "$download_url" ]; then
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        if wget -q "$download_url"; then
            unzip -q *.zip
            local binary_path=$(find . -name "amass" -type f | head -1)
            if [ -n "$binary_path" ]; then
                sudo cp "$binary_path" /usr/local/bin/
                sudo chmod +x /usr/local/bin/amass
                print_status "SUCCESS" "Amass installed successfully"
                cd /
                rm -rf "$temp_dir"
                return 0
            fi
        fi
        
        cd /
        rm -rf "$temp_dir"
    fi
    
    print_status "ERROR" "Failed to install Amass"
    return 1
}

# === دالة اختبار Amass ===
test_amass() {
    local domain="$1"
    local output_file="amass_results.txt"
    
    print_status "INFO" "Testing Amass on: $domain"
    
    # تشغيل Amass
    if amass enum -d "$domain" -silent -o "$output_file" >/dev/null 2>&1; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Amass test completed: $count subdomains found"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض عينة من النتائج
            if [ "$count" -gt 0 ]; then
                print_status "INFO" "Sample subdomains:"
                head -10 "$output_file" | while read -r line; do
                    echo "  $line"
                done
                echo
                print_status "INFO" "Domain analysis:"
                print_status "INFO" "Total subdomains: $count"
                print_status "INFO" "Unique domains: $(sort "$output_file" | uniq | wc -l)"
            fi
            return 0
        else
            print_status "WARNING" "Amass produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Amass test failed"
        return 1
    fi
}

# === دالة عرض الاستخدام ===
show_usage() {
    echo "Usage: $0 [DOMAIN]"
    echo
    echo "Examples:"
    echo "  $0 example.com"
    echo "  $0 google.com"
    echo "  $0 github.com"
    echo
    echo "Description:"
    echo "  This script tests Amass subdomain enumeration tool"
}

# === الدالة الرئيسية ===
main() {
    show_banner
    
    # التحقق من المعاملات
    if [ $# -eq 0 ]; then
        print_status "INFO" "No domain specified, using example.com"
        domain="example.com"
    else
        domain="$1"
    fi
    
    # التحقق من تثبيت الأداة
    if ! check_tool; then
        print_status "ERROR" "Cannot proceed without Amass"
        exit 1
    fi
    
    # اختبار الأداة
    if test_amass "$domain"; then
        print_status "SUCCESS" "Amass test completed successfully!"
    else
        print_status "ERROR" "Amass test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Amass with:"
    echo "  amass enum -d $domain -silent -o results.txt"
    echo "  amass enum -d $domain -active"
}

# === تشغيل الدالة الرئيسية ===
main "$@"

