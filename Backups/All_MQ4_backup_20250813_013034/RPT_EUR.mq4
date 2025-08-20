#property show_inputs 
#include <stdlib.mqh>


extern double Lots=0.1;
extern double EURUSD_b=0.01;
extern int    EURUSD_t3_period=30;
extern int    EURUSD_TimeFrame=5;
extern int    EURUSD_SL=500;
int EURUSD_Bars=0;
extern bool   TextAlert=true;
extern bool   SoundAlert=true;
extern string SoundFile="expert.wav";
extern bool   OpenTrades=true;

int mBar=300;
int Magic=230475609;


int check_stat(string para,int tf,int t3_period,double b)
 {
  RefreshRates();
  double C1=iCustom(para,tf,"i-RoundPrice-T01m-mod",t3_period,b,mBar,0,0);
  double C2=iCustom(para,tf,"i-RoundPrice-T01m-mod",t3_period,b,mBar,1,0);
  if (C1==0 && C2>0) int R0=-1; else  
  if (C1>0 && C2==0) R0=1; else R0=0;
  C1=iCustom(para,tf,"i-RoundPrice-T01m-mod",t3_period,b,mBar,0,1);
  C2=iCustom(para,tf,"i-RoundPrice-T01m-mod",t3_period,b,mBar,1,1);
  if (C1==0 && C2>0) int R1=-1; else
  if (C1>0 && C2==0) R1=1; else R1=0;
  if (R0!=R1)
   {
    if (R1==1) {R0=-1;} else 
    if (R1==-1) {R0=1;}
    if (R0==1) string do="ÏÎÊÓÏÀÒÜ (BUY)";
    if (R0==-1) do="ÏÐÎÄÀÂÀÒÜ (SELL)";
    int res=R0;
    if (TextAlert) Alert("Íà ", para," íà ",WhatTF(tf)," Ïîðà ",do);
    if (SoundAlert) PlaySound(SoundFile);
    return(R0);
   } else res=0;
  return(res);
 }

string WhatTF(int ctf)
{
 switch(ctf)
    {
    case PERIOD_M1:  return("M1");  break;
    case PERIOD_M5:  return("M5");  break;
    case PERIOD_M15: return("M15"); break;
    case PERIOD_M30: return("M30"); break;
    case PERIOD_H1:  return("H1");  break;
    case PERIOD_H4:  return("H4");  break;
    case PERIOD_D1:  return("D1");  break;
    case PERIOD_W1:  return("W1");  break;
    case PERIOD_MN1: return("MN1"); break;
    default: return("ÍÅÒ ÒÀÊÎÃÎ ÒÀÉÌÔÐÅÉÌÀ");
    }
}

int start(){
  {
   RefreshRates();
   if(EURUSD_Bars!=iBars("EURUSD",EURUSD_TimeFrame))
    {
     int stat=check_stat("EURUSD",EURUSD_TimeFrame,EURUSD_t3_period,EURUSD_b);

     int cnt1=OrdersTotal()-1;
     for(int cnt2=cnt1;cnt2>=0;cnt2--)
      {
       OrderSelect(cnt2,SELECT_BY_POS,MODE_TRADES);
       if(OrderSymbol()=="EURUSD" && OrderMagicNumber()==Magic)
        {
         if(OrderType()==OP_BUY && stat==-1)
          OrderClose(OrderTicket(),OrderLots(),MarketInfo("EURUSD",MODE_BID),3,Aqua);
         if(OrderType()==OP_SELL && stat==1)
          OrderClose(OrderTicket(),OrderLots(),MarketInfo("EURUSD",MODE_ASK),3,Magenta);
        }
      }
      
     if (stat==1 && OpenTrades && OrdersTotal()==0)
      {
       OrderSend("EURUSD",OP_BUY,Lots,MarketInfo("EURUSD",MODE_ASK),5,MarketInfo("EURUSD",MODE_BID)-EURUSD_SL*Point,0,"RPT",Magic,0,Aqua);
       EURUSD_Bars=iBars("EURUSD",EURUSD_TimeFrame);
      }
     if (stat==-1 && OpenTrades && OrdersTotal()==0)
      {
       OrderSend("EURUSD",OP_SELL,Lots,MarketInfo("EURUSD",MODE_BID),5,MarketInfo("EURUSD",MODE_ASK)+EURUSD_SL*Point,0,"RPT",Magic,0,Magenta);
       EURUSD_Bars=iBars("EURUSD",EURUSD_TimeFrame);
      }
    }
   if (!IsTesting()) Sleep(1000);
  }
 return(0);
}


