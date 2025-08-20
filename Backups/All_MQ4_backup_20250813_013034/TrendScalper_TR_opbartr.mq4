//+------------------------------------------------------------------+
//|                                              TrendScalper_TR.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Smoky's Trendscalper modified by TR_n00btrader@frisurf.no"
#property link      "http://www.metaquotes.net/"

//---- input parameters
extern double    LotsIfNoMM=0.1;
extern int       Stoploss=40;
extern int       TakeProfit=999;
extern int       Slip=5;
extern int       InitialTarget=999;
extern int       BB2periodMin=85;
extern int       BB2periodMax=95;
extern double    BB2multiplier=0.95;
extern int       TTFperiod1=15;
extern int       TTFperiod2=0;
extern double    TSmultiplier=6;
extern int       MM_Mode=0;
extern int       MM_Risk=40;


double Opentrades,orders,first,mode,cnt,Ilo,sym,b;
double b4signal,Signal,Triggerline,b4Triggerline,Triggerline2,b4Triggerline2,NowTriggerline,sl,LastOpByExpert,LastBarChecked,NoTouchBar;
bool PotentialLong,PotentialShort;



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




//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {

   Comment(" Trailingstop    ",  b, "\n","      Tick no. ", iVolume(Symbol(),0,0),
     "\n"," Lots    ",Ilo);


   /**********************************Money and Risk Management***************************************
   Changing the value of mm will give you several money management options
   mm = 0 : Single 1 lot orders.
   mm = -1 : Fractional lots/ balance X the risk factor.(use for Mini accts)
   mm = 1 : Full lots/ balance X the risk factor up to 100 lot orders.(use for Regular accounts)
   ***************************************************************************************************
   RISK FACTOR:
   risk can be anything from 1 up. 
   Factor of 5 adds a lot for every $20,000.00 added to the balance. 
   Factor of 10 adds a lot with every $10.000.00 added to the balance.
   The higher the risk,  the easier it is to blow your margin..
   **************************************************************************************************/

   if (MM_Mode < 0)  {
   Ilo = MathCeil(AccountBalance()*MM_Risk/10000)/10;
     if (Ilo > 100) {  
     Ilo = 100;  
     }
   } else {
   Ilo = LotsIfNoMM;
   }
   if (MM_Mode > 0)  
    {
   Ilo = MathCeil(AccountBalance()*MM_Risk/10000)/10;
    if (Ilo > 1)  
    {
    Ilo = MathCeil(Ilo);
    }
    if (Ilo < 1)  
    {
    Ilo = 1;
    }
    if (Ilo > 100)  
    {  
     Ilo = 100;  
     }
   }



   //------------------------------------------------------------------------------------------------ 
   Opentrades=0;
   for (cnt=0;cnt<OrdersTotal();cnt++) 
   {
      if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;
      if ( OrderSymbol()==Symbol()) Opentrades=Opentrades+1;
   }


   if (Opentrades==0)  //and iATR(5,2)<StopLoss*Point 
   
     {
  
     if (LastBarChecked == Time[0]) 
         return(0); 
      else 
  	      {

         if (NoTouchBar  == Time[0]) return(0); //This ensures that no positions will be opened during a bar where a SL was hit. This makes backtests at open prices only fully accurate.


  	      if (IsTesting()==True) LastBarChecked = Time[0]; //Setting this only when backtesting ensures that the full entry code will be run on each tick (when there are no positions open), in case a setorder fails and needs to be retried. Eventually I'll add in MT4 errortrapping features as well.
  	      
  	      PotentialLong=false;
  	      PotentialShort=false;
  	      
         for (cnt=BB2periodMin;cnt<=BB2periodMax;cnt++) 
            {
            //Print(cnt);
            if (! PotentialShort && High[1]>(iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_MAIN,1) + ((iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_UPPER,1) - iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_MAIN,1)) * BB2multiplier)))
               {
               PotentialShort=True;
               }
            if (! PotentialLong && Low[1]<(iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_MAIN,1) - ((iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_MAIN,1) - iBands(Symbol(),0,cnt,2,0,PRICE_CLOSE,MODE_LOWER,1)) * BB2multiplier)))
               {
               PotentialLong=True;
               }
            }
            
  	         if (! PotentialShort && ! PotentialLong) return(0); //If either OR BOTH is true, continues to remainder of entry code
  	      }
   	
 	   Triggerline = iCustom(Symbol(),0,"TTF_TR",TTFperiod1,1,1);
	   b4Triggerline = iCustom(Symbol(),0,"TTF_TR",TTFperiod1,1,2);
	   
	   if (TTFperiod2 != 0) 
	     {
	     Triggerline2 = iCustom(Symbol(),0,"TTF_TR",TTFperiod2,1,1);
	     b4Triggerline2 = iCustom(Symbol(),0,"TTF_TR",TTFperiod2,1,2);
        }
        else
        {
        //This ensures that no signal will be given for TTFperiod2
        Triggerline2=100;
        b4Triggerline2=100;
        }



     if (PotentialShort==True 
         && ((b4Triggerline>=100 && Triggerline<100) || (b4Triggerline2>=100 && Triggerline2<100)))
        {
        OrderSend(Symbol(),OP_SELL,Ilo,Bid,Slip,Bid+Stoploss*Point,Bid-TakeProfit*Point,"Tscalp",0,0,Red);
        LastOpByExpert=CurTime();
        //	Print (TimeToStr(Time[1]),"   ", Triggerline);
        return(0);            
        }

     if (PotentialLong==True 
         && ((b4Triggerline<=(-100) && Triggerline>(-100)) || (b4Triggerline2<=(-100) && Triggerline2>(-100))))
        {
        OrderSend(Symbol(),OP_BUY,Ilo,Ask,Slip,Ask-Stoploss*Point,Ask+TakeProfit*Point,"Tscalp",0,0,White);
        LastOpByExpert=CurTime();
        return(0);
        }

     }

   //----------------------------------------Order Control-------------------------------------------
 
   if (Opentrades != 0)  
   
     {
     
      NoTouchBar = Time[0]; //This ensures that no positions will be opened during a bar where a SL was hit. This makes backtests at open prices only fully accurate.
      orders=0;
      sym=0;
      for (cnt=0;cnt<OrdersTotal();cnt++) 
         { 
         if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;

         if ( OrderSymbol()==Symbol())
            {
            sym=cnt;
            orders=1;

   	      Triggerline = iCustom(Symbol(),0,"TTF_TR",TTFperiod1,1,1);
   
            b=5*Point+iATR(Symbol(),0,3,0)*TSmultiplier;

            mode=OrderType();

            if (mode==OP_BUY)   
             {
             if (
             OrderOpenPrice()>OrderStopLoss()
             && Bid-OrderOpenPrice()>InitialTarget*Point 
             && Triggerline<100) //) || (High[1]>iBands(Symbol(),0,BB2periodMin,1,0,PRICE_CLOSE,MODE_UPPER,1) && Triggerline<100)))
                 {
                 OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);
                 LastOpByExpert=CurTime();
                 return(0);
                 } 
             //if ("1"=="1") 
             if (Bid-OrderOpenPrice()>b)
              {
              if (OrderStopLoss()<Bid-b) 
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-b,OrderTakeProfit(),0,LimeGreen);
               LastOpByExpert=CurTime();
               return(0);
               } 
              }
             }  

             if (mode==OP_SELL) 
                 {
                 if (OrderOpenPrice()<OrderStopLoss()
                 && OrderOpenPrice()-Ask>InitialTarget*Point 
                 && Triggerline>-100) // || Low[1]<iBands(Symbol(),0,BB2periodMin,1,0,PRICE_CLOSE,MODE_LOWER,1) && NowTriggerline>-100)
             
                     {
                     OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
                     LastOpByExpert=CurTime();
                     return(0);
                     }
               //if ("1"=="1") 
               if (OrderOpenPrice()-Ask>b) 
                  {
                  if (OrderStopLoss()>Ask+b) 
                    {
                    OrderModify(OrderTicket(),OrderOpenPrice(),Ask+b,OrderTakeProfit(),0,HotPink);
                    LastOpByExpert=CurTime();
                    return(0);
                    }
                  }
               }
            } 
         }
   }



 //END OF MAIN SECTION
   return(0);
  }
//+------------------------------------------------------------------+

