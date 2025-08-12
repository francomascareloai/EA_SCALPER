//+------------------------------------------------------------------+
//|                                       IndicatorCrosslinesCCI.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width3 1
#property indicator_width4 1
extern int Timeframe=0;
extern int limit=610;
extern bool showlabels=false;
extern bool SR2=true;
extern int resvalue=-200;
extern int supvalue=200;
extern int period=13;
extern int applied_price=5;
extern int LineShift=1;
extern color resistanceColor=Red;
extern color supportColor=Lime;
extern int Labelsize=8;
extern int Linewidth=3;
extern bool calculateonbarclose=false;
extern bool showarrows=true;

                                                                                                             //
 double buyarrow[];
double sellarrow[];                                                                                          //
 double buyarrow2[];
double sellarrow2[];      
int periode;
string Symbolde;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
      IndicatorBuffers(4);
   SetIndexBuffer(0, buyarrow);
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(1, sellarrow);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(2, buyarrow2);
   SetIndexStyle(2, DRAW_ARROW, EMPTY);
   SetIndexArrow(2, 233);
   SetIndexBuffer(3, sellarrow2);
   SetIndexStyle(3, DRAW_ARROW, EMPTY);
   SetIndexArrow(3, 234);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     for (int i = ObjectsTotal()-1; i>=0; i--) 
    {
     string tmp = ObjectName(i);
     if (StringFind(tmp,"Resistance") >= 0) ObjectDelete(tmp);
     if (StringFind(tmp,"Support") >= 0) ObjectDelete(tmp);
    }
   return(0);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
     int    counted_bars=IndicatorCounted(),i,z,b,drawresend=0,drawsupend=0;
   double indicatorvalue[];   
   ArrayResize(indicatorvalue,limit);
   double reshigh=0;
   double suplow=0;
   bool calculateit=false;
//----
if(calculateonbarclose)
{
   if(NewBar()||Period()!=periode||Symbol()!=Symbolde)
   {
      calculateit=true;     
      periode=Period();
      Symbolde=Symbol();
   }
   else
   calculateit=false;
}
else
calculateit=true;


if(calculateit)
{
   for(i=limit;i>=0;i--)
   {
      indicatorvalue[i]=iCCI(NULL,Timeframe,period,applied_price,iBarShift(NULL,Timeframe,iTime(NULL,0,i)));
      if(i<(limit))
      {
         if(indicatorvalue[i+1]>resvalue&&indicatorvalue[i+0]<resvalue)
         {
            drawresend=Resistbars(i+LineShift);
            if(ObjectFind("Resistance"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {
            DrawRes(drawresend,i);
            

            reshigh=iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,i+LineShift)));
            }
            else
            ObjectSet("Resistance"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_TIME2,iTime(NULL,0,drawresend));
            if(showarrows)
            sellarrow[i]=High[i]+0.4*iATR(NULL,0,14,i);
            else
            sellarrow[i]=EMPTY_VALUE;

            
         }
         else
         sellarrow[i]=EMPTY_VALUE;
         
         if(indicatorvalue[i+1]>resvalue&&indicatorvalue[i+0]>resvalue)
         {
            if(ObjectFind("Resistance"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {            
               ObjectDelete("Resistance"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
               
               ObjectDelete("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
            }
         }
         
         if(showlabels&&(iBarShift(NULL,Timeframe,iTime(NULL,0,i))-iBarShift(NULL,Timeframe,iTime(NULL,0,drawresend)))>3)
         {
         if(ObjectFind("Resistance"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
         {
            if(ObjectFind("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {
            ObjectCreate("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJ_TEXT,0,Time[drawresend+4],reshigh);
            ObjectSetText("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,"CCIRes"+"("+period+")"+"_"+Timeframe);
            ObjectSet("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,resistanceColor); 
            ObjectSet("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_FONTSIZE,Labelsize);
            }
            else
            ObjectMove("Resistance"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,1,Time[drawresend+4],reshigh);
         }         
         }
         if(indicatorvalue[i+1]<supvalue&&indicatorvalue[i]>supvalue)
         {
            drawsupend=Supportbars(i+LineShift);
            if(ObjectFind("Support"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {

            DrawSup(drawsupend,i);
            suplow=iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,i+LineShift)));
            }
            else
            ObjectSet("Support"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_TIME2,iTime(NULL,0,drawsupend));
            
            if(showarrows)            
            buyarrow[i]=Low[i]-0.2*iATR(NULL,0,14,i);
            else
            buyarrow[i]=EMPTY_VALUE;
            

            
         } 
         else
         buyarrow[i]=EMPTY_VALUE;
         if(indicatorvalue[i+1]<supvalue&&indicatorvalue[i+0]<supvalue)
         {
            if(ObjectFind("Support"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {            
               ObjectDelete("Support"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
               ObjectDelete("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
            }
         }   
         
         if(showlabels&&(iBarShift(NULL,Timeframe,iTime(NULL,0,i))-iBarShift(NULL,Timeframe,iTime(NULL,0,drawsupend)))>3)
            {
                        if(ObjectFind("Support"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {
               if(ObjectFind("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
               {
               ObjectCreate("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJ_TEXT,0,Time[drawsupend+4],suplow);
               ObjectSetText("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,"CCISup"+"("+period+")"+"_"+Timeframe);
               ObjectSet("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,supportColor);
               ObjectSet("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_FONTSIZE,Labelsize);
               }
               else
               ObjectMove("Support"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,1,Time[drawsupend+4],suplow);
            }     
         }

          
     if(SR2)
     {
         if(indicatorvalue[i+1]>supvalue&&indicatorvalue[i+0]<supvalue)
         {
            drawresend=Resistbars(i+LineShift);
            if(ObjectFind("Resistance2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {
            DrawRes2(drawresend,i);
            

            reshigh=iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,i+LineShift)));
            }
            else
            ObjectSet("Resistance2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_TIME2,iTime(NULL,0,drawresend));
            if(showarrows)
            {
            sellarrow[i]=High[i]+0.4*iATR(NULL,0,14,i);
            Print(sellarrow2[i]+" "+TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));
            }
            else
            sellarrow2[i]=EMPTY_VALUE;

            
         }
         else
         sellarrow2[i]=EMPTY_VALUE;
         
         if(indicatorvalue[i+1]>supvalue&&indicatorvalue[i+0]>supvalue)
         {
            if(ObjectFind("Resistance2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {            
               ObjectDelete("Resistance2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
               
               ObjectDelete("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
            }
         }
         
         if(showlabels&&(iBarShift(NULL,Timeframe,iTime(NULL,0,i))-iBarShift(NULL,Timeframe,iTime(NULL,0,drawresend)))>3)
         {
         if(ObjectFind("Resistance2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
         {
            if(ObjectFind("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {
            ObjectCreate("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJ_TEXT,0,Time[drawresend+4],reshigh);
            ObjectSetText("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,"CCIRes"+"("+period+")"+"_"+Timeframe);
            ObjectSet("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,resistanceColor); 
            ObjectSet("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_FONTSIZE,Labelsize);
            }
            else
            ObjectMove("Resistance2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,1,Time[drawresend+4],reshigh);
         }         
         }


         if(indicatorvalue[i+1]<resvalue&&indicatorvalue[i]>resvalue)
         {
            drawsupend=Supportbars(i+LineShift);
            if(ObjectFind("Support2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
            {

            DrawSup2(drawsupend,i);
            suplow=iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,i+LineShift)));
            }
            else
            ObjectSet("Support2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_TIME2,iTime(NULL,0,drawsupend));
            
            if(showarrows)            
            buyarrow2[i]=Low[i]-0.2*iATR(NULL,0,14,i);
            else
            buyarrow2[i]=EMPTY_VALUE;
            

            
         } 
         else
         buyarrow2[i]=EMPTY_VALUE;
         if(indicatorvalue[i+1]<resvalue&&indicatorvalue[i+0]<resvalue)
         {
            if(ObjectFind("Support2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {            
               ObjectDelete("Support2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
               ObjectDelete("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue);
            }
         }   
         
         if(showlabels&&(iBarShift(NULL,Timeframe,iTime(NULL,0,i))-iBarShift(NULL,Timeframe,iTime(NULL,0,drawsupend)))>3)
         {
                        if(ObjectFind("Support2"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)!=-1)
            {
               if(ObjectFind("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue)==-1)
               {
               ObjectCreate("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJ_TEXT,0,Time[drawsupend+4],suplow);
               ObjectSetText("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,"CCISup"+"("+period+")"+"_"+Timeframe);
               ObjectSet("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,supportColor);
               ObjectSet("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,OBJPROP_FONTSIZE,Labelsize);
               }
               else
               ObjectMove("Support2"+"label"+"CCI"+period+Time[i]+Timeframe+resvalue+supvalue,1,Time[drawsupend+4],suplow);
            }     
         }

         
         
         }
         
                   
          
               

         
         
      }
      
   }
            
}   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int Resistbars(int Shift)
 {
     int rbars=0;
     for(int xi=Shift-1;xi>=0;xi--)
     {
         if(iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,Shift)))<High[xi])
         {
         rbars=xi; xi=0;
         }
         else
         rbars=xi;
     }           
     return(rbars);
 }
 
int Supportbars(int Shift)
 {
     int rbars=0;
     for(int xi=Shift-1;xi>=0;xi--)
     {
         if(iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,Shift)))>Low[xi])
         {
         rbars=xi; xi=0;
         }
         else
         rbars=xi;
     }           
     
     return(rbars);
 }
 bool NewBar()

{

   static datetime lastbar;

   datetime curbar = Time[0];

   if(lastbar!=curbar)

   {

      lastbar=curbar;

      return (true);

   }

   else return(false);

}
  
  
  
void DrawRes(int drawiresend,int resi)
{
            
            ObjectCreate("Resistance"+"CCI"+period+Time[resi]+Timeframe+resvalue+supvalue,OBJ_TREND,0,iTime(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi+LineShift))),iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi+LineShift))),iTime(NULL,0,drawiresend),iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi+LineShift))));
            ObjectSet("Resistance"+"CCI"+period+Time[resi]+Timeframe+resvalue+supvalue,OBJPROP_RAY,false);
            ObjectSet("Resistance"+"CCI"+period+Time[resi]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,resistanceColor);
            ObjectSet("Resistance"+"CCI"+period+Time[resi]+Timeframe+resvalue+supvalue,OBJPROP_WIDTH,Linewidth);
            return(0);
}
void DrawRes2(int drawiresend2,int resi2)
{
            
            ObjectCreate("Resistance2"+"CCI"+period+Time[resi2]+Timeframe+resvalue+supvalue,OBJ_TREND,0,iTime(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi2+LineShift))),iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi2+LineShift))),iTime(NULL,0,drawiresend2),iHigh(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,resi2+LineShift))));
            ObjectSet("Resistance2"+"CCI"+period+Time[resi2]+Timeframe+resvalue+supvalue,OBJPROP_RAY,false);
            ObjectSet("Resistance2"+"CCI"+period+Time[resi2]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,resistanceColor);
            ObjectSet("Resistance2"+"CCI"+period+Time[resi2]+Timeframe+resvalue+supvalue,OBJPROP_WIDTH,Linewidth);
            return(0);
}
void DrawSup(int drawisupend,int supi)
{
            
            ObjectCreate("Support"+"CCI"+period+Time[supi]+Timeframe+resvalue+supvalue,OBJ_TREND,0,iTime(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi+LineShift))),iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi+LineShift))),iTime(NULL,0,drawisupend),iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi+LineShift))));
            ObjectSet("Support"+"CCI"+period+Time[supi]+Timeframe+resvalue+supvalue,OBJPROP_RAY,false);
            ObjectSet("Support"+"CCI"+period+Time[supi]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,supportColor);
            ObjectSet("Support"+"CCI"+period+Time[supi]+Timeframe+resvalue+supvalue,OBJPROP_WIDTH,Linewidth);
            return(0);
}
void DrawSup2(int drawisupend2,int supi2)
{
            
            ObjectCreate("Support2"+"CCI"+period+Time[supi2]+Timeframe+resvalue+supvalue,OBJ_TREND,0,iTime(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi2+LineShift))),iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi2+LineShift))),iTime(NULL,0,drawisupend2),iLow(NULL,Timeframe,iBarShift(NULL,Timeframe,iTime(NULL,0,supi2+LineShift))));
            ObjectSet("Support2"+"CCI"+period+Time[supi2]+Timeframe+resvalue+supvalue,OBJPROP_RAY,false);
            ObjectSet("Support2"+"CCI"+period+Time[supi2]+Timeframe+resvalue+supvalue,OBJPROP_COLOR,supportColor);
            ObjectSet("Support2"+"CCI"+period+Time[supi2]+Timeframe+resvalue+supvalue,OBJPROP_WIDTH,Linewidth);
            return(0);
}
  
  