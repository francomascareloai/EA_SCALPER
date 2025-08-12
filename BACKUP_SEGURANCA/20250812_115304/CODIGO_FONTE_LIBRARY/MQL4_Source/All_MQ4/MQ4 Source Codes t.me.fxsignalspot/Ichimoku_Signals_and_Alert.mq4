// Id: 20637
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65794

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.1"

#property description "Signals and Alerts given by crossing of Price with components of the Ichimoku:"
#property description "- Kijun-sen with Price"
#property description "- Senkou span A with Price"
#property description "- Senkou span B with Price"
#property description "- Tenkan-sen with Kijun-sen"
#property description "- Senkou span A with Senkou span B"

#property indicator_chart_window

#property  indicator_buffers 12
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrLime
#property indicator_color4  clrRed
#property indicator_color5  clrLime
#property indicator_color6  clrRed
#property indicator_color7  clrLime
#property indicator_color8  clrRed
#property indicator_color9  clrLime
#property indicator_color10  clrRed
#property indicator_color11  clrLime
#property indicator_color12  clrRed

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_width9  2
#property indicator_width10  2
#property indicator_width11  2
#property indicator_width12  2

extern int  Tenkan_Sen_Period                = 9;
extern int  Kijun_Sen_Period                 = 26;
extern int  Senkou_Span_B_Period             = 52;
extern bool Show_Kijun_Sen                   = true;
extern bool Show_Senkou_Span_A               = true;
extern bool Show_Senkou_Span_B               = true;
extern bool Show_Tenkan_Sen_Kijun_Sen        = true;
extern bool Show_Senkou_Span_A_Senkou_Span_B = true;
//Signaler v 1.5
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

private:
   string GetTimeframe()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

datetime LastAlert;

double KIJUNSEN_up[], KIJUNSEN_dn[];
double SENKOUSPANA_up[], SENKOUSPANA_dn[];
double SENKOUSPANB_up[], SENKOUSPANB_dn[];
double CHIKOUSPAN_up[], CHIKOUSPAN_dn[];
double TENKANSEN_KIJUNSEN_up[], TENKANSEN_KIJUNSEN_dn[];
double SENKOUSPANA_SENKOUSPANB_up[], SENKOUSPANA_SENKOUSPANB_dn[];

double TENKANSEN[];
double KIJUNSEN[];
double SENKOUSPANA[];
double SENKOUSPANB[];
double CHIKOUSPAN[];

string IndName;
int      WindowNumber;
Signaler *signaler;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   IndicatorBuffers(17);
   
   SetIndexBuffer(0,KIJUNSEN_up);
   SetIndexStyle (0,DRAW_ARROW);
   SetIndexArrow (0,233);
   SetIndexBuffer(1,KIJUNSEN_dn);
   SetIndexStyle (1,DRAW_ARROW);
   SetIndexArrow (1,234);
   
   SetIndexBuffer(2,SENKOUSPANA_up);
   SetIndexStyle (2,DRAW_ARROW);
   SetIndexArrow (2,233);
   SetIndexBuffer(3,SENKOUSPANA_dn);
   SetIndexStyle (3,DRAW_ARROW);
   SetIndexArrow (3,234);
   
   SetIndexBuffer(4,SENKOUSPANB_up);
   SetIndexStyle (4,DRAW_ARROW);
   SetIndexArrow (4,233);
   SetIndexBuffer(5,SENKOUSPANB_dn);
   SetIndexStyle (5,DRAW_ARROW);
   SetIndexArrow (5,234);
   
   SetIndexBuffer(6,CHIKOUSPAN_up);
   SetIndexStyle (6,DRAW_ARROW);
   SetIndexArrow (6,233);
   SetIndexBuffer(7,CHIKOUSPAN_dn);
   SetIndexStyle (7,DRAW_ARROW);
   SetIndexArrow (7,234);
   
   SetIndexBuffer(8,TENKANSEN_KIJUNSEN_up);
   SetIndexStyle (8,DRAW_ARROW);
   SetIndexArrow (8,233);
   SetIndexBuffer(9,TENKANSEN_KIJUNSEN_dn);
   SetIndexStyle (9,DRAW_ARROW);
   SetIndexArrow (9,234);
   
   SetIndexBuffer(10,SENKOUSPANA_SENKOUSPANB_up);
   SetIndexStyle (10,DRAW_ARROW);
   SetIndexArrow (10,233);
   SetIndexBuffer(11,SENKOUSPANA_SENKOUSPANB_dn);
   SetIndexStyle (11,DRAW_ARROW);
   SetIndexArrow (11,234);
   
   SetIndexBuffer(12,TENKANSEN);
   SetIndexBuffer(13,KIJUNSEN);
   SetIndexBuffer(14,SENKOUSPANA);
   SetIndexBuffer(15,SENKOUSPANB);
   SetIndexBuffer(16,CHIKOUSPAN);
   
   IndName = "Ichimoku_Signals_and_Alerts";
   IndicatorShortName(IndName);
   
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,5.0);
   
//---- initialization done
   return(0);
  }

int deinit()
{
   delete signaler;
   return 0;
}

int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   string Alerts;
   
   for(i=limit ; i>=0; i--){
   
      Alerts = "";
      
      TENKANSEN[i]   = iIchimoku(NULL,0,Tenkan_Sen_Period,Kijun_Sen_Period,Senkou_Span_B_Period,1,i);
      KIJUNSEN[i]    = iIchimoku(NULL,0,Tenkan_Sen_Period,Kijun_Sen_Period,Senkou_Span_B_Period,2,i);
      SENKOUSPANA[i] = iIchimoku(NULL,0,Tenkan_Sen_Period,Kijun_Sen_Period,Senkou_Span_B_Period,3,i);
      SENKOUSPANB[i] = iIchimoku(NULL,0,Tenkan_Sen_Period,Kijun_Sen_Period,Senkou_Span_B_Period,4,i);
      CHIKOUSPAN[i]  = iIchimoku(NULL,0,Tenkan_Sen_Period,Kijun_Sen_Period,Senkou_Span_B_Period,5,i);
      
      if (Show_Kijun_Sen){
         if (Close[i] > KIJUNSEN[i] && Close[i+1] < KIJUNSEN[i+1]){
            KIJUNSEN_up[i] = Close[i];
            if (i==0) Alerts+= " KIJUNSEN (up) ";
         }
         if (Close[i] < KIJUNSEN[i] && Close[i+1] > KIJUNSEN[i+1]){
            KIJUNSEN_dn[i] = Close[i];
            if (i==0) Alerts+= " KIJUNSEN (down) ";
         }
      }
      
      if (Show_Senkou_Span_A){
         if (Close[i] > SENKOUSPANA[i] && Close[i+1] < SENKOUSPANA[i+1]){
            SENKOUSPANA_up[i] = Close[i];
            if (i==0) Alerts+= " SENKOUSPANA (up) ";
         }
         if (Close[i] < SENKOUSPANA[i] && Close[i+1] > SENKOUSPANA[i+1]){
            SENKOUSPANA_dn[i] = Close[i];
            if (i==0) Alerts+= " SENKOUSPANA (down) ";
         }
      }
      
      if (Show_Senkou_Span_B){
         if (Close[i] > SENKOUSPANB[i] && Close[i+1] < SENKOUSPANB[i+1]){
            SENKOUSPANB_up[i] = Close[i];
            if (i==0) Alerts+= " SENKOUSPANB (up) ";
         }
         if (Close[i] < SENKOUSPANB[i] && Close[i+1] > SENKOUSPANB[i+1]){
            SENKOUSPANB_dn[i] = Close[i];
            if (i==0) Alerts+= " SENKOUSPANB (down) ";
         }
      }
      
      if (Show_Tenkan_Sen_Kijun_Sen){
         if (TENKANSEN[i] > KIJUNSEN[i] && TENKANSEN[i+1] < KIJUNSEN[i+1]){
            TENKANSEN_KIJUNSEN_up[i] = TENKANSEN[i];
            if (i==0) Alerts+= " TENKANSEN_KIJUNSEN (up) ";
         }
         if (TENKANSEN[i] < KIJUNSEN[i] && TENKANSEN[i+1] > KIJUNSEN[i+1]){
            TENKANSEN_KIJUNSEN_dn[i] = TENKANSEN[i];
            if (i==0) Alerts+= " TENKANSEN_KIJUNSEN (down) ";
         }
      }
      
      if (Show_Senkou_Span_A_Senkou_Span_B){
         if (SENKOUSPANA[i] > SENKOUSPANB[i] && SENKOUSPANA[i+1] < SENKOUSPANB[i+1]){
            SENKOUSPANA_SENKOUSPANB_up[i] = SENKOUSPANA[i];
            if (i==0) Alerts+= " SENKOUSPANA_SENKOUSPANB (up) ";
         }
         if (SENKOUSPANA[i] < SENKOUSPANB[i] && SENKOUSPANA[i+1] > SENKOUSPANB[i+1]){
            SENKOUSPANA_SENKOUSPANB_dn[i] = SENKOUSPANA[i];
            if (i==0) Alerts+= " SENKOUSPANA_SENKOUSPANB (down) ";
         }
      }
   
   }
   
   if (Time[0] > LastAlert && Alerts!=""){
      signaler.SendNotifications("Ichimoku Alerts "+Symbol()+": "+Alerts);
      LastAlert = TimeCurrent();
   }
      
//---- done
   return(0);
}

