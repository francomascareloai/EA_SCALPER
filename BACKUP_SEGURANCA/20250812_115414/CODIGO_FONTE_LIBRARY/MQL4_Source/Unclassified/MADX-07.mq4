/*-------------------------------------------------------------------+
 |                                                       MADX-07.mq4 |
 |                            Copyright © 2013, basisforex@gmail.com |
 +-------------------------------------------------------------------*/// on the H4 TF
extern  double dProfit      = 13;
//----- 
extern  int    maPerBig     = 25;
extern  int    ModeBig      = 2;//MODE_SMA=0; MODE_EMA=1; MODE_SMMA=2; MODE_LWMA=3;
extern  int    appPriceBig  = 2;//PRICE_CLOSE=0; PRICE_OPEN=1; PRICE_HIGH=2; PRICE_LOW=3; PRICE_MEDIAN=4; PRICE_TYPICAL=5; PRICE_WEIGHTED=6; 
//-----
extern  int    maPerSmal    = 5;
extern  int    ModeSmal     = 1;//MODE_SMA=0; MODE_EMA=1; MODE_SMMA=2; MODE_LWMA=3;
extern  int    appPriceSmal = 0;//PRICE_CLOSE=0; PRICE_OPEN=1; PRICE_HIGH=2; PRICE_LOW=3; PRICE_MEDIAN=4; PRICE_TYPICAL=5; PRICE_WEIGHTED=6;
//-----
extern  int    maDif        = 5;
//-----
extern  int    advPeriod    = 11;
extern  int    appPriceAdx  = 4;//PRICE_CLOSE=0; PRICE_OPEN=1; PRICE_HIGH=2; PRICE_LOW=3; PRICE_MEDIAN=4; PRICE_TYPICAL=5; PRICE_WEIGHTED=6;
extern  int    advLevelMa   = 13; 
extern  int    advLevelPl   = 13;
extern  int    advLevelMi   = 14;
//-----
extern  int    TakeProfit   = 299;
extern  bool   UseMM        = false;
extern  int    PercentMM    = 1;
extern  double lots         = 0.1;
//-----
int            MagNum       = 10071;
bool           Action1;
//+------------------------------------------------------------------+
int Get_Broker_Digit()
 {  
   if(Digits == 5 || Digits == 3)
    { 
       return(10);
    } 
   else
    {    
       return(1); 
    }   
 }
//+------------------------------------------------------------------+
double GetLots()
 { 
   if (UseMM)
    {
      double a;
      a = NormalizeDouble((PercentMM * AccountFreeMargin() / 100000), 1);      
      if(a > 49.9) return(49.9);
      else if(a < 0.1)
       {
         Print("Lots < 0.1");
         return(0);
       }
      else return(a);
    }    
   else return(lots);
 }
//+------------------------------------------------------------------+
int start()
 {  
   int totT = OrdersTotal();   
   Action1 = true;
   if (totT > 0)
    {
      for(int i = 0; i < totT; i++)
       {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);      
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagNum)
          {
            Action1 = false;
            break;
          }
         else
          {
            Action1 = true; 
          }
       }
    } 
   //-----------------------------------------------  
   double main0, plus0, minus0, main1, plus1, minus1;
   double stMain, stSign;
   double maBigL0, maBigL1, maSmalL0, maSmalL1;
   int cnt, ticket, total, d;
   //==========================================================
   maBigL0  = iMA(NULL, 0, maPerBig, 0, ModeBig, appPriceBig, 0);
   maBigL1  = iMA(NULL, 0, maPerBig, 0, ModeBig, appPriceBig, 1);
   maSmalL0 = iMA(NULL, 0, maPerSmal, 0, ModeSmal, appPriceSmal, 0);
   maSmalL1 = iMA(NULL, 0, maPerSmal, 0, ModeSmal, appPriceSmal, 1);
   //...............................................................  
   main0    = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_MAIN, 0);
   plus0    = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_PLUSDI, 0);
   minus0   = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_MINUSDI, 0);
   main1    = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_MAIN, 1);
   plus1    = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_PLUSDI, 1);
   minus1   = iADX(NULL, 0, advPeriod, appPriceAdx, MODE_MINUSDI, 1);
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   d = Get_Broker_Digit();
   if(Action1 == true) 
    {//===============================================================================================================    BUY    =============   
      if(Bid >  maBigL0 && Low[1] - maSmalL1 > maDif * Point  * d && Low[0] - maSmalL0 > maDif * Point * d && maSmalL0 > maBigL0 &&
         main0 > main1 && main0 > advLevelMa && plus0 > plus1 && plus0 > advLevelPl && minus0 < minus1 && minus0 < advLevelMi)
       {
         ticket = OrderSend(Symbol(), OP_BUY, GetLots(), Ask, 3 * d, 0, Ask + TakeProfit * Point * d, "xax", MagNum, 0, Blue);
         if(ticket > 0)
          {
            if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
          }
         else Print("Error opening BUY order : ", GetLastError()); 
         return(0); 
       }//==============================================================================================================   SELL   ============
      if(Ask < maBigL0 && maSmalL1 - High[1] > maDif * Point && maSmalL0 - High[0] > maDif * Point && maSmalL0 < maBigL0 &&
         main0 > main1 && main0 > advLevelMa && minus0 > minus1 && minus0 > advLevelMi && plus0 < plus1 && plus0 < advLevelPl) 
       {
         ticket = OrderSend(Symbol(), OP_SELL, GetLots(), Bid, 3 * d, 0, Bid - TakeProfit * Point * d, "xax", MagNum, 0, Blue);
         if(ticket > 0)
          {
            if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
          }
         else Print("Error opening SELL order : ", GetLastError()); 
         return(0); 
       }
      return(0);
    }
//=============================================================================================================== 
   total = OrdersTotal();
   for(cnt = 0; cnt < total; cnt++)
    {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber() == MagNum)
       {
         if(OrderType() == OP_BUY) 
          {
            if(OrderProfit() + OrderSwap() > dProfit)
             {
                OrderClose(OrderTicket(), OrderLots(), Bid, 3 * d, Violet);
                return(0); 
             }            
          }
         else if(OrderType() == OP_SELL)
          {
            if(OrderProfit() + OrderSwap() > dProfit)
             {
               OrderClose(OrderTicket(), OrderLots(), Ask, 3 * d, Violet);
               return(0); 
             }
          }
       }
    }
   return(0);         
 }