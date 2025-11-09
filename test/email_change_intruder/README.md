# Email Change Intruder Extension

## الوصف

امتداد Burp Suite يقوم باكتشاف تلقائي لطلبات تغيير البريد الإلكتروني وتمييزها لإرسالها إلى Intruder بسهولة.

## المميزات

- ✅ **اكتشاف تلقائي** لطلبات تغيير البريد الإلكتروني (POST/PUT/PATCH)
- ✅ **تحديد معاملات البريد** تلقائياً في الطلبات
- ✅ **تمييز الطلبات** بلون أحمر في Proxy history
- ✅ **قائمة منبثقة** لإرسال الطلبات إلى Intruder بنقرة واحدة
- ✅ **دعم أنماط URL** المختلفة لعمليات تغيير البريد
- ✅ **اكتشاف معاملات البريد** في URL parameters و request body

## كيفية التثبيت

### المتطلبات

- Burp Suite Community Edition أو Professional
- Java JDK 11 أو أحدث
- ملف `burpsuite_community.jar` في المجلد الرئيسي

### خطوات التثبيت

#### 1. تجميع الامتداد

**على Windows (PowerShell):**
```powershell
cd test\email_change_intruder
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

**على Linux/Mac:**
```bash
cd test/email_change_intruder
javac -cp "../burpsuite_community.jar" EmailChangeIntruderExtension.java
jar cf EmailChangeIntruderExtension.jar EmailChangeIntruderExtension.class
```

#### 2. تحميل الامتداد في Burp Suite

1. افتح Burp Suite
2. اذهب إلى **Extensions** tab
3. اضغط على **Add** button
4. اختر **Extension type: Java**
5. اضغط **Select file** واختر `EmailChangeIntruderExtension.jar`
6. اضغط **Next** ثم **Close**
7. تأكد من أن الامتداد **Loaded** و **Enabled**

## كيفية الاستخدام

### الاستخدام التلقائي

1. تأكد من تفعيل **Proxy** في Burp Suite
2. قم بتصفح الموقع وحدوث تغيير البريد الإلكتروني
3. سيقوم الامتداد تلقائياً بـ:
   - اكتشاف طلبات تغيير البريد
   - تمييزها بلون **أحمر** في Proxy history
   - إضافة تعليق يوضح معاملات البريد المكتشفة

### إرسال إلى Intruder

**الطريقة 1: استخدام القائمة المنبثقة**
1. في **Proxy → HTTP history**
2. انقر بزر الماوس الأيمن على الطلب المميز (باللون الأحمر)
3. اختر **"Send Email Request to Intruder"**
4. سيتم إرسال الطلب إلى **Repeater**
5. من Repeater، أرسله إلى **Intruder** (Ctrl+I)
6. في Intruder، حدد معامل البريد للاختبار

**الطريقة 2: يدوياً**
1. في **Proxy → HTTP history**
2. ابحث عن الطلبات المميزة باللون الأحمر
3. انقر بزر الماوس الأيمن → **Send to Intruder**
4. حدد معامل البريد للاختبار

## المعاملات المدعومة

الامتداد يكتشف المعاملات التالية:

- `email`, `e-mail`, `mail`
- `email_address`, `emailAddress`
- `new_email`, `newEmail`, `newemail`
- `change_email`, `changeEmail`, `changeemail`
- `update_email`, `updateEmail`, `updateemail`
- `user_email`, `userEmail`, `useremail`
- `account_email`, `accountEmail`, `accountemail`
- `old_email`, `oldEmail`
- `current_email`, `currentEmail`

## أنماط URL المدعومة

الامتداد يكتشف URLs تحتوي على:

- `change*email`
- `update*email`
- `modify*email`
- `edit*email`
- `profile*email`
- `account*email`
- `settings*email`
- `user*email`

## مثال على الاستخدام

### سيناريو الاختبار

1. **تمكين الامتداد** في Burp Suite
2. **تصفح الموقع** المستهدف
3. **تغيير البريد الإلكتروني** في إعدادات الحساب
4. **فحص Proxy history** - ستجد الطلب مميزاً باللون الأحمر
5. **إرسال إلى Intruder** باستخدام القائمة المنبثقة
6. **تكوين Payloads** في Intruder:
   - اختر معامل البريد
   - أضف payloads للاختبار (مثلاً: قائمة بريديات)
   - ابدأ الهجوم

### مثال على Payloads للاختبار

```
test@example.com
admin@example.com
user@example.com
victim@example.com
```

## هيكل المشروع

```
email_change_intruder/
├── EmailChangeIntruderExtension.java  # الكود المصدري
├── build.ps1                          # سكريبت البناء (Windows)
├── EmailChangeIntruderExtension.jar   # ملف JAR (بعد البناء)
└── README.md                          # هذا الملف
```

## استكشاف الأخطاء

### الامتداد لا يعمل

1. تأكد من تحميل الامتداد في **Extensions** tab
2. تحقق من **Output** tab للأخطاء
3. تأكد من وجود Java 11+ مثبت
4. تحقق من توافق الإصدار مع Burp Suite

### لا يتم اكتشاف الطلبات

1. تأكد من تفعيل **Proxy**
2. تحقق من أن الطلبات هي **POST/PUT/PATCH**
3. تأكد من وجود معاملات البريد في الطلب
4. راجع **Output** tab للرسائل

### خطأ في التجميع

1. تأكد من وجود `burpsuite_community.jar` في المجلد الرئيسي
2. تحقق من تثبيت Java JDK (وليس JRE فقط)
3. تأكد من صحة مسار الملفات

## التطوير

### تعديل الكود

للتعديل على الامتداد:

1. عدّل `EmailChangeIntruderExtension.java`
2. أعد التجميع باستخدام `build.ps1`
3. أعد تحميل الامتداد في Burp Suite

### إضافة معاملات جديدة

لإضافة معاملات جديدة للكشف، عدّل مصفوفة `EMAIL_KEYWORDS`:

```java
private static final String[] EMAIL_KEYWORDS = {
    "email",
    "your_new_keyword",  // أضف هنا
    // ...
};
```

### إضافة أنماط URL جديدة

لإضافة أنماط URL جديدة، عدّل مصفوفة `EMAIL_CHANGE_PATTERNS`:

```java
private static final String[] EMAIL_CHANGE_PATTERNS = {
    ".*change.*email.*",
    ".*your_pattern.*",  // أضف هنا
    // ...
};
```

## الأمان

⚠️ **تحذير:** هذا الامتداد مخصص للاختبار الأمني فقط. استخدمه فقط على الأنظمة التي لديك إذن لاختبارها.

## الترخيص

هذا الامتداد متاح للاستخدام الحر للأغراض التعليمية والاختبار الأمني.

## الدعم

للمساعدة أو الإبلاغ عن المشاكل:
- راجع **Output** tab في Burp Suite للأخطاء
- تحقق من وثائق [Burp Suite API](https://portswigger.net/burp/documentation/desktop/extensions/api)

## التحديثات

### الإصدار 1.0
- إصدار أولي
- اكتشاف تلقائي لطلبات تغيير البريد
- تمييز الطلبات في Proxy history
- قائمة منبثقة لإرسال إلى Intruder

---

**تم التطوير بواسطة:** Attack Machine Project  
**التاريخ:** 2024

