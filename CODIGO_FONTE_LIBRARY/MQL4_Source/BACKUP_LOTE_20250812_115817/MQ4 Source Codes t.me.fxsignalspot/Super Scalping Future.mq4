
#property indicator_chart_window
#property indicator_minimum -1.2
#property indicator_maximum 1.2
#property indicator_buffers 1 // bija 1
#property indicator_color1 Blue
#property indicator_width1 3
#property indicator_style1 STYLE_SOLID



#property indicator_levelcolor Lime // bija OrangeRed
#property indicator_level1 0.8
#property indicator_level2 -0.8
//#property indicator_level3 0.8
//#property indicator_level4 -0.8
//#property indicator_level5 0.8
//#property indicator_level6 -0.8
//#property indicator_width1 2

  int pomul = 22;
extern   int FilterPeriod = 22;
  double ulinop = 1.0;
  int cilik = 0;

extern int SL_distance_pips = 20; // SL attaalums no kanaala aarmalaam
//+------------------------------------------------------------------+ 

double indic_buffer0[];
double indic_buffer1[];
double indic_buffer2[];
int iConst_14 = 14;
double dArray1[];
double dConst_pipDigits;
int iArray1[];
int iArray2[];
int iSignFlag = 0;
int iTimeBar0 = 0;

string indPrefix="www.mql54.com";
string nosaukums;

datetime lastAlertTime;

//+------------------------------------------------------------------+
void displayAlert(string strMsg, double tp, double sl, double currPrice) {
   if (Time[0] != lastAlertTime) {
      lastAlertTime = Time[0];
      
      string strSL, strTP, strCurr; 
      if (currPrice!=0) strCurr= " - price "+DoubleToStr(currPrice,4); else strCurr="";
      if (tp!=0) strTP= ", TakeProfit on "+DoubleToStr(tp,4); else strTP="";
      if (sl!=0) strSL= ", StopLoss on "+DoubleToStr(sl,4); else strSL="";
      
      Alert("www.mql54.com "+strMsg+strCurr+strTP+strSL+" ", Symbol(), ", ", Period(), " minute chart");
      

      //signalActive = true;
   }
}
//+------------------------------------------------------------------+

void MartAxis(int ai_0) {
   int li_4;
   int l_count_8;
   int li_12;
   int li_16;
   double ld_24;
   switch (cilik) {
   case 0:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_CLOSE, ai_0);
      break;
   case 1:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_OPEN, ai_0);
      break;
   case 2:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_HIGH, ai_0);
      break;
   case 3:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_LOW, ai_0);
      break;
   case 4:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_MEDIAN, ai_0);
      break;
   case 5:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_TYPICAL, ai_0);
      break;
   case 6:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_WEIGHTED, ai_0);
      break;
   default:
      indic_buffer1[ai_0] = iMA(NULL, 0, pomul + 1, 0, MODE_LWMA, PRICE_WEIGHTED, ai_0);
   }
   for (int li_20 = ai_0 + pomul + 2; li_20 > ai_0; li_20--) {
      ld_24 = 0.0;
      li_4 = 0;
      l_count_8 = 0;
      li_12 = li_20 + pomul;
      li_16 = li_20 - pomul;
      if (li_16 < ai_0) li_16 = ai_0;
      while (li_12 >= li_20) {
         l_count_8++;
         ld_24 += l_count_8 * SnakePrice(li_12);
         li_4 += l_count_8;
         li_12--;
      }
      while (li_12 >= li_16) {
         l_count_8--;
         ld_24 += l_count_8 * SnakePrice(li_12);
         li_4 += l_count_8;
         li_12--;
      }
      indic_buffer1[li_20] = ld_24 / li_4;
   }
}

double SnakePrice(int ai_0) {
   switch (cilik) {
   case 0:
      return (Close[ai_0]);
   case 1:
      return (Open[ai_0]);
   case 2:
      return (High[ai_0]);
   case 3:
      return (Low[ai_0]);
   case 4:
      return ((High[ai_0] + Low[ai_0]) / 2.0);
   case 5:
      return ((Close[ai_0] + High[ai_0] + Low[ai_0]) / 3.0);
   case 6:
      return ((2.0 * Close[ai_0] + High[ai_0] + Low[ai_0]) / 4.0);
   }
   return (Close[ai_0]);
}

void SmoothOverMart(int ai_0) {
   double ld_4 = indic_buffer1[ArrayMaximum(indic_buffer1, FilterPeriod, ai_0)];
   double ld_12 = indic_buffer1[ArrayMinimum(indic_buffer1, FilterPeriod, ai_0)];
   indic_buffer2[ai_0] = (2.0 * (ulinop + 2.0) * indic_buffer1[ai_0] - (ld_4 + ld_12)) / 2.0 / (ulinop + 1.0);
}

double SpearmanRankCorrelation(double ada_0[], int ai_4) {
   double ld_16;
   for (int l_index_24 = 0; l_index_24 < ai_4; l_index_24++) ld_16 += MathPow(ada_0[l_index_24] - l_index_24 - 1.0, 2);
   double ld_ret_8 = 1 - 6.0 * ld_16 / (MathPow(ai_4, 3) - ai_4);
   return (ld_ret_8);
}

void RankPrices(int aia_0[]) {
   double ld_4;
   double ld_12;
   int l_index_24;
   int li_32;
   int li_36;
   int li_40;
   double lda_44[];
   ArrayResize(lda_44, iConst_14);
   ArrayCopy(iArray2, aia_0);
   for (int l_index_20 = 0; l_index_20 < iConst_14; l_index_20++) lda_44[l_index_20] = l_index_20 + 1;
   ArraySort(iArray2, WHOLE_ARRAY, 0, MODE_DESCEND);
   for (l_index_20 = 0; l_index_20 < iConst_14 - 1; l_index_20++) {
      if (iArray2[l_index_20] == iArray2[l_index_20 + 1]) {
         li_32 = iArray2[l_index_20];
         l_index_24 = l_index_20 + 1;
         li_36 = 1;
         ld_12 = l_index_20 + 1;
         while (l_index_24 < iConst_14) {
            if (iArray2[l_index_24] != li_32) break;
            li_36++;
            ld_12 += l_index_24 + 1;
            l_index_24++;
         }
         ld_4 = li_36;
         ld_12 /= ld_4;
         for (int li_28 = l_index_20; li_28 < l_index_24; li_28++) lda_44[li_28] = ld_12;
         l_index_20 = l_index_24;
      }
   }
   for (l_index_20 = 0; l_index_20 < iConst_14; l_index_20++) {
      li_40 = aia_0[l_index_20];
      for (l_index_24 = 0; l_index_24 < iConst_14; l_index_24++) {
         if (li_40 == iArray2[l_index_24]) {
            dArray1[l_index_20] = lda_44[l_index_24];
            break;
         }
      }
   }
}

int init() {
   IndicatorBuffers(3); //  
   SetIndexBuffer(0, indic_buffer0);
   SetIndexStyle(0, DRAW_LINE,STYLE_SOLID, 2);  //STYLE_DASHDOT
   SetIndexBuffer(1, indic_buffer1);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, indic_buffer2);
   SetIndexStyle(2, DRAW_NONE);

   ArrayResize(dArray1, iConst_14);
   ArrayResize(iArray1, iConst_14);
   ArrayResize(iArray2, iConst_14);
   if (iConst_14 > 30) IndicatorShortName("www.mql54.com");
   else IndicatorShortName("BuySellWait");
   dConst_pipDigits = MathPow(10, Digits);
   return (0);
}

int deinit() {

   delObj("");
   return (0);
}

int start() {
   int li_8;
   int li_12;
   int li_16;
   int l_ind_counted_20 = IndicatorCounted();
   if (iConst_14 > 30) return (-1);
   if (l_ind_counted_20 == 0) {
      li_8 = Bars - (iConst_14 + FilterPeriod + pomul + 4);
      li_12 = Bars - (pomul + 2);
      li_16 = Bars - (FilterPeriod + pomul + 3);
   }
   if (l_ind_counted_20 > 0) {
      li_8 = Bars - l_ind_counted_20 + 1;
      li_12 = li_8;
      li_16 = li_8;
   }
   
   for (int li_0 = li_12; li_0 >= 0; li_0--) MartAxis(li_0);
   for (li_0 = li_16; li_0 >= 0; li_0--) SmoothOverMart(li_0);
   for (li_0 = li_8; li_0 >= 0; li_0--) {
      for (int l_index_4 = 0; l_index_4 < iConst_14; l_index_4++) iArray1[l_index_4] = (indic_buffer2[li_0 + l_index_4]) * dConst_pipDigits;
      RankPrices(iArray1);
      indic_buffer0[li_0] = SpearmanRankCorrelation(dArray1, iConst_14);
      
      if (indic_buffer0[li_0] > 1.0) indic_buffer0[li_0] = 1.0;
      if (indic_buffer0[li_0] < -1.0) indic_buffer0[li_0] = -1.0;
   }
   
   // alerti
   if (Time[0] <= iTimeBar0 ) return (0);
   iTimeBar0 = Time[0];

   iSignFlag=0; ///
 
   double currPrice, currTime, sl;
   color kraasa;
   
   delObj("");
   
   for (int i=300; i>=0; i--)
   {
   currPrice=Open[i];
   currTime=Time[i];
   if (iSignFlag >= 0) { // ieprieksh dotais signaals: 1 = buy, 2 = sell
      if ((indic_buffer0[i+2] >=0.8) && ( indic_buffer0[i+1] <= 0.8)) { // bija virs, tagad zem
         iSignFlag = -1;
         sl=High[1]+SL_distance_pips*Point;
         kraasa=Red;
         if (i==0) { displayAlert("Sell signal",0, sl, currPrice); kraasa=Blue; }
         drawSignalArrow(currTime,currPrice,iSignFlag, kraasa);

        // Alert("BuySellWait (", Symbol(), ", ", Period(), ")  -  Sell");
      }
   }
   if (iSignFlag <= 0) {
      if ((indic_buffer0[i+2] <= -0.8) && (indic_buffer0[i+1] >= - 0.8)) { // bija zem, tagad virs
         iSignFlag = 1;

         sl=Low[1]+SL_distance_pips*Point;
         kraasa=Lime;
         if (i==0) { displayAlert("Buy signal",0, sl, currPrice); kraasa=Blue; }
         drawSignalArrow(currTime,currPrice,iSignFlag, kraasa);
         
        // Alert("BuySellWait (", Symbol(), ", ", Period(), ")  -  Buy");
      }
   }
   
   } // i cikls
   
   drawMyText();
   
   return (0);
}

//-------------------------------------------------------------------------------------------------------

void drawMyText()
{
   nosaukums=indPrefix+"www.mql54.com";
   string teksts="www.mql54.com -  Current Signal: ";
   if (iSignFlag==0) teksts=teksts+"Wait";
   if (iSignFlag<0) teksts=teksts+"Sell";
   if (iSignFlag>0) teksts=teksts+"Buy";
   
   int BarsInWindow, SecondsInBar;
   double WindowHighest, WindowLowest;
   
	BarsInWindow	= BarsPerWindow();
	SecondsInBar	= Period() * 60;
	WindowHighest	= High[Highest(NULL,0,MODE_HIGH,BarsInWindow*4/5,0)];
	WindowLowest	= Low [Lowest (NULL,0,MODE_LOW, BarsInWindow*4/5,0)];   
   
   double laiks, cena, platums;
   laiks = Time[0] + (BarsInWindow/75+10)*SecondsInBar;
   cena = WindowLowest + (WindowHighest-WindowLowest)/10;
	platums	= MathMax( 7, (MathCeil(BarsInWindow/5.0/3.0)*3+1-3) )*SecondsInBar;   
   
   ObjectDelete(nosaukums);
   ObjectCreate(nosaukums,OBJ_TEXT, 0, laiks, cena, 0,0,0,0);
   ObjectSetText(nosaukums, teksts);
   ObjectSet(nosaukums,OBJPROP_COLOR,Red);
   

}


void drawSignalArrow(datetime bultasLaiks, double bultasCena, int signaals, color kraasa)
{

   // papildus bultas uz grafika
   
   int bultasTips;
   
   if (signaals>0) 
   { 
     bultasTips=233;
     bultasCena=bultasCena-1*Point; 
   }
   else 
   {
     bultasTips=234;
     bultasCena=bultasCena+10*Point; 
   
   }
   
   nosaukums=indPrefix+"signalArrow"+bultasCena+bultasLaiks+bultasTips;
   //signalArrowName = nosaukums; // atceramies
   
   ObjectDelete(nosaukums);
   ObjectCreate(nosaukums,OBJ_ARROW,0, bultasLaiks, bultasCena,0,0,0,0);
   ObjectSet(nosaukums, OBJPROP_WIDTH, 2);   
   ObjectSet(nosaukums,OBJPROP_ARROWCODE,bultasTips); // arrowcode
   ObjectSet(nosaukums,OBJPROP_COLOR,kraasa);
   
   
}

void delObj(string prePrefix)
{
 
   string objName;
   for (int i = ObjectsTotal() - 1; i >= 0; i--) 
   {
      objName = ObjectName(i);
      int l=StringLen(prePrefix)+StringLen(indPrefix);
      string totalPrefix=prePrefix+indPrefix;
      
      if (StringSubstr(objName, 0, l) == totalPrefix) 
     //    if (! ( (objName==signalArrowName) && ((signalStatus==2) || (signalStatus==-2)) ) )
            ObjectDelete(objName);
   }
 

}