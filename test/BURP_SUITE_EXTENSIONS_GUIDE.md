# دليل Extensions في Burp Suite

## ما هو تبويب Extensions؟

تبويب **Extensions** في Burp Suite يسمح لك بتحميل وتشغيل امتدادات (Extensions) تضيف وظائف إضافية للأداة. هذه الامتدادات يمكن أن تكون:
- **Java Extensions**: مكتوبة بلغة Java
- **Python Extensions**: مكتوبة بلغة Python
- **Ruby Extensions**: مكتوبة بلغة Ruby

## كيفية الوصول إلى Extensions

1. افتح Burp Suite
2. اذهب إلى التبويب **Extensions** في القائمة العلوية
3. ستجد قائمة بجميع الامتدادات المثبتة

## أنواع Extensions

### 1. Java Extensions
- الأكثر شيوعاً وقوة
- يمكن الوصول الكامل إلى Burp Suite API
- تحتاج إلى تجميع (compile) قبل الاستخدام

### 2. Python Extensions
- أسهل في التطوير
- تحتاج إلى Jython
- محدودة في الوصول إلى بعض الوظائف

### 3. Ruby Extensions
- تحتاج إلى JRuby
- أقل شيوعاً من Java و Python

## BApp Store

BApp Store هو متجر الامتدادات الرسمي لـ Burp Suite، يحتوي على مئات الامتدادات المجانية والمدفوعة.

### الوصول إلى BApp Store
1. في تبويب Extensions، اضغط على **BApp Store**
2. تصفح الامتدادات المتاحة
3. اضغط **Install** لتثبيت أي امتداد

## امتدادات شائعة ومفيدة

### 1. Active Scan++
- يحسن من جودة فحوصات Active Scan
- يضيف فحوصات إضافية

### 2. Retire.js
- يكتشف مكتبات JavaScript قديمة ومعرضة للثغرات

### 3. J2EEScan
- يفحص تطبيقات Java EE بحثاً عن ثغرات شائعة

### 4. Param Miner
- يكتشف معاملات مخفية في الطلبات

### 5. Collaborator Everywhere
- يضيف معاملات Collaborator تلقائياً للطلبات

### 6. Logger++
- يسجل جميع الطلبات والاستجابات بشكل متقدم

### 7. Autorize
- يفحص صلاحيات الوصول (Authorization)

### 8. JWT Editor
- يحرر ويفحص رموز JWT

### 9. Content-Type Converter
- يحول أنواع المحتوى في الطلبات

### 10. Turbo Intruder
- أداة متقدمة لإرسال الطلبات بسرعة عالية

## كيفية تثبيت Extension

### من BApp Store
1. افتح Extensions → BApp Store
2. ابحث عن الامتداد المطلوب
3. اضغط **Install**

### من ملف JAR
1. في Extensions، اضغط **Add**
2. اختر **Extension type**: Java
3. اضغط **Select file** واختر ملف `.jar`
4. اضغط **Next** ثم **Close**

### من ملف Python
1. في Extensions، اضغط **Add**
2. اختر **Extension type**: Python
3. اضغط **Select file** واختر ملف `.py`
4. تأكد من تثبيت Jython
5. اضغط **Next** ثم **Close**

## إدارة Extensions

### تفعيل/تعطيل Extension
- استخدم مربع الاختيار بجانب اسم الامتداد

### تحديث Extension
- في BApp Store، ستجد زر **Update** بجانب الامتدادات المثبتة

### حذف Extension
- اضغط على الامتداد → **Remove**

### عرض Output
- اضغط على الامتداد → **Output** لرؤية السجلات والأخطاء

## تطوير Extension خاص بك

### متطلبات تطوير Java Extension
1. **Burp Suite API**: موجود في `burpsuite_community.jar`
2. **مكتبات Java**: موجودة في مجلد `java_libs/`
3. **Java Development Kit (JDK)**: للإ编译

### خطوات إنشاء Java Extension بسيط

```java
import burp.*;

public class MyExtension implements IBurpExtender {
    private IBurpExtenderCallbacks callbacks;
    private IExtensionHelpers helpers;
    
    @Override
    public void registerExtenderCallbacks(IBurpExtenderCallbacks callbacks) {
        this.callbacks = callbacks;
        this.helpers = callbacks.getHelpers();
        
        callbacks.setExtensionName("My Custom Extension");
        callbacks.printOutput("Extension loaded successfully!");
    }
}
```

### تجميع Extension
```bash
javac -cp "burpsuite_community.jar" MyExtension.java
jar cf MyExtension.jar MyExtension.class
```

## استخراج Burp Suite API

للتطوير، تحتاج إلى استخراج API classes من JAR:

```bash
jar xf burpsuite_community.jar burp/
```

ثم استخدم `burp/` في classpath عند التجميع.

## نصائح مهمة

1. **اختبار الامتدادات**: اختبر الامتدادات في بيئة آمنة قبل استخدامها في بيئة إنتاج
2. **الأمان**: بعض الامتدادات قد تحتوي على ثغرات، استخدم فقط من مصادر موثوقة
3. **الأداء**: بعض الامتدادات قد تبطئ Burp Suite، راقب الأداء
4. **التوافق**: تأكد من توافق الامتداد مع إصدار Burp Suite الخاص بك

## حل المشاكل الشائعة

### Extension لا يعمل
- تحقق من Output tab للأخطاء
- تأكد من توافق الإصدار
- تحقق من Java/Jython/JRuby

### Extension بطيء
- بعض الامتدادات تستهلك موارد كثيرة
- جرب تعطيل امتدادات أخرى

### خطأ في التحميل
- تحقق من صحة ملف JAR/PY
- تأكد من وجود جميع المكتبات المطلوبة

## روابط مفيدة

- [Burp Suite Extensions Documentation](https://portswigger.net/burp/documentation/desktop/extensions)
- [Burp Suite API Documentation](https://portswigger.net/burp/documentation/desktop/extensions/api)
- [BApp Store](https://portswigger.net/bappstore)
- [Extension Development Examples](https://github.com/PortSwigger/example-custom-scan-checks)

