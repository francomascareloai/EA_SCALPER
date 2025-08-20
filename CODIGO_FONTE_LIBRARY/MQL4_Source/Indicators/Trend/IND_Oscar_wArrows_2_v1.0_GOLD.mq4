//+------------------------------------------------------------------+
//|                                                        Oscar.mq4 |
//+------------------------------------------------------------------+

//modified 5 aug 2020
// - arrows on crossover
//modified 10 aug 2020
// - zero divide on H=L protection

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 75
#property indicator_level2 25
#property indicator_levelcolor DarkSlateGray

#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern  int iLookBack = 8;
extern int OscarAve = 5;
extern int highstop= 3;
extern int lowstop = 2;

extern bool arrows_show = false;
extern bool arrows_on_chart = false;
extern int arrows_size = 1;
extern color arrows_up_color = Aqua;
extern color arrows_down_color = OrangeRed;
/* unused code
double  spr, pnt, tickval;
int     dig;
string  IndiName, ccy;
*/

string  IndiName;

//---- buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()   {
   IndicatorBuffers(4);
//---- indicators



 //----
//   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, indicator_color1);
   SetIndexBuffer(0, Buffer1);
//   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 0, indicator_color2);
   SetIndexBuffer(1, Buffer2);
   
   SetIndexBuffer(2,Buffer5);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,arrows_size,arrows_up_color);
   SetIndexArrow(2,233);
   SetIndexBuffer(3,Buffer6);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,arrows_size,arrows_down_color);
   SetIndexArrow(3,234);
   
   
/* useless code  
  int checksum = 0;
  string str = "1";
  for (int i=0; i<StringLen(str); i++)  
    checksum += i * StringGetChar(str,i);
  IndiName = "Oscar-" + checksum;
*/

  IndiName = "Oscar(" + iLookBack + ")";
  IndicatorShortName(IndiName);
  SetIndexLabel(1,"MA("+OscarAve+")");

/* useless code
  ccy     = Symbol();
  pnt     = MarketInfo(ccy,MODE_POINT);
  dig     = MarketInfo(ccy,MODE_DIGITS);
  spr     = MarketInfo(ccy,MODE_SPREAD);
  tickval = MarketInfo(ccy,MODE_TICKVALUE);
  if (dig == 3 || dig == 5) {
    pnt     *= 10;
    spr     /= 10;
    tickval *= 10;
  }
*/

  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
   ObjectsDeleteAll(NULL,"osc",0,OBJ_ARROW);
//+------------------------------------------------------------------+
  return(0);
}

//+------------------------------------------------------------------+
int start()  {
  double Y = 0;
  for (int i=Bars-(iLookBack+2); i>=0; i--)  {
    double X = Y;
    double A = 0;
    double B = 999999;
    for(int j=i; j<i+iLookBack; j++)   {
      A = MathMax(High[j],A);
      B = MathMin(Low[j],B);
    }
    double C = Close[i];  
    double rough  = 0;
    if(A-B!=0){rough = (C-B)/(A-B)*100;}
    else if(A-B==0){rough = (C-B)/(A-B-10/MathPow(10,Digits()))*100;}
    Y = X/3*2 + rough/3;
    Buffer1[i] = Y;
    Buffer3[i] = (A + highstop/10000); 
    Buffer4[i] = (B- lowstop/10000);    
  }
  	i = Bars - (iLookBack+2);
	while(i>=0)
	{
		Buffer2[i]=iMAOnArray(Buffer1,0,OscarAve,0,MODE_LWMA,i);
		if(arrows_show){Buffer6[i]=EMPTY_VALUE;Buffer5[i]=EMPTY_VALUE;
      	if(Buffer1[i+1] >= Buffer2[i+1] && Buffer1[i+2] < Buffer2[i+2]){
         	Buffer5[i+1]=Buffer2[i+1];
         	if(arrows_on_chart){
         	   ObjectCreate(NULL,"osc arr"+IntegerToString(Bars-i),OBJ_ARROW,0,Time[i+1],Low[i+1]);
               ObjectSetInteger(NULL,"osc arr"+IntegerToString(Bars-i),OBJPROP_ARROWCODE,233);
               ObjectSetInteger(NULL,"osc arr"+IntegerToString(Bars-i),OBJPROP_COLOR,arrows_up_color);}      	}
      	if(Buffer1[i+1] <= Buffer2[i+1] && Buffer1[i+2] > Buffer2[i+2]){
      	   Buffer6[i+1]=Buffer2[i+1];
         	if(arrows_on_chart){
         	   ObjectCreate(NULL,"osc arr"+IntegerToString(Bars-i),OBJ_ARROW,0,Time[i+1],High[i+1]);
               ObjectSetInteger(NULL,"osc arr"+IntegerToString(Bars-i),OBJPROP_ARROWCODE,234);
               ObjectSetInteger(NULL,"osc arr"+IntegerToString(Bars-i),OBJPROP_COLOR,arrows_down_color);}         }
   	}
   	
		i--;	
	}
	
	
	
	
  return(0);
}


