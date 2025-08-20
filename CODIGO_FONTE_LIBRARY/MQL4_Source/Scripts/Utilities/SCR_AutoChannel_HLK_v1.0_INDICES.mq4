#property  copyright "ANG3110@latchess.com"
#property indicator_chart_window
//----------------------------------
extern int Hours=12;
extern color col=LightBlue;
extern double K=20;
//------------------
double lr,lr0,lrp;
double sx,sy,sxy,sx2,aa,bb;
int p,sName,fs;
int f,f0,f1;
double dh,dl,dh_1,dl_1,dh_2,dl_2;
int ai_1,ai_2,bi_1,bi_2; 
double hai,lai,dhi,dli,dhm,dlm,ha0,hap,la0,lap;
double H0,S0,L0,Hp,Sp,Lp;
int i0,p0;
double HL,khl,HK0,LK0,HKp,LKp;
//*****************************************
int init() {
//-------------------------
p=Hours*60/Period();
if (fs==0) {sName=CurTime(); fs=1;}
return(0);}
//*******************************
int deinit() {
   ObjectDelete("chH"+sName);
   ObjectDelete("chS"+sName);
   ObjectDelete("chL"+sName);
   ObjectDelete("chHK"+sName);
   ObjectDelete("chLK"+sName);  
   ObjectDelete("txtHL"+sName); }
//*******************************
int start() {
//------------------------------------------------------------------------------
if (f0==1) p=iBarShift(Symbol(),Period(),ObjectGet("chS"+sName,OBJPROP_TIME1));
//====================================================
sx=0; sy=0; sxy=0; sx2=0; 
for (int n=i0; n<=i0+p; n++) {sx+=n; sy+=Close[n]; sxy+=n*Close[n]; sx2+=MathPow(n,2);}   
aa=(sx*sy-(p+1)*sxy)/(MathPow(sx,2)-(p+1)*sx2); bb=(sy-aa*sx)/(p+1);
//----------------------------------------------------
for (int i=i0; i<=i0+p; i++) {
lr=bb+aa*i;
dh=High[i]-lr; dl=Low[i]-lr;
//----------------------------------------------------
if (i<i0+p/2) {if (i==i0) {dh_1=0.0; dl_1=0.0; ai_1=i; bi_1=i;} 
if (dh>=dh_1) {dh_1=dh; ai_1=i;}
if (dl<=dl_1) {dl_1=dl; bi_1=i;}}  
//----------------------------------------------------
if (i>=i0+p/2) {if (i==i0+p/2) {dh_2=0.0; dl_2=0.0; ai_2=i; bi_2=i;} 
if (dh>=dh_2) {dh_2=dh; ai_2=i;}
if (dl<=dl_2) {dl_2=dl; bi_2=i;}}} 
//-------------------------------------
lr0=bb+aa*i0; lrp=bb+aa*(i0+p);
//===================================================
if (MathAbs(ai_1-ai_2)>MathAbs(bi_1-bi_2)) f=1;
if (MathAbs(ai_1-ai_2)<MathAbs(bi_1-bi_2)) f=2;
if (MathAbs(ai_1-ai_2)==MathAbs(bi_1-bi_2)) {if (MathAbs(dh_1-dh_2)<MathAbs(dl_1-dl_2)) f=1; if (MathAbs(dh_1-dh_2)>=MathAbs(dl_1-dl_2)) f=2;} 
//=================================================
if (f==1) {
for (n=0; n<=20; n++) { f1=0;
for (i=i0; i<=i0+p; i++) {hai=High[ai_1]*(i-ai_2)/(ai_1-ai_2)+High[ai_2]*(i-ai_1)/(ai_2-ai_1);  
if (i==i0 || i==i0+p/2) dhm=0.0; 
if (High[i]-hai>dhm && i<i0+p/2) {ai_1=i; f1=1;}
if (High[i]-hai>dhm && i>=i0+p/2) {ai_2=i; f1=1;} }
if (f==0) break;} 
//----------------------------
for (i=i0; i<=i0+p; i++) {hai=High[ai_1]*(i-ai_2)/(ai_1-ai_2)+High[ai_2]*(i-ai_1)/(ai_2-ai_1);  
dli=Low[i]-hai; 
if (i==i0) dlm=0.0; if (dli<dlm) dlm=dli;}   
ha0=High[ai_1]*(i0-ai_2)/(ai_1-ai_2)+High[ai_2]*(i0-ai_1)/(ai_2-ai_1); 
hap=High[ai_1]*(i0+p-ai_2)/(ai_1-ai_2)+High[ai_2]*(i0+p-ai_1)/(ai_2-ai_1);
//----------------------------
Hp=hap;
Sp=hap+dlm/2;
Lp=hap+dlm;

H0=ha0;
S0=ha0+dlm/2;
L0=ha0+dlm;
}
//=================================================
if (f==2) {
for (n=0; n<=20; n++) { f1=0;
for (i=i0; i<=i0+p; i++) {lai=Low[bi_1]*(i-bi_2)/(bi_1-bi_2)+Low[bi_2]*(i-bi_1)/(bi_2-bi_1); 
if (i==i0 || i==i0+p/2) dlm=0.0; 
if (Low[i]-lai<dlm && i<i0+p/2) {bi_1=i; f1=1;}
if (Low[i]-lai<dlm && i>=i0+p/2) {bi_2=i; f1=1;}} 
if (f==0) break;}
//----------------------------
for (i=i0; i<=i0+p; i++) {lai=Low[bi_1]*(i-bi_2)/(bi_1-bi_2)+Low[bi_2]*(i-bi_1)/(bi_2-bi_1); 
dhi=High[i]-lai;
if (i==i0) dhm=0.0; if (dhi>dhm) dhm=dhi;}   
la0=Low[bi_1]*(i0-bi_2)/(bi_1-bi_2)+Low[bi_2]*(i0-bi_1)/(bi_2-bi_1); 
lap=Low[bi_1]*(i0+p-bi_2)/(bi_1-bi_2)+Low[bi_2]*(i0+p-bi_1)/(bi_2-bi_1);
//----------------------------------------------------------------
Lp=lap;
Sp=lap+dhm/2;
Hp=lap+dhm;

L0=la0;
S0=la0+dhm/2;
H0=la0+dhm;
}
//----------------------------------------------------------------
HL=H0-L0;
khl=HL*K/100;

HK0=H0-khl;
LK0=L0+khl;
HKp=Hp-khl;
LKp=Lp+khl;
//===================================================================================
if (f0==1) {
ObjectMove("chH"+sName,0,Time[p],Hp);
ObjectMove("chS"+sName,0,Time[p],Sp);
ObjectMove("chL"+sName,0,Time[p],Lp);
ObjectMove("chHK"+sName,0,Time[p],HKp);
ObjectMove("chLK"+sName,0,Time[p],LKp);

ObjectMove("chH"+sName,1,Time[i0],H0);
ObjectMove("chS"+sName,1,Time[i0],S0);
ObjectMove("chL"+sName,1,Time[i0],L0);
ObjectMove("chHK"+sName,1,Time[i0],HK0);
ObjectMove("chLK"+sName,1,Time[i0],LK0);

if (S0>=Sp) ObjectMove("txtHL"+sName,0,Time[0],L0-0.0003);
if (S0<Sp) ObjectMove("txtHL"+sName,0,Time[0],H0+0.0006);
ObjectSetText("txtHL"+sName," "+DoubleToStr(HL/Point,0),8,"Arial",Lime);
}
//==================================================================
if (f0==0) { f0=1;
ObjectCreate("chH"+sName,2, 0,Time[p],Hp,Time[i0],H0);
ObjectCreate("chS"+sName,2, 0,Time[p],Sp,Time[i0],S0);
ObjectCreate("chL"+sName,2, 0,Time[p],Lp,Time[i0],L0);

ObjectCreate("chHK"+sName,2, 0,Time[p],HKp,Time[i0],HK0);
ObjectCreate("chLK"+sName,2, 0,Time[p],LKp,Time[i0],LK0);
//-----------------------------------------------------------------
ObjectSet("chH"+sName,OBJPROP_COLOR,col);
ObjectSet("chS"+sName,OBJPROP_COLOR,col);
ObjectSet("chS"+sName,OBJPROP_STYLE,STYLE_DOT);
ObjectSet("chL"+sName,OBJPROP_COLOR,col);

ObjectSet("chHK"+sName,OBJPROP_COLOR,col);
ObjectSet("chHK"+sName,OBJPROP_STYLE,STYLE_DOT);
ObjectSet("chLK"+sName,OBJPROP_COLOR,col);
ObjectSet("chLK"+sName,OBJPROP_STYLE,STYLE_DOT);
//-----------------------------------------------------------------
ObjectCreate("txtHL"+sName,OBJ_TEXT,0,Time[0],Close[0]);
}
//*************************************************************************************
return(0);}
//=====================================================================================