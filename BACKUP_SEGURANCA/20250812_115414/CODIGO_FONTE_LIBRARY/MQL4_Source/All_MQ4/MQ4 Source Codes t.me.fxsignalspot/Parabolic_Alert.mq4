//+------------------------------------------------------------------+
//|                                              Parabolic_Alert.mq4 |
//|                                Original file name: Parabolic.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                       Modified to give audible alarm on reversal |
//|                                       Modified by Jim Arner, Sr. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DarkOrange
//---- input parameters
extern double    Step=0.05;
extern double    Maximum=0.3;
//---- buffers
double SarBuffer[];
//----
int    save_lastreverse;
bool   save_dirlong, save_dirshort;
double save_start;
double save_last_high;
double save_last_low;
double save_ep;
double save_sar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,158);
   SetIndexBuffer(0,SarBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveLastReverse(int last,int dir_l,int dir_s,double start,double low,double high,double ep,double sar)
  {
   save_lastreverse=last;
   save_dirlong=dir_l;
   save_dirshort=dir_s;
   save_start=start;
   save_last_low=low;
   save_last_high=high;
   save_ep=ep;
   save_sar=sar;
  }
//+------------------------------------------------------------------+
//| Parabolic Sell And Reverse system                                |
//+------------------------------------------------------------------+
int start()
  {
   static bool first=true;
   bool   dirlong, dirshort;
   double start,last_high,last_low;
   double ep,sar,price_low,price_high,price;
   int    i,counted_bars=IndicatorCounted();
   string TradeTime;
//----
   if(Bars<3) return(0);
//---- initial settings
   i=Bars-2;
   if(counted_bars==0 || first)
     {
      first=false;
      dirlong=true;
      dirshort=false;
      start=Step;
      last_high=-10000000.0;
      last_low=10000000.0;
      while(i>0)
        {
         save_lastreverse=i;
         price_low=Low[i];
         if(last_low>price_low)   last_low=price_low;
         price_high=High[i];
         if(last_high<price_high) last_high=price_high;
         if(price_high>High[i+1] && price_low>Low[i+1]) break;
         if(price_high<High[i+1] && price_low<Low[i+1]) { dirlong=false; break; }
         i--;
        }
      //---- initial zero
      int k=i;
      while(k<Bars)
        {
         SarBuffer[k]=0.0;
         k++;
        }
      //---- check further
      if(dirlong)        { SarBuffer[i]=Low[i+1]; ep=High[i]; }
      if(dirshort)       { SarBuffer[i]=High[i+1]; ep=Low[i]; }
      i--;
     }
    else
     {
      i=save_lastreverse+1;
      start=save_start;
      dirlong=save_dirlong;
      dirshort=save_dirshort;
      last_high=save_last_high;
      last_low=save_last_low;
      ep=save_ep;
      sar=save_sar;
     }
//----
   while(i>=0)
   {
      price_low=Low[i];
      price_high=High[i];
      //--- check for reverse
      if(dirlong==true && price_low<SarBuffer[i+1])
        {
         // Print("Section 1 Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);
         SaveLastReverse(i,true,false,start,price_low,last_high,ep,sar);
         start=Step; dirlong=false; dirshort=true;
         // Comment("I= ",i);
         if (i==0)
          {
           PlaySound("alert.wav");
           TradeTime = TimeToStr(CurTime(),TIME_SECONDS);
           Comment("\nSell Alert","\nChart Time= ", TradeTime);
          }
         ep=price_low;  last_low=price_low;
         SarBuffer[i]=last_high;
         i--;
         continue;
        } 
      
      if(dirshort==true && price_high>SarBuffer[i+1])
        {
         // Print("Section 2 Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);
         SaveLastReverse(i,false,true,start,last_low,price_high,ep,sar);
         start=Step; dirlong=true; dirshort=false;
         // Comment("I= ",i);
         if (i==0)
          {
           PlaySound("alert.wav");
           TradeTime = TimeToStr(CurTime(),TIME_SECONDS);
           Comment("\nBuy Alert","\nChart Time= ", TradeTime);
          }
         ep=price_high; last_high=price_high;
         SarBuffer[i]=last_low;
         i--;
         continue;
        }
        
                
      //---
      price=SarBuffer[i+1];
      sar=price+start*(ep-price);
      if(dirlong)
        {
         /* 
         Comment("DirLong","\nI= ",i,"\nDirL ",dirlong,"\nDirS ",dirshort,
                 "\nStart= ",start,"\nLow= ",last_low,"\nHigh= ",last_high,
                 "\nEP= ",ep,"\nSAR= ",sar,"\nMinute= ",Minute());        
         */ 
         // Print("Section 3 Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);       
         if(ep<price_high && (start+Step)<=Maximum) start+=Step;
         if(price_high<High[i+1] && i==Bars-2)  sar=SarBuffer[i+1];

         price=Low[i+1];
         if(sar>price) sar=price;
         price=Low[i+2];
         if(sar>price) sar=price;
         if(sar>price_low)
           {
            SaveLastReverse(i,true,false,start,price_low,last_high,ep,sar);
            start=Step; dirlong=false; dirshort=true; ep=price_low;
            last_low=price_low;
            SarBuffer[i]=last_high;
            i--;
            /*
            if (i == 0)
            {
             Print("Section 3a Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);
            }
            */
            if (dirshort && i == 0)
            {
             PlaySound("alert.wav");
             TradeTime = TimeToStr(CurTime(),TIME_SECONDS);
             Comment("\nSell Alert","\nChart Time= ", TradeTime);
            }
            continue;
           }
         if(ep<price_high) { last_high=price_high; ep=price_high; }
        }
      if(dirshort)
        {
         /*
         Comment("DirShort","\nI= ",i,"\nDirL ",dirlong,"\nDirS ",dirshort,
                 "\nStart= ",start,"\nLow= ",last_low,"\nHigh= ",last_high,
                 "\nEP= ",ep,"\nSAR= ",sar,"\nMinute= ",Minute());
         */  
         // Print("Section 4 Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);      
         if(ep>price_low && (start+Step)<=Maximum) start+=Step;
         if(price_low<Low[i+1] && i==Bars-2)  sar=SarBuffer[i+1];

         price=High[i+1];
         if(sar<price) sar=price;
         price=High[i+2];
         if(sar<price) sar=price;
         if(sar<price_high)
           {
            SaveLastReverse(i,false,true,start,last_low,price_high,ep,sar);
            start=Step; dirlong=true; dirshort=false; ep=price_high;
            last_high=price_high;
            SarBuffer[i]=last_low;
            i--;
            /*
            if (i == 0)
            {
             Print("Section 4a Code executing"," I= ",i," DirLong= ",dirlong," DirShort= ",dirshort);
            }
            */
            if (dirlong && i == 0)
            {
             PlaySound("alert.wav");
             TradeTime = TimeToStr(CurTime(),TIME_SECONDS);
             Comment("\nBuy Alert","\nChart Time= ", TradeTime);
            }
            continue;
           }
         if(ep>price_low) { last_low=price_low; ep=price_low; }
        }
      SarBuffer[i]=sar;
      i--;
     }
//   sar=SarBuffer[0];
//   price=iSAR(NULL,0,Step,Maximum,0);
//   if(sar!=price) Print("custom=",sar,"   SAR=",price,"   counted=",counted_bars);
//   if(sar==price) Print("custom=",sar,"   SAR=",price,"   counted=",counted_bars);
//----
   return(0);
  }
//+------------------------------------------------------------------+