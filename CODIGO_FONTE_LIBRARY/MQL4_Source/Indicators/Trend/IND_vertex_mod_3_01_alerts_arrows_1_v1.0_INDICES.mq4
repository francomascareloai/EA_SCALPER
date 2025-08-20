#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     Red
#property indicator_color2     Blue
#property indicator_color3     Gray
#property indicator_color4     Gray
#property indicator_levelcolor MediumOrchid


extern int Processed        = 2000;
extern int Control_Period   = 14;

extern int Signal_Period    = 5;
extern int Signal_Method    = MODE_SMA;

extern int BB_Up_Period     = 12;
extern int BB_Up_Deviation  = 2;

extern int BB_Dn_Period     = 12;
extern int BB_Dn_Deviation  = 2;

extern double levelOb                  = 6;
extern double levelOs                  = -6;
extern double extremelevelOb           = 10;
extern double extremelevelOs           = -10;

extern bool   alertsOn                 = true;
extern bool   alertsOnObOs             = false;
extern bool   alertsOnExtremeObOs      = true;
extern bool   alertsOnCurrent          = false;
extern bool   alertsMessage            = true;
extern bool   alertsSound              = true;
extern bool   alertsEmail              = false;
extern bool   alertsNotify             = false;
extern string soundfile                = "alert2.wav";

extern bool   arrowsVisible            = true;
extern string arrowsIdentifier         = "vertex arrows1";
extern double arrowsUpperGap           = 1.0;
extern double arrowsLowerGap           = 1.0;

extern bool   arrowsOnObOs             = true;
extern color  arrowsObOsUpColor        = LimeGreen;
extern color  arrowsObOsDnColor        = Red;
extern int    arrowsObOsUpCode         = 241;
extern int    arrowsObOsDnCode         = 242;
extern int    arrowsObOsUpSize         = 1;
extern int    arrowsObOsDnSize         = 1;

extern bool   arrowsOnExtremeObOs      = true;
extern color  arrowsExtremeObOsUpColor = DeepSkyBlue;
extern color  arrowsExtremeObOsDnColor = PaleVioletRed;
extern int    arrowsExtremeObOsUpCode  = 159;
extern int    arrowsExtremeObOsDnCode  = 159;
extern int    arrowsExtremeObOsUpSize  = 5;
extern int    arrowsExtremeObOsDnSize  = 5;



double values[];
double signal[];
double band_up[];
double band_dn[];
double trend1[];
double trend2[];

int init() 
{
  IndicatorBuffers(6);
  SetIndexBuffer(0, values);
  SetIndexBuffer(1, signal);
  SetIndexBuffer(2, band_up);
  SetIndexBuffer(3, band_dn);  
  SetIndexBuffer(4, trend1);
  SetIndexBuffer(5, trend2);  
  SetLevelValue(0,levelOb);
  SetLevelValue(1,levelOs);
  SetLevelValue(2,extremelevelOb);
  SetLevelValue(3,extremelevelOs);
  return (0);
}

int deinit()
{
   deleteArrows();

return(0);
}

//
//
//
//
//

int start()
{
  datetime bar_time;
  int idx, counter, offset, bar_shft, bar_cont;
  double price_high, price_close, price_low, trigger_high, trigger_low;
  double sum_up, sum_dn, complex_up, complex_dn;

  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  if (counted > 0) counted--;
  int limit = Bars - counted;
  if (limit > Processed) limit = Processed;

  for (idx = limit; idx >= 0; idx--) {
    counter = 0;
    complex_up = 0; complex_dn = 0;
    trigger_high = -999999; trigger_low  = 999999;

    while (counter < Control_Period) {
      sum_up = 0; sum_dn = 0;
         
      offset = idx + counter;
      bar_time = iTime(Symbol(), 0, offset);
      bar_shft = iBarShift(Symbol(), 0, bar_time, FALSE);
      bar_cont = bar_shft - Period(); if (bar_cont < 0) bar_cont = 0;
         
      for (int jdx = bar_shft; jdx >= bar_cont; jdx--) {   
        price_high  = iHigh(Symbol(), 0, jdx); 
        price_close = iClose(Symbol(), 0, jdx); 
        price_low   = iLow(Symbol(), 0, jdx);
        if (price_high > trigger_high) {trigger_high = price_high; sum_up += price_close;}
        if (price_low  < trigger_low ) {trigger_low  = price_low;  sum_dn += price_close;}
      }
     
      counter++;
      complex_up += sum_up; complex_dn += sum_dn;        
    }
    if (complex_dn != 0.0 && complex_up != 0.0) 
      values[idx] = complex_dn / complex_up - complex_up / complex_dn;
  }
  
  for (idx = limit; idx >= 0; idx--) 
  { 
    signal[idx]  = iMAOnArray(values, 0, Signal_Period, 0, Signal_Method, idx); 
    band_up[idx] = iBandsOnArray(values, 0, BB_Up_Period, BB_Up_Deviation, 0, MODE_UPPER, idx); 
    band_dn[idx] = iBandsOnArray(values, 0, BB_Dn_Period, BB_Dn_Deviation, 0, MODE_LOWER, idx); 
    trend1[idx]  = trend1[idx+1];
    trend2[idx]  = trend2[idx+1];
    if (values[idx]>levelOb)        trend1[idx] =-1;
    if (values[idx]<levelOs)        trend1[idx] = 1;
    if (values[idx]>extremelevelOb) trend2[idx] =-1;
    if (values[idx]<extremelevelOs) trend2[idx] = 1;
    
    //
    //
    //
    //
    //
    
    if (arrowsVisible)
    {
      ObjectDelete(arrowsIdentifier+":1:"+Time[idx]);
      ObjectDelete(arrowsIdentifier+":2:"+Time[idx]);
      string lookFor = arrowsIdentifier+":"+Time[idx]; ObjectDelete(lookFor);
      if (arrowsOnObOs && trend1[idx] != trend1[idx+1])
      {
         if (trend1[idx] == 1) drawArrow("1",0.5,idx,arrowsObOsUpColor,arrowsObOsUpCode,arrowsObOsUpSize,false);
         if (trend1[idx] ==-1) drawArrow("1",0.5,idx,arrowsObOsDnColor,arrowsObOsDnCode,arrowsObOsDnSize, true);
      } 
      if (arrowsOnExtremeObOs && trend2[idx] != trend2[idx+1])
      {
         if (trend2[idx] == 1) drawArrow("2",1,idx,arrowsExtremeObOsUpColor,arrowsExtremeObOsUpCode,arrowsExtremeObOsUpSize,false);
         if (trend2[idx] ==-1) drawArrow("2",1,idx,arrowsExtremeObOsDnColor,arrowsExtremeObOsDnCode,arrowsExtremeObOsDnSize, true);
      }                              
    }    
  }
  
  //
  //
  //
  //
  // 
  
  if (alertsOn)
  {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnObOs && trend1[whichBar] != trend1[whichBar+1])
      {
         if (trend1[whichBar] ==  1) doAlert(time1,mess1,whichBar,"crossing oversold");
         if (trend1[whichBar] == -1) doAlert(time1,mess1,whichBar,"crossing overbought");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnExtremeObOs && trend2[whichBar] != trend2[whichBar+1])
      {
         if (trend2[whichBar] ==  1) doAlert(time2,mess2,whichBar,"crossing extreme oversold");
         if (trend2[whichBar] == -1) doAlert(time2,mess2,whichBar,"crossing extreme overbought");
      }
   }
return (0);
}

//
//
//
//
//

void drawArrow(string nameAdd, double gapMul, int i,color theColor,int theCode,int theWidth,bool up)
{
   string name = arrowsIdentifier+":"+nameAdd+":"+Time[i];
   double gap  = iATR(NULL,0,20,i)*gapMul;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theWidth);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
   
//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

        message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Vertex ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Vertex "),message);
          if (alertsSound)   PlaySound(soundfile);
   }
}

