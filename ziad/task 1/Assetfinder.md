# Assetfinder - أداة استكشاف النطاقات الفرعية

## 📋 الوظيفة
Assetfinder هي أداة Go لاستكشاف النطاقات الفرعية من مصادر مختلفة مثل Certificate Transparency logs و محركات البحث.

## 🚀 الاستخدامات
- استكشاف النطاقات الفرعية لنطاق معين
- البحث في شهادات SSL/TLS
- جمع معلومات عن البنية التحتية
- استخدام في اختبارات الاختراق الأخلاقي

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
assetfinder example.com

# البحث في النطاقات الفرعية فقط
assetfinder --subs-only example.com

# حفظ النتائج في ملف
assetfinder example.com > subdomains.txt

# البحث مع تصفية النتائج
assetfinder example.com | grep -E "\.(com|org|net)$"

# عرض المساعدة
assetfinder -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/tomnomnom/assetfinder@latest

# أو تحميل من GitHub
git clone https://github.com/tomnomnom/assetfinder.git
cd assetfinder
go build
sudo mv assetfinder /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Assetfinder Test Script

echo "=== Assetfinder Test Script ==="
echo "Testing Assetfinder on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل Assetfinder
echo "Running Assetfinder..."
assetfinder --subs-only example.com > assetfinder_results.txt

# عرض النتائج
if [ -f "assetfinder_results.txt" ]; then
    echo "Results saved to: assetfinder_results.txt"
    echo "Number of subdomains found: $(wc -l < assetfinder_results.txt)"
    echo
    echo "Sample subdomains:"
    head -10 assetfinder_results.txt
    echo
    echo "Domain extensions found:"
    grep -o '\.[a-zA-Z0-9]*$' assetfinder_results.txt | sort | uniq -c | sort -nr
else
    echo "No results found"
fi

echo
echo "Test completed!"
```

