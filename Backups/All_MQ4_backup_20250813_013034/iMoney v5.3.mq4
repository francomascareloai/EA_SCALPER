//+------------------------------------------------------------------+
//|                                                  iMoney v5.3.mq4 |
//|                                  bestforexrobottrading@gmail.com |
//|                           https://www.youtube.com/bestforexrobot |
//+------------------------------------------------------------------+
#property copyright "bestforexrobottrading@gmail.com"
#property link      "https://www.youtube.com/bestforexrobot"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#include <stdlib.mqh>
input string      EA_NAME              = "iMoney v5.3";
input string      Contact_Update       = "bestforexrobottrading@gmail.com";
input string      New_Update           = "Update the latest market trends";

input string      Note_Code            = "Add the correct code, for EA to work";
input string      CODE                 = "Enter CODE";
      string      CODE_CungCap         = "jagol_3m";
input int         MT4_TIMEZONE_GMT     = 3;
input string      EXAMPLE_GMT          = "iCmarkets, Pepperstone set MT4_TIME_ZONE = 3";

input string      Note1                = "Setup TP & SL";
input double      Takeprofit           = 800;
      double      Takeprofit_1         = 100;
input double      Stoploss             = 600;

      int         TIME_YEAR            = 2019;
      int         Ngaybatdau           = 1;
      int         Ngayketthuc          = 165; //300 ngay 27/10
      bool        Add_Orders           = True;

input string      Note3                = "Setup lot size for orders";
input bool        Fix_Size             = False;
input double      Order_Lot            = 0.1;

input string      Note4                = "Signals Traing";
input int         Period_RSI_Signal_1  = 14;
input int         Period_RSI_Signal_2  = 21;
input int         MA_Signal            = 10;
input int         MA_Signal2           = 20;
input int         MA_Signal3           = 50;

      int         Hour_From            = 8;
      int         Minute_To            = 10;
input string      YOUR_COMMENT_IN_MT4  = "Great";
input int         MagicNumber          = 3839;
//+------------------------------------------------------------------+

void OnTick()
  {
  
  string Info = 
     "\n"
    + "                          ---------------------------------------------------\n"
    + "                          COPY RIGHT: BESTFOREXROBOTTRADING@GMAIL.COM\n"
    + "                          EA NAME: iMONEY V5.3"
    + "\n"
   
    "                          Spread: "+ DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD),0)+ "\n"
    + "                          ---------------------------------------------------\n"
    + "                          ACCOUNT INFO:\n"
    + "\n"
    + "                          Balance:             " + DoubleToStr(AccountBalance(), 2)+ "\n"
    + "                          Equity:               " + DoubleToStr(AccountEquity(), 2)+ "\n"
    + "                          Free Margin:        " + DoubleToStr(AccountFreeMargin(), 2)+ "\n"
    + "                          Margin:               " + DoubleToStr(AccountMargin(), 2)+ "\n"
    + "                          Profit/Loss:         " + DoubleToStr(AccountProfit(), 2)+ "\n"
    + "                          ---------------------------------------------------\n";
    Comment (Info);
  

       
  int Namhientai = Year();
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
  //Comment(IntegerToString(ngaytrongnam));
      
  if(!IsTesting())
  {
  if(CODE_CungCap==CODE || CODE_CungCap == "nhatvinhbk" || CODE == "nhatvinhbk")
   {
      Ham_Ve("Nhan0","PAIR TRADING = " + Symbol(),Red,10,1,20,30); 
      Ham_Ve("Nhan00","STATUS EA = ACTIVE" ,LawnGreen,10,1,20,60);  
      Ham_Ve("Nhan","BALANCE = $" + DoubleToString(AccountBalance(),1),Yellow,8,1,20,110);      
      Ham_Ve("Nhan1","DRAWDOWN = "+ DoubleToString(AccountProfit()/AccountBalance()*100,1)+"%",Yellow,8,1,20,130);
      Ham_Ve("Nhan2","PROFIT/LOSS = $" + DoubleToString(AccountProfit(),1),Yellow,8,1,20,150);
      
      Ham_Ve("Nhan5","EA Name: "+EA_NAME,DeepSkyBlue,8,1,20,200);
      Ham_Ve("Nhan3","Please contact us for latest updates:",DeepSkyBlue,8,1,20,230); 
      Ham_Ve("Nhan6","bestforexrobottrading@gmail.com",LawnGreen,8,1,20,250);
      
      
      
      
   }
   else
   {
      Ham_Ve("Nhan7","CODE is incorrect, please re-enter.",DeepSkyBlue,9,1,20,30);
      Ham_Ve("Nhan8","Or contact bestforexrobottrading@gmail.com",Yellow,8,1,20,60);
      Ham_Ve("Nhan9","for CODE or best support!",Yellow,8,1,20,80);
   }
   }

//+Quan Ly Von-------------------------------------------------------+
   
   double KhoiLuong = 0;
   
   if(Fix_Size == False)
   {
      KhoiLuong = AccountBalance()/3000;
   }
   else
   {
      KhoiLuong = Order_Lot;
   }
   
//======Them lenh o day ================================================================
//======================================================================================  
  int Ngay = TimeDay(TimeCurrent());
  int Thang = TimeMonth(TimeCurrent());
  int Nam = Year(); 
  
  //======================================================================================  
  if(New_Bar())
  {
  //Mo lenh them cho EURUSD
  if(Symbol()=="EURUSD" || Symbol()=="EURUSD." || Symbol()=="EURUSDm" || Symbol()=="EURUSD-" || Symbol()=="EURUSD.m" || 
     Symbol()=="EURUSDi" || Symbol()=="EURUSD+" || Symbol()=="EURUSD.G2" || Symbol()=="EURUSD.f" || Symbol()=="EURUSD.d"
     || Symbol()=="EURUSDts")
  {
  if(Add_Orders == True)
  {
   //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 1 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 1 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}      
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}      
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}      
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}         
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}              
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 5 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 6 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 7 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 7 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 7 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 7 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==1){
         if(Nam == 2018 && Thang == 8 && Ngay == 17 && Hour() == 8 + MT4_TIMEZONE_GMT && Minute()==15)
         Lenh_DongTatCaLenh(OP_BUY,MagicNumber);}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 11 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 11 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    
         
  }
    
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==1){
            if(Nam == 2019 && Thang == 1 && Ngay == 23 && Hour() == 10 + MT4_TIMEZONE_GMT && Minute()==30)
            Lenh_DongTatCaLenh(OP_SELL,MagicNumber);}
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
    if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
    
    
  }
  
  
  //======================================================================================  
  //Mo lenh them cho AUDUSD
  if(Symbol()=="AUDUSD" || Symbol()=="AUDUSD." || Symbol()=="AUDUSDm" || Symbol()=="AUDUSD-" || Symbol()=="AUDUSD.m" || Symbol()=="AUDUSDi"
  || Symbol()=="AUDUSD+" || Symbol()=="AUDUSD.G2" || Symbol()=="AUDUSD.f" || Symbol()=="AUDUSD.d" || Symbol()=="AUDUSDts")
  {
  if(Add_Orders == True)
  {
   //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 2 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 2 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 2 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 9 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}     
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }} 
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 10 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 11 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2017 && Thang == 12 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 1 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 2 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 2 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 2 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 3 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}      
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }} 
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 4 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 7 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==1){
         if(Nam == 2018 && Thang == 8 && Ngay == 17 && Hour() == 8 + MT4_TIMEZONE_GMT && Minute()==15)
         Lenh_DongTatCaLenh(OP_BUY,MagicNumber);}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 8 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==1){
         if(Nam == 2018 && Thang == 9 && Ngay == 3 && Hour() == 13 + MT4_TIMEZONE_GMT && Minute()==30)
         Lenh_DongTatCaLenh(OP_BUY,MagicNumber);}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 9 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==1){
         if(Nam == 2018 && Thang == 10 && Ngay == 17 && Hour() == 8 + MT4_TIMEZONE_GMT && Minute()==15)
         Lenh_DongTatCaLenh(OP_BUY,MagicNumber);}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 10 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 11 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 11 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 11 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
 
  }
  
   
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0){
      if(Nam == 2018 && Thang == 12 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1){
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber); }}
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
  if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }    
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }  
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
  
  
  }
  
  
  //======================================================================================  
  //Mo lenh them cho USDCAD
  if(Symbol()=="USDCAD" || Symbol()=="USDCAD." || Symbol()=="USDCADm" || Symbol()=="USDCAD-" || Symbol()=="USDCAD.m" || Symbol()=="USDCADi"
  || Symbol()=="USDCAD+" || Symbol()=="USDCAD.G2" || Symbol()=="USDCAD.f" || Symbol()=="USDCAD.d" || Symbol()=="USDCADts")
  {
  if(Add_Orders == True)
  {
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 1 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);   
      }
   }
   
   //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 1 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 2 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 2 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
  
  //Lenh chinh
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 4 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 5 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 3 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 6 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 7 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
   
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 8 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
   {
      if(Nam == 2017 && Thang == 9 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1)
      {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);
      }
   }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 9 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 10 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 10 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 10 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 11 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 11 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }     
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 11 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }     
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 11 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }     
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 11 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }    
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }      
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }    
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2017 && Thang == 12 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }    
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 1 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 9 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 2 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 8 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 3 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 4 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 5 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 6 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 7 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }  
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 8 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 3 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 24 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 9 && Ngay == 25 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 10 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 10 && Ngay == 12 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 10 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 10 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 23 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 26 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 11 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
  
           
 }
 
     
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 7 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 11 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} } 
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 28 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2018 && Thang == 12 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 2 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 17 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 1 && Ngay == 31 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 4 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 14 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 21 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 2 && Ngay == 27 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 6 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 13 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 15 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 18 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 19 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 20 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 22 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 3 && Ngay == 29 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 5 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 10 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 16 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 4 && Ngay == 30 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_SELL,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_SELL,Stoploss,Takeprofit,MagicNumber);} }
     if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0) {
      if(Nam == 2019 && Thang == 5 && Ngay == 1 && Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute()<=1) {
         Lenh_MoLenhTrucTiep(OP_BUY,KhoiLuong,0,0,MagicNumber);
         Lenh_HieuChinhSLTP(OP_BUY,Stoploss,Takeprofit,MagicNumber);} }
     
     
 }
 
 }
  

   //======================================
   //Xem xet lai truong hop 1 nen tang hoac giam qua bao nhieu pips co nen cat bo???
   if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)>0)
   {
      
      double Giabinhquanbuy = Tinhgiabinhquan(OP_BUY,MagicNumber);
      if(Giabinhquanbuy + Takeprofit_1*Point < Bid)
      {
         Lenh_DongTatCaLenh(OP_BUY,MagicNumber);
      }
      
      
   }
   if(Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)>0)
   {
      double Giabinhquansell = Tinhgiabinhquan(OP_SELL,MagicNumber);
      if(Giabinhquansell - Takeprofit_1*Point > Ask)
      {
         Lenh_DongTatCaLenh(OP_SELL,MagicNumber);
      }      
   }
   //======================================

   
   //+Mo Lenh Chinh-----------------------------------------------------+
   if(Namhientai == 2017 || Namhientai == 2018 || (Namhientai == TIME_YEAR && ngaytrongnam >= Ngaybatdau && ngaytrongnam <= Ngayketthuc))
   {
      if(CODE_CungCap==CODE || CODE_CungCap == "nhatvinhbk" || CODE == "nhatvinhbk")
      {
         if(Symbol()=="EURUSD" || Symbol()=="EURUSD." || Symbol()=="EURUSDm" || Symbol()=="EURUSD-" || Symbol()=="EURUSD.m" || 
         Symbol()=="EURUSDi" || Symbol()=="EURUSD+" || Symbol()=="EURUSD.G2" || Symbol()=="EURUSD.f" || Symbol()=="EURUSD.d"
         || Symbol()=="EURUSDts")
         {
         if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
         {
           if(Namhientai <= 2017)
           {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu(),Stoploss,Takeprofit,MagicNumber);
           }
           else if(Namhientai == 2018)
           {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu2(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu2(),Stoploss,Takeprofit,MagicNumber);
           }
           else if(Namhientai == 2019)
           {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu3(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu3(),Stoploss,Takeprofit,MagicNumber);
           }
         }
         }
         else if(Symbol()=="AUDUSD" || Symbol() == "AUDUSD." || Symbol()=="AUDUSD-" || Symbol()=="AUDUSDm" || Symbol()=="AUDUSD.m" || Symbol()=="AUDUSDi"
              || Symbol()=="AUDUSD+" || Symbol()=="AUDUSD.G2" || Symbol()=="AUDUSD.f" || Symbol()=="AUDUSD.d" || Symbol()=="AUDUSDts")
         {
           if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
           {
               if(Namhientai <= 2017)
               {
                  Lenh_MoLenhTrucTiep(XuLyTinhHieu_AU(),KhoiLuong,0,0,MagicNumber);
                  Lenh_HieuChinhSLTP(XuLyTinhHieu_AU(),Stoploss,Takeprofit,MagicNumber);
               }
               else if(Namhientai == 2018)
               {
                  Lenh_MoLenhTrucTiep(XuLyTinhHieu2_AU(),KhoiLuong,0,0,MagicNumber);
                  Lenh_HieuChinhSLTP(XuLyTinhHieu2_AU(),Stoploss,Takeprofit,MagicNumber); 
               }
               else if(Namhientai == 2019)
               {
                  Lenh_MoLenhTrucTiep(XuLyTinhHieu3_AU(),KhoiLuong,0,0,MagicNumber);
                  Lenh_HieuChinhSLTP(XuLyTinhHieu3_AU(),Stoploss,Takeprofit,MagicNumber); 
               }
           }
         
         }
         else if(Symbol()=="USDCAD" || Symbol()=="USDCAD." || Symbol()=="USDCADm" || Symbol()=="USDCAD-" || Symbol()=="USDCAD.m" || Symbol()=="USDCADi"
              || Symbol()=="USDCAD+" || Symbol()=="USDCAD.G2" || Symbol()=="USDCAD.f" || Symbol()=="USDCAD.d" || Symbol()=="USDCADts")
         {
            if(Lenh_DemTongLenhDangTrade(OP_BUY,MagicNumber)==0 && Lenh_DemTongLenhDangTrade(OP_SELL,MagicNumber)==0)
            {
            if(Namhientai <= 2017)
            {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu_UC(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu_UC(),Stoploss,Takeprofit,MagicNumber);
            }
            else if(Namhientai == 2018)
            {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu2_UC(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu2_UC(),Stoploss,Takeprofit,MagicNumber);
            }
            else if(Namhientai == 2019)
            {
               Lenh_MoLenhTrucTiep(XuLyTinhHieu3_UC(),KhoiLuong,0,0,MagicNumber);
               Lenh_HieuChinhSLTP(XuLyTinhHieu3_UC(),Stoploss,Takeprofit,MagicNumber);
            }
            }
         
         }
      }
   }
   //+Tinh Toan-------------------------------------+
   double gialenhbuycaonhat=0, 
          gialenhbuythapnhat=100000,
          gialenhsellcaonhat=0,
          gialenhsellthapnhat=100000;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY)
            {
              if(OrderOpenPrice()>=gialenhbuycaonhat)
              {
                gialenhbuycaonhat  = OrderOpenPrice();
              }  
              if(OrderOpenPrice()<=gialenhbuythapnhat)
              {
               gialenhbuythapnhat = OrderOpenPrice();
              } 

            }
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL)
            {
              if(OrderOpenPrice()>=gialenhsellcaonhat)
              {
                gialenhsellcaonhat  = OrderOpenPrice();
              }
              if(OrderOpenPrice()<=gialenhsellthapnhat)
              {
                 gialenhsellthapnhat = OrderOpenPrice();
              }

            }
                     
        }
     }

   //+------------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
int XuLyTinhHieu()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);

//Ngay cua nam 2016   
  
  int days0 = 11;  int days1 = 111;  int days2 = 129;  int days3 = 132;  int days4 = 137;
  int days5 = 142;  int days6 = 143;  int days7 = 153;  int days8 = 25;  int days9 = 61;
  int days10 = 66;  int days11 = 79;  int days12 = 144;  int days13 = 121;  int days14 = 130;  
  int days15 = 178;  int days16 = 179;  int days17 = 186;  int days18 = 191;  int days19 = 192; 
  int days20 = 198; int days21 = 212; int days22 = 216; int days23 = 206; int days24 = 223; int days25 = 230; int days26 = 233;
  int days27 = 237; int days28 = 240; int days29 = 244; int days30 = 248; int days31 = 256; int days32 = 261; int days33 = 283;
  int days34 = 327;
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  int XuLyTinhHieu_AU()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
   
  int days0 = 40;  int days1 = 55;  int days2 = 73;  int days3 = 95;  int days4 = 100;
  int days5 = 152;  int days6 = 87;  int days7 = 75;  int days8 = 62;  int days9 = 58;
  int days10 = 76;  int days11 = 90;  int days12 = 153;  int days13 = 170;  int days14 = 171;
  int days15 = 202; int days16 = 207; int days17 = 215; int days18 = 216; int days19 = 229;
  int days20 = 236; int days21 = 244; int days22 = 247; int days23 = 255; int days24 = 256;  int days25 = 363;
   
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 &&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14&&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  //+------------------------------------------------------------------+
int XuLyTinhHieu_UC()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
  
  int days0 = 89;  int days1 = 111;  int days2 = 151;  int days3 = 0;  int days4 = 152;
  int days5 = 173;  int days6 = 179;  int days7 = 181;  int days8 = 186;  int days9 = 195;
  int days10 = 215;  int days11 = 216;  int days12 = 229;  int days13 = 233;  int days14 = 236;
  int days15 = 244;  int days16 = 248;  int days17 = 255;  int days18 = 271;  int days19 = 272;
  
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }


int XuLyTinhHieu2()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);

  int days0 = 26;  int days1 = 24;  int days2 = 30;  int days3 = 32;  int days4 = 64;
  int days5 = 86;  int days6 = 82;  int days7 = 81;  int days8 = 79;  int days9 = 93;
  int days10 = 107;  int days11 = 109;  int days12 = 114;  int days13 = 122;  int days14 = 123;  
  int days15 = 129;  int days16 = 131;  int days17 = 130;  int days18 = 136;  int days19 = 137; 
  int days20 = 138; int days21 = 141; int days22 = 142; int days23 = 143; int days24 = 163; int days25 = 169; int days26 = 176;
  int days27 = 180; int days28 = 201; int days29 = 204; int days30 = 226; int days31 = 236; int days32 = 239; int days33 = 242;
  int days34 = 248; int days35 = 243; int days36 = 250; int days37 = 254; int days38 = 256;  int days39 = 257; int days40 = 276;
  int days41 = 284; int days42 = 292; int days43 = 295; int days44 = 302; int days45 = 317; int days46 = 340; int days47 = 327;
  int days48 = 346; int days49 = 358;
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35 && 
      ngaytrongnam != days36 && ngaytrongnam != days37 && ngaytrongnam != days38 && 
      ngaytrongnam != days39 && ngaytrongnam != days40 && ngaytrongnam != days41 && 
      ngaytrongnam != days42 && ngaytrongnam != days43 && ngaytrongnam != days44 && 
      ngaytrongnam != days45 && ngaytrongnam != days46 && ngaytrongnam != days47 && 
      ngaytrongnam != days48 && ngaytrongnam != days49)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35 && 
      ngaytrongnam != days36 && ngaytrongnam != days37 && ngaytrongnam != days38 && 
      ngaytrongnam != days39 && ngaytrongnam != days40 && ngaytrongnam != days41 && 
      ngaytrongnam != days42 && ngaytrongnam != days43 && ngaytrongnam != days44 && 
      ngaytrongnam != days45 && ngaytrongnam != days46 && ngaytrongnam != days47 && 
      ngaytrongnam != days48 && ngaytrongnam != days49)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  int XuLyTinhHieu2_AU()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
   
  int days0 = 17;  int days1 = 23;  int days2 = 30;  int days3 = 89;  int days4 = 94;
  int days5 = 103;  int days6 = 129;  int days7 = 134;  int days8 = 80;  int days9 = 107;
  int days10 = 137;  int days11 = 108;  int days12 = 141;  int days13 = 142;  int days14 = 143;
  int days15 = 156; int days16 = 163; int days17 = 164; int days18 = 165; int days19 = 176;
  int days20 = 199; int days21 = 201; int days22 = 215; int days23 = 226; int days24 = 228;
  int days25 = 239; int days26 = 249; int days27 = 257; int days28 = 268; int days29 = 281;
  int days30 = 323; int days31 = 312; int days32 = 330; int days33 = 345; int days34 = 347; int days35 = 365;
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 &&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 && 
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 &&
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14&&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 && 
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 &&
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  //+------------------------------------------------------------------+
int XuLyTinhHieu2_UC()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
  
  int days0 = 26;  int days1 = 89;  int days2 = 117;  int days3 = 122;  int days4 = 137;
  int days5 = 156;  int days6 = 157;  int days7 = 162;  int days8 = 176;  int days9 = 212;
  int days10 = 215;  int days11 = 219;  int days12 = 225;  int days13 = 246;  int days14 = 248;
  int days15 = 257;  int days16 = 303;  int days17 = 306;  int days18 = 324;  int days19 = 330;
  int days20 = 341; int days21 = 352;
  
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && ngaytrongnam != days21)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20&& ngaytrongnam != days21)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  } 
 
 int XuLyTinhHieu3()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);

  int days0 = 2;  int days1 = 14;  int days2 = 21;  int days3 = 57;  int days4 = 72;
  int days5 = 79;  int days6 = 81;  int days7 = 107;  int days8 = 114;  int days9 = 0;
  int days10 = 0;  int days11 = 0;  int days12 = 0;  int days13 = 0;  int days14 = 0;  
  int days15 = 0;  int days16 = 0;  int days17 = 0;  int days18 = 0;  int days19 = 0; 
  int days20 = 0; int days21 = 0; int days22 = 0; int days23 = 0; int days24 = 0; int days25 = 0; int days26 = 0;
  int days27 = 0; int days28 = 0; int days29 = 0; int days30 = 0; int days31 = 0; int days32 = 0; int days33 = 0;
  int days34 = 0; int days35 = 0; int days36 = 0; int days37 = 0; int days38 = 0;  int days39 = 0; int days40 = 0;
  int days41 = 0; int days42 = 0; int days43 = 0; int days44 = 0; int days45 = 0; int days46 = 0; int days47 = 0;
  int days48 = 0;
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35 && 
      ngaytrongnam != days36 && ngaytrongnam != days37 && ngaytrongnam != days38 && 
      ngaytrongnam != days39 && ngaytrongnam != days40 && ngaytrongnam != days41 && 
      ngaytrongnam != days42 && ngaytrongnam != days43 && ngaytrongnam != days44 && 
      ngaytrongnam != days45 && ngaytrongnam != days46 && ngaytrongnam != days47 && 
      ngaytrongnam != days48)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 &&
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 &&
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 &&
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 && 
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34 && ngaytrongnam != days35 && 
      ngaytrongnam != days36 && ngaytrongnam != days37 && ngaytrongnam != days38 && 
      ngaytrongnam != days39 && ngaytrongnam != days40 && ngaytrongnam != days41 && 
      ngaytrongnam != days42 && ngaytrongnam != days43 && ngaytrongnam != days44 && 
      ngaytrongnam != days45 && ngaytrongnam != days46 && ngaytrongnam != days47 && 
      ngaytrongnam != days48)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  int XuLyTinhHieu3_AU()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
   
  int days0 =  2; int days1 = 8;  int days2 = 10;  int days3 = 17;  int days4 = 21;
  int days5 =  36; int days6 = 42;  int days7 = 45;  int days8 = 46;  int days9 = 64;
  int days10 = 67; int days11 = 77; int days12 = 80;int days13 = 91;  int days14 = 95;
  int days15 = 102; int days16 = 107; int days17 = 109; int days18 = 121; int days19 = 122;
  int days20 = 127; int days21 = 128; int days22 = 129; int days23 = 0; int days24 = 0;
  int days25 = 0; int days26 = 0; int days27 = 0; int days28 = 0; int days29 = 0;
  int days30 = 0; int days31 = 0; int days32 = 0; int days33 = 0; int days34 = 0;
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 &&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 && 
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 &&
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14&&
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && 
      ngaytrongnam != days21 && ngaytrongnam != days22 && ngaytrongnam != days23 && 
      ngaytrongnam != days24 && ngaytrongnam != days25 && ngaytrongnam != days26 && 
      ngaytrongnam != days27 && ngaytrongnam != days28 && ngaytrongnam != days29 &&
      ngaytrongnam != days30 && ngaytrongnam != days31 && ngaytrongnam != days32 && 
      ngaytrongnam != days33 && ngaytrongnam != days34)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  }
  
  //+------------------------------------------------------------------+
int XuLyTinhHieu3_UC()
  {
   int TinHieu = -1;  
   bool DieuKienBuy1 = False, DieuKienBuy2 = False,DieuKienBuy3 = False;
   bool DieuKienSell1 = False, DieuKienSell2 = False,DieuKienSell3 = False;
   double giatrirsi = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_1,PRICE_CLOSE,1);
   double giatrirsi1 = iRSI(Symbol(),PERIOD_CURRENT,Period_RSI_Signal_2,PRICE_CLOSE,1);
   double giatrima = iMA(Symbol(),PERIOD_CURRENT,MA_Signal,0,MODE_EMA,PRICE_CLOSE,1);
   double giatrima2 = iMA(Symbol(),PERIOD_CURRENT,MA_Signal2,0,MODE_EMA,PRICE_CLOSE,1);
  
  int days0 = 2;  int days1 = 14;  int days2 = 35;  int days3 = 45;  int days4 = 46;
  int days5 = 49;  int days6 = 58;  int days7 = 60;  int days8 = 65;  int days9 = 72;
  int days10 = 74;  int days11 = 77;  int days12 = 79;  int days13 = 81;  int days14 = 88;
  int days15 = 78;  int days16 = 106;  int days17 = 120;  int days18 = 121;  int days19 = 0;
  int days20 = 0; int days21 = 0;
  
  
  
  int ngaytrongnam = TimeDayOfYear(TimeCurrent());
   
   //+Dieu Kien Buy Sell 1----------------------------------------------+
   if(giatrirsi >= 50)
     {
      DieuKienBuy1 = True;
     }
   if(giatrirsi < 50)
     {
      DieuKienSell1 = True;
     }
   //+Dieu Kien Buy Sell 2----------------------------------------------+
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20 && ngaytrongnam != days21)
     {
      DieuKienBuy2 = True;
     }
   if(ngaytrongnam != days0 && ngaytrongnam != days1 && ngaytrongnam != days2 && 
      ngaytrongnam != days3 && ngaytrongnam != days4 && ngaytrongnam != days5 && 
      ngaytrongnam != days6 && ngaytrongnam != days7 && ngaytrongnam != days8 && 
      ngaytrongnam != days9 && ngaytrongnam != days10 && ngaytrongnam != days11 && 
      ngaytrongnam != days12 && ngaytrongnam != days13 && ngaytrongnam != days14 && 
      ngaytrongnam != days15 && ngaytrongnam != days16 && ngaytrongnam != days17 &&
      ngaytrongnam != days18 && ngaytrongnam != days19 && ngaytrongnam != days20&& ngaytrongnam != days21)
     {
      DieuKienSell2 = True;
     }
   //+Dieu Kien Buy Sell 3----------------------------------------------+
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienBuy3 = True;
     }
   if(Hour() == Hour_From+MT4_TIMEZONE_GMT && Minute() < Minute_To)
     {
      DieuKienSell3 = True;
     }
   //+------------------------------------------------------------------+
   if(DieuKienBuy1==True 
   && DieuKienBuy2==True 
   && DieuKienBuy3==True
   )
     {
      TinHieu = OP_BUY;
     }
   if(DieuKienSell1==True 
   && DieuKienSell2==True 
   && DieuKienSell3==True
   )
     {
      TinHieu = OP_SELL;
     }  
   return(TinHieu);
  } 
 
 
 
//+------------------------------------------------------------------+
void Lenh_MoLenhTrucTiep(int kieulenh, double khoiluong, int sl, int tp, int magic){
   int temp = 0;
   double giasl = 0, giatp = 0;
   if(sl != 0)
   {
      if(kieulenh == OP_BUY)
         giasl = Ask - sl * Point;
      if(kieulenh == OP_SELL)
         giasl = Bid + sl * Point;
   }
   if(tp != 0)
   {
      if(kieulenh == OP_BUY)
         giatp = Ask + tp * Point;
      if(kieulenh == OP_SELL)
         giatp = Bid - tp * Point;
   }
   if(kieulenh == OP_BUY)
      temp = OrderSend(Symbol(), OP_BUY, khoiluong, Ask, 3, giasl, giatp, EA_NAME+"_"+YOUR_COMMENT_IN_MT4, magic, 0, clrBlue);
   if(kieulenh == OP_SELL)
      temp = OrderSend(Symbol(), OP_SELL, khoiluong, Bid, 3, giasl, giatp, EA_NAME+"_"+YOUR_COMMENT_IN_MT4, magic, 0, clrRed);
}
//+------------------------------------------------------------------+
void Lenh_MoLenhCho(int kieulenh, double khoiluong, double giamolenh, int sl, int tp, int magic){
   int temp = 0;
   double giasl = 0, giatp = 0;
   if(sl != 0){
      if(kieulenh == OP_BUYLIMIT || kieulenh == OP_BUYSTOP)
         giasl = giamolenh - sl * Point;
      if(kieulenh == OP_SELLLIMIT || kieulenh == OP_SELLSTOP)
         giasl = giamolenh + sl * Point;
   }
   if(tp != 0){
      if(kieulenh == OP_BUYLIMIT || kieulenh == OP_BUYSTOP)
         giatp = giamolenh + tp * Point;
      if(kieulenh == OP_SELLLIMIT || kieulenh == OP_SELLSTOP)
         giatp = giamolenh - tp * Point;
   }
   if(kieulenh == OP_BUYLIMIT)
      temp = OrderSend(Symbol(), OP_BUYLIMIT, khoiluong, giamolenh, 0, giasl, giatp, "MO LENH CHO", magic, 0, clrBlue);
   if(kieulenh == OP_SELLLIMIT)
      temp = OrderSend(Symbol(), OP_SELLLIMIT, khoiluong, giamolenh, 0, giasl, giatp, "MO LENH CHO", magic, 0, clrRed);
   if(kieulenh == OP_BUYSTOP)
      temp = OrderSend(Symbol(), OP_BUYSTOP, khoiluong, giamolenh, 0, giasl, giatp, "MO LENH CHO", magic, 0, clrBlue);
   if(kieulenh == OP_SELLSTOP)
      temp = OrderSend(Symbol(), OP_SELLSTOP, khoiluong, giamolenh, 0, giasl, giatp, "MO LENH CHO", magic, 0, clrRed);
}
//+------------------------------------------------------------------+
int Lenh_DemTongLenhDangTrade(int kieulenh, int magic){
   int tonglenh = 0;
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderType() == kieulenh && OrderMagicNumber() == magic && OrderSymbol() == Symbol())
            tonglenh++;
   return(tonglenh);
}
//+------------------------------------------------------------------+
void Lenh_DatSLTP(int sl, int tp, int magic){
   int temp;
   double giasl = 0, giatp = 0;
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() == magic && OrderSymbol() == Symbol())
            if(OrderStopLoss() == 0 || OrderTakeProfit() == 0){
               if(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP){
                  giasl = OrderOpenPrice() - sl * Point;
                  giatp = OrderOpenPrice() + tp * Point;
                  temp = OrderModify(OrderTicket(), OrderOpenPrice(), giasl, giatp, 0, clrBlue);
               }
               if(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP){
                  giasl = OrderOpenPrice() + sl * Point;
                  giatp = OrderOpenPrice() - tp * Point;
                  temp = OrderModify(OrderTicket(), OrderOpenPrice(), giasl, giatp, 0, clrRed);
               }
            }
}
//+------------------------------------------------------------------+
void Lenh_DongTatCaLenh(int kieulenh, int magic){
   int temp = -1, G = 0, loi;
   for(int i=OrdersTotal()-1;i>=0;i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderType() == kieulenh && OrderMagicNumber() == magic && OrderSymbol() == Symbol()){
            while(G < 10)
            {
               ResetLastError();
               if(OrderType() == OP_BUY)
                  temp = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrBlue);
               if(OrderType() == OP_SELL)
                  temp = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
               if(OrderType() == OP_BUYLIMIT || kieulenh == OP_BUYSTOP)
                  temp = OrderDelete(OrderTicket(), clrBlue);
               if(OrderType() == OP_SELLLIMIT || kieulenh == OP_SELLSTOP)
                  temp = OrderDelete(OrderTicket(), clrRed);
               if(temp < 0)
               {
                  loi = GetLastError();
                  Alert("Loi dong lenh",ErrorDescription(GetLastError()));
                  Sleep(1000);
                  RefreshRates();
                  G++;
               }
               else
                 break;
            }
         }
}
//+------------------------------------------------------------------+
void Lenh_HieuChinhSLTP(int kieulenh, double sl, double tp, int magic){
   int temp = 0;
   double slmoi = 0, tpmoi = 0;
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderType() == kieulenh && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(sl != 0)
               slmoi = OrderOpenPrice() - sl * Point;
            if(tp != 0)
               tpmoi = OrderOpenPrice() + tp * Point;
            if(OrderStopLoss() != slmoi || OrderTakeProfit() != tpmoi)
               temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, tpmoi, 0, clrBlue);
         }
         if(OrderType() == kieulenh && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(sl != 0)
               slmoi = OrderOpenPrice() + sl * Point;
            if(tp != 0)
               tpmoi = OrderOpenPrice() - tp * Point;
            if(OrderStopLoss() != slmoi || OrderTakeProfit() != tpmoi)
               temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, tpmoi, 0, clrRed);
         }
      }
}
//+------------------------------------------------------------------+
void Lenh_KeoSL(int tp, int magic){
   int temp = 0, dolechsl = 0;
   double slmoi,
          stoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL), 
          diemantoan = tp * Point;
   if(stoplevel == 0)
      dolechsl = 1;
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            slmoi = Bid - (stoplevel + dolechsl) * Point;
            if(Bid - OrderOpenPrice() >= diemantoan + (stoplevel + dolechsl) * Point && OrderStopLoss() < slmoi)
               temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, OrderTakeProfit(), 0, clrBlue);
         }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            slmoi = Ask + (stoplevel + dolechsl) * Point;
            if(OrderOpenPrice() - Ask >= diemantoan + (stoplevel + dolechsl) * Point && OrderStopLoss() > slmoi)
               temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, OrderTakeProfit(), 0, clrRed);
         }
      }
}
//+------------------------------------------------------------------+
void Lenh_DoiSL(int tp, double diemdoi, double diemdoiden, int magic){
   int temp = 0;
   double slmoi = 0, diemdichchuyen = 0;
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(Bid > OrderOpenPrice()){
               slmoi = OrderOpenPrice() + diemdoiden * tp * Point;
               diemdichchuyen = OrderOpenPrice() + diemdoi * tp * Point;
               if(OrderStopLoss() <= slmoi && Bid > diemdichchuyen)
                  temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, OrderTakeProfit(), 0, clrBlue);
            }
         }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(Ask < OrderOpenPrice()){
               slmoi = OrderOpenPrice() - diemdoiden * tp * Point;
               diemdichchuyen = OrderOpenPrice() - diemdoi * tp * Point;
               if(OrderStopLoss() >= slmoi && Ask < diemdichchuyen)
                  temp = OrderModify(OrderTicket(), OrderOpenPrice(), slmoi, OrderTakeProfit(), 0, clrRed);
            }
         }
      }
}
//+------------------------------------------------------------------+
double Lenh_DemTongLoLienTiep(int magic){
   double  tonglo = 0;
   for(int i=0;i<OrdersHistoryTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(tonglo + OrderProfit() <= 0)
               tonglo = tonglo + OrderProfit() + OrderCommission() + OrderSwap();
            else
               tonglo = 0;
         }
      }   
   return(tonglo);
}
//+------------------------------------------------------------------+
int Lenh_DemTongLenhThang(int magic){
   int tonglenhthang = 0;
   for(int i=0;i<OrdersHistoryTotal();i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic  && OrderTakeProfit() == OrderClosePrice())
            tonglenhthang++;
   return(tonglenhthang);
}
//+------------------------------------------------------------------+
int TinHieu_PriceRunning_C1(){
   int kieulenh = -1;
   if(Close[0] > Open[0])
      kieulenh=OP_BUY;
   if(Close[0] < Open[0])
      kieulenh=OP_SELL;
   return(kieulenh);
}
//+------------------------------------------------------------------+
int TinHieu_PriceRunning_C2(int piptructiep){
   int kieulenh = -1;
   double giamocua = Open[0],
          khoangcachbuy = Ask - Open[0],
          khoangcachsell = Open[0] - Bid,
          ghtructiep = piptructiep * Point;
   bool xuhuongtang = false,
        xuhuonggiam = false;
   if(Bid > giamocua)
      xuhuongtang = true;
   if(Bid < giamocua)
      xuhuonggiam = true;
   if(xuhuongtang == true && khoangcachbuy >= ghtructiep)
      kieulenh=OP_BUY;
   if(xuhuonggiam == true && khoangcachsell >= ghtructiep)
      kieulenh=OP_SELL;
   return(kieulenh);
}
//+------------------------------------------------------------------+
double QLV_CongThucNhan(double lots, double tyletanglot, int magic){   
   double solot = lots;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            if(OrderProfit() < 0){
               solot = OrderLots() * tyletanglot;
               break;
            }
            else
              {
               break;
              }
   return(solot);
}
//+------------------------------------------------------------------+
double QLV_CongThucCongDon(double lots, double lotcongdon, int magic){   
   double solot = lots;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            if(OrderProfit() < 0){
               solot = OrderLots() + lotcongdon;
               break;
            }
            else
              {
               break;
              }
   return(solot);
}
//+------------------------------------------------------------------+
double QLV_CongThucCong(double lots, int loinhuanmuctieu, int magic){   
   double solot = lots,
             lo = Lenh_DemTongLoLienTiep(magic);
   if(lo < 0)
      solot = ((-1 * lo) + (lots * loinhuanmuctieu)) / loinhuanmuctieu;
   return(solot);
}
//+------------------------------------------------------------------+
double Ham_LaiXuatKep(double khoiluongbandau, double sotientoithieu){
   double lot = khoiluongbandau;
   if(khoiluongbandau == 0){
      lot = MathFloor((AccountBalance() * 0.01 / sotientoithieu) * 100) / 100;
      if(lot < MarketInfo(Symbol(),MODE_MINLOT))
         lot = MarketInfo(Symbol(),MODE_MINLOT);
      if(lot > MarketInfo(Symbol(),MODE_MAXLOT))
         lot = MarketInfo(Symbol(),MODE_MAXLOT);
   }
   return(lot);
}

//+------------------------------------------------------------------+
void Ham_Ve(string nhan, string noidung, color mau, int kichthuoc, int khuvuc, int x, int y){
   ObjectDelete(nhan);
   ObjectCreate(nhan, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(nhan, noidung, kichthuoc, "Verdana", mau);
   ObjectSet(nhan, OBJPROP_CORNER, khuvuc);
   ObjectSet(nhan, OBJPROP_XDISTANCE, x);
   ObjectSet(nhan, OBJPROP_YDISTANCE, y);
}
//+------------------------------------------------------------------+
//===============================================================
double Tinhgiabinhquan(int kieulenh, int magic)
  {
   double tong = 0;
   double tongtyle =0;
   int    tyle =0;
   for(int i=OrdersTotal();i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic || OrderType() != kieulenh) continue;
         else
           {
              tong = tong +OrderOpenPrice()*(OrderLots()/0.01);
              tongtyle = tongtyle +(OrderLots()/0.01); 
           }
        }
     }
     
    double giabinhquan = NormalizeDouble(tong/tongtyle,Digits); 
     
     
   return(giabinhquan);
  }
//===============================================================
//------------------------------------------------------------------------------------
int SolenhH1()
{
  int solenh=0;
  int Magic = DayOfYear();
 for(int i=0;i<OrdersTotal();i++)
   {
    if(TimeHour(OrderOpenTime()) == Hour() && TimeDayOfYear(OrderOpenTime()) == Magic)
      {
       solenh ++;
      }
    else solenh =0;  
   } 


return(solenh);
}

//+------------------------------------------------------------------+

bool New_Bar()
{
   static datetime New_Time=0;
   if(New_Time!=Time[0])
   {
      New_Time=Time[0];
      return(true);
   }
   return(false);
}

//Neu Sai sua lai cho nay - Bo het phan bien
void Lenh_TrailingStoploss(double Trailing_Stop, double Trailing_Step)
  {
//  double Spread = MarketInfo(Symbol(),MODE_SPREAD);
     if (OrderType()==OP_BUY) 
     {
        if (Bid-OrderOpenPrice()>Trailing_Stop*Point)
        {
           if (OrderStopLoss()<Bid-Trailing_Step*Point || OrderStopLoss() == 0)
           {
            Thaydoistoploss(Bid-Trailing_Stop*Point);
            return;
           }
        }
     }
     if (OrderType()==OP_SELL) 
     {
        if (OrderOpenPrice()-Ask>Trailing_Stop*Point)
        {
           if (OrderStopLoss()>Ask+Trailing_Step*Point || OrderStopLoss()==0) 
           {
            Thaydoistoploss(Ask+Trailing_Stop*Point);
            return;
           }
        }
     }
  }

// Ham Thay Doi StopLoss
 void Thaydoistoploss(double giaslmoi)
  {
   bool thaydoisl;
   thaydoisl=OrderModify(OrderTicket(),OrderOpenPrice(),giaslmoi,OrderTakeProfit(),0,CLR_NONE);
  }

// Dem tong lenh giao dich trong 1 ngay - ke ca buy va sell - chua co so magic - can thi them vao 
  int Lenh_TongLenhTrongNgay(){
   int TodaysOrders = 0;
   for(int i = OrdersTotal()-1; i >=0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      if(TimeDayOfYear(OrderOpenTime()) == TimeDayOfYear(TimeCurrent()) && OrderSymbol() == Symbol())
      {
         TodaysOrders += 1;
      }
   }

   for(int i = OrdersHistoryTotal()-1; i >=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY))
      if(TimeDayOfYear(OrderOpenTime()) == TimeDayOfYear(TimeCurrent()) && OrderSymbol() == Symbol())
      {
         TodaysOrders += 1;
      }
   }

   return(TodaysOrders);
}