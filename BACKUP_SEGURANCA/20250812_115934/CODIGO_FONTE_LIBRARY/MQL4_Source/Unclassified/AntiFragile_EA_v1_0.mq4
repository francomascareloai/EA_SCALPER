//+------------------------------------------------------------------+
//|                                               AntiFragile EA.mq4 |
//|                                         Copyright 2013, Mt-Coder |
//|                                             mt-coderÿhotmail.com |
//|                                                                  |
//|                 For your programming projects                    |
//|          Don't hesitate to contact me ÿ                          |
//|                            mt-coderÿhotmail.com                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2013, Mt-Coder"
#property link      "mailto:mt-coder@hotmail.com"

extern double     StartingLot = 0.1;
extern double     IncreasePercentage = 1;
extern int        SpaceBetweenTrades = 700;
extern int        NumberOfTrades = 50;
extern int        StopLoss = 300;
extern int        TrailingStop = 100;
extern bool        TradeLong = true;
extern bool        TradeShort = true;
extern int         Magic = 11235;

//---------
int     POS_n_BUY;
int     POS_n_SELL;
int     POS_n_BUYLIMIT;
int     POS_n_SELLLIMIT;
int     POS_n_total;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   string DisplayText = "\n" +  "______ AntiFragile EA ______\n" + 
   "Coded By: MT-Coder\n" + 
   "** MT-Coderÿhotmail.com **\n" ;
   
   Comment(DisplayText);

   int i ;
   double TradedLot;
   double TradedBLevel;
   double TradedSLevel;
   int ticketB;
   int ticketS;
   int total;
   int cnt;
   
   //-------
   count_position();
   //-------
   if(POS_n_BUYLIMIT == 0){DeleteSellLimit();}
   if(POS_n_SELLLIMIT == 0){DeleteBuyLimit();}
   //-------
   // place orders
   //-------
   
   if(POS_n_BUYLIMIT + POS_n_SELLLIMIT == 0)
   {

      for(i=1;i<=NumberOfTrades;i++)
      {
      RefreshRates();
      
      TradedLot = NormalizeDouble(StartingLot*(1+((i-1)*(IncreasePercentage/100))),2);
      TradedBLevel = NormalizeDouble(Bid - ((SpaceBetweenTrades * i)*Point),Digits);
      TradedSLevel = NormalizeDouble(Ask + ((SpaceBetweenTrades * i)*Point),Digits);
            
         if(TradeLong) 
         {
         ticketB=OrderSend(Symbol(),OP_BUYLIMIT,TradedLot,TradedBLevel,1,TradedBLevel-StopLoss*Point,0,"AF EA",Magic,0,Green);
            if(ticketB>0)
           {
            if(OrderSelect(ticketB,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY LIMIT order sent : ",OrderOpenPrice());
           }
            else 
            {
             Print("Error sending BUY LIMIT order : ",GetLastError()); 
            }
         }
        
        //---------------
         if(TradeShort) 
         {
     
         ticketS=OrderSend(Symbol(),OP_SELLLIMIT,TradedLot,TradedSLevel,1,TradedSLevel+StopLoss*Point,0,"AF EA",Magic,0,Red);
            if(ticketS>0)
           {
            if(OrderSelect(ticketS,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLLIMIT order sent : ",OrderOpenPrice());
           }
            else 
            {
             Print("Error sending SELLLIMIT order : ",GetLastError()); 
            }
         }      
      }
 }     
      //trailing stop
      
       total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // check for trailing stop
            if(TrailingStop>0)  
              {                 
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else // go to short position
           {
            // check for trailing stop
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
       }
      
 
   return(0);
}

//-----
void count_position()
{
    POS_n_BUY  = 0;
    POS_n_SELL = 0;
    
    POS_n_BUYLIMIT = 0;
    POS_n_SELLLIMIT = 0;
    
    for( int i = 0 ; i < OrdersTotal() ; i++ ){
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false || OrderMagicNumber() != Magic){
            break;
        }
        if( OrderType() == OP_BUY  && OrderSymbol() == Symbol() && OrderMagicNumber()==Magic){
            POS_n_BUY++;
        }
        else if( OrderType() == OP_SELL  && OrderSymbol() == Symbol() && OrderMagicNumber()==Magic){
            POS_n_SELL++;
        }
        else if( OrderType() == OP_BUYLIMIT  && OrderSymbol() == Symbol() && OrderMagicNumber()==Magic){
            POS_n_BUYLIMIT++;
        }
        else if( OrderType() == OP_SELLLIMIT  && OrderSymbol() == Symbol() && OrderMagicNumber()==Magic){
            POS_n_SELLLIMIT++;
        }
        
    }
    POS_n_total = POS_n_BUY + POS_n_SELL + POS_n_BUYLIMIT + POS_n_SELLLIMIT;
}
//-------
void DeleteBuyLimit()
{
int cnt, total;
total=OrdersTotal();
  for(cnt=total-1;cnt>=0;cnt--)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() != Magic || OrderType()!=OP_BUYLIMIT) break;
      
      if( OrderSymbol() == Symbol())  OrderDelete(OrderTicket());
      
     }
}
//-------
void DeleteSellLimit()
{
int cnt, total;
total=OrdersTotal();
  for(cnt=total-1;cnt>=0;cnt--)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() != Magic || OrderType()!=OP_SELLLIMIT) break;
      
if( OrderSymbol() == Symbol())  OrderDelete(OrderTicket());      
     }
}
//+------------------------------------------------------------------+