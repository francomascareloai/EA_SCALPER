//+------------------------------------------------------------------+
//|                                                   SweetSpots.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//| SweetSpotsGOLD_TRO_MODIFIED_VERSION                              |
//| MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM     |
//| I am NOT the ORIGINAL author 
//  and I am not claiming authorship of this indicator. 
//  All I did was modify it. I hope you find my modifications useful.|
//|                                                                  |
//+------------------------------------------------------------------+
 

#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com"

#property indicator_chart_window

/* Introduction:

   This indicator shows lines at sweet spots (50 and 100 
   pips levels). It is recommended to turn off the grid.
   
   Enjoy!

   Markus
*/

extern bool   TURN_OFF    = false ;
extern bool AutoAdjust  = true;
extern bool Show_Labels = true ;
extern int  ShiftLabel =  2  ;

extern int NumLinesAboveBelow  = 100;
extern int SweetSpotMainLevels = 100;

extern color LineColorMain= Yellow;
extern int LineStyleMain= STYLE_DOT;

extern bool ShowSubLevels= true;
extern int sublevels= 158;

extern color LineColorSub= Yellow;
extern int LineStyleSub= STYLE_DOT;


string symbol, tChartPeriod,  tShortName, pricelabel ;  
int    digits, period, digits2, mult = 1  ; 
double point ;
 
//+------------------------------------------------------------------+
int init()
{
   period       =  Period() ;    
   symbol       =  Symbol() ;
   digits       =  Digits ;   
   point        =  Point ;
 
   if(digits == 5 || digits == 3) { mult = 10; digits = digits - 1 ; point = point * 10 ; }   
    
   if(AutoAdjust && period > PERIOD_H1 && period < PERIOD_MN1) { mult = mult * 10; }
   if(AutoAdjust && period == PERIOD_MN1) { mult = mult * 100; }
   
 SweetSpotMainLevels = SweetSpotMainLevels * mult;
 
 sublevels           = sublevels * mult;
    
   deinit();
   
   return(0);
}

//+------------------------------------------------------------------+
int deinit()
{
   int obj_total= ObjectsTotal();
   
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,11)=="[SweetSpot]") 
         ObjectDelete(name);
   }
   TRO();
   return(0);
}
   
//+------------------------------------------------------------------+
int start()
{
   if( TURN_OFF ) { return(0) ; }

   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;
   
    
   // no need to update these buggers too often   
   if (CurTime()-timelastupdate < 600 && Period()==lasttimeframe)
      return (0);
   
   deinit();  // delete all previous lines
      
   int i, ssp1, style, ssp, thickness; //sublevels= 50;
   double ds1;
   color linecolor;
   
   if (!ShowSubLevels)
      sublevels*= 2;
   
   ssp1= Bid / Point;
   ssp1= ssp1 - ssp1%sublevels;

   for (i= -NumLinesAboveBelow; i<NumLinesAboveBelow; i++) 
   {
   
      ssp= ssp1+(i*sublevels); 
      
      if (ssp%SweetSpotMainLevels==0) 
      {
         style= LineStyleMain;
         linecolor= LineColorMain;
      }
      else 
      {
         style= LineStyleSub;
         linecolor= LineColorSub;
      }
      
      thickness= 1;
      
      if (ssp%(SweetSpotMainLevels*10)==0) 
      {
         thickness= 2;      
      }

      if (ssp%(SweetSpotMainLevels*100)==0) 
      {
         thickness= 3;      
      }
      
      ds1= ssp*Point;
      SetLevel(DoubleToStr(ds1,Digits), ds1,  linecolor, style, thickness, Time[10]);
   }

   return(0);
}


//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday)
{

   string linename= "[SweetSpot] " + text + " Line" + pricelabel; 

   // create or move the horizontal line   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, Time[0], level, Time[1], level, 0, 0);

//      ObjectCreate(linename, OBJ_HLINE, 0, 0, level);
      
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);

      ObjectSet(linename, OBJPROP_RAY, true);      
      ObjectSet(linename, OBJPROP_BACK, True);
   }
   else {
      ObjectMove(linename, 0, Time[0], level);
   }
   

   if(Show_Labels)
   {         
    
   
      string Obj0002 = linename+"linelbl" ;
      
      ObjectDelete(Obj0002);
      
      if(ObjectFind(Obj0002) != 0)
      {
          ObjectCreate(Obj0002,OBJ_ARROW,0,Time[0],level);
          ObjectSet(Obj0002,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(Obj0002,OBJPROP_COLOR,col1);  
      } 
      else
      {
         ObjectMove(Obj0002,0,Time[0],level);
      }
 
                 
   } // if     
    
}     


//+------------------------------------------------------------------+  
void TRO()
{   
   
   string tObjName03    = "TROTAG"  ;  
   ObjectCreate(tObjName03, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(tObjName03, CharToStr(78) , 12 ,  "Wingdings",  DimGray );
   ObjectSet(tObjName03, OBJPROP_CORNER, 3);
   ObjectSet(tObjName03, OBJPROP_XDISTANCE, 5 );
   ObjectSet(tObjName03, OBJPROP_YDISTANCE, 5 );  
}
//+------------------------------------------------------------------+
  