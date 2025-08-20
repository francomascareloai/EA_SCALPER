/*[[
        Name := AdaptTS
        Notes := eur/usd m15
        Lots := 1
        Stop Loss := 0
        Take Profit := 70
        Trailing Stop := 0
]]*/

extern int    Lots=1;
extern double StopLos=0;
extern int    TakeProfit=70;
extern int    TrainingStop=0;
extern int    MiniForex=1;
extern int    Slippage=5;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {
   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }


int start()
  {
   int    Timer=600;                 //inteval between the modifications
   int    PerTS=10;                  //period ATR for calculation TS/SL
   double Kts=7.5;                   //ATR for calculating the level TS/SL	
   int    risk=13;                   //% risk from available capital

   int lotsi=0;
   int i=0;
   double HD=0;
   double LD=0;
   int PrBuy=0;
   int cnt=0;
   int w,x,y,z;
   
   double p=Point();
   
   bool found=false;
   
   int DolPunkt=5;
	if (Symbol()=="EURUSD") DolPunkt = 10;
	if (Symbol()=="GBPUSD") DolPunkt =  7;
  
   if(Bars<100)                {Print("Bars less than 100"); return(0);}
   if(AccountFreeMargin()<100) {Print("We have no money");   return(0);}

   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         found=True;
         if (OrderType()==OP_BUY) PrBuy=1;
         if (OrderType()==OP_SELL) PrBuy=0;
         break;
        }
         else
        {
         found=false;
        }
     } //for(cnt=0;cnt<OrdersTotal();cnt++)

   HD=0;
   LD=0; 

   for (i=1; i<=PerTS; i++)   //StopLoss & TralingStop
	  {
	   HD+=High[i-1];
	   LD+=Low[i-1];
	  }	   

   // this has a problem
   StopLos=Kts*MathSqrt( (HD-LD)/PerTS/p ) * p ;

   if (!found)
     {   
      if (risk!=0)
        {
         //w=AccountBalance()*risk;
         //x=w/100;
         //y=x/DolPunkt;
         //z=y/(StopLos*p);
         //Comment("w=",w," x=",x," y=",y," z=",z);
         //lotsi=NormalizeDouble(z,1);
         lotsi=NormalizeDouble((((AccountBalance()*risk)/100)/DolPunkt)/(StopLos*p),1);
        }
         else
        {
         lotsi=Lots;
        } //if (risk!=0)
           
      if (lotsi > 10)lotsi=MathFloor(lotsi);
         
      if (lotsi<0.1 && MiniForex!=0) lotsi=0.1;
         
      if (lotsi<1 && MiniForex==0) lotsi=1;
         
      //Print("lotsi=",lotsi,"\nStopLos=",StopLos,"\nBuy=",PrBuy);
   
      if (PrBuy==0)
        {
         //SetOrder(OP_BUY,lotsi,Bid,Slippage,Bid-(StopLos*p),0,Lime);
         OrderSend(Symbol(),OP_BUY,lotsi,Bid,Slippage,Bid-(StopLos*p),0,"AdaptTS BUY",16123,0,White);
         return(0);
        }
      if (PrBuy==1)
	     {
	      //SetOrder(OP_SELL,lotsi,Ask,Slippage,Ask+(StopLos*p),0,Blue);
         OrderSend(Symbol(),OP_SELL,Lots,Ask,Slippage,Ask+(StopLos*p),0,"AdaptTS SELL",16321,0,Red);
         return(0);		
        }
           
      } //if (!found) 


      //Print("step 2");


   if (!found || CurTime()-OrderOpenTime()<Timer) return(0);

   if (PrBuy==1)
     {  		
      if (OrderStopLoss()<((Bid-(StopLos*p))-(10*p)))
        {
         //ModifyOrder(Ord(1,VAL_TICKET),Ord(1,VAL_OPENPRICE), Bid-(StopLos*p),0, LightGreen);
         OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(StopLos*p),OrderTakeProfit(),0,Red);
         return(0);
        }
     }
   
   if (PrBuy==0)
     {      
      if (OrderStopLoss()>((Ask+(StopLos*p))+(10*p)) || OrderStopLoss()==0)
        {
         //ModifyOrder(Ord(1,VAL_TICKET),Ord(1,VAL_OPENPRICE), Ask+(StopLos*p),0,Yellow);
         OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(StopLos*p),OrderTakeProfit(),0,Red);
         return(0);
        }
     }	
     
   return(0);
  
  } //start()
  
  

