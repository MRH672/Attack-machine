# Curl - أداة تحميل البيانات من الخوادم

## 📋 الوظيفة
Curl هي أداة سطر الأوامر لتحميل البيانات من الخوادم أو إرسال البيانات إليها، تدعم العديد من البروتوكولات مثل HTTP, HTTPS, FTP, FTPS.

## 🚀 الاستخدامات
- تحميل صفحات الويب والملفات
- اختبار APIs و endpoints
- فحص رؤوس HTTP
- تحميل الملفات من الخوادم
- اختبار الاتصال بالخوادم

## 📝 الأوامر الأساسية
```bash
# تحميل صفحة ويب
curl https://example.com

# حفظ النتائج في ملف
curl https://example.com -o page.html

# فحص رؤوس HTTP فقط
curl -I https://example.com

# فحص مع عرض معلومات مفصلة
curl -v https://example.com

# تحميل مع إعادة التوجيه
curl -L https://example.com

# فحص كود الحالة فقط
curl -L -s -o /dev/null -w "%{http_code}" https://example.com

# إرسال POST request
curl -X POST -d "data=value" https://example.com/api

# استخدام معاملات مخصصة
curl -H "User-Agent: Custom" https://example.com
```

## 🔧 التثبيت
```bash
# على Ubuntu/Debian
sudo apt-get install curl

# على CentOS/RHEL
sudo yum install curl

# على macOS
brew install curl

# على Windows
# تحميل من https://curl.se/download.html
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Curl Test Script

echo "=== Curl Test Script ==="
echo "Testing Curl functionality"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# اختبارات مختلفة
echo "1. Testing basic HTTP request..."
curl -s https://httpbin.org/get > curl_basic.txt
echo "Basic request completed"

echo "2. Testing HTTP headers..."
curl -I https://httpbin.org/get > curl_headers.txt
echo "Headers request completed"

echo "3. Testing status code..."
STATUS_CODE=$(curl -L -s -o /dev/null -w "%{http_code}" https://httpbin.org/get)
echo "Status code: $STATUS_CODE"

echo "4. Testing POST request..."
curl -X POST -d "test=data" https://httpbin.org/post > curl_post.txt
echo "POST request completed"

# عرض النتائج
echo
echo "Results:"
echo "Basic response saved to: curl_basic.txt"
echo "Headers saved to: curl_headers.txt"
echo "POST response saved to: curl_post.txt"

echo
echo "Test completed!"
```

