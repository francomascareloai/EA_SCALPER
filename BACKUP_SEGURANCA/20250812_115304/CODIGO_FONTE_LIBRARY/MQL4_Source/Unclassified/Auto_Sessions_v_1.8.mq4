//+------------------------------------------------------------------+
//|                                           Auto_Sessions_v1.6.mq4 |
//|                                        Copyright © 2010, cameofx |
//|                                                cameofx@gmail.com |
//|                                                                  |
//| 09-03-2011, Mark Pickersgill
//|   - Fixed issue with time frames crossing over midnight
//|   - Tidied up and documented some of the code
//| ver 1.8, 2011/7/24  Jani Verho
//|   - Added GMT shift
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, cameofx"
#property link      "cameofx@gmail.com"

#property indicator_chart_window
extern string SessionNames  = "Tokyo/London/NY";
extern string SessionGMTInfo= "GMT=0 assumes times below";
extern string SessionBeginInfo2= "00:00/07:00/13:00";
extern string SessionEndInfo= "09:00/17:00/22:00";
extern int GMTOffSet        =-5;               // Platform GMT offset assumes GMT=0 => Session Begin 00:00/07:00/13:00 Session End 09:00/17:00/22:00
string SessionBegins = "23:00/08:00/13:00";    // In the Platform's TimeZone
string SessionEnds   = "07:00/16:00/21:00";    // In the Platform's TimeZone
extern color  color1        = ForestGreen; //C'5,55,6'; 
extern color  color2        = Purple; //C'5,35,56'; 
extern color  color3        = DarkBlue; //C'65,5,46'; 
extern color  color4        = C'5,25,34'; 
extern color  color5        = C'25,65,5'; 
extern bool   FillColor     = true;
extern int    FrameWidth    = 1; 
extern int    FrameStyle    = 1; 
//extern bool   ShowPips      = true; 
//extern bool   AppendPips    = true;
extern int    LabelSize     = 8;
extern string LabelFont     = "Arial Bold";
extern color  LabelColor    = DarkKhaki;

string sTIME_BEGIN = "1970.01.01", saName[], saBeg[], saEnd[];
datetime t0, curDate, lastDate[], t1[], t2[];
bool MidnightCross[];  // Do any of the start to end times cross midnight
double lo[], hi[], vPoint; 
color col[]; 
int pip[], pipRange, Qty;

//+------------------------------------------------------------------+
int init()
{
if(GMTOffSet>6 ||GMTOffSet<-6 ){GMTOffSet=0;Alert("GMT offset value below -6 or above 6 !!! Value reset to: "+GMTOffSet);  }

if(GMTOffSet==-6){
SessionBegins = "18:00/02:00/07:00";    
SessionEnds   = "03:00/11:00/16:00";   
}
if(GMTOffSet==-5){
SessionBegins = "19:00/03:00/08:00";    
SessionEnds   = "04:00/12:00/17:00";   
}
if(GMTOffSet==-4){
SessionBegins = "20:00/04:00/09:00";    
SessionEnds   = "05:00/13:00/18:00";   
}
if(GMTOffSet==-3){
SessionBegins = "21:00/05:00/10:00";    
SessionEnds   = "06:00/14:00/19:00";   
}
if(GMTOffSet==-2){
SessionBegins = "22:00/06:00/11:00";    
SessionEnds   = "07:00/15:00/20:00";   
}
if(GMTOffSet==-1){
SessionBegins = "23:00/07:00/12:00";    
SessionEnds   = "08:00/16:00/21:00";   
}
if(GMTOffSet==0){
SessionBegins = "00:00/08:00/13:00";    
SessionEnds   = "09:00/17:00/22:00";   
}
if(GMTOffSet==1){
SessionBegins = "01:00/09:00/14:00";    
SessionEnds   = "10:00/18:00/23:00";   
}
if(GMTOffSet==2){
SessionBegins = "02:00/10:00/15:00";    
SessionEnds   = "11:00/19:00/00:00";   
}
if(GMTOffSet==3){
SessionBegins = "03:00/11:00/16:00";    
SessionEnds   = "12:00/20:00/01:00";   
}
if(GMTOffSet==4){
SessionBegins = "04:00/12:00/17:00";    
SessionEnds   = "13:00/21:00/02:00";   
}
if(GMTOffSet==5){
SessionBegins = "05:00/13:00/18:00";    
SessionEnds   = "14:00/22:00/03:00";   
}
if(GMTOffSet==6){
SessionBegins = "06:00/14:00/19:00";    
SessionEnds   = "15:00/23:00/04:00";   
}


   // Deal with micro-pips
   if(Digits==3 || Digits==5)
      vPoint = Point*10; 
   else 
      vPoint = Point;
   
   Qty = stringExtract_(SessionNames,"/",saName);  
   stringExtract_(SessionBegins,"/",saBeg);  
   stringExtract_(SessionEnds,"/",saEnd);  
   
   if (Qty>5)
      Qty = 5; 
         
   ArrayResize(lo,Qty); 
   ArrayInitialize(lo,99999999.0);
   ArrayResize(hi,Qty); 
   ArrayInitialize(hi,0.0);
   ArrayResize(t1,Qty);
   ArrayResize(t2,Qty);
   ArrayResize(pip,Qty);
   ArrayResize(col,Qty);
   ArrayResize(lastDate,Qty);
   ArrayResize(MidnightCross, Qty);

   col[0] = color1; 
   col[1] = color2; 
   col[2] = color3; 
   col[3] = color4; 
   col[4] = color5;
   t0 = StrToTime(sTIME_BEGIN); 
   curDate  = t0; 
   
   int g = 0;
   while(g<Qty){
      t1[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saBeg[g]));  
      t2[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saEnd[g])); 
      if (t1[g] > t2[g]) 
      {
         t2[g]+=86000;
         MidnightCross[g] = true;
      }
      else
      {
         MidnightCross[g] = false;
      }
      pip[g] = 0;
      lastDate[g] = t0; 
      g++;
   }
   
   return(0);
  }
//+------------------------------------------------------------------+ 
int deinit()
  {
   int g; 
   while(g<Qty)
   {
      clear_(saName[g]); 
      clear_(StringConcatenate("Pip",saName[g]));
      g++;
   } 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iterations                                      |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   if(counted_bars< 0) 
      return(-1);
   if(counted_bars> 0) 
      counted_bars--;
   int limit = Bars-1-counted_bars; 
   
   for(i=limit; i>=0; i--)
   {
      curDate = stripToDate_(Time[i]); 
      int g = 0;
      while(g<Qty){
         Session_(saName, curDate, lastDate, t1, t2, lo, hi, pip, col[g], g, i); 
         g++;
      }
   }  
   return(0);
  }
//+------------------------------------------------------------------+
void Session_(string& ses[], datetime cu_Date, datetime& las[], datetime& t1[], datetime& t2[], 
              double& l1[], double& h1[], int& pip[], color col1, int g, int i)
{
   bool TimeOk;
   
   // Check to see if the Bar time is in the given range and taking into consideration time ranges crossing midnight
   if (Time[i] >= (cu_Date+t1[g]) && Time[i] <= (cu_Date+t2[g]))
   {
      // Time is within the current day's time range
      TimeOk = true;
   }
   else if (MidnightCross[g] && (Time[i] < (cu_Date+t1[g])) && (Time[i] < (cu_Date-86400+t2[g])))
   {
      // Time is within the current day's time range, but is within a range that stretches back to the previous day.
      TimeOk = true;
      cu_Date = cu_Date-86400;
   }
   else
      TimeOk = false;
   
   // If we are in the given time bracket, draw or update the session rectangles and pip count
   if (TimeOk)
   {
      //if (Time[i] == StartTime)
      if (cu_Date > las[g])
      {
         // Create a new session and associated objects as the session has started
         las[g] = cu_Date; 
         l1[g] = Low[i]; 
         h1[g] = High[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         createSes_(ses[g], cu_Date, t1[g], l1[g], t2[g], h1[g], col1);
         createPip_(ses[g], cu_Date, t1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], pip[g]);
      }
      if (Low[i] < l1[g]){
         // A new low has been reached, so updated the visual objects
         l1[g] = Low[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         reDrawSes_(ses[g], cu_Date, l1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], pip[g]);
      }
      if (High[i] > h1[g]){

         // A new high has been reached, so updated the visual objects
         h1[g] = High[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         reDrawSes_(ses[g], cu_Date, l1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], pip[g]);
      }
   }
}
//+------------------------------------------------------------------+
void createSes_(string name, datetime cu_Date, datetime t1, double p1, datetime t2, double p2, color col)
{
   name = StringConcatenate(name, cu_Date);
   ObjectCreate(name, OBJ_RECTANGLE, 0, cu_Date + t1, p1, cu_Date + t2 , p2);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_BACK, FillColor); 
   ObjectSet(name, OBJPROP_STYLE, FrameStyle);
   ObjectSet(name, OBJPROP_WIDTH, FrameWidth);
}
//+------------------------------------------------------------------+
void reDrawSes_(string name, datetime cu_Date, double price1, double price2)
{
   name = StringConcatenate(name, cu_Date);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
}
//+------------------------------------------------------------------+ 
void createPip_(string name, datetime cu_Date, datetime t1, double p1)
{
   name = StringConcatenate("Pip", name, cu_Date);
   ObjectCreate(name, OBJ_TEXT, 0, cu_Date + t1, p1);
}
//+------------------------------------------------------------------+
void reDrawPip_(string name, datetime cu_Date, double p1, int pip)
{
   name = StringConcatenate("Pip", name, cu_Date);
   ObjectSetText(name, StringConcatenate("                ", pip, " pips"), 
   LabelSize, LabelFont, LabelColor);
   ObjectSet(name, OBJPROP_PRICE1, p1);
}
//+------------------------------------------------------------------+
int stringExtract_(string toRead, string delimChar, string& ReadValue[]) 
{
   int delimPos[]; 
   int len=StringLen(toRead); 
   int curpos; 
   int Qty=0;
   ArrayResize(delimPos,len); 
   ArrayInitialize(delimPos,  0);
   ArrayResize(ReadValue,len); 
   
   for(curpos=0; curpos<=len;)
   { 
      delimPos[Qty]=curpos-1;
      curpos = StringFind(toRead,delimChar,curpos)+1;
      if(curpos<=0) 
         break; 
      Qty++; 
   }
   if (Qty==0)
      ReadValue[0]=toRead; 
   else
   {
      for (int j=0; j<=Qty; j++)
         ReadValue[j] = StringSubstr(toRead,delimPos[j]+1,(delimPos[j+1]-delimPos[j])-1); 
   }
   return(Qty+1);
}
//+------------------------------------------------------------------+
datetime stripToDate_( datetime aTime )  
{                                           
   double ModVal = MathMod(aTime,86400);
   
   aTime -= ModVal;
           
   return(aTime);                        
}
//+------------------------------------------------------------------+
void clear_(string prefix) {
int prefix_len = StringLen(prefix);
   for(int i=ObjectsTotal(); i>=0; i--)
   {      
     string name = ObjectName(i);
        if (StringSubstr(name,0,prefix_len) == prefix) ObjectDelete(name);
   }    
}
//+------------------------------------------------------------------+

