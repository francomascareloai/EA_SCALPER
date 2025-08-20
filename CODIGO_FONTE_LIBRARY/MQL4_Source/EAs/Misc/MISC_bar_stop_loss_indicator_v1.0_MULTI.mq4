//+------------------------------------------------------------------+
//|                                                 3BarStopLoss.mq4 |
//|                           Copyright © 2009, Forex-Tools-Cafe.com |
//|                                  http://www.forex-tools-cafe.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property  indicator_buffers 4

extern bool  UseSpreadOffset=true;
extern int   ManualOffset=4; 
extern int   MaxBars=2000; 
extern int   TrendEMAPeriod=2;
extern int   lookback=3;


extern string S1="Line Style: 0=line,1=dash,2=dots"; 
extern int     StopLineStyle=2; 
extern int     EntryLineStyle=0; 
extern int     EntryLineWidth=3; 
extern color   SellColor=Red;
extern color   BuyColor=Blue; 

double  SellStop[];
double  BuyEntry[];
double  SellEntry[];
double  BuyStop[]; 

int     Trend; 



int init()
{

   // IndicatorBuffers(4);
    
   SetIndexBuffer(0,SellStop ); 
   SetIndexBuffer(1,BuyEntry ); 
   SetIndexBuffer(2,SellEntry); 
   SetIndexBuffer(3,BuyStop  ); 
   
   
   SetIndexStyle(0,DRAW_LINE, StopLineStyle, 1 , SellColor  );
   SetIndexStyle(1,DRAW_LINE, EntryLineStyle, 1 , BuyColor  );
   
   SetIndexStyle(2,DRAW_LINE, EntryLineStyle, 1 , SellColor  );
   SetIndexStyle(3,DRAW_LINE, StopLineStyle, 1 , BuyColor  );
   
   
   return(0);
}

int deinit()
{

   return(0);
}

int start()
{
   int    counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars ;
   
   if ( limit > MaxBars ) limit = MaxBars; 
   
   SetIndexStyle(0,DRAW_LINE, StopLineStyle, 1 , SellColor  );
   SetIndexStyle(1,DRAW_LINE, EntryLineStyle, EntryLineWidth , BuyColor  );
   
   SetIndexStyle(2,DRAW_LINE, EntryLineStyle, EntryLineWidth , SellColor  );
   SetIndexStyle(3,DRAW_LINE, StopLineStyle, 1 , BuyColor  );
   
   int offset; 
   if ( UseSpreadOffset ) offset = MarketInfo(Symbol(), MODE_SPREAD ); 
   else
      offset = ManualOffset; 
      
   for(int i=limit; i>=0; i--)
   {   
   
      double diff =  iMA(Symbol(), 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_CLOSE, i)  
                   - iMA(Symbol(), 0, TrendEMAPeriod+1, 0, MODE_SMMA, PRICE_CLOSE, i);
                   
   //   double diff2 =  iMA(Symbol(), 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_CLOSE, i+1)  
   //                - iMA(Symbol(), 0, TrendEMAPeriod+1, 0, MODE_SMMA, PRICE_CLOSE, i+1);
      
      
      if ( diff >= 0.0   ) // just crossed upward
      {
         Trend = 1;
      }
      else if ( diff < 0.0   )
      {
         Trend = -1;
      }
      
      if (false && i==14)
      {
         Comment("SellStop[i]: " + SellStop[i]
            + "\ndiff: " + diff
          //  + "\ndiff2: " + diff2
            + "\nBuyEntry[i]: " + BuyEntry[i]
            + "\nSellEntry[i]: " + SellEntry[i]
            + "\nBuyStop[i]: " + BuyStop[i]
            
          ); 
      
      }
   
      if ( Trend == 1 ) 
      {
         int lo = ArrayMinimum(Low,lookback,i);
         
         SellStop[i]=EMPTY_VALUE;
         BuyEntry[i]=High[i+1];
         SellEntry[i]=EMPTY_VALUE;
         double sl = Low[lo]-(offset)*Point; 
         if ( BuyStop[i+1]!=EMPTY_VALUE && sl < BuyStop[i+1] ) 
            BuyStop[i]= BuyStop[i+1];
         else 
            BuyStop[i]= sl; 
      
      }
      else if ( Trend == -1 )
      {
         int hi = ArrayMaximum(High,lookback,i);
         
         double slsell = High[hi] + (offset)*Point;
         if ( SellStop[i+1]!=EMPTY_VALUE && slsell > SellStop[i+1] )
            SellStop[i]= SellStop[i+1]; 
         else
            SellStop[i] = slsell; 
            
         BuyEntry[i]=EMPTY_VALUE ;
         SellEntry[i]=Low[i+1];
         BuyStop[i]=EMPTY_VALUE; 
      
      }
   }

   return(0);
}

