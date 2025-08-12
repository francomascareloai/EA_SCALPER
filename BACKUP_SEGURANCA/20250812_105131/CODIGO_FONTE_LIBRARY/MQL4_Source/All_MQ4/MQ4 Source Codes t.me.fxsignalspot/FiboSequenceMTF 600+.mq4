/*================================================================================
 Credit : Special thanks to "fising" & "Call Me..Bond" for sharing their 
          trading technic
 Author : Aiman
 
 How to use this indicator? :
   Just draw a trendline from High to Low or Low to High and then rename 
   that trendline to your TF, e.g M15
   
 If the market is slow, right click on chart and then click "Refresh" to 
 update the indicator.
 
 Magnet Setting :
   0 = Off
   1 = Close price    (to be used with line chart)
   2 = High/Low Price (to be used with candlesticks or bar chart)
 ================================================================================*/   
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrNONE



extern string MagnetSetting   = "0=OFF,1=Close,2=HiLo";
extern int    Magnet          = 2;
extern string TL_Name         = "Example use TF: H4,H1, M15,M5,";
extern string TLname          = "M15";
extern color boxcolor         = clrDarkSlateGray;
extern color labelcolor       = clrGray;

double _none[];

int init()
{
   SetIndexBuffer(0,_none);

return(0);
}

int deinit()
{
   for(int r=0;r<100;r++)
   for(int i=0;i<ObjectsTotal();i++)
       {
      if(ObjectName(i)==TLname) continue;
      if(StringSubstr(ObjectName(i),0,StringLen(TLname))==TLname)
        ObjectDelete(ObjectName(i));
   }
   Comment ("");
   return(0);
}
int start()
{
   
   
   string trend;
   double pips,seq=1;
   int shift1,shift2;
   datetime _start;
   
   if(ObjectFind(TLname)!=-1)
   {
      ObjectSet(TLname,OBJPROP_RAY,0);
      datetime time1 =ObjectGet(TLname,0);
      double price1  =ObjectGet(TLname,1);
      datetime time2 =ObjectGet(TLname,2);
      double price2  =ObjectGet(TLname,3);
   
      shift1=iBarShift(NULL,0,time1);
      shift2=iBarShift(NULL,0,time2);
      
      if (Magnet==1)
      {
         price1=iClose(NULL,0,shift1);
         price2=iClose(NULL,0,shift2);
      }
      
      if (Magnet==2)
      {
         if (price1>price2) trend="dt"; else trend="ut";
         
         if (trend=="dt") price1=iHigh(NULL,0,shift1); else price1=iLow(NULL,0,shift1);
         if (trend=="dt") price2=iLow(NULL,0,shift2);  else price2=iHigh(NULL,0,shift2);
      }
      
      ObjectSet(TLname,1,price1);
      ObjectSet(TLname,3,price2);
   
      int j;
      double k;
      
      if(time1<time2 && price1<price2) {trend="up";   j=shift2; k=price2;}
      if(time1<time2 && price1>price2) {trend="down"; j=shift2; k=price2;}
      if(time1>time2 && price1>price2) {trend="up";   j=shift1; k=price1;}
      if(time1>time2 && price1<price2) {trend="down"; j=shift1; k=price1;}
      
      pips=NormalizeDouble(MathAbs((price1-price2)/Point),0);
         
      while (seq<pips){seq=NormalizeDouble(seq*1.618,0);}
      double prevseq=NormalizeDouble(seq/1.618,0);
      
      if (MathAbs(seq-pips)>MathAbs(pips-prevseq)) seq=prevseq;
      
      double seqmin=NormalizeDouble(seq/1.618,0);
      double seqmax=NormalizeDouble(seqmin/1.618,0);
      double seqext=NormalizeDouble(seq*1.618,0);
      
      double target1,target2,target3;
      
      if(time1<time2 && trend=="up")
      {
         target1=price2-(seqmin*Point);
         target2=price2-(seqmax*Point);
         target3=price1+(seqext*Point);
      }
      if(time1>time2 && trend=="up")
      {
         target1=price1-(seqmin*Point);
         target2=price1-(seqmax*Point);
         target3=price2+(seqext*Point);
      }
      if(time1<time2 && trend=="down")
      {
         target1=price2+(seqmin*Point);
         target2=price2+(seqmax*Point);
         target3=price1-(seqext*Point);
      }
      if(time1>time2 && trend=="down")
      {
         target1=price1+(seqmin*Point);
         target2=price1+(seqmax*Point);
         target3=price2-(seqext*Point);
      }
      
      if (time1<time2) _start=time2; else _start=time1;
      
      
      drawLabel(TLname+"_Minimum" ,TLname +" Min Retracement "+DoubleToStr(seqmax,0)+ " ("+DoubleToStr(target2,Digits)+")",target2,labelcolor);
      drawLabel(TLname+"_Maximum" , TLname +" Max Retracement "+DoubleToStr(seqmin,0)+" ("+DoubleToStr(target1,Digits)+")",target1,labelcolor);
      drawLabel(TLname+"_Expansion" ,TLname + " Seq Projection "+DoubleToStr(seqext,0)+" ("+DoubleToStr(target3,Digits)+")",target3,labelcolor);
      drawRectang(TLname+"_RetracementBox" ,target1,target2,_start,boxcolor);
      drawLine(target3,TLname+"_Target3",_start,Teal);     
      
      //drawComment("Pips", "Total Pips = "+DoubleToStr(pips,0), 9, "Tahoma Bold", labelcolor, 2, 10, 25);
      drawComment(TLname+"_Sequence", "Nearest Fibo Sequence = "+DoubleToStr(seq,0), j, k, White); 
     
      
      drawLine2(target1, TLname+"_Target1", MediumSeaGreen, 0);
      //drawLabel("Minimum", "Minimum Retracement (" + DoubleToStr(seqmax, 0) + ")", target2, MediumSeaGreen);
      drawLine2(target2, TLname+"_Target2", DarkTurquoise, 0);
      //drawLabel("Maximum", "Maximum Retracement (" + DoubleToStr(seqmin, 0) + ")", target1, DarkTurquoise);
      drawLine2(target3, TLname+"_Target3", Teal, 0);
      //drawLabel("Expansion", "Expansion (" + DoubleToStr(seqext, 0) + ")", target3, Teal);
      Comment ("");
      
   }
   else
   {
      deinit();
      Comment ("Fibo Sequence - No \"TLname\" trendline on chart!");
      Comment(" 1. Draw a trendline from Hi to Lo or vise versa" 
         + "\n 2. Select the trendline, right click and then select \"Trendline Properties...\"" 
         + "\n 3. Under Common tab, in the name box, rename the trendline according to your TF, eg: \"M15 or H1\"" 
         + "\n 4. Indicator input, change TLname as per your TL properties\""
         + "\n 5. Click OK.");
   }
   
   WindowRedraw();
   return(0);
}


void drawLine2(double ad_0, string as_8, color ai_16, int ai_20) {
   if (ObjectFind(as_8) != -1) ObjectDelete(as_8);
   ObjectCreate(as_8, OBJ_HLINE, 0, Time[0], ad_0, Time[0], ad_0);
   if (ai_20 == 1) ObjectSet(as_8, OBJPROP_STYLE, STYLE_SOLID);
   else ObjectSet(as_8, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(as_8, OBJPROP_COLOR, ai_16);
   ObjectSet(as_8, OBJPROP_WIDTH, 1); }

void drawLine(double lvl,string name, datetime start, color Col)
{
   if(ObjectFind(name) != -1) ObjectDelete(name);
   ObjectCreate(name,2,0,start,lvl,Time[0],lvl);
   ObjectSet(name,7,0);
   ObjectSet(name,6,Col);        
   ObjectSet(name,8,2);
   ObjectSet(name,10,0);
}


void drawLabel(string name, string text, double lvl,color Color)
{
   if(ObjectFind(name) == -1)
   {
      ObjectCreate(name,21,0,Time[0],lvl);
      ObjectSetText(name,text,8,"Arial",EMPTY);
      ObjectSet(name,6,Color);
      
   }
   else 
   {
      ObjectMove(name,0,Time[0],lvl);
      ObjectSetText(name,text,8,"Arial",EMPTY);
   }
}

void drawComment (string id, string text,  int candle, double pos,color Color)
{
  /* ObjectCreate(id,23,0,0,0);
   ObjectSetText(id,text,size,fontstyle,colour);
   ObjectSet(id,101,corner);
   ObjectSet(id,9,1);
   ObjectSet(id,102,xpost);
   ObjectSet(id,103,ypost);  */
   
   if(ObjectFind(id) == -1)
   {
      ObjectCreate(id,21,0,Time[candle],pos);
      ObjectSetText(id,text,8,"Arial",EMPTY);
      ObjectSet(id,6,Color);
      
   }
   else 
   {
      ObjectMove(id,0,Time[candle],pos);
      ObjectSetText(id,text,8,"Arial",EMPTY);
   }
   
   
   
   
}


void drawRectang(string id, double price1, double price2, double start, color clr)
{
   if(ObjectFind(id) != -1) ObjectDelete(id);

   ObjectCreate(id,16,0,start,price1,Time[0],price2);
   ObjectSet(id,6,clr);
   ObjectSet(id,9,1);
   ObjectSet(id,8,2);
}


