/*+------------------------------------------------------------------+

   RD-TrendTrigger: MQ4 Conversion by Shimodax (www.strategybuilder.com)


   Original Notes and Authors:
	  Reference := Technical Analysis of Stocks and Commodities, Dec. 2004,p.28. M.H. Pee
	  TTF Author := Paul Y. Shimada
	  Link := PaulYShimada@Y...
	  Notes := Modified version of Trend Trigger Factor by mikesbon (thanks to perkyz)

//+------------------------------------------------------------------*/
#property copyright ""
#property link      ""

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_level1 0



#property indicator_color1 CadetBlue
#property indicator_color2 Blue
#property indicator_color3 Red

//---- input parameters
extern int       Regress= 15;
extern int       T3= 5;
extern double    B= 0.7;
extern int       HistoryMax= 1000;
extern int       TriggerLevel= 50;

//---- buffers
double Osc[];
double Trigger1[];
double Trigger2[];




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Osc);
   
   SetIndexStyle(1,DRAW_LINE, STYLE_DOT, 1);
   SetIndexBuffer(1,Trigger1);   

   SetIndexStyle(2,DRAW_LINE, STYLE_DOT, 1);
   SetIndexBuffer(2,Trigger2);   
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars= IndicatorCounted(), 
       limit;
   
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   
   limit= Bars - counted_bars;

   TrendTrigger(0, limit, Osc, Regress, T3, B);

   return (0);
}



//+------------------------------------------------------------------+
//| Calc forecast buffers  from lastbar down to offset               |
//+------------------------------------------------------------------+
void TrendTrigger(int offset, int lastbar, double &osc[], int regress, int t3, double b)
{

   int shift, length;
   double b2=b*b,
            b3=b2*b, 
            c1=-b3,
            c2=(3*(b2+b3)),
            c3=-3*(2*b2+b+b3),
            c4=(1+3*b+b3+3*b2), 
            n = 1 + 0.5*(t3-1),
            w1 = 2 / (n + 1),
            w2 = 1 - w1,
            WT,
            e1,e2,e3,e4,e5,e6,tmp,tmp2;

   lastbar= MathMin(lastbar, HistoryMax);
   lastbar= MathMin(Bars-31-regress, lastbar);   
 
   for (shift= lastbar+30; shift>=offset; shift--)   {

	  /*=================================*/
	  /* Standard Specific Computations */
	  /*=================================*/
	  double
	     HighestHighRecent = High[Highest(NULL, 0, MODE_HIGH,regress,shift)],
	     HighestHighOlder = High[Highest(NULL, 0, MODE_HIGH,regress,shift + regress)],
	     LowestLowRecent = Low [Lowest(NULL, 0, MODE_LOW,regress,shift)],
	     LowestLowOlder = Low [Lowest(NULL, 0, MODE_LOW,regress,shift+regress)],
	     BuyPower = HighestHighRecent - LowestLowOlder,
	     SellPower = HighestHighOlder - LowestLowRecent,
	     TTF = (BuyPower - SellPower) / (0.5 * (BuyPower + SellPower)) * 100;

      e1 = w1* TTF + w2*e1; 
      e2 = w1*e1 + w2*e2; 
      e3 = w1*e2 + w2*e3; 
      e4 = w1*e3 + w2*e4; 
      e5 = w1*e4 + w2*e5; 
      e6 = w1*e5 + w2*e6; 

      TTF = c1*e6 + c2*e5 + c3*e4 + c4*e3; 

      if (shift<=lastbar) {   // don't put swing in cycle into the signal buffers
         osc[shift] = TTF;
         
         Trigger1[shift]= TriggerLevel;
         Trigger2[shift]= -TriggerLevel;
      }
      
    }
  
   return(0);
}

/*======================*

loopBegin = loopBegin + 1; //Replot previous bar
For shift = loopBegin Downto 0
{
	//================================
	// Standard Specific Computations 
	//=================================
	HighestHighRecent = High[Highest(MODE_HIGH,shift,TTFbars)];
	HighestHighOlder = High[Highest(MODE_HIGH,shift + TTFbars,TTFbars)];
	LowestLowRecent = Low [Lowest(MODE_LOW,shift,TTFbars)];
	LowestLowOlder = Low [Lowest(MODE_LOW,shift+TTFbars,TTFbars)];
	BuyPower = HighestHighRecent - LowestLowOlder;
	SellPower = HighestHighOlder - LowestLowRecent;
	TTF = (BuyPower - SellPower) / (0.5 * (BuyPower + SellPower)) * 100;

	e1 = w1 * TTF + w2 * e1;
	e2 = w1 * e1 + w2 * e2;
	e3 = w1 * e2 + w2 * e3;
	e4 = w1 * e3 + w2 * e4;
	e5 = w1 * e4 + w2 * e5;
	e6 = w1 * e5 + w2 * e6;

	TTF = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
	SetIndexValue(shift,TTF);

	Switch mode_0Sep_1Main
		{
		Case 0: //Separate window Line (with dual trigger)
		SetIndexValue(shift,TTF);
		//Dual value trigger +/-100
		If TTF >= 0 Then SetIndexValue2(shift,50) Else SetIndexValue2(shift,(-50));

		Case 1: //Main Window Colored Bars
		If TTF >= 100 Then //Bull Trend, Blue bars
			{
			SetIndexValue(shift,High[shift]);
			SetIndexValue2(shift,Low[shift]);
			}
		Else
		If TTF <= (-100) Then //Bear Trend, Red bars
			{
			SetIndexValue(shift,Low[shift]);
			SetIndexValue2(shift,High[shift]);
			}
		Else //No Trend, No colored bars
			{
			SetIndexValue(shift,0);
			SetIndexValue2(shift,0);
			}
			}; //If TTF >= 100 Then ... Else
		}; //Switch mode_0Sep_1Main
		loopBegin = loopBegin - 1;
}

*/