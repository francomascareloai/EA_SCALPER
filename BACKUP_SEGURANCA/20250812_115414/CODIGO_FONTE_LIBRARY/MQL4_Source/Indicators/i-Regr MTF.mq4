//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aquamarine
#property indicator_color2 SteelBlue
#property indicator_color3 SteelBlue


extern string TimeFrame = "Current time frame";
extern int degree = 3;
extern double kstd = 1.5;
extern int bars = 240;
extern int shift = 0;


//-----
double fx[],sqh[],sql[];

double ai[10,10],b[10],x[10],sx[20];
double sum; 
int ip,p,n,f;
double qq,mm,tt;
int ii,jj,kk,ll,nn;
double sq;

int i0 = 0;

/* 
void clear()
{
 int total = ObjectsTotal(); 
 for (int i=total-1; i >= 0; i--) 
 {
string name = ObjectName(i);
 if (StringFind(name, prefix) == 0) ObjectDelete(name);
 }
}
*/

string indicatorFileName;
int timeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
 SetIndexBuffer(0, fx); // Буферы массивов индикатора
 SetIndexBuffer(1, sqh);
 SetIndexBuffer(2, sql);

 SetIndexEmptyValue(0, 0.0);
 SetIndexEmptyValue(1, 0.0);
 SetIndexEmptyValue(2, 0.0);

 indicatorFileName = WindowExpertName();
 timeFrame = stringToTimeFrame(TimeFrame);

 SetIndexShift(0, shift*timeFrame/Period());
 SetIndexShift(1, shift*timeFrame/Period());
 SetIndexShift(2, shift*timeFrame/Period());

 return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
 //clear();
 return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
datetime LastUpdate;

int start()
{
 
 if (TimeCurrent() - LastUpdate < 60) return(0);   //Checks to see last update
   LastUpdate = TimeCurrent();
 
 if (timeFrame!=Period())
 {
 int limit = MathMin(Bars-1,bars*timeFrame/Period());
 for (int i=limit; i>=0; i--)
 {
int y = iBarShift(NULL,timeFrame,Time[i]);
 fx[i] = iCustom(NULL,timeFrame,indicatorFileName,"",degree,kstd,bars,0,0,y);
 sqh[i] = iCustom(NULL,timeFrame,indicatorFileName,"",degree,kstd,bars,0,1,y);
 sql[i] = iCustom(NULL,timeFrame,indicatorFileName,"",degree,kstd,bars,0,2,y);
 }
 SetIndexDrawBegin(0, MathMin(Bars-limit-1,0));
 SetIndexDrawBegin(1, MathMin(Bars-limit-1,0));
 SetIndexDrawBegin(2, MathMin(Bars-limit-1,0)); 
 return(0);
 }
 if (Bars < bars) return(0);

//---- 

 int mi; // переменная использующаяся только в start
 ip = bars;
 p=ip; // типа присваивание
 sx[1]=p+1; // примечание - [] - означает массив
 nn = degree+1;

 SetIndexDrawBegin(0, Bars-p-1);
 SetIndexDrawBegin(1, Bars-p-1);
 SetIndexDrawBegin(2, Bars-p-1); 

//----------------------sx-------------------------------------------------------------------
 for(mi=1;mi<=nn*2-2;mi++) // математическое выражение - для всех mi от 1 до nn*2-2 
 {
 sum=0;
 for(n=i0;n<=i0+p;n++)
 {
 sum+=MathPow(n,mi);
 }
 sx[mi+1]=sum;
 } 
 //----------------------syx-----------
 for(mi=1;mi<=nn;mi++)
 {
 sum=0.00000;
 for(n=i0;n<=i0+p;n++)
 {
 if(mi==1) sum+=Close[n];
 else sum+=Close[n]*MathPow(n,mi-1);
 }
 b[mi]=sum;
 } 
//===============Matrix=======================================================================================================
 for(jj=1;jj<=nn;jj++)
 {
 for(ii=1; ii<=nn; ii++)
 {
 kk=ii+jj-1;
 ai[ii,jj]=sx[kk];
 }
 } 
//===============Gauss========================================================================================================
 for(kk=1; kk<=nn-1; kk++)
 {
 ll=0;
 mm=0;
 for(ii=kk; ii<=nn; ii++)
 {
 if(MathAbs(ai[ii,kk])>mm)
 {
 mm=MathAbs(ai[ii,kk]);
 ll=ii;
 }
 }
 if(ll==0) return(0); 
 if (ll!=kk)
 {
 for(jj=1; jj<=nn; jj++)
 {
 tt=ai[kk,jj];
 ai[kk,jj]=ai[ll,jj];
 ai[ll,jj]=tt;
 }
 tt=b[kk];
 b[kk]=b[ll];
 b[ll]=tt;
 } 
 for(ii=kk+1;ii<=nn;ii++)
 {
 qq=ai[ii,kk]/ai[kk,kk];
 for(jj=1;jj<=nn;jj++)
 {
 if(jj==kk) ai[ii,jj]=0;
 else ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
 }
 b[ii]=b[ii]-qq*b[kk];
 }
 } 
 x[nn]=b[nn]/ai[nn,nn];
 for(ii=nn-1;ii>=1;ii--)
 {
tt=0;
 for(jj=1;jj<=nn-ii;jj++)
 {
 tt=tt+ai[ii,ii+jj]*x[ii+jj];
 x[ii]=(1/ai[ii,ii])*(b[ii]-tt);
 }
 } 
//===========================================================================================================================
 for(n=i0;n<=i0+p;n++)
 {
 sum=0;
 for(kk=1;kk<=degree;kk++)
 {
 sum+=x[kk+1]*MathPow(n,kk);
 }
 fx[n]=x[1]+sum;
 } 
//-----------------------------------Std-----------------------------------------------------------------------------------
 sq=0.0;
 for(n=i0;n<=i0+p;n++)
 {
 sq+=MathPow(Close[n]-fx[n],2);
 }
 sq=MathSqrt(sq/(p+1))*kstd;

 for(n=i0;n<=i0+p;n++)
 {
 sqh[n]=fx[n]+sq;
 sql[n]=fx[n]-sq;
 }

 return(0);
}
//+------------------------------------------------------------------+

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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

//
//
//
//
//

string stringUpperCase(string str)
{
 string s = str;

 for (int length=StringLen(str)-1; length>=0; length--)
 {
int char_ = StringGetChar(s, length);
 if((char_ > 96 && char_ < 123) || (char_ > 223 && char_ < 256))
 s = StringSetChar(s, length, char_ - 32);
 else if(char_ > -33 && char_ < 0)
 s = StringSetChar(s, length, char_ + 224);
 }
 return(s);
}