//+++======================================================================+++
//+++                   ArrZZx2 Alerts Final Draft TT                      +++
//+++======================================================================+++
#property copyright   "©  Tankk,  12  September  2016,  http://forexsystems.ru/" 
#property link        "http://forexsystemsru.com/indikatory-foreks-f41/" 
#property description "ArrZZx2.mq4: автор - Bookkeeper, 22.04.2007, yuzefovich@gmail.com  //  http://www.forexter.land.ru/indicators.htm"
#property description "*****************************************************************************************************"
#property description "Анализ движений цены по High/Low, с применением ZigZag и Moving Average." 
#property description "Построение динамических Уровней поддержки/сопротивления." 
#property description "Индикатор перерисовывается!!!"
//#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1  LightCyan  //White
#property indicator_color2  LimeGreen
#property indicator_color3  DeepSkyBlue  //Aqua
#property indicator_color4  Orchid  //Violet
#property indicator_color5  DeepSkyBlue  //Aqua
#property indicator_color6  Orchid  //Violet
#property indicator_color7  OrangeRed
#property indicator_color8  DodgerBlue

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  2
#property indicator_width8  2

//+++======================================================================+++
//+++                 Custom indicator input parameters                    +++
//+++======================================================================+++

extern int                   ZZPeriod  =  15,    //12;//20; // =12..20..54..20
                          ArrSRLength  =  15;    //5; // =4..12..20..12

extern bool                ShowZigZag  =  true,
                            ShowArrSR  =  true;
extern int                  ArrSRCode  =  104;

extern bool                   ShowMAs  =  false;
extern int                   MAPeriod  =  3;    // =3..4 [значение SR]
extern ENUM_APPLIED_PRICE  PriceConst  =  PRICE_CLOSE; 
extern int                 FlowPeriod  =  12,    //21    [значение FP]
                           FlowSmooth  =  3;     // =1..5   //[значение SMF]
                           
extern bool             AlertsMessage  =  true,         //Сигнал в виде Сообщения
                          AlertsSound  =  true,         //Звуковой Сигнал
                          AlertsEmail  =  false,        //Сообщение на электронную почту
                         AlertsMobile  =  false;        //Сообщение на смартфон
extern string               SoundFile  =  "news.wav";   //Звук сигнала (исполняемый файл)
extern int                   AlertBar  =  5;            //На каком Баре сигналить

//+++======================================================================+++
//+++                     Custom indicator buffers                         +++
//+++======================================================================+++
double  Lmt[],  LZZ[];
double  Up[],   Dn[];
double  pUp[],  pDn[];
double  SA[],   SM[];
//+++======================================================================+++
int LTF[6]={0,0,0,0,0,0}, STF[5]={0,0,0,0,0}; 
int MaxBar, nSBZZ, nLBZZ, SBZZ, LBZZ;
bool First=true;   int prevBars=0;   int TimeBar=0; 
//+++======================================================================+++
//+++              Custom indicator initialization function                +++
//+++======================================================================+++

int init()
{ 
   IndicatorBuffers(8);
   
   SetIndexBuffer(0,Lmt);   SetIndexBuffer(1,LZZ);
   SetIndexBuffer(2,Up);    SetIndexBuffer(3,Dn);
   SetIndexBuffer(4,pUp);   SetIndexBuffer(5,pDn);
   SetIndexBuffer(6,SA);    SetIndexBuffer(7,SM);
   
   SetIndexStyle(0,DRAW_ARROW);   SetIndexArrow(0,110);
   
   int ZZT = DRAW_NONE;    if (ShowZigZag) ZZT = DRAW_SECTION;
   SetIndexStyle(1,ZZT);   
   
   int ASR = DRAW_NONE;    if (ShowArrSR) ASR = DRAW_ARROW;
   SetIndexStyle(2,ASR);  SetIndexArrow(2,ArrSRCode);  //Green up arrow
   SetIndexStyle(3,ASR);  SetIndexArrow(3,ArrSRCode);  //Red down arrow
   SetIndexStyle(4,ASR);  SetIndexArrow(4,ArrSRCode);  //Green up markers
   SetIndexStyle(5,ASR);  SetIndexArrow(5,ArrSRCode);  //Red down markers

   int MAT = DRAW_NONE;    if (ShowMAs) MAT = DRAW_LINE;
   SetIndexStyle(6,MAT);   
   SetIndexStyle(7,MAT);   
   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   
   SetIndexLabel(0,"Limit Point");
   SetIndexLabel(1,"ZigZag ["+ZZPeriod+"]");
   
   SetIndexLabel(2,"preUP");
   SetIndexLabel(3,"preDN");
   SetIndexLabel(4,"Trend UP ["+ArrSRLength+"]");
   SetIndexLabel(5,"Trend DN ["+ArrSRLength+"]");
   
   SetIndexLabel(6,"SA DN ["+MAPeriod+"-"+FlowPeriod+"*"+FlowSmooth+"]");
   SetIndexLabel(7,"SM UP ["+MAPeriod+"-"+FlowPeriod+"*"+FlowSmooth+"]");

   IndicatorShortName("ArrZZx2 FD TT ["+ZZPeriod+"]*["+MAPeriod+"]");
   
//---//---//---
return(0);
}
//+++======================================================================+++
//+++              Custom indicator deinitialization function              +++
//+++======================================================================+++
void deinit() { return; }
//+++======================================================================+++
//+++                 Custom indicator iteration function                  +++
//+++======================================================================+++

int start() 
{ 
   int counted_bars=IndicatorCounted(); 
   int i, limit;
   if (counted_bars<0) return(-1); 
   if (counted_bars>0) counted_bars--;
   
   if (First==true) 
    { 
     if (MAPeriod<2) MAPeriod=2;
     if (Bars<=2*(ZZPeriod+FlowPeriod+MAPeriod+2))
     return(-1); 
   
     if (ArrSRLength<=MAPeriod) ArrSRLength=MAPeriod+1; MaxBar=Bars-(ZZPeriod+FlowPeriod+MAPeriod+2);
     LBZZ=MaxBar; SBZZ=LBZZ; prevBars=Bars; First=false; 
   }
   
   limit=Bars-counted_bars; 
   
   for (i=limit; i>=0; i--) { MainCalculation(i); }
   
   if (prevBars!=Bars) 
    { 
     SBZZ=Bars-nSBZZ; 
     LBZZ=Bars-nLBZZ; prevBars=Bars; 
    } 
    
   SZZCalc(0); LZZCalc(0); ArrCalc(); 
//+++======================================================================+++

     if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound) 
      {
       string messageAA;
       
       if (TimeBar!=Time[0] && (pUp[0+AlertBar] > 0 && pUp[0+1+AlertBar] <= 0))   //(First1[0] > Secnd1[0] && First2[1] < Secnd2[1]) = сигнал на "0" баре
        {
         messageAA =("ArrZZx2 FD TT - "+Symbol()+", TF ["+IntegerToString(Period())+"] - draw Support  =  Signal  BUY");   //Triline 6 MTF TT [x2x3x3x4x1x3x8x8]
         if (AlertsMessage) Alert(messageAA);
         if (AlertsEmail)   SendMail(Symbol(),messageAA);
         if (AlertsMobile)  SendNotification(messageAA);
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"
         TimeBar=Time[0];
         //return(0);
        } 
       
       else if (TimeBar!=Time[0] && (pDn[0+AlertBar] > 0 && pDn[0+1+AlertBar] <= 0))   //(First1[0] < Secnd1[0] && First2[1] > Secnd2[1]) = сигнал на "0" баре
        { 
         messageAA =("ArrZZx2 FD TT - "+Symbol()+", TF ["+IntegerToString(Period())+"] - draw Resistance  =  Signal  SELL");   //Triline 6 MTF TT [x2x3x3x4x1x3x8x8]
         if (AlertsMessage) Alert(messageAA);
         if (AlertsEmail)   SendMail(Symbol(),messageAA);
         if (AlertsMobile)  SendNotification(messageAA);
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"
         TimeBar=Time[0];
         //return(0);
        }
      }         
//+++======================================================================+++
//---//---//---
return(0);
}
//+++======================================================================+++
//+++                   ArrZZx2 Alerts Final Draft TT                      +++
//+++======================================================================+++
void MainCalculation (int Pos) 
{
   if ((Bars-Pos)>(MAPeriod+1))            SACalc(Pos);  else SA[Pos]=0; 
   if ((Bars-Pos)>(FlowPeriod+MAPeriod+2)) SMCalc(Pos);  else SM[Pos]=0; 
//---
return; 
}
//+++======================================================================+++
//+++======================================================================+++
void SACalc(int Pos) 
{ 
   int sw, i, w, ww, Shift; double sum; 
   
   switch (PriceConst) 
    {
     case  0:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_CLOSE,Pos);    break;
     case  1:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_OPEN,Pos);     break;
     case  2:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_HIGH,Pos);     break;
     case  3:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_LOW,Pos);      break;
     case  4:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_MEDIAN,Pos);   break;
     case  5:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_TYPICAL,Pos);  break;
     case  6:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_WEIGHTED,Pos); break;
     default:  SA[Pos]=iMA(NULL,0,MAPeriod+1,0,MODE_LWMA,PRICE_OPEN,Pos);     break; 
    }
    
   for (Shift=Pos+MAPeriod+2; Shift>Pos; Shift--) 
    { 
     sum=0.0;  sw=0;  i=0;  w=Shift+MAPeriod;
     ww=Shift-MAPeriod;  
     
     if (ww<Pos) ww=Pos;
     
     while (w>=Shift) {i++; sum=sum+i*SnakePrice(w);  sw=sw+i; w--; }
     while (w>=ww)    {i--; sum=sum+i*SnakePrice(w);  sw=sw+i; w--; }
     
     SA[Shift]=sum/sw; 
    } 
//---
return; 
}
//+++======================================================================+++
//+++======================================================================+++
double SnakePrice (int Shift) 
{
   switch (PriceConst) 
   {
    case  0: return (Close[Shift]);
    case  1: return (Open[Shift]);
    case  2: return (High[Shift]);
    case  3: return (Low[Shift]);
    case  4: return ((High[Shift]+Low[Shift])/2);
    case  5: return ((Close[Shift]+High[Shift]+Low[Shift])/3);
    case  6: return ((2*Close[Shift]+High[Shift]+Low[Shift])/4);
    default: return (Open[Shift]); 
  } 
}
//+++======================================================================+++
//+++======================================================================+++
void SMCalc (int i) 
{ 
   double t, b;
   for (int Shift=i+MAPeriod+2; Shift>=i; Shift--)
    {
     t=SA[ArrayMaximum(SA,FlowPeriod,Shift)];  b=SA[ArrayMinimum(SA,FlowPeriod,Shift)];
     SM[Shift]=(2*(2+FlowSmooth)*SA[Shift]-(t+b))/2/(1+FlowSmooth); 
    } 
//---
return; 
}
//+++======================================================================+++
//+++                   ArrZZx2 Alerts Final Draft TT                      +++
//+++======================================================================+++
void LZZCalc (int Pos) 
{ 
   int i, RBar, LBar, ZZ, NZZ, NZig, NZag; 
   
   i=Pos-1;  NZig=0;  NZag=0;
   
   while (i<MaxBar && ZZ==0) 
    { 
     i++;  
     LZZ[i]=0;  RBar=i-ZZPeriod; 
     if (RBar<Pos) RBar=Pos;  LBar=i+ZZPeriod;
     if (i==ArrayMinimum(SM,LBar-RBar+1,RBar)) { ZZ=-1; NZig=i; }
     if (i==ArrayMaximum(SM,LBar-RBar+1,RBar)) { ZZ=1;NZag=i; } 
    }

   if (ZZ==0) return;  NZZ=0;
//---//---

   if (i>Pos) 
    { 
     if (SM[i]>SM[Pos]) { if (ZZ==1)  { if (i>=Pos+ZZPeriod && NZZ<5) { NZZ++; LTF[NZZ]=i; } NZag=i; LZZ[i]=SM[i]; } }
     else               { if (ZZ==-1) { if (i>=Pos+ZZPeriod && NZZ<5) { NZZ++; LTF[NZZ]=i; } NZig=i; LZZ[i]=SM[i]; } } 
    }
//---//---
   while (i<LBZZ || NZZ<5) 
    { 
     LZZ[i]=0; RBar=i-ZZPeriod; 

     if (RBar<Pos) RBar=Pos; LBar=i+ZZPeriod;

     if (i==ArrayMinimum(SM,LBar-RBar+1,RBar))  
      { 
       if (ZZ==-1 && SM[i]<SM[NZig]) { if (i>=Pos+ZZPeriod && NZZ<5) LTF[NZZ]=i; LZZ[NZig]=0; LZZ[i]=SM[i];  NZig=i; }
       if (ZZ==1)  { if (i>=Pos+ZZPeriod && NZZ<5) { NZZ++; LTF[NZZ]=i; } LZZ[i]=SM[i]; ZZ=-1; NZig=i; } 
      }

     if (i==ArrayMaximum(SM,LBar-RBar+1,RBar))  
      { 
       if (ZZ==1 && SM[i]>SM[NZag])  { if(i>=Pos+ZZPeriod && NZZ<5) LTF[NZZ]=i; LZZ[NZag]=0; LZZ[i]=SM[i];  NZag=i; }
       if (ZZ==-1) { if (i>=Pos+ZZPeriod && NZZ<5) { NZZ++; LTF[NZZ]=i; } LZZ[i]=SM[i]; ZZ=1; NZag=i; } 
      } 
     
     i++; 
     if (i>MaxBar) return; 
    } 

   nLBZZ=Bars-LTF[5];  LZZ[Pos]=SM[Pos];  
//---
return; 
}
//+++======================================================================+++
//+++======================================================================+++
void SZZCalc (int Pos) 
{ 
   int i, RBar, LBar, ZZ, NZZ, NZig, NZag; 
   
   i=Pos-1; NZig=0; NZag=0;
   
   while (i<=LBZZ && ZZ==0) 
    { 
     i++; 
     pDn[i]=0; pUp[i]=0; Dn[i]=0; Up[i]=0; 
     Lmt[i]=0; RBar=i-ArrSRLength;  
     if (RBar<Pos)RBar=Pos; LBar=i+ArrSRLength;
     if (i==ArrayMinimum(SM,LBar-RBar+1,RBar)) { ZZ=-1; NZig=i; }
     if (i==ArrayMaximum(SM,LBar-RBar+1,RBar)) { ZZ=1;  NZag=i; } 
    }
    
   if (ZZ==0) return;  NZZ=0;
//---
   
   if (i>Pos) 
    { 
     if (SM[i]>SM[Pos]) { if (ZZ==1)  { if (i>=Pos+ArrSRLength && NZZ<4) { NZZ++; STF[NZZ]=i; } NZag=i;  Dn[i-1]=Open[i-1]; } }
     else               { if (ZZ==-1) { if (i>=Pos+ArrSRLength && NZZ<4) { NZZ++; STF[NZZ]=i; } NZig=i;  Up[i-1]=Open[i-1]; } } 
    }
//---//---
   while (i<=LBZZ || NZZ<4) 
    {
     pDn[i]=0; pUp[i]=0; Dn[i]=0; Up[i]=0; 
     
     Lmt[i]=0; RBar=i-ArrSRLength; if (RBar<Pos) RBar=Pos; LBar=i+ArrSRLength;
     
     if (i==ArrayMinimum(SM,LBar-RBar+1,RBar)) 
      { 
       if (ZZ==-1 && SM[i]<SM[NZig]) { if (i>=Pos+ArrSRLength && NZZ<4) STF[NZZ]=i; Up[NZig-1]=0; Up[i-1]=Open[i-1];  NZig=i; } 
       if (ZZ==1) { if (i>=Pos+ArrSRLength && NZZ<4) { NZZ++; STF[NZZ]=i; }                       Up[i-1]=Open[i-1];  ZZ=-1; NZig=i; } 
      }
     
     if (i==ArrayMaximum(SM,LBar-RBar+1,RBar)) 
      {
       if (ZZ==1 && SM[i]>SM[NZag]) { if (i>=Pos+ArrSRLength && NZZ<4) STF[NZZ]=i; Dn[NZag-1]=0; Dn[i-1]=Open[i-1];  NZag=i; } 
       if (ZZ==-1) { if (i>=Pos+ArrSRLength && NZZ<4) { NZZ++; STF[NZZ]=i; }                     Dn[i-1]=Open[i-1];  ZZ=1; NZag=i; } 
      } 
       
     i++; 
     if (i>LBZZ) return; 
    } 
    
   nSBZZ=Bars-STF[4]; 
//---
return; 
}
//+++======================================================================+++
//+++======================================================================+++
void ArrCalc() 
{ 
   int i, j ,k, n, z=0; double p;
   
   i=LBZZ;  while (LZZ[i]==0)  i--;  j=i;  p=LZZ[i];  i--;  while(LZZ[i]==0) i--; 
   
   if (LZZ[i]>p)  z=1;  if (LZZ[i]>0 && LZZ[i]<p)  z=-1;  p=LZZ[j];  i=j-1; 
    
   while (i>0) 
    { 
     if(LZZ[i]>p) { z=-1; p=LZZ[i]; }
   
     if (LZZ[i]>0 && LZZ[i]<p) { z=1;  p=LZZ[i]; }
     
     if (z>0 && Dn[i]>0) { Lmt[i]=Open[i]; Dn[i]=0; }
     if (z<0 && Up[i]>0) { Lmt[i]=Open[i]; Up[i]=0; }
     
     if (z>0 && Up[i]>0) 
      { 
       if (i>1) 
        { 
         j=i-1;  k=j-ArrSRLength+1; if (k<0)  k=0;  n=j; 
         while (n>=k && Dn[n]==0) { pUp[n]=Up[i]; pDn[n]=0; n--; } 
        } 
     
       if (i==1)  pUp[0]=Up[i]; 
      } 
     
     if (z<0 && Dn[i]>0) 
      { 
       if (i>1) 
        { 
         j=i-1;  k=j-ArrSRLength+1;  if(k<0)  k=0;  n=j; 
         while (n>=k && Up[n]==0) { pDn[n]=Dn[i];  pUp[n]=0;  n--; } 
        } 
       
       if(i==1) pDn[0]=Dn[i]; 
      } 
//---
     i--; 
    } 
//---//---
return; 
}
//+++======================================================================+++
//+++                   ArrZZx2 Alerts Final Draft TT                      +++
//+++======================================================================+++