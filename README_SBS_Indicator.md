# مؤشر SBS MODEL للتداول - دليل الاستخدام
# SBS MODEL Trading Indicator - User Guide

## نظرة عامة / Overview

مؤشر SBS MODEL هو أداة تداول متقدمة مصممة لمنصة MetaTrader 5 تقوم بتحليل مستويات الدعم والمقاومة وتوفر إشارات تداول دقيقة مع رسم خطوط الفيبوناتشي التلقائية.

The SBS MODEL indicator is an advanced trading tool designed for MetaTrader 5 platform that analyzes support and resistance levels and provides accurate trading signals with automatic Fibonacci line drawing.

## الميزات الرئيسية / Key Features

### 1. استراتيجية SBS MODEL / SBS MODEL Strategy
- تحليل مستويات الدعم والمقاومة بدقة عالية
- كشف كسر المستويات المهمة
- تأكيد الإشارات بعدة شروط

### 2. رسم الفيبوناتشي التلقائي / Automatic Fibonacci Drawing
- رسم مستويات الفيبوناتشي تلقائياً عند الإشارات
- مستويات رئيسية: 0%, 23.6%, 38.2%, 50%, 61.8%, 100%
- ألوان وأنماط قابلة للتخصيص

### 3. مستويات الربح والخسارة / Profit & Loss Levels
- مستويات الربح (Take Profit) باللون الأخضر
- مستويات الخسارة (Stop Loss) باللون الأحمر
- حساب تلقائي بناءً على المضاعفات المحددة

### 4. الإشارات البصرية / Visual Signals
- أسهم خضراء للشراء
- أسهم حمراء للبيع
- إشارات واضحة ومرئية على الشارت

## المعاملات والإعدادات / Parameters & Settings

### إعدادات الاستراتيجية / Strategy Settings
- **SBS_Period (14)**: فترة حساب مستويات الدعم والمقاومة
- **BreakoutThreshold (0.0001)**: حد الكسر المطلوب لتأكيد الإشارة
- **MinCandlesForSignal (3)**: الحد الأدنى للشموع المطلوبة للإشارة

### إعدادات الفيبوناتشي / Fibonacci Settings
- **ShowFibonacci (true)**: تفعيل/إلغاء رسم خطوط الفيبوناتشي
- **FibPeriod (50)**: فترة البحث عن النقاط العالية والمنخفضة
- **FibColor (Yellow)**: لون خطوط الفيبوناتشي

### إعدادات الربح والخسارة / Profit & Loss Settings
- **TakeProfitMultiplier (2.0)**: مضاعف حساب مستوى الربح
- **StopLossMultiplier (1.0)**: مضاعف حساب مستوى الخسارة
- **ShowLevels (true)**: عرض مستويات الربح والخسارة

### إعدادات التنبيهات / Alert Settings
- **EnableAlerts (true)**: تفعيل التنبيهات الصوتية
- **SendNotifications (false)**: إرسال إشعارات للهاتف المحمول
- **PlaySounds (true)**: تشغيل الأصوات عند الإشارات

## طريقة الاستخدام / How to Use

### 1. التثبيت / Installation
```
1. انسخ ملف SBS_Model_Indicator.mq5 إلى مجلد Indicators في MetaTrader 5
2. أعد تشغيل MetaTrader 5 أو اضغط F5 لتحديث المؤشرات
3. اسحب المؤشر من نافذة Navigator إلى الشارت المطلوب
```

### 2. قراءة الإشارات / Reading Signals

#### إشارات الشراء / Buy Signals
- سهم أخضر تحت الشمعة
- كسر مستوى المقاومة
- رسم فيبوناتشي من الأدنى إلى الأعلى
- مستوى الربح الأخضر فوق السعر

#### إشارات البيع / Sell Signals
- سهم أحمر فوق الشمعة
- كسر مستوى الدعم
- رسم فيبوناتشي من الأعلى إلى الأدنى
- مستوى الربح الأخضر تحت السعر

### 3. إدارة المخاطر / Risk Management
- استخدم مستويات Stop Loss المعروضة
- لا تتجاهل إشارات الخروج
- طبق إدارة رأس المال المناسبة

## استراتيجية التداول / Trading Strategy

### شروط الدخول للشراء / Buy Entry Conditions
1. كسر السعر لمستوى المقاومة المحدد
2. تأكيد الكسر بشمعة إغلاق فوق المستوى
3. ظهور سهم الشراء الأخضر
4. رسم فيبوناتشي تلقائي

### شروط الدخول للبيع / Sell Entry Conditions
1. كسر السعر لمستوى الدعم المحدد
2. تأكيد الكسر بشمعة إغلاق تحت المستوى
3. ظهور سهم البيع الأحمر
4. رسم فيبوناتشي تلقائي

### أهداف الربح / Profit Targets
- استخدم مستويات الفيبوناتشي كأهداف
- المستوى الأول: 38.2%
- المستوى الثاني: 61.8%
- المستوى الثالث: 100%

### وقف الخسارة / Stop Loss
- المستوى المعروض باللون الأحمر
- يُحسب تلقائياً بناءً على StopLossMultiplier
- يُنصح بعدم تجاوز 2% من رأس المال

## نصائح التداول / Trading Tips

### أفضل الممارسات / Best Practices
1. **استخدم على إطارات زمنية متعددة**: تأكد من الإشارات على إطارات أكبر
2. **انتظر التأكيد**: لا تدخل فور ظهور السهم، انتظر إغلاق الشمعة
3. **راقب الحجم**: الإشارات مع حجم عالي أكثر موثوقية
4. **تجنب الأخبار**: لا تتداول أثناء الأخبار المهمة

### الأزواج الموصى بها / Recommended Pairs
- EUR/USD
- GBP/USD  
- USD/JPY
- AUD/USD
- USD/CAD

### الإطارات الزمنية المناسبة / Suitable Timeframes
- H1 (ساعة واحدة) - للتداول اليومي
- H4 (4 ساعات) - للتداول المتوسط المدى
- D1 (يومي) - للتداول طويل المدى

## استكشاف الأخطاء / Troubleshooting

### مشاكل شائعة وحلولها / Common Issues & Solutions

#### عدم ظهور الإشارات / No Signals Appearing
- تأكد من أن البيانات التاريخية كافية
- تحقق من إعدادات SBS_Period
- قلل من قيمة BreakoutThreshold

#### رسم فيبوناتشي غير صحيح / Incorrect Fibonacci Drawing
- تأكد من تفعيل ShowFibonacci
- اضبط FibPeriod حسب الإطار الزمني
- تحقق من وجود نقاط عالية ومنخفضة كافية

#### كثرة الإشارات الخاطئة / Too Many False Signals
- زد من قيمة MinCandlesForSignal
- زد من BreakoutThreshold
- استخدم إطارات زمنية أكبر

## دعم فني / Technical Support

للحصول على الدعم الفني أو الإبلاغ عن مشاكل:
- GitHub: https://github.com/mizo82580/hamza82580
- تأكد من تضمين تفاصيل المشكلة وإعدادات المؤشر

## إخلاء المسؤولية / Disclaimer

هذا المؤشر مخصص للأغراض التعليمية والتحليلية. التداول في الأسواق المالية ينطوي على مخاطر عالية وقد يؤدي إلى خسارة رأس المال. تأكد من فهمك للمخاطر قبل التداول واستشر مستشار مالي مؤهل.

This indicator is for educational and analytical purposes. Trading in financial markets involves high risk and may result in capital loss. Make sure you understand the risks before trading and consult a qualified financial advisor.

---

**الإصدار / Version**: 1.0  
**التاريخ / Date**: 2024  
**المطور / Developer**: hamza82580  
**الترخيص / License**: GNU LGPL v2.1