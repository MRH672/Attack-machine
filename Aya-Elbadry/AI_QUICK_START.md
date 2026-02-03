# دليل البدء السريع - AI Quick Start Guide
# Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)

## 🚀 البدء السريع (5 دقائق)

### الخطوة 1: تثبيت المكتبات (اختياري)
```bash
pip install scikit-learn requests
```

### الخطوة 2: توليد Payloads جديدة
```bash
python ai_payload_manager.py generate --waf Cloudflare --count 5
```

### الخطوة 3: تحديث تلقائي
```bash
python ai_payload_manager.py update
```

### الخطوة 4: استخدام مع sqlmap
```bash
python sqlmap.py -u "http://target.com/page?id=1" --level=3
```

**✅ جاهز! النظام الآن يتعلم ويتطور تلقائياً**

---

## 📋 الأوامر الأساسية

### توليد
```bash
python ai_payload_manager.py generate --type boolean --waf Cloudflare
```

### تحديث
```bash
python ai_payload_manager.py update
```

### تحليل
```bash
python ai_payload_manager.py analyze
```

### توصيات
```bash
python ai_payload_manager.py recommend --waf Cloudflare
```

### تعلم
```bash
python ai_payload_manager.py learn --payload "AND/**/1=1" --success --waf Cloudflare
```

---

## 🎯 كيف يعمل؟

1. **توليد** → النظام يولد payloads جديدة
2. **اختبار** → sqlmap يختبرها
3. **تعلم** → النظام يتعلم من النتائج
4. **تطور** → يطور payloads أفضل
5. **تكرار** → العملية مستمرة

---

## 📁 الملفات

- `lib/ai_payload_generator.py` - المحرك الأساسي
- `lib/ai_payload_integrator.py` - التكامل
- `ai_payload_manager.py` - الواجهة
- `data/ai_learning_db.json` - قاعدة البيانات

---

**للمزيد:** راجع `AI_INTEGRATION_GUIDE.md`

