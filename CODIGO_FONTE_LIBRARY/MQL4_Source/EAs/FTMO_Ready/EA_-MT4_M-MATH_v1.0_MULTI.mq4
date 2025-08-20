// THIS CODE IS POSTED SO THAT LIKE MINDED PAY IT FORWARD CODERS MAY
// IMPROVE ON IT AND REPOST IT ON THE FORUM FOR THEIR FELLOW TRADERS
//==================================================================
// [!!!-MT4 M-MATH]                  \¦/   
//                                  (ò ó)
//_____________________________o0o___(_)___o0o______________________ 
#property copyright "Welcome to the World of Forex"
#property indicator_chart_window 
    extern bool showMurreylines=false;
         double s1[]; int P=256,FW=800;
     extern int StepBack=0;
    extern bool show_timeleft=false,show_symbol_price=false;
     extern int win=0,Adjust_Side_to_side=10,Shift_UP_DN=0;
    extern bool showcomments=false;
//+------------------------------------------------------------------+
    extern bool bml_25_lines=false;
   extern color bml_25_color=DarkSlateGray;
     extern int bml_25_style=0;
//+------
    extern bool bml_33_lines=false;
   extern color bml_33_color=DarkSlateGray;
     extern int bml_33_style=0;
//+------
    extern bool bml_50_lines=false;
   extern color bml_50_color=DarkSlateGray;
     extern int bml_50_style=1;
//+------------------------------------------------------------------+ 
    bool color_frame=false;
   color MM1Color=clrNONE;     //C'0,90,90';
   color MM2Color=C'100,5,60'; //C'90,0,90';
   color MM3Color=clrNONE;     //C'0,30,90';
   color MM4Color=C'30,35,12';
//+------------------------------------------------------------------+
#define FF1 "FF1"
#define FF2 "FF2"
#define FF3 "FF3"
#define FF4 "FF4"
#define FF5 "FF5"
#define FF6 "FF6"
//+------------------------------------------------------------------+ 
   int l996=0,l1004=0;
   double bml_25[26],bml_33[26],bml_50[12];
   double dmml=0,dvtl=0,sum=0,v1=0,v2=0,mn=0,mx=0,
   x1=0,x2=0,x3=0,x4=0,x5=0,x6=0,
   y1=0,y2=0,y3=0,y4=0,y5=0,y6=0,
   octave=0,fractal=0,range=0,finalH=0,finalL=0,DecNos,mml[13];       
   string ln_txt[13],ln_tx[13],buff_str="",buff_str2="",buff_str3="",buff_str4="";
//+------------------------------------------------------------------+         
   int bn_v1=0,bn_v2=0,OctLinesCnt=13,mml_thk=8,mml_clr[13],mml_shft=3,nTime=0,CurPeriod=0,x33=0,x25=0,x50=0,
   nDigits=0,frametemp=0, i=0, gb=0,gb_T=0,mP=0,lperiod=0,d=0,ts=0,mml_wdth[13],
   bml_33_Cnt=26,bml_25_Cnt=38,bml_50_Cnt=12;
//+------------------------------------------------------------------+
   int init() {
   ln_txt[0] ="                 [-2/8]  ";
   ln_txt[1] ="                 [-1/8]  ";
   ln_txt[2] ="                 [0/8]  ";
   ln_txt[3] ="                 [1/8]  ";
   ln_txt[4] ="                 [2/8]  ";
   ln_txt[5] ="                 [3/8]  ";
   ln_txt[6] ="                 [4/8]  ";
   ln_txt[7] ="                 [5/8]  ";
   ln_txt[8] ="                 [6/8]  ";
   ln_txt[9] ="                 [7/8]  ";
   ln_txt[10]="                 [8/8]  ";
   ln_txt[11]="                 [+1/8]  ";
   ln_txt[12]="                 [+2/8]  ";
//+------------------------------------------------------------------+    
   mml_wdth[0] =2;
   mml_wdth[1] =2;
   mml_wdth[2] =2;
   mml_wdth[3] =2;
   mml_wdth[4] =2;
   mml_wdth[5] =2;
   mml_wdth[6] =2;
   mml_wdth[7] =2;
   mml_wdth[8] =2;
   mml_wdth[9] =2;
   mml_wdth[10]=2;
   mml_wdth[11]=2;
   mml_wdth[12]=2;
//+------------------------------------------------------------------+   
   ln_tx[0] ="";
   ln_tx[1] ="";
   ln_tx[2] ="";
   ln_tx[3] ="";
   ln_tx[4] ="";
   ln_tx[5] ="";
   ln_tx[6] ="";
   ln_tx[7] ="";
   ln_tx[8] ="";
   ln_tx[9] ="";
   ln_tx[10]="";
   ln_tx[11]="";
   ln_tx[12]="";
//+------------------------------------------------------------------+ 
   mml_shft=0; mml_thk=3;
//+------------------------------------------------------------------+  
   mml_clr[0] =clrRed;        // [-2]/8
   mml_clr[1] =clrOrange;     // [-1]/8
   mml_clr[2] =clrDeepSkyBlue;//  [0]/8
   mml_clr[3] =clrYellow;     //  [1]/8
   mml_clr[4] =clrDeepPink;   //  [2]/8
   mml_clr[5] =clrLime;       //  [3]/8
   mml_clr[6] =clrDeepSkyBlue;//  [4]/8
   mml_clr[7] =clrLime;       //  [5]/8
   mml_clr[8] =clrDeepPink;   //  [6]/8
   mml_clr[9] =clrYellow;     //  [7]/8
   mml_clr[10]=clrDeepSkyBlue;//  [8]/8
   mml_clr[11]=clrOrange;     // [+1]/8
   mml_clr[12]=clrRed;        // [+2]/8
//+------------------------------------------------------------------+ 
   bn_v1=Lowest(NULL,0,MODE_LOW,0); bn_v2=Highest(NULL,0,MODE_HIGH,0);
   v1=Low[bn_v1]; v2=High[bn_v2]; return(0);}
//+------------------------------------------------------------------+
   int deinit() {Comment(" ");   
   for(i=0; i<OctLinesCnt; i++) {
   buff_str="mml"+i; ObjectDelete(buff_str);
   buff_str="mml_txt"+i; ObjectDelete(buff_str);}
   ObjectDelete(FF1);
   ObjectDelete(FF2);
   ObjectDelete(FF3);
   ObjectDelete(FF4);
   ObjectDelete(FF5);
   ObjectDelete(FF6);
   
   for(x25=0;x25<bml_25_Cnt;x25++) {buff_str3="bml_25"+x25; ObjectDelete(buff_str3);}
   for(x33=0;x33<bml_33_Cnt;x33++) {buff_str2="bml_33"+x33; ObjectDelete(buff_str2);}
   for(x50=0;x50<bml_50_Cnt;x50++) {buff_str4="bml_50"+x50; ObjectDelete(buff_str4);}  
//----      
   ObjectsDeleteAll(0,OBJ_TREND);
   ObjectsDeleteAll(0,OBJ_TEXT); 
   ObjectsDeleteAll(0,OBJ_LABEL);
   ObjectsDeleteAll(2,OBJ_LABEL);
   ObjectsDeleteAll(win,OBJ_LABEL);
   ObjectsDeleteAll(0,OBJ_VLINE); return(0);}
//+------------------------------------------------------------------+   
   int start() {if(StringFind (Symbol(),"JPY",0)!=-1){DecNos=2;} else {DecNos=3;} 
   double r; int m,s; m=Time[0]+Period()*60-CurTime(); r=m/60.0; s=m%60; m=(m-m%60)/60;

   if(show_timeleft) {
    ObjectDelete("xard1");
    ObjectCreate("xard1",OBJ_LABEL,win,0,0);
   ObjectSetText("xard1",m+":"+s,14,"MV Boli",Silver);
       ObjectSet("xard1",OBJPROP_CORNER,1);
       ObjectSet("xard1",OBJPROP_XDISTANCE,Adjust_Side_to_side+135);
       ObjectSet("xard1",OBJPROP_YDISTANCE,Shift_UP_DN+20);}
      
   if(show_symbol_price) {   
    ObjectDelete("v2");
    ObjectCreate("v2",OBJ_LABEL,win,0,0);
   ObjectSetText("v2",DoubleToStr(v2,Digits),14,"MV Boli",Blue);
       ObjectSet("v2",OBJPROP_CORNER,1);
       ObjectSet("v2",OBJPROP_XDISTANCE,Adjust_Side_to_side+130);
       ObjectSet("v2",OBJPROP_YDISTANCE,Shift_UP_DN+0);
 
    ObjectDelete("v1");
    ObjectCreate("v1",OBJ_LABEL,win,0,0);
   ObjectSetText("v1",DoubleToStr(v1,Digits),14,"MV Boli",Crimson);
       ObjectSet("v1",OBJPROP_CORNER,1);
       ObjectSet("v1",OBJPROP_XDISTANCE,Adjust_Side_to_side+130);
       ObjectSet("v1",OBJPROP_YDISTANCE,Shift_UP_DN+20);
        
    ObjectDelete("xard2");
    ObjectCreate("xard2",OBJ_LABEL,win,0,0);
   ObjectSetText("xard2",DoubleToStr(Bid,Digits),25,"MV Boli",Yellow);
       ObjectSet("xard2",OBJPROP_CORNER,1);
       ObjectSet("xard2",OBJPROP_XDISTANCE,Adjust_Side_to_side+0);
       ObjectSet("xard2",OBJPROP_YDISTANCE,Shift_UP_DN+0);}
//+------------------------------------------------------------------+ 
   CreateMM(); return(0);}
   void CreateObj(string objName,double start,double end,color clr) {
   ObjectCreate(objName,OBJ_RECTANGLE,0,Time[0+FW],start,Time[0],end);
      ObjectSet(objName,OBJPROP_COLOR,clr);}
   void DeleteObjects(){
   ObjectDelete(FF1);
   ObjectDelete(FF2);
   ObjectDelete(FF3);
   ObjectDelete(FF4);
   ObjectDelete(FF5);
   ObjectDelete(FF6);}
//+------------------------------------------------------------------+   
   void CreateMM() {DeleteObjects();
//+------------------------------------------------------------------+    
   v1=(Close[Lowest (NULL,0,MODE_CLOSE,P+StepBack,0)]);
   v2=(Close[Highest(NULL,0,MODE_CLOSE,P+StepBack,0)]);
//+------------------------------------------------------------------+    
   if(v2<=250000 && v2>25000) fractal=100000;
   else if(v2<=25000 && v2>2500) fractal=10000;
   else if(v2<=2500 && v2>250) fractal=1000;
   else if(v2<=250 && v2>25) fractal=100;
   else if(v2<=25 && v2>12.5) fractal=12.5;
   else if(v2<=12.5 && v2>6.25) fractal=12.5;
   else if(v2<=6.25 && v2>3.125) fractal=6.25;
   else if(v2<=3.125 && v2>1.5625) fractal=3.125;
   else if(v2<=1.5625 && v2>0.390625) fractal=1.5625;
   else if(v2<=0.390625 && v2>0) fractal=0.1953125;
//+------------------------------------------------------------------+       
   range=(v2-v1);
   sum=MathFloor(MathLog(fractal/range)/MathLog(2));
   octave=fractal*(MathPow(0.5,sum));
   mn=MathFloor(v1/octave)*octave;
   if((mn+octave)>v2) mx=mn+octave; else mx=mn+(2*octave);
//+------------------------------------------------------------------+ 
   if((v1>=(3*(mx-mn)/16+mn)) && (v2<=(9*(mx-mn)/16+mn))) x2=mn+(mx-mn)/2; else x2=0;
   if((v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0)) x1=mn+(mx-mn)/2; else x1=0;
   if((v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn))) x4=mn+3*(mx-mn)/4; else x4=0;
   if((v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0)) x5=mx; else x5=0;
   if((v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0))
   x3=mn+3*(mx-mn)/4; else x3=0;
   if((x1+x2+x3+x4+x5)==0) x6=mx; else x6=0;
   finalH=x1+x2+x3+x4+x5+x6;
   if(x1>0) y1=mn; else y1=0;
   if(x2>0) y2=mn+(mx-mn)/4; else y2=0;
   if(x3>0) y3=mn+(mx-mn)/4; else y3=0;
   if(x4>0) y4=mn+(mx-mn)/2; else y4=0;
   if(x5>0) y5=mn+(mx-mn)/2; else y5=0;
   if((finalH>0) && ((y1+y2+y3+y4+y5)==0)) y6=mn; else y6=0;
   finalL=y1+y2+y3+y4+y5+y6; 
//+------------------------------------------------------------------+ 
   double xo=(finalH-finalL); double xmm=xo/8;
//+------------------------------------------------------------------+ 
   for(i=0; i<OctLinesCnt; i++) {mml[i]=0;}        
   dmml=(finalH-finalL)/8;
   mml[0]=(finalL-dmml*2);
   for(i=1; i<OctLinesCnt; i++) {mml[i]=mml[i-1]+dmml;}
   for(i=0; i<OctLinesCnt; i++ ){buff_str="mml"+i;
    
   bml_25[0] = mml[0]-((mml[1]-mml[0])/4);
   bml_25[1] = ((mml[1]-mml[0])/4)+mml[0];
   bml_25[2] = ((mml[1]-mml[0])/4)*3+mml[0];
   bml_25[3] = ((mml[2]-mml[1])/4)+mml[1];
   bml_25[4] = ((mml[2]-mml[1])/4)*3+mml[1];
   bml_25[5] = ((mml[3]-mml[2])/4)+mml[2];
   bml_25[6] = ((mml[3]-mml[2])/4)*3+mml[2];
   bml_25[7] = ((mml[4]-mml[3])/4)+mml[3];
   bml_25[8] = ((mml[4]-mml[3])/4)*3+mml[3];
   bml_25[9] = ((mml[5]-mml[4])/4)+mml[4];
   bml_25[10]= ((mml[5]-mml[4])/4)*3+mml[4];
   bml_25[11]= ((mml[6]-mml[5])/4)+mml[5];
   bml_25[12]= ((mml[6]-mml[5])/4)*3+mml[5];
   bml_25[13]= ((mml[7]-mml[6])/4)+mml[6];
   bml_25[14]= ((mml[7]-mml[6])/4)*3+mml[6];
   bml_25[15]= ((mml[8]-mml[7])/4)+mml[7];
   bml_25[16]= ((mml[8]-mml[7])/4)*3+mml[7];
   bml_25[17]= ((mml[9]-mml[8])/4)+mml[8];
   bml_25[18]= ((mml[9]-mml[8])/4)*3+mml[8];
   bml_25[19]= ((mml[10]-mml[9])/4)+mml[9];
   bml_25[20]= ((mml[10]-mml[9])/4)*3+mml[9];
   bml_25[21]= ((mml[11]-mml[10])/4)+mml[10];
   bml_25[22]= ((mml[11]-mml[10])/4)*3+mml[10];
   bml_25[23]= ((mml[12]-mml[11])/4)+mml[11];
   bml_25[24]= ((mml[12]-mml[11])/4)*3+mml[11];
   bml_25[25]= ((mml[12]-mml[11])/4)+mml[12];
//+-----  
   bml_33[0] = mml[0]-((mml[1]-mml[0])/3);
   bml_33[1] = ((mml[1]-mml[0])/3)+mml[0];
   bml_33[2] = ((mml[1]-mml[0])/3)*2+mml[0];
   bml_33[3] = ((mml[2]-mml[1])/3)+mml[1];
   bml_33[4] = ((mml[2]-mml[1])/3)*2+mml[1];
   bml_33[5] = ((mml[3]-mml[2])/3)+mml[2];
   bml_33[6] = ((mml[3]-mml[2])/3)*2+mml[2];
   bml_33[7] = ((mml[4]-mml[3])/3)+mml[3];
   bml_33[8] = ((mml[4]-mml[3])/3)*2+mml[3];
   bml_33[9] = ((mml[5]-mml[4])/3)+mml[4];
   bml_33[10]= ((mml[5]-mml[4])/3)*2+mml[4];
   bml_33[11]= ((mml[6]-mml[5])/3)+mml[5];
   bml_33[12]= ((mml[6]-mml[5])/3)*2+mml[5];
   bml_33[13]= ((mml[7]-mml[6])/3)+mml[6];
   bml_33[14]= ((mml[7]-mml[6])/3)*2+mml[6];
   bml_33[15]= ((mml[8]-mml[7])/3)+mml[7];
   bml_33[16]= ((mml[8]-mml[7])/3)*2+mml[7];
   bml_33[17]= ((mml[9]-mml[8])/3)+mml[8];
   bml_33[18]= ((mml[9]-mml[8])/3)*2+mml[8];
   bml_33[19]= ((mml[10]-mml[9])/3)+mml[9];
   bml_33[20]= ((mml[10]-mml[9])/3)*2+mml[9];
   bml_33[21]= ((mml[11]-mml[10])/3)+mml[10];
   bml_33[22]= ((mml[11]-mml[10])/3)*2+mml[10];
   bml_33[23]= ((mml[12]-mml[11])/3)+mml[11];
   bml_33[24]= ((mml[12]-mml[11])/3)*2+mml[11];
   bml_33[25]= ((mml[12]-mml[11])/3)+mml[12];
//-----  
   bml_50[0] = ((mml[1]-mml[0])/2)+mml[0];
   bml_50[1] = ((mml[2]-mml[1])/2)+mml[1];   
   bml_50[2] = ((mml[3]-mml[2])/2)+mml[2];
   bml_50[3] = ((mml[4]-mml[3])/2)+mml[3];
   bml_50[4] = ((mml[5]-mml[4])/2)+mml[4];
   bml_50[5] = ((mml[6]-mml[5])/2)+mml[5];
   bml_50[6] = ((mml[7]-mml[6])/2)+mml[6];
   bml_50[7] = ((mml[8]-mml[7])/2)+mml[7];
   bml_50[8] = ((mml[9]-mml[8])/2)+mml[8];
   bml_50[9] = ((mml[10]-mml[9])/2)+mml[9];
   bml_50[10]= ((mml[11]-mml[10])/2)+mml[10];
   bml_50[11]= ((mml[12]-mml[11])/2)+mml[11];         
//+------------------------------------------------------------------+         
     ObjectDelete(buff_str);
     ObjectCreate(buff_str,OBJ_TREND,0,Time[0],mml[i],Time[0+FW],mml[i]);
        ObjectSet(buff_str,OBJPROP_STYLE,STYLE_SOLID);
        ObjectSet(buff_str,OBJPROP_WIDTH,mml_wdth[i]);
   if(showMurreylines) {        
        ObjectSet(buff_str,OBJPROP_COLOR,mml_clr[i]);}
  else {ObjectSet(buff_str,OBJPROP_COLOR,CLR_NONE);}     
        ObjectSet(buff_str,OBJPROP_BACK,0);
        ObjectSet(buff_str,OBJPROP_RAY,0);
       ObjectMove(buff_str,0,Time[0],mml[i]);
//+------------------------------------------------------------------+              
   buff_str="mml_txt"+i;
     ObjectDelete(buff_str);
     ObjectCreate(buff_str,OBJ_TEXT,0,Time[mml_shft],mml_shft);      
  //ObjectSetText(buff_str,ln_txt[i]+DoubleToStr(mml[i],DecNos)+ln_tx[i],16,"Arial Black",mml_clr[i]);
    ObjectSetText(buff_str,ln_txt[i]+ln_tx[i],16,"Arial Black",mml_clr[i]);
        ObjectSet(buff_str,OBJPROP_BACK,0);
       ObjectMove(buff_str,0,Time[mml_shft],mml[i]);}
   
   if(bml_25_lines) {for(x25=0; x25<bml_25_Cnt; x25++ ){buff_str3="bml_25"+x25;
     ObjectDelete(buff_str3);
     ObjectCreate(buff_str3,OBJ_TREND,0,Time[0],bml_25[x25],Time[0+FW],bml_25[x25]);
        ObjectSet(buff_str3,OBJPROP_STYLE,bml_25_style);        
        ObjectSet(buff_str3,OBJPROP_WIDTH,0);
   if(showMurreylines) {     
        ObjectSet(buff_str3,OBJPROP_COLOR,bml_25_color);}
  else {ObjectSet(buff_str3,OBJPROP_COLOR,CLR_NONE);}     
        ObjectSet(buff_str3,OBJPROP_BACK,1);
        ObjectSet(buff_str3,OBJPROP_RAY,0);
       ObjectMove(buff_str3,0,Time[0],bml_25[x25]);}}       
   
   if(bml_50_lines) {for(x50=0; x50<bml_50_Cnt; x50++){buff_str4="bml_50"+x50;
     ObjectDelete(buff_str4);
     ObjectCreate(buff_str4,OBJ_TREND,0,Time[0],bml_50[x50],Time[0+FW],bml_50[x50]);
        ObjectSet(buff_str4,OBJPROP_STYLE,bml_50_style);
        ObjectSet(buff_str4,OBJPROP_WIDTH,0);
   if(showMurreylines) {     
        ObjectSet(buff_str4,OBJPROP_COLOR,bml_50_color);}
  else {ObjectSet(buff_str4,OBJPROP_COLOR,CLR_NONE);}      
        ObjectSet(buff_str4,OBJPROP_BACK,1);
        ObjectSet(buff_str4,OBJPROP_RAY,0);
       ObjectMove(buff_str4,0,Time[0],bml_50[x50]);}}  
   
   if(bml_33_lines) {for(x33=0; x33<bml_33_Cnt; x33++){buff_str2="bml_33"+x33;
     ObjectDelete(buff_str2);
     ObjectCreate(buff_str2,OBJ_TREND,0,Time[0],bml_33[x33],Time[0+FW],bml_33[x33]);
        ObjectSet(buff_str2,OBJPROP_STYLE,bml_33_style);
        ObjectSet(buff_str2,OBJPROP_WIDTH,0);
   if(showMurreylines) {    
        ObjectSet(buff_str2,OBJPROP_COLOR,bml_33_color);}
  else {ObjectSet(buff_str2,OBJPROP_COLOR,CLR_NONE);}     
        ObjectSet(buff_str2,OBJPROP_BACK,1);
        ObjectSet(buff_str2,OBJPROP_RAY,0);
       ObjectMove(buff_str2,0,Time[0],bml_33[x33]);}}        
 //+------------------------------------------------------------------+ 
   double  plus_franka=mml[10]+((mml[10]-mml[2])*1/3);
   double   t66_franka=mml[2] +((mml[10]-mml[2])*2/3);
   double   t33_franka=mml[2] +((mml[10]-mml[2])*1/3);
   double minus_franka=mml[2] -((mml[10]-mml[2])*1/3); 
 //+------------------------------------------------------------------+ 
    ObjectDelete("pf");
    ObjectCreate("pf",OBJ_TREND,0,Time[0],plus_franka,Time[0+FW],plus_franka);
       ObjectSet("pf",OBJPROP_STYLE,STYLE_DASH);
   if(showMurreylines) {    
       ObjectSet("pf",OBJPROP_COLOR,OrangeRed);}
 else {ObjectSet("pf",OBJPROP_COLOR,CLR_NONE);}      
       ObjectSet("pf",OBJPROP_BACK,1);
       ObjectSet("pf",OBJPROP_RAY,0);
      ObjectMove("pf",0,Time[0],plus_franka);
        
    ObjectDelete("pft");
    ObjectCreate("pft",OBJ_TEXT,0,Time[mml_shft],mml_shft);
   ObjectSetText("pft","["+"+1/3rd Frame Shift"+"]  "+DoubleToStr(plus_franka,Digits),9,"MV Boli",OrangeRed);
       ObjectSet("pft",OBJPROP_BACK,1);
      ObjectMove("pft",0,Time[mml_shft+25],plus_franka);        
//+------------------------------------------------------------------+  
    ObjectDelete("mf");
    ObjectCreate("mf",OBJ_TREND,0,Time[0],minus_franka,Time[0+FW],minus_franka);
       ObjectSet("mf",OBJPROP_STYLE,STYLE_DASH);
  if(showMurreylines) {    
       ObjectSet("mf",OBJPROP_COLOR,OrangeRed);}
 else {ObjectSet("mf",OBJPROP_COLOR,CLR_NONE);} 
       ObjectSet("mf",OBJPROP_BACK,1);
       ObjectSet("mf",OBJPROP_RAY,0);
      ObjectMove("mf",0,Time[0],minus_franka);
        
    ObjectDelete("mft");
    ObjectCreate("mft",OBJ_TEXT,0,Time[mml_shft],mml_shft);
   ObjectSetText("mft","["+"-1/3rd Frame Shift"+"]  "+DoubleToStr(minus_franka,Digits),9,"MV Boli",OrangeRed);
       ObjectSet("mft",OBJPROP_BACK,1);
      ObjectMove("mft",0,Time[mml_shft+25], minus_franka);         
//+------------------------------------------------------------------+  
   if(color_frame) {  
   CreateObj(FF1,mml[5], mml[7], MM1Color);
   CreateObj(FF2,mml[0], mml[2], MM2Color);
   CreateObj(FF3,mml[10],mml[12],MM2Color);
   CreateObj(FF4,mml[7], mml[10],MM3Color);
   CreateObj(FF5,mml[2], mml[5], MM3Color); 
   CreateObj(FF6,mml[7], mml[5], MM4Color);}}