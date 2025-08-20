//+------------------------------------------------------------------+
//|                                               SnakeInBorders.mq4 |
//|                                                                  |
//|                                                Bookkeeper, 2006, |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//+------------------------------------------------------------------+
#property  indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrBlue
#property indicator_color4  clrRed
#property indicator_width1  4
#property indicator_width2  4
#property indicator_width3  1
#property indicator_width4  1
//----
extern int  cPeriod=24; 
//----
double    ForceUp[];
double    ForceDown[];
double    ResistanceUp[];
double    ResistanceDown[];
double    Mart[];
double    prices[];

//----
double Snake_Sum, Snake_Weight, Snake_Sum_Minus, Snake_Sum_Plus;
//----
int init()
{
int    draw_begin;
double indperiod,val1;  //,val2;
string CommentStr;
   draw_begin=3*cPeriod;
   IndicatorBuffers(6);
   SetIndexBuffer(0,ForceUp);
   SetIndexBuffer(1,ForceDown);
   SetIndexBuffer(2,ResistanceUp);
   SetIndexBuffer(3,ResistanceDown);
   SetIndexBuffer(4,Mart);
   SetIndexBuffer(5,prices);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   indperiod=1.0*cPeriod*Period();
   if(indperiod<60)
   {
      CommentStr=DoubleToStr(indperiod,0);
      CommentStr=" M"+CommentStr+", FORCE UP -DOWN ";
   }
   else
   {
      indperiod=indperiod/60;
      if(indperiod>=24)
      {
         val1=MathAbs(MathRound(indperiod/24)-indperiod/24);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod/24,0);
            CommentStr=" D"+CommentStr+", FORCE UP -DOWN ";
         }
          else
         {
            CommentStr=DoubleToStr(indperiod/24,1);
            CommentStr=" D"+CommentStr+", FORCE UP -DOWN ";
         }
      }
      else
      {
         val1=MathAbs(MathRound(indperiod)-indperiod);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod,0);
            CommentStr=" H"+CommentStr+", FORCE UP -DOWN ";
         }
          else
         {
            CommentStr=DoubleToStr(indperiod,1);
            CommentStr=" H"+CommentStr+", FORCE UP -DOWN ";
         }
      }
   }
   IndicatorShortName("");
   SetIndexLabel(0,"");
   SetIndexLabel(1,"");
   return(0);
}
//----
void deinit()
{
}
//----
int start()
{
int FirstPos, ExtCountedBars=0;  //,i;
   if(Bars<=50) return(0);
   if(cPeriod<21) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   FirstPos=Bars-ExtCountedBars-2;
      Snake(FirstPos);
   return(0);
}
//----
void Snake(int Pos)
{
//int i;
   if(Pos<6) Pos=6;
   while(Pos>=0)
   {
      Mart[Pos]=iTma(SnakePrice(Pos),11,Pos);
      Drawing(Pos);
      Pos--;
   }
   return;
}

//
//
//
//
//

double iTma(double price, double period, int i)
{
   double half = (period+1.0)/2.0;
   double sum  = 0;
   double sumw = 0;
   prices[i] = price;

// for(int k=0; k<period && (i+k)<Bars; k++)
   for(int k=0; k<period;k++)
   {
      double weight = k+1; if (weight > half) weight = period-k;
             sumw  += weight;
             sum   += weight*prices[i+k];  
   }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//----
double SnakePrice(int Shift)
{
//   return((2*Close[Shift]+High[Shift]+Low[Shift])/4);
   return(Close[Shift]);
}
//----
double SnakeFirstCalc(int Shift)
{
int i, j, w;
   Snake_Sum=0.0;
   if(Shift<5)
   {
      Snake_Weight=0.0;
      i=0;
      w=Shift+5;
      while(w>=Shift)
      {
         i++;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
      while(w>=0)
      {
         i--;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
   }
   else
   {
      Snake_Sum_Minus=0.0;
      Snake_Sum_Plus=0.0;
      for(j=Shift-5,i=Shift+5,w=1; w<=5; j++,i--,w++)
      {
         Snake_Sum=Snake_Sum+w*(SnakePrice(i)+SnakePrice(j));
         Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(i);
         Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(j);
      }
      Snake_Sum=Snake_Sum+6*SnakePrice(Shift);
      Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(Shift);
      Snake_Weight=36;
   }
   return(Snake_Sum/Snake_Weight);
}
//----
double SnakeNextCalc(int Shift)
{
   Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(Shift-5);
   Snake_Sum=Snake_Sum-Snake_Sum_Minus+Snake_Sum_Plus;
   Snake_Sum_Minus=Snake_Sum_Minus-SnakePrice(Shift+6)+SnakePrice(Shift);
   Snake_Sum_Plus=Snake_Sum_Plus-SnakePrice(Shift);
   return(Snake_Sum/Snake_Weight);
}
//----
void Drawing(int Shift)
{
double val,Dval;  //,val1,val2,val11,val22,val3;
   val= 5*(Mart[Shift]-Mart[ArrayMinimum(Mart,cPeriod,Shift)])/9;
   Dval=5*(Mart[Shift]-
           Mart[Shift+1]+
           Mart[ArrayMinimum(Mart,cPeriod,Shift+1)]-
           Mart[ArrayMinimum(Mart,cPeriod,Shift)]   )/9;
   if(Dval>0) 
   {
      ForceUp[Shift]=val;
      ResistanceUp[Shift]=0;
   }
   else 
   {
      ForceUp[Shift]=0;
      ResistanceUp[Shift]=val;
   }
   val= 5*(Mart[Shift]-Mart[ArrayMaximum(Mart,cPeriod,Shift)])/9;
   Dval=5*(Mart[Shift]-
           Mart[Shift+1]+
           Mart[ArrayMaximum(Mart,cPeriod,Shift+1)]-
           Mart[ArrayMaximum(Mart,cPeriod,Shift)]   )/9;
   if(Dval<0) 
   {
      ForceDown[Shift]=val;
      ResistanceDown[Shift]=0;
   }
   else 
   {
      ForceDown[Shift]=0;
      ResistanceDown[Shift]=val;
   }
   return;
}

