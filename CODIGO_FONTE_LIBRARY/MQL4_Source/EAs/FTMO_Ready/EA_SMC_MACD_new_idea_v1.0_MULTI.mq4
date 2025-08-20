//+------------------------------------------------------------------+
//|                                                           SMC.mq4 
//|                                                                  +
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double Lots = 0.1; 

 extern int    TakeProfit = 100;
 extern double RiskPercent = 1;
 extern int    SignalLifeBars =24;
 extern int    PVoffset = 2;
 
 bool   BuySignal,SellSignal;
 string  LastOrder;
 string  Trend;
 datetime BarTime;
//#####################################################################
int init()
{
//----
LastOrder="xxxx";
//----
   return(0);
  }
//#############################################################################

int start()
  {
   double SL,TP,Spread, ATR, MinDist,MaxRisk;

   double PSARP0,PSARP1;
   double VSMAP0,VSMAP1,SMAP1,MMAP1,LMAP1,VLMAP1,VSMAP1Low,VSMAP1High;

   string MaxRiskStr;
   string Trading;

   bool   Buy,Sell;

   int    total,ticket,err,tmp,cnt;
   int    NumberofPositions;

  if(Bars<100){Print("bars less than 100"); return(0); }
   
//################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);
 Spread=(Ask-Bid);
 MaxRisk=(AccountFreeMargin()*RiskPercent/100)*Point;
 MaxRiskStr=DoubleToStr(MaxRisk,4);

//~~~~~~~~~~~~~~~~~~INDICATOR CALCULATIONS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double LMACDHP1,LMACDSP1,SMACDHP1,SMACDSP1;
double LMACDHP2,LMACDSP2,SMACDHP2,SMACDSP2;

LMACDHP1=iMACD(NULL,0,89,144,22,PRICE_CLOSE,MODE_MAIN,1);
LMACDSP1=iMACD(NULL,0,89,144,22,PRICE_CLOSE,MODE_SIGNAL,1);
LMACDHP2=iMACD(NULL,0,89,144,22,PRICE_CLOSE,MODE_MAIN,2);
LMACDSP2=iMACD(NULL,0,89,144,22,PRICE_CLOSE,MODE_SIGNAL,2);

SMACDHP1=iMACD(NULL,0,8,21,5,PRICE_CLOSE,MODE_MAIN,1);
SMACDSP1=iMACD(NULL,0,8,21,5,PRICE_CLOSE,MODE_SIGNAL,1);
SMACDHP2=iMACD(NULL,0,8,21,5,PRICE_CLOSE,MODE_MAIN,2);
SMACDSP2=iMACD(NULL,0,8,21,5,PRICE_CLOSE,MODE_SIGNAL,2);

PSARP1=iSAR(NULL,0,0.02,0.2,1);

 if(BarTime == Time[0]) {return(0);}
 BarTime = Time[0];

//##############################################################################
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
//BUY and SELL rules:
//~~~~~~~~~~~~BUY~~~~~~~~~~~~~~~~~~~~~~~~
SL=0;
TP=0;
 if((LMACDHP1>0&&LMACDHP1>LMACDSP1&&SMACDHP2<SMACDSP2&&SMACDHP1>SMACDSP1)//Long Term UP new Short term signal
     ||
    (LMACDHP2<0&&LMACDHP1>0)  //Long trend changes
     ||
    (LMACDHP1>0&&LMACDHP1>LMACDSP1&&SMACDHP2<0&&SMACDHP1>0))  //Long term trend UP and Short term change top UP
   {
   Buy = true;
    LastOrder = " Buy ";
    }

//~~~~~~~~~~~SELL~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 if((LMACDHP1<0&&SMACDHP1<0&&LMACDHP1<LMACDSP1&&SMACDHP2>SMACDSP2&&SMACDHP1<SMACDSP1)//Long Term UP new Short term signal
     ||
    (LMACDHP2>0&&LMACDHP1<0)  //Long trend changes
     ||
    (LMACDHP1<0&&LMACDHP1<LMACDSP1&&SMACDHP2>0&&SMACDHP1<0))  //Long term trend UP and Short term change top UP

    {Sell=true;
     LastOrder = " Sell ";
     }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##################################################################################
//~~~~~~~~~~~~~~~~  POSITION MANAGEMENT  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(0==1)
{
total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    { 
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol())    
     { 
      SL=PSARP1;

      if(SL > OrderStopLoss())
      {OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Orange);}
       }}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol())   
     {
      
      SL=PSARP1;

      if(SL != 0)
       {
       if(SL < OrderStopLoss() || OrderStopLoss()==0 )
        {OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Orange);}
       }}}}
}
//##################################################################################
//~~~~~~~~~~~~~~~~  ORDER CLOSURE  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if(0==0)
{
//CLOSE LONG Entries
                                
   total=OrdersTotal();
   if(total>0)
    { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() &&
         LMACDHP1 < LMACDSP1)
       {
        OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); 
   }}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE SHORT ENTRIES: 
 
   total=OrdersTotal();
   if(total>0)
    { 
    for(cnt=0;cnt<total;cnt++)
     {  
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() &&
         LMACDHP1 > LMACDSP1)
       {
        OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
   }}}
}
//##########################################################################################
//##########################################################################################
//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~
//##################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if(AccountFreeMargin()<(1000*Lots))
   {Print("Insufficient funds available. Free Margin = ", AccountFreeMargin());
    return(0);}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 NumberofPositions = 0;
 total=OrdersTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol()==Symbol()) NumberofPositions=NumberofPositions+1;
       }
//may require extra code to determine exposure on any one pair
       if (NumberofPositions >=50) return(0);
   }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//OPEN ORDER: LONG 
 if(Buy==true) 
  {Buy=false;

   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SL,TP,LastOrder,070177,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    { 
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {Print("BUY order opened : ",OrderOpenPrice());
       Alert("Buy Order for ",Symbol());
       SendMail("Buy Order "+Symbol()+" "+Ask,SL);     
       }
     }
     else Print("Error opening BUY order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//OPEN ORDER: SHORT                                   
 if(Sell==true) 
  {Sell=false;

   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SL,TP,"Flying Knives" + LastOrder,070177,0,Red);
   if(ticket>0)
    {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
       {Print("SELL order opened : ",OrderOpenPrice());
        Alert("Sell Order for ",Symbol());
        SendMail("Sell Order "+Symbol()+" "+Bid,Bid); 
        }
      }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
   }

//############               End of PROGRAM                  #########################   
   return(0);
}
//####################################################################################

