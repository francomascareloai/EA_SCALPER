//+------------------------------------------------------------------+
//|                                            KeyLevelsEA__Ulli.mq4 |
//|                                                          SmartUP |
//|                                              https://t.me/SmarUP |
//+------------------------------------------------------------------+
#property copyright "SmartUP"
#property link      "https://t.me/SmarUP"
#property version   "1.00"
#property strict

#define KEYLEVEL_INTEGRATED
#include <SUP\Key_levels_Ulli.mqh>

extern	bool	strict_signals = true;		// provide strict (true) or loose (false) signals?
extern	double 	defaultTP = 100.0;			// default TP


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

//---
    return(INIT_SUCCEEDED);
}

#ifndef KEYLEVEL_INTEGRATED
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}
#endif
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
    static 	datetime old_candle = 0;
    double 	high = 0, open = 0,
           	AskPrice = MarketInfo(_Symbol, MODE_ASK),
           	BidPrice = MarketInfo(_Symbol, MODE_BID);
           
    int 	my_Period = use_timeframe;				// from indicator
    int		ticket = 0;
    
    static 	datetime last_time = 0;
    
    double 	allValues[2][14] = {0.0};			// green lines are in allValues[0], red lines are in allValues[1]
    double	TP = 0.0;
    double 	SL = 0.0;
    string	TPName = ""; 
    string	SLName = "";
    string	LvlName = "";
    
    if (iTime(NULL, my_Period, shift) != last_time) {		// only act on new candle
    
    	last_time = iTime(NULL, my_Period, shift);
    
	    _OnCalculate();			// let the Indicator do it's work
	    
	    FillAllLevels(allValues);
	    
	    bool redCandle 		= iOpen(_Symbol, my_Period, shift + 1) 	> 	iClose(_Symbol, my_Period, shift + 1);
	    
	    bool greenCandle 	= iOpen(_Symbol, my_Period, shift + 1) 	< 	iClose(_Symbol, my_Period, shift + 1);
	    
	    
	    double candleClose 	= (iClose(_Symbol, my_Period, shift + 1));
	    double candleHigh 	= (iHigh(_Symbol, my_Period, shift + 1));
	    double candleLow 	= (iLow(_Symbol, my_Period, shift + 1));
	    double candleOpen 	= (iOpen(_Symbol, my_Period, shift + 1));
	    
	    if (greenCandle) {

	    	for (int i = 0; i <= 13; i++) {
	    		if ( 	( candleClose > allValues[0][i] )
	    			&&	(		(  strict_signals && ( candleOpen < allValues[1][i] || candleLow < allValues[1][i] ))
	    				 	||  ( !strict_signals && ( candleOpen < allValues[0][i] || candleLow < allValues[0][i] ))
	    				)
	    		   )
	    		{
	    			if (strict_signals ) 
	    				Print("Buy signal since candle closed above green Key Level " + LevelName(allValues[0][i]) + " and it's Open or Low was below next lower red Key Level " + LevelName(allValues[1][i]));
	    			else	
	    				Print("Buy signal since candle opened below and closed above green Key Level " + LevelName(allValues[0][i])) ;
	    				
	    			LvlName = LevelName(allValues[0][i]);
	    			
	    			if(LvlName == "SH6") { SLName = "SL6"; SL = ReturnLevel(SLName); TPName = "SL5"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH5") { SLName = "SL5"; SL = ReturnLevel(SLName); TPName = "SL4"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH4") { SLName = "SL4"; SL = ReturnLevel(SLName); TPName = "SL3"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH3") { SLName = "SL3"; SL = ReturnLevel(SLName); TPName = "SL2"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH2") { SLName = "SL2"; SL = ReturnLevel(SLName); TPName = "SL1"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH1") { SLName = "SL1"; SL = ReturnLevel(SLName); TPName = "SL0"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SH0") { SLName = "SL0"; SL = ReturnLevel(SLName); TPName = "BL1"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH0") { SLName = "SL0"; SL = ReturnLevel(SLName); TPName = "BL1"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH1") { SLName = "BL1"; SL = ReturnLevel(SLName); TPName = "BL2"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH2") { SLName = "BL2"; SL = ReturnLevel(SLName); TPName = "BL3"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH3") { SLName = "BL3"; SL = ReturnLevel(SLName); TPName = "BL4"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH4") { SLName = "BL4"; SL = ReturnLevel(SLName); TPName = "BL5"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH5") { SLName = "BL5"; SL = ReturnLevel(SLName); TPName = "BL6"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BH6") { SLName = "BL6"; SL = ReturnLevel(SLName); TPName = "0";   TP = 0;                   }
	    					
	    			if ( TP <= AskPrice )
	    				TP = AskPrice + defaultTP * _Point;
	    				
	    			ticket = OrderSend(_Symbol, OP_BUY, 1.0, AskPrice, 0, SL, TP, ("KeyLevel " + LevelName(allValues[0][i]) + "/TP:" + (string)TP + "/SL:" + (string)SL), 0, 0);
	    			if (ticket == -1)
	    				Print("**** could not open Buy Order @", AskPrice, " (KeyLevel: ", LevelName(allValues[0][i]), ") with SL: ", DoubleToStr(SL, 2), " (", SLName, ") and TP: ", DoubleToStr(TP, 2), " (", TPName, ")");
	    			else	
	    				Print("opened Buy Order #", ticket, " @", AskPrice, " (KeyLevel: ", LevelName(allValues[0][i]), ") with SL: ", DoubleToStr(SL, 2), " (", SLName, ") and TP: ", DoubleToStr(TP, 2), " (", TPName, ")");
	    			break;
	    		}
	    	}
	    }
	    
	    if( redCandle ) {

	    	for (int i = 13; i >= 0; i--) {

	    		if ( 	( candleClose < allValues[1][i] )
	    			&&	(		(  strict_signals && ( candleOpen > allValues[0][i] || candleLow > allValues[0][i] ))
	    				 	||  ( !strict_signals && ( candleOpen > allValues[1][i] || candleLow > allValues[1][i] ))
	    				)
	    		   )
	    		{
	    			if (strict_signals ) 
	    				Print("Sell signal since candle closed below red Key Level " + LevelName(allValues[1][i]) + " and it's Open or Low was above next higher green Key Level " + LevelName(allValues[0][i]));
	    			else	
	    				Print("Sell signal since candle opened above and closed below red Key Level " + LevelName(allValues[1][i])) ;
	    				
	    			LvlName = LevelName(allValues[1][i]);
	    			
	    			if(LvlName == "SL6") { SLName = "SH6"; SL = ReturnLevel(SLName); TPName = "0";   TP = 0;                   }
	    			if(LvlName == "SL5") { SLName = "SH5"; SL = ReturnLevel(SLName); TPName = "SH6"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SL4") { SLName = "SH4"; SL = ReturnLevel(SLName); TPName = "SH5"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SL3") { SLName = "SH3"; SL = ReturnLevel(SLName); TPName = "SH4"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SL2") { SLName = "SH2"; SL = ReturnLevel(SLName); TPName = "SH3"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SL1") { SLName = "SH1"; SL = ReturnLevel(SLName); TPName = "SH2"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "SL0") { SLName = "SH0"; SL = ReturnLevel(SLName); TPName = "SH1"; TP = ReturnLevel(TPName); }
	    			
	    			if(LvlName == "BL0") { SLName = "BH0"; SL = ReturnLevel(SLName); TPName = "SH1"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL1") { SLName = "BH1"; SL = ReturnLevel(SLName); TPName = "BH0"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL2") { SLName = "BH2"; SL = ReturnLevel(SLName); TPName = "BH1"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL3") { SLName = "BH3"; SL = ReturnLevel(SLName); TPName = "BH2"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL4") { SLName = "BH4"; SL = ReturnLevel(SLName); TPName = "BH3"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL5") { SLName = "BH5"; SL = ReturnLevel(SLName); TPName = "BH4"; TP = ReturnLevel(TPName); }
	    			if(LvlName == "BL6") { SLName = "BH6"; SL = ReturnLevel(SLName); TPName = "BH5"; TP = ReturnLevel(TPName); }
	    			
	    			if ( TP >= BidPrice )
	    				TP = BidPrice - defaultTP * _Point;
	    				
	    			ticket = OrderSend(_Symbol, OP_SELL, 1.0, BidPrice, 0, SL, TP, ("KeyLevel " + LevelName(allValues[1][i])), 0, 0);
	    			if (ticket == -1)
	    				Print("**** could not open Sell Order @", BidPrice, " (KeyLevel: ", LevelName(allValues[1][i]), ") with SL: ", DoubleToStr(SL, 2), " (", SLName, ") and TP: ", DoubleToStr(TP, 2), " (", TPName, ")");
	    			else
	    				Print("opened Sell Order #", ticket, " @", BidPrice, " (KeyLevel: ", LevelName(allValues[1][i]), ") with SL: ", DoubleToStr(SL, 2), " (", SLName, ") and TP: ", DoubleToStr(TP, 2), " (", TPName, ")");	
	    				
	    			break;
	    		}
	    	}
	        
	    }

    }

}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
	_OnChartEvent(id, lparam, dparam, sparam);
}
//+------------------------------------------------------------------+