//*********************
int ActNumber=0;
datetime ExpDate=D'23.12.2025';
//*********************



#property copyright "Copyright travone"
#property link "https://www.mql5.com/en/users" 
#property strict
#property version "3.05"

enum manager {
   P=0, // Primary
   B=1, // Secondary
}; 

extern manager TradeManager = 0;
extern string TradeComment = "iFX NET"; 
extern int MagicNumber = 33431; 
extern int MaxTrades=1;//Max obchodu
extern int Slippage = 3;
extern int MaxSpread = 110;
extern double FixedLot = 0;
extern int RiskPercent = 2; 
extern int MaxDrawdown = 90;
extern double MaxLoss=500;//Max ztrata za den
extern int SL=0;
extern int StartHour = 2; 
extern int EndHour = 22;
extern int GMTOffset = 0;
extern int TradeDeviation = 2;  
extern int TradeDelta = 12;
extern int Trailing = 3;  
extern int StartTrailing = 4;  
extern int VelocityTrigger = 70; 
extern int VelocityTime = 7;  
 int DeleteRatio = 0;  

int OrderExpiry = 0; 
extern int TickSample = 100;  

int r, gmt, brokerOffset, size, digits, stoplevel;

double marginRequirement, maxLot, minLot, lotSize, points, currentSpread, avgSpread, maxSpread, initialBalance, rateChange, rateTrigger, deleteRatio, commissionPoints;

double spreadSize[]; 
double tick[];
double avgtick[];
int tickTime[];   

string testerStartDate, testerEndDate; 

int lastBuyOrder, lastSellOrder;

bool calculateCommission = true;
bool closing;
double max = 0;

int init() {   
   marginRequirement = MarketInfo( Symbol(), MODE_MARGINREQUIRED ) * 0.01;
   maxLot = ( double ) MarketInfo( Symbol(), MODE_MAXLOT );  
   minLot = ( double ) MarketInfo( Symbol(), MODE_MINLOT );  
   currentSpread = NormalizeDouble( Ask - Bid, Digits ); 
   stoplevel = ( int ) MathMax( MarketInfo( Symbol(), MODE_FREEZELEVEL ), MarketInfo( Symbol(), MODE_STOPLEVEL ) );
   if( stoplevel > TradeDelta ) TradeDelta = stoplevel;
   if( stoplevel > Trailing ) Trailing = stoplevel;
   avgSpread = currentSpread; 
   size = TickSample;
   ArrayResize( spreadSize, size ); 
   ArrayFill( spreadSize, 0, size, avgSpread );
   maxSpread = NormalizeDouble( MaxSpread * Point, Digits );
   deleteRatio = NormalizeDouble( ( double ) DeleteRatio / 100, 2 );
   rateTrigger = NormalizeDouble( ( double ) VelocityTrigger * Point, Digits );
   testerStartDate = StringConcatenate( Year(), "-", Month(), "-", Day() );
   initialBalance = AccountBalance();  
   display();
   closing=false;
   return ( 0 );
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
int offlineGMT(){
   int bkrH = Hour();
   int gOffset =  bkrH - GMTOffset; 
   if( gOffset < 0 ) gOffset += 24;
   else if( gOffset > 23 ) gOffset -= 24;
   return ( gOffset );
}

int start() {   
   int totalBuyStop = 0;
   int totalSellStop = 0;  
   int ticket,pos;  
   int totalTrades = 0;
   int totalUnprotected = 0;
   double accountEquity,stop,cena,profdnes=0;
   if( calculateCommission ) commission();
   gmt = offlineGMT();
   prepareSpread();
   manageTicks();  
   
   if (MaxLoss!=0 && OrdersHistoryTotal()>0)
    {
     for( pos = 0; pos < OrdersHistoryTotal(); pos++ )
      {
       r = OrderSelect( pos, SELECT_BY_POS, MODE_HISTORY );
       if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderCloseTime()>=iTime(Symbol(),PERIOD_D1,0)) profdnes+=OrderProfit() + OrderCommission() + OrderSwap();
      }
    }
  
   if (!IsTesting() && !IsOptimization() && AccountNumber()!=ActNumber && ActNumber>0) {Comment("\n !! INVALID ACCOUNT NUMBER !!\n !! TRADING IS NOT ALLOWED !!");return(0);}
   if(ExpDate>0 && TimeCurrent()>=ExpDate) {Comment("\n*** LICENSE EXPIRED ***");return(0);}

   
   for(pos = OrdersTotal()-1; pos >=0; pos-- )
    {
      r = OrderSelect( pos, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() != Symbol() ) continue;   
      if( OrderMagicNumber() == MagicNumber ){ 
         totalTrades++;
         profdnes+=OrderProfit() + OrderCommission() + OrderSwap();
         switch ( OrderType() ) {
            case OP_BUYSTOP:
               if( (int) TimeCurrent() - lastBuyOrder > VelocityTime )
                  r = OrderDelete( OrderTicket() );
               totalBuyStop++;
               totalUnprotected++;
            break;
            case OP_SELLSTOP:
               if( (int) TimeCurrent() - lastSellOrder > VelocityTime )
                  r = OrderDelete( OrderTicket() );
               totalSellStop++;
               totalUnprotected++;
            break;
            case OP_BUY:    
               accountEquity = AccountBalance() + OrderProfit() + OrderCommission() + OrderSwap(); 
               if( OrderStopLoss() == 0 || ( OrderStopLoss() > 0 && OrderStopLoss() < OrderOpenPrice() ) ) totalUnprotected++;
               if( Bid - OrderOpenPrice() > ( Trailing * Point ) + ( StartTrailing * Point ) + commissionPoints ){  
                  if( OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > Trailing * Point )
                     if( NormalizeDouble( Bid - ( Trailing * Point ), Digits ) != OrderStopLoss() )
                        r = OrderModify( OrderTicket(), OrderOpenPrice(), NormalizeDouble( Bid - ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );                  
               } else {
                  if( accountEquity > max || accountEquity / AccountBalance() < ( double ) MaxDrawdown / 100 ){
                     if( Bid < OrderOpenPrice() - ( VelocityTrigger * Point ) )
                        if( OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > ( Trailing * Point ) )
                           if( NormalizeDouble( Bid - ( Trailing * Point ), Digits ) != OrderStopLoss() )
                              r = OrderModify( OrderTicket(), OrderOpenPrice(), NormalizeDouble( Bid - ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 ); 
                  }
               } 
            break;
            case OP_SELL:    
               accountEquity = AccountBalance() + OrderProfit() + OrderCommission() + OrderSwap();
               if( OrderStopLoss() == 0 || ( OrderStopLoss() > 0 && OrderStopLoss() > OrderOpenPrice() ) ) totalUnprotected++;
               if( OrderOpenPrice() - Ask > ( Trailing * Point ) + ( StartTrailing * Point ) + commissionPoints ){  
                  if( OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > Trailing * Point ) 
                     if( NormalizeDouble( Ask + ( Trailing * Point ), Digits ) != OrderStopLoss() )
                        r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble( Ask + ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );                    
               } else {
                  if( accountEquity > max || accountEquity / AccountBalance() < ( double ) MaxDrawdown / 100 ){
                     if( Ask > OrderOpenPrice() + ( VelocityTrigger * Point ) )
                        if( OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > ( Trailing * Point ) ) 
                           if( NormalizeDouble( Ask + ( Trailing * Point ), Digits ) != OrderStopLoss() )
                              r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble( Ask + ( Trailing * Point ), Digits ), OrderTakeProfit(), 0 );
                  }
               } 
            break;
         }  
      }
   }  
   
   
   if( totalTrades == 0 )
   {
      closing=false;
      if( AccountBalance() > max ) max = AccountBalance();
   }
    
  if (MaxLoss!=0 && (closing || profdnes<=MathAbs(MaxLoss)*-1) && OrdersTotal()>0) 
   {
    Print("*** Dosazena denni ztrata ...");
    closing=true;
    for(pos=OrdersTotal()-1;pos>=0;pos--)
    {
     r=OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
      {
       if (OrderType()==OP_BUY) r=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrYellow);
       if (OrderType()==OP_SELL) r=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrYellow);
       if (OrderType()!=OP_SELL && OrderType()!=OP_BUY) r=OrderDelete(OrderTicket(),clrYellow);

      }
     }
    return(0); 
   } 
   
   if (!IsTesting() && !IsOptimization() && AccountNumber()!=ActNumber && ActNumber>0) {Comment("\n !! INVALID ACCOUNT NUMBER !!\n !! TRADING IS NOT ALLOWED !!");return(0);}
   if(ExpDate>0 && TimeCurrent()>=ExpDate) {Comment("\n*** LICENSE EXPIRED ***");return(0);}

   if( TradeManager == 0 && totalTrades<MaxTrades && (MaxLoss==0 || profdnes>MathAbs(MaxLoss)*-1)) { 
      if( ( ( StartHour < EndHour && gmt >= StartHour && gmt <= EndHour ) 
      || ( StartHour > EndHour && ( ( gmt <= EndHour && gmt >= 0 ) 
      || ( gmt <= 23 && gmt >= StartHour ) ) ) ) 
      ){ 
         if( totalUnprotected < TradeDeviation ){
            if( rateChange > VelocityTrigger * Point && avgSpread <= maxSpread && totalBuyStop < TradeDeviation )
             { 
               cena=Ask + ( totalBuyStop + 1.0 ) * ( Point * TradeDelta );
               if (SL>0) stop=cena-SL*Point; else stop=0;
               ticket = OrderSend( Symbol(), OP_BUYSTOP, lotSize(), NormalizeDouble(cena,Digits), Slippage, NormalizeDouble(stop,Digits), 0, TradeComment, MagicNumber, 0 );
               lastBuyOrder = ( int ) TimeCurrent();
             } 
            if( rateChange < -VelocityTrigger * Point && avgSpread <= maxSpread && totalSellStop < TradeDeviation )
             { 
               cena= Bid - ( totalSellStop + 1.0 ) * ( Point * TradeDelta );
               if (SL>0) stop=cena+SL*Point; else stop=0;
               ticket = OrderSend(Symbol(), OP_SELLSTOP, lotSize(),NormalizeDouble(cena,Digits) , Slippage, NormalizeDouble(stop,Digits), 0, TradeComment, MagicNumber, 0 );
               lastSellOrder = ( int ) TimeCurrent();
             }    
         }
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
      string display = "  iFX NET 09.19\n";
      display = StringConcatenate( display, " ----------------------------------------\n" );
      if( TradeManager == 0 )
         display = StringConcatenate( display, "  TradeManager: Primary\n" );
      else 
         display = StringConcatenate( display, "  TradeManager: Secondary\n" ); 
      display = StringConcatenate( display, " ----------------------------------------\n" );
      display = StringConcatenate( display, "  Leverage: ", DoubleToStr( AccountLeverage(), 0 ), " Lots: ", DoubleToStr( lotSize, 2 ), ", \n" ); 
      display = StringConcatenate( display, "  Avg. Spread: ", DoubleToStr( avgSpread / Point, 0 ), " of ", MaxSpread, ", \n" ); 
      display = StringConcatenate( display, "  Commission: ", DoubleToStr( commissionPoints / Point, 0 ), " \n" ); 
      display = StringConcatenate( display, "  GMT Now: ", niceHour( gmt ), " \n" ); 
      display = StringConcatenate( display, " ----------------------------------------\n" );
      display = StringConcatenate( display, "  Set: ", TradeComment, " \n" ); 
      display = StringConcatenate( display, " ----------------------------------------\n" );   
      display = StringConcatenate( display, "  Velocity: ", DoubleToStr( rateChange / Point, 0 ), " \n" ); 
      Comment( display ); 
  }
} 