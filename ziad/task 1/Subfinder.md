# Subfinder - أداة استكشاف النطاقات الفرعية السريعة

## 📋 الوظيفة
Subfinder هي أداة Go سريعة ومتطورة لاستكشاف النطاقات الفرعية باستخدام مصادر متعددة ومحركات بحث مختلفة.

## 🚀 الاستخدامات
- استكشاف النطاقات الفرعية بسرعة عالية
- البحث في مصادر متعددة ومتنوعة
- جمع معلومات شاملة عن البنية التحتية
- استخدام في اختبارات الاختراق الأخلاقي والاستطلاع

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
subfinder -d example.com

# حفظ النتائج في ملف
subfinder -d example.com -o subdomains.txt

# استخدام وضع صامت
subfinder -d example.com -silent

# استخدام جميع المصادر المتاحة
subfinder -d example.com -all

# استخدام مصادر محددة
subfinder -d example.com -sources google,yahoo,bing

# فحص مع timeout مخصص
subfinder -d example.com -timeout 30

# عرض المساعدة
subfinder -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# أو تحميل من GitHub Releases
wget https://github.com/projectdiscovery/subfinder/releases/latest/download/subfinder_2.6.3_linux_amd64.zip
unzip subfinder_2.6.3_linux_amd64.zip
sudo mv subfinder /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Subfinder Test Script

echo "=== Subfinder Test Script ==="
echo "Testing Subfinder on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل Subfinder مع خيارات مختلفة
echo "Running Subfinder (silent mode)..."
subfinder -d example.com -silent -o subfinder_results.txt

# عرض النتائج
if [ -f "subfinder_results.txt" ]; then
    echo "Results saved to: subfinder_results.txt"
    echo "Number of subdomains found: $(wc -l < subfinder_results.txt)"
    echo
    echo "Sample subdomains:"
    head -10 subfinder_results.txt
    echo
    echo "Domain analysis:"
    echo "Total subdomains: $(wc -l < subfinder_results.txt)"
    echo "Unique domains: $(sort subfinder_results.txt | uniq | wc -l)"
else
    echo "No results found"
fi

echo
echo "Test completed!"
```

