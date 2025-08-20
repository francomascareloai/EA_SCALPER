//+------------------------------------------------------------------+
//|   #SpudFibo.mq4
//+------------------------------------------------------------------+
#property  indicator_chart_window

extern string note1 = "Fibonacci colors";
extern color UpperFiboColor = Navy;
extern color MainFiboColor = RoyalBlue;
extern color LowerFiboColor = DodgerBlue;
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
   ObjectDelete("FiboUp");
   ObjectDelete("FiboDn");
   ObjectDelete("FiboIn");
   return(0);
}


//+------------------------------------------------------------------+
//| Draw Fibo
//+------------------------------------------------------------------+

int DrawFibo()
{
	if(ObjectFind("FiboUp") == -1)
		ObjectCreate("FiboUp",OBJ_FIBO,0,StartTime,HiPrice+Range,StartTime,HiPrice);
	else
	{
		ObjectSet("FiboUp",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboUp",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboUp",OBJPROP_PRICE1,HiPrice+Range);
		ObjectSet("FiboUp",OBJPROP_PRICE2,HiPrice);
	}
   ObjectSet("FiboUp",OBJPROP_LEVELCOLOR,UpperFiboColor);
   ObjectSet("FiboUp",OBJPROP_FIBOLEVELS,13);
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboUp",0,"(100.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboUp",1,"(123.6%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboUp",2,"(138.2%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboUp",3,"(150.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboUp",4,"(161.8%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboUp",5,"(176.4%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboUp",6,"(200.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+7,1.236);	ObjectSetFiboDescription("FiboUp",7,"(223.6%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+8,1.500);	ObjectSetFiboDescription("FiboUp",8,"(250.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+9,1.618);	ObjectSetFiboDescription("FiboUp",9,"(261.8%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+10,2.000);	ObjectSetFiboDescription("FiboUp",10,"(300.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+11,2.500);	ObjectSetFiboDescription("FiboUp",11,"(350.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+12,3.000);	ObjectSetFiboDescription("FiboUp",12,"(400.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+13,3.500);	ObjectSetFiboDescription("FiboUp",13,"(450.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+14,4.000);	ObjectSetFiboDescription("FiboUp",14,"(500.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_RAY,true);
   ObjectSet("FiboUp",OBJPROP_BACK,true);

	if(ObjectFind("FiboDn") == -1)
		ObjectCreate("FiboDn",OBJ_FIBO,0,StartTime,LoPrice-Range,StartTime,LoPrice);
	else
	{
		ObjectSet("FiboDn",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboDn",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboDn",OBJPROP_PRICE1,LoPrice-Range);
		ObjectSet("FiboDn",OBJPROP_PRICE2,LoPrice);
	}
   ObjectSet("FiboDn",OBJPROP_LEVELCOLOR,LowerFiboColor); 
   ObjectSet("FiboDn",OBJPROP_FIBOLEVELS,19);
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboDn",0,"(0.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboDn",1,"(-23.6%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboDn",2,"(-38.2%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboDn",3,"(-50.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboDn",4,"(-61.8%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboDn",5,"(-76.4%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboDn",6,"(-100.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+7,1.236);	ObjectSetFiboDescription("FiboDn",7,"(-123.6%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+8,1.382);	ObjectSetFiboDescription("FiboDn",8,"(-138.2%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+9,1.500);	ObjectSetFiboDescription("FiboDn",9,"(-150.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+10,1.618);	ObjectSetFiboDescription("FiboDn",10,"(-161.8%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+11,1.764);	ObjectSetFiboDescription("FiboDn",11,"(-176.4%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+12,2.000);	ObjectSetFiboDescription("FiboDn",12,"(-200.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+13,2.500);	ObjectSetFiboDescription("FiboDn",13,"(-250.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+14,3.000);	ObjectSetFiboDescription("FiboDn",14,"(-300.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+15,3.500);	ObjectSetFiboDescription("FiboDn",15,"(-350.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+16,4.000);	ObjectSetFiboDescription("FiboDn",16,"(-400.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+17,4.500);	ObjectSetFiboDescription("FiboDn",17,"(-450.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+18,5.000);	ObjectSetFiboDescription("FiboDn",18,"(-500.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_RAY,true);
   ObjectSet("FiboDn",OBJPROP_BACK,true);

	if(InnerFibs)
	{
		if(ObjectFind("FiboIn") == -1)
			ObjectCreate("FiboIn",OBJ_FIBO,0,StartTime,HiPrice,StartTime+PERIOD_D1*60,LoPrice);
		else
		{
			ObjectSet("FiboIn",OBJPROP_TIME2, StartTime);
			ObjectSet("FiboIn",OBJPROP_TIME1, StartTime+PERIOD_D1*60);
			ObjectSet("FiboIn",OBJPROP_PRICE1,HiPrice);
			ObjectSet("FiboIn",OBJPROP_PRICE2,LoPrice);
		}
   	ObjectSet("FiboIn",OBJPROP_LEVELCOLOR,MainFiboColor); 
   	ObjectSet("FiboIn",OBJPROP_FIBOLEVELS,7);
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboIn",0,"Yesterday LOW (0.0) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboIn",1,"(23.6) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboIn",2,"(38.2) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboIn",3,"(50.0) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboIn",4,"(61.8) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboIn",5,"(76.4) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboIn",6,"Yesterday HIGH (100.0) -  %$"); 
   	ObjectSet("FiboIn",OBJPROP_RAY,true);
   	ObjectSet("FiboIn",OBJPROP_BACK,true);
   }
   else
	   ObjectDelete("FiboIn");
}

//+------------------------------------------------------------------+
//| Indicator start function
//+------------------------------------------------------------------+

int start()
{
	int shift	= iBarShift(NULL,PERIOD_D1,Time[0]) + 1;	// yesterday
	HiPrice		= iHigh(NULL,PERIOD_D1,shift);
	LoPrice		= iLow (NULL,PERIOD_D1,shift);
	StartTime	= iTime(NULL,PERIOD_D1,shift);

	if(TimeDayOfWeek(StartTime)==0/*Sunday*/)
	{//Add fridays high and low
		HiPrice = MathMax(HiPrice,iHigh(NULL,PERIOD_D1,shift+1));
		LoPrice = MathMin(LoPrice,iLow(NULL,PERIOD_D1,shift+1));
	}

	Range = HiPrice-LoPrice;

	DrawFibo();

	return(0);
}
//+------------------------------------------------------------------+

