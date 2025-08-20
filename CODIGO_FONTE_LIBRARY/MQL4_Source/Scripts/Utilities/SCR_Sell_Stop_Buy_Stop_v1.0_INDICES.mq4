#property copyright "Copyright trevone"
#property link "https://www.mql5.com/en/users/trevone" 
#property strict
#property version "1.04" 
   
extern string TradeComment = "Ascal v1.04"; 
extern int MagicNumber = 101; 
extern int Slippage = 3;
extern int MaxSpread = 262;
extern double FixedLot = 0;
extern int RiskPercent = 20; 
extern int MaxDrawdown = 3;  
extern int StartHour = 19; 
extern int EndHour = 1;
extern int GMTOffset = 0;
extern int Trailing = 7;   
extern int Profit = 13; 
extern int VelocityTrigger = 50; 
extern int Offset = 11;
int VelocityTime = 7;   

int OrderExpiry = 15; 
int TickSample = 100;  
int r, gmt, brokerOffset, size, digits, stoplevel;

double marginRequirement, maxLot, minLot, lotSize, points, currentSpread, avgSpread, maxSpread, initialBalance, rateChange, rateTrigger, deleteRatio, commissionPoints;

double spreadSize[]; 
double tick[];
double avgtick[];
int tickTime[];   

string testerStartDate, testerEndDate; 

int lastBuyOrder, lastSellOrder;

bool calculateCommission = true;

double max = 0;

int init() {   
   marginRequirement = MarketInfo( Symbol(), MODE_MARGINREQUIRED ) * 0.01;
   maxLot = ( double ) MarketInfo( Symbol(), MODE_MAXLOT );  
   minLot = ( double ) MarketInfo( Symbol(), MODE_MINLOT );  
   currentSpread = NormalizeDouble( Ask - Bid, Digits ); 
   stoplevel = ( int ) MathMax( MarketInfo( Symbol(), MODE_FREEZELEVEL ), MarketInfo( Symbol(), MODE_STOPLEVEL ) );
   if( stoplevel > Offset ) Offset = stoplevel;
   if( stoplevel > Trailing ) Trailing = stoplevel;
   avgSpread = currentSpread; 
   size = TickSample;
   ArrayResize( spreadSize, size ); 
   ArrayFill( spreadSize, 0, size, avgSpread );
   maxSpread = NormalizeDouble( MaxSpread * Point, Digits ); 
   rateTrigger = NormalizeDouble( ( double ) VelocityTrigger * Point, Digits );
   testerStartDate = StringConcatenate( Year(), "-", Month(), "-", Day() );
   initialBalance = AccountBalance();  
   gmt = offlineGMT();
   display();
   return ( 0 );
} 

int offlineGMT(){
   int bkrH = Hour();
   int gOffset =  bkrH - GMTOffset; 
   if( gOffset < 0 ) gOffset += 24;
   else if( gOffset > 23 ) gOffset -= 24;
   return ( gOffset );
}

void commission(){ 
   if( !IsTesting() ){ 
      double rate = 0;
      for( int pos = OrdersHistoryTotal() - 1; pos >= 0; pos-- ) {
         if( OrderSelect( pos, SELECT_BY_POS, MODE_HISTORY ) ) {
            if( OrderProfit() != 0.0 ) {
               if( OrderClosePrice() != OrderOpenPrice() ) {
                  if( OrderSymbol() == Symbol() ) {
                     calculateCommission = false;
                     rate = MathAbs( OrderProfit() / MathAbs( OrderClosePrice() - OrderOpenPrice() ) );
                     commissionPoints = ( -OrderCommission() ) / rate;
                     break;
                  }
               }
            }
         }
      } 
   }
}

int start() {   
   int totalBuyStop = 0;
   int totalSellStop = 0;  
   int ticket;  
   int totalTrades = 0;
   int accountTrades = 0; 
   double accountEquity;
   if( calculateCommission ) commission();
   gmt = offlineGMT();
   prepareSpread();
   manageTicks();   
   
   for( int pos = 0; pos < OrdersTotal(); pos++ ) {
      r = OrderSelect( pos, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() != Symbol() ) continue;   
      accountTrades++;
      if( OrderMagicNumber() == MagicNumber ){ 
         totalTrades++;
         switch ( OrderType() ) {
            case OP_BUYSTOP:
               if( (int) TimeCurrent() - lastBuyOrder > VelocityTime )
                  r = OrderDelete( OrderTicket() );
               totalBuyStop++; 
            break;
            case OP_SELLSTOP:
               if( (int) TimeCurrent() - lastSellOrder > VelocityTime )
                  r = OrderDelete( OrderTicket() );
               totalSellStop++; 
            break;
            case OP_BUY:     
               accountEquity = AccountBalance() + OrderProfit() + OrderCommission() + OrderSwap(); 
               if( Bid - OrderOpenPrice() > ( Trailing * Point ) + commissionPoints + ( Profit * Point ) ){  
                  if( OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > Trailing * Point )
                     if( NormalizeDouble( Bid - ( Trailing * Point ), Digits ) != OrderStopLoss() )
                        r = OrderModify( OrderTicket(), OrderOpenPrice(), NormalizeDouble( Bid - ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );                  
               } else {
                  if( accountEquity > max || accountEquity / AccountBalance() < ( ( double ) 100 - MaxDrawdown ) / 100 ){
                     if( Bid < OrderOpenPrice() - ( VelocityTrigger * Point ) )
                        if( OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > ( Trailing * Point * Trailing ) )
                           if( NormalizeDouble( Bid - ( Trailing * Point ), Digits ) != OrderStopLoss() )
                              r = OrderModify( OrderTicket(), OrderOpenPrice(), NormalizeDouble( Bid - ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 ); 
                  }
               } 
            break;
            case OP_SELL:     
               accountEquity = AccountBalance() + OrderProfit() + OrderCommission() + OrderSwap();
               if( OrderOpenPrice() - Ask > ( Trailing * Point ) + commissionPoints + ( Profit * Point ) ){  
                  if( OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > Trailing * Point ) 
                     if( NormalizeDouble( Ask + ( Trailing * Point ), Digits ) != OrderStopLoss() )
                        r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble( Ask + ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );                    
               } else {
                  if( accountEquity > max || accountEquity / AccountBalance() < ( ( double ) 100 - MaxDrawdown ) / 100 ){
                     if( Ask > OrderOpenPrice() + ( VelocityTrigger * Point ) )
                        if( OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > ( Trailing * Point * Trailing ) ) 
                           if( NormalizeDouble( Ask + ( Trailing * Point ), Digits ) != OrderStopLoss() )
                              r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble( Ask + ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );
                  }
               } 
            break;  
         }  
      }
   }    
     
   if( totalTrades == 0 && accountTrades == 0 ){
      
     
      if( rateChange > VelocityTrigger * Point && avgSpread <= maxSpread && totalBuyStop < 1 ) { 
         ticket = OrderSend( Symbol(), OP_BUYSTOP, lotSize(), Ask + ( totalBuyStop + 1.0 ) * ( Point * Offset ), Slippage, 0, 0, TradeComment, MagicNumber, 0 );
         lastBuyOrder = ( int ) TimeCurrent();
      } 
      if( rateChange < -VelocityTrigger * Point && avgSpread <= maxSpread && totalSellStop < 1 ) { 
         ticket = OrderSend(Symbol(), OP_SELLSTOP, lotSize(), Bid - ( totalSellStop + 1.0 ) * ( Point * Offset ), Slippage, 0, 0, TradeComment, MagicNumber, 0 );
         lastSellOrder = ( int ) TimeCurrent();
      }    
      
         
   }
    
   display(); 
   return ( 0 );
} 

double lotSize(){  
   if( FixedLot > 0 ){
      lotSize = NormalizeDouble( FixedLot, 2 );
   } else {
      if( marginRequirement > 0 ) 
         lotSize = MathMax( MathMin( NormalizeDouble( ( AccountBalance() * ( ( double ) RiskPercent / 1000 ) * 0.01 / marginRequirement ), 2 ), maxLot ), minLot );    
   }  
   return ( NormalizeLots( lotSize ) ); 
}  

double NormalizeLots( double p ){
    double ls = MarketInfo( Symbol(), MODE_LOTSTEP );
    return( MathRound( p / ls ) * ls );
}

void prepareSpread(){
   if( !IsTesting() ){  
      double spreadSize_temp[];
      ArrayResize( spreadSize_temp, size - 1 );
      ArrayCopy( spreadSize_temp, spreadSize, 0, 1, size - 1 );
      ArrayResize( spreadSize_temp, size ); 
      spreadSize_temp[size-1] = NormalizeDouble( Ask - Bid, Digits ); 
      ArrayCopy( spreadSize, spreadSize_temp, 0, 0 ); 
      avgSpread = iMAOnArray( spreadSize, size, size, 0, MODE_LWMA, 0 );  
   }
}       

void manageTicks(){    
   double tick_temp[], tickTime_temp[], avgtick_temp[];
   ArrayResize( tick_temp, size - 1 );
   ArrayResize( tickTime_temp, size - 1 );
   ArrayCopy( tick_temp, tick, 0, 1, size - 1 ); 
   ArrayCopy( tickTime_temp, tickTime, 0, 1, size - 1 ); 
   ArrayResize( tick_temp, size ); 
   ArrayResize( tickTime_temp, size );
   tick_temp[size-1] = Bid;
   tickTime_temp[size-1] = ( int ) TimeCurrent();
   ArrayCopy( tick, tick_temp, 0, 0 );    
   ArrayCopy( tickTime, tickTime_temp, 0, 0 ); 
   int timeNow = tickTime[size-1];
   double priceNow = tick[size-1];
   double priceThen = 0;   
   int period = 0;
   for( int i = size - 1; i >= 0; i-- ){ 
      period++;
      if( timeNow - tickTime[i] > VelocityTime ){
         priceThen = tick[i]; 
         break;
      }  
   }     
    
   rateChange = ( priceNow - priceThen );
   if( rateChange / Point > 5000 ) rateChange = 0;     
} 

string niceHour( int kgmt ){ 
   string m;
   if( kgmt > 12 ) {
      kgmt = kgmt - 12;
      m = "PM"; 
   } else {
      m = "AM";
      if( kgmt == 12 )
         m = "PM";
   }
   return ( StringConcatenate( kgmt, m ) );
} 

void display(){  
    if( !IsTesting() ){ 
      string display = "  Ascal v1.04\n"; 
      display = StringConcatenate( display, " ----------------------------------------\n" );
      display = StringConcatenate( display, "  Leverage: ", DoubleToStr( AccountLeverage(), 0 ), " Lots: ", DoubleToStr( lotSize, 2 ), ", \n" ); 
      display = StringConcatenate( display, "  Avg. Spread: ", DoubleToStr( avgSpread / Point, 0 ), " of ", MaxSpread, ", \n" ); 
      display = StringConcatenate( display, "  Commission: ", DoubleToStr( commissionPoints / Point, 0 ), " \n" ); 
      display = StringConcatenate( display, "  GMT Now: ", niceHour( gmt ), " \n" ); 
      display = StringConcatenate( display, " ----------------------------------------\n" );
      display = StringConcatenate( display, "  Set: ", TradeComment, " \n" ); 
      display = StringConcatenate( display, " ----------------------------------------\n" );    
      Comment( display ); 
  }
} 