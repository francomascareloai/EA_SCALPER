
#property copyright "GVC"
#property link      "http://www.metaquotes.net"
#property version   "1.00"
#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

#define BullColor Lime
#define BearColor Red

input string   info           = "Add your Prefix or Suffix to Pairs";
input string   Pairs          = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY" ;

input int    Magic_Number     = 2346;
input double lot              = 0.01;
input int  Basket_Target      = 0; 
input int  Basket_StopLoss    = 0; 
input int   x_axis            =10;
input int   y_axis            =50;



string button_close_basket_All = "btn_Close ALL"; 
string button_close_basket_Prof = "btn_Close Prof";
string button_close_basket_Loss = "btn_Close Loss";; 
string button_buy_basket_1 = "btn_buy_basket";  
string button_sell_basket_1 = "btn_sell_basket";
string button_close_basket_1 = "btn_Close Order";
string button_buy_basket_2 = "btn_buy_basket2";  
string button_sell_basket_2 = "btn_sell_basket2";
string button_close_basket_2 = "btn_Close Order2";
string button_buy_basket_3 = "btn_buy_basket3";  
string button_sell_basket_3 = "btn_sell_basket3";
string button_close_basket_3 = "btn_Close Order3";
string button_buy_basket_4 = "btn_buy_basket4";  
string button_sell_basket_4 = "btn_sell_basket4";
string button_close_basket_4 = "btn_Close Order4";
string button_buy_basket_5 = "btn_buy_basket5";  
string button_sell_basket_5 = "btn_sell_basket5";
string button_close_basket_5 = "btn_Close Order5";
string button_buy_basket_6 = "btn_buy_basket6";  
string button_sell_basket_6 = "btn_sell_basket6";
string button_close_basket_6 = "btn_Close Order6";
string button_buy_basket_7 = "btn_buy_basket7";  
string button_sell_basket_7 = "btn_sell_basket7";
string button_close_basket_7 = "btn_Close Order7";
string button_buy_basket_8 = "btn_buy_basket8";  
string button_sell_basket_8 = "btn_sell_basket8";
string button_close_basket_8 = "btn_Close Order8";
string button_buy_basket_9 = "btn_buy_basket9";  
string button_sell_basket_9 = "btn_sell_basket9";
string button_close_basket_9 = "btn_Close Order9";
string button_buy_basket_10 = "btn_buy_basket10";  
string button_sell_basket_10 = "btn_sell_basket10";
string button_close_basket_10 = "btn_Close Order10";
string button_buy_basket_11 = "btn_buy_basket11";  
string button_sell_basket_11 = "btn_sell_basket11";
string button_close_basket_11 = "btn_Close Order11";
string button_buy_basket_12 = "btn_buy_basket12";  
string button_sell_basket_12 = "btn_sell_basket12";
string button_close_basket_12 = "btn_Close Order12";
string button_buy_basket_13 = "btn_buy_basket13";  
string button_sell_basket_13 = "btn_sell_basket13";
string button_close_basket_13 = "btn_Close Order13";
string button_buy_basket_14 = "btn_buy_basket14";  
string button_sell_basket_14 = "btn_sell_basket14";
string button_close_basket_14 = "btn_Close Order14";
string button_buy_basket_15 = "btn_buy_basket15";  
string button_sell_basket_15 = "btn_sell_basket15";
string button_close_basket_15 = "btn_Close Order15";
string button_buy_basket_16 = "btn_buy_basket16";  
string button_sell_basket_16 = "btn_sell_basket16";
string button_close_basket_16 = "btn_Close Order16";
string button_buy_basket_17 = "btn_buy_basket17";  
string button_sell_basket_17 = "btn_sell_basket17";
string button_close_basket_17 = "btn_Close Order17";
string button_buy_basket_18 = "btn_buy_basket18";  
string button_sell_basket_18 = "btn_sell_basket18";
string button_close_basket_18 = "btn_Close Order18";
string button_buy_basket_19 = "btn_buy_basket19";  
string button_sell_basket_19 = "btn_sell_basket19";
string button_close_basket_19 = "btn_Close Order19";
string button_buy_basket_20 = "btn_buy_basket20";  
string button_sell_basket_20 = "btn_sell_basket20";
string button_close_basket_20 = "btn_Close Order20";
string button_buy_basket_21 = "btn_buy_basket21";  
string button_sell_basket_21 = "btn_sell_basket21";
string button_close_basket_21 = "btn_Close Order21";
string button_buy_basket_22 = "btn_buy_basket22";  
string button_sell_basket_22 = "btn_sell_basket22";
string button_close_basket_22 = "btn_Close Order22";
string button_buy_basket_23 = "btn_buy_basket23";  
string button_sell_basket_23 = "btn_sell_basket23";
string button_close_basket_23 = "btn_Close Order23";
string button_buy_basket_24 = "btn_buy_basket24";  
string button_sell_basket_24 = "btn_sell_basket24";
string button_close_basket_24 = "btn_Close Order24";
string button_buy_basket_25 = "btn_buy_basket25";  
string button_sell_basket_25 = "btn_sell_basket25";
string button_close_basket_25 = "btn_Close Order25";
string button_buy_basket_26 = "btn_buy_basket26";  
string button_sell_basket_26 = "btn_sell_basket26";
string button_close_basket_26 = "btn_Close Order26";
string button_buy_basket_27 = "btn_buy_basket27";  
string button_sell_basket_27 = "btn_sell_basket27";
string button_close_basket_27 = "btn_Close Order27";
string button_buy_basket_28 = "btn_buy_basket28";  
string button_sell_basket_28 = "btn_sell_basket28";
string button_close_basket_28 = "btn_Close Order28";
 
string   _font="Consolas";
double PairPip;
double Pips[28],Spread[28],Signalm1[28],Signalm5[28],Signalm15[28],Signalm30[28],Signalh1[28],Signalh4[28],Signald1[28],
       Signalw1[28],Signalmn[28],Signalhah4[28],Signalhad1[28],Signalhaw1[28],Signalusd[28];
color ProfitColor,ProfitColor1,ProfitColor2,ProfitColor3,PipsColor,Color,Color1,Color2,Color3,Color4,Color5,Color6,Color7,Color8,Color9,Color10,
      Color11,LotColor,LotColor1,OrdColor,OrdColor1;
color BackGrnCol =clrDarkGray;
color LineColor=clrBlack;
color TextColor=clrBlack;
double adr1[28],adr5[28],adr10[28],adr20[28],adr[28];
int ticket,pipsfactor;
int    orders  = 0;
double blots[28],slots[28],bprofit[28],sprofit[28],tprofit[28],bpos[28],spos[28];
bool CloseAll;
string TradePair[];
string suffix="";
string prefix="";
string      sep=","; 
ushort  u_sep=StringGetCharacter(sep,0);
int   symb_cnt=0;
int period1[]= {240,1440,10080};
double factor;
int labelcolor,labelcolor1,labelcolor2=clrNONE,labelcolor3,labelcolor4,labelcolor5,labelcolor6,labelcolor7,
    labelcolor8,labelcolor9,labelcolor10,labelcolor11;  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
  
   
//--- indicator buffers mapping
   EventSetTimer(1);
//---
   return(INIT_SUCCEEDED);
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
//--------------------------------------------------------------------------------------------



//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
    symb_cnt=StringSplit(Pairs,u_sep,TradePair);
    
    for(int i=0;i<ArraySize(TradePair);i++){
   if(iClose(TradePair[i],0,0) > 0) {      
   for(int e=0;e<ArraySize(period1);e++)
   
     {
      TradePair[i] = StringConcatenate(suffix,TradePair[i],suffix);
      if(Point==0.0001 || Point==0.01) 
        {
         PairPip=MarketInfo(TradePair[i] ,MODE_POINT);
         pipsfactor=1;
           } else if(Point==0.00001 || Point==0.001) {
         PairPip=MarketInfo(TradePair[i] ,MODE_POINT)*10;
         pipsfactor=10;
        }
     
      if(MarketInfo(TradePair[i],MODE_POINT) != 0 && pipsfactor != 0) {
       Pips[i]=(iClose(TradePair[i],PERIOD_D1,0)-iOpen(TradePair[i], PERIOD_D1,0))/MarketInfo(TradePair[i],MODE_POINT)/pipsfactor;     
       Spread[i]=MarketInfo(TradePair[i],MODE_SPREAD)/pipsfactor; 
      }  
      double Openm1    = iOpen(TradePair[i], PERIOD_M1,0);
      double Closem1   = iClose(TradePair[i],PERIOD_M1,0);
      double Openm5    = iOpen(TradePair[i], PERIOD_M5,0);
      double Closem5   = iClose(TradePair[i],PERIOD_M5,0);
      double Openm15   = iOpen(TradePair[i], PERIOD_M15,0);
      double Closem15  = iClose(TradePair[i],PERIOD_M15,0);
      double Openm30   = iOpen(TradePair[i], PERIOD_M30,0);
      double Closem30  = iClose(TradePair[i],PERIOD_M30,0);
      double Openh1    = iOpen(TradePair[i], PERIOD_H1,0);
      double Closeh1   = iClose(TradePair[i],PERIOD_H1,0);      
      double Openh4     = iOpen(TradePair[i], PERIOD_H4,0);
      double Closeh4    = iClose(TradePair[i],PERIOD_H4,0);
      double Opend     = iOpen(TradePair[i], PERIOD_D1,0);
      double Closed    = iClose(TradePair[i],PERIOD_D1,0);
      double Openw     = iOpen(TradePair[i], PERIOD_W1,0);
      double Closew    = iClose(TradePair[i],PERIOD_W1,0);
      double Openmn    = iOpen(TradePair[i], PERIOD_MN1,0);
      double Closemn   = iClose(TradePair[i],PERIOD_MN1,0);

      
      if(Closem1>Openm1)Signalm1[i]=1;
      if(Closem1<Openm1)Signalm1[i]=-1;
      if(Closem5>Openm5)Signalm5[i]=1;
      if(Closem5<Openm5)Signalm5[i]=-1;
      if(Closem15>Openm15)Signalm15[i]=1;
      if(Closem15<Openm15)Signalm15[i]=-1;
      if(Closem30>Openm30)Signalm30[i]=1;
      if(Closem30<Openm30)Signalm30[i]=-1;
      if(Closeh1>Openh1)Signalh1[i]=1;
      if(Closeh1<Openh1)Signalh1[i]=-1;
      if(Closeh4>Openh4)Signalh4[i]=1;
      if(Closeh4<Openh4)Signalh4[i]=-1;
      if(Closed>Opend)Signald1[i]=1;
      if(Closed<Opend)Signald1[i]=-1;
      if(Closew>Openw)Signalw1[i]=1;
      if(Closew<Openw)Signalw1[i]=-1;
      if(Closemn>Openmn)Signalmn[i]=1;
      if(Closemn<Openmn)Signalmn[i]=-1;


      double s=0.0;
      int n=1;     
      for(int a=1;a<=20;a++)
        {
         if(PairPip != 0) s=s+(iHigh(TradePair[i],PERIOD_D1,n)-iLow(TradePair[i],PERIOD_D1,n))/PairPip;
         if(a==1) adr1[i]=MathRound(s);
         if(a==5) adr5[i]=MathRound(s/5);
         if(a==10) adr10[i]=MathRound(s/10);
         if(a==20) adr20[i]=MathRound(s/20);
         n++; 
        }
      adr[i]=MathRound((adr1[i]+adr5[i]+adr10[i]+adr20[i])/4.0);

      
      double BB1=iMA(TradePair[i],PERIOD_H4,12,0,MODE_SMA,PRICE_CLOSE,0);      
      double BB10 = iMA(TradePair[i], PERIOD_D1,12,0,MODE_SMA,PRICE_CLOSE,0);       
      
      if(Closeh4>BB1 )Signalhah4[i]=1;
      if(Closeh4<BB1 )Signalhah4[i]=-1;
      if(Closed>BB10 )Signalhad1[i]=1;
      if(Closed<BB10 )Signalhad1[i]=-1;
     
     
     double high   = iHigh(TradePair[i],period1[e],0);
     double low    = iLow(TradePair[i],period1[e],0);
     double close  = iClose(TradePair[i],period1[e],0);
     double open   = iOpen(TradePair[i],period1[e],0);
      
     if (StringFind(TradePair[i],"JPY",0)!=-1) factor=10;
      else factor=1000;
      
      
       if(close != 0)Signalusd[i] = ((high-open)-(open-low)-(high-close)-(low-close)/(high+low)*(high+low))*factor;
                                     
       if (Signalusd[i]>100)Signalusd[i]=100;
      
     }
    }
   }  
    if(CloseAll)
      {
         close_basket(Magic_Number);
         if(OrdersTotal()==0)
         {
            
            CloseAll=false;
         }
      }
      //- Target
      if(Basket_Target>0 && TotalProfit()>=Basket_Target) CloseAll=true;

      //- StopLoss
      if(Basket_StopLoss>0 && TotalProfit()<(0-Basket_StopLoss)) CloseAll=true; 
      
    Trades();
   TotalProfit();  
  
   for(int i=0;i<ArraySize(TradePair);i++)  
        {
       ObjectDelete("Pips"+IntegerToString(i)); ObjectDelete("TtlProf"+IntegerToString(i));ObjectDelete("bLots"+IntegerToString(i));        
       ObjectDelete("sLots"+IntegerToString(i));ObjectDelete("bPos"+IntegerToString(i));ObjectDelete("sPos"+IntegerToString(i));
       ObjectDelete("TProf"+IntegerToString(i));ObjectDelete("SProf"+IntegerToString(i));ObjectDelete("Sig"+IntegerToString(i));
       ObjectDelete("SGD"+IntegerToString(i));ObjectDelete("M1sig"+IntegerToString(i));ObjectDelete("M5sig"+IntegerToString(i));   
       ObjectDelete("M15sig"+IntegerToString(i));ObjectDelete("M30sig"+IntegerToString(i));ObjectDelete("H1sig"+IntegerToString(i));
       ObjectDelete("H4sig"+IntegerToString(i));ObjectDelete("D1sig"+IntegerToString(i));ObjectDelete("W1sig"+IntegerToString(i));
       ObjectDelete("Mnsig"+IntegerToString(i)); ObjectDelete("TotProf");
       
         if(blots[i]>0){LotColor =Orange;}        
         if(blots[i]==0){LotColor =clrWhite;}
         if(slots[i]>0){LotColor1 =Orange;}        
         if(slots[i]==0){LotColor1 =clrWhite;}
         if(bpos[i]>0){OrdColor =DodgerBlue;}        
         if(bpos[i]==0){OrdColor =clrWhite;}
         if(spos[i]>0){OrdColor1 =DodgerBlue;}        
         if(spos[i]==0){OrdColor1 =clrWhite;}
         if(bprofit[i]>0){ProfitColor =BullColor;}
         if(bprofit[i]<0){ProfitColor =BearColor;}
         if(bprofit[i]==0){ProfitColor =clrWhite;}
         if(sprofit[i]>0){ProfitColor2 =BullColor;}
         if(sprofit[i]<0){ProfitColor2 =BearColor;}
         if(sprofit[i]==0){ProfitColor2 =clrWhite;}
         if(tprofit[i]>0){ProfitColor3 =BullColor;}
         if(tprofit[i]<0){ProfitColor3 =BearColor;}
         if(tprofit[i]==0){ProfitColor3 =clrWhite;}
         if(TotalProfit()>0){ProfitColor1 =BullColor;}
         if(TotalProfit()<0){ProfitColor1 =BearColor;}
         if(TotalProfit()==0){ProfitColor1 =clrWhite;}         
         if(Pips[i]>0){PipsColor =BullColor;}
         if(Pips[i]<0){PipsColor =BearColor;} 
         if(Pips[i]==0){PipsColor =clrWhite;}       
         if(Signalm1[i]==1){Color=BullColor;}
         if(Signalm1[i]==-1){Color=BearColor;}
         if(Signalm5[i]==1){Color1=BullColor;}         
         if(Signalm5[i]==-1){Color1 =BearColor;}
         if(Signalm15[i]==1){Color2 =BullColor;}
         if(Signalm15[i]==-1){Color2=BearColor;}
         if(Signalm30[i]==1){Color3=BullColor;}
         if(Signalm30[i]==-1){Color3=BearColor;}
         if(Signalh1[i]==1){Color4=BullColor;}
         if(Signalh1[i]==-1){Color4=BearColor;}
         if(Signalh4[i]==1){Color5=BullColor;}
         if(Signalh4[i]==-1){Color5=BearColor;}
         if(Signald1[i]==1){Color6=BullColor;}
         if(Signald1[i]==-1){Color6=BearColor;}
         if(Signalw1[i]==1){Color7=BullColor;}
         if(Signalw1[i]==-1){Color7=BearColor;}
         if(Signalmn[i]==1){Color8=BullColor;}
         if(Signalmn[i]==-1){Color8=BearColor;}
         if(Signalusd[i]>0){Color9=BullColor;}
         if(Signalusd[i]<0){Color9=BearColor;}
         
        if(Signalusd[i]>0.0)labelcolor1=clrDodgerBlue;     
    else if(Signalusd[i]<0.0)labelcolor1=clrOrangeRed;
         if(Signalusd[i]>10.0)labelcolor3=clrDodgerBlue;     
    else if(Signalusd[i]<-10.0)labelcolor3=clrOrangeRed;
         else labelcolor3=C'30,30,30'; 
         if(Signalusd[i]>20.0)labelcolor4=clrDodgerBlue;     
    else if(Signalusd[i]<-20.0)labelcolor4=clrOrangeRed;
         else labelcolor4=C'30,30,30'; 
         if(Signalusd[i]>30.0)labelcolor5=clrDodgerBlue;     
    else if(Signalusd[i]<-30.0)labelcolor5=clrOrangeRed;
         else labelcolor5=C'30,30,30'; 
         if(Signalusd[i]>40.0)labelcolor6=clrDodgerBlue;     
    else if(Signalusd[i]<-40.0)labelcolor6=clrOrangeRed;
         else labelcolor6=C'30,30,30'; 
         if(Signalusd[i]>50.0)labelcolor7=clrDodgerBlue;     
    else if(Signalusd[i]<-50.0)labelcolor7=clrOrangeRed;
         else labelcolor7=C'30,30,30'; 
         if(Signalusd[i]>60.0)labelcolor8=clrDodgerBlue;     
    else if(Signalusd[i]<-60.0)labelcolor8=clrOrangeRed;
         else labelcolor8=C'30,30,30'; 
         if(Signalusd[i]>70.0)labelcolor9=clrDodgerBlue;     
    else if(Signalusd[i]<-70.0)labelcolor9=clrOrangeRed;
         else labelcolor9=C'30,30,30'; 
         if(Signalusd[i]>80.0)labelcolor10=clrDodgerBlue;     
    else if(Signalusd[i]<-80.0)labelcolor10=clrOrangeRed;
         else labelcolor10=C'30,30,30'; 
         if(Signalusd[i]>90.0)labelcolor11=clrDodgerBlue;     
    else if(Signalusd[i]<-90.0)labelcolor11=clrOrangeRed;
         else labelcolor11=C'30,30,30';   
         
         if(Signalhah4[i]==1){SetObjText("Sig"+IntegerToString(i),CharToStr(233),x_axis+464,(i*16)+y_axis,BullColor,9);}
         if(Signalhah4[i]==-1){SetObjText("Sig"+IntegerToString(i),CharToStr(234),x_axis+464,(i*16)+y_axis+2,BearColor,9);}
         if(Signalhad1[i]==1){SetObjText("SGD"+IntegerToString(i),CharToStr(233),x_axis+494,(i*16)+y_axis,BullColor,9);}
         if(Signalhad1[i]==-1){SetObjText("SGD"+IntegerToString(i),CharToStr(234),x_axis+494,(i*16)+y_axis+2,BearColor,9);}
         
         if(OrdersTotal()==0){SetText("CTP","No Trades To Monitor",x_axis+250,y_axis-47,Yellow,8);}
         if(OrdersTotal()>0 ){SetText("CTP","Monitoring Trades",x_axis+253,y_axis-47,Yellow,8);}
         SetText("TPr","Basket TakeProfit =$ "+DoubleToStr(Basket_Target,0),x_axis+378,y_axis-47,Yellow,8);
         SetText("SL","Basket StopLoss =$ -"+DoubleToStr(Basket_StopLoss,0),x_axis+538,y_axis-47,Yellow,8);

         if (Pips[i]>0&&Signalm1[i]==1&&Signalm5[i]==1&&Signalm15[i]==1&&Signalm30[i]==1&&Signalh1[i]==1&&Signalh4[i]==1&&Signald1[i]==1&&Signalw1[i]==1&&Signalmn[i]==1&&Signalhah4[i]==1&&Signalhad1[i]==1)
            labelcolor = clrGreen;
         else if (Pips[i]<0&&Signalm1[i]==-1&&Signalm5[i]==-1&&Signalm15[i]==-1&&Signalm30[i]==-1&&Signalh1[i]==-1&&Signalh4[i]==-1&&Signald1[i]==-1&&Signalw1[i]==-1&&Signalmn[i]==-1&&Signalhah4[i]==-1&&Signalhad1[i]==-1)
               labelcolor = clrRed;
             else
               labelcolor = BackGrnCol;
         
         SetPanel("BP",0,x_axis-1,y_axis-3,1100,451,C'30,30,30',C'61,61,61',1);
         SetPanel("Bar",0,x_axis,y_axis-30,1100,27,Maroon,LineColor,1);        
         SetPanel("Panel"+IntegerToString(i),0,x_axis,(i*16)+y_axis,68,15,labelcolor,LineColor,1);         
         SetPanel("Spread"+IntegerToString(i),0,x_axis+70,(i*16)+y_axis-2,30,17,C'20,20,20',C'61,61,61',1);
         SetPanel("Pips"+IntegerToString(i),0,x_axis+101,(i*16)+y_axis-2,35,17,C'20,20,20',C'61,61,61',1);
         SetPanel("Adr"+IntegerToString(i),0,x_axis+137,(i*16)+y_axis-2,40,17,C'20,20,20',C'61,61,61',1);
         SetPanel("m1"+IntegerToString(i),0,x_axis+180,(i*16)+y_axis,25,15,Color,White,1);
         SetPanel("m5"+IntegerToString(i),0,x_axis+210,(i*16)+y_axis,25,15,Color1,White,1);
         SetPanel("m15"+IntegerToString(i),0,x_axis+240,(i*16)+y_axis,25,15,Color2,White,1);
         SetPanel("m30"+IntegerToString(i),0,x_axis+270,(i*16)+y_axis,25,15,Color3,White,1);
         SetPanel("h1"+IntegerToString(i),0,x_axis+300,(i*16)+y_axis,25,15,Color4,White,1);
         SetPanel("h4"+IntegerToString(i),0,x_axis+330,(i*16)+y_axis,25,15,Color5,White,1);
         SetPanel("d1"+IntegerToString(i),0,x_axis+360,(i*16)+y_axis,25,15,Color6,White,1);
         SetPanel("w1"+IntegerToString(i),0,x_axis+390,(i*16)+y_axis,25,15,Color7,White,1);
         SetPanel("mn1"+IntegerToString(i),0,x_axis+420,(i*16)+y_axis,25,15,Color8,White,1);
         SetPanel("ha4"+IntegerToString(i),0,x_axis+452,(i*16)+y_axis-2,30,17,C'20,20,20',C'61,61,61',1);
         SetPanel("had1"+IntegerToString(i),0,x_axis+485,(i*16)+y_axis-2,30,17,C'20,20,20',C'61,61,61',1);
         SetPanel("TP",0,x_axis+1040,y_axis-27,55,20,Black,White,1);
         SetPanel("TP1",0,x_axis+250,y_axis-50,125,20,Black,White,1);
         SetPanel("TP2",0,x_axis+375,y_axis-50,160,20,Black,White,1);
         SetPanel("TP3",0,x_axis+535,y_axis-50,160,20,Black,White,1);
         //SetPanel("TP4",0,x_axis+700,y_axis-50,160,20,Black,White,1);
         SetPanel("A1"+IntegerToString(i),0,x_axis+695,(i*16)+y_axis-3,36,19,C'30,30,30',C'61,61,61',1);
         SetPanel("A2"+IntegerToString(i),0,x_axis+731,(i*16)+y_axis-3,265,19,C'30,30,30',C'61,61,61',1);          
         SetPanel("A3"+IntegerToString(i),0,x_axis+834,(i*16)+y_axis-3,265,19,C'30,30,30',C'61,61,61',1);   
         SetPanel("B1"+IntegerToString(i),0,x_axis+730,(i*16)+y_axis-3,12,19,labelcolor1,labelcolor2,1);
         SetPanel("B2"+IntegerToString(i),0,x_axis+740,(i*16)+y_axis-3,12,19,labelcolor3,labelcolor2,1);
         SetPanel("B3"+IntegerToString(i),0,x_axis+750,(i*16)+y_axis-3,12,19,labelcolor4,labelcolor2,1);
         SetPanel("B4"+IntegerToString(i),0,x_axis+760,(i*16)+y_axis-3,12,19,labelcolor5,labelcolor2,1);
         SetPanel("B5"+IntegerToString(i),0,x_axis+770,(i*16)+y_axis-3,12,19,labelcolor6,labelcolor2,1);
         SetPanel("B6"+IntegerToString(i),0,x_axis+780,(i*16)+y_axis-3,12,19,labelcolor7,labelcolor2,1);
         SetPanel("B7"+IntegerToString(i),0,x_axis+790,(i*16)+y_axis-3,12,19,labelcolor8,labelcolor2,1);
         SetPanel("B8"+IntegerToString(i),0,x_axis+800,(i*16)+y_axis-3,12,19,labelcolor9,labelcolor2,1);
         SetPanel("B9"+IntegerToString(i),0,x_axis+810,(i*16)+y_axis-3,12,19,labelcolor10,labelcolor2,1);
         SetPanel("B10"+IntegerToString(i),0,x_axis+820,(i*16)+y_axis-3,15,19,labelcolor11,labelcolor2,1);

         SetText("Pair"+IntegerToString(i),TradePair[i],x_axis+2,(i*16)+y_axis+2,clrBlack,8);
         SetText("Pr1"+IntegerToString(i),TradePair[i],x_axis+780,(i*16)+y_axis,labelcolor,8);       
         SetText("Symbol","Symbol      Spread   Pips     ADR",x_axis+4,y_axis-25,White,8);
         SetText("Direct","Candle Direction",x_axis+270,y_axis-30,White,8);
         SetText("Trend","M1     M5     M15    M30    H1      H4     D1     W1     MN",x_axis+183,y_axis-17,White,8);
         SetText("Signal","Signal",x_axis+465,y_axis-30,White,8);
         SetText("MA","H4      D1",x_axis+462,y_axis-17,White,8);
         SetText("Trades","Buy       Sell     Buy  Sell      Buy      Sell",x_axis+840,y_axis-17,White,8);
         SetText("TTr","Lots           Orders",x_axis+860,y_axis-30,White,8);
         SetText("Tottrade","Profit",x_axis+980,y_axis-30,White,8);
         SetText("Spr1"+IntegerToString(i),DoubleToStr(Spread[i],1),x_axis+72,(i*16)+y_axis,Orange,8);
         SetText("Pp1"+IntegerToString(i),DoubleToStr(MathAbs(Pips[i]),0),x_axis+103,(i*16)+y_axis,PipsColor,8);
         SetText("S1"+IntegerToString(i),DoubleToStr(adr[i],0),x_axis+143,(i*16)+y_axis,Yellow,8);
         SetText("bLots"+IntegerToString(i),DoubleToStr(blots[i],2),x_axis+840,(i*16)+y_axis,LotColor,8);
         SetText("sLots"+IntegerToString(i),DoubleToStr(slots[i],2),x_axis+880,(i*16)+y_axis,LotColor1,8);
         SetText("bPos"+IntegerToString(i),DoubleToStr(bpos[i],0),x_axis+920,(i*16)+y_axis,OrdColor,8);
         SetText("sPos"+IntegerToString(i),DoubleToStr(spos[i],0),x_axis+940,(i*16)+y_axis,OrdColor1,8);
         SetText("TProf"+IntegerToString(i),DoubleToStr(MathAbs(bprofit[i]),2),x_axis+970,(i*16)+y_axis,ProfitColor,8);
         SetText("SProf"+IntegerToString(i),DoubleToStr(MathAbs(sprofit[i]),2),x_axis+1010,(i*16)+y_axis,ProfitColor2,8);
         SetText("TtlProf"+IntegerToString(i),DoubleToStr(MathAbs(tprofit[i]),2),x_axis+1060,(i*16)+y_axis,ProfitColor3,8);
         SetText("TotProf",DoubleToStr(MathAbs(TotalProfit()),2),x_axis+1043,y_axis-22,ProfitColor1,8);
         SetText("usdintsig"+IntegerToString(i),DoubleToStr(MathAbs( Signalusd[i]),0)+"%",x_axis+700,(i*16)+y_axis,Color9,8);
         
       Create_Button(button_close_basket_All,"CLOSE ALL",90 ,18,x_axis+530 ,y_axis-25,clrDarkGray,clrRed);
       Create_Button(button_close_basket_Prof,"CLOSE PROFIT",90 ,18,x_axis+630 ,y_axis-25,clrDarkGray,clrRed);
       Create_Button(button_close_basket_Loss,"CLOSE LOSS",90 ,18,x_axis+730 ,y_axis-25,clrDarkGray,clrRed);
       Create_Button(button_buy_basket_1,"BUY",50 ,15,x_axis+520,y_axis,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_1,"SELL",50 ,15,x_axis+580 ,y_axis,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_1,"CLOSE",50 ,15,x_axis+640 ,y_axis,clrRed,clrWhite);
       Create_Button(button_buy_basket_2,"BUY",50 ,15,x_axis+520,y_axis+16,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_2,"SELL",50 ,15,x_axis+580 ,y_axis+16,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_2,"CLOSE",50 ,15,x_axis+640 ,y_axis+16,clrRed,clrWhite);
       Create_Button(button_buy_basket_3,"BUY",50 ,15,x_axis+520,y_axis+32,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_3,"SELL",50 ,15,x_axis+580 ,y_axis+32,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_3,"CLOSE",50 ,15,x_axis+640 ,y_axis+32,clrRed,clrWhite);
       Create_Button(button_buy_basket_4,"BUY",50 ,15,x_axis+520,y_axis+48,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_4,"SELL",50 ,15,x_axis+580 ,y_axis+48,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_4,"CLOSE",50 ,15,x_axis+640 ,y_axis+48,clrRed,clrWhite);
       Create_Button(button_buy_basket_5,"BUY",50 ,15,x_axis+520,y_axis+64,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_5,"SELL",50 ,15,x_axis+580 ,y_axis+64,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_5,"CLOSE",50 ,15,x_axis+640 ,y_axis+64,clrRed,clrWhite);
       Create_Button(button_buy_basket_6,"BUY",50 ,15,x_axis+520,y_axis+80,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_6,"SELL",50 ,15,x_axis+580 ,y_axis+80,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_6,"CLOSE",50 ,15,x_axis+640 ,y_axis+80,clrRed,clrWhite);
       Create_Button(button_buy_basket_7,"BUY",50 ,15,x_axis+520,y_axis+96,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_7,"SELL",50 ,15,x_axis+580 ,y_axis+96,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_7,"CLOSE",50 ,15,x_axis+640 ,y_axis+96,clrRed,clrWhite);
       Create_Button(button_buy_basket_8,"BUY",50 ,15,x_axis+520,y_axis+112,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_8,"SELL",50 ,15,x_axis+580 ,y_axis+112,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_8,"CLOSE",50 ,15,x_axis+640 ,y_axis+112,clrRed,clrWhite);
       Create_Button(button_buy_basket_9,"BUY",50 ,15,x_axis+520,y_axis+128,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_9,"SELL",50 ,15,x_axis+580 ,y_axis+128,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_9,"CLOSE",50 ,15,x_axis+640 ,y_axis+128,clrRed,clrWhite);
       Create_Button(button_buy_basket_10,"BUY",50 ,15,x_axis+520,y_axis+144,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_10,"SELL",50 ,15,x_axis+580 ,y_axis+144,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_10,"CLOSE",50 ,15,x_axis+640 ,y_axis+144,clrRed,clrWhite);
       Create_Button(button_buy_basket_11,"BUY",50 ,15,x_axis+520,y_axis+160,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_11,"SELL",50 ,15,x_axis+580 ,y_axis+160,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_11,"CLOSE",50 ,15,x_axis+640 ,y_axis+160,clrRed,clrWhite);
       Create_Button(button_buy_basket_12,"BUY",50 ,15,x_axis+520,y_axis+176,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_12,"SELL",50 ,15,x_axis+580 ,y_axis+176,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_12,"CLOSE",50 ,15,x_axis+640 ,y_axis+176,clrRed,clrWhite);
       Create_Button(button_buy_basket_13,"BUY",50 ,15,x_axis+520,y_axis+192,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_13,"SELL",50 ,15,x_axis+580 ,y_axis+192,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_13,"CLOSE",50 ,15,x_axis+640 ,y_axis+192,clrRed,clrWhite);
       Create_Button(button_buy_basket_14,"BUY",50 ,15,x_axis+520,y_axis+208,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_14,"SELL",50 ,15,x_axis+580 ,y_axis+208,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_14,"CLOSE",50 ,15,x_axis+640 ,y_axis+208,clrRed,clrWhite);
       Create_Button(button_buy_basket_15,"BUY",50 ,15,x_axis+520,y_axis+224,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_15,"SELL",50 ,15,x_axis+580 ,y_axis+224,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_15,"CLOSE",50 ,15,x_axis+640 ,y_axis+224,clrRed,clrWhite);
       Create_Button(button_buy_basket_16,"BUY",50 ,15,x_axis+520,y_axis+240,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_16,"SELL",50 ,15,x_axis+580 ,y_axis+240,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_16,"CLOSE",50 ,15,x_axis+640 ,y_axis+240,clrRed,clrWhite);
       Create_Button(button_buy_basket_17,"BUY",50 ,15,x_axis+520,y_axis+256,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_17,"SELL",50 ,15,x_axis+580 ,y_axis+256,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_17,"CLOSE",50 ,15,x_axis+640 ,y_axis+256,clrRed,clrWhite);
       Create_Button(button_buy_basket_18,"BUY",50 ,15,x_axis+520,y_axis+272,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_18,"SELL",50 ,15,x_axis+580 ,y_axis+272,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_18,"CLOSE",50 ,15,x_axis+640 ,y_axis+272,clrRed,clrWhite);
       Create_Button(button_buy_basket_19,"BUY",50 ,15,x_axis+520,y_axis+288,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_19,"SELL",50 ,15,x_axis+580 ,y_axis+288,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_19,"CLOSE",50 ,15,x_axis+640 ,y_axis+288,clrRed,clrWhite);
       Create_Button(button_buy_basket_20,"BUY",50 ,15,x_axis+520,y_axis+304,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_20,"SELL",50 ,15,x_axis+580 ,y_axis+304,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_20,"CLOSE",50 ,15,x_axis+640 ,y_axis+304,clrRed,clrWhite);
       Create_Button(button_buy_basket_21,"BUY",50 ,15,x_axis+520,y_axis+320,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_21,"SELL",50 ,15,x_axis+580 ,y_axis+320,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_21,"CLOSE",50 ,15,x_axis+640 ,y_axis+320,clrRed,clrWhite);
       Create_Button(button_buy_basket_22,"BUY",50 ,15,x_axis+520,y_axis+336,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_22,"SELL",50 ,15,x_axis+580 ,y_axis+336,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_22,"CLOSE",50 ,15,x_axis+640 ,y_axis+336,clrRed,clrWhite);
       Create_Button(button_buy_basket_23,"BUY",50 ,15,x_axis+520,y_axis+352,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_23,"SELL",50 ,15,x_axis+580 ,y_axis+352,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_23,"CLOSE",50 ,15,x_axis+640 ,y_axis+352,clrRed,clrWhite);
       Create_Button(button_buy_basket_24,"BUY",50 ,15,x_axis+520,y_axis+368,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_24,"SELL",50 ,15,x_axis+580 ,y_axis+368,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_24,"CLOSE",50 ,15,x_axis+640 ,y_axis+368,clrRed,clrWhite);
       Create_Button(button_buy_basket_25,"BUY",50 ,15,x_axis+520,y_axis+384,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_25,"SELL",50 ,15,x_axis+580 ,y_axis+384,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_25,"CLOSE",50 ,15,x_axis+640 ,y_axis+384,clrRed,clrWhite);
       Create_Button(button_buy_basket_26,"BUY",50 ,15,x_axis+520,y_axis+400,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_26,"SELL",50 ,15,x_axis+580 ,y_axis+400,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_26,"CLOSE",50 ,15,x_axis+640 ,y_axis+400,clrRed,clrWhite);
       Create_Button(button_buy_basket_27,"BUY",50 ,15,x_axis+520,y_axis+416,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_27,"SELL",50 ,15,x_axis+580 ,y_axis+416,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_27,"CLOSE",50 ,15,x_axis+640 ,y_axis+416,clrRed,clrWhite);
        Create_Button(button_buy_basket_28,"BUY",50 ,15,x_axis+520,y_axis+432,clrRoyalBlue,clrWhite);           
       Create_Button(button_sell_basket_28,"SELL",50 ,15,x_axis+580 ,y_axis+432,clrGoldenrod,clrWhite);
       Create_Button(button_close_basket_28,"CLOSE",50 ,15,x_axis+640 ,y_axis+432,clrRed,clrWhite);  
        }
  }
  
//+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+

void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
     }
  ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
  ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+
void Create_Button(string but_name,string label,int xsize,int ysize,int xdist,int ydist,int bcolor,int fcolor)
{
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetString(0,but_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bcolor);
      ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      //ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,ChartGetInteger(0,CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      
      ChartRedraw();      
   }

}
void OnChartEvent(const int id,  const long &lparam, const double &dparam,  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
  ticket = OrderTicket();
  
      {
      if(sparam==button_close_basket_All)
        {
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Closing...");               
               close_basket(Magic_Number);
               ObjectSetInteger(0,button_close_basket_All,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_All);        
        }
//-----------------------------------------------------------------------------------------------------------------     
if(sparam==button_close_basket_Prof)
        {
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Closing...");               
               close_profit();
               ObjectSetInteger(0,button_close_basket_Prof,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_Prof);        
        }
//----------------------------------------------------------------------------------------------------------------- 
if(sparam==button_close_basket_Loss)
        {
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Closing...");               
               close_loss();
               ObjectSetInteger(0,button_close_basket_Loss,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_Loss);        
        }
//-----------------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_1)
        {
               ObjectSetString(0,button_buy_basket_1,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[0],OP_BUY,lot,MarketInfo(TradePair[0],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_1,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_1,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_1);        
        }
     if(sparam==button_sell_basket_1)
        {
               ObjectSetString(0,button_sell_basket_1,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[0],OP_SELL,lot,MarketInfo(TradePair[0],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_1,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_1,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_1);         
        }
     if(sparam==button_close_basket_1)
        {
               ObjectSetString(0,button_close_basket_1,OBJPROP_TEXT,"Closing...");               
               closeOpenOrders(TradePair[0]);               
               ObjectSetInteger(0,button_close_basket_1,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_1,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_1);         
        }
         
//----------------------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_2)
        {
               ObjectSetString(0,button_buy_basket_2,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[1],OP_BUY,lot,MarketInfo(TradePair[1],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_2,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_2,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_2);         
        }
     if(sparam==button_sell_basket_2)
        {
               ObjectSetString(0,button_sell_basket_2,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[1],OP_SELL,lot,MarketInfo(TradePair[1],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_2,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_2,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_2);         
        }
    if(sparam==button_close_basket_2)
        {
               ObjectSetString(0,button_close_basket_2,OBJPROP_TEXT,"Closing...");               
               closeOpenOrders(TradePair[1]);               
               ObjectSetInteger(0,button_close_basket_2,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_2,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_2);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_3)
        {
               ObjectSetString(0,button_buy_basket_3,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[2],OP_BUY,lot,MarketInfo(TradePair[2],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_3,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_3,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_3);        
        }
     if(sparam==button_sell_basket_3)
        {
               ObjectSetString(0,button_sell_basket_3,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[2],OP_SELL,lot,MarketInfo(TradePair[2],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_3,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_3,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_3);          
        }
    if(sparam==button_close_basket_3)
        {
               ObjectSetString(0,button_close_basket_3,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[2]);               
               ObjectSetInteger(0,button_close_basket_3,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_3,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_3);       
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_4)
        {
               ObjectSetString(0,button_buy_basket_4,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[3],OP_BUY,lot,MarketInfo(TradePair[3],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_4,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_4,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_4);         
        }
     if(sparam==button_sell_basket_4)
        {
               ObjectSetString(0,button_sell_basket_4,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[3],OP_SELL,lot,MarketInfo(TradePair[3],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_4,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_4,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_4);        
        }
    if(sparam==button_close_basket_4)
        {
               ObjectSetString(0,button_close_basket_4,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[3]);               
               ObjectSetInteger(0,button_close_basket_4,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_4,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_4);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_5)
        {
               ObjectSetString(0,button_buy_basket_5,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[4],OP_BUY,lot,MarketInfo(TradePair[4],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_5,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_5,OBJPROP_TEXT,"Buy Basket"); 
                ObjectDelete(button_buy_basket_5);       
        }
     if(sparam==button_sell_basket_5)
        {
               ObjectSetString(0,button_sell_basket_5,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[4],OP_SELL,lot,MarketInfo(TradePair[4],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_5,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_5,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_5);         
        }
    if(sparam==button_close_basket_5)
        {
               ObjectSetString(0,button_close_basket_5,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[4]);              
               ObjectSetInteger(0,button_close_basket_5,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_5,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_5);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_6)
        {
               ObjectSetString(0,button_buy_basket_6,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[5],OP_BUY,lot,MarketInfo(TradePair[5],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_6,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_6,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_6);         
        }
     if(sparam==button_sell_basket_6)
        {
               ObjectSetString(0,button_sell_basket_6,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[5],OP_SELL,lot,MarketInfo(TradePair[5],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_6,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_6,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_6);       
        }
    if(sparam==button_close_basket_6)
        {
               ObjectSetString(0,button_close_basket_6,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[5]);               
               ObjectSetInteger(0,button_close_basket_6,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_6,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_6);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_7)
        {
               ObjectSetString(0,button_buy_basket_7,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[6],OP_BUY,lot,MarketInfo(TradePair[6],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_7,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_7,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_7);        
        }
     if(sparam==button_sell_basket_7)
        {
               ObjectSetString(0,button_sell_basket_7,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[6],OP_SELL,lot,MarketInfo(TradePair[6],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_7,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_7,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_7);      
        }
    if(sparam==button_close_basket_7)
        {
               ObjectSetString(0,button_close_basket_7,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[6]);               
               ObjectSetInteger(0,button_close_basket_7,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_7,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_7);           
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_8)
        {
               ObjectSetString(0,button_buy_basket_8,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[7],OP_BUY,lot,MarketInfo(TradePair[7],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_8,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_8,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_8);        
        }
     if(sparam==button_sell_basket_8)
        {
               ObjectSetString(0,button_sell_basket_8,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[7],OP_SELL,lot,MarketInfo(TradePair[7],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_8,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_8,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_8);         
        }
    if(sparam==button_close_basket_8)
        {
               ObjectSetString(0,button_close_basket_8,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[7]);               
               ObjectSetInteger(0,button_close_basket_8,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_8,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_8);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_9)
        {
               ObjectSetString(0,button_buy_basket_9,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[8],OP_BUY,lot,MarketInfo(TradePair[8],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_9,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_9,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_9);      
        }
     if(sparam==button_sell_basket_9)
        {
               ObjectSetString(0,button_sell_basket_9,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[8],OP_SELL,lot,MarketInfo(TradePair[8],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_9,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_9,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_9);        
        }
    if(sparam==button_close_basket_9)
        {
               ObjectSetString(0,button_close_basket_9,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[8]);               
               ObjectSetInteger(0,button_close_basket_9,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_9,OBJPROP_TEXT,"Close Basket");  
               ObjectDelete(button_close_basket_9);        
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_10)
        {
               ObjectSetString(0,button_buy_basket_10,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[9],OP_BUY,lot,MarketInfo(TradePair[9],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_10,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_10,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_10);         
        }
     if(sparam==button_sell_basket_10)
        {
               ObjectSetString(0,button_sell_basket_10,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[9],OP_SELL,lot,MarketInfo(TradePair[9],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_10,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_10,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_10);         
        }
    if(sparam==button_close_basket_10)
        {
               ObjectSetString(0,button_close_basket_10,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[9]);            
               ObjectSetInteger(0,button_close_basket_10,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_10,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_10);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_11)
        {
               ObjectSetString(0,button_buy_basket_11,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[10],OP_BUY,lot,MarketInfo(TradePair[10],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_11,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_11,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_11);        
        }
     if(sparam==button_sell_basket_11)
        {
               ObjectSetString(0,button_sell_basket_11,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[10],OP_SELL,lot,MarketInfo(TradePair[10],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_11,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_11,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_11);        
        }
    if(sparam==button_close_basket_11)
        {
               ObjectSetString(0,button_close_basket_11,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[10]);              
               ObjectSetInteger(0,button_close_basket_11,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_11,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_11);          
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_12)
        {
               ObjectSetString(0,button_buy_basket_12,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[11],OP_BUY,lot,MarketInfo(TradePair[11],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_12,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_12,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_12);        
        }
     if(sparam==button_sell_basket_12)
        {
               ObjectSetString(0,button_sell_basket_12,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[11],OP_SELL,lot,MarketInfo(TradePair[11],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_12,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_12,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_12);          
        }
    if(sparam==button_close_basket_12)
        {
               ObjectSetString(0,button_close_basket_12,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[11]);               
               ObjectSetInteger(0,button_close_basket_12,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_12,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_12);        
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_13)
        {
               ObjectSetString(0,button_buy_basket_13,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[12],OP_BUY,lot,MarketInfo(TradePair[12],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_13,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_13,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_13);         
        }
     if(sparam==button_sell_basket_13)
        {
               ObjectSetString(0,button_sell_basket_13,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[12],OP_SELL,lot,MarketInfo(TradePair[12],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_13,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_13,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_13);         
        }
    if(sparam==button_close_basket_13)
        {
               ObjectSetString(0,button_close_basket_13,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[12]);               
               ObjectSetInteger(0,button_close_basket_13,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_13,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_13);        
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_14)
        {
               ObjectSetString(0,button_buy_basket_14,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[13],OP_BUY,lot,MarketInfo(TradePair[13],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_14,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_14,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_14);       
        }
     if(sparam==button_sell_basket_14)
        {
               ObjectSetString(0,button_sell_basket_14,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[13],OP_SELL,lot,MarketInfo(TradePair[13],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_14,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_14,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_14);        
        }
    if(sparam==button_close_basket_14)
        {
               ObjectSetString(0,button_close_basket_14,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[13]);              
               ObjectSetInteger(0,button_close_basket_14,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_14,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_14);          
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_15)
        {
               ObjectSetString(0,button_buy_basket_15,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[14],OP_BUY,lot,MarketInfo(TradePair[14],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_15,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_15,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_15);        
        }
     if(sparam==button_sell_basket_15)
        {
               ObjectSetString(0,button_sell_basket_15,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[14],OP_SELL,lot,MarketInfo(TradePair[14],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_15,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_15,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_15);        
        }
    if(sparam==button_close_basket_15)
        {
               ObjectSetString(0,button_close_basket_15,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[14]);               
               ObjectSetInteger(0,button_close_basket_15,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_15,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_15);          
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_16)
        {
               ObjectSetString(0,button_buy_basket_16,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[15],OP_BUY,lot,MarketInfo(TradePair[15],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_16,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_16,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_16);        
        }
     if(sparam==button_sell_basket_16)
        {
               ObjectSetString(0,button_sell_basket_16,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[15],OP_SELL,lot,MarketInfo(TradePair[15],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_16,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_16,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_16);          
        }
    if(sparam==button_close_basket_16)
        {
               ObjectSetString(0,button_close_basket_16,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[15]);               
               ObjectSetInteger(0,button_close_basket_16,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_16,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_16);       
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_17)
        {
               ObjectSetString(0,button_buy_basket_17,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[16],OP_BUY,lot,MarketInfo(TradePair[16],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_17,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_17,OBJPROP_TEXT,"Buy Basket");
                ObjectDelete(button_buy_basket_17);         
        }
     if(sparam==button_sell_basket_17)
        {
               ObjectSetString(0,button_sell_basket_17,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[16],OP_SELL,lot,MarketInfo(TradePair[16],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_17,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_17,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_17);      
        }
    if(sparam==button_close_basket_17)
        {
               ObjectSetString(0,button_close_basket_17,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[16]);               
               ObjectSetInteger(0,button_close_basket_17,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_17,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_17);           
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_18)
        {
               ObjectSetString(0,button_buy_basket_18,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[17],OP_BUY,lot,MarketInfo(TradePair[17],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_18,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_18,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_18);        
        }
     if(sparam==button_sell_basket_18)
        {
               ObjectSetString(0,button_sell_basket_18,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[17],OP_SELL,lot,MarketInfo(TradePair[17],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_18,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_18,OBJPROP_TEXT,"Sell Basket"); 
                ObjectDelete(button_sell_basket_18);        
        }
    if(sparam==button_close_basket_18)
        {
               ObjectSetString(0,button_close_basket_18,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[17]);               
               ObjectSetInteger(0,button_close_basket_18,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_18,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_18);         
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_19)
        {
               ObjectSetString(0,button_buy_basket_19,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[18],OP_BUY,lot,MarketInfo(TradePair[18],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_19,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_19,OBJPROP_TEXT,"Buy Basket");  
               ObjectDelete(button_buy_basket_19);      
        }
     if(sparam==button_sell_basket_19)
        {
               ObjectSetString(0,button_sell_basket_19,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[18],OP_SELL,lot,MarketInfo(TradePair[18],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_19,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_19,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_19);         
        }
    if(sparam==button_close_basket_19)
        {
               ObjectSetString(0,button_close_basket_19,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[18]);               
               ObjectSetInteger(0,button_close_basket_19,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_19,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_19);       
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_20)
        {
               ObjectSetString(0,button_buy_basket_20,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[19],OP_BUY,lot,MarketInfo(TradePair[19],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_20,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_20,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_20);          
        }
     if(sparam==button_sell_basket_20)
        {
               ObjectSetString(0,button_sell_basket_20,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[19],OP_SELL,lot,MarketInfo(TradePair[19],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_20,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_20,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_20);        
        }
    if(sparam==button_close_basket_20)
        {
               ObjectSetString(0,button_close_basket_20,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[19]);               
               ObjectSetInteger(0,button_close_basket_20,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_20,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_20);         
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_21)
        {
               ObjectSetString(0,button_buy_basket_21,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[20],OP_BUY,lot,MarketInfo(TradePair[20],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_21,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_21,OBJPROP_TEXT,"Buy Basket");
                ObjectDelete(button_buy_basket_21);        
        }
     if(sparam==button_sell_basket_21)
        {
               ObjectSetString(0,button_sell_basket_21,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[20],OP_SELL,lot,MarketInfo(TradePair[20],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_21,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_21,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_21);          
        }
    if(sparam==button_close_basket_21)
        {
               ObjectSetString(0,button_close_basket_21,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[20]);               
               ObjectSetInteger(0,button_close_basket_21,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_21,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_21);        
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_22)
        {
               ObjectSetString(0,button_buy_basket_22,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[21],OP_BUY,lot,MarketInfo(TradePair[21],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_22,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_22,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_22);          
        }
     if(sparam==button_sell_basket_22)
        {
               ObjectSetString(0,button_sell_basket_22,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[21],OP_SELL,lot,MarketInfo(TradePair[21],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_22,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_22,OBJPROP_TEXT,"Sell Basket");  
               ObjectDelete(button_sell_basket_22);      
        }
    if(sparam==button_close_basket_22)
        {
               ObjectSetString(0,button_close_basket_22,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[21]);               
               ObjectSetInteger(0,button_close_basket_22,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_22,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_22);        
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_23)
        {
               ObjectSetString(0,button_buy_basket_23,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[22],OP_BUY,lot,MarketInfo(TradePair[22],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_23,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_23,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_23);       
        }
     if(sparam==button_sell_basket_23)
        {
               ObjectSetString(0,button_sell_basket_23,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[22],OP_SELL,lot,MarketInfo(TradePair[22],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_23,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_23,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_23);      
        }
    if(sparam==button_close_basket_23)
        {
               ObjectSetString(0,button_close_basket_23,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[22]);               
               ObjectSetInteger(0,button_close_basket_23,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_23,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_23);
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_24)
        {
               ObjectSetString(0,button_buy_basket_24,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[23],OP_BUY,lot,MarketInfo(TradePair[23],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_24,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_24,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_24);                 
        }
     if(sparam==button_sell_basket_24)
        {
               ObjectSetString(0,button_sell_basket_24,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[23],OP_SELL,lot,MarketInfo(TradePair[23],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_24,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_24,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_24);         
        }
    if(sparam==button_close_basket_24)
        {
               ObjectSetString(0,button_close_basket_24,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[23]);               
               ObjectSetInteger(0,button_close_basket_24,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_24,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_24);        
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_25)
        {
               ObjectSetString(0,button_buy_basket_25,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[24],OP_BUY,lot,MarketInfo(TradePair[24],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_25,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_25,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_25);        
        }
     if(sparam==button_sell_basket_25)
        {
               ObjectSetString(0,button_sell_basket_25,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[24],OP_SELL,lot,MarketInfo(TradePair[24],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_25,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_25,OBJPROP_TEXT,"Sell Basket"); 
               ObjectDelete(button_sell_basket_25);      
        }
    if(sparam==button_close_basket_25)
        {
               ObjectSetString(0,button_close_basket_25,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[24]);               
               ObjectSetInteger(0,button_close_basket_25,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_25,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_25);
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_26)
        {
               ObjectSetString(0,button_buy_basket_26,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[25],OP_BUY,lot,MarketInfo(TradePair[25],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_26,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_26,OBJPROP_TEXT,"Buy Basket"); 
               ObjectDelete(button_buy_basket_26);                 
        }
     if(sparam==button_sell_basket_26)
        {
               ObjectSetString(0,button_sell_basket_26,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[25],OP_SELL,lot,MarketInfo(TradePair[25],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_26,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_26,OBJPROP_TEXT,"Sell Basket");
                ObjectDelete(button_sell_basket_26);         
        }
    if(sparam==button_close_basket_26)
        {
               ObjectSetString(0,button_close_basket_26,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[25]);               
               ObjectSetInteger(0,button_close_basket_26,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_26,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_26);          
        }
//--------------------------------------------------------------------------------------------------------
    if(sparam==button_buy_basket_27)
        {
               ObjectSetString(0,button_buy_basket_27,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[26],OP_BUY,lot,MarketInfo(TradePair[26],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_27,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_27,OBJPROP_TEXT,"Buy Basket");
                ObjectDelete(button_buy_basket_27);
         }       
     if(sparam==button_sell_basket_27)
        {
               ObjectSetString(0,button_sell_basket_27,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[26],OP_SELL,lot,MarketInfo(TradePair[26],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_27,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_27,OBJPROP_TEXT,"Sell Basket");
               ObjectDelete(button_sell_basket_27);         
        }
    if(sparam==button_close_basket_27)
        {
               ObjectSetString(0,button_close_basket_27,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[26]);               
               ObjectSetInteger(0,button_close_basket_27,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_27,OBJPROP_TEXT,"Close Basket");
               ObjectDelete(button_close_basket_27);         
        }
//--------------------------------------------------------------------------------------------------------
     if(sparam==button_buy_basket_28)
        {
               ObjectSetString(0,button_buy_basket_28,OBJPROP_TEXT,"Buying...");
               ticket=OrderSend(TradePair[27],OP_BUY,lot,MarketInfo(TradePair[27],MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,button_buy_basket_28,OBJPROP_STATE,0);
               ObjectSetString(0,button_buy_basket_28,OBJPROP_TEXT,"Buy Basket");
               ObjectDelete(button_buy_basket_28);         
        }
     if(sparam==button_sell_basket_28)
        {
               ObjectSetString(0,button_sell_basket_28,OBJPROP_TEXT,"Selling...");
               ticket=OrderSend(TradePair[27],OP_SELL,lot,MarketInfo(TradePair[27],MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,button_sell_basket_28,OBJPROP_STATE,0);
               ObjectSetString(0,button_sell_basket_28,OBJPROP_TEXT,"Sell Basket"); 
                ObjectDelete(button_sell_basket_28);         
        }
    if(sparam==button_close_basket_28)
        {
               ObjectSetString(0,button_close_basket_28,OBJPROP_TEXT,"Closing...");               
                closeOpenOrders(TradePair[27]);               
               ObjectSetInteger(0,button_close_basket_28,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_28,OBJPROP_TEXT,"Close Basket"); 
               ObjectDelete(button_close_basket_28);        
        }
//--------------------------------------------------------------------------------------------------------
        
     }
    //--- re-draw property values
   ChartRedraw(); 
     }
//+------------------------------------------------------------------+
//| closeOpenOrders                                                  |
//+------------------------------------------------------------------+
void closeOpenOrders(string currency )
{
   int cnt = 0;
    for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
    //for(j=0;j<ArraySize(TradePair);j++)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
                  if(OrderType()==OP_BUY && OrderSymbol() == currency && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderSymbol() == currency && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL) //pending orders
                     ticket=OrderDelete(OrderTicket());
                   
            }
}
void close_basket(int magic_number)
{ 
  
if (OrdersTotal()==0) return;
for (int i=OrdersTotal()-1; i>=0; i--)
      {//pozicio kivalasztasa
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)//ha kivalasztas ok
            {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber());
            if (OrderType()==0 && OrderMagicNumber()==Magic_Number)
               {//ha long
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }
            if (OrderType()==1 && OrderMagicNumber()==Magic_Number)
               {//ha short
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }  
            }
      }
  
//----
   return;
    
}
void close_profit()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() > 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    }
void close_loss()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() < 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    }                            
//+------------------------------------------------------------------+
void Trades ()
{
   int i, j;
   double totallots=0;
   for(i=0;i<ArraySize(TradePair);i++)
   {
      
      bpos[i]=0;
      spos[i]=0;       
      blots[i]=0;
      slots[i]=0;     
      bprofit[i]=0;
      sprofit[i]=0;
      tprofit[i]=0;
   }
	for(i=0;i<OrdersTotal();i++)
	{
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      for(j=0;j<ArraySize(TradePair);j++)
      {	  
         if((TradePair[j]==OrderSymbol() || TradePair[j]=="") && OrderMagicNumber()==Magic_Number)
         {
            TradePair[j]=OrderSymbol();                       
            tprofit[j]=tprofit[j]+OrderProfit()+OrderSwap()+OrderCommission();
           if(OrderType()==0){ bprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==1){ sprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==0){ blots[j]+=OrderLots(); } 
           if(OrderType()==1){ slots[j]+=OrderLots(); }
           if(OrderType()==0){ bpos[j]+=+1; } 
           if(OrderType()==1){ spos[j]+=+1; } 
                                
            totallots=totallots+OrderLots();
            break;
	     }
	  }
   }
   }
//+------------------------------------------------------------------+
double TotalProfit ()
{
   double totalprofit=0;
   for(int i=0;i<OrdersTotal();i++) 
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if((OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderMagicNumber()==Magic_Number)
          totalprofit=totalprofit+OrderProfit()+OrderCommission()+OrderSwap();
   }
   return (totalprofit);
}
//+------------------------------------------------------------------+ 
#define sectorSize  1936
#define HFILE_ERROR -1
void getPrefixSuffix(string& prefix, string& suffix)
{ 
   int fileHandle = FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE);
   if (fileHandle == HFILE_ERROR) {
      Print("Open symbols.raw failed");
      return;
   }

   prefix="";
   suffix="";
   for(int i=0;; i++)
   {
      FileSeek(fileHandle, sectorSize*i, SEEK_SET);
         if (FileIsEnding(fileHandle)) { 
            break; 
         }
string symbolName = FileReadString(fileHandle,12);
      symbolName = StringSubstr(symbolName, 0);
                   
            int pos = StringFind(symbolName,"EURUSD",0);
             if (pos > -1)
             {
                if (pos>0)
                  prefix = StringSubstr(symbolName,0,pos);
                if ((pos+6)<StringLen(symbolName))
                  suffix = StringSubstr(symbolName,(pos+6),0);
                break;
             }     
   } 

   if (fileHandle>-1)
      FileClose(fileHandle);
}    