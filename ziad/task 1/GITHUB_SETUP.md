# 🚀 تعليمات رفع المشروع على GitHub

## 📋 خطوات رفع المشروع

### 1. إنشاء Repository جديد على GitHub
```bash
# اذهب إلى https://github.com/new
# اختر اسم للمشروع: Attack-machine
# اختر Public أو Private حسب رغبتك
# لا تضع README أو .gitignore (موجود بالفعل)
```

### 2. رفع المشروع من Terminal
```bash
# الانتقال لمجلد المشروع
cd /path/to/Attack-machine

# تهيئة Git
git init

# إضافة جميع الملفات
git add .

# عمل commit أولي
git commit -m "Initial commit: Subdomain Enumeration Tools Collection"

# إضافة Remote repository
git remote add origin https://github.com/YOUR_USERNAME/Attack-machine.git

# رفع المشروع
git push -u origin main
```

### 3. استخدام المشروع من Terminal لينكس
```bash
# تحميل المشروع
git clone https://github.com/YOUR_USERNAME/Attack-machine.git
cd Attack-machine/ziad/task\ 1/

# تثبيت الأدوات
sudo chmod +x install_tools.sh
sudo ./install_tools.sh

# اختبار الأدوات
./test_all_tools.sh
```

## 📁 هيكل المشروع النهائي
```
Attack-machine/
├── .gitignore
├── README.md
└── ziad/
    └── task 1/
        ├── README.md
        ├── install_tools.sh
        ├── .gitignore
        ├── Sublist3r.md
        ├── Subfinder.md
        ├── Assetfinder.md
        ├── Amass.md
        ├── HTTPx.md
        ├── GAU.md
        ├── Waybackurls.md
        ├── Anew.md
        ├── Curl.md
        ├── Wget.md
        └── tools
```

## 🔧 أوامر Git مفيدة

### تحديث المشروع
```bash
# إضافة التغييرات
git add .

# عمل commit
git commit -m "Update: Added new features"

# رفع التحديثات
git push origin main
```

### تحميل التحديثات
```bash
# تحميل آخر التحديثات
git pull origin main
```

### إنشاء Branch جديد
```bash
# إنشاء branch جديد
git checkout -b new-feature

# العمل على التغييرات
# ... تعديل الملفات ...

# رفع Branch جديد
git push origin new-feature
```

## 📝 ملاحظات مهمة

1. **تأكد من تحديث URL** في README.md ليحتوي على اسم المستخدم الصحيح
2. **استخدم أوصاف واضحة** في commit messages
3. **احفظ ملفات النتائج** في .gitignore لتجنب رفعها
4. **اختبر المشروع** بعد التحميل للتأكد من عمله

## 🌐 روابط مفيدة

- [GitHub Documentation](https://docs.github.com/)
- [Git Commands Reference](https://git-scm.com/docs)
- [Markdown Guide](https://www.markdownguide.org/)

## 📞 الدعم

للحصول على المساعدة:
- راجع ملفات التوثيق الفردية
- تحقق من سكريبت التثبيت
- استخدم `-h` مع أي أداة لعرض المساعدة

