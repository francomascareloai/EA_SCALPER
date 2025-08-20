//+------------------------------------------------------------------+
//|                                          Candlestick Pattern.mq4 |
//|                                                    MHM Marketing |
//|                                              http://www.mql5.com |
//|                                      email: h.habboubi@gmail.com |
//+------------------------------------------------------------------+
#property copyright "MHM Marketing"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

extern int     StopLoss       = 20;
extern int     TakeProfit     = 50;
extern double  Lots           = 0.01;
extern int     Slippage       = 3;
extern int     MagicNumber    = 58132134;

extern bool Show_Alert = true;

extern bool Display_ShootStar_2 = true;
extern bool Show_ShootStar_Alert_2 = true;
extern bool Display_ShootStar_3 = true;
extern bool Show_ShootStar_Alert_3 = true;
extern bool Display_ShootStar_4 = true;
extern bool Show_ShootStar_Alert_4 = true;
extern color Color_ShootStar = Red;
int Text_ShootStar = 8;

extern bool Display_Hammer_2 = true;
extern bool Show_Hammer_Alert_2 = true;
extern bool Display_Hammer_3 = true;
extern bool Show_Hammer_Alert_3 = true;
extern bool Display_Hammer_4 = true;
extern bool Show_Hammer_Alert_4 = true;
extern color Color_Hammer = Blue;
int Text_Hammer = 8;

extern bool Display_Doji = true;
extern bool Show_Doji_Alert = true;
extern color Color_Doji = Red;
int Text_Doji = 8;

extern bool Display_Stars = true;
extern bool Show_Stars_Alert = true;
extern int  Star_Body_Length = 5;
extern color Color_Star = Blue;
int Text_Star = 8;

extern bool Display_Dark_Cloud_Cover = true;
extern bool Show_DarkCC_Alert = true;
extern color Color_DarkCC = Red;
int Text_DarkCC = 8;

extern bool Display_Piercing_Line = true;
extern bool Show_Piercing_Line_Alert = true;
extern color Color_Piercing_Line = Blue;
int Text_Piercing_Line = 8;

extern bool Display_Bearish_Engulfing = true;
extern bool Show_Bearish_Engulfing_Alert = true;
extern color Color_Bearish_Engulfing = Red;
int Text_Bearish_Engulfing = 8;

extern bool Display_Bullish_Engulfing = false;
extern bool Show_Bullish_Engulfing_Alert = false;
extern color Color_Bullish_Engulfing = Blue;
int Text_Bullish_Engulfing = 8;
extern int bars = 500;


//---- buffers
double upArrow[];
double downArrow[];


int Signal;
int SL,TP;
int point = 0;
int pipMultiplier = 1;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---
      if (Digits==3 || Digits==5) 
         pipMultiplier = 10;
   else  pipMultiplier = 1;               
         point = Point*pipMultiplier;
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---
   ObjectsDeleteAll(0, OBJ_TEXT);
   return(0);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int start()
  {
  if (!Lots > 0)
   {
       Lots = AccountFreeMargin() * .0001;
   }
  int Result=0;
//---
   Comment("\n", "\n", "Candlestick Pattern EA");

      SL=0;TP=0;
      if(StopLoss>0)   SL=Ask-point*StopLoss;
      if(TakeProfit>0) TP=Ask+point*TakeProfit;

 double Range, AvgRange;
   int counter, setalert;
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   int shift4;
   string pattern, period;
   int setPattern = 0;
   int alert = 0;
   double O, O1, O2, C, C1, C2, C3, L, L1, L2, L3, H, H1, H2, H3;
   double CL, CL1, CL2, BL, BLa, BL90, UW, LW, BodyHigh, BodyLow;
   BodyHigh = 0;
   BodyLow = 0;
   double Doji_Star_Ratio = 0;
   double Doji_MinLength = 0;
   double Star_MinLength = 0;
   int  Pointer_Offset = 0;         // The offset value for the arrow to be located off the candle high or low point.
   int  High_Offset = 0;            // The offset value added to the high arrow pointer for correct plotting of the pattern label.
   int  Offset_ShootStar = 0;       // The offset value of the shooting star above or below the pointer arrow.
   int  Offset_Hammer = 0;          // The offset value of the hammer above or below the pointer arrow.
   int  Offset_Doji = 0;            // The offset value of the doji above or below the pointer arrow.
   int  Offset_Star = 0;            // The offset value of the star above or below the pointer arrow.
   int  Offset_Piercing_Line = 0;   // The offset value of the piercing line above or below the pointer arrow.
   int  Offset_DarkCC = 0;          // The offset value of the dark cloud cover above or below the pointer arrow.
   int  Offset_Bullish_Engulfing = 0;
   int  Offset_Bearish_Engulfing = 0;
   int  CumOffset = 0;              // The counter value to be added to as more candle types are met.
   int  IncOffset = 0;              // The offset value that is added to a cummaltive offset value for each pass through the routine so any 
                                    // additional candle patterns that are also met, the label will print above the previous label. 
   double Piercing_Line_Ratio = 0;      
   int Piercing_Candle_Length = 0;  
   int Engulfing_Length = 0;
   double Candle_WickBody_Percent = 0;
   int CandleLength = 0;  
   
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   
   
   
   for (shift = 0; shift < bars; shift++) { 
      
      CumOffset = 0;
      setalert = 0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for (counter=shift ;counter<=shift+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
      shift4 = shift + 4;
      
      
      O = Open[shift1];
      O1 = Open[shift2];
      O2 = Open[shift3];
      H = High[shift1];
      H1 = High[shift2];
      H2 = High[shift3];
      H3 = High[shift4];
      L = Low[shift1];
      L1 = Low[shift2];
      L2 = Low[shift3];
      L3 = Low[shift4];
      C = Close[shift1];
      C1 = Close[shift2];
      C2 = Close[shift3];
      C3 = Close[shift4];
      if (O>C) {
         BodyHigh = O;
         BodyLow = C;  }
      else {
         BodyHigh = C;
         BodyLow = O; }
      CL = High[shift1]-Low[shift1];
      CL1 = High[shift2]-Low[shift2];
      CL2 = High[shift3]-Low[shift3];
      BL = Open[shift1]-Close[shift1];
      UW = High[shift1]-BodyHigh;
      LW = BodyLow-Low[shift1];
      BLa = MathAbs(BL);
      BL90 = BLa*Candle_WickBody_Percent;
      int ticket;
            
         
 // Bearish Patterns  
 
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/2)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)&&((UW/3)<=LW)&&((UW/4)<=LW)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_2 == true)  {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Shooting ShootStar 2",MagicNumber,0,Red);
            return(ticket);
         }
         	
         if (Show_ShootStar_Alert_2) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 2";
            setalert = 1;
         }
         }
         }
      }
      
      
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/3)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)&&((UW/4)<=LW)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_3 == true)  {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Shooting ShootStar 3",MagicNumber,0,Red);
            return(ticket);
         }
         
         if (Show_ShootStar_Alert_3) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 3";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/4)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_4 == true)  {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Shooting ShootStar 4",MagicNumber,0,Red);
            return(ticket);
         }
         
          if (Show_ShootStar_Alert_4) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 4";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Evening Star pattern
      if ((H>=H1)&&(H1>H2)&&(H1>H3))  {
         if (/*(L>O1)&&*/(BLa<(Star_Body_Length*Point))&&(C2>O2)&&(!O==C)&&((C2-O2)/(0.001+H2-L2)>Doji_Star_Ratio)/*&&(C2<O1)*/&&(C1>O1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(O>C)&&(CL>=(Star_MinLength*Point))){
         if (Display_Stars == true) {
           ticket =  OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Evening Star Pattern",MagicNumber,0,Red);
           return(ticket);
         }
         
         if (Show_Stars_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Star Pattern";
            setalert = 1;
         }
         }
         }
      }  
      
      // Check for Evening Doji Star pattern
      if ((H>=H1)&&(H1>H2)&&(H1>H3))  {
         if (/*(L>O1)&&*/(O==C)&&((C2>O2)&&(C2-O2)/(0.001+H2-L2)>Doji_Star_Ratio)/*&&(C2<O1)*/&&(C1>O1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(CL>=(Doji_MinLength*Point))) {
         if (Display_Doji == true) {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Evening Doji Star Pattern",MagicNumber,0,Red);
            return(ticket);
         }
         
         if (Show_Doji_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Doji Star Pattern";
            setalert = 1;
         }
         }
         }
      } 
      
      // Check for a Dark Cloud Cover pattern
      if ((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)/*&&(O>C1)*/&&(C>O1)&&((O-C)/(0.001+(H-L))>Piercing_Line_Ratio)&&((CL>=Piercing_Candle_Length*Point))) {
         if (Display_Dark_Cloud_Cover == true) {   
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Dark Cloud Cover Pattern",MagicNumber,0,Red);
            return(ticket);
         }
         
         if (Show_DarkCC_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Dark Cloud Cover Pattern";
            setalert = 1;
         }
         }
      }

      // Check for Bearish Engulfing pattern
      if ((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1))&&(CL>=(Engulfing_Length*Point))) {
         if (Display_Bearish_Engulfing == true) {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*Point,Ask+StopLoss*Point,Bid-TakeProfit*Point,"CSP: Bearish Engulfing Pattern",MagicNumber,0,Red);
            return(ticket);
         }
         if (Show_Bearish_Engulfing_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bearish Engulfing Pattern";
            setalert = 1;
         }
         }
      }
 
 // End of Bearish Patterns
   
 // Bullish Patterns
   
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
      if (((LW/2)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)&&((LW/3)<=UW)&&((LW/4)<=UW)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_2 == true)  {
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Bullish Hammer 2",MagicNumber,0,Green);
            return(ticket);
         }
         
         if (Show_Hammer_Alert_2) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 2";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
         if (((LW/3)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)&&((LW/4)<=UW)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_3 == true)  {
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Bullish Hammer 3",MagicNumber,0,Green);
            return(ticket);
         }
         
         if (Show_Hammer_Alert_3) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 3";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
         if (((LW/4)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_4 == true)  {
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Bullish Hammer 4",MagicNumber,0,Green);
            return(ticket);
            
         }
         
         
         if (Show_Hammer_Alert_4) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 4";
            setalert = 1;
         }
         }
         }
      }      

     // Check for Morning Star
      
      if ((L<=L1)&&(L1<L2)&&(L1<L3))  {
      if (/*(H1<(BL/2))&&*/(BLa<(Star_Body_Length*Point))&&(!O==C)&&((O2>C2)&&((O2-C2)/(0.001+H2-L2)>Doji_Star_Ratio))/*&&(C2>O1)*/&&(O1>C1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(C>O)&&(CL>=(Star_MinLength*Point))) {
         if (Display_Stars == true) {   
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Morning Star Pattern",MagicNumber,0,Green);
            return(ticket);
         }
         
         if (Show_Stars_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Star Pattern";
            setalert = 1;
         }
         }
         }
      }

      // Check for Morning Doji Star
      
      if ((L<=L1)&&(L1<L2)&&(L1<L3))  {
      if (/*(H1<(BL/2))&&*/(O==C)&&((O2>C2)&&((O2-C2)/(0.001+H2-L2)>Doji_Star_Ratio))/*&&(C2>O1)*/&&(O1>C1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(CL>=(Doji_MinLength*Point))) {
         if (Display_Doji == true) {   
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Morning Doji Pattern",MagicNumber,0,Green);
            return(ticket);
         }
         
         if (Show_Doji_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Doji Pattern";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Piercing Line pattern
      
      if ((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)/*&&(O<C1)*//*&&(C<O1)*/&&((C-O)/(0.001+(H-L))>Piercing_Line_Ratio)&&(CL>=(Piercing_Candle_Length*Point))) {
         if (Display_Piercing_Line == true) {   
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Piercing Line Pattern",MagicNumber,0,Green);
            return(ticket);
         }
         
         if (Show_Piercing_Line_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Piercing Line Pattern";
            setalert = 1;
         }
         }
      }   

      // Check for Bullish Engulfing pattern
      
      if ((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1))&&(CL>=(Engulfing_Length*Point))) {
         if (Display_Bullish_Engulfing) {   
            ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage*Point,Bid-StopLoss*Point,Ask+TakeProfit*Point,"CSP: Bullish Engulfing Pattern",MagicNumber,0,Green);
            return(ticket);
         }
        

         if (Show_Bullish_Engulfing_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Bullish Engulfing Pattern";
            setalert = 1;
         }
         }
      }
      
 // End of Bullish Patterns          
      if (setalert == 1 && shift == 0) {
         Alert(Symbol(), " ", period, " ", pattern);
         setalert = 0;
      }
      CumOffset = 0;
   } // End of for loop
     
   
      
   return(0);

   
  }
//+------------------------------------------------------------------+


string GetName(string aName,int shift)
{
  return(aName+DoubleToStr(Time[shift],0));
}