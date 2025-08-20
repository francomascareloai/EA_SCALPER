//+------------------------------------------------------------------+
//|                                            Phoenix_5_7_2_W.mq4   |
//|                                       Copyright © 2006, Hendrick |
//|               Joint Copyright © 2006,2007 PhoenixFund Community  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Hendrick."

#define MAGICMA_A  20061120   //modified to simple range by Daraknor 5.6.6
#define MAGICMA_B  20061121   //If you run two copies of Phoenix on one account, modify Magic numbers on one EA.

#define MAGICMA01  20061122
#define MAGICMA02  20061123
#define MAGICMA03  20061124

//+--------------------------------------------------------------------------------------------------+
//|  Pcontour 5.7.F: massive variable and function renaming. Integrated with community suggestions in release 5.7.1
//|  Fields that start with U_ - are USER fields - that the user always chooses.
//|                            - contain defaults that are the same for all currencies.
//|                            - You must set these, even if you set PrefSettings to True
//|
//|                         P  - If you set PrefSettings to False then you need to set all the
//|                              external fields  starting with P_ and U_ to your own settings.
//|
//|                         C  - These are just comments
//+--------------------------------------------------------------------------------------------------+

extern string     C_INIT                  = "=== Use INIT section - ignore all P_ settings =====";
extern bool       U_PrefSettings          = true;     //True means the builtin values are used to trade

extern string     C_PhoenixSettings       = "===== Phoenix Mode Selected ==============================";
extern int        U_Mode                  = 1;	//Daraknor changed 5.6.8 to mode 1 by default for stable trading 5.6.8

extern string     C_M1_Settings           = "====== Phoenix Mode 1 (Stable) ==================";
extern int        U_M1_BreakEvenAfterPips = 0;
extern int        P_M1_TS                 = 0;	//set here to activate trailing stop, value of 0 disables.
extern string     C_M12_Settings          = "==== Phoenix Mode 1 & 2 - shared fields ==================";
extern int        P_M12_TP                = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern int        P_M12_SL                = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern int        U_M12_MaxTrades         = 1;	//set to number of trades to open
extern int        U_M12_ConsecSignals     = 5;	//Set to number of Consec confirming signals.
                                                   //Added 5.6.4 by Daraknor, contributed by Dagnar
                                                   //Change 5.6.6 by Daraknor to default=5 for consistency in trading

extern string     C_M2_Settings           = "===== Phoenix Mode 2 (2 trades-testing, move 2nd SL)===";
extern int        P_M2_OpenTrade_2        = 0;
extern int        P_M2_TP                 = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern int        P_M2_SL                 = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern bool       U_M2_CloseTrade_1       = false;

extern string     C_M3                    = "====== Phoenix Mode 3 (3 trades-testing, moving SL, incr profit) =====";
extern int        P_M3_CloseTrade_23      = 0;
extern int        P_M3_TP                 = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern int        P_M3_SL                 = 0;	//not necessary for standard currencies, assign here for U_PrefSettings=false
extern double     P_M3_T1adj              = 0.8;
extern double     P_M3_T2adj              = 1.0;
extern double     P_M3_T3adj              = 1.2; 	//Added 5.7.0

// Money Management Settings
extern string     C_Function_Y            = "====== U_MM Money Management decreases lotsize in a losing streak =====";
extern bool       U_MM                    = true;     //Money management
extern double     U_Lots                  = 1;        //Money management will override setting
extern double     U_MaxRisk               = 0.05;     //
extern int        U_DecreaseFactor        = 901000;   //
extern bool       U_AccIsMicro            = false;	 //Micro means 0.01 lot size is allowed
//Daraknor Add 5.7.1 contrib Dmitry_CH, modified version of min/max settings with new style.
//Recommend changing U_MinLot based on your minimum broker value. 
extern double     U_MinLot                = 00.01;	 //Set to be micro safe by default, maybe this should change
extern double     U_MaxLot                = 99.00;	 //Set to previous max value by default

// Exit Strategy Settings
extern string     C_Function_X            = "====== Grace Functionality ======";
extern int        U_GraceHours            = 0;       //Setting of 0 disables, 24 = 24 hours Daraknor 5.6.6
extern int        U_ForceHours            = 0;       //Setting of 0 disables, 48 = 48 hours Darankor 5.6.6
extern int        U_Grace_TS              = 10;	//Trailing stop in pips to use during Grace Exit: should be small
							//Daraknor Added U_Grace_TS 5.7.1 from PContour suggestion


extern string     C_Signal1               = "====== Signal 1 ===================================";
extern bool       U_UseSig1               = true;
extern double     P_Percent               = 0;
extern int        P_EnvPeriod             = 0;

extern string     C_Signal2               = "====== Signal 2 ==================================";
extern bool       U_UseSig2               = true;
extern int        P_SMAPeriod             = 0;
extern int        P_SMA2Bars              = 0;

extern string     C_Signal3               = "====== Signal 3 ==================================";
extern bool       U_UseSig3               = true;
extern int        P_OSMAFast              = 0; //Daraknor 5.7.1 contrib Yashil, switched these to be standard usage.
extern int        P_OSMASlow              = 0; //Should have no visible effect at all.
extern double     P_OSMASignal            = 0;

extern string     C_Signal4               = "====== Signal 4 ==================================";
extern bool       U_UseSig4               = true;
extern int        P_Fast_Period           = 0;
       int        P_Fast_Price            = PRICE_OPEN;  // NOTE: not external - Daraknor 5.7.2
extern int        P_Slow_Period           = 0;
       int        P_Slow_Price            = PRICE_OPEN;  // NOTE: not external - Daraknor 5.7.2
extern double     P_DVBuySell             = 0;
extern double     P_DVStayOut             = 0;

extern string     C_Signal5               = "====== Signal 5 =================================";
extern bool       U_UseSig5               = true;
extern int        U_T1From                = 0;
extern int        U_T1Until               = 24;
extern int        U_T2From                = 0;
extern int        U_T2Until               = 0;
extern int        U_T3From                = 0;
extern int        U_T3Until               = 0;
extern int        U_T4From                = 0;
extern int        U_T4Until               = 0;

bool dummyResult;
//+--------------------------------------------------------------------------------------------------+
//|  Fields that start with W_ - are WORK fields - You don't change these.                           |
//+--------------------------------------------------------------------------------------------------+

int  W_Buy_Signal  =0;			//confirming signals code   Added 5.6.4
int  W_Sell_Signal =0;
int  W_s_time      =0;
int  W_M1_TS       =0;

//+------------------------------------------------------------------+
//| INITIALIZATION SECTION                                           |
//+------------------------------------------------------------------+

int init()
{

//+------------------------------------------------------------------+
//| START Preffered Settings                                         |
//+------------------------------------------------------------------+
if(U_PrefSettings == true)
   {
//   if((Symbol() == "EURUSD") || (Symbol() == "EURUSDm"))
  //    {     //Settings added in 5.6.6 by Daraknor, contributed by EricBach
            //5.7.2 settings removed after testing.

/*   if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update
         P_M1_TS         = 0; //    they override the settings here.    - pcontour TS update
      P_M12_TP           = 10;
      P_M12_SL           = 10;

      P_M2_OpenTrade_2   = 0;
      P_M2_TP            = 50;
      P_M2_SL            = 60;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 0;
          P_M3_TP            = 42;
          P_M3_SL            = 84;
        } 
      // Signal 1 to 4 Settings

      P_Percent          = 0.001;
      P_EnvPeriod        = 20;

      P_SMAPeriod        = 11;
      P_SMA2Bars         = 50;

      P_OSMAFast         = 8;
      P_OSMASlow         = 40;
      P_OSMASignal       = 10;

      P_Fast_Period      = 4;
      P_Slow_Period      = 15;
      P_DVBuySell        = 0.0003;
      P_DVStayOut        = 0.006;

      } */
   if((Symbol() == "USDJPY") || (Symbol() == "USDJPYm"))
      {

      
      if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update 
         P_M1_TS         = 0; //    they override the settings here.     - pcontour TS update

      P_M12_TP           = 42;
      P_M12_SL           = 84;

      P_M2_OpenTrade_2   = 0;
      P_M2_TP            = 50;
      P_M2_SL            = 60;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 0;
          P_M3_TP            = 42;
          P_M3_SL            = 84;
        }

      // Signal 1 to 4 Settings

      P_Percent          = 0.0032;
      P_EnvPeriod        = 2;

      P_SMAPeriod        = 2;
      P_SMA2Bars         = 18;

      P_OSMAFast         = 5;
      P_OSMASlow         = 22;
      P_OSMASignal       = 2;

      P_Fast_Period      = 25;
      P_Slow_Period      = 15;
      P_DVBuySell        = 0.0029;
      P_DVStayOut        = 0.024;
      }

   if((Symbol() == "EURJPY") || (Symbol() == "EURJPYm"))
      {
      if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update 
         P_M1_TS         = 0; //    they override the settings here.     - pcontour TS update

      P_M12_TP           = 42;
      P_M12_SL           = 84;

      P_M2_OpenTrade_2   = 18;
      P_M2_TP            = 70;
      P_M2_SL            = 30;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 55;
          P_M3_TP            = 70;
          P_M3_SL            = 80;
        }

      // Signal 1 to 4 Settings

      P_Percent          = 0.007;
      P_EnvPeriod        = 2;

      P_SMAPeriod        = 4;
      P_SMA2Bars         = 16;

      P_OSMAFast         = 11;
      P_OSMASlow         = 20;
      P_OSMASignal       = 14;

      P_Fast_Period      = 20;
      P_Slow_Period      = 10;
      P_DVBuySell        = 0.0078;
      P_DVStayOut        = 0.026;
      }

   if((Symbol() == "GBPJPY") || (Symbol() == "GBPJPYm"))
      {
      if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update 
         P_M1_TS         = 0; //    they override the settings here.     - pcontour TS update

      P_M12_TP           = 42;
      P_M12_SL           = 84;

      P_M2_OpenTrade_2   = 2;
      P_M2_TP            = 130;
      P_M2_SL            = 80;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 40;
          P_M3_TP            = 90;
          P_M3_SL            = 80;
        }

      // Signal 1 to 4 Settings

      P_Percent          = 0.0072;
      P_EnvPeriod        = 2;

      P_SMAPeriod        = 8;
      P_SMA2Bars         = 12;

      P_OSMAFast         = 5;
      P_OSMASlow         = 36;
      P_OSMASignal       = 10;

      P_Fast_Period      = 17;
      P_Slow_Period      = 28;
      P_DVBuySell        = 0.0034;
      P_DVStayOut        = 0.063;
      }

   if((Symbol() == "USDCHF") || (Symbol() == "USDCHFm"))
      {
      if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update 
         P_M1_TS         = 0; //    they override the settings here.     - pcontour TS update

      P_M12_TP           = 42;
      P_M12_SL           = 84;

      P_M2_OpenTrade_2   = 10;
      P_M2_TP            = 90;
      P_M2_SL            = 65;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 85;
          P_M3_TP            = 130;
          P_M3_SL            = 80;
        }

      // Signal 1 to 4 Settings

      P_Percent          = 0.0056;
      P_EnvPeriod        = 10;

      P_SMAPeriod        = 5;
      P_SMA2Bars         = 9;

      P_OSMAFast         = 5;
      P_OSMASlow         = 12;
      P_OSMASignal       = 11;

      P_Fast_Period      = 5;
      P_Slow_Period      = 20;
      P_DVBuySell        = 0.00022;
      P_DVStayOut        = 0.0015;
      }

   if((Symbol() == "GBPUSD") || (Symbol() == "GBPUSDm"))
      {
      if (P_M1_TS == 0)       // If the user sets the trailing stop then - pcontour TS update 
         P_M1_TS         = 0; //    they override the settings here.     - pcontour TS update

      P_M12_TP           = 42;
      P_M12_SL           = 84;

      P_M2_OpenTrade_2   = 5;
      P_M2_TP            = 95;
      P_M2_SL            = 90;

      if (U_Mode == 3 )
        {
          P_M3_CloseTrade_23 = 90;
          P_M3_TP            = 110;
          P_M3_SL            = 80;
        }

      // Signal 1 to 4 Settings

      P_Percent          = 0.0023;
      P_EnvPeriod        = 6;

      P_SMAPeriod        = 3;
      P_SMA2Bars         = 14;

      P_OSMAFast         = 23;
      P_OSMASlow         = 17;
      P_OSMASignal       = 15;

      P_Fast_Period      = 25;
      P_Slow_Period      = 37;
      P_DVBuySell        = 0.00042;
      P_DVStayOut        = 0.05;
      }
   }
   
if(P_M1_TS!=0) 
  {
    P_M12_TP = 999; // - pcontour TS update

    if( P_M1_TS <  MarketInfo(Symbol(),MODE_STOPLEVEL) )
      {
        Print("Trailing stop below broker minumum. TS changed to: ",MODE_STOPLEVEL);
        P_M1_TS  = MarketInfo(Symbol(),MODE_STOPLEVEL);
      }
   }
  
if(U_MinLot==0) U_MinLot = MarketInfo(Symbol(),MODE_MINLOT); //Pcontour 5.7.3
if(U_MaxLot==0) U_MaxLot = MarketInfo(Symbol(),MODE_MAXLOT); //Pcontour 5.7.3
   return(0);
}

//+------------------------------------------------------------------+
//| END Preffered Settings                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| START EA  -  MainlIne                                            |
//+------------------------------------------------------------------+
void start()
   {

 /*failed experiment in 5.7.2 to cut down the number of bad values tested. */
 //if((P_Fast_Period +5>P_Slow_Period)||(P_OSMAFast+5>P_OSMASlow)) {

   if(Bars<100)
      {
      Print("bars less than 100");
      return;
      }

   if(U_Mode==1)//Phoenix Classic - Open One Trade
      {
      S1_Mode_1_2_OpenTrade_If_Signal();

      if(U_GraceHours !=0 ||U_ForceHours !=0) X_ForceClose_or_GraceModify();

      if(P_M1_TS !=0)                         M1_A_Update_TStop_if_Applicable();
      if(U_M1_BreakEvenAfterPips != 0)        M1_B_Update_TStop_if_BreakEven();
      }


   if(U_Mode==2)//Phoenix - Open Second Trade after First Trade Profit
      {
      S1_Mode_1_2_OpenTrade_If_Signal();

      if(U_GraceHours !=0 ||U_ForceHours !=0) X_ForceClose_or_GraceModify();

      M2_A_MakeSecondTrade_If_Profit();
      }

   if(U_Mode==3)//Phoenix 123 - Open three trades at once
      {
      if(U_GraceHours !=0 ||U_ForceHours !=0) X_ForceClose_or_GraceModify();//Added 5.6.6 Daraknor

      M3_A_Mode3_OpenTrade_If_Signal();
      M3_B_MoveSL_Trade_2_to_CurPr();
      M3_C_MoveSL_Trade_3_to_CalcPr();

      if(P_M3_CloseTrade_23 != 0) M3_D_CloseTrade23_If_Trd1_Loss();
      }
   }
//+------------------------------------------------------------------+
//| END EA   - End Mainline                                          |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//+-------------  MODE 1 Functions ----------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function UpdateTStop_if_Applicable   - Mode 1              |
//+------------------------------------------------------------------+

void M1_A_Update_TStop_if_Applicable()
   {
   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)          break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;

      if(OrderType() == OP_BUY)
        {
         //if(((Bid - OrderOpenPrice()) > (Point * P_M1_TS)) && (OrderStopLoss() < (Bid - Point * P_M1_TS)))
         //Daraknor Modify 5.7.2 Made sure that trade is profitable before altering SL
         //if(((Bid - OrderOpenPrice()) > (Point * P_M1_TS)) && (OrderStopLoss() < (Bid - Point * P_M1_TS)) && (Bid > OrderOpenPrice()))
         //Pcontour Modify 5.7.2 If there is any profit allow the TS to be changed.
         if(((Bid - OrderOpenPrice()) > 0) && (OrderStopLoss() < (Bid - Point * P_M1_TS)) && (Bid > OrderOpenPrice()))
           {
             if (P_M3_CloseTrade_23 > 1 )  W_M1_TS = P_M1_TS - MathRound ( ( (Bid - OrderOpenPrice()) / Point ) / P_M3_CloseTrade_23) ;
             else W_M1_TS = P_M1_TS;

             if (W_M1_TS < MarketInfo(Symbol(),MODE_STOPLEVEL))  W_M1_TS = MarketInfo(Symbol(),MODE_STOPLEVEL) ;

             dummyResult = OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        Bid - Point * W_M1_TS,      //SL
                        Bid + Point * W_M1_TS,      //TP
//                        OrderTakeProfit(),        //TP
                        0,
                        GreenYellow);
           }
         }

      if(OrderType() == OP_SELL)
        {
         //if(((OrderOpenPrice() - Ask) > (Point * P_M1_TS)) && (OrderStopLoss() > (Ask + Point * P_M1_TS)))
         //Daraknor Modify 5.7.2 Made sure that trade is profitable before altering SL
         //if(((OrderOpenPrice() - Ask) > (Point * P_M1_TS)) && (OrderStopLoss() > (Ask + Point * P_M1_TS)) && (Ask < OrderOpenPrice()))
         //Pcontour Modify 5.7.2 If there is any profit allow the TS to be changed.
         if(((OrderOpenPrice() - Ask) > 0) && (OrderStopLoss() > (Ask + Point * P_M1_TS)) && (Ask < OrderOpenPrice()))
           {
             if (P_M3_CloseTrade_23 > 1 ) W_M1_TS = P_M1_TS - MathRound ( ( (OrderOpenPrice() - Ask) / Point ) / P_M3_CloseTrade_23 );
             else W_M1_TS = P_M1_TS;

             if (W_M1_TS < MarketInfo(Symbol(),MODE_STOPLEVEL))  W_M1_TS = MarketInfo(Symbol(),MODE_STOPLEVEL) ; 

             dummyResult = OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        Ask + Point * W_M1_TS,      //SL
                        Ask - Point * W_M1_TS,      //TP
//                        OrderTakeProfit(),        //TP
                        0,
                        Red);
           }
         }
      }
   }

//+------------------------------------------------------------------+
//| START Function UpdateTStop_if_BreakEven  - Mode 1                |
//+------------------------------------------------------------------+
void M1_B_Update_TStop_if_BreakEven()
   {
   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)          break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;

      if(OrderType() == OP_BUY)
         {
         //if((Bid-OrderOpenPrice()) > (Point*U_M1_BreakEvenAfterPips))
         if((Bid-OrderOpenPrice()) > (Point*U_M1_BreakEvenAfterPips) && (OrderStopLoss()< OrderOpenPrice()))
		 //Daraknor Modify 5.7.2 Made sure old SL isn't better than what the new SL will be: e.g. no heading backwards
	   dummyResult = OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        OrderOpenPrice(),
                        OrderTakeProfit(),
                        0,
                        GreenYellow);
         }

      if(OrderType() == OP_SELL)
         {
         //if((OrderOpenPrice()-Ask) > (Point*U_M1_BreakEvenAfterPips))
         if((OrderOpenPrice()-Ask) > (Point*U_M1_BreakEvenAfterPips)  && (OrderStopLoss()> OrderOpenPrice()))
		 //Daraknor Modify 5.7.2 Made sure old SL isn't better than what the new SL will be: e.g. no heading backwards
            dummyResult = OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        OrderOpenPrice(),
                        OrderTakeProfit(),
                        0,
                        Red);
         }
      }
   }

//+------------------------------------------------------------------+
//+-------------  MODE 2 Functions ----------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function MakeSecondTrade_If_Profit  - Mode 2               |
//+------------------------------------------------------------------+
void M2_A_MakeSecondTrade_If_Profit()
   {
   int err = 0, total = OrdersTotal();

   for(int z = total - 1; z >= 0; z --)
      {
      if(!OrderSelect( z, SELECT_BY_POS))
         {
         err = GetLastError();
         Print("OrderSelect( ", z, ", SELECT_BY_POS ) - Error #",err );
         continue;
         }

      if(OrderSymbol() != Symbol())       continue;

      if(OrderMagicNumber() == MAGICMA_B) break;

      if(OrderMagicNumber() != MAGICMA_A) continue;

      if(OrderType() == OP_BUY && (Bid-OrderOpenPrice() > Point*P_M2_OpenTrade_2))
         {
         if(OrderSend(Symbol(),OP_BUY,Y_MM_OptimizeLotSize(),Ask,3,Ask - P_M2_SL * Point,Ask + P_M2_TP * Point,"Mode2_SecondTrade",MAGICMA_B,0,Blue) < 0)
            {
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return;
            }
         if(U_M2_CloseTrade_1==true) {M2_A_1_CloseFirstTrade();}
         return;
         }

      if(OrderType() == OP_SELL && (OrderOpenPrice()-Ask > Point*P_M2_OpenTrade_2))
         {
         if(OrderSend(Symbol(),OP_SELL,Y_MM_OptimizeLotSize(),Bid,3,Bid + P_M2_SL * Point,Bid - P_M2_TP*Point,"Mode2_SecondTrade",MAGICMA_B,0,Red) < 0)
            {
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return;
            }
         if(U_M2_CloseTrade_1==true) {M2_A_1_CloseFirstTrade();}
         return;
         }
      }
   }

//+------------------------------------------------------------------+
//| START Function Close First Trade - Mode 2                        |
//+------------------------------------------------------------------+
int M2_A_1_CloseFirstTrade()
   {
   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)          break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;

         dummyResult = OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
         return(0);
      }
      return(0);
   }


//+------------------------------------------------------------------+
//+-------------  MODE 3 Functions ----------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| START Function Open Trade If Signal  - MODE 3  By HerbertH 5.6.4 |
//+------------------------------------------------------------------+

int M3_A_Mode3_OpenTrade_If_Signal()
   {

   int Signal = 0, err = 0, total = OrdersTotal(), decimalPlaces=1;

   if(U_AccIsMicro==true)                        decimalPlaces=2;

   double lots123 = NormalizeDouble(Y_MM_OptimizeLotSize()/3,decimalPlaces);

   if(lots123 < 0.1 && U_AccIsMicro==false) {lots123=0.1;}
   if(lots123 < 0.01 && U_AccIsMicro==true) {lots123=0.01;}

   if(M3_A_1_NumberOfOpenPositions(Symbol()) < 1)
      {
      if(Z_CheckSignal(Signal)==1)
         {
         if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+P_M3_SL*Point,Bid-NormalizeDouble(P_M3_TP*P_M3_T1adj,0)*Point,"Mode3_FirstTrade",MAGICMA01,0,Red)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }

         if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+P_M3_SL*Point,Bid-NormalizeDouble(P_M3_TP*P_M3_T2adj,0)*Point,"Mode3_SecondTrade",MAGICMA02,0,Red)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }

         if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+P_M3_SL*Point,Bid-NormalizeDouble(P_M3_TP*P_M3_T3adj,0)*Point,"Mode3_ThirdTrade",MAGICMA03,0,Red)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }
         return(0);
         }

         if(Z_CheckSignal(Signal)==2)
         {
         if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-P_M3_SL*Point,Ask+NormalizeDouble(P_M3_TP*P_M3_T1adj,0)*Point,"Mode3_FirstTrade",MAGICMA01,0,Blue)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }
         if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-P_M3_SL*Point,Ask+NormalizeDouble(P_M3_TP*P_M3_T2adj,0)*Point,"Mode3_SecondTrade",MAGICMA02,0,Blue)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }
         if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-P_M3_SL*Point,Ask+NormalizeDouble(P_M3_TP*P_M3_T3adj,0)*Point,"Mode3_ThirdTrade",MAGICMA03,0,Blue)<0)
            {	//5.7.0 Set scale adj to variable
            err = GetLastError();
            Print("Error Ordersend(",err,"): ");
            return(-1);
            }
         return(0);
         }
      }
      return(0);
      
   }

//+------------------------------------------------------------------+
//| START Function Number of Open Positions - Mode 3                 |
//+------------------------------------------------------------------+

int M3_A_1_NumberOfOpenPositions(string symbol)
  {
    int buys=0,sells=0;

    for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(
           (OrderSymbol()==Symbol()) &&
           ((OrderMagicNumber()==MAGICMA01) ||
            (OrderMagicNumber()==MAGICMA02) ||
            (OrderMagicNumber()==MAGICMA03))   )
          {
            if(OrderType()==OP_BUY)  buys++;
            if(OrderType()==OP_SELL) sells++;
          }
      }
    return(buys+sells);
  }



//+------------------------------------------------------------------+
//| START Check Second Trade Mode3                                   |
//|                                                                  |
//| If for trade2   Ask > Open + (SL*point)                          |
//|     trade2 is updated so that the SL is equal to your buy price. |
//|                                                                  |
//| That's a feature of mode 3 trade 2.                              |
//+------------------------------------------------------------------+
void M3_B_MoveSL_Trade_2_to_CurPr()
  {//5.7.0 Removed all global variable and history references
    if(S2_Mode_ALL_NumberOfOpenOrder(Symbol())==2)	//5.7.0 Assumes Mode3 starts with 3 tardes,has 3 trades max.
      {
        for(int y=0;y<OrdersTotal();y++)
          {
            dummyResult = OrderSelect(y, SELECT_BY_POS, MODE_TRADES);

            if(OrderType()<=OP_SELL && OrderSymbol()==Symbol()&& (OrderMagicNumber()==MAGICMA02 || OrderMagicNumber()==MAGICMA03))
   //         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol()&& (OrderMagicNumber()==MAGICMA02))
              { //undid change in 5.6.7a changed 5.6.7 above line to only work on MAGICMA02
                RefreshRates(); //Daraknor Add 5.6.7 This makes more sense here, possibly the reason there was a bug
  		if(OrderType()==OP_BUY)
                  {
  
  		   if(Ask<OrderOpenPrice()+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) continue; //5.7.0
  		   if(OrderOpenPrice()<=OrderStopLoss()) continue; //Changed 5.6.7a, Added 5.6.7 by Daraknor, if new SL = old SL then quit.
  		   if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,GreenYellow))
                        { //Modify 5.6.7 by Daraknor - previous line becomes if(!order). Added error printing below
                        Print("OrderModify 2 ",Bid," Error # ",GetLastError()); 	//Modify 5.7.0 increased logging
                        continue;
                        }
                  }
                if(OrderType()==OP_SELL)
                  {
  		if(Bid>OrderOpenPrice()-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) continue; //5.7.0
  		if(OrderOpenPrice()>=OrderStopLoss()) continue; //Daraknor Change 5.6.7a Add 5.6.7, if new SL=old SL then quit
                    if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,GreenYellow))
                      { //Daraknor Modify 5.6.7 previous line becomes if(!order). Added error printing below
                        Print("OrderModify 2 ",Ask," Error # ",GetLastError()); 	//Modify 5.7.0 increased logging
                        continue;
                      }
                  }
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| START Check Second Trade Mode3                                   |
//+------------------------------------------------------------------+
void M3_C_MoveSL_Trade_3_to_CalcPr()
  {//5.7.0 Removed all global variable and history references
  double NewSLTrade3B,NewSLTrade3S;
    if(S2_Mode_ALL_NumberOfOpenOrder(Symbol())==1)	//5.7.0 Assumes Mode3 starts with 3 trades,has 3 trades max.
      {
        for(int y=0;y<OrdersTotal();y++)
          {
            dummyResult = OrderSelect(y, SELECT_BY_POS, MODE_TRADES);

            if(OrderType()<=OP_SELL && OrderSymbol()==Symbol()&& OrderMagicNumber()==MAGICMA03)
              {
                if(OrderType()==OP_BUY)
                  {
                    NewSLTrade3B=OrderOpenPrice()+NormalizeDouble(((
                       OrderTakeProfit()-OrderOpenPrice())/2),Digits)- MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
                    //Daraknor Add 5.6.6 MarketInfo STOPLevel make the trades universally broker safe
  	 	    //Daraknor Modify 5.6.8 STOPLEVEL returns Point value. Adjusted value to price with *Point
  		    if(NewSLTrade3B<=OrderStopLoss()) continue; //Daraknor Add 5.6.7 if new SL equal or worse old SL then quit.
                    if(!OrderModify(OrderTicket(),OrderOpenPrice(),NewSLTrade3B,OrderTakeProfit(),0,GreenYellow))
                      {
                        Print("OrderModify 3 - Error # ",GetLastError()); //Daraknor Modify 5.6.7 to include number 3
                        continue;
                      }
                      return;
                  }
                if(OrderType()==OP_SELL)
                  {
                    NewSLTrade3S=OrderOpenPrice()-NormalizeDouble(((
                       OrderOpenPrice()-OrderTakeProfit())/2),Digits)+ MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
  		    //Daraknor Modify 5.6.8 STOPLEVEL returns Point value. Adjusted value to price with *Point
                    //Daraknor Add 5.6.6 MarketInfo STOPLevel make the trades universally broker safe
                    if(NewSLTrade3S>=OrderStopLoss()) continue; //Daraknor Add 5.6.7 if new SL same/worse old SL then quit.
  			  //Daraknor Modify 5.6.8 changed to appropriate variable.
                    if(!OrderModify(OrderTicket(),OrderOpenPrice(),NewSLTrade3S,OrderTakeProfit(),0,GreenYellow))
                      {
                        Print("OrderModify 3 - Error # ",GetLastError()); //Daraknor Modify 5.6.7 to include number 3
                        continue;
                      }
                      return;
                  }
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| START Function Close Trade 2 And 3 if Trade 1 is losing - Mode3  |
//+------------------------------------------------------------------+

void M3_D_CloseTrade23_If_Trd1_Loss()
  {

    bool CloseTrade=false;

    for(int x=OrdersTotal()-1; x>=0; x--)
      {
        if(!OrderSelect( x, SELECT_BY_POS))
          {
            Print("OrderSelect( ", x, ", SELECT_BY_POS ) - Error #",GetLastError());
            continue;
          }

        if((OrderSymbol() != Symbol()) || (OrderMagicNumber() != MAGICMA01)) continue;

        if(OrderType() == OP_BUY  && (OrderOpenPrice()-Bid > Point * P_M3_CloseTrade_23)) {CloseTrade=true;}
        if(OrderType() == OP_SELL && (Ask-OrderOpenPrice() > Point * P_M3_CloseTrade_23)) {CloseTrade=true;}

        if(CloseTrade)
          {
            for(int y = OrdersTotal() - 1; y >= 0; y --)
              {
                if(!OrderSelect( y, SELECT_BY_POS))
                  {
                    Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",GetLastError());
                    continue;
                  }

                if ((OrderMagicNumber() == MAGICMA02 || OrderMagicNumber() == MAGICMA03) && OrderSymbol()==Symbol())
                  {
                    if(OrderType() == OP_BUY)
                      {
                        if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                          {
                            Print("Error OrderClose: ",GetLastError());
                            return;
                          }
                        return;
                      }
                    if(OrderType() == OP_SELL)
                      {
                        if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
                          {
                            Print("Error OrderClose: ",GetLastError());
                            return;
                          }
                        return;
                      }
                  }
              }
          }
      }
  }





//+------------------------------------------------------------------+
//+-------------  Shared Functions for PHOENIX  ---------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Open Trade If Signal for Mode 1 or Mode 2         |
//+------------------------------------------------------------------+
int S1_Mode_1_2_OpenTrade_If_Signal()
   {
   int Signal=0, err = 0, total = OrdersTotal();

   if(S2_Mode_ALL_NumberOfOpenOrder(Symbol()) < U_M12_MaxTrades)
      {
      if(Z_CheckSignal(Signal)==1)
         {
         if (CurTime()-W_s_time>900)
            {  //Daraknor Add 5.6.4 Contrib Dagnar, Disable with a U_M12_ConsecSignals=1 or 0
            W_Sell_Signal++;
            W_Buy_Signal=0;
            //W_s_time=CurTime(); //Uncomment here to make time check work. Default is tick based signals.
            }
         if (W_Sell_Signal>=U_M12_ConsecSignals)
            {
            if(OrderSend(Symbol(),OP_SELL,Y_MM_OptimizeLotSize(),Bid,3,Bid+P_M12_SL*Point,Bid-P_M12_TP*Point,"FirstTrade",MAGICMA_A,0,Red) < 0)
               {
               err = GetLastError();
               Print("Error Ordersend(",err,"): ");
               return(-1);
               }
            W_Sell_Signal=0;
            W_s_time=CurTime();
            }
         return(0);
         }

      if(Z_CheckSignal(Signal)==2)
         {
         if (CurTime()-W_s_time>900)
            {  //Daraknor Add 5.6.4 Contrib Dagnar, Disable with a U_M12_ConsecSignals=1
            W_Buy_Signal++;
            W_Sell_Signal=0;
            //W_s_time=CurTime(); //Uncomment here to make time check work. Default is tick based signals.
            }
         if (W_Buy_Signal>=U_M12_ConsecSignals)
            {
            if(OrderSend(Symbol(),OP_BUY,Y_MM_OptimizeLotSize(),Ask,3,Ask-P_M12_SL*Point,Ask+P_M12_TP*Point,"FirstTrade",MAGICMA_A,0,Blue) < 0)
               {
               err = GetLastError();
               Print("Error Ordersend(",err,"): ");
               return(-1);
               }
            W_Buy_Signal=0;
            W_s_time=CurTime();
            }
         return(0);
         }
      }
      return(0);
   }

//+------------------------------------------------------------------+
//| START Function Number of Open Orders                             |
//+------------------------------------------------------------------+
int S2_Mode_ALL_NumberOfOpenOrder(string symbol)
  {
    int count=0;

    for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
//      if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MAGICMA_A || OrderMagicNumber()==MAGICMA_B))
        if(OrderSymbol()==symbol && (OrderMagicNumber()>=MAGICMA_A && OrderMagicNumber()<=MAGICMA03))
          {//Daraknor 5.7.0 made method generic
            count++;
          }
       }
    return(count);
  }


  
//+------------------------------------------------------------------+
//+-----  Functions for use in Any Expert Advisor  ------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Valid Trade Time                                  |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------------------------------------+
//Define 2 period settings:
//- 1st period (a kind of grace period) after which a trade will be closed as soon as it is without a loss.
//              Technically by changing the TP setting to its price on entry (+spread?)
//              When this period has been reached, trades that are in profit will be closed immediately,
//              trades not yet in profit, will have time upto the next period to reach the breakeven point.
//
//- 2nd period after which the trade will be closed, regardless of its profit or loss status.
//+----------------------------------------------------------------------------------------------------------+

void X_ForceClose_or_GraceModify()
   {  //Add/Modify Daraknor 5.6.6 contrib by HerbertH in original Phoenix 2007 thread.

   int PeriodForce=U_ForceHours*3600;
   int PeriodGrace=U_GraceHours*3600;
   double newSL=0;  //Daraknor Add 5.7.1 Need to make sure new SL is better than the old one. Temp Variable.
   RefreshRates(); //Daraknor Add 5.6.6

   for(int i=0;i<OrdersTotal();i++)
      {
      dummyResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if (OrderSymbol()!=Symbol()) continue;
      if (OrderMagicNumber()>=MAGICMA_A && OrderMagicNumber()<=MAGICMA03 )
         {
         if (PeriodForce!=0)
            {
            if((OrderOpenTime() + PeriodForce) < Time[0])
               {
               if(OrderType() == OP_BUY)
                  {
                  dummyResult = OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
                  }
               if(OrderType() == OP_SELL)
                  {
                  dummyResult = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
                  }
               }
            }
         if(PeriodGrace!=0)
            {
            if(OrderType() == OP_BUY)
               {
               if((OrderOpenTime() + PeriodGrace) < Time[0] && (OrderTakeProfit() > OrderOpenPrice()+(Ask-Bid)))
//TODO: what is the point of the OrderTP check? This doesn't solve spread issues, profitability requirements, etc.
                  {
		  newSL=Bid-Point*U_Grace_TS;
		  if(newSL>OrderStopLoss()) //Daraknor Add 5.7.1 Need to make sure new SL is better than the old one.
                    dummyResult = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderOpenPrice()+(Ask-Bid),0,GreenYellow);
                  }
               }
            if(OrderType() == OP_SELL)
               {
               if((OrderOpenTime() + PeriodGrace) < Time[0] && (OrderTakeProfit() > OrderOpenPrice()+(Ask-Bid)))
//TODO: what is the point of the OrderTP check? This doesn't solve spread issues, profitability requirements, etc.
                  { 
		  newSL=Ask+Point*U_Grace_TS;
		  if(newSL<OrderStopLoss()) //Daraknor Add 5.7.1 Need to make sure new SL is better than the old one.
                    dummyResult = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderOpenPrice()-(Ask-Bid),0,GreenYellow);
                  }
               }
            }
         }
      }
   }

//+------------------------------------------------------------------+
//| START MoneyManagement - Optimize lot size                        |
//+------------------------------------------------------------------+

double Y_MM_OptimizeLotSize()
  {
    if(U_MM==false) return(U_Lots);
//Dmitry_CH Modify 5.7.1 lotsize min/max and safe on more brokers
    double lot          =U_Lots;
    int    orders       =HistoryTotal();
    int    i            =0;
    int    trades       =0;
    int    wins         =0;
    int    losses       =0;
    int    decimalPlaces=1;
    if(MarketInfo(Symbol(),MODE_LOTSTEP)==1) decimalPlaces=0; //Dmitry_CH Add 5.7.1
    if(U_AccIsMicro==true) decimalPlaces=2;

    lot=NormalizeDouble(AccountFreeMargin()*U_MaxRisk/1000.0,decimalPlaces);
    if(U_DecreaseFactor>0)
      {
       i            =orders-1;
       trades       =0;
       wins         =0;
       losses       =0;
       while (trades< 3 && i > 0) 
         {
          if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
          
          if(OrderSymbol()==Symbol() && OrderType()<=OP_SELL) 
            {
              trades++;
              if(OrderProfit()<0) losses++;
              if(OrderProfit()>0) wins++;
            }  
          i--;
         }

       if (U_DecreaseFactor > 999999)
         {
           Print("U_DecreaseFactor too large.  Changed to 802000")                 ;
           U_DecreaseFactor = 802000                                               ;
         }

       int Loss1_Percentage =  U_DecreaseFactor * 0.0001                            ;
       int Loss2_Percentage = (U_DecreaseFactor - 10000 * Loss1_Percentage) * 0.01  ;
       int Loss3_Percentage = (U_DecreaseFactor - 10000 * Loss1_Percentage
                                                -   100 * Loss2_Percentage)        ;
                                                
//       Print("Breakit ", Loss1_Percentage," ", Loss2_Percentage," ", Loss3_Percentage) ;                                               

//     if (losses==0){ lot=lot*100             *0.01;   }  //This line is just documentation
       if (losses==1){ lot=lot*Loss1_Percentage*0.01;   }
       if (losses==2){ lot=lot*Loss2_Percentage*0.01;   }
       if (losses>=3){ lot=lot*Loss3_Percentage*0.01;   }
      }
      
      lot = NormalizeDouble(lot,decimalPlaces); 

//      Print("  losses ", losses, "  lot ", lot);


//    if(lot<0.1 && U_AccIsMicro==false) lot=0.1;
//    if(lot<0.01 && U_AccIsMicro==true) lot=0.01;
//    if(lot>99) lot=99;
    if(lot<U_MinLot) { lot=U_MinLot; Print("lots switched to min ",lot); }  //Dmitry_CH Add 5.7.1
    if(lot>U_MaxLot) { lot=U_MaxLot; Print("lots switched to max ",lot); }  //Dmitry_CH Add 5.7.1


    return(lot);
  }


//+------------------------------------------------------------------+
//| START Function Z Check Signals                                   |
//+------------------------------------------------------------------+

//+ Note: If a siganl is used then it could be set to false or true
//+       If a signal is not used then it is always set to true
                             
//=====================SIGNAL1========================

int Z_CheckSignal(int Signal)
  {
    Signal=0;
    
    bool BuySignal1=false, SellSignal1=false;
    
    double HighEnvelope1 = iEnvelopes(NULL,0,P_EnvPeriod,MODE_SMA,0,PRICE_CLOSE,P_Percent,MODE_UPPER,1);
    double LowEnvelope1  = iEnvelopes(NULL,0,P_EnvPeriod,MODE_SMA,0,PRICE_CLOSE,P_Percent,MODE_LOWER,1);
    double CloseBar1     = iClose(NULL,0,1);
    
    if(U_UseSig1)
      {
        if(CloseBar1 > HighEnvelope1) {SellSignal1 = true;}
        if(CloseBar1 < LowEnvelope1)  {BuySignal1  = true;}
      }
    else
      {
    	  SellSignal1=true;
        BuySignal1 =true;
      }


    //=====================SIGNAL2========================
    
    bool BuySignal2=false, SellSignal2=false;
    
    double SMA1=iMA(NULL,0,P_SMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);
    double SMA2=iMA(NULL,0,P_SMAPeriod,0,MODE_SMA,PRICE_CLOSE,P_SMA2Bars);
    
    if(U_UseSig2)
      {
        if(SMA2-SMA1>0) {BuySignal2  = true;}
        if(SMA2-SMA1<0) {SellSignal2 = true;}
      }
    else
      {
    	  SellSignal2=true;
        BuySignal2 =true;
      }

    
    //=====================SIGNAL3========================
    
    bool BuySignal3=false, SellSignal3=false;
    
    double OsMABar2=iOsMA(NULL,0,P_OSMAFast,P_OSMASlow,P_OSMASignal,PRICE_CLOSE,2); 	//Daraknor Modify 5.7.1 contrib Yashil, standard OSMA use
    double OsMABar1=iOsMA(NULL,0,P_OSMAFast,P_OSMASlow,P_OSMASignal,PRICE_CLOSE,1); 	//Daraknor Modify 5.7.1 contrib Yashil, standard OSMA use
//    double OsMABar2=iOsMA(NULL,0,P_OSMASlow,P_OSMAFast,P_OSMASignal,PRICE_CLOSE,2);
//    double OsMABar1=iOsMA(NULL,0,P_OSMASlow,P_OSMAFast,P_OSMASignal,PRICE_CLOSE,1);
    
    if(U_UseSig3)
      {
        if(OsMABar2 < OsMABar1)  {SellSignal3 = true;}	//Daraknor Modify 5.7.1 contrib Yashil, standard OSMA use
        if(OsMABar2 > OsMABar1)  {BuySignal3  = true;}	//Daraknor Modify 5.7.1 contrib Yashil, standard OSMA use
//        if(OsMABar2 > OsMABar1)  {SellSignal3 = true;}
//        if(OsMABar2 < OsMABar1)  {BuySignal3  = true;}
      }
    else
      {
    	  SellSignal3=true;
        BuySignal3 =true;
      }


    //=====================SIGNAL4========================  
    
       double diverge;
       bool BuySignal4=false,SellSignal4=false;
       
       diverge = Z_S4_Divergence(P_Fast_Period, P_Slow_Period, P_Fast_Price, P_Slow_Price,0);
    
    if(U_UseSig4)
      {
        if(diverge >= P_DVBuySell && diverge <= P_DVStayOut)
          {BuySignal4  = true;}
        if(diverge <= (P_DVBuySell*(-1)) && diverge >= (P_DVStayOut*(-1)))
          {SellSignal4 = true;}
      }
    else
      {
        SellSignal4=true;
        BuySignal4 =true;
      }

        
    //=====================SIGNAL5=======================  
    
    bool BuySignal5=false, SellSignal5=false;
    
    if(U_UseSig5)
      {
        int iHour=TimeHour(LocalTime());
        int ValidTradeTime = Z_S5_ValidTradeTime(iHour);

        if(ValidTradeTime==true)
          {
            BuySignal5 =true;
            SellSignal5=true;
          }
      }
    else
      {
    	  SellSignal5 =true;
         BuySignal5 =true;
      }

    //== Signal Setter =======================  

    // All 5 Sells signals or All 5 Buy signals are needed to have any signal at all
    
    if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) && (SellSignal5==true)) return(1);  
    if((BuySignal1==true)  && (BuySignal2==true)  && (BuySignal3==true)  && (BuySignal4==true)  && (BuySignal5==true))  return(2);
    return(0);
  }

//+------------------------------------------------------------------+
//| START Function Diverge                                           |
//+------------------------------------------------------------------+

double Z_S4_Divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
    double maF2, maS2;

    maF2 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
    maS2 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos + 1);

    return(maF2-maS2);
  }



//+------------------------------------------------------------------+
//| START Function Valid Trade Time                                  |
//+------------------------------------------------------------------+
bool Z_S5_ValidTradeTime (int iHour)
   {
      if(((iHour >= U_T1From) && (iHour <= (U_T1Until-1)))||((iHour>= U_T2From) && (iHour <= (U_T2Until-1)))||((iHour >= U_T3From)&& (iHour <= (U_T3Until-1)))||((iHour >= U_T4From) && (iHour <=(U_T4Until-1))))
      {
         return (true);
      }
      else
         return (false);
   }  

