//+------------------------------------------------------------------+
//|                                             EA_RSI_Stocho_MA.mq4 |
//|                                                              Oxy |
//|                                                  m-viva@inbox.ru |
//+------------------------------------------------------------------+
#property copyright "Oxy"
#property link      "m-viva@inbox.ru"
#property version   "1.00"
#property strict
//------- external parameters ---------------------------------------+
extern string             nameInd1           = "___________RSI__________"; // RSi 
extern int                RSI_period         = 3;                          // RSi period
extern ENUM_APPLIED_PRICE RSI_applied_price  = PRICE_CLOSE;                // RSi applied price
extern int                RSI_up_level       = 80;                         // level up - RSi 
extern int                RSI_dn_level       = 20;                         // level down - RSi 
extern string             nameInd2           = "________Stochastic______"; // Stochastic
extern int                STh_K_period       = 6;                          // K period
extern int                STh_D_period       = 3;                          // D period
extern int                STh_slowing        = 3;                          // slowing
extern ENUM_MA_METHOD     STh_method         = MODE_SMA;                   // Stochastic method
extern int                STh_price_field    = 0;                          // 0 - Low/High; 1 - Close/Close
extern int                STh_up_level       = 70;                         // level up - Stochastic
extern int                STh_dn_level       = 30;                         // level down - Stochastic
extern string             nameInd3           = "___________MA___________"; // MA
extern int                MA_period          = 150;                        // MA period
extern int                MA_shift           = 0;                          // MA shift
extern ENUM_MA_METHOD     MA_method          = MODE_SMA;                   // MA method
extern ENUM_APPLIED_PRICE MA_applied_price   = PRICE_CLOSE;                // MA applied price
extern string             EA_properties      = "_________Expert_________"; // Expert properties
extern double             Lot                = 0.01;                       // Lot
extern int                AllowLoss          = 300;                        // allow Loss, 0 - close by Stocho
extern int                TrailingStop       = 300;                        // Trailing Stop, 0 - close by Stocho
extern int                Slippage           = 30;                         // Slippage
extern int                NumberOfTry        = 5;                          // number of trade attempts
extern int                MagicNumber        = 5577555;                    // Magic Number
//------- global variables ------------------------------------------+
string   NameEA="Expert_RSI_Stochastic_MA";
string   Symb;
datetime candleTime=0;
string   txt="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Symb=Symbol();
   if(STh_price_field!=1) STh_price_field=0;
   if(RSI_up_level>=100 || RSI_up_level<=RSI_dn_level) { Print("Wrong level up - RSi !");             return(INIT_FAILED);}
   if(RSI_dn_level<=0   || RSI_dn_level>=RSI_up_level) { Print("Wrong level down - RSi !");           return(INIT_FAILED);}
   if(STh_up_level>=100 || STh_up_level<=STh_dn_level) { Print("Wrong level up - Stochastic !");      return(INIT_FAILED);}
   if(STh_dn_level<=0   || STh_dn_level>=STh_up_level) { Print("Wrong level down - Stochastic !");    return(INIT_FAILED);}
   if(Lot<MarketInfo(Symb,MODE_MINLOT) || Lot>MarketInfo(Symb,MODE_MAXLOT)) { Print("Wrong LOT!");  return(INIT_FAILED);}
   if(AllowLoss<0) AllowLoss=0;
   if(AllowLoss!=0 && AllowLoss<MarketInfo(Symb,MODE_STOPLEVEL)) { Print("Wrong allow Loss!");       return(INIT_FAILED);}
   if(TrailingStop<0) TrailingStop=0;
   if(TrailingStop!=0 && TrailingStop<MarketInfo(Symb,MODE_STOPLEVEL)) { Print("Wrong Trailing Stop!"); return(INIT_FAILED);}
   if(Slippage<0) Slippage=0;
   if(NumberOfTry<1)  NumberOfTry=1;
   if(MagicNumber<0)  MagicNumber=MathAbs(MagicNumber);
   Comment("Waiting a new tick!");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { Comment(""); }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsTradeAllowed())
     {
      string _txt_new="You must allow trading!";
      if(txt!=_txt_new) { txt=_txt_new; Print(txt); Comment(txt);}
      return;
     }
//---
   double _ma      = iMA        (Symb, 0, MA_period, MA_shift, MA_method, MA_applied_price, 0);
   double _rsi     = iRSI       (Symb, 0, RSI_period, RSI_applied_price, 0);
   double _STh_0_0 = iStochastic(Symb, 0, STh_K_period, STh_D_period, STh_slowing, STh_method, STh_price_field, 0, 0);
   double _STh_1_0 = iStochastic(Symb, 0, STh_K_period, STh_D_period, STh_slowing, STh_method, STh_price_field, 1, 0);
//---
//--- comment
   string _dn_up="DOWN price"; if(Bid>_ma) _dn_up="UP price";
   txt="\n"+NameEA+"\nMA = "+double_to_str(_ma,Digits)+" ---> "+_dn_up
       +"\nRSI ("+(string)RSI_dn_level+"/"+(string)RSI_up_level+") = "+double_to_str(_rsi)
       +"\nStochastic ("+(string)STh_dn_level+"/"+(string)STh_up_level+") = "+double_to_str(_STh_0_0)+" _ "+double_to_str(_STh_1_0);
   Comment(txt);
//---
   double _openPriceBuy  = OpenPrice(0);
   double _openPriceSell = OpenPrice(1);
//---
//--- check loss BUY
   if(_openPriceBuy!=0 && _openPriceBuy>Bid)
     {
      if(AllowLoss==0)
        {
         if(_STh_0_0>STh_up_level) { CloseOpenPos(0); return;} // negative result - close
           } else {
         if(_openPriceBuy-Bid>=AllowLoss*Point && _STh_0_0>STh_dn_level)
           { // close by allow loss
            CloseOpenPos(0);
            return;
           }
        }
     }
//--- check loss SELL
   if(_openPriceSell!=0 && _openPriceSell<Ask)
     {
      if(AllowLoss==0)
        {
         if(_STh_0_0<STh_dn_level) { CloseOpenPos(1); return;} // negative result - close
           } else {
         if(Ask-_openPriceSell>=AllowLoss*Point && _STh_0_0<STh_up_level)
           { // close by allow loss
            CloseOpenPos(1);
            return;
           }
        }
     }
//---
//--- close or trail BUY
   if(_openPriceBuy!=0 && _STh_0_0>STh_up_level && _openPriceBuy<=Bid)
     {
      //--- positive result
      if(TrailingStop>0)
        {
         //--- trail
         if(candleTime!=Time[0])
           {
            //--- once per candle
            Modify_SL_trail(0,TrailingStop);
            candleTime=Time[0];
           }
        }
      else CloseOpenPos(0); // close     
     }
//--- close or trail SELL
   if(_openPriceSell!=0 && _STh_0_0<STh_dn_level && _openPriceSell>=Ask)
     {
      //--- positive result
      if(TrailingStop>0)
        {
         //--- trail
         if(candleTime!=Time[0])
           {
            //--- once per candle
            Modify_SL_trail(1,TrailingStop);
            candleTime=Time[0];
           }
        }
      else CloseOpenPos(1); // close      
     }
//---
//--- BUY
   if(Bid>_ma && _rsi<RSI_dn_level && HaveOpenPos(0)==false
      && (_STh_0_0<STh_dn_level && _STh_1_0<STh_dn_level))
     {
      BuyPos(Lot);
     }
//--- SELL
   if(Ask<_ma && _rsi>RSI_up_level && HaveOpenPos(1)==false
      && (_STh_0_0>STh_up_level && _STh_1_0>STh_up_level))
     {
      SellPos(Lot);
     }
//---
  }
//+------------------------------------------------------------------+
//| Check open position                                              |
//+------------------------------------------------------------------+
bool HaveOpenPos(int or_tp=-1)
  {
   int i,ot,k=OrdersTotal();
   if(or_tp<0 || or_tp>1) or_tp=-1;
   for(i=k-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symb && OrderMagicNumber()==MagicNumber)
           {
            ot=OrderType();
            if(or_tp==-1)
              {
               if(ot==0 || ot==1) return (true);
                 } else {
               if(or_tp==ot) return (true);
              }
           }
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| Looking for a open price                                         |
//+------------------------------------------------------------------+
double OpenPrice(int or_tp)
  {
   double _opPr=0;
   if(or_tp!=0 && or_tp!=1) return (_opPr);
   int i, k = OrdersTotal ();
//---
   for(i=k-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symb && OrderMagicNumber()==MagicNumber)
           {
            if(or_tp==OrderType())
              {
               if(_opPr==0) {_opPr=OrderOpenPrice(); continue;}
               if(or_tp==0 && _opPr<OrderOpenPrice()) _opPr=OrderOpenPrice();
               if(or_tp==1 && _opPr>OrderOpenPrice()) _opPr=OrderOpenPrice();
              }
           }
        }
     }
   return (_opPr);
  }
//+------------------------------------------------------------------+
//| Modify Stop Loss                                                 |
//+------------------------------------------------------------------+
void Modify_SL_trail(int or_tp,int _sl)
  {
   if(or_tp!=0 && or_tp!=1) return;
   int i,err,k=OrdersTotal();
   double sl=0;
   for(i=k-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symb && OrderMagicNumber()==MagicNumber)
           {
            if(or_tp==OrderType())
              {
               RefreshRates();
               if(or_tp==0)
                 {
                  sl=NormalizeDouble(Bid-(double)_sl*Point,Digits);
                 }
               if(or_tp==1)
                 {
                  sl=NormalizeDouble(Ask+(double)_sl*Point,Digits);
                 }
               if(OrderStopLoss()==0 || (or_tp==0 && OrderStopLoss()<sl) || (or_tp==1 && OrderStopLoss()>sl))
                 {
                  for(int it=1; it<=NumberOfTry; it++)
                    {
                     ResetLastError();
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0))
                       {
                        if(it>=NumberOfTry) { Print("Cannot change the order ",OrderTicket(),"!"); break; }
                        err=GetLastError();
                        if(err==4 || err==6 || err==8 || err==128 || err==137 || err==141 || err==146) Sleep(1000*100);
                        else { Print("Cannot change the order ",OrderTicket(),"!"); break; }
                       }
                     else break;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Close open position                                              |
//+------------------------------------------------------------------+
void CloseOpenPos(int or_tp)
  {
   int i,err,k=OrdersTotal();
//---
   for(i=k-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symb && OrderMagicNumber()==MagicNumber)
           {
            if(or_tp==OrderType())
              {
               for(int it=1; it<=NumberOfTry; it++)
                 {
                  ResetLastError();
                  RefreshRates();
                  double _price=Ask; if(or_tp==0) _price=Bid;
                  //---
                  if(!OrderClose(OrderTicket(),OrderLots(),_price,Slippage))
                    {
                     if(it>=NumberOfTry) { Print("Failed to close the order ",OrderTicket(),"!"); break; }
                     err=GetLastError();
                     if(err==4 || err==6 || err==8 || err==128 || err==137 || err==141 || err==146) Sleep(1000*100);
                     else { Print("Failed to close the order ",OrderTicket(),"!"); break; }
                    }
                  else break;

                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| BUY                                                              |
//+------------------------------------------------------------------+
void BuyPos(double _lot)
  {
   double sl=0,tp=0;
//---
   int err;
   for(int it=1; it<=NumberOfTry; it++)
     {
      ResetLastError();
      RefreshRates();
      if(!OrderSend(Symb,OP_BUY,_lot,NormalizeDouble(Ask,Digits),Slippage,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),NULL,MagicNumber))
        {
         if(it>=NumberOfTry) { Print("Failed OP_BUY !"); break; }
         err=GetLastError();
         if(err==4 || err==6 || err==8 || err==128 || err==137 || err==141 || err==146) Sleep(1000*100);
         else { Print("Failed OP_BUY !"); break; }
        }
      else break;
     }
  }
//+------------------------------------------------------------------+
//| SELL                                                             |
//+------------------------------------------------------------------+
void SellPos(double _lot)
  {
   double sl=0,tp=0;
//---
   int err;
   for(int it=1; it<=NumberOfTry; it++)
     {
      ResetLastError();
      RefreshRates();
      if(!OrderSend(Symb,OP_SELL,_lot,NormalizeDouble(Bid,Digits),Slippage,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),NULL,MagicNumber))
        {
         if(it>=NumberOfTry) { Print("Failed OP_SELL !"); break; }
         err=GetLastError();
         if(err==4 || err==6 || err==8 || err==128 || err==137 || err==141 || err==146) Sleep(1000*100);
         else { Print("Failed OP_SELL !"); break; }
        }
      else break;
     }
  }
//+------------------------------------------------------------------+
//| double to string                                                 |
//+------------------------------------------------------------------+
string double_to_str(double num,int _dig=2)
  {
   string _num  = (string)num;
   int    _pp   = StringFind(_num, ".", 0);
   if(_pp!=-1) _num=StringSubstr(_num,0,_pp+_dig+1);
   return(_num);
  }
//+------------------------------------------------------------------+
