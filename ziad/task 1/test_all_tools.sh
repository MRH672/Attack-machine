#!/bin/bash

# =============================================================================
# All Tools Test Script
# سكريبت اختبار جميع أدوات Subdomain Enumeration
# =============================================================================

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
    ║              All Tools Test Script                          ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
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
    echo "  This script tests all subdomain enumeration tools"
}

# === دالة تشغيل سكريبت أداة ===
run_tool_script() {
    local script_name="$1"
    local domain="$2"
    
    if [ -f "$script_name" ]; then
        print_status "STEP" "Running $script_name..."
        if bash "$script_name" "$domain" >/dev/null 2>&1; then
            print_status "SUCCESS" "$script_name completed successfully"
            return 0
        else
            print_status "WARNING" "$script_name failed or had issues"
            return 1
        fi
    else
        print_status "ERROR" "$script_name not found"
        return 1
    fi
}

# === دالة اختبار جميع الأدوات ===
test_all_tools() {
    local domain="$1"
    local total_tools=0
    local successful_tools=0
    
    print_status "STEP" "Starting comprehensive tool testing..."
    echo
    
    # قائمة السكريبتات
    local scripts=(
        "Sublist3r.sh"
        "Subfinder.sh"
        "Assetfinder.sh"
        "HTTPx.sh"
        "Anew.sh"
        "GAU.sh"
        "Waybackurls.sh"
        "Amass.sh"
        "Curl.sh"
        "Wget.sh"
    )
    
    # تشغيل كل سكريبت
    for script in "${scripts[@]}"; do
        ((total_tools++))
        if run_tool_script "$script" "$domain"; then
            ((successful_tools++))
        fi
        echo
    done
    
    # عرض النتائج النهائية
    print_status "STEP" "Test Results Summary"
    print_status "INFO" "Total tools tested: $total_tools"
    print_status "SUCCESS" "Successful tests: $successful_tools"
    print_status "INFO" "Failed tests: $((total_tools - successful_tools))"
    
    if [ "$successful_tools" -eq "$total_tools" ]; then
        print_status "SUCCESS" "All tools tested successfully! 🎉"
        return 0
    elif [ "$successful_tools" -gt 0 ]; then
        print_status "WARNING" "Some tools passed, some failed"
        return 1
    else
        print_status "ERROR" "All tools failed"
        return 2
    fi
}

# === دالة عرض النتائج ===
show_results() {
    print_status "STEP" "Generated Files"
    echo
    
    # عرض الملفات المنشأة
    if ls *.txt >/dev/null 2>&1; then
        print_status "INFO" "Result files created:"
        ls -la *.txt | while read -r line; do
            echo -e "  ${CYAN}$line${NC}"
        done
    else
        print_status "INFO" "No result files found"
    fi
    
    echo
    print_status "INFO" "You can review individual tool results in the generated files"
}

# === دالة تنظيف الملفات المؤقتة ===
cleanup() {
    print_status "INFO" "Cleaning up temporary files..."
    rm -f test_*.txt 2>/dev/null || true
}

# === الدالة الرئيسية ===
main() {
    # التحقق من المعاملات
    if [ $# -eq 0 ]; then
        print_status "INFO" "No domain specified, using example.com"
        domain="example.com"
    else
        domain="$1"
    fi
    
    # عرض البانر
    show_banner
    
    # عرض إعدادات الاختبار
    print_status "INFO" "Test Configuration:"
    print_status "INFO" "  Domain: $domain"
    print_status "INFO" "  Working Directory: $(pwd)"
    echo
    
    # اختبار جميع الأدوات
    if test_all_tools "$domain"; then
        print_status "SUCCESS" "All tests completed successfully!"
    else
        print_status "WARNING" "Some tests failed, but the script completed"
    fi
    
    # عرض النتائج
    show_results
    
    # تنظيف الملفات المؤقتة
    cleanup
    
    echo
    print_status "SUCCESS" "Test script completed!"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
