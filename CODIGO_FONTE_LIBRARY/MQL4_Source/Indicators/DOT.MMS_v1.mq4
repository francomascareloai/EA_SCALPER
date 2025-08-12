#property copyright   "Mobidik && MMS"
//#property icon        "\\Images\\ukraine.ico"
#property strict
//-------------------------------------------------------------------------------------+
#property indicator_maximum 100
#property indicator_minimum 0
 
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  clrGold
#property indicator_color2  clrMagenta
#property indicator_color3  clrDodgerBlue
#property indicator_color4  clrGold
#property indicator_color5  clrRed
#property indicator_color6  clrGreen
#property indicator_width6  3
#property indicator_width5  3
//-------------------------------------------------------------------------------------+
enum ENUM0 
 {
   Var0,//  от данного момента времени
   Var1,//  за заданное количество баров
   Var2,//  от заданной даты
   Var3 //  функция отключена
 };
enum ENUM1
 {  
   On,//  да
   Off//  нет
 }; 
enum ENUM2 
 {
   VarB,//  только Buy
   VarS,//  только Sell
   VarA //  Buy & Sell
 };
enum ENUM3
 {  
   Win0,//  главном окне
   Win1 //  окне индикатора
 };
//-------------------------------------------------------------------------------------+
extern string ____________DOT_MMS____________ = "Настройки индикатора";
input  ENUM2  Signal              = VarA;              //.            Работать с сигналами: 
extern string aa                  = "";                //====== Настройка для Buy ==========
extern int    RSI_Period_Up       = 2;                 //Период
extern int    RSI_Level_Up        = 5;                 //Уровень
extern int    Shift_Signal_Up     = 0;                 //Сдвиг сигнала
extern bool   Revers_Up           = false;             //Реверс
extern string ab                  = "";                //===== Настройка для Sell ==========
extern int    RSI_Period_Dn       = 2;                 //Период
extern int    RSI_Level_Dn        = 95;                //Уровень
extern int    Shift_Signal_Dn     = 0;                 //Сдвиг сигнала
extern bool   Revers_Dn           = false;             //Реверс
extern string aс                  = "===================================";//================================
//-------------------------------------------------------------------------------------+
extern string bb                  = "";                //______Инфо блок индикатора___    
input  ENUM0  RunBacktest         = Var1;              //Считать сигналы        
extern string TimeStart           = "2015.10.25 15:00";//Считать сигналы с даты:
extern int    History             = 1440;              //Считать за последних баров
input  ENUM3  SetWind             = Win0;              //Инфо блок отобразить в 
//-------------------------------------------------------------------------------------+  
extern string Time_Start_End      = " ";               //___работа по времени суток___
extern string Time_Start          = "08:00";           //Начало подачи сигналов (включительно) 
extern string Time_End            = "17:59";           //Конец подачи сигналов (включительно)
//-------------------------------------------------------------------------------------+
extern string Arr                 = " ";               //___настройка Arrows & Alert___
input  ENUM1  KlikSig             = Off;               //Включить сигналы для кликера
extern bool   ArrPredv            = true;              //Предварительные стрелки
extern bool   ArrOsnov            = true;              //Основные стрелки
extern int    Arr_code_Up         = 233;               //Код стрелки Up
extern int    Arr_code_Dn         = 234;               //Код стрелки Dn
extern color  Arr_color_Up        = clrLime;           //Цвет стрелки/точки Up 
extern color  Arr_color_Dn        = clrMagenta;        //Цвет стрелки/точки Dn 
extern int    Arr_otstup          = 0;                 //Отступ от баров 
extern int    Arr_width           = 1;                 //Размер стрелок 
extern bool   AlertsMessage       = true;              //Оповещение Message (для точек)
extern bool   AlertsSound         = false;             //Оповещение Sound (для точек)

bool     Color_Sig_Line = true;
//-------------------------------------------------------------------------------------+
int      Corner = 1;
int      YDistance = -40;
int      XDistance = 5;
color    BackTestColorDn = clrOrangeRed;  
color    BackTestColorUp = C'0,191,0';
color    BackTestColorSg = clrMediumSeaGreen;
//-------------------------------------------------------------------------------------+
double   ArrowsUp[];
double   ArrowsDn[];

double   B_count[];
double   B_itm[];
double   B_count_winrate;
double   B_count_total=0;
double   B_count_itm=0;
double   B_count_otm=0;

double   S_count[];
double   S_itm[];
double   S_count_winrate;
double   S_count_total=0;
double   S_count_itm=0;
double   S_count_otm=0;

datetime TimeBegin;
datetime LastBarTime=0;;
int      HistBar;
int      BarBegin;
#define  PREFIX "sХs"
bool     Trade;
double   RSI_Up[];
double   RSI_Dn[];
double   Upper[];
double   Lower[];
int      overSold; 
int      overBought;
int      Sig_Up0;
int      Sig_Up1;
int      Sig_Dn0;
int      Sig_Dn1;
datetime TimeBarUp;
datetime TimeBarDn;
//---------------------------------------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(10);
//-----     
   SetIndexBuffer(0,ArrowsUp);      
   SetIndexLabel (0,NULL);
   SetIndexArrow (0, 233);
   SetIndexBuffer(1,ArrowsDn);    
   SetIndexLabel (1,NULL);
   SetIndexArrow (1, 234);
   
if(ArrOsnov)
 {    
   SetIndexStyle (0,DRAW_ARROW);
   SetIndexStyle (1,DRAW_ARROW);
 }else{     
   SetIndexStyle (0,DRAW_NONE);     
   SetIndexStyle (1,DRAW_NONE); 
 } 
//+----- 
   SetIndexBuffer(2,RSI_Up);
   SetIndexLabel (2,"SigLine");
   SetIndexStyle (2,DRAW_LINE);
      
   SetIndexBuffer(3,RSI_Dn);
   SetIndexLabel (3,"SigLine");
   SetIndexStyle (3,DRAW_LINE); 
      
   SetIndexBuffer(4,Upper); 
   SetIndexLabel (4,NULL);
   
   SetIndexBuffer(5,Lower);
   SetIndexLabel (5,NULL);   
   
   SetLevelValue (0, RSI_Level_Up); 
   SetLevelValue (1, RSI_Level_Dn);      
//+----- 
   SetIndexBuffer(6,B_count);
   SetIndexStyle (6,DRAW_NONE);
   SetIndexBuffer(7,B_itm); 
   SetIndexStyle (7,DRAW_NONE);
   
   SetIndexBuffer(8,S_count);
   SetIndexStyle (8,DRAW_NONE);
   SetIndexBuffer(9,S_itm); 
   SetIndexStyle (9,DRAW_NONE);
//+----   
   overSold = RSI_Level_Up;
   overBought = RSI_Level_Dn;
//+----- 
 if(RunBacktest!=3)
  {
   int xdp;
   int xds;
   if(KlikSig==0)
    { 
      xdp = 0;
      xds = 0;
    }else{
      xdp = 30;
      xds = 30;
      XDistance = XDistance-30;
    }
      ObjectFon("fon-ind",10+xdp,65,-195+xds,72,1, C'18,34,46', clrGainsboro);//xd, yd, xs, ys
      ObjectFon("fon-in1",10+xdp,100,-195+xds,1,0,clrGray, clrGray);
      if(KlikSig==0)ObjectFon("fon-in2",12+xdp,70,-28+xds,62,0,C'18,34,46', clrGray);//xd, yd, xs, ys
    
  }
 if(RunBacktest==0)//в реальном времени 
    TimeBegin = Time[0]; 
          
   return (0);
}
//---------------------------------------------------------------------------------------------------+
  int deinit()   
{  
   Comment("");                                  
   for (int i = ObjectsTotal()-1; i >= 0; i--)   
   if (StringSubstr(ObjectName(i), 0, StringLen(PREFIX)) == PREFIX)
       ObjectDelete(ObjectName(i));
   return(0);  
}  
//---------------------------------------------------------------------------------------------------+
int start() 
{ 
   if(WindowExpertName() != "DOT.MMS_v1")
      {
        Alert("Решил переименовать в  \" ",WindowExpertName()," \" ?   :)  Ай, молодец.   Пробуем еще? :)");
        return(0);
      }
    
  if(RunBacktest==0)//в реальном времени 
   {
     BarBegin = iBarShift(NULL,0,TimeBegin);
     HistBar = BarBegin;
     vertical_line(BarBegin,Lime); 
   }
  if(RunBacktest==1)//за заданное количество баров
   {
     HistBar = History;
     TimeBegin = Time[History]; 
     vertical_line(HistBar,Lime); 
     if(LastBarTime != Time[0]) ObjectDelete(PREFIX+TimeToStr(Time[HistBar+1]));
   }
  if(RunBacktest==2)//от заданной даты
   {
     TimeBegin = StrToTime(TimeStart);
     BarBegin = iBarShift(NULL,0,TimeBegin);
     HistBar = BarBegin; 
     vertical_line(HistBar,Lime);
   } 
  if(RunBacktest==3)//функция отключена 
     HistBar = History;
//---------------------------------------------------------------------------------------------------+   
  int i,counted_bars = IndicatorCounted();
  if (counted_bars < 0) return (-1);
  if (counted_bars > 0) counted_bars--;
  int limit = MathMin(Bars-counted_bars,HistBar+100);

  for(i=limit; i>=0; i--)
   {  
     string Time_S=TimeToStr(StrToTime(Time_Start),TIME_MINUTES); 
     string Time_E=TimeToStr(StrToTime(Time_End),TIME_MINUTES);
     string Time_i=TimeToStr(Time[i],TIME_MINUTES);

     if(Time_S < Time_E && Time_i >= Time_S && Time_i <= Time_E) Trade=true; 
       else {
        if(Time_S > Time_E && (Time_i >= Time_S || Time_i <= Time_E)) // ночью, через полночь
      {Trade=true;} else {Trade=false; // Comment("Торговля запрещена по времени");
       }
     }
      
   if(Signal==VarA || Signal==VarB)
     {
       if(!Revers_Up)
         RSI_Up[i] = iRSI(Symbol(),0,RSI_Period_Up,PRICE_CLOSE,i); 
         else
         RSI_Up[i] = (iRSI(Symbol(),0,RSI_Period_Up,PRICE_CLOSE,i)*-1)+100;
     } else
       RSI_Up[i] = 50;
     
   if(Signal==VarA || Signal==VarS)
     { 
       if(!Revers_Dn)
         RSI_Dn[i] = iRSI(Symbol(),0,RSI_Period_Dn,PRICE_CLOSE,i); 
         else
         RSI_Dn[i] = (iRSI(Symbol(),0,RSI_Period_Dn,PRICE_CLOSE,i)*-1)+100;
     } else
       RSI_Dn[i] = 50;  

   if(Color_Sig_Line)
     {        
      if(RSI_Dn[i] > overBought)
        { 
          Upper[i] = RSI_Dn[i]; 
          Upper[i+1] = RSI_Dn[i+1];
        } else {
          Upper[i] = EMPTY_VALUE;
          if (Upper[i+2] == EMPTY_VALUE) Upper[i+1]  = EMPTY_VALUE;
        }
      
      if(RSI_Up[i] < overSold) 
        { 
          Lower[i] = RSI_Up[i]; 
          Lower[i+1] = RSI_Up[i+1]; 
        } else { 
          Lower[i] = EMPTY_VALUE;
          if (Lower[i+2] == EMPTY_VALUE) Lower[i+1]  = EMPTY_VALUE;
        } 
     } else {
       Upper[i]  = EMPTY_VALUE;
       Lower[i]  = EMPTY_VALUE; 
     }
  
  if(Trade)
   { 
      if(ArrPredv && RSI_Up[i+2]>RSI_Level_Up && RSI_Up[i+1]>RSI_Level_Up && RSI_Up[i]<RSI_Level_Up) 
         {
           arrows_wind(i,"P_Up1",Arr_otstup ,159,Arr_color_Up,Arr_width,false);
           Sig_Up0=1;
         } else {
           Sig_Up0=0;
         }
  
      if(ArrPredv && RSI_Dn[i+2]<RSI_Level_Dn && RSI_Dn[i+1]<RSI_Level_Dn && RSI_Dn[i]>RSI_Level_Dn) 
         {
           arrows_wind(i,"P_Dn1",Arr_otstup ,159,Arr_color_Dn,Arr_width,true);
           Sig_Dn0=1;
         } else {      
           Sig_Dn0=0;
         }

      if(RSI_Up[i+3+Shift_Signal_Up]>RSI_Level_Up && RSI_Up[i+2+Shift_Signal_Up]>RSI_Level_Up && RSI_Up[i+1+Shift_Signal_Up]<RSI_Level_Up)
         { 
           if(ArrOsnov)arrows_wind(i,"O_Up1",Arr_otstup ,Arr_code_Up,Arr_color_Up,Arr_width,false);
           ArrowsUp[i]=0.1;
           Sig_Up1=1;
         } else {
           Sig_Up1=0;
         } 
      
      if(RSI_Dn[i+3+Shift_Signal_Dn]<RSI_Level_Dn && RSI_Dn[i+2+Shift_Signal_Dn]<RSI_Level_Dn && RSI_Dn[i+1+Shift_Signal_Dn]>RSI_Level_Dn) 
         {
           if(ArrOsnov)arrows_wind(i,"O_Dn1",Arr_otstup ,Arr_code_Dn,Arr_color_Dn,Arr_width,true);
           ArrowsDn[i]=99.9;
           Sig_Dn1=1;
         } else {
           Sig_Dn1=0;
         }
       }
   }     
//---------------------------------------------------------------------------------------------------+  
 if(AlertsMessage || AlertsSound)
  { 
   string message1 = (WindowExpertName()+" - "+Symbol()+"  "+PeriodString()+" - Возможен сигнал на Buy");
   string message2 = (WindowExpertName()+" - "+Symbol()+"  "+PeriodString()+" - Возможен сигнал на Sell");
       
    if(TimeBarUp!=Time[0] && Sig_Up0==1)
     { 
        if (AlertsMessage) Alert(message1);
        if (AlertsSound)   PlaySound("alert2.wav");
        TimeBarUp=Time[0];
     }
    if(TimeBarDn!=Time[0] && Sig_Dn0==1)
     { 
        if (AlertsMessage) Alert(message2);
        if (AlertsSound)   PlaySound("alert2.wav");
        TimeBarDn=Time[0];
    }
  }
//---------------------------------------------------------------------------------------------------+           
   if(KlikSig==0)
     {
       if(ArrowsUp[0]!=EMPTY_VALUE && ArrowsUp[0]!=0)
         object_klik("Info-up","5","Webdings",27,Gold,7,15);
         else ObjectDelete(PREFIX+"Info-up");
              
       if(ArrowsDn[0]!=EMPTY_VALUE && ArrowsDn[0]!=0) 
         object_klik("Info-dn","6","Webdings",27,Magenta,7,50);
         else ObjectDelete(PREFIX+"Info-dn");
     }  
//---------------------------------------------------------------------------------------------------+      
 if(RunBacktest!=3)
  {
    B_count_total   = 0;
    B_count_itm     = 0;
    B_count_otm     = 0;
    B_count_winrate = 0;
    
    S_count_total   = 0;
    S_count_itm     = 0;
    S_count_otm     = 0;
    S_count_winrate = 0;
        
  for(i=HistBar-1; i>=0; i--)
   {
    if(LastBarTime != Time[i])
      { 
//---------------    
       if(ArrowsUp[i+1]>0 && ArrowsUp[i+1]!=EMPTY_VALUE) 
          B_count[i] = 1; else B_count[i] = 0;

       if(ArrowsUp[i+1]>0 && ArrowsUp[i+1]!=EMPTY_VALUE && Open[i+1] < Close[i+1])
          B_itm[i] = 1; else B_itm[i] = 0;

        B_count_total += (int)B_count[i];
        B_count_itm   += (int)B_itm[i];
        B_count_otm    = B_count_total - B_count_itm;
        
       if(B_count_total>0)  B_count_winrate = (B_count_itm*100)/B_count_total;
//---------------
       if(ArrowsDn[i+1]>0 && ArrowsDn[i+1]!=EMPTY_VALUE)
          S_count[i] = 1; else S_count[i] = 0;

       if(ArrowsDn[i+1]>0 && ArrowsDn[i+1]!=EMPTY_VALUE && Open[i+1] > Close[i+1]) 
          S_itm[i] = 1; else S_itm[i] = 0;

        S_count_total += (int)S_count[i];
        S_count_itm   += (int)S_itm[i];
        S_count_otm    = S_count_total - S_count_itm;
        
       if(S_count_total>0)  S_count_winrate = (S_count_itm*100)/S_count_total;
//---------------
              
       BackTest((int)B_count_total,(int)B_count_itm,(int)B_count_otm,B_count_winrate,
                (int)S_count_total,(int)S_count_itm,(int)S_count_otm,S_count_winrate);          

      }
    }
  }
//---------------------------------------------------------------------------------------------------+  
   return (0);
}
//---------------------------------------------------------------------------------------------------+
void arrows_wind(int k, string N,int ots,int Code,color clr, int ArrowSize,bool up)                 
{           
   string objName = PREFIX+N+TimeToStr(Time[k]);
   double gap  = /*iATR(NULL,0,20,k)+*/ots*Point;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,Code);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);
   ObjectSet   (objName,OBJPROP_BACK,true);  
  if (up)
    {
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(objName,OBJPROP_PRICE1,High[k]+gap);
    }else{  
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSet(objName,OBJPROP_PRICE1,Low[k]-gap);
    }
}
//---------------------------------------------------------------------------------------------------+
void object_klik(string z,string x,string m,int b,color c,int k,int v)
{
 string objName = PREFIX+z; 
 int wind_ind;
   
   if(SetWind!=Win0)
     {
       int indicatorWindow = WindowFind("DOT.MMS_v1");
       if(indicatorWindow < 0) return;  
       wind_ind=indicatorWindow;
     } else wind_ind=0;
     
   if(ObjectFind(objName)==-1){
   ObjectCreate (objName,OBJ_LABEL,wind_ind,0,0);}
   ObjectSetText(objName,x,b,m,c);
   ObjectSet    (objName,OBJPROP_CORNER,Corner);
   ObjectSet    (objName,OBJPROP_XDISTANCE,XDistance+k);
   ObjectSet    (objName,OBJPROP_YDISTANCE,YDistance+v+48);
   ObjectSet    (objName,OBJPROP_SELECTABLE,false);
   ObjectSet    (objName,OBJPROP_BACK,false);
} 
//---------------------------------------------------------------------------------------------------+
void vertical_line(int k, color clr)   
{
   string objName = PREFIX+TimeToStr(Time[k]);
   
   ObjectCreate(objName, OBJ_VLINE,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_BACK, true);
   ObjectSet   (objName, OBJPROP_STYLE, 2);
   ObjectSet   (objName, OBJPROP_WIDTH, 0); 
   ObjectSet   (objName, OBJPROP_SELECTABLE, false); 
   ObjectSet   (objName, OBJPROP_HIDDEN, true); 
}
//---------------------------------------------------------------------------------------------------+
void ObjectFon(string names,int xd,int yd,int xs,int ys,int type,color bgcol,color foncol)
{
   string name = PREFIX+names;
   int wind_ind;
   if(SetWind!=Win0)
     {
       int indicatorWindow = WindowFind("DOT.MMS_v1");
       if(indicatorWindow < 0) return;  
       wind_ind=indicatorWindow;
     } else wind_ind=0;
    
   if(ObjectFind   (0,name)==-1){
   ObjectCreate    (0,name,OBJ_RECTANGLE_LABEL,wind_ind,0,0);}
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xd+XDistance);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yd+YDistance);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ys);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xs);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgcol);
   ObjectSetInteger(0,name,OBJPROP_COLOR,foncol);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   if(type==1)
     ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
    else
     ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
}    
//---------------------------------------------------------------------------------------------------+
void BackTest(int B_total_of_trades, int B_total_itm, int B_total_otm, double B_total_winrate,
              int S_total_of_trades, int S_total_itm, int S_total_otm, double S_total_winrate)
{
   string name = PREFIX+"Info";
   color B_Color_Winrate; 
   color S_Color_Winrate;
   int FontSize = 10;
   
   if (B_total_winrate<50)
      B_Color_Winrate = BackTestColorDn; else B_Color_Winrate = BackTestColorUp;
      
   if (S_total_winrate<50)
      S_Color_Winrate = BackTestColorDn; else S_Color_Winrate = BackTestColorUp;
      
   int wind_ind;
   if(SetWind!=Win0)
     {
       int indicatorWindow = WindowFind("DOT.MMS_v1");
       if(indicatorWindow < 0) return;  
       wind_ind=indicatorWindow;
     } else wind_ind=0;
     
   ObjectCreate(0,name+"1",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"1","B-sig",FontSize,NULL,BackTestColorSg);
   ObjectSet(name+"1",OBJPROP_XDISTANCE,XDistance+185);
   ObjectSet(name+"1",OBJPROP_YDISTANCE,YDistance+110);//110/75
   ObjectSet(name+"1",OBJPROP_CORNER,Corner);
   ObjectSet(name+"1",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"1",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"2",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"2","Win",FontSize,NULL,BackTestColorUp);
   ObjectSet(name+"2",OBJPROP_XDISTANCE,XDistance+150);
   ObjectSet(name+"2",OBJPROP_YDISTANCE,YDistance+110);
   ObjectSet(name+"2",OBJPROP_CORNER,Corner);
   ObjectSet(name+"2",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"2",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"3",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"3","Lose",FontSize,NULL,BackTestColorDn);
   ObjectSet(name+"3",OBJPROP_XDISTANCE,XDistance+115);
   ObjectSet(name+"3",OBJPROP_YDISTANCE,YDistance+110);
   ObjectSet(name+"3",OBJPROP_CORNER,Corner);
   ObjectSet(name+"3",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"3",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"4",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"4","WinRate",FontSize,NULL,B_Color_Winrate);
   ObjectSet(name+"4",OBJPROP_XDISTANCE,XDistance+70);
   ObjectSet(name+"4",OBJPROP_YDISTANCE,YDistance+110);
   ObjectSet(name+"4",OBJPROP_CORNER,Corner);
   ObjectSet(name+"4",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"4",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"5",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"5",IntegerToString(B_total_itm),FontSize,NULL,BackTestColorUp);
   ObjectSet(name+"5",OBJPROP_XDISTANCE,XDistance+150);
   ObjectSet(name+"5",OBJPROP_YDISTANCE,YDistance+125);
   ObjectSet(name+"5",OBJPROP_CORNER,Corner);
   ObjectSet(name+"5",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"5",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"6",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"6",IntegerToString(B_total_otm),FontSize,NULL,BackTestColorDn);
   ObjectSet(name+"6",OBJPROP_XDISTANCE,XDistance+115);
   ObjectSet(name+"6",OBJPROP_YDISTANCE,YDistance+125);
   ObjectSet(name+"6",OBJPROP_CORNER,Corner);
   ObjectSet(name+"6",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"6",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"7",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"7",DoubleToString(B_total_winrate,1)+"%",FontSize,NULL,B_Color_Winrate);
   ObjectSet(name+"7",OBJPROP_XDISTANCE,XDistance+70);
   ObjectSet(name+"7",OBJPROP_YDISTANCE,YDistance+125);
   ObjectSet(name+"7",OBJPROP_CORNER,Corner);
   ObjectSet(name+"7",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"7",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"8",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"8",IntegerToString(B_total_of_trades),FontSize,NULL,BackTestColorSg);
   ObjectSet(name+"8",OBJPROP_XDISTANCE,XDistance+185);
   ObjectSet(name+"8",OBJPROP_YDISTANCE,YDistance+125);
   ObjectSet(name+"8",OBJPROP_CORNER,Corner);
   ObjectSet(name+"8",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"8",OBJPROP_SELECTABLE,false);
//----
   ObjectCreate(0,name+"11",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"11","S-sig",FontSize,NULL,BackTestColorSg);
   ObjectSet(name+"11",OBJPROP_XDISTANCE,XDistance+185);
   ObjectSet(name+"11",OBJPROP_YDISTANCE,YDistance+75);//75
   ObjectSet(name+"11",OBJPROP_CORNER,Corner);
   ObjectSet(name+"11",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"11",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"12",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"12","Win",FontSize,NULL,BackTestColorUp);
   ObjectSet(name+"12",OBJPROP_XDISTANCE,XDistance+150);
   ObjectSet(name+"12",OBJPROP_YDISTANCE,YDistance+75);
   ObjectSet(name+"12",OBJPROP_CORNER,Corner);
   ObjectSet(name+"12",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"12",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"13",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"13","Lose",FontSize,NULL,BackTestColorDn);
   ObjectSet(name+"13",OBJPROP_XDISTANCE,XDistance+115);
   ObjectSet(name+"13",OBJPROP_YDISTANCE,YDistance+75);
   ObjectSet(name+"13",OBJPROP_CORNER,Corner);
   ObjectSet(name+"13",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"13",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"14",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"14","WinRate",FontSize,NULL,S_Color_Winrate);
   ObjectSet(name+"14",OBJPROP_XDISTANCE,XDistance+70);
   ObjectSet(name+"14",OBJPROP_YDISTANCE,YDistance+75);
   ObjectSet(name+"14",OBJPROP_CORNER,Corner);
   ObjectSet(name+"14",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"14",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"15",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"15",IntegerToString(S_total_itm),FontSize,NULL,BackTestColorUp);
   ObjectSet(name+"15",OBJPROP_XDISTANCE,XDistance+150);
   ObjectSet(name+"15",OBJPROP_YDISTANCE,YDistance+90);//90
   ObjectSet(name+"15",OBJPROP_CORNER,Corner);
   ObjectSet(name+"15",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"15",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"16",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"16",IntegerToString(S_total_otm),FontSize,NULL,BackTestColorDn);
   ObjectSet(name+"16",OBJPROP_XDISTANCE,XDistance+115);
   ObjectSet(name+"16",OBJPROP_YDISTANCE,YDistance+90);
   ObjectSet(name+"16",OBJPROP_CORNER,Corner);
   ObjectSet(name+"16",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"16",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"17",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"17",DoubleToString(S_total_winrate,1)+"%",FontSize,NULL,S_Color_Winrate);
   ObjectSet(name+"17",OBJPROP_XDISTANCE,XDistance+70);
   ObjectSet(name+"17",OBJPROP_YDISTANCE,YDistance+90);
   ObjectSet(name+"17",OBJPROP_CORNER,Corner);
   ObjectSet(name+"17",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"17",OBJPROP_SELECTABLE,false);
   
   ObjectCreate(0,name+"18",OBJ_LABEL,wind_ind,Time[0],Close[0]);
   ObjectSetText(name+"18",IntegerToString(S_total_of_trades),FontSize,NULL,BackTestColorSg);
   ObjectSet(name+"18",OBJPROP_XDISTANCE,XDistance+185);
   ObjectSet(name+"18",OBJPROP_YDISTANCE,YDistance+90);
   ObjectSet(name+"18",OBJPROP_CORNER,Corner);
   ObjectSet(name+"18",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSet(name+"18",OBJPROP_SELECTABLE,false);
}
//---------------------------------------------------------------------------------------------------+
string PeriodString()
{
    switch (_Period) 
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN1");
     }    
   return("M" + string(_Period));
}
//---------------------------------------------------------------------------------------------------+