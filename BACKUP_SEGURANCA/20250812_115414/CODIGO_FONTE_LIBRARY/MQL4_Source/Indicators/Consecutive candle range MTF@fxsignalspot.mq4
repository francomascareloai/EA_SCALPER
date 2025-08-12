//+------------------------------------------------------------------+
//|                                     Consecutive candle range.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red

extern int timeFrame = 0;
extern color Bullish = Blue;
extern color Bearish = Red;
extern int Extend=50;

extern int Period=5;
extern int ArrowSize=2;

double UpArrow[], DnArrow[];
double Count[];

int init()
  {
   timeFrame = MathMax(timeFrame,Period());
    IndicatorBuffers(3);
    IndicatorShortName("ConsecutiveCandleRangeLine");
   
    SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
    SetIndexArrow(0,233);
    SetIndexBuffer(0,UpArrow);
    SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
    SetIndexArrow(1,234);
    SetIndexBuffer(1,DnArrow);
	

    SetIndexBuffer(2,Count);
	

   return(0);
  }
  
  int deinit()
  {
  
  ObjectsDeleteAll(0, OBJ_TREND);
  ObjectsDeleteAll(0, OBJ_ARROW);

  
   return(0);
  }
  
  


void DrawARROW(int pos,int Flag ,double Price)
{
 
   
     if(Flag==1) UpArrow[pos]=Price ;
      
      if(Flag==-1)  DnArrow[pos]=Price ;
    
    
    
 return;
}  

int start()
{
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         int limit = Bars-2;
         int pos   = MathMin(Bars-counted_bars,Bars-1);

         if (timeFrame!=Period())
         {
            pos = MathMin(MathMax(pos,2*timeFrame/Period()),Bars-1);
            for (;pos>=0; pos--)
            {
               UpArrow[pos] = EMPTY_VALUE;
               DnArrow[pos] = EMPTY_VALUE;
                  int y = iBarShift(NULL,timeFrame,Time[pos  ]);
                  int x = iBarShift(NULL,timeFrame,Time[pos+1]);
                  if (x!=y)
                  {
                     UpArrow[pos] = iCustom(NULL,timeFrame,WindowExpertName(),0,Bullish,Bearish,Extend,Period,ArrowSize,0,y);
                     DnArrow[pos] = iCustom(NULL,timeFrame,WindowExpertName(),0,Bullish,Bearish,Extend,Period,ArrowSize,1,y);
                  }
            }
            return(0);
         }
 while(pos>=0)
 { 
 
       if (pos==limit-1)
	   {
	   Count[pos+1]=pos+1;
	   }
     
       Count[pos]=Count[pos+1];
	  
	   
	  x= Count[pos+1];
  
	  if (Close[pos]>Open[pos]  && Close[x]<Open[x]  )
	  { 
	   
		Count[pos]=pos; 	
		  
	  }
	  
	  if (Close[pos]<Open[pos] && Close[x]>Open[x]   )
	  {
	        
	         
				Count[pos]=pos;
			   
	   
	  }
	  


     pos--;
  
 } 
 
 
  pos=limit-1;
 while(pos>=1)
 { 
   UpArrow[pos] = EMPTY_VALUE;
   DnArrow[pos] = EMPTY_VALUE;
 
          if  ((Count[pos]-pos+1) >= Period  && Count[pos-1]== pos-1 ) 
		{
		  
		        x=Count[pos];
				
            ObjectDelete(""+Time[pos]);
            ObjectDelete(""+Time[x]);
				if (Close[pos] >Open[pos] )
				{
				 DrawARROW(pos,-1, High[pos]);
				 DrawARROW(x,1, Low[x]);
				 DrawLine(pos, true);
				  DrawLine(x,  false);
				 
				 }
				 
				 if (Close[pos] <Open[pos] )
				{
				DrawARROW(x,-1, High[x]);
				 DrawARROW(pos,1, Low[pos]);
				 
				 DrawLine(x, true);
				  DrawLine(pos, false);
				 }
		}
 

     pos--;
  
 } 
 
   
 return(0);
}


void DrawLine(int First, bool BullFl)
{
  string ObjName=Time[First];
 int WindowNumber=0;
  if (ObjectFind(ObjName)==-1)
 		 {
		//  WindowNumber=WindowFind("ConsecutiveCandleRangeLine");
		//  WindowNumber=0;
				  if (WindowNumber!=-1)
				  {

				  int x= MathMax((First-Extend), 0);
						   if (BullFl)
						   {
							   ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], High[First], Time[x], High[First]);
							 
						   ObjectSet(ObjName, OBJPROP_RAY, false);
						     ObjectSet(ObjName, OBJPROP_COLOR, Bullish);
							 // ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[First], High[First]);
							 //  ObjectSet(ObjName+"A", OBJPROP_COLOR, Bullish);
							    // ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 242);
						 
						   }
						   else
						   {
							  ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], Low[First], Time[x], Low[First]);							
						   ObjectSet(ObjName, OBJPROP_RAY, false);
						     ObjectSet(ObjName, OBJPROP_COLOR, Bearish);
							 //ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[First], Low[First]);
							  // ObjectSet(ObjName+"A", OBJPROP_COLOR, Bearish);
							   //  ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 241);
						   } 
				  
				  } 
  }
		 
		  return;
} 

