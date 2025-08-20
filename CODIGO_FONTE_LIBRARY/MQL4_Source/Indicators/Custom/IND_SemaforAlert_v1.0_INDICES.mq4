///+-----------------------------------------------------------------+ 
// Final Draft 3 Semafor alert\¦/
// Knowledge of the ancients (ò ó)
//______________________o0o___(_)___o0o__
//___¦_____¦_____¦mladen¦_____¦_____¦_____¦
//¦_cja_¦_____¦_____¦_____¦_____¦_____¦__
//___¦_____¦_____¦_____¦_Xard¦777__¦_____¦
//¦____¦ihldiaf¦_____¦_____¦_____¦____¦__
//___¦_____¦_____¦_____¦Baba¦Master_¦____¦
//¦FxSniper___¦_____¦_igor_¦_____¦_nen_¦__           March 24th, 2009
//+------------------------------------------------------------------+
//3_Level_ZZ_Semafor_TRO_MODIFIED_VERSION                     
//3_Level_ZZ_Semafor_TRO_MODIFIED_VERSION   fixed                  
//2008mod   alerts   box email                
//2009mod   alerts   box email + sound               
//+------------------------------------------------------------------+ 
#property copyright "asystem2000" 
#property link      "asystem2000@yandex.ru" 

#property indicator_chart_window 
#property indicator_buffers 6
#property indicator_color1 Lime 
#property indicator_color2 OrangeRed 
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 White
#property indicator_color6 Red
 
#property indicator_width1 6
#property indicator_width2 6
#property indicator_width3 7
#property indicator_width4 7
#property indicator_width5 7
#property indicator_width6 7
 
 
//---- input parameters 
extern double Period1=5; 
extern double Period2=12; 
extern double Period3=35; 
extern string   Dev_Step_1="5,3"; //1,3
extern string   Dev_Step_2="5,3"; //8,5
extern string   Dev_Step_3="5,3";//13,8
extern int Symbol_1_Kod=159;
extern int Symbol_2_Kod=159;
extern int Symbol_3_Kod=82;

//+----    mod of  TRO MODIFICATION ------------------------+ 
extern string _____           ="";
extern bool   Box.Alerts      = false ;
extern bool   Email.Alerts    = false ;
extern bool   Sound.Alerts    = true ;

extern bool   Alert.Lv1    = false ;
extern bool   Alert.Lv2    = true ;
extern bool   Alert.Lv3    = true ;
string Alert.Lv1.High.SoundFile       =  "stage one level high.wav";  //any soundfile
string Alert.Lv1.Low.SoundFile        =  "stage one level low.wav";
string Alert.Lv2.High.SoundFile       =  "stage two level high.wav";
string Alert.Lv2.Low.SoundFile        =  "stage two level low.wav";
string Alert.Lv3.High.SoundFile       =  "stage three level high.wav";
string Alert.Lv3.Low.SoundFile        =  "stage three level low.wav";

//---- buffers 
double FP_BuferUp[];
double FP_BuferDn[]; 
double NP_BuferUp[];
double NP_BuferDn[]; 
double HP_BuferUp[];
double HP_BuferDn[]; 

int F_Period;
int N_Period;
int H_Period;
int Dev1;
int Stp1;
int Dev2;
int Stp2;
int Dev3;
int Stp3;
//+--------- TRO MODIFICATION ---------------------------------------+ 
string symbol, tChartPeriod,  tShortName ;  
int    digits, period  ; 

bool Trigger1,  Trigger2,  Trigger3 ;

int OldBars = -1 ;

color tColor = Yellow ;

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 
//+--------- TRO MODIFICATION ---------------------------------------+  
   period       = Period() ;     
   tChartPeriod =  TimeFrameToString(period) ;
   symbol       =  Symbol() ;
   digits       =  Digits ;   

   tShortName = "tbb"+ symbol + tChartPeriod  ;
    
   
  
// --------- Êîððåêòèðóåì ïåðèîäû äëÿ ïîñòðîåíèÿ ÇèãÇàãîâ
  
  
   if (Period1>0) F_Period=MathCeil(Period1*Period()); else F_Period=0; 
   if (Period2>0) N_Period=MathCeil(Period2*Period()); else N_Period=0; 
   if (Period3>0) H_Period=MathCeil(Period3*Period()); else H_Period=0; 
   
//---- Îáðàáàòûâàåì 1 áóôåð 
   if (Period1>0)
   {
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexArrow(0,Symbol_1_Kod); 
   SetIndexBuffer(0,FP_BuferUp); 
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(1,DRAW_ARROW); 
   SetIndexArrow(1,Symbol_1_Kod); 
   SetIndexBuffer(1,FP_BuferDn); 
   SetIndexEmptyValue(1,0.0); 
   }
   
//---- Îáðàáàòûâàåì 2 áóôåð 
   if (Period2>0)
   {
   SetIndexStyle(2,DRAW_ARROW); 
   SetIndexArrow(2,Symbol_2_Kod); 
   SetIndexBuffer(2,NP_BuferUp); 
   SetIndexEmptyValue(2,0.0); 
   
   SetIndexStyle(3,DRAW_ARROW); 
   SetIndexArrow(3,Symbol_2_Kod); 
   SetIndexBuffer(3,NP_BuferDn); 
   SetIndexEmptyValue(3,0.0); 
   }
//---- Îáðàáàòûâàåì 3 áóôåð 
   if (Period3>0)
   {
   SetIndexStyle(4,DRAW_ARROW); 
   SetIndexArrow(4,Symbol_3_Kod); 
   SetIndexBuffer(4,HP_BuferUp); 
   SetIndexEmptyValue(4,0.0); 

   SetIndexStyle(5,DRAW_ARROW); 
   SetIndexArrow(5,Symbol_3_Kod); 
   SetIndexBuffer(5,HP_BuferDn); 
   SetIndexEmptyValue(5,0.0); 
   }
// Îáðàáàòûâàåì çíà÷åíèÿ äåâèàöèé è øàãîâ
   int CDev=0;
   int CSt=0;
   int Mass[]; 
   int C=0;  
   if (IntFromStr(Dev_Step_1,C, Mass)==1) 
      {
        Stp1=Mass[1];
        Dev1=Mass[0];
      }
   
   if (IntFromStr(Dev_Step_2,C, Mass)==1)
      {
        Stp2=Mass[1];
        Dev2=Mass[0];
      }      
   
   
   if (IntFromStr(Dev_Step_3,C, Mass)==1)
      {
        Stp3=Mass[1];
        Dev3=Mass[0];
      }      
   return(0); 
  } 
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit() 
  { 
//---- 
    
//---- 
   return(0); 
  } 

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start() 
  { 
  

//+--------- TRO MODIFICATION ---------------------------------------+   
   if( Bars != OldBars ) { Trigger1 = True ; Trigger2 = True ; Trigger3 = True ;}
   
     
   if (Period1>0) CountZZ(FP_BuferUp,FP_BuferDn,Period1,Dev1,Stp1);
   if (Period2>0) CountZZ(NP_BuferUp,NP_BuferDn,Period2,Dev2,Stp2);
   if (Period3>0) CountZZ(HP_BuferUp,HP_BuferDn,Period3,Dev3,Stp3);
   
   
//+----    mod of  TRO MODIFICATION ------------------------+ 
   string alert.level;   string alert.message;
   
   alert.message = symbol+"  "+ tChartPeriod+ " at "+ DoubleToStr(Close[0] ,digits);

      if ( Trigger1 &&  Alert.Lv1 ) 
      {
        if( FP_BuferUp[0] != 0 ) {  Trigger1 = False ; alert.level =" ZZS: Level 1 Low;  "; 
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv1.Low.SoundFile); 
                                   }
        if( FP_BuferDn[0] != 0 ) {  Trigger1 = False ; alert.level =" ZZS: Level 1 High; ";
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv1.High.SoundFile);
                                   }
      }
      
      if ( Trigger2 &&  Alert.Lv2 ) 
      {
        if( NP_BuferUp[0] != 0 ) {  Trigger2 = False ; alert.level =" ZZS: Level 2 Low;  "; 
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv2.Low.SoundFile); 
                                   }
        if( NP_BuferDn[0] != 0 ) {  Trigger2 = False ; alert.level =" ZZS: Level 2 High; "; 
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv2.High.SoundFile);
                                   }
      }

      if ( Trigger3 &&  Alert.Lv3 ) 
      {     
        if( HP_BuferUp[0] != 0 ) {  Trigger3 = False ; alert.level =" ZZS: Level 3 Low;  "; 
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv3.Low.SoundFile); 
                                    }
        if( HP_BuferDn[0] != 0 ) {  Trigger3 = False ; alert.level =" ZZS: Level 3 High; "; 
                                    if(Box.Alerts)    Alert(alert.level,alert.message); 
                                    if(Email.Alerts)  SendMail(alert.level,alert.message);
                                    if(Sound.Alerts)  PlaySound(Alert.Lv3.High.SoundFile);
                                   }
      }


   OldBars = Bars ;   

//+----    mod of  TRO MODIFICATION ------------------------+ 
   return(0);
}

//+--------- TRO MODIFICATION ---------------------------------------+  

string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

//+------------------------------------------------------------------+ 
// äîïîëíèòåëüíûå ôóíêöèè
//int Take



//+------------------------------------------------------------------+ 
//| Ôóíêö ôîðìèðîâàíèÿ ÇèãÇàãà                        | 
//+------------------------------------------------------------------+  
int CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep )
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
        
          ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
        }
     }
 }

//+------------------------------------------------------------------+   
int Str2Massive(string VStr, int& M_Count, int& VMass[])
  {
    int val=StrToInteger( VStr);
    if (val>0)
       {
         M_Count++;
         int mc=ArrayResize(VMass,M_Count);
         if (mc==0)return(-1);
          VMass[M_Count-1]=val;
         return(1);
       }
    else return(0);    
  } 
  

//+------------------------------------------------------------------+   
int IntFromStr(string ValStr,int& M_Count, int& VMass[])
  {
    
    if (StringLen(ValStr)==0) return(-1);
    string SS=ValStr;
    int NP=0; 
    string CS;
    M_Count=0;
    ArrayResize(VMass,M_Count);
    while (StringLen(SS)>0)
      {
            NP=StringFind(SS,",");
            if (NP>0)
               {
                 CS=StringSubstr(SS,0,NP);
                 SS=StringSubstr(SS,NP+1,StringLen(SS));  
               }
               else
               {
                 if (StringLen(SS)>0)
                    {
                      CS=SS;
                      SS="";
                    }
               }
            if (Str2Massive(CS,M_Count,VMass)==0) 
               {
                 return(-2);
               }
      }
    return(1);    
  }
  

//+------------------------------------------------------------------+   