//+------------------------------------------------------------------+
//|                                      RenkoLiveChart_v600.4.2.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------+
//|   EA VERSION
//|   RenkoLiveChart_v3.2.mq4
//|   Inspired from Renko script by "e4" (renko_live_scr.mq4)
//|   Copyleft 2009 LastViking
//|   
//|   Aug 12 2009 (LV): 
//|            - Wanted volume in my Renko chart so I wrote my own script
//|     
//|   Aug 20-21 2009 (LV) (v1.1 - v1.3):
//|            - First attempt at live Renko brick formation (bugs O bugs...)
//|            - Fixed problem with strange symbol names at some 5 digit 
//|               brokers (credit to Tigertron)
//|     
//|   Aug 24 2009 (LV) (v1.4):
//|            - Handle High / Low in history in a reasonable way (prev. 
//|               used Close)
//|   
//|   Aug 26 2009 (Lou G) (v1.5/v1.6):
//|            - Finaly fixing the "late appearance" (live Renko brick 
//|               formation) bug
//| 
//|   Aug 31 2009 (LV) (v2.0):
//|            - Not a script anylonger, but run as indicator 
//|            - Naroved down the MT4 bug that used to cause the "late appearance bug" 
//|               a little closer (has to do with High / Low gaps)
//|            - Removed the while ... sleep() loop. Renko chart is now tick 
//|               driven: -MUCH nicer to system resources this way
//| 
//|   Sep 03 2009 (LV) (v2.1):
//|            - Fixed so that Time[] holds the open time of the renko 
//|               bricks (prev. used time of close)
//|     
//|   Sep 16 2009 (Lou G) (v3.0): 
//|            - Optional wicks added
//|            - Conversion back to EA 
//|            - Auto adjust for 5 and 6 dec brokers added
//|               enter RenkoBoxSize as "actual" size e.g. "10" for 10 pips
//|            - Compensation for "zero compare" problem added
//|
//|   Okt 05 2009 (LV) (v3.1): 
//|            - Fixed a bug related to BoxOffset
//|            - Auto adjust for 3 and 4 dec JPY pairs
//|            - Removed init() function
//|            - Changed back to old style Renko brick formation
//| 
//|   Okt 13 2009 (LV) (v3.2): 
//|            - Added "EmulateOnLineChart" option (credit to Skipperxit/Mimmo)
//| 
//|   Feb 07 2014 (KZ) (v600.1): 
//|            - Build 600 forced upgrade for new history file format
//|            - Build 600 has some "funny" quirks
//|            - "So that is why everyone is laughing"?
//|            -   1) The share/lock access rights
//|            -   2) It appears to me static variables do not act right
//|            -      Seems like they might not be reset when the code is re-loaded
//|            -      Not sure, so just moved them all to common
//|            - Many thanks to LastViking, Lou G, Kiads, Mihailo, and many others
//|            - that have contributed to making Renko a success
//|            - My apologies to each of you if I have abused your code
//|            - Many thanks to Mary-Jane for helping me get up to date on passing strings to DLLs
//|            - "surprise, surprise, surprise"
//|            - Many thanks to MetaQuirks for forcing me to bring my programming skills up to date
//|
//|   Apr 03 2015 (SK) (v600.3)
//|            - Fixed missing wicks on the same side of bar as current direction
//|            - Fixed missing wicks on extremums
//|            - Made a start timer to build the chart once even if no ticks coming (i.e. during weekend)
//|   Nov 25 2015 (SK - https://www.mql5.com/en/users/marketeer) (v600.4)
//|            - Classical 'look and feel' of renko wicks applied as a patch
//|
//|   Jan 19 2106 (File45 - https://www.mql5.com/en/users/file45/publications) (v600.5 & v600.6)
//|            - Transcribed to Post MT4 Build 600 New Code
//|            - Change Renko BoxSize from int to double
//|            - Corrected ShowWicks=false failure to remove wicks 
//|   Mar 24 2106 (File45 - https://www.mql5.com/en/users/file45/publications) (v600.6)   
//|            - Convert EA to Indicator
//|
//| From the MQL4 Reference
//| MqlRates
//|
//| This structure stores information about the prices, volumes and spread.
//|
//| struct MqlRates
//| {
//|   datetime time;         // Period start time
//|   double   open;         // Open price
//|   double   high;         // The highest price of the period
//|   double   low;          // The lowest price of the period
//|   double   close;        // Close price
//|   long     tick_volume;  // Tick volume
//|   int      spread;       // Spread
//|   long     real_volume;  // Trade volume
//| };
//+---------------------------------------------------------------------------+

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "6.00"
#property strict
#property indicator_chart_window

#include <WinUser32.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
#import "user32.dll"
int RegisterWindowMessageW(string lpString);
#import
//+------------------------------------------------------------------+

input double RenkoBoxSize = 3.0;
input int RenkoBoxOffset = 0;
input int RenkoTimeFrame = 7; // Offline Timeframe
input bool ShowWicks = false;
input bool EmulateOnLineChart = true;
input bool StrangeSymbolName = false;

//+------------------------------------------------------------------+
int HstHandle = -1, LastFPos = 0, MT4InternalMsg = 0;
string sSymbolName;
datetime dtSendTime;
double dSendOpen;
double dSendHigh;
double dSendLow;
double dSendClose;
double dSendVol;
bool bStopAll = false;
int iRcdCnt = 0;
int hwnd = 0;
double BoxPoints, UpWick, DnWick;
double PrevLow, PrevHigh, PrevOpen, PrevClose, CurVolume, CurLow, CurHigh, CurOpen, CurClose;
datetime PrevTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    if(HstHandle > 0)
    {
      FileClose(HstHandle);
    }
    HstHandle = -1;
    EventSetTimer(1);
  
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   if(HstHandle >= 0)
  {
    FileClose(HstHandle);
    HstHandle = -1;
  }
  Comment("");
  return;
   
  }  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
 
   if(bStopAll) return(0);

  //+------------------------------------------------------------------+
  // This is only executed once, then the first tick arives.
  if(HstHandle < 0)
  {
    // Init
    // Error checking	
    if(!IsConnected())
    {
      Print("Waiting for connection...");
      return(0);
    }
    if(!IsDllsAllowed())
    {
      Print("Error: Dll calls must be allowed!");
      bStopAll = true;
      return(0);
    }
    if(MathAbs(RenkoBoxOffset) >= RenkoBoxSize)
    {
      Print("Error: |RenkoBoxOffset| should be less then RenkoBoxSize!");
      bStopAll = true;
      return(0);
    }
    switch(RenkoTimeFrame)
    {
      case 1:
      case 5:
      case 15:
      case 30:
      case 60:
      case 240:
      case 1440:
      case 10080:
      case 43200:
      case 0:
        Print("Error: Invald time frame used for offline renko chart (RenkoTimeFrame)!");
        bStopAll = true;
        return(0);
    }

    double BoxSize = RenkoBoxSize;
    int BoxOffset = RenkoBoxOffset;
    if(Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1))
    {
      BoxSize = BoxSize * 10;
      BoxOffset = BoxOffset * 10;
    }
    if(Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1))
    {
      BoxSize = BoxSize * 100;
      BoxOffset = BoxOffset * 100;
    }

    if(StrangeSymbolName) sSymbolName = StringSubstr(Symbol(), 0, 6);
    else sSymbolName = Symbol();
    BoxPoints = NormalizeDouble(BoxSize * Point, Digits);
    PrevLow = NormalizeDouble(BoxOffset * Point + MathFloor(Close[Bars - 1] / BoxPoints) * BoxPoints, Digits);
    DnWick = PrevLow;
    PrevHigh = PrevLow + BoxPoints;
    UpWick = PrevHigh;
    PrevOpen = PrevLow;
    PrevClose = PrevHigh;
    CurVolume = 1;
    PrevTime = Time[Bars - 1];

    // create / open hst file		
    HstHandle = FileOpenHistory(sSymbolName + IntegerToString(RenkoTimeFrame) + ".hst", FILE_BIN | FILE_WRITE | FILE_ANSI);//W1
    if(HstHandle < 0)
    {
      Print("Error: can\'t create / open history file: " + ErrorDescription(GetLastError()) + ": " + sSymbolName + IntegerToString(RenkoTimeFrame) + ".hst");
      bStopAll = true;
      return(0);
    }
    else
    {
      Print("History file opened for write, handle: " + IntegerToString(HstHandle));
      FileSeek(HstHandle, 0, SEEK_SET);
      // Hist file opened as write zero length to create
    }
    // the file is created empty, now re-open it read write shared
    DoOpenHistoryReadWrite();
    FileSeek(HstHandle, 0, SEEK_SET);
    //Hist file opened as read write for adding to


    // write hst file header  -  does anyone have a structure for this heading?
    int HstUnused[13];
    FileWriteInteger(HstHandle, 401, LONG_VALUE); // Version  // was 400
    FileWriteString(HstHandle, "", 64); // Copyright
    FileWriteString(HstHandle, sSymbolName, 12); // Symbol
    FileWriteInteger(HstHandle, RenkoTimeFrame, LONG_VALUE); // Period
    FileWriteInteger(HstHandle, Digits, LONG_VALUE); // Digits
    FileWriteInteger(HstHandle, 0, LONG_VALUE); // Time Sign
    FileWriteInteger(HstHandle, 0, LONG_VALUE); // Last Sync
    FileWriteArray(HstHandle, HstUnused, 0, 13); // Unused

    // process historical data
    int i = Bars - 2;
    //Print(Symbol() + " " + High[i] + " " + Low[i] + " " + Open[i] + " " + Close[i]);
    //---------------------------------------------------------------------------
    while(i >= 0)
    {
      CurVolume = CurVolume + Volume[i];

      UpWick = MathMax(UpWick, High[i]);
      DnWick = MathMin(DnWick, Low[i]);

      // update low before high or the revers depending on is closest to prev. bar
      bool UpTrend = High[i] + Low[i] > High[i + 1] + Low[i + 1];
      bool WipeUpWick = false, WipeDownWick = false;

      // go down in up phase
      while(UpTrend && (Low[i] < PrevLow - BoxPoints || CompareDoubles(Low[i], PrevLow - BoxPoints)))
      {
        PrevHigh = PrevHigh - BoxPoints;
        PrevLow = PrevLow - BoxPoints;
        PrevOpen = PrevHigh;
        PrevClose = PrevLow;

        dtSendTime = PrevTime;
        dSendOpen = PrevOpen;
        if(ShowWicks==true && DnWick < PrevLow && Low[i] >= PrevLow - BoxPoints)
        {
          dSendLow = DnWick;
          WipeDownWick = true;
        }
        else
        {
          //dSendLow = PrevLow;// When ShowWicks = false this code will show wicks (file45)
          dSendLow = PrevHigh;
         
        }
        
        if(ShowWicks==true && UpWick > PrevHigh && UpWick <= PrevHigh + 2 * BoxPoints)
        {
          dSendHigh = UpWick;
          WipeUpWick = true;
        }
        else
        {
          dSendHigh = PrevHigh;
          
        }
        
        dSendClose = PrevClose;
        dSendVol = CurVolume;
        DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);

        if(WipeUpWick) UpWick = 0;
        if(WipeDownWick) DnWick = EMPTY_VALUE;
        CurVolume = 0;
        CurHigh = PrevLow;
        CurLow = PrevLow;

        if(PrevTime < Time[i]) PrevTime = Time[i];
        else PrevTime++;
      }

      // go up
      while(High[i] > PrevHigh + BoxPoints || CompareDoubles(High[i], PrevHigh + BoxPoints))
      {
        PrevHigh = PrevHigh + BoxPoints;
        PrevLow = PrevLow + BoxPoints;
        PrevOpen = PrevLow;
        PrevClose = PrevHigh;

        dtSendTime = PrevTime;
        dSendOpen = PrevOpen;
        
        if(ShowWicks==true && DnWick < PrevLow && DnWick >= PrevLow - 2 * BoxPoints )
        {
          dSendLow = DnWick;
          WipeDownWick = true;
        }
        else
        {
          dSendLow = PrevLow;
        }
        
         
        if(ShowWicks==true && UpWick > PrevHigh && High[i] <= PrevHigh + BoxPoints)
        {
          dSendHigh = UpWick;
          WipeUpWick = true;
        }
        else
        {
          //dSendHigh = PrevHigh; // When ShowWicks = false this code will show wicks (file45)
          dSendHigh = PrevLow;
        }
       
        dSendClose = PrevClose;
        dSendVol = CurVolume;
        DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);

        if(WipeUpWick) UpWick = 0;
        if(WipeDownWick) DnWick = EMPTY_VALUE;
        CurVolume = 0;
        CurHigh = PrevHigh;
        CurLow = PrevHigh;

        if(PrevTime < Time[i]) PrevTime = Time[i];
        else PrevTime++;
      
         RefreshRates();
      }

      // go down in down phase
      while(!UpTrend && (Low[i] < PrevLow - BoxPoints || CompareDoubles(Low[i], PrevLow - BoxPoints)))
      {
        PrevHigh = PrevHigh - BoxPoints;
        PrevLow = PrevLow - BoxPoints;
        PrevOpen = PrevHigh;
        PrevClose = PrevLow;

        dtSendTime = PrevTime;
        dSendOpen = PrevOpen;
        
        if(ShowWicks==true && DnWick < PrevLow && Low[i] >= PrevLow - BoxPoints)
        {
          dSendLow = DnWick;
          WipeDownWick = true;
        }
        else
        {
          //dSendLow = PrevLow; // When ShowWicks = false this code will show wicks (file45)
          dSendLow = PrevHigh;
        }
        
        
        if(ShowWicks==true && UpWick > PrevHigh)
        {
          dSendHigh = UpWick;
          WipeUpWick = true;
        }
        else
        {
          dSendHigh = PrevHigh;
        }
       
        dSendClose = PrevClose;
        dSendVol = CurVolume;
        DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);

        if(WipeUpWick) UpWick = 0;
        if(WipeDownWick) DnWick = EMPTY_VALUE;
        CurVolume = 0;
        CurHigh = PrevLow;
        CurLow = PrevLow;

        if(PrevTime < Time[i]) PrevTime = Time[i];
        else PrevTime++;
      
        RefreshRates();
      }
      i--;
    }
    LastFPos = (int)FileTell(HstHandle); // Remember Last pos in file

    if(Close[0] > MathMax(PrevClose, PrevOpen)) CurOpen = MathMax(PrevClose, PrevOpen);
    else if(Close[0] < MathMin(PrevClose, PrevOpen)) CurOpen = MathMin(PrevClose, PrevOpen);
    else CurOpen = Close[0];

    CurClose = Close[0];

    if(ShowWicks==true)
    {
      if(UpWick > PrevHigh) CurHigh = UpWick;
      if(DnWick < PrevLow) CurLow = DnWick;
    }

    dtSendTime = PrevTime;
    dSendOpen = CurOpen;
    dSendLow = CurLow;
    dSendHigh = CurHigh;
    dSendClose = CurClose;
    dSendVol = CurVolume;
    DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);
    FileFlush(HstHandle);

    if(bStopAll) return(0);
    Comment("RenkoLiveChart (" + DoubleToString(RenkoBoxSize) + "): Open Offline ", sSymbolName, ",M", RenkoTimeFrame, " To View Chart");//3
    UpdateChartWindow();
    return(0);
    // End historical data / Init		
  }
  //----------------------------------------------------------------------------
  // HstHandle not < 0 so we always enter here after history done
  // Begin live data feed
  if(bStopAll) return(0);
  UpWick = MathMax(UpWick, Bid);
  DnWick = MathMin(DnWick, Bid);

  CurVolume++;
  FileSeek(HstHandle, LastFPos, SEEK_SET);

  //-------------------------------------------------------------------------	   				
  // up box	   				
  if(Bid > PrevHigh + BoxPoints || CompareDoubles(Bid, PrevHigh + BoxPoints))
  {
    PrevHigh = PrevHigh + BoxPoints;
    PrevLow = PrevLow + BoxPoints;
    PrevOpen = PrevLow;
    PrevClose = PrevHigh;

    dtSendTime = PrevTime;
    dSendOpen = PrevOpen;
    if(ShowWicks==true && DnWick < PrevLow)
    {
      dSendLow = DnWick;
    }
    else
    {
      dSendLow = PrevLow;
    }
    if(ShowWicks==true && UpWick > PrevHigh)
    {
      dSendHigh = UpWick;
    }
    else
    {
      dSendHigh = PrevHigh;
    }
    dSendClose = PrevClose;
    dSendVol = CurVolume;
    DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);
    FileFlush(HstHandle);
    LastFPos = (int) FileTell(HstHandle); // Remeber Last pos in file				  							

    if(PrevTime < TimeCurrent()) PrevTime = TimeCurrent();
    else PrevTime++;

    CurVolume = 0;
    CurHigh = PrevHigh;
    CurLow = PrevHigh;

    UpWick = 0;
    DnWick = EMPTY_VALUE;

    UpdateChartWindow();
  }
  //-------------------------------------------------------------------------	   				
  // down box
  else if(Bid < PrevLow - BoxPoints || CompareDoubles(Bid, PrevLow - BoxPoints))
  {
    PrevHigh = PrevHigh - BoxPoints;
    PrevLow = PrevLow - BoxPoints;
    PrevOpen = PrevHigh;
    PrevClose = PrevLow;

    dtSendTime = PrevTime;
    dSendOpen = PrevOpen;
   
    if(ShowWicks==true && DnWick < PrevLow)
    {
      dSendLow = DnWick;
    }
    else
    {
      dSendLow = PrevLow;
      
    }
    
    if(ShowWicks==true && UpWick > PrevHigh)
    {
      dSendHigh = UpWick;
    }
    else
    {
      dSendHigh = PrevHigh;
    }
    dSendClose = PrevClose;
    dSendVol = CurVolume;
    DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol);
    FileFlush(HstHandle);
    LastFPos = (int)FileTell(HstHandle); // Remeber Last pos in file				  							

    if(PrevTime < TimeCurrent()) PrevTime = TimeCurrent();
    else PrevTime++;

    CurVolume = 0;
    CurHigh = PrevLow;
    CurLow = PrevLow;

    UpWick = 0;
    DnWick = EMPTY_VALUE;

    UpdateChartWindow();
  }
  //-------------------------------------------------------------------------	   				
  // no box - high/low not hit				
  else
  {
    if(Bid > CurHigh) CurHigh = Bid;
    if(Bid < CurLow) CurLow = Bid;

    if(PrevHigh <= Bid) CurOpen = PrevHigh;
    else if(PrevLow >= Bid) CurOpen = PrevLow;
    else CurOpen = Bid;

    CurClose = Bid;

    dtSendTime = PrevTime;
    dSendOpen = CurOpen;
    dSendLow = CurLow;
    dSendHigh = CurHigh;
    dSendClose = CurClose;
    dSendVol = CurVolume;
    DoWriteStruct(dtSendTime, dSendOpen, dSendHigh, dSendLow, dSendClose, dSendVol, false);
    FileFlush(HstHandle);

    UpdateChartWindow();
  }
   return(rates_total);
  }
 
 void UpdateChartWindow()
{
  if(hwnd == 0)
  {
    hwnd = WindowHandle(sSymbolName, RenkoTimeFrame);
    if(hwnd != 0) Print("Chart window detected");
  }
  if(EmulateOnLineChart && MT4InternalMsg == 0) MT4InternalMsg = RegisterWindowMessageW("MetaTrader4_Internal_Message");
  if(hwnd != 0) if(PostMessageW(hwnd, WM_COMMAND, 0x822c, 0) == 0) hwnd = 0;
  if(hwnd != 0 && MT4InternalMsg != 0) PostMessageW(hwnd, MT4InternalMsg, 2, 1);
  return;
}

void DoWriteStruct(datetime dtTime, double dOpen, double dHigh, double dLow, double dClose, double dVol, bool history = true)
{
  iRcdCnt++;
  static int iErr = 0;
  static int iBWritn = 0;
  MqlRates rate;
  rate.time = dtTime;
  rate.open = dOpen;
  static double prevHigh = 0, prevLow = DBL_MAX;
  if(history)
  {
    rate.high = (dOpen < dClose)?dClose:MathMax(dHigh, prevHigh);
    rate.low = (dOpen > dClose)?dClose:MathMin(dLow, prevLow);
    prevHigh = (dOpen < dClose)?dHigh:0;
    prevLow = (dOpen > dClose)?dLow:DBL_MAX;
  }
  else
  {
    rate.high = dHigh;
    rate.low = dLow;
  }
  rate.close = dClose;
  rate.tick_volume = (long) dVol;
  rate.spread = 0;
  rate.real_volume = (long) dVol;
  iBWritn = (int)FileWriteStruct(HstHandle, rate);
  if(iBWritn == 0)
  {
    iErr = GetLastError();
    Print("Error on write struct at cntr: " + IntegerToString(iRcdCnt) + ", errdesc: " + ErrorDescription(iErr));//W4
    bStopAll = true;
  }
  return;
}

void DoOpenHistoryReadWrite()
{
  if(HstHandle >= 0)
  {
    int iSz = (int)FileSize(HstHandle);
    Print("fl sz " + IntegerToString(iSz));
    FileClose(HstHandle);
    HstHandle = -1;
  }
  HstHandle = FileOpenHistory(
  sSymbolName + IntegerToString(RenkoTimeFrame) + ".hst", FILE_BIN | FILE_READ | FILE_WRITE | FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_ANSI);
  // this combination is critical to unlock the file and still allow read write and opening a chart on it
  if(HstHandle < 0)
  {
    Print("Error: cant open history file read write: " + ErrorDescription(GetLastError()) + ": " + sSymbolName + IntegerToString(RenkoTimeFrame) + ".hst");
    bStopAll = true;
  }
  else
  {
    Print("Hist file opened for read write, handle: " + IntegerToString(HstHandle));
  }
  return;
}