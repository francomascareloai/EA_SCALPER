//+------------------------------------------------------------------+
//|                                                      solvers.mqh |
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
//#include "matrix.mqh"
#include "ap.mqh"
#include "alglibinternal.mqh"
#include "linalg.mqh"
//+------------------------------------------------------------------+
//| Auxiliary class for CDenseSolver                                 |
//+------------------------------------------------------------------+
class CDenseSolverReport
  {
public:
   double            m_r1;
   double            m_rinf;

                     CDenseSolverReport(void) { ZeroMemory(this); }
                    ~CDenseSolverReport(void) {}

   void              Copy(CDenseSolverReport &obj);
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CDenseSolverReport::Copy(CDenseSolverReport &obj)
  {
//--- copy variables
   m_r1=obj.m_r1;
   m_rinf=obj.m_rinf;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CDenseSolverReport               |
//+------------------------------------------------------------------+
class CDenseSolverReportShell
  {
private:
   CDenseSolverReport m_innerobj;
public:
   //--- constructors, destructor
                     CDenseSolverReportShell(void) {}
                     CDenseSolverReportShell(CDenseSolverReport &obj) { m_innerobj.Copy(obj); }
                    ~CDenseSolverReportShell(void) {}
   //--- methods
   double            GetR1(void);
   void              SetR1(const double d);
   double            GetRInf(void);
   void              SetRInf(const double d);
   CDenseSolverReport *GetInnerObj(void);
  };
//+------------------------------------------------------------------+
//| Returns the value of the variable r1                             |
//+------------------------------------------------------------------+
double CDenseSolverReportShell::GetR1(void)
  {
   return(m_innerobj.m_r1);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable r1                            |
//+------------------------------------------------------------------+
void CDenseSolverReportShell::SetR1(const double d)
  {
   m_innerobj.m_r1=d;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable rinf                           |
//+------------------------------------------------------------------+
double CDenseSolverReportShell::GetRInf(void)
  {
   return(m_innerobj.m_rinf);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable rinf                          |
//+------------------------------------------------------------------+
void CDenseSolverReportShell::SetRInf(const double d)
  {
   m_innerobj.m_rinf=d;
  }
//+------------------------------------------------------------------+
//| Return object of class                                           |
//+------------------------------------------------------------------+
CDenseSolverReport *CDenseSolverReportShell::GetInnerObj(void)
  {
   return(GetPointer(m_innerobj));
  }
//+------------------------------------------------------------------+
//| Auxiliary class for CDenseSolver                                 |
//+------------------------------------------------------------------+
class CDenseSolverLSReport
  {
public:
   double            m_r2;
   CMatrixDouble     m_cx;
   int               m_n;
   int               m_k;
   //--- constructor, destructor
                     CDenseSolverLSReport(void) { m_r2=0; m_n=0; m_k=0; }
                    ~CDenseSolverLSReport(void) {}
   //--- copy
   void              Copy(CDenseSolverLSReport &obj);
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CDenseSolverLSReport::Copy(CDenseSolverLSReport &obj)
  {
//--- copy variables
   m_r2=obj.m_r2;
   m_n=obj.m_n;
   m_k=obj.m_k;
//--- copy matrix
   m_cx=obj.m_cx;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CDenseSolverLSReport             |
//+------------------------------------------------------------------+
class CDenseSolverLSReportShell
  {
private:
   CDenseSolverLSReport m_innerobj;
public:
   //--- constructors, destructor
                     CDenseSolverLSReportShell(void) {}
                     CDenseSolverLSReportShell(CDenseSolverLSReport &obj) { m_innerobj.Copy(obj); }
                    ~CDenseSolverLSReportShell(void) {}
   //--- methods
   double            GetR2(void);
   void              SetR2(const double d);
   int               GetN(void);
   void              SetN(const int i);
   int               GetK(void);
   void              SetK(const int i);
   CDenseSolverLSReport *GetInnerObj(void);
  };
//+------------------------------------------------------------------+
//| Returns the value of the variable r2                             |
//+------------------------------------------------------------------+
double CDenseSolverLSReportShell::GetR2(void)
  {
//--- return result
   return(m_innerobj.m_r2);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable r2                            |
//+------------------------------------------------------------------+
void CDenseSolverLSReportShell::SetR2(const double d)
  {
   m_innerobj.m_r2=d;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable n                              |
//+------------------------------------------------------------------+
int CDenseSolverLSReportShell::GetN(void)
  {
   return(m_innerobj.m_n);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable n                             |
//+------------------------------------------------------------------+
void CDenseSolverLSReportShell::SetN(const int i)
  {
   m_innerobj.m_n=i;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable k                              |
//+------------------------------------------------------------------+
int CDenseSolverLSReportShell::GetK(void)
  {
   return(m_innerobj.m_k);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable k                             |
//+------------------------------------------------------------------+
void CDenseSolverLSReportShell::SetK(const int i)
  {
   m_innerobj.m_k=i;
  }
//+------------------------------------------------------------------+
//| Return object of class                                           |
//+------------------------------------------------------------------+
CDenseSolverLSReport *CDenseSolverLSReportShell::GetInnerObj(void)
  {
   return(GetPointer(m_innerobj));
  }
//+------------------------------------------------------------------+
//| Dense solver                                                     |
//+------------------------------------------------------------------+
class CDenseSolver
  {
private:
   static void       RMatrixLUSolveInternal(CMatrixDouble &lua,int &p[],const double scalea,const int n,CMatrixDouble &a,const bool havea,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       SPDMatrixCholeskySolveInternal(CMatrixDouble &cha,const double sqrtscalea,const int n,const bool IsUpper,CMatrixDouble &a,const bool havea,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       CMatrixLUSolveInternal(CMatrixComplex &lua,int &p[],const double scalea,const int n,CMatrixComplex &a,const bool havea,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       HPDMatrixCholeskySolveInternal(CMatrixComplex &cha,const double sqrtscalea,const int n,const bool IsUpper,CMatrixComplex &a,const bool havea,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static int        CDenseSolverRFSMax(const int n,const double r1,const double rinf);
   static int        CDenseSolverRFSMaxV2(const int n,const double r2);
   static void       RBasicLUSolve(CMatrixDouble &lua,int &p[],const double scalea,const int n,double &xb[],double &tmp[]);
   static void       SPDBasicCholeskySolve(CMatrixDouble &cha,const double sqrtscalea,const int n,const bool IsUpper,double &xb[],double &tmp[]);
   static void       CBasicLUSolve(CMatrixComplex &lua,int &p[],const double scalea,const int n,complex &xb[],complex &tmp[]);
   static void       HPDBasicCholeskySolve(CMatrixComplex &cha,const double sqrtscalea,const int n,const bool IsUpper,complex &xb[],complex &tmp[]);

public:
   static void       RMatrixSolve(CMatrixDouble &a,const int n,double &b[],int &info,CDenseSolverReport &rep,double &x[]);
   static void       RMatrixSolve(CMatrixDouble &a,const int n,CRowDouble &b,int &info,CDenseSolverReport &rep,CRowDouble &x);
   static void       RMatrixSolveM(CMatrixDouble &a,const int n,CMatrixDouble &b,const int m,const bool rfs,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       RMatrixLUSolve(CMatrixDouble &lua,int &p[],const int n,double &b[],int &info,CDenseSolverReport &rep,double &x[]);
   static void       RMatrixLUSolveM(CMatrixDouble &lua,int &p[],const int n,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       RMatrixMixedSolve(CMatrixDouble &a,CMatrixDouble &lua,int &p[],const int n,double &b[],int &info,CDenseSolverReport &rep,double &x[]);
   static void       RMatrixMixedSolveM(CMatrixDouble &a,CMatrixDouble &lua,int &p[],const int n,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       CMatrixSolveM(CMatrixComplex &a,const int n,CMatrixComplex &b,const int m,const bool rfs,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       CMatrixSolve(CMatrixComplex &a,const int n,complex &b[],int &info,CDenseSolverReport &rep,complex &x[]);
   static void       CMatrixLUSolveM(CMatrixComplex &lua,int &p[],const int n,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       CMatrixLUSolve(CMatrixComplex &lua,int &p[],const int n,complex &b[],int &info,CDenseSolverReport &rep,complex &x[]);
   static void       CMatrixMixedSolveM(CMatrixComplex &a,CMatrixComplex &lua,int &p[],const int n,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       CMatrixMixedSolve(CMatrixComplex &a,CMatrixComplex &lua,int &p[],const int n,complex &b[],int &info,CDenseSolverReport &rep,complex &x[]);
   static void       SPDMatrixSolveM(CMatrixDouble &a,const int n,const bool IsUpper,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       SPDMatrixSolve(CMatrixDouble &a,const int n,const bool IsUpper,double &b[],int &info,CDenseSolverReport &rep,double &x[]);
   static void       SPDMatrixCholeskySolveM(CMatrixDouble &cha,const int n,const bool IsUpper,CMatrixDouble &b,const int m,int &info,CDenseSolverReport &rep,CMatrixDouble &x);
   static void       SPDMatrixCholeskySolve(CMatrixDouble &cha,const int n,const bool IsUpper,double &b[],int &info,CDenseSolverReport &rep,double &x[]);
   static void       SPDMatrixCholeskySolve(CMatrixDouble &cha,const int n,const bool IsUpper,CRowDouble &b,int &info,CDenseSolverReport &rep,CRowDouble &x);
   static void       HPDMatrixSolveM(CMatrixComplex &a,const int n,const bool IsUpper,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       HPDMatrixSolve(CMatrixComplex &a,const int n,const bool IsUpper,complex &b[],int &info,CDenseSolverReport &rep,complex &x[]);
   static void       HPDMatrixCholeskySolveM(CMatrixComplex &cha,const int n,const bool IsUpper,CMatrixComplex &b,const int m,int &info,CDenseSolverReport &rep,CMatrixComplex &x);
   static void       HPDMatrixCholeskySolve(CMatrixComplex &cha,const int n,const bool IsUpper,complex &b[],int &info,CDenseSolverReport &rep,complex &x[]);
   static void       RMatrixSolveLS(CMatrixDouble &a,const int nrows,const int ncols,double &b[],double threshold,int &info,CDenseSolverLSReport &rep,double &x[]);
  };
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| This subroutine solves a system A*x=b, where A is NxN            |
//| non-denegerate real matrix, x and b are vectors.                 |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(N^3) complexity                                              |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   return code:                                     |
//|                 * -3    A is singular, or VERY close to singular.|
//|                         X is filled by zeros in such cases.      |
//|                 * -1    N<=0 was passed                          |
//|                 *  1    task is solved (but matrix A may be      |
//|                         ill-conditioned, check R1/RInf parameters|
//|                         for condition numbers).                  |
//|     Rep     -   solver report, see below for more info           |
//|     X       -   array[0..N-1], it contains:                      |
//|                 * solution of A*x=b if A is non-singular         |
//|                   (well-conditioned or ill-conditioned, but not  |
//|                   very close to singular)                        |
//|                 * zeros, if A is singular or VERY close to       |
//|                   singular (in this case Info=-3).               |
//| SOLVER REPORT                                                    |
//| Subroutine sets following fields of the Rep structure:           |
//| * R1        reciprocal of condition number: 1/cond(A), 1-norm.   |
//| * RInf      reciprocal of condition number: 1/cond(A), inf-norm. |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixSolve(CMatrixDouble &a,const int n,double &b[],
                                int &info,CDenseSolverReport &rep,
                                double &x[])
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   RMatrixSolveM(a,n,bm,1,true,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixSolve(CMatrixDouble &a,const int n,CRowDouble &b,
                                int &info,CDenseSolverReport &rep,
                                CRowDouble &x)
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
      bm.Col(0,b);
//--- function call
   RMatrixSolveM(a,n,bm,1,true,info,rep,xm);
//--- copy
      x=xm.Col(0)+0;
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| Similar to RMatrixSolve() but solves task with multiple right    |
//| parts (where b and x are NxM matrices).                          |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * optional iterative refinement                                  |
//| * O(N^3+M*N^2) complexity                                        |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//|     RFS     -   iterative refinement switch:                     |
//|                 * True - refinement is used.                     |
//|                   Less performance, more precision.              |
//|                 * False - refinement is not used.                |
//|                   More performance, less precision.              |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixSolveM(CMatrixDouble &a,const int n,
                                 CMatrixDouble &b,const int m,
                                 const bool rfs,int &info,
                                 CDenseSolverReport &rep,
                                 CMatrixDouble &x)
  {
   double scalea=0;
//--- create matrix
   CMatrixDouble da;
   CMatrixDouble emptya;
//--- create array
   int p[];
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   da.Resize(n,n);
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=0; j<n; j++)
         scalea=MathMax(scalea,MathAbs(a[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
   for(int i=0; i<n; i++)
     {
      for(int i_=0; i_<n; i_++)
         da.Set(i,i_,a[i][i_]);
     }
//--- function call
   CTrFac::RMatrixLU(da,n,n,p);
//--- check
   if(rfs)
      RMatrixLUSolveInternal(da,p,scalea,n,a,true,b,m,info,rep,x);
   else
      RMatrixLUSolveInternal(da,p,scalea,n,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| This subroutine solves a system A*X=B, where A is NxN            |
//| non-denegerate real matrix given by its LU decomposition, X and  |
//| B are NxM real matrices.                                         |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(N^2) complexity                                              |
//| * condition number estimation                                    |
//| No iterative refinement is provided because exact form of        |
//| original matrix is not known to subroutine. Use RMatrixSolve or  |
//| RMatrixMixedSolve if you need iterative refinement.              |
//| INPUT PARAMETERS                                                 |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, RMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, RMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixLUSolve(CMatrixDouble &lua,int &p[],
                                  const int n,double &b[],
                                  int &info,CDenseSolverReport &rep,
                                  double &x[])
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   RMatrixLUSolveM(lua,p,n,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| Similar to RMatrixLUSolve() but solves task with multiple right  |
//| parts (where b and x are NxM matrices).                          |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(M*N^2) complexity                                            |
//| * condition number estimation                                    |
//| No iterative refinement is provided because exact form of        |
//| original matrix is not known to subroutine. Use RMatrixSolve or  |
//| RMatrixMixedSolve if you need iterative refinement.              |
//| INPUT PARAMETERS                                                 |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, RMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, RMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixLUSolveM(CMatrixDouble &lua,int &p[],
                                   const int n,CMatrixDouble &b,
                                   const int m,int &info,
                                   CDenseSolverReport &rep,
                                   CMatrixDouble &x)
  {
   double scalea=0;
//--- create matrix
   CMatrixDouble emptya;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|U[i][j]|)
//---    we assume that LU is in its normal form,i.e. |L[i][j]|<=1
//--- 2. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=i; j<n; j++)
         scalea=MathMax(scalea,MathAbs(lua[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
//--- function call
   RMatrixLUSolveInternal(lua,p,scalea,n,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| This subroutine solves a system A*x=b, where BOTH ORIGINAL A AND |
//| ITS LU DECOMPOSITION ARE KNOWN. You can use it if for some       |
//| reasons you have both A and its LU decomposition.                |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(N^2) complexity                                              |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, RMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, RMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolveM                         |
//|     Rep     -   same as in RMatrixSolveM                         |
//|     X       -   same as in RMatrixSolveM                         |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixMixedSolve(CMatrixDouble &a,CMatrixDouble &lua,
                                     int &p[],const int n,double &b[],
                                     int &info,CDenseSolverReport &rep,
                                     double &x[])
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   RMatrixMixedSolveM(a,lua,p,n,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| Similar to RMatrixMixedSolve() but solves task with multiple     |
//| right parts (where b and x are NxM matrices).                    |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(M*N^2) complexity                                            |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, RMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, RMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolveM                         |
//|     Rep     -   same as in RMatrixSolveM                         |
//|     X       -   same as in RMatrixSolveM                         |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixMixedSolveM(CMatrixDouble &a,CMatrixDouble &lua,
                                      int &p[],const int n,CMatrixDouble &b,
                                      const int m,int &info,
                                      CDenseSolverReport &rep,
                                      CMatrixDouble &x)
  {
   double scalea=0;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=0; j<n; j++)
         scalea=MathMax(scalea,MathAbs(a[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
//--- function call
   RMatrixLUSolveInternal(lua,p,scalea,n,a,true,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolveM(), but for complex matrices. |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(N^3+M*N^2) complexity                                        |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//|     RFS     -   iterative refinement switch:                     |
//|                 * True - refinement is used.                     |
//|                   Less performance, more precision.              |
//|                 * False - refinement is not used.                |
//|                   More performance, less precision.              |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixSolveM(CMatrixComplex &a,const int n,
                                 CMatrixComplex &b,const int m,
                                 const bool rfs,int &info,
                                 CDenseSolverReport &rep,
                                 CMatrixComplex &x)
  {
   double scalea=0;
//--- create array
   int p[];
//--- create matrix
   CMatrixComplex da;
   CMatrixComplex emptya;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   da.Resize(n,n);
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=0; j<n; j++)
         scalea=MathMax(scalea,CMath::AbsComplex(a[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
   for(int i=0; i<n; i++)
     {
      for(int i_=0; i_<n; i_++)
         da.Set(i,i_,a[i][i_]);
     }
//--- function call
   CTrFac::CMatrixLU(da,n,n,p);
//--- check
   if(rfs)
      CMatrixLUSolveInternal(da,p,scalea,n,a,true,b,m,info,rep,x);
   else
      CMatrixLUSolveInternal(da,p,scalea,n,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolve(), but for complex matrices.  |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(N^3) complexity                                              |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixSolve(CMatrixComplex &a,const int n,
                                complex &b[],int &info,
                                CDenseSolverReport &rep,complex &x[])
  {
//--- create matrix
   CMatrixComplex bm;
   CMatrixComplex xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   CMatrixSolveM(a,n,bm,1,true,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolveM(), but for complex         |
//| matrices.                                                        |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(M*N^2) complexity                                            |
//| * condition number estimation                                    |
//| No iterative refinement is provided because exact form of        |
//| original matrix is not known to subroutine. Use CMatrixSolve or  |
//| CMatrixMixedSolve if you need iterative refinement.              |
//| INPUT PARAMETERS                                                 |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, RMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, RMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixLUSolveM(CMatrixComplex &lua,int &p[],
                                   const int n,CMatrixComplex &b,
                                   const int m,int &info,
                                   CDenseSolverReport &rep,
                                   CMatrixComplex &x)
  {
   double scalea=0;
//--- create matrix
   CMatrixComplex emptya;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|U[i][j]|)
//---    we assume that LU is in its normal form,i.e. |L[i][j]|<=1
//--- 2. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=i; j<n; j++)
         scalea=MathMax(scalea,CMath::AbsComplex(lua[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
//--- function call
   CMatrixLUSolveInternal(lua,p,scalea,n,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolve(), but for complex matrices.|
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(N^2) complexity                                              |
//| * condition number estimation                                    |
//| No iterative refinement is provided because exact form of        |
//| original matrix is not known to subroutine. Use CMatrixSolve or  |
//| CMatrixMixedSolve if you need iterative refinement.              |
//| INPUT PARAMETERS                                                 |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, CMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, CMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixLUSolve(CMatrixComplex &lua,int &p[],
                                  const int n,complex &b[],int &info,
                                  CDenseSolverReport &rep,complex &x[])
  {
//--- create matrix
   CMatrixComplex bm;
   CMatrixComplex xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   CMatrixLUSolveM(lua,p,n,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixMixedSolveM(), but for complex      |
//| matrices.                                                        |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(M*N^2) complexity                                            |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, CMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, CMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolveM                         |
//|     Rep     -   same as in RMatrixSolveM                         |
//|     X       -   same as in RMatrixSolveM                         |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixMixedSolveM(CMatrixComplex &a,CMatrixComplex &lua,
                                      int &p[],const int n,CMatrixComplex &b,
                                      const int m,int &info,CDenseSolverReport &rep,
                                      CMatrixComplex &x)
  {
   double scalea=0;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   scalea=0;
   for(int i=0; i<n; i++)
     {
      for(int j=0; j<n; j++)
         scalea=MathMax(scalea,CMath::AbsComplex(a[i][j]));
     }
//--- check
   if(scalea==0.0)
      scalea=1;
//--- change values
   scalea=1/scalea;
//--- function call
   CMatrixLUSolveInternal(lua,p,scalea,n,a,true,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixMixedSolve(), but for complex       |
//| matrices.                                                        |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * iterative refinement                                           |
//| * O(N^2) complexity                                              |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     LUA     -   array[0..N-1,0..N-1], LU decomposition, CMatrixLU|
//|                 result                                           |
//|     P       -   array[0..N-1], pivots array, CMatrixLU result    |
//|     N       -   size of A                                        |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolveM                         |
//|     Rep     -   same as in RMatrixSolveM                         |
//|     X       -   same as in RMatrixSolveM                         |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixMixedSolve(CMatrixComplex &a,CMatrixComplex &lua,
                                     int &p[],const int n,complex &b[],
                                     int &info,CDenseSolverReport &rep,
                                     complex &x[])
  {
//--- create matrix
   CMatrixComplex bm;
   CMatrixComplex xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   CMatrixMixedSolveM(a,lua,p,n,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolveM(), but for symmetric positive|
//| definite matrices.                                               |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * O(N^3+M*N^2) complexity                                        |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise matrix-vector products for large matrices. Use     |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of A is provided                       |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve.                         |
//|                 Returns -3 for non-SPD matrices.                 |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixSolveM(CMatrixDouble &a,const int n,
                                   const bool IsUpper,CMatrixDouble &b,
                                   const int m,int &info,
                                   CDenseSolverReport &rep,
                                   CMatrixDouble &x)
  {
//--- create variables
   double sqrtscalea=0;
   int    i=0;
   int    j=0;
   int    j1=0;
   int    j2=0;
   int    i_=0;
//--- create matrix
   CMatrixDouble da;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   da.Resize(n,n);
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   sqrtscalea=0;
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
      //--- calculation
      for(j=j1; j<=j2; j++)
         sqrtscalea=MathMax(sqrtscalea,MathAbs(a[i][j]));
     }
//--- check
   if(sqrtscalea==0.0)
      sqrtscalea=1;
//--- change values
   sqrtscalea=1/sqrtscalea;
   sqrtscalea=MathSqrt(sqrtscalea);
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
      //--- calculation
      for(i_=j1; i_<=j2; i_++)
         da.Set(i,i_,a[i][i_]);
     }
//--- check
   if(!CTrFac::SPDMatrixCholesky(da,n,IsUpper))
     {
      //--- allocation
      x.Resize(n,m);
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- function call
   SPDMatrixCholeskySolveInternal(da,sqrtscalea,n,IsUpper,a,true,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolve(), but for SPD matrices.      |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * O(N^3) complexity                                              |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise  matrix-vector products for large matrices. Use    |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of A is provided                       |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|                 Returns -3 for non-SPD matrices.                 |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixSolve(CMatrixDouble &a,const int n,
                                  const bool IsUpper,double &b[],
                                  int &info,CDenseSolverReport &rep,
                                  double &x[])
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   SPDMatrixSolveM(a,n,IsUpper,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolveM(), but for SPD matrices    |
//| represented by their Cholesky decomposition.                     |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(M*N^2) complexity                                            |
//| * condition number estimation                                    |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise  matrix-vector products for large matrices. Use    |
//| RMatrixSolve or RMatrixMixedSolve  if  you need iterative        |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     CHA     -   array[0..N-1,0..N-1], Cholesky decomposition,    |
//|                 SPDMatrixCholesky result                         |
//|     N       -   size of CHA                                      |
//|     IsUpper -   what half of CHA is provided                     |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixCholeskySolveM(CMatrixDouble &cha,const int n,
                                           const bool IsUpper,CMatrixDouble &b,
                                           const int m,int &info,
                                           CDenseSolverReport &rep,
                                           CMatrixDouble &x)
  {
//--- create variables
   double sqrtscalea=0;
   int    i=0;
   int    j=0;
   int    j1=0;
   int    j2=0;
//--- create matrix
   CMatrixDouble emptya;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|U[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   sqrtscalea=0;
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
      //--- calculation
      for(j=j1; j<=j2; j++)
         sqrtscalea=MathMax(sqrtscalea,MathAbs(cha[i][j]));
     }
//--- check
   if(sqrtscalea==0.0)
      sqrtscalea=1;
//--- change values
   sqrtscalea=1/sqrtscalea;
//--- function call
   SPDMatrixCholeskySolveInternal(cha,sqrtscalea,n,IsUpper,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolve(), but for  SPD matrices    |
//| represented by their Cholesky decomposition.                     |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(N^2) complexity                                              |
//| * condition number estimation                                    |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise  matrix-vector products for large matrices. Use    |
//| RMatrixSolve or RMatrixMixedSolve  if  you need iterative        |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     CHA     -   array[0..N-1,0..N-1], Cholesky decomposition,    |
//|                 SPDMatrixCholesky result                         |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of CHA is provided                     |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixCholeskySolve(CMatrixDouble &cha,const int n,
                                          const bool IsUpper,double &b[],
                                          int &info,CDenseSolverReport &rep,
                                          double &x[])
  {
   CRowDouble X;
   CRowDouble B=b;
   SPDMatrixCholeskySolve(cha,n,IsUpper,B,info,rep,X);
   X.ToArray(x);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixCholeskySolve(CMatrixDouble &cha,const int n,
                                          const bool IsUpper,CRowDouble &b,
                                          int &info,CDenseSolverReport &rep,
                                          CRowDouble &x)
  {
//--- create matrix
   CMatrixDouble bm;
   CMatrixDouble xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   bm.Col(0,b);
//--- function call
   SPDMatrixCholeskySolveM(cha,n,IsUpper,bm,1,info,rep,xm);
//--- copy
   x=xm.Col(0)+0;
   x.Resize(n);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolveM(), but for Hermitian positive|
//| definite matrices.                                               |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * O(N^3+M*N^2) complexity                                        |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise  matrix-vector products for large matrices. Use    |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of A is provided                       |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve.                         |
//|                 Returns -3 for non-HPD matrices.                 |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::HPDMatrixSolveM(CMatrixComplex &a,const int n,
                                   const bool IsUpper,CMatrixComplex &b,
                                   const int m,int &info,
                                   CDenseSolverReport &rep,CMatrixComplex &x)
  {
//--- create variables
   double sqrtscalea=0;
   int    i=0;
   int    j=0;
   int    j1=0;
   int    j2=0;
   int    i_=0;
//--- create matrix
   CMatrixComplex da;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   da.Resize(n,n);
//--- 1. scale matrix,max(|A[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   sqrtscalea=0;
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
      //--- calculation
      for(j=j1; j<=j2; j++)
         sqrtscalea=MathMax(sqrtscalea,CMath::AbsComplex(a[i][j]));
     }
//--- check
   if(sqrtscalea==0.0)
      sqrtscalea=1;
//--- change values
   sqrtscalea=1/sqrtscalea;
   sqrtscalea=MathSqrt(sqrtscalea);
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
      //--- calculation
      for(i_=j1; i_<=j2; i_++)
         da.Set(i,i_,a[i][i_]);
     }
//--- check
   if(!CTrFac::HPDMatrixCholesky(da,n,IsUpper))
     {
      //--- allocation
      x.Resize(n,m);
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0.0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- function call
   HPDMatrixCholeskySolveInternal(da,sqrtscalea,n,IsUpper,a,true,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixSolve(), but for Hermitian positive |
//| definite matrices.                                               |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * condition number estimation                                    |
//| * O(N^3) complexity                                              |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise matrix-vector products for large matrices. Use     |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..N-1,0..N-1], system matrix              |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of A is provided                       |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|                 Returns -3 for non-HPD matrices.                 |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::HPDMatrixSolve(CMatrixComplex &a,const int n,
                                  const bool IsUpper,complex &b[],
                                  int &info,CDenseSolverReport &rep,
                                  complex &x[])
  {
//--- create matrix
   CMatrixComplex bm;
   CMatrixComplex xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   HPDMatrixSolveM(a,n,IsUpper,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolveM(), but for HPD matrices    |
//| represented by their Cholesky decomposition.                     |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(M*N^2) complexity                                            |
//| * condition number estimation                                    |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise matrix-vector products for large matrices. Use     |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     CHA     -   array[0..N-1,0..N-1], Cholesky decomposition,    |
//|                 HPDMatrixCholesky result                         |
//|     N       -   size of CHA                                      |
//|     IsUpper -   what half of CHA is provided                     |
//|     B       -   array[0..N-1,0..M-1], right part                 |
//|     M       -   right part size                                  |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::HPDMatrixCholeskySolveM(CMatrixComplex &cha,
                                           const int n,const bool IsUpper,
                                           CMatrixComplex &b,const int m,
                                           int &info,CDenseSolverReport &rep,
                                           CMatrixComplex &x)
  {
//--- create variables
   double sqrtscalea=0;
   int    j1=0;
   int    j2=0;
//--- create matrix
   CMatrixComplex emptya;
//--- initialization
   info=0;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- 1. scale matrix,max(|U[i][j]|)
//--- 2. factorize scaled matrix
//--- 3. solve
   sqrtscalea=0;
   for(int i=0; i<n; i++)
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
      //--- calculation
      for(int j=j1; j<=j2; j++)
        {
         sqrtscalea=MathMax(sqrtscalea,CMath::AbsComplex(cha[i][j]));
        }
     }
//--- check
   if(sqrtscalea==0.0)
     {
      sqrtscalea=1;
     }
//--- change values
   sqrtscalea=1/sqrtscalea;
//--- function call
   HPDMatrixCholeskySolveInternal(cha,sqrtscalea,n,IsUpper,emptya,false,b,m,info,rep,x);
  }
//+------------------------------------------------------------------+
//| Dense solver. Same as RMatrixLUSolve(), but for  HPD matrices    |
//| represented by their Cholesky decomposition.                     |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * O(N^2) complexity                                              |
//| * condition number estimation                                    |
//| * matrix is represented by its upper or lower triangle           |
//| No iterative refinement is provided because such partial         |
//| representation of matrix does not allow efficient calculation of |
//| extra-precise  matrix-vector products for large matrices. Use    |
//| RMatrixSolve or RMatrixMixedSolve if you need iterative          |
//| refinement.                                                      |
//| INPUT PARAMETERS                                                 |
//|     CHA     -   array[0..N-1,0..N-1], Cholesky decomposition,    |
//|                 SPDMatrixCholesky result                         |
//|     N       -   size of A                                        |
//|     IsUpper -   what half of CHA is provided                     |
//|     B       -   array[0..N-1], right part                        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   same as in RMatrixSolve                          |
//|     Rep     -   same as in RMatrixSolve                          |
//|     X       -   same as in RMatrixSolve                          |
//+------------------------------------------------------------------+
void CDenseSolver::HPDMatrixCholeskySolve(CMatrixComplex &cha,
                                          const int n,const bool IsUpper,
                                          complex &b[],int &info,
                                          CDenseSolverReport &rep,
                                          complex &x[])
  {
//--- create matrix
   CMatrixComplex bm;
   CMatrixComplex xm;
//--- initialization
   info=0;
//--- check
   if(n<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   bm.Resize(n,1);
//--- filling
   for(int i_=0; i_<n; i_++)
      bm.Set(i_,0,b[i_]);
//--- function call
   HPDMatrixCholeskySolveM(cha,n,IsUpper,bm,1,info,rep,xm);
//--- allocation
   ArrayResize(x,n);
//--- copy
   for(int i_=0; i_<n; i_++)
      x[i_]=xm[i_][0];
  }
//+------------------------------------------------------------------+
//| Dense solver.                                                    |
//| This subroutine finds solution of the linear system A*X=B with   |
//| non-square, possibly degenerate A. System is solved in the least |
//| squares sense, and general least squares solution  X = X0 + CX*y |
//| which  minimizes |A*X-B| is returned. If A is non-degenerate,    |
//| solution in the usual sense is returned                          |
//| Algorithm features:                                              |
//| * automatic detection of degenerate cases                        |
//| * iterative refinement                                           |
//| * O(N^3) complexity                                              |
//| INPUT PARAMETERS                                                 |
//|     A       -   array[0..NRows-1,0..NCols-1], system matrix      |
//|     NRows   -   vertical size of A                               |
//|     NCols   -   horizontal size of A                             |
//|     B       -   array[0..NCols-1], right part                    |
//|     Threshold-  a number in [0,1]. Singular values beyond        |
//|                 Threshold are considered  zero.  Set it to 0.0,  |
//|                 if you don't understand what it means, so the    |
//|                 solver will choose good value on its own.        |
//| OUTPUT PARAMETERS                                                |
//|     Info    -   return code:                                     |
//|                 * -4    SVD subroutine failed                    |
//|                 * -1    if NRows<=0 or NCols<=0 or Threshold<0   |
//|                         was passed                               |
//|                 *  1    if task is solved                        |
//|     Rep     -   solver report, see below for more info           |
//|     X       -   array[0..N-1,0..M-1], it contains:               |
//|                 * solution of A*X=B if A is non-singular         |
//|                   (well-conditioned or ill-conditioned, but not  |
//|                   very close to singular)                        |
//|                 * zeros, if A is singular or VERY close to       |
//|                   singular (in this case Info=-3).               |
//| SOLVER REPORT                                                    |
//| Subroutine sets following fields of the Rep structure:           |
//| * R2        reciprocal of condition number: 1/cond(A), 2-norm.   |
//| * N         = NCols                                              |
//| * K         dim(Null(A))                                         |
//| * CX        array[0..N-1,0..K-1], kernel of A.                   |
//|             Columns of CX store such vectors that A*CX[i]=0.     |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixSolveLS(CMatrixDouble &a,const int nrows,
                                  const int ncols,double &b[],
                                  double threshold,int &info,
                                  CDenseSolverLSReport &rep,
                                  double &x[])
  {
//--- create matrix
   CMatrixDouble u;
   CMatrixDouble vt;
//--- create arrays
   double sv[];
   double rp[];
   double utb[];
   double sutb[];
   double tmp[];
   double ta[];
   double tx[];
   double buf[];
   double w[];
//--- create variables
   int    i=0;
   int    j=0;
   int    nsv=0;
   int    kernelidx=0;
   double v=0;
   double verr=0;
   bool   svdfailed;
   bool   zeroa;
   int    rfs=0;
   int    nrfs=0;
   bool   terminatenexttime;
   bool   smallerr;
   int    i_=0;
//--- initialization
   info=0;
//--- check
   if((nrows<=0 || ncols<=0) || threshold<0.0)
     {
      info=-1;
      return;
     }
//--- check
   if(threshold==0.0)
      threshold=1000*CMath::m_machineepsilon;
//--- Factorize A first
   svdfailed=!CSingValueDecompose::RMatrixSVD(a,nrows,ncols,1,2,2,sv,u,vt);
//--- check
   if(sv[0]==0.0)
      zeroa=true;
   else
      zeroa=false;
//--- check
   if(svdfailed || zeroa)
     {
      //--- check
      if(svdfailed)
         info=-4;
      else
         info=1;
      //--- allocation
      ArrayResize(x,ncols);
      for(i=0; i<=ncols-1; i++)
         x[i]=0;
      //--- change values
      rep.m_n=ncols;
      rep.m_k=ncols;
      rep.m_cx.Resize(ncols,ncols);
      for(i=0; i<=ncols-1; i++)
        {
         for(j=0; j<=ncols-1; j++)
           {
            //--- check
            if(i==j)
               rep.m_cx.Set(i,j,1);
            else
               rep.m_cx.Set(i,j,0);
           }
        }
      rep.m_r2=0;
      //--- exit the function
      return;
     }
   nsv=MathMin(ncols,nrows);
//--- check
   if(nsv==ncols)
      rep.m_r2=sv[nsv-1]/sv[0];
   else
      rep.m_r2=0;
//--- change values
   rep.m_n=ncols;
   info=1;
//--- Iterative refinement of xc combined with solution:
//--- 1. xc=0
//--- 2. calculate r=bc-A*xc using extra-precise dot product
//--- 3. solve A*y=r
//--- 4. update x:=x+r
//--- 5. goto 2
//--- This cycle is executed until one of two things happens:
//--- 1. maximum number of iterations reached
//--- 2. last iteration decreased error to the lower limit
   ArrayResize(utb,nsv);
   ArrayResize(sutb,nsv);
   ArrayResize(x,ncols);
   ArrayResize(tmp,ncols);
   ArrayResize(ta,ncols+1);
   ArrayResize(tx,ncols+1);
   ArrayResize(buf,ncols+1);
//--- initialization
   for(i=0; i<=ncols-1; i++)
      x[i]=0;
   kernelidx=nsv;
   for(i=0; i<=nsv-1; i++)
     {
      //--- check
      if(sv[i]<=threshold*sv[0])
        {
         kernelidx=i;
         break;
        }
     }
//--- change values
   rep.m_k=ncols-kernelidx;
   nrfs=CDenseSolverRFSMaxV2(ncols,rep.m_r2);
   terminatenexttime=false;
//--- allocation
   ArrayResize(rp,nrows);
   for(rfs=0; rfs<=nrfs; rfs++)
     {
      //--- check
      if(terminatenexttime)
         break;
      //--- calculate right part
      if(rfs==0)
        {
         for(i_=0; i_<=nrows-1; i_++)
            rp[i_]=b[i_];
        }
      else
        {
         smallerr=true;
         for(i=0; i<=nrows-1; i++)
           {
            //--- copy
            for(i_=0; i_<=ncols-1; i_++)
               ta[i_]=a[i][i_];
            ta[ncols]=-1;
            //--- copy
            for(i_=0; i_<=ncols-1; i_++)
               tx[i_]=x[i_];
            tx[ncols]=b[i];
            //--- function call
            CXblas::XDot(ta,tx,ncols+1,buf,v,verr);
            rp[i]=-v;
            smallerr=smallerr && MathAbs(v)<4*verr;
           }
         //--- check
         if(smallerr)
            terminatenexttime=true;
        }
      //--- solve A*dx=rp
      for(i=0; i<=ncols-1; i++)
         tmp[i]=0;
      for(i=0; i<=nsv-1; i++)
         utb[i]=0;
      //--- change values
      for(i=0; i<=nrows-1; i++)
        {
         v=rp[i];
         for(i_=0; i_<=nsv-1; i_++)
            utb[i_]=utb[i_]+v*u[i][i_];
        }
      for(i=0; i<=nsv-1; i++)
        {
         //--- check
         if(i<kernelidx)
            sutb[i]=utb[i]/sv[i];
         else
            sutb[i]=0;
        }
      //--- change values
      for(i=0; i<=nsv-1; i++)
        {
         v=sutb[i];
         for(i_=0; i_<=ncols-1; i_++)
            tmp[i_]=tmp[i_]+v*vt[i][i_];
        }
      //--- update x:  x:=x+dx
      for(i_=0; i_<=ncols-1; i_++)
         x[i_]=x[i_]+tmp[i_];
     }
//--- fill CX
   if(rep.m_k>0)
     {
      //--- allocation
      rep.m_cx.Resize(ncols,rep.m_k);
      for(i=0; i<=rep.m_k-1; i++)
        {
         for(i_=0; i_<=ncols-1; i_++)
            rep.m_cx.Set(i_,i,vt[kernelidx+i][i_]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Internal LU solver                                               |
//+------------------------------------------------------------------+
void CDenseSolver::RMatrixLUSolveInternal(CMatrixDouble &lua,int &p[],
                                          const double scalea,const int n,
                                          CMatrixDouble &a,const bool havea,
                                          CMatrixDouble &b,const int m,
                                          int &info,CDenseSolverReport &rep,
                                          CMatrixDouble &x)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   int    rfs=0;
   int    nrfs=0;
   double v=0;
   double verr=0;
   double mxb=0;
   double scaleright=0;
   bool   smallerr;
   bool   terminatenexttime;
   int    i_=0;
//--- create arrays
   double xc[];
   double y[];
   double bc[];
   double xa[];
   double xb[];
   double tx[];
//--- initialization
   info=0;
//--- check
   if(!CAp::Assert(scalea>0.0))
      return;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
   for(i=0; i<n; i++)
     {
      //--- check
      if(p[i]>n-1 || p[i]<i)
        {
         info=-1;
         return;
        }
     }
//--- allocation
   x.Resize(n,m);
   ArrayResize(y,n);
   ArrayResize(xc,n);
   ArrayResize(bc,n);
   ArrayResize(tx,n+1);
   ArrayResize(xa,n+1);
   ArrayResize(xb,n+1);
//--- estimate condition number,test for near singularity
   rep.m_r1=CRCond::RMatrixLURCond1(lua,n);
   rep.m_rinf=CRCond::RMatrixLURCondInf(lua,n);
//--- check
   if(rep.m_r1<CRCond::RCondThreshold() || rep.m_rinf<CRCond::RCondThreshold())
     {
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- solve
   for(k=0; k<=m-1; k++)
     {
      //--- copy B to contiguous storage
      for(i_=0; i_<n; i_++)
         bc[i_]=b[i_][k];
      //--- Scale right part:
      //--- * MX stores max(|Bi|)
      //--- * ScaleRight stores actual scaling applied to B when solving systems
      //---   it is chosen to make |scaleRight*b| close to 1.
      mxb=0;
      for(i=0; i<n; i++)
         mxb=MathMax(mxb,MathAbs(bc[i]));
      //--- check
      if(mxb==0.0)
         mxb=1;
      //--- change values
      scaleright=1/mxb;
      //--- First,non-iterative part of solution process.
      //--- We use separate code for this task because
      //--- XDot is quite slow and we want to save time.
      for(i_=0; i_<n; i_++)
         xc[i_]=bc[i_]*scaleright;
      //--- function call
      RBasicLUSolve(lua,p,scalea,n,xc,tx);
      //--- Iterative refinement of xc:
      //--- * calculate r=bc-A*xc using extra-precise dot product
      //--- * solve A*y=r
      //--- * update x:=x+r
      //--- This cycle is executed until one of two things happens:
      //--- 1. maximum number of iterations reached
      //--- 2. last iteration decreased error to the lower limit
      if(havea)
        {
         //--- calculation
         nrfs=CDenseSolverRFSMax(n,rep.m_r1,rep.m_rinf);
         terminatenexttime=false;
         for(rfs=0; rfs<=nrfs-1; rfs++)
           {
            //--- check
            if(terminatenexttime)
               break;
            //--- generate right part
            smallerr=true;
            for(i_=0; i_<n; i_++)
               xb[i_]=xc[i_];
            for(i=0; i<n; i++)
              {
               //--- change values
               for(i_=0; i_<n; i_++)
                  xa[i_]=a[i][i_]*scalea;
               xa[n]=-1;
               xb[n]=bc[i]*scaleright;
               //--- function call
               CXblas::XDot(xa,xb,n+1,tx,v,verr);
               y[i]=-v;
               smallerr=smallerr && MathAbs(v)<4*verr;
              }
            //--- check
            if(smallerr)
               terminatenexttime=true;
            //--- solve and update
            RBasicLUSolve(lua,p,scalea,n,y,tx);
            for(i_=0; i_<n; i_++)
               xc[i_]=xc[i_]+y[i_];
           }
        }
      //--- Store xc.
      //--- Post-scale result.
      v=scalea*mxb;
      for(i_=0; i_<n; i_++)
         x.Set(i_,k,xc[i_]*v);
     }
  }
//+------------------------------------------------------------------+
//| Internal Cholesky solver                                         |
//+------------------------------------------------------------------+
void CDenseSolver::SPDMatrixCholeskySolveInternal(CMatrixDouble &cha,
                                                  const double sqrtscalea,
                                                  const int n,const bool IsUpper,
                                                  CMatrixDouble &a,
                                                  const bool havea,
                                                  CMatrixDouble &b,
                                                  const int m,int &info,
                                                  CDenseSolverReport &rep,
                                                  CMatrixDouble &x)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   double v=0;
   double mxb=0;
   double scaleright=0;
   int    i_=0;
//--- create arrays
   double xc[];
   double y[];
   double bc[];
   double xa[];
   double xb[];
   double tx[];
//--- initialization
   info=0;
//--- check
   if(!CAp::Assert(sqrtscalea>0.0))
      return;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   x.Resize(n,m);
   ArrayResize(y,n);
   ArrayResize(xc,n);
   ArrayResize(bc,n);
   ArrayResize(tx,n+1);
   ArrayResize(xa,n+1);
   ArrayResize(xb,n+1);
//--- estimate condition number,test for near singularity
   rep.m_r1=CRCond::SPDMatrixCholeskyRCond(cha,n,IsUpper);
   rep.m_rinf=rep.m_r1;
//--- check
   if(rep.m_r1<CRCond::RCondThreshold())
     {
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- solve
   for(k=0; k<=m-1; k++)
     {
      //--- copy B to contiguous storage
      for(i_=0; i_<n; i_++)
         bc[i_]=b[i_][k];
      //--- Scale right part:
      //--- * MX stores max(|Bi|)
      //--- * ScaleRight stores actual scaling applied to B when solving systems
      //---   it is chosen to make |scaleRight*b| close to 1.
      mxb=0;
      for(i=0; i<n; i++)
         mxb=MathMax(mxb,MathAbs(bc[i]));
      //--- check
      if(mxb==0.0)
         mxb=1;
      scaleright=1/mxb;
      //--- First,non-iterative part of solution process.
      //--- We use separate code for this task because
      //--- XDot is quite slow and we want to save time.
      for(i_=0; i_<n; i_++)
         xc[i_]=bc[i_]*scaleright;
      //--- function call
      SPDBasicCholeskySolve(cha,sqrtscalea,n,IsUpper,xc,tx);
      //--- Store xc.
      //--- Post-scale result.
      v=CMath::Sqr(sqrtscalea)*mxb;
      for(i_=0; i_<n; i_++)
         x.Set(i_,k,xc[i_]*v);
     }
  }
//+------------------------------------------------------------------+
//| Internal LU solver                                               |
//+------------------------------------------------------------------+
void CDenseSolver::CMatrixLUSolveInternal(CMatrixComplex &lua,int &p[],
                                          const double scalea,const int n,
                                          CMatrixComplex &a,const bool havea,
                                          CMatrixComplex &b,const int m,
                                          int &info,CDenseSolverReport &rep,
                                          CMatrixComplex &x)
  {
//--- create variables
   int     i=0;
   int     j=0;
   int     k=0;
   int     rfs=0;
   int     nrfs=0;
   complex v=0;
   double  verr=0;
   double  mxb=0;
   double  scaleright=0;
   bool    smallerr;
   bool    terminatenexttime;
   int     i_=0;
//--- create arrays
   complex xc[];
   complex y[];
   complex bc[];
   complex xa[];
   complex xb[];
   complex tx[];
   double     tmpbuf[];
//--- initialization
   info=0;
//--- check
   if(!CAp::Assert(scalea>0.0))
      return;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
   for(i=0; i<n; i++)
     {
      //--- check
      if(p[i]>n-1 || p[i]<i)
        {
         info=-1;
         return;
        }
     }
//--- allocation
   x.Resize(n,m);
   ArrayResize(y,n);
   ArrayResize(xc,n);
   ArrayResize(bc,n);
   ArrayResize(tx,n);
   ArrayResize(xa,n+1);
   ArrayResize(xb,n+1);
   ArrayResize(tmpbuf,2*n+2);
//--- estimate condition number,test for near singularity
   rep.m_r1=CRCond::CMatrixLURCond1(lua,n);
   rep.m_rinf=CRCond::CMatrixLURCondInf(lua,n);
//--- check
   if(rep.m_r1<CRCond::RCondThreshold() || rep.m_rinf<CRCond::RCondThreshold())
     {
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0.0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- solve
   for(k=0; k<=m-1; k++)
     {
      //--- copy B to contiguous storage
      for(i_=0; i_<n; i_++)
         bc[i_]=b[i_][k];
      //--- Scale right part:
      //--- * MX stores max(|Bi|)
      //--- * ScaleRight stores actual scaling applied to B when solving systems
      //---   it is chosen to make |scaleRight*b| close to 1.
      mxb=0;
      for(i=0; i<n; i++)
         mxb=MathMax(mxb,CMath::AbsComplex(bc[i]));
      //--- check
      if(mxb==0.0)
         mxb=1;
      scaleright=1/mxb;
      //--- First,non-iterative part of solution process.
      //--- We use separate code for this task because
      //--- XDot is quite slow and we want to save time.
      for(i_=0; i_<n; i_++)
         xc[i_]=bc[i_]*scaleright;
      //--- function call
      CBasicLUSolve(lua,p,scalea,n,xc,tx);
      //--- Iterative refinement of xc:
      //--- * calculate r=bc-A*xc using extra-precise dot product
      //--- * solve A*y=r
      //--- * update x:=x+r
      //--- This cycle is executed until one of two things happens:
      //--- 1. maximum number of iterations reached
      //--- 2. last iteration decreased error to the lower limit
      if(havea)
        {
         //--- calculation
         nrfs=CDenseSolverRFSMax(n,rep.m_r1,rep.m_rinf);
         terminatenexttime=false;
         for(rfs=0; rfs<=nrfs-1; rfs++)
           {
            //--- check
            if(terminatenexttime)
               break;
            //--- generate right part
            smallerr=true;
            //--- copy
            for(i_=0; i_<n; i_++)
               xb[i_]=xc[i_];
            for(i=0; i<n; i++)
              {
               //--- change values
               for(i_=0; i_<n; i_++)
                  xa[i_]=a[i][i_]*scalea;
               xa[n]=-1;
               xb[n]=bc[i]*scaleright;
               //--- function call
               CXblas::XCDot(xa,xb,n+1,tmpbuf,v,verr);
               y[i]=-v;
               smallerr=smallerr && CMath::AbsComplex(v)<4*verr;
              }
            //--- check
            if(smallerr)
               terminatenexttime=true;
            //--- solve and update
            CBasicLUSolve(lua,p,scalea,n,y,tx);
            for(i_=0; i_<n; i_++)
               xc[i_]=xc[i_]+y[i_];
           }
        }
      //--- Store xc.
      //--- Post-scale result.
      v=scalea*mxb;
      for(i_=0; i_<n; i_++)
         x.Set(i_,k,xc[i_]*v);
     }
  }
//+------------------------------------------------------------------+
//| Internal Cholesky solver                                         |
//+------------------------------------------------------------------+
void CDenseSolver::HPDMatrixCholeskySolveInternal(CMatrixComplex &cha,
                                                  const double sqrtscalea,
                                                  const int n,
                                                  const bool IsUpper,
                                                  CMatrixComplex &a,
                                                  const bool havea,
                                                  CMatrixComplex &b,
                                                  const int m,int &info,
                                                  CDenseSolverReport &rep,
                                                  CMatrixComplex &x)
  {
//--- create variables
   int    i=0;
   int    j=0;
   int    k=0;
   double v=0;
   double mxb=0;
   double scaleright=0;
   int    i_=0;
//--- create arrays
   complex xc[];
   complex y[];
   complex bc[];
   complex xa[];
   complex xb[];
   complex tx[];
//--- initialization
   info=0;
//--- check
   if(!CAp::Assert(sqrtscalea>0.0))
      return;
//--- prepare: check inputs,allocate space...
   if(n<=0 || m<=0)
     {
      info=-1;
      return;
     }
//--- allocation
   x.Resize(n,m);
   ArrayResize(y,n);
   ArrayResize(xc,n);
   ArrayResize(bc,n);
   ArrayResize(tx,n+1);
   ArrayResize(xa,n+1);
   ArrayResize(xb,n+1);
//--- estimate condition number,test for near singularity
   rep.m_r1=CRCond::HPDMatrixCholeskyRCond(cha,n,IsUpper);
   rep.m_rinf=rep.m_r1;
//--- check
   if(rep.m_r1<CRCond::RCondThreshold())
     {
      for(i=0; i<n; i++)
        {
         for(j=0; j<=m-1; j++)
            x.Set(i,j,0.0);
        }
      //--- change values
      rep.m_r1=0;
      rep.m_rinf=0;
      info=-3;
      //--- exit the function
      return;
     }
   info=1;
//--- solve
   for(k=0; k<=m-1; k++)
     {
      //--- copy B to contiguous storage
      for(i_=0; i_<n; i_++)
         bc[i_]=b[i_][k];
      //--- Scale right part:
      //--- * MX stores max(|Bi|)
      //--- * ScaleRight stores actual scaling applied to B when solving systems
      //---   it is chosen to make |scaleRight*b| close to 1.
      mxb=0;
      for(i=0; i<n; i++)
         mxb=MathMax(mxb,CMath::AbsComplex(bc[i]));
      //--- check
      if(mxb==0.0)
         mxb=1;
      scaleright=1/mxb;
      //--- First,non-iterative part of solution process.
      //--- We use separate code for this task because
      //--- XDot is quite slow and we want to save time.
      for(i_=0; i_<n; i_++)
         xc[i_]=bc[i_]*scaleright;
      //--- function call
      HPDBasicCholeskySolve(cha,sqrtscalea,n,IsUpper,xc,tx);
      //--- Store xc.
      //--- Post-scale result.
      v=CMath::Sqr(sqrtscalea)*mxb;
      for(i_=0; i_<n; i_++)
         x.Set(i_,k,xc[i_]*v);
     }
  }
//+------------------------------------------------------------------+
//| Internal subroutine.                                             |
//| Returns maximum count of RFS iterations as function of:          |
//| 1. machine epsilon                                               |
//| 2. task size.                                                    |
//| 3. condition number                                              |
//+------------------------------------------------------------------+
int CDenseSolver::CDenseSolverRFSMax(const int n,const double r1,
                                     const double rinf)
  {
//--- return result
   return(5);
  }
//+------------------------------------------------------------------+
//| Internal subroutine.                                             |
//| Returns maximum count of RFS iterations as function of:          |
//| 1. machine epsilon                                               |
//| 2. task size.                                                    |
//| 3. norm-2 condition number                                       |
//+------------------------------------------------------------------+
int CDenseSolver::CDenseSolverRFSMaxV2(const int n,const double r2)
  {
//--- return result
   return(CDenseSolverRFSMax(n,0,0));
  }
//+------------------------------------------------------------------+
//| Basic LU solver for ScaleA*PLU*x = y.                            |
//| This subroutine assumes that:                                    |
//| * L is well-scaled, and it is U which needs scaling by ScaleA.   |
//| * A=PLU is well-conditioned, so no zero divisions or overflow may|
//|   occur                                                          |
//+------------------------------------------------------------------+
void CDenseSolver::RBasicLUSolve(CMatrixDouble &lua,int &p[],
                                 const double scalea,const int n,
                                 double &xb[],double &tmp[])
  {
//--- create variables
   int    i=0;
   double v=0;
   int    i_=0;
//--- swap
   for(i=0; i<n; i++)
     {
      //--- check
      if(p[i]!=i)
        {
         v=xb[i];
         xb[i]=xb[p[i]];
         xb[p[i]]=v;
        }
     }
//--- calculation
   for(i=1; i<n; i++)
     {
      v=0.0;
      //--- change value
      for(i_=0; i_<=i-1; i_++)
         v+=lua[i][i_]*xb[i_];
      //--- shift
      xb[i]=xb[i]-v;
     }
//--- change value
   xb[n-1]=xb[n-1]/(lua[n-1][n-1]*scalea);
   for(i=n-2; i>=0; i--)
     {
      //--- calculation
      for(i_=i+1; i_<n; i_++)
         tmp[i_]=lua[i][i_]*scalea;
      v=0.0;
      //--- change value
      for(i_=i+1; i_<n; i_++)
         v+=tmp[i_]*xb[i_];
      //--- get result
      xb[i]=(xb[i]-v)/(lua[i][i]*scalea);
     }
  }
//+------------------------------------------------------------------+
//| Basic Cholesky solver for ScaleA*Cholesky(A)'*x = y.             |
//| This subroutine assumes that:                                    |
//| * A*ScaleA is well scaled                                        |
//| * A is well-conditioned, so no zero divisions or overflow may    |
//| occur                                                            |
//+------------------------------------------------------------------+
void CDenseSolver::SPDBasicCholeskySolve(CMatrixDouble &cha,
                                         const double sqrtscalea,
                                         const int n,const bool IsUpper,
                                         double &xb[],double &tmp[])
  {
//--- create variables
   int    i=0;
   double v=0;
   int    i_=0;
//--- A=L*L' or A=U'*U
   if(IsUpper)
     {
      //--- Solve U'*y=b first.
      for(i=0; i<n; i++)
        {
         xb[i]=xb[i]/(sqrtscalea*cha[i][i]);
         //--- check
         if(i<n-1)
           {
            v=xb[i];
            //--- calculation
            for(i_=i+1; i_<n; i_++)
               tmp[i_]=sqrtscalea*cha[i][i_];
            for(i_=i+1; i_<n; i_++)
               xb[i_]=xb[i_]-v*tmp[i_];
           }
        }
      //--- Solve U*x=y then.
      for(i=n-1; i>=0; i--)
        {
         //--- check
         if(i<n-1)
           {
            for(i_=i+1; i_<n; i_++)
               tmp[i_]=sqrtscalea*cha[i][i_];
            v=0.0;
            //--- change value
            for(i_=i+1; i_<n; i_++)
               v+=tmp[i_]*xb[i_];
            //--- shift
            xb[i]=xb[i]-v;
           }
         xb[i]=xb[i]/(sqrtscalea*cha[i][i]);
        }
     }
   else
     {
      //--- Solve L*y=b first
      for(i=0; i<n; i++)
        {
         //--- check
         if(i>0)
           {
            for(i_=0; i_<=i-1; i_++)
               tmp[i_]=sqrtscalea*cha[i][i_];
            //--- change value
            v=0.0;
            for(i_=0; i_<=i-1; i_++)
               v+=tmp[i_]*xb[i_];
            //--- shift
            xb[i]=xb[i]-v;
           }
         xb[i]=xb[i]/(sqrtscalea*cha[i][i]);
        }
      //--- Solve L'*x=y then.
      for(i=n-1; i>=0; i--)
        {
         xb[i]=xb[i]/(sqrtscalea*cha[i][i]);
         //--- check
         if(i>0)
           {
            v=xb[i];
            //--- calculation
            for(i_=0; i_<=i-1; i_++)
               tmp[i_]=sqrtscalea*cha[i][i_];
            for(i_=0; i_<=i-1; i_++)
               xb[i_]=xb[i_]-v*tmp[i_];
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Basic LU solver for ScaleA*PLU*x = y.                            |
//| This subroutine assumes that:                                    |
//| * L is well-scaled, and it is U which needs scaling by ScaleA.   |
//| * A=PLU is well-conditioned, so no zero divisions or overflow may|
//|   occur                                                          |
//+------------------------------------------------------------------+
void CDenseSolver::CBasicLUSolve(CMatrixComplex &lua,int &p[],
                                 const double scalea,const int n,
                                 complex &xb[],complex &tmp[])
  {
//--- create variables
   int     i=0;
   complex v=0;
   int     i_=0;
//--- swap
   for(i=0; i<n; i++)
     {
      //--- check
      if(p[i]!=i)
        {
         v=xb[i];
         xb[i]=xb[p[i]];
         xb[p[i]]=v;
        }
     }
   for(i=1; i<n; i++)
     {
      v=0.0;
      //--- calculation
      for(i_=0; i_<=i-1; i_++)
         v+=lua[i][i_]*xb[i_];
      //--- shift
      xb[i]=xb[i]-v;
     }
//--- change values
   xb[n-1]=xb[n-1]/(lua[n-1][n-1]*scalea);
   for(i=n-2; i>=0; i--)
     {
      for(i_=i+1; i_<n; i_++)
         tmp[i_]=lua[i][i_]*scalea;
      //--- calculation
      v=0.0;
      for(i_=i+1; i_<n; i_++)
         v+=tmp[i_]*xb[i_];
      //--- get result
      xb[i]=(xb[i]-v)/(lua[i][i]*scalea);
     }
  }
//+------------------------------------------------------------------+
//| Basic Cholesky solver for ScaleA*Cholesky(A)'*x = y.             |
//| This subroutine assumes that:                                    |
//| * A*ScaleA is well scaled                                        |
//| * A is well-conditioned, so no zero divisions or overflow may    |
//|   occur                                                          |
//+------------------------------------------------------------------+
void CDenseSolver::HPDBasicCholeskySolve(CMatrixComplex &cha,
                                         const double sqrtscalea,
                                         const int n,const bool IsUpper,
                                         complex &xb[],complex &tmp[])
  {
//--- create variables
   int     i=0;
   complex v=0;
   int     i_=0;
//--- A=L*L' or A=U'*U
   if(IsUpper)
     {
      //--- Solve U'*y=b first.
      for(i=0; i<n; i++)
        {
         xb[i]=xb[i]/(CMath::Conj(cha[i][i])*sqrtscalea);
         //--- check
         if(i<n-1)
           {
            v=xb[i];
            //--- calculation
            for(i_=i+1; i_<n; i_++)
               tmp[i_]=CMath::Conj(cha[i][i_])*sqrtscalea;
            for(i_=i+1; i_<n; i_++)
               xb[i_]=xb[i_]-v*tmp[i_];
           }
        }
      //--- Solve U*x=y then.
      for(i=n-1; i>=0; i--)
        {
         //--- check
         if(i<n-1)
           {
            for(i_=i+1; i_<n; i_++)
               tmp[i_]=cha[i][i_]*sqrtscalea;
            //--- change value
            v=0.0;
            for(i_=i+1; i_<n; i_++)
               v+=tmp[i_]*xb[i_];
            //--- shift
            xb[i]=xb[i]-v;
           }
         xb[i]=xb[i]/(cha[i][i]*sqrtscalea);
        }
     }
   else
     {
      //--- Solve L*y=b first
      for(i=0; i<n; i++)
        {
         //--- check
         if(i>0)
           {
            for(i_=0; i_<=i-1; i_++)
               tmp[i_]=cha[i][i_]*sqrtscalea;
            //--- change value
            v=0.0;
            for(i_=0; i_<=i-1; i_++)
               v+=tmp[i_]*xb[i_];
            //--- shift
            xb[i]=xb[i]-v;
           }
         xb[i]=xb[i]/(cha[i][i]*sqrtscalea);
        }
      //--- Solve L'*x=y then.
      for(i=n-1; i>=0; i--)
        {
         xb[i]=xb[i]/(CMath::Conj(cha[i][i])*sqrtscalea);
         //--- check
         if(i>0)
           {
            v=xb[i];
            //--- calculation
            for(i_=0; i_<=i-1; i_++)
               tmp[i_]=CMath::Conj(cha[i][i_])*sqrtscalea;
            for(i_=0; i_<=i-1; i_++)
               xb[i_]=xb[i_]-v*tmp[i_];
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Auxiliary class for CNlEq                                        |
//+------------------------------------------------------------------+
class CNlEqState
  {
public:
   //--- variables
   int               m_n;
   int               m_m;
   double            m_epsf;
   int               m_maxits;
   bool              m_xrep;
   double            m_stpmax;
   double            m_f;
   bool              m_needf;
   bool              m_needfij;
   bool              m_xupdated;
   RCommState        m_rstate;
   int               m_repiterationscount;
   int               m_repnfunc;
   int               m_repnjac;
   int               m_repterminationtype;
   double            m_fbase;
   double            m_fprev;
   //--- arrays
   double            m_x[];
   double            m_fi[];
   double            m_xbase[];
   double            m_candstep[];
   double            m_rightpart[];
   double            m_cgbuf[];
   //--- matrix
   CMatrixDouble     m_j;
   //--- constructor, destructor
                     CNlEqState(void);
                    ~CNlEqState(void) {}
   //--- copy
   void              Copy(CNlEqState &obj);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNlEqState::CNlEqState(void)
  {
   m_n=0;
   m_m=0;
   m_epsf=0;
   m_maxits=0;
   m_xrep=false;
   m_stpmax=0;
   m_f=0;
   m_needf=false;
   m_needfij=false;
   m_xupdated=false;
   m_repiterationscount=0;
   m_repnfunc=0;
   m_repnjac=0;
   m_repterminationtype=0;
   m_fbase=0;
   m_fprev=0;
  }
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CNlEqState::Copy(CNlEqState &obj)
  {
//--- copy variables
   m_n=obj.m_n;
   m_m=obj.m_m;
   m_epsf=obj.m_epsf;
   m_maxits=obj.m_maxits;
   m_xrep=obj.m_xrep;
   m_stpmax=obj.m_stpmax;
   m_f=obj.m_f;
   m_needf=obj.m_needf;
   m_needfij=obj.m_needfij;
   m_xupdated=obj.m_xupdated;
   m_repiterationscount=obj.m_repiterationscount;
   m_repnfunc=obj.m_repnfunc;
   m_repnjac=obj.m_repnjac;
   m_repterminationtype=obj.m_repterminationtype;
   m_fbase=obj.m_fbase;
   m_fprev=obj.m_fprev;
   m_rstate.Copy(obj.m_rstate);
//--- copy arrays
   ArrayCopy(m_x,obj.m_x);
   ArrayCopy(m_fi,obj.m_fi);
   ArrayCopy(m_xbase,obj.m_xbase);
   ArrayCopy(m_candstep,obj.m_candstep);
   ArrayCopy(m_rightpart,obj.m_rightpart);
   ArrayCopy(m_cgbuf,obj.m_cgbuf);
//--- copy matrix
   m_j=obj.m_j;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CNlEqState                       |
//+------------------------------------------------------------------+
class CNlEqStateShell
  {
private:
   CNlEqState        m_innerobj;
public:
   //--- constructors, destructor
                     CNlEqStateShell(void) {}
                     CNlEqStateShell(CNlEqState &obj) { m_innerobj.Copy(obj); }
                    ~CNlEqStateShell(void) {}
   //--- methods
   bool              GetNeedF(void);
   void              SetNeedF(const bool b);
   bool              GetNeedFIJ(void);
   void              SetNeedFIJ(const bool b);
   bool              GetXUpdated(void);
   void              SetXUpdated(const bool b);
   double            GetF(void);
   void              SetF(const double d);
   CNlEqState       *GetInnerObj(void);
  };
//+------------------------------------------------------------------+
//| Returns the value of the variable needf                          |
//+------------------------------------------------------------------+
bool CNlEqStateShell::GetNeedF(void)
  {
   return(m_innerobj.m_needf);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable needf                         |
//+------------------------------------------------------------------+
void CNlEqStateShell::SetNeedF(const bool b)
  {
   m_innerobj.m_needf=b;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable needfij                        |
//+------------------------------------------------------------------+
bool CNlEqStateShell::GetNeedFIJ(void)
  {
   return(m_innerobj.m_needfij);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable needfij                       |
//+------------------------------------------------------------------+
void CNlEqStateShell::SetNeedFIJ(const bool b)
  {
   m_innerobj.m_needfij=b;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable xupdated                       |
//+------------------------------------------------------------------+
bool CNlEqStateShell::GetXUpdated(void)
  {
   return(m_innerobj.m_xupdated);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable xupdated                      |
//+------------------------------------------------------------------+
void CNlEqStateShell::SetXUpdated(const bool b)
  {
   m_innerobj.m_xupdated=b;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable f                              |
//+------------------------------------------------------------------+
double CNlEqStateShell::GetF(void)
  {
   return(m_innerobj.m_f);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable f                             |
//+------------------------------------------------------------------+
void CNlEqStateShell::SetF(const double d)
  {
   m_innerobj.m_f=d;
  }
//+------------------------------------------------------------------+
//| Return object of class                                           |
//+------------------------------------------------------------------+
CNlEqState *CNlEqStateShell::GetInnerObj(void)
  {
   return(GetPointer(m_innerobj));
  }
//+------------------------------------------------------------------+
//| Auxiliary class for CNlEq                                        |
//+------------------------------------------------------------------+
class CNlEqReport
  {
public:
   //--- variables
   int               m_iterationscount;
   int               m_nfunc;
   int               m_njac;
   int               m_terminationtype;
   //--- constructor, destructor
                     CNlEqReport(void) { ZeroMemory(this); }
                    ~CNlEqReport(void) {}
   //--- copy
   void              Copy(CNlEqReport &obj);
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CNlEqReport::Copy(CNlEqReport &obj)
  {
//--- copy variables
   m_iterationscount=obj.m_iterationscount;
   m_nfunc=obj.m_nfunc;
   m_njac=obj.m_njac;
   m_terminationtype=obj.m_terminationtype;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CNlEqReport                      |
//+------------------------------------------------------------------+
class CNlEqReportShell
  {
private:
   CNlEqReport       m_innerobj;
public:
   //--- constructors, destructor
                     CNlEqReportShell(void) {}
                     CNlEqReportShell(CNlEqReport &obj) { m_innerobj.Copy(obj); }
                    ~CNlEqReportShell(void) {}
   //--- methods
   int               GetIterationsCount(void);
   void              SetIterationsCount(const int i);
   int               GetNFunc(void);
   void              SetNFunc(const int i);
   int               GetNJac(void);
   void              SetNJac(const int i);
   int               GetTerminationType(void);
   void              SetTerminationType(const int i);
   CNlEqReport      *GetInnerObj(void);
  };
//+------------------------------------------------------------------+
//| Returns the value of the variable iterationscount                |
//+------------------------------------------------------------------+
int CNlEqReportShell::GetIterationsCount(void)
  {
   return(m_innerobj.m_iterationscount);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable iterationscount               |
//+------------------------------------------------------------------+
void CNlEqReportShell::SetIterationsCount(const int i)
  {
   m_innerobj.m_iterationscount=i;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable nfunc                          |
//+------------------------------------------------------------------+
int CNlEqReportShell::GetNFunc(void)
  {
   return(m_innerobj.m_nfunc);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable nfunc                         |
//+------------------------------------------------------------------+
void CNlEqReportShell::SetNFunc(const int i)
  {
   m_innerobj.m_nfunc=i;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable njac                           |
//+------------------------------------------------------------------+
int CNlEqReportShell::GetNJac(void)
  {
   return(m_innerobj.m_njac);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable njac                          |
//+------------------------------------------------------------------+
void CNlEqReportShell::SetNJac(const int i)
  {
   m_innerobj.m_njac=i;
  }
//+------------------------------------------------------------------+
//| Returns the value of the variable terminationtype                |
//+------------------------------------------------------------------+
int CNlEqReportShell::GetTerminationType(void)
  {
   return(m_innerobj.m_terminationtype);
  }
//+------------------------------------------------------------------+
//| Changing the value of the variable terminationtype               |
//+------------------------------------------------------------------+
void CNlEqReportShell::SetTerminationType(const int i)
  {
   m_innerobj.m_terminationtype=i;
  }
//+------------------------------------------------------------------+
//| Return object of class                                           |
//+------------------------------------------------------------------+
CNlEqReport *CNlEqReportShell::GetInnerObj(void)
  {
   return(GetPointer(m_innerobj));
  }
//+------------------------------------------------------------------+
//| Solving systems of nonlinear equations                           |
//+------------------------------------------------------------------+
class CNlEq
  {
private:
   //--- private methods
   static void       ClearRequestFields(CNlEqState &state);
   static bool       IncreaseLambda(double &lambdav,double &nu,const double lambdaup);
   static void       DecreaseLambda(double &lambdav,double &nu,const double lambdadown);
   //--- auxiliary functions forNlEqiteration
   static void       Func_case_rcomm(CNlEqState &state,const int n,const int m,const int i,const bool b,const double lambdaup,const double lambdadown,const double lambdav,const double rho,const double mu,const double stepnorm);
   static void       Func_case_7(CNlEqState &state,const int n);
   static bool       Func_case_5(CNlEqState &state,double &lambdaup,double &lambdadown,double &lambdav,double &rho);
   static bool       Func_case_11(CNlEqState &state,const double stepnorm);
   static int        Func_case_10(CNlEqState &state,const int n,const int m,const int i,const bool b,const double lambdaup,const double lambdadown,const double lambdav,const double rho,const double mu,const double stepnorm);
   static int        Func_case_9(CNlEqState &state,int &n,int &m,int &i,bool &b,const double lambdaup,const double lambdadown,double &lambdav,const double rho,const double mu,double &stepnorm);

public:
   //--- constant
   static const int  m_armijomaxfev;
   //--- public methods
   static void       NlEqCreateLM(const int n,const int m,double &x[],CNlEqState &state);
   static void       NlEqSetCond(CNlEqState &state,double epsf,const int maxits);
   static void       NlEqSetXRep(CNlEqState &state,const bool needxrep);
   static void       NlEqSetStpMax(CNlEqState &state,const double stpmax);
   static void       NlEqResults(CNlEqState &state,double &x[],CNlEqReport &rep);
   static void       NlEqResultsBuf(CNlEqState &state,double &x[],CNlEqReport &rep);
   static void       NlEqRestartFrom(CNlEqState &state,double &x[]);
   static bool       NlEqIteration(CNlEqState &state);
  };
//+------------------------------------------------------------------+
//| Initialize constant                                              |
//+------------------------------------------------------------------+
const int CNlEq::m_armijomaxfev=20;
//+------------------------------------------------------------------+
//|                 LEVENBERG-MARQUARDT-LIKE NONLINEAR SOLVER        |
//| DESCRIPTION:                                                     |
//| This algorithm solves system of nonlinear equations              |
//|     F[0](x[0], ..., x[n-1])   = 0                                |
//|     F[1](x[0], ..., x[n-1])   = 0                                |
//|     ...                                                          |
//|     F[M-1](x[0], ..., x[n-1]) = 0                                |
//| with M/N do not necessarily coincide. Algorithm converges        |
//| quadratically under following conditions:                        |
//|     * the solution set XS is nonempty                            |
//|     * for some xs in XS there exist such neighbourhood N(xs)     |
//|       that:                                                      |
//|       * vector function F(x) and its Jacobian J(x) are           |
//|         continuously differentiable on N                         |
//|       * ||F(x)|| provides local error bound on N, i.e. there     |
//|         exists such c1, that ||F(x)||>c1*distance(x,XS)          |
//| Note that these conditions are much more weaker than usual       |
//| non-singularity conditions. For example, algorithm will converge |
//| for any affine function F (whether its Jacobian singular or not).|
//| REQUIREMENTS:                                                    |
//| Algorithm will request following information during its          |
//| operation:                                                       |
//| * function vector F[] and Jacobian matrix at given point X       |
//| * value of merit function f(x)=F[0]^2(x)+...+F[M-1]^2(x) at given|
//| point X                                                          |
//| USAGE:                                                           |
//| 1. User initializes algorithm state with NLEQCreateLM() call     |
//| 2. User tunes solver parameters with NLEQSetCond(),              |
//|    NLEQSetStpMax() and other functions                           |
//| 3. User calls NLEQSolve() function which takes algorithm state   |
//|    and pointers (delegates, etc.) to callback functions which    |
//|    calculate merit function value and Jacobian.                  |
//| 4. User calls NLEQResults() to get solution                      |
//| 5. Optionally, user may call NLEQRestartFrom() to solve another  |
//|    problem with same parameters (N/M) but another starting point |
//|    and/or another function vector. NLEQRestartFrom() allows to   |
//|    reuse already initialized structure.                          |
//| INPUT PARAMETERS:                                                |
//|     N       -   space dimension, N>1:                            |
//|                 * if provided, only leading N elements of X are  |
//|                   used                                           |
//|                 * if not provided, determined automatically from |
//|                   size of X                                      |
//|     M       -   system size                                      |
//|     X       -   starting point                                   |
//| OUTPUT PARAMETERS:                                               |
//|     State   -   structure which stores algorithm state           |
//| NOTES:                                                           |
//| 1. you may tune stopping conditions with NLEQSetCond() function  |
//| 2. if target function contains exp() or other fast growing       |
//|    functions, and optimization algorithm makes too large steps   |
//|    which leads to overflow, use NLEQSetStpMax() function to bound|
//|    algorithm's steps.                                            |
//| 3. this algorithm is a slightly modified implementation of the   |
//|    method described in 'Levenberg-Marquardt method for           |
//|    constrained nonlinear equations with strong local convergence |
//|    properties' by Christian Kanzow Nobuo Yamashita and Masao     |
//|    Fukushima and further developed in  'On the convergence of a  |
//|    New Levenberg-Marquardt Method' by Jin-yan Fan and Ya-Xiang   |
//|    Yuan.                                                         |
//+------------------------------------------------------------------+
void CNlEq::NlEqCreateLM(const int n,const int m,double &x[],
                         CNlEqState &state)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<1!"))
      return;
//--- check
   if(!CAp::Assert(m>=1,__FUNCTION__+": M<1!"))
      return;
//--- check
   if(!CAp::Assert(CAp::Len(x)>=n,__FUNCTION__+": Length(X)<N!"))
      return;
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(x,n),__FUNCTION__+": X contains infinite or NaN values!"))
      return;
//--- Initialize
   state.m_n=n;
   state.m_m=m;
   NlEqSetCond(state,0,0);
   NlEqSetXRep(state,false);
   NlEqSetStpMax(state,0);
//--- allocation
   ArrayResize(state.m_x,n);
   ArrayResize(state.m_xbase,n);
   state.m_j.Resize(m,n);
   ArrayResize(state.m_fi,m);
   ArrayResize(state.m_rightpart,n);
   ArrayResize(state.m_candstep,n);
//--- function call
   NlEqRestartFrom(state,x);
  }
//+------------------------------------------------------------------+
//| This function sets stopping conditions for the nonlinear solver  |
//| INPUT PARAMETERS:                                                |
//|     State   -   structure which stores algorithm state           |
//|     EpsF    -   >=0                                              |
//|                 The subroutine finishes  its work if on k+1-th   |
//|                 iteration the condition ||F||<=EpsF is satisfied |
//|     MaxIts  -   maximum number of iterations. If MaxIts=0, the   |
//|                 number of iterations is unlimited.               |
//| Passing EpsF=0 and MaxIts=0 simultaneously will lead to          |
//| automatic stopping criterion selection (small EpsF).             |
//| NOTES:                                                           |
//+------------------------------------------------------------------+
void CNlEq::NlEqSetCond(CNlEqState &state,double epsf,const int maxits)
  {
//--- check
   if(!CAp::Assert(CMath::IsFinite(epsf),__FUNCTION__+": EpsF is not finite number!"))
      return;
//--- check
   if(!CAp::Assert(epsf>=0.0,__FUNCTION__+": negative EpsF!"))
      return;
//--- check
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": negative MaxIts!"))
      return;
//--- check
   if(epsf==0.0 && maxits==0)
      epsf=1.0E-6;
//--- change values
   state.m_epsf=epsf;
   state.m_maxits=maxits;
  }
//+------------------------------------------------------------------+
//| This function turns on/off reporting.                            |
//| INPUT PARAMETERS:                                                |
//|     State   -   structure which stores algorithm state           |
//|     NeedXRep-   whether iteration reports are needed or not      |
//| If NeedXRep is True, algorithm will call rep() callback function |
//| if it is provided to NLEQSolve().                                |
//+------------------------------------------------------------------+
void CNlEq::NlEqSetXRep(CNlEqState &state,const bool needxrep)
  {
//--- change value
   state.m_xrep=needxrep;
  }
//+------------------------------------------------------------------+
//| This function sets maximum step length                           |
//| INPUT PARAMETERS:                                                |
//|     State   -   structure which stores algorithm state           |
//|     StpMax  -   maximum step length, >=0. Set StpMax to 0.0, if  |
//|                 you don't want to limit step length.             |
//| Use this subroutine when target function contains exp() or other |
//| fast growing functions, and algorithm makes too large steps which|
//| lead to overflow. This function allows us to reject steps that   |
//| are too large (and therefore expose us to the possible overflow) |
//| without actually calculating function value at the x+stp*d.      |
//+------------------------------------------------------------------+
void CNlEq::NlEqSetStpMax(CNlEqState &state,const double stpmax)
  {
//--- check
   if(!CAp::Assert(CMath::IsFinite(stpmax),__FUNCTION__+": StpMax is not finite!"))
      return;
//--- check
   if(!CAp::Assert(stpmax>=0.0,__FUNCTION__+": StpMax<0!"))
      return;
//--- change value
   state.m_stpmax=stpmax;
  }
//+------------------------------------------------------------------+
//| NLEQ solver results                                              |
//| INPUT PARAMETERS:                                                |
//|     State   -   algorithm state.                                 |
//| OUTPUT PARAMETERS:                                               |
//|     X       -   array[0..N-1], solution                          |
//|     Rep     -   optimization report:                             |
//|                 * Rep.TerminationType completetion code:         |
//|                     * -4    ERROR: algorithm has converged to the|
//|                             stationary point Xf which is local   |
//|                             minimum of f=F[0]^2+...+F[m-1]^2,    |
//|                             but is not solution of nonlinear     |
//|                             system.                              |
//|                     *  1    sqrt(f)<=EpsF.                       |
//|                     *  5    MaxIts steps was taken               |
//|                     *  7    stopping conditions are too          |
//|                             stringent, further improvement is    |
//|                             impossible                           |
//|                 * Rep.IterationsCount contains iterations count  |
//|                 * NFEV countains number of function calculations |
//|                 * ActiveConstraints contains number of active    |
//|                   constraints                                    |
//+------------------------------------------------------------------+
void CNlEq::NlEqResults(CNlEqState &state,double &x[],CNlEqReport &rep)
  {
   ArrayResize(x,0);
//--- function call
   NlEqResultsBuf(state,x,rep);
  }
//+------------------------------------------------------------------+
//| NLEQ solver results                                              |
//| Buffered implementation of NLEQResults(), which uses             |
//| pre-allocated buffer to store X[]. If buffer size is too small,  |
//| it resizes buffer. It is intended to be used in the inner cycles |
//| of performance critical algorithms where array reallocation      |
//| penalty is too large to be ignored.                              |
//+------------------------------------------------------------------+
void CNlEq::NlEqResultsBuf(CNlEqState &state,double &x[],CNlEqReport &rep)
  {
//--- check
   if(CAp::Len(x)<state.m_n)
      ArrayResize(x,state.m_n);
//--- copy
   for(int i_=0; i_<state.m_n; i_++)
      x[i_]=state.m_xbase[i_];
//--- change values
   rep.m_iterationscount=state.m_repiterationscount;
   rep.m_nfunc=state.m_repnfunc;
   rep.m_njac=state.m_repnjac;
   rep.m_terminationtype=state.m_repterminationtype;
  }
//+------------------------------------------------------------------+
//| This subroutine restarts CG algorithm from new point. All        |
//| optimization parameters are left unchanged.                      |
//| This function allows to solve multiple optimization problems     |
//| (which must have same number of dimensions) without object       |
//| reallocation penalty.                                            |
//| INPUT PARAMETERS:                                                |
//|     State   -   structure used for reverse communication         |
//|                 previously allocated with MinCGCreate call.      |
//|     X       -   new starting point.                              |
//|     BndL    -   new lower bounds                                 |
//|     BndU    -   new upper bounds                                 |
//+------------------------------------------------------------------+
void CNlEq::NlEqRestartFrom(CNlEqState &state,double &x[])
  {
//--- check
   if(!CAp::Assert(CAp::Len(x)>=state.m_n,__FUNCTION__+": Length(X)<N!"))
      return;
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(x,state.m_n),__FUNCTION__+": X contains infinite or NaN values!"))
      return;
//--- copy
   for(int i_=0; i_<state.m_n; i_++)
      state.m_x[i_]=x[i_];
//--- allocation
   state.m_rstate.ia.Resize(3);
   ArrayResizeAL(state.m_rstate.ba,1);
   state.m_rstate.ra.Resize(6);
   state.m_rstate.stage=-1;
//--- function call
   ClearRequestFields(state);
  }
//+------------------------------------------------------------------+
//| Clears request fileds (to be sure that we don't forgot to clear  |
//| something)                                                       |
//+------------------------------------------------------------------+
void CNlEq::ClearRequestFields(CNlEqState &state)
  {
//--- change values
   state.m_needf=false;
   state.m_needfij=false;
   state.m_xupdated=false;
  }
//+------------------------------------------------------------------+
//| Increases lambda,returns False when there is a danger of         |
//| overflow                                                         |
//+------------------------------------------------------------------+
bool CNlEq::IncreaseLambda(double &lambdav,double &nu,const double lambdaup)
  {
//--- create variables
   double lnlambda=MathLog(lambdav);
   double lnlambdaup=MathLog(lambdaup);
   double lnnu=MathLog(nu);
   double lnmax=0.5*MathLog(CMath::m_maxrealnumber);
//--- check
   if(lnlambda+lnlambdaup+lnnu>lnmax)
      return(false);
//--- check
   if(lnnu+MathLog(2)>lnmax)
      return(false);
//--- change values
   lambdav=lambdav*lambdaup*nu;
   nu=nu*2;
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Decreases lambda, but leaves it unchanged when there is danger of|
//| underflow.                                                       |
//+------------------------------------------------------------------+
void CNlEq::DecreaseLambda(double &lambdav,double &nu,const double lambdadown)
  {
//--- initialization
   nu=1;
//--- check
   if(MathLog(lambdav)+MathLog(lambdadown)<MathLog(CMath::m_minrealnumber))
      lambdav=CMath::m_minrealnumber;
   else
      lambdav=lambdav*lambdadown;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNlEq::NlEqIteration(CNlEqState &state)
  {
//--- create variables
   int    n=0;
   int    m=0;
   int    i=0;
   double lambdaup=0;
   double lambdadown=0;
   double lambdav=0;
   double rho=0;
   double mu=0;
   double stepnorm=0;
   bool   b;
   int    i_=0;
   int    temp;
//--- This code initializes locals by:
//--- * random values determined during code
//---   generation - on first subroutine call
//--- * values from previous call - on subsequent calls
   if(state.m_rstate.stage>=0)
     {
      //--- initialization
      n=state.m_rstate.ia[0];
      m=state.m_rstate.ia[1];
      i=state.m_rstate.ia[2];
      b=state.m_rstate.ba[0];
      lambdaup=state.m_rstate.ra[0];
      lambdadown=state.m_rstate.ra[1];
      lambdav=state.m_rstate.ra[2];
      rho=state.m_rstate.ra[3];
      mu=state.m_rstate.ra[4];
      stepnorm=state.m_rstate.ra[5];
     }
   else
     {
      //--- initialization
      n=-983;
      m=-989;
      i=-834;
      b=false;
      lambdaup=-287;
      lambdadown=364;
      lambdav=214;
      rho=-338;
      mu=-686;
      stepnorm=912;
     }
//--- check
   if(state.m_rstate.stage==0)
     {
      //--- change values
      state.m_needf=false;
      state.m_repnfunc=state.m_repnfunc+1;
      //--- copy
      for(i_=0; i_<n; i_++)
         state.m_xbase[i_]=state.m_x[i_];
      //--- change values
      state.m_fbase=state.m_f;
      state.m_fprev=CMath::m_maxrealnumber;
      //--- check
      if(!state.m_xrep)
        {
         //--- check
         if(!Func_case_5(state,lambdaup,lambdadown,lambdav,rho))
            return(false);
         //--- function call
         Func_case_7(state,n);
         //--- Saving state
         Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
         //--- return result
         return(true);
        }
      //--- progress report
      ClearRequestFields(state);
      state.m_xupdated=true;
      state.m_rstate.stage=1;
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(true);
     }
//--- check
   if(state.m_rstate.stage==1)
     {
      //--- change value
      state.m_xupdated=false;
      //--- check
      if(!Func_case_5(state,lambdaup,lambdadown,lambdav,rho))
         return(false);
      //--- function call
      Func_case_7(state,n);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(true);
     }
//--- check
   if(state.m_rstate.stage==2)
     {
      //--- change values
      state.m_needfij=false;
      state.m_repnfunc=state.m_repnfunc+1;
      state.m_repnjac=state.m_repnjac+1;
      //--- function call
      CAblas::RMatrixMVect(n,m,state.m_j,0,0,1,state.m_fi,0,state.m_rightpart,0);
      for(i_=0; i_<n; i_++)
         state.m_rightpart[i_]=-1*state.m_rightpart[i_];
      //--- Inner cycle: find good lambda
      temp=Func_case_9(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- check
      if(temp==-1)
         return(false);
      //--- check
      if(temp==1)
         return(true);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(true);
     }
//--- check
   if(state.m_rstate.stage==3)
     {
      //--- change values
      state.m_needf=false;
      state.m_repnfunc=state.m_repnfunc+1;
      //--- check
      if(state.m_f<state.m_fbase)
        {
         //--- function value decreased,move on
         DecreaseLambda(lambdav,rho,lambdadown);
         temp=Func_case_10(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
         //--- check
         if(temp==-1)
            return(false);
         //--- check
         if(temp==1)
            return(true);
         //--- Saving state
         Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
         //--- return result
         return(true);
        }
      //--- check
      if(!IncreaseLambda(lambdav,rho,lambdaup))
        {
         //--- Lambda is too large (near overflow),force zero step and break
         stepnorm=0;
         for(i_=0; i_<n; i_++)
            state.m_x[i_]=state.m_xbase[i_];
         state.m_f=state.m_fbase;
         temp=Func_case_10(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
         //--- check
         if(temp==-1)
            return(false);
         //--- check
         if(temp==1)
            return(true);
         //--- Saving state
         Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
         //--- return result
         return(true);
        }
      temp=Func_case_9(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- check
      if(temp==-1)
         return(false);
      //--- check
      if(temp==1)
         return(true);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(true);
     }
//--- check
   if(state.m_rstate.stage==4)
     {
      //--- change value
      state.m_xupdated=false;
      //--- check
      if(!Func_case_11(state,stepnorm))
         return(false);
      //--- Now,iteration is finally over
      Func_case_7(state,n);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(true);
     }
//--- Routine body
//--- Prepare
   n=state.m_n;
   m=state.m_m;
   state.m_repterminationtype=0;
   state.m_repiterationscount=0;
   state.m_repnfunc=0;
   state.m_repnjac=0;
//--- Calculate F/G,initialize algorithm
   ClearRequestFields(state);
   state.m_needf=true;
   state.m_rstate.stage=0;
//--- Saving state
   Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
void CNlEq::Func_case_rcomm(CNlEqState &state,const int n,const int m,
                            const int i,const bool b,const double lambdaup,
                            const double lambdadown,const double lambdav,
                            const double rho,const double mu,const double stepnorm)
  {
//--- save
   state.m_rstate.ia.Set(0,n);
   state.m_rstate.ia.Set(1,m);
   state.m_rstate.ia.Set(2,i);
   state.m_rstate.ba[0]=b;
   state.m_rstate.ra.Set(0,lambdaup);
   state.m_rstate.ra.Set(1,lambdadown);
   state.m_rstate.ra.Set(2,lambdav);
   state.m_rstate.ra.Set(3,rho);
   state.m_rstate.ra.Set(4,mu);
   state.m_rstate.ra.Set(5,stepnorm);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
void CNlEq::Func_case_7(CNlEqState &state,const int n)
  {
//--- Get Jacobian;
//--- before we get to this point we already have State.XBase filled
//--- with current point and State.FBase filled with function value
//--- at XBase
   ClearRequestFields(state);
   state.m_needfij=true;
//--- copy
   for(int i_=0; i_<n; i_++)
      state.m_x[i_]=state.m_xbase[i_];
   state.m_rstate.stage=2;
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
bool CNlEq::Func_case_5(CNlEqState &state,double &lambdaup,
                        double &lambdadown,double &lambdav,
                        double &rho)
  {
//--- check
   if(state.m_f<=CMath::Sqr(state.m_epsf))
     {
      state.m_repterminationtype=1;
      return(false);
     }
//--- change values
   lambdaup=10;
   lambdadown=0.3;
   lambdav=0.001;
   rho=1;
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
bool CNlEq::Func_case_11(CNlEqState &state,const double stepnorm)
  {
//--- Test stopping conditions on F,step (zero/non-zero) and MaxIts;
//--- If one of the conditions is met,RepTerminationType is changed.
   if(MathSqrt(state.m_f)<=state.m_epsf)
      state.m_repterminationtype=1;
//--- check
   if(stepnorm==0.0 && state.m_repterminationtype==0)
      state.m_repterminationtype=-4;
//--- check
   if(state.m_repiterationscount>=state.m_maxits && state.m_maxits>0)
      state.m_repterminationtype=5;
//--- check
   if(state.m_repterminationtype!=0)
      return(false);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
int CNlEq::Func_case_10(CNlEqState &state,const int n,const int m,
                        const int i,const bool b,const double lambdaup,
                        const double lambdadown,const double lambdav,
                        const double rho,const double mu,
                        const double stepnorm)
  {
//--- Accept step:
//--- * new position
//--- * new function value
   state.m_fbase=state.m_f;
   for(int i_=0; i_<n; i_++)
      state.m_xbase[i_]=state.m_xbase[i_]+stepnorm*state.m_candstep[i_];
   state.m_repiterationscount=state.m_repiterationscount+1;
//--- Report new iteration
   if(!state.m_xrep)
     {
      //--- check
      if(!Func_case_11(state,stepnorm))
         return(-1);
      //--- Now,iteration is finally over
      Func_case_7(state,n);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(1);
     }
//--- function call
   ClearRequestFields(state);
//--- change values
   state.m_xupdated=true;
   state.m_f=state.m_fbase;
//--- copy
   for(int i_=0; i_<n; i_++)
      state.m_x[i_]=state.m_xbase[i_];
   state.m_rstate.stage=4;
//--- return result
   return(0);
  }
//+------------------------------------------------------------------+
//| Auxiliary function for NlEqiteration. Is a product to get rid of |
//| the operator unconditional jump goto.                            |
//+------------------------------------------------------------------+
int CNlEq::Func_case_9(CNlEqState &state,int &n,int &m,int &i,bool &b,
                       const double lambdaup,const double lambdadown,
                       double &lambdav,const double rho,const double mu,
                       double &stepnorm)
  {
//--- Solve (J^T*J + (Lambda+Mu)*I)*y=J^T*F
//--- to get step d=-y where:
//--- * Mu=||F|| - is damping parameter for nonlinear system
//--- * Lambda   - is additional Levenberg-Marquardt parameter
//---              for better convergence when far away from minimum
   for(i=0; i<n; i++)
      state.m_candstep[i]=0;
//--- function call
   CFbls::FblsSolveCGx(state.m_j,m,n,lambdav,state.m_rightpart,state.m_candstep,state.m_cgbuf);
//--- Normalize step (it must be no more than StpMax)
   stepnorm=0;
   for(i=0; i<n; i++)
     {
      //--- check
      if(state.m_candstep[i]!=0.0)
        {
         stepnorm=1;
         break;
        }
     }
   CLinMin::LinMinNormalized(state.m_candstep,stepnorm,n);
//--- check
   if(state.m_stpmax!=0.0)
      stepnorm=MathMin(stepnorm,state.m_stpmax);
//--- Test new step - is it good enough?
//--- * if not,Lambda is increased and we try again.
//--- * if step is good,we decrease Lambda and move on.
//--- We can break this cycle on two occasions:
//--- * step is so small that x+step==x (in floating point arithmetics)
//--- * lambda is so large
   for(int i_=0; i_<n; i_++)
      state.m_x[i_]=state.m_xbase[i_];
   for(int i_=0; i_<n; i_++)
      state.m_x[i_]=state.m_x[i_]+stepnorm*state.m_candstep[i_];
   b=true;
   for(i=0; i<n; i++)
     {
      //--- check
      if(state.m_x[i]!=state.m_xbase[i])
        {
         b=false;
         break;
        }
     }
//--- check
   if(b)
     {
      //--- Step is too small,force zero step and break
      stepnorm=0;
      for(int i_=0; i_<n; i_++)
         state.m_x[i_]=state.m_xbase[i_];
      state.m_f=state.m_fbase;
      //--- function call
      int temp=Func_case_10(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- check
      if(temp!=0)
         return(temp);
      //--- Saving state
      Func_case_rcomm(state,n,m,i,b,lambdaup,lambdadown,lambdav,rho,mu,stepnorm);
      //--- return result
      return(1);
     }
//--- function call
   ClearRequestFields(state);
//--- change values
   state.m_needf=true;
   state.m_rstate.stage=3;
//--- return result
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct CPolynomialSolverReport
  {
   double            m_maxerr;
   //--- constructor / destructor
                     CPolynomialSolverReport(void) { m_maxerr=0; }
                    ~CPolynomialSolverReport(void) {}
   void              Copy(const CPolynomialSolverReport &obj) { m_maxerr=obj.m_maxerr; }
   //--- overloading
   void              operator=(const CPolynomialSolverReport &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPolynomialSolver
  {
public:
   static void       PolynomialSolve(CRowDouble &a,int n,CRowComplex &x,CPolynomialSolverReport &rep);
  };
//+------------------------------------------------------------------+
//| Polynomial root finding.                                         |
//| This function returns all roots of the polynomial                |
//|      P(x) = a0 + a1*x + a2*x^2 + ... + an*x^n                    |
//| Both real and complex roots are returned (see below).            |
//| INPUT PARAMETERS:                                                |
//|   A        -  array[N+1], polynomial coefficients:               |
//|               * A[0] is constant term                            |
//|               * A[N] is a coefficient of X^N                     |
//|   N        -  polynomial degree                                  |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array of complex roots:                            |
//|               * for isolated real root, X[I] is strictly real:   |
//|                 IMAGE(X[I])=0                                    |
//|               * complex roots are always returned in pairs-roots |
//|                 occupy positions I and I+1, with:                |
//|                  * X[I+1]=Conj(X[I])                             |
//|                  * IMAGE(X[I]) > 0                               |
//|                  * IMAGE(X[I+1]) = -IMAGE(X[I]) < 0              |
//|               * multiple real roots may have non-zero imaginary  |
//|                 part due to roundoff errors. There is no reliable|
//|                 way to distinguish real root of multiplicity 2   |
//|                 from two complex roots in the presence of        |
//|                 roundoff errors.                                 |
//|   Rep      -  report, additional information, following fields   |
//|               are set:                                           |
//|               * Rep.MaxErr - max( |P(xi)| )  for  i=0..N-1. This |
//|                 field allows to quickly estimate "quality" of the|
//|                 roots being returned.                            |
//| NOTE: this function uses companion matrix method to find roots.  |
//|       In case internal EVD solver fails do find eigenvalues,     |
//|       exception is generated.                                    |
//| NOTE: roots are not "polished" and no matrix balancing is        |
//|       performed for them.                                        |
//+------------------------------------------------------------------+
void CPolynomialSolver::PolynomialSolve(CRowDouble &A,int n,
                                        CRowComplex &x,
                                        CPolynomialSolverReport &rep)
  {
//--- create variables
   CMatrixDouble c;
   CMatrixDouble vl;
   CMatrixDouble vr;
   CRowDouble wr;
   CRowDouble wi;
   int     i=0;
   int     j=0;
   bool    status=false;
   int     nz=0;
   int     ne=0;
   complex v=0;
   complex vv=0;
   CRowDouble a=A;
   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CAp::Len(a)>n,__FUNCTION__+": Length(A)<N+1"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(a,n+1),__FUNCTION__+": A contains infitite numbers"))
      return;
   if(!CAp::Assert(a[n]!=0.0,__FUNCTION__+": A[N]=0"))
      return;
//--- Prepare
   x.Resize(n);
//--- Normalize A:
//--- * analytically determine NZ zero roots
//--- * quick exit for NZ=N
//--- * make residual NE-th degree polynomial monic
//---   (here NE=N-NZ)
   nz=0;
   while(nz<n && a[nz]==0.0)
      nz++;
   ne=n-nz;
   for(i=nz; i<=n; i++)
      a.Set(i-nz,a[i]/a[n]);
//--- For NZ<N, build companion matrix and find NE non-zero roots
   if(ne>0)
     {
      c=matrix<double>::Zeros(ne,ne);
      c.Set(0,ne-1,-a[0]);
      for(i=1; i<ne; i++)
        {
         c.Set(i,i-1,1);
         c.Set(i,ne-1,-a[i]);
        }
      status=CEigenVDetect::RMatrixEVD(c,ne,0,wr,wi,vl,vr);
      //--- check
      if(!CAp::Assert(status,__FUNCTION__+": inernal error - EVD solver failed"))
         return;
      for(i=0; i<ne; i++)
        {
         x.SetRe(i,wr[i]);
         x.SetIm(i,wi[i]);
        }
     }
//--- Remaining NZ zero roots
   for(i=ne; i<n; i++)
      x.Set(i,0.0);
//--- Rep
   rep.m_maxerr=0;
   for(i=0; i<ne; i++)
     {
      v=0;
      vv=1;
      for(j=0; j<=ne; j++)
        {
         v=v+a[j]*vv;
         vv=vv*x[i];
        }
      rep.m_maxerr=MathMax(rep.m_maxerr,CMath::AbsComplex(v));
     }
  }
//+------------------------------------------------------------------+
//| This structure is a sparse solver report (both direct and        |
//| iterative solvers use this structure).                           |
//| Following fields can be accessed by users:                       |
//|   *  TerminationType (specific error codes depend on the solver  |
//|      being used, with positive values ALWAYS signaling that      |
//|      something useful is returned in X, and negative values      |
//|      ALWAYS meaning critical failures.                           |
//|   *  NMV - number of matrix - vector products performed (0 for   |
//|      direct solvers)                                             |
//|   *  IterationsCount - inner iterations count (0 for direct      |
//|      solvers)                                                    |
//|   *  R2 - squared residual                                       |
//+------------------------------------------------------------------+
struct CSparseSolverReport
  {
   int               m_iterationscount;
   int               m_nmv;
   int               m_terminationtype;
   double            m_r2;
   //--- constructor / destructor
                     CSparseSolverReport(void) { ZeroMemory(this); }
                    ~CSparseSolverReport(void) {}
   //---
   void              Copy(const CSparseSolverReport &obj)
     {
      m_iterationscount=obj.m_iterationscount;
      m_nmv=obj.m_nmv;
      m_terminationtype=obj.m_terminationtype;
      m_r2=obj.m_r2;
     }
   //--- overloading
   void              operator=(const CSparseSolverReport &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDirectSparseSolvers
  {
public:
   static void       SparseSPDSolveSKS(CSparseMatrix &a,bool IsUpper,CRowDouble &b,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSPDSolve(CSparseMatrix &a,bool IsUpper,CRowDouble &b,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSPDCholeskySolve(CSparseMatrix &a,bool IsUpper,CRowDouble &b,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSolve(CSparseMatrix &a,CRowDouble &b,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseLUSolve(CSparseMatrix &a,CRowInt &p,CRowInt &q,CRowDouble &b,CRowDouble &x,CSparseSolverReport &rep);
   static void       InitSparseSolverReport(CSparseSolverReport &rep);
  };
//+------------------------------------------------------------------+
//| Sparse linear solver for A*x = b with N*N sparse real symmetric  |
//| positive definite matrix A, N * 1 vectors x and b.               |
//| This solver converts input matrix to SKS format, performs        |
//| Cholesky factorization using SKS Cholesky subroutine (works well |
//| for limited bandwidth matrices) and uses sparse triangular       |
//| solvers to get solution of the original system.                  |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse matrix, must be NxN exactly                 |
//|   IsUpper  -  which half of A is provided (another half is       |
//|               ignored)                                           |
//|   B        -  array[0..N - 1], right part                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], it contains:                             |
//|               * rep.m_terminationtype > 0    =>  solution        |
//|               * rep.m_terminationtype = -3   =>  filled by zeros |
//|   Rep      -  solver report, following fields are set:           |
//|               * rep.m_terminationtype - solver status; > 0 for   |
//|                                       success, set to - 3 on     |
//|                                       failure (degenerate or     |
//|                                       non-SPD system).           |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::SparseSPDSolveSKS(CSparseMatrix &a,
                                             bool IsUpper,
                                             CRowDouble &b,
                                             CRowDouble &x,
                                             CSparseSolverReport &rep)
  {
//--- create variables
   CSparseMatrix a2 ;
   int n=CSparse::SparseGetNRows(a);

   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains infinities or NANs"))
      return;

   InitSparseSolverReport(rep);
   CSparse::SparseCopyToSKS(a,a2);
   if(!CTrFac::SparseCholeskySkyLine(a2,n,IsUpper))
     {
      rep.m_terminationtype=-3;
      x=vector<double>::Zeros(n);
      return;
     }

   x=b;
   x.Resize(n);
   if(IsUpper)
     {
      CSparse::SparseTRSV(a2,IsUpper,false,1,x);
      CSparse::SparseTRSV(a2,IsUpper,false,0,x);
     }
   else
     {
      CSparse::SparseTRSV(a2,IsUpper,false,0,x);
      CSparse::SparseTRSV(a2,IsUpper,false,1,x);
     }

   rep.m_terminationtype=1;
  }
//+------------------------------------------------------------------+
//| Sparse linear solver for A*x = b with N*N sparse real symmetric  |
//| positive definite matrix A, N * 1 vectors x and b.               |
//| This solver converts input matrix to CRS format, performs        |
//| Cholesky factorization using supernodal Cholesky decomposition   |
//| with permutation-reducing ordering and uses sparse triangular    |
//| solver to get solution of the original system.                   |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse matrix, must be NxN exactly                 |
//|   IsUpper  -  which half of A is provided (another half is       |
//|               ignored)                                           |
//|   B        -  array[N], right part                               |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], it contains:                             |
//|               * rep.m_terminationtype > 0  => solution           |
//|               * rep.m_terminationtype = -3  => filled by zeros   |
//|   Rep      -  solver report, following fields are set:           |
//|               * rep.m_terminationtype - solver status; > 0 for   |
//|                                         success, set to - 3 on   |
//|                                         failure (degenerate or   |
//|                                         non-SPD system).         |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::SparseSPDSolve(CSparseMatrix &a,
                                          bool IsUpper,
                                          CRowDouble &b,
                                          CRowDouble &x,
                                          CSparseSolverReport &rep)
  {
//--- create variables
   int    n=CSparse::SparseGetNRows(a);
   double v=0;
   CSparseMatrix a2;
   CRowInt p;

   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains infinities or NANs"))
      return;

   InitSparseSolverReport(rep);
   CSparse::SparseCopyToCRS(a,a2);
   if(!CTrFac::SparseCholeskyP(a2,IsUpper,p))
     {
      rep.m_terminationtype=-3;
      x=vector<double>::Zeros(n);
      return;
     }
   CAblasF::RCopyAllocV(n,b,x);

   for(int i=0; i<n; i++)
      x.Swap(i,p[i]);
   if(IsUpper)
     {
      CSparse::SparseTRSV(a2,IsUpper,false,1,x);
      CSparse::SparseTRSV(a2,IsUpper,false,0,x);
     }
   else
     {
      CSparse::SparseTRSV(a2,IsUpper,false,0,x);
      CSparse::SparseTRSV(a2,IsUpper,false,1,x);
     }
   for(int i=n-1; i>=0; i--)
      x.Swap(i,p[i]);

   rep.m_terminationtype=1;
  }
//+------------------------------------------------------------------+
//| Sparse linear solver for A*x = b with N*N real symmetric positive|
//| definite matrix A given by its Cholesky decomposition, and N * 1 |
//| vectors x and b.                                                 |
//| IMPORTANT: this solver requires input matrix to be in the SKS    |
//|            (Skyline) or CRS (compressed row storage) format. An  |
//|            exception will be generated if you pass matrix in some|
//|            other format.                                         |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse NxN matrix stored in CRs or SKS format, must|
//|               be NxN exactly                                     |
//|   IsUpper  -  which half of A is provided (another half is       |
//|               ignored)                                           |
//|   B        -  array[N], right part                               |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], it contains:                             |
//|               * rep.m_terminationtype > 0  => solution           |
//|               * rep.m_terminationtype = -3  => filled by zeros   |
//|   Rep      -  solver report, following fields are set:           |
//|               * rep.m_terminationtype - solver status; > 0 for   |
//|                                         success, set to - 3 on   |
//|                                         failure (degenerate or   |
//|                                         non-SPD system).         |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::SparseSPDCholeskySolve(CSparseMatrix &a,
                                                  bool IsUpper,
                                                  CRowDouble &b,
                                                  CRowDouble &x,
                                                  CSparseSolverReport &rep)
  {
   int n=CSparse::SparseGetNRows(a);

   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseIsSKS(a) || CSparse::SparseIsCRS(a),__FUNCTION__+": A is not an SKS/CRS matrix"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains infinities or NANs"))
      return;

   InitSparseSolverReport(rep);
   for(int i=0; i<n; i++)
     {
      if(CSparse::SparseGet(a,i,i)==0.0)
        {
         rep.m_terminationtype=-3;
         x=vector<double>::Zeros(n);
         return;
        }
     }

   x=b;
   x.Resize(n);
   if(IsUpper)
     {
      CSparse::SparseTRSV(a,IsUpper,false,1,x);
      CSparse::SparseTRSV(a,IsUpper,false,0,x);
     }
   else
     {
      CSparse::SparseTRSV(a,IsUpper,false,0,x);
      CSparse::SparseTRSV(a,IsUpper,false,1,x);
     }

   rep.m_terminationtype=1;
  }
//+------------------------------------------------------------------+
//| Sparse linear solver for A*x = b with general (nonsymmetric) N*N |
//| sparse real matrix A, N * 1 vectors x and b.                     |
//| This solver converts input matrix to CRS format, performs LU     |
//| factorization and uses sparse triangular solvers to get solution |
//| of the original system.                                          |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse matrix, must be NxN exactly, any storage    |
//|               format                                             |
//|   N        -  size of A, N > 0                                   |
//|   B        -  array[0..N - 1], right part                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], it contains:                             |
//|               * rep.m_terminationtype > 0  => solution           |
//|               * rep.m_terminationtype = -3  => filled by zeros   |
//|   Rep      -  solver report, following fields are set:           |
//|               * rep.m_terminationtype - solver status; > 0 for   |
//|                 success, set to - 3 on failure (degenerate       |
//|                 system).                                         |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::SparseSolve(CSparseMatrix &a,
                                       CRowDouble &b,
                                       CRowDouble &x,
                                       CSparseSolverReport &rep)
  {
//--- create variables
   int    n=CSparse::SparseGetNRows(a);
   double v=0;
   CSparseMatrix a2;
   CRowInt pivp;
   CRowInt pivq;

   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains infinities or NANs"))
      return;

   InitSparseSolverReport(rep);
   CSparse::SparseCopyToCRS(a,a2);
   if(!CTrFac::SparseLU(a2,0,pivp,pivq))
     {
      rep.m_terminationtype=-3;
      x=vector<double>::Zeros(n);
      return;
     }

   x=b;
   x.Resize(n);
   for(int i=0; i<n; i++)
      x.Swap(i,pivp[i]);
   CSparse::SparseTRSV(a2,false,true,0,x);
   CSparse::SparseTRSV(a2,true,false,0,x);
   for(int i=n-1; i>=0; i--)
      x.Swap(i,pivq[i]);

   rep.m_terminationtype=1;
  }
//+------------------------------------------------------------------+
//| Sparse linear solver for A*x = b with general (nonsymmetric) N*N |
//| sparse real matrix A given by its LU factorization, N*1 vectors x|
//| and b.                                                           |
//| IMPORTANT: this solver requires input matrix to be in the CRS    |
//|            sparse storage format. An exception will be generated |
//|            if you pass matrix in some other format (HASH or SKS).|
//| INPUT PARAMETERS:                                                |
//|   A        -  LU factorization of the sparse matrix, must be NxN |
//|               exactly in CRS storage format                      |
//|   P, Q     -  pivot indexes from LU factorization                |
//|   N        -  size of A, N > 0                                   |
//|   B        -  array[0..N - 1], right part                        |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], it contains:                             |
//|               * rep.m_terminationtype > 0  => solution           |
//|               * rep.m_terminationtype = -3  => filled by zeros   |
//|   Rep      -  solver report, following fields are set:           |
//|               * rep.m_terminationtype - solver status; > 0 for   |
//|                                         success, set to - 3 on   |
//|                                         failure (degenerate      |
//|                                         system).                 |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::SparseLUSolve(CSparseMatrix &a,
                                         CRowInt &p,
                                         CRowInt &q,
                                         CRowDouble &b,
                                         CRowDouble &x,
                                         CSparseSolverReport &rep)
  {
//--- create variables
   int    n=CSparse::SparseGetNRows(a);
   int    i=0;
   int    j=0;
   double v=0;

   x.Resize(0);
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseIsCRS(a),__FUNCTION__+": A is not an SKS matrix"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains infinities or NANs"))
      return;
   if(!CAp::Assert(CAp::Len(p)>=n,__FUNCTION__+": length(P)<N"))
      return;
   if(!CAp::Assert(CAp::Len(q)>=n,__FUNCTION__+": length(Q)<N"))
      return;

   for(i=0; i<n; i++)
     {
      //--- check
      if(!CAp::Assert(p[i]>=i && p[i]<n,__FUNCTION__+": P is corrupted"))
         return;
      if(!CAp::Assert(q[i]>=i && q[i]<n,__FUNCTION__+": Q is corrupted"))
         return;
     }
   InitSparseSolverReport(rep);
   x.Resize(n);
   for(i=0; i<n; i++)
     {
      if(a.m_DIdx[i]==a.m_UIdx[i] || a.m_Vals[a.m_DIdx[i]]==0.0)
        {
         rep.m_terminationtype=-3;
         x=vector<double>::Zeros(n);
         return;
        }
     }

   x=b;
   x.Resize(n);
   for(i=0; i<n; i++)
      x.Swap(i,p[i]);
   CSparse::SparseTRSV(a,false,true,0,x);
   CSparse::SparseTRSV(a,true,false,0,x);
   for(i=n-1; i>=0; i--)
      x.Swap(i,q[i]);
   rep.m_terminationtype=1;
  }
//+------------------------------------------------------------------+
//| Reset report fields                                              |
//+------------------------------------------------------------------+
void CDirectSparseSolvers::InitSparseSolverReport(CSparseSolverReport &rep)
  {
   rep.m_terminationtype=0;
   rep.m_nmv=0;
   rep.m_iterationscount=0;
   rep.m_r2=0;
  }
//+------------------------------------------------------------------+
//| This object stores state of the sparse linear solver object.     |
//| You should use ALGLIB functions to work with this object.        |
//| Never try to access its fields directly!                         |
//+------------------------------------------------------------------+
struct CSparseSolverState
  {
   int               m_algotype;
   int               m_gmresk;
   int               m_maxits;
   int               m_n;
   int               m_repiterationscount;
   int               m_repnmv;
   int               m_repterminationtype;
   int               m_requesttype;
   double            m_epsf;
   double            m_reply1;
   double            m_repr2;
   bool              m_running;
   bool              m_userterminationneeded;
   bool              m_xrep;
   RCommState        m_rstate;
   CSparseMatrix     m_convbuf;
   CRowDouble        m_ax;
   CRowDouble        m_b;
   CRowDouble        m_wrkb;
   CRowDouble        m_x0;
   CRowDouble        m_x;
   CRowDouble        m_xf;
   CFblsGMRESState   m_gmressolver;
   //--- constructor / destructor
                     CSparseSolverState(void);
                    ~CSparseSolverState(void) {}
   //---
   void              Copy(const CSparseSolverState &obj);
   //--- overloading
   void              operator=(const CSparseSolverState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSparseSolverState::CSparseSolverState(void)
  {
   m_algotype=0;
   m_gmresk=0;
   m_maxits=0;
   m_n=0;
   m_repiterationscount=0;
   m_repnmv=0;
   m_repterminationtype=0;
   m_requesttype=0;
   m_epsf=0;
   m_reply1=0;
   m_repr2=0;
   m_running=false;
   m_userterminationneeded=false;
   m_xrep=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSparseSolverState::Copy(const CSparseSolverState &obj)
  {
   m_rstate=obj.m_rstate;
   m_algotype=obj.m_algotype;
   m_gmresk=obj.m_gmresk;
   m_maxits=obj.m_maxits;
   m_n=obj.m_n;
   m_repiterationscount=obj.m_repiterationscount;
   m_repnmv=obj.m_repnmv;
   m_repterminationtype=obj.m_repterminationtype;
   m_requesttype=obj.m_requesttype;
   m_epsf=obj.m_epsf;
   m_reply1=obj.m_reply1;
   m_repr2=obj.m_repr2;
   m_running=obj.m_running;
   m_userterminationneeded=obj.m_userterminationneeded;
   m_xrep=obj.m_xrep;
   m_convbuf=obj.m_convbuf;
   m_ax=obj.m_ax;
   m_b=obj.m_b;
   m_wrkb=obj.m_wrkb;
   m_x0=obj.m_x0;
   m_x=obj.m_x;
   m_xf=obj.m_xf;
   m_gmressolver=obj.m_gmressolver;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CIterativeSparse
  {
public:
   static void       SparseSolveSymmetricGMRES(CSparseMatrix &a,bool IsUpper,CRowDouble &b,int k,double epsf,int maxits,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSolveGMRES(CSparseMatrix &a,CRowDouble &b,int k,double epsf,int maxits,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSolverCreate(int n,CSparseSolverState &state);
   static void       SparseSolverSetAlgoGMRES(CSparseSolverState &state,int k);
   static void       SparseSolverSetStartingPoint(CSparseSolverState &state,CRowDouble &x);
   static void       SparseSolverSetCond(CSparseSolverState &state,double epsf,int maxits);
   static void       SparseSolverSolveSymmetric(CSparseSolverState &state,CSparseMatrix &a,bool IsUpper,CRowDouble &b);
   static void       SparseSolverSolve(CSparseSolverState &state,CSparseMatrix &a,CRowDouble &b);
   static void       SparseSolverResults(CSparseSolverState &state,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSolverSetXRep(CSparseSolverState &state,bool needxrep);
   static void       SparseSolverOOCStart(CSparseSolverState &state,CRowDouble &b);
   static bool       SparseSolverOOCContinue(CSparseSolverState &state);
   static void       SparseSolverOOCGetRequestInfo(CSparseSolverState &state,int &requesttype);
   static void       SparseSolverOOCGetRequestData(CSparseSolverState &state,CRowDouble &x);
   static void       SparseSolverOOCGetRequestData1(CSparseSolverState &state,double &v);
   static void       SparseSolverOOCSendResult(CSparseSolverState &state,CRowDouble &ax);
   static void       SparseSolverOOCStop(CSparseSolverState &state,CRowDouble &x,CSparseSolverReport &rep);
   static void       SparseSolverRequestTermination(CSparseSolverState &state);
   static bool       SparseSolverIteration(CSparseSolverState &state);

private:
   static void       ClearRequestFields(CSparseSolverState &state);
   static void       ClearReportFields(CSparseSolverState &state);
  };
//+------------------------------------------------------------------+
//| Solving sparse symmetric linear system A*x = b using GMRES(k)    |
//| method. Sparse symmetric A is given by its lower or upper        |
//| triangle.                                                        |
//| NOTE: use SparseSolveGMRES() to solve system with nonsymmetric A.|
//| This function provides convenience API for an 'expert' interface |
//| provided by SparseSolverState class. Use SparseSolver API if you |
//| need advanced functions like providing initial point, using      |
//| out-of-core API and so on.                                       |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse symmetric NxN matrix in any sparse storage  |
//|               format. Using CRS format is recommended because it |
//|               avoids internal conversion. An exception will be   |
//|               generated if A is not NxN matrix (where N is a size|
//|               specified during solver object creation).          |
//|   IsUpper  -  whether upper or lower triangle of A is used:      |
//|               * IsUpper = True => only upper triangle is used and|
//|                 lower triangle is not referenced at all          |
//|               * IsUpper = False => only lower triangle is used   |
//|                 and upper triangle is not referenced at all      |
//|   B        -  right part, array[N]                               |
//|   K        -  k parameter for GMRES(k), k >= 0. Zero value means |
//|               that algorithm will choose it automatically.       |
//|   EpsF     -  stopping condition, EpsF >= 0. The algorithm will  |
//|               stop when residual will decrease below EpsF* | B |.|
//|               Having EpsF = 0 means that this stopping condition |
//|               is ignored.                                        |
//|   MaxIts   -  stopping condition, MaxIts >= 0. The algorithm will|
//|               stop after performing MaxIts iterations. Zero value|
//|               means no limit.                                    |
//| NOTE: having both EpsF = 0 and MaxIts = 0 means that stopping    |
//|       criteria will be chosen automatically.                     |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], the solution                             |
//|   Rep      -  solution report:                                   |
//|               * Rep.TerminationType completion code:             |
//|                  * -5  CG method was used for a matrix which is  |
//|                        not positive definite                     |
//|                  * -4  overflow / underflow during solution (ill |
//|                        conditioned problem)                      |
//|                  * 1   || residual || <= EpsF* || b ||           |
//|                  * 5   MaxIts steps was taken                    |
//|                  * 7   rounding errors prevent further progress, |
//|                        best point found is returned              |
//|                  * 8   the algorithm was terminated  early with  |
//|                        SparseSolverRequestTermination() being    |
//|                        called from other thread.                 |
//|               * Rep.IterationsCount contains iterations count    |
//|               * Rep.NMV contains number of matrix - vector       |
//|                         calculations                             |
//|               * Rep.R2 contains squared residual                 |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolveSymmetricGMRES(CSparseMatrix &a,
                                                 bool IsUpper,
                                                 CRowDouble &b,
                                                 int k,
                                                 double epsf,
                                                 int maxits,
                                                 CRowDouble &x,
                                                 CSparseSolverReport &rep)
  {
//--- create variables
   int n=CSparse::SparseGetNRows(a);
   CSparseMatrix convbuf;
   CSparseSolverState solver;
   x.Resize(0);
//--- Test inputs
   if(!CAp::Assert(n>=1,__FUNCTION__+": tried to automatically detect N from sizeof(A),got nonpositive size"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains NAN/INF"))
      return;
   if(!CAp::Assert(MathIsValidNumber(epsf) && epsf>=0.0,__FUNCTION__+": EpsF<0 or infinite"))
      return;
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": MaxIts<0"))
      return;
   if(epsf==0.0 && maxits==0)
      epsf=1.0E-6;
//--- If A is non-CRS, perform conversion
   if(!CSparse::SparseIsCRS(a))
     {
      CSparse::SparseCopyToCRSBuf(a,convbuf);
      SparseSolveSymmetricGMRES(convbuf,IsUpper,b,k,epsf,maxits,x,rep);
      return;
     }
//--- Solve using temporary solver object
   SparseSolverCreate(n,solver);
   SparseSolverSetAlgoGMRES(solver,k);
   SparseSolverSetCond(solver,epsf,maxits);
   SparseSolverSolveSymmetric(solver,a,IsUpper,b);
   SparseSolverResults(solver,x,rep);
  }
//+------------------------------------------------------------------+
//| Solving sparse linear system A*x = b using GMRES(k) method.      |
//| This function provides convenience API for an 'expert' interface |
//| provided by SparseSolverState class. Use SparseSolver API if you |
//| need advanced functions like providing initial point, using      |
//| out-of-core API and so on.                                       |
//| INPUT PARAMETERS:                                                |
//|   A        -  sparse NxN matrix in any sparse storage format.    |
//|               Using CRS format is recommended because it avoids  |
//|               internal conversion. An exception will be generated|
//|               if A is not NxN matrix (where N is a size specified|
//|               during solver object creation).                    |
//|   B        -  right part, array[N]                               |
//|   K        -  k parameter for GMRES(k), k >= 0. Zero value means |
//|               that algorithm will choose it automatically.       |
//|   EpsF     -  stopping condition, EpsF >= 0. The algorithm will  |
//|               stop when residual will decrease below EpsF*| B |. |
//|               Having EpsF = 0 means that this stopping condition |
//|               is ignored.                                        |
//|   MaxIts   -  stopping condition, MaxIts >= 0. The algorithm will|
//|               stop after performing MaxIts iterations. Zero value|
//|               means no limit.                                    |
//| NOTE: having both EpsF = 0 and MaxIts = 0 means that stopping    |
//|       criteria will be chosen automatically.                     |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], the solution                             |
//|   Rep      -  solution report:                                   |
//|               * Rep.TerminationType completion code:             |
//|                  * -5  CG method was used for a matrix which is  |
//|                        not positive definite                     |
//|                  * -4  overflow / underflow during solution (ill |
//|                        conditioned problem)                      |
//|                  * 1   || residual || <= EpsF* || b ||           |
//|                  * 5   MaxIts steps was taken                    |
//|                  * 7   rounding errors prevent further progress, |
//|                        best point found is returned              |
//|                  * 8   the algorithm was terminated  early with  |
//|                        SparseSolverRequestTermination() being    |
//|                        called from other thread.                 |
//|               * Rep.IterationsCount contains iterations count    |
//|               * Rep.NMV contains number of matrix - vector       |
//|                        calculations                              |
//|               * Rep.R2 contains squared residual                 |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolveGMRES(CSparseMatrix &a,
                                        CRowDouble &b,
                                        int k,
                                        double epsf,
                                        int maxits,
                                        CRowDouble &x,
                                        CSparseSolverReport &rep)
  {
//--- create variables
   int n=CSparse::SparseGetNRows(a);
   CSparseMatrix convbuf;
   CSparseSolverState solver;
   x.Resize(0);
//--- Test inputs
   if(!CAp::Assert(n>=1,__FUNCTION__+": tried to automatically detect N from sizeof(A),got nonpositive size"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains NAN/INF"))
      return;
   if(!CAp::Assert(MathIsValidNumber(epsf) && epsf>=0.0,__FUNCTION__+": EpsF<0 or infinite"))
      return;
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": MaxIts<0"))
      return;

   if(epsf==0.0 && maxits==0)
      epsf=1.0E-6;
//--- If A is non-CRS, perform conversion
   if(!CSparse::SparseIsCRS(a))
     {
      CSparse::SparseCopyToCRSBuf(a,convbuf);
      SparseSolveGMRES(convbuf,b,k,epsf,maxits,x,rep);
      return;
     }
//--- Solve using temporary solver object
   SparseSolverCreate(n,solver);
   SparseSolverSetAlgoGMRES(solver,k);
   SparseSolverSetCond(solver,epsf,maxits);
   SparseSolverSolve(solver,a,b);
   SparseSolverResults(solver,x,rep);
  }
//+------------------------------------------------------------------+
//| This function initializes sparse linear iterative solver object. |
//| This solver can be used to solve nonsymmetric and symmetric      |
//| positive definite NxN(square) linear systems.                    |
//| The solver provides 'expert' API which allows advanced control   |
//| over algorithms being used, including ability to get progress    |
//| report, terminate long-running solver from other thread,         |
//| out-of-core solution and so on.                                  |
//| NOTE: there are also convenience functions that allows quick one-|
//|       line to the solvers:                                       |
//|      *  SparseSolveCG() to solve SPD linear systems              |
//|      *  SparseSolveGMRES() to solve unsymmetric linear systems.  |
//| NOTE: if you want to solve MxN(rectangular) linear problem you   |
//|       may use LinLSQR solver provided by ALGLIB.                 |
//| USAGE (A is given by the SparseMatrix structure):                |
//|   1. User initializes algorithm state with SparseSolverCreate()  |
//|      call                                                        |
//|   2. User selects algorithm with one of the SparseSolverSetAlgo??|
//|      functions. By default, GMRES(k) is used with automatically  |
//|      chosen k                                                    |
//|   3. Optionally, user tunes solver parameters, sets starting     |
//|      point, etc.                                                 |
//|   4. Depending on whether system is symmetric or not, user calls:|
//|      * SparseSolverSolveSymmetric() for a symmetric system given |
//|        by its lower or upper triangle                            |
//|      * SparseSolverSolve() for a nonsymmetric system or a        |
//|        symmetric one given by the full matrix                    |
//|   5. User calls SparseSolverResults() to get the solution        |
//| It is possible to call SparseSolverSolve???() again to solve     |
//| another task with same dimensionality but different matrix and/or|
//| right part without reinitializing SparseSolverState structure.   |
//| USAGE(out-of-core mode):                                         |
//|   1. User initializes algorithm state with SparseSolverCreate()  |
//|      call                                                        |
//|   2. User selects algorithm with one of the SparseSolverSetAlgo??|
//|      functions. By default, GMRES(k) is used with automatically  |
//|      chosen k                                                    |
//|   3. Optionally, user tunes solver parameters, sets starting     |
//|      point, etc.                                                 |
//|   4. After that user should work with out-of-core interface in a |
//|      loop like one given below:                                  |
//|      > CAlgLib::SparseSolverOOCStart(state)                      |
//|      > while CAlgLib::SparseSolverOOCContinue(state) do          |
//|      >   CAlgLib::SparseSolver))CGetRequestInfo(state,           |
//|                                                 RequestType)     |
//|      >   CAlgLib::SparseSolverOOCGetRequeStdata(state,  X)       |
//|      >   if RequestType = 0 then                                 |
//|      >     [calculate Y = A * X, with X = R ^ N]                 |
//|      >   CAlgLib:SparseSolverOOCSendResult(state, Y)             |
//|      > CAlgLib::SparseSolverOOCStop(state, X, Report)            |
//| INPUT PARAMETERS:                                                |
//|   N        -  problem dimensionality (fixed at start-up)         |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverCreate(int n,
                                          CSparseSolverState &state)
  {
//--- check
   if(!CAp::Assert(n>=1,__FUNCTION__+": N<=0"))
      return;

   state.m_n=n;
   state.m_running=false;
   state.m_userterminationneeded=false;
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_x0);
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_x);
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_ax);
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_xf);
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_b);
   CAblasF::RSetAllocV(state.m_n,0.0,state.m_wrkb);
   state.m_reply1=0.0;
   SparseSolverSetXRep(state,false);
   SparseSolverSetCond(state,0.0,0);
   SparseSolverSetAlgoGMRES(state,0);
   ClearRequestFields(state);
   ClearReportFields(state);
  }
//+------------------------------------------------------------------+
//| This function sets the solver algorithm to GMRES(k).             |
//| NOTE: if you do not need advanced functionality of the           |
//|       SparseSolver API, you may use convenience functions        |
//|       SparseSolveGMRES() and SparseSolveSymmetricGMRES().        |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//|   K        -  GMRES parameter, K >= 0:                           |
//|               * recommended values are in 10..100 range          |
//|               * larger values up to N are possible but have      |
//|                 little sense - the algorithm will be slower than |
//|                 any dense solver.                                |
//|               * values above N are truncated down to N           |
//|               * zero value means that default value is chosen.   |
//|                 This value is 50 in the current version, but it  |
//|                 may change in future ALGLIB releases.            |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSetAlgoGMRES(CSparseSolverState &state,
                                                int k)
  {
//--- check
   if(!CAp::Assert(k>=0,__FUNCTION__+": K<0"))
      return;

   state.m_algotype=0;
   if(k==0)
      k=50;
   state.m_gmresk=MathMin(k,state.m_n);
  }
//+------------------------------------------------------------------+
//| This function sets starting point.                               |
//| By default, zero starting point is used.                         |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//|   X        -  starting point, array[N]                           |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  new starting point was set                         |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSetStartingPoint(CSparseSolverState &state,
                                                    CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(state.m_n<=CAp::Len(x),__FUNCTION__+": Length(X)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(x,state.m_n),__FUNCTION__+": X contains infinite or NaN values!"))
      return;

   state.m_x0=x;
   state.m_x0.Resize(state.m_n);
  }
//+------------------------------------------------------------------+
//| This function sets stopping criteria.                            |
//| INPUT PARAMETERS:                                                |
//|   EpsF     -  algorithm will be stopped if norm of residual is   |
//|               less than EpsF* || b ||.                           |
//|   MaxIts   -  algorithm will be stopped if number of iterations  |
//|               is more than MaxIts.                               |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//| NOTES: If both EpsF and MaxIts are zero then small EpsF will be  |
//|        set to small value.                                       |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSetCond(CSparseSolverState &state,
                                           double epsf,
                                           int maxits)
  {
//--- check
   if(!CAp::Assert(MathIsValidNumber(epsf) && epsf>=0.0,__FUNCTION__+": EpsF is negative or contains infinite or NaN values"))
      return;
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": MaxIts is negative"))
      return;

   if(epsf==0.0 && maxits==0)
     {
      state.m_epsf=1.0E-6;
      state.m_maxits=0;
     }
   else
     {
      state.m_epsf=epsf;
      state.m_maxits=maxits;
     }
  }
//+------------------------------------------------------------------+
//| Procedure for the solution of A*x = b with sparse symmetric A    |
//| given by its lower or upper triangle.                            |
//| This function will work with any solver algorithm being  used,   |
//| SPD one (like CG) or not(like GMRES). Using unsymmetric solvers  |
//| (like GMRES) on SPD problems is suboptimal, but still possible.  |
//| NOTE: the solver behavior is ill-defined for a situation when a  |
//|       SPD solver is used on indefinite matrix. It may solve the  |
//|       problem up to desired precision (sometimes, rarely) or     |
//|       return with error code signalling violation of underlying  |
//|       assumptions.                                               |
//| INPUT PARAMETERS:                                                |
//|   State    -  algorithm state                                    |
//|   A        -  sparse symmetric NxN matrix in any sparse storage  |
//|               format. Using CRS format is recommended because it |
//|               avoids internal conversion. An exception will be   |
//|               generated if A is not NxN matrix (where N is a size|
//|               specified during solver object creation).          |
//|   IsUpper  -  whether upper or lower triangle of A is used:      |
//|               * IsUpper = True => only upper triangle is used and|
//|                 lower triangle is not referenced at all          |
//|               * IsUpper = False => only lower triangle is used   |
//|                 and upper triangle is not referenced at all      |
//|   B        -  right part, array[N]                               |
//| RESULT:                                                          |
//|   This function returns no result. You can get the solution by   |
//|   calling SparseSolverResults()                                  |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSolveSymmetric(CSparseSolverState &state,
                                                  CSparseMatrix &a,
                                                  bool IsUpper,
                                                  CRowDouble &b)
  {
   int n=state.m_n;
//--- Test inputs
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains NAN/INF"))
      return;
//--- If A is non-CRS, perform conversion
   if(!CSparse::SparseIsCRS(a))
     {
      CSparse::SparseCopyToCRSBuf(a,state.m_convbuf);
      SparseSolverSolveSymmetric(state,state.m_convbuf,IsUpper,b);
      return;
     }
//--- Solve using out-of-core API
   SparseSolverOOCStart(state,b);
   while(SparseSolverOOCContinue(state))
     {
      if(state.m_requesttype==-1)
        {
         //--- Skip location reports
         continue;
        }
      //--- check
      if(!CAp::Assert(state.m_requesttype==0,__FUNCTION__+": integrity check 7372 failed"))
         return;
      CSparse::SparseSMV(a,IsUpper,state.m_x,state.m_ax);
     }
  }
//+------------------------------------------------------------------+
//| Procedure for the solution of A*x = b with sparse nonsymmetric A |
//| IMPORTANT: this function will work with any solver algorithm     |
//|            being used, symmetric solver like CG, or not. However,|
//|            using symmetric solvers on nonsymmetric problems is   |
//|            dangerous. It may solve the problem up to desired     |
//|            precision (sometimes, rarely) or terminate with error |
//|            code signalling violation of underlying assumptions.  |
//| INPUT PARAMETERS:                                                |
//|   State    -  algorithm state                                    |
//|   A        -  sparse NxN matrix in any sparse storage format.    |
//|               Using CRS format is recommended because it avoids  |
//|               internal conversion. An exception will be generated|
//|               if A is not NxN matrix (where N is a size specified|
//|               during solver object creation).                    |
//|   B        -  right part, array[N]                               |
//| RESULT:                                                          |
//|   This function returns no result.                               |
//|   You can get the solution by calling SparseSolverResults()      |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSolve(CSparseSolverState &state,
                                         CSparseMatrix &a,
                                         CRowDouble &b)
  {
   int n=state.m_n;
//--- Test inputs
   if(!CAp::Assert(CSparse::SparseGetNRows(a)==n,__FUNCTION__+": rows(A)!=N"))
      return;
   if(!CAp::Assert(CSparse::SparseGetNCols(a)==n,__FUNCTION__+": cols(A)!=N"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=n,__FUNCTION__+": length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,n),__FUNCTION__+": B contains NAN/INF"))
      return;
//--- If A is non-CRS, perform conversion
   if(!CSparse::SparseIsCRS(a))
     {
      CSparse::SparseCopyToCRSBuf(a,state.m_convbuf);
      SparseSolverSolve(state,state.m_convbuf,b);
      return;
     }
//--- Solve using out-of-core API
   SparseSolverOOCStart(state,b);
   while(SparseSolverOOCContinue(state))
     {
      if(state.m_requesttype==-1)
        {
         //--- Skip location reports
         continue;
        }
      if(!CAp::Assert(state.m_requesttype==0,__FUNCTION__+": integrity check 7372 failed"))
         return;
      CSparse::SparseMV(a,state.m_x,state.m_ax);
     }
  }
//+------------------------------------------------------------------+
//| Sparse solver results.                                           |
//| This function must be called after calling one of the            |
//| SparseSolverSolve() functions.                                   |
//| INPUT PARAMETERS:                                                |
//|   State    -  algorithm state                                    |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], solution                                 |
//|   Rep      -  solution report:                                   |
//|               * Rep.TerminationType completion code:             |
//|                  * -5  CG method was used for a matrix which is  |
//|                        not positive definite                     |
//|                  * -4  overflow/underflow during solution (ill   |
//|                        conditioned problem)                      |
//|                  * 1   || residual || <= EpsF* || b ||           |
//|                  * 5   MaxIts steps was taken                    |
//|                  * 7   rounding errors prevent further progress, |
//|                        best point found is returned              |
//|                  * 8   the algorithm was terminated  early with  |
//|                        SparseSolverRequestTermination() being    |
//|                        called from other thread.                 |
//|               * Rep.IterationsCount contains iterations count    |
//|               * Rep.NMV contains number of matrix - vector       |
//|                        calculations                              |
//|               * Rep.R2 contains squared residual                 |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverResults(CSparseSolverState &state,
                                           CRowDouble &x,
                                           CSparseSolverReport &rep)
  {
   x.Resize(0);
   SparseSolverOOCStop(state,x,rep);
  }
//+------------------------------------------------------------------+
//|This function turns on/off reporting during out-of-core processing|
//| When the solver works in the out-of-core mode, it can be         |
//| configured to report its progress by returning current location. |
//| These location reports implemented as a special kind of the      |
//| out-of-core request:                                             |
//|   *  SparseSolverOOCGetRequestInfo() returns - 1                 |
//|   *  SparseSolverOOCGetRequestData() returns current location    |
//|   *  SparseSolverOOCGetRequestData1() returns squared norm of    |
//|                                       the residual               |
//|   *  SparseSolverOOCSendResult() shall NOT be called             |
//| This function has no effect when SparseSolverSolve() is used     |
//| because this function has no method of reporting its progress.   |
//| NOTE: when used with GMRES(k), this function reports progress    |
//|       every k-th iteration.                                      |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//|   NeedXRep -  whether iteration reports are needed or not        |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverSetXRep(CSparseSolverState &state,
                                           bool needxrep)
  {
   state.m_xrep=needxrep;
  }
//+------------------------------------------------------------------+
//| This function initiates out-of-core mode of the sparse solver. It|
//| should be used in conjunction with other out-of-core - related   |
//| functions of this subspackage in a loop like one given below:    |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State       -  solver object                                   |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCStart(CSparseSolverState &state,
                                            CRowDouble &b)
  {
   state.m_rstate.ia.Resize(1);
   state.m_rstate.ra.Resize(3);
   state.m_rstate.stage=-1;
   ClearRequestFields(state);
   ClearReportFields(state);
   state.m_running=true;
   state.m_userterminationneeded=false;
   CAblasF::RCopyV(state.m_n,b,state.m_b);
  }
//+------------------------------------------------------------------+
//| This function performs iterative solution of the linear system in|
//| the out-of-core mode. It should be used in conjunction with other|
//| out-of-core - related functions of this subspackage in a loop    |
//| like one given below:                                            |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State       -  solver object                                   |
//+------------------------------------------------------------------+
bool CIterativeSparse::SparseSolverOOCContinue(CSparseSolverState &state)
  {
//--- check
   if(!CAp::Assert(state.m_running,__FUNCTION__+": the solver is not running"))
      return(false);

   bool result=SparseSolverIteration(state);
   state.m_running=result;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| This function is used to retrieve information about out-of-core  |
//| request sent by the solver:                                      |
//|   * RequestType = 0 means that matrix - vector products A * x is |
//|                     requested                                    |
//|   * RequestType = -1 means that solver reports its progress; this|
//|                     request is returned only when reports are    |
//|                     activated wit SparseSolverSetXRep().         |
//| This function returns just request type; in order to get contents|
//| of the trial vector, use SparseSolverOOCGetRequestData().        |
//| It should be used in conjunction with other out-of-core - related|
//| functions of this subspackage in a loop like one given below:    |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State    -  solver running in out-of-core mode                 |
//| OUTPUT PARAMETERS:                                               |
//|   RequestType -  type of the request to process:                 |
//|                  * 0  for matrix - vector product A * x, with A  |
//|                       being NxN system matrix and X being        |
//|                       N-dimensional vector                       |
//|                  *-1  for location and residual report           |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCGetRequestInfo(CSparseSolverState &state,
                                                     int &requesttype)
  {
   requesttype=0;
//--- check
   if(!CAp::Assert(state.m_running,__FUNCTION__+": the solver is not running"))
      return;

   requesttype=state.m_requesttype;
  }
//+------------------------------------------------------------------+
//| This function is used to retrieve vector associated with         |
//| out-of-core request sent by the solver to user code. Depending on|
//| the request type(returned by the SparseSolverOOCGetRequestInfo())|
//| this vector should be multiplied by A or subjected to another    |
//| processing.                                                      |
//| It should be used in conjunction with other out-of-core - related|
//| functions of this subspackage in a loop like one given below:    |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State       -  solver running in out-of-core mode              |
//|   X           -  possibly preallocated  storage; reallocated if  |
//|                  needed, left unchanged, if large enough to store|
//|                  request data.                                   |
//| OUTPUT PARAMETERS:                                               |
//|   X           -  array[N] or larger, leading N elements are      |
//|                  filled with vector X.                           |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCGetRequestData(CSparseSolverState &state,
                                                     CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(state.m_running,__FUNCTION__+": the solver is not running"))
      return;

   x=state.m_x;
  }
//+------------------------------------------------------------------+
//| This function is used to retrieve scalar value associated with   |
//| out-of-core request sent by the solver to user code. In the      |
//| current ALGLIB version this function is used to retrieve squared |
//| residual norm during progress reports.                           |
//| INPUT PARAMETERS:                                                |
//|   State       -  solver running in out-of-core mode              |
//| OUTPUT PARAMETERS:                                               |
//|   V           -  scalar value associated with the current request|
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCGetRequestData1(CSparseSolverState &state,
                                                      double &v)
  {
   v=0;
//--- check
   if(!CAp::Assert(state.m_running,__FUNCTION__+": the solver is not running"))
      return;

   v=state.m_reply1;
  }
//+------------------------------------------------------------------+
//| This function is used to send user reply to out-of-core request  |
//| sent by the solver. Usually it is product A*x for vector X       |
//| returned by the solver.                                          |
//| It should be used in conjunction with other out-of-core - related|
//| functions of this subspackage in a loop like one given below:    |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State    -  solver running in out-of-core mode                 |
//|   AX       -  array[N] or larger, leading N elements contain A*x |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCSendResult(CSparseSolverState &state,
                                                 CRowDouble &ax)
  {
//--- check
   if(!CAp::Assert(state.m_running,__FUNCTION__+": the solver is not running"))
      return;
   if(!CAp::Assert(state.m_requesttype==0,__FUNCTION__+": this request type does not accept replies"))
      return;

   CAblasF::RCopyV(state.m_n,ax,state.m_ax);
  }
//+------------------------------------------------------------------+
//| This function finalizes out-of-core mode of the linear solver. It|
//| should be used in conjunction with other out-of-core - related   |
//| functions of this subspackage in a loop like one given below:    |
//|   >         CAlgLib::SparseSolverOOCStart(state)                 |
//|   > while   CAlgLib::SparseSolverOOCContinue(state) do           |
//|   >   CAlgLib::SparseSolverOOCGetRequestInfo(state, RequestType) |
//|   >   CAlgLib::SparseSolverOOCGetRequestData(state, out X)       |
//|   >   if RequestType = 0 then                                    |
//|   >     [calculate Y = A * X, with X = R ^ N]                    |
//|   >   CAlgLib::SparseSolverOOCSendResult(state, in Y)            |
//|   > CAlgLib::SparseSolverOOCStop(state, out X, out Report)       |
//| INPUT PARAMETERS:                                                |
//|   State    -  solver state                                       |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], the solution.                            |
//|   Zero     -  filled on the failure(Rep.TerminationType < 0).    |
//|   Rep      -  report with additional info:                       |
//|               * Rep.TerminationType completion code:             |
//|                  * -5  CG method was used for a matrix which is  |
//|                        not positive definite                     |
//|                  * -4  overflow/underflow during solution (ill   |
//|                        conditioned problem)                      |
//|                  * 1   || residual || <= EpsF* || b ||           |
//|                  * 5   MaxIts steps was taken                    |
//|                  * 7   rounding errors prevent further progress, |
//|                        best point found is returned              |
//|                  * 8   the algorithm was terminated  early with  |
//|                        SparseSolverRequestTermination() being    |
//|                        called from other thread.                 |
//|               * Rep.IterationsCount contains iterations count    |
//|               * Rep.NMV contains number of matrix - vector       |
//|                        calculations                              |
//|               * Rep.R2 contains squared residual                 |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverOOCStop(CSparseSolverState &state,
                                           CRowDouble &x,
                                           CSparseSolverReport &rep)
  {
   x.Resize(0);
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": the solver is still running"))
      return;

   x.Resize(state.m_n);
   CAblasF::RCopyV(state.m_n,state.m_xf,x);
   CDirectSparseSolvers::InitSparseSolverReport(rep);
   rep.m_iterationscount=state.m_repiterationscount;
   rep.m_nmv=state.m_repnmv;
   rep.m_terminationtype=state.m_repterminationtype;
   rep.m_r2=state.m_repr2;
  }
//+------------------------------------------------------------------+
//| This subroutine submits request for termination of the running   |
//| solver. It can be called from some other thread which wants the  |
//| solver to terminate or when processing an out-of-core request.   |
//| As result, solver stops at point which was "current accepted"    |
//| when the termination request was submitted and returns error code|
//| 8 (successful termination). Such termination is a smooth process |
//| which properly deallocates all temporaries.                      |
//| INPUT PARAMETERS:                                                |
//|   State    -  solver structure                                   |
//| NOTE: calling this function on solver which is NOT running will  |
//|       have no effect.                                            |
//| NOTE: multiple calls to this function are possible. First call is|
//|       counted, subsequent calls are silently ignored.            |
//| NOTE: solver clears termination flag on its start, it means that |
//|       if some other thread will request termination too soon, its|
//|       request will went unnoticed.                               |
//+------------------------------------------------------------------+
void CIterativeSparse::SparseSolverRequestTermination(CSparseSolverState &state)
  {
   state.m_userterminationneeded=true;
  }
//+------------------------------------------------------------------+
//| Reverse communication sparse iteration subroutine                |
//+------------------------------------------------------------------+
bool CIterativeSparse::SparseSolverIteration(CSparseSolverState &state)
  {
//--- create variables
   int    outeridx=0;
   double res=0;
   double prevres=0;
   double res0=0;
   int    label=-1;
//--- Reverse communication preparations
//--- This code initializes locals by:
//--- * random values determined during code
//---  generation - on first subroutine call
//--- * values from previous call - on subsequent calls
   if(state.m_rstate.stage>=0)
     {
      outeridx=state.m_rstate.ia[0];
      res=state.m_rstate.ra[0];
      prevres=state.m_rstate.ra[1];
      res0=state.m_rstate.ra[2];
     }
   else
     {
      outeridx=359;
      res=-58;
      prevres=-919;
      res0=-909;
     }

   switch(state.m_rstate.stage)
     {
      case 0:
         label=0;
         break;
      case 1:
         label=1;
         break;
      case 2:
         label=2;
         break;
      case 3:
         label=3;
         break;
      case 4:
         label=4;
         break;
      default:
         //--- Routine body
         state.m_running=true;
         ClearRequestFields(state);
         ClearReportFields(state);
         //--- GMRES?
         //
         if(state.m_algotype!=0)
           {
            label=5;
            break;
           }
         if(CAblasF::RDotV2(state.m_n,state.m_x0)!=0.0)
           {
            label=7;
            break;
           }
         //--- Starting point is default one (zero), quick initialization
         CAblasF::RSetV(state.m_n,0.0,state.m_xf);
         CAblasF::RCopyV(state.m_n,state.m_b,state.m_wrkb);
         label=8;
         break;
     }
//--- main loop
   while(label>=0)
     {
      switch(label)
        {
         case 7:
            //--- Non-zero starting point is provided,
            CAblasF::RCopyV(state.m_n,state.m_x0,state.m_xf);
            state.m_requesttype=0;
            CAblasF::RCopyV(state.m_n,state.m_x0,state.m_x);
            state.m_rstate.stage=0;
            label=-1;
            break;
         case 0:
            state.m_requesttype=-999;
            state.m_repnmv=state.m_repnmv+1;
            CAblasF::RCopyV(state.m_n,state.m_b,state.m_wrkb);
            CAblasF::RAddV(state.m_n,-1.0,state.m_ax,state.m_wrkb);
         case 8:
            outeridx=0;
            state.m_repterminationtype=5;
            state.m_repr2=CAblasF::RDotV2(state.m_n,state.m_wrkb);
            res0=MathSqrt(CAblasF::RDotV2(state.m_n,state.m_b));
            res=MathSqrt(state.m_repr2);
            if(!state.m_xrep)
              {
               label=9;
               break;
              }
            //--- Report initial point
            state.m_requesttype=-1;
            state.m_reply1=res*res;
            CAblasF::RCopyV(state.m_n,state.m_xf,state.m_x);
            state.m_rstate.stage=1;
            label=-1;
            break;
         case 1:
            state.m_requesttype=-999;
         case 9:
         case 11:
            if(!(res>0.0 && (state.m_maxits==0 || state.m_repiterationscount<state.m_maxits)))
              {
               label=12;
               break;
              }
            //--- Solve with GMRES(k) for current residual.
            //--- We set EpsF-based stopping condition for GMRES(k). It allows us
            //--- to quickly detect sufficient decrease in the residual. We still
            //--- have to recompute residual after the GMRES round because residuals
            //--- computed by GMRES are different from the true one (due to restarts).
            //--- However, checking residual decrease within GMRES still gives us
            //--- an opportunity to stop early without waiting for GMRES round to
            //--- complete.
            CFbls::FblsGMRESCreate(state.m_wrkb,state.m_n,state.m_gmresk,state.m_gmressolver);
            state.m_gmressolver.m_epsres=state.m_epsf*res0/res;
         case 13:
            if(!CFbls::FblsGMRESIteration(state.m_gmressolver))
              {
               label=14;
               break;
              }
            state.m_requesttype=0;
            CAblasF::RCopyV(state.m_n,state.m_gmressolver.m_x,state.m_x);
            state.m_rstate.stage=2;
            label=-1;
            break;
         case 2:
            state.m_requesttype=-999;
            CAblasF::RCopyV(state.m_n,state.m_ax,state.m_gmressolver.m_ax);
            state.m_repnmv++;
            if(state.m_userterminationneeded)
              {
               //--- User requested termination
               state.m_repterminationtype=8;
               return(false);
              }
            label=13;
            break;
         case 14:
            state.m_repiterationscount+=state.m_gmressolver.m_itsperformed;
            CAblasF::RAddV(state.m_n,1.0,state.m_gmressolver.m_xs,state.m_xf);
            //--- Update residual, evaluate residual decrease, terminate if needed
            state.m_requesttype=0;
            CAblasF::RCopyV(state.m_n,state.m_xf,state.m_x);
            state.m_rstate.stage=3;
            label=-1;
            break;
         case 3:
            state.m_requesttype=-999;
            state.m_repnmv++;
            CAblasF::RCopyV(state.m_n,state.m_b,state.m_wrkb);
            CAblasF::RAddV(state.m_n,-1.0,state.m_ax,state.m_wrkb);
            state.m_repr2=CAblasF::RDotV2(state.m_n,state.m_wrkb);
            prevres=res;
            res=MathSqrt(state.m_repr2);
            if(!state.m_xrep)
              {
               label=15;
               break;
              }
            //--- Report initial point
            state.m_requesttype=-1;
            state.m_reply1=res*res;
            CAblasF::RCopyV(state.m_n,state.m_xf,state.m_x);
            state.m_rstate.stage=4;
            label=-1;
            break;
         case 4:
            state.m_requesttype=-999;
         case 15:
            if(res<=(state.m_epsf*res0))
              {
               //--- Residual decrease condition met, stopping
               state.m_repterminationtype=1;
               label=12;
               break;
              }
            if(res>=(prevres*(1-MathSqrt(CMath::m_machineepsilon))))
              {
               //--- The algorithm stagnated
               state.m_repterminationtype=7;
               label=12;
               break;
              }
            if(state.m_userterminationneeded)
              {
               //--- User requested termination
               state.m_repterminationtype=8;
               return(false);
              }
            outeridx++;
            label=11;
            break;
         case 12:
            return(false);
         case 5:
            CAp::Assert(false,__FUNCTION__+": integrity check failed (unexpected algo)");
            return(false);
        }
     }
//--- Saving state
   state.m_rstate.ia.Set(0,outeridx);
   state.m_rstate.ra.Set(0,res);
   state.m_rstate.ra.Set(1,prevres);
   state.m_rstate.ra.Set(2,res0);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Clears request fileds (to be sure that we don't forgot to clear  |
//| something)                                                       |
//+------------------------------------------------------------------+
void CIterativeSparse::ClearRequestFields(CSparseSolverState &state)
  {
   state.m_requesttype=-999;
  }
//+------------------------------------------------------------------+
//| Clears report fileds (to be sure that we don't forgot to clear   |
//| something)                                                       |
//+------------------------------------------------------------------+
void CIterativeSparse::ClearReportFields(CSparseSolverState &state)
  {
   state.m_repiterationscount=0;
   state.m_repnmv=0;
   state.m_repterminationtype=0;
   state.m_repr2=0;
  }
//+------------------------------------------------------------------+
//| This object stores state of the linear CG method.                |
//| You should use ALGLIB functions to work with this object.        |
//| Never try to access its fields directly!                         |
//+------------------------------------------------------------------+
struct CLinCGState
  {
   int               m_itsbeforerestart;
   int               m_itsbeforerupdate;
   int               m_maxits;
   int               m_n;
   int               m_prectype;
   int               m_repiterationscount;
   int               m_repnmv;
   int               m_repterminationtype;
   double            m_alpha;
   double            m_beta;
   double            m_epsf;
   double            m_meritfunction;
   double            m_r2;
   double            m_vmv;
   bool              m_needmtv;
   bool              m_needmv2;
   bool              m_needmv;
   bool              m_needprec;
   bool              m_needvmv;
   bool              m_running;
   bool              m_xrep;
   bool              m_xupdated;
   RCommState        m_rstate;
   CRowDouble        m_b;
   CRowDouble        m_cr;
   CRowDouble        m_cx;
   CRowDouble        m_cz;
   CRowDouble        m_mv;
   CRowDouble        m_p;
   CRowDouble        m_pv;
   CRowDouble        m_r;
   CRowDouble        m_rx;
   CRowDouble        m_startx;
   CRowDouble        m_tmpd;
   CRowDouble        m_x;
   CRowDouble        m_z;
   //--- constructor / destructor
                     CLinCGState(void);
                    ~CLinCGState(void) {}
   //---
   void              Copy(const CLinCGState &obj);
   //--- overloading
   void              operator=(const CLinCGState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLinCGState::CLinCGState(void)
  {
   m_itsbeforerestart=0;
   m_itsbeforerupdate=0;
   m_maxits=0;
   m_n=0;
   m_prectype=0;
   m_repiterationscount=0;
   m_repnmv=0;
   m_repterminationtype=0;
   m_alpha=0;
   m_beta=0;
   m_epsf=0;
   m_meritfunction=0;
   m_r2=0;
   m_vmv=0;
   m_needmtv=false;
   m_needmv2=false;
   m_needmv=false;
   m_needprec=false;
   m_needvmv=false;
   m_running=false;
   m_xrep=false;
   m_xupdated=false;
  }
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CLinCGState::Copy(const CLinCGState &obj)
  {
   m_itsbeforerestart=obj.m_itsbeforerestart;
   m_itsbeforerupdate=obj.m_itsbeforerupdate;
   m_maxits=obj.m_maxits;
   m_n=obj.m_n;
   m_prectype=obj.m_prectype;
   m_repiterationscount=obj.m_repiterationscount;
   m_repnmv=obj.m_repnmv;
   m_repterminationtype=obj.m_repterminationtype;
   m_alpha=obj.m_alpha;
   m_beta=obj.m_beta;
   m_epsf=obj.m_epsf;
   m_meritfunction=obj.m_meritfunction;
   m_r2=obj.m_r2;
   m_vmv=obj.m_vmv;
   m_needmtv=obj.m_needmtv;
   m_needmv2=obj.m_needmv2;
   m_needmv=obj.m_needmv;
   m_needprec=obj.m_needprec;
   m_needvmv=obj.m_needvmv;
   m_running=obj.m_running;
   m_xrep=obj.m_xrep;
   m_xupdated=obj.m_xupdated;
   m_rstate=obj.m_rstate;
   m_b=obj.m_b;
   m_cr=obj.m_cr;
   m_cx=obj.m_cx;
   m_cz=obj.m_cz;
   m_mv=obj.m_mv;
   m_p=obj.m_p;
   m_pv=obj.m_pv;
   m_r=obj.m_r;
   m_rx=obj.m_rx;
   m_startx=obj.m_startx;
   m_tmpd=obj.m_tmpd;
   m_x=obj.m_x;
   m_z=obj.m_z;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct CLinCGReport
  {
   int               m_iterationscount;
   int               m_nmv;
   int               m_terminationtype;
   double            m_r2;
   //--- constructor / destructor
                     CLinCGReport(void) { ZeroMemory(this); }
                    ~CLinCGReport(void) {}
   //---
   void              Copy(const CLinCGReport &obj);
   //--- overloading
   void              operator=(const CLinCGReport &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CLinCGReport::Copy(const CLinCGReport &obj)
  {
   m_iterationscount=obj.m_iterationscount;
   m_nmv=obj.m_nmv;
   m_terminationtype=obj.m_terminationtype;
   m_r2=obj.m_r2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLinCG
  {
public:
   //--- constants
   static const double m_defaultprecision;

   static void       LinCGCreate(int n,CLinCGState &state);
   static void       LinCGSetStartingPoint(CLinCGState &state,CRowDouble &x);
   static void       LinCGSetB(CLinCGState &state,CRowDouble &b);
   static void       LinCGSetPrecUnit(CLinCGState &state);
   static void       LinCGSetPrecDiag(CLinCGState &state);
   static void       LinCGSetCond(CLinCGState &state,double epsf,int maxits);
   static bool       LinCGIteration(CLinCGState &state);
   static void       LinCGSolveSparse(CLinCGState &state,CSparseMatrix &a,bool IsUpper,CRowDouble &b);
   static void       LinCGResult(CLinCGState &state,CRowDouble &x,CLinCGReport &rep);
   static void       LinCGSetRestartFreq(CLinCGState &state,int srf);
   static void       LinCGSetRUpdateFreq(CLinCGState &state,int freq);
   static void       LinCGSetXRep(CLinCGState &state,bool needxrep);
   static void       LinCGRestart(CLinCGState &state);

private:
   static void       ClearrFields(CLinCGState &state);
   static void       UpdateItersData(CLinCGState &state);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double CLinCG::m_defaultprecision=1.0E-6;
//+------------------------------------------------------------------+
//| This function initializes linear CG Solver. This solver is used  |
//| to solve symmetric positive definite problems. If you want to    |
//| solve nonsymmetric (or non-positive definite) problem you may use|
//| LinLSQR solver provided by ALGLIB.                               |
//| USAGE:                                                           |
//|   1. User initializes algorithm state with LinCGCreate() call    |
//|   2. User tunes solver parameters with LinCGSetCond() and other  |
//|      functions                                                   |
//|   3. Optionally, user sets starting point with                   |
//|      LinCGSetStartingPoint()                                     |
//|   4. User calls LinCGSolveSparse() function which takes algorithm|
//|      state and SparseMatrix object.                              |
//|   5. User calls LinCGResults() to get solution                   |
//|   6. Optionally, user may call LinCGSolveSparse() again to solve |
//|      another problem with different matrix and/or right part     |
//|      without reinitializing LinCGState structure.                |
//| INPUT PARAMETERS:                                                |
//|   N        -  problem dimension, N > 0                           |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinCG::LinCGCreate(int n,CLinCGState &state)
  {
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;

   state.m_n=n;
   state.m_prectype=0;
   state.m_itsbeforerestart=n;
   state.m_itsbeforerupdate=10;
   state.m_epsf=m_defaultprecision;
   state.m_maxits=0;
   state.m_xrep=false;
   state.m_running=false;
//--- * allocate arrays
//--- * set RX to NAN (just for the case user calls Results() without
//---  calling SolveSparse()
//--- * set starting point to zero
//--- * we do NOT initialize B here because we assume that user should
//---  initializate it using LinCGSetB() function. In case he forgets
//---  to do so, exception will be thrown in the LinCGIteration().
   state.m_rx=vector<double>::Full(state.m_n,AL_NaN);
   state.m_startx=vector<double>::Zeros(state.m_n);
   state.m_b=vector<double>::Zeros(state.m_n);
   state.m_cx=vector<double>::Zeros(state.m_n);
   state.m_p=vector<double>::Zeros(state.m_n);
   state.m_r=vector<double>::Zeros(state.m_n);
   state.m_cr=vector<double>::Zeros(state.m_n);
   state.m_z=vector<double>::Zeros(state.m_n);
   state.m_cz=vector<double>::Zeros(state.m_n);
   state.m_x=vector<double>::Zeros(state.m_n);
   state.m_mv=vector<double>::Zeros(state.m_n);
   state.m_pv=vector<double>::Zeros(state.m_n);
   UpdateItersData(state);
   state.m_rstate.ia.Resize(1);
   state.m_rstate.ra=vector<double>::Zeros(3);
   state.m_rstate.stage=-1;
  }
//+------------------------------------------------------------------+
//| This function sets starting point.                               |
//| By default, zero starting point is used.                         |
//| INPUT PARAMETERS:                                                |
//|   X        -  starting point, array[N]                           |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetStartingPoint(CLinCGState &state,
                                   CRowDouble &x)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change starting point because LinCGIteration() function is running"))
      return;
   if(!CAp::Assert(state.m_n<=CAp::Len(x),__FUNCTION__+": Length(X)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(x,state.m_n),__FUNCTION__+": X contains infinite or NaN values!"))
      return;
//--- copy
   state.m_startx=x;
   state.m_startx.Resize(state.m_n);
  }
//+------------------------------------------------------------------+
//| This function sets right part. By default, right part is zero.   |
//| INPUT PARAMETERS:                                                |
//|   B        -  right part, array[N].                              |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetB(CLinCGState &state,CRowDouble &b)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not set B,because function LinCGIteration is running!"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=state.m_n,__FUNCTION__+": Length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,state.m_n),__FUNCTION__+": B contains infinite or NaN values!"))
      return;
//--- copy
   state.m_b=b;
   state.m_b.Resize(state.m_n);
  }
//+------------------------------------------------------------------+
//| This function changes preconditioning settings of                |
//| LinCGSolveSparse() function. By default, SolveSparse() uses      |
//| diagonal preconditioner, but if you want to use solver without   |
//| preconditioning, you can call this function which forces solver  |
//| to use unit matrix for preconditioning.                          |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetPrecUnit(CLinCGState &state)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change preconditioner,because function LinCGIteration is running!"))
      return;

   state.m_prectype=-1;
  }
//+------------------------------------------------------------------+
//| This function changes preconditioning settings of                |
//| LinCGSolveSparse() function. LinCGSolveSparse() will use diagonal|
//| of the system matrix as preconditioner. This preconditioning mode|
//| is active by default.                                            |
//| INPUT PARAMETERS:                                                |
//|   State       -  structure which stores algorithm state          |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetPrecDiag(CLinCGState &state)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change preconditioner,because function LinCGIteration is running!"))
      return;

   state.m_prectype=0;
  }
//+------------------------------------------------------------------+
//| This function sets stopping criteria.                            |
//| INPUT PARAMETERS:                                                |
//|   EpsF     -  algorithm will be stopped if norm of residual is   |
//|               less than EpsF* || b ||.                           |
//|   MaxIts   -  algorithm will be stopped if number of iterations  |
//|               is more than MaxIts.                               |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//| NOTES: If both EpsF and MaxIts are zero then small EpsF will be  |
//|        set to small value.                                       |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetCond(CLinCGState &state,double epsf,int maxits)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change stopping criteria when LinCGIteration() is running"))
      return;
   if(!CAp::Assert(MathIsValidNumber(epsf) && epsf>=0.0,__FUNCTION__+": EpsF is negative or contains infinite or NaN values"))
      return;
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": MaxIts is negative"))
      return;

   if(epsf==0.0 && maxits==0)
     {
      state.m_epsf=m_defaultprecision;
      state.m_maxits=maxits;
     }
   else
     {
      state.m_epsf=epsf;
      state.m_maxits=maxits;
     }
  }
//+------------------------------------------------------------------+
//| Reverse communication version of linear CG.                      |
//+------------------------------------------------------------------+
bool CLinCG::LinCGIteration(CLinCGState &state)
  {
//--- create variables
   int    i=0;
   double uvar=0;
   double bnorm=0;
   double v=0;
   int    label=-1;
//--- Reverse communication preparations
//--- This code initializes locals by:
//--- * random values determined during code
//---  generation - on first subroutine call
//--- * values from previous call - on subsequent calls
//
   if(state.m_rstate.stage>=0)
     {
      i=state.m_rstate.ia[0];
      uvar=state.m_rstate.ra[0];
      bnorm=state.m_rstate.ra[1];
      v=state.m_rstate.ra[2];
     }
   else
     {
      i=359;
      uvar=-58;
      bnorm=-919;
      v=-909;
     }

   switch(state.m_rstate.stage)
     {
      case 0:
         label=0;
         break;
      case 1:
         label=1;
         break;
      case 2:
         label=2;
         break;
      case 3:
         label=3;
         break;
      case 4:
         label=4;
         break;
      case 5:
         label=5;
         break;
      case 6:
         label=6;
         break;
      case 7:
         label=7;
         break;
      default:
         //--- Routine body
         //--- check
         if(!CAp::Assert(CAp::Len(state.m_b)>0,__FUNCTION__+": B is not initialized (you must initialize B by LinCGSetB() call"))
            return(false);
         state.m_running=true;
         state.m_repnmv=0;
         ClearrFields(state);
         UpdateItersData(state);
         //--- Start 0-th iteration
         state.m_rx=state.m_startx;
         state.m_x=state.m_rx;
         state.m_repnmv++;
         ClearrFields(state);
         state.m_needvmv=true;
         state.m_rstate.stage=0;
         label=-1;
         break;
     }
//--- main loop
   while(label>=0)
     {
      switch(label)
        {
         case 0:
            state.m_needvmv=false;
            bnorm=0;
            state.m_r2=0;
            state.m_meritfunction=0;
            state.m_r=state.m_b-state.m_mv+0;
            state.m_r2=state.m_r.Dot(state.m_r);
            state.m_meritfunction= state.m_mv.Dot(state.m_rx)-2*state.m_b.Dot(state.m_rx);
            bnorm=state.m_b.Dot(state.m_b);
            bnorm=MathSqrt(bnorm);
            //--- Output first report
            if(!state.m_xrep)
              {
               label=8;
               break;
              }
            state.m_x=state.m_rx;
            ClearrFields(state);
            state.m_xupdated=true;
            state.m_rstate.stage=1;
            label=-1;
            break;
         case 1:
            state.m_xupdated=false;
         case 8:
            //--- Is x0 a solution?
            if(!MathIsValidNumber(state.m_r2) || MathSqrt(state.m_r2)<=(state.m_epsf*bnorm))
              {
               state.m_running=false;
               if(MathIsValidNumber(state.m_r2))
                  state.m_repterminationtype=1;
               else
                  state.m_repterminationtype=-4;
               return(false);
              }
            //--- Calculate Z and P
            state.m_x=state.m_r;
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needprec=true;
            state.m_rstate.stage=2;
            label=-1;
            break;
         case 2:
            state.m_needprec=false;
            state.m_z=state.m_pv;
            state.m_p=state.m_z;
            //--- Other iterations(1..N)
            state.m_repiterationscount=0;
         case 10:
            state.m_repiterationscount++;
            //--- Calculate Alpha
            state.m_x=state.m_p;
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needvmv=true;
            state.m_rstate.stage=3;
            label=-1;
            break;
         case 3:
            state.m_needvmv=false;
            if(!MathIsValidNumber(state.m_vmv) || state.m_vmv<=0.0)
              {
               //--- a) Overflow when calculating VMV
               //--- b) non-positive VMV (non-SPD matrix)
               state.m_running=false;
               if(MathIsValidNumber(state.m_vmv))
                  state.m_repterminationtype=-5;
               else
                  state.m_repterminationtype=-4;
               return(false);
              }
            state.m_alpha=state.m_r.Dot(state.m_z);
            state.m_alpha=state.m_alpha/state.m_vmv;
            if(!MathIsValidNumber(state.m_alpha))
              {
               //--- Overflow when calculating Alpha
               state.m_running=false;
               state.m_repterminationtype=-4;
               return(false);
              }
            //--- Next step toward solution
            state.m_cx=state.m_rx.ToVector()+state.m_p*state.m_alpha;
            //--- Calculate R:
            //--- * use recurrent relation to update R
            //--- * at every ItsBeforeRUpdate-th iteration recalculate it from scratch, using matrix-vector product
            //---  in case R grows instead of decreasing, algorithm is terminated with positive completion code
            if(!(state.m_itsbeforerupdate==0 || state.m_repiterationscount%state.m_itsbeforerupdate!=0))
              {
               label=12;
               break;
              }
            //--- Calculate R using recurrent formula
            state.m_cr=state.m_r.ToVector()-state.m_mv*state.m_alpha;
            state.m_x=state.m_cr;
            label=13;
            break;
         case 12:
            //--- Calculate R using matrix-vector multiplication
            state.m_x=state.m_cx;
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needmv=true;
            state.m_rstate.stage=4;
            label=-1;
            break;
         case 4:
            state.m_needmv=false;
            state.m_cr=state.m_b-state.m_mv+0;
            state.m_x=state.m_cr;
            //--- Calculating merit function
            //--- Check emergency stopping criterion
            v=state.m_mv.Dot(state.m_cx)-2*state.m_b.Dot(state.m_cx);
            if(v<state.m_meritfunction)
              {
               label=14;
               break;
              }
            if(!CApServ::IsFiniteVector(state.m_rx,state.m_n))
              {
               state.m_running=false;
               state.m_repterminationtype=-4;
               return(false);
              }
            //output last report
            if(!state.m_xrep)
              {
               label=16;
               break;
              }
            state.m_x=state.m_rx;
            ClearrFields(state);
            state.m_xupdated=true;
            state.m_rstate.stage=5;
            label=-1;
            break;
         case 5:
            state.m_xupdated=false;
         case 16:
            state.m_running=false;
            state.m_repterminationtype=7;
            return(false);
         case 14:
            state.m_meritfunction=v;
         case 13:
            state.m_rx=state.m_cx;
            //--- calculating RNorm
            //--- NOTE: monotonic decrease of R2 is not guaranteed by algorithm.
            state.m_r2=state.m_cr.Dot(state.m_cr);
            //output report
            if(!state.m_xrep)
              {
               label=18;
               break;
              }
            state.m_x=state.m_rx;
            ClearrFields(state);
            state.m_xupdated=true;
            state.m_rstate.stage=6;
            label=-1;
            break;
         case 6:
            state.m_xupdated=false;
         case 18:
            //stopping criterion
            //achieved the required precision
            if(!MathIsValidNumber(state.m_r2) || (MathSqrt(state.m_r2)<=(state.m_epsf*bnorm)))
              {
               state.m_running=false;
               if(MathIsValidNumber(state.m_r2))
                  state.m_repterminationtype=1;
               else
                  state.m_repterminationtype=-4;
               return(false);
              }
            if(state.m_repiterationscount>=state.m_maxits && state.m_maxits>0)
              {
               if(!CApServ::IsFiniteVector(state.m_rx,state.m_n))
                 {
                  state.m_running=false;
                  state.m_repterminationtype=-4;
                  return(false);
                 }
               //if X is finite number
               state.m_running=false;
               state.m_repterminationtype=5;
               return(false);
              }
            state.m_x=state.m_cr;
            //prepere of parameters for next iteration
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needprec=true;
            state.m_rstate.stage=7;
            label=-1;
            break;
         case 7:
            state.m_needprec=false;
            state.m_cz=state.m_pv;
            if(state.m_repiterationscount%state.m_itsbeforerestart!=0)
              {
               state.m_beta=state.m_cz.Dot(state.m_cr);
               uvar=state.m_z.Dot(state.m_r);
               //check that UVar is't INF or is't zero
               if(!MathIsValidNumber(uvar) || uvar==0.0)
                 {
                  state.m_running=false;
                  state.m_repterminationtype=-4;
                  return(false);
                 }
               //calculate .BETA
               state.m_beta/=uvar;
               //check that .BETA neither INF nor NaN
               if(!MathIsValidNumber(state.m_beta))
                 {
                  state.m_running=false;
                  state.m_repterminationtype=-1;
                  return(false);
                 }
               state.m_p=state.m_cz.ToVector()+state.m_p*state.m_beta;
              }
            else
               state.m_p=state.m_cz;
            //prepere data for next iteration
            //write (k+1)th iteration to (k )th iteration
            state.m_r=state.m_cr;
            state.m_z=state.m_cz;
            label=10;
            break;
         case 11:
            return(false);
        }
     }
//--- Saving state
   state.m_rstate.ia.Set(0,i);
   state.m_rstate.ra.Set(0,uvar);
   state.m_rstate.ra.Set(1,bnorm);
   state.m_rstate.ra.Set(2,v);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Procedure for solution of A*x = b with sparse A.                 |
//| INPUT PARAMETERS:                                                |
//|   State       -  algorithm state                                 |
//|   A           -  sparse matrix in the CRS format (you MUST       |
//|                  contvert it to CRS format by calling            |
//|                  SparseConvertToCRS() function).                 |
//|   IsUpper     -  whether upper or lower triangle of A is used:   |
//|                  * IsUpper = True => only upper triangle is used |
//|                                      and lower triangle is not   |
//|                                      referenced at all           |
//|                  * IsUpper = False => only lower triangle is used|
//|                                      and upper triangle is not   |
//|                                      referenced at all           |
//|   B           -  right part, array[N]                            |
//| RESULT:                                                          |
//|   This function returns no result.                               |
//|   You can get solution by calling LinCGResults()                 |
//| NOTE: this function uses lightweight preconditioning -           |
//|       multiplication by inverse of diag(A). If you want, you can |
//|       turn preconditioning off by calling LinCGSetPrecUnit().    |
//|       However, preconditioning cost is low and preconditioner is |
//|       very important for solution of badly scaled problems.      |
//+------------------------------------------------------------------+
void CLinCG::LinCGSolveSparse(CLinCGState &state,CSparseMatrix &a,
                              bool IsUpper,CRowDouble &b)
  {
//--- create variables
   int    n=state.m_n;
   double v=0;
   double vmv=0;
//--- check
   if(!CAp::Assert(CAp::Len(b)>=state.m_n,__FUNCTION__+": Length(B)<N"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,state.m_n),__FUNCTION__+": B contains infinite or NaN values!"))
      return;
//--- Allocate temporaries
   state.m_tmpd.Resize(n);
//--- Compute diagonal scaling matrix D
   if(state.m_prectype==0)
     {
      //--- Default preconditioner - inverse of matrix diagonal
      for(int i=0; i<n; i++)
        {
         v=CSparse::SparseGetDiagonal(a,i);
         if(v>0.0)
            state.m_tmpd.Set(i,1/MathSqrt(v));
         else
            state.m_tmpd.Set(i,1);
        }
     }
   else
     {
      //--- No diagonal scaling
      state.m_tmpd.Fill(1);
     }
//--- Solve
   LinCGRestart(state);
   LinCGSetB(state,b);
   while(LinCGIteration(state))
     {
      //--- Process different requests from optimizer
      if(state.m_needmv)
         CSparse::SparseSMV(a,IsUpper,state.m_x,state.m_mv);
      if(state.m_needvmv)
        {
         CSparse::SparseSMV(a,IsUpper,state.m_x,state.m_mv);
         vmv=state.m_x.Dot(state.m_mv);
         state.m_vmv=vmv;
        }
      if(state.m_needprec)
         state.m_pv=state.m_x.ToVector()*state.m_tmpd.Pow(2);
     }
  }
//+------------------------------------------------------------------+
//| CG - solver: results.                                            |
//| This function must be called after LinCGSolve                    |
//| INPUT PARAMETERS:                                                |
//|   State       -  algorithm state                                 |
//| OUTPUT PARAMETERS:                                               |
//|   X           -  array[N], solution                              |
//|   Rep         -  optimization report:                            |
//|                  * Rep.TerminationType completetion code:        |
//|                     * -5  input matrix is either not positive    |
//|                           definite, too large or too small       |
//|                     * -4  overflow / underflow during solution   |
//|                           (ill conditioned problem)              |
//|                     * 1   || residual || <= EpsF* || b ||        |
//|                     * 5   MaxIts steps was taken                 |
//|                     * 7   rounding errors prevent further        |
//|                           progress, best point found is returned |
//|                  * Rep.IterationsCount contains iterations count |
//|                  * NMV countains number of matrix - vector       |
//|                           calculations                           |
//+------------------------------------------------------------------+
void CLinCG::LinCGResult(CLinCGState &state,CRowDouble &x,
                         CLinCGReport &rep)
  {
   x.Resize(0);
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not get result,because function LinCGIteration has been launched!"))
      return;

   if(CAp::Len(x)<state.m_n)
      x.Resize(state.m_n);
   x=state.m_rx;
   rep.m_iterationscount=state.m_repiterationscount;
   rep.m_nmv=state.m_repnmv;
   rep.m_terminationtype=state.m_repterminationtype;
   rep.m_r2=state.m_r2;
  }
//+------------------------------------------------------------------+
//| This function sets restart frequency. By default, algorithm is   |
//| restarted after N subsequent iterations.                         |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetRestartFreq(CLinCGState &state,int srf)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change restart frequency when LinCGIteration() is running"))
      return;
   if(!CAp::Assert(srf>0,__FUNCTION__+": non-positive SRF"))
      return;

   state.m_itsbeforerestart=srf;
  }
//+------------------------------------------------------------------+
//| This function sets frequency of residual recalculations.         |
//| Algorithm updates residual r_k using iterative formula, but      |
//| recalculates it from scratch after each 10 iterations. It is done|
//| to avoid accumulation of numerical errors and to stop algorithm  |
//| when r_k starts to grow.                                         |
//| Such low update  frequence(1 / 10) gives very little overhead,   |
//| but makes algorithm a bit more robust against numerical errors.  |
//| However, you may change it                                       |
//| INPUT PARAMETERS:                                                |
//|   Freq        -  desired update frequency, Freq >= 0.            |
//| Zero value means that no updates will be done.                   |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetRUpdateFreq(CLinCGState &state,int freq)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change update frequency when LinCGIteration() is running"))
      return;
   if(!CAp::Assert(freq>=0,__FUNCTION__+": non-positive Freq"))
      return;

   state.m_itsbeforerupdate=freq;
  }
//+------------------------------------------------------------------+
//| This function turns on / off reporting.                          |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//|   NeedXRep -  whether iteration reports are needed or not        |
//| If NeedXRep is True, algorithm will call rep() callback function |
//| if it is provided to MinCGOptimize().                            |
//+------------------------------------------------------------------+
void CLinCG::LinCGSetXRep(CLinCGState &state,bool needxrep)
  {
   state.m_xrep=needxrep;
  }
//+------------------------------------------------------------------+
//| Procedure for restart function LinCGIteration                    |
//+------------------------------------------------------------------+
void CLinCG::LinCGRestart(CLinCGState &state)
  {
   state.m_rstate.ia.Resize(1);
   state.m_rstate.ra.Resize(3);
   state.m_rstate.stage=-1;
   ClearrFields(state);
  }
//+------------------------------------------------------------------+
//| Clears request fileds (to be sure that we don't forgot to clear  |
//| something)                                                       |
//+------------------------------------------------------------------+
void CLinCG::ClearrFields(CLinCGState &state)
  {
   state.m_xupdated=false;
   state.m_needmv=false;
   state.m_needmtv=false;
   state.m_needmv2=false;
   state.m_needvmv=false;
   state.m_needprec=false;
  }
//+------------------------------------------------------------------+
//| Clears request fileds (to be sure that we don't forgot to clear  |
//| something)                                                       |
//+------------------------------------------------------------------+
void CLinCG::UpdateItersData(CLinCGState &state)
  {
   state.m_repiterationscount=0;
   state.m_repnmv=0;
   state.m_repterminationtype=0;
  }
//+------------------------------------------------------------------+
//| This object stores state of the LinLSQR method.                  |
//| You should use ALGLIB functions to work with this object.        |
//+------------------------------------------------------------------+
struct CLinLSQRState
  {
   int               m_m;
   int               m_maxits;
   int               m_n;
   int               m_prectype;
   int               m_repiterationscount;
   int               m_repnmv;
   int               m_repterminationtype;
   double            m_alphai;
   double            m_alphaip1;
   double            m_anorm;
   double            m_betai;
   double            m_betaip1;
   double            m_bnorm2;
   double            m_ci;
   double            m_dnorm;
   double            m_epsa;
   double            m_epsb;
   double            m_epsc;
   double            m_lambdai;
   double            m_phibari;
   double            m_phibarip1;
   double            m_phii;
   double            m_r2;
   double            m_rhobari;
   double            m_rhobarip1;
   double            m_rhoi;
   double            m_si;
   double            m_theta;
   bool              m_needmtv;
   bool              m_needmv2;
   bool              m_needmv;
   bool              m_needprec;
   bool              m_needvmv;
   bool              m_running;
   bool              m_userterminationneeded;
   bool              m_xrep;
   bool              m_xupdated;
   RCommState        m_rstate;
   CRowDouble        m_b;
   CRowDouble        m_d;
   CRowDouble        m_mtv;
   CRowDouble        m_mv;
   CRowDouble        m_omegai;
   CRowDouble        m_omegaip1;
   CRowDouble        m_rx;
   CRowDouble        m_tmpd;
   CRowDouble        m_tmpx;
   CRowDouble        m_ui;
   CRowDouble        m_uip1;
   CRowDouble        m_vi;
   CRowDouble        m_vip1;
   CRowDouble        m_x;
   CNormEstimatorState m_nes;
   //--- constructor / destructor
                     CLinLSQRState(void);
                    ~CLinLSQRState(void) {}
   //---
   void              Copy(const CLinLSQRState &obj);
   //--- overloading
   void              operator=(const CLinLSQRState &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLinLSQRState::CLinLSQRState(void)
  {
   m_m=0;
   m_maxits=0;
   m_n=0;
   m_prectype=0;
   m_repiterationscount=0;
   m_repnmv=0;
   m_repterminationtype=0;
   m_alphai=0;
   m_alphaip1=0;
   m_anorm=0;
   m_betai=0;
   m_betaip1=0;
   m_bnorm2=0;
   m_ci=0;
   m_dnorm=0;
   m_epsa=0;
   m_epsb=0;
   m_epsc=0;
   m_lambdai=0;
   m_phibari=0;
   m_phibarip1=0;
   m_phii=0;
   m_r2=0;
   m_rhobari=0;
   m_rhobarip1=0;
   m_rhoi=0;
   m_si=0;
   m_theta=0;
   m_needmtv=false;
   m_needmv2=false;
   m_needmv=false;
   m_needprec=false;
   m_needvmv=false;
   m_running=false;
   m_userterminationneeded=false;
   m_xrep=false;
   m_xupdated=false;
  }
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CLinLSQRState::Copy(const CLinLSQRState &obj)
  {
   m_m=obj.m_m;
   m_maxits=obj.m_maxits;
   m_n=obj.m_n;
   m_prectype=obj.m_prectype;
   m_repiterationscount=obj.m_repiterationscount;
   m_repnmv=obj.m_repnmv;
   m_repterminationtype=obj.m_repterminationtype;
   m_alphai=obj.m_alphai;
   m_alphaip1=obj.m_alphaip1;
   m_anorm=obj.m_anorm;
   m_betai=obj.m_betai;
   m_betaip1=obj.m_betaip1;
   m_bnorm2=obj.m_bnorm2;
   m_ci=obj.m_ci;
   m_dnorm=obj.m_dnorm;
   m_epsa=obj.m_epsa;
   m_epsb=obj.m_epsb;
   m_epsc=obj.m_epsc;
   m_lambdai=obj.m_lambdai;
   m_phibari=obj.m_phibari;
   m_phibarip1=obj.m_phibarip1;
   m_phii=obj.m_phii;
   m_r2=obj.m_r2;
   m_rhobari=obj.m_rhobari;
   m_rhobarip1=obj.m_rhobarip1;
   m_rhoi=obj.m_rhoi;
   m_si=obj.m_si;
   m_theta=obj.m_theta;
   m_needmtv=obj.m_needmtv;
   m_needmv2=obj.m_needmv2;
   m_needmv=obj.m_needmv;
   m_needprec=obj.m_needprec;
   m_needvmv=obj.m_needvmv;
   m_running=obj.m_running;
   m_userterminationneeded=obj.m_userterminationneeded;
   m_xrep=obj.m_xrep;
   m_xupdated=obj.m_xupdated;
   m_rstate=obj.m_rstate;
   m_b=obj.m_b;
   m_d=obj.m_d;
   m_mtv=obj.m_mtv;
   m_mv=obj.m_mv;
   m_omegai=obj.m_omegai;
   m_omegaip1=obj.m_omegaip1;
   m_rx=obj.m_rx;
   m_tmpd=obj.m_tmpd;
   m_tmpx=obj.m_tmpx;
   m_ui=obj.m_ui;
   m_uip1=obj.m_uip1;
   m_vi=obj.m_vi;
   m_vip1=obj.m_vip1;
   m_x=obj.m_x;
   m_nes=obj.m_nes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct CLinLSQRReport
  {
   int               m_iterationscount;
   int               m_nmv;
   int               m_terminationtype;
   //--- constructor / destructor
                     CLinLSQRReport(void) { ZeroMemory(this); }
                    ~CLinLSQRReport(void) {}
   //---
   void              Copy(const CLinLSQRReport &obj);
   //--- overloading
   void              operator=(const CLinLSQRReport &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CLinLSQRReport::Copy(const CLinLSQRReport &obj)
  {
   m_iterationscount=obj.m_iterationscount;
   m_nmv=obj.m_nmv;
   m_terminationtype=obj.m_terminationtype;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLinLSQR
  {
public:
   //--- constants
   static const double m_atol;
   static const double m_btol;

   static void       LinLSQRCreate(int m,int n,CLinLSQRState &state);
   static void       LinLSQRCreateBuf(int m,int n,CLinLSQRState &state);
   static void       LinLSQRSetB(CLinLSQRState &state,CRowDouble &b);
   static void       LinLSQRSetPrecUnit(CLinLSQRState &state);
   static void       LinLSQRSetPrecDiag(CLinLSQRState &state);
   static void       LinLSQRSetLambdaI(CLinLSQRState &state,double lambdai);
   static bool       LinLSQRIteration(CLinLSQRState &state);
   static void       LinLSQRSolveSparse(CLinLSQRState &state,CSparseMatrix &a,CRowDouble &b);
   static void       LinLSQRSetCond(CLinLSQRState &state,double epsa,double epsb,int maxits);
   static void       LinLSQRResults(CLinLSQRState &state,CRowDouble &x,CLinLSQRReport &rep);
   static void       LinLSQRSetXRep(CLinLSQRState &state,bool needxrep);
   static void       CLinLSQR::LinLSQRRestart(CLinLSQRState &state);
   static int        LinLSQRPeekIterationsCount(CLinLSQRState &s);
   static void       LinLSQRRequestTermination(CLinLSQRState &state);

private:
   static void       ClearrFields(CLinLSQRState &state);
  };
//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
const double CLinLSQR::m_atol=1.0E-6;
const double CLinLSQR::m_btol=1.0E-6;
//+------------------------------------------------------------------+
//| This function initializes linear LSQR Solver. This solver is used|
//| to solve non-symmetric (and, possibly, non-square) problems.     |
//| Least squares solution is returned for non - compatible systems. |
//| USAGE:                                                           |
//|   1. User initializes algorithm state with LinLSQRCreate() call  |
//|   2. User tunes solver parameters with LinLSQRSetCond() and other|
//|      functions                                                   |
//|   3. User calls LinLSQRSolveSparse() function which takes        |
//|      algorithm state and SparseMatrix object.                    |
//|   4. User calls LinLSQRResults() to get solution                 |
//|   5. Optionally, user may call LinLSQRSolveSparse() again to     |
//|      solve another problem with different matrix and/or right    |
//|      part without reinitializing LinLSQRState structure.         |
//| INPUT PARAMETERS:                                                |
//|   M        -  number of rows in A                                |
//|   N        -  number of variables, N > 0                         |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//| NOTE: see also LinLSQRCreateBuf() for version which reuses       |
//|       previously allocated place as much as possible.            |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRCreate(int m,int n,CLinLSQRState &state)
  {
//--- check
   if(!CAp::Assert(m>0,__FUNCTION__+": M<=0"))
      return;
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;
//--- function call
   LinLSQRCreateBuf(m,n,state);
  }
//+------------------------------------------------------------------+
//| This function initializes linear LSQR Solver. It provides exactly|
//| same functionality as LinLSQRCreate(), but reuses previously     |
//| allocated space as much as possible.                             |
//| INPUT PARAMETERS:                                                |
//|   M        -  number of rows in A                                |
//|   N        -  number of variables, N > 0                         |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRCreateBuf(int m,int n,CLinLSQRState &state)
  {
//--- check
   if(!CAp::Assert(m>0,__FUNCTION__+": M<=0"))
      return;
   if(!CAp::Assert(n>0,__FUNCTION__+": N<=0"))
      return;

   state.m_m=m;
   state.m_n=n;
   state.m_prectype=0;
   state.m_epsa=m_atol;
   state.m_epsb=m_btol;
   state.m_epsc=1/MathSqrt(CMath::m_machineepsilon);
   state.m_maxits=0;
   state.m_lambdai=0;
   state.m_xrep=false;
   state.m_running=false;
   state.m_repiterationscount=0;
//--- * allocate arrays
//--- * set RX to NAN (just for the case user calls Results() without
//---  calling SolveSparse()
//--- * set B to zero
   CNormEstimator::NormEstimatorCreate(m,n,2,2,state.m_nes);
   state.m_rx=vector<double>::Full(state.m_n,AL_NaN);
   state.m_ui=vector<double>::Zeros(state.m_m+state.m_n);
   state.m_uip1=vector<double>::Zeros(state.m_m+state.m_n);
   state.m_vip1=vector<double>::Zeros(state.m_n);
   state.m_vi=vector<double>::Zeros(state.m_n);
   state.m_omegai=vector<double>::Zeros(state.m_n);
   state.m_omegaip1=vector<double>::Zeros(state.m_n);
   state.m_d=vector<double>::Zeros(state.m_n);
   state.m_x=vector<double>::Zeros(state.m_m+state.m_n);
   state.m_mv=vector<double>::Zeros(state.m_m+state.m_n);
   state.m_mtv=vector<double>::Zeros(state.m_n);
   state.m_b=vector<double>::Zeros(state.m_m);
   state.m_rstate.ia.Resize(2);
   state.m_rstate.ra=vector<double>::Zeros(1);
   state.m_rstate.stage=-1;
  }
//+------------------------------------------------------------------+
//| This function sets right part. By default, right part is zero.   |
//| INPUT PARAMETERS:                                                |
//|   B        -  right part, array[N].                              |
//| OUTPUT PARAMETERS:                                               |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetB(CLinLSQRState &state,CRowDouble &b)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change B when LinLSQRIteration is running"))
      return;
   if(!CAp::Assert(state.m_m<=CAp::Len(b),__FUNCTION__+": Length(B)<M"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,state.m_m),__FUNCTION__+": B contains infinite or NaN values"))
      return;

   state.m_b=b;
   state.m_b.Resize(state.m_m);
   state.m_bnorm2=state.m_b.Dot(state.m_b);
  }
//+------------------------------------------------------------------+
//| This function changes preconditioning settings of                |
//| LinLSQQSolveSparse() function. By default, SolveSparse() uses    |
//| diagonal preconditioner, but if you want to use solver without   |
//| preconditioning, you can call this function which forces solver  |
//| to use unit matrix for preconditioning.                          |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetPrecUnit(CLinLSQRState &state)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change preconditioner,because function LinLSQRIteration is running!"))
      return;

   state.m_prectype=-1;
  }
//+------------------------------------------------------------------+
//| This function changes preconditioning settings of                |
//| LinCGSolveSparse() function. LinCGSolveSparse() will use diagonal|
//| of the system matrix as preconditioner. This preconditioning mode|
//| is active by default.                                            |
//| INPUT PARAMETERS:                                                |
//|   State       -  structure which stores algorithm state          |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetPrecDiag(CLinLSQRState &state)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not change preconditioner,because function LinCGIteration is running!"))
      return;

   state.m_prectype=0;
  }
//+------------------------------------------------------------------+
//| This function sets optional Tikhonov regularization coefficient. |
//| It is zero by default.                                           |
//| INPUT PARAMETERS:                                                |
//|   LambdaI     -  regularization factor, LambdaI >= 0             |
//| OUTPUT PARAMETERS:                                               |
//|   State       -  structure which stores algorithm state          |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetLambdaI(CLinLSQRState &state,double lambdai)
  {
//--- check
   if(!CAp::Assert(!state.m_running,"LinLSQRSetLambdaI: you can not set LambdaI,because function LinLSQRIteration is running"))
      return;
   if(!CAp::Assert(MathIsValidNumber(lambdai) && lambdai>=0.0,"LinLSQRSetLambdaI: LambdaI is infinite or NaN"))
      return;

   state.m_lambdai=lambdai;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLinLSQR::LinLSQRIteration(CLinLSQRState &state)
  {
//--- create variables
   int    summn=0;
   double bnorm=0;
   int    i=0;
   int    i_=0;
   int    label=-1;
//--- Reverse communication preparations
//--- This code initializes locals by:
//--- * random values determined during code
//---  generation - on first subroutine call
//--- * values from previous call - on subsequent calls
   if(state.m_rstate.stage>=0)
     {
      summn=state.m_rstate.ia[0];
      i=state.m_rstate.ia[1];
      bnorm=state.m_rstate.ra[0];
     }
   else
     {
      summn=359;
      i=-58;
      bnorm=-919;
     }
   switch(state.m_rstate.stage)
     {
      case 0:
         label=0;
         break;
      case 1:
         label=1;
         break;
      case 2:
         label=2;
         break;
      case 3:
         label=3;
         break;
      case 4:
         label=4;
         break;
      case 5:
         label=5;
         break;
      case 6:
         label=6;
         break;
      default:
         //--- Routine body
         //--- check
         if(!CAp::Assert(CAp::Len(state.m_b)>0,__FUNCTION__+": using non-allocated array B"))
            return(false);
         summn=state.m_m+state.m_n;
         bnorm=MathSqrt(state.m_bnorm2);
         state.m_userterminationneeded=false;
         state.m_running=true;
         state.m_repnmv=0;
         state.m_repiterationscount=0;
         state.m_r2=state.m_bnorm2;
         ClearrFields(state);
         //estimate for ANorm
         CNormEstimator::NormEstimatorRestart(state.m_nes);
         label=7;
         break;
     }
//--- main loop
   while(label>=0)
      switch(label)
        {
         case 7:
            if(!CNormEstimator::NormEstimatorIteration(state.m_nes))
              {
               label=8;
               break;
              }
            if(!state.m_nes.m_NeedMv)
              {
               label=9;
               break;
              }
            for(i_=0; i_<state.m_n; i_++)
               state.m_x.Set(i_,state.m_nes.m_X[i_]);
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needmv=true;
            state.m_rstate.stage=0;
            label=-1;
            break;
         case 0:
            state.m_needmv=false;
            state.m_nes.m_Mv=state.m_mv;
            label=7;
            break;
         case 9:
            if(!state.m_nes.m_NeedMtv)
              {
               label=11;
               break;
              }
            for(i_=0; i_<state.m_n; i_++)
               state.m_x.Set(i_,state.m_nes.m_X[i_]);
            //matrix-vector multiplication
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needmtv=true;
            state.m_rstate.stage=1;
            label=-1;
            break;
         case 1:
            state.m_needmtv=false;
            state.m_nes.m_Mtv=state.m_mtv;
            label=7;
            break;
         case 11:
            label=7;
            break;
         case 8:
            CNormEstimator::NormEstimatorResults(state.m_nes,state.m_anorm);
            //--- initialize .RX by zeros
            state.m_rx.Fill(0);
            //output first report
            if(!state.m_xrep)
              {
               label=13;
               break;
              }
            for(i_=0; i_<state.m_n; i_++)
               state.m_x.Set(i_,state.m_rx[i_]);
            ClearrFields(state);
            state.m_xupdated=true;
            state.m_rstate.stage=2;
            label=-1;
            break;
         case 2:
            state.m_xupdated=false;
         case 13:
            //--- LSQR, Step 0.
            //--- Algorithm outline corresponds to one which was described at p.50 of
            //--- "LSQR - an algorithm for sparse linear equations and sparse least
            //--- squares" by C.Paige and M.Saunders with one small addition - we
            //--- explicitly extend system matrix by additional N lines in order
            //--- to handle non-zero lambda, i.e. original A is replaced by
            //---     [ A    ]
            //--- A_mod = [     ]
            //---     [ lambda*I ].
            //--- Step 0:
            //---   x[0]     = 0
            //---   beta[1]*u[1] = b
            //---   alpha[1]*v[1] = A_mod'*u[1]
            //---   w[1]     = v[1]
            //---   phiBar[1]   = beta[1]
            //---   rhoBar[1]   = alpha[1]
            //---   d[0]     = 0
            //--- NOTE:
            //--- There are three criteria for stopping:
            //--- (S0) maximum number of iterations
            //--- (S1) ||Rk||<=EpsB*||B||;
            //--- (S2) ||A^T*Rk||/(||A||*||Rk||)<=EpsA.
            //--- It is very important that S2 always checked AFTER S1. It is necessary
            //--- to avoid division by zero when Rk=0.
            state.m_betai=bnorm;
            if(state.m_betai==0.0)
              {
               //--- Zero right part
               state.m_running=false;
               state.m_repterminationtype=1;
               return(false);
              }
            for(i=0; i<summn; i++)
              {
               if(i<state.m_m)
                  state.m_ui.Set(i,state.m_b[i]/state.m_betai);
               else
                  state.m_ui.Set(i,0);
               state.m_x.Set(i,state.m_ui[i]);
              }
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needmtv=true;
            state.m_rstate.stage=3;
            label=-1;
            break;
         case 3:
            state.m_needmtv=false;
            for(i=0; i<state.m_n; i++)
               state.m_mtv.Add(i,state.m_lambdai*state.m_ui[state.m_m+i]);
            state.m_alphai=state.m_mtv.Dot(state.m_mtv);
            state.m_alphai=MathSqrt(state.m_alphai);
            if(state.m_alphai==0.0)
              {
               //--- Orthogonality stopping criterion is met
               state.m_running=false;
               state.m_repterminationtype=4;
               return(false);
              }
            state.m_vi=state.m_mtv/state.m_alphai+0;
            state.m_omegai=state.m_vi;
            state.m_phibari=state.m_betai;
            state.m_rhobari=state.m_alphai;
            state.m_d.Fill(0);
            state.m_dnorm=0;
         //--- Steps I=1, 2, ...
         case 15:
            //--- At I-th step State.RepIterationsCount=I.
            state.m_repiterationscount++;
            //--- Bidiagonalization part:
            //---   beta[i+1]*u[i+1] = A_mod*v[i]-alpha[i]*u[i]
            //---   alpha[i+1]*v[i+1] = A_mod'*u[i+1] - beta[i+1]*v[i]
            //--- NOTE: beta[i+1]=0 or alpha[i+1]=0 will lead to successful termination
            //---    in the end of the current iteration. In this case u/v are zero.
            //--- NOTE2: algorithm won't fail on zero alpha or beta (there will be no
            //---    division by zero because it will be stopped BEFORE division
            //---    occurs). However, near-zero alpha and beta won't stop algorithm
            //---    and, although no division by zero will happen, orthogonality
            //---    in U and V will be lost.
            for(i_=0; i_<state.m_n; i_++)
               state.m_x.Set(i_,state.m_vi[i_]);
            state.m_repnmv=state.m_repnmv+1;
            ClearrFields(state);
            state.m_needmv=true;
            state.m_rstate.stage=4;
            label=-1;
            break;
         case 4:
            state.m_needmv=false;
            for(i=0; i<state.m_n; i++)
               state.m_mv.Set(state.m_m+i,state.m_lambdai*state.m_vi[i]);
            state.m_betaip1=0;
            state.m_uip1=state.m_mv.ToVector()-state.m_ui*state.m_alphai;
            state.m_betaip1=CAblasF::RDotV2(summn,state.m_uip1);
            if(state.m_betaip1!=0.0)
              {
               state.m_betaip1=MathSqrt(state.m_betaip1);
               state.m_uip1/=state.m_betaip1;
              }
            state.m_x=state.m_uip1;
            state.m_repnmv++;
            ClearrFields(state);
            state.m_needmtv=true;
            state.m_rstate.stage=5;
            label=-1;
            break;
         case 5:
            state.m_needmtv=false;
            for(i=0; i<state.m_n; i++)
               state.m_mtv.Add(i,state.m_lambdai*state.m_uip1[state.m_m+i]);
            state.m_alphaip1=0;
            state.m_vip1=state.m_mtv.ToVector()-state.m_vi*state.m_betaip1 ;
            state.m_alphaip1=state.m_vip1.Dot(state.m_vip1);
            if(state.m_alphaip1!=0.0)
              {
               state.m_alphaip1=MathSqrt(state.m_alphaip1);
               state.m_vip1/=state.m_alphaip1;
              }
            //--- Build next orthogonal transformation
            state.m_rhoi=CApServ::SafePythag2(state.m_rhobari,state.m_betaip1);
            state.m_ci=state.m_rhobari/state.m_rhoi;
            state.m_si=state.m_betaip1/state.m_rhoi;
            state.m_theta=state.m_si*state.m_alphaip1;
            state.m_rhobarip1=-(state.m_ci*state.m_alphaip1);
            state.m_phii=state.m_ci*state.m_phibari;
            state.m_phibarip1=state.m_si*state.m_phibari;
            //--- Update .RNorm
            //--- This tricky formula is necessary because simply writing
            //--- State.R2:=State.PhiBarIP1*State.PhiBarIP1 does NOT guarantees
            //--- monotonic decrease of R2. Roundoff error combined with 80-bit
            //--- precision used internally by Intel chips allows R2 to increase
            //--- slightly in some rare, but possible cases. This property is
            //--- undesirable, so we prefer to guard against R increase.
            state.m_r2=MathMin(state.m_r2,state.m_phibarip1*state.m_phibarip1);
            //--- Update d and DNorm, check condition-related stopping criteria
            state.m_d=(state.m_vi.ToVector()-state.m_d*state.m_theta)/state.m_rhoi;
            state.m_dnorm=CAblasF::RDotV2(state.m_n,state.m_d);
            if((MathSqrt(state.m_dnorm)*state.m_anorm)>=state.m_epsc)
              {
               state.m_running=false;
               state.m_repterminationtype=7;
               return(false);
              }
            //--- Update x, output report
            state.m_rx+=state.m_omegai.ToVector()*state.m_phii/state.m_rhoi;
            if(!state.m_xrep)
              {
               label=17;
               break;
              }
            for(i_=0; i_<state.m_n; i_++)
               state.m_x.Set(i_,state.m_rx[i_]);
            ClearrFields(state);
            state.m_xupdated=true;
            state.m_rstate.stage=6;
            label=-1;
            break;
         case 6:
            state.m_xupdated=false;
         case 17:
            //--- Check stopping criteria
            //--- 1. achieved required number of iterations;
            //--- 2. ||Rk||<=EpsB*||B||;
            //--- 3. ||A^T*Rk||/(||A||*||Rk||)<=EpsA;
            if(state.m_maxits>0 && state.m_repiterationscount>=state.m_maxits)
              {
               //--- Achieved required number of iterations
               state.m_running=false;
               state.m_repterminationtype=5;
               return(false);
              }
            if(state.m_phibarip1<=state.m_epsb*bnorm)
              {
               //--- ||Rk||<=EpsB*||B||, here ||Rk||=PhiBar
               state.m_running=false;
               state.m_repterminationtype=1;
               return(false);
              }
            if((state.m_alphaip1*MathAbs(state.m_ci)/state.m_anorm)<=state.m_epsa)
              {
               //--- ||A^T*Rk||/(||A||*||Rk||)<=EpsA, here ||A^T*Rk||=PhiBar*Alpha[i+1]*|.C|
               state.m_running=false;
               state.m_repterminationtype=4;
               return(false);
              }
            if(state.m_userterminationneeded)
              {
               //--- User requested termination
               state.m_running=false;
               state.m_repterminationtype=8;
               return(false);
              }
            //--- Update omega
            state.m_omegaip1=state.m_vip1.ToVector()-state.m_omegai*state.m_theta/state.m_rhoi;
            //--- Prepare for the next iteration - rename variables:
            //--- u[i]  := u[i+1]
            //--- v[i]  := v[i+1]
            //--- rho[i] := rho[i+1]
            //--- ...
            state.m_ui=state.m_uip1;
            state.m_vi=state.m_vip1;
            state.m_omegai=state.m_omegaip1;
            state.m_alphai=state.m_alphaip1;
            state.m_betai=state.m_betaip1;
            state.m_phibari=state.m_phibarip1;
            state.m_rhobari=state.m_rhobarip1;
            label=15;
            break;
         case 16:
            return(false);
        }
//--- Saving state
   state.m_rstate.ia.Set(0,summn);
   state.m_rstate.ia.Set(1,i);
   state.m_rstate.ra.Set(0,bnorm);
//--- return result
   return(true);
  }
//+------------------------------------------------------------------+
//| Procedure for solution of A*x = b with sparse A.                 |
//| INPUT PARAMETERS:                                                |
//|   State       -  algorithm state                                 |
//|   A           -  sparse M*N matrix in the CRS format (you MUST   |
//|                  contvert it to CRS format by calling            |
//|                  SparseConvertToCRS() function BEFORE you pass it|
//|                  to this function).                              |
//|   B           -  right part, array[M]                            |
//| RESULT:                                                          |
//|   This function returns no result.                               |
//|   You can get solution by calling LinCGResults()                 |
//| NOTE: this function uses lightweight preconditioning -           |
//|       multiplication by inverse of diag(A). If you want, you can |
//|      turn preconditioning off by calling LinLSQRSetPrecUnit().   |
//|      However, preconditioning cost is low and preconditioner is  |
//|      very important for solution of badly scaled problems.       |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSolveSparse(CLinLSQRState &state,
                                  CSparseMatrix &a,CRowDouble &b)
  {
//--- create variables
   int    n=state.m_n;
   int    i=0;
   int    j=0;
   int    t0=0;
   int    t1=0;
   double v=0;
//--- check
   if(!CAp::Assert(!state.m_running,"LinLSQRSolveSparse: you can not call this function when LinLSQRIteration is running"))
      return;
   if(!CAp::Assert(CAp::Len(b)>=state.m_m,"LinLSQRSolveSparse: Length(B)<M"))
      return;
   if(!CAp::Assert(CApServ::IsFiniteVector(b,state.m_m),"LinLSQRSolveSparse: B contains infinite or NaN values"))
      return;
//--- Allocate temporaries
   state.m_tmpd.Resize(n);
   state.m_tmpx.Resize(n);
//--- Compute diagonal scaling matrix D
   if(state.m_prectype==0)
     {
      //--- Default preconditioner - inverse of column norms
      state.m_tmpd.Fill(0);
      t0=0;
      t1=0;
      while(CSparse::SparseEnumerate(a,t0,t1,i,j,v))
         state.m_tmpd.Add(j,CMath::Sqr(v));
      for(i=0; i<n; i++)
        {
         if(state.m_tmpd[i]>0.0)
            state.m_tmpd.Set(i,1/MathSqrt(state.m_tmpd[i]));
         else
            state.m_tmpd.Set(i,1);
        }
     }
   else
     {
      //--- No diagonal scaling
      state.m_tmpd.Fill(1);
     }
//--- Solve.
//--- Instead of solving A*x=b we solve preconditioned system (A*D)*(inv(D)*x)=b.
//--- Transformed A is not calculated explicitly, we just modify multiplication
//--- by A or A'. After solution we modify State.RX so it will store untransformed
//--- variables
   LinLSQRSetB(state,b);
   LinLSQRRestart(state);
   while(LinLSQRIteration(state))
     {
      if(state.m_needmv)
        {
         for(i=0; i<n; i++)
            state.m_tmpx.Set(i,state.m_tmpd[i]*state.m_x[i]);
         CSparse::SparseMV(a,state.m_tmpx,state.m_mv);
        }
      if(state.m_needmtv)
        {
         CSparse::SparseMTV(a,state.m_x,state.m_mtv);
         state.m_mtv*=state.m_tmpd;
        }
     }
   state.m_rx*=state.m_tmpd;
  }
//+------------------------------------------------------------------+
//| This function sets stopping criteria.                            |
//| INPUT PARAMETERS:                                                |
//|   EpsA        -  algorithm will be stopped if                    |
//|                  || A^T * Rk || / ( || A || * || Rk ||) <= EpsA. |
//|   EpsB        -  algorithm will be stopped if                    |
//|                  || Rk || <= EpsB * || B ||                      |
//|   MaxIts      -  algorithm will be stopped if number of          |
//|                  iterations more than MaxIts.                    |
//| OUTPUT PARAMETERS:                                               |
//|   State       -  structure which stores algorithm state          |
//| NOTE: if EpsA, EpsB, EpsC and MaxIts are zero then these         |
//|       variables will be setted as default values.                |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetCond(CLinLSQRState &state,double epsa,
                              double epsb,int maxits)
  {
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not call this function when LinLSQRIteration is running"))
      return;
   if(!CAp::Assert(MathIsValidNumber(epsa) && epsa>=0.0,__FUNCTION__+": EpsA is negative,INF or NAN"))
      return;
   if(!CAp::Assert(MathIsValidNumber(epsb) && epsb>=0.0,__FUNCTION__+": EpsB is negative,INF or NAN"))
      return;
   if(!CAp::Assert(maxits>=0,__FUNCTION__+": MaxIts is negative"))
      return;

   if((epsa==0.0 && epsb==0.0) && maxits==0)
     {
      state.m_epsa=m_atol;
      state.m_epsb=m_btol;
      state.m_maxits=state.m_n;
     }
   else
     {
      state.m_epsa=epsa;
      state.m_epsb=epsb;
      state.m_maxits=maxits;
     }
  }
//+------------------------------------------------------------------+
//| LSQR solver: results.                                            |
//| This function must be called after LinLSQRSolve                  |
//| INPUT PARAMETERS:                                                |
//|   State    -  algorithm state                                    |
//| OUTPUT PARAMETERS:                                               |
//|   X        -  array[N], solution                                 |
//|   Rep      -  optimization report:                               |
//|               * Rep.TerminationType completetion code:           |
//|                  * 1  || Rk || <= EpsB* || B ||                  |
//|                  * 4  ||A^T * Rk|| / (||A|| * ||Rk||) <= EpsA    |
//|                  * 5  MaxIts steps was taken                     |
//|                  * 7  rounding errors prevent further progress,  |
//|                       X contains best point found so far.        |
//|                       (sometimes returned on singular systems)   |
//|                  * 8  user requested termination via calling     |
//|                       LinLSQRRequestTermination()                |
//|               * Rep.IterationsCount contains iterations count    |
//|               * NMV countains number of matrix - vector          |
//|                     calculations                                 |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRResults(CLinLSQRState &state,CRowDouble &x,
                              CLinLSQRReport &rep)
  {
   x.Resize(0);
//--- check
   if(!CAp::Assert(!state.m_running,__FUNCTION__+": you can not call this function when LinLSQRIteration is running"))
      return;

   x=state.m_rx;
   x.Resize(state.m_n);
   rep.m_iterationscount=state.m_repiterationscount;
   rep.m_nmv=state.m_repnmv;
   rep.m_terminationtype=state.m_repterminationtype;
  }
//+------------------------------------------------------------------+
//| This function turns on / off reporting.                          |
//| INPUT PARAMETERS:                                                |
//|   State    -  structure which stores algorithm state             |
//|   NeedXRep -  whether iteration reports are needed or not        |
//|               If NeedXRep is True, algorithm will call rep()     |
//|               callback function if it is provided to             |
//|               MinCGOptimize().                                   |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRSetXRep(CLinLSQRState &state,bool needxrep)
  {
   state.m_xrep=needxrep;
  }
//+------------------------------------------------------------------+
//| This function restarts LinLSQRIteration                          |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRRestart(CLinLSQRState &state)
  {
   state.m_rstate.ia.Resize(2);
   state.m_rstate.ra.Resize(1);
   state.m_rstate.stage=-1;
   ClearrFields(state);
   state.m_repiterationscount=0;
  }
//+------------------------------------------------------------------+
//| This function is used to peek into LSQR solver and get current   |
//| iteration counter. You can safely "peek" into the solver from    |
//| another thread.                                                  |
//| INPUT PARAMETERS:                                                |
//|   S        -  solver object                                      |
//| RESULT:                                                          |
//|   iteration counter, in [0, INF)                                 |
//+------------------------------------------------------------------+
int CLinLSQR::LinLSQRPeekIterationsCount(CLinLSQRState &s)
  {
   int result=s.m_repiterationscount;
   return(result);
  }
//+------------------------------------------------------------------+
//| This subroutine submits request for termination of the running   |
//| solver. It can be called from some other thread which wants LSQR |
//| solver to terminate (obviously, the thread running LSQR solver   |
//| can not request termination because it is already busy working on|
//| LSQR).                                                           |
//| As result, solver stops at point which was "current accepted"    |
//| when termination request was submitted and returns error code 8  |
//| (successful termination). Such  termination  is a smooth process |
//| which properly deallocates all temporaries.                      |
//| INPUT PARAMETERS:                                                |
//|   State    -  solver structure                                   |
//| NOTE: calling this function on solver which is NOT running will  |
//|       have no effect.                                            |
//| NOTE: multiple calls to this function are possible. First call is|
//|       counted, subsequent calls are silently ignored.            |
//| NOTE: solver clears termination flag on its start, it means that |
//|       if some other thread will request termination too soon, its|
//|       request will went unnoticed.                               |
//+------------------------------------------------------------------+
void CLinLSQR::LinLSQRRequestTermination(CLinLSQRState &state)
  {
   state.m_userterminationneeded=true;
  }
//+------------------------------------------------------------------+
//| Clears request fileds (to be sure that we don't forgot to clear  |
//| something)                                                       |
//+------------------------------------------------------------------+
void CLinLSQR::ClearrFields(CLinLSQRState &state)
  {
   state.m_xupdated=false;
   state.m_needmv=false;
   state.m_needmtv=false;
   state.m_needmv2=false;
   state.m_needvmv=false;
   state.m_needprec=false;
  }
//+------------------------------------------------------------------+
