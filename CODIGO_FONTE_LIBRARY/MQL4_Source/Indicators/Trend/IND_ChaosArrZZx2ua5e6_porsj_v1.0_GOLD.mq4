//+------------+-----------------------------------------------------+
//| v.22.04.07 |                                         ArrZZx2.mq4 |
//+------------+                                                     |
//|------------|              Bookkeeper, 2007, yuzefovich@gmail.com |
//+------------+-----------------------------------------------------+
#property copyright ""
#property link      "http://www.forexter.land.ru/indicators.htm"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  Magenta
#property indicator_width1 5
#property indicator_color2  Lime
#property indicator_width2 5
#property indicator_color3  Blue
#property indicator_color4  Blue
#property indicator_color5  Yellow//C'0,128,255'
#property indicator_width5 2
#property indicator_color6  Yellow//C'192,0,192'
#property indicator_width6 2
#property indicator_color7  DodgerBlue//C'0,128,255'
#property indicator_width7 1
#property indicator_color8  MediumVioletRed//C'192,0,192'
#property indicator_width8 1
//--------------------------------------------------------------------
int    SR     =3;  // =3..4   Xard settings (3,21,20,21,3,false,0)
extern int    SRZZ   =8;//60;//36;//24;//13; // =4..12..20..12
int    MainRZZ=20;//20; // =12..20..54..20
int    FP     =21;
int    SMF    =3;  // =1..5
bool   DrawZZ =false;
int    PriceConst=0; // 0 - Close
                            // 1 - Open
                            // 2 - High
                            // 3 - Low
                            // 4 - (H+L)/2
                            // 5 - (H+L+C)/3
                            // 6 - (H+L+2*C)/4
//extern string Prefix="ArrZZx2"; 
//--------------------------------------------------------------------
double        Lmt[];
double        LZZ[];
double        SA[];
double        SM[];
double        Up[];
double        Dn[];
double        pUp[];
double        pDn[];
//---------------------------------------------------------------------
int LTF[6]={0,0,0,0,0,0},STF[5]={0,0,0,0,0}; 
int MaxBar, nSBZZ, nLBZZ, SBZZ, LBZZ;
bool First=true;
int prevBars=0;
//---------------------------------------------------------------------
void MainCalculation(int Pos) {
if((Bars-Pos)>(SR+1)) SACalc(Pos); else SA[Pos]=0; 
if((Bars-Pos)>(FP+SR+2)) SMCalc(Pos); else SM[Pos]=0; return; }
//---------------------------------------------------------------------
void SACalc(int Pos) { int sw, i, w, ww, Shift; double sum; 
switch(PriceConst) {
case  0: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_CLOSE,Pos);
  break;
case  1: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_OPEN,Pos);
  break;
/*case  2: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_HIGH,Pos);
  break;
case  3: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_LOW,Pos);
  break;*/
case  4: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_MEDIAN,Pos);
  break;
case  5: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_TYPICAL,Pos);
  break;
case  6: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_WEIGHTED,Pos);
  break;
default: 
  SA[Pos]=iMA(NULL,0,SR+1,0,MODE_LWMA,PRICE_OPEN,Pos);
  break; }
for(Shift=Pos+SR+2;Shift>Pos;Shift--) { sum=0.0; sw=0; i=0; w=Shift+SR;
ww=Shift-SR; if(ww<Pos) ww=Pos;
while(w>=Shift) {i++; sum=sum+i*SnakePrice(w); sw=sw+i; w--; }
while(w>=ww) { i--; sum=sum+i*SnakePrice(w); sw=sw+i; w--; }
SA[Shift]=sum/sw; } return; }
//----
double SnakePrice(int Shift) {
switch(PriceConst) {
   case  0: return(Close[Shift]);
   case  1: return(Open[Shift]);
   /*case  2: return(High[Shift]);
   case  3: return(Low[Shift]);*/
   case  4: return((High[Shift]+Low[Shift])/2);
   case  5: return((Close[Shift]+High[Shift]+Low[Shift])/3);
   case  6: return((2*Close[Shift]+High[Shift]+Low[Shift])/4);
   default: return(Open[Shift]); } }
//---------------------------------------------------------------------
void SMCalc(int i) { double t, b;
for(int Shift=i+SR+2;Shift>=i;Shift--) {
t=SA[ArrayMaximum(SA,FP,Shift)]; b=SA[ArrayMinimum(SA,FP,Shift)];
SM[Shift]=(2*(2+SMF)*SA[Shift]-(t+b))/2/(1+SMF); } return; }
//---------------------------------------------------------------------
void LZZCalc(int Pos) { 
int i,RBar,LBar,ZZ,NZZ,NZig,NZag; 
i=Pos-1; NZig=0; NZag=0;
while(i<MaxBar && ZZ==0) { i++; LZZ[i]=0; RBar=i-MainRZZ; 
if(RBar<Pos) RBar=Pos; LBar=i+MainRZZ;
if(i==ArrayMinimum(SM,LBar-RBar+1,RBar)) { ZZ=-1; NZig=i; }
if(i==ArrayMaximum(SM,LBar-RBar+1,RBar)) { ZZ=1;NZag=i; } }
if(ZZ==0) return; NZZ=0;
if(i>Pos) { if(SM[i]>SM[Pos]) { if(ZZ==1) {
if(i>=Pos+MainRZZ && NZZ<5) { NZZ++; LTF[NZZ]=i; } NZag=i; 
LZZ[i]=SM[i]; } }
else { if(ZZ==-1) { if(i>=Pos+MainRZZ && NZZ<5) { NZZ++; LTF[NZZ]=i; }
NZig=i; LZZ[i]=SM[i]; } } }
while(i<LBZZ || NZZ<5) {  LZZ[i]=0; RBar=i-MainRZZ; 
if(RBar<Pos) RBar=Pos; LBar=i+MainRZZ;
if(i==ArrayMinimum(SM,LBar-RBar+1,RBar)) {
if(ZZ==-1 && SM[i]<SM[NZig]) { 
if(i>=Pos+MainRZZ && NZZ<5) LTF[NZZ]=i; LZZ[NZig]=0; LZZ[i]=SM[i]; 
NZig=i; }
if(ZZ==1) { if(i>=Pos+MainRZZ && NZZ<5) { NZZ++; LTF[NZZ]=i; } 
LZZ[i]=SM[i]; ZZ=-1; NZig=i; } }
if(i==ArrayMaximum(SM,LBar-RBar+1,RBar)) {
if(ZZ==1 && SM[i]>SM[NZag]) { 
if(i>=Pos+MainRZZ && NZZ<5) LTF[NZZ]=i; LZZ[NZag]=0; LZZ[i]=SM[i]; 
NZag=i; }
if(ZZ==-1) { if(i>=Pos+MainRZZ && NZZ<5) { NZZ++; LTF[NZZ]=i; } 
LZZ[i]=SM[i]; ZZ=1; NZag=i; } } i++; if(i>MaxBar) return; } 
nLBZZ=Bars-LTF[5]; LZZ[Pos]=SM[Pos]; return; }
//----
void SZZCalc(int Pos) { 
int i,RBar,LBar,ZZ,NZZ,NZig,NZag; 
i=Pos-1; NZig=0; NZag=0;
while(i<=LBZZ && ZZ==0) { i++; pDn[i]=0; pUp[i]=0; Dn[i]=0; Up[i]=0; 
Lmt[i]=0; RBar=i-SRZZ; if(RBar<Pos) RBar=Pos; LBar=i+SRZZ;
if(i==ArrayMinimum(SM,LBar-RBar+1,RBar)) { ZZ=-1; NZig=i; }
if(i==ArrayMaximum(SM,LBar-RBar+1,RBar)) { ZZ=1; NZag=i; } }
if(ZZ==0) return; NZZ=0;
if(i>Pos) { if(SM[i]>SM[Pos]) { if(ZZ==1) {
if(i>=Pos+SRZZ && NZZ<4) { NZZ++; STF[NZZ]=i; } NZag=i; 
Dn[i-1]=Open[i-1]; } }
else { if(ZZ==-1) { if(i>=Pos+SRZZ && NZZ<4) { NZZ++; STF[NZZ]=i; }
NZig=i; Up[i-1]=Open[i-1]; } } }
while(i<=LBZZ || NZZ<4) { pDn[i]=0; pUp[i]=0; Dn[i]=0; Up[i]=0; 
Lmt[i]=0; RBar=i-SRZZ; if(RBar<Pos) RBar=Pos; LBar=i+SRZZ;
if(i==ArrayMinimum(SM,LBar-RBar+1,RBar)) {
if(ZZ==-1 && SM[i]<SM[NZig]) { 
if(i>=Pos+SRZZ && NZZ<4) STF[NZZ]=i; Up[NZig-1]=0; Up[i-1]=Open[i-1]; 
NZig=i; } if(ZZ==1) { if(i>=Pos+SRZZ && NZZ<4) { NZZ++; STF[NZZ]=i; } 
Up[i-1]=Open[i-1]; ZZ=-1; NZig=i;  } }
if(i==ArrayMaximum(SM,LBar-RBar+1,RBar)) {
if(ZZ==1 && SM[i]>SM[NZag]) { 
if(i>=Pos+SRZZ && NZZ<4) STF[NZZ]=i; Dn[NZag-1]=0; Dn[i-1]=Open[i-1]; 
NZag=i; } if(ZZ==-1) { if(i>=Pos+SRZZ && NZZ<4) { NZZ++; STF[NZZ]=i; } 
Dn[i-1]=Open[i-1]; ZZ=1; NZag=i; } } i++; if(i>LBZZ) return; } 
nSBZZ=Bars-STF[4]; return; }
//---------------------------------------------------------------------
void ArrCalc() { int i,j,k,n,z=0; double p, b;
i=LBZZ; while(LZZ[i]==0) i--; j=i; p=LZZ[i]; i--; while(LZZ[i]==0) i--; 
if(LZZ[i]>p) z=1; if(LZZ[i]>0 && LZZ[i]<p) z=-1; p=LZZ[j]; i=j-1;  
while(i>0) { if(LZZ[i]>p) { z=-1; p=LZZ[i]; }
if(LZZ[i]>0 && LZZ[i]<p) { z=1;  p=LZZ[i]; }
if(z>0 && Dn[i]>0) { Lmt[i]=Open[i]; Dn[i]=0; }
if(z<0 && Up[i]>0) { Lmt[i]=Open[i]; Up[i]=0; }
if(z>0 && Up[i]>0) { if(i>1) { j=i-1; k=j-SRZZ+1; if(k<0) k=0; 
n=j; while(n>=k && Dn[n]==0) { pUp[n]=Up[i]; pDn[n]=0; n--; } } 
if(i==1) pUp[0]=Up[i]; } 
if(z<0 && Dn[i]>0) { if(i>1) { j=i-1; k=j-SRZZ+1; if(k<0) k=0; 
n=j; while(n>=k && Up[n]==0) { pDn[n]=Dn[i]; pUp[n]=0; n--; } } 
if(i==1) pDn[0]=Dn[i]; } 
i--; } return; }
//---------------------------------------------------------------------
void deinit() { 
return; }
//---------------------------------------------------------------------
int init() { IndicatorBuffers(8);
SetIndexBuffer(0,Lmt);
SetIndexStyle(0,DRAW_ARROW,EMPTY,indicator_width1); SetIndexArrow(0,167);
SetIndexEmptyValue(0,0.0);
SetIndexBuffer(1,LZZ);
if(DrawZZ) {
SetIndexStyle(1,DRAW_SECTION,EMPTY,2);
SetIndexEmptyValue(1,0.0); }
else SetIndexStyle(1,DRAW_NONE);
SetIndexBuffer(2,SA); SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(3,SM); SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(4,Up); SetIndexStyle(4,DRAW_ARROW,EMPTY,indicator_width6);//Green up arrow
SetIndexArrow(4,233); SetIndexEmptyValue(4,0.0);
SetIndexBuffer(5,Dn); SetIndexStyle(5,DRAW_ARROW,EMPTY,indicator_width6);//Red down arrow
SetIndexArrow(5,234); SetIndexEmptyValue(5,0.0);
SetIndexBuffer(6,pUp); SetIndexStyle(6,DRAW_ARROW,EMPTY,indicator_width7);//Green up markers
SetIndexArrow(6,104); SetIndexEmptyValue(6,0.0);
SetIndexBuffer(7,pDn); SetIndexStyle(7,DRAW_ARROW,EMPTY,indicator_width8);//Red down markers
SetIndexArrow(7,104); SetIndexEmptyValue(7,0.0); return(0); }//167
//---------------------------------------------------------------------
int start() { int counted_bars=IndicatorCounted(); int limit,i,j,n;
if(counted_bars<0) return(-1); if(counted_bars>0) counted_bars--;
if(First==true) { 
if(SR<2) SR=2; if(Bars<=2*(MainRZZ+FP+SR+2)) return(-1); 
if(SRZZ<=SR) SRZZ=SR+1; MaxBar=Bars-(MainRZZ+FP+SR+2);
LBZZ=MaxBar; SBZZ=LBZZ; prevBars=Bars; First=false; }
limit=Bars-counted_bars; for(i=limit;i>=0;i--) { MainCalculation(i); }
if(prevBars!=Bars) { SBZZ=Bars-nSBZZ; LBZZ=Bars-nLBZZ; prevBars=Bars; } 
SZZCalc(0); LZZCalc(0); ArrCalc(); 

/*//////////////////////////
      ObjectDelete("tx01");
      ObjectCreate("tx01", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("tx01", DoubleToStr(pDn,2), 25, "Arial Bold", LimeGreen);
      ObjectSet("tx01", OBJPROP_CORNER, 1);
      ObjectSet("tx01", OBJPROP_BACK, true);
      ObjectSet("tx01", OBJPROP_XDISTANCE, 20);
      ObjectSet("tx01", OBJPROP_YDISTANCE, 200);
      *////////////////////////////////////////

return(0); }
//---------------------------------------------------------------------

