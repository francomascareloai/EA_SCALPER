/*

*********************************************************************
          
                 RSI with Trend Catcher signal
                      
                              
                          by Matsu
              based on codes from various sources
                  
*********************************************************************

*/


#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Gold

#property indicator_level1 60
#property indicator_level2 50
#property indicator_level3 40

int       BBPrd=20;
double    BBDev=2.0;
int       SBPrd=13;
int       SBATRPrd=21;
double    SBFactor=2;
int       SBShift=1;
extern int       RSIPeriod=21;
extern int       BullLevel=50;
extern int       BearLevel=50;
extern bool      AlertOn = true;

double RSI[];
double DnRSI[];
double Buy[];
double Sell[];
double Squeeze[];



int init() 
{

   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSI);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,DnRSI);
   
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Buy);
   
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,Sell);
   
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(4,159);
   SetIndexBuffer(4,Squeeze);
      
   IndicatorShortName("RSI("+RSIPeriod+")");
   IndicatorDigits(2);
   
   return(0);
   
}



int start() 
{

   int counted_bars=IndicatorCounted();
   int shift,limit,ob,os;
   double BBMA, SBMA, TopBBand, BotBBand, TopBBandPrev, BotBBandPrev, TopSBand, BotSBand;
   bool dn = false;
   double BuyNow, BuyPrevious, SellNow, SellPrevious;
   static datetime prevtime = 0;
   
      
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-31;
   if(counted_bars>=31) limit=Bars-counted_bars-1;

   for (shift=limit;shift>=0;shift--)   
   {
            
      RSI[shift]=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,shift);
      ob = indicator_level1;
      os = indicator_level3;
      
      // ========= Two-tone RSI
      
      if (dn==true)
      {
         if (RSI[shift]>BullLevel) 
         {
            dn=false;
            DnRSI[shift]=EMPTY_VALUE;
         }
         else
         {
            dn=true;
            DnRSI[shift]=RSI[shift];
         }

      }
      else
      {
         if (RSI[shift]<BearLevel) 
         {
            dn=true;
            DnRSI[shift]=RSI[shift];
         }
         else
         {
            dn=false;
            DnRSI[shift]=EMPTY_VALUE;
         }
           
      }
      
      // ========= Two-tone RSI Ends
      
      // ========= Squeeze Signals
      
      BBMA     = iMA(NULL,0,BBPrd,0,MODE_SMA,PRICE_CLOSE,shift);
      SBMA     = iMA(NULL,0,SBPrd,0,MODE_EMA,PRICE_CLOSE,shift+SBShift);
      TopBBand = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_UPPER,shift);
	   BotBBand = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_LOWER,shift);
      TopSBand = SBMA + (SBFactor * iATR(NULL,0,SBATRPrd,shift+SBShift));
      BotSBand = SBMA - (SBFactor * iATR(NULL,0,SBATRPrd,shift+SBShift));
      TopBBandPrev = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_UPPER,shift+1);
	   BotBBandPrev = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_LOWER,shift+1);
      
      if (TopBBand<TopSBand && BotBBand>BotSBand) Squeeze[shift]=50;
      
      // ========= Squeeze Signals Ends
      
      // ========= BB Breakout Signals
      
      //if(Squeeze[shift+2]==50 && RSI[shift]>50 && BotBBand<BotSBand) 
      if((Squeeze[shift+2]==50 || Squeeze[shift+1]==50) && RSI[shift]>50 && BotBBand<BotSBand) 
      {
         Buy[shift]=ob;
         Sell[shift]=EMPTY_VALUE;
      } 
      else 
      //if(Squeeze[shift+2]==50 && RSI[shift]<50 && TopBBand>TopSBand) 
      if((Squeeze[shift+2]==50 || Squeeze[shift+1]==50) && RSI[shift]<50 && TopBBand>TopSBand) 
      {
         Buy[shift]=EMPTY_VALUE;
         Sell[shift]=os;
      }
      else
      if(Buy[shift+1]==ob && BotBBand<BotBBandPrev && RSI[shift]>50)
      {
         Buy[shift]=ob;
         Sell[shift]=EMPTY_VALUE;
      } 
      else
      if(Sell[shift+1]==os && TopBBand>TopBBandPrev && RSI[shift]<50)
      {
         Buy[shift]=EMPTY_VALUE;
         Sell[shift]=os;
      }
      else
      {
         Buy[shift]=EMPTY_VALUE;
         Sell[shift]=EMPTY_VALUE;
      }
      
      // ========= BB Breakout Signals Ends
      
   }      
         

   // ======= Alert =========

   if(AlertOn)
   {
      if(prevtime == Time[0]) 
      {
         return(0);
      }
      prevtime = Time[0];
   
      BuyNow = Buy[0];
      BuyPrevious = Buy[1];
      SellNow = Sell[0];
      SellPrevious = Sell[1];
   
      if((BuyNow ==ob) && (BuyPrevious ==EMPTY_VALUE) )
      {
         Alert(Symbol(), " M", Period(), " Buy Alert");
      }
      else   
      if((SellNow ==os) && (SellPrevious ==EMPTY_VALUE) )
      {
         Alert(Symbol(), " M", Period(), " Sell Alert");
      }
         
      IndicatorShortName("RSI("+RSIPeriod+") (Alert on)");

   }

   // ======= Alert Ends =========


   
   return(0);
   
}



