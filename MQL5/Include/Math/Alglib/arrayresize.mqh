//+------------------------------------------------------------------+
//|                                                  arrayresize.mqh |
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

//--- forward declaration
class CRowInt;

//+------------------------------------------------------------------+
//| ArrayResizeAL for Alglib library with MQL5 features              |
//+------------------------------------------------------------------+
template<typename T>
int ArrayResizeAL(T &arr[],const int size)
  {
   int old=ArraySize(arr);
   int res=ArrayResize(arr,size);
//--- fill array if necessary
   if(res>0 && old<size)
      ArrayFill(arr,old,size-old,(T)0);
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| ArrayResizeAL for Alglib library with MQL5 features              |
//+------------------------------------------------------------------+
int ArrayResizeAL(bool &arr[],const int size)
  {
   int old=ArraySize(arr);
   int res=ArrayResize(arr,size);
//--- fill array if necessary
   if(res>0 && old<size)
      ArrayFill(arr,old,size-old,false);
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| ArrayResizeAL for Alglib library with MQL5 features              |
//+------------------------------------------------------------------+
int ArrayResizeAL(string &arr[],const int size)
  {
   return(ArrayResize(arr,size));
  }
//+------------------------------------------------------------------+
//| ArrayResizeAL for Alglib library with MQL4 and MQL5 features     |
//+------------------------------------------------------------------+
int ArrayResizeAL(CRowInt &arr[],const int size)
  {
   return(ArrayResize(arr,size));
  }
//+------------------------------------------------------------------+
