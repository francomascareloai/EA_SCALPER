//+------------------------------------------------------------------+
//|                                              TrendScalper_TR.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Smoky's Trendscalper modified by TR_n00btrader@frisurf.no"
#property link      "http://www.metaquotes.net/"

//---- input parameters
extern double    LotsIfNoMM=0.1;
extern int       Stoploss=200;
extern int       Slip=5;
extern int       InitialTarget=999;
extern int       MM_Mode=0;
extern int       MM_Risk=40;

double Opentrades,orders,first,mode,Ilo,sym,b;
double b4signal,Signal,Triggerline,b4Triggerline,Nowsignal,NowTriggerline,sl,LastOpByExpert,LastBarChecked;
int cnt,cnt2; 


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
/*
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,0,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,1,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,2,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,3,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,4,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,5,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,6,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,7,2));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,0,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,1,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,2,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,3,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,4,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,5,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,6,7));
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,7,7));
Print("ASD");
Print(iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,21));
Print(iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,20));
Print(iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,19));
Print("ASD2");
Print(iCustom(Symbol(),0,"3Line_Break",3,0,0));
Print(iCustom(Symbol(),0,"3Line_Break",3,1,0));
Print(iCustom(Symbol(),0,"3Line_Break",3,0,10));
Print(iCustom(Symbol(),0,"3Line_Break",3,1,10));
*/

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
//return(0);
   Comment(" Trailingstop    ",  b, "\n","      Tick no. ", iVolume(NULL,0,0),
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

/*
Print(iCustom(Symbol(),0,"Ind-Fractals-1",True,7,7));
Print(iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,19));
Print(iCustom(Symbol(),0,"3Line_Break",3,0,1));
//Fract: An odd line(s) is set if fract below, even line if above.
// Zig: Set at low/high of bar if ends there.
//3Line: If line 0 is higher than 1, then blue/bull bar. If line 0 is lower than 1, then red/bear bar.
*/

 	      
  	      //Print("ASDASDASD    ", iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,11));
         //return(0); 



     if (LastBarChecked == Time[0]) 
         return(0); 
      else 
  	      {
  	      LastBarChecked = Time[0]; 
  	      
         Opentrades=0;
         for (cnt=0;cnt<OrdersTotal();cnt++) 
            {
            if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;
            if ( OrderSymbol()==Symbol()) Opentrades=Opentrades+1;
            }

  	      
  	      
         //----------------------------------------Order Control-------------------------------------------
 
         if (Opentrades != 0)  
   
           {
            orders=0;
            sym=0;
            for (cnt=0;cnt<OrdersTotal();cnt++) 
               { 
               if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;

               if ( OrderSymbol()==Symbol())
                  {
                  sym=cnt;
                  orders=1;
                  b=5*Point+iATR(NULL,0,3,1)*2;
                  //b=50*Point;
                  }
               } 

            mode=OrderType();

            if (mode==OP_BUY)   
             {
             if (Bid-OrderOpenPrice()>b)
              {
              if (OrderStopLoss()<Bid-b) 
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-b,OrderTakeProfit(),0,LimeGreen);
               LastOpByExpert=CurTime();
               //return(0);
               } 
              }
             }  

             if (mode==OP_SELL) 
                 {
                  if (OrderOpenPrice()-Ask>(b)) 
                     {
                     if (OrderStopLoss()>(Ask+b)) 
                       {
                       OrderModify(OrderTicket(),OrderOpenPrice(),Ask+b,OrderTakeProfit(),0,HotPink);
                       LastOpByExpert=CurTime();
                       //return(0);
                       }
                     }
                  }
               }

  	      
  	      
         //----------------------------------------New signals-------------------------------------------
  	      
  	      
  	      
  	      Signal = 0;
         for (cnt=1;cnt<=40;cnt++) 
            {    
            if (iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,cnt)<=Low[cnt])
               {
               for (cnt2=1;cnt2<=7;cnt2=cnt2+2)
                  {
                  if (iCustom(Symbol(),0,"Ind-Fractals-1",True,cnt2,cnt)!=0)
                     {
                     Signal = 1; //1=BUY, 2=SELL
                     break;
                     }
                  }
               if (Signal != 0) break;
               }

            if (iCustom(Symbol(),0,"High_Low v2 (ZigZag)",300,6,0,cnt)>=High[cnt])
               {
               for (cnt2=0;cnt2<=7;cnt2=cnt2+2)
                  {
                  if (iCustom(Symbol(),0,"Ind-Fractals-1",True,cnt2,cnt)!=0)
                     {
                     Signal = 2; //1=BUY, 2=SELL
                     break;
                     }
                  }
               if (Signal != 0) break;
               }
            }   

         if (Signal == 0) 
            {
            Print("No signal over 40 bars..."); //Highly unlikely, but interesting to check
            return(0);
            }
          else
            {
            //Exit if last 3-line-break bar does not confirm signal
            if (Signal == 1 && iCustom(Symbol(),0,"3Line_Break",3,0,1) > iCustom(Symbol(),0,"3Line_Break",3,1,1)) 
               return(0);
            if (Signal == 2 && iCustom(Symbol(),0,"3Line_Break",3,0,1) < iCustom(Symbol(),0,"3Line_Break",3,1,1)) 
               return(0);

            
            }



         if (Signal == 1)
            {
            if (Opentrades != 0)  
   
              {
     
               orders=0;
               sym=0;
               for (cnt=0;cnt<OrdersTotal();cnt++) 
                  { 
                  if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;

                  if ( OrderSymbol()==Symbol())
                     {
                        mode=OrderType();
                        if (mode==OP_BUY)   
                         {
                             return(0);
                         } 

                         if (mode==OP_SELL) 
                                 {
                                 OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
                                 }

                     }
                  } 

               }

            OrderSend(Symbol(),OP_BUY,Ilo,Ask,Slip,Ask-Stoploss*Point,0,"Tscalp",0,0,White);
            return(0);


  	      }


         if (Signal == 2)
            {
            if (Opentrades != 0)  
   
              {
     
               orders=0;
               sym=0;
               for (cnt=0;cnt<OrdersTotal();cnt++) 
                  { 
                  if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;

                  if ( OrderSymbol()==Symbol())
                     {
                        mode=OrderType();
                        if (mode==OP_BUY)   
                         {
                             OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);
                            } 

                         if (mode==OP_SELL) 
                                 {
                                 return(0);
                                 }

                     }
                  } 
               }
                             OrderSend(Symbol(),OP_SELL,Ilo,Bid,Slip,Bid+Stoploss*Point,0,"Tscalp",0,0,Red);
                             return(0);




  	      } 




      } //Ends if (LastBarChecked == Time[0])

   return(0);
  }

/*
   //------------------------------------------------------------------------------------------------ 


   if (Opentrades==0)  //and iATR(5,2)<StopLoss*Point 
   
     {
  
     if (LastBarChecked == Time[0]) 
         return(0); 
      else 
  	      {
  	      LastBarChecked = Time[0]; 
  	      if (! High[1]>iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_UPPER,1) && ! Low[1]<iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_LOWER,1)) 
  	         return(0);
  	      }
   	
	   //Signal =iCustom("TrendScalpIndic",15,0,5,0.7,0,1000,0,MODE_FIRST,1);
	   //b4signal=iCustom("TrendScalpIndic",15,0,5,0.7,0,1000,0,MODE_FIRST,2);
	   //NowSignal=iCustom("TrendScalpIndic",15,0,5,0.7,0,1000,0,MODE_FIRST,0);
	   //Triggerline =iCustom("TrendScalpIndic",15,0,5,0.7,0,1000,0,MODE_SECOND,0);
	   //b4Triggerline =iCustom("TrendScalpIndic",15,0,5,0.7,0,1000,0,MODE_SECOND,1);

      double HHR,HHO,LLR,LLO;
      double BP,SP;

	  HHR=High[Highest(NULL, 0, MODE_HIGH,1,0+1)];
	  HHO =High[Highest(NULL, 0, MODE_HIGH,15,0+1+1)];
	  LLR =Low [Lowest (NULL, 0, MODE_LOW,1,0+1)];
	  LLO =Low [Lowest (NULL, 0, MODE_LOW,15,0+1+1)];
	  BP =HHR-LLO;
	  SP=HHO -LLR;
	  Triggerline=(BP-SP)/(0.5*(BP+SP))*100;
	  if (Triggerline>=0) Triggerline= 100; else Triggerline=-100;

	  HHR=High[Highest(NULL, 0, MODE_HIGH,1,1+1)];
	  HHO =High[Highest(NULL, 0, MODE_HIGH,15,1+1+1)];
	  LLR =Low [Lowest (NULL, 0, MODE_LOW ,1,1+1)];
	  LLO =Low [Lowest (NULL, 0, MODE_LOW ,15,1+1+1)];
	  BP =HHR-LLO;
	  SP=HHO -LLR;
	  b4Triggerline=(BP-SP)/(0.5*(BP+SP))*100;
	  if (b4Triggerline>=0) b4Triggerline=100; else b4Triggerline=-100;

     //Print (Triggerline, "   ", b4Triggerline);



     if (b4Triggerline>=100
     && High[1]>iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_UPPER,1)
     && Triggerline<100) 
  
        {
        OrderSend(Symbol(),OP_SELL,Ilo,Bid,Slip,Bid+Stoploss*Point,0,"Tscalp",0,0,Red);
        LastOpByExpert=CurTime();
        //	Print (TimeToStr(Time[1]),"   ", Triggerline);
        return(0);            
        }

     if 
     (b4Triggerline<=(-100) 
     && Low[1]<iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_LOWER,1)
     && Triggerline>(-100)) //and iATR(10,1)>6*Point

        {
        OrderSend(Symbol(),OP_BUY,Ilo,Ask,Slip,Ask-Stoploss*Point,0,"Tscalp",0,0,White);
        LastOpByExpert=CurTime();
        return(0);
        }

     }

   //----------------------------------------Order Control-------------------------------------------
 
   if (Opentrades != 0)  
   
     {
      orders=0;
      sym=0;
      for (cnt=0;cnt<OrdersTotal();cnt++) 
         { 
         if ( OrderSelect (cnt, SELECT_BY_POS) == false )  continue;

         if ( OrderSymbol()==Symbol())
            {
            sym=cnt;
            orders=1;
	         HHR=High[Highest(NULL, 0, MODE_HIGH,1,0+1)];
	         HHO =High[Highest(NULL, 0, MODE_HIGH,15,0+1+1)];
	         LLR =Low [Lowest (NULL, 0, MODE_LOW,1,0+1)];
	         LLO =Low [Lowest (NULL, 0, MODE_LOW,15,0+1+1)];
	         BP =HHR-LLO;
	         SP=HHO -LLR;
	         NowTriggerline=(BP-SP)/(0.5*(BP+SP))*100;
	         if (NowTriggerline>=0) NowTriggerline= 100; else NowTriggerline=-100;
            b=5*Point+iATR(NULL,0,3,1)*4;
            }
         } 

      mode=OrderType();

      if (mode==OP_BUY)   
       {
       if (
       OrderOpenPrice()>OrderStopLoss()
       && Bid-OrderOpenPrice()>InitialTarget*Point  
       && NowTriggerline<100 || High[1]>iBands(NULL,0,100,1,0,PRICE_CLOSE,MODE_UPPER,1) && NowTriggerline<100)
           {
           OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);
           LastOpByExpert=CurTime();
           return(0);
           } 
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
           && NowTriggerline>-100 || Low[1]<iBands(NULL,0,100,1,0,PRICE_CLOSE,MODE_LOWER,1) && NowTriggerline>-100)
             
               {
               OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
               LastOpByExpert=CurTime();
               return(0);
               }
            if (OrderOpenPrice()-Ask>(b)) 
               {
               if (OrderStopLoss()>(Ask+b)) 
                 {
                 OrderModify(OrderTicket(),OrderOpenPrice(),Ask+b,OrderTakeProfit(),0,HotPink);
                 LastOpByExpert=CurTime();
                 return(0);
                 }
               }
            }
         }




   return(0);
  }
//+------------------------------------------------------------------+