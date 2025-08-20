// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=23087


//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_buffers 13
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Yellow

extern int Length=9;
extern int MaxBars=100;
extern color UP_Color=Green;
extern color DN_Color=Red;
extern color OB_Color=Blue;

double Buff5[], Buff6[], Up[], Dn[];
double UpH[], UpL[], UpN[], DnH[], DnL[], DnN[], ZH[], ZL[], ZN[];

int init()
  {
   IndicatorShortName("Overbought/Oversold Indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(2,DRAW_HISTOGRAM, EMPTY, EMPTY, UP_Color);
   SetIndexBuffer(2,UpH);
   SetIndexStyle(3,DRAW_HISTOGRAM, EMPTY, EMPTY, UP_Color);
   SetIndexBuffer(3,DnH);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ZH);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Buff5);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Buff6);
   SetIndexStyle(7,DRAW_HISTOGRAM, EMPTY, EMPTY, DN_Color);
   SetIndexBuffer(7,UpL);
   SetIndexStyle(8,DRAW_HISTOGRAM, EMPTY, EMPTY, DN_Color);
   SetIndexBuffer(8,DnL);
   SetIndexStyle(9,DRAW_HISTOGRAM);
   SetIndexBuffer(9,ZL);
   SetIndexStyle(10,DRAW_HISTOGRAM, EMPTY, EMPTY, OB_Color);
   SetIndexBuffer(10,UpN);
   SetIndexStyle(11,DRAW_HISTOGRAM, EMPTY, EMPTY, OB_Color);
   SetIndexBuffer(11,DnN);
   SetIndexStyle(12,DRAW_HISTOGRAM);
   SetIndexBuffer(12,ZN);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMax(limit, MaxBars);
 pos=limit;
 double Buff1, Buff3, Buff4;
 while(pos>=0)
 {
  Buff1=(High[pos]+Low[pos]+Close[pos]+Close[pos])/4;
  Buff3=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  Buff4=iStdDev(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  if (Buff4!=0) 
  {
   Buff5[pos]=(Buff1-Buff3)*100/Buff4; 
  } 
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  Buff6[pos]=iMAOnArray(Buff5, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  Up[pos]=iMAOnArray(Buff6, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit - 1;
 
    while(pos>=0)
    {
        Dn[pos]=iMAOnArray(Up, 0, Length, 0, MODE_EMA, pos);
        if (Up[pos + 1] < Up[pos] && Dn[pos + 1] < Dn[pos])
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpH[pos] = MathMax(Dn[pos], Up[pos]);
                ZH[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnH[pos] = MathMin(Dn[pos], Up[pos]);
                ZH[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpH[pos] = MathMax(Dn[pos], Up[pos]);
                DnH[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        else if (Up[pos + 1] > Up[pos] && Dn[pos + 1] > Dn[pos])
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpL[pos] = MathMax(Dn[pos], Up[pos]);
                ZL[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnL[pos] = MathMin(Dn[pos], Up[pos]);
                ZL[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpL[pos] = MathMax(Dn[pos], Up[pos]);
                DnL[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        else
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpN[pos] = MathMax(Dn[pos], Up[pos]);
                ZN[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnN[pos] = MathMin(Dn[pos], Up[pos]);
                ZN[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpN[pos] = MathMax(Dn[pos], Up[pos]);
                DnN[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        
        pos--;
    }

    return(0);
}

