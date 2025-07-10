//+------------------------------------------------------------------+
//|                                              SBS_Utils.mqh       |
//|                                 Copyright 2024, hamza82580       |
//|                                             https://github.com/mizo82580/hamza82580 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, hamza82580"
#property link      "https://github.com/mizo82580/hamza82580"
#property version   "1.00"

//+------------------------------------------------------------------+
//| مكتبة الوظائف المساعدة لمؤشر SBS MODEL                           |
//| Utility functions library for SBS MODEL indicator               |
//+------------------------------------------------------------------+

//--- ثوابت عامة / General constants
#define SBS_VERSION "1.0"
#define SBS_DEVELOPER "hamza82580"

//--- ألوان المؤشر / Indicator colors
#define COLOR_BUY_SIGNAL    clrLime
#define COLOR_SELL_SIGNAL   clrRed
#define COLOR_TAKE_PROFIT   clrGreen
#define COLOR_STOP_LOSS     clrRed
#define COLOR_FIBONACCI     clrYellow

//--- رموز الأسهم / Arrow codes
#define ARROW_BUY    233
#define ARROW_SELL   234

//--- مستويات الفيبوناتشي الافتراضية / Default Fibonacci levels
double FibLevels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618};

//+------------------------------------------------------------------+
//| فئة إدارة البيانات التاريخية / Historical data management class  |
//+------------------------------------------------------------------+
class CSBSDataManager
{
private:
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    
public:
    CSBSDataManager(string sym = "", ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
    {
        symbol = (sym == "") ? _Symbol : sym;
        timeframe = (tf == PERIOD_CURRENT) ? _Period : tf;
    }
    
    //--- الحصول على أعلى نقطة في فترة محددة / Get highest point in specified period
    double GetHighest(int startPos, int count)
    {
        double high[];
        ArraySetAsSeries(high, true);
        
        if(CopyHigh(symbol, timeframe, startPos, count, high) <= 0)
            return 0.0;
            
        return ArrayMaximum(high);
    }
    
    //--- الحصول على أقل نقطة في فترة محددة / Get lowest point in specified period
    double GetLowest(int startPos, int count)
    {
        double low[];
        ArraySetAsSeries(low, true);
        
        if(CopyLow(symbol, timeframe, startPos, count, low) <= 0)
            return 0.0;
            
        return ArrayMinimum(low);
    }
    
    //--- فحص صحة البيانات / Validate data
    bool IsDataValid(int requiredBars)
    {
        return (iBars(symbol, timeframe) >= requiredBars);
    }
};

//+------------------------------------------------------------------+
//| فئة حساب المستويات / Levels calculation class                    |
//+------------------------------------------------------------------+
class CSBSLevels
{
private:
    int period;
    double threshold;
    
public:
    CSBSLevels(int per = 14, double thresh = 0.0001)
    {
        period = per;
        threshold = thresh;
    }
    
    //--- حساب مستوى المقاومة / Calculate resistance level
    double CalculateResistance(const double &high[], int pos)
    {
        if(pos < period) return 0.0;
        
        double maxHigh = 0.0;
        for(int i = pos; i < pos + period; i++)
        {
            if(high[i] > maxHigh)
                maxHigh = high[i];
        }
        return maxHigh;
    }
    
    //--- حساب مستوى الدعم / Calculate support level
    double CalculateSupport(const double &low[], int pos)
    {
        if(pos < period) return 0.0;
        
        double minLow = DBL_MAX;
        for(int i = pos; i < pos + period; i++)
        {
            if(low[i] < minLow)
                minLow = low[i];
        }
        return (minLow == DBL_MAX) ? 0.0 : minLow;
    }
    
    //--- فحص كسر المقاومة / Check resistance breakout
    bool IsResistanceBreakout(double currentPrice, double resistanceLevel)
    {
        return (currentPrice > resistanceLevel + threshold);
    }
    
    //--- فحص كسر الدعم / Check support breakdown
    bool IsSupportBreakdown(double currentPrice, double supportLevel)
    {
        return (currentPrice < supportLevel - threshold);
    }
};

//+------------------------------------------------------------------+
//| فئة إدارة الفيبوناتشي / Fibonacci management class               |
//+------------------------------------------------------------------+
class CSBSFibonacci
{
private:
    string prefix;
    color fibColor;
    int objectCount;
    
public:
    CSBSFibonacci(string pref = "SBS_Fib", color col = clrYellow)
    {
        prefix = pref;
        fibColor = col;
        objectCount = 0;
    }
    
    //--- إنشاء كائن فيبوناتشي / Create Fibonacci object
    bool CreateFibObject(datetime time1, double price1, datetime time2, double price2)
    {
        string objName = prefix + "_" + IntegerToString(objectCount++);
        
        if(!ObjectCreate(0, objName, OBJ_FIBO, 0, time1, price1, time2, price2))
            return false;
            
        //--- تعيين الخصائص / Set properties
        ObjectSetInteger(0, objName, OBJPROP_COLOR, fibColor);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, false);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_LEVELS, ArraySize(FibLevels));
        
        //--- إضافة المستويات / Add levels
        for(int i = 0; i < ArraySize(FibLevels); i++)
        {
            ObjectSetDouble(0, objName, OBJPROP_LEVELVALUE, i, FibLevels[i]);
            ObjectSetInteger(0, objName, OBJPROP_LEVELCOLOR, i, fibColor);
        }
        
        return true;
    }
    
    //--- حذف جميع كائنات الفيبوناتشي / Delete all Fibonacci objects
    void DeleteAllFibObjects()
    {
        int total = ObjectsTotal(0, 0, OBJ_FIBO);
        for(int i = total - 1; i >= 0; i--)
        {
            string objName = ObjectName(0, i, 0, OBJ_FIBO);
            if(StringFind(objName, prefix) == 0)
                ObjectDelete(0, objName);
        }
        objectCount = 0;
    }
    
    //--- الحصول على قيمة مستوى فيبوناتشي / Get Fibonacci level value
    double GetFibLevel(double high, double low, double level)
    {
        return low + (high - low) * level;
    }
};

//+------------------------------------------------------------------+
//| فئة إدارة التنبيهات / Alert management class                     |
//+------------------------------------------------------------------+
class CSBSAlerts
{
private:
    bool enableAlerts;
    bool sendNotifications;
    bool playSounds;
    datetime lastAlertTime;
    
public:
    CSBSAlerts(bool alerts = true, bool notifications = false, bool sounds = true)
    {
        enableAlerts = alerts;
        sendNotifications = notifications;
        playSounds = sounds;
        lastAlertTime = 0;
    }
    
    //--- إرسال تنبيه شراء / Send buy alert
    void SendBuyAlert(string symbol, datetime time)
    {
        if(time == lastAlertTime) return;
        
        string message = "إشارة شراء SBS MODEL على " + symbol + " في " + TimeToString(time);
        SendAlert(message, time);
    }
    
    //--- إرسال تنبيه بيع / Send sell alert  
    void SendSellAlert(string symbol, datetime time)
    {
        if(time == lastAlertTime) return;
        
        string message = "إشارة بيع SBS MODEL على " + symbol + " في " + TimeToString(time);
        SendAlert(message, time);
    }
    
private:
    //--- إرسال التنبيه / Send alert
    void SendAlert(string message, datetime time)
    {
        lastAlertTime = time;
        
        if(enableAlerts && playSounds)
            Alert(message);
            
        if(sendNotifications)
            SendNotification(message);
            
        Print(message);
    }
};

//+------------------------------------------------------------------+
//| فئة حساب المخاطر والأرباح / Risk and profit calculation class    |
//+------------------------------------------------------------------+
class CSBSRiskManager
{
private:
    double tpMultiplier;
    double slMultiplier;
    
public:
    CSBSRiskManager(double tp = 2.0, double sl = 1.0)
    {
        tpMultiplier = tp;
        slMultiplier = sl;
    }
    
    //--- حساب مستوى الربح للشراء / Calculate take profit for buy
    double CalculateBuyTP(double entryPrice, double supportLevel)
    {
        double range = entryPrice - supportLevel;
        return entryPrice + (range * tpMultiplier);
    }
    
    //--- حساب مستوى الخسارة للشراء / Calculate stop loss for buy
    double CalculateBuySL(double entryPrice, double supportLevel)
    {
        double range = entryPrice - supportLevel;
        return entryPrice - (range * slMultiplier);
    }
    
    //--- حساب مستوى الربح للبيع / Calculate take profit for sell
    double CalculateSellTP(double entryPrice, double resistanceLevel)
    {
        double range = resistanceLevel - entryPrice;
        return entryPrice - (range * tpMultiplier);
    }
    
    //--- حساب مستوى الخسارة للبيع / Calculate stop loss for sell
    double CalculateSellSL(double entryPrice, double resistanceLevel)
    {
        double range = resistanceLevel - entryPrice;
        return entryPrice + (range * slMultiplier);
    }
    
    //--- حساب نسبة المخاطرة للربح / Calculate risk-reward ratio
    double CalculateRiskReward(double entry, double tp, double sl)
    {
        double profit = MathAbs(tp - entry);
        double loss = MathAbs(entry - sl);
        
        return (loss > 0) ? profit / loss : 0.0;
    }
};

//+------------------------------------------------------------------+
//| وظائف مساعدة عامة / General utility functions                   |
//+------------------------------------------------------------------+

//--- فحص صحة المعاملات / Validate parameters
bool ValidateParameters(int period, double threshold, double tpMult, double slMult)
{
    if(period < 1 || period > 1000)
    {
        Print("خطأ: فترة SBS غير صحيحة / Error: Invalid SBS period");
        return false;
    }
    
    if(threshold < 0 || threshold > 0.01)
    {
        Print("خطأ: حد الكسر غير صحيح / Error: Invalid breakout threshold");
        return false;
    }
    
    if(tpMult < 0.1 || tpMult > 10.0)
    {
        Print("خطأ: مضاعف الربح غير صحيح / Error: Invalid take profit multiplier");
        return false;
    }
    
    if(slMult < 0.1 || slMult > 10.0)
    {
        Print("خطأ: مضاعف الخسارة غير صحيح / Error: Invalid stop loss multiplier");
        return false;
    }
    
    return true;
}

//--- تحويل الإطار الزمني إلى نص / Convert timeframe to string
string TimeframeToString(ENUM_TIMEFRAMES tf)
{
    switch(tf)
    {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
        default:         return "Unknown";
    }
}

//--- تنسيق رسالة التداول / Format trading message
string FormatTradeMessage(string action, string symbol, double price, datetime time)
{
    return StringFormat("%s على %s | السعر: %s | الوقت: %s",
                       action, symbol, DoubleToString(price, _Digits), TimeToString(time));
}

//--- حساب المدى اليومي المتوسط / Calculate average daily range
double CalculateADR(string symbol, int days = 20)
{
    double high[], low[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    
    if(CopyHigh(symbol, PERIOD_D1, 0, days, high) <= 0 ||
       CopyLow(symbol, PERIOD_D1, 0, days, low) <= 0)
        return 0.0;
    
    double totalRange = 0.0;
    for(int i = 0; i < days; i++)
    {
        totalRange += (high[i] - low[i]);
    }
    
    return totalRange / days;
}

//+------------------------------------------------------------------+