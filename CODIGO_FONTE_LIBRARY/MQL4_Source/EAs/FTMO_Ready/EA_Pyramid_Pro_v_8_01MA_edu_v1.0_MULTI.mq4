//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua"


extern double koef_grid= 0.5;
extern string ____0___ = "Indicators";
extern int tf_grid = 0;
extern int tf_lock = 60;
extern int tf_aw = 60;
extern int shift = 1;
extern int Period_MA_1 = 5;
extern int Period_MA_2 = 10;
extern int Period_MA_3 = 34;
extern int ma_method=1;
extern int applied_price=0;
extern string ____1___="Start";
extern int start_recede=30;
extern int steps=15;
int Gi_144=0;
extern int quantity=5;
extern int MagicNumber=2808;
extern int StopLoss=0;
extern double Lot=0.0;
extern bool Choice_method=FALSE;
extern double Risk=0.3;
extern string _____Lock_____="______Settings warrants Lock_____";
extern bool Lock=TRUE;
extern int lock_pips=15;
extern double koef_lot_lock=2.0;
extern int StopLoss_Lock=0;
extern string _____AV_____="______Settings warrants AV_____";
extern bool AV=TRUE;
extern double exponents=0.0;
extern int level_AV = 20;
extern int level_OP = 15;
extern double f_lot_av=2.0;
extern int TakeProfit_AV=10;
double G_price_248;
double Gd_256;
string Gs_264="";
extern int Slippage=3;
extern string _____TT_____="______Settings warrants TT_____";
extern int NumberOfTry=5;
extern bool UseSound=TRUE;
extern string NameFileSound="expert.wav";
extern string NameCloseSound="ok.wav";
extern bool MarketWatch=FALSE;
bool Gi_312 = FALSE;
bool Gi_316 = FALSE;
extern bool ShowComment=TRUE;
double Gd_324=0.0;
// 7439F21E440F650B67FCE3BC9F3C24F5
double f0_9()
  {
   int Li_0= StringFind(Symbol(),"JPY");
   if(Li_0 == -1) return (0.0001);
   return (0.01);
  }
// 73CE652B24CD59D9CAB58474A8407399
double f0_8()
  {
   double lotstep_0=MarketInfo(Symbol(),MODE_LOTSTEP);
   int Li_ret_8=MathCeil(MathAbs(MathLog(lotstep_0)/MathLog(10)));
   return (Li_ret_8);
  }
// 195F7A8C3579B807C96412E1BAFAE599
int f0_1(string As_0="",int A_cmd_8=-1,int A_magic_12=-1,int Ai_16=0)
  {
   int cmd_28;
   int order_total_24=OrdersTotal();
   if(As_0=="0") As_0=Symbol();
   for(int pos_20=0; pos_20<order_total_24; pos_20++)
     {
      if(OrderSelect(pos_20,SELECT_BY_POS,MODE_TRADES))
        {
         cmd_28=OrderType();
         if(cmd_28>OP_SELL && cmd_28<6)
           {
            if((OrderSymbol()==As_0 || As_0=="") && (A_cmd_8<OP_BUY || cmd_28==A_cmd_8))
              {
               if(A_magic_12<0 || OrderMagicNumber()==A_magic_12)
                  if(Ai_16 <= OrderOpenTime()) return (1);
              }
           }
        }
     }
   return (0);
  }
// 436F5A19B3A03B7E56C5A3C6E5948369
int f0_2(string As_0="",int A_cmd_8=-1,int A_magic_12=-1,int Ai_16=0)
  {
   int order_total_24=OrdersTotal();
   if(As_0=="0") As_0=Symbol();
   for(int pos_20=0; pos_20<order_total_24; pos_20++)
     {
      if(OrderSelect(pos_20,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==As_0 || As_0=="")
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(A_cmd_8<OP_BUY || OrderType()==A_cmd_8)
                 {
                  if(A_magic_12<0 || OrderMagicNumber()==A_magic_12)
                     if(Ai_16 <= OrderOpenTime()) return (1);
                 }
              }
           }
        }
     }
   return (0);
  }
// 9FDEBEDD6557A3BB9931DD4354992A42
void f0_11(string A_symbol_0,int A_cmd_8,double A_lots_12,double A_price_20,double A_price_28=0.0,double A_price_36=0.0,int A_magic_44=0,int A_datetime_48=0,string A_comment_52="")
  {
   color color_60;
   int datetime_64;
   double ask_68;
   double bid_76;
   double point_84;
   int error_92;
   int ticket_100;
   string comment_108= A_comment_52;
   int stoplevel_104 = MarketInfo(A_symbol_0,MODE_STOPLEVEL);
   if(A_cmd_8==OP_BUYLIMIT || A_cmd_8==OP_BUYSTOP) color_60=Lime;
   else color_60=Red;
   if(A_datetime_48>0 && A_datetime_48<TimeCurrent()) A_datetime_48=0;
   for(int Li_96=1; Li_96<=NumberOfTry; Li_96++)
     {
      if((!IsTesting() && !IsExpertEnabled()) || IsStopped())
        {
         Print("SetOrder(): Остановка работы функции");
         return;
        }
      while(!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      datetime_64= TimeCurrent();
      ticket_100 = OrderSend(A_symbol_0,A_cmd_8,A_lots_12,A_price_20,Slippage,A_price_28,A_price_36,comment_108,A_magic_44,A_datetime_48,color_60);
      if(ticket_100>0)
        {
         if(!(UseSound)) break;
         PlaySound(NameFileSound);
         return;
        }
      error_92=GetLastError();
      if(error_92==128/* TRADE_TIMEOUT */ || error_92==142 || error_92==143)
        {
         Sleep(66000);
         if(f0_1(A_symbol_0,A_cmd_8,A_magic_44,datetime_64))
           {
            if(!(UseSound)) break;
            PlaySound(NameFileSound);
            return;
           }
         Print("Error(",error_92,") set order: ",ErrorDescription(error_92),", try ",Li_96);
           } else {
         point_84=MarketInfo(A_symbol_0,MODE_POINT);
         ask_68 = MarketInfo(A_symbol_0, MODE_ASK);
         bid_76 = MarketInfo(A_symbol_0, MODE_BID);
         if(error_92==130/* INVALID_STOPS */)
           {
            switch(A_cmd_8)
              {
               case OP_BUYLIMIT:
                  if(A_price_20>ask_68-stoplevel_104*point_84) A_price_20=ask_68-stoplevel_104*point_84;
                  if(A_price_28>A_price_20 -(stoplevel_104+1)*point_84) A_price_28=A_price_20 -(stoplevel_104+1)*point_84;
                  if(!(A_price_36>0.0 && A_price_36<A_price_20+(stoplevel_104+1)*point_84)) break;
                  A_price_36=A_price_20+(stoplevel_104+1)*point_84;
                  break;
               case OP_BUYSTOP:
                  if(A_price_20<ask_68+(stoplevel_104+1)*point_84) A_price_20=ask_68+(stoplevel_104+1)*point_84;
                  if(A_price_28>A_price_20 -(stoplevel_104+1)*point_84) A_price_28=A_price_20 -(stoplevel_104+1)*point_84;
                  if(!(A_price_36>0.0 && A_price_36<A_price_20+(stoplevel_104+1)*point_84)) break;
                  A_price_36=A_price_20+(stoplevel_104+1)*point_84;
                  break;
               case OP_SELLLIMIT:
                  if(A_price_20<bid_76+stoplevel_104*point_84) A_price_20=bid_76+stoplevel_104*point_84;
                  if(A_price_28>0.0 && A_price_28<A_price_20+(stoplevel_104+1)*point_84) A_price_28=A_price_20+(stoplevel_104+1)*point_84;
                  if(A_price_36<=A_price_20 -(stoplevel_104+1)*point_84) break;
                  A_price_36=A_price_20 -(stoplevel_104+1)*point_84;
                  break;
               case OP_SELLSTOP:
                  if(A_price_20>bid_76-stoplevel_104*point_84) A_price_20=bid_76-stoplevel_104*point_84;
                  if(A_price_28>0.0 && A_price_28<A_price_20+(stoplevel_104+1)*point_84) A_price_28=A_price_20+(stoplevel_104+1)*point_84;
                  if(A_price_36<=A_price_20 -(stoplevel_104+1)*point_84) break;
                  A_price_36=A_price_20 -(stoplevel_104+1)*point_84;
              }
            Print("SetOrder(): Скорректированы ценовые уровни");
           }
         Print("Error(",error_92,") set order: ",ErrorDescription(error_92),", try ",Li_96);
         Print("Ask=",ask_68,"  Bid=",bid_76,"  sy=",A_symbol_0,"  ll=",A_lots_12,"  op=",f0_14(A_cmd_8),"  pp=",A_price_20,"  sl=",A_price_28,"  tp=",A_price_36,
               "  mn=",A_magic_44,"  com=",comment_108);
         if(ask_68==0.0 && bid_76==0.0) f0_3("SetOrder(): Проверьте в обзоре рынка наличие символа "+A_symbol_0);
         if(error_92==2/* COMMON_ERROR */ || error_92==64/* ACCOUNT_DISABLED */ || error_92==65/* INVALID_ACCOUNT */ || error_92==133/* TRADE_DISABLED */)
           {
            Gi_312=TRUE;
            return;
           }
         if(error_92==4/* SERVER_BUSY */ || error_92==131/* INVALID_TRADE_VOLUME */ || error_92==132/* MARKET_CLOSED */)
           {
            Sleep(300000);
            return;
           }
         if(error_92 == 8/* TOO_FREQUENT_REQUESTS */ || error_92 == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
         if(error_92 == 139/* ORDER_LOCKED */ || error_92 == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error_92 == 148/* TRADE_TOO_MANY_ORDERS */) break;
         if(error_92 == 146/* TRADE_CONTEXT_BUSY */) while(IsTradeContextBusy()) Sleep(11000);
         if(error_92 == 147/* TRADE_EXPIRATION_DENIED */) A_datetime_48 = 0;
         else
            if(error_92!=135/* PRICE_CHANGED */ && error_92!=138/* REQUOTE */) Sleep(7700.0);
        }
     }
  }
// 4C2A8FE7EAF24721CC7A9F0175115BD4
void f0_3(string As_0)
  {
   Comment(As_0);
   if(StringLen(As_0)>0) Print(As_0);
  }
// B6838164ED869516345D96B32AA351B5
string f0_14(int Ai_0)
  {
   switch(Ai_0)
     {
      case 0:
         return ("Buy");
      case 1:
         return ("Sell");
      case 2:
         return ("Buy Limit");
      case 3:
         return ("Sell Limit");
      case 4:
         return ("Buy Stop");
      case 5:
         return ("Sell Stop");
     }
   return ("Unknown Operation");
  }
// 9D83CE1B6EB850A087D4F3A7322D07C9
void f0_10(string As_0="",int A_cmd_8=-1,int A_magic_12=-1)
  {
   bool is_deleted_16;
   int error_20;
   int cmd_36;
   int order_total_32=OrdersTotal();
   if(As_0=="0") As_0=Symbol();
   for(int pos_24=order_total_32-1; pos_24>=0; pos_24--)
     {
      if(OrderSelect(pos_24,SELECT_BY_POS,MODE_TRADES))
        {
         cmd_36=OrderType();
         if(cmd_36>OP_SELL && cmd_36<6)
           {
            if((OrderSymbol()==As_0 || As_0=="") && (A_cmd_8<OP_BUY || cmd_36==A_cmd_8))
              {
               if(A_magic_12<0 || OrderMagicNumber()==A_magic_12)
                 {
                  for(int Li_28=1; Li_28<=NumberOfTry; Li_28++)
                    {
                     if((!IsTesting() && !IsExpertEnabled()) || IsStopped()) break;
                     while(!IsTradeAllowed()) Sleep(5000);
                     is_deleted_16=OrderDelete(OrderTicket(),Blue);
                     if(is_deleted_16)
                       {
                        if(!(UseSound)) break;
                        PlaySound(NameFileSound);
                        break;
                       }
                     error_20=GetLastError();
                     Print("Error(",error_20,") delete order ",f0_14(cmd_36),": ",ErrorDescription(error_20),", try ",Li_28);
                     Sleep(5000);
                    }
                 }
              }
           }
        }
     }
  }
// A076F38073ABEC669F1459B783418EA6
void f0_12(string A_symbol_0,int A_cmd_8,double A_lots_12,double A_price_20=0.0,double A_price_28=0.0,int A_magic_36=0,string A_comment_40="")
  {
   color color_48;
   int datetime_52;
   double price_56;
   double price_64;
   double price_72;
   int digits_80;
   int error_84;
   int ticket_92=0;
   string comment_96=A_comment_40;
   if(A_symbol_0=="" || A_symbol_0=="0") A_symbol_0=Symbol();
   if(A_cmd_8==OP_BUY) color_48=Lime;
   else color_48=Red;
   for(int Li_88=1; Li_88<=NumberOfTry; Li_88++)
     {
      if((!IsTesting() && !IsExpertEnabled()) || IsStopped())
        {
         Print("OpenPosition(): Остановка работы функции");
         break;
        }
      while(!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      digits_80= MarketInfo(A_symbol_0,MODE_DIGITS);
      price_64 = MarketInfo(A_symbol_0, MODE_ASK);
      price_72 = MarketInfo(A_symbol_0, MODE_BID);
      if(A_cmd_8==OP_BUY) price_56=price_64;
      else price_56=price_72;
      price_56=NormalizeDouble(price_56,digits_80);
      datetime_52=TimeCurrent();
      if(MarketWatch) ticket_92=OrderSend(A_symbol_0,A_cmd_8,A_lots_12,price_56,Slippage,0,0,comment_96,A_magic_36,0,color_48);
      else ticket_92=OrderSend(A_symbol_0,A_cmd_8,A_lots_12,price_56,Slippage,A_price_20,A_price_28,comment_96,A_magic_36,0,color_48);
      if(ticket_92>0)
        {
         if(!(UseSound)) break;
         PlaySound(NameFileSound);
         break;
        }
      error_84=GetLastError();
      if(price_64==0.0 && price_72==0.0) f0_3("Проверьте в Обзоре рынка наличие символа "+A_symbol_0);
      Print("Error(",error_84,") opening position: ",ErrorDescription(error_84),", try ",Li_88);
      Print("Ask=",price_64," Bid=",price_72," sy=",A_symbol_0," ll=",A_lots_12," op=",f0_14(A_cmd_8)," pp=",price_56," sl=",A_price_20," tp=",A_price_28,
            " mn=",A_magic_36);
      if(error_84==2/* COMMON_ERROR */ || error_84==64/* ACCOUNT_DISABLED */ || error_84==65/* INVALID_ACCOUNT */ || error_84==133/* TRADE_DISABLED */)
        {
         Gi_312=TRUE;
         break;
        }
      if(error_84==4/* SERVER_BUSY */ || error_84==131/* INVALID_TRADE_VOLUME */ || error_84==132/* MARKET_CLOSED */)
        {
         Sleep(300000);
         break;
        }
      if(error_84==128/* TRADE_TIMEOUT */ || error_84==142 || error_84==143)
        {
         Sleep(66666.0);
         if(f0_2(A_symbol_0,A_cmd_8,A_magic_36,datetime_52))
           {
            if(!(UseSound)) break;
            PlaySound(NameFileSound);
            break;
           }
        }
      if(error_84 == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error_84 == 148/* TRADE_TOO_MANY_ORDERS */ || error_84 == 4110/* LONGS__NOT_ALLOWED */ || error_84 == 4111/* SHORTS_NOT_ALLOWED */) break;
      if(error_84 == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
      if(error_84 == 145/* TRADE_MODIFY_DENIED */) Sleep(17000);
      if(error_84 == 146/* TRADE_CONTEXT_BUSY */) while(IsTradeContextBusy()) Sleep(11000);
      if(error_84!=135/* PRICE_CHANGED */) Sleep(7700.0);
     }
   if(MarketWatch && ticket_92>0 && (A_price_20>0.0 || A_price_28>0.0))
      if(OrderSelect(ticket_92,SELECT_BY_TICKET)) f0_16(-1,A_price_20,A_price_28);
  }
// F235F73FF9E6C9B0402F9856A41D6B1B
void f0_16(double A_order_open_price_0=-1.0,double A_order_stoploss_8=0.0,double A_order_takeprofit_16=0.0,int A_datetime_24=0)
  {
   bool bool_28;
   color color_32;
   double ask_44;
   double bid_52;
   int error_80;
   int digits_76=MarketInfo(OrderSymbol(),MODE_DIGITS);
   if(A_order_open_price_0<=0.0) A_order_open_price_0=OrderOpenPrice();
   if(A_order_stoploss_8<0.0) A_order_stoploss_8=OrderStopLoss();
   if(A_order_takeprofit_16<0.0) A_order_takeprofit_16=OrderTakeProfit();
   A_order_open_price_0=NormalizeDouble(A_order_open_price_0,digits_76);
   A_order_stoploss_8=NormalizeDouble(A_order_stoploss_8,digits_76);
   A_order_takeprofit_16=NormalizeDouble(A_order_takeprofit_16,digits_76);
   double Ld_36 = NormalizeDouble(OrderOpenPrice(), digits_76);
   double Ld_60 = NormalizeDouble(OrderStopLoss(), digits_76);
   double Ld_68 = NormalizeDouble(OrderTakeProfit(), digits_76);
   if(A_order_open_price_0!=Ld_36 || A_order_stoploss_8!=Ld_60 || A_order_takeprofit_16!=Ld_68)
     {
      for(int Li_84=1; Li_84<=NumberOfTry; Li_84++)
        {
         if((!IsTesting() && !IsExpertEnabled()) || IsStopped()) break;
         while(!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         bool_28=OrderModify(OrderTicket(),A_order_open_price_0,A_order_stoploss_8,A_order_takeprofit_16,A_datetime_24,color_32);
         if(bool_28)
           {
            if(!(UseSound)) break;
            PlaySound(NameFileSound);
            return;
           }
         error_80=GetLastError();
         ask_44 = MarketInfo(OrderSymbol(), MODE_ASK);
         bid_52 = MarketInfo(OrderSymbol(), MODE_BID);
         Print("Error(",error_80,") modifying order: ",ErrorDescription(error_80),", try ",Li_84);
         Print("Ask=",ask_44,"  Bid=",bid_52,"  sy=",OrderSymbol(),"  op="+f0_14(OrderType()),"  pp=",A_order_open_price_0,"  sl=",A_order_stoploss_8,"  tp=",
               A_order_takeprofit_16);
         Sleep(10000);
        }
     }
  }
// 6216BECFACB24323B06018073D421B21
double f0_6(int Ai_0,double Ad_4,int Ai_12)
  {
   int Li_16=Ai_0;
   double Ld_20=100;
   if(Li_16==3 || Li_16>=5) Ld_20=1000;
   double Ld_ret_28=1000.0*Ad_4 *(Ai_12/Ld_20);
   return (Ld_ret_28);
  }
// 059B0D4DA2C19C05E682F73846603B50
void f0_0(string As_0="",int A_cmd_8=-1,int A_magic_12=-1)
  {
   int order_total_20=OrdersTotal();
   if(As_0=="0") As_0=Symbol();
   for(int pos_16=order_total_20-1; pos_16>=0; pos_16--)
     {
      if(OrderSelect(pos_16,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==As_0 || As_0=="") && (A_cmd_8<OP_BUY || OrderType()==A_cmd_8))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(A_magic_12<0 || OrderMagicNumber()==A_magic_12)
                  if(OrderProfit()+OrderSwap()>0.0) f0_5();
              }
           }
        }
     }
   order_total_20=OrdersTotal();
   for(pos_16=order_total_20-1; pos_16>=0; pos_16--)
     {
      if(OrderSelect(pos_16,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==As_0 || As_0=="") && (A_cmd_8<OP_BUY || OrderType()==A_cmd_8))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               if(A_magic_12<0 || OrderMagicNumber()==A_magic_12) f0_5();
           }
        }
     }
  }
// 5AEEEB0339BF3B809576C8AEEC9E9A92
void f0_5()
  {
   bool is_closed_0;
   color color_4;
   double order_lots_8;
   double price_16;
   double price_24;
   double price_32;
   int error_40;
   if(OrderType()==OP_BUY || OrderType()==OP_SELL)
     {
      for(int Li_44=1; Li_44<=NumberOfTry; Li_44++)
        {
         if((!IsTesting() && !IsExpertEnabled()) || IsStopped()) break;
         while(!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         price_16 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), Digits);
         price_24 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), Digits);
         if(OrderType()==OP_BUY)
           {
            price_32= price_24;
            color_4 = Lime;
              } else {
            price_32= price_16;
            color_4 = Red;
           }
         order_lots_8= OrderLots();
         is_closed_0 = OrderClose(OrderTicket(),order_lots_8,price_32,Slippage,color_4);
         if(is_closed_0)
           {
            if(!(UseSound)) break;
            PlaySound(NameCloseSound);
            return;
           }
         error_40=GetLastError();
         if(error_40==146/* TRADE_CONTEXT_BUSY */) while(IsTradeContextBusy()) Sleep(11000);
         Print("Error(",error_40,") Close ",f0_14(OrderType())," ",ErrorDescription(error_40),", try ",Li_44);
         Print(OrderTicket(),"  Ask=",price_16,"  Bid=",price_24,"  pp=",price_32);
         Print("sy=",OrderSymbol(),"  ll=",order_lots_8,"  sl=",OrderStopLoss(),"  tp=",OrderTakeProfit(),"  mn=",OrderMagicNumber());
         Sleep(5000);
        }
     }
   else Print("Некорректная торговая операция. Close ",f0_14(OrderType()));
  }
// D0978FB1B9458AB48F770DAC7934B5B7
void f0_15()
  {
   string Lsa_0[256];
   for(int index_4=0; index_4<256; index_4++) Lsa_0[index_4]=CharToStr(index_4);
   string Ls_8=Lsa_0[104]+Lsa_0[116]+Lsa_0[116]+Lsa_0[112]+Lsa_0[58]+Lsa_0[47]+Lsa_0[47]+Lsa_0[119]+Lsa_0[119]+Lsa_0[119]+Lsa_0[46]+Lsa_0[102]+
               Lsa_0[111]+Lsa_0[114]+Lsa_0[101]+Lsa_0[120]+Lsa_0[105]+Lsa_0[110]+Lsa_0[118]+Lsa_0[101]+Lsa_0[115]+Lsa_0[116]+Lsa_0[46]+Lsa_0[101]+Lsa_0[101];
   f0_13("label",Ls_8,2,3,15,10);
  }
// B021DF6AAC4654C454F46C77646E745F
void f0_13(string A_name_0,string A_text_8,int A_corner_16=2,int A_x_20=3,int A_y_24=15,int A_fontsize_28=10,string A_fontname_32="Arial",color A_color_40=3329330)
  {
   if(ObjectFind(A_name_0)!=-1) ObjectDelete(A_name_0);
   ObjectCreate(A_name_0,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(A_name_0,OBJPROP_CORNER,A_corner_16);
   ObjectSet(A_name_0,OBJPROP_XDISTANCE,A_x_20);
   ObjectSet(A_name_0,OBJPROP_YDISTANCE,A_y_24);
   ObjectSetText(A_name_0,A_text_8,A_fontsize_28,A_fontname_32,A_color_40);
  }
// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   Gi_316=FALSE;
   if(!IsTradeAllowed())
     {
      f0_3("For normal operation adviser to\n"+"Allow the Advisor to trade");
      Gi_316=TRUE;
      return(0);
     }
   if(!IsLibrariesAllowed())
     {
      f0_3("For normal operation adviser to\n"+"Allow import of external experts");
      Gi_316=TRUE;
      return(0);
     }
   if(!IsTesting())
     {
      if(IsExpertEnabled()) f0_3("Counselor will be launched next tick");
      else f0_3("Pressed button \"Allow execution advisers\"");
     }
   Slippage=Slippage *(f0_9()/Point);
   return (0);
  }
// 52D46093050F38C27267BCE42543EF60
int deinit()
  {
   Comment("");
   return (0);
  }
// EA2B2676C28C0DB26D39331A336C6B92
int start()
  {
   string Ls_8;
   double Ld_204;
   double Ld_212;
   double Ld_236;
   if(Gi_312)
     {
      f0_3("Critical error! Advisor stopped!");
      return(0);
     }
   if(Gi_316)
     {
      f0_3("Failed to initialize Advisor!");
      return(0);
     }

   double Ld_0=(AccountEquity()-AccountBalance())/(AccountBalance()/100.0);
   if(Ld_0<Gd_324) Gd_324=Ld_0;
   if(ShowComment)
     {
      Ls_8=" CurTime="+TimeToStr(TimeCurrent(),TIME_MINUTES)
           +"\n Number of warrants="+DoubleToStr(quantity*2,0)
           +"\n Abound. between orders="+steps
           +"\n StopLoss="+StopLoss
           +"\n Lots="+DoubleToStr(Lot,2)
           +"\n+------------------------------+"
           +"\n Balance="+DoubleToStr(AccountBalance(),2)
           +"\n Equity="+DoubleToStr(AccountEquity(),2)
           +"\n Current Drawdown="+DoubleToStr(Ld_0,2)+"%"
           +"\n Maximum Drawdown="+DoubleToStr(Gd_324,2)+"%"
           +"\n+------------------------------+";
      Comment(Ls_8);
     }
   else Comment("");
   int count_16 = 0;
   int count_20 = 0;
   double order_open_price_24=99999;
   double order_lots_32=0;
   double order_open_price_40=0;
   double order_lots_48 = 0;
   double order_lots_56 = 0;
   double Ld_64=0;
   double order_lots_72=0;
   int count_80 = 0;
   int count_84 = 0;
   double order_open_price_88=0;
   double order_lots_96=0;
   double order_open_price_104=99999;
   double order_lots_112 = 0;
   double order_lots_120 = 0;
   double Ld_128=0;
   double order_lots_136=0;
   int count_144 = 0;
   int count_148 = 0;
   int count_152 = 0;
   int count_156 = 0;
   double order_open_price_160 = EMPTY_VALUE;
   double order_open_price_168 = 0;
   int m=OrdersTotal();
   for(int pos_176=0; pos_176<m; pos_176++)
     {
      if(OrderSelect(pos_176,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            if(OrderMagicNumber()==MagicNumber)
              {
               if(OrderType()==OP_BUY)
                 {
                  count_16++;
                  if(OrderOpenPrice()<order_open_price_24)
                    {
                     order_open_price_24=OrderOpenPrice();
                     order_lots_32=OrderLots();
                    }
                 }
               if(OrderType()==OP_BUYSTOP)
                 {
                  count_20++;
                  order_lots_120=OrderLots();
                  if(OrderOpenPrice()<order_open_price_160) order_open_price_160=OrderOpenPrice();
                 }
               if(OrderType()==OP_SELL)
                 {
                  count_152++;
                  order_lots_72=OrderLots();
                 }
               if(OrderType()== OP_SELLSTOP) count_156++;
               if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)
                 {
                  if(OrderOpenPrice()>order_open_price_40)
                    {
                     order_open_price_40=OrderOpenPrice();
                     order_lots_48=OrderLots();
                    }
                 }
               if(OrderType()==OP_BUY || OrderType()==OP_SELL) Ld_64+=OrderProfit()+OrderCommission()+OrderSwap();
              }
            if(OrderMagicNumber()==MagicNumber+1)
              {
               if(OrderType()==OP_SELL)
                 {
                  count_80++;
                  if(OrderOpenPrice()>order_open_price_88)
                    {
                     order_open_price_88=OrderOpenPrice();
                     order_lots_96=OrderLots();
                    }
                 }
               if(OrderType()==OP_SELLSTOP)
                 {
                  count_84++;
                  order_lots_56=OrderLots();
                  if(OrderOpenPrice()>order_open_price_168) order_open_price_168=OrderOpenPrice();
                 }
               if(OrderType()==OP_BUY)
                 {
                  count_144++;
                  order_lots_136=OrderLots();
                 }
               if(OrderType()== OP_BUYSTOP) count_148++;
               if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)
                 {
                  if(OrderOpenPrice()<order_open_price_104)
                    {
                     order_open_price_104=OrderOpenPrice();
                     order_lots_112=OrderLots();
                    }
                 }
               if(OrderType()==OP_BUY || OrderType()==OP_SELL) Ld_128+=OrderProfit()+OrderCommission()+OrderSwap();
              }
           }
        }
     }
   if(count_152>0 && Ld_64>f0_6(Digits,order_lots_48,TakeProfit_AV))
     {
      Alert("fix profit s");
      f0_0(Symbol(),-1,MagicNumber);
      f0_10(Symbol(),-1,MagicNumber);
      return (0);
     }
   if(count_144>0 && Ld_128>f0_6(Digits,order_lots_112,TakeProfit_AV))
     {
      Alert("fix profit b");
      f0_0(Symbol(),-1,MagicNumber+1);
      f0_10(Symbol(),-1,MagicNumber+1);
      return (0);
     }
   if(count_20>0 && count_152>1 && NormalizeDouble(order_lots_72*koef_grid,f0_8())>order_lots_120)
     {
      Alert("lot grid buystop small, delete");
      f0_10(Symbol(),OP_BUYSTOP,MagicNumber);
      return (0);
     }
   if(count_84>0 && count_144>1 && NormalizeDouble(order_lots_136*koef_grid,f0_8())>order_lots_56)
     {
      Alert("lot grid sellstop small, delete");
      f0_10(Symbol(),OP_SELLSTOP,MagicNumber+1);
      return (0);
     }
   if(Gi_144>0)
     {
      if(A(count_20,count_16,order_open_price_160,Ask,steps,Gi_144,f0_9()))
        {
         f0_10(Symbol(),OP_BUYSTOP,MagicNumber);
         return (0);
        }
      if(A(count_84,count_80,Bid,order_open_price_168,steps,Gi_144,f0_9()))
        {
         f0_10(Symbol(),OP_SELLSTOP,MagicNumber+1);
         return (0);
        }
     }
   double Ld_180 = 0;
   double Ld_188 = 0;
   double Ld_196 = 0;
   if(AV)
     {
      if(B(count_144,order_open_price_104,Ask,count_148,exponents,level_OP,level_AV,f0_9(),f0_7(tf_aw),0))
        {
         Ld_180 = NormalizeDouble(f_lot_av * order_lots_112, f0_8());
         Gs_264 = "averaging_buy";
         Ld_196 = Ask + level_OP * f0_9();
         f0_11(Symbol(),OP_BUYSTOP,Ld_180,Ld_196,0,0,MagicNumber+1,0,Gs_264);
        }
      if(B(count_152,Bid,order_open_price_40,count_156,exponents,level_OP,level_AV,f0_9(),0,f0_7(tf_aw)))
        {
         Ld_188 = NormalizeDouble(f_lot_av * order_lots_48, f0_8());
         Gs_264 = "averaging_sell";
         Ld_196 = Bid - level_OP * f0_9();
         f0_11(Symbol(),OP_SELLSTOP,Ld_188,Ld_196,0,0,MagicNumber,0,Gs_264);
        }
     }
   if(Lock)
     {
      if(C(count_16,count_152,order_open_price_24,Ask,lock_pips,f0_9(),f0_7(tf_lock),0))
        {
         Ld_204=NormalizeDouble(order_lots_32*koef_lot_lock,f0_8());
         if(StopLoss_Lock>0) Ld_212=Ask+StopLoss_Lock*f0_9();
         else Ld_212=0;
         Gs_264="lock_buy";
         f0_12(Symbol(),OP_SELL,Ld_204,Ld_212,0,MagicNumber,Gs_264);
        }
      if(C(count_80,count_144,Bid,order_open_price_88,lock_pips,f0_9(),0,f0_7(tf_lock)))
        {
         Ld_204=NormalizeDouble(order_lots_96*koef_lot_lock,f0_8());
         if(StopLoss_Lock>0) Ld_212=Bid-StopLoss_Lock*f0_9();
         else Ld_212=0;
         Gs_264="lock_sell";
         f0_12(Symbol(),OP_BUY,Ld_204,Ld_212,0,MagicNumber+1,Gs_264);
        }
     }
   if(count_16>0 && count_84>0)
     {
      Alert("open buy grid, delete sellstop grid");
      f0_10(Symbol(),OP_SELLSTOP,MagicNumber+1);
      return (0);
     }
   if(count_80>0 && count_20>0)
     {
      Alert("open sell grid, delete buystop grid");
      f0_10(Symbol(),OP_BUYSTOP,MagicNumber);
      return (0);
     }
   double Ld_220 = 0;
   double Ld_228 = 0;
   if(D(count_16,count_20,count_80,count_144,count_148,f0_7(tf_grid),0))
     {
      G_price_248=Ask;
      for(int count_244=0; count_244<quantity; count_244++)
        {
         Gd_256 = E(G_price_248, start_recede, f0_9(), count_244, steps, f0_9());
         Gs_264 = "grid";
         if(StopLoss>0) Ld_220=Gd_256-StopLoss*f0_9();
         else Ld_220=0;
         Ld_228=NormalizeDouble(Gd_256+steps*f0_9() -(Ask-Bid),Digits);
         if(count_152>0) Ld_236=NormalizeDouble(order_lots_72*koef_grid,f0_8());
         else Ld_236=f0_4();
         f0_11(Symbol(),OP_BUYSTOP,Ld_236,Gd_256,Ld_220,Ld_228,MagicNumber,0,Gs_264);
        }
     }
   if(D(count_80,count_84,count_16,count_152,count_156,0,f0_7(tf_grid)))
     {
      G_price_248=Bid;
      for(int count_248=0; count_248<quantity; count_248++)
        {
         Gd_256 = E(G_price_248, -start_recede, f0_9(), -count_248, steps, f0_9());
         Gs_264 = "grid";
         if(StopLoss>0) Ld_220=Gd_256+StopLoss*f0_9();
         else Ld_220=0;
         Ld_228=NormalizeDouble(Gd_256-steps*f0_9()+(Ask-Bid),Digits);
         if(count_144>0) Ld_236=NormalizeDouble(order_lots_136*koef_grid,f0_8());
         else Ld_236=f0_4();
         f0_11(Symbol(),OP_SELLSTOP,Ld_236,Gd_256,Ld_220,Ld_228,MagicNumber+1,0,Gs_264);
        }
     }
   return (0);
  }
// 71A75A167C33C58BFB561764255C880A
int f0_7(int A_timeframe_0=0)
  {
   double ima_4=iMA(Symbol(),A_timeframe_0,Period_MA_1,0,ma_method,applied_price,shift);
   double ima_12 = iMA(Symbol(), A_timeframe_0, Period_MA_2, 0, ma_method, applied_price, shift);
   double ima_20 = iMA(Symbol(), A_timeframe_0, Period_MA_3, 0, ma_method, applied_price, shift);
   if(ima_4 > ima_20 && ima_12 > ima_20) return (1);
   if(ima_4 < ima_20 && ima_12 < ima_20) return (-1);
   return (0);
  }
// 4CA46AAB119D6115222154B9DE991BEE
double f0_4()
  {
   double free_magrin_0=0;
   if(Choice_method) free_magrin_0=AccountBalance();
   else free_magrin_0=AccountFreeMargin();
   double Ld_8=MarketInfo(Symbol(),MODE_MINLOT);
   double Ld_16 = MarketInfo(Symbol(), MODE_MAXLOT);
   double Ld_24 = Risk / 100.0;
   double Ld_ret_32=MathFloor(free_magrin_0*Ld_24/MarketInfo(Symbol(),MODE_MARGINREQUIRED)/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
   if(Lot>0.0) Ld_ret_32=Lot;
   if(Ld_ret_32 < Ld_8) Ld_ret_32 = Ld_8;
   if(Ld_ret_32> Ld_16) Ld_ret_32 = Ld_16;
   return (Ld_ret_32);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int A(int a1,int a2,double a3,double a4,int a5,int a6,double a7)
  {
   int v7;

   v7=0;
   if(true)
     {
      v7=1;
      if(a1<=0 || a2>=1 || (double)(a6+a5)*a7>=a3-a4) v7=0;
     }
   return (v7);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int B(int a1,double a2,double a3,int a4,double a5,int a6,int a7,double a8,int a9,int a10)
  {
   int v10;

   v10=0;
   if(true)
     {
      v10=1;
      if(a1<=0 || ((double)(a4+a1)*a5+1.0) *(double)(a7+a6)*a8>=a2-a3 || a9<=a10) v10=0;
     }
   return (v10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int C(int a1,int a2,double a3,double a4,int a5,double a6,int a7,int a8)
  {
   int v8;

   v8=0;
   if(true)
     {
      v8=1;
      if(a1<=0 || a2>=1 || (double)a5*a6>=a3-a4 || a7>=a8) v8=0;
     }
   return (v8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int D(int a1,int a2,int a3,int a4,int a5,int a6,int a7)
  {
   int result;

   result=0;
   if(true)
     {
      result=1;
      if(a5+a4+a3+a2+a1>=1 || a6<=a7) result=0;
     }
   return (result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double E(double a1,int a2,double a3,int a4,int a5,double a6)
  {
   double v7;

   v7=-1.0;
   if(true)
      v7=(double)a2*a3+a1+(double)(a5*a4)*a6;
   return (v7);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int error,int lang=0)
  {
   string ErrorNumber;
   switch(lang)
     {
      case 0:
        {
         switch(error)
           {
            case 0:
            case 1:     ErrorNumber = "Нет ошибки, но результат неизвестен";                        break;
            case 2:     ErrorNumber = "Общая ошибка";                                               break;
            case 3:     ErrorNumber = "Неправильные параметры";                                     break;
            case 4:     ErrorNumber = "Торговый сервер занят";                                      break;
            case 5:     ErrorNumber = "Старая версия клиентского терминала";                        break;
            case 6:     ErrorNumber = "Нет связи с торговым сервером";                              break;
            case 7:     ErrorNumber = "Недостаточно прав";                                          break;
            case 8:     ErrorNumber = "Слишком частые запросы";                                     break;
            case 9:     ErrorNumber = "Недопустимая операция нарушающая функционирование сервера";  break;
            case 64:    ErrorNumber = "Счет заблокирован";                                          break;
            case 65:    ErrorNumber = "Неправильный номер счета";                                   break;
            case 128:   ErrorNumber = "Истек срок ожидания совершения сделки";                      break;
            case 129:   ErrorNumber = "Неправильная цена";                                          break;
            case 130:   ErrorNumber = "Неправильные стопы";                                         break;
            case 131:   ErrorNumber = "Неправильный объем";                                         break;
            case 132:   ErrorNumber = "Рынок закрыт";                                               break;
            case 133:   ErrorNumber = "Торговля запрещена";                                         break;
            case 134:   ErrorNumber = "Недостаточно денег для совершения операции";                 break;
            case 135:   ErrorNumber = "Цена изменилась";                                            break;
            case 136:   ErrorNumber = "Нет цен";                                                    break;
            case 137:   ErrorNumber = "Брокер занят";                                               break;
            case 138:   ErrorNumber = "Новые цены - Реквот";                                        break;
            case 139:   ErrorNumber = "Ордер заблокирован и уже обрабатывается";                    break;
            case 140:   ErrorNumber = "Разрешена только покупка";                                   break;
            case 141:   ErrorNumber = "Слишком много запросов";                                     break;
            case 145:   ErrorNumber = "Модификация запрещена, так как ордер слишком близок к рынку";break;
            case 146:   ErrorNumber = "Подсистема торговли занята";                                 break;
            case 147:   ErrorNumber = "Использование даты истечения ордера запрещено брокером";     break;
            case 148:   ErrorNumber = "Количество открытых и отложенных ордеров достигло предела "; break;

            case 4000:  ErrorNumber = "Нет ошибки";                                                 break;
            case 4001:  ErrorNumber = "Неправильный указатель функции";                             break;
            case 4002:  ErrorNumber = "Индекс массива - вне диапазона";                             break;
            case 4003:  ErrorNumber = "Нет памяти для стека функций";                               break;
            case 4004:  ErrorNumber = "Переполнение стека после рекурсивного вызова";               break;
            case 4005:  ErrorNumber = "На стеке нет памяти для передачи параметров";                break;
            case 4006:  ErrorNumber = "Нет памяти для строкового параметра";                        break;
            case 4007:  ErrorNumber = "Нет памяти для временной строки";                            break;
            case 4008:  ErrorNumber = "Неинициализированная строка";                                break;
            case 4009:  ErrorNumber = "Неинициализированная строка в массиве";                      break;
            case 4010:  ErrorNumber = "Нет памяти для строкового массива";                          break;
            case 4011:  ErrorNumber = "Слишком длинная строка";                                     break;
            case 4012:  ErrorNumber = "Остаток от деления на ноль";                                 break;
            case 4013:  ErrorNumber = "Деление на ноль";                                            break;
            case 4014:  ErrorNumber = "Неизвестная команда";                                        break;
            case 4015:  ErrorNumber = "Неправильный переход";                                       break;
            case 4016:  ErrorNumber = "Неинициализированный массив";                                break;
            case 4017:  ErrorNumber = "Вызовы DLL не разрешены";                                    break;
            case 4018:  ErrorNumber = "Невозможно загрузить библиотеку";                            break;
            case 4019:  ErrorNumber = "Невозможно вызвать функцию";                                 break;
            case 4020:  ErrorNumber = "Вызовы внешних библиотечных функций не разрешены";           break;
            case 4021:  ErrorNumber = "Недостаточно памяти для строки, возвращаемой из функции";    break;
            case 4022:  ErrorNumber = "Система занята";                                             break;
            case 4050:  ErrorNumber = "Неправильное количество параметров функции";                 break;
            case 4051:  ErrorNumber = "Недопустимое значение параметра функции";                    break;
            case 4052:  ErrorNumber = "Внутренняя ошибка строковой функции";                        break;
            case 4053:  ErrorNumber = "Ошибка массива";                                             break;
            case 4054:  ErrorNumber = "Неправильное использование массива-таймсерии";               break;
            case 4055:  ErrorNumber = "Ошибка пользовательского индикатора";                        break;
            case 4056:  ErrorNumber = "Массивы несовместимы";                                       break;
            case 4057:  ErrorNumber = "Ошибка обработки глобальныех переменных";                    break;
            case 4058:  ErrorNumber = "Глобальная переменная не обнаружена";                        break;
            case 4059:  ErrorNumber = "Функция не разрешена в тестовом режиме";                     break;
            case 4060:  ErrorNumber = "Функция не подтверждена";                                    break;
            case 4061:  ErrorNumber = "Ошибка отправки почты";                                      break;
            case 4062:  ErrorNumber = "Ожидается параметр типа string";                             break;
            case 4063:  ErrorNumber = "Ожидается параметр типа integer";                            break;
            case 4064:  ErrorNumber = "Ожидается параметр типа double";                             break;
            case 4065:  ErrorNumber = "В качестве параметра ожидается массив";                      break;
            case 4066:  ErrorNumber = "Запрошенные исторические данные в состоянии обновления";     break;
            case 4067:  ErrorNumber = "Ошибка при выполнении торговой операции";                    break;
            case 4099:  ErrorNumber = "Конец файла";                                                break;
            case 4100:  ErrorNumber = "Ошибка при работе с файлом";                                 break;
            case 4101:  ErrorNumber = "Неправильное имя файла";                                     break;
            case 4102:  ErrorNumber = "Слишком много открытых файлов";                              break;
            case 4103:  ErrorNumber = "Невозможно открыть файл";                                    break;
            case 4104:  ErrorNumber = "Несовместимый режим доступа к файлу";                        break;
            case 4105:  ErrorNumber = "Ни один ордер не выбран";                                    break;
            case 4106:  ErrorNumber = "Неизвестный символ";                                         break;
            case 4107:  ErrorNumber = "Неправильный параметр цены для торговой функции";            break;
            case 4108:  ErrorNumber = "Неверный номер тикета";                                      break;
            case 4109:  ErrorNumber = "Торговля не разрешена";                                      break;
            case 4110:  ErrorNumber = "Длинные позиции не разрешены";                               break;
            case 4111:  ErrorNumber = "Короткие позиции не разрешены";                              break;
            case 4200:  ErrorNumber = "Объект уже существует";                                      break;
            case 4201:  ErrorNumber = "Запрошено неизвестное свойство объекта";                     break;
            case 4202:  ErrorNumber = "Объект не существует";                                       break;
            case 4203:  ErrorNumber = "Неизвестный тип объекта";                                    break;
            case 4204:  ErrorNumber = "Нет имени объекта";                                          break;
            case 4205:  ErrorNumber = "Ошибка координат объекта";                                   break;
            case 4206:  ErrorNumber = "Не найдено указанное подокно";                               break;
            case 4207:  ErrorNumber = "Ошибка при работе с объектом";                               break;
            default:    ErrorNumber = "Неизвестная ошибка";
           }
        }
      break;
      case 1:
        {
         switch(error)
           {
            case 0:
            case 1:   ErrorNumber="no error";                                                   break;
            case 2:   ErrorNumber="common error";                                               break;
            case 3:   ErrorNumber="invalid trade parameters";                                   break;
            case 4:   ErrorNumber="trade server is busy";                                       break;
            case 5:   ErrorNumber="old version of the client terminal";                         break;
            case 6:   ErrorNumber="no connection with trade server";                            break;
            case 7:   ErrorNumber="not enough rights";                                          break;
            case 8:   ErrorNumber="too frequent requests";                                      break;
            case 9:   ErrorNumber="malfunctional trade operation (never returned error)";       break;
            case 64:  ErrorNumber="account disabled";                                           break;
            case 65:  ErrorNumber="invalid account";                                            break;
            case 128: ErrorNumber="trade timeout";                                              break;
            case 129: ErrorNumber="invalid price";                                              break;
            case 130: ErrorNumber="invalid stops";                                              break;
            case 131: ErrorNumber="invalid trade volume";                                       break;
            case 132: ErrorNumber="market is closed";                                           break;
            case 133: ErrorNumber="trade is disabled";                                          break;
            case 134: ErrorNumber="not enough money";                                           break;
            case 135: ErrorNumber="price changed";                                              break;
            case 136: ErrorNumber="off quotes";                                                 break;
            case 137: ErrorNumber="broker is busy (never returned error)";                      break;
            case 138: ErrorNumber="requote";                                                    break;
            case 139: ErrorNumber="order is locked";                                            break;
            case 140: ErrorNumber="long positions only allowed";                                break;
            case 141: ErrorNumber="too many requests";                                          break;
            case 145: ErrorNumber="modification denied because order is too close to market";   break;
            case 146: ErrorNumber="trade context is busy";                                      break;
            case 147: ErrorNumber="expirations are denied by broker";                           break;
            case 148: ErrorNumber="amount of open and pending orders has reached the limit";    break;
            case 149: ErrorNumber="hedging is prohibited";                                      break;
            case 150: ErrorNumber="prohibited by FIFO rules";                                   break;
            //--- mql4 errors
            case 4000: ErrorNumber="no error (never generated code)";                           break;
            case 4001: ErrorNumber="wrong function pointer";                                    break;
            case 4002: ErrorNumber="array index is out of range";                               break;
            case 4003: ErrorNumber="no memory for function call stack";                         break;
            case 4004: ErrorNumber="recursive stack overflow";                                  break;
            case 4005: ErrorNumber="not enough stack for parameter";                            break;
            case 4006: ErrorNumber="no memory for parameter string";                            break;
            case 4007: ErrorNumber="no memory for temp string";                                 break;
            case 4008: ErrorNumber="non-initialized string";                                    break;
            case 4009: ErrorNumber="non-initialized string in array";                           break;
            case 4010: ErrorNumber="no memory for array\' string";                              break;
            case 4011: ErrorNumber="too long string";                                           break;
            case 4012: ErrorNumber="remainder from zero divide";                                break;
            case 4013: ErrorNumber="zero divide";                                               break;
            case 4014: ErrorNumber="unknown command";                                           break;
            case 4015: ErrorNumber="wrong jump (never generated error)";                        break;
            case 4016: ErrorNumber="non-initialized array";                                     break;
            case 4017: ErrorNumber="dll calls are not allowed";                                 break;
            case 4018: ErrorNumber="cannot load library";                                       break;
            case 4019: ErrorNumber="cannot call function";                                      break;
            case 4020: ErrorNumber="expert function calls are not allowed";                     break;
            case 4021: ErrorNumber="not enough memory for temp string returned from function";  break;
            case 4022: ErrorNumber="system is busy (never generated error)";                    break;
            case 4023: ErrorNumber="dll-function call critical error";                          break;
            case 4024: ErrorNumber="internal error";                                            break;
            case 4025: ErrorNumber="out of memory";                                             break;
            case 4026: ErrorNumber="invalid pointer";                                           break;
            case 4027: ErrorNumber="too many formatters in the format function";                break;
            case 4028: ErrorNumber="parameters count is more than formatters count";            break;
            case 4029: ErrorNumber="invalid array";                                             break;
            case 4030: ErrorNumber="no reply from chart";                                       break;
            case 4050: ErrorNumber="invalid function parameters count";                         break;
            case 4051: ErrorNumber="invalid function parameter value";                          break;
            case 4052: ErrorNumber="string function internal error";                            break;
            case 4053: ErrorNumber="some array error";                                          break;
            case 4054: ErrorNumber="incorrect series array usage";                              break;
            case 4055: ErrorNumber="custom indicator error";                                    break;
            case 4056: ErrorNumber="arrays are incompatible";                                   break;
            case 4057: ErrorNumber="global variables processing error";                         break;
            case 4058: ErrorNumber="global variable not found";                                 break;
            case 4059: ErrorNumber="function is not allowed in testing mode";                   break;
            case 4060: ErrorNumber="function is not confirmed";                                 break;
            case 4061: ErrorNumber="send mail error";                                           break;
            case 4062: ErrorNumber="string parameter expected";                                 break;
            case 4063: ErrorNumber="integer parameter expected";                                break;
            case 4064: ErrorNumber="double parameter expected";                                 break;
            case 4065: ErrorNumber="array as parameter expected";                               break;
            case 4066: ErrorNumber="requested history data is in update state";                 break;
            case 4067: ErrorNumber="internal trade error";                                      break;
            case 4068: ErrorNumber="resource not found";                                        break;
            case 4069: ErrorNumber="resource not supported";                                    break;
            case 4070: ErrorNumber="duplicate resource";                                        break;
            case 4071: ErrorNumber="custom indicator cannot initialize";                        break;
            case 4099: ErrorNumber="end of file";                                               break;
            case 4100: ErrorNumber="some file error";                                           break;
            case 4101: ErrorNumber="wrong file name";                                           break;
            case 4102: ErrorNumber="too many opened files";                                     break;
            case 4103: ErrorNumber="cannot open file";                                          break;
            case 4104: ErrorNumber="incompatible access to a file";                             break;
            case 4105: ErrorNumber="no order selected";                                         break;
            case 4106: ErrorNumber="unknown symbol";                                            break;
            case 4107: ErrorNumber="invalid price parameter for trade function";                break;
            case 4108: ErrorNumber="invalid ticket";                                            break;
            case 4109: ErrorNumber="trade is not allowed in the expert properties";             break;
            case 4110: ErrorNumber="longs are not allowed in the expert properties";            break;
            case 4111: ErrorNumber="shorts are not allowed in the expert properties";           break;
            case 4200: ErrorNumber="object already exists";                                     break;
            case 4201: ErrorNumber="unknown object property";                                   break;
            case 4202: ErrorNumber="object does not exist";                                     break;
            case 4203: ErrorNumber="unknown object type";                                       break;
            case 4204: ErrorNumber="no object name";                                            break;
            case 4205: ErrorNumber="object coordinates error";                                  break;
            case 4206: ErrorNumber="no specified subwindow";                                    break;
            case 4207: ErrorNumber="graphical object error";                                    break;
            case 4210: ErrorNumber="unknown chart property";                                    break;
            case 4211: ErrorNumber="chart not found";                                           break;
            case 4212: ErrorNumber="chart subwindow not found";                                 break;
            case 4213: ErrorNumber="chart indicator not found";                                 break;
            case 4220: ErrorNumber="symbol select error";                                       break;
            case 4250: ErrorNumber="notification error";                                        break;
            case 4251: ErrorNumber="notification parameter error";                              break;
            case 4252: ErrorNumber="notifications disabled";                                    break;
            case 4253: ErrorNumber="notification send too frequent";                            break;
            case 5001: ErrorNumber="too many opened files";                                     break;
            case 5002: ErrorNumber="wrong file name";                                           break;
            case 5003: ErrorNumber="too long file name";                                        break;
            case 5004: ErrorNumber="cannot open file";                                          break;
            case 5005: ErrorNumber="text file buffer allocation error";                         break;
            case 5006: ErrorNumber="cannot delete file";                                        break;
            case 5007: ErrorNumber="invalid file handle (file closed or was not opened)";       break;
            case 5008: ErrorNumber="wrong file handle (handle index is out of handle table)";   break;
            case 5009: ErrorNumber="file must be opened with FILE_WRITE flag";                  break;
            case 5010: ErrorNumber="file must be opened with FILE_READ flag";                   break;
            case 5011: ErrorNumber="file must be opened with FILE_BIN flag";                    break;
            case 5012: ErrorNumber="file must be opened with FILE_TXT flag";                    break;
            case 5013: ErrorNumber="file must be opened with FILE_TXT or FILE_CSV flag";        break;
            case 5014: ErrorNumber="file must be opened with FILE_CSV flag";                    break;
            case 5015: ErrorNumber="file read error";                                           break;
            case 5016: ErrorNumber="file write error";                                          break;
            case 5017: ErrorNumber="string size must be specified for binary file";             break;
            case 5018: ErrorNumber="incompatible file (for string arrays-TXT, for others-BIN)"; break;
            case 5019: ErrorNumber="file is directory, not file";                               break;
            case 5020: ErrorNumber="file does not exist";                                       break;
            case 5021: ErrorNumber="file cannot be rewritten";                                  break;
            case 5022: ErrorNumber="wrong directory name";                                      break;
            case 5023: ErrorNumber="directory does not exist";                                  break;
            case 5024: ErrorNumber="specified file is not directory";                           break;
            case 5025: ErrorNumber="cannot delete directory";                                   break;
            case 5026: ErrorNumber="cannot clean directory";                                    break;
            case 5027: ErrorNumber="array resize error";                                        break;
            case 5028: ErrorNumber="string resize error";                                       break;
            case 5029: ErrorNumber="structure contains strings or dynamic arrays";              break;
            default:   ErrorNumber="unknown error";
           }
        }
      break;
     }
   return (ErrorNumber);
  }
//+------------------------------------------------------------------+
