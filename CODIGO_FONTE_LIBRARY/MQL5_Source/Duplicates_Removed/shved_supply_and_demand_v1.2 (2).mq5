//+------------------------------------------------------------------+
//|                             shved_supply_and_demand_v1.2.mq5     |
//|                      MQL5 version of Shved Supply and Demand     |
//|                                          Behzad.mvr@gmail.com    |
//+------------------------------------------------------------------+
// v1.2: History mode added. Set "historyMode" parameter to true then "double click" on any point in price chart to see Support and Resistance zones in that point. 

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

input int BackLimit=1000;  // Back Limit
input bool HistoryMode=false; // History Mode (with double click)

input string pus1="/////////////////////////////////////////////////";
input bool zone_show_weak=false;  // Show Weak Zones
input bool zone_show_untested = true;  // Show Untested Zones
input bool zone_show_turncoat = true; // Show Broken Zones
input double zone_fuzzfactor=0.75;  // Zone ATR Factor

input string pus2="/////////////////////////////////////////////////";
input double fractal_fast_factor = 3.0;   // Fractal Fast Factor
input double fractal_slow_factor = 6.0;   // Fractal slow Factor
input bool SetGlobals=false;  // Set terminal global variables

input string pus3="/////////////////////////////////////////////////";
input bool zone_solid=true; // Fill zone with color
input int zone_linewidth=1;   // Zone border width
input ENUM_LINE_STYLE zone_style=STYLE_SOLID;    // Zone border style
input bool zone_show_info=true;  // Show info labels
input int zone_label_shift=10;   // Info label shift
input bool zone_merge=true;   // Zone Merge
input bool zone_extend=true;  // Zone Extend

input string pus4="/////////////////////////////////////////////////";
input bool zone_show_alerts  = false;  // Trigger alert when entering a zone
input bool zone_alert_popups = true;   // Show alert window
input bool zone_alert_sounds = true;   // Play alert sound
input int zone_alert_waitseconds=300;  // Delay between alerts (seconds)

input string pus5="/////////////////////////////////////////////////";
input int Text_size=8;  // Text Size
input string Text_font = "Courier New";   // Text Font
input color Text_color = clrBlack;  // Text Color
input string sup_name = "Sup";   // Support Name
input string res_name = "Res";   // Resistance Name
input string test_name= "Retests";  // Test Name
input color color_support_weak     = clrDarkSlateGray;
input color color_support_untested = clrSeaGreen;
input color color_support_verified = clrGreen;
input color color_support_proven   = clrLimeGreen;
input color color_support_turncoat = clrOliveDrab;
input color color_resist_weak      = clrIndigo;
input color color_resist_untested  = clrOrchid;
input color color_resist_verified  = clrCrimson;
input color color_resist_proven    = clrRed;
input color color_resist_turncoat  = clrDarkOrange;


double FastDnPts[],FastUpPts[];
double SlowDnPts[],SlowUpPts[];

double zone_hi[1000],zone_lo[1000];
int    zone_start[1000],zone_hits[1000],zone_type[1000],zone_strength[1000],zone_count=0;
bool   zone_turn[1000];
double temp_hi[1000],temp_lo[1000];
int    temp_start[1000],temp_hits[1000],temp_strength[1000],temp_count=0;
bool   temp_turn[1000],temp_merge[1000];
int merge1[1000],merge2[1000],merge_count=0;

#define ZONE_SUPPORT 1
#define ZONE_RESIST  2

#define ZONE_WEAK      0
#define ZONE_TURNCOAT  1
#define ZONE_UNTESTED  2
#define ZONE_VERIFIED  3
#define ZONE_PROVEN    4

#define UP_POINT 1
#define DN_POINT -1

int time_offset=0;

double ner_lo_zone_P1[];
double ner_lo_zone_P2[];
double ner_hi_zone_P1[];
double ner_hi_zone_P2[];
int iATR_handle;
double ATR[];
int cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   iATR_handle=iATR(NULL,0,7);

   SetIndexBuffer(0,SlowDnPts,INDICATOR_DATA);
   SetIndexBuffer(1,SlowUpPts,INDICATOR_DATA);
   SetIndexBuffer(2,FastDnPts,INDICATOR_DATA);
   SetIndexBuffer(3,FastUpPts,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);

   SetIndexBuffer(4,ner_hi_zone_P1,INDICATOR_DATA);
   SetIndexBuffer(5,ner_hi_zone_P2,INDICATOR_DATA);
   SetIndexBuffer(6,ner_lo_zone_P1,INDICATOR_DATA);
   SetIndexBuffer(7,ner_lo_zone_P2,INDICATOR_DATA);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetString(4,PLOT_LABEL,"Resistant Zone High");
   PlotIndexSetString(5,PLOT_LABEL,"Resistant Zone Low");
   PlotIndexSetString(6,PLOT_LABEL,"Support Zone High");
   PlotIndexSetString(7,PLOT_LABEL,"Support Zone Low");

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   ArraySetAsSeries(SlowDnPts,true);
   ArraySetAsSeries(SlowUpPts,true);
   ArraySetAsSeries(FastDnPts,true);
   ArraySetAsSeries(FastUpPts,true);

   ArraySetAsSeries(ner_hi_zone_P1,true);
   ArraySetAsSeries(ner_hi_zone_P2,true);
   ArraySetAsSeries(ner_lo_zone_P1,true);
   ArraySetAsSeries(ner_lo_zone_P2,true);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteZones();
   DeleteGlobalVars();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   if(NewBar()==true)
     {
      int old_zone_count=zone_count;
      FastFractals();
      SlowFractals();
      DeleteZones();
      FindZones();
      DrawZones();
      if(zone_count<old_zone_count)
         DeleteOldGlobalVars(old_zone_count);
     }
   if(zone_show_info==true)
     {
      showLabels();
     }

   CheckAlerts();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAlerts()
  {
   datetime Time[];
   CopyTime(Symbol(),0,0,1,Time);
   ArraySetAsSeries(Time,true);
   static int lastalert=0;

   if(zone_show_alerts==false)
      return;

   if(Time[0]-lastalert>zone_alert_waitseconds)
      if(CheckEntryAlerts()==true)
         lastalert=int(Time[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckEntryAlerts()
  {
   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(Symbol(),0,0,1,Close);
// check for entries
   for(int i=0; i<zone_count; i++)
     {
      if(Close[0]>=zone_lo[i] && Close[0]<zone_hi[i])
        {
         if(zone_show_alerts==true)
           {
            if(zone_alert_popups==true)
              {
               if(zone_type[i]==ZONE_SUPPORT)
                  Alert(Symbol()+" "+TFTS(Period())+": Support Zone Entered.");
               else
                  Alert(Symbol()+" "+TFTS(Period())+": Resistance Zone Entered.");
              }
            if(zone_alert_sounds==true)
               PlaySound("alert.wav");
           }

         return(true);
        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteGlobalVars()
  {
   if(SetGlobals==false)
      return;

   GlobalVariableDel("SSSR_Count_"+Symbol()+TFTS(Period()));
   GlobalVariableDel("SSSR_Updated_"+Symbol()+TFTS(Period()));

   int old_count=zone_count;
   zone_count=0;
   DeleteOldGlobalVars(old_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOldGlobalVars(int old_count)
  {
   if(SetGlobals==false)
      return;

   for(int i=zone_count; i<old_count; i++)
     {
      GlobalVariableDel("SSSR_HI_"+Symbol()+TFTS(Period())+string(i));
      GlobalVariableDel("SSSR_LO_"+Symbol()+TFTS(Period())+string(i));
      GlobalVariableDel("SSSR_HITS_"+Symbol()+TFTS(Period())+string(i));
      GlobalVariableDel("SSSR_STRENGTH_"+Symbol()+TFTS(Period())+string(i));
      GlobalVariableDel("SSSR_AGE_"+Symbol()+TFTS(Period())+string(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindZones()
  {
   int i,j,shift,bustcount=0,testcount=0;
   double hival,loval;
   bool turned=false,hasturned=false;

   temp_count=0;
   merge_count=0;

// iterate through zones from oldest to youngest (ignore recent 5 bars),
// finding those that have survived through to the present___
   shift=MathMin(Bars(Symbol(),PERIOD_CURRENT)-1,BackLimit+cnt);
   double Close[],High[],Low[];
   ArraySetAsSeries(Close,true);
   CopyClose(Symbol(),0,0,shift+1,Close);
   ArraySetAsSeries(High,true);
   CopyHigh(Symbol(),0,0,shift+1,High);
   ArraySetAsSeries(Low,true);
   CopyLow(Symbol(),0,0,shift+1,Low);
   ArraySetAsSeries(ATR,true);
   CopyBuffer(iATR_handle,0,0,shift+1,ATR);
   for(int ii=shift; ii>cnt+5; ii--)
     {

      double atr= ATR[ii];
      double fu = atr/2 * zone_fuzzfactor;
      bool isWeak;
      bool touchOk= false;
      bool isBust = false;

      if(FastUpPts[ii]>0.001)
        {
         // a zigzag high point
         isWeak=true;
         if(SlowUpPts[ii]>0.001)
            isWeak=false;

         hival=High[ii];
         if(zone_extend==true)
            hival+=fu;

         loval=MathMax(MathMin(Close[ii],High[ii]-fu),High[ii]-fu*2);
         turned=false;
         hasturned=false;
         isBust=false;

         bustcount = 0;
         testcount = 0;

         for(i=ii-1; i>=cnt+0; i--)
           {
            if((turned==false && FastUpPts[i]>=loval && FastUpPts[i]<=hival) ||
               (turned==true && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
              {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk=true;
               for(j=i+1; j<i+11; j++)
                 {
                  if((turned==false && FastUpPts[j]>=loval && FastUpPts[j]<=hival) ||
                     (turned==true && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                    {
                     touchOk=false;
                     break;
                    }
                 }

               if(touchOk==true)
                 {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount=0;
                  testcount++;
                 }
              }

            if((turned==false && High[i]>hival) ||
               (turned==true && Low[i]<loval))
              {
               // this level has been busted at least once
               bustcount++;

               if(bustcount>1 || isWeak==true)
                 {
                  // busted twice or more
                  isBust=true;
                  break;
                 }

               if(turned == true)
                  turned = false;
               else
                  if(turned==false)
                     turned=true;

               hasturned=true;

               // forget previous hits
               testcount=0;
              }
           }

         if(isBust==false)
           {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = ii;
            temp_merge[temp_count] = false;

            if(testcount>3)
               temp_strength[temp_count]=ZONE_PROVEN;
            else
               if(testcount>0)
                  temp_strength[temp_count]=ZONE_VERIFIED;
               else
                  if(hasturned==true)
                     temp_strength[temp_count]=ZONE_TURNCOAT;
                  else
                     if(isWeak==false)
                        temp_strength[temp_count]=ZONE_UNTESTED;
                     else
                        temp_strength[temp_count]=ZONE_WEAK;

            temp_count++;
           }
        }
      else
         if(FastDnPts[ii]>0.001)
           {
            // a zigzag low point
            isWeak=true;
            if(SlowDnPts[ii]>0.001)
               isWeak=false;

            loval=Low[ii];
            if(zone_extend==true)
               loval-=fu;

            hival=MathMin(MathMax(Close[ii],Low[ii]+fu),Low[ii]+fu*2);
            turned=false;
            hasturned=false;

            bustcount = 0;
            testcount = 0;
            isBust=false;

            for(i=ii-1; i>=cnt+0; i--)
              {
               if((turned==true && FastUpPts[i]>=loval && FastUpPts[i]<=hival) ||
                  (turned==false && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
                 {
                  // Potential touch, just make sure its been 10+candles since the prev one
                  touchOk=true;
                  for(j=i+1; j<i+11; j++)
                    {
                     if((turned==true && FastUpPts[j]>=loval && FastUpPts[j]<=hival) ||
                        (turned==false && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                       {
                        touchOk=false;
                        break;
                       }
                    }

                  if(touchOk==true)
                    {
                     // we have a touch_  If its been busted once, remove bustcount
                     // as we know this level is still valid & has just switched sides
                     bustcount=0;
                     testcount++;
                    }
                 }

               if((turned==true && High[i]>hival) ||
                  (turned==false && Low[i]<loval))
                 {
                  // this level has been busted at least once
                  bustcount++;

                  if(bustcount>1 || isWeak==true)
                    {
                     // busted twice or more
                     isBust=true;
                     break;
                    }

                  if(turned == true)
                     turned = false;
                  else
                     if(turned==false)
                        turned=true;

                  hasturned=true;

                  // forget previous hits
                  testcount=0;
                 }
              }

            if(isBust==false)
              {
               // level is still valid, add to our list
               temp_hi[temp_count] = hival;
               temp_lo[temp_count] = loval;
               temp_turn[temp_count] = hasturned;
               temp_hits[temp_count] = testcount;
               temp_start[temp_count] = ii;
               temp_merge[temp_count] = false;

               if(testcount>3)
                  temp_strength[temp_count]=ZONE_PROVEN;
               else
                  if(testcount>0)
                     temp_strength[temp_count]=ZONE_VERIFIED;
                  else
                     if(hasturned==true)
                        temp_strength[temp_count]=ZONE_TURNCOAT;
                     else
                        if(isWeak==false)
                           temp_strength[temp_count]=ZONE_UNTESTED;
                        else
                           temp_strength[temp_count]=ZONE_WEAK;

               temp_count++;
              }
           }
     }

// look for overlapping zones___
   if(zone_merge==true)
     {
      merge_count=1;
      int iterations=0;
      while(merge_count>0 && iterations<3)
        {
         merge_count=0;
         iterations++;

         for(i=0; i<temp_count; i++)
            temp_merge[i]=false;

         for(i=0; i<temp_count-1; i++)
           {
            if(temp_hits[i]==-1 || temp_merge[i]==true)
               continue;

            for(j=i+1; j<temp_count; j++)
              {
               if(temp_hits[j]==-1 || temp_merge[j]==true)
                  continue;

               if((temp_hi[i]>=temp_lo[j] && temp_hi[i]<=temp_hi[j]) ||
                  (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                  (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                  (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i]))
                 {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
                 }
              }
           }

         // ___ and merge them ___
         for(i=0; i<merge_count; i++)
           {
            int target = merge1[i];
            int source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target]=MathMax(temp_strength[target],temp_strength[source]);
            if(temp_hits[target]>3)
               temp_strength[target]=ZONE_PROVEN;

            if(temp_hits[target]==0 && temp_turn[target]==false)
              {
               temp_hits[target]=1;
               if(temp_strength[target]<ZONE_VERIFIED)
                  temp_strength[target]=ZONE_VERIFIED;
              }

            if(temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;
            if(temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source]=-1;
           }
        }
     }

// copy the remaining list into our official zones arrays

   zone_count=0;
   for(i=0; i<temp_count; i++)
     {
      if(temp_hits[i]>=0 && zone_count<1000)
        {
         zone_hi[zone_count]       = temp_hi[i];
         zone_lo[zone_count]       = temp_lo[i];
         zone_hits[zone_count]     = temp_hits[i];
         zone_turn[zone_count]     = temp_turn[i];
         zone_start[zone_count]    = temp_start[i];
         zone_strength[zone_count] = temp_strength[i];


         if(zone_hi[zone_count]<Close[4])
            zone_type[zone_count]=ZONE_SUPPORT;
         else
            if(zone_lo[zone_count]>Close[4])
               zone_type[zone_count]=ZONE_RESIST;
            else
              {
               int  sh=MathMin(Bars(Symbol(),PERIOD_CURRENT)-1,BackLimit+cnt);
               for(j=5; j<sh; j++)
                 {
                  if(Close[j]<zone_lo[zone_count])
                    {
                     zone_type[zone_count]=ZONE_RESIST;
                     break;
                    }
                  else
                     if(Close[j]>zone_hi[zone_count])
                       {
                        zone_type[zone_count]=ZONE_SUPPORT;
                        break;
                       }
                 }

               if(j==sh)
                  zone_type[zone_count]=ZONE_SUPPORT;
              }

         zone_count++;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawZones()
  {
   double lower_nerest_zone_P1=0;
   double lower_nerest_zone_P2=0;
   double higher_nerest_zone_P1=99999;
   double higher_nerest_zone_P2=99999;

   if(SetGlobals==true)
     {
      GlobalVariableSet("SSSR_Count_"+Symbol()+TFTS(Period()),zone_count);
      GlobalVariableSet("SSSR_Updated_"+Symbol()+TFTS(Period()),TimeCurrent());
     }

   for(int i=0; i<zone_count; i++)
     {
      if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
         continue;

      if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
         continue;

      if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
         continue;

      //name sup
      string s;
      if(zone_type[i]==ZONE_SUPPORT)
         s="SSSR#S"+string(i)+" Strength=";
      else
         //name res
         s="SSSR#R"+string(i)+" Strength=";

      if(zone_strength[i]==ZONE_PROVEN)
         s=s+"Proven, Test Count="+string(zone_hits[i]);
      else
         if(zone_strength[i]==ZONE_VERIFIED)
            s=s+"Verified, Test Count="+string(zone_hits[i]);
         else
            if(zone_strength[i]==ZONE_UNTESTED)
               s=s+"Untested";
            else
               if(zone_strength[i]==ZONE_TURNCOAT)
                  s=s+"Turncoat";
               else
                  s=s+"Weak";
      datetime Time[];
      CopyTime(Symbol(),0,0,zone_start[i]+1,Time);
      ArraySetAsSeries(Time,true);
      ObjectCreate(0,s,OBJ_RECTANGLE,0,0,0,0,0);
      ObjectSetInteger(0,s,OBJPROP_TIME,0,Time[zone_start[i]]);
      ObjectSetInteger(0,s,OBJPROP_TIME,1,Time[cnt+0]);
      ObjectSetDouble(0,s,OBJPROP_PRICE,0,zone_hi[i]);
      ObjectSetDouble(0,s,OBJPROP_PRICE,1,zone_lo[i]);
      ObjectSetInteger(0,s,OBJPROP_BACK,true);
      ObjectSetInteger(0,s,OBJPROP_FILL,zone_solid);
      ObjectSetInteger(0,s,OBJPROP_WIDTH,zone_linewidth);
      ObjectSetInteger(0,s,OBJPROP_STYLE,zone_style);

      if(zone_type[i]==ZONE_SUPPORT)
        {
         // support zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSetInteger(0,s,OBJPROP_COLOR,color_support_turncoat);
         else
            if(zone_strength[i]==ZONE_PROVEN)
               ObjectSetInteger(0,s,OBJPROP_COLOR,color_support_proven);
            else
               if(zone_strength[i]==ZONE_VERIFIED)
                  ObjectSetInteger(0,s,OBJPROP_COLOR,color_support_verified);
               else
                  if(zone_strength[i]==ZONE_UNTESTED)
                     ObjectSetInteger(0,s,OBJPROP_COLOR,color_support_untested);
                  else
                     ObjectSetInteger(0,s,OBJPROP_COLOR,color_support_weak);
        }
      else
        {
         // resistance zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSetInteger(0,s,OBJPROP_COLOR,color_resist_turncoat);
         else
            if(zone_strength[i]==ZONE_PROVEN)
               ObjectSetInteger(0,s,OBJPROP_COLOR,color_resist_proven);
            else
               if(zone_strength[i]==ZONE_VERIFIED)
                  ObjectSetInteger(0,s,OBJPROP_COLOR,color_resist_verified);
               else
                  if(zone_strength[i]==ZONE_UNTESTED)
                     ObjectSetInteger(0,s,OBJPROP_COLOR,color_resist_untested);
                  else
                     ObjectSetInteger(0,s,OBJPROP_COLOR,color_resist_weak);
        }

      if(SetGlobals==true)
        {
         GlobalVariableSet("SSSR_HI_"+Symbol()+TFTS(Period())+string(i),zone_hi[i]);
         GlobalVariableSet("SSSR_LO_"+Symbol()+TFTS(Period())+string(i),zone_lo[i]);
         GlobalVariableSet("SSSR_HITS_"+Symbol()+TFTS(Period())+string(i),zone_hits[i]);
         GlobalVariableSet("SSSR_STRENGTH_"+Symbol()+TFTS(Period())+string(i),zone_strength[i]);
         GlobalVariableSet("SSSR_AGE_"+Symbol()+TFTS(Period())+string(i),zone_start[i]);
        }

      //nearest zones
      double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

      if(zone_lo[i]>lower_nerest_zone_P2 && price>zone_lo[i])
        {
         lower_nerest_zone_P1=zone_hi[i];
         lower_nerest_zone_P2=zone_lo[i];
        }
      if(zone_hi[i]<higher_nerest_zone_P1 && price<zone_hi[i])
        {
         higher_nerest_zone_P1=zone_hi[i];
         higher_nerest_zone_P2=zone_lo[i];
        }
     }

   ner_hi_zone_P1[0]=higher_nerest_zone_P1;
   ner_hi_zone_P2[0]=higher_nerest_zone_P2;
   ner_lo_zone_P1[0]=lower_nerest_zone_P1;
   ner_lo_zone_P2[0]=lower_nerest_zone_P2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fractal(int M,int P,int shift)
  {
   if(Period()>P)
      P=Period();

   P=int(P/Period()*2+MathCeil(P/Period()/2));

   if(shift<P)
      return(false);

   if(shift>Bars(Symbol(),PERIOD_CURRENT)-P-1)
      return(false);
   double High[],Low[];
   ArraySetAsSeries(High,true);
   CopyHigh(Symbol(),0,0,shift+P+1,High);
   ArraySetAsSeries(Low,true);
   CopyLow(Symbol(),0,0,shift+P+1,Low);
   for(int i=1; i<=P; i++)
     {
      if(M==UP_POINT)
        {
         if(High[shift+i]>High[shift])
            return(false);
         if(High[shift-i]>=High[shift])
            return(false);
        }
      if(M==DN_POINT)
        {
         if(Low[shift+i]<Low[shift])
            return(false);
         if(Low[shift-i]<=Low[shift])
            return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime LastTime=0;
   if(iTime(Symbol(),Period(),0)+time_offset!=LastTime)
     {
      LastTime=iTime(Symbol(),Period(),0)+time_offset;
      return (true);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteZones()
  {
   int len=5;
   int i=0;
   while(i<ObjectsTotal(0,0,-1))
     {
      string objName=ObjectName(0,i,0,-1);
      if(StringSubstr(objName,0,len)!="SSSR#")
        {
         i++;
         continue;
        }
      ObjectDelete(0,objName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFTS(int tf) //--- Timeframe to string
  {
   string tfs;

   switch(tf)
     {
      case PERIOD_M1:
         tfs="M1";
         break;
      case PERIOD_M2:
         tfs="M2";
         break;
      case PERIOD_M3:
         tfs="M3";
         break;
      case PERIOD_M4:
         tfs="M4";
         break;
      case PERIOD_M5:
         tfs="M5";
         break;
      case PERIOD_M6:
         tfs="M6";
         break;
      case PERIOD_M10:
         tfs="M10";
         break;
      case PERIOD_M12:
         tfs="M12";
         break;
      case PERIOD_M15:
         tfs="M15";
         break;
      case PERIOD_M20:
         tfs="M20";
         break;
      case PERIOD_M30:
         tfs="M30";
         break;
      case PERIOD_H1:
         tfs="H1";
         break;
      case PERIOD_H2:
         tfs="H2";
         break;
      case PERIOD_H3:
         tfs="H3";
         break;
      case PERIOD_H4:
         tfs="H4";
         break;
      case PERIOD_H6:
         tfs="H6";
         break;
      case PERIOD_H8:
         tfs="H8";
         break;
      case PERIOD_H12:
         tfs="H12";
         break;
      case PERIOD_D1:
         tfs="D1";
         break;
      case PERIOD_W1:
         tfs="W1";
         break;
      case PERIOD_MN1:
         tfs="MN1";
         break;
     }
   return(tfs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FastFractals()
  {
//--- FastFractals
   int shift;
   int limit=MathMin(Bars(Symbol(),PERIOD_CURRENT)-1,BackLimit+cnt);
   int P1=int(Period()*fractal_fast_factor);
   double High[],Low[];
   ArraySetAsSeries(High,true);
   CopyHigh(Symbol(),0,0,limit+1,High);
   ArraySetAsSeries(Low,true);
   CopyLow(Symbol(),0,0,limit+1,Low);
   FastUpPts[0] = 0.0;
   FastUpPts[1] = 0.0;
   FastDnPts[0] = 0.0;
   FastDnPts[1] = 0.0;

   for(shift=limit; shift>cnt+1; shift--)
     {
      if(Fractal(UP_POINT,P1,shift)==true)
         FastUpPts[shift]=High[shift];
      else
         FastUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P1,shift)==true)
         FastDnPts[shift]=Low[shift];
      else
         FastDnPts[shift]=0.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SlowFractals()
  {
//--- SlowFractals
   int shift;
   int limit=MathMin(Bars(Symbol(),PERIOD_CURRENT)-1,BackLimit+cnt);
   int P2=int(Period()*fractal_slow_factor);
   double High[],Low[];
   ArraySetAsSeries(High,true);
   CopyHigh(Symbol(),0,0,limit+1,High);
   ArraySetAsSeries(Low,true);
   CopyLow(Symbol(),0,0,limit+1,Low);
   SlowUpPts[0] = 0.0;
   SlowUpPts[1] = 0.0;
   SlowDnPts[0] = 0.0;
   SlowDnPts[1] = 0.0;

   for(shift=limit; shift>cnt+1; shift--)
     {
      if(Fractal(UP_POINT,P2,shift)==true)
         SlowUpPts[shift]=High[shift];
      else
         SlowUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P2,shift)==true)
         SlowDnPts[shift]=Low[shift];
      else
         SlowDnPts[shift]=0.0;

      ner_hi_zone_P1[shift]=0;
      ner_hi_zone_P2[shift]=0;
      ner_lo_zone_P1[shift]=0;
      ner_lo_zone_P2[shift]=0;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(HistoryMode==true)
     {
      static ulong clickTimeMemory;
      if(id == CHARTEVENT_CLICK)
        {
         ulong clickTime = GetTickCount();
         if(clickTime < clickTimeMemory + 500)
           {
            clickTimeMemory = 0;
            int x=(int)lparam;
            int y=(int)dparam;
            datetime dt=0;
            double price=0;
            int window=0;
            if(ChartXYToTimePrice(0,x,y,window,dt,price))
              {
               cnt=iBarShift(_Symbol,_Period,dt,false);
               int old_zone_count=zone_count;
               FastFractals();
               SlowFractals();
               DeleteZones();
               FindZones();
               DrawZones();
               showLabels();
               ChartRedraw(0);
              }
           }
         else
            clickTimeMemory = clickTime;
        }
      else
         if(id == CHARTEVENT_MOUSE_MOVE) {}
         else
            if(id == CHARTEVENT_KEYDOWN)
              {
               return;
              }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void showLabels()
  {
   datetime Time[];
   CopyTime(Symbol(),0,cnt,1,Time);
   ArraySetAsSeries(Time,true);
   for(int i=0; i<zone_count; i++)
     {
      string lbl;
      if(zone_strength[i]==ZONE_PROVEN)
         lbl="Proven";
      else
         if(zone_strength[i]==ZONE_VERIFIED)
            lbl="Verified";
         else
            if(zone_strength[i]==ZONE_UNTESTED)
               lbl="Untested";
            else
               if(zone_strength[i]==ZONE_TURNCOAT)
                  lbl="Turncoat";
               else
                  lbl="Weak";

      if(zone_type[i]==ZONE_SUPPORT)
         lbl=lbl+" "+sup_name;
      else
         lbl=lbl+" "+res_name;

      if(zone_hits[i]>0 && zone_strength[i]>ZONE_UNTESTED)
        {
         if(zone_hits[i]==1)
            lbl=lbl+", "+test_name+"="+string(zone_hits[i]);
         else
            lbl=lbl+", "+test_name+"="+string(zone_hits[i]);
        }

      int adjust_hpos;
      long wbpc=ChartGetInteger(0,CHART_VISIBLE_BARS);
      int k=PeriodSeconds()/10+(StringLen(lbl));

      if(wbpc<80)
         adjust_hpos=int(Time[0])+k*1;
      else
         if(wbpc<125)
            adjust_hpos=int(Time[0])+k*2;
         else
            if(wbpc<250)
               adjust_hpos=int(Time[0])+k*4;
            else
               if(wbpc<480)
                  adjust_hpos=int(Time[0])+k*8;
               else
                  if(wbpc<950)
                     adjust_hpos=int(Time[0])+k*16;
                  else
                     adjust_hpos=int(Time[0])+k*32;

      int shift=k*zone_label_shift;
      double vpos=zone_hi[i]-(zone_hi[i]-zone_lo[i])/3;

      if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
         continue;
      if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
         continue;
      if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
         continue;

      string s="SSSR#"+string(i)+"LBL";
      ObjectCreate(0,s,OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,s,OBJPROP_TIME,adjust_hpos+shift);
      ObjectSetDouble(0,s,OBJPROP_PRICE,vpos);
      ObjectSetString(0,s,OBJPROP_TEXT,lbl);
      ObjectSetString(0,s,OBJPROP_FONT,Text_font);
      ObjectSetInteger(0,s,OBJPROP_FONTSIZE,Text_size);
      ObjectSetInteger(0,s,OBJPROP_COLOR,Text_color);
     }
  }
//+------------------------------------------------------------------+
