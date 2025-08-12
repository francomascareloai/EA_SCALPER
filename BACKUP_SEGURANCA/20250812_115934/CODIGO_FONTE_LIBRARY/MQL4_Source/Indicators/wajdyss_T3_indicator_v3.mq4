//+------------------------------------------------------------------+
//|                                             wajdyss_MA_indicator |
//|                                           Copyright 2007 Wajdyss |
//|                                                wajdyss@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2008 Wajdyss"
#property link      "wajdyss@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_width1  2
#property indicator_width2  2

extern int MA_Period=14;
extern double b=0.7;
extern string Note1="--------------";
extern bool alert=true;
string file="alert.wav";
extern string Note2="--------------";
extern int TextSize=14;
extern color TextColor1=White;
extern color TextColor2=Yellow;
extern color TextColor3=Aqua;
extern color TextColor4=Red;
extern color TextColor5=Chartreuse;

double CrossUp[];
double CrossDown[];
int eyear=9999;
int emonth=9;
int eday=9;
bool al1=false;
bool al2=false;
int date1=999;
int date2=999;
int date6=999;
int second=20;
string Name="wajdyss T3 indicator";
int days;


double MapBuffer;

double e1[],e2[],e3[],e4[],e5[],e6[];
double c1,c2,c3,c4;
double n,w1,w2,b2,b3;
int UP[];
int UP2[];
int UU;
int DD;
int date3=999;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,CrossUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,CrossDown);
//----
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,Red);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//IndicatorShortName("T3"+MA_Period);
   SetIndexDrawBegin(2,100);
//SetIndexBuffer(0,MapBuffer);


//---- variable reset
//e2=0; e3=0; e4=0; e5=0; e6=0;
   c1=0; c2=0; c3=0; c4=0;
   n=0;
   w1=0; w2=0;
   b2=0; b3=0;

   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   n=MA_Period;

   if(n<1) n=1;
   n=1+0.5*(n-1);
   w1 = 2 / (n + 1);
   w2 = 1 - w1;

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   ObjectDelete("a label");
   ObjectDelete("b label");
   ObjectDelete("c label");
   ObjectDelete("d label");
   ObjectDelete("e label");

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//a
   if(ObjectFind("a label")!=0)
     {
      ObjectCreate("a label",OBJ_LABEL,0,0,0);
      ObjectSetText("a label","ÈÓã Çááå ÇáÑÍãä ÇáÑÍíã",TextSize,"Arial",TextColor1);
      ObjectSet("a label",OBJPROP_XDISTANCE,350);
      ObjectSet("a label",OBJPROP_YDISTANCE,0);
     }

//b
   if(ObjectFind("b label")!=0)
     {
      ObjectCreate("b label",OBJ_LABEL,0,0,0);
      ObjectSetText("b label",Name,TextSize,"Arial",TextColor2);
      ObjectSet("b label",OBJPROP_XDISTANCE,335);
      ObjectSet("b label",OBJPROP_YDISTANCE,25);
     }

// c

   if(ObjectFind("c label")!=0)
     {
      ObjectCreate("c label",OBJ_LABEL,0,0,0);
      ObjectSetText("c label","wajdyss@yahoo.com",TextSize,"Arial",TextColor3);
      ObjectSet("c label",OBJPROP_XDISTANCE,335);
      ObjectSet("c label",OBJPROP_YDISTANCE,50);
     }

// if (Period() != 1440) return(0);

   /*if((Year()>eyear) || (Year()==eyear && Month()>emonth) || (Year()==eyear && Month()==emonth && Day()>eday))
     {
      //d
      if(ObjectFind("d label")!=0)
        {
         ObjectCreate("d label",OBJ_LABEL,0,0,0);
         ObjectSetText("d label","the indicator has expired , contact us by E-mail",TextSize,"Arial",TextColor4);
         ObjectSet("d label",OBJPROP_XDISTANCE,250);
         ObjectSet("d label",OBJPROP_YDISTANCE,75);
        }
      return(0);
     }
   else
   if(ObjectFind("d label")!=0)
     {
      ObjectCreate("d label",OBJ_LABEL,0,0,0);
      ObjectSetText("d label","the indicator well expire after ( "+eday+"-"+emonth+"-"+eyear+" )",TextSize,"Arial",TextColor4);
      ObjectSet("d label",OBJPROP_XDISTANCE,265);
      ObjectSet("d label",OBJPROP_YDISTANCE,75);
     }
*/
   double  GSignalUP=0,SignalUP=0,GSignalDOWN=0,SignalDOWN=0,AllSignal=0,BSignalUP=0,BSignalDOWN=0;
   double GSignals,GSignalsP,GSignalUPP,GSignalDOWNP;
   string sameforecast,notsameforecast,wajdyssforecast,status;

//   if (manual ==true) status="manual"; else status="auto";
   //int limit;
   //int sBars=600;
   //limit=(sBars)-1;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;   
   int sBars=limit+1;
   UU=0;
   
//---- indicator calculation
   ArrayResize(e1,sBars+1);
   ArrayResize(e2,sBars+1);
   ArrayResize(e3,sBars+1);
   ArrayResize(e4,sBars+1);
   ArrayResize(e5,sBars+1);
   ArrayResize(e6,sBars+1);
   ArrayResize(UP,sBars+1);
   ArrayResize(UP2,sBars+1);

   for(int i=limit;i>=1;i--)
     {
      e1[sBars-i] = w1*Close[i] + w2*e1[(sBars-i)-1];
      e2[sBars-i] = w1*e1[sBars-i] + w2*e2[(sBars-i)-1];
      e3[sBars-i] = w1*e2[sBars-i] + w2*e3[(sBars-i)-1];
      e4[sBars-i] = w1*e3[sBars-i] + w2*e4[(sBars-i)-1];
      e5[sBars-i] = w1*e4[sBars-i] + w2*e5[(sBars-i)-1];
      e6[sBars-i] = w1*e5[sBars-i] + w2*e6[(sBars-i)-1];
      //Print ("I- ",i, "Bars-I ",Bars-i);
      MapBuffer=c1*e6[sBars-i]+c2*e5[sBars-i]+c3*e4[sBars-i]+c4*e3[sBars-i];

      //Comment (MapBuffer,"   ",Close[i],"   ",UP[i]);
      //if ((Close[i]-5*Point)>MapBuffer && UP[UU]==0) {}

      //if ((Close[i]+5*Point)<MapBuffer && UP[UU]==1) {}

      if((Close[i]-5*Point)>MapBuffer && UP[UU]==0)
        {
         UU=i+1; UP[UU]=1;
         //   {UP[ii]=1; DOWN[i]=0;} 
         //   DOWN[i]=0;
         /*if((Year()>eyear) || (Year()==eyear && Month()>emonth) || (Year()==eyear && Month()==emonth && Day()>eday))
           {
            //d
            if(ObjectFind("d label")!=0)
              {
               ObjectCreate("d label",OBJ_LABEL,0,0,0);
               ObjectSetText("d label","the indicator has expired , contact us by E-mail",TextSize,"Arial",TextColor4);
               ObjectSet("d label",OBJPROP_XDISTANCE,250);
               ObjectSet("d label",OBJPROP_YDISTANCE,75);
              }
            return(0);
           }
         else
         if(ObjectFind("d label")!=0)
           {
            ObjectCreate("d label",OBJ_LABEL,0,0,0);
            ObjectSetText("d label","the indicator well expire after ( "+eday+"-"+emonth+"-"+eyear+" )",TextSize,"Arial",TextColor4);
            ObjectSet("d label",OBJPROP_XDISTANCE,265);
            ObjectSet("d label",OBJPROP_YDISTANCE,75);
           }
*/
         CrossUp[i]=Low[i]-5*Point;
         AllSignal++;
         SignalUP++;
         if(iClose(Symbol(),NULL,i-1)>iOpen(Symbol(),NULL,i-1))
            GSignalUP++;
         else BSignalUP++;
        }

      else if((Close[i]+5*Point)<MapBuffer && UP[UU]==1)

      //else if (Result1+Result2+Result3+MA_Result+RSI_Result+L_C_A_S_Result<=-2) 

        {
         UU=i+1; UP[UU]=0;
         //    DOWN[i]=1;
       /*  if((Year()>eyear) || (Year()==eyear && Month()>emonth) || (Year()==eyear && Month()==emonth && Day()>eday))
           {
            //d
            if(ObjectFind("d label")!=0)
              {
               ObjectCreate("d label",OBJ_LABEL,0,0,0);
               ObjectSetText("d label","the indicator has expired , contact us by E-mail",TextSize,"Arial",TextColor4);
               ObjectSet("d label",OBJPROP_XDISTANCE,250);
               ObjectSet("d label",OBJPROP_YDISTANCE,75);
              }
            return(0);
           }
         else
         if(ObjectFind("d label")!=0)
           {
            ObjectCreate("d label",OBJ_LABEL,0,0,0);
            ObjectSetText("d label","the indicator well expire after ( "+eday+"-"+emonth+"-"+eyear+" )",TextSize,"Arial",TextColor4);
            ObjectSet("d label",OBJPROP_XDISTANCE,265);
            ObjectSet("d label",OBJPROP_YDISTANCE,75);
           }
*/
         CrossDown[i]=High[i]+5*Point;
         AllSignal++;
         SignalDOWN++;
         if(iClose(Symbol(),NULL,i-1)<iOpen(Symbol(),NULL,i-1))
            GSignalDOWN++;
         else BSignalDOWN++;
        }
     }
   int j=1;
   i=1;
   int date4=TimeMinute(Time[j]);
   int date5=TimeDay(Time[j]);

//Comment(UP2[2]);

   if((Close[i]-5*Point)>MapBuffer && UP2[2]==0 && alert==true && date3!=Time[j] && Seconds()<second)
     {date3=Time[j]; UP2[2]=1; Alert(Name," Close Sell Orders And Buy  ",Symbol()," AT ",iClose(Symbol(),0,i)); PlaySound(file); }

   if((Close[i]+5*Point)<MapBuffer && UP2[2]==1 && alert==true && date3!=Time[j] && Seconds()<second)

     {date3=Time[j]; UP2[2]=0; Alert(Name," Close Buy Orders And Sell  ",Symbol()," AT ",iClose(Symbol(),0,i)); PlaySound(file); }

   GSignals=GSignalUP+GSignalDOWN;
   
   if (AllSignal!=0) GSignalsP=GSignals/AllSignal;
   
   if (SignalUP!=0) GSignalUPP=(GSignalUP/SignalUP);
   if (SignalDOWN!=0) GSignalDOWNP=(GSignalDOWN/SignalDOWN);

   int www=GSignalsP*100;

//  if(ObjectFind("e label") != 0)
//{
//    ObjectCreate("e label", OBJ_LABEL, 0,0,0);
//  ObjectSetText("e label","%"+ "äÓÈÉ äÌÇÍ ÇáãÄÔÑ ="+ www  , TextSize, "Arial", TextColor5);
//  ObjectSet("e label", OBJPROP_XDISTANCE,340);
// ObjectSet("e label", OBJPROP_YDISTANCE,100);
// }

   return(0);
  }
//+------------------------------------------------------------------+
