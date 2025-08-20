//+------------------------------------------------------------------+
//|                                            Account Protector.mq4 |
//|                             Copyright © 2017-2024, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-expert-advisors/Account-Protector/"
#property version   "1.11"
string    Version = "1.11";
#property strict

#property description "Protects account balance by applying given actions when set conditions trigger."
#property description "Trails stop-losses, applies breakeven, logs its actions, sends notifications.\r\n"
#property description "WARNING: There is no guarantee that the expert advisor will work as intended. Use at your own risk."

#include "Account Protector.mqh";

input string ____Main = "";
input bool EnableEmergencyButton = false; // Enable emergency button
input bool DoNotDisableConditions = false; // DoNotDisableConditions: Don't disable conditions on trigger?
input bool DoNotDisableActions = false; // DoNotDisableActions: Don't disable actions on trigger?
input bool DoNotDisableEquityTS = false; // DoNotDisableEquityTS: Don't disable equity TS on trigger?
input bool DoNotDisableTimer = false; // DoNotDisableTimer: Don't disable timer on trigger?
input int ConditionDelay = 0; // ConditionDelay: How long should condition be active to trigger?
input bool CountFloatingInDailyPL = true; // CountFloatingInDailyPL: Count floating P/L in daily P/L?
input string ____Conditions = "";
input bool DisableFloatLossRisePerc = false; // Disable floating loss rises % condition.
input bool DisableFloatLossFallPerc = true; // Disable floating loss falls % condition.
input bool DisableFloatLossRiseCurr = false; // Disable floating loss rises currency units condition.
input bool DisableFloatLossFallCurr = true; // Disable floating loss falls currency units condition.
input bool DisableFloatLossRisePoints = false; // Disable floating loss rises points condition.
input bool DisableFloatLossFallPoints = true; // Disable floating loss falls points condition.
input bool DisableFloatProfitRisePerc = false; // Disable floating profit rises % condition.
input bool DisableFloatProfitFallPerc = true; // Disable floating profit falls % condition.
input bool DisableFloatProfitRiseCurr = false; // Disable floating profit rises currency units condition.
input bool DisableFloatProfitFallCurr = true; // Disable floating profit falls currency units condition.
input bool DisableFloatProfitRisePoints = false; // Disable floating profit rises points condition.
input bool DisableFloatProfitFallPoints = true; // Disable floating profit falls points condition.
input bool DisableCurrentPriceGE = true; // Disable current price greater or equal condition.
input bool DisableCurrentPriceLE = true; // Disable current price less or equal condition.
input bool DisableEquityMinusSnapshot = true; // Disable (Equity - snapshot) greater or equal condition.
input bool DisableSnapshotMinusEquity = true; // Disable (snapshot - Equity) greater or equal condition.
input bool DisableMarginLevelGE = true; // Disable margin level greater or equal condition.
input bool DisableMarginLevelLE = true; // Disable margin level less or equal condition.
input bool DisableSpreadGE = true; // Disable spread greater or equal condition.
input bool DisableSpreadLE = true; // Disable spread less or equal condition.
input bool DisableDailyProfitLossUnitsGE = true; // Disable daily profit/loss greater or equal units condition.
input bool DisableDailyProfitLossUnitsLE = true; // Disable daily profit/loss level less or equal units condition.
input bool DisableDailyProfitLossPointsGE = true; // Disable daily profit/loss greater or equal points condition.
input bool DisableDailyProfitLossPointsLE = true; // Disable daily profit/loss level less or equal points condition.
input bool DisableDailyProfitLossPercGE = true; // Disable daily profit/loss greater or equal percentage condition.
input bool DisableDailyProfitLossPercLE = true; // Disable daily profit/loss level less or equal percentage condition.
input bool DisableNumberOfPositionsGE = true; // Disable number of positions greater or equal condition.
input bool DisableNumberOfOrdersGE = true; // Disable number of pending orders greater or equal condition.
input bool DisableNumberOfPositionsLE = true; // Disable number of positions less or equal condition.
input bool DisableNumberOfOrdersLE = true; // Disable number of pending orders less or equal condition.
input string ____Trading = "";
input int DelayOrderClose = 0; // DelayOrderClose: Delay in milliseconds.
input bool UseTotalVolume = false; // UseTotalVolume: enable if trading with many small trades and partial position closing.
input ENUM_CLOSE_TRADES CloseFirst = ENUM_CLOSE_TRADES_DEFAULT; // CloseFirst: Close which trades first?
input bool BreakEvenProfitInCurrencyUnits = false; // BreakEvenProfitInCurrencyUnits: currency instead of points.
input bool EquityTrailingStopInPercentage = false; // EquityTrailingStopInPercentage: % instead of $.
input string ____Miscellaneous = "";
input bool AlertOnEquityTS = false; // AlertOnEquityTS: Alert when equity trailing stop triggers?
input double AdditionalFunds = 0; // AdditionalFunds: Added to balance, equity, and free margin.
input string Instruments = ""; // Instruments: Default list of trading instruments for order filtering.
input bool GlobalSnapshots = false; // GlobalSnapshots: AP instances share equity & margin snapshots.
input int Slippage = 2; // Slippage
input string LogFileName = "ap_log.txt"; // Log file name
input string SettingsFileName = ""; // Settings file: Load custom panel settings from \Files\ folder.
input bool Silent = false; // Silent: No log output to the Experts tab.

CAccountProtector ExtDialog;

int DeinitializationReason = -1;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
{
    if (DeinitializationReason == REASON_CHARTCHANGE)
    {
        EventSetTimer(1);
        return INIT_SUCCEEDED;
    }

    MathSrand(GetTickCount() + 2202051901); // Used by CreateInstanceId() in Dialog.mqh (standard library). Keep the second number unique across other panel indicators/EAs.

    if (SettingsFileName != "") // Load a custom settings file if given via input parameters.
    {
        ExtDialog.SetFileName(SettingsFileName);
    }

    if (!ExtDialog.LoadSettingsFromDisk())
    {
        sets.OnOff = false;
        sets.CountCommSwaps = true;
        sets.UseTimer = false;
        sets.Timer = TimeToString(TimeCurrent() - 7200, TIME_MINUTES);
        sets.TimeLeft = "";
        sets.intTimeType = 0;
        sets.dtTimerLastTriggerTime = 0;
        sets.boolTrailingStart = false;
        sets.intTrailingStart = 0;
        sets.boolTrailingStep = false;
        sets.intTrailingStep = 0;
        sets.boolBreakEven = false;
        sets.intBreakEven = 0;
        sets.doubleBreakEven = 0;
        sets.boolBreakEvenExtra = false;
        sets.intBreakEvenExtra = 0;
        sets.boolEquityTrailingStop = false;
        sets.doubleEquityTrailingStop = 0;
        sets.doubleCurrentEquityStopLoss = 0;
        sets.SnapEquity = AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds;
        sets.SnapEquityTime = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        sets.SnapMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds;
        sets.SnapMarginTime = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        if (GlobalSnapshots)
        {
            SaveGlobalEquitySnapshots();
            SaveGlobalMarginSnapshots();
        }
        sets.OrderCommentary = "";
        sets.intOrderCommentaryCondition = 0;
        sets.intOrderDirection = 0;
        sets.MagicNumbers = "";
        sets.boolExcludeMagics = false;
        sets.intInstrumentFilter = 0;
        sets.Instruments = Instruments;
        sets.boolIgnoreLossTrades = false;
        sets.boolIgnoreProfitTrades = false;
        sets.boolLossPerBalance = false;
        sets.boolLossQuanUnits = false;
        sets.boolLossPoints = false;
        sets.boolProfPerBalance = false;
        sets.boolProfQuanUnits = false;
        sets.boolProfPoints = false;
        sets.boolLossPerBalanceReverse = false;
        sets.boolLossQuanUnitsReverse = false;
        sets.boolLossPointsReverse = false;
        sets.boolProfPerBalanceReverse = false;
        sets.boolProfQuanUnitsReverse = false;
        sets.boolProfPointsReverse = false;
        sets.boolEquityLessUnits = false;
        sets.boolEquityGrUnits = false;
        sets.boolEquityLessPerSnap = false;
        sets.boolEquityGrPerSnap = false;
        sets.boolEquityMinusSnapshot = false;
        sets.boolSnapshotMinusEquity = false;
        sets.boolMarginLessUnits = false;
        sets.boolMarginGrUnits = false;
        sets.boolMarginLessPerSnap = false;
        sets.boolMarginGrPerSnap = false;
        sets.boolPriceGE = false;
        sets.boolPriceLE = false;
        sets.boolMarginLevelGE = false;
        sets.boolMarginLevelLE = false;
        sets.boolSpreadGE = false;
        sets.boolSpreadLE = false;
        sets.boolDailyProfitLossUnitsGE = false;
        sets.boolDailyProfitLossUnitsLE = false;
        sets.boolDailyProfitLossPointsGE = false;
        sets.boolDailyProfitLossPointsLE = false;
        sets.boolDailyProfitLossPercGE = false;
        sets.boolDailyProfitLossPercLE = false;
        sets.boolNumberOfPositionsGE = false;
        sets.boolNumberOfOrdersGE = false;
        sets.boolNumberOfPositionsLE = false;
        sets.boolNumberOfOrdersLE = false;
        sets.doubleLossPerBalance = 0;
        sets.doubleLossQuanUnits = 0;
        sets.intLossPoints = 0;
        sets.doubleProfPerBalance = 0;
        sets.doubleProfQuanUnits = 0;
        sets.intProfPoints = 0;
        sets.doubleLossPerBalanceReverse = 0;
        sets.doubleLossQuanUnitsReverse = 0;
        sets.intLossPointsReverse = 0;
        sets.doubleProfPerBalanceReverse = 0;
        sets.doubleProfQuanUnitsReverse = 0;
        sets.intProfPointsReverse = 0;
        sets.doubleEquityLessUnits = 0;
        sets.doubleEquityGrUnits = 0;
        sets.doubleEquityLessPerSnap = 0;
        sets.doubleEquityGrPerSnap = 0;
        sets.doubleEquityMinusSnapshot = 0;
        sets.doubleSnapshotMinusEquity = 0;
        sets.doubleMarginLessUnits = 0;
        sets.doubleMarginGrUnits = 0;
        sets.doubleMarginLessPerSnap = 0;
        sets.doubleMarginGrPerSnap = 0;
        sets.doublePriceGE = 0;
        sets.doublePriceLE = 0;
        sets.doubleMarginLevelGE = 0;
        sets.doubleMarginLevelLE = 0;
        sets.intSpreadGE = 0;
        sets.intSpreadLE = 0;
        sets.doubleDailyProfitLossUnitsGE= 0;
        sets.doubleDailyProfitLossUnitsLE = 0;
        sets.intDailyProfitLossPointsGE= 0;
        sets.intDailyProfitLossPointsLE = 0;
        sets.doubleDailyProfitLossPercGE= 0;
        sets.doubleDailyProfitLossPercLE = 0;
        sets.intNumberOfPositionsGE = 0;
        sets.intNumberOfOrdersGE = 0;
        sets.intNumberOfPositionsLE = 0;
        sets.intNumberOfOrdersLE = 0;
        sets.ClosePos = true;
        sets.doubleClosePercentage = 100;
        sets.CloseWhichPositions = All;
        sets.DeletePend = true;
        sets.DisAuto = true;
        sets.SendMails = false;
        sets.SendNotif = false;
        sets.ClosePlatform = false;
        sets.DisAuto = false;
        sets.EnableAuto = false;
        sets.RecaptureSnapshots = false;
        sets.CloseAllOtherCharts = false;
        sets.SelectedTab = MainTab;

        ExtDialog.SilentLogging = true;
        ExtDialog.Logging("=====EA IS FIRST ATTACHED TO CHART=====");
        ExtDialog.Logging("Account Number = " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ", Client Name = " + AccountInfoString(ACCOUNT_NAME));
        ExtDialog.Logging("Server Name = " + AccountInfoString(ACCOUNT_SERVER) + ", Broker Name = " + AccountInfoString(ACCOUNT_COMPANY));
        ExtDialog.Logging("Account Currency = " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Leverage = " + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)));
        ExtDialog.Logging("Account Balance = " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Credit = " + DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
        ExtDialog.Logging("Account Equity = " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Free Margin = " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
        ExtDialog.Logging("Account Margin Call / Stop-Out Mode = " + EnumToString((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)));
        string units;
        int decimal_places;
        if (AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE) == ACCOUNT_STOPOUT_MODE_PERCENT)
        {
            units = "%";
            decimal_places = 0;
        }
        else
        {
            units = AccountInfoString(ACCOUNT_CURRENCY);
            decimal_places = 2;
        }
        ExtDialog.Logging("Account Margin Call Level = " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL), decimal_places) + units + ", Account Margin Stopout Level = " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO), decimal_places) + units);
        ExtDialog.Logging("Enable Emergency Button = " + IntegerToString(EnableEmergencyButton));
        ExtDialog.Logging("DelayOrderClose = " + IntegerToString(DelayOrderClose));
        ExtDialog.Logging("UseTotalVolume = " + IntegerToString(UseTotalVolume));
        ExtDialog.Logging("AdditionalBalance = " + DoubleToString(AdditionalFunds, 2));
        ExtDialog.SilentLogging = false;

        sets.Triggered = false;
        sets.TriggeredTime = "";
        sets.TimerDayOfWeek = Any;
    }

    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED)))
    {
        string where = "";
        if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) && (!MQLInfoInteger(MQL_TRADE_ALLOWED))) where = "in both EA's and platform's settings"; // Both.
        else if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) where = "in the platform's settings"; // Platform level.
        else if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) where = "in the EA's settings"; // EA level.
        Alert("AutoTrading is disabled " + where + "! EA will be not able to perform trading operations!");
        sets.ClosePos = false;
        sets.DeletePend = false;
        sets.DisAuto = false;
        sets.boolTrailingStart = false;
        sets.boolTrailingStep = false;
        sets.boolBreakEven = false;
        sets.boolBreakEvenExtra = false;
    }

    if (!ExtDialog.Create(0, Symbol() + " Account Protector (ver. " + Version + ")", 0, 20, 20)) return(-1);
    ExtDialog.Run();
    ExtDialog.IniFileLoad();

    // Brings panel on top of other objects without actual maximization of the panel.
    ExtDialog.HideShowMaximize(false);

    ExtDialog.ShowSelectedTab();
    ExtDialog.RefreshPanelControls();
    ExtDialog.RefreshValues();

    EventSetTimer(1);

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    DeinitializationReason = reason; // Remember reason to avoid recreating the panel in the OnInit() if it is not deleted here.
    EventKillTimer();
    if ((reason == REASON_REMOVE) || (reason == REASON_CHARTCLOSE) || (reason == REASON_PROGRAM))
    {
        if (SettingsFileName == "") ExtDialog.DeleteSettingsFile(); // Only delete settings file if no custom file name is given.
        Print("Trying to delete ini file.");
        if (!FileIsExist(ExtDialog.IniFileName() + ".dat")) Print("File doesn't exist.");
        else if (!FileDelete(ExtDialog.IniFileName() + ".dat")) Print("Failed to delete file: " + ExtDialog.IniFileName() + ".dat. Error: " + IntegerToString(GetLastError()));
        else Print("Deleted ini file successfully.");
        ExtDialog.SilentLogging = true;
        ExtDialog.Logging("EA Account Protector is removed.");
        ExtDialog.Logging("Account Balance = " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Credit = " + DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
        ExtDialog.Logging("Account Equity = " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Free Margin = " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
        ExtDialog.SilentLogging = false;
        ExtDialog.Logging_Current_Settings();
    }
    else if (reason != REASON_CHARTCHANGE)
    {
        if (reason == REASON_PARAMETERS) GlobalVariableSet("AP-" + IntegerToString(ChartID()) + "-Parameters", 1);
        ExtDialog.SaveSettingsOnDisk();
        ExtDialog.IniFileSave();
    }
    if (reason != REASON_CHARTCHANGE) ExtDialog.Destroy();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Remember the panel's location to have the same location for minimized and maximized states.
    if ((id == CHARTEVENT_CUSTOM + ON_DRAG_END) && (lparam == -1))
    {
        ExtDialog.remember_top = ExtDialog.Top();
        ExtDialog.remember_left = ExtDialog.Left();
    }

    // Call Panel's event handler only if it is not a CHARTEVENT_CHART_CHANGE - workaround for minimization bug on chart switch.
    if (id != CHARTEVENT_CHART_CHANGE) ExtDialog.OnEvent(id, lparam, dparam, sparam);

    if (ExtDialog.Top() < 0) ExtDialog.Move(ExtDialog.Left(), 0);
}

//+------------------------------------------------------------------+
//| Tick event handler                                               |
//+------------------------------------------------------------------+
void OnTick()
{
    ExtDialog.RefreshValues();
    if (!sets.OnOff) return;
    ExtDialog.Trailing();
    ExtDialog.EquityTrailing();
    ExtDialog.MoveToBreakEven();
    ExtDialog.CheckAllConditions();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    ExtDialog.RefreshValues();
    if (!sets.OnOff) return;
    ExtDialog.Trailing();
    ExtDialog.EquityTrailing();
    ExtDialog.MoveToBreakEven();
    ExtDialog.CheckAllConditions();
    ChartRedraw();
}
//+------------------------------------------------------------------+