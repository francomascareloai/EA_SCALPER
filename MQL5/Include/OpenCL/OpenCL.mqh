//+------------------------------------------------------------------+
//|                                                       OpenCL.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Class for working with OpenCL                                    |
//+------------------------------------------------------------------+
class COpenCL
  {
protected:
   int               m_context;
   int               m_program;
   //--- kernel
   string            m_kernel_names[];
   int               m_kernels[];
   int               m_kernels_total;
   //--- buffers
   int               m_buffers[];
   int               m_buffers_total;
   string            m_device_extensions;
   bool              m_support_cl_khr_fp64;

public:
                     COpenCL(void);
                    ~COpenCL(void);
   //--- get handles
   int               GetContext(void) const { return(m_context); }
   int               GetProgram(void) const { return(m_program); }
   int               GetKernel(const int kernel_index) const;
   string            GetKernelName(const int kernel_index) const;
   //--- global and local memory size
   bool              GetGlobalMemorySize(long &global_memory_size);
   bool              GetLocalMemorySize(long &local_memory_size);
   //--- maximal workgroup size
   bool              GetMaxWorkgroupSize(long &max_workgroup_size);
   //--- check support working with double
   bool              SupportDouble(void) const { return(m_support_cl_khr_fp64); }
   //--- initialization and shutdown
   bool              Initialize(const string program,const bool show_log=true);
   void              Shutdown(void);

   bool              ContextCreate(const int device=CL_USE_ANY);
   void              ContextClean(void);

   bool              ProgramCreate(const string program,const bool show_log=true);
   void              ProgramDelete(void);
   //--- set buffers/kernels count
   bool              SetBuffersCount(const int total_buffers);
   bool              SetKernelsCount(const int total_kernels);
   //--- kernel operations
   bool              KernelCreate(const int kernel_index,const string kernel_name);
   bool              KernelFree(const int kernel_index);
   //--- device and kernel info
   long              GetDeviceInfo(const int prop);
   long              GetDeviceInfoInteger(ENUM_OPENCL_PROPERTY_INTEGER prop);
   long              GetKernelInfoInteger(const int kernel_index,ENUM_OPENCL_PROPERTY_INTEGER prop);
   //--- buffer operations
   bool              BufferCreate(const int buffer_index,const uint size_in_bytes,const uint flags);
   bool              BufferFree(const int buffer_index);
   template<typename T>
   bool              BufferFromArray(const int buffer_index,T &data[],const uint data_array_offset,const uint data_array_count,const uint flags);
   template<typename T>
   bool              BufferFromMatrix(const int buffer_index,matrix<T> &data,const uint flags);
   template<typename T>
   bool              BufferFromVector(const int buffer_index,vector<T> &data,const uint flags);
   template<typename T>
   bool              BufferToMatrix(const int buffer_index,matrix<T> &data,const ulong rows=-1,const ulong cols=-1);
   template<typename T>
   bool              BufferToVector(const int buffer_index,vector<T> &data,const ulong size=-1);
   template<typename T>
   bool              BufferRead(const int buffer_index,T &data[],const uint cl_buffer_offset,const uint data_array_offset,const uint data_array_count);
   template<typename T>
   bool              BufferWrite(const int buffer_index,T &data[],const uint cl_buffer_offset,const uint data_array_offset,const uint data_array_count);
   //--- set kernel arguments
   template<typename T>
   bool              SetArgument(const int kernel_index,const int arg_index,T value);
   bool              SetArgumentBuffer(const int kernel_index,const int arg_index,const int buffer_index);
   bool              SetArgumentLocalMemory(const int kernel_index,const int arg_index,const int local_memory_size);
   //--- kernel execution
   bool              Execute(const int kernel_index,const int work_dim,const uint &work_offset[],const uint &work_size[]);
   bool              Execute(const int kernel_index,const int work_dim,const uint &work_offset[],const uint &work_size[],const uint &local_work_size[]);
   //--- kernel execution status
   ENUM_OPENCL_EXECUTION_STATUS ExecutionStatus(const int kernel_index);
  };
//+------------------------------------------------------------------+
//| COpenCL class constructor                                        |
//+------------------------------------------------------------------+
COpenCL::COpenCL(void)
  {
   m_context=INVALID_HANDLE;
   m_program=INVALID_HANDLE;
   m_buffers_total=0;
   m_kernels_total=0;
   m_device_extensions="";
   m_support_cl_khr_fp64=false;
  }
//+------------------------------------------------------------------+
//| COpenCL class destructor                                         |
//+------------------------------------------------------------------+
COpenCL::~COpenCL(void)
  {
   Shutdown();
  }
//+------------------------------------------------------------------+
//| GetKernel                                                        |
//+------------------------------------------------------------------+
int COpenCL::GetKernel(const int kernel_index) const
  {
//--- check parameters
   if(m_kernels_total<=0 || kernel_index<0 || kernel_index>=m_kernels_total)
      return(INVALID_HANDLE);
//---
   return m_kernels[kernel_index];
  }
//+------------------------------------------------------------------+
//| GetKernelName                                                    |
//+------------------------------------------------------------------+
string COpenCL::GetKernelName(const int kernel_index) const
  {
//--- check parameters
   if(m_kernels_total<=0 || kernel_index<0 || kernel_index>=m_kernels_total)
      return("");
//---
   return m_kernel_names[kernel_index];
  }
//+------------------------------------------------------------------+
//| GetGlobalMemorySize                                              |
//+------------------------------------------------------------------+
bool COpenCL::GetGlobalMemorySize(long &global_memory_size)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);
//--- get global memory size
   global_memory_size=CLGetInfoInteger(m_context,CL_DEVICE_GLOBAL_MEM_SIZE);

   if(global_memory_size==-1)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| GetLocalMemorySize                                               |
//+------------------------------------------------------------------+
bool COpenCL::GetLocalMemorySize(long &local_memory_size)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);
//--- get local memory size
   local_memory_size=CLGetInfoInteger(m_context,CL_DEVICE_LOCAL_MEM_SIZE);

   if(local_memory_size==-1)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| GetMaxWorkgroupSize                                              |
//+------------------------------------------------------------------+
bool COpenCL::GetMaxWorkgroupSize(long &max_workgroup_size)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);
//--- get maximal workgroup size
   max_workgroup_size=CLGetInfoInteger(m_context,CL_DEVICE_MAX_WORK_GROUP_SIZE);
   if(max_workgroup_size==-1)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool COpenCL::Initialize(const string program,const bool show_log)
  {
//--- create context
   if(!ContextCreate(CL_USE_ANY))
      return(false);
//---
   return(ProgramCreate(program,show_log));
  }
//+------------------------------------------------------------------+
//| ContextCreate                                                    |
//+------------------------------------------------------------------+
bool COpenCL::ContextCreate(const int device)
  {
//--- remove context
   if(m_context!=INVALID_HANDLE)
     {
      CLContextFree(m_context);
      m_context=INVALID_HANDLE;
     }
//--- create context
   if((m_context=CLContextCreate(device))==INVALID_HANDLE)
     {
      Print("OpenCL not found, error code=",GetLastError());
      return(false);
     }
//--- check support working with doubles (cl_khr_fp64)
   m_support_cl_khr_fp64=false;
   if(CLGetInfoString(m_context,CL_DEVICE_EXTENSIONS,m_device_extensions))
     {
      int    size;
      string extenstions[];
      //---
      StringSplit(m_device_extensions,' ',extenstions);

      size=ArraySize(extenstions);
      for(int i=0; i<size; i++)
         if(extenstions[i]=="cl_khr_fp64")
           {
            m_support_cl_khr_fp64=true;
            break;
           }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ProgramCreate                                                    |
//+------------------------------------------------------------------+
bool COpenCL::ProgramCreate(const string program,const bool show_log)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);
//--- remove program
   if(m_program!=INVALID_HANDLE)
     {
      CLProgramFree(m_program);
      m_program=INVALID_HANDLE;
     }
//--- compile the program
   string build_error_log;

   if((m_program=CLProgramCreate(m_context,program,build_error_log))==INVALID_HANDLE)
     {
      //--- show details
      if(show_log)
        {
         int    lines_count;
         string lines[];
         //---
         StringSplit(build_error_log,'\n',lines);

         lines_count=ArraySize(lines);
         for(int i=0; i<lines_count; i++)
            Print(lines[i]);
        }
      //---
      CLContextFree(m_context);
      Print("OpenCL program create failed, error code=",GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ProgramDelete                                                    |
//+------------------------------------------------------------------+
void COpenCL::ProgramDelete(void)
  {
//--- remove program
   if(m_program!=INVALID_HANDLE)
     {
      CLProgramFree(m_program);
      m_program=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| ContextClean                                                     |
//+------------------------------------------------------------------+
void COpenCL::ContextClean(void)
  {
//--- remove buffers
   if(m_buffers_total>0)
     {
      for(int i=0; i<m_buffers_total; i++)
         BufferFree(i);
      m_buffers_total=0;
     }
//--- remove buffers
   if(m_kernels_total>0)
     {
      for(int i=0; i<m_kernels_total; i++)
         KernelFree(i);
      m_kernels_total=0;
     }
//--- remove program
   if(m_program!=INVALID_HANDLE)
     {
      CLProgramFree(m_program);
      m_program=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| Shutdown                                                         |
//+------------------------------------------------------------------+
void COpenCL::Shutdown(void)
  {
   ContextClean();
//--- remove context
   if(m_context!=INVALID_HANDLE)
     {
      CLContextFree(m_context);
      m_context=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| SetBuffersCount                                                  |
//+------------------------------------------------------------------+
bool COpenCL::SetBuffersCount(const int total_buffers)
  {
//--- check parameters
   if(total_buffers<=0)
      return(false);
//---
   m_buffers_total=total_buffers;

   if(ArraySize(m_buffers)<m_buffers_total)
      ArrayResize(m_buffers,m_buffers_total);

   for(int i=0; i<m_buffers_total; i++)
      m_buffers[i]=INVALID_HANDLE;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| SetKernelsCount                                                  |
//+------------------------------------------------------------------+
bool COpenCL::SetKernelsCount(const int total_kernels)
  {
//--- check parameters
   if(total_kernels<=0)
      return(false);
//---
   m_kernels_total=total_kernels;

   if(ArraySize(m_kernels)<m_kernels_total)
      ArrayResize(m_kernels,m_kernels_total);

   if(ArraySize(m_kernel_names)<m_kernels_total)
      ArrayResize(m_kernel_names,m_kernels_total);
//---
   for(int i=0; i<m_kernels_total; i++)
     {
      m_kernel_names[i]="";
      m_kernels[i]=INVALID_HANDLE;
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| KernelCreate                                                     |
//+------------------------------------------------------------------+
bool COpenCL::KernelCreate(const int kernel_index,const string kernel_name)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);

   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);
//---
   int kernel_handle=m_kernels[kernel_index];

   if(kernel_handle==INVALID_HANDLE || m_kernel_names[kernel_index]!=kernel_name)
     {
      //--- create kernel
      if((kernel_handle=CLKernelCreate(m_program,kernel_name))==INVALID_HANDLE)
        {
         //--- cleanup
         CLProgramFree(m_program);
         m_program=INVALID_HANDLE;

         CLContextFree(m_context);
         m_context=INVALID_HANDLE;

         Print("OpenCL kernel create failed, error code=",GetLastError());
         return(false);
        }
      //---
      m_kernels[kernel_index]=kernel_handle;
      m_kernel_names[kernel_index]=kernel_name;
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| KernelFree                                                       |
//+------------------------------------------------------------------+
bool COpenCL::KernelFree(const int kernel_index)
  {
//--- check kernel index
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);

   if(m_kernels[kernel_index]==INVALID_HANDLE)
      return(false);
//--- free kernel handle
   CLKernelFree(m_kernels[kernel_index]);
   m_kernels[kernel_index]=INVALID_HANDLE;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| GetDeviceInfo                                                    |
//+------------------------------------------------------------------+
long COpenCL::GetDeviceInfo(const int prop)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(-1);
//---
   uchar data[];
   uint  size=0;

   if(!CLGetDeviceInfo(m_context,prop,data,size))
      return(-1);

   if(size<4)
      return(-1);
//---
   union res_data
     {
      uchar cdata[8];
      long  ldata;
     } res;

   if(size<=8)
     {
      ZeroMemory(res);
      ArrayCopy(res.cdata,data);
     }
   else
      ArrayCopy(res.cdata,data,0,8);
//---
   return(res.ldata);
  }
//+------------------------------------------------------------------+
//| GetDeviceInfoInteger                                             |
//+------------------------------------------------------------------+
long COpenCL::GetDeviceInfoInteger(ENUM_OPENCL_PROPERTY_INTEGER prop)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(-1);
//---
   return(CLGetInfoInteger(m_context,prop));
  }
//+------------------------------------------------------------------+
//| GetKernelInfoInteger                                             |
//+------------------------------------------------------------------+
long COpenCL::GetKernelInfoInteger(const int kernel_index,ENUM_OPENCL_PROPERTY_INTEGER prop)
  {
//--- check parameters
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(-1);
//---
   return(CLGetInfoInteger(m_kernels[kernel_index],prop));
  }
//+------------------------------------------------------------------+
//| BufferCreate                                                     |
//+------------------------------------------------------------------+
bool COpenCL::BufferCreate(const int buffer_index,const uint size_in_bytes,const uint flags)
  {
//--- check parameters
   if(buffer_index<0 || buffer_index>=m_buffers_total)
      return(false);

   if(m_context==INVALID_HANDLE)
      return(false);
//---
   int buffer_handle=CLBufferCreate(m_context,size_in_bytes,flags);

   if(buffer_handle!=INVALID_HANDLE)
     {
      m_buffers[buffer_index]=buffer_handle;
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| BufferFree                                                       |
//+------------------------------------------------------------------+
bool COpenCL::BufferFree(const int buffer_index)
  {
//--- check buffer index
   if(buffer_index<0 || buffer_index>=m_buffers_total)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);
//--- free buffer handle
   CLBufferFree(m_buffers[buffer_index]);
   m_buffers[buffer_index]=INVALID_HANDLE;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BufferFromArray                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferFromArray(const int buffer_index,T &data[],const uint data_array_offset,const uint data_array_count,const uint flags)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);

   if(buffer_index<0 || buffer_index>=m_buffers_total || data_array_count<=0)
      return(false);
//--- buffer does not exists, create it
   if(m_buffers[buffer_index]==INVALID_HANDLE)
     {
      uint size_in_bytes=data_array_count*sizeof(T);
      int  buffer_handle=CLBufferCreate(m_context,size_in_bytes,flags);
      //---
      if(buffer_handle==INVALID_HANDLE)
         return(false);

      m_buffers[buffer_index]=buffer_handle;
     }
//--- write data to OpenCL buffer
   uint data_written=CLBufferWrite(m_buffers[buffer_index],data,0,data_array_offset,data_array_count);

   if(data_written!=data_array_count)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BufferWriteFromMatrix                                            |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferFromMatrix(const int buffer_index,matrix<T> &data,const uint flags)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);

   if(buffer_index<0 || buffer_index>=m_buffers_total || data.Rows()==0 || data.Cols()==0)
      return(false);
//--- buffer does not exists, create it
   if(m_buffers[buffer_index]==INVALID_HANDLE)
     {
      uint matrix_size  =uint(data.Rows()*data.Cols());
      uint size_in_bytes=matrix_size*sizeof(T);
      int  buffer_handle=CLBufferCreate(m_context,size_in_bytes,flags);
      //---
      if(buffer_handle==INVALID_HANDLE)
         return(false);

      m_buffers[buffer_index]=buffer_handle;
     }
//--- write data to OpenCL buffer
   return(CLBufferWrite(m_buffers[buffer_index],0,data));
  }
//+------------------------------------------------------------------+
//| BufferWriteFromVector                                            |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferFromVector(const int buffer_index,vector<T> &data,const uint flags)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE)
      return(false);

   if(buffer_index<0 || buffer_index>=m_buffers_total || data.Size()==0)
      return(false);
//--- buffer does not exists, create it
   if(m_buffers[buffer_index]==INVALID_HANDLE)
     {
      uint size_in_bytes=(uint)data.Size()*sizeof(T);
      int  buffer_handle=CLBufferCreate(m_context,size_in_bytes,flags);
      //---
      if(buffer_handle==INVALID_HANDLE)
         return(false);

      m_buffers[buffer_index]=buffer_handle;
     }
//--- write data to OpenCL buffer
   return(CLBufferWrite(m_buffers[buffer_index],0,data));
  }
//+------------------------------------------------------------------+
//| BufferReadToMatrix                                               |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferToMatrix(const int buffer_index,matrix<T> &data,const ulong rows,const ulong cols)
  {
//--- check parameters
   if(buffer_index<0 || buffer_index>=m_buffers_total)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);

   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);
//--- read data from OpenCL buffer
   return(CLBufferRead(m_buffers[buffer_index],0,data,rows,cols));
  }
//+------------------------------------------------------------------+
//| BufferReadToVector                                               |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferToVector(const int buffer_index,vector<T> &data,const ulong size)
  {
//--- check parameters
   if(buffer_index<0 || buffer_index>=m_buffers_total)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);

   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);
//--- read data from OpenCL buffer
   return(CLBufferRead(m_buffers[buffer_index],0,data,size));
  }
//+------------------------------------------------------------------+
//| BufferRead                                                       |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferRead(const int buffer_index,T &data[],const uint cl_buffer_offset,const uint data_array_offset,const uint data_array_count)
  {
//--- check parameters
   if(buffer_index<0 || buffer_index>=m_buffers_total || data_array_count<=0)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);

   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);
//--- read data from OpenCL buffer
   uint data_read=CLBufferRead(m_buffers[buffer_index],data,cl_buffer_offset,data_array_offset,data_array_count);

   if(data_read!=data_array_count)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BufferWrite                                                      |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::BufferWrite(const int buffer_index,T &data[],const uint cl_buffer_offset,const uint data_array_offset,const uint data_array_count)
  {
//--- check parameters
   if(buffer_index<0 || buffer_index>=m_buffers_total || data_array_count<=0)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);

   if(m_context==INVALID_HANDLE)
      return(false);
//--- write data to OpenCL buffer
   uint data_written=CLBufferWrite(m_buffers[buffer_index],data,cl_buffer_offset,data_array_offset,data_array_count);

   if(data_written!=data_array_count)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| SetArgument                                                      |
//+------------------------------------------------------------------+
template<typename T>
bool COpenCL::SetArgument(const int kernel_index,const int arg_index,T value)
  {
//--- check parameters
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);
//---
   int kernel_handle=m_kernels[kernel_index];

   if(kernel_handle==INVALID_HANDLE)
      return(false);
//---
   return CLSetKernelArg(kernel_handle,arg_index,value);
  }
//+------------------------------------------------------------------+
//| SetArgumentBuffer                                                |
//+------------------------------------------------------------------+
bool COpenCL::SetArgumentBuffer(const int kernel_index,const int arg_index,const int buffer_index)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);

   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);

   if(buffer_index<0 || buffer_index>=m_buffers_total)
      return(false);

   if(m_buffers[buffer_index]==INVALID_HANDLE)
      return(false);
//---
   return CLSetKernelArgMem(m_kernels[kernel_index],arg_index,m_buffers[buffer_index]);
  }
//+------------------------------------------------------------------+
//| SetArgumentLocalMemory                                           |
//+------------------------------------------------------------------+
bool COpenCL::SetArgumentLocalMemory(const int kernel_index,const int arg_index,const int local_memory_size)
  {
//--- check parameters
   if(m_context==INVALID_HANDLE || m_program==INVALID_HANDLE)
      return(false);

   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);
//--- check device local memory size
   long device_local_memory_size=CLGetInfoInteger(m_context,CL_DEVICE_LOCAL_MEM_SIZE);

   if(local_memory_size>device_local_memory_size)
      return(false);
//---
   return CLSetKernelArgMemLocal(m_kernels[kernel_index],arg_index,local_memory_size);
  }
//+------------------------------------------------------------------+
//| Execute                                                          |
//+------------------------------------------------------------------+
bool COpenCL::Execute(const int kernel_index,const int work_dim,const uint &work_offset[],const uint &work_size[])
  {
//--- check parameters
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);
//---
   int kernel_handle=m_kernels[kernel_index];

   if(kernel_handle==INVALID_HANDLE)
      return(false);
//---
   return CLExecute(kernel_handle,work_dim,work_offset,work_size);
  }
//+------------------------------------------------------------------+
//| Execute                                                          |
//+------------------------------------------------------------------+
bool COpenCL::Execute(const int kernel_index,const int work_dim,const uint &work_offset[],const uint &work_size[],const uint &local_work_size[])
  {
//--- check parameters
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(false);
//---
   return CLExecute(m_kernels[kernel_index],work_dim,work_offset,work_size,local_work_size);
  }
//+------------------------------------------------------------------+
//| Execution status                                                 |
//+------------------------------------------------------------------+
ENUM_OPENCL_EXECUTION_STATUS COpenCL::ExecutionStatus(const int kernel_index)
  {
//--- check parameters
   if(kernel_index<0 || kernel_index>=m_kernels_total)
      return(-1);
//---
   return CLExecutionStatus(m_kernels[kernel_index]);
  }
//+------------------------------------------------------------------+
