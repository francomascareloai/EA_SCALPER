//+------------------------------------------------------------------+
//|                                                     test0.02.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https//+------------------------------------------------------------------+
//|                                           TRAIL_BY_R Manager.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
/*Upon activation this EA will look for setups as designated by the user, place a trade1 and managed the trade1 according to
the Money Mannager EA. 
Functions:
//1: TDI cross (TDI_Cross_Up,TDI_Cross_down) / TDI bounce
//2: TDI angle
//3:5EMA cross
//3: enter market
//4: manage: (R_trail,Candle_Trail,MA_trail)
//future:
//look for consolidation and let the EA run after the break.
//look for HL fo decide on trend


scans first to see if any trade1 is taken. If not, it will place a market order based "orderType" value 
that the user enters.
The user has two options to set the stop: pips value or let the EA calculate those pips based preceeding candles.
Atfer the market order is placed, the EA places a number of grid leves equally spaces by the stop pip value. At each,
the EA will move the stop up or down in favor of the trade1.There is also a trailing option that if activaled. the EA
will trail with a number of candles designated by the user once the price hits the last grid level before TP. */


#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//Extern Variables
extern bool enterNow = False;
extern bool wait_4Break = false;
extern double enteryLevel = 0;
extern double orderType = 0;
extern double top1 = 25;
extern double top2 = 40;
extern double top3 = 60;
extern double TP_pips = 80;
extern double lot2_coef =0.66;
extern double lot3_coef =1.54;
extern double lot4_coef =3.1;
extern double RISK = 3;
extern string ab2 ="##########Stop Setting############";
extern string ab3 ="hard pips = 1, candles = 2";
extern int stopSetting = 2;
extern int STOP_PIPs = 50;
extern int STOP_CANDLEs = 2;
extern string ab4 = "set The next 2 var if stopSetting = 2";
extern double SL_MAX_PIPS = 50;
extern double SL_MIN_PIPS = 10;
extern string ab6 = "##########TDI setting############";
extern double TDI_ANGLE = 60;
extern double WRB_avoid = 50;
//Global Variables
double stop = 0;
int OP = 0;
double price;
double lot;
bool _trail[];
double oldTime = Time[0];
double lastTrail = 0;
double STOP_MOV_CNT = 0;
bool scanFirst = false;
double lastBar = 0;
//DIAD
bool trade1;
bool trade2;
bool trade3;
bool trade4;

int ticket1;
int ticket2;
int ticket3;
int ticket4;
bool abort = false;

double TP=0;
double R_mult_TP = 5;



double lot1;
double lot2;
double lot3;
double lot4;

double price1;
double price2;
double price3;
double price4;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   top1 = NormalizeDouble(top1*10*Point,Digits) ;
   top2 = NormalizeDouble(top2*10*Point,Digits);
   top3 = NormalizeDouble(top3*10*Point,Digits);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(enterNow && !abort)
   {
      if(!trade1)
      {
         DIAD();
      }
      else
      {  
         manage();
      }   
   }
   else if(wait_4Break && !abort)
   {
      if(orderType == 1)
      {
         if(Close[1] > enteryLevel + MarketInfo(Symbol(),MODE_SPREAD)*0.1*Point)
         {
            DIAD();
         } 
         else if(trade1)
         {  
            manage();
         }   
      }
      else if(orderType == -1)
      {
         if(Close[1] < enteryLevel - MarketInfo(Symbol(),MODE_SPREAD)*0.1*Point)
         {
            DIAD();
         }
         else if(trade1)
         {  
            manage();
         } 
      }
         
   }
   else if(!trade1 && !enterNow && !wait_4Break)
   {
      if(oldTime != Time[0])
      {
         lastBar = (MathAbs(High[1]-Low[2]))/Point*0.1;
         if(lastBar < WRB_avoid)
         {
            setTrend();
            if(TDI_Cross())
            {
               DIAD();
            }
         }
        oldTime = Time[0];
      }   
   }
   else
   {
      manage();
   }   
}
//+------------------------------------------------------------------+
void DIAD()
{
      if(orderType == 1)
      {
         price = Bid;
         OP = OP_BUY;
         setStop();
         double _stop = price - getStop() *10* Point;
         TP = price + TP_pips*10*Point;
         getLot();
         Print("lot1: ", lot1);
         ticket1 = OrderSend(Symbol(),OP,lot1,Ask,10,0,0,NULL,0,0,clrGreen);
         if(OrderSelect(ticket1,SELECT_BY_TICKET))
         {
            OrderModify(ticket1,price,_stop,TP,0,clrRed);
            trade1 = true;
            price1 = OrderOpenPrice();
         }
      }
      else if(orderType == -1)
      {
         price = Ask;
         OP = OP_SELL;
         setStop();
         double _stop = price + getStop() *10* Point;
         TP = price - TP_pips*10*Point;
         getLot();
         Print("lot1: ", lot1);
         ticket1 = OrderSend(Symbol(),OP,lot1,price,10,0,0,NULL,0,0,clrGreen);
         if(OrderSelect(ticket1,SELECT_BY_TICKET))
         {
            OrderModify(ticket1,price,_stop,TP,0,clrRed);
            trade1 = true;
            price1 = OrderOpenPrice();
         }
      }   
}
void manage()
{    
     if(orderType == 1)
     {
         price = Ask;
         OP = OP_BUY;
         if(OrderSelect(ticket1,SELECT_BY_TICKET)) 
         { 
            double ctm=OrderCloseTime(); 
            if (ctm == 0) 
            {   
               if(!trade2 && price>= price1+top1)
               {
                  ticket2 = OrderSend(Symbol(),OP,lot2,price,10,0,0,NULL,0,0,clrGreen);
                  trade2 = true; 
                  BreakEven();
               }
               else if(!trade3 && price>= price1+top2)
               {
                  ticket3 = OrderSend(Symbol(),OP,lot3,price,10,0,0,NULL,0,0,clrGreen);
                  trade3 = true;
                  BreakEven();
               }
               else if(!trade4 && price>= price1+top3)
               {
                  ticket4 = OrderSend(Symbol(),OP,lot4,price,10,0,0,NULL,0,0,clrGreen);
                  trade4 = true;
                  BreakEven();
               }
            }
            else
            {
               trade1 = false;
               trade2 = false;
               trade3 = false;
               trade4 = false;
               orderType = 0;
               abort = true;
            }
       }
     }
      
      if(orderType == -1)
      {
         price = Ask;
         OP = OP_SELL;
         if(!trade1)
         {
            setStop();
            double _stop = price + getStop() *10* Point;
            TP = price - getStop()*10*Point* R_mult_TP;
            getLot();
            Print("lot1: ", lot1);
            ticket1 = OrderSend(Symbol(),OP,lot1,price,10,0,0,NULL,0,0,clrGreen);
            if(OrderSelect(ticket1,SELECT_BY_TICKET))
            {
               OrderModify(ticket1,price,_stop,TP,0,clrRed);
               trade1 = true;
               price1 = OrderOpenPrice();
            }
         }
         else if(OrderSelect(ticket1,SELECT_BY_TICKET)) 
         { 
            double ctm=OrderCloseTime(); 
            if (ctm == 0) 
            {   
               if(!trade2 && price <= price1-top1)
               {
                  ticket2 = OrderSend(Symbol(),OP,lot2,price,10,0,0,NULL,0,0,clrGreen);
                  trade2 = true; 
                  BreakEven();
                  Print("price: ", price);
                  Print("price1: ",price1);
                  Print("top1: ",top1);
                  Print("ask: ",price);
                  Print("price1-top1: ", price1-top1);
               }
               else if(!trade3 && price <= price1-top2)
               {
                  ticket3 = OrderSend(Symbol(),OP,lot3,price,10,0,0,NULL,0,0,clrGreen);
                  trade3 = true;
                  BreakEven();
               }
               else if(!trade4 && price <= price1-top3)
               {
                  ticket4 = OrderSend(Symbol(),OP,lot4,price,10,0,0,NULL,0,0,clrGreen);
                  trade4 = true;
                  BreakEven();
               }
            }
            else
            {
               trade1 = false;
               trade2 = false;
               trade3 = false;
               trade4 = false;
               orderType = 0;
               abort = true;
            }
       }
       
   }    
}

bool TDI_Cross()
{
   bool cross = false;
   double green_1 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,4,1); 
   double green_2 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,4,2); 
   double green_3 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,4,3); 
   double red_1 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,5,1);
   double red_2 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,5,2);
   double red_3 = iCustom(Symbol(),0,"Synergy_Pro_TDI",10,5,3);
   double HOpen_1 = iCustom(Symbol(),0,"Heiken Ashi",2,1);
   double HOpen_2 = iCustom(Symbol(),0,"Heiken Ashi",2,2);
   double HOpen_3 = iCustom(Symbol(),0,"Heiken Ashi",2,3);
   double HClose_1 = iCustom(Symbol(),0,"Heiken Ashi",3,1);
   double HClose_2 = iCustom(Symbol(),0,"Heiken Ashi",3,2);
   double HClose_3 = iCustom(Symbol(),0,"Heiken Ashi",3,3);
   if(orderType == -1)
   {
    if(green_1 < red_1 && TDI_angle(green_1,green_2) <= -TDI_ANGLE 
       && (green_2>red_2))// || green_3 > red_3))
    {
         cross = true;
    }
   }
   else if(orderType == 1)
   {
     if(green_1 > red_1 && TDI_angle(green_1,green_2) >= TDI_ANGLE 
       && (green_2 < red_2))// || green_3 < red_3))
     {  
         cross = true;
     }
   }
   return cross;
}
double TDI_angle(double price1, double price2)
{
  double pi = 3.14159265358979323846;
  double angle = MathArctan((price1-price2)/1)*180/pi;
  return angle;
}

void setTrend()
{

      if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)>iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0)
         && iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)>0)
      {
         orderType = 1;
      } 
      else if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)<iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0)
         && iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)<0)
      {
         orderType = -1;
      }
      else
      {
         orderType = 0;
      }   
}  

void BreakEven()
{
   double p=0;
   if(trade1 && trade2 && !trade3 && !trade4)
   {
      if(OrderSelect(ticket2,SELECT_BY_TICKET))
      {
         price2 = OrderOpenPrice();
         p = (price1*lot1+price2*lot2)/(lot1+lot2)+orderType*MarketInfo(Symbol(),MODE_SPREAD)*0.1*Point;
         Print("p: ",p);
         OrderModify(ticket2,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket1,SELECT_BY_TICKET))
      {
         OrderModify(ticket1,price,p,TP,0,clrRed);
      }
   }
   else if(trade1 && trade2 && trade3 && !trade4)
   {
      if(OrderSelect(ticket3,SELECT_BY_TICKET))
      {
         price3 = OrderOpenPrice();
         p = (price1*lot1+price2*lot2+price3*lot3)/(lot1+lot2+lot3)
         +orderType*MarketInfo(Symbol(),MODE_SPREAD)*0.1*Point;
         Print("p: ",p);
         OrderModify(ticket3,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket1,SELECT_BY_TICKET))
      {
         OrderModify(ticket1,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket2,SELECT_BY_TICKET))
      {
         OrderModify(ticket2,price,p,TP,0,clrRed);
      }
      
   }
   else if(trade1 && trade2 && trade3 && trade4)
   {
      if(OrderSelect(ticket4,SELECT_BY_TICKET))
      {
         price4 = OrderOpenPrice();
         p = (price1*lot1+price2*lot2+price3*lot3+price4*lot4)/(lot1+lot2+lot3+lot4)
         +orderType*MarketInfo(Symbol(),MODE_SPREAD)*0.1*Point;
         Print("p: ",p);
         OrderModify(ticket4,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket1,SELECT_BY_TICKET))
      {
         OrderModify(ticket1,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket2,SELECT_BY_TICKET))
      {
         OrderModify(ticket2,price,p,TP,0,clrRed);
      }
      if(OrderSelect(ticket3,SELECT_BY_TICKET))
      {
         OrderModify(ticket3,price,p,TP,0,clrRed);
      }
   }
}
void getLot()
{
   double balance = 0;
   if(AccountBalance() < AccountEquity())
   {
      balance = AccountBalance() + (AccountEquity()-AccountBalance())/2;
   }
   else
   {
      balance = AccountBalance();
   }
   double lots = ((balance*RISK*0.01)/getStop())/(10*MarketInfo(Symbol(), MODE_TICKVALUE));
   double MAX_LOT = AccountFreeMargin() / MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if(lots > MAX_LOT && lots < 100)
   {
      lots = MAX_LOT;
   }
   else if (lots > MarketInfo(Symbol(),MODE_MAXLOT))
   {
      lots = MarketInfo(Symbol(),MODE_MAXLOT);
   }
   lot1 = lots;
   lot2 = NormalizeDouble(lot1 * lot2_coef,Digits);
   lot3 = NormalizeDouble(lot1 * lot3_coef,Digits);
   lot4 = NormalizeDouble(lot1 * lot4_coef,Digits);
}
void setStop()
{
   if(stopSetting == 1)
   {
      stop = STOP_PIPs + MarketInfo(Symbol(),MODE_SPREAD) *  0.1; 
   }
   
   else if (stopSetting == 2)
   {
         if(STOP_CANDLEs == 1)
         {
            if(OP==OP_BUY)
            {
               stop = (Ask-Low[1])/Point*0.1+ MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
            }
            else if(OP==OP_SELL)
            {
               stop = (High[1]-Bid)/Point*0.1+ MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
            }
         }
         else
         {
            if(OP==OP_BUY)stop = (Ask-Low[iLowest(Symbol(),0,MODE_LOW,STOP_CANDLEs,1)])/
                                  Point*0.1+ MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
            if(OP==OP_SELL)stop = (High[iHighest(Symbol(),0,MODE_HIGH,5,0)]-Bid)/Point*0.1
                                  + MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
         }   
         Print("Stop:   ",stop);

         if (stop < SL_MIN_PIPS) 
         {
            stop = SL_MIN_PIPS+ MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
         }
         else if(stop > SL_MAX_PIPS)
         {
            stop = SL_MAX_PIPS+ MarketInfo(Symbol(),MODE_SPREAD) *  0.1;
         }
   }  
}

double getStop()
{
   return stop;
}