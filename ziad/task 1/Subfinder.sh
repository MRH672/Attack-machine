#!/bin/bash

# =============================================================================
# Subfinder Test Script
# سكريبت اختبار أداة Subfinder
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
    ║                    Subfinder Test Script                     ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "subfinder" >/dev/null 2>&1; then
        print_status "SUCCESS" "Subfinder is installed"
        return 0
    else
        print_status "ERROR" "Subfinder is not installed"
        print_status "INFO" "Installing Subfinder..."
        install_subfinder
        return $?
    fi
}

# === دالة تثبيت Subfinder ===
install_subfinder() {
    print_status "INFO" "Installing Subfinder..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت Subfinder
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/subfinder" ]; then
        sudo cp "$HOME/go/bin/subfinder" /usr/local/bin/
        sudo chmod +x /usr/local/bin/subfinder
        print_status "SUCCESS" "Subfinder installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install Subfinder"
        return 1
    fi
}

# === دالة اختبار Subfinder ===
test_subfinder() {
    local domain="$1"
    local output_file="subfinder_results.txt"
    
    print_status "INFO" "Testing Subfinder on: $domain"
    
    # تشغيل Subfinder
    if subfinder -d "$domain" -silent -o "$output_file" >/dev/null 2>&1; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Subfinder test completed: $count subdomains found"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض عينة من النتائج
            if [ "$count" -gt 0 ]; then
                print_status "INFO" "Sample results:"
                head -5 "$output_file" | while read -r line; do
                    echo "  $line"
                done
            fi
            return 0
        else
            print_status "WARNING" "Subfinder produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Subfinder test failed"
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
    echo "  This script tests Subfinder subdomain enumeration tool"
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
        print_status "ERROR" "Cannot proceed without Subfinder"
        exit 1
    fi
    
    # اختبار الأداة
    if test_subfinder "$domain"; then
        print_status "SUCCESS" "Subfinder test completed successfully!"
    else
        print_status "ERROR" "Subfinder test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Subfinder with:"
    echo "  subfinder -d $domain -silent -o results.txt"
    echo "  subfinder -d $domain -all"
}

# === تشغيل الدالة الرئيسية ===
main "$@"

