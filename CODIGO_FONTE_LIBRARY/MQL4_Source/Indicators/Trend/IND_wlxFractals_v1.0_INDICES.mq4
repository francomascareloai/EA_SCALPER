//+------------------------------------------------------------------+
//|                                                  wlxFractals.mq4 |
//|         Copyright © 2004, by konKop, GOODMAN, Mstera, af + wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
// 2014-10-06 by Capella at WWI
// - Run a script to convert . to _ in variable names

#property copyright "Copyright © 2004, by wellx"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int Equals = 5;
extern int nLeftUp = 2;
extern int nRightUp = 2;
extern int nLeftDown = 2;
extern int nRightDown = 2;
//---- buffers
double FractalsUp[];
double FractalsDown[];
//----
int pos = 0, cntup = 0, cntdown = 0, cnt = 0;
int r = 0, l = 0, e = 0;
int fup = 0, fdown = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0, FractalsUp);
   SetIndexBuffer(1, FractalsDown);   
//----
   SetIndexStyle(0, DRAW_ARROW, 0, 0);
   SetIndexArrow(0, 217);
//----
   SetIndexStyle(1, DRAW_ARROW, 0, 0);
   SetIndexArrow(1, 218);
//----
   cntup = nLeftUp + nRightUp + Equals + 1;
   cntdown = nLeftDown + Equals + 1;
   if(cntup >= cntdown) 
       cnt = cntup;
   if(cntup < cntdown)  
       cnt = cntdown; 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i=0, j=0;
   int cbars = IndicatorCounted();
//----
   if(cbars < 0) 
       return(-1);
//----
   if(cbars > 0) 
       cbars--;
   pos = 0;
//----
   if(cbars > (Bars - cnt - 1)) 
       pos =(Bars - cnt - 1);
   else 
       pos = Bars - (cbars + nRightUp);
//----
   while(pos >= nRightUp)
     {
       FractalsUp[pos] = NULL;
       FractalsDown[pos] = NULL;     
       //фРАКТАЛ ВВЕРХ
       r = nRightUp; //проверяем правую сторону фрактала
       //----
       for(i = 1; i <= r; i++)
         {
           if(High[pos] <= High[pos-i]) 
               break;
         }
       //если справа все ОК то i должно быть равно r+1
       if(i == r + 1) //FractalsUp[pos]=High[pos];
         {
           l = nLeftUp;  //проверяем левую сторону фрактала
           e = Equals;
           //----
           for(j = 1; j <= l + Equals; j++)
             {     
               if(High[pos] < High[pos+j]) 
                   break;
               //----
               if(High[pos] > High[pos+j]) 
                   l--;
               //----
               if(High[pos] == High[pos+j])
                   e--;
               //----
               if(l == 0) 
                 {
                   FractalsUp[pos] = High[pos];
                   break;
                 }
               //----
               if(e < 0) 
                   break;
             }
         }
       //ФРАКТАЛ ВНИЗ
       r = nRightDown; //проверяем правую сторону фрактала
       //----
       for(i = 1; i <= r; i++)
         {
           if(Low[pos] >= Low[pos-i]) 
               break;
         }     
       //----
       if(i == r + 1) //FractalsUp[pos]=High[pos];
         {
           l = nLeftDown;  //проверяем левую сторону фрактала
           e = Equals;
           //----
           for(j = 1; j <= l + Equals; j++)
             {      
               if(Low[pos] > Low[pos+j]) 
                   break;
               //----
               if(Low[pos] < Low[pos+j]) 
                   l--;
               //----
               if(Low[pos] == Low[pos+j])
                   e--;
               //----
               if(l == 0) 
                 {
                   FractalsDown[pos] = Low[pos];
                   break;
                 }
               if(e < 0) 
                   break;
             }
         }
       pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+