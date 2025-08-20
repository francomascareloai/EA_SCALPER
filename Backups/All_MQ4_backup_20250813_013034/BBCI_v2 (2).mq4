//+------------------------------------------------------------------+
//|                                        BBCI v2.0 by Yuritch 2011 |
//|                            based on CycleIdentifier by Roy Kelly |  
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Aqua
#property indicator_color2 Orange

#property indicator_color5 Red
#property indicator_color6 Lime

#property indicator_width1 3
#property indicator_width2 3

#property indicator_width5 2
#property indicator_width6 2

#property indicator_minimum -1.2
#property indicator_maximum  1.2

extern int     smooth_factor=3;
extern double  Length=2;
extern int     mcs=2;
int 				limit=750;
extern bool    show_lines=true;

double MajorCycleBuy[];
double MajorCycleSell[];
double MinorCycleBuy[];
double MinorCycleSell[];
double trend[];
double sign[];
double smooth[];
int	 major;
int    minor;

double   ma_price = 0.0, scope_a = 0.0, scope_b = 0.0;
double   price_buy_a1 = 0.0, price_buy_a2 = 0.0;
double   price_sell_a1 = 0.0, price_sell_a2 = 0.0, range = 0.0,srange = 0.0;
double 	a,b,c,k1, k2, k3, k4;
int      switch1 = 0, switch2 = 0, switch3 = 0, switch4 = 0;
int      price_buy_b1 = 1.0, price_buy_b2 = 1.0;
int      price_sell_b1 = 0.0, price_sell_b2 = 0.0;
int      direct = 1,subwin;

bool     buy_sw_a = 0, buy_sw_b = 0, sell_sw_a = 0, sell_sw_b = 0;
bool     status = 1, status1, status2;
string   shortname = "BBCI";

/* ***************************************************************** */
int init()  
{
   IndicatorDigits(0);
   IndicatorBuffers(7);
   
   for (int i=0;i<=6;i++) SetIndexEmptyValue(i,0); 
       
   SetIndexBuffer(0,trend);   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexLabel(0,"trend");
   
   SetIndexBuffer(1,sign);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
//   SetIndexArrow(1, 0x9F);
   SetIndexLabel(1,"signal");
    
   SetIndexBuffer(2,MajorCycleBuy);       
   SetIndexStyle(2,DRAW_NONE);
   SetIndexLabel(2,NULL);

   SetIndexBuffer(3,MajorCycleSell);   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexLabel(3,NULL);
      
   SetIndexBuffer(4,MinorCycleBuy);   
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(4, 0xFB);
   SetIndexLabel(4,"Exit SELL");

   SetIndexBuffer(5,MinorCycleSell);   
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID);
   SetIndexArrow(5, 0xFB);
   SetIndexLabel(5,"Exit BUY");
   
   SetIndexBuffer(6,smooth);

   SetLevelValue(1,1);
   SetLevelValue(2,-1);
   
    a = MathExp(-3.14159 / smooth_factor);
    b = 2 * a * MathCos(MathSqrt(2) * 180 / smooth_factor);
    c = a * a;
    k2 = b + c;
    k3 = -(c + b * c);
    k4 = c * c;
    k1 = 1.0 - k2 - k3 - k4;   
//
  
return(0);
}
/* ***************************************************************** */
int deinit() {

  ObjectsDeleteAll(subwin,0);
return(0);
}
   
/* ***************************************************************** */
int start() {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int position=limit-counted_bars-1;
   if (position<0) position=0;
//   position=limit;
   int rnglength =250;
  
   double range = 0.0, srange = 0.0;

   for (int pos = position; pos >=0; pos--) {
         
 /*         srange = 0.0;
         int j = 0;
 
         for (int i=0;i<rnglength;i++) {
            j++;
            int posr = pos + i;
            if (posr >= limit) break;
            
            srange = srange + (iHigh(Symbol(),0,posr)-iLow(Symbol(),0,posr));
         }
         range = srange / j * Length;
 range=iStdDev(NULL,0,20,0,0,0,pos)* Length;
		
*/	 		
		range=iATR(NULL,0,50,pos)* Length;

      int BarNumber = limit-pos;
      if (BarNumber < 0) BarNumber = 0;

		ma_price = tpssf(pos);

      if (BarNumber <= 1){
         scope_a = range;   
         price_buy_a1  = ma_price;
         price_sell_a1  = ma_price;
		}

/* ***************************************************************** */

		if (BarNumber > 1){
			if (switch1 > -1){
				if (ma_price < price_buy_a1){
					if (buy_sw_a) {
					 MinorCycleBuy[pos +BarNumber - price_buy_b1] = 0;//***********************
					}
					price_buy_a1 = ma_price;
					price_buy_b1 = BarNumber;
					buy_sw_a = 1;
				}
				else if (ma_price > price_buy_a1){
					switch3 = BarNumber - price_buy_b1;
					MinorCycleBuy[pos +switch3] = -1;//***********************
					buy_sw_a = 1;
					double cyclePrice1 = tpssf(pos + switch3);
					if (status) status1 = ma_price - cyclePrice1 >= scope_a;
					else        status1 = ma_price >= cyclePrice1 * (1 + scope_a / 1000);
					if (status1 && switch3 >= direct){
						switch1 =  - 1;
						price_sell_a1 = ma_price;
						price_sell_b1 = BarNumber;
						sell_sw_a = 0;
						buy_sw_a = 0;
					}
            }
         }
			if(switch1 < 1){
				if (ma_price > price_sell_a1){
					if (sell_sw_a )  {
					 MinorCycleSell[pos +BarNumber - price_sell_b1] = 0;//***********************
					}
					price_sell_a1 = ma_price;
					price_sell_b1 = BarNumber;
					sell_sw_a = 1;
				}
				else if (ma_price < price_sell_a1){
					switch3 = BarNumber - price_sell_b1;
					MinorCycleSell[pos +switch3] = 1;//***********************
					sell_sw_a = 1;
					double cyclePrice2 = tpssf(pos + switch3);
					if (status) status1 = (cyclePrice2 - ma_price) >= scope_a;
					else        status1 = ma_price <= (cyclePrice2 * (1 - scope_a / 1000));
					if (status1 && switch3 >= direct){
						switch1 = 1;
						price_buy_a1 = ma_price;
						price_buy_b1 = BarNumber;
						sell_sw_a = 0;
						buy_sw_a = 0;
					}
				}
			}
		}
      MinorCycleBuy[pos] = 0;
      MinorCycleSell[pos] = 0; 
     
/* ***************************************************************** */
		if (BarNumber == 1){
			scope_b = range *  mcs;
			price_buy_a2 = ma_price;
			price_sell_a2 = ma_price;
		}
		if (BarNumber > 1){
			if (switch2  >  - 1){
				if (ma_price < price_buy_a2){
					if (buy_sw_b )  {
					 MajorCycleBuy[pos +BarNumber - price_buy_b2] = 0; //******************************
					}
					price_buy_a2 = ma_price;
					price_buy_b2 = BarNumber;
					buy_sw_b = 1;
				}
				else if (ma_price > price_buy_a2){
					switch4 = BarNumber - price_buy_b2;
					MajorCycleBuy[pos +switch4] = -1; //***********************
					buy_sw_b = 1;
					double cyclePrice3 = tpssf(pos + switch4);
					if (status) status2 = ma_price - cyclePrice3 >= scope_b;
					else        status2 = ma_price >= cyclePrice3 * (1 + scope_b / 1000);
					if (status2 && switch4 >= direct){
						switch2 =  - 1;
						price_sell_a2 = ma_price;
						price_sell_b2 = BarNumber;
						sell_sw_b = 0;
						buy_sw_b = 0;
					}
				}
			}

			if (switch2  < 1){
				if (ma_price  > price_sell_a2 ){
					if (sell_sw_b) {
					 MajorCycleSell[pos +BarNumber - price_sell_b2] = 0;//***********************
					}
					price_sell_a2 = ma_price;
					price_sell_b2 = BarNumber;
					sell_sw_b = 1;
				}
				else if (ma_price < price_sell_a2){
					switch4 = BarNumber - price_sell_b2 ;
					MajorCycleSell[pos + switch4] = 1;//***********************
					sell_sw_b = 1;
					double cyclePrice4 = tpssf(pos + switch4);
					if (status) status2 = cyclePrice4 - ma_price >= scope_b;
					else        status2 = ma_price <= cyclePrice4 * (1.0 - scope_b / 1000.0);
					if (status2 && switch4 >= direct){
						switch2 = 1;
						price_buy_a2 = ma_price;
						price_buy_b2 = BarNumber;
						sell_sw_b = 0;
						buy_sw_b = 0;
					}
				}
			}
		}
      MajorCycleSell[pos] = 0;
		MajorCycleBuy[pos] = 0;

   } // for position

//====================================================================== 
  for (pos=position;pos>=0;pos--) {
  		major=0;
  		minor=0;    
		major = (MajorCycleBuy[pos] + MajorCycleSell[pos]);
      if (MathAbs(major)==1) trend[pos]=major*(-1);
      else trend[pos]=trend[pos+1];
      minor = (MinorCycleBuy[pos] + MinorCycleSell[pos])*(-1);    
      sign[pos]=minor*(trend[pos]==minor);

      if(show_lines) {
      	string timestamp=TimeToStr(Time[pos]);
      	if (trend[pos]==1)
         	{
         	if (sign[pos] == 1 &&  sign[pos+1]<=0)
               	{
               	if (ObjectFind("BBBuy "+timestamp)==-1) 
                  	{
                  	ObjectCreate("BBBuy "+timestamp,0,0,iTime(Symbol(),0,pos),0);
                  	ObjectSet("BBBuy "+timestamp,OBJPROP_COLOR,Aqua);
                  	ObjectSet("BBBuy "+timestamp,OBJPROP_BACK,true);
                  	}
               	}
            	else {ObjectDelete("BBBuy "+timestamp); WindowRedraw();}
         	}         
      
      	if (trend[pos]==-1 && sign[pos+1] >=0)
         	{
          	if (sign[pos] ==-1)
               	{         
               	if (ObjectFind("BBSell "+timestamp)==-1) 
                  	{
                  	ObjectCreate("BBSell "+timestamp,0,0,iTime(Symbol(),0,pos),0);
                  	ObjectSet("BBSell "+timestamp,OBJPROP_COLOR,Red);
                  	ObjectSet("BBSell "+timestamp,OBJPROP_BACK,true);
                  	}
               	}
           	else {ObjectDelete("BBSell "+timestamp); WindowRedraw();}
         	}
      }
      MinorCycleBuy[pos] = 0;
      MinorCycleSell[pos] = 0; 
      MajorCycleSell[pos] = 0;
		MajorCycleBuy[pos] = 0;            
	} // for

return(0);
}
//=====================================================================
		  
double tpssf(int pos) {
	smooth[pos] = k1 * (iOpen(NULL,0,pos) + iClose(NULL,0,pos)) / 2.0 +
                 k2 * smooth[pos + 1] + 
                 k3 * smooth[pos + 2] +
                 k4 * smooth[pos + 3];
	if (pos > Bars - 4) {
		smooth[pos] = (iOpen(NULL,0,pos) + iClose(NULL,0,pos)) / 2.0;
	}
return(smooth[pos]);	
}

