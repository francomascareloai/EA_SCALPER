
#property copyright "Copyright © 2012, forex4live.com"
#property link      "http://www.forex4live.com/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 CLR_NONE
#property indicator_color2 DodgerBlue
#property indicator_color3 Red

extern int    TEMAPeriod       = 11;
extern int    SvePeriod        = 12;
extern double BBUpDeviations   = 2.3;
extern double BBDnDeviations   = 2.3;
extern int    DeviationsPeriod = 71;

       double G_ibuf_104[];
       double G_ibuf_108[];
       double G_ibuf_112[];
       double G_ibuf_116[];
       double G_ibuf_120[];
       double G_ibuf_124[];
       double Gda_128[][10];
       double Gd_132;

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
 {
  string Lsa_0[256];
  
  for (int index_4 = 0; index_4 < 256; index_4++)
   Lsa_0[index_4] = CharToStr(index_4);
  
  int str2int_8 = StrToInteger(Lsa_0[67] + Lsa_0[111] + Lsa_0[112] + Lsa_0[121] + Lsa_0[32] + Lsa_0[82] + Lsa_0[105] + Lsa_0[103] + Lsa_0[104] + Lsa_0[116] +
                               Lsa_0[32] + Lsa_0[169] + Lsa_0[32]  + Lsa_0[75]  + Lsa_0[97] + Lsa_0[122] + Lsa_0[97] + Lsa_0[111] + Lsa_0[111] + Lsa_0[32]  +
                               Lsa_0[50] + Lsa_0[48]  + Lsa_0[49]  + Lsa_0[49]  + Lsa_0[32]);
  
  IndicatorBuffers(6);
  
  SetIndexBuffer(0, G_ibuf_104);
  SetIndexBuffer(1, G_ibuf_108);
  SetIndexBuffer(2, G_ibuf_112);
  SetIndexBuffer(3, G_ibuf_116);
  SetIndexBuffer(4, G_ibuf_120);
  SetIndexBuffer(5, G_ibuf_124);
  
  Gd_132 = 2.0 / (TEMAPeriod + 1.0);
  IndicatorShortName("FL2 (" + TEMAPeriod + "," + SvePeriod + "," + DoubleToStr(BBUpDeviations, 2) + "," + DoubleToStr(BBDnDeviations, 2) + ")");
  
  return(0);
 }

// 52D46093050F38C27267BCE42543EF60
int deinit()
 {
  return(0);
 }

// EA2B2676C28C0DB26D39331A336C6B92
int start()
 {
  double Ld_16;
  double Ld_24;
  double Ld_32;
  double Ld_40;
  double Ld_48;
  double Ld_56;
  
  int Li_0 = IndicatorCounted();
  
  if (Li_0 < 0)
   return(-1);
  
  if (Li_0 > 0)
   Li_0--;
  
  int Li_12 = MathMin(Bars - Li_0, Bars - 1);
  
  if (ArrayRange(Gda_128, 0) != Bars)
   ArrayResize(Gda_128, Bars);
  
  int Li_4 = Li_12;
  
  for (int Li_8 = Bars - Li_4 - 1; Li_4 >= 0; Li_8++)
   {
    if (Li_4 == Bars - 1)
     Gda_128[Li_8][9] = f0_0(Li_4);
    else
     {
      Gda_128[Li_8][9] = (f0_0(Li_4) + Gda_128[Li_8 - 1][9]) / 2.0;
      
      Ld_16 = (f0_0(Li_4) + Gda_128[Li_8][9] + MathMax(High[Li_4], Gda_128[Li_8][9]) + MathMin(Low[Li_4], Gda_128[Li_8][9])) / 4.0;
      Ld_24 = f0_3(Ld_16, Li_4, 0);
      Ld_32 = f0_3(Ld_24, Li_4, 3);
      Ld_40 = Ld_24 - Ld_32;
      Ld_48 = Ld_24 + Ld_40;
      
      G_ibuf_116[Li_4] = f0_3(Ld_48, Li_4, 6);
     }
    
    Li_4--;
   }
  
  for (Li_4 = Li_12; Li_4 >= 0; Li_4--)
   {
    Ld_56 = f0_1(G_ibuf_116, SvePeriod, Li_4);
    
    if (Ld_56 != 0.0)
     G_ibuf_120[Li_4] = 25.0 * (G_ibuf_116[Li_4] + 2.0 * Ld_56 - iMAOnArray(G_ibuf_116, 0, SvePeriod, 0, MODE_LWMA, Li_4)) / Ld_56;
    else
     G_ibuf_120[Li_4] = 0;
    
    Ld_56 = f0_1(G_ibuf_120, DeviationsPeriod, Li_4);
    
    G_ibuf_104[Li_4] = G_ibuf_120[Li_4];
    G_ibuf_108[Li_4] = Ld_56 * BBUpDeviations + 50.0;
    G_ibuf_112[Li_4] = 50.0 - Ld_56 * BBDnDeviations;
    G_ibuf_124[Li_4] = G_ibuf_124[Li_4 + 1];
    
    if (G_ibuf_104[Li_4] > G_ibuf_108[Li_4])
     G_ibuf_124[Li_4] = 1;
    
    if (G_ibuf_104[Li_4] < G_ibuf_112[Li_4])
     G_ibuf_124[Li_4] = -1;
    
    if (G_ibuf_104[Li_4] > G_ibuf_112[Li_4] &&
        G_ibuf_104[Li_4] < G_ibuf_108[Li_4])
     G_ibuf_124[Li_4] = 0;
   }
  
  return(0);
 }

// 0D7ACF43BA85E0E3BF0A7DB4333FC6CA
double f0_0(int Ai_0)
 {
  if (Open[Ai_0] != 0.0)
   return((Open[Ai_0] + High[Ai_0] + Low[Ai_0] + Close[Ai_0]) / 4.0);
  
  return((High[Ai_0] + Low[Ai_0] + Close[Ai_0]) / 3.0);
 }

// 33B5F9392F2A76B37F7C243381478E4B
double f0_1(double Ada_0[], int Ai_4, int Ai_8)
 {
  double Ld_12 = f0_2(Ada_0, Ai_4, Ai_8);
  double Ld_20 = 0;
  
  int count_28 = 0;
  
  while (count_28 < Ai_4)
   {
    Ld_20 += (Ada_0[Ai_8] - Ld_12) * (Ada_0[Ai_8] - Ld_12);
    count_28++;
    Ai_8++;
   }
  
  return(MathSqrt(Ld_20 / Ai_4));
 }

// 420A52726C9FD7552E0DFE0F10124329
double f0_2(double Ada_0[], int Ai_4, int Ai_8)
 {
  double Ld_12 = 0.0;
  
  int count_20 = 0;
  
  while (count_20 < Ai_4)
   {
    Ld_12 += Ada_0[Ai_8];
    count_20++;
    Ai_8++;
   }
  
  return(Ld_12 / Ai_4);
 }

// 9923DC4630FF8CC7916F8BCDC5A9549B
double f0_3(double Ad_0, int Ai_8, int Ai_12 = 0)
 {
  int Li_16 = Bars - Ai_8 - 1;
  int Li_20 = Ai_12 + 0;
  int Li_24 = Ai_12 + 1;
  int Li_28 = Ai_12 + 2;
  
  if (Li_16 < 1)
   {
    Gda_128[Li_16][Li_20] = Ad_0;
    Gda_128[Li_16][Li_24] = Ad_0;
    Gda_128[Li_16][Li_28] = Ad_0;
   }
  else
   {
    Gda_128[Li_16][Li_20] = Gda_128[Li_16 - 1][Li_20] + Gd_132 * (Ad_0 - (Gda_128[Li_16 - 1][Li_20]));
    Gda_128[Li_16][Li_24] = Gda_128[Li_16 - 1][Li_24] + Gd_132 * (Gda_128[Li_16][Li_20] - (Gda_128[Li_16 - 1][Li_24]));
    Gda_128[Li_16][Li_28] = Gda_128[Li_16 - 1][Li_28] + Gd_132 * (Gda_128[Li_16][Li_24] - (Gda_128[Li_16 - 1][Li_28]));
   }
  
  return(3.0 * Gda_128[Li_16][Li_20] - 3.0 * Gda_128[Li_16][Li_24] + Gda_128[Li_16][Li_28]);
 }
