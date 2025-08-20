//+------------------------------------------------------------------+
//|                                               ClearMethod-SD.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "ay.pop3@gmail.com"
#property link      "ay.pop3@gmail.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 MediumSeaGreen
#property indicator_color2 Maroon
#property indicator_color3 MediumSeaGreen
#property indicator_color4 Maroon

#property indicator_width3 2
#property indicator_width4 2

extern int   Lookback    = 20000;
extern bool  ShowCMLine  = false;
extern bool  ShowCMDot   = false;
extern bool  ShowSbDDbS = true;
extern bool  demtosupclr = true;
extern bool  suptodemclr = true;
extern color SupplyClr   = clrLightGray;
extern color DemandClr   = clrLightGray;
extern color DemToSupClr = clrPowderBlue;
extern color SupToDemClr = clrPowderBlue;


//--- buffers
double BuffUp[];
double BuffDn[];
double BuffDotUp[];
double BuffDotDn[];

bool UpSwing = true;
double HighestLow, LowestHigh;

string ObjPref = "CSD.";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
   SetIndexBuffer(0, BuffUp);   
   SetIndexEmptyValue(0, 0.0);
   SetIndexLabel(0, "UpLine");
   if (ShowCMLine) SetIndexStyle(0, DRAW_LINE);
   else SetIndexStyle(0, DRAW_NONE);   

   SetIndexBuffer(1, BuffDn);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel(1, "DnLine");
   if (ShowCMLine) SetIndexStyle(1, DRAW_LINE);
   else SetIndexStyle(1, DRAW_NONE);    
   
   SetIndexBuffer(2, BuffDotUp);
   SetIndexEmptyValue(2, 0.0);
   SetIndexLabel(2, "UpDot");
   if (ShowCMDot)
   {
      SetIndexStyle(2, DRAW_ARROW);
      SetIndexArrow(2, 158);
   }
   else SetIndexStyle(2, DRAW_NONE); 
   
   SetIndexBuffer(3, BuffDotDn);
   SetIndexEmptyValue(3, 0.0);
   SetIndexLabel(3, "DnDot");
   if (ShowCMDot)
   {
      SetIndexStyle(3, DRAW_ARROW);
      SetIndexArrow(3, 158);
   }
   else SetIndexStyle(3, DRAW_NONE); 
           
   //force load data
   iBars(NULL, 0);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
   delObjs();
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    limit, i;
   int    counted_bars=IndicatorCounted();

   //--- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit= Bars-counted_bars-1;
   
   BuffUp[0] = 0.0;      
   BuffDn[0] = 0.0; 
   BuffDotDn[0] = 0.0;
   BuffDotUp[0] = 0.0;
   
   for(i=limit; i>=1; i--)
   {
      BuffUp[i] = 0.0;      
      BuffDn[i] = 0.0; 
      BuffDotDn[i] = 0.0;
      BuffDotUp[i] = 0.0;
   
      if (i == Bars-1)
      {
         HighestLow = Low[i];
         LowestHigh = High[i];
         //Comment(DoubleToStr(HighestLow, Digits), " ", DoubleToStr(LowestHigh, Digits));
         continue;
      }
      if (UpSwing)
      {
         HighestLow = MathMax(Low[i], HighestLow);
         //LowestHigh = MathMin(High[i], LowestHigh);
         if (High[i] < HighestLow)
         {
            UpSwing = false;
            LowestHigh = High[i];
         }         
      }
      else
      {
         //HighestLow = MathMax(Low[i], HighestLow);
         LowestHigh = MathMin(High[i], LowestHigh);
         if (Low[i] > LowestHigh)
         {
            UpSwing = true;
            HighestLow = Low[i];
         }   
      }
   
      if (UpSwing)
      {      
         //if ( BuffUp[i+2] != 0.0 &&  BuffUp[i+1] < HighestLow ) BuffUp[i+1] = 0.0;
         BuffUp[i] = HighestLow;      
         BuffDn[i] = 0.0;      
         if (Low[i] > LowestHigh && BuffDn[i+1]!= 0.0)
         {
            BuffDotDn[i+1] = LowestHigh;
            BuffDotUp[i] = HighestLow;
         }
      }
      else
      {
         BuffUp[i] = 0.0;      
         BuffDn[i] = LowestHigh;  
         if (High[i] < HighestLow && BuffUp[i+1] !=0)
         {
            BuffDotDn[i] = LowestHigh;
            BuffDotUp[i+1] = HighestLow;
         }                  
      }
   
   }

   if (newBar()) getSD();

   return(0);
}
/**
 *
 */
void getSD()
{
   int i, j, k, l, m, limit = MathMin(Bars, Lookback)
       , ihh, ihl, iesw, isw //highest high bar, highest low bar, end bar of swing, index swing 
       , ill, ilh //lowest low bar, lowest high bar
       , upswgcnt, dnswgcnt  //upswing count, dnswing count
       , supcnt, demcnt  //unbroken upswing count, unbroken dnswing count
       //, suptestcnt, demtestcnt
       , suptodemcnt, demtosupcnt
       ;
   double hl, hh  //highest low, highest high
         ,lh, ll  //lowest hight, lowest low
         ,upswg[][4], dnswg[][4]
         ,sup[][4], dem[][4]   //unbroken upswing array, unbroken dnswing array
         //,suptest[][4], demtest[][4]     
         ,suptodem[][4], demtosup[][4]     
         ;
   
   bool broken, testprev; //is supply/demand broken, the swing is testing previous swing      
   
   delObjs();
   
   //-----------------------------------------------------------------
   //--populate upswing      
   //-----------------------------------------------------------------
   for (i=limit-1; i>0; i--)
   {
      if(BuffDotUp[i] !=0.0 && BuffDotDn[i+1] != 0.0) 
      {
         for (j=i-1; j>0; j--)
         {
            if(BuffDotUp[j] != 0.0 && BuffDotDn[j-1] != 0.0)
            {
               ihh = iHighest(NULL, 0, MODE_HIGH, (i-j)+1, j);
               ihl = iHighest(NULL, 0, MODE_LOW, (i-j)+1, j);
               hh = High[ihh];
               hl = Low [ihl];
               //--hh can be on BuffDotDn
               //hh = MathMax(hh, High[i+1]);
               if (High[i+1]>hh) { hh=High[i+1]; ihh=i+1; }
               
               upswgcnt++;
               ArrayResize(upswg,upswgcnt);
               upswg[upswgcnt-1][0] = hh;
               upswg[upswgcnt-1][1] = hl; 
               upswg[upswgcnt-1][2] = ihh;              
               upswg[upswgcnt-1][3] = j-1; //--end bar of swing
               i = j-1;
               break;
             }
          }            
      }
   }
   //-----------------------------------------------------------------
   //--populate down swing
   //-----------------------------------------------------------------
   for (i=limit-1; i>0; i--)
   {
      if(BuffDotDn[i] != 0.0 && BuffDotUp[i+1] != 0.0)
      {
         for (j=i-1; j>0; j--)
         {
            if(BuffDotDn[j] != 0.0 && BuffDotUp[j-1] != 0.0)
            {
               ill = iLowest(NULL, 0, MODE_LOW, (i-j)+1, j);
               ilh = iLowest(NULL, 0, MODE_HIGH, (i-j)+1, j);
               ll = Low[ill];
               lh = High[ilh];
               //--ll can be on BuffDotUp
               //ll = MathMin(ll, Low[i+1]);
               if (Low[i+1]<ll) { ll=Low[i+1]; ill=i+1; }
               
               dnswgcnt++;
               ArrayResize(dnswg,dnswgcnt);
               dnswg[dnswgcnt-1][0] = ll;
               dnswg[dnswgcnt-1][1] = lh; 
               dnswg[dnswgcnt-1][2] = ill;              
               dnswg[dnswgcnt-1][3] = j-1; //--end bar of swing
               i = j-1;
               break;
             }
          }            
      }
   }     
   //-----------------------------------------------------------------
   //--identify supply
   //-----------------------------------------------------------------
   for (i=0; i<upswgcnt; i++)
   {
      hh = upswg[i][0]; hl = upswg[i][1]; ihh = upswg[i][2]; iesw = upswg[i][3];
      broken = false;
      for (j=iesw-1; j>0; j--)
      {
         if (High[j]>hh) { broken = true; break; }
         //if (Close[j]>hh) { broken = true; break; }
      }
      
      if (!broken)
      {
         testprev = false;
         //--check to the left if this upswg is a test of prev upswg
         for (k=supcnt-1; k>=0; k--)
         {
            testprev = (hh <= sup[k][0] && hh >= sup[k][1]);
            if (testprev) break;            
         }
         if (!testprev)
         {
            supcnt++;
            ArrayResize(sup,supcnt);
            sup[supcnt-1][0] = hh;
            sup[supcnt-1][1] = hl;  
            sup[supcnt-1][2] = ihh; 
            sup[supcnt-1][3] = i;   //index upswg
            createRect("sup."+TimeToStr(Time[ihh]), hh, Time[ihh], hl, Time[0]+(5*Period()*60), SupplyClr);                                                     
         }         
      }
      else
      {
         broken = false; //--initialize this suptodem is unbroken         
         for (k=j-1; k>0; k--)
         {
            if (Low[k]<hl) { broken= true; break;}  
            //if (Close[k]<hl) { broken= true; break;} 
         }   
         if (!broken)
         {

            suptodemcnt++;
            ArrayResize(suptodem, suptodemcnt);
            suptodem[suptodemcnt-1][0] = hh;
            suptodem[suptodemcnt-1][1] = hl;  
            suptodem[suptodemcnt-1][2] = ihh;  
            suptodem[suptodemcnt-1][3] = i; //index dnswg 
            
         }         
      }
   }
   //-----------------------------------------------------------------
   //--identify demand
   //-----------------------------------------------------------------
   for (i=0; i<dnswgcnt; i++)
   {
      ll = dnswg[i][0]; lh = dnswg[i][1]; ill = dnswg[i][2]; iesw = dnswg[i][3];
      
      broken = false;      
      for (j=iesw-1; j>0; j--)
      {
         if (Low[j]<ll) { broken = true; break; }
         //if (Close[j]<ll) { broken = true; break; }
      }
      
      if (!broken)
      {
         testprev = false;
         //--check to the left if this dnswg is a test of prev supply
         for (k=demcnt-1; k>=0; k--)
         {
            testprev = (ll >= dem[k][0] && ll <= dem[k][1]);
            if (testprev) break;            
         }
         if (!testprev)
         {
            demcnt++;
            ArrayResize(dem,demcnt);
            dem[demcnt-1][0] = ll;
            dem[demcnt-1][1] = lh;  
            dem[demcnt-1][2] = ill;
            dem[demcnt-1][3] = i;  //index dnswg
            createRect("dem."+TimeToStr(Time[ill]), ll, Time[ill], lh, Time[0]+(5*Period()*60), DemandClr);                                                     
         }
         /*else
         {
            demtestcnt++;
            ArrayResize(demtest,demtestcnt);
            demtest[demtestcnt-1][0] = ll;
            demtest[demtestcnt-1][1] = lh; 
            demtest[demtestcnt-1][2] = ill;
            demtest[demtestcnt-1][3] = i; //index dnswg
         }*/     
      }
      else //-- check if this broken demand is unbroken supply
      {         
         broken = false; //--initialize this demtosup as unbroken
         //
         for (k=j-1; k>0; k--)
         {
            if (High[k]>lh) { broken=true; break;}   
            //if (Close[k]>lh) { broken= true; break;} 
         }   
         if (!broken)
         {
            demtosupcnt++;
            ArrayResize(demtosup, demtosupcnt);
            demtosup[demtosupcnt-1][0] = ll;
            demtosup[demtosupcnt-1][1] = lh;  
            demtosup[demtosupcnt-1][2] = ill;  
            demtosup[demtosupcnt-1][3] = i; //index dnswg             
         }
      }      
   }   
   
   if (!ShowSbDDbS) return;
   //-----------------------------------------------------------------
   //--supply become demand
   //-----------------------------------------------------------------
   for (i=suptodemcnt-1; i>=0; i--)
   {
      hh = suptodem[i][0];
      hl = suptodem[i][1];
      ihh = suptodem[i][2];  
      
      //--check this suptodem is test to prev supply
      testprev = false;
      for(j=supcnt-1; j>=0; j--)
      {
         testprev = (hh <= sup[j][0] && hh >= sup[j][1]);
         if (testprev) break;
      }
      if (testprev) continue;   
      
      //--check this suptodem is a test to prev suptodem
      testprev = false;
      for (j=i-1; j>=0; j--)
      {
         testprev = (hh <= suptodem[j][0] && hh >= suptodem[j][1]);
         if (testprev) break;
      }
      if (testprev) continue;
           
      //--check if there is new demand inside suptodem; dem[j][0] = dem ll; dem[j][1] = dem hl
      bool newdem = false;
      for(j=demcnt-1; j>=0; j--)
      {
         newdem = (    (dem[j][0] >= hl && dem[j][0] <= hh) //dem ll between sup hh and sup hl
                    || (dem[j][1] >= hl && dem[j][1] <= hh) //dem lh between sup hh and sup hl
                  );
         //if (newdem) break;
         ill = dem[j][2];
         if (newdem) ObjectDelete(ObjPref+"dem."+TimeToStr(Time[ill]));
      }
      
      
      //if (newdem)
      //{
         createRect("sd."+TimeToStr(Time[ihh]), hh, Time[ihh], hl, Time[0]+(5*Period()*60), SupToDemClr);
         ObjectSet(ObjPref+"sd."+TimeToStr(Time[ihh]), OBJPROP_BACK, true);
         
      //}      
      
   }   
   //-----------------------------------------------------------------
   //--demand become supply
   //-----------------------------------------------------------------
   for (i=demtosupcnt-1; i>=0; i--)
   {
      ll  = demtosup[i][0];
      lh  = demtosup[i][1];
      ill = demtosup[i][2];  
      isw = demtosup[i][3]; //index dnswg
      
      //--check this demtusup is test to prev demand
      testprev = false;
      for(j=demcnt-1; j>=0; j--)
      {
         testprev = (ll >= dem[j][0] && ll <= dem[j][1]);
         if (testprev) break;
      }
      if (testprev) continue;      
      
      //--check this demtusup is in a test to prev demtusup
      testprev = false;
      for (j=i-1; j>=0; j--)
      {
         testprev = (ll >= demtosup[j][0] && ll <= demtosup[j][1]);
         if (testprev) break;
      }
      if (testprev) continue;
                     
      //--check there is new supply inside demtosup; sup[j][0] = sup hh; sup[j][1] = sup lh
      bool newsup = false;
      for(j=supcnt-1; j>=0; j--)
      {
         newsup = (    (sup[j][0] <= lh && sup[j][0] >= ll)
                    || (sup[j][1] <= lh && sup[j][1] >= ll) 
                  );
         //if (newsup) break;
         //sup[supcnt-1][2] = ihh; 
         ihh = sup[j][2];
         if (newsup) ObjectDelete(ObjPref+"sup."+TimeToStr(Time[ihh]));
      }
      
      
      //if (!newsup)
      //{
         createRect("ds."+TimeToStr(Time[ill]), ll, Time[ill], lh, Time[0]+(5*Period()*60), DemToSupClr);
         ObjectSet(ObjPref+"ds."+TimeToStr(Time[ill]), OBJPROP_BACK, true);
         
      //}      
      
   }
   
}
/**
 *
 */
bool newBar()
{
   static datetime lasttime;
   datetime currtime = Time[0];
   static int lastnumbars;
   int currnumbars = Bars;
   
   if (lasttime != currtime)
   {
      lasttime = currtime;
      return(true);
   }
   if (lastnumbars != currnumbars)
   {
      lastnumbars = currnumbars;
      return(true);
   }   
   return(false);
}

//+------------------------------------------------------------------+
//| createRect                                                       |
//+------------------------------------------------------------------+   
void createRect(string objname, double p1, datetime t1, double p2, 
   datetime t2, color clr, bool back=true,  int winid=0)
{

   objname = ObjPref + objname;
   if(ObjectFind(objname) != winid)    
      ObjectCreate(objname, OBJ_RECTANGLE, winid, 0, 0, 0, 0);
   
   ObjectSet(objname, OBJPROP_PRICE1, p1);
   ObjectSet(objname, OBJPROP_TIME1,  t1);
   ObjectSet(objname, OBJPROP_PRICE2, p2);
   ObjectSet(objname, OBJPROP_TIME2,  t2);
   ObjectSet(objname, OBJPROP_COLOR,  clr);
   ObjectSet(objname, OBJPROP_BACK,   back);
} 
//+------------------------------------------------------------------+
//| delObjs function                                                 |
//+------------------------------------------------------------------+
void delObjs(string s="")
{
   int objs = ObjectsTotal();
   if (StringLen(s) == 0) s = ObjPref;
   
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringSubstr(name,0,StringLen(s)) == s)       
         ObjectDelete(name); 
   }   
} 

