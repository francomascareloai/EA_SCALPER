/*
<<����� �� �����>>

iCustom(NULL,0,"AdaptiveRenko",
   K,             // ��������� ATR (>0) ��� StDev (<0) 
   VltPeriod,     // ������ �������������; ���� ������ ����� ���� ������: �� Close (>0) ��� �� High/Low (<0)
   WideMin,       // ����������� ������� ������� � ��.
   N,             // ������: 0- ���������, 1- �������������, 2- �����.��.�������, 3- ������
   i)             // �����
*/
#property indicator_chart_window // � ���� �����������
#property indicator_buffers 4
#property indicator_color1 Green // 
#property indicator_color2 Red // 
#property indicator_color3 Green // 
#property indicator_color4 Red // 


// ������� ���������
extern double K=1; // ��������� ATR (>0) ��� StDev (<0) 
 bool ATR_StD=1; // 0- StDev, 1- ATR
extern int VltPeriod=10; // ������ ������������� �� Close (>0) ��� �� High/Low (<0)
 bool Price=0; // 0- Close, 1- High/Low
extern int WideMin=2; // ����������� ������� ������� � ��.
   double sens; // ����������� ������� ������� � �����

 int History=0; // 0- ��� ����

// ���.������
double   UpTrend[], // ���������
         DnTrend[], // �������������
         UP[], // ������� ������� ��������
         DN[]; // ������

// �������������
void init()
  {
   string _v="Renko";
   if(VltPeriod<0) {VltPeriod=-VltPeriod; Price=1; _v=_v+"(HiLo) ";} else _v=_v+"(Close) ";
   if(K!=0) {
      _v=_v+DoubleToStr(MathAbs(K),1)+"x";
      if(K<0) {K=-K; ATR_StD=0; _v=_v+"StDev(";} else _v=_v+"ATR(";
      _v=_v+VltPeriod+") ";
     }
   if(WideMin>0) {sens=WideMin*Point; _v=_v+"min="+WideMin+"p.";}
   Comment(_v);
   
   SetIndexBuffer(0,UpTrend);
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexEmptyValue(0,0.0);

   SetIndexBuffer(1,DnTrend);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexEmptyValue(1,0.0);

   SetIndexBuffer(2,UP);
   SetIndexStyle(2,DRAW_LINE,2);

   SetIndexBuffer(3,DN);
   SetIndexStyle(3,DRAW_LINE,2);

  }

// �-� �������������� �������������
int reinit() 
  {
   ArrayInitialize(UpTrend,0.0); // ��������� �������
   ArrayInitialize(DnTrend,0.0); // ��������� �������
   ArrayInitialize(DN,0.0); // ��������� �������
   ArrayInitialize(UP,0.0); // ��������� �������
   return(0);
  }

void deinit()
  {
   Comment("");
  }

void start()
  {
   int ic=IndicatorCounted();
   if(Bars-ic-1>1) ic=reinit(); // ���� ���� ����������� ���� �� �� ����������� - ��������
   int limit=Bars-ic-1; // ���-�� ����������
   if(ic==0) limit-=VltPeriod;
   if(History>0) limit=MathMin(limit,History-1); // ���-�� ���������� �� �������

   for(int i=limit; i>=0; i--) { // ���� ��������� �� ���� �����
      bool reset=i==limit && limit>1; // ����� �� ������ �������� ����� ���������

      int sh=i+1;
      if(!Price) {double Hi=Close[sh]; double Lo=Hi;}
      else {Hi=High[sh]; Lo=Low[sh];} 
      
      static double Brick,Up,Dn;
      if(reset) {
         Brick=MathMax(K*(Hi-Lo),sens);
         Up=Hi; Dn=Lo;
        }

      if(ATR_StD) double vlt=iATR(NULL,0,VltPeriod, sh);
      else vlt=iStdDev(NULL,0,VltPeriod,0,0,0, sh);
      vlt=MathMax(K*vlt,sens);
        
      if(Hi>Up+Brick) {
         if(Brick==0) double BricksUp=0; 
         else BricksUp=MathFloor((Hi-Up)/Brick)*Brick;
         Up=Up+BricksUp;
         Brick=vlt;
         Dn=Up-Brick;
         double BricksDn=0;
        }
      if(Lo<Dn-Brick) {
         if(Brick==0) BricksDn=0; 
         else BricksDn=MathFloor((Dn-Lo)/Brick)*Brick;
         Dn=Dn-BricksDn;
         Brick=vlt;
         Up=Dn+Brick;
         BricksUp=0;
        }
      // ������� ��������
      UP[i]=Up; DN[i]=Dn;
      // �����
      static bool dir;
      if(UP[i+1]<UP[i]) dir=1;
      if(DN[i+1]>DN[i]) dir=0;
      if(dir)  UpTrend[i]=DN[i]-Brick;
      else     DnTrend[i]=UP[i]+Brick;
      
     }   
  }



