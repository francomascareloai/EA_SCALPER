#property copyright "Copyright © 2013, ForexMT4Systems."
#property link      "http://www.forexmt4systems.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DarkSlateGray
#property indicator_color2  Blue          //major bottom
#property indicator_color3  Red           //major top
#property indicator_color4  LimeGreen     //minor bottom
#property indicator_color5  PaleVioletRed //minor top
#property indicator_width1  4
#property indicator_width2  4
#property indicator_width3  4
#property indicator_width4  1
#property indicator_width5  1
#property indicator_minimum -1.2
#property indicator_maximum 1.2

extern int    PriceActionFilter  = 1;
extern int    Length             = 3;
extern int    MajorCycleStrength = 4;
extern bool   UseCycleFilter     = false;
extern int    UseFilterSMAorRSI  = 1;
extern int    FilterStrengthSMA  = 12;
extern int    FilterStrengthRSI  = 21;
extern bool   alertsOn           = true;
extern bool   alertsOnMajorCycle = true;
extern bool   alertsOnMinorCycle = false;
extern bool   alertsOnCurrent    = false;
extern bool   alertsMessage      = true;
extern bool   alertsSound        = false;
extern bool   alertsNotify       = false;
extern bool   alertsEmail        = false;

extern bool   arrowsVisible           = true;
extern bool   arrowsOnMajorCycle      = true;
extern color  arrowsMajorUpCycleColor = LimeGreen;
extern color  arrowsMajorDnCycleColor = Red;
extern int    arrowsMajorUpCycleCode  = 241;
extern int    arrowsMajorDnCycleCode  = 242;
extern int    arrowsMajorCycleSize    = 2;

extern bool   arrowsOnMinorCycle      = true;
extern color  arrowsMinorUpCycleColor = DeepSkyBlue;
extern color  arrowsMinorDnCycleColor = PaleVioletRed;
extern int    arrowsMinorUpCycleCode  = 159;
extern int    arrowsMinorDnCycleCode  = 159;
extern int    arrowsMinorCycleSize    = 5;

extern string arrowsIdentifier        = "ci arrows1";
extern double arrowsUpperGap          = 1.0;
extern double arrowsLowerGap          = 1.0;


double LineBuffer[];
double MajorCycleBuy[];
double MajorCycleSell[];
double MinorCycleBuy[];
double MinorCycleSell[];
double ZL1[];

double CyclePrice = 0.0, Strength =0.0, SweepA = 0.0, SweepB = 0.0;
int Switch = 0, Switch2 = 0,	SwitchA = 0, SwitchB = 0, SwitchC = 0, SwitchD = 0, SwitchE = 0, SwitchAA = 0, SwitchBB = 0;
double Price1BuyA = 0.0, Price2BuyA = 0.0;
int Price1BuyB = 1.0, Price2BuyB = 1.0;
double Price1SellA = 0.0, Price2SellA = 0.0;
int Price1SellB = 0.0, Price2SellB = 0.0;
bool ActiveSwitch = True, BuySwitchA = FALSE, BuySwitchB = FALSE, SellSwitchA = FALSE, SellSwitchB = FALSE;
int BuySellFac = 01;
bool Condition1, Condition2, Condition3, Condition6;

int SignalIndex = 0;
int init()  {
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,LineBuffer);
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(1,MajorCycleBuy);
   
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(2,MajorCycleSell);
   
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(3,MinorCycleBuy);
   
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(4,MinorCycleSell);
   SetIndexBuffer(5,ZL1);
   
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);  
   
   
   return(0);
}

int deinit()
{
   deleteArrows();

return(0);
}

int start() {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
  // if(counted_bars>0) counted_bars--;
  // int position=Bars-1;
   int position=Bars-counted_bars;
   if (position<0) position=0;

   int rnglength = 250;
   double range = 0.0, srange = 0.0;
   for (int pos = position; pos >=0; pos--)
   {
      srange = 0.0;
      int j = 0;
      for (int i=0;i<rnglength;i++)
      {
         j++;
         int posr = pos + i;
         if (posr >= Bars)
            break;
            
         srange = srange + (High[posr] - Low[posr]);
      }
      range = srange / j * Length;
      int BarNumber = Bars-pos; //??????????
      if (BarNumber < 0)
            BarNumber = 0;
 
      CyclePrice = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos);
      
      if (UseFilterSMAorRSI == 1)
            ZL1[pos] = ZeroLag(CyclePrice,FilterStrengthSMA, pos);
      if (UseFilterSMAorRSI == 2)
            ZL1[pos] = ZeroLag( iRSI(NULL, 0, 14, CyclePrice, FilterStrengthRSI ), FilterStrengthRSI, pos);

      if (ZL1[pos] > ZL1[pos+1]) 
          SwitchC = 1;
      if (ZL1[pos] < ZL1[pos+1]) 
          SwitchC = 2;
          
      if (BarNumber <= 1)
      {
         if (Strength == 0)
     		  SweepA  = range;
     		else
     		  SweepA = Strength;
         Price1BuyA  = CyclePrice;
         Price1SellA  = CyclePrice;
      }
      
      /* ***************************************************************** */
      
      if (BarNumber > 1)
      {
         if (Switch > -1)
         {
            if (CyclePrice < Price1BuyA)
            {
               
                  if (UseCycleFilter && (SwitchC == 2) && BuySwitchA )
                  {
			           MinorCycleBuy[pos + BarNumber - Price1BuyB] = 0; //MinorBuySell
			           LineBuffer[pos + BarNumber - Price1BuyB ] = 0; //line
		            }
		      
		            if (!UseCycleFilter && BuySwitchA)
		            {
			           MinorCycleBuy[pos +BarNumber - Price1BuyB] = 0;
			           LineBuffer[pos +BarNumber - Price1BuyB] = 0;
		            }
		            Price1BuyA = CyclePrice;
                  Price1BuyB = BarNumber;
                  BuySwitchA = TRUE;
            }
            else if (CyclePrice > Price1BuyA)
            {
  
   			      SwitchA = BarNumber - Price1BuyB;
         
		            if (!UseCycleFilter)
		            {
			           MinorCycleBuy[pos +SwitchA] = -1;//MinorBuySell - DarkGreen
			           LineBuffer[pos +SwitchA] = -1;//line
		            }
		      
		            if (UseCycleFilter && SwitchC  == 1)
		            {
			           MinorCycleBuy[pos +SwitchA] = -1;  //MinorBuySell
			           LineBuffer[pos +SwitchA] = -1; //line
			           SwitchD = 1; 
		            }
		            else
		            {
			           SwitchD = 0;
			         }
			   
                  BuySwitchA = TRUE;
		
		            double cyclePrice1 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchA);
                  if (ActiveSwitch)
                  {  
                        Condition1 = CyclePrice - cyclePrice1 >= SweepA; 
                  }
                  else
                  {
                        Condition1 = CyclePrice >= cyclePrice1 * (1 + SweepA / 1000);
                  }
                  if (Condition1 && SwitchA >= BuySellFac) 
                  {
                        Switch =  - 1;
                        Price1SellA = CyclePrice;
                        Price1SellB = BarNumber;
                        SellSwitchA = FALSE;
                        BuySwitchA = FALSE;
                  }            
            }
         }
         if(Switch < 1)
         {
            if (CyclePrice > Price1SellA)
            {
               if (UseCycleFilter && SwitchC == 1 && SellSwitchA )
               {
				     MinorCycleSell[pos +BarNumber - Price1SellB] = 0; //MinorBuySell
				     LineBuffer[pos +BarNumber - Price1SellB ] = 0; //line
			      }
			      if (!UseCycleFilter && SellSwitchA )
			      {
                   MinorCycleSell[pos +BarNumber - Price1SellB] = 0;//MinorBuySell
                   LineBuffer[pos +BarNumber - Price1SellB] = 0;//line
               }
               Price1SellA = CyclePrice;
               Price1SellB = BarNumber;
               SellSwitchA = TRUE;   
		       }
		       else if (CyclePrice < Price1SellA)
		       {
			      SwitchA = BarNumber - Price1SellB;
               if (!UseCycleFilter)
               {
                  MinorCycleSell[pos +SwitchA] = 1; // MinorBuySell darkRed
                  LineBuffer[pos +SwitchA] = 1; //"CycleLine"
			      }
      			if (UseCycleFilter && (SwitchC == 2))
      			{
				     MinorCycleSell[pos +SwitchA] = 1;//MinorBuySell darkRed
				     LineBuffer[pos +SwitchA] = 1;//CycleLine
				     SwitchD  = 2;
			      } 
			      else
			         SwitchD  = 0;

               SellSwitchA = TRUE;
			      double cyclePrice2 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchA);
               
			      if (ActiveSwitch)
				     Condition1 = (cyclePrice2 - CyclePrice) >= SweepA;
			      else 
				     Condition1 = CyclePrice <= (cyclePrice2 * (1 - SweepA / 1000));

			      if (Condition1 && SwitchA >= BuySellFac)
			      {
				      Switch = 1;
                  Price1BuyA = CyclePrice;
                  Price1BuyB = BarNumber;
                  SellSwitchA = FALSE;
                  BuySwitchA = FALSE;
               }
            } 
         }
      }
      
      LineBuffer[pos] = 0;
      MinorCycleBuy[pos] = 0;
      MinorCycleSell[pos] = 0;

      if (BarNumber == 1)
      {
         if (Strength == 0)
            SweepB  = range *  MajorCycleStrength;
         else
            SweepB = Strength * MajorCycleStrength;
            
         Price2BuyA = CyclePrice;
         Price2SellA = CyclePrice;
      }     
            
      if (BarNumber > 1)
      {
         if (Switch2  >  - 1)
         {
            if (CyclePrice < Price2BuyA)
            {
               if (UseCycleFilter && SwitchC == 2 && BuySwitchB )
				   {
				      MajorCycleBuy [pos +BarNumber - Price2BuyB] = 0; //MajorBuySell,green
		//		      LineBuffer[pos + BarNumber - Price2BuyB ] = 0; //line -----
               }
               if (!UseCycleFilter && BuySwitchB )
               {
                  MajorCycleBuy [pos +BarNumber - Price2BuyB] = 0;//MajorBuySell,green
  	//			      LineBuffer[pos + BarNumber - Price2BuyB ] = 0; //line-----------
               }
			      Price2BuyA = CyclePrice;
               Price2BuyB = BarNumber;
               BuySwitchB = TRUE;
            } 
            else if (CyclePrice > Price2BuyA)
            {
			      SwitchB = BarNumber - Price2BuyB;

               if (!UseCycleFilter)
               {  
                     MajorCycleBuy [pos +SwitchB] = -1; //MajorBuySell green
      //               LineBuffer[pos + SwitchB] = -1; //line--------------
               }
               if (UseCycleFilter && SwitchC  == 1)
               {
                  MajorCycleBuy [pos +SwitchB] = -1; //MajorBuySell green
     //             LineBuffer[pos + SwitchB] = -1; //line-----------------
                  SwitchE  = 1;
               } 
               else
				     SwitchE  = 0;

               BuySwitchB = TRUE;
			      double cyclePrice3 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchB);
               if (ActiveSwitch) 
                  Condition6 = CyclePrice - cyclePrice3 >= SweepB;
               else
                  Condition6 = CyclePrice >= cyclePrice3 * (1 + SweepB / 1000);

			      if (Condition6 && SwitchB >= BuySellFac)
			      {
                     Switch2 =  - 1;
                     Price2SellA = CyclePrice;
                     Price2SellB = BarNumber;
                     SellSwitchB = FALSE;
                     BuySwitchB = FALSE;
               }
            }
         }

         if (Switch2  < 1)
         {
            if (CyclePrice  > Price2SellA )
            {
			      if (UseCycleFilter && SwitchC  == 1 && SellSwitchB )
				   { 
				         MajorCycleSell [pos +BarNumber - Price2SellB] = 0; //"MajorBuySell",red 
		//			      LineBuffer[pos + BarNumber - Price2SellB ] = 0; //line -----
			     }
			      if (!UseCycleFilter && SellSwitchB )
				   {
				       MajorCycleSell [pos +BarNumber - Price2SellB] = 0;//"MajorBuySell",red 
     //              LineBuffer[pos + BarNumber - Price2SellB ] = 0; //line -----
               }
			      Price2SellA = CyclePrice;
               Price2SellB = BarNumber;
               SellSwitchB = TRUE;
		       }
		       else if (CyclePrice < Price2SellA)
		       {
               SwitchB = BarNumber - Price2SellB ;

      			if (!UseCycleFilter) 
      			{
      			   MajorCycleSell[pos + SwitchB] = 1; //"MajorBuySell",red 
     // 		      LineBuffer[pos + SwitchB ] = 1; //line -----
			      }
		         if (UseCycleFilter && SwitchC  == 2)
		         {
      				MajorCycleSell [pos + SwitchB] = 1; //"MajorBuySell",red 
      //		      LineBuffer[pos + SwitchB ] = 1; //line -----
		       		SwitchE  = 2;
			      }
			      else
				     SwitchE  = 0;

               SellSwitchB = TRUE;
	            double cyclePrice4 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchB);
			      if (ActiveSwitch)
                  Condition6 = cyclePrice4 - CyclePrice >= SweepB;
			      else
                  Condition6 = CyclePrice <= cyclePrice4 * (1.0 - SweepB / 1000.0);

			      if (Condition6 && SwitchB >= BuySellFac)
			      {
				        Switch2 = 1;
                     Price2BuyA = CyclePrice;
                     Price2BuyB = BarNumber;
                     SellSwitchB = FALSE;
                     BuySwitchB = FALSE;
               }
            }
         }
      }
      LineBuffer[pos]     = 0;
      MajorCycleSell[pos] = 0;
      MajorCycleBuy[pos]  = 0;  
    }
    
    for (pos = position; pos >=0; pos--)
    {
      if (arrowsVisible)
      {
        ObjectDelete(arrowsIdentifier+":1:"+Time[pos]);
        ObjectDelete(arrowsIdentifier+":2:"+Time[pos]);
        string lookFor = arrowsIdentifier+":"+Time[pos]; ObjectDelete(lookFor);
        if (arrowsOnMajorCycle)
        {
          if (MajorCycleBuy[pos]  != 0 && MajorCycleBuy[pos+1]  == 0) drawArrow("1",0.5,pos,arrowsMajorUpCycleColor,arrowsMajorUpCycleCode,arrowsMajorCycleSize,false);
          if (MajorCycleSell[pos] != 0 && MajorCycleSell[pos+1] == 0) drawArrow("1",0.5,pos,arrowsMajorDnCycleColor,arrowsMajorDnCycleCode,arrowsMajorCycleSize, true);
        } 
        if (arrowsOnMinorCycle)
        {
          if (MinorCycleBuy[pos]  != 0 && MinorCycleBuy[pos+1]  == 0) drawArrow("2",1,pos,arrowsMinorUpCycleColor,arrowsMinorUpCycleCode,arrowsMinorCycleSize,false);
          if (MinorCycleSell[pos] != 0 && MinorCycleSell[pos+1] == 0) drawArrow("2",1,pos,arrowsMinorDnCycleColor,arrowsMinorDnCycleCode,arrowsMinorCycleSize, true);
        }
                                
     }   

   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
     if (alertsOnCurrent)
        int whichBar = 0;
     else   whichBar = 1;
     
     //
     //
     //
     //
     //
     
     static string   type1 = "";
     static datetime time1 = 0;
        if (alertsOnMajorCycle)
        {
          if (MajorCycleBuy[whichBar]  != 0 && MajorCycleBuy[whichBar+1]  == 0) doAlert(type1,time1," ForexMT4Systems Cycle Buy");
          if (MajorCycleSell[whichBar] != 0 && MajorCycleSell[whichBar+1] == 0) doAlert(type1,time1," ForexMT4Systems Cycle Sell");
        }
     static string   type2 = "";
     static datetime time2 = 0;
        if (alertsOnMinorCycle)
        {
          if (MinorCycleBuy[whichBar]  != 0 && MinorCycleBuy[whichBar+1]  == 0) doAlert(type2,time2," ForexMT4Systems Cycle Buy");
          if (MinorCycleSell[whichBar] != 0 && MinorCycleSell[whichBar+1] == 0) doAlert(type2,time2," ForexMT4Systems Cycle Sell");
        }
     
     //
     //
     //
     //
     //
     
   }               
   return(0);
}

//
//
//
//
//

double ZeroLag(double price, int length, int pos)
{   
   if (length < 3)
   {
      return(price);
   }
   double aa = MathExp(-1.414*3.14159 / length);
   double bb = 2*aa*MathCos(1.414*180 / length);
   double CB = bb;
   double CC = -aa*aa;
   double CA = 1 - CB - CC;
   double CD = CA*price + CB*ZL1[pos+1] + CC*ZL1[pos+2];
   return(CD);
}


 //+------------------------------------------------------------------+
//
//
//
//
//

void doAlert(string& previousAlert, datetime& previousTime, string doWhat)
{
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Cycle identifier ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Cycle identifier "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void drawArrow(string nameAdd, double gapMul, int i,color theColor,int theCode,int theWidth,bool up)
{
   string name = arrowsIdentifier+":"+nameAdd+":"+Time[i];
   double gap  = iATR(NULL,0,20,i)*gapMul;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theWidth);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}



