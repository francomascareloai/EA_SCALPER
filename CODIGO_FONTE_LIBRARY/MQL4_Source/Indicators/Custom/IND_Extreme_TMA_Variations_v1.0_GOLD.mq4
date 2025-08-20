//https://fxcodebase.com/code/viewtopic.php?f=38&t=73942

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
 
 
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DarkGray
#property indicator_color4 DarkGray
#property indicator_color5 DarkGray
#property indicator_color6 DarkGray
#property indicator_color7 DarkGray

//---- input parameters
extern int TMA_Period = 56;
int ATR_Period = 100;
double ATR_Mult = 2;
double TrendThreshold = 0.5;
bool Redraw = True;

input int HalfLength = 50;
input int pipRange = 6;
//---- indicator buffers
double Up [];
double Down [];
double Neutral [];
double TMA [];

double Top [];
double Bottom [];

int FullLength;
double ArrowUp [];
double ArrowDn [];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    //---- indicator buffers mapping
    IndicatorBuffers(8);
    SetIndexBuffer(0, Up);
    SetIndexBuffer(1, Down);
    SetIndexBuffer(2, Neutral);
    SetIndexBuffer(3, Top);
    SetIndexBuffer(4, Bottom);
    SetIndexBuffer(5, ArrowUp);
    SetIndexBuffer(6, ArrowDn);

    SetIndexBuffer(7, TMA);


    //---- drawing settings
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexStyle(3, DRAW_LINE);
    SetIndexStyle(4, DRAW_LINE);
    SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexArrow(5, 233);
    SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(6, 234);

    // SetIndexStyle(5, DRAW_ARROW);
    // SetIndexStyle(6, DRAW_ARROW);

    SetIndexStyle(7, DRAW_NONE);

    IndicatorShortName("Extreame_TMA_Line");

    FullLength = 2 * HalfLength + 1;
    //---- initialization done
    return(0);
}


// ------------------------------------------------------------------
int start()
{
    int    i, j, nLimit;
    //---- bars count that does not changed after last indicator launch.
    int    nCountedBars = IndicatorCounted();
    //---- last counted bar will be recounted
    // if(nCountedBars <= ATR_Period * 2)
        // nLimit = Bars - (ATR_Period * 2);

    if(nCountedBars <= FullLength * 2) nLimit = Bars - (FullLength * 2);
    else nLimit = Bars - nCountedBars - 1;
    //---- moving averages absolute difference

    double Sum, SumW;
    int ii;
    bool LastPeriod;
    double ATR, Slope;


    for(i = nLimit; i >= 0; i--)
    {
        ii = TMA_Period;

        if(i == 0) { LastPeriod = True; }
        else { LastPeriod = False; }

        while(ii > 0)
        {
            if(LastPeriod == False) { ii = 0; }
            else { ii = ii - 1; }

            Sum = 0;
            SumW = (TMA_Period + 2) * (TMA_Period + 1) / 2;

            for(j = 0; j <= TMA_Period; j++)
            {
                Sum = Sum + (TMA_Period - j + 1) * Close[i + j];
                if(Redraw == True)
                {
                    if(i - j > 0) // (j<=nLimiti && j>0)
                    {
                        Sum = Sum + (TMA_Period - j + 1) * Close[i - j];
                        SumW = SumW + (TMA_Period - j + 1);
                    }
                }

            }

            if(SumW != 0) { TMA[i] = Sum / SumW; } // i=i+1;
        }
    }

    if(nCountedBars <= ATR_Period * 2) nLimit = Bars - (ATR_Period * 2); else nLimit = Bars - nCountedBars - 1;


    double range;

    for(i = nLimit; i >= 0; i--)
    {

        ATR = iATR(NULL, 0, ATR_Period, i);
        Slope = (TMA[i] - TMA[i + 1]) / (0.1 * ATR);


        // if(Slope > TrendThreshold)
        if(TMA[i] > TMA[i + FullLength - 1])
        {
            Up[i] = TMA[i];
            Up[i + 1] = TMA[i + 1];
            Down[i] = EMPTY_VALUE;
            Neutral[i] = EMPTY_VALUE;
        }
        // else if(Slope < -TrendThreshold)
        else if(TMA[i] < TMA[i + FullLength - 1])
        {
            Up[i] = EMPTY_VALUE;
            Down[i] = TMA[i];
            Down[i + 1] = TMA[i + 1];
            Neutral[i] = EMPTY_VALUE;
        }

        else
        {
            Up[i] = EMPTY_VALUE;
            Down[i] = EMPTY_VALUE;
            Neutral[i] = TMA[i];
            Neutral[i + 1] = TMA[i + 1];
        }

        // range = ATR * ATR_Mult;
        // Top[i] = TMA[i] + range;
        // Bottom[i] = TMA[i] - range;

        double newrange = pipRange * 10 * _Point;
        Top[i] = TMA[i] + newrange;
        Bottom[i] = TMA[i] - newrange;

        if(Up[i] != EMPTY_VALUE)
            if(Close[i] <= Bottom[i] && Open[i] >= Bottom[i] || Close[i] >= Bottom[i] && Open[i] <= Bottom[i])
            {
                ArrowUp[i] = Bottom[i];
            }
        if(Down[i] != EMPTY_VALUE)
            if(Close[i] >= Top[i] && Open[i] <= Top[i] || Close[i] <= Top[i] && Open[i] >= Top[i])
            {
                ArrowDn[i] = Top[i];
            }


    }

    //---- done
    return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+