// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68998

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//Modified, 26/May/2021, by jeanlouie, www.forexfactory.com/jeanlouie
// - arrow buffers

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 clrNONE
#property indicator_color3 clrRed
#property indicator_color4 clrLime
#property indicator_color5 clrGreen
#property indicator_color6 clrOrange
#property indicator_style1 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_width1 1
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

#property indicator_level1 0
#property indicator_levelcolor clrGray

//#property indicator_maximum 3
//#property indicator_minimum -3

extern int    period         = 13;
extern int    arrow_shift    = 2;
extern int    nbars          = 300;
extern int    shift          = 1;
extern bool   show_arrow     = true;
extern color  arrow_up_color = clrLime;
extern color  arrow_dn_color = clrRed;
extern int    Arrow_size     = 0;  
extern bool   alertsOn       = true;
extern bool   alertsMessage  = true;
extern bool   alertsSound    = false;
extern bool   alertsNotify   = false;
extern bool   alertsEmail    = false;
extern string soundFile      = "alert.wav"; 
input int b_arr_val_up = 1;
input int b_arr_val_dn = -1;

string gral_name="gral_";
string s_symbol,s_id,s_gral;

double  ExtBuffer0[];
double  ExtBuffer1[];
double  ExtBuffer2[];
double  ExtBuffer3[];
double  ExtBuffer4[];
double  ExtBuffer5[];

//double arrow_down[];
//double arrow_up[];

bool flag_last_trend,flag_arr_up,flag_arr_dn,flag_start_max_search;
double last_trend,max_value;
int k;

datetime time_alert_buy,time_alert_sell;
int whichBar = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(6);
   
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);
   SetIndexBuffer(5,ExtBuffer5);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexStyle(5,DRAW_ARROW);
   
   SetIndexArrow(4,233);
   SetIndexArrow(5,234);
   
   SetIndexLabel(0,"line");
   SetIndexLabel(1,"arr");
   SetIndexLabel(2,"dn");
   SetIndexLabel(3,"up");
   SetIndexLabel(4,"Arr Up");
   SetIndexLabel(5,"Arr Dn");
   
   IndicatorDigits(Digits);

   s_symbol=Symbol();
   s_id=s_symbol+" "+fTimeFrameName(0);
   s_gral=gral_name+s_id;

   IndicatorShortName("GRAALUn");

   time_alert_buy=0;
   time_alert_sell=0;

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
   deleteArrows(s_gral);
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars;
   double Value0=0,Value1=0,Fish0=0,Fish1=0,Fish2=0,Fish3=0,Value00=0,Value11=0;
   double price;
   double MinL=0;
   double MaxH=0;
   bool   up = true;

   counted_bars=IndicatorCounted();

   if(counted_bars>0)
      counted_bars--;
   limit=Bars-counted_bars;

   for(int i = shift; i<limit; i++)
   {
      MaxH = High[iHighest(NULL,0,MODE_HIGH,period,i)];
      MinL = Low[iLowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;

      if(MaxH-MinL == 0)
         Value00 = 0.33*2*(0-0.5) + 0.67*Value0;
      else
         Value00 = 0.33*2*((price-MaxH)/(MinL-MaxH)-0.5) + 0.67*Value0;

      if(1-Value00==0)
         ExtBuffer0[i]=0.5+0.5*Fish0;
      else
         ExtBuffer0[i]=-0.5*MathLog((1+Value00)/(1-Value00))+0.5*Fish0;

      Value00=MathMin(MathMax(Value00,-0.999),0.999);

      Value0=Value00;
      Fish0=ExtBuffer0[i];

      if(MaxH-MinL==0)
         Value11=0.33*2*(0-0.5)+0.67*Value1;
      else
         Value11=0.33*2*((price-MaxH)/(MinL-MaxH)-0.5)+0.67*Value1;

      Value11=MathMin(MathMax(Value11,-0.999),0.999);

      if(1-Value11==0)
         ExtBuffer1[i]=0.5+0.5*Fish1;
      else
         ExtBuffer1[i]=-0.5*MathLog((1-Value11)/(1+Value11))+0.5*Fish1;

      Value1=Value11;
      Fish1=ExtBuffer1[i];
      
      Fish2=ExtBuffer0[i];
      Fish3=ExtBuffer1[i];

      if (((Fish2<0)&&(Fish3<0))||(Fish2<0))   up = false;    
      if (((Fish2>0)&&(Fish3>0))||(Fish2>0))   up = true;
      
      if(!up)
        {
         ExtBuffer2[i]=Fish2;
         ExtBuffer3[i]=0;
        }
        
       else
        {
         ExtBuffer3[i]=Fish2;
         ExtBuffer2[i]=0;
        }
      
     }

   flag_last_trend=false;
   k=0;
   flag_start_max_search=false;
   last_trend=0;
   max_value=0;

   for(int i = shift; i<nbars; i++)
   {
      flag_arr_up=false;
      flag_arr_dn=false;
      if(ExtBuffer1[i]>0 && ExtBuffer1[i+1]<=0)
      {
         if (show_arrow == true){
            create_arrow(s_gral+TimeToString(Time[i]),High[i]+arrow_shift*Point,Time[i],234,Arrow_size,arrow_dn_color,ANCHOR_BOTTOM);
            ExtBuffer5[i] = b_arr_val_dn;
         }
         else create_arrow(s_gral+TimeToString(Time[i]),High[i]+arrow_shift*Point,Time[i],234,0,clrNONE,ANCHOR_BOTTOM);
         
         if(!flag_last_trend)
         {
            k=i;
            flag_start_max_search=true;
            last_trend=-1;
            max_value=ExtBuffer1[i];
         }
         flag_last_trend=true;
         flag_arr_dn=true;
      }
      else ExtBuffer5[i] = EMPTY_VALUE;
      
      if(ExtBuffer1[i]<0 && ExtBuffer1[i+1]>=0)
      {
         if (show_arrow == true){
            create_arrow(s_gral+TimeToString(Time[i]),Low[i]-arrow_shift*Point,Time[i],233,Arrow_size,arrow_up_color,ANCHOR_TOP);
            ExtBuffer4[i] = b_arr_val_up;
         }
         else create_arrow(s_gral+TimeToString(Time[i]),Low[i]-arrow_shift*Point,Time[i],233,0,clrNONE,ANCHOR_TOP);
         if(!flag_last_trend)
         {
            k=i;
            flag_start_max_search=true;
            last_trend=1;
            max_value=ExtBuffer1[i];
         }
         flag_last_trend=true;
         flag_arr_up=true;
      }
      else ExtBuffer4[i] = EMPTY_VALUE;
      
      if(flag_start_max_search && i>k)
      {
         if(last_trend<0)
         {
            if(flag_arr_up)
               flag_start_max_search=false;
            else
               if(ExtBuffer0[i]>=max_value)
                  max_value=ExtBuffer0[i];
         }
         if(last_trend>0)
         {
            if(flag_arr_dn)
               flag_start_max_search=false;
            else
               if(ExtBuffer0[i]<=max_value)
                  max_value=ExtBuffer0[i];
         }
      }
   }

   int i = shift;
   if(alertsOn)
   {
      if((ExtBuffer1[i]>0 && ExtBuffer1[i+1]<=0) && (time_alert_sell!=Time[0]))
      {
         doAlert(whichBar,"SELL");
         time_alert_sell=Time[0];
      }
      if((ExtBuffer1[i]<0 && ExtBuffer1[i+1]>=0) && (time_alert_buy!=Time[0]))
      {
         doAlert(whichBar,"BUY");
         time_alert_buy=Time[0];
      }
   }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_arrow(string name,double price,datetime time,int arrow_code,int width,color _color,ENUM_ARROW_ANCHOR _anchor)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_ARROW,0,0,0);
     }
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_TIME,time);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,arrow_code);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,_anchor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteArrows(string arrowsIdentifier_)
  {
   string lookFor       = arrowsIdentifier_;
   int    lookForLength = StringLen(lookFor);
   for(int i_=ObjectsTotal()-1; i_>=0; i_--)

     {
      string objectName=ObjectName(i_);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
         ObjectDelete(objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fTimeFrameName(int arg)
  {
   if(arg==0)
     {
      arg=Period();
     }
   switch(arg)
     {
      case 0:
         return("0");
      case 1:
         return("M1");
      case 2:
         return("M2");
      case 5:
         return("M5");
      case 15:
         return("M15");
      case 30:
         return("M30");
      case 60:
         return("H1");
      case 240:
         return("H4");
      case 1440:
         return("D1");
      case 10080:
         return("W1");
      case 43200:
         return("MN1");
      default:
         return("M"+IntegerToString(arg));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];

      message =  StringConcatenate(WindowExpertName()," ",s_id," ",doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), Period(), WindowExpertName()),message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }
//+------------------------------------------------------------------+