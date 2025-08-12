/*

*********************************************************************
          
                 RSI with Trend Catcher signal
                      
                              
                          by Matsu
              based on codes from various sources
                  
*********************************************************************

*/


#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Red

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
double Buy[];
double Sell[];
double DnRSI[];


int init() 
{

   IndicatorBuffers(4);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSI);
   
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,Buy);
   
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Sell);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,DnRSI);
   
   IndicatorShortName("RSI("+RSIPeriod+")");
   IndicatorDigits(2);
   
   return(0);
   
}



int start() 
{

   int counted_bars=IndicatorCounted();
   int shift,limit,ob,os;
   double BBMA, SBMA, TopBBand, BotBBand, TopSBand, BotSBand;
   bool TrendUp, TrendDn;
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
      
      TrendUp=false;
      TrendDn=false;
      BBMA     = iMA(NULL,0,BBPrd,0,MODE_SMA,PRICE_CLOSE,shift);
      SBMA     = iMA(NULL,0,SBPrd,0,MODE_EMA,PRICE_CLOSE,shift+SBShift);
      TopBBand = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_UPPER,shift);
	   BotBBand = iBands(NULL,0,BBPrd,BBDev,0,PRICE_CLOSE,MODE_LOWER,shift);
      TopSBand = SBMA + (SBFactor * iATR(NULL,0,SBATRPrd,shift+SBShift));
      BotSBand = SBMA - (SBFactor * iATR(NULL,0,SBATRPrd,shift+SBShift));

      if(SBMA>BBMA && RSI[shift]>50) TrendUp=true;
      if(SBMA<BBMA && RSI[shift]<50) TrendDn=true;
      
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
      
      


      if(TrendUp==true && BotBBand<BotSBand) 
      {
         Buy[shift]=ob;
         Sell[shift]=EMPTY_VALUE;
      } 
      else 
      if(TrendDn==true && TopBBand>TopSBand) 
      {
         Buy[shift]=EMPTY_VALUE;
         Sell[shift]=os;
      } 
      else
      {
         Buy[shift]=EMPTY_VALUE;
         Sell[shift]=EMPTY_VALUE;
      }
      
    }      
         

//       ======= Alert =========

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

//       ======= Alert End =========


   
   return(0);
   
}



