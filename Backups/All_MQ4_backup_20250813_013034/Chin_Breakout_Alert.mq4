//+------------------------------------------------------------------+
//|                                          Chin Breakout Alert.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                                                  |
//|    Instructions for use                                          |
//|    are in this video:http://www.youtube.com/watch?v=5Ds1BZl78xQ  |
//+------------------------------------------------------------------+
#property copyright "Chin Pip.  Video instruction is@ youtube video below:"
#property link      "http://www.youtube.com/watch?v=5Ds1BZl78xQ"
//----
#include <stdlib.mqh>
//----
#property indicator_chart_window
#property indicator_buffers 1
//----
#property indicator_color1 Black
//---- input parameters
extern bool      Alert_on =True;
extern bool      Pop_Up_Box=False;
extern double    Time_Out=6;
//---- buffers
double ExtMapBuffer1[];
double top =-1;
double bottom=-1;
double hi= -1;     //this is used for the visible bar High
double lo= -1;     //visible bar Low
double hi5=-1;     // (5 bar hi)this is to make sure that we didn't scale ourselves out of the visible area of WindowS
double lo5=-1;     // (5 bar low)
double himax=-1;   //max price on the scale.
double lomin=-1;   //min price on the scale
int windowbars=-1; //how many bars
double i=-1;       //this is a counter
double ii=-1;      //another counter
double sleep=716.0989767; // this is an artificial sleep
double timecur=-1; //this is the time current for the pauses between movements
double timeloc=-1;
double timeloc2= -1;//this is a smaller lock out just for displaying the breech message
string topS=" ";    //this is a string to convert the double top into a string
string bottomS="."; //this is to convert double bottom into a string
double blue_ydistance= -1; //finds the ydistnace 
double red_ydistance=-1;
string TopComment="none";
string BottomComment="none";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //Before we Start, Let's delete all the objects:
   ObjectDelete("top");
   ObjectDelete("bottom");
   ObjectDelete("Top Instruction");
   ObjectDelete("Bottom Instruction");
   ObjectDelete("Vis1");
   ObjectDelete("Vis2");
   ObjectDelete("Vis3");
   ObjectDelete("Vis4");
//------------
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   //Comment("blah blah");
/* 
   let's do some visual effects to let traders know that this is indeed a Visual Trader
   himax=WindowPriceMax(0);  //get the hi and low window price
   lomin=WindowPriceMin(0); 
   int x1 = MathRound(WindowBarsPerChart()*0.66);
   int x2 = MathRound(WindowBarsPerChart()*0.39);
   int x3 = MathRound(WindowBarsPerChart()*0.71);
   int x4 = MathRound(WindowBarsPerChart()*0.31);
   double xx1 = lomin+(himax-lomin)/7;  //the low plus a tenth of the range of the high to the low
   double xx2 = himax-(himax-lomin)/7;
   double xx3 = himax-(himax-lomin)/7;
   double xx4 = himax-(himax-lomin)/7;
   xx1=WindowPriceMax(0);
   xx2=WindowPriceMin(0);
   Comment("winmax",WindowPriceMax(0), " xx1 ", xx1, " xx2 ", xx2, " xx3 ", xx3, " xx4 ", xx4);
   ObjectCreate("Vis1",OBJ_TEXT,0,Time[x1],xx1);//lomin+(himax+lomin)/10);
   ObjectCreate("Vis2",OBJ_TEXT,0,Time[x2],xx2);//himax-(himax+lomin)/10);
   ObjectCreate("Vis3",OBJ_TEXT,0,Time[x3],xx3);//himax-(himax+lomin)/7);
   ObjectCreate("Vis4",OBJ_TEXT,0,Time[x4],xx4);
   ObjectSetText("Vis1","____________________________________________________________",10,"Arial",Blue); //start at the middle and move towards the final location 
   ObjectSetText("Vis2","____________________________________________________________",10,"Arial",Red); 
   ObjectSetText("Vis3","Visual",30,"Arial",ForestGreen);
   ObjectSetText("Vis4","Trader",40,"Arial",ForestGreen);
   //final destination of:
   //vis1: middle and Hi (spins twice as fast)
   //vis2: middle and low
   //vis3: Left middle and Low(spins twice as fast)
   //vis4: Right Middle and Low      
   //we will do a measured move from the origination to the destination
   i=0;
   for (i=0; i < 723.9000; i+=4.00000)  //we want to spin this thing until it reaches the X coordinates and y coordinates we want.
   //i / 2 = 360   
       {
        timecur = TimeCurrent();     
        ii=0;
        while (TimeCurrent()<timecur+sleep-i/2 && ii<70000.00001-i*1.655) ii++;  //we have a small pause between each movement
                                                                          //the pause gets smaller and smaller (ie substracted by increments of i       
        Sleep(500);
//at first we substract 0.17 / 720.  But eventually, we substract the whole 0.17.
        x1 = MathRound(0.660000*WindowBarsPerChart()-0.17000*WindowBarsPerChart()/720.00001*i);
        xx1= lomin+(himax-lomin)/7+(himax-lomin)*0.6/720.000001*i;



      //ObjectDelete("Vis1");
      //ObjectCreate("Vis1",OBJ_TEXT,0,Time[x1],xx1);//lomin+(himax+lomin)/10);
      //ObjectMove("Vis1",0,Time[x1],xx1);
      //ObjectSet("Vis1",OBJPROP_ANGLE, 720-i);      
      //ObjectSetText("Vis1","____________________________________________________________",10,"Arial",Blue); //start at the middle and move towards the final location 
      //ObjectSet("Vis1",OBJPROP_TIME1,  Time[x1]);
      //ObjectSet("Vis1",OBJPROP_PRICE1,  xx1);
      //This math has us starting at 0.66.  We substract 0.17 in 720 increments to eventually substract the whole 0.17, which ends us up in 0.5         
        x2 = MathRound(0.37*WindowBarsPerChart()+0.14*WindowBarsPerChart()/720.000001*i);                                                             
        xx2 = himax-(himax-lomin)/7-(himax-lomin)*0.72/720.000001*i;
      //ObjectDelete("Vis2");
      //ObjectCreate("Vis2",OBJ_TEXT,0,Time[x2],xx2);//himax-(himax+lomin)/10);  
        ObjectSet("Vis2",OBJPROP_ANGLE,  i/2);
        ObjectMove("Vis2",0,Time[x2],xx2);
      //ObjectSetText("Vis2","____________________________________________________________",10,"Arial",Red); 
      //ObjectSet("Vis2",OBJPROP_TIME1,  Time[x2]);
      //ObjectSet("Vis2",OBJPROP_PRICE1,  xx2);
                                          //we add .14 in 720 increments.  Eventually, as i approach 720, we add the whole 0.14 to make .51           
        x3 = MathRound(0.71*WindowBarsPerChart()-0.4*WindowBarsPerChart()/720.000001*i);  //eventually the secone term grows bigger until it becomes 0.4; so 0.71-.4 = 0.31 where we want it to end up
        xx3 = himax-(himax-lomin)/7-(himax-lomin)*0.72/720.0000001*i;
        int xxx3 = MathRound(39.00000-27.0000001/720.0000001*i);
      //ObjectDelete("Vis3");
      //ObjectCreate("Vis3",OBJ_TEXT,0,Time[x3],xx3);//himax-(himax+lomin)/7);
        ObjectMove("Vis3",0,Time[x3],xx3);
        ObjectSet("Vis3",OBJPROP_ANGLE,  i);
        ObjectSetText("Vis3","Visual",xxx3,"Arial",Purple);     
     // ObjectSet("Vis3",OBJPROP_TIME1,  Time[x3]);
     // ObjectSet("Vis3",OBJPROP_PRICE1,  xx3);        
        x4 = MathRound(0.31*WindowBarsPerChart()+0.4*WindowBarsPerChart()/720*i);
        xx4 = himax-(himax-lomin)/7-(himax-lomin)*0.72/720*i;
        int xxx4 = MathRound(44.000001-30.0000001/720.0000001*i);
      //ObjectDelete("Vis4");
      //ObjectCreate("Vis4",OBJ_TEXT,0,Time[x4],xx4);   
        ObjectMove("Vis4",0,Time[x4],xx4);
        ObjectSet("Vis4",OBJPROP_ANGLE, (720.0000000-i)/2);
        ObjectSetText("Vis4","Trader",xxx4,"Arial",Green);
        ObjectsRedraw();        
      //ObjectSet("Vis4",OBJPROP_TIME1,  Time[x4]);
      //ObjectSet("Vis4",OBJPROP_PRICE1,  xx4);  
        xx3=3000.00234/720.2342;  
        Comment("winmax",WindowPriceMax(0)," i ", i, " xx1 ", xx1, " xx2 ", xx2, " xx3 ", xx3, " xx4 ", xx4, " xxx3 ", xxx3, " xxx4 ",xxx4
                ,"mathround ", (45-(30.00000/720.000000*i)," 30/ ", (307.0000/777.00000))  );  
       }
*/
   //Now let's set the Horizontal Lines.  
   if (WindowFirstVisibleBar()>WindowBarsPerChart()) windowbars=WindowBarsPerChart();  //these are numbered with last bar being number 1.  If first visible bar is more than the # of bars per window, then the chart has been scrolled left.
   else windowbars=WindowFirstVisibleBar();  //if chart has not bee scrolled left, we can use the first visible bar
//----
   himax=WindowPriceMax(0);  //get the hi and low window price
   lomin=WindowPriceMin(0);
//----
   hi=High[iHighest(NULL,0,MODE_HIGH,windowbars*0.6,0)];
   lo=Low[iLowest(NULL,0,MODE_LOW,windowbars*0.6,0)];
//----
   hi5=High[iHighest(NULL,0,MODE_HIGH,15,0)];
   lo5=Low[iLowest(NULL,0,MODE_LOW,15,0)];
//----
   himax=WindowPriceMax(0);
   lomin=WindowPriceMin(0);
//----
   if (hi>himax) hi-=(hi+lo)/12;
   if (lo<lomin) lo+=(hi+lo)/12;
   if (hi<hi5) hi=hi5;  //if we moved the y parameter too close to the current price, then do it at the current price.
   if (lo>lo5) lo=lo5;  //if the scale is out of range, we just take the hi or low of the last 5 bars.
//----
   ObjectCreate("top",OBJ_HLINE,0,0,hi);
   ObjectSet("top",OBJPROP_COLOR,Blue);
   ObjectCreate("bottom",OBJ_HLINE,0,0,lo);
   ObjectSet("bottom",OBJPROP_COLOR,Red);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("top");
   ObjectDelete("bottom");
   ObjectDelete("Top Instruction");
   ObjectDelete("Bottom Instruction");
   ObjectDelete("Top Instruction2");
   ObjectDelete("Bottom Instruction2");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
/*
for (int akak =1 ; akak< 10; akak++)
     { 
      for(int kkkk=1; kkkk<500000; ) kkkk++;    
      Comment(akak); 
      PlaySound("Alert2.wav");
      kkkk=0;
     }
*/
   ObjectCreate("Top Instruction",OBJ_TEXT,0,Time[WindowBarsPerChart()/2],hi);
   ObjectSetText("Top Instruction","DBL click BLUE line to Move or Delete.",10,"Arial",DodgerBlue);
   // ObjectMove("Top Instruction",0,Time[55],hi+15*Point); 
   // ObjectSet("Top Instruction",OBJPROP_XDISTANCE,30);
   ObjectSet("Top Instruction",OBJPROP_ANGLE, i);
   if (i>3.9 || ii<-3.7) {i=-3.2; ii=3.4;}
   i +=0.1657;
   ii-=0.6;
   ObjectCreate("Bottom Instruction",OBJ_TEXT,0,Time[WindowBarsPerChart()/2],lo);
   ObjectSetText("Bottom Instruction","DBL click RED line to Move or Delete.",10,"Arial",DeepPink);
   // ObjectMove("Bottom Instruction",0,Time[37],lo+12*Point);
   // ObjectSet("Bottom Instruction",OBJPROP_XDISTANCE,30); 
   ObjectSet("Bottom Instruction",OBJPROP_ANGLE, ii);
   ObjectSet("top",OBJPROP_COLOR,Blue);
   ObjectSet("bottom",OBJPROP_COLOR,Red);
   //this gets the price of the blue and red lines
   top=ObjectGet("top",OBJPROP_PRICE1);
   bottom=ObjectGet ("bottom",OBJPROP_PRICE1);
   if(top!=hi)
     {
      hi +=0.002932498*Point;
      topS=(string)NormalizeDouble(top,Digits);
      //--Let's find the decimal point to the topS string.  (we do this so we can truncate the string to shave off the extra zeros after the decimal point
      i=0;
      while(StringGetChar(topS,i)!=46 && i<10) i++; //trying to find the decimal point in the topS string
      topS=StringSubstr(topS,0,i+Digits+1); //start extract the string from the first charater up to all the places behind the decimal
      if (TimeCurrent()>timeloc2)  //do this only if we are not in time lock
        {TopComment=   "Upper Alert set at: "+topS;
        }
      if (ObjectFind("top") !=0)//This is if the /blue horizontal line has been deleted.
        {
         top=9999999;
         TopComment="Top Alert=off (Blue line DELETED)."; //objfind returns the window in which the object resides.
        }
      ObjectDelete("Top Instruction");
      ObjectCreate("Top Instruction",OBJ_LABEL,0,TimeCurrent(),0);
      ObjectSetText("Top Instruction",TopComment,10,"Arial",SteelBlue);
      ObjectSet("Top Instruction",OBJPROP_YDISTANCE, 44);
      ObjectSet("Top Instruction",OBJPROP_XDISTANCE, 10);
     }
   if(bottom!=lo)
     {
      lo +=0.001228398*Point;
      bottomS=(string)NormalizeDouble(bottom,Digits);
      //--- The following is for trying to find the decimal point of the bottomS string
      i=0;
      while(StringGetChar(bottomS,i)!=46 && i <10) i++; //trying to find the decimal point in the topS string
      bottomS=StringSubstr(bottomS,0,i+Digits+1);  //start extract the string from the first charater (0) all the way to the last place behind the decimal
      //---
      if(TimeCurrent()>timeloc2)//DO THIS  only if we are not in lock out.
        {BottomComment="Lower Alert set at: "+bottomS;
        }
      if (ObjectFind("bottom") !=0)//this is if the Red line has been deleted.
        {
         bottom=-9999999;
         BottomComment="Bottom Alert=off (Red line DELETED).";//objectfind returns the window that object resides.
        }
      ObjectDelete("Bottom Instruction");
      ObjectCreate("Bottom Instruction",OBJ_LABEL,0,TimeCurrent(),0);
      ObjectSetText("Bottom Instruction",BottomComment,10,"Arial",Red);
      ObjectSet("Bottom Instruction",OBJPROP_YDISTANCE,61);
      ObjectSet("Bottom Instruction",OBJPROP_XDISTANCE,10);
     }
   //Comment("\ntop: ", top, " b ", bottom, " y ", blue_ydistance, " ", red_ydistance);   

   if (Close[0] >=NormalizeDouble(top,Digits)  &&  TimeCurrent() > timeloc  && Alert_on ==true)
     {
      timeloc2=TimeCurrent()+4.5; //this is a smaller lock out just for displaying the breech message           
      timeloc= TimeCurrent();  //done just for a slight pause
      if (Pop_Up_Box==False)
        {
         PlaySound("Alert2.wav");
         for(double asdfff =1;asdfff <1900.0239 ;) asdfff+=.91231; //a little pause
         while(TimeCurrent()<=timeloc) asdfff=0; //another little pause
         PlaySound("Alert.wav");
        }
      else {Alert("Upper Breech ", Symbol()," ",topS);}
      TopComment=topS+ " Breech!";
      ObjectSetText("Top Instruction",TopComment,12,"Arial",DodgerBlue);
      timeloc=TimeCurrent()+Time_Out;   //how many seconds do we lock out the Alert
     }
   if (Close[0] <=NormalizeDouble(bottom,Digits)  &&  TimeCurrent() > timeloc  && Alert_on ==true)
     {
      timeloc2=TimeCurrent()+4.5;//this is a smaller lock out just for displaying the breech message
      timeloc =TimeCurrent();   //just for a slight, unofficial pause
      if (Pop_Up_Box==False)
        {
         PlaySound("Alert.wav");
         for(double asdf =1;asdf <1200.0239 ;) asdf+=.91231; //a little pause
         while(TimeCurrent()<=timeloc) asdf=0; //another little pause
         PlaySound("Alert2.wav");
        }
      else {Alert("Lower Breech ",Symbol()," ",bottomS);}
      BottomComment =bottomS + " Breech!";
      ObjectSetText("Bottom Instruction",BottomComment,12,"Arial",Red);
      timeloc=TimeCurrent()+Time_Out;   //how many seconds do we lock out the Alert
     }
   // Comment("timecurrent() ",TimeToStr(TimeCurrent(),TIME_SECONDS)," Lockout, ",TimeToStr(timeloc2,TIME_SECONDS)  );
//----
   return(0);
  }
//+------------------------------------------------------------------+