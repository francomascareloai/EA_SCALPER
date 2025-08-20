#property copyright "";
#property link "";
#property version "";

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_level1 0
#property indicator_levelcolor DimGray
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#property indicator_color1 LightGreen
#property indicator_width1 3

#property indicator_color2 LightSalmon
#property indicator_width2 3

#property indicator_color3 DimGray
#property indicator_width3 1

extern int RLength = 8;

int Ii_0 = 98;
double Id_14[];
double Id_48[];
double Id_7C[];
double Id_B0[];
double Id_E4[];
int Ii_118 = 109;

int Gi_0;
int Ii_8;
int Ii_C;
int Ii_4;
int Gi_1;
double Gd_0;
double Gd_2;
int Gi_3;
double Gd_3;
double Gd_4;
int Gi_5;
double Gd_5;
int Gi_6;
double Gd_6;
int Gi_4;
int Gi_7;
double Gd_7;
double Gd_8;
int Gi_9;
double Gd_9;
double Gd_A;
int Gi_B;
double Gd_B;
int Gi_A;
int Gi_C;
double Gd_C;
int Gi_D;
int Gi_E;
double Gd_E;
double Gd_D;
double Gd_F;
int Gi_10;
double Gd_10;
int Gi_F;
int Gi_11;
double Gd_11;
double Gd_12;
int Gi_13;
double Gd_13;
int Gi_12;
int Gi_14;
double Gd_14;
double Gd_15;
int Gi_16;
double Gd_16;
int Gi_15;
int Gi_17;
double Gd_17;
int Gi_18;
double Gd_18;
int Gi_19;
int Gi_1A;
double Gd_1A;
double Gd_19;
int Gi_1B;
double Gd_1B;
int Gi_1C;
int Gi_1D;
double Gd_1D;
double Gd_1C;
bool Ib_10;
bool Ib_11;
int Gi_2;

int init()
{
    int Li_C;

    Li_C = 0;
    IndicatorBuffers(5);
    SetIndexBuffer(0, Id_48);
    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(1, Id_7C);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexBuffer(2, Id_14);
    SetIndexBuffer(3, Id_B0);
    SetIndexBuffer(4, Id_E4);
    if (IndicatorInit() == false) return 0;
    Print("Индикатор инициирован (", 72, "). KX1. ТФ = ", _Period);
    Li_C = 0;
    return 0;
}

int start()
{
    int Li_C;
    int Li_8;
    int Li_4;
    int Li_0;
    double Ld_E8;
    double Ld_E0;
    double Ld_D8;

    Li_C = 0;
    Li_8 = 0;
    Li_4 = 0;
    Li_0 = 0;
    Ld_E8 = 0;
    Ld_E0 = 0;
    Ld_D8 = 0;
    Li_8 = IndicatorCounted();
    Li_4 = 0;
    Li_0 = 0;
    if (IndicatorInit() != true)
    {
        Li_C = 0;
        return Li_C;
    }
    Gi_0 = Ii_118 - Ii_0;
    Gi_0 = Ii_8 / Gi_0;
    Ii_C = Gi_0 - Ii_4;
    if (Li_8 < 0)
    {
        Li_C = -1;
        return Li_C;
    }
    if (Li_8 > 0)
    {
        Li_8 = Li_8 - 1;
    }
    Gi_0 = Bars - 1;
    Gi_1 = Bars - Li_8;
    if (Gi_1 >= Gi_0)
    {
    }
    else
    {
        Gi_0 = Gi_1;
    }
    Li_0 = Gi_0;
    Ld_E8 = (2.0 / ((RLength * 5) + 1));
    Li_4 = Gi_0;
    if (Gi_0 < 0) return 0;
    do
    {
        Gd_2 = (Close[Li_4] * 3);
        Gi_3 = iLowest(NULL, 0, 1, RLength, Li_4);
        Gd_4 = (Low[Gi_3] * 2);
        Gd_4 = (Gd_2 - Gd_4);
        Gi_5 = Li_4 + RLength;
        Gd_4 = ((Gd_4 - Open[Gi_5]) * 100);
        Ld_E0 = (Gd_4 / Close[Li_4]);
        Gi_4 = Li_4 + RLength;
        Gi_7 = iHighest(NULL, 0, 2, RLength, Li_4);
        Gd_8 = ((High[Gi_7] * 2) + Open[Gi_4]);
        Gd_A = (Close[Li_4] * 3);
        Gd_A = ((Gd_8 - Gd_A) * 100);
        Ld_D8 = (Gd_A / Close[Li_4]);
        Gi_A = Bars - 1;
        if (Li_4 == Gi_A)
        {
            Id_B0[Li_4] = Ld_E0;
            Id_E4[Li_4] = Ld_D8;
        }
        else
        {
            Gi_D = Li_4 + 1;
            Gi_E = Li_4 + 1;
            Gd_F = (((Ld_E0 - Id_B0[Gi_E]) * Ld_E8) + Id_B0[Gi_D]);
            Id_B0[Li_4] = Gd_F;
            Gi_F = Li_4 + 1;
            Gi_11 = Li_4 + 1;
            Gd_12 = (((Ld_D8 - Id_E4[Gi_11]) * Ld_E8) + Id_E4[Gi_F]);
            Id_E4[Li_4] = Gd_12;
            Gd_15 = (Id_B0[Li_4] - Id_E4[Li_4]);
            Gd_15 = (Gd_15 + Ii_C);
            Id_14[Li_4] = Gd_15;
            Id_48[Li_4] = 2147483647;
            Id_7C[Li_4] = 2147483647;
            if ((Id_14[Li_4] > 0))
            {
                Id_48[Li_4] = Id_14[Li_4];
            }
            if ((Id_14[Li_4] < 0))
            {
                Id_7C[Li_4] = Id_14[Li_4];
            }
        }
        Li_4 = Li_4 - 1;
    } while (Li_4 >= 0);

    Li_C = 0;
    return Li_C;
}

bool IndicatorInit()
{
    string str_0;
    string str_1;
    string str_2;
    bool Lb_F;

    Lb_F = false;
    Gi_0 = 0;
    Gi_1 = 0;
    Gi_2 = 0;
    if (Ib_10 != true)
    {
        if (AccountNumber() == 0) return Ib_10;

        uchar symbolBytes[];
        uchar encryptedBytes[];
        uchar keyBytes[];
        StringToCharArray("TGYK12OT", keyBytes, 0, -1, 0);
        StringToCharArray(_Symbol, symbolBytes, 0, -1, 0);
        CryptEncode(CRYPT_DES, symbolBytes, keyBytes, encryptedBytes);
        Gi_0 = -1;
        str_2 = "";
        Gi_1 = 0;
        Gi_4 = ArraySize(encryptedBytes);
        Gi_0 = Gi_4;
        Gi_2 = 0;
        if (Gi_4 > 0)
        {
            do
            {
                str_2 = str_2 + StringFormat("%.2X", encryptedBytes[Gi_2]);
                Gi_1 = Gi_1 + encryptedBytes[Gi_2] * (Gi_2 + 1);
                Gi_2 = Gi_2 + 1;
            } while (Gi_2 < Gi_0);
        }
        ArrayFree(keyBytes);
        ArrayFree(encryptedBytes);
        ArrayFree(symbolBytes);

        Ii_4 = Gi_1;
        Ii_8 = SymbolTick3(Gi_1);
        Ib_10 = true;
        Ib_11 = true;
        return Ib_10;
    }
    Ib_11 = false;

    Lb_F = Ib_10;
    return Lb_F;
}

int SymbolTick3(int symbolHash)
{
    return symbolHash * 11;
}
