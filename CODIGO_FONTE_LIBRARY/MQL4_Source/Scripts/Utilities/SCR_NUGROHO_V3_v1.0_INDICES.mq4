#property indicator_chart_window

extern int BarShift=233;
extern bool ViewLine=false;
extern color txt_c=Black;
extern int timeshift=0;


//+------------------------------------------------------------------+
int deinit() {

ObjectsDeleteAll(0,EMPTY);

return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()

  {
   
  }

  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {         
   
   double x;
   int h,m,s,k;
   m=Time[0]+Period()*60-CurTime();
   x=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   h=x/60;
   k=m-(h*60);
   
   
   for (int i=BarShift;i>=0;i--)
   {
   
   double ma340  = NormalizeDouble(iMA(Symbol(),0,34,0,3,6,i),Digits);
   double ma550  = NormalizeDouble(iMA(Symbol(),0,55,0,3,6,i),Digits);
   double ma890  = NormalizeDouble(iMA(Symbol(),0,89,0,3,6,i),Digits);
    
  
   //==================================================================================================
   //  *******  Moving Average **********
   //==================================================================================================
     
      if (MathAbs(ma340-ma890)==0)
         {  datetime w1 = iTime(Symbol(),0,i);
            double H = iHigh(Symbol(),0,iBarShift(Symbol(),0,w1));
            double L = iLow(Symbol(),0,iBarShift(Symbol(),0,w1));
            string wstr = TimeToStr(w1,TIME_DATE|TIME_MINUTES);
            
            if (ViewLine)
            { 
               ObjectCreate(wstr+" - Resistance3489 | "+i,OBJ_TREND,0,w1,H,TimeCurrent(),H);
               ObjectSet(wstr+" - Resistance3489 | "+i,OBJPROP_COLOR,Red);
               ObjectSet(wstr+" - Resistance3489 | "+i,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(wstr+" - Resistance3489 | "+i,OBJPROP_RAY,false);
               ObjectSet(wstr+" - Resistance3489 | "+i,OBJPROP_WIDTH,1);
            
               ObjectCreate(wstr+" - Support3489 | "+i,OBJ_TREND,0,w1,L,TimeCurrent(),L);
               ObjectSet(wstr+" - Support3489 | "+i,OBJPROP_COLOR,Blue);
               ObjectSet(wstr+" - Support3489 | "+i,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(wstr+" - Support3489 | "+i,OBJPROP_RAY,false);  
               ObjectSet(wstr+" - Support3489 | "+i,OBJPROP_WIDTH,1);
            }
         }
   
       if (MathAbs(ma550-ma890)==0)
         {  w1 = iTime(Symbol(),0,i);
            H = iHigh(Symbol(),0,iBarShift(Symbol(),0,w1));
            L = iLow(Symbol(),0,iBarShift(Symbol(),0,w1));
            wstr = TimeToStr(w1,TIME_DATE|TIME_MINUTES);
            
            if (ViewLine)
            { 
            
               ObjectCreate(wstr+" - Resistance5589 | "+i,OBJ_TREND,0,w1,H,TimeCurrent(),H);
               ObjectSet(wstr+" - Resistance5589 | "+i,OBJPROP_COLOR,Red);
               ObjectSet(wstr+" - Resistance5589 | "+i,OBJPROP_STYLE,STYLE_SOLID);
               ObjectSet(wstr+" - Resistance5589 | "+i,OBJPROP_WIDTH,1);
               ObjectSet(wstr+" - Resistance5589 | "+i,OBJPROP_RAY,false);
            
               ObjectCreate(wstr+" - Support5589 | "+i,OBJ_TREND,0,w1,L,TimeCurrent(),L);
               ObjectSet(wstr+" - Support5589 | "+i,OBJPROP_COLOR,Blue);
               ObjectSet(wstr+" - Support5589 | "+i,OBJPROP_STYLE,STYLE_SOLID);
               ObjectSet(wstr+" - Support5589 | "+i,OBJPROP_WIDTH,1);
               ObjectSet(wstr+" - Support5589 | "+i,OBJPROP_RAY,false);
            }  
         }
   
   datetime TokyoStart=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 01:00");
            TokyoStart=StrToTime(TimeToStr(TokyoStart,TIME_DATE)+" "+(TimeHour(TokyoStart)+timeshift));
            
   datetime TokyoEnd=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 09:00");
            TokyoEnd=StrToTime(TimeToStr(TokyoEnd,TIME_DATE)+" "+(TimeHour(TokyoEnd)+timeshift));
            
   int tokyo_bs=iBarShift(Symbol(),0,TokyoStart);
   int tokyo_be=iBarShift(Symbol(),0,TokyoEnd);
   int ibl_tokyo = iLowest(Symbol(),0,MODE_LOW,tokyo_bs-tokyo_be,tokyo_be);
   int ibh_tokyo = iHighest(Symbol(),0,MODE_HIGH,tokyo_bs-tokyo_be,tokyo_be);
   double vHigh_tokyo =High[ibh_tokyo];
   double vLow_tokyo =Low[ibl_tokyo];
   double vMid_tokyo =(vHigh_tokyo+vLow_tokyo)/2;
   double sum_tokyo=(vHigh_tokyo-vLow_tokyo)/Point;
    
   if (TimeHour(TimeCurrent())>1)
   {
   
   ObjectCreate ("sumtokyopips :",OBJ_LABEL,0,0,0);
   ObjectSet("sumtokyopips :", OBJPROP_CORNER, 1);
   ObjectSet("sumtokyopips :", OBJPROP_BACK, false);
   ObjectSet("sumtokyopips :", OBJPROP_XDISTANCE, 60);
   ObjectSet("sumtokyopips :", OBJPROP_YDISTANCE, 10);
   ObjectSetText("sumtokyopips :",DoubleToStr(sum_tokyo,0)+" pips", 9, "Arial", txt_c);
   }
   ObjectCreate ("sumtokyo :",OBJ_LABEL,0,0,0);
   ObjectSet("sumtokyo :", OBJPROP_CORNER, 1);
   ObjectSet("sumtokyo :", OBJPROP_BACK, false);
   ObjectSet("sumtokyo :", OBJPROP_XDISTANCE, 130);
   ObjectSet("sumtokyo :", OBJPROP_YDISTANCE, 10);
   ObjectSetText("sumtokyo :","Tokyo :", 9, "Arial", txt_c);
 
   ObjectCreate ("tokyo1"+i,OBJ_RECTANGLE,0,TokyoStart,vHigh_tokyo,TokyoEnd,vLow_tokyo);
   ObjectSet("tokyo1"+i,OBJPROP_WIDTH,2);ObjectSet("tokyo1"+i,OBJPROP_STYLE,STYLE_SOLID);ObjectSet("tokyo1"+i,OBJPROP_BACK,false);
   ObjectSet("tokyo1"+i,OBJPROP_COLOR,Yellow);
   
   double fibo_0= vHigh_tokyo;double fibo_100=vLow_tokyo;
   
   string objname = "FIBO Tokyo"+i;
   ObjectCreate(objname,OBJ_FIBO,0,TokyoEnd,vHigh_tokyo,TokyoEnd+2000,vLow_tokyo);
   ObjectSet(objname,OBJPROP_COLOR,White);
   ObjectSet(objname,OBJPROP_RAY,false);
   
   ObjectSet(objname,OBJPROP_LEVELCOLOR,Yellow);
   ObjectSet(objname,OBJPROP_FIBOLEVELS,21);
   ObjectSet(objname,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL,0);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+2,0.5);   
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+4,1);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+5,1.236);  
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+6,1.618);  
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+7,2); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+8,2.618);  
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+10,3.236); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+9,3.618);
   
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+11,-0.382); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+12,-0.5); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+13,-0.618); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+14,-1); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+15,-1.236);  
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+16,-1.618); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+17,-2); 
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+18,-2.618);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+19,-3.236);
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+20,-3.618);
   
   ObjectSetFiboDescription(objname,0,"0%");
   ObjectSetFiboDescription(objname,1,"38.2%");
   ObjectSetFiboDescription(objname,2,"50%");
   ObjectSetFiboDescription(objname,3,"61.8%");
   ObjectSetFiboDescription(objname,4,"100%");     
   ObjectSetFiboDescription(objname,5,"123.6%"); 
   ObjectSetFiboDescription(objname,6,"S W E E T  S P O T ");       
   ObjectSetFiboDescription(objname,7,"200%"); 
   ObjectSetFiboDescription(objname,8,"261.8%"); 
   ObjectSetFiboDescription(objname,9,"E 323.6%");  
   ObjectSetFiboDescription(objname,10,"E 361.8%");  
   
   ObjectSetFiboDescription(objname,11,"E 38.2%");
   ObjectSetFiboDescription(objname,12,"E 50%");
   ObjectSetFiboDescription(objname,13,"E 61.8%");
   ObjectSetFiboDescription(objname,14,"E 100%");
   ObjectSetFiboDescription(objname,15,"E 123.6%");
   ObjectSetFiboDescription(objname,16,"E 161.8%");
   ObjectSetFiboDescription(objname,17,"E 200%");
   ObjectSetFiboDescription(objname,18,"E 261.8%");  
   ObjectSetFiboDescription(objname,19,"E 323.6%");
   ObjectSetFiboDescription(objname,20,"E 361.8%");  
   
   
   datetime LondonStart=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 09:00");
            LondonStart=StrToTime(TimeToStr(LondonStart,TIME_DATE)+" "+(TimeHour(LondonStart)+timeshift));
             
   datetime LondonEnd=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 14:00");
            LondonEnd=StrToTime(TimeToStr(LondonEnd,TIME_DATE)+" "+(TimeHour(LondonEnd)+timeshift));
            
   int London_bs=iBarShift(Symbol(),0,LondonStart);
   int London_be=iBarShift(Symbol(),0,LondonEnd);
   int ibl_London = iLowest(Symbol(),0,MODE_LOW,London_bs-London_be,London_be);
   int ibh_London = iHighest(Symbol(),0,MODE_HIGH,London_bs-London_be,London_be);
   double vHigh_London =High[ibh_London];
   double vLow_London =Low[ibl_London];
   double sum_london=(vHigh_London-vLow_London)/Point;
   
   if (TimeHour(TimeCurrent())>9)
   {
   
   ObjectCreate ("sumlondonpips :",OBJ_LABEL,0,0,0);
   ObjectSet("sumlondonpips :", OBJPROP_CORNER, 1);
   ObjectSet("sumlondonpips :", OBJPROP_BACK, false);
   ObjectSet("sumlondonpips :", OBJPROP_XDISTANCE, 60);
   ObjectSet("sumlondonpips :", OBJPROP_YDISTANCE, 28);
   ObjectSetText("sumlondonpips :",DoubleToStr(sum_london,0)+" pips", 9, "Arial", txt_c);
   }
   ObjectCreate ("sumlondon :",OBJ_LABEL,0,0,0);
   ObjectSet("sumlondon :", OBJPROP_CORNER, 1);
   ObjectSet("sumlondon :", OBJPROP_BACK, false);
   ObjectSet("sumlondon :", OBJPROP_XDISTANCE, 130);
   ObjectSet("sumlondon :", OBJPROP_YDISTANCE, 28);
   ObjectSetText("sumlondon :","London :", 9, "Arial", txt_c);
   
  
   ObjectCreate ("London1"+i,OBJ_RECTANGLE,0,LondonStart,vHigh_London,LondonEnd,vLow_London);
   ObjectSet("London1"+i,OBJPROP_WIDTH,2);ObjectSet("London1"+i,OBJPROP_STYLE,STYLE_SOLID);ObjectSet("London1"+i,OBJPROP_BACK,false);
   ObjectSet("London1"+i,OBJPROP_COLOR,LimeGreen);
   
   double fibo_1= vHigh_London;double fibo_200=vLow_London;
   string objnameL = "FIBO London"+i;
   ObjectCreate(objnameL,OBJ_FIBO,0,LondonEnd,vHigh_London,LondonEnd+3000,vLow_London);
   ObjectSet(objnameL,OBJPROP_COLOR,White);
   ObjectSet(objnameL,OBJPROP_RAY,false);
   
   ObjectSet(objnameL,OBJPROP_LEVELCOLOR,LimeGreen);
   ObjectSet(objnameL,OBJPROP_FIBOLEVELS,21);
   ObjectSet(objnameL,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL,0);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+2,0.5);   
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+4,1);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+5,1.236);  
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+6,1.618);  
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+7,2); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+8,2.618); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+9,3.618); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+10,3.236);
   
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+11,-0.382); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+12,-0.5); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+13,-0.618); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+14,-1); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+15,-1.236);  
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+16,-1.618); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+17,-2); 
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+18,-2.618);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+19,-3.236);
   ObjectSet(objnameL,OBJPROP_FIRSTLEVEL+20,-3.618);
   
   ObjectSetFiboDescription(objnameL,0,"0%");
   ObjectSetFiboDescription(objnameL,1,"38.2%");
   ObjectSetFiboDescription(objnameL,2,"50%");
   ObjectSetFiboDescription(objnameL,3,"61.8%");
   ObjectSetFiboDescription(objnameL,4,"100%");     
   ObjectSetFiboDescription(objnameL,5,"123.6%"); 
   ObjectSetFiboDescription(objnameL,6,"S W E E T  S P O T ");       
   ObjectSetFiboDescription(objnameL,7,"200%"); 
   ObjectSetFiboDescription(objnameL,8,"261.8%");
   ObjectSetFiboDescription(objnameL,9,"E 361.8%");  
   ObjectSetFiboDescription(objnameL,10,"E 323.6%");  
   
   ObjectSetFiboDescription(objnameL,11,"E 38.2%");
   ObjectSetFiboDescription(objnameL,12,"E 50%");
   ObjectSetFiboDescription(objnameL,13,"E 61.8%");
   ObjectSetFiboDescription(objnameL,14,"E 100%");
   ObjectSetFiboDescription(objnameL,15,"E 123.6%");
   ObjectSetFiboDescription(objnameL,16,"E 161.8%");
   ObjectSetFiboDescription(objnameL,17,"E 200%");
   ObjectSetFiboDescription(objnameL,18,"E 261.8%");  
   ObjectSetFiboDescription(objnameL,19,"E 323.6%");  
   ObjectSetFiboDescription(objnameL,20,"E 361.8%");  
   
   datetime NewyorkStart=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 14:00");
            NewyorkStart=StrToTime(TimeToStr(NewyorkStart,TIME_DATE)+" "+(TimeHour(NewyorkStart)+timeshift));
            
   datetime NewyorkEnd=StrToTime(TimeToStr(iTime(Symbol(),PERIOD_D1,i),TIME_DATE)+" 22:00");
            NewyorkEnd=StrToTime(TimeToStr(NewyorkEnd,TIME_DATE)+" "+(TimeHour(NewyorkEnd)+timeshift));
           
   int Newyork_bs=iBarShift(Symbol(),0,NewyorkStart);
   int Newyork_be=iBarShift(Symbol(),0,NewyorkEnd);
   int ibl_Newyork = iLowest(Symbol(),0,MODE_LOW,Newyork_bs-Newyork_be,Newyork_be);
   int ibh_Newyork = iHighest(Symbol(),0,MODE_HIGH,Newyork_bs-Newyork_be,Newyork_be);
   double vHigh_Newyork =High[ibh_Newyork];
   double vLow_Newyork =Low[ibl_Newyork];
   double sum_NY=(vHigh_Newyork-vLow_Newyork)/Point;
   
   if (TimeHour(TimeCurrent())>14)
   {
   ObjectCreate ("sumNYpips :",OBJ_LABEL,0,0,0);
   ObjectSet("sumNYpips :", OBJPROP_CORNER, 1);
   ObjectSet("sumNYpips :", OBJPROP_BACK, false);
   ObjectSet("sumNYpips :", OBJPROP_XDISTANCE, 60);
   ObjectSet("sumNYpips :", OBJPROP_YDISTANCE, 46);
   ObjectSetText("sumNYpips :",DoubleToStr(sum_NY,0)+" pips", 9, "Arial", txt_c);
   }
   
   ObjectCreate ("sumNY :",OBJ_LABEL,0,0,0);
   ObjectSet("sumNY :", OBJPROP_CORNER, 1);
   ObjectSet("sumNY :", OBJPROP_BACK, false);
   ObjectSet("sumNY :", OBJPROP_XDISTANCE, 130);
   ObjectSet("sumNY :", OBJPROP_YDISTANCE, 46);
   ObjectSetText("sumNY :","New York :", 9, "Arial", txt_c);
   
   ObjectCreate ("Newyork1"+i,OBJ_RECTANGLE,0,NewyorkStart,vHigh_Newyork,NewyorkEnd,vLow_Newyork);
   ObjectSet("Newyork1"+i,OBJPROP_WIDTH,2);ObjectSet("Newyork1"+i,OBJPROP_STYLE,STYLE_SOLID);ObjectSet("Newyork1"+i,OBJPROP_BACK,false);
   ObjectSet("Newyork1"+i,OBJPROP_COLOR,Maroon);
   double fibo_2= vHigh_Newyork;double fibo_300=vLow_Newyork;
   string objnameN = "FIBO New York"+i;
   
   ObjectCreate(objnameN,OBJ_FIBO,0,NewyorkEnd,vHigh_Newyork,NewyorkEnd+4000,vLow_Newyork);
   ObjectSet(objnameN,OBJPROP_COLOR,White);
   ObjectSet(objnameN,OBJPROP_RAY,false);
   
   ObjectSet(objnameN,OBJPROP_LEVELCOLOR,Maroon);
   ObjectSet(objnameN,OBJPROP_FIBOLEVELS,21);
   ObjectSet(objnameN,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL,0);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+2,0.5);   
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+4,1);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+5,1.236);  
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+6,1.618);  
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+7,2); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+8,2.618); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+9,3.618); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+10,3.236);
   
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+11,-0.382); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+12,-0.5); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+13,-0.618); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+14,-1); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+15,-1.236);  
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+16,-1.618); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+17,-2); 
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+18,-2.618);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+19,-3.236);
   ObjectSet(objnameN,OBJPROP_FIRSTLEVEL+20,-3.618);
   
   ObjectSetFiboDescription(objnameN,0,"0%");
   ObjectSetFiboDescription(objnameN,1,"38.2%");
   ObjectSetFiboDescription(objnameN,2,"50%");
   ObjectSetFiboDescription(objnameN,3,"61.8%");
   ObjectSetFiboDescription(objnameN,4,"100%");     
   ObjectSetFiboDescription(objnameN,5,"123.6%"); 
   ObjectSetFiboDescription(objnameN,6,"S W E E T  S P O T ");       
   ObjectSetFiboDescription(objnameN,7,"200%"); 
   ObjectSetFiboDescription(objnameN,8,"261.8%");
   ObjectSetFiboDescription(objnameN,9,"E 361.8%");  
   ObjectSetFiboDescription(objnameN,10,"E 323.6%");  
   
   ObjectSetFiboDescription(objnameN,11,"E 38.2%");
   ObjectSetFiboDescription(objnameN,12,"E 50%");
   ObjectSetFiboDescription(objnameN,13,"E 61.8%");
   ObjectSetFiboDescription(objnameN,14,"E 100%");
   ObjectSetFiboDescription(objnameN,15,"E 123.6%");
   ObjectSetFiboDescription(objnameN,16,"E 161.8%");
   ObjectSetFiboDescription(objnameN,17,"E 200%");
   ObjectSetFiboDescription(objnameN,18,"E 261.8%"); 
   ObjectSetFiboDescription(objnameN,19,"E 323.6%");  
   ObjectSetFiboDescription(objnameN,20,"E 361.8%");  
   }
  
   double sumAll= (sum_NY+sum_london+sum_tokyo )/3;
   ObjectCreate ("sa",OBJ_LABEL,0,0,0);
   ObjectSet("sa", OBJPROP_CORNER, 1);
   ObjectSet("sa", OBJPROP_BACK, false);
   ObjectSet("sa", OBJPROP_XDISTANCE, 130);
   ObjectSet("sa", OBJPROP_YDISTANCE, 64);
   ObjectSetText("sa","Average :", 9, "Arial", txt_c);
   
   ObjectCreate ("sumallpips",OBJ_LABEL,0,0,0);
   ObjectSet("sumallpips", OBJPROP_CORNER, 1);
   ObjectSet("sumallpips", OBJPROP_BACK, false);
   ObjectSet("sumallpips", OBJPROP_XDISTANCE, 60);
   ObjectSet("sumallpips", OBJPROP_YDISTANCE, 64);
   ObjectSetText("sumallpips",DoubleToStr(sumAll,0)+" pips", 9, "Arial", txt_c);
  
   ObjectCreate ("candle",OBJ_LABEL,0,0,0);
   ObjectSet("candle", OBJPROP_CORNER, 1);
   ObjectSet("candle", OBJPROP_BACK, false);
   ObjectSet("candle", OBJPROP_XDISTANCE, 130);
   ObjectSet("candle", OBJPROP_YDISTANCE, 82);
   ObjectSetText("candle","Candle :", 9, "Arial", txt_c);
   
   ObjectCreate ("time",OBJ_LABEL,0,0,0);
   ObjectSet("time", OBJPROP_CORNER, 1);
   ObjectSet("time", OBJPROP_BACK, false);
   ObjectSet("time", OBJPROP_XDISTANCE, 60);
   ObjectSet("time", OBJPROP_YDISTANCE, 82);
   ObjectSetText("time",k + " : " + s, 9, "Arial", txt_c);
  
  return(0);
  }
//+------------------------------------------------------------------+