# Sublist3r - أداة استكشاف النطاقات الفرعية

## 📋 الوظيفة
Sublist3r هي أداة Python متقدمة لاستكشاف النطاقات الفرعية باستخدام مصادر متعددة مثل محركات البحث وقواعد البيانات العامة.

## 🚀 الاستخدامات
- استكشاف النطاقات الفرعية لنطاق معين
- البحث في مصادر متعددة (Google, Yahoo, Bing, Baidu, etc.)
- جمع معلومات شاملة عن البنية التحتية للموقع
- استخدام في اختبارات الاختراق الأخلاقي

## 📝 الأوامر الأساسية
```bash
# الاستخدام الأساسي
python3 sublist3r.py -d example.com

# حفظ النتائج في ملف
python3 sublist3r.py -d example.com -o subdomains.txt

# استخدام مصادر محددة
python3 sublist3r.py -d example.com -e google,yahoo,bing

# استخدام جميع المصادر المتاحة
python3 sublist3r.py -d example.com -e all

# عرض المساعدة
python3 sublist3r.py -h
```

## 🔧 التثبيت
```bash
# تحميل من GitHub
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
pip3 install -r requirements.txt
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Sublist3r Test Script

echo "=== Sublist3r Test Script ==="
echo "Testing Sublist3r on example.com"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# تشغيل Sublist3r
echo "Running Sublist3r..."
python3 ../sublist3r.py -d example.com -o sublist3r_results.txt

# عرض النتائج
if [ -f "sublist3r_results.txt" ]; then
    echo "Results saved to: sublist3r_results.txt"
    echo "Number of subdomains found: $(wc -l < sublist3r_results.txt)"
    echo
    echo "Sample results:"
    head -5 sublist3r_results.txt
else
    echo "No results found"
fi

echo
echo "Test completed!"
```
