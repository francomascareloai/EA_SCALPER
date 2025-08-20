
#property copyright "MojoFX - Conversion only"
#property link      "http://groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 FireBrick
#property indicator_color4 CLR_NONE

extern bool On_Off = TRUE;
extern int period = 60;
extern double koef = 1.0;
extern int width = 5;

extern string pus1 = "";
extern string Y_L = "Lines on change Coral";
extern bool show_line_on_yellow = false;
extern int width_line = 2;
extern color col_Up_line = Blue;
extern color col_Dn_line = White;

extern string pus2 = "";
extern bool use_alert = false;
extern string al_mes = "Trend changed";
extern bool use_sound = false;
extern string so = "alert2";



static int prevtime;

double dg_ibuf_92[];
double dg_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double gda_108[];
double gda_112[];
double gda_116[];
double gda_120[];
double gda_124[];
double gda_128[];
double dg132;
double dg140;
double dg148;
double dg156;
double dg164;
double dg172;
double dg180;
double dg188;
double dg196;

int init() {
   IndicatorBuffers(4);
   SetIndexBuffer(0, dg_ibuf_92);
   SetIndexBuffer(1, dg_ibuf_96);
   SetIndexBuffer(2, g_ibuf_100);
   SetIndexBuffer(3, g_ibuf_104);
   SetIndexStyle(0, DRAW_LINE,EMPTY,width);
   SetIndexStyle(1, DRAW_LINE,EMPTY,width);
   SetIndexStyle(2, DRAW_LINE,EMPTY,width);
   IndicatorShortName("THV Coral (" + period + ") ");
   dg188 = koef * koef;
   dg196 = 0;
   dg196 = dg188 * koef;
   dg132 = -dg196;
   dg140 = 3.0 * (dg188 + dg196);
   dg148 = -3.0 * (2.0 * dg188 + koef + dg196);
   dg156 = 3.0 * koef + 1.0 + dg196 + 3.0 * dg188;
   dg164 = period;
   if (dg164 < 1.0) dg164 = 1;
   dg164 = (dg164 - 1.0) / 2.0 + 1.0;
   dg172 = 2 / (dg164 + 1.0);
   dg180 = 1 - dg172;
   return (0);
}

//////////////////////////////////////////////////////////
int deinit() {
for (int il_23 = Bars; il_23 >= 0; il_23--) 
    {
     if(ObjectFind("Yell_line"+il_23)!=-1)
      ObjectDelete("Yell_line"+il_23);
     
    }


return(0);
}
///////////////////////////////////////////////////////
int start() {
if (On_Off == FALSE) return (0);

   double dl0;
   double dl_8;
 
   int li_20 = IndicatorCounted();
   if (li_20 < 0) return (-1);
   if (li_20 > 0) li_20--;
   int li_16 = Bars - li_20 - 1;
   ArrayResize(gda_108, Bars + 1);
   ArrayResize(gda_112, Bars + 1);
   ArrayResize(gda_116, Bars + 1);
   ArrayResize(gda_120, Bars + 1);
   ArrayResize(gda_124, Bars + 1);
   ArrayResize(gda_128, Bars + 1);
   for (int il_23 = li_16; il_23 >= 0; il_23--) {
      gda_108[Bars - il_23] = dg172 * Close[il_23] + dg180 * (gda_108[Bars - il_23 - 1]);
      gda_112[Bars - il_23] = dg172 * (gda_108[Bars - il_23]) + dg180 * (gda_112[Bars - il_23 - 1]);
      gda_116[Bars - il_23] = dg172 * (gda_112[Bars - il_23]) + dg180 * (gda_116[Bars - il_23 - 1]);
      gda_120[Bars - il_23] = dg172 * (gda_116[Bars - il_23]) + dg180 * (gda_120[Bars - il_23 - 1]);
      gda_124[Bars - il_23] = dg172 * (gda_120[Bars - il_23]) + dg180 * (gda_124[Bars - il_23 - 1]);
      gda_128[Bars - il_23] = dg172 * (gda_124[Bars - il_23]) + dg180 * (gda_128[Bars - il_23 - 1]);
      g_ibuf_104[il_23] = dg132 * (gda_128[Bars - il_23]) + dg140 * (gda_124[Bars - il_23]) + dg148 * (gda_120[Bars - il_23]) + dg156 * (gda_116[Bars - il_23]);
      dl0 = g_ibuf_104[il_23];
      dl_8 = g_ibuf_104[il_23 + 1];
      dg_ibuf_92[il_23] = dl0;
      dg_ibuf_96[il_23] = dl0;
      g_ibuf_100[il_23] = dl0;
      if (dl_8 > dl0) dg_ibuf_96[il_23] = EMPTY_VALUE;
      else {
         if (dl_8 < dl0) g_ibuf_100[il_23] = EMPTY_VALUE;
         else dg_ibuf_92[il_23] = EMPTY_VALUE;
      }
      
     
   }
  
  
  if (Time[0] == prevtime) return(0);
   prevtime = Time[0];
  
   //del old yell line
    for (il_23 = Bars; il_23 >= 2; il_23--) 
    {
 
      if(ObjectFind("Yell_line"+il_23)!=-1)
      ObjectDelete("Yell_line"+il_23);
    }
  
  // yell_line
   if(show_line_on_yellow)
      {
      int r_li;
      int g_li;
      datetime r_can;
      datetime g_can;
      
    for (il_23 = 2; il_23 <= Bars-1; il_23++) 
    {
    if(r_li==1 && g_li==1)
    break;
    
      if(dg_ibuf_96[il_23]==EMPTY_VALUE && dg_ibuf_96[il_23+1]!=EMPTY_VALUE)
      {
      ObjectCreate("Yell_line"+il_23,OBJ_TREND,0,Time[il_23],dg_ibuf_92[il_23],Time[il_23-1],dg_ibuf_92[il_23]);
      ObjectSet("Yell_line"+il_23,OBJPROP_RAY,TRUE);
      ObjectSet("Yell_line"+il_23,OBJPROP_COLOR,col_Up_line);
      ObjectSet("Yell_line"+il_23,OBJPROP_WIDTH,width_line);
      r_li++;
     
      }
      
      if(g_ibuf_100[il_23]==EMPTY_VALUE && g_ibuf_100[il_23+1]!=EMPTY_VALUE)
      {
      ObjectCreate("Yell_line"+il_23,OBJ_TREND,0,Time[il_23],dg_ibuf_92[il_23],Time[il_23-1],dg_ibuf_92[il_23]);
      ObjectSet("Yell_line"+il_23,OBJPROP_RAY,TRUE);
      ObjectSet("Yell_line"+il_23,OBJPROP_COLOR,col_Dn_line);
      ObjectSet("Yell_line"+il_23,OBJPROP_WIDTH,width_line);
      g_li++;
     
      }
    }
   
  
      }
   
   if((dg_ibuf_96[1]==EMPTY_VALUE && dg_ibuf_96[2]!=EMPTY_VALUE) || (g_ibuf_100[1]==EMPTY_VALUE && g_ibuf_100[2]!=EMPTY_VALUE))
   {
   if(use_alert) Alert(Symbol()+" "+Period()+" "+al_mes);
   if(use_sound) PlaySound(so+".wav");
   }
  
     
  
   
   return (0);
}