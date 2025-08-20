//+------------------------------------------------------------------+
//|                                                                  |
//| CustomCandle_TRO_MODIFIED_VERSION                           |
//| MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM     |
//| I am NOT the ORIGINAL author 
//  and I am not claiming authorship of this indicator. 
//  All I did was modify it. I hope you find my modifications useful.|
//|                                                                  |
//+------------------------------------------------------------------+

#property link      "mankurt@freemail.ru"
#property copyright "© 2006, mankurt"
#property indicator_chart_window
//+------------------------------------------------------------------------------------------------+


extern string noteTimeNY = " 14:00 server time = 05:00 am pst" ; 
extern string noteTimeAU = " 23:00 server time = 14:00 am pst" ; 

extern string myOpenHHMM = "14:00"; // 05:00 am pst = 14:00 server time 


extern int   TimeFrame=60;
extern color UpCandle=DarkGreen;
extern color DnCandle=MistyRose;
extern color DojiColor=Blue;
extern int   Width=1;
extern bool  BGCandle=True;



//+------------------------------------------------------------------------------------------------+
int      Nbar,OpenBar,timer,i,timerTF,name,MidBar;
double   HighPrevBar,LowPrevBar,ClosePrevBar;
double   OpenNewBar,HighNewBar,LowNewBar,CloseNewBar;
double   HighCurBar,LowCurBar,CloseCurBar;
double   priceNewSH,priceNewSL,pricePrevSH,pricePrevSL,priceCurSH,priceCurSL;
string   nameNewCandle,namePrevCandle;
string   nameNewShadowH,nameNewShadowL,namePrevShadowH,namePrevShadowL;
string   NameBar, NameHigh, NameLow;
datetime TimeOpenNewBar,TimeCloseNewBar,TimeClosePrevBar;
datetime timeNewShadow,timePrevShadow;
bool     NewBar;

string     yymmddms  ;
int cd ;
datetime   r ; 

//+------------------------------------------------------------------------------------------------+

int init()
{
IndicatorShortName("M"+TimeFrame+" íà M"+Period());
Nbar=TimeFrame/Period();
timer=Period()*60;
timerTF=TimeFrame*60;
name=0;


// ----------------

if( TimeFrame == 1440 ) {
   int   yy = TimeYear(Time[0]);
   int   mm = TimeMonth(Time[0]);
   int   dd = TimeDay(Time[0]);  
   
   yymmddms = yy+"."+mm+"."+dd+" " + myOpenHHMM ;
         
   datetime var1 = StrToTime(yymmddms);  
  
  
   datetime day=24*60*60;
   r  = var1 ;
   cd = iBarShift(NULL,0,r,FALSE);

   datetime r2=r-day;


   if(TimeDayOfWeek(r2)==0) r2=r2-day-day;
   int cd2=iBarShift(NULL,0,r2,FALSE);

   if( var1 > Time[0] ) { r = r2 ;cd = cd2 ;} // if date/time is greater than current date/time go back 1 day

   TimeOpenNewBar=Time[cd]; OpenNewBar = Open[cd] ; } 
else 
{
   TimeOpenNewBar=Time[Bars-1]; OpenNewBar=Open[Bars-1];
} 

// ----------------

NewBar=false;
NameBar="Bar M"+TimeFrame+"-";
NameHigh="High M"+TimeFrame+"-";
NameLow="Low M"+TimeFrame+"-";
return(0);}

//+------------------------------------------------------------------------------------------------+

int deinit(){
for(int DelOBJ=1; DelOBJ<=name; DelOBJ++){
ObjectDelete(NameBar+DelOBJ);
ObjectDelete(NameHigh+DelOBJ);
ObjectDelete(NameLow+DelOBJ);}
//Comment("");
return(0);}

//+------------------------------------------------------------------------------------------------+

int start()
{

if(TimeFrame>1440)
{Comment("\n"," TimeFrame more than D1 is not supporting!!!");return(0);}
if(Period()>240)
{Comment("\n"," Period more than H4 is not supporting!!!");return(0);}
if(TimeFrame<=Period()||MathMod(TimeFrame,Period())!=0)
{Comment("\n"," TimeFrame should be more or divisible by M",Period());return(0);}
i=Bars-IndicatorCounted();
while(i>0){i--;
while(i>=0) if(Time[i]==TimeOpenNewBar||BarNew(i,TimeFrame)==false)i--;
             else{NewBar=true; name++; break;}
if(i<0) i=0;
if(NewBar==true){
//+-----------------------------------------Previos Bar--------------------------------------------+
  OpenBar=iBarShift(0,0,TimeOpenNewBar,false);
  TimeClosePrevBar=Time[i+1];
  ClosePrevBar=Close[i+1];
  HighPrevBar=High[Highest(0,0,MODE_HIGH,OpenBar-i,i+1)];
  LowPrevBar=Low[Lowest(0,0,MODE_LOW,OpenBar-i,i+1)];
  namePrevCandle=NameBar+(name-1);
  MidBar=OpenBar-MathRound((OpenBar-i)/2);
  timePrevShadow=Time[MidBar];
  pricePrevSH=PriceShadow(OpenNewBar,ClosePrevBar,0);
  pricePrevSL=PriceShadow(OpenNewBar,ClosePrevBar,1);
  namePrevShadowH=NameHigh+(name-1);
  namePrevShadowL=NameLow+(name-1);
//+----------------------------------Modifi Previos Bar & Shadow-----------------------------------+
if(ObjectFind(namePrevCandle)==0){
  ObjectMove(namePrevCandle,1,TimeClosePrevBar,ClosePrevBar);
  PropBar(OpenNewBar,ClosePrevBar,namePrevCandle);
  if(OpenBar==i+1) ObjectSet(namePrevCandle,OBJPROP_WIDTH, Width*3);}
if(ObjectFind(namePrevShadowH)==0){
  if(pricePrevSH==HighPrevBar) ObjectDelete(namePrevShadowH);
   else{ObjectMove(namePrevShadowH,0,timePrevShadow,pricePrevSH);
    ObjectMove(namePrevShadowH,1,timePrevShadow,HighPrevBar);
    ColorShadow(OpenNewBar,ClosePrevBar,namePrevShadowH);
    ObjectSetText(namePrevShadowH,"High="+DoubleToStr(HighPrevBar,Digits),7,"Tahoma");}}
if(ObjectFind(namePrevShadowL)==0){
  if(pricePrevSL==LowPrevBar) ObjectDelete(namePrevShadowL);
   else{ObjectMove(namePrevShadowL,0,timePrevShadow,pricePrevSL);
    ObjectMove(namePrevShadowL,1,timePrevShadow,LowPrevBar);
    ColorShadow(OpenNewBar,ClosePrevBar,namePrevShadowL);
    ObjectSetText(namePrevShadowL,"Low="+DoubleToStr(LowPrevBar,Digits),7,"Tahoma");}}
//+-------------------------------------------New Bar----------------------------------------------+

// ----------------

if( TimeFrame == 1440 ) {
   int   yy = TimeYear(Time[i]);
   int   mm = TimeMonth(Time[i]);
   int   dd = TimeDay(Time[i]);  
   
   yymmddms = yy+"."+mm+"."+dd+" " + myOpenHHMM ;
         
   datetime var1 = StrToTime(yymmddms);  
  
  
   datetime day=24*60*60;
   r  = var1 ;
   cd = iBarShift(NULL,0,r,FALSE);

   datetime r2=r-day;


   if(TimeDayOfWeek(r2)==0) r2=r2-day-day;
   int cd2=iBarShift(NULL,0,r2,FALSE);

   if( var1 > Time[i] ) { r = r2 ;cd = cd2 ;} // if date/time is greater than current date/time go back 1 day

   TimeOpenNewBar=Time[cd]; OpenNewBar = Open[cd] ; } 
else 
{
   TimeOpenNewBar=Time[i]; OpenNewBar=Open[i];
} 

// ----------------

 
  HighNewBar=High[i];
  LowNewBar=Low[i];
  CloseNewBar=Close[i];
  TimeCloseNewBar=Time[i]+timerTF-timer;
  nameNewCandle=NameBar+name;
  timeNewShadow=Time[i]+MathRound(Nbar/2)*timer;
  priceNewSH=PriceShadow(OpenNewBar,CloseNewBar,0);
  priceNewSL=PriceShadow(OpenNewBar,CloseNewBar,1);
  nameNewShadowH=NameHigh+name;
  nameNewShadowL=NameLow+name;
  NewBar=false;}
 else{
//+------------------------------------------Current Bar-------------------------------------------+
  OpenBar=iBarShift(0,0,TimeOpenNewBar,false);
  CloseCurBar=Close[i];
  HighCurBar=High[Highest(0,0,MODE_HIGH,OpenBar+1,i)];
  LowCurBar=Low[Lowest(0,0,MODE_LOW,OpenBar+1,i)];
  priceCurSH=PriceShadow(OpenNewBar,CloseCurBar,0);
  priceCurSL=PriceShadow(OpenNewBar,CloseCurBar,1);}
//+------------------------------Create New Object & Modifi Current--------------------------------+
if(ObjectFind(nameNewCandle)!=0){
  ObjectCreate(nameNewCandle,OBJ_RECTANGLE,0,TimeOpenNewBar,OpenNewBar,TimeCloseNewBar,CloseNewBar);
  ObjectSet(nameNewCandle,OBJPROP_STYLE, STYLE_SOLID);
  PropBar(OpenNewBar,CloseNewBar,nameNewCandle);}
 else{
  ObjectMove(nameNewCandle,1,TimeCloseNewBar,CloseCurBar);       
  PropBar(OpenNewBar,CloseCurBar,nameNewCandle);}
if(ObjectFind(nameNewShadowH)!=0){
  ObjectCreate(nameNewShadowH,OBJ_TREND,0,timeNewShadow,priceNewSH,timeNewShadow,HighNewBar);
  ObjectSet(nameNewShadowH,OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(nameNewShadowH,OBJPROP_WIDTH, Width);
  ObjectSet(nameNewShadowH,OBJPROP_RAY, false);
  ColorShadow(OpenNewBar,CloseNewBar,nameNewShadowH);}
 else{
  ObjectMove(nameNewShadowH,0,timeNewShadow,priceCurSH);
  ObjectMove(nameNewShadowH,1,timeNewShadow,HighCurBar);
  ColorShadow(OpenNewBar,CloseCurBar,nameNewShadowH);}
if(ObjectFind(nameNewShadowL)!=0){
  ObjectCreate(nameNewShadowL,OBJ_TREND,0,timeNewShadow,priceNewSL,timeNewShadow,LowNewBar);
  ObjectSet(nameNewShadowL,OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(nameNewShadowL,OBJPROP_WIDTH, Width);
  ObjectSet(nameNewShadowL,OBJPROP_RAY, false);
  ColorShadow(OpenNewBar,CloseNewBar,nameNewShadowL);}
 else{
  ObjectMove(nameNewShadowL,0,timeNewShadow,priceCurSL);
  ObjectMove(nameNewShadowL,1,timeNewShadow,LowCurBar);
  ColorShadow(OpenNewBar,CloseCurBar,nameNewShadowL);}}
//+-------------------------------------Comment OHLC-----------------------------------------------+
//Comment(Symbol(),",M",TimeFrame,"   O=",OpenNewBar,",  H=",HighCurBar,
//                                ",  L=",LowCurBar,",  C=",CloseCurBar,"\n");
return(0);}
//+---------------------Main Function "New Bar or Old Bar"-----------------------------------------+
bool BarNew (int j, int tmf)
{int t0=1440*(TimeDayOfWeek(Time[j])-1)+60*TimeHour(Time[j])+TimeMinute(Time[j]),
t1=1440*(TimeDayOfWeek(Time[j+1])-1)+60*TimeHour(Time[j+1])+TimeMinute(Time[j+1]);
if(MathMod(t0,tmf)-MathMod(t1,tmf)==t0-t1)return(false);
else return(true);}
//+---------------------Function "Price Shadow"----------------------------------------------------+
double PriceShadow (double OpnB, double ClsB, int swt)
{double prH, prL;
if(OpnB<ClsB){prH=ClsB; prL=OpnB;}
if(OpnB>ClsB){prH=OpnB; prL=ClsB;}
if(OpnB==ClsB){prH=ClsB; prL=ClsB;}
switch(swt){case 0:return(prH);break;
case 1:return(prL);break;}}
//+---------------------Function "Properti Bars"---------------------------------------------------+
void PropBar (double OpPr, double ClPr, string NmOBJ)
{string Cl=" Close="+DoubleToStr(ClPr,Digits);
string Op=" Open="+DoubleToStr(OpPr,Digits);
if(OpPr==ClPr){ObjectSet(NmOBJ,OBJPROP_BACK, false);
ObjectSet(NmOBJ,OBJPROP_COLOR,DojiColor);
ObjectSetText(NmOBJ,"Doji "+Op+Cl,7,"Tahoma");}
if(OpPr<ClPr){ObjectSet(NmOBJ,OBJPROP_COLOR,UpCandle);
ObjectSet(NmOBJ,OBJPROP_BACK, BGCandle);
ObjectSetText(NmOBJ,"UpBar "+Op+Cl,7,"Tahoma");}
if (OpPr>ClPr){ObjectSet(NmOBJ,OBJPROP_COLOR,DnCandle);
ObjectSet(NmOBJ,OBJPROP_BACK, BGCandle);
ObjectSetText(NmOBJ,"DnBar "+Op+Cl,7,"Tahoma");}
ObjectSet(NmOBJ,OBJPROP_WIDTH, Width);}
//+----------------------Function "Color Shadow"---------------------------------------------------+
void ColorShadow (double OP, double CP, string NOBJ)
{if(OP==CP)ObjectSet(NOBJ,OBJPROP_COLOR,DojiColor);
if(OP<CP)ObjectSet(NOBJ,OBJPROP_COLOR,UpCandle);
if (OP>CP)ObjectSet(NOBJ,OBJPROP_COLOR,DnCandle);}
//+----------------------------------------------END-----------------------------------------------+