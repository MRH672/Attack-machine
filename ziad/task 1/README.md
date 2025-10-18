# 🛠️ Subdomain Enumeration Tools Collection

## 📁 هيكل المشروع
```
ziad/
└── task 1/
    ├── Sublist3r.md      # أداة استكشاف النطاقات الفرعية
    ├── Subfinder.md      # أداة استكشاف سريعة
    ├── Assetfinder.md    # أداة استكشاف من مصادر متعددة
    ├── Amass.md          # أداة استكشاف شاملة
    ├── HTTPx.md          # أداة فحص HTTP/HTTPS
    ├── GAU.md            # أداة جمع URLs
    ├── Waybackurls.md    # أداة جمع من Wayback Machine
    ├── Anew.md           # أداة إزالة التكرار
    ├── Curl.md           # أداة تحميل البيانات
    ├── Wget.md           # أداة تحميل الملفات
    ├── tools             # قائمة الأدوات
    └── install_tools.sh  # سكريبت التثبيت التلقائي
```

## 🚀 التثبيت السريع على لينكس

### 1. تحميل المشروع
```bash
# تحميل المشروع من GitHub
git clone https://github.com/YOUR_USERNAME/Attack-machine.git
cd Attack-machine/ziad/task\ 1/
```

### 2. تثبيت الأدوات تلقائياً
```bash
# جعل سكريبت التثبيت قابل للتنفيذ
chmod +x install_tools.sh

# تشغيل التثبيت التلقائي
sudo ./install_tools.sh
```

### 3. اختبار الأدوات
```bash
# اختبار Sublist3r
bash Sublist3r_test.sh

# اختبار Subfinder
bash Subfinder_test.sh

# اختبار HTTPx
bash HTTPx_test.sh
```

## 📋 الأدوات المتوفرة

| الأداة | الوظيفة | الملف |
|--------|---------|-------|
| **Sublist3r** | استكشاف النطاقات الفرعية | `Sublist3r.md` |
| **Subfinder** | استكشاف سريع | `Subfinder.md` |
| **Assetfinder** | استكشاف من مصادر متعددة | `Assetfinder.md` |
| **Amass** | استكشاف شامل | `Amass.md` |
| **HTTPx** | فحص HTTP/HTTPS | `HTTPx.md` |
| **GAU** | جمع URLs | `GAU.md` |
| **Waybackurls** | جمع من Wayback Machine | `Waybackurls.md` |
| **Anew** | إزالة التكرار | `Anew.md` |
| **Curl** | تحميل البيانات | `Curl.md` |
| **Wget** | تحميل الملفات | `Wget.md` |

## 🔧 المتطلبات

- **Linux** (Ubuntu/Debian/Kali)
- **Go** 1.19+
- **Python 3** 3.7+
- **Git**
- **صلاحيات sudo**

## 📖 كيفية الاستخدام

### قراءة التوثيق
```bash
# عرض ملف أداة معينة
cat Sublist3r.md

# تصفح الملفات
less Subfinder.md
```

### تشغيل السكريبتات التجريبية
```bash
# جعل السكريبتات قابلة للتنفيذ
chmod +x *_test.sh

# تشغيل اختبار أداة معينة
./Sublist3r_test.sh
```

## 🌐 الاستخدام من Terminal

### مثال شامل لاستكشاف النطاقات الفرعية
```bash
# 1. استكشاف النطاقات الفرعية
subfinder -d example.com -silent > subfinder.txt
assetfinder --subs-only example.com > assetfinder.txt
amass enum -d example.com -silent > amass.txt

# 2. دمج النتائج وإزالة التكرار
cat subfinder.txt assetfinder.txt amass.txt | anew > all_subdomains.txt

# 3. فحص النطاقات الفرعية النشطة
httpx -l all_subdomains.txt -status-code -title -o active_subdomains.txt
```

### مثال لجمع URLs
```bash
# جمع URLs من مصادر مختلفة
gau example.com > gau_urls.txt
waybackurls example.com > wayback_urls.txt

# دمج وتحليل
cat gau_urls.txt wayback_urls.txt | anew > all_urls.txt
httpx -l all_urls.txt -status-code -o live_urls.txt
```

## 📝 ملاحظات مهمة

- تأكد من تثبيت جميع الأدوات قبل الاستخدام
- استخدم `sudo` عند الحاجة لصلاحيات إدارية
- تحقق من الاتصال بالإنترنت للتحميل
- احفظ النتائج في ملفات منظمة

## 🔗 روابط مفيدة

- [ProjectDiscovery Tools](https://github.com/projectdiscovery)
- [TomNomNom Tools](https://github.com/tomnomnom)
- [OWASP Amass](https://github.com/OWASP/Amass)
- [Sublist3r](https://github.com/aboul3la/Sublist3r)

## 📞 الدعم

للحصول على المساعدة:
- راجع ملفات التوثيق الفردية
- تحقق من سكريبتات الاختبار
- استخدم `-h` مع أي أداة لعرض المساعدة
