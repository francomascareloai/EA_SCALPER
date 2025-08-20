//+------------------------------------------------------------------+
//|                                                   ����������.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property indicator_chart_window

extern int    CorPeriod_1 = 120;   // ������ ����������-1
extern int    CorPeriod_2 = 480;   // ������ ����������-2
extern double KK_level    = 0.80;  // ������� ��  
extern int    ControlBars = 50;    // ���������� ����� ��� ������� ������ 
extern int    Delta_level = 500;   // ���������� ����� ��� ������� ������ 
extern bool   DisplayInfo = true;

//+------------------------------------------------------------------+
string Index[8];      // ��� ������� ����� 
string Symbols[8,8];  // ��� �������� ���� �����
string Object_y[28];  // ���� ��� ������� �� ��� Y
string Object_x[28];  // ���� ��� ������� �� ��� X
string Sym_sym[28,28];// ��� ���� ��� (��)  
double Corr[28,28];   // ��� ������������ ���������� (��)
int    DIST_y[28];    // ���������� �� ��� Y
int    DIST_x[28];    // ���������� �� ��� X
string Delte[201]={"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""};    // ������ �����
string DelteText[201]={"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",
"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""};// ������ ����� ��������
//+------------------------------------------------------------------+
color Color = DodgerBlue;
int x=10,y=8,o,font_size=8,tic=20;
int    CorPeriod;
int dx,dy;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {

  
//----
   o=0;
//+------------------------------------------------------------------+
   Index[0]="JPY";
   Index[1]="CHF";
   Index[2]="CAD";
   Index[3]="USD";
   Index[4]="NZD";
   Index[5]="AUD";
   Index[6]="GBP";
   Index[7]="EUR";
//+------------------------------------------------------------------+
   for(int i=1;i<8;i++)
     {
    for(int j=0;j<i;j++)
      {
       Symbols[i,j] = StringConcatenate(Index[i],Index[j]); // ������������ ������� Symbols[i,j]
       Object_y[o] = Symbols[i,j];                          // ���������� ������� Object_y[o]  
       Object_x[o] = StringConcatenate(Symbols[i,j],"+");   // ���������� ������� Object_x[o] 
       DIST_y[o] = ((font_size+8)*28)+y-10-(font_size+6)*o;    // ������������ ������� DIST_y[o]
       DIST_x[o] = (x+font_size*8)+(font_size*4)*o;         // ������������ ������� DIST_x[o]
//----
       ObjectCreate(Object_y[o], OBJ_LABEL, 0, 0, 0);// �������� ���.
       ObjectSet(Object_y[o], OBJPROP_CORNER, 2);    // �������� ����
       ObjectSet(Object_y[o], OBJPROP_XDISTANCE, x); // ���������� �
       ObjectSet(Object_y[o], OBJPROP_YDISTANCE, DIST_y[o]);// ���������� Y
       ObjectSetText(Object_y[o],Symbols[i,j],font_size,"Arial",Color);// ��������� ������� �������
//----
       ObjectCreate(Object_x[o], OBJ_LABEL, 0, 0, 0);// �������� ���.
       ObjectSet(Object_x[o], OBJPROP_CORNER, 2);    // �������� ���� 
       ObjectSet(Object_x[o], OBJPROP_ANGLE, 90);    // �������� ������ �� ���� 
       ObjectSet(Object_x[o], OBJPROP_XDISTANCE,18+DIST_x[o]);// ���������� �
       ObjectSet(Object_x[o], OBJPROP_YDISTANCE, y); // ���������� Y
       ObjectSetText(Object_x[o],Symbols[i,j],font_size,"Arial",Color);// ��������� ������� �������
//+------------------------------------------------------------------+
       o++; 
      }
     } 
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i=0;i<28;i++)
     {
     if(Object_y[i]!="")
      ObjectDelete(Object_y[i]);              // �������� �������  
      if(Object_x[i]!="")
      ObjectDelete(Object_x[i]);              // �������� �������        
     }
//----
   for(int t=1;t<28;t++)
     {
    for(int c=0;c<t;c++)
      {
      if(Sym_sym[t,c]!="")
       ObjectDelete(Sym_sym[t,c]);            // �������� ������� 
      }
     } 
//---- 
      ObjectDelete("Info");                   // �������� �������              
      ObjectDelete("Info_1");                 // �������� ������� 
//---- 
   for(int d=0;d<201;d++)
     {
      if(Delte[d]!="")
      ObjectDelete(Delte[d]);                 // �������� �������  
      if(DelteText[d]!="")
      ObjectDelete(DelteText[d]);             // �������� �������  
     }
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
//+------------------------------------------------------------------+
  if(tic<5){tic++;return(0);}
  else tic=0;
//+------------------------------------------------------------------+
   for(int d=0;d<201;d++)
     {
      if(Delte[d]!="")
      ObjectDelete(Delte[d]);                 // �������� �������  
      if(DelteText[d]!="")
      ObjectDelete(DelteText[d]);             // �������� ������� 
     }
//+------------------------------------------------------------------+
  o=0;int o_1=0;dx=0;dy=0;
   string Text;
   for(int a=1;a<28;a++)
     {
    for(int b=0;b<a;b++)
      {
       Sym_sym[a,b] = StringConcatenate(Object_y[a],"_",Object_y[b]);
//---- 
       CorPeriod = CorPeriod_1;
       double C = Cor(Object_y[a], Object_y[b]);
       Text = DoubleToStr(C,2);
       Color = DimGray;
       if(C>=KK_level)
        {
         Color = Yellow;o++;
         CorPeriod = CorPeriod_2;
         C = Cor(Object_y[a], Object_y[b]);
         if(C>=KK_level){Object(0,a,b,o_1);Color = Lime;o_1++;}
        }
       if(C<=-KK_level)
        {         
         Color = Yellow;o++;
         CorPeriod = CorPeriod_2;
         C = Cor(Object_y[a], Object_y[b]);
         if(C<=-KK_level){Object(1,a,b,o_1);Color = Red;o_1++;}
        }
       ObjectCreate(Sym_sym[a,b], OBJ_LABEL, 0, 0, 0);// �������� ���.
       ObjectSet(Sym_sym[a,b], OBJPROP_CORNER, 2);    // �������� ����
       ObjectSet(Sym_sym[a,b], OBJPROP_XDISTANCE, DIST_x[b]); // ���������� �
       ObjectSet(Sym_sym[a,b], OBJPROP_YDISTANCE, DIST_y[a]);// ���������� Y
       ObjectSetText(Sym_sym[a,b],Text,font_size,"Arial",Color);// ��������� ������� �������
//---- 
      }
     } 
//----
//--------------------------------------------------------------- 2 --
   if (DisplayInfo)
   {
      Color = Yellow;
      Text = StringConcatenate(" KK period I = ",DoubleToStr(CorPeriod_1,0),"   KK level = ",DoubleToStr(KK_level, 2),"     Total III= ",DoubleToStr(o, 0));
      ObjectCreate("Info", OBJ_LABEL, 0, 0, 0);// �������� ���.
      ObjectSet("Info", OBJPROP_CORNER, 0);    // �������� ����
      ObjectSet("Info", OBJPROP_XDISTANCE, 10);// ���������� �
      ObjectSet("Info", OBJPROP_YDISTANCE, 15);// ���������� Y
      ObjectSetText("Info",Text,12,"Arial",Color);// ��������� ������� �������
//--------------------------------------------------------------- 3 --
//--------------------------------------------------------------- 2 --
      Color = Yellow;
      Text = StringConcatenate(" KK Period II = ",DoubleToStr(CorPeriod_2,0),"   Delta bars= ",DoubleToStr(ControlBars, 0),"   Total III 2 = ",DoubleToStr(o_1, 0));
      ObjectCreate("Info_1", OBJ_LABEL, 0, 0, 0);// �������� ���.
      ObjectSet("Info_1", OBJPROP_CORNER, 0);    // �������� ����
      ObjectSet("Info_1", OBJPROP_XDISTANCE, 10);// ���������� �
      ObjectSet("Info_1", OBJPROP_YDISTANCE, 35);// ���������� Y
      ObjectSetText("Info_1",Text,12,"Arial",Color);// ��������� ������� �������
   }      
//--------------------------------------------------------------- 3 --
//----
//   WindowRedraw();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//|  ����������                                                     |
//+------------------------------------------------------------------+ 
double symboldif(string symbol, int shift) 
  { 
    return(iClose(symbol, 0, shift) - 
           iMA(symbol, 0, CorPeriod, 0, MODE_SMA, 
               PRICE_CLOSE, shift)); 
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double powdif(double val) 
  { 
    return(MathPow(val, 2)); 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
double u(double val1,double val2) 
  { 
    return((val1*val2)); 
  }
//+------------------------------------------------------------------+
//|  ��� ��������� �������������� �������, ������� ����� �������     |
//+------------------------------------------------------------------+
double Cor(string base, string hedge) 
  { 
    double u1=0,l1=0,s1=0; 
    for(int i = CorPeriod - 1; i >= 0; i--) 
      { 
        u1 += u(symboldif(base, i), symboldif(hedge, i)); 
        l1 += powdif(symboldif(base, i)); 
        s1 += powdif(symboldif(hedge, i)); 
      } 
    if(l1*s1 > 0) 
        return(u1 / MathSqrt(l1*s1)); 
        return(0);
  } 
//+------------------------------------------------------------------+
//|  ������ ������� ������, � ���������                              |
//+------------------------------------------------------------------+
double Delta(string simbol_1, string simbol_2, bool simrev_2)
  {
  //---- ������ ������
   double arr_delta =0;
   double P_1=MarketInfo(simbol_1,MODE_POINT);
   double P_2=MarketInfo(simbol_2,MODE_POINT);
   double H_1 = iHigh(simbol_1,0,iHighest(simbol_1,0,MODE_HIGH,ControlBars,0));
   double L_1 = iLow (simbol_1,0,iLowest (simbol_1,0,MODE_LOW, ControlBars,0));
   double H_2 = iHigh(simbol_2,0,iHighest(simbol_2,0,MODE_HIGH,ControlBars,0));
   double L_2 = iLow (simbol_2,0,iLowest (simbol_2,0,MODE_LOW, ControlBars,0));
   double M_1 = (H_1+L_1)/2;
   double M_2 = (H_2+L_2)/2;
   double Cl_1 = iClose(simbol_1,0,0);   
   double Cl_2 = iClose(simbol_2,0,0);   
   double arr_simbol_1 = (Cl_1-M_1)/P_1;
   double arr_simbol_2 = (Cl_2-M_2)/P_2;
   if(simrev_2)
   {
   if((arr_simbol_1>0 && arr_simbol_2>0) || (arr_simbol_1<0 && arr_simbol_2<0))
   arr_delta = arr_simbol_1+arr_simbol_2;
   else arr_delta = 0;
   }
   else
   {   
   if((arr_simbol_1>0 && arr_simbol_2<0) || (arr_simbol_1<0 && arr_simbol_2>0))
   arr_delta = arr_simbol_1-arr_simbol_2;
   }   
  //----
   return(arr_delta);
  }
//+------------------------------------------------------------------+
//|  ������ ������� ������, � ���������                              |
//+------------------------------------------------------------------+
/*double Delta(string simbol_1, string simbol_2, bool simrev_2)
  {
  //---- ������ ������
   double arr_simbol_2;
   double P_1=MarketInfo(simbol_1,MODE_POINT);
   double P_2=MarketInfo(simbol_2,MODE_POINT);
   double H_1 = iHigh(simbol_1,0,iHighest(simbol_1,0,MODE_HIGH,ControlBars,0));
   double L_1 = iLow (simbol_1,0,iLowest (simbol_1,0,MODE_LOW, ControlBars,0));
   double H_2 = iHigh(simbol_2,0,iHighest(simbol_2,0,MODE_HIGH,ControlBars,0));
   double L_2 = iLow (simbol_2,0,iLowest (simbol_2,0,MODE_LOW, ControlBars,0));
   double M_1 = (H_1-L_1)/P_1;
   double M_2 = (H_2-L_2)/P_2;
   double Cl_1 = iClose(simbol_1,0,0);   
   double Cl_2 = iClose(simbol_2,0,0);   
   double arr_modul    = (M_1/M_2);
   double arr_simbol_1 = (Cl_1-L_1)/P_1/M_1;
   if(simrev_2)
   arr_simbol_2 = (H_2-Cl_2)/P_2/M_2;
   else   
   arr_simbol_2 = (Cl_2-L_2)/P_2/M_2;
   double arr_delta    = arr_simbol_1-arr_simbol_2;   
  //----
   return(arr_delta);
  }*/
//+------------------------------------------------------------------+
//| ������� ������                                                   |
//+------------------------------------------------------------------+
int Object(bool simrev,int a,int b,int o_1)
  {
//---- 
       if(dy==30 && dx==0){dx=150;dy=0;}
       if(dy==25 && dx==150){dx=300;dy=0;}
       color Color_d;
       double D = Delta(Object_y[a], Object_y[b],simrev);
       if(D<Delta_level && D>-Delta_level)return(0);
       Color_d = DimGray;
       if(D>=Delta_level)Color_d = Lime;
       if(D<=-Delta_level)Color_d = Red;
       string Text_d = StringConcatenate(DoubleToStr(D,0)," ");
       Delte[o_1] = StringConcatenate(Sym_sym[a,b],"+");
       ObjectCreate(Delte[o_1], OBJ_LABEL, 0, 0, 0);// �������� ���.
       ObjectSet(Delte[o_1], OBJPROP_CORNER, 0);    // �������� ����
       ObjectSet(Delte[o_1], OBJPROP_XDISTANCE, 850+dx); // ���������� �
       ObjectSet(Delte[o_1], OBJPROP_YDISTANCE, 15+dy*13);// ���������� Y
       ObjectSetText(Delte[o_1],Text_d,9,"Arial",Color_d);// ��������� ������� �������
//---- 
       if(simrev)Color_d = Red;
       else Color_d = Lime;
       Text_d = StringConcatenate(Sym_sym[a,b],"      ");
       DelteText[o_1] = StringConcatenate(Sym_sym[a,b],"++");
       ObjectCreate(DelteText[o_1], OBJ_LABEL, 0, 0, 0);// �������� ���.
       ObjectSet(DelteText[o_1], OBJPROP_CORNER, 0);    // �������� ����
       ObjectSet(DelteText[o_1], OBJPROP_XDISTANCE, 720+dx); // ���������� �
       ObjectSet(DelteText[o_1], OBJPROP_YDISTANCE, 15+dy*13);// ���������� Y
       ObjectSetText(DelteText[o_1],Text_d,9,"Arial",Color_d);// ��������� ������� �������
       dy++;
//---- 
   return(0);
  }
  
  

