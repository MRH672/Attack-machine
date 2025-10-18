# Amass - أداة استكشاف النطاقات الفرعية الشاملة

## 📋 الوظيفة
Amass هي أداة Go متقدمة وشاملة لاستكشاف النطاقات الفرعية ورسم خرائط البنية التحتية للمواقع باستخدام مصادر متعددة وتقنيات متطورة.

## 🚀 الاستخدامات
- استكشاف شامل للنطاقات الفرعية
- رسم خرائط البنية التحتية للمواقع
- البحث في مصادر متعددة ومتنوعة
- تحليل DNS والبنية التحتية
- استخدام في اختبارات الاختراق الأخلاقي

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
amass enum -d example.com

# استخدام وضع صامت
amass enum -d example.com -silent

# حفظ النتائج في ملف
amass enum -d example.com -o subdomains.txt

# استخدام البحث النشط
amass enum -d example.com -active

# استخدام مصادر محددة
amass enum -d example.com -src

# فحص مع timeout مخصص
amass enum -d example.com -timeout 30

# رسم خريطة البنية التحتية
amass viz -d example.com

# عرض المساعدة
amass enum -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/OWASP/Amass/v3/...@latest

# أو تحميل من GitHub Releases
wget https://github.com/OWASP/Amass/releases/latest/download/amass_linux_amd64.zip
unzip amass_linux_amd64.zip
sudo mv amass /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Amass Test Script

echo "=== Amass Test Script ==="
echo "Testing Amass on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل Amass مع خيارات مختلفة
echo "Running Amass (silent mode)..."
amass enum -d example.com -silent -o amass_results.txt

echo "Running Amass with active scanning..."
amass enum -d example.com -active -silent -o amass_active.txt

# عرض النتائج
if [ -f "amass_results.txt" ]; then
    echo "Results saved to: amass_results.txt"
    echo "Number of subdomains found: $(wc -l < amass_results.txt)"
    echo
    echo "Sample subdomains:"
    head -10 amass_results.txt
    echo
    echo "Domain analysis:"
    echo "Total subdomains: $(wc -l < amass_results.txt)"
    echo "Unique domains: $(sort amass_results.txt | uniq | wc -l)"
else
    echo "No results found"
fi

if [ -f "amass_active.txt" ]; then
    echo "Active scan results: $(wc -l < amass_active.txt) subdomains"
fi

echo
echo "Test completed!"
```
