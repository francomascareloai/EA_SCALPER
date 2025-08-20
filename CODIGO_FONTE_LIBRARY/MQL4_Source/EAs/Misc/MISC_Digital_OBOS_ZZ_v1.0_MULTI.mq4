
#property copyright "Copyright 2020"
#property link      "OBOS ZZ"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_width1 1
#property indicator_color2 DarkOrange
#property indicator_width2 2
#property indicator_color3 DeepPink
#property indicator_width3 0
#property indicator_color4 DeepSkyBlue
#property indicator_width4 0
#property indicator_color5 SlateGray
#property indicator_width5 0
#property indicator_color6 Lime
#property indicator_width6 0
#property indicator_color7 DeepSkyBlue
#property indicator_width7 0
#property indicator_color8 Lime
#property indicator_width8 0



//---- input parameters
extern int     barn=1000;
extern int     LengthB=60;
extern int     LengthK=12;
double prev;
double last;
double alertBar;
extern int SoundAlertMode = 1;
extern int Soundonly = 1;
extern int period = 21;
extern int shifts = 0;
extern int bar = 2000;
double u1 = 0.0;
double u2 = 0.0;
double G_ibuf_104[];
double G_ibuf_108[];
double G_ibuf_112[];
double G_ibuf_116[];
double G_ibuf_120[];
double G_ibuf_124[];
double G_ibuf_128[];


bool targets = false;

double previ;
double lasti;
double alertBar1;
bool targetsi = false;
//---- buffers
int sim=0;
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
int PipValue=1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

Tulis("Spread","Spread = "+(MarketInfo(Symbol(),MODE_SPREAD)/PipValue)+"",DarkOrange,1, 12, 21,10);

   SetIndexEmptyValue(0,0.0);
   SetIndexDrawBegin(0, barn);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,174); 
   SetIndexBuffer(0,ExtMapBuffer1);
   IndicatorShortName("DIN");
   SetIndexEmptyValue(1,0.0);
   SetIndexDrawBegin(1, barn);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,164); 
   SetIndexBuffer(1,ExtMapBuffer2);
   IndicatorShortName("UDIN");
   SetIndexStyle(2, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(2, G_ibuf_104);
   SetIndexStyle(3, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(3, G_ibuf_108);
   SetIndexStyle(4, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(4, G_ibuf_112);
   SetIndexStyle(5, DRAW_NONE, STYLE_DOT, 1);
   SetIndexBuffer(5, G_ibuf_116);
   SetIndexStyle(6, DRAW_NONE, STYLE_DOT, 1);
   SetIndexBuffer(6, G_ibuf_120);
   SetIndexStyle(7, DRAW_NONE, STYLE_DOT, 1);
   SetIndexBuffer(7, G_ibuf_124);
   SetIndexStyle(8, DRAW_NONE, STYLE_DOT, 1);
   SetIndexBuffer(8, G_ibuf_128);
   for (int count_0 = 0; count_0 < 8; count_0++) SetIndexShift(count_0, shifts);
   if (bar > Bars) bar = Bars;
   if(Digits==3 || Digits==5)PipValue=10;
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   ObjectDelete("Start line");
   ObjectDelete("Stop line");
   ObjectDelete("Target1 line");
   ObjectDelete("Target2 line");
   ObjectDelete("Target3 line");
   ObjectDelete("info0");
   ObjectDelete("info1");
   ObjectDelete("info2");
   ObjectDelete("info3");
   ObjectDelete("ss");
   ObjectDelete("bs");
   ObjectDelete("scalpss");
   ObjectDelete("scalpbs");
   ObjectDelete("Judul");
   ObjectDelete("warning");
   ObjectDelete("Spread");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   int    counted_bars=IndicatorCounted();
   int shift,Swing,Swing_n,uzl,i,zu,zd,mv;
   double PointA,PointB,PointC,Target1,Target2,Target3,Fantnsy,CrazyDream,Start,Stop;
   double LL,HH,BH,BL; 
   double Uzel[10000][3]; 

// loop from first bar to current bar (with shift=0) 
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[barn];BL=Low[barn];zu=barn;zd=barn; 

for (shift=barn;shift>=0;shift--) { 
      LL=10000000;HH=-100000000; 
   for (i=shift+LengthK;i>=shift+1;i--) { 
         if (Low[i]< LL) {LL=Low[i];} 
         if (High[i]>HH) {HH=High[i];} 
   } 


   if (Low[shift]<LL && High[shift]>HH){ 
      Swing=2; 
      if (Swing_n==1) {zu=shift+1;} 
      if (Swing_n==-1) {zd=shift+1;} 
   } else { 
      if (Low[shift]<LL) {Swing=-1;} 
      if (High[shift]>HH) {Swing=1;} 
   } 

   if (Swing!=Swing_n && Swing_n!=0) { 
   if (Swing==2) {
      Swing=-Swing_n;BH = High[shift];BL = Low[shift]; 
   } 
      uzl=uzl+1; 
   if (Swing==1) {
      Uzel[uzl][1]=zd;
      Uzel[uzl][2]=BL;
   } 
   if (Swing==-1) {
      Uzel[uzl][1]=zu;
      Uzel[uzl][2]=BH; 
   } 
      BH = High[shift];
      BL = Low[shift]; 
   } 

   if (Swing==1) { 
      if (High[shift]>=BH) {BH=High[shift];zu=shift;}} 
      if (Swing==-1) {
          if (Low[shift]<=BL) {BL=Low[shift]; zd=shift;}} 
      Swing_n=Swing; 
   } 
   for (i=1;i<=uzl;i++) { 
      //text=DoubleToStr(Uzel[i][1],0);
      //text=;
      //double harga;
         mv=StrToInteger(DoubleToStr(Uzel[i][1],0));


      if(prev > Uzel[i][2] && ExtMapBuffer1[mv]!=Uzel[i][2] && SoundAlertMode > 0 && Bars>alertBar) {sim=3;Alert("BUY Signal on ",Symbol()," Period ",Period());alertBar = Bars;}
      if(prev < Uzel[i][2] && ExtMapBuffer1[mv]!=Uzel[i][2] && SoundAlertMode > 0 && Bars>alertBar) {sim=4;Alert("SELL Signal on ",Symbol()," Period ",Period());alertBar = Bars;}

      //if(prev > Uzel[i][2] && ExtMapBuffer1[mv]!=Uzel[i][2] && Bars>alertBar) {harga=iOpen(Symbol(),0,i);PlaySound("mailworf.wav");alertBar = Bars;}
      //if(prev < Uzel[i][2] && ExtMapBuffer1[mv]!=Uzel[i][2] && Bars>alertBar) {harga=iOpen(Symbol(),0,i);PlaySound("subspace.wav");alertBar = Bars;}
      ExtMapBuffer1[mv]=Uzel[i][2];
      prev=Uzel[i][2];
      //if(  sim==1||sim==3 ){
      //ObjectDelete("scalpss");
      //Tulis("scalpbs","BUY ",Blue,1, 20, 50,10);}
      //else if(  sim==2 || sim==4 ){
      //ObjectDelete("scalpbs");
      //Tulis("scalpss","SELL ",Red,1, 20, 50,10);}
   } 

PointA = Uzel[uzl-2][2];
PointB = Uzel[uzl-1][2];
PointC = Uzel[uzl][2];

Target1=NormalizeDouble((PointB-PointA)*0.618+PointC,4);
Target2=PointB-PointA+PointC;
Target3=NormalizeDouble((PointB-PointA)*1.618+PointC,4);
Fantnsy=NormalizeDouble((PointB-PointA)*2.618+PointC,4);
CrazyDream=NormalizeDouble((PointB-PointA)*4.618+PointC,4);
if (PointB<PointC)
{
Start= NormalizeDouble((PointB-PointA)*0.118+PointC,4)-(Ask-Bid);
Stop=PointC+2*(Ask-Bid);
}
if (PointB>PointC)
{
Start= NormalizeDouble((PointB-PointA)*0.118+PointC,4)+(Ask-Bid);
Stop=PointC-2*(Ask-Bid);
}


   if (ObjectFind("Start Line") != 0 && targets == true) 
     {
      ObjectCreate("Start line",OBJ_HLINE,0,Time[0],Start);
      ObjectSet("Start line",OBJPROP_COLOR,Bisque);
      ObjectSet("Start line",OBJPROP_WIDTH,1);
      ObjectSet("Start line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Start line", 0,Time[0],Start);
     }

   if (ObjectFind("Stop Line") != 0 && targets == true) 
     {
      ObjectCreate("Stop line",OBJ_HLINE,0,Time[0],Stop);
      ObjectSet("Stop line",OBJPROP_COLOR,Red);
      ObjectSet("Stop line",OBJPROP_WIDTH,1);
      ObjectSet("Stop line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Stop line", 0,Time[0],Stop);
     }
    
    if (ObjectFind("Target1 Line") != 0 && targets == true) 
     {
      ObjectCreate("Target1 line",OBJ_HLINE,0,Time[0],Target1);
      ObjectSet("Target1 line",OBJPROP_COLOR,Yellow);
      ObjectSet("Target1 line",OBJPROP_WIDTH,1);
      ObjectSet("Target1 line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Target1 line", 0,Time[0],Target1);
     }

    if (ObjectFind("Target2 Line") != 0 && targets == true) 
     {
      ObjectCreate("Target2 line",OBJ_HLINE,0,Time[0],Target2);
      ObjectSet("Target2 line",OBJPROP_COLOR,PaleTurquoise);
      ObjectSet("Target2 line",OBJPROP_WIDTH,1);
      ObjectSet("Target2 line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Target2 line", 0,Time[0],Target2);
     }
    
    if (ObjectFind("Target3 Line") != 0 && targets == true) 
     {
      ObjectCreate("Target3 line",OBJ_HLINE,0,Time[0],Target3);
      ObjectSet("Target3 line",OBJPROP_COLOR,LightSkyBlue);
      ObjectSet("Target3 line",OBJPROP_WIDTH,1);
      ObjectSet("Target3 line",OBJPROP_STYLE,STYLE_DASH);
     }
     else
     {
     ObjectMove("Target3 line", 0,Time[0],Target3);
     }
     sinyal();
     garis();
   return(0);
  }
//+------------------------------------------------------------------+
void garis(){
   int Li_8 = IndicatorCounted();
   //if (Li_8 < 0) return (-1);
   if (Li_8 > 0) Li_8--;
   int Li_4 = Bars - Li_8 - 1;
   if (Li_8 == 0 && Li_4 > bar) Li_4 = bar;
   for (int Li_0 = Li_4; Li_0 >= 0; Li_0--) {
      G_ibuf_104[Li_0] = High[iHighest(NULL, 0, MODE_HIGH, period, Li_0)];
      G_ibuf_108[Li_0] = Low[iLowest(NULL, 0, MODE_LOW, period, Li_0)];
      G_ibuf_112[Li_0] = (G_ibuf_104[Li_0] + G_ibuf_108[Li_0]) / 2.0;
      G_ibuf_116[Li_0] = G_ibuf_108[Li_0] + (G_ibuf_104[Li_0] - G_ibuf_108[Li_0]) * u1;
      G_ibuf_120[Li_0] = G_ibuf_108[Li_0] + (G_ibuf_104[Li_0] - G_ibuf_108[Li_0]) * u2;
      G_ibuf_124[Li_0] = G_ibuf_104[Li_0] - (G_ibuf_104[Li_0] - G_ibuf_108[Li_0]) * u1;
      G_ibuf_128[Li_0] = G_ibuf_104[Li_0] - (G_ibuf_104[Li_0] - G_ibuf_108[Li_0]) * u2;
   }

}





void sinyal(){
int shifti,Swingi,Swing_ni,uzli,ii,zui,zdi,mvi;
   double PointAi,PointBi,PointCi,Target1i,Target2i,Target3i,Fantnsyi,CrazyDreami,Starti,Stopi;
   double LLi,HHi,BHi,BLi; 
   double Uzeli[10000][3]; 

// loop from first bar to current bar (with shift=0) 
      Swing_ni=0;Swingi=0;uzli=0; 
      BHi =High[barn];BLi=Low[barn];zui=barn;zdi=barn; 

for (shifti=barn;shifti>=0;shifti--) { 
      LLi=10000000;HHi=-100000000; 
   for (ii=shifti+LengthB;ii>=shifti+1;ii--) { 
         if (Low[ii]< LLi) {LLi=Low[ii];} 
         if (High[ii]>HHi) {HHi=High[ii];} 
   } 


   if (Low[shifti]<LLi && High[shifti]>HHi){ 
      Swingi=2; 
      if (Swing_ni==1) {zui=shifti+1;} 
      if (Swing_ni==-1) {zdi=shifti+1;} 
   } else { 
      if (Low[shifti]<LLi) {Swingi=-1;} 
      if (High[shifti]>HHi) {Swingi=1;} 
   } 

   if (Swingi!=Swing_ni && Swing_ni!=0) { 
   if (Swingi==2) {
      Swingi=-Swing_ni;BHi = High[shifti];BLi = Low[shifti]; 
   } 
      uzli=uzli+1; 
   if (Swingi==1) {
      Uzeli[uzli][1]=zdi;
      Uzeli[uzli][2]=BLi;
   } 
   if (Swingi==-1) {
      Uzeli[uzli][1]=zui;
      Uzeli[uzli][2]=BHi; 
   } 
      BHi = High[shifti];
      BLi = Low[shifti]; 
   } 

   if (Swingi==1) { 
      if (High[shifti]>=BHi) {BHi=High[shifti];zui=shifti;}} 
      if (Swingi==-1) {
          if (Low[shifti]<=BLi) {BLi=Low[shifti]; zdi=shifti;}} 
      Swing_ni=Swingi; 
   } 
   for (ii=1;ii<=uzli;ii++) { 
      //text=DoubleToStr(Uzel[i][1],0);
      //text=;
         mvi=StrToInteger(DoubleToStr(Uzeli[ii][1],0));


      if(previ > Uzeli[ii][2] && ExtMapBuffer2[mvi]!=Uzeli[ii][2] && SoundAlertMode > 0 && Bars>alertBar1) {sim=1;Alert("Big Trend Up ",Symbol()," Period ",Period());alertBar = Bars;}
      if(previ < Uzeli[ii][2] && ExtMapBuffer2[mvi]!=Uzeli[ii][2] && SoundAlertMode > 0 && Bars>alertBar1) {sim=2;Alert("Big Trend Down ",Symbol()," Period ",Period());alertBar = Bars;}

      //if(previ > Uzeli[ii][2] && ExtMapBuffer2[mvi]!=Uzeli[ii][2] && Bars>alertBar1) {}
      //if(previ < Uzeli[ii][2] && ExtMapBuffer2[mvi]!=Uzeli[ii][2] && Bars>alertBar1) {}
      ExtMapBuffer2[mvi]=Uzeli[ii][2];
      if(sim==1){
      ObjectDelete("ss");
      Tulis("bs","UP TREND",Green,1, 12, 1,14);}
      else if(sim==2){
      ObjectDelete("bs");
      Tulis("ss","DOWN TREND",Red,1, 12, 1,14);}
      
      previ=Uzeli[ii][2];
      
   } 

PointAi = Uzeli[uzli-2][2];
PointBi = Uzeli[uzli-1][2];
PointCi = Uzeli[uzli][2];

Target1i=NormalizeDouble((PointBi-PointAi)*0.618+PointCi,4);
Target2i=PointBi-PointAi+PointCi;
Target3i=NormalizeDouble((PointBi-PointAi)*1.618+PointCi,4);
Fantnsyi=NormalizeDouble((PointBi-PointAi)*2.618+PointCi,4);
CrazyDreami=NormalizeDouble((PointBi-PointAi)*4.618+PointCi,4);
if (PointBi<PointCi)
{
Starti= NormalizeDouble((PointBi-PointAi)*0.118+PointCi,4)-(Ask-Bid);
Stopi=PointCi+2*(Ask-Bid);
}
if (PointBi>PointCi)
{
Starti= NormalizeDouble((PointBi-PointAi)*0.118+PointCi,4)+(Ask-Bid);
Stopi=PointCi-2*(Ask-Bid);
}



}
void Tulis(string namateks, string teks, color warna, int pojok, int posx, int posy,int size)
{
   ObjectCreate(namateks, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(namateks, teks, size, teks, warna);
   ObjectSet(namateks, OBJPROP_CORNER, pojok);
   ObjectSet(namateks, OBJPROP_XDISTANCE, posx);
   ObjectSet(namateks, OBJPROP_YDISTANCE, posy);
}