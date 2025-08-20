//+------------------------------------------------------------------+
//|                                          10.2 TmaSlope v.1.4.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, zznbrm"

//Edited by shahrooz "sh.sadeghi.me@gmail.com"
//Edited by de capris 10.2                           
//---- indicator settings
#property indicator_separate_window
#property  indicator_buffers     7
#property  indicator_level1      0.4
#property  indicator_level2      -0.4 
#property  indicator_level3      0.8 
#property  indicator_level4      -0.8 
#property  indicator_levelcolor  Black 

#property indicator_color1 Green
#property indicator_color2 Lime
#property indicator_color3 FireBrick
#property indicator_color4 Red
#property indicator_color5 Teal
#property indicator_color6 HotPink
#property indicator_color7 DarkBlue


#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 3  
#property indicator_width6 3  
#property indicator_width7 0   


//---- input parameters
extern string OtherTimeFrames = "Select below 0=current tf,1,5,15,30,60,240,1440,10080,43200";

extern int select_other_tf_to_show=0;
extern int H_Pos_MTF=1;
extern int V_Pos_MTF=50;
extern int        Font_Size_MTF              = 12;
extern int Corner_MTF=3;
extern color      Font_Color_MTF              = Black;


extern int eintPeriod = 20;
extern double edblHigh1 = 0.4;
extern double edblLow1 = -0.4;
extern int atrPeriod = 100;


extern color      Font_Color          = White;
extern int        H_Pos               = 1;
extern int        V_Pos               = 25;
extern int        Corner              = 3;
extern int        Font_Size           = 14;
extern int        Font_Size_text      = 11;
extern int        H_Pos_text          = 1;
extern int        V_Pos_text          = 1;

extern int Text_Corner=3;

//---- indicator buffers
double gadblUp1[];
double gadblUp2[];

double gadblDn1[];
double gadblDn2[];

double gadblMid1[];
double gadblMid2[];

double gadblSlope[]; 
color Font_Color_M15;

double TICK;
bool AdditionalDigit;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{              
   //IndicatorBuffers( 8 );    
   IndicatorBuffers( 7 );
   IndicatorDigits( 5 );
   IndicatorShortName( "10.2 TmaSlope_Norm" );
   AdditionalDigit = MarketInfo(Symbol(), MODE_MARGINCALCMODE) == 0 && MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0 && Digits % 2 == 1;
   TICK = getTick();
      
   SetIndexBuffer( 0, gadblUp1 );    SetIndexLabel( 0, NULL );       SetIndexStyle( 0, DRAW_HISTOGRAM );
   SetIndexBuffer( 1, gadblUp2 );    SetIndexLabel( 1, NULL );       SetIndexStyle( 1, DRAW_HISTOGRAM );
   SetIndexBuffer( 2, gadblDn1 );    SetIndexLabel( 2, NULL );       SetIndexStyle( 2, DRAW_HISTOGRAM );
   SetIndexBuffer( 3, gadblDn2 );    SetIndexLabel( 3, NULL );       SetIndexStyle( 3, DRAW_HISTOGRAM );
   SetIndexBuffer( 4, gadblMid1 );    SetIndexLabel( 4, NULL );       SetIndexStyle( 4, DRAW_HISTOGRAM );
   SetIndexBuffer( 5, gadblMid2 );    SetIndexLabel( 5, NULL );       SetIndexStyle( 5, DRAW_HISTOGRAM );

   SetIndexBuffer( 6, gadblSlope );  SetIndexLabel( 6, "TMA Slope" );    SetIndexStyle( 6, DRAW_NONE );

      
   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );


   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars > 0 ) counted_bars--;
               
   int intLimit = MathMin( Bars - 1, Bars - counted_bars + eintPeriod );
   
   double dblTma, dblPrev;
      double dblTmaMTF, dblPrevMTF;
   double atr ; 
    double atrMTF ;
   for( int inx = intLimit; inx >= 0; inx-- )
   {   
      //gadblTma[inx] = calcTma( inx );
      //gadblPrev[inx] = calcTma( inx+1 );
      //gadblSlope[inx] = ( gadblTma[inx] - gadblPrev[inx] ) / TICK;
      atr= iATR(NULL,0,atrPeriod,inx+10)*0.1;
      atrMTF= iATR(NULL,select_other_tf_to_show,atrPeriod,inx+10)*0.1;
      if (atr == 0) continue;
      if (atrMTF == 0) continue;
      dblTma = calcTma( inx );
      dblPrev = calcTma( inx+1 );
      gadblSlope[inx] = ( dblTma - dblPrev ) / atr;
      
      gadblUp1[inx] = 0.0;   
      gadblDn1[inx] = 0.0;     
      gadblMid1[inx] = 0.0;   
      gadblUp2[inx] = 0.0;   
      gadblDn2[inx] = 0.0;     
      gadblMid2[inx] = 0.0;   
   
     if ( gadblSlope[inx] > edblHigh1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblUp1[inx] = gadblSlope[inx];
         else gadblUp2[inx] = gadblSlope[inx];
     }
     else if ( gadblSlope[inx] < edblLow1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblDn2[inx] = gadblSlope[inx];
         else gadblDn1[inx] = gadblSlope[inx];
     }
     else  
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblMid2[inx] = gadblSlope[inx];
         else gadblMid1[inx] = gadblSlope[inx];
     } 
   
 //  if(gadblSlope[inx]>=0 && gadblSlope[inx]<gadblSlope[inx+1] && Close[inx]>Open[inx] ) arrowdown[inx]=gadblSlope[inx]+0.1*gadblSlope[inx]; 
 //  if(gadblSlope[inx]<0 && gadblSlope[inx]>gadblSlope[inx+1] && Close[inx]<Open[inx]&& gadblSlope[inx+2]>=gadblSlope[inx+1]) arrowup[inx]=gadblSlope[inx]+0.1*gadblSlope[inx]; 

     string tt=DoubleToStr(gadblSlope[inx],2);

    ObjectCreate("label",OBJ_LABEL,WindowFind("10.2 TmaSlope_Norm"),0,0);
    ObjectSet("label",OBJPROP_XDISTANCE,H_Pos);
    ObjectSet("label",OBJPROP_YDISTANCE,V_Pos);
    ObjectSet("label",OBJPROP_CORNER,Corner);
    ObjectSetText("label"," "+tt+" ",Font_Size,"Arial",Font_Color);
   
    string sObjName="InfoBar1";
   if (gadblSlope[0] >= edblHigh1)
      ObjectSetText(sObjName, "Buy Only", Font_Size_text, "Verdana", Black);
   
   else if (gadblSlope[0] <= edblLow1)
      ObjectSetText(sObjName, "Sell Only", Font_Size_text, "Verdana", Red);
   
   else 
      ObjectSetText(sObjName, "Ranging", Font_Size_text, "Verdana", DarkGreen);
      
   
   string name1 = "InfoBar1";
   
   switch(select_other_tf_to_show)
   {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="Current";
   } 
   
   ObjectCreate(sObjName, OBJ_LABEL,WindowFind("10.2 TmaSlope_Norm"), 0, 0);
   ObjectSet(sObjName, OBJPROP_CORNER, Text_Corner);
   ObjectSet(sObjName, OBJPROP_XDISTANCE, H_Pos_text);//left to right
   ObjectSet(sObjName, OBJPROP_YDISTANCE, V_Pos_text);//top to bottom

    dblTmaMTF = calcTmaMTF( 0 , select_other_tf_to_show );
      dblPrevMTF = calcTmaMTF( 1 , select_other_tf_to_show);
      double hh = ( dblTmaMTF - dblPrevMTF ) / atrMTF;
if(hh>=0.5) Font_Color_MTF=Black;
else if (hh<=-0.5) Font_Color_MTF=Red;
else Font_Color_MTF=DarkGreen;
string jj=DoubleToStr(hh,2);
    ObjectCreate("label MTF",OBJ_LABEL,WindowFind("10.2 TmaSlope_Norm"),0,0);
    ObjectSet("label MTF",OBJPROP_XDISTANCE,H_Pos_MTF);
    ObjectSet("label MTF",OBJPROP_YDISTANCE,V_Pos_MTF);
    ObjectSet("label MTF",OBJPROP_CORNER,Corner_MTF);
   ObjectSetText("label MTF",""+TimeFrameStr+" = "+jj+" ",Font_Size_MTF,"Arial",Font_Color_MTF);
     }
   return( 0 );
}

//+------------------------------------------------------------------+
//| getTick()                                                        |
//+------------------------------------------------------------------+
double getTick() {
    double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (AdditionalDigit) {
        tick *= 10;
    }    
    return (tick);
}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( int inx )
{
   double dblSum  = (eintPeriod+1)*Close[inx];
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * Close[inx+jnx] );
      dblSumw += knx;

      if ( jnx <= inx )
      {
         dblSum  += ( knx * Close[inx-jnx] );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}
 
 
 double calcTmaMTF( int inx , int tf)
{
   double dblSum  = (eintPeriod+1)*iClose(Symbol(),tf,inx);
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(Symbol(),tf,inx+jnx) );
      dblSumw += knx;

      if ( jnx <= inx )
      {
         dblSum  += ( knx * iClose(Symbol(),tf,inx-jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



   


