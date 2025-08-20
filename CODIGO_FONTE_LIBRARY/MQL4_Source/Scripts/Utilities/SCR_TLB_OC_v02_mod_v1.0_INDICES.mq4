//+------------------------------------------------------------------+
//|                                                       SR_TLB.mq4 |
//|                     Support and Resistance MTF Trend Line Breaks |
//|                                  Copyright © 2008, Ulterior (FF) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Ulterior (FF)"
#property link      "http://localhost"
//----
#property indicator_chart_window
#property indicator_buffers 0
//----
extern int LB = 3;
extern int maxBarsForPeriod = 1000;
extern bool showM01 = true;
extern bool showM05 = true;
extern bool showM15 = true;
extern bool showM30 = true;
extern bool showH01 = true;
extern bool showH04 = true;
extern bool showD01 = true;
extern bool showW01 = true;
extern bool showMN1 = true;
extern color Res_Color = Red,
             Sup_Color = Green,
             ResC_Color = Gray,
             SupC_Color = Gray;
extern int   LineWidth = 1;
extern bool ShowC = true;
//----

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("3 Line Break On Chart +levels");
//---- indicators

  set_prevBarTime( PERIOD_M1, NULL );
  set_prevBarTime( PERIOD_M5, NULL );
  set_prevBarTime( PERIOD_M15, NULL );
  set_prevBarTime( PERIOD_M30, NULL );
  set_prevBarTime( PERIOD_H1, NULL );
  set_prevBarTime( PERIOD_H4, NULL );
  set_prevBarTime( PERIOD_D1, NULL );
  set_prevBarTime( PERIOD_W1, NULL );
  set_prevBarTime( PERIOD_MN1, NULL );

  return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M1 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M1 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M1 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M1 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M5 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M5 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M5 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M5 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M15 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M15 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M15 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M15 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M30 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M30 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M30 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_M30 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H1 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H1 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H1 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H1 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H4 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H4 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H4 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_H4 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_D1 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_D1 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_D1 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_D1 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_W1 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_W1 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_W1 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_W1 ), " Res C" ) );

  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_MN1 ), " Sup" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_MN1 ), " Res" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_MN1 ), " Sup C" ) );
  DeleteHLineObject( StringConcatenate( getPeriodAsString( PERIOD_MN1 ), " Res C" ) );

//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Diap( int mt4Period, bool up, int C, int shift )
  { 
   int i;
   double MM;
   if(up)
     {
       MM = get_max( mt4Period, shift );
       for(i = 1; i < C; i++)
           if(get_max( mt4Period, shift-i ) > MM)
               MM = get_max( mt4Period, shift-i );  
     }
   if(!up)
     {
       MM = get_min( mt4Period, shift );
       for(i = 1; i < C; i++)
           if(get_min( mt4Period, shift-i ) < MM)
               MM = get_min( mt4Period, shift-i );  
     }  
  return(MM);
  }
  
void EmulateDoubleBuffer( double buffer[], int numBars )
{
   //---- INDICATOR BUFFERS EMULATION
   if(ArraySize(buffer) < numBars)
     {
       ArraySetAsSeries(buffer, false);
       //----  
       ArrayResize(buffer, numBars); 
       //----
       ArraySetAsSeries(buffer, true);
     } 
}  

//+------------------------------------------------------------------+
//|  Custom indicator initialization function                        |
//+------------------------------------------------------------------+
void DeleteHLineObject(string name)
{
   ObjectDelete(name);
   ObjectDelete(name + "_Label");
}
//+------------------------------------------------------------------+
//|  Custom indicator initialization function                        |
//+------------------------------------------------------------------+
void ShowHLineObject(string name, color clr, int style, double dValue, int shift )
{
   if(ObjectFind(name)!= 0)
   {
      CreateHLineObject(name,clr, style, dValue, shift);         
   }    
   
   //if(ShowLineLabels)
   {
      ObjectSet(name + "_Label",OBJPROP_PRICE1,dValue);  
      ObjectSet(name + "_Label",OBJPROP_TIME1,Time[0] + Period() * shift);  
      ObjectSet(name + "_Label",OBJPROP_STYLE, style);  
   }
   
   ObjectSet(name, OBJPROP_PRICE1, dValue);
}
//+------------------------------------------------------------------+
//|  Custom indicator initialization function                        |
//+------------------------------------------------------------------+
void CreateHLineObject(string name, color clr, int style, double dValue, int shift )
{
   //if(ShowLineLabels)
   {
      ObjectCreate   (name + "_Label", OBJ_TEXT, 0,Time[0] + Period() * shift, dValue); 
      ObjectSetText  (name + "_Label",  name, 7, "Verdana", clr);
   }
   
   ObjectCreate   (name,            OBJ_HLINE, 0, Time[0], dValue);
   ObjectSet      (name,            OBJPROP_STYLE, style );
   ObjectSet      (name,            OBJPROP_COLOR, clr);  
   ObjectSet      (name,            OBJPROP_WIDTH, LineWidth);   
}

string getPeriodAsString( int mt4Period )
{
 string periodname = 0;
 switch( mt4Period )
 {
  case PERIOD_M1:  { periodname = "M1"; break; }
  case PERIOD_M5:  { periodname = "M5"; break; }
  case PERIOD_M15: { periodname = "M15"; break; }
  case PERIOD_M30: { periodname = "M30"; break; }
  case PERIOD_H1:  { periodname = "H1"; break; }
  case PERIOD_H4:  { periodname = "H4"; break; }
  case PERIOD_D1:  { periodname = "D1"; break; }
  case PERIOD_W1:  { periodname = "W1"; break; }
  case PERIOD_MN1: { periodname = "MN1"; break; }
 }
 
 return (periodname);
}
 
static datetime prevBarTime_M01 = NULL;  
static datetime prevBarTime_M05 = NULL;  
static datetime prevBarTime_M15 = NULL;  
static datetime prevBarTime_M30 = NULL;  
static datetime prevBarTime_H01 = NULL;  
static datetime prevBarTime_H04 = NULL;  
static datetime prevBarTime_D01 = NULL;  
static datetime prevBarTime_W01 = NULL;  
static datetime prevBarTime_MN1 = NULL;  
    
void set_prevBarTime( int mt4Period, datetime value )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { prevBarTime_M01 = value; break; }
  case PERIOD_M5:  { prevBarTime_M05 = value; break; }
  case PERIOD_M15: { prevBarTime_M15 = value; break; }
  case PERIOD_M30: { prevBarTime_M30 = value; break; }
  case PERIOD_H1:  { prevBarTime_H01 = value; break; }
  case PERIOD_H4:  { prevBarTime_H04 = value; break; }
  case PERIOD_D1:  { prevBarTime_D01 = value; break; }
  case PERIOD_W1:  { prevBarTime_W01 = value; break; }
  case PERIOD_MN1: { prevBarTime_MN1 = value; break; } 
 }
}

datetime get_prevBarTime( int mt4Period )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { return (prevBarTime_M01); break; }
  case PERIOD_M5:  { return (prevBarTime_M05); break; }
  case PERIOD_M15: { return (prevBarTime_M15); break; }
  case PERIOD_M30: { return (prevBarTime_M30); break; }
  case PERIOD_H1:  { return (prevBarTime_H01); break; }
  case PERIOD_H4:  { return (prevBarTime_H04); break; }
  case PERIOD_D1:  { return (prevBarTime_D01); break; }
  case PERIOD_W1:  { return (prevBarTime_W01); break; }
  case PERIOD_MN1: { return (prevBarTime_MN1); break; } 
 }
}
    
static datetime prevBarCount_M01 = NULL;  
static datetime prevBarCount_M05 = NULL;  
static datetime prevBarCount_M15 = NULL;  
static datetime prevBarCount_M30 = NULL;  
static datetime prevBarCount_H01 = NULL;  
static datetime prevBarCount_H04 = NULL;  
static datetime prevBarCount_D01 = NULL;  
static datetime prevBarCount_W01 = NULL;  
static datetime prevBarCount_MN1 = NULL;  
    
void set_prevBarCount( int mt4Period, int value )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { prevBarCount_M01 = value; break; }
  case PERIOD_M5:  { prevBarCount_M05 = value; break; }
  case PERIOD_M15: { prevBarCount_M15 = value; break; }
  case PERIOD_M30: { prevBarCount_M30 = value; break; }
  case PERIOD_H1:  { prevBarCount_H01 = value; break; }
  case PERIOD_H4:  { prevBarCount_H04 = value; break; }
  case PERIOD_D1:  { prevBarCount_D01 = value; break; }
  case PERIOD_W1:  { prevBarCount_W01 = value; break; }
  case PERIOD_MN1: { prevBarCount_MN1 = value; break; } 
 }
}

int get_prevBarCount( int mt4Period )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { return (prevBarCount_M01); break; }
  case PERIOD_M5:  { return (prevBarCount_M05); break; }
  case PERIOD_M15: { return (prevBarCount_M15); break; }
  case PERIOD_M30: { return (prevBarCount_M30); break; }
  case PERIOD_H1:  { return (prevBarCount_H01); break; }
  case PERIOD_H4:  { return (prevBarCount_H04); break; }
  case PERIOD_D1:  { return (prevBarCount_D01); break; }
  case PERIOD_W1:  { return (prevBarCount_W01); break; }
  case PERIOD_MN1: { return (prevBarCount_MN1); break; } 
 }
}

double TLBMax_M01[];
double TLBMax_M05[];
double TLBMax_M15[];
double TLBMax_M30[];
double TLBMax_H01[];
double TLBMax_H04[];
double TLBMax_D01[];
double TLBMax_W01[];
double TLBMax_MN1[];

double TLBMin_M01[];
double TLBMin_M05[];
double TLBMin_M15[];
double TLBMin_M30[];
double TLBMin_H01[];
double TLBMin_H04[];
double TLBMin_D01[];
double TLBMin_W01[];
double TLBMin_MN1[];
    
void set_max( int mt4Period, int shift, double value )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { TLBMax_M01[ shift ] = value; break; }
  case PERIOD_M5:  { TLBMax_M05[ shift ] = value; break; }
  case PERIOD_M15: { TLBMax_M15[ shift ] = value; break; }
  case PERIOD_M30: { TLBMax_M30[ shift ] = value; break; }
  case PERIOD_H1:  { TLBMax_H01[ shift ] = value; break; }
  case PERIOD_H4:  { TLBMax_H04[ shift ] = value; break; }
  case PERIOD_D1:  { TLBMax_D01[ shift ] = value; break; }
  case PERIOD_W1:  { TLBMax_W01[ shift ] = value; break; }
  case PERIOD_MN1: { TLBMax_MN1[ shift ] = value; break; }
 }
}

double get_max( int mt4Period, int shift )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { return(TLBMax_M01[ shift ]); break; }
  case PERIOD_M5:  { return(TLBMax_M05[ shift ]); break; }
  case PERIOD_M15: { return(TLBMax_M15[ shift ]); break; }
  case PERIOD_M30: { return(TLBMax_M30[ shift ]); break; }
  case PERIOD_H1:  { return(TLBMax_H01[ shift ]); break; }
  case PERIOD_H4:  { return(TLBMax_H04[ shift ]); break; }
  case PERIOD_D1:  { return(TLBMax_D01[ shift ]); break; }
  case PERIOD_W1:  { return(TLBMax_W01[ shift ]); break; }
  case PERIOD_MN1: { return(TLBMax_MN1[ shift ]); break; }
 }
}
    
void set_min( int mt4Period, int shift, double value )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { TLBMin_M01[ shift ] = value; break; }
  case PERIOD_M5:  { TLBMin_M05[ shift ] = value; break; }
  case PERIOD_M15: { TLBMin_M15[ shift ] = value; break; }
  case PERIOD_M30: { TLBMin_M30[ shift ] = value; break; }
  case PERIOD_H1:  { TLBMin_H01[ shift ] = value; break; }
  case PERIOD_H4:  { TLBMin_H04[ shift ] = value; break; }
  case PERIOD_D1:  { TLBMin_D01[ shift ] = value; break; }
  case PERIOD_W1:  { TLBMin_W01[ shift ] = value; break; }
  case PERIOD_MN1: { TLBMin_MN1[ shift ] = value; break; }
 }
}

double get_min( int mt4Period, int shift )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { return(TLBMin_M01[ shift ]); break; }
  case PERIOD_M5:  { return(TLBMin_M05[ shift ]); break; }
  case PERIOD_M15: { return(TLBMin_M15[ shift ]); break; }
  case PERIOD_M30: { return(TLBMin_M30[ shift ]); break; }
  case PERIOD_H1:  { return(TLBMin_H01[ shift ]); break; }
  case PERIOD_H4:  { return(TLBMin_H04[ shift ]); break; }
  case PERIOD_D1:  { return(TLBMin_D01[ shift ]); break; }
  case PERIOD_W1:  { return(TLBMin_W01[ shift ]); break; }
  case PERIOD_MN1: { return(TLBMin_MN1[ shift ]); break; }
 }
}
    
void emulate_tlbmaxmin( int mt4Period, int numBars )
{
 switch( mt4Period )
 {
  case PERIOD_M1:  { EmulateDoubleBuffer(TLBMax_M01, numBars ); EmulateDoubleBuffer(TLBMin_M01, numBars ); break; }
  case PERIOD_M5:  { EmulateDoubleBuffer(TLBMax_M05, numBars ); EmulateDoubleBuffer(TLBMin_M05, numBars ); break; }
  case PERIOD_M15: { EmulateDoubleBuffer(TLBMax_M15, numBars ); EmulateDoubleBuffer(TLBMin_M15, numBars ); break; }
  case PERIOD_M30: { EmulateDoubleBuffer(TLBMax_M30, numBars ); EmulateDoubleBuffer(TLBMin_M30, numBars ); break; }
  case PERIOD_H1:  { EmulateDoubleBuffer(TLBMax_H01, numBars ); EmulateDoubleBuffer(TLBMin_H01, numBars ); break; }
  case PERIOD_H4:  { EmulateDoubleBuffer(TLBMax_H04, numBars ); EmulateDoubleBuffer(TLBMin_H04, numBars ); break; }
  case PERIOD_D1:  { EmulateDoubleBuffer(TLBMax_D01, numBars ); EmulateDoubleBuffer(TLBMin_D01, numBars ); break; }
  case PERIOD_W1:  { EmulateDoubleBuffer(TLBMax_W01, numBars ); EmulateDoubleBuffer(TLBMin_W01, numBars ); break; }
  case PERIOD_MN1: { EmulateDoubleBuffer(TLBMax_MN1, numBars ); EmulateDoubleBuffer(TLBMin_MN1, numBars ); break; }
 }
}   
    
void displayPeriod( int mt4Period )
{
  if( get_prevBarTime( mt4Period ) == NULL || get_prevBarTime( mt4Period ) != iTime( Symbol(), mt4Period, 0 ) ||
      get_prevBarCount( mt4Period ) == NULL || get_prevBarCount( mt4Period ) != iBars( Symbol(), mt4Period ) )
  {
   set_prevBarTime( mt4Period, iTime( Symbol(), mt4Period, 0 ));
   set_prevBarCount( mt4Period, iBars( Symbol(), mt4Period ));
  } 
  else return;

  int numBars = iBars( Symbol(), mt4Period );   
  if( maxBarsForPeriod > 0 && numBars > maxBarsForPeriod ) numBars = maxBarsForPeriod; 
  int TLBBuffShift = 0;
  int limit=numBars;

  emulate_tlbmaxmin( mt4Period, numBars );
  
   int i, j;
   j = 1;
   while( iClose( Symbol(), mt4Period, limit-1) == iClose( Symbol(), mt4Period, limit-1-j) )
   {
       j++;
       if(j > limit-1)
        break;
   }    
      
   if(iClose( Symbol(), mt4Period, limit-1) > iClose( Symbol(), mt4Period, limit-1-j))
     {
       set_max( mt4Period, 0, iClose( Symbol(), mt4Period, limit-1));
       set_min( mt4Period, 0, iClose( Symbol(), mt4Period, limit-1-j));
     } 
   if(iClose( Symbol(), mt4Period, limit-1) < iClose( Symbol(), mt4Period, limit-1-j))
     {
       set_max( mt4Period, 0, iClose( Symbol(), mt4Period, limit-1-j));
       set_min( mt4Period, 0, iClose( Symbol(), mt4Period, limit-1));
     } 
   
   for(i = 1; i < LB; i++)
     {
       while(iClose( Symbol(), mt4Period, limit-j) <= Diap(mt4Period, true, i, TLBBuffShift) && iClose( Symbol(), mt4Period, limit-j) >= Diap(mt4Period, false, i, TLBBuffShift))
       {
         j++;

         if(j > limit-1)
         break;
       }     
       if(j > limit-1)
           break;   

       if(iClose( Symbol(), mt4Period, limit-j) > get_max( mt4Period, i-1 ))
         {
           set_max( mt4Period, i, iClose( Symbol(), mt4Period, limit-j));
           set_min( mt4Period, i, get_max( mt4Period, i-1 ));
           TLBBuffShift++;
         }
       if(iClose( Symbol(), mt4Period, limit-j) < get_min( mt4Period, i-1 ))
         {
           set_min( mt4Period, i, iClose( Symbol(), mt4Period, limit-j));
           set_max( mt4Period, i, get_min( mt4Period, i-1 ));
           TLBBuffShift++;
         }  
     }
     
   for(i = LB; i < limit; i++)   
     {    
       while(iClose( Symbol(), mt4Period, limit-j) <= Diap(mt4Period, true, LB, TLBBuffShift) && iClose( Symbol(), mt4Period, limit-j) >= Diap(mt4Period, false, LB, TLBBuffShift))
         {
           j++;
           if(j > limit-1)
               break;
         }
       if(j > limit-1)
           break;   

       if(iClose( Symbol(), mt4Period, limit-j) > get_max( mt4Period, i-1 ))
         {
           set_max( mt4Period, i, iClose( Symbol(), mt4Period, limit-j));
           set_min( mt4Period, i, get_max( mt4Period, i-1 ));
           TLBBuffShift++;
         }
       if(iClose( Symbol(), mt4Period, limit-j) < get_min( mt4Period, i-1 ))
         {
           set_min( mt4Period, i, iClose( Symbol(), mt4Period, limit-j));
           set_max( mt4Period, i, get_min( mt4Period, i-1 ));
           TLBBuffShift++;
         }  
     }
   
   double sup = 0, res = 0, supc = 0, resc = 0;   
   int redCnt=0, blueCnt=0; 
   int numObj = 0;  
   for(i = 1; i <= TLBBuffShift; i++)
     {
       if(get_max( mt4Period, i ) > get_max( mt4Period, i-1 ))
         {
           if( blueCnt >= LB )   
            sup = get_max( mt4Period, i-LB );
           else
            sup = get_min( mt4Period, i-blueCnt-1 ); 
           
           resc = get_max( mt4Period, i );
           supc = 0;
           res = 0;

           blueCnt++;
           redCnt=0;                        
         }
       if(get_max( mt4Period, i ) < get_max( mt4Period, i-1 ))
         {
           if( redCnt >= LB )   
            res = get_min( mt4Period, i-LB );
           else
            res = get_max( mt4Period, i-redCnt-1 );

           supc = get_min( mt4Period, i );
           sup = 0;
           resc = 0;
           
           blueCnt=0;
           redCnt++;             
         }
       
     }        

     if( sup > 0.0 )     
      ShowHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Sup" ), Sup_Color, STYLE_SOLID, sup, 500 );
     else
      DeleteHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Sup" ) );             

     if( res > 0.0 )
      ShowHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Res" ), Res_Color, STYLE_SOLID, res, 500 );            
     else
      DeleteHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Res" ) );
      
     if( supc > 0.0 && ShowC)
      ShowHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Sup C" ), SupC_Color, STYLE_DASHDOTDOT, supc, 1200 );
     else
      DeleteHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Sup C" ) );
      
     if( resc > 0.0 && ShowC)
      ShowHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Res C" ), ResC_Color, STYLE_DASHDOTDOT, resc, 1200 );            
     else
      DeleteHLineObject( StringConcatenate( getPeriodAsString( mt4Period ), " Res C" ) );             
}    
    
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int start()
{
  if( Period() <= PERIOD_M1 && showM01 ) displayPeriod( PERIOD_M1 );
  if( Period() <= PERIOD_M5 && showM05 ) displayPeriod( PERIOD_M5 );
  if( Period() <= PERIOD_M15 && showM15 ) displayPeriod( PERIOD_M15 );
  if( Period() <= PERIOD_M30 && showM30 ) displayPeriod( PERIOD_M30 );
  if( Period() <= PERIOD_H1 && showH01 ) displayPeriod( PERIOD_H1 );
  if( Period() <= PERIOD_H4 && showH04 ) displayPeriod( PERIOD_H4 );
  if( Period() <= PERIOD_D1 && showD01 ) displayPeriod( PERIOD_D1 );
  if( Period() <= PERIOD_W1 && showW01 ) displayPeriod( PERIOD_W1 );
  if( Period() <= PERIOD_MN1 && showMN1 ) displayPeriod( PERIOD_MN1 );

 return(0);
}
//+------------------------------------------------------------------+

