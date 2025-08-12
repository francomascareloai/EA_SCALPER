//+------------------------------------------------------------------+
//|                                          TrailingStopFrCnSAR.mq4 |
//|                               Copyright © 2010, Хлыстов Владимир |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, cmillion@narod.ru"
#property link      "http://cmillion.narod.ru"
#property show_inputs
//--------------------------------------------------------------------
extern string  parameters.trailing="0-off  1-Candle  2-Fractals  3-Velosity  4-Parabolic  >4-pips";
extern int     TrailingStop         = 2;     //0 off
extern int     delta                = 0;     //отступ от фрактала или свечи или Parabolic
extern bool    only_Profit          = true;  //тралить только прибыльные ордера
extern bool    only_NoLoss          = false; //вместо тралла просто переводить в безубыток
extern bool    only_SL              = false; //тралить только те ордера, у которых уже есть SL
extern bool    SymbolAll            = true;  //трейлить все инструменты 
extern bool    Portfel              = true;  //по портфельному профиту
extern string parameters.Parabolic  = "";
extern double  Step                 = 0.02;
extern double  Maximum              = 0.2;
extern int     Magic                = 0;
extern bool    visualization        = true;
extern int     VelosityPeriodBar    = 30;
extern double  K_Velosity           = 1.0;    //коэффициент увеличения стоплосса по Velosity

//--------------------------------------------------------------------
int  STOPLEVEL,n,DIGITS;
double BID,ASK,POINT;
string  SymbolTral,TekSymbol;
//--------------------------------------------------------------------
int start()                                  
{
   SymbolTral = Symbol();
   ObjectCreate("info",OBJ_LABEL,0,0,0);
   ObjectSet("info",OBJPROP_CORNER,2);      
   ObjectSet("info",OBJPROP_XDISTANCE,0); 
   ObjectSet("info",OBJPROP_YDISTANCE,15);
   ObjectCreate("info1",OBJ_LABEL,0,0,0);
   ObjectSet("info1",OBJPROP_CORNER,2);      
   ObjectSet("info1",OBJPROP_XDISTANCE,0); 
   ObjectSet("info1",OBJPROP_YDISTANCE,5);
   ObjectSetText("info1","Copyright © 2010, cmillion@narod.ru",8,"Arial",Gold);
   string Simb,txt="Установки TrailingStop   ";
   if (TrailingStop==1) txt=StringConcatenate(txt,"по свечам","\n"); 
   if (TrailingStop==2) txt=StringConcatenate(txt,"по Fractals","\n"); 
   if (TrailingStop==3) txt=StringConcatenate(txt,"по Velosity","\n"); 
   if (TrailingStop==4) txt=StringConcatenate(txt,"по Parabolic","\n"); 
   if (TrailingStop> 4) txt=StringConcatenate(txt,"по ",TrailingStop," пункт","\n"); 
   if (Magic==0) txt=StringConcatenate(txt,"Magic любой","\n"); 
   else  txt=StringConcatenate(txt,"Magic ",Magic,"\n");
   if (SymbolAll) {txt=StringConcatenate(txt,"Все инструменты","\n");Simb="  All Symbols";}
   else  Simb=StringConcatenate("  ",SymbolTral);

   if (Portfel) txt=StringConcatenate(txt,"тралить от уровня безубытка","\n");
   if (only_Profit) txt=StringConcatenate(txt,"только прибыльные ордера","\n");
   if (only_NoLoss) txt=StringConcatenate(txt,"только перевод в безубыток","\n");
   if (only_SL) txt=StringConcatenate(txt,"только ордера с выставленным SL","\n");

   while(true)
   {
      RefreshRates();
      STOPLEVEL=MarketInfo(SymbolTral,MODE_STOPLEVEL);
      if (TrailingStop<STOPLEVEL) TrailingStop=STOPLEVEL;
      if (ObjectFind("info1")==-1 || ObjectFind("info")==-1) break;
      TrailingStop();
      ObjectSetText("info",StringConcatenate("Orders ", n,Simb),8,"Arial",Gold);
      if (n==0) break;
      Sleep(500);
      Comment(txt);
   }
   Comment("Закрытие скрипта ",TimeToStr(TimeCurrent(),TIME_SECONDS));
   ObjectDelete("info");
   ObjectDelete("info1");
   ObjectDelete("SL Buy");
   ObjectDelete("STOPLEVEL-");
   ObjectDelete("SL Sell");
   ObjectDelete("STOPLEVEL+");
   ObjectDelete("NoLossSell");
   ObjectDelete("NoLossSell_");
   ObjectDelete("NoLossBuy");
   ObjectDelete("NoLossBuy_");
}
//--------------------------------------------------------------------
void TrailingStop()
{
   int tip,Ticket;
   bool error;
   double StLo,OSL,OOP,NoLoss;
   n=0;
   for (int i=OrdersTotal(); i>=0; i--) 
   {  if (OrderSelect(i, SELECT_BY_POS)==true)
      {  tip = OrderType();
         TekSymbol=OrderSymbol();
         if (tip<2 && (TekSymbol==SymbolTral || SymbolAll) && (OrderMagicNumber()==Magic || Magic==0))
         {
/*            if (visualization && TekSymbol==SymbolTral)
            {
               ObjectDelete("SL Buy");     ObjectDelete("STOPLEVEL-");
               ObjectDelete("SL Sell");    ObjectDelete("STOPLEVEL+");
               ObjectDelete("NoLossSell"); ObjectDelete("NoLossBuy");
               ObjectDelete("NoLossSell_");ObjectDelete("NoLossBuy_");
            }*/
            POINT  = MarketInfo(TekSymbol,MODE_POINT);
            DIGITS = MarketInfo(TekSymbol,MODE_DIGITS);
            BID    = MarketInfo(TekSymbol,MODE_BID);
            ASK    = MarketInfo(TekSymbol,MODE_ASK);
            OSL    = OrderStopLoss();
            OOP    = OrderOpenPrice();
            Ticket = OrderTicket();
            if (tip==OP_BUY)             
            {  n++;
               if (Portfel) NoLoss = TProfit(1,TekSymbol);
               OrderSelect(i, SELECT_BY_POS);
               StLo = SlLastBar(1,BID); 
               if ((StLo < NoLoss && Portfel) || NoLoss==0) continue;
               if (StLo < OOP && only_Profit && !Portfel) continue;
               if (OSL  >= OOP && only_NoLoss) continue;
               if (OSL  == 0 && only_SL) continue;
               if (StLo > OSL)
               {  error=OrderModify(Ticket,OOP,NormalizeDouble(StLo,DIGITS),OrderTakeProfit(),0,White);
                  Comment(TekSymbol,"  TrailingStop ",Ticket," ",TimeToStr(TimeCurrent(),TIME_MINUTES));
                  if (!error) Print(TekSymbol,"  Error order ",Ticket," TrailingStop ",
                              GetLastError(),"   ",SymbolTral,"   SL ",StLo);
               }
            }                                         
            if (tip==OP_SELL)        
            {  n++;
               if (Portfel) NoLoss = TProfit(-1,TekSymbol); 
               OrderSelect(i, SELECT_BY_POS);
               StLo = SlLastBar(-1,ASK);  
               if (StLo > NoLoss && Portfel) continue;
               if (StLo==0) continue;        
               if (StLo > OOP && only_Profit && !Portfel) continue;
               if (OSL  <= OOP && only_NoLoss) continue;
               if (OSL  == 0 && only_SL) continue;
               if (StLo < OSL || OSL==0 )
               {  error=OrderModify(Ticket,OOP,NormalizeDouble(StLo,DIGITS),OrderTakeProfit(),0,White);
                  Comment(TekSymbol,"  TrailingStop "+Ticket," ",TimeToStr(TimeCurrent(),TIME_MINUTES));
                  if (!error) Print(TekSymbol,"  Error order ",Ticket," TrailingStop ",
                              GetLastError(),"   ",SymbolTral,"   SL ",StLo);
               }
            } 
         }
      }
   }
}
//--------------------------------------------------------------------
double SlLastBar(int tip,double price)
{
   double fr=0;
   int jj,ii;
   if (TrailingStop>4)
   {
      if (tip==1) fr = price - TrailingStop*POINT;  
      else        fr = price + TrailingStop*POINT;  
   }
   else
   {
      //------------------------------------------------------- тралл по фракталам
      if (TrailingStop==2)
      {
         if (tip== 1)
         for (ii=1; ii<100; ii++) 
         {
            fr = iFractals(TekSymbol,0,MODE_LOWER,ii);
            if (fr!=0) {fr-=delta*POINT; if (price-STOPLEVEL*POINT > fr) break;}
            else fr=0;
         }
         if (tip==-1)
         for (jj=1; jj<100; jj++) 
         {
            fr = iFractals(TekSymbol,0,MODE_UPPER,jj);
            if (fr!=0) {fr+=delta*POINT; if (price+STOPLEVEL*POINT < fr) break;}
            else fr=0;
         }
      }
      //------------------------------------------------------- тралл по свечам
      if (TrailingStop==1)
      {
         if (tip== 1)
         for (ii=1; ii<100; ii++) 
         {
            fr = iLow(TekSymbol,0,ii)-delta*POINT;
            if (fr!=0) if (price-STOPLEVEL*POINT > fr) break;
            else fr=0;
         }
         if (tip==-1)
         for (jj=1; jj<100; jj++) 
         {
            fr = iHigh(TekSymbol,0,jj)+delta*POINT;
            if (fr!=0) if (price+STOPLEVEL*POINT < fr) break;
            else fr=0;
         }
      }   
      //------------------------------------------------------- тралл по скорости
      if (TrailingStop==3)
      {
         double Velosity_0 = iCustom(TekSymbol,0,"Velosity",VelosityPeriodBar,2,0);
         double Velosity_1 = iCustom(TekSymbol,0,"Velosity",VelosityPeriodBar,2,1);
         if (tip== 1)
         {
            if(Velosity_0>Velosity_1) fr = price - (delta-Velosity_0+Velosity_1)*POINT*K_Velosity;
            else fr=0;
         }
         if (tip==-1)
         {
            if(Velosity_1>Velosity_0) fr = price + (delta+Velosity_1-Velosity_0)*POINT*K_Velosity;
            else fr=0;
         }
      }
      //------------------------------------------------------- тралл по параболику
      if (TrailingStop==4)
      {
         double PSAR = iSAR(TekSymbol,0,Step,Maximum,0);
         if (tip== 1)
         {
            if(price-STOPLEVEL*POINT > PSAR) fr = PSAR - delta*POINT;
            else fr=0;
         }
         if (tip==-1)
         {
            if(price+STOPLEVEL*POINT < PSAR) fr = PSAR + delta*POINT;
            else fr=0;
         }
      }
   }
   //-------------------------------------------------------
   if (visualization && TekSymbol==SymbolTral)
   {
      if (tip== 1)
      {  
         if (fr!=0){
         ObjectCreate("SL Buy",OBJ_ARROW,0,Time[0]+Period()*60,fr,0,0,0,0);                     
         ObjectSet   ("SL Buy",OBJPROP_ARROWCODE,6);
         ObjectSet   ("SL Buy",OBJPROP_COLOR, Blue);}
         if (STOPLEVEL>0){
         ObjectCreate("STOPLEVEL-",OBJ_ARROW,0,Time[0]+Period()*60,price-STOPLEVEL*POINT,0,0,0,0);                     
         ObjectSet   ("STOPLEVEL-",OBJPROP_ARROWCODE,4);
         ObjectSet   ("STOPLEVEL-",OBJPROP_COLOR, Blue);}
      }
      if (tip==-1)
      {
         if (fr!=0){
         ObjectCreate("SL Sell",OBJ_ARROW,0,Time[0]+Period()*60,fr,0,0,0,0);
         ObjectSet   ("SL Sell",OBJPROP_ARROWCODE,6);
         ObjectSet   ("SL Sell", OBJPROP_COLOR, Pink);}
         if (STOPLEVEL>0){
         ObjectCreate("STOPLEVEL+",OBJ_ARROW,0,Time[0]+Period()*60,price+STOPLEVEL*POINT,0,0,0,0);                     
         ObjectSet   ("STOPLEVEL+",OBJPROP_ARROWCODE,4);
         ObjectSet   ("STOPLEVEL+",OBJPROP_COLOR, Pink);}

      }
   }
   return(fr);
}
//-------------------------------------------------------------------- вычисление общего (портфельного) TP
double TProfit(int tip,string Symb)
{
   int b,s;
   double price,price_b,price_s,lot,SLb,SLs,lot_s,lot_b;
   for (int j=0; j<OrdersTotal(); j++)
   {  if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==true)
      {  if ((Magic==OrderMagicNumber() || Magic==0) && OrderSymbol()==Symb)
         {
            price = OrderOpenPrice();
            lot   = OrderLots();
            if (OrderType()==OP_BUY ) {price_b += price*lot; lot_b+=lot; b++;}                     
            if (OrderType()==OP_SELL) {price_s += price*lot; lot_s+=lot; s++;}
         }  
      }  
   }
   //--------------------------------------
   if (b!=0) 
   {  SLb = price_b/lot_b;
      if (visualization && Symb==SymbolTral){
         ObjectCreate("NoLossBuy",OBJ_ARROW,0,Time[0]+Period()*60*5,SLb,0,0,0,0);                     
         ObjectSet   ("NoLossBuy",OBJPROP_ARROWCODE,6);
         ObjectSet   ("NoLossBuy",OBJPROP_COLOR, Blue);         
         ObjectCreate("NoLossBuy_",OBJ_ARROW,0,Time[0]+Period()*60*5,SLb,0,0,0,0);                     
         ObjectSet   ("NoLossBuy_",OBJPROP_ARROWCODE,200);
         ObjectSet   ("NoLossBuy_",OBJPROP_COLOR, Blue);}
   }
   if (s!=0) 
   {  SLs = price_s/lot_s;
      if (visualization && Symb==SymbolTral){
         ObjectCreate("NoLossSell",OBJ_ARROW,0,Time[0]+Period()*60*5,SLs,0,0,0,0);                     
         ObjectSet   ("NoLossSell",OBJPROP_ARROWCODE,6);
         ObjectSet   ("NoLossSell",OBJPROP_COLOR, Pink);         
         ObjectCreate("NoLossSell_",OBJ_ARROW,0,Time[0]+Period()*60*5,SLs,0,0,0,0);                     
         ObjectSet   ("NoLossSell_",OBJPROP_ARROWCODE,202);
         ObjectSet   ("NoLossSell_",OBJPROP_COLOR, Pink);}
   }
if (tip== 1) return(SLb);
if (tip==-1) return(SLs);
}
//--------------------------------------------------------------------

