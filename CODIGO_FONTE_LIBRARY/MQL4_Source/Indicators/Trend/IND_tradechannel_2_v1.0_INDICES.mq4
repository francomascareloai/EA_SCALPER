//+------------------------------------------------------------------+
//|                                                    Trade Channel |
//|                                             http://abc-forex.ru/ |
//+------------------------------------------------------------------+
#property copyright "---"
#property link      "http://abc-forex.ru/"
//----
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_color7 Black
#property indicator_color8 Black
//---- input parameters
extern int nLeft=50;
extern int nRight=50;
extern int filter=10;
//---- buffers
double UpBuffer[];
double DnBuffer[];
double f_2[];
double f_3[];
double f_4[];
double f_5[];
double f_6[];
//----
int draw_begin1=0, draw_begin2=0, d_b3=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   double nfUp;
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE,0,3);
   SetIndexStyle(1,DRAW_LINE,0,3);
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexStyle(3,DRAW_LINE,2);
   SetIndexStyle(4,DRAW_LINE,2);
   SetIndexStyle(5,DRAW_LINE,2);
   SetIndexStyle(6,DRAW_LINE,2);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,f_2);
   SetIndexBuffer(3,f_3);
   SetIndexBuffer(4,f_4);
   SetIndexBuffer(5,f_5);
   SetIndexBuffer(6,f_6);
//----
   string short_name;
   short_name="rvmFractalsLevel("+nLeft+","+nRight+","+filter+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Level ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(1,"Down Level ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(2,"f_2 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(3,"f_3 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(4,"f_4 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(5,"f_5 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(6,"f_6 ("+nLeft+","+nRight+","+filter+")");
//----
 /*  int n,k,i,Range=nLeft+nRight+1;
   for(n=Bars-1-nLeft;n>=nRight;n--)
     {
      if(draw_begin1==0)
        {
         if(High[n]>=High[Highest(NULL,0,MODE_HIGH,Range,n-nRight)])
           {
            int fRange=nvnLeft(n,nLeft)+nvnRight(n,nRight)+1;
            if(High[n]>=High[Highest(NULL,0,MODE_HIGH,fRange,n-nvnRight(n,nRight))])
              {
               draw_begin1=Bars-n;
               for(i=Bars-1;i>draw_begin1;i--)
                 {
                  UpBuffer[i]=High[Bars-draw_begin1];
                 }
              }
           }
        }
      if(draw_begin2==0)
        {
         if(Low[n]<=Low[Lowest(NULL,0,MODE_LOW,Range,n-nRight)])
           {
            fRange=nvnLeft(n,nLeft)+nvnRight(n,nRight)+1;
            if(Low[n]<=Low[Lowest(NULL,0,MODE_HIGH,fRange,n-nvnRight(n,nRight))])
              {
               draw_begin2=Bars-n;
               for(i=Bars-1;i>draw_begin2;i--)
                 {
                  DnBuffer[i]=Low[Bars-draw_begin2];
                 }
              }
           }
        }
      if(draw_begin1>0&&draw_begin2>0) break;
     }
    
//----
   if(draw_begin1>draw_begin2)
     {
      d_b3=draw_begin1;
     }
   else
     {
      d_b3=draw_begin2;
     }*/ 
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
   SetIndexDrawBegin(2,d_b3);
   SetIndexDrawBegin(3,d_b3);
   SetIndexDrawBegin(4,d_b3);
   SetIndexDrawBegin(5,d_b3);
   SetIndexDrawBegin(6,d_b3);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double UpStage=0.0,DnStage=0.0;
   int i,j,fRange,Range=nLeft+nRight+1;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+nLeft;
      
//---- 
   for(i=limit;i>=nRight;i--)
     {
      if(High[i]>=High[Highest(NULL,0,MODE_HIGH,Range,i-nRight)])
        {
         fRange=nvnLeft(i,nLeft)+nvnRight(i,nRight)+1;
         if(High[i]>=High[Highest(NULL,0,MODE_HIGH,fRange,i-nvnRight(i,nRight))])
           {
            UpStage=High[i];
           }
         else
           {
            if(High[i]<=UpBuffer[i+1])
              {
               UpStage=UpBuffer[i+1];
              }
            else
              {
               UpStage=nfUp(i);
              }
           }
        }
      else
        {
         if(High[i]<=UpBuffer[i+1])
           {
            UpStage=UpBuffer[i+1];
           }
         else
           {
            UpStage=nfUp(i);
           }
        }
      if(Low[i]<=Low[Lowest(NULL,0,MODE_LOW,Range,i-nRight)])
        {
         fRange=nvnLeft(i,nLeft)+nvnRight(i,nRight)+1;
         if(Low[i]<=Low[Lowest(NULL,0,MODE_HIGH,fRange,i-nvnRight(i,nRight))])
           {
            DnStage=Low[i];
           }
         else
           {
            if(Low[i]>=DnBuffer[i+1])
              {
               DnStage=DnBuffer[i+1];
              }
            else
              {
               DnStage=nfDn(i);
              }
           }
        }
      else
        {
         if(Low[i]>=DnBuffer[i+1])
           {
            DnStage=DnBuffer[i+1];
           }
         else
           {
            DnStage=nfDn(i);
           }
        }
      UpBuffer[i]=UpStage;
      DnBuffer[i]=DnStage;
//----
      f_2[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
      f_3[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
      f_4[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
      f_5[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
      f_6[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4);
     }
   for(i=nRight-1;i>=0;i--)
     {
      if(High[i]<=UpBuffer[i+1])
        {
         UpStage=UpBuffer[i+1];
        }
      else
        {
         UpStage=nfUp(i);
        }
      if(Low[i]>=DnBuffer[i+1])
        {
         DnStage=DnBuffer[i+1];
        }
      else
        {
         DnStage=nfDn(i);
        }
      UpBuffer[i]=UpStage;
      DnBuffer[i]=DnStage;
//----
      f_2[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
      f_3[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
      f_4[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
      f_5[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
      f_6[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4);
     }
//---- построение веера Фибоначчи
   double LastUp, LastDn, st_h, st_l, st_3, y1, y2, y3;
   int tmp, x1=0, x2=0, x3=0, cb, dn_x, up_x;
   string fibo="Fibo 1", fibo2="Fibo 2";
   LastDn=DnBuffer[0];
   for(cb=1;cb<=Bars-1;cb++)
     {
      if(tmp!=1 && LastDn>DnBuffer[cb])
        {
         tmp=1;
         continue;
        }
      if(tmp==1 && DnBuffer[cb]>DnBuffer[cb-1])
        {
         tmp=0;
         dn_x=cb-1;
         break;
        }
     }
   LastUp=UpBuffer[0];
   for(cb=1;cb<=Bars-1;cb++)
     {
      if(tmp!=1 && LastUp<UpBuffer[cb])
        {
         tmp=1;
         continue;
        }
      if(tmp==1 && UpBuffer[cb]<UpBuffer[cb-1])
        {
         tmp=0;
         up_x=cb-1;
         break;
        }
     }
   st_h=High[Highest(NULL,0,MODE_HIGH,MathMax(dn_x,up_x),0)];
   st_l=Low[Lowest(NULL,0,MODE_LOW,MathMax(dn_x,up_x),0)];
   for(cb=MathMax(dn_x,up_x)-1;cb>=0;cb--)
     {
      if(High[cb]==st_h || Low[cb]==st_l)
        {
         if(High[cb]==st_h && (x1==0 || x2==0) )
           {
            if(x1==0)
              {
               x1=cb;
               y1=High[x1];
               continue;
              }
            else
              {
               x2=cb;
               y2=High[x2];
               break;
              }
           }
         else
           {
            if(x1==0)
              {
               x1=cb;
               y1=Low[x1];
               continue;
              }
            else
              {
               x2=cb;
               y2=Low[x2];
               break;
              }
           }
        }
     }
   if(ObjectFind(fibo)!=-1 )
     {
      ObjectSet(fibo,OBJPROP_TIME1,Time[x1]);
      ObjectSet(fibo,OBJPROP_PRICE1,y1);
      ObjectSet(fibo,OBJPROP_TIME2,Time[x2]);
      ObjectSet(fibo,OBJPROP_PRICE2,y2);
     }
   else
     {
      ObjectCreate(fibo,OBJ_FIBOFAN,0,Time[x1],y1,Time[x2],y2);
      ObjectSet(fibo,OBJPROP_COLOR,DodgerBlue);
      ObjectSet(fibo,OBJPROP_STYLE,STYLE_DOT);
     }
   if(y2>y1)
     {
      st_3=Low[Lowest(NULL,0,MODE_LOW,x2,0)];
     }
   else
     {
      st_3=High[Highest(NULL,0,MODE_HIGH,x2,0)];
     }
   for(cb=0;cb<x2;cb++)
     {
      if(y2>y1 && Low[cb]==st_3)
        {
         x3=cb;
         y3=Low[cb];
         break;
        }
      else
        {
         if(y2<y1 && High[cb]==st_3)
           {
            x3=cb;
            y3=High[cb];
            break;
           }
        }
     }
   if(ObjectFind(fibo2)!=-1 )
     {
      ObjectSet(fibo2,OBJPROP_TIME1,Time[x2]);
      ObjectSet(fibo2,OBJPROP_PRICE1,y2);
      ObjectSet(fibo2,OBJPROP_TIME2,Time[x3]);
      ObjectSet(fibo2,OBJPROP_PRICE2,y3);
     }
   else
     {
      ObjectCreate(fibo2,OBJ_FIBOFAN,0,Time[x2],y2,Time[x3],y3);
      ObjectSet(fibo2,OBJPROP_COLOR,Red);
      ObjectSet(fibo2,OBJPROP_STYLE,STYLE_DOT);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
double nfUp(int i)
  {
   int l,flag=0;
   double Price=0.0;
//----------
   for(l=i+1;l<Bars-draw_begin1-1;l++)
     {
      if(filter>0)
        {
         if(Close[i]<=UpBuffer[l]+(UpBuffer[l]-DnBuffer[l])*filter/100)
           {
            Price=UpBuffer[l];
            flag=1;
           }
        }
      else
        {
         if(High[i]<=UpBuffer[l])
           {
            Price=UpBuffer[l];
            flag=1;
           }
        }
      if(Price>0) break;
     }
   if(flag==0) Price=High[i];
//----
   return(Price);
  }
//+------------------------------------------------------------------+
double nfDn(int i)
  {
   int l,flag=0;
   double Price=0.0;
//----------
   for(l=i+1;l<Bars-draw_begin2-1;l++)
     {
      if(filter>0)
        {
         if(Close[i]>=DnBuffer[l]-(UpBuffer[l]-DnBuffer[l])*filter/100)
           {
            Price=DnBuffer[l];
            flag=1;
           }
        }
      else
        {
         if(Low[i]>=DnBuffer[l])
           {
            Price=DnBuffer[l];
            flag=1;
           }
        }
      if(Price>0) break;
     }
   if(flag==0) Price=Low[i];
//----
   return(Price);
  }
//+------------------------------------------------------------------+
int nvnLeft(int i,int n)
  {
   int k=0,l;
   for(l=i+1;l<Bars-1;l++)
     {
      if(High[l]<High[l+1]&&Low[l]>Low[l+1]) continue;
      k++;
      if(k==n)
        {
         k=l-i;
         break;
        }
     }
//----
   return(k);
  }
//+------------------------------------------------------------------+
int nvnRight(int i,int n)
  {
   int k=0,l;
   for(l=i-1;l>=0;l--)
     {
      if(High[l]<High[l+1]&&Low[l]>Low[l+1]) continue;
      k++;
      if(k==n)
        {
         k=i-l;
         break;
        }
     }
//----
   return(k);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   string fibo="Fibo 1", fibo2="Fibo 2";
   ObjectDelete(fibo);
   ObjectDelete(fibo2);
//----
   return(0);
  }
//+------------------------------------------------------------------+