#!/bin/bash

# =============================================================================
# HTTPx Test Script
# سكريبت اختبار أداة HTTPx
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
    ║                      HTTPx Test Script                      ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "httpx" >/dev/null 2>&1; then
        print_status "SUCCESS" "HTTPx is installed"
        return 0
    else
        print_status "ERROR" "HTTPx is not installed"
        print_status "INFO" "Installing HTTPx..."
        install_httpx
        return $?
    fi
}

# === دالة تثبيت HTTPx ===
install_httpx() {
    print_status "INFO" "Installing HTTPx..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت HTTPx
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/httpx" ]; then
        sudo cp "$HOME/go/bin/httpx" /usr/local/bin/
        sudo chmod +x /usr/local/bin/httpx
        print_status "SUCCESS" "HTTPx installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install HTTPx"
        return 1
    fi
}

# === دالة اختبار HTTPx ===
test_httpx() {
    local domain="$1"
    local test_file="test_domains.txt"
    local output_file="httpx_results.txt"
    
    print_status "INFO" "Testing HTTPx on: $domain"
    
    # إنشاء ملف اختبار
    echo "http://$domain" > "$test_file"
    echo "https://$domain" >> "$test_file"
    
    # تشغيل HTTPx
    if httpx -l "$test_file" -status-code -title -o "$output_file" >/dev/null 2>&1; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "HTTPx test completed: $count active URLs found"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض النتائج
            if [ "$count" -gt 0 ]; then
                print_status "INFO" "Results:"
                cat "$output_file" | while read -r line; do
                    echo "  $line"
                done
            fi
            return 0
        else
            print_status "WARNING" "HTTPx produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "HTTPx test failed"
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
    echo "  This script tests HTTPx HTTP/HTTPS probing tool"
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
        print_status "ERROR" "Cannot proceed without HTTPx"
        exit 1
    fi
    
    # اختبار الأداة
    if test_httpx "$domain"; then
        print_status "SUCCESS" "HTTPx test completed successfully!"
    else
        print_status "ERROR" "HTTPx test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use HTTPx with:"
    echo "  httpx -l subdomains.txt -status-code"
    echo "  httpx -l subdomains.txt -title -tech-detect"
}

# === تشغيل الدالة الرئيسية ===
main "$@"

