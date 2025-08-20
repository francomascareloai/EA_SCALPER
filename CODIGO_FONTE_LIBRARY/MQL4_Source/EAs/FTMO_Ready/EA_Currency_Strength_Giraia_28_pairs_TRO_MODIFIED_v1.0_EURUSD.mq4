//+------------------------------------------------------------------+
//|                                   Currency Strength - Giraia.mq4 |
//+------------------------------------------------------------------+
//
// Indicator modified in 06/June/2015 to make it compatible with 
// build 600+. Credits to the original creator.
//
// This version doesn't use all 28 pairs to be compatible with the
// most used version which uses only 25. To have all 28 pairs, just 
// add NC,CF,NF in the Currency pairs. Results will be slightly 
// different.

//  Currency_Strength_Giraia_25_pairs_TRO_MODIFIED
//--------------------------------------------------------------------


#property indicator_chart_window

extern bool TURN_OFF    = false ;    // TRO
extern bool SHOW_CURRENCIES    = true ;    // TRO
extern bool SHOW_CHART_PAIR    = true ;    // TRO  
extern bool SHOW_COMMENT       = false ;    // TRO  

extern string myCorner = 1 ;         // TRO

extern string   missingPairs        = "To have 28 pairs, these must be added: ";
extern string   CurrencyPairs       = "GU,UF,EU,UJ,UC,NU,AU,AN,AC,AF,AJ,CJ,FJ,EG,EA,EF,EJ,EN,EC,GF,GA,GC,GJ,GN,NJ,NC,CF,NF";         
//extern string   CurrencyPairs       = "GU,UF,EU,UJ,UC,NU,AU,AN,AC,AF,AJ,CJ,FJ,EG,EA,EF,EJ,EN,EC,GF,GA,GC,GJ,GN,NJ,NC,FC,NF";  // 28 pairs
extern string   FontName            = "Calibri";   //Courier New";
extern int      FontSize            = 16;
//extern string   OutputFormat        = "R3.1";
extern int      HorizPos            = 50;
extern int      VertPos             = 180;
extern int      VertSpacing         = 20;
extern int      RefreshEveryXMins   = 0;
extern color    Color1              = MediumVioletRed;
extern double   Level1              = 7.0;
extern color    Color2              = DarkGreen;
extern double   Level2              = 5.0;
extern color    Color3              = Blue;
extern double   Level3              = 2.9;
extern color    Color4              = Red;
extern double   Level4              = 0.0;
extern bool     ShowNoOfPairs       = false;
extern bool     SortDescending      = true;

double    spr, pnt, tickval, ccy_strength[8];
int       dig, tf, ccy_count[8], ccCP;
string    IndiName, ccy, CP[99], ccy_name[8];
datetime  prev_time;

   string BaseCur, QuoteCur, tMessage;   
   double BaseVal, QuoteVal, PairVal;
//+------------------------------------------------------------------+
int init()   {
//+------------------------------------------------------------------+

  if (RefreshEveryXMins > 240)                             RefreshEveryXMins = 240;
  if (RefreshEveryXMins > 60 && RefreshEveryXMins < 240)   RefreshEveryXMins = 60;
  if (RefreshEveryXMins > 30 && RefreshEveryXMins < 60)    RefreshEveryXMins = 30;
  if (RefreshEveryXMins > 15 && RefreshEveryXMins < 30)    RefreshEveryXMins = 15;
  if (RefreshEveryXMins > 5  && RefreshEveryXMins < 15)    RefreshEveryXMins = 5;
  if (RefreshEveryXMins > 1  && RefreshEveryXMins < 5)     RefreshEveryXMins = 1;


  CurrencyPairs  = StringUpper(CurrencyPairs);
  if (CurrencyPairs == "")  CurrencyPairs = Symbol();
  if (StringSubstr(CurrencyPairs,StringLen(CurrencyPairs)-1,1) != ",")  CurrencyPairs = CurrencyPairs + ",";
  ccCP = StringFindCount(CurrencyPairs,",");
  
  for (int i=0; i<99; i++)
    CP[i] = "";
    
  int comma1 = -1;
 
  for (i=0; i<99; i++)  {
    int comma2 = StringFind(CurrencyPairs,",",comma1+1);
    string temp  = StringSubstr(CurrencyPairs,comma1+1,comma2-comma1-1);
    CP[i] = ExpandCcy(temp);
    if (comma2 >= StringLen(CurrencyPairs)-1)   break;
    comma1 = comma2;
  }  

  int checksum = 0;
  string str = "0";
  for (i=0; i<StringLen(str); i++)  
    checksum += i * StringGetChar(str,i);
  IndiName = "CurrencyStrength-" + checksum;
  IndicatorShortName(IndiName);

  ccy     = Symbol();
  tf      = Period();
  pnt     = MarketInfo(ccy,MODE_POINT);
  dig     = MarketInfo(ccy,MODE_DIGITS);
  spr     = MarketInfo(ccy,MODE_SPREAD);
  tickval = MarketInfo(ccy,MODE_TICKVALUE);
  if (dig == 3 || dig == 5) {
    pnt     *= 10;
    spr     /= 10;
    tickval *= 10;
  }

  ccy_name[0] = "USD";
  ccy_name[1] = "EUR";
  ccy_name[2] = "GBP";
  ccy_name[3] = "CHF";
  ccy_name[4] = "CAD";
  ccy_name[5] = "AUD";
  ccy_name[6] = "JPY";
  ccy_name[7] = "NZD";

  del_obj();
  plot_obj();    
  prev_time = -9999;
  
  
// extract base and quote from symbol

   BaseCur    = StringSubstr(Symbol(),0,3);
   QuoteCur    = StringSubstr(Symbol(),3,3);  
    TRO();
    
  return(0);
}


//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  del_obj();
  Comment("") ;
   TRO();
  return(0);
}


//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
 
   if( TURN_OFF ) { deinit(); return(0) ; }
 
  if (RefreshEveryXMins == 0) {
    del_obj();
    plot_obj();    
  }
  else {
    if(prev_time != iTime(ccy,RefreshEveryXMins,0))  {
      del_obj();
      plot_obj();
      prev_time = iTime(ccy,RefreshEveryXMins,0);
  } }      
  return(0);
}



//+------------------------------------------------------------------+
void plot_obj()   {
//+------------------------------------------------------------------+

  ArrayInitialize(ccy_strength,0.0);
  ArrayInitialize(ccy_count,0);

  for (int i=0; i<ccCP; i++)   {
    double day_high     = MarketInfo(CP[i],MODE_HIGH);
    double day_low      = MarketInfo(CP[i],MODE_LOW);
    double curr_bid     = MarketInfo(CP[i],MODE_BID);
    double bid_ratio    = DivZero(curr_bid - day_low, day_high - day_low);

    double ind_strength = 0;
    if (bid_ratio >= 0.97)   ind_strength = 9;    else
    if (bid_ratio >= 0.90)   ind_strength = 8;    else
    if (bid_ratio >= 0.75)   ind_strength = 7;    else
    if (bid_ratio >= 0.60)   ind_strength = 6;    else
    if (bid_ratio >= 0.50)   ind_strength = 5;    else
    if (bid_ratio >= 0.40)   ind_strength = 4;    else
    if (bid_ratio >= 0.25)   ind_strength = 3;    else
    if (bid_ratio >= 0.10)   ind_strength = 2;    else
    if (bid_ratio >= 0.03)   ind_strength = 1;

    string temp = StringSubstr(CP[i],0,3);
    for (int j=0; j<8; j++)   {
      if (ccy_name[j] == temp)  {
        ccy_strength[j] += ind_strength;
        ccy_count[j]    += 1;
        break;
    } }    

    temp = StringSubstr(CP[i],3,3);
    for (j=0; j<8; j++)   {
      if (ccy_name[j] == temp)  {
        ccy_strength[j] += 9 - ind_strength;
        ccy_count[j]    += 1;
        break;
  } } }    

  // This routine loads the strength values and currency symbols into an array, and sorts the array......
  string array_to_sort[8];
  
  for (j=0; j<8; j++)  
  {
       array_to_sort[j] = "";
       if (ccy_count[j] < 1)   continue;
       double out_value = DivZero(ccy_strength[j],ccy_count[j]);        // calculate the strength value = total strength / number of pairs that were summed        
      
      if( ccy_name[j] == BaseCur )
      {
         BaseVal = out_value ;  int basej = j ;
      }
      
      if( ccy_name[j] == QuoteCur )
      {
         QuoteVal = out_value ; int quotej = j ;
      } 
         
       string tstr1     = DoubleToStr(out_value, 1) + ccy_name[j];      // build a string (tstr1) with the formatted number value, followed by the currency name
       int    length    = StringLen(DoubleToStr(out_value,1));          // length of the formatted number value
       if (ShowNoOfPairs)  
         tstr1 = tstr1 + DoubleToStr(ccy_count[j],0);                   // append the currency count to the string
       array_to_sort[j] = tstr1;                                        // load the string into an array to be sorted
     
  }
   
  ShellsortStringArray(array_to_sort,SortDescending);   
                                                                             //   string, it has priority, but everything in the string gets sorted
  int xp = HorizPos;
  int yp = VertPos;
  for (j=0; j<8; j++)  
  {
    if (ccy_count[j] < 1)   continue;
    
      color FontColor = White;
      string objname = IndiName + "-" + j;
    
    out_value = StrToDouble(StringSubstr(array_to_sort[j],0,length));                      // extract the value from the string
    //Print(array_to_sort[j], " ", out_value, " ", length);
    tstr1 = StringSubstr(array_to_sort[j],length,3) + "    " + DoubleToStr(out_value,1);     // build a new string to be output, from the sorted array, with the currency sybol first
    if (ShowNoOfPairs)  
      tstr1 = tstr1 + " (" + StringSubstr(array_to_sort[j],length+3) + ")";                // extract and append the currency count to the string
//    string objname = IndiName + "-" + j;
 
 
   if(SHOW_CURRENCIES)
   {  
       ObjectCreate(objname,OBJ_LABEL,0,0,0);
       ObjectSet(objname, OBJPROP_CORNER, myCorner ); // TRO
       ObjectSet(objname,OBJPROP_XDISTANCE,xp);
       ObjectSet(objname,OBJPROP_YDISTANCE,yp);
   //    color FontColor = White;
       if (out_value >  Level1)   FontColor = Color1;    else
       if (out_value >  Level2)   FontColor = Color2;    else
       if (out_value >  Level3)   FontColor = Color3;    else
       if (out_value >= Level4)   FontColor = Color4;
       tstr1=StringRightPad(tstr1,16," ");
       ObjectSetText(objname,tstr1,FontSize,FontName,FontColor);
       yp += VertSpacing;
   } // if
 
  } // for



      PairVal  =  BaseVal - QuoteVal ;
      
      if( PairVal >= 0.0 )   { tMessage = "BUY  " ; FontColor = Green; } 
                        else { tMessage = "SELL " ; FontColor = Red;} 

   if(SHOW_COMMENT)
   {   
   
      Comment( BaseCur  + " " + DoubleToStr(BaseVal,Digits)  , "\n" , 
               QuoteCur + " " + DoubleToStr(QuoteVal,Digits) , "\n" , 
               Symbol() + " " + DoubleToStr(PairVal,Digits) + " " +  tMessage   , "\n" ,  
               "") ;
   }            
               
   if(SHOW_CHART_PAIR)
   {                   
       tstr1 = Symbol() + " " + DoubleToStr(PairVal,1) + " " +  tMessage ;
       objname = IndiName + "-" + j;
       ObjectCreate(objname,OBJ_LABEL,0,0,0);
       ObjectSet(objname, OBJPROP_CORNER, myCorner ); // TRO
       ObjectSet(objname,OBJPROP_XDISTANCE,xp);
       ObjectSet(objname,OBJPROP_YDISTANCE,yp);
        
       ObjectSetText(objname,tstr1,FontSize,FontName,FontColor);
       yp += VertSpacing;
       
       
    }//if  

          
  //return(0);
}



//+------------------------------------------------------------------+
//| del_obj                                                          |
//+------------------------------------------------------------------+
void del_obj()
{
  int k=0;
  while (k<ObjectsTotal())   {
    string objname = ObjectName(k);
    if (StringSubstr(objname,0,StringLen(IndiName)) == IndiName)  
      ObjectDelete(objname);
    else
      k++;
  }    
  //return(0);
}



//===========================================================================
//                            FUNCTIONS LIBRARY
//===========================================================================


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
string StringRightPad(string str, int n=1, string str2=" ")
//+------------------------------------------------------------------+
// Appends occurrences of the string STR2 to the string STR to make a string N characters long
// Usage:    string x=StringRightPad("ABCDEFG",9," ")  returns x = "ABCDEFG  "
{
  return(str + StringRepeat(str2,n-StringLen(str)));
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
string ExpandCcy(string str)
//+------------------------------------------------------------------+
// Expands a currency (e.g. G to GBP) or a currency pair (e.g. EU to EURUSD)
//  as shown in the code
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) < 1 || StringLen(str) > 2)   return(str);
  string str2 = "";
  for (int i=0; i<StringLen(str); i++)   {
    string char2 = StringSubstr(str,i,1);
    if (char2 == "A")  str2 = str2 + "AUD";     else
    if (char2 == "C")  str2 = str2 + "CAD";     else   
    if (char2 == "E")  str2 = str2 + "EUR";     else   
    if (char2 == "F")  str2 = str2 + "CHF";     else   
    if (char2 == "G")  str2 = str2 + "GBP";     else   
    if (char2 == "J")  str2 = str2 + "JPY";     else   
    if (char2 == "N")  str2 = str2 + "NZD";     else   
    if (char2 == "U")  str2 = str2 + "USD";     else   
    if (char2 == "H")  str2 = str2 + "HKD";     else   
    if (char2 == "S")  str2 = str2 + "SGD";     else   
    if (char2 == "Z")  str2 = str2 + "ZAR";   
  }  
  return(str2);
}


//+------------------------------------------------------------------+
string ReduceCcy(string str)
//+------------------------------------------------------------------+
// Abbreviates a single currency (e.g. GBP to G) or a currency pair (e.g. EURUSD to EU)
//  as shown in the code. Inverse of ExpandCcy() function
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) !=3 && StringLen(str) < 6)   return("");
  string s = "";
  for (int i=0; i<StringLen(str); i+=3)   {
    string char2 = StringSubstr(str,i,3);
    if (char2 == "AUD")  s = s + "A";     else
    if (char2 == "CAD")  s = s + "C";     else   
    if (char2 == "EUR")  s = s + "E";     else   
    if (char2 == "CHF")  s = s + "F";     else   
    if (char2 == "GBP")  s = s + "G";     else   
    if (char2 == "JPY")  s = s + "J";     else   
    if (char2 == "NZD")  s = s + "N";     else   
    if (char2 == "USD")  s = s + "U";     else   
    if (char2 == "HKD")  s = s + "H";     else   
    if (char2 == "SGD")  s = s + "S";     else   
    if (char2 == "ZAR")  s = s + "Z";   
  }  
  return(s);
}


//+------------------------------------------------------------------+
double MathInt(double n, int d=0)
//+------------------------------------------------------------------+
// Corrects a rounding/accuracy bug in MQL4's MathFloor function
//   (use MathInt(n) instead of MathFloor(n)
// Rounds n DOWN to d decimal places, e.g.
// MathInt(2.57,1) returns 2.5
// MathInt(2.99)   returns 2
 {
   return(MathFloor(n*MathPow(10,d)+0.000000000001)/MathPow(10,d));
 }  


//+------------------------------------------------------------------+
double MathFix(double n, int d=0)
//+------------------------------------------------------------------+
// Corrects a rounding/accuracy bug in MQL4's MathRound() function
//   (use MathFix(n) instead of MathRound(n)
// Rounds n to d decimal places, e.g.
// MathFix(2.54,1) returns 2.5
// MathFix(2.57,1) returns 2.6
// MathFix(2.99)   returns 3
{
  return(MathRound(n*MathPow(10,d)+0.000000000001*MathSign(n))/MathPow(10,d));
}  


//+------------------------------------------------------------------+
double DivZero(double n, double d)
//+------------------------------------------------------------------+
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
// Use DivZero(y,z) instead of y/z to eliminate division by zero errors
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
void ShellsortStringArray(string &a[], bool desc=false)  {
//+------------------------------------------------------------------+
// Performs a shell sort (rapid resorting) of string array 'a'
//  default is ascending order, unless 'desc' is set to true
  int n=ArraySize(a);
  int j,i,m;
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
  //return(0);
}

//+------------------------------------------------------------------+  
void TRO()
{   
   
   string TRO_OBJ    = "TROTAG"  ;  
   ObjectCreate(TRO_OBJ, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(TRO_OBJ, CharToStr(78) , 12 ,  "Wingdings",  DimGray );
   ObjectSet(TRO_OBJ, OBJPROP_CORNER, 3);
   ObjectSet(TRO_OBJ, OBJPROP_XDISTANCE, 5 );
   ObjectSet(TRO_OBJ, OBJPROP_YDISTANCE, 5 );  
}
//+------------------------------------------------------------------+