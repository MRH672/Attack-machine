#!/bin/bash

# =============================================================================
# Assetfinder Test Script
# سكريبت اختبار أداة Assetfinder
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
    ║                   Assetfinder Test Script                   ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "assetfinder" >/dev/null 2>&1; then
        print_status "SUCCESS" "Assetfinder is installed"
        return 0
    else
        print_status "ERROR" "Assetfinder is not installed"
        print_status "INFO" "Installing Assetfinder..."
        install_assetfinder
        return $?
    fi
}

# === دالة تثبيت Assetfinder ===
install_assetfinder() {
    print_status "INFO" "Installing Assetfinder..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت Assetfinder
    go install github.com/tomnomnom/assetfinder@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/assetfinder" ]; then
        sudo cp "$HOME/go/bin/assetfinder" /usr/local/bin/
        sudo chmod +x /usr/local/bin/assetfinder
        print_status "SUCCESS" "Assetfinder installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install Assetfinder"
        return 1
    fi
}

# === دالة اختبار Assetfinder ===
test_assetfinder() {
    local domain="$1"
    local output_file="assetfinder_results.txt"
    
    print_status "INFO" "Testing Assetfinder on: $domain"
    
    # تشغيل Assetfinder
    if assetfinder --subs-only "$domain" > "$output_file" 2>/dev/null; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Assetfinder test completed: $count subdomains found"
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
            print_status "WARNING" "Assetfinder produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Assetfinder test failed"
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
    echo "  This script tests Assetfinder subdomain enumeration tool"
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
        print_status "ERROR" "Cannot proceed without Assetfinder"
        exit 1
    fi
    
    # اختبار الأداة
    if test_assetfinder "$domain"; then
        print_status "SUCCESS" "Assetfinder test completed successfully!"
    else
        print_status "ERROR" "Assetfinder test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Assetfinder with:"
    echo "  assetfinder --subs-only $domain > results.txt"
    echo "  assetfinder $domain | grep -E '\.(com|org|net)$'"
}

# === تشغيل الدالة الرئيسية ===
main "$@"

