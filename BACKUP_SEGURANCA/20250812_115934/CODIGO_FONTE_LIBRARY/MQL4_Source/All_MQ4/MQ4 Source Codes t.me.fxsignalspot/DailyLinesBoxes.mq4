//+------------------------------------------------------------------+
//|                                             Daily LinesBoxes.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window

#import "kernel32.dll"
  void OutputDebugStringA(string msg);
#import

extern int      LookbackDays        = 20;
extern double   StartHours          = -1;
extern double   EndHours            = 6;
extern double   ExtendHours         = 23;
extern string   UniqueID            = "DLB#1";
extern color    BoxColor            = C'0,64,0';
extern color    LineColor           = Green;
extern string   Properties          = "FTH2";
extern string   TextProperties      = "Arial,9,White,4,7";
extern string   SymbolProperties    = "2,White,108,10";
extern string   DaysOfWeek          = "Mon,Tue,Wed,Thu,Fri";
extern string   Visibility          = "M1,M5,M15,M30,H1,H4";
extern string   TimeFrame           = "M5";
extern bool     CandlesMustExist    = false;
extern double   ClearancePips       = 0;
extern int      RefreshEveryXMins   = 1;

int tscale;

datetime prev_time;
string   sym, arr[5];
double   pnt;
int      dig;

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+

  if (RefreshEveryXMins > 240)                             RefreshEveryXMins = 240;
  if (RefreshEveryXMins > 60 && RefreshEveryXMins < 240)   RefreshEveryXMins = 60;
  if (RefreshEveryXMins > 30 && RefreshEveryXMins < 60)    RefreshEveryXMins = 30;
  if (RefreshEveryXMins > 15 && RefreshEveryXMins < 30)    RefreshEveryXMins = 15;
  if (RefreshEveryXMins > 5  && RefreshEveryXMins < 15)    RefreshEveryXMins = 5;
  if (RefreshEveryXMins > 1  && RefreshEveryXMins < 5)     RefreshEveryXMins = 1;

  prev_time = -9999;
  del_obj();
  plot_obj();
  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  del_obj();
  return(0);
}


//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  sym = Symbol();
  if (RefreshEveryXMins < 0)
    return(0);
  if (RefreshEveryXMins == 0) {
    del_obj();
    plot_obj();    
  }
  else {
    if(prev_time != iTime(sym,RefreshEveryXMins,0))  {
      del_obj();
      plot_obj();
      prev_time = iTime(sym,RefreshEveryXMins,0);
  } }      
  return(0);
}

//+------------------------------------------------------------------+
void del_obj()  {
//+------------------------------------------------------------------+
  int k=0;
  while (k<ObjectsTotal())   {
    string objname = ObjectName(k);
    if (StringSubstr(objname,0,StringLen(UniqueID)) == UniqueID)  
      ObjectDelete(objname);
    else
      k++;
  }    
  return(0);
}

//+------------------------------------------------------------------+
void plot_obj()  {
//+------------------------------------------------------------------+
  if (TimeFrame == "")
    tscale = Period();
  else  
    tscale = StrToTF(TimeFrame);
  sym = Symbol();
  pnt = MarketInfo(sym,MODE_POINT);
  dig = MarketInfo(sym,MODE_DIGITS);
  if (dig == 3 || dig == 5) {
    pnt *= 10;
  }  

  DaysOfWeek = StringUpper(DaysOfWeek) + ",";
  Visibility = StringUpper(Visibility) + ",";
  string test_vis[9] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
  int vis = 0, inc = 1;
  for (int i=0; i<9; i++)  {
    if (StringFind(Visibility,test_vis[i]+",") >= 0)    vis+=inc;
    inc*=2;
  }  

  datetime tc  = TimeCurrent();
  for (i=0; i<LookbackDays; i++)   {
    int shifted = tc-i*86400;      
    if (shifted < Time[Bars-1])    break;
    if (StringFind(DaysOfWeek,StringUpper(DateToStr(shifted,"w"))+",") < 0)  continue;
    datetime dt1  = StrToTime(DateToStr(shifted,"Y.M.D")) + 3600 * StartHours;
    datetime dt2  = StrToTime(DateToStr(shifted,"Y.M.D")) + 3600 * EndHours;
    datetime dt3  = StrToTime(DateToStr(shifted,"Y.M.D")) + 3600 * ExtendHours;

    int exist1 = iBarShift(NULL,tscale,dt1,true);
//    if (exist1 >= 0 && Time[exist1] != dt1)   exist1 = -1;
    int exist2 = iBarShift(NULL,tscale,dt2,true);
//    if (exist2 >= 0 && Time[exist2] != dt1)   exist2 = -1;
    int exist3 = iBarShift(NULL,tscale,dt3,true);
//    if (exist3 >= 0 && Time[exist3] != dt1)   exist3 = -1;

    double   hi = 0, lo = 999999; 
    double   hivol = 0, lovol = 999999, vol = 0;
    double   hirng = 0, lorng = 999999, rng = 0;
    double   hivtr = 0, lovtr = 999999, vtr = 0;
    double   hivdr = 0, lovdr = 999999, vdr = 0;
    int      bar1 = iBarShift(NULL,tscale,dt1,false);
    int      bar2 = iBarShift(NULL,tscale,dt2,false);
    for (int j=bar1; j>bar2; j--)  {
      hi = MathMax(hi,iHigh(NULL,tscale,j));
      lo = MathMin(lo,iLow(NULL,tscale,j));
      double range    = iHigh(NULL,tscale,j) - iLow(NULL,tscale,j);
      double vtrtmp   = range * iVolume(NULL,tscale,j);
      double vdrtmp   = DivZero(iVolume(NULL,tscale,j), range);
      if (range > rng)    { rng = range;    hirng = iHigh(NULL,tscale,j);    lorng = iLow(NULL,tscale,j);  }  
      if (vtrtmp > vtr)   { vtr = vtrtmp;   hivtr = iHigh(NULL,tscale,j);    lovtr = iLow(NULL,tscale,j);  }  
      if (vdrtmp > vdr)   { vdr = vdrtmp;   hivdr = iHigh(NULL,tscale,j);    lovdr = iLow(NULL,tscale,j);  }
      if (iVolume(NULL,tscale,j) > vol)  {  vol = iVolume(NULL,tscale,j);    hivol = iHigh(NULL,tscale,j);    lovol = iLow(NULL,tscale,j);  } 
    }
    string prop = StringUpper(Properties); 
    if (StringFind(prop,"E",0) >= 0)  { hi = hivol;   lo = lovol;  }  else
    if (StringFind(prop,"R",0) >= 0)  { hi = hirng;   lo = lorng;  }  else
    if (StringFind(prop,"M",0) >= 0)  { hi = hivtr;   lo = lovtr;  }  else
    if (StringFind(prop,"D",0) >= 0)  { hi = hivdr;   lo = lovdr;  }  
    hi += ClearancePips * pnt;  
    lo -= ClearancePips * pnt;
    int width = StrToNumber(Properties);  
    int style = STYLE_SOLID;             
    if (StringFind(prop,"-..",0) >= 0)   style = STYLE_DASHDOTDOT;   else
    if (StringFind(prop,"-.",0) >= 0)    style = STYLE_DASHDOT;      else
    if (StringFind(prop,".",0) >= 0)     style = STYLE_DOT;          else
    if (StringFind(prop,"--",0) >= 0)    style = STYLE_DASH;

    if (StringFind(prop,"<",0) >= 0)     hi    = iOpen(NULL,tscale,bar1);
    if (StringFind(prop,">",0) >= 0)     lo    = iOpen(NULL,tscale,bar1);
    
    // Plot box.......
    if (StringFind(prop,"F",0) >= 0  ||  StringFind(prop,"B",0) >= 0  ||  StringFind(prop,"T",0) >= 0)  {
      string objname = UniqueID+"-"+i+"-r";
      if (StringFind(prop,"T",0) >= 0)  {
        datetime dt4 = dt2;
        int exist4 = exist2;
      }  else  {
        dt4 = dt3;
        exist4 = exist3;
      }  
      if (!CandlesMustExist  ||  (exist1 >= 0 && exist4 >= 0))   {
        ObjectCreate(objname,OBJ_RECTANGLE,0,dt1,hi,dt4,lo);
        ObjectSet(objname,OBJPROP_COLOR,BoxColor);            
        ObjectSet(objname,OBJPROP_BACK,false);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);               
        if (StringFind(prop,"F",0) >= 0)    ObjectSet(objname,OBJPROP_BACK,true);
        if (StringFind(prop,"P",0) >= 0)    ObjectSetText(objname,DoubleToStr((hi-lo)/pnt,0));
    } }  

    // Plot horizontal lines..........
    if (StringFind(prop,"H",0) >= 0)  {
      if (!CandlesMustExist  ||  (exist1 >= 0 && exist3 >= 0))   {
        objname = UniqueID+"-"+i+"-hi";
        ObjectCreate(objname,OBJ_TREND,0,dt1,hi,dt3,hi); 
        ObjectSet(objname,OBJPROP_RAY,0);
        if (StringFind(prop,"X",0) >= 0)    ObjectSet(objname,OBJPROP_RAY,true); 
        ObjectSet(objname,OBJPROP_COLOR,LineColor);
        ObjectSet(objname,OBJPROP_WIDTH,width);
        ObjectSet(objname,OBJPROP_STYLE,style);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
        objname = UniqueID+"-"+i+"-lo";
        ObjectCreate(objname,OBJ_TREND,0,dt1,lo,dt3,lo); 
        ObjectSet(objname,OBJPROP_RAY,0);
        if (StringFind(prop,"X",0) >= 0)    ObjectSet(objname,OBJPROP_RAY,true);  
        ObjectSet(objname,OBJPROP_COLOR,LineColor);
        ObjectSet(objname,OBJPROP_WIDTH,width);
        ObjectSet(objname,OBJPROP_STYLE,style);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
    } } 
    
    if (StringFind(prop,"C",0) >= 0)  {
      if (!CandlesMustExist  ||  (exist1 >= 0 && exist3 >= 0))   {
        objname = UniqueID+"-"+i+"-cl";
        double price = iClose(NULL,tscale,bar1);
        ObjectCreate(objname,OBJ_TREND,0,dt1,price,dt3,price); 
        ObjectSet(objname,OBJPROP_RAY,0);
        if (StringFind(prop,"X",0) >= 0)    ObjectSet(objname,OBJPROP_RAY,true); 
        ObjectSet(objname,OBJPROP_COLOR,LineColor);
        ObjectSet(objname,OBJPROP_WIDTH,width);
        ObjectSet(objname,OBJPROP_STYLE,style);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
    } } 

    if (StringFind(prop,"O",0) >= 0)  {
      if (!CandlesMustExist  ||  (exist1 >= 0 && exist3 >= 0))   {
        objname = UniqueID+"-"+i+"-op";
        price = iOpen(NULL,tscale,bar1);
        ObjectCreate(objname,OBJ_TREND,0,dt1,price,dt3,price); 
        ObjectSet(objname,OBJPROP_RAY,0);
        if (StringFind(prop,"X",0) >= 0)    ObjectSet(objname,OBJPROP_RAY,true); 
        ObjectSet(objname,OBJPROP_COLOR,LineColor);
        ObjectSet(objname,OBJPROP_WIDTH,width);
        ObjectSet(objname,OBJPROP_STYLE,style);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
    } } 

    // Plot vertical lines.......
    if (StringFind(prop,"V",0) >= 0)  { 
      if (!CandlesMustExist  ||  exist1 >= 0)   {
        objname = UniqueID+"-"+i+"-va";
        ObjectCreate(objname,OBJ_VLINE,0,dt1,0);
        ObjectSet(objname,OBJPROP_COLOR,LineColor);
        ObjectSet(objname,OBJPROP_WIDTH,width);
        ObjectSet(objname,OBJPROP_STYLE,style);
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
        if (StringFind(prop,"^",0) >= 0)    ObjectSet(objname,OBJPROP_BACK,true);
      }  
      if (StringFind(prop,"VV",0) >= 0)  {
        if (!CandlesMustExist  ||  exist3 >= 0)   {
          objname = UniqueID+"-"+i+"-vb";
          ObjectCreate(objname,OBJ_VLINE,0,dt3,0); 
          ObjectSet(objname,OBJPROP_COLOR,LineColor);
          ObjectSet(objname,OBJPROP_WIDTH,width);
          ObjectSet(objname,OBJPROP_STYLE,style);
          ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
          if (StringFind(prop,"^",0) >= 0)    ObjectSet(objname,OBJPROP_BACK,true);
    } } }
    // Display box height......
    if (TextProperties > "")    {
      StrToStringArray(TextProperties,arr);
      double prc = StrToNumber(arr[3]);
      prc = (hi+prc*pnt)*(prc>=0) + (lo+prc*pnt)*(prc<0);
      objname = UniqueID+"-"+i+"-t";
      ObjectCreate(objname,OBJ_TEXT,0,dt1,prc);
      ObjectSetText(objname,NumberToStr((hi-lo)/pnt,arr[4]),StrToInteger(arr[1]),arr[0],StrToColor(arr[2])); 
    }
    // Display Wingdings symbol......
    if (StringFind(prop,"W",0) >= 0 && SymbolProperties > "")  {
      if (!CandlesMustExist  ||  exist1 >= 0)   {
        int bar     = iBarShift(NULL,0,dt1,true); 
        double high = iHigh(NULL,0,bar); 
        double low  = iLow(NULL,0,bar); 
        StrToStringArray(SymbolProperties,arr);
        prc = StrToNumber(arr[3]);
        prc = (high+prc*pnt)*(prc>=0) + (low+prc*pnt)*(prc<0);
        objname = UniqueID+"-"+i+"-wa";
        ObjectCreate(objname,OBJ_ARROW,0,dt1,prc); 
        ObjectSet(objname,OBJPROP_ARROWCODE,StrToInteger(arr[2]));
        ObjectSet(objname,OBJPROP_COLOR,StrToColor(arr[1]));
        ObjectSet(objname,OBJPROP_WIDTH,StrToInteger(arr[0]));
        ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
      }
      if (StringFind(prop,"WW",0) >= 0 && SymbolProperties > "")  { 
        if (!CandlesMustExist  ||  exist3 >= 0)   {
          bar  = iBarShift(NULL,0,dt3,true); 
          high = iHigh(NULL,0,bar); 
          low  = iLow(NULL,0,bar); 
          prc  = StrToNumber(arr[3]);
          prc  = (high+prc*pnt)*(prc>=0) + (low+prc*pnt)*(prc<0);
          objname = UniqueID+"-"+i+"-wb";
          ObjectCreate(objname,OBJ_ARROW,0,dt3,prc); 
          ObjectSet(objname,OBJPROP_ARROWCODE,StrToInteger(arr[2]));
          ObjectSet(objname,OBJPROP_COLOR,StrToColor(arr[1]));
          ObjectSet(objname,OBJPROP_WIDTH,StrToInteger(arr[0]));
          ObjectSet(objname,OBJPROP_TIMEFRAMES,vis);
  } } } }
  return(0);
}


//===========================================================================
//                            FUNCTIONS LIBRARY
//===========================================================================


//+------------------------------------------------------------------+
void log(string s1, string s2="", string s3="", string s4="", string s5="", string s6="", string s7="", string s8="")   {
//+------------------------------------------------------------------+
   string out = StringTrimRight(StringConcatenate(WindowExpertName(), ".mq4 ", Symbol(), " ", s1, " ", s2, " ", s3, " ", s4, " ", s5, " ", s6, " ", s7, " ", s8));
   OutputDebugStringA(out);
}

//+------------------------------------------------------------------+
int BarConvert(int bar, string FromTF, string ToTF, string ccy="")   {
//+------------------------------------------------------------------+
// Usage: returns bar# on ToTF that matches same time of bar# on FromTF
// e.g. bar = BarConvert(40,"M15","H4",Symbol());
//   will find the bar# on H4 chart whose time matches bar# 40 on M15 chart
  if (ccy == "")  ccy = Symbol();
  return(iBarShift(ccy,StrToTF(ToTF),iTime(ccy,StrToTF(FromTF),bar)));
}  


//+------------------------------------------------------------------+
int StrToColor(string str)
//+------------------------------------------------------------------+
// Returns the numeric value for an MQL4 color descriptor string
// Usage:   int x = StrToColor("Aqua")      returns x = 16776960
// or:      int x = StrToColor("0,255,255") returns x = 16776960
// i.e.             StrToColor("<red>,<green>,<blue>")
// or:      int x = StrToColor("0xFFFF00")  returns x = 16776960
// i.e.             StrToColor("0xbbggrr")
// or:      int x = StrToColor("r0g255b255")  returns x = 16776960
// i.e.             StrToColor("r<nnn>g<nnn>b<nnn>")
{
  str = StringLower(str);
  if (str == "aliceblue")              return(0xFFF8F0);
  if (str == "antiquewhite")           return(0xD7EBFA);
  if (str == "aqua")                   return(0xFFFF00);
  if (str == "aquamarine")             return(0xD4FF7F);
  if (str == "beige")                  return(0xDCF5F5);
  if (str == "bisque")                 return(0xC4E4FF);
  if (str == "black")                  return(0x000000);
  if (str == "blanchedalmond")         return(0xCDEBFF);
  if (str == "blue")                   return(0xFF0000);
  if (str == "blueviolet")             return(0xE22B8A);
  if (str == "brown")                  return(0x2A2AA5);
  if (str == "burlywood")              return(0x87B8DE);
  if (str == "cadetblue")              return(0xA09E5F);
  if (str == "chartreuse")             return(0x00FF7F);
  if (str == "chocolate")              return(0x1E69D2);
  if (str == "coral")                  return(0x507FFF);
  if (str == "cornflowerblue")         return(0xED9564);
  if (str == "cornsilk")               return(0xDCF8FF);
  if (str == "crimson")                return(0x3C14DC);
  if (str == "darkblue")               return(0x8B0000);
  if (str == "darkgoldenrod")          return(0x0B86B8);
  if (str == "darkgray")               return(0xA9A9A9);
  if (str == "darkgreen")              return(0x006400);
  if (str == "darkkhaki")              return(0x6BB7BD);
  if (str == "darkolivegreen")         return(0x2F6B55);
  if (str == "darkorange")             return(0x008CFF);
  if (str == "darkorchid")             return(0xCC3299);
  if (str == "darksalmon")             return(0x7A96E9);
  if (str == "darkseagreen")           return(0x8BBC8F);
  if (str == "darkslateblue")          return(0x8B3D48);
  if (str == "darkslategray")          return(0x4F4F2F);
  if (str == "darkturquoise")          return(0xD1CE00);
  if (str == "darkviolet")             return(0xD30094);
  if (str == "deeppink")               return(0x9314FF);
  if (str == "deepskyblue")            return(0xFFBF00);
  if (str == "dimgray")                return(0x696969);
  if (str == "dodgerblue")             return(0xFF901E);
  if (str == "firebrick")              return(0x2222B2);
  if (str == "forestgreen")            return(0x228B22);
  if (str == "gainsboro")              return(0xDCDCDC);
  if (str == "gold")                   return(0x00D7FF);
  if (str == "goldenrod")              return(0x20A5DA);
  if (str == "gray")                   return(0x808080);
  if (str == "green")                  return(0x008000);
  if (str == "greenyellow")            return(0x2FFFAD);
  if (str == "honeydew")               return(0xF0FFF0);
  if (str == "hotpink")                return(0xB469FF);
  if (str == "indianred")              return(0x5C5CCD);
  if (str == "indigo")                 return(0x82004B);
  if (str == "ivory")                  return(0xF0FFFF);
  if (str == "khaki")                  return(0x8CE6F0);
  if (str == "lavender")               return(0xFAE6E6);
  if (str == "lavenderblush")          return(0xF5F0FF);
  if (str == "lawngreen")              return(0x00FC7C);
  if (str == "lemonchiffon")           return(0xCDFAFF);
  if (str == "lightblue")              return(0xE6D8AD);
  if (str == "lightcoral")             return(0x8080F0);
  if (str == "lightcyan")              return(0xFFFFE0);
  if (str == "lightgoldenrod")         return(0xD2FAFA);
  if (str == "lightgray")              return(0xD3D3D3);
  if (str == "lightgreen")             return(0x90EE90);
  if (str == "lightpink")              return(0xC1B6FF);
  if (str == "lightsalmon")            return(0x7AA0FF);
  if (str == "lightseagreen")          return(0xAAB220);
  if (str == "lightskyblue")           return(0xFACE87);
  if (str == "lightslategray")         return(0x998877);
  if (str == "lightsteelblue")         return(0xDEC4B0);
  if (str == "lightyellow")            return(0xE0FFFF);
  if (str == "lime")                   return(0x00FF00);
  if (str == "limegreen")              return(0x32CD32);
  if (str == "linen")                  return(0xE6F0FA);
  if (str == "magenta")                return(0xFF00FF);
  if (str == "maroon")                 return(0x000080);
  if (str == "mediumaquamarine")       return(0xAACD66);
  if (str == "mediumblue")             return(0xCD0000);
  if (str == "mediumorchid")           return(0xD355BA);
  if (str == "mediumpurple")           return(0xDB7093);
  if (str == "mediumseagreen")         return(0x71B33C);
  if (str == "mediumslateblue")        return(0xEE687B);
  if (str == "mediumspringgreen")      return(0x9AFA00);
  if (str == "mediumturquoise")        return(0xCCD148);
  if (str == "mediumvioletred")        return(0x8515C7);
  if (str == "midnightblue")           return(0x701919);
  if (str == "mintcream")              return(0xFAFFF5);
  if (str == "mistyrose")              return(0xE1E4FF);
  if (str == "moccasin")               return(0xB5E4FF);
  if (str == "navajowhite")            return(0xADDEFF);
  if (str == "navy")                   return(0x800000);
  if (str == "none")                   return(C'0x00,0x00,0x00');
  if (str == "oldlace")                return(0xE6F5FD);
  if (str == "olive")                  return(0x008080);
  if (str == "olivedrab")              return(0x238E6B);
  if (str == "orange")                 return(0x00A5FF);
  if (str == "orangered")              return(0x0045FF);
  if (str == "orchid")                 return(0xD670DA);
  if (str == "palegoldenrod")          return(0xAAE8EE);
  if (str == "palegreen")              return(0x98FB98);
  if (str == "paleturquoise")          return(0xEEEEAF);
  if (str == "palevioletred")          return(0x9370DB);
  if (str == "papayawhip")             return(0xD5EFFF);
  if (str == "peachpuff")              return(0xB9DAFF);
  if (str == "peru")                   return(0x3F85CD);
  if (str == "pink")                   return(0xCBC0FF);
  if (str == "plum")                   return(0xDDA0DD);
  if (str == "powderblue")             return(0xE6E0B0);
  if (str == "purple")                 return(0x800080);
  if (str == "red")                    return(0x0000FF);
  if (str == "rosybrown")              return(0x8F8FBC);
  if (str == "royalblue")              return(0xE16941);
  if (str == "saddlebrown")            return(0x13458B);
  if (str == "salmon")                 return(0x7280FA);
  if (str == "sandybrown")             return(0x60A4F4);
  if (str == "seagreen")               return(0x578B2E);
  if (str == "seashell")               return(0xEEF5FF);
  if (str == "sienna")                 return(0x2D52A0);
  if (str == "silver")                 return(0xC0C0C0);
  if (str == "skyblue")                return(0xEBCE87);
  if (str == "slateblue")              return(0xCD5A6A);
  if (str == "slategray")              return(0x908070);
  if (str == "snow")                   return(0xFAFAFF);
  if (str == "springgreen")            return(0x7FFF00);
  if (str == "steelblue")              return(0xB48246);
  if (str == "tan")                    return(0x8CB4D2);
  if (str == "teal")                   return(0x808000);
  if (str == "thistle")                return(0xD8BFD8);
  if (str == "tomato")                 return(0x4763FF);
  if (str == "turquoise")              return(0xD0E040);
  if (str == "violet")                 return(0xEE82EE);
  if (str == "wheat")                  return(0xB3DEF5);
  if (str == "white")                  return(0xFFFFFF);
  if (str == "whitesmoke")             return(0xF5F5F5);
  if (str == "yellow")                 return(0x00FFFF);
  if (str == "yellowgreen")            return(0x32CD9A);

  int t1 = StringFind(str,",",0);
  int t2 = StringFind(str,",",t1+1);
  if (t1>0 && t2>0) {
    int red   = StrToInteger(StringSubstr(str,0,t1));
    int green = StrToInteger(StringSubstr(str,t1+1,t2-1));
    int blue  = StrToInteger(StringSubstr(str,t2+1,StringLen(str)));
    return(blue*256*256+green*256+red);
  }  

  if (StringSubstr(str,0,2) == "0x")  {
    string cnvstr = "0123456789abcdef";
    string seq    = "234567";
    int    retval = 0;
    for(int i=0; i<6; i++)  {
      int pos = StrToInteger(StringSubstr(seq,i,1));
      int val = StringFind(cnvstr,StringSubstr(str,pos,1),0);
      if (val < 0)  return(val);
      retval = retval * 16 + val;
    }
    return(retval);
  }

  string cclr = "", tmp = "";
  red = 0;
  blue = 0;
  green = 0;
  if (StringFind("rgb",StringSubstr(str,0,1)) >= 0)  {
    for(i=0; i<StringLen(str); i++)  {
      tmp = StringSubstr(str,i,1);
      if (StringFind("rgb",tmp,0) >= 0)
        cclr = tmp;
      else {
        if (cclr == "b")  blue  = blue  * 10 + StrToInteger(tmp);
        if (cclr == "g")  green = green * 10 + StrToInteger(tmp);
        if (cclr == "r")  red   = red   * 10 + StrToInteger(tmp);
    } }  
    return(blue*256*256+green*256+red);
  }    

  return(0);
}  

//+------------------------------------------------------------------+
bool StrToBool(string str)
//+------------------------------------------------------------------+
{
  str = StringLower(StringSubstr(str,0,1));
  if (str == "t" || str == "y" || str == "1")   return(true);
  return(false);
}  

//+------------------------------------------------------------------+
string BoolToStr(bool bval)
//+------------------------------------------------------------------+
// Converts the boolean value true or false to the string "true" or "false" 
{
  if (bval)   return("true");
  return("false");
}  

//+------------------------------------------------------------------+
int StrToTF(string str)
//+------------------------------------------------------------------+
// Converts a timeframe string to its MT4-numeric value
// Usage:   int x=StrToTF("M15")   returns x=15
{
  str = StringUpper(str);
  if (str == "M1")   return(1);
  if (str == "M5")   return(5);
  if (str == "M15")  return(15);
  if (str == "M30")  return(30);
  if (str == "H1")   return(60);
  if (str == "H4")   return(240);
  if (str == "D1")   return(1440);
  if (str == "W1")   return(10080);
  if (str == "MN")   return(43200);
  return(0);
}  

//+------------------------------------------------------------------+
string TFToStr(int tf)
//+------------------------------------------------------------------+
// Converts a MT4-numeric timeframe to its descriptor string
// Usage:   string s=TFToStr(15) returns s="M15"
{
  switch (tf)  {
    case     1 :  return("M1");
    case     5 :  return("M5");
    case    15 :  return("M15");
    case    30 :  return("M30");
    case    60 :  return("H1");
    case   240 :  return("H4");
    case  1440 :  return("D1");
    case 10080 :  return("W1");
    case 43200 :  return("MN");
  }  
  return("");
}  

//+------------------------------------------------------------------+
string err_msg(int e)
//+------------------------------------------------------------------+
// Returns error message text for a given MQL4 error number
// Usage:   string s=err_msg(146) returns s="Error 0146:  Trade context is busy."
{
  switch (e)   {
    case 0:     return("Error 0000:  No error returned.");
    case 1:     return("Error 0001:  No error returned, but the result is unknown.");
    case 2:     return("Error 0002:  Common error.");
    case 3:     return("Error 0003:  Invalid trade parameters.");
    case 4:     return("Error 0004:  Trade server is busy.");
    case 5:     return("Error 0005:  Old version of the client terminal.");
    case 6:     return("Error 0006:  No connection with trade server.");
    case 7:     return("Error 0007:  Not enough rights.");
    case 8:     return("Error 0008:  Too frequent requests.");
    case 9:     return("Error 0009:  Malfunctional trade operation.");
    case 64:    return("Error 0064:  Account disabled.");
    case 65:    return("Error 0065:  Invalid account.");
    case 128:   return("Error 0128:  Trade timeout.");
    case 129:   return("Error 0129:  Invalid price.");
    case 130:   return("Error 0130:  Invalid stops.");
    case 131:   return("Error 0131:  Invalid trade volume.");
    case 132:   return("Error 0132:  Market is closed.");
    case 133:   return("Error 0133:  Trade is disabled.");
    case 134:   return("Error 0134:  Not enough money.");
    case 135:   return("Error 0135:  Price changed.");
    case 136:   return("Error 0136:  Off quotes.");
    case 137:   return("Error 0137:  Broker is busy.");
    case 138:   return("Error 0138:  Requote.");
    case 139:   return("Error 0139:  Order is locked.");
    case 140:   return("Error 0140:  Long positions only allowed.");
    case 141:   return("Error 0141:  Too many requests.");
    case 145:   return("Error 0145:  Modification denied because order too close to market.");
    case 146:   return("Error 0146:  Trade context is busy.");
    case 147:   return("Error 0147:  Expirations are denied by broker.");
    case 148:   return("Error 0148:  The amount of open and pending orders has reached the limit set by the broker.");
    case 4000:  return("Error 4000:  No error.");
    case 4001:  return("Error 4001:  Wrong function pointer.");
    case 4002:  return("Error 4002:  Array index is out of range.");
    case 4003:  return("Error 4003:  No memory for function call stack.");
    case 4004:  return("Error 4004:  Recursive stack overflow.");
    case 4005:  return("Error 4005:  Not enough stack for parameter.");
    case 4006:  return("Error 4006:  No memory for parameter string.");
    case 4007:  return("Error 4007:  No memory for temp string.");
    case 4008:  return("Error 4008:  Not initialized string.");
    case 4009:  return("Error 4009:  Not initialized string in array.");
    case 4010:  return("Error 4010:  No memory for array string.");
    case 4011:  return("Error 4011:  Too long string.");
    case 4012:  return("Error 4012:  Remainder from zero divide.");
    case 4013:  return("Error 4013:  Zero divide.");
    case 4014:  return("Error 4014:  Unknown command.");
    case 4015:  return("Error 4015:  Wrong jump (never generated error).");
    case 4016:  return("Error 4016:  Not initialized array.");
    case 4017:  return("Error 4017:  DLL calls are not allowed.");
    case 4018:  return("Error 4018:  Cannot load library.");
    case 4019:  return("Error 4019:  Cannot call function.");
    case 4020:  return("Error 4020:  Expert function calls are not allowed.");
    case 4021:  return("Error 4021:  Not enough memory for temp string returned from function.");
    case 4022:  return("Error 4022:  System is busy (never generated error).");
    case 4050:  return("Error 4050:  Invalid function parameters count.");
    case 4051:  return("Error 4051:  Invalid function parameter value.");
    case 4052:  return("Error 4052:  String function internal error.");
    case 4053:  return("Error 4053:  Some array error.");
    case 4054:  return("Error 4054:  Incorrect series array using.");
    case 4055:  return("Error 4055:  Custom indicator error.");
    case 4056:  return("Error 4056:  Arrays are incompatible.");
    case 4057:  return("Error 4057:  Global variables processing error.");
    case 4058:  return("Error 4058:  Global variable not found.");
    case 4059:  return("Error 4059:  Function is not allowed in testing mode.");
    case 4060:  return("Error 4060:  Function is not confirmed.");
    case 4061:  return("Error 4061:  Send mail error.");
    case 4062:  return("Error 4062:  String parameter expected.");
    case 4063:  return("Error 4063:  Integer parameter expected.");
    case 4064:  return("Error 4064:  Double parameter expected.");
    case 4065:  return("Error 4065:  Array as parameter expected.");
    case 4066:  return("Error 4066:  Requested history data in updating state.");
    case 4067:  return("Error 4067:  Some error in trading function.");
    case 4099:  return("Error 4099:  End of file.");
    case 4100:  return("Error 4100:  Some file error.");
    case 4101:  return("Error 4101:  Wrong file name.");
    case 4102:  return("Error 4102:  Too many opened files.");
    case 4103:  return("Error 4103:  Cannot open file.");
    case 4104:  return("Error 4104:  Incompatible access to a file.");
    case 4105:  return("Error 4105:  No order selected.");
    case 4106:  return("Error 4106:  Unknown symbol.");
    case 4107:  return("Error 4107:  Invalid price.");
    case 4108:  return("Error 4108:  Invalid ticket.");
    case 4109:  return("Error 4109:  Trade is not allowed. Enable checkbox 'Allow live trading' in the expert properties.");
    case 4110:  return("Error 4110:  Longs are not allowed. Check the expert properties.");
    case 4111:  return("Error 4111:  Shorts are not allowed. Check the expert properties.");
    case 4200:  return("Error 4200:  Object exists already.");
    case 4201:  return("Error 4201:  Unknown object property.");
    case 4202:  return("Error 4202:  Object does not exist.");
    case 4203:  return("Error 4203:  Unknown object type.");
    case 4204:  return("Error 4204:  No object name.");
    case 4205:  return("Error 4205:  Object coordinates error.");
    case 4206:  return("Error 4206:  No specified subwindow.");
    case 4207:  return("Error 4207:  Some error in object function.");
//    case 9001:  return("Error 9001:  Cannot close entire order - insufficient volume previously open.");
//    case 9002:  return("Error 9002:  Incorrect net position.");
//    case 9003:  return("Error 9003:  Orders not completed correctly - details in log file.");
    default:    return("Error " + e + ": ??? Unknown error.");
  }   
  return(0);   
}

//+------------------------------------------------------------------+
string StringLeft(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the leftmost N characters of STR, if N is positive
// Usage:    string x=StringLeft("ABCDEFG",2)  returns x = "AB"
//
// Returns all but the rightmost N characters of STR, if N is negative
// Usage:    string x=StringLeft("ABCDEFG",-2)  returns x = "ABCDE"
{
  if (n > 0)  return(StringSubstr(str,0,n));
  if (n < 0)  return(StringSubstr(str,0,StringLen(str)+n));
  return("");
}

//+------------------------------------------------------------------+
string StringRight(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the rightmost N characters of STR, if N is positive
// Usage:    string x=StringRight("ABCDEFG",2)  returns x = "FG"
//
// Returns all but the leftmost N characters of STR, if N is negative
// Usage:    string x=StringRight("ABCDEFG",-2)  returns x = "CDEFG"
{
  if (n > 0)  return(StringSubstr(str,StringLen(str)-n,n));
  if (n < 0)  return(StringSubstr(str,-n,StringLen(str)-n));
  return("");
}

//+------------------------------------------------------------------+
string StringLeftPad(string str, int n=1, string str2=" ")
//+------------------------------------------------------------------+
// Prepends occurrences of the string STR2 to the string STR to make a string N characters long
// Usage:    string x=StringLeftPad("ABCDEFG",9," ")  returns x = "  ABCDEFG"
{
  return(StringRepeat(str2,n-StringLen(str)) + str);
}

//+------------------------------------------------------------------+
string StringRightPad(string str, int n=1, string str2=" ")
//+------------------------------------------------------------------+
// Appends occurrences of the string STR2 to the string STR to make a string N characters long
// Usage:    string x=StringRightPad("ABCDEFG",9," ")  returns x = "ABCDEFG  "
{
  return(str + StringRepeat(str2,n-StringLen(str)));
}

//+------------------------------------------------------------------+
string StringReverse(string str)
//+------------------------------------------------------------------+
{
  string outstr = "";
  for (int i=StringLen(str)-1; i>=0; i--)
    outstr = outstr + StringSubstr(str,i,1);
  return(outstr);
}

//+------------------------------------------------------------------+
string StringLeftExtract(string str, int n, string str2, int m)
//+------------------------------------------------------------------+
{
  if (n > 0)   {
    int j = -1;
    for(int i=1; i<=n; i++)  j=StringFind(str,str2,j+1);
    if (j > 0)   return(StringLeft(str,j+m));
  } 
  if (n < 0)   {
    int c = 0;
    j = 0;
    for (i=StringLen(str)-1; i>=0; i--)  {
      if (StringSubstr(str,i,StringLen(str2)) == str2)  {
        c++;
        if (c==-n)  {
          j = i;
          break;
    } } }
    if (j > 0)   return(StringLeft(str,j+m));
  }      
  return("");
}

//+------------------------------------------------------------------+
string StringRightExtract(string str, int n, string str2, int m)
//+------------------------------------------------------------------+
{
  if (n > 0)   {
    int j = -1;
    for(int i=1; i<=n; i++)  j=StringFind(str,str2,j+1);
    if (j > 0)   return(StringRight(str,StringLen(str)-j-1+m));
  } 
  if (n < 0)   {
    int c = 0;
    j = 0;
    for (i=StringLen(str)-1; i>=0; i--)  {
      if (StringSubstr(str,i,StringLen(str2)) == str2)  {
        c++;
        if (c==-n)  {
          j = i;
          break;
    } } }
    if (j > 0)   return(StringRight(str,StringLen(str)-j-1+m));
  }      
  return("");
}

//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
{
  int c = 0;
  for (int i=0; i<StringLen(str); i++)
    if (StringSubstr(str,i,StringLen(str2)) == str2)  c++;
  return(c);
}

/*
//+------------------------------------------------------------------+
string StringReplace(string str, int n, string str2, string str3)
//+------------------------------------------------------------------+
// Replaces the Nth occurrence of STR2 in STR with STR3, working from left to right, if N is positive
// Usage:   string s = StringReplace("ABCDEFGHIJKABACABB",2,"AB","XYZ")   returns s = "ABCDEFGHIJKXYZACABB"
//
// Replaces the Nth occurrence of STR2 in STR with STR3, working from right to left, if N is negative
// Usage:   string s = StringReplace("ABCDEFGHIJKABACABB",-1,"AB","XYZ")   returns s = "ABCDEFGHIJKABACXYZB"
//
// Replaces all occurrence of STR2 in STR with STR3, if N is 0
// Usage:   string s = StringReplace("ABCDEFGHIJKABACABB",0,"AB","XYZ")   returns s = "XYZCDEFGHIJKXYZACXYZB"
{

  return("");
}
*/

//+------------------------------------------------------------------+
string StringRightTrim(string str)
//+------------------------------------------------------------------+
// Removes all trailing spaces from a string
// Usage:    string x=StringRightTrim("  XX YY  ")  returns x = "  XX  YY"
{
  int pos = 0;
  for(int i=StringLen(str)-1; i>=0; i--)  {
    if (StringSubstr(str,i,1) != " ")   {
      pos = i;
      break;
  } }
  string outstr = StringSubstr(str,0,pos+1);
  return(outstr);
}

//+------------------------------------------------------------------+
string ExpandCcy(string str)
//+------------------------------------------------------------------+
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) < 1 || StringLen(str) > 2)   return(str);
  string str2 = "";
  for (int i=0; i<StringLen(str); i++)   {
    string char = StringSubstr(str,i,1);
    if (char == "A")  str2 = str2 + "AUD";     else
    if (char == "C")  str2 = str2 + "CAD";     else   
    if (char == "E")  str2 = str2 + "EUR";     else   
    if (char == "F")  str2 = str2 + "CHF";     else   
    if (char == "G")  str2 = str2 + "GBP";     else   
    if (char == "J")  str2 = str2 + "JPY";     else   
    if (char == "N")  str2 = str2 + "NZD";     else   
    if (char == "U")  str2 = str2 + "USD";     else   
    if (char == "H")  str2 = str2 + "HKD";     else   
    if (char == "S")  str2 = str2 + "SGD";     else   
    if (char == "Z")  str2 = str2 + "ZAR";   
  }  
  return(str2);
}

//+------------------------------------------------------------------+
double MathInt(double n, int d=0)
//+------------------------------------------------------------------+
 {
   return(MathFloor(n*MathPow(10,d)+0.000000000001)/MathPow(10,d));
 }  

//+------------------------------------------------------------------+
string  DateToStr(datetime mt4date, string mask="")   {
//+------------------------------------------------------------------+
// Special characters in mask are replaced as follows:
//   Y = 4 digit year
//   y = 2 digit year
//   M = 2 digit month
//   m = 1-2 digit Month
//   N = full month name, e.g. November
//   n = 3 char month name, e.g. Nov
//   D = 2 digit day of Month
//   d = 1-2 digit day of Month
//   T or t = append 'th' to day of month, e.g. 14th, 23rd, etc
//   W = full weekday name, e.g. Tuesday
//   w = 3 char weekday name, e.g. Tue
//   H = 2 digit hour (defaults to 24-hour time unless 'a' or 'A' included)
//   h = 1-2 digit hour (defaults to 24-hour time unless 'a' or 'A' included)
//   a = convert to 12-hour time and append lowercase am/pm
//   A = convert to 12-hour time and append uppercase AM/PM
//   I or i = minutes in the hour
//   S or s = seconds in the minute
//   
//   All other characters in the mask are output 'as is'
//   You can output reserved characters 'as is', by preceding them with an exclamation Point
//    e.g. DateToStr(StrToTime("2010.07.30"),"(!D=DT N)") results in output: (D=30th July)
//   
// You can also embed any text inside single quotes at the far left, or far right, of the mask:
//    e.g. DateToStr(StrToTime("2010.07.30"),"'xxx'w D n Y'yyy'") results in output: xxxFri 30 Jul 2010yyy

  string ltext = "", rtext = "";
  if (StringSubstr(mask,0,1) == "'")   {
    for (int k1=1; k1<StringLen(mask); k1++)   {
      if (StringSubstr(mask,k1,1) == "'")   break;
        ltext = ltext + StringSubstr(mask,k1,1);
    }
    mask = StringSubstr(mask,k1+1);
  }
  if (StringSubstr(mask,StringLen(mask)-1,1) == "'")   {
    for (int k2=StringLen(mask)-2; k2>=0; k2--)   {
      if (StringSubstr(mask,k2,1) == "'")   break;
        rtext = StringSubstr(mask,k2,1) + rtext;
    } 
    mask = StringSubstr(mask,0,k2);
  }

  if (mask == "")   mask = "Y.M.D H:I:S";

  string mth[12] = {"January","February","March","April","May","June","July","August","September","October","November","December"};
  string dow[7]  = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};

  int dd  = TimeDay(mt4date);
  int mm  = TimeMonth(mt4date);
  int yy  = TimeYear(mt4date);
  int dw  = TimeDayOfWeek(mt4date);
  int hr  = TimeHour(mt4date);
  int min = TimeMinute(mt4date);
  int sec = TimeSeconds(mt4date);

  bool h12f = false;
  if (StringFind(StringUpper(mask),"A",0) >= 0)   h12f = true; 
  int h12 = 12;
  if (hr > 12)  h12 = hr - 12;   else
  if (hr > 0)   h12 = hr;
  string ampm = "am";
  if (hr > 12)
    ampm = "pm";

  switch (MathMod(dd,10))   {
    case 1  : string d10 = "st";   break;
    case 2  :        d10 = "nd";   break;
    case 3  :        d10 = "rd";   break;
    default :        d10 = "th";   break;
  }  
  if (dd > 10 && dd < 14)  d10 = "th";

  string outdate = "";
  for(int i=0; i<StringLen(mask); i++)   {
    string char = StringSubstr(mask,i,1);
    if (char == "!")  {
      outdate = outdate + StringSubstr(mask,i+1,1);
      i++;
      continue;
    }  
    if (char ==  "d")               outdate = outdate + StringTrim(NumberToStr(dd,"2"));     else
    if (char ==  "D")               outdate = outdate + StringTrim(NumberToStr(dd,"Z2"));    else
    if (char ==  "m")               outdate = outdate + StringTrim(NumberToStr(mm,"2"));     else
    if (char ==  "M")               outdate = outdate + StringTrim(NumberToStr(mm,"Z2"));    else
    if (char ==  "y")               outdate = outdate + StringTrim(NumberToStr(yy,"2"));     else
    if (char ==  "Y")               outdate = outdate + StringTrim(NumberToStr(yy,"4"));     else
    if (char ==  "n")               outdate = outdate + StringSubstr(mth[mm-1],0,3);         else
    if (char ==  "N")               outdate = outdate + mth[mm-1];                           else
    if (char ==  "w")               outdate = outdate + StringSubstr(dow[dw],0,3);           else
    if (char ==  "W")               outdate = outdate + dow[dw];                             else
    if (char ==  "h" && h12f)       outdate = outdate + StringTrim(NumberToStr(h12,"2"));    else
    if (char ==  "H" && h12f)       outdate = outdate + StringTrim(NumberToStr(h12,"Z2"));   else
    if (char ==  "h" && !h12f)      outdate = outdate + StringTrim(NumberToStr(hr,"2"));     else
    if (char ==  "H" && !h12f)      outdate = outdate + StringTrim(NumberToStr(hr,"Z2"));    else
    if (char ==  "i")               outdate = outdate + StringTrim(NumberToStr(min,"2"));    else
    if (char ==  "I")               outdate = outdate + StringTrim(NumberToStr(min,"Z2"));   else
    if (char ==  "s")               outdate = outdate + StringTrim(NumberToStr(sec,"2"));    else
    if (char ==  "S")               outdate = outdate + StringTrim(NumberToStr(sec,"Z2"));   else
    if (char ==  "a")               outdate = outdate + ampm;                                else
    if (char ==  "A")               outdate = outdate + StringUpper(ampm);                   else
    if (StringUpper(char) ==  "T")  outdate = outdate + d10;                                 else
    outdate = outdate + char;
  }
  return(ltext+outdate+rtext);
}

//+------------------------------------------------------------------+
string NumberToStr(double n, string mask="")
//+------------------------------------------------------------------+
// Formats a number using a mask, and returns the resulting string
// Usage:    string result = NumberToStr(number,mask)
// 
// Mask parameters:
// n = number of digits to output, to the left of the decimal point
// n.d = output n digits to left of decimal point; d digits to the right
// -n.d = floating minus sign at left of output
// n.d- = minus sign at right of output
// +n.d = floating plus/minus sign at left of output
//
// These characters may appear anywhere in the string:
//   ( or ) = enclose negative number in parentheses
//   $ or £ or ¥ or € = include floating currency symbol at left of output
//   % = include trailing % sign
//   , = use commas to separate thousands, millions, etc
//   Z or z = left fill with zeros instead of spaces
//   * = left fill with asterisks instead of spaces
//   R or r = round result in rightmost displayed digit
//   B or b = blank entire field if number is 0
//   ~ = show tilde in leftmost position if overflow occurs
//   ; = switch use of comma and period (European format)
//   L or l = left align final string 
//   T ot t = trim (remove all spaces from) end result

{

  if (MathAbs(n) == 2147483647)
    n = 0;

  string ltext = "", rtext = "";
  if (StringSubstr(mask,0,1) == "'")   {
    for (int k1=1; k1<StringLen(mask); k1++)   {
      if (StringSubstr(mask,k1,1) == "'")   break;
        ltext = ltext + StringSubstr(mask,k1,1);
    }
    mask = StringSubstr(mask,k1+1);
  }
  if (StringSubstr(mask,StringLen(mask)-1,1) == "'")   {
    for (int k2=StringLen(mask)-2; k2>=0; k2--)   {
      if (StringSubstr(mask,k2,1) == "'")   break;
        rtext = StringSubstr(mask,k2,1) + rtext;
    } 
    mask = StringSubstr(mask,0,k2);
  }

  if (mask == "")   mask = "TR-9.2";

  mask = StringUpper(mask);
  int dotadj = 0;
  int dot    = StringFind(mask,".",0);
  if (dot < 0)  {
    dot    = StringLen(mask);
    dotadj = 1;
  }  

  int nleft  = 0;
  int nright = 0;
  for (int i=0; i<dot; i++)  {
    string char = StringSubstr(mask,i,1);
    if (char >= "0" && char <= "9")   nleft = 10 * nleft + StrToInteger(char);
  }
  if (dotadj == 0)   {
    for (i=dot+1; i<=StringLen(mask); i++)  {
      char = StringSubstr(mask,i,1);
      if (char >= "0" && char <= "9")  nright = 10 * nright + StrToInteger(char);
  } }
  nright = MathMin(nright,7);

  if (dotadj == 1)  {
    for (i=0; i<StringLen(mask); i++)  {
      char = StringSubstr(mask,i,1);
      if (char >= "0" && char <= "9")  {
        dot = i;
        break;
  } } }

  string csym = "";
  if (StringFind(mask,"$",0) >= 0)   csym = "$";
  if (StringFind(mask,"£",0) >= 0)   csym = "£";
  if (StringFind(mask,"€",0) >= 0)   csym = "€";
  if (StringFind(mask,"¥",0) >= 0)   csym = "¥";

  string leadsign  = "";
  string trailsign = "";
  if (StringFind(mask,"+",0) >= 0 && StringFind(mask,"+",0) < dot)  {
    leadsign = " ";
    if (n > 0)   leadsign  = "+";
    if (n < 0)   leadsign  = "-";
  }    
  if (StringFind(mask,"-",0) >= 0 && StringFind(mask,"-",0) < dot)
    if (n < 0)  leadsign  = "-"; else leadsign = " ";
  if (StringFind(mask,"-",0) >= 0 && StringFind(mask,"-",0) > dot)
    if (n < 0)  trailsign  = "-"; else trailsign = " ";
  if (StringFind(mask,"(",0) >= 0 || StringFind(mask,")",0) >= 0)  {
    leadsign  = " ";
    trailsign = " ";
    if (n < 0)  { 
      leadsign  = "("; 
      trailsign = ")";
  } }    

  if (StringFind(mask,"%",0) >= 0)   trailsign = "%" + trailsign;

  if (StringFind(mask,",",0) >= 0) bool comma = true; else comma = false;
  if (StringFind(mask,"Z",0) >= 0) bool zeros = true; else zeros = false;
  if (StringFind(mask,"*",0) >= 0) bool aster = true; else aster = false;
  if (StringFind(mask,"B",0) >= 0) bool blank = true; else blank = false;
  if (StringFind(mask,"R",0) >= 0) bool round = true; else round = false;
  if (StringFind(mask,"~",0) >= 0) bool overf = true; else overf = false;
  if (StringFind(mask,"L",0) >= 0) bool lftsh = true; else lftsh = false;
  if (StringFind(mask,";",0) >= 0) bool swtch = true; else swtch = false;
  if (StringFind(mask,"T",0) >= 0) bool trimf = true; else trimf = false;

  if (round) n = MathFix(n,nright);
  string outstr = n;

  int dleft = 0;
  for (i=0; i<StringLen(outstr); i++)  {
    char = StringSubstr(outstr,i,1);
    if (char >= "0" && char <= "9")   dleft++;
    if (char == ".")   break;
  }
  
// Insert fill characters.......
  string fill = " ";
  if (zeros) fill = "0";
  if (aster) fill = "*";
  if (n < 0)
    outstr = "-" + StringRepeat(fill,nleft-dleft) + StringSubstr(outstr,1,StringLen(outstr)-1);
  else  
    outstr = StringRepeat(fill,nleft-dleft) + StringSubstr(outstr,0,StringLen(outstr));

  outstr = StringSubstr(outstr,StringLen(outstr)-9-nleft,nleft+1+nright-dotadj);

// Insert the commas.......  
  if (comma)   {
    bool digflg = false;
    bool stpflg = false;
    string out1 = "";
    string out2 = "";
    for (i=0; i<StringLen(outstr); i++)  {
      char = StringSubstr(outstr,i,1);
      if (char == ".")   stpflg = true;
      if (!stpflg && (nleft-i == 3 || nleft-i == 6 || nleft-i == 9)) 
        if (digflg)   out1 = out1 + ","; else out1 = out1 + " "; 
      out1 = out1 + char;    
      if (char >= "0" && char <= "9")   digflg = true;
    }  
    outstr = out1;
  }  
// Add currency symbol and signs........  
  outstr = csym + leadsign + outstr + trailsign;

// 'Float' the currency symbol/sign.......
  out1 = "";
  out2 = "";
  bool fltflg = true;
  for (i=0; i<StringLen(outstr); i++)   {
    char = StringSubstr(outstr,i,1);
    if (char >= "0" && char <= "9")   fltflg = false;
    if ((char == " " && fltflg) || (blank && n == 0) )   out1 = out1 + " ";   else   out2 = out2 + char;
  }   
  outstr = out1 + out2;

// Overflow........  
  if (overf && dleft > nleft)  outstr = "~" + StringSubstr(outstr,1,StringLen(outstr)-1);

// Left shift.......
  if (lftsh)   {
    int len = StringLen(outstr);
    outstr = StringLeftTrim(outstr);
    outstr = outstr + StringRepeat(" ",len-StringLen(outstr));
  }

// Switch period and comma.......
  if (swtch)   {
    out1 = "";
    for (i=0; i<StringLen(outstr); i++)   {
      char = StringSubstr(outstr,i,1);
      if (char == ".")   out1 = out1 + ",";     else
      if (char == ",")   out1 = out1 + ".";     else
      out1 = out1 + char;
    }    
    outstr = out1;
  }  

// Trim output....
  if (trimf)    outstr = StringTrim(outstr);

  return(ltext+outstr+rtext);
}

//+------------------------------------------------------------------+
string StringRepeat(string str, int n=1)
//+------------------------------------------------------------------+
// Repeats the string STR N times
// Usage:    string x=StringRepeat("-",10)  returns x = "----------"
{
  string outstr = "";
  for(int i=0; i<n; i++)  {
    outstr = outstr + str;
  }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringLeftTrim(string str)
//+------------------------------------------------------------------+
// Removes all leading spaces from a string
// Usage:    string x=StringLeftTrim("  XX YY  ")  returns x = "XX  YY  "
{
  bool   left = true;
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " " || !left) {
      outstr = outstr + StringSubstr(str,i,1);
      left = false;
  } }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  

//+------------------------------------------------------------------+
string StringLower(string str)
//+------------------------------------------------------------------+
// Converts any uppercase characters in a string to lowercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "the quick brown fox"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(upper,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(lower,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringTrim(string str)
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
{
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " ")
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
double MathFix(double n, int d=0)
//+------------------------------------------------------------------+
// Returns N rounded to D decimals - works around a precision bug in MQL4
{
  return(MathRound(n*MathPow(10,d)+0.000000000001*MathSign(n))/MathPow(10,d));
}  

//+------------------------------------------------------------------+
double DivZero(double n, double d)
//+------------------------------------------------------------------+
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
{
  if (d == 0) return(0);  else return(1.0*n/d);
}  

//+------------------------------------------------------------------+
int MathSign(double n)
//+------------------------------------------------------------------+
// Returns the sign of a number (i.e. -1, 0, +1)
// Usage:   int x=MathSign(-25)   returns x=-1
{
  if (n > 0) return(1);
  else if (n < 0) return (-1);
  else return(0);
}  

//+------------------------------------------------------------------+
int BaseToNumber(string str, int base=16)
//+------------------------------------------------------------------+
// Returns the base 10 version of a number in another base
// Usage:   int x=BaseToNumber("DC",16)   returns x=220
{
  str = StringUpper(str);
  string cnvstr = "0123456789ABCDEF";
  int    retval = 0;
  for(int i=0; i<StringLen(str); i++)  {
    int val = StringFind(cnvstr,StringSubstr(str,i,1),0);
    if (val < 0)  return(val);
    retval = retval * base + val;
  }
  return(retval);
}

//+------------------------------------------------------------------+
string NumberToBase(int n, int base=16, int pad=4)
//+------------------------------------------------------------------+
// Converts a base 10 number to another base, left-padded with zeros
// Usage:   int x=BaseToNumber(220,16,4)   returns x="00DC"
{
  string cnvstr = "0123456789ABCDEF";
  string outstr = "";
  while (n>0)  {
    int x = MathMod(n,base);    
    outstr = StringSubstr(cnvstr,x,1) + outstr;
    n /= base;
  }
  x = StringLen(outstr); 
  if (x < pad)
    outstr = StringRepeat("0",pad-x) + outstr;
  return(outstr);
}

//+------------------------------------------------------------------+
int YMDtoDate(int yy, int mm, int dd)  {
//+------------------------------------------------------------------+
  string dt = NumberToStr(yy,"4") + "." + NumberToStr(mm,"2") + "." + NumberToStr(dd,"2") + " 00:00:00";
  return(StrToTime(dt));
}

//+------------------------------------------------------------------+
string StringEncrypt(string str)  {
//+------------------------------------------------------------------+
  for (int i=StringLen(str)-1; i>=0; i--)   {
    int x=StringGetChar(str,i);
    string outstr = outstr + CharToStr(255-x);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringDecrypt(string str)  {
//+------------------------------------------------------------------+
  for (int i=StringLen(str)-1; i>=0; i--)   {
    int x=StringGetChar(str,i);
    string outstr = outstr + CharToStr(255-x);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringReplace(string str, string str1, string str2)  {
//+------------------------------------------------------------------+
// Usage: replaces every occurrence of str1 with str2 in str
  string outstr = "";
  for (int i=0; i<StringLen(str); i++)   {
    if (StringSubstr(str,i,StringLen(str1)) == str1)  {
      outstr = outstr + str2;
      i += StringLen(str1) - 1;
    }
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}

//+------------------------------------------------------------------+
string StrToStr(string str, string mask)  {
//+------------------------------------------------------------------+
  string ltext = "", rtext = "";
  if (StringSubstr(mask,0,1) == "'")   {
    for (int k1=1; k1<StringLen(mask); k1++)   {
      if (StringSubstr(mask,k1,1) == "'")   break;
        ltext = ltext + StringSubstr(mask,k1,1);
    }
    mask = StringSubstr(mask,k1+1);
  }
  if (StringSubstr(mask,StringLen(mask)-1,1) == "'")   {
    for (int k2=StringLen(mask)-2; k2>=0; k2--)   {
      if (StringSubstr(mask,k2,1) == "'")   break;
        rtext = StringSubstr(mask,k2,1) + rtext;
    } 
    mask = StringSubstr(mask,0,k2);
  }

  if (mask == "")   mask = "L20";

  string outstr = "";
  int n = 0;
  for (int i=0; i<StringLen(mask); i++)  {
    string s = StringSubstr(mask,i,1);
    if (s == "!")   {
      outstr = outstr + StringSubstr(mask,i+1,1);
      i++;
      continue;
    }  
    if (s == "L" || s == "C" || s == "R" || s == "T")   {
      string func = s;
      i++;
      while (i<StringLen(mask))  {
        s = StringSubstr(mask,i,1);
        if (s >= "0" && s <= "9")  {
          n = n * 10 + StrToInteger(s);
          i++;
          continue;
        }  
        else
          break;  
      }
      i--;
      if (n<StringLen(str))   str = StringSubstr(str,0,n);
      int lpad = 0, rpad = 0;
      if (func == "L")  rpad = MathMax(0,n-StringLen(str));
      if (func == "R")  lpad = MathMax(0,n-StringLen(str));
      if (func == "C")  {
        lpad = MathMax(0,n-StringLen(str))/2;
        rpad = MathMax(0,n-StringLen(str)) - lpad;
      }
      outstr = outstr + StringRepeat(" ",lpad) + str + StringRepeat(" ",rpad);    
    }  
    else
      outstr = outstr + s;
  }  
  return(ltext+outstr+rtext);
}

//+------------------------------------------------------------------+
double StrToNumber(string str)  {
//+------------------------------------------------------------------+
// Usage: strips all non-numeric characters out of a string
  int    dp   = -1;
  int    sgn  = 1;
  double num  = 0.0;
  for (int i=0; i<StringLen(str); i++)  {
    string s = StringSubstr(str,i,1);
    if (s == "-")  sgn = -sgn;   else
    if (s == ".")  dp = 0;       else
    if (s >= "0" && s <= "9")  {
      if (dp >= 0)  dp++;
      if (dp > 0)
        num = num + StrToInteger(s) / MathPow(10,dp);
      else
        num = num * 10 + StrToInteger(s);
    }
  }
  return(num*sgn);
}

//+------------------------------------------------------------------+
string ReduceCcy(string str)
//+------------------------------------------------------------------+
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) !=3 && StringLen(str) < 6)   return("");
  string s = "";
  for (int i=0; i<StringLen(str); i+=3)   {
    string char = StringSubstr(str,i,3);
    if (char == "AUD")  s = s + "A";     else
    if (char == "CAD")  s = s + "C";     else   
    if (char == "EUR")  s = s + "E";     else   
    if (char == "CHF")  s = s + "F";     else   
    if (char == "GBP")  s = s + "G";     else   
    if (char == "JPY")  s = s + "J";     else   
    if (char == "NZD")  s = s + "N";     else   
    if (char == "USD")  s = s + "U";     else   
    if (char == "HKD")  s = s + "H";     else   
    if (char == "SGD")  s = s + "S";     else   
    if (char == "ZAR")  s = s + "Z";   
  }  
  return(s);
}

//+------------------------------------------------------------------+
string NumbersToStr(string mask, double n1=0, double n2=0, double n3=0, double n4=0, double n5=0, double n6=0, double n7=0, double n8=0, double n9=0)   {
//+------------------------------------------------------------------+
  if (StringSubstr(mask,StringLen(mask)-1,1) != "_")   mask = mask + "_";
  string outstr = "";
  string maska[9] = {"<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>"};
  int z=0;
  for (int x=0; x<StringLen(mask); x++)   {
    if (maska[z] == "<NULL>")   maska[z] = "";
    string s = StringSubstr(mask,x,1);
    if (s == "_")   {
      if (StringLower(StringSubstr(maska[z],1,1)) == "@")  {
        int yy = StrToNumber(StringSubstr(maska[z],0,1));
        maska[z] = StringSubstr(maska[z],2);
        for (int y=1; y<yy; y++)  {
          maska[z+1] = maska[z];
          z++;
      } }
      z++;
    }
    else 
      maska[z] = maska[z] + s;
  }
  if (maska[0] != "<NULL>")   outstr = outstr + NumberToStr(n1,maska[0]);
  if (maska[1] != "<NULL>")   outstr = outstr + NumberToStr(n2,maska[1]);
  if (maska[2] != "<NULL>")   outstr = outstr + NumberToStr(n3,maska[2]);
  if (maska[3] != "<NULL>")   outstr = outstr + NumberToStr(n4,maska[3]);
  if (maska[4] != "<NULL>")   outstr = outstr + NumberToStr(n5,maska[4]);
  if (maska[5] != "<NULL>")   outstr = outstr + NumberToStr(n6,maska[5]);
  if (maska[6] != "<NULL>")   outstr = outstr + NumberToStr(n7,maska[6]);
  if (maska[7] != "<NULL>")   outstr = outstr + NumberToStr(n8,maska[7]);
  if (maska[8] != "<NULL>")   outstr = outstr + NumberToStr(n9,maska[8]);
  return(outstr);
}  

//+------------------------------------------------------------------+
string DatesToStr(string mask, datetime d1=0, datetime d2=0, datetime d3=0, datetime d4=0, datetime d5=0, datetime d6=0, datetime d7=0, datetime d8=0, datetime d9=0)   {
//+------------------------------------------------------------------+
  if (StringSubstr(mask,StringLen(mask)-1,1) != "_")   mask = mask + "_";
  string outstr = "";
  string maska[9] = {"<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>"};
  int z=0;
  for (int x=0; x<StringLen(mask); x++)   {
    if (maska[z] == "<NULL>")   maska[z] = "";
    string s = StringSubstr(mask,x,1);
    if (s == "_")   {
      if (StringLower(StringSubstr(maska[z],1,1)) == "@")  {
        int yy = StrToNumber(StringSubstr(maska[z],0,1));
        maska[z] = StringSubstr(maska[z],2);
        for (int y=1; y<yy; y++)  {
          maska[z+1] = maska[z];
          z++;
      } }
      z++;
    }
    else 
      maska[z] = maska[z] + s;
  }
  if (maska[0] != "<NULL>")   outstr = outstr + DateToStr(d1,maska[0]);
  if (maska[1] != "<NULL>")   outstr = outstr + DateToStr(d2,maska[1]);
  if (maska[2] != "<NULL>")   outstr = outstr + DateToStr(d3,maska[2]);
  if (maska[3] != "<NULL>")   outstr = outstr + DateToStr(d4,maska[3]);
  if (maska[4] != "<NULL>")   outstr = outstr + DateToStr(d5,maska[4]);
  if (maska[5] != "<NULL>")   outstr = outstr + DateToStr(d6,maska[5]);
  if (maska[6] != "<NULL>")   outstr = outstr + DateToStr(d7,maska[6]);
  if (maska[7] != "<NULL>")   outstr = outstr + DateToStr(d8,maska[7]);
  if (maska[8] != "<NULL>")   outstr = outstr + DateToStr(d9,maska[8]);
  return(outstr);
}  

//+------------------------------------------------------------------+
string StrsToStr(string mask, string s1="", string s2="", string s3="", string s4="", string s5="", string s6="", string s7="", string s8="", string s9="")   {
//+------------------------------------------------------------------+
  if (StringSubstr(mask,StringLen(mask)-1,1) != "_")   mask = mask + "_";
  string outstr = "";
  string maska[9] = {"<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>"};
  int z=0;
  for (int x=0; x<StringLen(mask); x++)   {
    if (maska[z] == "<NULL>")   maska[z] = "";
    string s = StringSubstr(mask,x,1);
    if (s == "_")   {
      if (StringLower(StringSubstr(maska[z],1,1)) == "@")  {
        int yy = StrToNumber(StringSubstr(maska[z],0,1));
        maska[z] = StringSubstr(maska[z],2);
        for (int y=1; y<yy; y++)  {
          maska[z+1] = maska[z];
          z++;
      } }
      z++;
    }
    else 
      maska[z] = maska[z] + s;
  }
  if (maska[0] != "<NULL>")   outstr = outstr + StrToStr(s1,maska[0]);
  if (maska[1] != "<NULL>")   outstr = outstr + StrToStr(s2,maska[1]);
  if (maska[2] != "<NULL>")   outstr = outstr + StrToStr(s3,maska[2]);
  if (maska[3] != "<NULL>")   outstr = outstr + StrToStr(s4,maska[3]);
  if (maska[4] != "<NULL>")   outstr = outstr + StrToStr(s5,maska[4]);
  if (maska[5] != "<NULL>")   outstr = outstr + StrToStr(s6,maska[5]);
  if (maska[6] != "<NULL>")   outstr = outstr + StrToStr(s7,maska[6]);
  if (maska[7] != "<NULL>")   outstr = outstr + StrToStr(s8,maska[7]);
  if (maska[8] != "<NULL>")   outstr = outstr + StrToStr(s9,maska[8]);
  return(outstr);
}  

//+------------------------------------------------------------------+
void ShellsortDoubleArray(double &a[], bool desc=false)  {
//+------------------------------------------------------------------+
  int n=ArraySize(a);
  int j,i,k,m;
  double mid;
  for(m=n/2; m>0; m/=2)  {
    for(j=m; j<n; j++)  {
      for(i=j-m; i>=0; i-=m)  {
        if (desc)   {
          if (a[i+m] <= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
        else  {
          if (a[i+m] >= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
  } } } 
  return(0);
}

//+------------------------------------------------------------------+
void ShellsortIntegerArray(int &a[], bool desc=false)  {
//+------------------------------------------------------------------+
  int n=ArraySize(a);
  int j,i,k,m,mid;
  for(m=n/2; m>0; m/=2)  {
    for(j=m; j<n; j++)  {
      for(i=j-m; i>=0; i-=m)  {
        if (desc)   {
          if (a[i+m] <= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
        else  {
          if (a[i+m] >= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
  } } } 
  return(0);
}

//+------------------------------------------------------------------+
void ShellsortStringArray(string &a[], bool desc=false)  {
//+------------------------------------------------------------------+
  int n=ArraySize(a);
  int j,i,k,m;
  string mid;
  for(m=n/2; m>0; m/=2)  {
    for(j=m; j<n; j++)  {
      for(i=j-m; i>=0; i-=m)  {
        if (desc)   {
          if (a[i+m] <= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
        else  {
          if (a[i+m] >= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
  } } } 
  return(0);
}

//+------------------------------------------------------------------+
void StrToDoubleArray(string str, double &a[], string delim=",")  {
//+------------------------------------------------------------------+
  int z1=-1, z2=0;
  for (int i=0; i<ArraySize(a); i++)  {
    z2 = StringFind(str,delim,z1+1);
    a[i] = StrToNumber(StringSubstr(str,z1+1,z2-z1-1));
    if (z2 >= StringLen(str)-1)   break;
    z1 = z2;
  }
  return(0);
}

//+------------------------------------------------------------------+
void StrToIntegerArray(string str, int &a[], string delim=",")  {
//+------------------------------------------------------------------+
  int z1=-1, z2=0;
  for (int i=0; i<ArraySize(a); i++)  {
    z2 = StringFind(str,delim,z1+1);
    a[i] = StrToNumber(StringSubstr(str,z1+1,z2-z1-1));
    if (z2 >= StringLen(str)-1)   break;
    z1 = z2;
  }
  return(0);
}

//+------------------------------------------------------------------+
void StrToStringArray(string str, string &a[], string delim=",")  {
//+------------------------------------------------------------------+
  int z1=-1, z2=0;
  for (int i=0; i<ArraySize(a); i++)  {
    z2 = StringFind(str,delim,z1+1);
    a[i] = StringSubstr(str,z1+1,z2-z1-1);
    if (z2 >= StringLen(str)-1)   break;
    z1 = z2;
  }
  return(0);
}

//+------------------------------------------------------------------+
string DoubleArrayToStr(double a[], string mask="", string delim=",")  {
//+------------------------------------------------------------------+
  string str = "";
  for (int i=0; i<ArraySize(a); i++)
    if (str == "")
      str = NumberToStr(a[i],mask);
    else 
      str = str + delim + NumberToStr(a[i],mask);  
  return(str);
}

//+------------------------------------------------------------------+
string IntegerArrayToStr(int a[], string mask="", string delim=",")  {
//+------------------------------------------------------------------+
  string str = "";
  for (int i=0; i<ArraySize(a); i++)
    if (str == "")
      str = NumberToStr(a[i],mask);
    else 
      str = str + delim + NumberToStr(a[i],mask);  
  return(str);
}

//+------------------------------------------------------------------+
string StringArrayToStr(string a[], string mask="", string delim=",")  {
//+------------------------------------------------------------------+
  string str = "";
  for (int i=0; i<ArraySize(a); i++)
    if (str == "")
      str = StrToStr(a[i],mask);
    else 
      str = str + delim + StrToStr(a[i],mask);  
  return(str);
}

//+------------------------------------------------------------------+
string DebugDoubleArray(double a[], string mask="", string delim=",", int fromidx=0, int thruidx=0)  {
//+------------------------------------------------------------------+
  if (thruidx == 0)  thruidx = ArraySize(a);
  string str = "";
  for (int i=MathMax(0,fromidx); i<MathMin(ArraySize(a),thruidx+1); i++)
    if (str == "")
      str = NumberToStr(i,"'['T4']='") + NumberToStr(a[i],mask);
    else 
      str = str + delim + NumberToStr(i,"'['T4']='") + NumberToStr(a[i],mask);  
  return(str);
}

//+------------------------------------------------------------------+
string DebugIntegerArray(int a[], string mask="", string delim=",", int fromidx=0, int thruidx=0)  {
//+------------------------------------------------------------------+
  if (thruidx == 0)  thruidx = ArraySize(a);
  string str = "";
  for (int i=MathMax(0,fromidx); i<MathMin(ArraySize(a),thruidx+1); i++)
    if (str == "")
      str = NumberToStr(i,"'['T4']='") + NumberToStr(a[i],mask);
    else 
      str = str + delim + NumberToStr(i,"'['T4']='") + NumberToStr(a[i],mask);  
  return(str);
}

//+------------------------------------------------------------------+
string DebugStringArray(string a[], string mask="", string delim=",", int fromidx=0, int thruidx=0)  {
//+------------------------------------------------------------------+
  if (thruidx == 0)  thruidx = ArraySize(a);
  string str = "";
  for (int i=MathMax(0,fromidx); i<MathMin(ArraySize(a),thruidx+1); i++)
    if (str == "")
      str = NumberToStr(i,"'['T4']='") + StrToStr(a[i],mask);
    else 
      str = str + delim + NumberToStr(i,"'['T4']='") + StrToStr(a[i],mask);  
  return(str);
}
//+------------------------------------------------------------------+
string FileSort(string fname, bool desc=false)   {
//+------------------------------------------------------------------+
// Sorts the text file named fname, on a line by line basis
//  (default is ascending sequence, unless desc=true)
  string a[9999];
  int h = FileOpen(fname,FILE_CSV|FILE_READ,'~');
  int i = -1;
  while (!FileIsEnding(h) && i<9999)  {
    i++;
    a[i] = FileReadString(h);
  }  
  FileClose(h);
  ArrayResize(a,i);
  ShellsortStringArray(a,desc);
  h = FileOpen(fname,FILE_CSV|FILE_WRITE,'~');
  for (i=0; i<ArraySize(a); i++)  {
    FileWrite(h,a[i]);
  }  
  FileClose(h);
  return(0);
}  

// ===========================================  DEBUGGING ===========================================

//+------------------------------------------------------------------+
string d(string s1, string s2="", string s3="", string s4="", string s5="", string s6="", string s7="", string s8="")  {
//+------------------------------------------------------------------+
// Outputs up to 8 values to the DEBUG.TXT file (after creating the file, if it doesn't already exist)
  string out = StringTrimRight(StringConcatenate(s1, " ", s2, " ", s3, " ", s4, " ", s5, " ", s6, " ", s7, " ", s8));
  int h = FileOpen("debug.txt",FILE_CSV|FILE_READ|FILE_WRITE,'~');
  FileSeek(h,0,SEEK_END);
  FileWrite(h,out);
  FileClose(h);
  return(0);
}

//+------------------------------------------------------------------+
string dd(string s1, string s2="", string s3="", string s4="", string s5="", string s6="", string s7="", string s8="")  {
//+------------------------------------------------------------------+
// Deletes and re-creates the DEBUG.TXT file, and adds up to 8 values to it
  string out = StringTrimRight(StringConcatenate(s1, " ", s2, " ", s3, " ", s4, " ", s5, " ", s6, " ", s7, " ", s8));
  int h = FileOpen("debug.txt",FILE_CSV|FILE_WRITE,'~');
  FileWrite(h,out);
  FileClose(h);
  return(0);
}

