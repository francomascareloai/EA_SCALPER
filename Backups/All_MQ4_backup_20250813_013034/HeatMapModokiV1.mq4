//+------------------------------------------------------------------+
//|                                                HeatMapModoki.mq4 |
//|                           Copyright (c) 2013, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2013, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property indicator_chart_window

extern int BeforeMin = 60;

extern int FontSize = 12;
extern string FontName = "Arial";
extern int ShiftX = 0;
extern int ShiftY = 30;
extern int Corner = 0;
int ID     = ShiftX+ShiftY; 

string Symbols[8][3] = {
  "USD", "", "BASE",
  "JPY", "USDJPY", "R",
  "CHF", "USDCHF", "R",
  "CAD", "USDCAD", "R",

  "EUR", "EURUSD", "L",
  "AUD", "AUDUSD", "L",
  "GBP", "GBPUSD", "L",
  "NZD", "NZDUSD", "L"

};// 0:name 1:targetpair 2:method


double Data[][2];// 0:ROC 1:index
int size;
string  ObjPrefix = "m_";
int TargetPeriod = PERIOD_M1;


datetime openTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
  size = ArraySize( Symbols ) / 3;
  ArrayResize( Data, size );
  for( int i = 0; i < size; i++ ) {
    Data[i][0] = 0.0;
    Data[i][1] = i;
  }
  ObjPrefix = ObjPrefix + GetHeader() + "_";

  if( Corner >= 2 ) {
    ShiftY += 1;
  }

  
  if( BeforeMin < 2000 ) {
    TargetPeriod = PERIOD_M1;
  } else if( BeforeMin < 10000 ) {
    TargetPeriod = PERIOD_M5;
  } else if( BeforeMin < 30000 ) {
    TargetPeriod = PERIOD_M15;
  } else if( BeforeMin < 60000 ) {
    TargetPeriod = PERIOD_M30;
  } else if( BeforeMin < 120000 ) {
    TargetPeriod = PERIOD_H1;
  } else if( BeforeMin < 480000 ) {
    TargetPeriod = PERIOD_H4;
  } else {
    TargetPeriod = PERIOD_D1;
  }
 // Print( "TargetPeriod = ", TargetPeriod, " BeforeMin = ", BeforeMin );
//----
  return( 0 );
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
  DeleteObj();
//----
  return( 0 );
}
void DeleteObj()
{
  for( int i = ObjectsTotal() - 1; i >= 0; i-- ) {
    string ObjName = ObjectName( i );
    if ( StringFind( ObjName, ObjPrefix ) == 0 ) ObjectDelete( ObjName );
  }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int i;
  double min, max;
  openTime = 0;
  // 2sec interval
  static datetime tm = 0;
 // if( TimeLocal() - tm < 2 ) return(0);
  tm = TimeLocal();

 
  for( i = 0; i < size; i++ ) {
    Data[i][0] = GetValue( Data[i][1] ) * 100;
  }

  
  if( Corner < 2 ) {
    ArraySort( Data, WHOLE_ARRAY, 0, MODE_DESCEND );
    max = Data[0][0];
    min = Data[size - 1][0];
  } else {
    ArraySort( Data, WHOLE_ARRAY, 0, MODE_ASCEND );
    min = Data[0][0];
    max = Data[size - 1][0];
  }


  int TextY = ShiftY;//30;
  int Ydiff = MathCeil( FontSize * 1.72 );

  DeleteObj();

 
  string text = GetHeader();
  string opTime = TimeToStr( openTime/*TimeCurrent() - BeforeMin * 60*/ );
  ObjCreate( 0, ObjPrefix + "-n" + opTime, text, clrWhite, TextY, ShiftX );
  //ObjCreateBG( 0, ObjPrefix + "--" + opTime, "gg" , clrBlack , TextY, ShiftX );

  TextY += Ydiff;


 
  for( i = 0; i < size; i++ ) {
    int n = Data[i][1];
   
    text = Symbols[n][0];
    ObjCreate( 0, ObjPrefix + "-n" + Symbols[n][0] + " " + DoubleToStr( Data[i][0], 4 ), text, GetFontColor( n ), TextY, ShiftX );
    ObjCreateBG( 0, ObjPrefix + "--" + Symbols[n][0] + " " + DoubleToStr( Data[i][0], 4 ), "gg" , GetColor( max, min, Data[i][0],n ) , TextY,  ShiftX );

    TextY += Ydiff;
  }

  return( 0 );
}
//+------------------------------------------------------------------+

double GetValue( int n )
{
  //double ret;
  if( Symbols[n][2] == "BASE" ) return( 0.0 );

 
  double cl = iClose( Symbols[n][1], TargetPeriod, 0 );  
  int bk = iBarShift( Symbols[n][1], TargetPeriod, TimeCurrent() - BeforeMin * 60 );
  double op = iOpen( Symbols[n][1], TargetPeriod, bk );
  int tm = iTime( Symbols[n][1], TargetPeriod, bk );

 // if( openTime < tm ) openTime = tm;

  if( cl == 0.0 ) return( 0.0 );
  if( op == 0.0 ) return( 0.0 );

  if( Symbols[n][2] == "L" ) {
    return( ( cl - op ) / op );
  }
  if( Symbols[n][2] == "R" ) {
    return( ( ( 1 / cl ) - ( 1 / op ) ) / ( 1 / op ) );
  }
  return( Symbols[n][2]);
}
color GetFontColor( int n )
{

  if( Symbols[n][2] == "BASE" ) return( clrBlack );

  
  if( iBars( Symbols[n][1], TargetPeriod ) < 2048 ) {
   // Print( Symbols[n][1] + "_" + TargetPeriod + " Bars = " + iBars( Symbols[n][1], TargetPeriod ) );
    return( Yellow );
  }

  
  int bk = iBarShift( Symbols[n][1], TargetPeriod, TimeCurrent() - BeforeMin * 60 );
  double op = iOpen( Symbols[n][1], TargetPeriod, bk );
  if( op == 0.0 ) return( Red );

  return( Black );
}





void ObjCreate( int  win_idx, string objname, string text, color textColor, int TextY, int TextX = 10 )
{
  ObjectDelete( objname+ID );
  ObjectCreate( objname+ID, OBJ_LABEL, win_idx, 0, 0 );
  ObjectSetText( objname+ID, text, FontSize, FontName, textColor );
  ObjectSet( objname+ID, OBJPROP_CORNER, Corner );
  ObjectSet( objname+ID, OBJPROP_XDISTANCE, TextX );
  ObjectSet( objname+ID, OBJPROP_YDISTANCE, TextY ); //c
}
void ObjCreateBG( int  win_idx, string objname, string text, color textColor, int TextY, int TextX = 10 )
{
  ObjectDelete( objname+ID );
  ObjectCreate( objname+ID, OBJ_LABEL, win_idx, 0, 0 );
  
  ObjectSetText( objname+ID, text, FontSize + 2,  "Webdings", textColor );
  ObjectSet( objname+ID, OBJPROP_CORNER, Corner );
  ObjectSet( objname+ID, OBJPROP_BACK,true  );
  ObjectSet( objname+ID, OBJPROP_XDISTANCE, TextX - 2 );
  ObjectSet( objname+ID, OBJPROP_YDISTANCE, TextY - 3 ); //c
}


color GetColor( double min, double max , double val,int n )
{
 // if( Symbols[n][2] == "BASE" ) return( clrDarkGray );  
  if( max == min ) return( White );
  double r = ( val - min ) / ( max - min ); //r = 0~1

  
  if( r > 0.5 ) {
    color x = 0x0000FF + MathFloor( 0xFF * ( 1 - ( r - 0.5 ) * 2 ) ) * 0x10100;
  //Print(r," ",IntegerToHexString(x));
    return( x );
  } else {
   
    x = 0xFF0000 + MathFloor( 0xFF * ( r + 0.5 ) ) * 0x101;
  //Print(r," ",IntegerToHexString(x));
    return( x );
  }

  return( Blue );
}


string IntegerToHexString( int integer_number )
{
  string hex_string = "00000000";
  int    value, shift = 28;
//   Print("Parameter for IntegerHexToString is ",integer_number);
//----
  for( int i = 0; i < 8; i++ ) {
    value = ( integer_number >> shift ) & 0x0F;
    if( value < 10 ) hex_string = StringSetChar( hex_string, i, value + '0' );
    else         hex_string = StringSetChar( hex_string, i, ( value - 10 ) + 'A' );
    shift -= 4;
  }
//----
  return( hex_string );
}

string GetHeader()
{
  if( BeforeMin < 60 ) return("M" + BeforeMin );
  if( BeforeMin < 1440 ) return(  "H"+ (BeforeMin / 60.0 ) );
  if( BeforeMin < 10080 ) return( "D"+( BeforeMin / 60.0 / 24 ) );
  if( BeforeMin < 43200 ) return("W"+( BeforeMin / 60.0 / 24 / 7 ) );
 else return(  "MN" );
}
string DoubleToStrEx( double x, int n )
{
  int i;
  for( i = 0; i <= 8; i++ ) {
    if( MathAbs( x - NormalizeDouble( x, i ) ) < 0.00000001 ) break;
  }
  if( i > n ) i = n;
  return( DoubleToStr( x, i ) );
}