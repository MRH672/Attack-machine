#!/bin/bash

# =============================================================================
# GAU (Get All URLs) Test Script
# سكريبت اختبار أداة GAU
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
    ║                      GAU Test Script                        ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "gau" >/dev/null 2>&1; then
        print_status "SUCCESS" "GAU is installed"
        return 0
    else
        print_status "ERROR" "GAU is not installed"
        print_status "INFO" "Installing GAU..."
        install_gau
        return $?
    fi
}

# === دالة تثبيت GAU ===
install_gau() {
    print_status "INFO" "Installing GAU..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت GAU
    go install github.com/lc/gau/v2/cmd/gau@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/gau" ]; then
        sudo cp "$HOME/go/bin/gau" /usr/local/bin/
        sudo chmod +x /usr/local/bin/gau
        print_status "SUCCESS" "GAU installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install GAU"
        return 1
    fi
}

# === دالة اختبار GAU ===
test_gau() {
    local domain="$1"
    local output_file="gau_results.txt"
    
    print_status "INFO" "Testing GAU on: $domain"
    
    # تشغيل GAU
    if gau "$domain" > "$output_file" 2>/dev/null; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "GAU test completed: $count URLs found"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض عينة من النتائج
            if [ "$count" -gt 0 ]; then
                print_status "INFO" "Sample URLs:"
                head -5 "$output_file" | while read -r line; do
                    echo "  $line"
                done
                echo
                print_status "INFO" "File extensions found:"
                grep -o '\.[a-zA-Z0-9]*$' "$output_file" | sort | uniq -c | sort -nr | head -5
            fi
            return 0
        else
            print_status "WARNING" "GAU produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "GAU test failed"
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
    echo "  This script tests GAU URL collection tool"
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
        print_status "ERROR" "Cannot proceed without GAU"
        exit 1
    fi
    
    # اختبار الأداة
    if test_gau "$domain"; then
        print_status "SUCCESS" "GAU test completed successfully!"
    else
        print_status "ERROR" "GAU test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use GAU with:"
    echo "  gau $domain > urls.txt"
    echo "  gau -providers wayback,commoncrawl $domain"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
