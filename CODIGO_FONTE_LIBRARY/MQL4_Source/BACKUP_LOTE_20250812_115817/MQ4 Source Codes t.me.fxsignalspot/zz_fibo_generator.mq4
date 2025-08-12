//+------------------------------------------------------------------+
//|                                               fibo generator.mq4 |
//|                     Copyright © 20011, MetaQuotes Software Corp. |
//|                                        http://forex-shop.com/    |
//+------------------------------------------------------------------+

// automatic fibo generator
// based on fukinagashi work on moneytec.Com
// modified by nicogris

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int ExtDepth=21;
extern int ExtDeviation=13;
extern int ExtBackstep=34;
extern color FibColor1= Green;
extern color FibColor2= RoyalBlue;
extern color FibColor3= Gold;
//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
double posA,posB,posC,posD,posX;
double topA,botA,topB,botB,topC,botC,topD,botD,topX,botX;
double XA,AB,BC,CD;
double XAAB,ABBC,BCCD;
datetime TimeX,TimeA,TimeB,TimeC,TimeD,TS1,TS2,TS3,TT1,TT2,TT3;
double PS1,PT1,PS2,PT2,PS3,PT3;
double Fib1High,Fib1Low,Fib2High,Fib2Low,Fib3High,Fib3Low;
double level_array[13]={0,0.236,0.386,0.5,0.618,0.786,1,1.276,1.618,2.058,2.618,3.33,4.236};
string leveldesc_array[13]={"0","23.6%","38.6%","50%","61.8%","78.6%","100%","127.6%","161.8%","205.8%","261.80%","333%","423.6%"};
int level_count;
string level_name;
double text_y;

//TS1: time source of fibo1
//PS1: price source of fibo1
//TT1: time target of fibo1
//PT1: price target of fibo1
//etc...

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  { 
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- indicator short name
   IndicatorShortName("Fibodrawer");
//---- initialization done
   return(0);
  }
  
int deinit() 
{
	ObjectDelete("Fibo1");
	ObjectDelete("Fibo2");
	ObjectDelete("Fibo3");

   ObjectDelete("X");
   ObjectDelete("B");
   ObjectDelete("A");
   ObjectDelete("C");
   ObjectDelete("D");
  
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()


 


  { 
  
 
  
  
    double Points = MarketInfo (Symbol(), MODE_POINT);
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
         if(res!=0.0) ExtMapBuffer[shift]=res;
        }

     }
     
  	int i=0;
  	int LastZigZag, PreviousZigZag,PreviousZigZag2,PreviousZigZag3,PreviousZigZag4;
   
   int h=0;
   while ( ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) 
         {h++;}
   LastZigZag=h;
   h++;
   while(ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) 
         {h++;}
   PreviousZigZag=h;
   h++;
   while(ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) 
      {h++;}
   PreviousZigZag2=h;
   h++;
   while(ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) 
      {h++;}
   PreviousZigZag3=h;
   h++;
   while(ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) 
      {h++;}
   PreviousZigZag4=h;
   
 
   topD=High[LastZigZag];
   botD=Low[LastZigZag];
   topC=High[PreviousZigZag];
   botC=Low[PreviousZigZag];
   topB=High[PreviousZigZag2];
   botB=Low[PreviousZigZag2];
   topA=High[PreviousZigZag3];
   botA=Low[PreviousZigZag3];
   topX=High[PreviousZigZag4];
   botX=Low[PreviousZigZag4];
   TimeD=Time[LastZigZag];
   TimeC=Time[PreviousZigZag];
   TimeB=Time[PreviousZigZag2];
   TimeA=Time[PreviousZigZag3];
   TimeX=Time[PreviousZigZag4];
 if(topD>topC)// D IS A PEAK
      {//defining fib1 as CD retracement
         TS1=TimeC;
         PS1=botC;
         TT1=TimeD;
         PT1=topD;
         if (topB<topD)
         {//defining fib2 as BC retracement
            TS2=TimeB;
            PS2=topB;
            TT2=TimeC;
            PT2=botC;
         }
         if (topB>=topD)
         {//defining fib2 as BC extension
            TS2=TimeC;
            PS2=botC;
            TT2=TimeB;
            PT2=topB;
         }
         if (botA<=botC)
         {//defining fib3 as AB retracement
            TS3=TimeA;
            PS3=botA;
            TT3=TimeB;
            PT3=topB;
         }
      }
      
      if(botD<botC)// D IS A TROUGH
      {//defining fib1 as CD retracement
         TS1=TimeC;
         PS1=topC;
         TT1=TimeD;
         PT1=botD;
         if (botB<=botD)
         {//defining fib2 as BC retracement
            TS2=TimeB;
            PS2=botB;
            TT2=TimeC;
            PT2=topC;
         }
         if (botB>botD)
         {//defining fib2 as BC extension
            TS2=TimeC;
            PS2=topC;
            TT2=TimeB;
            PT2=botB;
         }
         //defining fib3 as AB retracement
            TS3=TimeA;
            PS3=topA;
            TT3=TimeB;
            PT3=botB;
         
      }    
      
      
      
      
  // CREATE X,A,B,C,D TEXTS
  if(botD<botC)// D IS A TROUGH
      {//Alert("cas 1");
      
      posD=botD;
      posC=topC+11*Points;
      posB=botB;
      posA=topA+11*Points;
      posX=botX;
      XA=(topA-botX)/Points;
      AB=(topA-botB)/Points;
      BC=(topC-botB)/Points;
      CD=(topC-botD)/Points;
      
     Comment("XA= ",XA," AB=",AB," BC=",BC," CD=",CD);
      }
  if(topD>topC)// D IS A PEAK
      {//Alert("cas 2");
      
      posD=topD;
      posC=botC;
      posB=topB;
      posA=botA;
      posX=topX;
      XA=(topX-botA)/Points;
      AB=(topB-botA)/Points;
      BC=(topB-botC)/Points;
      CD=(topD-botC)/Points;
      XAAB=AB/XA;
      ABBC=BC/AB;
      BCCD=CD/BC;
      Comment("XA= ",XA," AB=",AB," BC=",BC," CD=",CD," AB/XA=",XAAB," BC/AB=",ABBC," CD/BC=",BCCD);
      }   
  
   ObjectCreate("X", OBJ_TEXT, 0, Time[PreviousZigZag4],posX);  
   ObjectSetText("X", "X", 14, "Arial", Yellow); 
   ObjectCreate("A", OBJ_TEXT, 0, Time[PreviousZigZag3],posA);  
   ObjectSetText("A", "A", 14, "Arial", Yellow);
   ObjectCreate("B", OBJ_TEXT, 0, Time[PreviousZigZag2],posB);  
   ObjectSetText("B", "B", 14, "Arial", Yellow);
   ObjectCreate("C", OBJ_TEXT, 0, Time[PreviousZigZag],posC);  
   ObjectSetText("C", "C", 14, "Arial", Yellow);
   ObjectCreate("D", OBJ_TEXT, 0, Time[LastZigZag],posD);  
   ObjectSetText("D", "D", 14, "Arial", Yellow); 
   // END OF TEXT CREATION
   
  
        
     // START DRAWING FIBS
         ObjectCreate("Fibo1", OBJ_FIBO, 0,TS1,PS1,TT1,PT1);
   	   ObjectSet("Fibo1", OBJPROP_COLOR, White);
   	   ObjectSet("Fibo1", OBJPROP_STYLE, STYLE_SOLID);
         ObjectCreate("Fibo2", OBJ_FIBO, 0,TS2,PS2,TT2,PT2);
         ObjectSet("Fibo2", OBJPROP_COLOR, Yellow);
   	   ObjectSet("Fibo2", OBJPROP_STYLE, STYLE_SOLID);
   	   if (PS3>0)// if fib3 is defined 
   	     {  
   	        ObjectCreate("Fibo3", OBJ_FIBO, 0, TS3,PS3,TT3,PT3);
   	        ObjectSet("Fibo3", OBJPROP_COLOR, DodgerBlue);
   	        ObjectSet("Fibo3", OBJPROP_STYLE, STYLE_SOLID);
   	     }
   level_count=ArraySize(level_array);
   //Alert(level_count);
   
   ObjectSet("Fibo1", OBJPROP_FIBOLEVELS, level_count);
   ObjectSet("Fibo2", OBJPROP_FIBOLEVELS, level_count);
   ObjectSet("Fibo3", OBJPROP_FIBOLEVELS, level_count);
   
   for(int j=0; j<level_count; j++)
   {//Print(j," ",level_array[j]);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+j, level_array[j]);
   ObjectSetFiboDescription("Fibo1",j,leveldesc_array[j]);

   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+j, level_array[j]);
   ObjectSetFiboDescription("Fibo2",j,leveldesc_array[j]+"           ");
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+j, level_array[j]);
   ObjectSetFiboDescription("Fibo3",j,leveldesc_array[j]+"                      ");
   ObjectSet( "Fibo1", OBJPROP_LEVELCOLOR, FibColor1) ;
   ObjectSet( "Fibo2", OBJPROP_LEVELCOLOR, FibColor2) ;
   ObjectSet( "Fibo3", OBJPROP_LEVELCOLOR, FibColor3) ;
   /*level_name="essai"+j;
   text_y=PS1+(PT1-PS1)*level_array[j];
   //Print(level_array[j]," ",text_y);
   ObjectDelete(level_name);
   ObjectCreate(level_name, OBJ_TEXT, 0, Time[1],text_y);  
   ObjectSetText(level_name, leveldesc_array[j], 8, "Arial", Yellow);
   //FiboLC = FiboL + (FiboH - FiboL)*0.236;*/
   }
/*
   ObjectSet("Fibo1", OBJPROP_FIBOLEVELS, 11);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+0, 0);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+1, 0.236);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+2, 0.382);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+3, 0.5);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+4, 0.618);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+5, 0.786);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+6, 1);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+7, 1.276);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+8, 1.618);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+9, 2.058);
   ObjectSet("Fibo1", OBJPROP_FIRSTLEVEL+10, 261.8);
   
   ObjectSet("Fibo2", OBJPROP_FIBOLEVELS, 11);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+0, 0);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+1, 0.236);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+2, 0.382);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+3, 0.5);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+4, 0.618);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+5, 0.786);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+6, 1);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+7, 1.276);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+8, 1.618);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+9, 2.058);
   ObjectSet("Fibo2", OBJPROP_FIRSTLEVEL+10, 261.8);
   
   ObjectSet("Fibo3", OBJPROP_FIBOLEVELS, 11);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+0, 0);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+1, 0.236);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+2, 0.382);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+3, 0.5);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+4, 0.618);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+5, 0.786);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+6, 1);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+7, 1.276);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+8, 1.618);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+9, 2.058);
   ObjectSet("Fibo3", OBJPROP_FIRSTLEVEL+10, 261.8);
 */   

}
  
   