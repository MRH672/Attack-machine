# GAU (Get All URLs) - أداة جمع URLs

## 📋 الوظيفة
GAU هي أداة Go لجمع URLs من مصادر مختلفة مثل Wayback Machine و Common Crawl و AlienVault و VirusTotal.

## 🚀 الاستخدامات
- جمع URLs التاريخية من Wayback Machine
- البحث في أرشيفات Common Crawl
- جمع URLs من مصادر الأمان المختلفة
- تحليل البنية التحتية للمواقع

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
gau example.com

# حفظ النتائج في ملف
gau example.com > urls.txt

# استخدام مصادر محددة
gau -providers wayback,commoncrawl example.com

# تصفية النتائج
gau example.com | grep -E "\.(js|css|php)$"

# عرض المساعدة
gau -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/lc/gau/v2/cmd/gau@latest

# أو تحميل من GitHub Releases
wget https://github.com/lc/gau/releases/latest/download/gau_2.1.2_linux_amd64.tar.gz
tar -xzf gau_2.1.2_linux_amd64.tar.gz
sudo mv gau /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# GAU Test Script

echo "=== GAU Test Script ==="
echo "Testing GAU on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل GAU
echo "Running GAU..."
gau example.com > gau_results.txt

# عرض النتائج
if [ -f "gau_results.txt" ]; then
    echo "Results saved to: gau_results.txt"
    echo "Number of URLs found: $(wc -l < gau_results.txt)"
    echo
    echo "Sample URLs:"
    head -5 gau_results.txt
    echo
    echo "File extensions found:"
    grep -o '\.[a-zA-Z0-9]*$' gau_results.txt | sort | uniq -c | sort -nr | head -10
else
    echo "No results found"
fi

echo
echo "Test completed!"
```
