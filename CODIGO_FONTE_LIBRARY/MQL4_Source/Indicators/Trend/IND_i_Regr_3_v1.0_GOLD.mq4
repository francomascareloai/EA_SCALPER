//http://codebase.mql4.com/ru/4333
//post fxcanada (12.09.2008 12:01) 
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Gold
#property indicator_color3 Gold


extern int degree = 3;
extern double kstd = 2.0;
extern int bars = 250;
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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
  SetIndexBuffer(0, fx); // Буферы массивов индикатора
  SetIndexBuffer(1, sqh);
  SetIndexBuffer(2, sql);

  SetIndexStyle(0, DRAW_LINE);
  SetIndexStyle(1, DRAW_LINE);
  SetIndexStyle(2, DRAW_LINE);

  SetIndexEmptyValue(0, 0.0);
  SetIndexEmptyValue(1, 0.0);
  SetIndexEmptyValue(2, 0.0);
  
  SetIndexShift(0, shift);
  SetIndexShift(1, shift);
  SetIndexShift(2, shift);

  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
  //clear();
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  if (Bars < bars) return;

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