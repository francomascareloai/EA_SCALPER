#property copyright "VMesquita"
#property indicator_chart_window // an indicator is drawn in the main chart window
#property indicator_buffers 1
int limit;
int init ()
{
//----
return(0);
}
int deinit()
{
return(0);
}
int start()
{
double O,C,H,L,O1,C1,H1,L1,O2,C2,H2,L2;
string text;
int counted_bars=IndicatorCounted();
limit=Bars-counted_bars;
//---- check for possible errors
if(counted_bars<0) {
Alert("No Bars..");
return(-1);
}
//---- last counted bar will be recounted
for(int i=1; i<limit; i++) {
O=iOpen(NULL,0,i);
C=iClose(NULL,0,i);
H=iHigh(NULL,0,i);
L=iLow(NULL,0,i);

O1=iOpen(NULL,0,i-1);
C1=iClose(NULL,0,i-1);
H1=iHigh(NULL,0,i-1);
L1=iLow(NULL,0,i-1);
O2=iOpen(NULL,0,i+1);
C2=iClose(NULL,0,i+1);
H2=iHigh(NULL,0,i+1);
L2=iLow(NULL,0,i+1);



text="";
if(((H-L)>4*(O-C))&&((C-L)/(0.001+H-L)>=0.75)&&((O-L)/
(0.001+H-L)>=0.75)) text="Hang";
if(((H-L)>3*(O-C))&&((C-L)/(0.001+H-L)>0.6)&&((O-L)/
(0.001+H-L)>0.6)) text="Hammer";
if(((H-L)>3*(O-C))&&((H-C)/(0.001+H-L)>0.6)&&((H-O)/
(0.001+H-L)>0.6)) text="IHammer";
if((O2>C2)&&((O2-C2)/(0.001+H2-L2)>0.6)&&(C2>O1)&&(O1>C1)&&
((H1-L1)>(3*(C1-O1)))&&(C>O)&&(O>O1)) text="MStar";
if((O>C)&&(H==O)&&(C==L)) text="LMarubozu";
if((C>O)&&(H==C)&&(O==L)) text="HMarubozu";
if((C1==O1)&&(C2>O2)&&(O>C)&&(L1>H2)&&(L1>H)) text="ABaby";
if((C1==O1)&&(O2>C2)&&(C>O)&&(L2>H1)&&(L>H1)) text="ABaby";
if((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&
((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) text="EStar";
if((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)&&(O>C1)&&(C>O1)&&((O-C)/
(0.001+(H-L))>0.6)) text="DCloud";
if((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1)))
text="Engulf";
if((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1)))
text="Engulf";
if((O1>C1)&&(C>O)&&(C<=O1)&&(C1<=O)&&((C-O)<(O1-C1)))
text="Harami";
if((C1>O1)&&(O>C)&&(O<=C1)&&(O1<=C)&&((O-C)<(C1-O1)))
text="Harami";
if((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)&&(O<C1)&&(C<O1)&&((C-O)/
(.001+(H-L))>0.6)) text="Piercing";
if((C>O*1.01)&&(C1>O1*1.01) &&(C2>O2*1.01) &&(C>C1) &&
(C1>C2) &&(O<C1&&O>O1) &&(O1<C2&&O1>O2) &&(((H-C)/(H-L))<0.2) &&(((H1-
C1)/(H1-L1))<0.2)&&(((H2-C2)/(H2-L2))<0.2)) text="Three White Soldiers";
if(((H-L)>4*(O-C))&&((H-C)/(0.001+H-L)>= 0.75)&&((H-O)/
(0.001+H-L)>=0.75)) text="SStar";
if(C==O) text="Doji";
//If we found a special candlem write in the Chart
if(text!="")
{
ObjectCreate(DoubleToStr(i,0)+" label", OBJ_TEXT, 0, Time
[i], H);
ObjectSetText(DoubleToStr(i,0)+" label", text, 10, "Arial",
Yellow);
}
}
}