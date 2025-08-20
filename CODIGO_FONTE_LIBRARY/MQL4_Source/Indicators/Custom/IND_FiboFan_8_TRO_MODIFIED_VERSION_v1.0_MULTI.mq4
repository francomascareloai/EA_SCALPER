//+------------------------------------------------------------------+
//| FiboFan_8_TRO_MODIFIED_VERSION               FiboRetracement.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//|  FiboFan_8_TRO_MODIFIED_VERSION                                  |
//| MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM     |
//| I am NOT the ORIGINAL author 
//  and I am not claiming authorship of this indicator. 
//  All I did was modify it. I hope you find my modifications useful.|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


#property indicator_chart_window

#property indicator_buffers 0
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_color7 Black
#property indicator_color8 Black
//---- input parameters
extern int TimeFrame=0;
extern int nLeft=8;
extern int nRight=8;
extern int filter=10;


//extern int TimeFrame=60;
//extern int nLeft=50;
//extern int nRight=50;
//extern int filter=10;
extern color   Fibo1Color = Red;
extern int     Fibo1Width = 1;
extern int     Fibo1Style = 2;

extern color   Fibo2Color = Blue;
extern int     Fibo2Width = 1;
extern int     Fibo2Style = 2;

extern double  FibLevel1 = 0.236;
extern double  FibLevel2 = 0.382;
extern double  FibLevel3 = 0.500;
extern double  FibLevel4 = 0.618;
extern double  FibLevel5 = 0.764;

//---- buffers
double UpBuffer[];
double DnBuffer[];
double f_2[];
double f_3[];
double f_4[];
double f_5[];
double f_6[];

string fibo,fibo2;

//----
int draw_begin1=0, draw_begin2=0, d_b3=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   double nfUp;
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_NONE,0,3);
   SetIndexStyle(1,DRAW_NONE,0,3);
   SetIndexStyle(2,DRAW_NONE,2);
   SetIndexStyle(3,DRAW_NONE,2);
   SetIndexStyle(4,DRAW_NONE,2);
   SetIndexStyle(5,DRAW_NONE,2);
   SetIndexStyle(6,DRAW_NONE,2);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,f_2);
   SetIndexBuffer(3,f_3);
   SetIndexBuffer(4,f_4);
   SetIndexBuffer(5,f_5);
   SetIndexBuffer(6,f_6);

   fibo="Fibo "+TimeFrame;
   fibo2="Fibo2 "+TimeFrame;

//---- name for DataWindow and indicator subwindow label
   string short_name; //обявление переменной short_name типа "строковый"
   //переменной short_name присваиваем строковое значение равное выражению
  // short_name="rvmFractalsLevel("+nLeft+","+nRight+","+filter+")"; 
   short_name="Davo_LBR_FibFan("+nLeft+","+nRight+","+filter+")"; 
   IndicatorShortName(short_name); //для отображения на графике присвоим индикатору краткое
                                   //наименование
   //для отображения на графике присвоим метке отображающей значения 0 буфера имя Up Channel
   SetIndexLabel(0,"Up Level ("+nLeft+","+nRight+","+filter+")");
   //для отображения на графике присвоим метке отображающей значения 1 буфера имя Down Channel
   SetIndexLabel(1,"Down Level ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(2,"f_2 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(3,"f_3 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(4,"f_4 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(5,"f_5 ("+nLeft+","+nRight+","+filter+")");
   SetIndexLabel(6,"f_6 ("+nLeft+","+nRight+","+filter+")");

//---- Здесь определим начальные точки для прорисовки индикатора
   int n,k,i,Range=nLeft+nRight+1;
   //переберем свечки от (всего свечек минус минимум свечек слева) до (минимум свечек справа)
   for(n=iBars(NULL,TimeFrame)-1-nLeft;n>=nRight;n--)
   {
      //верхние фракталы
      //если начало отрисовки верхнего уровня не определено
      if(draw_begin1==0)
      {
      //текущая свеча максимум на локальном промежутке?
      if(iHigh(NULL,TimeFrame,n)>=iLow(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,Range,n-nRight)))
      {
         int fRange=nvnLeft(n,nLeft)+nvnRight(n,nRight)+1;
         //если она же - фрактал
         if(iHigh(NULL,TimeFrame,n)>=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,fRange,n-nvnRight(n,nRight))))
         {
            draw_begin1=iBars(NULL,TimeFrame)-n;//начало отрисовки верхнего уровня определено
            for(i=iBars(NULL,TimeFrame)-1;i>draw_begin1;i--)
            {
               UpBuffer[i]=iHigh(NULL,TimeFrame,iBars(NULL,TimeFrame)-draw_begin1);
            }
         }
      }//конец действий если if(iHigh(NULL,TimeFrame,n)>=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,Range,n-nRight))=истина
      }//конец условия if(draw_begin1==0)
      
      //нижние фракталы
      //если начало отрисовки нижнего уровня не определено
      if(draw_begin2==0)
      {
      //текущая свеча минимум на локальном промежутке?
      if(iLow(NULL,TimeFrame,n)<=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,Range,n-nRight)))
      {
         fRange=nvnLeft(n,nLeft)+nvnRight(n,nRight)+1;
         //если она же - фрактал
         if(iLow(NULL,TimeFrame,n)<=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_HIGH,fRange,n-nvnRight(n,nRight)))) 
         {
            draw_begin2=iBars(NULL,TimeFrame)-n;//начало отрисовки нижнего уровня определено
            for(i=iBars(NULL,TimeFrame)-1;i>draw_begin2;i--)
            {
               DnBuffer[i]=iLow(NULL,TimeFrame,iBars(NULL,TimeFrame)-draw_begin2);
            }
         }
      }//конец условия if(iLow(NULL,TimeFrame,n)<=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,Range,n-nRight)))=true
      }//конец условия if(draw_begin2==0)
      
      //если оба начала отрисовки уровней определены, выходим из цикла for(n=iBars(NULL,TimeFrame)-1-nLeft;n>=nRight;n--)
      if(draw_begin1>0&&draw_begin2>0) break;
   }//конец цикла for(n=iBars(NULL,TimeFrame)-1-nLeft;n>=nRight;n--)
//----
   if(draw_begin1>draw_begin2)
   {
      d_b3=draw_begin1;
   }
   else
   {
      d_b3=draw_begin2;
   }
   SetIndexDrawBegin(0,draw_begin1); //установка начальной точки прорисовки для 0 буфера
   SetIndexDrawBegin(1,draw_begin2); //установка начальной точки прорисовки для 1 буфера
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
   int counted_bars=IndicatorCounted();
//---- 
   //перебираем свечки от (iBars(NULL,TimeFrame)-counted_iBars(NULL,TimeFrame)-nLeft) до (nRight) включительно
   for(i=iBars(NULL,TimeFrame)-1-counted_bars-nLeft;i>=nRight;i--)
   {
      //если свеча локальный максимум
      if(iHigh(NULL,TimeFrame,i)>=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,Range,i-nRight)))
      {
         //Print(TimeToStr(iTime(NULL,TimeFrame,i)), "******Локальный максимум");
         fRange=nvnLeft(i,nLeft)+nvnRight(i,nRight)+1;
         //если она же - фрактал
         if(iHigh(NULL,TimeFrame,i)>=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,fRange,i-nvnRight(i,nRight))))
         {
            UpStage=iHigh(NULL,TimeFrame,i);
            //Print("    она же фрактал");
         }
         else
         {
            if(iHigh(NULL,TimeFrame,i)<=UpBuffer[i+1])
            {
               UpStage=UpBuffer[i+1];
               //Print("    не фрактал, но ниже предыдущего уровня");
            }
            else
            {
               UpStage=nfUp(i);
               //Print("    не фрактал, выше предыдущего уровня");
            }
         }
      }
      else
      {
         //Print(TimeToStr(iTime(NULL,TimeFrame,i)), "******не локальный максимум");
         if(iHigh(NULL,TimeFrame,i)<=UpBuffer[i+1])
         {
            UpStage=UpBuffer[i+1];
            //Print("    ниже предыдущего уровня");
         }
         else
         {
            UpStage=nfUp(i);
            //Print("    выше предыдущего уровня");
         }
      }
      
      //если свеча локальный минимум
      if(iLow(NULL,TimeFrame,i)<=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,Range,i-nRight)))
      {
         fRange=nvnLeft(i,nLeft)+nvnRight(i,nRight)+1;
         //Print(TimeToStr(iTime(NULL,TimeFrame,i))," ",nvnLeft(i,nLeft)," ",nvnRight(i,nRight)+1);
         //если она же - фрактал
         if(iLow(NULL,TimeFrame,i)<=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_HIGH,fRange,i-nvnRight(i,nRight)))) 
         {
            DnStage=iLow(NULL,TimeFrame,i);
         }
         else
         {
            if(iLow(NULL,TimeFrame,i)>=DnBuffer[i+1])
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
         if(iLow(NULL,TimeFrame,i)>=DnBuffer[i+1])
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
//---- расчет остальных буферов
  //    f_2[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
  //    f_3[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
  //    f_4[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
  //    f_5[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
  //    f_6[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4);
      
      
      f_2[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
      f_3[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
      f_4[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
      f_5[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
      f_6[i]=NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4); 
      

   }//конец цикла for(i=iBars(NULL,TimeFrame)-counted_bars-nLeft;i>=nRight;i--)
   for(i=nRight-1;i>=0;i--)
   {
      if(iHigh(NULL,TimeFrame,i)<=UpBuffer[i+1])
      {
         UpStage=UpBuffer[i+1];
      }
      else
      {
         UpStage=nfUp(i);
      }
      if(iLow(NULL,TimeFrame,i)>=DnBuffer[i+1])
      {
         DnStage=DnBuffer[i+1];
      }
      else
      {
         DnStage=nfDn(i);
      }
      UpBuffer[i]=UpStage;
      DnBuffer[i]=DnStage;
//---- расчет остальных буферов
  //    f_2[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
  //    f_3[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
  //    f_4[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
  //    f_5[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
  //    f_6[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4);
      
      f_2[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/6,4);
      f_3[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/3,4);
      f_4[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])/2,4);
      f_5[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*2/3,4);
      f_6[i] =NormalizeDouble(DnBuffer[i]+(UpBuffer[i]-DnBuffer[i])*5/6,4);
      

   }
//---- построение веера Фибоначчи
   double LastUp, LastDn, st_h, st_l, st_3, y1, y2, y3;
   int tmp, x1=0, x2=0, x3=0, cb, dn_x, up_x;
   LastDn=DnBuffer[0];
   for(cb=1;cb<=iBars(NULL,TimeFrame)-1;cb++)
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
   for(cb=1;cb<=iBars(NULL,TimeFrame)-1;cb++)
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
   st_h=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,MathMax(dn_x,up_x),0));
   st_l=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,MathMax(dn_x,up_x),0));
   //y1=MathMin(iOpen(NULL,TimeFrame,x1),)x1));
   //y1=MathMax(iClose(NULL,TimeFrame,x1),iClose(NULL,TimeFrame,x1));
   for(cb=MathMax(dn_x,up_x)-1;cb>=0;cb--)
   {
      if(iHigh(NULL,TimeFrame,cb)==st_h || iLow(NULL,TimeFrame,cb)==st_l)
      {
         if(iHigh(NULL,TimeFrame,cb)==st_h && (x1==0 || x2==0) )
         {
            if(x1==0)
            {
               x1=cb;
               y1=iHigh(NULL,TimeFrame,x1);
               continue;
            }
            else
            {
               x2=cb;
               y2=iHigh(NULL,TimeFrame,x2);
               break;
            }
         }
         else
         {
            if(x1==0)
            {
               x1=cb;
               y1=iLow(NULL,TimeFrame,x1);
               continue;
            }
            else
            {
               x2=cb;
               y2=iLow(NULL,TimeFrame,x2);
               break;
            }
         }
      }
   }
   //Print("x1="+x1+" y1="+y1+" x2="+x2+" y2="+y2);
   if( ObjectFind(fibo)!=-1 )
   {
      ObjectSet(fibo,OBJPROP_TIME1,iTime(NULL,TimeFrame,x1));
      ObjectSet(fibo,OBJPROP_PRICE1,y1);
      ObjectSet(fibo,OBJPROP_TIME2,iTime(NULL,TimeFrame,x2));
      ObjectSet(fibo,OBJPROP_PRICE2,y2);
       
   }
   else
   {
      ObjectCreate(fibo,OBJ_FIBOFAN,0,iTime(NULL,TimeFrame,x1),y1,iTime(NULL,TimeFrame,x2),y2);
 
      ObjectSet(fibo,OBJPROP_COLOR,Fibo1Color);
      ObjectSet(fibo,OBJPROP_LEVELSTYLE,Fibo1Style);
      ObjectSet(fibo,OBJPROP_LEVELWIDTH,Fibo1Width);
      ObjectSet(fibo,OBJPROP_LEVELCOLOR,Fibo1Color) ;  
       
      ObjectSet(fibo,OBJPROP_FIBOLEVELS,5);
      ObjectSet(fibo,OBJPROP_FIRSTLEVEL+0,FibLevel1)  ;
      ObjectSet(fibo,OBJPROP_FIRSTLEVEL+1,FibLevel2)  ;
      ObjectSet(fibo,OBJPROP_FIRSTLEVEL+2,FibLevel3) ; 
      ObjectSet(fibo,OBJPROP_FIRSTLEVEL+3,FibLevel4) ;
      ObjectSet(fibo,OBJPROP_FIRSTLEVEL+4,FibLevel5) ;      
      ObjectSetFiboDescription( fibo, 0, DoubleToStr(FibLevel1,3) ); 
      ObjectSetFiboDescription( fibo, 1, DoubleToStr(FibLevel2,3) ); 
      ObjectSetFiboDescription( fibo, 2, DoubleToStr(FibLevel3,3) ); 
      ObjectSetFiboDescription( fibo, 3, DoubleToStr(FibLevel4,3) ); 
      ObjectSetFiboDescription( fibo, 4, DoubleToStr(FibLevel5,3) );           
   }
//----- а это отрисовка вспомогательного веера фибоначчи
   if(y2>y1)
   {
      st_3=iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,x2,0));
   }
   else
   {
      st_3=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,x2,0));
   }

   for(cb=0;cb<x2;cb++)
   {
      if(y2>y1 && iLow(NULL,TimeFrame,cb)==st_3)
      {
         x3=cb;
         y3=iLow(NULL,TimeFrame,cb);
         break;
      }
      else
      {
         if(y2<y1 && iHigh(NULL,TimeFrame,cb)==st_3)
         {
            x3=cb;
            y3=iHigh(NULL,TimeFrame,cb);
            break;
         }
      }
   }
   if( ObjectFind(fibo2)!=-1 )
   {
      ObjectSet(fibo2,OBJPROP_TIME1,iTime(NULL,TimeFrame,x2));
      ObjectSet(fibo2,OBJPROP_PRICE1,y2);
      ObjectSet(fibo2,OBJPROP_TIME2,iTime(NULL,TimeFrame,x3));
      ObjectSet(fibo2,OBJPROP_PRICE2,y3); 
   }
   else
   {

      ObjectCreate(fibo2,OBJ_FIBOFAN,0,iTime(NULL,TimeFrame,x2),y2,iTime(NULL,TimeFrame,x3),y3);
      ObjectSet(fibo2,OBJPROP_COLOR,Fibo2Color);  
      ObjectSet(fibo2,OBJPROP_LEVELSTYLE,Fibo2Style);
      ObjectSet(fibo2,OBJPROP_LEVELWIDTH,Fibo2Width) ; 
      ObjectSet(fibo2,OBJPROP_LEVELCOLOR,Fibo2Color) ; 
      ObjectSet(fibo2,OBJPROP_FIBOLEVELS,5);
      ObjectSet(fibo2,OBJPROP_FIRSTLEVEL+0,FibLevel1)  ;
      ObjectSet(fibo2,OBJPROP_FIRSTLEVEL+1,FibLevel2)  ;
      ObjectSet(fibo2,OBJPROP_FIRSTLEVEL+2,FibLevel3) ; 
      ObjectSet(fibo2,OBJPROP_FIRSTLEVEL+3,FibLevel4) ;
      ObjectSet(fibo2,OBJPROP_FIRSTLEVEL+4,FibLevel5) ;      
      ObjectSetFiboDescription( fibo2, 0, DoubleToStr(FibLevel1,3) ); 
      ObjectSetFiboDescription( fibo2, 1, DoubleToStr(FibLevel2,3) ); 
      ObjectSetFiboDescription( fibo2, 2, DoubleToStr(FibLevel3,3) ); 
      ObjectSetFiboDescription( fibo2, 3, DoubleToStr(FibLevel4,3) ); 
      ObjectSetFiboDescription( fibo2, 4, DoubleToStr(FibLevel5,3) );   
   }

//----
   return(0);
}


double nfUp(int i)
{
   int l,flag=0;
   double Price=0.0;

   for(l=i+1;l<Bars-draw_begin1-1;l++)
   {
      if(filter>0)
      {
         if(iClose(NULL,TimeFrame,i)<=UpBuffer[l]+(UpBuffer[l]-DnBuffer[l])*filter/100)
         {
            Price=UpBuffer[l];
            flag=1;
            //Print(TimeToStr(iTime(NULL,TimeFrame,i))," ",l," ",Bars," ",Price," ",UpBuffer[l));
         }
      }
      else
      {
         if(iHigh(NULL,TimeFrame,i)<=UpBuffer[l])
         {
            Price=UpBuffer[l];
            flag=1;
         }
      }
      if(Price>0) break;
   }

   if(flag==0) Price=iHigh(NULL,TimeFrame,i);

   return(Price);

}


double nfDn(int i)
{
   int l,flag=0;
   double Price=0.0;

   for(l=i+1;l<Bars-draw_begin2-1;l++)
   {
      if(filter>0)
      {
         if(iClose(NULL,TimeFrame,i)>=DnBuffer[l]-(UpBuffer[l]-DnBuffer[l])*filter/100)
         {
            Price=DnBuffer[l];
            flag=1;
         }
      }
      else
      {
         if(iLow(NULL,TimeFrame,i)>=DnBuffer[l])
         {
            Price=DnBuffer[l];
            flag=1;
         }
      }
      if(Price>0) break;
   }

   if(flag==0) Price=iLow(NULL,TimeFrame,i);

   return(Price);

}



int nvnLeft(int i,int n)
{
   int k=0,l;
   for(l=i+1;l<=iBars(NULL,TimeFrame)-1;l++)
   {
      if(iHigh(NULL,TimeFrame,l)<iHigh(NULL,TimeFrame,l+1)&&iLow(NULL,TimeFrame,l)>iLow(NULL,TimeFrame,l+1)) continue;
      k++;
      if(k==n)
      {
         k=l-i;
         break;
      }
   }
   return(k);
}


int nvnRight(int i,int n)
{
   int k=0,l;
   for(l=i-1;l>=0;l--)
   {
      if(iHigh(NULL,TimeFrame,l)<iHigh(NULL,TimeFrame,l+1)&&iLow(NULL,TimeFrame,l)>iOpen(NULL,TimeFrame,l+1)) continue;
      k++;
      if(k==n)
      {
         k=i-l;
         break;
      }
   }

   return(k);

}



int deinit()
{
   ObjectDelete(fibo);
   ObjectDelete(fibo2);
   return(0);
}


