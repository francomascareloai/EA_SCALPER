//+------------------------------------------------------------------+
//|                                                                  |
//|   v 4.4.5                                                        |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+


extern bool Jaipong = TRUE;
extern bool Keroncong = TRUE;
extern bool Tortor = TRUE;
 bool OrdersSideOptimize = TRUE;
 int MinGridLevelForEnable_Strategy_3 = 9999;

extern bool  MA_Keroncong = FALSE;
extern int Period_MA = PERIOD_H1;
 int Delay_Jaipong = PERIOD_M1;
 int Delay_Keroncong = PERIOD_M1;
 int Delay_Tortor = PERIOD_M1;

 bool StopTradeAfterTP_Jaipong = FALSE;
 bool StopTradeAfterTP_Keroncong = FALSE;
 bool StopTradeAfterTP_Tortor = FALSE;

int Period = 60;

 double LossLimit_Jaipong = -1000000.0;
 double LossLimit_Keroncong = -1000000.0;
 double LossLimit_Tortor = -1000000.0;

extern int MaxTrades_Jaipong = 12;
extern int MaxTrades_Keroncong = 12;
extern int MaxTrades_Tortor = 12;

 bool Auto_MagicNumber = FALSE;
extern int MagicNumber_Jaipong = 11111;
extern int MagicNumber_Keroncong = 22222;
extern int MagicNumber_Tortor = 33333;


/// -------------------------------------------  Trio Total  --------------------  
double Jai_lot, Jai;
double Ker_lot, Ker;
double Tor_lot, Tor; 

double max_loss_J=0;
double max_loss_K=0;
double max_loss_T=0;

int J, K, T;

string a, b, c;
string posJ, posK, posT;

int J_r = 0; 
int K_r = 0;
int T_r = 0;

double Jai_r=0;
double Ker_r=0;
double Tor_r=0;

/// -------------------------------------------  Trio Total  -------------------- end


int Gi_108 = 2;
extern double MaxLots = 5.0;
 bool MM = FALSE;
 bool UseEquityStop = FALSE;
 double TotalEquityRisk = 20.0;
extern string t2 = "Time Setting";
extern bool CloseFriday = TRUE;
extern int CloseFridayHour = 17;
extern bool OpenMondey = TRUE;
extern int OpenMondeyHour = 3;
 bool       UseTimer =            FALSE;
 int        StartHour =          1;
 int        StopHour =           6;
extern string ____Urdala_News_Investing_____ = "----------Urdala_News_Investing----------";
extern bool AvoidNews = true;
 int UTimeDo =61;
 int UTimePosle = 61;
 int Uoffset = 3;
 bool Vhigh = true;
 bool Vmedium = false;
 bool Vlow = false;
extern string t3 = "Setting for Dancing Jaipong";
bool Gi_220 = FALSE;
double Gd_224 = 48.0;
extern bool UseTrailingStop_Jaipong = FALSE;
double G_pips_236 = 500.0;
extern double TrailingStart_Jaipong = 10.0;
extern double TrailingStop_Jaipong = 5.0;
extern double Step_Jaipong = 30.0;
extern double Slippage_Jaipong = 3.0;
double G_price_280;
double Gd_288;
double Gd_unused_296;
double Gd_unused_304;
double G_price_312;
double G_bid_320;
double G_ask_328;
double Gd_336;
double Gd_344;
bool Gi_360;
string Gs_364 = "Dancing Jaipong";
int Gi_372 = 0;
int Gi_376;
int Gi_380 = 0;
double Lot_Jaipong;
int G_pos_392 = 0;
int OrdersCount1;
double Gd_400 = 0.0;
bool Gi_408 = FALSE;
bool Gi_412 = FALSE;
bool Gi_416 = FALSE;
int Gi_420;
bool Gi_424 = FALSE;
double Gd_428;
double Gd_436;
extern string t4 = "Setting for Dancing Keroncong";
extern bool UseTrailingStop_Keroncong = FALSE;
double G_pips_508 = 500.0;
extern double TrailingStart_Keroncong = 10.0;
extern double TrailingStop_Keroncong = 5.0;
extern double Step_Keroncong = 30.0;
bool Gi_532 = FALSE;
double Gd_536 = 48.0;
extern double Slippage_Keroncong = 3.0;
double G_price_564;
double Gd_572;
double G_price_596;
double G_bid_604;
double G_ask_612;
double Gd_620;
double Gd_628;
double Gd_636;
bool Gi_644;
string Gs_648 = "Dancing Keroncong";
int Gi_656 = 0;
int Gi_660;
int Gi_664 = 0;
double Lot_Keroncong;
int G_pos_676 = 0;
int OrdersCount2;
double Gd_684 = 0.0;
bool Gi_692 = FALSE;
bool Gi_696 = FALSE;
bool Gi_700 = FALSE;
int Gi_704;
bool Gi_708 = FALSE;
double Gd_712;
double Gd_720;
int G_datetime_728 = 1;
extern string t5 = "Setting for Dancing Tortor";
extern bool UseTrailingStop_Tortor = FALSE;
double G_pips_792 = 500.0;
extern double TrailingStart_Tortor = 100.0;
extern double TrailingStop_Tortor = 50.0;
bool Gi_816 = FALSE;
double Gd_820 = 48.0;
extern double Step_Tortor = 300.0;
extern double Slippage_Tortor = 3.0;
double G_price_848;
double Gd_856;
double Gd_unused_864;
double Gd_unused_872;
double G_price_880;
double G_bid_888;
double G_ask_896;
double Gd_904;
double Gd_912;
double Gd_920;
bool Gi_928;
string Gs_932 = "Dancing Tortor";
int Gi_940 = 0;
int Gi_944;
int Gi_948 = 0;
double Lot_Tortor;
int G_pos_960 = 0;
int OrdersCount3;
double Gd_968 = 0.0;
bool Gi_976 = FALSE;
bool Gi_980 = FALSE;
bool Gi_984 = FALSE;
int Gi_988;
bool Gi_992 = FALSE;
double Gd_996;
double Gd_1004;
int G_datetime_1012 = 1;
int Jaipong_Datetime = 1;
bool G_corner_1052 = TRUE;
int Gi_1056 = 0;
int Gi_1060 = 10;
int G_window_1064 = 0;
bool Gi_1068 = TRUE;
bool Gi_unused_1072 = TRUE;
bool Gi_1076 = FALSE;
int G_color_1080 = Gray;
int G_color_1084 = Gray;
int G_color_1088 = Gray;
int G_color_1092 = DarkOrange;
int Gi_unused_1096 = 36095;
int G_color_1100 = Lime;
int G_color_1104 = OrangeRed;
int Gi_1108 = 65280;
int Gi_1112 = 17919;
int G_color_1116 = Lime;
int G_color_1120 = Red;
int G_color_1124 = Orange;
int G_period_1128 = 8;
int G_period_1132 = 17;
int G_period_1136 = 9;
int G_applied_price_1140 = PRICE_CLOSE;
int G_color_1144 = Lime;
int G_color_1148 = Tomato;
int G_color_1152 = Green;
int G_color_1156 = Red;
int G_period_1176 = 9;
int G_applied_price_1180 = PRICE_CLOSE;
int G_period_1192 = 13;
int G_applied_price_1196 = PRICE_CLOSE;
int G_period_1208 = 5;
int G_period_1212 = 3;
int G_slowing_1216 = 3;
int G_ma_method_1220 = MODE_EMA;
int G_color_1232 = Lime;
int G_color_1236 = Red;
int G_color_1240 = Orange;
int G_period_1252 = 5;
int G_period_1256 = 9;
int G_ma_method_1260 = MODE_EMA;
int G_applied_price_1264 = PRICE_CLOSE;
int G_color_1276 = Lime;
int G_color_1280 = Red;
string Gs_dummy_1292;
string G_text_1464;
string G_text_1472;
bool Gi_1480 = FALSE;//TRUE;
int Gi_1492;
int G_str2int_1496;
int G_str2int_1500;
int G_str2int_1504;
extern string T6 = "Lots settings";
extern double Lots = 0.01;
extern int BaseLotLevel = 3;
extern double LotExponent = 1.5;
extern string T7 = "Take profit settings";
 bool AutoGridStepAndProfit = false;
extern double TakeProfit = 50.0;
extern string T8 = "Additional distance settings";
extern double DistanceExponent = 1.1;
extern int BaseDistanceLevel = 3;
double PreviousMinute = -1.0;
int PreviousHour = -1;

int init()                                      
{
	if(Auto_MagicNumber == TRUE){
		if (Symbol()== "EURUSD"){ MagicNumber_Jaipong = 17777;
			MagicNumber_Keroncong = 18888;
		MagicNumber_Tortor = 19999; }
		
		if (Symbol()== "USDJPY"){ MagicNumber_Jaipong = 27777;
			MagicNumber_Keroncong = 28888;
		MagicNumber_Tortor = 29999; }
		
		if (Symbol()== "EURJPY"){ MagicNumber_Jaipong = 37777;
			MagicNumber_Keroncong = 38888;
		MagicNumber_Tortor = 39999; }
		
		if (Symbol()== "AUDUSD"){ MagicNumber_Jaipong = 47777;
			MagicNumber_Keroncong = 48888;
		MagicNumber_Tortor = 49999; }
		
	}
	
  if(!IsTesting())
	{
	News();
	}	
	return(0);                                      
} 


int start() {
	
	if(IsTesting())
	{
		if(PreviousMinute == Minute())
		{
			return(0);
		}
	PreviousMinute = Minute();
	}
	
	if(PreviousHour != Hour())
	{
	   PreviousHour = Hour();
	   if(!AutoGridStep())
	   {
	      ExpertRemove();
	   }
	}
	
	string Ls_unused_100;
	double ihigh_1128;
	double ilow_1136;
	double iclose_1144;
	double iclose_1152;
	double Lot1;
	double Lot2;
	double Ld_1256;
	int Li_1264;
	int count_1268;
	double Lot3;
	double Ld_1324;
	int Li_1332;
	int count_1336;
	
	
	color ColorJ=Lime;
	color ColorK=Lime;
	color ColorT=Lime;   
	
	Jai_lot=0; Jai=0; J=0;
	Ker_lot=0; Ker=0; K=0;
	Tor_lot=0; Tor=0; T=0;
	
	/// --------------------------------------------------------
	
	if ((StopTradeAfterTP_Jaipong == TRUE) && f0_4()==0 )  Jaipong = FALSE;
	if (StopTradeAfterTP_Keroncong == TRUE && f0_5()==0) Keroncong = FALSE;
	if (StopTradeAfterTP_Tortor == TRUE && f0_12()==0) Tortor = FALSE;
	
	double ww=iMA(NULL,Period_MA,29,0,MODE_LWMA,PRICE_CLOSE,1);
	
	if(!IsTesting())
	{
	if(f0_4() > 0) SetTakeProfit(MagicNumber_Jaipong,GetTakeProfit(f0_4())); 
	if(f0_5() > 0) SetTakeProfit(MagicNumber_Keroncong,GetTakeProfit(f0_5()));
	if(f0_12() > 0) SetTakeProfit(MagicNumber_Tortor,GetTakeProfit(f0_12()));
	}
	//--------------------------------------------   Jaipong  ----------------------
	if (Jaipong == TRUE) 
	{
		double LotExponent1 = LotExponent;
		int Li_1168 = Gi_108;
		bool bool_1180 = UseEquityStop;
		double Ld_1184 = TotalEquityRisk;
		if (MM == TRUE) 
		{
			if (MathCeil(AccountBalance()) < 2000.0) Lot1 = Lots;
			else Lot1 = 0.000005 * MathCeil(AccountBalance());
		}   else Lot1 = Lots;
		if (UseTrailingStop_Jaipong) f0_35(TrailingStart_Jaipong, TrailingStop_Jaipong, G_price_312);
		if (Gi_220)
		{
			if (TimeCurrent() >= Gi_376) {
				f0_24();
			Print("Closed All due_Hilo to TimeOut"); }
		}
		double Ld_1200 = f0_31();
		if (bool_1180) {
			if (Ld_1200 < 0.0 && MathAbs(Ld_1200) > Ld_1184 / 100.0 * f0_7()) {
				f0_24();
				Print("Closed All due_Hilo to Stop Out");
				Gi_424 = FALSE;
			}
		}
		OrdersCount1 = f0_4();
		double TakeProfit1 = GetTakeProfit(OrdersCount1);
		if(Gi_372 != Time[0])
		{
			if (OrdersCount1 == 0) Gi_360 = FALSE;
			for (G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
			{
				OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
					if (OrderType() == OP_BUY) {
						Gi_412 = TRUE;
						Gi_416 = FALSE;
						break;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
					if (OrderType() == OP_SELL) {
						Gi_412 = FALSE;
						Gi_416 = TRUE;
						break;
					}
				}
			}
			
			if (OrdersCount1 > 0 && OrdersCount1 <= MaxTrades_Jaipong) {
				LotExponent1 = GetLotExponent(OrdersCount1);
				double Step_Jaipong_ = 0.0;
				Step_Jaipong_ = GetDistance(OrdersCount1, 1);
				RefreshRates();
				Gd_336 = f0_32();
				Gd_344 = f0_20();
				if (Gi_412 && Gd_336 - Ask >= Step_Jaipong_ * Point) Gi_408 = TRUE;
				if (Gi_416 && Bid - Gd_344 >= Step_Jaipong_ * Point) Gi_408 = TRUE;
			}
			if (OrdersCount1 < 1) {
				Gi_416 = FALSE;
				Gi_412 = FALSE;
				Gi_408 = TRUE;
				Gd_288 = AccountEquity();
			}
			if (Gi_408) {
				Gd_336 = f0_32();
				Gd_344 = f0_20();
				if (Gi_416) {
					Gi_380 = OrdersCount1;
					Lot_Jaipong = NormalizeDouble(Lot1 * MathPow(LotExponent1, Gi_380-BaseLotLevel+1), Li_1168);  // определение последущего лота (x 1.5)
					Lot_Jaipong = CheckLotSize(Lot_Jaipong);
					RefreshRates();
					Gi_420 = f0_3(1, Lot_Jaipong, Bid, Slippage_Jaipong, Ask, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Jaipong, 0, HotPink);
					if (Gi_420 < 0) {
						Print("Error: ", GetLastError());
						return (0);
					}
					Gd_344 = f0_20();
					Gi_408 = FALSE;
					Gi_424 = TRUE;
					} else {
					if (Gi_412) {
						Gi_380 = OrdersCount1;
						Lot_Jaipong = NormalizeDouble(Lot1 * MathPow(LotExponent1, Gi_380-BaseLotLevel+1), Li_1168); // определение последущего лота (x 1.5)
						Lot_Jaipong = CheckLotSize(Lot_Jaipong);
						Gi_420 = f0_3(0, Lot_Jaipong, Ask, Slippage_Jaipong, Bid, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Jaipong, 0, HotPink );
						if (Gi_420 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_336 = f0_32();
						Gi_408 = FALSE;
						Gi_424 = TRUE;
					}
				}
			}
			Gi_372 = Time[0];
		}
		if ((OrdersCount1 < 1) && (Jaipong_Datetime != iTime(NULL, Delay_Jaipong, 0)))           // -------   / начало стратегии Jaipong
		{
			ihigh_1128 = iHigh(Symbol(), 0, 1);
			ilow_1136 = iLow(Symbol(), 0, 2);
			G_bid_320 = Bid;
			G_ask_328 = Ask;
				Gi_380 = OrdersCount1;
				Lot_Jaipong = NormalizeDouble(Lot1 * MathPow(LotExponent1, Gi_380), Li_1168);
				if (ihigh_1128 > ilow_1136) {
					if (iRSI(NULL, Period, 14, PRICE_CLOSE, 1) > 30.0 && OrdersSideOptimization(MagicNumber_Jaipong, -1) && !Weekend() && !News() && AllowTradeTime())
					{
						Gi_420 = f0_3(1, Lot_Jaipong, G_bid_320, Slippage_Jaipong, G_bid_320, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Jaipong, 0, HotPink );
						if (Gi_420 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_336 = f0_32();
						Gi_424 = TRUE;
						
					}
					} else {
					if (iRSI(NULL, Period, 14, PRICE_CLOSE, 1) < 70.0 && OrdersSideOptimization(MagicNumber_Jaipong, 1) && !Weekend() && !News() && AllowTradeTime()) {
						Gi_420 = f0_3(0, Lot_Jaipong, G_ask_328, Slippage_Jaipong, G_ask_328, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Jaipong, 0, HotPink );
						if (Gi_420 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_344 = f0_20();
						Gi_424 = TRUE;
					}
				}
				if (Gi_420 > 0) Gi_376 = TimeCurrent() + 60.0 * (60.0 * Gd_224);
				Gi_408 = FALSE;
				Jaipong_Datetime = iTime(NULL, Delay_Jaipong, 0);
		}
		OrdersCount1 = f0_4();
		G_price_312 = 0;
		double Ld_1208 = 0;
		for (G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--) {
			OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
			if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
				if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
					G_price_312 += OrderOpenPrice() * OrderLots();
					Ld_1208 += OrderLots();
				}
			}
		}
		if (OrdersCount1 > 0) G_price_312 = NormalizeDouble(G_price_312 / Ld_1208, Digits);
		if (Gi_424) {
			for (G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--) {
				OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
					if (OrderType() == OP_BUY) {
						G_price_280 = G_price_312 + TakeProfit1 * Point;
						Gd_unused_296 = G_price_280;
						Gd_400 = G_price_312 - G_pips_236 * Point;
						Gi_360 = TRUE;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
					if (OrderType() == OP_SELL) {
						G_price_280 = G_price_312 - TakeProfit1 * Point;
						Gd_unused_304 = G_price_280;
						Gd_400 = G_price_312 + G_pips_236 * Point;
						Gi_360 = TRUE;
					}
				}
			}
			
			
		}
		if (Gi_424) {
			if (Gi_360 == TRUE) {
				for (G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--) {
					OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
					if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
					if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) 
					OrderModify(OrderTicket(), G_price_312, OrderStopLoss(), G_price_280, 0, Yellow);
					Gi_424 = FALSE;
				}
			}
		}
	}
	
	// ----------------------------------------------   Keroncong  ---------------------
	if (Keroncong == TRUE) {
		double LotExponent2 = LotExponent;
		int Li_1224 = Gi_108;
		bool bool_1236 = UseEquityStop;
		double Ld_1240 = TotalEquityRisk;
		if (MM == TRUE) {
			if (MathCeil(AccountBalance()) < 2000.0) Lot2 = Lots;
			else Lot2 = 0.000005 * MathCeil(AccountBalance());
		} else Lot2 = Lots;
		if (UseTrailingStop_Keroncong) f0_21(TrailingStart_Keroncong, TrailingStop_Keroncong, G_price_596);
		
		
		////////----------------------------------------
		
		OrdersCount2 = f0_5();  /// кол-во открытых поз.
		double TakeProfit2 = GetTakeProfit(OrdersCount2);
		if (Gi_656 != Time[0]) {    /// Gi_656 = 0;
			Ld_1256 = f0_29();     /// f0_29() суммарный профит всех позиций
			if (bool_1236) {
				if (Ld_1256 < 0.0 && MathAbs(Ld_1256) > Ld_1240 / 100.0 * f0_16()) {
					f0_18();
					Print("Closed All due to Stop Out");
					Gi_708 = FALSE;
				}
			}
			if (OrdersCount2 == 0) Gi_644 = FALSE;
			for (G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--) {
				OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
					if (OrderType() == OP_BUY) {
						Gi_696 = TRUE;  ///////  BUY
						Gi_700 = FALSE;
						break;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
					if (OrderType() == OP_SELL) {
						Gi_696 = FALSE; 
						Gi_700 = TRUE;  ////////// SELL
						break;
					}
				}
			}
			if (OrdersCount2 > 0 && OrdersCount2 <= MaxTrades_Keroncong) {
				LotExponent2 = GetLotExponent(OrdersCount2);
				double Step_Keroncong_ = 0.0; 
				Step_Keroncong_ = GetDistance(OrdersCount2, 2);
				RefreshRates();
				Gd_620 = f0_36();
				Gd_628 = f0_28();
				if (Gi_696 && Gd_620 - Ask >= Step_Keroncong_ * Point) Gi_692 = TRUE;
				if (Gi_700 && Bid - Gd_628 >= Step_Keroncong_ * Point) Gi_692 = TRUE;
			}
			if (OrdersCount2 < 1) {   // кол-во открытых поз.
				Gi_700 = FALSE;
				Gi_696 = FALSE;
				Gi_692 = TRUE;
				Gd_572 = AccountEquity();
			}
			if (Gi_692) {          ///если да, то продолжаем расти сетку
				Gd_620 = f0_36();
				Gd_628 = f0_28();
				if (Gi_700) {   /// если есть SELL
					Gi_664 = OrdersCount2;/// кол-во открытых поз.
					Lot_Keroncong = NormalizeDouble(Lot2 * MathPow(LotExponent2, Gi_664-BaseLotLevel+1), Li_1224);
					Lot_Keroncong = CheckLotSize(Lot_Keroncong);
					RefreshRates();
					Gi_704 = f0_2(1, Lot_Keroncong, Bid, Slippage_Keroncong, Ask, 0, 0, Gs_648 + "-" + Gi_664, MagicNumber_Keroncong, 0, Lime);
					if (Gi_704 < 0) {
						Print("Error: ", GetLastError());
						return (0);
					}
					Gd_628 = f0_28();
					Gi_692 = FALSE;
					Gi_708 = TRUE;
					} else {
					if (Gi_696) {        /// если есть BUY
						Gi_664 = OrdersCount2; /// кол-во открытых поз.
						Lot_Keroncong = NormalizeDouble(Lot2 * MathPow(LotExponent2, Gi_664-BaseLotLevel+1), Li_1224);
						Lot_Keroncong = CheckLotSize(Lot_Keroncong);
						Gi_704 = f0_2(0, Lot_Keroncong, Ask, Slippage_Keroncong, Bid, 0, 0, Gs_648 + "-" + Gi_664, MagicNumber_Keroncong, 0, Lime);
						if (Gi_704 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_620 = f0_36();
						Gi_692 = FALSE;
						Gi_708 = TRUE;
					}
				}
			}
			Gi_656 = Time[0];
		}
		
		////                                        ОТКРЫТИЕ ПОЗ.
		/////////////// -------------------------------------------------------
		if (G_datetime_728 != iTime(NULL, Delay_Keroncong, 0)) {
			Li_1264 = OrdersTotal();
			count_1268 = 0;
			for (int Li_1272 = Li_1264; Li_1272 >= 1; Li_1272--) {
				OrderSelect(Li_1272 - 1, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) count_1268++;
			}
			if (Li_1264 == 0 || count_1268 < 1)
			{
				iclose_1144 = iClose(Symbol(), 0, 2);
				iclose_1152 = iClose(Symbol(), 0, 1);
				G_bid_604 = Bid;
				G_ask_612 = Ask;
				Gi_664 = OrdersCount2;
				Lot_Keroncong = Lot2;
				if (iclose_1144 > iclose_1152 ) {  //sell
					if((MA_Keroncong == FALSE || iclose_1152 < ww) && OrdersSideOptimization(MagicNumber_Keroncong, -1) && !Weekend() && !News() && AllowTradeTime()){
						Gi_704 = f0_2(1, Lot_Keroncong, G_bid_604, Slippage_Keroncong, G_bid_604, 0, 0, Gs_648 + "-" + Gi_664, MagicNumber_Keroncong, 0, Lime);
						if (Gi_704 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_620 = f0_36();
					Gi_708 = TRUE;}}
					else {  //buy
						if((MA_Keroncong == FALSE || iclose_1152 > ww) && OrdersSideOptimization(MagicNumber_Keroncong, 1) && !Weekend() && !News() && AllowTradeTime()){
							Gi_704 = f0_2(0, Lot_Keroncong, G_ask_612, Slippage_Keroncong, G_ask_612, 0, 0, Gs_648 + "-" + Gi_664, MagicNumber_Keroncong, 0, Lime);
							if (Gi_704 < 0) {
								Print("Error: ", GetLastError());
								return (0);
							}
							Gd_628 = f0_28();
							Gi_708 = TRUE;
						}}
						if (Gi_704 > 0) Gi_660 = TimeCurrent() + 60.0 * (60.0 * Gd_536);
						Gi_692 = FALSE;
						
			}
			G_datetime_728 = iTime(NULL, Delay_Keroncong, 0);
		}
		
		
		/////// -------------------------------------------------------------
		
		OrdersCount2 = f0_5();
		G_price_596 = 0;
		double Ld_1276 = 0;
		for (G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--) {
			OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
			if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
				if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
					G_price_596 += OrderOpenPrice() * OrderLots();
					Ld_1276 += OrderLots();
				}
			}
		}
		
		if (OrdersCount2 > 0) G_price_596 = NormalizeDouble(G_price_596 / Ld_1276, Digits);
		if (Gi_708) {
			for (G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--) {
				OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
					if (OrderType() == OP_BUY) {
						G_price_564 = G_price_596 + TakeProfit2 * Point;
						Gd_684 = G_price_596 - G_pips_508 * Point;
						Gi_644 = TRUE;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
					if (OrderType() == OP_SELL) {
						G_price_564 = G_price_596 - TakeProfit2 * Point;
						Gd_684 = G_price_596 + G_pips_508 * Point;
						Gi_644 = TRUE;
					}
				}
			}
		}
		if (Gi_708) {
			if (Gi_644 == TRUE) {
				for (G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--) {
					OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
					if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
					if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) OrderModify(OrderTicket(), G_price_596, OrderStopLoss(), G_price_564, 0, Yellow);
					Gi_708 = FALSE;
				}
			}
		}
	} 
	
	// ----------------------------------------------   Tortor  --------------------- 
	
	if (Tortor == TRUE) {
		double LotExponent3 = LotExponent;
		int Li_1292 = Gi_108;
		bool bool_1304 = UseEquityStop;
		double Ld_1308 = TotalEquityRisk;
		if (MM == TRUE) {
			if (MathCeil(AccountBalance()) < 2000.0) Lot3 = Lots;
			else Lot3 = 0.000005 * MathCeil(AccountBalance());
		} else Lot3 = Lots;
		if (UseTrailingStop_Tortor) f0_34(TrailingStart_Tortor, TrailingStop_Tortor, G_price_880);
		if (Gi_816) {
			if (TimeCurrent() >= Gi_944) {
				f0_0();
				Print("Closed All due to TimeOut");
			}
		}
		OrdersCount3 = f0_12();
		double TakeProfit3 = GetTakeProfit(OrdersCount3);
		if (Gi_940 != Time[0]) {
			Ld_1324 = f0_8();
			if (bool_1304)
			{
				if (Ld_1324 < 0.0 && MathAbs(Ld_1324) > Ld_1308 / 100.0 * f0_30())
				{
					f0_0();
					Print("Closed All due to Stop Out");
					Gi_992 = FALSE;
				}
			}
			if (OrdersCount3 == 0) Gi_928 = FALSE;
			for (G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--) {
				OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
					if (OrderType() == OP_BUY) {
						Gi_980 = TRUE;
						Gi_984 = FALSE;
						break;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
					if (OrderType() == OP_SELL) {
						Gi_980 = FALSE;
						Gi_984 = TRUE;
						break;
					}
				}
			}
			if (OrdersCount3 > 0 && OrdersCount3 <= MaxTrades_Tortor) {
				LotExponent3 = GetLotExponent(OrdersCount3);
				double Step_Tortor_ = 0.0; 
				Step_Tortor_ = GetDistance(OrdersCount3, 3);
				RefreshRates();
				Gd_904 = f0_17();
				Gd_912 = f0_27();
				if (Gi_980 && Gd_904 - Ask >= Step_Tortor_ * Point) Gi_976 = TRUE;
				if (Gi_984 && Bid - Gd_912 >= Step_Tortor_ * Point) Gi_976 = TRUE;
			}
			if (OrdersCount3 < 1) {
				Gi_984 = FALSE;
				Gi_980 = FALSE;
				Gd_856 = AccountEquity();
			}
			if (Gi_976) {
				Gd_904 = f0_17();
				Gd_912 = f0_27();
				if (Gi_984) {
					Gi_948 = OrdersCount3;
					Lot_Tortor = NormalizeDouble(Lot3 * MathPow(LotExponent3, Gi_948-BaseLotLevel+1), Li_1292);
					Lot_Tortor = CheckLotSize(Lot_Tortor);
					RefreshRates();
					Gi_988 = f0_6(1, Lot_Tortor, Bid, Slippage_Tortor, Ask, 0, 0, Gs_932 + "-" + Gi_948, MagicNumber_Tortor, 0, Black);
					if (Gi_988 < 0) {
						Print("Error: ", GetLastError());
						return (0);
					}
					Gd_912 = f0_27();
					Gi_976 = FALSE;
					Gi_992 = TRUE;
					} else {
					if (Gi_980) {
						Gi_948 = OrdersCount3;
						Lot_Tortor = NormalizeDouble(Lot3 * MathPow(LotExponent3, Gi_948-BaseLotLevel+1), Li_1292);
						Lot_Tortor = CheckLotSize(Lot_Tortor);
						Gi_988 = f0_6(0, Lot_Tortor, Ask, Slippage_Tortor, Bid, 0, 0, Gs_932 + "-" + Gi_948, MagicNumber_Tortor, 0, Black);
						if (Gi_988 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_904 = f0_17();
						Gi_976 = FALSE;
						Gi_992 = TRUE;
					}
				}
			}
			Gi_940 = Time[0];
		}
		if (G_datetime_1012 != iTime(NULL, Delay_Tortor, 0)) {
			Li_1332 = OrdersTotal();
			count_1336 = 0;
			for (int Li_1340 = Li_1332; Li_1340 >= 1; Li_1340--) {
				OrderSelect(Li_1340 - 1, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) count_1336++;
			}
			if (Li_1332 == 0 || count_1336 < 1) 
			{
				iclose_1144 = iClose(Symbol(), 0, 2);
				iclose_1152 = iClose(Symbol(), 0, 1);
				G_bid_888 = Bid;
				G_ask_896 = Ask;
				Gi_948 = OrdersCount3;
				Lot_Tortor = Lot3;
				if (iclose_1144 > iclose_1152) {
					if (iRSI(NULL, Period, 14, PRICE_CLOSE, 1) > 30.0 && OrdersSideOptimization(MagicNumber_Tortor, -1) && !Weekend() && !News() && AllowTradeTime()) {
						Gi_988 = f0_6(1, Lot_Tortor, G_bid_888, Slippage_Tortor, G_bid_888, 0, 0, Gs_932 + "-" + Gi_948, MagicNumber_Tortor, 0, Black);
						if (Gi_988 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_904 = f0_17();
						Gi_992 = TRUE; 
					}
					} else {
					if (iRSI(NULL, Period, 14, PRICE_CLOSE, 1) < 70.0 && OrdersSideOptimization(MagicNumber_Tortor, 1) && !Weekend() && !News() && AllowTradeTime()) {
						Gi_988 = f0_6(0, Lot_Tortor, G_ask_896, Slippage_Tortor, G_ask_896, 0, 0, Gs_932 + "-" + Gi_948, MagicNumber_Tortor, 0, Black);
						if (Gi_988 < 0) {
							Print("Error: ", GetLastError());
							return (0);
						}
						Gd_912 = f0_27();
						Gi_992 = TRUE;
					}
				}
				if (Gi_988 > 0) Gi_944 = TimeCurrent() + 60.0 * (60.0 * Gd_820);
				Gi_976 = FALSE;
				
			}
			G_datetime_1012 = iTime(NULL, Delay_Tortor, 0);
		}
		OrdersCount3 = f0_12();
		G_price_880 = 0;
		double Ld_1344 = 0;
		for (G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--) {
			OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
			if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
				if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
					G_price_880 += OrderOpenPrice() * OrderLots();
					Ld_1344 += OrderLots();
				}
			}
		}
		if (OrdersCount3 > 0) G_price_880 = NormalizeDouble(G_price_880 / Ld_1344, Digits);
		if (Gi_992) {
			for (G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--) {
				OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
					if (OrderType() == OP_BUY) {
						G_price_848 = G_price_880 + TakeProfit3 * Point;
						Gd_unused_864 = G_price_848;
						Gd_968 = G_price_880 - G_pips_792 * Point;
						Gi_928 = TRUE;
					}
				}
				if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
					if (OrderType() == OP_SELL) {
						G_price_848 = G_price_880 - TakeProfit3 * Point;
						Gd_unused_872 = G_price_848;
						Gd_968 = G_price_880 + G_pips_792 * Point;
						Gi_928 = TRUE;
					}
				}
			}
		}
		if (Gi_992) {
			if (Gi_928 == TRUE) {
				for (G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--) {
					OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
					if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
					if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) OrderModify(OrderTicket(), G_price_880, OrderStopLoss(), G_price_848, 0, Yellow);
					Gi_992 = FALSE;
				}
			}
		}
	}
	
	/// -------------------------------------------  Trio Total  --------------------
	a = "Jaipong";
	b = "Keroncong";
	c = "Tortor";
	
	posJ = "Neutral";
	posK = "Neutral";
	posT = "Neutral";
	
	J = 0;
	K = 0;
	T = 0;
	
	Jai = 0.00;
	Ker	= 0.00;
	Tor = 0.00;
	
	Jai_lot = 0.00;
	Ker_lot = 0.00;
	Tor_lot = 0.00;
	
	if (OrdersTotal()>0)
	{
		
		for(int i=OrdersTotal()-1; i>=0; i--)
		
		{
			OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
			if(OrderSymbol()==Symbol()&& OrderMagicNumber()==MagicNumber_Jaipong)
			{ 
				if (OrderType()==0) posJ="Buy";
				else posJ="Sell";
				Jai_lot=Jai_lot + OrderLots();
				Jai=Jai + OrderProfit();      Jai_r=Jai;    if (Jai<max_loss_J) max_loss_J=Jai;
				J=J+1;                        J_r=J;
			}
			else if(OrderSymbol()==Symbol()&& OrderMagicNumber()==MagicNumber_Keroncong)
			{
				if (OrderType()==0) posK="Buy";
				else posK="Sell";
				Ker_lot=Ker_lot + OrderLots();
				Ker=Ker + OrderProfit();          if (Ker<max_loss_K) max_loss_K=Ker;
				K=K+1;   K_r=K; Ker_r=Ker;
			} 
			else if(OrderSymbol()==Symbol()&& OrderMagicNumber()==MagicNumber_Tortor)
			{ 
				if (OrderType()==0) posT="Buy";
				else posT="Sell";
				Tor_lot=Tor_lot + OrderLots();
				Tor=Tor + OrderProfit();         if (Tor<max_loss_T) max_loss_T=Tor;
				T=T+1;   T_r=T; Tor_r=Tor;
			}         
		}
		
		
		
		ObjectDelete("Total Jaipon");
		ObjectDelete("Total Keronc");
		ObjectDelete("Total Tortor");
		
		if (Jaipong == TRUE){  if(J>7) ColorJ=Red;
			ObjectCreate("Total Jaipon", OBJ_LABEL,0, 0, 0); 
			ObjectSet( "Total Jaipon",OBJPROP_CORNER, 2);
			ObjectSet( "Total Jaipon",OBJPROP_YDISTANCE, 50);
			ObjectSet( "Total Jaipon",OBJPROP_XDISTANCE, 5);  
		ObjectSetText("Total Jaipon", a + "      " +posJ+"  "+ IntegerToString(J)/* ск. колен */ + "    " + DoubleToStr(Jai, 2)/* profit*/ + "    " + DoubleToStr(Jai_lot, 2) + "   Max Loss "+ max_loss_J, 14, "Arial", ColorJ );}
		if (Keroncong == TRUE){    if(K>7) ColorK=Red;            
			ObjectCreate("Total Keronc", OBJ_LABEL,0, 0, 0); 
			ObjectSet( "Total Keronc",OBJPROP_CORNER, 2);
			ObjectSet( "Total Keronc",OBJPROP_YDISTANCE, 30);
			ObjectSet( "Total Keronc",OBJPROP_XDISTANCE, 5);  
		ObjectSetText("Total Keronc", b + " " +posK+"  " +IntegerToString(K) + "    " + DoubleToStr(Ker, 2) + "    " + DoubleToStr(Ker_lot, 2) + "   Max Loss "+ max_loss_K , 14, "Arial", ColorK ); }  
		if (Tortor == TRUE){    if(T>7) ColorT=Red;              
			ObjectCreate("Total Tortor", OBJ_LABEL,0, 0, 0); 
			ObjectSet( "Total Tortor",OBJPROP_CORNER, 2);
			ObjectSet( "Total Tortor",OBJPROP_YDISTANCE, 10);
			ObjectSet( "Total Tortor",OBJPROP_XDISTANCE, 5);  
		ObjectSetText("Total Tortor", c + "         " +posT+"   "+ IntegerToString(T) + "    " + DoubleToStr(Tor, 2) + "    " + DoubleToStr(Tor_lot, 2)+ "   Max Loss "+ max_loss_T, 14, "Arial", ColorT ); }   
	}
	
	if(News())
	{
		string NewsStatus = "YES";
	}
	else
	{
		NewsStatus = "NO";
	}
	
	if(Weekend())
	{
		string WeekendStatus = "YES";
	}
	else
	{
		WeekendStatus = "NO";
	}
	
	if(AllowTradeTime())
	{
		string AllowTradeTimeStatus = "YES";
	}
	else
	{
		AllowTradeTimeStatus = "NO";
	}
	
	Comment(
 "\n\n News: "+NewsStatus
 +"\n Weekend: "+WeekendStatus
 +"\n AllowTradeTime: "+AllowTradeTimeStatus
 +"\n\nStep Jaipong : "+Step_Jaipong
 +"\nStep Keroncong : "+Step_Keroncong
 +"\nStep Tortor : "+Step_Tortor
 +"\n\nTake Profit : "+TakeProfit
	);
	
	
	/// ------------------------  Over loss close  --------------    
	
	if(max_loss_J < LossLimit_Jaipong) //&& J>MaxTrades_Jaipong)
	{
		f0_24();
		Print("Maximum Loss Jaipong was -",max_loss_J);
		max_loss_J=0;
		Print("Closed All Jaipong due Over Limit");
	}
	if(max_loss_K < LossLimit_Keroncong) //&& K>MaxTrades_Keroncong)
	{
		f0_18();
		Print("Maximum Loss Keroncong was -",max_loss_K);
		max_loss_K=0;
		Print("Closed All Keroncong due Over Limit");
	}
	if(max_loss_T < LossLimit_Tortor) //&& T>MaxTrades_Tortor)
	{
		f0_0();
		Print("Maximum Loss Tortor was -",max_loss_T);
		max_loss_T=0;
		Print("Closed All Tortor due Over Limit");
	}
	
	return (0);
}

// ------------------------  end all programm int start()  ---------------------



int f0_4() {                 //подсчёт открытых поз. Jaipong
	int count_0 = 0;
	for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
		OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong)
		if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
	}
	return (count_0);
}

void f0_24() {           //закрытие всех Jaipong
	
	for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
		OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() == Symbol()) {
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong) {
				if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Slippage_Jaipong, Blue);
				if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Slippage_Jaipong, Red);
			}
			Sleep(1000);
		}
	}
}

//              открытие позиций Jaipong

int f0_3(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
	int ticket_60 = 0;
	int error_64 = 0;
	int count_68 = 0;
	int Li_72 = 100;
	switch (Ai_0) {
		case 2:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_22(Ad_24, Ai_32), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(1000);
		}
		break;
		case 4:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_22(Ad_24, Ai_32), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 0:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			RefreshRates();
			ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_22(Bid, Ai_32), f0_19(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("jaipong.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 3:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, Ai_32), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 5:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, Ai_32), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 1:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_11(Ask, Ai_32), f0_1(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("jaipong.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
	}
	return (ticket_60);
}

// ABBF0924C7D109476997F144FF69BA18
double f0_22(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// 65324E009A83B2CB88BFB3D4529CFA3F
double f0_11(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// A4B319A5A3851A7BB5CE0B195DF27F55
double f0_19(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// 0CCFFE5E259E6D9684C883601327DD0E
double f0_1(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// подсчёт профита 
double f0_31() {
	double Ld_ret_0 = 0;
	for (G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--) {
		OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong)
		if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
	}
	return (Ld_ret_0);
}

//                               ----------------------    замена StopLoss  -------------
void f0_35(int Ai_0, int Ai_4, double A_price_8) {
	int Li_16;
	double order_stoploss_20;
	double price_28;
	if (Ai_4 != 0) {
		for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
			if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
				if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Jaipong) {
					if (OrderType() == OP_BUY) {
						Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Bid - Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
					}
					if (OrderType() == OP_SELL) {
						Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Ask + Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
					}
				}
				Sleep(1000);
			}
		}
	}
}

//            ------------------------   Баланс -----------
double f0_7() {
	if (f0_4() == 0) Gd_428 = AccountEquity();
	if (Gd_428 < Gd_436) Gd_428 = Gd_436;
	else Gd_428 = AccountEquity();
	Gd_436 = AccountEquity();
	return (Gd_428);
}

//                           ------------   
double f0_32() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong && OrderType() == OP_BUY) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

// A5F3F48E555BFC9A5526CC1B30FF0AB2
double f0_20() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Jaipong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong && OrderType() == OP_SELL) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

// 22F0FA52408CE450B63ADF3F087F21DE
int f0_5() {
	int count_0 = 0;
	for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
		OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong)
		if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
	}
	return (count_0);
}

// A180C6ED0DC34AACA6CCA8CB05FECC10
void f0_18() {
	for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
		OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() == Symbol()) {
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong) {
				if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Slippage_Keroncong, Blue);
				if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Slippage_Keroncong, Red);
			}
			Sleep(1000);
		}
	}
}

// 114DC2E883BB39B95234C711A240BE3E
int f0_2(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
	int ticket_60 = 0;
	int error_64 = 0;
	int count_68 = 0;
	int Li_72 = 100;
	switch (Ai_0) {
		case 2:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_13(Ad_24, Ai_32), f0_25(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(1000);
		}
		break;
		case 4:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_13(Ad_24, Ai_32), f0_25(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 0:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			RefreshRates();
			ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_13(Bid, Ai_32), f0_25(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("keroncong.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 3:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_33(Ad_24, Ai_32), f0_26(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 5:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_33(Ad_24, Ai_32), f0_26(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 1:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_33(Ask, Ai_32), f0_26(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("keroncong.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
	}
	return (ticket_60);
}

// 7AE15E889172CCCB33ECFB32124CDF19
double f0_13(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// E29638E1934BE380D2D902E838F29BF7
double f0_33(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// BCF3A4C4831B7913DD5F18AF706ADC75
double f0_25(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// C4C44C724F3DAE9C33262735893D433A
double f0_26(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// D3C476201B00C1A782FB71A65C106452
double f0_29() {
	double Ld_ret_0 = 0;
	for (G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--) {
		OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong)
		if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
	}
	return (Ld_ret_0);
}

// A84D2ACC80FE890D5547A65D5C3D18EE
void f0_21(int Ai_0, int Ai_4, double A_price_8) {
	int Li_16;
	double order_stoploss_20;
	double price_28;
	if (Ai_4 != 0) {
		for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
			if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
				if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Keroncong) {
					if (OrderType() == OP_BUY) {
						Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Bid - Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
					}
					if (OrderType() == OP_SELL) {
						Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Ask + Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
					}
				}
				Sleep(1000);
			}
		}
	}
}

// 9EB62284E5C15187BCA5B502C66B6C59
double f0_16() {
	if (f0_5() == 0) Gd_712 = AccountEquity();
	if (Gd_712 < Gd_720) Gd_712 = Gd_720;
	else Gd_712 = AccountEquity();
	Gd_720 = AccountEquity();
	return (Gd_712);
}

// F66F194C04A03CB5E74EC2A8C1DD0537
double f0_36() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong && OrderType() == OP_BUY) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

// C8E1186288BBCE29FD09990000128B35
double f0_28() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Keroncong) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong && OrderType() == OP_SELL) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

// 6EF0698100DD80AB6B7953B95E5FAD5C
int f0_12() {
	int count_0 = 0;
	for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
		OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor)
		if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
	}
	return (count_0);
}

// 065CE9405D7D7C2EAE70F2FF0F5A8147
void f0_0() {
	for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
		OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() == Symbol()) {
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor) {
				if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Slippage_Tortor, Blue);
				if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Slippage_Tortor, Red);
			}
			Sleep(1000);
		}
	}
}

// 25977731C5753DECF295DA11C4378DE5
int f0_6(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
	int ticket_60 = 0;
	int error_64 = 0;
	int count_68 = 0;
	int Li_72 = 100;
	switch (Ai_0) {
		case 2:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, Ai_32), f0_9(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(1000);
		}
		break;
		case 4:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, Ai_32), f0_9(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 0:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			RefreshRates();
			ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_14(Bid, Ai_32), f0_9(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("tortor.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 3:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_23(Ad_24, Ai_32), f0_10(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 5:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_23(Ad_24, Ai_32), f0_10(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
			A_color_56);
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
		break;
		case 1:
		for (count_68 = 0; count_68 < Li_72; count_68++) {
			ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_23(Ask, Ai_32), f0_10(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
			PlaySound("tortor.wav");
			error_64 = GetLastError();
			if (error_64 == 0/* NO_ERROR */) break;
			if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
			Sleep(5000);
		}
	}
	return (ticket_60);
}

// 87D810BEA6B0AD2FCF70C69C17E19362
double f0_14(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// B3477275C69E607F97F2840B12AE4A9F
double f0_23(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// 37FA8C95BB37E55BB52283CC69099A5F
double f0_9(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 + Ai_8 * Point);
}

// 5EF05A0BDFEED3445F4FE51BA1977B3C
double f0_10(double Ad_0, int Ai_8) {
	if (Ai_8 == 0) return (0);
	return (Ad_0 - Ai_8 * Point);
}

// 31C5A9E59B9C6E81AE342B735890CD44
double f0_8() {
	double Ld_ret_0 = 0;
	for (G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--) {
		OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor)
		if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
	}
	return (Ld_ret_0);
}

// ED2502136334FB187FF67433121886AF
void f0_34(int Ai_0, int Ai_4, double A_price_8) {
	int Li_16;
	double order_stoploss_20;
	double price_28;
	if (Ai_4 != 0) {
		for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
			if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
				if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
				if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Tortor) {
					if (OrderType() == OP_BUY) {
						Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Bid - Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
					}
					if (OrderType() == OP_SELL) {
						Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
						if (Li_16 < Ai_0) continue;
						order_stoploss_20 = OrderStopLoss();
						price_28 = Ask + Ai_4 * Point;
						if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
					}
				}
				Sleep(1000);
			}
		}
	}
}

// DED4C3E9893A50A6B8A9A57E1BCD0548
double f0_30() {
	if (f0_12() == 0) Gd_996 = AccountEquity();
	if (Gd_996 < Gd_1004) Gd_996 = Gd_1004;
	else Gd_996 = AccountEquity();
	Gd_1004 = AccountEquity();
	return (Gd_996);
}

// 9FC0A73FE3F286FD086830C3094E8AB3
double f0_17() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor && OrderType() == OP_BUY) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

// C55A286500E20535F02887DCF6EFC3C6
double f0_27() {
	double order_open_price_0;
	int ticket_8;
	double Ld_unused_12 = 0;
	int ticket_20 = 0;
	for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
		OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Tortor) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor && OrderType() == OP_SELL) {
			ticket_8 = OrderTicket();
			if (ticket_8 > ticket_20) {
				order_open_price_0 = OrderOpenPrice();
				Ld_unused_12 = order_open_price_0;
				ticket_20 = ticket_8;
			}
		}
	}
	return (order_open_price_0);
}

double GetTakeProfit(int GridLevel)
{
	double Profit;
	
	switch(GridLevel)
	{
		case 0: Profit = TakeProfit; break;
		default: Profit = TakeProfit; break;
	}
	
	return NormalizeDouble(Profit,2); 
}

double GetLotExponent(int GridLevel)
{
	
	double Exponent;
	
	if(GridLevel < BaseLotLevel)
	{
		Exponent = 1;
	}
	else
	{
		Exponent = LotExponent;
	}
	
	return(Exponent);
	
}

bool AllowTradeTime(){
	if((UseTimer==TRUE && Hour() >= StartHour && Hour() <= StopHour) || UseTimer==FALSE)
	{
		return true;
	}
	else
	{
		return false;
	}
}

double CheckLotSize(double Lot)
{
	if(Lot > MaxLots)
	{
		Lot = MaxLots;
	}
	return Lot;
}

double GetDistance(int GridLevel, int StrategyNumber)
{
	
	double Distance;
	double Exponent;
	GridLevel++;
	
	if(GridLevel <= BaseDistanceLevel)
	{
		Exponent = 1;
	}
	else
	{
		Exponent = DistanceExponent;
	}
	
	switch(StrategyNumber)
	{
		case 1 : Distance = NormalizeDouble(Step_Jaipong * MathPow(Exponent, (GridLevel-BaseDistanceLevel)), 1); break;
		
		case 2 : Distance = NormalizeDouble(Step_Keroncong * MathPow(Exponent, (GridLevel-BaseDistanceLevel)), 1); break;
		
		case 3 : Distance = NormalizeDouble(Step_Tortor * MathPow(Exponent, (GridLevel-BaseDistanceLevel)), 1); break;
	}
	
	return(Distance);
	
}

bool OrdersSideOptimization(int Magic, int Side)
{
	
	if(!OrdersSideOptimize)
	{
		return(true);
	}
	
	int JaipongSide = 0;
	int KeroncongSide = 0;
	int TortorSide = 0;
	
	double JaipongLots = 0.0;
	double KeroncongLots = 0.0;
	double TortorLots = 0.0;
	
	int JaipongTotalOrders = 0;
	int KeroncongTotalOrders = 0;
	int TortorTotalOrders = 0;
	
	int MinOrders = MinGridLevelForEnable_Strategy_3;
	
	for (int i = OrdersTotal() - 1; i >= 0; i--) 
	{
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol() || (OrderMagicNumber() != MagicNumber_Jaipong && OrderMagicNumber() != MagicNumber_Keroncong && OrderMagicNumber() != MagicNumber_Tortor)) continue;
		//Jaipong
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong && OrderType() == OP_BUY) 
		{
			JaipongLots += OrderLots();
			JaipongSide = 1;
			JaipongTotalOrders++;
		}
		else if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Jaipong && OrderType() == OP_SELL) 
		{
			JaipongLots += OrderLots();
			JaipongSide = -1;
			JaipongTotalOrders++;
		}
		//Keroncong
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong && OrderType() == OP_BUY) 
		{
			KeroncongLots += OrderLots();
			KeroncongSide = 1;
			KeroncongTotalOrders++;
		}
		else if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Keroncong && OrderType() == OP_SELL) 
		{
			KeroncongLots += OrderLots();
			KeroncongSide = -1;
			KeroncongTotalOrders++;
		}
		//Tortor
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor && OrderType() == OP_BUY) 
		{
			TortorLots += OrderLots();
			TortorSide = 1;
			TortorTotalOrders++;
		}
		else if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Tortor && OrderType() == OP_SELL) 
		{
			TortorLots += OrderLots();
			TortorSide = -1;
			TortorTotalOrders++;
		}
	}
	
	/*Comment(
		"\n JaipongLots: "+JaipongLots
		+"\n JaipongSide: "+JaipongSide
		+"\n JaipongTotalOrders: "+JaipongTotalOrders
		+"\n"
		+"\n KeroncongLots: "+KeroncongLots
		+"\n KeroncongSide: "+KeroncongSide
		+"\n KeroncongTotalOrders: "+KeroncongTotalOrders
		+"\n"
		+"\n TortorLots: "+TortorLots
		+"\n TortorSide: "+TortorSide
		+"\n TortorTotalOrders: "+TortorTotalOrders
		);
	*/
	
	if(JaipongSide == 0 && KeroncongSide == 0 && TortorSide == 0)
	{
		return(true);
	}
	
	//Jaipong
	if(Magic == MagicNumber_Jaipong)
	{
		if(Side == 1)
		{
			if((TortorSide == -1 && KeroncongSide == 0) || (KeroncongSide == -1 && TortorSide == 0))
			{
				return(true);
			}
			else if((TortorSide == 1 && KeroncongSide == -1 && TortorLots < KeroncongLots && KeroncongTotalOrders >= MinOrders) || (KeroncongSide == 1 && TortorSide == -1 && KeroncongLots < TortorLots && TortorTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Jaipong Strategy. Cant open BUY ORDER.");
				return(false);
			}
		}
		else if(Side == -1)
		{
			if((TortorSide == 1 && KeroncongSide == 0) || (KeroncongSide == 1 && TortorSide == 0))
			{
				return(true);
			}
			else if((TortorSide == -1 && KeroncongSide == 1 && TortorLots < KeroncongLots && KeroncongTotalOrders >= MinOrders) || (KeroncongSide == -1 && TortorSide == 1 && KeroncongLots < TortorLots && TortorTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Jaipong Strategy. Cant open SELL ORDER");
				return(false);
			}
		}
	}
	//Keroncong
	if(Magic == MagicNumber_Keroncong)
	{
		if(Side == 1)
		{
			if((JaipongSide == -1 && TortorSide == 0) || (TortorSide == -1 && JaipongSide == 0))
			{
				return(true);
			}
			else if((JaipongSide == 1 && TortorSide == -1 && JaipongLots < TortorLots && TortorTotalOrders >= MinOrders) || (TortorSide == 1 && JaipongSide == -1 && TortorLots < JaipongLots && JaipongTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Keroncong Strategy. Cant open BUY ORDER");
				return(false);
			}
		}
		else if(Side == -1)
		{
			if((JaipongSide == 1 && TortorSide == 0) || (TortorSide == 1 && JaipongSide == 0))
			{
				return(true);
			}
			else if((JaipongSide == -1 && TortorSide == 1 && JaipongLots < TortorLots && TortorTotalOrders >= MinOrders) || (TortorSide == -1 && JaipongSide == 1 && TortorLots < JaipongLots && JaipongTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Keroncong Strategy. Cant open SELL ORDER");
				return(false);
			}
		}
	}
	//Tortor
	if(Magic == MagicNumber_Tortor)
	{
		if(Side == 1)
		{
			if((JaipongSide == -1 && KeroncongSide == 0) || (KeroncongSide == -1 && JaipongSide == 0))
			{
				return(true);
			}
			else if((JaipongSide == 1 && KeroncongSide == -1 && JaipongLots < KeroncongLots && KeroncongTotalOrders >= MinOrders) || (KeroncongSide == 1 && JaipongSide == -1 && KeroncongLots < JaipongLots && JaipongTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Tortor Strategy. Cant open BUY ORDER");
				return(false);
			}
		}
		else if(Side == -1)
		{
			if((JaipongSide == 1 && KeroncongSide == 0) || (KeroncongSide == 1 && JaipongSide == 0))
			{
				return(true);
			}
			else if((JaipongSide == -1 && KeroncongSide == 1 && JaipongLots < KeroncongLots && KeroncongTotalOrders >= MinOrders) || (KeroncongSide == -1 && JaipongSide == 1 && KeroncongLots < JaipongLots && JaipongTotalOrders >= MinOrders))
			{
				return(true);
			}
			else
			{
				//Print("Tortor Strategy. Cant open SELL ORDER");
				return(false);
			}
		}
	}
	Print("Something wrong with function \"OrdersSideOptimization\".");
	return(false);
}

void SetTakeProfit(int MagicNumber, double TakeProfit_)
{
	double avgPrice = 0.0;
	double sumLots  = 0.0;
	int orderType;
	int returnvalue;
	for (int order=OrdersTotal()-1; order >= 0; order--) 
	{
		returnvalue=OrderSelect(order, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
		{
			orderType = OrderType();
			avgPrice += OrderOpenPrice()*OrderLots();
			sumLots  += OrderLots();
		}
	}
	if(avgPrice == 0.0 || sumLots == 0.0)
	{
		return;
	}
	double newTakeProfit=avgPrice/sumLots;
	if (orderType==OP_BUY) 
	newTakeProfit=newTakeProfit+TakeProfit_*Point; 
	else 
	newTakeProfit=newTakeProfit-TakeProfit_*Point;
	newTakeProfit=NormalizeDouble(newTakeProfit,Digits);
	
	for (order=OrdersTotal()-1; order>=0; order--) 
	{
		returnvalue=OrderSelect(order, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderTakeProfit() != newTakeProfit)) 
		{
			returnvalue=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTakeProfit,0,clrYellow);
		}
	}
}

bool Weekend()
{
	if ((CloseFriday == TRUE && DayOfWeek() == 5 && TimeCurrent() >= StrToTime(CloseFridayHour + ":00")) || (OpenMondey == TRUE && DayOfWeek() == 1 && TimeCurrent() <= StrToTime(OpenMondeyHour + ":00")))
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool News()
{
	if(!AvoidNews)
	{
		return false;
	}
	if (iCustom(Symbol(),0,"urdala_news_investing.com",UTimeDo,UTimePosle,Uoffset,Vhigh,Vmedium,Vlow,0,0))
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool AutoGridStep()
{
	if(!AutoGridStepAndProfit)
	{
		return true;
	}
	if(Bars(Symbol(), PERIOD_D1) < 6)
	{
		Alert(Symbol()+": Bars count PERIOD_D1 < 6. Expert Removed from chart!");
		return false;
	}
	int Days = 5;
	double sum_rng = 0.0;
	double avg_rng = 0.0;
	for(int i=1;i<=Days;i++) {
      double rng=(iHigh(Symbol(),PERIOD_D1,i)-iLow(Symbol(),PERIOD_D1,i));
      sum_rng+=rng;
	}
	avg_rng = (sum_rng/Point)/Days;
	Step_Keroncong = NormalizeDouble(avg_rng/3+TakeProfit,0);
	Step_Jaipong = NormalizeDouble(avg_rng/3+TakeProfit,0);
	Step_Tortor = NormalizeDouble(avg_rng/3+TakeProfit,0);
	TakeProfit = NormalizeDouble(Step_Keroncong/10,0);
	return true;
}