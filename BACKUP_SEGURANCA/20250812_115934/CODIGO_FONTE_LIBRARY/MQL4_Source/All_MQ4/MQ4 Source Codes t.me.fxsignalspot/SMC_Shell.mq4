//+------------------------------------------------------------------+
//|                                                           SMC.mq4 
//|                                                                  +
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double Lots = 0.1; 
 extern int    LotsMultiplier=2;

 extern int    SMALength=21;
 extern int    MMALength=34;
 extern int    LMALength=55;

 extern int    ProtectProfit = 5;
 extern int    TrailingStop = 5;
 extern int    TakeProfit = 25;
 extern double RiskPercent = 1;
 
 string  LastOrder;
 string  Trend;
 datetime BarTime;
//#####################################################################
int init()
{
//----

LastOrder= " ";


//----
   return(0);
  }
//#############################################################################

int start()
  {
   double SL,TP,Spread, ATR, MinDist,MaxRisk;
   double VSMAP0,VSMAP1,SMAP1,MMAP1,LMAP1,VLMAP1,VSMAP1Low,VSMAP1High;

   string MaxRiskStr;

   bool   CloseLongs,CloseShorts;
   bool   Buy,Sell;

   int    total,ticket,err,tmp,cnt;
   int    NumberofPositions;
   int    BuyLots;

  if(Bars<100){Print("bars less than 100"); return(0); }
   
//################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);
 Spread=(Ask-Bid);
 MaxRisk=(AccountFreeMargin()*RiskPercent/100)*Point;
 MaxRiskStr=DoubleToStr(MaxRisk,4);

//#############################################################################
//~~~~~~~~~~~~~~~~~~INDICATOR CALCULATIONS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SMAP1 = iMA(NULL,0,SMALength,0,MODE_SMA,PRICE_CLOSE,0);
MMAP1 = iMA(NULL,0,MMALength,0,MODE_SMA,PRICE_CLOSE,0);
LMAP1 = iMA(NULL,0,LMALength,0,MODE_SMA,PRICE_CLOSE,0);

//#############################################################################
tmp=0;
err=0;
tmp = ObjectGet("X"+Time[0],6);
err = GetLastError();
 if(err!=0) 
  {ObjectCreate("X"+Time[0],22,0,Time[0],High[1]);
   ObjectSet("X"+Time[0],14,2);
   ObjectSetText("X"+Time[0],TimeToStr(Time[0]));
   ObjectSet("X"+Time[0],6,Gray);
   }

   ObjectDelete("X"+Time[3]);

//###################################################################################
//  TREND Definition
      tmp=0;
      tmp=ObjectGet("Trend",6);
        if(SMAP1 > MMAP1 && MMAP1 > LMAP1 && tmp != Lime) 
         {Trend="UP";
          ObjectDelete("Trend");
          ObjectCreate("Trend",22,1,Time[0],50);
          ObjectSet("Trend",6,Lime);
          ObjectSet("Trend",14,241);
          }
      
        if(SMAP1 < MMAP1 && MMAP1 < LMAP1 && tmp != Red)
         {Trend="DOWN";
          ObjectDelete("Trend");
          ObjectCreate("Trend",22,1,Time[0],50);
          ObjectSet("Trend",6,Red);
          ObjectSet("Trend",14,242);
          }
        
 
      if(Trend=="UP" || Trend=="DOWN") Trend=Trend;
       else 
         {Trend="NONE";
          ObjectDelete("Trend");
          ObjectCreate("Trend",22,1,Time[0],50);
          ObjectSet("Trend",6,Yellow);
          ObjectSet("Trend",14,240);
          }

      
//##############################################################################
string Trading ="Trading OPEN";
//if(Hour() < 07 || Hour() >= 23)  Trading="Trading CLOSED ";

Comment("SMC SHELL","                                               ",Trading,"  Long Term Trend (Stochastic with MAs)   ",Trend,"   ",Hour()," ",Minute()," ",Seconds(),
       "\n",
        "TRADING VALUES",
        "\n",
        "Spread ", Spread," MinDist ",MinDist," Max Risk ",MaxRiskStr,
        "\n",
        "Ask/Bid ",Ask," ",Bid,
        "\n",
        "SYSTEM PARAMETERS",
        "\n",
        "MA settings Short ",SMALength," Medium ",MMALength," Long ",LMALength,
        "\n",
        "Trailing Stop ",TrailingStop,
        "\n",
        "Lots Multiplier ",LotsMultiplier,
        "\n",
        );


//##############################################################################
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
//BUY and SELL rules:
 BuyLots = Lots;
 Buy = false;
 Sell =false;
 tmp=0;
 tmp=ObjectGet("X"+Time[0],6);  //add in tmp=gray check
if(tmp==Gray)
{
//################################################################################
//~~~~~~~~~~~~BUY~~~~~~~~~~~~~~~~~~~~~~~~

  if(Trend != "DOWN")    //this is a placeholder for the entry LONG conditions                                         
   {
    Buy=true;
    if(Trend == "UP") BuyLots = Lots*LotsMultiplier;
    LastOrder = " Buy on Failure 1";
    ObjectSet("X"+Time[0],6,Pink);
    SL=Low[Lowest(NULL,0,MODE_LOW,2,1)]-(2*Point); //modify appropriatley
    TP=Ask+(10*Point);
   }
//################################################################################

//~~~~~~~~~~~SELL~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if( Trend != "UP")   //this is a placeholder for the entry SHORT conditions
   {
    Sell=true;
    if(Trend == "DOWN") BuyLots = Lots*LotsMultiplier;
    LastOrder = " Sell on Failure 1 ";
    ObjectSet("X"+Time[0],6,Pink);
    SL=High[Highest(NULL,0,MODE_HIGH,2,1)]+(2*Point); 
    TP=Bid-(10*Point);
   }
}//if bar indicator is Pink no new trade this bar
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##################################################################################
//~~~~~~~~~~~~~~~~~~~LOCK IN PROFIT / TRAILING STOP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//This needs a new approach e.g. run down on previous hi/lo values until a reversal signal
//in the opposite direction

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
      if(MathAbs(Bid - OrderStopLoss())/Point > TrailingStop*Point) SL= Bid-(TrailingStop*Point); 

       if(SL > OrderStopLoss())
       {
       OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Orange);
       return(0);}
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
      if(MathAbs(OrderStopLoss()-Ask)/Point  > (TrailingStop*Point)) SL= Ask + (TrailingStop*Point);
      
       if(SL < OrderStopLoss() || OrderStopLoss() == 0)
       OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Red);
       return(0);}
       }}
}
//##############################################################################
//~~~~~~~~~~~~~~~~  ORDER CLOSURE  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE LONG Entries
 if(0==1)
 {                               
   total=OrdersTotal();
   if(total>0)
    { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() &&
         0==1)
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
         0==1)
       {
        OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
   }}}
 }  
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
       if (NumberofPositions >=2) return(0);
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

   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SL,TP,LastOrder,070177,0,Red);
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

