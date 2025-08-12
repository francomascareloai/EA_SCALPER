//+------------------------------------------------------------------+
//|                                   AccountEquityAnalyzer v1.00    |
//|                                   Copyright © 2007, Project1972  |
//|        Property of  http://www.forex-tsd.com ELITE section ONLY  |
//| You are NOT ALLOWED to distribute this tool in any public forum  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                      This indicator is based on:                 |
//|                                                  i-BalEq_v1.mq4  |
//|                                           им »горь ¬. aka KimIV  |
//|                                             http://www.kimiv.ru  |
//+------------------------------------------------------------------+
#property copyright "Project1972"
#property link    "http://www.forex-tsd.com"
//
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 1
#property indicator_color3 LightBlue
#property indicator_width3 2
// +------------------------------------------------------------------+
// |  Input parameters                                                |
// +------------------------------------------------------------------+
  
extern double StartingDeposit           =50000;
extern int    MinutesScreenshootInterval=60;
//        
// 
int ImageTime=0;
double dBuf0[], dBuf1[], dBuf2[];
double InitialDeposit=0,PercentDD,MaxPercentDD,PercentDD2;
double MaxDrawdown,Balance,Equity,DW,StartingTime;
double Drawdown,WorstDrawdown,GDrawdownTime;
string MaxDD,MaxBL,MaxEQ,GMaxDrawdown,DrawDownAnalizer,DrawdownTime,GMaxPercentDD;
string TextDrawDownTime,PercentDDT,ROIText,growtext;
//------- 
int    oob[];      // 
int    oty[];      // 
double olo[];      // 
string osy[];      // 
double oop[];      // 
int    ocb[];      // 
double ocp[];      // 
double osw[];      // 
double opr[];      // 
//+------------------------------------------------------------------+
//|  Custom indicator initialization function                        |
//+------------------------------------------------------------------+
void init()
  {
   IndicatorDigits(2);
//----
   SetIndexBuffer(0, dBuf0);
   SetIndexLabel (0, "Balance");
   SetIndexStyle (0, DRAW_LINE);
//----
   SetIndexBuffer(1, dBuf1);
   SetIndexLabel (1, "Equity");
   SetIndexStyle (1, DRAW_LINE);
   
   SetIndexBuffer(2, dBuf2);
   SetIndexLabel (2, "Deposit");
   SetIndexStyle (2, DRAW_LINE);
    
   IndicatorShortName("Account Equity Analyzer");
   
   ObjectDelete("B_object");
   ObjectCreate("B_object",OBJ_LABEL,0,0,0);
   ObjectSet("B_object",OBJPROP_XDISTANCE,10);
   ObjectSet("B_object",OBJPROP_YDISTANCE,2);

   ObjectDelete("E_object");
   ObjectCreate("E_object",OBJ_LABEL,0,0,0);
   ObjectSet("E_object",OBJPROP_XDISTANCE,190);
   ObjectSet("E_object",OBJPROP_YDISTANCE,2);

   ObjectDelete("PL_object");
   ObjectCreate("PL_object",OBJ_LABEL,0,0,0);
   ObjectSet("PL_object",OBJPROP_XDISTANCE,340);
   ObjectSet("PL_object",OBJPROP_YDISTANCE,2);

   ObjectDelete("Time_object");
   ObjectCreate("Time_object",OBJ_LABEL,0,0,0);
   ObjectSet("Time_object",OBJPROP_XDISTANCE,10);
   ObjectSet("Time_object",OBJPROP_YDISTANCE,45);

   ObjectDelete("Time_DD");
   ObjectCreate("Time_DD",OBJ_LABEL,0,0,0);
   ObjectSet("Time_DD",OBJPROP_XDISTANCE,10);
   ObjectSet("Time_DD",OBJPROP_YDISTANCE,25);

   ObjectDelete("note");
   ObjectCreate("note",OBJ_LABEL,1,0,0);
   ObjectSet("note",OBJPROP_XDISTANCE,250);
   ObjectSet("note",OBJPROP_YDISTANCE,2);

   ObjectDelete("DDPercent");
   ObjectCreate("DDPercent",OBJ_LABEL,0,0,0);
   ObjectSet("DDPercent",OBJPROP_XDISTANCE,480);
   ObjectSet("DDPercent",OBJPROP_YDISTANCE,35);

   ObjectDelete("DDPercent2");
   ObjectCreate("DDPercent2",OBJ_LABEL,0,0,0);
   ObjectSet("DDPercent2",OBJPROP_XDISTANCE,630);
   ObjectSet("DDPercent2",OBJPROP_YDISTANCE,24);

   ObjectDelete("ROI");
   ObjectCreate("ROI",OBJ_LABEL,0,0,0);
   ObjectSet("ROI",OBJPROP_XDISTANCE,480);
   ObjectSet("ROI",OBJPROP_YDISTANCE,60);

   ObjectDelete("ROI2");
   ObjectCreate("ROI2",OBJ_LABEL,0,0,0);
   ObjectSet("ROI2",OBJPROP_XDISTANCE,555);
   ObjectSet("ROI2",OBJPROP_YDISTANCE,49);

   ObjectDelete("ROI3");
   ObjectCreate("ROI3",OBJ_LABEL,0,0,0);
   ObjectSet("ROI3",OBJPROP_XDISTANCE,10);
   ObjectSet("ROI3",OBJPROP_YDISTANCE,65);

   ObjectDelete("ROI4");
   ObjectCreate("ROI4",OBJ_LABEL,0,0,0);
   ObjectSet("ROI4",OBJPROP_XDISTANCE,295);
   ObjectSet("ROI4",OBJPROP_YDISTANCE,65);

   ObjectDelete("ROI5");
   ObjectCreate("ROI5",OBJ_LABEL,0,0,0);
   ObjectSet("ROI5",OBJPROP_XDISTANCE,10);
   ObjectSet("ROI5",OBJPROP_YDISTANCE,85);

   ObjectDelete("ROI6");
   ObjectCreate("ROI6",OBJ_LABEL,0,0,0);
   ObjectSet("ROI6",OBJPROP_XDISTANCE,155);
   ObjectSet("ROI6",OBJPROP_YDISTANCE,85);
   
   GMaxDrawdown=AccountNumber()+"_MaxDrawdown";
   if (!GlobalVariableCheck(GMaxDrawdown)) GlobalVariableSet(GMaxDrawdown,0);
   GMaxPercentDD=AccountNumber()+"_GMaxPercentDD";
   if (!GlobalVariableCheck(GMaxPercentDD)) GlobalVariableSet(GMaxPercentDD,0);
   DrawdownTime=AccountNumber()+"_DrawdownTime";
   if (!GlobalVariableCheck(DrawdownTime)) GlobalVariableSet(DrawdownTime,0);
   ImageTime=TimeCurrent()+60;
  
  }
  
void deinit()
{
 ObjectDelete("B_object");
 ObjectDelete("E_object");
 ObjectDelete("PL_object");
 ObjectDelete("Time_object");
 ObjectDelete("Time_DD");
 ObjectDelete("note");
 ObjectDelete("DDPercent");
 ObjectDelete("DDPercent2");
 ObjectDelete("ROI");
 ObjectDelete("ROI2");
 ObjectDelete("ROI3");
 ObjectDelete("ROI4");
 ObjectDelete("ROI5");
 ObjectDelete("ROI6");
 return(0);
}
//+------------------------------------------------------------------+
//|  Custom indicator iteration function                             |
//+------------------------------------------------------------------+
void start()
  {
   double b, e, p, t;
   int    i, j, k;
//----
   ReadDeals();
 	 if(oob[0] < 0) 
 	     return;
 	 k = ArraySize(oob);
//----
   for(i = Bars; i >= oob[0]; i--)
     {
       dBuf0[i] = EMPTY_VALUE;
       dBuf1[i] = EMPTY_VALUE;
     }
   for(i = oob[0]; i >= 0; i--)
     {
       b = StartingDeposit; 
       e = 0;
       for(j = 0; j < k; j++)
         {
           if(i <= oob[j] && i >= ocb[j])
             {
               p = MarketInfo(osy[j], MODE_POINT);
               t = MarketInfo(osy[j], MODE_TICKVALUE);
               if(t == 0) 
                   t = 10;
               if(p == 0) 
                   if(StringFind(osy[j], "JPY") < 0) 
                       p = 0.0001; 
                   else 
                       p=0.01;
               if(oty[j] == OP_BUY) 
                   e += (iClose(osy[j], 0, i) - oop[j]) / p*olo[j]*t;
               else 
                   e += (oop[j] - iClose(osy[j], 0, i)) / p*olo[j]*t;
             } 
           else 
               if(i <= ocb[j]) 
                   b += osw[j] + opr[j];
         }
       dBuf2[i] = StartingDeposit;
       dBuf0[i] = b;
       dBuf1[i] = b + e;
     }
int OrderOpen;     
for (i = 0; i <= OrdersHistoryTotal(); i++) 
{ 
 OrderSelect(i,SELECT_BY_POS,MODE_HISTORY); 
 OrderOpen=OrderOpenTime();
 if(StartingTime==0 && OrderOpen>StartingTime)
 { 
  StartingTime=OrderOpen; 
 } 
} 
//Print("StartingTime=",TimeToStr(StartingTime));
double AccountGrow=((AccountEquity()-StartingDeposit)/(CurTime()-StartingTime))*31536000;
double ROI=(AccountGrow/StartingDeposit)*100;
//Print("StartingTime=",AccountGrow," ROI=",ROI);  
WorstDrawdown=GlobalVariableGet(GMaxDrawdown);
GDrawdownTime=GlobalVariableGet(DrawdownTime);
MaxPercentDD=GlobalVariableGet(GMaxPercentDD);
Drawdown=AccountEquity()-AccountBalance();
if (Drawdown<WorstDrawdown)
 {
  WorstDrawdown=Drawdown;
  GDrawdownTime=CurTime();
  GlobalVariableSet(GMaxDrawdown,WorstDrawdown);
  GlobalVariableSet(DrawdownTime,GDrawdownTime);
 }
PercentDD=(MathAbs(WorstDrawdown)/AccountBalance())*100; 
if (PercentDD>MaxPercentDD)
 {
  MaxPercentDD=PercentDD;
  GlobalVariableSet(GMaxPercentDD,MaxPercentDD);
 }


if (WorstDrawdown<MaxDrawdown)
 {
  MaxDrawdown=WorstDrawdown;
 } 
PercentDD2=(MathAbs(MaxDrawdown)/AccountBalance())*100;
if (PercentDD2>MaxPercentDD)MaxPercentDD=PercentDD2;
MaxBL="Balance=$"+DoubleToStr(AccountBalance(),2);
MaxEQ="Equity=$"+DoubleToStr(AccountEquity(),2);
MaxDD="Max Floating Drawdown=$"+DoubleToStr(MaxDrawdown,2);
PercentDDT=DoubleToStr(MaxPercentDD,2)+"%";
growtext="a $"+DoubleToStr(StartingDeposit,2)+" account will become $"+DoubleToStr(StartingDeposit+((StartingDeposit*ROI)/100),2)+" in one year";
ROIText=DoubleToStr(ROI,0)+"%";
TextDrawDownTime="";
if (GDrawdownTime!=0) {TextDrawDownTime="Time of Max Drawdown Registered: "+TimeToStr(GDrawdownTime);}
ObjectSetText("B_object",MaxBL,12,"Arial",Yellow);
ObjectSetText("E_object",MaxEQ,12,"Arial",Blue);
ObjectSetText("PL_object",MaxDD,12,"Arial",Red);
ObjectSetText("Time_object","Current Broker Time is : "+TimeToStr(CurTime()),10,"Arial",White);
ObjectSetText("Time_DD",TextDrawDownTime,10,"Arial",White);
ObjectSetText("note","NOTE: Graph calculation is not reliable for the last bar",9,"Arial",Lime);
ObjectSetText("ROI3","ROI is the estimate Annual Return over the initial",10,"Arial",White);
ObjectSetText("ROI4","Account Equity",10,"Arial",White);
ObjectSetText("ROI6",growtext,10,"Arial",White);
ObjectSetText("DDPercent","Max Floating Drawdown:",10,"Arial",Red);
ObjectSetText("DDPercent2",PercentDDT,20,"Arial",Red);
if (ROI>=0)
{
ObjectSetText("ROI","Annual ROI:",10,"Arial",Lime);
ObjectSetText("ROI2",ROIText,20,"Arial",Lime);
ObjectSetText("ROI5","At the current grow rate, ",10,"Arial",White);
}
else
{
ObjectSetText("ROI","Annual ROI:",10,"Arial",Red);
ObjectSetText("ROI2",ROIText,20,"Arial",Red);
ObjectSetText("ROI5","At the current loss rate, ",10,"Arial",White);
}

if (ImageTime<TimeCurrent())
{
 WindowScreenShot("EquityGraph.gif",820,500);
 if (GetLastError()==0) {ImageTime=TimeCurrent()+(MinutesScreenshootInterval*60);}
}   
}
//+------------------------------------------------------------------+
//|    ReadDeals                                                     |
//+------------------------------------------------------------------+
void ReadDeals()
  {
   ArrayResize(oob, 0);
   ArrayResize(oty, 0);
   ArrayResize(olo, 0);
   ArrayResize(osy, 0);
   ArrayResize(oop, 0);
   ArrayResize(ocb, 0);
   ArrayResize(ocp, 0);
   ArrayResize(osw, 0);
   ArrayResize(opr, 0);
   int h = OrdersHistoryTotal(), i, k;
//----
   for(i = 0; i < h; i++)
     {
       if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                   k = ArraySize(oob);
                   ArrayResize(oob, k + 1);
                   ArrayResize(oty, k + 1);
                   ArrayResize(olo, k + 1);
                   ArrayResize(osy, k + 1);
                   ArrayResize(oop, k + 1);
                   ArrayResize(ocb, k + 1);
                   ArrayResize(ocp, k + 1);
                   ArrayResize(osw, k + 1);
                   ArrayResize(opr, k + 1);
                   oob[k] = iBarShift(NULL, 0, OrderOpenTime()); 
                   oty[k] = OrderType();       // тип
                   olo[k] = OrderLots();       // лот
                   osy[k] = OrderSymbol();     // инструмент
                   oop[k] = OrderOpenPrice();  // цена открыти€
                   ocb[k] = iBarShift(NULL, 0, OrderCloseTime());
                   ocp[k]=OrderClosePrice();   // цена закрыти€
                   osw[k]=OrderSwap();         // своп
                   opr[k]=OrderProfit();       // прибыль
                 }
         }
     }
   h = OrdersTotal();
//----
   for(i = 0; i < h; i++)
     {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                   k = ArraySize(oob);
                   ArrayResize(oob, k + 1);
                   ArrayResize(oty, k + 1);
                   ArrayResize(olo, k + 1);
                   ArrayResize(osy, k + 1);
                   ArrayResize(oop, k + 1);
                   ArrayResize(ocb, k + 1);
                   ArrayResize(ocp, k + 1);
                   ArrayResize(osw, k + 1);
                   ArrayResize(opr, k + 1);
                   oob[k] = iBarShift(NULL, 0, OrderOpenTime()); 
                   oty[k] = OrderType();       // тип
                   olo[k] = OrderLots();       // лот
                   osy[k] = OrderSymbol();     // инструмент
                   oop[k] = OrderOpenPrice();  // цена открыти€
                   ocb[k] = 0;                 // номер бара закрыти€
                   ocp[k] = 0;                 // цена закрыти€
                   osw[k] = OrderSwap();       // своп
                   opr[k] = OrderProfit();     // прибыль
                 }
         }
     }
  }
//+------------------------------------------------------------------+

