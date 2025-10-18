# Waybackurls - أداة جمع URLs من Wayback Machine

## 📋 الوظيفة
Waybackurls هي أداة Go بسيطة وسريعة لجمع URLs من Wayback Machine (web.archive.org) لنطاق معين.

## 🚀 الاستخدامات
- جمع URLs التاريخية من أرشيف الإنترنت
- البحث عن صفحات محذوفة أو متغيرة
- تحليل تطور المواقع عبر الزمن
- جمع معلومات عن البنية التحتية القديمة

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
waybackurls example.com

# حفظ النتائج في ملف
waybackurls example.com > wayback_urls.txt

# تصفية النتائج حسب الامتداد
waybackurls example.com | grep -E "\.(js|css|php|html)$"

# البحث عن ملفات محددة
waybackurls example.com | grep -E "(admin|login|config)"

# عرض المساعدة
waybackurls -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/tomnomnom/waybackurls@latest

# أو تحميل من GitHub
git clone https://github.com/tomnomnom/waybackurls.git
cd waybackurls
go build
sudo mv waybackurls /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Waybackurls Test Script

echo "=== Waybackurls Test Script ==="
echo "Testing Waybackurls on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل Waybackurls
echo "Running Waybackurls..."
waybackurls example.com > wayback_results.txt

# عرض النتائج
if [ -f "wayback_results.txt" ]; then
    echo "Results saved to: wayback_results.txt"
    echo "Number of URLs found: $(wc -l < wayback_results.txt)"
    echo
    echo "Sample URLs:"
    head -5 wayback_results.txt
    echo
    echo "Interesting endpoints found:"
    grep -E "(admin|login|api|config|test)" wayback_results.txt | head -5
else
    echo "No results found"
fi

echo
echo "Test completed!"
```

