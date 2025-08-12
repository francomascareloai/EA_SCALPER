//+------------------------------------------------------------------+
//|                                      a. MARKET UPLOAD CHECKS.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|      1. CHECK TRADING VOLUME                                     |
//+------------------------------------------------------------------+

double Check1_ValidateVolume_Lots(double lots){
   double symbolVol_Min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double symbolVol_Max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double symbolVol_STEP = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
      
   double accepted_Lots;
   double CurrentLots = lots;
   accepted_Lots = MathMax(MathMin(CurrentLots,symbolVol_Max),symbolVol_Min);
   
   int lotDigits = 0;
   if (symbolVol_Min == 1) lotDigits = 0;
   if (symbolVol_Min == 0.1) lotDigits = 1;
   if (symbolVol_Min == 0.01) lotDigits = 2;
   if (symbolVol_Min == 0.001) lotDigits = 3;

   double normalized_lots = NormalizeDouble(accepted_Lots,lotDigits);
   //Print("MIN LOTS = ",symbolVol_Min,", NORMALIZED LOTS = ",normalized_lots);
   
   return (normalized_lots);
}



//+------------------------------------------------------------------+
//|      2. CHECK MONEY/MARGIN TO OPEN POSITION                      |
//+------------------------------------------------------------------+

bool Check2_Margin(ENUM_ORDER_TYPE Order_Type,double lot_Vol){
   double margin;
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   double openPrice = (Order_Type == ORDER_TYPE_BUY) ? Ask : Bid;
   
   bool result = OrderCalcMargin(Order_Type,_Symbol,lot_Vol,openPrice,margin);
   if (result == false){
      Print("ERROR: Something Unexpected Happened While Calculating Margin");
      return (false);
   }
   if (margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Print("WARNING! NOT ENOUGH MARGIN TO OPEN THE POSITION. NEEDED = ",margin);
      return (false);
   }
   return (true);
}



//+------------------------------------------------------------------+
//|      3. CHECK VOLUME LIMIT                                       |
//+------------------------------------------------------------------+

bool Check3_VolumeLimit(double lots_Vol_Limit){
   double volumeLimit = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
   double symb_Vol_Max40 = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double allowed_Vol_Lim = (volumeLimit == 0) ? symb_Vol_Max40 : volumeLimit;
   if (getAllVolume()+lots_Vol_Limit > allowed_Vol_Lim){
      Print("WARNING! VOLUME LIMIT REACHED: LIMIT = ",allowed_Vol_Lim);
      return (false);
   }
   return (true);
}

double getAllVolume(){
   ulong ticket=0;
   double Volume=0;
   
   for (int i=PositionsTotal()-1 ;i>=0 ;i--){
      ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket)){
         if (PositionGetString(POSITION_SYMBOL)==_Symbol){
            Volume += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   
   for (int i=OrdersTotal()-1 ;i>=0 ;i--){
      ticket = OrderGetTicket(i);
      if (OrderSelect(ticket)){
         if (OrderGetString(ORDER_SYMBOL)==_Symbol){
            Volume += OrderGetDouble(ORDER_VOLUME_CURRENT);
         }
      }
   }
   return (Volume);
}



//+------------------------------------------------------------------+
//|      4. CHECK TRADE LEVELS                                       |
//+------------------------------------------------------------------+

bool Check4_TradeLevels(ENUM_POSITION_TYPE pos_Type,double sl=0,double tp=0,ulong tkt=0){
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   int stopLevel = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   int freezeLevel = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   
   double stopLevel_Pts = stopLevel*_Point;
   double freezeLevel_Pts = freezeLevel*_Point;
   
   if (pos_Type == POSITION_TYPE_BUY){
      // STOP LEVELS CHECK
      if (tp > 0 && tp - Bid < stopLevel_Pts){
         Print("WARNING! BUY TP ",tp,", Bid ",Bid," (TP-Bid = ",NormalizeDouble((tp-Bid)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         return (false);
      }
      if (sl > 0 && Bid - sl < stopLevel_Pts){
         Print("WARNING! BUY SL ",sl,", Bid ",Bid," (Bid-SL = ",NormalizeDouble((Bid-sl)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         return (false);
      }
      // FREEZE LEVELS CHECK
      if (tp > 0 && tp - Bid < freezeLevel_Pts){
         Print("WARNING! BUY TP ",tp,", Bid ",Bid," (TP-Bid = ",NormalizeDouble((tp-Bid)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         return (false);
      }
      if (sl > 0 && Bid - sl < freezeLevel_Pts){
         Print("WARNING! BUY SL ",sl,", Bid ",Bid," (Bid-SL = ",NormalizeDouble((Bid-sl)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         return (false);
      }
   }
   if (pos_Type == POSITION_TYPE_SELL){
      // STOP LEVELS CHECK
      if (tp > 0 && Ask - tp < stopLevel_Pts){
         Print("WARNING! SELL TP ",tp,", Ask ",Ask," (Ask-TP = ",NormalizeDouble((Ask-tp)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         return (false);
      }
      if (sl > 0 && sl - Ask < stopLevel_Pts){
         Print("WARNING! SELL SL ",sl,", Ask ",Ask," (SL-Ask = ",NormalizeDouble((sl-Ask)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         return (false);
      }
      
      // FREEZE LEVELS CHECK
      if (tp > 0 && Ask - tp < freezeLevel_Pts){
         Print("WARNING! SELL TP ",tp,", Ask ",Ask," (Ask-TP = ",NormalizeDouble((Ask-tp)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         return (false);
      }
      if (sl > 0 && sl - Ask < freezeLevel_Pts){
         Print("WARNING! SELL SL ",sl,", Ask ",Ask," (SL-Ask = ",NormalizeDouble((sl-Ask)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         return (false);
      }
   }
   
   if (tkt > 0){
      bool result = PositionSelectByTicket(tkt);
      if (result == false){
         Print("ERROR Selecting The Position (CHECK) With Ticket # ",tkt);
         return (false);
      }
      double point = SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double pos_SL = PositionGetDouble(POSITION_SL);
      double pos_TP = PositionGetDouble(POSITION_TP);
      
      bool slChanged = MathAbs(pos_SL - sl) > point;
      bool tpChanged = MathAbs(pos_TP - tp) > point;

      //bool slChanged = pos_SL != sl;
      //bool tpChanged = pos_TP != tp;
      
      if (!slChanged && !tpChanged){
         Print("ERROR. Pos # ",tkt," Already has Levels of SL: ",pos_SL,
               ", TP: ",pos_TP," NEW[SL = ",sl," | TP = ",tp,"]. NO POINT IN MODIFYING!!!");
         return (false);
      }
   }
   
   return (true);
}

//+------------------------------------------------------------------+
//|      5. CHECK & CORRECT TRADE LEVELS                             |
//+------------------------------------------------------------------+

double Check5_TradeLevels_Rectify(ENUM_POSITION_TYPE pos_Type,double sl=0,double tp=0){
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   int stopLevel = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   int freezeLevel = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   
   double stopLevel_Pts = stopLevel*_Point;
   double freezeLevel_Pts = freezeLevel*_Point;
   
   double accepted_price = 0.0;
   
   if (pos_Type == POSITION_TYPE_BUY){
      // STOP LEVELS CHECK
      if (tp > 0 && tp - Bid < stopLevel_Pts){
         accepted_price = Bid+stopLevel_Pts;
         Print("WARNING! BUY TP ",tp,", Bid ",Bid," (TP-Bid = ",NormalizeDouble((tp-Bid)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      if (sl > 0 && Bid - sl < stopLevel_Pts){
         accepted_price = Bid-stopLevel_Pts;
         Print("WARNING! BUY SL ",sl,", Bid ",Bid," (Bid-SL = ",NormalizeDouble((Bid-sl)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      // FREEZE LEVELS CHECK
      if (tp > 0 && tp - Bid < freezeLevel_Pts){
         accepted_price = Bid+freezeLevel_Pts;
         Print("WARNING! BUY TP ",tp,", Bid ",Bid," (TP-Bid = ",NormalizeDouble((tp-Bid)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      if (sl > 0 && Bid - sl < freezeLevel_Pts){
         accepted_price = Bid-freezeLevel_Pts;
         Print("WARNING! BUY SL ",sl,", Bid ",Bid," (Bid-SL = ",NormalizeDouble((Bid-sl)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
   }
   if (pos_Type == POSITION_TYPE_SELL){
      // STOP LEVELS CHECK
      if (tp > 0 && Ask - tp < stopLevel_Pts){
         accepted_price = Ask-stopLevel_Pts;
         Print("WARNING! SELL TP ",tp,", Ask ",Ask," (Ask-TP = ",NormalizeDouble((Ask-tp)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      if (sl > 0 && sl - Ask < stopLevel_Pts){
         accepted_price = Ask+stopLevel_Pts;
         Print("WARNING! SELL SL ",sl,", Ask ",Ask," (SL-Ask = ",NormalizeDouble((sl-Ask)/_Point,_Digits),") WITHIN STOP LEVEL OF ",stopLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      
      // FREEZE LEVELS CHECK
      if (tp > 0 && Ask - tp < freezeLevel_Pts){
         accepted_price = Ask-freezeLevel_Pts;
         Print("WARNING! SELL TP ",tp,", Ask ",Ask," (Ask-TP = ",NormalizeDouble((Ask-tp)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
      if (sl > 0 && sl - Ask < freezeLevel_Pts){
         accepted_price = Ask+freezeLevel_Pts;
         Print("WARNING! SELL SL ",sl,", Ask ",Ask," (SL-Ask = ",NormalizeDouble((sl-Ask)/_Point,_Digits),") WITHIN FREEZE LEVEL OF ",freezeLevel);
         Print("PRICE MODIFIED TO: ",accepted_price);
         return (accepted_price);
      }
   }
   return (accepted_price);
}
