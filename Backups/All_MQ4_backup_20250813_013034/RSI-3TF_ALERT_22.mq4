//+------------------------------------------------------------------+
//|                                          RSI-3TF_ALERT_25.mq4 
//+------------------------------------------------------------------+
#property copyright "AHGduP"
#property link      "RSI-3TF_ALERT_25"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Magenta
#property indicator_color2 Aqua
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 White
#property indicator_color6 White
#property indicator_color7 GreenYellow
#property indicator_color8 Yellow

#property indicator_minimum   0
#property indicator_maximum   100

//=============================================================
#property indicator_level1 93
#property indicator_level3 50
#property indicator_level2 7
#property indicator_levelcolor DarkGray  
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 0

//====================  INPUT  =================================
extern string     RSI_INPUT_1     = "=== RSI A ===";
extern int        RSI_Period_1    = 2 ;
extern int        RSI_Period_2    = 2 ;
extern int        RSI_Period_3    = 2 ;//4

extern string     RSI_INPUT_2     = "=== RSI B ===";
extern int        RSI_Period_B1   = 2 ;//6
extern int        RSI_Period_B2   = 2 ;//6
extern int        RSI_Period_B3   = 2 ;//6
//============================================================

extern int TF1         = 0 ;
extern int TF2         = 0 ;
extern int TF3         = 0 ;

bool   StepTF1_Up   =  true ; 
bool   StepTF2_Up   =  true ; 
bool   StepTF3_Up   =  true ; 

extern int  LineSize1     = 1 ;
extern int  LineSize2     = 1 ;
extern int  LineSize3     = 2 ;
extern int LineSize4      = 1 ;//<<<<<<<<< ek het bygesit
extern int  DotSizeRSI    = 1 ;
extern int  DotSizeARROW  = 1 ;
extern int  DotSizeZERO   = 1 ;
extern int  DotSizeRSI5   = 4 ;
extern int NumberOfBars   = 500 ; 

double R1up,R2up,R3up;
double R1dn,R2dn,R3dn;
double up1, down1 ;

double BR1up,BR2up,BR3up;
double BR1dn,BR2dn,BR3dn;
double Bup1, Bdown1 ;
//------------------------------------------------
double RSIBuffer1[];
double RSIBuffer2[];
double RSIBuffer3[];
double RSIBuffer4[];
double upX[];
double dnX[];
double RSIBuffer5[];
double RSIBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
 {
    string short_name;
    SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, LineSize1);
    SetIndexBuffer(0, RSIBuffer1);
    SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, LineSize2);
    SetIndexBuffer(1, RSIBuffer2);
    SetIndexStyle (2, DRAW_LINE, STYLE_SOLID, LineSize3);
    SetIndexBuffer(2, RSIBuffer3);

    SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,DotSizeRSI);
    SetIndexArrow(3,159);
    SetIndexBuffer(3,RSIBuffer4);
    
    SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,DotSizeARROW);
    SetIndexArrow(4,233);
    SetIndexBuffer(4,upX);
    SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,DotSizeARROW);
    SetIndexArrow(5,234);
    SetIndexBuffer(5,dnX);
    
    SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,DotSizeZERO);
    SetIndexArrow(6,159);
    SetIndexBuffer(6,RSIBuffer5);
    
    SetIndexStyle(7,DRAW_ARROW,STYLE_SOLID,DotSizeRSI5);
    SetIndexArrow(7,159);
    SetIndexBuffer(7,RSIBuffer6);
  
    up1   = 0 ;
    down1 = 0 ;
    Bup1   = 0 ;
    Bdown1 = 0 ;
  
//========================================================================================    
     switch(TF1)   {    case 1 : string TimeFrameStr1="Period_M1"; break;
                        case 5 : TimeFrameStr1="Period_M5"; break;
                       case 15 : TimeFrameStr1="Period_M15"; break;
                       case 30 : TimeFrameStr1="Period_M30"; break;
                       case 60 : TimeFrameStr1="Period_H1"; break;
                      case 240 : TimeFrameStr1="Period_H4"; break;
                     case 1440 : TimeFrameStr1="Period_D1"; break;
                    case 10080 : TimeFrameStr1="Period_W1"; break;
                    case 43200 : TimeFrameStr1="Period_MN1"; break;
                       default : TimeFrameStr1="Current Timeframe";
                   SetStepTF1_Up();
                 }
//=======================================================================================      
    switch(TF2)   {     case 1 : string TimeFrameStr2="Period_M1"; break;
                        case 5 : TimeFrameStr2="Period_M5"; break;
                       case 15 : TimeFrameStr2="Period_M15"; break;
                       case 30 : TimeFrameStr2="Period_M30"; break;
                       case 60 : TimeFrameStr2="Period_H1"; break;
                      case 240 : TimeFrameStr2="Period_H4"; break;
                     case 1440 : TimeFrameStr2="Period_D1"; break;
                    case 10080 : TimeFrameStr2="Period_W1"; break;
                    case 43200 : TimeFrameStr2="Period_MN1"; break;
                       default : TimeFrameStr2="Current Timeframe";
                   SetStepTF2_Up();
                  }
//=======================================================================================     
    switch(TF3)    {    case 1 : string TimeFrameStr3="Period_M1"; break;
                        case 5 : TimeFrameStr3="Period_M5"; break;
                       case 15 : TimeFrameStr3="Period_M15"; break;
                       case 30 : TimeFrameStr3="Period_M30"; break;
                       case 60 : TimeFrameStr3="Period_H1"; break;
                      case 240 : TimeFrameStr3="Period_H4"; break;
                     case 1440 : TimeFrameStr3="Period_D1"; break;
                    case 10080 : TimeFrameStr3="Period_W1"; break;
                    case 43200 : TimeFrameStr3="Period_MN1"; break;
                       default : TimeFrameStr3="Current Timeframe";
                    SetStepTF3_Up();
                  }
//=======================================================================================  

        string  ThisName = "RSI-3TF_ALERT_22";
        string Text=ThisName;
        Text=Text+"  ("+TF1;
        Text=Text+", "+TF2;
        Text=Text+", "+TF3;
        Text=Text+")";
        Text=Text+"(";
        Text=Text+" "+DoubleToStr(RSI_Period_1,0);
        Text=Text+", "+DoubleToStr(RSI_Period_2,0);
        Text=Text+", "+DoubleToStr(RSI_Period_3,0);
        Text=Text+")  ";
       IndicatorShortName(Text); 
 
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void start()
 {
     static datetime AlertTime = 0;
     int limit,LoopBegin, sh, nsb,nsb2,nsb3;
     
  //---------------------------------------------------------------------   
    // limit=Bars-NumberOfBars+TF1/Period();
    // limit=Bars-NumberOfBars+TF2/Period();
    // limit=Bars-NumberOfBars+TF3/Period();
    
         limit=Bars-NumberOfBars;
  //--------------------------------------------------------------------  
       
    	if (NumberOfBars==0) LoopBegin=Bars-1;
      else LoopBegin=NumberOfBars-1;

     for (sh=LoopBegin; sh>=0; sh--) {
         nsb3=iBarShift(NULL, TF1, Time[sh], False);
         nsb=iBarShift(NULL, TF2, Time[sh], False);
         nsb2=iBarShift(NULL, TF3, Time[sh], False);
        
        RSIBuffer1[sh]=iRSI(NULL, TF1, RSI_Period_1, PRICE_CLOSE, nsb3);
        RSIBuffer2[sh]=iRSI(NULL, TF2, RSI_Period_2, PRICE_CLOSE, nsb);
        RSIBuffer3[sh]=iRSI(NULL, TF3, RSI_Period_3, PRICE_CLOSE, nsb2);
        RSIBuffer4[sh]=iRSI(NULL, TF3, RSI_Period_3, PRICE_CLOSE, nsb2);
    
//=========================================================================    
    if      (RSIBuffer1[sh] > 50 ) R1up =1; else R1up =0; 
    if      (RSIBuffer2[sh] > 50 ) R2up =1; else R2up =0; 
    if      (RSIBuffer3[sh] > 50 ) R3up =1; else R3up =0; 
    if      ( up1 == 0 && AlertTime != Time[sh] && ( R1up + R2up + R3up ) == 3 )  
               {  upX[sh] = 30;  
               // PlaySound("buy.wav");
               // AlertTime = Time[sh];
                  up1   = 1;  down1 = 0;
               }
     
   if       (RSIBuffer1[sh] < 50 ) R1dn =1; else R1dn =0; 
   if       (RSIBuffer2[sh] < 50 ) R2dn =1; else R2dn =0;
   if       (RSIBuffer3[sh] < 50 ) R3dn =1; else R3dn =0;
   if      ( down1 == 0 && AlertTime != Time[sh] && ( R1dn + R2dn + R3dn ) == 3 )  
                {  dnX[sh] = 70; 
                // PlaySound("sell.wav"); 
               //  AlertTime = Time[sh];
                  up1   = 0;  down1 = 1;
               }
//===========cancel signal  and re enter in same direction===========================    
  
      if  (  up1 == 1
                &&  ( R1up + R2up + R3up ) != 3 
          )
              {  up1 = 0;   down1 = 0;
              }    
         
         
     if  (  down1 == 1 
                &&  ( R1dn + R2dn + R3dn ) != 3  
          
         )
              {  up1 = 0;   down1 = 0;
              }     
 
//====================================================================  
    if (RSIBuffer1[sh] > 50 && RSIBuffer1[sh+1] < 50 ) RSIBuffer5[sh] = 50; 
    if (RSIBuffer2[sh] > 50 && RSIBuffer2[sh+1] < 50 ) RSIBuffer5[sh] = 50; 
    if (RSIBuffer3[sh] > 50 && RSIBuffer3[sh+1] < 50 ) RSIBuffer5[sh] = 50; 
    if (RSIBuffer1[sh] < 50 && RSIBuffer1[sh+1] > 50 ) RSIBuffer5[sh] = 50; 
    if (RSIBuffer2[sh] < 50 && RSIBuffer2[sh+1] > 50 ) RSIBuffer5[sh] = 50; 
    if (RSIBuffer3[sh] < 50 && RSIBuffer3[sh+1] > 50 ) RSIBuffer5[sh] = 50; 



//==========================  RSI  5   =======================================

        double RSIB1=iRSI(NULL, TF1, RSI_Period_B1, PRICE_CLOSE, nsb3);
        double RSIB2=iRSI(NULL, TF2, RSI_Period_B2, PRICE_CLOSE, nsb);
        double RSIB3=iRSI(NULL, TF3, RSI_Period_B3, PRICE_CLOSE, nsb2);
        
//=========================================================================    
    if      (RSIB1 > 50 ) BR1up =1; else BR1up =0; 
    if      (RSIB2 > 50 ) BR2up =1; else BR2up =0; 
    if      (RSIB3 > 50 ) BR3up =1; else BR3up =0; 
    if      ( Bup1 == 0 &&  ( BR1up + BR2up + BR3up ) == 3 )  
               {  RSIBuffer6[sh] = 95;  
                //  PlaySound("buy.wav");
                //  AlertTime = Time[sh];
                  Bup1   = 1;  Bdown1 = 0;
               }
     
   if       (RSIBuffer1[sh] < 50 ) BR1dn =1; else BR1dn =0; 
   if       (RSIBuffer2[sh] < 50 ) BR2dn =1; else BR2dn =0;
   if       (RSIBuffer3[sh] < 50 ) BR3dn =1; else BR3dn =0;
   if      ( Bdown1 == 0 && ( BR1dn + BR2dn + BR3dn ) == 3 )  
                {  RSIBuffer6[sh] = 95; 
                 //  PlaySound("sell.wav"); 
                 //  AlertTime = Time[sh];
                  Bup1   = 0;  Bdown1 = 1;
               }
//===========cancel signal  and re enter in same direction===========================    
  
      if  (  Bup1 == 1
                &&  ( BR1up + BR2up + BR3up ) != 3 
          )
              {  Bup1 = 0;   Bdown1 = 0;
              }    
         
         
     if  (  Bdown1 == 1 
                &&  ( BR1dn + BR2dn + BR3dn ) != 3  
          
         )
              {  Bup1 = 0;   Bdown1 = 0;
              }     
//========================================================================================              
  }
}
//==============================step timeframe up TF1====================================  
       void SetValues(int p1) { TF1 = p1;        }                                    
       void SetStepTF1_Up()   { switch (Period() )                
           { case PERIOD_M1  :  SetValues(PERIOD_M30);   break;       
             case PERIOD_M5  :  SetValues(PERIOD_H1);   break;         
             case PERIOD_M15 :  SetValues(PERIOD_H4);   break;     
             case PERIOD_M30 :  SetValues(PERIOD_D1);    break;            
             case PERIOD_H1  :  SetValues(PERIOD_W1);    break;               
             case PERIOD_H4  :  SetValues(PERIOD_MN1);    break;                
             case PERIOD_D1  :  SetValues(PERIOD_MN1);    break;                
             case PERIOD_W1  :  SetValues(PERIOD_MN1);   break;             
             case PERIOD_MN1 :  SetValues(PERIOD_MN1);   break;                   
          } }   
//============================== TF2 ===================================================     
       void SetValues2(int p2) {  TF2 = p2;         }                                    
       void SetStepTF2_Up()    {  switch (Period()  )                
          { case PERIOD_M1  :  SetValues2(PERIOD_M15);   break;       
            case PERIOD_M5  :  SetValues2(PERIOD_M30);   break;         
            case PERIOD_M15 :  SetValues2(PERIOD_H1);    break;     
            case PERIOD_M30 :  SetValues2(PERIOD_H4);    break;            
            case PERIOD_H1  :  SetValues2(PERIOD_D1);    break;               
            case PERIOD_H4  :  SetValues2(PERIOD_W1);    break;                
            case PERIOD_D1  :  SetValues2(PERIOD_MN1);    break;                
            case PERIOD_W1  :  SetValues2(PERIOD_MN1);   break;             
            case PERIOD_MN1 :  SetValues2(PERIOD_MN1);   break;                   
         } }    
//=============================== TF3 ==================================================  
        void SetValues3(int p3)  {  TF3 = p3;        }                                   
        void SetStepTF3_Up()     {  switch (Period() )                
           {  case PERIOD_M1  :  SetValues3(PERIOD_M5);   break;       
              case PERIOD_M5  :  SetValues3(PERIOD_M15);   break;         
              case PERIOD_M15 :  SetValues3(PERIOD_M30);   break;     
              case PERIOD_M30 :  SetValues3(PERIOD_H1);  break;            
              case PERIOD_H1  :  SetValues3(PERIOD_H4);   break;               
              case PERIOD_H4  :  SetValues3(PERIOD_D1);   break;                
              case PERIOD_D1  :  SetValues3(PERIOD_W1);   break;                
              case PERIOD_W1  :  SetValues3(PERIOD_MN1);   break;             
              case PERIOD_MN1 :  SetValues3(PERIOD_MN1);  break;                   
           } }    
 //================================================================================== ++  



