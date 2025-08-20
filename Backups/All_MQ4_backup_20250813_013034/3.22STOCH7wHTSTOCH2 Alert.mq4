//+------------------------------------------------------------------+
//|                                    3.22STOCH7wHTSTOCH2_Alert.mq4 |
//|                                     Copyright 2014, milanese     |
//|                                 http://www.stevehopwoodforex.com |
//+------------------------------------------------------------------+

//3.21 07/04/2014 new auto dedection of sunday candles and using it for all Stoch and TMA calculations...
//3.16 05/04/2014 new with swap filter and only 7.2.2 exit alert
// 
// Elixe : Added colored lines with styles for sto levels Thank you!!!

// properties which tell the indicator how it should look

#property	indicator_separate_window
#property	indicator_maximum			100
#property	indicator_minimum			0
#property	indicator_buffers			3
#property	indicator_color1			DodgerBlue
#property	indicator_width1			1
#property	indicator_width2			3
#property	indicator_color2			Gold
#property	indicator_width3			5
#property	indicator_color3			Red


// user-defined parameters
extern bool     UseSwapFilter=false;
extern bool     ShowOnlyBuyEntryAlerts=false;
extern bool     ShowOnlySellEntryAlerts=false;
double actual_long_swap=0;
double actual_short_swap=0;
extern bool    ShowCounterTrend=false;//gives too CT alerts
extern bool    ShowDaily2_1=true;//setting this to true the indicator shows to the D1 2.1.1 Stoch
//extern bool   UseD1StochforAlert=false;// setting this to true the indicator uses D1 2.1.1 Stoch in combination with 7.2.2 you must set UseW1StochforAlert to false
//extern bool   UseW1StochforAlert=true;// setting this to true the indicator uses W1 2.1.1 Stoch in combination with 7.2.2 you must set UseD1StochforAlert to false
extern bool   UseOnly7_2forEntryAlert=false;// this setting will only use the Stoch 7.2.2 for the enrty alerts the HigherTF Stoch 2.1.1 is not used independend from the above setting
extern bool      PopupAlert=true; // ALERTS WHEN WHENEVER PRICE GOES BELOW 90&70 AND ABOVE 10&30 AND HT STOCH CONFIRMS 
extern bool      EmailAlert= false;
extern bool      PushAlert=false;
extern bool    GiveStoch2_1_ExitAlerts=false;//set this to false if you have set ShowCounterTrend to true, because it will give you an immediatly exit alert in that case
extern bool    GiveStoch7ExitAlerts=false;//gives Stoch 7.2.2 exits alerts for BUY if we have Stoch 7.2.2 >=90 and for SELL if we have  Stoch 7.2.2<=10
extern bool    GiveTMASlopeExitAlert=false;
int     HigherTF_Used           = 1440;
int     HigherTF2_Used          =10080;
extern string  Set_Stoch_Alert_Levels="Default = 20, 40, 60, 80";
extern int     LevelOne=10;                                    // default = 20
extern int     LevelTwo                = 30; //CHANGE TO 10 IF YOU ONLY WANT 1 ALERT // default = 40
extern int     LevelThree              = 70; //CHANGE TO 90 IF YOU ONLY WANT 1 ALERT // default = 60
extern int     LevelFour=90;                                    // default = 80

extern string  Stoch_Settings="Default = 7, 2, 2, 2, 1";

extern int   KPeriod                     = 7;
extern int   DPeriod                     = 2;
extern int   Slowing=2;
extern int   Method=MODE_SMMA;
extern int   Price=1;                                     // 0=Low/High, 1=Close/Close
extern int K_period_HT = 2;
extern int D_period_HT = 1;
extern int S_period_HT = 1;
extern int STOCH_MAIN_Line_Style_HT=2;
extern int STOCH_SIGNAL_Line_Style_HT=2;
extern int STOCH_MAIN_Price_HT=1;
extern int STOCH_SIGNAL_Price_HT=1;
extern int STOCH_MAIN_Ma_HT=0;
extern int STOCH_SIGNAL_Ma_HT=0;
extern string  Level_Styles            = "0 Solid, 1 Dash, 2 Dot, 3 Dashdot, 4 Dashdotdot";
extern int     LevelOneStyle           = 0;
extern color   LevelOneColor           = Blue;
extern int     LevelTwoStyle           = 2;
extern color   LevelTwoColor           = Blue;
extern int     LevelThreeStyle         = 2; 
extern color   LevelThreeColor         = Gold;
extern int     LevelFourStyle          = 0;
extern color   LevelFourColor          = Gold;
extern string   slp="--TMA-SlopeSettings--";
extern int      TMASlopeTF=240;//H4 TF for the TMA-Slope
extern double   TMASlopeCloseBuyAlertLevel=-0.3;
extern double   TMASlopeCloseSellAlertLevel=0.3;

double          TMASlopeVal[8];
bool     BrokerHasSundayCandle=false;
int count_var=0;
// indicator buffers
double dStochMain[];
double HTStochMain[];
double HT2StochMain[];

int indiWindow=0;
// function which is called when indicator is loaded
int OnInit(void)
  {
   count_var=0;
   if (ShowOnlyBuyEntryAlerts==true && ShowOnlySellEntryAlerts==true)
   {
   ShowOnlyBuyEntryAlerts=false;
  ShowOnlySellEntryAlerts=false;
  Alert("ShowOnlyBuyEntryAlerts && ShowOnlySellEntryAlerts set to false");
  Alert("As you can only one set to true!!");
   }
   /*if (UseD1StochforAlert==true && UseW1StochforAlert==true)
   {
   UseW1StochforAlert=true;
   UseD1StochforAlert=false;
   
  Alert("I am using W1StochforAlert ! ");
  Alert("As you can only one set to true!!");
   }*/
// set the display value for upper left corner of indicator window
   IndicatorShortName("10.7 STOCH7wHTSTOCH_Alert ("+KPeriod+") ("+DPeriod+") ("+Slowing+") D1W1  ("+K_period_HT+")("+D_period_HT+")("+S_period_HT+")");

   indiWindow=WindowFind("10.7 STOCH7wHTSTOCH_Alert ("+KPeriod+") ("+DPeriod+") ("+Slowing+") D1W1  ("+K_period_HT+")("+D_period_HT+")("+S_period_HT+")");
// tell the indicator which arrays to use as buffers
   SetIndexBuffer(0,dStochMain);
   if(ShowDaily2_1==true)SetIndexBuffer(1,HTStochMain);
   SetIndexBuffer(2,HT2StochMain);

// label the indicies (shows on mouseover of lines and in Data Window)
SetIndexLabel(0,"Stoch Main");
SetIndexLabel(1,"HTStochMain");
SetIndexLabel(2,"HT2StochMain");
// Draw lines for sto levels
   ObjectCreate("stolvl1",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelOne,0));
   ObjectSet("stolvl1",OBJPROP_COLOR,LevelOneColor);
   ObjectSet("stolvl1",OBJPROP_STYLE,LevelOneStyle);
   ObjectSet("stolvl1",OBJPROP_WIDTH,1);

   ObjectCreate("stolvl2",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelTwo,0));
   ObjectSet("stolvl2",OBJPROP_COLOR,LevelTwoColor);
   ObjectSet("stolvl2",OBJPROP_STYLE,LevelTwoStyle);
   ObjectSet("stolvl2",OBJPROP_WIDTH,1);

   ObjectCreate("stolvl3",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelThree,0));
   ObjectSet("stolvl3",OBJPROP_COLOR,LevelThreeColor);
   ObjectSet("stolvl3",OBJPROP_STYLE,LevelThreeStyle);
   ObjectSet("stolvl3",OBJPROP_WIDTH,1);

   ObjectCreate("stolvl4",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelFour,0));
   ObjectSet("stolvl4",OBJPROP_COLOR,LevelFourColor);
   ObjectSet("stolvl4",OBJPROP_STYLE,LevelFourStyle);
   ObjectSet("stolvl4",OBJPROP_WIDTH,1);
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   count_var=0;
// remove lines on deinit
   ObjectDelete("stolvl1");
   ObjectDelete("stolvl2");
   ObjectDelete("stolvl3");
   ObjectDelete("stolvl4");
  }
// function which is called with every tick
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

   if(rates_total<=KPeriod+DPeriod+Slowing)
      return(0);
       BrokerHasSundayCandle=false;
       int BrokerHour=TimeHour(TimeCurrent());
   for(int CC=0; CC<8; CC++)
     {
      if(TimeDayOfWeek(iTime(NULL,PERIOD_D1,CC))==0)
        {
         BrokerHasSundayCandle=true;
         break;
        }
     }
      int m_bar=0;//Need to deal with a Sunday candle
     int n_bar=0;//Need to deal with a Sunday candle
     int tma_bar=0;
   int d= TimeDayOfWeek(TimeCurrent());
 
   actual_long_swap=MarketInfo(Symbol(),MODE_SWAPLONG);
   actual_short_swap=MarketInfo(Symbol(),MODE_SWAPSHORT);
   
      double   HigherTF1STOCH=iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,m_bar);
      double   HigherTF2STOCH=iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,n_bar);
       if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440)
      {
     HigherTF1STOCH=((iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1))+BrokerHour*(iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1)))/(1+BrokerHour);;
      }
        if(d == 1 && BrokerHasSundayCandle && HigherTF2_Used==1440)
      {
      HigherTF2STOCH=((iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1))+BrokerHour*(iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1)))/(1+BrokerHour);;
      }
      /*if(UseD1StochforAlert==true) double HigherTFSTOCH=HigherTF1STOCH;
      else if(UseW1StochforAlert==true) HigherTFSTOCH=HigherTF2STOCH;
      else HigherTFSTOCH=HigherTF2STOCH;*/

     
     
  
// keep track of the bar on which an alert was last fired
// since this variable is static, it will "remember" its value between calls
   static datetime tLastAlert=0;
   static datetime tLastAlert_exit=0;
   static datetime tLastAlert_fastexit= 0;
   static datetime tLastAlert_cssexit = 0;

// determine how far back to iterate
// always recalc last completed bar incase the client was too busy to handle
// the last tick of the last bar (very, very rare).
/*int	iBarsToCalc = Bars - IndicatorCounted();
	if (iBarsToCalc < Bars) iBarsToCalc++;
	
	// iterate over bars to be calculated, starting with oldest
	int i;
	for (i=iBarsToCalc-i;i>=0;i--) {
	
		// calculate the stoch values for the bar
		dStochMain[i]   	= iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,i);
		
	}*/
   int i=0;
   datetime TimeArray2[];
   datetime TimeArray3[];
   datetime TimeArray4[];
   int    limit,y2=0,y3=0,y4=0,counted_bars=IndicatorCounted();

// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray2,MODE_TIME,Symbol(),Period());
   ArrayCopySeries(TimeArray3,MODE_TIME,Symbol(),HigherTF_Used);
   ArrayCopySeries(TimeArray4,MODE_TIME,Symbol(),HigherTF2_Used);

   limit=Bars-counted_bars+Period()/Period();
   limit=Bars-counted_bars+HigherTF_Used/Period();
   limit=Bars-counted_bars+HigherTF2_Used/Period();

   for(i=0,y2=0,y3=0,y4=0;i<limit;i++)

     {
      if(Time[i]<TimeArray2[y2]) y2++;
      if(Time[i]<TimeArray3[y3]) y3++;
      if(Time[i]<TimeArray4[y4]) y4++;
       if(d == 1 && BrokerHasSundayCandle && Period()==1440 && i==0)
      {
      dStochMain[0]=((iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,1))+BrokerHour*(iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,0)))/(1+BrokerHour);
      }
       if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440 && i==0)
      {
      HTStochMain[0]=((iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1))+BrokerHour*(iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1)))/(1+BrokerHour);;
      }
        if(d == 1 && BrokerHasSundayCandle && HigherTF2_Used==1440 && i==0)
      {
      HT2StochMain[0]=((iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1))+BrokerHour*(iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,1)))/(1+BrokerHour);;
      }
      if(d == 1 && BrokerHasSundayCandle && Period()==1440 && i!=0)
      {
      dStochMain[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,y2);
     
     
      }
      else  dStochMain[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,y2);
      if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440 && i!=0)
      {
      HTStochMain[i]=iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,y3);
     
     
      }
       else HTStochMain[i]=iStochastic(NULL,HigherTF_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,y3);
      
      HT2StochMain[i]=iStochastic(NULL,HigherTF2_Used,K_period_HT,D_period_HT,S_period_HT,STOCH_MAIN_Ma_HT,STOCH_MAIN_Price_HT,MODE_MAIN,y4);
     
     
      
      

     }
   

    if(d == 1 && BrokerHasSundayCandle && TMASlopeTF==1440)  tma_bar=tma_bar+1;
     
      
   TMASlopeVal[0]= GetSlope(Symbol(),TMASlopeTF,tma_bar);
   TMASlopeVal[1]= GetSlope(Symbol(),TMASlopeTF,tma_bar+1);



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(tLastAlert<Time[0])
     {
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false) && ((UseSwapFilter==true && actual_short_swap>=0) || UseSwapFilter==false))
        {

         // if stoch dipped down under LevelFour...(90 NOW WAS 80)
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour &&( HigherTF1STOCH>=99 || HigherTF2STOCH>=99))
           {

            fireAlerts(" 10.7 (CT) TRADE SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch dipped down under LevelThree...(70 NOW WAS 60)
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree && (HigherTF1STOCH>=99 || HigherTF2STOCH>=99))
           {
            fireAlerts(" LAST CALL(CT)TRADE SELL "+Symbol()+" Stoch dipped below "+LevelThree+" (CHECK )");
            tLastAlert=Time[0];
           }
        }
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false) && ((UseSwapFilter==true && actual_long_swap>=0) || UseSwapFilter==false))
        {
         // if stoch pushed up over LevelOne... (10 NOW WAS 20)
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne &&( HigherTF1STOCH<=1 || HigherTF2STOCH<=1))
           {
            fireAlerts(" 10.7(CT)TRADE BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch pushed up over LevelTwo... (30 NOW WAS 40)
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo &&( HigherTF1STOCH<=1 || HigherTF2STOCH<=1))
           {
            fireAlerts(" LAST CALL(CT)TRADE BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=Time[0];
           }
        }
     }
   if(tLastAlert<Time[0])
     {
      if((UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false) && ((UseSwapFilter==true && actual_short_swap>=0) || UseSwapFilter==false))
        {
         // if stoch dipped down under LevelFour...(90 NOW WAS 80)
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour  &&( HigherTF1STOCH < 99 && HigherTF2STOCH < 99))
           {
            fireAlerts("10.7 TREND SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch dipped down under LevelThree...(70 NOW WAS 60)
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree  &&( HigherTF1STOCH < 99 && HigherTF2STOCH < 99))
           {
            fireAlerts(" HEY SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK )");
            tLastAlert=Time[0];
           }
        }
      if((UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false) && ((UseSwapFilter==true && actual_long_swap>=0) || UseSwapFilter==false))
        {
         // if stoch pushed up over LevelOne... (10 NOW WAS 20)
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne &&( HigherTF1STOCH > 1 && HigherTF2STOCH > 1))
           {
            fireAlerts(" 10.7 TREND BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch pushed up over LevelTwo... (30 NOW WAS 40)
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo &&( HigherTF1STOCH > 1 && HigherTF2STOCH > 1))
           {
            fireAlerts(" HEY BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=Time[0];
           }
        }
     }
   if(tLastAlert<Time[0])
     {

      if((UseOnly7_2forEntryAlert==true && ShowOnlyBuyEntryAlerts==false) && ((UseSwapFilter==true && actual_short_swap>=0) || UseSwapFilter==false))
        {
         // if stoch dipped down under LevelFour...(90 NOW WAS 80)
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour)
           {
            fireAlerts("10.7 TREND SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch dipped down under LevelThree...(70 NOW WAS 60)
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree)
           {
            fireAlerts(" HEY SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK )");
            tLastAlert=Time[0];
           }
        }
      if((UseOnly7_2forEntryAlert==true && ShowOnlySellEntryAlerts==false) && ((UseSwapFilter==true && actual_long_swap>=0) || UseSwapFilter==false))
        {
         // if stoch pushed up over LevelOne... (10 NOW WAS 20)
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne)
           {
            fireAlerts(" 10.7 TREND BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=Time[0];
           }
         // if stoch pushed up over LevelTwo... (30 NOW WAS 40)
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo)
           {
            fireAlerts(" HEY BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=Time[0];
           }
        }




     }

   
      if(GiveStoch7ExitAlerts==true)
        {
         if(tLastAlert_fastexit<Time[0])
           {

            if(CountSells(Symbol())>0 &&  dStochMain[0]<=LevelOne)
              {
               fireAlerts(" CLOSE YOUR SELL "+Symbol()+" Stoch7 dipped below "+LevelOne);
               tLastAlert_fastexit=Time[0];
              }
            if(CountBuys(Symbol())>0 && dStochMain[0]>=LevelFour )
              {
               fireAlerts(" CLOSE YOUR BUY "+Symbol()+" Stoch7 pushed up above "+LevelFour);
               tLastAlert_fastexit=Time[0];
              }

           }

        }
      if (GiveStoch2_1_ExitAlerts==true)
      {
      if(tLastAlert_exit<Time[0])
        {
         if(CountSells(Symbol())>0 && (HigherTF1STOCH >=99  || HigherTF2STOCH >=99) )
           {
            fireAlerts(" CLOSE YOUR SELL "+Symbol()+" HTStoch changed to 100 ");
            tLastAlert_exit=Time[0];
           }
         if(CountBuys(Symbol())>0 && (HigherTF1STOCH <=1  || HigherTF2STOCH <=1) )
           {
            fireAlerts(" CLOSE YOUR BUY "+Symbol()+" HTStoch changed to 0 ");
            tLastAlert_exit=Time[0];
           }

        }
       }
      if(GiveTMASlopeExitAlert==true)
        {
         if(tLastAlert_cssexit<Time[0])
           {
            if(CountSells(Symbol())>0 && TMASlopeVal[0]>=TMASlopeCloseSellAlertLevel)
              {
               fireAlerts(" TMASlope CLOSE YOUR SELL "+Symbol()+" TMASlope is >="+TMASlopeCloseSellAlertLevel);
               tLastAlert_cssexit=Time[0];
              }
            if(CountBuys(Symbol())>0 && TMASlopeVal[0]<=TMASlopeCloseBuyAlertLevel)
              {
               fireAlerts(" TMASlope CLOSE YOUR BUY "+Symbol()+" TMASlope is <="+TMASlopeCloseBuyAlertLevel);
               tLastAlert_cssexit=Time[0];
              }

           }
        }

    

//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fireAlerts(string sMsg)
  {

     if(PopupAlert)
      Alert(sMsg);

   if(EmailAlert)
      SendMail("Stoch Alert On "+Symbol(),sMsg);
      if(PushAlert)
SendNotification(sMsg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountSells(string strSymbol)
  {
   int nOrderCount=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;

      if(OrderSymbol()!=strSymbol) continue;
      if(OrderType()==OP_SELL)

         nOrderCount++;
     }
   return(nOrderCount);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountBuys(string strSymbol)
  {
   int nOrderCount=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;

      if(OrderSymbol()!=strSymbol) continue;
      if(OrderType()==OP_BUY)

         nOrderCount++;
     }
   return(nOrderCount);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseEnough(double num1,double num2)
  {
/*
   This function addresses the problem of the way in which mql4 compares doubles. It often messes up the 8th
   decimal point.
   For example, if A = 1.5 and B = 1.5, then these numbers are clearly equal. Unseen by the coder, mql4 may
   actually be giving B the value of 1.50000001, and so the variable are not equal, even though they are.
   This nice little quirk explains some of the problems I have endured in the past when comparing doubles. This
   is common to a lot of program languages, so watch out for it if you program elsewhere.
   Gary (garyfritz) offered this solution, so our thanks to him.
   */

   if(num1==0 && num2==0) return(true); //0==0
   if(MathAbs(num1 - num2) / (MathAbs(num1) + MathAbs(num2)) < 0.00000001) return(true);

//Doubles are unequal
   return(false);

  }//End bool CloseEnough(double num1, double num2)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(int TimeFrame)
  {
   static datetime LastTime=0;
   if(iTime(NULL,TimeFrame,0)!=LastTime)
     {
      LastTime=iTime(NULL,TimeFrame,0);
      return (true);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSlope(string symbol,int tf,int shift)
  {
   double atr=iATR(symbol,tf,60,shift+10)/10;
   double gadblSlope=0.0;
   if(atr!=0)
     {
      double dblTma=calcTma(symbol,tf,shift);
      double dblPrev=calcTma(symbol,tf,shift+1);
      gadblSlope=(dblTma-dblPrev)/atr;
     }

   return ( gadblSlope );

  }
//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma(string symbol,int tf,int shift)
  {
   double dblSum  = iClose(symbol, tf, shift) * 21;
   double dblSumw = 21;
   int jnx,knx;

   for(jnx=1,knx=20; jnx<=20; jnx++,knx--)
     {
      dblSum  += ( knx * iClose(symbol, tf, shift + jnx) );
      dblSumw += knx;

      if(jnx<=shift)
        {
         dblSum  += ( knx * iClose(symbol, tf, shift - jnx) );
         dblSumw += knx;
        }
     }

   return( dblSum / dblSumw );

  }
//+------------------------------------------------------------------+
