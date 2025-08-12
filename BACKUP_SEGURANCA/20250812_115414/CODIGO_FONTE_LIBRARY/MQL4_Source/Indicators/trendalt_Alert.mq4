

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 DodgerBlue
#property indicator_color3 Red
#property indicator_width2 2
#property indicator_width3 2

extern string Notealerts="-----Alert Settings-----";
extern bool MsgAlerts=true;
extern bool SoundAlerts=true;
extern string SoundAlertFile="alert.wave";
extern bool eMailAlerts=false;

int LastAlertBar; //Alert code


extern int BarsCount = 14;
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];


int init() {
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   IndicatorDigits(Digits + 0);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexBuffer(1, g_ibuf_84);
   SetIndexBuffer(2, g_ibuf_88);
   IndicatorShortName("trendline_fast");
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

int start() {
   double ld_8;
   double ld_16;
   double ld_80;
   int li_4 = IndicatorCounted();
   double ld_32 = 0;
   double ld_40 = 0;
   double ld_unused_48 = 0;
   double ld_unused_56 = 0;
   double ld_64 = 0;
   double ld_unused_72 = 0;
   double l_low_88 = 0;
   double l_high_96 = 0;
   if (li_4 > 0) li_4--;
   int li_0 = Bars - li_4;
   for (int li_104 = 0; li_104 < li_0; li_104++) {
      l_high_96 = High[iHighest(NULL, 0, MODE_HIGH, BarsCount, li_104)];
      l_low_88 = Low[iLowest(NULL, 0, MODE_LOW, BarsCount, li_104)];
      ld_80 = (High[li_104] + Low[li_104]) / 2.0;
      ld_32 = 0.66 * ((ld_80 - l_low_88) / (l_high_96 - l_low_88) - 0.5) + 0.67 * ld_40;
      ld_32 = MathMin(MathMax(ld_32, -0.999), 0.999);
      g_ibuf_80[li_104] = MathLog((ld_32 + 1.0) / (1 - ld_32)) / 2.0 + ld_64 / 2.0;
      ld_40 = ld_32;
      ld_64 = g_ibuf_80[li_104];
   }
   bool li_108 = TRUE;
   for (li_104 = li_0 - 2; li_104 >= 0; li_104--) {
      ld_16 = g_ibuf_80[li_104+1];
      ld_8 = g_ibuf_80[li_104 + 2];
      if ((ld_16 < 0.0 && ld_8 > 0.0) || ld_16 < 0.0)
      { 
      li_108 = FALSE;
      
      //Start Alert code
       if(ld_16<0.0 && ld_8>0.0)
       {
         string base=Symbol()+", TF:" + TF2Str(Period());
         string Subj=base+", Trend Is Now Down, value: "+ld_16;
         string Msg=Subj+" @ "+TimeToStr(TimeLocal(),TIME_SECONDS);
         if(Bars>LastAlertBar)
         {
         LastAlertBar=Bars;
         DoAlerts(Msg,Subj);
         }
        }
       //End Alert code
      }
      if ((ld_16 > 0.0 && ld_8 < 0.0) || ld_16 > 0.0)
      {
         li_108 = TRUE;
        
        // Start Alert code
         if(ld_16>0.0 && ld_8<0.0)
        {
          base=Symbol()+", TF:"+TF2Str(Period());
          Subj=base+", Trend Is Now Up, value: "+ld_16;
          Msg=Subj+" @ "+TimeToStr(TimeLocal(),TIME_SECONDS);
          if(Bars>LastAlertBar)
         {
           LastAlertBar=Bars;
           DoAlerts(Msg,Subj);
         }
        }
       //End Alert code  
      }
      if (!li_108 ) {
         g_ibuf_88[li_104] = ld_16;
         g_ibuf_84[li_104] = 0.0;
         
         
      } else {
         g_ibuf_84[li_104] = ld_16;
         g_ibuf_88[li_104] = 0.0;
        
      }
   }
   return (0);
}

//Start Alert functions
void DoAlerts(string msgText,string eMailSub)
  {
   if(MsgAlerts) Alert(msgText);
   if(SoundAlerts) PlaySound(SoundAlertFile);
   if(eMailAlerts) SendMail(eMailSub,msgText);
  }
  
  string TF2Str(int period)
  {
      switch(period)
      {
         case PERIOD_M1: return("M1");
         case PERIOD_M5: return("M5");
         case PERIOD_M15: return("M15");
         case PERIOD_M30: return("M30");
         case PERIOD_H1: return("H1");
         case PERIOD_H4: return("H4");
         case PERIOD_D1: return("D1");
         case PERIOD_W1: return("W1");
         case PERIOD_MN1: return("MN1");
       }
       return(Period());
   }
   
 //End Alert functions