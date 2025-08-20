/*[[
        Name := Robot_PowerM5_demo
        Author := MT
        Link := http://www.metexinvest.com/
        Notes := M5 for all majors
        Lots := 1.00
        Stop Loss := 45
        Take Profit := 150
        Trailing Stop := 15
]]*/

extern double slippage=20,mm=1,risk=7.5,Lot=0.1,StopLoss=45,TakeProfit=150, TrailingStop=15;

int start()
  {

double bull=0,bear=0,sl=0,tp=0,cnt=0,b=0,s=0,Opentrades=0,lotsi=0,ITB=0,ITS=0,total=0;



ITB=iCustom(NULL,0,"iTrend",2,0,0,20,0,14,0,0,1);

ITS=iCustom(NULL,0,"iTrend",2,0,0,20,0,14,0,1,1);

bull = iBullsPower(NULL,0,5,PRICE_CLOSE,1);
bear = iBearsPower(NULL,0,5,PRICE_CLOSE,1);
Comment("bull+bear= ",bull + bear,"\n I Blue ",ITB,"\n I Red ",ITS);

//////////////////////////////////////////////////
///////////// Manage multiple trades ///////////// 
//////////////////////////////////////////////////

Opentrades=0;

total=OrdersTotal();
for(cnt=0;cnt<total;cnt++)
{ 
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() ) Opentrades = Opentrades+1;  
}

//////////////////////////////////////////////////
///////////// Money Manager ///////////// 
//////////////////////////////////////////////////

if (mm != 0) 
        lotsi=MathCeil(AccountBalance()*risk/10000)/10;
else
        lotsi=Lot;
        



if (Opentrades == 0) 
   {
   if ((bull + bear > 0) && (ITB == 1) && (ITS == 0)) 
      {
      sl = Ask - StopLoss * Point;
      tp = Bid + TakeProfit * Point;
      OrderSend(Symbol(),OP_BUY,lotsi,Ask,slippage,sl,tp,0,0,Blue);
      }
   if ((bull + bear < 0) && (ITS == -1) && (ITB == 0))
      {
      sl = Bid + StopLoss * Point;
      tp = Ask - TakeProfit * Point;
      OrderSend(Symbol(),OP_SELL,lotsi,Bid,slippage,sl,tp,0,0,Red);
      }
   }


b = 1 * Point + iATR(NULL,0,5,1) * 1.5;
s = 1 * Point + iATR(NULL,0,5,1) * 1.5;


total=OrdersTotal();
for(cnt=0;cnt<total;cnt++)
{

OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ((OrderType()== OP_BUY) && (OrderSymbol()== Symbol())) 
         {
         if ((OrderOpenPrice() > OrderStopLoss()) && (Bid-OrderOpenPrice() > StopLoss*Point))   
            { 
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,SlateBlue);
            return(0);
            }
         if ((Bid - OrderOpenPrice()) > b )
            { 
            if ((OrderStopLoss()) < (Bid -b))  
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid - b,OrderTakeProfit(),0,SlateBlue);
               return(0);
               }
            }
         }
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ((OrderType()== OP_SELL) && (OrderSymbol()== Symbol()))          
         {
         if ((OrderOpenPrice() < OrderStopLoss()) && (OrderOpenPrice()-Ask > StopLoss*Point)) 
            {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
            return(0);
            }
         if ((OrderOpenPrice()-Ask ) > s )
            { 
            if ((OrderStopLoss()) > (Ask + s))
            {
            OrderModify(OrderTicket(),OrderOpenPrice(),Ask + s,OrderTakeProfit(),0,Red);
            return(0);
            }  
         }
       } 
  
    
}
}