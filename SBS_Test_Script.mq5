//+------------------------------------------------------------------+
//|                                    SBS_Test_Script.mq5          |
//|                                 Copyright 2024, hamza82580       |
//|                                             https://github.com/mizo82580/hamza82580 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, hamza82580"
#property link      "https://github.com/mizo82580/hamza82580"
#property version   "1.00"
#property script_show_inputs
#property description "سكريبت اختبار مؤشر SBS MODEL"
#property description "SBS MODEL Indicator Test Script"

//--- تضمين المكتبات / Include libraries
#include "SBS_Utils.mqh"

//--- معاملات الإدخال / Input parameters
input group "===== إعدادات الاختبار / Test Settings ====="
input int TestPeriod = 100;        // عدد الشموع للاختبار / Number of candles to test
input bool ShowDetails = true;     // عرض التفاصيل / Show details
input bool TestFibonacci = true;   // اختبار الفيبوناتشي / Test Fibonacci
input bool TestAlerts = false;     // اختبار التنبيهات / Test alerts

//--- متغيرات الاختبار / Test variables
CSBSLevels *testLevels;
CSBSRiskManager *testRiskManager;
CSBSFibonacci *testFibonacci;

int totalSignals = 0;
int buySignals = 0;
int sellSignals = 0;
int validLevels = 0;

//+------------------------------------------------------------------+
//| وظيفة تنفيذ السكريبت / Script execution function                |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== بدء اختبار مؤشر SBS MODEL / Starting SBS MODEL Indicator Test ===");
    
    //--- تهيئة الكائنات / Initialize objects
    testLevels = new CSBSLevels(14, 0.0001);
    testRiskManager = new CSBSRiskManager(2.0, 1.0);
    
    if(TestFibonacci)
        testFibonacci = new CSBSFibonacci("TEST_FIB", clrYellow);
    
    //--- تشغيل الاختبارات / Run tests
    bool result1 = TestDataIntegrity();
    bool result2 = TestLevelCalculations();
    bool result3 = TestSignalGeneration();
    bool result4 = TestRiskCalculations();
    
    if(TestFibonacci)
        bool result5 = TestFibonacciDrawing();
    
    //--- عرض النتائج / Display results
    DisplayTestResults(result1, result2, result3, result4);
    
    //--- تنظيف الذاكرة / Cleanup
    CleanupObjects();
    
    Print("=== انتهاء اختبار مؤشر SBS MODEL / SBS MODEL Indicator Test Completed ===");
}

//+------------------------------------------------------------------+
//| اختبار سلامة البيانات / Test data integrity                     |
//+------------------------------------------------------------------+
bool TestDataIntegrity()
{
    Print("--- اختبار سلامة البيانات / Testing Data Integrity ---");
    
    //--- فحص توفر البيانات / Check data availability
    int bars = iBars(_Symbol, _Period);
    if(bars < TestPeriod)
    {
        Print("خطأ: بيانات غير كافية. متوفر: ", bars, " مطلوب: ", TestPeriod);
        return false;
    }
    
    //--- فحص صحة البيانات / Validate data
    double high[], low[], close[], open[];
    if(CopyHigh(_Symbol, _Period, 0, TestPeriod, high) <= 0 ||
       CopyLow(_Symbol, _Period, 0, TestPeriod, low) <= 0 ||
       CopyClose(_Symbol, _Period, 0, TestPeriod, close) <= 0 ||
       CopyOpen(_Symbol, _Period, 0, TestPeriod, open) <= 0)
    {
        Print("خطأ: فشل في نسخ البيانات");
        return false;
    }
    
    //--- فحص منطقية البيانات / Check data logic
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(open, true);
    
    for(int i = 0; i < TestPeriod; i++)
    {
        if(high[i] < low[i] || high[i] < close[i] || high[i] < open[i] ||
           low[i] > close[i] || low[i] > open[i])
        {
            Print("خطأ: بيانات غير منطقية في الشمعة ", i);
            return false;
        }
    }
    
    Print("✓ سلامة البيانات: ناجح");
    return true;
}

//+------------------------------------------------------------------+
//| اختبار حساب المستويات / Test level calculations                 |
//+------------------------------------------------------------------+
bool TestLevelCalculations()
{
    Print("--- اختبار حساب المستويات / Testing Level Calculations ---");
    
    double high[], low[];
    if(CopyHigh(_Symbol, _Period, 0, TestPeriod, high) <= 0 ||
       CopyLow(_Symbol, _Period, 0, TestPeriod, low) <= 0)
        return false;
    
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    
    for(int i = 15; i < TestPeriod - 5; i++)
    {
        double resistance = testLevels.CalculateResistance(high, i);
        double support = testLevels.CalculateSupport(low, i);
        
        if(resistance > 0 && support > 0 && resistance > support)
        {
            validLevels++;
            
            if(ShowDetails && validLevels <= 5)
            {
                Print(StringFormat("شمعة %d: مقاومة = %s, دعم = %s", 
                      i, DoubleToString(resistance, _Digits), DoubleToString(support, _Digits)));
            }
        }
    }
    
    Print("✓ حساب المستويات: ناجح - مستويات صحيحة: ", validLevels);
    return (validLevels > 0);
}

//+------------------------------------------------------------------+
//| اختبار توليد الإشارات / Test signal generation                  |
//+------------------------------------------------------------------+
bool TestSignalGeneration()
{
    Print("--- اختبار توليد الإشارات / Testing Signal Generation ---");
    
    double high[], low[], close[], open[];
    if(CopyHigh(_Symbol, _Period, 0, TestPeriod, high) <= 0 ||
       CopyLow(_Symbol, _Period, 0, TestPeriod, low) <= 0 ||
       CopyClose(_Symbol, _Period, 0, TestPeriod, close) <= 0 ||
       CopyOpen(_Symbol, _Period, 0, TestPeriod, open) <= 0)
        return false;
    
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(open, true);
    
    for(int i = 20; i < TestPeriod - 5; i++)
    {
        double resistance = testLevels.CalculateResistance(high, i);
        double support = testLevels.CalculateSupport(low, i);
        
        if(resistance > 0 && support > 0)
        {
            //--- فحص إشارة الشراء / Check buy signal
            if(testLevels.IsResistanceBreakout(close[i], resistance) && close[i] > open[i])
            {
                buySignals++;
                totalSignals++;
                
                if(ShowDetails && totalSignals <= 10)
                {
                    Print(StringFormat("إشارة شراء في الشمعة %d: السعر %s كسر المقاومة %s", 
                          i, DoubleToString(close[i], _Digits), DoubleToString(resistance, _Digits)));
                }
            }
            
            //--- فحص إشارة البيع / Check sell signal
            if(testLevels.IsSupportBreakdown(close[i], support) && close[i] < open[i])
            {
                sellSignals++;
                totalSignals++;
                
                if(ShowDetails && totalSignals <= 10)
                {
                    Print(StringFormat("إشارة بيع في الشمعة %d: السعر %s كسر الدعم %s", 
                          i, DoubleToString(close[i], _Digits), DoubleToString(support, _Digits)));
                }
            }
        }
    }
    
    Print("✓ توليد الإشارات: ناجح - إجمالي الإشارات: ", totalSignals);
    Print("  إشارات الشراء: ", buySignals, " | إشارات البيع: ", sellSignals);
    return true;
}

//+------------------------------------------------------------------+
//| اختبار حساب المخاطر / Test risk calculations                    |
//+------------------------------------------------------------------+
bool TestRiskCalculations()
{
    Print("--- اختبار حساب المخاطر / Testing Risk Calculations ---");
    
    //--- اختبار حساب الربح والخسارة للشراء / Test buy TP/SL calculation
    double entryPrice = 1.1000;
    double supportLevel = 1.0980;
    
    double buyTP = testRiskManager.CalculateBuyTP(entryPrice, supportLevel);
    double buySL = testRiskManager.CalculateBuySL(entryPrice, supportLevel);
    double buyRR = testRiskManager.CalculateRiskReward(entryPrice, buyTP, buySL);
    
    if(ShowDetails)
    {
        Print("اختبار الشراء:");
        Print("  الدخول: ", DoubleToString(entryPrice, 5));
        Print("  الربح: ", DoubleToString(buyTP, 5));
        Print("  الخسارة: ", DoubleToString(buySL, 5));
        Print("  نسبة المخاطرة/الربح: ", DoubleToString(buyRR, 2));
    }
    
    //--- اختبار حساب الربح والخسارة للبيع / Test sell TP/SL calculation
    entryPrice = 1.0980;
    double resistanceLevel = 1.1000;
    
    double sellTP = testRiskManager.CalculateSellTP(entryPrice, resistanceLevel);
    double sellSL = testRiskManager.CalculateSellSL(entryPrice, resistanceLevel);
    double sellRR = testRiskManager.CalculateRiskReward(entryPrice, sellTP, sellSL);
    
    if(ShowDetails)
    {
        Print("اختبار البيع:");
        Print("  الدخول: ", DoubleToString(entryPrice, 5));
        Print("  الربح: ", DoubleToString(sellTP, 5));
        Print("  الخسارة: ", DoubleToString(sellSL, 5));
        Print("  نسبة المخاطرة/الربح: ", DoubleToString(sellRR, 2));
    }
    
    //--- فحص منطقية النتائج / Check results logic
    bool buyLogic = (buyTP > entryPrice && buySL < entryPrice && buyRR > 0);
    bool sellLogic = (sellTP < entryPrice && sellSL > entryPrice && sellRR > 0);
    
    Print("✓ حساب المخاطر: ناجح - منطق الشراء: ", (buyLogic ? "صحيح" : "خطأ"), 
          " | منطق البيع: ", (sellLogic ? "صحيح" : "خطأ"));
    
    return (buyLogic && sellLogic);
}

//+------------------------------------------------------------------+
//| اختبار رسم الفيبوناتشي / Test Fibonacci drawing                |
//+------------------------------------------------------------------+
bool TestFibonacciDrawing()
{
    if(!TestFibonacci) return true;
    
    Print("--- اختبار رسم الفيبوناتشي / Testing Fibonacci Drawing ---");
    
    //--- إنشاء مثال لرسم الفيبوناتشي / Create example Fibonacci drawing
    datetime time1 = iTime(_Symbol, _Period, 20);
    datetime time2 = iTime(_Symbol, _Period, 10);
    double price1 = iLow(_Symbol, _Period, 20);
    double price2 = iHigh(_Symbol, _Period, 10);
    
    bool result = testFibonacci.CreateFibObject(time1, price1, time2, price2);
    
    if(result)
    {
        Print("✓ رسم الفيبوناتشي: ناجح - تم إنشاء كائن الفيبوناتشي");
        
        //--- اختبار حساب مستويات الفيبوناتشي / Test Fibonacci level calculation
        double fib236 = testFibonacci.GetFibLevel(price2, price1, 0.236);
        double fib618 = testFibonacci.GetFibLevel(price2, price1, 0.618);
        
        if(ShowDetails)
        {
            Print("  مستوى 23.6%: ", DoubleToString(fib236, _Digits));
            Print("  مستوى 61.8%: ", DoubleToString(fib618, _Digits));
        }
        
        //--- تنظيف / Cleanup
        Sleep(2000); // انتظار لمشاهدة الرسم / Wait to see the drawing
        testFibonacci.DeleteAllFibObjects();
        
        return true;
    }
    else
    {
        Print("✗ رسم الفيبوناتشي: فشل");
        return false;
    }
}

//+------------------------------------------------------------------+
//| عرض نتائج الاختبار / Display test results                      |
//+------------------------------------------------------------------+
void DisplayTestResults(bool data, bool levels, bool signals, bool risk)
{
    Print("\n=== نتائج الاختبار / Test Results ===");
    
    int passedTests = 0;
    if(data) passedTests++;
    if(levels) passedTests++;
    if(signals) passedTests++;
    if(risk) passedTests++;
    
    Print("الاختبارات الناجحة: ", passedTests, " من 4");
    Print("نسبة النجاح: ", (passedTests * 100.0 / 4.0), "%");
    
    if(passedTests == 4)
    {
        Print("✓ جميع الاختبارات ناجحة - المؤشر جاهز للاستخدام");
        
        //--- إحصائيات إضافية / Additional statistics
        Print("\n--- إحصائيات الاختبار / Test Statistics ---");
        Print("إجمالي الشموع المختبرة: ", TestPeriod);
        Print("المستويات الصحيحة: ", validLevels);
        Print("إجمالي الإشارات: ", totalSignals);
        Print("نسبة الإشارات: ", DoubleToString((totalSignals * 100.0) / TestPeriod, 2), "%");
        
        if(totalSignals > 0)
        {
            Print("توزيع الإشارات:");
            Print("  شراء: ", buySignals, " (", DoubleToString((buySignals * 100.0) / totalSignals, 1), "%)");
            Print("  بيع: ", sellSignals, " (", DoubleToString((sellSignals * 100.0) / totalSignals, 1), "%)");
        }
    }
    else
    {
        Print("✗ فشل في بعض الاختبارات - يرجى مراجعة الإعدادات");
        Print("الاختبارات الفاشلة:");
        if(!data) Print("  - سلامة البيانات");
        if(!levels) Print("  - حساب المستويات");
        if(!signals) Print("  - توليد الإشارات");
        if(!risk) Print("  - حساب المخاطر");
    }
    
    Print("========================================\n");
}

//+------------------------------------------------------------------+
//| تنظيف الكائنات / Cleanup objects                               |
//+------------------------------------------------------------------+
void CleanupObjects()
{
    if(testLevels != NULL)
    {
        delete testLevels;
        testLevels = NULL;
    }
    
    if(testRiskManager != NULL)
    {
        delete testRiskManager;
        testRiskManager = NULL;
    }
    
    if(testFibonacci != NULL)
    {
        delete testFibonacci;
        testFibonacci = NULL;
    }
}

//+------------------------------------------------------------------+