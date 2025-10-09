#!/usr/bin/env bash

set -euo pipefail

# === إعدادات الألوان ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === دالة للطباعة الملونة ===
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

# === دالة لعرض البانر ===
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║    ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗        ║
    ║    ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║        ║
    ║    ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║        ║
    ║    ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║        ║
    ║    ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║        ║
    ║    ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝        ║
    ║                                                              ║
    ║              Domain to File Converter                        ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# === دالة لعرض الاستخدام ===
show_usage() {
    echo -e "${YELLOW}الاستخدام:${NC}"
    echo -e "  $0 [DOMAIN]"
    echo
    echo -e "${YELLOW}الأمثلة:${NC}"
    echo -e "  $0 zdev.net"
    echo -e "  $0 example.com"
    echo -e "  $0 subdomain.example.com"
    echo
    echo -e "${YELLOW}الوصف:${NC}"
    echo -e "  يحول الدومين أو الساب دومين إلى ملف نصي بنفس الاسم"
    echo -e "  مثال: zdev.net → zdev.txt"
}

# === دالة لاستخراج اسم الدومين ===
extract_domain_name() {
    local domain="$1"
    # إزالة البروتوكول إذا وُجد
    domain="${domain#http://}"
    domain="${domain#https://}"
    domain="${domain#www.}"
    
    # استخراج الجزء الأول قبل النقطة
    local domain_name="${domain%%.*}"
    echo "$domain_name"
}

# === دالة لإنشاء الملف ===
create_domain_file() {
    local domain="$1"
    local domain_name=$(extract_domain_name "$domain")
    local output_file="${domain_name}.txt"
    
    print_status "INFO" "الدومين المدخل: $domain"
    print_status "INFO" "اسم الملف المطلوب: $output_file"
    
    # إنشاء الملف
    if [ -f "$output_file" ]; then
        print_status "WARNING" "الملف $output_file موجود بالفعل"
        read -p "هل تريد استبداله؟ (y/n): " replace
        if [[ "$replace" =~ ^[Yy]$ ]]; then
            rm -f "$output_file"
            print_status "INFO" "تم حذف الملف القديم"
        else
            print_status "INFO" "تم إلغاء العملية"
            exit 0
        fi
    fi
    
    # كتابة معلومات الدومين في الملف
    {
        echo "# معلومات الدومين"
        echo "الدومين الأصلي: $domain"
        echo "اسم الملف: $output_file"
        echo "تاريخ الإنشاء: $(date)"
        echo "=========================================="
        echo ""
        echo "# يمكنك إضافة النطاقات الفرعية هنا"
        echo "# مثال:"
        echo "# www.$domain"
        echo "# mail.$domain"
        echo "# ftp.$domain"
        echo "# admin.$domain"
        echo ""
        echo "# أو يمكنك استخدام أدوات أخرى مثل:"
        echo "# subfinder -d $domain -o $output_file"
        echo "# assetfinder --subs-only $domain >> $output_file"
    } > "$output_file"
    
    print_status "SUCCESS" "تم إنشاء الملف: $output_file"
    print_status "INFO" "يمكنك الآن إضافة النطاقات الفرعية إلى هذا الملف"
}

# === الدالة الرئيسية ===
main() {
    show_banner
    
    # التحقق من وجود معامل
    if [ $# -eq 0 ]; then
        print_status "ERROR" "لم يتم تحديد الدومين"
        show_usage
        exit 1
    fi
    
    local domain="$1"
    
    # التحقق من صحة الدومين
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_status "ERROR" "تنسيق الدومين غير صحيح: $domain"
        print_status "INFO" "تأكد من أن الدومين يحتوي على نقطة وامتداد صحيح"
        exit 1
    fi
    
    # إنشاء الملف
    create_domain_file "$domain"
    
    echo
    print_status "SUCCESS" "تم الانتهاء بنجاح!"
    print_status "INFO" "يمكنك الآن استخدام الملف مع أدوات أخرى:"
    echo -e "  ${CYAN}subfinder -d $domain -o ${domain%%.*}.txt${NC}"
    echo -e "  ${CYAN}assetfinder --subs-only $domain >> ${domain%%.*}.txt${NC}"
    echo -e "  ${CYAN}httpx -l ${domain%%.*}.txt${NC}"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
