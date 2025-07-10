//+------------------------------------------------------------------+
//|                                          SBS_Model_Indicator.mq5 |
//|                                 Copyright 2024, hamza82580       |
//|                                             https://github.com/mizo82580/hamza82580 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, hamza82580"
#property link      "https://github.com/mizo82580/hamza82580"
#property version   "1.00"
#property description "مؤشر استراتيجية SBS MODEL مع رسم الفيبوناتشي التلقائي ومستويات الربح والخسارة"
#property description "SBS MODEL Strategy Indicator with Automatic Fibonacci and Profit/Loss Levels"

//--- إعدادات المؤشر / Indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4

//--- خطوط المؤشر / Indicator plots
#property indicator_label1  "إشارة شراء / Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "إشارة بيع / Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "مستوى الربح / Take Profit"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  2

#property indicator_label4  "مستوى الخسارة / Stop Loss"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_DOT
#property indicator_width4  2

//--- معاملات الإدخال / Input parameters
input group "===== إعدادات استراتيجية SBS MODEL / SBS MODEL Strategy Settings ====="
input int      SBS_Period = 14;              // فترة حساب SBS / SBS Calculation Period
input double   BreakoutThreshold = 0.0001;   // حد الكسر / Breakout Threshold
input int      MinCandlesForSignal = 3;      // الحد الأدنى للشموع للإشارة / Minimum Candles for Signal

input group "===== إعدادات الفيبوناتشي / Fibonacci Settings ====="
input bool     ShowFibonacci = true;         // عرض خطوط الفيبوناتشي / Show Fibonacci Lines
input int      FibPeriod = 50;               // فترة حساب الفيبوناتشي / Fibonacci Period
input color    FibColor = clrYellow;         // لون خطوط الفيبوناتشي / Fibonacci Color

input group "===== إعدادات الربح والخسارة / Profit & Loss Settings ====="
input double   TakeProfitMultiplier = 2.0;   // مضاعف الربح / Take Profit Multiplier
input double   StopLossMultiplier = 1.0;     // مضاعف الخسارة / Stop Loss Multiplier
input bool     ShowLevels = true;            // عرض مستويات الربح والخسارة / Show Profit & Loss Levels

input group "===== إعدادات الإشارات / Signal Settings ====="
input bool     EnableAlerts = true;          // تفعيل التنبيهات / Enable Alerts
input bool     SendNotifications = false;    // إرسال الإشعارات / Send Notifications
input bool     PlaySounds = true;            // تشغيل الأصوات / Play Sounds

//--- مصفوفات المؤشر / Indicator buffers
double BuySignalBuffer[];
double SellSignalBuffer[];
double TakeProfitBuffer[];
double StopLossBuffer[];
double UpperBuffer[];      // مخزن مؤقت علوي / Upper buffer
double LowerBuffer[];      // مخزن مؤقت سفلي / Lower buffer

//--- متغيرات عامة / Global variables
double lastHigh, lastLow;
int fibObjectCount = 0;
bool isNewSignal = false;
datetime lastSignalTime = 0;

//+------------------------------------------------------------------+
//| وظيفة التهيئة المخصصة للمؤشر / Custom indicator initialization  |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- ربط المصفوفات بمخازن المؤشر / Set array as series and bind to indicator buffers
    SetIndexBuffer(0, BuySignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, SellSignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, TakeProfitBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, StopLossBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, UpperBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, LowerBuffer, INDICATOR_CALCULATIONS);
    
    //--- تعيين رموز الأسهم للإشارات / Set arrow symbols for signals
    PlotIndexSetInteger(0, PLOT_ARROW, 233);  // سهم شراء / Buy arrow
    PlotIndexSetInteger(1, PLOT_ARROW, 234);  // سهم بيع / Sell arrow
    
    //--- تعيين قيم فارغة / Set empty values
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
    
    //--- تعيين دقة الأرقام / Set digits precision
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    //--- تعيين اسم قصير للمؤشر / Set short name
    IndicatorSetString(INDICATOR_SHORTNAME, "SBS Model v1.0");
    
    Print("تم تهيئة مؤشر SBS MODEL بنجاح / SBS MODEL Indicator initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| وظيفة إلغاء التهيئة / Deinitialization function                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- حذف جميع كائنات الفيبوناتشي / Delete all Fibonacci objects
    DeleteAllFibonacciObjects();
    Print("تم إلغاء تهيئة مؤشر SBS MODEL / SBS MODEL Indicator deinitialized");
}

//+------------------------------------------------------------------+
//| وظيفة حساب المؤشر الرئيسية / Main indicator calculation function |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    //--- التحقق من توفر بيانات كافية / Check if enough data is available
    if(rates_total < SBS_Period + FibPeriod)
        return(0);
    
    //--- تحديد نطاق الحساب / Determine calculation range
    int start = MathMax(prev_calculated - 1, SBS_Period + FibPeriod);
    if(start < 0) start = 0;
    
    //--- تهيئة المصفوفات / Initialize arrays
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(time, true);
    
    //--- حساب المؤشر لكل شمعة / Calculate indicator for each bar
    for(int i = start; i < rates_total - 1; i++)
    {
        //--- إعادة تعيين القيم / Reset values
        BuySignalBuffer[i] = 0.0;
        SellSignalBuffer[i] = 0.0;
        TakeProfitBuffer[i] = 0.0;
        StopLossBuffer[i] = 0.0;
        
        //--- حساب مستويات SBS / Calculate SBS levels
        CalculateSBSLevels(i, high, low, close);
        
        //--- البحث عن إشارات التداول / Look for trading signals
        if(CheckForBuySignal(i, high, low, close, open))
        {
            BuySignalBuffer[i] = low[i] - (high[i] - low[i]) * 0.1;
            
            if(ShowLevels)
            {
                TakeProfitBuffer[i] = close[i] + (close[i] - low[i]) * TakeProfitMultiplier;
                StopLossBuffer[i] = close[i] - (close[i] - low[i]) * StopLossMultiplier;
            }
            
            //--- رسم الفيبوناتشي / Draw Fibonacci
            if(ShowFibonacci)
                DrawFibonacci(i, high, low, true);
                
            //--- التنبيهات / Alerts
            if(EnableAlerts && i == rates_total - 2)
                SendAlert("إشارة شراء SBS MODEL / SBS MODEL Buy Signal", time[i]);
        }
        
        if(CheckForSellSignal(i, high, low, close, open))
        {
            SellSignalBuffer[i] = high[i] + (high[i] - low[i]) * 0.1;
            
            if(ShowLevels)
            {
                TakeProfitBuffer[i] = close[i] - (high[i] - close[i]) * TakeProfitMultiplier;
                StopLossBuffer[i] = close[i] + (high[i] - close[i]) * StopLossMultiplier;
            }
            
            //--- رسم الفيبوناتشي / Draw Fibonacci
            if(ShowFibonacci)
                DrawFibonacci(i, high, low, false);
                
            //--- التنبيهات / Alerts
            if(EnableAlerts && i == rates_total - 2)
                SendAlert("إشارة بيع SBS MODEL / SBS MODEL Sell Signal", time[i]);
        }
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| حساب مستويات SBS / Calculate SBS levels                         |
//+------------------------------------------------------------------+
void CalculateSBSLevels(int pos, const double &high[], const double &low[], const double &close[])
{
    //--- البحث عن أعلى وأقل نقطة في الفترة المحددة / Find highest and lowest points in specified period
    int highIndex = ArrayMaximum(high, pos, SBS_Period);
    int lowIndex = ArrayMinimum(low, pos, SBS_Period);
    
    if(highIndex != -1 && lowIndex != -1)
    {
        UpperBuffer[pos] = high[highIndex];
        LowerBuffer[pos] = low[lowIndex];
    }
    else
    {
        UpperBuffer[pos] = 0.0;
        LowerBuffer[pos] = 0.0;
    }
}

//+------------------------------------------------------------------+
//| فحص إشارة الشراء / Check for buy signal                         |
//+------------------------------------------------------------------+
bool CheckForBuySignal(int pos, const double &high[], const double &low[], const double &close[], const double &open[])
{
    if(pos < SBS_Period + MinCandlesForSignal) return false;
    
    //--- التحقق من كسر المقاومة / Check for resistance breakout
    bool breakoutOccurred = false;
    double resistanceLevel = UpperBuffer[pos + 1];
    
    if(resistanceLevel > 0)
    {
        // التحقق من كسر السعر لمستوى المقاومة / Check if price breaks resistance level
        if(close[pos] > resistanceLevel + BreakoutThreshold && 
           close[pos + 1] <= resistanceLevel)
        {
            breakoutOccurred = true;
        }
    }
    
    //--- التحقق من شروط إضافية / Check additional conditions
    bool volumeConfirmation = true; // يمكن إضافة شروط الحجم هنا / Volume conditions can be added here
    bool candlePattern = close[pos] > open[pos]; // شمعة خضراء / Green candle
    
    return (breakoutOccurred && volumeConfirmation && candlePattern);
}

//+------------------------------------------------------------------+
//| فحص إشارة البيع / Check for sell signal                         |
//+------------------------------------------------------------------+
bool CheckForSellSignal(int pos, const double &high[], const double &low[], const double &close[], const double &open[])
{
    if(pos < SBS_Period + MinCandlesForSignal) return false;
    
    //--- التحقق من كسر الدعم / Check for support breakdown
    bool breakdownOccurred = false;
    double supportLevel = LowerBuffer[pos + 1];
    
    if(supportLevel > 0)
    {
        // التحقق من كسر السعر لمستوى الدعم / Check if price breaks support level
        if(close[pos] < supportLevel - BreakoutThreshold && 
           close[pos + 1] >= supportLevel)
        {
            breakdownOccurred = true;
        }
    }
    
    //--- التحقق من شروط إضافية / Check additional conditions
    bool volumeConfirmation = true; // يمكن إضافة شروط الحجم هنا / Volume conditions can be added here
    bool candlePattern = close[pos] < open[pos]; // شمعة حمراء / Red candle
    
    return (breakdownOccurred && volumeConfirmation && candlePattern);
}

//+------------------------------------------------------------------+
//| رسم خطوط الفيبوناتشي / Draw Fibonacci lines                    |
//+------------------------------------------------------------------+
void DrawFibonacci(int pos, const double &high[], const double &low[], bool isBuySignal)
{
    //--- العثور على النقاط العالية والمنخفضة للفيبوناتشي / Find high and low points for Fibonacci
    int lookback = MathMin(FibPeriod, pos);
    int highIndex = ArrayMaximum(high, pos, lookback);
    int lowIndex = ArrayMinimum(low, pos, lookback);
    
    if(highIndex == -1 || lowIndex == -1) return;
    
    //--- إنشاء اسم فريد للكائن / Create unique object name
    string objName = "SBS_Fib_" + IntegerToString(fibObjectCount++);
    
    //--- تحديد نقاط البداية والنهاية / Determine start and end points
    datetime time1, time2;
    double price1, price2;
    
    if(isBuySignal)
    {
        // من الأدنى إلى الأعلى / From low to high
        time1 = iTime(_Symbol, _Period, lowIndex);
        price1 = low[lowIndex];
        time2 = iTime(_Symbol, _Period, highIndex);
        price2 = high[highIndex];
    }
    else
    {
        // من الأعلى إلى الأدنى / From high to low
        time1 = iTime(_Symbol, _Period, highIndex);
        price1 = high[highIndex];
        time2 = iTime(_Symbol, _Period, lowIndex);
        price2 = low[lowIndex];
    }
    
    //--- إنشاء كائن الفيبوناتشي / Create Fibonacci object
    if(ObjectCreate(0, objName, OBJ_FIBO, 0, time1, price1, time2, price2))
    {
        //--- تعيين خصائص الكائن / Set object properties
        ObjectSetInteger(0, objName, OBJPROP_COLOR, FibColor);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, false);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        
        //--- إضافة المستويات الرئيسية / Add main levels
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 0, 0.0);     // 0%
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 1, 0.236);   // 23.6%
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 2, 0.382);   // 38.2%
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 3, 0.5);     // 50%
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 4, 0.618);   // 61.8%
        ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, 5, 1.0);     // 100%
        
        ObjectSetInteger(0, objName, OBJPROP_LEVELS, 6);
    }
}

//+------------------------------------------------------------------+
//| حذف جميع كائنات الفيبوناتشي / Delete all Fibonacci objects     |
//+------------------------------------------------------------------+
void DeleteAllFibonacciObjects()
{
    int objectsTotal = ObjectsTotal(0, 0, OBJ_FIBO);
    
    for(int i = objectsTotal - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i, 0, OBJ_FIBO);
        if(StringFind(objName, "SBS_Fib_") == 0)
        {
            ObjectDelete(0, objName);
        }
    }
}

//+------------------------------------------------------------------+
//| إرسال التنبيهات / Send alerts                                   |
//+------------------------------------------------------------------+
void SendAlert(string message, datetime signalTime)
{
    //--- تجنب التنبيهات المتكررة / Avoid duplicate alerts
    if(signalTime == lastSignalTime) return;
    lastSignalTime = signalTime;
    
    string fullMessage = "SBS MODEL: " + message + " على " + _Symbol + " في " + TimeToString(signalTime);
    
    //--- تنبيه صوتي / Audio alert
    if(PlaySounds)
        Alert(fullMessage);
    
    //--- إشعار للهاتف المحمول / Mobile notification
    if(SendNotifications)
        SendNotification(fullMessage);
    
    //--- طباعة في السجل / Print to log
    Print(fullMessage);
}

//+------------------------------------------------------------------+
//| وظيفة للحصول على معلومات المؤشر / Function to get indicator info |
//+------------------------------------------------------------------+
string GetIndicatorInfo()
{
    string info = "مؤشر SBS MODEL - معلومات الإعدادات:\n";
    info += "فترة SBS: " + IntegerToString(SBS_Period) + "\n";
    info += "حد الكسر: " + DoubleToString(BreakoutThreshold, 5) + "\n";
    info += "مضاعف الربح: " + DoubleToString(TakeProfitMultiplier, 2) + "\n";
    info += "مضاعف الخسارة: " + DoubleToString(StopLossMultiplier, 2) + "\n";
    info += "عرض الفيبوناتشي: " + (ShowFibonacci ? "نعم" : "لا") + "\n";
    info += "عرض المستويات: " + (ShowLevels ? "نعم" : "لا");
    
    return info;
}

//+------------------------------------------------------------------+