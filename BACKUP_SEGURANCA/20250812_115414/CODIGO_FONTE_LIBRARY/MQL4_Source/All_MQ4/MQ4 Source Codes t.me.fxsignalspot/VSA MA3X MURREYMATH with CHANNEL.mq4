//+------------------------------------------------------------------+
//|                                                         VSA MA3X |
//|                                    Copyright © 2009, FOREXflash. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, FOREXflash Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 8

#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 White
#property indicator_color4 Magenta
#property indicator_color5 Lime
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Blue

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 3
#property indicator_width6 2

#define MMTop "MMTop"
#define MMBot "MMBot"
#define MMperiod "MMperiod"

extern string  Note = "VSA SIGNALS";
extern bool    WaitNextBarConfirmation = true;
extern int     NumberOfBars = 500;
extern int     P = 64;
extern int     StepBack = 0;
extern bool    Comments=true;
extern int     AngleText=90;
extern string  Note2 = "CHANNEL";
extern int     AllBars = 240;
extern int     BarsForFract = 0;
extern string  Note3 = "AVERAGE RANGE";
int Magic_num = 12345;
extern int Av_1  = 0;
extern int Av_2  = 1;
extern int Av_3  = 5;
extern int Av_4  = 10;
extern int Av_5  = 20;
extern int Av_6  = 30;
extern color Title_col    = DarkOrange;
extern color Label_col    = Gray;
extern color Av_col       = Red;
extern color Total_col    = Silver;
extern color Total_Av_col = Red;

extern int   Shift_UP_DN = 10;// Adjusts Signal Display Up & Down 
extern int   Adjust_Side_to_side  = 10;// Adjusts Signal Display from side to side

int     MAPeriod = 100;
int     LookBack = 20;



double  dmml = 0,
        dvtl = 0,
        sum  = 0,
        v1 = 0,
        v2 = 0,
        mn = 0,
        mx = 0,
        x1 = 0,
        x2 = 0,
        x3 = 0,
        x4 = 0,
        x5 = 0,
        x6 = 0,
        y1 = 0,
        y2 = 0,
        y3 = 0,
        y4 = 0,
        y5 = 0,
        y6 = 0,
        octave = 0,
        fractal = 0,
        range   = 0,
        finalH  = 0,
        finalL  = 0,
        mml[13];

string  ln_txt[13],        
        buff_str = "";
        
int     
        bn_v1   = 0,
        bn_v2   = 0,
        OctLinesCnt = 13,
        mml_thk = 8,
        mml_clr[13],
        mml_shft = 3,
        nTime = 0,
        CurPeriod = 0,
        nDigits = 0,
        i = 0;
        
double ExtMapBufferSHI[];
//---- input parameters

int    CurrentBar = 0;
double Step = 0;
int    B1 = -1, B2 = -1;
int    UpDown = 0;
double P1 = 0, P2 = 0, PP = 0;
int     AB = 300, BFF = 0;
int    ishift = 0;
double iprice = 0;
datetime T1, T2;


double red[],green[],white[],magenta[],P1Buffer[],P2Buffer[];

double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
      SetIndexBuffer(0,red);
      SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(0,159);
      SetIndexLabel(0,"Climax High ");
      
      SetIndexBuffer(1,green);
      SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(1,159);
      SetIndexLabel(1,"HighChurn ");
      
      SetIndexBuffer(2,white);
      SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(2,159);
      SetIndexLabel(2,"Climax Low ");
      
      SetIndexBuffer(3,magenta);
      SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(3,159);
      SetIndexLabel(3,"ClimaxChurn ");
      
      SetIndexBuffer(4, P1Buffer);
      SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexLabel(4,"BUYERS PRESSURE ");

      SetIndexBuffer(5, P2Buffer);
      SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexLabel(5,"SELLERS PRESSURE ");
      

      SetIndexBuffer(6,ExtMapBuffer1);
      SetIndexEmptyValue(6,0.0);
      

      SetIndexBuffer(7,ExtMapBuffer2);
      SetIndexEmptyValue(7,0.0);
      
      IndicatorShortName("VSA MA3X" );
      
      //---- indicators
   ln_txt[0]  = "                          [-2/8]Extreme Overshoot";// "extremely overshoot [-2/8]";// [-2/8]
   ln_txt[1]  = "             [-1/8]Overshoot";// "overshoot [-1/8]";// [-1/8]
   ln_txt[2]  = "                     [0/8]Ultimate Support";// "Ultimate Support - extremely oversold [0/8]";// [0/8]
   ln_txt[3]  = "                           [1/8]Weak Stall & Reverse";// "Weak, Stall and Reverse - [1/8]";// [1/8]
   ln_txt[4]  = "                    [2/8]Reversal - Major";// "Pivot, Reverse - major [2/8]";// [2/8]
   ln_txt[5]  = "                               [3/8]Bottom - Trading Range";// "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone";//[3/8]
   ln_txt[6]  = "                                  [4/8]Major Support/Resistance";// "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level";// [4/8]
   ln_txt[7]  = "                       [5/8]Top Trading Range";// "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone";//[5/8]
   ln_txt[8]  = "                 [6/8]Reversal Major";// "Pivot, Reverse - major [6/8]";// [6/8]
   ln_txt[9]  = "                           [7/8]Weak Stall & Reverse";// "Weak, Stall and Reverse - [7/8]";// [7/8]
   ln_txt[10] = "                         [8/8]Ulitimate Resistance";// "Ultimate Resistance - extremely overbought [8/8]";// [8/8]
   ln_txt[11] = "             [+1/8]Overshoot";// "overshoot [+1/8]";// [+1/8]
   ln_txt[12] = "                          [+2/8]Extreme Overshoot";// "extremely overshoot [+2/8]";// [+2/8]

   mml_shft = 0;//original was 3
   mml_thk  = 3;

   // Ír÷rëüír? ónnríîâer öâlnîâ ódîâílé îenrâ 
   mml_clr[0]  = C'90,90,90';//SteelBlue;    // [-2]/8
   mml_clr[1]  = C'90,90,90';//DarkViolet;  // [-1]/8
   mml_clr[2]  = Maroon;//Aqua;        //  [0]/8
   mml_clr[3]  = C'90,90,90';//Gold;      //  [1]/8
   mml_clr[4]  = C'90,90,90';//Red;         //  [2]/8
   mml_clr[5]  = Maroon;//Green;   //  [3]/8
   mml_clr[6]  = Black;//Blue;        //  [4]/8
   mml_clr[7]  = Maroon;//Green;   //  [5]/8
   mml_clr[8]  = C'90,90,90';//Red;         //  [6]/8
   mml_clr[9]  = C'90,90,90';//Gold;      //  [7]/8
   mml_clr[10] = Maroon;//Aqua;        //  [8]/8
   mml_clr[11] = C'90,90,90';//DarkViolet;  // [+1]/8
   mml_clr[12] = C'90,90,90';//SteelBlue;    // [+2]/8
//----
      

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  for(int i = 0; i < Bars; i++)
   {
      if(ObjectFind("VSA_BarSupply&Demand" + Time[i]) >= 0)
      {
         ObjectDelete("VSA_BarSupply&Demand" + Time[i]);
      }
   } 
   Comment(" ");   
for(i=0;i<OctLinesCnt;i++) {
    buff_str = "mml"+i;
    ObjectDelete(buff_str);
    buff_str = "mml_txt"+i;
    ObjectDelete(buff_str);
    }
     ObjectDelete("TL1");
	  ObjectDelete("TL2");
	  ObjectDelete("MIDL");
     DeleteLabels();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelObj()
  {
	  ObjectDelete("TL1");
	  ObjectDelete("TL2");
	  ObjectDelete("MIDL");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int TickVolume()
  {

   int i,ii;
   static int pii=-1;
   
   for(i = 0; i <iBars(Symbol(),PERIOD_M1) ; i++)
     {
       ii = iBarShift(Symbol(), Period(), iTime(Symbol(),PERIOD_M1,i), true);
       //----
       if (pii!=ii)
       {
         P1=0;
         P2=0;
         P1Buffer[ii]=0;
         P2Buffer[ii]=0;

       }
       
       if (ii != -1)
       {
         if (iClose(Symbol(),PERIOD_M1,i)>iClose(Symbol(),PERIOD_M1,i+1))
         {
           P1 = P1+(iVolume(Symbol(),PERIOD_M1,i));
         }
         if (iClose(Symbol(),PERIOD_M1,i)<iClose(Symbol(),PERIOD_M1,i+1))
         {
           P2 = P2+(iVolume(Symbol(),PERIOD_M1,i));
         }
         if (iClose(Symbol(),PERIOD_M1,i)==iClose(Symbol(),PERIOD_M1,i+1))
         {
           P1 = P1+(iVolume(Symbol(),PERIOD_M1,i)/2);
           P2 = P2+(iVolume(Symbol(),PERIOD_M1,i)/2);
         }
       }
       P1Buffer[ii]=P1;
       P2Buffer[ii]=P2;


       pii=ii;
    }
//----
   return(0);
  }  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   TickVolume();
   VSA_BarSD();
   MURREYMATH();
   SHI();
   RANGE();
   
  
   double VolLowest,Range,Value2,Value3,HiValue2,HiValue3,LoValue3,tempv2,tempv3,tempv;
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   if ( NumberOfBars == 0 ) 
      NumberOfBars = Bars-counted_bars;
   limit=NumberOfBars; //Bars-counted_bars;
   
      
   for(int i=0; i<limit; i++)   
      {
         red[i] = 0; green[i] = 0; white[i] = 0; magenta[i] = 0;
         Value2=0;Value3=0;HiValue2=0;HiValue3=0;LoValue3=99999999;tempv2=0;tempv3=0;tempv=0;
         
         
               
         Range = (High[i]-Low[i]);
         Value2 = Volume[i]*Range;
         
         if (  Range != 0 )
            Value3 = Volume[i]/Range;
            
         
         for ( int n=i;n<i+MAPeriod;n++ )
            {
               tempv= Volume[n] + tempv; 
            } 
         
          
          for ( n=i;n<i+LookBack;n++)
            {
               tempv2 = Volume[n]*((High[n]-Low[n])); 
               if ( tempv2 >= HiValue2 )
                  HiValue2 = tempv2;
                    
               if ( Volume[n]*((High[n]-Low[n])) != 0 )
                  {           
                     tempv3 = Volume[n] / ((High[n]-Low[n]));
                     if ( tempv3 > HiValue3 ) 
                        HiValue3 = tempv3; 
                     if ( tempv3 < LoValue3 )
                        LoValue3 = tempv3;
                  } 
            }
            
                                               
          if ( Value2 == HiValue2  && Close[i] > (High[i] + Low[i]) / 2 )
            {
             if ( P1Buffer[i]>P2Buffer[i]) red[i] = P1Buffer[i]+50;
             if ( P1Buffer[i]<P2Buffer[i]) red[i] = P2Buffer[i]+50;
             white[i]=0;
             magenta[i]=0;
             green[i]=0;
            }   
            
          if ( Value3 == HiValue3 )
            {
             if ( P1Buffer[i]>P2Buffer[i]) green[i] = P1Buffer[i]+50;
             if ( P1Buffer[i]<P2Buffer[i]) green[i] = P2Buffer[i]+50;
             red[i]=0;
             white[i]=0;
             magenta[i]=0;
            }
          if ( Value2 == HiValue2 && Value3 == HiValue3 )
            {
             if ( P1Buffer[i]>P2Buffer[i]) magenta[i] = P1Buffer[i]+50;
             if ( P1Buffer[i]<P2Buffer[i]) magenta[i] = P2Buffer[i]+50;
             red[i]=0;
             green[i]=0;
             white[i]=0;

            } 
         if ( Value2 == HiValue2  && Close[i] <= (High[i] + Low[i]) / 2 )
            {
             if ( P1Buffer[i]>P2Buffer[i]) white[i] = P1Buffer[i]+50;
             if ( P1Buffer[i]<P2Buffer[i]) white[i] = P2Buffer[i]+50;
             magenta[i]=0;
             red[i]=0;
             green[i]=0;
            } 
            
         
      }
//----
   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void VSA_BarSD()
{
   int    counted_bars=IndicatorCounted();
   int i = Bars - counted_bars + 1;
   if(counted_bars == 0)
   {
      i = 6000;
   }
   int volume = 0;
   int spread = 0;
   int close = 0;
   double range;
   double range1;
   bool ND = false;
   bool NS = false;
//----
   while(i > 0)
   {
      ExtMapBuffer1[i] = 0;
      ExtMapBuffer2[i] = 0;
   
      range = High[i] - Low[i];
      range1 = High[i+1] - Low[i+1];
      ND = false;
      NS = false;
      
      if(Volume[i] <= Volume[i+1] && Volume[i] <= Volume[i+2])
      {
         //Version1
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range <= range1 && Close[i] > Close[i+1])
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 1);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range <= range1 && Close[i] < Close[i+1])
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 1);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version2
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range > range1 && Close[i] == Open[i])
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 2);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range > range1 && Close[i] == Open[i])
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 2);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version3
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range > range1 && Close[i] == High[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 3);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range > range1 && Close[i] == Low[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 3);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version4
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range > range1 && Close[i] == (High[i]+Low[i])*0.5 && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 4);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range > range1 && Close[i] == (High[i]+Low[i])*0.5 && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 4);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version5
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range > range1 && Close[i] == Low[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 5);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range > range1 && Close[i] == High[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 5);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version6
         if(range < range1 && Close[i] > Close[i+1] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 6);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range < range1 && Close[i] < Close[i+1] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 6);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version7
         if(range == range1 && Close[i] > Close[i+1] && Close[i] == Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 7);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range == range1 && Close[i] < Close[i+1] && Close[i] == Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 7);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version8
         if(range == range1 && Close[i] > Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 8);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range == range1 && Close[i] < Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 8);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version9
         if(range == range1 && Close[i] > Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 9);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range == range1 && Close[i] < Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 9);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version10
         if(range == range1 && Close[i] > Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 10);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range == range1 && Close[i] < Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 10);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version11
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]))
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 11);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]))
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 11);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version12
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 12);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 12);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version13
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 13);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 13);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version14
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 14);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(range < range1 && Close[i] == Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 14);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version15
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range < range1 && Close[i] >= Close[i+1] && Close[i] == Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 15);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range < range1 && Close[i] <= Close[i+1] && Close[i] == Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 15);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version16
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range < range1 && Close[i] >= Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 16);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range < range1 && Close[i] <= Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 16);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version17
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range < range1 && Close[i] >= Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 17);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range < range1 && Close[i] <= Close[i+1] && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 17);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version18
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range < range1 && Close[i] >= Close[i+1] && Close[i] == Low[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 18);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range < range1 && Close[i] <= Close[i+1] && Close[i] == High[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 18);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version19
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && Close[i] == Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]))
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 19);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1]  && Close[i] == Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]))
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 19);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version20
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range <= range1 && Close[i] == High[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 20);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range <= range1 && Close[i] == Low[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 20);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version21
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range <= range1 && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 21);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range <= range1 && Close[i] == (High[i]+Low[i])*0.5 && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 21);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

         //Version22
         if(High[i] > High[i+1] && Low[i] >= Low[i+1] && range <= range1 && Close[i] == Low[i] && Close[i] != Open[i] && ND == false)
         {
            if((WaitNextBarConfirmation && Close[i] > Close[i-1] && High[i] >= High[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], High[i] + 3*Point, true, 22);
               ExtMapBuffer1[i] = High[i];// + 3*Point;
               ND = true;
            }
         }
         if(Low[i] < Low[i+1] && High[i] <= High[i+1] && range <= range1 && Close[i] == High[i] && Close[i] != Open[i] && NS == false)
         {
            if((WaitNextBarConfirmation && Close[i] < Close[i-1] && Low[i] <= Low[i-1]) || WaitNextBarConfirmation == false)
            {
               TextOutput(Time[i], Low[i] - 3*Point, false, 22);
               ExtMapBuffer2[i] = Low[i];// + 3*Point;
               NS = true;
            }
         }

      }
      i--;
   }
//----
   return(0);
}

void TextOutput(datetime t, double p, bool ND, int NDN)
{
   string name = "VSA_BarSupply&Demand" + t;
   if(ObjectFind(name) >= 0) ObjectDelete(name);
   
   ObjectCreate(name, OBJ_TEXT, 0, t, p);
   ObjectSet(name, OBJPROP_ANGLE, AngleText);
   
   string text;
   
   if(ND)
   {
      text = "NoDemand " + NDN;
      ObjectSetText(name, text, 8, "Arial Narrow", Red);
   }
   else
   {
      text = "NoSupply " + NDN;
      ObjectSetText(name, text, 8, "Arial Narrow", Blue);
   }
}

  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void MURREYMATH() {

//---- TODO: add your code here

if( (nTime != Time[0]) || (CurPeriod != Period()) ) {
   
  //price
   bn_v1 = Lowest(NULL,0,MODE_LOW,P+StepBack,0);
   bn_v2 = Highest(NULL,0,MODE_HIGH,P+StepBack,0); // changes when price exceeds hi/low

   v1 = Low[bn_v1];
   v2 = High[bn_v2];
   
   //Comment("\n","MURREYMATH ","\n","HighClose = ",v2,"\n","LowClose = ",v1,"\n");
   //Comment("HighClose ",v2,"\n","LowClose ",v1,"\n");

//Comment("Copyright © http://young.net.pl/forex");
   
   //v1=(Close[Lowest(NULL,0,MODE_CLOSE,P+StepBack,0)]);
   //v2=(Close[Highest(NULL,0,MODE_CLOSE,P+StepBack,0)]);// Possibly a better hi/low code than above code changes on CLOSE
                                                         // Still does not update 
                         
//determine fractal.....
   if( v2<=250000 && v2>25000 )
   fractal=100000;
   else
     if( v2<=25000 && v2>2500 )
     fractal=10000;
     else
       if( v2<=2500 && v2>250 )
       fractal=1000;
       else
         if( v2<=250 && v2>25 )
         fractal=100;
         else
           if( v2<=25 && v2>12.5 )
           fractal=12.5;
           else
             if( v2<=12.5 && v2>6.25)
             fractal=12.5;
             else
               if( v2<=6.25 && v2>3.125 )
               fractal=6.25;
               else
                 if( v2<=3.125 && v2>1.5625 )
                 fractal=3.125;
                 else
                   if( v2<=1.5625 && v2>0.390625 )
                   fractal=1.5625;
                   else
                     if( v2<=0.390625 && v2>0)
                     fractal=0.1953125;
      
   range=(v2-v1);
   sum=MathFloor(MathLog(fractal/range)/MathLog(2));
   octave=fractal*(MathPow(0.5,sum));
   mn=MathFloor(v1/octave)*octave;
   if( (mn+octave)>v2 )
   mx=mn+octave; 
   else
     mx=mn+(2*octave);


// calculating xx
//x2
    if( (v1>=(3*(mx-mn)/16+mn)) && (v2<=(9*(mx-mn)/16+mn)) )
    x2=mn+(mx-mn)/2; 
    else x2=0;
//x1
    if( (v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0) )
    x1=mn+(mx-mn)/2; 
    else x1=0;

//x4
    if( (v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn)) )
    x4=mn+3*(mx-mn)/4; 
    else x4=0;

//x5
    if( (v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0) )
    x5=mx; 
    else  x5=0;

//x3
    if( (v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0) )
    x3=mn+3*(mx-mn)/4; 
    else x3=0;

//x6
    if( (x1+x2+x3+x4+x5) ==0 )
    x6=mx; 
    else x6=0;

     finalH = x1+x2+x3+x4+x5+x6;
// calculating yy
//y1
    if( x1>0 )
    y1=mn; 
    else y1=0;

//y2
    if( x2>0 )
    y2=mn+(mx-mn)/4; 
    else y2=0;

//y3
    if( x3>0 )
    y3=mn+(mx-mn)/4; 
    else y3=0;

//y4
    if( x4>0 )
    y4=mn+(mx-mn)/2; 
    else y4=0;

//y5
    if( x5>0 )
    y5=mn+(mx-mn)/2; 
    else y5=0;

//y6
    if( (finalH>0) && ((y1+y2+y3+y4+y5)==0) )
    y6=mn; 
    else y6=0;

    finalL = y1+y2+y3+y4+y5+y6;

    for( i=0; i<OctLinesCnt; i++) {
         mml[i] = 0;
         }
         
   dmml = (finalH-finalL)/8;

   mml[0] =(finalL-dmml*2); //-2/8
   for( i=1; i<OctLinesCnt; i++) {
        mml[i] = mml[i-1] + dmml;
        }
   for( i=0; i<OctLinesCnt; i++ ){
        buff_str = "mml"+i;
        if(ObjectFind(buff_str) == -1) {
           ObjectCreate(buff_str, OBJ_HLINE, 0, Time[0], mml[i]);
           ObjectSet(buff_str, OBJPROP_STYLE, STYLE_DOT);
           ObjectSet(buff_str, OBJPROP_COLOR, mml_clr[i]);
           ObjectSet(buff_str, OBJPROP_BACK, 1);
           ObjectMove(buff_str, 0, Time[0],  mml[i]);
           }
        else {
           ObjectMove(buff_str, 0, Time[0],  mml[i]);
           }
             
        buff_str = "mml_txt"+i;
        if(ObjectFind(buff_str) == -1) {
           ObjectCreate(buff_str, OBJ_TEXT, 0, Time[mml_shft], mml_shft);
           ObjectSetText(buff_str, ln_txt[i], 8, "Tahoma", mml_clr[i]);
           ObjectSet(buff_str, OBJPROP_BACK, 1);
           ObjectMove(buff_str, 0, Time[mml_shft],  mml[i]);
           }
        else {
           ObjectMove(buff_str, 0, Time[mml_shft],  mml[i]);
           }
        } // for( i=1; i<=OctLinesCnt; i++ ){

   nTime    = Time[0];
   CurPeriod= Period();

           //ObjectDelete(MMBot);
           //ObjectCreate(MMBot, OBJ_RECTANGLE, 0, Time[0], mml[0], Time[P], mml[2]);
           //ObjectSet(MMBot, OBJPROP_COLOR, C'33,33,33');
           
           //ObjectDelete(MMTop);
           //ObjectCreate(MMTop, OBJ_RECTANGLE, 0, Time[0], mml[10], Time[P], mml[12]);
           //ObjectSet(MMTop, OBJPROP_COLOR, C'33,33,33');

           //ObjectDelete(MMperiod);
           //ObjectCreate(MMperiod, OBJ_RECTANGLE, 0, Time[P], mml[0], Time[2*P], mml[12]);
           //ObjectSet(MMperiod, OBJPROP_COLOR, C'33,33,33');
   }
 
//---- End Of Program
  return(0);
  }
   
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void SHI()
  {
   int counted_bars = IndicatorCounted();
//---- 
	  if((AllBars == 0) || (Bars < AllBars)) 
	      AB = Bars; 
	  else AB = AllBars;
	  if(BarsForFract > 0) 
		     BFF = BarsForFract; 
	  else
		     switch (Period())
		       {
			        case     1: BFF = 12; break;
			        case     5: BFF = 48; break;
			        case    15: BFF = 24; break;
			        case    30: BFF = 24; break;
			        case    60: BFF = 12; break;
			        case   240: BFF = 15; break;
			        case  1440: BFF = 10; break;
			        case 10080: BFF = 6;  break;
			        default: DelObj(); return(-1); break;
		       }
   CurrentBar = 2; 
   B1 = -1; 
   B2 = -1; 
   UpDown = 0;
   while(((B1 == -1) || (B2==-1)) && (CurrentBar<AB))
     {

		     if((UpDown < 1) && (CurrentBar == Lowest(Symbol(), Period(), MODE_LOW, BFF*2 + 1,
		        CurrentBar - BFF))) 
		       {
			        if(UpDown == 0) 
			          { 
			            UpDown = -1; 
			            B1 = CurrentBar; 
			            P1 = Low[B1]; 
			          }
			        else 
			          { 
			            B2 = CurrentBar; 
			            P2 = Low[B2];
			          }
		       }
		     if((UpDown > -1) && (CurrentBar == Highest(Symbol(), Period(), MODE_HIGH, BFF*2 + 1,
		        CurrentBar - BFF))) 
		       {
			        if(UpDown == 0) 
			          { 
			            UpDown = 1; 
			            B1 = CurrentBar; 
			            P1 = High[B1]; 
			          }
			        else 
			          { 
			            B2 = CurrentBar; 
			            P2 = High[B2]; 
			          }
		       }
		     CurrentBar++;
	    }
	  if((B1 == -1) || (B2 == -1)) 
	    {
	      DelObj(); 
	      return(-1);
	    } 
	  Step = (P2 - P1) / (B2 - B1); 
	  P1 = P1 - B1*Step; 
	  B1 = 0; 

	  ishift = 0; 
	  iprice = 0;
	  if(UpDown == 1)
	    { 
		     PP = Low[2] - 2*Step;
		     for(i = 3; i <= B2; i++) 
		       {
			        if(Low[i] < PP + Step*i) 
			            PP = Low[i] - i*Step; 
		       }
		     if(Low[0] < PP) 
		       {
		         ishift = 0; 
		         iprice = PP;
		       }
		     if(Low[1] < PP + Step) 
		       {
		         ishift = 1; 
		         iprice = PP + Step;
		       }
		     if(High[0] > P1) 
		       {
		         ishift = 0; 
		         iprice = P1;
		       }
		     if(High[1] > P1 + Step) 
		       {
		         ishift = 1; 
		         iprice = P1 + Step;
		       }
	    } 
	  else
	    { 
		     PP = High[2] - 2*Step;
		     for(i = 3; i <= B2; i++) 
		       {
			        if(High[i] > PP + Step*i) 
			            PP = High[i] - i*Step;
		       }
		     if(Low[0] < P1) 
		       {
		         ishift = 0; 
		         iprice = P1;
		       }
		     if(Low[1] < P1 + Step) 
		       {
		         ishift = 1; 
		         iprice = P1 + Step;
		       }
		     if(High[0] > PP) 
		       {
		         ishift = 0; 
		         iprice = PP;
		       }
		     if(High[1] > PP + Step) 
		       {
		         ishift = 1; 
		         iprice = PP + Step;
		       }
	    }

	  P2 = P1 + AB*Step;
	  T1 = Time[B1]; 
	  T2 = Time[AB];

	  if(iprice != 0) 
	      ExtMapBufferSHI[ishift] = iprice;
	  DelObj();
	  ObjectCreate("TL1", OBJ_TREND, 0, T2, PP + Step*AB, T1, PP); 
		 ObjectSet("TL1", OBJPROP_COLOR, Gray); 
		 ObjectSet("TL1", OBJPROP_WIDTH, 2); 
		 ObjectSet("TL1", OBJPROP_STYLE, STYLE_SOLID); 
	  ObjectCreate("TL2", OBJ_TREND, 0, T2, P2, T1, P1); 
		 ObjectSet("TL2", OBJPROP_COLOR, Gray); 
		 ObjectSet("TL2", OBJPROP_WIDTH, 2); 
		 ObjectSet("TL2", OBJPROP_STYLE, STYLE_SOLID); 
	  ObjectCreate("MIDL", OBJ_TREND, 0, T2, (P2 + PP + Step*AB) / 2, T1, (P1 + PP) / 2);
		 ObjectSet("MIDL", OBJPROP_COLOR, Gray); 
		 ObjectSet("MIDL", OBJPROP_WIDTH, 1); 
		 ObjectSet("MIDL", OBJPROP_STYLE, STYLE_DOT);
		 Comment(" Channel size = ", DoubleToStr(MathAbs(PP - P1) / Point, 0), " Slope = ", 
		         DoubleToStr(-Step / Point, 2));
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void RANGE()
  {
   int    counted_bars=IndicatorCounted();
//----

    int AV1=0,AV2=0,AV3=0,AV4=0,AV5=0,AV6=0,RAvg;
    int i=0;

   AV1 =  (iHigh(NULL,1440,0)-iLow(NULL,1440,0))/Point;
   
   AV2 =  (iHigh(NULL,1440,1)-iLow(NULL,1440,1))/Point;
   
   for(i=1;i<=Av_3;i++)
   AV3 =  AV3 +  (iHigh(NULL,1440,i)-iLow(NULL,1440,i))/Point;
  
   for(i=1;i<=Av_4;i++)
   AV4 =  AV4 +  (iHigh(NULL,1440,i)-iLow(NULL,1440,i))/Point;
   
   for(i=1;i<=Av_5;i++)    
   AV5 = AV5 +  (iHigh(NULL,1440,i)-iLow(NULL,1440,i))/Point;
   
   for(i=1;i<=Av_6;i++)
   AV6 =  AV6  +  (iHigh(NULL,1440,i)-iLow(NULL,1440,i))/Point;
      
   AV3 = AV3/Av_3;
   AV4 = AV4/Av_4;
   AV5 = AV5/Av_5;
   AV6 = AV6/Av_6;
   RAvg  =  (AV2+AV3+AV4+AV5+AV6)/5; 
   
   CreateAverage( "AV"+Magic_num,15+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV"+Magic_num,"Daily Range",14,"Arial Bold",DarkOrange); 
   
   CreateAverage( "AV1"+Magic_num,28+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV1"+Magic_num,"-------------------------------",10,"Arial Bold",Silver); 
   
   
   CreateAverage( "AV2"+Magic_num,40+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV2"+Magic_num,"Today", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV3"+Magic_num,40+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV3"+Magic_num,DoubleToStr(AV1 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV4"+Magic_num,60+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV4"+Magic_num,""+Av_2+" Day", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV5"+Magic_num,60+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV5"+Magic_num,DoubleToStr(AV2 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV6"+Magic_num,80+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV6"+Magic_num,""+Av_3+" Days", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV7"+Magic_num,80+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV7"+Magic_num,DoubleToStr(AV3 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV8"+Magic_num,100+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV8"+Magic_num,""+Av_4+" Days", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV9"+Magic_num,100+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV9"+Magic_num,DoubleToStr(AV4 ,0), 16,"Arial Bold",Red); 
   
    CreateAverage( "AV8"+Magic_num,100+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV8"+Magic_num,""+Av_4+" Days", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV9"+Magic_num,100+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV9"+Magic_num,DoubleToStr(AV4 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV10"+Magic_num,120+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV10"+Magic_num,""+Av_5+" Days", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV11"+Magic_num,120+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV11"+Magic_num,DoubleToStr(AV5 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV12"+Magic_num,140+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV12"+Magic_num,""+Av_6+" Days", 14,"Arial Bold",Gray); 
     
   CreateAverage( "AV13"+Magic_num,140+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV13"+Magic_num,DoubleToStr(AV6 ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV14"+Magic_num,167+ Shift_UP_DN,60+ Adjust_Side_to_side );
   ObjectSetText("AV14"+Magic_num,"Total Av", 14,"Arial Bold",Silver); 
  
   CreateAverage( "AV15"+Magic_num,167+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV15"+Magic_num,DoubleToStr(RAvg ,0), 16,"Arial Bold",Red); 
   
   CreateAverage( "AV16"+Magic_num,155+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV16"+Magic_num,"-------------------------------",10,"Arial Bold",Silver); 
   
   CreateAverage( "AV17"+Magic_num,180+ Shift_UP_DN,10+ Adjust_Side_to_side );
   ObjectSetText("AV17"+Magic_num,"-------------------------------",10,"Arial Bold",Silver); 
   
   
     
   
//----
   return(0);
  }
  
  
int CreateAverage( string n, int Shift_UP_DN, int Adjust_Side_to_side ) {
   ObjectCreate( n, OBJ_LABEL,0, 0, 0 );
   ObjectSet( n, OBJPROP_CORNER, 1 );
   ObjectSet( n, OBJPROP_XDISTANCE,Adjust_Side_to_side );
   ObjectSet( n, OBJPROP_YDISTANCE,Shift_UP_DN);
   ObjectSet( n, OBJPROP_BACK, false );
   }
   
   void DeleteLabels(){
   
   ObjectDelete("AV"+Magic_num); ObjectDelete("AV1"+Magic_num);ObjectDelete("AV2"+Magic_num);
   ObjectDelete("AV3"+Magic_num);ObjectDelete("AV4"+Magic_num);ObjectDelete("AV5"+Magic_num);
   ObjectDelete("AV6"+Magic_num);ObjectDelete("AV7"+Magic_num);ObjectDelete("AV8"+Magic_num);
   ObjectDelete("AV9"+Magic_num);ObjectDelete("AV10"+Magic_num);ObjectDelete("AV11"+Magic_num);
   ObjectDelete("AV12"+Magic_num);ObjectDelete("AV13"+Magic_num);ObjectDelete("AV14"+Magic_num);
   ObjectDelete("AV15"+Magic_num);ObjectDelete("AV16"+Magic_num);ObjectDelete("AV17"+Magic_num);
   }
//+------------------------------------------------------------------+