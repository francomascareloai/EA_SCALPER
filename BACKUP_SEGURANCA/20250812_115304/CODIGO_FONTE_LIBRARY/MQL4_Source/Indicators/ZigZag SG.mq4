//+------------------------------------------------------------------+
//|                                                   ZigZag SG.mq4  |
//|                 Copyright © 2005-2007, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//| Based origially on work started by acerinvest of ForexFactory    |
//| Modified by stevegee58                                           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_width1 1
//---- indicator parameters
extern int ExtDepth       = 13;
extern int ExtDeviation   =  5;
extern int ExtBackstep    =  5;
//---- indicator buffers
double ZigzagBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];

int level=3; // recounting's depth 
bool downloadhistory=false;
double acehigh[];
double high;
double acelow[];
double low;

void PrintText (string text, string objName, double textColor, double row, double column)
{
   int rowHeight = 15;

   ObjectCreate( objName, OBJ_LABEL, 0, 0, 0 );
   ObjectSet( objName, OBJPROP_COLOR, textColor );
   ObjectSet( objName, OBJPROP_CORNER, 3 );
   ObjectSet( objName, OBJPROP_XDISTANCE, column );
   ObjectSet( objName, OBJPROP_YDISTANCE, row*rowHeight);
   ObjectSetText( objName, text, 10, "Terminal" );
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ZigzagBuffer);
   SetIndexBuffer(1,HighMapBuffer);
   SetIndexBuffer(2,LowMapBuffer);
   
   SetIndexEmptyValue(0,0.0);
   

//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
int deinit()
{
   int i;

   for (i=1;i<=3;i++)
   {
      ObjectDelete("item"+i);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  
   double vertices[10];
   double vertexPos[10];
   int vertexIndex;
  
    ObjectDelete("high");
    ObjectDelete("low");
  
   int i, counted_bars = IndicatorCounted();
   int limit,counterZ,whatlookfor;
   int shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   
   if (counted_bars==0 && downloadhistory) // history was downloaded
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
     }
   if (counted_bars==0) 
     {
      limit=Bars-ExtDepth;
      downloadhistory=true;
     }
   if (counted_bars>0) 
     {
      while (counterZ<level && i<100)
        {
         res=ZigzagBuffer[i];
         if (res!=0) counterZ++;
         i++;
        }
      i--;
      limit=i;
      if (LowMapBuffer[i]!=0) 
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      for (i=limit-1;i>=0;i--)  
        {
         ZigzagBuffer[i]=0.0;  
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
      
   for(shift=limit; shift>=0; shift--)
     {
      val=Low[iLowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[shift+back];
               if((res!=0)&&(res>val)) LowMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      if (Low[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=High[iHighest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[shift+back];
               if((res!=0)&&(res<val)) HighMapBuffer[shift+back]=0.0; 
              } 
           }
        }
      if (High[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

   // final cutting 
   if (whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for (shift=limit;shift>=0;shift--)
     {
      res=0.0;
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if (lastlow==0 && lasthigh==0)
              {
               if (HighMapBuffer[shift]!=0)
                 {
                  lasthigh=High[shift];
                  lasthighpos=shift;
                  whatlookfor=-1;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                  acehigh[i] = lasthigh;
                 }
               if (LowMapBuffer[shift]!=0)
                 {
                  lastlow=Low[shift];
                  lastlowpos=shift;
                  whatlookfor=1;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                  acelow[i] = lastlow;
                 }
              }
             break;  
         case 1: // look for peak
            if (LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if (HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=-1;
               res=1;
              }   
            break;               
         case -1: // look for lawn
            if (HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if (LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=1;
              }   
            break;               
         default: return; 
        }
     }

   vertexIndex = 0;
   for (i=0;i<Bars;i++)
   {
      if (ZigzagBuffer [i] != 0.0)
      {
         vertices [vertexIndex] = ZigzagBuffer [i];
         vertexPos [vertexIndex] = i;
         vertexIndex++;
         if (vertexIndex == 10)
         {
            break;
         }
      }
   }

   PrintText ("Last ZZ = "+DoubleToStr(MathAbs(vertices[1]-vertices[2])/Point,0)+" pips", "item1", Gray, 1, 50);
   
   if (vertices[1] > vertices [2])
   {
      high = vertices[1];
      lasthighpos = vertexPos[1];
      low = vertices[2];
      lastlowpos = vertexPos[2];
   }
   else
   {
      high = vertices[2];
      lasthighpos = vertexPos[2];
      low = vertices[1];
      lastlowpos = vertexPos[1];
   }

   ObjectCreate("high", OBJ_TREND, 0, Time[lasthighpos], high, Time[0],high);
   ObjectSet("high", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("high", OBJPROP_COLOR, Blue);                  
   ObjectSet("high", OBJPROP_WIDTH, 2);
   ObjectSet("high", OBJPROP_RAY, true); 
   ObjectSet("high", OBJPROP_BACK,true);

   ObjectCreate("low", OBJ_TREND, 0, Time[lastlowpos], low, Time[0],low);
   ObjectSet("low", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("low", OBJPROP_COLOR, Red);                  
   ObjectSet("low", OBJPROP_WIDTH, 2);
   ObjectSet("low", OBJPROP_RAY, true); 
   ObjectSet("low", OBJPROP_BACK,true);

   return(0);
}
//+------------------------------------------------------------------+