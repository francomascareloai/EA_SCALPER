//+------------------------------------------------------------------+
//|                                                           CC.mq4 |
//| original made by Semen Semenich                                  |
//| this version made by mladen                                      |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 8

//
//
//
//
//
//

extern string TimeFrame = "Current time frame";
extern int    MaMethod  = 3;
extern int    MaFast    = 0;
extern int    MaSlow    = 0;
extern int    Price     = 6;
extern bool   USD       = true;
extern bool   EUR       = true;
extern bool   GBP       = true;
extern bool   CHF       = true;
extern bool   JPY       = true;
extern bool   AUD       = true;
extern bool   CAD       = true;
extern bool   NZD       = true;
extern color  Color_USD = Black;
extern color  Color_EUR = Red;
extern color  Color_GBP = FireBrick;
extern color  Color_CHF = GreenYellow;
extern color  Color_JPY = Gold;
extern color  Color_AUD = Blue;
extern color  Color_CAD = Aqua;
extern color  Color_NZD = Teal;
extern int    Line_Thickness = 1;

extern int mn_per   = 12;
extern int mn_fast  = 3;
extern int w_per    = 9;
extern int w_fast   = 3;
extern int d_per    = 5;
extern int d_fast   = 3;
extern int h4_per   = 18;
extern int h4_fast  = 6;
extern int h1_per   = 24;
extern int h1_fast  = 8;
extern int m30_per  = 16;
extern int m30_fast = 2;
extern int m15_per  = 16;
extern int m15_fast = 4;
extern int m5_per   = 12;
extern int m5_fast  = 3;
extern int m1_per   = 30;
extern int m1_fast  = 10;

extern bool Interpolate=true;

//
//
//
//
//

double arrUSD[];
double arrEUR[];
double arrGBP[];
double arrCHF[];
double arrJPY[];
double arrAUD[];
double arrCAD[];
double arrNZD[];

string Indicator_Name = "CC: ";
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame = 0;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
   SetIndexBuffer(0, arrUSD);
   SetIndexBuffer(1, arrEUR);
   SetIndexBuffer(2, arrGBP);
   SetIndexBuffer(3, arrCHF);
   SetIndexBuffer(4, arrJPY);
   SetIndexBuffer(5, arrAUD);
   SetIndexBuffer(6, arrCAD);
   SetIndexBuffer(7, arrNZD);

      //
      //
      //
      //
      //
         
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

         switch(timeFrame)
         {
            case PERIOD_M1:  MaSlow = m1_per;  MaFast = m1_fast;  break;
            case PERIOD_M5:  MaSlow = m5_per;  MaFast = m5_fast;  break;
            case PERIOD_M15: MaSlow = m15_per; MaFast = m15_fast; break;
            case PERIOD_M30: MaSlow = m30_per; MaFast = m30_fast; break;
            case PERIOD_H1:  MaSlow = h1_per;  MaFast = h1_fast;  break;
            case PERIOD_H4:  MaSlow = h4_per;  MaFast = h4_fast;  break;
            case PERIOD_D1:  MaSlow = d_per;   MaFast = d_fast;   break;
            case PERIOD_W1:  MaSlow = w_per;   MaFast = w_fast;   break;
            case PERIOD_MN1: MaSlow = mn_per;  MaFast = mn_fast;  break;
         }
   
      //
      //
      //
      //
      //

      if(USD) Indicator_Name = StringConcatenate(Indicator_Name, " USD");
      if(EUR) Indicator_Name = StringConcatenate(Indicator_Name, " EUR");
      if(GBP) Indicator_Name = StringConcatenate(Indicator_Name, " GBP");
      if(CHF) Indicator_Name = StringConcatenate(Indicator_Name, " CHF");
      if(JPY) Indicator_Name = StringConcatenate(Indicator_Name, " JPY");
      if(AUD) Indicator_Name = StringConcatenate(Indicator_Name, " AUD");
      if(CAD) Indicator_Name = StringConcatenate(Indicator_Name, " CAD");
      if(NZD) Indicator_Name = StringConcatenate(Indicator_Name, " NZD");
      IndicatorShortName(Indicator_Name);

      int cur = 0; 
      int st = 23; 
         if (USD) { sl(0,"~",cur,Color_USD,"USD"); cur+=st;  }
         if (EUR) { sl(1,"~",cur,Color_EUR,"EUR"); cur+=st; addSymbol("EURUSD"); }
         if (GBP) { sl(2,"~",cur,Color_GBP,"GBP"); cur+=st; addSymbol("GBPUSD"); }
         if (CHF) { sl(3,"~",cur,Color_CHF,"CHF"); cur+=st; addSymbol("USDCHF"); }
         if (JPY) { sl(4,"~",cur,Color_JPY,"JPY"); cur+=st; addSymbol("USDJPY"); }
         if (AUD) { sl(5,"~",cur,Color_AUD,"AUD"); cur+=st; addSymbol("AUDUSD"); }
         if (CAD) { sl(6,"~",cur,Color_CAD,"CAD"); cur+=st; addSymbol("CADUSD"); }
         if (NZD) { sl(7,"~",cur,Color_NZD,"NZD"); cur+=st; addSymbol("NZDUSD"); }
   return(0);
}
  
//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

string symbols[];
void addSymbol(string symbol)
{
   ArrayResize(symbols,ArraySize(symbols)+1); symbols[ArraySize(symbols)-1] = symbol;
}

//
//
//
//
//

int getLimit(int limit, string symbol)
{
   if (symbol!=Symbol())
          limit = MathMax(MathMin(Bars-1,iCustom(symbol,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()),limit);
   return(limit);
}

//
//
//
//
//
  
int deinit()
{
   for(int i = 0; i < 8; i++) ObjectDelete(Indicator_Name + i);
   return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------

int start()
{
   int limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { arrUSD[0] = limit; return(0); }
           for (int t=0; t<ArraySize(symbols); t++) limit = getLimit(limit,symbols[t]);

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())   
   {
      for(int i = 0; i < limit; i++)
      {
         if(EUR) {
              double EURUSD_Fast = ma("EURUSD", MaFast, MaMethod, Price, i);
              double EURUSD_Slow = ma("EURUSD", MaSlow, MaMethod, Price, i);
                 if (!EURUSD_Fast || !EURUSD_Slow) break; }
         if(GBP) {
              double GBPUSD_Fast = ma("GBPUSD", MaFast, MaMethod, Price, i);
              double GBPUSD_Slow = ma("GBPUSD", MaSlow, MaMethod, Price, i);
                 if(!GBPUSD_Fast || !GBPUSD_Slow) break;  }
         if(AUD) {
              double AUDUSD_Fast = ma("AUDUSD", MaFast, MaMethod, Price, i);
              double AUDUSD_Slow = ma("AUDUSD", MaSlow, MaMethod, Price, i);
                 if(!AUDUSD_Fast || !AUDUSD_Slow) break;  }
         if(NZD) {
              double NZDUSD_Fast = ma("NZDUSD", MaFast, MaMethod, Price, i);
              double NZDUSD_Slow = ma("NZDUSD", MaSlow, MaMethod, Price, i);
                 if(!NZDUSD_Fast || !NZDUSD_Slow)  break; }
         if(CAD) {
              double USDCAD_Fast = ma("USDCAD", MaFast, MaMethod, Price, i);
              double USDCAD_Slow = ma("USDCAD", MaSlow, MaMethod, Price, i);
                 if(!USDCAD_Fast || !USDCAD_Slow) break; }
         if(CHF) {
              double USDCHF_Fast = ma("USDCHF", MaFast, MaMethod, Price, i);
              double USDCHF_Slow = ma("USDCHF", MaSlow, MaMethod, Price, i);
                 if(!USDCHF_Fast || !USDCHF_Slow) break; }
         if(JPY) {
              double USDJPY_Fast = ma("USDJPY", MaFast, MaMethod, Price, i) / 100.0;
              double USDJPY_Slow = ma("USDJPY", MaSlow, MaMethod, Price, i) / 100.0;
                 if(!USDJPY_Fast || !USDJPY_Slow) break; }
         
         //
         //
         //
         //
         //
               
         if(USD)
         {
            arrUSD[i] = 0;
              if(EUR) arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
              if(GBP) arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
              if(AUD) arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
              if(NZD) arrUSD[i] += NZDUSD_Slow - NZDUSD_Fast;
              if(CHF) arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
              if(CAD) arrUSD[i] += USDCAD_Fast - USDCAD_Slow;
              if(JPY) arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
         }
         if(EUR)
         {
            arrEUR[i] = 0;
              if(USD) arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
              if(GBP) arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
              if(AUD) arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
              if(NZD) arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / NZDUSD_Slow;
              if(CHF) arrEUR[i] += EURUSD_Fast * USDCHF_Fast - EURUSD_Slow * USDCHF_Slow;
              if(CAD) arrEUR[i] += EURUSD_Fast * USDCAD_Fast - EURUSD_Slow * USDCAD_Slow;
              if(JPY) arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
         }
         if(GBP)
         {
              arrGBP[i] = 0;
              if(USD) arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
              if(EUR) arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
              if(AUD) arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
              if(NZD) arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / NZDUSD_Slow;
              if(CHF) arrGBP[i] += GBPUSD_Fast * USDCHF_Fast - GBPUSD_Slow * USDCHF_Slow;
              if(CAD) arrGBP[i] += GBPUSD_Fast * USDCAD_Fast - GBPUSD_Slow * USDCAD_Slow;
              if(JPY) arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
         }
         if(AUD)
         {
              arrAUD[i] = 0;
              if(USD) arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
              if(EUR) arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
              if(GBP) arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
              if(NZD) arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / NZDUSD_Slow;
              if(CHF) arrAUD[i] += AUDUSD_Fast * USDCHF_Fast - AUDUSD_Slow * USDCHF_Slow;
              if(CAD) arrAUD[i] += AUDUSD_Fast * USDCAD_Fast - AUDUSD_Slow * USDCAD_Slow;
              if(JPY) arrAUD[i] += AUDUSD_Fast * USDJPY_Fast - AUDUSD_Slow * USDJPY_Slow;
         }
         if(NZD)
         {
              arrNZD[i] = 0;
              if(USD) arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
              if(EUR) arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / NZDUSD_Fast;
              if(GBP) arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / NZDUSD_Fast;
              if(AUD) arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / NZDUSD_Fast;
              if(CHF) arrNZD[i] += NZDUSD_Fast * USDCHF_Fast - NZDUSD_Slow * USDCHF_Slow;
              if(CAD) arrNZD[i] += NZDUSD_Fast * USDCAD_Fast - NZDUSD_Slow * USDCAD_Slow;
              if(JPY) arrNZD[i] += NZDUSD_Fast * USDJPY_Fast - NZDUSD_Slow * USDJPY_Slow;
         }
         if(CAD)
         {
              arrCAD[i] = 0;
              if(USD) arrCAD[i] += USDCAD_Slow - USDCAD_Fast;
              if(EUR) arrCAD[i] += EURUSD_Slow * USDCAD_Slow - EURUSD_Fast * USDCAD_Fast;
              if(GBP) arrCAD[i] += GBPUSD_Slow * USDCAD_Slow - GBPUSD_Fast * USDCAD_Fast;
              if(AUD) arrCAD[i] += AUDUSD_Slow * USDCAD_Slow - AUDUSD_Fast * USDCAD_Fast;
              if(NZD) arrCAD[i] += NZDUSD_Slow * USDCAD_Slow - NZDUSD_Fast * USDCAD_Fast;
              if(CHF) arrCAD[i] += USDCHF_Fast / USDCAD_Fast - USDCHF_Slow / USDCAD_Slow;
              if(JPY) arrCAD[i] += USDJPY_Fast / USDCAD_Fast - USDJPY_Slow / USDCAD_Slow;
         }
         if(CHF)
         {
              arrCHF[i] = 0;
              if(USD) arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
              if(EUR) arrCHF[i] += EURUSD_Slow * USDCHF_Slow - EURUSD_Fast * USDCHF_Fast;
              if(GBP) arrCHF[i] += GBPUSD_Slow * USDCHF_Slow - GBPUSD_Fast * USDCHF_Fast;
              if(AUD) arrCHF[i] += AUDUSD_Slow * USDCHF_Slow - AUDUSD_Fast * USDCHF_Fast;
              if(NZD) arrCHF[i] += NZDUSD_Slow * USDCHF_Slow - NZDUSD_Fast * USDCHF_Fast;
              if(CAD) arrCHF[i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
              if(JPY) arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
         }
         if(JPY)
         {
              arrJPY[i] = 0;
              if(USD) arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
              if(EUR) arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
              if(GBP) arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
              if(AUD) arrJPY[i] += AUDUSD_Slow * USDJPY_Slow - AUDUSD_Fast * USDJPY_Fast;
              if(NZD) arrJPY[i] += NZDUSD_Slow * USDJPY_Slow - NZDUSD_Fast * USDJPY_Fast;
              if(CAD) arrJPY[i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
              if(CHF) arrJPY[i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
         }
      }
      return(0);
   }      
   
   //
   //
   //
   //
   //

   for(i = limit; i >=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         if (USD) arrUSD[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,0,y);
         if (EUR) arrEUR[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,1,y);
         if (GBP) arrGBP[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,2,y);
         if (CHF) arrCHF[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,3,y);
         if (JPY) arrJPY[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,4,y);
         if (AUD) arrAUD[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,5,y);
         if (CAD) arrCAD[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,6,y);
         if (NZD) arrNZD[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaMethod,MaFast,MaSlow,Price,USD,EUR,GBP,CHF,JPY,AUD,CAD,NZD,7,y);

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
      
         //
         //
         //
         //
         //

         if (USD) interpolate(arrUSD,iTime(NULL,timeFrame,y),i);
         if (EUR) interpolate(arrEUR,iTime(NULL,timeFrame,y),i);
         if (GBP) interpolate(arrGBP,iTime(NULL,timeFrame,y),i);
         if (JPY) interpolate(arrJPY,iTime(NULL,timeFrame,y),i);
         if (CHF) interpolate(arrCHF,iTime(NULL,timeFrame,y),i);
         if (AUD) interpolate(arrAUD,iTime(NULL,timeFrame,y),i);
         if (CAD) interpolate(arrCAD,iTime(NULL,timeFrame,y),i);
         if (NZD) interpolate(arrNZD,iTime(NULL,timeFrame,y),i);
   }
   return(0);
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void interpolate(double& buffer[], datetime time, int i)
{
   for (int n = 1; (i+n) < Bars && Time[i+n] >= time; n++) continue;
   
   //
   //
   //
   //
   //
   
   if (buffer[i] == EMPTY_VALUE || buffer[i+n] == EMPTY_VALUE) n=-1;
               double increment = (buffer[i+n] - buffer[i])/ n;
   for (int k = 1; k < n; k++)     buffer[i+k] = buffer[i] + k*increment;
}

//
//
//
//
//

double ma(string sym, int per, int Mode, int Price, int i)
{
    return(iMA(sym, 0, per, 0, Mode, Price, i));
}   


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void sl(int buffNo, string sym, int x, color col, string buffLabel)
{
   int    window = WindowFind(Indicator_Name);
   string ID = Indicator_Name + buffNo;
   
      if(ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
            ObjectSet(ID, OBJPROP_XDISTANCE, x + 25);
            ObjectSet(ID, OBJPROP_YDISTANCE, 5);
            ObjectSetText(ID, sym, 18, "Arial Black", col);

   SetIndexStyle(buffNo,DRAW_LINE,DRAW_LINE, Line_Thickness,col);
   SetIndexLabel(buffNo,buffLabel);
}
 
//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}