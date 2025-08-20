//---------------------SVS_Trend------
#property indicator_separate_window    
#property indicator_buffers 6
#property indicator_color1 White
#property indicator_color2 DarkGray
#property indicator_color3 Black
#property indicator_color4 MediumBlue
#property indicator_color5 FireBrick
#property indicator_color6 DarkGreen 
extern int p1=8;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//--------------------------------------
int init()
  {
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(5,ExtMapBuffer6);
   return(0);
  }
//---------------------------------------------------------
double hloc(int i,int p)
  {
   double hloc;
   hloc=0;
   for(int n=i;n<=i+p-1;n++)
     {
      hloc=hloc+((High[n]+Low[n]+Open[n]+Close[n])/4);
     }
   return(hloc/p);
  }
//------------------------------------------
int start()
  {
   double z,s1,v1,vts,vv,sv,svz,vj,vk,vd,ff;
//-----------------------------------
   int i;
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2*p1;

   i=limit;
   while(i>=0)
     {
      vts=0;
      z=(High[i]+Low[i]+Open[i]+Close[i])/4;
      s1=hloc(i,p1);
      for(int c=i;c<=(i+p1-1);c++)
        {
         vts=vts+hloc(c,p1);
         if(c==(i+p1-1))v1=vts/p1;
        }
      //---------------------------------               
      sv=(s1+v1)/2;
      svz=(sv+z)/2;
      ff=(svz-sv);
      vv=(s1-v1);
      vk=(vv+ff)/2;
      vd=(ff/2);
      vj=(vv-vd);
      //----------------------------
      ExtMapBuffer1[i]=vv;
      ExtMapBuffer2[i]=vk;
      ExtMapBuffer3[i]=vd;
      if(vd>0) ExtMapBuffer4[i]=vj;
      if(vd<0) ExtMapBuffer5[i]=vj;
      if(vd>0 && vk<vj) ExtMapBuffer6[i]=vj;
      if(vd<0 && vk>vj) ExtMapBuffer6[i]=vj;
      i--;
     }
   return(0);
  }

//--------------------------------------------------------------------
