#property strict
#property indicator_buffers 6
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

input int         iRSIPeriod           = 14;                    // RSI periods
input int         iBandsPeriod         = 34;                    // BB periods
input double      iBandsDeviation      = 2.5;                   // BB deviation
input bool        alertsOn             = true;                  // Alerts on true/false?
input bool        alertsOnCurrent      = false;                 // Alerts on open bar true/false?
input bool        alertsMessage        = true;                  // Alerts message true/false?
input bool        alertsSound          = false;                 // Alerts sound true/false?
input bool        alertsEmail          = false;                 // Alerts email true/false?
input bool        alertsNotify         = false;                 // Alerts notification true/false?

double ExtRSI[], ExtUp[], ExtDn[], ExtMd[], ExtBuyArrow[], ExtSellArrow[],trend[];

int OnInit() {
   IndicatorShortName("RSI("+string(iRSIPeriod)+") Bands("+string(iBandsPeriod)+","+DoubleToString(iBandsDeviation,2)+")");
   IndicatorBuffers(7);
   SetIndexBuffer(0,ExtRSI);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrDodgerBlue);
   SetIndexLabel(0,"RSI");
   SetIndexBuffer(1,ExtUp);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(1,"Upper band");
   SetIndexBuffer(2,ExtDn);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(2,"Lower band");
   SetIndexBuffer(3,ExtMd);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(3,"Middle band");
   SetIndexBuffer(4,ExtBuyArrow);
   SetIndexStyle(4,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(4,225);
   SetIndexLabel(4,"Buy arrow");
   SetIndexBuffer(5,ExtSellArrow);
   SetIndexStyle(5,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(5,226);
   SetIndexLabel(5,"Sell arrow");
   SetIndexBuffer(6,trend);
   
   SetIndexDrawBegin(0,iRSIPeriod);
   SetIndexDrawBegin(1,iRSIPeriod+iBandsPeriod);
   SetIndexDrawBegin(2,iRSIPeriod+iBandsPeriod);
   SetIndexDrawBegin(3,iRSIPeriod+iBandsPeriod);
   return(INIT_SUCCEEDED);
}
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   int limit = rates_total-prev_calculated;
   if( limit<=0 ) limit = 1;
   
   for( int i=0; i<limit; i++ ) {
      ExtRSI[i] = iRSI(NULL,0,iRSIPeriod,PRICE_CLOSE,i);
   }
   for( int i=0; i<limit; i++ ) {
      ExtUp[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_UPPER,i);
      ExtMd[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_MAIN,i);
      ExtDn[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_LOWER,i);
   }
   for( int i=0; i<limit; i++ ) {
      ExtBuyArrow[i] = ExtSellArrow[i] = EMPTY_VALUE;
      trend[i] = 0;
      bool BuyArrow  = ExtRSI[i]>ExtDn[i] && ExtRSI[i+1]<=ExtDn[i+1];
      bool SellArrow = ExtRSI[i]<ExtUp[i] && ExtRSI[i+1]>=ExtUp[i+1];
      
      if( BuyArrow )  { ExtBuyArrow[i]  = ExtDn[i]; trend[i] = 1; }
      if( SellArrow ) { ExtSellArrow[i] = ExtUp[i]; trend[i] =-1; }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("price crossed lower band");
      else  doAlert("price crossed upper band");       
   }     
   return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" RSI-BB-BAND "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" RSI-BB-BAND ",message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}



