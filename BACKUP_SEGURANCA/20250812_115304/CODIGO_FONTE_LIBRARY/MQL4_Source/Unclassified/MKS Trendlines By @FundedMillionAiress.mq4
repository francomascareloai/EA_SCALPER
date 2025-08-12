//+------------------------------------------------------------------+
//|                                              4_Trendlines_v3.mq4 |
//|                      Copyright © 2006, Cartwright Software Corp. |
//|                                        http://www.cartwright.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Cartwright Software Corp."
#property link      "http://www.cartwright.net"  // No web site!!!
extern int Server_Local_TimeDiff = 10;
extern bool   ApplyToOpen = false;
extern string Friday_Close_Hour = "1pm";
extern string TL_1_StartTime =  "2:45pm"; //2:45pm(PST) 5:45pm(EST)
extern string TL_1_EndTime =  "9:15pm"; //9:15pm(PST) 12:15am(EST)
extern string TL_2_StartTime =  "2:45pm"; //2:45pm(PST) 5:45pm(EST)
extern string TL_2_EndTime =  "11:45pm"; //11:45pm(PST) 2:45am(EST)
extern string TL_3_StartTime =  "12:15am"; //12:15am(PST) 3:15am(EST)
extern string TL_3_EndTime =  "5:15am"; //5:15am(PST) 8:15am(EST)
extern string TL_4_StartTime =  "5:15am"; //5:15am(PST) 8:15am(EST)
extern string TL_4_EndTime =  "11:15am"; //11:15am(PST) 2:15pm(EST)
extern color  FirstColor = DodgerBlue;
extern color  SecondColor = Goldenrod;
extern color  ThirdColor = Salmon;
extern color  FourthColor = Violet;

int FridayCloseHour=23, vHour=0;
int timeDiff=10;
bool alertFlag=false, alertFlag2=false;
string TL1StartTime, TL1EndTime, TL2StartTime, TL2EndTime;
string TL3StartTime, TL3EndTime, TL4StartTime, TL4EndTime;
string test, test2, barTime;

int TL_1_TradeDay=1;  

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
TL_1_TradeDay=DayOfYear()+1;  

int str=0, vHour2=0;
string substring, substring2, substring3;

//Calculate Friday Close Hour
str=StringLen(Friday_Close_Hour);
if (str==3) {
substring=StringSubstr(Friday_Close_Hour, 0, 1);
substring2=StringSubstr(Friday_Close_Hour, 1, 2);
if (substring2=="am" && substring!="12") {vHour2=StrToInteger(substring)+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if  (substring2=="am" && substring=="12") {vHour2=0+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if (substring2=="pm" && substring!="12") {vHour2=StrToInteger(substring)+12+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if  (substring2=="pm" && substring=="12") {vHour2=12+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
}
if (str==4) {
substring=StringSubstr(Friday_Close_Hour, 0, 2);
substring2=StringSubstr(Friday_Close_Hour, 2, 2);
if (substring2=="am" && substring!="12") {vHour2=StrToInteger(substring)+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if  (substring2=="am" && substring=="12") {vHour2=0+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if (substring2=="pm" && substring!="12") {vHour2=StrToInteger(substring)+12+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
   else if  (substring2=="pm" && substring=="12") {vHour2=12+Server_Local_TimeDiff; if (vHour2>23) vHour2=vHour2-24;}
}
FridayCloseHour=vHour2;

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectDelete("TL_1");
ObjectDelete("TL_1_2");
ObjectDelete("TL_2");
ObjectDelete("TL_2_2");   
ObjectDelete("TL_3");
ObjectDelete("TL_3_2");
ObjectDelete("TL_4");
ObjectDelete("TL_4_2");      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
calcTimes();

int i;
double TL_1_starttime=0, TL_1_endtime=0,TL_1_StartPrice=0, TL_1_EndPrice=0;
double TL_2_starttime=0, TL_2_endtime=0,TL_2_StartPrice=0, TL_2_EndPrice=0;
double TL_3_starttime=0, TL_3_endtime=0,TL_3_StartPrice=0, TL_3_EndPrice=0;
double TL_4_starttime=0, TL_4_endtime=0,TL_4_StartPrice=0, TL_4_EndPrice=0;
bool TL_1_Start=false, TL_1_Completed=false;
bool TL_2_Start=false, TL_2_Completed=false;
bool TL_3_Start=false, TL_3_Completed=false;
bool TL_4_Start=false, TL_4_Completed=false;


for (i=0;i<Bars;i++)
{
barTime=TimeToStr(iTime(NULL,PERIOD_M15,i), TIME_MINUTES);
if (TL_1_Completed == false && barTime==TL1EndTime)
   {
   TL_1_endtime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_1_EndPrice = iOpen(NULL,PERIOD_M15,i);
   if (ApplyToOpen==true) TL_1_EndPrice = iOpen(NULL,PERIOD_M15,i); else TL_1_EndPrice = iClose(NULL,PERIOD_M15,i);
   TL_1_Start = true;
   }  
if (TL_1_Start == true && barTime==TL1StartTime)
   {
   TL_1_starttime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_1_StartPrice = iOpen(NULL,PERIOD_M15,i);
   if (ApplyToOpen==true) TL_1_StartPrice = iOpen(NULL,PERIOD_M15,i); else TL_1_StartPrice = iClose(NULL,PERIOD_M15,i);
   TL_1_Completed = true;
   TL_1_Start= false;
   } 

if (TL_2_Completed == false && barTime==TL2EndTime)
   {
   TL_2_endtime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_2_EndPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_2_EndPrice = iOpen(NULL,PERIOD_M15,i); else TL_2_EndPrice = iClose(NULL,PERIOD_M15,i);
   TL_2_Start = true;
   }  
if (TL_2_Start == true && barTime==TL2StartTime)
   {
   TL_2_starttime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_2_StartPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_2_StartPrice = iOpen(NULL,PERIOD_M15,i); else TL_2_StartPrice = iClose(NULL,PERIOD_M15,i);
   TL_2_Completed = true;
   TL_2_Start = false;
   }
   
if (TL_3_Completed == false && barTime==TL3EndTime)
   {
   TL_3_endtime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_3_EndPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_3_EndPrice = iOpen(NULL,PERIOD_M15,i); else TL_3_EndPrice = iClose(NULL,PERIOD_M15,i);
   TL_3_Start = true;
   }  
if (TL_3_Start == true && barTime==TL3StartTime)
   {
   TL_3_starttime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_3_StartPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_3_StartPrice = iOpen(NULL,PERIOD_M15,i); else TL_3_StartPrice = iClose(NULL,PERIOD_M15,i);
   TL_3_Completed = true;
   TL_3_Start = false;
   }           
   
if (TL_4_Completed == false && barTime==TL4EndTime)
   {
   TL_4_endtime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_4_EndPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_4_EndPrice = iOpen(NULL,PERIOD_M15,i); else TL_4_EndPrice = iClose(NULL,PERIOD_M15,i);
   TL_4_Start = true;
   }  
if (TL_4_Start == true && barTime==TL4StartTime)
   {
   TL_4_starttime = iTime(NULL,PERIOD_M15,i);//Time[i];
   //TL_4_StartPrice = iOpen(NULL,PERIOD_M15,i);//Close[i];
   if (ApplyToOpen==true) TL_4_StartPrice = iOpen(NULL,PERIOD_M15,i); else TL_4_StartPrice = iClose(NULL,PERIOD_M15,i);
   TL_4_Completed = true;
   TL_4_Start = false;
   }          

if (TL_1_Completed == true && TL_2_Completed == true
    && TL_3_Completed == true && TL_4_Completed == true) break;

}
    
ObjectDelete("TL_1");
ObjectCreate("TL_1",OBJ_TREND, 0,TL_1_starttime,TL_1_StartPrice,TL_1_endtime,TL_1_EndPrice);
ObjectSet("TL_1",OBJPROP_COLOR,FirstColor);
ObjectSet("TL_1", OBJPROP_RAY, false);
ObjectSet("TL_1",OBJPROP_WIDTH,2);

ObjectDelete("TL_1_2");
ObjectCreate("TL_1_2",OBJ_TREND, 0,TL_1_starttime,TL_1_StartPrice,TL_1_endtime,TL_1_EndPrice);
ObjectSet("TL_1_2",OBJPROP_COLOR,FirstColor);
ObjectSet("TL_1_2",OBJPROP_STYLE,STYLE_DOT);
ObjectSet("TL_1_2", OBJPROP_RAY, true);

ObjectDelete("TL_2");
ObjectCreate("TL_2",OBJ_TREND, 0,TL_2_starttime,TL_2_StartPrice,TL_2_endtime,TL_2_EndPrice);
ObjectSet("TL_2",OBJPROP_COLOR,SecondColor);
ObjectSet("TL_2", OBJPROP_RAY, false);
ObjectSet("TL_2",OBJPROP_WIDTH,2);

ObjectDelete("TL_2_2");
ObjectCreate("TL_2_2",OBJ_TREND, 0,TL_2_starttime,TL_2_StartPrice,TL_2_endtime,TL_2_EndPrice);
ObjectSet("TL_2_2",OBJPROP_COLOR,SecondColor);
ObjectSet("TL_2_2",OBJPROP_STYLE,STYLE_DOT);
ObjectSet("TL_2_2", OBJPROP_RAY, true);

ObjectDelete("TL_3");
ObjectCreate("TL_3",OBJ_TREND, 0,TL_3_starttime,TL_3_StartPrice,TL_3_endtime,TL_3_EndPrice);
ObjectSet("TL_3",OBJPROP_COLOR,ThirdColor);
ObjectSet("TL_3", OBJPROP_RAY, false);
ObjectSet("TL_3",OBJPROP_WIDTH,2);

ObjectDelete("TL_3_2");
ObjectCreate("TL_3_2",OBJ_TREND, 0,TL_3_starttime,TL_3_StartPrice,TL_3_endtime,TL_3_EndPrice);
ObjectSet("TL_3_2",OBJPROP_COLOR,ThirdColor);
ObjectSet("TL_3_2",OBJPROP_STYLE,STYLE_DOT);
ObjectSet("TL_3_2", OBJPROP_RAY, true);

ObjectDelete("TL_4");
ObjectCreate("TL_4",OBJ_TREND, 0,TL_4_starttime,TL_4_StartPrice,TL_4_endtime,TL_4_EndPrice);
ObjectSet("TL_4",OBJPROP_COLOR,FourthColor);
ObjectSet("TL_4", OBJPROP_RAY, false);
ObjectSet("TL_4",OBJPROP_WIDTH,2);

ObjectDelete("TL_4_2");
ObjectCreate("TL_4_2",OBJ_TREND, 0,TL_4_starttime,TL_4_StartPrice,TL_4_endtime,TL_4_EndPrice);
ObjectSet("TL_4_2",OBJPROP_COLOR,FourthColor);
ObjectSet("TL_4_2",OBJPROP_STYLE,STYLE_DOT);
ObjectSet("TL_4_2", OBJPROP_RAY, true);

double price=ObjectGetValueByShift("TL_4_2", 0);
double price2=ObjectGetValueByShift("TL_4_2", 1);
double HC1=ObjectGetValueByShift("HC1_1", 1);
double LC1=ObjectGetValueByShift("LC1_1", 1);

double TL_1_2_price=ObjectGetValueByShift("TL_1_2", 0);
double TL_2_2_price=ObjectGetValueByShift("TL_2_2", 0);
double TL_3_2_price=ObjectGetValueByShift("TL_3_2", 0);
double TL_4_2_price=ObjectGetValueByShift("TL_4_2", 0);

bool TrendUp=false, TrendDown=false;
bool TL_1_Trade=false;

if (TL_1_2_price > ObjectGetValueByShift("TL_1_2", 5)) TrendUp=true;
   else if (TL_1_2_price < ObjectGetValueByShift("TL_1_2", 5)) TrendDown=true;

Comment("TL4StartTime= ",TL4StartTime," TL4EndTime = ",TL4EndTime," TL_4_EndPrice = ",TL_4_EndPrice," TL_1_Start = ",TL_1_Start,
      "\n","Time[0]= ",TimeToStr(Time[0],TIME_MINUTES)," vHour= ",vHour," barTime = ",barTime,"\n",
       "TL_1_starttime = ",TL_1_starttime," TL_1_endtime = ",TL_1_endtime," FridayCloseHour= ",FridayCloseHour,"\n",
       "iTime(NULL,PERIOD_M15,0)= ",iTime(NULL,PERIOD_M15,0),
      "\n","iClose(NULL,PERIOD_M15,0)= ",iClose(NULL,PERIOD_M15,0),
      "\n","iOpen(NULL,PERIOD_M15,0)= ",iOpen(NULL,PERIOD_M15,0),"\n",
      "TL_4_0= ",price," TL_4_1= ",price2,"\n","HC1 = ",HC1,," LC1 = ",LC1,"\n",
      "TL_1_TradeDay= ",TL_1_TradeDay, " TrendUp= ",TrendUp," TrendDown= ",TrendDown,"\n",
      "Time difference = ",(MathRound((CurTime() - LocalTime())/3600)));       
//----

   return(0);
  }
//+------------------------------------------------------------------+
void calcTimes(){
int strlen=0;
string substr, substr2, substr3;
string substr100, substr200;

if (CurTime() > LocalTime()) {timeDiff = CurTime() - LocalTime();} 
    else timeDiff = LocalTime() - CurTime(); // if (alertFlag==false) {Alert("Error!!!", "Server Time<Local Time",
     // "\n","If Server is active. You need to replace the code!"); alertFlag=true;}}//----}
timeDiff=MathRound(timeDiff/3600);

if (DayOfWeek()==5 && Hour()>=FridayCloseHour) timeDiff=Server_Local_TimeDiff;
else 
if (timeDiff != Server_Local_TimeDiff) {
//--!--   if (alertFlag==false) {Alert("Error!!!", " Server_Local_TimeDiff Do not match!",
   Alert("Error!!!", " Server_Local_TimeDiff Do not match!");} //--!--
//      "\n","If Server is active.","\n", 
//      "You need to change Server_Local_TimeDiff!","\n",
//      "Or you may have to change the Friday_Close_Hour."); alertFlag=true;}}
   //if (alertFlag2==false) {Alert("Error!!!", " timeDiff != Server_Local_TimeDiff",
    //  "\n","timeDiff= ",timeDiff); alertFlag2=true;}}//----


//Calculate TL1StartTime 
strlen=StringLen(TL_1_StartTime);

if (strlen==6) {
substr=StringSubstr(TL_1_StartTime, 0, 1);
substr2=StringSubstr(TL_1_StartTime, 2, 2);
substr3=StringSubstr(TL_1_StartTime, 4, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}

if (strlen==7) {
substr=StringSubstr(TL_1_StartTime, 0, 2);
substr2=StringSubstr(TL_1_StartTime, 3, 2);
substr3=StringSubstr(TL_1_StartTime, 5, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}
TL1StartTime=vHour+":"+substr2;   
strlen=StringLen(TL1StartTime);
if (strlen==4) TL1StartTime="0"+TL1StartTime;  

//Calculate TL1EndTime 
strlen=StringLen(TL_1_EndTime);
if (strlen==6) {substr=StringSubstr(TL_1_EndTime, 0, 1);
               substr2=StringSubstr(TL_1_EndTime, 2, 2);
               substr3=StringSubstr(TL_1_EndTime, 4, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
if (strlen==7) {substr=StringSubstr(TL_1_EndTime, 0, 2);
               substr2=StringSubstr(TL_1_EndTime, 3, 2);
               substr3=StringSubstr(TL_1_EndTime, 5, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}   

TL1EndTime=vHour+":"+substr2;   
strlen=StringLen(TL1EndTime);
if (strlen==4) TL1EndTime="0"+TL1EndTime;         

//Calculate TL2StartTime 
strlen=StringLen(TL_2_StartTime);

if (strlen==6) {
substr=StringSubstr(TL_2_StartTime, 0, 1);
substr2=StringSubstr(TL_2_StartTime, 2, 2);
substr3=StringSubstr(TL_2_StartTime, 4, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}

if (strlen==7) {
substr=StringSubstr(TL_2_StartTime, 0, 2);
substr2=StringSubstr(TL_2_StartTime, 3, 2);
substr3=StringSubstr(TL_2_StartTime, 5, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}
TL2StartTime=vHour+":"+substr2;   
strlen=StringLen(TL2StartTime);
if (strlen==4) TL2StartTime="0"+TL2StartTime;  

//Calculate TL2EndTime 
strlen=StringLen(TL_2_EndTime);
if (strlen==6) {substr=StringSubstr(TL_2_EndTime, 0, 1);
               substr2=StringSubstr(TL_2_EndTime, 2, 2);
               substr3=StringSubstr(TL_2_EndTime, 4, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
if (strlen==7) {substr=StringSubstr(TL_2_EndTime, 0, 2);
               substr2=StringSubstr(TL_2_EndTime, 3, 2);
               substr3=StringSubstr(TL_2_EndTime, 5, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}   

TL2EndTime=vHour+":"+substr2;   
strlen=StringLen(TL2EndTime);
if (strlen==4) TL2EndTime="0"+TL2EndTime;         

//Calculate TL3StartTime 
strlen=StringLen(TL_3_StartTime);

if (strlen==6) {
substr=StringSubstr(TL_3_StartTime, 0, 1);
substr2=StringSubstr(TL_3_StartTime, 2, 2);
substr3=StringSubstr(TL_3_StartTime, 4, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}

if (strlen==7) {
substr=StringSubstr(TL_3_StartTime, 0, 2);
substr2=StringSubstr(TL_3_StartTime, 3, 2);
substr3=StringSubstr(TL_3_StartTime, 5, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}
TL3StartTime=vHour+":"+substr2;   
strlen=StringLen(TL3StartTime);
if (strlen==4) TL3StartTime="0"+TL3StartTime;  

//Calculate TL3EndTime 
strlen=StringLen(TL_3_EndTime);
if (strlen==6) {substr=StringSubstr(TL_3_EndTime, 0, 1);
               substr2=StringSubstr(TL_3_EndTime, 2, 2);
               substr3=StringSubstr(TL_3_EndTime, 4, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
if (strlen==7) {substr=StringSubstr(TL_3_EndTime, 0, 2);
               substr2=StringSubstr(TL_3_EndTime, 3, 2);
               substr3=StringSubstr(TL_3_EndTime, 5, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}   

TL3EndTime=vHour+":"+substr2;   
strlen=StringLen(TL3EndTime);
if (strlen==4) TL3EndTime="0"+TL3EndTime;         


//Calculate TL4StartTime 
strlen=StringLen(TL_4_StartTime);

if (strlen==6) {
substr=StringSubstr(TL_4_StartTime, 0, 1);
substr2=StringSubstr(TL_4_StartTime, 2, 2);
substr3=StringSubstr(TL_4_StartTime, 4, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}

if (strlen==7) {
substr=StringSubstr(TL_4_StartTime, 0, 2);
substr2=StringSubstr(TL_4_StartTime, 3, 2);
substr3=StringSubstr(TL_4_StartTime, 5, 2);
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else if  (substr3=="pm" && substr=="12") {vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
}
TL4StartTime=vHour+":"+substr2;   
strlen=StringLen(TL4StartTime);
if (strlen==4) TL4StartTime="0"+TL4StartTime;  

//Calculate TL4EndTime 
strlen=StringLen(TL_4_EndTime);
if (strlen==6) {substr=StringSubstr(TL_4_EndTime, 0, 1);
               substr2=StringSubstr(TL_4_EndTime, 2, 2);
               substr3=StringSubstr(TL_4_EndTime, 4, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}
if (strlen==7) {substr=StringSubstr(TL_4_EndTime, 0, 2);
               substr2=StringSubstr(TL_4_EndTime, 3, 2);
               substr3=StringSubstr(TL_4_EndTime, 5, 2);}
if (substr3=="am" && substr!="12") {vHour=StrToInteger(substr)+timeDiff;} else if (vHour>23) vHour=vHour-24;
   else if  (substr3=="am" && substr=="12") {vHour=0+timeDiff; if (vHour>23) vHour=vHour-24;}
if (substr3=="pm" && substr!="12") {vHour=StrToInteger(substr)+12+timeDiff; if (vHour>23) vHour=vHour-24;}
   else {if  (substr3=="pm" && substr=="12") vHour=12+timeDiff; if (vHour>23) vHour=vHour-24;}   

TL4EndTime=vHour+":"+substr2;   
strlen=StringLen(TL4EndTime);
if (strlen==4) TL4EndTime="0"+TL4EndTime;       
}  

