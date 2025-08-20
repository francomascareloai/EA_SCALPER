//+---------------------------------------------------------------------+
//|                                                         PrizmaL.mq4 |
//|                                     Copyright 2010,info@fx68.com |
//|                                              http://www.Fx68.com |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "必胜外汇 EA智能系统专家(MT4)"
#property link      "http://www.Fx68.com"
extern int    EA_magic          = 2010888;
extern double POS_tp            = 5;
extern double POS_sl            = 30;
extern double POS_slippage      = 3;
extern int    POS_num_max       = 1;
extern double        minLots           = 0.1;
extern double        maxLots           = 15;
extern int           Risk_percent      = 57;
#define DEF_MA_TYP              5
#define DEF_MA_NUM              4
double Buf_MA[DEF_MA_TYP][DEF_MA_NUM];
int MA_prm_1                    = 8;
int MA_prm_2                    = 17;
int MA_prm_3                    = 20;
int MA_prm_4                    = 29;
int MA_prm_5                    = 37;
int    RSI_period5              = 11;
int    RSI_period1              = 38;
double RSI_upper                = 51;
double RSI_lower                = 50;
double   Lots;
int     POS_n_BUY;
int     POS_n_SELL;
int     POS_n_total;
#define SIG_Buy                 0
#define SIG_Sell                1
#define SIG_MAX                 2
bool    TradeSign[SIG_MAX];

void count_position()
{
    POS_n_BUY  = 0;
    POS_n_SELL = 0;

    for( int i = 0 ; i < OrdersTotal() ; i++ ){
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ){
            break;
        }
        if( OrderMagicNumber() != EA_magic ){
            continue;
        }
        if( OrderSymbol() != Symbol() ){
            continue;
        }
        if( OrderType() == OP_BUY ){
            POS_n_BUY++;
        }
        else if( OrderType() == OP_SELL ){
            POS_n_SELL++;
        }
    }
    POS_n_total = POS_n_BUY + POS_n_SELL;
}

int start()
{
    double pos_tp  = 0.0;
    double pos_sl  = 0.0;
    int   spread = MarketInfo(Symbol(),MODE_SPREAD);
    int    ticket;
    int    signal = 0;
    if( IsTradeAllowed() != true ){
        return(0);
    }

    if( Hour()<21 && Hour()>6)
      return(0);

    if( get_signal() == true ){
        count_position();
        Call_MM();
        if( POS_n_total < POS_num_max ){
            if( TradeSign[SIG_Buy]== true ){
                pos_tp = Ask + (POS_tp * Point);
                pos_sl = Ask - (POS_sl * Point);
                ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, POS_slippage, pos_sl, pos_tp, "必胜外汇 Fx68.com", EA_magic, 0, Blue );
                Print("ticket ",GetLastError());
                if( ticket < 0 ){
                    Sleep(5000);
                }
            }
            if( TradeSign[SIG_Sell] == true ){
                pos_tp = Bid - (POS_tp * Point);
                pos_sl = Bid + (POS_sl * Point);
                ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, POS_slippage, pos_sl, pos_tp, "必胜外汇 Fx68.com", EA_magic, 0, Red );
                Print("ticket ",GetLastError());
                if( ticket < 0 ){
                    Sleep(5000);
                }
            }
        }
    }

    return(0);
}

bool get_signal()
{
    bool enable_trade = false;
    int  trend_up   = 0;
    int  trend_down = 0;
    int  i;

    ArrayInitialize( TradeSign, false );

    if( Bars >= 100 ){
        for( i = 0 ; i < DEF_MA_NUM ; i++ ){
            Buf_MA[0][ i ] = calc_SMA( PERIOD_M30, MA_prm_1, i );
            Buf_MA[1][ i ] = calc_SMA( PERIOD_M30, MA_prm_2, i );
            Buf_MA[2][ i ] = calc_SMA( PERIOD_M30, MA_prm_3, i );
            Buf_MA[3][ i ] = calc_SMA( PERIOD_M30, MA_prm_4, i );
            Buf_MA[4][ i ] = calc_SMA( PERIOD_M30, MA_prm_5, i );
        }
        double vRSI   = iRSI( Symbol(), PERIOD_M5, RSI_period5, PRICE_CLOSE, 0 );
        double vRSI2  = iRSI( Symbol(), PERIOD_M1, RSI_period1, PRICE_CLOSE, 0 );

        for( i = 0 ; i < DEF_MA_TYP ; i++ ){
            if((Buf_MA[i][2] < Buf_MA[i][1]) && (Buf_MA[i][1] < Buf_MA[i][0])){
                trend_up++;
            }
        }
        if((trend_up > 3) && (vRSI <= RSI_lower) && (vRSI2 <= RSI_lower)){
            TradeSign[SIG_Buy] = true;
            enable_trade = true;
        }

        for( i = 0 ; i < DEF_MA_TYP ; i++ ){
            if((Buf_MA[i][2] > Buf_MA[i][1]) && (Buf_MA[i][1] > Buf_MA[i][0])){
                trend_down++;
            }
        }
        if((trend_down > 3) && (vRSI >= RSI_upper) && (vRSI2 >= RSI_upper)){
            TradeSign[SIG_Sell] = true;
            enable_trade = true;
        }
    }

    return(enable_trade);
}

double calc_SMA( int timeframe, int period, int offset )
{
    double vMA = 0;
    double sum=0;
    int    i;

    for( i = 0 ; i < period ; i++ ){
        sum += iClose( Symbol(), timeframe, i + offset );
    }
    vMA = sum / period;

    return(vMA);
}

void Call_MM()
{
   Lots=AccountFreeMargin()/100000*Risk_percent;

   Lots=MathMin(maxLots,MathMax(minLots,Lots));
   if(minLots<0.1) 
     Lots=NormalizeDouble(Lots,2);
   else
     {
     if(minLots<1) Lots=NormalizeDouble(Lots,1);
     else          Lots=NormalizeDouble(Lots,0);
     }


   return(0);


}