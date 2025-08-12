//+---------------------------------------------------------------------------+
//|   EA VERSION
//|   RenkoRangeBars_V1.1.mq4 modified by Chris_B
//|   Based on RenkoLiveChart_v3.2.mq4
//|   Inspired from Renko script by "e4" (renko_live_scr.mq4)
//|   Copyleft 2009 LastViking
//|   Copyleft 2009 Chris_B
//|   
//|   Dec 10 2009
//|            - Modified the EA so renko bars can show range and reversals,
//|              Needed for "50Pips Candle" Strategy created by Zebulon
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
//|               driven: -MUSH nicer to system resources this way
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
//+---------------------------------------------------------------------------+
#property copyright "©2009 LastViking || ©2012 Tommy Prasetyanto && Mladen" 
#property indicator_chart_window
//+------------------------------------------------------------------+
#include <WinUser32.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
#import "user32.dll"
	int RegisterWindowMessageA(string lpString); 
#import
//+------------------------------------------------------------------+
extern int CandleSize = 50;
extern int Offset = 0;
extern int TimeFrame = 2;      // What time frame to use for the offline renko chart
extern bool ShowWicks = false;
extern bool EmulateOnLineChart = true;
extern bool StrangeSymbolName = false;
//+------------------------------------------------------------------+
int HstHandle = -1, LastFPos = 0, MT4InternalMsg = 0;
string SymbolName;
//+------------------------------------------------------------------+
#import "user32.dll"
   int GetParent(int hWnd);
   int GetWindow(int hWnd,int uCmd);
   int RegisterWindowMessageW(string lpString);
   int GetWindowTextW(int hWnd,string lpString,int nMaxCount);
   int PostMessageW(int hWnd,int Msg,int wParam,int lParam);
#import

//+------------------------------------------------------------------+
void UpdateChartWindow() {
	static int hwnd = 0;
 
	if(hwnd == 0) {
		hwnd = WindowHandle(SymbolName, TimeFrame);
		if(hwnd != 0) Print("Chart window detected");
	}

	if(EmulateOnLineChart && MT4InternalMsg == 0) 
		MT4InternalMsg = RegisterWindowMessageW("MetaTrader4_Internal_Message");

	if(hwnd != 0) if(PostMessageW(hwnd, WM_COMMAND, 0x822c, 0) == 0) hwnd = 0;
	if(hwnd != 0 && MT4InternalMsg != 0) PostMessageW(hwnd, MT4InternalMsg, 2, 1);

	return;
}
//+------------------------------------------------------------------+
int start() {

	static double BoxPoints, UpWick, DnWick;
	static double PrevLow, PrevHigh, PrevOpen, PrevClose, CurVolume, CurLow, CurHigh, CurOpen, CurClose;
	static datetime PrevTime;
   	
	//+------------------------------------------------------------------+
	// This is only executed ones, then the first tick arives.
   MqlRates rates;
	if(HstHandle < 0) {
		// Init

		// Error checking	
		if(!IsConnected()) {
			Print("Waiting for connection...");
			return(0);
		}							
		if(!IsDllsAllowed()) {
			Print("Error: Dll calls must be allowed!");
			return(-1);
		}		
		if(MathAbs(Offset) >= CandleSize) {
			Print("Error: |Offset| should be less then CandleSize!");
			return(-1);
		}
		switch(TimeFrame) {
		case 1: case 5: case 15: case 30: case 60: case 240:
		case 1440: case 10080: case 43200: case 0:
			Print("Error: Invald time frame used for offline renko chart (TimeFrame)!");
			return(-1);
		}
		//
		
		int BoxSize = CandleSize;
		int BoxOffset = Offset;
		if(Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize = BoxSize*10;
			BoxOffset = BoxOffset*10;
		}
		if(Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize = BoxSize*100;		
			BoxOffset = BoxOffset*100;
		}
		
		if(StrangeSymbolName) SymbolName = StringSubstr(Symbol(), 0, 6);
		else SymbolName = Symbol();
		BoxPoints = NormalizeDouble(BoxSize*Point, Digits);
		PrevLow = NormalizeDouble(BoxOffset*Point + MathFloor(Close[Bars-1]/BoxPoints)*BoxPoints, Digits);
		DnWick = PrevLow;
		PrevHigh = PrevLow + BoxPoints;
		UpWick = PrevHigh;
		PrevOpen = PrevLow;
		PrevClose = PrevHigh;
		CurVolume = 1;
		PrevTime = Time[Bars-1];
	
		// create / open hst file		
		HstHandle = FileOpenHistory(SymbolName + (string)TimeFrame + ".hst", FILE_BIN|FILE_WRITE|FILE_ANSI);
		FileClose(HstHandle); HstHandle = -1;
		HstHandle = FileOpenHistory(SymbolName + (string)TimeFrame + ".hst", FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
		
		//HstHandle = FileOpenHistory(SymbolName + TimeFrame + ".hst", FILE_BIN|FILE_WRITE);
		if(HstHandle < 0) {
			Print("Error: can\'t create / open history file: " + ErrorDescription(GetLastError()) + ": " + SymbolName + TimeFrame + ".hst");
			return(-1);
		}
		//
   	
		// write hst file header
		int HstUnused[13];
		FileWriteInteger(HstHandle, 401, LONG_VALUE); 			// Version
		FileWriteString(HstHandle, "", 64);					// Copyright
		FileWriteString(HstHandle, SymbolName, 12);			// Symbol
		FileWriteInteger(HstHandle, TimeFrame, LONG_VALUE);	// Period
		FileWriteInteger(HstHandle, Digits, LONG_VALUE);		// Digits
		FileWriteInteger(HstHandle, 0, LONG_VALUE);			// Time Sign
		FileWriteInteger(HstHandle, 0, LONG_VALUE);			// Last Sync
		FileWriteArray(HstHandle, HstUnused, 0, 13);			// Unused
		//
   	
 		// process historical data
  		int i = Bars-2;
		//Print(Symbol() + " " + High[i] + " " + Low[i] + " " + Open[i] + " " + Close[i]);
		//---------------------------------------------------------------------------
  		while(i >= 0) {
  		
			CurVolume = CurVolume + Volume[i];
		
			UpWick = MathMax(UpWick, High[i]);
			DnWick = MathMin(DnWick, Low[i]);

			// update low before high or the revers depending on is closest to prev. bar
		
			while((Low[i] < PrevClose-BoxPoints || CompareDoubles(Low[i], PrevClose-BoxPoints))) {
  				PrevHigh = PrevClose;
  				PrevLow = PrevClose - BoxPoints;
  				PrevOpen = PrevHigh;
  				PrevClose = PrevClose - BoxPoints;

            rates.time = PrevTime;
            rates.open = PrevOpen;
            rates.low  = PrevLow;
            if(ShowWicks && UpWick > PrevHigh)
                  rates.high = UpWick;
            else  rates.high = PrevHigh;             
            rates.close = PrevClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);

				//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);
				//FileWriteDouble(HstHandle, PrevOpen, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle, PrevLow, DOUBLE_VALUE);

				//if(ShowWicks && UpWick > PrevHigh) FileWriteDouble(HstHandle, UpWick, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle, PrevHigh, DOUBLE_VALUE);
				  				  			
				//FileWriteDouble(HstHandle, PrevClose, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);
				
				UpWick = 0;
				DnWick = EMPTY_VALUE;
				CurVolume = 0;
				CurHigh = PrevLow;
				CurLow = PrevLow;  
				
				if(PrevTime < Time[i]) PrevTime = Time[i];
				else PrevTime++;
			}
		
			while(High[i] > PrevClose+BoxPoints || CompareDoubles(High[i], PrevClose+BoxPoints)) {
  				PrevHigh = PrevClose + BoxPoints;
  				PrevLow = PrevClose;
  				PrevOpen = PrevLow;
  				PrevClose = PrevClose + BoxPoints;
  			
            rates.time = PrevTime;
            rates.open = PrevOpen;
            rates.high = PrevHigh;
            if(ShowWicks && DnWick < PrevLow)
                  rates.low = DnWick;
            else  rates.low = PrevLow;             
            rates.close = PrevClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);
  			
				//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);
				//FileWriteDouble(HstHandle, PrevOpen, DOUBLE_VALUE);

            //if(ShowWicks && DnWick < PrevLow) FileWriteDouble(HstHandle, DnWick, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle, PrevLow, DOUBLE_VALUE);
  				  			
				//FileWriteDouble(HstHandle, PrevHigh, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle, PrevClose, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);
				
				UpWick = 0;
				DnWick = EMPTY_VALUE;
				CurVolume = 0;
				CurHigh = PrevHigh;
				CurLow = PrevHigh;  
				
				if(PrevTime < Time[i]) PrevTime = Time[i];
				else PrevTime++;
			}
		
			i--;
		} 
		LastFPos = FileTell(HstHandle);   // Remember Last pos in file
		//
			
		Comment("RenkoRangeBars(" + CandleSize + "): Open Offline ", SymbolName, ",M", TimeFrame, " to view chart");
		
		if(Close[0] > MathMax(PrevClose, PrevOpen)) CurOpen = MathMax(PrevClose, PrevOpen);
		else if (Close[0] < MathMin(PrevClose, PrevOpen)) CurOpen = MathMin(PrevClose, PrevOpen);
		else CurOpen = Close[0];
		
		CurClose = Close[0];
				
		if(UpWick > PrevHigh) CurHigh = UpWick;
		if(DnWick < PrevLow) CurLow = DnWick;

            rates.time = PrevTime;
            rates.open = CurOpen;
            rates.low  = CurLow;
            rates.high = CurHigh;             
            rates.close = CurClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);
      
		//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle, CurOpen, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle, CurLow, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle, CurHigh, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle, CurClose, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);		// Volume				
		FileFlush(HstHandle);
            
		UpdateChartWindow();
		
		return(0);
 		// End historical data / Init		
	} 		
	//----------------------------------------------------------------------------
 	// HstHandle not < 0 so we always enter here after history done
	// Begin live data feed
   			
	UpWick = MathMax(UpWick, Bid);
	DnWick = MathMin(DnWick, Bid);

	CurVolume++;   			
	FileSeek(HstHandle, LastFPos, SEEK_SET);

 	//-------------------------------------------------------------------------	   				
 	// up box	   				
   	if(Bid > PrevClose+BoxPoints || CompareDoubles(Bid, PrevClose+BoxPoints)) {
      PrevHigh = PrevClose + BoxPoints;
  		PrevLow = PrevClose;
  		PrevOpen = PrevLow;
  		PrevClose = PrevClose + BoxPoints;
  		
            rates.time = PrevTime;
            rates.open = PrevOpen;
            rates.high = PrevHigh;
            if(ShowWicks && DnWick < PrevLow)
                  rates.low = DnWick;
            else  rates.low = PrevLow;             
            rates.close = PrevClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);
  				  			
		//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);
		//FileWriteDouble(HstHandle, PrevOpen, DOUBLE_VALUE);

		//if (ShowWicks && DnWick < PrevLow) FileWriteDouble(HstHandle, DnWick, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle, PrevLow, DOUBLE_VALUE);
		  			
		//FileWriteDouble(HstHandle, PrevHigh, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle, PrevClose, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);
      	FileFlush(HstHandle);
  	  	LastFPos = FileTell(HstHandle);   // Remeber Last pos in file				  							
      	
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
	else if(Bid < PrevClose-BoxPoints || CompareDoubles(Bid,PrevClose-BoxPoints)) {
  		//	PrevHigh = PrevOpen;
  		//	PrevLow = PrevOpen - BoxPoints;
  		//	PrevOpen = PrevLow;
  		//	PrevClose = PrevOpen - BoxPoints;
  			PrevHigh = PrevClose;
  			PrevLow = PrevClose - BoxPoints;
  			PrevOpen = PrevHigh;
  			PrevClose = PrevClose - BoxPoints;
  		
            rates.time = PrevTime;
            rates.open = PrevOpen;
            rates.low  = PrevLow;
            if(ShowWicks && UpWick > PrevHigh)
                  rates.high = UpWick;
            else  rates.high = PrevHigh;             
            rates.close = PrevClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);
  				  			
		//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);
		//FileWriteDouble(HstHandle, PrevOpen, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle, PrevLow, DOUBLE_VALUE);

		//if(ShowWicks && UpWick > PrevHigh) FileWriteDouble(HstHandle, UpWick, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle, PrevHigh, DOUBLE_VALUE);
				  			
		//FileWriteDouble(HstHandle, PrevClose, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);
      	FileFlush(HstHandle);
  	  	LastFPos = FileTell(HstHandle);   // Remeber Last pos in file				  							
      	
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
	else {
		if(Bid > CurHigh) CurHigh = Bid;
		if(Bid < CurLow) CurLow = Bid;
		
		if(PrevHigh <= Bid) CurOpen = PrevHigh;
		else if(PrevLow >= Bid) CurOpen = PrevLow;
		else CurOpen = Bid;
		
		CurClose = Bid;
		
            rates.time = PrevTime;
            rates.open = CurOpen;
            rates.low  = CurLow;
            rates.high = CurHigh;             
            rates.close = CurClose;
            rates.real_volume = (long)CurVolume;
            rates.tick_volume = (long)CurVolume;
   				FileWriteStruct(HstHandle,rates);
		
		//FileWriteInteger(HstHandle, PrevTime, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle, CurOpen, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle, CurLow, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle, CurHigh, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle, CurClose, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle, CurVolume, DOUBLE_VALUE);		// Volume				
            FileFlush(HstHandle);
            
		UpdateChartWindow();            
     	}
     	return(0);
}

//+------------------------------------------------------------------+
int deinit() {
	if(HstHandle >= 0) {
		FileClose(HstHandle);
		HstHandle = -1;
	}
   	Comment("");
	return(0);
}
//+------------------------------------------------------------------+
   