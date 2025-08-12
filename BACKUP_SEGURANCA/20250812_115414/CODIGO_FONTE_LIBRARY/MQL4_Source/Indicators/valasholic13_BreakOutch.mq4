//+------------------------------------------------------------------+
//|                                            valasholic13 v2.5.mq4 |
//|                        Copyright © 2006, CT-Valas Software Corp. |
//|                                             valasholic@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, CT-Valas Software Corp."
#property link      "valasholic@yahoo.com"
//----
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  Snow
#property indicator_width1 0
#property indicator_color2  Red
#property indicator_width2 1
#property indicator_color3  Blue
#property indicator_width3 1
#property indicator_color4  Pink
#property indicator_width4 1
#property indicator_color5  LightBlue
#property indicator_width5 1
#property indicator_color6  Lime
#property indicator_width6 1
#property indicator_color7  Lime
#property indicator_width7 1
//---- input parameters
//---- buffers
double PBuffer[];
double J1Buffer[];
double B1Buffer[];
double J2Buffer[];
double B2Buffer[];
double J3Buffer[];
double B3Buffer[];
string Pivot="Pivot Point", Jual1="S 1", Beli1="R 1";
string Jual2="S 2", Beli2="R 2", Jual3="S 3", Beli3="R 3";
int fontsize=10;
double P,J1,B1,J2,B2,J3,B3;
double LastHigh,LastLow,x;
double D4=0.55;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
// ObjectDelete("Pivot");
   ObjectDelete("Jual1");
   ObjectDelete("Beli1");
   ObjectDelete("Jual2");
   ObjectDelete("Beli2");
   ObjectDelete("Jual3");
   ObjectDelete("Beli3");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,J1Buffer);
   SetIndexBuffer(2,B1Buffer);
   SetIndexBuffer(3,J2Buffer);
   SetIndexBuffer(4,B2Buffer);
   SetIndexBuffer(5,J3Buffer);
   SetIndexBuffer(6,B3Buffer);
//---- name for DataWindow and indicator subwindow label
//IndicatorShortName("Pivot Point");
//SetIndexLabel(0, "Pivot Point");
//----
   SetIndexDrawBegin(0,1);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   int limit,i;
   Print(DoubleToStr(Close[i],Digits));
   Print(DoubleToStr(Close[0],Digits));
   Print(DoubleToStr(Close[0],Digits));
//---- indicator calculation
   if(counted_bars==0)
     {
      x=Period();
      if(x>240)
         return(-1);
      /////////// MEMBUAT TULISAN PADA GARIS JUAL / BELI \\\\\\\\\\\\\
      //ObjectCreate("Pivot", OBJ_TEXT, 0, 0, 0);
      //ObjectSetText("Pivot", "                PIVOT", fontsize, "Arial", Black);
      ObjectCreate("Jual1",OBJ_TEXT,0,0,0);
      ObjectSetText("Jual1","                       SELL AREA",fontsize,"Arial",Green);
      ObjectCreate("Beli1",OBJ_TEXT,0,0,0);
      ObjectSetText("Beli1","                       BUY AREA",fontsize,"Arial",Green);
      ObjectCreate("Jual2",OBJ_TEXT,0,0,0);
      ObjectSetText("Jual2","                       BREAK LOW",fontsize,"Arial",Green);
      ObjectCreate("Beli2",OBJ_TEXT,0,0,0);
      ObjectSetText("Beli2","                       BREAK HIGH",fontsize,"Arial",Green);
      ObjectCreate("Jual3",OBJ_TEXT,0,0,0);
      ObjectSetText("Jual3","                       TARGET",fontsize,"Arial",Green);
      ObjectCreate("Beli3",OBJ_TEXT,0,0,0);
      ObjectSetText("Beli3","                       TARGET",fontsize,"Arial",Green);
     }

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

//----
   for(i=limit; i>=0; i--)
     {
      if(High[i+1]>LastHigh)
         LastHigh=High[i+1];
      //----
      if(Low[i+1]<LastLow)
         LastLow=Low[i+1];
      if(TimeDay(Time[i])!=TimeDay(Time[i+1]))
        {
         Print(DoubleToStr(Close[i],Digits));
         Print(DoubleToStr(High[0],Digits));
         Print(DoubleToStr(Low[0],Digits));
         //////////// RUMUS UNTUK MENENTUKAN BREAK \\\\\\\\\\\\\\\\\\\\\
         P=(LastHigh+LastLow+Close[i+1])/3; // RUMUS UTK MENENTUKAN PIVOT
         B1=P + 20*Point; // PENENTUAN MASUK BUY AREA (BOLEH DIGANTI SESUAI ANALISA ANDA)
         J1=P - 20*Point; // PENENTUAN MASUK SELL AREA (BOLEH DIGANTI SESUAI ANALISA ANDA)
         B2=P + 40*Point; // PENENTUAN NILAI BREAK HIGH (BOLEH DIGANTI SESUAI ANALISA ANDA)
         J2=P - 40*Point; // PENENTUAN NIAI BREAK LOW (BOLEH DIGANTI SESUAI ANALISA ANDA)
         B3=P + 55*Point; // GARIS TARGET HIGH (BOLEH DIGANTI SESUAI ANALISA ANDA)
         J3=P - 55*Point; // GARIS TARGET LOW (BOLEH DIGANTI SESUAI ANALISA ANDA)
                          //Re2 = P + (LastHigh - LastLow); //ini adalah rumus dari Resistance 2
         //Su2 = P - (LastHigh - LastLow); // ini adalah rumus dari Support 2
         //Re3 = (2*P) + (LastHigh - (2*LastLow)); // ini adalah rumus dari resistance 3
         //Su3 = (2*P) - ((2* LastHigh) - LastLow); //ni adalah rumus dari Support 3          
         LastLow=Open[i];
         LastHigh=Open[i];
         //----
         //ObjectMove("Pivot", 0, Time[i], P);
         ObjectMove("Jual1",0,Time[i],J1);
         ObjectMove("Beli1",0,Time[i],B1);
         ObjectMove("Jual2",0,Time[i],J2);
         ObjectMove("Beli2",0,Time[i],B2);
         ObjectMove("Jual3",0,Time[i],J3);
         ObjectMove("Beli3",0,Time[i],B3);
        }
      PBuffer[i]=P;
      J1Buffer[i]=J1;
      B1Buffer[i]=B1;
      J2Buffer[i]=J2;
      B2Buffer[i]=B2;
      J3Buffer[i]=J3;
      B3Buffer[i]=B3;
      //----
      Comment("\n VALASHOLIC13 v2.5 ( BREAKOUT STRATEGY ) \n Registered to: Latihan Bikin \n"
              +"\n Copyright © 2006,CT-Valas Software Corp.\n contact support:valasholic@yahoo.com"
              +"\n \n -------------------------------------------------------------------"
              +"\n :::::::::::: SAAT DIANTARA 2 BREAK ::::::::::::"
              +"\n -------------------------------------------------------------------"
              +"\n BUY AREA (break) :"
              +"\n # BUY STOP1  "+Symbol()+" pada "+(DoubleToStr(B1Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr(B2Buffer[i],Digits))+" dan SL pada "+(DoubleToStr(J1Buffer[i],Digits))
              +"\n # BUY STOP2  "+Symbol()+" pada "+(DoubleToStr(B2Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr((B2Buffer[i]+(10*Point)),Digits))+" dan SL pada "+(DoubleToStr(B1Buffer[i],Digits))
              +"\n \n SELL AREA (break) :"
              +"\n # SELL STOP  "+Symbol()+" pada "+(DoubleToStr(J1Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr(J2Buffer[i],Digits))+" dan SL pada "+(DoubleToStr(B1Buffer[i],Digits))
              +"\n # SELL STOP  "+Symbol()+" pada "+(DoubleToStr(J2Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr((J2Buffer[i]-(10*Point)),Digits))+" dan SL pada "+(DoubleToStr(J1Buffer[i],Digits))
              //----
              +"\n \n -------------------------------------------------------------------"
              +"\n :::::::::::: SAAT MELEWATI KOREKSI ::::::::::::"
              +"\n -------------------------------------------------------------------"
              +"\n KOREKSI BAWAH :"
              +"\n # BUY STOP  "+Symbol()+" pada "+(DoubleToStr(J2Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr(B1Buffer[i],Digits))+" dan SL pada "+(DoubleToStr(J3Buffer[i],Digits))
              +"\n \n KOREKSI ATAS :"
              +"\n # SELL STOP  "+Symbol()+" pada "+(DoubleToStr(B2Buffer[i],Digits))
              +"\n dengan TP "+(DoubleToStr(J1Buffer[i],Digits))+" dan SL pada "+(DoubleToStr(B3Buffer[i],Digits))
              +"\n -------------------------------------------------------------------"
              +"\n \n -------------------------------------------------------------------"
              +"\n :::::: SUPPORT & RESISTANCE HARI INI :::::"
              +"\n -------------------------------------------------------------------");
      //Bagaimana caranya menampilkan nilai Support dan Resistance?
      //Kita tunggu TIPs berikutnya
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
