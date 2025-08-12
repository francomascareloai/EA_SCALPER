//+------------------------------------------------------------------+ 
//| RSTL.mq4 
//| 
//+------------------------------------------------------------------+ 
#property copyright "" 
#property link "" 

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Maroon 


//---- buffers 
double RSTLBuffer[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
{ 
string short_name; 
//---- indicator line 
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3); 
SetIndexBuffer(0,RSTLBuffer); 
SetIndexDrawBegin(0,98); 
//---- 
return(0); 
} 
//+------------------------------------------------------------------+ 
//| RSTL | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int i,counted_bars=IndicatorCounted(); 
//---- 
if(Bars<=98) return(0); 
//---- initial zero 
if(counted_bars<98) 
for(i=1;i<=0;i++) RSTLBuffer[Bars-i]=0.0; 
//---- 
i=Bars-98-1; 
if(counted_bars>=98) i=Bars-counted_bars-1; 
while(i>=0) 
{ 
RSTLBuffer[i]= 
-0.00514293*Close[i+0] 
-0.00398417*Close[i+1] 
-0.00262594*Close[i+2] 
-0.00107121*Close[i+3] 
+0.00066887*Close[i+4] 
+0.00258172*Close[i+5] 
+0.00465269*Close[i+6] 
+0.00686394*Close[i+7] 
+0.00919334*Close[i+8] 
+0.01161720*Close[i+9] 
+0.01411056*Close[i+10] 
+0.01664635*Close[i+11] 
+0.01919533*Close[i+12] 
+0.02172747*Close[i+13] 
+0.02421320*Close[i+14] 
+0.02662203*Close[i+15] 
+0.02892446*Close[i+16] 
+0.03109071*Close[i+17] 
+0.03309496*Close[i+18] 
+0.03490921*Close[i+19] 
+0.03651145*Close[i+20] 
+0.03788045*Close[i+21] 
+0.03899804*Close[i+22] 
+0.03984915*Close[i+23] 
+0.04042329*Close[i+24] 
+0.04071263*Close[i+25] 
+0.04071263*Close[i+26] 
+0.04042329*Close[i+27] 
+0.03984915*Close[i+28] 
+0.03899804*Close[i+29] 
+0.03788045*Close[i+30] 
+0.03651145*Close[i+31] 
+0.03490921*Close[i+32] 
+0.03309496*Close[i+33] 
+0.03109071*Close[i+34] 
+0.02892446*Close[i+35] 
+0.02662203*Close[i+36] 
+0.02421320*Close[i+37] 
+0.02172747*Close[i+38] 
+0.01919533*Close[i+39] 
+0.01664635*Close[i+40] 
+0.01411056*Close[i+41] 
+0.01161720*Close[i+42] 
+0.00919334*Close[i+43] 
+0.00686394*Close[i+44] 
+0.00465269*Close[i+45] 
+0.00258172*Close[i+46] 
+0.00066887*Close[i+47] 
-0.00107121*Close[i+48] 
-0.00262594*Close[i+49] 
-0.00398417*Close[i+50] 
-0.00514293*Close[i+51] 
-0.00609634*Close[i+52] 
-0.00684602*Close[i+53] 
-0.00739452*Close[i+54] 
-0.00774847*Close[i+55] 
-0.00791630*Close[i+56] 
-0.00790940*Close[i+57] 
-0.00774085*Close[i+58] 
-0.00742482*Close[i+59] 
-0.00697718*Close[i+60] 
-0.00641613*Close[i+61] 
-0.00576108*Close[i+62] 
-0.00502957*Close[i+63] 
-0.00423873*Close[i+64] 
-0.00340812*Close[i+65] 
-0.00255923*Close[i+66] 
-0.00170217*Close[i+67] 
-0.00085902*Close[i+68] 
-0.00004113*Close[i+69] 
+0.00073700*Close[i+70] 
+0.00146422*Close[i+71] 
+0.00213007*Close[i+72] 
+0.00272649*Close[i+73] 
+0.00324752*Close[i+74] 
+0.00368922*Close[i+75] 
+0.00405000*Close[i+76] 
+0.00433024*Close[i+77] 
+0.00453068*Close[i+78] 
+0.00465046*Close[i+79] 
+0.00469058*Close[i+80] 
+0.00466041*Close[i+81] 
+0.00457855*Close[i+82] 
+0.00442491*Close[i+83] 
+0.00423019*Close[i+84] 
+0.00399201*Close[i+85] 
+0.00372169*Close[i+86] 
+0.00342736*Close[i+87] 
+0.00311822*Close[i+88] 
+0.00280309*Close[i+89] 
+0.00249088*Close[i+90] 
+0.00219089*Close[i+91] 
+0.00191283*Close[i+92] 
+0.00166683*Close[i+93] 
+0.00146419*Close[i+94] 
+0.00131867*Close[i+95] 
+0.00124645*Close[i+96] 
+0.00126836*Close[i+97] 
-0.00401854*Close[i+98]; 

i--; 
} 
return(0); 
} 
//+------------------------------------------------------------------+  
 
        
 

