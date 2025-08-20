// v1.01
// - modified by jeanlouie 22/9/2020, forexfactory.com
// - report of not every alert being alerted
#property version "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#define NAME MQLInfoString(MQL_PROGRAM_NAME)
input int      EMAvalue=3;//EMA Value
input color    bearClr=clrRed;//Bear Colour
input color    bullClr=clrBlue;//Bull Colour
input color    emaClr=clrWhite;//EMA Colour
input string bearmsg="Bear Message";//Bear Message
input string bullmsg="Bull Message";//Bull Message
double         k=10*Point,bearArr[], bullArr[], emaBff[];
//+------------------------------------------------------------------+
int OnInit(){
   SetIndexBuffer(0,bullArr); SetIndexLabel(0,"bull"); SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,2,bullClr);SetIndexArrow(0,241);
   SetIndexBuffer(1,bearArr); SetIndexLabel(0,"bear"); SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,2,bearClr);SetIndexArrow(1,242);
   SetIndexBuffer(2,emaBff); SetIndexLabel(0,"ema"); SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,EMPTY,emaClr);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   return(INIT_SUCCEEDED);}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]) {
   int limit = MathMax(rates_total-prev_calculated,2);
   double avg;
   for(int i=1;i<limit;i++){
      avg = iMA(NULL,0,EMAvalue,0,MODE_EMA,PRICE_CLOSE,i);
      if (Low[i]>avg)  {bearArr[i]=High[i]+k; bullArr[i]=EMPTY_VALUE;if(prev_calculated!=0)Alerts(1);}
      if (High[i]<avg) {bullArr[i]=Low[i]-k; bearArr[i]=EMPTY_VALUE;if(prev_calculated!=0)Alerts(0);}
      emaBff[i]=avg;}
   return(rates_total);}
//+------------------------------------------------------------------+

void Alerts(int dir){
  //static datetime newbar=-1;
  //datetime temp=iTime(NULL,0,0);
  //if(newbar!=-1&&newbar<temp)
  static datetime new_alert;
  if(iTime(NULL,0,0)!=new_alert){
   new_alert = iTime(NULL,0,0);
   if(dir==0)Alert(NAME+" "+_Symbol+" "/*\n*/+bullmsg);
   if(dir==1)Alert(NAME+" "+_Symbol+" "/*\n*/+bearmsg);}
  //newbar=temp;
  }