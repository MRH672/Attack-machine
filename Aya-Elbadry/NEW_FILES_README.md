# ملفات جديدة - New Files
# Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)

## 📁 الملفات الجديدة

### 1. `data/txt/new Agents.txt`
- **الوصف:** ملف يحتوي على 50+ User Agent جديد
- **الغرض:** تخطي كشف WAF وإخفاء الهوية
- **المحتوى:**
  - Chrome, Firefox, Edge, Safari, Opera
  - Mobile (iOS & Android)
  - Tor Browser
  - Browsers غير شائعة

### 2. `data/xml/payloads/new_payloads.xml`
- **الوصف:** ملف يحتوي على 25+ SQL Injection Payload جديد
- **الغرض:** تخطي WAF (Akamai, Cloudflare, Imperva, etc.)
- **التقنيات:**
  - Comment Obfuscation (/**/)
  - Space Obfuscation (%09, %0A)
  - Case Variation
  - Double Encoding
  - Nested Functions

### 3. `NEW_FILES_DOCUMENTATION.md`
- **الوصف:** توثيق شامل للملفات الجديدة
- **المحتوى:** تعليمات الاستخدام، أمثلة، استكشاف الأخطاء

---

## 🚀 الاستخدام السريع

### استخدام User Agents الجديدة:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --random-agent
```

### استخدام Payloads الجديدة:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --level=3 --risk=2
```

### استخدام Tor:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor --check-tor
```

### استخدام كل شيء معاً:
```bash
python sqlmap.py -u "http://target.com/page?id=1" \
  --tor \
  --random-agent \
  --level=3 \
  --risk=2 \
  --tamper=space2comment,charencode
```

---

## ⚙️ الإعداد

تم تحديث `lib/core/settings.py` تلقائياً لإضافة `new_payloads.xml` إلى قائمة Payloads.

---

## 📖 للمزيد من التفاصيل

راجع ملف `NEW_FILES_DOCUMENTATION.md` للحصول على:
- شرح مفصل لكل ملف
- أمثلة متقدمة
- استكشاف الأخطاء
- أفضل الممارسات

---

**تم الإنشاء بواسطة:** Aya Elbadry (@Aya-Elbadry)  
**التاريخ:** 2025

