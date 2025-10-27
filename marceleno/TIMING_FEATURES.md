# ✨ ملف get_endpoints_timed.sh - النسخة المحسنة مع القياس الزمني

## 📊 المميزات الجديدة

### 1️⃣ **قياس زمني شامل**
- ✅ قياس زمن كل أدوات الـ subdomain enumeration بشكل منفصل
- ✅ قياس زمن كل أدوات الـ endpoint discovery بشكل منفصل
- ✅ قياس زمن التثبيت
- ✅ قياس الزمن الإجمالي للعملية بالكامل

### 2️⃣ **إحصائيات مفصلة**
```
✓ Total Subdomains Found: [عدد]
✓ Working Subdomains: [عدد]
✓ Total Endpoints Found: [عدد]
⚡ Total Execution Time: [وقت]
```

### 3️⃣ **رسائل مفصلة لكل خطوة**
- لكل أداة: يتم عرض الوقت المستغرق
- مثال: `Subfinder found 150 subdomains in 00:45`

### 4️⃣ **ملف statistics.txt**
- يحفظ تفاصيل كاملة عن العملية
- يتضمن التاريخ والنتائج والتوقيت

---

## 🔧 التحسينات الإضافية

### في Katana:
```bash
katana -silent -depth 3 -concurrency 20
```
- `depth 3`: زيادة العمق
- `concurrency 20`: تشغيل متوازي أسرع

### في HTTPx:
```bash
httpx -fc 200 -silent -threads 50
```
- `threads 50`: تشغيل أسرع بنحو 50 مؤشر ترابط

---

## 🚀 الاستخدام

```bash
sudo ./marceleno/get_endpoints_timed.sh example.com
```

### الملفات المخرجة:
- `all_endpoints.txt` - جميع الـ endpoints
- `js.txt` - ملفات JavaScript
- `php.txt` - ملفات PHP  
- `json.txt` - ملفات JSON
- `css.txt` - ملفات CSS
- `xml.txt` - ملفات XML
- `statistics.txt` - الإحصائيات والنتائج

---

## 📈 مثال على الإخراج:

```
=====================================================
  FINAL STATISTICS
=====================================================
✓ Total Subdomains Found: 250
✓ Working Subdomains: 180
✓ Total Endpoints Found: 5000
⚡ Total Execution Time: 01:23:45
=====================================================
```

---

## ⚡ مقارنة مع الملف الأصلي:

| الميزة | الأصلي | المحسن |
|--------|---------|--------|
| قياس الزمن | ❌ لا | ✅ نعم |
| إحصائيات | ❌ لا | ✅ نعم |
| توقيت جزئي | ❌ لا | ✅ لكل أداة |
| ملف إحصائيات | ❌ لا | ✅ statistics.txt |
| عرض التقدم | محدود | مفصل جداً |

