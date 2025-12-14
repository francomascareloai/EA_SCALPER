//+------------------------------------------------------------------+
//|                                                   alglibmisc.mqh |
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
#include "ap.mqh"
#include "alglibinternal.mqh"
//+------------------------------------------------------------------+
//| Buffer object which is used to perform nearest neighbor requests |
//| in the multithreaded mode (multiple threads working with same    |
//| KD-tree object).                                                 |
//| This object should be created with KDTreeCreateRequestBuffer().  |
//+------------------------------------------------------------------+
class CKDTreeRequestBuffer
  {
public:
   int               m_kneeded;
   int               m_kcur;
   bool              m_selfmatch;
   double            m_rneeded;
   double            m_approxf;
   double            m_curdist;
   //--- arrays
   CRowInt           m_idx;
   CRowDouble        m_x;
   CRowDouble        m_boxmin;
   CRowDouble        m_boxmax;
   CRowDouble        m_r;
   CRowDouble        m_buf;
   CRowDouble        m_curboxmin;
   CRowDouble        m_curboxmax;
   //--- constructor, destructor
                     CKDTreeRequestBuffer(void) { Init(); }
                    ~CKDTreeRequestBuffer(void) {}
   void              Init(void) { m_kneeded=0; m_kcur=0; m_selfmatch=false; m_rneeded=0; m_approxf=0; m_curdist=0;}
   //--- copy
   void              Copy(const CKDTreeRequestBuffer &obj);
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CKDTreeRequestBuffer::Copy(const CKDTreeRequestBuffer &obj)
  {
   m_x=obj.m_x;
   m_boxmin=obj.m_boxmin;
   m_boxmax=obj.m_boxmax;
   m_kneeded=obj.m_kneeded;
   m_rneeded=obj.m_rneeded;
   m_selfmatch=obj.m_selfmatch;
   m_approxf=obj.m_approxf;
   m_kcur=obj.m_kcur;
   m_idx=obj.m_idx;
   m_r=obj.m_r;
   m_buf=obj.m_buf;
   m_curboxmin=obj.m_curboxmin;
   m_curboxmax=obj.m_curboxmax;
   m_curdist=obj.m_curdist;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CKDTree                          |
//+------------------------------------------------------------------+
class CKDTreeRequestBufferShell
  {
private:
   CKDTreeRequestBuffer m_innerobj;

public:
   //--- constructors, destructor
                     CKDTreeRequestBufferShell(void) {}
                     CKDTreeRequestBufferShell(CKDTreeRequestBuffer &obj) { m_innerobj.Copy(obj); }
                    ~CKDTreeRequestBufferShell(void) {}
   //--- method
   CKDTreeRequestBuffer *GetInnerObj(void) { return(GetPointer(m_innerobj)); }
  };
//+------------------------------------------------------------------+
//| KD-trees                                                         |
//+------------------------------------------------------------------+
class CKDTree
  {
public:
   int               m_n;
   int               m_nx;
   int               m_ny;
   int               m_normtype;
   int               m_debugcounter;
   //--- arrays
   CRowInt           m_tags;
   CRowDouble        m_boxmin;
   CRowDouble        m_boxmax;
   CRowInt           m_nodes;
   CRowDouble        m_splits;
   //--- buffer
   CKDTreeRequestBuffer m_innerbuf;
   //--- matrix
   CMatrixDouble     m_xy;
   //--- constructor, destructor
                     CKDTree(void) { m_n=0; m_nx=0; m_ny=0; m_normtype=0; m_debugcounter=0; }
                    ~CKDTree(void) {}
   //--- copy
   void              Copy(const CKDTree &obj);
   //--- override
   void              operator=(const CKDTree &obj) { Copy(obj); }
  };
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CKDTree::Copy(const CKDTree &obj)
  {
//--- copy variables
   m_n=obj.m_n;
   m_nx=obj.m_nx;
   m_ny=obj.m_ny;
   m_normtype=obj.m_normtype;
   m_innerbuf.Copy(obj.m_innerbuf);
   m_debugcounter=obj.m_debugcounter;
//--- copy arrays
   m_tags=obj.m_tags;
   m_boxmin=obj.m_boxmin;
   m_boxmax=obj.m_boxmax;
   m_nodes=obj.m_nodes;
   m_splits=obj.m_splits;
//--- copy matrix
   m_xy=obj.m_xy;
  }
//+------------------------------------------------------------------+
//| This class is a shell for class CKDTree                          |
//+------------------------------------------------------------------+
class CKDTreeShell
  {
private:
   CKDTree           m_innerobj;

public:
   //--- constructors, destructor
                     CKDTreeShell(void) {}
                     CKDTreeShell(CKDTree &obj) { m_innerobj.Copy(obj); }
                    ~CKDTreeShell(void) {}
   //--- method
   CKDTree          *GetInnerObj(void) { return(GetPointer(m_innerobj)); }
  };
//+------------------------------------------------------------------+
//| Build KD-trees                                                   |
//+------------------------------------------------------------------+
class CNearestNeighbor
  {
public:
   //--- class constants
   static const int  m_splitnodesize;
   static const int  m_kdtreefirstversion;

   //--- build
   static void       KDTreeBuild(CMatrixDouble &xy,const int n,const int nx,const int ny,const int normtype,CKDTree &kdt);
   static void       KDTreeBuildTagged(CMatrixDouble &xy,int &tags[],const int n,const int nx,const int ny,const int normtype,CKDTree &kdt);
   static void       KDTreeBuildTagged(CMatrixDouble &xy,CRowInt &tags,const int n,const int nx,const int ny,const int normtype,CKDTree &kdt);
   static void       KDTreeCreateRequestBuffer(CKDTree &kdt,CKDTreeRequestBuffer &buf);
   static int        KDTreeQueryKNN(CKDTree &kdt,double &x[],const int k,const bool selfmatch=true);
   static int        KDTreeQueryKNN(CKDTree &kdt,CRowDouble &x,const int k,const bool selfmatch=true);
   static int        KDTreeTsQueryKNN(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &x,int k,bool selfmatch=true);
   static int        KDTreeQueryRNN(CKDTree &kdt,double &x[],const double r,const bool selfmatch=true);
   static int        KDTreeQueryRNN(CKDTree &kdt,CRowDouble &x,const double r,const bool selfmatch=true);
   static int        KDTreeQueryRNNU(CKDTree &kdt,double &x[],const double r,const bool selfmatch=true);
   static int        KDTreeQueryRNNU(CKDTree &kdt,CRowDouble &x,const double r,const bool selfmatch=true);
   static int        KDTreeTsQueryRNN(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &x,const double r,const bool selfmatch=true);
   static int        KDTreeTsQueryRNNU(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &x,const double r,const bool selfmatch=true);
   static int        KDTreeQueryAKNN(CKDTree &kdt,double &x[],int k,const bool selfmatch=true,const double eps=0);
   static int        KDTreeQueryAKNN(CKDTree &kdt,CRowDouble &x,int k,const bool selfmatch=true,const double eps=0);
   static int        KDTreeTsQueryAKNN(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &x,int k,const bool selfmatch=true,const double eps=0);
   static int        KDTreeQueryBox(CKDTree &kdt,double &boxmin[],double &boxmax[]);
   static int        KDTreeQueryBox(CKDTree &kdt,CRowDouble &boxmin,CRowDouble &boxmax);
   static int        KDTreeTsQueryBox(CKDTree &kdt,CKDTreeRequestBuffer &buf,double &boxmin[],double &boxmax[]);
   static int        KDTreeTsQueryBox(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &boxmin,CRowDouble &boxmax);
   static void       KDTreeQueryResultsX(CKDTree &kdt,CMatrixDouble &x);
   static void       KDTreeTsQueryResultsX(CKDTree &kdt,CKDTreeRequestBuffer &buf,CMatrixDouble &x);
   static void       KDTreeQueryResultsXY(CKDTree &kdt,CMatrixDouble &xy);
   static void       KDTreeTsQueryResultsXY(CKDTree &kdt,CKDTreeRequestBuffer &buf,CMatrixDouble &xy);
   static void       KDTreeQueryResultsTags(CKDTree &kdt,int &tags[]);
   static void       KDTreeQueryResultsTags(CKDTree &kdt,CRowInt &tags);
   static void       KDTreeTsQueryResultsTags(CKDTree &kdt,CKDTreeRequestBuffer &buf,int &tags[]);
   static void       KDTreeTsQueryResultsTags(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowInt &tags);
   static void       KDTreeQueryResultsDistances(CKDTree &kdt,double &r[]);
   static void       KDTreeQueryResultsDistances(CKDTree &kdt,CRowDouble &r);
   static void       KDTreeTsQueryResultsDistances(CKDTree &kdt,CKDTreeRequestBuffer &buf,double &r[]);
   static void       KDTreeTsQueryResultsDistances(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &r);
   static void       KDTreeQueryResultsXI(CKDTree &kdt,CMatrixDouble &x);
   static void       KDTreeQueryResultsXYI(CKDTree &kdt,CMatrixDouble &xy);
   static void       KDTreeQueryResultsTagsI(CKDTree &kdt,int &tags[]);
   static void       KDTreeQueryResultsTagsI(CKDTree &kdt,CRowInt &tags);
   static void       KDTreeQueryResultsDistancesI(CKDTree &kdt,double &r[]);
   static void       KDTreeQueryResultsDistancesI(CKDTree &kdt,CRowDouble &r);
   //--- information
   static void       KDTreeExploreBox(CKDTree &kdt,CRowDouble &boxmin,CRowDouble &boxmax);
   static void       KDTreeExploreNodeType(CKDTree &kdt,int node,int &nodetype);
   static void       KDTreeExploreLeaf(CKDTree &kdt,int node,CMatrixDouble &xy,int &k);
   static void       KDTreeExploreSplit(CKDTree &kdt,int node,int &d,double &s,int &nodele,int &nodege);
   //--- serialize
   static void       KDTreeAlloc(CSerializer &s,CKDTree &tree);
   static void       KDTreeSerialize(CSerializer &s,CKDTree &tree);
   static void       KDTreeUnserialize(CSerializer &s,CKDTree &tree);

private:
   static int        TsQueryRNN(CKDTree &kdt,CKDTreeRequestBuffer &buf,CRowDouble &x,double r,bool selfmatch=true,bool orderedbydist=true);
   static bool       CheckRequestBufferConsistency(CKDTree &kdt,CKDTreeRequestBuffer &buf);
   static void       KDTreeSplit(CKDTree &kdt,const int i1,const int i2,const int d,const double s,int &i3);
   static void       KDTreeGenerateTreeRec(CKDTree &kdt,int &nodesoffs,int &splitsoffs,const int i1,const int i2,const int maxleafsize);
   static void       KDTreeQueryNNRec(CKDTree &kdt,const int offs);
   static void       KDTreeQueryNNRec(CKDTree &kdt,CKDTreeRequestBuffer &buf,const int offs);
   static void       KDTreeQueryBoxRec(CKDTree &kdt,CKDTreeRequestBuffer &buf,int offs);
   static void       KDTreeInitBox(CKDTree &kdt,CRowDouble &x,CKDTreeRequestBuffer &buf);
   static void       KDTreeAllocDataSetIndependent(CKDTree &kdt,const int nx,const int ny);
   static void       KDTreeAllocDataSetDependent(CKDTree &kdt,const int n,const int nx,const int ny);
  };
//+------------------------------------------------------------------+
//| Initialize constants                                             |
//+------------------------------------------------------------------+
const int CNearestNeighbor::m_splitnodesize=6;
const int CNearestNeighbor::m_kdtreefirstversion=0;
//+------------------------------------------------------------------+
//| KD-tree creation                                                 |
//| This subroutine creates KD-tree from set of X-values and optional|
//| Y-values                                                         |
//| INPUT PARAMETERS                                                 |
//|     XY      -   dataset, array[0..N-1,0..NX+NY-1].               |
//|                 one row corresponds to one point.                |
//|                 first NX columns contain X-values, next NY (NY   |
//|                 may be zero)                                     |
//|                 columns may contain associated Y-values          |
//|     N       -   number of points, N>=1                           |
//|     NX      -   space dimension, NX>=1.                          |
//|     NY      -   number of optional Y-values, NY>=0.              |
//|     NormType-   norm type:                                       |
//|                 * 0 denotes infinity-norm                        |
//|                 * 1 denotes 1-norm                               |
//|                 * 2 denotes 2-norm (Euclidean norm)              |
//| OUTPUT PARAMETERS                                                |
//|     KDT     -   KD-tree                                          |
//| NOTES                                                            |
//| 1. KD-tree  creation  have O(N*logN) complexity and              |
//|    O(N*(2*NX+NY)) memory requirements.                           |
//| 2. Although KD-trees may be used with any combination of N and   |
//|    NX, they are more efficient than brute-force search only when |
//|    N >> 4^NX. So they are most useful in low-dimensional tasks   |
//|    (NX=2, NX=3). NX=1  is another inefficient case, because      |
//|    simple  binary  search  (without  additional structures) is   |
//|    much more efficient in such tasks than KD-trees.              |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeBuild(CMatrixDouble &xy,const int n,
                                   const int nx,const int ny,
                                   const int normtype,CKDTree &kdt)
  {
   int tags[];
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": N<0!"))
      return;
//--- check
   if(!CAp::Assert(nx>=1,__FUNCTION__+": NX<1!"))
      return;
//--- check
   if(!CAp::Assert(ny>=0,__FUNCTION__+": NY<0!"))
      return;
//--- check
   if(!CAp::Assert(normtype>=0 && normtype<=2,__FUNCTION__+": incorrect NormType!"))
      return;
//--- check
   if(!CAp::Assert((int)CAp::Rows(xy)>=n,__FUNCTION__+": rows(X)<N!"))
      return;
//--- check
   if(!CAp::Assert((int)CAp::Cols(xy)>=nx+ny,__FUNCTION__+": cols(X)<NX+NY!"))
      return;
//--- check
   if(!CAp::Assert(CApServ::IsFiniteMatrix(xy,n,nx+ny),__FUNCTION__+": X contains infinite or NaN values!"))
      return;
//--- allocation
   ArrayResizeAL(tags,n);
   ArrayInitialize(tags,0);
//--- function call
   KDTreeBuildTagged(xy,tags,n,nx,ny,normtype,kdt);
  }
//+------------------------------------------------------------------+
//| KD-tree creation                                                 |
//| This subroutine creates KD-tree from set of X-values, integer    |
//| tags and optional Y-values                                       |
//| INPUT PARAMETERS                                                 |
//|     XY      -   dataset, array[0..N-1,0..NX+NY-1].               |
//|                 one row corresponds to one point.                |
//|                 first NX columns contain X-values, next NY (NY   |
//|                 may be zero)                                     |
//|                 columns may contain associated Y-values          |
//|     Tags    -   tags, array[0..N-1], contains integer tags       |
//|                 associated with points.                          |
//|     N       -   number of points, N>=1                           |
//|     NX      -   space dimension, NX>=1.                          |
//|     NY      -   number of optional Y-values, NY>=0.              |
//|     NormType-   norm type:                                       |
//|                 * 0 denotes infinity-norm                        |
//|                 * 1 denotes 1-norm                               |
//|                 * 2 denotes 2-norm (Euclidean norm)              |
//| OUTPUT PARAMETERS                                                |
//|     KDT     -   KD-tree                                          |
//| NOTES                                                            |
//| 1. KD-tree  creation  have O(N*logN) complexity and              |
//|    O(N*(2*NX+NY)) memory requirements.                           |
//| 2. Although KD-trees may be used with any combination of N and   |
//|    NX, they are more efficient than brute-force search only when |
//|    N >> 4^NX. So they are most useful in low-dimensional tasks   |
//|    (NX=2, NX=3). NX=1 is another inefficient case, because simple|
//|    binary search (without additional structures) is much more    |
//|    efficient in such tasks than KD-trees.                        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeBuildTagged(CMatrixDouble &xy,int &tags[],
                                         const int n,const int nx,
                                         const int ny,
                                         const int normtype,CKDTree &kdt)
  {
   CRowInt Tags=tags;
   KDTreeBuildTagged(xy,Tags,n,nx,ny,normtype,kdt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeBuildTagged(CMatrixDouble &xy,CRowInt &tags,
                                         const int n,const int nx,
                                         const int ny,
                                         const int normtype,CKDTree &kdt)
  {
   int i=0;
   int j=0;
   int nodesoffs=0;
   int splitsoffs=0;
   int i_=0;
   int i1_=0;
//--- check
   if(!CAp::Assert(n>=0,__FUNCTION__+": N<0!"))
      return;
//--- check
   if(!CAp::Assert(nx>=1,__FUNCTION__+": NX<1!"))
      return;
//--- check
   if(!CAp::Assert(ny>=0,__FUNCTION__+": NY<0!"))
      return;
//--- check
   if(!CAp::Assert(normtype>=0 && normtype<=2,__FUNCTION__+": incorrect NormType!"))
      return;
//--- check
   if(!CAp::Assert((int)CAp::Rows(xy)>=n,__FUNCTION__+": rows(X)<N!"))
      return;
//--- check
   if(!CAp::Assert((int)CAp::Cols(xy)>=nx+ny || n==0,__FUNCTION__+": cols(X)<NX+NY!"))
      return;
//--- check
   if(!CAp::Assert(CApServ::IsFiniteMatrix(xy,n,nx+ny),__FUNCTION__+": X contains infinite or NaN values!"))
      return;
//--- initialize
   kdt.m_n=n;
   kdt.m_nx=nx;
   kdt.m_ny=ny;
   kdt.m_normtype=normtype;
   kdt.m_innerbuf.m_kcur=0;
   kdt.m_debugcounter=0;
//--- N=0 => quick exit
   if(n==0)
      return;
//--- Allocate
   KDTreeAllocDataSetIndependent(kdt,nx,ny);
   KDTreeAllocDataSetDependent(kdt,n,nx,ny);
   KDTreeCreateRequestBuffer(kdt,kdt.m_innerbuf);
//--- Initial fill
   for(i_=0; i_<nx; i_++)
     {
      vector<double> col=xy.Col(i_);
      kdt.m_xy.Col(i_,col);
     }
   i1_=-nx;
   for(i_=nx; i_<2*nx+ny; i_++)
     {
      vector<double> col=xy.Col(i_+i1_);
      kdt.m_xy.Col(i_,col);
     }
   kdt.m_tags=tags;
//--- Determine bounding box
   kdt.m_boxmin=kdt.m_xy.Min(0)+0;
   kdt.m_boxmax=kdt.m_xy.Max(0)+0;
   kdt.m_boxmin.Resize(kdt.m_nx);
   kdt.m_boxmax.Resize(kdt.m_nx);
//--- prepare tree structure
//--- * MaxNodes=N because we guarantee no trivial splits,i.e.
//---   every split will generate two non-empty boxes
//--- allocation
   nodesoffs=0;
   splitsoffs=0;
   kdt.m_innerbuf.m_curboxmin=kdt.m_boxmin;
   kdt.m_innerbuf.m_curboxmax=kdt.m_boxmax;
//--- function call
   KDTreeGenerateTreeRec(kdt,nodesoffs,splitsoffs,0,n,8);
   kdt.m_nodes.Resize(nodesoffs);
   kdt.m_splits.Resize(splitsoffs);
  }
//+------------------------------------------------------------------+
//| This function creates buffer structure which can be used         |
//| to perform parallel KD-tree requests.                            |
//| KD-tree subpackage provides two sets of request functions - ones |
//| which use internal buffer of KD-tree object (these functions are |
//| single-threaded because they use same buffer, which can not      |
//| shared between threads), and ones which use external buffer.     |
//| This function is used to initialize external buffer.             |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree which is associated with newly created buffer |
//| OUTPUT PARAMETERS                                                |
//|   Buf   -  external buffer.                                      |
//| IMPORTANT: KD-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt      |
//|            to use buffer with different object is dangerous - you|
//|            may get integrity check failure (exception) because   |
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeCreateRequestBuffer(CKDTree &kdt,
                                                 CKDTreeRequestBuffer &buf)
  {
   buf.m_x.Resize(kdt.m_nx);
   buf.m_boxmin.Resize(kdt.m_nx);
   buf.m_boxmax.Resize(kdt.m_nx);
   buf.m_idx.Resize(kdt.m_n);
   buf.m_r.Resize(kdt.m_n);
   buf.m_buf.Resize(MathMax(kdt.m_n,kdt.m_nx));
   buf.m_curboxmin.Resize(kdt.m_nx);
   buf.m_curboxmax.Resize(kdt.m_nx);
   buf.m_kcur=0;
  }
//+------------------------------------------------------------------+
//| K-NN query: K nearest neighbors                                  |
//| INPUT PARAMETERS                                                 |
//|     KDT         -   KD-tree                                      |
//|     X           -   point, array[0..NX-1].                       |
//|     K           -   number of neighbors to return, K>=1          |
//|     SelfMatch   -   whether self-matches are allowed:            |
//|                     * if True, nearest neighbor may be the point |
//|                       itself (if it exists in original dataset)  |
//|                     * if False, then only points with non-zero   |
//|                       distance are returned                      |
//|                     * if not given, considered True              |
//| RESULT                                                           |
//|     number of actual neighbors found (either K or N, if K>N).    |
//| This  subroutine performs query and stores its result in the     |
//| internal structures of the KD-tree. You can use following        |
//| subroutines to obtain these results:                             |
//| * KDTreeQueryResultsX() to get X-values                          |
//| * KDTreeQueryResultsXY() to get X- and Y-values                  |
//| * KDTreeQueryResultsTags() to get tag values                     |
//| * KDTreeQueryResultsDistances() to get distances                 |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryKNN(CKDTree &kdt,double &x[],
                                     const int k,const bool selfmatch)
  {
//--- check
   if(!CAp::Assert(k>=1,__FUNCTION__+": K<1!"))
      return(-1);
//--- check
   if(!CAp::Assert(CAp::Len(x)>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(x,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(KDTreeQueryAKNN(kdt,x,k,selfmatch,0.0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryKNN(CKDTree &kdt,CRowDouble &x,
                                     const int k,const bool selfmatch)
  {
//--- check
   if(!CAp::Assert(k>=1,__FUNCTION__+": K<1!"))
      return(-1);
//--- check
   if(!CAp::Assert(CAp::Len(x)>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(x,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(KDTreeQueryAKNN(kdt,x,k,selfmatch,0.0));
  }
//+------------------------------------------------------------------+
//| K-NN query: K nearest neighbors, using external thread-local     |
//| buffer.                                                          |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  kd-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure with                    |
//|            KDTreeCreateRequestBuffer() function.                |
//|   X     -  point, array[0..NX-1].                                |
//|   K     -  number of neighbors to return, K>=1                   |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|                  * if True, nearest neighbor may be the point    |
//|                    itself (if it exists in original dataset)     |
//|                  * if False, then only points with non-zero      |
//|                    distance are returned                         |
//|                  * if not given, considered True                 |
//| RESULT                                                           |
//|   number of actual neighbors found (either K or N, if K>N).      |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "buf" in   |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() to get distances             |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//| which was used to initialize buffer. Any attempt to use biffer   |
//| with different object is dangerous - you may get integrity check |
//| failure (exception) because sizes of internal arrays do not fit  |
//| to dimensions of KD-tree structure.                              |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryKNN(CKDTree &kdt,
                                       CKDTreeRequestBuffer &buf,
                                       CRowDouble &x,
                                       int k,
                                       bool selfmatch=true)
  {
//--- check
   if(!CAp::Assert(k>=1,__FUNCTION__+": K<1!"))
      return(-1);
//--- check
   if(!CAp::Assert(CAp::Len(x)>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(x,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(KDTreeTsQueryAKNN(kdt,buf,x,k,selfmatch,0.0));
  }
//+------------------------------------------------------------------+
//| R-NN query: all points within R-sphere centered at X             |
//| INPUT PARAMETERS                                                 |
//|     KDT         -   KD-tree                                      |
//|     X           -   point, array[0..NX-1].                       |
//|     R           -   radius of sphere (in corresponding norm), R>0|
//|     SelfMatch   -   whether self-matches are allowed:            |
//|                     * if True, nearest neighbor may be the point |
//|                       itself (if it exists in original dataset)  |
//|                     * if False, then only points with non-zero   |
//|                       distance are returned                      |
//|                     * if not given, considered True              |
//| RESULT                                                           |
//|     number of neighbors found, >=0                               |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the KD-tree. You can use following        |
//| subroutines to obtain actual results:                            |
//| * KDTreeQueryResultsX() to get X-values                          |
//| * KDTreeQueryResultsXY() to get X- and Y-values                  |
//| * KDTreeQueryResultsTags() to get tag values                     |
//| * KDTreeQueryResultsDistances() to get distances                 |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryRNN(CKDTree &kdt,double &x[],
                                     const double r,const bool selfmatch=true)
  {
   CRowDouble vec=x;
//--- return result
   return(KDTreeQueryRNN(kdt,vec,r,selfmatch));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryRNN(CKDTree &kdt,CRowDouble &x,
                                     const double r,const bool selfmatch=true)
  {
//--- check
   if(!CAp::Assert((double)(r)>0.0,__FUNCTION__+": incorrect R!"))
      return(-1);
//--- check
   if(!CAp::Assert((int)x.Size()>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   CRowDouble X=x;
   if(!CAp::Assert(CApServ::IsFiniteVector(X,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(KDTreeTsQueryRNN(kdt,kdt.m_innerbuf,x,r,selfmatch));
  }
//+------------------------------------------------------------------+
//| R-NN query: all points within R-sphere centered at X, no ordering|
//| by distance as undicated by "U" suffix (faster that ordered      |
//| query, for large queries - significantly faster).                |
//| IMPORTANT: this function can not be used in multithreaded code   |
//|            because it uses internal temporary buffer of kd-tree  |
//|            object, which can not be shared between multiple      |
//|            threads. If you want to perform parallel requests, use|
//|            function which uses external request buffer:          |
//|            KDTreeTsQueryRNN() ("Ts" stands for "thread-safe").   |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   X     -  point, array[0..NX-1].                                |
//|   R     -  radius of sphere (in corresponding norm), R>0         |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|                  * if True, nearest neighbor may be the point    |
//|                    itself (if it exists in original dataset)     |
//|                  * if False, then only points with non-zero      |
//|                    distance are returned                         |
//|                  * if not given, considered True                 |
//| RESULT                                                           |
//|   number of neighbors found, >=0                                 |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the KD-tree. You can use following        |
//| subroutines to obtain actual results:                            |
//|   * KDTreeQueryResultsX() to get X-values                        |
//|   * KDTreeQueryResultsXY() to get X- and Y-values                |
//|   * KDTreeQueryResultsTags() to get tag values                   |
//|   * KDTreeQueryResultsDistances() to get distances               |
//| As indicated by "U" suffix, this function returns unordered      |
//| results.                                                         |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryRNNU(CKDTree &kdt,
                                      double &x[],
                                      double r,
                                      bool selfmatch=true)
  {
   CRowDouble vec=x;
//--- return result
   return(KDTreeQueryRNNU(kdt,vec,r,selfmatch));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryRNNU(CKDTree &kdt,
                                      CRowDouble &x,
                                      double r,
                                      bool selfmatch=true)
  {
//--- check
   if(!CAp::Assert(r>0.0,__FUNCTION__+": incorrect R!"))
      return(-1);
//--- check
   if(!CAp::Assert((int)x.Size()>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   CRowDouble X=x;
   if(!CAp::Assert(CApServ::IsFiniteVector(X,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(KDTreeTsQueryRNNU(kdt,kdt.m_innerbuf,x,r,selfmatch));
  }
//+------------------------------------------------------------------+
//| R-NN query: all points within  R-sphere  centered  at  X,  using |
//| external thread-local buffer, sorted by distance between point   |
//| and X (by ascending)                                             |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| NOTE: it is also possible to perform undordered queries performed|
//| by means of KDTreeQueryRNNU() and KDTreeTsQueryRNNU() functions. |
//| Such queries are faster because we do not have to use heap       |
//| structure for sorting.                                           |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure with                    |
//|            KDTreeCreateRequestBuffer() function.                 |
//|   X     -  point, array[0..NX-1].                                |
//|   R     -  radius of sphere (in corresponding norm), R>0         |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|            * if True, nearest neighbor may be the point itself   |
//|              (if it exists in original dataset)                  |
//|            * if False, then only points with non-zero distance   |
//|              are returned                                        |
//|            * if not given, considered True                       |
//| RESULT                                                           |
//|   number of neighbors found, >=0                                 |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "buf" in   |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() to get distances             |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt to   |
//|            use biffer with different object is dangerous - you   |
//|            may get integrity check failure (exception) because   |
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryRNN(CKDTree &kdt,
                                       CKDTreeRequestBuffer &buf,
                                       CRowDouble &x,
                                       const double r,
                                       const bool selfmatch=true)
  {
//--- check
   if(!CAp::Assert(MathIsValidNumber(r) && r>0.0,__FUNCTION__+": incorrect R!"))
      return(-1);
//--- check
   if(!CAp::Assert((int)x.Size()>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   CRowDouble X=x;
   if(!CAp::Assert(CApServ::IsFiniteVector(X,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(TsQueryRNN(kdt,buf,x,r,selfmatch,true));
  }
//+------------------------------------------------------------------+
//| R-NN query: all points within R-sphere centered at X, using      |
//| external thread-local buffer, no ordering by distance as         |
//| undicated by "U" suffix (faster that ordered query, for large    |
//| queries - significantly faster).                                 |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure with                    |
//|            KDTreeCreateRequestBuffer() function.                 |
//|   X     -  point, array[0..NX-1].                                |
//|   R     -  radius of sphere (in corresponding norm), R>0         |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|               * if True, nearest neighbor may be the point itself|
//|                 (if it exists in original dataset)               |
//|               * if False, then only points with non-zero distance|
//|                 are returned                                     |
//|               * if not given, considered True                    |
//| RESULT                                                           |
//|   number of neighbors found, >=0                                 |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "buf" in   |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() to get distances             |
//| As indicated by "U" suffix, this function returns unordered      |
//| results.                                                         |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt to   |
//|            use biffer with different object is dangerous - you   |
//|            may get integrity check failure (exception) because   |
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryRNNU(CKDTree &kdt,
                                        CKDTreeRequestBuffer &buf,
                                        CRowDouble &x,
                                        const double r,
                                        const bool selfmatch=true)
  {
//--- check
   if(!CAp::Assert(MathIsValidNumber(r) && r>0.0,__FUNCTION__+": incorrect R!"))
      return(-1);
//--- check
   if(!CAp::Assert((int)x.Size()>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   CRowDouble X=x;
   if(!CAp::Assert(CApServ::IsFiniteVector(X,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- return result
   return(TsQueryRNN(kdt,buf,x,r,selfmatch,false));
  }
//+------------------------------------------------------------------+
//| K-NN query: approximate K nearest neighbors                      |
//| INPUT PARAMETERS                                                 |
//|     KDT         -   KD-tree                                      |
//|     X           -   point, array[0..NX-1].                       |
//|     K           -   number of neighbors to return, K>=1          |
//|     SelfMatch   -   whether self-matches are allowed:            |
//|                     * if True, nearest neighbor may be the point |
//|                       itself (if it exists in original dataset)  |
//|                     * if False, then only points with non-zero   |
//|                       distance are returned                      |
//|                     * if not given, considered True              |
//|     Eps         -   approximation factor, Eps>=0. eps-approximate|
//|                     nearest neighbor is a neighbor whose distance|
//|                     from X is at most (1+eps) times distance of  |
//|                     true nearest neighbor.                       |
//| RESULT                                                           |
//|     number of actual neighbors found (either K or N, if K>N).    |
//| NOTES                                                            |
//|     significant performance gain may be achieved only when Eps is|
//|     on the order of magnitude of 1 or larger.                    |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the KD-tree. You can use following        |
//| these subroutines to  obtain results:                            |
//| * KDTreeQueryResultsX() to get X-values                          |
//| * KDTreeQueryResultsXY() to get X- and Y-values                  |
//| * KDTreeQueryResultsTags() to get tag values                     |
//| * KDTreeQueryResultsDistances() to get distances                 |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryAKNN(CKDTree &kdt,double &x[],
                                      int k,const bool selfmatch=true,
                                      const double eps=0)
  {
   CRowDouble vec=x;
//--- return result
   return(KDTreeTsQueryAKNN(kdt,kdt.m_innerbuf,vec,k,selfmatch,eps));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryAKNN(CKDTree &kdt,CRowDouble &x,
                                      int k,const bool selfmatch=true,
                                      const double eps=0)
  {
   return(KDTreeTsQueryAKNN(kdt,kdt.m_innerbuf,x,k,selfmatch,eps));
  }
//+------------------------------------------------------------------+
//| K-NN query: approximate K nearest neighbors, using thread-local  |
//| buffer.                                                          |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure with                    |
//|            KDTreeCreateRequestBuffer() function.                 |
//|   X     -  point, array[0..NX-1].                                |
//|   K     -  number of neighbors to return, K>=1                   |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|               * if True, nearest neighbor may be the point itself|
//|                 (if it exists in original dataset)               |
//|               * if False, then only points with non-zero distance|
//|                 are returned                                     |
//|               * if not given, considered True                    |
//|   Eps   -  approximation factor, Eps>=0. eps-approximate nearest |
//|            neighbor is a neighbor whose distance from X is at    |
//|            most (1+eps) times distance of true nearest neighbor. |
//| RESULT                                                           |
//|   number of actual neighbors found (either K or N, if K>N).      |
//| NOTES                                                            |
//|   significant performance gain may be achieved only when Eps is  |
//|   on the order of magnitude of 1 or larger.                      |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "buf" in   |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() to get distances             |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt to   |
//|            use biffer with different object is dangerous - you   |
//|            may get integrity check failure (exception) because   |
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryAKNN(CKDTree &kdt,
                                        CKDTreeRequestBuffer &buf,
                                        CRowDouble &x,
                                        int k,
                                        bool selfmatch=true,
                                        double eps=0)
  {
   int result=0;
   int i=0;
   int j=0;
//--- check
   if(!CAp::Assert(k>0,__FUNCTION__+": incorrect K!"))
      return(-1);
//--- check
   if(!CAp::Assert(eps>=0.0,__FUNCTION__+": incorrect Eps!"))
      return(-1);
//--- check
   if(!CAp::Assert((int)x.Size()>=kdt.m_nx,__FUNCTION__+": Length(X)<NX!"))
      return(-1);
//--- check
   CRowDouble X=x;
   if(!CAp::Assert(CApServ::IsFiniteVector(X,kdt.m_nx),__FUNCTION__+": X contains infinite or NaN values!"))
      return(-1);
//--- Handle special case: KDT.N=0
   if(kdt.m_n==0)
     {
      buf.m_kcur=0;
      return(0);
     }
//--- Check consistency of request buffer
   if(!CheckRequestBufferConsistency(kdt,buf))
      return(-1);
//--- Prepare parameters
   k=MathMin(k,kdt.m_n);
   buf.m_kneeded=k;
   buf.m_rneeded=0;
   buf.m_selfmatch=selfmatch;
   if(kdt.m_normtype==2)
     {
      buf.m_approxf=1/pow(1+eps,2);
     }
   else
     {
      buf.m_approxf=1/(1+eps);
     }
   buf.m_kcur=0;
//--- calculate distance from point to current bounding box
   KDTreeInitBox(kdt,x,buf);
//--- call recursive search
//--- results are returned as heap
   KDTreeQueryNNRec(kdt,buf,0);
//--- pop from heap to generate ordered representation
//--- last element is non pop'ed because it is already in its place
   result=buf.m_kcur;
   j=buf.m_kcur;
   for(i=buf.m_kcur; i>=2; i--)
      CTSort::TagHeapPopI(buf.m_r,buf.m_idx,j);
   return(result);
  }
//+------------------------------------------------------------------+
//| Box query: all points within user-specified box.                 |
//| IMPORTANT: this function can not be used in multithreaded code   |
//|            because it uses internal temporary buffer of kd-tree  |
//|            object, which can not be shared between multiple      |
//|            threads. If you want to perform parallel requests,    |
//|            use function which uses external request buffer:      |
//|            KDTreeTsQueryBox() ("Ts" stands for "thread-safe").   |
//| INPUT PARAMETERS                                                 |
//|   KDT      -  KD-tree                                            |
//|   BoxMin   -  lower bounds, array[0..NX-1].                      |
//|   BoxMax   -  upper bounds, array[0..NX-1].                      |
//| RESULT                                                           |
//|   number of actual neighbors found (in [0,N]).                   |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the KD-tree. You can use following        |
//| subroutines to obtain these results:                             |
//|   * KDTreeQueryResultsX() to get X-values                        |
//|   * KDTreeQueryResultsXY() to get X- and Y-values                |
//|   * KDTreeQueryResultsTags() to get tag values                   |
//|   * KDTreeQueryResultsDistances() returns zeros for this request |
//| NOTE: this particular query returns unordered results, because   |
//|       there is no meaningful way of ordering points. Furthermore,|
//|       no 'distance' is associated with points - it is either     |
//|       INSIDE or OUTSIDE (so request for distances will return    |
//|       zeros).                                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryBox(CKDTree &kdt,
                                     double &boxmin[],
                                     double &boxmax[])
  {
   return(KDTreeTsQueryBox(kdt,kdt.m_innerbuf,boxmin,boxmax));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeQueryBox(CKDTree &kdt,
                                     CRowDouble &boxmin,
                                     CRowDouble &boxmax)
  {
   return(KDTreeTsQueryBox(kdt,kdt.m_innerbuf,boxmin,boxmax));
  }
//+------------------------------------------------------------------+
//| Box query: all points within user-specified box, using           |
//| thread-local buffer.                                             |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| INPUT PARAMETERS                                                 |
//|   KDT      -  KD-tree                                            |
//|   Buf      -  request buffer object created for this particular  |
//|               instance of kd-tree structure with                 |
//|               KDTreeCreateRequestBuffer() function.              |
//|   BoxMin   -  lower bounds, array[0..NX-1].                      |
//|   BoxMax   -  upper bounds, array[0..NX-1].                      |
//| RESULT                                                           |
//|   number of actual neighbors found (in [0,N]).                   |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "ts" in    |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() returns zeros for this query |
//| NOTE: this particular query returns unordered results, because   |
//|       there is no meaningful way of ordering points. Furthermore,|
//|       no 'distance' is associated with points - it is either     |
//|       INSIDE  or OUTSIDE (so request for distances will return   |
//|       zeros).                                                    |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt to   |
//|            use biffer with different object is dangerous - you   |
//|            may  get  integrity  check failure (exception) because|
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryBox(CKDTree &kdt,
                                       CKDTreeRequestBuffer &buf,
                                       double &boxmin[],
                                       double &boxmax[])
  {
   int result=0;
//--- check
   if(!CAp::Assert(CAp::Len(boxmin)>=kdt.m_nx,__FUNCTION__+": Length(BoxMin)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CAp::Len(boxmax)>=kdt.m_nx,__FUNCTION__+": Length(BoxMax)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(boxmin,kdt.m_nx),__FUNCTION__+": BoxMin contains infinite or NaN values!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(boxmax,kdt.m_nx),__FUNCTION__+": BoxMax contains infinite or NaN values!"))
      return(-1);
//--- check consistency of request buffer
   if(!CheckRequestBufferConsistency(kdt,buf))
      return(-1);
//--- quick exit for degenerate boxes
   for(int j=0; j<kdt.m_nx; j++)
      if((double)(boxmin[j])>(double)(boxmax[j]))
        {
         buf.m_kcur=0;
         return(0);
        }
//--- prepare parameters
   buf.m_boxmin=boxmin;
   buf.m_boxmax=boxmax;
   buf.m_curboxmin=boxmin;
   buf.m_curboxmax=boxmax;
   buf.m_kcur=0;
//--- call recursive search
   KDTreeQueryBoxRec(kdt,buf,0);
   result=buf.m_kcur;
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNearestNeighbor::KDTreeTsQueryBox(CKDTree &kdt,
                                       CKDTreeRequestBuffer &buf,
                                       CRowDouble &boxmin,
                                       CRowDouble &boxmax)
  {
   int result=0;
//--- check
   if(!CAp::Assert(CAp::Len(boxmin)>=kdt.m_nx,__FUNCTION__+": Length(BoxMin)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CAp::Len(boxmax)>=kdt.m_nx,__FUNCTION__+": Length(BoxMax)<NX!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(boxmin,kdt.m_nx),__FUNCTION__+": BoxMin contains infinite or NaN values!"))
      return(-1);
//--- check
   if(!CAp::Assert(CApServ::IsFiniteVector(boxmax,kdt.m_nx),__FUNCTION__+": BoxMax contains infinite or NaN values!"))
      return(-1);
//--- check consistency of request buffer
   if(!CheckRequestBufferConsistency(kdt,buf))
      return(-1);
//--- quick exit for degenerate boxes
   for(int j=0; j<kdt.m_nx; j++)
      if((double)(boxmin[j])>(double)(boxmax[j]))
        {
         buf.m_kcur=0;
         return(0);
        }
//--- prepare parameters
   buf.m_boxmin=boxmin;
   buf.m_boxmax=boxmax;
   buf.m_curboxmin=boxmin;
   buf.m_curboxmax=boxmax;
   buf.m_kcur=0;
//--- call recursive search
   KDTreeQueryBoxRec(kdt,buf,0);
   result=buf.m_kcur;
   return(result);
  }
//+------------------------------------------------------------------+
//| X-values from last query                                         |
//| INPUT PARAMETERS                                                 |
//|     KDT     -   KD-tree                                          |
//|     X       -   possibly pre-allocated buffer. If X is too small |
//|                 to store result, it is resized. If size(X) is    |
//|                 enough to store result, it is left unchanged.    |
//| OUTPUT PARAMETERS                                                |
//|     X       -   rows are filled with X-values                    |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first =  |
//|    closest)                                                      |
//| 2. if  XY is larger than required to store result, only leading  |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//| same name and suffix 'I'.                                        |
//| SEE ALSO                                                         |
//| * KDTreeQueryResultsXY()            X- and Y-values              |
//| * KDTreeQueryResultsTags()          tag values                   |
//| * KDTreeQueryResultsDistances()     distances                    |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsX(CKDTree &kdt,CMatrixDouble &x)
  {
   KDTreeTsQueryResultsX(kdt,kdt.m_innerbuf,x);
  }
//+------------------------------------------------------------------+
//| X- and Y-values from last query                                  |
//| INPUT PARAMETERS                                                 |
//|     KDT     -   KD-tree                                          |
//|     XY      -   possibly pre-allocated buffer. If XY is too small|
//|                 to store result, it is resized. If size(XY) is   |
//|                 enough to store result, it is left unchanged.    |
//| OUTPUT PARAMETERS                                                |
//|     XY      -   rows are filled with points: first NX columns    |
//|                 with X-values, next NY columns - with Y-values.  |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first =  |
//|    closest)                                                      |
//| 2. if  XY is larger than required to store result, only leading  |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//| * KDTreeQueryResultsX()             X-values                     |
//| * KDTreeQueryResultsTags()          tag values                   |
//| * KDTreeQueryResultsDistances()     distances                    |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsXY(CKDTree &kdt,CMatrixDouble &xy)
  {
   KDTreeTsQueryResultsXY(kdt,kdt.m_innerbuf,xy);
  }
//+------------------------------------------------------------------+
//| Tags from last query                                             |
//| INPUT PARAMETERS                                                 |
//|     KDT     -   KD-tree                                          |
//|     Tags    -   possibly pre-allocated buffer. If X is too small |
//|                 to store result, it is resized. If size(X) is    |
//|                 enough to store result, it is left unchanged.    |
//| OUTPUT PARAMETERS                                                |
//|     Tags    -   filled with tags associated with points,         |
//|                 or, when no tags were supplied, with zeros       |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first    |
//|    = closest)                                                    |
//| 2. if  XY is larger than required to store result, only leading  |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//| * KDTreeQueryResultsX()             X-values                     |
//| * KDTreeQueryResultsXY()            X- and Y-values              |
//| * KDTreeQueryResultsDistances()     distances                    |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsTags(CKDTree &kdt,int &tags[])
  {
   KDTreeTsQueryResultsTags(kdt,kdt.m_innerbuf,tags);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsTags(CKDTree &kdt,CRowInt &tags)
  {
   KDTreeTsQueryResultsTags(kdt,kdt.m_innerbuf,tags);
  }
//+------------------------------------------------------------------+
//| Distances from last query                                        |
//| INPUT PARAMETERS                                                 |
//|     KDT     -   KD-tree                                          |
//|     R       -   possibly pre-allocated buffer. If X is too small |
//|                 to store result, it is resized. If size(X) is    |
//|                 enough to store result, it is left unchanged.    |
//| OUTPUT PARAMETERS                                                |
//|     R       -   filled with distances (in corresponding norm)    |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first    |
//|    = closest)                                                    |
//| 2. if  XY is larger than required to store result, only leading  |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//| * KDTreeQueryResultsX()             X-values                     |
//| * KDTreeQueryResultsXY()            X- and Y-values              |
//| * KDTreeQueryResultsTags()          tag values                   |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsDistances(CKDTree &kdt,
                                                   double &r[])
  {
   KDTreeTsQueryResultsDistances(kdt,kdt.m_innerbuf,r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsDistances(CKDTree &kdt,
                                                   CRowDouble &r)
  {
   KDTreeTsQueryResultsDistances(kdt,kdt.m_innerbuf,r);
  }
//+------------------------------------------------------------------+
//| X-values from last query associated with CKDTreeRequestBuffer    |
//| object.                                                          |
//| INPUT PARAMETERS                                                 |
//|   KDT      -  KD-tree                                            |
//|   Buf      -  request buffer object created for this particular  |
//|               instance of kd-tree structure.                     |
//|   X        -  possibly pre-allocated buffer. If X is too small to|
//|               store result, it is resized. If size(X) is enough  |
//|               to store result, it is left unchanged.             |
//| OUTPUT PARAMETERS                                                |
//|   X        -  rows are filled with X-values                      |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point           |
//|    (first = closest)                                             |
//| 2. if XY is larger than required to store result, only leading   |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//|   * KDTreeQueryResultsXY()            X- and Y-values            |
//|   * KDTreeQueryResultsTags()          tag values                 |
//|   * KDTreeQueryResultsDistances()     distances                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsX(CKDTree &kdt,
                                             CKDTreeRequestBuffer &buf,
                                             CMatrixDouble &x)
  {
   int k=0;
   int i1_=0;
//--- check
   if(buf.m_kcur==0)
      return;

   if((int)x.Rows()<buf.m_kcur || (int)x.Cols()<kdt.m_nx)
     {
      x.Resize(buf.m_kcur,kdt.m_nx);
     }
   k=buf.m_kcur;
   for(int i=0; i<k; i++)
     {
      i1_=kdt.m_nx;
      for(int i_=0; i_<kdt.m_nx; i_++)
         x.Set(i,i_,kdt.m_xy[buf.m_idx[i]][i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| X- and Y-values from last query associated with                  |
//| CKDTreeRequestBuffer object.                                     |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure.                        |
//|   XY    -  possibly pre-allocated buffer. If XY is too small to  |
//|            store result, it is resized. If size(XY) is enough to |
//|            store result, it is left unchanged.                   |
//| OUTPUT PARAMETERS                                                |
//|   XY    -  rows are filled with points: first NX columns with    |
//|            X-values, next NY columns - with Y-values.            |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point           |
//|    (first = closest)                                             |
//| 2. if XY is larger than required to store result, only leading   |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//|   * KDTreeQueryResultsX()             X-values                   |
//|   * KDTreeQueryResultsTags()          tag values                 |
//|   * KDTreeQueryResultsDistances()     distances                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsXY(CKDTree &kdt,
                                              CKDTreeRequestBuffer &buf,
                                              CMatrixDouble &xy)
  {
   int k=0;
   int i1_=0;
//--- check
   if(buf.m_kcur==0)
      return;
//--- check
   if((int)xy.Rows()<buf.m_kcur || (int)xy.Cols()<(kdt.m_nx+kdt.m_ny))
      xy.Resize(buf.m_kcur,kdt.m_nx+kdt.m_ny);

   k=buf.m_kcur;
   for(int i=0; i<k; i++)
     {
      i1_=kdt.m_nx;
      for(int i_=0; i_<(kdt.m_nx+kdt.m_ny); i_++)
         xy.Set(i,i_,kdt.m_xy[buf.m_idx[i]][i_+i1_]);
     }
  }
//+------------------------------------------------------------------+
//| Tags from last query associated with CKDTreeRequestBuffer object.|
//| This function retuns results stored in the internal buffer of    |
//| kd-tree object. If you performed buffered requests (ones which   |
//| use instances of CKDTreeRequestBuffer class), you should call    |
//| buffered version of this function - KDTreeTsQueryResultsTags().  |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure.                        |
//|   Tags  -  possibly pre-allocated buffer. If X is too small to   |
//|            store result, it is resized. If size(X) is enough to  |
//|            store result, it is left unchanged.                   |
//| OUTPUT PARAMETERS                                                |
//|   Tags  -  filled with tags associated with points, or, when no  |
//|            tags were supplied, with zeros                        |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first =  |
//|    closest)                                                      |
//| 2. if XY is larger than required to store result, only leading   |
//|    part will be overwritten; trailing part will be left          |
//|    unchanged. So if on input XY = [[A,B],[C,D]], and result is   |
//|    [1,2], then on exit we will get XY = [[1,2],[C,D]]. This is   |
//|    done purposely to increase performance; if you want function  |
//|    to resize array according to result size, use function with   |
//|    same name and suffix 'I'.                                     |
//| SEE ALSO                                                         |
//|   * KDTreeQueryResultsX()             X-values                   |
//|   * KDTreeQueryResultsXY()            X- and Y-values            |
//|   * KDTreeQueryResultsDistances()     distances                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsTags(CKDTree &kdt,
                                                CKDTreeRequestBuffer &buf,
                                                int &tags[])
  {
   CRowInt Tags=tags;
   KDTreeTsQueryResultsTags(kdt,buf,Tags);
   Tags.ToArray(tags);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsTags(CKDTree &kdt,
                                                CKDTreeRequestBuffer &buf,
                                                CRowInt &tags)
  {
   int k=0;
//--- check
   if(buf.m_kcur==0)
      return;

   if(CAp::Len(tags)<buf.m_kcur)
      tags.Resize(buf.m_kcur);

   k=buf.m_kcur;
   for(int i=0; i<k; i++)
      tags.Set(i,kdt.m_tags[buf.m_idx[i]]);
  }
//+------------------------------------------------------------------+
//| Distances from last query associated with CKDTreeRequestBuffer   |
//| object.                                                          |
//| This function retuns results stored in the internal buffer of    |
//| kd-tree object. If you performed buffered requests (ones which   |
//| use instances of CKDTreeRequestBuffer class), you should call    |
//| buffered version of this function -                              |
//| KDTreeTsQueryResultsDistances().                                 |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure.                        |
//|   R     -  possibly pre-allocated buffer. If X is too small to   |
//|            store result, it is resized. If size(X) is enough to  |
//|            store result, it is left unchanged.                   |
//| OUTPUT PARAMETERS                                                |
//|   R     -  filled with distances (in corresponding norm)         |
//| NOTES                                                            |
//| 1. points are ordered by distance from the query point (first =  |
//|    closest)                                                      |
//| 2. if XY is larger than required to store result, only leading   |
//|   part will be overwritten; trailing part will be left unchanged.|
//|   So if on input XY = [[A,B],[C,D]], and result is [1,2], then on|
//|   exit we will get XY = [[1,2],[C,D]]. This is done purposely to |
//|   increase performance; if you want function to resize array     |
//|   according to result size, use function with same name and      |
//|   suffix 'I'.                                                    |
//| SEE ALSO                                                         |
//|   * KDTreeQueryResultsX()             X-values                   |
//|   * KDTreeQueryResultsXY()            X- and Y-values            |
//|   * KDTreeQueryResultsTags()          tag values                 |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsDistances(CKDTree &kdt,
                                                     CKDTreeRequestBuffer &buf,
                                                     double &r[])
  {
   int i=0;
   int k=0;
//--- check
   if(buf.m_kcur==0)
      return;
//--- check
   if(CAp::Len(r)<buf.m_kcur)
      if(!CAp::Assert(ArrayResize(r,buf.m_kcur),__FUNCTION__+": Errore resize buffer"))
         return;
   k=buf.m_kcur;
//--- unload norms
//--- Abs() call is used to handle cases with negative norms (generated during KFN requests)
   switch(kdt.m_normtype)
     {
      case 0:
         for(i=0; i<k; i++)
            r[i]=MathAbs(buf.m_r[i]);
         break;
      case 1:
         for(i=0; i<k; i++)
            r[i]=MathAbs(buf.m_r[i]);
         break;
      case 2:
         for(i=0; i<k; i++)
            r[i]=MathSqrt(MathAbs(buf.m_r[i]));
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeTsQueryResultsDistances(CKDTree &kdt,
                                                     CKDTreeRequestBuffer &buf,
                                                     CRowDouble &r)
  {
//--- check
   if(buf.m_kcur==0)
      return;
//--- unload norms
//--- Abs() call is used to handle cases with negative norms (generated during KFN requests)
   switch(kdt.m_normtype)
     {
      case 0:
         r=buf.m_r.Abs()+0;
         break;
      case 1:
         r=buf.m_r.Abs()+0;
         break;
      case 2:
         r=MathSqrt(buf.m_r.Abs()+0);
         break;
     }
  }
//+------------------------------------------------------------------+
//| X-values from last query; 'interactive' variant for languages    |
//| like Python which support constructs like "X =                   |
//| KDTreeQueryResultsXI(KDT)" and interactive mode of interpreter.  |
//| This function allocates new array on each call, so it is         |
//| significantly slower than its 'non-interactive' counterpart, but |
//| it is more convenient when you call it from command line.        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsXI(CKDTree &kdt,CMatrixDouble &x)
  {
//--- memory reset
   x.Resize(0,0);
//--- function call
   KDTreeQueryResultsX(kdt,x);
  }
//+------------------------------------------------------------------+
//| XY-values from last query; 'interactive' variant for languages   |
//| like Python which support constructs like "XY =                  |
//| KDTreeQueryResultsXYI(KDT)" and interactive mode of interpreter. |
//| This function allocates new array on each call, so it is         |
//| significantly slower than its 'non-interactive' counterpart, but |
//| it is more convenient when you call it from command line.        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsXYI(CKDTree &kdt,CMatrixDouble &xy)
  {
//--- memory reset
   xy.Resize(0,0);
//--- function call
   KDTreeQueryResultsXY(kdt,xy);
  }
//+------------------------------------------------------------------+
//| Tags from last query; 'interactive' variant for languages like   |
//| Python which  support  constructs  like "Tags =                  |
//| KDTreeQueryResultsTagsI(KDT)" and interactive mode of            |
//| interpreter.                                                     |
//| This function allocates new array on each call, so it is         |
//| significantly slower than its 'non-interactive' counterpart, but |
//| it is more convenient when you call it from command line.        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsTagsI(CKDTree &kdt,
                                               int &tags[])
  {
//--- memory reset
   ArrayResizeAL(tags,0);
//--- function call
   KDTreeQueryResultsTags(kdt,tags);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsTagsI(CKDTree &kdt,
                                               CRowInt &tags)
  {
//--- memory reset
   tags.Resize(0);
//--- function call
   KDTreeQueryResultsTags(kdt,tags);
  }
//+------------------------------------------------------------------+
//| Distances from last query; 'interactive' variant for languages   |
//| like Python which support constructs like "R =                   |
//| KDTreeQueryResultsDistancesI(KDT)" and interactive mode of       |
//| interpreter.                                                     |
//| This function allocates new array on each call, so it is         |
//| significantly slower than its 'non-interactive' counterpart, but |
//| it is more convenient when you call it from command line.        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsDistancesI(CKDTree &kdt,
                                                    double &r[])
  {
//--- memory reset
   ArrayResize(r,0);
//--- function call
   KDTreeQueryResultsDistances(kdt,r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryResultsDistancesI(CKDTree &kdt,
                                                    CRowDouble &r)
  {
//--- memory reset
   r.Resize(0);
//--- function call
   KDTreeQueryResultsDistances(kdt,r);
  }
//+------------------------------------------------------------------+
//| It is informational function which returns bounding box for      |
//| entire dataset.                                                  |
//| This function is not visible to ALGLIB users, only ALGLIB itself |
//| may  use it.                                                     |
//| This function assumes that output buffers are preallocated by    |
//| caller.                                                          |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeExploreBox(CKDTree &kdt,
                                        CRowDouble &boxmin,
                                        CRowDouble &boxmax)
  {
   boxmin=kdt.m_boxmin;
   boxmax=kdt.m_boxmax;
  }
//+------------------------------------------------------------------+
//| It is informational function which allows to get information     |
//| about node type. Node index is given by integer value, with 0    |
//| corresponding to root node and other node indexes obtained via   |
//| exploration.                                                     |
//| You should not expect that serialization/unserialization will    |
//| retain node indexes. You should keep in mind that future versions|
//| of ALGLIB may introduce new node types.                          |
//| OUTPUT VALUES:                                                   |
//|   NodeType   -   node type:                                      |
//|            * 0 corresponds to leaf node, which can be explored by|
//|              KDTreeExploreLeaf() function                        |
//|            * 1 corresponds to split node, which can be explored  |
//|              by KDTreeExploreSplit() function                    |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeExploreNodeType(CKDTree &kdt,
                                             int node,
                                             int &nodetype)
  {
   nodetype=0;
//--- check
   if(!CAp::Assert(node>=0,__FUNCTION__+": incorrect node"))
      return;
//--- check
   if(!CAp::Assert(node<kdt.m_nodes.Size(),__FUNCTION__+": incorrect node"))
      return;
//--- check
   if(kdt.m_nodes[node]>0)
     {
      //--- Leaf node
      nodetype=0;
      return;
     }
   if(kdt.m_nodes[node]==0)
     {
      //--- Split node
      nodetype=1;
      return;
     }
//--- check
   if(!CAp::Assert(false,__FUNCTION__+": integrity check failure"))
      return;
  }
//+------------------------------------------------------------------+
//| It is informational function which allows to get information     |
//| about leaf node. Node index is given by integer value, with 0    |
//| corresponding to root node and other node indexes obtained via   |
//| exploration.                                                     |
//| You should not expect that serialization/unserialization will    |
//| retain node indexes. You should keep in mind that future versions|
//| of ALGLIB may introduce new node types.                          |
//| OUTPUT VALUES:                                                   |
//|   XT -  output buffer is reallocated (if too small) and filled by|
//|         XY values                                                |
//|   K  -  number of rows in XY                                     |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeExploreLeaf(CKDTree &kdt,
                                         int node,
                                         CMatrixDouble &xy,
                                         int &k)
  {
   int offs=0;
   k=0;
//--- check
   if(!CAp::Assert(node>=0,__FUNCTION__+": incorrect node index"))
      return;
//--- check
   if(!CAp::Assert(node+1<kdt.m_nodes.Size(),__FUNCTION__+": incorrect node index"))
      return;
//--- check
   if(!CAp::Assert(kdt.m_nodes[node]>0,__FUNCTION__+": incorrect node index"))
      return;

   k=kdt.m_nodes[node];
   offs=kdt.m_nodes[node+1];
//--- check
   if(!CAp::Assert(offs>=0,__FUNCTION__+": integrity error"))
      return;
//--- check
   if(!CAp::Assert((offs+k-1)<(int)CAp::Rows(kdt.m_xy),__FUNCTION__+": integrity error"))
      return;
   CApServ::RMatrixSetLengthAtLeast(xy,k,kdt.m_nx+kdt.m_ny);
   for(int i=0; i<k; i++)
      for(int j=0; j<(kdt.m_nx+kdt.m_ny); j++)
         xy.Set(i,j,kdt.m_xy[offs+i][kdt.m_nx+j]);
  }
//+------------------------------------------------------------------+
//| It is informational function which allows to get information     |
//| about split node. Node index is given by integer value, with 0   |
//| corresponding to root node and other node indexes obtained via   |
//| exploration.                                                     |
//| You should not expect that serialization/unserialization will    |
//| retain node indexes. You should keep in mind that future versions|
//| of ALGLIB may introduce new node types.                          |
//| OUTPUT VALUES:                                                   |
//|   XT -  output buffer is reallocated (if too small) and filled by|
//|         XY values                                                |
//|   K  -  number of rows in XY                                     |
//|                                                                  |
//|   Nodes[idx+1]=dim    dimension to split                         |
//|   Nodes[idx+2]=offs   offset of splitting point in Splits[]      |
//|   Nodes[idx+3]=left   position of left child in Nodes[]          |
//|   Nodes[idx+4]=right  position of right child in Nodes[]         |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeExploreSplit(CKDTree &kdt,
                                          int node,
                                          int &d,
                                          double &s,
                                          int &nodele,
                                          int &nodege)
  {
//--- init variables
   d=0;
   s=0;
   nodele=0;
   nodege=0;
//--- check
   if(!CAp::Assert(node>=0,__FUNCTION__+": incorrect node index"))
      return;
//--- check
   if(!CAp::Assert(node+4<kdt.m_nodes.Size(),__FUNCTION__+": incorrect node index"))
      return;
//--- check
   if(!CAp::Assert(kdt.m_nodes[node]==0,__FUNCTION__+": incorrect node index"))
      return;

   d=kdt.m_nodes[node+1];
   s=kdt.m_splits[kdt.m_nodes[node+2]];
   nodele=kdt.m_nodes[node+3];
   nodege=kdt.m_nodes[node+4];
//--- check
   if(!CAp::Assert(d>=0,__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(d<kdt.m_nx,__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(CMath::IsFinite(s),__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(nodele>=0,__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(nodele<kdt.m_nodes.Size(),__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(nodege>=0,__FUNCTION__+": integrity failure"))
      return;
//--- check
   if(!CAp::Assert(nodege<kdt.m_nodes.Size(),"KDTreeExploreSplit: integrity failure"))
      return;
  }
//+------------------------------------------------------------------+
//| Serializer: allocation                                           |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeAlloc(CSerializer &s,CKDTree &tree)
  {
//--- Header
   s.Alloc_Entry();
   s.Alloc_Entry();
//--- Data
   s.Alloc_Entry();
   s.Alloc_Entry();
   s.Alloc_Entry();
   s.Alloc_Entry();
//--- allocation
   CApServ::AllocRealMatrix(s,tree.m_xy,-1,-1);
   CApServ::AllocIntegerArray(s,tree.m_tags,-1);
   CApServ::AllocRealArray(s,tree.m_boxmin,-1);
   CApServ::AllocRealArray(s,tree.m_boxmax,-1);
   CApServ::AllocIntegerArray(s,tree.m_nodes,-1);
   CApServ::AllocRealArray(s,tree.m_splits,-1);
  }
//+------------------------------------------------------------------+
//| Serializer: serialization                                        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeSerialize(CSerializer &s,CKDTree &tree)
  {
//--- Header
   s.Serialize_Int(CSCodes::GetKDTreeSerializationCode());
   s.Serialize_Int(m_kdtreefirstversion);
//--- Data
   s.Serialize_Int(tree.m_n);
   s.Serialize_Int(tree.m_nx);
   s.Serialize_Int(tree.m_ny);
   s.Serialize_Int(tree.m_normtype);
//--- serialization
   CApServ::SerializeRealMatrix(s,tree.m_xy,-1,-1);
   CApServ::SerializeIntegerArray(s,tree.m_tags,-1);
   CApServ::SerializeRealArray(s,tree.m_boxmin,-1);
   CApServ::SerializeRealArray(s,tree.m_boxmax,-1);
   CApServ::SerializeIntegerArray(s,tree.m_nodes,-1);
   CApServ::SerializeRealArray(s,tree.m_splits,-1);
  }
//+------------------------------------------------------------------+
//| Serializer: unserialization                                      |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeUnserialize(CSerializer &s,CKDTree &tree)
  {
//--- check correctness of header
   int i0=s.Unserialize_Int();
//--- check
   if(!CAp::Assert(i0==CSCodes::GetKDTreeSerializationCode(),__FUNCTION__+": stream header corrupted"))
      return;
   int i1=s.Unserialize_Int();
//--- check
   if(!CAp::Assert(i1==m_kdtreefirstversion,__FUNCTION__+": stream header corrupted"))
      return;
//--- Unserialize data
   tree.m_n=s.Unserialize_Int();
   tree.m_nx=s.Unserialize_Int();
   tree.m_ny=s.Unserialize_Int();
   tree.m_normtype=s.Unserialize_Int();
//--- unserializetion
   CApServ::UnserializeRealMatrix(s,tree.m_xy);
   CApServ::UnserializeIntegerArray(s,tree.m_tags);
   CApServ::UnserializeRealArray(s,tree.m_boxmin);
   CApServ::UnserializeRealArray(s,tree.m_boxmax);
   CApServ::UnserializeIntegerArray(s,tree.m_nodes);
   CApServ::UnserializeRealArray(s,tree.m_splits);
//--- function call
   KDTreeCreateRequestBuffer(tree,tree.m_innerbuf);
  }
//+------------------------------------------------------------------+
//| R-NN query: all points within R-sphere centered at X, using      |
//| external thread-local buffer, sorted by distance between point   |
//| and X (by ascending)                                             |
//| You can call this function from multiple threads for same kd-tree|
//| instance, assuming that different instances of buffer object are |
//| passed to different threads.                                     |
//| NOTE: it is also possible to perform undordered queries performed|
//|       by means of KDTreeQueryRNNU() and KDTreeTsQueryRNNU()      |
//|       functions. Such queries are faster because we do not have  |
//|       to use heap structure for sorting.                         |
//| INPUT PARAMETERS                                                 |
//|   KDT   -  KD-tree                                               |
//|   Buf   -  request buffer object created for this particular     |
//|            instance of kd-tree structure with                    |
//|            KDTreeCreateRequestBuffer() function.                 |
//|   X     -  point, array[0..NX-1].                                |
//|   R     -  radius of sphere (in corresponding norm), R>0         |
//|   SelfMatch   -  whether self-matches are allowed:               |
//|         * if True, nearest neighbor may be the point itself (if  |
//|           it exists in original dataset)                         |
//|         * if False, then only points with non-zero distance are  |
//|           returned                                               |
//|         * if not given, considered True                          |
//| RESULT                                                           |
//|   number of neighbors found, >=0                                 |
//| This subroutine performs query and stores its result in the      |
//| internal structures of the buffer object. You can use following  |
//| subroutines to obtain these results (pay attention to "buf" in   |
//| their names):                                                    |
//|   * KDTreeTsQueryResultsX() to get X-values                      |
//|   * KDTreeTsQueryResultsXY() to get X- and Y-values              |
//|   * KDTreeTsQueryResultsTags() to get tag values                 |
//|   * KDTreeTsQueryResultsDistances() to get distances             |
//| IMPORTANT: kd-tree buffer should be used only with KD-tree object|
//|            which was used to initialize buffer. Any attempt to   |
//|            use biffer with different object is dangerous - you   |
//|            may get integrity check failure (exception) because   |
//|            sizes of internal arrays do not fit to dimensions of  |
//|            KD-tree structure.                                    |
//+------------------------------------------------------------------+
int CNearestNeighbor::TsQueryRNN(CKDTree &kdt,
                                 CKDTreeRequestBuffer &buf,
                                 CRowDouble &x,
                                 double r,
                                 bool selfmatch=true,
                                 bool orderedbydist=true)
  {
   int result=0;
   int i=0;
   int j=0;
//--- Handle special case: KDT.N=0
   if(kdt.m_n==0)
     {
      buf.m_kcur=0;
      return(0);
     }
//--- Check consistency of request buffer
   CheckRequestBufferConsistency(kdt,buf);
//--- Prepare parameters
   buf.m_kneeded=0;
   if(kdt.m_normtype!=2)
      buf.m_rneeded=r;
   else
      buf.m_rneeded=CMath::Sqr(r);
   buf.m_selfmatch=selfmatch;
   buf.m_approxf=1;
   buf.m_kcur=0;
//--- calculate distance from point to current bounding box
   KDTreeInitBox(kdt,x,buf);
//--- call recursive search
//--- results are returned as heap
   KDTreeQueryNNRec(kdt,buf,0);
   result=buf.m_kcur;
//--- pop from heap to generate ordered representation
//--- last element is not pop'ed because it is already in its place
   if(orderedbydist)
     {
      j=buf.m_kcur;
      for(i=buf.m_kcur; i>=2; i--)
         CTSort::TagHeapPopI(buf.m_r,buf.m_idx,j);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Rearranges nodes [I1,I2) using partition in D-th dimension with  |
//| S as threshold. Returns split position I3: [I1,I3) and [I3,I2)   |
//| are created as result.                                           |
//| This subroutine doesn't create tree structures, just rearranges  |
//| nodes.                                                           |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeSplit(CKDTree &kdt,const int i1,
                                   const int i2,const int d,
                                   const double s,int &i3)
  {
   int    ileft=0;
   int    iright=0;
   double v=0;
//--- initialization
   i3=0;
//--- split XY/Tags in two parts:
//--- * [ILeft,IRight] is non-processed part of XY/Tags
//--- After cycle is done, we have Ileft=IRight. We deal with
//--- this element separately.
//--- After this, [I1,ILeft) contains left part, and [ILeft,I2)
//--- contains right part.
   ileft=i1;
   iright=i2-1;
   while(ileft<iright)
     {
      //--- check
      if(kdt.m_xy.Get(ileft,d)<=s)
        {
         //--- XY[ILeft] is on its place.
         //--- Advance ILeft.
         ileft=ileft+1;
        }
      else
        {
         //--- XY[ILeft,..] must be at IRight.
         //--- Swap and advance IRight.
         kdt.m_xy.SwapRows(ileft,iright);
         //--- change values
         kdt.m_tags.Swap(ileft,iright);
         iright--;
        }
     }
//--- check
   if(kdt.m_xy.Get(ileft,d)<=s)
      ileft++;
//--- get result
   i3=ileft;
  }
//+------------------------------------------------------------------+
//| Recursive kd-tree generation subroutine.                         |
//| PARAMETERS                                                       |
//|     KDT         tree                                             |
//|     NodesOffs   unused part of Nodes[] which must be filled by   |
//|                 tree                                             |
//|     SplitsOffs  unused part of Splits[]                          |
//|     I1, I2      points from [I1,I2) are processed                |
//| NodesOffs[] and SplitsOffs[] must be large enough.               |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeGenerateTreeRec(CKDTree &kdt,int &nodesoffs,
                                             int &splitsoffs,const int i1,
                                             const int i2,const int maxleafsize)
  {
//--- create variables
   int    n=0;
   int    nx=0;
   int    ny=0;
   int    i=0;
   int    j=0;
   int    oldoffs=0;
   int    i3=0;
   int    cntless=0;
   int    cntgreater=0;
   double minv=0;
   double maxv=0;
   int    minidx=0;
   int    maxidx=0;
   int    d=0;
   double ds=0;
   double s=0;
   double v=0;
   int    i_=0;
   int    i1_=0;
//--- check
   if(!CAp::Assert(kdt.m_n>0,__FUNCTION__+": internal error"))
      return;
//--- check
   if(!CAp::Assert(i2>i1,__FUNCTION__+": internal error"))
      return;
//--- Generate leaf if needed
   if(i2-i1<=maxleafsize)
     {
      kdt.m_nodes.Set(nodesoffs+0,i2-i1);
      kdt.m_nodes.Set(nodesoffs+1,i1);
      nodesoffs=nodesoffs+2;
      //--- exit the function
      return;
     }
//--- Load values for easier access
   nx=kdt.m_nx;
   ny=kdt.m_ny;
//--- select dimension to split:
//--- * D is a dimension number
//--- In case bounding box has zero size, we enforce creation of the leaf node.
   d=0;
   ds=kdt.m_innerbuf.m_curboxmax[0]-kdt.m_innerbuf.m_curboxmin[0];
   for(i=1; i<nx; i++)
     {
      v=kdt.m_innerbuf.m_curboxmax[i]-kdt.m_innerbuf.m_curboxmin[i];
      //--- check
      if(v>ds)
        {
         ds=v;
         d=i;
        }
     }
   if((double)(ds)==0.0)
     {
      kdt.m_nodes.Set(nodesoffs+0,i2-i1);
      kdt.m_nodes.Set(nodesoffs+1,i1);
      nodesoffs=nodesoffs+2;
      return;
     }
//--- Select split position S using sliding midpoint rule,
//--- rearrange points into [I1,I3) and [I3,I2)
   s=kdt.m_innerbuf.m_curboxmin[d]+0.5*ds;
   i1_=i1;
   for(i_=0; i_<i2-i1; i_++)
      kdt.m_innerbuf.m_buf.Set(i_,kdt.m_xy.Get(i_+i1_,d));
//--- change values
   n=i2-i1;
   cntless=0;
   cntgreater=0;
   minv=kdt.m_innerbuf.m_buf[0];
   maxv=kdt.m_innerbuf.m_buf[0];
   minidx=i1;
   maxidx=i1;
   for(i=0; i<n; i++)
     {
      v=kdt.m_innerbuf.m_buf[i];
      //--- check
      if(v<minv)
        {
         minv=v;
         minidx=i1+i;
        }
      //--- check
      if(v>maxv)
        {
         maxv=v;
         maxidx=i1+i;
        }
      //--- check
      if(v<s)
         cntless=cntless+1;
      //--- check
      if(v>s)
         cntgreater=cntgreater+1;
     }
//--- check
   if(minv==maxv)
     {
      //--- In case all points has same value of D-th component
      //--- (MinV=MaxV) we enforce D-th dimension of bounding
      //--- box to become exactly zero and repeat tree construction.
      double v0=kdt.m_innerbuf.m_curboxmin[d];
      double v1=kdt.m_innerbuf.m_curboxmax[d];
      kdt.m_innerbuf.m_curboxmin.Set(d,minv);
      kdt.m_innerbuf.m_curboxmax.Set(d,maxv);
      KDTreeGenerateTreeRec(kdt,nodesoffs,splitsoffs,i1,i2,maxleafsize);
      kdt.m_innerbuf.m_curboxmin.Set(d,v0);
      kdt.m_innerbuf.m_curboxmax.Set(d,v1);
      return;
     }
//--- check
   if(cntless>0 && cntgreater>0)
     {
      //--- normal midpoint split
      KDTreeSplit(kdt,i1,i2,d,s,i3);
     }
   else
     {
      //--- sliding midpoint
      if(cntless==0)
        {
         //--- 1. move split to MinV,
         //--- 2. place one point to the left bin (move to I1),
         //---    others - to the right bin
         s=minv;
         //--- check
         if(minidx!=i1)
           {
            for(i=0; i<(2*kdt.m_nx+kdt.m_ny); i++)
              {
               v=kdt.m_xy[minidx][i];
               kdt.m_xy.Set(minidx,i,kdt.m_xy[i1][i]);
               kdt.m_xy.Set(i1,i,v);
              }
            //--- change values
            kdt.m_tags.Swap(minidx,i1);
           }
         i3=i1+1;
        }
      else
        {
         //--- 1. move split to MaxV,
         //--- 2. place one point to the right bin (move to I2-1),
         //---    others - to the left bin
         s=maxv;
         //--- check
         if(maxidx!=i2-1)
           {
            for(i=0; i<(2*kdt.m_nx+kdt.m_ny); i++)
              {
               v=kdt.m_xy[maxidx][i];
               kdt.m_xy.Set(maxidx,i,kdt.m_xy[i2-1][i]);
               kdt.m_xy.Set(i2-1,i,v);
              }
            //--- change values
            kdt.m_tags.Swap(maxidx,i2-1);
           }
         i3=i2-1;
        }
     }
//--- Generate 'split' node
   kdt.m_nodes.Set(nodesoffs,0);
   kdt.m_nodes.Set(nodesoffs+1,d);
   kdt.m_nodes.Set(nodesoffs+2,splitsoffs);
   kdt.m_splits.Set(splitsoffs,s);
   oldoffs=nodesoffs;
   nodesoffs+=m_splitnodesize;
   splitsoffs ++;
//--- Recirsive generation:
//--- * update CurBox
//--- * call subroutine
//--- * restore CurBox
   kdt.m_nodes.Set(oldoffs+3,nodesoffs);
   v=kdt.m_innerbuf.m_curboxmax[d];
   kdt.m_innerbuf.m_curboxmax.Set(d,s);
//--- function call
   KDTreeGenerateTreeRec(kdt,nodesoffs,splitsoffs,i1,i3,maxleafsize);
   kdt.m_innerbuf.m_curboxmax.Set(d,v);
   kdt.m_nodes.Set(oldoffs+4,nodesoffs);
   v=kdt.m_innerbuf.m_curboxmin[d];
   kdt.m_innerbuf.m_curboxmin.Set(d,s);
//--- function call
   KDTreeGenerateTreeRec(kdt,nodesoffs,splitsoffs,i3,i2,maxleafsize);
   kdt.m_innerbuf.m_curboxmin.Set(d,v);
//--- Zero-fill unused portions of the node (avoid false warnings by Valgrind
//--- about attempt to serialize uninitialized values)
   CAp::Assert(CNearestNeighbor::m_splitnodesize==6,__FUNCTION__+": node size has unexpectedly changed");
   kdt.m_nodes.Set(oldoffs+5,0);
  }
//+------------------------------------------------------------------+
//| Recursive subroutine for NN queries.                             |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryNNRec(CKDTree &kdt,const int offs)
  {
   KDTreeQueryNNRec(kdt,kdt.m_innerbuf,offs);
  }
//+------------------------------------------------------------------+
//| Recursive subroutine for NN queries.                             |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryNNRec(CKDTree &kdt,CKDTreeRequestBuffer &buf,const int offs)
  {
//--- create variables
   double ptdist=0;
   int    i=0;
   int    j=0;
   int    nx=0;
   int    i1=0;
   int    i2=0;
   int    d=0;
   double s=0;
   double v=0;
   double t1=0;
   int    childbestoffs=0;
   int    childworstoffs=0;
   int    childoffs=0;
   double prevdist=0;
   bool   todive;
   bool   bestisleft;
   bool   updatemin;
//--- check
   if(!CAp::Assert(kdt.m_n>0,__FUNCTION__+": internal error"))
      return;
//--- Leaf node.
//--- Process points.
   if(kdt.m_nodes[offs]>0)
     {
      i1=kdt.m_nodes[offs+1];
      i2=i1+kdt.m_nodes[offs];
      for(i=i1; i<i2; i++)
        {
         //--- Calculate distance
         ptdist=0;
         nx=kdt.m_nx;
         //--- check
         switch(kdt.m_normtype)
           {
            case 0:
               for(j=0; j<nx; j++)
                  ptdist=MathMax(ptdist,MathAbs(kdt.m_xy[i][j]-buf.m_x[j]));
               break;
            case 1:
               for(j=0; j<nx; j++)
                  ptdist=ptdist+MathAbs(kdt.m_xy[i][j]-buf.m_x[j]);
               break;
            case 2:
               for(j=0; j<nx; j++)
                  ptdist=ptdist+CMath::Sqr(kdt.m_xy[i][j]-buf.m_x[j]);
               break;
           }
         //--- Skip points with zero distance if self-matches are turned off
         if(ptdist==0.0 && !buf.m_selfmatch)
            continue;
         //--- We CAN'T process point if R-criterion isn't satisfied,
         //--- i.e. (RNeeded<>0) AND (PtDist>R).
         if(buf.m_rneeded==0.0 || ptdist<=buf.m_rneeded)
           {
            //--- R-criterion is satisfied, we must either:
            //--- * replace worst point, if (KNeeded<>0) AND (KCur=KNeeded)
            //---   (or skip, if worst point is better)
            //--- * add point without replacement otherwise
            if(buf.m_kcur<buf.m_kneeded || buf.m_kneeded==0)
              {
               //--- add current point to heap without replacement
               CTSort::TagHeapPushI(buf.m_r,buf.m_idx,buf.m_kcur,ptdist,i);
              }
            else
              {
               //--- New points are added or not, depending on their distance.
               //--- If added, they replace element at the top of the heap
               if(ptdist<(double)(buf.m_r[0]))
                 {
                  //--- check
                  if(buf.m_kneeded==1)
                    {
                     buf.m_idx.Set(0,i);
                     buf.m_r.Set(0,ptdist);
                    }
                  else
                     CTSort::TagHeapReplaceTopI(buf.m_r,buf.m_idx,buf.m_kneeded,ptdist,i);
                 }
              }
           }
        }
      //--- exit the function
      return;
     }
//--- Simple split
   if(kdt.m_nodes[offs]==0)
     {
      //--- Load:
      //--- * D  dimension to split
      //--- * S  split position
      d=kdt.m_nodes[offs+1];
      s=kdt.m_splits[kdt.m_nodes[offs+2]];
      //--- Calculate:
      //--- * ChildBestOffs      child box with best chances
      //--- * ChildWorstOffs     child box with worst chances
      if(buf.m_x[d]<=s)
        {
         childbestoffs=kdt.m_nodes[offs+3];
         childworstoffs=kdt.m_nodes[offs+4];
         bestisleft=true;
        }
      else
        {
         childbestoffs=kdt.m_nodes[offs+4];
         childworstoffs=kdt.m_nodes[offs+3];
         bestisleft=false;
        }
      //--- Navigate through childs
      for(i=0; i<=1; i++)
        {
         //--- Select child to process:
         //--- * ChildOffs      current child offset in Nodes[]
         //--- * UpdateMin      whether minimum or maximum value
         //---                  of bounding box is changed on update
         if(i==0)
           {
            childoffs=childbestoffs;
            updatemin=!bestisleft;
           }
         else
           {
            updatemin=bestisleft;
            childoffs=childworstoffs;
           }
         //--- Update bounding box and current distance
         if(updatemin)
           {
            prevdist=buf.m_curdist;
            t1=buf.m_x[d];
            v=buf.m_curboxmin[d];
            //--- check
            if(t1<=s)
               //--- check
               switch(kdt.m_normtype)
                 {
                  case 0:
                     buf.m_curdist=MathMax(buf.m_curdist,s-t1);
                     break;
                  case 1:
                     buf.m_curdist=buf.m_curdist-MathMax(v-t1,0)+s-t1;
                     break;
                  case 2:
                     buf.m_curdist=buf.m_curdist-CMath::Sqr(MathMax(v-t1,0))+CMath::Sqr(s-t1);
                     break;
                 }
            buf.m_curboxmin.Set(d,s);
           }
         else
           {
            prevdist=buf.m_curdist;
            t1=buf.m_x[d];
            v=buf.m_curboxmax[d];
            //--- check
            if(t1>=s)
               switch(kdt.m_normtype)
                 {
                  case 0:
                     buf.m_curdist=MathMax(buf.m_curdist,t1-s);
                     break;
                  case 1:
                     buf.m_curdist=buf.m_curdist-MathMax(t1-v,0)+t1-s;
                     break;
                  case 2:
                     buf.m_curdist=buf.m_curdist-CMath::Sqr(MathMax(t1-v,0))+CMath::Sqr(t1-s);
                     break;
                 }
            buf.m_curboxmax.Set(d,s);
           }
         //--- Decide: to dive into cell or not to dive
         if(buf.m_rneeded!=0.0 && buf.m_curdist>buf.m_rneeded)
            todive=false;
         else
           {
            //--- check
            if(buf.m_kcur<buf.m_kneeded || buf.m_kneeded==0)
              {
               //--- KCur<KNeeded (i.e. not all points are found)
               todive=true;
              }
            else
              {
               //--- KCur=KNeeded,decide to dive or not to dive
               //--- using point position relative to bounding box.
               todive=buf.m_curdist<=(double)(buf.m_r[0]*buf.m_approxf);
              }
           }
         //--- check
         if(todive)
            KDTreeQueryNNRec(kdt,buf,childoffs);
         //--- Restore bounding box and distance
         if(updatemin)
            buf.m_curboxmin.Set(d,v);
         else
            buf.m_curboxmax.Set(d,v);
         buf.m_curdist=prevdist;
        }
      //--- exit the function
      return;
     }
  }
//+------------------------------------------------------------------+
//| Recursive subroutine for box queries.                            |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeQueryBoxRec(CKDTree &kdt,
                                         CKDTreeRequestBuffer &buf,
                                         int offs)
  {
//--- create variables
   bool   inbox=false;
   int    nx=0;
   int    i1=0;
   int    i2=0;
   int    i=0;
   int    j=0;
   int    d=0;
   double s=0;
   double v=0;
//--- check
   if(!CAp::Assert(kdt.m_n>0,__FUNCTION__+": internal error"))
      return;
   nx=kdt.m_nx;
//--- Check that intersection of query box with bounding box is non-empty.
//--- This check is performed once for Offs=0 (tree root).
   if(offs==0)
     {
      for(j=0; j<nx; j++)
        {
         if(buf.m_boxmin[j]>buf.m_curboxmax[j])
            return;
         if(buf.m_boxmax[j]<buf.m_curboxmin[j])
            return;
        }
     }
//--- Leaf node.
//--- Process points.
   if(kdt.m_nodes[offs]>0)
     {
      i1=kdt.m_nodes[offs+1];
      i2=i1+kdt.m_nodes[offs];
      for(i=i1; i<i2; i++)
        {
         //--- Check whether point is in box or not
         inbox=true;
         for(j=0; j<nx; j++)
           {
            inbox=inbox && (kdt.m_xy[i][j]>=buf.m_boxmin[j]);
            inbox=inbox && (kdt.m_xy[i][j]<=buf.m_boxmax[j]);
           }
         if(!inbox)
            continue;
         //--- Add point to unordered list
         buf.m_r.Set(buf.m_kcur,0.0);
         buf.m_idx.Set(buf.m_kcur,i);
         buf.m_kcur++;
        }
      return;
     }
//--- Simple split
   if(kdt.m_nodes[offs]==0)
     {
      //--- Load:
      //--- * D  dimension to split
      //--- * S  split position
      d=kdt.m_nodes[offs+1];
      s=kdt.m_splits[kdt.m_nodes[offs+2]];
      //--- Check lower split (S is upper bound of new bounding box)
      if(s>=buf.m_boxmin[d])
        {
         v=buf.m_curboxmax[d];
         buf.m_curboxmax.Set(d,s);
         KDTreeQueryBoxRec(kdt,buf,kdt.m_nodes[offs+3]);
         buf.m_curboxmax.Set(d,v);
        }
      //--- Check upper split (S is lower bound of new bounding box)
      if(s<=buf.m_boxmax[d])
        {
         v=buf.m_curboxmin[d];
         buf.m_curboxmin.Set(d,s);
         KDTreeQueryBoxRec(kdt,buf,kdt.m_nodes[offs+4]);
         buf.m_curboxmin.Set(d,v);
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Copies X[] to KDT.X[]                                            |
//| Loads distance from X[] to bounding box.                         |
//| Initializes CurBox[].                                            |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeInitBox(CKDTree&kdt,CRowDouble &x,
                                     CKDTreeRequestBuffer&buf)
  {
   int    i=0;
   double vx=0;
   double vmin=0;
   double vmax=0;
//--- check
   if(!CAp::Assert(kdt.m_n>0,__FUNCTION__+": Internal error"))
      return;
//--- calculate distance from point to current bounding box
   buf.m_curdist=0;
   if(kdt.m_normtype==0)
     {
      for(i=0; i<kdt.m_nx; i++)
        {
         vx=x[i];
         vmin=kdt.m_boxmin[i];
         vmax=kdt.m_boxmax[i];
         buf.m_x.Set(i,vx);
         buf.m_curboxmin.Set(i,vmin);
         buf.m_curboxmax.Set(i,vmax);
         //--- check
         if(vx<vmin)
            buf.m_curdist=MathMax(buf.m_curdist,vmin-vx);
         else
           {
            //--- check
            if(vx>vmax)
               buf.m_curdist=MathMax(buf.m_curdist,vx-vmax);
           }
        }
     }
//--- check
   if(kdt.m_normtype==1)
     {
      for(i=0; i<kdt.m_nx; i++)
        {
         vx=x[i];
         vmin=kdt.m_boxmin[i];
         vmax=kdt.m_boxmax[i];
         buf.m_x.Set(i,vx);
         buf.m_curboxmin.Set(i,vmin);
         buf.m_curboxmax.Set(i,vmax);
         //--- check
         if(vx<vmin)
            buf.m_curdist=buf.m_curdist+vmin-vx;
         else
           {
            //--- check
            if(vx>vmax)
               buf.m_curdist=buf.m_curdist+vx-vmax;
           }
        }
     }
//--- check
   if(kdt.m_normtype==2)
     {
      for(i=0; i<kdt.m_nx; i++)
        {
         vx=x[i];
         vmin=kdt.m_boxmin[i];
         vmax=kdt.m_boxmax[i];
         buf.m_x.Set(i,vx);
         buf.m_curboxmin.Set(i,vmin);
         buf.m_curboxmax.Set(i,vmax);
         //--- check
         if(vx<vmin)
            buf.m_curdist=buf.m_curdist+CMath::Sqr(vmin-vx);
         else
           {
            //--- check
            if(vx>vmax)
               buf.m_curdist=buf.m_curdist+CMath::Sqr(vx-vmax);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| This function allocates all dataset-independent array fields of  |
//| KDTree, i.e. such array fields that their dimensions do not      |
//| depend on dataset size.                                          |
//| This function do not sets KDT.NX or KDT.NY - it just allocates   |
//| arrays                                                           |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeAllocDataSetIndependent(CKDTree&kdt,
                                                     const int nx,
                                                     const int ny)
  {
//--- check
   if(!CAp::Assert(kdt.m_n>0,__FUNCTION__+": internal error"))
      return;
//--- allocation
   kdt.m_boxmin.Resize(nx);
   kdt.m_boxmax.Resize(nx);
  }
//+------------------------------------------------------------------+
//| This function allocates all dataset-dependent array fields of    |
//| KDTree, i.e. such array fields that their dimensions depend on   |
//| dataset size.                                                    |
//| This function do not sets KDT.N, KDT.NX or KDT.NY -              |
//| it just allocates arrays.                                        |
//+------------------------------------------------------------------+
void CNearestNeighbor::KDTreeAllocDataSetDependent(CKDTree&kdt,
                                                   const int n,
                                                   const int nx,
                                                   const int ny)
  {
//--- check
   if(!CAp::Assert(n>0,__FUNCTION__+": internal error"))
      return;
//--- allocation
   kdt.m_xy.Resize(n,2*nx+ny);
   kdt.m_tags.Resize(n);
   kdt.m_nodes.Resize(m_splitnodesize*2*n);
   kdt.m_splits.Resize(2*n);
  }
//+------------------------------------------------------------------+
//| This function checks consistency of request buffer structure with|
//| dimensions of kd-tree object.                                    |
//+------------------------------------------------------------------+
bool CNearestNeighbor::CheckRequestBufferConsistency(CKDTree&kdt,CKDTreeRequestBuffer&buf)
  {
   if(!CAp::Assert((int)buf.m_x.Size()>=kdt.m_nx,__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);
   if(!CAp::Assert(CAp::Len(buf.m_idx)>=kdt.m_n,__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);
   if(!CAp::Assert((int)buf.m_r.Size()>=kdt.m_n,__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);
   if(!CAp::Assert((int)buf.m_buf.Size()>=MathMax(kdt.m_n,kdt.m_nx),__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);
   if(!CAp::Assert((int)buf.m_curboxmin.Size()>=kdt.m_nx,__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);
   if(!CAp::Assert((int)buf.m_curboxmax.Size()>=kdt.m_nx,__FUNCTION__+": dimensions of CKDTreeRequestBuffer are inconsistent with CKDTree structure"))
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
