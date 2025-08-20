// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65127

//+------------------------------------------------------------------+
//|                                    MTF_MCP_TrendStop_HeatMap.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property  indicator_buffers 21
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrDarkGray
#property indicator_color4  clrLime
#property indicator_color5  clrRed
#property indicator_color6  clrDarkGray
#property indicator_color7  clrLime
#property indicator_color8  clrRed
#property indicator_color9  clrDarkGray
#property indicator_color10 clrLime
#property indicator_color11 clrRed
#property indicator_color12 clrDarkGray
#property indicator_color13 clrLime
#property indicator_color14 clrRed
#property indicator_color15 clrDarkGray
#property indicator_color16 clrLime
#property indicator_color17 clrRed
#property indicator_color18 clrDarkGray
#property indicator_color19 clrLime
#property indicator_color20 clrRed
#property indicator_color21 clrDarkGray
#property indicator_minimum 0
#property indicator_maximum 5

extern int    Periods    = 10;
extern string Comment0       = "<< Currency Pair: Leave Blank for Current >>";
extern string Currency_Pair  = "EURUSD";

double w1_up[];
double w1_dn[];
double w1_nt[];
double d1_up[];
double d1_dn[];
double d1_nt[];
double h4_up[];
double h4_dn[];
double h4_nt[];
double h1_up[];
double h1_dn[];
double h1_nt[];
double m30_up[];
double m30_dn[];
double m30_nt[];
double m15_up[];
double m15_dn[];
double m15_nt[];
double m5_up[];
double m5_dn[];
double m5_nt[];

string IndName;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init(){
   
       double temp = iCustom(NULL, 0, "TrendStop", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TrendStop' indicator");
       return INIT_FAILED;
   }
   IndicatorBuffers(21);
   
   SetIndexBuffer(0,w1_up);
   SetIndexBuffer(1,w1_dn);
   SetIndexBuffer(2,w1_nt);
   SetIndexBuffer(3,d1_up);
   SetIndexBuffer(4,d1_dn);
   SetIndexBuffer(5,d1_nt);
   SetIndexBuffer(6,h4_up);
   SetIndexBuffer(7,h4_dn);
   SetIndexBuffer(8,h4_nt);
   SetIndexBuffer(9,h1_up);
   SetIndexBuffer(10,h1_dn);
   SetIndexBuffer(11,h1_nt);
   SetIndexBuffer(12,m30_up);
   SetIndexBuffer(13,m30_dn);
   SetIndexBuffer(14,m30_nt);
   SetIndexBuffer(15,m15_up);
   SetIndexBuffer(16,m15_dn);
   SetIndexBuffer(17,m15_nt);
   SetIndexBuffer(18,m5_up);
   SetIndexBuffer(19,m5_dn);
   SetIndexBuffer(20,m5_nt);
   
   int arrow = 110;
   for (int i = 0; i < 21; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndName = "MTF_MCP_TrendStop_HeatMap";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   Limpiar();
   
   return(0);
}

int deinit(){
   Limpiar();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Currency_Pair!="") string Symbolo = Currency_Pair; else Symbolo = NULL;
   
   double TS;
   
   // Week
   if (Period() < 43200){
      period     = PERIOD_W1;
      multiplier = 10080/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               w1_up[j] = 1.0;
            else
               w1_dn[j] = 1.0;
         }
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
   } // Week End
   
   // Day
   if (Period() < 10080){
      period     = PERIOD_D1;
      multiplier = 1440/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               d1_up[j] = 1.5;
            else
               d1_dn[j] = 1.5;
         }
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
   } // Day End
   
   // H4
   if (Period() < 1440){
      period     = PERIOD_H4;
      multiplier = 240/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               h4_up[j] = 2.0;
            else
               h4_dn[j] = 2.0;
         }
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
   } // H4 End
   
   // H1
   if (Period() < 240){
      period     = PERIOD_H1;
      multiplier = 60/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               h1_up[j] = 2.5;
            else
               h1_dn[j] = 2.5;
         }
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
   } // H1 End
   
   // M30
   if (Period() < 60){
      period     = PERIOD_M30;
      multiplier = 30/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               m30_up[j] = 3.0;
            else
               m30_dn[j] = 3.0;
         }
         Etiqueta("HeatLbl_M30"," - M30 ",3.3, Time[0]);
      }
   } // M30 End
   
   // M15
   if (Period() < 30){
      period     = PERIOD_M15;
      multiplier = 15/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               m15_up[j] = 3.5;
            else
               m15_dn[j] = 3.5;
         }
         Etiqueta("HeatLbl_M15"," - M15 ",3.8, Time[0]);
      }
   } // M15 End
   
   // M5
   if (Period() < 15){
      period     = PERIOD_M5;
      multiplier = 5/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         TS = iCustom(NULL,period,"TrendStop",Periods,0,i);

         for (j=current; j>=next; j--){
            if (Close[j] > TS)
               m5_up[j] = 4.0;
            else
               m5_dn[j] = 4.0;
         }
         Etiqueta("HeatLbl_M5"," - M5 ",4.3, Time[0]);
      }
   } // M5 End
   
//----
   return(0);
}

int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
  ObjectSetText(IndicatorObjPrefix + sName, " "+sLabel, 8, "Lucida Console", clrWhite);
  ObjectMove(IndicatorObjPrefix + sName,0,tTime+Period()*60*2, dPrice);
  return(0);
}

void Limpiar(){
}