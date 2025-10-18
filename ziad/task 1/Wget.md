# Wget - أداة تحميل الملفات من الويب

## 📋 الوظيفة
Wget هي أداة سطر الأوامر لتحميل الملفات من الويب، تدعم HTTP, HTTPS, FTP, FTPS. تتميز بقدرتها على إعادة المحاولة والتحميل المتقطع.

## 🚀 الاستخدامات
- تحميل الملفات والمواقع من الويب
- تحميل مواقع كاملة (mirroring)
- تحميل مع إعادة المحاولة التلقائية
- تحميل في الخلفية
- تحميل متقطع للملفات الكبيرة

## 📝 الأوامر الأساسية
```bash
# تحميل ملف
wget https://example.com/file.txt

# تحميل صفحة ويب
wget https://example.com

# تحميل مع إعادة المحاولة
wget --tries=3 https://example.com/file.txt

# تحميل في الخلفية
wget -b https://example.com/file.txt

# تحميل مع timeout
wget --timeout=30 https://example.com/file.txt

# تحميل موقع كامل
wget --mirror --convert-links --adjust-extension https://example.com

# تحميل مع تصفية الامتدادات
wget -r -A "*.pdf,*.doc" https://example.com

# تحميل مع استكمال التحميل المتقطع
wget -c https://example.com/largefile.zip

# عرض المساعدة
wget --help
```

## 🔧 التثبيت
```bash
# على Ubuntu/Debian
sudo apt-get install wget

# على CentOS/RHEL
sudo yum install wget

# على macOS
brew install wget

# على Windows
# تحميل من https://www.gnu.org/software/wget/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Wget Test Script

echo "=== Wget Test Script ==="
echo "Testing Wget functionality"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# اختبارات مختلفة
echo "1. Testing basic file download..."
wget -q https://httpbin.org/robots.txt -O wget_robots.txt
echo "Robots.txt downloaded"

echo "2. Testing with retries..."
wget --tries=3 -q https://httpbin.org/json -O wget_json.txt
echo "JSON file downloaded with retries"

echo "3. Testing with timeout..."
wget --timeout=10 -q https://httpbin.org/html -O wget_html.txt
echo "HTML file downloaded with timeout"

echo "4. Testing resume capability..."
# محاكاة التحميل المتقطع
wget -c -q https://httpbin.org/bytes/1024 -O wget_bytes.txt
echo "Binary file downloaded"

# عرض النتائج
echo
echo "Results:"
echo "Files downloaded:"
ls -la wget_*.txt

echo
echo "File contents preview:"
echo "Robots.txt:"
head -3 wget_robots.txt
echo
echo "JSON:"
head -3 wget_json.txt

echo
echo "Test completed!"
```

