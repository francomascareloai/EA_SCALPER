extern double TakeProfit = 25;
extern double Lots = 0.1;
extern double TrailingStop = 15;
extern double StopLoss = 4;
extern double MM = 1;
extern double Risk = 0.2;
extern double LotLimit = 100;
extern double Per = 10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  
  
double s=GlobalVariableGet("SELLLIMIT");
double b=GlobalVariableGet("BUYLIMIT");
double ds=GlobalVariableGet("DateS");
double db=GlobalVariableGet("DateB");

if (ds != DayOfWeek())
{
GlobalVariableDel("SELLLIMIT");
GlobalVariableDel("BUYLIMIT");
GlobalVariableDel("DatesS");
GlobalVariableDel("DatesB");
}


 double H3,H4,L3,L4,SH4,SH3,BL3,BL4;
 
 if ( OrdersTotal() < 1 && Hour() == 23 && Minute() == 59 ) return(0);
 if ( OrdersTotal() > 0 && Hour() == 23 && Minute() == 59 ) {
 
 int total = OrdersTotal();
 for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;

      //Close pending orders
      case OP_BUYLIMIT  :
      case OP_BUYSTOP   :
      case OP_SELLLIMIT :
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  }
 
 H4= ((((High[1]-Low[1])*1.1)/2)+Close[1]);
 H3= ((((High[1]-Low[1])*1.1)/4)+Close[1]);
 
 L3= (Close[1]-((High[1]-Low[1])*1.1)/4);
 L4= (Close[1]-((High[1]-Low[1])*1.1)/2);


if (db != DayOfWeek() && s == 0) {


SH3 = OrderSend(Symbol(),OP_SELLLIMIT,Lots,H4,3,H4+StopLoss*Point,H4-TakeProfit*Point,"H3",0,0,Red);
if (SH3 < 0){
          GlobalVariableSet("SELLLIMIT",0);
          
          }
        else 
          {
          GlobalVariableSet("SELLLIMIT",1);
          GlobalVariableSet("DateS",DayOfWeek());   
          
           }
           }
           

//SH4 = OrderSend(Symbol(),OP_SELLLIMIT,Lots,H4,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"H4",0,0,Red);           
                      
           


if (db != DayOfWeek() && b == 0) {
BL3 = OrderSend(Symbol(),OP_BUYLIMIT,Lots,L4,3,L4-StopLoss*Point,L4+TakeProfit*Point,"L3",0,0,Green);  
if (BL3 < 0){
          GlobalVariableSet("BUYLIMIT",0);
          
          }
        else 
          {
          GlobalVariableSet("BUYLIMIT",1);
          GlobalVariableSet("DateB",DayOfWeek());   
          
           }
           }
           
//BL4 = OrderSend(Symbol(),OP_BUYLIMIT,Lots,L4,3,Ask+StopLoss*Point,Bid-TakeProfit*Point,"L4",0,0,Green);    

}