# مؤشر SBS MODEL للتداول - SBS MODEL Trading Indicator

مجموعة شاملة من أدوات التداول لمنصة MetaTrader 5 تتضمن مؤشر SBS MODEL مع رسم الفيبوناتشي التلقائي ومستويات الربح والخسارة.

A comprehensive trading tools collection for MetaTrader 5 platform including SBS MODEL indicator with automatic Fibonacci drawing and profit/loss levels.

## المحتويات / Contents

### الملفات الرئيسية / Main Files

1. **SBS_Model_Indicator.mq5** - المؤشر الرئيسي / Main Indicator
2. **SBS_Model_EA.mq5** - الخبير التلقائي / Expert Advisor
3. **SBS_Utils.mqh** - مكتبة الوظائف المساعدة / Utility Functions Library
4. **README_SBS_Indicator.md** - دليل الاستخدام التفصيلي / Detailed User Guide

## الميزات الرئيسية / Key Features

### 🎯 استراتيجية SBS MODEL / SBS MODEL Strategy
- تحليل مستويات الدعم والمقاومة بدقة عالية
- كشف كسر المستويات المهمة مع التأكيد
- شروط دخول وخروج واضحة ومحددة

### 📈 رسم الفيبوناتشي التلقائي / Automatic Fibonacci Drawing
- رسم مستويات الفيبوناتشي تلقائياً عند الإشارات
- مستويات رئيسية: 0%, 23.6%, 38.2%, 50%, 61.8%, 100%
- ألوان وأنماط قابلة للتخصيص

### 💰 مستويات الربح والخسارة / Profit & Loss Levels
- مستويات الربح (Take Profit) باللون الأخضر
- مستويات الخسارة (Stop Loss) باللون الأحمر
- حساب تلقائي بناءً على المضاعفات المحددة

### 🔔 الإشارات والتنبيهات / Signals & Alerts
- أسهم خضراء للشراء وحمراء للبيع
- تنبيهات صوتية عند الإشارات
- إشعارات للهاتف المحمول (اختيارية)

## التثبيت والاستخدام / Installation & Usage

### 1. التثبيت / Installation
```
1. انسخ الملفات إلى مجلد Indicators في MetaTrader 5
2. أعد تشغيل MetaTrader 5 أو اضغط F5
3. اسحب المؤشر من Navigator إلى الشارت
```

### 2. الإعدادات الموصى بها / Recommended Settings
- **SBS_Period**: 14 للإطارات الزمنية الصغيرة، 21 للكبيرة
- **BreakoutThreshold**: 0.0001 للأزواج الرئيسية
- **TakeProfitMultiplier**: 2.0 لنسبة مخاطرة 1:2
- **StopLossMultiplier**: 1.0 للحماية المناسبة

### 3. أفضل الممارسات / Best Practices
- استخدم على إطارات زمنية متعددة للتأكيد
- انتظر إغلاق الشمعة قبل التداول
- طبق إدارة رأس المال المناسبة
- تجنب التداول أثناء الأخبار المهمة

## الأزواج والإطارات الزمنية / Pairs & Timeframes

### الأزواج الموصى بها / Recommended Pairs
- EUR/USD, GBP/USD, USD/JPY
- AUD/USD, USD/CAD, NZD/USD
- EUR/GBP, EUR/JPY, GBP/JPY

### الإطارات الزمنية المناسبة / Suitable Timeframes
- **H1**: للتداول اليومي
- **H4**: للتداول المتوسط المدى  
- **D1**: للتداول طويل المدى

## المتطلبات التقنية / Technical Requirements

- **المنصة**: MetaTrader 5
- **الإصدار**: Build 3200 أو أحدث
- **الذاكرة**: 4 GB RAM أو أكثر
- **المعالج**: Intel Core i3 أو مكافئ

## الدعم والتطوير / Support & Development

### الإبلاغ عن المشاكل / Report Issues
يرجى الإبلاغ عن أي مشاكل أو اقتراحات من خلال:
Please report any issues or suggestions through:
- GitHub Issues في هذا المستودع / GitHub Issues in this repository

### التطوير المستقبلي / Future Development
- [ ] إضافة مؤشرات فنية إضافية للتأكيد
- [ ] تحسين خوارزمية كشف الإشارات
- [ ] إضافة نظام إدارة المخاطر المتقدم
- [ ] دعم التداول متعدد الأزواج

## إخلاء المسؤولية / Disclaimer

⚠️ **تحذير مهم / Important Warning**

هذه الأدوات مخصصة للأغراض التعليمية والتحليلية فقط. التداول في الأسواق المالية ينطوي على مخاطر عالية وقد يؤدي إلى خسارة رأس المال. تأكد من فهمك للمخاطر قبل التداول واستشر مستشار مالي مؤهل.

These tools are for educational and analytical purposes only. Trading in financial markets involves high risk and may result in capital loss. Make sure you understand the risks before trading and consult a qualified financial advisor.

## الترخيص / License

هذا المشروع مرخص تحت رخصة GNU LGPL v2.1 - انظر ملف [LICENSE](LICENSE) للتفاصيل.

This project is licensed under the GNU LGPL v2.1 License - see the [LICENSE](LICENSE) file for details.

---

**الإصدار / Version**: 1.0  
**المطور / Developer**: hamza82580  
**التاريخ / Date**: 2024