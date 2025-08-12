#property copyright "";
#property link "";
#property version "";

#property indicator_separate_window
#property indicator_buffers 6

#property indicator_color1 RoyalBlue

#property indicator_color2 Crimson

#property indicator_color3 Blue

#property indicator_color4 Red

#property indicator_color5 Blue

#property indicator_color6 Red

extern bool EnableAlerts;
extern color BullishDivergenceColor = DodgerBlue;
extern color BearishDivergenceColor = FireBrick;

int Ii_0 = 98;
int Ii_14 = 20;
int Ii_18 = 35;
string Is_20 = "Level colors";
int Ii_2C = 2237106;
int Ii_30 = 6908265;
int Ii_34 = 25600;
int Ii_38 = 2;
string Is_40 = "Cobra Label colors";
int Ii_4C = 30583;
int Ii_50 = 30583;
int Ii_54 = 32768;
string Is_60 = "CBullishDiv.wav";
int Ii_6C = 1;
int Ii_88 = 750;
double Id_98 = 0.7;
double Id_A0[];
double Id_D4[];
double Id_108[];
double Id_13C[];
double Id_170[];
double Id_1A4[];
string Is_220 = "*** Divergence Settings ***";
int Ii_22C = 500;
bool Ib_230 = true;
string Is_238 = "--- Divergence Alert Settings ---";
string Is_258 = "------------------------------------";
string Is_268 = "SoundAlertOnDivergence only works";
string Is_278 = "when EnableAlerts is true.";
string Is_298 = "If SoundAlertOnDivergence is true,";
string Is_2A8 = "then sound alert will be generated,";
string Is_2B8 = "otherwise a pop-up alert will be";
string Is_2C8 = "generated.";
string Is_2D8 = "------------------------------------";
string Is_2F8 = "--- Divergence Color Settings ---";
string Is_308 = "--- Divergence Sound Files ---";
string Is_318 = "CBullishDiv.wav";
string Is_328 = "RBullishDiv.wav";
string Is_338 = "CBearishDiv.wav";
string Is_348 = "RBearishDiv.wav";
double Id_354[];
double Id_388[];
int Ii_3BC = 109;

int Gi_0;
string Is_1F0;
string Is_200;
int Gi_1;
int Gi_2;
int Gi_3;
int Gi_4;
int Gi_5;
int Gi_6;
int Ii_8;
int Ii_C;
int Ii_4;
bool Gb_6;
double Id_80;
double Gd_6;
int Gi_7;
long Gl_8;
long Gl_7;
int Gi_9;
double Gd_9;
int Gi_A;
long Gl_B;
long Gl_A;
int Gi_C;
double Gd_C;
int Gi_D;
long Gl_E;
long Gl_D;
int Gi_F;
int Ii_8C;
int Ii_90;
bool Gb_F;
int Gi_10;
long Gl_F;
long Gl_10;
bool Gb_11;
int Gi_11;
int Gi_12;
bool Gb_13;
bool Ib_232;
double Gd_13;
int Gi_13;
int Gi_14;
double Gd_14;
int Gi_15;
double Gd_15;
double Gd_16;
double Gd_17;
bool Gb_17;
int Gi_17;
double Gd_18;
double Gd_19;
int Gi_1A;
double Gd_1A;
int Gi_1B;
double Gd_1B;
int Gi_19;
double Id_1E0;
int Gi_1F;
double Gd_1F;
int Gi_20;
double Gd_20;
int Gi_21;
int Gi_22;
bool Gb_23;
double Gd_21;
double Gd_22;
int Gi_23;
bool Gb_24;
double Gd_23;
int Gi_24;
int Gi_25;
double Gd_25;
double Gd_24;
int Gi_26;
int Gi_27;
double Gd_27;
double Gd_26;
int Gi_2F;
double Gd_2F;
int Gi_30;
double Gd_30;
int Gi_31;
int Gi_32;
bool Gb_33;
double Gd_31;
double Gd_32;
int Gi_33;
bool Gb_34;
double Gd_33;
int Gi_34;
int Gi_35;
double Gd_35;
double Gd_34;
int Gi_36;
int Gi_37;
double Gd_37;
double Gd_36;
bool Gb_3F;
int Gi_3F;
double Id_1D8;
bool Ib_5D;
int Gi_40;
bool Gb_41;
double Gd_3F;
double Gd_40;
int Gi_41;
bool Gb_42;
double Gd_41;
int Gi_42;
bool Gb_43;
double Gd_42;
int Ii_1E8;
bool Ib_70;
int Gi_43;
long Gl_43;
long Gl_44;
bool Ib_58;
bool Ib_5A;
bool Ib_59;
int Gi_49;
long Gl_49;
int Gi_4B;
long Gl_4B;
int Gi_44;
int Gi_45;
bool Gb_46;
double Gd_44;
double Gd_45;
int Gi_46;
bool Gb_47;
double Gd_46;
int Gi_47;
bool Gb_48;
double Gd_47;
int Gi_48;
long Gl_48;
int Gi_4A;
long Gl_4A;
int Gi_38;
int Gi_39;
bool Gb_3A;
double Gd_38;
double Gd_39;
int Gi_3A;
bool Gb_3B;
double Gd_3A;
int Gi_3B;
int Gi_3C;
double Gd_3C;
double Gd_3B;
int Gi_3D;
int Gi_3E;
double Gd_3E;
double Gd_3D;
int Gi_28;
int Gi_29;
bool Gb_2A;
double Gd_28;
double Gd_29;
int Gi_2A;
bool Gb_2B;
double Gd_2A;
int Gi_2B;
int Gi_2C;
double Gd_2C;
double Gd_2B;
int Gi_2D;
int Gi_2E;
double Gd_2E;
double Gd_2D;
bool Gb_1C;
double Gd_1C;
int Gi_1D;
double Gd_1D;
int Gi_1E;
double Gd_1E;
int Gi_1C;
int Gi_16;
bool Ib_10;
bool Ib_11;
bool Ib_5B;
bool Ib_5C;
int Ii_74;
int Ii_78;
long Il_210;
long Il_218;
bool Ib_231;
string Is_248;
string Is_288;
string Is_2E8;
bool Ib_2F4;
bool Ib_2F5;
double Gd_7;
double Gd_8;
double Gd_A;
int Gi_B;
double Gd_D;
double Gd_E;
double Gd_10;
int Gi_18;
bool Gb_22;
bool Gb_26;
bool Gb_28;
bool Gb_2C;
bool Gb_2E;
bool Gb_30;
bool Gb_32;
bool Gb_36;
bool Gb_38;
long Gl_3E;
long Gl_3F;
long Gl_40;
long Gl_41;
long Gl_45;
long Gl_46;
bool Gb_4A;
double Gd_48;
double Gd_49;
double Gd_4A;
double Gd_4B;
int Gi_4C;
double Gd_4C;
int Gi_4D;
double Gd_4D;
int Gi_4E;
long Gl_4E;
int Gi_4F;
long Gl_4F;
double Gd_50;
long Gl_50;
long Gl_51;
int Gi_51;
double Gd_51;
int Gi_52;
double Gd_52;
int Gi_53;
long Gl_53;
int Gi_54;
long Gl_54;
double Gd_55;
long Gl_55;
long Gl_56;
int Gi_56;
int Gi_57;
long Gl_57;
bool Gb_25;
bool Gb_27;
bool Gb_29;
bool Gb_2D;
bool Gb_2F;
bool Gb_31;
bool Gb_35;
bool Gb_37;
bool Gb_39;
long Gl_42;
double Gd_43;
long Gl_47;
bool Gb_4B;
bool Gb_4D;
double Gd_4E;
double Gd_4F;
int Gi_50;
long Gl_52;
double Gd_53;
double Gd_54;
int Gi_55;
double Gd_58;
long Gl_58;
long Gl_59;
int Gi_59;
int Gi_5A;
long Gl_5A;

int init()
{
    int Li_C;

    Li_C = 0;
    IndicatorBuffers(8);
    SetIndexStyle(0, DRAW_LINE, 0, 4);
    SetIndexBuffer(0, Id_D4);
    SetIndexStyle(1, DRAW_LINE, 0, 4);
    SetIndexBuffer(1, Id_108);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(2, Id_170);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexBuffer(3, Id_1A4);
    SetIndexBuffer(4, Id_354);
    SetIndexBuffer(5, Id_388);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexStyle(5, DRAW_NONE);
    SetIndexDrawBegin(5, 9);
    IndicatorDigits((_Digits + 2));
    SetIndexBuffer(6, Id_13C);
    SetIndexBuffer(7, Id_A0);
    Is_1F0 = "1234.01";
    Is_200 = "1234.01";
    IndicatorShortName(Is_1F0);
    if (IndicatorInit() == false) return 0; // Goto_00000000
    Print("Индикатор инициирован (", 72, "). KX4. ТФ = ", _Period);
    // Label 00000002
    Li_C = 0;
    return 0;
}

int start()
{
    string str_0;
    string str_1;
    string str_2;
    string str_3;
    string str_4;
    string str_5;
    string str_6;
    string str_7;
    string str_8;
    string str_9;
    string str_A;
    string str_B;
    int Li_C;
    double Ld_0;
    string Ls_E0;
    string Ls_D0;
    double Ld_C8;
    double Ld_C0;
    int Li_BC;
    double Ld_B0;
    double Ld_A8;
    double Ld_A0;
    double Ld_98;
    double Ld_90;
    double Ld_88;
    double Ld_80;
    double Ld_78;
    double Ld_70;
    double Ld_68;
    double Ld_60;
    double Ld_58;
    double Ld_50;
    double Ld_48;
    double Ld_40;
    double Ld_38;
    double Ld_30;
    double Ld_28;
    double Ld_20;
    double Ld_18;
    double Ld_10;
    double Ld_08;
    double Ld_00;
    double Ld_EF8;
    double Ld_EF0;
    double Ld_EE8;
    double Ld_EE0;
    double Ld_ED8;
    double Ld_ED0;
    double Ld_EC8;
    double Ld_EC0;
    double Ld_EB8;
    double Ld_EB0;
    double Ld_EA8;
    double Ld_EA0;
    double Ld_E98;
    double Ld_E90;
    double Ld_E88;
    double Ld_E80;
    double Ld_E78;
    double Ld_E70;
    double Ld_E68;
    double Ld_E60;
    double Ld_E58;
    double Ld_E50;
    double Ld_E48;
    double Ld_E40;
    string Ls_E30;
    int Li_E2C;
    bool Lb_E2B;

    Li_C = 0;
    Ld_0 = 0;
    Ld_C8 = 0;
    Ld_C0 = 0;
    Li_BC = 0;
    Ld_B0 = 0;
    Ld_A8 = 0;
    Ld_A0 = 0;
    Ld_98 = 0;
    Ld_90 = 0;
    Ld_88 = 0;
    Ld_80 = 0;
    Ld_78 = 0;
    Ld_70 = 0;
    Ld_68 = 0;
    Ld_60 = 0;
    Ld_58 = 0;
    Ld_50 = 0;
    Ld_48 = 0;
    Ld_40 = 0;
    Ld_38 = 0;
    Ld_30 = 0;
    Ld_28 = 0;
    Ld_20 = 0;
    Ld_18 = 0;
    Ld_10 = 0;
    Ld_08 = 0;
    Ld_00 = 0;
    Ld_EF8 = 0;
    Ld_EF0 = 0;
    Ld_EE8 = 0;
    Ld_EE0 = 0;
    Ld_ED8 = 0;
    Ld_ED0 = 0;
    Ld_EC8 = 0;
    Ld_EC0 = 0;
    Ld_EB8 = 0;
    Ld_EB0 = 0;
    Ld_EA8 = 0;
    Ld_EA0 = 0;
    Ld_E98 = 0;
    Ld_E90 = 0;
    Ld_E88 = 0;
    Ld_E80 = 0;
    Ld_E78 = 0;
    Ld_E70 = 0;
    Ld_E68 = 0;
    Ld_E60 = 0;
    Ld_E58 = 0;
    Ld_E50 = 0;
    Ld_E48 = 0;
    Ld_E40 = 0;
    Li_E2C = 0;
    Lb_E2B = false;
    Gi_0 = 0;
    Gi_1 = 0;
    Gi_2 = 0;
    Gi_3 = 0;
    Gi_4 = 0;
    Gi_5 = 0;
    Ld_0 = 0;
    if (IndicatorInit() != true)
    { // Goto_00000005
        Li_C = 0;
        return Li_C;
    } // Label 00000005
    Gi_6 = Ii_3BC - Ii_0;
    Gi_6 = Ii_8 / Gi_6;
    Ii_C = Gi_6 - Ii_4;
    if (_Period == 1)
    { // Goto_00000008
        Ld_0 = 0.0002;
    } // Label 00000008
    if (_Period == 5)
    { // Goto_0000000A
        Ld_0 = 0.0003;
    } // Label 0000000A
    if (_Period == 15)
    { // Goto_0000000C
        Ld_0 = 0.0005;
    } // Label 0000000C
    if (_Period == 30)
    { // Goto_0000000E
        Ld_0 = 0.008;
    } // Label 0000000E
    if (_Period == 60)
    { // Goto_00000010
        Ld_0 = 0.0012;
    } // Label 00000010
    if (_Period == 240)
    { // Goto_00000012
        Ld_0 = 0.003;
    } // Label 00000012
    if (_Period == 1440)
    { // Goto_00000014
        Ld_0 = 0.005;
    } // Label 00000014
    if (_Period == 10080)
    { // Goto_00000016
        Ld_0 = 0.08;
    } // Label 00000016
    if (_Period == 43200)
    { // Goto_00000018
        Ld_0 = 0.015;
    } // Label 00000018
    if ((Id_80 > 0))
    { // Goto_0000001A
        Ld_0 = Id_80;
    } // Label 0000001A
    Ld_C8 = Ld_0;
    Ld_C0 = -Ld_0;
    Gi_1 = Ii_38;
    Gi_0 = Ii_2C;
    str_0 = "T_line_HL";
    ObjectDelete(str_0);
    ObjectCreate(0, str_0, OBJ_HLINE, WindowFind(Is_1F0), Time[0], Ld_0, 0, 0, 0, 0);
    ObjectSet(str_0, OBJPROP_STYLE, Gi_1);
    ObjectSet(str_0, OBJPROP_COLOR, Gi_0);
    ObjectSet(str_0, OBJPROP_WIDTH, 1);
    Gi_3 = Ii_38;
    Gi_2 = Ii_30;
    str_1 = "T_line_ZL";
    ObjectDelete(str_1);
    ObjectCreate(0, str_1, OBJ_HLINE, WindowFind(Is_1F0), Time[0], 0, 0, 0, 0, 0);
    ObjectSet(str_1, OBJPROP_STYLE, Gi_3);
    ObjectSet(str_1, OBJPROP_COLOR, Gi_2);
    ObjectSet(str_1, OBJPROP_WIDTH, 1);
    Gi_5 = Ii_38;
    Gi_4 = Ii_34;
    str_2 = "T_line_LL";
    ObjectDelete(str_2);
    ObjectCreate(0, str_2, OBJ_HLINE, WindowFind(Is_1F0), Time[0], Ld_C0, 0, 0, 0, 0);
    ObjectSet(str_2, OBJPROP_STYLE, Gi_5);
    ObjectSet(str_2, OBJPROP_COLOR, Gi_4);
    ObjectSet(str_2, OBJPROP_WIDTH, 1);
    Li_BC = 0;
    Ld_B0 = 0;
    Ld_A8 = 0;
    Ld_A0 = 0;
    Ld_98 = 0;
    Ld_90 = 0;
    Ld_88 = 0;
    Ld_80 = 0;
    Ld_78 = 0;
    Ld_70 = 0;
    Ld_68 = 0;
    Ld_60 = 0;
    Ld_58 = 0;
    Ld_50 = 0;
    Ld_48 = 0;
    Ld_40 = 0;
    Ld_38 = 0;
    Ld_30 = 0;
    Ld_28 = 0;
    Ld_20 = 0;
    Ld_18 = 0;
    Ld_10 = 0;
    Ld_08 = 0;
    Ld_00 = 0;
    Ld_EF8 = 0;
    Ld_EF0 = 0;
    Ld_EE8 = 0;
    Ld_EE0 = 0;
    Ld_ED8 = 0;
    Ld_ED0 = 0;
    Ld_EC8 = 0;
    Ld_EC0 = 0;
    Ld_EB8 = 0;
    Ld_EB0 = 0;
    Ld_EA8 = 0;
    Ld_EA0 = 0;
    Ld_E98 = 0;
    Ld_E90 = 0;
    Ld_E88 = 0;
    Ld_E80 = 0;
    Ld_E78 = 0;
    Ld_E70 = 1;
    Ld_E68 = 0;
    Ld_E60 = 0;
    Ld_E58 = 0;
    Ld_E50 = 0;
    Ld_E48 = 0;
    Ld_E40 = 0;
    Ls_E30 = "nonono";
    Li_E2C = IndicatorCounted();
    Lb_E2B = true;
    Gi_F = Ii_88 + Ii_14;
    Gi_F = Gi_F + Ii_8C;
    Gi_F = Gi_F + Ii_18;
    Gi_F = Gi_F + Ii_90;
    Ld_E50 = (Gi_F + Id_98);
    if ((Ld_E50 == 0) && _Symbol == "nonono" &&
        (Ld_E40 == Time[4] - Time[5]) && ((Bars - Ld_E60) < 2))
    {
        Ld_E58 = (Bars - Ld_E60);
    }
    else
    {
        Ld_E58 = -1;
    } // Label 00000025
    Ls_E30 = _Symbol;
    Ld_E40 = Time[4] - Time[5];
    Ld_E60 = Bars;
    Ld_E48 = Ld_E50;
    if ((Ld_E58 == 1) || (Ld_E58 == 0))
    { // Goto_00000035
      // Label 00000034
        Ld_E68 = Ld_E58;
    } // Goto_00000033
    else
    { // Label 00000035
        Ld_E70 = 1;
    } // Label 00000033
    if (Ib_232 == false && _Period == 1)
    { // Goto_00000037
        Lb_E2B = false;
    } // Label 00000037
    if ((Ld_E70 == 1))
    { // Goto_0000003A
        Ld_E80 = (Id_98 * Id_98);
        Ld_E78 = (Ld_E80 * Id_98);
        Ld_58 = -Ld_E78;
        Ld_50 = ((Ld_E80 + Ld_E78) * 3);
        Ld_48 = ((((Ld_E80 * 2) + Id_98) + Ld_E78) * -3);
        Gd_13 = (((Id_98 * 3) + 1) + Ld_E78);
        Ld_40 = ((Ld_E80 * 3) + Gd_13);
        Ld_EA8 = Ii_14;
        if ((Ld_EA8 < 1))
        { // Goto_0000003C
            Ld_EA8 = 1;
        } // Label 0000003C
        Ld_EA8 = (((Ld_EA8 - 1) / 2) + 1);
        Ld_EA0 = (2.0 / (Ld_EA8 + 1));
        Ld_E98 = (1.0 - Ld_EA0);
        Ld_EA8 = Ii_18;
        if ((Ld_EA8 < 1))
        { // Goto_0000003F
            Ld_EA8 = 1;
        } // Label 0000003F
        Ld_EA8 = (((Ld_EA8 - 1) / 2) + 1);
        Ld_E90 = (2.0 / (Ld_EA8 + 1));
        Ld_E88 = (1.0 - Ld_E90);
        Gi_13 = Ii_88 - 1;
        Id_A0[Gi_13] = 0;
        Ld_ED8 = 0;
        Ld_ED0 = 0;
        Ld_EC8 = 0;
        Ld_EC0 = 0;
        Ld_EB8 = 0;
        Ld_EB0 = 0;
        Gi_14 = Ii_88 - 1;
        Id_13C[Gi_14] = 0;
        Ld_38 = 0;
        Ld_30 = 0;
        Ld_28 = 0;
        Ld_20 = 0;
        Ld_18 = 0;
        Ld_10 = 0;
        Gi_15 = Ii_88 - 2;
        Ld_E68 = Gi_15;
        Ld_E70 = 0;
    } // Label 0000003A
    Li_BC = Ld_E68;
    if (Li_BC >= 0)
    { // Goto_00000046
        do
        { // Label 00000048
            if (Ii_8C == 1)
            { // Goto_0000004D
                Gd_16 = (Ld_EA0 * Open[Li_BC]);
                Gd_16 = ((Ld_E98 * Ld_ED8) + Gd_16);
                Ld_08 = (Gd_16 + Ii_C);
            } // Goto_0000004B
            else
            { // Label 0000004D
                Gd_17 = (Ld_EA0 * Close[Li_BC]);
                Ld_08 = ((Ld_E98 * Ld_ED8) + Gd_17);
            } // Label 0000004B
            Gd_17 = (Ld_EA0 * Ld_08);
            Ld_00 = ((Ld_E98 * Ld_ED0) + Gd_17);
            Gd_17 = (Ld_00 * Ld_EA0);
            Ld_EF8 = ((Ld_E98 * Ld_EC8) + Gd_17);
            Gd_17 = (Ld_EF8 * Ld_EA0);
            Ld_EF0 = ((Ld_E98 * Ld_EC0) + Gd_17);
            Gd_17 = (Ld_EF0 * Ld_EA0);
            Ld_EE8 = ((Ld_E98 * Ld_EB8) + Gd_17);
            Gd_17 = (Ld_EE8 * Ld_EA0);
            Ld_EE0 = ((Ld_E98 * Ld_EB0) + Gd_17);
            Gd_17 = (Ld_EE0 * Ld_58);
            Gd_17 = ((Ld_50 * Ld_EE8) + Gd_17);
            Gd_17 = ((Ld_48 * Ld_EF0) + Gd_17);
            Ld_B0 = ((Ld_40 * Ld_EF8) + Gd_17);
            if ((Ld_E58 == 1 && Li_BC == 1) ||
                Ld_E58 == -1)
            {
                Ld_ED8 = Ld_08;
                Ld_ED0 = Ld_00;
                Ld_EC8 = Ld_EF8;
                Ld_EC0 = Ld_EF0;
                Ld_EB8 = Ld_EE8;
                Ld_EB0 = Ld_EE0;
            } // Label 00000052
            Gd_18 = (Ld_E90 * Close[Li_BC]);
            Ld_88 = ((Ld_E88 * Ld_38) + Gd_18);
            Gd_18 = (Ld_88 * Ld_E90);
            Ld_80 = ((Ld_E88 * Ld_30) + Gd_18);
            Gd_18 = (Ld_80 * Ld_E90);
            Ld_78 = ((Ld_E88 * Ld_28) + Gd_18);
            Gd_18 = (Ld_78 * Ld_E90);
            Ld_70 = ((Ld_E88 * Ld_20) + Gd_18);
            Gd_18 = (Ld_70 * Ld_E90);
            Ld_68 = ((Ld_E88 * Ld_18) + Gd_18);
            Gd_18 = (Ld_68 * Ld_E90);
            Ld_60 = ((Ld_E88 * Ld_10) + Gd_18);
            Gd_18 = (Ld_60 * Ld_58);
            Gd_18 = ((Ld_50 * Ld_68) + Gd_18);
            Gd_18 = ((Ld_48 * Ld_70) + Gd_18);
            Ld_98 = ((Ld_40 * Ld_78) + Gd_18);
            if (Ii_90 == 1)
            { // Goto_0000005A
                Gd_18 = (Ld_B0 - Ld_A8);
                Gd_18 = (Gd_18 / Ld_A8);
                Gd_19 = (Ld_98 - Ld_90);
                Gd_19 = ((Gd_19 / Ld_90) + Gd_18);
                Id_A0[Li_BC] = Gd_19;
                Gd_19 = (Ld_B0 - Ld_A8);
                Gd_19 = (Gd_19 / Ld_A8);
                Id_13C[Li_BC] = Gd_19;
                Id_1E0 = Id_13C[Li_BC];
            } // Goto_00000064
            else
            { // Label 0000005A
                if ((Ld_90 > 0) && (Ld_A8 > 0))
                { // Goto_00000064
                    Gd_1C = (Ld_98 - Ld_90);
                    Gd_1C = (Gd_1C / Ld_90);
                    Id_A0[Li_BC] = Gd_1C;
                    Gd_1C = (Ld_B0 - Ld_A8);
                    Gd_1C = (Gd_1C / Ld_A8);
                    Id_13C[Li_BC] = Gd_1C;
                    Id_1E0 = Id_13C[Li_BC];
                }
            } // Label 00000064
            Id_D4[Li_BC] = 2147483647;
            Id_108[Li_BC] = 2147483647;
            Gi_21 = Li_BC + 1;
            if ((Id_A0[Gi_21] < Id_A0[Li_BC]))
            { // Goto_00000075
                Gi_23 = Li_BC + 1;
                if ((Id_D4[Gi_23] == 2147483647))
                { // Goto_0000007A
                    Gi_24 = Li_BC + 1;
                    Gi_25 = Li_BC + 1;
                    Id_D4[Gi_25] = Id_A0[Gi_24];
                } // Label 0000007A
                Id_D4[Li_BC] = Id_A0[Li_BC];
            } // Goto_00000086
            else
            { // Label 00000075
                Gi_28 = Li_BC + 1;
                if ((Id_A0[Gi_28] > Id_A0[Li_BC]))
                { // Goto_00000086
                    Gi_2A = Li_BC + 1;
                    if ((Id_108[Gi_2A] == 2147483647))
                    { // Goto_0000008C
                        Gi_2B = Li_BC + 1;
                        Gi_2C = Li_BC + 1;
                        Id_108[Gi_2C] = Id_A0[Gi_2B];
                    } // Label 0000008C
                    Id_108[Li_BC] = Id_A0[Li_BC];
                }
            } // Label 00000086
            Id_170[Li_BC] = 2147483647;
            Id_1A4[Li_BC] = 2147483647;
            Gi_31 = Li_BC + 1;
            if ((Id_13C[Gi_31] < Id_13C[Li_BC]))
            { // Goto_0000009E
                Gi_33 = Li_BC + 1;
                if ((Id_170[Gi_33] == 2147483647))
                { // Goto_000000A3
                    Gi_34 = Li_BC + 1;
                    Gi_35 = Li_BC + 1;
                    Id_170[Gi_35] = Id_13C[Gi_34];
                } // Label 000000A3
                Id_170[Li_BC] = Id_13C[Li_BC];
            } // Goto_000000AF
            else
            { // Label 0000009E
                Gi_38 = Li_BC + 1;
                if ((Id_13C[Gi_38] > Id_13C[Li_BC]))
                { // Goto_000000AF
                    Gi_3A = Li_BC + 1;
                    if ((Id_1A4[Gi_3A] == 2147483647))
                    { // Goto_000000B5
                        Gi_3B = Li_BC + 1;
                        Gi_3C = Li_BC + 1;
                        Id_1A4[Gi_3C] = Id_13C[Gi_3B];
                    } // Label 000000B5
                    Id_1A4[Li_BC] = Id_13C[Li_BC];
                }
            } // Label 000000AF
            if ((Ld_E58 == 1 && Li_BC == 1) ||
                Ld_E58 == -1)
            {
                Ld_A8 = Ld_B0;
                Ld_90 = Ld_98;
                Ld_38 = Ld_88;
                Ld_30 = Ld_80;
                Ld_28 = Ld_78;
                Ld_20 = Ld_70;
                Ld_18 = Ld_68;
                Ld_10 = Ld_60;
            } // Label 000000C1
            if (Li_BC <= Ii_22C && Lb_E2B)
            { // Goto_000000C5
                Gi_3F = Li_BC + 2;
                CatchBullishDivergence(Gi_3F);
                CatchBearishDivergence(Gi_3F);
            } // Label 000000C5
            Li_BC = Li_BC - 1;
        } while (Li_BC >= 0); // Goto_00000048
    } // Label 00000046
    Id_1D8 = Id_1E0;
    if (Ib_5D == false) return 0; // Goto_00000000
    if ((Id_13C[1] > Id_A0[1]) && (Id_170[2] != 2147483647) && (Id_170[1] == 2147483647) && Ii_1E8 < Bars)
    {
        if (Ib_70)
        { // Goto_000000D8
            Ls_D0 = "";
        } // Label 000000D8
        str_3 = (string)Time[0];
        str_3 = "Alarm_Crossing_Label" + str_3;
        if (ObjectFind(str_3) == -1)
        { // Goto_000000DA
            ObjectDelete("Alarm_Crossing_Label");
        } // Label 000000DA
        str_4 = Is_1F0 + " ";
        str_4 = str_4 + _Symbol;
        str_4 = str_4 + " ";
        str_4 = str_4 + TF2Str(_Period);
        str_4 = str_4 + " EXIT ALARM @ ";
        str_4 = str_4 + TimeToString(TimeCurrent(), 3);
        Ls_E0 = str_4;
        str_5 = str_4;
        if (Ib_58)
        { // Goto_000000DF
            Alert(str_5);
        } // Label 000000DF
        if (Ib_5A)
        { // Goto_000000E1
            SendMail(str_4, str_5);
        } // Label 000000E1
        Ii_1E8 = Bars;
        if (Ib_59)
        {
            PlaySound("analyze exit.wav");
        }
    }
    else if ((Id_13C[1] < Id_A0[1]) && (Id_1A4[2] != 2147483647) && (Id_1A4[1] == 2147483647) && Ii_1E8 < Bars)
    { // Goto_00000101
        if (Ib_70)
        { // Goto_000000F2
            Ls_D0 = "";
        } // Label 000000F2
        str_6 = (string)Time[0];
        str_6 = "Alarm_Crossing_Label" + str_6;
        if (ObjectFind(str_6) == -1 && Ib_70)
        { // Goto_000000F8
            ObjectDelete("Alarm_Crossing_Label");
            str_7 = (string)Time[0];
            str_7 = "Alarm_Crossing_Label" + str_7;
            ObjectCreate(0, str_7, OBJ_LABEL, Ii_6C, 0, 0, 0, 0, 0, 0);
        } // Label 000000F8
        str_8 = Is_1F0 + " ";
        str_8 = str_8 + _Symbol;
        str_8 = str_8 + " ";
        str_8 = str_8 + TF2Str(_Period);
        str_8 = str_8 + " EXIT ALARM @ ";
        str_8 = str_8 + TimeToString(TimeCurrent(), 3);
        Ls_E0 = str_8;
        str_9 = str_8;
        if (Ib_58)
        { // Goto_000000FD
            Alert(str_9);
        } // Label 000000FD
        if (Ib_5A)
        { // Goto_000000FF
            SendMail(str_8, str_9);
        } // Label 000000FF
        Ii_1E8 = Bars;
        if (Ib_59)
        { // Goto_00000101
            PlaySound("analyze exit.wav");
        }
    } // Label 00000101
    str_A = (string)Time[1];
    str_A = "Alarm_Crossing_Label" + str_A;
    if (ObjectFind(str_A) == -1) return 0; // Goto_00000000
    str_B = (string)Time[1];
    str_B = "Alarm_Crossing_Label" + str_B;
    ObjectDelete(str_B);
    // Label 00000103
    Li_C = 0;
    // Label 00000004
    return Li_C;
}

int deinit()
{
    string str_0;
    string str_1;
    int Li_C;

    Li_C = 0;
    Gi_0 = 0;
    str_0 = "Trix_";
    Gi_1 = ObjectsTotal(-1) - 1;
    Gi_0 = Gi_1;
    if (Gi_1 >= 0)
    { // Goto_0000010B
        do
        { // Label 0000010D
            str_1 = ObjectName(Gi_0);
            if (StringFind(str_1, str_0, 0) > -1)
            { // Goto_00000110
                ObjectDelete(str_1);
            } // Label 00000110
            Gi_0 = Gi_0 - 1;
        } while (Gi_0 >= 0); // Goto_0000010D
    } // Label 0000010B
    Comment("");
    Li_C = 0;
    return 0;
}

string TF2Str(int FuncArg_Integer_00000000)
{
    string str_0;

    if (FuncArg_Integer_00000000 < 1) return _Period; // Goto_00000000
    if (FuncArg_Integer_00000000 > 43200) return _Period; // Goto_00000000
    if (FuncArg_Integer_00000000 == 1) return "M1";
    if (FuncArg_Integer_00000000 == 5) return "M5";
    if (FuncArg_Integer_00000000 == 15) return "M15";
    if (FuncArg_Integer_00000000 == 30) return "M30";
    if (FuncArg_Integer_00000000 == 60) return "H1";
    if (FuncArg_Integer_00000000 == 240) return "H4";
    if (FuncArg_Integer_00000000 == 1440) return "D1";
    if (FuncArg_Integer_00000000 == 10080) return "W1";
    if (FuncArg_Integer_00000000 == 43200) return "MN";
    return _Period;
}

void CatchBullishDivergence(int FuncArg_Integer_00000000)
{
    string str_0;
    string str_1;
    string str_2;
    string str_3;
    string str_4;
    int Li_C;
    int Li_8;

    Li_C = 0;
    Li_8 = 0;
    Gi_0 = 0;
    Gi_1 = 0;
    Gi_2 = 0;
    Gi_3 = 0;
    Gi_4 = 0;
    Gi_5 = 0;
    Gi_6 = 0;
    Gd_7 = 0;
    Gd_8 = 0;
    Gi_9 = 0;
    Gd_A = 0;
    Gi_B = 0;
    Gi_C = 0;
    Gd_D = 0;
    Gd_E = 0;
    Gi_F = 0;
    Gd_10 = 0;
    Gi_11 = 0;
    Gi_12 = 0;
    Gi_13 = 0;
    Gd_14 = 0;
    Gd_15 = 0;
    Gi_16 = 0;
    Gd_17 = 0;
    Gi_18 = 0;
    Gi_19 = 0;
    Gd_1A = 0;
    Gd_1B = 0;
    Gi_1C = 0;
    Gd_1D = 0;
    Gi_1E = 0;
    Gi_1F = 0;
    Li_C = 0;
    Li_8 = 0;
    if (Id_13C[FuncArg_Integer_00000000] <= Id_13C[FuncArg_Integer_00000000 + 1] &&
        Id_13C[FuncArg_Integer_00000000] < Id_13C[FuncArg_Integer_00000000 + 2] &&
        Id_13C[FuncArg_Integer_00000000] < Id_13C[FuncArg_Integer_00000000 - 1])
    {
        Gi_0 = 1;
    }
    else
    {
        Gi_0 = 0;
    } // Label 00000133
    if (Gi_0 == 0) return; // Goto_00000000
    Li_C = FuncArg_Integer_00000000;
    Gi_3 = FuncArg_Integer_00000000 + 5;
    Gi_2 = -1;
    if (Gi_3 < Bars)
    {
        do
        { // Label 00000147
            if (Id_A0[Gi_3] <= Id_A0[Gi_3 + 1] &&
                Id_A0[Gi_3] <= Id_A0[Gi_3 + 2] &&
                Id_A0[Gi_3] <= Id_A0[Gi_3 - 1] &&
                Id_A0[Gi_3] <= Id_A0[Gi_3 - 2])
            {
                Gi_4 = Gi_3;
                if (Gi_3 < Bars)
                {
                    do
                    { // Label 00000161
                        if (Id_13C[Gi_4] <= Id_13C[Gi_4 + 1] &&
                            Id_13C[Gi_4] < Id_13C[Gi_4 + 2] &&
                            Id_13C[Gi_4] <= Id_13C[Gi_4 - 1] &&
                            Id_13C[Gi_4] < Id_13C[Gi_4 - 2])
                        {
                            Gi_2 = Gi_4;
                            break;
                        } // Label 00000164
                        Gi_4 = Gi_4 + 1;
                    } while (Gi_4 < Bars); // Goto_00000161

                    if (Gi_2 != -1) break;
                }
            } // Label 0000015F
            Gi_3 = Gi_3 + 1;
        } while (Gi_3 < Bars); // Goto_00000147
    } // Label 00000145
    // Label 00000144
    Li_8 = Gi_2;
    if ((Id_13C[Li_C] > Id_13C[Li_8]) && (Low[Li_C] < Low[Li_8]))
    { // Goto_0000019E
        Gd_3B = (Id_13C[Li_C] - 0.0001);
        Id_354[Li_C] = Gd_3B;
        Gi_3B = Ib_230;
        if (Gi_3B == 1)
        { // Goto_00000188
            Gi_9 = BullishDivergenceColor;
            Gi_6 = Time[Li_8];
            Gi_5 = Time[Li_C];
            str_1 = "Tv4Divergence_# " + DoubleToString(Gi_5, 0);
            str_0 = str_1;
            ObjectDelete(str_0);
            ObjectCreate(0, str_0, OBJ_TREND, 0, Gi_5, Low[Li_C], Gi_6, Low[Li_8], 0, 0);
            ObjectSet(str_0, OBJPROP_RAY, 0);
            ObjectSet(str_0, OBJPROP_COLOR, Gi_9);
            ObjectSet(str_0, OBJPROP_STYLE, 0);
        } // Label 00000188
        Gi_41 = Ib_231;
        if (Gi_41 == 1)
        { // Goto_0000019E
            Gi_F = BullishDivergenceColor;
            Gi_C = Time[Li_8];
            Gi_B = Time[Li_C];
            Gi_11 = WindowFind(Is_200);
            if (Gi_11 >= 0)
            { // Goto_0000019E
                str_2 = "Tv4Divergence$# " + DoubleToString(Gi_B, 0);
                str_1 = str_2;
                ObjectDelete(str_1);
                ObjectCreate(0, str_1, OBJ_TREND, Gi_11, Gi_B, Id_13C[Li_C], Gi_C, Id_13C[Li_8], 0, 0);
                ObjectSet(str_1, OBJPROP_RAY, 0);
                ObjectSet(str_1, OBJPROP_COLOR, Gi_F);
                ObjectSet(str_1, OBJPROP_STYLE, 0);
            }
        }
    } // Label 0000019E
    if ((Id_13C[Li_C] >= Id_13C[Li_8])) return; // Goto_00000000
    if ((Low[Li_C] <= Low[Li_8])) return; // Goto_00000000
    Gd_4B = (Id_13C[Li_C] - 0.0001);
    Id_354[Li_C] = Gd_4B;
    Gi_4B = Ib_230;
    if (Gi_4B == 1)
    { // Goto_000001B1
        Gi_16 = BullishDivergenceColor;
        Gi_13 = Time[Li_8];
        Gi_12 = Time[Li_C];
        str_3 = "Tv4Divergence_# " + DoubleToString(Gi_12, 0);
        str_2 = str_3;
        ObjectDelete(str_2);
        ObjectCreate(0, str_2, OBJ_TREND, 0, Gi_12, Low[Li_C], Gi_13, Low[Li_8], 0, 0);
        ObjectSet(str_2, OBJPROP_RAY, 0);
        ObjectSet(str_2, OBJPROP_COLOR, Gi_16);
        ObjectSet(str_2, OBJPROP_STYLE, 2);
    } // Label 000001B1
    Gi_51 = Ib_231;
    if (Gi_51 == 1)
    { // Goto_000001C7
        Gi_1C = BullishDivergenceColor;
        Gi_19 = Time[Li_8];
        Gi_18 = Time[Li_C];
        Gi_1E = WindowFind(Is_200);
        if (Gi_1E >= 0)
        { // Goto_000001C7
            str_4 = "Tv4Divergence$# " + DoubleToString(Gi_18, 0);
            str_3 = str_4;
            ObjectDelete(str_3);
            ObjectCreate(0, str_3, OBJ_TREND, Gi_1E, Gi_18, Id_13C[Li_C], Gi_19, Id_13C[Li_8], 0, 0);
            ObjectSet(str_3, OBJPROP_RAY, 0);
            ObjectSet(str_3, OBJPROP_COLOR, Gi_1C);
            ObjectSet(str_3, OBJPROP_STYLE, 2);
        }
    } // Label 000001C7
    Gi_56 = EnableAlerts;
    if (Gi_56 != 1) return; // Goto_00000000
    Gi_56 = Ib_2F4;
    if (Gi_56 != 1) return; // Goto_00000000
    Gi_1F = Li_C;
    str_4 = Is_328;
    if (Li_C > 2) return; // Goto_00000000
    if (Time[Li_C] == Il_218) return; // Goto_00000000
    Il_218 = Time[Gi_1F];
    PlaySound(str_4);
    // Label 000001CB
}

void CatchBearishDivergence(int FuncArg_Integer_00000000)
{
    string str_0;
    string str_1;
    string str_2;
    string str_3;
    string str_4;
    string str_5;
    int Li_C;
    int Li_8;

    Li_C = 0;
    Li_8 = 0;
    Gi_0 = 0;
    Gi_1 = 0;
    Gi_2 = 0;
    Gi_3 = 0;
    Gi_4 = 0;
    Gi_5 = 0;
    Gi_6 = 0;
    Gd_7 = 0;
    Gd_8 = 0;
    Gi_9 = 0;
    Gd_A = 0;
    Gi_B = 0;
    Gi_C = 0;
    Gd_D = 0;
    Gd_E = 0;
    Gi_F = 0;
    Gd_10 = 0;
    Gi_11 = 0;
    Gi_12 = 0;
    Gi_13 = 0;
    Gi_14 = 0;
    Gd_15 = 0;
    Gd_16 = 0;
    Gi_17 = 0;
    Gd_18 = 0;
    Gi_19 = 0;
    Gi_1A = 0;
    Gd_1B = 0;
    Gd_1C = 0;
    Gi_1D = 0;
    Gd_1E = 0;
    Gi_1F = 0;
    Gi_20 = 0;
    Li_C = 0;
    Li_8 = 0;
    Gi_1 = FuncArg_Integer_00000000;
    if (Id_13C[FuncArg_Integer_00000000] >= Id_13C[Gi_1 + 1] &&
        Id_13C[Gi_1] > Id_13C[Gi_1 + 2] &&
        Id_13C[Gi_1] > Id_13C[Gi_1 - 1])
    {
        Gi_0 = 1;
    }
    else
    {
        Gi_0 = 0;
    } // Label 000001D9
    if (Gi_0 == 0) return; // Goto_00000000
    Li_C = FuncArg_Integer_00000000;
    Gi_27 = FuncArg_Integer_00000000 + 5;
    Gi_3 = Gi_27;
    Gi_2 = -1;
    if (Gi_27 < Bars)
    {
        do
        { // Label 000001ED
            if (Id_A0[Gi_3] >= Id_A0[Gi_3 + 1] &&
                Id_A0[Gi_3] >= Id_A0[Gi_3 + 2] &&
                Id_A0[Gi_3] >= Id_A0[Gi_3 - 1] &&
                Id_A0[Gi_3] >= Id_A0[Gi_3 - 2])
            {
                Gi_4 = Gi_3;
                if (Gi_3 < Bars)
                {
                    do
                    { // Label 00000207
                        if (Id_13C[Gi_4] >= Id_13C[Gi_4 + 1] &&
                            Id_13C[Gi_4] > Id_13C[Gi_4 + 2] &&
                            Id_13C[Gi_4] >= Id_13C[Gi_4 - 1] &&
                            Id_13C[Gi_4] > Id_13C[Gi_4 - 2])
                        {
                            Gi_2 = Gi_4;
                            break;
                        } // Label 0000020A
                        Gi_4 = Gi_4 + 1;
                    } while (Gi_4 < Bars); // Goto_00000207

                    if (Gi_2 != -1) break;
                }
            } // Label 00000205
            Gi_3 = Gi_3 + 1;
        } while (Gi_3 < Bars); // Goto_000001ED
    } // Label 000001EB
    // Label 000001EA
    Li_8 = Gi_2;
    if ((Id_13C[Li_C] < Id_13C[Li_8]) && (High[Li_C] > High[Li_8]))
    { // Goto_0000024B
        Gd_3C = (Id_13C[Li_C] + 0.0001);
        Id_388[Li_C] = Gd_3C;
        Gi_3C = Ib_230;
        if (Gi_3C == 1)
        { // Goto_0000022E
            Gi_9 = BearishDivergenceColor;
            Gi_6 = Time[Li_8];
            Gi_5 = Time[Li_C];
            str_1 = "Tv4Divergence_# " + DoubleToString(Gi_5, 0);
            str_0 = str_1;
            ObjectDelete(str_0);
            ObjectCreate(0, str_0, OBJ_TREND, 0, Gi_5, High[Li_C], Gi_6, High[Li_8], 0, 0);
            ObjectSet(str_0, OBJPROP_RAY, 0);
            ObjectSet(str_0, OBJPROP_COLOR, Gi_9);
            ObjectSet(str_0, OBJPROP_STYLE, 0);
        } // Label 0000022E
        Gi_42 = Ib_231;
        if (Gi_42 == 1)
        { // Goto_00000244
            Gi_F = BearishDivergenceColor;
            Gi_C = Time[Li_8];
            Gi_B = Time[Li_C];
            Gi_11 = WindowFind(Is_200);
            if (Gi_11 >= 0)
            { // Goto_00000244
                str_2 = "Tv4Divergence$# " + DoubleToString(Gi_B, 0);
                str_1 = str_2;
                ObjectDelete(str_1);
                ObjectCreate(0, str_1, OBJ_TREND, Gi_11, Gi_B, Id_13C[Li_C], Gi_C, Id_13C[Li_8], 0, 0);
                ObjectSet(str_1, OBJPROP_RAY, 0);
                ObjectSet(str_1, OBJPROP_COLOR, Gi_F);
                ObjectSet(str_1, OBJPROP_STYLE, 0);
            }
        } // Label 00000244
        Gi_47 = EnableAlerts;
        if (Gi_47 == 1)
        { // Goto_0000024B
            Gi_47 = Ib_2F4;
            if (Gi_47 == 1)
            { // Goto_0000024B
                Gi_12 = Li_C;
                str_2 = Is_338;
                if (Li_C <= 2 && Time[Li_C] != Il_218)
                { // Goto_0000024B
                    Il_218 = Time[Gi_12];
                    PlaySound(str_2);
                }
            }
        }
    } // Label 0000024B
    if ((Id_13C[Li_C] <= Id_13C[Li_8])) return; // Goto_00000000
    if ((High[Li_C] >= High[Li_8])) return; // Goto_00000000
    Gd_4E = (Id_13C[Li_C] + 0.0001);
    Id_388[Li_C] = Gd_4E;
    Gi_4E = Ib_230;
    if (Gi_4E == 1)
    { // Goto_00000261
        Gi_17 = BearishDivergenceColor;
        Gi_14 = Time[Li_8];
        Gi_13 = Time[Li_C];
        str_4 = "Tv4Divergence_# " + DoubleToString(Gi_13, 0);
        str_3 = str_4;
        ObjectDelete(str_3);
        ObjectCreate(0, str_3, OBJ_TREND, 0, Gi_13, High[Li_C], Gi_14, High[Li_8], 0, 0);
        ObjectSet(str_3, OBJPROP_RAY, 0);
        ObjectSet(str_3, OBJPROP_COLOR, Gi_17);
        ObjectSet(str_3, OBJPROP_STYLE, 2);
    } // Label 00000261
    Gi_54 = Ib_231;
    if (Gi_54 == 1)
    { // Goto_00000277
        Gi_1D = BearishDivergenceColor;
        Gi_1A = Time[Li_8];
        Gi_19 = Time[Li_C];
        Gi_1F = WindowFind(Is_200);
        if (Gi_1F >= 0)
        { // Goto_00000277
            str_5 = "Tv4Divergence$# " + DoubleToString(Gi_19, 0);
            str_4 = str_5;
            ObjectDelete(str_4);
            ObjectCreate(0, str_4, OBJ_TREND, Gi_1F, Gi_19, Id_13C[Li_C], Gi_1A, Id_13C[Li_8], 0, 0);
            ObjectSet(str_4, OBJPROP_RAY, 0);
            ObjectSet(str_4, OBJPROP_COLOR, Gi_1D);
            ObjectSet(str_4, OBJPROP_STYLE, 2);
        }
    } // Label 00000277
    Gi_59 = EnableAlerts;
    if (Gi_59 != 1) return; // Goto_00000000
    Gi_59 = Ib_2F4;
    if (Gi_59 != 1) return; // Goto_00000000
    Gi_20 = Li_C;
    str_5 = Is_348;
    if (Li_C > 2) return; // Goto_00000000
    if (Time[Li_C] == Il_218) return; // Goto_00000000
    Il_218 = Time[Gi_20];
    PlaySound(str_5);
    // Label 0000027B
}

bool IndicatorInit()
{
    string str_0;
    string str_1;
    string str_2;
    bool Lb_F;
    int Li_8;

    Lb_F = false;
    Li_8 = 0;
    Gi_0 = 0;
    Gi_1 = 0;
    Gi_2 = 0;
    if (Ib_10 != true)
    { // Goto_0000032C
        if (AccountNumber() == 0) return Ib_10; // Goto_00000000

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
    } // Label 0000032C
    Ib_11 = false;
    // Label 0000032A
    Lb_F = Ib_10;
    // Label 00000329
    return Lb_F;
}

int SymbolTick3(int symbolHash)
{
    return symbolHash * 11;
}