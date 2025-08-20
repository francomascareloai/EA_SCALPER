// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=71267

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                        |
//+------------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_width1 1
#property indicator_label1 "Buy"
#property indicator_color2 White
#property indicator_width2 1
#property indicator_label2 "Sell"

double G_ibuf_76[];
double G_ibuf_80[];
extern int FasterMovingAverage = 3;
extern int SlowerMovingAverage = 4;
extern int RSIPeriod = 13;
extern int MagicFilterPeriod = 1;
extern int BollingerbandsPeriod = 21;
extern int BollingerbandsShift = 0;
extern double BollingerbandsDeviation = 0.8;
extern int BullsPowerPeriod = 34;
extern int BearsPowerPeriod = 34;
extern bool Alerts = TRUE;
extern int Utstup = 10;

input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = true; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key

int Gi_unused_128 = 0;
bool Gi_132 = FALSE;
bool Gi_136 = FALSE;
bool Gi_140 = FALSE;
bool Gi_144 = FALSE;
bool Gi_148 = FALSE;
bool Gi_152 = FALSE;
bool Gi_156 = FALSE;
bool Gi_160 = FALSE;
bool Gi_164 = FALSE;
bool Gi_168 = FALSE;
int Gi_172 = 0;
bool Gi_176 = FALSE;
bool Gi_180 = FALSE;

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, "", "");
   }
};
Signaler* signaler;

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_CURRENT: return TimeframeToString((ENUM_TIMEFRAMES)_Period);
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
   return "";
}

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, G_ibuf_76);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, G_ibuf_80);
   signaler = new Signaler();
   signaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   delete signaler;
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int pos;
   double ima_12;
   double ima_20;
   double ima_28;
   double ima_36;
   double irsi_44;
   double irsi_52;
   double ibullspower_60;
   double ibullspower_68;
   double ibearspower_76;
   double ibearspower_84;
   double Ld_92;
   double Ld_100;
   double Ld_108;
   double Ld_116;
   double Ld_124;
   double Ld_132;
   double Ld_140;
   double ibands_152;
   double ibands_160;
   double ibands_168;
   double ibands_176;
   int Li_148 = IndicatorCounted();
   if (Li_148 < 0) return (-1);
   if (Li_148 > 0) Li_148--;
   int Li_0 = Bars - Li_148 - 11;
   for (int Li_4 = 0; Li_4 <= Li_0; Li_4++) {
      Ld_132 = 0;
      Ld_140 = 0;
      for (pos = Li_4; pos <= Li_4 + 10; pos++) 
      {
         Ld_140 += MathAbs(High[pos] - Low[pos]);
      }
      Ld_132 = Ld_140 / 10.0;
      ima_12 = iMA(NULL, 0, FasterMovingAverage, 0, MODE_EMA, PRICE_CLOSE, Li_4);
      ima_28 = iMA(NULL, 0, FasterMovingAverage, 0, MODE_EMA, PRICE_CLOSE, Li_4 + 1);
      ima_20 = iMA(NULL, 0, SlowerMovingAverage, 0, MODE_EMA, PRICE_CLOSE, Li_4);
      ima_36 = iMA(NULL, 0, SlowerMovingAverage, 0, MODE_EMA, PRICE_CLOSE, Li_4 + 1);
      irsi_44 = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Li_4);
      irsi_52 = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Li_4 + 1);
      ibullspower_60 = iBullsPower(NULL, 0, BullsPowerPeriod, PRICE_CLOSE, Li_4);
      ibullspower_68 = iBullsPower(NULL, 0, BullsPowerPeriod, PRICE_CLOSE, Li_4 + 1);
      ibearspower_76 = iBearsPower(NULL, 0, BearsPowerPeriod, PRICE_CLOSE, Li_4);
      ibearspower_84 = iBearsPower(NULL, 0, BearsPowerPeriod, PRICE_CLOSE, Li_4 + 1);
      ibands_152 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_UPPER, Li_4);
      ibands_160 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_LOWER, Li_4);
      ibands_168 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_UPPER, Li_4 + 1);
      ibands_176 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_LOWER, Li_4 + 1);
      Ld_92 = iHighest(NULL, 0, MODE_HIGH, MagicFilterPeriod, Li_4);
      Ld_100 = iHighest(NULL, 0, MODE_LOW, MagicFilterPeriod, Li_4);
      Ld_108 = 100 - 100.0 * ((Ld_92 - 0.0) / 10.0);
      Ld_116 = 100 - 100.0 * ((Ld_100 - 0.0) / 10.0);
      if (Ld_108 == 0.0) Ld_108 = 0.0000001;
      if (Ld_116 == 0.0) Ld_116 = 0.0000001;
      Ld_124 = Ld_108 - Ld_116;
      if (Ld_124 >= 0.0) {
         Gi_148 = TRUE;
         Gi_168 = FALSE;
      } else {
         if (Ld_124 < 0.0) {
            Gi_148 = FALSE;
            Gi_168 = TRUE;
         }
      }
      if (Close[Li_4] > ibands_152 && Close[Li_4 + 1] >= ibands_168) {
         Gi_144 = FALSE;
         Gi_164 = TRUE;
      }
      if (Close[Li_4] < ibands_160 && Close[Li_4 + 1] <= ibands_176) {
         Gi_144 = TRUE;
         Gi_164 = FALSE;
      }
      if (ibullspower_60 > 0.0 && ibullspower_68 > ibullspower_60) {
         Gi_140 = FALSE;
         Gi_160 = TRUE;
      }
      if (ibearspower_76 < 0.0 && ibearspower_84 < ibearspower_76) {
         Gi_140 = TRUE;
         Gi_160 = FALSE;
      }
      if (irsi_44 > 50.0 && irsi_52 < 50.0) {
         Gi_136 = TRUE;
         Gi_156 = FALSE;
      }
      if (irsi_44 < 50.0 && irsi_52 > 50.0) {
         Gi_136 = FALSE;
         Gi_156 = TRUE;
      }
      if (ima_12 > ima_20 && ima_28 < ima_36) {
         Gi_132 = TRUE;
         Gi_152 = FALSE;
      }
      if (ima_12 < ima_20 && ima_28 > ima_36) {
         Gi_132 = FALSE;
         Gi_152 = TRUE;
      }
      if (Gi_132 == TRUE && Gi_136 == TRUE && Gi_144 == TRUE && Gi_140 == TRUE && Gi_148 == TRUE && Gi_172 != 1) {
         G_ibuf_76[Li_4] = Low[Li_4] - (Point * Utstup); //1.3 * Ld_132;
         if (Li_4 <= 2 && Alerts && (!Gi_176)) {
            Alert(Symbol(), " ", Period(), "   BUY");
            signaler.SendNotifications("BUY");
            Gi_176 = TRUE;
            Gi_180 = FALSE;
         }
         Gi_172 = 1;
      } else {
         if (Gi_152 == TRUE && Gi_156 == TRUE && Gi_164 == TRUE && Gi_160 == TRUE && Gi_168 == FALSE && Gi_172 != 2) {
            G_ibuf_80[Li_4] = High[Li_4] + (Point * Utstup); // 1.3 * Ld_132;
            if (Li_4 <= 2 && Alerts && (!Gi_180)) {
               Alert(Symbol(), " ", Period(), "   SELL");
               signaler.SendNotifications("SELL");
               Gi_180 = TRUE;
               Gi_176 = FALSE;
            }
            Gi_172 = 2;
         }
      }
   }
   return (0);
}
