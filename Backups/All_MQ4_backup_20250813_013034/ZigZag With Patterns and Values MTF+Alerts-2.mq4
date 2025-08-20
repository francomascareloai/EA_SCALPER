//+------------------------------------------------------------------+
//|                                         ZigZag_with_patterns.mq4 |
//|                                          modify by franiok |
//|                                                                  |
//+------------------------------------------------------------------+

//edited by jeanlouie
// - removed ObjectsDeleteAll();
// - added tag for indicator objects
// - delete indicator objects on deinit

#property copyright "rewritten by CrazyChart, modify by franiok www.freefxsystem.com"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

//
//
//
//
//

extern string TimeFrame="";
extern int       barn=1000;
extern int       Length=20;
extern int       PatternLength=10;
extern int        PatternWidth=4;
extern color       PatternColor = Yellow;
extern bool       DrawZigZag = true;
extern bool   ShowValues      = true;
extern color  ValueColor      = Orange;

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsNotify    = false;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//---- buffers
double ExtMapBuffer1[];
double trend[];
int    timeFrame;
string indicatorFileName;
bool   calculateValue;
string tag="";
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   tag = "zzpvmtf";
   IndicatorBuffers(2);
   SetIndexEmptyValue(0,0.0);
  //SetIndexDrawBegin(0, barn);
  if (DrawZigZag == true)  {SetIndexStyle(0,DRAW_SECTION);}
  else {SetIndexStyle(0,DRAW_NONE);}
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,trend);
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//ObjectsDeleteAll();
   for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
   {
      string objname = ObjectName(iObj);
      if(StringFind(objname, tag) != -1){ObjectDelete(0,objname);}
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
 
   int shift,Swing,Swing_n,uzl,i,zu,zd,mv;
   double LL,HH,BH,BL; 
   double Uzel[10000][3]; 
   string text;

   if (calculateValue || timeFrame==Period())
   {
    
    //ObjectDelete(OBJ_TREND);
    

// loop from first bar to current bar (with shift=0) 
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[barn];BL=Low[barn];zu=barn;zd=barn; 



for (shift=barn;shift>=0;shift--) { 
      LL=10000000;HH=-100000000; 
   for (i=shift+Length;i>=shift+1;i--) { 
         if (Low[i]< LL) {LL=Low[i];
           
         } 
         if (High[i]>HH) {HH=High[i];} 

  }
 
   if (Low[shift]<LL && High[shift]>HH){ 
      Swing=2; 
      if (Swing_n==1) {zu=shift+1;} 
      if (Swing_n==-1) {zd=shift+1;
 
      } 
      
   } else { 
      if (Low[shift]<LL) {Swing=-1;} 
      if (High[shift]>HH) {Swing=1;} 
   } 

   if (Swing!=Swing_n && Swing_n!=0) { 
   if (Swing==2) {
      Swing=-Swing_n;BH = High[shift];BL = Low[shift]; 
   } 
   uzl=uzl+1; 
   trend[shift] = trend[shift+1];
   if (Swing==1) {
      Uzel[uzl][1]=zd;
      Uzel[uzl][2]=BL;
      NewSid(i,zd,BL);
      trend[shift] = 1;
     
   } 
   if (Swing==-1) {
      Uzel[uzl][1]=zu;
      Uzel[uzl][2]=BH; 
       NewSid(i,zu,BH);
       trend[shift] = -1;
   } 
      BH = High[shift];
      BL = Low[shift]; 
      

   } 
 
   
/*

 */
   
   

   if (Swing==1) { 
      if (High[shift]>=BH) {BH=High[shift];zu=shift;}} 
      if (Swing==-1) {
          if (Low[shift]<=BL) {BL=Low[shift]; zd=shift;}} 
      Swing_n=Swing; 
   } 

   

   
   for (i=1;i<=uzl;i++) { 
         mv=StrToInteger(DoubleToStr(Uzel[i][1],0));
      ExtMapBuffer1[mv]=Uzel[i][2];
      

   
   } 
   manageAlerts();
   return(0);
  }

   //
   //
   //
   //
   //

   for(shift=barn; shift>=0; shift--)
   {
      int y = iBarShift(NULL,timeFrame,Time[shift]);
      int x = iBarShift(NULL,timeFrame,Time[shift+1]);
         ExtMapBuffer1[shift] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",barn,Length,PatternLength,PatternWidth,PatternColor,DrawZigZag,ShowValues,ValueColor,0,y);
         if (x==y) ExtMapBuffer1[shift] = 0;
   }
   manageAlerts();   
   return(0);
   
}  
  void NewSid(int i, int re,  double Uzels)
{

int zed=re-PatternLength;

if (zed < 0)
   {
   ObjectCreate(tag+"priceLine1_"+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_PRICE1,Uzels);
  
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_TIME2,Time[re+PatternLength]); 
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_PRICE2,Uzels);   
    
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_COLOR,PatternColor);
   ObjectSet(tag+"priceLine1_"+i,OBJPROP_RAY, false);
   ObjectSet(tag+"priceLine1_"+i,OBJPROP_WIDTH,PatternWidth);
   

   }
   
   
   
   
  else {

   ObjectCreate(tag+"priceLine1_"+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_PRICE1,Uzels);
  
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_TIME2,Time[re-PatternLength]); 
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_PRICE2,Uzels);   
    
   ObjectSet(tag+"priceLine1_"+i ,OBJPROP_COLOR,PatternColor);
   ObjectSet(tag+"priceLine1_"+i,OBJPROP_RAY, false);
   ObjectSet(tag+"priceLine1_"+i,OBJPROP_WIDTH,PatternWidth);
}

      string high  = DoubleToStr(High[re],5);
      string low   = DoubleToStr(Low[re],5);
      string open  = DoubleToStr(Open[re],5);
      string close = DoubleToStr(Close[re],5);



if (ShowValues == true)

{
   ObjectCreate(tag+"price_text"+i,OBJ_TEXT,0,0,0);
   //ObjectSetText("price_text"+i,"Date: "+TimeToStr(Time[re],TIME_DATE | TIME_MINUTES)+" | Time: ",10,"Calibri", Green);
   
   ObjectSetText(tag+"price_text"+i,"Open: "+open+" | High: "+high+" | Low: "+low+" | Close: "+close,8,"Calibri", ValueColor);
   ObjectSet(tag+"price_text"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet(tag+"price_text"+i ,OBJPROP_PRICE1,Uzels);
}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(Period())+" ZigZag patterns and values trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," ZigZag patterns and values "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


