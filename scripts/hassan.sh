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

# === متغيرات عامة ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/subdomain_tools_install.log"
TOOLS_DIR="/opt/subdomain_tools"
WORDLISTS_DIR="/usr/share/wordlists"

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

# === دالة للتحقق من وجود الأمر ===
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# === دالة للتحقق من أن المستخدم root ===
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_status "ERROR" "يجب تشغيل السكربت كـ root!"
        print_status "INFO" "استخدم: sudo $0"
        exit 1
    fi
}

# === دالة لتثبيت الحزم ===
install_pkg() {
    local pkg=$1
    local description=${2:-$pkg}
    
    if ! dpkg -l | grep -q "^ii.*$pkg "; then
        print_status "INFO" "جاري تثبيت $description..."
        if apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1; then
            print_status "SUCCESS" "تم تثبيت $description بنجاح"
        else
            print_status "ERROR" "فشل في تثبيت $description"
            return 1
        fi
    else
        print_status "SUCCESS" "$description مثبت بالفعل"
    fi
}

# === دالة لتنزيل أداة من GitHub ===
install_github_tool() {
    local repo=$1
    local tool_name=$2
    local build_cmd=${3:-""}
    local install_cmd=${4:-""}
    
    if [ ! -d "$TOOLS_DIR/$tool_name" ]; then
        print_status "INFO" "جاري تنزيل $tool_name..."
        
        if git clone "https://github.com/$repo" "$TOOLS_DIR/$tool_name" >> "$LOG_FILE" 2>&1; then
            cd "$TOOLS_DIR/$tool_name" || exit 1
            
            # تثبيت المتطلبات إذا وُجدت
            if [ -f "requirements.txt" ]; then
                print_status "INFO" "تثبيت متطلبات Python لـ $tool_name..."
                pip3 install -r requirements.txt >> "$LOG_FILE" 2>&1
            fi
            
            # بناء الأداة إذا وُجدت أوامر البناء
            if [ -n "$build_cmd" ]; then
                print_status "INFO" "بناء $tool_name..."
                eval "$build_cmd" >> "$LOG_FILE" 2>&1
            fi
            
            # تثبيت الأداة إذا وُجدت أوامر التثبيت
            if [ -n "$install_cmd" ]; then
                print_status "INFO" "تثبيت $tool_name..."
                eval "$install_cmd" >> "$LOG_FILE" 2>&1
            fi
            
            # جعل الملفات قابلة للتنفيذ
            find . -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
            find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            
            print_status "SUCCESS" "تم تثبيت $tool_name بنجاح"
        else
            print_status "ERROR" "فشل في تنزيل $tool_name"
            return 1
        fi
    else
        print_status "SUCCESS" "$tool_name موجود بالفعل"
    fi
}

# === دالة لتثبيت Go tools ===
install_go_tool() {
    local tool_path=$1
    local tool_name=$2
    
    if ! command_exists "$tool_name"; then
        print_status "INFO" "تثبيت $tool_name..."
        if go install "$tool_path@latest" >> "$LOG_FILE" 2>&1; then
            print_status "SUCCESS" "تم تثبيت $tool_name بنجاح"
        else
            print_status "ERROR" "فشل في تثبيت $tool_name"
            return 1
        fi
    else
        print_status "SUCCESS" "$tool_name مثبت بالفعل"
    fi
}

# === دالة لعرض البانر ===
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
    ║              Subdomain Enumeration Tools Installer           ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    print_status "INFO" "بدء تثبيت أدوات اكتشاف النطاقات الفرعية..."
    echo
}

# === دالة لتنزيل القواميس ===
download_wordlists() {
    print_status "STEP" "تنزيل القواميس المطلوبة..."
    
    # إنشاء مجلد القواميس
    mkdir -p "$WORDLISTS_DIR"
    
    # قاموس الساب دومينات الرئيسي
    if [ ! -f "$WORDLISTS_DIR/subdomains.txt" ]; then
        print_status "INFO" "تنزيل قاموس الساب دومينات..."
        wget -q "https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt" -O "$WORDLISTS_DIR/subdomains.txt"
        print_status "SUCCESS" "تم تنزيل قاموس الساب دومينات"
    else
        print_status "SUCCESS" "قاموس الساب دومينات موجود بالفعل"
    fi
    
    # قاموس DNS
    if [ ! -f "$WORDLISTS_DIR/dnsmap.txt" ]; then
        print_status "INFO" "تنزيل قاموس DNS..."
        wget -q "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/dns-Jhaddix.txt" -O "$WORDLISTS_DIR/dnsmap.txt"
        print_status "SUCCESS" "تم تنزيل قاموس DNS"
    else
        print_status "SUCCESS" "قاموس DNS موجود بالفعل"
    fi
}

# === دالة لإعداد البيئة ===
setup_environment() {
    print_status "STEP" "إعداد البيئة والاختصارات..."
    
    # إنشاء مجلد الأدوات
    mkdir -p "$TOOLS_DIR"
    
    # إضافة Go إلى PATH
    if ! grep -q "GOPATH" ~/.bashrc; then
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi
    
    # إضافة اختصارات مفيدة
    cat >> ~/.bashrc << 'EOF'

# === Subdomain Tools Aliases ===
alias subenum='amass enum -d'
alias subfinder='subfinder -d'
alias sublister='python3 /opt/subdomain_tools/Sublist3r/sublist3r.py -d'
alias assetfinder='assetfinder -subs-only'
alias httpx='httpx -silent -status-code'
alias anew='anew'
alias subdomain-tools='cd /opt/subdomain_tools'
alias wordlists='cd /usr/share/wordlists'

# === Quick Commands ===
alias subscan='subfinder -d $1 | httpx -silent -status-code'
alias subenum-full='amass enum -d $1 && subfinder -d $1 && assetfinder -subs-only $1 | anew all_subs.txt'
EOF
    
    print_status "SUCCESS" "تم إعداد البيئة والاختصارات"
}

# === دالة لعرض النتائج ===
show_results() {
    echo
    print_status "SUCCESS" "تم الانتهاء من التثبيت بنجاح!"
    echo
    print_status "INFO" "يجب إعادة تشغيل الطرفية أو تشغيل: source ~/.bashrc"
    echo
    print_status "STEP" "الأدوات المتاحة الآن:"
    echo -e "  ${GREEN}•${NC} amass - أداة شاملة لاكتشاف النطاقات"
    echo -e "  ${GREEN}•${NC} subfinder - أداة سريعة لاكتشاف النطاقات"
    echo -e "  ${GREEN}•${NC} assetfinder - أداة لاكتشاف النطاقات من مصادر متعددة"
    echo -e "  ${GREEN}•${NC} httpx - أداة فحص HTTP/HTTPS"
    echo -e "  ${GREEN}•${NC} anew - أداة إزالة التكرارات"
    echo -e "  ${GREEN}•${NC} sublist3r - أداة لاكتشاف النطاقات من مصادر عامة"
    echo -e "  ${GREEN}•${NC} gobuster - أداة فحص الدلائل والنطاقات"
    echo -e "  ${GREEN}•${NC} nmap - أداة فحص الشبكة"
    echo -e "  ${GREEN}•${NC} masscan - أداة فحص سريع للشبكة"
    echo
    print_status "STEP" "أمثلة الاستخدام:"
    echo -e "  ${CYAN}subenum example.com${NC}                    # فحص شامل"
    echo -e "  ${CYAN}subfinder example.com${NC}                  # فحص سريع"
    echo -e "  ${CYAN}subscan example.com${NC}                    # فحص مع HTTP"
    echo -e "  ${CYAN}subenum-full example.com${NC}               # فحص شامل مع جميع الأدوات"
    echo -e "  ${CYAN}httpx -l subdomains.txt${NC}                # فحص HTTP للنطاقات"
    echo
    print_status "INFO" "ملف السجل: $LOG_FILE"
    print_status "INFO" "مجلد الأدوات: $TOOLS_DIR"
    print_status "INFO" "مجلد القواميس: $WORDLISTS_DIR"
}

# === الدالة الرئيسية ===
main() {
    # التحقق من صلاحيات root
    check_root
    
    # عرض البانر
    show_banner
    
    # إنشاء ملف السجل
    echo "=== Subdomain Tools Installation Log ===" > "$LOG_FILE"
    echo "Started at: $(date)" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    
    # تحديث النظام
    print_status "STEP" "تحديث النظام..."
    apt-get update >> "$LOG_FILE" 2>&1
    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    print_status "SUCCESS" "تم تحديث النظام"
    
    # تثبيت الأدوات الأساسية
    print_status "STEP" "تثبيت الأدوات الأساسية..."
    install_pkg "git" "Git"
    install_pkg "python3" "Python 3"
    install_pkg "python3-pip" "Python pip"
    install_pkg "curl" "cURL"
    install_pkg "wget" "Wget"
    install_pkg "jq" "jq JSON processor"
    install_pkg "dnsutils" "DNS utilities"
    install_pkg "golang-go" "Go programming language"
    
    # تثبيت أدوات اكتشاف النطاقات
    print_status "STEP" "تثبيت أدوات اكتشاف النطاقات الفرعية..."
    install_pkg "amass" "Amass"
    install_pkg "sublist3r" "Sublist3r"
    
    # تثبيت أدوات Go
    print_status "STEP" "تثبيت أدوات Go..."
    install_go_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "subfinder"
    install_go_tool "github.com/tomnomnom/assetfinder" "assetfinder"
    install_go_tool "github.com/tomnomnom/anew" "anew"
    install_go_tool "github.com/projectdiscovery/httpx/cmd/httpx" "httpx"
    install_go_tool "github.com/tomnomnom/waybackurls" "waybackurls"
    install_go_tool "github.com/tomnomnom/gau" "gau"
    
    # تثبيت أدوات GitHub
    print_status "STEP" "تثبيت أدوات GitHub..."
    install_github_tool "aboul3la/Sublist3r" "Sublist3r"
    install_github_tool "OJ/gobuster" "gobuster" "go build" "go install"
    install_github_tool "guelfoweb/knock" "knock"
    
    # تثبيت الأدوات المساعدة
    print_status "STEP" "تثبيت الأدوات المساعدة..."
    install_pkg "seclists" "SecLists"
    install_pkg "dnsrecon" "DNSRecon"
    install_pkg "masscan" "Masscan"
    install_pkg "nmap" "Nmap"
    install_pkg "dnsenum" "DNSenum"
    install_pkg "fierce" "Fierce"
    
    # تنزيل القواميس
    download_wordlists
    
    # إعداد البيئة
    setup_environment
    
    # عرض النتائج
    show_results
    
    echo "Completed at: $(date)" >> "$LOG_FILE"
}

# === تشغيل الدالة الرئيسية ===
main "$@"
