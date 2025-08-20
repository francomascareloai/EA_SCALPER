#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_color4 White
#property indicator_color5 Gold
#property indicator_color6 Magenta
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 2
#property indicator_width6 2

extern int p = 10;
extern int s = 5;
extern int cb = 1000;
extern int ATR = 1000;
extern double distance = 2.0;
extern int arrots = 15;
extern int barsig = 1;

double fx1[],fx2[],hp[];
double z1,z2,ki;
int fs;

double upper[],lower[];
double upar[],dnar[];

int init()
{
IndicatorBuffers(7);
SetIndexBuffer(0,fx1);
SetIndexBuffer(1,fx2);
SetIndexBuffer(2,lower);
SetIndexBuffer(3,upper);

SetIndexBuffer(4,upar);
SetIndexStyle (4,DRAW_ARROW);
SetIndexArrow (4,233);
SetIndexBuffer(5,dnar);
SetIndexStyle (5,DRAW_ARROW);
SetIndexArrow (5,234);

SetIndexBuffer(6,hp);
SetIndexStyle(2,DRAW_LINE);
SetIndexStyle(3,DRAW_LINE);
SetIndexEmptyValue(0,0.0);
SetIndexEmptyValue(1,0.0);

ki=2.0/(p+1);

return(0);
}

int start()
{
SetIndexDrawBegin(0,Bars-cb);
SetIndexDrawBegin(1,Bars-cb);

double avg;

for (int i=cb; i>=0; i--) {fx1[i]=Close[i];}

for (int m=0; m<=s; m++)
{
z1=fx1[0];
for (i=0; i<=cb; i++) {z1=z1+(fx1[i]-z1)*ki; hp[i]=z1;}

z2=fx1[cb];
for (i=cb; i>=0; i--) {z2=z2+(fx1[i]-z2)*ki; fx1[i]=(hp[i]+z2)/2;}
}

fs=0;
for (i=cb; i>=0; i--)
{
if (fx1[i]>fx1[i+1]) fs=1;
if (fx1[i]<fx1[i+1]) {if (fs==1) fx2[i+1]=fx1[i+1]; fs=2;}
if (fs==2) fx2[i]=fx1[i]; else fx2[i]=0.0;

avg = iATR(NULL,0,ATR, i+10);
upper[i] = hp[i] + distance*avg;
lower[i] = hp[i] - distance*avg;

if(Close[i+1+barsig]<upper[i+1+barsig] && Close[i+barsig]>upper[i+barsig])
 dnar[i] = High[i]+arrots*Point; else dnar[i] = EMPTY_VALUE;
 
if(Close[i+1+barsig]>lower[i+1+barsig] && Close[i+barsig]<lower[i+barsig])
 upar[i] = Low[i]-arrots*Point; else upar[i] = EMPTY_VALUE; 
}
return(0);
}