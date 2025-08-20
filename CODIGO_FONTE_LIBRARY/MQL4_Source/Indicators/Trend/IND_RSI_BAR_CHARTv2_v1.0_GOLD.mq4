//+------------------------------------------------------------------+
//|                                           GH-RSI BAR CHART       |      
//|                             Copyright c 2009, Godfreyh@gmail.com |
//|                                  REFRESH ISSUES FIXED BY Obaidah |
//|  ->>>>>   Free eas and indicators: https://t.me/simpleforextools |
//+------------------------------------------------------------------+
//| take care that this indicator doesnt resize the trendline in the 
//|indicator window, for that reason,if you run that in real time 
//|(before the bar close), it will give you different high/low than 
//|when you run it after the bar close
//+-------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4

extern 	color 	OneColor = Blue,
				      UpColor = DodgerBlue,
			      	DnColor = Red;



extern 	bool UseOneColor = false;
extern int RSI_Period =14;

//----

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators

IndicatorBuffers(4); 

//   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, ExtMapBuffer1);//high/low buffer
//   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, ExtMapBuffer2); //high/low buffer
//   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2, ExtMapBuffer3); //open buffer
//   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3, ExtMapBuffer4);// close buffer
//----
//---- indicator buffers mapping
	IndicatorShortName("GH RSI BAR CHARTv2"); 

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
  ObjectsDeleteAll(); 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   // take care that this indicator doesnt resize the trendline in the indicator window, for that reason, 
   //if you run that in real time (before the bar close), it will give you different high/low than when you run it 
   //after the bar close
   double rsiOpen, rsiHigh, rsiLow, rsiClose;
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for isible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   int i=Bars-ExtCountedBars-1; // when Bars increases by 1 i will be 1, in the next time extcountedbars will 
   //increase by one and i will be equal to 0, when a new bar comes the value of Bars will increase by one and so,
   //the value of i will be 1 again
   while(i>=0)
     {
      rsiOpen= iRSI(NULL,0,RSI_Period,PRICE_OPEN,i);
      rsiClose=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
      rsiHigh= iRSI(NULL,0,RSI_Period,PRICE_HIGH,i);
      rsiLow=  iRSI(NULL,0,RSI_Period,PRICE_LOW,i);
    
      if (rsiOpen<rsiClose) 
        {
         ExtMapBuffer1[i]=rsiLow;
         ExtMapBuffer2[i]=rsiHigh;
        } 
      else
        {
         ExtMapBuffer1[i]=rsiHigh;
         ExtMapBuffer2[i]=rsiLow;
        } 
      ExtMapBuffer3[i]=rsiOpen;
      ExtMapBuffer4[i]=rsiClose;
 	   
 	   
 	   		if(UseOneColor)//   double rsiOpen, rsiHigh, rsiLow, rsiClose;
		{
			drawLine("BB"+Time[i],Time[i],rsiOpen,rsiClose,3,OneColor); // Time[i] instead of i, for, during the real time 
			//calculating, the value of i will range between 1 and 0, so you'll have the same name for each new bar 
			//.... in the draw function it will skipe drawing new one because of the first if statement
			//So we had to assine something uniqe to the name of the line, which is the time of that bar.
			drawLine("SB"+Time[i],Time[i],rsiHigh,rsiLow,1,OneColor);
		}

 		else
		{	
			if(rsiClose<rsiOpen)
			{
				drawLine("BB"+Time[i],Time[i],rsiOpen,rsiClose,3,DnColor);
				drawLine("SB"+Time[i],Time[i],rsiHigh,rsiLow,1,DnColor);
			}
			else
			{
				drawLine("BB"+Time[i],Time[i],rsiOpen,rsiClose,3,UpColor);
				drawLine("SB"+Time[i],Time[i],rsiHigh,rsiLow,1,UpColor);
			}			
		}			
	   
 	   
 	   
 	   
 	   i--;
     }
     
     
//----
   return(0);
  }
  
  
//----  
  
  
void drawLine(string name,datetime time, double pfrom, double pto, int width,color Col)
{
         if(ObjectFind(name) != 0)
         {
            ObjectCreate(name, OBJ_TREND, WindowFind("GH RSI BAR CHARTv2"), time, pfrom,time,pto);
            ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(name, OBJPROP_COLOR, Col);
            ObjectSet(name,OBJPROP_WIDTH,width);
            ObjectSet(name,OBJPROP_RAY,0);
         }
         else
         {
            ObjectDelete(name);
            ObjectCreate(name, OBJ_TREND, WindowFind("GH RSI BAR CHARTv2"), time, pfrom,time,pto);
            ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(name, OBJPROP_COLOR, Col);        
            ObjectSet(name,OBJPROP_WIDTH,width);
            ObjectSet(name,OBJPROP_RAY,0);
          
         }
}  
  
  
  
  
  
  
  
  
  
  
  
  
//+------------------------------------------------------------------+