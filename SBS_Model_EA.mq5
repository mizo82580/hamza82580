//+------------------------------------------------------------------+
//|                                          SBS_Model_EA.mq5        |
//|                                 Copyright 2024, hamza82580       |
//|                                             https://github.com/mizo82580/hamza82580 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, hamza82580"
#property link      "https://github.com/mizo82580/hamza82580"
#property version   "1.00"
#property description "خبير استراتيجية SBS MODEL للتداول التلقائي"
#property description "SBS MODEL Strategy Expert Advisor for Automated Trading"

//--- تضمين المكتبات المطلوبة / Include required libraries
#include <Trade\Trade.mqh>
#include "SBS_Utils.mqh"

//--- معاملات الإدخال / Input parameters
input group "===== إعدادات استراتيجية SBS MODEL / SBS MODEL Strategy Settings ====="
input int      SBS_Period = 14;              // فترة حساب SBS / SBS Calculation Period
input double   BreakoutThreshold = 0.0001;   // حد الكسر / Breakout Threshold
input int      MinCandlesForSignal = 3;      // الحد الأدنى للشموع للإشارة / Minimum Candles for Signal

input group "===== إعدادات إدارة المخاطر / Risk Management Settings ====="
input double   LotSize = 0.1;                // حجم اللوت / Lot Size
input double   TakeProfitMultiplier = 2.0;   // مضاعف الربح / Take Profit Multiplier
input double   StopLossMultiplier = 1.0;     // مضاعف الخسارة / Stop Loss Multiplier
input double   MaxRiskPercent = 2.0;         // الحد الأقصى للمخاطرة % / Max Risk Percent

input group "===== إعدادات التداول / Trading Settings ====="
input bool     AllowBuy = true;              // السماح بالشراء / Allow Buy Orders
input bool     AllowSell = true;             // السماح بالبيع / Allow Sell Orders
input int      MaxOrders = 1;                // الحد الأقصى للأوامر / Maximum Orders
input int      MagicNumber = 123456;         // الرقم السحري / Magic Number

input group "===== إعدادات الوقت / Time Settings ====="
input bool     UseTimeFilter = false;        // استخدام فلتر الوقت / Use Time Filter
input int      StartHour = 8;                // ساعة البداية / Start Hour
input int      EndHour = 18;                 // ساعة النهاية / End Hour

input group "===== إعدادات التنبيهات / Alert Settings ====="
input bool     EnableAlerts = true;          // تفعيل التنبيهات / Enable Alerts
input bool     SendNotifications = false;    // إرسال الإشعارات / Send Notifications

//--- متغيرات عامة / Global variables
CTrade trade;
CSBSLevels *sbsLevels;
CSBSRiskManager *riskManager;
CSBSAlerts *alertManager;

double lastResistance = 0.0;
double lastSupport = 0.0;
datetime lastSignalTime = 0;
int ordersCount = 0;

//+------------------------------------------------------------------+
//| وظيفة التهيئة / Expert initialization function                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- فحص صحة المعاملات / Validate parameters
    if(!ValidateParameters(SBS_Period, BreakoutThreshold, TakeProfitMultiplier, StopLossMultiplier))
        return INIT_PARAMETERS_INCORRECT;
    
    //--- تهيئة الكائنات / Initialize objects
    sbsLevels = new CSBSLevels(SBS_Period, BreakoutThreshold);
    riskManager = new CSBSRiskManager(TakeProfitMultiplier, StopLossMultiplier);
    alertManager = new CSBSAlerts(EnableAlerts, SendNotifications, true);
    
    //--- إعداد التداول / Setup trading
    trade.SetExpertMagicNumber(MagicNumber);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(_Symbol);
    
    //--- طباعة معلومات التهيئة / Print initialization info
    Print("تم تهيئة خبير SBS MODEL بنجاح");
    Print("الزوج: ", _Symbol);
    Print("الإطار الزمني: ", TimeframeToString(_Period));
    Print("حجم اللوت: ", LotSize);
    Print("الحد الأقصى للمخاطرة: ", MaxRiskPercent, "%");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| وظيفة إلغاء التهيئة / Expert deinitialization function          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- حذف الكائنات / Delete objects
    if(sbsLevels != NULL)
    {
        delete sbsLevels;
        sbsLevels = NULL;
    }
    
    if(riskManager != NULL)
    {
        delete riskManager;
        riskManager = NULL;
    }
    
    if(alertManager != NULL)
    {
        delete alertManager;
        alertManager = NULL;
    }
    
    Print("تم إنهاء خبير SBS MODEL");
}

//+------------------------------------------------------------------+
//| وظيفة القراد / Expert tick function                              |
//+------------------------------------------------------------------+
void OnTick()
{
    //--- فحص الشروط الأساسية / Check basic conditions
    if(!IsNewBar()) return;
    if(UseTimeFilter && !IsTimeToTrade()) return;
    
    //--- تحديث عدد الأوامر / Update orders count
    ordersCount = GetOpenOrdersCount();
    if(ordersCount >= MaxOrders) return;
    
    //--- الحصول على البيانات / Get data
    double high[], low[], close[], open[];
    if(!GetMarketData(high, low, close, open)) return;
    
    //--- حساب مستويات SBS / Calculate SBS levels
    CalculateLevels(high, low, close);
    
    //--- البحث عن إشارات التداول / Look for trading signals
    CheckForSignals(high, low, close, open);
}

//+------------------------------------------------------------------+
//| فحص وجود شمعة جديدة / Check for new bar                         |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(_Symbol, _Period, 0);
    
    if(currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| فحص وقت التداول / Check trading time                            |
//+------------------------------------------------------------------+
bool IsTimeToTrade()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    return (dt.hour >= StartHour && dt.hour < EndHour);
}

//+------------------------------------------------------------------+
//| الحصول على بيانات السوق / Get market data                       |
//+------------------------------------------------------------------+
bool GetMarketData(double &high[], double &low[], double &close[], double &open[])
{
    int barsNeeded = SBS_Period + MinCandlesForSignal + 5;
    
    if(CopyHigh(_Symbol, _Period, 0, barsNeeded, high) <= 0 ||
       CopyLow(_Symbol, _Period, 0, barsNeeded, low) <= 0 ||
       CopyClose(_Symbol, _Period, 0, barsNeeded, close) <= 0 ||
       CopyOpen(_Symbol, _Period, 0, barsNeeded, open) <= 0)
    {
        Print("خطأ في الحصول على بيانات السوق");
        return false;
    }
    
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(open, true);
    
    return true;
}

//+------------------------------------------------------------------+
//| حساب مستويات SBS / Calculate SBS levels                         |
//+------------------------------------------------------------------+
void CalculateLevels(const double &high[], const double &low[], const double &close[])
{
    lastResistance = sbsLevels.CalculateResistance(high, 1);
    lastSupport = sbsLevels.CalculateSupport(low, 1);
}

//+------------------------------------------------------------------+
//| البحث عن إشارات التداول / Check for trading signals            |
//+------------------------------------------------------------------+
void CheckForSignals(const double &high[], const double &low[], const double &close[], const double &open[])
{
    datetime currentTime = iTime(_Symbol, _Period, 0);
    
    //--- تجنب الإشارات المتكررة / Avoid duplicate signals
    if(currentTime == lastSignalTime) return;
    
    //--- فحص إشارة الشراء / Check buy signal
    if(AllowBuy && CheckBuyConditions(high, low, close, open))
    {
        ExecuteBuyOrder(close[0]);
        lastSignalTime = currentTime;
        alertManager.SendBuyAlert(_Symbol, currentTime);
    }
    
    //--- فحص إشارة البيع / Check sell signal
    if(AllowSell && CheckSellConditions(high, low, close, open))
    {
        ExecuteSellOrder(close[0]);
        lastSignalTime = currentTime;
        alertManager.SendSellAlert(_Symbol, currentTime);
    }
}

//+------------------------------------------------------------------+
//| فحص شروط الشراء / Check buy conditions                          |
//+------------------------------------------------------------------+
bool CheckBuyConditions(const double &high[], const double &low[], const double &close[], const double &open[])
{
    if(lastResistance <= 0) return false;
    
    //--- فحص كسر المقاومة / Check resistance breakout
    bool breakout = sbsLevels.IsResistanceBreakout(close[0], lastResistance);
    if(!breakout) return false;
    
    //--- فحص تأكيد الكسر / Check breakout confirmation
    bool confirmation = (close[0] > open[0]); // شمعة خضراء / Green candle
    
    //--- فحص شروط إضافية / Check additional conditions
    bool volumeOk = true; // يمكن إضافة فحص الحجم / Volume check can be added
    bool trendOk = IsUpTrend(close); // فحص الاتجاه / Trend check
    
    return (confirmation && volumeOk && trendOk);
}

//+------------------------------------------------------------------+
//| فحص شروط البيع / Check sell conditions                          |
//+------------------------------------------------------------------+
bool CheckSellConditions(const double &high[], const double &low[], const double &close[], const double &open[])
{
    if(lastSupport <= 0) return false;
    
    //--- فحص كسر الدعم / Check support breakdown
    bool breakdown = sbsLevels.IsSupportBreakdown(close[0], lastSupport);
    if(!breakdown) return false;
    
    //--- فحص تأكيد الكسر / Check breakdown confirmation
    bool confirmation = (close[0] < open[0]); // شمعة حمراء / Red candle
    
    //--- فحص شروط إضافية / Check additional conditions
    bool volumeOk = true; // يمكن إضافة فحص الحجم / Volume check can be added
    bool trendOk = IsDownTrend(close); // فحص الاتجاه / Trend check
    
    return (confirmation && volumeOk && trendOk);
}

//+------------------------------------------------------------------+
//| فحص الاتجاه الصاعد / Check uptrend                              |
//+------------------------------------------------------------------+
bool IsUpTrend(const double &close[])
{
    // فحص بسيط للاتجاه / Simple trend check
    return (close[0] > close[5] && close[1] > close[6]);
}

//+------------------------------------------------------------------+
//| فحص الاتجاه الهابط / Check downtrend                            |
//+------------------------------------------------------------------+
bool IsDownTrend(const double &close[])
{
    // فحص بسيط للاتجاه / Simple trend check
    return (close[0] < close[5] && close[1] < close[6]);
}

//+------------------------------------------------------------------+
//| تنفيذ أمر شراء / Execute buy order                              |
//+------------------------------------------------------------------+
void ExecuteBuyOrder(double currentPrice)
{
    //--- حساب مستويات الربح والخسارة / Calculate TP and SL levels
    double tp = riskManager.CalculateBuyTP(currentPrice, lastSupport);
    double sl = riskManager.CalculateBuySL(currentPrice, lastSupport);
    
    //--- حساب حجم اللوت بناءً على المخاطرة / Calculate lot size based on risk
    double lotSize = CalculateLotSize(currentPrice, sl);
    
    //--- تنفيذ الأمر / Execute order
    if(trade.Buy(lotSize, _Symbol, 0, sl, tp, "SBS Model Buy"))
    {
        Print("تم تنفيذ أمر شراء: ", lotSize, " لوت على ", _Symbol);
        Print("السعر: ", currentPrice, " | الربح: ", tp, " | الخسارة: ", sl);
    }
    else
    {
        Print("فشل في تنفيذ أمر الشراء: ", trade.ResultRetcodeDescription());
    }
}

//+------------------------------------------------------------------+
//| تنفيذ أمر بيع / Execute sell order                              |
//+------------------------------------------------------------------+
void ExecuteSellOrder(double currentPrice)
{
    //--- حساب مستويات الربح والخسارة / Calculate TP and SL levels
    double tp = riskManager.CalculateSellTP(currentPrice, lastResistance);
    double sl = riskManager.CalculateSellSL(currentPrice, lastResistance);
    
    //--- حساب حجم اللوت بناءً على المخاطرة / Calculate lot size based on risk
    double lotSize = CalculateLotSize(currentPrice, sl);
    
    //--- تنفيذ الأمر / Execute order
    if(trade.Sell(lotSize, _Symbol, 0, sl, tp, "SBS Model Sell"))
    {
        Print("تم تنفيذ أمر بيع: ", lotSize, " لوت على ", _Symbol);
        Print("السعر: ", currentPrice, " | الربح: ", tp, " | الخسارة: ", sl);
    }
    else
    {
        Print("فشل في تنفيذ أمر البيع: ", trade.ResultRetcodeDescription());
    }
}

//+------------------------------------------------------------------+
//| حساب حجم اللوت بناءً على المخاطرة / Calculate lot size based on risk |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double stopLoss)
{
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * MaxRiskPercent / 100.0;
    
    double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double stopLossPips = MathAbs(entryPrice - stopLoss) / _Point;
    
    double calculatedLotSize = riskAmount / (stopLossPips * pipValue);
    
    //--- تطبيق حدود حجم اللوت / Apply lot size limits
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    calculatedLotSize = MathMax(calculatedLotSize, minLot);
    calculatedLotSize = MathMin(calculatedLotSize, maxLot);
    calculatedLotSize = MathMin(calculatedLotSize, LotSize);
    
    //--- تقريب إلى أقرب خطوة / Round to nearest step
    calculatedLotSize = MathFloor(calculatedLotSize / lotStep) * lotStep;
    
    return calculatedLotSize;
}

//+------------------------------------------------------------------+
//| الحصول على عدد الأوامر المفتوحة / Get open orders count         |
//+------------------------------------------------------------------+
int GetOpenOrdersCount()
{
    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
               PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
                count++;
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| وظيفة التداول / Trade function                                  |
//+------------------------------------------------------------------+
void OnTrade()
{
    //--- يمكن إضافة منطق إضافي هنا عند تنفيذ الصفقات
    //--- Additional logic can be added here when trades are executed
}

//+------------------------------------------------------------------+