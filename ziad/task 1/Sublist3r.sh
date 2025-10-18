#!/bin/bash

# =============================================================================
# Sublist3r Test Script
# سكريبت اختبار أداة Sublist3r
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
    ║                    Sublist3r Test Script                     ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "sublist3r.py" >/dev/null 2>&1; then
        print_status "SUCCESS" "Sublist3r is installed"
        return 0
    else
        print_status "ERROR" "Sublist3r is not installed"
        print_status "INFO" "Installing Sublist3r..."
        install_sublist3r
        return $?
    fi
}

# === دالة تثبيت Sublist3r ===
install_sublist3r() {
    print_status "INFO" "Installing Sublist3r..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y python3 python3-pip git
    
    # تحميل Sublist3r
    git clone https://github.com/aboul3la/Sublist3r.git
    cd Sublist3r
    pip3 install -r requirements.txt
    sudo cp sublist3r.py /usr/local/bin/
    cd ..
    
    if command -v "sublist3r.py" >/dev/null 2>&1; then
        print_status "SUCCESS" "Sublist3r installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install Sublist3r"
        return 1
    fi
}

# === دالة اختبار Sublist3r ===
test_sublist3r() {
    local domain="$1"
    local output_file="sublist3r_results.txt"
    
    print_status "INFO" "Testing Sublist3r on: $domain"
    
    # تشغيل Sublist3r
    if python3 /usr/local/bin/sublist3r.py -d "$domain" -o "$output_file" >/dev/null 2>&1; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Sublist3r test completed: $count subdomains found"
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
            print_status "WARNING" "Sublist3r produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Sublist3r test failed"
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
    echo "  This script tests Sublist3r subdomain enumeration tool"
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
        print_status "ERROR" "Cannot proceed without Sublist3r"
        exit 1
    fi
    
    # اختبار الأداة
    if test_sublist3r "$domain"; then
        print_status "SUCCESS" "Sublist3r test completed successfully!"
    else
        print_status "ERROR" "Sublist3r test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Sublist3r with:"
    echo "  sublist3r.py -d $domain -o results.txt"
    echo "  sublist3r.py -d $domain -e google,yahoo,bing"
}

# === تشغيل الدالة الرئيسية ===
main "$@"

