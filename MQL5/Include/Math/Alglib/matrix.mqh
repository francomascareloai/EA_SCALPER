//+------------------------------------------------------------------+
//|                                                       matrix.mqh |
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

#include "arrayresize.mqh"

class CMatrixDouble;

//+------------------------------------------------------------------+
//| Rows (double)                                                    |
//+------------------------------------------------------------------+
class CRowDouble
  {
private:
   vector<double>    m_array;

public:
   //--- constructors @ destructor
                     CRowDouble(void)                            {}
                     CRowDouble(const vector<double> &vect)      { m_array=vect; }
                     CRowDouble(const double &vect[])            { this=vect; }
                     CRowDouble(const CRowDouble &vect)          { this=vect; }
                    ~CRowDouble(void)                            {}

   //--- methods
   int               Size(void) const                            { return((int)m_array.Size()); }
   bool              Resize(const ulong n)                       { return(m_array.Resize(n)); }
   void              Set(const int i,const double d)             { m_array[i]=d;}
   void              Add(const int i,const double d)             { m_array[i]+=d; }
   void              Mul(const int i,const double d)             { m_array[i]*=d; }
   vector<double>    Pow(const double p) const                   { return(MathPow(m_array,p)); }
   vector<double>    Sqrt(void)                                  { return(MathSqrt(m_array)); }
   double            Sum(void)                                   { return(m_array.Sum()); }
   bool              ToArray(double &arr[]);
   vector<double>    ToVector(void) const                        { return(m_array); }
   vector<double>    Abs(void) const                             { return(MathAbs(m_array)); }
   double            MaxAbs(void) const                          { return(MathAbs(m_array)).Max(); }
   void              Fill(const double value)                    { m_array.Fill(value); }
   void              Swap(int i1,int i2);
   double            Max()                                       { return(m_array.Max()); }
   ulong             ArgMax()                                    { return(m_array.ArgMax()); }
   double            Min()                                       { return(m_array.Min()); }
   ulong             ArgMin()                                    { return(m_array.ArgMin()); }
   double            Dot(CRowDouble &obj)                        { return(m_array.Dot(obj.ToVector())); }
   double            Dot(vector<double> &obj)                    { return(m_array.Dot(obj)); }
   double            DotR(CMatrixDouble &obj,int row)            { return(m_array.Dot(obj.Row(row))); }
   double            DotC(CMatrixDouble &obj,int col)            { return(m_array.Dot(obj.Col(col))); }
   vector<double>    MatMul(matrix<double> &obj)                 { return(m_array.MatMul(obj)); }
   vector<double>    MatMul(CMatrixDouble &obj)                  { return(m_array.MatMul(obj.ToMatrix())); }
   bool              Clip(const double min,const double max)     { return(m_array.Clip(min,max)); }
   void              Copy(const vector<double> &vect,const int n);

   //--- operators
   double            operator[](const int i) const               { return(m_array[i]); }
   void              operator=(const double &array[])            { m_array.Assign(array); }
   void              operator=(const vector<double> &vect)       { m_array.Assign(vect); }
   void              operator=(const CRowDouble &vect)           { m_array.Assign(vect.m_array); }
   vector<double>    operator^(const double p) const             { return(Pow(p)); }
   vector<double>    operator/(const double p) const             { return(m_array/p); }
   vector<double>    operator/(const CRowDouble &p) const        { return(m_array/p.ToVector()); }
   vector<double>    operator/(const vector<double> &p) const    { return(m_array/p); }
   vector<double>    operator+(const double value) const         { return(m_array+value); }
   vector<double>    operator+(const vector<double> &vect) const { return(m_array+vect); }
   vector<double>    operator+(const CRowDouble &vect) const     { return(m_array+vect.m_array); }
   vector<double>    operator+(const double &vect[]) const;
   vector<double>    operator-(const double value) const         { return(m_array-value); }
   vector<double>    operator-(const vector<double> &vect) const { return(m_array-vect); }
   vector<double>    operator-(const CRowDouble &vect) const     { return(m_array-vect.m_array); }
   vector<double>    operator-(const double &vect[]) const;
   vector<double>    operator*(const double value) const         { return(m_array*value); }
   vector<double>    operator*(const CRowDouble &vect) const     { return(m_array*vect.m_array); }
   void              operator/=(const double value)              { m_array=m_array/value; }
   void              operator*=(const double value)              { m_array=m_array*value; }
   void              operator+=(const CRowDouble &vect)          { m_array=m_array+vect.m_array; }
   void              operator+=(const vector<double> &vect)      { m_array=m_array+vect; }
   void              operator+=(const double value)              { m_array=m_array+value; }
   void              operator-=(const double val)                { m_array=m_array-val; }
   void              operator-=(const CRowDouble &vect)          { m_array=m_array-vect.m_array; }
   void              operator-=(const vector<double> &vect)      { m_array=m_array-vect; }
   void              operator-=(const double &vect[]);
   void              operator*=(const CRowDouble &vect)          { m_array=m_array*vect.m_array; }
   void              operator*=(const vector<double> &vect)      { m_array=m_array*vect; }
   void              operator/=(const CRowDouble &vect)          { m_array=m_array/vect.m_array; }
   void              operator/=(const vector<double> &vect)      { m_array=m_array/vect; }
  };
//+------------------------------------------------------------------+
//| Method ToArray                                                   |
//+------------------------------------------------------------------+
bool CRowDouble::ToArray(double &arr[])
  {
   ulong size=Size();
   if(ArrayResize(arr,(int)size)!=size)
      return(false);

   for(ulong i=0; i<size; i++)
      arr[i]=m_array[i];

   return(true);
  }
//+------------------------------------------------------------------+
//| Method Swap                                                      |
//+------------------------------------------------------------------+
void CRowDouble::Swap(int i1,int i2)
  {
   if(i1>=0 && i2>=0 && i1<(int)Size() && i2<(int)Size())
     {
      double temp=m_array[i1];
      m_array[i1]=m_array[i2];
      m_array[i2]=temp;
     }
  }
//+------------------------------------------------------------------+
//| Method Copy                                                      |
//+------------------------------------------------------------------+
void CRowDouble::Copy(const vector<double> &vect,const int n)
  {
   if(Size()<=n)
     {
      m_array=vect;
      m_array.Resize(n);
     }
   else
     {
      int size=(int)MathMin(n,vect.Size());
      for(int i=0; i<size; i++)
         m_array[i]=vect[i];
     }
  }
//+------------------------------------------------------------------+
//| Overloading (+)                                                  |
//+------------------------------------------------------------------+
vector<double> CRowDouble::operator+(const double &vect[]) const
  {
   int            size=MathMin(ArraySize(vect),Size());
   vector<double> result=m_array;

   for(int i=0; i<size; i++)
      result[i]+=vect[i];

   return(result);
  }
//+------------------------------------------------------------------+
//| Overloading (-)                                                  |
//+------------------------------------------------------------------+
vector<double> CRowDouble::operator-(const double &vect[]) const
  {
   int            size=MathMin(ArraySize(vect),Size());
   vector<double> result=m_array;

   for(int i=0; i<size; i++)
      result[i]-=vect[i];

   return(result);
  }
//+------------------------------------------------------------------+
//| Overloading (-=)                                                 |
//+------------------------------------------------------------------+
void CRowDouble::operator-=(const double &vect[])
  {
   int size=MathMin(ArraySize(vect),Size());

   for(int i=0; i<size; i++)
      m_array[i]-=vect[i];
  }

//+------------------------------------------------------------------+
//| Rows (int)                                                       |
//+------------------------------------------------------------------+
class CRowInt
  {
private:
   int               m_array[];

public:
   //--- constructors @ destructor
                     CRowInt(void)                 {}
                     CRowInt(const CRowInt &obj)   { this=obj; }
                     CRowInt(const int &array[])   { this=array; }
                    ~CRowInt(void)                 {}
   //--- methods
   int               Size(void) const              { return(ArraySize(m_array)); }
   void              Resize(const int n)           { ArrayResizeAL(m_array,n); }
   void              Set(const int i,const int d)  { m_array[i]=d; }
   void              Add(const int i,const int d)  { m_array[i]+=d; }
   void              Swap(int i1,int i2);
   CRowInt           Pow(const int p);
   long              Sum(void);
   bool              ToArray(int &arr[]);
   CRowInt           Abs(void) const;
   int               MaxAbs(void) const;
   void              Fill(const int value)                                  { ArrayInitialize(m_array,value); }
   void              Fill(const int value,const int offset,const int count) { ArrayFill(m_array,offset,count,value); }
   int               Max()                                                  { return (Size()>0?m_array[ArrayMaximum(m_array)]:INT_MAX); }
   int               Min()                                                  { return (Size()>0?m_array[ArrayMinimum(m_array)]:INT_MIN); }
   long              Dot(CRowInt &obj);
   void              Copy(const CRowInt &obj,const int offset,const int offset_obj,const int count);
   void              Copy(const int &obj[],const int offset,const int offset_obj,const int count);
   void              Mul(int pos,int mult)  { m_array[pos]=m_array[pos]*mult; }
   
   //--- operators
   int               operator[](const int i) const    { return(m_array[i]); }
   void              operator=(const int &array[]);
   void              operator=(const CRowInt &r);
   CRowInt           operator^(const int p)           { return Pow(p); }
   CRowInt           operator/(const int p);
   CRowInt           operator+(const int add);
   CRowInt           operator+(const CRowInt &add);
   CRowInt           operator-(const int value);
   CRowInt           operator-(const CRowInt &value);
   CRowInt           operator*(const int mult);
   void              operator/=(const int value);
   void              operator*=(const int value);
   void              operator+=(const CRowInt &add)   { this=this+add; }
   void              operator+=(const int add)        { this=this+add; }
   void              operator-=(const CRowInt &value) { this=this-value; }
   void              operator-=(const int value)      { this=this-value; }
  };
//+------------------------------------------------------------------+
//| Method Swap                                                      |
//+------------------------------------------------------------------+
void CRowInt::Swap(int i1,int i2)
  {
   if(i1>=0 && i2>=0 && i1<Size() && i2<Size())
     {
      int temp=m_array[i1];
      m_array[i1]=m_array[i2];
      m_array[i2]=temp;
     }
  }
//+------------------------------------------------------------------+
//| Method Pow                                                       |
//+------------------------------------------------------------------+
CRowInt CRowInt::Pow(const int p)
  {
   int array[];
   int size=Size();

   ArrayResize(array,size);
   for(int i=0; i<size; i++)
      array[i]=(int)MathPow(m_array[i],p);

   return(array);
  }
//+------------------------------------------------------------------+
//| Method Sum                                                       |
//+------------------------------------------------------------------+
long CRowInt::Sum(void)
  {
   long sum=0;
   int  size=Size();

   for(int i=0; i<size; i++)
      sum+=m_array[i];

   return(sum);
  }
//+------------------------------------------------------------------+
//| Method ToArray                                                   |
//+------------------------------------------------------------------+
bool CRowInt::ToArray(int &arr[])
  {
   int size=Size();

   if(ArrayResize(arr,size)!=size)
      return(false);

   return(ArrayCopy(arr,m_array)==size);
  }
//+------------------------------------------------------------------+
//| Method Dot                                                       |
//+------------------------------------------------------------------+
long CRowInt::Dot(CRowInt &obj)
  {
   long dot=0;

   if(Size()==obj.Size())
     {
      int size=Size();
      for(int i=0; i<size; i++)
         dot+=m_array[i]*obj[i];
     }

   return(dot);
  }
//+------------------------------------------------------------------+
//| Method Copy                                                      |
//+------------------------------------------------------------------+
void CRowInt::Copy(const CRowInt &obj,const int offset,const int offset_obj,const int count)
  {
   ArrayCopy(m_array,obj.m_array,offset,offset_obj,count);
  }
//+------------------------------------------------------------------+
//| Method Copy                                                      |
//+------------------------------------------------------------------+
void CRowInt::Copy(const int &obj[],const int offset,const int offset_obj,const int count)
  {
   ArrayCopy(m_array,obj,offset,offset_obj,count);
  }
//+------------------------------------------------------------------+
//| Overloading (=)                                                  |
//+------------------------------------------------------------------+
void CRowInt::operator=(const int &array[])
  {
   if(ArraySize(array)>0)
     {
      ArrayFree(m_array);
      ArrayCopy(m_array,array);
     }
  }
//+------------------------------------------------------------------+
//| Overloading (=)                                                  |
//+------------------------------------------------------------------+
void CRowInt::operator=(const CRowInt &r)
  {
   if(r.Size()>0)
     {
      ArrayFree(m_array);
      ArrayCopy(m_array,r.m_array);
     }
  }
//+------------------------------------------------------------------+
//| Overloading (+)                                                  |
//+------------------------------------------------------------------+
CRowInt CRowInt::operator+(const CRowInt &add)
  {
   int size1=Size();
   int size2=add.Size();
   int total=MathMax(size1,size2);
   int result[];
//--- check and allocate
   if(total>0 && ArrayResize(result,total)==total)
     {
      //--- filling array
      for(int i=0; i<total; i++)
         result[i]=(i<size1?m_array[i]:0)+(i<size2?add.m_array[i]:0);
     }
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Overloading (+)                                                  |
//+------------------------------------------------------------------+
CRowInt CRowInt::operator+(const int add)
  {
   int total=Size();
   int result[];
//--- check and allocate
   if(total==0 || ArrayResize(result,total)<total)
      return result;
//--- filling array
   for(int i=0; i<total; i++)
      result[i]=m_array[i]+add;
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Overloading (-)                                                  |
//+------------------------------------------------------------------+
CRowInt CRowInt::operator-(const CRowInt &value)
  {
   int size1=Size();
   int size2=value.Size();
   int total=MathMax(size1,size2);
   int result[];
//--- check and allocate
   if(total==0 || ArrayResize(result,total)<total)
      return result;
//--- filling array
   for(int i=0; i<total; i++)
      result[i]=(i<size1?m_array[i]:0)-(i<size2?value.m_array[i]:0);
//--- return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Overloading (-)                                                  |
//+------------------------------------------------------------------+
CRowInt CRowInt::operator-(const int value)
  {
   int total=Size();
   int result[];
//--- check and allocate
   if(total==0 || ArrayResize(result,total)<total)
      return result;
//--- filling array
   for(int i=0; i<total; i++)
      result[i]=m_array[i]-value;
//--- return result
   return(result);
  }

//+------------------------------------------------------------------+
//| Rows (complex)                                                   |
//+------------------------------------------------------------------+
class CRowComplex
  {
private:
   vector<complex>   m_array;
public:
   //--- constructor, destructor
                     CRowComplex(void) {}
                     CRowComplex(const complex &array[]) { *this=array; }
                    ~CRowComplex(void) {}

   //--- methods
   int               Size(void) const                    { return((int)m_array.Size()); }
   void              Resize(const ulong n)               { m_array.Resize(n); }
   void              Set(const int i,const complex c)    { m_array[i]=c; }
   void              Set(const int i,const double d)     { m_array[i]=d+0i; }
   void              Mul(const int i,const complex c)    { m_array[i]*=c; }
   void              Mul(const int i,const double d)     { m_array[i]*=d+0i; }
   void              SetRe(const int i,const double d)   { m_array[i].real=d; }
   void              SetIm(const int i,const double d)   { m_array[i].imag=d; }
   vector<complex>   ToVector(void) const                { return(m_array); }
   bool              ToArray(complex &dst[]);

   //--- operators
   complex           operator[](const int i) const       { return(m_array[i]); }
   void              operator=(const complex &array[])   { m_array.Assign(array); }
   void              operator=(const CRowComplex &r)     { m_array=r.m_array; }
   void              operator=(const vector<complex> &r) { m_array=r; }
   void              operator*=(const complex mult);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CRowComplex::ToArray(complex &dst[])
  {
   int size=Size();
   if(ArrayResize(dst,size)!=size)
      return(false);

   for(int i=0; i<size; i++)
      dst[i]=m_array[i];

   return(true);
  }
//+------------------------------------------------------------------+
//| Overloading (*=)                                                 |
//+------------------------------------------------------------------+
void CRowComplex::operator*=(const complex mult)
  {
   int size=Size();
   for(int i=0; i<size; i++)
      m_array[i]*=mult;
  }

//+------------------------------------------------------------------+
//| Matrix (double)                                                  |
//+------------------------------------------------------------------+
class CMatrixDouble
  {
private:
   matrix<double>    m_matrix;

public:
   //--- constructors, destructor
                     CMatrixDouble(void) {}
                     CMatrixDouble(const ulong rows)                    { m_matrix.Resize(rows,1); }
                     CMatrixDouble(const ulong rows,const ulong cols)   { m_matrix.Resize(rows,cols); }
                     CMatrixDouble(const matrix<double> &mat)           { m_matrix=mat; }
                    ~CMatrixDouble(void) {}

   //--- methods
   int               Size(void) const                                   { return((int)m_matrix.Rows()); }
   int               Rows(void) const                                   { return((int)m_matrix.Rows()); }
   int               Cols(void) const                                   { return((int)m_matrix.Cols()); }
   vector<double>    Row(const int row) const                           { return(m_matrix.Row(row)); }
   bool              Row(const int row,const vector<double> &vect)      { return(m_matrix.Row(vect,row)); }
   bool              Row(const int row,const CRowDouble &vect)          { return m_matrix.Row(vect.ToVector(),row); }
   bool              Row(const int row,const CMatrixDouble &mat,const int mat_row) { return(m_matrix.Row(mat.m_matrix.Row(mat_row),row)); }
   vector<double>    Col(const int col) const                           { return(m_matrix.Col(col)); }
   bool              Col(const int col,const vector<double> &vect)      { return(m_matrix.Col(vect,col)); }
   bool              Col(const int col,const CRowDouble &vect)          { return(m_matrix.Col(vect.ToVector(),col)); }
   bool              Col(const int col,const CRowInt &vect);
   bool              Resize(const ulong n,const ulong m)                { return(m_matrix.Resize(n,m)); }
   bool              Set(const ulong row,const ulong col,double d);
   void              Add(const ulong row,const ulong col,double d)      { m_matrix[row][col]+=d; }
   void              Mul(const ulong row,const ulong col,double d)      { m_matrix[row][col]*=d; }
   double            Get(const ulong row,const ulong col) const         { return(m_matrix[row][col]); }
   matrix<double>    Abs(void) const                                    { return(MathAbs(m_matrix)); }
   matrix<double>    Transpose(void) const                              { return(m_matrix.Transpose()); }
   double            Max(void) const                                    { return(m_matrix.Max()); }
   vector<double>    Max(int axis) const                                { return(m_matrix.Max(axis)); }
   double            Min(void) const                                    { return(m_matrix.Min()); }
   vector<double>    Min(int axis) const                                { return(m_matrix.Min(axis)); }
   double            Mean(void) const                                   { return(m_matrix.Mean()); }
   vector<double>    Mean(int axis) const                               { return(m_matrix.Mean(axis)); }
   double            Std(void) const                                    { return(m_matrix.Std()); }
   vector<double>    Std(int axis) const                                { return(m_matrix.Std(axis)); }
   vector<double>    Sum(int axis) const                                { return(m_matrix.Sum(axis)); }
   void              Split(ulong &parts[],int axis,matrix<double> &splitted[]) const { m_matrix.Split(parts,axis,splitted); }
   matrix<double>    ToMatrix(void) const                               { return(m_matrix); }
   matrix<double>    TriU(const long diag=0) const                      { return(m_matrix.TriU(diag)); }
   matrix<double>    TriL(const long diag=0) const                      { return(m_matrix.TriL(diag)); }
   vector<double>    Diag(const long diag=0) const                      { return(m_matrix.Diag(diag)); }
   void              Diag(const vector<double> &vect,const long diag=0) { m_matrix.Diag(vect,diag); }
   void              Diag(const CRowDouble &vect,const long diag=0)     { m_matrix.Diag(vect.ToVector(),diag); }
   bool              SwapRows(const ulong row1,const ulong row2)        { return(m_matrix.SwapRows(row1,row2)); }
   bool              SwapCols(const ulong col1,const ulong col2)        { return(m_matrix.SwapCols(col1,col2)); }
   void              Fill(double value)                                 { m_matrix.Fill(value); }
   void              Fill(double value,int rows,int cols);
   matrix<double>    MatMul(CMatrixDouble &matr,bool transpose=false);
   int               Compare(const matrix<double>& mat,const double epsilon=1e-308) { return((int)m_matrix.Compare(mat,epsilon)); }
   //---
   bool              InsertRow(int row);
   bool              InsertCol(int col);
   bool              DeleteRow(int row);
   bool              DeleteCol(int col);

   //--- operators
   const vector<double> operator[](const ulong i) const      { return(m_matrix.Row(i)); }
   void              operator=(const matrix<double> &m)      { m_matrix.Copy(m); }
   void              operator=(const CMatrixDouble &m)       { m_matrix=m.ToMatrix(); }
   matrix<double>    operator+(const matrix<double> &m) const;
   matrix<double>    operator+(const CMatrixDouble &m) const;
   matrix<double>    operator+(const double value) const     { return(m_matrix+value); };
   matrix<double>    operator-(const matrix<double> &m) const;
   matrix<double>    operator-(const CMatrixDouble &m) const;
   matrix<double>    operator-(const double value) const     { return(m_matrix-value); };
   matrix<double>    operator*(const matrix<double> &m) const;
   matrix<double>    operator*(const CMatrixDouble &m) const;
   matrix<double>    operator*(const double value) const     { return(m_matrix*value); };
   matrix<double>    operator/(const matrix<double> &m) const;
   matrix<double>    operator/(const CMatrixDouble &m) const;
   matrix<double>    operator/(const double value) const     { return(m_matrix/value); };
   void              operator*=(const double value)          { m_matrix=m_matrix*value; }
   void              operator/=(const double value)          { m_matrix=m_matrix/value; }
   void              operator+=(const double value)          { m_matrix=m_matrix+value; }
   void              operator+=(const matrix<double> &value) { m_matrix=m_matrix+value; }
   void              operator+=(const CMatrixDouble &value)  { m_matrix=m_matrix+value.m_matrix; }
   void              operator-=(const double value)          { m_matrix=m_matrix-value; }
   void              operator-=(const matrix<double> &value) { m_matrix=m_matrix-value; }
   void              operator-=(const CMatrixDouble &value)  { m_matrix=m_matrix-value.m_matrix; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixDouble::Col(const int col,const CRowInt &vect)
  {
   if(col>=Cols())
      return(false);

   int total=Rows();
   int total_data=vect.Size();

   for(int i=0; i<total; i++)
      m_matrix[i,col]=(i<total_data?(double)vect[i]:0.0);

   return(true);
  }
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixDouble::Set(const ulong row,const ulong col,double d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]=d;

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMatrixDouble::Fill(double value,int rows,int cols)
  {
   if(rows>(int)Rows())
      if(!m_matrix.Resize(rows,MathMin(cols,(int)Cols())))
         return;
   if(cols>(int)Cols())
      if(!m_matrix.Resize(Rows(),cols))
         return;

   if(rows==Rows() && cols==Cols())
     {
      m_matrix.Fill(value);
      return;
     }

   for(int i=0; i<rows; i++)
      for(int j=0; j<cols; j++)
         m_matrix[i,j]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::MatMul(CMatrixDouble &matr,bool transpose)
  {
   if(transpose)
      return(m_matrix.MatMul(matr.m_matrix.Transpose()));

   return(m_matrix.MatMul(matr.m_matrix));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixDouble::InsertRow(int row)
  {
   int rows=(int)Rows();
   if(row>rows)
      return(false);
   if(!m_matrix.Resize(rows+1,Cols()))
      return(false);

   for(int i=rows; i>row; i--)
      if(!m_matrix.SwapRows(i-1,i))
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixDouble::InsertCol(int col)
  {
   int cols=(int)Cols();
   if(col>cols)
      return(false);
   if(!m_matrix.Resize(Rows(),cols+1))
      return(false);

   for(int i=cols; i>col; i--)
      if(!m_matrix.SwapCols(i-1,i))
         return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixDouble::DeleteRow(int row)
  {
   int rows=(int)Rows();
   if(row>=rows)
      return(false);

   for(int i=row; i<rows-1; i++)
      if(!m_matrix.SwapRows(i,i+1))
         return(false);

   return(m_matrix.Resize(rows-1,Cols()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixDouble::DeleteCol(int col)
  {
   int cols=(int)Cols();
   if(col>=cols)
      return(false);

   for(int i=col; i<cols-1; i++)
      if(!m_matrix.SwapCols(i,i+1))
         return(false);

   return(m_matrix.Resize(Rows(),cols-1));
  }
//+------------------------------------------------------------------+
//| Overloading (+)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator+(const matrix<double> &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix+m);
  }
//+------------------------------------------------------------------+
//| Overloading (+)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator+(const CMatrixDouble &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix+m.m_matrix);
  }
//+------------------------------------------------------------------+
//| Overloading (-)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator-(const matrix<double> &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix-m);
  }
//+------------------------------------------------------------------+
//| Overloading (-)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator-(const CMatrixDouble &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix-m.m_matrix);
  }
//+------------------------------------------------------------------+
//| Overloading (*)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator*(const matrix<double> &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix*m);
  }
//+------------------------------------------------------------------+
//| Overloading (*)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator*(const CMatrixDouble &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix*m.m_matrix);
  }
//+------------------------------------------------------------------+
//| Overloading (/)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator/(const matrix<double> &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix/m);
  }
//+------------------------------------------------------------------+
//| Overloading (/)                                                  |
//+------------------------------------------------------------------+
matrix<double> CMatrixDouble::operator/(const CMatrixDouble &m) const
  {
   if(m_matrix.Rows()!=m.Rows() || m_matrix.Cols()!=m.Cols())
     {
      matrix<double> zero(0,0);
      return(zero);
     }

   return(m_matrix/m.m_matrix);
  }

//+------------------------------------------------------------------+
//| Matrix (int)                                                     |
//+------------------------------------------------------------------+
class CMatrixInt
  {
private:
   CRowInt           m_matrix[];

public:
   //--- constructors, destructor
                     CMatrixInt(void) {}
                     CMatrixInt(const int rows)             { ArrayResizeAL(m_matrix,rows); }
                     CMatrixInt(const int rows,const int cols);
                    ~CMatrixInt(void) {}

   //--- methods
   int               Size(void) const                       { return(ArraySize(m_matrix)); }
   int               Rows(void) const                       { return(Size()); }
   int               Cols(void) const                       { return(Size()>0?m_matrix[0].Size():0); }
   void              Resize(const int n,const int m);
   bool              Set(const int row,const int col,int d);
   int               Get(const int row,const int col) const { return(m_matrix[row][col]); }
   void              Fill(const int value);

   //--- operators
   CRowInt          *operator[](const int i) const;
   void              operator=(const CMatrixInt &m);
  };
//+------------------------------------------------------------------+
//| Constructor with two parameters                                  |
//+------------------------------------------------------------------+
CMatrixInt::CMatrixInt(const int rows,const int cols)
  {
   ArrayResizeAL(m_matrix,rows);
   for(int i=0; i<rows; i++)
      m_matrix[i].Resize(cols);
  }
//+------------------------------------------------------------------+
//| Resize                                                           |
//+------------------------------------------------------------------+
void CMatrixInt::Resize(const int n,const int m)
  {
//--- check
   if(n<0 || m<0)
      return;

//--- change sizes
   ArrayResizeAL(m_matrix,n);
   for(int i=0; i<n; i++)
      m_matrix[i].Resize(m);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMatrixInt::Set(const int row,const int col,int d)
  {
   if(row>=ArraySize(m_matrix))
      return(false);
   if(col>=m_matrix[row].Size())
      return(false);

   m_matrix[row].Set(col,d);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMatrixInt::Fill(const int value)
  {
   int size=Size();

   for(int i=0; i<size; i++)
      m_matrix[i].Fill(value);
  }
//+------------------------------------------------------------------+
//| Indexing operator                                                |
//+------------------------------------------------------------------+
CRowInt *CMatrixInt::operator[](int i) const
  {
   return(GetPointer(m_matrix[i]));
  }
//+------------------------------------------------------------------+
//| Overloading (=)                                                  |
//+------------------------------------------------------------------+
void CMatrixInt::operator=(const CMatrixInt &m)
  {
   int rows=m.Size();
//--- check
   if(rows==0)
      return;

   int cols=m[0].Size();
//--- check
   if(cols==0)
      return;

//--- change size
   ArrayResizeAL(m_matrix,rows);
   for(int i=0; i<rows; i++)
      m_matrix[i].Resize(cols);

//--- copy
   for(int i=0; i<rows; i++)
      m_matrix[i]=m[i];
  }

//+------------------------------------------------------------------+
//| Matrix (complex)                                                 |
//+------------------------------------------------------------------+
class CMatrixComplex
  {
private:
   matrix<complex>   m_matrix;

public:
   //--- constructors, destructor
                     CMatrixComplex(void) {}
                     CMatrixComplex(const ulong rows)                  { m_matrix.Resize(rows,1); }
                     CMatrixComplex(const ulong rows,const ulong cols) { m_matrix.Resize(rows,cols);}
                     CMatrixComplex(matrix<complex> &mat)              { m_matrix=mat; }
                    ~CMatrixComplex(void) {}

   //--- methods
   int               Size(void) const                                  { return((int)m_matrix.Rows()); }
   int               Rows(void) const                                  { return((int)m_matrix.Rows()); }
   int               Cols(void) const                                  { return((int)m_matrix.Cols()); }
   bool              Col(const ulong col,vector<complex> &vect)        { return m_matrix.Col(vect,col); }
   vector<complex>   Col(const ulong col)                              { return m_matrix.Col(col); }
   bool              Resize(const ulong n,const ulong m)               { return(m_matrix.Resize(n,m)); }
   bool              Set(const ulong row,const ulong col,complex d);
   complex           Get(const ulong row,const ulong col) const        { return m_matrix[row][col]; }
   bool              Set(const ulong row,const ulong col,const double d);
   bool              Set(const ulong row,const ulong col,const int d);
   bool              SetRe(const ulong row,const ulong col,const double d);
   bool              SetIm(const ulong row,const ulong col,const double d);
   bool              Mul(const ulong row,const ulong col,const double d);
   bool              Mul(const ulong row,const ulong col,const int d);
   matrix<complex>   TriU(const long diag=0) const                     { return (m_matrix.TriU(diag)); }
   matrix<complex>   TriL(const long diag=0) const                     { return (m_matrix.TriL(diag)); }
   matrix<complex>   ToMatrix(void) const                              { return (m_matrix); }

   //--- operators
   const vector<complex> operator[](const ulong i) const { return(m_matrix.Row(i)); }
   void              operator=(const CMatrixComplex &m)  { m_matrix=m.m_matrix;  }
   void              operator=(const matrix<complex> &m) { m_matrix=m; }
   void              operator*=(const double value)      { m_matrix*=value; }
  };
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixComplex::Set(const ulong row,const ulong col,complex d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]=d;

   return(true);
  }
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixComplex::Set(const ulong row,const ulong col,double d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]=d+0i;

   return(true);
  }
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixComplex::Set(const ulong row,const ulong col,int d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]=(double)d+0i;

   return(true);
  }
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixComplex::SetRe(const ulong row,const ulong col,const double d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col].real=d;

   return(true);
  }
//+------------------------------------------------------------------+
//| Set value                                                        |
//+------------------------------------------------------------------+
bool CMatrixComplex::SetIm(const ulong row,const ulong col,const double d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col].imag=d;

   return(true);
  }
//+------------------------------------------------------------------+
//| Multiplicate value                                               |
//+------------------------------------------------------------------+
bool CMatrixComplex::Mul(const ulong row,const ulong col,double d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]*=d+0i;

   return(true);
  }
//+------------------------------------------------------------------+
//| Multiplicate value                                               |
//+------------------------------------------------------------------+
bool CMatrixComplex::Mul(const ulong row,const ulong col,int d)
  {
   if(row>=m_matrix.Rows() || col>=m_matrix.Cols())
      return(false);

   m_matrix[row][col]*=(double)d+0i;

   return(true);
  }
//+------------------------------------------------------------------+
