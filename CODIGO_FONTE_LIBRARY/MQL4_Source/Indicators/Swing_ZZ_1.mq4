//+------------------------------------------------------------------+
//|                                                   Swing_ZZ_1.mq4 |
//+------------------------------------------------------------------+
#property copyright "onix"
#property link      "http://onix-trade.net/forum/index.php?s=&showtopic=4786&view=findpost&p=275885"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_width2 2
#property indicator_width3 2

//---- indicator parameters
extern int minBars = 1;
extern int ExtLabel= 1; 

//---- indicator buffers
double zzL[];
double zzH[];
double zz[];

int cbi;
double lLast=0,hLast=0, hBar, lBar; 
int fs=0; 
int ai,bi,ai0,bi0,aim,bim; 
datetime tai,tbi,ti, tmh, tml, tiZZ; 
// Переменные для Свингов Ганна
double lLast_m=0, hLast_m=0;
int countBarExt; // счетчик внешних баров
int countBarl,countBarh;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
 //  IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexArrow(2,159);
//---- indicator buffers mapping
   SetIndexBuffer(0,zz);
   SetIndexBuffer(1,zzH);
   SetIndexBuffer(2,zzL);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
     
//---- indicator short name
   IndicatorShortName("Swing_ZZ("+minBars+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
 
   int i,n;


// lLast, hLast - минимум и максимум активного бара
// lLast_m, hLast_m - минимум и максимум "промежуточных" баров

   if (lBar<=Low[0] && hBar>=High[0] && tiZZ==Time[0]) return(0);
   else {lBar=Low[0]; hBar=High[0]; tiZZ=Time[0];}

//   cbi=Bars-IndicatorCounted();
   cbi=Bars-1; 

    ArrayInitialize(zz,0.0);
    ArrayInitialize(zzL,0.0);
    ArrayInitialize(zzH,0.0);


//---------------------------------
   for (i=cbi; i>=0; i--) 
     {
//-------------------------------------------------
      // Устанавливаем начальные значения минимума и максимума бара
      if (lLast==0) {lLast=Low[i]; hLast=High[i]; ai=i; bi=i;}
      if (ti!=Time[i])
        {
         ti=Time[i];
         if (lLast_m==0 && hLast_m==0)
           {
            if (lLast>Low[i] && hLast<High[i]) // Внешний бар
              {
               lLast=Low[i];hLast=High[i];lLast_m=Low[i];hLast_m=High[i];countBarExt++;
               if (fs==1) {countBarl=countBarExt; ai=i; tai=Time[i];}
               else if (fs==2) {countBarh=countBarExt; bi=i; tbi=Time[i];}
               else {countBarl++;countBarh++;}
              }
            else if (lLast<=Low[i] && hLast<High[i]) // Тенденция на текущем баре восходящая
              {
               lLast_m=0;hLast_m=High[i];countBarl=0;countBarExt=0;
               if (fs!=1) countBarh++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; ai=i; tai=Time[i];}
              }
            else if (lLast>Low[i] && hLast>=High[i]) // Тенденция на текущем баре нисходящая
              {
               lLast_m=Low[i];hLast_m=0;countBarh=0;countBarExt=0;
               if (fs!=2) countBarl++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; bi=i; tbi=Time[i];}
              }
           }
         else  if (lLast_m>0 && hLast_m>0) // Внешний бар (предыдущий)
           {
            if (lLast_m>Low[i] && hLast_m<High[i]) // Внешний бар
              {
               lLast=Low[i];hLast=High[i];lLast_m=Low[i];hLast_m=High[i];countBarExt++;
               if (fs==1) {countBarl=countBarExt; ai=i; tai=Time[i];}
               else if (fs==2) {countBarh=countBarExt; bi=i; tbi=Time[i];}
               else {countBarl++;countBarh++;}
              }
            else if (lLast_m<=Low[i] && hLast_m<High[i]) // Тенденция на текущем баре восходящая
              {
               lLast_m=0;hLast_m=High[i];countBarl=0;countBarExt=0;
               if (fs!=1) countBarh++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; ai=i; tai=Time[i];}
              }
            else if (lLast_m>Low[i] && hLast_m>=High[i]) // Тенденция на текущем баре нисходящая
              {
               lLast_m=Low[i];hLast_m=0;countBarh=0;countBarExt=0;
               if (fs!=2) countBarl++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; bi=i; tbi=Time[i];}
              }
           }
         else  if (lLast_m>0)
           {
            if (lLast_m>Low[i] && hLast<High[i]) // Внешний бар
              {
               lLast=Low[i];hLast=High[i];lLast_m=Low[i];hLast_m=High[i];countBarExt++;
               if (fs==1) {countBarl=countBarExt; ai=i; tai=Time[i];}
               else if (fs==2) {countBarh=countBarExt; bi=i; tbi=Time[i];}
               else {countBarl++;countBarh++;}
              }
            else if (lLast_m<=Low[i] && hLast<High[i]) // Тенденция на текущем баре восходящая
              {
               lLast_m=0;hLast_m=High[i];countBarl=0;countBarExt=0;
               if (fs!=1) countBarh++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; ai=i; tai=Time[i];}
              }
            else if (lLast_m>Low[i] && hLast>=High[i]) // Тенденция на текущем баре нисходящая
              {
               lLast_m=Low[i];hLast_m=0;countBarh=0;countBarExt=0;
               if (fs!=2) countBarl++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; bi=i; tbi=Time[i];}
              }
           }
         else  if (hLast_m>0)
           {
            if (lLast>Low[i] && hLast_m<High[i]) // Внешний бар
              {
               lLast=Low[i];hLast=High[i];lLast_m=Low[i];hLast_m=High[i];countBarExt++;
               if (fs==1) {countBarl=countBarExt; ai=i; tai=Time[i];}
               else if (fs==2) {countBarh=countBarExt; bi=i; tbi=Time[i];}
               else {countBarl++;countBarh++;}
              }
            else if (lLast<=Low[i] && hLast_m<High[i]) // Тенденция на текущем баре восходящая
              {
               lLast_m=0;hLast_m=High[i];countBarl=0;countBarExt=0;
               if (fs!=1) countBarh++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; ai=i; tai=Time[i];}
              }
            else if (lLast>Low[i] && hLast_m>=High[i]) // Тенденция на текущем баре нисходящая
              {
               lLast_m=Low[i];hLast_m=0;countBarh=0;countBarExt=0;
               if (fs!=2) countBarl++;
               else {lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0; bi=i; tbi=Time[i];}
              }
           }

         // Определяем направление тренда. 
         if (fs==0)
           {
            if (lLast<lLast_m && hLast>hLast_m) // внутренний бар
              {
               lLast=Low[i]; hLast=High[i]; ai=i; bi=i; countBarl=0;countBarh=0;countBarExt=0;
              }
              
            if (countBarh>countBarl && countBarh>countBarExt && countBarh>minBars)
              {
               lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0;
               fs=1;countBarh=0;countBarl=0;countBarExt=0;
               zz[bi]=Low[bi];
               zzL[bi]=Low[bi];
               zzH[bi]=0;
               ai=i;
               tai=Time[i];
              }
            else if (countBarl>countBarh && countBarl>countBarExt && countBarl>minBars)
              {
               lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0;
               fs=2;countBarl=0;countBarh=0;countBarExt=0;
               zz[ai]=High[ai];
               zzH[ai]=High[ai];
               zzL[ai]=0;
               bi=i;
               tbi=Time[i];
              }
           }
         else
           {
            if (lLast_m==0 && hLast_m==0)
              {
               countBarl=0;countBarh=0;countBarExt=0;
              }

            // Тенденция восходящая
            if (fs==1)
              {
                  if (countBarl>countBarh && countBarl>countBarExt && countBarl>minBars) // Определяем точку смены тенденции.
                    {
                     // запоминаем значение направления тренда fs на предыдущем баре
                     ai=iBarShift(Symbol(),Period(),tai); 
                     fs=2;
                     countBarl=0;

                     zz[ai]=High[ai];
                     zzH[ai]=High[ai];
                     zzL[ai]=0;
                     if (ExtLabel>0) {zzH[ai]=High[ai]; zzL[ai]=0; tml=Time[i]; zzH[i]=0; zzL[i]=Low[i];}
                     bi=i;
                     tbi=Time[i];

                     lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0;

                     for (n=0;countBarExt<minBars;n++) 
                       {
                        if (lLast<Low[i+n+1] && hLast>High[i+n+1]) {countBarExt++; countBarh++; lLast=Low[i+n+1]; hLast=High[i+n+1]; hLast_m=High[i];}
                        else break;
                       }

                     lLast=Low[i]; hLast=High[i];
                    }
              }

            // Тенденция нисходящая
            if (fs==2)
              {
                  if (countBarh>countBarl && countBarh>countBarExt && countBarh>minBars) // Определяем точку смены тенденции.
                    {
                     // запоминаем значение направления тренда fs на предыдущем баре
                     bi=iBarShift(Symbol(),Period(),tbi);
                     fs=1;
                     countBarh=0;

                     zz[bi]=Low[bi];
                     zzL[bi]=Low[bi];
                     zzH[bi]=0;
                     if (ExtLabel>0) {zzH[bi]=0; zzL[bi]=Low[bi]; tmh=Time[i]; zzH[i]=High[i]; zzL[i]=0;}
                     ai=i;
                     tai=Time[i];

                     lLast=Low[i]; hLast=High[i]; lLast_m=0; hLast_m=0;

                     for (n=0;countBarExt<minBars;n++) 
                       {
                        if (lLast<Low[i+n+1] && hLast>High[i+n+1]) {countBarExt++; countBarl++; lLast=Low[i+n+1]; hLast=High[i+n+1]; lLast_m=Low[i];}
                        else break;
                       }

                     lLast=Low[i]; hLast=High[i];
                    }
              }
           } 
        } 

       if (i==0)
         {
          if (hLast<High[i] && fs==1) // Тенденция на текущем баре восходящая
            {
             ai=i; tai=Time[i]; zz[ai]=High[ai]; zzH[ai]=High[ai]; zzL[ai]=0;
            }
          else if (lLast>Low[i] && fs==2) // Тенденция на текущем баре нисходящая
            {
             bi=i; tbi=Time[i]; zz[bi]=Low[bi]; zzL[bi]=Low[bi]; zzH[bi]=0;
            }
//===================================================================================================
      // Нулевой бар. Расчет первого луча ZigZag-a

          ai0=iBarShift(Symbol(),0,tai); 
          bi0=iBarShift(Symbol(),0,tbi);

          if (bi0>1) if (fs==1) {for (n=bi0-1; n>=0; n--) {zzH[n]=0.0; zz[n]=0.0;} zz[ai0]=High[ai0]; zzH[ai0]=High[ai0]; zzL[ai0]=0.0;}         
          if (ai0>1) if (fs==2) {for (n=ai0-1; n>=0; n--) {zzL[n]=0.0; zz[n]=0.0;} zz[bi0]=Low[bi0]; zzL[bi0]=Low[bi0]; zzH[bi0]=0.0;}
          if (ExtLabel>0)
            {
             if (fs==1) {aim=iBarShift(Symbol(),0,tmh); zzH[aim]=High[aim];}
             else if (fs==2) {bim=iBarShift(Symbol(),0,tml); zzL[bim]=Low[bim];}
            }

          if (ti<Time[1]) i=2;

         }
//====================================================================================================

     }
//--------------------------------------------
   
return(0);
}
//+------------------------------------------------------------------+