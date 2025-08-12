//+------------------------------------------------------------------+
//|                                                     Trigger Line |
//|                             Copyright © 2005 dwt5 and adoleh2000 |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005 dwt5 and adoleh2000 "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4            
#property indicator_color1 Red      
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int width;

extern bool Alerts = false;
extern int Rperiod = 15;
extern int LSMA_Period = 5;
int Draw4HowLong;
int shift;
int i;
int j;
int loopbegin;
int length;
int lsma_length;

double lengthvar;
double tmp ;
double tmp2 ;
double wt[];
double sum[];
double lsma_sum[];
double lsma_ma[];
double middle[];
int c;
bool TurnedUp = false;
bool TurnedDown = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 7 additional buffers are used for counting.
   IndicatorBuffers(7);   
   
//---- drawing settings
   
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   
   
   
   SetIndexBuffer(4,sum);        
   SetIndexBuffer(5,wt);         
   SetIndexBuffer(6,lsma_ma);
   
//---- initialization done
   return(0);
  }

int start()

{
   Draw4HowLong = Bars-Rperiod - 5;                            //Rperiod = 20
   length = Rperiod;                                           //length now = 20  
   lsma_length = LSMA_Period;
   loopbegin = Draw4HowLong - length - 1;   
      
   for(shift = loopbegin; shift >= 0; shift--)  //  MAIN For Loop
   { 
      sum[1] = 0;                                              
      for(i = length; i >= 1  ; i--)             //LSMA loop
      {
         lengthvar = length + 1;                               //lengthvar = 21  
         lengthvar /= 3;                                       //lengthvar = 7
         tmp = 0;
         tmp = ( i - lengthvar)*Close[length-i+shift];         //tmp = 20 - 7 * close[20-i+shift]
         sum[1]+=tmp;
      }
      wt[shift] = sum[1]*6/(length*(length+1));  
      j = shift;
      lsma_ma[shift] = wt[j+1] + (wt[j]-wt[j+1])* 2/(lsma_length+1);
  
//========== COLOR CODING ===========================================                       
        
        
      ExtMapBuffer1[shift] = wt[shift]; 
      ExtMapBuffer2[shift] = lsma_ma[shift]; 
      ExtMapBuffer3[shift] = wt[shift]; 
      ExtMapBuffer4[shift] = lsma_ma[shift]; 
            
      if (wt[shift]  < lsma_ma[shift])
      {
          ExtMapBuffer4[shift] = EMPTY_VALUE;
          ExtMapBuffer3[shift] = EMPTY_VALUE;
      }          
        
   }
        
   if (Alerts)
   {
      if (wt[1] > lsma_ma[1])
      {
         if (!TurnedUp)
         {
            Alert ("Triggerlines turned up on ",Symbol(),"-",Period());
            PlaySound("alert.wav");
            TurnedUp = true;
            TurnedDown = false;
         }
      }
      if (wt[1] < lsma_ma[1])
      {
         if (!TurnedDown)
         {
            Alert ("Triggerlines turned down on ",Symbol(),"-",Period());
            PlaySound("timeout.wav");
            TurnedDown = true;
            TurnedUp = false;
         }
      }
   }
}
//+------------------------------------------------------------------+

