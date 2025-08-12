//+------------------------------------------------------------------+
//|                      !   MTH Renko Chart Builder Indi Ver 01.mq4 |
//|                                                        mth depok |
//|                                         do your homework mate... |
//+------------------------------------------------------------------+
#property copyright "mth depok"
#property link      "do your homework mate..."

#property indicator_chart_window
#include <WinUser32.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
#import "user32.dll"
	int RegisterWindowMessageW(string lpString); 
   int GetWindowTextW(int hWnd,string lpString,int nMaxCount);
   int PostMessageW(int hWnd,int Msg,int wParam,int lParam);
#import
//+------------------------------------------------------------------+
extern double  StartingPrice     = 0.0;

extern double  RenkoBoxSize1     = 7.5;
extern double  BoxShiftPercent1  = 100.00;
extern int     RenkoTimeFrame1   = 11;      // What time frame to use for the offline renko chart
extern int     RenkoBoxOffset1   = 0;
extern bool    ShowWicks1        = false;
extern int     MaxBars1          = 100000;

extern bool    Use2ndRenkoChart  = false;
extern double  RenkoBoxSize2     = 10.0;
extern double  BoxShiftPercent2  = 50;
extern int     RenkoTimeFrame2   = 3;      // What time frame to use for the offline renko chart
extern int     RenkoBoxOffset2   = 0;
extern bool    ShowWicks2        = false;
extern int     MaxBars2          = 10000;
extern bool    EmulateOnLineChart= true;
extern bool    StrangeSymbolName = false;
//+------------------------------------------------------------------+
int HstHandle1 = -1, LastFPos1 = 0, MT4InternalMsg1 = 0;
int HstHandle2 = -1, LastFPos2 = 0, MT4InternalMsg2 = 0;
string SymbolName;
//+------------------------------------------------------------------+
void UpdateChartWindow() {
	static int hwnd1 = 0;
	if(hwnd1 == 0) {
		hwnd1 = WindowHandle(SymbolName, RenkoTimeFrame1);
		if(hwnd1 != 0) Print("Chart window detected");
	}

	if(EmulateOnLineChart && MT4InternalMsg1 == 0) 
		MT4InternalMsg1 = RegisterWindowMessageW("MetaTrader4_Internal_Message");

	if(hwnd1 != 0) if(PostMessageW(hwnd1, WM_COMMAND, 0x822c, 0) == 0) hwnd1 = 0;
	if(hwnd1 != 0 && MT4InternalMsg1 != 0) PostMessageW(hwnd1, MT4InternalMsg1, 2, 1);

// drugi
	static int hwnd2 = 0;
	if(hwnd2 == 0) {
		hwnd2 = WindowHandle(SymbolName, RenkoTimeFrame2);
		if(hwnd2 != 0) Print("Chart window detected");
	}

	if(EmulateOnLineChart && MT4InternalMsg2 == 0) 
		MT4InternalMsg2 = RegisterWindowMessageW("MetaTrader4_Internal_Message");

	if(hwnd2 != 0) if(PostMessageW(hwnd2, WM_COMMAND, 0x822c, 0) == 0) hwnd2 = 0;
	if(hwnd2 != 0 && MT4InternalMsg2 != 0) PostMessageW(hwnd2, MT4InternalMsg2, 2, 1);
	return;
}
//+------------------------------------------------------------------+
int start() {
//PRVIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	static double BoxPoints1, UpWick1, DnWick1;
	static double PrevLow1, PrevHigh1, PrevOpen1, PrevClose1, CurVolume1, CurLow1, CurHigh1, CurOpen1, CurClose1;
	static datetime PrevTime1;
  		MqlRates rates;
   	
	//+------------------------------------------------------------------+
	// This is only executed ones, then the first tick arives.
	if(HstHandle1 < 0) {
		// Init
		if(!IsDllsAllowed()) {
			Print("Error: Dll calls must be allowed!");
			return(-1);
		}		
		if(MathAbs(RenkoBoxOffset1) >= RenkoBoxSize1) {
			Print("Error: |RenkoBoxOffset| should be less then RenkoBoxSize1!");
			return(-1);
		}
		//
		double BoxSize1 = RenkoBoxSize1;
		int BoxOffset1 = RenkoBoxOffset1;
		if(Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize1 = BoxSize1*10;
			BoxOffset1 = BoxOffset1*10;
		}
		if(Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize1 = BoxSize1*100;		
			BoxOffset1 = BoxOffset1*100;
		}
		
		if(StrangeSymbolName) SymbolName = StringSubstr(Symbol(), 0, 6);
		else SymbolName = Symbol();
		BoxPoints1 = NormalizeDouble(BoxSize1*Point, Digits);

		//Add starting price for Renko Chart 1

      if (Close[Bars-1]>= StartingPrice)
         {
		   PrevLow1 = NormalizeDouble(BoxOffset1*Point + MathFloor((Close[Bars-1]-StartingPrice)/BoxPoints1)*BoxPoints1 + StartingPrice, Digits);
		   }
		
      if (Close[Bars-1]< StartingPrice)
         {
		   PrevLow1 = NormalizeDouble(BoxOffset1*Point +  StartingPrice - MathCeil((StartingPrice-Close[Bars-1])/BoxPoints1)*BoxPoints1 - Point, Digits);
		   }
		
		DnWick1 = PrevLow1;
		PrevHigh1 = PrevLow1 + BoxPoints1;
		UpWick1 = PrevHigh1;
		PrevOpen1 = PrevLow1;
		PrevClose1 = PrevHigh1;
		CurVolume1 = 1;
		PrevTime1 = Time[Bars-1];
	
		// create / open hst file		
		HstHandle1 = FileOpenHistory(SymbolName + (string)RenkoTimeFrame1 + ".hst", FILE_BIN|FILE_WRITE|FILE_ANSI);
		FileClose(HstHandle1); HstHandle1 = -1;
		HstHandle1 = FileOpenHistory(SymbolName + (string)RenkoTimeFrame1 + ".hst", FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
		
		//HstHandle1 = FileOpenHistory(SymbolName + RenkoTimeFrame1 + ".hst", FILE_BIN|FILE_WRITE);
		if(HstHandle1< 0) {
			Print("Error: can\'t create / open history file: " + ErrorDescription(GetLastError()) + ": " + SymbolName + RenkoTimeFrame1 + ".hst");
			return(-1);
		}
		//
   	
		// write hst file header
		int HstUnused1[13];
		FileWriteInteger(HstHandle1, 401, LONG_VALUE); 			// Version
		FileWriteString(HstHandle1, "", 64);					// Copyright
		FileWriteString(HstHandle1, SymbolName, 12);			// Symbol
		FileWriteInteger(HstHandle1, RenkoTimeFrame1, LONG_VALUE);	// Period
		FileWriteInteger(HstHandle1, Digits, LONG_VALUE);		// Digits
		FileWriteInteger(HstHandle1, 0, LONG_VALUE);			// Time Sign
		FileWriteInteger(HstHandle1, 0, LONG_VALUE);			// Last Sync
		FileWriteArray(HstHandle1, HstUnused1, 0, 13);			// Unused
		//
   	
 		// process historical data
  		int i1 = Bars-2;
  			if (i1>MaxBars1) i1=MaxBars1; 
		//Print(Symbol() + " " + High[i] + " " + Low[i] + " " + Open[i] + " " + Close[i]);
		//---------------------------------------------------------------------------
  		while(i1 >= 0) {
  		
			CurVolume1 = CurVolume1 + Volume[i1];
		
			UpWick1 = MathMax(UpWick1, High[i1]);
			DnWick1 = MathMin(DnWick1, Low[i1]);

			// update low before high or the reverse depending on previous bar
			bool UpTrend1 = High[i1]+Low[i1] > High[i1+1]+Low[i1+1];
		
			while(!UpTrend1 && (Low[i1] < PrevLow1-(BoxShiftPercent1/100)*BoxPoints1 || CompareDoubles(Low[i1], PrevLow1-(BoxShiftPercent1/100)*BoxPoints1))) {
  				PrevHigh1   =  PrevHigh1   -  (BoxShiftPercent1/100)* BoxPoints1;
  				PrevLow1    =  PrevLow1    -  (BoxShiftPercent1/100)*BoxPoints1;
  				PrevOpen1   =  PrevHigh1;
  				PrevClose1  =  PrevLow1;

            rates.time = PrevTime1;
            rates.open = PrevOpen1;
            rates.low  = PrevLow1;
            if(ShowWicks1 && UpWick1 > PrevHigh1)
                  rates.high = UpWick1;
            else  rates.high = PrevHigh1;             
            rates.close = PrevClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);

				//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);
				//FileWriteDouble(HstHandle1, PrevOpen1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, PrevLow1, DOUBLE_VALUE);
	
				//if(ShowWicks1 && UpWick1 > PrevHigh1) FileWriteDouble(HstHandle1, UpWick1, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle1, PrevHigh1, DOUBLE_VALUE);
				  				  			
				//FileWriteDouble(HstHandle1, PrevClose1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);
				
				UpWick1 = 0;
				DnWick1 = EMPTY_VALUE;
				CurVolume1 = 0;
				CurHigh1 = PrevLow1;
				CurLow1 = PrevLow1;  
				
				if(PrevTime1 < Time[i1]) PrevTime1 = Time[i1];
				else PrevTime1++;
			}
		
			while(High[i1] > PrevHigh1+(BoxShiftPercent1/100)*BoxPoints1 || CompareDoubles(High[i1], PrevHigh1+(BoxShiftPercent1/100)*BoxPoints1)) {
  				PrevHigh1   =  PrevHigh1   +  (BoxShiftPercent1/100)*BoxPoints1;
  				PrevLow1    =  PrevLow1    +  (BoxShiftPercent1/100)*BoxPoints1;
  				PrevOpen1   =  PrevLow1;
  				PrevClose1  =  PrevHigh1;
  			
            rates.time = PrevTime1;
            rates.open = PrevOpen1;
            rates.high = PrevHigh1;
            if(ShowWicks1 && DnWick1 < PrevLow1)
                  rates.low = DnWick1;
            else  rates.low = PrevLow1;             
            rates.close = PrevClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);
  			
				//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);
				//FileWriteDouble(HstHandle1, PrevOpen1, DOUBLE_VALUE);

            //if(ShowWicks1 && DnWick1 < PrevLow1) FileWriteDouble(HstHandle1, DnWick1, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle1, PrevLow1, DOUBLE_VALUE);
  				  			
				//FileWriteDouble(HstHandle1, PrevHigh1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, PrevClose1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);
				
				UpWick1 = 0;
				DnWick1 = EMPTY_VALUE;
				CurVolume1 = 0;
				CurHigh1 = PrevHigh1;
				CurLow1 = PrevHigh1;  
				
				if(PrevTime1 < Time[i1]) PrevTime1 = Time[i1];
				else PrevTime1++;
			}
		
			while(UpTrend1 && (Low[i1] < PrevLow1-(BoxShiftPercent1/100)*BoxPoints1 || CompareDoubles(Low[i1], PrevLow1-(BoxShiftPercent1/100)*BoxPoints1))) {
  				PrevHigh1   =  PrevHigh1   -  (BoxShiftPercent1/100)*BoxPoints1;
  				PrevLow1    =  PrevLow1    -  (BoxShiftPercent1/100)*BoxPoints1;
  				PrevOpen1   =  PrevHigh1;
  				PrevClose1  =  PrevLow1;

            rates.time = PrevTime1;
            rates.open = PrevOpen1;
            rates.low  = PrevLow1;
            if(ShowWicks1 && UpWick1 > PrevHigh1)
                  rates.high = UpWick1;
            else  rates.high = PrevHigh1;             
            rates.close = PrevClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);
  			
				//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);
				//FileWriteDouble(HstHandle1, PrevOpen1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, PrevLow1, DOUBLE_VALUE);
				
				//if(ShowWicks1 && UpWick1 > PrevHigh1) FileWriteDouble(HstHandle1, UpWick1, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle1, PrevHigh1, DOUBLE_VALUE);
				
				//FileWriteDouble(HstHandle1, PrevClose1, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);

				UpWick1 = 0;
				DnWick1 = EMPTY_VALUE;
				CurVolume1 = 0;
				CurHigh1 = PrevLow1;
				CurLow1 = PrevLow1;  
								
				if(PrevTime1 < Time[i1]) PrevTime1 = Time[i1];
				else PrevTime1++;
			}		
			i1--;
		} 
		LastFPos1 = FileTell(HstHandle1);   // Remember Last pos in file
		//
			
	
		
		if(Close[0] > MathMax(PrevClose1, PrevOpen1)) CurOpen1 = MathMax(PrevClose1, PrevOpen1);
		else if (Close[0] < MathMin(PrevClose1, PrevOpen1)) CurOpen1 = MathMin(PrevClose1, PrevOpen1);
		else CurOpen1 = Close[0];
		
		CurClose1 = Close[0];
				
		if(UpWick1 > PrevHigh1) CurHigh1 = UpWick1;
		if(DnWick1 < PrevLow1) CurLow1 = DnWick1;
      
            rates.time = PrevTime1;
            rates.open = CurOpen1;
            rates.low  = CurLow1;
            rates.high = CurHigh1;             
            rates.close = CurClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);
      
		//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle1, CurOpen1, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle1, CurLow1, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle1, CurHigh1, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle1, CurClose1, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);		// Volume				
		FileFlush(HstHandle1);
            
		UpdateChartWindow();
		
		return(0);
 		// End historical data / Init		
	} 		
	//----------------------------------------------------------------------------
 	// HstHandle not < 0 so we always enter here after history done
	// Begin live data feed
   			
	UpWick1 = MathMax(UpWick1, Bid);
	DnWick1 = MathMin(DnWick1, Bid);

	CurVolume1++;   			
	FileSeek(HstHandle1, LastFPos1, SEEK_SET);

 	//-------------------------------------------------------------------------	   				
 	// up box	   				
   	if(Bid > PrevHigh1+(BoxShiftPercent1/100)*BoxPoints1 || CompareDoubles(Bid, PrevHigh1+(BoxShiftPercent1/100)*BoxPoints1)) {
		PrevHigh1    =  PrevHigh1   +  (BoxShiftPercent1/100)*BoxPoints1;
		PrevLow1     =  PrevLow1    +  (BoxShiftPercent1/100)*BoxPoints1;
		PrevOpen1    =  PrevLow1;
		PrevClose1   =  PrevHigh1;

            rates.time = PrevTime1;
            rates.open = PrevOpen1;
            rates.high = PrevHigh1;
            if(ShowWicks1 && DnWick1 < PrevLow1)
                  rates.low = DnWick1;
            else  rates.low = PrevLow1;             
            rates.close = PrevClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);
  				  			
		//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);
		//FileWriteDouble(HstHandle1, PrevOpen1, DOUBLE_VALUE);

		//if (ShowWicks1 && DnWick1 < PrevLow1) FileWriteDouble(HstHandle1, DnWick1, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle1, PrevLow1, DOUBLE_VALUE);
		  			
		//FileWriteDouble(HstHandle1, PrevHigh1, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle1, PrevClose1, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);
      	FileFlush(HstHandle1);
  	  	LastFPos1 = FileTell(HstHandle1);   // Remember Last pos in file				  							
      	
		if(PrevTime1 < TimeCurrent()) PrevTime1 = TimeCurrent();
		else PrevTime1++;
            		
  		CurVolume1 = 0;
		CurHigh1 = PrevHigh1;
		CurLow1 = PrevHigh1;  
		
		UpWick1 = 0;
		DnWick1 = EMPTY_VALUE;		
		
		UpdateChartWindow();				            		
  	}
 	//-------------------------------------------------------------------------	   				
 	// down box
	else if(Bid < PrevLow1-(BoxShiftPercent1/100)*BoxPoints1 || CompareDoubles(Bid,PrevLow1-(BoxShiftPercent1/100)*BoxPoints1)) {
  		PrevHigh1  =  PrevHigh1   -  (BoxShiftPercent1/100)*BoxPoints1;
  		PrevLow1   =  PrevLow1    -  (BoxShiftPercent1/100)*BoxPoints1;
  		PrevOpen1  =  PrevHigh1;
  		PrevClose1 =  PrevLow1;

            rates.time = PrevTime1;
            rates.open = PrevOpen1;
            rates.low  = PrevLow1;
            if(ShowWicks1 && UpWick1> PrevHigh1)
                  rates.high = UpWick1;
            else  rates.high = PrevHigh1;             
            rates.close = PrevClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);

  				  			
		//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);
		//FileWriteDouble(HstHandle1, PrevOpen1, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle1, PrevLow1, DOUBLE_VALUE);

		//if(ShowWicks1 && UpWick1 > PrevHigh1) FileWriteDouble(HstHandle1, UpWick1, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle1, PrevHigh1, DOUBLE_VALUE);
				  			
		//FileWriteDouble(HstHandle1, PrevClose1, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);
      	FileFlush(HstHandle1);
  	  	LastFPos1 = FileTell(HstHandle1);   // Remember Last pos in file				  							
      	
		if(PrevTime1 < TimeCurrent()) PrevTime1 = TimeCurrent();
		else PrevTime1++;      	
            		
  		CurVolume1 = 0;
		CurHigh1 = PrevLow1;
		CurLow1 = PrevLow1;  
		
		UpWick1 = 0;
		DnWick1 = EMPTY_VALUE;		
		
		UpdateChartWindow();						
     	} 
 	//-------------------------------------------------------------------------	   				
   	// no box - high/low not hit				
	else {
		if(Bid > CurHigh1) CurHigh1 = Bid;
		if(Bid < CurLow1) CurLow1 = Bid;
	
      CurOpen1 = PrevClose1;
		CurClose1 = Bid;
		
            rates.time = PrevTime1;
            rates.open = CurOpen1;
            rates.low  = CurLow1;
            rates.high = CurHigh1;             
            rates.close = CurClose1;
            rates.real_volume = (long)CurVolume1;
            rates.tick_volume = (long)CurVolume1;
   				FileWriteStruct(HstHandle1,rates);
		
		//FileWriteInteger(HstHandle1, PrevTime1, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle1, CurOpen1, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle1, CurLow1, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle1, CurHigh1, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle1, CurClose1, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle1, CurVolume1, DOUBLE_VALUE);		// Volume				
            FileFlush(HstHandle1);
            
		UpdateChartWindow();            
     	}
if (!Use2ndRenkoChart)
   {Comment("MTH Renko Chart Builder Indi Ver 01 (" +DoubleToStr(RenkoBoxSize1,1)+ ") point: Open Offline ", SymbolName, ",M", RenkoTimeFrame1, " to view chart");}
if (Use2ndRenkoChart)
   {
 //DRUGI-----------------------------------------------------------------------------------------
	static double BoxPoints2, UpWick2, DnWick2;
	static double PrevLow2, PrevHigh2, PrevOpen2, PrevClose2, CurVolume2, CurLow2, CurHigh2, CurOpen2, CurClose2;
	static datetime PrevTime2;
   	
	//+------------------------------------------------------------------+
	// This is only executed ones, then the first tick arives.
	if(HstHandle2 < 0) {
		// Init

		// Error checking	
			
		if(!IsDllsAllowed()) {
			Print("Error: Dll calls must be allowed!");
			return(-1);
		}		
		if(MathAbs(RenkoBoxOffset2) >= RenkoBoxSize2) {
			Print("Error: |RenkoBoxOffset| should be less then RenkoBoxSize2!");
			return(-1);
		}

		//
		
		double BoxSize2 = RenkoBoxSize2;
		int BoxOffset2 = RenkoBoxOffset2;
		if(Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize2 = BoxSize2*10;
			BoxOffset2 = BoxOffset2*10;
		}
		if(Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) {
			BoxSize2 = BoxSize2*100;		
			BoxOffset2 = BoxOffset2*100;
		}
		
		if(StrangeSymbolName) SymbolName = StringSubstr(Symbol(), 0, 6);
		else SymbolName = Symbol();
		
		BoxPoints2 = NormalizeDouble(BoxSize2*Point, Digits);
		
		// Add Starting Price for renko chart 2
		
		if (Close[Bars-1]>= StartingPrice)
         {
		   PrevLow2 = NormalizeDouble(BoxOffset2*Point + MathFloor((Close[Bars-1]-StartingPrice)/BoxPoints2)*BoxPoints2 + StartingPrice, Digits);
		   }
		
      if (Close[Bars-1]< StartingPrice)
         {
		   PrevLow2 = NormalizeDouble(BoxOffset2*Point +  StartingPrice - MathCeil((StartingPrice-Close[Bars-1])/BoxPoints2)*BoxPoints2 - Point, Digits);
		   }
		
		
		DnWick2 = PrevLow2;
		PrevHigh2 = PrevLow2 + BoxPoints2;
		UpWick2 = PrevHigh2;
		PrevOpen2 = PrevLow2;
		PrevClose2 = PrevHigh2;
		CurVolume2 = 1;
		PrevTime2 = Time[Bars-1];
	
		// create / open hst file		
		HstHandle2 = FileOpenHistory(SymbolName + (string)RenkoTimeFrame2 + ".hst", FILE_BIN|FILE_WRITE|FILE_ANSI);
		FileClose(HstHandle2); HstHandle2 = -1;
		HstHandle2 = FileOpenHistory(SymbolName + (string)RenkoTimeFrame2 + ".hst", FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
		//HstHandle2 = FileOpenHistory(SymbolName + RenkoTimeFrame2 + ".hst", FILE_BIN|FILE_WRITE);
		if(HstHandle2< 0) {
			Print("Error: can\'t create / open history file: " + ErrorDescription(GetLastError()) + ": " + SymbolName + RenkoTimeFrame2 + ".hst");
			return(-1);
		}
		//
   	
		// write hst file header
		int HstUnused2[13];
		FileWriteInteger(HstHandle2, 401, LONG_VALUE); 			// Version
		FileWriteString(HstHandle2, "", 64);					// Copyright
		FileWriteString(HstHandle2, SymbolName, 12);			// Symbol
		FileWriteInteger(HstHandle2, RenkoTimeFrame2, LONG_VALUE);	// Period
		FileWriteInteger(HstHandle2, Digits, LONG_VALUE);		// Digits
		FileWriteInteger(HstHandle2, 0, LONG_VALUE);			// Time Sign
		FileWriteInteger(HstHandle2, 0, LONG_VALUE);			// Last Sync
		FileWriteArray(HstHandle2, HstUnused2, 0, 13);			// Unused
		//
   	
 		// process historical data
  		int i2 = Bars-2;
  			if (i2>MaxBars2) i2=MaxBars2;  
		//Print(Symbol() + " " + High[i] + " " + Low[i] + " " + Open[i] + " " + Close[i]);
		//---------------------------------------------------------------------------
  		while(i2 >= 0) {
  		
			CurVolume2 = CurVolume2 + Volume[i2];
		
			UpWick2 = MathMax(UpWick2, High[i2]);
			DnWick2 = MathMin(DnWick2, Low[i2]);

			// update low before high or the reverse depending on previous bar
			bool UpTrend2 = High[i2]+Low[i2] > High[i2+1]+Low[i2+1];
		
			while(!UpTrend2 && (Low[i2] < PrevLow2-(BoxShiftPercent2/100)*BoxPoints2 || CompareDoubles(Low[i2], PrevLow2-(BoxShiftPercent2/100)*BoxPoints2))) {
  				PrevHigh2   =  PrevHigh2   -  (BoxShiftPercent2/100)*BoxPoints2;
  				PrevLow2    =  PrevLow2    -  (BoxShiftPercent2/100)*BoxPoints2;
  				PrevOpen2   =  PrevHigh2;
  				PrevClose2  =  PrevLow2;

            rates.time = PrevTime2;
            rates.open = PrevOpen2;
            rates.low  = PrevLow2;
            if(ShowWicks2 && UpWick2 > PrevHigh2)
                  rates.high = UpWick2;
            else  rates.high = PrevHigh2;             
            rates.close = PrevClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);


				//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);
				//FileWriteDouble(HstHandle2, PrevOpen2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, PrevLow2, DOUBLE_VALUE);

				//if(ShowWicks2 && UpWick2 > PrevHigh2) FileWriteDouble(HstHandle2, UpWick2, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle2, PrevHigh2, DOUBLE_VALUE);
				  				  			
				//FileWriteDouble(HstHandle2, PrevClose2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);
				
				UpWick2 = 0;
				DnWick2 = EMPTY_VALUE;
				CurVolume2 = 0;
				CurHigh2 = PrevLow2;
				CurLow2 = PrevLow2;  
				
				if(PrevTime2 < Time[i2]) PrevTime2 = Time[i2];
				else PrevTime2++;
			}
		
			while(High[i2] > PrevHigh2+(BoxShiftPercent2/100)*BoxPoints2 || CompareDoubles(High[i2], PrevHigh2+(BoxShiftPercent2/100)*BoxPoints2)) {
  				PrevHigh2   =  PrevHigh2   +  (BoxShiftPercent2/100)*BoxPoints2;
  				PrevLow2    =  PrevLow2    +  (BoxShiftPercent2/100)*BoxPoints2;
  				PrevOpen2   =  PrevLow2;
  				PrevClose2  =  PrevHigh2;

            rates.time = PrevTime2;
            rates.open = PrevOpen2;
            rates.high = PrevHigh2;
            if(ShowWicks2 && DnWick2 < PrevLow2)
                  rates.low = DnWick2;
            else  rates.low = PrevLow2;             
            rates.close = PrevClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);
  			
				//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);
				//FileWriteDouble(HstHandle2, PrevOpen2, DOUBLE_VALUE);

            //if(ShowWicks2 && DnWick2 < PrevLow2) FileWriteDouble(HstHandle2, DnWick2, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle2, PrevLow2, DOUBLE_VALUE);
  				  			
				//FileWriteDouble(HstHandle2, PrevHigh2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, PrevClose2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);
				
				UpWick2 = 0;
				DnWick2 = EMPTY_VALUE;
				CurVolume2 = 0;
				CurHigh2 = PrevHigh2;
				CurLow2 = PrevHigh2;  
				
				if(PrevTime2 < Time[i2]) PrevTime2 = Time[i2];
				else PrevTime2++;
			}
		
			while(UpTrend2 && (Low[i2] < PrevLow2-(BoxShiftPercent2/100)*BoxPoints2 || CompareDoubles(Low[i2], PrevLow2-(BoxShiftPercent2/100)*BoxPoints2))) {
  				PrevHigh2   =  PrevHigh2   -  (BoxShiftPercent2/100)* BoxPoints2;
  				PrevLow2    =  PrevLow2    -  (BoxShiftPercent2/100)* BoxPoints2;
  				PrevOpen2   =  PrevHigh2;
  				PrevClose2  =  PrevLow2;
  			
            rates.time = PrevTime2;
            rates.open = PrevOpen2;
            rates.low  = PrevLow2;
            if(ShowWicks2 && UpWick2 > PrevHigh2)
                  rates.high = UpWick2;
            else  rates.high = PrevHigh2;             
            rates.close = PrevClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);

  			
				//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);
				//FileWriteDouble(HstHandle2, PrevOpen2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, PrevLow2, DOUBLE_VALUE);
				
				//if(ShowWicks2 && UpWick2 > PrevHigh2) FileWriteDouble(HstHandle2, UpWick2, DOUBLE_VALUE);
				//else FileWriteDouble(HstHandle2, PrevHigh2, DOUBLE_VALUE);
				
				//FileWriteDouble(HstHandle2, PrevClose2, DOUBLE_VALUE);
				//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);

				UpWick2 = 0;
				DnWick2 = EMPTY_VALUE;
				CurVolume2 = 0;
				CurHigh2 = PrevLow2;
				CurLow2 = PrevLow2;  
								
				if(PrevTime2 < Time[i2]) PrevTime2 = Time[i2];
				else PrevTime2++;
			}		
			i2--;
		} 
		LastFPos2 = FileTell(HstHandle2);   // Remember Last pos in file
		//Comment("BUY:",TG_SIGNAL_BUY,"\n","SELL:",TG_SIGNAL_SELL);  	
		Comment("MTH Renko Chart Builder Indi Ver 01 (" + DoubleToStr(RenkoBoxSize1,1) + ") point: Open Offline ", SymbolName, ",M", RenkoTimeFrame1, " to view chart","\n",
		        "MTH Renko Chart Builder Indi Ver 01 (" + DoubleToStr(RenkoBoxSize2,1) + ") point: Open Offline ", SymbolName, ",M", RenkoTimeFrame2, " to view chart");
		
		if(Close[0] > MathMax(PrevClose2, PrevOpen2)) CurOpen2 = MathMax(PrevClose2, PrevOpen2);
		else if (Close[0] < MathMin(PrevClose2, PrevOpen2)) CurOpen2 = MathMin(PrevClose2, PrevOpen2);
		else CurOpen2 = Close[0];
		
		CurClose2 = Close[0];
				
		if(UpWick2 > PrevHigh2) CurHigh2 = UpWick2;
		if(DnWick2 < PrevLow2) CurLow2 = DnWick2;

            rates.time = PrevTime2;
            rates.open = CurOpen2;
            rates.low  = CurLow2;
            rates.high = CurHigh2;             
            rates.close = CurClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);
      
		//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle2, CurOpen2, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle2, CurLow2, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle2, CurHigh2, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle2, CurClose2, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);		// Volume				
		FileFlush(HstHandle2);
            
		UpdateChartWindow();
		
		return(0);
 		// End historical data / Init		
	} 		
	//----------------------------------------------------------------------------
 	// HstHandle not < 0 so we always enter here after history done
	// Begin live data feed
   			
	UpWick2 = MathMax(UpWick2, Bid);
	DnWick2 = MathMin(DnWick2, Bid);

	CurVolume2++;   			
	FileSeek(HstHandle2, LastFPos2, SEEK_SET);

 	//-------------------------------------------------------------------------	   				
 	// up box	   				
   	if(Bid > PrevHigh2+(BoxShiftPercent2/100)*BoxPoints2 || CompareDoubles(Bid, PrevHigh2+(BoxShiftPercent2/100)*BoxPoints2)) {
		PrevHigh2    =  PrevHigh2   +  (BoxShiftPercent2/100)* BoxPoints2;
		PrevLow2     =  PrevLow2    +  (BoxShiftPercent2/100)* BoxPoints2;
		PrevOpen2    =  PrevLow2;
		PrevClose2   =  PrevHigh2;
  				
            rates.time = PrevTime2;
            rates.open = PrevOpen2;
            rates.high = PrevHigh2;
            if(ShowWicks2 && DnWick2 < PrevLow2)
                  rates.low = DnWick2;
            else  rates.low = PrevLow2;             
            rates.close = PrevClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);
  				  			
		//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);
		//FileWriteDouble(HstHandle2, PrevOpen2, DOUBLE_VALUE);

		//if (ShowWicks2 && DnWick2 < PrevLow2) FileWriteDouble(HstHandle2, DnWick2, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle2, PrevLow2, DOUBLE_VALUE);
		  			
		//FileWriteDouble(HstHandle2, PrevHigh2, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle2, PrevClose2, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);
      	FileFlush(HstHandle2);
  	  	LastFPos2 = FileTell(HstHandle2);   // Remeber Last pos in file				  							
      	
		if(PrevTime2 < TimeCurrent()) PrevTime2 = TimeCurrent();
		else PrevTime2++;
            		
  		CurVolume2 = 0;
		CurHigh2 = PrevHigh2;
		CurLow2 = PrevHigh2;  
		
		UpWick2 = 0;
		DnWick2 = EMPTY_VALUE;		
		
		UpdateChartWindow();				            		
  	}
 	//-------------------------------------------------------------------------	   				
 	// down box
	else if(Bid < PrevLow2-(BoxShiftPercent2/100)*BoxPoints2 || CompareDoubles(Bid,PrevLow2-(BoxShiftPercent2/100)*BoxPoints2)) {
  		PrevHigh2  =  PrevHigh2   -  (BoxShiftPercent2/100)* BoxPoints2;
  		PrevLow2   =  PrevLow2    -  (BoxShiftPercent2/100)* BoxPoints2;
  		PrevOpen2  =  PrevHigh2;
  		PrevClose2 =  PrevLow2;
  				  			
            rates.time = PrevTime2;
            rates.open = PrevOpen2;
            rates.low  = PrevLow2;
            if(ShowWicks2 && UpWick2 > PrevHigh2)
                  rates.high = UpWick2;
            else  rates.high = PrevHigh2;             
            rates.close = PrevClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);
  				  			
		//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);
		//FileWriteDouble(HstHandle2, PrevOpen2, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle2, PrevLow2, DOUBLE_VALUE);

		//if(ShowWicks2 && UpWick2 > PrevHigh2) FileWriteDouble(HstHandle2, UpWick2, DOUBLE_VALUE);
		//else FileWriteDouble(HstHandle2, PrevHigh2, DOUBLE_VALUE);
				  			
		//FileWriteDouble(HstHandle2, PrevClose2, DOUBLE_VALUE);
		//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);
      	FileFlush(HstHandle2);
  	  	LastFPos2 = FileTell(HstHandle2);   // Remember Last pos in file				  							
      	
		if(PrevTime2 < TimeCurrent()) PrevTime2 = TimeCurrent();
		else PrevTime2++;      	
            		
  		CurVolume2 = 0;
		CurHigh2 = PrevLow2;
		CurLow2 = PrevLow2;  
		
		UpWick2 = 0;
		DnWick2 = EMPTY_VALUE;		
		
		UpdateChartWindow();						
     	} 
 	//-------------------------------------------------------------------------	   				
   	// no box - high/low not hit				
	else {
		if(Bid > CurHigh2) CurHigh2 = Bid;
		if(Bid < CurLow2) CurLow2 = Bid;
	
      CurOpen2 = PrevClose2;
		CurClose2 = Bid;

            rates.time = PrevTime2;
            rates.open = CurOpen2;
            rates.low  = CurLow2;
            rates.high = CurHigh2;             
            rates.close = CurClose2;
            rates.real_volume = (long)CurVolume2;
            rates.tick_volume = (long)CurVolume2;
   				FileWriteStruct(HstHandle2,rates);
		
		//FileWriteInteger(HstHandle2, PrevTime2, LONG_VALUE);		// Time
		//FileWriteDouble(HstHandle2, CurOpen2, DOUBLE_VALUE);         	// Open
		//FileWriteDouble(HstHandle2, CurLow2, DOUBLE_VALUE);		// Low
		//FileWriteDouble(HstHandle2, CurHigh2, DOUBLE_VALUE);		// High
		//FileWriteDouble(HstHandle2, CurClose2, DOUBLE_VALUE);		// Close
		//FileWriteDouble(HstHandle2, CurVolume2, DOUBLE_VALUE);		// Volume				
            FileFlush(HstHandle2);
            
		UpdateChartWindow();            
     	}

		Comment("MTH Renko Chart Builder Indi Ver 01 (" + DoubleToStr(RenkoBoxSize1,1) + ") point: Open Offline ", SymbolName, ",M", RenkoTimeFrame1, " to view chart","\n",
		        "MTH Renko Chart Builder Indi Ver 01 (" + DoubleToStr(RenkoBoxSize2,1) + ") point: Open Offline ", SymbolName, ",M", RenkoTimeFrame2, " to view chart");
   } // end if(Use2ndRenkoChart)
   
     	return(0);
}
//+------------------------------------------------------------------+
int deinit() {
	if(HstHandle1 >= 0) {
		FileClose(HstHandle1);
		HstHandle1 = -1;
	}
	if(HstHandle2 >= 0) {
		FileClose(HstHandle2);
		HstHandle2 = -1;
	}	
	
	
   	Comment("");
	return(0);
}
//+------------------------------------------------------------------+
   