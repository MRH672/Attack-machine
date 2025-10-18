#!/bin/bash

# =============================================================================
# Anew Test Script
# سكريبت اختبار أداة Anew
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
    ║                      Anew Test Script                       ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة التحقق من وجود الأداة ===
check_tool() {
    if command -v "anew" >/dev/null 2>&1; then
        print_status "SUCCESS" "Anew is installed"
        return 0
    else
        print_status "ERROR" "Anew is not installed"
        print_status "INFO" "Installing Anew..."
        install_anew
        return $?
    fi
}

# === دالة تثبيت Anew ===
install_anew() {
    print_status "INFO" "Installing Anew..."
    
    # تثبيت المتطلبات
    sudo apt update
    sudo apt install -y golang-go
    
    # تثبيت Anew
    go install github.com/tomnomnom/anew@latest
    
    # نسخ إلى /usr/local/bin
    if [ -f "$HOME/go/bin/anew" ]; then
        sudo cp "$HOME/go/bin/anew" /usr/local/bin/
        sudo chmod +x /usr/local/bin/anew
        print_status "SUCCESS" "Anew installed successfully"
        return 0
    else
        print_status "ERROR" "Failed to install Anew"
        return 1
    fi
}

# === دالة اختبار Anew ===
test_anew() {
    local test_file1="test_file1.txt"
    local test_file2="test_file2.txt"
    local output_file="anew_results.txt"
    
    print_status "INFO" "Testing Anew functionality"
    
    # إنشاء ملفات اختبار
    echo -e "sub1.example.com\nsub2.example.com\nsub3.example.com" > "$test_file1"
    echo -e "sub2.example.com\nsub3.example.com\nsub4.example.com" > "$test_file2"
    
    print_status "INFO" "Created test files:"
    print_status "INFO" "File1: $(cat $test_file1)"
    print_status "INFO" "File2: $(cat $test_file2)"
    
    # دمج الملفات مع إزالة التكرار
    if cat "$test_file1" "$test_file2" | anew > "$output_file" 2>/dev/null; then
        if [ -f "$output_file" ]; then
            local count=$(wc -l < "$output_file")
            print_status "SUCCESS" "Anew test completed: $count unique entries"
            print_status "INFO" "Results saved to: $output_file"
            
            # عرض النتائج
            print_status "INFO" "Merged results:"
            cat "$output_file" | while read -r line; do
                echo "  $line"
            done
            return 0
        else
            print_status "WARNING" "Anew produced no output file"
            return 1
        fi
    else
        print_status "ERROR" "Anew test failed"
        return 1
    fi
}

# === دالة عرض الاستخدام ===
show_usage() {
    echo "Usage: $0"
    echo
    echo "Description:"
    echo "  This script tests Anew deduplication tool"
    echo
    echo "Examples:"
    echo "  echo 'new-subdomain.com' | anew existing.txt"
    echo "  cat file1.txt file2.txt | anew > merged.txt"
}

# === الدالة الرئيسية ===
main() {
    show_banner
    
    # التحقق من تثبيت الأداة
    if ! check_tool; then
        print_status "ERROR" "Cannot proceed without Anew"
        exit 1
    fi
    
    # اختبار الأداة
    if test_anew; then
        print_status "SUCCESS" "Anew test completed successfully!"
    else
        print_status "ERROR" "Anew test failed"
        exit 1
    fi
    
    echo
    print_status "INFO" "You can now use Anew with:"
    echo "  echo 'new-subdomain.com' | anew existing.txt"
    echo "  cat file1.txt file2.txt | anew > merged.txt"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
