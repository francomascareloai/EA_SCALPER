#property copyright "DOWNLOADMQ4.COM "
#property link      "https://downloadmq4.com/"
//----
#property strict
#property description "PricePosition indicator provide the position of price in the point of angle"
#property description "when the price was rise or down, where the chance to buy or sell."
#property indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1  clrLime
#property  indicator_width1  2
//---
enum YN
 {
   Yes = 1,
    No = 0
 };
//--
enum corner
 {  
   RightHand=1,
   LeftHand=0
 };
//---
input corner cor        = RightHand;    // Corner Position
input YN     UseAlert   = Yes;          // Turn On Alert (Yes) or (No)
input color  BuyColor   = clrLime;      // BUY Color
input color  SellColor  = clrOrangeRed; // SELL Color
input color  clrNT      = clrYellow;    // No Trend Color
//--
//--- buffers
double angle[],
       signal[],
       media1[],
       media2[];
//--
string day[]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
//--
//--
int xdis=0,
    ydis=135;
//--
color clrfont;
//--
int cal,
    pal,
    prc,
    pdn;
//-----//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectCreate("textir",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textir",OBJPROP_CORNER,1);
   ObjectSet("textir",OBJPROP_XDISTANCE,50);
   ObjectSet("textir",OBJPROP_YDISTANCE,40);
   ObjectSetText("textir","DOWNLOADMQ4.COM",10,"Times New Roman",Gold);
   ObjectCreate("textiNr",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textiNr",OBJPROP_CORNER,1);
   ObjectSet("textiNr",OBJPROP_XDISTANCE,50);
   ObjectSet("textiNr",OBJPROP_YDISTANCE,58);
   ObjectSetText("textiNr","FREE FOREX LIBRARY",10,"Times New Roman",Gold);
   ObjectCreate("textiKr",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textiKr",OBJPROP_CORNER,1);
   ObjectSet("textiKr",OBJPROP_XDISTANCE,54);
   ObjectSet("textiKr",OBJPROP_YDISTANCE,72);
   ObjectSetText("textiKr","https://t.me/downloadmq4",10,"Times New Roman",Gold); 
   //---
//--- indicator buffers mapping
    IndicatorBuffers(4);
    //--
    SetIndexBuffer(0,angle);
    SetIndexBuffer(1,signal);
    SetIndexBuffer(2,media1);
    SetIndexBuffer(3,media2);
    //--
    SetIndexStyle(0,DRAW_SECTION,STYLE_SOLID);
    SetIndexStyle(1,DRAW_NONE);
    SetIndexStyle(2,DRAW_NONE);
    SetIndexStyle(3,DRAW_NONE);
    //--
    SetIndexLabel(0,"Turn");
    SetIndexLabel(1,NULL);
    SetIndexLabel(2,NULL);
    SetIndexLabel(3,NULL);
    //--
    IndicatorShortName("PricePosition");
    IndicatorDigits(_Digits);
    //--
    xdis=cor==1 ? 133 : 30;
    //---
//---
   return(INIT_SUCCEEDED);
  }
//-----//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll();
   GlobalVariablesDeleteAll();
//----
   return;
  }
//---
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
   int i,limit;
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) {limit++;}
   //--
   ArraySetAsSeries(angle,true);
   ArraySetAsSeries(signal,true);
   ArraySetAsSeries(media1,true);
   ArraySetAsSeries(media2,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   //--
   for(i=limit-1; i>=0; i--)
     {
       media1[i]=iMA(_Symbol,0,26,0,2,4,i);
       media2[i]=iMA(_Symbol,0,20,0,0,4,i);
       signal[i]=(media1[i]+media2[i])/2;
     }
   //--
   for(i=limit-1; i>=0; i--)
     {
       if((open[i]<=signal[i])&&(close[i]>=signal[i])) angle[i]=low[i];
       else if((open[i]>=signal[i])&&(close[i]<=signal[i])) angle[i]=high[i];
       else angle[i]=EMPTY_VALUE;
     }
   //--
   double priceturn=0.0;  
   int seek=0;
   int s=0;
   //--
   while(seek<1)
     {
       if(angle[s]!=EMPTY_VALUE)
         {
           priceturn=angle[s];
           seek++;
         }
       s++;
     }
   //--
   //---
   //--- Create indicator section angles
   if(close[0]>priceturn)
     { 
      CreateLabel(0,"AngleDirection","BUY","Verdana",28,BuyColor,cor,xdis,ydis);
      CreateLabel(0,"AngleLevel","above "+DoubleToString(priceturn,_Digits),"Verdana",10,BuyColor,cor,xdis,ydis+45);
      //--
      clrfont=BuyColor;
      cal=1;
      if((cal!=pal)&&(UseAlert==1))
        {Alert("*"+WindowExpertName()+": "+_Symbol+", TF: ",strTF(_Period)+", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+
         " --- BUY above --- ",DoubleToString(priceturn,_Digits)); pal=cal;}
     }
   else if(close[0]<priceturn)
     {
      CreateLabel(0,"AngleDirection","SELL","Verdana",28,SellColor,cor,xdis,ydis);
      CreateLabel(0,"AngleLevel","below "+DoubleToString(priceturn,_Digits),"Verdana",10,SellColor,cor,xdis,ydis+45);
      //--
      clrfont=SellColor;
      cal=-1;
      if((cal!=pal)&&(UseAlert==1))
        {Alert("*"+WindowExpertName()+": "+_Symbol+", TF: ",strTF(_Period)+", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+
         " --- SELL below --- ",DoubleToString(priceturn,_Digits)); pal=cal;}
     }
   //--
   //---
   //-- create indicator price direction arrow
   string bararw="";
   color barclr=0;
   if(close[0]>open[0]) {bararw=CharToStr(241); barclr=BuyColor;}
   else if(close[0]<open[0]) {bararw=CharToStr(242); barclr=SellColor;}
   else {bararw=CharToStr(91); barclr=clrNT;}
   //--
   if(close[0]>open[0]) 
     {
       prc=1;
       if((prc!=pdn)&&(UseAlert==1))
        {Alert("*"+WindowExpertName()+": "+_Symbol+", TF: ",strTF(_Period)+", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+
         " --- Rising --- "); pdn=prc;}
     }
   else if(close[0]<open[0]) 
     {
       prc=-1;
       if((prc!=pdn)&&(UseAlert==1))
        {Alert("*"+WindowExpertName()+": "+_Symbol+", TF: ",strTF(_Period)+", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+
         " --- Down --- "); pdn=prc;}
     }
   else 
     {
       prc=0;
       if((prc!=pdn)&&(UseAlert==1))
        {Alert("*"+WindowExpertName()+": "+_Symbol+", TF: ",strTF(_Period)+", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+
         " --- Wait --- "); pdn=prc;}
     }
   //--
   int da=cor==1 ? -78 : 78;
   int aj=cor==1 ? -2 : 2;
   //--
   CreateLabel(0,"DIRARROW",bararw,"Wingdings",25,barclr,cor,xdis+da,ydis-45);
   //---
   //--- create indicator OHLC price
   CreateLabel(0,"OPEN","O: "+DoubleToString(open[0],_Digits),"Verdana",10,barclr,cor,xdis,ydis-57);
   
   CreateLabel(0,"HIGH","H: "+DoubleToString(high[0],_Digits),"Verdana",10,barclr,cor,xdis,ydis-44);
   //--
   CreateLabel(0,"LOW","L: "+DoubleToString(low[0],_Digits),"Verdana",10,barclr,cor,xdis+aj,ydis-31);
   //--
   CreateLabel(0,"CLOSE","C: "+DoubleToString(close[0],_Digits),"Verdana",10,barclr,cor,xdis,ydis-18);
   //--
   //--- create indicator labels time
   RefreshRates();
   //--
   CreateLabel(0,"txDay",day[DayOfWeek()],"Verdana",14,clrNT,cor,xdis,ydis+65);
   //--
   CreateLabel(0,"txTime",TimeToStr(TimeCurrent(),TIME_SECONDS),"Verdana",14,clrNT,cor,xdis,ydis+87);
   //--
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

void CreateLabel(long   chart_id, 
                 string lable_name, 
                 string label_text,
                 string font_model,
                 int    font_size,
                 color  label_color,
                 int    chart_corner,
                 int    x_cor, 
                 int    y_cor) 
  { 
//--- 
   if(ObjectFind(chart_id,lable_name)<0)
     {
       if(ObjectCreate(chart_id,lable_name,OBJ_LABEL,0,0,0,0,0)) 
         { 
           ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
           ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
           ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
         } 
       else 
          {Print("Failed to create the object OBJ_LABEL ",lable_name,", Error code = ", GetLastError());}
     }
   else
     {
       ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
     }
  }
//---------//

string strTF(int period)
  {
   string periodcur;
   switch(period)
     {
       //--
       case PERIOD_M1: periodcur="M1"; break;
       case PERIOD_M5: periodcur="M5"; break;
       case PERIOD_M15: periodcur="M15"; break;
       case PERIOD_M30: periodcur="M30"; break;
       case PERIOD_H1: periodcur="H1"; break;
       case PERIOD_H4: periodcur="H4"; break;
       case PERIOD_D1: periodcur="D1"; break;
       case PERIOD_W1: periodcur="W1"; break;
       case PERIOD_MN1: periodcur="MN"; break;
       //--
     }
   //--
   return(periodcur);
  }  
//---------//
//---/
//+------------------------------------------------------------------+
