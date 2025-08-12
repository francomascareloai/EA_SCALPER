//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
CTrade obj_Trade;
#define Btn_BUY "BuyButton"
#define Btn_SELL "SellButton"
#define Btn_CLOSE_ALL "CloseAllButton"
#define Btn_CLOSE_ALL_PROFIT "CloseProfitButton"
#define Btn_CLOSE_ALL_LOSS "CloseLoseButton"

#include <Controls/Button.mqh>
CButton obj_Btn_BUY;
CButton obj_Btn_SELL;
CButton obj_Btn_CLOSE_ALL;
CButton obj_Btn_CLOSE_ALL_LOSS;
CButton obj_Btn_CLOSE_ALL_PROFIT;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int maxOpLayers = 5;               // Jumlah maksimal posisi yang dapat dibuka
input int tpPoints = 5000;                 // TP dalam point
input int slPoints = 10000;                // SL dalam point
input double lotSize = 0.01;              // Ukuran lot untuk setiap posisi
input int slippage = 10;                  // Slippage untuk order
input int layerInterval = 2;              // Jarak antar posisi dalam detik (interval)
input string CommentOrder  = "Trade";   //CommentOrder
input int inMagicNumber  = 123456;   //Magic Number
input int trailingStopPoints = 1000;  // Trailing stop dalam points (misalnya 1000 untuk 100 pips)


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Membuat tombol Buy
   obj_Btn_BUY.Create(0, Btn_BUY, 0, 20,50, 0, 0);
   obj_Btn_BUY.Size(100, 30);
   obj_Btn_BUY.Text("BUY");
   obj_Btn_BUY.Color(clrWhite);
   obj_Btn_BUY.ColorBackground(clrDodgerBlue);
   obj_Btn_BUY.ColorBorder(clrWhite);



// Membuat tombol Sell
   obj_Btn_SELL.Create(0, Btn_SELL, 0, 140,50, 0, 0);
   obj_Btn_SELL.Size(100, 30);
   obj_Btn_SELL.Text("SELL");
   obj_Btn_SELL.Color(clrWhite);
   obj_Btn_SELL.ColorBackground(clrTomato);
   obj_Btn_SELL.ColorBorder(clrWhite);

//// Membuat tombol Close All
   obj_Btn_CLOSE_ALL.Create(0, Btn_CLOSE_ALL, 0, 260,50, 0, 0);
   obj_Btn_CLOSE_ALL.Size(100, 30);
   obj_Btn_CLOSE_ALL.Text("Close All");
   obj_Btn_CLOSE_ALL.Color(clrBlack);
   obj_Btn_CLOSE_ALL.ColorBackground(clrYellow);
   obj_Btn_CLOSE_ALL.ColorBorder(clrWhite);

//// Membuat tombol Close All Profit
   obj_Btn_CLOSE_ALL_PROFIT.Create(0, Btn_CLOSE_ALL_PROFIT, 0, 380,50, 0, 0);
   obj_Btn_CLOSE_ALL_PROFIT.Size(100, 30);
   obj_Btn_CLOSE_ALL_PROFIT.Text("Close Profit");
   obj_Btn_CLOSE_ALL_PROFIT.Color(clrWhite);
   obj_Btn_CLOSE_ALL_PROFIT.ColorBackground(clrGreen);
   obj_Btn_CLOSE_ALL_PROFIT.ColorBorder(clrWhite);

//// Membuat tombol Close All Lose
   obj_Btn_CLOSE_ALL_LOSS.Create(0, Btn_CLOSE_ALL_LOSS, 0, 500,50, 0, 0);
   obj_Btn_CLOSE_ALL_LOSS.Size(100, 30);
   obj_Btn_CLOSE_ALL_LOSS.Text("Close Lose");
   obj_Btn_CLOSE_ALL_LOSS.Color(clrWhite);
   obj_Btn_CLOSE_ALL_LOSS.ColorBackground(clrRed);
   obj_Btn_CLOSE_ALL_LOSS.ColorBorder(clrWhite);


   obj_Trade.SetExpertMagicNumber(inMagicNumber);
   obj_Trade.SetDeviationInPoints(slippage);
   obj_Trade.SetAsyncMode(true);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Menghapus tombol saat EA dihapus
   ObjectDelete(0, Btn_BUY);
   ObjectDelete(0, Btn_SELL);
   ObjectDelete(0, Btn_CLOSE_ALL);
   ObjectDelete(0, Btn_CLOSE_ALL_PROFIT);
   ObjectDelete(0, Btn_CLOSE_ALL_LOSS);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Cek apakah tombol BUY ditekan
   if(obj_Btn_BUY.Pressed())
     {
      OpenBuyLayers();  // Membuka beberapa posisi BUY
      obj_Btn_BUY.Pressed(false);
     }

// Cek apakah tombol SELL ditekan
   if(obj_Btn_SELL.Pressed())
     {
      OpenSellLayers();  // Membuka beberapa posisi SELL
      obj_Btn_SELL.Pressed(false);
     }

// Cek apakah tombol Close All ditekan
   if(obj_Btn_CLOSE_ALL.Pressed())
     {
      CloseAllPositions();  // Menutup semua posisi
      obj_Btn_CLOSE_ALL.Pressed(false);
     }

// Cek apakah tombol Close Profit ditekan
   if(obj_Btn_CLOSE_ALL_PROFIT.Pressed())
     {
      CloseProfitPositions();  // Menutup semua posisi profit
      obj_Btn_CLOSE_ALL_PROFIT.Pressed(false);
     }

// Cek apakah tombol Close Lose ditekan
   if(obj_Btn_CLOSE_ALL_LOSS.Pressed())
     {
      CloseLosePositions();  // Menutup semua posisi loss
      obj_Btn_CLOSE_ALL_LOSS.Pressed(false);
     }
     // Menjalankan Trailing Stop
   TrailingStop();
  }

// Fungsi untuk membuka posisi BUY
void OpenBuyLayers()
  {
   for(int i = 0; i < maxOpLayers; i++)
     {
      int    digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
      double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double SL=NormalizeDouble(price-slPoints*_Point,digits);
      double TP=NormalizeDouble(price+tpPoints*_Point,digits);

      if(obj_Trade.Buy(lotSize, _Symbol, price, SL, TP, CommentOrder))
        {
         Print("BUY order opened ",obj_Trade.ResultRetcode(),
               " (",obj_Trade.ResultRetcodeDescription(),")");

        }
      else
        {
         //--- failure message
         Print("Error opening BUY order ",obj_Trade.ResultRetcode(),
               ". Code description: ",obj_Trade.ResultRetcodeDescription());

        }

      // Jeda antar order
      Sleep(layerInterval * 1000);
     }
  }

// Fungsi untuk membuka posisi SELL
void OpenSellLayers()
  {
   for(int i = 0; i < maxOpLayers; i++)
     {
      int    digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
      double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double SL=NormalizeDouble(price+slPoints*_Point,digits);
      double TP=NormalizeDouble(price-tpPoints*_Point,digits);

      if(obj_Trade.Sell(lotSize, _Symbol, price, SL, TP, CommentOrder))
        {
         Print("SELL order opened ",obj_Trade.ResultRetcode(),
               " (",obj_Trade.ResultRetcodeDescription(),")");

        }
      else
        {
         //--- failure message
         Print("Error opening SELL order ",obj_Trade.ResultRetcode(),
               ". Code description: ",obj_Trade.ResultRetcodeDescription());

        }

      // Jeda antar order
      Sleep(layerInterval * 1000);
     }
  }

void TrailingStop()
{
   int totalPositions = PositionsTotal();
   
   // Pastikan ada posisi terbuka
   if (totalPositions == 0)
   {
      Print("No positions to modify.");
      return;
   }

   for (int i = 0; i < totalPositions; i++)
   {
      ulong ticket = PositionGetTicket(i); // Mendapatkan tiket posisi
      if (PositionSelect(ticket))
      {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);  // Harga buka posisi
         double currentPrice = SymbolInfoDouble(_Symbol, PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? SYMBOL_BID : SYMBOL_ASK);
         double stopLoss = PositionGetDouble(POSITION_SL);  // SL sebelumnya
         double newStopLoss = 0;

         // Untuk posisi BUY
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            // Jika harga bergerak cukup jauh untuk trailing stop
            if (currentPrice - openPrice >= trailingStopPoints * _Point)
            {
               newStopLoss = currentPrice - trailingStopPoints * _Point;  // Tentukan SL baru
               if (newStopLoss > stopLoss)  // Pastikan SL baru lebih baik daripada yang lama
               {
                  // Modifikasi SL menjadi nilai yang lebih menguntungkan
                  if (!obj_Trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP)))
                  {
                     Print("Error updating stop loss for BUY position: ", obj_Trade.ResultRetcode());
                  }
                  else
                  {
                     Print("BUY Stop Loss updated to: ", newStopLoss);
                  }
               }
            }
         }
         // Untuk posisi SELL
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            // Jika harga bergerak cukup jauh untuk trailing stop
            if (openPrice - currentPrice >= trailingStopPoints * _Point)
            {
               newStopLoss = currentPrice + trailingStopPoints * _Point;  // Tentukan SL baru
               if (newStopLoss < stopLoss)  // Pastikan SL baru lebih baik daripada yang lama
               {
                  // Modifikasi SL menjadi nilai yang lebih menguntungkan
                  if (!obj_Trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP)))
                  {
                     Print("Error updating stop loss for SELL position: ", obj_Trade.ResultRetcode());
                  }
                  else
                  {
                     Print("SELL Stop Loss updated to: ", newStopLoss);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   ulong st = GetMicrosecondCount();
   int total = PositionsTotal();

   for(int cnt = total - 1; cnt >= 0 && !IsStopped(); cnt--)
     {
      ulong position_ticket = PositionGetTicket(cnt);
      if(PositionSelectByTicket(position_ticket))
        {
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         if(magic == inMagicNumber)
           {
            obj_Trade.PositionClose(position_ticket);
            uint code = obj_Trade.ResultRetcode();
            if(code != 10008)
              {
               PrintFormat("Error closing position %lu: %d (%s)", position_ticket, code, obj_Trade.ResultRetcodeDescription());
              }
           }
        }
     }

   int timeout = 10000;
   int sleepInterval = 100;
   int maxIterations = timeout / sleepInterval;

   for(int i = 0; i < maxIterations; i++)
     {
      if(PositionsTotal() <= 0)
        {
         Print("All positions closed successfully.");
         break;
        }
      Sleep(sleepInterval);
     }

   if(PositionsTotal() > 0)
     {
      Print("Timeout: Not all positions were closed.");
     }
  }




// Fungsi untuk menutup posisi profit
void CloseProfitPositions()
  {
   ulong st = GetMicrosecondCount();
   int total = PositionsTotal();

   for(int i = total - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong position_ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(position_ticket))
        {
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(magic == inMagicNumber && profit > 0)
           {
            // Proses penutupan posisi
            obj_Trade.PositionClose(position_ticket);
            uint code = obj_Trade.ResultRetcode();
            if(code != 10008)  // 10008 adalah TRADE_RETCODE_PLACED : OK
              {
               PrintFormat("Error closing profitable position %lu: %d (%s)", position_ticket, code, obj_Trade.ResultRetcodeDescription());
              }
           }
        }
     }


   int timeout = 10000;
   int sleepInterval = 100;
   int maxIterations = timeout / sleepInterval;

   for(int i = 0; i < maxIterations; i++)
     {
      if(PositionsTotal() <= 0)
        {
         Print("All profitable positions closed successfully.");
         break;
        }
      Sleep(sleepInterval);
     }

   if(PositionsTotal() > 0)
     {
      Print("Timeout: Not all profitable positions were closed.");
     }
  }


// Fungsi untuk menutup posisi loss
void CloseLosePositions()
  {
   ulong st = GetMicrosecondCount();
   int total = PositionsTotal();

   for(int i = total - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong position_ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(position_ticket))
        {
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(magic == inMagicNumber && profit < 0)
           {
            // Proses penutupan posisi
            obj_Trade.PositionClose(position_ticket);
            uint code = obj_Trade.ResultRetcode();
            if(code != 10008)  // 10008 adalah TRADE_RETCODE_PLACED : OK
              {
               PrintFormat("Error closing Lose position %lu: %d (%s)", position_ticket, code, obj_Trade.ResultRetcodeDescription());
              }
           }
        }
     }


   int timeout = 10000;
   int sleepInterval = 100;
   int maxIterations = timeout / sleepInterval;

   for(int i = 0; i < maxIterations; i++)
     {
      if(PositionsTotal() <= 0)
        {
         Print("All Lose positions closed successfully.");
         break;
        }
      Sleep(sleepInterval);
     }

   if(PositionsTotal() > 0)
     {
      Print("Timeout: Not all Lose positions were closed.");
     }
  }
//+------------------------------------------------------------------+
