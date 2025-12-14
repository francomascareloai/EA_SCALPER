//+------------------------------------------------------------------+
//|                                              ContextIndex.mqh    |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Context Layer Index   |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Context Layer Components                                          |
//|                                                                   |
//| Purpose: Understand market context before trading                 |
//|                                                                   |
//| Components:                                                       |
//| 1. CNewsWindowDetector - Detect news events (API + CSV fallback)  |
//| 2. CHolidayDetector - US/UK holidays, reduced liquidity           |
//+------------------------------------------------------------------+

#include "CNewsWindowDetector.mqh"
#include "CHolidayDetector.mqh"

//+------------------------------------------------------------------+
