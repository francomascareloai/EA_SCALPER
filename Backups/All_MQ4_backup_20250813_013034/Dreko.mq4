#property copyright "HiLLzX@Gmail.com";
#property link "HiLLzX@Gmail.com";
#property version "2.5";
#property strict

enum LicenseEnum
{
    Platinum = 1, // Platinum
    One_Month_Trial = 0 // One_Month_Trial
};

enum RiskEnum
{
    Level1_890 = 7, // Level1_890
    Level2_530 = 6, // Level2_530
    Level3_420 = 5, // Level3_420
    Level4_330 = 4, // Level4_330
    Level5_290 = 3, // Level5_290
    Level6_250 = 2, // Level6_250
    Level7_210 = 1, // Level7_210
    Level8_185 = 0 // Level8_185
};

extern bool ShowTotalWins;
extern LicenseEnum License = One_Month_Trial;
extern string Password; // Password
extern bool WithdrawMode;
extern bool OverrideRisk;
extern int OverrideRiskDigit = 150;
extern RiskEnum RiskScale = Level8_185;
extern bool Money_Management = true;
extern double LotSize = 0.01;
extern int Slippage = 5; // Maximum Slippage (in points / 5 Digit)
extern int MaxSpread = 10; // Maximum Spread (in points / 5 Digit)
extern int StopLoss;

string Is_0 = "2.5";
string Is_10 = "Total Buy";
string Is_20 = "Total Sell";
string Is_30 = "Profit";
string Is_40 = "Profit";
string Is_50 = "Loss";
string Is_60 = "Loss";
string Is_70 = "Money";
int Ii_7C = 10;
int Ii_80 = 130;
double Id_B8[10];
double Id_13C[10];
string Is_1C0[10];
int Ii_23C = 150;
int Ii_250 = 300;
int Ii_254 = 30;
int Ii_258 = 4;
int Ii_25C = 80;
int Ii_264 = 10;
int Ii_268 = 10;

int Gi_0;
int Gi_1;
datetime Ii_278;
long Gl_0;
double Id_280;
bool Ib_238;
int Ii_260;
int Ii_288;
int Gi_2;
int Gi_3;
int Ii_240;
int Ii_244;
int Ii_248;
int Ii_24C;
double Id_270;
long Gl_4;
int Gi_4;
int Gi_5;
long Gl_5;
int Gi_6;
long Gl_6;
bool Gb_0;
double Gd_4;
string Gs_6;
double Gd_5;
int Gi_A;
double Gd_A;
int Gi_B;
double Gd_B;
int Gi_7;
double Gd_7;
int Gi_8;
int Gi_9;
string Gs_9;
double Gd_8;
bool Gb_1;
double Gd_0;
string Gs_1;
double Gd_2;
double Gd_3;
bool Gb_6;
int Gi_D;
bool Gb_E;
double Gd_D;
double Gd_E;
int Gi_E;
string Gs_7;
double Gd_9;
bool Gb_C;
int Gi_C;
long Gl_1;
double Gd_6;
double Gd_C;
bool Gb_2;
bool Gb_3;

int OnInit()
{
    string str_0;
    string str_1;
    int Li_C;

    Gi_0 = ObjectsTotal(-1) - 1;
    Gi_1 = Gi_0;
    if (Gi_0 > -1)
    {
        do
        {
            str_0 = ObjectName(Gi_1);
            if (StringFind(str_0, "TxtConqueror", 0) >= 0)
            {
                str_1 = ObjectName(Gi_1);
                ObjectDelete(str_1);
            }
            Gi_1 = Gi_1 - 1;
        } while (Gi_1 > -1);
    }
    Ii_278 = Time[0];
    Id_280 = MarketInfo(_Symbol, MODE_MINLOT);
    Li_C = 0;
    return 0;
}

void OnTick()
{
    string str_0;
    string str_1;
    string str_2;
/*
    Ib_238 = func_1004();
    if (Ib_238)
    {
        if (License == 0)
        {
            ObjectCreate(0, "TxtConquerorTitle", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
            ObjectSet("TxtConquerorTitle", OBJPROP_CORNER, Ii_260);
            ObjectSet("TxtConquerorTitle", OBJPROP_XDISTANCE, Ii_264);
            Gi_0 = Ii_268 + 10;
            ObjectSet("TxtConquerorTitle", OBJPROP_YDISTANCE, Gi_0);
            str_0 = "HiLLzX Conqueror " + Is_0;
            str_0 = str_0 + " | Valid ";
            str_0 = str_0 + func_1009();
            str_0 = str_0 + ServerAddress();
            ObjectSetText("TxtConquerorTitle", str_0, 14, "Arial", 55295);
        }
        else
        {
            ObjectCreate(0, "TxtConquerorTitle", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
            ObjectSet("TxtConquerorTitle", OBJPROP_CORNER, Ii_260);
            ObjectSet("TxtConquerorTitle", OBJPROP_XDISTANCE, Ii_264);
            Gi_0 = Ii_268 + 10;
            ObjectSet("TxtConquerorTitle", OBJPROP_YDISTANCE, Gi_0);
            str_1 = "HiLLzX Conqueror " + Is_0;
            str_1 = str_1 + " Platinum";
            ObjectSetText("TxtConquerorTitle", str_1, 14, "Arial", 55295);
        }
    }
    else
    {
        ObjectCreate(0, "TxtConquerorTitle", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
        ObjectSet("TxtConquerorTitle", OBJPROP_CORNER, Ii_260);
        ObjectSet("TxtConquerorTitle", OBJPROP_XDISTANCE, Ii_264);
        Gi_0 = Ii_268 + 10;
        ObjectSet("TxtConquerorTitle", OBJPROP_YDISTANCE, Gi_0);
        str_2 = "HiLLzX Conqueror " + Is_0;
        str_2 = str_2 + " | Unlicensed | hillzx@gmail.com";
        ObjectSetText("TxtConquerorTitle", str_2, 14, "Arial", 12695295);
    }
    if (Ib_238 == 0) return;
    */
    if (ShowTotalWins)
    {
        func_1005();
    }
    Ii_288 = (int)MarketInfo(_Symbol, MODE_SPREAD);
    if (Ii_288 > MaxSpread) return;
    if (WithdrawMode != 0) return;
    Gi_0 = 0;
    Gi_1 = OrdersTotal() - 1;
    Gi_2 = Gi_1;
    if (Gi_1 >= 0)
    {
        do
        {
            OrderSelect(Gi_2, 0, 0);
            Gi_1 = OrderType();
            if (OrderSymbol() == _Symbol)
            {
                if (Gi_1 == 1)
                {
                    Gi_3 = Gi_0 + 1;
                    Gi_0 = Gi_3;
                }
                else if (Gi_1 == 0)
                {
                    Gi_3 = Gi_0 + 1;
                    Gi_0 = Gi_3;
                }
            }
            Gi_2 = Gi_2 - 1;
        } while (Gi_2 >= 0);
    }
    if (Gi_0 >= Ii_258) return;
    func_1011();
   
}

void OnDeinit(const int reason)
{
    string str_0;
    string str_1;

    Gi_0 = ObjectsTotal(-1) - 1;
    Gi_1 = Gi_0;
    if (Gi_0 <= -1) return;
    do
    {
        str_0 = ObjectName(Gi_1);
        if (StringFind(str_0, "TxtConqueror", 0) >= 0)
        {
            str_1 = ObjectName(Gi_1);
            ObjectDelete(str_1);
        }
        Gi_1 = Gi_1 - 1;
    } while (Gi_1 > -1);
                                           
}

bool func_1004()
{
    string str_0;
    string str_1;
    string str_2;
    int Li_8;
    string Ls_E8;
    int Li_E4;
    string Ls_D8;
    string Ls_C8;
    string Ls_B8;
    string Ls_A8;
    string Ls_98;
    int Li_94;
    int Li_90;
    string Ls_80;
    bool Lb_F;

    Li_8 = 0;
    if (License == 0)
    {
        str_0 = AccountName();
        Gi_0 = 0;
        Gi_1 = 0;
        Gi_1 = 0;
        Gi_2 = StringLen(str_0);
        if (Gi_2 > 0)
        {
            do
            {
                Gi_2 = StringGetCharacter(str_0, Gi_1);
                Gi_2 = Gi_0 + Gi_2;
                Gi_0 = Gi_2;
                Gi_1 = Gi_1 + 1;
                Gi_2 = StringLen(str_0);
            } while (Gi_1 < Gi_2);
        }
        Gi_2 = Gi_0 - 17;
        Gi_2 = Gi_2 * 373;
        Li_8 = Gi_2 - 1313;
    }
    else
    {
        if (License == 1)
        {
            str_1 = AccountName();
            Gi_2 = 0;
            Gi_3 = 0;
            Gi_3 = 0;
            Gi_4 = StringLen(str_1);
            if (Gi_4 > 0)
            {
                do
                {
                    Gi_4 = StringGetCharacter(str_1, Gi_3);
                    Gi_4 = Gi_2 + Gi_4;
                    Gi_2 = Gi_4;
                    Gi_3 = Gi_3 + 1;
                    Gi_4 = StringLen(str_1);
                } while (Gi_3 < Gi_4);
            }
            Gi_4 = Gi_2 - 17;
            Gi_4 = Gi_4 * 373;
            Li_8 = Gi_4 - 9393;
        }
    }
    Ls_E8 = IntegerToString(Li_8, 0, 32);
    Li_E4 = StringLen(Ls_E8);
    Gi_4 = StringLen(Ls_E8);
    Ls_D8 = StringSubstr(Ls_E8, (Gi_4 - 4), 1);
    Gi_4 = StringLen(Ls_E8);
    Ls_C8 = StringSubstr(Ls_E8, (Gi_4 - 3), 1);
    Gi_4 = StringLen(Ls_E8);
    Ls_B8 = StringSubstr(Ls_E8, (Gi_4 - 2), 1);
    Gi_4 = StringLen(Ls_E8);
    Ls_A8 = StringSubstr(Ls_E8, (Gi_4 - 1), 1);
    str_2 = Ls_D8 + Ls_C8;
    str_2 = str_2 + Ls_B8;
    str_2 = str_2 + Ls_A8;
    str_2 = str_2 + Ls_C8;
    str_2 = str_2 + Ls_A8;
    Ls_98 = str_2;
    Gl_4 = StringToInteger(Ls_98) * 2;
    Li_94 = Gl_4;
    Ls_98 = IntegerToString(Li_94, 0, 32);
    Gl_4 = StringToInteger(Ls_98);
    Gi_5 = Month() * 23;
    Gl_5 = Gi_5;
    Gl_5 = Gl_4 * Gl_5;
    Gi_6 = Year() * 13;
    Gl_6 = Gi_6;
    Gl_6 = Gl_5 + Gl_6;
    Li_90 = Gl_6;
    if (License == 0)
    {
        Ls_80 = IntegerToString(Li_90, 0, 32);
    }
    else
    {
        if (License == 1)
        {
            Ls_80 = IntegerToString((int)Ls_98, 0, 32);
        }
    }
    str_2 = "8267" + Ls_80;
    str_2 = str_2 + "4536";
    Ls_80 = str_2;
    if (Password == str_2) return true;
    Lb_F = false;
    return Lb_F;
   
    Lb_F = true;
   
    return Lb_F;
}

void func_1005()
{
    string str_0;
    string str_1;
    string str_2;
    string str_3;
    string str_4;
    int Li_C;
    int Li_8;
    int Li_4;
    int Li_0;
    int Li_EC;
    string Ls_E0;

    Ii_244 = 0;
    Ii_240 = 0;
    Ii_248 = 0;
    Ii_24C = 0;
    Li_C = HistoryTotal();
    Li_8 = Li_C - 1;
    if (Li_8 >= 0)
    {
        do
        {
            OrderSelect(Li_8, 0, 1);
            Li_4 = OrderType();
            if (Li_4 == 1)
            {
                Ii_240 = Ii_240 + 1;
                if ((OrderProfit() > 0))
                {
                    Ii_248 = Ii_248 + 1;
                }
            }
            else if (Li_4 == 0)
            {
                Ii_244 = Ii_244 + 1;
                if ((OrderProfit() > 0))
                {
                    Ii_24C = Ii_24C + 1;
                }
            }
            Li_8 = Li_8 - 1;
        } while (Li_8 >= 0);
    }
    Gi_0 = HistoryTotal();
    Gi_1 = Ii_7C - 1;
    Gi_2 = Gi_0 - 1;
    Gi_3 = Gi_2;
    Gi_4 = Gi_0 - 10;
    if (Gi_2 >= Gi_4)
    {
        do
        {
            if (Gi_1 < 0) break;
            OrderSelect(Gi_3, 0, 1);
            if (OrderType() == 1)
            {
                Id_B8[Gi_1] = OrderProfit();
                Gi_5 = OrderTicket();
                Is_1C0[Gi_1] = (string)Gi_5;
                Id_13C[Gi_1] = OrderLots();
            }
            else if (OrderType() == 0)
            {
                Id_B8[Gi_1] = OrderProfit();
                Gi_8 = OrderTicket();
                Is_1C0[Gi_1] = (string)Gi_8;
                Id_13C[Gi_1] = OrderLots();
            }
            str_0 = (string)Gi_1;
            str_0 = "Profit " + str_0;
            str_0 = str_0 + " : ";
            str_1 = (string)Id_B8[Gi_1];
            str_0 = str_0 + str_1;
            Print(str_0);
            Gi_1 = Gi_1 - 1;
            Gi_3 = Gi_3 - 1;
            Gi_B = Gi_0 - 10;
        } while (Gi_3 >= Gi_B);
    }
    ObjectCreate(0, "TxtConquerorLine1", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorLine1", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorLine1", OBJPROP_XDISTANCE, Ii_264);
    Gi_B = Ii_268 + 20;
    ObjectSet("TxtConquerorLine1", OBJPROP_YDISTANCE, Gi_B);
    ObjectSetText("TxtConquerorLine1", "-----------------------------------------------------", 14, "Arial", 42495);
    ObjectCreate(0, "TxtConquerorTotalBuy", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorTotalBuy", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorTotalBuy", OBJPROP_XDISTANCE, Ii_264);
    Gi_B = Ii_268 + 40;
    ObjectSet("TxtConquerorTotalBuy", OBJPROP_YDISTANCE, Gi_B);
    str_1 = Is_10 + ": ";
    str_2 = (string)Ii_244;
    str_1 = str_1 + str_2;
    str_1 = str_1 + "  |  ";
    str_1 = str_1 + Is_30;
    str_1 = str_1 + ": ";
    str_2 = (string)Ii_24C;
    str_1 = str_1 + str_2;
    str_1 = str_1 + "  |  ";
    str_1 = str_1 + Is_50;
    str_1 = str_1 + ": ";
    Gi_B = Ii_244 - Ii_24C;
    str_2 = (string)Gi_B;
    str_1 = str_1 + str_2;
    ObjectSetText("TxtConquerorTotalBuy", str_1, 12, "Arial", 65535);
    ObjectCreate(0, "TxtConquerorTotalSell", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorTotalSell", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorTotalSell", OBJPROP_XDISTANCE, Ii_264);
    Gi_B = Ii_268 + 60;
    ObjectSet("TxtConquerorTotalSell", OBJPROP_YDISTANCE, Gi_B);
    str_2 = Is_20 + ": ";
    str_3 = (string)Ii_240;
    str_2 = str_2 + str_3;
    str_2 = str_2 + " |  ";
    str_2 = str_2 + Is_40;
    str_2 = str_2 + ": ";
    str_3 = (string)Ii_248;
    str_2 = str_2 + str_3;
    str_2 = str_2 + "  |  ";
    str_2 = str_2 + Is_60;
    str_2 = str_2 + ": ";
    Gi_B = Ii_240 - Ii_248;
    str_3 = (string)Gi_B;
    str_2 = str_2 + str_3;
    ObjectSetText("TxtConquerorTotalSell", str_2, 12, "Arial", 65535);
    ObjectCreate(0, "TxtConquerorTotalMoney", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorTotalMoney", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorTotalMoney", OBJPROP_XDISTANCE, Ii_264);
    Gi_B = Ii_268 + 80;
    ObjectSet("TxtConquerorTotalMoney", OBJPROP_YDISTANCE, Gi_B);
    str_3 = Is_70 + ": $";
    str_3 = str_3 + DoubleToString(AccountBalance(), 2);
    ObjectSetText("TxtConquerorTotalMoney", str_3, 20, "Verdana", 16776960);
    ObjectCreate(0, "TxtConquerorLine3", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorLine3", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorLine3", OBJPROP_XDISTANCE, Ii_264);
    Gi_B = Ii_268 + 110;
    ObjectSet("TxtConquerorLine3", OBJPROP_YDISTANCE, Gi_B);
    ObjectSetText("TxtConquerorLine3", "-----------------------------------------------------", 14, "Arial", 16776960);
    Li_0 = Ii_240 + Ii_244;
    Li_EC = Ii_248 + Ii_24C;
    if (Li_0 > 0 && Li_EC > 0)
    {
        Gi_B = Li_EC * 100;
        Gi_B = Gi_B / Li_0;
        Ls_E0 = DoubleToString(Gi_B, 2);
        ObjectCreate(0, "TxtConquerorLine4", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
        ObjectSet("TxtConquerorLine4", OBJPROP_CORNER, Ii_260);
        ObjectSet("TxtConquerorLine4", OBJPROP_XDISTANCE, Ii_264);
        Gi_B = Ii_268 + 340;
        ObjectSet("TxtConquerorLine4", OBJPROP_YDISTANCE, Gi_B);
        str_4 = "WIN RATE : " + Ls_E0;
        str_4 = str_4 + "%";
        ObjectSetText("TxtConquerorLine4", str_4, 24, "Arial", 16777215);
    }
    func_1007();
}

void func_1007()
{
    string str_0;
    string str_1;
    string str_2;
    string str_3;
    string str_4;
    string Ls_0;
    int Li_EC;
    int Li_E8;
    int Li_E4;

    Li_EC = 0;
    Li_E8 = Ii_80;
    Li_E4 = Ii_7C - 1;
    if (Li_E4 < 0) return;
    do
    {
        if ((Id_B8[Li_E4] > 0))
        {
            str_0 = "Order:" + Is_1C0[Li_E4];
            str_0 = str_0 + " Lot:";
            str_0 = str_0 + DoubleToString(Id_13C[Li_E4], 2);
            str_0 = str_0 + " +$";
            str_0 = str_0 + DoubleToString(Id_B8[Li_E4], 2);
            Ls_0 = str_0;
            Gd_5 = Id_B8[Li_E4];
            if ((Gd_5 > 0))
            {
                Gi_6 = 65280;
            }
            else
            {
                Gi_6 = 13353215;
            }
            Li_EC = Gi_6;
        }
        else
        {
            str_0 = "Order:" + Is_1C0[Li_E4];
            str_0 = str_0 + " Lot:";
            str_0 = str_0 + DoubleToString(Id_13C[Li_E4], 2);
            str_0 = str_0 + " -$";
            str_0 = str_0 + DoubleToString(Id_B8[Li_E4], 2);
            Ls_0 = str_0;
            Gd_B = Id_B8[Li_E4];
            if ((Gd_B > 0))
            {
                Gi_C = 65280;
            }
            else
            {
                Gi_C = 13353215;
            }
            Li_EC = Gi_C;
        }
        if ((Id_B8[Li_E4] != 0))
        {
            str_0 = (string)Li_E4;
            str_0 = "TxtConquerorProfit_" + str_0;
            ObjectCreate(0, str_0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
            str_1 = (string)Li_E4;
            str_1 = "TxtConquerorProfit_" + str_1;
            ObjectSet(str_1, OBJPROP_CORNER, Ii_260);
            str_2 = (string)Li_E4;
            str_2 = "TxtConquerorProfit_" + str_2;
            ObjectSet(str_2, OBJPROP_XDISTANCE, Ii_264);
            Gi_E = Li_E8 + Ii_268;
            str_3 = (string)Li_E4;
            str_3 = "TxtConquerorProfit_" + str_3;
            ObjectSet(str_3, OBJPROP_YDISTANCE, Gi_E);
            str_4 = (string)Li_E4;
            str_4 = "TxtConquerorProfit_" + str_4;
            ObjectSetText(str_4, Ls_0, 14, "Arial", Li_EC);
            Li_E8 = Li_E8 + 20;
        }
        Li_E4 = Li_E4 - 1;
    } while (Li_E4 >= 0);
                                          
}

string func_1009()
{
    string str_0;
    string str_1;

    if (Month() == 1)
    {
        str_0 = "January " + IntegerToString(Year(), 0, 32);
        return str_0;
    }
    if (Month() == 2)
    {
        str_1 = "February " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 3)
    {
        str_1 = "March " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 4)
    {
        str_1 = "April " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 5)
    {
        str_1 = "May " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 6)
    {
        str_1 = "June " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 7)
    {
        str_1 = "July " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 8)
    {
        str_1 = "August " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 9)
    {
        str_1 = "September " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 10)
    {
        str_1 = "October " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() == 11)
    {
        str_1 = "November " + IntegerToString(Year(), 0, 32);
        str_0 = str_1;
        return str_0;
    }
    if (Month() != 12) return "";
    str_1 = "December " + IntegerToString(Year(), 0, 32);
    str_0 = str_1;
    return str_0;
   
    str_0 = "";
   
    return str_0;
}

void func_1011()
{
    string str_0;
    double Ld_8;
    double Ld_0;
    double Ld_E8;
    double Ld_E0;
    double Ld_D8;
    double Ld_D0;
    int Li_CC;
    double Ld_C0;
    int Li_BC;
    string Ls_B0;

    Gl_1 = Ii_278;
    if (Gl_1 == Time[0]) return;
    Ii_278 = Time[0];
    ObjectCreate(0, "TxtConquerorTitle", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
    ObjectSet("TxtConquerorTitle", OBJPROP_CORNER, Ii_260);
    ObjectSet("TxtConquerorTitle", OBJPROP_XDISTANCE, Ii_264);
    Gi_2 = Ii_268 + 10;
    ObjectSet("TxtConquerorTitle", OBJPROP_YDISTANCE, Gi_2);
    str_0 = "HiLLzX Conqueror " + Is_0;
    ObjectSetText("TxtConquerorTitle", str_0, 14, "Arial", 55295);
    if (RiskScale == 0)
    {
        Ii_23C = 185;
    }
    else
    {
        if (RiskScale == 1)
        {
            Ii_23C = 210;
        }
        else
        {
            if (RiskScale == 2)
            {
                Ii_23C = 250;
            }
            else
            {
                if (RiskScale == 3)
                {
                    Ii_23C = 290;
                }
                else
                {
                    if (RiskScale == 4)
                    {
                        Ii_23C = 330;
                    }
                    else
                    {
                        if (RiskScale == 5)
                        {
                            Ii_23C = 420;
                        }
                        else
                        {
                            if (RiskScale == 6)
                            {
                                Ii_23C = 530;
                            }
                            else
                            {
                                if (RiskScale == 7)
                                {
                                    Ii_23C = 890;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (OverrideRisk)
    {
        Ii_23C = OverrideRiskDigit;
    }
    Ld_8 = 0;
    Gi_2 = Money_Management;
    if (Gi_2 == 1)
    {
        Ld_8 = NormalizeDouble(((AccountBalance() / Ii_23C) * Id_280), 2);
        Id_270 = Ld_8;
    }
    else
    {
        if ((LotSize < Id_280))
        {
            Id_270 = Id_280;
        }
        else
        {
            Id_270 = LotSize;
        }
    }
    Ld_0 = Close[1];
    Ld_E8 = Open[1];
    Ld_E0 = Low[1];
    Ld_D8 = High[1];
    Ld_D0 = 0;
    Li_CC = 0;
    Ld_C0 = 0;
    Li_BC = 0;
    if ((Ld_E8 > Ld_0))
    {
        Ld_D0 = NormalizeDouble((Ld_E8 - Ld_0), _Digits);
        Li_CC = (int)(Ld_D0 / _Point);
        Ld_C0 = NormalizeDouble((Ld_0 - Ld_E0), _Digits);
        Li_BC = (int)(Ld_C0 / _Point);
        Ls_B0 = "sell";
    }
    else
    {
        Ld_D0 = NormalizeDouble((Ld_0 - Ld_E8), _Digits);
        Li_CC = (int)(Ld_D0 / _Point);
        Ld_C0 = NormalizeDouble((Ld_D8 - Ld_0), _Digits);
        Li_BC = (int)(Ld_C0 / _Point);
        Ls_B0 = "buy";
    }
    if (Li_CC <= Ii_250) return;
    if (Li_BC >= Ii_254) return;
    if (Ls_B0 == "buy")
    {
        func_1012(Low[1]);
        return;
    }
    func_1013(High[1]);
   
}

void func_1012(double arg_0)
{
    double Ld_8;
    double Ld_0;
    int Li_EC;
    int Li_E8;
    string Ls_D8;

    Ld_8 = 0;
    Ld_0 = 0;
    Gi_0 = Ii_25C - Ii_288;
    Ld_8 = Gi_0;
    if (StopLoss == 0)
    {
        Ld_0 = 0;
    }
    else
    {
        Gd_0 = (StopLoss * _Point);
        Ld_0 = (arg_0 - Gd_0);
    }
    Li_EC = 0;
    Li_E8 = 0;
    do
    {
        Gd_0 = Id_270;
        Gb_1 = (Id_270 < SymbolInfoDouble(_Symbol, 34));
        if (Gb_1)
        {
            Ls_D8 = StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", SymbolInfoDouble(_Symbol, 34));
            Gb_1 = false;
        }
        else
        {
            if ((Gd_0 > SymbolInfoDouble(_Symbol, 35)))
            {
                Ls_D8 = StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", SymbolInfoDouble(_Symbol, 35));
                Gb_1 = false;
            }
            else
            {
                Gd_2 = round((Gd_0 / SymbolInfoDouble(_Symbol, 36)));
                Gi_2 = (int)Gd_2;
                Gd_3 = fabs(((Gi_2 * SymbolInfoDouble(_Symbol, 36)) - Gd_0));
                if ((Gd_3 > 1E-07))
                {
                    Ls_D8 = StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", SymbolInfoDouble(_Symbol, 36), (Gi_2 * SymbolInfoDouble(_Symbol, 36)));
                    Gb_1 = false;
                }
                else
                {
                    Ls_D8 = "Correct volume value";
                    Gb_1 = true;
                }
            }
        }
        if (Gb_1)
        {
            Li_EC = OrderSend(_Symbol, 0, Id_270, Ask, Slippage, Ld_0, ((Ld_8 * _Point) + Ask), "HiLLzX Conqueror Buy", -1, 0, 4294967295);
        }
        if (Li_EC > 0)
        {
            return;
        }
        RefreshRates();
        Li_E8 = Li_E8 + 1;
    } while (Li_E8 < 3);
                                         
}

void func_1013(double arg_1)
{
    double Ld_8;
    double Ld_0;
    int Li_EC;
    int Li_E8;
    string Ls_D8;

    Ld_8 = 0;
    Ld_0 = 0;
    Gi_0 = Ii_25C - Ii_288;
    Ld_8 = Gi_0;
    if (StopLoss == 0)
    {
        Ld_0 = 0;
    }
    else
    {
        Ld_0 = ((StopLoss * _Point) + arg_1);
    }
    Li_EC = 0;
    Li_E8 = 0;
    do
    {
        Gd_0 = Id_270;
        Gb_1 = (Id_270 < SymbolInfoDouble(_Symbol, 34));
        if (Gb_1)
        {
            Ls_D8 = StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", SymbolInfoDouble(_Symbol, 34));
            Gb_1 = false;
        }
        else
        {
            if ((Gd_0 > SymbolInfoDouble(_Symbol, 35)))
            {
                Ls_D8 = StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", SymbolInfoDouble(_Symbol, 35));
                Gb_1 = false;
            }
            else
            {
                Gd_2 = round((Gd_0 / SymbolInfoDouble(_Symbol, 36)));
                Gi_2 = (int)Gd_2;
                Gd_3 = fabs(((Gi_2 * SymbolInfoDouble(_Symbol, 36)) - Gd_0));
                if ((Gd_3 > 1E-07))
                {
                    Ls_D8 = StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", SymbolInfoDouble(_Symbol, 36), (Gi_2 * SymbolInfoDouble(_Symbol, 36)));
                    Gb_1 = false;
                }
                else
                {
                    Ls_D8 = "Correct volume value";
                    Gb_1 = true;
                }
            }
        }
        if (Gb_1)
        {
            Gd_3 = (Ld_8 * _Point);
            Li_EC = OrderSend(_Symbol, 1, Id_270, Bid, Slippage, Ld_0, (Bid - Gd_3), "HiLLzX Conqueror Sell", -1, 0, 4294967295);
        }
        if (Li_EC > 0)
        {
            return;
        }
        RefreshRates();
        Li_E8 = Li_E8 + 1;
    } while (Li_E8 < 3);
                                         
}


