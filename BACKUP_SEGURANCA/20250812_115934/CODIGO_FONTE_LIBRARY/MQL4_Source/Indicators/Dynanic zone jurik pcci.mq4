#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  Goldenrod
#property indicator_color2  LimeGreen
#property indicator_color3  LimeGreen
#property indicator_color4  Red
#property indicator_color5  Red
#property indicator_color6  DarkSlateGray
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style6  STYLE_DOT
#property indicator_width1  2

//
//
//
//
//

#import "dynamicZone.dll"
   double dzBuyP(double& sourceArray[], double probabiltyValue, int lookBack, int bars, int i, double precision);
   double dzSellP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
#import

//
//
//
//
//
//
//
//
//
//

extern string TimeFrame                = "Current time frame";
extern int    PcciSmoothLength         = 10;
extern double PcciSmoothPhase          = 0;
extern bool   PcciSmoothDouble         = false;
extern int    DzLookBackBars           = 70;
extern double DzStartBuyProbability1   = 0.10;
extern double DzStartBuyProbability2   = 0.25;
extern double DzStartSellProbability1  = 0.10;
extern double DzStartSellProbability2  = 0.25;
extern bool   Interpolate              = true;

//
//
//
//
//

double pcci[];
double bl1Buffer[];
double bl2Buffer[];
double sl1Buffer[];
double sl2Buffer[];
double zliBuffer[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
  {
  IndicatorBuffers(6);
    SetIndexBuffer(0,pcci);
    SetIndexBuffer(1,bl1Buffer);
    SetIndexBuffer(2,bl2Buffer);
    SetIndexBuffer(3,sl2Buffer);
    SetIndexBuffer(4,sl1Buffer);
    SetIndexBuffer(5,zliBuffer);
    
    //
    //
    //
    //
    //
   
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   
   //
   //
   //
   //
   //
   
 IndicatorShortName(timeFrameToString(timeFrame)+"  Dynamic zone jurik pcci");
   
 return(0);
}
    
//
//
//
//
//

int deinit(){  return(0); }

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,n,k,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1); 
           if (returnBars)  { pcci[0] = limit+1; return(0); }
   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
   
   //
   //
   //
   //
   //        
      
   for(i=limit; i>=0; i--)
   {  
      double response =
       
              0.1177628838235*Close[i+0]
             +0.1170077388431*Close[i+1]
             +0.1147601209029*Close[i+2]
             +0.1110729054065*Close[i+3]
             +0.1060324421434*Close[i+4]
             +0.0997560988008*Close[i+5]
             +0.0923890376402*Close[i+6]
             +0.0841000389219*Close[i+7]
             +0.0750766919597*Close[i+8]
             +0.0655202662708*Close[i+9]
             +0.0556401583046*Close[i+10]
             +0.0456482572592*Close[i+11]
             +0.0357530528012*Close[i+12]
             +0.02615415804227*Close[i+13]
             +0.01703731282680*Close[i+14]
             +0.00856960311288*Close[i+15]
             +0.000895555708556*Close[i+16]
             -0.00586627422066*Close[i+17]
             -0.01162552971203*Close[i+18]
             -0.01632152444323*Close[i+19]
             -0.01992414580732*Close[i+20]
             -0.02243335117589*Close[i+21]
             -0.02387813894599*Close[i+22]
             -0.02431430200598*Close[i+23]
             -0.02382176331725*Close[i+24]
             -0.02250140527159*Close[i+25]
             -0.02047075493180*Close[i+26]
             -0.01786000052706*Close[i+27]
             -0.01480733499641*Close[i+28]
             -0.01145463232852*Close[i+29]
             -0.00794304696010*Close[i+30]
             -0.00440829083275*Close[i+31]
             -0.000977238472653*Close[i+32]
             +0.002235823933755*Close[i+33]
             +0.00513191787383*Close[i+34]
             +0.00762972457736*Close[i+35]
             +0.00966747623918*Close[i+36]
             +0.01120310303187*Close[i+37]
             +0.01221499285956*Close[i+38]
             +0.01270127547603*Close[i+39]
             +0.01267881242200*Close[i+40]
             +0.01218165493397*Close[i+41]
             +0.01125820035359*Close[i+42]
             +0.00996954486984*Close[i+43]
             +0.00838605323109*Close[i+44]
             +0.00658436935337*Close[i+45]
             +0.00464439195323*Close[i+46]
             +0.002645759417416*Close[i+47]
             +0.000666068159555*Close[i+48]
             -0.001222776729259*Close[i+49]
             -0.002956488520058*Close[i+50]
             -0.00448011021214*Close[i+51]
             -0.00574988855361*Close[i+52]
             -0.00673332989225*Close[i+53]
             -0.00741117882839*Close[i+54]
             -0.00777644547070*Close[i+55]
             -0.00783388153265*Close[i+56]
             -0.00759966748743*Close[i+57]
             -0.00709931269272*Close[i+58]
             -0.00636769053766*Close[i+59]
             -0.00544559940274*Close[i+60]
             -0.00437852874428*Close[i+61]
             -0.00321542503890*Close[i+62]
             -0.002005580069262*Close[i+63]
             -0.000798178859997*Close[i+64]
             +0.000361723322003*Close[i+65]
             +0.001433101593600*Close[i+66]
             +0.002380073229874*Close[i+67]
             +0.00317453700490*Close[i+68]
             +0.00379492177651*Close[i+69]
             +0.00422884523807*Close[i+70]
             +0.00447038314289*Close[i+71]
             +0.00452100306476*Close[i+72]
             +0.00439082398691*Close[i+73]
             +0.00409492037175*Close[i+74]
             +0.00365528338580*Close[i+75]
             +0.003096238149856*Close[i+76]
             +0.002446112685573*Close[i+77]
             +0.001736376831290*Close[i+78]
             +0.000996103380422*Close[i+79]
             +0.0002557237615143*Close[i+80]
             -0.000458282529397*Close[i+81]
             -0.001119581482823*Close[i+82]
             -0.001704893115208*Close[i+83]
             -0.002199032152313*Close[i+84]
             -0.002586916898054*Close[i+85]
             -0.002861741841535*Close[i+86]
             -0.003018651749353*Close[i+87]
             -0.003060101508137*Close[i+88]
             -0.002997112675297*Close[i+89]
             -0.002834938217095*Close[i+90]
             -0.002589089321820*Close[i+91]
             -0.002272072078644*Close[i+92]
             -0.001902835889698*Close[i+93]
             -0.001502872027811*Close[i+94]
             -0.001077466851623*Close[i+95]
             -0.000655481642188*Close[i+96]
             -0.0002511660753314*Close[i+97]
             +0.0001137882502083*Close[i+98]
             +0.000426098842482*Close[i+99]
             +0.000714775119642*Close[i+100]
             +0.000916639580735*Close[i+101]
             +0.001063116482197*Close[i+102]
             +0.001143113996535*Close[i+103]
             +0.001159315803654*Close[i+104]
             +0.00922554212244*Close[i+105];
             
             //
             //
             //
             //
             //
             
             pcci[i] = iDSmooth(Close[i]-response,PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,i,0); 

             if (DzStartBuyProbability1  > 0) bl1Buffer[i] = dzBuyP (pcci, DzStartBuyProbability1,  DzLookBackBars, Bars, i, 0.0001);
             if (DzStartBuyProbability2  > 0) bl2Buffer[i] = dzBuyP (pcci, DzStartBuyProbability2,  DzLookBackBars, Bars, i, 0.0001);
             if (DzStartSellProbability1 > 0) sl1Buffer[i] = dzSellP(pcci, DzStartSellProbability1, DzLookBackBars, Bars, i, 0.0001);
             if (DzStartSellProbability2 > 0) sl2Buffer[i] = dzSellP(pcci, DzStartSellProbability2, DzLookBackBars, Bars, i, 0.0001);
                                              zliBuffer[i] = dzSellP(pcci, 0.5                    , DzLookBackBars, Bars, i, 0.0001);
         
             }
   
             return(0);
             }       
             
             //
             //
             //
             //
             //
             
             limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
             
             for (i=limit;i>=0; i--)
             {
               int y = iBarShift(NULL,timeFrame,Time[i]);
               
                pcci[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,0,y);
                bl1Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,1,y);
                bl2Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,2,y);
                sl2Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,3,y);
                sl1Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,4,y);
                zliBuffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",PcciSmoothLength,PcciSmoothPhase,PcciSmoothDouble,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,5,y);
                
                //
                //
                //
                //
                //
        
                if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
      
                //
                //
                //
                //
                //

                datetime time = iTime(NULL,timeFrame,y);
                   for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
                   for(k = 1; k < n; k++)
                   {
                       pcci[i+k]      = pcci[i]      + (pcci[i+n]      - pcci[i]     ) * k/n;
                       bl1Buffer[i+k] = bl1Buffer[i] + (bl1Buffer[i+n] - bl1Buffer[i]) * k/n;
                       bl2Buffer[i+k] = bl2Buffer[i] + (bl2Buffer[i+n] - bl2Buffer[i]) * k/n;
                       sl2Buffer[i+k] = sl2Buffer[i] + (sl2Buffer[i+n] - sl2Buffer[i]) * k/n;
                       sl1Buffer[i+k] = sl1Buffer[i] + (sl1Buffer[i+n] - sl1Buffer[i]) * k/n;
                       zliBuffer[i+k] = zliBuffer[i] + (zliBuffer[i+n] - zliBuffer[i]) * k/n;
                   }
                }
                
   return(0);
}

//+------------------------------------------------------------------+
//
//
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0)
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}
  
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//
//
//
//
//


