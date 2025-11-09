# دليل التثبيت السريع - Email Change Intruder Extension

## متطلبات التثبيت

### 1. تثبيت Java JDK

**Windows:**
1. قم بتحميل Java JDK 11 أو أحدث من [Adoptium](https://adoptium.net/)
2. قم بتثبيت JDK
3. أضف Java إلى PATH:
   - افتح System Properties → Environment Variables
   - أضف `C:\Program Files\Java\jdk-XX\bin` إلى PATH
   - أو استخدم Java بدون PATH باستخدام المسار الكامل

**التحقق من التثبيت:**
```bash
java -version
javac -version
```

### 2. تجميع الامتداد

**الطريقة 1: استخدام سكريبت البناء (موصى به)**
```powershell
cd test\email_change_intruder
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

**الطريقة 2: التجميع اليدوي**
```bash
# تأكد من وجود burpsuite_community.jar في المجلد الرئيسي
cd test\email_change_intruder
javac -cp "..\..\burpsuite_community.jar" EmailChangeIntruderExtension.java
jar cf EmailChangeIntruderExtension.jar EmailChangeIntruderExtension.class
```

### 3. تحميل الامتداد في Burp Suite

1. افتح **Burp Suite**
2. اذهب إلى **Extensions** tab
3. اضغط **Add**
4. اختر **Extension type: Java**
5. اضغط **Select file** واختر `EmailChangeIntruderExtension.jar`
6. اضغط **Next** ثم **Close**
7. تأكد من أن الحالة هي **Loaded** و **Enabled**

## استخدام الامتداد

### الخطوات الأساسية

1. **تفعيل Proxy** في Burp Suite
2. **تصفح الموقع** المستهدف
3. **غيّر البريد الإلكتروني** في إعدادات الحساب
4. **افحص Proxy history** - ستجد الطلب مميزاً باللون الأحمر
5. **انقر بزر الماوس الأيمن** على الطلب المميز
6. **اختر "Send Email Request to Intruder"**
7. **من Repeater**، أرسل الطلب إلى **Intruder** (Ctrl+I)
8. **في Intruder**، حدد معامل البريد للاختبار

## استكشاف الأخطاء

### خطأ: Java is not installed

**الحل:**
- قم بتثبيت Java JDK من [Adoptium](https://adoptium.net/)
- أضف Java إلى PATH
- أعد تشغيل Terminal/PowerShell

### خطأ: burpsuite_community.jar not found

**الحل:**
- تأكد من وجود الملف في `test/burpsuite_community.jar`
- أو قم بتشغيل `download_burpsuite_java_libraries.ps1` أولاً

### خطأ: Compilation failed

**الحل:**
- تأكد من استخدام Java JDK (وليس JRE فقط)
- تحقق من صحة المسار إلى `burpsuite_community.jar`
- تأكد من وجود `EmailChangeIntruderExtension.java` في المجلد الصحيح

### الامتداد لا يعمل في Burp Suite

**الحل:**
1. تحقق من **Output** tab في Extensions للأخطاء
2. تأكد من أن الامتداد **Loaded** و **Enabled**
3. أعد تشغيل Burp Suite
4. تحقق من توافق الإصدار مع Burp Suite

## نصائح للاستخدام

### أفضل الممارسات

1. **اختبر في بيئة آمنة** أولاً
2. **استخدم Payloads مناسبة** للاختبار
3. **راقب الاستجابات** في Intruder
4. **احفظ النتائج** المهمة

### أمثلة على Payloads

```
test@example.com
admin@example.com
user@example.com
victim@example.com
attacker@evil.com
```

### نصائح للاختبار

- استخدم **Sniper** attack type للاختبار السريع
- استخدم **Cluster bomb** للاختبار المتقدم
- راقب **Status codes** و **Length** في النتائج
- ابحث عن **Response differences** للثغرات المحتملة

## الدعم

للمزيد من المعلومات، راجع:
- [README.md](README.md) - الوثائق الكاملة
- [Burp Suite Extensions Documentation](https://portswigger.net/burp/documentation/desktop/extensions)
- [Burp Suite API Documentation](https://portswigger.net/burp/documentation/desktop/extensions/api)

