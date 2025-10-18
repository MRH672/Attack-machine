#!/bin/bash

# =============================================================================
# Waybackurls Test Script
# سكريبت اختبار أداة Waybackurls
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
    ║                   Waybackurls Test Script                   ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "waybackurls" >/dev/null 2>&1; then
        print_status "SUCCESS" "Waybackurls is installed"
        return 0
    else
        print_status "ERROR" "Waybackurls is not installed"
        print_status "INFO" "Installing Waybackurls..."
        install_waybackurls
        return $?
    fi
}

# === دالة تثبيت Waybackurls ===
install_waybackurls() {
    print_status "INFO" "Installing Waybackurls..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت Waybackurls
    go install github.com/tomnomnom/waybackurls@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/waybackurls" ]; then
        sudo cp "$HOME/go/bin/waybackurls" /usr/local/bin/
        sudo chmod +x /usr/local/bin/waybackurls
        print_status "SUCCESS" "Waybackurls installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install Waybackurls"
        return 1
    fi
}

# === دالة اختبار Waybackurls ===
test_waybackurls() {
    local domain="$1"
    local output_file="waybackurls_results.txt"
    
    print_status "INFO" "Testing Waybackurls on: $domain"
    
    # تشغيل Waybackurls
    if waybackurls "$domain" > "$output_file" 2>/dev/null; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Waybackurls test completed: $count URLs found"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض عينة من النتائج
            if [ "$count" -gt 0 ]; then
                print_status "INFO" "Sample URLs:"
                head -5 "$output_file" | while read -r line; do
                    echo "  $line"
                done
                echo
                print_status "INFO" "Interesting endpoints found:"
                grep -E "(admin|login|api|config|test)" "$output_file" | head -5
            fi
            return 0
        else
            print_status "WARNING" "Waybackurls produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Waybackurls test failed"
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
    echo "  This script tests Waybackurls URL collection tool"
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
        print_status "ERROR" "Cannot proceed without Waybackurls"
        exit 1
    fi
    
    # اختبار الأداة
    if test_waybackurls "$domain"; then
        print_status "SUCCESS" "Waybackurls test completed successfully!"
    else
        print_status "ERROR" "Waybackurls test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Waybackurls with:"
    echo "  waybackurls $domain > urls.txt"
    echo "  waybackurls $domain | grep -E '\.(js|css|php)$'"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
