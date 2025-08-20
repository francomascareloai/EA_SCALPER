//+------------------------------------------------------------------+
//|                                        Brooky_Garnish_Levels.mq4 |
//|                      Copyright © 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Tomato
#property indicator_color3 IndianRed
#property indicator_color4 Green
#property indicator_color5 CadetBlue
#property indicator_color6 DodgerBlue
#property indicator_color7 Blue
#property indicator_color8 Crimson


//--- input parameters

#property indicator_width1 3
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 4
#property indicator_width5 1
#property indicator_width6 2
#property indicator_width7 3
#property indicator_width8 4


extern double    SensitivityPercent = 61.8;
extern bool      UseAutoFit = true;
extern double    FitRatio = 1;

extern bool      HorizontalMode = false;


extern double    Ratio_1=0.0125;
extern double    Ratio_2=0.025;
extern double    Ratio_3=0.033;
extern double    Ratio_4=0.0375;
extern double    Ratio_5=0.05;
extern double    Ratio_6=0.0625;

//--- buffers
double P_Upper_3[];
double P_Upper_2[];
double P_Upper_1[];

double P_Centre[];

double P_Lower_1[];
double P_Lower_2[];
double P_Lower_3[];

double P_Data[];

double    Step=0.005,Max=0.005;
static double Diffamount;
int       TimeFrame = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(8);
   SetIndexBuffer(0,P_Upper_3);SetIndexStyle(0,DRAW_LINE);SetIndexLabel(0,"Upper_3");
   
   SetIndexBuffer(1,P_Upper_2);SetIndexStyle(1,DRAW_LINE);SetIndexLabel(1,"Upper_2");
   
   SetIndexBuffer(2,P_Upper_1);SetIndexStyle(2,DRAW_LINE);SetIndexLabel(2,"Upper_1");
   
   
   SetIndexBuffer(3,P_Centre);SetIndexStyle(3,DRAW_LINE);SetIndexLabel(3,"Breakout_1");
   
   
   SetIndexBuffer(4,P_Lower_1);SetIndexStyle(4,DRAW_LINE);SetIndexLabel(4,"Lower_1");
   
   SetIndexBuffer(5,P_Lower_2);SetIndexStyle(5,DRAW_LINE);SetIndexLabel(5,"Lower_2");
   
   SetIndexBuffer(6,P_Lower_3);SetIndexStyle(6,DRAW_LINE);SetIndexLabel(6,"Lower_3");
   
   
   SetIndexBuffer(7,P_Data);SetIndexStyle(7,DRAW_LINE);SetIndexLabel(7,"Breakout_2");
   
   IndicatorShortName("Brooky Garnish");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   
   if(UseAutoFit)
   {
      
      if(Period()==1)FitRatio=Ratio_1*5;
      if(Period()==5)FitRatio=Ratio_1*10;
      if(Period()==15)FitRatio=Ratio_2*10;
      if(Period()==30)FitRatio=Ratio_3*10;
      if(Period()==60)FitRatio=Ratio_4*10;
      if(Period()==240)FitRatio=Ratio_6*10;
      if(Period()==1440)FitRatio=Ratio_2*100;
      if(Period()==10080)FitRatio=Ratio_4*100;
      if(Period()==43200)FitRatio=Ratio_6*100;
   
   }
    
   Step=SensitivityPercent*0.0001; Max=SensitivityPercent*0.0001;
   int    i,counted_bars=IndicatorCounted();
   int limit=Bars-counted_bars;
      
   if(counted_bars>0) limit++;
   
   for(i=limit; i>0; i--)
   
   {
   
   
   if(iSAR(Symbol(),TimeFrame,Step,Max,i)>=iClose(Symbol(),0,i) && iSAR(Symbol(),TimeFrame,Step,Max,i+1)<=iClose(Symbol(),0,i+1) )
   {
     Diffamount=(MathAbs(iSAR(Symbol(),TimeFrame,Step,Max,i)-iSAR(Symbol(),TimeFrame,Step,Max,i+1)));
   
   }
   if(iSAR(Symbol(),TimeFrame,Step,Max,i+1)>=iClose(Symbol(),0,i+1) && iSAR(Symbol(),TimeFrame,Step,Max,i)<=iClose(Symbol(),0,i) )
   {
      Diffamount=(MathAbs(iSAR(Symbol(),TimeFrame,Step,Max,i)-iSAR(Symbol(),TimeFrame,Step,Max,i+1)));
   
   }
   
   if(!HorizontalMode)
   {
   
   P_Centre[i]=iSAR(Symbol(),TimeFrame,Step,Max,i);
   P_Data[i]=iSAR(Symbol(),0,-Step,-Max,i);
   

   if(iSAR(Symbol(),TimeFrame,Step,Max,i)<=iLow(Symbol(),TimeFrame,i))
   {
   P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio);
   P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio);
   P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);
   P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);
   P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio);
   P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);   
   

   P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+Diffamount;
   
   }

   if(iSAR(Symbol(),TimeFrame,Step,Max,i)>=iHigh(Symbol(),TimeFrame,i))
   {
   
   P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);
   P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio);
   P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);
   P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);
   P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio);
   P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio);   
   
   P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-Diffamount;
   }
   }
   
   if(HorizontalMode)
   {
          P_Upper_3[i]= P_Upper_3[i+1];
          P_Upper_2[i]= P_Upper_2[i+1];
          P_Upper_1[i]= P_Upper_1[i+1];
          P_Lower_1[i]= P_Lower_1[i+1];
          P_Lower_2[i]= P_Lower_2[i+1];
          P_Lower_3[i]= P_Lower_3[i+1];
          P_Data[i]= P_Data[i+1];
          P_Centre[i]=P_Centre[i+1];
          
      if(iSAR(Symbol(),TimeFrame,Step,Max,i)>=iClose(Symbol(),0,i) && iSAR(Symbol(),TimeFrame,Step,Max,i+1)<=iClose(Symbol(),0,i+1) )
         {
             Diffamount=(MathAbs(iSAR(Symbol(),TimeFrame,Step,Max,i)-iSAR(Symbol(),TimeFrame,Step,Max,i+1)));
             if(iSAR(Symbol(),TimeFrame,Step,Max,i)<=iLow(Symbol(),TimeFrame,i))
               {
               P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio); 
               P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio); 
               P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);  
               P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);  
               P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio); 
               P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);   
   

               P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+Diffamount; 
               P_Centre[i]=iSAR(Symbol(),TimeFrame,Step,Max,i);
   
               }


      if(iSAR(Symbol(),TimeFrame,Step,Max,i)>=iHigh(Symbol(),TimeFrame,i))
          {
   
               P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);
               P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio);
               P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);
               P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);
               P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio);
               P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio);   
   
               P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-Diffamount;
               P_Centre[i]=iSAR(Symbol(),TimeFrame,Step,Max,i);
               } 
          
          
   
         }
       if(iSAR(Symbol(),TimeFrame,Step,Max,i+1)>=iClose(Symbol(),0,i+1) && iSAR(Symbol(),TimeFrame,Step,Max,i)<=iClose(Symbol(),0,i) )
         {
            Diffamount=(MathAbs(iSAR(Symbol(),TimeFrame,Step,Max,i)-iSAR(Symbol(),TimeFrame,Step,Max,i+1)));
             if(iSAR(Symbol(),TimeFrame,Step,Max,i)<=iLow(Symbol(),TimeFrame,i))
               {
               P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio); 
               P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio); 
               P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);  
               P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);  
               P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio); 
               P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);   
   

               P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)+Diffamount; 
               P_Centre[i]=iSAR(Symbol(),TimeFrame,Step,Max,i);
   
               }


      if(iSAR(Symbol(),TimeFrame,Step,Max,i)>=iHigh(Symbol(),TimeFrame,i))
          {
   
               P_Upper_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_1*FitRatio);
               P_Upper_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_2*FitRatio);
               P_Upper_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_3*FitRatio);
               P_Lower_1[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_4*FitRatio);
               P_Lower_2[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_5*FitRatio);
               P_Lower_3[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-(iSAR(Symbol(),TimeFrame,Step,Max,i)*Ratio_6*FitRatio);   
   
               P_Data[i]=iSAR(Symbol(),TimeFrame,Step,Max,i)-Diffamount;
               P_Centre[i]=iSAR(Symbol(),TimeFrame,Step,Max,i);
               }   
         }
 
         
   
   }
   

 }
  
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+