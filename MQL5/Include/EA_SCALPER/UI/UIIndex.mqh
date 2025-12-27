//+------------------------------------------------------------------+
//|                                                      UIIndex.mqh |
//|                     EA_SCALPER_XAUUSD - UI Components Index      |
//|                     Single include for all UI modules            |
//+------------------------------------------------------------------+
//| UI COMPONENT LIBRARY                                             |
//|                                                                  |
//| Available Components:                                            |
//| - CRiskHUD: Visual HUD panel for risk monitoring (Task 4.2)     |
//|                                                                  |
//| Usage:                                                           |
//|   #include <EA_SCALPER/UI/UIIndex.mqh>                          |
//|                                                                  |
//|   CRiskHUD hud;                                                 |
//|   hud.Init(10, 30);                                             |
//|   hud.Update(dd_tracker, time_handler, decision);               |
//+------------------------------------------------------------------+
#ifndef UIINDEX_MQH
#define UIINDEX_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

//--- Core dependencies
#include "../Core/Definitions.mqh"

//--- UI Components
#include "CRiskHUD.mqh"

#endif // UIINDEX_MQH
//+------------------------------------------------------------------+
