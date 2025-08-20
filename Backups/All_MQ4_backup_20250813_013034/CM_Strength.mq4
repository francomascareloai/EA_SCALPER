//+------------------------------------------------------------------+
//|                                                  CM_Strength.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define BullColor Lime
#define BearColor Red

#define NONE 0
#define DOWN -1
#define UP 1


sinput int                       x_axis                     =0;
sinput int                       y_axis                    =70;

bool                      UseDefaultPairs            = true;              // Use the default 28 pairs
string                    OwnPairs                   = "";                // Comma seperated own pair list

string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
string TradePairs[];
string curr[8] = {"USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"};
string EUR[7] = {"EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD"};
string GBP[6] = {"GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD"};
string GBP_R[1] = {"EURGBP"};
string CHF[1] = {"CHFJPY"};
string CHF_R[6] = {"AUDCHF","CADCHF","EURCHF","GBPCHF","NZDCHF","USDCHF"};
string USD[3] = {"USDCAD","USDCHF","USDJPY"};
string USD_R[4] = {"AUDUSD","EURUSD","GBPUSD","NZDUSD"};
string CAD[2] = {"CADCHF","CADJPY"};
string CAD_R[5] = {"AUDCAD","EURCAD","GBPCAD","NZDCAD","USDCAD"};
string NZD[4] = {"NZDCAD","NZDCHF","NZDJPY","NZDUSD"};
string NZD_R[3] = {"AUDNZD","EURNZD","GBPNZD"};
string AUD[5] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD"};
string AUD_R[2] = {"EURAUD","GBPAUD"};
string JPY_R[7] = {"AUDJPY","CADJPY","CHFJPY","EURJPY","GBPJPY","NZDJPY","USDJPY"};

double currstrength[8];
double prevstrength[8];
string postfix=StringSubstr(Symbol(),6,6);

struct pairinf {
   double PairPip;
   int pipsfactor;
   double Pips;
   double PipsSig;
   double Pipsprev;
   double Spread;
   double point;
   int lastSignal;
   int    base;
   int    quote;   
}; pairinf pairinfo[];

struct currency 
  {
   string            curr;
   double            strength;
   double            prevstrength;
   double            crs;
   int               sync;
   datetime          lastbar;
  }
; currency currencies[8];

struct signal { 
   string symbol;
   double range;
   double range1;
   double ratio;
   double ratio1;
   double bidratio;
   double fact;
   double strength;
   double strength1;
   double strength2;
   double calc;
   double strength3;
   double strength4;
   double strength5;
   double strength6;
   double strength7;
   double strength8;
   double strength_Gap;
   double hi;
   double lo;
   double prevratio;   
   double prevbid;   
   int    shift;
   double open;
   double close;
   double bid;
   double point;   
   double Signalperc;   
   double SigRatio;
   double SigRelStr;
   double SigBSRatio;    
   double SigCRS;
   double SigGap;
   double SigGapPrev;
   double SigRatioPrev;
   double Signalrsi;
   
}; signal signals[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

    if (UseDefaultPairs == true)
      ArrayCopy(TradePairs,DefaultPairs);
    else
      StringSplit(OwnPairs,',',TradePairs);
   
  for (int i=0;i<8;i++)
      currencies[i].curr = curr[i]; 
   
   if (ArraySize(TradePairs) <= 0) {
      Print("No pairs to trade");
      return(INIT_FAILED);
   }
   
   ArrayResize(pairinfo,ArraySize(TradePairs));
          
    for(int i=0;i<ArraySize(TradePairs);i++){
    TradePairs[i]=TradePairs[i]+postfix;    

     pairinfo[i].base = StringSubstr(TradePairs[i],0,3);
     pairinfo[i].quote = StringSubstr(TradePairs[i],3,0);
   
      if (MarketInfo(TradePairs[i] ,MODE_DIGITS) == 4 || MarketInfo(TradePairs[i] ,MODE_DIGITS) == 2) {
         pairinfo[i].PairPip = MarketInfo(TradePairs[i] ,MODE_POINT);
         pairinfo[i].pipsfactor = 1;
      } else { 
         pairinfo[i].PairPip = MarketInfo(TradePairs[i] ,MODE_POINT)*10;
         pairinfo[i].pipsfactor = 10;
      }
 
   }



   EventSetTimer(1);




//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
  
  //+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
      
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   GetSignals();
   displayMeter();
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
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
void displayMeter() {
   
   double arrt[8][3];
   int arr2,arr3;
   arrt[0][0] = currency_strength(curr[0]); arrt[1][0] = currency_strength(curr[1]); arrt[2][0] = currency_strength(curr[2]);
   arrt[3][0] = currency_strength(curr[3]); arrt[4][0] = currency_strength(curr[4]); arrt[5][0] = currency_strength(curr[5]);
   arrt[6][0] = currency_strength(curr[6]); arrt[7][0] = currency_strength(curr[7]);
   arrt[0][2] = old_currency_strength(curr[0]); arrt[1][2] = old_currency_strength(curr[1]);arrt[2][2] = old_currency_strength(curr[2]);
   arrt[3][2] = old_currency_strength(curr[3]); arrt[4][2] = old_currency_strength(curr[4]);arrt[5][2] = old_currency_strength(curr[5]);
   arrt[6][2] = old_currency_strength(curr[6]);arrt[7][2] = old_currency_strength(curr[7]);
   arrt[0][1] = 0; arrt[1][1] = 1; arrt[2][1] = 2; arrt[3][1] = 3; arrt[4][1] = 4;arrt[5][1] = 5; arrt[6][1] = 6; arrt[7][1] = 7;
   ArraySort(arrt, WHOLE_ARRAY, 0, MODE_DESCEND);
     
   for (int m = 0; m < 8; m++) {
      arr2 = arrt[m][1];
      arr3=(int)arrt[m][2];
      currstrength[m] = arrt[m][0];
      prevstrength[m] = arrt[m][2]; 
         SetText(curr[arr2]+"pos",IntegerToString(m+1)+".",x_axis+615,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
         SetText(curr[arr2]+"curr", curr[arr2],x_axis+630,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
         SetText(curr[arr2]+"currdig", DoubleToStr(arrt[m][0],1),x_axis+670,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
        // SetText(curr[arr2]+"currdig", DoubleToStr(ratio[m][0],1),x_axis+280,(m*18)+y_axis+17,color_for_profit(arrt[m][0]),12);
        
        if(currstrength[m] > prevstrength[m]){SetObjText("Sdir"+IntegerToString(m),CharToStr(233),x_axis+700,(m*18)+y_axis+17,BullColor,12);}
         else if(currstrength[m] < prevstrength[m]){SetObjText("Sdir"+IntegerToString(m),CharToStr(234),x_axis+700,(m*18)+y_axis+17,BearColor,12);}
         else {SetObjText("Sdir"+IntegerToString(m),CharToStr(243),x_axis+700,(m*18)+y_axis+17,clrYellow,12);}
         
         
         }
 ChartRedraw(); 
}
color color_for_profit(double total) 
  {
  if(total<2.0)
      return (clrRed);
   if(total<=3.0)
      return (clrOrangeRed);
   if(total>7.0)
      return (clrLime);
   if(total>6.0)
      return (clrGreen);
   if(total>5.0)
      return (clrSandyBrown);
   if(total<=5.0)
      return (clrYellow);       
   return(clrSteelBlue);
  }

double currency_strength(string pair) {
   int fact;
   string sym;
   double range;
   double ratio;
   double strength = 0;
   int cnt1 = 0;
   
   for (int x = 0; x < ArraySize(TradePairs); x++) {
      fact = 0;
      sym = TradePairs[x];
      if (pair == StringSubstr(sym, 0, 3) || pair == StringSubstr(sym, 3, 3)) {
        // sym = sym + tempsym;
         range = (MarketInfo(sym, MODE_HIGH) - MarketInfo(sym, MODE_LOW)) ;
         if (range != 0.0) {
            ratio = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_LOW)) / range );
            if (ratio > 3.0)  fact = 1;
            if (ratio > 10.0) fact = 2;
            if (ratio > 25.0) fact = 3;
            if (ratio > 40.0) fact = 4;
            if (ratio > 50.0) fact = 5;
            if (ratio > 60.0) fact = 6;
            if (ratio > 75.0) fact = 7;
            if (ratio > 90.0) fact = 8;
            if (ratio > 97.0) fact = 9;
            cnt1++;
            if (pair == StringSubstr(sym, 3, 3)) fact = 9 - fact;
            strength += fact;
           // signals[x].strength += fact;
         }
      } 
           
   }
  // for (int x = 0; x < ArraySize(TradePairs); x++) 
   //if(cnt1!=0)signals[x].strength /= cnt1;
   if(cnt1!=0)strength /= cnt1;
   return (strength);
   
 }
//-----------------------------------------------------------------------------------+
double old_currency_strength(string pair) 
  {
   int fact;
   string sym;
   double range;
   double ratio;
   double strength=0;
   int cnt1=0;

   for(int x=0; x<ArraySize(TradePairs); x++) 
     {
      fact= 0;
      sym = TradePairs[x];
      int bar = iBarShift(TradePairs[x],PERIOD_M1,TimeCurrent()-1800);
      double prevbid = iClose(TradePairs[x],PERIOD_M1,bar);
      
      if(pair==StringSubstr(sym,0,3) || pair==StringSubstr(sym,3,3)) 
        {
         // sym = sym + tempsym;
         range=(MarketInfo(sym,MODE_HIGH)-MarketInfo(sym,MODE_LOW));
         if(range!=0.0) 
           {
            ratio=100.0 *((prevbid-MarketInfo(sym,MODE_LOW))/range);

            if(ratio > 3.0)  fact = 1;
            if(ratio > 10.0) fact = 2;
            if(ratio > 25.0) fact = 3;
            if(ratio > 40.0) fact = 4;
            if(ratio > 50.0) fact = 5;
            if(ratio > 60.0) fact = 6;
            if(ratio > 75.0) fact = 7;
            if(ratio > 90.0) fact = 8;
            if(ratio > 97.0) fact = 9;
            
            cnt1++;

            if(pair==StringSubstr(sym,3,3))
               fact=9-fact;

            strength+=fact;

           }
        }
     }
   if(cnt1!=0)
      strength/=cnt1;

   return (strength);
  
}


//-----------------------------------------------------------------------------------------------+ 
void GetSignals() {
   int cnt = 0;
   ArrayResize(signals,ArraySize(TradePairs));
   for (int i=0;i<ArraySize(signals);i++) {
      signals[i].symbol=TradePairs[i]; 
      signals[i].point=MarketInfo(signals[i].symbol,MODE_POINT);
      signals[i].open=iOpen(signals[i].symbol,PERIOD_D1,0);      
      signals[i].close=iClose(signals[i].symbol,PERIOD_D1,0);
      signals[i].hi=MarketInfo(signals[i].symbol,MODE_HIGH);
      signals[i].lo=MarketInfo(signals[i].symbol,MODE_LOW);
      signals[i].bid=MarketInfo(signals[i].symbol,MODE_BID);
      signals[i].range=(signals[i].hi-signals[i].lo);
      signals[i].shift = iBarShift(signals[i].symbol,PERIOD_M1,TimeCurrent()-1800);
      signals[i].prevbid = iClose(signals[i].symbol,PERIOD_M1,signals[i].shift);
                 
     if(signals[i].range!=0) {            
      signals[i].ratio=MathMin(((signals[i].bid-signals[i].lo)/signals[i].range*100 ),100);
      signals[i].prevratio=MathMin(((signals[i].prevbid-signals[i].lo)/signals[i].range*100 ),100);     
           
      for (int j = 0; j < 8; j++){
            
      if(signals[i].ratio <= 3.0) signals[i].fact = 0;
      if(signals[i].ratio > 3.0)  signals[i].fact = 1;
      if(signals[i].ratio > 10.0) signals[i].fact = 2;
      if(signals[i].ratio > 25.0) signals[i].fact = 3;
      if(signals[i].ratio > 40.0) signals[i].fact = 4;
      if(signals[i].ratio > 50.0) signals[i].fact = 5;
      if(signals[i].ratio > 60.0) signals[i].fact = 6;
      if(signals[i].ratio > 75.0) signals[i].fact = 7;
      if(signals[i].ratio > 90.0) signals[i].fact = 8;
      if(signals[i].ratio > 97.0) signals[i].fact = 9;
       cnt++;
      
      if(curr[j]==StringSubstr(signals[i].symbol,3,3))
               signals[i].fact=9-signals[i].fact;

      if(curr[j]==StringSubstr(signals[i].symbol,0,3)) {
               signals[i].strength1=signals[i].fact;
              }  else{
      if(curr[j]==StringSubstr(signals[i].symbol,3,0))
               signals[i].strength2=signals[i].fact;
              }

      signals[i].calc =signals[i].strength1-signals[i].strength2;
      
      signals[i].strength=currency_strength(curr[j]);

            if(curr[j]==StringSubstr(signals[i].symbol,0,3)){
               signals[i].strength3=signals[i].strength;
            } else{
            if(curr[j]==StringSubstr(signals[i].symbol,3,0))
               signals[i].strength4=signals[i].strength;
            }
            signals[i].strength5=(signals[i].strength3-signals[i].strength4);
            
       signals[i].strength=old_currency_strength(curr[j]);

            if(curr[j]==StringSubstr(signals[i].symbol,0,3)){
               signals[i].strength6=signals[i].strength;
            } else {
            if(curr[j]==StringSubstr(signals[i].symbol,3,0))
               signals[i].strength7=signals[i].strength;
            }
            signals[i].strength8=(signals[i].strength6-signals[i].strength7);     
            signals[i].strength_Gap=signals[i].strength5-signals[i].strength8;
        
        
        
        if(signals[i].ratio>signals[i].prevratio){
                signals[i].SigRatioPrev=UP;
           } else {
        if(signals[i].ratio<signals[i].prevratio)
                signals[i].SigRatioPrev=DOWN;
           }      
                    
 
             
       
              
        if(signals[i].strength5>signals[i].strength8){
              signals[i].SigGapPrev=UP;
             } else {
        if(signals[i].strength5<signals[i].strength8)      
               signals[i].SigGapPrev=DOWN;
             }          
      
      }
     
     }
      
    }    

}

//+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
  } 
  
  //+------------------------------------------------------------------+

void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
   ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  } 
//-----------------------------------------------------------------------+