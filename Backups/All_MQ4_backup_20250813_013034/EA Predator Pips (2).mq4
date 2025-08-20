//+------------------------------------------------------------------+
//|                            dr. Felik Admaja                      |
//|                            Jasa Pembuatan Robot Forex (EA)       |
//|                            http://efexrobot.com                  |
//|                            Handphone: 0821 344 35 666            | 
//|                                                                  |  
//+------------------------------------------------------------------+
 
#property copyright "ninjaa trader" 
#property link      "http://cafetrader.blogspot.com"     
   

// LIMIT ACCOUNT DAN KADALUARSA

//  GANTI NOMOR ACCOUNT DENGAN NOMOR ACCOUNT KLIEN YANG BELI EA ANDA
//  JIKA = 0, MAKA SEMUA NOMOR ACCOUNT BISA DIPAKAI
int     NomorAccount         = 0;


// GANTI TANGGAL DIBAWAH SESUAI DENGAN KADALUARSA YANG ANDA INGINKAN
// FORMAT TANGGAL ADALAH "TAHUN.BULAN.TANGGAL  JAM:MENIT"
string  Kadaluarsa           = "2029.9.12 00:00";


//+==================================================================+
//| CARA MENGKOMPILE                                                 |
//| Klik tombol Compile (centang hijau) di panel atas.               |
//| Lihat pesan yang muncul di bagian bawah, jika ada pesan error    |
//| Berarti proses mengkompile tidak berhasil dan Anda salah input   |
//+==================================================================+



extern string _EA                            = "___EA PREDATOR PIPS___";
extern int    Magic                          = 20121218;
extern bool   Use_Compund                    = true;
extern double Kelipatan_Kompon               = 80000; 
extern double Lots                           = 0.1;
extern double Penentu_Lot                    = 5; 


extern int    TakeProfit                     = 10; 
extern int    StopLoss                       = 0; 
extern int    Minimal_Step                   = 20;
extern double Max_Lot                        = 20;
extern int    Max_Level                      = 15; 


extern int    TP_In_Money                    = 0;
extern int    SL_In_Money                    = 0;



extern string _MOVING_AVERAGES               = "_______MA INDICATOR______";
extern int    Level_Atas                     = 60;
extern int    Level_Bawah                    = 60;
extern int    MA_Period                      = 100;
extern int    MA_Method                      = 0;
extern string MA_MethoD                      = "0=simple 1=exponential 2=smoothed 3=linear weighted";
extern int    aplied_price                   = 0;
extern string aplied_pricE                   = "0=CLOSE 1=OPEN 2=HIGH 3=LOW 4=MEDIAN 5=TYPICAL 6=WEIGHTED";
extern int    MA_shift                       = 1;
double MA, ma_atas, ma_bawah;

extern string _UNI_CROSS                     = "____ UNI CROSS ____"; 
extern bool   UseSound                       = false;
extern bool   TypeCHart                      = false;
extern bool   UseAlert                       = true;
extern string NameFileSound                  = "alert.wav";
extern int    T3Period                       = 14;
extern int    T3Price                        = 0;
extern double b                              = 0.618;
extern int    Snake_HalfCycle                = 5;
extern int    Inverse                        = 0;
extern int    DeltaForSell                   = 0;
extern int    DeltaForBuy                    = 0;
double panah_biru, panah_merah;
 

extern string _TIMEFILTER                    = "_______ TIME FILTER KOMPUTER_______";
extern bool    Use_TimeFilter                = false;
extern int     StartHour                     = 0;
extern int     EndHour                       = 24;
int    EndHour1, StartHour1, GMTOffset;
string comment1;

 


int    Trailing_Stop                  = 0;
double MinLots, MaxLots, minlot, TPBuy, SLBuy;
int    DIGIT, convert, slippage=10, spread, stoplevel;
double last_lot_sell, last_price_sell, last_lot_buy, last_price_buy, last_price, last_lot;
int    last_type, pending, OpenOrders, cnt, openbuy, opensell;
bool   CLOSE, DELETE;
datetime time;
double SL;
double Lot_Marti;
double harga; 
double last_tp, last_sl;
int    pendingsell=0,pendingbuy=0;
double last_tp_buy, last_tp_sell, last_sl_buy, last_sl_sell;

int buystop=0;
int buylimit=0;
int sellstop=0;
int selllimit=0;
double konversi_kompon; 
int komponen_buy=0;
int komponen_sell=0;
double lot_op1_buy, harga_op1_buy, lot_op1_sell, harga_op1_sell;
double rata_buy, rata_sell;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
if (!IsExpertEnabled()) {Alert ("EA BELUM AKTIF, KLIK TOMBOL AKTIVASI EA");}
if (!IsTradeAllowed())  {Alert ("EA BELUM AKTIF, CENTANG PADA ALLOW LIVE TRADING");}
Level_Atas = MathAbs (Level_Atas);
Level_Bawah = MathAbs (Level_Bawah);


start();

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
openord();
if (OpenOrders>0)
   {
      Alert ("EA RESET");
      Alert ("JANGAN MERESET EA SELAGI ADA ORDER");
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {

minlot =MarketInfo(Symbol(),MODE_MINLOT);
if (minlot/0.01==1) {DIGIT=2;} else {DIGIT=1;}
if (MarketInfo (Symbol(), MODE_LOTSTEP)*10<1)  {DIGIT=2;} else {DIGIT=1;}
if (Digits==5 ||Digits==3 || Symbol()=="GOLD" || Symbol()=="GOLD." || Symbol()=="GOLDm") {convert=10; slippage=100;} else {convert=1;}
MinLots = NormalizeDouble((MarketInfo(Symbol(), MODE_MINLOT)),DIGIT);
MaxLots = NormalizeDouble((MarketInfo(Symbol(), MODE_MAXLOT)),DIGIT);
if (Use_Compund) {Lots = AccountBalance()/Kelipatan_Kompon;} 
if(Lots<MinLots){Lots=MinLots;}
if(Lots>MaxLots){Lots=MaxLots;}
Lots = NormalizeDouble (Lots,DIGIT);
stoplevel=NormalizeDouble(MarketInfo(Symbol(),MODE_STOPLEVEL),2);
spread = NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),2);
if (Trailing_Stop*convert<stoplevel+spread && Trailing_Stop!=0) {Trailing_Stop=(stoplevel+spread)/convert;}
if (TakeProfit*convert<stoplevel && TakeProfit!=0) {TakeProfit=(stoplevel)/convert;} 
if (StopLoss*convert<stoplevel+spread && StopLoss!=0) {StopLoss=(stoplevel+spread)/convert;}





MA = iMA(NULL,0,MA_Period,0,MA_Method,aplied_price,1);
ma_atas  = MA + Level_Atas * convert * Point;
ma_bawah = MA - Level_Bawah * convert * Point;

panah_biru = iCustom(NULL, 0, "uni_cross",UseSound, TypeCHart, UseAlert, NameFileSound, T3Period, T3Price, b, Snake_HalfCycle, Inverse, DeltaForSell, DeltaForBuy, 0,1);
panah_merah = iCustom(NULL, 0, "uni_cross",UseSound, TypeCHart, UseAlert, NameFileSound, T3Period, T3Price, b, Snake_HalfCycle, Inverse, DeltaForSell, DeltaForBuy, 1,1);




openord();
if (Use_Compund) { konversi_kompon =  MathMax (lot_op1_buy, lot_op1_sell) *100;} else {konversi_kompon=1;}
if (konversi_kompon==0) {konversi_kompon=1;}
if (TP_In_Money!=0 && ProfitInMoney(OP_BUY)>=TP_In_Money*konversi_kompon   && openbuy>0)    {CloseAll(0); CloseAll(2); CloseAll(4); Alert ("TP IN MONEY");}
if (TP_In_Money!=0 && ProfitInMoney(OP_SELL)>=TP_In_Money*konversi_kompon  && opensell>0)   {CloseAll(1); CloseAll(3); CloseAll(5); Alert ("TP IN MONEY");}
if (SL_In_Money!=0 && ProfitInMoney(OP_BUY)<=-SL_In_Money*konversi_kompon  && openbuy>0)    {CloseAll(0); CloseAll(2); CloseAll(4); Alert ("SL IN MONEY");}
if (SL_In_Money!=0 && ProfitInMoney(OP_SELL)<=-SL_In_Money*konversi_kompon && opensell>0)   {CloseAll(1); CloseAll(3); CloseAll(5); Alert ("SL IN MONEY");}





openord();
if (openbuy==0 && pendingbuy>0)   {CloseAll(2);}
if (opensell==0 && pendingsell>0) {CloseAll(3);}




openord();
if (TimeFilter() && kadaluarsa() && LoginNumber())
   {
      if (openbuy==0 && pendingbuy==0 && buy() && buy_uni() && sudah_open_candle_ini(OP_BUY)==false)
         {
            if (OPEN (Symbol(), OP_BUY, Blue, Lots, slippage, Ask, false, 0, 0, "", Magic))
               {time=iTime (Symbol(),0,0);}
         } 
      if (opensell==0 && pendingsell==0 && sell() && sell_uni() && sudah_open_candle_ini(OP_SELL)==false)
         {
            if (OPEN (Symbol(), OP_SELL, Red, Lots, slippage, Bid, false, 0, 0, "", Magic))
               {time=iTime (Symbol(),0,0);}
         }
   }  



//+------------------------------------------------------------------+
//| OPEN MARTINGALE HYBRID                                           |
//+------------------------------------------------------------------+
openord();
if (openbuy>0 && openbuy<Max_Level && pendingbuy==0  && buy() && buy_uni() && sudah_open_candle_ini(OP_BUY)==false)
   {
      Lot_Marti = NormalizeDouble (((harga_op1_buy - Ask)/(convert*Point))*lot_op1_buy/Penentu_Lot, DIGIT);
      
      if (Lot_Marti>Max_Lot) {return (0);}
      harga = last_price_buy-Minimal_Step*convert*Point;
      if (Ask<=harga)
         {
            if (OPEN (Symbol(), OP_BUY, Blue, Lot_Marti, slippage, Ask, false, 0, 0, "", Magic))
               {time=iTime (Symbol(),0,0);}
         }        
   }

//+------------------------------------------------------------------+
//| OPEN MARTINGALE HYBRID                                           | 
//+------------------------------------------------------------------+
openord();
if (opensell>0 && opensell<Max_Level && pendingsell==0 && sudah_open_candle_ini(OP_SELL)==false)
   {
      Lot_Marti = NormalizeDouble (((Bid - harga_op1_sell)/(convert*Point))*lot_op1_sell/Penentu_Lot, DIGIT);
      if (Lot_Marti>Max_Lot) {return (0);}
      harga = last_price_sell+Minimal_Step*convert*Point;  
      if (Bid>=harga)  
         { 
            if (OPEN (Symbol(), OP_SELL, Red, Lot_Marti, slippage, Bid, false, 0, 0, "", Magic))
               {time=iTime (Symbol(),0,0);}
         }
   }



openord(); 
rata_buy  = rata_price(OP_BUY);
rata_sell = rata_price(OP_SELL);


if (TakeProfit!=0) {ModifyTP(OP_BUY, rata_buy + TakeProfit*convert*Point);}
if (TakeProfit!=0) {ModifyTP(OP_SELL, rata_sell - TakeProfit*convert*Point);}
if (StopLoss!=0) {ModifySL(OP_BUY,  rata_buy-StopLoss*convert*Point);}
if (StopLoss!=0) {ModifySL(OP_SELL, rata_sell+StopLoss*convert*Point);}
  

komentar (1, "MAGIC", DoubleToStr (Magic,0));
komentar (2, "NAMA", AccountName());
komentar (3, "No. ACC", AccountNumber());
komentar (4, "BROKER", AccountCompany());
komentar (5, "LEVERAGE", "1:"+DoubleToStr(AccountLeverage(),0));
komentar (6, "BALANCE", DoubleToStr (AccountBalance(),2));
komentar (7, "EQUITY", DoubleToStr (AccountEquity(),2));


if (GetLastError()==134) {Alert ("BALANCE TIDAK CUKUP UNTUK MEMBUKA ORDER"); return (0);}


   return(0);
  }
//+------------------------------------------------------------------+

bool kadaluarsa()
{datetime kada  = StrToTime(Kadaluarsa); if (TimeCurrent()>kada) {Alert ("Expert Advisor has expired");return (false);} else {return (true);}}


bool LoginNumber()
{if (AccountNumber()==NomorAccount || NomorAccount == 0 ) {return (true);} else {Alert ("Login Number dont match "); return (false);}}

 
 
 
double ProfitInMoney(int tipe)
{
double Profit=0;
for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==tipe) )
	     {Profit = Profit + OrderProfit() + OrderSwap() + OrderCommission();}
   }
return (Profit);
}   
 
 
 
double rata_price(int tipe)
{
double total_lot=0; 
double total_kali=0; 
double rata_price=0;
for(cnt=0;cnt<OrdersTotal();cnt++)   
   { 
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==tipe))
	     {
	       total_lot  = total_lot + OrderLots();
	       total_kali = total_kali + (OrderLots() * OrderOpenPrice());
	     } 
   }
if (total_lot!=0) {rata_price = total_kali / total_lot;} else {rata_price = 0;}
return (rata_price);
}




bool sudah_open_candle_ini(int tipe)
{
bool sudahopenhariini=false;  
for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==tipe )
	     {
	        if (OrderOpenTime()>=iTime(Symbol(),0,0)) {sudahopenhariini=true;}
	     }
   }
for(cnt=0;cnt<OrdersHistoryTotal();cnt++)     
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==tipe)
	     {  
	        if (OrderOpenTime()>=iTime(Symbol(),0,0)) {sudahopenhariini=true;}
	     }
   }
      
return (sudahopenhariini);
   
}


bool buy()
{
   if (Close[1]<=ma_bawah) {return (true);} else {return (false);}
}
bool sell()
{
   if (Close[1]>=ma_atas) {return (true);} else {return (false);}
}

bool buy_uni()
{ 
   if (panah_biru>0 && panah_biru<999999) {return (true);} else {return (false);}
} 
bool sell_uni()
{ 
   if (panah_merah>0 && panah_merah<999999) {return (true);} else {return (false);}
} 




void ModifyTP(int tipe, double TP) // TP disini diambil dari OrderTakeProfit() dari OP terakhir 
{ 
for (cnt = OrdersTotal(); cnt >= 0; cnt--) 
    {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==Magic && (OrderType()==tipe) && (tipe==OP_BUY || tipe==OP_BUYSTOP || tipe==OP_BUYLIMIT)   ) 
         {
           if (NormalizeDouble (OrderTakeProfit(),Digits)!=NormalizeDouble (TP,Digits) && NormalizeDouble (TP,Digits)-Ask>=stoplevel*Point)
              {
                OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble (TP,Digits), 0, CLR_NONE);
              }
         }
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==Magic && (OrderType()==tipe) && (tipe==OP_SELL || tipe==OP_SELLSTOP || tipe==OP_SELLLIMIT)) 
         {
           if (NormalizeDouble (OrderTakeProfit(),Digits)!=NormalizeDouble (TP,Digits) && Bid-NormalizeDouble (TP,Digits)>=stoplevel*Point)
              {
                OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble (TP,Digits), 0, CLR_NONE);
              }
         }   
     }
}    


void ModifySL(int tipe, double SL) // TP disini diambil dari OrderTakeProfit() dari OP terakhir 
{
for (cnt = OrdersTotal(); cnt >= 0; cnt--) 
    { 
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber()==Magic && (OrderType()==tipe) ) 
         {
           if (NormalizeDouble (OrderStopLoss(),Digits)!=NormalizeDouble (SL,Digits))
              {
                OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble (SL,Digits), OrderTakeProfit(), 0, CLR_NONE);
              }
         }
     }
}    


void komentar (int baris, string label1, string label2)
{
if (!IsTradeAllowed() || !IsExpertEnabled()) {ObjectDelete("baris0"); return (0);} 
int x,y;
switch(baris)
      {
         case 1: x=40; y=60;   break;  
         case 2: x=40; y=75;   break;
         case 3: x=40; y=90;   break;
         case 4: x=40; y=105;   break;
         case 5: x=40; y=120;   break;
         case 6: x=40; y=135;   break;
         case 7: x=40; y=150;   break;
         case 8: x=40; y=165;   break;
         case 9: x=40; y=180;   break;
         case 10: x=40; y=195;   break;
         case 11: x=40; y=210;   break;
         case 12: x=40; y=225;   break;
         case 13: x=40; y=240;   break;
         case 14: x=40; y=255;   break;
         case 15: x=40; y=270;   break;
         case 16: x=40; y=285;   break;
         case 17: x=40; y=300;   break;
      }
Monitor("baris0", WindowExpertName()+ " IS RUNNING", 10, 40, 20, Yellow,0);
Monitor("baris00", "Ninjaa Trader 082199976000", 8, 40, 10, Yellow,2);
Monitor("baris"+baris, label1, 8, x, y, Yellow,0);
Monitor("baris_"+baris, ":", 8, x+150, y, Yellow,0);
Monitor("baris-"+baris, label2, 8, x+160, y, Yellow,0);
}



void Monitor(string nama, string isi, int ukuran, int x, int y, color warna, int pojok)
{
  if (ObjectFind(nama)<0) {ObjectCreate  (nama,OBJ_LABEL,0,0,0,0,0);}
  ObjectSet     (nama,OBJPROP_CORNER,pojok);
  ObjectSet     (nama,OBJPROP_XDISTANCE,x);
  ObjectSet     (nama,OBJPROP_YDISTANCE,y);
  ObjectSetText (nama,isi,ukuran,"Tahoma",warna);
}





bool OPEN (string symbol, int tipe, color warna, double Lots, double slippage, double harga, bool hidden_mode, double StopLoss, double TakeProfit, string komen, int Magic  )
{
     double TP, SL;
     int ticket=0;
     //while (ticket<=0)
     //      {
             RefreshRates();
             stoplevel=NormalizeDouble(MarketInfo(Symbol(),MODE_STOPLEVEL),0);
             spread = NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),0);
             if (tipe==OP_BUY || tipe==OP_BUYLIMIT || tipe==OP_BUYSTOP)
                {
                  if (TakeProfit*convert>stoplevel && !hidden_mode)            {TP=harga+TakeProfit*convert*Point;} else {TP=0;}
                  if (StopLoss*convert>stoplevel+spread && !hidden_mode)       {SL=harga-StopLoss*convert*Point;}   else {SL=0;} 
                  if (StopLoss==0) {SL=0;}
                }
                
             if (tipe==OP_SELL || tipe==OP_SELLLIMIT || tipe==OP_SELLSTOP)
                {
                  if (TakeProfit*convert>stoplevel && !hidden_mode)         {TP=harga-TakeProfit*convert*Point;} else {TP=0;}
                  if (StopLoss*convert>stoplevel+spread && !hidden_mode)    {SL=harga+StopLoss*convert*Point;}   else {SL=0;} 
                  if (StopLoss==0) {SL=0;}
                }
                
             ticket = OrderSend(symbol,tipe,Lots,NormalizeDouble (harga,Digits) ,slippage,SL,TP,komen,Magic,0,warna);
             if (ticket<=0) {Sleep(1000);} else {return (true);}
     //      }
     
}

bool TimeFilter()
{
EndHour1=EndHour+GMTOffset;
StartHour1=StartHour+GMTOffset;
if ((StartHour+GMTOffset)<0)  {StartHour1=StartHour+GMTOffset+24;} 
if ((EndHour+GMTOffset)<0)    {EndHour1=EndHour+GMTOffset+24;}     
if ((StartHour+GMTOffset)>24) {StartHour1=StartHour+GMTOffset-24;} 
if ((EndHour+GMTOffset)>24)   {EndHour1=EndHour+GMTOffset-24;}    


if (Use_TimeFilter==false) {return (true);}
      else 



if (StartHour1<EndHour1)
       {
         if (TimeHour(TimeLocal())>=StartHour1 && TimeHour(TimeLocal())<EndHour1){return (true);} else {return (false);}
       }

     else
     
if (StartHour1>EndHour1)

       {
         if (TimeHour(TimeLocal())>=StartHour1 || TimeHour(TimeLocal())<EndHour1){return (true);} else {return (false);}
       }

}





void openord()
{
OpenOrders=0; openbuy=0; opensell=0; pending=0;
pendingsell=0;  pendingbuy=0;
buystop=0;
buylimit=0;
sellstop=0;
selllimit=0;
komponen_buy=0;
komponen_sell=0;

for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_BUY )
	     {
	        if (StringFind (OrderComment(),"",0)>=0)
	           {
	              lot_op1_buy = OrderLots();
	              harga_op1_buy = OrderOpenPrice();
	           }
	     }
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_SELL )
	     {
	        if (StringFind (OrderComment(),"",0)>=0)
	           {
	              lot_op1_sell = OrderLots();
	              harga_op1_sell = OrderOpenPrice();
	           }
	     }   
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==OP_BUY ||OrderType()==OP_SELL))
	     {
	       OpenOrders++;
	       last_price = OrderOpenPrice();
	       last_lot   = OrderLots();
	       last_type  = OrderType();
	       last_tp    = OrderTakeProfit();
	       last_sl    = OrderStopLoss();
	     }
     
     if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_BUYSTOP )
	     {
	        buystop++;
	        komponen_buy++;
	     }
	  
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_BUYLIMIT )
	     {
	        buylimit++;
	        komponen_buy++;
	     }   
	  
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic &&  OrderType()==OP_SELLSTOP )
	     {
	        sellstop++;
	        komponen_sell++;
	     }  
	   
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_SELLLIMIT)
	     {
	        selllimit++;
	        komponen_sell++;
	     } 
     
     if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT))
	     {pending++;}
     
     if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT))
	     {pendingsell++;}
	     
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP))
	     {pendingbuy++;}
	        
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_BUY)
	     {
	        openbuy++;
	        komponen_buy++;
	        last_price_buy = OrderOpenPrice();
	        last_tp_buy    = OrderTakeProfit();
	        last_sl_buy    = OrderStopLoss();
	        last_lot_buy   = OrderLots();
	     }
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderType()==OP_SELL)
	     {   
	        opensell++;
	        komponen_sell++;
	        last_price_sell = OrderOpenPrice();
	        last_lot_sell   = OrderLots();
	        last_tp_sell    = OrderTakeProfit();
	        last_sl_sell    = OrderStopLoss();
	     }
   }
}



// BUY = 0
// SELL = 1
// BUYLIMIT=2
// SELLIMIT=3
// BUYSTOP = 4
// SELLSTOP = 5
void CloseAll(int tipe)
{
    CLOSE=false;
    DELETE=false;
    for(cnt=OrdersTotal();cnt>=0;cnt--)
       {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	      if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
	         {
	   	    if (OrderType()==OP_BUY && (tipe==0 || tipe==7)) 
	   	       {
	   	         
	   	         int retry=0;
	   	         while (CLOSE==false) 
		   	             { 
		   	              RefreshRates();
		   	              CLOSE = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue); 
   	   	              if (CLOSE==false) {Sleep(1000); retry++;}
		   	              if (GetLastError()==4108 || GetLastError()==145) {CLOSE=true;}
		   	             } 
		   	       CLOSE=false;
	   	       }
		       if (OrderType()==OP_SELL && (tipe==1 || tipe==7)) 
		          {
		            
		            retry=0;
		            while (CLOSE==false) 
		   	             {
		   	               RefreshRates();
		   	               CLOSE = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Red); 
		   	               if (CLOSE==false) {Sleep(1000); retry++;}
		   	               if (GetLastError()==4108 || GetLastError()==145) {CLOSE=true;}
		   	             } 
		   	       CLOSE=false;
		          }
		             
		      }
	    }
	 for(cnt=OrdersTotal();cnt>=0;cnt--)
       {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	      if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
	         {
	   	    
		       if (OrderType()==OP_BUYLIMIT && (tipe==2 || tipe==7)) 
		          {
		            
		            retry=0;
		            while (DELETE==false)
			               {
			                 RefreshRates();
			                 DELETE = OrderDelete(OrderTicket()); 
			                 if (DELETE==false) {Sleep(1000); retry++;}
			                 if (GetLastError()==4108 || GetLastError()==145) {DELETE=true;}
			               }
			          DELETE=false;
		          }
		       if (OrderType()==OP_SELLLIMIT && (tipe==3 || tipe==7)) 
		          {
		            retry=0;
		            while (DELETE==false)
			               {
			                 RefreshRates();
			                 DELETE = OrderDelete(OrderTicket()); 
			                 if (DELETE==false) {Sleep(1000); retry++;}
			                 if (GetLastError()==4108 || GetLastError()==145) {DELETE=true;}
			               }
			          DELETE=false;
		          } 
		       if (OrderType()==OP_BUYSTOP && (tipe==4 || tipe==7)) 
		          {
		            retry=0;
		            while (DELETE==false)
			               {
			                 RefreshRates();
			                 DELETE = OrderDelete(OrderTicket()); 
			                 if (DELETE==false) {Sleep(1000); retry++;}
			                 if (GetLastError()==4108 || GetLastError()==145) {DELETE=true;}
			               }
			          DELETE=false;
		          }  
		       if (OrderType()==OP_SELLSTOP && (tipe==5 || tipe==7)) 
		          {
		            retry=0;
		            while (DELETE==false)
			               {
			                 RefreshRates();
			                 DELETE = OrderDelete(OrderTicket()); 
			                 if (DELETE==false) {Sleep(1000); retry++;}
			                 if (GetLastError()==4108 || GetLastError()==145) {DELETE=true;}
			               }
			          DELETE=false;
		          }                    
		      }
	    }
}