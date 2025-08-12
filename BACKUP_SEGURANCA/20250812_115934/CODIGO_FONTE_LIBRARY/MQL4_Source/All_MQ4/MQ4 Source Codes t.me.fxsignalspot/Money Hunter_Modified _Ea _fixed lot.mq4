//+------------------------------------------------------------------+
//|                                                        |
//|                                              |
//|                                            |
//+------------------------------------------------------------------+
#property copyright "https://fxshop4.com/"
#property link      "https://fxshop4.com/"
#property version   ""
#property strict

#include <stderror.mqh>
#include <stdlib.mqh>

#import   "kernel32.dll"
int CreateFileW(string Filename,int AccessMode,int ShareMode,int PassAsZero,int CreationMode,int FlagsAndAttributes,int AlsoPassAsZero);
int GetFileSize(int FileHandle,int PassAsZero);
int SetFilePointer(int FileHandle,int Distance,int &PassAsZero[],int FromPosition);
int ReadFile(int FileHandle,uchar &BufferPtr[],int BufferLength,int  &BytesRead[],int PassAsZero);
int CloseHandle(int FileHandle);
#import


string Ordercomment="";
int Slippage=3;

int    Retries=10;

bool   AutoTrade=true;

bool   ecnBroker=false;

input int MagicID=12345678;
input double LOTS=0.01;
input int risk=0;//risk: 0-->fixed lots
input double SL=50;
input double TP=100;
extern bool Trailing = true;
extern double TrailingExtra = 50.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
union Price
  {
   uchar             buffer[8];
   double            close;
  };

double data[][2];

int BytesToRead;
string    datapath;
string    result;
Price     m_price;

double g_Point=100;
int    ticket=0;
//datetime expDate=D'2029.10.12 02:00';//yyyy.mm.dd
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!IsDllsAllowed())
     {
      Alert("Make Sure DLL Import is Allowed");
      ExpertRemove();
      return(INIT_FAILED);
     }
   ///if(TimeCurrent()>expDate)
     {
     /// MessageBox("The version has expired, contact forexea333@gmail.com");
      //ExpertRemove();
     /// return(INIT_FAILED);
     }

 
//------------------------------------------------------
     {
      //---
      g_Point=Point;
      if(Digits==5 || Digits==3)
        {
         g_Point *= 100;
         Slippage*=10;

        }
      ChartSetInteger(0,17,0,0);
      ChartSetInteger(0,0,1);
      string account_server=AccountInfoString(3);
      if(account_server=="")
        {
         account_server="default";
        }
      datapath=TerminalInfoString(3)+"\\history\\"
               +account_server+"\\"+Symbol()+"240"+".hst";
      ReadFileHst(datapath);
      //---
      return(INIT_SUCCEEDED);
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime previousBar;
   if(previousBar!=Time[0])
     {
      previousBar=Time[0];
      ChartRedraw();
     }
   else
     {
      return;
     }

   if(iVolume(Symbol(),PERIOD_H4,0)>iVolume(Symbol(),PERIOD_H4,1))
      return;
//**********************************

   if(!BytesToRead>0)
      return;

   int pos = -1 ;
   for(int i = 0 ; i < BytesToRead - 1 ; i++)
     {
      if(!(data[i][0]<Time[0]))
         break;
      pos = i + 1;
     }

//********************************
   HideTestIndicators(true);
   double wpr= iWPR(Symbol(),0,4,0);
   double ao = iAO(Symbol(),0,0);
   HideTestIndicators(false);

   double level=NormalizeDouble(data[pos][1],Digits);
   ObjectDelete("level");
   MakeLine(level);

   if(data[pos][1]>Open[0])
      Comment("BUY - ", data[pos][1]);
   if(data[pos][1]<Open[0])
      Comment("SELL - ", data[pos][1]);

   if(MarketInfo(Symbol(),MODE_SPREAD)>30)
      return;

   if(pos>0)
     {

      if(CheckMarketBuyOrders()<70 && CheckMarketSellOrders()<70)
        {
         if(data[pos][1]>Open[0])

            if(IsBuyPinbar())
               //if(ao<0)

              {
               double BuySL=NormalizeDouble(Ask - SL*g_Point,Digits);
               double BuyTP=NormalizeDouble(Ask + TP*g_Point,Digits);
               if(AccountFreeMarginCheck(Symbol(),OP_BUY,GetLots())>0)
                 {
                  ticket=OrderSend(Symbol(),OP_BUY,GetLots(),Ask,Slippage,BuySL,BuyTP,"",MagicID,0,clrGreen);
                  //MainOrders(0,Ask,BuyTP,BuySL);
                  CloseSell();
                 }
              }

         if(data[pos][1]<Open[0])

            if(IsSellPinbar())
               //if(ao>0)


              {
               double SellSL=NormalizeDouble(Bid + SL*g_Point,Digits);
               double SellTP=NormalizeDouble(Bid - TP*g_Point,Digits);
               if(AccountFreeMarginCheck(Symbol(),OP_SELL,GetLots())>0)
                 {
                  ticket=OrderSend(Symbol(),OP_SELL,GetLots(),Bid,Slippage,SellSL,SellTP,"",MagicID,0,clrGreen);
                  //MainOrders(1,Bid,SellTP,SellSL);
                  CloseBuy();

                 }
              }
        }

     }
   return;
  }
//+------------------------------------------------------------------+
void ReadFileHst(string FileName)
  {
   int       j=0;;
   string    strFileContents;
   int       Handle;
   int       LogFileSize;
   int       movehigh[1]= {0};
   uchar     buffer[];
   int       nNumberOfBytesToRead;
   int       read[1]= {0};
   int       i;
   double    mm;
//----- -----
   strFileContents="";
   Handle=CreateFileW(FileName,(int)0x80000000,3,0,3,0,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Handle==-1)
     {
      Comment("");
      return;
     }
   LogFileSize=GetFileSize(Handle,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(LogFileSize<=0)
     {
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((LogFileSize-148)/60==BytesToRead)
     {
      return;
     }
   SetFilePointer(Handle,148,movehigh,0);
   BytesToRead=(LogFileSize-148)/60;
   ArrayResize(data,BytesToRead,0);
   nNumberOfBytesToRead=60;
   ArrayResize(buffer,60,0);
   for(i=0; i<BytesToRead; i=i+1)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ReadFile(Handle,buffer,nNumberOfBytesToRead,read,NULL);
      if(read[0]==nNumberOfBytesToRead)
        {
         result=StringFormat("0x%02x%02x%02x%02x%02x%02x%02x%02x",buffer[7],buffer[6],buffer[5],buffer[4],buffer[3],buffer[2],buffer[1],buffer[0]);

         m_price.buffer[0] = buffer[32];
         m_price.buffer[1] = buffer[33];
         m_price.buffer[2] = buffer[34];
         m_price.buffer[3] = buffer[35];
         m_price.buffer[4] = buffer[36];
         m_price.buffer[5] = buffer[37];
         m_price.buffer[6] = buffer[38];
         m_price.buffer[7] = buffer[39];
         mm=m_price.close;
         data[j][0] = StringToDouble(result);
         data[j][1] = mm;
         j=j+1;
         strFileContents=TimeToString(StringToTime(result),3)+" "+DoubleToString(mm,8);
        }
      else
        {
         CloseHandle(Handle);
         return;
        }
     }
   CloseHandle(Handle);
   strFileContents=DoubleToString(data[j-1][0],3)+" "+DoubleToString(data[j-1][1],8)+" "+DoubleToString(data[j-2][1],3)+" "+DoubleToString(data[j-2][1],8);
   result=strFileContents;
  }
//ReadFileHst <<==--------   --------
int fnGetLotDigit()
  {
   double l_LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(l_LotStep == 1)
      return(0);
   if(l_LotStep == 0.1)
      return(1);
   if(l_LotStep == 0.01)
      return(2);
   if(l_LotStep == 0.001)
      return(3);
   if(l_LotStep == 0.0001)
      return(4);
   return(1);
  }
//+------------------------------------------------------------------+
int CheckBuyOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
            break;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckSellOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
            break;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalBuyOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalSellOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketSellOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=MagicID)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=MagicID)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MainOrders(int a_cmd_0,double price_24,double price_TP,double price_SL)
  {
   color color_8=Black;
   int bClosed;
   int nAttemptsLeft=Retries;
   int cmd=0;

   if(a_cmd_0 ==OP_BUY||a_cmd_0 ==OP_BUYSTOP)
      cmd=0;
   if(a_cmd_0 ==OP_SELL||a_cmd_0 ==OP_SELLSTOP)
      cmd=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(a_cmd_0==OP_BUYLIMIT || a_cmd_0==OP_BUY)
     {
      color_8=Blue;
     }
   else
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(a_cmd_0==OP_SELLLIMIT || a_cmd_0==OP_SELL)
        {
         color_8=Red;
        }
     }

   double lots_32=NormalizeDouble(LOTS,fnGetLotDigit());

   if(lots_32==0.0)
      return(false);

   double gd_532 = MarketInfo(Symbol(), MODE_MAXLOT);
   double gd_540 = MarketInfo(Symbol(), MODE_MINLOT);

   if(lots_32 > gd_532)
      lots_32 = gd_532;
   if(lots_32 < gd_540)
      lots_32 = gd_540;

   bClosed=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while((bClosed==false) && (nAttemptsLeft>=0))
     {
      nAttemptsLeft--;
      RefreshRates();

      if(!ecnBroker)
         bClosed=OrderSend(Symbol(),a_cmd_0,lots_32,price_24,Slippage,price_SL,price_TP,Ordercomment,MagicID,0,color_8);
      else
         bClosed=OrderSend(Symbol(),a_cmd_0,lots_32,price_24,Slippage,0,0,Ordercomment,MagicID,0,color_8);

      if(bClosed<=0)
        {
         int nErrResult=GetLastError();

         if(a_cmd_0==0)
           {
            Print("FX EA Open New Buy FAILED : Error "+IntegerToString(nErrResult)+" ["+ErrorDescription(nErrResult)+".]");
            Print(IntegerToString(a_cmd_0)+" "+DoubleToString(lots_32,2)+" "+DoubleToString(price_24,Digits));
           }
         else
           {
            if(a_cmd_0==1)
              {
               Print("FX EA Open New Sell FAILED : Error "+IntegerToString(nErrResult)+" ["+ErrorDescription(nErrResult)+".]");
               Print(IntegerToString(a_cmd_0)+" "+DoubleToString(lots_32,2)+" "+DoubleToString(price_24,Digits));
              }
           }

         if(nErrResult == ERR_TRADE_CONTEXT_BUSY ||
            nErrResult == ERR_NO_CONNECTION)
           {
            Sleep(50);
            continue;
           }
        }

      ticket=bClosed;

      bClosed=true;

     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
  {
   bool clo;
   while(CheckMarketBuyOrders()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicID)
               if(OrderType()==OP_BUY)
                  clo=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,clrAqua);

        }
     }

  }
//+------------------------------------------------------------------+
void CloseSell()
  {
   bool clo;
   while(CheckMarketSellOrders()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicID)
               if(OrderType()==OP_SELL)
                  clo=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,clrAqua);

        }
     }
  }
//+------------------------------------------------------------------+
double GetLots()
  {
   double lot;
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(risk!=0)
     {
      lot=NormalizeDouble(AccountBalance()*risk/100/10000,2);
      if(lot<minlot)
         lot=minlot;
      if(lot>maxlot)
         lot=maxlot;
     }
   else
      lot=LOTS;
   return(lot);
  }
//+------------------------------------------------------------------+
int signal(int mode)
  {
   int res=0;

   double var1 = 0;
   double var2 = 0;
   double var3 = 0;
   double var4 = 0;
   double var5 = 0;
   double var6 = 0;


   if(Close[2]>Open[2] && Close[1]>Open[1] && Low[2]<Low[1])
     {
      if(mode==2)
        {
         var5 = Low[2];
         var6 = Low[1];
         if(Open[0]<var6 -(var5-var6))
           {
            var1=High[0];
           }
         if(Open[2]<Open[1])
           {
            var5 = Open[2];
            var6 = Open[1];
           }
         else
           {
            var5 = 0.0;
            var6 = 0.0;
           }
         if(Open[0]<var6 -(var5-var6))
           {
            var3=High[0];
           }
        }
      else
        {
         if(mode==0)
           {
            if(Open[2]<Open[1])
              {
               var5 = Open[2];
               var6 = Open[1];
              }
            else
              {
               var5 = 0.0;
               var6 = 0.0;
              }
           }
         else
           {
            var5 = Low[2];
            var6 = Low[1];
           }
         if(Open[0]<var6 -(var5-var6))
           {
            var3=High[0];
           }
        }
     }
   if(Open[2]>Close[2] && Open[1]>Close[1] && High[2]>High[1])
     {
      if(mode==2)
        {
         var5 = High[2];
         var6 = High[1];
         if(Open[0]>var6 -(var5-var6))
           {
            var2=Low[0];
           }
         if(Open[2]>Open[1])
           {
            var5 = Open[2];
            var6 = Open[1];
           }
         else
           {
            var5 = 0.0;
            var6 = 0.0;
           }
         if(Open[0]>var6 -(var5-var6))
           {
            var4=Low[0];
           }
        }
      else
        {
         if(mode==0)
           {
            if(Open[2]>Open[1])
              {
               var5 = Open[2];
               var6 = Open[1];
              }
            else
              {
               var5 = 0.0;
               var6 = 0.0;
              }
           }
         else
           {
            var5 = High[2];
            var6 = High[1];
           }
         if(Open[0]>var6 -(var5-var6))
           {
            var4=Low[0];
           }
        }
     }
   if((var1>0.0 || var3>0.0))
     {
      res=+1;
     }
   else
     {
      if((var2>0.0 || var4>0.0))
        {
         res=-1;
        }
     }

   return res;

  }
//+------------------------------------------------------------------+
string CandleStick_Analyzer()
  {
   RefreshRates();
   string CandleStick, Comment1="",Comment2="",Comment3="",Comment4="",Comment5="",Comment6="",Comment7="",Comment8="",Comment9="";

   if(BullishEngulfingExists())
      Comment1 =" Bullish Engulfing ";
   if(BullishHaramiExists())
      Comment2 =" Bullish Harami ";
   if(LongUpCandleExists())
      Comment3 =" Bullish LongUp ";
   if(DojiAtBottomExists())
      Comment4 =" MorningStar Doji ";

   if(DojiAtTopExists())
      Comment5 =" EveningStar Doji ";
   if(BearishHaramiExists())
      Comment6 =" Bearish Harami ";
   if(BearishEngulfingExists())
      Comment7 =" Bearish Engulfing ";
   if(LongDownCandleExists())
      Comment8 =" Bearish LongDown ";

   /*if(SpinningTopExists())
      Comment9 =" Spinning Top ";*/

   CandleStick =Comment1+Comment2+Comment3+Comment4+Comment5+Comment6+Comment7+Comment8+Comment9;
   return (CandleStick);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishEngulfingExists()
  {
   if(Open[1] <= Close[2] && Close[1] >= Open[2] && Open[2] -  Close[2] >= 10*Point && Close[1] - Open[1] >= 10*Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishHaramiExists()
  {
   if(Close[2] < Open[2] && Open[1] < Close[1] && Open[2] - Close[2] > iATR(NULL, 0, 14, 2) && Open[2] - Close[2] > 4*(Close[1] - Open[1]))
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtBottomExists()
  {
   if(Open[3] - Close[3] >= 8*Point && MathAbs(Close[2] - Open[2]) <= 1*Point && Close[1] - Open[1] >= 8*Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtTopExists()
  {
   if(Close[3] - Open[3] >= 8*Point && MathAbs(Close[2] - Open[2]) <= 1*Point && Open[1] - Close[1] >= 8*Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishHaramiExists()
  {
   if(Close[2] > Close[1] && Open[2] < Open[1] && Close[2] > Open[2] && Open[1] > Close[1] && Close[2] -  Open[2] > iATR(NULL, 0, 14, 2) && Close[2] -  Open[2] > 4*(Open[1] -  Close[1]))
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongUpCandleExists()
  {
   if(Open[2] < Close[2] && High[2] - Low[2] >= 40*Point && High[2] - Low[2] > 2.5*iATR(NULL, 0, 14, 2) && Close[1] < Open[1] && Open[1] -  Close[1] > 10*Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongDownCandleExists()
  {
   if(Open[1] > Close[1] && High[1] -Low[1] >= 40*Point && High[1] - Low[1] > 2.5*iATR(NULL, 0, 14, 1))
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfingExists()
  {
   if(Open[1] >= Close[2] && Close[1] <= Open[2] && Open[2] -Close[2] >= 10*Point && Close[1]- Open[1] >= 10*Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*bool SpinningTopExists()
  {
   HideTestIndicators(true);
   if(High[1] - Low[1] > 1.5*iATR(NULL, 0, 14, 1))
      Print("ST Condition 1 Met");
   if(MathAbs(Open[1] - Close[1])*5 < High[1] - Low[1])
      Print("ST Condition 2 Met");
   if(High[1] - Low[1] > 1.5*iATR(NULL, 0, 14, 1) && (High[1] - Low[1] > 30*Point) && MathAbs(Open[1] - Close[1])*5 < High[1]- Low[1])
      return (true);
   HideTestIndicators(false);
   return (false);
  }*/
//+------------------------------------------------------------------+
void MakeLine(double price)
  {
   string name="level";

   if(price>iOpen(Symbol(),PERIOD_M1,0))
      Comment("BUY = "+DoubleToStr(price,Digits));
   if(price<iOpen(Symbol(),PERIOD_M1,0))
      Comment("SELL= "+DoubleToStr(price,Digits));

   if(ObjectFind(name)!=-1)
     {
      ObjectMove(name,0,iTime(Symbol(),PERIOD_M1,0),price);
      return;
     }
   ObjectCreate(name,OBJ_HLINE,0,0,price);
   ObjectSet(name,OBJPROP_COLOR,clrAqua);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_WIDTH,2);
   ObjectSet(name,OBJPROP_BACK,TRUE);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| User function IsPinbar                                           |
//+------------------------------------------------------------------+
bool IsBuyPinbar()
  {
//start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actHigherPart,actHigherPart1;
   actOp=Open[1];
   actCl=Close[1];
   actHi=High[0];
   actLo=Low[1];
   preOp=Open[2];
   preCl=Close[2];
   preHi=High[2];
   preLo=Low[2];
//SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actHigherPart=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
   actHigherPart1=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
//end of declaratins
//start function body
   double dayRange=AveRange4();
   if((actCl>actHigherPart1&&actOp>actHigherPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
//(actHi<(preHi-preRange*0.3))&& //High of PB is NOT higher than 1/2 of previous Bar
      (actLo+actRange*0.25<preLo)) //Nose of the PB is at least 1/3 lower than previous bar
     {

      if(Low[ArrayMinimum(Low,3,3)]>Low[1])
         return (true);
     }
   return(false);

  }//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSellPinbar()
  {
//start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actLowerPart, actLowerPart1;
   actOp=Open[1];
   actCl=Close[1];
   actHi=High[1];
   actLo=Low[1];
   preOp=Open[2];
   preCl=Close[2];
   preHi=High[2];
   preLo=Low[2];
//SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actLowerPart=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
   actLowerPart1=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
//end of declaratins

//start function body

   double dayRange=AveRange4();
   if((actCl<actLowerPart1&&actOp<actLowerPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
//(actLo>(preLo+preRange/3.0))&& //Low of PB is NOT lower than 1/2 of previous Bar
      (actHi-actRange*0.25>preHi)) //Nose of the PB is at least 1/3 lower than previous bar

     {
      if(High[ArrayMaximum(High,3,3)]<High[1])
         return (true);
     }
   return false;
  }//------------END FUNCTION-------------
//+------------------------------------------------------------------+
//| User function AveRange4                                          |
//+------------------------------------------------------------------+
double AveRange4()
  {
   double sum=0;
   double rangeSerie[4];

   int i=0;
   int ind=1;
   int startYear=1995;


   while(i<4)
     {
      //datetime pok=Time[pos+ind];
      if(TimeDayOfWeek(Time[ind])!=0)
        {
         sum+=High[ind]-Low[ind];//make summation
         i++;
        }
      ind++;
      //i++;
     } 
//Comment(sum/4.0);
   return (sum/4.0);//make average, don't count min and max, this is why I divide by 4 and not by 6


  }//------------END FUNCTION-------------




//+------------------------------------------------------------------+
