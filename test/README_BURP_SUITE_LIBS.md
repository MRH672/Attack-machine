# مكتبات Java الخاصة بـ Burp Suite

## نظرة عامة
تم تحميل جميع مكتبات Java المطلوبة لتشغيل وتطوير امتدادات Burp Suite في هذا المجلد.

## الملفات المحملة

### 1. Burp Suite Community Edition
- **الملف:** `burpsuite_community.jar`
- **الحجم:** ~0.12 MB
- **الوصف:** النسخة المجتمعية من Burp Suite

### 2. مكتبات Java (في مجلد `java_libs/`)

#### مكتبات JSON
- `gson-2.10.1.jar` - مكتبة Gson لمعالجة JSON
- `jackson-core-2.16.0.jar` - مكتبة Jackson Core
- `jackson-databind-2.16.0.jar` - مكتبة Jackson Data Binding
- `jackson-annotations-2.16.0.jar` - مكتبة Jackson Annotations
- `json-20231013.jar` - مكتبة JSON الأساسية

#### مكتبات Apache Commons
- `commons-lang3-3.14.0.jar` - Apache Commons Lang
- `commons-io-2.15.1.jar` - Apache Commons IO
- `commons-codec-1.16.0.jar` - Apache Commons Codec
- `commons-logging-1.2.jar` - Apache Commons Logging
- `commons-collections4-4.4.jar` - Apache Commons Collections

#### مكتبات HTTP
- `httpclient-4.5.14.jar` - Apache HttpClient 4
- `httpcore-4.4.16.jar` - Apache HttpCore 4
- `httpclient5-5.2.1.jar` - Apache HttpClient 5
- `httpcore5-5.2.2.jar` - Apache HttpCore 5

#### مكتبات أخرى
- `guava-32.1.3-jre.jar` - Google Guava
- `jsoup-1.17.2.jar` - JSoup HTML Parser
- `snakeyaml-2.2.jar` - SnakeYAML لمعالجة YAML
- `slf4j-api-2.0.9.jar` - SLF4J API للوظائف السجل
- `slf4j-simple-2.0.9.jar` - SLF4J Simple Implementation

## متطلبات التشغيل

### Java Runtime Environment (JRE)
- يتطلب Java 11 أو أحدث
- للتحقق من إصدار Java:
  ```bash
  java -version
  ```
- إذا لم يكن Java مثبتاً، قم بتحميله من:
  - [OpenJDK (موصى به)](https://adoptium.net/)
  - [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
  - [Amazon Corretto](https://aws.amazon.com/corretto/)

## كيفية الاستخدام

### تشغيل Burp Suite
```bash
java -jar burpsuite_community.jar
```

### تطوير امتدادات Burp Suite
1. أضف مكتبات Java من مجلد `java_libs/` إلى classpath المشروع
2. استخرج API classes من `burpsuite_community.jar`:
   ```bash
   jar xf burpsuite_community.jar burp/
   ```
3. استخدم API classes المستخرجة في مشروعك

## هيكل المجلدات
```
test/
├── burpsuite_community.jar       # ملف Burp Suite الرئيسي
├── java_libs/                     # مجلد مكتبات Java
│   ├── gson-2.10.1.jar
│   ├── jackson-core-2.16.0.jar
│   ├── commons-io-2.15.1.jar
│   └── ... (بقية المكتبات)
└── download_burpsuite_java_libraries.ps1  # سكريبت التحميل
```

## ملاحظات مهمة

1. **Burp Suite API:** API classes مدمجة في ملف `burpsuite_community.jar` وليست مكتبة منفصلة على Maven Central
2. **التحديثات:** يمكن تحديث المكتبات من خلال تشغيل السكريبت `download_burpsuite_java_libraries.ps1`
3. **التراخيص:** تأكد من قراءة تراخيص كل مكتبة قبل الاستخدام التجاري

## إعادة التحميل
لإعادة تحميل جميع المكتبات، قم بتشغيل:
```powershell
powershell -ExecutionPolicy Bypass -File .\download_burpsuite_java_libraries.ps1
```

## الدعم
للمزيد من المعلومات:
- [وثائق Burp Suite](https://portswigger.net/burp/documentation)
- [دليل تطوير الامتدادات](https://portswigger.net/burp/documentation/desktop/extensions)

