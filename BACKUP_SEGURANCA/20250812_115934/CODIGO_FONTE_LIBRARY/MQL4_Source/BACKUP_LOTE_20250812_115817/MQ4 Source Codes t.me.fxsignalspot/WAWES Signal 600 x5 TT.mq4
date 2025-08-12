//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+                            http://cmillion.ru/                           +
//+--------------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////////////
/////////// 31.10.2015 - Tankk painted for http://forexsystemsru.com /////////
//////////////////////////////////////////////////////////////////////////////
#property copyright "Copyright © 2014, cmillion@narod.ru"
#property link      "http://cmillion.ru/"

#property  indicator_chart_window
#property  indicator_buffers 2
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern int channel     =  200;     ///12;   // width of "working channel" in paragraphs (a view with 5 characters after the decimal point)
extern int Q           =  4;       ///6;    // number of consecutive intersections of opposite sides of a "working channel"
extern int HistoryBar  =  1000;             // количество баров, используемых для построения канала

extern string Options__of__Lines  =  "Wawes Signal Lines";
extern ENUM_LINE_STYLE LinesStyle =  STYLE_DOT;
extern int             LinesSize  =  0;
extern color           Line1      =  DarkSlateBlue,
                       Line2      =  DarkOliveGreen;  ///DarkSlateGray;
extern int             FontSize   =  10;
extern color           FontColor  =  Gold;            ///LimeGreen;

extern string Options__of__Arrows =  "Wawes Signal Arrows";
extern color              ColorUP =  White,           //Blue /// DodgerBlue
                          ColorDN =  Red;             //Magenta   /// OrangeRed;

extern int             arrowsSize =  1,
                       arrowsUP   =  233, 
                       arrowsDN   =  234;
              
extern string  arrowsCodes_42_120_110_108_117_121  =  "139-149_171_172_174_181_203_85_86_91",
                _241_242_221_222_228_230_246_248   =  "233-234_225-226_217-218_236-238_74-76";


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double     SignalBufferRed[];
double     SignalBufferBlue[];
string PreName;
int init()
{
   PreName=WindowExpertName();
   SetIndexStyle(0,DRAW_ARROW,0,arrowsSize,ColorUP);
   SetIndexArrow(0,arrowsUP);
   SetIndexStyle(1,DRAW_ARROW,0,arrowsSize,ColorDN);
   SetIndexArrow(1,arrowsDN);

   SetIndexBuffer(0,SignalBufferBlue);
   SetIndexBuffer(1,SignalBufferRed);
   return(0);
}
int deinit()
{
   remove_objects(PreName);
   return(0);
}
//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+                            http://cmillion.ru/                           +
//+--------------------------------------------------------------------------+
int start()
{
   for(int j=HistoryBar; j>=0; j--)
   {
      bool NoSell=false,NoBuy=false;
      int q=0;
      int i=j;
      double GN[2][10];
      ArrayInitialize(GN,0);
      while (i<Bars)
      {
         i++;
         if (Low[i]<=Close[j]-channel*2*Point || High[i]>=Close[j]+channel*Point) NoBuy=true;
         if (Low[i]<=Close[j]-channel*Point || High[i]>=Close[j]+channel*2*Point) NoSell=true;
         if (NoBuy && NoSell) break;
         if (NoBuy)
         {
            if (High[i]>=Close[j]+channel*Point)
            {
               if (q==0 || q==2 || q==4 || q==6 || q==8 || q==10) {GN[0][q]=Time[i]; GN[1][q]=Close[j]+channel*Point; q++; i++;}
            }
            if (Low[i]<=Close[j])
            {
               if (q==1 || q==3 || q==5 || q==7 || q==9 || q==11) {GN[0][q]=Time[i]; GN[1][q]=Close[j]; q++; i++;}
            }
         }
         if (NoSell)
         {
            if (Low[i]<=Close[j]-channel*Point)
            {
               if (q==0 || q==2 || q==4 || q==6 || q==8 || q==10) {GN[0][q]=Time[i]; GN[1][q]=Close[j]-channel*Point; q++; i++;}
            }
            if (High[i]>=Close[j])
            {
               if (q==1 || q==3 || q==5 || q==7 || q==9 || q==11) {GN[0][q]=Time[i]; GN[1][q]=Close[j]; q++; i++;}
            }
         }
         if (q>=Q || q>10)
         {
            if (NoSell) SignalBufferBlue[j]=Close[j];
            if (NoBuy) SignalBufferRed[j]=Close[j];
            for (int n=0; n<q; n++) Text(StringConcatenate(n," ",TimeToStr(Time[j],TIME_DATE|TIME_MINUTES)), Red, GN[0][n], GN[1][n], n+1 ,0);
            Trend(StringConcatenate(TimeToStr(Time[j],TIME_DATE|TIME_MINUTES)," 1Channel"),Line1,GN[0][q-1],Close[j],Time[j],Close[j]);
            Trend(StringConcatenate(TimeToStr(Time[j],TIME_DATE|TIME_MINUTES)," 2Channel"),Line2,GN[0][q-1],GN[1][0],Time[j],GN[1][0]);
            break;
         }
      }
   }

   return(0);
  }
//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+--------------------------------------------------------------------------+
void Text(string name, color COLOR, datetime T1, double Price,string Name, int ANGLE)
{
   name=StringConcatenate(PreName,name);
   ObjectDelete(name);
   ObjectCreate(name, OBJ_TEXT,0,T1,Price,0,0,0,0);
   ObjectSet(name, OBJPROP_ANGLE, ANGLE);
   ObjectSetText(name, Name,FontSize, "Arial", FontColor);
}
//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+--------------------------------------------------------------------------+
void Trend(string name, color COLOR, datetime T1, double P1, datetime T2, double P2)
{
   name=StringConcatenate(PreName,name);
   ObjectDelete(name);
   ObjectCreate(name, OBJ_TREND,0,T1,P1,T2,P2,0,0);
   ObjectSet(name, OBJPROP_STYLE, LinesStyle);
   ObjectSet(name, OBJPROP_WIDTH, LinesSize);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, COLOR);
}
//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+--------------------------------------------------------------------------+
int remove_objects(string N)
{
   for(int k=ObjectsTotal()-1; k>=0; k--) 
   {
      string Obj_Name=ObjectName(k);
      string Head=StringSubstr(Obj_Name,0,StringLen(N));
 
      if (Head==N)
      {
         ObjectDelete(Obj_Name);
      }                  
   }
   Comment("");
   return(0);
}
//+--------------------------------------------------------------------------+
//+                   Copyright © 2014, Khlystov Vladimir                    +
//+                            http://cmillion.ru/                           +
//+--------------------------------------------------------------------------+
