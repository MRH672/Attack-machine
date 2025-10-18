# HTTPx - أداة فحص HTTP/HTTPS

## 📋 الوظيفة
HTTPx هي أداة Go متعددة الوظائف لفحص HTTP/HTTPS، التحقق من حالة الخوادم، وجمع معلومات عن المواقع.

## 🚀 الاستخدامات
- فحص قوائم النطاقات الفرعية
- التحقق من حالة الخوادم (HTTP codes)
- جمع معلومات عن التكنولوجيا المستخدمة
- فحص الأمان والاستجابة
- تحليل البنية التحتية للمواقع

## 📝 الأوامر الأساسية
```bash
# فحص قائمة من النطاقات الفرعية
httpx -l subdomains.txt

# فحص مع عرض كود الحالة
httpx -l subdomains.txt -status-code

# فحص مع عرض العنوان
httpx -l subdomains.txt -title

# فحص مع عرض التكنولوجيا المستخدمة
httpx -l subdomains.txt -tech-detect

# فحص مع عرض حجم الاستجابة
httpx -l subdomains.txt -content-length

# استخدام وضع صامت
httpx -l subdomains.txt -silent

# فحص مع timeout مخصص
httpx -l subdomains.txt -timeout 10

# عرض المساعدة
httpx -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# أو تحميل من GitHub Releases
wget https://github.com/projectdiscovery/httpx/releases/latest/download/httpx_1.3.7_linux_amd64.zip
unzip httpx_1.3.7_linux_amd64.zip
sudo mv httpx /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# HTTPx Test Script

echo "=== HTTPx Test Script ==="
echo "Testing HTTPx on sample domains"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# إنشاء قائمة تجريبية من النطاقات
echo -e "http://example.com\nhttps://example.com\nhttp://google.com\nhttps://github.com" > test_domains.txt

echo "Test domains:"
cat test_domains.txt
echo

# تشغيل HTTPx مع خيارات مختلفة
echo "Running HTTPx with status codes..."
httpx -l test_domains.txt -status-code -o httpx_status.txt

echo "Running HTTPx with titles..."
httpx -l test_domains.txt -title -o httpx_titles.txt

echo "Running HTTPx with tech detection..."
httpx -l test_domains.txt -tech-detect -o httpx_tech.txt

# عرض النتائج
echo "Results:"
echo "Status codes:"
cat httpx_status.txt
echo
echo "Titles:"
cat httpx_titles.txt
echo
echo "Technologies:"
cat httpx_tech.txt

echo
echo "Test completed!"
```

