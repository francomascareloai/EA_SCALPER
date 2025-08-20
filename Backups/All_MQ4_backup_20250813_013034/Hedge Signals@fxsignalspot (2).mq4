//+------------------------------------------------------------------+
//|                                                                  |
//|                                                Hedge Signals.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Hedge Signals for Scalping - Kasparek Jiri"
#property link      "http://www.goldaxrocket.com"


#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 Lime 
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

#property indicator_color2 Red
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID


bool _enableAlert=true;
//-------



double _lotSizeDefault=0;
//-------
double _buySignal[];
double _sellSignal[];
double _lotSize[];

double _pipsMultiplyer=1;


int init()
{
   
   Comment("Hedge Signal" );  
  _lotSizeDefault=MarketInfo(Symbol(),MODE_MINLOT);  

   IndicatorBuffers(3);    
   SetIndexBuffer(0,_buySignal);
   SetIndexBuffer(1,_sellSignal);
   SetIndexBuffer(2,_lotSize);   
 
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_NONE);

   SetIndexLabel(0,"Buy");
   SetIndexLabel(1,"Sell");
   SetIndexLabel(2,"Lot");

   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   if(Digits == 2 || Digits == 4) {
      _pipsMultiplyer = 1;
   } else {
      if(Digits == 3 || Digits == 5) {
         _pipsMultiplyer = 10;
      }
   }
   return(0);
}

int deinit()
{
   return(0);
}

bool IsCrossUp(double lineX0, double lineX1, double lineY0, double lineY1){
   if(lineX1<lineY1 && lineX0>lineY0){
      return (true);
   }
   return (false);
}
bool IsCrossDown(double lineX0, double lineX1, double lineY0, double lineY1){
   if(lineX1>lineY1 && lineX0<lineY0){
      return (true);
   }
   return (false);
}

bool IsPointingUp(double lineX0, double lineX1){
   if(lineX1<lineX0){
      return (true);
   }
   return (false);
}
bool IsPointingDown(double lineX0, double lineX1){
   if(lineX1>lineX0){
      return (true);
   }
   return (false);
}

bool IsAbove(double lineX0, double lineY0){
   if(lineX0>lineY0){
      return (true);
   }
   return (false);
}
bool IsBelow(double lineX0, double lineY0){
   if(lineX0<lineY0){
      return (true);
   }
   return (false);
}

bool IsMaximum(double lineX0, double lineX1, double lineX2){
   if(lineX0<lineX1 && lineX1>lineX2){
      return (true);
   }
   return (false);
}
bool IsMinimum(double lineX0, double lineX1, double lineX2){
   if(lineX0>lineX1 && lineX1<lineX2){
      return (true);
   }
   return (false);
}

bool IsBuySignal(int i){
   bool result=true;
   
if(!Condition1(i)){
    result=false; 
}
if(!Condition2(i)){
    result=false; 
}
if(!Condition3(i)){
    result=false; 
}

   return (result);
}
bool IsSellSignal(int i){
   bool result=true;
   
if(!Condition4(i)){
    result=false; 
}
if(!Condition5(i)){
    result=false; 
}
if(!Condition6(i)){
    result=false; 
}
 
   return (result);  
}

int start()
{
   double visualAddition= 3*_pipsMultiplyer*Point;
   int    counted_bars=IndicatorCounted();
   if(Bars<=100) {return(0);}
   int i=Bars-counted_bars-1;
   while(i>=0)
   {
      _buySignal[i]=EMPTY_VALUE;
      _sellSignal[i]=EMPTY_VALUE;
      _lotSize[i]=_lotSizeDefault;
      if(IsBuySignal(i)){
         _buySignal[i]=iLow(Symbol(),Period(),i)-visualAddition;
         if(_enableAlert){
            if(i==1){
               Alert("BUY "+Symbol()+" "+Period());
            }
         }
      }
      if(IsSellSignal(i)){
         _sellSignal[i]=iHigh(Symbol(),Period(),i)+visualAddition;
         if(_enableAlert){
            if(i==1){
               Alert("SELL "+Symbol()+" "+Period());
            }
         }
      }         
      i--;
   }
   return(0);
}


   
bool Condition1(int i){
    bool result;
    double lineX0 = iMA(Symbol(),Period(),1,0,0,0,i+0);
    double lineX1 = iMA(Symbol(),Period(),1,0,0,0,i+1);
    double lineY0 = iMA(Symbol(),Period(),10,0,0,0,i+0);
    double lineY1 = iMA(Symbol(),Period(),10,0,0,0,i+1);
    result = IsCrossUp(lineX0,lineX1,lineY0,lineY1);
    return (result);

}
bool Condition2(int i){
    bool result;
    double lineX0 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 0, i+0);
    double lineX1 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 0, i+1);
    double lineY0 = 0;
    double lineY1 = 0;
    result = IsAbove(lineX0,lineY0);
    return (result);

}
bool Condition3(int i){
    bool result;
    double lineX0 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 1, i+0);
    double lineX1 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 1, i+1);
    double lineY0 = 0;
    double lineY1 = 0;
    result = IsAbove(lineX0,lineY0);
    return (result);

}
bool Condition4(int i){
    bool result;
    double lineX0 = iMA(Symbol(),Period(),1,0,0,0,i+0);
    double lineX1 = iMA(Symbol(),Period(),1,0,0,0,i+1);
    double lineY0 = iMA(Symbol(),Period(),10,0,0,0,i+0);
    double lineY1 = iMA(Symbol(),Period(),10,0,0,0,i+1);
    result = IsCrossDown(lineX0,lineX1,lineY0,lineY1);
    return (result);

}
bool Condition5(int i){
    bool result;
    double lineX0 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 0, i+0);
    double lineX1 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 0, i+1);
    double lineY0 = 0;
    double lineY1 = 0;
    result = IsBelow(lineX0,lineY0);
    return (result);

}
bool Condition6(int i){
    bool result;
    double lineX0 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 1, i+0);
    double lineX1 = iMACD(Symbol(), Period(), 12, 26, 9, 0, 1, i+1);
    double lineY0 = 0;
    double lineY1 = 0;
    result = IsBelow(lineX0,lineY0);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   return (result);}