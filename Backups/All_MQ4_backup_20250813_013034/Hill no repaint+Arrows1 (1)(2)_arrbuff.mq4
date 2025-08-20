//------------------------------------------------------------------
#property copyright "Hill"
#property link      "Romio.com"
//------------------------------------------------------------------
//modified 9 aug 2020
// - request for arrow objs to have buffers
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Orange
#property indicator_color2 DarkGray
#property indicator_color3 Orange
#property indicator_color4 LimeGreen
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

//
//
//
//
//

extern int    RsiLength  = 14;
extern int    RsiPrice   = PRICE_CLOSE;
extern int    HalfLength = 12;
extern int    DevPeriod  = 100;
extern double Deviations = 1.5;
extern bool   UseAlert   = true;
extern bool   DrawArrows = true;

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   HalfLength=MathMax(HalfLength,1);
         SetIndexBuffer(0,buffer1); 
         SetIndexBuffer(1,buffer2);
         SetIndexBuffer(2,buffer3); 
         SetIndexBuffer(3,buffer4);
         SetIndexBuffer(4,buffer5); 
         SetIndexBuffer(5,buffer6);
         
   return(0);
}
int deinit() 
{
  DellObj(PrefixArrow);
  
 return(0); 
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,j,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);

   //
   //
   //
   //
   //
   static datetime timeLastAlert = NULL;
   
   for (i=limit; i>=0; i--) buffer1[i] = iRSI(NULL,0,RsiLength,RsiPrice,i);
   for (i=limit; i>=0; i--)
   {
      double dev  = iStdDevOnArray(buffer1,0,DevPeriod,0,MODE_SMA,i);
      double sum  = (HalfLength+1)*buffer1[i];
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*buffer1[i+j];
         sumw += k;
         if (j<=i)
         {
            sum  += k*buffer1[i-j];
            sumw += k;
         }
      }
      buffer2[i] = sum/sumw;
      buffer3[i] = buffer2[i]+dev*Deviations;
      buffer4[i] = buffer2[i]-dev*Deviations;
      
      if( buffer1[i] >= buffer3[i] /*&& buffer1[i+1] < buffer3[i+1]*/ )
      { 
         if( DrawArrows ){ ArrowDn(Time[i], High[i]);buffer5[i]=High[i];}
         
         if( UseAlert && i == 0 && Time[0] != timeLastAlert )
         {
            Alert("Signal DOWN!");
            timeLastAlert = Time[0];
         }
      }
      
      if( buffer1[i] <= buffer4[i] /*&& buffer1[i+1] > buffer4[i+1] */)
      { 
         if( DrawArrows ){ ArrowUp(Time[i], Low[i]);buffer6[i]=Low[i];}

         if( UseAlert && i == 0 && Time[0] != timeLastAlert )
         {
            Alert("Signal UP!");
            timeLastAlert = Time[0];
         }         
      }
   }
   return(0);
}


    color ColorDn = Crimson;
 color ColorUp = DodgerBlue;
  int     CodDn = 226;
  int     CodUp = 225;
 extern int      Sise = 11;
  string   Font = "Verdana";
 
// ti init() if(ObjectFind("100s")<0)GetText(3,"100s","BuySell Pro",LawnGreen,5,5,7); 
 
 
string PrefixArrow = "ArrowsHill"; 
//+==================================================================+
//+==================================================================+
void ArrowUp(datetime tim,double pr)
{if(ObjectFind(PrefixArrow+"TextUp"+tim)==-1)
 {if(ObjectCreate(PrefixArrow+"TextUp"+tim,OBJ_TEXT,0,tim,pr-GetDistSdvig()))
  ObjectSetText(PrefixArrow+"TextUp"+tim,CharToStr(CodUp),Sise,"WingDings",ColorUp);
 }
}

//+==================================================================+
//+==================================================================+
void ArrowDn(datetime tim,double pr)
{if(ObjectFind(PrefixArrow+"TextDn"+tim)==-1)
 {if(ObjectCreate(PrefixArrow+"TextDn"+tim,OBJ_TEXT,0,tim,pr+GetDistSdvig()))
  ObjectSetText(PrefixArrow+"TextDn"+tim,CharToStr(CodDn),Sise,"WingDings",ColorDn);
 }
}
extern double TextSdvigMnoj = 2;
double GetDistSdvig(){  return( iATR(NULL, 0, 100, 1) * TextSdvigMnoj); }
//+------------------------------------------------------------------+
//
void DellObj( string dell )
{
  string name;
   for(int i = ObjectsTotal()-1 ; i >=0 ; i-- ){
      name = ObjectName(i);
      if( StringFind(name, dell) != EMPTY )
         ObjectDelete(name);
   }
}