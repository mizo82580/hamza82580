# دليل التثبيت السريع - SBS MODEL Trading System
# Quick Installation Guide - SBS MODEL Trading System

## متطلبات التثبيت / Installation Requirements

### 1. المتطلبات الأساسية / Basic Requirements
- **MetaTrader 5** (Build 3200 أو أحدث / Build 3200 or later)
- **نظام التشغيل / OS**: Windows 10/11, Mac OS, Linux
- **الذاكرة / RAM**: 4 GB أو أكثر / 4 GB or more
- **مساحة القرص / Disk Space**: 100 MB حرة / 100 MB free

### 2. الأذونات المطلوبة / Required Permissions
- السماح بالتداول التلقائي / Allow automated trading
- السماح باستيراد DLL / Allow DLL imports
- السماح بالتعديل على الإعدادات / Allow settings modification

## خطوات التثبيت / Installation Steps

### الخطوة 1: تنزيل الملفات / Step 1: Download Files
```
1. انتقل إلى مستودع GitHub / Go to GitHub repository
2. انقر على "Code" ثم "Download ZIP" / Click "Code" then "Download ZIP"
3. استخرج الملفات إلى مجلد مؤقت / Extract files to temporary folder
```

### الخطوة 2: نسخ الملفات / Step 2: Copy Files
```
1. افتح MetaTrader 5
2. اضغط Ctrl+Shift+D لفتح مجلد البيانات
3. انسخ الملفات كما يلي / Copy files as follows:

الملفات المطلوب نسخها / Files to copy:
├── MQL5/Indicators/
│   ├── SBS_Model_Indicator.mq5
│   └── SBS_Utils.mqh
├── MQL5/Experts/
│   └── SBS_Model_EA.mq5
├── MQL5/Scripts/
│   └── SBS_Test_Script.mq5
└── MQL5/Files/
    └── SBS_Config_Template.txt
```

### الخطوة 3: إعادة التحميل / Step 3: Reload
```
1. في MetaTrader 5، اضغط F5 لإعادة تحميل المؤشرات
2. أو أعد تشغيل MetaTrader 5 بالكامل
3. تحقق من ظهور الملفات في Navigator
```

## التحقق من التثبيت / Installation Verification

### 1. فحص المؤشر / Check Indicator
```
1. افتح Navigator (Ctrl+N)
2. انتقل إلى Indicators > Custom
3. يجب أن تجد "SBS_Model_Indicator"
4. اسحبه إلى أي شارت للاختبار
```

### 2. فحص الخبير / Check Expert Advisor
```
1. في Navigator، انتقل إلى Expert Advisors
2. يجب أن تجد "SBS_Model_EA"
3. اسحبه إلى شارت واضبط الإعدادات
```

### 3. تشغيل اختبار التشخيص / Run Diagnostic Test
```
1. في Navigator، انتقل إلى Scripts
2. اسحب "SBS_Test_Script" إلى الشارت
3. اضغط OK لتشغيل الاختبار
4. راجع النتائج في نافذة Experts
```

## الإعداد الأولي / Initial Setup

### 1. إعدادات المؤشر الأساسية / Basic Indicator Settings
```
الإعدادات الموصى بها للمبتدئين / Recommended settings for beginners:
- SBS_Period: 14
- BreakoutThreshold: 0.0001
- ShowFibonacci: true
- ShowLevels: true
- EnableAlerts: true
```

### 2. إعدادات الخبير الأساسية / Basic EA Settings
```
إعدادات آمنة للبداية / Safe settings for start:
- LotSize: 0.01
- MaxRiskPercent: 1.0
- TakeProfitMultiplier: 2.0
- StopLossMultiplier: 1.0
- MaxOrders: 1
```

### 3. اختبار على حساب تجريبي / Test on Demo Account
```
⚠️ مهم جداً / Very Important:
1. اختبر دائماً على حساب تجريبي أولاً
2. راقب الأداء لمدة أسبوع على الأقل
3. اضبط الإعدادات حسب النتائج
4. لا تستخدم على حساب حقيقي قبل التأكد
```

## استكشاف الأخطاء / Troubleshooting

### المشكلة: المؤشر لا يظهر / Problem: Indicator doesn't appear
```
الحلول / Solutions:
1. تأكد من نسخ الملفات في المجلد الصحيح
2. تأكد من أن MetaTrader 5 محدث
3. أعد تشغيل MetaTrader 5 بالكامل
4. تحقق من رسائل الخطأ في نافذة Experts
```

### المشكلة: لا توجد إشارات / Problem: No signals
```
الحلول / Solutions:
1. تأكد من وجود بيانات تاريخية كافية
2. اضبط BreakoutThreshold إلى قيمة أصغر
3. قلل MinCandlesForSignal
4. جرب إطاراً زمنياً مختلفاً
```

### المشكلة: كثرة الإشارات الخاطئة / Problem: Too many false signals
```
الحلول / Solutions:
1. زد BreakoutThreshold
2. زد MinCandlesForSignal
3. استخدم إطاراً زمنياً أكبر
4. فعل فلتر الوقت في الإعدادات
```

### المشكلة: الخبير لا يتداول / Problem: EA doesn't trade
```
الحلول / Solutions:
1. تأكد من تفعيل "Allow automated trading"
2. تحقق من إعدادات MaxOrders
3. تأكد من وجود رصيد كافي
4. راجع رسائل الخطأ في Experts
```

## نصائح مهمة / Important Tips

### 🎯 للمبتدئين / For Beginners
```
1. ابدأ بالإعدادات الافتراضية
2. اختبر على حساب تجريبي لمدة شهر
3. تعلم قراءة الإشارات قبل التداول
4. لا تغير الإعدادات بناءً على صفقة واحدة
```

### 📊 للمتقدمين / For Advanced Users
```
1. اضبط الإعدادات حسب الزوج والإطار الزمني
2. استخدم تحليل متعدد الإطارات
3. ادمج مع مؤشرات أخرى للتأكيد
4. طور استراتيجية إدارة مخاطر شخصية
```

### ⚠️ تحذيرات مهمة / Important Warnings
```
1. لا تستخدم مبالغ كبيرة في البداية
2. راقب الأداء باستمرار
3. كن مستعداً لتعديل الإعدادات
4. تذكر أن التداول ينطوي على مخاطر
```

## الدعم الفني / Technical Support

### للحصول على المساعدة / For Help
```
1. راجع README_SBS_Indicator.md للدليل المفصل
2. تحقق من SBS_Config_Template.txt للإعدادات
3. شغل SBS_Test_Script.mq5 للتشخيص
4. أبلغ عن المشاكل في GitHub Issues
```

### معلومات مفيدة للدعم / Useful Info for Support
```
عند طلب المساعدة، قدم / When asking for help, provide:
1. إصدار MetaTrader 5
2. الزوج والإطار الزمني المستخدم
3. الإعدادات المطبقة
4. رسائل الخطأ (إن وجدت)
5. لقطة شاشة من الشارت
```

---

## ملاحظات أخيرة / Final Notes

✅ **تم التثبيت بنجاح؟ / Successfully Installed?**
- المؤشر يظهر على الشارت
- الإشارات تظهر بوضوح
- اختبار التشخيص ناجح
- لا توجد رسائل خطأ

🎉 **مبروك! أنت جاهز للبدء / Congratulations! You're ready to start**

تذكر: التداول المسؤول هو المفتاح للنجاح
Remember: Responsible trading is the key to success

---

**آخر تحديث / Last Updated**: 2024  
**الإصدار / Version**: 1.0  
**المطور / Developer**: hamza82580