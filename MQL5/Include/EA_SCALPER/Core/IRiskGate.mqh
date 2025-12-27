//+------------------------------------------------------------------+
//|                                                    IRiskGate.mqh |
//|                     EA_SCALPER_XAUUSD - Risk Gate Interface      |
//|                     Base interface for all risk management gates |
//+------------------------------------------------------------------+
#ifndef IRISKGATE_MQH
#define IRISKGATE_MQH

#include "Definitions.mqh"

//+------------------------------------------------------------------+
//| Interface for all risk gates                                      |
//| All risk management components must implement this interface      |
//+------------------------------------------------------------------+
class IRiskGate
{
public:
    //--- Pure virtual methods (must be implemented by derived classes)

    //--- Check if trading is blocked by this gate
    virtual bool IsBlocked(void) = 0;

    //--- Get the reason for blocking (bitmask of ENUM_GATE_REASON)
    virtual ENUM_GATE_REASON GetReason(void) = 0;

    //--- Get human-readable reason text for logging
    virtual string GetReasonText(void) = 0;

    //--- Optional: Update gate state (called on each tick)
    virtual void OnTick(void) { }

    //--- Optional: Reset gate state (called on new day/session)
    virtual void Reset(void) { }

    //--- Optional: Get gate name for logging
    virtual string GetGateName(void) { return "UnnamedGate"; }
};

//+------------------------------------------------------------------+
//| Helper function to convert gate reason bitmask to string          |
//+------------------------------------------------------------------+
string GateReasonToString(ENUM_GATE_REASON reason)
{
    if(reason == GATE_OK) return "OK";

    string result = "";

    if((reason & GATE_TIME) != 0)
        result += (result != "" ? "|" : "") + "TIME";
    if((reason & GATE_DD_TRAILING) != 0)
        result += (result != "" ? "|" : "") + "DD_TRAILING";
    if((reason & GATE_DD_DAILY) != 0)
        result += (result != "" ? "|" : "") + "DD_DAILY";
    if((reason & GATE_SPREAD) != 0)
        result += (result != "" ? "|" : "") + "SPREAD";
    if((reason & GATE_VIRTUAL) != 0)
        result += (result != "" ? "|" : "") + "VIRTUAL";
    if((reason & GATE_GAP_COOLDOWN) != 0)
        result += (result != "" ? "|" : "") + "GAP_COOLDOWN";
    if((reason & GATE_NEWS) != 0)
        result += (result != "" ? "|" : "") + "NEWS";
    if((reason & GATE_SESSION) != 0)
        result += (result != "" ? "|" : "") + "SESSION";

    return (result != "" ? result : "UNKNOWN");
}

//+------------------------------------------------------------------+
//| Helper function to check if specific reason is set in bitmask     |
//+------------------------------------------------------------------+
bool HasGateReason(ENUM_GATE_REASON reasons, ENUM_GATE_REASON check)
{
    return ((reasons & check) != 0);
}

//+------------------------------------------------------------------+
//| Helper function to combine gate reasons                           |
//+------------------------------------------------------------------+
ENUM_GATE_REASON CombineGateReasons(ENUM_GATE_REASON a, ENUM_GATE_REASON b)
{
    return (ENUM_GATE_REASON)(a | b);
}

#endif // IRISKGATE_MQH
//+------------------------------------------------------------------+
