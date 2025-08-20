// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66300
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern ENUM_TIMEFRAMES TF = PERIOD_D1; // Bar Size to display High/Low

double vwap[], wp[];

int init()
{
    IndicatorShortName("Any Time Frame VWAP");
    IndicatorDigits(Digits);
    SetIndexStyle(0, DRAW_LINE);
    SetIndexBuffer(0, vwap);
    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(1, wp);

    return 0;
}

int deinit()
{
    return 0;
}

double Calculate(const datetime from, const int to)
{
    double wp_summ = 0;
    double volume_summ = 0;
    int i = to;
    while (i < Bars && Time[i] >= from)
    {
        wp_summ += wp[i];
        volume_summ += (double)Volume[i];
        i++;
    }
    return volume_summ == 0 ? 0 : wp_summ / volume_summ;
}

int start()
{
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
    int pos = limit;
    while (pos >= 0)
    {
        wp[pos] = Volume[pos] * (High[pos] + Low[pos] + Close[pos]) / 3;
        
        int index = iBarShift(_Symbol, TF, Time[pos]);
        vwap[pos] = Calculate(iTime(_Symbol, TF, index), pos);
        
        pos--;
    }
    return(0);
}
