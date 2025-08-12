//-------------------------------------------------------------------
//       original : ANG3110                                                           
//       this version : mladen
//-------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color3 LightSlateGray
#property indicator_color4 DodgerBlue
#property indicator_color5 SandyBrown
#property indicator_color6 SandyBrown
#property indicator_style3 STYLE_DOT
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

extern int    period = 14;
extern int    Level  = 25;
extern double Smooth = 15;
extern string Prefix = "ADXm nrp 2";
extern color  arrowsUpColor = clrDodgerBlue;  //
extern color  arrowsDnColor = clrSandyBrown; //
extern int    arrowsUpCode  = 233;          //
extern int    arrowsDnCode  = 234;          //
extern int    arrowsUpSize  = 3;            //
extern int    arrowsDnSize  = 3;            //
double ADX[],ADXLa[],ADXLb[],DI[],UP[],DN[];

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

int init()
{

   SetIndexBuffer(0,UP);
   SetIndexBuffer(1,DN);
   
   SetIndexBuffer(2,DI);
   SetIndexBuffer(3,ADX);
   SetIndexBuffer(4,ADXLa);
   SetIndexBuffer(5,ADXLb);
      SetLevelValue(2,0);
      SetLevelValue(3, Level);
      SetLevelValue(4,-Level);
   IndicatorShortName("ADXm "+"("+period+","+DoubleToStr(Smooth,2)+")");
   return(0);
}

int deinit()
{
   ObjectDelete(Prefix);
   deleteArrows();
   return(0);
}
//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

double work[][4];
#define zdh   0
#define zdl   1
#define zdx   2
#define slope 3

int start()
{
   int i,r,counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         double alpha = 2.0/(period+1);
         int limit    = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //
   
   if (work[limit][slope]==-1) CleanPoint(limit,ADXLa,ADXLb);
   for (i=limit,r=Bars-i-1; i>=0; i--,r++)
   {
   
      ObjectDelete(Prefix+":1:"+TimeToStr(Time[i]));
      string lookFor = Prefix+":"+TimeToStr(Time[i]); ObjectDelete(lookFor);
      
      if (i==Bars-1) { work[r][zdh] = 0; work[r][zdl] = 0; work[r][zdx] = 0;  continue; }
      
         double hc = iSsm(High[i]   ,Smooth,i,0);
         double lc = iSsm(Low[i]    ,Smooth,i,1);
         double cp = iSsm(Close[i+1],Smooth,i,2);
         double hp = iSsm(High[i+1] ,Smooth,i,3);
         double lp = iSsm(Low[i+1]  ,Smooth,i,4);
         double dh = MathMax(hc-hp,0);
         double dl = MathMax(lp-lc,0);
         
      if(dh==dl) {dh=0; dl=0;} else if(dh<dl) dh=0; else if(dl<dh) dl=0;
      
         double num1 = MathAbs(hc-lc);
         double num2 = MathAbs(hc-cp);
         double num3 = MathAbs(lc-cp);
         double tr   = MathMax(MathMax(num1,num2),num3);
         double dhk  = 0;
         double dlk  = 0;
      
            if(tr!=0) { dhk = 100.0*dh/tr; dlk = 100.0*dl/tr; }
      
         work[r][zdh] = work[r-1][zdh] + alpha*(dhk-work[r-1][zdh]);
         work[r][zdl] = work[r-1][zdl] + alpha*(dlk-work[r-1][zdl]);
         DI[i]        = work[r][zdh] - work[r][zdl];

            double div  = MathAbs(work[r][zdh] + work[r][zdl]);
            double temp = 0; if( div != 0.0)  temp = 100*(MathAbs(DI[i])/div); 
               if (work[r][zdh]<work[r][zdl]) temp = -temp;
      
         work[r][zdx]   = work[r-1][zdx] + alpha*(temp-work[r-1][zdx]);
         ADX[i]         = work[r][zdx];
         ADXLa[i]       = EMPTY_VALUE;
         ADXLb[i]       = EMPTY_VALUE;
         work[r][slope] = work[r-1][slope];
      
      if (ADX[i]>ADX[i+1]) work[r][slope] =  1;
      if (ADX[i]<ADX[i+1]) work[r][slope] = -1;
      if (work[r][slope]==-1) PlotPoint(i,ADXLa,ADXLb,ADX);
      
      if (ADX[i]>ADX[i+1] && ADX[i+1]<ADX[i+2]) 
      {
      UP[i]=1;
      drawArrowUP("1",1,i,arrowsUpColor,arrowsUpCode,arrowsUpSize);
      } 
      else UP[i]=EMPTY_VALUE;
      
      if (ADX[i]<ADX[i+1] && ADX[i+1]>ADX[i+2]) 
      {
      DN[i]=1; 
      drawArrowDN("1",1,i,arrowsDnColor,arrowsDnCode,arrowsDnSize);
      }
      else DN[i]=EMPTY_VALUE;
   }
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define Pi 3.14159265358979323846264338327950288
double workSsm[][10];
#define _tprice 0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3

//
//
//
//
//

double iSsm(double tprice, double tperiod, int i, int instanceNo=0)
{
   if (tperiod<=1) return(tprice); i = Bars-i-1;
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != tperiod)
   {
      workSsmCoeffs[instanceNo][_period] = tperiod;
      double a1 = MathExp(-1.414*Pi/tperiod);
      double b1 = 2.0*a1*MathCos(1.414*Pi/tperiod);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2;   
          workSsm[i][s+_tprice] = tprice;
          if (i>1)
              workSsm[i][s+_ssm]   = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                                     workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                                + 
                                     workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm]; 
         else workSsm[i][s+_ssm] = tprice;
   return(workSsm[i][s+_ssm]);
}

void drawArrowUP(string nameAdd, double gapMul, int i,color theColor,int theCode,int theWidth)
{
   string name = Prefix+":"+nameAdd+":"+TimeToStr(Time[i]);
   double gap  = iATR(NULL,0,20,i)*gapMul;

   ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
   ObjectSet(name,OBJPROP_ARROWCODE,theCode);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   ObjectSet(name,OBJPROP_WIDTH,theWidth);
   ObjectSetDouble(0,name,OBJPROP_PRICE1,Low[i]);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_TOP);
   
   WindowRedraw();
}

void drawArrowDN(string nameAdd, double gapMul, int i,color theColor,int theCode,int theWidth)
{
   string name = Prefix+":"+nameAdd+":"+TimeToStr(Time[i]);
   double gap  = iATR(NULL,0,20,i)*gapMul;

   ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
   ObjectSet(name,OBJPROP_ARROWCODE,theCode);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   ObjectSet(name,OBJPROP_WIDTH,theWidth);
   ObjectSet(name,OBJPROP_PRICE1,High[i]);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
   WindowRedraw();
}

void deleteArrows()
{
   string lookFor       = Prefix+":";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}