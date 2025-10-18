# Anew - أداة إزالة التكرار

## 📋 الوظيفة
Anew هي أداة Go لإضافة عناصر جديدة إلى ملف بدون تكرار، مفيدة جداً في دمج نتائج أدوات الاستكشاف المختلفة.

## 🚀 الاستخدامات
- دمج ملفات متعددة مع إزالة التكرار
- إضافة عناصر جديدة لملف موجود
- تنظيف نتائج أدوات الاستكشاف
- إنشاء قوائم فريدة من مصادر متعددة

## 📝 الأوامر الأساسية
```bash
# إضافة عنصر جديد لملف
echo "new-subdomain.com" | anew existing.txt

# دمج ملفين مع إزالة التكرار
cat file1.txt file2.txt | anew > merged.txt

# إضافة عناصر متعددة
echo -e "sub1.com\nsub2.com\nsub3.com" | anew subdomains.txt

# دمج عدة ملفات
cat *.txt | anew > all_unique.txt

# عرض المساعدة
anew -h
```

## 🔧 التثبيت
```bash
# تثبيت عبر Go
go install github.com/tomnomnom/anew@latest

# أو تحميل من GitHub
git clone https://github.com/tomnomnom/anew.git
cd anew
go build
sudo mv anew /usr/local/bin/
```

## ⚡ سكريبت تجريبي
```bash
#!/bin/bash
# Anew Test Script

echo "=== Anew Test Script ==="
echo "Testing Anew functionality"
echo

# إنشاء مجلد النتائج
mkdir -p results
cd results

# إنشاء ملفات تجريبية
echo -e "sub1.example.com\nsub2.example.com\nsub3.example.com" > file1.txt
echo -e "sub2.example.com\nsub3.example.com\nsub4.example.com" > file2.txt
echo -e "sub3.example.com\nsub4.example.com\nsub5.example.com" > file3.txt

echo "Created test files:"
echo "File1: $(cat file1.txt)"
echo "File2: $(cat file2.txt)"
echo "File3: $(cat file3.txt)"
echo

# دمج الملفات مع إزالة التكرار
echo "Merging files with anew..."
cat file1.txt file2.txt file3.txt | anew > merged.txt

# عرض النتائج
if [ -f "merged.txt" ]; then
    echo "Merged results saved to: merged.txt"
    echo "Unique entries: $(wc -l < merged.txt)"
    echo "Content:"
    cat merged.txt
else
    echo "No results found"
fi

echo
echo "Test completed!"
```
