//+------------------------------------------------------------------+
//|                                                ArrayDatetime.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Array.mqh"
//+------------------------------------------------------------------+
//| Class CArrayDatetime.                                            |
//| Purpose: Class of dynamic array of datetime type values.         |
//|          Derives from class CArray.                              |
//+------------------------------------------------------------------+
class CArrayDatetime : public CArray
  {
protected:
   datetime          m_data[];           // data array

public:
                     CArrayDatetime(void);
                    ~CArrayDatetime(void);
   //--- method of identifying the object
   virtual int       Type(void) const { return(TYPE_DATETIME); }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- methods of managing dynamic memory
   bool              Reserve(const int size);
   bool              Resize(const int size);
   bool              Shutdown(void);
   //--- methods of filling the array
   bool              Add(const datetime element);
   bool              AddArray(const datetime &src[]);
   bool              AddArray(const CArrayDatetime *src);
   bool              Insert(const datetime element,const int pos);
   bool              InsertArray(const datetime &src[],const int pos);
   bool              InsertArray(const CArrayDatetime *src,const int pos);
   bool              AssignArray(const datetime &src[]);
   bool              AssignArray(const CArrayDatetime *src);
   //--- method of access to the array
   datetime          At(const int index) const;
   datetime operator[](const int index) const { return(At(index)); }
   //--- methods of searching for minimum and maximum
   int               Minimum(const int start,const int count) const { return(CArray::Minimum(m_data,start,count)); }
   int               Maximum(const int start,const int count) const { return(CArray::Maximum(m_data,start,count)); }
   //--- methods change
   bool              Update(const int index,const datetime element);
   bool              Shift(const int index,const int shift);
   //--- methods for deleting
   bool              Delete(const int index);
   bool              DeleteRange(int from,int to);
   //--- methods for compare arrays
   bool              CompareArray(const datetime &array[]) const;
   bool              CompareArray(const CArrayDatetime *array) const;
   //--- methods for working with the sorted array
   bool              InsertSort(const datetime element);
   int               Search(const datetime element) const;
   int               SearchGreat(const datetime element) const;
   int               SearchLess(const datetime element) const;
   int               SearchGreatOrEqual(const datetime element) const;
   int               SearchLessOrEqual(const datetime element) const;
   int               SearchFirst(const datetime element) const;
   int               SearchLast(const datetime element) const;
   int               SearchLinear(const datetime element) const;

protected:
   virtual void      QuickSort(int beg,int end,const int mode=0);
   int               QuickSearch(const datetime element) const;
   int               MemMove(const int dest,const int src,int count);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CArrayDatetime::CArrayDatetime(void)
  {
//--- initialize protected data
   m_data_max=ArraySize(m_data);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CArrayDatetime::~CArrayDatetime(void)
  {
   if(m_data_max!=0)
      Shutdown();
  }
//+------------------------------------------------------------------+
//| Moving the memory within a single array                          |
//+------------------------------------------------------------------+
int CArrayDatetime::MemMove(const int dest,const int src,int count)
  {
   int i;
//--- check parameters
   if(dest<0 || src<0 || count<0)
      return(-1);
//--- check count
   if(src+count>m_data_total)
      count=m_data_total-src;
   if(count<0)
      return(-1);
//--- no need to copy
   if(dest==src || count==0)
      return(dest);
//--- check data total
   if(dest+count>m_data_total)
     {
      if(m_data_max<dest+count)
         return(-1);
      m_data_total=dest+count;
     }
//--- copy
   if(dest<src)
     {
      //--- copy from left to right
      for(i=0;i<count;i++)
         m_data[dest+i]=m_data[src+i];
     }
   else
     {
      //--- copy from right to left
      for(i=count-1;i>=0;i--)
         m_data[dest+i]=m_data[src+i];
     }
//--- successful
   return(dest);
  }
//+------------------------------------------------------------------+
//| Request for more memory in an array. Checks if the requested     |
//| number of free elements already exists; allocates additional     |
//| memory with a given step                                         |
//+------------------------------------------------------------------+
bool CArrayDatetime::Reserve(const int size)
  {
   int new_size;
//--- check
   if(size<=0)
      return(false);
//--- resize array
   if(Available()<size)
     {
      new_size=m_data_max+m_step_resize*(1+(size-Available())/m_step_resize);
      if(new_size<0)
         //--- overflow occurred when calculating new_size
         return(false);
      if((m_data_max=ArrayResize(m_data,new_size))==-1)
         m_data_max=ArraySize(m_data);
     }
//--- result
   return(Available()>=size);
  }
//+------------------------------------------------------------------+
//| Resizing (with removal of elements on the right)                 |
//+------------------------------------------------------------------+
bool CArrayDatetime::Resize(const int size)
  {
   int new_size;
//--- check
   if(size<0)
      return(false);
//--- resize array
   new_size=m_step_resize*(1+size/m_step_resize);
   if(m_data_max!=new_size)
     {
      if((m_data_max=ArrayResize(m_data,new_size))==-1)
        {
         m_data_max=ArraySize(m_data);
         return(false);
        }
     }
   if(m_data_total>size)
      m_data_total=size;
//--- result
   return(m_data_max==new_size);
  }
//+------------------------------------------------------------------+
//| Complete cleaning of the array with the release of memory        |
//+------------------------------------------------------------------+
bool CArrayDatetime::Shutdown(void)
  {
//--- check
   if(m_data_max==0)
      return(true);
//--- clean
   if(ArrayResize(m_data,0)==-1)
      return(false);
   m_data_total=0;
   m_data_max=0;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array                        |
//+------------------------------------------------------------------+
bool CArrayDatetime::Add(const datetime element)
  {
//--- check/reserve elements of array
   if(!Reserve(1))
      return(false);
//--- add
   m_data[m_data_total++]=element;
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array from another array     |
//+------------------------------------------------------------------+
bool CArrayDatetime::AddArray(const datetime &src[])
  {
   int num=ArraySize(src);
//--- check/reserve elements of array
   if(!Reserve(num))
      return(false);
//--- add
   for(int i=0;i<num;i++)
      m_data[m_data_total++]=src[i];
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array from another array     |
//+------------------------------------------------------------------+
bool CArrayDatetime::AddArray(const CArrayDatetime *src)
  {
   int num;
//--- check
   if(!CheckPointer(src))
      return(false);
//--- check/reserve elements of array
   num=src.Total();
   if(!Reserve(num))
      return(false);
//--- add
   for(int i=0;i<num;i++)
      m_data[m_data_total++]=src.m_data[i];
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting an element in the specified position                   |
//+------------------------------------------------------------------+
bool CArrayDatetime::Insert(const datetime element,const int pos)
  {
//--- check/reserve elements of array
   if(pos<0 || !Reserve(1))
      return(false);
//--- insert
   m_data_total++;
   if(pos<m_data_total-1)
     {
      if(MemMove(pos+1,pos,m_data_total-pos-1)<0)
         return(false);
      m_data[pos]=element;
     }
   else
      m_data[m_data_total-1]=element;
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting elements in the specified position                     |
//+------------------------------------------------------------------+
bool CArrayDatetime::InsertArray(const datetime &src[],const int pos)
  {
   int num=ArraySize(src);
//--- check/reserve elements of array
   if(!Reserve(num))
      return(false);
//--- insert
   if(MemMove(num+pos,pos,m_data_total-pos)<0)
      return(false);
   for(int i=0;i<num;i++)
      m_data[i+pos]=src[i];
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting elements in the specified position                     |
//+------------------------------------------------------------------+
bool CArrayDatetime::InsertArray(const CArrayDatetime *src,const int pos)
  {
   int num;
//--- check
   if(!CheckPointer(src))
      return(false);
//--- check/reserve elements of array
   num=src.Total();
   if(!Reserve(num))
      return(false);
//--- insert
   if(MemMove(num+pos,pos,m_data_total-pos)<0)
      return(false);
   for(int i=0;i<num;i++)
      m_data[i+pos]=src.m_data[i];
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array                            |
//+------------------------------------------------------------------+
bool CArrayDatetime::AssignArray(const datetime &src[])
  {
   int num=ArraySize(src);
//--- check/reserve elements of array
   Clear();
   if(m_data_max<num)
     {
      if(!Reserve(num))
         return(false);
     }
   else
      Resize(num);
//--- copy array
   for(int i=0;i<num;i++)
     {
      m_data[i]=src[i];
      m_data_total++;
     }
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array                            |
//+------------------------------------------------------------------+
bool CArrayDatetime::AssignArray(const CArrayDatetime *src)
  {
   int num;
//--- check
   if(!CheckPointer(src))
      return(false);
//--- check/reserve elements of array
   num=src.m_data_total;
   Clear();
   if(m_data_max<num)
     {
      if(!Reserve(num))
         return(false);
     }
   else
      Resize(num);
//--- copy array
   for(int i=0;i<num;i++)
     {
      m_data[i]=src.m_data[i];
      m_data_total++;
     }
   m_sort_mode=src.SortMode();
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Access to data in the specified position                         |
//+------------------------------------------------------------------+
datetime CArrayDatetime::At(const int index) const
  {
//--- check
   if(index<0 || index>=m_data_total)
      return(LONG_MAX);
//--- result
   return(m_data[index]);
  }
//+------------------------------------------------------------------+
//| Updating element in the specified position                       |
//+------------------------------------------------------------------+
bool CArrayDatetime::Update(const int index,const datetime element)
  {
//--- check
   if(index<0 || index>=m_data_total)
      return(false);
//--- update
   m_data[index]=element;
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving element from the specified position                       |
//| on the specified shift                                           |
//+------------------------------------------------------------------+
bool CArrayDatetime::Shift(const int index,const int shift)
  {
//--- check
   if(index<0 || index+shift<0 || index+shift>=m_data_total)
      return(false);
   if(shift==0)
      return(true);
//--- move
   datetime tmp_long=m_data[index];

   if(shift>0)
     {
      if(MemMove(index,index+1,shift)<0)
         return(false);
     }
   else
     {
      if(MemMove(index+shift+1,index+shift,-shift)<0)
         return(false);
     }

   m_data[index+shift]=tmp_long;
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting element from the specified position                     |
//+------------------------------------------------------------------+
bool CArrayDatetime::Delete(const int index)
  {
//--- check
   if(index<0 || index>=m_data_total)
      return(false);
//--- delete
   if(index<m_data_total-1 && MemMove(index,index+1,m_data_total-index-1)<0)
      return(false);
   m_data_total--;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting range of elements                                       |
//+------------------------------------------------------------------+
bool CArrayDatetime::DeleteRange(int from,int to)
  {
//--- check
   if(from<0 || to<0)
      return(false);
   if(from>to || from>=m_data_total)
      return(false);
//--- delete
   if(to>=m_data_total-1)
      to=m_data_total-1;
   if(MemMove(from,to+1,m_data_total-to-1)<0)
      return(false);
   m_data_total-=to-from+1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Equality comparison of two arrays                                |
//+------------------------------------------------------------------+
bool CArrayDatetime::CompareArray(const datetime &array[]) const
  {
//--- compare
   if(m_data_total!=ArraySize(array))
      return(false);
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]!=array[i])
         return(false);
//--- equal
   return(true);
  }
//+------------------------------------------------------------------+
//| Equality comparison of two arrays                                |
//+------------------------------------------------------------------+
bool CArrayDatetime::CompareArray(const CArrayDatetime *array) const
  {
//--- check
   if(!CheckPointer(array))
      return(false);
//--- compare
   if(m_data_total!=array.m_data_total)
      return(false);
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]!=array.m_data[i])
         return(false);
//--- equal
   return(true);
  }
//+------------------------------------------------------------------+
//| Method QuickSort                                                 |
//+------------------------------------------------------------------+
void CArrayDatetime::QuickSort(int beg,int end,const int mode)
  {
//--- check
   if(beg<0 || end<0)
      return;
//--- sort
   int i=beg;
   int j=end;
   
   while(i<end)
     {
      //--- ">>1" is quick division by 2
      datetime p_long=m_data[(beg+end)>>1];

      while(i<j)
        {
         while(m_data[i]<p_long)
           {
            //--- control the output of the array bounds
            if(i==m_data_total-1)
               break;
            i++;
           }
         while(m_data[j]>p_long)
           {
            //--- control the output of the array bounds
            if(j==0)
               break;
            j--;
           }
         if(i<=j)
           {
            datetime tmp=m_data[i];
            m_data[i++]=m_data[j];
            m_data[j]=tmp;
            //--- control the output of the array bounds
            if(j==0)
               break;
            j--;
           }
        }
      if(beg<j)
         QuickSort(beg,j);
      beg=i;
      j=end;
     }
  }
//+------------------------------------------------------------------+
//| Inserting element in a sorted array                              |
//+------------------------------------------------------------------+
bool CArrayDatetime::InsertSort(const datetime element)
  {
   int pos;
//--- check
   if(!IsSorted())
      return(false);
//--- check/reserve elements of array
   if(!Reserve(1))
      return(false);
//--- if the array is empty, add an element
   if(m_data_total==0)
     {
      m_data[m_data_total++]=element;
      return(true);
     }
//--- search position and insert
   pos=QuickSearch(element);
   if(m_data[pos]>element)
      Insert(element,pos);
   else
      Insert(element,pos+1);
//--- restore the sorting flag after Insert(...)
   m_sort_mode=0;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Search of position of element in a array                         |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchLinear(const datetime element) const
  {
//--- check
   if(m_data_total==0)
      return(-1);
//---
   for(int i=0;i<m_data_total;i++)
      if(m_data[i]==element)
         return(i);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Quick search of position of element in a sorted array            |
//+------------------------------------------------------------------+
int CArrayDatetime::QuickSearch(const datetime element) const
  {
   int  i,j,m=-1;
   long t_long;
//--- search
   i=0;
   j=m_data_total-1;
   while(j>=i)
     {
      //--- ">>1" is quick division by 2
      m=(j+i)>>1;
      if(m<0 || m>=m_data_total)
         break;
      t_long=m_data[m];
      if(t_long==element)
         break;
      if(t_long>element)
         j=m-1;
      else
         i=m+1;
     }
//--- position
   return(m);
  }
//+------------------------------------------------------------------+
//| Search of position of element in a sorted array                  |
//+------------------------------------------------------------------+
int CArrayDatetime::Search(const datetime element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos]==element)
      return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than       |
//| specified in a sorted array                                      |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchGreat(const datetime element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   pos=QuickSearch(element);
   while(m_data[pos]<=element)
      if(++pos==m_data_total)
         return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than          |
//| specified in the sorted array                                    |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchLess(const datetime element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   pos=QuickSearch(element);
   while(m_data[pos]>=element)
      if(pos--==0)
         return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than or    |
//| equal to the specified in a sorted array                         |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchGreatOrEqual(const datetime element) const
  {
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   for(int pos=QuickSearch(element);pos<m_data_total;pos++)
      if(m_data[pos]>=element)
         return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than or equal |
//| to the specified in a sorted array                               |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchLessOrEqual(const datetime element) const
  {
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   for(int pos=QuickSearch(element);pos>=0;pos--)
      if(m_data[pos]<=element)
         return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of first appearance of element in a sorted array   |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchFirst(const datetime element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos]==element)
     {
      while(m_data[pos]==element)
         if(pos--==0)
            break;
      return(pos+1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of last appearance of element in a sorted array    |
//+------------------------------------------------------------------+
int CArrayDatetime::SearchLast(const datetime element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !IsSorted())
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos]==element)
     {
      while(m_data[pos]==element)
         if(++pos==m_data_total)
            break;
      return(pos-1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Writing array to file                                            |
//+------------------------------------------------------------------+
bool CArrayDatetime::Save(const int file_handle)
  {
   int i=0;
//--- check
   if(!CArray::Save(file_handle))
      return(false);
//--- write array length
   if(FileWriteInteger(file_handle,m_data_total,INT_VALUE)!=INT_VALUE)
      return(false);
//--- write array
   for(i=0;i<m_data_total;i++)
      if(FileWriteLong(file_handle,m_data[i])!=sizeof(long))
         break;
//--- result
   return(i==m_data_total);
  }
//+------------------------------------------------------------------+
//| Reading array from file                                          |
//+------------------------------------------------------------------+
bool CArrayDatetime::Load(const int file_handle)
  {
   int i=0,num;
//--- check
   if(!CArray::Load(file_handle))
      return(false);
//--- read array length
   num=FileReadInteger(file_handle,INT_VALUE);
//--- read array
   Clear();
   if(num!=0)
     {
      if(!Reserve(num))
         return(false);
      for(i=0;i<num;i++)
        {
         m_data[i]=(datetime)FileReadLong(file_handle);
         m_data_total++;
         if(FileIsEnding(file_handle))
            break;
        }
     }
   m_sort_mode=-1;
//--- result
   return(m_data_total==num);
  }
//+------------------------------------------------------------------+
