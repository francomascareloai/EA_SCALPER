//+------------------------------------------------------------------+
//|   #SpudFibo.mq4 - downloaded from ultimaforex.com
//+------------------------------------------------------------------+
#property  indicator_chart_window
#define PERIOD_Y 999999
extern string note1 = "Weekly Fibonacci colors";
extern color UpperFiboColor = clrMaroon;
extern color MainFiboColor = clrBrown;
extern color LowerFiboColor = clrSienna;
extern string note2 = "Draw main Fibonacci lines?";
extern bool  InnerFibs = true;

double HiPrice, LoPrice, Range;
datetime StartTime;

int init()
{
   return(0);
}

int deinit()
{
   ObjectDelete("FiboUp1");
   ObjectDelete("FiboDn1");
   ObjectDelete("FiboIn1");
   return(0);
}


//+------------------------------------------------------------------+
//| Draw Fibo
//+------------------------------------------------------------------+

int DrawFibo()
{
	if(ObjectFind("FiboUp1") == -1)
		ObjectCreate("FiboUp1",OBJ_FIBO,0,StartTime,HiPrice+Range,StartTime,HiPrice);
	else
	{
		ObjectSet("FiboUp1",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboUp1",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboUp1",OBJPROP_PRICE1,HiPrice+Range);
		ObjectSet("FiboUp1",OBJPROP_PRICE2,HiPrice);
	}
   ObjectSet("FiboUp1",OBJPROP_LEVELCOLOR,UpperFiboColor);
   ObjectSet("FiboUp1",OBJPROP_FIBOLEVELS,13);
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboUp1",0,"(100.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboUp1",1,"(123.6%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboUp1",2,"(138.2%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboUp1",3,"(150.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboUp1",4,"(161.8%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboUp1",5,"(176.4%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboUp1",6,"(200.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+7,1.236);	ObjectSetFiboDescription("FiboUp1",7,"(223.6%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+8,1.500);	ObjectSetFiboDescription("FiboUp1",8,"(250.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+9,1.618);	ObjectSetFiboDescription("FiboUp1",9,"(261.8%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+10,2.000);	ObjectSetFiboDescription("FiboUp1",10,"(300.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+11,2.500);	ObjectSetFiboDescription("FiboUp1",11,"(350.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+12,3.000);	ObjectSetFiboDescription("FiboUp1",12,"(400.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+13,3.500);	ObjectSetFiboDescription("FiboUp1",13,"(450.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_FIRSTLEVEL+14,4.000);	ObjectSetFiboDescription("FiboUp1",14,"(500.0%) -  %$"); 
   ObjectSet("FiboUp1",OBJPROP_RAY,true);
   ObjectSet("FiboUp1",OBJPROP_BACK,true);

	if(ObjectFind("FiboDn1") == -1)
		ObjectCreate("FiboDn1",OBJ_FIBO,0,StartTime,LoPrice-Range,StartTime,LoPrice);
	else
	{
		ObjectSet("FiboDn1",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboDn1",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboDn1",OBJPROP_PRICE1,LoPrice-Range);
		ObjectSet("FiboDn1",OBJPROP_PRICE2,LoPrice);
	}
   ObjectSet("FiboDn1",OBJPROP_LEVELCOLOR,LowerFiboColor); 
   ObjectSet("FiboDn1",OBJPROP_FIBOLEVELS,19);
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboDn1",0,"(0.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboDn1",1,"(-23.6%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboDn1",2,"(-38.2%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboDn1",3,"(-50.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboDn1",4,"(-61.8%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboDn1",5,"(-76.4%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboDn1",6,"(-100.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+7,1.236);	ObjectSetFiboDescription("FiboDn1",7,"(-123.6%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+8,1.382);	ObjectSetFiboDescription("FiboDn1",8,"(-138.2%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+9,1.500);	ObjectSetFiboDescription("FiboDn1",9,"(-150.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+10,1.618);	ObjectSetFiboDescription("FiboDn1",10,"(-161.8%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+11,1.764);	ObjectSetFiboDescription("FiboDn1",11,"(-176.4%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+12,2.000);	ObjectSetFiboDescription("FiboDn1",12,"(-200.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+13,2.500);	ObjectSetFiboDescription("FiboDn1",13,"(-250.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+14,3.000);	ObjectSetFiboDescription("FiboDn1",14,"(-300.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+15,3.500);	ObjectSetFiboDescription("FiboDn1",15,"(-350.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+16,4.000);	ObjectSetFiboDescription("FiboDn1",16,"(-400.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+17,4.500);	ObjectSetFiboDescription("FiboDn1",17,"(-450.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_FIRSTLEVEL+18,5.000);	ObjectSetFiboDescription("FiboDn1",18,"(-500.0%) -  %$"); 
   ObjectSet("FiboDn1",OBJPROP_RAY,true);
   ObjectSet("FiboDn1",OBJPROP_BACK,true);

	if(InnerFibs)
	{
		if(ObjectFind("FiboIn1") == -1)
			ObjectCreate("FiboIn1",OBJ_FIBO,0,StartTime,HiPrice,StartTime+PERIOD_W1*60,LoPrice);
		else
		{
			ObjectSet("FiboIn1",OBJPROP_TIME2, StartTime);
			ObjectSet("FiboIn1",OBJPROP_TIME1, StartTime+PERIOD_W1*60);
			ObjectSet("FiboIn1",OBJPROP_PRICE1,HiPrice);
			ObjectSet("FiboIn1",OBJPROP_PRICE2,LoPrice);
		}
   	ObjectSet("FiboIn1",OBJPROP_LEVELCOLOR,MainFiboColor); 
   	ObjectSet("FiboIn1",OBJPROP_FIBOLEVELS,7);
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboIn1",0,"Weekly LOW (0.0) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboIn1",1,"(23.6) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboIn1",2,"(38.2) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboIn1",3,"(50.0) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboIn1",4,"(61.8) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboIn1",5,"(76.4) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboIn1",6,"Weekly HIGH (100.0) -  %$"); 
   	ObjectSet("FiboIn1",OBJPROP_RAY,true);
   	ObjectSet("FiboIn1",OBJPROP_BACK,true);
   }
   else
	   ObjectDelete("FiboIn1");
}

//+------------------------------------------------------------------+
//| Indicator start function
//+------------------------------------------------------------------+

int start()
{
	int shift	= iBarShift(NULL,PERIOD_W1 ,Time[0]) + 1;	// yesterday
	HiPrice		= iHigh(NULL,PERIOD_W1,shift);
	LoPrice		= iLow (NULL,PERIOD_W1,shift);
	StartTime	= iTime(NULL,PERIOD_W1,shift);

	if(TimeDayOfWeek(StartTime)==0/*Sunday*/)
	{//Add fridays high and low
		HiPrice = MathMax(HiPrice,iHigh(NULL,PERIOD_W1,shift+1));
		LoPrice = MathMin(LoPrice,iLow(NULL,PERIOD_W1,shift+1));
	}

	Range = HiPrice-LoPrice;

	DrawFibo();

	return(0);
}
//+------------------------------------------------------------------+

