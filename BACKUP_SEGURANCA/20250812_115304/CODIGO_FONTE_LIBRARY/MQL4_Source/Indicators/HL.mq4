//+------------------------------------------------------------------+
//| H_L.mq4 |
//| Copyright © 2004, MetaQuotes Software Corp. |
//| http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Yellow
//---- input parameters
extern int S=4;
//---- buffers
double ID_0[];
double ID_1[];
double ID_2[];
double ID_3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
IndicatorBuffers(4);
SetIndexBuffer(0,ID_0);
SetIndexBuffer(1,ID_1);
SetIndexBuffer(2,ID_2);
SetIndexBuffer(3,ID_3); 
//---- indicators
SetIndexStyle(0,DRAW_LINE);
SetIndexStyle(1,DRAW_LINE);
SetIndexStyle(2,DRAW_LINE);
SetIndexStyle(3,DRAW_LINE);
//----//
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int limit;
int counted_bars=IndicatorCounted();
if (counted_bars<0) return (-1);
if (counted_bars>0) counted_bars--;
limit=Bars-counted_bars;
int A1=0;int A1d=0;
int A2=0;int A2d=0;
int V1=0;int V1d=0;
int V2=0;int V2d=0;
int AX=0;int AXd=0;
int BX=0;int BXd=0;
int CX=0;int CXd=0;
int DX=0;int DXd=0;

for (int cnt1=0; cnt1<limit; cnt1++) 
{
ID_0[cnt1]=High[cnt1];
ID_1[cnt1]=Low[cnt1];
ID_2[cnt1]=(Open[cnt1]+Close[cnt1])/2;
ID_3[cnt1]=(Open[cnt1]+Close[cnt1])/2;
}
for (int cnt2=0;cnt2<S;cnt2++) 
{ 
AX=0;BX=0;CX=0;DX=0;A1=0;A2=0;V1=0;V2=0; 
AXd=0;BXd=0;CXd=0;DXd=0;A1d=0;A2d=0;V1d=0;V2d=0;

for (int cnt3=limit-1;cnt3>=0;cnt3--)
{//---------------------------------------------------
if (cnt3>0 && ID_0[cnt3]<ID_0[cnt3-1])
{ 
AX=cnt3-1;
BX=AX;
}
if (cnt3>0 && ID_0[cnt3]==ID_0[cnt3-1] && AX>0)
{ 
BX=cnt3-1;
} 
if (cnt3>0 && ID_0[cnt3]>ID_0[cnt3-1] && AX>0) //
{ 
if (A1==0) 
{
A1=(AX+BX)/2;
}
if (A1>0) 
{
A2=(AX+BX)/2;
}
if (A1>0 && A2>0) 
{
for (int cnt4=1;cnt4<=A1-A2;cnt4++)
{
ID_0[A2+cnt4]=ID_0[A2]+(((ID_0[A1]-ID_0[A2])*cnt4)/(A1-A2));
}
A1=A2;
A2=0;
} 
}
//-----------------------------------------------
if (cnt3>0 && ID_1[cnt3]>ID_1[cnt3-1])
{ 
CX=cnt3-1;
DX=CX;
}
if (cnt3>0 && ID_1[cnt3]==ID_1[cnt3-1] && CX>0)
{ 
DX=cnt3-1;
} 
if (cnt3>0 && ID_1[cnt3]<ID_1[cnt3-1] && CX>0) 
{ 
if (V1==0) 
{
V1=(CX+DX)/2;
}
if (V1>0) 
{
V2=(CX+DX)/2;
}
if (V1>0 && V2>0) 
{
for (int cnt5=1;cnt5<=V1-V2;cnt5++) 
{
ID_1[V2+cnt5]=ID_1[V2]+(((ID_1[V1]-ID_1[V2])*cnt5)/(V1-V2));
}
V1=V2;
V2=0;
} 
}
//---------------------------------------------------
//---------------------------------------------------
if (cnt3>0 && ID_2[cnt3]<ID_2[cnt3-1])
{ 
AXd=cnt3-1;
BXd=AXd;
}
if (cnt3>0 && ID_2[cnt3]==ID_2[cnt3-1] && AXd>0)
{ 
BXd=cnt3-1;
} 
if (cnt3>0 && ID_2[cnt3]>ID_2[cnt3-1] && AXd>0) 
{ 
if (A1d==0) 
{
A1d=(AXd+BXd)/2;
}
if (A1d>0) 
{
A2d=(AXd+BXd)/2;
}
if (A1d>0 && A2d>0) 
{
for (int cnt41=1;cnt41<=A1d-A2d;cnt41++) 
{
ID_2[A2d+cnt41]=ID_2[A2d]+(((ID_2[A1d]-ID_2[A2d])*cnt41)/(A1d-A2d));
}
A1d=A2d;
A2d=0;
} 
}
//-----------------------------------------------
if (cnt3>0 && ID_3[cnt3]>ID_3[cnt3-1])
{ 
CXd=cnt3-1;
DXd=CXd;
}
if (cnt3>0 && ID_3[cnt3]==ID_3[cnt3-1] && CXd>0)
{ 
DXd=cnt3-1;
} 
if (cnt3>0 && ID_3[cnt3]<ID_3[cnt3-1] && CXd>0) 
{ 
if (V1d==0) 
{
V1d=(CXd+DXd)/2;
}
if (V1d>0) 
{
V2d=(CXd+DXd)/2;
}
if (V1d>0 && V2d>0) 
{
for (int cnt51=1;cnt51<=V1d-V2d;cnt51++) 
{
ID_3[V2d+cnt51]=ID_3[V2d]+(((ID_3[V1d]-ID_3[V2d])*cnt51)/(V1d-V2d));
}
V1d=V2d;
V2d=0;
} 
} 
}//-----------------------------------------------------
} 

return(0);
}