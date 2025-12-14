//+------------------------------------------------------------------+
//|                                               alglibinternal.mqh |
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
//| published by the Free Software Foundation (www.fsf.org);either   |
//| version 2 of the License, or (at your option) any later version. |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY;without even the implied warranty of    |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//+------------------------------------------------------------------+
#include "ap.mqh"
//+------------------------------------------------------------------+
//| Class stores serialized codes                                    |
//+------------------------------------------------------------------+
class CSCodes
  {
public:
   static int        GetRDFSerializationCode(void)          { return(1);   }
   static int        GetKDTreeSerializationCode(void)       { return(2);   }
   static int        GetMLPSerializationCode(void)          { return(3);   }
   static int        GetMLPESerializationCode(void)         { return(4);   }
   static int        GetRBFSerializationCode(void)          { return(5);   }
   static int        GetSpline2DSerializationCode(void)     { return(6);   }
   static int        GetIDWSerializationCode(void)          { return(7);   }
   static int        GetSparseMatrixSerializationCode(void) { return(8);   }
   static int        GetKNNSerializationCode(void)          { return(108); }
   static int        GetLpTestSerializationCode(void)       { return(200); }
  };
//+------------------------------------------------------------------+
//| Buffers for internal functions which need buffers:               |
//| * check for size of the buffer you want to use.                  |
//| * if buffer is too small, resize it; leave unchanged, if it is   |
//| larger than needed.                                              |
//| * use it.                                                        |
//| We can pass this structure to multiple functions;  after first   |
//| run through functions buffer sizes will be finally determined,   |
//| and  on  a next run no allocation will be required.              |
//+------------------------------------------------------------------+
struct CApBuff
  {
   //--- arrays
   bool              m_ba[];
   CRowInt           m_ia0;
   CRowInt           m_ia1;
   CRowInt           m_ia2;
   CRowInt           m_ia3;
   CRowDouble        m_ra0;
   CRowDouble        m_ra1;
   CRowDouble        m_ra2;
   CRowDouble        m_ra3;
   CMatrixDouble     m_rm0;
   CMatrixDouble     m_rm1;
   //--- constructor, destructor
                     CApBuff(void) {}
                    ~CApBuff(void) {}
   //--- copy
   void              Copy(const CApBuff &obj);
   //--- overloading
   void              operator=(const CApBuff &buf) { Copy(buf); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CApBuff::Copy(const CApBuff &obj)
  {
//--- copy arrays
   m_ia0=obj.m_ia0;
   m_ia1=obj.m_ia1;
   m_ia2=obj.m_ia2;
   m_ia3=obj.m_ia3;
   m_ra0=obj.m_ra0;
   m_ra1=obj.m_ra1;
   m_ra2=obj.m_ra2;
   m_ra3=obj.m_ra3;
   m_rm0=obj.m_rm0;
   m_rm1=obj.m_rm1;
   ArrayFree(m_ba);
   ArrayCopy(m_ba,obj.m_ba);
  }
//+------------------------------------------------------------------+
//| Basic functions                                                  |
//+------------------------------------------------------------------+
class CApServ
  {
public:
   //--- constants
   static double     SparseLevel2Density(void);
   static int        MatrixTileSizeA(void);
   static int        MatrixTileSizeB(void);
   static double     SMPActivationLevel(void);
   static double     SpawnLevel(void);

   //--- generate interpolation
   static void       TaskGenInt1D(const double a,const double b,const int n,double &x[],double &y[]);
   static void       TaskGenInt1D(const double a,const double b,const int n,CRowDouble &x,CRowDouble &y);
   static void       TaskGenInt1DEquidist(const double a,const double b,const int n,double &x[],double &y[]);
   static void       TaskGenInt1DEquidist(const double a,const double b,const int n,CRowDouble &x,CRowDouble &y);
   static void       TaskGenInt1DCheb1(const double a,const double b,const int n,double &x[],double &y[]);
   static void       TaskGenInt1DCheb1(const double a,const double b,const int n,CRowDouble &x,CRowDouble &y);
   static void       TaskGenInt1DCheb2(const double a,const double b,const int n,double &x[],double &y[]);
   static void       TaskGenInt1DCheb2(const double a,const double b,const int n,CRowDouble &x,CRowDouble &y);
   //--- distinct
   static bool       AreDistinct(double &x[],const int n);
   static bool       AreDistinct(CRowDouble &x,const int n);
   //--- resize arrays
   static void       BVectorSetLengthAtLeast(bool &x[],const int n);
   static void       IVectorSetLengthAtLeast(int &x[],const int n);
   static void       IVectorSetLengthAtLeast(CRowInt &x,const int n);
   static bool       RVectorSetLengthAtLeast(double &x[],const int n);
   template <typename T>
   static bool       RVectorSetLengthAtLeast(vector<T> &x,const int n);
   static bool       RVectorSetLengthAtLeast(CRowDouble &x,const int n);
   template <typename T>
   static void       VectorGrowTo(T &x[],int n);
   static void       VectorGrowTo(CRowInt &x,int n);
   static void       VectorGrowTo(CRowDouble &x,int n);
   template <typename T>
   static void       VectorAppend(T &x[],T v);
   static void       VectorAppend(CRowInt &x,int v);
   static void       VectorAppend(CRowDouble &x,double v);
   static void       VectorAppend(CRowComplex &x,complex v);
   template <typename T>
   static void       UnsetArray(T &a[])   {  ArrayFree(a);  }
   //--- resize matrix
   static bool       RMatrixSetLengthAtLeast(CMatrixDouble &x,const int m,const int n);
   static void       RMatrixResize(CMatrixDouble &x,const int m,const int n);
   static void       RMatrixGrowRowsTo(CMatrixDouble &a,int n,int mincols);
   static void       RMatrixGrowColsTo(CMatrixDouble &a,int n,int minrows);

   //--- check to infinity
   static bool       IsFiniteVector(const double &x[],const int n);
   static bool       IsFiniteVector(const CRowDouble &x,const int n);
   static bool       IsFiniteComplexVector(CRowComplex &x,const int n);
   static bool       IsFiniteComplexVector(complex &z[],const int n);
   static bool       IsFiniteMatrix(const CMatrixDouble &x,const int m,const int n);
   static bool       IsFiniteComplexMatrix(CMatrixComplex &x,const int m,const int n);
   static bool       IsFiniteRTrMatrix(CMatrixDouble &x,const int n,const bool IsUpper);
   static bool       IsFiniteCTrMatrix(CMatrixComplex &x,const int n,const bool IsUpper);
   static bool       IsFiniteOrNaNMatrix(CMatrixDouble &x,const int m,const int n);
   //--- safe methods
   static double     SafePythag2(const double x,const double y);
   static double     SafePythag3(double x,double y,double z);
   static int        SafeRDiv(double x,double y,double &r);
   static double     SafeMinPosRV(const double x,const double y,const double v);
   static void       ApPeriodicMap(double &x,const double a,const double b,double &k);
   static double     RandomNormal(void);
   static void       RandomUnit(int n,CRowDouble &x);
   template <typename T>
   static T          BoundVal(const T x,const T b1,const T b2);
   static void       CountDown(int &v);
   static double     PosSign(double x);
   template <typename T>
   static T          RMaxAbs3(T r0,T r1,T r2);

   //--- swaps
   template <typename T>
   static void       Swap(T &v0,T &v1);
   static void       SwapRows(CMatrixDouble &a,int i0,int i1,int ncols);
   static void       SwapCols(CMatrixDouble &a,int j0,int j1,int nrows);
   static void       SwapEntries(CRowDouble &a,int i0,int i1,int entrywidth);
   static void       SwapElements(CRowDouble &a,int i0,int i1);
   static void       SwapElementsI(CRowInt &a,int i0,int i1);
   static int        IDivUp(int a,int b);

   //--- serialization/unserialization
   static void       AllocComplex(CSerializer &s,complex &v);
   static void       SerializeComplex(CSerializer &s,complex &v);
   static complex    UnserializeComplex(CSerializer &s);
   static void       AllocRealArray(CSerializer &s,double &v[],int n=-1);
   static void       AllocRealArray(CSerializer &s,CRowDouble &v,int n=-1);
   static void       SerializeRealArray(CSerializer &s,double &v[],int n=-1);
   static void       SerializeRealArray(CSerializer &s,CRowDouble &v,int n=-1);
   static void       UnserializeRealArray(CSerializer &s,double &v[]);
   static void       UnserializeRealArray(CSerializer &s,CRowDouble &v);
   static void       AllocIntegerArray(CSerializer &s,int &v[],int n=-1);
   static void       AllocIntegerArray(CSerializer &s,CRowInt &v,int n=-1);
   static void       SerializeIntegerArray(CSerializer &s,int &v[],int n=-1);
   static void       SerializeIntegerArray(CSerializer &s,CRowInt &v,int n=-1);
   static void       UnserializeIntegerArray(CSerializer &s,int &v[]);
   static void       UnserializeIntegerArray(CSerializer &s,CRowInt &v);
   static void       AllocBoolArray(CSerializer &s,bool &v[],int n=-1);
   static void       SerializeBoolArray(CSerializer &s,bool &v[],int n=-1);
   static void       AllocRealMatrix(CSerializer &s,CMatrixDouble &v,int n0,int n1);
   static void       SerializeRealMatrix(CSerializer &s,CMatrixDouble &v,int n0,int n1);
   static void       UnserializeRealMatrix(CSerializer &s,CMatrixDouble &v);
   //--- copy
   static void       CopyIntegerArray(int &src[],int &dst[]);
   static void       CopyIntegerArray(CRowInt &src,CRowInt &dst);
   static void       CopyRealArray(double &src[],double &dst[]);
   static void       CopyRealArray(double &src[],CRowDouble &dst);
   static void       CopyRealArray(CRowDouble &src,CRowDouble &dst);
   static void       CopyRealMatrix(CMatrixDouble &src,CMatrixDouble &dst);
   //--- split
   static void       TiledSplit(int tasksize,int tilesize,int &task0,int &task1);
   static void       SplitLengthEven(int tasksize,int &task0,int &task1);
   static void       SplitLength(int tasksize,int m_ChunkSize,int &task0,int &task1);

   //--- check array
   static int        RecSearch(int &a[],const int nrec,const int nheader,int i0,int i1,int &b[]);
   static int        RecSearch(CRowInt &a,const int nrec,const int nheader,int i0,int i1,CRowInt &b);

   static int        CountNZ1(CRowDouble &v,int n);
   static int        CountNZ2(CMatrixDouble &v,int m,int n);
   //---
   static int        ChunksCount(int tasksize,int m_ChunkSize);
   static double     Coalesce(double a,double b);
   static int        CoalesceI(int a,int b);
   static double     LogBase2(double x);
   static bool       ApproxEqual(double a,double b,double tol);
   static bool       ApproxEqualRel(double a,double b,double tol);
   //--- trace
   static void       TraceVectorAutopRec(CRowDouble &a,int i0,int i1);
   static void       TraceRowAutopRec(CMatrixDouble &a,int i,int j0,int j1);
   static void       TraceVectoRunScaledUnshiftedAutopRec(CRowDouble &x,int n,CRowDouble &scl,bool applyscl,CRowDouble &sft,bool applysft);
   static void       TraceVectorUnscaledUnshiftedAutopRec(CRowDouble &x,int n,CRowDouble &scl,bool applyscl,CRowDouble &sft,bool applysft);
   static void       TraceRowNrm1AutopRec(CMatrixDouble &a,int i0,int i1,int j0,int j1);
   static void       TraceVectorE3(CRowDouble &a,int i0,int i1);
   static void       TraceVectorE6(CRowDouble &a,int i0,int i1);
   static void       TraceVectorE615(CRowDouble &a,int i0,int i1,bool usee15);
   static void       TraceRowNrm1E6(CMatrixDouble &a,int i0,int i1,int j0,int j1);
  };
//+------------------------------------------------------------------+
//| This  function  generates  1-dimensional  general  interpolation |
//| task with moderate Lipshitz constant (close to 1.0)              |
//| If N=1 then suborutine generates only one point at the middle    |
//| of [A,B]                                                         |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1D(const double a,const double b,const int n,
                           double &x[],double &y[])
  {
//--- create variables
   int    i=0;
   double h=0;
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   ArrayResize(x,n);
   ArrayResize(y,n);
//--- check
   if(n>1)
     {
      //--- change values
      x[0]=a;
      y[0]=2*CMath::RandomReal()-1;
      h=(b-a)/(n-1);
      for(i=1; i<n; i++)
        {
         //--- check
         if(i!=n-1)
            x[i]=a+(i+0.2*(2*CMath::RandomReal()-1))*h;
         else
            x[i]=b;
         y[i]=y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1]);
        }
     }
   else
     {
      //--- change values
      x[0]=0.5*(a+b);
      y[0]=2*CMath::RandomReal()-1;
     }
  }
//+------------------------------------------------------------------+
//| This  function  generates  1-dimensional  general  interpolation |
//| task with moderate Lipshitz constant (close to 1.0)              |
//| If N=1 then suborutine generates only one point at the middle    |
//| of [A,B]                                                         |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1D(const double a,const double b,const int n,
                           CRowDouble &x,CRowDouble &y)
  {
//--- create variables
   int    i=0;
   double h=0;
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   y.Resize(n);
//--- check
   if(n>1)
     {
      //--- change values
      matrix<double> m;
      m.Init(1,n);
      m.Random(-0.2,0.2);
      h=(b-a)/(n-1);
      x=vector<double>::Ones(n).CumSum()-1;
      x=(x+m.Row(0))*h;
      x.Set(0,a);
      x.Set(n-1,b);
      y.Set(0,2*CMath::RandomReal()-1);
      for(i=1; i<n; i++)
         y.Set(i,y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1]));
     }
   else
     {
      //--- change values
      x.Set(0,0.5*(a+b));
      y.Set(0,2*CMath::RandomReal()-1);
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional equidistant interpolation |
//| task withmoderate Lipshitz constant(close to 1.0)                |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DEquidist(const double a,const double b,
                                   const int n,double &x[],double &y[])
  {
//--- create variables
   int    i=0;
   double h=0;
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   ArrayResize(x,n);
   ArrayResize(y,n);
//--- check
   if(n>1)
     {
      //--- change values
      x[0]=a;
      y[0]=2*CMath::RandomReal()-1;
      h=(b-a)/(n-1);
      for(i=1; i<n; i++)
        {
         x[i]=a+i*h;
         y[i]=y[i-1]+(2*CMath::RandomReal()-1)*h;
        }
     }
   else
     {
      //--- change values
      x[0]=0.5*(a+b);
      y[0]=2*CMath::RandomReal()-1;
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional equidistant interpolation |
//| task withmoderate Lipshitz constant(close to 1.0)                |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DEquidist(const double a,const double b,const int n,
                                   CRowDouble &x,CRowDouble &y)
  {
//--- create variables
   int    i=0;
   double h=0;
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   y.Resize(n);
//--- check
   if(n>1)
     {
      //--- change values
      h=(b-a)/(n-1);
      vector<double> temp=vector<double>::Ones(n).CumSum()-1;
      x=temp*h+a;
      y.Set(0,(2*CMath::RandomReal()-1));
      for(i=1; i<n; i++)
         y.Set(i,(y[i-1]+(2*CMath::RandomReal()-1)*h));
     }
   else
     {
      //--- change values
      x.Set(0,0.5*(a+b));
      y.Set(0,2*CMath::RandomReal()-1);
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional Chebyshev-1 interpolation |
//| task with moderate Lipshitz constant(close to 1.0)               |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DCheb1(const double a,const double b,
                                const int n,double &x[],double &y[])
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   ArrayResize(x,n);
   ArrayResize(y,n);
//--- check
   if(n>1)
     {
      for(int i=0; i<n; i++)
        {
         x[i]=0.5*(b+a)+0.5*(b-a)*MathCos(M_PI*(i+0.5)/(double)n);
         //--- check
         if(i==0)
            y[i]=2*CMath::RandomReal()-1;
         else
            y[i]=y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1]);
        }
     }
   else
     {
      //--- change values
      x[0]=0.5*(a+b);
      y[0]=2*CMath::RandomReal()-1;
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional Chebyshev-1 interpolation |
//| task with moderate Lipshitz constant(close to 1.0)               |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DCheb1(const double a,const double b,const int n,
                                CRowDouble &x,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   y.Resize(n);
//--- check
   if(n>1)
     {
      vector<double> temp=vector<double>::Ones(n).CumSum()-0.5;
      x=MathCos(temp*M_PI/(double)n)*0.5*(b-a)+0.5*(b+a);
      y.Set(0,(2*CMath::RandomReal()-1));
      for(int i=1; i<n; i++)
         y.Set(i,(y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1])));
     }
   else
     {
      //--- change values
      x.Set(0,(0.5*(a+b)));
      y.Set(0,(2*CMath::RandomReal()-1));
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional Chebyshev-2 interpolation |
//| task with moderate Lipshitz constant(close to 1.0)               |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DCheb2(const double a,const double b,
                                const int n,double &x[],double &y[])
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   ArrayResize(x,n);
   ArrayResize(y,n);
//--- check
   if(n>1)
     {
      for(int i=0; i<n; i++)
        {
         x[i]=0.5*(b+a)+0.5*(b-a)*MathCos(M_PI*i/(n-1));
         //--- check
         if(i==0)
            y[i]=2*CMath::RandomReal()-1;
         else
            y[i]=y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1]);
        }
     }
   else
     {
      //--- change values
      x[0]=0.5*(a+b);
      y[0]=2*CMath::RandomReal()-1;
     }
  }
//+------------------------------------------------------------------+
//| This function generates  1-dimensional Chebyshev-2 interpolation |
//| task with moderate Lipshitz constant(close to 1.0)               |
//| If N=1 then suborutine generates only one point at the middle    |
//| of[A,B]                                                          |
//+------------------------------------------------------------------+
void CApServ::TaskGenInt1DCheb2(const double a,const double b,const int n,
                                CRowDouble &x,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- allocation
   y.Resize(n);
//--- check
   if(n>1)
     {
      vector<double> temp=vector<double>::Ones(n).CumSum();
      x=MathCos(temp*M_PI/(n-1.0))*0.5*(b-a)+0.5*(b+a);
      y.Set(0,(2*CMath::RandomReal()-1));
      for(int i=1; i<n; i++)
         y.Set(i,(y[i-1]+(2*CMath::RandomReal()-1)*(x[i]-x[i-1])));
     }
   else
     {
      //--- change values
      x.Set(0,(0.5*(a+b)));
      y.Set(0,(2*CMath::RandomReal()-1));
     }
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[] are distinct.      |
//| It does more than just usual floating point comparison:          |
//| * first, it calculates max(X) and min(X)                         |
//| * second, it maps X[] from [min,max] to [1,2]                    |
//| * only at this stage actual comparison is done                   |
//| The meaning of such check is to ensure that all values are       |
//| "distinct enough" and will not cause interpolation subroutine    |
//| to fail.                                                         |
//|  NOTE:                                                           |
//|     X[] must be sorted by ascending (subroutine ASSERT's it)     |
//+------------------------------------------------------------------+
bool CApServ::AreDistinct(double &x[],const int n)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": internal error (N<1)"))
      return(false);
//--- check
   if(n==1)
     {
      //--- everything is alright, it is up to caller to decide whether it
      //--- can interpolate something with just one point
      return(true);
     }
//--- create variables
   double a=0;
   double b=0;
   int    i=0;
   bool   nonsorted;
//--- initialization
   a=x[0];
   b=x[0];
   nonsorted=false;
   for(i=1; i<n; i++)
     {
      a=MathMin(a,x[i]);
      b=MathMax(b,x[i]);
      nonsorted=nonsorted || x[i-1]>=x[i];
     }
//--- check
   if(!CAp::Assert(!nonsorted,__FUNCTION__+": internal error (not sorted)"))
      return(false);
   for(i=1; i<n; i++)
     {
      //--- check
      if((x[i]-a)/(b-a)==(x[i-1]-a)/(b-a))
         return(false);
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[] are distinct.      |
//| It does more than just usual floating point comparison:          |
//| * first, it calculates max(X) and min(X)                         |
//| * second, it maps X[] from [min,max] to [1,2]                    |
//| * only at this stage actual comparison is done                   |
//| The meaning of such check is to ensure that all values are       |
//| "distinct enough" and will not cause interpolation subroutine    |
//| to fail.                                                         |
//|  NOTE:                                                           |
//|     X[] must be sorted by ascending (subroutine ASSERT's it)     |
//+------------------------------------------------------------------+
bool CApServ::AreDistinct(CRowDouble &x,const int n)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": internal error (N<1)"))
      return(false);
//--- check
   if(n==1)
     {
      //--- everything is alright, it is up to caller to decide whether it
      //--- can interpolate something with just one point
      return(true);
     }
//--- create variables
   double a=0;
   double b=0;
   int    i=0;
   bool   nonsorted;
//--- initialization
   a=x.Min();
   b=x.Max();
   nonsorted=false;
   for(i=1; i<n; i++)
      nonsorted=nonsorted || x[i-1]>=x[i];
//--- check
   if(!CAp::Assert(!nonsorted,__FUNCTION__+": internal error (not sorted)"))
      return(false);
   for(i=1; i<n; i++)
     {
      //--- check
      if((x[i]-a)/(b-a)==(x[i-1]-a)/(b-a))
         return(false);
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N, resizes X                                        |
//+------------------------------------------------------------------+
void CApServ::BVectorSetLengthAtLeast(bool &x[],const int n)
  {
//--- check
   if(CAp::Len(x)<n)
      ArrayResizeAL(x,n);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N, resizes X                                        |
//+------------------------------------------------------------------+
void CApServ::IVectorSetLengthAtLeast(CRowInt &x,const int n)
  {
//--- check
   if(x.Size()<n)
      x.Resize(n);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N, resizes X                                        |
//+------------------------------------------------------------------+
void CApServ::IVectorSetLengthAtLeast(int &x[],const int n)
  {
//--- check
   if(CAp::Len(x)<n)
      ArrayResizeAL(x,n);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N , resizes X                                       |
//+------------------------------------------------------------------+
bool CApServ::RVectorSetLengthAtLeast(double &x[],const int n)
  {
//--- check
   if(CAp::Len(x)<n)
      if(ArrayResize(x,n)<0)
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N , resizes X                                       |
//+------------------------------------------------------------------+
template <typename T>
bool CApServ::RVectorSetLengthAtLeast(vector<T> &x,const int n)
  {
//--- check
   if((int)x.Size()<n)
      if(!x.Resize(n))
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| If Length(X)<N , resizes X                                       |
//+------------------------------------------------------------------+
bool CApServ::RVectorSetLengthAtLeast(CRowDouble &x,const int n)
  {
//--- check
   if((int)x.Size()<n)
      if(!x.Resize(n))
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| Grows X, i.e. changes its size in such a way that:               |
//|   a) contents is preserved                                       |
//|   b) new size is at least N                                      |
//|   c) new size can be larger than N, so subsequent grow() calls   |
//|      can return without reallocation                             |
//+------------------------------------------------------------------+
template <typename T>
void CApServ::VectorGrowTo(T &x[],int n)
  {
//--- create variables
   int i=0;
   int n2=0;
//--- Enough place
   if(CAp::Len(x)>=n)
      return;
//--- Choose new size
   n=MathMax(n,(int)MathRound(1.8*x.Size()+1));
//--- Grow
   n2=x.Size();
   if(ArrayResize(x,n)<n)
      return;
   T def=(T)0;
   for(i=n2; i<n; i++)
      x[i]=def;
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CApServ::VectorGrowTo(CRowInt &x,int n)
  {
//--- create variables
   int i=0;
   int n2=0;
//--- Enough place
   if(x.Size()>=n)
      return;
//--- Choose new size
   n=MathMax(n,(int)MathRound(1.8*x.Size()+1));
//--- Grow
   n2=x.Size();
   x.Resize(n);
   for(i=n2; i<n; i++)
      x.Set(i,0);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CApServ::VectorGrowTo(CRowDouble &x,int n)
  {
//--- create variables
   int i=0;
   int n2=0;
//--- Enough place
   if((int)x.Size()>=n)
      return;
//--- Choose new size
   n=MathMax(n,(int)MathRound(1.8*x.Size()+1));
//--- Grow
   n2=(int)x.Size();
   x.Resize(n);
   for(i=n2; i<n; i++)
      x.Set(i,0.0);
  }
//+------------------------------------------------------------------+
//| If Cols(X)<N or Rows(X)<M, resizes X                             |
//+------------------------------------------------------------------+
bool CApServ::RMatrixSetLengthAtLeast(CMatrixDouble &x,const int m,
                                      const int n)
  {
//--- check
   if((int)CAp::Rows(x)<m || (int)CAp::Cols(x)<n)
      if(!x.Resize(m,n))
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| Resizes X and:                                                   |
//| * preserves old contents of X                                    |
//| * fills new elements by zeros                                    |
//+------------------------------------------------------------------+
void CApServ::RMatrixResize(CMatrixDouble &x,const int m,const int n)
  {
//--- initialization
   ulong m2=x.Rows();
   ulong n2=x.Cols();
//--- resize
   x.Resize(m,n);
//--- filling
   vector<double> zero=vector<double>::Zeros(n);
   for(int i=(int)m2; i<m; i++)
      x.Row(i,zero);
   zero=vector<double>::Zeros(m);
   for(int i=(int)n2; i<n; i++)
      x.Col(i,zero);
  }
//+------------------------------------------------------------------+
//| Grows X, i.e. appends rows in such a way that:                   |
//|   a) contents is preserved                                       |
//|   b) new row count is at least N                                 |
//|   c) new row count can be larger than N, so subsequent grow()    |
//|      calls can return without reallocation                       |
//|   d) new matrix has at least MinCols columns (if less than       |
//|      specified amount of columns is present, new columns are     |
//|      added with undefined contents);                             |
//| MinCols can be 0 or negative value = ignored                     |
//+------------------------------------------------------------------+
void CApServ::RMatrixGrowRowsTo(CMatrixDouble &a,int n,int mincols)
  {
//--- Enough place?
   if(a.Rows()>=n && a.Cols()>=mincols)
      return;
//--- Sizes and metrics
   if(a.Rows()<n)
      n=MathMax(n,(int)MathRound(1.8*a.Rows()+1));
   int m=a.Cols();
//--- Grow
   a.Resize(n,MathMax(m,mincols));
  }
//+------------------------------------------------------------------+
//| Grows X, i.e. appends cols in such a way that:                   |
//|   a) contents is preserved                                       |
//|   b) new col count is at least N                                 |
//|   c) new col count can be larger than N, so subsequent grow()    |
//|      calls can return without reallocation                       |
//|   d) new matrix has at least MinRows row (if less than specified |
//|      amount of rows is present, new rows are added with undefined|
//|      contents);                                                  |
//| MinRows can be 0 or negative value = ignored                     |
//+------------------------------------------------------------------+
void CApServ::RMatrixGrowColsTo(CMatrixDouble &a,int n,int minrows)
  {
//--- Enough place?
   if(a.Cols()>=n && a.Rows()>=minrows)
      return;
//--- Sizes and metrics
   if(a.Cols()<n)
      n=MathMax(n,(int)MathRound(1.8*a.Cols()+1));
   int m=a.Rows();
//--- Grow
   a.Resize(MathMax(m,minrows),n);
  }
//+------------------------------------------------------------------+
//| Appends element to X                                             |
//+------------------------------------------------------------------+
template <typename T>
void CApServ::VectorAppend(T &x[],T v)
  {
   int n=x.Size();
   if(ArrayResize(x,n+1)<(n+1))
      return;
   x[n]=v;
  }
//+------------------------------------------------------------------+
//| Appends element to X                                             |
//+------------------------------------------------------------------+
void CApServ::VectorAppend(CRowInt &x,int v)
  {
   int n=x.Size();
   x.Resize(n+1);
   x.Set(n,v);
  }
//+------------------------------------------------------------------+
//| Appends element to X                                             |
//+------------------------------------------------------------------+
void CApServ::VectorAppend(CRowDouble &x,double v)
  {
   int n=(int)x.Size();
   x.Resize(n+1);
   x.Set(n,v);
  }
//+------------------------------------------------------------------+
//| Appends element to X                                             |
//+------------------------------------------------------------------+
void CApServ::VectorAppend(CRowComplex &x,complex v)
  {
   int n=(int)x.Size();
   x.Resize(n+1);
   x.Set(n,v);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[] are finite         |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteComplexVector(complex &x[],const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": internal error (N<0)"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Size()<n)
      return(false);

   for(int i=0; i<n; i++)
     {
      //--- check
      if(!CMath::IsFinite(x[i].real) || !CMath::IsFinite(x[i].imag))
         return(false);
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that length(X) is at least N and first N    |
//| values from X[] are finite                                       |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteVector(const double &x[],const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": the error variable"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Size()<n)
      return(false);
//--- is finite?
   for(int i=0; i<n; i++)
      if(!CMath::IsFinite(x[i]))
         return(false);
//--- is finite
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that length(X) is at least N and first N    |
//| values from X[] are finite                                       |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteVector(const CRowDouble &x,const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": the error variable"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Size()<n)
      return(false);
//--- is finite?
   for(int i=0; i<n; i++)
      if(!CMath::IsFinite(x[i]))
         return(false);
//--- is finite
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that length(X) is at least N and first N    |
//| values from X[] are finite                                       |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteComplexVector(CRowComplex &x,const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": the error variable"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Size()<n)
      return(false);
//--- is finite?
   for(int i=0; i<n; i++)
      if(!CMath::IsFinite(x[i].real) || !CMath::IsFinite(x[i].imag))
         return(false);
//--- is finite
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[0..M-1,0..N-1]       |
//| are finite                                                       |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteMatrix(const CMatrixDouble &x,const int m,
                             const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": the error variable"))
      return(false);
//--- check
   if(!CAp::Assert(m>=0,__FUNCTION__+": the error variable"))
      return(false);

   if(m==0 || n==0)
      return(true);
   if((int)x.Rows()<m || (int)x.Cols()<n)
      return(false);
//--- is finite?
   for(int i=0; i<m; i++)
      for(int j=0; j<n; j++)
         //--- check
         if(!CMath::IsFinite(x.Get(i,j)))
            return(false);
//--- is finite
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[0..M-1,0..N-1]       |
//| are finite                                                       |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteComplexMatrix(CMatrixComplex &x,const int m,
                                    const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": internal error (N<0)"))
      return(false);
//--- check
   if(!CAp::Assert(m>=0,__FUNCTION__+": internal error (M<0)"))
      return(false);

   if(m==0 || n==0)
      return(true);
   if((int)x.Rows()<m || (int)x.Cols()<n)
      return(false);
//--- is finite?
   for(int i=0; i<m; i++)
     {
      for(int j=0; j<n; j++)
         //--- check
         if(!CMath::IsFinite(x.Get(i,j).real) || !CMath::IsFinite(x.Get(i,j).imag))
            return(false);
     }
//--- is finite
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from upper/lower triangle of|
//| X[0..N-1,0..N-1] are finite                                      |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteRTrMatrix(CMatrixDouble &x,const int n,
                                const bool IsUpper)
  {
//--- create variables
   int i=0;
   int j1=0;
   int j2=0;
   int j=0;
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": internal error (N<0)"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Rows()<n || (int)x.Cols()<n)
      return(false);

   for(i=0; i<n; i++)
     {
      //--- check
      if(IsUpper)
        {
         j1=i;
         j2=n-1;
        }
      else
        {
         j1=0;
         j2=i;
        }
      for(j=j1; j<=j2; j++)
        {
         //--- check
         if(!CMath::IsFinite(x.Get(i,j)))
            return(false);
        }
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from upper/lower triangle of|
//| X[0..N-1,0..N-1] are finite                                      |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteCTrMatrix(CMatrixComplex &x,const int n,
                                const bool IsUpper)
  {
//--- create variables
   int i=0;
   int j1=0;
   int j2=0;
   int j=0;
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": internal error (N<0)"))
      return(false);

   if(n==0)
      return(true);
   if((int)x.Rows()<n || (int)x.Cols()<n)
      return(false);

   for(i=0; i<n; i++)
     {
      //--- check
      if(IsUpper)
        {
         j1=i;
         j2=n-1;
        }
      else
        {
         j1=0;
         j2=i;
        }
      for(j=j1; j<=j2; j++)
        {
         //--- check
         if(!CMath::IsFinite(x.Get(i,j).real) || !CMath::IsFinite(x.Get(i,j).imag))
            return(false);
        }
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| This function checks that all values from X[0..M-1,0..N-1] are   |
//| finite or NaN's.                                                 |
//+------------------------------------------------------------------+
bool CApServ::IsFiniteOrNaNMatrix(CMatrixDouble &x,const int m,
                                  const int n)
  {
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": internal error (N<0)"))
      return(false);
//--- check
   if(!CAp::Assert(m>=0,__FUNCTION__+": internal error (M<0)"))
      return(false);

   if(m==0 || n==0)
      return(true);
   if((int)x.Rows()<m || (int)x.Cols()<n)
      return(false);

   for(int i=0; i<m; i++)
     {
      for(int j=0; j<n; j++)
        {
         //--- check
         if(!(CMath::IsFinite(x.Get(i,j)) || CInfOrNaN::IsNaN(x.Get(i,j))))
            return(false);
        }
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Safe sqrt(x^2+y^2)                                               |
//+------------------------------------------------------------------+
double CApServ::SafePythag2(const double x,const double y)
  {
//--- create variables
   double result=0;
   double xabs=MathAbs(x);
   double yabs=MathAbs(y);
   double w=MathMax(xabs,yabs);
   double z=MathMin(xabs,yabs);
//--- check
   if(z==0.0)
      result=w;
   else
      result=w*MathSqrt(1+CMath::Sqr(z/w));
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Safe sqrt(x^2+y^2+z^2)                                           |
//+------------------------------------------------------------------+
double CApServ::SafePythag3(double x,double y,double z)
  {
   double w=MathMax(MathAbs(x),MathMax(MathAbs(y),MathAbs(z)));
//--- check
   if(w==0.0)
      return(0);
//--- change values
   x=x/w;
   y=y/w;
   z=z/w;
//--- return result
   return(w*MathSqrt(CMath::Sqr(x)+CMath::Sqr(y)+CMath::Sqr(z)));
  }
//+------------------------------------------------------------------+
//| Safe division.                                                   |
//| This function attempts to calculate R=X/Y without overflow.      |
//| It returns:                                                      |
//| * +1, if abs(X/Y)>=MaxRealNumber or undefined - overflow-like    |
//|       situation (no overlfow is generated, R is either NAN,      |
//|       PosINF, NegINF)                                            |
//| *  0, if MinRealNumber<abs(X/Y)<MaxRealNumber or X=0, Y<>0       |
//|       (R contains result, may be zero)                           |
//| * -1, if 0<abs(X/Y)<MinRealNumber - underflow-like situation     |
//|       (R contains zero; it corresponds to underflow)             |
//| No overflow is generated in any case.                            |
//+------------------------------------------------------------------+
int CApServ::SafeRDiv(double x,double y,double &r)
  {
//--- create variables
   int result=0;
//--- initialization
   r=0;
//--- Two special cases:
//--- * Y=0
//--- * X=0 and Y<>0
   if(y==0.0)
     {
      result=1;
      //--- check
      if(x==0.0)
         r=CInfOrNaN::NaN();
      //--- check
      if(x>0.0)
         r=CInfOrNaN::PositiveInfinity();
      //--- check
      if(x<0.0)
         r=CInfOrNaN::NegativeInfinity();
      //--- return result
      return(result);
     }
//--- check
   if(x==0.0)
     {
      r=0;
      result=0;
      //--- return result
      return(result);
     }
//--- make Y>0
   if(y<0.0)
     {
      x=-x;
      y=-y;
     }
//--- check
   if(y>=1.0)
     {
      r=x/y;
      //--- check
      if(MathAbs(r)<=CMath::m_minrealnumber)
        {
         result=-1;
         r=0;
        }
      else
         result=0;
     }
   else
     {
      //--- check
      if(MathAbs(x)>=CMath::m_maxrealnumber*y)
        {
         //--- check
         if(x>0.0)
            r=CInfOrNaN::PositiveInfinity();
         else
            r=CInfOrNaN::NegativeInfinity();
         result=1;
        }
      else
        {
         r=x/y;
         result=0;
        }
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function calculates "safe" min(X/Y,V) for positive finite X,|
//| Y, V. No overflow is generated in any case.                      |
//+------------------------------------------------------------------+
double CApServ::SafeMinPosRV(const double x,const double y,const double v)
  {
//--- create variables
   double result=0;
   double r=0;
//--- check
   if(y>=1.0)
     {
      //--- Y>=1, we can safely divide by Y
      r=x/y;
      result=v;
      //--- check
      if(v>r)
         result=r;
      else
         result=v;
     }
   else
     {
      //--- Y<1, we can safely multiply by Y
      if(x<v*y)
         result=x/y;
      else
         result=v;
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function makes periodic mapping of X to [A,B].              |
//| It accepts X, A, B (A>B). It returns T which lies in  [A,B] and  |
//| integer K, such that X = T + K*(B-A).                            |
//| NOTES:                                                           |
//| * K is represented as real value, although actually it is integer|
//| * T is guaranteed to be in [A,B]                                 |
//| * T replaces X                                                   |
//+------------------------------------------------------------------+
void CApServ::ApPeriodicMap(double &x,const double a,const double b,
                            double &k)
  {
//--- initialization
   k=0;
//--- check
   if(!CAp::Assert(a<b,__FUNCTION__+": internal error!"))
      return;
//--- initialization
   k=(int)MathFloor((x-a)/(b-a));
   x=x-k*(b-a);
//--- change values
   while(x<a)
     {
      x=x+(b-a);
      k=k-1;
     }
//--- change values
   while(x>b)
     {
      x=x-(b-a);
      k=k+1;
     }
//--- change values
   x=MathMax(x,a);
   x=MathMin(x,b);
  }
//+------------------------------------------------------------------+
//| Returns random normal number using low-quality system-provided   |
//| generator                                                        |
//+------------------------------------------------------------------+
double CApServ::RandomNormal(void)
  {
//--- create variables
   double result=0;
   double u=0;
   double v=0;
   double s=0;
//--- main loop
   while(true)
     {
      u=2*CMath::RandomReal()-1;
      v=2*CMath::RandomReal()-1;
      s=MathPow(u,2)+MathPow(v,2);
      if(s>0.0 && s<1.0)
        {
         //--- two Sqrt's instead of one to
         //--- avoid overflow when S is too small
         s=MathSqrt(-2*MathLog(s)/s);
         result=u*s;
         break;
        }
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generates random unit vector using low-quality system-provided   |
//| generator.                                                       |
//| Reallocates array if its size is too short.                      |
//+------------------------------------------------------------------+
void CApServ::RandomUnit(int n,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__": N<=0"))
      return;
//--- create variables
   double v=0;
   double vv=0;

   if((int)x.Size()<n)
      x.Resize(n);

   do
     {
      v=0.0;
      for(int i=0; i<n; i++)
        {
         vv=RandomNormal();
         x.Set(i,vv);
         v=v+vv*vv;
        }
     }
   while(v<=0.0);
   v=1.0/MathSqrt(v);
   x*=v;
  }
//+------------------------------------------------------------------+
//| This function is used to swap two values                         |
//+------------------------------------------------------------------+
template <typename T>
void CApServ::Swap(T &v0,T &v1)
  {
   T v=v0;
   v0=v1;
   v1=v;
  }
//+------------------------------------------------------------------+
//| This function is used to swap two rows of the matrix; if NCols<0,|
//| automatically determined from the matrix size.                   |
//+------------------------------------------------------------------+
void CApServ::SwapRows(CMatrixDouble &a,int i0,int i1,int ncols)
  {
   if(i0!=i1)
      a.SwapRows((ulong)i0,(ulong)i1);
  }
//+------------------------------------------------------------------+
//| This function is used to swap two cols of the matrix; if NRows<0,|
//|  automatically determined from the matrix size.                  |
//+------------------------------------------------------------------+
void CApServ::SwapCols(CMatrixDouble &a,int j0,int j1,int nrows)
  {
   if(j0!=j1)
      a.SwapCols((ulong)j0,(ulong)j1);
  }


//+------------------------------------------------------------------+
//| This function is used to swap two "entries" in 1-dimensional     |
//| array composed from D-element entries                            |
//+------------------------------------------------------------------+
void CApServ::SwapEntries(CRowDouble &a,int i0,int i1,int entrywidth)
  {
//--- create variables
   int offs0=i0*entrywidth;
   int offs1=i1*entrywidth;
//--- quick exit
   if(i0==i1)
      return;

   for(int j=0; j<entrywidth; j++)
      a.Swap(offs0+j,offs1+j);
  }
//+------------------------------------------------------------------+
//| This function is used to swap two elements of the vector         |
//+------------------------------------------------------------------+
void CApServ::SwapElements(CRowDouble &a,int i0,int i1)
  {
   if(i0!=i1)
      a.Swap(i0,i1);
  }
//+------------------------------------------------------------------+
//| This function is used to swap two elements of the vector         |
//+------------------------------------------------------------------+
void CApServ::SwapElementsI(CRowInt &a,int i0,int i1)
  {
   if(i0!=i1)
      a.Swap(i0,i1);
  }
//+------------------------------------------------------------------+
//| This function performs two operations:                           |
//| 1. decrements value of integer variable, if it is positive       |
//| 2. explicitly sets variable to zero if it is non-positive        |
//| It is used by some algorithms to decrease value of internal      |
//| counters.                                                        |
//+------------------------------------------------------------------+
void CApServ::CountDown(int &v)
  {
   if(v>0)
      v--;
   else
      v=0;
  }
//+------------------------------------------------------------------+
//| This function returns +1 or -1 depending on sign of X.           |
//| x=0 results in +1 being returned.                                |
//+------------------------------------------------------------------+
double CApServ::PosSign(double x)
  {
   double result=0;

   if(x>=0.0)
      result=1.0;
   else
      result=-1.0;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function returns (A div B) rounded up; it expects that A>0, |
//| B>0, but does not check it.                                      |
//+------------------------------------------------------------------+
int CApServ::IDivUp(int a,int b)
  {
   return((a+b-1)/b);
  }
//+------------------------------------------------------------------+
//| This function returns max(|r0|,|r1|,|r2|)                        |
//+------------------------------------------------------------------+
template <typename T>
T CApServ::RMaxAbs3(T r0,T r1,T r2)
  {
   T result=(T)MathMax(MathAbs(r0),MathAbs(r1));
   result=(T)MathMax(result,MathAbs(r2));
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| 'bounds' value: maps X to [B1,B2]                                |
//+------------------------------------------------------------------+
template <typename T>
T CApServ::BoundVal(const T x,const T b1,const T b2)
  {
//--- check
   if(x<=b1)
      return(b1);
//--- check
   if(x>=b2)
      return(b2);
//--- return result
   return(x);
  }
//+------------------------------------------------------------------+
//| Returns number of non-zeros                                      |
//+------------------------------------------------------------------+
int CApServ::CountNZ1(CRowDouble &v,int n)
  {
   int result=0;
//--- main loop
   for(int i=0; i<n; i++)
      if(v[i]!=0)
         result++;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Returns number of non-zeros                                      |
//+------------------------------------------------------------------+
int CApServ::CountNZ2(CMatrixDouble &v,int m,int n)
  {
   int result=0;
//--- main loop
   for(int i=0; i<m; i++)
      for(int j=0; j<n; j++)
         if(v.Get(i,j)!=0)
            result++;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: complex value                          |
//+------------------------------------------------------------------+
void CApServ::AllocComplex(CSerializer &s,complex &v)
  {
//--- entry
   s.Alloc_Entry();
   s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Serialization: complex value                                     |
//+------------------------------------------------------------------+
void CApServ::SerializeComplex(CSerializer &s,complex &v)
  {
//--- serialization
   s.Serialize_Double(v.real);
   s.Serialize_Double(v.imag);
  }
//+------------------------------------------------------------------+
//| Unserialization: complex value                                   |
//+------------------------------------------------------------------+
complex CApServ::UnserializeComplex(CSerializer &s)
  {
   complex result;
//--- unserialization
   result.real=s.Unserialize_Double();
   result.imag=s.Unserialize_Double();
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: real array                             |
//+------------------------------------------------------------------+
void CApServ::AllocRealArray(CSerializer &s,double &v[],int n)
  {
//--- check
   if(n<0)
      n=CAp::Len(v);
//--- entry
   s.Alloc_Entry();
   for(int i=0; i<n; i++)
      s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: real array                             |
//+------------------------------------------------------------------+
void CApServ::AllocRealArray(CSerializer &s,CRowDouble &v,int n)
  {
//--- check
   if(n<0)
      n=(int)v.Size();
//--- entry
   s.Alloc_Entry();
   for(int i=0; i<n; i++)
      s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Serialization: real array                                        |
//+------------------------------------------------------------------+
void CApServ::SerializeRealArray(CSerializer &s,double &v[],int n)
  {
//--- check
   if(n<0)
      n=CAp::Len(v);
//--- serialization
   s.Serialize_Int(n);
   for(int i=0; i<n; i++)
      s.Serialize_Double(v[i]);
  }
//+------------------------------------------------------------------+
//| Serialization: real array                                        |
//+------------------------------------------------------------------+
void CApServ::SerializeRealArray(CSerializer &s,CRowDouble &v,int n)
  {
//--- check
   if(n<0)
      n=(int)v.Size();
//--- serialization
   s.Serialize_Int(n);
   for(int i=0; i<n; i++)
      s.Serialize_Double(v[i]);
  }
//+------------------------------------------------------------------+
//| Unserialization: real array                                      |
//+------------------------------------------------------------------+
void CApServ::UnserializeRealArray(CSerializer &s,double &v[])
  {
//--- unserialization
   int n=s.Unserialize_Int();
//--- check
   if(n==0)
      return;
//--- allocation
   ArrayResize(v,n);
//--- unserialization
   for(int i=0; i<n; i++)
      v[i]=s.Unserialize_Double();
  }
//+------------------------------------------------------------------+
//| Unserialization: real array                                      |
//+------------------------------------------------------------------+
void CApServ::UnserializeRealArray(CSerializer &s,CRowDouble &v)
  {
//--- unserialization
   int n=s.Unserialize_Int();
//--- check
   if(n==0)
      return;
//--- allocation
   v.Resize(n);
//--- unserialization
   for(int i=0; i<n; i++)
      v.Set(i,s.Unserialize_Double());
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: Integer array                          |
//+------------------------------------------------------------------+
void CApServ::AllocIntegerArray(CSerializer &s,int &v[],int n)
  {
//--- check
   if(n<0)
      n=CAp::Len(v);
//--- entry
   s.Alloc_Entry();
   for(int i=0; i<n; i++)
      s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: Integer array                          |
//+------------------------------------------------------------------+
void CApServ::AllocIntegerArray(CSerializer &s,CRowInt &v,int n)
  {
//--- check
   if(n<0)
      n=v.Size();
//--- entry
   s.Alloc_Entry();
   for(int i=0; i<n; i++)
      s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Serialization: Integer array                                     |
//+------------------------------------------------------------------+
void CApServ::SerializeIntegerArray(CSerializer &s,int &v[],int n)
  {
//--- check
   if(n<0)
      n=CAp::Len(v);
//--- serialization
   s.Serialize_Int(n);
   for(int i=0; i<n; i++)
      s.Serialize_Int(v[i]);
  }
//+------------------------------------------------------------------+
//| Serialization: Integer array                                     |
//+------------------------------------------------------------------+
void CApServ::SerializeIntegerArray(CSerializer &s,CRowInt &v,int n)
  {
//--- check
   if(n<0)
      n=v.Size();
//--- serialization
   s.Serialize_Int(n);
   for(int i=0; i<n; i++)
      s.Serialize_Int(v[i]);
  }
//+------------------------------------------------------------------+
//| Unserialization: Integer array                                   |
//+------------------------------------------------------------------+
void CApServ::UnserializeIntegerArray(CSerializer &s,int &v[])
  {
//--- unserialization
   int n=s.Unserialize_Int();
//--- check
   if(n==0)
      return;
//--- allocation
   ArrayResizeAL(v,n);
   for(int i=0; i<n; i++)
      v[i]=s.Unserialize_Int();
  }
//+------------------------------------------------------------------+
//| Unserialization: Integer array                                   |
//+------------------------------------------------------------------+
void CApServ::UnserializeIntegerArray(CSerializer &s,CRowInt &v)
  {
//--- unserialization
   int n=s.Unserialize_Int();
//--- check
   if(n==0)
      return;
//--- allocation
   v.Resize(n);
   for(int i=0; i<n; i++)
      v.Set(i,s.Unserialize_Int());
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: Bool array                             |
//+------------------------------------------------------------------+
void CApServ::AllocBoolArray(CSerializer &s,bool &v[],int n)
  {
//--- check
   if(n<0)
      n=(int)v.Size();
//--- entry
   s.Alloc_Entry();
   for(int i=0; i<n; i++)
      s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Serialization: Bool array                                        |
//+------------------------------------------------------------------+
void CApServ::SerializeBoolArray(CSerializer &s,bool &v[],int n)
  {
//--- check
   if(n<0)
      n=(int)v.Size();
//--- serialization
   s.Serialize_Int(n);
   for(int i=0; i<n; i++)
      s.Serialize_Bool(v[i]);
  }
//+------------------------------------------------------------------+
//| Allocation of serializer: real matrix                            |
//+------------------------------------------------------------------+
void CApServ::AllocRealMatrix(CSerializer &s,CMatrixDouble &v,int n0,int n1)
  {
//--- check
   if(n0<0)
      n0=(int)CAp::Rows(v);
//--- check
   if(n1<0)
      n1=(int)CAp::Cols(v);
//--- entry
   s.Alloc_Entry();
   s.Alloc_Entry();
   for(int i=0; i<n0; i++)
      for(int j=0; j<n1; j++)
         s.Alloc_Entry();
  }
//+------------------------------------------------------------------+
//| Serialization: real matrix                                       |
//+------------------------------------------------------------------+
void CApServ::SerializeRealMatrix(CSerializer &s,CMatrixDouble &v,int n0,int n1)
  {
//--- check
   if(n0<0)
      n0=(int)CAp::Rows(v);
//--- check
   if(n1<0)
      n1=(int)CAp::Cols(v);
//--- serialization
   s.Serialize_Int(n0);
//--- serialization
   s.Serialize_Int(n1);
   for(int i=0; i<n0; i++)
      for(int j=0; j<n1; j++)
         s.Serialize_Double(v.Get(i,j));
  }
//+------------------------------------------------------------------+
//| Unserialization: real matrix                                     |
//+------------------------------------------------------------------+
void CApServ::UnserializeRealMatrix(CSerializer &s,CMatrixDouble &v)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    n0=0;
   int    n1=0;
   double t=0;
//--- unserialization
   n0=s.Unserialize_Int();
   n1=s.Unserialize_Int();
//--- check
   if(n0==0 || n1==0)
      return;
//--- resize
   v.Resize(n0,n1);
//--- unserialization
   for(i=0; i<n0; i++)
      for(j=0; j<n1; j++)
         v.Set(i,j,s.Unserialize_Double());
  }
//+------------------------------------------------------------------+
//| Copy integer array                                               |
//+------------------------------------------------------------------+
void CApServ::CopyIntegerArray(int &src[],int &dst[])
  {
//--- check
   if(CAp::Len(src)>0)
     {
      //--- allocation
      ArrayResizeAL(dst,CAp::Len(src));
      //--- copy
      ArrayCopy(dst,src);
     }
  }
//+------------------------------------------------------------------+
//| Copy integer array                                               |
//+------------------------------------------------------------------+
void CApServ::CopyIntegerArray(CRowInt &src,CRowInt &dst)
  {
   dst=src;
  }
//+------------------------------------------------------------------+
//| Copy real array                                                  |
//+------------------------------------------------------------------+
void CApServ::CopyRealArray(double &src[],double &dst[])
  {
//--- check
   if(CAp::Len(src)>0)
     {
      ArrayResize(dst,CAp::Len(src));
      ArrayCopy(dst,src);
     }
  }
//+------------------------------------------------------------------+
//| Copy real array                                                  |
//+------------------------------------------------------------------+
void CApServ::CopyRealArray(double &src[],CRowDouble &dst)
  {
   dst=src;
  }
//+------------------------------------------------------------------+
//| Copy real array                                                  |
//+------------------------------------------------------------------+
void CApServ::CopyRealArray(CRowDouble &src,CRowDouble &dst)
  {
   dst=src;
  }
//+------------------------------------------------------------------+
//| Copy real matrix                                                 |
//+------------------------------------------------------------------+
void CApServ::CopyRealMatrix(CMatrixDouble &src,CMatrixDouble &dst)
  {
   dst=src;
  }
//+------------------------------------------------------------------+
//| This function is used in parallel functions for recurrent        |
//| division of large task into two smaller tasks.                   |
//| It has following properties:                                     |
//|   * it works only for TaskSize>=2 and TaskSize>TileSize          |
//|     (assertion is thrown otherwise)                              |
//|   * Task0+Task1=TaskSize, Task0>0, Task1>0                       |
//|   * Task0 and Task1 are close to each other                      |
//|   * Task0>=Task1                                                 |
//|   * Task0 is always divisible by TileSize                        |
//+------------------------------------------------------------------+
void CApServ::TiledSplit(int tasksize,int tilesize,
                         int &task0,int &task1)
  {
   task0=0;
   task1=0;
//---check
   if(!CAp::Assert(tasksize>=2,__FUNCTION__": TaskSize<2"))
      return;
   if(!CAp::Assert(tasksize>tilesize,__FUNCTION__": TaskSize<=TileSize"))
      return;
   int cc=ChunksCount(tasksize,tilesize);
   if(!CAp::Assert(cc>=2,__FUNCTION__": integrity check failed"))
      return;
   task0=IDivUp(cc,2)*tilesize;
   task1=tasksize-task0;
//--- check
   if(!CAp::Assert(task0>=1,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(task1>=1,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(task0%tilesize==0,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(task0>=task1,__FUNCTION__": internal error"))
      return;
  }
//+------------------------------------------------------------------+
//| This function searches integer array. Elements in this array are |
//| actually records, each NRec elements wide. Each record has unique|
//| header - NHeader integer values, which identify it. Records are  |
//| lexicographically sorted by header.                              |
//| Records are identified by their index, not offset                |
//| (offset = NRec*index).                                           |
//| This function searches A (records with indices [I0,I1)) for a    |
//| record with header B. It returns index of this record            |
//| (not offset!), or -1 on failure.                                 |
//+------------------------------------------------------------------+
int CApServ::RecSearch(int &a[],const int nrec,const int nheader,int i0,int i1,int &b[])
  {
//--- create variables
   int mididx=0;
   int cflag=0;
   int k=0;
   int offs=0;
//--- cycle
   while(true)
     {
      //--- check
      if(i0>=i1)
         break;
      //--- change values
      mididx=(i0+i1)/2;
      offs=nrec*mididx;
      cflag=0;
      for(k=0; k<nheader ; k++)
        {
         //--- check
         if(a[offs+k]<b[k])
           {
            cflag=-1;
            break;
           }
         //--- check
         if(a[offs+k]>b[k])
           {
            cflag=1;
            break;
           }
        }
      //--- check
      if(cflag==0)
        {
         return(mididx);
        }
      //--- check
      if(cflag<0)
         i0=mididx+1;
      else
         i1=mididx;
     }
//--- return result
   return(-1);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
int CApServ::RecSearch(CRowInt &a,const int nrec,
                       const int nheader,int i0,
                       int i1,CRowInt &b)
  {
//--- create variables
   int mididx=0;
   int cflag=0;
   int k=0;
   int offs=0;
//--- cycle
   while(true)
     {
      //--- check
      if(i0>=i1)
         break;
      //--- change values
      mididx=(i0+i1)/2;
      offs=nrec*mididx;
      cflag=0;
      for(k=0; k<nheader; k++)
        {
         //--- check
         if(a[offs+k]<b[k])
           {
            cflag=-1;
            break;
           }
         //--- check
         if(a[offs+k]>b[k])
           {
            cflag=1;
            break;
           }
        }
      //--- check
      if(cflag==0)
         return(mididx);
      //--- check
      if(cflag<0)
         i0=mididx+1;
      else
         i1=mididx;
     }
//--- return result
   return(-1);
  }
//+------------------------------------------------------------------+
//| This function is used in parallel functions for recurrent        |
//| division of large task into two smaller tasks.                   |
//| It has following properties:                                     |
//|   * it works only for TaskSize>=2 (assertion is thrown otherwise)|
//|   * for TaskSize=2, it returns Task0=1, Task1=1                  |
//|   * in case TaskSize is odd,  Task0=TaskSize-1, Task1=1          |
//|   * in case TaskSize is even, Task0 and Task1 are approximately  |
//|     TaskSize/2 and both Task0 and Task1 are even, Task0>=Task1   |
//+------------------------------------------------------------------+
void CApServ::SplitLengthEven(int tasksize,int &task0,int &task1)
  {
//--- initialize
   task0=0;
   task1=0;
//---chek
   if(!CAp::Assert(tasksize>=2,__FUNCTION__": TaskSize<2"))
      return;
   if(tasksize==2)
     {
      task0=1;
      task1=1;
      return;
     }
   if(tasksize%2==0)
     {
      //--- Even division
      task1=task0=tasksize/2;
      if(task0%2!=0)
        {
         task0++;
         task1--;
        }
     }
   else
     {
      //--- Odd task size, split trailing odd part from it.
      task0=tasksize-1;
      task1=1;
     }
   if(!CAp::Assert(task0>=1,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(task1>=1,__FUNCTION__": internal error"))
      return;
  }
//+------------------------------------------------------------------+
//| This function is used to calculate number of chunks (including   |
//| partial, non-complete chunks) in some set. It expects that       |
//| ChunkSize>=1, TaskSize>=0. Assertion is thrown otherwise.        |
//| Function result is equivalent to Ceil(TaskSize/ChunkSize), but   |
//| with guarantees that rounding errors won't ruin results.         |
//+------------------------------------------------------------------+
int CApServ::ChunksCount(int tasksize,int m_ChunkSize)
  {
   int result=0;
//--- check
   if(!CAp::Assert(tasksize>=0,__FUNCTION__": TaskSize<0"))
      return(-1);
   if(!CAp::Assert(m_ChunkSize>=1,__FUNCTION__": ChunkSize<1"))
      return(-1);

   result=(tasksize+m_ChunkSize-1)/m_ChunkSize;

   return(result);
  }
//+------------------------------------------------------------------+
//| The function performs zero-coalescing on real value.             |
//| NOTE: no check is performed for B<>0                             |
//+------------------------------------------------------------------+
double CApServ::Coalesce(double a,double b)
  {
   double result=a;
   if(a==0.0)
      result=b;

   return(result);
  }
//+------------------------------------------------------------------+
//| The function performs zero-coalescing on integer value.          |
//| NOTE: no check is performed for B<>0                             |
//+------------------------------------------------------------------+
int CApServ::CoalesceI(int a,int b)
  {
   int result=a;
   if(a==0)
      result=b;

   return(result);
  }
//+------------------------------------------------------------------+
//| The function calculates binary logarithm.                        |
//| NOTE: it costs twice as much as Ln(x)                            |
//+------------------------------------------------------------------+
double CApServ::LogBase2(double x)
  {
   return(MathLog(x)/MathLog(2.0));
  }
//+------------------------------------------------------------------+
//| This function compares two numbers for approximate equality, with|
//| tolerance to errors as large as tol.                             |
//+------------------------------------------------------------------+
bool CApServ::ApproxEqual(double a,double b,double tol)
  {
   return(MathAbs(a-b)<=tol);
  }
//+------------------------------------------------------------------+
//| This function compares two numbers for approximate equality, with|
//| tolerance to errors as large as max(|a|,|b|)*tol.                |
//+------------------------------------------------------------------+
bool CApServ::ApproxEqualRel(double a,double b,double tol)
  {
   return(MathAbs(a-b)<=MathMax(MathAbs(a),MathAbs(b))*tol);
  }
//+------------------------------------------------------------------+
//| Returns maximum density for level 2 sparse/dense functions.      |
//| Density values below one returned by this function are better to |
//| handle via sparse Level 2 functionality.                         |
//+------------------------------------------------------------------+
double CApServ::SparseLevel2Density(void)
  {
   return(0.1);
  }
//+------------------------------------------------------------------+
//| Returns A-tile size for a matrix.                                |
//| A-tiles are smallest tiles (32x32), suitable for processing by   |
//| ALGLIB own implementation of Level 3 linear algebra.             |
//+------------------------------------------------------------------+
int CApServ::MatrixTileSizeA(void)
  {
   return(32);
  }
//+------------------------------------------------------------------+
//| Returns B-tile size for a matrix.                                |
//| B-tiles are larger tiles (64x64), suitable for parallel execution|
//| or for processing by vendor's implementation of Level 3 linear   |
//| algebra.                                                         |
//+------------------------------------------------------------------+
int CApServ::MatrixTileSizeB(void)
  {
   return(64);
  }
//+------------------------------------------------------------------+
//| This function returns minimum cost of task which is feasible for |
//| multithreaded processing. It returns real number in order to     |
//| avoid overflow problems.                                         |
//+------------------------------------------------------------------+
double CApServ::SMPActivationLevel(void)
  {
   double nn=2*MatrixTileSizeB();
   return(MathMax(1.9*MathPow(nn,3),1.0E7));
  }
//+------------------------------------------------------------------+
//| This function returns minimum cost of task which is feasible for |
//| spawn (given that multithreading is active).                     |
//| It returns real number in order to avoid overflow problems.      |
//+------------------------------------------------------------------+
double CApServ::SpawnLevel(void)
  {
   double nn=2*MatrixTileSizeA();
   return(1.9*MathPow(nn,3));
  }
//+------------------------------------------------------------------+
//| --- OBSOLETE FUNCTION, USE TILED SPLIT INSTEAD ---               |
//| This function is used in parallel functions for recurrent        |
//| division of large task into two smaller tasks.                   |
//| It has following properties:                                     |
//|   * it works only for TaskSize>=2 and ChunkSize>=2 (assertion is |
//|     thrown otherwise)                                            |
//|   * Task0+Task1=TaskSize, Task0>0, Task1>0                       |
//|   * Task0 and Task1 are close to each other                      |
//|   * in case TaskSize>ChunkSize, Task0 is always divisible by     |
//|     ChunkSize                                                    |
//+------------------------------------------------------------------+
void CApServ::SplitLength(int tasksize,int m_ChunkSize,
                          int &task0,int &task1)
  {
   task0=0;
   task1=0;
//--- check
   if(!CAp::Assert(m_ChunkSize>=2,__FUNCTION__": ChunkSize<2"))
      return;
   if(!CAp::Assert(tasksize>=2,__FUNCTION__": TaskSize<2"))
      return;
   task0=tasksize/2;
   if(task0>m_ChunkSize && task0%m_ChunkSize!=0)
      task0=task0-task0%m_ChunkSize;
   task1=tasksize-task0;
//--- check
   if(!CAp::Assert(task0>=1,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(task1>=1,__FUNCTION__": internal error"))
      return;
  }
//+------------------------------------------------------------------+
//| Outputs vector A[I0,I1-1] to trace log using either:             |
//|   a)  6-digit exponential format (no trace flags is set)         |
//|   b) 15-ditit exponential format ('PREC.E15' trace flag is set)  |
//|   c)  6-ditit fixed-point format ('PREC.F6' trace flag is set)   |
//| This function checks trace flags every time it is called.        |
//+------------------------------------------------------------------+
void CApServ::TraceVectorAutopRec(CRowDouble &a,int i0,int i1)
  {
   int prectouse=0;
//--- Determine precision to use
   if(CAp::IsTraceEnabled("PREC.E15"))
      prectouse=1;
   if(CAp::IsTraceEnabled("PREC.F6"))
      prectouse=2;
//--- Output
   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      switch(prectouse)
        {
         case 0:
            CAp::Trace(StringFormat("%14.6E",a[i]));
            break;
         case 1:
            CAp::Trace(StringFormat("%23.15E",a[i]));
            break;
         case 2:
            CAp::Trace(StringFormat("%13.6F",a[i]));
            break;
        }
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs row A[I,J0..J1-1] to trace log using either:             |
//|   a)  6-digit exponential format (no trace flags is set)         |
//|   b) 15-ditit exponential format ('PREC.E15' trace flag is set)  |
//|   c)  6-ditit fixed-point format ('PREC.F6' trace flag is set)   |
//| This function checks trace flags every time it is called.        |
//+------------------------------------------------------------------+
void CApServ::TraceRowAutopRec(CMatrixDouble &a,int i,int j0,int j1)
  {
//--- create variables
   CRowDouble Row=a.Row(i)+0;
   TraceVectorAutopRec(Row,j0,j1);
  }
//+------------------------------------------------------------------+
//| Unscales/unshifts vector A[N] by computing A*Scl+Sft and outputs |
//| result to trace log using either:                                |
//|   a)  6-digit exponential format (no trace flags is set)         |
//|   b) 15-ditit exponential format ('PREC.E15' trace flag is set)  |
//|   b)  6-ditit fixed-point format ('PREC.F6' trace flag is set)   |
//| This function checks trace flags every time it is called.        |
//| Both Scl and Sft can be omitted.                                 |
//+------------------------------------------------------------------+
void CApServ::TraceVectoRunScaledUnshiftedAutopRec(CRowDouble &x,
                                                   int n,
                                                   CRowDouble &scl,
                                                   bool applyscl,
                                                   CRowDouble &sft,
                                                   bool applysft)
  {
//--- create variables
   int    prectouse=0;
   double v=0;
//--- Determine precision to use
   if(CAp::IsTraceEnabled("PREC.E15"))
      prectouse=1;
   if(CAp::IsTraceEnabled("PREC.F6"))
      prectouse=2;
//--- Output
   CAp::Trace("[ ");
   for(int i=0; i<n; i++)
     {
      v=x[i];
      if(applyscl)
         v=v*scl[i];
      if(applysft)
         v=v+sft[i];
      switch(prectouse)
        {
         case 0:
            CAp::Trace(StringFormat("%14.6E",v));
            break;
         case 1:
            CAp::Trace(StringFormat("%23.15E",v));
            break;
         case 2:
            CAp::Trace(StringFormat("%13.6F",v));
            break;
        }
      if(i<n-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Unscales/unshifts vector A[N] by computing A*Scl+Sft and outputs |
//| result to trace log using either:                                |
//|   a)  6-digit exponential format (no trace flags is set)         |
//|   b) 15-ditit exponential format ('PREC.E15' trace flag is set)  |
//|   c)  6-ditit fixed-point format ('PREC.F6' trace flag is set)   |
//| This function checks trace flags every time it is called.        |
//| Both Scl and Sft can be omitted.                                 |
//+------------------------------------------------------------------+
void CApServ::TraceVectorUnscaledUnshiftedAutopRec(CRowDouble &x,
                                                   int n,
                                                   CRowDouble &scl,
                                                   bool applyscl,
                                                   CRowDouble &sft,
                                                   bool applysft)
  {
//--- create variables
   int    prectouse=0;
   double v=0;
//--- Determine precision to use
   if(CAp::IsTraceEnabled("PREC.E15"))
      prectouse=1;
   if(CAp::IsTraceEnabled("PREC.F6"))
      prectouse=2;
//--- Output
   CAp::Trace("[ ");
   for(int i=0; i<n; i++)
     {
      v=x[i];
      if(applyscl)
         v*=scl[i];
      if(applysft)
         v+=sft[i];
      switch(prectouse)
        {
         case 0:
            CAp::Trace(StringFormat("%14.6E",v));
            break;
         case 1:
            CAp::Trace(StringFormat("%23.15E",v));
            break;
         case 2:
            CAp::Trace(StringFormat("%13.6F",v));
            break;
        }
      if(i<n-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs vector of 1-norms of rows [I0,I1-1] of                   |
//| A[I0...I1-1,J0...J1-1] to trace log using either:                |
//|   a) 6-digit exponential format (no trace flags is set)          |
//|   b) 15-ditit exponential format ('PREC.E15' trace flag is set)  |
//|   c) 6-ditit fixed-point format ('PREC.F6' trace flag is set)    |
//| This function checks trace flags every time it is called.        |
//+------------------------------------------------------------------+
void CApServ::TraceRowNrm1AutopRec(CMatrixDouble &a,int i0,int i1,
                                   int j0,int j1)
  {
//--- create variables
   double v=0;
   int    prectouse=0;
//--- Determine precision to use
   if(CAp::IsTraceEnabled("PREC.E15"))
      prectouse=1;
   if(CAp::IsTraceEnabled("PREC.F6"))
      prectouse=2;
//--- Output
   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      v=0;
      for(int j=j0; j<j1; j++)
         v=MathMax(v,MathAbs(a.Get(i,j)));
      switch(prectouse)
        {
         case 0:
            CAp::Trace(StringFormat("%14.6E",v));
            break;
         case 1:
            CAp::Trace(StringFormat("%23.15E",v));
            break;
         case 2:
            CAp::Trace(StringFormat("%13.6F",v));
            break;
        }
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs vector A[I0,I1-1] to trace log using E3 precision        |
//+------------------------------------------------------------------+
void CApServ::TraceVectorE3(CRowDouble &a,int i0,int i1)
  {
   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      CAp::Trace(StringFormat("%11.3E}",a[i]));
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs vector A[I0,I1-1] to trace log using E6 precision        |
//+------------------------------------------------------------------+
void CApServ::TraceVectorE6(CRowDouble &a,int i0,int i1)
  {
   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      CAp::Trace(StringFormat("%14.6E",a[i]));
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs vector A[I0,I1-1] to trace log using E8 or E15 precision |
//+------------------------------------------------------------------+
void CApServ::TraceVectorE615(CRowDouble &a,int i0,int i1,bool usee15)
  {
   if(!usee15)
     {
      TraceVectorE6(a,i0,i1);
      return;
     }

   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      CAp::Trace(StringFormat("23.15E",a[i]));
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Outputs vector of 1-norms of rows [I0,I1-1] of                   |
//| A[I0...I1-1,J0...J1-1] to trace log using E8 precision           |
//+------------------------------------------------------------------+
void CApServ::TraceRowNrm1E6(CMatrixDouble &a,int i0,int i1,int j0,int j1)
  {
   CAp::Trace("[ ");
   for(int i=i0; i<i1; i++)
     {
      double v=0;
      for(int j=j0; j<j1; j++)
         v=MathMax(v,MathAbs(a.Get(i,j)));
      CAp::Trace(StringFormat("%14.6E",v));
      if(i<i1-1)
         CAp::Trace(" ");
     }
   CAp::Trace(" ]");
  }
//+------------------------------------------------------------------+
//| Tag Sort                                                         |
//+------------------------------------------------------------------+
class CTSort
  {
public:
   static void       TagSort(double &a[],const int n,int &p1[],int &p2[]);
   static void       TagSort(CRowDouble &a,const int n,CRowInt &p1,CRowInt &p2);
   static void       TagSortBuf(double &a[],const int n,int &p1[],int &p2[],CApBuff &buf);
   static void       TagSortBuf(CRowDouble &a,const int n,CRowInt &p1,CRowInt &p2,CApBuff &buf);
   static void       TagSortFastI(double &a[],int &b[],double &bufa[],int &bufb[],const int n);
   static void       TagSortFastI(double &a[],int &b[],CRowDouble &bufa,CRowInt &bufb,const int n);
   static void       TagSortFastI(CRowDouble &a,CRowInt &b,CRowDouble &bufa,CRowInt &bufb,const int n);
   static void       TagSortFastR(double &a[],double &b[],double &bufa[],double &bufb[],const int n);
   static void       TagSortFastR(CRowDouble &a,CRowDouble &b,CRowDouble &bufa,CRowDouble &bufb,const int n);
   static void       TagSortFast(double &a[],double &bufa[],const int n);
   static void       TagSortFast(CRowDouble &a,CRowDouble &bufa,const int n);
   static void       TagSortMiddleIR(CRowInt &a,CRowDouble &b,int offset,int n);
   static void       TagSortMiddleII(CRowInt &a,CRowInt &b,int offset,int n);
   static void       TagSortMiddleI(CRowInt &a,int offset,int n);
   static void       SortMiddleI(CRowInt &a,int offset,int n);
   static void       TagHeapPushI(double &a[],int &b[],int &n,const double va,const int vb);
   static void       TagHeapPushI(CRowDouble &a,CRowInt &b,int &n,const double va,const int vb);
   static void       TagHeapReplaceTopI(double &a[],int &b[],const int n,const double va,const int vb);
   static void       TagHeapReplaceTopI(CRowDouble &a,CRowInt &b,const int n,const double va,const int vb);
   static void       TagHeapPopI(double &a[],int &b[],int &n);
   static void       TagHeapPopI(CRowDouble &a,CRowInt &b,int &n);
   static int        LowerBound(CRowDouble &a,int n,double t);
   static int        UpperBound(CRowDouble &a,int n,double t);

private:
   static void       TagSortFastIRec(double &a[],int &b[],double &bufa[],int &bufb[],const int i1,const int i2);
   static void       TagSortFastIRec(double &a[],int &b[],CRowDouble &bufa,CRowInt &bufb,const int i1,const int i2);
   static void       TagSortFastIRec(CRowDouble &a,CRowInt &b,CRowDouble &bufa,CRowInt &bufb,const int i1,const int i2);
   static void       TagSortFastRRec(CRowDouble &a,CRowDouble &b,CRowDouble &bufa,CRowDouble &bufb,const int i1,const int i2);
   static void       TagSortFastRec(CRowDouble &a,CRowDouble &bufa,const int i1,const int i2);
  };
//+------------------------------------------------------------------+
//| This function sorts array of real keys by ascending.             |
//| Its results are:                                                 |
//| * sorted array A                                                 |
//| * permutation tables P1, P2                                      |
//| Algorithm outputs permutation tables using two formats:          |
//| * as usual permutation of [0..N-1]. If P1[i]=j, then sorted A[i] |
//|   contains value which was moved there from J-th position.       |
//| * as a sequence of pairwise permutations. Sorted A[] may be      |
//|    obtained byswaping A[i] and A[P2[i]] for all i from 0 to N-1. |
//| INPUT PARAMETERS:                                                |
//|     A       -   unsorted array                                   |
//|     N       -   array size                                       |
//| OUPUT PARAMETERS:                                                |
//|     A       -   sorted array                                     |
//|     P1, P2  -   permutation tables, array[N]                     |
//| NOTES:                                                           |
//|     this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//+------------------------------------------------------------------+
void CTSort::TagSort(double &a[],const int n,int &p1[],int &p2[])
  {
//--- create a variable
   CApBuff buf;
//--- function call
   TagSortBuf(a,n,p1,p2,buf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTSort::TagSort(CRowDouble &a,const int n,CRowInt &p1,CRowInt &p2)
  {
//--- create a variable
   CApBuff buf;
//--- function call
   TagSortBuf(a,n,p1,p2,buf);
  }
//+------------------------------------------------------------------+
//| Buffered variant of TagSort, which accepts preallocated output   |
//| arrays as well as special structure for buffered allocations. If |
//| arrays are too short, they are reallocated. If they are large    |
//| enough, no memoryallocation is done.                             |
//| It is intended to be used in the performance-critical parts of   |
//| code, where additional allocations can lead to severe performance|
//| degradation                                                      |
//+------------------------------------------------------------------+
void CTSort::TagSortBuf(double &a[],const int n,int &p1[],int &p2[],
                        CApBuff &buf)
  {
   CRowDouble A=a;
   CRowInt P1=p1;
   CRowInt P2=p1;
   TagSortBuf(A,n,P1,P2,buf);
   A.ToArray(a);
   P1.ToArray(p1);
   P2.ToArray(p2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTSort::TagSortBuf(CRowDouble &a,const int n,CRowInt &p1,CRowInt &p2,
                        CApBuff &buf)
  {
//--- create variables
   int i=0;
   int lv=0;
   int rv=0;
   int rp=0;
//--- Special cases
   if(n<=0)
      return;
//--- check
   if(n==1)
     {
      //--- function call
      CApServ::IVectorSetLengthAtLeast(p1,1);
      //--- function call
      CApServ::IVectorSetLengthAtLeast(p2,1);
      p1.Set(0,0);
      p2.Set(0,0);
      //--- exit the function
      return;
     }
//--- General case, N>1: prepare permutations table P1
   CApServ::IVectorSetLengthAtLeast(p1,n);
   for(i=0; i<n; i++)
      p1.Set(i,i);
//--- General case, N>1: sort, update P1
   CApServ::RVectorSetLengthAtLeast(buf.m_ra0,n);
//--- function call
   CApServ::IVectorSetLengthAtLeast(buf.m_ia0,n);
   TagSortFastI(a,p1,buf.m_ra0,buf.m_ia0,n);
//--- General case, N>1: fill permutations table P2
//--- To fill P2 we maintain two arrays:
//--- * PV (Buf.IA0), Position(Value). PV[i] contains position of I-th key at the moment
//--- * VP (Buf.IA1), Value(Position). VP[i] contains key which has position I at the moment
//--- At each step we making permutation of two items:
//--- Left,which is given by position/value pair LP/LV
//--- and Right,which is given by RP/RV
//--- and updating PV[] and VP[] correspondingly.
   CApServ::IVectorSetLengthAtLeast(buf.m_ia0,n);
//--- function call
   CApServ::IVectorSetLengthAtLeast(buf.m_ia1,n);
//--- function call
   CApServ::IVectorSetLengthAtLeast(p2,n);
   for(i=0; i<n; i++)
     {
      buf.m_ia0.Set(i,i);
      buf.m_ia1.Set(i,i);
     }
   for(i=0; i<n; i++)
     {
      //--- calculate LP, LV, RP, RV
      lv=buf.m_ia1[i];
      rv=p1[i];
      rp=buf.m_ia0[rv];
      //--- Fill P2
      p2.Set(i,rp);
      //--- update PV and VP
      buf.m_ia1.Set(i,rv);
      buf.m_ia1.Set(rp,lv);
      buf.m_ia0.Set(lv,rp);
      buf.m_ia0.Set(rv,i);
     }
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys and integer labels. |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//| 2.  this function uses two buffers, BufA and BufB, each is N     |
//|     elements large. They may be preallocated (which will save    |
//|     some time) or not, in which case function will automatically |
//|     allocate memory.                                             |
//+------------------------------------------------------------------+
void CTSort::TagSortFastI(double &a[],int &b[],double &bufa[],
                          int &bufb[],const int n)
  {
//--- create variables
   int    i=0;
   int    j=0;
   bool   isascending;
   bool   isdescending;
   double tmpr=0;
   int    tmpi=0;
//--- Special case
   if(n<=1)
      return;
//--- Test for already sorted set
   isascending=true;
   isdescending=true;
   for(i=1; i<n; i++)
     {
      isascending=isascending && a[i]>=a[i-1];
      isdescending=isdescending && a[i]<=a[i-1];
     }
//--- check
   if(isascending)
      return;
//--- check
   if(isdescending)
     {
      for(i=0; i<=n-1; i++)
        {
         j=n-1-i;
         //--- check
         if(j<=i)
            break;
         //--- swap
         tmpr=a[i];
         a[i]=a[j];
         a[j]=tmpr;
         tmpi=b[i];
         b[i]=b[j];
         b[j]=tmpi;
        }
      //--- exit the function
      return;
     }
//--- General case
   if(CAp::Len(bufa)<n)
      ArrayResize(bufa,n);
//--- check
   if(CAp::Len(bufb)<n)
      ArrayResizeAL(bufb,n);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,0,n-1);
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys and integer labels. |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//| 2.  this function uses two buffers, BufA and BufB, each is N     |
//|     elements large. They may be preallocated (which will save    |
//|     some time) or not, in which case function will automatically |
//|     allocate memory.                                             |
//+------------------------------------------------------------------+
void CTSort::TagSortFastI(double &a[],int &b[],CRowDouble &bufa,CRowInt &bufb,const int n)
  {
//--- create variables
   int    i=0;
   int    j=0;
   bool   isascending;
   bool   isdescending;
   double tmpr=0;
   int    tmpi=0;
//--- Special case
   if(n<=1)
      return;
//--- Test for already sorted set
   isascending=true;
   isdescending=true;
   for(i=1; i<n; i++)
     {
      isascending=isascending && a[i]>=a[i-1];
      isdescending=isdescending && a[i]<=a[i-1];
     }
//--- check
   if(isascending)
      return;
//--- check
   if(isdescending)
     {
      for(i=0; i<=n-1; i++)
        {
         j=n-1-i;
         //--- check
         if(j<=i)
            break;
         //--- swap
         tmpr=a[i];
         a[i]=a[j];
         a[j]=tmpr;
         tmpi=b[i];
         b[i]=b[j];
         b[j]=tmpi;
        }
      //--- exit the function
      return;
     }
//--- General case
   if((int)bufa.Size()<n)
      bufa.Resize(n);
//--- check
   if(bufb.Size()<n)
      bufb.Resize(n);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,0,n-1);
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys and integer labels. |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//| 2.  this function uses two buffers, BufA and BufB, each is N     |
//|     elements large. They may be preallocated (which will save    |
//|     some time) or not, in which case function will automatically |
//|     allocate memory.                                             |
//+------------------------------------------------------------------+
void CTSort::TagSortFastI(CRowDouble &a,CRowInt &b,CRowDouble &bufa,CRowInt &bufb,const int n)
  {
//--- create variables
   int    i=0;
   int    j=0;
   bool   isascending;
   bool   isdescending;
   double tmpr=0;
   int    tmpi=0;
//--- Special case
   if(n<=1)
      return;
//--- Test for already sorted set
   isascending=true;
   isdescending=true;
   for(i=1; i<n; i++)
     {
      isascending=isascending && a[i]>=a[i-1];
      isdescending=isdescending && a[i]<=a[i-1];
     }
//--- check
   if(isascending)
      return;
//--- check
   if(isdescending)
     {
      for(i=0; i<=n-1; i++)
        {
         j=n-1-i;
         //--- check
         if(j<=i)
            break;
         //--- swap
         a.Swap(i,j);
         b.Swap(i,j);
        }
      //--- exit the function
      return;
     }
//--- General case
   if((int)bufa.Size()<n)
      bufa.Resize(n);
//--- check
   if((int)bufb.Size()<n)
      bufb.Resize(n);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,0,n-1);
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys and real labels.    |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     etc.) are not that condition. All other conditions (size of  |
//|     input arrays, checked too.                                   |
//| 2.  this function uses two buffers, BufA and BufB, each is N     |
//|     elements large. They may be preallocated (which will save    |
//|     some time) or not, in whichcase function will automatically  |
//|     allocate memory.                                             |
//+------------------------------------------------------------------+
void CTSort::TagSortFastR(double &a[],double &b[],double &bufa[],
                          double &bufb[],const int n)
  {
//--- create variables
   int    i=0;
   int    j=0;
   bool   isascending=true;
   bool   isdescending=true;
   double tmpr=0;
//--- Special case
   if(n<=1)
      return;
//--- Test for already sorted set
   for(i=1; i<=n-1; i++)
     {
      isascending=isascending && a[i]>=a[i-1];
      isdescending=isdescending && a[i]<=a[i-1];
     }
//--- check
   if(isascending)
      return;
//--- check
   if(isdescending)
     {
      for(i=0; i<=n-1; i++)
        {
         j=n-1-i;
         //--- check
         if(j<=i)
            break;
         //--- swap
         tmpr=a[i];
         a[i]=a[j];
         a[j]=tmpr;
         tmpr=b[i];
         b[i]=b[j];
         b[j]=tmpr;
        }
      //--- exit the function
      return;
     }
//--- General case
   if(CAp::Len(bufa)<n)
      ArrayResize(bufa,n);
//--- check
   if(CAp::Len(bufb)<n)
      ArrayResize(bufb,n);
//--- function call
   CRowDouble A=a;
   CRowDouble B=b;
   CRowDouble bufA=bufa;
   CRowDouble bufB=bufb;
   TagSortFastRRec(A,B,bufA,bufB,0,n-1);
   A.ToArray(a);
   B.ToArray(b);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTSort::TagSortFastR(CRowDouble &a,CRowDouble &b,CRowDouble &bufa,
                          CRowDouble &bufb,const int n)
  {
//--- create variables
   int    i=0;
   int    j=0;
   bool   isascending=true;
   bool   isdescending=true;
   double tmpr=0;
//--- Special case
   if(n<=1)
      return;
//--- Test for already sorted set
   for(i=1; i<=n-1; i++)
     {
      isascending=isascending && a[i]>=a[i-1];
      isdescending=isdescending && a[i]<=a[i-1];
     }
//--- check
   if(isascending)
      return;
//--- check
   if(isdescending)
     {
      for(i=0; i<=n-1; i++)
        {
         j=n-1-i;
         //--- check
         if(j<=i)
            break;
         //--- swap
         a.Swap(i,j);
         b.Swap(i,j);
        }
      //--- exit the function
      return;
     }
//--- General case
   if(CAp::Len(bufa)<n)
      bufa.Resize(n);
//--- check
   if(CAp::Len(bufb)<n)
      bufb.Resize(n);
//--- function call
   TagSortFastRRec(a,b,bufa,bufb,0,n-1);
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys without labels.     |
//| A is sorted, and that's all.                                     |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//| 2.  this function uses buffer, BufA, which is N elements large.  |
//|     It may be preallocated (which will save some time) or not,   |
//|     in which casefunction will automatically allocate memory.    |
//+------------------------------------------------------------------+
void CTSort::TagSortFast(double &a[],double &bufa[],const int n)
  {
//--- Special case
   if(n<=1)
      return;
//--- create variables
   int    i;
   int    j;
   bool   isAsCending=true;
   bool   isDesCending=true;
   double tmpr;
//--- Test for already sorted set
   for(i=1; i<n; i++)
     {
      isAsCending=isAsCending && a[i]>=a[i-1];
      isDesCending=isDesCending && a[i]<=a[i-1];
     }
//--- check
   if(isAsCending)
      return;
//--- check
   if(isDesCending)
     {
      for(i=0; i<n; i++)
        {
         j=n-1-i;
         if(j<=i)
            break;
         tmpr=a[i];
         a[i]=a[j];
         a[j]=tmpr;
        }
      //--- exit the function
      return;
     }
//--- General case
   if(CAp::Len(bufa)<n)
      ArrayResize(bufa,n);
//--- function call
   CRowDouble A=a;
   CRowDouble bufA=bufa;
   TagSortFastRec(A,bufA,0,n-1);
   A.ToArray(a);
   bufA.ToArray(bufa);
  }
//+------------------------------------------------------------------+
//| Same as TagSort, but optimized for real keys without labels.     |
//| A is sorted, and that's all.                                     |
//| NOTES:                                                           |
//| 1.  this function assumes that A[] is finite; it doesn't checks  |
//|     that condition. All other conditions (size of input arrays,  |
//|     etc.) are not checked too.                                   |
//| 2.  this function uses buffer, BufA, which is N elements large.  |
//|     It may be preallocated (which will save some time) or not,   |
//|     in which casefunction will automatically allocate memory.    |
//+------------------------------------------------------------------+
void CTSort::TagSortFast(CRowDouble &a,CRowDouble &bufa,const int n)
  {
//--- Special case
   if(n<=1)
      return;
//--- create variables
   int  i;
   int  j;
   bool isAsCending=true;
   bool isDesCending=true;
//--- Test for already sorted set
   for(i=1; i<n; i++)
     {
      isAsCending=isAsCending && a[i]>=a[i-1];
      isDesCending=isDesCending && a[i]<=a[i-1];
     }
//--- check
   if(isAsCending)
      return;
//--- check
   if(isDesCending)
     {
      for(i=0; i<n; i++)
        {
         j=n-1-i;
         if(j<=i)
            break;
         a.Swap(i,j);
        }
      //--- exit the function
      return;
     }
//--- General case
   if(CAp::Len(bufa)<n)
      bufa.Resize(n);
//--- function call
   TagSortFastRec(a,bufa,0,n-1);
  }
//+------------------------------------------------------------------+
//| Sorting function optimized for integer keys and real labels, can |
//| be used to sort middle of the array                              |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES: this function assumes that A[] is finite; it doesn't      |
//|        checks that condition. All other conditions (size of input|
//|        arrays, etc.) are not checked too.                        |
//+------------------------------------------------------------------+
void CTSort::TagSortMiddleIR(CRowInt &a,CRowDouble &b,
                             int offset,int n)
  {
//--- Special cases
   if(n<=1)
      return;
//--- create variables
   int    i=0;
   int    k=0;
   int    t=0;
   int    tmp=0;
   double tmpr=0;
   int    p0=0;
   int    p1=0;
   int    at=0;
   int    ak=0;
   int    ak1=0;
   double bt=0;
//--- General case, N>1: sort, update B
   for(i=2; i<=n; i++)
     {
      t=i;
      while(t!=1)
        {
         k=t/2;
         p0=offset+k-1;
         p1=offset+t-1;
         ak=a[p0];
         at=a[p1];
         if(ak>=at)
            break;
         a.Swap(p0,p1);
         b.Swap(p0,p1);
         t=k;
        }
     }
   for(i=n-1; i>=1; i--)
     {
      p0=offset;
      p1=offset+i;
      at=a[p1];
      a.Swap(p1,p0);
      bt=b[p1];
      b.Swap(p1,p0);
      t=0;
      while(true)
        {
         k=2*t+1;
         if(k+1>i)
            break;
         p0=offset+t;
         p1=offset+k;
         ak=a[p1];
         if(k+1<i)
           {
            ak1=a[p1+1];
            if(ak1>ak)
              {
               ak=ak1;
               p1++;
               k++;
              }
           }
         if(at>=ak)
            break;
         a.Set(p1,at);
         a.Set(p0,ak);
         b.Set(p0,b[p1]);
         b.Set(p1,bt);
         t=k;
        }
     }
  }
//+------------------------------------------------------------------+
//| Sorting function optimized for integer keys and integer labels,  |
//| can be used to sort middle of the array                          |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES: this function assumes that A[] is finite; it doesn't      |
//|        checks that condition. All other conditions (size of input|
//|        arrays, etc.) are not checked too.                        |
//+------------------------------------------------------------------+
void CTSort::TagSortMiddleII(CRowInt &a,CRowInt &b,int offset,int n)
  {
//--- Special cases
   if(n<=1)
      return;
//--- create variables
   int i=0;
   int k=0;
   int t=0;
   int tmp=0;
   int tmpi=0;
   int p0=0;
   int p1=0;
   int at=0;
   int ak=0;
   int ak1=0;
   int bt=0;
//--- General case, N>1: sort, update B
   for(i=2; i<=n; i++)
     {
      t=i;
      while(t!=1)
        {
         k=t/2;
         p0=offset+k-1;
         p1=offset+t-1;
         ak=a[p0];
         at=a[p1];
         if(ak>=at)
            break;
         a.Swap(p0,p1);
         b.Swap(p0,p1);
         t=k;
        }
     }
   for(i=n-1; i>=1; i--)
     {
      p0=offset+0;
      p1=offset+i;
      at=a[p1];
      a.Swap(p1,p0);
      bt=b[p1];
      b.Swap(p1,p0);
      t=0;
      while(true)
        {
         k=2*t+1;
         if(k+1>i)
            break;
         p0=offset+t;
         p1=offset+k;
         ak=a[p1];
         if(k+1<i)
           {
            ak1=a[p1+1];
            if(ak1>ak)
              {
               ak=ak1;
               p1=p1+1;
               k=k+1;
              }
           }
         if(at>=ak)
            break;
         a.Set(p1,at);
         a.Set(p0,ak);
         b.Set(p0,b[p1]);
         b.Set(p1,bt);
         t=k;
        }
     }
  }
//+------------------------------------------------------------------+
//| Sorting function optimized for integer keys and real labels, can |
//| be used to sort middle of the array                              |
//| A is sorted, and same permutations are applied to B.             |
//| NOTES: this function assumes that A[] is finite; it doesn't      |
//|        checks that condition. All other conditions (size of input|
//|        arrays, etc.) are not checked too.                        |
//+------------------------------------------------------------------+
void CTSort::TagSortMiddleI(CRowInt &a,int offset,int n)
  {
//--- Special cases
   if(n<=1)
      return;
//--- create variables
   int i=0;
   int k=0;
   int t=0;
   int tmp=0;
   int p0=0;
   int p1=0;
   int at=0;
   int ak=0;
   int ak1=0;
//--- General case, N>1: sort, update B
   for(i=2; i<=n; i++)
     {
      t=i;
      while(t!=1)
        {
         k=t/2;
         p0=offset+k-1;
         p1=offset+t-1;
         ak=a[p0];
         at=a[p1];
         if(ak>=at)
            break;
         a.Swap(p0,p1);
         t=k;
        }
     }
   for(i=n-1; i>=1; i--)
     {
      p0=offset+0;
      p1=offset+i;
      at=a[p1];
      a.Swap(p1,p0);
      t=0;
      while(true)
        {
         k=2*t+1;
         if(k+1>i)
            break;
         p0=offset+t;
         p1=offset+k;
         ak=a[p1];
         if(k+1<i)
           {
            ak1=a[p1+1];
            if(ak1>ak)
              {
               ak=ak1;
               p1=p1+1;
               k=k+1;
              }
           }
         if(at>=ak)
            break;
         a.Set(p1,at);
         a.Set(p0,ak);
         t=k;
        }
     }
  }
//+------------------------------------------------------------------+
//| Sorting function optimized for integer values (only keys, no     |
//| labels), can be used to sort middle of the array                 |
//+------------------------------------------------------------------+
void CTSort::SortMiddleI(CRowInt &a,int offset,int n)
  {
//--- Special cases
   if(n<=1)
      return;
//--- create variables
   int i=0;
   int k=0;
   int t=0;
   int tmp=0;
   int p0=0;
   int p1=0;
   int at=0;
   int ak=0;
   int ak1=0;
//--- General case, N>1: sort, update B
   for(i=2; i<=n; i++)
     {
      t=i;
      while(t!=1)
        {
         k=t/2;
         p0=offset+k-1;
         p1=offset+t-1;
         ak=a[p0];
         at=a[p1];
         if(ak>=at)
            break;
         a.Swap(p0,p1);
         t=k;
        }
     }
   for(i=n-1; i>=1; i--)
     {
      p0=offset+0;
      p1=offset+i;
      at=a[p1];
      a.Swap(p1,p0);
      t=0;
      while(true)
        {
         k=2*t+1;
         if(k+1>i)
            break;
         p0=offset+t;
         p1=offset+k;
         ak=a[p1];
         if(k+1<i)
           {
            ak1=a[p1+1];
            if(ak1>ak)
              {
               ak=ak1;
               p1=p1+1;
               k=k+1;
              }
           }
         if(at>=ak)
            break;
         a.Set(p1,at);
         a.Set(p0,ak);
         t=k;
        }
     }
  }
//+------------------------------------------------------------------+
//| Heap operations: adds element to the heap                        |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N]        |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap (without new element).          |
//|                 updated on output                                |
//|     VA      -   value of the element being added                 |
//|     VB      -   value of the tag                                 |
//+------------------------------------------------------------------+
void CTSort::TagHeapPushI(double &a[],int &b[],int &n,const double va,
                          const int vb)
  {
//--- check
   if(n<0)
      return;
//--- create variables
   int    j=0;
   int    k=0;
   double v=0;
//--- N=0 is a special case
   if(n==0)
     {
      a[0]=va;
      b[0]=vb;
      n=n+1;
      //--- exit the function
      return;
     }
//--- add current point to the heap
//--- (add to the bottom, then move up)
//--- we don't write point to the heap
//--- until its final position is determined
//--- (it allow us to reduce number of array access operations)
   j=n;
   n=n+1;
   while(j>0)
     {
      k=(j-1)/2;
      v=a[k];
      //--- check
      if(v<va)
        {
         //--- swap with higher element
         a[j]=v;
         b[j]=b[k];
         j=k;
        }
      else
        {
         //--- element in its place. terminate.
         break;
        }
     }
//--- change values
   a[j]=va;
   b[j]=vb;
  }
//+------------------------------------------------------------------+
//| Heap operations: adds element to the heap                        |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N]        |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap (without new element).          |
//|                 updated on output                                |
//|     VA      -   value of the element being added                 |
//|     VB      -   value of the tag                                 |
//+------------------------------------------------------------------+
void CTSort::TagHeapPushI(CRowDouble &a,CRowInt &b,int &n,const double va,
                          const int vb)
  {
//--- create variables
   int    j=0;
   int    k=0;
   double v=0;
//--- check
   if(n<0)
      return;
//--- N=0 is a special case
   if(n==0)
     {
      a.Set(0,va);
      b.Set(0,vb);
      n=n+1;
      //--- exit the function
      return;
     }
//--- add current point to the heap
//--- (add to the bottom, then move up)
//--- we don't write point to the heap
//--- until its final position is determined
//--- (it allow us to reduce number of array access operations)
   j=n;
   n=n+1;
   while(j>0)
     {
      k=(j-1)/2;
      v=a[k];
      //--- check
      if(v<va)
        {
         //--- swap with higher element
         a.Set(j,v);
         b.Set(j,b[k]);
         j=k;
        }
      else
        {
         //--- element in its place. terminate.
         break;
        }
     }
//--- change values
   a.Set(j,va);
   b.Set(j,vb);
  }
//+------------------------------------------------------------------+
//| Heap operations: replaces top element with new element           |
//| (which is moved down)                                            |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N-1]      |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap                                 |
//|     VA      -   value of the element which replaces top element  |
//|     VB      -   value of the tag                                 |
//+------------------------------------------------------------------+
void CTSort::TagHeapReplaceTopI(double &a[],int &b[],const int n,
                                const double va,const int vb)
  {
//--- create variables
   int    j=0;
   int    k1=0;
   int    k2=0;
   double v=0;
   double v1=0;
   double v2=0;
//--- check
   if(n<1)
      return;
//--- N=1 is a special case
   if(n==1)
     {
      a[0]=va;
      b[0]=vb;
      //--- exit the function
      return;
     }
//--- move down through heap:
//--- * J  -   current element
//--- * K1 -   first child (always exists)
//--- * K2 -   second child (may not exists)
//--- we don't write point to the heap
//--- until its final position is determined
//--- (it allow us to reduce number of array access operations)
   j=0;
   k1=1;
   k2=2;
   while(k1<n)
     {
      //--- check
      if(k2>=n)
        {
         //--- only one child.
         //--- swap and terminate (because this child
         //--- have no siblings due to heap structure)
         v=a[k1];
         //--- check
         if(v>va)
           {
            a[j]=v;
            b[j]=b[k1];
            j=k1;
           }
         break;
        }
      else
        {
         //--- two childs
         v1=a[k1];
         v2=a[k2];
         //--- check
         if(v1>v2)
           {
            //--- check
            if(va<v1)
              {
               a[j]=v1;
               b[j]=b[k1];
               j=k1;
              }
            else
               break;
           }
         else
           {
            //--- check
            if(va<v2)
              {
               a[j]=v2;
               b[j]=b[k2];
               j=k2;
              }
            else
               break;
           }
         //--- change values
         k1=2*j+1;
         k2=2*j+2;
        }
     }
//--- change values
   a[j]=va;
   b[j]=vb;
  }
//+------------------------------------------------------------------+
//| Heap operations: replaces top element with new element           |
//| (which is moved down)                                            |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N-1]      |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap                                 |
//|     VA      -   value of the element which replaces top element  |
//|     VB      -   value of the tag                                 |
//+------------------------------------------------------------------+
void CTSort::TagHeapReplaceTopI(CRowDouble &a,CRowInt &b,const int n,
                                const double va,const int vb)
  {
//--- create variables
   int    j=0;
   int    k1=0;
   int    k2=0;
   double v=0;
   double v1=0;
   double v2=0;
//--- check
   if(n<1)
      return;
//--- N=1 is a special case
   if(n==1)
     {
      a.Set(0,va);
      b.Set(0,vb);
      //--- exit the function
      return;
     }
//--- move down through heap:
//--- * J  -   current element
//--- * K1 -   first child (always exists)
//--- * K2 -   second child (may not exists)
//--- we don't write point to the heap
//--- until its final position is determined
//--- (it allow us to reduce number of array access operations)
   j=0;
   k1=1;
   k2=2;
   while(k1<n)
     {
      //--- check
      if(k2>=n)
        {
         //--- only one child.
         //--- swap and terminate (because this child
         //--- have no siblings due to heap structure)
         v=a[k1];
         //--- check
         if(v>va)
           {
            a.Set(j,v);
            b.Set(j,b[k1]);
            j=k1;
           }
         break;
        }
      else
        {
         //--- two childs
         v1=a[k1];
         v2=a[k2];
         //--- check
         if(v1>v2)
           {
            //--- check
            if(va<v1)
              {
               a.Set(j,v1);
               b.Set(j,b[k1]);
               j=k1;
              }
            else
               break;
           }
         else
           {
            //--- check
            if(va<v2)
              {
               a.Set(j,v2);
               b.Set(j,b[k2]);
               j=k2;
              }
            else
               break;
           }
         //--- change values
         k1=2*j+1;
         k2=2*j+2;
        }
     }
//--- change values
   a.Set(j,va);
   b.Set(j,vb);
  }
//+------------------------------------------------------------------+
//| Heap operations: pops top element from the heap                  |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N-1]      |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap, N>=1                           |
//| On output top element is moved to A[N-1], B[N-1], heap is        |
//| reordered, N is decreased by 1.                                  |
//+------------------------------------------------------------------+
void CTSort::TagHeapPopI(double &a[],int &b[],int &n)
  {
//--- create variables
   double va=0;
   int    vb=0;
//--- check
   if(n<1)
      return;
//--- N=1 is a special case
   if(n==1)
     {
      n=0;
      return;
     }
//--- swap top element and last element,
//--- then reorder heap
   va=a[n-1];
   vb=b[n-1];
   a[n-1]=a[0];
   b[n-1]=b[0];
   n=n-1;
//--- function call
   TagHeapReplaceTopI(a,b,n,va,vb);
  }
//+------------------------------------------------------------------+
//| Heap operations: pops top element from the heap                  |
//| PARAMETERS:                                                      |
//|     A       -   heap itself, must be at least array[0..N-1]      |
//|     B       -   array of integer tags, which are updated         |
//|                 according to permutations in the heap            |
//|     N       -   size of the heap, N>=1                           |
//| On output top element is moved to A[N-1], B[N-1], heap is        |
//| reordered, N is decreased by 1.                                  |
//+------------------------------------------------------------------+
void CTSort::TagHeapPopI(CRowDouble &a,CRowInt &b,int &n)
  {
//--- create variables
   double va=0;
   int    vb=0;
//--- check
   if(n<1)
      return;
//--- N=1 is a special case
   if(n==1)
     {
      n=0;
      return;
     }
//--- swap top element and last element,
//--- then reorder heap
   va=a[n-1];
   vb=b[n-1];
   a.Set(n-1,a[0]);
   b.Set(n-1,b[0]);
   n=n-1;
//--- function call
   TagHeapReplaceTopI(a,b,n,va,vb);
  }
//+------------------------------------------------------------------+
//| Search first element less than T in sorted array.                |
//| PARAMETERS:                                                      |
//|   A        -  sorted array by ascending from 0 to N-1            |
//|   N        -  number of elements in array                        |
//|   T        -  the desired element                                |
//| RESULT:                                                          |
//|   The very first element's index, which isn't less than T. In    |
//|   the case when there aren't such elements, returns N.           |
//+------------------------------------------------------------------+
int CTSort::LowerBound(CRowDouble &a,int n,double t)
  {
//--- create variables
   int l=n;
   int half=0;
   int first=0;
   int middle=0;

   while(l>0)
     {
      half=l/2;
      middle=first+half;
      if(a[middle]<t)
        {
         first=middle+1;
         l-=half+1;
        }
      else
         l=half;
     }
//--- return result
   return(first);
  }
//+------------------------------------------------------------------+
//| Search first element more than T in sorted array.                |
//| PARAMETERS:                                                      |
//|   A        -  sorted array by ascending from 0 to N-1            |
//|   N        -  number of elements in array                        |
//|   T        -  the desired element                                |
//| RESULT:                                                          |
//|   The very first element's index, which more than T. In the case |
//|   when there aren't such elements, returns N.                    |
//+------------------------------------------------------------------+
int CTSort::UpperBound(CRowDouble &a,int n,double t)
  {
//--- create variables
   int l=n;
   int half=0;
   int first=0;
   int middle=0;

   while(l>0)
     {
      half=l/2;
      middle=first+half;
      if(t<a[middle])
         l=half;
      else
        {
         first=middle+1;
         l-=half+1;
        }
     }
//--- return result
   return(first);
  }
//+------------------------------------------------------------------+
//| Internal TagSortFastI: sorts A[I1...I2] (both bounds are         |
//| included), applies same permutations to B.                       |
//+------------------------------------------------------------------+
void CTSort::TagSortFastIRec(double &a[],int &b[],double &bufa[],
                             int &bufb[],const int i1,const int i2)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   int    cntless=0;
   int    cnteq=0;
   int    cntgreater=0;
   double tmpr=0;
   int    tmpi=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double vp=0;
//--- Fast exit
   if(i2<=i1)
      return;
//--- Non-recursive sort for small arrays
   if(i2-i1<=16)
     {
      for(j=i1+1; j<=i2; j++)
        {
         //--- Search elements [I1..J-1] for place to insert Jth element.
         //--- This code stops immediately if we can leave A[J] at J-th position
         //--- (all elements have same value of A[J] larger than any of them)
         tmpr=a[j];
         tmpi=j;
         for(k=j-1; k>=i1; k--)
           {
            //--- check
            if(a[k]<=tmpr)
               break;
            tmpi=k;
           }
         k=tmpi;
         //--- Insert Jth element into Kth position
         if(k!=j)
           {
            //--- change values
            tmpr=a[j];
            tmpi=b[j];
            for(i=j-1; i>=k; i--)
              {
               a[i+1]=a[i];
               b[i+1]=b[i];
              }
            a[k]=tmpr;
            b[k]=tmpi;
           }
        }
      //--- exit the function
      return;
     }
//--- Quicksort: choose pivot
//--- Here we assume that I2-I1>=2
   v0=a[i1];
   v1=a[i1+(i2-i1)/2];
   v2=a[i2];
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
//--- check
   if(v1>v2)
     {
      tmpr=v2;
      v2=v1;
      v1=tmpr;
     }
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
   vp=v1;
//--- now pass through A/B and:
//--- * move elements that are LESS than VP to the left of A/B
//--- * move elements that are EQUAL to VP to the right of BufA/BufB (in the reverse order)
//--- * move elements that are GREATER than VP to the left of BufA/BufB (in the normal order
//--- * move elements from the tail of BufA/BufB to the middle of A/B (restoring normal order)
//--- * move elements from the left of BufA/BufB to the end of A/B
   cntless=0;
   cnteq=0;
   cntgreater=0;
   for(i=i1; i<=i2; i++)
     {
      v0=a[i];
      //--- check
      if(v0<vp)
        {
         //--- LESS
         k=i1+cntless;
         //--- check
         if(i!=k)
           {
            a[k]=v0;
            b[k]=b[i];
           }
         cntless++;
         continue;
        }
      //--- check
      if(v0==vp)
        {
         //--- EQUAL
         k=i2-cnteq;
         bufa[k]=v0;
         bufb[k]=b[i];
         cnteq++;
         continue;
        }
      //--- GREATER
      k=i1+cntgreater;
      bufa[k]=v0;
      bufb[k]=b[i];
      cntgreater++;
     }
//--- change values
   for(i=0; i<=cnteq-1; i++)
     {
      j=i1+cntless+cnteq-1-i;
      k=i2+i-(cnteq-1);
      a[j]=bufa[k];
      b[j]=bufb[k];
     }
//--- change values
   for(i=0; i<=cntgreater-1; i++)
     {
      j=i1+cntless+cnteq+i;
      k=i1+i;
      a[j]=bufa[k];
      b[j]=bufb[k];
     }
//--- Sort left and right parts of the array (ignoring middle part)
   TagSortFastIRec(a,b,bufa,bufb,i1,i1+cntless-1);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,i1+cntless+cnteq,i2);
  }
//+------------------------------------------------------------------+
//| Internal TagSortFastI: sorts A[I1...I2] (both bounds are         |
//| included), applies same permutations to B.                       |
//+------------------------------------------------------------------+
void CTSort::TagSortFastIRec(double &a[],int &b[],CRowDouble &bufa,
                             CRowInt &bufb,const int i1,const int i2)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   int    cntless=0;
   int    cnteq=0;
   int    cntgreater=0;
   double tmpr=0;
   int    tmpi=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double vp=0;
//--- Fast exit
   if(i2<=i1)
      return;
//--- Non-recursive sort for small arrays
   if(i2-i1<=16)
     {
      for(j=i1+1; j<=i2; j++)
        {
         //--- Search elements [I1..J-1] for place to insert Jth element.
         //--- This code stops immediately if we can leave A[J] at J-th position
         //--- (all elements have same value of A[J] larger than any of them)
         tmpr=a[j];
         tmpi=j;
         for(k=j-1; k>=i1; k--)
           {
            //--- check
            if(a[k]<=tmpr)
               break;
            tmpi=k;
           }
         k=tmpi;
         //--- Insert Jth element into Kth position
         if(k!=j)
           {
            //--- change values
            tmpr=a[j];
            tmpi=b[j];
            for(i=j-1; i>=k; i--)
              {
               a[i+1]=a[i];
               b[i+1]=b[i];
              }
            a[k]=tmpr;
            b[k]=tmpi;
           }
        }
      //--- exit the function
      return;
     }
//--- Quicksort: choose pivot
//--- Here we assume that I2-I1>=2
   v0=a[i1];
   v1=a[i1+(i2-i1)/2];
   v2=a[i2];
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
//--- check
   if(v1>v2)
     {
      tmpr=v2;
      v2=v1;
      v1=tmpr;
     }
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
   vp=v1;
//--- now pass through A/B and:
//--- * move elements that are LESS than VP to the left of A/B
//--- * move elements that are EQUAL to VP to the right of BufA/BufB (in the reverse order)
//--- * move elements that are GREATER than VP to the left of BufA/BufB (in the normal order
//--- * move elements from the tail of BufA/BufB to the middle of A/B (restoring normal order)
//--- * move elements from the left of BufA/BufB to the end of A/B
   cntless=0;
   cnteq=0;
   cntgreater=0;
   for(i=i1; i<=i2; i++)
     {
      v0=a[i];
      //--- check
      if(v0<vp)
        {
         //--- LESS
         k=i1+cntless;
         //--- check
         if(i!=k)
           {
            a[k]=v0;
            b[k]=b[i];
           }
         cntless=cntless+1;
         continue;
        }
      //--- check
      if(v0==vp)
        {
         //--- EQUAL
         k=i2-cnteq;
         bufa.Set(k,v0);
         bufb.Set(k,b[i]);
         cnteq=cnteq+1;
         continue;
        }
      //--- GREATER
      k=i1+cntgreater;
      bufa.Set(k,v0);
      bufb.Set(k,b[i]);
      cntgreater=cntgreater+1;
     }
//--- change values
   for(i=0; i<=cnteq-1; i++)
     {
      j=i1+cntless+cnteq-1-i;
      k=i2+i-(cnteq-1);
      a[j]=bufa[k];
      b[j]=bufb[k];
     }
//--- change values
   for(i=0; i<=cntgreater-1; i++)
     {
      j=i1+cntless+cnteq+i;
      k=i1+i;
      a[j]=bufa[k];
      b[j]=bufb[k];
     }
//--- Sort left and right parts of the array (ignoring middle part)
   TagSortFastIRec(a,b,bufa,bufb,i1,i1+cntless-1);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,i1+cntless+cnteq,i2);
  }
//+------------------------------------------------------------------+
//| Internal TagSortFastI: sorts A[I1...I2] (both bounds are         |
//| included), applies same permutations to B.                       |
//+------------------------------------------------------------------+
void CTSort::TagSortFastIRec(CRowDouble &a,CRowInt &b,CRowDouble &bufa,
                             CRowInt &bufb,const int i1,const int i2)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   int    cntless=0;
   int    cnteq=0;
   int    cntgreater=0;
   double tmpr=0;
   int    tmpi=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double vp=0;
//--- Fast exit
   if(i2<=i1)
      return;
//--- Non-recursive sort for small arrays
   if(i2-i1<=16)
     {
      for(j=i1+1; j<=i2; j++)
        {
         //--- Search elements [I1..J-1] for place to insert Jth element.
         //--- This code stops immediately if we can leave A[J] at J-th position
         //--- (all elements have same value of A[J] larger than any of them)
         tmpr=a[j];
         tmpi=j;
         for(k=j-1; k>=i1; k--)
           {
            //--- check
            if(a[k]<=tmpr)
               break;
            tmpi=k;
           }
         k=tmpi;
         //--- Insert Jth element into Kth position
         if(k!=j)
           {
            //--- change values
            tmpr=a[j];
            tmpi=b[j];
            for(i=j-1; i>=k; i--)
              {
               a.Set(i+1,a[i]);
               b.Set(i+1,b[i]);
              }
            a.Set(k,tmpr);
            b.Set(k,tmpi);
           }
        }
      //--- exit the function
      return;
     }
//--- Quicksort: choose pivot
//--- Here we assume that I2-I1>=2
   v0=a[i1];
   v1=a[i1+(i2-i1)/2];
   v2=a[i2];
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
//--- check
   if(v1>v2)
     {
      tmpr=v2;
      v2=v1;
      v1=tmpr;
     }
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
   vp=v1;
//--- now pass through A/B and:
//--- * move elements that are LESS than VP to the left of A/B
//--- * move elements that are EQUAL to VP to the right of BufA/BufB (in the reverse order)
//--- * move elements that are GREATER than VP to the left of BufA/BufB (in the normal order
//--- * move elements from the tail of BufA/BufB to the middle of A/B (restoring normal order)
//--- * move elements from the left of BufA/BufB to the end of A/B
   cntless=0;
   cnteq=0;
   cntgreater=0;
   for(i=i1; i<=i2; i++)
     {
      v0=a[i];
      //--- check
      if(v0<vp)
        {
         //--- LESS
         k=i1+cntless;
         //--- check
         if(i!=k)
           {
            a.Set(k,v0);
            b.Set(k,b[i]);
           }
         cntless=cntless+1;
         continue;
        }
      //--- check
      if(v0==vp)
        {
         //--- EQUAL
         k=i2-cnteq;
         bufa.Set(k,v0);
         bufb.Set(k,b[i]);
         cnteq=cnteq+1;
         continue;
        }
      //--- GREATER
      k=i1+cntgreater;
      bufa.Set(k,v0);
      bufb.Set(k,b[i]);
      cntgreater=cntgreater+1;
     }
//--- change values
   for(i=0; i<=cnteq-1; i++)
     {
      j=i1+cntless+cnteq-1-i;
      k=i2+i-(cnteq-1);
      a.Set(j,bufa[k]);
      b.Set(j,bufb[k]);
     }
//--- change values
   for(i=0; i<=cntgreater-1; i++)
     {
      j=i1+cntless+cnteq+i;
      k=i1+i;
      a.Set(j,bufa[k]);
      b.Set(j,bufb[k]);
     }
//--- Sort left and right parts of the array (ignoring middle part)
   TagSortFastIRec(a,b,bufa,bufb,i1,i1+cntless-1);
//--- function call
   TagSortFastIRec(a,b,bufa,bufb,i1+cntless+cnteq,i2);
  }
//+------------------------------------------------------------------+
//| Internal TagSortFastR: sorts A[I1...I2] (both bounds are         |
//| included), applies same permutations to B.                       |
//+------------------------------------------------------------------+
void CTSort::TagSortFastRRec(CRowDouble &a,CRowDouble &b,CRowDouble &bufa,
                             CRowDouble &bufb,const int i1,const int i2)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   double tmpr=0;
   double tmpr2=0;
   int    tmpi=0;
   int    cntless=0;
   int    cnteq=0;
   int    cntgreater=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double vp=0;
//--- Fast exit
   if(i2<=i1)
      return;
//--- Non-recursive sort for small arrays
   if(i2-i1<=16)
     {
      for(j=i1+1; j<=i2; j++)
        {
         //--- Search elements [I1..J-1] for place to insert Jth element.
         //--- This code stops immediatly if we can leave A[J] at J-th position
         //--- (all elements have same value of A[J] larger than any of them)
         tmpr=a[j];
         tmpi=j;
         for(k=j-1; k>=i1; k--)
           {
            //--- check
            if(a[k]<=tmpr)
               break;
            tmpi=k;
           }
         k=tmpi;
         //--- Insert Jth element into Kth position
         if(k!=j)
           {
            //--- change values
            tmpr=a[j];
            tmpr2=b[j];
            for(i=j-1; i>=k; i--)
              {
               a.Set(i+1,a[i]);
               b.Set(i+1,b[i]);
              }
            a.Set(k,tmpr);
            b.Set(k,tmpr2);
           }
        }
      //--- exit the function
      return;
     }
//--- Quicksort: choose pivot
//--- Here we assume that I2-I1>=16
   v0=a[i1];
   v1=a[i1+(i2-i1)/2];
   v2=a[i2];
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
//--- check
   if(v1>v2)
     {
      tmpr=v2;
      v2=v1;
      v1=tmpr;
     }
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
   vp=v1;
//--- now pass through A/B and:
//--- * move elements that are LESS than VP to the left of A/B
//--- * move elements that are EQUAL to VP to the right of BufA/BufB (in the reverse order)
//--- * move elements that are GREATER than VP to the left of BufA/BufB (in the normal order
//--- * move elements from the tail of BufA/BufB to the middle of A/B (restoring normal order)
//--- * move elements from the left of BufA/BufB to the end of A/B
   cntless=0;
   cnteq=0;
   cntgreater=0;
   for(i=i1; i<=i2; i++)
     {
      v0=a[i];
      //--- check
      if(v0<vp)
        {
         //--- LESS
         k=i1+cntless;
         //--- check
         if(i!=k)
           {
            a.Set(k,v0);
            b.Set(k,b[i]);
           }
         cntless++;
         continue;
        }
      //--- check
      if(v0==vp)
        {
         //--- EQUAL
         k=i2-cnteq;
         bufa.Set(k,v0);
         bufb.Set(k,b[i]);
         cnteq++;
         continue;
        }
      //--- GREATER
      k=i1+cntgreater;
      bufa.Set(k,v0);
      bufb.Set(k,b[i]);
      cntgreater++;
     }
//--- change values
   for(i=0; i<=cnteq-1; i++)
     {
      j=i1+cntless+cnteq-1-i;
      k=i2+i-(cnteq-1);
      a.Set(j,bufa[k]);
      b.Set(j,bufb[k]);
     }
//--- change values
   for(i=0; i<=cntgreater-1; i++)
     {
      j=i1+cntless+cnteq+i;
      k=i1+i;
      a.Set(j,bufa[k]);
      b.Set(j,bufb[k]);
     }
//--- Sort left and right parts of the array (ignoring middle part)
   TagSortFastRRec(a,b,bufa,bufb,i1,i1+cntless-1);
//--- function call
   TagSortFastRRec(a,b,bufa,bufb,i1+cntless+cnteq,i2);
  }
//+------------------------------------------------------------------+
//| Internal TagSortFastI: sorts A[I1...I2] (both bounds are         |
//| included), applies same permutations to B.                       |
//+------------------------------------------------------------------+
void CTSort::TagSortFastRec(CRowDouble &a,CRowDouble &bufa,
                            const int i1,const int i2)
  {
//--- check
   if(i2<=i1)
      return;
//--- create variables
   int    cntLess=0;
   int    cntEq=0;
   int    cntGreat=0;
   int    i=0;
   int    j=0;
   int    k=0;
   double tmpr=0;
   int    tmpi=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double vp=0;
//--- Non-recursive sort for small arrays
   if(i2-i1<=16)
     {
      for(j=i1+1; j<=i2; j++)
        {
         //--- Search elements [I1..J-1] for place to insert Jth element.
         //--- This code stops immediatly if we can leave A[J] at J-th position
         //--- (all elements have same value of A[J] larger than any of them)
         tmpr=a[j];
         tmpi=j;
         for(k=j-1; k>=i1; k--)
           {
            //--- check
            if(a[k]<=tmpr)
               break;
            tmpi=k;
           }
         k=tmpi;
         //--- Insert Jth element into Kth position
         if(k!=j)
           {
            tmpr=a[j];
            for(i=j-1; i>=k; i--)
               a.Set(i+1,a[i]);
            a.Set(k,tmpr);
           }
        }
      return;
     }
//--- Quicksort: choose pivot
//--- Here we assume that I2-I1>=16
   v0=a[i1];
   v1=a[i1+(i2-i1)/2];
   v2=a[i2];
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
//--- check
   if(v1>v2)
     {
      tmpr=v2;
      v2=v1;
      v1=tmpr;
     }
//--- check
   if(v0>v1)
     {
      tmpr=v1;
      v1=v0;
      v0=tmpr;
     }
   vp=v1;
//--- now pass through A/B and:
//--- * move elements that are LESS than VP to the left of A/B
//--- * move elements that are EQUAL to VP to the right of BufA/BufB (in the reverse order)
//--- * move elements that are GREATER than VP to the left of BufA/BufB (in the normal order
//--- * move elements from the tail of BufA/BufB to the middle of A/B (restoring normal order)
//--- * move elements from the left of BufA/BufB to the end of A/B
   for(i=i1; i<=i2; i++)
     {
      v0=a[i];
      //--- check
      if(v0<vp)
        {
         //--- LESS
         k=i1+cntLess;
         if(i!=k)
            a.Set(k,v0);
         cntLess++;
         continue;
        }
      //--- check
      if(v0==vp)
        {
         //--- EQUAL
         k=i2-cntEq;
         bufa.Set(k,v0);
         cntEq++;
         continue;
        }
      //--- GREATER
      k=i1+cntGreat;
      bufa.Set(k,v0);
      cntGreat++;
     }
//--- change values
   for(i=0; i<cntEq; i++)
     {
      j=i1+cntLess+cntEq-1-i;
      k=i2+i-(cntEq-1);
      a.Set(j,bufa[k]);
     }
   for(i=0; i<cntGreat; i++)
     {
      j=i1+cntLess+cntEq+i;
      k=i1+i;
      a.Set(j,bufa[k]);
     }
//--- Sort left and right parts of the array (ignoring middle part)
   TagSortFastRec(a,bufa,i1,i1+cntLess-1);
   TagSortFastRec(a,bufa,i1+cntLess+cntEq,i2);
  }
//+------------------------------------------------------------------+
//| Calculation of basic statistical properties                      |
//+------------------------------------------------------------------+
class CBasicStatOps
  {
public:
   static void       RankX(CRowDouble &x,const int n,bool IsCentered,CApBuff &buf);
   static void       RankXUntied(CRowDouble &x,int n,CApBuff &buf);
  };
//+------------------------------------------------------------------+
//| Internal tied ranking subroutine.                                |
//| INPUT PARAMETERS:                                                |
//|   X        -  array to rank                                      |
//|   N        -  array size                                         |
//|   IsCentered- whether ranks are centered or not:                 |
//|               * True - ranks are centered in such way that their |
//|                        sum is zero                               |
//|               * False - ranks are not centered                   |
//|   Buf      -  temporary buffers                                  |
//| NOTE: when IsCentered is True and all X[] are equal, this        |
//|       function fills X by zeros (exact zeros are used, not sum   |
//|       which is only approximately equal to zero).                |
//+------------------------------------------------------------------+
void CBasicStatOps::RankX(CRowDouble &x,const int n,
                          bool IsCentered,CApBuff &buf)
  {
//--- Prepare
   if(n<1)
      return;
//--- check
   if(n==1)
     {
      x.Set(0,1);
      return;
     }
//--- create variables
   int    i;
   int    j;
   int    k;
   double tmp=0;
   double voffs=0;
//--- check
   if((int)buf.m_ra1.Size()<n)
      buf.m_ra1.Resize(n);
//--- check
   if((int)buf.m_ia1.Size()<n)
      buf.m_ia1.Resize(n);
//--- copy
   for(i=0; i<n; i++)
     {
      buf.m_ra1.Set(i,x[i]);
      buf.m_ia1.Set(i,i);
     }
   CTSort::TagSortFastI(buf.m_ra1,buf.m_ia1,buf.m_ra2,buf.m_ia2,n);
//--- Special test for all values being equal
   if(buf.m_ra1[0]==buf.m_ra1[n-1])
     {
      if(IsCentered)
         tmp=0.0;
      else
         tmp=(double)(n-1)/(2.0);
      for(i=0; i<n; i++)
         x.Set(i,tmp);
      return;
     }
//--- compute tied ranks
   i=0;
   while(i<n)
     {
      for(j=i+1; j<n; j++)
         if(buf.m_ra1[j]!=buf.m_ra1[i])
            break;
      for(k=i; k<j; k++)
         buf.m_ra1.Set(k,(double)(i+j-1)/2.0);
      i=j;
     }
//--- back to x
   if(IsCentered)
      voffs=(double)(n-1)/2.0;
   else
      voffs=0.0;
   for(i=0; i<n; i++)
      x.Set(buf.m_ia1[i],buf.m_ra1[i]-voffs);
  }
//+------------------------------------------------------------------+
//| Internal untied ranking subroutine.                              |
//| INPUT PARAMETERS:                                                |
//|   X        -  array to rank                                      |
//|   N        -  array size                                         |
//|   Buf      -  temporary buffers                                  |
//| Returns untied ranks (in case of a tie ranks are resolved        |
//| arbitrarily).                                                    |
//+------------------------------------------------------------------+
void CBasicStatOps::RankXUntied(CRowDouble &x,int n,CApBuff &buf)
  {
//--- Prepare
   if(n<1)
      return;

   if(n==1)
     {
      x.Set(0,0);
      return;
     }
   if(CAp::Len(buf.m_ra1)<n)
      buf.m_ra1.Resize(n);
   if(CAp::Len(buf.m_ia1)<n)
      buf.m_ia1.Resize(n);
   for(int i=0; i<n; i++)
     {
      buf.m_ra1.Set(i,x[i]);
      buf.m_ia1.Set(i,i);
     }
   CTSort::TagSortFastI(buf.m_ra1,buf.m_ia1,buf.m_ra2,buf.m_ia2,n);
   for(int i=0; i<n; i++)
      x.Set(buf.m_ia1[i],i);
  }
//+------------------------------------------------------------------+
//| Class includes templates for future functions                    |
//+------------------------------------------------------------------+
class CAblasF
  {
public:
   static void       RAddVC(int n,double alpha,CRowDouble &y,CMatrixDouble &x,int colidx);
   static void       RSetAllocV(int n,double v,CRowDouble &x);
   static void       RSetAllocM(int m,int n,double v,CMatrixDouble &a);
   static void       RAllocV(int n,CRowDouble &x);
   static void       IAllocV(int n,CRowInt &x);
   static void       BAllocV(int n,bool &x[]);
   static void       RAllocM(int m,int n,CMatrixDouble &a);
   static void       ISetAllocV(int n,int v,CRowInt &x);
   static void       BSetAllocV(int n,bool v,bool &x[]);
   static void       RSetC(int n,double v,CMatrixDouble &a,int j);
   static void       RCopyAllocV(int n,CRowDouble &x,CRowDouble &y);
   static void       RCopyM(int m,int n,CMatrixDouble &x,CMatrixDouble &y);
   static void       RCopyAllocM(int m,int n,CMatrixDouble &x,CMatrixDouble &y);
   static void       ICopyAllocV(int n,CRowInt &x,CRowInt &y);
   static void       BCopyAllocV(int n,bool &x[],bool &y[]);
   static void       IGrowV(int newn,CRowInt &x);
   static void       RGrowV(int newn,CRowDouble &x);
   static void       RCopyMulVC(int n,double v,CRowDouble &x,CMatrixDouble &y,int cidx);
   static void       RCopyVC(int n,CRowDouble &x,CMatrixDouble &a,int j);
   static void       RCopyCV(int n,CMatrixDouble &a,int j,CRowDouble &x);
   static void       CMatrixGemmK(int m,int n,int k,complex alpha,const CMatrixComplex &a,int ia,int ja,int optypea,const CMatrixComplex &b,int ib,int jb,int optypeb,complex beta,CMatrixComplex &c,int ic,int jc);
   static void       RMatrixGemmK(int m,int n,int k,double alpha,const CMatrixDouble &a,int ia,int ja,int optypea,const CMatrixDouble &b,int ib,int jb,int optypeb,double beta,CMatrixDouble &c,int ic,int jc);
   static void       RMatrixGemmK44v00(int m,int n,int k,double alpha,const CMatrixDouble &a,int ia,int ja,const CMatrixDouble &b,int ib,int jb,double beta,CMatrixDouble &c,int ic,int jc);
   static void       RMatrixGemmK44v01(int m,int n,int k,double alpha,const CMatrixDouble &a,int ia,int ja,const CMatrixDouble &b,int ib,int jb,double beta,CMatrixDouble &c,int ic,int jc);
   static void       RMatrixGemmK44v10(int m,int n,int k,double alpha,const CMatrixDouble &a,int ia,int ja,const CMatrixDouble &b,int ib,int jb,double beta,CMatrixDouble &c,int ic,int jc);
   static void       RMatrixGemmK44v11(int m,int n,int k,double alpha,const CMatrixDouble &a,int ia,int ja,const CMatrixDouble &b,int ib,int jb,double beta,CMatrixDouble &c,int ic,int jc);
   //---
   static double     RDotV(int n,CRowDouble &x,CRowDouble &y);
   static double     RDotVR(int n,CRowDouble &x,CMatrixDouble &a,int i);
   static double     RDotVC(int n,CRowDouble &x,CMatrixDouble &a,int i);
   static double     RDotRR(int n,CMatrixDouble &a,int ia,CMatrixDouble &b,int ib);
   static double     RDotV2(int n,CRowDouble &x);
   static void       RAddV(int n,double alpha,CRowDouble &y,CRowDouble &x);
   static void       RAddVX(int n,double alpha,CRowDouble &y,int offsy,CRowDouble &x,int offsx);
   static void       RAddVR(int n,double alpha,CRowDouble &y,CMatrixDouble &x,int rowidx);
   static void       RAddRV(int n,double alpha,CMatrixDouble &y,int ridx,CRowDouble &x);
   static void       RAddRR(int n,double alpha,CMatrixDouble &y,int ridxsrc,CMatrixDouble &x,int ridxdst);
   static void       RMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x);
   static void       RMulV(int n,double v,CRowDouble &x);
   static void       RMulR(int n,double v,CMatrixDouble &x,int rowidx);
   static void       RMulVX(int n,double v,CRowDouble &x,int offsx);
   static void       RNegMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x);
   static void       RMergeMulV(int n,CRowDouble &y,CRowDouble &x);
   static void       RMergeMulVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx);
   static void       RMergeMulRV(int n,CMatrixDouble &y,int rowidy,CRowDouble &x);
   static void       RMergeDivV(int n,CRowDouble &y,CRowDouble &x);
   static void       RMergeDivVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx);
   static void       RMergeDivRV(int n,CMatrixDouble &y,int rowidy,CRowDouble &x);
   static void       RMergeMaxV(int n,CRowDouble &y,CRowDouble &x);
   static void       RMergeMaxVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx);
   static void       RMergeMaxRV(int n,CMatrixDouble &x,int rowidx,CRowDouble &y);
   static void       RMergeMinV(int n,CRowDouble &y,CRowDouble &x);
   static void       RMergeMinVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx);
   static void       RMergeMinRV(int n,CMatrixDouble &x,int rowidx,CRowDouble &y);
   static void       RSqrtV(int n,CRowDouble &x);
   static void       RSqrtR(int n,CMatrixDouble &x,int rowidx);
   static double     RMaxV(int n,CRowDouble &x);
   static double     RMaxAbsV(int n,CRowDouble &x);
   static double     RMaxR(int n,CMatrixDouble &x,int rowidx);
   static double     RMaxAbsR(int n,CMatrixDouble &x,int rowidx);
   static void       RSetV(int n,double v,CRowDouble &x);
   static void       RSetVX(int n,double v,CRowDouble &x,int offsx);
   static void       ISetV(int n,int v,CRowInt &x);
   static void       BSetV(int n,bool v,bool &x[]);
   static void       RSetM(int m,int n,double v,CMatrixDouble &a);
   static void       RSetR(int n,double v,CMatrixDouble &a,int i);
   //--- copy
   static void       BCopyV(int n,bool &x[],bool &y[]);
   static void       RCopyV(int n,CRowDouble &x,CRowDouble &y);
   static void       RCopyVX(int n,CRowDouble &x,int offsx,CRowDouble &y,int offsy);
   static void       RCopyVR(int n,CRowDouble &x,CMatrixDouble &a,int i);
   static void       RCopyRV(int n,CMatrixDouble &a,int i,CRowDouble &x);
   static void       RCopyRR(int n,CMatrixDouble &a,int i,CMatrixDouble &b,int k);
   static void       RCopyMulV(int n,double v,CRowDouble &x,CRowDouble &y);
   static void       RCopyMulVR(int n,double v,CRowDouble &x,CMatrixDouble &y,int ridx);
   static void       RCopyMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x,CRowDouble &r);
   static void       RCopyNegMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x,CRowDouble &r);
   static void       ICopyV(int n,CRowInt &x,CRowInt &y);
   static void       ICopyVX(int n,CRowInt &x,int offsx,CRowInt &y,int offsy);
   //---
   static void       RGemV(int m,int n,double alpha,CMatrixDouble &a,int opa,CRowDouble &x,double beta,CRowDouble &y);
   static void       RGemVX(int m,int n,double alpha,CMatrixDouble &a,int ia,int ja,int opa,CRowDouble &x,int ix,double beta,CRowDouble &y,int iy);
   static void       RGer(int m,int n,double alpha,CRowDouble &u,CRowDouble &v,CMatrixDouble &a);
   static void       RTrsVX(int n,CMatrixDouble &a,int ia,int ja,bool IsUpper,bool IsUnit,int OpType,CRowDouble &x,int ix);
  };
//+------------------------------------------------------------------+
//| Performs inplace addition of vector Y[] to column X[]            |
//| INPUT PARAMETERS:                                                |
//|   N     -  vector length                                         |
//|   Alpha -  multiplier                                            |
//|   Y     -  vector to add                                         |
//|   X     -  target column ColIdx                                  |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddVC(int n,double alpha,CRowDouble &y,
                     CMatrixDouble &x,int colidx)
  {
   if(x.Rows()==n && y.Size()==n)
      x.Col(colidx,x.Col(colidx)+y*alpha);
   else
     {
      for(int i=0; i<n; i++)
         x.Add(i,colidx,y[i]*alpha);
     }
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V, reallocating X[] if too small              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  possibly preallocated array                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V; array is     |
//|               reallocated if its length is less than N.          |
//+------------------------------------------------------------------+
void CAblasF::RSetAllocV(int n,double v,CRowDouble &x)
  {
   x=vector<double>::Full(n,v);
  }
//+------------------------------------------------------------------+
//| Sets vector A[] to V, reallocating A[] if too small.             |
//| INPUT PARAMETERS:                                                |
//|   M        -  rows count                                         |
//|   N        -  cols count                                         |
//|   V        -  value to set                                       |
//|   A        -  possibly preallocated matrix                       |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading M rows, N cols are replaced by V;          |
//|               the matrix is reallocated if its rows / cols count |
//|               is less than M / N.                                |
//+------------------------------------------------------------------+
void CAblasF::RSetAllocM(int m,int n,double v,CMatrixDouble &a)
  {
   a=matrix<double>::Full(m,n,v);
  }
//+------------------------------------------------------------------+
//| Reallocates X[] if its length is less than required value. Does  |
//| not change its length and contents if it is large enough.        |
//| INPUT PARAMETERS:                                                |
//|   N        -  desired vector length                              |
//|   X        -  possibly preallocated array                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  length(X)>=N                                       |
//+------------------------------------------------------------------+
void CAblasF::RAllocV(int n,CRowDouble &x)
  {
   if((int)x.Size()<n)
      x.Resize(n);
  }
//+------------------------------------------------------------------+
//| Reallocates X[] if its length is less than required value. Does  |
//| not change its length and contents if it is large enough.        |
//| INPUT PARAMETERS:                                                |
//|   N        -  desired vector length                              |
//|   X        -  possibly preallocated array                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  length(X)>=N                                       |
//+------------------------------------------------------------------+
void CAblasF::IAllocV(int n,CRowInt &x)
  {
   if(x.Size()<n)
     {
      x.Resize(n);
      x.Fill(0);
     }
  }
//+------------------------------------------------------------------+
//| Reallocates X[] if its length is less than required value. Does  |
//| not change its length and contents if it is large enough.        |
//| INPUT PARAMETERS:                                                |
//|   N        -  desired vector length                              |
//|   X        -   possibly preallocated array                       |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  length(X) >= N                                     |
//+------------------------------------------------------------------+
void CAblasF::BAllocV(int n,bool &x[])
  {
   if(CAp::Len(x)<n)
      ArrayResize(x,n);
  }
//+------------------------------------------------------------------+
//| Reallocates matrix if its rows or cols count is less than        |
//| required. Does not change its size if it is exactly that size or |
//| larger.                                                          |
//| INPUT PARAMETERS:                                                |
//|   M        -  rows count                                         |
//|   N        -  cols count                                         |
//|   A        -  possibly preallocated matrix                       |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  size is at least M*N                               |
//+------------------------------------------------------------------+
void CAblasF::RAllocM(int m,int n,CMatrixDouble &a)
  {
   if((int)a.Rows()<m || (int)a.Cols()<n)
      a.Resize(m,n);
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V, reallocating X[] if too small              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  possibly preallocated array                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V; array is     |
//|               reallocated if its length is less than N.          |
//+------------------------------------------------------------------+
void CAblasF::ISetAllocV(int n,int v,CRowInt &x)
  {
   IAllocV(n,x);
   ISetV(n,v,x);
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V, reallocating X[] if too small              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  possibly preallocated array                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V; array is     |
//|               reallocated if its length is less than N.          |
//+------------------------------------------------------------------+
void CAblasF::BSetAllocV(int n,bool v,bool &x[])
  {
   BAllocV(n,x);
   BSetV(n,v,x);
  }
//+------------------------------------------------------------------+
//| Sets col J of A[,] to V                                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   A        -  array[N,N] or larger                               |
//|   J        -  col index                                          |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading N elements of I-th col are replaced by V   |
//+------------------------------------------------------------------+
void CAblasF::RSetC(int n,double v,CMatrixDouble &a,int j)
  {
   a.Col(j,vector<double>::Full(n,v));
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[], resizing Y[] if needed.                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   Y        -  possibly preallocated array[N] (resized if needed) |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading N elements are replaced by X               |
//+------------------------------------------------------------------+
void CAblasF::RCopyAllocV(int n,CRowDouble &x,CRowDouble &y)
  {
   y=x;
   y.Resize(n);
  }
//+------------------------------------------------------------------+
//| Copies matrix X[] to Y[], resizing Y[] if needed. On resize,     |
//| dimensions of Y[] are increased - but not decreased.             |
//| INPUT PARAMETERS:                                                |
//|   M        -  rows count                                         |
//|   N        -  cols count                                         |
//|   X        -  array[M,N], source                                 |
//|   Y        -  possibly preallocated array[M,N](resized if needed)|
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading [M,N] elements are replaced by X           |
//+------------------------------------------------------------------+
void CAblasF::RCopyM(int m,int n,CMatrixDouble &x,CMatrixDouble &y)
  {
//--- quick exit
   if(m==0 || n==0)
      return;
//--- check
   if((int)y.Rows()<=m && (int)y.Cols()<=n)
     {
      y=x;
      return;
     }
//--- create variables
   int i=0;
   int j=0;
//--- check
   if((int)y.Rows()>m && (int)y.Cols()<=n)
     {
      RAllocM(m,n,y);
      for(i=0; i<m; i++)
         y.Row(i,x.Row(i)+0);
      return;
     }
//--- check
   if((int)y.Rows()<=m && (int)y.Cols()>n)
     {
      RAllocM(m,n,y);
      for(i=0; i<n; i++)
         y.Col(i,x.Col(i)+0);
      return;
     }

   for(i=0; i<m; i++)
      for(j=0; j<n; j++)
         y.Set(i,j,x.Get(i,j));
  }
//+------------------------------------------------------------------+
//| Copies matrix X[] to Y[], resizing Y[] if needed. On resize,     |
//| dimensions of Y[] are increased - but not decreased.             |
//| INPUT PARAMETERS:                                                |
//|   M        -  rows count                                         |
//|   N        -  cols count                                         |
//|   X        -  array[M,N], source                                 |
//|   Y        -  possibly preallocated array[M,N](resized if needed)|
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading [M,N] elements are replaced by X           |
//+------------------------------------------------------------------+
void CAblasF::RCopyAllocM(int m,int n,CMatrixDouble &x,CMatrixDouble &y)
  {
   RCopyM(m,n,x,y);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[], resizing Y[] if needed.                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   Y        -  possibly preallocated array[N] (resized if needed) |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading N elements are replaced by X               |
//+------------------------------------------------------------------+
void CAblasF::ICopyAllocV(int n,CRowInt &x,CRowInt &y)
  {
   ICopyV(n,x,y);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[], resizing Y[] if needed.                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   Y        -  possibly preallocated array[N] (resized if needed) |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading N elements are replaced by X               |
//+------------------------------------------------------------------+
void CAblasF::BCopyAllocV(int n,bool &x[],bool &y[])
  {
   ArrayCopy(y,x,0,0,n);
  }
//+------------------------------------------------------------------+
//| Grows X, i.e. changes its size in such a way that:               |
//|   a) contents is preserved                                       |
//|   b) new size is at least N                                      |
//|   c) actual size can be larger than N, so subsequent grow() calls|
//|      can return without reallocation                             |
//+------------------------------------------------------------------+
void CAblasF::IGrowV(int newn,CRowInt &x)
  {
//--- quick exit
   if(x.Size()>=newn)
      return;
//--- create a variable
   int oldn=x.Size();
   newn=MathMax(newn,(int)MathRound(1.8*oldn+1));
   x.Resize(newn);
  }
//+------------------------------------------------------------------+
//| Grows X, i.e. changes its size in such a way that:               |
//|   a) contents is preserved                                       |
//|   b) new size is at least N                                      |
//|   c) actual size can be larger than N, so subsequent grow() calls|
//|      can return without reallocation                             |
//+------------------------------------------------------------------+
void CAblasF::RGrowV(int newn,CRowDouble &x)
  {
//--- quick exit
   if((int)x.Size()>=newn)
      return;
//--- create a variable
   int oldn=(int)x.Size();
   newn=MathMax(newn,(int)MathRound(1.8*oldn+1));
   x.Resize(newn);
  }
//+------------------------------------------------------------------+
//| Performs copying with multiplication of V*X[] to Y[*,J]          |
//| INPUT PARAMETERS:   `                                            |
//|   N        -  vector length                                      |
//|   V        -  multiplier                                         |
//|   X        -  array[N], source                                   |
//|   Y        -  preallocated array[N,?]                            |
//|   CIdx     -  destination rocol index                            |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  Y[RIdx,...] = V*X                                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyMulVC(int n,double v,CRowDouble &x,CMatrixDouble &y,
                         int cidx)
  {
//--- create variable
   vector<double> temp=x.ToVector();
//--- check
   if(temp.Size()!=n)
      temp.Resize(n);
//--- copy
   y.Col(cidx,temp*v);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to column J of A[,]                            |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   A        -  preallocated 2D array large enough to store result |
//|   J        -  destination col index                              |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading N elements of J-th column are replaced by X|
//+------------------------------------------------------------------+
void CAblasF::RCopyVC(int n,CRowDouble &x,CMatrixDouble &a,int j)
  {
//--- create variable
   vector<double> temp=x.ToVector();
//--- check
   if(temp.Size()!=n)
      temp.Resize(n);
//--- copy
   a.Col(j,temp);
  }
//+------------------------------------------------------------------+
//| Copies column J of A[,] to vector X[]                            |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   A        -  source 2D array                                    |
//|   J        -  source col index                                   |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  preallocated array[N], destination                 |
//+------------------------------------------------------------------+
void CAblasF::RCopyCV(int n,CMatrixDouble &a,int j,CRowDouble &x)
  {
   if(x.Size()<=n && a.Rows()>=n)
     {
      x=a.Col(j)+0;
      if(x.Size()!=n)
         x.Resize(n);
     }
   else
     {
      for(int i=0; i<MathMin(n,a.Rows()); i++)
         x.Set(i,a.Get(i,j));
     }
  }
//+------------------------------------------------------------------+
//| CMatrixGEMM kernel, basecase code for CMatrixGEMM.               |
//| This subroutine calculates C = alpha*op1(A)*op2(B) +beta*C where:|
//|   * C is MxN general matrix                                      |
//|   * op1(A) is MxK matrix                                         |
//|   * op2(B) is KxN matrix                                         |
//|  *"op" may be identity transformation, transposition, conjugate|
//|     transposition                                                |
//| Additional info:                                                 |
//|   * multiplication result replaces C. If Beta=0, C elements are  |
//|     not used in calculations (not multiplied by zero - just not  |
//|     referenced)                                                  |
//|   * if Alpha=0, A is not used (not multiplied by zero - just not |
//|     referenced)                                                  |
//|   * if both Beta and Alpha are zero, C is filled by zeros.       |
//| IMPORTANT:                                                       |
//| This function does NOT preallocate output matrix C, it MUST be   |
//| preallocated by caller prior to calling this function. In case C |
//| does not have enough space to store result, exception will be    |
//| generated.                                                       |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   OpTypeA  -  transformation type:                               |
//|               * 0 - no transformation                            |
//|               * 1 - transposition                                |
//|               * 2 - conjugate transposition                      |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   OpTypeB  -  transformation type:                               |
//|               * 0 - no transformation                            |
//|               * 1 - transposition                                |
//|               * 2 - conjugate transposition                      |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::CMatrixGemmK(int m,int n,int k,complex alpha,
                           const CMatrixComplex &a,int ia,int ja,int optypea,
                           const CMatrixComplex &b,int ib,int jb,int optypeb,
                           complex beta,CMatrixComplex &c,int ic,int jc)
  {
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- if K=0 or Alpha=0, then C=Beta*C
   if(beta!=1.0)
     {
      if(beta!=0.0)
        {
         for(int i=0; i<m; i++)
            for(int j=0; j<n ; j++)
               c.Set(ic+i,jc+j,beta*c.Get(ic+i,jc+j));
        }
      else
        {
         for(int i=0; i<m; i++)
            for(int j=0; j<n; j++)
               c.Set(ic+i,jc+j,0.0);
        }
     }
   if(k==0 || alpha==0)
      return;
//--- create variables
   int     i=0;
   int     j=0;
   complex v=0;
   complex v00=0;
   complex v01=0;
   complex v10=0;
   complex v11=0;
   double  v00x=0;
   double  v00y=0;
   double  v01x=0;
   double  v01y=0;
   double  v10x=0;
   double  v10y=0;
   double  v11x=0;
   double  v11y=0;
   double  a0x=0;
   double  a0y=0;
   double  a1x=0;
   double  a1y=0;
   double  b0x=0;
   double  b0y=0;
   double  b1x=0;
   double  b1y=0;
   int     idxa0=0;
   int     idxa1=0;
   int     idxb0=0;
   int     idxb1=0;
   int     i0=0;
   int     i1=0;
   int     ik=0;
   int     j0=0;
   int     j1=0;
   int     jk=0;
   int     t=0;
   int     offsa=0;
   int     offsb=0;
   int     i_=0;
   int     i1_=0;
//--- General case
   for(i=0; i<m; i+=2)
     {
      for(j=0; j<n; j+=2)
        {
         //--- Choose between specialized 4x4 code and general code
         if(i+2<=m && j+2<=n)
           {
            //--- Specialized 4x4 code for [I..I+3]x[J..J+3] submatrix of C.
            //--- This submatrix is calculated as sum of K rank-1 products,
            //--- with operands cached in local variables in order to speed
            //--- up operations with arrays.
            v00x=0.0;
            v00y=0.0;
            v01x=0.0;
            v01y=0.0;
            v10x=0.0;
            v10y=0.0;
            v11x=0.0;
            v11y=0.0;
            if(optypea==0)
              {
               idxa0=ia+i+0;
               idxa1=ia+i+1;
               offsa=ja;
              }
            else
              {
               idxa0=ja+i+0;
               idxa1=ja+i+1;
               offsa=ia;
              }
            if(optypeb==0)
              {
               idxb0=jb+j+0;
               idxb1=jb+j+1;
               offsb=ib;
              }
            else
              {
               idxb0=ib+j+0;
               idxb1=ib+j+1;
               offsb=jb;
              }
            for(t=0; t<k; t++)
              {
               switch(optypea)
                 {
                  case 0:
                     a0x=a.Get(idxa0,offsa).real;
                     a0y=a.Get(idxa0,offsa).imag;
                     a1x=a.Get(idxa1,offsa).real;
                     a1y=a.Get(idxa1,offsa).imag;
                     break;
                  case 1:
                     a0x=a.Get(offsa,idxa0).real;
                     a0y=a.Get(offsa,idxa0).imag;
                     a1x=a.Get(offsa,idxa1).real;
                     a1y=a.Get(offsa,idxa1).imag;
                     break;
                  case 2:
                     a0x=a.Get(offsa,idxa0).real;
                     a0y=-a.Get(offsa,idxa0).imag;
                     a1x=a.Get(offsa,idxa1).real;
                     a1y=-a.Get(offsa,idxa1).imag;
                     break;
                 }
               switch(optypeb)
                 {
                  case 0:
                     b0x=b.Get(offsb,idxb0).real;
                     b0y=b.Get(offsb,idxb0).imag;
                     b1x=b.Get(offsb,idxb1).real;
                     b1y=b.Get(offsb,idxb1).imag;
                     break;
                  case 1:
                     b0x=b.Get(idxb0,offsb).real;
                     b0y=b.Get(idxb0,offsb).imag;
                     b1x=b.Get(idxb1,offsb).real;
                     b1y=b.Get(idxb1,offsb).imag;
                     break;
                  case 2:
                     b0x=b.Get(idxb0,offsb).real;
                     b0y=-b.Get(idxb0,offsb).imag;
                     b1x=b.Get(idxb1,offsb).real;
                     b1y=-b.Get(idxb1,offsb).imag;
                     break;
                 }
               v00x+=a0x*b0x-a0y*b0y;
               v00y+=a0x*b0y+a0y*b0x;
               v01x+=a0x*b1x-a0y*b1y;
               v01y+=a0x*b1y+a0y*b1x;
               v10x+=a1x*b0x-a1y*b0y;
               v10y+=a1x*b0y+a1y*b0x;
               v11x+=a1x*b1x-a1y*b1y;
               v11y+=a1x*b1y+a1y*b1x;
               offsa++;
               offsb++;
              }
            v00.real=v00x;
            v00.imag=v00y;
            v10.real=v10x;
            v10.imag=v10y;
            v01.real=v01x;
            v01.imag=v01y;
            v11.real=v11x;
            v11.imag=v11y;
            if(beta==0)
              {
               c.Set(ic+i,jc+j,alpha*v00);
               c.Set(ic+i,jc+j+1,alpha*v01);
               c.Set(ic+i+1,jc+j,alpha*v10);
               c.Set(ic+i+1,jc+j+1,alpha*v11);
              }
            else
              {
               c.Set(ic+i,jc+j,c.Get(ic+i,jc+j)+alpha*v00);
               c.Set(ic+i,jc+j+1,c.Get(ic+i,jc+j+1)+alpha*v01);
               c.Set(ic+i+1,jc+j,c.Get(ic+i+1,jc+j)+alpha*v10);
               c.Set(ic+i+1,jc+j+1,c.Get(ic+i+1,jc+j+1)+alpha*v11);
              }
           }
         else
           {
            //--- Determine submatrix [I0..I1]x[J0..J1] to process
            i0=i;
            i1=MathMin(i+1,m-1);
            j0=j;
            j1=MathMin(j+1,n-1);
            //--- Process submatrix
            for(ik=i0; ik<=i1; ik++)
              {
               for(jk=j0; jk<=j1; jk++)
                 {
                  v=0.0;
                  switch(optypea)
                    {
                     case 0:
                        switch(optypeb)
                          {
                           case 0:
                              i1_=(ib)-(ja);
                              for(i_=ja; i_<ja+k; i_++)
                                 v+=a.Get(ia+ik,i_)*b.Get(i_+i1_,jb+jk);
                              break;
                           case 1:
                              i1_=(jb)-(ja);
                              for(i_=ja; i_<ja+k; i_++)
                                 v+=a.Get(ia+ik,i_)*b.Get(ib+jk,i_+i1_);
                              break;
                           case 2:
                              i1_=(jb)-(ja);
                              for(i_=ja; i_<ja+k; i_++)
                                 v+=a.Get(ia+ik,i_)*CMath::Conj(b.Get(ib+jk,i_+i1_));
                              break;
                          }
                        break;
                     case 1:
                        switch(optypeb)
                          {
                           case 0:
                              i1_=(ib)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=a.Get(i_,ja+ik)*b.Get(i_+i1_,jb+jk);
                              break;
                           case 1:
                              i1_=(jb)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=a.Get(i_,ja+ik)*b.Get(ib+jk,i_+i1_);
                              break;
                           case 2:
                              i1_=(jb)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=a.Get(i_,ja+ik)*CMath::Conj(b.Get(ib+jk,i_+i1_));
                          }
                        break;
                     case 2:
                        switch(optypeb)
                          {
                           case 0:
                              i1_=(ib)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=CMath::Conj(a.Get(i_,ja+ik))*b.Get(i_+i1_,jb+jk);
                              break;
                           case 1:
                              i1_=(jb)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=CMath::Conj(a.Get(i_,ja+ik))*b.Get(ib+jk,i_+i1_);
                              break;
                           case 2:
                              i1_=(jb)-(ia);
                              for(i_=ia; i_<ia+k; i_++)
                                 v+=CMath::Conj(a.Get(i_,ja+ik))*CMath::Conj(b.Get(ib+jk,i_+i1_));
                              break;
                          }
                        break;
                    }
                  if(beta==0)
                     c.Set(ic+ik,jc+jk,alpha*v);
                  else
                     c.Set(ic+ik,jc+jk,c.Get(ic+ik,jc+jk)+alpha*v);
                 }   // end for(jk)
              }   // end for(ik)
           }   // end else
        }   // end for(j)
     } // end for(i)
  }
//+------------------------------------------------------------------+
//| RMatrixGEMM kernel, basecase code for RMatrixGEMM.               |
//| This subroutine calculates C = alpha*op1(A)*op2(B) +beta*C where:|
//|   * C is MxN general matrix                                      |
//|   * op1(A) is MxK matrix                                         |
//|   * op2(B) is KxN matrix                                         |
//|  *"op" may be identity transformation, transposition           |
//| Additional info:                                                 |
//|   * multiplication result replaces C. If Beta=0, C elements are  |
//|     not used in calculations (not multiplied by zero - just not  |
//|     referenced)                                                  |
//|   * if Alpha=0, A is not used (not multiplied by zero - just not |
//|     referenced)                                                  |
//|   * if both Beta and Alpha are zero, C is filled by zeros.       |
//| IMPORTANT:                                                       |
//| This function does NOT preallocate output matrix C, it MUST be   |
//| preallocated by caller prior to calling this function. In case C |
//| does not have enough space to store result, exception will be    |
//| generated.                                                       |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   OpTypeA  -  transformation type:                               |
//|               * 0 - no transformation                            |
//|               * 1 - transposition                                |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   OpTypeB  -  transformation type:                               |
//|               * 0 - no transformation                            |
//|               * 1 - transposition                                |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::RMatrixGemmK(int m,int n,int k,double alpha,
                           const CMatrixDouble &a,int ia,int ja,int optypea,
                           const CMatrixDouble &b,int ib,int jb,int optypeb,
                           double beta,CMatrixDouble &c,int ic,int jc)
  {
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- Call specialized code.
//--- NOTE: specialized code was moved to separate function because of strange
//---       issues with instructions cache on some systems; Having too long
//---       functions significantly slows down internal loop of the algorithm.
//--- if K=0 or Alpha=0, then C=Beta*C
   if(k==0 || (double)(alpha)==0.0)
     {
      if(beta==1.0)
         return;
      if(beta!=0.0)
        {
         for(int i=0; i<m; i++)
            for(int j=0; j<n ; j++)
               c.Set(ic+i,jc+j,beta*c.Get(ic+i,jc+j));
        }
      else
        {
         for(int i=0; i<m; i++)
            for(int j=0; j<n; j++)
               c.Set(ic+i,jc+j,0);
        }
      return;
     }

   if(optypea==0)
     {
      if(optypeb==0)
         RMatrixGemmK44v00(m,n,k,alpha,a,ia,ja,b,ib,jb,beta,c,ic,jc);
      else
         RMatrixGemmK44v01(m,n,k,alpha,a,ia,ja,b,ib,jb,beta,c,ic,jc);
     }
   else
      if(optypeb==0)
         RMatrixGemmK44v10(m,n,k,alpha,a,ia,ja,b,ib,jb,beta,c,ic,jc);
      else
         RMatrixGemmK44v11(m,n,k,alpha,a,ia,ja,b,ib,jb,beta,c,ic,jc);
  }
//+------------------------------------------------------------------+
//| RMatrixGEMM kernel, basecase code for RMatrixGEMM, specialized   |
//| for sitation with OpTypeA=0 and OpTypeB=0.                       |
//| Additional info:                                                 |
//|   * this function requires that Alpha<>0 (assertion is thrown    |
//|     otherwise)                                                   |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::RMatrixGemmK44v00(int m,int n,int k,double alpha,
                                const CMatrixDouble &a,int ia,int ja,
                                const CMatrixDouble &b,int ib,int jb,
                                double beta,CMatrixDouble &c,int ic,int jc)
  {
//--- check
   if(!CAp::Assert(alpha!=0.0,__FUNCTION__": internal error (Alpha=0)"))
      return;
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
   double v00=0;
   double v01=0;
   double v02=0;
   double v03=0;
   double v10=0;
   double v11=0;
   double v12=0;
   double v13=0;
   double v20=0;
   double v21=0;
   double v22=0;
   double v23=0;
   double v30=0;
   double v31=0;
   double v32=0;
   double v33=0;
   double a0=0;
   double a1=0;
   double a2=0;
   double a3=0;
   double b0=0;
   double b1=0;
   double b2=0;
   double b3=0;
   int    idxa0=0;
   int    idxa1=0;
   int    idxa2=0;
   int    idxa3=0;
   int    idxb0=0;
   int    idxb1=0;
   int    idxb2=0;
   int    idxb3=0;
   int    i0=0;
   int    i1=0;
   int    ik=0;
   int    j0=0;
   int    j1=0;
   int    jk=0;
   int    t=0;
   int    offsa=0;
   int    offsb=0;
   int    i_=0;
   int    i1_=0;
//--- A*B
   for(i=0; i<m; i+=4)
     {
      for(j=0; j<n; j+=4)
        {
         //--- Choose between specialized 4x4 code and general code
         if(i+4<=m && j+4<=n)
           {
            //--- Specialized 4x4 code for [I..I+3]x[J..J+3] submatrix of C.
            //--- This submatrix is calculated as sum of K rank-1 products,
            //--- with operands cached in local variables in order to speed
            //--- up operations with arrays.
            idxa0=ia+i;
            idxa1=idxa0+1;
            idxa2=idxa0+2;
            idxa3=idxa0+3;
            offsa=ja;
            idxb0=jb+j;
            idxb1=idxb0+1;
            idxb2=idxb0+2;
            idxb3=idxb0+3;
            offsb=ib;
            v00=0.0;
            v01=0.0;
            v02=0.0;
            v03=0.0;
            v10=0.0;
            v11=0.0;
            v12=0.0;
            v13=0.0;
            v20=0.0;
            v21=0.0;
            v22=0.0;
            v23=0.0;
            v30=0.0;
            v31=0.0;
            v32=0.0;
            v33=0.0;
            //--- Different variants of internal loop
            for(t=0; t<k; t++)
              {
               a0=a.Get(idxa0,offsa);
               a1=a.Get(idxa1,offsa);
               b0=b.Get(offsb,idxb0);
               b1=b.Get(offsb,idxb1);
               v00+=a0*b0;
               v01+=a0*b1;
               v10+=a1*b0;
               v11+=a1*b1;
               a2=a.Get(idxa2,offsa);
               a3=a.Get(idxa3,offsa);
               v20+=a2*b0;
               v21+=a2*b1;
               v30+=a3*b0;
               v31+=a3*b1;
               b2=b.Get(offsb,idxb2);
               b3=b.Get(offsb,idxb3);
               v22+=a2*b2;
               v23+=a2*b3;
               v32+=a3*b2;
               v33+=a3*b3;
               v02+=a0*b2;
               v03+=a0*b3;
               v12+=a1*b2;
               v13+=a1*b3;
               offsa++;
               offsb++;
              }
            if(beta==0.0)
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,alpha*v00);
               c.Set(idxa0,idxb0+1,alpha*v01);
               c.Set(idxa0,idxb0+2,alpha*v02);
               c.Set(idxa0,idxb0+3,alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v10);
               c.Set(idxa0,idxb0+1,alpha*v11);
               c.Set(idxa0,idxb0+2,alpha*v12);
               c.Set(idxa0,idxb0+3,alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v20);
               c.Set(idxa0,idxb0+1,alpha*v21);
               c.Set(idxa0,idxb0+2,alpha*v22);
               c.Set(idxa0,idxb0+3,alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v30);
               c.Set(idxa0,idxb0+1,alpha*v31);
               c.Set(idxa0,idxb0+2,alpha*v32);
               c.Set(idxa0,idxb0+3,alpha*v33);
              }
            else
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v00);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v01);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v02);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v10);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v11);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v12);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v20);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v21);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v22);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v30);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v31);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v32);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v33);
              }
           }
         else
           {
            //--- Determine submatrix [I0..I1]x[J0..J1] to process
            i0=i;
            i1=MathMin(i+3,m-1);
            j0=j;
            j1=MathMin(j+3,n-1);
            //--- Process submatrix
            for(ik=i0; ik<=i1; ik++)
              {
               for(jk=j0; jk<=j1; jk++)
                 {
                  v=0.0;
                  if(k!=0 && alpha!=0.0)
                    {
                     i1_=(ib)-(ja);
                     for(i_=ja; i_<ja+k; i_++)
                        v+=a.Get(ia+ik,i_)*b.Get(i_+i1_,jb+jk);
                    }
                  if(beta==0.0)
                     c.Set(ic+ik,jc+jk,alpha*v);
                  else
                     c.Set(ic+ik,jc+jk,beta*c.Get(ic+ik,jc+jk)+alpha*v);
                 }
              }
           }   // else
        }   // end for(j)
     }   // end for(i)
  }
//+------------------------------------------------------------------+
//| RMatrixGEMM kernel, basecase code for RMatrixGEMM, specialized   |
//| for sitation with OpTypeA=0 and OpTypeB=1.                       |
//| Additional info:                                                 |
//|   * this function requires that Alpha<>0 (assertion is thrown    |
//|     otherwise)                                                   |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::RMatrixGemmK44v01(int m,int n,int k,double alpha,
                                const CMatrixDouble &a,int ia,int ja,
                                const CMatrixDouble &b,int ib,int jb,
                                double beta,CMatrixDouble &c,int ic,int jc)
  {
//--- check
   if(!CAp::Assert(alpha!=0.0,__FUNCTION__": internal error (Alpha=0)"))
      return;
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
   double v00=0;
   double v01=0;
   double v02=0;
   double v03=0;
   double v10=0;
   double v11=0;
   double v12=0;
   double v13=0;
   double v20=0;
   double v21=0;
   double v22=0;
   double v23=0;
   double v30=0;
   double v31=0;
   double v32=0;
   double v33=0;
   double a0=0;
   double a1=0;
   double a2=0;
   double a3=0;
   double b0=0;
   double b1=0;
   double b2=0;
   double b3=0;
   int    idxa0=0;
   int    idxa1=0;
   int    idxa2=0;
   int    idxa3=0;
   int    idxb0=0;
   int    idxb1=0;
   int    idxb2=0;
   int    idxb3=0;
   int    i0=0;
   int    i1=0;
   int    ik=0;
   int    j0=0;
   int    j1=0;
   int    jk=0;
   int    t=0;
   int    offsa=0;
   int    offsb=0;
   int    i_=0;
   int    i1_=0;
//--- A*B'
   for(i=0; i<m; i+=4)
     {
      for(j=0; j<n; j+=4)
        {
         //--- Choose between specialized 4x4 code and general code
         if(i+4<=m && j+4<=n)
           {
            //--- Specialized 4x4 code for [I..I+3]x[J..J+3] submatrix of C.
            //--- This submatrix is calculated as sum of K rank-1 products,
            //--- with operands cached in local variables in order to speed
            //--- up operations with arrays.
            idxa0=ia+i;
            idxa1=idxa0+1;
            idxa2=idxa0+2;
            idxa3=idxa0+3;
            offsa=ja;
            idxb0=ib+j;
            idxb1=idxb0+1;
            idxb2=idxb0+2;
            idxb3=idxb0+3;
            offsb=jb;
            v00=0.0;
            v01=0.0;
            v02=0.0;
            v03=0.0;
            v10=0.0;
            v11=0.0;
            v12=0.0;
            v13=0.0;
            v20=0.0;
            v21=0.0;
            v22=0.0;
            v23=0.0;
            v30=0.0;
            v31=0.0;
            v32=0.0;
            v33=0.0;
            for(t=0; t<k; t++)
              {
               a0=a.Get(idxa0,offsa);
               a1=a.Get(idxa1,offsa);
               b0=b.Get(idxb0,offsb);
               b1=b.Get(idxb1,offsb);
               v00+=a0*b0;
               v01+=a0*b1;
               v10+=a1*b0;
               v11+=a1*b1;
               a2=a.Get(idxa2,offsa);
               a3=a.Get(idxa3,offsa);
               v20+=a2*b0;
               v21+=a2*b1;
               v30+=a3*b0;
               v31+=a3*b1;
               b2=b.Get(idxb2,offsb);
               b3=b.Get(idxb3,offsb);
               v22+=a2*b2;
               v23+=a2*b3;
               v32+=a3*b2;
               v33+=a3*b3;
               v02+=a0*b2;
               v03+=a0*b3;
               v12+=a1*b2;
               v13+=a1*b3;
               offsa++;
               offsb++;
              }
            if(beta==0.0)
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,alpha*v00);
               c.Set(idxa0,idxb0+1,alpha*v01);
               c.Set(idxa0,idxb0+2,alpha*v02);
               c.Set(idxa0,idxb0+3,alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v10);
               c.Set(idxa0,idxb0+1,alpha*v11);
               c.Set(idxa0,idxb0+2,alpha*v12);
               c.Set(idxa0,idxb0+3,alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v20);
               c.Set(idxa0,idxb0+1,alpha*v21);
               c.Set(idxa0,idxb0+2,alpha*v22);
               c.Set(idxa0,idxb0+3,alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v30);
               c.Set(idxa0,idxb0+1,alpha*v31);
               c.Set(idxa0,idxb0+2,alpha*v32);
               c.Set(idxa0,idxb0+3,alpha*v33);
              }
            else
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v00);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v01);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v02);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v10);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v11);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v12);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v20);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v21);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v22);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v30);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v31);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v32);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v33);
              }
           }
         else
           {
            //--- Determine submatrix [I0..I1]x[J0..J1] to process
            i0=i;
            i1=MathMin(i+3,m-1);
            j0=j;
            j1=MathMin(j+3,n-1);
            //--- Process submatrix
            for(ik=i0; ik<=i1; ik++)
              {
               for(jk=j0; jk<=j1; jk++)
                 {
                  v=0;
                  if(k!=0 && alpha!=0.0)
                    {
                     i1_=(jb)-(ja);
                     for(i_=ja; i_<ja+k; i_++)
                        v+=a.Get(ia+ik,i_)*b.Get(ib+jk,i_+i1_);
                    }
                  if(beta==0.0)
                     c.Set(ic+ik,jc+jk,alpha*v);
                  else
                     c.Set(ic+ik,jc+jk,beta*c.Get(ic+ik,jc+jk)+alpha*v);
                 }
              }
           }   // else
        }   // end for(j)
     }   // end for(i)
  }
//+------------------------------------------------------------------+
//| RMatrixGEMM kernel, basecase code for RMatrixGEMM, specialized   |
//| for sitation with OpTypeA=1 and OpTypeB=0.                       |
//| Additional info:                                                 |
//|   * this function requires that Alpha<>0 (assertion is thrown    |
//|     otherwise)                                                   |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::RMatrixGemmK44v10(int m,int n,int k,double alpha,
                                const CMatrixDouble &a,int ia,int ja,
                                const CMatrixDouble &b,int ib,int jb,
                                double beta,CMatrixDouble &c,int ic,int jc)
  {
//--- check
   if(!CAp::Assert(alpha!=0.0,__FUNCTION__": internal error (Alpha=0)"))
      return;
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- create variable
   int    i=0;
   int    j=0;
   double v=0;
   double v00=0;
   double v01=0;
   double v02=0;
   double v03=0;
   double v10=0;
   double v11=0;
   double v12=0;
   double v13=0;
   double v20=0;
   double v21=0;
   double v22=0;
   double v23=0;
   double v30=0;
   double v31=0;
   double v32=0;
   double v33=0;
   double a0=0;
   double a1=0;
   double a2=0;
   double a3=0;
   double b0=0;
   double b1=0;
   double b2=0;
   double b3=0;
   int    idxa0=0;
   int    idxa1=0;
   int    idxa2=0;
   int    idxa3=0;
   int    idxb0=0;
   int    idxb1=0;
   int    idxb2=0;
   int    idxb3=0;
   int    i0=0;
   int    i1=0;
   int    ik=0;
   int    j0=0;
   int    j1=0;
   int    jk=0;
   int    t=0;
   int    offsa=0;
   int    offsb=0;
   int    i_=0;
   int    i1_=0;
//--- A'*B
   for(i=0; i<m; i+=4)
     {
      for(j=0; j<n; j+=4)
        {
         //--- Choose between specialized 4x4 code and general code
         if(i+4<=m && j+4<=n)
           {
            //--- Specialized 4x4 code for [I..I+3]x[J..J+3] submatrix of C.
            //--- This submatrix is calculated as sum of K rank-1 products,
            //--- with operands cached in local variables in order to speed
            //--- up operations with arrays.
            idxa0=ja+i;
            idxa1=idxa0+1;
            idxa2=idxa0+2;
            idxa3=idxa0+3;
            offsa=ia;
            idxb0=jb+j;
            idxb1=idxb0+1;
            idxb2=idxb0+2;
            idxb3=idxb0+3;
            offsb=ib;
            v00=0.0;
            v01=0.0;
            v02=0.0;
            v03=0.0;
            v10=0.0;
            v11=0.0;
            v12=0.0;
            v13=0.0;
            v20=0.0;
            v21=0.0;
            v22=0.0;
            v23=0.0;
            v30=0.0;
            v31=0.0;
            v32=0.0;
            v33=0.0;
            for(t=0; t<k; t++)
              {
               a0=a.Get(offsa,idxa0);
               a1=a.Get(offsa,idxa1);
               b0=b.Get(offsb,idxb0);
               b1=b.Get(offsb,idxb1);
               v00+=a0*b0;
               v01+=a0*b1;
               v10+=a1*b0;
               v11+=a1*b1;
               a2=a.Get(offsa,idxa2);
               a3=a.Get(offsa,idxa3);
               v20+=a2*b0;
               v21+=a2*b1;
               v30+=a3*b0;
               v31+=a3*b1;
               b2=b.Get(offsb,idxb2);
               b3=b.Get(offsb,idxb3);
               v22+=a2*b2;
               v23+=a2*b3;
               v32+=a3*b2;
               v33+=a3*b3;
               v02+=a0*b2;
               v03+=a0*b3;
               v12+=a1*b2;
               v13+=a1*b3;
               offsa++;
               offsb++;
              }
            if(beta==0.0)
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,alpha*v00);
               c.Set(idxa0,idxb0+1,alpha*v01);
               c.Set(idxa0,idxb0+2,alpha*v02);
               c.Set(idxa0,idxb0+3,alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v10);
               c.Set(idxa0,idxb0+1,alpha*v11);
               c.Set(idxa0,idxb0+2,alpha*v12);
               c.Set(idxa0,idxb0+3,alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v20);
               c.Set(idxa0,idxb0+1,alpha*v21);
               c.Set(idxa0,idxb0+2,alpha*v22);
               c.Set(idxa0,idxb0+3,alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v30);
               c.Set(idxa0,idxb0+1,alpha*v31);
               c.Set(idxa0,idxb0+2,alpha*v32);
               c.Set(idxa0,idxb0+3,alpha*v33);
              }
            else
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v00);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v01);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v02);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v10);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v11);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v12);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v20);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v21);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v22);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v30);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v31);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v32);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v33);
              }
           }
         else
           {
            //--- Determine submatrix [I0..I1]x[J0..J1] to process
            i0=i;
            i1=MathMin(i+3,m-1);
            j0=j;
            j1=MathMin(j+3,n-1);
            //--- Process submatrix
            for(ik=i0; ik<=i1; ik++)
              {
               for(jk=j0; jk<=j1; jk++)
                 {
                  v=0;
                  if(k!=0 && alpha!=0.0)
                    {
                     i1_=(ib)-(ia);
                     for(i_=ia; i_<ia+k; i_++)
                        v+=a.Get(i_,ja+ik)*b.Get(i_+i1_,jb+jk);
                    }
                  if(beta==0.0)
                     c.Set(ic+ik,jc+jk,alpha*v);
                  else
                     c.Set(ic+ik,jc+jk,beta*c.Get(ic+ik,jc+jk)+alpha*v);
                 }
              }
           }   // else
        }   // end for(j)
     }   // end for(i)
  }
//+------------------------------------------------------------------+
//| RMatrixGEMM kernel, basecase code for RMatrixGEMM, specialized   |
//| for sitation with OpTypeA=1 and OpTypeB=1.                       |
//| Additional info:                                                 |
//|   * this function requires that Alpha<>0 (assertion is thrown    |
//|     otherwise)                                                   |
//| INPUT PARAMETERS:                                                |
//|   M        -  matrix size, M>0                                   |
//|   N        -  matrix size, N>0                                   |
//|   K        -  matrix size, K>0                                   |
//|   Alpha    -  coefficient                                        |
//|   A        -  matrix                                             |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   B        -  matrix                                             |
//|   IB       -  submatrix offset                                   |
//|   JB       -  submatrix offset                                   |
//|   Beta     -  coefficient                                        |
//|   C        -  PREALLOCATED output matrix                         |
//|   IC       -  submatrix offset                                   |
//|   JC       -  submatrix offset                                   |
//+------------------------------------------------------------------+
void CAblasF::RMatrixGemmK44v11(int m,int n,int k,double alpha,
                                const CMatrixDouble &a,int ia,int ja,
                                const CMatrixDouble &b,int ib,int jb,
                                double beta,CMatrixDouble &c,int ic,int jc)
  {
//--- check
   if(!CAp::Assert(alpha!=0.0,__FUNCTION__": internal error (Alpha=0)"))
      return;
//--- if matrix size is zero
   if(m==0 || n==0)
      return;
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
   double v00=0;
   double v01=0;
   double v02=0;
   double v03=0;
   double v10=0;
   double v11=0;
   double v12=0;
   double v13=0;
   double v20=0;
   double v21=0;
   double v22=0;
   double v23=0;
   double v30=0;
   double v31=0;
   double v32=0;
   double v33=0;
   double a0=0;
   double a1=0;
   double a2=0;
   double a3=0;
   double b0=0;
   double b1=0;
   double b2=0;
   double b3=0;
   int    idxa0=0;
   int    idxa1=0;
   int    idxa2=0;
   int    idxa3=0;
   int    idxb0=0;
   int    idxb1=0;
   int    idxb2=0;
   int    idxb3=0;
   int    i0=0;
   int    i1=0;
   int    ik=0;
   int    j0=0;
   int    j1=0;
   int    jk=0;
   int    t=0;
   int    offsa=0;
   int    offsb=0;
   int    i_=0;
   int    i1_=0;
//--- A'*B'
   for(i=0; i<m; i+=4)
     {
      for(j=0; j<n; j+=4)
        {
         //--- Choose between specialized 4x4 code and general code
         if(i+4<=m && j+4<=n)
           {
            //--- Specialized 4x4 code for [I..I+3]x[J..J+3] submatrix of C.
            //--- This submatrix is calculated as sum of K rank-1 products,
            //--- with operands cached in local variables in order to speed
            //--- up operations with arrays.
            idxa0=ja+i;
            idxa1=idxa0+1;
            idxa2=idxa0+2;
            idxa3=idxa0+3;
            offsa=ia;
            idxb0=ib+j;
            idxb1=idxb0+1;
            idxb2=idxb0+2;
            idxb3=idxb0+3;
            offsb=jb;
            v00=0.0;
            v01=0.0;
            v02=0.0;
            v03=0.0;
            v10=0.0;
            v11=0.0;
            v12=0.0;
            v13=0.0;
            v20=0.0;
            v21=0.0;
            v22=0.0;
            v23=0.0;
            v30=0.0;
            v31=0.0;
            v32=0.0;
            v33=0.0;
            for(t=0; t<k; t++)
              {
               a0=a.Get(offsa,idxa0);
               a1=a.Get(offsa,idxa1);
               b0=b.Get(idxb0,offsb);
               b1=b.Get(idxb1,offsb);
               v00+=a0*b0;
               v01+=a0*b1;
               v10+=a1*b0;
               v11+=a1*b1;
               a2=a.Get(offsa,idxa2);
               a3=a.Get(offsa,idxa3);
               v20+=a2*b0;
               v21+=a2*b1;
               v30+=a3*b0;
               v31+=a3*b1;
               b2=b.Get(idxb2,offsb);
               b3=b.Get(idxb3,offsb);
               v22+=a2*b2;
               v23+=a2*b3;
               v32+=a3*b2;
               v33+=a3*b3;
               v02+=a0*b2;
               v03+=a0*b3;
               v12+=a1*b2;
               v13+=a1*b3;
               offsa++;
               offsb++;
              }
            if(beta==0.0)
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,alpha*v00);
               c.Set(idxa0,idxb0+1,alpha*v01);
               c.Set(idxa0,idxb0+2,alpha*v02);
               c.Set(idxa0,idxb0+3,alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v10);
               c.Set(idxa0,idxb0+1,alpha*v11);
               c.Set(idxa0,idxb0+2,alpha*v12);
               c.Set(idxa0,idxb0+3,alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v20);
               c.Set(idxa0,idxb0+1,alpha*v21);
               c.Set(idxa0,idxb0+2,alpha*v22);
               c.Set(idxa0,idxb0+3,alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,alpha*v30);
               c.Set(idxa0,idxb0+1,alpha*v31);
               c.Set(idxa0,idxb0+2,alpha*v32);
               c.Set(idxa0,idxb0+3,alpha*v33);
              }
            else
              {
               idxa0=ic+i;
               idxb0=jc+j;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v00);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v01);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v02);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v03);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v10);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v11);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v12);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v13);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v20);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v21);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v22);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v23);
               idxa0++;
               c.Set(idxa0,idxb0,beta*c.Get(idxa0,idxb0)+alpha*v30);
               c.Set(idxa0,idxb0+1,beta*c.Get(idxa0,idxb0+1)+alpha*v31);
               c.Set(idxa0,idxb0+2,beta*c.Get(idxa0,idxb0+2)+alpha*v32);
               c.Set(idxa0,idxb0+3,beta*c.Get(idxa0,idxb0+3)+alpha*v33);
              }
           }
         else
           {
            //--- Determine submatrix [I0..I1]x[J0..J1] to process
            i0=i;
            i1=MathMin(i+3,m-1);
            j0=j;
            j1=MathMin(j+3,n-1);
            //--- Process submatrix
            for(ik=i0; ik<=i1; ik++)
              {
               for(jk=j0; jk<=j1; jk++)
                 {
                  v=0.0;
                  if(k!=0 && alpha!=0.0)
                    {
                     i1_=(jb)-(ia);
                     for(i_=ia; i_<ia+k; i_++)
                        v+=a.Get(i_,ja+ik)*b.Get(ib+jk,i_+i1_);
                    }
                  if(beta==0.0)
                     c.Set(ic+ik,jc+jk,alpha*v);
                  else
                     c.Set(ic+ik,jc+jk,beta*c.Get(ic+ik,jc+jk)+alpha*v);
                 }
              }
           }   // else
        }   // end for(j)
     }   // end for(i)
  }
//+------------------------------------------------------------------+
//| Computes dot product (X,Y) for elements [0,N) of X[] and Y[]     |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//|   Y        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   (X,Y)                                                          |
//+------------------------------------------------------------------+
double CAblasF::RDotV(int n,CRowDouble &x,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert((int)x.Size()>=n,__FUNCTION__": X size less N"))
      return(0);
   if(!CAp::Assert((int)y.Size()>=n,__FUNCTION__": Y size less N"))
      return(0);
//--- Quick exit
   if(n<=0)
      return(0);

   double result=0;

   if(x.Size()==n && y.Size()==n)
      result=x.Dot(y);
   else
      for(int i=0; i<n; i++)
         result+=x[i]*y[i];
//---return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Computes dot product (X,A[i]) for elements [0,N) of vector X[]   |
//| and row A[i,*]                                                   |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//|   A        -  array[?,N], matrix to process                      |
//|   I        -  row index                                          |
//| RESULT:                                                          |
//|   (X,Ai)                                                         |
//+------------------------------------------------------------------+
double CAblasF::RDotVR(int n,CRowDouble &x,CMatrixDouble &a,int i)
  {
//--- create variables
   CRowDouble row;
//--- check
   if(!CAp::Assert((int)a.Rows()>=i,__FUNCTION__": A rows less I"))
      return(0);

   row=a[i]+0;
   row.Resize(n);
//---return result
   return(RDotV(n,x,row));
  }
//+------------------------------------------------------------------+
//| Computes dot product (X,A[i]) for elements [0,N) of vector X[]   |
//| and row A[i,*]                                                   |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//|   A        -  array[?,N], matrix to process                      |
//|   I        -  colum index                                        |
//| RESULT:                                                          |
//|   (X,Ai)                                                         |
//+------------------------------------------------------------------+
double CAblasF::RDotVC(int n,CRowDouble &x,CMatrixDouble &a,int i)
  {
//--- create variables
   CRowDouble col;
//--- check
   if(!CAp::Assert((int)a.Cols()>=i,__FUNCTION__": A cols less I"))
      return(0);

   col=a.Col(i)+0;
   col.Resize(n);
//---return result
   return(RDotV(n,x,col));
  }
//+------------------------------------------------------------------+
//| Computes dot product(X, A[i]) for rows A[ia, *] and B[ib, *]     |
//| INPUT PARAMETERS :                                               |
//|   N        -  vector length                                      |
//|   A        -  array[ ?, N], matrix to process                    |
//|   IA       -  row index                                          |
//|   B        -  array[ ?, N], matrix to process                    |
//|   IB       -  row index                                          |
//| RESULT :                                                         |
//|   (Ai, Bi)                                                       |
//+------------------------------------------------------------------+
double CAblasF::RDotRR(int n,CMatrixDouble &a,int ia,
                       CMatrixDouble &b,int ib)
  {
//--- check
   if(!CAp::Assert((int)a.Rows()>=ia,__FUNCTION__": A rows less IA"))
      return(0);
   if(!CAp::Assert((int)b.Rows()>=ib,__FUNCTION__": B rows less IB"))
      return(0);
//--- create variables
   CRowDouble A=a[ia]+0;
   CRowDouble B=b[ib]+0;
   A.Resize(n);
   B.Resize(n);
//--- return result
   return(RDotV(n,A,B));
  }
//+------------------------------------------------------------------+
//| Computes dot product (X,X) for elements [0,N) of X[]             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   (X,X)                                                          |
//+------------------------------------------------------------------+
double CAblasF::RDotV2(int n,CRowDouble &x)
  {
   return(RDotV(n,x,x));
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of Y[] to X[]                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Alpha    -  multiplier                                         |
//|   Y        -  array[N], vector to process                        |
//|   X        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddV(int n,double alpha,CRowDouble &y,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert((int)x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert((int)y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
//--- try vector method
   if(x.Size()==n && y.Size()==n)
     {
      x+=y*alpha+0;
      return;
     }
//--- loop
   for(int i=0; i<n; i++)
      x.Add(i,alpha*y[i]);
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of Y[] to X[]                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Alpha    -  multiplier                                         |
//|   Y        -  source vector                                      |
//|   OffsY    -  source offset                                      |
//|   X        -  destination vector                                 |
//|   OffsX    -  destination offset                                 |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddVX(int n,double alpha,CRowDouble &y,int offsy,
                     CRowDouble &x,int offsx)
  {
//--- check
   if(offsx==0 && offsy==0)
     {
      RAddV(n,alpha,y,x);
      return;
     }
   if(!CAp::Assert((int)x.Size()>=(n+offsx),__FUNCTION__": X size less N+OffsX"))
      return;
   if(!CAp::Assert((int)y.Size()>=(n+offsy),__FUNCTION__": Y size less N+OffsY"))
      return;

   for(int i=0; i<n; i++)
      x.Set(offsx+i,x[offsx+i]+alpha*y[offsy+i]);
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of vector Y[] to row X[]               |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Alpha    -  multiplier                                         |
//|   Y        -  vector to add                                      |
//|   X        -  target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddVR(int n,double alpha,CRowDouble &y,
                     CMatrixDouble &x,int rowidx)
  {
   if(alpha==0)
      return;
//--- check
   if(!CAp::Assert((int)x.Rows()>=rowidx,__FUNCTION__": X rows less RowIdx"))
      return;
   if(!CAp::Assert((int)x.Cols()>=n,__FUNCTION__": X cols less N"))
      return;
   if(!CAp::Assert((int)y.Size()>=n,__FUNCTION__": Y size less N"))
      return;

   if(x.Cols()==n && y.Size()==n)
      x.Row(rowidx,x[rowidx]+y*alpha);
   else
      for(int i=0; i<n; i++)
         x.Set(rowidx,i,x.Get(rowidx,i)+alpha*y[i]);
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of Y[]*Z[] to X[]                      |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  array[N], vector to process                        |
//|   Z        -  array[N], vector to process                        |
//|   X        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   X := X + Y*Z                                                   |
//+------------------------------------------------------------------+
void CAblasF::RMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert((int)x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert((int)y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert((int)z.Size()>=n,__FUNCTION__": Z size less N"))
      return;

   if(x.Size()==n && y.Size()==n && z.Size()==n)
      x+=y*z+0;
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]+y[i]*z[i]);
  }
//+------------------------------------------------------------------+
//| Performs inplace subtraction of Y[]*Z[] from X[]                 |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  array[N], vector to process                        |
//|   Z        -  array[N], vector to process                        |
//|   X        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   X := X - Y*Z                                                   |
//+------------------------------------------------------------------+
void CAblasF::RNegMulAddV(int n,CRowDouble &y,CRowDouble &z,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(z.Size()>=n,__FUNCTION__": Z size less N"))
      return;

   if(x.Size()==n && y.Size()==n && z.Size()==n)
      x-=y*z+0;
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]-y[i]*z[i]);
  }
//+------------------------------------------------------------------+
//| Performs addition of Y[]*Z[] to X[]                              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  array[N], vector to process                        |
//|   Z        -  array[N], vector to process                        |
//|   X        -  array[N], vector to process                        |
//|   R        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   R := X + Y*Z                                                   |
//+------------------------------------------------------------------+
void CAblasF::RCopyMulAddV(int n,CRowDouble &y,CRowDouble &z,
                           CRowDouble &x,CRowDouble &r)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(z.Size()>=n,__FUNCTION__": Z size less N"))
      return;

   if(x.Size()==n && y.Size()==n && z.Size()==n)
     {
      r=x.ToVector()+y*z;
      return;
     }

   if(r.Size()<n)
      if(!CAp::Assert(z.Resize(n),__FUNCTION__": error resize vector R"))
         return;
   for(int i=0; i<n; i++)
      r.Set(i,x[i]+y[i]*z[i]);
  }
//+------------------------------------------------------------------+
//| Performs subtraction of Y[]*Z[] from X[]                         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  array[N], vector to process                        |
//|   Z        -  array[N], vector to process                        |
//|   X        -  array[N], vector to process                        |
//|   R        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   R := X - Y * Z                                                 |
//+------------------------------------------------------------------+
void CAblasF::RCopyNegMulAddV(int n,CRowDouble &y,CRowDouble &z,
                              CRowDouble &x,CRowDouble &r)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(z.Size()>=n,__FUNCTION__": Z size less N"))
      return;

   if(x.Size()==n && y.Size()==n && z.Size()==n)
     {
      r=x.ToVector()-y*z;
      return;
     }

   if(r.Size()<n)
      if(!CAp::Assert(z.Resize(n),__FUNCTION__": error resize vector R"))
         return;
   for(int i=0; i<n; i++)
      r.Set(i,x[i]-y[i]*z[i]);
  }
//+------------------------------------------------------------------+
//| Performs componentwise multiplication of vector X[] by vector Y[]|
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target vector                                      |
//| RESULT:                                                          |
//|   X := componentwise(X*Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeMulV(int n,CRowDouble &y,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;

   if(x.Size()==n && y.Size()==n)
      x*=y;
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]*y[i]);
  }
//+------------------------------------------------------------------+
//| Performs componentwise multiplication of row X[] by vector Y[]   |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := componentwise(X*Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeMulVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Mul(rowidx,i,y[i]);
  }
//+------------------------------------------------------------------+
//| Performs componentwise multiplication of row X[] by vector Y[]   |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  row RowIdY to multiply by                          |
//|   X        -  target vector                                      |
//| RESULT:                                                          |
//|   X := componentwise(X*Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeMulRV(int n,CMatrixDouble &y,int rowidy,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(y.Rows()>=rowidy,__FUNCTION__": Y Rows less RowIdx"))
      return;
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Cols()>=n,__FUNCTION__": Y Cols less N"))
      return;

   if(x.Size()==n)
     {
      if(y.Cols()==n)
         x*=y[rowidy]+0;
      else
        {
         vector<double> temp=y[rowidy];
         if(!temp.Resize(n))
            return;
         x*=temp;
        }
     }
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]*y.Get(rowidy,i));
  }
//+------------------------------------------------------------------+
//| Performs componentwise division of vector X[] by vector Y[]      |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to divide by                                |
//|   X        -  target vector                                      |
//| RESULT:                                                          |
//|   X := componentwise(X/Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeDivV(int n,CRowDouble &y,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;

   if(x.Size()==n && y.Size()==n)
      x/=y;
   else
      for(int i=0; i<n; i++)
         x.Mul(i,MathPow(y[i],-1.0));
  }
//+------------------------------------------------------------------+
//| Performs componentwise division of row X[] by vector Y[]         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y       -   vector to divide by                                |
//|   X       -   target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := componentwise(X/Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeDivVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(rowidx,i,x.Get(rowidx,i)/y[i]);
  }
//+------------------------------------------------------------------+
//| Performs componentwise division of row X[] by vector Y[]         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to divide by                                |
//|   X        -  target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := componentwise(X/Y)                                        |
//+------------------------------------------------------------------+
void CAblasF::RMergeDivRV(int n,CMatrixDouble &y,int rowidy,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(y.Rows()>=rowidy,__FUNCTION__": Y Rows less RowIdY"))
      return;
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Cols()>=n,__FUNCTION__": Y Cols less N"))
      return;

   if(x.Size()==n)
     {
      if(y.Cols()==n)
         x/=y[rowidy]+0;
      else
        {
         vector<double> temp=y[rowidy];
         if(!temp.Resize(n))
            return;
         x/=temp;
        }
     }
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]/y.Get(rowidy,i));
  }
//+------------------------------------------------------------------+
//| Performs componentwise max of vector X[] and vector Y[]          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target vector                                      |
//| RESULT:                                                          |
//|   X := componentwise_max(X,Y)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMaxV(int n,CRowDouble &y,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(i,MathMax(x[i],y[i]));
  }
//+------------------------------------------------------------------+
//| Performs componentwise max of row X[] and vector Y[]             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := componentwise_max(X,Y)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMaxVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(rowidx,i,MathMax(x.Get(rowidx,i),y[i]));
  }
//+------------------------------------------------------------------+
//| Performs componentwise max of row X[I] and vector Y[]            |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  matrix, I-th row is source                         |
//|   Y        -  target vector                                      |
//| RESULT:                                                          |
//|   Y := componentwise_max(Y,X)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMaxRV(int n,CMatrixDouble &x,int rowidx,CRowDouble &y)
  {
   if(n<=0)
      return;
//--- check
   if(!CAp::Assert(MathMax(x.Rows(),0)>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(MathMax(y.Size(),0)>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(MathMax(x.Cols(),0)>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      y.Set(i,MathMax(y[i],x.Get(rowidx,i)));
  }
//+------------------------------------------------------------------+
//| Performs componentwise min of vector X[] and vector Y[]          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target vector                                      |
//| RESULT:                                                          |
//|   X := componentwise_max(X,Y)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMinV(int n,CRowDouble &y,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(i,MathMin(x[i],y[i]));
  }
//+------------------------------------------------------------------+
//| Performs componentwise max of row X[] and vector Y[]             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Y        -  vector to multiply by                              |
//|   X        -  target row RowIdx                                  |
//| RESULT:                                                          |
//|   X := componentwise_max(X,Y)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMinVR(int n,CRowDouble &y,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(rowidx,i,MathMin(x.Get(rowidx,i),y[i]));
  }
//+------------------------------------------------------------------+
//| Performs componentwise max of row X[I] and vector Y[]            |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  matrix, I-th row is source                         |
//|   Y       -   target vector                                      |
//| RESULT:                                                          |
//|   Y := componentwise_max(X,Y)                                    |
//+------------------------------------------------------------------+
void CAblasF::RMergeMinRV(int n,CMatrixDouble &x,int rowidx,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(y.Size()>=n,__FUNCTION__": Y size less N"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      y.Set(i,MathMin(y[i],x.Get(rowidx,i)));
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of Y[RIdx,...] to X[]                  |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Alpha    -  multiplier                                         |
//|   Y        -  array[?,N], matrix whose RIdx-th row is added      |
//|   RIdx     -  row index                                          |
//|   X        -  array[N], vector to process                        |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddRV(int n,double alpha,CMatrixDouble &y,int ridx,
                     CRowDouble &x)
  {
//--- check
   if(!CAp::Assert((int)y.Rows()>=ridx,__FUNCTION__": Y Rows less RIdx"))
      return;
   if(!CAp::Assert((int)x.Size()>=n,__FUNCTION__": X size less N"))
      return;
   if(!CAp::Assert((int)y.Cols()>=n,__FUNCTION__": Y Cols less N"))
      return;

   if(x.Size()==n)
     {
      if(y.Cols()==n)
         x+=y[ridx]*alpha;
      else
        {
         vector<double> temp=y[ridx];
         if(!temp.Resize(n))
            return;
         x+=temp*alpha;
        }
     }
   else
      for(int i=0; i<n; i++)
         x.Set(i,x[i]+alpha*y.Get(ridx,i));
  }
//+------------------------------------------------------------------+
//| Performs inplace addition of Y[RIdx,...] to X[RIdxDst]           |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   Alpha    -  multiplier                                         |
//|   Y        -  array[?,N], matrix whose RIdxSrc-th row is added   |
//|   RIdxSrc  -  source row index                                   |
//|   X        -  array[?,N], matrix whose RIdxDst-th row is target  |
//|   RIdxDst  -  destination row index                              |
//| RESULT:                                                          |
//|   X := X + alpha*Y                                               |
//+------------------------------------------------------------------+
void CAblasF::RAddRR(int n,double alpha,CMatrixDouble &y,int ridxsrc,
                     CMatrixDouble &x,int ridxdst)
  {
//--- check
   if(!CAp::Assert((int)x.Rows()>=ridxdst,__FUNCTION__": X Rows less RIdxDst"))
      return;
   if(!CAp::Assert((int)y.Rows()>=ridxsrc,__FUNCTION__": Y Rows less RIdxSrc"))
      return;
   if(!CAp::Assert((int)y.Cols()>=n,__FUNCTION__": Y Cols less N"))
      return;
   if(!CAp::Assert((int)x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(ridxdst,i,x.Get(ridxdst,i)+alpha*y.Get(ridxsrc,i));
  }
//+------------------------------------------------------------------+
//| Performs inplace multiplication of X[] by V                      |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//|   V        -  multiplier                                         |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  elements 0...N - 1 multiplied by V                 |
//+------------------------------------------------------------------+
void CAblasF::RMulV(int n,double v,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(x.Size()==n)
      x*=v;
   else
      for(int i=0; i<n; i++)
         x.Mul(i,v);
  }
//+------------------------------------------------------------------+
//| Performs inplace multiplication of X[] by V                      |
//| INPUT PARAMETERS:                                                |
//|   N        -  row length                                         |
//|   X        -  array[?,N], row to process                         |
//|   V        -  multiplier                                         |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  elements 0...N-1 of row RowIdx are multiplied by V |
//+------------------------------------------------------------------+
void CAblasF::RMulR(int n,double v,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(rowidx,i,x.Get(rowidx,i)*v);
  }
//+------------------------------------------------------------------+
//| Performs inplace computation of Sqrt(X)                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  elements 0...N-1 replaced by Sqrt(X)               |
//+------------------------------------------------------------------+
void CAblasF::RSqrtV(int n,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(x.Size()==n)
      x=x.Sqrt()+0;
   else
      for(int i=0; i<n; i++)
         x.Set(i,MathSqrt(x[i]));
  }
//+------------------------------------------------------------------+
//| Performs inplace computation of Sqrt(X[RowIdx,*])                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[?,N], matrix to process                      |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  elements 0...N-1 replaced by Sqrt(X)               |
//+------------------------------------------------------------------+
void CAblasF::RSqrtR(int n,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return;
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return;

   for(int i=0; i<n; i++)
      x.Set(rowidx,i,MathSqrt(x.Get(rowidx,i)));
  }
//+------------------------------------------------------------------+
//| Performs inplace multiplication of X[OffsX:OffsX+N-1] by V       |
//| INPUT PARAMETERS:                                                |
//|   N        -  subvector length                                   |
//|   X        -  vector to process                                  |
//|   V        -  multiplier                                         |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  elements OffsX:OffsX+N-1 multiplied by V           |
//+------------------------------------------------------------------+
void CAblasF::RMulVX(int n,double v,CRowDouble &x,int offsx)
  {
//--- check
   if(offsx==0)
     {
      RMulV(n,v,x);
      return;
     }
   if(!CAp::Assert(x.Size()>=(n+offsx),__FUNCTION__": X size less N+OffsX"))
      return;

   for(int i=0; i<n; i++)
      x.Mul(offsx+i,v);
  }
//+------------------------------------------------------------------+
//| Returns maximum X                                                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//| OUTPUT PARAMETERS:                                               |
//|   max(X[i])                                                      |
//|   zero for N=0                                                   |
//+------------------------------------------------------------------+
double CAblasF::RMaxV(int n,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return(0);

   if(n==0)
      return(0);
   if(x.Size()==n)
      return(x.Max());

   vector<double> temp=x.ToVector();
   if(!temp.Resize(n))
      return(0);
//--- return result
   return(temp.Max());
  }
//+------------------------------------------------------------------+
//| Returns maximum |X|                                              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], vector to process                        |
//| OUTPUT PARAMETERS:                                               |
//|   max(|X[i]|)                                                    |
//|  zero for N=0                                                    |
//+------------------------------------------------------------------+
double CAblasF::RMaxAbsV(int n,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return(0);

   if(n==0)
      return(0);
   if(x.Size()==n)
      return(x.MaxAbs());

   CRowDouble temp=x;
   if(!temp.Resize(n))
      return(0);
//--- return result
   return(temp.MaxAbs());
  }
//+------------------------------------------------------------------+
//| Returns maximum X                                                |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  matrix to process, RowIdx-th row is processed      |
//| OUTPUT PARAMETERS:                                               |
//|   max(X[RowIdx,i])                                               |
//|   zero for N=0                                                   |
//+------------------------------------------------------------------+
double CAblasF::RMaxR(int n,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return(0);
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return(0);

   CRowDouble temp=x[rowidx]+0;
   if(temp.Size()!=n)
      if(!temp.Resize(n))
         return(0);
   return(temp.Max());
  }
//+------------------------------------------------------------------+
//| Returns maximum |X|                                              |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  matrix to process, RowIdx-th row is processed      |
//| OUTPUT PARAMETERS:                                               |
//|   max(|X[RowIdx,i]|)                                             |
//|   zero for N=0                                                   |
//+------------------------------------------------------------------+
double CAblasF::RMaxAbsR(int n,CMatrixDouble &x,int rowidx)
  {
//--- check
   if(!CAp::Assert(x.Rows()>=rowidx,__FUNCTION__": X Rows less RowIdx"))
      return(0);
   if(!CAp::Assert(x.Cols()>=n,__FUNCTION__": X Cols less N"))
      return(0);

   CRowDouble temp=x[rowidx]+0;
   if(temp.Size()!=n)
      if(!temp.Resize(n))
         return(0);
//--- return result
   return(temp.MaxAbs());
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V                                             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  array[N]                                           |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V               |
//+------------------------------------------------------------------+
void CAblasF::RSetV(int n,double v,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(x.Size()==n)
      x.Fill(v);
   else
      for(int j=0; j<n; j++)
         x.Set(j,v);
  }
//+------------------------------------------------------------------+
//| Sets X[OffsX:OffsX+N-1] to V                                     |
//| INPUT PARAMETERS:                                                |
//|   N        -  subvector length                                   |
//|   V        -  value to set                                       |
//|   X        -  array[N]                                           |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  X[OffsX:OffsX+N-1] is replaced by V                |
//+------------------------------------------------------------------+
void CAblasF::RSetVX(int n,double v,CRowDouble &x,int offsx)
  {
//--- check
   if(offsx==0)
     {
      RSetV(n,v,x);
      return;
     }
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   for(int j=0; j<n; j++)
      x.Set(offsx+j,v);
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V                                             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  array[N]                                           |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V               |
//+------------------------------------------------------------------+
void CAblasF::ISetV(int n,int v,CRowInt &x)
  {
   x.Fill(v,0,n);
  }
//+------------------------------------------------------------------+
//| Sets vector X[] to V                                             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   X        -  array[N]                                           |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  leading N elements are replaced by V               |
//+------------------------------------------------------------------+
void CAblasF::BSetV(int n,bool v,bool &x[])
  {
   ArrayFill(x,0,n,v);
  }
//+------------------------------------------------------------------+
//| Sets matrix A[] to V                                             |
//| INPUT PARAMETERS:                                                |
//|   M, N     -  rows/cols count                                    |
//|   V        -  value to set                                       |
//|   A        -  array[M,N]                                         |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading M rows, N cols are replaced by V           |
//+------------------------------------------------------------------+
void CAblasF::RSetM(int m,int n,double v,CMatrixDouble &a)
  {
//--- check
   if(!CAp::Assert(a.Rows()>=m,__FUNCTION__": A Rows less M"))
      return;
   if(!CAp::Assert(a.Cols()>=n,__FUNCTION__": A Cols less N"))
      return;
   a.Fill(v,m,n);
  }
//+------------------------------------------------------------------+
//| Sets row I of A[,] to V                                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  value to set                                       |
//|   A        -  array[N,N] or larger                               |
//|   I        -  row index                                          |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading N elements of I-th row are replaced by V   |
//+------------------------------------------------------------------+
void CAblasF::RSetR(int n,double v,CMatrixDouble &a,int i)
  {
//--- check
   if(!CAp::Assert(a.Rows()>=i,__FUNCTION__": A Rows less I"))
      return;
   if(!CAp::Assert(a.Cols()>=n,__FUNCTION__": A Cols less N"))
      return;

   if(a.Cols()==n)
      a.Row(i,vector<double>::Full(n,v));
   else
      for(int j=0; j<n; j++)
         a.Set(i,j,v);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[]                                         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   Y        -  preallocated array[N]                              |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading N elements are replaced by X               |
//| NOTE: destination and source should NOT overlap                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyV(int n,CRowDouble &x,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(y.Size()<=n)
     {
      y=x;
      if(y.Size()>n)
         y.Resize(n);
     }
   else
      for(int j=0; j<n; j++)
         y.Set(j,x[j]);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[]                                         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   Y        -  preallocated array[N]                              |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  leading N elements are replaced by X               |
//| NOTE: destination and source should NOT overlap                  |
//+------------------------------------------------------------------+
void CAblasF::BCopyV(int n,bool &x[],bool &y[])
  {
   for(int j=0; j<n; j++)
      y[j]=x[j];
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[]                                         |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  source array                                       |
//|   Y        -  preallocated array[N]                              |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  X copied to Y                                      |
//+------------------------------------------------------------------+
void CAblasF::ICopyV(int n,CRowInt &x,CRowInt &y)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   y.Copy(x,0,0,n);
  }
//+------------------------------------------------------------------+
//| Performs copying with multiplication of V*X[] to Y[]             |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  multiplier                                         |
//|   X        -  array[N], source                                   |
//|   Y        -  preallocated array[N]                              |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  array[N], Y = V*X                                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyMulV(int n,double v,CRowDouble &x,CRowDouble &y)
  {
//--- check
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(y.Size()<=n)
     {
      y=x*v+0;
      if(y.Size()>n)
         y.Resize(n);
      return;
     }

   for(int i=0; i<n; i++)
      y.Set(i,v*x[i]);
  }
//+------------------------------------------------------------------+
//| Performs copying with multiplication of V*X[] to Y[I,*]          |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   V        -  multiplier                                         |
//|   X        -  array[N], source                                   |
//|   Y        -  preallocated array[?,N]                            |
//|   RIdx     -  destination row index                              |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  Y[RIdx,...] = V*X                                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyMulVR(int n,double v,CRowDouble &x,
                         CMatrixDouble &y,int ridx)
  {
//--- check
   if(!CAp::Assert(y.Rows()>=ridx,__FUNCTION__": y Rows less RIdx"))
      return;
   if(!CAp::Assert(y.Cols()>=n,__FUNCTION__": Y Cols less N"))
      return;
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   for(int i=0; i<n; i++)
      y.Set(ridx,i,v*x[i]);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to row I of A[,]                               |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  array[N], source                                   |
//|   A        -  preallocated 2D array large enough to store result |
//|   I        -  destination row index                              |
//| OUTPUT PARAMETERS:                                               |
//|   A        -  leading N elements of I-th row are replaced by X   |
//+------------------------------------------------------------------+
void CAblasF::RCopyVR(int n,CRowDouble &x,CMatrixDouble &a,int i)
  {
//--- check
   if(!CAp::Assert(a.Rows()>=i,__FUNCTION__": A Rows less I"))
      return;
   if(!CAp::Assert(a.Cols()>=n,__FUNCTION__": A Cols less N"))
      return;
   if(!CAp::Assert(x.Size()>=n,__FUNCTION__": X size less N"))
      return;

   if(a.Cols()==n && x.Size()==n)
      a.Row(i,x);
   else
      for(int j=0; j<n; j++)
         a.Set(i,j,x[j]);
  }
//+------------------------------------------------------------------+
//| Copies row I of A[,] to vector X[]                               |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   A        -  2D array, source                                   |
//|   I        -  source row index                                   |
//|   X        -  preallocated destination                           |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], destination                              |
//+------------------------------------------------------------------+
void CAblasF::RCopyRV(int n,CMatrixDouble &a,int i,CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(a.Rows()>=i,__FUNCTION__": A Rows less I"))
      return;

   CRowDouble temp=a[i]+0;
   RCopyV(n,temp,x);
  }
//+------------------------------------------------------------------+
//| Copies row I of A[,] to row K of B[,].                           |
//| A[i,...] and B[k,...] may overlap.                               |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   A        -  2D array, source                                   |
//|   I        -  source row index                                   |
//|   B        -  preallocated destination                           |
//|   K        -  destination row index                              |
//| OUTPUT PARAMETERS:                                               |
//|   B        -  row K overwritten                                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyRR(int n,CMatrixDouble &a,int i,CMatrixDouble &b,int k)
  {
//--- check
   if(!CAp::Assert(a.Rows()>=i,__FUNCTION__": A Rows less i"))
      return;
   if(!CAp::Assert(a.Cols()>=n,__FUNCTION__": A Cols less N"))
      return;
   if(!CAp::Assert(b.Rows()>=k,__FUNCTION__": B Rows less K"))
      return;
   if(!CAp::Assert(b.Cols()>=n,__FUNCTION__": B Cols less N"))
      return;

   if(a.Cols()==n && b.Cols()==n)
      b.Row(k,a[i]+0);
   else
      for(int j=0; j<n; j++)
         b.Set(k,j,a.Get(i,j));
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[], extended version                       |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  source array                                       |
//|   OffsX    -  source offset                                      |
//|   Y        -  preallocated array[N]                              |
//|   OffsY    -  destination offset                                 |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  N elements starting from OffsY are replaced        |
//|               by X[OffsX:OffsX+N-1]                              |
//| NOTE: destination and source should NOT overlap                  |
//+------------------------------------------------------------------+
void CAblasF::RCopyVX(int n,CRowDouble &x,int offsx,
                      CRowDouble &y,int offsy)
  {
//--- check
   if(!CAp::Assert(x.Size()>=(n+offsx),__FUNCTION__": X size less N+OffsX"))
      return;
   if(!CAp::Assert(y.Size()>=(n+offsy),__FUNCTION__": Y size less N+OffsY"))
      return;

   for(int j=0; j<n; j++)
      y.Set(offsy+j,x[offsx+j]);
  }
//+------------------------------------------------------------------+
//| Copies vector X[] to Y[], extended version                       |
//| INPUT PARAMETERS:                                                |
//|   N        -  vector length                                      |
//|   X        -  source array                                       |
//|   OffsX    -  source offset                                      |
//|   Y        -  preallocated array[N]                              |
//|   OffsY    -  destination offset                                 |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  N elements starting from OffsY are replaced        |
//|               by X[OffsX:OffsX+N-1]                              |
//| NOTE: destination and source should NOT overlap                  |
//+------------------------------------------------------------------+
void CAblasF::ICopyVX(int n,CRowInt &x,int offsx,CRowInt &y,int offsy)
  {
   y.Copy(x,offsy,offsx,n);
  }
//+------------------------------------------------------------------+
//| Matrix-vector product: y := alpha*op(A)*x + beta*y               |
//| NOTE: this function expects Y to be large enough to store result.|
//|       No automatic preallocation happens for smaller arrays. No  |
//|       integrity checks is performed for sizes of A, x, y.        |
//| INPUT PARAMETERS:                                                |
//|   M        -  number of rows of op(A)                            |
//|   N        -  number of columns of op(A)                         |
//|   Alpha    -  coefficient                                        |
//|   A        -  source matrix                                      |
//|   OpA      -  operation type:                                    |
//|               * OpA=0     =>  op(A) = A                          |
//|               * OpA=1     =>  op(A) = A^T                        |
//|   X        -  input vector, has at least N elements              |
//|   Beta     -  coefficient                                        |
//|   Y        -  preallocated output array, has at least M elements |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  vector which stores result                         |
//| HANDLING OF SPECIAL CASES:                                       |
//|   * if M=0, then subroutine does nothing. It does not even touch |
//|     arrays.                                                      |
//|   * if N=0 or Alpha=0.0, then:                                   |
//|      * if Beta=0, then Y is filled by zeros. A and X are  not    |
//|        referenced at all. Initial values of Y are ignored (we    |
//|        do not multiply Y by zero, we just rewrite it by zeros)   |
//|      * if Beta<>0, then Y is replaced by Beta*Y                  |
//|   * if M>0, N>0, Alpha<>0, but Beta=0, then Y is replaced by     |
//|     A*x; initial state of Y is ignored (rewritten by  A*x,       |
//|     without initial multiplication by zeros).                    |
//+------------------------------------------------------------------+
void CAblasF::RGemV(int m,int n,double alpha,CMatrixDouble &a,int opa,
                    CRowDouble &x,double beta,CRowDouble &y)
  {
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
//--- Properly premultiply Y by Beta.
//--- Quick exit for M=0, N=0 or Alpha=0.
//--- After this block we have M>0, N>0, Alpha<>0.
   if(m<=0)
      return;
   if(beta!=0.0)
      RMulV(m,beta,y);
   else
      RSetV(m,0.0,y);
   if(n<=0 || alpha==0.0)
      return;
//--- Generic code
   switch(opa)
     {
      case 0:
         //--- y += A*x
         for(i=0; i<m ; i++)
           {
            v=RDotVR(n,x,a,i);
            y.Set(i,alpha*v+y[i]);
           }
         break;
      case 1:
         //--- y += A^T*x
         for(i=0; i<n; i++)
           {
            v=alpha*x[i];
            for(j=0; j<m; j++)
               y.Add(j,v*a.Get(i,j));
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| Matrix-vector product: y := alpha*op(A)*x + beta*y               |
//| Here  x,  y,  A  are  subvectors/submatrices  of  larger         |
//| vectors/matrices.                                                |
//| NOTE: this function expects Y to be large enough to store result.|
//|       No automatic preallocation happens for  smaller  arrays.   |
//|       No integrity checks is performed for sizes of A, x, y.     |
//| INPUT PARAMETERS:                                                |
//|   M        -  number of rows of op(A)                            |
//|   N        -  number of columns of op(A)                         |
//|   Alpha    -  coefficient                                        |
//|   A        -  source matrix                                      |
//|   IA       -  submatrix offset (row index)                       |
//|   JA       -  submatrix offset (column index)                    |
//|   OpA      -  operation type:                                    |
//|               * OpA=0     =>  op(A) = A                          |
//|               * OpA=1     =>  op(A) = A^T                        |
//|   X        -  input vector, has at least N+IX elements           |
//|   IX       -  subvector offset                                   |
//|   Beta     -  coefficient                                        |
//|   Y        -  preallocated output array, has at least M+IY       |
//|               elements                                           |
//|   IY       -  subvector offset                                   |
//| OUTPUT PARAMETERS:                                               |
//|   Y        -  vector which stores result                         |
//| HANDLING OF SPECIAL CASES:                                       |
//|   * if M=0, then subroutine does nothing. It does not even       |
//|     touch arrays.                                                |
//|   * if N=0 or Alpha=0.0, then:                                   |
//|      * if Beta=0, then Y is filled by zeros. A and X are  not    |
//|        referenced at all. Initial values of Y are ignored (we    |
//|        do not  multiply Y by zero, we just rewrite it by zeros)  |
//|      * if Beta<>0, then Y is replaced by Beta*Y                  |
//|   * if M>0, N>0, Alpha<>0, but Beta=0, then Y is replaced by A*x;|
//|     initial state of Y is ignored (rewritten by A*x, without     |
//|     initial multiplication by zeros).                            |
//+------------------------------------------------------------------+
void CAblasF::RGemVX(int m,int n,double alpha,CMatrixDouble &a,
                     int ia,int ja,int opa,CRowDouble &x,
                     int ix,double beta,CRowDouble &y,int iy)
  {
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
//--- Properly premultiply Y by Beta.
//--- Quick exit for M=0, N=0 or Alpha=0.
//--- After this block we have M>0, N>0, Alpha<>0.
   if(m<=0)
      return;
   if(beta!=0.0)
      RMulVX(m,beta,y,iy);
   else
      RSetVX(m,0.0,y,iy);
   if(n<=0 || alpha==0.0)
      return;
//--- Generic code
   switch(opa)
     {
      case 0: // y += A*x
         for(i=0; i<m; i++)
           {
            v=0;
            for(j=0; j<n; j++)
               v=v+a.Get(ia+i,ja+j)*x[ix+j];
            y.Add(iy+i,alpha*v);
           }
         break;
      case 1: // y += A^T*x
         for(i=0; i<n; i++)
           {
            v=alpha*x[ix+i];
            for(j=0; j<m; j++)
               y.Add(iy+j,v*a.Get(ia+i,ja+j));
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| Rank-1 correction: A := A + alpha*u*v'                           |
//| NOTE: this function expects A to be large enough to store result.|
//|       No automatic preallocation happens for smaller arrays. No  |
//|       integrity checks is performed for sizes of A, u, v.        |
//| INPUT PARAMETERS:                                                |
//|   M        -  number of rows                                     |
//|   N        -  number of columns                                  |
//|   A        -  target MxN matrix                                  |
//|   Alpha    -  coefficient                                        |
//|   U        -  vector #1                                          |
//|   V        -  vector #2                                          |
//+------------------------------------------------------------------+
void CAblasF::RGer(int m,int n,double alpha,CRowDouble &u,
                   CRowDouble &v,CMatrixDouble &a)
  {
//--- check
   if(m<=0 || n<=0 || alpha==0.0)
      return;

   for(int i=0; i<m; i++)
     {
      double s=alpha*u[i];
      for(int j=0; j<n; j++)
         a.Set(i,j,a.Get(i,j)+s*v[j]);
     }
  }
//+------------------------------------------------------------------+
//| This subroutine solves linear system op(A)*x=b where:            |
//|   * A is NxN upper/lower triangular/unitriangular matrix         |
//|   * X and B are Nx1 vectors                                      |
//|  *"op" may be identity transformation or transposition         |
//| Solution replaces X.                                             |
//| IMPORTANT:                                                       |
//|   * no overflow/underflow/denegeracy tests is performed.         |
//|   * no integrity checks for operand sizes, out-of-bounds accesses|
//|     and so on is performed                                       |
//| INPUT PARAMETERS:                                                |
//|   N        -  matrix size, N>=0                                  |
//|   A        -  matrix, actial matrix is stored                    |
//|               in A[IA:IA+N-1,JA:JA+N-1]                          |
//|   IA       -  submatrix offset                                   |
//|   JA       -  submatrix offset                                   |
//|   IsUpper  -  whether matrix is upper triangular                 |
//|   IsUnit   -  whether matrix is unitriangular                    |
//|   OpType   -  transformation type:                               |
//|               * 0 - no transformation                            |
//|               * 1 - transposition                                |
//|   X        -  right part, actual vector is stored in X[IX:IX+N-1]|
//|   IX       -  offset                                             |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  solution replaces elements X[IX:IX+N-1]            |
//+------------------------------------------------------------------+
void CAblasF::RTrsVX(int n,CMatrixDouble &a,int ia,int ja,
                     bool IsUpper,bool IsUnit,int OpType,
                     CRowDouble &x,int ix)
  {
//--- create variables
   int    i=0;
   int    j=0;
   double v=0;
//--- check
   if(n<=0)
      return;
   switch(OpType)
     {
      case 0:
         if(IsUpper)
           {
            for(i=n-1; i>=0; i--)
              {
               v=x[ix+i];
               for(j=i+1; j<n; j++)
                  v-=a.Get(ia+i,ja+j)*x[ix+j];
               if(!IsUnit)
                  v/=a.Get(ia+i,ja+i);
               x.Set(ix+i,v);
              }
           }
         else
           {
            for(i=0; i<n; i++)
              {
               v=x[ix+i];
               for(j=0; j<i; j++)
                  v-=a.Get(ia+i,ja+j)*x[ix+j];
               if(!IsUnit)
                  v/=a.Get(ia+i,ja+i);
               x.Set(ix+i,v);
              }
           }
         break;
      case 1:
         if(IsUpper)
           {
            for(i=0; i<n; i++)
              {
               v=x[ix+i];
               if(v==0)
                  continue;
               if(!IsUnit)
                 {
                  v/=a.Get(ia+i,ja+i);
                  x.Set(ix+i,v);
                 }
               for(j=i+1; j<=n-1; j++)
                  x.Set(ix+j,x[ix+j]-v*a.Get(ia+i,ja+j));
              }
           }
         else
           {
            for(i=n-1; i>=0; i--)
              {
               v=x[ix+i];
               if(v==0)
                  continue;
               if(!IsUnit)
                 {
                  v/=a.Get(ia+i,ja+i);
                  x.Set(ix+i,v);
                 }
               for(j=0; j<i; j++)
                  x.Set(ix+j,x[ix+j]-v*a.Get(ia+i,ja+j));
              }
           }
         break;
      default:
         CAp::Assert(false,__FUNCTION__": unexpected operation type");
         break;
     }
  }
//+------------------------------------------------------------------+
//| Computing matrix-vector and matrix-matrix                        |
//+------------------------------------------------------------------+
class CBlas
  {
public:
   static double     VectorNorm2(double &x[],const int i1,const int i2);
   static double     VectorNorm2(CRowDouble &x,const int i1,const int i2);
   static int        VectorIdxAbsMax(double &x[],const int i1,const int i2);
   static int        VectorIdxAbsMax(CRowDouble &x,const int i1,const int i2);
   static int        ColumnIdxAbsMax(CMatrixDouble &x,const int i1,const int i2,const int j);
   static int        RowIdxAbsMax(CMatrixDouble &x,const int j1,const int j2,const int i);
   static double     UpperHessenberg1Norm(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,double &work[]);
   static double     UpperHessenberg1Norm(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,CRowDouble &work);
   static void       CopyMatrix(CMatrixDouble &a,const int is1,const int is2,const int js1,const int js2,CMatrixDouble &b,const int id1,const int id2,const int jd1,const int jd2);
   static void       InplaceTranspose(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,double &work[]);
   static void       InplaceTranspose(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,CRowDouble &work);
   static void       CopyAndTranspose(CMatrixDouble &a,const int is1,const int is2,const int js1,const int js2,CMatrixDouble &b,const int id1,const int id2,const int jd1,const int jd2);
   static void       MatrixVectorMultiply(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,const bool trans,double &x[],const int ix1,const int ix2,const double alpha,double &y[],const int iy1,const int iy2,const double beta);
   static void       MatrixVectorMultiply(CMatrixDouble &a,const int i1,const int i2,const int j1,const int j2,const bool trans,CRowDouble &x,const int ix1,const int ix2,const double alpha,CRowDouble &y,const int iy1,const int iy2,const double beta);
   static double     PyThag2(double x,double y);
   static void       MatrixMatrixMultiply(CMatrixDouble &a,const int ai1,const int ai2,const int aj1,const int aj2,const bool transa,CMatrixDouble &b,const int bi1,const int bi2,const int bj1,const int bj2,const bool transb,const double alpha,CMatrixDouble &c,const int ci1,const int ci2,const int cj1,const int cj2,const double beta,double &work[]);
   static void       MatrixMatrixMultiply(CMatrixDouble &a,const int ai1,const int ai2,const int aj1,const int aj2,const bool transa,CMatrixDouble &b,const int bi1,const int bi2,const int bj1,const int bj2,const bool transb,const double alpha,CMatrixDouble &c,const int ci1,const int ci2,const int cj1,const int cj2,const double beta,CRowDouble &work);
  };
//+------------------------------------------------------------------+
//| Vector norm                                                      |
//+------------------------------------------------------------------+
double CBlas::VectorNorm2(double &x[],const int i1,const int i2)
  {
   CRowDouble X=x;
//--- return result
   return(VectorNorm2(X,i1,i2));
  }
//+------------------------------------------------------------------+
//| Vector norm                                                      |
//+------------------------------------------------------------------+
double CBlas::VectorNorm2(CRowDouble &x,const int i1,const int i2)
  {
//--- create variables
   int    n=i2-i1+1;
   int    ix=0;
   double absxi=0;
   double scl=0;
   double ssq=1;
//--- check
   if(n<1)
      return(0);
//--- check
   if(n==1)
      return(MathAbs(x[i1]));
//--- norm
   for(ix=i1; ix<=i2; ix++)
     {
      //--- check
      if(x[ix]!=0.0)
        {
         absxi=MathAbs(x[ix]);
         //--- check
         if(scl<absxi)
           {
            ssq=1+ssq*CMath::Sqr(scl/absxi);
            scl=absxi;
           }
         else
            ssq+=CMath::Sqr(absxi/scl);
        }
     }
//--- return result
   return(scl*MathSqrt(ssq));
  }
//+------------------------------------------------------------------+
//| Internal subroutine                                              |
//+------------------------------------------------------------------+
int CBlas::VectorIdxAbsMax(double &x[],const int i1,const int i2)
  {
   CRowDouble X=x;
   return(VectorIdxAbsMax(X,i1,i2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBlas::VectorIdxAbsMax(CRowDouble &x,const int i1,const int i2)
  {
   int result=i1;
//--- calculation
   for(int i=i1+1; i<=i2; i++)
     {
      //--- check
      if(MathAbs(x[i])>MathAbs(x[result]))
         result=i;
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Internal subroutine                                              |
//+------------------------------------------------------------------+
int CBlas::ColumnIdxAbsMax(CMatrixDouble &x,const int i1,const int i2,const int j)
  {
   CRowDouble temp=x.Col(j)+0;
//--- return result
   return(VectorIdxAbsMax(temp,i1,i2));
  }
//+------------------------------------------------------------------+
//| Internal subroutine                                              |
//+------------------------------------------------------------------+
int CBlas::RowIdxAbsMax(CMatrixDouble &x,const int j1,const int j2,const int i)
  {
   CRowDouble temp=x[i]+0;
//--- return result
   return(VectorIdxAbsMax(temp,j1,j2));
  }
//+------------------------------------------------------------------+
//| Upper Hessenberg norm                                            |
//+------------------------------------------------------------------+
double CBlas::UpperHessenberg1Norm(CMatrixDouble &a,const int i1,
                                   const int i2,const int j1,
                                   const int j2,double &work[])
  {
   CRowDouble Work=work;
   double result=UpperHessenberg1Norm(a,i1,i2,j1,j2,Work);
   Work.ToArray(work);
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CBlas::UpperHessenberg1Norm(CMatrixDouble &a,const int i1,
                                   const int i2,const int j1,
                                   const int j2,CRowDouble &work)
  {
//--- create variables
   double result=0;
   int    i=0;
   int    j=0;
//--- check
   if(!CAp::Assert(i2-i1==j2-j1,__FUNCTION__+": I2-I1!=J2-J1!"))
      return(EMPTY_VALUE);
   for(j=j1; j<=j2; j++)
      work.Set(j,0);
   for(i=i1; i<=i2; i++)
     {
      for(j=MathMax(j1,j1+i-i1-1); j<=j2; j++)
         work.Set(j,work[j]+MathAbs(a.Get(i,j)));
     }
//--- get result
   result=0;
   for(j=j1; j<=j2; j++)
      result=MathMax(result,work[j]);
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Copy matrix                                                      |
//+------------------------------------------------------------------+
void CBlas::CopyMatrix(CMatrixDouble &a,const int is1,const int is2,
                       const int js1,const int js2,CMatrixDouble &b,
                       const int id1,const int id2,const int jd1,const int jd2)
  {
//--- create variables
   int isrc=0;
   int idst=0;
   int i_=0;
   int i1_=0;
//--- check
   if(is1>is2 || js1>js2)
      return;
//--- check
   if(!CAp::Assert(is2-is1==id2-id1,__FUNCTION__+": different sizes!"))
      return;
//--- check
   if(!CAp::Assert(js2-js1==jd2-jd1,__FUNCTION__+": different sizes!"))
      return;
//--- copy
   for(isrc=is1; isrc<=is2; isrc++)
     {
      idst=isrc-is1+id1;
      i1_=js1-jd1;
      for(i_=jd1; i_<=jd2; i_++)
         b.Set(idst,i_,a.Get(isrc,i_+i1_));
     }
  }
//+------------------------------------------------------------------+
//| Matrix transpose                                                 |
//+------------------------------------------------------------------+
void CBlas::InplaceTranspose(CMatrixDouble &a,const int i1,const int i2,
                             const int j1,const int j2,double &work[])
  {
//--- create variables
   int i=0;
   int j=0;
   int ips=0;
   int jps=0;
   int l=0;
   int i_=0;
   int i1_=0;
//--- check
   if(i1>i2 || j1>j2)
      return;
//--- check
   if(!CAp::Assert(i1-i2==j1-j2,__FUNCTION__+": incorrect array size!"))
      return;
   for(i=i1; i<=i2-1; i++)
     {
      //--- change values
      j=j1+i-i1;
      ips=i+1;
      jps=j1+ips-i1;
      l=i2-i;
      i1_=ips-1;
      //--- transpose
      for(i_=1; i_<=l; i_++)
         work[i_]=a.Get(i_+i1_,j);
      i1_=jps-ips;
      for(i_=ips; i_<=i2; i_++)
         a.Set(i_,j,a.Get(i,i_+i1_));
      i1_=1-jps;
      for(i_=jps; i_<=j2; i_++)
         a.Set(i,i_,work[i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| Matrix transpose                                                 |
//+------------------------------------------------------------------+
void CBlas::InplaceTranspose(CMatrixDouble &a,const int i1,const int i2,
                             const int j1,const int j2,CRowDouble &work)
  {
//--- create variables
   int i=0;
   int j=0;
   int ips=0;
   int jps=0;
   int l=0;
   int i_=0;
   int i1_=0;
//--- check
   if(i1>i2 || j1>j2)
      return;
//--- check
   if(!CAp::Assert(i1-i2==j1-j2,__FUNCTION__+": incorrect array size!"))
      return;
   for(i=i1; i<=i2-1; i++)
     {
      //--- change values
      j=j1+i-i1;
      ips=i+1;
      jps=j1+ips-i1;
      l=i2-i;
      i1_=ips-1;
      //--- transpose
      for(i_=1; i_<=l; i_++)
         work.Set(i_,a.Get(i_+i1_,j));
      i1_=jps-ips;
      for(i_=ips; i_<=i2; i_++)
         a.Set(i_,j,a.Get(i,i_+i1_));
      i1_=1-jps;
      for(i_=jps; i_<=j2; i_++)
         a.Set(i,i_,work[i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| Copy and transpose matrix                                        |
//+------------------------------------------------------------------+
void CBlas::CopyAndTranspose(CMatrixDouble &a,const int is1,const int is2,
                             const int js1,const int js2,CMatrixDouble &b,
                             const int id1,const int id2,const int jd1,const int jd2)
  {
//--- create variables
   int isrc=0;
   int jdst=0;
   int i_=0;
   int i1_=0;
//--- check
   if(is1>is2 || js1>js2)
      return;
//--- check
   if(!CAp::Assert(is2-is1==jd2-jd1,__FUNCTION__+": different sizes!"))
      return;
//--- check
   if(!CAp::Assert(js2-js1==id2-id1,__FUNCTION__+": different sizes!"))
      return;
//--- copy and transpose
   for(isrc=is1; isrc<=is2; isrc++)
     {
      jdst=isrc-is1+jd1;
      i1_=js1-id1;
      for(i_=id1; i_<=id2; i_++)
         b.Set(i_,jdst,a.Get(isrc,i_+i1_));
     }
  }
//+------------------------------------------------------------------+
//| Matrix vector multiply                                           |
//+------------------------------------------------------------------+
void CBlas::MatrixVectorMultiply(CMatrixDouble &a,const int i1,const int i2,
                                 const int j1,const int j2,const bool trans,
                                 double &x[],const int ix1,const int ix2,
                                 const double alpha,double &y[],const int iy1,
                                 const int iy2,const double beta)
  {
   CRowDouble X=x;
   CRowDouble Y=y;
   MatrixVectorMultiply(a,i1,i2,j1,j2,trans,X,ix1,ix2,alpha,Y,iy1,iy2,beta);
   Y.ToArray(y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBlas::MatrixVectorMultiply(CMatrixDouble &a,const int i1,const int i2,
                                 const int j1,const int j2,const bool trans,
                                 CRowDouble &x,const int ix1,const int ix2,
                                 const double alpha,CRowDouble &y,const int iy1,
                                 const int iy2,const double beta)
  {
//--- create variables
   int    i=0;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(!trans)
     {
      //--- y := alpha*A*x + beta*y;
      if(i1>i2 || j1>j2)
         return;
      //--- check
      if(!CAp::Assert(j2-j1==ix2-ix1,__FUNCTION__+": A and X dont match!"))
         return;
      //--- check
      if(!CAp::Assert(i2-i1==iy2-iy1,__FUNCTION__+": A and Y dont match!"))
         return;
      //--- beta*y
      if(beta==0.0)
        {
         for(i=iy1; i<=iy2; i++)
            y.Set(i,0);
        }
      else
        {
         for(i_=iy1; i_<=iy2; i_++)
            y.Set(i_,beta*y[i_]);
        }
      //--- alpha*A*x
      for(i=i1; i<=i2; i++)
        {
         i1_=ix1-j1;
         v=0.0;
         for(i_=j1; i_<=j2; i_++)
            v+=a.Get(i,i_)*x[i_+i1_];
         y.Set((iy1+i-i1),(y[iy1+i-i1]+alpha*v));
        }
     }
   else
     {
      //--- y := alpha*A'*x + beta*y;
      if(i1>i2 || j1>j2)
         return;
      //--- check
      if(!CAp::Assert(i2-i1==ix2-ix1,__FUNCTION__+": A and X dont match!"))
         return;
      //--- check
      if(!CAp::Assert(j2-j1==iy2-iy1,__FUNCTION__+": A and Y dont match!"))
         return;
      //--- beta*y
      if(beta==0.0)
        {
         for(i=iy1; i<=iy2; i++)
            y.Set(i,0);
        }
      else
        {
         for(i_=iy1; i_<=iy2; i_++)
            y.Set(i_,beta*y[i_]);
        }
      //--- alpha*A'*x
      for(i=i1; i<=i2; i++)
        {
         v=alpha*x[ix1+i-i1];
         i1_=j1-iy1;
         for(i_=iy1; i_<=iy2; i_++)
            y.Set(i_,(y[i_]+v*a.Get(i,i_+i1_)));
        }
     }
  }
//+------------------------------------------------------------------+
//| Internal subroutine                                              |
//+------------------------------------------------------------------+
double CBlas::PyThag2(double x,double y)
  {
//--- create variables
   double result=0;
   double xabs=MathAbs(x);
   double yabs=MathAbs(y);
   double w=MathMax(xabs,yabs);
   double z=MathMin(xabs,yabs);
//--- check
   if(z==0.0)
      result=w;
   else
      result=w*MathSqrt(1+CMath::Sqr(z/w));
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Matrix matrix multiply                                           |
//+------------------------------------------------------------------+
void CBlas::MatrixMatrixMultiply(CMatrixDouble &a,const int ai1,const int ai2,
                                 const int aj1,const int aj2,const bool transa,
                                 CMatrixDouble &b,const int bi1,const int bi2,
                                 const int bj1,const int bj2,const bool transb,
                                 const double alpha,CMatrixDouble &c,const int ci1,
                                 const int ci2,const int cj1,const int cj2,
                                 const double beta,double &work[])
  {
   CRowDouble Work=work;
   MatrixMatrixMultiply(a,ai1,ai2,aj1,aj2,transa,b,bi1,bi2,bj1,bj2,transb,alpha,c,ci1,ci2,cj1,cj2,beta,Work);
   Work.ToArray(work);
  }
//+------------------------------------------------------------------+
//| Matrix matrix multiply                                           |
//+------------------------------------------------------------------+
void CBlas::MatrixMatrixMultiply(CMatrixDouble &a,const int ai1,const int ai2,
                                 const int aj1,const int aj2,const bool transa,
                                 CMatrixDouble &b,const int bi1,const int bi2,
                                 const int bj1,const int bj2,const bool transb,
                                 const double alpha,CMatrixDouble &c,const int ci1,
                                 const int ci2,const int cj1,const int cj2,
                                 const double beta,CRowDouble &work)
  {
//--- create variables
   int    arows=0;
   int    acols=0;
   int    brows=0;
   int    bcols=0;
   int    crows=0;
   int    ccols=0;
   int    i=0;
   int    j=0;
   int    k=0;
   int    l=0;
   int    r=0;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- Setup
   if(!transa)
     {
      arows=ai2-ai1+1;
      acols=aj2-aj1+1;
     }
   else
     {
      arows=aj2-aj1+1;
      acols=ai2-ai1+1;
     }
//--- check
   if(!transb)
     {
      brows=bi2-bi1+1;
      bcols=bj2-bj1+1;
     }
   else
     {
      brows=bj2-bj1+1;
      bcols=bi2-bi1+1;
     }
//--- check
   if(!CAp::Assert(acols==brows,__FUNCTION__+": incorrect matrix sizes!"))
      return;
//--- check
   if(arows<=0 || acols<=0 || brows<=0 || bcols<=0)
      return;
   crows=arows;
   ccols=bcols;
//--- Test WORK
   i=MathMax(arows,acols);
   i=MathMax(brows,i);
   i=MathMax(i,bcols);
   work.Set(1,0);
   work.Set(i,0);
//--- Prepare C
   if(beta==0.0)
     {
      for(i=ci1; i<=ci2; i++)
         for(j=cj1; j<=cj2; j++)
            c.Set(i,j,0);
     }
   else
     {
      for(i=ci1; i<=ci2; i++)
         for(i_=cj1; i_<=cj2; i_++)
            c.Mul(i,i_,beta);
     }
//--- A*B
   if(!transa && !transb)
     {
      for(l=ai1; l<=ai2; l++)
        {
         for(r=bi1; r<=bi2; r++)
           {
            //--- change values
            v=alpha*a.Get(l,aj1+r-bi1);
            k=ci1+l-ai1;
            i1_=bj1-cj1;
            for(i_=cj1; i_<=cj2; i_++)
               c.Add(k,i_,v*b.Get(r,i_+i1_));
           }
        }
      //--- exit the function
      return;
     }
//--- A*B'
   if(!transa && transb)
     {
      //--- check
      if(arows*acols<brows*bcols)
        {
         for(r=bi1; r<=bi2; r++)
           {
            for(l=ai1; l<=ai2; l++)
              {
               //--- change values
               i1_=bj1-aj1;
               v=0.0;
               for(i_=aj1; i_<=aj2; i_++)
                  v+=a.Get(l,i_)*b.Get(r,i_+i1_);
               c.Add(ci1+l-ai1,cj1+r-bi1,alpha*v);
              }
           }
         //--- exit the function
         return;
        }
      else
        {
         for(l=ai1; l<=ai2; l++)
           {
            for(r=bi1; r<=bi2; r++)
              {
               //--- change values
               i1_=bj1-aj1;
               v=0.0;
               for(i_=aj1; i_<=aj2; i_++)
                  v+=a.Get(l,i_)*b.Get(r,i_+i1_);
               c.Set(ci1+l-ai1,cj1+r-bi1,c.Get(ci1+l-ai1,cj1+r-bi1)+alpha*v);
              }
           }
         //--- exit the function
         return;
        }
     }
//--- A'*B
   if(transa && !transb)
     {
      for(l=aj1; l<=aj2; l++)
        {
         for(r=bi1; r<=bi2; r++)
           {
            //--- change values
            v=alpha*a.Get(ai1+r-bi1,l);
            k=ci1+l-aj1;
            i1_=bj1-cj1;
            for(i_=cj1; i_<=cj2; i_++)
               c.Set(k,i_,c.Get(k,i_)+v*b.Get(r,i_+i1_));
           }
        }
      //--- exit the function
      return;
     }
//--- A'*B'
   if(transa && transb)
     {
      //--- check
      if(arows*acols<brows*bcols)
        {
         for(r=bi1; r<=bi2; r++)
           {
            k=cj1+r-bi1;
            for(i=1; i<=crows; i++)
               work.Set(i,0.0);
            for(l=ai1; l<=ai2; l++)
              {
               //--- change values
               v=alpha*b.Get(r,bj1+l-ai1);
               i1_=aj1-1;
               for(i_=1; i_<=crows; i_++)
                  work.Set(i_,work[i_]+v*a.Get(l,i_+i1_));
              }
            i1_=1-ci1;
            for(i_=ci1; i_<=ci2; i_++)
               c.Set(i_,k,c.Get(i_,k)+work[i_+i1_]);
           }
        }
      else
        {
         for(l=aj1; l<=aj2; l++)
           {
            k=ai2-ai1+1;
            i1_=ai1-1;
            for(i_=1; i_<=k; i_++)
               work.Set(i_,a.Get(i_+i1_,l));
            for(r=bi1; r<=bi2; r++)
              {
               //--- change values
               i1_=bj1-1;
               v=0.0;
               for(i_=1; i_<=k; i_++)
                  v+=work[i_]*b.Get(r,i_+i1_);
               c.Set(ci1+l-aj1,cj1+r-bi1,c.Get(ci1+l-aj1,cj1+r-bi1)+alpha*v);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Work with the Hermitian matrix                                   |
//+------------------------------------------------------------------+
class CHblas
  {
public:
   static void       HermitianMatrixVectorMultiply(CMatrixComplex &a,const bool IsUpper,const int i1,const int i2,complex &x[],complex &alpha,complex &y[]);
   static void       HermitianMatrixVectorMultiply(CMatrixComplex &a,const bool IsUpper,const int i1,const int i2,CRowComplex &x,complex &alpha,CRowComplex &y);
   static void       HermitianRank2Update(CMatrixComplex &a,const bool IsUpper,const int i1,const int i2,complex &x[],complex &y[],complex &t[],complex &alpha);
   static void       HermitianRank2Update(CMatrixComplex &a,const bool IsUpper,const int i1,const int i2,CRowComplex &x,CRowComplex &y,CRowComplex &t,complex &alpha);
  };
//+------------------------------------------------------------------+
//| Multiply                                                         |
//+------------------------------------------------------------------+
void CHblas::HermitianMatrixVectorMultiply(CMatrixComplex &a,const bool IsUpper,
                                           const int i1,const int i2,complex &x[],
                                           complex &alpha,complex &y[])
  {
//--- create variables
   int     i=0;
   int     ba1=0;
   int     ba2=0;
   int     by1=0;
   int     by2=0;
   int     bx1=0;
   int     bx2=0;
   int     n=i2-i1+1;
   int     i_=0;
   int     i1_=0;
   complex v=0;
//--- check
   if(n<=0)
      return;
//--- Let A = L + D + U, where
//---  L is strictly lower triangular (main diagonal is zero)
//---  D is diagonal
//---  U is strictly upper triangular (main diagonal is zero)
//--- A*x = L*x + D*x + U*x
//--- Calculate D*x first
   for(i=i1; i<=i2; i++)
      y[i-i1+1]=a.Get(i,i)*x[i-i1+1];
//--- Add L*x + U*x
   if(IsUpper)
     {
      for(i=i1; i<i2; i++)
        {
         //--- Add L*x to the result
         v=x[i-i1+1];
         by1=i-i1+2;
         by2=n;
         ba1=i+1;
         ba2=i2;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
            y[i_]=y[i_]+v*CMath::Conj(a.Get(i,i_+i1_));
         //--- Add U*x to the result
         bx1=i-i1+2;
         bx2=n;
         ba1=i+1;
         ba2=i2;
         i1_=ba1-bx1;
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y[i-i1+1]=y[i-i1+1]+v;
        }
     }
   else
     {
      for(i=i1+1; i<=i2; i++)
        {
         //--- Add L*x to the result
         bx1=1;
         bx2=i-i1;
         ba1=i1;
         ba2=i-1;
         i1_=ba1-bx1;
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y[i-i1+1]=y[i-i1+1]+v;
         //--- change parameters
         v=x[i-i1+1];
         by1=1;
         by2=i-i1;
         ba1=i1;
         ba2=i-1;
         i1_=ba1-by1;
         //--- Add U*x to the result
         for(i_=by1; i_<=by2; i_++)
            y[i_]=y[i_]+v*CMath::Conj(a.Get(i,i_+i1_));
        }
     }
//--- get result
   for(i_=1; i_<=n; i_++)
      y[i_]=alpha*y[i_];
  }
//+------------------------------------------------------------------+
//| Multiply                                                         |
//+------------------------------------------------------------------+
void CHblas::HermitianMatrixVectorMultiply(CMatrixComplex &a,const bool IsUpper,
                                           const int i1,const int i2,CRowComplex &x,
                                           complex &alpha,CRowComplex &y)
  {
//--- create variables
   int     i=0;
   int     ba1=0;
   int     ba2=0;
   int     by1=0;
   int     by2=0;
   int     bx1=0;
   int     bx2=0;
   int     n=i2-i1+1;
   int     i_=0;
   int     i1_=0;
   complex v=0;
//--- check
   if(n<=0)
      return;
//--- Let A = L + D + U, where
//---  L is strictly lower triangular (main diagonal is zero)
//---  D is diagonal
//---  U is strictly upper triangular (main diagonal is zero)
//--- A*x = L*x + D*x + U*x
//--- Calculate D*x first
   for(i=i1; i<=i2; i++)
      y.Set(i-i1+1,a.Get(i,i)*x[i-i1+1]);
//--- Add L*x + U*x
   if(IsUpper)
     {
      for(i=i1; i<i2; i++)
        {
         //--- Add L*x to the result
         v=x[i-i1+1];
         by1=i-i1+2;
         by2=n;
         ba1=i+1;
         ba2=i2;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
           {
            complex value=y[i_]+v*CMath::Conj(a.Get(i,i_+i1_));
            y.Set(i_,value);
           }
         //--- Add U*x to the result
         bx1=i-i1+2;
         bx2=n;
         ba1=i+1;
         ba2=i2;
         i1_=ba1-bx1;
         v=y[i-i1+1];
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y.Set(i-i1+1,v);
        }
     }
   else
     {
      for(i=i1+1; i<=i2; i++)
        {
         //--- Add L*x to the result
         bx1=1;
         bx2=i-i1;
         ba1=i1;
         ba2=i-1;
         i1_=ba1-bx1;
         v=y[i-i1+1];
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y.Set(i-i1+1,v);
         //--- change parameters
         v=x[i-i1+1];
         by1=1;
         by2=i-i1;
         ba1=i1;
         ba2=i-1;
         i1_=ba1-by1;
         //--- Add U*x to the result
         for(i_=by1; i_<=by2; i_++)
           {
            complex value=y[i_]+v*CMath::Conj(a.Get(i,i_+i1_));
            y.Set(i_,value);
           }
        }
     }
//--- get result
   y*=alpha;
  }
//+------------------------------------------------------------------+
//| Update matrix                                                    |
//+------------------------------------------------------------------+
void CHblas::HermitianRank2Update(CMatrixComplex &a,const bool IsUpper,
                                  const int i1,const int i2,complex &x[],
                                  complex &y[],complex &t[],complex &alpha)
  {
//--- create variables
   int     i=0;
   int     tp1=0;
   int     tp2=0;
   complex v=0;
   int     i_=0;
   int     i1_=0;
//--- check
   if(IsUpper)
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=i+1-i1;
         tp2=i2-i1+1;
         v=alpha*x[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=v*CMath::Conj(y[i_]);
         v=CMath::Conj(alpha)*y[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=t[i_]+v*CMath::Conj(x[i_]);
         i1_=tp1-i;
         //--- change a
         for(i_=i; i_<=i2; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
   else
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=1;
         tp2=i+1-i1;
         v=alpha*x[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=v*CMath::Conj(y[i_]);
         v=CMath::Conj(alpha)*y[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=t[i_]+v*CMath::Conj(x[i_]);
         i1_=tp1-i1;
         //--- change a
         for(i_=i1; i_<=i; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Update matrix                                                    |
//+------------------------------------------------------------------+
void CHblas::HermitianRank2Update(CMatrixComplex &a,const bool IsUpper,
                                  const int i1,const int i2,CRowComplex &x,
                                  CRowComplex &y,CRowComplex &t,complex &alpha)
  {
//--- create variables
   int     i=0;
   int     tp1=0;
   int     tp2=0;
   complex v=0;
   int     i_=0;
   int     i1_=0;
//--- check
   if(IsUpper)
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=i+1-i1;
         tp2=i2-i1+1;
         v=alpha*x[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
           {
            complex value=v*CMath::Conj(y[i_]);
            t.Set(i_,value);
           }
         v=CMath::Conj(alpha)*y[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
           {
            complex value=t[i_]+v*CMath::Conj(x[i_]);
            t.Set(i_,value);
           }
         i1_=tp1-i;
         //--- change a
         for(i_=i; i_<=i2; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
   else
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=1;
         tp2=i+1-i1;
         v=alpha*x[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
           {
            complex value=v*CMath::Conj(y[i_]);
            t.Set(i_,value);
           }
         v=CMath::Conj(alpha)*y[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
           {
            complex value=t[i_]+v*CMath::Conj(x[i_]);
            t.Set(i_,value);
           }
         i1_=tp1-i1;
         //--- change a
         for(i_=i1; i_<=i; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Reflections                                                      |
//+------------------------------------------------------------------+
class CReflections
  {
public:
   static void       GenerateReflection(double &x[],const int n,double &tau);
   static void       GenerateReflection(CRowDouble &x,const int n,double &tau);
   static void       ApplyReflectionFromTheLeft(CMatrixDouble &c,const double tau,const double &v[],const int m1,const int m2,const int n1,const int n2,double &work[]);
   static void       ApplyReflectionFromTheLeft(CMatrixDouble &c,const double tau,const CRowDouble &v,const int m1,const int m2,const int n1,const int n2,CRowDouble &work);
   static void       ApplyReflectionFromTheRight(CMatrixDouble &c,const double tau,const double &v[],const int m1,const int m2,const int n1,const int n2,double &work[]);
   static void       ApplyReflectionFromTheRight(CMatrixDouble &c,const double tau,const CRowDouble &v,const int m1,const int m2,const int n1,const int n2,CRowDouble &work);
  };
//+------------------------------------------------------------------+
//| Generation of an elementary reflection transformation            |
//| The subroutine generates elementary reflection H of order N, so  |
//| that, for a given X, the following equality holds true:          |
//|     ( X(1) )   ( Beta )                                          |
//| H * (  ..  ) = (  0   )                                          |
//|     ( X(n) )   (  0   )                                          |
//| where                                                            |
//|               ( V(1) )                                           |
//| H = 1 - Tau * (  ..  ) * ( V(1), ..., V(n) )                     |
//|               ( V(n) )                                           |
//| where the first component of vector V equals 1.                  |
//| Input parameters:                                                |
//|     X   -   vector. Array whose index ranges within [1..N].      |
//|     N   -   reflection order.                                    |
//| Output parameters:                                               |
//|     X   -   components from 2 to N are replaced with vector V.   |
//|             The first component is replaced with parameter Beta. |
//|     Tau -   scalar value Tau. If X is a null vector, Tau equals  |
//|             0, otherwise 1 <= Tau <= 2.                          |
//| This subroutine is the modification of the DLARFG subroutines    |
//| from the LAPACK library.                                         |
//| MODIFICATIONS:                                                   |
//|     24.12.2005 sign(Alpha) was replaced with an analogous to the |
//|     Fortran SIGN code.                                           |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CReflections::GenerateReflection(double &x[],const int n,
                                      double &tau)
  {
   CRowDouble X=x;
   GenerateReflection(X,n,tau);
   X.ToArray(x);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReflections::GenerateReflection(CRowDouble &x,const int n,
                                      double &tau)
  {
//--- check
   if(n<=1)
     {
      tau=0;
      //--- exit the function
      return;
     }
//--- create variables
   int    j=0;
   double alpha=0;
   double xnorm=0;
   double v=0;
   double beta=0;
   double mx=0;
   double s=0;
   int    i_=0;
//--- Scale if needed (to avoid overflow/underflow during intermediate
//--- calculations).
   for(j=1; j<=n; j++)
      mx=MathMax(MathAbs(x[j]),mx);
   s=1;
//--- check
   if(mx!=0.0)
     {
      //--- check
      if(mx<=CMath::m_minrealnumber/CMath::m_machineepsilon)
        {
         //--- change parameters
         s=CMath::m_minrealnumber/CMath::m_machineepsilon;
         v=1/s;
         //--- change x
         CAblasF::RMulVX(n,v,x,1);
         mx=mx*v;
        }
      else
        {
         //--- check
         if(mx>=CMath::m_maxrealnumber*CMath::m_machineepsilon)
           {
            //--- change parameters
            s=CMath::m_maxrealnumber*CMath::m_machineepsilon;
            v=1/s;
            //--- change x
            CAblasF::RMulVX(n,v,x,1);
            mx=mx*v;
           }
        }
     }
//--- XNORM = DNRM2( N-1, X, INCX )
   alpha=x[1];
   xnorm=0;
//--- check
   if(mx!=0.0)
     {
      for(j=2; j<=n; j++)
         xnorm=xnorm+CMath::Sqr(x[j]/mx);
      xnorm=MathSqrt(xnorm)*mx;
     }
//--- check
   if(xnorm==0.0)
     {
      //--- H = I
      tau=0;
      x.Set(1,x[1]*s);
      //--- exit the function
      return;
     }
//--- general case
   mx=MathMax(MathAbs(alpha),MathAbs(xnorm));
   beta=-(mx*MathSqrt(CMath::Sqr(alpha/mx)+CMath::Sqr(xnorm/mx)));
//--- check
   if(alpha<0.0)
      beta=-beta;
//--- change parameters
   tau=(beta-alpha)/beta;
   v=1/(alpha-beta);
//--- change x
   CAblasF::RMulVX(n-1,v,x,2);
//--- Scale back outputs
   x.Set(1,beta*s);
  }
//+------------------------------------------------------------------+
//| Application of an elementary reflection to a rectangular matrix  |
//| of size MxN                                                      |
//| The algorithm pre-multiplies the matrix by an elementary         |
//| reflection transformation which is given by column V and scalar  |
//| Tau (see the description of the GenerateReflection procedure).   |
//| Not the whole matrix but only a part of it is transformed (rows  |
//| from M1 to M2, columns from N1 to N2). Only the elements of this |
//| submatrix are changed.                                           |
//| Input parameters:                                                |
//|     C       -   matrix to be transformed.                        |
//|     Tau     -   scalar defining the transformation.              |
//|     V       -   column defining the transformation.              |
//|                 Array whose index ranges within [1..M2-M1+1].    |
//|     M1, M2  -   range of rows to be transformed.                 |
//|     N1, N2  -   range of columns to be transformed.              |
//|     WORK    -   working array whose indexes goes from N1 to N2.  |
//| Output parameters:                                               |
//|     C       -   the result of multiplying the input matrix C by  |
//|                 the transformation matrix which is given by Tau  |
//|                 and V. If N1>N2 or M1>M2, C is not modified.     |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CReflections::ApplyReflectionFromTheLeft(CMatrixDouble &c,const double tau,
                                              const double &v[],const int m1,
                                              const int m2,const int n1,
                                              const int n2,double &work[])
  {
//--- check
   if(tau==0.0 || n1>n2 || m1>m2)
      return;
//--- create variables
   double t=0;
   int    i=0;
   int    vm=0;
   int    i_=0;
//--- w := C' * v
   vm=m2-m1+1;
   for(i=n1; i<=n2; i++)
      work[i]=0;
   for(i=m1; i<=m2; i++)
     {
      t=v[i+1-m1];
      //--- change array
      for(i_=n1; i_<=n2; i_++)
         work[i_]+=t*c[i][i_];
     }
//--- C := C - tau * v * w'
   for(i=m1; i<=m2; i++)
     {
      t=v[i-m1+1]*tau;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c[i][i_]-t*work[i_]);
     }
  }
//+------------------------------------------------------------------+
//| Application of an elementary reflection to a rectangular matrix  |
//| of size MxN                                                      |
//| The algorithm post-multiplies the matrix by an elementary        |
//| reflection transformation which is given by column V and scalar  |
//| Tau (see the description of the GenerateReflection procedure).   |
//| Not the whole matrix but only a part of it is transformed (rows  |
//| from M1 to M2, columns from N1 to N2). Only the elements of this |
//| submatrix are changed.                                           |
//| Input parameters:                                                |
//|     C       -   matrix to be transformed.                        |
//|     Tau     -   scalar defining the transformation.              |
//|     V       -   column defining the transformation.              |
//|                 Array whose index ranges within [1..N2-N1+1].    |
//|     M1, M2  -   range of rows to be transformed.                 |
//|     N1, N2  -   range of columns to be transformed.              |
//|     WORK    -   working array whose indexes goes from M1 to M2.  |
//| Output parameters:                                               |
//|     C       -   the result of multiplying the input matrix C by  |
//|                 the transformation matrix which is given by Tau  |
//|                 and V. If N1>N2 or M1>M2, C is not modified.     |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CReflections::ApplyReflectionFromTheRight(CMatrixDouble &c,const double tau,
                                               const double &v[],const int m1,
                                               const int m2,const int n1,
                                               const int n2,double &work[])
  {
   CRowDouble V=v;
   CRowDouble Work=work;
   ApplyReflectionFromTheRight(c,tau,V,m1,m2,n1,n2,Work);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReflections::ApplyReflectionFromTheRight(CMatrixDouble &c,const double tau,
                                               const CRowDouble &v,const int m1,
                                               const int m2,const int n1,
                                               const int n2,CRowDouble &work)
  {
//--- check
   if(tau==0.0 || n1>n2 || m1>m2)
      return;
//--- create variables
   double t=0;
   int    i=0;
   int    vm=n2-n1+1;
   int    i_=0;
   int    i1_=0;
//--- change matrix
   for(i=m1; i<=m2; i++)
     {
      i1_=1-n1;
      t=0.0;
      //--- calculation parameters
      for(i_=n1; i_<=n2; i_++)
         t+=c[i][i_]*v[i_+i1_];
      t=t*tau;
      i1_=1-n1;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c[i][i_]-t*v[i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| Complex reflections                                              |
//+------------------------------------------------------------------+
class CComplexReflections
  {
public:
   static void       ComplexGenerateReflection(complex &x[],const int n,complex &tau);
   static void       ComplexGenerateReflection(CRowComplex &x,const int n,complex &tau);
   static void       ComplexApplyReflectionFromTheLeft(CMatrixComplex &c,complex tau,complex &v[],const int m1,const int m2,const int n1,const int n2,complex &work[]);
   static void       ComplexApplyReflectionFromTheLeft(CMatrixComplex &c,complex tau,CRowComplex &v,const int m1,const int m2,const int n1,const int n2,CRowComplex &work);
   static void       ComplexApplyReflectionFromTheRight(CMatrixComplex &c,complex tau,complex &v[],const int m1,const int m2,const int n1,const int n2,complex &work[]);
   static void       ComplexApplyReflectionFromTheRight(CMatrixComplex &c,complex tau,CRowComplex &v,const int m1,const int m2,const int n1,const int n2,CRowComplex &work);
  };
//+------------------------------------------------------------------+
//| Generation of an elementary complex reflection transformation    |
//| The subroutine generates elementary complex reflection H of      |
//| order N, so that, for a given X, the following equality holds    |
//| true:                                                            |
//|      ( X(1) )   ( Beta )                                         |
//| H' * (  ..  ) = (  0   ),   H'*H = I,   Beta is a real number    |
//|      ( X(n) )   (  0   )                                         |
//| where                                                            |
//|               ( V(1) )                                           |
//| H = 1 - Tau * (  ..  ) * ( conj(V(1)), ..., conj(V(n)) )         |
//|               ( V(n) )                                           |
//| where the first component of vector V equals 1.                  |
//| Input parameters:                                                |
//|     X   -   vector. Array with elements [1..N].                  |
//|     N   -   reflection order.                                    |
//| Output parameters:                                               |
//|     X   -   components from 2 to N are replaced by vector V.     |
//|             The first component is replaced with parameter Beta. |
//|     Tau -   scalar value Tau.                                    |
//| This subroutine is the modification of CLARFG subroutines  from  |
//| the LAPACK library. It has similar functionality except for the  |
//| fact that it  doesn?t handle errors when intermediate results    |
//| cause an overflow.                                               |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexGenerateReflection(complex &x[],
                                                    const int n,
                                                    complex &tau)
  {
//--- check
   if(n<=0)
     {
      tau=0;
      //--- exit the function
      return;
     }
//--- create variables
   int     j=0;
   complex alpha=0;
   double  alphi=0;
   double  alphr=0;
   double  beta=0;
   double  xnorm=0;
   double  mx=0;
   complex t=0;
   double  s=1;
   complex v=0;
   int     i_=0;
   complex One(1,0);
//--- Scale if needed (to avoid overflow/underflow during intermediate
//--- calculations).
   for(j=1; j<=n; j++)
      mx=MathMax(CMath::AbsComplex(x[j]),mx);
//--- check
   if(mx!=0)
     {
      //--- check
      if(mx<1)
        {
         s=MathSqrt(CMath::m_minrealnumber);
         v=1/s;
         //--- change x
         for(i_=1; i_<=n; i_++)
            x[i_]=v*x[i_];
        }
      else
        {
         s=MathSqrt(CMath::m_maxrealnumber);
         v=1/s;
         //--- change x
         for(i_=1; i_<=n; i_++)
            x[i_]=v*x[i_];
        }
     }
//--- calculate
   alpha=x[1];
   mx=0;
   for(j=2; j<=n; j++)
      mx=MathMax(CMath::AbsComplex(x[j]),mx);
   xnorm=0;
//--- check
   if(mx!=0)
     {
      for(j=2; j<=n; j++)
        {
         t=x[j]/mx;
         xnorm=xnorm+(t*CMath::Conj(t)).real;
        }
      xnorm=MathSqrt(xnorm)*mx;
     }
//--- change parameters
   alphr=alpha.real;
   alphi=alpha.imag;
//--- check
   if((xnorm==0) && (alphi==0))
     {
      tau=0;
      x[1]=x[1]*s;
      //--- exit the function
      return;
     }
//--- change parameters
   mx=MathMax(MathAbs(alphr),MathAbs(alphi));
   mx=MathMax(mx,MathAbs(xnorm));
   beta=-(mx*MathSqrt(CMath::Sqr(alphr/mx)+CMath::Sqr(alphi/mx)+CMath::Sqr(xnorm/mx)));
//--- check
   if(alphr<0)
      beta=-beta;
//--- change parameters
   tau.real=(beta-alphr)/beta;
   tau.imag=-(alphi/beta);
   alpha=One/(alpha-beta);
//--- check
   if(n>1)
     {
      //--- change x
      for(i_=2; i_<=n; i_++)
         x[i_]=alpha*x[i_];
     }
   alpha=beta;
   x[1]=alpha;
//--- Scale back
   x[1]=x[1]*s;
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexGenerateReflection(CRowComplex &x,
                                                    const int n,
                                                    complex &tau)
  {
//--- check
   if(n<=0)
     {
      tau=0;
      //--- exit the function
      return;
     }
//--- create variables
   int     j=0;
   complex alpha=0;
   double  alphi=0;
   double  alphr=0;
   double  beta=0;
   double  xnorm=0;
   double  mx=0;
   complex t=0;
   double  s=1;
   complex v=0;
   int     i_=0;
   complex One(1,0);
//--- Scale if needed (to avoid overflow/underflow during intermediate
//--- calculations).
   for(j=1; j<=n; j++)
      mx=MathMax(CMath::AbsComplex(x[j]),mx);
//--- check
   if(mx!=0)
     {
      //--- check
      if(mx<1)
         s=MathSqrt(CMath::m_minrealnumber);
      else
         s=MathSqrt(CMath::m_maxrealnumber);
      v=1/s;
      //--- change x
      for(i_=1; i_<=n; i_++)
         x.Set(i_,v*x[i_]);
     }
//--- calculate
   alpha=x[1];
   mx=0;
   for(j=2; j<=n; j++)
      mx=MathMax(CMath::AbsComplex(x[j]),mx);
   xnorm=0;
//--- check
   if(mx!=0)
     {
      for(j=2; j<=n; j++)
        {
         t=x[j]/mx;
         xnorm+=(t*CMath::Conj(t)).real;
        }
      xnorm=MathSqrt(xnorm)*mx;
     }
//--- change parameters
   alphr=alpha.real;
   alphi=alpha.imag;
//--- check
   if((xnorm==0) && (alphi==0))
     {
      tau=0;
      x.Mul(1,s);
      //--- exit the function
      return;
     }
//--- change parameters
   mx=MathMax(MathAbs(alphr),MathAbs(alphi));
   mx=MathMax(mx,MathAbs(xnorm));
   beta=-(mx*MathSqrt(CMath::Sqr(alphr/mx)+CMath::Sqr(alphi/mx)+CMath::Sqr(xnorm/mx)));
//--- check
   if(alphr<0)
      beta=-beta;
//--- change parameters
   tau.real=(beta-alphr)/beta;
   tau.imag=-(alphi/beta);
   alpha=One/(alpha-beta);
//--- check
   if(n>1)
     {
      //--- change x
      for(i_=2; i_<=n; i_++)
         x.Mul(i_,alpha);
     }
   alpha=beta;
//--- Scale back
   x.Set(1,alpha*s);
  }
//+------------------------------------------------------------------+
//| Application of an elementary reflection to a rectangular matrix  |
//| of size MxN                                                      |
//| The  algorithm  pre-multiplies  the  matrix  by  an  elementary  |
//| reflection transformation  which  is  given  by  column  V  and  |
//| scalar  Tau (see the description of the GenerateReflection). Not |
//| the whole matrix  but  only  a part of it is transformed (rows   |
//| from M1 to M2, columns from N1 to N2). Only the elements of this |
//| submatrix are changed.                                           |
//| Note: the matrix is multiplied by H, not by H'.   If  it  is     |
//| required  to multiply the matrix by H', it is necessary to pass  |
//| Conj(Tau) instead of Tau.                                        |
//| Input parameters:                                                |
//|     C       -   matrix to be transformed.                        |
//|     Tau     -   scalar defining transformation.                  |
//|     V       -   column defining transformation.                  |
//|                 Array whose index ranges within [1..M2-M1+1]     |
//|     M1, M2  -   range of rows to be transformed.                 |
//|     N1, N2  -   range of columns to be transformed.              |
//|     WORK    -   working array whose index goes from N1 to N2.    |
//| Output parameters:                                               |
//|     C       -   the result of multiplying the input matrix C by  |
//|                 the transformation matrix which is given by Tau  |
//|                 and V. If N1>N2 or M1>M2, C is not modified.     |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexApplyReflectionFromTheLeft(CMatrixComplex &c,
                                                            complex tau,
                                                            complex &v[],
                                                            const int m1,
                                                            const int m2,
                                                            const int n1,
                                                            const int n2,
                                                            complex &work[])
  {
//--- check
   if(tau==0 || n1>n2 || m1>m2)
      return;
//--- create variables
   complex t=0;
   int     i=0;
   int     vm=0;
   int     i_=0;
//--- w := C^T * conj(v)
   vm=m2-m1+1;
   for(i=n1; i<=n2; i++)
      work[i]=0;
   for(i=m1; i<=m2; i++)
     {
      t=CMath::Conj(v[i+1-m1]);
      for(i_=n1; i_<=n2; i_++)
         work[i_]=work[i_]+t*c.Get(i,i_);
     }
//--- C := C - tau * v * w^T
   for(i=m1; i<=m2; i++)
     {
      t=v[i-m1+1]*tau;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c.Get(i,i_)-t*work[i_]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexApplyReflectionFromTheLeft(CMatrixComplex &c,
                                                            complex tau,
                                                            CRowComplex &v,
                                                            const int m1,
                                                            const int m2,
                                                            const int n1,
                                                            const int n2,
                                                            CRowComplex &work)
  {
//--- check
   if(tau==0 || n1>n2 || m1>m2)
      return;
//--- create variables
   complex t=0;
   int     i=0;
   int     vm=0;
   int     i_=0;
//--- w := C^T * conj(v)
   vm=m2-m1+1;
   for(i=n1; i<=n2; i++)
      work.Set(i,0.0);
   for(i=m1; i<=m2; i++)
     {
      t=CMath::Conj(v[i+1-m1]);
      for(i_=n1; i_<=n2; i_++)
         work.Set(i_,work[i_]+t*c.Get(i,i_));
     }
//--- C := C - tau * v * w^T
   for(i=m1; i<=m2; i++)
     {
      t=v[i-m1+1]*tau;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c.Get(i,i_)-t*work[i_]);
     }
  }
//+------------------------------------------------------------------+
//| Application of an elementary reflection to a rectangular matrix  |
//| of size MxN                                                      |
//| The  algorithm  post-multiplies  the  matrix  by  an elementary  |
//| reflection transformation  which  is  given  by  column  V  and  |
//| scalar  Tau (see the description  of  the  GenerateReflection).  |
//| Not the whole matrix but only a part  of  it  is  transformed    |
//| (rows from M1 to M2, columns from N1 to N2). Only the elements   |
//| of this submatrix are changed.                                   |
//| Input parameters:                                                |
//|     C       -   matrix to be transformed.                        |
//|     Tau     -   scalar defining transformation.                  |
//|     V       -   column defining transformation.                  |
//|                 Array whose index ranges within [1..N2-N1+1]     |
//|     M1, M2  -   range of rows to be transformed.                 |
//|     N1, N2  -   range of columns to be transformed.              |
//|     WORK    -   working array whose index goes from M1 to M2.    |
//| Output parameters:                                               |
//|     C       -   the result of multiplying the input matrix C by  |
//|                 the transformation matrix which is given by Tau  |
//|                 and V. If N1>N2 or M1>M2, C is not modified.     |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      September 30, 1994                                          |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexApplyReflectionFromTheRight(CMatrixComplex &c,
                                                             complex tau,
                                                             complex &v[],
                                                             const int m1,
                                                             const int m2,
                                                             const int n1,
                                                             const int n2,
                                                             complex &work[])
  {
//--- check
   if(tau==0 || n1>n2 || m1>m2)
      return;
//--- create variables
   complex t=0;
   int     i=0;
   int     vm=0;
   int     i_=0;
   int     i1_=0;
   vector<complex> tempV;
//--- w := C * v
   vm=n2-n1+1;
   for(i=m1; i<=m2; i++)
     {
      i1_=1-n1;
      t=0.0;
      //--- change values
      for(i_=n1; i_<=n2; i_++)
         t+=c.Get(i,i_)*v[i_+i1_];
      work[i]=t;
     }
//--- C := C - w * conj(v^T)
   tempV.Init(vm+1);
   for(i_=1; i_<=vm; i_++)
      tempV[i_]=CMath::Conj(v[i_]);
//--- get result
   for(i=m1; i<=m2; i++)
     {
      t=work[i]*tau;
      i1_=1-n1;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c.Get(i,i_)-t*tempV[i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplexReflections::ComplexApplyReflectionFromTheRight(CMatrixComplex &c,
                                                             complex tau,
                                                             CRowComplex &v,
                                                             const int m1,
                                                             const int m2,
                                                             const int n1,
                                                             const int n2,
                                                             CRowComplex &work)
  {
//--- check
   if(tau==0 || n1>n2 || m1>m2)
      return;
//--- create variables
   complex t=0;
   int     i=0;
   int     vm=0;
   int     i_=0;
   int     i1_=0;
   vector<complex> tempV;
//--- w := C * v
   vm=n2-n1+1;
   for(i=m1; i<=m2; i++)
     {
      i1_=1-n1;
      t=0.0;
      //--- change values
      for(i_=n1; i_<=n2; i_++)
         t+=c.Get(i,i_)*v[i_+i1_];
      work.Set(i,t);
     }
//--- C := C - w * conj(v^T)
   tempV.Init(vm+1);
   for(i_=1; i_<=vm; i_++)
      tempV[i_]=CMath::Conj(v[i_]);
//--- get result
   for(i=m1; i<=m2; i++)
     {
      t=work[i]*tau;
      i1_=1-n1;
      for(i_=n1; i_<=n2; i_++)
         c.Set(i,i_,c.Get(i,i_)-t*tempV[i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| Work with the symmetric matrix                                   |
//+------------------------------------------------------------------+
class CSblas
  {
public:
   static void       SymmetricMatrixVectorMultiply(const CMatrixDouble &a,const bool IsUpper,const int i1,const int i2,const double &x[],const double alpha,double &y[]);
   static void       SymmetricMatrixVectorMultiply(const CMatrixDouble &a,const bool IsUpper,const int i1,const int i2,const CRowDouble &x,const double alpha,CRowDouble &y);
   static void       SymmetricRank2Update(CMatrixDouble &a,const bool IsUpper,const int i1,const int i2,const double &x[],const double &y[],double &t[],const double alpha);
   static void       SymmetricRank2Update(CMatrixDouble &a,const bool IsUpper,const int i1,const int i2,const CRowDouble &x,const CRowDouble  &y,CRowDouble &t,const double alpha);
  };
//+------------------------------------------------------------------+
//| Multiply                                                         |
//+------------------------------------------------------------------+
void CSblas::SymmetricMatrixVectorMultiply(const CMatrixDouble &a,
                                           const bool IsUpper,
                                           const int i1,const int i2,
                                           const double &x[],
                                           const double alpha,
                                           double &y[])
  {
//--- create variables
   int    i=0;
   int    ba1=0;
   int    by1=0;
   int    by2=0;
   int    bx1=0;
   int    bx2=0;
   int    n=i2-i1+1;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(n<=0)
      return;
//--- Let A = L + D + U, where
//---  L is strictly lower triangular (main diagonal is zero)
//---  D is diagonal
//---  U is strictly upper triangular (main diagonal is zero)
//--- A*x = L*x + D*x + U*x
//--- Calculate D*x first
   for(i=i1; i<=i2; i++)
      y[i-i1+1]=a.Get(i,i)*x[i-i1+1];
//--- Add L*x + U*x
   if(IsUpper)
     {
      for(i=i1; i<i2; i++)
        {
         //--- Add L*x to the result
         v=x[i-i1+1];
         by1=i-i1+2;
         by2=n;
         ba1=i+1;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
            y[i_]=y[i_]+v*a.Get(i,i_+i1_);
         //--- Add U*x to the result
         bx1=by1;
         bx2=n;
         i1_=ba1-bx1;
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y[i-i1+1]=y[i-i1+1]+v;
        }
     }
   else
     {
      for(i=i1+1; i<=i2; i++)
        {
         //--- Add L*x to the result
         bx1=1;
         bx2=i-i1;
         ba1=i1;
         i1_=(ba1)-(bx1);
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y[i-i1+1]=y[i-i1+1]+v;
         //--- Add U*x to the result
         v=x[i-i1+1];
         by1=1;
         by2=bx2;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
            y[i_]=y[i_]+v*a.Get(i,i_+i1_);
        }
     }
//--- get result
   for(i_=1; i_<=n; i_++)
      y[i_]=alpha*y[i_];
  }
//+------------------------------------------------------------------+
//| Multiply                                                         |
//+------------------------------------------------------------------+
void CSblas::SymmetricMatrixVectorMultiply(const CMatrixDouble &a,
                                           const bool IsUpper,
                                           const int i1,const int i2,
                                           const CRowDouble &x,
                                           const double alpha,
                                           CRowDouble &y)
  {
//--- create variables
   int    i=0;
   int    ba1=0;
   int    by1=0;
   int    by2=0;
   int    bx1=0;
   int    bx2=0;
   int    n=i2-i1+1;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(n<=0)
      return;
//--- Let A = L + D + U, where
//---  L is strictly lower triangular (main diagonal is zero)
//---  D is diagonal
//---  U is strictly upper triangular (main diagonal is zero)
//--- A*x = L*x + D*x + U*x
//--- Calculate D*x first
   for(i=i1; i<=i2; i++)
      y.Set(i-i1+1,a.Get(i,i)*x[i-i1+1]);
//--- Add L*x + U*x
   if(IsUpper)
     {
      for(i=i1; i<i2; i++)
        {
         //--- Add L*x to the result
         v=x[i-i1+1];
         by1=i-i1+2;
         by2=n;
         ba1=i+1;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
            y.Set(i_,y[i_]+v*a.Get(i,i_+i1_));
         //--- Add U*x to the result
         bx1=by1;
         bx2=n;
         i1_=ba1-bx1;
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y.Set(i-i1+1,y[i-i1+1]+v);
        }
     }
   else
     {
      for(i=i1+1; i<=i2; i++)
        {
         //--- Add L*x to the result
         bx1=1;
         bx2=i-i1;
         ba1=i1;
         i1_=(ba1)-(bx1);
         v=0.0;
         for(i_=bx1; i_<=bx2; i_++)
            v+=x[i_]*a.Get(i,i_+i1_);
         y.Set(i-i1+1,y[i-i1+1]+v);
         //--- Add U*x to the result
         v=x[i-i1+1];
         by1=1;
         by2=bx2;
         i1_=ba1-by1;
         for(i_=by1; i_<=by2; i_++)
            y.Set(i_,y[i_]+v*a.Get(i,i_+i1_));
        }
     }
//--- get result
   for(i_=1; i_<=n; i_++)
      y.Set(i_,alpha*y[i_]);
  }
//+------------------------------------------------------------------+
//| Update matrix                                                    |
//+------------------------------------------------------------------+
void CSblas::SymmetricRank2Update(CMatrixDouble &a,const bool IsUpper,
                                  const int i1,const int i2,
                                  const double &x[],const double &y[],
                                  double &t[],const double alpha)
  {
//--- create variables
   int    i=0;
   int    tp1=0;
   int    tp2=0;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(IsUpper)
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=i+1-i1;
         tp2=i2-i1+1;
         v=x[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=v*y[i_];
         v=y[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=(t[i_]+v*x[i_])*alpha;
         i1_=tp1-i;
         //--- change a
         for(i_=i; i_<=i2; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
   else
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=1;
         tp2=i+1-i1;
         v=x[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=v*y[i_];
         v=y[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t[i_]=(t[i_]+v*x[i_])*alpha;
         i1_=tp1-i1;
         //--- change a
         for(i_=i1; i_<=i; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Update matrix                                                    |
//+------------------------------------------------------------------+
void CSblas::SymmetricRank2Update(CMatrixDouble &a,const bool IsUpper,
                                  const int i1,const int i2,
                                  const CRowDouble &x,const CRowDouble &y,
                                  CRowDouble &t,const double alpha)
  {
//--- create variables
   int    i=0;
   int    tp1=0;
   int    tp2=0;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(IsUpper)
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=i+1-i1;
         tp2=i2-i1+1;
         v=x[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t.Set(i_,v*y[i_]);
         v=y[tp1];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t.Set(i_,(t[i_]+v*x[i_])*alpha);
         i1_=tp1-i;
         //--- change a
         for(i_=i; i_<=i2; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
   else
     {
      for(i=i1; i<=i2; i++)
        {
         //--- change values
         tp1=1;
         tp2=i+1-i1;
         v=x[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t.Set(i_,v*y[i_]);
         v=y[tp2];
         //--- change t
         for(i_=tp1; i_<=tp2; i_++)
            t.Set(i_,(t[i_]+v*x[i_])*alpha);
         i1_=tp1-i1;
         //--- change a
         for(i_=i1; i_<=i; i_++)
            a.Set(i,i_,a.Get(i,i_)+t[i_+i1_]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Rotations                                                        |
//+------------------------------------------------------------------+
class CRotations
  {
public:
   static void       ApplyRotationsFromTheLeft(const bool isforward,const int m1,const int m2,const int n1,const int n2,double &c[],double &s[],CMatrixDouble &a,double &work[]);
   static void       ApplyRotationsFromTheLeft(const bool isforward,const int m1,const int m2,const int n1,const int n2,CRowDouble &c,CRowDouble &s,CMatrixDouble &a,CRowDouble &work);
   static void       ApplyRotationsFromTheRight(const bool isforward,const int m1,const int m2,const int n1,const int n2,double &c[],double &s[],CMatrixDouble &a,double &work[]);
   static void       ApplyRotationsFromTheRight(const bool isforward,const int m1,const int m2,const int n1,const int n2,CRowDouble &c,CRowDouble &s,CMatrixDouble &a,CRowDouble &work);
   static void       GenerateRotation(const double f,const double g,double &cs,double &sn,double &r);
  };
//+------------------------------------------------------------------+
//| Application of a sequence of  elementary rotations to a matrix   |
//| The algorithm pre-multiplies the matrix by a sequence of rotation|
//| transformations which is given by arrays C and S. Depending on   |
//| the value of the IsForward parameter either 1 and 2, 3 and 4 and |
//| so on (if IsForward=true) rows are rotated, or the rows N and    |
//| N-1, N-2 and N-3 and so on, are rotated.                         |
//| Not the whole matrix but only a part of it is transformed (rows  |
//| from M1 to M2, columns from N1 to N2). Only the elements of this |
//| submatrix are changed.                                           |
//| Input parameters:                                                |
//|     IsForward   -   the sequence of the rotation application.    |
//|     M1,M2       -   the range of rows to be transformed.         |
//|     N1, N2      -   the range of columns to be transformed.      |
//|     C,S         -   transformation coefficients.                 |
//|                     Array whose index ranges within [1..M2-M1].  |
//|     A           -   processed matrix.                            |
//|     WORK        -   working array whose index ranges within      |
//|                     [N1..N2].                                    |
//| Output parameters:                                               |
//|     A           -   transformed matrix.                          |
//| Utility subroutine.                                              |
//+------------------------------------------------------------------+
void CRotations::ApplyRotationsFromTheLeft(const bool isforward,
                                           const int m1,const int m2,
                                           const int n1,const int n2,
                                           double &c[],double &s[],
                                           CMatrixDouble &a,double &work[])
  {
   CRowDouble C=c;
   CRowDouble S=s;
   CRowDouble Work=work;
   ApplyRotationsFromTheLeft(isforward,m1,m2,n1,n2,C,S,a,Work);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRotations::ApplyRotationsFromTheLeft(const bool isforward,
                                           const int m1,const int m2,
                                           const int n1,const int n2,
                                           CRowDouble &c,CRowDouble &s,
                                           CMatrixDouble &a,CRowDouble &work)
  {
//--- create variables
   int    j=0;
   int    jp1=0;
   double ctemp=0;
   double stemp=0;
   double temp=0;
   int    i_=0;
//--- check
   if(m1>m2 || n1>n2)
      return;
//--- Form  P * A
   if(isforward)
     {
      //--- check
      if(n1!=n2)
        {
         //--- Common case: N1<>N2
         for(j=m1; j<m2; j++)
           {
            ctemp=c[j-m1+1];
            stemp=s[j-m1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               jp1=j+1;
               //--- prepare array
               for(i_=n1; i_<=n2; i_++)
                  work.Set(i_,(ctemp*a.Get(jp1,i_)-stemp*a.Get(j,i_)));
               //--- get result
               for(i_=n1; i_<=n2; i_++)
                  a.Set(j,i_,(ctemp*a.Get(j,i_)+stemp*a[jp1][i_]));
               for(i_=n1; i_<=n2; i_++)
                  a.Set(jp1,i_,work[i_]);
              }
           }
        }
      else
        {
         //--- Special case: N1=N2
         for(j=m1; j<m2; j++)
           {
            ctemp=c[j-m1+1];
            stemp=s[j-m1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               temp=a.Get(j+1,n1);
               //--- get result
               a.Set(j+1,n1,ctemp*temp-stemp*a.Get(j,n1));
               a.Set(j,n1,stemp*temp+ctemp*a.Get(j,n1));
              }
           }
        }
     }
   else
     {
      if(n1!=n2)
        {
         //--- Common case: N1<>N2
         for(j=m2-1; j>=m1; j--)
           {
            ctemp=c[j-m1+1];
            stemp=s[j-m1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               jp1=j+1;
               //--- prepare array
               for(i_=n1; i_<=n2; i_++)
                  work.Set(i_,(ctemp*a.Get(jp1,i_)-stemp*a.Get(j,i_)));
               //--- get result
               for(i_=n1; i_<=n2; i_++)
                  a.Set(j,i_,(ctemp*a.Get(j,i_)+stemp*a.Get(jp1,i_)));
               for(i_=n1; i_<=n2; i_++)
                  a.Set(jp1,i_,work[i_]);
              }
           }
        }
      else
        {
         //--- Special case: N1=N2
         for(j=m2-1; j>=m1; j--)
           {
            ctemp=c[j-m1+1];
            stemp=s[j-m1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               temp=a[j+1][n1];
               //--- get result
               a.Set(j+1,n1,ctemp*temp-stemp*a.Get(j,n1));
               a.Set(j,n1,stemp*temp+ctemp*a.Get(j,n1));
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Application of a sequence of  elementary rotations to a matrix   |
//| The algorithm post-multiplies the matrix by a sequence of        |
//| rotation transformations which is given by arrays C and S.       |
//| Depending on the value of the IsForward parameter either 1 and 2,|
//| 3 and 4 and so on (if IsForward=true) rows are rotated, or the   |
//| rows N and N-1, N-2 and N-3 and so on are rotated.               |
//| Not the whole matrix but only a part of it is transformed (rows  |
//| from M1 to M2, columns from N1 to N2). Only the elements of this |
//| submatrix are changed.                                           |
//| Input parameters:                                                |
//|     IsForward   -   the sequence of the rotation application.    |
//|     M1,M2       -   the range of rows to be transformed.         |
//|     N1, N2      -   the range of columns to be transformed.      |
//|     C,S         -   transformation coefficients.                 |
//|                     Array whose index ranges within [1..N2-N1].  |
//|     A           -   processed matrix.                            |
//|     WORK        -   working array whose index ranges within      |
//|                     [M1..M2].                                    |
//| Output parameters:                                               |
//|     A           -   transformed matrix.                          |
//| Utility subroutine.                                              |
//+------------------------------------------------------------------+
void CRotations::ApplyRotationsFromTheRight(const bool isforward,
                                            const int m1,const int m2,
                                            const int n1,const int n2,
                                            double &c[],double &s[],
                                            CMatrixDouble &a,
                                            double &work[])
  {
   CRowDouble C=c;
   CRowDouble S=s;
   CRowDouble Work=work;
   ApplyRotationsFromTheRight(isforward,m1,m2,n1,n2,C,S,a,Work);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRotations::ApplyRotationsFromTheRight(const bool isforward,
                                            const int m1,const int m2,
                                            const int n1,const int n2,
                                            CRowDouble &c,CRowDouble &s,
                                            CMatrixDouble &a,
                                            CRowDouble &work)
  {
//--- create variables
   int    j=0;
   int    jp1=0;
   double ctemp=0;
   double stemp=0;
   double temp=0;
   int    i_=0;
//--- Form A * P'
   if(isforward)
     {
      //--- check
      if(m1!=m2)
        {
         //--- Common case: M1<>M2
         for(j=n1; j<=n2-1; j++)
           {
            ctemp=c[j-n1+1];
            stemp=s[j-n1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               jp1=j+1;
               //--- prepare array
               for(i_=m1; i_<=m2; i_++)
                  work.Set(i_,(ctemp*a.Get(i_,jp1)-stemp*a.Get(i_,j)));
               //--- get result
               for(i_=m1; i_<=m2; i_++)
                  a.Set(i_,j,(ctemp*a.Get(i_,j)+stemp*a.Get(i_,jp1)));
               for(i_=m1; i_<=m2; i_++)
                  a.Set(i_,jp1,work[i_]);
              }
           }
        }
      else
        {
         //--- Special case: M1=M2
         for(j=n1; j<=n2-1; j++)
           {
            ctemp=c[j-n1+1];
            stemp=s[j-n1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               temp=a[m1][j+1];
               //--- get result
               a.Set(m1,j+1,ctemp*temp-stemp*a.Get(m1,j));
               a.Set(m1,j,stemp*temp+ctemp*a.Get(m1,j));
              }
           }
        }
     }
   else
     {
      //--- check
      if(m1!=m2)
        {
         //--- Common case: M1<>M2
         for(j=n2-1; j>=n1; j--)
           {
            ctemp=c[j-n1+1];
            stemp=s[j-n1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               jp1=j+1;
               //--- prepare array
               for(i_=m1; i_<=m2; i_++)
                  work.Set(i_,(ctemp*a.Get(i_,jp1)-stemp*a.Get(i_,j)));
               //--- get result
               for(i_=m1; i_<=m2; i_++)
                  a.Set(i_,j,(ctemp*a.Get(i_,j)+stemp*a.Get(i_,jp1)));
               for(i_=m1; i_<=m2; i_++)
                  a.Set(i_,jp1,work[i_]);
              }
           }
        }
      else
        {
         //--- Special case: M1=M2
         for(j=n2-1; j>=n1; j--)
           {
            ctemp=c[j-n1+1];
            stemp=s[j-n1+1];
            //--- check
            if(ctemp!=1.0 || stemp!=0.0)
              {
               temp=a[m1][j+1];
               //--- get result
               a.Set(m1,j+1,ctemp*temp-stemp*a.Get(m1,j));
               a.Set(m1,j,stemp*temp+ctemp*a.Get(m1,j));
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| The subroutine generates the elementary rotation, so that:       |
//| [  CS  SN  ]  .  [ F ]  =  [ R ]                                 |
//| [ -SN  CS  ]     [ G ]     [ 0 ]                                 |
//| CS**2 + SN**2 = 1                                                |
//+------------------------------------------------------------------+
void CRotations::GenerateRotation(const double f,const double g,
                                  double &cs,double &sn,double &r)
  {
//--- create variables
   double f1=0;
   double g1=0;
//--- check
   if(g==0.0)
     {
      //--- get result
      cs=1;
      sn=0;
      r=f;
     }
   else
     {
      //--- check
      if(f==0.0)
        {
         //--- get result
         cs=0;
         sn=1;
         r=g;
        }
      else
        {
         f1=f;
         g1=g;
         //--- check
         if(MathAbs(f1)>MathAbs(g1))
            r=MathAbs(f1)*MathSqrt(1+CMath::Sqr(g1/f1));
         else
            r=MathAbs(g1)*MathSqrt(1+CMath::Sqr(f1/g1));
         cs=f1/r;
         sn=g1/r;
         //--- check
         if(MathAbs(f)>MathAbs(g) && cs<0.0)
           {
            //--- get result
            cs=-cs;
            sn=-sn;
            r=-r;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Safe solutions for tridiagonal linear matrix                     |
//+------------------------------------------------------------------+
class CTrLinSolve
  {
public:
   static void       RMatrixTrSafeSolve(CMatrixDouble &a,const int n,double &x[],double &s,const bool IsUpper,const bool IsTrans,const bool IsUnit);
   static void       RMatrixTrSafeSolve(CMatrixDouble &a,const int n,CRowDouble &x,double &s,const bool IsUpper,const bool IsTrans,const bool IsUnit);
   static void       SafeSolveTriangular(CMatrixDouble &a,const int n,double &x[],double &s,const bool IsUpper,const bool IsTrans,const bool IsUnit,const bool normin,double &cnorm[]);
   static void       SafeSolveTriangular(CMatrixDouble &a,const int n,CRowDouble &x,double &s,const bool IsUpper,const bool IsTrans,const bool IsUnit,const bool normin,CRowDouble &cnorm);
  };
//+------------------------------------------------------------------+
//| Utility subroutine performing the "safe" solution of system of   |
//| linear equations with triangular coefficient matrices.           |
//| The subroutine uses scaling and solves the scaled system A*x=s*b |
//| (where  s is  a  scalar  value)  instead  of  A*x=b,  choosing   |
//| s  so  that x can be represented by a floating-point number. The |
//| closer the system  gets  to  a  singular, the less s is. If the  |
//| system is singular, s=0 and x contains the non-trivial solution  |
//| of equation A*x=0.                                               |
//| The feature of an algorithm is that it could not cause an        |
//| overflow  or  a division by zero regardless of the matrix used   |
//| as the input.                                                    |
//| The algorithm can solve systems of equations with  upper/lower   |
//| triangular matrices,  with/without unit diagonal, and systems of |
//| type A*x=b or A'*x=b (where A' is a transposed matrix A).        |
//| Input parameters:                                                |
//|     A       -   system matrix. Array whose indexes range within  |
//|                 [0..N-1, 0..N-1].                                |
//|     N       -   size of matrix A.                                |
//|     X       -   right-hand member of a system.                   |
//|                 Array whose index ranges within [0..N-1].        |
//|     IsUpper -   matrix type. If it is True, the system matrix is |
//|                 the upper triangular and is located in  the      |
//|                 corresponding  part  of matrix A.                |
//|     Trans   -   problem type. If it is True, the problem to be   |
//|                 solved  is A'*x=b, otherwise it is A*x=b.        |
//|     IsUnit  -   matrix type. If it is True, the system matrix has|
//|                 a  unit diagonal (the elements on the main       |
//|                 diagonal are  not  used in the calculation       |
//|                 process), otherwise the matrix is considered to  |
//|                 be a general triangular matrix.                  |
//| Output parameters:                                               |
//|     X       -   solution. Array whose index ranges within        |
//|                 [0..N-1].                                        |
//|     S       -   scaling factor.                                  |
//|   -- LAPACK auxiliary routine (version 3.0) --                   |
//|      Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., |
//|      Courant Institute, Argonne National Lab, and Rice University|
//|      June 30, 1992                                               |
//+------------------------------------------------------------------+
void CTrLinSolve::RMatrixTrSafeSolve(CMatrixDouble &a,const int n,
                                     double &x[],double &s,
                                     const bool IsUpper,
                                     const bool IsTrans,
                                     const bool IsUnit)
  {
   CRowDouble X=x;
   RMatrixTrSafeSolve(a,n,X,s,IsUpper,IsTrans,IsUnit);
   X.ToArray(x);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CTrLinSolve::RMatrixTrSafeSolve(CMatrixDouble &a,const int n,
                                     CRowDouble &x,double &s,
                                     const bool IsUpper,
                                     const bool IsTrans,
                                     const bool IsUnit)
  {
//--- create variables
   bool normin;
   int  i=0;
   int  i_=0;
   int  i1_=0;
//--- create arrays
   CRowDouble cnorm;
   CRowDouble x1;
//--- create matrix
   CMatrixDouble a1;
//--- initialization
   s=0;
//--- From 0-based to 1-based
   normin=false;
//--- allocation
   a1.Resize(n+1,n+1);
   x1.Resize(n+1);
   i1_=-1;
   for(i=1; i<=n; i++)
     {
      for(i_=1; i_<=n; i_++)
         a1.Set(i,i_,a.Get(i-1,i_+i1_));
      x1.Set(i,x[i+i1_]);
     }
//--- Solve 1-based
   SafeSolveTriangular(a1,n,x1,s,IsUpper,IsTrans,IsUnit,normin,cnorm);
//--- From 1-based to 0-based
   i1_=1;
   for(i_=0; i_<n; i_++)
      x.Set(i_,x1[i_+i1_]);
  }
//+------------------------------------------------------------------+
//| Obsolete 1-based subroutine.                                     |
//| See RMatrixTRSafeSolve for 0-based replacement.                  |
//+------------------------------------------------------------------+
void CTrLinSolve::SafeSolveTriangular(CMatrixDouble &a,const int n,
                                      double &x[],double &s,
                                      const bool IsUpper,
                                      const bool IsTrans,
                                      const bool IsUnit,
                                      const bool normin,
                                      double &cnorm[])
  {
   CRowDouble X=x;
   CRowDouble CNorm=cnorm;
   SafeSolveTriangular(a,n,X,s,IsUpper,IsTrans,IsUnit,normin,CNorm);
   X.ToArray(x);
   CNorm.ToArray(cnorm);
  }
//+------------------------------------------------------------------+
//| Obsolete 1-based subroutine.                                     |
//| See RMatrixTRSafeSolve for 0-based replacement.                  |
//+------------------------------------------------------------------+
void CTrLinSolve::SafeSolveTriangular(CMatrixDouble &a,const int n,
                                      CRowDouble &x,double &s,
                                      const bool IsUpper,
                                      const bool IsTrans,
                                      const bool IsUnit,
                                      const bool normin,
                                      CRowDouble &cnorm)
  {
//--- create variables
   int    i=0;
   int    imax=0;
   int    j=0;
   int    jfirst=0;
   int    jinc=0;
   int    jlast=0;
   int    jm1=0;
   int    jp1=0;
   int    ip1=0;
   int    im1=0;
   int    k=0;
   int    flg=0;
   double v=0;
   double vd=0;
   double bignum=0;
   double grow=0;
   double rec=0;
   double smlnum=0;
   double sumj=0;
   double tjj=0;
   double tjjs=0;
   double tmax=0;
   double tscal=0;
   double uscal=0;
   double xbnd=0;
   double xj=0;
   double xmax=0;
   bool   notran;
   bool   upper;
   bool   nounit;
   int    i_=0;
//--- initialization
   s=0;
   upper=IsUpper;
   notran=!IsTrans;
   nounit=!IsUnit;
//--- these initializers are not really necessary,
//--- but without them compiler complains about uninitialized locals
   tjjs=0;
//--- Quick return if possible
   if(n==0)
      return;
//--- Determine machine dependent parameters to control overflow.
   smlnum=CMath::m_minrealnumber/(CMath::m_machineepsilon*2);
   bignum=1/smlnum;
   s=1;
//--- check
   if(!normin)
     {
      cnorm.Resize(n+1);
      //--- Compute the 1-norm of each column,not including the diagonal.
      if(upper)
        {
         //--- A is upper triangular.
         for(j=1; j<=n; j++)
           {
            v=0;
            for(k=1; k<j; k++)
               v=v+MathAbs(a.Get(k,j));
            cnorm.Set(j,v);
           }
        }
      else
        {
         //--- A is lower triangular.
         for(j=1; j<n; j++)
           {
            v=0;
            for(k=j+1; k<=n; k++)
               v=v+MathAbs(a.Get(k,j));
            cnorm.Set(j,v);
           }
         cnorm.Set(n,0);
        }
     }
//--- Scale the column norms by TSCAL if the maximum element in CNORM is
//--- greater than BIGNUM.
   imax=1;
   for(k=2; k<=n; k++)
     {
      //--- check
      if(cnorm[k]>cnorm[imax])
         imax=k;
     }
   tmax=cnorm[imax];
//--- check
   if(tmax<=bignum)
      tscal=1;
   else
     {
      tscal=1/(smlnum*tmax);
      for(i_=1; i_<=n; i_++)
         cnorm.Set(i_,tscal*cnorm[i_]);
     }
//--- Compute a bound on the computed solution vector to see if the
//--- Level 2 BLAS routine DTRSV can be used.
   j=1;
   for(k=2; k<=n; k++)
     {
      //--- check
      if(MathAbs(x[k])>MathAbs(x[j]))
         j=k;
     }
//--- change values
   xmax=MathAbs(x[j]);
   xbnd=xmax;
//--- check
   if(notran)
     {
      //--- Compute the growth in A * x=b.
      if(upper)
        {
         jfirst=n;
         jlast=1;
         jinc=-1;
        }
      else
        {
         jfirst=1;
         jlast=n;
         jinc=1;
        }
      //--- check
      if(tscal!=1.0)
         grow=0;
      else
        {
         //--- check
         if(nounit)
           {
            //--- A is non-unit triangular.
            //--- Compute GROW=1/G(j) and XBND=1/M(j).
            //--- Initially,G(0)=max{x(i),i=1,...,n}.
            grow=1/MathMax(xbnd,smlnum);
            xbnd=grow;
            j=jfirst;
            while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
              {
               //--- Exit the loop if the growth factor is too small.
               if(grow<=smlnum)
                  break;
               //--- M(j)=G(j-1) / abs(A(j,j))
               tjj=MathAbs(a.Get(j,j));
               xbnd=MathMin(xbnd,MathMin(1,tjj)*grow);
               //--- check
               if(tjj+cnorm[j]>=smlnum)
                 {
                  //--- G(j)=G(j-1)*( 1 + CNORM(j) / abs(A(j,j)) )
                  grow*=(tjj/(tjj+cnorm[j]));
                 }
               else
                 {
                  //--- G(j) could overflow,set GROW to 0.
                  grow=0;
                 }
               //--- check
               if(j==jlast)
                  grow=xbnd;
               j=j+jinc;
              }
           }
         else
           {
            //--- A is unit triangular.
            //--- Compute GROW=1/G(j), where G(0)=max{x(i), i=1,...,n}.
            grow=MathMin(1,1/MathMax(xbnd,smlnum));
            j=jfirst;
            while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
              {
               //--- Exit the loop if the growth factor is too small.
               if(grow<=smlnum)
                  break;
               //--- G(j) = G(j-1)*( 1 + CNORM(j) )
               grow/=(1+cnorm[j]);
               j=j+jinc;
              }
           }
        }
     }
   else
     {
      //--- Compute the growth in A' * x = b.
      if(upper)
        {
         jfirst=1;
         jlast=n;
         jinc=1;
        }
      else
        {
         jfirst=n;
         jlast=1;
         jinc=-1;
        }
      //--- check
      if(tscal!=1.0)
         grow=0;
      else
        {
         //--- check
         if(nounit)
           {
            //--- A is non-unit triangular.
            //--- Compute GROW=1/G(j) and XBND=1/M(j).
            //--- Initially, M(0)=max{x(i), i=1,...,n}.
            grow=1/MathMax(xbnd,smlnum);
            xbnd=grow;
            j=jfirst;
            while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
              {
               //--- Exit the loop if the growth factor is too small.
               if(grow<=smlnum)
                  break;
               //--- G(j) = max( G(j-1), M(j-1)*( 1 + CNORM(j) ) )
               xj=1+cnorm[j];
               grow=MathMin(grow,xbnd/xj);
               //--- M(j)=M(j-1)*( 1 + CNORM(j) ) / abs(A(j,j))
               tjj=MathAbs(a.Get(j,j));
               //--- check
               if(xj>tjj)
                  xbnd=xbnd*(tjj/xj);
               //--- check
               if(j==jlast)
                  grow=MathMin(grow,xbnd);
               j=j+jinc;
              }
           }
         else
           {
            //--- A is unit triangular.
            //--- Compute GROW=1/G(j), where G(0)=max{x(i), i=1,...,n}.
            grow=MathMin(1,1/MathMax(xbnd,smlnum));
            j=jfirst;
            while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
              {
               //--- Exit the loop if the growth factor is too small.
               if(grow<=smlnum)
                  break;
               //--- G(j)=( 1 + CNORM(j) )*G(j-1)
               xj=1+cnorm[j];
               grow=grow/xj;
               j=j+jinc;
              }
           }
        }
     }
   if(grow*tscal>smlnum)
     {
      //--- Use the Level 2 BLAS solve if the reciprocal of the bound on
      //--- elements of X is not too small.
      if((upper && notran) || (!upper && !notran))
        {
         //--- check
         if(nounit)
            vd=a.Get(n,n);
         else
            vd=1;
         x.Set(n,x[n]/vd);
         for(i=n-1; i>=1; i--)
           {
            ip1=i+1;
            //--- check
            if(upper)
              {
               v=0.0;
               for(i_=ip1; i_<=n; i_++)
                  v+=a.Get(i,i_)*x[i_];
              }
            else
              {
               v=0.0;
               for(i_=ip1; i_<=n; i_++)
                  v+=a.Get(i_,i)*x[i_];
              }
            //--- check
            if(nounit)
               vd=a.Get(i,i);
            else
               vd=1;
            x.Set(i,(x[i]-v)/vd);
           }
        }
      else
        {
         //--- check
         if(nounit)
            vd=a.Get(1,1);
         else
            vd=1;
         x.Set(1,x[1]/vd);
         for(i=2; i<=n; i++)
           {
            im1=i-1;
            //--- check
            if(upper)
              {
               v=0.0;
               for(i_=1; i_<=im1; i_++)
                  v+=a.Get(i_,i)*x[i_];
              }
            else
              {
               v=0.0;
               for(i_=1; i_<=im1; i_++)
                  v+=a.Get(i,i_)*x[i_];
              }
            //--- check
            if(nounit)
               vd=a.Get(i,i);
            else
               vd=1;
            x.Set(i,(x[i]-v)/vd);
           }
        }
     }
   else
     {
      //--- Use a Level 1 BLAS solve, scaling intermediate results.
      if(xmax>bignum)
        {
         //--- Scale X so that its components are less than or equal to
         //--- BIGNUM in absolute value.
         s=bignum/xmax;
         for(i_=1; i_<=n; i_++)
            x.Set(i_,s*x[i_]);
         xmax=bignum;
        }
      //--- check
      if(notran)
        {
         //--- Solve A * x = b
         j=jfirst;
         while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
           {
            //--- Compute x(j)=b(j) / A(j,j), scaling x if necessary.
            xj=MathAbs(x[j]);
            flg=0;
            //--- check
            if(nounit)
               tjjs=a.Get(j,j)*tscal;
            else
              {
               tjjs=tscal;
               //--- check
               if(tscal==1.0)
                  flg=100;
              }
            //--- check
            if(flg!=100)
              {
               tjj=MathAbs(tjjs);
               if(tjj>smlnum)
                 {
                  //--- abs(A(j,j)) > SMLNUM:
                  if(tjj<1.0)
                    {
                     //--- check
                     if(xj>(tjj*bignum))
                       {
                        //--- Scale x by 1/b(j).
                        rec=1/xj;
                        for(i_=1; i_<=n; i_++)
                           x.Set(i_,(rec*x[i_]));
                        s*=rec;
                        xmax*=rec;
                       }
                    }
                  x.Set(j,x[j]/tjjs);
                  xj=MathAbs(x[j]);
                 }
               else
                 {
                  //--- check
                  if(tjj>0.0)
                    {
                     //--- 0 < abs(A(j,j)) <=SMLNUM:
                     if(xj>(tjj*bignum))
                       {
                        //--- Scale x by (1/abs(x(j)))*abs(A(j,j))*BIGNUM
                        //--- to avoid overflow when dividing by A(j,j).
                        rec=tjj*bignum/xj;
                        //--- check
                        if(cnorm[j]>1.0)
                          {
                           //--- Scale by 1/CNORM(j) to avoid overflow when
                           //--- multiplying x(j) times column j.
                           rec=rec/cnorm[j];
                          }
                        for(i_=1; i_<=n; i_++)
                           x.Set(i_,rec*x[i_]);
                        s*=rec;
                        xmax*=rec;
                       }
                     x.Set(j,x[j]/tjjs);
                     xj=MathAbs(x[j]);
                    }
                  else
                    {
                     //--- A(j,j) = 0:  Set x(1:n) = 0, x(j) = 1, and
                     //--- scale = 0, and compute a solution to A*x = 0.
                     for(i=1; i<=n; i++)
                        x.Set(i,0);
                     //--- change values
                     x.Set(j,1);
                     xj=1;
                     s=0;
                     xmax=0;
                    }
                 }
              }
            //--- Scale x if necessary to avoid overflow when adding a
            //--- multiple of column j of A.
            if(xj>1.0)
              {
               rec=1/xj;
               //--- check
               if(cnorm[j]>(bignum-xmax)*rec)
                 {
                  //--- Scale x by 1/(2*abs(x(j))).
                  rec*=0.5;
                  for(i_=1; i_<=n; i_++)
                     x.Set(i_,(rec*x[i_]));
                  s*=rec;
                 }
              }
            else
              {
               //--- check
               if(xj*cnorm[j]>bignum-xmax)
                 {
                  //--- Scale x by 1/2.
                  for(i_=1; i_<=n; i_++)
                     x.Set(i_,(0.5*x[i_]));
                  s*=0.5;
                 }
              }
            //--- check
            if(upper)
              {
               //--- check
               if(j>1)
                 {
                  //--- Compute the update
                  //--- x(1:j-1) := x(1:j-1) - x(j) * A(1:j-1,j)
                  v=x[j]*tscal;
                  jm1=j-1;
                  //--- change x
                  for(i_=1; i_<=jm1; i_++)
                     x.Set(i_,x[i_]-v*a.Get(i_,j));
                  i=1;
                  for(k=2; k<j; k++)
                    {
                     //--- check
                     if(MathAbs(x[k])>MathAbs(x[i]))
                        i=k;
                    }
                  xmax=MathAbs(x[i]);
                 }
              }
            else
              {
               //--- check
               if(j<n)
                 {
                  //--- Compute the update
                  //--- x(j+1:n) := x(j+1:n) - x(j) * A(j+1:n,j)
                  jp1=j+1;
                  v=x[j]*tscal;
                  //--- change x
                  for(i_=jp1; i_<=n; i_++)
                     x.Set(i_,x[i_]-v*a.Get(i_,j));
                  i=j+1;
                  for(k=j+2; k<=n; k++)
                    {
                     //--- check
                     if(MathAbs(x[k])>MathAbs(x[i]))
                        i=k;
                    }
                  xmax=MathAbs(x[i]);
                 }
              }
            j=j+jinc;
           }
        }
      else
        {
         //--- Solve A' * x = b
         j=jfirst;
         while((jinc>0 && j<=jlast) || (jinc<0 && j>=jlast))
           {
            //--- Compute x(j) = b(j) - sum A(k,j)*x(k).
            //--- k<>j
            xj=MathAbs(x[j]);
            uscal=tscal;
            rec=1/MathMax(xmax,1);
            //--- check
            if(cnorm[j]>(bignum-xj)*rec)
              {
               //--- If x(j) could overflow,scale x by 1/(2*XMAX).
               rec=rec*0.5;
               //--- check
               if(nounit)
                  tjjs=a.Get(j,j)*tscal;
               else
                  tjjs=tscal;
               tjj=MathAbs(tjjs);
               //--- check
               if(tjj>1.0)
                 {
                  //--- Divide by A(j,j) when scaling x if A(j,j) > 1.
                  rec=MathMin(1,rec*tjj);
                  uscal=uscal/tjjs;
                 }
               //--- check
               if(rec<1.0)
                 {
                  for(i_=1; i_<=n; i_++)
                     x.Set(i_,rec*x[i_]);
                  s*=rec;
                  xmax*=rec;
                 }
              }
            sumj=0;
            //--- check
            if(uscal==1.0)
              {
               //--- If the scaling needed for A in the dot product is 1,
               //--- call DDOT to perform the dot product.
               if(upper)
                 {
                  //--- check
                  if(j>1)
                    {
                     jm1=j-1;
                     sumj=0.0;
                     for(i_=1; i_<=jm1; i_++)
                        sumj+=a.Get(i_,j)*x[i_];
                    }
                  else
                     sumj=0;
                 }
               else
                 {
                  //--- check
                  if(j<n)
                    {
                     jp1=j+1;
                     sumj=0.0;
                     for(i_=jp1; i_<=n; i_++)
                        sumj+=a.Get(i_,j)*x[i_];
                    }
                 }
              }
            else
              {
               //--- Otherwise, use in-line code for the dot product.
               if(upper)
                 {
                  for(i=1; i<=j-1; i++)
                    {
                     v=a.Get(i,j)*uscal;
                     sumj+=v*x[i];
                    }
                 }
               else
                 {
                  //--- check
                  if(j<n)
                    {
                     for(i=j+1; i<=n; i++)
                       {
                        v=a.Get(i,j)*uscal;
                        sumj=sumj+v*x[i];
                       }
                    }
                 }
              }
            if(uscal==tscal)
              {
               //--- Compute x(j) := ( x(j) - sumj ) / A(j,j) if 1/A(j,j)
               //--- was not used to scale the dotproduct.
               x.Set(j,x[j]-sumj);
               xj=MathAbs(x[j]);
               flg=0;
               //--- check
               if(nounit)
                  tjjs=a.Get(j,j)*tscal;
               else
                 {
                  tjjs=tscal;
                  //--- check
                  if(tscal==1.0)
                     flg=150;
                 }
               //--- Compute x(j) = x(j) / A(j,j), scaling if necessary.
               if(flg!=150)
                 {
                  tjj=MathAbs(tjjs);
                  //--- check
                  if(tjj>smlnum)
                    {
                     //--- abs(A(j,j)) > SMLNUM:
                     if(tjj<1.0)
                       {
                        //--- check
                        if(xj>(double)(tjj*bignum))
                          {
                           //--- Scale X by 1/abs(x(j)).
                           rec=1/xj;
                           for(i_=1; i_<=n; i_++)
                              x.Set(i_,rec*x[i_]);
                           s*=rec;
                           xmax*=rec;
                          }
                       }
                     x.Set(j,x[j]/tjjs);
                    }
                  else
                    {
                     //--- check
                     if(tjj>0.0)
                       {
                        //--- 0 < abs(A(j,j)) <=SMLNUM:
                        if(xj>(double)(tjj*bignum))
                          {
                           //--- Scale x by (1/abs(x(j)))*abs(A(j,j))*BIGNUM.
                           rec=tjj*bignum/xj;
                           for(i_=1; i_<=n; i_++)
                              x.Set(i_,rec*x[i_]);
                           s*=rec;
                           xmax*=rec;
                          }
                        x.Set(j,x[j]/tjjs);
                       }
                     else
                       {
                        //--- A(j,j) = 0:  Set x(1:n) = 0, x(j) = 1, and
                        //--- scale = 0, and compute a solution to A'*x = 0.
                        for(i=1; i<=n; i++)
                           x.Set(i,0);
                        x.Set(j,1);
                        s=0;
                        xmax=0;
                       }
                    }
                 }
              }
            else
              {
               //--- Compute x(j) := x(j) / A(j,j)  - sumj if the dot
               //--- product has already been divided by 1/A(j,j).
               x.Set(j,x[j]/tjjs-sumj);
              }
            xmax=MathMax(xmax,MathAbs(x[j]));
            j=j+jinc;
           }
        }
      s=s/tscal;
     }
//--- Scale the column norms by 1/TSCAL for return.
   if(tscal!=1.0)
     {
      v=1/tscal;
      for(i_=1; i_<=n; i_++)
         cnorm.Set(i_,v*cnorm[i_]);
     }
  }
//+------------------------------------------------------------------+
//| Safe solvers                                                     |
//+------------------------------------------------------------------+
class CSafeSolve
  {
public:
   static bool       RMatrixScaledTrSafeSolve(CMatrixDouble &a,const double sa,const int n,double &x[],const bool IsUpper,const int trans,const bool IsUnit,const double maxgrowth);
   static bool       RMatrixScaledTrSafeSolve(CMatrixDouble &a,const double sa,const int n,CRowDouble &x,const bool IsUpper,const int trans,const bool IsUnit,const double maxgrowth);
   static bool       CMatrixScaledTrSafeSolve(CMatrixComplex &a,const double sa,const int n,complex &x[],const bool IsUpper,const int trans,const bool IsUnit,const double maxgrowth);
   static bool       CMatrixScaledTrSafeSolve(CMatrixComplex &a,const double sa,const int n,CRowComplex &x,const bool IsUpper,const int trans,const bool IsUnit,const double maxgrowth);

private:
   static bool       CBasicSolveAndUpdate(complex &alpha,complex &beta,const double lnmax,const double bnorm,const double maxgrowth,double &xnorm,complex &x);
  };
//+------------------------------------------------------------------+
//| Real implementation of CMatrixScaledTRSafeSolve                  |
//+------------------------------------------------------------------+
bool CSafeSolve::RMatrixScaledTrSafeSolve(CMatrixDouble &a,const double sa,
                                          const int n,double &x[],
                                          const bool IsUpper,const int trans,
                                          const bool IsUnit,const double maxgrowth)
  {
   CRowDouble X=x;
//--- check
   if(!RMatrixScaledTrSafeSolve(a,sa,n,X,IsUpper,trans,IsUnit,maxgrowth))
      return(false);
//--- function call
   X.ToArray(x);
   return(true);
  }
//+------------------------------------------------------------------+
//| Real implementation of CMatrixScaledTRSafeSolve                  |
//+------------------------------------------------------------------+
bool CSafeSolve::RMatrixScaledTrSafeSolve(CMatrixDouble &a,const double sa,
                                          const int n,CRowDouble &x,
                                          const bool IsUpper,const int trans,
                                          const bool IsUnit,const double maxgrowth)
  {
//--- create variables
   bool    result;
   double  lnmax=0;
   double  nrmb=0;
   double  nrmx=0;
   double  vr=0;
   complex alpha=0;
   complex beta=0;
   complex cx=0;
   int     i_=0;
   int     i=0;
//--- create array
   CRowDouble tmp;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": incorrect N!"))
      return(true);
//--- check
   if(!CAp::Assert(trans==0 || trans==1,__FUNCTION__+": incorrect Trans!"))
      return(false);
//--- initialization
   result=true;
   lnmax=MathLog(CMath::m_maxrealnumber);
//--- Load norms: right part and X
   tmp=x;
   if(!tmp.Resize(n))
      return(false);
   nrmb=tmp.MaxAbs();
   nrmx=0;
//--- Solve
//--- check
   if(IsUpper && trans==0)
     {
      //--- U*x = b
      for(i=n-1; i>=0; i--)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         //--- check
         if(i<n-1)
           {
            //--- calculation
            vr=0.0;
            for(i_=i+1; i_<n; i_++)
               vr+=sa*a.Get(i,i_)*x[i_];
            beta=x[i]-vr;
           }
         else
            beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,cx);
         //--- check
         if(!result)
            return(result);
         //--- change values
         x.Set(i,cx.real);
        }
      //--- return result
      return(result);
     }
//--- check
   if(!IsUpper && trans==0)
     {
      //--- L*x = b
      for(i=0; i<n; i++)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         //--- check
         if(i>0)
           {
            //--- calculation
            vr=0.0;
            for(i_=0; i_<i; i_++)
               vr+=sa*a.Get(i,i_)*x[i_];
            beta=x[i]-vr;
           }
         else
            beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,cx);
         //--- check
         if(!result)
            return(result);
         //--- change values
         x.Set(i,cx.real);
        }
      //--- return result
      return(result);
     }
//--- check
   if(IsUpper && trans==1)
     {
      //--- U^T*x = b
      for(i=0; i<n; i++)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,cx);
         //--- check
         if(!result)
            return(result);
         //--- change values
         x.Set(i,cx.real);
         //--- update the rest of right part
         if(i<n-1)
           {
            vr=cx.real;
            for(i_=i+1; i_<n; i_++)
               x.Set(i_,x[i_]-vr*sa*a.Get(i,i_));
           }
        }
      //--- return result
      return(result);
     }
//--- check
   if(!IsUpper && trans==1)
     {
      //--- L^T*x = b
      for(i=n-1; i>=0; i--)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,cx);
         //--- check
         if(!result)
            return(result);
         //--- change values
         x.Set(i,cx.real);
         //--- update the rest of right part
         if(i>0)
           {
            vr=cx.real;
            for(i_=0; i_<i; i_++)
               x.Set(i_,x[i_]-vr*sa*a.Get(i,i_));
           }
        }
      //--- return result
      return(result);
     }
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| Internal subroutine for safe solution of                         |
//|     SA*op(A)=b                                                   |
//| where A is NxN upper/lower triangular/unitriangular matrix, op(A)|
//| is either identity transform, transposition or Hermitian         |
//| transposition, SA is a scaling factor such that max(|SA*A[i,j]|) |
//| is close to 1.0 in magnutude.                                    |
//| This subroutine limits relative growth of solution (in inf-norm) |
//| by MaxGrowth, returning False if growth exceeds MaxGrowth.       |
//| Degenerate or near-degenerate matrices are handled correctly     |
//| (False is returned) as long as MaxGrowth is significantly less   |
//| than MaxRealNumber/norm(b).                                      |
//+------------------------------------------------------------------+
bool CSafeSolve::CMatrixScaledTrSafeSolve(CMatrixComplex &a,const double sa,
                                          const int n,complex &x[],
                                          const bool IsUpper,const int trans,
                                          const bool IsUnit,const double maxgrowth)
  {
   CRowComplex X=x;
//--- check
   if(!CMatrixScaledTrSafeSolve(a,sa,n,X,IsUpper,trans,IsUnit,maxgrowth))
      return(false);
//--- function call
   X.ToArray(x);
   return(true);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
bool CSafeSolve::CMatrixScaledTrSafeSolve(CMatrixComplex &a,const double sa,
                                          const int n,CRowComplex &x,
                                          const bool IsUpper,const int trans,
                                          const bool IsUnit,const double maxgrowth)
  {
//--- create variables
   complex Csa;
   bool    result=true;
   double  lnmax=MathLog(CMath::m_maxrealnumber);
   double  nrmb=0;
   double  nrmx=0;
   complex alpha=0;
   complex beta=0;
   complex vc=0;
   int     i=0;
   int     i_=0;
//--- create array
   CRowComplex tmp;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": incorrect N!"))
      return(true);
//--- check
   if(!CAp::Assert((trans==0 || trans==1) || trans==2,__FUNCTION__+": incorrect Trans!"))
      return(false);
//--- Load norms: right part and X
   nrmb=0;
   for(i=0; i<n; i++)
      nrmb=MathMax(nrmb,CMath::AbsComplex(x[i]));
   nrmx=0;
//--- Solve
   tmp.Resize(n);
//--- check
   if(IsUpper && trans==0)
     {
      //--- U*x = b
      for(i=n-1; i>=0; i--)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         //--- check
         if(i<n-1)
           {
            //--- calculation
            vc=0.0;
            for(i_=i+1; i_<n; i_++)
               vc+=sa*a.Get(i,i_)*x[i_];
            beta=x[i]-vc;
           }
         else
            beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
        }
      //--- return result
      return(result);
     }
//--- check
   if(!IsUpper && trans==0)
     {
      //--- L*x = b
      for(i=0; i<n; i++)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         //--- check
         if(i>0)
           {
            //--- calculation
            vc=0.0;
            for(i_=0; i_<i; i_++)
               vc+=sa*a.Get(i,i_)*x[i_];
            beta=x[i]-vc;
           }
         else
            beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
        }
      //--- return result
      return(result);
     }
//--- check
   if(IsUpper && trans==1)
     {
      //--- U^T*x = b
      for(i=0; i<n; i++)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
         //--- update the rest of right part
         if(i<n-1)
           {
            for(i_=i+1; i_<n; i_++)
               x.Set(i_,x[i_]-vc*sa*a.Get(i,i_));
           }
        }
      //--- return result
      return(result);
     }
//--- check
   if(!IsUpper && trans==1)
     {
      //--- L^T*x = b
      for(i=n-1; i>=0; i--)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=a.Get(i,i)*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
         //--- update the rest of right part
         if(i>0)
           {
            for(i_=0; i_<i; i_++)
               x.Set(i_,x[i_]-vc*sa*a.Get(i,i_));
           }
        }
      //--- return result
      return(result);
     }
//--- check
   if(IsUpper && trans==2)
     {
      //--- U^H*x=b
      for(i=0; i<n; i++)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=CMath::Conj(a.Get(i,i))*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
         //--- update the rest of right part
         if(i<n-1)
           {
            for(i_=i+1; i_<n; i_++)
               x.Set(i_,x[i_]-vc*sa*CMath::Conj(a.Get(i,i_)));
           }
        }
      //--- return result
      return(result);
     }
//--- check
   if(!IsUpper && trans==2)
     {
      //--- L^T*x = b
      for(i=n-1; i>=0; i--)
        {
         //--- Task is reduced to alpha*x[i] = beta
         if(IsUnit)
            alpha=sa;
         else
            alpha=CMath::Conj(a.Get(i,i))*sa;
         beta=x[i];
         //--- solve alpha*x[i] = beta
         result=CBasicSolveAndUpdate(alpha,beta,lnmax,nrmb,maxgrowth,nrmx,vc);
         //--- check
         if(!result)
            return(result);
         x.Set(i,vc);
         //--- update the rest of right part
         if(i>0)
           {
            for(i_=0; i_<i; i_++)
               x.Set(i_,x[i_]-vc*sa*CMath::Conj(a.Get(i,i_)));
           }
        }
      //--- return result
      return(result);
     }
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| complex basic solver-updater for reduced linear system           |
//|     alpha*x[i] = beta                                            |
//| solves this equation and updates it in overlfow-safe manner      |
//| (keeping track of relative growth of solution).                  |
//| Parameters:                                                      |
//|     Alpha   -   alpha                                            |
//|     Beta    -   beta                                             |
//|     LnMax   -   precomputed Ln(MaxRealNumber)                    |
//|     BNorm   -   inf-norm of b (right part of original system)    |
//|     MaxGrowth-  maximum growth of norm(x) relative to norm(b)    |
//|     XNorm   -   inf-norm of other components of X (which are     |
//|                 already processed) it is updated by              |
//|                 CBasicSolveAndUpdate.                            |
//|     X       -   solution                                         |
//+------------------------------------------------------------------+
bool CSafeSolve::CBasicSolveAndUpdate(complex &alpha,complex &beta,
                                      const double lnmax,const double bnorm,
                                      const double maxgrowth,
                                      double &xnorm,complex &x)
  {
   double v=0;
//--- initialization
   x=0;
//--- check
   if(alpha==0)
      return(false);
//--- check
   if(beta!=0)
     {
      //--- alpha*x[i]=beta
      v=MathLog(CMath::AbsComplex(beta))-MathLog(CMath::AbsComplex(alpha));
      //--- check
      if(v>lnmax)
         return(false);
      x=beta/alpha;
     }
   else
     {
      //--- alpha*x[i]=0
      x=0;
     }
//--- update NrmX, test growth limit
   xnorm=MathMax(xnorm,CMath::AbsComplex(x));
//--- check
   if(xnorm>maxgrowth*bnorm)
      return(false);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Dot-product                                                      |
//+------------------------------------------------------------------+
class CXblas
  {
public:
   static void       XDot(double &a[],double &b[],const int n,double &temp[],double &r,double &rerr);
   static void       XDot(CRowDouble &a,CRowDouble &b,const int n,CRowDouble &temp,double &r,double &rerr);
   static void       XCDot(complex &a[],complex &b[],const int n,double &temp[],complex &r,double &rerr);
   static void       XCDot(CRowComplex &a,CRowComplex &b,const int n,CRowDouble &temp,complex &r,double &rerr);

private:
   static void       XSum(CRowDouble &w,const double mx,const int n,double &r,double &rerr);
   static double     XFastPow(const double r,const int n);
  };
//+------------------------------------------------------------------+
//| More precise dot-product. Absolute error of subroutine result is |
//| about 1 ulp of max(MX,V), where:                                 |
//|     MX = max( |a[i]*b[i]| )                                      |
//|     V  = |(a,b)|                                                 |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1], vector 1                          |
//|     B       -   array[0..N-1], vector 2                          |
//|     N       -   vectors length, N<2^29.                          |
//|     Temp    -   array[0..N-1], pre-allocated temporary storage   |
//| OUTPUT PARAMETERS                                                |
//|     R       -   (A,B)                                            |
//|     RErr    -   estimate of error. This estimate accounts for    |
//|                 both errors during  calculation of (A,B) and     |
//|                errors introduced by rounding of A and B to fit in|
//| double (about 1 ulp).                                            |
//+------------------------------------------------------------------+
void CXblas::XDot(double &a[],double &b[],const int n,double &temp[],
                  double &r,double &rerr)
  {
   CRowDouble A=a;
   CRowDouble B=b;
   CRowDouble Temp=temp;
   XDot(A,B,n,Temp,r,rerr);
   Temp.ToArray(temp);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CXblas::XDot(CRowDouble &a,CRowDouble &b,const int n,CRowDouble &temp,
                  double &r,double &rerr)
  {
//--- create variables
   double mx=0;
   double v=0;
//--- initialization
   r=0;
   rerr=0;
//--- special cases:
//--- * N=0
   if(n==0)
     {
      r=0;
      rerr=0;
      //--- exit the function
      return;
     }
   mx=0;
//--- calculations
   for(int i=0; i<n; i++)
     {
      v=a[i]*b[i];
      temp.Set(i,v);
      mx=MathMax(mx,MathAbs(v));
     }
//--- check
   if(mx==0.0)
     {
      r=0;
      rerr=0;
      //--- exit the function
      return;
     }
//--- function call
   XSum(temp,mx,n,r,rerr);
  }
//+------------------------------------------------------------------+
//| More precise complex dot-product. Absolute error of subroutine   |
//| result is about 1 ulp of max(MX,V), where:                       |
//|     MX = max( |a[i]*b[i]| )                                      |
//|     V  = |(a,b)|                                                 |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1], vector 1                          |
//|     B       -   array[0..N-1], vector 2                          |
//|     N       -   vectors length, N<2^29.                          |
//|     Temp    -   array[0..2*N-1], pre-allocated temporary storage |
//| OUTPUT PARAMETERS                                                |
//|     R       -   (A,B)                                            |
//|     RErr    -   estimate of error. This estimate accounts for    |
//|                 both errors during  calculation of (A,B) and     |
//|                 errors introduced by rounding of A and B to fit  |
//|                 in double (about 1 ulp).                         |
//+------------------------------------------------------------------+
void CXblas::XCDot(complex &a[],complex &b[],const int n,double &temp[],
                   complex &r,double &rerr)
  {
   CRowComplex A=a;
   CRowComplex B=b;
   CRowDouble Temp=temp;
   XCDot(A,B,n,Temp,r,rerr);
   Temp.ToArray(temp);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CXblas::XCDot(CRowComplex &a,CRowComplex &b,const int n,CRowDouble &temp,
                   complex &r,double &rerr)
  {
//--- create variables
   int    i=0;
   double mx=0;
   double v=0;
   double rerrx=0;
   double rerry=0;
//--- initialization
   r=0;
   rerr=0;
//--- special cases:
//--- * N=0
   if(n==0)
     {
      r=0;
      rerr=0;
      //--- exit the function
      return;
     }
//--- calculate real part
   mx=0;
   for(i=0; i<n; i++)
     {
      //--- change values
      v=a[i].real*b[i].real;
      temp.Set(2*i,v);
      mx=MathMax(mx,MathAbs(v));
      v=-(a[i].imag*b[i].imag);
      temp.Set(2*i+1,v);
      mx=MathMax(mx,MathAbs(v));
     }
//--- check
   if(mx==0.0)
     {
      r.real=0;
      rerrx=0;
     }
   else
      XSum(temp,mx,2*n,r.real,rerrx);
//--- calculate imaginary part
   mx=0;
   for(i=0; i<n; i++)
     {
      //--- change values
      v=a[i].real*b[i].imag;
      temp.Set(2*i,v);
      mx=MathMax(mx,MathAbs(v));
      v=a[i].imag*b[i].real;
      temp.Set(2*i+1,v);
      mx=MathMax(mx,MathAbs(v));
     }
//--- check
   if(mx==0.0)
     {
      r.imag=0;
      rerry=0;
     }
   else
      XSum(temp,mx,2*n,r.imag,rerry);
//--- total error
   if(rerrx==0.0 && rerry==0.0)
      rerr=0;
   else
      rerr=MathMax(rerrx,rerry)*MathSqrt(1+CMath::Sqr(MathMin(rerrx,rerry)/MathMax(rerrx,rerry)));
  }
//+------------------------------------------------------------------+
//| Internal subroutine for extra-precise calculation of SUM(w[i]).  |
//| INPUT PARAMETERS:                                                |
//|     W   -   array[0..N-1], values to be added                    |
//|             W is modified during calculations.                   |
//|     MX  -   max(W[i])                                            |
//|     N   -   array size                                           |
//| OUTPUT PARAMETERS:                                               |
//|     R   -   SUM(w[i])                                            |
//|     RErr-   error estimate for R                                 |
//+------------------------------------------------------------------+
void CXblas::XSum(CRowDouble &w,const double mx,const int n,double &r,
                  double &rerr)
  {
//--- create variables
   int    i=0;
   int    k=0;
   int    ks=0;
   double v=0;
   double s=0;
   double ln2=0;
   double chunk=0;
   double invchunk=0;
   bool   allzeros;
   int    i_=0;
//--- initialization
   r=0;
   rerr=0;
//--- special cases:
//--- * N=0
//--- * N is too large to use integer arithmetics
   if(n==0)
     {
      r=0;
      rerr=0;
      //--- exit the function
      return;
     }
//--- check
   if(mx==0.0)
     {
      r=0;
      rerr=0;
      //--- exit the function
      return;
     }
//--- check
   if(!CAp::Assert(n<536870912,__FUNCTION__+": N is too large!"))
      return;
//--- Prepare
   ln2=MathLog(2);
   rerr=mx*CMath::m_machineepsilon;
//--- 1. find S such that 0.5<=S*MX<1
//--- 2. multiply W by S, so task is normalized in some sense
//--- 3. S:=1/S so we can obtain original vector multiplying by S
   k=(int)MathRound(MathLog(mx)/ln2);
   s=XFastPow(2,-k);
//--- check s
   if(!CMath::IsFinite(s))
     {
      //--- Overflow or underflow during evaluation of S; fallback low-precision code
      r=0;
      rerr=mx*CMath::m_machineepsilon;
      for(i=0; i<n; i++)
        {
         r=r+w[i];
        }
      return;
     }
//--- change s
   while(s*mx>=1.0)
      s=0.5*s;
   while(s*mx<0.5)
      s=2*s;
   for(i_=0; i_<n; i_++)
      w.Set(i_,s*w[i_]);
   s=1/s;
//--- find Chunk=2^M such that N*Chunk<2^29
//--- we have chosen upper limit (2^29) with enough space left
//--- to tolerate possible problems with rounding and N's close
//--- to the limit, so we don't want to be very strict here.
   k=(int)(MathLog((double)536870912/(double)n)/ln2);
   chunk=XFastPow(2,k);
//--- check
   if(chunk<2.0)
      chunk=2;
   invchunk=1/chunk;
//--- calculate result
   r=0;
   for(i_=0; i_<n; i_++)
      w.Set(i_,chunk*w[i_]);
//--- cycle
   while(true)
     {
      //--- change values
      s=s*invchunk;
      allzeros=true;
      ks=0;
      for(i=0; i<=n-1; i++)
        {
         v=w[i];
         k=(int)(v);
         //--- check
         if(v!=k)
            allzeros=false;
         w.Set(i,chunk*(v-k));
         ks=ks+k;
        }
      r=r+s*ks;
      v=MathAbs(r);
      //--- check
      if(allzeros || (s*n)==0.0)
         break;
     }
//--- correct error
   rerr=MathMax(rerr,MathAbs(r)*CMath::m_machineepsilon);
  }
//+------------------------------------------------------------------+
//| Fast Pow                                                         |
//+------------------------------------------------------------------+
double CXblas::XFastPow(const double r,const int n)
  {
   double result=0;
//--- check
   if(n>0)
     {
      //--- check
      if(n%2==0)
         result=CMath::Sqr(XFastPow(r,n/2));
      else
         result=r*XFastPow(r,n-1);
     }
   else
      //--- check
      if(n==0)
         result=1;
      else
         result=XFastPow(1/r,-n);
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Auxiliary class for CLinMin                                      |
//+------------------------------------------------------------------+
struct CLinMinState
  {
   bool              m_brackt;
   bool              m_stage1;
   int               m_infoc;
   double            m_dg;
   double            m_dgm;
   double            m_dginit;
   double            m_dgtest;
   double            m_dgx;
   double            m_dgxm;
   double            m_dgy;
   double            m_dgym;
   double            m_finit;
   double            m_ftest1;
   double            m_fm;
   double            m_fx;
   double            m_fxm;
   double            m_fy;
   double            m_fym;
   double            m_stx;
   double            m_sty;
   double            m_stmin;
   double            m_stmax;
   double            m_width;
   double            m_width1;
   double            m_xtrapf;
   //--- constructor, destructor
                     CLinMinState(void) { ZeroMemory(this); }
                    ~CLinMinState(void) {}
   //--- create a copy
   void              Copy(const CLinMinState &obj);
   //--- overloading
   void              operator=(const CLinMinState &obj)  { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Create a copy                                                    |
//+------------------------------------------------------------------+
void CLinMinState::Copy(const CLinMinState &obj)
  {
//--- copy variables
   m_brackt=obj.m_brackt;
   m_stage1=obj.m_stage1;
   m_infoc=obj.m_infoc;
   m_dg=obj.m_dg;
   m_dgm=obj.m_dgm;
   m_dginit=obj.m_dginit;
   m_dgtest=obj.m_dgtest;
   m_dgx=obj.m_dgx;
   m_dgxm=obj.m_dgxm;
   m_dgy=obj.m_dgy;
   m_dgym=obj.m_dgym;
   m_finit=obj.m_finit;
   m_ftest1=obj.m_ftest1;
   m_fm=obj.m_fm;
   m_fx=obj.m_fx;
   m_fxm=obj.m_fxm;
   m_fy=obj.m_fy;
   m_fym=obj.m_fym;
   m_stx=obj.m_stx;
   m_sty=obj.m_sty;
   m_stmin=obj.m_stmin;
   m_stmax=obj.m_stmax;
   m_width=obj.m_width;
   m_width1=obj.m_width1;
   m_xtrapf=obj.m_xtrapf;
  }
//+------------------------------------------------------------------+
//| Auxiliary class for CLinMin                                      |
//+------------------------------------------------------------------+
struct CArmijoState
  {
   bool              m_needf;
   CRowDouble        m_x;
   double            m_f;
   int               m_n;
   CRowDouble        m_xbase;
   CRowDouble        m_s;
   double            m_stplen;
   double            m_fcur;
   double            m_stpmax;
   int               m_fmax;
   int               m_nfev;
   int               m_info;
   RCommState        m_rstate;
   //--- constructor, destructor
                     CArmijoState(void) { m_needf=0; m_f=0; m_n=0; m_stplen=0; m_fcur=0; m_stpmax=0; m_fmax=0; m_nfev=0; m_info=0; }
                    ~CArmijoState(void) {}
   //--- create a copy
   void              Copy(CArmijoState &obj);
   //--- overloading
   void              operator=(CArmijoState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CArmijoState::Copy(CArmijoState &obj)
  {
   m_needf=obj.m_needf;
   m_x=obj.m_x;
   m_f=obj.m_f;
   m_n=obj.m_n;
   m_xbase=obj.m_xbase;
   m_s=obj.m_s;
   m_stplen=obj.m_stplen;
   m_fcur=obj.m_fcur;
   m_stpmax=obj.m_stpmax;
   m_fmax=obj.m_fmax;
   m_nfev=obj.m_nfev;
   m_info=obj.m_info;
   m_rstate=obj.m_rstate;
  }
//+------------------------------------------------------------------+
//| Minimization of linear forms                                     |
//+------------------------------------------------------------------+
class CLinMin
  {
public:
   //--- class constants
   static const double m_ftol;
   static const double m_xtol;
   static const int  m_maxfev;
   static const double m_stpmin;
   static const double m_defstpmax;
   static const double m_armijofactor;
   //--- public methods
   static void       LinMinNormalized(double &d[],double &stp,const int n);
   static void       LinMinNormalized(CRowDouble &d,double &stp,const int n);
   static void       MCSrch(const int n,double &x[],double &f,double &g[],double &s[],double &stp,double stpmax,double gtol,int &info,int &nfev,double &wa[],CLinMinState &state,int &stage);
   static void       MCSrch(const int n,CRowDouble &x,double &f,CRowDouble &g,CRowDouble &s,double &stp,double stpmax,double gtol,int &info,int &nfev,CRowDouble &wa,CLinMinState &state,int &stage);
   static void       ArmijoCreate(const int n,double &x[],const double f,double &s[],const double stp,const double stpmax,const int ffmax,CArmijoState &state);
   static void       ArmijoCreate(const int n,CRowDouble &x,const double f,CRowDouble &s,const double stp,const double stpmax,const int ffmax,CArmijoState &state);
   static void       ArmijoResults(CArmijoState &state,int &info,double &stp,double &f);
   static bool       ArmijoIteration(CArmijoState &state);

private:
   //--- private methods
   static void       MCStep(double &stx,double &fx,double &dx,double &sty,double &fy,double &dy,double &stp,double fp,double dp,bool &m_brackt,double stmin,double stmax,int &info);
   //--- auxiliary functions for ArmijoIteration
   static void       Func_lbl_rcomm(CArmijoState &state,int n,double v);
   static bool       Func_lbl_6(CArmijoState &state,int &n,double &v);
   static bool       Func_lbl_10(CArmijoState &state,int &n,double &v);
  };
//+------------------------------------------------------------------+
//| Initialize constants                                             |
//+------------------------------------------------------------------+
const double CLinMin::m_ftol=0.001;
const double CLinMin::m_xtol=100*CMath::m_machineepsilon;
const int    CLinMin::m_maxfev=20;
const double CLinMin::m_stpmin=1.0E-50;
const double CLinMin::m_defstpmax=1.0E+50;
const double CLinMin::m_armijofactor=1.3;
//+------------------------------------------------------------------+
//| Normalizes direction/step pair: makes |D|=1,scales Stp.          |
//| If |D|=0,it returns,leavind D/Stp unchanged.                     |
//+------------------------------------------------------------------+
void CLinMin::LinMinNormalized(double &d[],double &stp,const int n)
  {
   CRowDouble D=d;
   LinMinNormalized(D,stp,n);
   D.ToArray(d);
  }
//+------------------------------------------------------------------+
//| Normalizes direction/step pair: makes |D|=1,scales Stp.          |
//| If |D|=0,it returns,leavind D/Stp unchanged.                     |
//+------------------------------------------------------------------+
void CLinMin::LinMinNormalized(CRowDouble &d,double &stp,const int n)
  {
//--- create variables
   double mx=0;
   double s=0;
   int    i=0;
   int    i_=0;
//--- first, scale D to avoid underflow/overflow durng squaring
   mx=0;
   for(i=0; i<n; i++)
      mx=MathMax(mx,MathAbs(d[i]));
//--- check
   if(mx==0.0)
      return;
   s=1/mx;
   for(i_=0; i_<n; i_++)
      d.Set(i_,s*d[i_]);
   stp=stp/s;
//--- normalize D
   s=0.0;
   for(i_=0; i_<n; i_++)
      s+=d[i_]*d[i_];
   s=1/MathSqrt(s);
   for(i_=0; i_<=n-1; i_++)
      d.Set(i_,s*d[i_]);
   stp=stp/s;
  }
//+------------------------------------------------------------------+
//| The purpose of MCSrch is to find a step which satisfies a        |
//| sufficient decrease condition and a curvature condition.         |
//| At each stage the subroutine updates an interval of uncertainty  |
//| with endpoints stx and sty. The interval of uncertainty is       |
//| initially chosen so that it contains a minimizer of the modified |
//| function                                                         |
//|     f(x+stp*s) - f(x) - ftol*stp*(gradf(x)'s).                   |
//| If a step is obtained for which the modified function has a      |
//| nonpositive function value and nonnegative derivative, then the  |
//| interval of uncertainty is chosen so that it contains a minimizer|
//| of f(x+stp*s).                                                   |
//| The  algorithm  is  designed to find a step which satisfies the  |
//| sufficient decrease condition                                    |
//|     f(x+stp*s) .le. f(x) + ftol*stp*(gradf(x)'s),                |
//| and the curvature condition                                      |
//|     abs(gradf(x+stp*s)'s)) .le. gtol*abs(gradf(x)'s).            |
//| If  ftol is less than gtol and if, for example, the function is  |
//| bounded below, then there is always a step which satisfies both  |
//| conditions. If no step can be found which satisfies both         |
//| conditions, then the algorithm usually stops when rounding errors|
//| prevent further progress. In this case stp only satisfies the    |
//| sufficient decrease condition.                                   |
//| :::::::::::::important notes:::::::::::::                        |
//| note 1:                                                          |
//| This routine  guarantees that it will stop at the last point     |
//| where function value was calculated. It won't make several       |
//| additional function evaluations after finding good point. So if  |
//| you store function evaluations requested by this routine, you can|
//| be sure that last one is the point where we've stopped.          |
//| NOTE 2:                                                          |
//| when 0<StpMax<StpMin, algorithm will terminate with INFO=5 and   |
//| Stp=0.0                                                          |
//| :::::::::::::::::::::::::::::::::::::::::                        |
//| Parameters descriprion                                           |
//| Stage is zero on first call, zero on final exit                  |
//| N is a positive integer input variable set to the number of      |
//| variables.                                                       |
//| X is  an  array  of  length n. on input it must contain the base |
//| point for the line search. on output it contains x+stp*s.        |
//| F is  a  variable. on input it must contain the value of f at x. |
//| on output it contains the value of f at x + stp*s.               |
//| G is an array of length n. on input it must contain the gradient |
//| of f at x. on output it contains the gradient of f at x + stp*s. |
//| S is an input array of length n which specifies the search       |
//| direction.                                                       |
//| Stp  is  a nonnegative variable. on input stp contains an initial|
//| estimate of a satisfactory step. on output stp contains the final|
//| estimate.                                                        |
//| Ftol and gtol are nonnegative input variables. termination occurs|
//| when the sufficient decrease condition and the directional       |
//| derivative condition are satisfied.                              |
//| Xtol is a nonnegative input variable. termination occurs when the|
//| relative width of the interval of uncertainty is at most xtol.   |
//| Stpmin and stpmax are nonnegative input variables which specify  |
//| lower and upper bounds for the step.                             |
//| Maxfev is a positive integer input variable. termination occurs  |
//| when the number of calls to fcn is at least maxfev by the end of |
//| an iteration.                                                    |
//| Info is an integer output variable set as follows:               |
//|     info = 0  improper input parameters.                         |
//|     info = 1  the sufficient decrease condition and the          |
//|               directional derivative condition hold.             |
//|     info = 2  relative width of the interval of uncertainty      |
//|              is at most xtol.                                    |
//|     info = 3  number of calls to fcn has reached maxfev.         |
//|     info = 4  the step is at the lower bound stpmin.             |
//|     info = 5  the step is at the upper bound stpmax.             |
//|     info = 6  rounding errors prevent further progress.          |
//|               there may not be a step which satisfies the        |
//|               sufficient decrease and curvature conditions.      |
//|               tolerances may be too small.                       |
//| Nfev is an integer output variable set to the number of calls to |
//| fcn.                                                             |
//| wa is a work array of length n.                                  |
//| argonne national laboratory. minpack project. june 1983          |
//| Jorge J. More', David J. Thuente                                 |
//+------------------------------------------------------------------+
void CLinMin::MCSrch(const int n,double &x[],double &f,double &g[],
                     double &s[],double &stp,double stpmax,double gtol,
                     int &info,int &nfev,double &wa[],
                     CLinMinState &state,int &stage)
  {
   CRowDouble X=x;
   CRowDouble G=g;
   CRowDouble S=s;
   CRowDouble WA=wa;
   MCSrch(n,X,f,G,S,stp,stpmax,gtol,info,nfev,WA,state,stage);
   X.ToArray(x);
   G.ToArray(g);
   WA.ToArray(wa);
  }
//+------------------------------------------------------------------+
//| Same                                                             |
//+------------------------------------------------------------------+
void CLinMin::MCSrch(const int n,CRowDouble &x,double &f,CRowDouble &g,
                     CRowDouble &s,double &stp,double stpmax,double gtol,
                     int &info,int &nfev,CRowDouble &wa,
                     CLinMinState &state,int &stage)
  {
//--- create variables
   double v=0;
   double p5=0.5;
   double p66=0.66;
   double zero=0;
   int    i_=0;
//--- init
   state.m_xtrapf=4.0;
//--- check
   if(stpmax==0.0)
      stpmax=m_defstpmax;
//--- check
   if(stp<m_stpmin)
      stp=m_stpmin;
//--- check
   if(stp>stpmax)
      stp=stpmax;
//--- Main cycle
   while(true)
     {
      switch(stage)
        {
         case 0:
            //--- NEXT
            stage=2;
            continue;
         case 2:
            state.m_infoc=1;
            info=0;
            //--- check the input parameters for errors.
            if(stpmax<m_stpmin && stpmax>0.0)
              {
               info=5;
               stp=stpmax;
               stage=0;
               //--- exit the function
               return;
              }
            //--- check
            if(n<=0 || stp<=0.0 || m_ftol<0.0 || gtol<zero || m_xtol<zero || m_stpmin<zero || stpmax<m_stpmin || m_maxfev<=0)
              {
               stage=0;
               return;
              }
            //--- compute the initial gradient in the search direction
            //--- and check that s is a descent direction.
            v=CAblasF::RDotV(n,g,s);
            state.m_dginit=v;
            //--- check
            if(state.m_dginit>=0.0)
              {
               stage=0;
               return;
              }
            //--- initialize local variables.
            state.m_brackt=false;
            state.m_stage1=true;
            nfev=0;
            state.m_finit=f;
            state.m_dgtest=m_ftol*state.m_dginit;
            state.m_width=stpmax-m_stpmin;
            state.m_width1=state.m_width/p5;
            wa=x;
            //--- the variables stx,fx,dgx contain the values of the step,
            //--- function,and directional derivative at the best step.
            //--- the variables sty,fy,dgy contain the value of the step,
            //--- function,and derivative at the other endpoint of
            //--- the interval of uncertainty.
            //--- the variables stp,f,dg contain the values of the step,
            //--- function,and derivative at the current step.
            state.m_stx=0;
            state.m_fx=state.m_finit;
            state.m_dgx=state.m_dginit;
            state.m_sty=0;
            state.m_fy=state.m_finit;
            state.m_dgy=state.m_dginit;
            //--- next
            stage=3;
            continue;
         case 3:
            //--- start of iteration.
            //--- set the minimum and maximum steps to correspond
            //--- to the present interval of uncertainty.
            if(state.m_brackt)
              {
               //--- check
               if(state.m_stx<state.m_sty)
                 {
                  state.m_stmin=state.m_stx;
                  state.m_stmax=state.m_sty;
                 }
               else
                 {
                  state.m_stmin=state.m_sty;
                  state.m_stmax=state.m_stx;
                 }
              }
            else
              {
               state.m_stmin=state.m_stx;
               state.m_stmax=stp+state.m_xtrapf*(stp-state.m_stx);
              }
            //--- force the step to be within the bounds stpmax and stpmin.
            if(stp>stpmax)
               stp=stpmax;
            //--- check
            if(stp<m_stpmin)
               stp=m_stpmin;
            //--- if an unusual termination is to occur then let
            //--- stp be the lowest point obtained so far.
            if((state.m_brackt && (stp<=state.m_stmin || stp>=state.m_stmax)) || nfev>=m_maxfev-1 || state.m_infoc==0 ||
               (state.m_brackt && state.m_stmax-state.m_stmin<=m_xtol*state.m_stmax))
               stp=state.m_stx;
            //--- evaluate the function and gradient at stp
            //--- and compute the directional derivative.
            for(i_=0; i_<n; i_++)
               x.Set(i_,wa[i_]+s[i_]*stp);
            //--- NEXT
            stage=4;
            return;
         case 4:
            info=0;
            nfev++;
            v=CAblasF::RDotV(n,g,s);
            state.m_dg=v;
            state.m_ftest1=state.m_finit+stp*state.m_dgtest;
            //--- test for convergence.
            if((state.m_brackt && (stp<=state.m_stmin || stp>=state.m_stmax)) || state.m_infoc==0)
               info=6;
            //--- check
            if((stp==stpmax && f<=state.m_ftest1) && state.m_dg<=state.m_dgtest)
               info=5;
            //--- check
            if(stp==m_stpmin && (f>state.m_ftest1 || state.m_dg>=state.m_dgtest))
               info=4;
            //--- check
            if(nfev>=m_maxfev)
               info=3;
            //--- check
            if(state.m_brackt && state.m_stmax-state.m_stmin<=m_xtol*state.m_stmax)
               info=2;
            //--- check
            if(f<=state.m_ftest1 && MathAbs(state.m_dg)<=-(gtol*state.m_dginit))
               info=1;
            //--- check for termination.
            if(info!=0)
              {
               //--- Check guarantees provided by the function for INFO=1 or INFO=5
               if(info==1 || info==5)
                 {
                  v=MathPow(wa.ToVector()-x.ToVector(),2.0).Sum();
                  if(f>=state.m_finit || v==0.0)
                     info=6;
                 }
               stage=0;
               return;
              }
            //--- in the first stage we seek a step for which the modified
            //--- function has a nonpositive value and nonnegative derivative.
            if((state.m_stage1 && f<=state.m_ftest1) && state.m_dg>=MathMin(m_ftol,gtol)*state.m_dginit)
               state.m_stage1=false;
            //--- a modified function is used to predict the step only if
            //--- we have not obtained a step for which the modified
            //--- function has a nonpositive function value and nonnegative
            //--- derivative,and if a lower function value has been
            //--- obtained but the decrease is not sufficient.
            if((state.m_stage1 && f<=state.m_fx) && f>state.m_ftest1)
              {
               //--- define the modified function and derivative values.
               state.m_fm=f-stp*state.m_dgtest;
               state.m_fxm=state.m_fx-state.m_stx*state.m_dgtest;
               state.m_fym=state.m_fy-state.m_sty*state.m_dgtest;
               state.m_dgm=state.m_dg-state.m_dgtest;
               state.m_dgxm=state.m_dgx-state.m_dgtest;
               state.m_dgym=state.m_dgy-state.m_dgtest;
               //--- call cstep to update the interval of uncertainty
               //--- and to compute the new step.
               MCStep(state.m_stx,state.m_fxm,state.m_dgxm,state.m_sty,state.m_fym,state.m_dgym,stp,state.m_fm,state.m_dgm,state.m_brackt,state.m_stmin,state.m_stmax,state.m_infoc);
               //--- reset the function and gradient values for f.
               state.m_fx=state.m_fxm+state.m_stx*state.m_dgtest;
               state.m_fy=state.m_fym+state.m_sty*state.m_dgtest;
               state.m_dgx=state.m_dgxm+state.m_dgtest;
               state.m_dgy=state.m_dgym+state.m_dgtest;
              }
            else
              {
               //--- call mcstep to update the interval of uncertainty
               //--- and to compute the new step.
               MCStep(state.m_stx,state.m_fx,state.m_dgx,state.m_sty,state.m_fy,state.m_dgy,stp,f,state.m_dg,state.m_brackt,state.m_stmin,state.m_stmax,state.m_infoc);
              }
            //--- force a sufficient decrease in the size of the
            //--- interval of uncertainty.
            if(state.m_brackt)
              {
               //--- check
               if(MathAbs(state.m_sty-state.m_stx)>=p66*state.m_width1)
                  stp=state.m_stx+p5*(state.m_sty-state.m_stx);
               state.m_width1=state.m_width;
               state.m_width=MathAbs(state.m_sty-state.m_stx);
              }
            //--- next.
            stage=3;
            continue;
        }
     }
  }
//+------------------------------------------------------------------+
//| These functions perform Armijo line search using at most FMAX    |
//| function evaluations. It doesn't enforce some kind of            |
//| "sufficient decrease" criterion - it just tries different Armijo |
//| steps and returns optimum found so far.                          |
//| Optimization is done using F-rcomm interface:                    |
//| * ArmijoCreate initializes State structure                       |
//|   (reusing previously allocated buffers)                         |
//| * ArmijoIteration is subsequently called                         |
//| * ArmijoResults returns results                                  |
//| INPUT PARAMETERS:                                                |
//|     N       -   problem size                                     |
//|     X       -   array[N], starting point                         |
//|     F       -   F(X+S*STP)                                       |
//|     S       -   step direction, S>0                              |
//|     STP     -   step length                                      |
//|     STPMAX  -   maximum value for STP or zero (if no limit is    |
//|                 imposed)                                         |
//|     FMAX    -   maximum number of function evaluations           |
//|     State   -   optimization state                               |
//+------------------------------------------------------------------+
void CLinMin::ArmijoCreate(const int n,double &x[],const double f,
                           double &s[],const double stp,const double stpmax,
                           const int ffmax,CArmijoState &state)
  {
   CRowDouble X=x;
   CRowDouble S=s;
   ArmijoCreate(n,X,f,S,stp,stpmax,ffmax,state);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLinMin::ArmijoCreate(const int n,CRowDouble &x,const double f,
                           CRowDouble &s,const double stp,const double stpmax,
                           const int ffmax,CArmijoState &state)
  {
//--- check
   if(CAp::Len(state.m_x)<n)
      state.m_x.Resize(n);
//--- copy
   state.m_stpmax=stpmax;
   state.m_fmax=ffmax;
   state.m_stplen=stp;
   state.m_fcur=f;
   state.m_n=n;
   state.m_xbase=x;
//--- check
   if(CAp::Len(state.m_xbase)!=n)
      state.m_xbase.Resize(n);
   state.m_s=s;
//--- check
   if(CAp::Len(state.m_s)!=n)
      state.m_s.Resize(n);
//--- allocation
   state.m_rstate.ia.Resize(1);
   state.m_rstate.ra.Resize(1);
   state.m_rstate.stage=-1;
  }
//+------------------------------------------------------------------+
//| Results of Armijo search                                         |
//| OUTPUT PARAMETERS:                                               |
//|     INFO    -   on output it is set to one of the return codes:  |
//|                 * 0     improper input params                    |
//|                 * 1     optimum step is found with at most FMAX  |
//|                         evaluations                              |
//|                 * 3     FMAX evaluations were used,              |
//|                         X contains optimum found so far          |
//|                 * 4     step is at lower bound STPMIN            |
//|                 * 5     step is at upper bound                   |
//|     STP     -   step length (in case of failure it is still      |
//|                 returned)                                        |
//|     F       -   function value (in case of failure it is still   |
//|                 returned)                                        |
//+------------------------------------------------------------------+
void CLinMin::ArmijoResults(CArmijoState &state,int &info,
                            double &stp,double &f)
  {
//--- change values
   info=state.m_info;
   stp=state.m_stplen;
   f=state.m_fcur;
  }
//+------------------------------------------------------------------+
//| Internal subroutine for MCSrch                                   |
//+------------------------------------------------------------------+
void CLinMin::MCStep(double &stx,double &fx,double &dx,double &sty,
                     double &fy,double &dy,double &stp,double fp,
                     double dp,bool &m_brackt,double stmin,
                     double stmax,int &info)
  {
//--- create variables
   bool   bound;
   double gamma=0;
   double p=0;
   double q=0;
   double r=0;
   double s=0;
   double sgnd=0;
   double stpc=0;
   double stpf=0;
   double stpq=0;
   double theta=0;
//--- initialization
   info=0;
//--- check the input parameters for errors.
   if(((m_brackt && (stp<=MathMin(stx,sty) || stp>=MathMax(stx,sty))) || dx*(stp-stx)>=0.0) || stmax<stmin)
      return;
//--- determine if the derivatives have opposite sign.
   sgnd=dp*(dx/MathAbs(dx));
//--- first case. a higher function value.
//--- the minimum is bracketed. if the cubic step is closer
//--- to stx than the quadratic step,the cubic step is taken,
//--- else the average of the cubic and quadratic steps is taken.
   if(fp>fx)
     {
      //--- initialization
      info=1;
      bound=true;
      theta=3*(fx-fp)/(stp-stx)+dx+dp;
      s=MathMax(MathAbs(theta),MathMax(MathAbs(dx),MathAbs(dp)));
      gamma=(s==0?0:s*MathSqrt(CMath::Sqr(theta/s)-dx/s*(dp/s)));
      //--- check
      if(stp<stx)
         gamma=-gamma;
      //--- initialization
      p=gamma-dx+theta;
      q=gamma-dx+gamma+dp;
      r=p/q;
      stpc=stx+r*(stp-stx);
      stpq=stx+dx/((fx-fp)/(stp-stx)+dx)/2*(stp-stx);
      //--- check
      if(MathAbs(stpc-stx)<MathAbs(stpq-stx))
         stpf=stpc;
      else
         stpf=stpc+(stpq-stpc)/2;
      m_brackt=true;
     }
   else
     {
      //--- check
      if(sgnd<0.0)
        {
         //--- second case. a lower function value and derivatives of
         //--- opposite sign. the minimum is bracketed. if the cubic
         //--- step is closer to stx than the quadratic (secant) step,
         //--- the cubic step is taken, else the quadratic step is taken.
         info=2;
         bound=false;
         theta=3*(fx-fp)/(stp-stx)+dx+dp;
         s=MathMax(MathAbs(theta),MathMax(MathAbs(dx),MathAbs(dp)));
         gamma=s*MathSqrt(CMath::Sqr(theta/s)-dx/s*(dp/s));
         //--- check
         if(stp>stx)
            gamma=-gamma;
         //--- initialization
         p=gamma-dp+theta;
         q=gamma-dp+gamma+dx;
         r=p/q;
         stpc=stp+r*(stx-stp);
         stpq=stp+dp/(dp-dx)*(stx-stp);
         //--- check
         if(MathAbs(stpc-stp)>MathAbs(stpq-stp))
            stpf=stpc;
         else
            stpf=stpq;
         m_brackt=true;
        }
      else
        {
         //--- check
         if(MathAbs(dp)<MathAbs(dx))
           {
            //--- third case. a lower function value,derivatives of the
            //--- same sign, and the magnitude of the derivative decreases.
            //--- the cubic step is only used if the cubic tends to infinity
            //--- in the direction of the step or if the minimum of the cubic
            //--- is beyond stp. otherwise the cubic step is defined to be
            //--- either stpmin or stpmax. the quadratic (secant) step is also
            //--- computed and if the minimum is bracketed then the the step
            //--- closest to stx is taken, else the step farthest away is taken.
            info=3;
            bound=true;
            theta=3*(fx-fp)/(stp-stx)+dx+dp;
            s=MathMax(MathAbs(theta),MathMax(MathAbs(dx),MathAbs(dp)));
            //--- the case gamma=0 only arises if the cubic does not tend
            //--- to infinity in the direction of the step.
            gamma=s*MathSqrt(MathMax(0,CMath::Sqr(theta/s)-dx/s*(dp/s)));
            //--- check
            if(stp>stx)
               gamma=-gamma;
            p=gamma-dp+theta;
            q=gamma+(dx-dp)+gamma;
            r=p/q;
            //--- check
            if(r<0.0 && (double)(gamma)!=0.0)
               stpc=stp+r*(stx-stp);
            else
              {
               //--- check
               if(stp>stx)
                  stpc=stmax;
               else
                  stpc=stmin;
              }
            stpq=stp+dp/(dp-dx)*(stx-stp);
            //--- check
            if(m_brackt)
              {
               //--- check
               if(MathAbs(stp-stpc)<MathAbs(stp-stpq))
                  stpf=stpc;
               else
                  stpf=stpq;
              }
            else
              {
               //--- check
               if(MathAbs(stp-stpc)>MathAbs(stp-stpq))
                  stpf=stpc;
               else
                  stpf=stpq;
              }
           }
         else
           {
            //--- fourth case. a lower function value,derivatives of the
            //--- same sign, and the magnitude of the derivative does
            //--- not decrease. if the minimum is not bracketed, the step
            //--- is either stpmin or stpmax, else the cubic step is taken.
            info=4;
            bound=false;
            //--- check
            if(m_brackt)
              {
               theta=3*(fp-fy)/(sty-stp)+dy+dp;
               s=MathMax(MathAbs(theta),MathMax(MathAbs(dy),MathAbs(dp)));
               gamma=s*MathSqrt(CMath::Sqr(theta/s)-dy/s*(dp/s));
               //--- check
               if(stp>sty)
                  gamma=-gamma;
               //--- initialization
               p=gamma-dp+theta;
               q=gamma-dp+gamma+dy;
               r=p/q;
               stpc=stp+r*(sty-stp);
               stpf=stpc;
              }
            else
              {
               //--- check
               if(stp>stx)
                  stpf=stmax;
               else
                  stpf=stmin;
              }
           }
        }
     }
//--- update the interval of uncertainty. this update does not
//--- depend on the new step or the case analysis above.
   if(fp>fx)
     {
      //--- set value
      sty=stp;
      fy=fp;
      dy=dp;
     }
   else
     {
      //--- check
      if(sgnd<0.0)
        {
         //--- set value
         sty=stx;
         fy=fx;
         dy=dx;
        }
      //--- set value
      stx=stp;
      fx=fp;
      dx=dp;
     }
//--- compute the new step and safeguard it.
   stpf=MathMin(stmax,stpf);
   stpf=MathMax(stmin,stpf);
   stp=stpf;
//--- check
   if(m_brackt && bound)
     {
      //--- check
      if(sty>stx)
         stp=MathMin(stx+0.66*(sty-stx),stp);
      else
         stp=MathMax(stx+0.66*(sty-stx),stp);
     }
  }
//+------------------------------------------------------------------+
//| This is rcomm-based search function                              |
//+------------------------------------------------------------------+
bool CLinMin::ArmijoIteration(CArmijoState &state)
  {
//--- create variables
   double v=0;
   int    n=0;
   int    i_=0;
//--- This code initializes locals by:
//--- * random values determined during code
//---   generation - on first subroutine call
//--- * values from previous call - on subsequent calls
   if(state.m_rstate.stage>=0)
     {
      //--- initialization
      n=state.m_rstate.ia[0];
      v=state.m_rstate.ra[0];
     }
   else
     {
      //--- initialization
      n=-983;
      v=-989;
     }
//--- check
   if(state.m_rstate.stage==0)
     {
      state.m_nfev=state.m_nfev+1;
      //--- check
      if(state.m_f>=state.m_fcur)
        {
         //--- Decrease length
         v=state.m_stplen/m_armijofactor;
         //--- copy
         state.m_x=state.m_xbase.ToVector()+state.m_s*v;
         state.m_rstate.stage=2;
         //--- Saving state
         Func_lbl_rcomm(state,n,v);
         //--- return result
         return(true);
        }
      //--- change values
      state.m_stplen=v;
      state.m_fcur=state.m_f;
      //--- function call, return result
      return(Func_lbl_6(state,n,v));
     }
//--- check
   if(state.m_rstate.stage==1)
     {
      state.m_nfev++;
      //--- make decision
      if(state.m_f<state.m_fcur)
        {
         //--- change values
         state.m_stplen=v;
         state.m_fcur=state.m_f;
        }
      else
        {
         state.m_info=1;
         //--- return result
         return(false);
        }
      //--- function call, return result
      return(Func_lbl_6(state,n,v));
     }
//--- check
   if(state.m_rstate.stage==2)
     {
      state.m_nfev++;
      //--- check
      if(state.m_f>=state.m_fcur)
        {
         //--- Nothing to be done
         state.m_info=1;
         //--- return result
         return(false);
        }
      //--- change values
      state.m_stplen/=m_armijofactor;
      state.m_fcur=state.m_f;
      //--- function call, return result
      return(Func_lbl_10(state,n,v));
     }
//--- check
   if(state.m_rstate.stage==3)
     {
      state.m_nfev++;
      //--- make decision
      if(state.m_f<state.m_fcur)
        {
         //--- change values
         state.m_stplen/=m_armijofactor;
         state.m_fcur=state.m_f;
        }
      else
        {
         state.m_info=1;
         //--- return result
         return(false);
        }
      return(Func_lbl_10(state,n,v));
     }
//--- Routine body
   if((state.m_stplen<=0.0 || state.m_stpmax<0.0) || state.m_fmax<2)
     {
      state.m_info=0;
      //--- return result
      return(false);
     }
//--- check
   if(state.m_stplen<=m_stpmin)
     {
      state.m_info=4;
      //--- return result
      return(false);
     }
//--- change values
   n=state.m_n;
   state.m_nfev=0;
//--- We always need F
   state.m_needf=true;
//--- Bound StpLen
   if(state.m_stplen>state.m_stpmax && state.m_stpmax!=0.0)
      state.m_stplen=state.m_stpmax;
//--- Increase length
   v=state.m_stplen*m_armijofactor;
//--- check
   if(v>state.m_stpmax && state.m_stpmax!=0.0)
      v=state.m_stpmax;
//--- copy
   state.m_x=state.m_xbase.ToVector()+state.m_s*v;
   state.m_rstate.stage=0;
//--- Saving state
   Func_lbl_rcomm(state,n,v);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for ArmijoIteration. Is a product to get rid  |
//| of the operator unconditional jump goto.                         |
//+------------------------------------------------------------------+
void CLinMin::Func_lbl_rcomm(CArmijoState &state,int n,double v)
  {
//--- save
   state.m_rstate.ia.Set(0,n);
   state.m_rstate.ra.Set(0,v);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for ArmijoIteration. Is a product to get rid  |
//| of the operator unconditional jump goto.                         |
//+------------------------------------------------------------------+
bool CLinMin::Func_lbl_6(CArmijoState &state,int &n,double &v)
  {
//--- test stopping conditions
   if(state.m_nfev>=state.m_fmax)
     {
      state.m_info=3;
      //--- return result
      return(false);
     }
//--- check
   if(state.m_stplen>=state.m_stpmax)
     {
      state.m_info=5;
      //--- return result
      return(false);
     }
//--- evaluate F
   v=state.m_stplen*m_armijofactor;
//--- check
   if(v>state.m_stpmax && state.m_stpmax!=0.0)
      v=state.m_stpmax;
//--- copy
   state.m_x=state.m_xbase.ToVector()+state.m_s*v;
   state.m_rstate.stage=1;
//--- Saving state
   Func_lbl_rcomm(state,n,v);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for ArmijoIteration. Is a product to get rid  |
//| of the operator unconditional jump goto.                         |
//+------------------------------------------------------------------+
bool CLinMin::Func_lbl_10(CArmijoState &state,int &n,double &v)
  {
//--- test stopping conditions
   if(state.m_nfev>=state.m_fmax)
     {
      state.m_info=3;
      //--- return result
      return(false);
     }
//--- check
   if(state.m_stplen<=m_stpmin)
     {
      state.m_info=4;
      //--- return result
      return(false);
     }
//--- evaluate F
   v=state.m_stplen/m_armijofactor;
//--- copy
   state.m_x=state.m_xbase.ToVector()+state.m_s*v;
   state.m_rstate.stage=3;
//--- Saving state
   Func_lbl_rcomm(state,n,v);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| This record stores execution plan for the fast transformation    |
//| along with preallocated temporary buffers and precalculated      |
//| values.                                                          |
//| FIELDS:                                                          |
//|   Entries     -  plan entries, one row = one entry (see below for|
//|                  description).                                   |
//|   Buf0,Buf1,Buf2 - global temporary buffers; some of them are    |
//|                  allocated, some of them are not (as decided by  |
//|                  plan generation subroutine).                    |
//|   Buffer      -  global buffer whose size is equal to plan size. |
//|                  There is one-to-one correspondence between      |
//|                  elements of global buffer and elements of array |
//|                  transformed. Because of it global buffer can be |
//|                  used as temporary thread-safe storage WITHOUT   |
//|                  ACQUIRING LOCK - each worker thread works with  |
//|                  its part of input array, and each part of input |
//|                  array corresponds to distinct part of buffer.   |
//| FORMAT OF THE ENTRIES TABLE:                                     |
//| Entries table is 2D array which stores one entry per row. Row    |
//| format is:                                                       |
//|   row[0]         operation type:                                 |
//|           * 0 for "end of plan/subplan"                        |
//|           *+1 for "reference O(N^2) complex FFT"               |
//|            * -1 for complex transposition                        |
//|            * -2 for multiplication by twiddle factors of complex |
//|                 FFT                                              |
//|           *-3 for "start of plan/subplan"                      |
//|   row[1]         repetition count, >=1                           |
//|   row[2]         base operand size (number of microvectors), >=1 |
//|   row[3]         microvector size (measured in real numbers), >=1|
//|   row[4]         parameter0, meaning depends on row[0]           |
//|   row[5]         parameter1, meaning depends on row[0]           |
//| FORMAT OF THE DATA:                                              |
//| Transformation plan works with row[1]*row[2]*row[3] real numbers,|
//| which are (in most cases) interpreted as sequence of complex     |
//| numbers. These data are grouped as follows:                      |
//|   * we have row[1] contiguous OPERANDS, which can be treated     |
//|     separately                                                   |
//|   * each operand includes row[2] contiguous MICROVECTORS         |
//|   * each microvector includes row[3] COMPONENTS, which can be    |
//|     treated separately                                           |
//|   * pair of components form complex number, so in most cases     |
//|     row[3] will be even                                          |
//| Say, if you want to perform complex FFT of length 3, then:       |
//|   * you have 1 operand: row[1]=1                                 |
//|   * operand consists of 3 microvectors:   row[2]=3               |
//|   * each microvector has two components:  row[3]=2               |
//|   * a pair of subsequent components is treated as complex number |
//|     if you want to perform TWO simultaneous complex FFT's of     |
//|     length 3, then you can choose between two representations:   |
//|      * 1 operand, 3 microvectors, 4 components; storage format is|
//|          given below: [ A0X A0Y B0X B0Y A1X A1Y B1X B1Y ... ]    |
//|          (here A denotes first sequence, B - second one).        |
//|      * 2 operands, 3 microvectors, 2 components; storage format  |
//|          is given below:[A0X A0Y A1X A2Y...B0X B0Y B1X B1Y...]   |
//| Most FFT operations are supported only for the second format, but|
//| you should remember that first format sometimes can be used too. |
//| SUPPORTED OPERATIONS:                                            |
//| row[0]=0:                                                        |
//|  *"end of plan/subplan"                                        |
//|   * in case we meet entry with such type, FFT transformation is  |
//|     finished (or we return from recursive FFT subplan, in case   |
//|     it was subplan).                                             |
//| row[0]=+1:                                                       |
//|  *"reference 1D complex FFT"                                   |
//|   * we perform reference O(N^2) complex FFT on input data, which |
//|     are treated as row[1] arrays, each of row[2] complex numbers,|
//|     and row[3] must be equal to 2                                |
//|   * transformation is performed using temporary buffer           |
//| row[0]=opBluesteinsFFT:                                          |
//|   * input array is handled with Bluestein's algorithm (by        |
//|     zero-padding to Param0 complex numbers).                     |
//|   * this plan calls Param0-point subplan which is located at     |
//|     offset Param1 (offset is measured with respect to location   |
//|     of the calling entry)                                        |
//|   * this plan uses precomputed quantities stored in Plan.PrecR   |
//|     at offset Param2.                                            |
//|   * transformation is performed using 4 temporary buffers, which |
//|     are retrieved from Plan.BluesteinPool.                       |
//| row[0]=+3:                                                       |
//|  *"optimized 1D complex FFT"                                   |
//|   * this function supports only several operand sizes:           |
//|     from 1 to 5.                                                 |
//| These transforms are hard-coded and performed very efficiently   |
//| row[0]=opRadersFFT:                                              |
//|   * input array is handled with Rader's algorithm (permutation   |
//|     and reduction to N-1-point FFT)                              |
//|   * this plan calls N-1-point subplan which is located at        |
//|     offset Param0 (offset is measured with respect to location   |
//|     of the calling entry)                                        |
//|   * this plan uses precomputed primitive root and its inverse    |
//|     (modulo N) which are stored in Param1 and Param2.            |
//|   * Param3 stores offset of the precomputed data for the plan    |
//|   * plan length must be prime, (N-1)*(N-1) must fit into integer |
//|     variable                                                     |
//| row[0]=-1                                                        |
//|  *"complex transposition"                                      |
//|   * input data are treated as row[1] independent arrays, which   |
//|     are processed separately                                     |
//|   * each of operands is treated as matrix with row[4] rows and   |
//|     row[2]/row[4] columns. Each element of the matrix is         |
//|     microvector with row[3] components.                          |
//|   * transposition is performed using temporary buffer            |
//| row[0]=-2                                                        |
//|  *"multiplication by twiddle factors of complex FFT"           |
//|   * input data are treated as row[1] independent arrays, which   |
//|     are processed separately                                     |
//|  *row[4] contains N1-length of the "first FFT" in a          |
//|     Cooley-Tukey FFT algorithm                                   |
//|   * this function does not require temporary buffers             |
//| row[0]=-3                                                        |
//|  *"start of the plan"                                          |
//|   * each subplan must start from this entry                      |
//|   * param0 is ignored                                            |
//|   * param1 stores approximate (optimistic) estimate of KFLOPs    |
//|     required to transform one operand of the plan. Total cost of |
//|     the plan is approximately equal to row[1]*param1 KFLOPs.     |
//|   * this function does not require temporary buffers             |
//| row[0]=-4                                                        |
//|  *"jump"                                                       |
//|   * param0 stores relative offset of the jump site               |
//|     (+1 corresponds to the next entry)                           |
//| row[0]=-5                                                        |
//|  *"parallel call"                                              |
//|   * input data are treated as row[1] independent arrays          |
//|   * child subplan is applied independently for each of arrays -  |
//|     row[1] times                                                 |
//|   * subplan length must be equal to row[2]*row[3]                |
//|   * param0 stores relative offset of the child subplan site      |
//|     (+1 corresponds to the next entry)                           |
//|   * param1 stores approximate total cost of plan, measured in    |
//|     UNITS (1 UNIT = 100 KFLOPs). Plan cost must be rounded DOWN  |
//|     to nearest integer.                                          |
//+------------------------------------------------------------------+
struct CFtPlan
  {
   //--- arrays
   CMatrixInt        m_entries;
   CRowDouble        m_buffer;
   CRowDouble        m_precr;
   CRowDouble        m_preci;
   CRowDouble        m_bluesteinpool[];
   //--- constructor, destructor
                     CFtPlan(void) {}
                    ~CFtPlan(void) {}
   //---
   void              Copy(CFtPlan &obj);
   //--- overloading
   void              operator=(CFtPlan &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFtPlan::Copy(CFtPlan &obj)
  {
   m_entries=obj.m_entries;
   m_buffer=obj.m_buffer;
   m_precr=obj.m_precr;
   m_preci=obj.m_preci;
  }
//+------------------------------------------------------------------+
//| Generation FFT, FHT plans                                        |
//+------------------------------------------------------------------+
class CFtBase
  {
public:
   //--- class constants
   static const int  m_coltype;
   static const int  m_coloperandscnt;
   static const int  m_coloperandsize;
   static const int  m_colmicrovectorsize;
   static const int  m_colparam0;
   static const int  m_colparam1;
   static const int  m_colparam2;
   static const int  m_colparam3;
   static const int  m_colscnt;
   static const int  m_opend;
   static const int  m_opcomplexreffft;
   static const int  m_opbluesteinsfft;
   static const int  m_opcomplexcodeletfft;
   static const int  m_opcomplexcodelettwfft;
   static const int  m_opradersfft;
   static const int  m_opcomplextranspose;
   static const int  m_opcomplexfftfactors;
   static const int  m_opstart;
   static const int  m_opjmp;
   static const int  m_opparallelcall;
   static const int  m_MaxRadix;
   static const int  m_updatetw;
   static const int  m_recursivethreshold;
   static const int  m_raderthreshold;
   static const int  m_ftbasecodeletrecommended;
   static const double m_ftbaseinefficiencyfactor;
   static const int  m_ftbasemaxsmoothfactor;
   //--- public methods
   static void       FtComplexFFTPlan(int n,int k,CFtPlan &plan);
   static void       FtApplyPlan(CFtPlan &plan,double &a[],int offsa,int repcnt);
   static void       FtApplyPlan(CFtPlan &plan,CRowDouble &a,int offsa,int repcnt);

   static void       FtBaseFactorize(const int n,const int tasktype,int &n1,int &n2);
   static bool       FtBaseIsSmooth(int n);
   static int        FtBaseFindSmooth(const int n);
   static int        FtBaseFindSmoothEven(const int n);
   static double     FtBaseGetFlopEstimate(const int n);

private:
   static void       FtDetermineSpaceRequirements(int n,int &precrsize,int &precisize);
   static void       FtComplexFFTPlanRec(int n,int k,bool childplan,bool topmostplan,int &rowptr,int &bluesteinsize,int &precrptr,int &preciptr,CFtPlan &plan);
   static void       FtPushEntry(CFtPlan &plan,int &rowptr,int etype,int eopcnt,int eopsize,int emcvsize,int eparam0);
   static void       FtPushEntry2(CFtPlan &plan,int &rowptr,int etype,int eopcnt,int eopsize,int emcvsize,int eparam0,int eparam1);
   static void       FtPushEntry4(CFtPlan &plan,int &rowptr,int etype,int eopcnt,int eopsize,int emcvsize,int eparam0,int eparam1,int eparam2,int eparam3);
   static void       FtApplySubPlan(CFtPlan &plan,int subplan,CRowDouble &a,int abase,int aoffset,CRowDouble &buf,int repcnt);
   static void       FtApplyComplexRefFFT(CRowDouble &a,int offs,int operandscnt,int operandsize,int microvectorsize,CRowDouble &buf);
   static void       FtApplyComplexCodeLetFFT(CRowDouble &a,int offs,int operandscnt,int operandsize,int microvectorsize);
   static void       FtApplyComplexCodeLetTwFFT(CRowDouble &a,int offs,int operandscnt,int operandsize,int microvectorsize);
   static void       FtPrecomputeBluesteinsFFT(int n,int m,CRowDouble &precr,int offs);
   static void       FtBluesteinsFFT(CFtPlan &plan,CRowDouble &a,int abase,int aoffset,int operandscnt,int n,int m,int precoffs,int subplan,CRowDouble &bufa,CRowDouble &bufb,CRowDouble &bufc,CRowDouble &bufd);
   static void       FtPrecomputeRadersFFT(int n,int rq,int riq,CRowDouble &precr,int offs);
   static void       FtRadersFFT(CFtPlan &plan,CRowDouble &a,int abase,int aoffset,int operandscnt,int n,int subplan,int rq,int riq,int precoffs,CRowDouble &buf);
   static void       FtFactorize(int n,bool IsRoot,int &n1,int &n2);
   static int        FtOptimisticEstimate(int n);
   static void       FFtTwCalc(CRowDouble &a,const int aoffset,const int n1,const int n2);
   static void       InternalComplexLinTranspose(CRowDouble &a,const int m,const int n,const int astart,CRowDouble &buf);
   static void       InternalRealLinTranspose(CRowDouble &a,const int m,const int n,const int astart,CRowDouble &buf);
   static void       FFtICLTRec(CRowDouble &a,const int astart,const int astride,CRowDouble &b,const int bstart,const int bstride,const int m,const int n);
   static void       FFtIRLTRec(CRowDouble &a,const int astart,const int astride,CRowDouble &b,const int bstart,const int bstride,const int m,const int n);
   static void       FtBaseFindSmoothRec(const int n,const int seed,const int leastfactor,int &best);
  };
//+------------------------------------------------------------------+
//| Initialize constants                                             |
//+------------------------------------------------------------------+
const int CFtBase::m_coltype=0;
const int CFtBase::m_coloperandscnt=1;
const int CFtBase::m_coloperandsize=2;
const int CFtBase::m_colmicrovectorsize=3;
const int CFtBase::m_colparam0=4;
const int CFtBase::m_colparam1=5;
const int CFtBase::m_colparam2=6;
const int CFtBase::m_colparam3=7;
const int CFtBase::m_colscnt=8;
const int CFtBase::m_opend=0;
const int CFtBase::m_opcomplexreffft=1;
const int CFtBase::m_opbluesteinsfft=2;
const int CFtBase::m_opcomplexcodeletfft=3;
const int CFtBase::m_opcomplexcodelettwfft=4;
const int CFtBase::m_opradersfft=5;
const int CFtBase::m_opcomplextranspose=-1;
const int CFtBase::m_opcomplexfftfactors=-2;
const int CFtBase::m_opstart=-3;
const int CFtBase::m_opjmp=-4;
const int CFtBase::m_opparallelcall=-5;
const int CFtBase::m_MaxRadix=6;
const int CFtBase::m_updatetw=16;
const int CFtBase::m_recursivethreshold=1024;
const int CFtBase::m_raderthreshold=19;
const int CFtBase::m_ftbasecodeletrecommended=5;
const double CFtBase::m_ftbaseinefficiencyfactor=1.3;
const int CFtBase::m_ftbasemaxsmoothfactor=5;
//+------------------------------------------------------------------+
//| This subroutine generates FFT plan for K complex FFT's with      |
//| length N each.                                                   |
//| INPUT PARAMETERS:                                                |
//|   N        -  FFT length (in complex numbers), N>=1              |
//|   K        -  number of repetitions, K>=1                        |
//| OUTPUT PARAMETERS:                                               |
//|   Plan     -  plan                                               |
//+------------------------------------------------------------------+
void CFtBase::FtComplexFFTPlan(int n,int k,CFtPlan &plan)
  {
//--- create variables
   int rowptr=0;
   int bluesteinsize=0;
   int precrptr=0;
   int preciptr=0;
   int precrsize=0;
   int precisize=0;
//--- Initial check for parameters
   if(!CAp::Assert(n>0,__FUNCTION__": N<=0"))
      return;
   if(!CAp::Assert(k>0,__FUNCTION__": K<=0"))
      return;
//--- Determine required sizes of precomputed real and integer
//--- buffers. This stage of code is highly dependent on internals
//--- of FTComplexFFTPlanRec() and must be kept synchronized with
//--- possible changes in internals of plan generation function.
//--- Buffer size is determined as follows:
//--- * N is factorized
//--- * we factor out anything which is less or equal to MaxRadix
//--- * prime factor F>RaderThreshold requires 4*FTBaseFindSmooth(2*F-1)
//---   real entries to store precomputed Quantities for Bluestein's
//---   transformation
//--- * prime factor F<=RaderThreshold does NOT require
//---   precomputed storage
   FtDetermineSpaceRequirements(n,precrsize,precisize);
   if(precrsize>0)
      plan.m_precr.Resize(precrsize);
   if(precisize>0)
      plan.m_preci.Resize(precisize);
//--- Generate plan
   bluesteinsize=1;
   plan.m_buffer.Resize(2*n*k);
   FtComplexFFTPlanRec(n,k,true,true,rowptr,bluesteinsize,precrptr,preciptr,plan);
   ArrayResize(plan.m_bluesteinpool,1);
   plan.m_bluesteinpool[0]=vector<double>::Zeros(bluesteinsize);
//--- Check that actual amount of precomputed space used by transformation
//--- plan is EXACTLY equal to amount of space allocated by us.
   if(!CAp::Assert(precrptr==precrsize,__FUNCTION__": internal error (PrecRPtr<>PrecRSize)"))
      return;
   if(!CAp::Assert(preciptr==precisize,__FUNCTION__": internal error (PrecRPtr<>PrecRSize)"))
      return;
  }
//+------------------------------------------------------------------+
//| This subroutine applies transformation plan to input/output      |
//| array A.                                                         |
//| INPUT PARAMETERS:                                                |
//|   Plan     -  transformation plan                                |
//|   A        -  array, must be large enough for plan to work       |
//|   OffsA    -  offset of the subarray to process                  |
//|   RepCnt   -  repetition count (transformation is repeatedly     |
//|               applied to subsequent subarrays)                   |
//| OUTPUT PARAMETERS:                                               |
//|   Plan     -  plan (temporary buffers can be modified, plan      |
//|               itself is unchanged and can be reused)             |
//|   A        -  transformed array                                  |
//+------------------------------------------------------------------+
void CFtBase::FtApplyPlan(CFtPlan &plan,double &a[],int offsa,int repcnt)
  {
   CRowDouble A=a;
   FtApplyPlan(plan,A,offsa,repcnt);
   A.ToArray(a);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFtBase::FtApplyPlan(CFtPlan &plan,CRowDouble &a,int offsa,int repcnt)
  {
//--- create variables
   int i=0;
   int plansize=plan.m_entries.Get(0,m_coloperandscnt)*plan.m_entries.Get(0,m_coloperandsize) *
                  plan.m_entries.Get(0,m_colmicrovectorsize);

   for(i=0; i<repcnt; i++)
      FtApplySubPlan(plan,0,a,offsa+plansize*i,0,plan.m_buffer,1);
  }
//+------------------------------------------------------------------+
//| Returns good factorization N=N1*N2.                              |
//| Usually N1<=N2 (but not always - small N's may be exception).    |
//| if N1<>1 then N2<>1.                                             |
//| Factorization is chosen depending on task type and codelets we   |
//| have.                                                            |
//+------------------------------------------------------------------+
void CFtBase::FtBaseFactorize(const int n,const int tasktype,
                              int &n1,int &n2)
  {
//--- create a variable
   int j=0;
//--- initialization
   n1=0;
   n2=0;
//--- try to find good codelet
   if(n1*n2!=n)
     {
      for(j=m_ftbasecodeletrecommended; j>=2; j--)
        {
         //--- check
         if(n%j==0)
           {
            n1=j;
            n2=n/j;
            break;
           }
        }
     }
//--- try to factorize N
   if(n1*n2!=n)
     {
      for(j=m_ftbasecodeletrecommended+1; j<n; j++)
        {
         //--- check
         if(n%j==0)
           {
            n1=j;
            n2=n/j;
            break;
           }
        }
     }
//--- looks like N is prime :(
   if(n1*n2!=n)
     {
      n1=1;
      n2=n;
     }
//--- normalize
   if(n2==1 && n1!=1)
     {
      n2=n1;
      n1=1;
     }
  }
//+------------------------------------------------------------------+
//| Is number smooth?                                                |
//+------------------------------------------------------------------+
bool CFtBase::FtBaseIsSmooth(int n)
  {
//--- change n
   for(int i=2; i<=m_ftbasemaxsmoothfactor; i++)
     {
      while(n%i==0)
         n=n/i;
     }
//--- check
   if(n==1)
      return(true);
//--- return result
   return(false);
  }
//+------------------------------------------------------------------+
//| Returns smallest smooth (divisible only by 2, 3, 5) number that  |
//| is greater than or equal to max(N,2)                             |
//+------------------------------------------------------------------+
int CFtBase::FtBaseFindSmooth(const int n)
  {
//--- create a variable
   int best=2;
//--- calculation
   while(best<n)
      best=2*best;
//--- function call
   FtBaseFindSmoothRec(n,1,2,best);
//--- return result
   return(best);
  }
//+------------------------------------------------------------------+
//| Returns smallest smooth (divisible only by 2, 3, 5) even number  |
//| that is greater than or equal to max(N,2)                        |
//+------------------------------------------------------------------+
int CFtBase::FtBaseFindSmoothEven(const int n)
  {
//--- create a variable
   int best=2;
//--- calculation
   while(best<n)
      best=2*best;
//--- function call
   FtBaseFindSmoothRec(n,2,2,best);
//--- return result
   return(best);
  }
//+------------------------------------------------------------------+
//| Returns estimate of FLOP count for the FFT.                      |
//| It is only an estimate based on operations count for the PERFECT |
//| FFT and relative inefficiency of the algorithm actually used.    |
//| N should be power of 2, estimates are badly wrong for            |
//| non-power-of-2 N's.                                              |
//+------------------------------------------------------------------+
double CFtBase::FtBaseGetFlopEstimate(const int n)
  {
   return(m_ftbaseinefficiencyfactor*(4*n*MathLog(n)/MathLog(2)-6*n+8));
  }
//+------------------------------------------------------------------+
//| This function returns EXACT estimate of the space requirements   |
//| for N-point FFT. Internals of this function are highly dependent |
//| on details of different FFTs employed by this unit, so every time|
//| algorithm is changed this function has to be rewritten.          |
//| INPUT PARAMETERS:                                                |
//|   N         - transform length                                   |
//|   PrecRSize - must be set to zero                                |
//|   PrecISize - must be set to zero                                |
//| OUTPUT PARAMETERS:                                               |
//|   PrecRSize - number of real temporaries required for            |
//|               transformation                                     |
//|   PrecISize - number of integer temporaries required for         |
//|               transformation                                     |
//+------------------------------------------------------------------+
void CFtBase::FtDetermineSpaceRequirements(int n,int &precrsize,int &precisize)
  {
//--- create variables
   int ncur=0;
   int f=0;
//--- Determine required sizes of precomputed real and integer
//--- buffers. This stage of code is highly dependent on internals
//--- of FTComplexFFTPlanRec() and must be kept synchronized with
//--- possible changes in internals of plan generation function.
//--- Buffer size is determined as follows:
//--- * N is factorized
//--- * we factor out anything which is less or equal to MaxRadix
//--- * prime factor F>RaderThreshold requires 4*FTBaseFindSmooth(2*F-1)
//---   real entries to store precomputed Quantities for Bluestein's
//---   transformation
//--- * prime factor F<=RaderThreshold requires 2*(F-1)+ESTIMATE(F-1)
//---   precomputed storage
   ncur=n;
   for(int i=2; i<=m_MaxRadix; i++)
     {
      while(ncur%i==0)
         ncur=ncur/i;
     }
   f=2;
   while(f<=ncur)
     {
      while(ncur%f==0)
        {
         if(f>m_raderthreshold)
            precrsize+=4*FtBaseFindSmooth(2*f-1);
         else
           {
            precrsize+=2*(f-1);
            FtDetermineSpaceRequirements(f-1,precrsize,precisize);
           }
         ncur=ncur/f;
        }
      f++;
     }
  }
//+------------------------------------------------------------------+
//| Recurrent function called by FTComplexFFTPlan() and other        |
//| functions. It recursively builds transformation plan             |
//| INPUT PARAMETERS:                                                |
//|   N           -  FFT length (in complex numbers), N>=1           |
//|   K           -  number of repetitions, K>=1                     |
//|   ChildPlan   -  if True, plan generator inserts OpStart/opEnd   |
//|                  in the plan header/footer.                      |
//|   TopmostPlan -  if True, plan generator assumes that it is      |
//|                  topmost plan:                                   |
//|                  * it may use global buffer for transpositions   |
//|                    and there is no other plan which executes in  |
//|                    parallel                                      |
//|   RowPtr      -  index which points to past-the-last entry       |
//|                  generated so far                                |
//|   BluesteinSize- amount of storage (in real numbers) required    |
//|                  for Bluestein buffer                            |
//|   PrecRPtr    -  pointer to unused part of precomputed real      |
//|                  buffer (Plan.PrecR):                            |
//|                  * when this function stores some data to        |
//|                    precomputed buffer, it advances pointer.      |
//|                  * it is responsibility of the function to assert|
//|                    that Plan.PrecR has enough space to store data|
//|                    before actually writing to buffer.            |
//|                  * it is responsibility of the caller to allocate|
//|                    enough space before calling this function     |
//|   PrecIPtr    -  pointer to unused part of precomputed integer   |
//|                  buffer (Plan.PrecI):                            |
//|                  * when this function stores some data to        |
//|                    precomputed buffer, it advances pointer.      |
//|                  * it is responsibility of the function to assert|
//|                    that Plan.PrecR has enough space to store data|
//|                    before actually writing to buffer.            |
//|                  * it is responsibility of the caller to allocate|
//|                    enough space before calling this function     |
//|   Plan        -  plan (generated so far)                         |
//| OUTPUT PARAMETERS:                                               |
//|   RowPtr      -  updated pointer (advanced by number of entries  |
//|                  generated by function)                          |
//|   BluesteinSize- updated amount (may be increased, but may never |
//|                  be decreased)                                   |
//| NOTE: in case TopmostPlan is True, ChildPlan is also must be True|
//+------------------------------------------------------------------+
void CFtBase::FtComplexFFTPlanRec(int n,int k,bool childplan,
                                  bool topmostplan,int &rowptr,
                                  int &bluesteinsize,int &precrptr,
                                  int &preciptr,CFtPlan &plan)
  {
//--- create variables
   CRowDouble localbuf;
   int m=0;
   int n1=0;
   int n2=0;
   int gq=0;
   int giq=0;
   int row0=0;
   int row1=0;
   int row2=0;
   int row3=0;
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__": N<=0"))
      return;
   if(!CAp::Assert(k>0,__FUNCTION__": K<=0"))
      return;
   if(!CAp::Assert(!topmostplan || childplan,__FUNCTION__": ChildPlan is inconsistent with TopmostPlan"))
      return;
//--- Try to generate "topmost" plan
   if(topmostplan && n>m_recursivethreshold)
     {
      FtFactorize(n,false,n1,n2);
      if(n1*n2==0)
        {
         //--- Handle prime-factor FFT with Bluestein's FFT.
         //--- Determine size of Bluestein's buffer.
         m=FtBaseFindSmooth(2*n-1);
         bluesteinsize=MathMax(2*m,bluesteinsize);
         //--- Generate plan
         FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
         FtPushEntry4(plan,rowptr,m_opbluesteinsfft,k,n,2,m,2,precrptr,0);
         row0=rowptr;
         FtPushEntry(plan,rowptr,m_opjmp,0,0,0,0);
         FtComplexFFTPlanRec(m,1,true,true,rowptr,bluesteinsize,precrptr,preciptr,plan);
         row1=rowptr;
         plan.m_entries.Set(row0,m_colparam0,row1-row0);
         FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
         //--- Fill precomputed buffer
         FtPrecomputeBluesteinsFFT(n,m,plan.m_precr,precrptr);
         //--- Update pointer to the precomputed area
         precrptr+=4*m;
        }
      else
        {
         //--- Handle composite FFT with recursive Cooley-Tukey which
         //--- uses global buffer instead of local one.
         FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
         FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
         row0=rowptr;
         FtPushEntry2(plan,rowptr,m_opparallelcall,k*n2,n1,2,0,FtOptimisticEstimate(n));
         FtPushEntry(plan,rowptr,m_opcomplexfftfactors,k,n,2,n1);
         FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n2);
         row2=rowptr;
         FtPushEntry2(plan,rowptr,m_opparallelcall,k*n1,n2,2,0,FtOptimisticEstimate(n));
         FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
         FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
         row1=rowptr;
         FtComplexFFTPlanRec(n1,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
         plan.m_entries.Set(row0,m_colparam0,row1-row0);
         row3=rowptr;
         FtComplexFFTPlanRec(n2,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
         plan.m_entries.Set(row2,m_colparam0,row3-row2);
        }
      return;
     }
//--- Prepare "non-topmost" plan:
//--- * calculate factorization
//--- * use local (shared) buffer
//--- * update buffer size - ANY plan will need at least
//---   2*N temporaries, additional requirements can be
//---   applied later
   FtFactorize(n,false,n1,n2);
//--- Handle FFT's with N1*N2=0: either small-N or prime-factor
   if(n1*n2==0)
     {
      if(n<=m_MaxRadix)
        {
         //--- Small-N FFT
         if(childplan)
            FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
         FtPushEntry(plan,rowptr,m_opcomplexcodeletfft,k,n,2,0);
         if(childplan)
            FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
         return;
        }
      if(n<=m_raderthreshold)
        {
         //--- Handle prime-factor FFT's with Rader's FFT
         m=n-1;
         if(childplan)
            FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
         CNTheory::FindPrimitiveRootAndInverse(n,gq,giq);
         FtPushEntry4(plan,rowptr,m_opradersfft,k,n,2,2,gq,giq,precrptr);
         FtPrecomputeRadersFFT(n,gq,giq,plan.m_precr,precrptr);
         precrptr+=2*(n-1);
         row0=rowptr;
         FtPushEntry(plan,rowptr,m_opjmp,0,0,0,0);
         FtComplexFFTPlanRec(m,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
         row1=rowptr;
         plan.m_entries.Set(row0,m_colparam0,row1-row0);
         if(childplan)
            FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
        }
      else
        {
         //--- Handle prime-factor FFT's with Bluestein's FFT
         m=FtBaseFindSmooth(2*n-1);
         bluesteinsize=MathMax(2*m,bluesteinsize);
         if(childplan)
            FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
         FtPushEntry4(plan,rowptr,m_opbluesteinsfft,k,n,2,m,2,precrptr,0);
         FtPrecomputeBluesteinsFFT(n,m,plan.m_precr,precrptr);
         precrptr+=4*m;
         row0=rowptr;
         FtPushEntry(plan,rowptr,m_opjmp,0,0,0,0);
         FtComplexFFTPlanRec(m,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
         row1=rowptr;
         plan.m_entries.Set(row0,m_colparam0,row1-row0);
         if(childplan)
            FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
        }
      return;
     }
//--- Handle Cooley-Tukey FFT with small N1
   if(n1<=m_MaxRadix)
     {
      //--- Specialized transformation for small N1:
      //--- * N2 short inplace FFT's, each N1-point, with integrated twiddle factors
      //--- * N1 long FFT's
      //--- * final transposition
      if(childplan)
         FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
      FtPushEntry(plan,rowptr,m_opcomplexcodelettwfft,k,n1,2*n2,0);
      FtComplexFFTPlanRec(n2,k*n1,false,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
      if(childplan)
         FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
      return;
     }
//--- Handle general Cooley-Tukey FFT, either "flat" or "recursive"
   if(n<=m_recursivethreshold)
     {
      //--- General code for large N1/N2, "flat" version without explicit recurrence
      //--- (nested subplans are inserted directly into the body of the plan)
      if(childplan)
         FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
      FtComplexFFTPlanRec(n1,k*n2,false,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
      FtPushEntry(plan,rowptr,m_opcomplexfftfactors,k,n,2,n1);
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n2);
      FtComplexFFTPlanRec(n2,k*n1,false,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
      if(childplan)
         FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
     }
   else
     {
      //--- General code for large N1/N2, "recursive" version - nested subplans
      //--- are separated from the plan body.
      //--- Generate parent plan.
      if(childplan)
         FtPushEntry2(plan,rowptr,m_opstart,k,n,2,-1,FtOptimisticEstimate(n));
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
      row0=rowptr;
      FtPushEntry2(plan,rowptr,m_opparallelcall,k*n2,n1,2,0,FtOptimisticEstimate(n));
      FtPushEntry(plan,rowptr,m_opcomplexfftfactors,k,n,2,n1);
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n2);
      row2=rowptr;
      FtPushEntry2(plan,rowptr,m_opparallelcall,k*n1,n2,2,0,FtOptimisticEstimate(n));
      FtPushEntry(plan,rowptr,m_opcomplextranspose,k,n,2,n1);
      if(childplan)
         FtPushEntry(plan,rowptr,m_opend,k,n,2,0);
      //--- Generate child subplans, insert refence to parent plans
      row1=rowptr;
      FtComplexFFTPlanRec(n1,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
      plan.m_entries.Set(row0,m_colparam0,row1-row0);
      row3=rowptr;
      FtComplexFFTPlanRec(n2,1,true,false,rowptr,bluesteinsize,precrptr,preciptr,plan);
      plan.m_entries.Set(row2,m_colparam0,row3-row2);
     }
  }
//+------------------------------------------------------------------+
//| This function pushes one more entry to the plan. It resizes      |
//| Entries matrix if needed.                                        |
//| INPUT PARAMETERS:                                                |
//|   Plan     -  plan (generated so far)                            |
//|   RowPtr   -  index which points to past-the-last entry          |
//|               generated so far                                   |
//|   EType    -  entry type                                         |
//|   EOpCnt   -  operands count                                     |
//|   EOpSize  -  operand size                                       |
//|   EMcvSize -  microvector size                                   |
//|   EParam0  -  parameter 0                                        |
//| OUTPUT PARAMETERS:                                               |
//|   Plan     -  updated plan                                       |
//|   RowPtr   -  updated pointer                                    |
//| NOTE: Param1 is set to -1.                                       |
//+------------------------------------------------------------------+
void CFtBase::FtPushEntry(CFtPlan &plan,int &rowptr,int etype,int eopcnt,
                          int eopsize,int emcvsize,int eparam0)
  {
   FtPushEntry2(plan,rowptr,etype,eopcnt,eopsize,emcvsize,eparam0,-1);
  }
//+------------------------------------------------------------------+
//| Same as FTPushEntry(), but sets Param0 AND Param1.               |
//| This function pushes one more entry to the plan. It resized      |
//| Entries matrix if needed.                                        |
//| INPUT PARAMETERS:                                                |
//|   Plan        -  plan (generated so far)                         |
//|   RowPtr      -  index which points to past-the-last entry       |
//|                  generated so far                                |
//|   EType       -  entry type                                      |
//|   EOpCnt      -  operands count                                  |
//|   EOpSize     -  operand size                                    |
//|   EMcvSize    -  microvector size                                |
//|   EParam0     -  parameter 0                                     |
//|   EParam1     -  parameter 1                                     |
//| OUTPUT PARAMETERS:                                               |
//|   Plan        -  updated plan                                    |
//|   RowPtr      -  updated pointer                                 |
//+------------------------------------------------------------------+
void CFtBase::FtPushEntry2(CFtPlan &plan,int &rowptr,int etype,
                           int eopcnt,int eopsize,int emcvsize,
                           int eparam0,int eparam1)
  {
   if(rowptr>=plan.m_entries.Rows())
      plan.m_entries.Resize(MathMax(2*plan.m_entries.Rows(),1),m_colscnt);
   plan.m_entries.Set(rowptr,m_coltype,etype);
   plan.m_entries.Set(rowptr,m_coloperandscnt,eopcnt);
   plan.m_entries.Set(rowptr,m_coloperandsize,eopsize);
   plan.m_entries.Set(rowptr,m_colmicrovectorsize,emcvsize);
   plan.m_entries.Set(rowptr,m_colparam0,eparam0);
   plan.m_entries.Set(rowptr,m_colparam1,eparam1);
   plan.m_entries.Set(rowptr,m_colparam2,0);
   plan.m_entries.Set(rowptr,m_colparam3,0);
   rowptr++;
  }
//+------------------------------------------------------------------+
//| Same as FTPushEntry(), but sets Param0, Param1, Param2 and Param3|
//| This function pushes one more entry to the plan. It resized      |
//| Entries matrix if needed.                                        |
//| INPUT PARAMETERS:                                                |
//|   Plan        -  plan (generated so far)                         |
//|   RowPtr      -  index which points to past-the-last entry       |
//|                  generated so far                                |
//|   EType       -  entry type                                      |
//|   EOpCnt      -  operands count                                  |
//|   EOpSize     -  operand size                                    |
//|   EMcvSize    -  microvector size                                |
//|   EParam0     -  parameter 0                                     |
//|   EParam1     -  parameter 1                                     |
//|   EParam2     -  parameter 2                                     |
//|   EParam3     -  parameter 3                                     |
//| OUTPUT PARAMETERS:                                               |
//|   Plan        -  updated plan                                    |
//|   RowPtr      -  updated pointer                                 |
//+------------------------------------------------------------------+
void CFtBase::FtPushEntry4(CFtPlan &plan,int &rowptr,int etype,
                           int eopcnt,int eopsize,int emcvsize,
                           int eparam0,int eparam1,int eparam2,
                           int eparam3)
  {
//--- check
   if(rowptr>=plan.m_entries.Rows())
      plan.m_entries.Resize(MathMax(2*plan.m_entries.Rows(),1),m_colscnt);
   plan.m_entries.Set(rowptr,m_coltype,etype);
   plan.m_entries.Set(rowptr,m_coloperandscnt,eopcnt);
   plan.m_entries.Set(rowptr,m_coloperandsize,eopsize);
   plan.m_entries.Set(rowptr,m_colmicrovectorsize,emcvsize);
   plan.m_entries.Set(rowptr,m_colparam0,eparam0);
   plan.m_entries.Set(rowptr,m_colparam1,eparam1);
   plan.m_entries.Set(rowptr,m_colparam2,eparam2);
   plan.m_entries.Set(rowptr,m_colparam3,eparam3);
   rowptr++;
  }
//+------------------------------------------------------------------+
//| This subroutine applies subplan to input/output array A.         |
//| INPUT PARAMETERS:                                                |
//|   Plan        -  transformation plan                             |
//|   SubPlan     -  subplan index                                   |
//|   A           -  array, must be large enough for plan to work    |
//|   ABase       -  base offset in array A, this value points to    |
//|                  start of subarray whose length is equal to      |
//|                  length of the plan                              |
//|   AOffset     -  offset with respect to ABase,                   |
//|                  0<=AOffset<PlanLength. This is an offset within |
//|                  large PlanLength-subarray of the chunk to       |
//|                  process.                                        |
//|   Buf         -  temporary buffer whose length is equal to plan  |
//|                  length (without taking into account RepCnt) or  |
//|                  larger.                                         |
//|   OffsBuf     -  offset in the buffer array                      |
//|   RepCnt      -  repetition count (transformation is repeatedly  |
//|                  applied to subsequent subarrays)                |
//| OUTPUT PARAMETERS:                                               |
//|   Plan        -  plan (temporary buffers can be modified, plan   |
//|                  itself is unchanged and can be reused)          |
//|   A           -  transformed array                               |
//+------------------------------------------------------------------+
void CFtBase::FtApplySubPlan(CFtPlan &plan,int subplan,CRowDouble &a,
                             int abase,int aoffset,CRowDouble &buf,
                             int repcnt)
  {
//--- create variables
   int rowidx=0;
   int i=0;
   int n1=0;
   int n2=0;
   int operation=0;
   int operandscnt=0;
   int operandsize=0;
   int microvectorsize=0;
   int param0=0;
   int param1=0;
   int parentsize=0;
   int childsize=0;
   int m_ChunkSize=0;
   int lastchunksize=0;
   CRowDouble bufa;
   CRowDouble bufb;
   CRowDouble bufc;
   CRowDouble bufd;
//---check
   if(!CAp::Assert(plan.m_entries.Get(subplan,m_coltype)==m_opstart,__FUNCTION__": incorrect subplan header"))
      return;
   rowidx=subplan+1;
   while(plan.m_entries.Get(rowidx,m_coltype)!=m_opend)
     {
      operation=plan.m_entries.Get(rowidx,m_coltype);
      operandscnt=repcnt*plan.m_entries.Get(rowidx,m_coloperandscnt);
      operandsize=plan.m_entries.Get(rowidx,m_coloperandsize);
      microvectorsize=plan.m_entries.Get(rowidx,m_colmicrovectorsize);
      param0=plan.m_entries.Get(rowidx,m_colparam0);
      param1=plan.m_entries.Get(rowidx,m_colparam1);
      //--- Process "jump" operation
      if(operation==m_opjmp)
         rowidx+=plan.m_entries.Get(rowidx,m_colparam0);
      else
        {
         //--- Process "parallel call" operation:
         //--- * we perform initial check for consistency between parent and child plans
         //--- * we call FTSplitAndApplyParallelPlan(), which splits parallel plan into
         //---   several parallel tasks
         if(operation==m_opparallelcall)
           {
            parentsize=operandsize*microvectorsize;
            childsize=plan.m_entries.Get(rowidx+param0,m_coloperandscnt)*plan.m_entries.Get(rowidx+param0,m_coloperandsize) *
                        plan.m_entries.Get(rowidx+param0,m_colmicrovectorsize);
            //--- check
            if(!CAp::Assert(plan.m_entries.Get(rowidx+param0,m_coltype)==m_opstart,__FUNCTION__": incorrect child subplan header"))
               return;
            if(!CAp::Assert(parentsize==childsize,__FUNCTION__": incorrect child subplan header"))
               return;
            m_ChunkSize=MathMax(m_recursivethreshold/childsize,1);
            lastchunksize=operandscnt%m_ChunkSize;
            if(lastchunksize==0)
               lastchunksize=m_ChunkSize;
            i=0;
            while(i<operandscnt)
              {
               m_ChunkSize=MathMin(m_ChunkSize,operandscnt-i);
               FtApplySubPlan(plan,rowidx+param0,a,abase,aoffset+i*childsize,buf,m_ChunkSize);
               i+=m_ChunkSize;
              }
            rowidx++;
           }
         else
           {
            //--- Process "reference complex FFT" operation
            if(operation==m_opcomplexreffft)
              {
               FtApplyComplexRefFFT(a,abase+aoffset,operandscnt,operandsize,microvectorsize,buf);
               rowidx++;
              }
            else
              {
               //--- Process "codelet FFT" operation
               if(operation==m_opcomplexcodeletfft)
                 {
                  FtApplyComplexCodeLetFFT(a,abase+aoffset,operandscnt,operandsize,microvectorsize);
                  rowidx++;
                 }
               else
                 {
                  //--- Process "integrated codelet FFT" operation
                  if(operation==m_opcomplexcodelettwfft)
                    {
                     FtApplyComplexCodeLetTwFFT(a,abase+aoffset,operandscnt,operandsize,microvectorsize);
                     rowidx++;
                    }
                  else
                    {
                     //--- Process Bluestein's FFT operation
                     if(operation==m_opbluesteinsfft)
                       {
                        if(!CAp::Assert(microvectorsize==2,__FUNCTION__": microvectorsize!=2 for Bluesteins FFT"))
                           return;
                        int last=ArraySize(plan.m_bluesteinpool)-1;
                        if(!CAp::Assert(last>=0,__FUNCTION__": Bluesteins FFT pool empty"))
                           return;
                        bufa=plan.m_bluesteinpool[last];
                        bufb=plan.m_bluesteinpool[last];
                        bufc=plan.m_bluesteinpool[last];
                        bufd=plan.m_bluesteinpool[last];
                        FtBluesteinsFFT(plan,a,abase,aoffset,operandscnt,operandsize,plan.m_entries.Get(rowidx,m_colparam0),
                                        plan.m_entries.Get(rowidx,m_colparam2),rowidx+plan.m_entries.Get(rowidx,m_colparam1),
                                        bufa,bufb,bufc,bufd);
                        if(!CAp::Assert(ArrayResize(plan.m_bluesteinpool,last+5)>0,__FUNCTION__": microvectorsize!=2 for Bluesteins FFT"))
                           return;
                        plan.m_bluesteinpool[last+1]=bufa;
                        plan.m_bluesteinpool[last+2]=bufb;
                        plan.m_bluesteinpool[last+3]=bufc;
                        plan.m_bluesteinpool[last+4]=bufd;
                        rowidx++;
                       }
                     else
                       {
                        //--- Process Rader's FFT
                        if(operation==m_opradersfft)
                          {
                           FtRadersFFT(plan,a,abase,aoffset,operandscnt,operandsize,rowidx+plan.m_entries.Get(rowidx,m_colparam0),
                                       plan.m_entries.Get(rowidx,m_colparam1),plan.m_entries.Get(rowidx,m_colparam2),
                                       plan.m_entries.Get(rowidx,m_colparam3),buf);
                           rowidx++;
                          }
                        else
                          {
                           //--- Process "complex twiddle factors" operation
                           if(operation==m_opcomplexfftfactors)
                             {
                              if(!CAp::Assert(microvectorsize==2,__FUNCTION__": MicrovectorSize<>1"))
                                 return;
                              n1=plan.m_entries.Get(rowidx,m_colparam0);
                              n2=operandsize/n1;
                              for(i=0; i<operandscnt; i++)
                                 FFtTwCalc(a,abase+aoffset+i*operandsize*2,n1,n2);
                              rowidx++;
                             }
                           else
                             {
                              //--- Process "complex transposition" operation
                              if(operation==m_opcomplextranspose)
                                {
                                 if(!CAp::Assert(microvectorsize==2,__FUNCTION__": MicrovectorSize<>1"))
                                    return;
                                 n1=plan.m_entries.Get(rowidx,m_colparam0);
                                 n2=operandsize/n1;
                                 for(i=0; i<operandscnt; i++)
                                    InternalComplexLinTranspose(a,n1,n2,abase+aoffset+i*operandsize*2,buf);
                                 rowidx++;
                                }
                              else
                                {
                                 //--- Error
                                 CAp::Assert(false,__FUNCTION__": unexpected plan type");
                                 return;
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| This subroutine applies complex reference FFT to input/output    |
//| array A.                                                         |
//| VERY SLOW OPERATION, do not use it in real life plans :)         |
//| INPUT PARAMETERS:                                                |
//|   A           -  array, must be large enough for plan to work    |
//|   Offs        -  offset of the subarray to process               |
//|   OperandsCnt -  operands count (see description of              |
//|                  FastTransformPlan)                              |
//|   OperandSize -  operand size (see description of                |
//|                  FastTransformPlan)                              |
//|   MicrovectorSize - microvector size (see description of         |
//|                  FastTransformPlan)                              |
//|   Buf         -  temporary array, must be at least               |
//|                  OperandsCnt * OperandSize * MicrovectorSize     |
//| OUTPUT PARAMETERS:                                               |
//|   A           -  transformed array                               |
//+------------------------------------------------------------------+
void CFtBase::FtApplyComplexRefFFT(CRowDouble &a,int offs,int operandscnt,
                                   int operandsize,int microvectorsize,
                                   CRowDouble &buf)
  {
//--- check
   if(!CAp::Assert(operandscnt>=1,__FUNCTION__": OperandsCnt<1"))
      return;
   if(!CAp::Assert(operandsize>=1,__FUNCTION__": OperandSize<1"))
      return;
   if(!CAp::Assert(microvectorsize==2,__FUNCTION__": MicrovectorSize<>2"))
      return;
//--- create variables
   double hre=0;
   double him=0;
   double c=0;
   double s=0;
   double re=0;
   double im=0;
   int    n=operandsize;
//--- main loop
   for(int opidx=0; opidx<operandscnt; opidx++)
     {
      for(int i=0; i<n; i++)
        {
         hre=0;
         him=0;
         for(int k=0; k<n; k++)
           {
            re=a[offs+opidx*operandsize*2+2*k+0];
            im=a[offs+opidx*operandsize*2+2*k+1];
            c=MathCos(-(2*M_PI*k*i/n));
            s=MathSin(-(2*M_PI*k*i/n));
            hre+=c*re-s*im;
            him+=c*im+s*re;
           }
         buf.Set(2*i+0,hre);
         buf.Set(2*i+1,him);
        }
      for(int i=0; i<operandsize*2; i++)
         a.Set(offs+opidx*operandsize*2+i,buf[i]);
     }
  }
//+------------------------------------------------------------------+
//| This subroutine applies complex codelet FFT to input/output      |
//| array A.                                                         |
//| INPUT PARAMETERS:                                                |
//|   A           -  array, must be large enough for plan to work    |
//|   Offs        -  offset of the subarray to process               |
//|   OperandsCnt -  operands count (see description of              |
//|                  FastTransformPlan)                              |
//|   OperandSize -  operand size (see description of                |
//|                  FastTransformPlan)                              |
//|   MicrovectorSize - microvector size, must be 2                  |
//| OUTPUT PARAMETERS:                                               |
//|   A           -  transformed array                               |
//+------------------------------------------------------------------+
void CFtBase::FtApplyComplexCodeLetFFT(CRowDouble &a,int offs,
                                       int operandscnt,
                                       int operandsize,
                                       int microvectorsize)
  {
//--- check
   if(!CAp::Assert(operandscnt>=1,__FUNCTION__": OperandsCnt<1"))
      return;
   if(!CAp::Assert(operandsize>=1,__FUNCTION__": OperandSize<1"))
      return;
   if(!CAp::Assert(operandsize<=m_MaxRadix,__FUNCTION__": N>MaxRadix"))
      return;
   if(!CAp::Assert(microvectorsize==2,__FUNCTION__": MicrovectorSize<>2"))
      return;
//--- create variables
   int    opidx=0;
   int    aoffset=0;
   double a0x=0;
   double a0y=0;
   double a1x=0;
   double a1y=0;
   double a2x=0;
   double a2y=0;
   double a3x=0;
   double a3y=0;
   double a4x=0;
   double a4y=0;
   double a5x=0;
   double a5y=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double v3=0;
   double t1x=0;
   double t1y=0;
   double t2x=0;
   double t2y=0;
   double t3x=0;
   double t3y=0;
   double t4x=0;
   double t4y=0;
   double t5x=0;
   double t5y=0;
   double m1x=0;
   double m1y=0;
   double m2x=0;
   double m2y=0;
   double m3x=0;
   double m3y=0;
   double m4x=0;
   double m4y=0;
   double m5x=0;
   double m5y=0;
   double s1x=0;
   double s1y=0;
   double s2x=0;
   double s2y=0;
   double s3x=0;
   double s3y=0;
   double s4x=0;
   double s4y=0;
   double s5x=0;
   double s5y=0;
   double c1=0;
   double c2=0;
   double c3=0;
   double c4=0;
   double c5=0;
   double v=0;
   int    n=operandsize;
//--- Hard-coded transforms for different N's
   switch(n)
     {
      case 2:
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset=offs+opidx*operandsize*2;
            a0x=a[aoffset];
            a0y=a[aoffset+1];
            a1x=a[aoffset+2];
            a1y=a[aoffset+3];
            a.Set(aoffset,a0x+a1x);
            a.Set(aoffset+1,a0y+a1y);
            a.Set(aoffset+2,a0x-a1x);
            a.Set(aoffset+3,a0y-a1y);
           }
         break;
      case 3:
         c1=MathCos(2*M_PI/3.0)-1;
         c2=MathSin(2*M_PI/3.0);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset=offs+opidx*operandsize*2;
            a0x=a[aoffset+0];
            a0y=a[aoffset+1];
            a1x=a[aoffset+2];
            a1y=a[aoffset+3];
            a2x=a[aoffset+4];
            a2y=a[aoffset+5];
            t1x=a1x+a2x;
            t1y=a1y+a2y;
            a0x+=t1x;
            a0y+=t1y;
            m1x=c1*t1x;
            m1y=c1*t1y;
            m2x=c2*(a1y-a2y);
            m2y=c2*(a2x-a1x);
            s1x=a0x+m1x;
            s1y=a0y+m1y;
            a1x=s1x+m2x;
            a1y=s1y+m2y;
            a2x=s1x-m2x;
            a2y=s1y-m2y;
            a.Set(aoffset,a0x);
            a.Set(aoffset+1,a0y);
            a.Set(aoffset+2,a1x);
            a.Set(aoffset+3,a1y);
            a.Set(aoffset+4,a2x);
            a.Set(aoffset+5,a2y);
           }
         break;
      case 4:
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset=offs+opidx*operandsize*2;
            a0x=a[aoffset+0];
            a0y=a[aoffset+1];
            a1x=a[aoffset+2];
            a1y=a[aoffset+3];
            a2x=a[aoffset+4];
            a2y=a[aoffset+5];
            a3x=a[aoffset+6];
            a3y=a[aoffset+7];
            t1x=a0x+a2x;
            t1y=a0y+a2y;
            t2x=a1x+a3x;
            t2y=a1y+a3y;
            m2x=a0x-a2x;
            m2y=a0y-a2y;
            m3x=a1y-a3y;
            m3y=a3x-a1x;
            a.Set(aoffset,t1x+t2x);
            a.Set(aoffset+1,t1y+t2y);
            a.Set(aoffset+4,t1x-t2x);
            a.Set(aoffset+5,t1y-t2y);
            a.Set(aoffset+2,m2x+m3x);
            a.Set(aoffset+3,m2y+m3y);
            a.Set(aoffset+6,m2x-m3x);
            a.Set(aoffset+7,m2y-m3y);
           }
         break;
      case 5:
         v=2*M_PI/5.0;
         c1=(MathCos(v)+MathCos(2*v))/2.0-1;
         c2=(MathCos(v)-MathCos(2*v))/2.0;
         c3=-MathSin(v);
         c4=-(MathSin(v)+MathSin(2*v));
         c5=MathSin(v)-MathSin(2*v);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset=offs+opidx*operandsize*2;
            t1x=a[aoffset+2]+a[aoffset+8];
            t1y=a[aoffset+3]+a[aoffset+9];
            t2x=a[aoffset+4]+a[aoffset+6];
            t2y=a[aoffset+5]+a[aoffset+7];
            t3x=a[aoffset+2]-a[aoffset+8];
            t3y=a[aoffset+3]-a[aoffset+9];
            t4x=a[aoffset+6]-a[aoffset+4];
            t4y=a[aoffset+7]-a[aoffset+5];
            t5x=t1x+t2x;
            t5y=t1y+t2y;
            a.Set(aoffset,a[aoffset]+t5x);
            a.Set(aoffset+1,a[aoffset+1]+t5y);
            m1x=c1*t5x;
            m1y=c1*t5y;
            m2x=c2*(t1x-t2x);
            m2y=c2*(t1y-t2y);
            m3x=-(c3*(t3y+t4y));
            m3y=c3*(t3x+t4x);
            m4x=-(c4*t4y);
            m4y=c4*t4x;
            m5x=-(c5*t3y);
            m5y=c5*t3x;
            s3x=m3x-m4x;
            s3y=m3y-m4y;
            s5x=m3x+m5x;
            s5y=m3y+m5y;
            s1x=a[aoffset+0]+m1x;
            s1y=a[aoffset+1]+m1y;
            s2x=s1x+m2x;
            s2y=s1y+m2y;
            s4x=s1x-m2x;
            s4y=s1y-m2y;
            a.Set(aoffset+2,s2x+s3x);
            a.Set(aoffset+3,s2y+s3y);
            a.Set(aoffset+4,s4x+s5x);
            a.Set(aoffset+5,s4y+s5y);
            a.Set(aoffset+6,s4x-s5x);
            a.Set(aoffset+7,s4y-s5y);
            a.Set(aoffset+8,s2x-s3x);
            a.Set(aoffset+9,s2y-s3y);
           }
         break;
      case 6:
         c1=MathCos(2*M_PI/3.0)-1;
         c2=MathSin(2*M_PI/3.0);
         c3=MathCos(-(M_PI/3.0));
         c4=MathSin(-(M_PI/3.0));
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset=offs+opidx*operandsize*2;
            a0x=a[aoffset+0];
            a0y=a[aoffset+1];
            a1x=a[aoffset+2];
            a1y=a[aoffset+3];
            a2x=a[aoffset+4];
            a2y=a[aoffset+5];
            a3x=a[aoffset+6];
            a3y=a[aoffset+7];
            a4x=a[aoffset+8];
            a4y=a[aoffset+9];
            a5x=a[aoffset+10];
            a5y=a[aoffset+11];
            v0=a0x;
            v1=a0y;
            a0x+=a3x;
            a0y+=a3y;
            a3x=v0-a3x;
            a3y=v1-a3y;
            v0=a1x;
            v1=a1y;
            a1x+=a4x;
            a1y+=a4y;
            a4x=v0-a4x;
            a4y=v1-a4y;
            v0=a2x;
            v1=a2y;
            a2x+=a5x;
            a2y+=a5y;
            a5x=v0-a5x;
            a5y=v1-a5y;
            t4x=a4x*c3-a4y*c4;
            t4y=a4x*c4+a4y*c3;
            a4x=t4x;
            a4y=t4y;
            t5x=-(a5x*c3)-a5y*c4;
            t5y=a5x*c4-a5y*c3;
            a5x=t5x;
            a5y=t5y;
            t1x=a1x+a2x;
            t1y=a1y+a2y;
            a0x=a0x+t1x;
            a0y=a0y+t1y;
            m1x=c1*t1x;
            m1y=c1*t1y;
            m2x=c2*(a1y-a2y);
            m2y=c2*(a2x-a1x);
            s1x=a0x+m1x;
            s1y=a0y+m1y;
            a1x=s1x+m2x;
            a1y=s1y+m2y;
            a2x=s1x-m2x;
            a2y=s1y-m2y;
            t1x=a4x+a5x;
            t1y=a4y+a5y;
            a3x=a3x+t1x;
            a3y=a3y+t1y;
            m1x=c1*t1x;
            m1y=c1*t1y;
            m2x=c2*(a4y-a5y);
            m2y=c2*(a5x-a4x);
            s1x=a3x+m1x;
            s1y=a3y+m1y;
            a4x=s1x+m2x;
            a4y=s1y+m2y;
            a5x=s1x-m2x;
            a5y=s1y-m2y;
            a.Set(aoffset,a0x);
            a.Set(aoffset+1,a0y);
            a.Set(aoffset+2,a3x);
            a.Set(aoffset+3,a3y);
            a.Set(aoffset+4,a1x);
            a.Set(aoffset+5,a1y);
            a.Set(aoffset+6,a4x);
            a.Set(aoffset+7,a4y);
            a.Set(aoffset+8,a2x);
            a.Set(aoffset+9,a2y);
            a.Set(aoffset+10,a5x);
            a.Set(aoffset+11,a5y);
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| This subroutine applies complex "integrated" codelet FFT  to     |
//| input/output array A. "Integrated" codelet differs from "normal" |
//| one in following ways:                                           |
//|   * it can work with MicrovectorSize > 1                         |
//|   * hence, it can be used in Cooley-Tukey FFT without            |
//|     transpositions                                               |
//|   * it performs inlined multiplication by twiddle factors of     |
//|     Cooley-Tukey FFT with N2=MicrovectorSize/2.                  |
//| INPUT PARAMETERS:                                                |
//|   A              -  array, must be large enough for plan to work |
//|   Offs           -  offset of the subarray to process            |
//|   OperandsCnt    -  operands count (see description of           |
//|                     FastTransformPlan)                           |
//|   OperandSize    -  operand size (see description of             |
//|                     FastTransformPlan)                           |
//|   MicrovectorSize-  microvector size, must be 1                  |
//| OUTPUT PARAMETERS:                                               |
//|   A              -  transformed array                            |
//+------------------------------------------------------------------+
void CFtBase::FtApplyComplexCodeLetTwFFT(CRowDouble &a,int offs,
                                         int operandscnt,
                                         int operandsize,
                                         int microvectorsize)
  {
//--- check
   if(!CAp::Assert(operandscnt>=1,__FUNCTION__": OperandsCnt<1"))
      return;
   if(!CAp::Assert(operandsize>=1,__FUNCTION__": OperandSize<1"))
      return;
   if(!CAp::Assert(microvectorsize>=1,__FUNCTION__": MicrovectorSize<>1"))
      return;
   if(!CAp::Assert(microvectorsize%2==0,__FUNCTION__": MicrovectorSize is not even"))
      return;
   if(!CAp::Assert(operandsize<=m_MaxRadix,__FUNCTION__": N>MaxRadix"))
      return;
//--- create variables
   int    opidx=0;
   int    mvidx=0;
   int    n=operandsize;
   int    m=microvectorsize/2;
   int    aoffset0=0;
   int    aoffset2=0;
   int    aoffset4=0;
   int    aoffset6=0;
   int    aoffset8=0;
   int    aoffset10=0;
   double a0x=0;
   double a0y=0;
   double a1x=0;
   double a1y=0;
   double a2x=0;
   double a2y=0;
   double a3x=0;
   double a3y=0;
   double a4x=0;
   double a4y=0;
   double a5x=0;
   double a5y=0;
   double v0=0;
   double v1=0;
   double v2=0;
   double v3=0;
   double q0x=0;
   double q0y=0;
   double t1x=0;
   double t1y=0;
   double t2x=0;
   double t2y=0;
   double t3x=0;
   double t3y=0;
   double t4x=0;
   double t4y=0;
   double t5x=0;
   double t5y=0;
   double m1x=0;
   double m1y=0;
   double m2x=0;
   double m2y=0;
   double m3x=0;
   double m3y=0;
   double m4x=0;
   double m4y=0;
   double m5x=0;
   double m5y=0;
   double s1x=0;
   double s1y=0;
   double s2x=0;
   double s2y=0;
   double s3x=0;
   double s3y=0;
   double s4x=0;
   double s4y=0;
   double s5x=0;
   double s5y=0;
   double c1=0;
   double c2=0;
   double c3=0;
   double c4=0;
   double c5=0;
   double v=0;
   double tw0=0;
   double tw1=0;
   double twx=0;
   double twxm1=0;
   double twy=0;
   double tw2x=0;
   double tw2y=0;
   double tw3x=0;
   double tw3y=0;
   double tw4x=0;
   double tw4y=0;
   double tw5x=0;
   double tw5y=0;
//--- Hard-coded transforms for different N's
   switch(n)
     {
      case 2:
         v=-(2*M_PI/(n*m));
         tw0=-(2*CMath::Sqr(MathSin(0.5*v)));
         tw1=MathSin(v);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset0=offs+opidx*operandsize*microvectorsize;
            aoffset2=aoffset0+microvectorsize;
            twxm1=0.0;
            twy=0.0;
            for(mvidx=0; mvidx<m; mvidx++)
              {
               a0x=a[aoffset0];
               a0y=a[aoffset0+1];
               a1x=a[aoffset2];
               a1y=a[aoffset2+1];
               v0=a0x+a1x;
               v1=a0y+a1y;
               v2=a0x-a1x;
               v3=a0y-a1y;
               a.Set(aoffset0,v0);
               a.Set(aoffset0+1,v1);
               a.Set(aoffset2,(v2*(1+twxm1)-v3*twy));
               a.Set(aoffset2+1,(v3*(1+twxm1)+v2*twy));
               aoffset0+=2;
               aoffset2+=2;
               if((mvidx+1)%m_updatetw==0)
                 {
                  v=-(2*M_PI*(mvidx+1)/(n*m));
                  twxm1=MathSin(0.5*v);
                  twxm1=-(2*twxm1*twxm1);
                  twy=MathSin(v);
                 }
               else
                 {
                  v=twxm1+tw0+twxm1*tw0-twy*tw1;
                  twy=twy+tw1+twxm1*tw1+twy*tw0;
                  twxm1=v;
                 }
              }
           }
         break;
      case 3:
         v=-(2*M_PI/(n*m));
         tw0=-(2*CMath::Sqr(MathSin(0.5*v)));
         tw1=MathSin(v);
         c1=MathCos(2*M_PI/3.0)-1;
         c2=MathSin(2*M_PI/3.0);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset0=offs+opidx*operandsize*microvectorsize;
            aoffset2=aoffset0+microvectorsize;
            aoffset4=aoffset2+microvectorsize;
            twx=1.0;
            twxm1=0.0;
            twy=0.0;
            for(mvidx=0; mvidx<m; mvidx++)
              {
               a0x=a[aoffset0];
               a0y=a[aoffset0+1];
               a1x=a[aoffset2];
               a1y=a[aoffset2+1];
               a2x=a[aoffset4];
               a2y=a[aoffset4+1];
               t1x=a1x+a2x;
               t1y=a1y+a2y;
               a0x=a0x+t1x;
               a0y=a0y+t1y;
               m1x=c1*t1x;
               m1y=c1*t1y;
               m2x=c2*(a1y-a2y);
               m2y=c2*(a2x-a1x);
               s1x=a0x+m1x;
               s1y=a0y+m1y;
               a1x=s1x+m2x;
               a1y=s1y+m2y;
               a2x=s1x-m2x;
               a2y=s1y-m2y;
               tw2x=twx*twx-twy*twy;
               tw2y=2*twx*twy;
               a.Set(aoffset0,a0x);
               a.Set(aoffset0+1,a0y);
               a.Set(aoffset2,(a1x*twx-a1y*twy));
               a.Set(aoffset2+1,(a1y*twx+a1x*twy));
               a.Set(aoffset4,(a2x*tw2x-a2y*tw2y));
               a.Set(aoffset4+1,(a2y*tw2x+a2x*tw2y));
               aoffset0=aoffset0+2;
               aoffset2=aoffset2+2;
               aoffset4=aoffset4+2;
               if((mvidx+1)%m_updatetw==0)
                 {
                  v=-(2*M_PI*(mvidx+1)/(n*m));
                  twxm1=MathSin(0.5*v);
                  twxm1=-(2*twxm1*twxm1);
                  twy=MathSin(v);
                  twx=twxm1+1;
                 }
               else
                 {
                  v=twxm1+tw0+twxm1*tw0-twy*tw1;
                  twy=twy+tw1+twxm1*tw1+twy*tw0;
                  twxm1=v;
                  twx=v+1;
                 }
              }
           }
         break;
      case 4:
         v=-(2*M_PI/(n*m));
         tw0=-(2*CMath::Sqr(MathSin(0.5*v)));
         tw1=MathSin(v);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset0=offs+opidx*operandsize*microvectorsize;
            aoffset2=aoffset0+microvectorsize;
            aoffset4=aoffset2+microvectorsize;
            aoffset6=aoffset4+microvectorsize;
            twx=1.0;
            twxm1=0.0;
            twy=0.0;
            for(mvidx=0; mvidx<m; mvidx++)
              {
               a0x=a[aoffset0];
               a0y=a[aoffset0+1];
               a1x=a[aoffset2];
               a1y=a[aoffset2+1];
               a2x=a[aoffset4];
               a2y=a[aoffset4+1];
               a3x=a[aoffset6];
               a3y=a[aoffset6+1];
               t1x=a0x+a2x;
               t1y=a0y+a2y;
               t2x=a1x+a3x;
               t2y=a1y+a3y;
               m2x=a0x-a2x;
               m2y=a0y-a2y;
               m3x=a1y-a3y;
               m3y=a3x-a1x;
               tw2x=twx*twx-twy*twy;
               tw2y=2*twx*twy;
               tw3x=twx*tw2x-twy*tw2y;
               tw3y=twx*tw2y+twy*tw2x;
               a1x=m2x+m3x;
               a1y=m2y+m3y;
               a2x=t1x-t2x;
               a2y=t1y-t2y;
               a3x=m2x-m3x;
               a3y=m2y-m3y;
               a.Set(aoffset0,t1x+t2x);
               a.Set(aoffset0+1,t1y+t2y);
               a.Set(aoffset2,(a1x*twx-a1y*twy));
               a.Set(aoffset2+1,(a1y*twx+a1x*twy));
               a.Set(aoffset4,(a2x*tw2x-a2y*tw2y));
               a.Set(aoffset4+1,(a2y*tw2x+a2x*tw2y));
               a.Set(aoffset6,(a3x*tw3x-a3y*tw3y));
               a.Set(aoffset6+1,(a3y*tw3x+a3x*tw3y));
               aoffset0=aoffset0+2;
               aoffset2=aoffset2+2;
               aoffset4=aoffset4+2;
               aoffset6=aoffset6+2;
               if((mvidx+1)%m_updatetw==0)
                 {
                  v=-(2*M_PI*(mvidx+1)/(n*m));
                  twxm1=MathSin(0.5*v);
                  twxm1=-(2*twxm1*twxm1);
                  twy=MathSin(v);
                  twx=twxm1+1;
                 }
               else
                 {
                  v=twxm1+tw0+twxm1*tw0-twy*tw1;
                  twy=twy+tw1+twxm1*tw1+twy*tw0;
                  twxm1=v;
                  twx=v+1;
                 }
              }
           }
         break;
      case 5:
         v=-(2*M_PI/(n*m));
         tw0=-(2*CMath::Sqr(MathSin(0.5*v)));
         tw1=MathSin(v);
         v=2*M_PI/5;
         c1=(MathCos(v)+MathCos(2*v))/2-1;
         c2=(MathCos(v)-MathCos(2*v))/2;
         c3=-MathSin(v);
         c4=-(MathSin(v)+MathSin(2*v));
         c5=MathSin(v)-MathSin(2*v);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset0=offs+opidx*operandsize*microvectorsize;
            aoffset2=aoffset0+microvectorsize;
            aoffset4=aoffset2+microvectorsize;
            aoffset6=aoffset4+microvectorsize;
            aoffset8=aoffset6+microvectorsize;
            twx=1.0;
            twxm1=0.0;
            twy=0.0;
            for(mvidx=0; mvidx<m; mvidx++)
              {
               a0x=a[aoffset0];
               a0y=a[aoffset0+1];
               a1x=a[aoffset2];
               a1y=a[aoffset2+1];
               a2x=a[aoffset4];
               a2y=a[aoffset4+1];
               a3x=a[aoffset6];
               a3y=a[aoffset6+1];
               a4x=a[aoffset8];
               a4y=a[aoffset8+1];
               t1x=a1x+a4x;
               t1y=a1y+a4y;
               t2x=a2x+a3x;
               t2y=a2y+a3y;
               t3x=a1x-a4x;
               t3y=a1y-a4y;
               t4x=a3x-a2x;
               t4y=a3y-a2y;
               t5x=t1x+t2x;
               t5y=t1y+t2y;
               q0x=a0x+t5x;
               q0y=a0y+t5y;
               m1x=c1*t5x;
               m1y=c1*t5y;
               m2x=c2*(t1x-t2x);
               m2y=c2*(t1y-t2y);
               m3x=-(c3*(t3y+t4y));
               m3y=c3*(t3x+t4x);
               m4x=-(c4*t4y);
               m4y=c4*t4x;
               m5x=-(c5*t3y);
               m5y=c5*t3x;
               s3x=m3x-m4x;
               s3y=m3y-m4y;
               s5x=m3x+m5x;
               s5y=m3y+m5y;
               s1x=q0x+m1x;
               s1y=q0y+m1y;
               s2x=s1x+m2x;
               s2y=s1y+m2y;
               s4x=s1x-m2x;
               s4y=s1y-m2y;
               tw2x=twx*twx-twy*twy;
               tw2y=2*twx*twy;
               tw3x=twx*tw2x-twy*tw2y;
               tw3y=twx*tw2y+twy*tw2x;
               tw4x=tw2x*tw2x-tw2y*tw2y;
               tw4y=tw2x*tw2y+tw2y*tw2x;
               a1x=s2x+s3x;
               a1y=s2y+s3y;
               a2x=s4x+s5x;
               a2y=s4y+s5y;
               a3x=s4x-s5x;
               a3y=s4y-s5y;
               a4x=s2x-s3x;
               a4y=s2y-s3y;
               a.Set(aoffset0,q0x);
               a.Set(aoffset0+1,q0y);
               a.Set(aoffset2,(a1x*twx-a1y*twy));
               a.Set(aoffset2+1,(a1x*twy+a1y*twx));
               a.Set(aoffset4,(a2x*tw2x-a2y*tw2y));
               a.Set(aoffset4+1,(a2x*tw2y+a2y*tw2x));
               a.Set(aoffset6,(a3x*tw3x-a3y*tw3y));
               a.Set(aoffset6+1,(a3x*tw3y+a3y*tw3x));
               a.Set(aoffset8,(a4x*tw4x-a4y*tw4y));
               a.Set(aoffset8+1,(a4x*tw4y+a4y*tw4x));
               aoffset0=aoffset0+2;
               aoffset2=aoffset2+2;
               aoffset4=aoffset4+2;
               aoffset6=aoffset6+2;
               aoffset8=aoffset8+2;
               if((mvidx+1)%m_updatetw==0)
                 {
                  v=-(2*M_PI*(mvidx+1)/(n*m));
                  twxm1=MathSin(0.5*v);
                  twxm1=-(2*twxm1*twxm1);
                  twy=MathSin(v);
                  twx=twxm1+1;
                 }
               else
                 {
                  v=twxm1+tw0+twxm1*tw0-twy*tw1;
                  twy=twy+tw1+twxm1*tw1+twy*tw0;
                  twxm1=v;
                  twx=v+1;
                 }
              }
           }
         break;
      case 6:
         c1=MathCos(2*M_PI/3)-1;
         c2=MathSin(2*M_PI/3);
         c3=MathCos(-(M_PI/3));
         c4=MathSin(-(M_PI/3));
         v=-(2*M_PI/(n*m));
         tw0=-(2*CMath::Sqr(MathSin(0.5*v)));
         tw1=MathSin(v);
         for(opidx=0; opidx<operandscnt; opidx++)
           {
            aoffset0=offs+opidx*operandsize*microvectorsize;
            aoffset2=aoffset0+microvectorsize;
            aoffset4=aoffset2+microvectorsize;
            aoffset6=aoffset4+microvectorsize;
            aoffset8=aoffset6+microvectorsize;
            aoffset10=aoffset8+microvectorsize;
            twx=1.0;
            twxm1=0.0;
            twy=0.0;
            for(mvidx=0; mvidx<m; mvidx++)
              {
               a0x=a[aoffset0+0];
               a0y=a[aoffset0+1];
               a1x=a[aoffset2+0];
               a1y=a[aoffset2+1];
               a2x=a[aoffset4+0];
               a2y=a[aoffset4+1];
               a3x=a[aoffset6+0];
               a3y=a[aoffset6+1];
               a4x=a[aoffset8+0];
               a4y=a[aoffset8+1];
               a5x=a[aoffset10+0];
               a5y=a[aoffset10+1];
               v0=a0x;
               v1=a0y;
               a0x=a0x+a3x;
               a0y=a0y+a3y;
               a3x=v0-a3x;
               a3y=v1-a3y;
               v0=a1x;
               v1=a1y;
               a1x=a1x+a4x;
               a1y=a1y+a4y;
               a4x=v0-a4x;
               a4y=v1-a4y;
               v0=a2x;
               v1=a2y;
               a2x=a2x+a5x;
               a2y=a2y+a5y;
               a5x=v0-a5x;
               a5y=v1-a5y;
               t4x=a4x*c3-a4y*c4;
               t4y=a4x*c4+a4y*c3;
               a4x=t4x;
               a4y=t4y;
               t5x=-(a5x*c3)-a5y*c4;
               t5y=a5x*c4-a5y*c3;
               a5x=t5x;
               a5y=t5y;
               t1x=a1x+a2x;
               t1y=a1y+a2y;
               a0x=a0x+t1x;
               a0y=a0y+t1y;
               m1x=c1*t1x;
               m1y=c1*t1y;
               m2x=c2*(a1y-a2y);
               m2y=c2*(a2x-a1x);
               s1x=a0x+m1x;
               s1y=a0y+m1y;
               a1x=s1x+m2x;
               a1y=s1y+m2y;
               a2x=s1x-m2x;
               a2y=s1y-m2y;
               t1x=a4x+a5x;
               t1y=a4y+a5y;
               a3x=a3x+t1x;
               a3y=a3y+t1y;
               m1x=c1*t1x;
               m1y=c1*t1y;
               m2x=c2*(a4y-a5y);
               m2y=c2*(a5x-a4x);
               s1x=a3x+m1x;
               s1y=a3y+m1y;
               a4x=s1x+m2x;
               a4y=s1y+m2y;
               a5x=s1x-m2x;
               a5y=s1y-m2y;
               tw2x=twx*twx-twy*twy;
               tw2y=2*twx*twy;
               tw3x=twx*tw2x-twy*tw2y;
               tw3y=twx*tw2y+twy*tw2x;
               tw4x=tw2x*tw2x-tw2y*tw2y;
               tw4y=2*tw2x*tw2y;
               tw5x=tw3x*tw2x-tw3y*tw2y;
               tw5y=tw3x*tw2y+tw3y*tw2x;
               a.Set(aoffset0,a0x);
               a.Set(aoffset0+1,a0y);
               a.Set(aoffset2,(a3x*twx-a3y*twy));
               a.Set(aoffset2+1,(a3y*twx+a3x*twy));
               a.Set(aoffset4,(a1x*tw2x-a1y*tw2y));
               a.Set(aoffset4+1,(a1y*tw2x+a1x*tw2y));
               a.Set(aoffset6,(a4x*tw3x-a4y*tw3y));
               a.Set(aoffset6+1,(a4y*tw3x+a4x*tw3y));
               a.Set(aoffset8,(a2x*tw4x-a2y*tw4y));
               a.Set(aoffset8+1,(a2y*tw4x+a2x*tw4y));
               a.Set(aoffset10,(a5x*tw5x-a5y*tw5y));
               a.Set(aoffset10+1,(a5y*tw5x+a5x*tw5y));
               aoffset0=aoffset0+2;
               aoffset2=aoffset2+2;
               aoffset4=aoffset4+2;
               aoffset6=aoffset6+2;
               aoffset8=aoffset8+2;
               aoffset10=aoffset10+2;
               if((mvidx+1)%m_updatetw==0)
                 {
                  v=-(2*M_PI*(mvidx+1)/(n*m));
                  twxm1=MathSin(0.5*v);
                  twxm1=-(2*twxm1*twxm1);
                  twy=MathSin(v);
                  twx=twxm1+1;
                 }
               else
                 {
                  v=twxm1+tw0+twxm1*tw0-twy*tw1;
                  twy=twy+tw1+twxm1*tw1+twy*tw0;
                  twxm1=v;
                  twx=v+1;
                 }
              }
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| This subroutine precomputes data for complex Bluestein's  FFT    |
//| and writes them to array PrecR[] at specified offset. It  is     |
//| responsibility of the caller to make sure that PrecR[] is large  |
//| enough.                                                          |
//| INPUT PARAMETERS:                                                |
//|   N        -  original size of the transform                     |
//|   M       - size of the "padded" Bluestein's transform         |
//|   PrecR    -  preallocated array                                 |
//|   Offs     -  offset                                             |
//| OUTPUT PARAMETERS:                                               |
//|   PrecR    -  data at Offs:Offs+4*M-1 are modified:              |
//|            * PrecR[Offs:Offs+2*M-1] stores Z[k]=exp(i*pi*k^2/N)  |
//|            * PrecR[Offs+2*M:Offs+4*M-1] stores FFT of the Z      |
//|              Other parts of PrecR are unchanged.                 |
//| NOTE: this function performs internal M-point FFT. It allocates  |
//|       temporary plan which is destroyed after leaving this       |
//|       function.                                                  |
//+------------------------------------------------------------------+
void CFtBase::FtPrecomputeBluesteinsFFT(int n,int m,CRowDouble &precr,
                                        int offs)
  {
//--- create variables
   int     i=0;
   double  bx=0;
   double  by=0;
   CFtPlan plan;
//--- Fill first half of PrecR with b[k] = exp(i*pi*k^2/N)
   if(offs==0 && (int)precr.Size()<=2*m)
      precr=vector<double>::Zeros(2*m);
   else
      for(i=0; i<2*m; i++)
         precr.Set(offs+i,0);
   for(i=0; i<n; i++)
     {
      bx=MathCos(M_PI/n*i*i);
      by=MathSin(M_PI/n*i*i);
      precr.Set(offs+2*i,bx);
      precr.Set(offs+2*i+1,by);
      precr.Set(offs+2*((m-i)%m),bx);
      precr.Set(offs+2*((m-i)%m)+1,by);
     }
//--- Precomputed FFT
   FtComplexFFTPlan(m,1,plan);
   for(i=0; i<2*m; i++)
      precr.Set(offs+2*m+i,precr[offs+i]);
   FtApplySubPlan(plan,0,precr,offs+2*m,0,plan.m_buffer,1);
  }
//+------------------------------------------------------------------+
//| This subroutine applies complex Bluestein's FFT to input/output  |
//| array A.                                                         |
//| INPUT PARAMETERS:                                                |
//|   Plan           -  transformation plan                          |
//|   A              -  array, must be large enough for plan to work |
//|   ABase          -  base offset in array A, this value points to |
//|                     start of subarray whose length is equal to   |
//|                     length of the plan                           |
//|   AOffset        -  offset with respect to ABase,                |
//|                     0 <= AOffset < PlanLength.                   |
//|                     This is an offset within large               |
//|                     PlanLength-subarray of the chunk to process. |
//|   OperandsCnt    -  number of repeated operands (length N each)  |
//|   N              -  original data length (measured in complex    |
//|                     numbers)                                     |
//|   M              -  padded data length (measured in complex      |
//|                     numbers)                                     |
//|   PrecOffs       -  offset of the precomputed data for the plan  |
//|   SubPlan        -  position of the length-M FFT subplan which   |
//|                     is used by transformation                    |
//|   BufA           -  temporary buffer, at least 2*M elements      |
//|   BufB           -  temporary buffer, at least 2*M elements      |
//|   BufC           -  temporary buffer, at least 2*M elements      |
//|   BufD           -  temporary buffer, at least 2*M elements      |
//| OUTPUT PARAMETERS:                                               |
//|   A              -  transformed array                            |
//+------------------------------------------------------------------+
void CFtBase::FtBluesteinsFFT(CFtPlan &plan,CRowDouble &a,int abase,
                              int aoffset,int operandscnt,int n,
                              int m,int precoffs,int subplan,
                              CRowDouble &bufa,CRowDouble &bufb,
                              CRowDouble &bufc,CRowDouble &bufd)
  {
//--- create variables
   int    op=0;
   int    i=0;
   double x=0;
   double y=0;
   double bx=0;
   double by=0;
   double ax=0;
   double ay=0;
   double rx=0;
   double ry=0;
   int    p0=0;
   int    p1=0;
   int    p2=0;

   for(op=0; op<operandscnt; op++)
     {
      //--- Multiply A by conj(Z), store to buffer.
      //--- Pad A by zeros.
      //--- NOTE: Z[k]=exp(i*pi*k^2/N)
      p0=abase+aoffset+op*2*n;
      p1=precoffs;
      for(i=0; i<n; i++)
        {
         x=a[p0+0];
         y=a[p0+1];
         bx=plan.m_precr[p1+0];
         by=-plan.m_precr[p1+1];
         bufa.Set(2*i,(x*bx-y*by));
         bufa.Set(2*i+1,(x*by+y*bx));
         p0=p0+2;
         p1=p1+2;
        }
      for(i=2*n; i<2*m; i++)
         bufa.Set(i,0);
      //--- Perform convolution of A and Z (using precomputed
      //--- FFT of Z stored in Plan structure).
      FtApplySubPlan(plan,subplan,bufa,0,0,bufc,1);
      p0=0;
      p1=precoffs+2*m;
      for(i=0; i<m; i++)
        {
         ax=bufa[p0+0];
         ay=bufa[p0+1];
         bx=plan.m_precr[p1+0];
         by=plan.m_precr[p1+1];
         bufa.Set(p0,(ax*bx-ay*by));
         bufa.Set(p0+1,-(ax*by+ay*bx));
         p0=p0+2;
         p1=p1+2;
        }
      FtApplySubPlan(plan,subplan,bufa,0,0,bufc,1);
      //--- Post processing:
      //---     A:=conj(Z)*conj(A)/M
      //--- Here conj(A)/M corresponds to last stage of inverse DFT,
      //--- and conj(Z) comes from Bluestein's FFT algorithm.
      p0=precoffs;
      p1=0;
      p2=abase+aoffset+op*2*n;
      for(i=0; i<n; i++)
        {
         bx=plan.m_precr[p0+0];
         by=plan.m_precr[p0+1];
         rx=bufa[p1+0]/m;
         ry=-(bufa[p1+1]/m);
         a.Set(p2,(rx*bx-ry*-by));
         a.Set(p2+1,(rx*-by+ry*bx));
         p0=p0+2;
         p1=p1+2;
         p2=p2+2;
        }
     }
  }
//+------------------------------------------------------------------+
//| This subroutine precomputes data for complex Rader's FFT and     |
//| writes them to array PrecR[] at specified offset. It  is         |
//| responsibility of the caller to make sure that PrecR[] is large  |
//| enough.                                                          |
//| INPUT PARAMETERS:                                                |
//|   N           -  original size of the transform (before reduction|
//|                  to N-1)                                         |
//|   RQ          -  primitive root modulo N                         |
//|   RIQ         -  inverse of primitive root modulo N              |
//|   PrecR       -  preallocated array                              |
//|   Offs        -  offset                                          |
//| OUTPUT PARAMETERS:                                               |
//|   PrecR       -  data at Offs:Offs+2*(N-1)-1 store FFT of Rader's|
//|                  factors, other parts of PrecR are unchanged.    |
//| NOTE: this function performs internal (N-1)-point FFT. It        |
//|       allocates temporary plan which is destroyed after leaving  |
//|       this function.                                             |
//+------------------------------------------------------------------+
void CFtBase::FtPrecomputeRadersFFT(int n,int rq,int riq,CRowDouble &precr,
                                    int offs)
  {
//--- create variables
   int     q=0;
   CFtPlan plan;
   int     kiq=0;
   double  v=0;
//-- Fill PrecR with Rader factors, perform FFT
   kiq=1;
   for(q=0; q<n-1; q++)
     {
      v=-(2*M_PI*kiq/n);
      precr.Set(offs+2*q,MathCos(v));
      precr.Set(offs+2*q+1,MathSin(v));
      kiq=kiq*riq%n;
     }
   FtComplexFFTPlan(n-1,1,plan);
   FtApplySubPlan(plan,0,precr,offs,0,plan.m_buffer,1);
  }
//+------------------------------------------------------------------+
//| This subroutine applies complex Rader's FFT to input/output      |
//| array A.                                                         |
//| INPUT PARAMETERS:                                                |
//|   A           -  array, must be large enough for plan to work    |
//|   ABase       -  base offset in array A, this value points to    |
//|                  start of subarray whose length is equal to      |
//|                  length of the plan                              |
//|   AOffset     -  offset with respect to ABase,                   |
//|                  0 <= AOffset < PlanLength.                      |
//|                  This is an offset within large                  |
//|                  PlanLength-subarray of the chunk to process.    |
//|   OperandsCnt -  number of repeated operands (length N each)     |
//|   N           -  original data length (measured in complex       |
//|                  numbers)                                        |
//|   SubPlan     -  position of the (N-1)-point FFT subplan which   |
//|                  is used by transformation                       |
//|   RQ          -  primitive root modulo N                         |
//|   RIQ         -  inverse of primitive root modulo N              |
//|   PrecOffs    -  offset of the precomputed data for the plan     |
//|   Buf         -  temporary array                                 |
//| OUTPUT PARAMETERS:                                               |
//|   A           -  transformed array                               |
//+------------------------------------------------------------------+
void CFtBase::FtRadersFFT(CFtPlan &plan,CRowDouble &a,int abase,
                          int aoffset,int operandscnt,int n,
                          int subplan,int rq,int riq,int precoffs,
                          CRowDouble &buf)
  {
//--- create variables
   int    opidx=0;
   int    i=0;
   int    q=0;
   int    kq=0;
   int    kiq=0;
   double x0=0;
   double y0=0;
   int    p0=0;
   int    p1=0;
   double ax=0;
   double ay=0;
   double bx=0;
   double by=0;
   double rx=0;
   double ry=0;
//--- check
   if(!CAp::Assert(operandscnt>=1,__FUNCTION__": OperandsCnt<1"))
      return;
//--- Process operands
   for(opidx=0; opidx<operandscnt; opidx++)
     {
      //--- fill QA
      kq=1;
      p0=abase+aoffset+opidx*n*2;
      p1=aoffset+opidx*n*2;
      rx=a[p0+0];
      ry=a[p0+1];
      x0=rx;
      y0=ry;
      for(q=0; q<n-1; q++)
        {
         ax=a[p0+2*kq];
         ay=a[p0+2*kq+1];
         buf.Set(p1,ax);
         buf.Set(p1+1,ay);
         rx=rx+ax;
         ry=ry+ay;
         kq=kq*rq%n;
         p1=p1+2;
        }
      p0=abase+aoffset+opidx*n*2;
      p1=aoffset+opidx*n*2;
      for(q=0; q<n-1; q++)
        {
         a.Set(p0,buf[p1]);
         a.Set(p0+1,buf[p1+1]);
         p0+=2;
         p1+=2;
        }
      //--- Convolution
      FtApplySubPlan(plan,subplan,a,abase,aoffset+opidx*n*2,buf,1);
      p0=abase+aoffset+opidx*n*2;
      p1=precoffs;
      for(i=0; i<n-1; i++)
        {
         ax=a[p0+0];
         ay=a[p0+1];
         bx=plan.m_precr[p1+0];
         by=plan.m_precr[p1+1];
         a.Set(p0+0,(ax*bx-ay*by));
         a.Set(p0+1,-(ax*by+ay*bx));
         p0+=2;
         p1+=2;
        }
      FtApplySubPlan(plan,subplan,a,abase,aoffset+opidx*n*2,buf,1);
      p0=abase+aoffset+opidx*n*2;
      for(i=0; i<n-1; i++)
        {
         a.Set(p0,a[p0]/(n-1));
         a.Set(p0+1,-(a[p0+1]/(n-1)));
         p0=p0+2;
        }
      //--- Result
      buf.Set(aoffset+opidx*n*2,rx);
      buf.Set(aoffset+opidx*n*2+1,ry);
      kiq=1;
      p0=aoffset+opidx*n*2;
      p1=abase+aoffset+opidx*n*2;
      for(q=0; q<n-1; q++)
        {
         buf.Set(p0+2*kiq+0,(x0+a[p1+0]));
         buf.Set(p0+2*kiq+1,(y0+a[p1+1]));
         kiq=kiq*riq%n;
         p1=p1+2;
        }
      p0=abase+aoffset+opidx*n*2;
      p1=aoffset+opidx*n*2;
      for(q=0; q<n; q++)
        {
         a.Set(p0,buf[p1]);
         a.Set(p0+1,buf[p1+1]);
         p0+=2;
         p1+=2;
        }
     }
  }
//+------------------------------------------------------------------+
//| Factorizes task size N into product of two smaller sizes N1      |
//| and N2                                                           |
//| INPUT PARAMETERS:                                                |
//|   N        -  task size, N>0                                     |
//|   IsRoot   -  whether taks is root task (first one in a sequence)|
//| OUTPUT PARAMETERS:                                               |
//|   N1, N2   -  such numbers that:                                 |
//|               * for prime N:                  N1=N2=0            |
//|               * for composite N<=MaxRadix:    N1=N2=0            |
//|               * for composite N>MaxRadix:     1<=N1<=N2, N1*N2=N |
//+------------------------------------------------------------------+
void CFtBase::FtFactorize(int n,bool IsRoot,int &n1,int &n2)
  {
//---check
   if(!CAp::Assert(n>0,__FUNCTION__": N<=0"))
      return;
//--- create variables
   int j=0;
   int k=0;
   n1=0;
   n2=0;
//--- Small N
   if(n<=m_MaxRadix)
      return;
//--- Large N, recursive split
   if(n>m_recursivethreshold)
     {
      k=(int)MathCeil(MathSqrt(n))+1;
      if(!CAp::Assert(k*k>=n,__FUNCTION__": internal error during recursive factorization"))
         return;
      for(j=k; j>=2; j--)
        {
         if(n%j==0)
           {
            n1=MathMin(n/j,j);
            n2=MathMax(n/j,j);
            return;
           }
        }
     }
//--- N > MaxRadix, try to find good codelet
   for(j=m_MaxRadix; j>=2; j--)
     {
      if(n%j==0)
        {
         n1=j;
         n2=n/j;
         break;
        }
     }
//--- In case no good codelet was found,
//--- try to factorize N into product of ANY primes.
   if(n1*n2!=n)
     {
      for(j=2; j<n; j++)
        {
         if(n%j==0)
           {
            n1=j;
            n2=n/j;
            break;
           }
         if(j*j>n)
            break;
        }
     }
//--- normalize
   if(n1>n2)
     {
      j=n1;
      n1=n2;
      n2=j;
     }
  }
//+------------------------------------------------------------------+
//| Returns optimistic estimate of the FFT cost, in UNITs            |
//| (1 UNIT = 100 KFLOPs)                                            |
//| INPUT PARAMETERS:                                                |
//|   N        -  task size, N>0                                     |
//| RESULT: cost in UNITs, rounded down to nearest integer           |
//| NOTE: If FFT cost is less than 1 UNIT, it will return 0 as result|
//+------------------------------------------------------------------+
int CFtBase::FtOptimisticEstimate(int n)
  {
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__": N<=0"))
      return(0);

   int result=(int)MathFloor(1.0E-5*5*n*MathLog(n)/MathLog(2));
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Twiddle factors calculation                                      |
//+------------------------------------------------------------------+
void CFtBase::FFtTwCalc(CRowDouble &a,const int aoffset,const int n1,
                        const int n2)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    n=0;
   int    halfn1=0;
   int    offs=0;
   double x=0;
   double y=0;
   double twxm1=0;
   double twy=0;
   double twbasexm1=0;
   double twbasey=0;
   double twrowxm1=0;
   double twrowy=0;
   double tmpx=0;
   double tmpy=0;
   double v=0;
   int    updatetw2=0;
//--- Multiplication by twiddle factors for complex Cooley-Tukey FFT
//--- with N factorized as N1*N2.
//--- Naive solution to this problem is given below:
//---     > for K:=1 to N2-1 do
//---     >     for J:=1 to N1-1 do
//---     >     begin
//---     >         Idx:=K*N1+J;
//---     >         X:=A[AOffset+2*Idx+0];
//---     >         Y:=A[AOffset+2*Idx+1];
//---     >         TwX:=Cos(-2*Pi()*K*J/(N1*N2));
//---     >         TwY:=Sin(-2*Pi()*K*J/(N1*N2));
//---     >         A[AOffset+2*Idx+0]:=X*TwX-Y*TwY;
//---     >         A[AOffset+2*Idx+1]:=X*TwY+Y*TwX;
//---     >     end;
//--- However, there are exist more efficient solutions.
//--- Each pass of the inner cycle corresponds to multiplication of one
//--- entry of A by W[k,j]=exp(-I*2*pi*k*j/N). This factor can be rewritten
//--- as exp(-I*2*pi*k/N)^j. So we can replace costly exponentiation by
//--- repeated multiplication: W[k,j+1]=W[k,j]*exp(-I*2*pi*k/N), with
//--- second factor being computed once in the beginning of the iteration.
//--- Also, exp(-I*2*pi*k/N) can be represented as exp(-I*2*pi/N)^k, i.e.
//--- we have W[K+1,1]=W[K,1]*W[1,1].
//--- In our loop we use following variables:
//--- * [TwBaseXM1,TwBaseY] =   [cos(2*pi/N)-1,     sin(2*pi/N)]
//--- * [TwRowXM1, TwRowY]  =   [cos(2*pi*I/N)-1,   sin(2*pi*I/N)]
//--- * [TwXM1,    TwY]     =   [cos(2*pi*I*J/N)-1, sin(2*pi*I*J/N)]
//--- Meaning of the variables:
//--- * [TwXM1,TwY] is current twiddle factor W[I,J]
//--- * [TwRowXM1, TwRowY] is W[I,1]
//--- * [TwBaseXM1,TwBaseY] is W[1,1]
//--- During inner loop we multiply current twiddle factor by W[I,1],
//--- during outer loop we update W[I,1].
   if(!CAp::Assert(m_updatetw>=2,__FUNCTION__": internal error - UpdateTw<2"))
      return;
   updatetw2=m_updatetw/2;
   halfn1=n1/2;
   n=n1*n2;
   v=-(2*M_PI/n);
   twbasexm1=-(2*CMath::Sqr(MathSin(0.5*v)));
   twbasey=MathSin(v);
   twrowxm1=0;
   twrowy=0;
   offs=aoffset;
//--- calculation
   for(i=0; i<n2; i++)
     {
      //--- Initialize twiddle factor for current row
      twxm1=0;
      twy=0;
      //--- N1-point block is separated into 2-point chunks and residual 1-point chunk
      //--- (in case N1 is odd). Unrolled loop is several times faster.
      for(j=0; j<halfn1; j++)
        {
         //--- Processing:
         //--- * process first element in a chunk.
         //--- * update twiddle factor (unconditional update)
         //--- * process second element
         //--- * conditional update of the twiddle factor
         x=a[offs];
         y=a[offs+1];
         tmpx=x*(1+twxm1)-y*twy;
         tmpy=x*twy+y*(1+twxm1);
         a.Set(offs,tmpx);
         a.Set(offs+1,tmpy);
         tmpx=(1+twxm1)*twrowxm1-twy*twrowy;
         twy+=(1+twxm1)*twrowy+twy*twrowxm1;
         twxm1+=tmpx;
         x=a[offs+2];
         y=a[offs+3];
         tmpx=x*(1+twxm1)-y*twy;
         tmpy=x*twy+y*(1+twxm1);
         a.Set(offs+2,tmpx);
         a.Set(offs+3,tmpy);
         offs+=4;
         if((j+1)%updatetw2==0 && j<halfn1-1)
           {
            //--- Recalculate twiddle factor
            v=-(2*M_PI*i*2*(j+1)/n);
            twxm1=MathSin(0.5*v);
            twxm1=-(2*twxm1*twxm1);
            twy=MathSin(v);
           }
         else
           {
            //--- Update twiddle factor
            tmpx=(1+twxm1)*twrowxm1-twy*twrowy;
            twy+=(1+twxm1)*twrowy+twy*twrowxm1;
            twxm1+=tmpx;
           }
        }
      if(n1%2==1)
        {
         //--- Handle residual chunk
         x=a[offs+0];
         y=a[offs+1];
         tmpx=x*(1+twxm1)-y*twy;
         tmpy=x*twy+y*(1+twxm1);
         a.Set(offs,tmpx);
         a.Set(offs+1,tmpy);
         offs+=2;
        }
      //--- update TwRow: TwRow(new) = TwRow(old)*TwBase
      if(i<n2-1)
        {
         if((i+1)%m_updatetw==0)
           {
            v=-(2*M_PI*(i+1)/n);
            twrowxm1=MathSin(0.5*v);
            twrowxm1=-(2*twrowxm1*twrowxm1);
            twrowy=MathSin(v);
           }
         else
           {
            tmpx=twbasexm1+twrowxm1*twbasexm1-twrowy*twbasey;
            tmpy=twbasey+twrowxm1*twbasey+twrowy*twbasexm1;
            twrowxm1+=tmpx;
            twrowy+=tmpy;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Linear transpose: transpose complex matrix stored in             |
//| 1-dimensional array                                              |
//+------------------------------------------------------------------+
void CFtBase::InternalComplexLinTranspose(CRowDouble &a,const int m,
                                          const int n,const int astart,
                                          CRowDouble &buf)
  {
//--- function call
   FFtICLTRec(a,astart,n,buf,0,m,m,n);
   int i1_=-astart;
//--- calculation
   for(int i_=astart; i_<(astart+2*m*n); i_++)
      a.Set(i_,buf[i_+i1_]);
  }
//+------------------------------------------------------------------+
//| Linear transpose: transpose real matrix stored in 1-dimensional  |
//| array                                                            |
//+------------------------------------------------------------------+
void CFtBase::InternalRealLinTranspose(CRowDouble &a,const int m,
                                       const int n,const int astart,
                                       CRowDouble &buf)
  {
//--- function call
   FFtIRLTRec(a,astart,n,buf,0,m,m,n);
   int i1_=-astart;
//--- calculation
   for(int i_=astart; i_<(astart+m*n); i_++)
      a.Set(i_,buf[i_+i1_]);
  }
//+------------------------------------------------------------------+
//| Recurrent subroutine for a InternalComplexLinTranspose           |
//| Write A^T to B, where:                                           |
//| * A is m*n complex matrix stored in array A as pairs of          |
//|   real/image values, beginning from AStart position, with AStride|
//|   stride                                                         |
//| * B is n*m complex matrix stored in array B as pairs of          |
//|   real/image values, beginning from BStart position, with BStride|
//|   stride                                                         |
//| stride is measured in complex numbers, i.e. in real/image pairs. |
//+------------------------------------------------------------------+
void CFtBase::FFtICLTRec(CRowDouble &a,const int astart,const int astride,
                         CRowDouble &b,const int bstart,const int bstride,
                         const int m,const int n)
  {
//--- create variables
   int i=0;
   int j=0;
   int idx1=0;
   int idx2=0;
   int m2=0;
   int m1=0;
   int n1=0;
//--- check
   if(m==0 || n==0)
      return;
//--- check
   if(MathMax(m,n)<=8)
     {
      m2=2*bstride;
      for(i=0; i<m; i++)
        {
         //--- calculation
         idx1=bstart+2*i;
         idx2=astart+2*i*astride;
         for(j=0; j<n; j++)
           {
            b.Set(idx1,a[idx2+0]);
            b.Set(idx1+1,a[idx2+1]);
            idx1+=m2;
            idx2+=2;
           }
        }
      //--- exit the function
      return;
     }
//--- check
   if(n>m)
     {
      //--- New partition:
      //--- "A^T -> B" becomes "(A1 A2)^T -> ( B1 )
      //---                                  ( B2 )
      n1=n/2;
      //--- check
      if(n-n1>=8 && n1%8!=0)
         n1+=(8-n1%8);
      //--- check
      if(!CAp::Assert(n-n1>0))
         return;
      //--- function call
      FFtICLTRec(a,astart,astride,b,bstart,bstride,m,n1);
      //--- function call
      FFtICLTRec(a,astart+2*n1,astride,b,bstart+2*n1*bstride,bstride,m,n-n1);
     }
   else
     {
      //--- New partition:
      //--- "A^T -> B" becomes "( A1 )^T -> ( B1 B2 )
      //---                     ( A2 )
      m1=m/2;
      //--- check
      if(m-m1>=8 && m1%8!=0)
         m1+=(8-m1%8);
      //--- check
      if(!CAp::Assert(m-m1>0))
         return;
      //--- function call
      FFtICLTRec(a,astart,astride,b,bstart,bstride,m1,n);
      //--- function call
      FFtICLTRec(a,astart+2*m1*astride,astride,b,bstart+2*m1,bstride,m-m1,n);
     }
  }
//+------------------------------------------------------------------+
//| Recurrent subroutine for a InternalRealLinTranspose              |
//+------------------------------------------------------------------+
void CFtBase::FFtIRLTRec(CRowDouble &a,const int astart,const int astride,
                         CRowDouble &b,const int bstart,const int bstride,
                         const int m,const int n)
  {
//--- create variables
   int i=0;
   int j=0;
   int idx1=0;
   int idx2=0;
   int m1=0;
   int n1=0;
//--- check
   if(m==0 || n==0)
      return;
//--- check
   if(MathMax(m,n)<=8)
     {
      for(i=0; i<m; i++)
        {
         //--- calculation
         idx1=bstart+i;
         idx2=astart+i*astride;
         for(j=0; j<n; j++)
           {
            b.Set(idx1,a[idx2]);
            idx1=idx1+bstride;
            idx2=idx2+1;
           }
        }
      //--- exit the function
      return;
     }
//--- check
   if(n>m)
     {
      //--- New partition:
      //--- "A^T -> B" becomes "(A1 A2)^T -> ( B1 )
      //---                                  ( B2 )
      n1=n/2;
      //--- check
      if(n-n1>=8 && n1%8!=0)
         n1+=(8-n1%8);
      //--- check
      if(!CAp::Assert(n-n1>0))
         return;
      //--- function call
      FFtIRLTRec(a,astart,astride,b,bstart,bstride,m,n1);
      //--- function call
      FFtIRLTRec(a,astart+n1,astride,b,bstart+n1*bstride,bstride,m,n-n1);
     }
   else
     {
      //--- New partition:
      //--- "A^T -> B" becomes "( A1 )^T -> ( B1 B2 )
      //---                     ( A2 )
      m1=m/2;
      //--- check
      if(m-m1>=8 && m1%8!=0)
         m1+=(8-m1%8);
      //--- check
      if(!CAp::Assert(m-m1>0))
         return;
      //--- function call
      FFtIRLTRec(a,astart,astride,b,bstart,bstride,m1,n);
      //--- function call
      FFtIRLTRec(a,astart+m1*astride,astride,b,bstart+m1,bstride,m-m1,n);
     }
  }
//+------------------------------------------------------------------+
//| recurrent subroutine for FFTFindSmoothRec                        |
//+------------------------------------------------------------------+
void CFtBase::FtBaseFindSmoothRec(const int n,const int seed,
                                  const int leastfactor,int &best)
  {
//--- check
   if(!CAp::Assert(m_ftbasemaxsmoothfactor<=5,__FUNCTION__+": internal error!"))
      return;
//--- check
   if(seed>=n)
     {
      best=MathMin(best,seed);
      return;
     }
//--- check
   if(leastfactor<=2)
     {
      //--- function call
      FtBaseFindSmoothRec(n,seed*2,2,best);
     }
//--- check
   if(leastfactor<=3)
     {
      //--- function call
      FtBaseFindSmoothRec(n,seed*3,3,best);
     }
//--- check
   if(leastfactor<=5)
     {
      //--- function call
      FtBaseFindSmoothRec(n,seed*5,5,best);
     }
  }
//+------------------------------------------------------------------+
//| Auxiliary class for calculation mathematical functions           |
//+------------------------------------------------------------------+
class CNearUnitYUnit
  {
public:
   static double     NULog1p(const double x);
   static double     NUExp1m(const double x);
   static double     NUCos1m(const double x);
  };
//+------------------------------------------------------------------+
//| Log                                                              |
//+------------------------------------------------------------------+
double CNearUnitYUnit::NULog1p(const double x)
  {
//--- create variables
   double z=1.0+x;
   double lp=0;
   double lq=0;
//--- check
   if(z<0.70710678118654752440 || z>1.41421356237309504880)
      return(MathLog(z));
//--- calculation result
   z=x*x;
   lp=4.5270000862445199635215E-5;
   lp=lp*x+4.9854102823193375972212E-1;
   lp=lp*x+6.5787325942061044846969E0;
   lp=lp*x+2.9911919328553073277375E1;
   lp=lp*x+6.0949667980987787057556E1;
   lp=lp*x+5.7112963590585538103336E1;
   lp=lp*x+2.0039553499201281259648E1;
   lq=1.0000000000000000000000E0;
   lq=lq*x+1.5062909083469192043167E1;
   lq=lq*x+8.3047565967967209469434E1;
   lq=lq*x+2.2176239823732856465394E2;
   lq=lq*x+3.0909872225312059774938E2;
   lq=lq*x+2.1642788614495947685003E2;
   lq=lq*x+6.0118660497603843919306E1;
   z=-(0.5*z)+x*(z*lp/lq);
//--- return result
   return(x+z);
  }
//+------------------------------------------------------------------+
//| Exp                                                              |
//+------------------------------------------------------------------+
double CNearUnitYUnit::NUExp1m(const double x)
  {
//--- create variables
   double r;
   double xx;
   double ep;
   double eq;
//--- check
   if(x<-0.5 || x>0.5)
      return(MathExp(x)-1.0);
//--- calculation result
   xx=x*x;
   ep=1.2617719307481059087798E-4;
   ep=ep*xx+3.0299440770744196129956E-2;
   ep=ep*xx+9.9999999999999999991025E-1;
   eq=3.0019850513866445504159E-6;
   eq=eq*xx+2.5244834034968410419224E-3;
   eq=eq*xx+2.2726554820815502876593E-1;
   eq=eq*xx+2.0000000000000000000897E0;
   r=x*ep;
   r=r/(eq-r);
//--- return result
   return(r+r);
  }
//+------------------------------------------------------------------+
//| Cos                                                              |
//+------------------------------------------------------------------+
double CNearUnitYUnit::NUCos1m(const double x)
  {
//--- create variables
   double xx;
   double c;
//--- check
   if(x<-0.25*M_PI || x>0.25*M_PI)
      return(MathCos(x)-1);
//--- get result
   xx=x*x;
   c=4.7377507964246204691685E-14;
   c=c*xx-1.1470284843425359765671E-11;
   c=c*xx+2.0876754287081521758361E-9;
   c=c*xx-2.7557319214999787979814E-7;
   c=c*xx+2.4801587301570552304991E-5;
   c=c*xx-1.3888888888888872993737E-3;
   c=c*xx+4.1666666666666666609054E-2;
//--- return result
   return(-(0.5*xx)+xx*xx*c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNTheory
  {
public:
   static void       FindPrimitiveRootAndInverse(int n,int &proot,int &invproot);

private:
   static bool       IsPrime(int n);
   static int        ModMul(int a,int b,int n);
   static int        ModExp(int a,int b,int n);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNTheory::FindPrimitiveRootAndInverse(int n,int &proot,int &invproot)
  {
//---check
   if(!CAp::Assert(n>=3,__FUNCTION__": N<3"))
      return;
//--- create variables
   int  candroot=0;
   int  phin=0;
   int  q=0;
   int  f=0;
   bool allnonone;
   int  x=0;
   int  lastx=0;
   int  y=0;
   int  lasty=0;
   int  a=0;
   int  b=0;
   int  t=0;
   int  n2=0;

   proot=0;
   invproot=0;
//--- check that N is prime
   if(!CAp::Assert(IsPrime(n),__FUNCTION__": N is not prime"))
      return;
//--- Because N is prime, Euler totient function is equal to N-1
   phin=n-1;
//--- Test different values of PRoot - from 2 to N-1.
//--- One of these values MUST be primitive root.
//--- For testing we use algorithm from Wiki (Primitive root modulo n):
//--- * compute phi(N)
//--- * determine the different prime factors of phi(N), say p1, ..., pk
//--- * for every element m of Zn*, compute m^(phi(N)/pi) mod N for i=1..k
//---   using a fast algorithm for modular exponentiation.
//--- * a number m for which these k results are all different from 1 is a
//---   primitive root.
   for(candroot=2; candroot<n; candroot++)
     {
      //--- We have current candidate root in CandRoot.
      //--- Scan different prime factors of PhiN. Here:
      //--- * F is a current candidate factor
      //--- * Q is a current quotient - amount which was left after dividing PhiN
      //---   by all previous factors
      //--- For each factor, perform test mentioned above.
      q=phin;
      f=2;
      allnonone=true;
      while(q>1)
        {
         if(q%f==0)
           {
            t=ModExp(candroot,phin/f,n);
            if(t==1)
              {
               allnonone=false;
               break;
              }
            while(q%f==0)
               q=q/f;
           }
         f++;
        }
      if(allnonone)
        {
         proot=candroot;
         break;
        }
     }
   if(!CAp::Assert(proot>=2,__FUNCTION__": internal error (root not found)"))
      return;
//--- Use extended Euclidean algorithm to find multiplicative inverse of primitive root
   x=0;
   lastx=1;
   y=1;
   lasty=0;
   a=proot;
   b=n;
   while(b!=0)
     {
      q=a/b;
      t=a%b;
      a=b;
      b=t;
      t=lastx-q*x;
      lastx=x;
      x=t;
      t=lasty-q*y;
      lasty=y;
      y=t;
     }
   while(lastx<0)
      lastx+=n;
   invproot=lastx;
//--- Check that it is safe to perform multiplication modulo N.
//--- Check results for consistency.
   n2=(n-1)*(n-1);
   if(!CAp::Assert(n2/(n-1)==n-1,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(proot*invproot/proot==invproot,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(proot*invproot/invproot==proot,__FUNCTION__": internal error"))
      return;
   if(!CAp::Assert(proot*invproot%n==1,__FUNCTION__": internal error"))
      return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNTheory::IsPrime(int n)
  {
   int p=2;

   while(p*p<=n)
     {
      if(n%p==0)
         return(false);
      p++;
     }
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNTheory::ModMul(int a,int b,int n)
  {
//--- create variables
   int    result=0;
   int    t=0;
   double ra=(double)a;
   double rb=(double)b;
//--- check
   if(!CAp::Assert(a>=0 && a<n,__FUNCTION__": A<0 or A>=N"))
      return(result);
   if(!CAp::Assert(b>=0 && b<n,__FUNCTION__": B<0 or B>=N"))
      return(result);
//--- Base cases
   if(b==0 || a==0)
      return(result);

   if(b==1 || a==1)
      return(a*b);

   if((ra*rb)==(double)(a*b))
      return(a*b%n);
//--- Non-base cases
   if(b%2==0)
     {
      //--- A*B = (A*(B/2)) * 2
      //--- Product T=A*(B/2) is calculated recursively, product T*2 is
      //--- calculated as follows:
      //--- * result:=T-N
      //--- * result:=result+T
      //--- * if result<0 then result:=result+N
      //--- In case integer result overflows, we generate exception
      t=ModMul(a,b/2,n);
      result=2*t-n;
      if(result<0)
         result+=n;
     }
   else
     {
      //--- A*B = (A*(B div 2)) * 2 + A
      //--- Product T=A*(B/2) is calculated recursively, product T*2 is
      //--- calculated as follows:
      //--- * result:=T-N
      //--- * result:=result+T
      //--- * if result<0 then result:=result+N
      //--- In case integer result overflows, we generate exception
      t=ModMul(a,b/2,n);
      result=2*t-n;
      if(result<0)
         result=result+n;
      result=result-n;
      result=result+a;
      if(result<0)
         result=result+n;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNTheory::ModExp(int a,int b,int n)
  {
//--- create variables
   int result=0;
   int t=0;
//--- check
   if(!CAp::Assert(a>=0 && a<n,__FUNCTION__": A<0 or A>=N"))
      return(result);
   if(!CAp::Assert(b>=0,__FUNCTION__": B<0"))
      return(result);
//--- Base cases
   if(b==0)
     {
      result=1;
      return(result);
     }
   if(b==1)
     {
      result=a;
      return(result);
     }
//--- Non-base cases
   if(b%2==0)
     {
      t=ModMul(a,a,n);
      result=ModExp(t,b/2,n);
     }
   else
     {
      t=ModMul(a,a,n);
      result=ModExp(t,b/2,n);
      result=ModMul(result,a,n);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| This structure stores temporary buffers used by gradient         |
//| calculation functions for neural networks.                       |
//+------------------------------------------------------------------+
struct CMLPBuffers
  {
   int               m_ChunkSize;
   int               m_NTotal;
   int               m_NIn;
   int               m_NOut;
   int               m_WCount;
   CRowDouble        m_Batch4Buf;
   CRowDouble        m_HPCBuf;
   CMatrixDouble     m_XY;
   CMatrixDouble     m_XY2;
   CRowDouble        m_XYRow;
   CRowDouble        m_X;
   CRowDouble        m_Y;
   CRowDouble        m_Desiredy;
   double            m_E;
   CRowDouble        m_G;
   CRowDouble        m_Tmp0;
   //--- constructor / destructor
                     CMLPBuffers(void) { m_ChunkSize=0; m_NTotal=0; m_NIn=0; m_NOut=0; m_WCount=0; m_E=0; }
                    ~CMLPBuffers(void) {}
   //---
   void              Copy(CMLPBuffers &obj);
   //--- overloading
   void              operator=(CMLPBuffers &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CMLPBuffers::Copy(CMLPBuffers &obj)
  {
   m_ChunkSize=obj.m_ChunkSize;
   m_NTotal=obj.m_NTotal;
   m_NIn=obj.m_NIn;
   m_NOut=obj.m_NOut;
   m_WCount=obj.m_WCount;
   m_Batch4Buf=obj.m_Batch4Buf;
   m_HPCBuf=obj.m_HPCBuf;
   m_XY=obj.m_XY;
   m_XY2=obj.m_XY2;
   m_XYRow=obj.m_XYRow;
   m_X=obj.m_X;
   m_Y=obj.m_Y;
   m_Desiredy=obj.m_Desiredy;
   m_E=obj.m_E;
   m_G=obj.m_G;
   m_Tmp0=obj.m_Tmp0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPCCores
  {
public:
   static void       HPCPrepareChunkedGradient(CRowDouble &weights,int wcount,int NTotal,int NIn,int NOut,CMLPBuffers &buf);
   static void       HPCFinalizeChunkedGradient(CMLPBuffers &buf,CRowDouble &grad);
  };
//+------------------------------------------------------------------+
//| Prepares HPC compuations  of  chunked  gradient with             |
//| HPCChunkedGradient().                                            |
//| You  have to call this function  before  calling                 |
//| HPCChunkedGradient() for a new set of weights. You have to call  |
//| it only once, see example below:                                 |
//|   HOW TO PROCESS DATASET WITH THIS FUNCTION:                     |
//|      Grad:=0                                                     |
//|      HPCPrepareChunkedGradient(Weights,WCount,NTotal,NOut,Buf)   |
//|      foreach chunk-of-dataset do                                 |
//|         HPCChunkedGradient(...)                                  |
//|      HPCFinalizeChunkedGradient(Buf, Grad)                       |
//+------------------------------------------------------------------+
void CHPCCores::HPCPrepareChunkedGradient(CRowDouble &weights,
                                          int wcount,
                                          int NTotal,
                                          int NIn,
                                          int NOut,
                                          CMLPBuffers &buf)
  {
//--- create variables
   int ChunkSize=4;
   int batch4size=3*ChunkSize*NTotal+ChunkSize*(2*NOut+1);
//--- allocated
   if((int)buf.m_XY.Rows()<ChunkSize || (int)buf.m_XY.Cols()<(NIn+NOut))
      buf.m_XY.Resize(ChunkSize,NIn+NOut);
   if((int)buf.m_XY2.Rows()<ChunkSize || (int)buf.m_XY2.Cols()<(NIn+NOut))
      buf.m_XY2.Resize(ChunkSize,NIn+NOut);
   if((int)buf.m_XYRow.Size()<(NIn+NOut))
      buf.m_XYRow.Resize((ulong)(NIn+NOut));
   if((int)buf.m_X.Size()<NIn)
      buf.m_X.Resize(NIn);
   if((int)buf.m_Y.Size()<NOut)
      buf.m_Y.Resize(NOut);
   if((int)buf.m_Desiredy.Size()<NOut)
      buf.m_Desiredy.Resize(NOut);
   if((int)buf.m_Batch4Buf.Size()<batch4size)
      buf.m_Batch4Buf.Resize(batch4size);
   if((int)buf.m_G.Size()<wcount)
      buf.m_G.Resize(wcount);
   buf.m_HPCBuf=vector<double>::Zeros(wcount);
   buf.m_WCount=wcount;
   buf.m_NTotal=NTotal;
   buf.m_NIn=NIn;
   buf.m_NOut=NOut;
   buf.m_ChunkSize=ChunkSize;
  }
//+------------------------------------------------------------------+
//| Finalizes HPC compuations  of  chunked gradient with             |
//| HPCChunkedGradient().                                            |
//| You have to call this function after calling HPCChunkedGradient()|
//| for a new set of weights. You have to call it only once, see     |
//| example below:                                                   |
//|   HOW TO PROCESS DATASET WITH THIS FUNCTION:                     |
//|      Grad:=0                                                     |
//|      HPCPrepareChunkedGradient(Weights,WCount,NTotal,NOut,Buf)   |
//|      foreach chunk-of-dataset do                                 |
//|         HPCChunkedGradient(...)                                  |
//|   HPCFinalizeChunkedGradient(Buf, Grad)                          |
//+------------------------------------------------------------------+
void CHPCCores::HPCFinalizeChunkedGradient(CMLPBuffers &buf,CRowDouble &grad)
  {
   grad+=buf.m_HPCBuf;
  }
//+------------------------------------------------------------------+
