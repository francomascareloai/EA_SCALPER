// FX 3 MA
#property copyright "Copyright © 2012,Yarik INC"
#property link      "Jungle999@mail.ru"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Blue
#property indicator_color4 Yellow
#property indicator_color5 Lime

           
double buffer1[];
double buffer2[];
double buffer3[];
double MA1buffer[];
double MA2buffer[];
double MA_sUP[];
double MA_sDN[];



extern int period=10;
extern int price=0; // 0 or other = (H+L)/2
                    // 1 = Open
                    // 2 = Close
                    // 3 = High
                    // 4 = Low
                    // 5 = (H+L+C)/3
                    // 6 = (O+C+H+L)/4
                    // 7 = (O+C)/2
extern bool Mode_Fast= False;
extern bool Signals= False;
extern int MA1period=9, MA2period=45;
extern string TypeHelp = "SMA- 0, EMA - 1, SMMA - 2, LWMA- 3";
extern string TypeHelp2 = "John Hyden settings TypeMA1=0, TypeMA2=3";
extern int TypeMA1=0;
extern int TypeMA2=3;

extern int SignalBar = 1; //Проверка сигнала на баре. 0 - на открытом баре, > 0 - на закрытых. 
extern int NumLine = 1; //Номер линии со стрелками
extern int  widthSimbol = 1;   //Толщина символа
extern int  indexSymbolUp = 233; //241 //Код символа buy
extern int  indexSymbolDn = 234; //242 //Код символа sell                           

      
int init()
  {
  SetIndexBuffer(0,buffer1);
  SetIndexBuffer(1,buffer2);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexLabel(2,"line");
  SetIndexBuffer(2,buffer3);
  SetIndexStyle(3,DRAW_LINE);
  SetIndexLabel(3,"MA1 "+MA1period);
  SetIndexStyle(4,DRAW_LINE);
  SetIndexLabel(4,"MA2 "+MA2period);
  SetIndexBuffer(3,MA1buffer);
  SetIndexBuffer(4,MA2buffer);
  
  SetIndexBuffer(5,MA_sUP);
  SetIndexStyle(5,DRAW_ARROW, EMPTY, widthSimbol, Blue);
  SetIndexArrow(5,indexSymbolUp);
  SetIndexBuffer(6,MA_sDN);
  SetIndexStyle(6,DRAW_ARROW, EMPTY, widthSimbol, Red);
  SetIndexArrow(6,indexSymbolDn);
  
  return(0);
  }


int deinit()
  {
  int i;
  double tmp;
  
  
  for (i=0;i>Bars;i++)
    {
    ObjectDelete("SELL SIGNAL: "+DoubleToStr(i,0));
    ObjectDelete("BUY SIGNAL: "+DoubleToStr(i,0));
    ObjectDelete("EXIT: "+DoubleToStr(i,0));
    }
  return(0);
  }


double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;

int buy=0,sell=0;

int start()
  {
  int counted_bars=IndicatorCounted();
  int i;
  int barras;
  double _price;
  double tmp;
  
  double MinL=0;
  double MaxH=0;                    
  
  double Threshold=1.2; 

  if(counted_bars>0) counted_bars--;

  //barras = Bars;з
  barras = Bars-counted_bars;
  if (Mode_Fast)
    barras = 100;
  i = 0;
  while(i<barras)
   {
   MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
   MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
  
   switch (price)
     {
     case 1: _price = Open[i]; break;
     case 2: _price = Close[i]; break;
     case 3: _price = High[i]; break;
     case 4: _price = Low[i]; break;
     case 5: _price = (High[i]+Low[i]+Close[i])/3; break;
     case 6: _price = (Open[i]+High[i]+Low[i]+Close[i])/4; break;
     case 7: _price = (Open[i]+Close[i])/2; break;
     default: _price = (High[i]+Low[i])/2; break;
     }
   
        
   Value = 0.33*2*((_price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
   Value=MathMin(MathMax(Value,-0.999),0.999); 
   Fish = 0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
   
   buffer1[i]= 0;
   buffer2[i]= 0;
   
   if ( (Fish<0) && (Fish1>0)) 
     {
     if (Signals)
       {
       ObjectCreate("EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
       ObjectSetText("EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),7,"Arial",White);
       }
     buy = 0;
     }   
   if ((Fish>0) && (Fish1<0))
     {
     if (Signals)
       {
       ObjectCreate("EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
       ObjectSetText("EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),7,"Arial",White);
       }
     sell = 0;
     }        
    
   if (Fish>=0)
     {
     buffer1[i] = Fish;
     buffer3[i]= Fish;
     }
   else
     {
     buffer2[i] = Fish;  
     buffer3[i]= Fish;
     }
     
   tmp = i;
   if ((Fish<-Threshold) && 
       (Fish>Fish1) && 
       (Fish1<=Fish2))
     {     
     if (Signals)
       {
       ObjectCreate("SELL SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
       ObjectSetText("SELL SIGNAL: "+DoubleToStr(i,0),"SELL AT "+DoubleToStr(_price,4),7,"Arial",Red);
       }
     sell = 1;
     }

  if ((Fish>Threshold) && 
       (Fish<Fish1) && 
       (Fish1>=Fish2))
    {
    if (Signals)
       {
       ObjectCreate("BUY SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
       ObjectSetText("BUY SIGNAL: "+DoubleToStr(i,0),"BUY AT "+DoubleToStr(_price,4),7,"Arial",Lime);
       }
    buy=1;
    }

   Value1 = Value;
   Fish2 = Fish1;  
   Fish1 = Fish;
 
   i++;
   }
   
   for(i=0; i<barras; i++)
    MA1buffer[i]=iMAOnArray(buffer3,Bars,MA1period,0,TypeMA1,i);
   for(i=0; i<barras; i++)
    MA2buffer[i]=iMAOnArray(MA1buffer,Bars,MA2period,0,TypeMA2,i);
   for(i=SignalBar; i<barras; i++) {
      if(NumLine <= 1 ||NumLine > 3) {
         if(buffer3[i] > 0 && buffer3[i+1] < 0) MA_sUP[i] = buffer3[i];
         if(buffer3[i] < 0 && buffer3[i+1] > 0) MA_sDN[i] = buffer3[i];
      }
      if(NumLine == 2) {
         if(MA1buffer[i] > 0 && MA1buffer[i+1] < 0) MA_sUP[i] = MA1buffer[i];
         if(MA1buffer[i] < 0 && MA1buffer[i+1] > 0) MA_sDN[i] = MA1buffer[i];
      }
      if(NumLine == 3) {
         if(MA2buffer[i] > 0 && MA2buffer[i+1] < 0) MA_sUP[i] = MA2buffer[i];
         if(MA2buffer[i] < 0 && MA2buffer[i+1] > 0) MA_sDN[i] = MA2buffer[i];
      }
   }
  return(0);
  }
//+------------------------------------------------------------------+