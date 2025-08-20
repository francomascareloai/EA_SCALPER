// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66191

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern int RSI_Period = 14;
extern int CCI_Period = 14;
extern color    Labels_Color             = clrWhite;

string   WindowName;
int      WindowNumber;
string _font = "Arial";
int _fontSize = 12;

class TextMaxSizeCalculator
{
    int _width;
    int _height;
public:
    TextMaxSizeCalculator()
    {
        _width = 0;
        _height = 0;
    }

    void AddText(const string text)
    {
        int width;
        int height;
        TextGetSize(text, width, height);
        if (_width < width)
        {
            _width = width;
        }
        if (_height < height)
        {
            _height = height;
        }
    }

    int GetWidth()
    {
        return _width;
    }
    int GetHeight()
    {
        return _height;
    }
};

int init()
{
    WindowName = "RSI & CCI Values on Chart Window";
    IndicatorShortName(WindowName);

    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID());
    return(0);
}

int start()
{
    int y = 50;
    int x = 50;
    TextMaxSizeCalculator col0;
    TextMaxSizeCalculator col1;
    col0.AddText("RSI:");
    col0.AddText("-1:");
    col0.AddText("-2:");
    col0.AddText("-3:");
    col0.AddText("-4:");
    col0.AddText("-5:");
    col0.AddText("CCI:");
    int h = col0.GetHeight() * 1.1;
    int col_0_x = x;
    for (int i = 0; i < 6; ++i)
    {
        string rsi_val = DoubleToStr(iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, i), 2);
        col1.AddText(rsi_val);
        ObjectMakeLabel("col_1_RSI_" + IntegerToString(i), col_0_x, y + h * i, rsi_val, Labels_Color, 1, WindowNumber, _font, _fontSize);
    }
    for (i = 0; i < 6; ++i)
    {
        string cci_val = DoubleToStr(iCCI(NULL, 0, CCI_Period, PRICE_CLOSE, i), 2);
        col1.AddText(cci_val);
        ObjectMakeLabel("col_1_CCI_" + IntegerToString(i), col_0_x, y + h * (i + 7), cci_val, Labels_Color, 1, WindowNumber, _font, _fontSize);
    }
    int col_1_x = col_0_x + col1.GetWidth() * 1.1;
    ObjectMakeLabel("col_0_RSI", col_1_x, y, "RSI:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_RSI_1", col_1_x, y + h * 1, "-1:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_RSI_2", col_1_x, y + h * 2, "-2:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_RSI_3", col_1_x, y + h * 3, "-3:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_RSI_4", col_1_x, y + h * 4, "-4:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_RSI_5", col_1_x, y + h * 5, "-5:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI", col_1_x, y + h * 7, "CCI:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI_1", col_1_x, y + h * 8, "-1:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI_2", col_1_x, y + h * 9, "-2:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI_3", col_1_x, y + h * 10, "-3:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI_4", col_1_x, y + h * 11, "-4:", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_0_CCI_5", col_1_x, y + h * 12, "-5:", Labels_Color, 1, WindowNumber, _font, _fontSize);

    return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
    ObjectDelete(nm);
    ObjectCreate( nm, OBJ_LABEL, Window, 0, 0 );
    ObjectSet( nm, OBJPROP_CORNER, LabelCorner );
    ObjectSet( nm, OBJPROP_XDISTANCE, xoff );
    ObjectSet( nm, OBJPROP_YDISTANCE, yoff );
    ObjectSet( nm, OBJPROP_BACK, false );
    ObjectSetText( nm, LabelTexto, FSize, Font, LabelColor );
    return;
}