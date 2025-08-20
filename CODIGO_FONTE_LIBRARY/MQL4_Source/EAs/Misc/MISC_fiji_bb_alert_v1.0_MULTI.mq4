#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 White
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_color5 Blue
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 3
#property indicator_width5 3
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID


//---- input parameters
extern int eintBandsPeriod = 20;
extern double edblBandsDev = 2.0;
extern int eintMAMode = MODE_SMA;
extern int eintMAPrice = PRICE_CLOSE;
extern int eintMAShift = 0;
extern int eintBarsBack = 1;
extern bool UseSound=true;
extern bool AlertSound=true;
extern string SoundFileBuy ="alert2.wav";
extern string SoundFileSell="email.wav";
extern bool SendMailPossible = false;
extern int SIGNAL_BAR =  1 ; 
bool SoundBuy  = False;
bool SoundSell = False;


//---- indicator buffers
double gadblMid[];
double gadblUpper[];
double gadblLower[];
double gadblDiv[];
double gadblDiv2[];

//+------------------------------------------------------------------+
//| init()                                                           |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer( 0, gadblMid );
   SetIndexStyle( 0, DRAW_LINE );
   SetIndexLabel( 0, "BB-Mid" );
   
   SetIndexBuffer( 1, gadblUpper );
   SetIndexStyle( 1, DRAW_LINE );
   SetIndexLabel( 1, "BB-Upper" );
   
   SetIndexBuffer( 2, gadblLower );
   SetIndexStyle( 2, DRAW_LINE );
   SetIndexLabel( 2, "BB-Lower" );
   
   SetIndexBuffer( 3, gadblDiv );
   SetIndexStyle( 3, DRAW_ARROW );
   SetIndexArrow( 3, 108 ); 
   SetIndexLabel( 3, NULL );
   SetIndexEmptyValue( 3, 0.0 );
   
   SetIndexBuffer( 4, gadblDiv2 );
   SetIndexStyle( 4, DRAW_ARROW );
   SetIndexArrow( 4, 108 ); 
   SetIndexLabel( 4, NULL );
   SetIndexEmptyValue( 4, 0.0 );

   IndicatorShortName( "Fiji BB" );
   IndicatorDigits( Digits );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| deinit()                                                         |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| start()                                                          |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int intLimit = Bars - counted_bars;
        
   int intTrueShift, inx, jnx;
   double dblSum, dblNewRes, dblClose, dblDeviation, dblCurrMA;

   for( inx = intLimit; inx >= 0; inx-- )
   {
      intTrueShift = inx + eintMAShift;
      dblSum = 0.0;
      dblCurrMA = iMA( Symbol(), Period(), eintBandsPeriod, 0, eintMAMode, eintMAPrice, intTrueShift );
      
      for ( jnx = intTrueShift + eintBandsPeriod - 1; jnx >= intTrueShift; jnx-- )
      {
         dblNewRes = Close[jnx] - dblCurrMA;
         dblSum += ( dblNewRes * dblNewRes );
      }
   
      dblDeviation = edblBandsDev * MathSqrt( dblSum / eintBandsPeriod );
      gadblMid[inx] = dblCurrMA;
      gadblUpper[inx] = dblCurrMA + dblDeviation;
      gadblLower[inx] = dblCurrMA - dblDeviation; 
      gadblDiv[inx] = 0.0;
      gadblDiv2[inx] = 0.0;
      
      // Check for divergence of upper band
      if ( ( High[inx] > gadblUpper[inx] ) && ( High[inx+eintBarsBack] > gadblUpper[inx+eintBarsBack] ) )
      {
         if ( High[inx] < High[inx+eintBarsBack] )
         {
            if ( gadblUpper[inx] > gadblUpper[inx+eintBarsBack] )    gadblDiv[inx] = High[inx];
         }
      }
      
      // Check for divergence of lower band
      if ( ( Low[inx] < gadblLower[inx] ) && ( Low[inx+eintBarsBack] < gadblLower[inx+eintBarsBack] ) )
      {
         if ( Low[inx] > Low[inx+eintBarsBack] )
         {
            if ( gadblLower[inx] < gadblLower[inx+eintBarsBack] )    gadblDiv2[inx] = Low[inx];
         }
      }   
   }
 //+------------------------------------------------------------------+ 
  string  message  =  StringConcatenate("Fiji BB (", Symbol(), ", ", Period(), ")  -  BUY!!!" ,"-" ,TimeToStr(TimeLocal(),TIME_SECONDS)); 
  string  message2 =  StringConcatenate("Fiji BB (", Symbol(), ", ", Period(), ")  -  SELL!!!" ,"-" ,TimeToStr(TimeLocal(),TIME_SECONDS)); 
 
               
        if (gadblDiv2[SIGNAL_BAR] != EMPTY_VALUE && gadblDiv2[SIGNAL_BAR] != 0 && SoundBuy)
         {
         SoundBuy = False;
            if (UseSound) PlaySound (SoundFileBuy);
               if(AlertSound){         
               Alert(message);                             
               if (SendMailPossible) SendMail(Symbol(),message); 
            }              
         } 
      if (!SoundBuy && (gadblDiv2[SIGNAL_BAR] == EMPTY_VALUE || gadblDiv2[SIGNAL_BAR] == 0)) SoundBuy = True; 
      
        if (gadblDiv[SIGNAL_BAR] != EMPTY_VALUE && gadblDiv[SIGNAL_BAR] != 0 && SoundSell)
         {
         SoundSell = False;
            if (UseSound) PlaySound (SoundFileSell); 
             if(AlertSound){                    
             Alert(message2);             
             if (SendMailPossible) SendMail(Symbol(),message2); 
             }            
         } 
      if (!SoundSell && (gadblDiv[SIGNAL_BAR] == EMPTY_VALUE || gadblDiv[SIGNAL_BAR] == 0)) SoundSell = True;     
   return( 0 );
}

   


