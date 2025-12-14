//+------------------------------------------------------------------+
//|                                               ExpertTrailing.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "ExpertBase.mqh"
//+------------------------------------------------------------------+
//| Class CExpertTrailing.                                           |
//| Purpose: Base class traling stops.                               |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CExpertTrailing : public CExpertBase
  {
public:
                     CExpertTrailing(void);
                    ~CExpertTrailing(void);
   //---
   virtual bool      CheckTrailingStopLong(CPositionInfo *position,double &sl,double &tp)  { return(false); }
   virtual bool      CheckTrailingStopShort(CPositionInfo *position,double &sl,double &tp) { return(false); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertTrailing::CExpertTrailing(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertTrailing::~CExpertTrailing(void)
  {
  }
//+------------------------------------------------------------------+
