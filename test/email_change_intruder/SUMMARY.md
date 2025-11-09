# ملخص مشروع Email Change Intruder Extension

## نظرة عامة

تم إنشاء امتداد Burp Suite يقوم باكتشاف تلقائي لطلبات تغيير البريد الإلكتروني وإرسالها إلى Intruder للاختبار.

## الملفات المنشأة

### 1. EmailChangeIntruderExtension.java
- **الوصف:** الكود المصدري للامتداد
- **الوظيفة:** 
  - يراقب جميع طلبات HTTP عبر Proxy
  - يكتشف طلبات تغيير البريد تلقائياً
  - يميز الطلبات المكتشفة بلون أحمر
  - يوفر قائمة منبثقة لإرسال الطلبات إلى Intruder

### 2. build.ps1
- **الوصف:** سكريبت البناء لأجهزة Windows
- **الوظيفة:** 
  - يتحقق من تثبيت Java
  - يجمع الكود المصدري
  - ينشئ ملف JAR جاهز للاستخدام

### 3. README.md
- **الوصف:** الوثائق الكاملة للامتداد
- **المحتوى:** 
  - شرح المميزات
  - خطوات التثبيت
  - دليل الاستخدام
  - استكشاف الأخطاء

### 4. INSTALL.md
- **الوصف:** دليل التثبيت السريع
- **المحتوى:** 
  - متطلبات التثبيت
  - خطوات التجميع
  - نصائح للاستخدام

## المميزات الرئيسية

### ✅ الاكتشاف التلقائي
- يراقب جميع طلبات HTTP (POST/PUT/PATCH)
- يكتشف طلبات تغيير البريد بناءً على:
  - أنماط URL
  - معاملات البريد
  - محتوى Request Body

### ✅ التمييز البصري
- يميز الطلبات المكتشفة بلون **أحمر** في Proxy history
- يضيف تعليقات توضح معاملات البريد المكتشفة

### ✅ إرسال إلى Intruder
- يوفر قائمة منبثقة لإرسال الطلبات إلى Intruder
- يحدد تلقائياً معاملات البريد للاختبار

## المعاملات المدعومة

الامتداد يكتشف المعاملات التالية:
- `email`, `e-mail`, `mail`
- `new_email`, `newEmail`, `change_email`, `changeEmail`
- `update_email`, `updateEmail`, `user_email`, `userEmail`
- `account_email`, `accountEmail`
- وأكثر...

## أنماط URL المدعومة

- `change*email`, `update*email`, `modify*email`
- `edit*email`, `profile*email`, `account*email`
- `settings*email`, `user*email`

## خطوات الاستخدام

### 1. التجميع
```powershell
cd test\email_change_intruder
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

### 2. التثبيت
1. افتح Burp Suite
2. Extensions → Add → Java
3. اختر `EmailChangeIntruderExtension.jar`

### 3. الاستخدام
1. تفعيل Proxy
2. تصفح الموقع وتغيير البريد
3. افحص Proxy history للطلبات المميزة
4. انقر بزر الماوس الأيمن → Send Email Request to Intruder
5. أرسل من Repeater إلى Intruder
6. حدد معامل البريد وابدأ الاختبار

## المتطلبات

- **Java JDK 11+** (للتصريف)
- **Burp Suite** Community أو Professional
- **burpsuite_community.jar** (موجود في المجلد الرئيسي)

## البنية التقنية

### الكلاسات المستخدمة
- `IBurpExtender` - واجهة الامتداد الأساسية
- `IHttpListener` - للاستماع إلى طلبات HTTP
- `IContextMenuFactory` - لإنشاء القوائم المنبثقة

### الطرق الرئيسية
- `processHttpMessage()` - معالجة الطلبات
- `isEmailChangeRequest()` - التحقق من طلبات تغيير البريد
- `findEmailParameters()` - البحث عن معاملات البريد
- `sendRequestToIntruder()` - إرسال إلى Intruder

## التطوير المستقبلي

### تحسينات محتملة
- [ ] إضافة واجهة GUI للتكوين
- [ ] دعم المزيد من أنماط URL
- [ ] إضافة فلاتر مخصصة
- [ ] دعم JSON و XML requests
- [ ] إضافة إحصائيات للطلبات المكتشفة

## الأمان

⚠️ **تحذير:** هذا الامتداد مخصص للاختبار الأمني فقط. استخدمه فقط على الأنظمة التي لديك إذن لاختبارها.

## الترخيص

هذا الامتداد متاح للاستخدام الحر للأغراض التعليمية والاختبار الأمني.

## المساهمة

للمساهمة في المشروع:
1. عدّل الكود المصدري
2. اختبر التغييرات
3. أعد التجميع والتحقق من العمل

## الدعم

للمساعدة أو الإبلاغ عن المشاكل:
- راجع **Output** tab في Burp Suite
- تحقق من الوثائق في README.md
- راجع [Burp Suite API Documentation](https://portswigger.net/burp/documentation/desktop/extensions/api)

---

**تم التطوير بواسطة:** Attack Machine Project  
**التاريخ:** 2024  
**الإصدار:** 1.0

