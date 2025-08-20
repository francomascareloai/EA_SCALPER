//+------------------------------------------------------------------+
//|sltp-currency.mq4                                                 |
//|Desmond Wright aka " Buju"                                        |
//|notes:                                                            |
// this EA will use the deposit currency as stop loss and take profit|
// for each trade. It does NOT use pips to measure values.           |
// Once profit or loss has been reached it will close the entire trade|
//                                                                   |
//+------------------------------------------------------------------+
#property copyright "Desmond Wright aka  Buju"
#property link      ""

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
extern double stop_loss=8;     // stop loss input in currency    
extern double take_profit=5;   // take profit input in currency
int i;
int ticket;
  
int start()  {                 //start of prog


if(OrdersTotal() !=0) // if total orders are not zero
{
int total = OrdersTotal(); // the word total represents total orders

for(i = total - 1; i >= 0; i--)// count each order backwards
{
OrderSelect(i, SELECT_BY_POS, MODE_TRADES); //select each order by postiton

if(OrderSymbol() != Symbol()) continue; //if it is not equal to our symbol, skip it

if((OrderType() == OP_BUY) || (OrderType() == OP_SELL))
{

//----- order profit -----------------
if(OrderProfit() >= (take_profit))  // OrderProfit is measured in the deposit currency - not pips
OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
}
{
//----- end order profit -----------------

//----- order stop -----------------
if(OrderProfit() <= -(stop_loss))
OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
//----- end order stop -----------------

Comment ("Take Profit " ,take_profit ," Stop Loss " ,stop_loss);
}
}
}
}



