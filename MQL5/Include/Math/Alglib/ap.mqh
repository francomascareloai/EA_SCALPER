//+------------------------------------------------------------------+
//|                                                           ap.mqh |
//|            Copyright 2003-2022 Sergey Bochkanov (ALGLIB project) |
//|                             Copyright 2012-2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Implementation of ALGLIB library in MetaQuotes Language 5        |
//|                                                                  |
//| The features of the library include:                             |
//| - Linear algebra (direct algorithms, EVD, SVD)                   |
//| - Solving systems of linear and non-linear equations             |
//| - Interpolation                                                  |
//| - Optimization                                                   |
//| - FFT (Fast Fourier Transform)                                   |
//| - Numerical integration                                          |
//| - Linear and nonlinear least-squares fitting                     |
//| - Ordinary differential equations                                |
//| - Computation of special functions                               |
//| - Descriptive statistics and hypothesis testing                  |
//| - Data analysis - classification, regression                     |
//| - Implementing linear algebra algorithms, interpolation, etc.    |
//|   in high-precision arithmetic (using MPFR)                      |
//|                                                                  |
//| This file is free software; you can redistribute it and/or       |
//| modify it under the terms of the GNU General Public License as   |
//| published by the Free Software Foundation (www.fsf.org); either  |
//| version 2 of the License, or (at your option) any later version. |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of   |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "matrix.mqh"
#include "bitconvert.mqh"
//---
#define IsPosInf(value) (AL_POSINF==value)
#define IsNegInf(value) (AL_NEGINF==value)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AL_NaN  =CInfOrNaN::NaN();  //---AL_NaN
double AL_POSINF=CInfOrNaN::PositiveInfinity(); //---+infinity 1.#INF
double AL_NEGINF=CInfOrNaN::NegativeInfinity(); //----infinity -1.#INF
//+------------------------------------------------------------------+
//| Reverse communication structure                                  |
//+------------------------------------------------------------------+
struct RCommState
  {
public:
   int               stage;
   CRowInt           ia;
   bool              ba[];
   CRowDouble        ra;
   CRowComplex       ca;

                     RCommState(void) { stage=-1; }
                    ~RCommState(void) {}
   void              Copy(const RCommState &obj);
   //--- overloading
   void              operator=(const RCommState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Create a copy                                                    |
//+------------------------------------------------------------------+
void RCommState::Copy(const RCommState &obj)
  {
//--- copy a variable
   stage=obj.stage;
//--- copy arrays
   ia=obj.ia;
   ArrayCopy(ba,obj.ba);
   ra=obj.ra;
   ca=obj.ca;
  }
//+------------------------------------------------------------------+
//| Internal functions                                               |
//+------------------------------------------------------------------+
enum TRACE_MODE { TRACE_NONE,TRACE_FILE };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAp
  {
public:
   //--- variable that determines whether an exception happened
   static bool       exception_happened;
   //--- len
   template <typename T>
   static int        Len(const T &a[]);
   static int        Len(const CRowInt &a);
   static int        Len(const CRowDouble &a);
   static int        Len(const CRowComplex &a);
   //--- rows count
   static int        Rows(const CMatrixInt &a);
   static int        Rows(const CMatrixDouble &a);
   static int        Rows(const CMatrixComplex &a);
   //--- cols count
   static int        Cols(const CMatrixInt &a);
   static int        Cols(const CMatrixDouble &a);
   static int        Cols(const CMatrixComplex &a);
   //--- swap
   template <typename T>
   static void       Swap(T &a,T &b);
   template <typename T>
   static void       Swap(T &a[],T &b[]);
   static void       Swap(vector<double> &a,vector<double> &b);
   static void       Swap(vector<float> &a,vector<float> &b);
   static void       Swap(vector<complex> &a,vector<complex> &b);
   static void       Swap(CMatrixInt &a,CMatrixInt &b);
   static void       Swap(CMatrixDouble &a,CMatrixDouble &b);
   static void       Swap(CMatrixComplex &a,CMatrixComplex &b);
   //--- check assertions
   static bool       Assert(const bool cond);
   static bool       Assert(const bool cond,const string s);
   static bool       SetErrorFlag(bool &flag,bool cond,string xdesc);
   static void       SetErrorFlagDiff(bool &flag,double val,double refval,double tol,double s);
   //--- determination of accuracy
   static int        ThresHoldToDPS(const double threshold);
   //--- join string
   static string     StringJoin(const string sep,const string &a[]);
   //--- convert to string
   static string     Format(const complex &a,const int dps);
   static string     Format(const bool &a[]);
   static string     Format(const int &a[]);
   static string     Format(const double &a[],const int dps);
   static string     Format(const vector<double> &a,const int dps);
   static string     Format(const complex &a[],const int dps);
   static string     Format(const vector<complex> &a,const int dps);
   static string     FormatB(CMatrixInt &a);
   static string     Format(CMatrixInt &a);
   static string     Format(CMatrixDouble &a,const int dps);
   static string     Format(CMatrixComplex &a,const int dps);
   //--- work with matrix
   static bool       IsSymmetric(const CMatrixDouble &a);
   static bool       IsHermitian(const CMatrixComplex &a);
   static bool       ForceSymmetric(CMatrixDouble &a);
   static bool       ForceHermitian(CMatrixComplex &a);
   //--- trace
   static void       TraceFile(string tags,string filename);
   static void       TraceDisable(void);
   static bool       IsTraceEnabled(string tag);
   static void       Trace(string s);

private:
   static TRACE_MODE m_TraceMode;
   static string     m_TraceTags;
   static string     m_TraceFilename;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TRACE_MODE CAp::m_TraceMode=TRACE_NONE;
string CAp::m_TraceTags="";
string CAp::m_TraceFilename="";
//+------------------------------------------------------------------+
//| Initialize variable                                              |
//+------------------------------------------------------------------+
bool CAp::exception_happened=false;
//+------------------------------------------------------------------+
//| Get array lenght                                                 |
//+------------------------------------------------------------------+
template <typename T>
int CAp::Len(const T &a[])
  {
   return(ArraySize(a));
  }
//+------------------------------------------------------------------+
//| Get array lenght                                                 |
//+------------------------------------------------------------------+
int CAp::Len(const CRowInt &a)
  {
   return((int)a.Size());
  }
//+------------------------------------------------------------------+
//| Get array lenght                                                 |
//+------------------------------------------------------------------+
int CAp::Len(const CRowDouble &a)
  {
   return((int)a.Size());
  }
//+------------------------------------------------------------------+
//| Get array lenght                                                 |
//+------------------------------------------------------------------+
int CAp::Len(const CRowComplex &a)
  {
   return((int)a.Size());
  }
//+------------------------------------------------------------------+
//| Get rows count                                                   |
//+------------------------------------------------------------------+
int CAp::Rows(const CMatrixInt &a)
  {
   return(a.Size());
  }
//+------------------------------------------------------------------+
//| Get rows count                                                   |
//+------------------------------------------------------------------+
int CAp::Rows(const CMatrixDouble &a)
  {
   return(a.Size());
  }
//+------------------------------------------------------------------+
//| Get rows count                                                   |
//+------------------------------------------------------------------+
int CAp::Rows(const CMatrixComplex &a)
  {
   return(a.Size());
  }
//+------------------------------------------------------------------+
//| Get cols count                                                   |
//+------------------------------------------------------------------+
int CAp::Cols(const CMatrixInt &a)
  {
//--- check
   if(a.Size()==0)
      return(0);
//--- return result
   return(a[0].Size());
  }
//+------------------------------------------------------------------+
//| Get rows count                                                   |
//+------------------------------------------------------------------+
int CAp::Cols(const CMatrixDouble &a)
  {
   return(a.Cols());
  }
//+------------------------------------------------------------------+
//| Get rows count                                                   |
//+------------------------------------------------------------------+
int CAp::Cols(const CMatrixComplex &a)
  {
   return(a.Cols());
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
template <typename T>
void CAp::Swap(T &a,T &b)
  {
   T t=a;
   a=b;
   b=t;
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
template <typename T>
void CAp::Swap(T &a[],T &b[])
  {
   ArraySwap(a,b);
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(vector<double> &a,vector<double> &b)
  {
   a.Swap(b);
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(vector<float> &a,vector<float> &b)
  {
   a.Swap(b);
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(vector<complex> &a,vector<complex> &b)
  {
   a.Swap(b);
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(CMatrixInt &a,CMatrixInt &b)
  {
//--- create matrix
   CMatrixInt t;
//--- swap
   t=a;
   a=b;
   b=t;
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(CMatrixDouble &a,CMatrixDouble &b)
  {
//--- create matrix
   CMatrixDouble t;
//--- swap
   t=a;
   a=b;
   b=t;
  }
//+------------------------------------------------------------------+
//| Swap                                                             |
//+------------------------------------------------------------------+
void CAp::Swap(CMatrixComplex &a,CMatrixComplex &b)
  {
//--- create matrix
   CMatrixComplex t;
//--- swap
   t=a;
   a=b;
   b=t;
  }
//+------------------------------------------------------------------+
//| Check assertions                                                 |
//+------------------------------------------------------------------+
bool CAp::Assert(const bool cond)
  {
   return(Assert(cond,"ALGLIB: assertion failed"));
  }
//+------------------------------------------------------------------+
//| Check assertions                                                 |
//+------------------------------------------------------------------+
bool CAp::Assert(const bool cond,const string s)
  {
//--- check
   if(!cond)
     {
      Print(__FUNCTION__+" " + s);
      exception_happened=true;
      return(false);
     }
//--- the assertion is true
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAp::SetErrorFlag(bool &flag,bool cond,string xdesc)
  {
   if(cond)
     {
      flag=true;
      Print(xdesc);
     }
//---
   return(flag);
  }
//+------------------------------------------------------------------+
//| Internally calls SetErrorFlag() with condition:                  |
//|            Abs(Val-RefVal)>Tol*Max(Abs(RefVal),S)                |
//| This function is used to test relative error in Val against      |
//| RefVal, with relative error being replaced by absolute when scale|
//| of  RefVal  is  less than S.                                     |
//| This function returns value of COND.                             |
//+------------------------------------------------------------------+
void CAp::SetErrorFlagDiff(bool &flag,double val,double refval,
                           double tol,double s)
  {
   CAp::SetErrorFlag(flag,MathAbs(val-refval)>(tol*MathMax(MathAbs(refval),s)),"apserv.ap:162");
  }
//+------------------------------------------------------------------+
//| returns dps (digits-of-precision) value corresponding to         |
//| threshold.                                                       |
//| dps(0.9)  = dps(0.5)  = dps(0.1) = 0                             |
//| dps(0.09) = dps(0.05) = dps(0.01) = 1                            |
//| and so on                                                        |
//+------------------------------------------------------------------+
int CAp::ThresHoldToDPS(const double threshold)
  {
//--- initialization
   int    res=0;
   double t=1.0;
   for(res=0; t/10>threshold*(1+1E-10); res++)
      t/=10;
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Concatenation                                                    |
//+------------------------------------------------------------------+
string CAp::StringJoin(const string sep,const string &a[])
  {
   int size=ArraySize(a);
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- concatenation
   string res="";
   for(int i=0; i<size; i++)
     {
      StringAdd(res,a[i]);
      if(i!=size-1)
         StringAdd(res,sep);
     }
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Prints formatted complex                                         |
//+------------------------------------------------------------------+
string CAp::Format(const complex &a,const int dps)
  {
//--- definition of output style
   string fmt;
   if(dps>=0)
      fmt="f";
   else
      fmt="e";
//--- get sign of the imaginary part
   string sign;
   if(a.imag>=0)
      sign="+";
   else
      sign="-";
//--- converting
   int    d=(int)MathAbs(dps);
   string fmtx=StringFormat(".%d" + fmt,d);
   string fmty=StringFormat(".%d" + fmt,d);
//--- get result
   string res=StringFormat("%" + fmtx,a.real) + sign +
                StringFormat("%" + fmty,MathAbs(a.imag)) + "i";
   StringReplace(res,",",".");
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Prints formatted array                                           |
//+------------------------------------------------------------------+
string CAp::Format(const bool &a[])
  {
   int size=ArraySize(a);
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- converting
   string result[];
   ArrayResizeAL(result,size);
   for(int i=0; i<size; i++)
     {
      if(a[i]==0)
         result[i]="true";
      else
         result[i]="false";
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted array                                           |
//+------------------------------------------------------------------+
string CAp::Format(const int &a[])
  {
   int size=ArraySize(a);
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- converting
   string result[];
   ArrayResizeAL(result,size);
   for(int i=0; i<size; i++)
      result[i]=IntegerToString(a[i]);
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted array                                           |
//+------------------------------------------------------------------+
string CAp::Format(const double &a[],const int dps)
  {
   int size=ArraySize(a);
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
   string result[];
   ArrayResizeAL(result,size);
//--- definition of output style
   string sfmt;
   if(dps>=0)
      sfmt="f";
   else
      sfmt="e";
//--- converting
   int    d=(int)MathAbs(dps);
   string fmt=StringFormat(".%d" + sfmt,d);
   for(int i=0; i<size; i++)
     {
      result[i]=StringFormat("%" + fmt,a[i]);
      StringReplace(result[i],",",".");
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted array                                           |
//+------------------------------------------------------------------+
string CAp::Format(const vector<double> &a,const int dps)
  {
   ulong size=a.Size();
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": vector size error");
      return(NULL);
     }
   string result[];
   ArrayResizeAL(result,(int)size);
//--- definition of output style
   string sfmt;
   if(dps>=0)
      sfmt="f";
   else
      sfmt="e";
//--- converting
   int    d=(int)MathAbs(dps);
   string fmt=StringFormat(".%d" + sfmt,d);
   for(ulong i=0; i<size; i++)
     {
      result[i]=StringFormat("%" + fmt,a[i]);
      StringReplace(result[i],",",".");
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted array                                           |
//+------------------------------------------------------------------+
string CAp::Format(const complex &a[],const int dps)
  {
   int size=ArraySize(a);
//--- check
   if(size==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
   string result[];
   ArrayResizeAL(result,size);
//--- definition of output style
   string fmt;
   if(dps>=0)
      fmt="f";
   else
      fmt="e";
//--- converting
   int    d=(int)MathAbs(dps);
   string fmtx=StringFormat(".%d" + fmt,d);
   string fmty=StringFormat(".%d" + fmt,d);
   string sign;
   for(int i=0; i<size; i++)
     {
      //--- definition of the sign
      if(a[i].imag>=0)
         sign="+";
      else
         sign="-";
      //--- fill result
      result[i]=StringFormat("%" + fmtx,a[i].real) + sign +
                  StringFormat("%" + fmty,MathAbs(a[i].imag)) + "i";
      StringReplace(result[i],",",".");
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted matrix                                          |
//+------------------------------------------------------------------+
string CAp::FormatB(CMatrixInt &a)
  {
   int m=a.Rows();
//--- check
   if(m==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
   int n=a.Cols();
//--- check
   if(n==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- prepare arrays
   bool   line[];
   string result[];
   ArrayResizeAL(line,n);
   ArrayResizeAL(result,m);
//--- converting
   for(int i=0; i<m; i++)
     {
      for(int j=0; j<n; j++)
         line[j]=(bool)(a.Get(i,j));
      result[i]=Format(line);
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted matrix                                          |
//+------------------------------------------------------------------+
string CAp::Format(CMatrixInt &a)
  {
   int m=a.Rows();
//--- check
   if(m==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
   int n=a.Cols();
//--- check
   if(n==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- prepare arrays
   int    line[];
   string result[];
   ArrayResizeAL(line,n);
   ArrayResizeAL(result,m);
//--- converting
   for(int i=0; i<m; i++)
     {
      for(int j=0; j<n; j++)
         line[j]=a.Get(i,j);
      result[i]=Format(line);
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted matrix                                          |
//+------------------------------------------------------------------+
string CAp::Format(CMatrixDouble &a,const int dps)
  {
   ulong m=a.Rows();
//--- check
   if(m==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
   ulong n=a.Cols();
//--- check
   if(n==0)
     {
      Print(__FUNCTION__+": array size error");
      return(NULL);
     }
//--- prepare arrays
   string result[];
   ArrayResizeAL(result,(int)m);
//--- converting
   for(ulong i=0; i<m; i++)
     {
      vector<double> v=a[i];
      result[i]=Format(v,dps);
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| Prints formatted matrix                                          |
//+------------------------------------------------------------------+
string CAp::Format(CMatrixComplex &a,const int dps)
  {
   ulong m=a.Rows();
//--- check
   if(m==0)
     {
      Print(__FUNCTION__+": matrix size error");
      return(NULL);
     }
   ulong n=a.Cols();
//--- check
   if(n==0)
     {
      Print(__FUNCTION__+": matrix size error");
      return(NULL);
     }
//--- prepare arrays
   string     result[];
   ArrayResizeAL(result,(int)m);
//--- converting
   for(ulong i=0; i<m; i++)
     {
      vector<complex> v=a[i];
      result[i]=Format(v,dps);
     }
//--- return result
   return("{" + StringJoin(",",result) + "}");
  }
//+------------------------------------------------------------------+
//| checks that matrix is symmetric.                                 |
//| max|A-A^T| is calculated; if it is within 1.0E-14 of max|A|,     |
//| matrix is considered symmetric                                   |
//+------------------------------------------------------------------+
bool CAp::IsSymmetric(const CMatrixDouble &a)
  {
   ulong n=a.Rows();
//--- check
   if(n!=a.Cols())
      return(false);
//--- check
   if(n==0)
      return(true);
//--- check for symmetry
   double mx=0;
   double err=0;
   for(ulong i=0; i<n; i++)
     {
      for(ulong j=i+1; j<n; j++)
        {
         double v1=a.Get(i,j);
         double v2=a.Get(j,i);
         if(!MathIsValidNumber(v1))
            return(false);
         if(!MathIsValidNumber(v2))
            return(false);
         err=MathMax(err,MathAbs(v1-v2));
         mx =MathMax(mx,MathAbs(v1));
         mx =MathMax(mx,MathAbs(v2));
        }
      double v=a.Get(i,i);
      if(!MathIsValidNumber(v))
         return(false);
      mx=MathMax(mx,MathAbs(v));
     }
//--- check
   if(mx==0)
      return(true);
//--- check
   if(err/mx<=1.0E-14)
      return(true);
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| checks that matrix is Hermitian.                                 |
//| max|A-A^H| is calculated; if it is within 1.0E-14 of max|A|,     |
//| matrix is considered Hermitian                                   |
//+------------------------------------------------------------------+
bool CAp::IsHermitian(const CMatrixComplex &a)
  {
   ulong n=a.Rows();
//--- check
   if(n!=a.Cols())
      return(false);
//--- check
   if(n==0)
      return(true);
//--- initialization
   double     mx=0;
   double     err=0;
   complex v1,v2,vt;
//--- check for Hermitian
   for(ulong i=0; i<n; i++)
     {
      for(ulong j=i+1; j<n; j++)
        {
         v1=a.Get(i,j);
         v2=a.Get(j,i);
         //--- checks
         if(!CMath::IsFinite(v1.real))
            return(false);
         if(!CMath::IsFinite(v1.imag))
            return(false);
         if(!CMath::IsFinite(v2.real))
            return(false);
         if(!CMath::IsFinite(v2.imag))
            return(false);
         //--- change values
         vt.real=v1.real-v2.real;
         vt.imag=v1.imag+v2.imag;
         err=MathMax(err,CMath::AbsComplex(vt));
         mx=MathMax(mx,CMath::AbsComplex(v1));
         mx=MathMax(mx,CMath::AbsComplex(v2));
        }
      v1=a.Get(i,i);
      //--- checks
      if(!CMath::IsFinite(v1.real))
         return(false);
      if(!CMath::IsFinite(v1.imag))
         return(false);
      //--- change values
      err=MathMax(err,MathAbs(v1.imag));
      mx=MathMax(mx,CMath::AbsComplex(v1));
     }
//--- check
   if(mx==0)
      return(true);
//--- check
   if(err/mx<=1.0E-14)
      return(true);
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| Forces symmetricity by copying upper half of A to the lower one  |
//+------------------------------------------------------------------+
bool CAp::ForceSymmetric(CMatrixDouble &a)
  {
   ulong n=a.Rows();
//--- check
   if(n!=a.Cols())
      return(false);
//--- check
   if(n==0)
      return(true);
//--- change matrix
   matrix<double> m=a.Transpose();
   a=a.TriL()+m.TriU(1);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Forces Hermiticity by copying upper half of A to the lower one   |
//+------------------------------------------------------------------+
bool CAp::ForceHermitian(CMatrixComplex &a)
  {
   ulong n=a.Rows();
//--- check
   if(n!=a.Cols())
      return(false);
//--- check
   if(n==0)
      return(true);
//--- change matrix
   complex c;
   for(ulong i=0; i<n; i++)
      for(ulong j=i+1; j<n; j++)
        {
         c=a.Get(j,i);
         c.imag=-c.imag;
         a.Set(i,j,c);
        }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Start trace                                                      |
//+------------------------------------------------------------------+
void CAp::TraceFile(string tags,string filename)
  {
   m_TraceMode    =TRACE_FILE;
   StringToLower(tags);
   m_TraceTags    ="," + tags + ",";
   m_TraceFilename=filename;
   Trace("####################################################################################################\r\n");
   Trace("# TRACING ENABLED: " + TimeToString(TimeCurrent(),TIME_DATE | TIME_SECONDS) + "\r\n");
   Trace("# TRACE TAGS:      '" + tags + "'\r\n");
   Trace("####################################################################################################\r\n");
  }
//+------------------------------------------------------------------+
//| Stop trace                                                       |
//+------------------------------------------------------------------+
void CAp::TraceDisable(void)
  {
   m_TraceMode    =TRACE_NONE;
   m_TraceTags    ="";
  }
//+------------------------------------------------------------------+
//| Check trace enabled                                              |
//+------------------------------------------------------------------+
bool CAp::IsTraceEnabled(string tag)
  {
//--- trace disabled
   if(m_TraceMode==TRACE_NONE)
      return(false);
//--- contains tag (followed by comma, which means exact match)
   StringToLower(tag);
   if(StringFind(m_TraceTags,("," + tag + ",")) >= 0)
      return(true);
//--- contains tag (followed by dot, which means match with child)
   if(StringFind(m_TraceTags,("," + tag + ".")) >= 0)
      return(true);
//---nothing
   return(false);
  }
//+------------------------------------------------------------------+
//| Trace                                                            |
//+------------------------------------------------------------------+
void CAp::Trace(string s)
  {
   if(m_TraceMode==TRACE_FILE)
     {
      int handle=FileOpen(m_TraceFilename,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(handle<=0 || !FileSeek(handle,0,SEEK_END))
         return;
      FileWriteString(handle,s);
      FileClose(handle);
     }
  }
//+------------------------------------------------------------------+
//| Portable high quality random number generator state.             |
//| Initialized with HQRNDRandomize() or HQRNDSeed().                |
//| Fields:                                                          |
//|     S1, S2      -   seed values                                  |
//|     V           -   precomputed value                            |
//|     MagicV      -   'magic' value used to determine whether State|
//|                     structure was correctly initialized.         |
//+------------------------------------------------------------------+
class CHighQualityRandState
  {
public:
   //--- variables
   int               m_s1;
   int               m_s2;
   double            m_v;
   int               m_magicv;
   //--- constructor, destructor
                     CHighQualityRandState(void) { ZeroMemory(this); }
                    ~CHighQualityRandState(void) {}
   //---
   void              Copy(const CHighQualityRandState &obj);
   //--- overloading
   void              operator=(const CHighQualityRandState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHighQualityRandState::Copy(const CHighQualityRandState &obj)
  {
   m_s1=obj.m_s1;
   m_s2=obj.m_s2;
   m_magicv=obj.m_magicv;
   m_v=obj.m_v;
  }
//+------------------------------------------------------------------+
//| Portable high quality random number generator state.             |
//| Initialized with HQRNDRandomize() or HQRNDSeed().                |
//| Fields:                                                          |
//|     S1, S2      -   seed values                                  |
//|     V           -   precomputed value                            |
//|     MagicV      -   'magic' value used to determine whether State|
//|                     structure was correctly initialized.         |
//+------------------------------------------------------------------+
class CHighQualityRandStateShell
  {
private:
   CHighQualityRandState m_innerobj;

public:
   //--- constructors, destructor
                     CHighQualityRandStateShell(void) {}
                     CHighQualityRandStateShell(CHighQualityRandState &obj);
                    ~CHighQualityRandStateShell(void) {}
   //--- method
   CHighQualityRandState *GetInnerObj(void) { return(GetPointer(m_innerobj)); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
CHighQualityRandStateShell::CHighQualityRandStateShell(CHighQualityRandState &obj)
  {
//--- copy
   m_innerobj.m_s1=obj.m_s1;
   m_innerobj.m_s2=obj.m_s2;
   m_innerobj.m_v=obj.m_v;
   m_innerobj.m_magicv=obj.m_magicv;
  }
//+------------------------------------------------------------------+
//| Portable high quality random number generator                    |
//+------------------------------------------------------------------+
class CHighQualityRand
  {
public:
   //--- static class members
   static const int  m_HQRndMax;
   static const int  m_HQRndM1;
   static const int  m_HQRndM2;
   static const int  m_HQRndMagic;
   //--- public methods
   static void       HQRndRandomize(CHighQualityRandState &state);
   static void       HQRndSeed(const int s1,const int s2,CHighQualityRandState &state);
   static double     HQRndUniformR(CHighQualityRandState &state);
   static int        HQRndUniformI(CHighQualityRandState &state,const int n);
   static double     HQRndNormal(CHighQualityRandState &state);
   static void       HQRndNormalV(CHighQualityRandState &state,int n,CRowDouble &x);
   static void       HQRndNormalM(CHighQualityRandState &state,int m,int n,CMatrixDouble &x);
   static void       HQRndUnit2(CHighQualityRandState &state,double &x,double &y);
   static void       HQRndNormal2(CHighQualityRandState &state,double &x1,double &x2);
   static double     HQRndExponential(CHighQualityRandState &state,const double lambdav);
   static double     HQRndDiscrete(CHighQualityRandState &state,int n,CRowDouble &x);
   template <typename T>
   static T          HQRndDiscrete(CHighQualityRandState &state,int n,vector<T> &x);
   static double     HQRndContinuous(CHighQualityRandState &state,int n,CRowDouble &x);
   template <typename T>
   static T          HQRndContinuous(CHighQualityRandState &state,int n,vector<T> &x);

private:
   static int        HQRndIntegerBase(CHighQualityRandState &state);
  };
//+------------------------------------------------------------------+
//| Initialize constants                                             |
//+------------------------------------------------------------------+
const int CHighQualityRand::m_HQRndMax=2147483561;
const int CHighQualityRand::m_HQRndM1 =2147483563;
const int CHighQualityRand::m_HQRndM2 =2147483399;
const int CHighQualityRand::m_HQRndMagic=1634357784;
//+------------------------------------------------------------------+
//| HQRNDState initialization with random values which come from     |
//| standard RNG.                                                    |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndRandomize(CHighQualityRandState &state)
  {
//--- get result
   HQRndSeed(CMath::RandomInteger(m_HQRndM1),CMath::RandomInteger(m_HQRndM2),state);
  }
//+------------------------------------------------------------------+
//| HQRNDState initialization with seed values                       |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndSeed(const int s1,const int s2,
                                 CHighQualityRandState &state)
  {
//--- calculation parameters
   state.m_s1=s1%(m_HQRndM1-1)+1;
   state.m_s2=s2%(m_HQRndM2-1)+1;
   state.m_v=1.0/(double)m_HQRndMax;
   state.m_magicv=m_HQRndMagic;
  }
//+------------------------------------------------------------------+
//| This function generates random real number in [0,1).             |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
double CHighQualityRand::HQRndUniformR(CHighQualityRandState &state)
  {
   return(state.m_v*(HQRndIntegerBase(state)-1));
  }
//+------------------------------------------------------------------+
//| This function generates random integer number in [0, N)          |
//| 1. N must be less than HQRNDMax-1.                               |
//| 2. State structure must be initialized with HQRNDRandomize() or  |
//| HQRNDSeed()                                                      |
//+------------------------------------------------------------------+
int CHighQualityRand::HQRndUniformI(CHighQualityRandState &state,const int n)
  {
//--- create variables
   int result=0;
   int maxcnt=0;
   int mx=0;
   int a=0;
   int b=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0!"))
      return(INT_MAX);
//---
   maxcnt=m_HQRndMax+1;
//---Two branches: one for N<=MaxCnt, another for N>MaxCnt.
   if(n>maxcnt)
     {
      //---N>=MaxCnt.
      //---We have two options here:
      //---a) N is exactly divisible by MaxCnt
      //---b) N is not divisible by MaxCnt
      //---In both cases we reduce problem on interval spanning [0,N)
      //---to several subproblems on intervals spanning [0,MaxCnt).
      if(n%maxcnt==0)
        {
         //---N is exactly divisible by MaxCnt.
         //---[0,N) range is dividided into N/MaxCnt bins,
         //---each of them having length equal to MaxCnt.
         //---We generate:
         //---* random bin number B
         //---* random offset within bin A
         //---Both random numbers are generated by recursively
         //---calling HQRNDUniformI().
         //---Result is equal to A+MaxCnt*B.
         //--- check
         if(!CAp::Assert(n/maxcnt<=maxcnt,__FUNCTION__+": N is too large"))
            return(INT_MAX);
         a=HQRndUniformI(state,maxcnt);
         b=HQRndUniformI(state,n/maxcnt);
         result=a+maxcnt*b;
        }
      else
        {
         //---N is NOT exactly divisible by MaxCnt.
         //---[0,N) range is dividided into Ceil(N/MaxCnt) bins,
         //---each of them having length equal to MaxCnt.
         //---We generate:
         //---* random bin number B in [0, Ceil(N/MaxCnt)-1]
         //---* random offset within bin A
         //---* if both of what is below is true
         //---  1) bin number B is that of the last bin
         //---  2) A >= N mod MaxCnt
         //---  then we repeat generation of A/B.
         //---  This stage is essential in order to avoid bias in the result.
         //---* otherwise, we return A*MaxCnt+N
         //--- check
         if(!CAp::Assert(n/maxcnt+1<=maxcnt,__FUNCTION__+": N is too large"))
            return(INT_MAX);
         result=-1;
         do
           {
            a=HQRndUniformI(state,maxcnt);
            b=HQRndUniformI(state,n/maxcnt+1);
            if(b==n/maxcnt && a>=n%maxcnt)
               continue;
            result=a+maxcnt*b;
           }
         while(result<0);
        }
     }
   else
     {
      //---N<=MaxCnt
      //---Code below is a bit complicated because we can not simply
      //---return "HQRNDIntegerBase() mod N" - it will be skewed for
      //---large N's in [0.1*HQRNDMax...HQRNDMax].
      mx=maxcnt-maxcnt%n;
      do
        {
         result=HQRndIntegerBase(state);
        }
      while(result>=mx);
      result=result%n;
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Random number generator: normal numbers                          |
//| This function generates one random number from normal            |
//| distribution.                                                    |
//| Its performance is equal to that of HQRNDNormal2()               |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
double CHighQualityRand::HQRndNormal(CHighQualityRandState &state)
  {
//--- create variables
   double v1=0;
   double v2=0;
//--- function call
   HQRndNormal2(state,v1,v2);
//--- return result
   return(v1);
  }
//+------------------------------------------------------------------+
//| Random number generator: vector with random entries (normal      |
//| distribution)                                                    |
//| This function generates N random numbers from normal             |
//| distribution.                                                    |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndNormalV(CHighQualityRandState &state,
                                    int n,CRowDouble &x)
  {
//--- create variables
   int    n2=0;
   double v1=0;
   double v2=0;
//--- function call
   if(n<0)
     {
      n=(int)x.Size();
     }
   else
     {
      if((int)x.Size()<n)
         x.Resize(n);
     }
   n2=n/2;
   for(int i=0; i<n2; i++)
     {
      HQRndNormal2(state,v1,v2);
      x.Set(2*i,v1);
      x.Set(2*i+1,v2);
     }
   if(n%2!=0)
     {
      HQRndNormal2(state,v1,v2);
      x.Set(n-1,v1);
     }
  }
//+------------------------------------------------------------------+
//| Random number generator: matrix with random entries (normal      |
//| distribution)                                                    |
//| This function generates MxN random matrix.                       |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndNormalM(CHighQualityRandState &state,
                                    int m,int n,CMatrixDouble &x)
  {
//--- create variables
   int    n2=0;
   double v1=0;
   double v2=0;
//--- function call
   if(n<0)
     {
      n=(int)x.Cols();
     }
   else
     {
      if((int)x.Cols()<n)
         x.Resize(x.Rows(),n);
     }
   if(m<0)
     {
      m=(int)x.Rows();
     }
   else
     {
      if((int)x.Rows()<m)
         x.Resize(m,x.Cols());
     }
   n2=n/2;
   for(int i=0; i<m; i++)
     {
      for(int j=0; j<n2; j++)
        {
         HQRndNormal2(state,v1,v2);
         x.Set(i,2*j,v1);
         x.Set(i,2*j+1,v2);
        }
      if(n%2!=0)
        {
         HQRndNormal2(state,v1,v2);
         x.Set(i,n-1,v1);
        }
     }
  }
//+------------------------------------------------------------------+
//| Random number generator: random X and Y such that X^2+Y^2=1      |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndUnit2(CHighQualityRandState &state,
                                  double &x,double &y)
  {
//--- create variables
   double v=0;
   double mx=0;
   double mn=0;
//--- initialization
   x=0;
   y=0;
//--- function call
   do
      HQRndNormal2(state,x,y);
   while(!(x!=0.0 || y!=0.0));
//--- change values
   mx=MathMax(MathAbs(x),MathAbs(y));
   mn=MathMin(MathAbs(x),MathAbs(y));
   v=mx*MathSqrt(1+CMath::Sqr(mn/mx));
//--- get result
   x=x/v;
   y=y/v;
  }
//+------------------------------------------------------------------+
//| Random number generator: normal numbers                  |
//| This function generates two independent random numbers from      |
//| normal distribution. Its performance is equal to that of         |
//| HQRNDNormal()                                      |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                       |
//+------------------------------------------------------------------+
void CHighQualityRand::HQRndNormal2(CHighQualityRandState &state,
                                    double &x1,double &x2)
  {
//--- create variables
   double u=0;
   double v=0;
   double s=0;
//--- initialization
   x1=0;
   x2=0;
//--- cycle
   while(true)
     {
      u=2*HQRndUniformR(state)-1;
      v=2*HQRndUniformR(state)-1;
      s=CMath::Sqr(u)+CMath::Sqr(v);
      //--- check
      if(s>0.0 && s<1.0)
        {
         //--- two Sqrt's instead of one to
         //--- avoid overflow when S is too small
         s=MathSqrt(-(2*MathLog(s)))/MathSqrt(s);
         x1=u*s;
         x2=v*s;
         //--- exit the function
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Random number generator: exponential distribution                |
//| State structure must be initialized with HQRNDRandomize() or     |
//| HQRNDSeed().                                                     |
//+------------------------------------------------------------------+
double CHighQualityRand::HQRndExponential(CHighQualityRandState &state,
                                          const double lambdav)
  {
//--- check
   if(!CAp::Assert(lambdav>0.0,__FUNCTION__+": LambdaV<=0!"))
      return(EMPTY_VALUE);
//--- return result
   return(-(MathLog(HQRndUniformR(state))/lambdav));
  }
//+------------------------------------------------------------------+
//| This function generates  random number from discrete distribution|
//| given by finite sample X.                                        |
//| INPUT PARAMETERS                                                 |
//|   State   -   high quality random number generator, must be      |
//|               initialized with HQRNDRandomize() or HQRNDSeed().  |
//|   X   -   finite sample                                          |
//|   N   -   number of elements to use, N>=1                        |
//| RESULT                                                           |
//|   this function returns one of the X[i] for random i=0..N-1      |
//+------------------------------------------------------------------+
double CHighQualityRand::HQRndDiscrete(CHighQualityRandState &state,
                                       int n,CRowDouble &x)
  {
   double result=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return (EMPTY_VALUE);
   if(!CAp::Assert(n<=(int)x.Size(),__FUNCTION__+": Length(X)<N"))
      return (EMPTY_VALUE);
//--- call function
   result=x[HQRndUniformI(state,n)];
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function generates  random number from discrete distribution|
//| given by finite sample X.                                        |
//| INPUT PARAMETERS                                                 |
//|   State   -   high quality random number generator, must be      |
//|               initialized with HQRNDRandomize() or HQRNDSeed().  |
//|   X   -   finite sample                                          |
//|   N   -   number of elements to use, N>=1                        |
//| RESULT                                                           |
//|   this function returns one of the X[i] for random i=0..N-1      |
//+------------------------------------------------------------------+
template <typename T>
T CHighQualityRand::HQRndDiscrete(CHighQualityRandState &state,
      int n,vector<T> &x)
  {
   T result=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return (EMPTY_VALUE);
   if(!CAp::Assert(n<=(int)x.Size(),__FUNCTION__+": Length(X)<N"))
      return (EMPTY_VALUE);
//--- call function
   result=x[HQRndUniformI(state,n)];
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function generates random number from continuous            |
//| distribution  given by finite sample X.                          |
//| INPUT PARAMETERS                                                 |
//|   State   -   high quality random number generator, must be      |
//|               initialized with HQRNDRandomize() or HQRNDSeed().  |
//|   X       -   finite sample, array[N] (can be larger, in this    |
//|               case only leading N elements are used). THIS ARRAY |
//|               MUST BE SORTED BY ASCENDING.                       |
//|   N       -   number of elements to use, N>=1                    |
//| RESULT                                                           |
//|   this function returns random number from continuous            |
//|   distribution which tries to approximate X as mush as possible. |
//|   min(X)<=Result<=max(X).                                        |
//+------------------------------------------------------------------+
double CHighQualityRand::HQRndContinuous(CHighQualityRandState &state,
                                         int n,CRowDouble &x)
  {
//--- create variables
   double result=0;
   double mx=0;
   double mn=0;
   int    i=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return (EMPTY_VALUE);
   if(!CAp::Assert(n<=(int)x.Size(),__FUNCTION__+": Length(X)<N"))
      return (EMPTY_VALUE);
//--- call function
   if(n==1)
     {
      result=x[0];
      return(result);
     }
   i=HQRndUniformI(state,n-1);
   mn=x[i];
   mx=x[i+1];
   if(!CAp::Assert(mx>=mn,__FUNCTION__+": X is not sorted by ascending"))
      return(EMPTY_VALUE);
   if(mx!=mn)
      result=(mx-mn)*HQRndUniformR(state)+mn;
   else
      result=mn;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function generates random number from continuous            |
//| distribution  given by finite sample X.                          |
//| INPUT PARAMETERS                                                 |
//|   State   -   high quality random number generator, must be      |
//|               initialized with HQRNDRandomize() or HQRNDSeed().  |
//|   X       -   finite sample, array[N] (can be larger, in this    |
//|               case only leading N elements are used). THIS ARRAY |
//|               MUST BE SORTED BY ASCENDING.                       |
//|   N       -   number of elements to use, N>=1                    |
//| RESULT                                                           |
//|   this function returns random number from continuous            |
//|   distribution which tries to approximate X as mush as possible. |
//|   min(X)<=Result<=max(X).                                        |
//+------------------------------------------------------------------+
template <typename T>
T CHighQualityRand::HQRndContinuous(CHighQualityRandState &state,
      int n,vector<T> &x)
  {
//--- create variables
   T      result=0;
   double mx=0;
   double mn=0;
   int    i=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return (EMPTY_VALUE);
   if(!CAp::Assert(n<=(int)x.Size(),__FUNCTION__+": Length(X)<N"))
      return (EMPTY_VALUE);
//--- call function
   if(n==1)
     {
      result=x[0];
      return(result);
     }
   i=HQRndUniformI(state,n-1);
   mn=x[i];
   mx=x[i+1];
   if(!CAp::Assert(mx>=mn,__FUNCTION__+": X is not sorted by ascending"))
      return(EMPTY_VALUE);
   if(mx!=mn)
      result=(T)((mx-mn)*HQRndUniformR(state)+mn);
   else
      result=mn;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| L'Ecuyer, Efficient and portable combined random number          |
//| generators                                                       |
//+------------------------------------------------------------------+
int CHighQualityRand::HQRndIntegerBase(CHighQualityRandState &state)
  {
//--- create variables
   int result=0;
   int k=0;
//--- check
   if(!CAp::Assert(state.m_magicv==m_HQRndMagic,__FUNCTION__+": State is not correctly initialized!"))
      return(-1);
//--- initialization
   k=state.m_s1/53668;
   state.m_s1=40014*(state.m_s1-k*53668)-k*12211;
//--- check
   if(state.m_s1<0)
      state.m_s1=state.m_s1+2147483563;
//--- change values
   k=state.m_s2/52774;
   state.m_s2=40692*(state.m_s2-k*52774)-k*3791;
//--- check
   if(state.m_s2<0)
      state.m_s2=state.m_s2+2147483399;
//--- Result
   result=state.m_s1-state.m_s2;
//--- check
   if(result<1)
      result=result+2147483562;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Math functions                                                   |
//+------------------------------------------------------------------+
class CMath
  {
public:
   //--- class variables
   static bool       m_first_call;
   static double     m_last;
   static CHighQualityRandState m_state;
   //--- machine constants
   static const double m_machineepsilon;
   static const double m_maxrealnumber;
   static const double m_minrealnumber;
   //--- methods
   static bool       IsFinite(const double d);
   static double     RandomReal(void);
   static int        RandomInteger(const int n);
   static double     Sqr(const double x) { return(x*x); }
   static double     AbsComplex(const complex z);
   static double     AbsComplex(const double r);
   static complex    Conj(const complex z);
   static complex    Csqr(const complex z);
  };
//+------------------------------------------------------------------+
//| Initialize class constants                                       |
//+------------------------------------------------------------------+
const double CMath::m_machineepsilon=5E-16;
const double CMath::m_maxrealnumber=1E300;
const double CMath::m_minrealnumber=1E-300;
bool         CMath::m_first_call=true;
double       CMath::m_last=0.0;
CHighQualityRandState CMath::m_state;
//+------------------------------------------------------------------+
//| Check on +-inf                                                   |
//+------------------------------------------------------------------+
bool CMath::IsFinite(const double d)
  {
   return(MathIsValidNumber(d));
  }
//+------------------------------------------------------------------+
//| Random real value [0,1)                                          |
//+------------------------------------------------------------------+
double CMath::RandomReal(void)
  {
   double result;
//--- check
   if(m_first_call)
     {
      CHighQualityRand::HQRndSeed(1+MathRand(),1+MathRand(),m_state);
      m_first_call=false;
     }
//--- get value
   result=CHighQualityRand::HQRndUniformR(m_state);
//--- check
   if(result==m_last)
     {
      m_first_call=true;
      return(RandomReal());
     }
//--- change value
   m_last=result;
//--- return result
   return(CHighQualityRand::HQRndUniformR(m_state));
  }
//+------------------------------------------------------------------+
//| Random integer value                                             |
//+------------------------------------------------------------------+
int CMath::RandomInteger(const int n)
  {
//--- check
   if(m_first_call)
     {
      CHighQualityRand::HQRndSeed(1+MathRand(),1+MathRand(),m_state);
      m_first_call=false;
     }
//--- check and return result
   if(n>=CHighQualityRand::m_HQRndM1-1)
      return(CHighQualityRand::HQRndUniformI(m_state,CHighQualityRand::m_HQRndM1-2));
   else
      return(CHighQualityRand::HQRndUniformI(m_state,n));
  }
//+------------------------------------------------------------------+
//| The absolute value of a complex number                           |
//+------------------------------------------------------------------+
double CMath::AbsComplex(const complex z)
  {
//--- initialization
   double xabs=MathAbs(z.real);
   double yabs=MathAbs(z.imag);
//--- check
   if(xabs==0)
      return(yabs);
//--- check
   if(yabs==0)
      return(xabs);
//--- check
//--- calculation
   double t=MathSqrt(MathPow(xabs,2)+MathPow(yabs,2));
//--- return result
   return(t);
  }
//+------------------------------------------------------------------+
//| The absolute value of a complex number                           |
//+------------------------------------------------------------------+
double CMath::AbsComplex(const double r)
  {
//--- initialization
   complex z=r;
   double  w=0.0;
   double  v=0.0;
   double  xabs=MathAbs(z.real);
   double  yabs=MathAbs(z.imag);
//--- check
   if(xabs>yabs)
      w=xabs;
   else
      w=yabs;
//--- check
   if(xabs<yabs)
      v=xabs;
   else
      v=yabs;
//--- check
   if(v==0)
      return(w);
//--- calculation
   double t=v/w;
//--- return result
   return(w*MathSqrt(1+t*t));
  }
//+------------------------------------------------------------------+
//| Get conjugate                                                    |
//+------------------------------------------------------------------+
complex CMath::Conj(const complex z)
  {
   complex res;
   res.real=z.real;
   res.imag=-z.imag;
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Squaring                                                         |
//+------------------------------------------------------------------+
complex CMath::Csqr(const complex z)
  {
   complex res;
   res.real=z.real*z.real-z.imag*z.imag;
   res.imag=2*z.real*z.imag;
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Global array of constants                                        |
//+------------------------------------------------------------------+
char _sixbits2char_tbl[] =
  {
   '0','1','2','3','4','5','6','7',
   '8','9','A','B','C','D','E','F',
   'G','H','I','J','K','L','M','N',
   'O','P','Q','R','S','T','U','V',
   'W','X','Y','Z','a','b','c','d',
   'e','f','g','h','i','j','k','l',
   'm','n','o','p','q','r','s','t',
   'u','v','w','x','y','z','-','_'
  };
//+------------------------------------------------------------------+
//| Global array of constants                                        |
//+------------------------------------------------------------------+
int _char2sixbits_tbl[128] =
  {
   -1,-1,-1,-1,-1,-1,-1,-1,
   -1,-1,-1,-1,-1,-1,-1,-1,
   -1,-1,-1,-1,-1,-1,-1,-1,
   -1,-1,-1,-1,-1,-1,-1,-1,
   -1,-1,-1,-1,-1,-1,-1,-1,
   -1,-1,-1,-1,-1,62,-1,-1,
    0,1,2,3,4,5,6,7,
    8,9,-1,-1,-1,-1,-1,-1,
   -1,10,11,12,13,14,15,16,
   17,18,19,20,21,22,23,24,
   25,26,27,28,29,30,31,32,
   33,34,35,-1,-1,-1,-1,63,
   -1,36,37,38,39,40,41,42,
   43,44,45,46,47,48,49,50,
   51,52,53,54,55,56,57,58,
   59,60,61,-1,-1,-1,-1,-1
  };
//+------------------------------------------------------------------+
//| Serializer object (should not be used directly)                  |
//+------------------------------------------------------------------+
class CSerializer
  {
   //--- enumeration
   enum SMODE { DEFAULT,ALLOC,TO_STRING,FROM_STRING };

private:
   //--- class constants
   static const int  m_ser_entries_per_row;
   static const int  m_ser_entry_length;
   //--- variables
   SMODE             m_mode;
   int               m_entries_needed;
   int               m_entries_saved;
   int               m_bytes_asked;
   int               m_bytes_written;
   int               m_bytes_read;
   char              m_out_str[];
   char              m_in_str[];
   //---local temporaries
   char              m_entry_buf_char[];
   char              m_entry_buf_byte[];

   //--- private methods
   int               Get_Alloc_Size(void);
   static char       SixBits2Char(const int v);
   static int        Char2SixBits(const char c);
   static void       ThreeBytes2FourSixBits(uchar &src[],const int src_offs,int &dst[],const int dst_offs);
   static void       FourSixBits2ThreeBytes(int &src[],const int src_offs,uchar &dst[],const int dst_offs);
   static void       Bool2Str(const bool v,char &buf[],int &offs);
   static bool       Str2Bool(char &buf[],int &offs);
   static void       Int2Str(const int v,char &buf[],int &offs);
   static int        Str2Int(char &buf[],int &offs);
   static void       Double2Str(const double v,char &buf[],int &offs);
   static double     Str2Double(char &buf[],int &offs);

public:
   //--- constructor, destructor
                     CSerializer(void);
                    ~CSerializer(void);
   //--- public methods
   void              ClearBuffers(void);
   void              Alloc_Start(void);
   void              Alloc_Entry(void);
   void              Alloc_Byte_Array(char &a[]);

   void              SStart_Str(void);
   void              UStart_Str(const string s);
   void              Reset(void);
   void              Stop(void);
   //--- serialization
   void              Serialize_Bool(const bool v);
   void              Serialize_Int(const int v);
   void              Serialize_Double(const double v);
   //--- unserialization
   bool              Unserialize_Bool(void);
   int               Unserialize_Int(void);
   double            Unserialize_Double(void);
   //--- get string
   string            Get_String(void);
  };
//+------------------------------------------------------------------+
//| Initialize constants                                             |
//+------------------------------------------------------------------+
const int CSerializer::m_ser_entries_per_row=5;
const int CSerializer::m_ser_entry_length=11;
//+------------------------------------------------------------------+
//| Constructor without parameters                                   |
//+------------------------------------------------------------------+
CSerializer::CSerializer(void): m_mode(DEFAULT),m_entries_needed(0),
   m_bytes_asked(0)
  {
   ArrayRemove(m_entry_buf_byte,m_ser_entry_length+2);
   ArrayRemove(m_entry_buf_char,m_ser_entry_length+2);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSerializer::~CSerializer(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSerializer::ClearBuffers(void)
  {
   ArrayFree(m_out_str);
   ArrayFree(m_in_str);
  }
//+------------------------------------------------------------------+
//| Start                                                            |
//+------------------------------------------------------------------+
void CSerializer::Alloc_Start(void)
  {
//--- change values
   m_entries_needed=0;
   m_bytes_asked=0;
   m_mode=ALLOC;
  }
//+------------------------------------------------------------------+
//| Entry                                                            |
//+------------------------------------------------------------------+
void CSerializer::Alloc_Entry(void)
  {
//--- check
   if(m_mode!=ALLOC)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
   m_entries_needed++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSerializer::Alloc_Byte_Array(char &a[])
  {
   if(m_mode!=ALLOC)
     {
      Print(__FUNCTION__": internal error during (un)serialization");
      return;
     }
   int n=CAp::Len(a);
   n=n/8+(n%8>0?1:0);
   m_entries_needed+=1+n;
  }
//+------------------------------------------------------------------+
//| Switching state on TO_STRING                                     |
//+------------------------------------------------------------------+
void CSerializer::SStart_Str(void)
  {
//--- get size
   int allocsize=Get_Alloc_Size();
//--- clear input/output buffers which may hold pointers to unneeded memory
//--- NOTE: it also helps us to avoid errors when data are written to incorrect location
   ClearBuffers();
//--- check and change m_mode
   if(m_mode!=ALLOC)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
   m_mode=TO_STRING;
//--- other preparations
   ArrayResizeAL(m_out_str,allocsize);
   m_entries_saved=0;
   m_bytes_written=0;
  }
//+------------------------------------------------------------------+
//| Switching state on FROM_STRING                                   |
//+------------------------------------------------------------------+
void CSerializer::UStart_Str(const string s)
  {
//--- check and change m_mode
   if(m_mode!=DEFAULT)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
   m_mode=FROM_STRING;
   StringToCharArray(s,m_in_str);
   m_bytes_read=0;
  }
//+------------------------------------------------------------------+
//| Reset parameters                                                 |
//+------------------------------------------------------------------+
void CSerializer::Reset(void)
  {
   m_mode=DEFAULT;
   m_entries_needed=0;
   m_bytes_asked=0;
   ClearBuffers();
  }
//+------------------------------------------------------------------+
//| Serialize bool                                                   |
//+------------------------------------------------------------------+
void CSerializer::Serialize_Bool(const bool v)
  {
//--- check
   if(m_mode!=TO_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
//--- function call
   Bool2Str(v,m_out_str,m_bytes_written);
   m_entries_saved++;
//--- check
   if(m_entries_saved%m_ser_entries_per_row!=0)
     {
      m_out_str[m_bytes_written]=' ';
      m_bytes_written++;
     }
   else
     {
      m_out_str[m_bytes_written+0]='\r';
      m_out_str[m_bytes_written+1]='\n';
      m_bytes_written+=2;
     }
  }
//+------------------------------------------------------------------+
//| Serialize int                                                    |
//+------------------------------------------------------------------+
void CSerializer::Serialize_Int(const int v)
  {
//--- check
   if(m_mode!=TO_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
//--- function call
   Int2Str(v,m_out_str,m_bytes_written);
   m_entries_saved++;
//--- check
   if(m_entries_saved%m_ser_entries_per_row!=0)
     {
      m_out_str[m_bytes_written]=' ';
      m_bytes_written++;
     }
   else
     {
      m_out_str[m_bytes_written+0]='\r';
      m_out_str[m_bytes_written+1]='\n';
      m_bytes_written+=2;
     }
  }
//+------------------------------------------------------------------+
//| Serialize double                                                 |
//+------------------------------------------------------------------+
void CSerializer::Serialize_Double(const double v)
  {
//--- check
   if(m_mode!=TO_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- exit the function
      return;
     }
//--- function call
   Double2Str(v,m_out_str,m_bytes_written);
   m_entries_saved++;
//--- check
   if(m_entries_saved%m_ser_entries_per_row!=0)
     {
      m_out_str[m_bytes_written]=' ';
      m_bytes_written++;
     }
   else
     {
      m_out_str[m_bytes_written+0]='\r';
      m_out_str[m_bytes_written+1]='\n';
      m_bytes_written+=2;
     }
  }
//+------------------------------------------------------------------+
//| Unserialize bool                                                 |
//+------------------------------------------------------------------+
bool CSerializer::Unserialize_Bool(void)
  {
//--- check
   if(m_mode!=FROM_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- return result
      return(false);
     }
//--- return result
   return(Str2Bool(m_in_str,m_bytes_read));
  }
//+------------------------------------------------------------------+
//| Unserialize int                                                  |
//+------------------------------------------------------------------+
int CSerializer::Unserialize_Int(void)
  {
//--- check
   if(m_mode!=FROM_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- return result
      return(-1);
     }
//--- return result
   return(Str2Int(m_in_str,m_bytes_read));
  }
//+------------------------------------------------------------------+
//| Unserialize double                                               |
//+------------------------------------------------------------------+
double CSerializer::Unserialize_Double(void)
  {
//--- check
   if(m_mode!=FROM_STRING)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- return result
      return(EMPTY_VALUE);
     }
//--- return result
   return(Str2Double(m_in_str,m_bytes_read));
  }
//+------------------------------------------------------------------+
//| Stop                                                             |
//+------------------------------------------------------------------+
void CSerializer::Stop(void)
  {
   if(m_mode==TO_STRING)
     {
      m_out_str[m_bytes_written]='.';
      m_bytes_written++;
      return;
     }
   if(m_mode==FROM_STRING)
     {
      //--- because input string may be from pre-3.11 serializer,
      //--- which does not include trailing dot, we do not test
      //--- string for presence of "." symbol. Anyway, because string
      //--- is not stream, we do not have to read ALL trailing symbols.
      return;
     }
   Print(__FUNCTION__": internal error during unserialization");
  }
//+------------------------------------------------------------------+
//| Get string                                                       |
//+------------------------------------------------------------------+
string CSerializer::Get_String(void)
  {
   return(GetSelectionString(m_out_str,0,m_bytes_written));
  }
//+------------------------------------------------------------------+
//| Get alloc size                                                   |
//+------------------------------------------------------------------+
int CSerializer::Get_Alloc_Size(void)
  {
//--- create variables
   int rows;
   int lastrowsize;
   int result;
//--- check and change m_mode
   if(m_mode!=ALLOC)
     {
      Print(__FUNCTION__+": internal error during (un)serialization");
      //--- return result
      return(-1);
     }
//--- if no entries needes (degenerate case)
   if(m_entries_needed==0)
     {
      m_bytes_asked=1;
      //--- return result
      return(m_bytes_asked);
     }
//--- non-degenerate case
   rows=m_entries_needed/m_ser_entries_per_row;
   lastrowsize=m_ser_entries_per_row;
//--- check
   if(m_entries_needed%m_ser_entries_per_row!=0)
     {
      lastrowsize=m_entries_needed%m_ser_entries_per_row;
      rows++;
     }
//--- calculate result size
   result=((rows-1)*m_ser_entries_per_row+lastrowsize)*m_ser_entry_length;
   result+=(rows-1)*(m_ser_entries_per_row-1)+(lastrowsize-1);
   result+=rows*2;
//--- save result
   m_bytes_asked=result;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function converts six-bit value (from 0 to 63) to character |
//| (only digits, lowercase and uppercase letters, minus and         |
//| underscore are used). If v is negative or greater than 63, this  |
//| function returns '?'.                                            |
//+------------------------------------------------------------------+
char CSerializer::SixBits2Char(const int v)
  {
//--- check
   if(v<0 || v>63)
      return('?');
//--- return result
   return(_sixbits2char_tbl[v]);
  }
//+------------------------------------------------------------------+
//| This function converts character to six-bit value (from 0 to 63).|
//| This function is inverse of ae_sixbits2char()                    |
//| If c is not correct character, this function returns -1.         |
//+------------------------------------------------------------------+
int CSerializer::Char2SixBits(const char c)
  {
//--- check
   if(c>=0 && c<127)
      return(_char2sixbits_tbl[c]);
//--- return result
   return(-1);
  }
//+------------------------------------------------------------------+
//| This function converts three bytes (24 bits) to four six-bit     |
//| values (24 bits again).                                          |
//| src         array                                                |
//| src_offs    offset of three-bytes chunk                          |
//| dst         array for ints                                       |
//| dst_offs    offset of four-ints chunk                            |
//+------------------------------------------------------------------+
void CSerializer::ThreeBytes2FourSixBits(uchar &src[],const int src_offs,
                                         int &dst[],const int dst_offs)
  {
//--- get bits
   dst[dst_offs+0]=src[src_offs+0]&0x3F;
   dst[dst_offs+1]=(src[src_offs+0]>>6)|((src[src_offs+1]&0x0F)<<2);
   dst[dst_offs+2]=(src[src_offs+1]>>4)|((src[src_offs+2]&0x03)<<4);
   dst[dst_offs+3]=src[src_offs+2]>>2;
  }
//+------------------------------------------------------------------+
//| This function converts four six-bit values (24 bits) to three    |
//| bytes (24 bits again).                                           |
//| src         pointer to four ints                                 |
//| src_offs    offset of the chunk                                  |
//| dst         pointer to three bytes                               |
//| dst_offs    offset of the chunk                                  |
//+------------------------------------------------------------------+
void CSerializer::FourSixBits2ThreeBytes(int &src[],const int src_offs,
                                         uchar &dst[],const int dst_offs)
  {
//--- get bytes
   dst[dst_offs+0]=(uchar)(src[src_offs+0]|((src[src_offs+1]&0x03)<<6));
   dst[dst_offs+1]=(uchar)((src[src_offs+1]>>2)|((src[src_offs+2]&0x0F)<<4));
   dst[dst_offs+2]=(uchar)((src[src_offs+2]>>4)|(src[src_offs+3]<<2));
  }
//+------------------------------------------------------------------+
//| This function serializes boolean value into buffer               |
//| v           boolean value to be serialized                       |
//| buf         buffer, at least 11 characters wide                  |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//+------------------------------------------------------------------+
void CSerializer::Bool2Str(const bool v,char &buf[],int &offs)
  {
   char c;
//--- check
   if(v)
      c='1';
   else
      c='0';
//--- copy c
   for(int i=0; i<m_ser_entry_length; i++)
      buf[offs+i]=c;
//--- change value
   offs+=m_ser_entry_length;
  }
//+------------------------------------------------------------------+
//| This function unserializes boolean value from buffer             |
//| buf         buffer which contains value;leading                  |
//|             spaces/tabs/newlines are ignored, traling            |
//|             spaces/tabs/newlines are treated as end of the       |
//|             boolean value.                                       |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//| This function raises an error in case unexpected symbol is found |
//+------------------------------------------------------------------+
bool CSerializer::Str2Bool(char &buf[],int &offs)
  {
//--- create variables
   bool   was0;
   bool   was1;
   string emsg=": unable to read boolean value from stream";
//--- initialization
   was0=false;
   was1=false;
//--- shift
   while(buf[offs]==' ' || buf[offs]=='\t' || buf[offs]=='\n' || buf[offs]=='\r')
      offs++;
//--- cycle
   while(buf[offs]!=' ' && buf[offs]!='\t' && buf[offs]!='\n' && buf[offs]!='\r' && buf[offs]!=0)
     {
      //--- check
      if(buf[offs]=='0')
        {
         was0=true;
         offs++;
         continue;
        }
      //--- check
      if(buf[offs]=='1')
        {
         was1=true;
         offs++;
         continue;
        }
      Print(__FUNCTION__+" " + emsg);
      //--- return result
      return(false);
     }
//--- check
   if((!was0) && (!was1))
     {
      Print(__FUNCTION__+" " + emsg);
      //--- return result
      return(false);
     }
//--- check
   if(was0 && was1)
     {
      Print(__FUNCTION__+" " + emsg);
      //--- return result
      return(false);
     }
//--- check
   if(was1)
      return(true);
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| This function serializes integer value into buffer               |
//| v           integer value to be serialized                       |
//| buf         buffer, at least 11 characters wide                  |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//| This function raises an error in case unexpected symbol is found |
//+------------------------------------------------------------------+
void CSerializer::Int2Str(const int v,char &buf[],int &offs)
  {
//--- create variables
   int   i;
   uchar c;
   uchar _bytes[];
//--- get bytes of v
   BitConverter::GetBytes(v,_bytes);
//--- create arrays
   uchar bytes[];
   int sixbits[];
//--- allocation
   ArrayResizeAL(bytes,9);
   ArrayResizeAL(sixbits,12);
//--- copy v to array of bytes, sign extending it and
//--- converting to little endian order. Additionally,
//--- we set 9th byte to zero in order to simplify
//--- conversion to six-bit representation
   if(!BitConverter::IsLittleEndian())
      ArrayReverse(_bytes);
//--- check
   if(v<0)
      c=(uchar)0xFF;
   else
      c=(uchar)0x00;
//--- copy
   for(i=0; i<sizeof(int); i++)
      bytes[i]=_bytes[i];
//--- fill remaining part
   for(i=sizeof(int); i<8; i++)
      bytes[i]=c;
   bytes[8]=0;
//--- convert to six-bit representation, output
//--- NOTE: last 12th element of sixbits is always zero, we do not output it
   ThreeBytes2FourSixBits(bytes,0,sixbits,0);
   ThreeBytes2FourSixBits(bytes,3,sixbits,4);
   ThreeBytes2FourSixBits(bytes,6,sixbits,8);
//--- copy
   for(i=0; i<m_ser_entry_length; i++)
      buf[offs+i]=SixBits2Char(sixbits[i]);
//--- change value
   offs+=m_ser_entry_length;
  }
//+------------------------------------------------------------------+
//| This function unserializes integer value from string             |
//| buf         buffer which contains value;leading                  |
//|             spaces/tabs/newlines are ignored, traling            |
//|             spaces/tabs/newlines are treated as end of the       |
//|             integer value.                                       |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//| This function raises an error in case unexpected symbol is found |
//+------------------------------------------------------------------+
int CSerializer::Str2Int(char &buf[],int &offs)
  {
//--- create variables
   string emsg=": unable to read integer value from stream";
   string emsg3264=": unable to read integer value from stream (value does not fit into 32 bits)";
   int    sixbitsread;
   int    i;
   uchar  c;
//--- create arrays
   int   sixbits[];
   uchar bytes[];
   uchar _bytes[];
//--- allocation
   ArrayResizeAL(sixbits,12);
   ArrayResizeAL(bytes,9);
   ArrayResizeAL(_bytes,sizeof(int));
//--- 1. skip leading spaces
//--- 2. read and decode six-bit digits
//--- 3. set trailing digits to zeros
//--- 4. convert to little endian 64-bit integer representation
//--- 5. check that we fit into int
//--- 6. convert to big endian representation, if needed
   sixbitsread=0;
   while(buf[offs]==' ' || buf[offs]=='\t' || buf[offs]=='\n' || buf[offs]=='\r')
      offs++;
   while(buf[offs]!=' ' && buf[offs]!='\t' && buf[offs]!='\n' && buf[offs]!='\r' && buf[offs]!=0)
     {
      int d;
      //--- function call
      d=Char2SixBits(buf[offs]);
      //--- check
      if(d<0 || sixbitsread>=m_ser_entry_length)
        {
         Print(__FUNCTION__+" " + emsg);
         //--- return result
         return(-1);
        }
      sixbits[sixbitsread]=d;
      sixbitsread++;
      offs++;
     }
//--- check
   if(sixbitsread==0)
     {
      Print(__FUNCTION__+" " + emsg);
      //--- return result
      return(-1);
     }
   for(i=sixbitsread; i<12; i++)
      sixbits[i]=0;
//--- function call
   FourSixBits2ThreeBytes(sixbits,0,bytes,0);
//--- function call
   FourSixBits2ThreeBytes(sixbits,4,bytes,3);
//--- function call
   FourSixBits2ThreeBytes(sixbits,8,bytes,6);
//--- check
   if((bytes[sizeof(int) -1]&0x80)!=0)
      c=(uchar)0xFF;
   else
      c=(uchar)0x00;
   for(i=sizeof(int); i<8; i++)
      //--- check
      if(bytes[i]!=c)
        {
         Print(__FUNCTION__+" " + emsg3264);
         //--- return result
         return(-1);
        }
//--- copy
   for(i=0; i<sizeof(int); i++)
      _bytes[i]=bytes[i];
//--- check
   if(!BitConverter::IsLittleEndian())
      ArrayReverse(_bytes);
//--- return result
   return(BitConverter::ToInt32(_bytes));
  }
//+------------------------------------------------------------------+
//| This function serializes double value into buffer                |
//| v           double value to be serialized                        |
//| buf         buffer, at least 11 characters wide                  |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//+------------------------------------------------------------------+
void CSerializer::Double2Str(const double v,char &buf[],int &offs)
  {
//--- create variable
   int i;
//--- create arrays
   uchar bytes[];
   int   sixbits[];
//--- allocation
   ArrayResizeAL(sixbits,12);
   ArrayResizeAL(bytes,9);
//--- handle special quantities
   if(CInfOrNaN::IsNaN(v))
     {
      buf[offs+0]='.';
      buf[offs+1]='n';
      buf[offs+2]='a';
      buf[offs+3]='n';
      buf[offs+4]='_';
      buf[offs+5]='_';
      buf[offs+6]='_';
      buf[offs+7]='_';
      buf[offs+8]='_';
      buf[offs+9]='_';
      buf[offs+10]='_';
      offs+=m_ser_entry_length;
      //--- exit the function
      return;
     }
//--- check
   if(CInfOrNaN::IsPositiveInfinity(v))
     {
      buf[offs+0]='.';
      buf[offs+1]='p';
      buf[offs+2]='o';
      buf[offs+3]='s';
      buf[offs+4]='i';
      buf[offs+5]='n';
      buf[offs+6]='f';
      buf[offs+7]='_';
      buf[offs+8]='_';
      buf[offs+9]='_';
      buf[offs+10]='_';
      offs+=m_ser_entry_length;
      //--- exit the function
      return;
     }
//--- check
   if(CInfOrNaN::IsNegativeInfinity(v))
     {
      buf[offs+0]='.';
      buf[offs+1]='n';
      buf[offs+2]='e';
      buf[offs+3]='g';
      buf[offs+4]='i';
      buf[offs+5]='n';
      buf[offs+6]='f';
      buf[offs+7]='_';
      buf[offs+8]='_';
      buf[offs+9]='_';
      buf[offs+10]='_';
      offs+=m_ser_entry_length;
      //--- exit the function
      return;
     }
//--- process general case:
//--- 1. copy v to array of chars
//--- 2. set 9th byte to zero in order to simplify conversion to six-bit representation
//--- 3. convert to little endian (if needed)
//--- 4. convert to six-bit representation
//---    (last 12th element of sixbits is always zero, we do not output it)
   uchar _bytes[];
   BitConverter::GetBytes(v,_bytes);
//--- check
   if(!BitConverter::IsLittleEndian())
      ArrayReverse(_bytes);
//--- copy
   for(i=0; i<sizeof(double); i++)
      bytes[i]=_bytes[i];
//--- filling
   for(i=sizeof(double); i<9; i++)
      bytes[i]=0;
//--- function call
   ThreeBytes2FourSixBits(bytes,0,sixbits,0);
//--- function call
   ThreeBytes2FourSixBits(bytes,3,sixbits,4);
//--- function call
   ThreeBytes2FourSixBits(bytes,6,sixbits,8);
//--- function call
   for(i=0; i<m_ser_entry_length; i++)
      buf[offs+i]=SixBits2Char(sixbits[i]);
//--- change value
   offs+=m_ser_entry_length;
  }
//+------------------------------------------------------------------+
//| This function unserializes double value from string              |
//| buf         buffer which contains value;leading                  |
//|             spaces/tabs/newlines are ignored, traling            |
//|             spaces/tabs/newlines are treated as end of the       |
//|             double value.                                        |
//| offs        offset in the buffer                                 |
//| after return(from this function, offs points to the char's past  |
//| the value being read.                                            |
//| This function raises an error in case unexpected symbol is found |
//+------------------------------------------------------------------+
double CSerializer::Str2Double(char &buf[],int &offs)
  {
//--- create variables
   string emsg="ALGLIB: unable to read double value from stream";
   int    sixbitsread;
//--- create arrays
   uchar bytes[];
   uchar _bytes[];
   int   sixbits[];
//--- allocation
   ArrayResizeAL(bytes,9);
   ArrayResizeAL(sixbits,12);
   ArrayResizeAL(_bytes,sizeof(double));
//--- skip leading spaces
   while(buf[offs]==' ' || buf[offs]=='\t' || buf[offs]=='\n' || buf[offs]=='\r')
      offs++;
//--- Handle special cases
   if(buf[offs]=='.')
     {
      //--- function call
      string s=GetSelectionString(buf,offs,m_ser_entry_length);
      //--- check
      if(s==".nan_______")
        {
         offs+=m_ser_entry_length;
         //--- return result
         return(CInfOrNaN::NaN());
        }
      //--- check
      if(s==".posinf____")
        {
         offs+=m_ser_entry_length;
         //--- return result
         return(CInfOrNaN::PositiveInfinity());
        }
      //--- check
      if(s==".neginf____")
        {
         offs+=m_ser_entry_length;
         //--- return result
         return(CInfOrNaN::NegativeInfinity());
        }
      Print(__FUNCTION__+"emsg");
      //--- return result
      return(EMPTY_VALUE);
     }
//--- General case:
//--- 1. read and decode six-bit digits
//--- 2. check that all 11 digits were read
//--- 3. set last 12th digit to zero (needed for simplicity of conversion)
//--- 4. convert to 8 bytes
//--- 5. convert to big endian representation, if needed
   sixbitsread=0;
   while(buf[offs]!=' ' && buf[offs]!='\t' && buf[offs]!='\n' && buf[offs]!='\r' && buf[offs]!=0)
     {
      int d;
      //--- function call
      d=Char2SixBits(buf[offs]);
      //--- check
      if(d<0 || sixbitsread>=m_ser_entry_length)
        {
         Print(__FUNCTION__+"emsg");
         //--- return result
         return(EMPTY_VALUE);
        }
      sixbits[sixbitsread]=d;
      sixbitsread++;
      offs++;
     }
//--- check
   if(sixbitsread!=m_ser_entry_length)
     {
      Print(__FUNCTION__+"emsg");
      //--- return result
      return(EMPTY_VALUE);
     }
   sixbits[m_ser_entry_length]=0;
//--- function call
   FourSixBits2ThreeBytes(sixbits,0,bytes,0);
//--- function call
   FourSixBits2ThreeBytes(sixbits,4,bytes,3);
//--- function call
   FourSixBits2ThreeBytes(sixbits,8,bytes,6);
//--- copy
   for(int i=0; i<sizeof(double); i++)
      _bytes[i]=bytes[i];
//--- check
   if(!BitConverter::IsLittleEndian())
      ArrayReverse(_bytes);
//--- return result
   return(BitConverter::ToDouble(_bytes));
  }
//+------------------------------------------------------------------+
