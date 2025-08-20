//+------------------------------------------------------------------+
//|                                                      Pro7_EA.mq4 |
//|                                                          prozor7 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "prozor7"
#property link      "https://www.mql5.com"
#define VERSION "1.0"
#property version VERSION
#property description "Pro7_EA"
#property strict


//---- EA Settings
enum ActivateEA {
	off=0,  	// Trading Off
	on=1,  		// Trading On
};
ActivateEA Activate_EA = 0;			// EA activate

extern string Additional = "---------- Original EA Settings ----------";		// Original EA Settings
extern double LotSize = 0.02;						// Trade Lot size
extern int DelayNext = 3;							// Number of minutes between trades
extern int Slippage = 5;							// Max Slippage
extern int MaxSpread = 3;							// Max Spread to only open trades below this value
extern int MagicNumber = 9991;						// Magic number
extern string Comment = "Comment";					// Trade Comment

extern string PendsSell = "---------- Pending Sell and Sell Range Options ----------";		// Pending Sell and Sell Range Options
extern double PendSell = 0;							// Pending sell price to enter
extern int NoSellAttempts = 5;						// Number of attempts EA will sell at price
extern int TakeProfitSellPips = 0;					// Take profit pips, 0 for no TP
extern int StopLossSellPips = 0;					// Stop loss pips, 0 for no SL
extern int BreakEvenSellPips = 0;					// Break even if profit pips above this, 0 for no BE
extern int DefaultRangeSellPips = 0;				// Default pips for pending range
extern string CommentSell = "CommentSell";			// Trade Comment

extern string PendsBuy = "---------- Pending Buy and Buy Range Options ----------";		// Pending Buy and Buy Range Options
extern double PendBuy = 0;							// Pending buy price to enter
extern int NoBuyAttempts = 5;						// Number of attempts EA will buy at price
extern int TakeProfitBuyPips = 0;					// Take profit pips, 0 for no TP
extern int StopLossBuyPips = 0;						// Stop loss pips, 0 for no SL
extern int BreakEvenBuyPips = 0;					// Break even if profit pips above this, 0 for no BE
extern int DefaultRangeBuyPips = 0;					// Default pips for pending range
extern string CommentBuy = "CommentBuy";			// Trade Comment

extern string Colors = "---------- Color Options ----------";		// Color Options
extern color ColorLabels = White;					// On screen Labels
extern color ColorPendBuy = Lime;					// Pend Buy
extern color ColorPendSell = Red;					// Pend Sell
extern color ColorStopLoss = Magenta;				// Stop Loss
extern color ColorBreakEven = Yellow;				// Break Even
extern color ColorTakeProfit = DeepSkyBlue;			// Take Profit
extern color ColorRangeButton = White;				// Range Button 
extern color ColorRangeButtonActive = Green;		// Range Button Active





//---- Trading parameters
int tradeDifference;
int tradeDigits = 0;
datetime tradeTime = 0;
datetime tradeSecond;
double SlippageTrade = 1.0;			// 1.0 pips range of price detection below or above

//---- Trading Range
bool RangeBuy = false;
bool RangeSell = false;
double RangePendBuy;
double RangePendSell;

//---- Trading Break Even
bool BreakEvenBuy = false;
bool BreakEvenSell = false;


class Trades {
private:

public:
	int tradeID;			// client side trade id
	int tradeType;			// Long or short
	double tradeLotSize;	// Lot size
	double tradePrice;		// Price at trade open
	string tradeComment;	// Comment
	bool tradeClosed;		// Trade closed

	Trades() { }
	~Trades() { }
};
Trades* UserTrades[];


class CumulativeTrades {
private:
public:
	double price;
	int opened;
	int type;
	CumulativeTrades() { }
	~CumulativeTrades() { }
};
CumulativeTrades* CumulativeBuy[];
CumulativeTrades* CumulativeSell[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {

	//---- Market Information
	if( MarketInfo( Symbol(), MODE_DIGITS) == 2 || MarketInfo( Symbol(), MODE_DIGITS) == 3 || MarketInfo( Symbol(), MODE_DIGITS) == 5 )
	tradeDifference=10;
	else tradeDifference=1;
	tradeDigits = (int)MarketInfo( Symbol(), MODE_DIGITS );
	
	//---- Check for existing CumulativeBuy && CumulativeSell Orders
	if( ObjectFind( 0, "CumulativeBuy" ) >= 0 ) {
		string Explode[];
		int x = StringSplit( ObjectGetString( 0, "CumulativeBuy", OBJPROP_TEXT ), ';', Explode );
		RangeBuy = true;
		PendBuy = StrToDouble( Explode[0] );
		RangePendBuy = StrToDouble( Explode[1] );
		CalculateRangeTrades( OP_BUY );
		if( ArraySize( CumulativeBuy ) == x - 2 ) {
			for( int i = 2; i < x - 2; i++ ) {
				CumulativeBuy[i-2].opened = StrToInteger( Explode[i] );
			}
		}
		ObjectDelete( 0, "CumulativeBuy" );
	}
	if( ObjectFind( 0, "CumulativeSell" ) >= 0 ) {
		string Explode[];
		int x = StringSplit( ObjectGetString( 0, "CumulativeSell", OBJPROP_TEXT ), ';', Explode );
		RangeSell = true;
		PendSell = StrToDouble( Explode[0] );
		RangePendSell = StrToDouble( Explode[1] );
		CalculateRangeTrades( OP_SELL );
		if( ArraySize( CumulativeSell ) == x - 2 ) {
			for( int i = 2; i < x - 2; i++ ) {
				CumulativeSell[i-2].opened = StrToInteger( Explode[i] );
			}
		}
		ObjectDelete( 0, "CumulativeSell" );
	}
	
	//---- Reset PendBuy Line
	if( PendBuy > 0 && ObjectFind( 0, "PendBuy" ) >= 0 ) {
		ObjectSetDouble( 0, "PendBuy", OBJPROP_PRICE, PendBuy );
	}
	//---- Remove PendBuy Line
	if( PendBuy == 0 && ObjectFind( 0, "PendBuy" ) >= 0 ) ObjectDelete( 0, "PendBuy" );
	
	//---- Reset PendSell Line
	if( PendSell > 0 && ObjectFind( 0, "PendSell" ) >= 0 ) {
		ObjectSetDouble( 0, "PendSell", OBJPROP_PRICE, PendSell );
	}
	//---- Remove PendSell Line
	if( PendSell == 0 && ObjectFind( 0, "PendSell" ) >= 0 ) ObjectDelete( 0, "PendSell" );
	
	EventSetMillisecondTimer( 100 );
	return(0);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit( const int reason ) {
	for( int i = 0; i < ArraySize( UserTrades ); i++ ) {
		delete UserTrades[i];
	}
	ArrayResize( UserTrades, 0 );
	
	//---- Save range data incase of close event
	switch( reason ) {
		//---- NOT saving:
		case REASON_PROGRAM:			// EA Removed from ExpertRemove()
		case REASON_REMOVE:				// EA Removed manually by user
		case REASON_CHARTCLOSE:			// Chart closed
		case REASON_INITFAILED: break;	// Failed to load EA
		//---- Saving:
		case REASON_RECOMPILE:			// Mq4 Recompile
		case REASON_CHARTCHANGE:		// Chart / Timeframe change
		case REASON_PARAMETERS:			// EA input parameters changed
		case REASON_ACCOUNT:			// Changed Account
		case REASON_TEMPLATE:			// Template Changed
		case REASON_CLOSE:				// Terminal(MT4) Closed
			//---- Save any pending ranges
			if( ArraySize( CumulativeBuy ) > 0 ) {
				string Implode = DoubleToStr( PendBuy ) + ";" + DoubleToStr( RangePendBuy ) + ";";
				for (int i = 0; i < ArraySize( CumulativeBuy ); i++) {
					Implode = StringConcatenate( Implode, IntegerToString( CumulativeBuy[i].opened ), ";" );
					ObjectDelete( 0, "PendBuy" + IntegerToString( i ) );
					delete CumulativeBuy[i];
				}
				ArrayResize( CumulativeBuy, 0 );
				if( ObjectFind( 0, "CumulativeBuy" ) < 0 ) ObjectCreate( 0, "CumulativeBuy", OBJ_TEXT, 0, 0, 0 );
				ObjectSetText( "CumulativeBuy", Implode );
			}
			if( ArraySize( CumulativeSell ) > 0 ) {
				string Implode = DoubleToStr( PendSell ) + ";" + DoubleToStr( RangePendSell ) + ";";
				for (int i = 0; i < ArraySize( CumulativeSell ); i++) {
					Implode = StringConcatenate( Implode, IntegerToString( CumulativeSell[i].opened ), ";" );
					ObjectDelete( 0, "PendSell" + IntegerToString( i ) );
					delete CumulativeSell[i];
				}
				ArrayResize( CumulativeSell, 0 );
				if( ObjectFind( 0, "CumulativeSell" ) < 0 ) ObjectCreate( 0, "CumulativeSell", OBJ_TEXT, 0, 0, 0 );
				ObjectSetText( "CumulativeSell", Implode );
			}
		break;
	}
	
	//---- Remove remaining information not called from reason
	if( ArraySize( CumulativeBuy ) > 0 ) {
		for (int i = 0; i < ArraySize( CumulativeBuy ); i++) {
			ObjectDelete( 0, "PendBuy" + IntegerToString( i ) );
			delete CumulativeBuy[i];
		}
		ArrayResize( CumulativeBuy, 0 );
	}
	if( ArraySize( CumulativeSell ) > 0 ) {
		for (int i = 0; i < ArraySize( CumulativeSell ); i++) {
			ObjectDelete( 0, "PendSell" + IntegerToString( i ) );
			delete CumulativeSell[i];
		}
		ArrayResize( CumulativeSell, 0 );
	}
	//----
	for( int i = 0; i < 7; i++ ) {
		ObjectDelete( 0, "Jail_EA_" + IntegerToString( i ) );
	}
	ObjectDelete( 0, "EAActive" );
	ObjectDelete( 0, "PendBuy" );
	ObjectDelete( 0, "PendBuyT" );
	ObjectDelete( 0, "RangeBuy" );
	ObjectDelete( 0, "RangePendBuy" );
	ObjectDelete( 0, "PendSell" );
	ObjectDelete( 0, "PendSellT" );
	ObjectDelete( 0, "RangeSell" );
	ObjectDelete( 0, "RangePendSell" );
	
	ObjectDelete( 0, "PendBuySL" );
	ObjectDelete( 0, "PendBuySLT" );
	ObjectDelete( 0, "PendBuyTP" );
	ObjectDelete( 0, "PendBuyTPT" );
	ObjectDelete( 0, "PendSellSL" );
	ObjectDelete( 0, "PendSellSLT" );
	ObjectDelete( 0, "PendSellTP" );
	ObjectDelete( 0, "PendSellTPT" );
	
	RangeBuy = RangeSell = false;
	RangePendBuy = RangePendSell = 0;
	
}


//+------------------------------------------------------------------+
//| Expert button's on event function                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam ) {
	if( id == CHARTEVENT_OBJECT_CLICK ) {
		string clickedChartObject = sparam;
		if( clickedChartObject == "EAActive" ) {
			Activate_EA = (ActivateEA)(1 - Activate_EA);
			if( Activate_EA == 0 ) {
				ObjectSetString( 0, "EAActive", OBJPROP_TEXT, "OFF" );
				ObjectSetInteger( 0, "EAActive", OBJPROP_BGCOLOR, ColorRangeButton );
			} else {
				ObjectSetString( 0, "EAActive", OBJPROP_TEXT, "ON" );
				ObjectSetInteger( 0, "EAActive", OBJPROP_BGCOLOR, ColorRangeButtonActive );
				tradeTime = 0; // Reset timer trade and allow instant trade
			}
		}
		if( clickedChartObject == "RangeBuy" ) {
			RangeBuy = 1 - RangeBuy;
			if( RangeBuy == true ) {
				RangePendBuy = PendBuy + DefaultRangeBuyPips * tradeDifference * Point;
				CalculateRangeTrades( OP_BUY );
			} else {
				for( int i = 0; i < ArraySize( CumulativeBuy ); i++ ) {
					ObjectDelete( 0, "PendBuy" + IntegerToString( i ) );
					ObjectDelete( 0, "PendBuyT" + IntegerToString( i ) );
					delete CumulativeBuy[i];
				}
				ArrayResize( CumulativeBuy, 0 );
				RangePendBuy = 0;
			}
		}
		if( clickedChartObject == "RangeSell" ) {
			RangeSell = 1 - RangeSell;
			if( RangeSell == true ) {
				RangePendSell = PendSell - DefaultRangeSellPips * tradeDifference * Point;
				CalculateRangeTrades( OP_SELL );
			} else {
				for( int i = 0; i < ArraySize( CumulativeSell ); i++ ) {
					ObjectDelete( 0, "PendSell" + IntegerToString( i ) );
					ObjectDelete( 0, "PendSellT" + IntegerToString( i ) );
					delete CumulativeSell[i];
				}
				ArrayResize( CumulativeSell, 0 );
				RangePendSell = 0;
			}
		}
	}
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//| Executes from tick data                                          |
//+------------------------------------------------------------------+
void start() {

	//---- EA Running
	if( Activate_EA == 0 ) return;
	
	//---- Check active trades
	ActiveTrades();
	
	//---- Wait "DelayNext" minutes before opening another trade
	if( TimeCurrent() < tradeTime ) return;
	
	//---- Spread
	double Spread = MarketInfo( NULL, MODE_SPREAD );
	
	//---- Buy Trading
	if( ArraySize( CumulativeBuy ) > 0 ) {
		CumulativeTradeOpen( OP_BUY );
	} else {
		if( PendBuy > 0 && TicketType( OP_BUY ) < NoBuyAttempts && ( Spread / tradeDifference ) <= MaxSpread ) {
			if( Ask > PendBuy - SlippageTrade * Point * tradeDifference && Ask < PendBuy + SlippageTrade * Point * tradeDifference ) {
				tradeTime = TimeCurrent() + DelayNext * 60;
				int res = OrderSend( Symbol(), OP_BUY, LotSize, Ask, Slippage, 0, 0, Comment, MagicNumber, 0, Blue );
				if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
			}
		}
	}
	
	//---- Sell Trading
	if( ArraySize( CumulativeSell ) > 0 ) {
		CumulativeTradeOpen( OP_SELL );
	} else {
		if( PendSell > 0 && TicketType( OP_SELL ) < NoSellAttempts && ( Spread / tradeDifference ) <= MaxSpread ) {
			if( Bid > PendSell - SlippageTrade * Point * tradeDifference && Bid < PendSell + SlippageTrade * Point * tradeDifference ) {
				tradeTime = TimeCurrent() + DelayNext * 60;
				int res = OrderSend( Symbol(), OP_SELL, LotSize, Bid, Slippage, 0, 0, Comment, MagicNumber, 0, Red );
				if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
			}
		}
	}
}


void CumulativeTradeOpen( int trend ) {

	//---- Spread and cannot exceed MaxSpread
	double Spread = MarketInfo( NULL, MODE_SPREAD );
	if( ( Spread / tradeDifference ) > MaxSpread ) return;
	
	if( trend == OP_BUY ) {
		//---- Divide by 0 error
		int _noBA = NoBuyAttempts - 1; if( _noBA < 1 ) _noBA = 1;
		double _diff = MathAbs( PendBuy - RangePendBuy ) / _noBA / 2;
		for( int i = 0; i < ArraySize( CumulativeBuy ); i++ ) {
			if( CumulativeBuy[i].opened == 0 ) {
				if( CumulativeBuy[i].type == OP_SELL ) {
					if( Ask <= CumulativeBuy[i].price ) {
						if( Ask <= ( CumulativeBuy[i].price - _diff ) ) {
							CumulativeBuy[i].opened = 1;
							return;
						}
						if( TicketType( OP_BUY ) < NoBuyAttempts ) {
							tradeTime = TimeCurrent() + 1;
							int res = OrderSend( Symbol(), OP_BUY, LotSize, Ask, Slippage, 0, 0, CommentBuy, MagicNumber, 0, Blue );
							if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
						}
						CumulativeBuy[i].opened = 1;
					}
				} else {
					if( i == ArraySize( CumulativeBuy ) / 2 && TicketType( OP_BUY ) > 0 ) {
						CumulativeBuy[i].opened = 1;
						return;
					}
					if( Ask >= CumulativeBuy[i].price ) {
						if( Ask >= ( CumulativeBuy[i].price + _diff ) ) {
							CumulativeBuy[i].opened = 1;
							return;
						}
						if( TicketType( OP_BUY ) < NoBuyAttempts ) {
							tradeTime = TimeCurrent() + 1;
							int res = OrderSend( Symbol(), OP_BUY, LotSize, Ask, Slippage, 0, 0, CommentBuy, MagicNumber, 0, Blue );
							if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
						}
						CumulativeBuy[i].opened = 1;
					}
				}
				return;
			}
		}
	} else {
		//---- Divide by 0 error
		int _noSA = NoSellAttempts - 1; if( _noSA < 1 ) _noSA = 1;
		double _diff = MathAbs( PendSell - RangePendSell ) / _noSA / 2;
		for( int i = 0; i < ArraySize( CumulativeSell ); i++ ) {
			if( CumulativeSell[i].opened == 0 && TicketType( OP_SELL ) < NoSellAttempts ) {
				if( CumulativeSell[i].type == OP_BUY ) {
					if( Bid >= CumulativeSell[i].price ) {
						if( Bid >= ( CumulativeSell[i].price + _diff ) ) {
							CumulativeSell[i].opened = 1;
							return;
						}
						if( TicketType( OP_SELL ) < NoSellAttempts ) {
							tradeTime = TimeCurrent() + 1;
							int res = OrderSend( Symbol(), OP_SELL, LotSize, Bid, Slippage, 0, 0, CommentSell, MagicNumber, 0, Red );
							if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
						}
						CumulativeSell[i].opened = 1;
					}
				} else {
					if( i == ArraySize( CumulativeSell ) / 2 && TicketType( OP_SELL ) > 0 ) {
						CumulativeSell[i].opened = 1;
						return;
					}
					if( Bid <= CumulativeSell[i].price ) {
						if( Bid <= ( CumulativeSell[i].price - _diff ) ) {
							CumulativeSell[i].opened = 1;
							return;
						}
						if( TicketType( OP_SELL ) < NoSellAttempts ) {
							tradeTime = TimeCurrent() + 1;
							int res = OrderSend( Symbol(), OP_SELL, LotSize, Bid, Slippage, 0, 0, CommentSell, MagicNumber, 0, Red );
							if( res == -1 ) printf( "Error opening trade: %u", GetLastError() );
						}
						CumulativeSell[i].opened = 1;
					}
				}
				return;
			}
		}
	}
}


//+------------------------------------------------------------------+
//| Expert Timer function                                            |
//| Executes every 100 milliseconds                                  |
//+------------------------------------------------------------------+
void OnTimer() {
	Visuals();
}


//+------------------------------------------------------------------+
//| Returns active amount of trades                                  |
//+------------------------------------------------------------------+
void ActiveTrades() {
	
	//---- Prevent duplicate calls
	if( tradeSecond == TimeCurrent() ) return;
	tradeSecond = TimeCurrent();
	
	//---- Search for new trades
	for( int i = 0; i < OrdersTotal(); i++ ) {
		if( OrderSelect( i, SELECT_BY_POS ) ) {
			if( OrderSymbol() == Symbol() && MagicNumber == OrderMagicNumber() ) {
				int _trade = TradeId( OrderTicket() );
				if( _trade == -1 ) {
					Trades* pTrade = new Trades;
					pTrade.tradeID = OrderTicket();
					pTrade.tradeType = OrderType();
					pTrade.tradeComment = OrderComment();
					pTrade.tradeLotSize = OrderLots();
					pTrade.tradePrice = OrderOpenPrice();
					int sz = ArraySize( UserTrades );
					ArrayResize( UserTrades, sz + 1 );
					UserTrades[sz] = pTrade;
					if( OrderType() == OP_BUY )
						if( BreakEvenBuyPips > 0 ) VerifyBreakEven( OrderOpenTime(), OrderType() );
					else
						if( BreakEvenSellPips > 0 ) VerifyBreakEven( OrderOpenTime(), OrderType() );
				}
			}
		}
	}
	
	
	//---- Check Active Trades
	for( int i = 0; i < ArraySize( UserTrades ); i++ ) {
		if( UserTrades[i].tradeClosed == false ) {
			
			//---- Check for closed trades
			if( TicketId( UserTrades[i].tradeID ) == 0 ) {
				UserTrades[i].tradeClosed = true;
				return;
			}
		
			//---- Check for Stop loss and Take profit on Buy trades
			if( UserTrades[i].tradeType == OP_BUY ) {
				//---- Set Break Even
				if( BreakEvenBuyPips > 0 && BreakEvenBuy == false ) {
					if( Bid > UserTrades[i].tradePrice + BreakEvenBuyPips * Point * tradeDifference ) {
						BreakEvenBuy = true;
					}
				}
				/*---- Close at break even, this has been detached to seperate function
				if( BreakEvenBuy == true ) {
					if( Bid <= UserTrades[i].tradePrice + SlippageTrade * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Bid, Slippage, Blue ) ) Print( "OrderClose error ", GetLastError() );
					}
				}*/
				//---- Stop Loss
				if( StopLossBuyPips > 0 && Bid < PendBuy - StopLossBuyPips * Point * tradeDifference ) {
					if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Bid, Slippage, Blue ) ) Print( "OrderClose error ", GetLastError() );
				}
				//---- Take Profit
				if( RangeBuy == true ) {
					if( TakeProfitBuyPips > 0 && RangePendBuy > 0 && Bid > RangePendBuy + TakeProfitBuyPips * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Bid, Slippage, Blue ) ) Print( "OrderClose error ", GetLastError() );
						RangeBuy = false;
					}
				} else {
					if( TakeProfitBuyPips > 0 && Bid > PendBuy + TakeProfitBuyPips * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Bid, Slippage, Blue ) ) Print( "OrderClose error ", GetLastError() );
						RangeBuy = false;
					}
				}
			}
		
			//---- Check for Stop loss and Take profit on Sell trades
			if( UserTrades[i].tradeType == OP_SELL ) {
				//---- Set Break Even
				if( BreakEvenSellPips > 0 && BreakEvenSell == false ) {
					if( Ask < UserTrades[i].tradePrice - BreakEvenSellPips * Point * tradeDifference ) {
						BreakEvenSell = true;
					}
				}
				/*---- Close at break even, this has been detached to seperate function
				if( BreakEvenSell == true ) {
					if( Ask >= UserTrades[i].tradePrice - SlippageTrade * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Ask, Slippage, Red ) ) Print( "OrderClose error ", GetLastError() );
					}
				}*/
				//---- Stop Loss
				if( StopLossSellPips > 0 && Ask > PendSell + StopLossSellPips * Point * tradeDifference ) {
					if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Ask, Slippage, Red ) ) Print( "OrderClose error ", GetLastError() );
				}
				//---- Take Profit
				if( RangeSell == true ) {
					if( TakeProfitSellPips > 0 && RangePendSell > 0 && Ask < RangePendSell - TakeProfitSellPips * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Ask, Slippage, Red ) ) Print( "OrderClose error ", GetLastError() );
						RangeSell = false;
					}
				} else {
					if( TakeProfitSellPips > 0 && Ask < PendSell - TakeProfitSellPips * Point * tradeDifference ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Ask, Slippage, Red ) ) Print( "OrderClose error ", GetLastError() );
						RangeSell = false;
					}
				}
			}
		}
	}
	
	//---- Check Break Even
	if( ArraySize( UserTrades ) > 0 ) TradesBreakEven();
	
	//---- Reset Break Even
	if( BreakEvenBuy == true && TicketType( OP_BUY ) == 0 ) BreakEvenBuy = false;
	if( BreakEvenSell == true && TicketType( OP_SELL ) == 0 ) BreakEvenSell = false;
	
	//---- Reset Array of ALL closed trades
	DeleteArray();
}


//--- Break Even
void TradesBreakEven() {
	if( BreakEvenBuy == true ) {
		//---- Calculate break even for all buy open trades
		int count = 0;
		double breakeven = 0;
		for( int i = 0; i < OrdersTotal(); i++ ) {
			if( OrderSelect( i, SELECT_BY_POS ) ) {
				if( OrderSymbol() == Symbol() && MagicNumber == OrderMagicNumber() && OrderType() == OP_BUY ) {
					breakeven += OrderOpenPrice();
					count++;
				}
			}
		}
		if( count == 0 ) return; // Prevents divide by 0 error
		breakeven /= count;
		
		//---- Draw break even
		if( ObjectFind( "BreakEvenBuy" ) < 0 ) {
			ObjectCreate( 0, "BreakEvenBuy", OBJ_TREND, 0, Time[3], breakeven + SlippageTrade * Point * tradeDifference, ( Time[0] + 3 * 60 * Period() ), breakeven + SlippageTrade * Point * tradeDifference );
			ObjectSetInteger( 0, "BreakEvenBuy", OBJPROP_COLOR, ColorBreakEven );
			ObjectSetInteger( 0, "BreakEvenBuy", OBJPROP_STYLE, STYLE_SOLID );
			ObjectSetInteger( 0, "BreakEvenBuy", OBJPROP_WIDTH, 1 );
			ObjectSetInteger( 0, "BreakEvenBuy", OBJPROP_RAY_RIGHT, 0 );
		}
		ObjectMove( "BreakEvenBuy", 0, Time[3], breakeven + SlippageTrade * Point * tradeDifference );
		ObjectMove( "BreakEvenBuy", 1, ( Time[0] + 3 * 60 * Period() ), breakeven + SlippageTrade * Point * tradeDifference );
		
		//---- Break even hit and close all trades
		if( Bid < breakeven + SlippageTrade * Point * tradeDifference ) {
			for( int i = 0; i < OrdersTotal(); i++ ) {
				if( OrderSelect( i, SELECT_BY_POS ) ) {
					if( OrderSymbol() == Symbol() && MagicNumber == OrderMagicNumber() && OrderType() == OP_BUY ) {
						if( !OrderClose( OrderTicket(), OrderLots(), Bid, Slippage, Blue ) ) Print( "OrderClose error ", GetLastError() );
					}
				}
			}
			ObjectDelete( 0, "BreakEvenBuy" );
		}
	}
	if( BreakEvenSell == true ) {
		//---- Calculate break even for all buy open trades
		int count = 0;
		double breakeven = 0;
		for( int i = 0; i < OrdersTotal(); i++ ) {
			if( OrderSelect( i, SELECT_BY_POS ) ) {
				if( OrderSymbol() == Symbol() && MagicNumber == OrderMagicNumber() && OrderType() == OP_SELL ) {
					breakeven += OrderOpenPrice();
					count++;
				}
			}
		}
		if( count == 0 ) return; // Prevents divide by 0 error
		breakeven /= count;
		
		//---- Draw break even
		if( ObjectFind( "BreakEvenSell" ) < 0 ) {
			ObjectCreate( 0, "BreakEvenSell", OBJ_TREND, 0, Time[3], breakeven - SlippageTrade * Point * tradeDifference, ( Time[0] + 3 * 60 * Period() ), breakeven - SlippageTrade * Point * tradeDifference );
			ObjectSetInteger( 0, "BreakEvenSell", OBJPROP_COLOR, ColorBreakEven );
			ObjectSetInteger( 0, "BreakEvenSell", OBJPROP_STYLE, STYLE_SOLID );
			ObjectSetInteger( 0, "BreakEvenSell", OBJPROP_WIDTH, 1 );
			ObjectSetInteger( 0, "BreakEvenSell", OBJPROP_RAY_RIGHT, 0 );
		}
		ObjectMove( "BreakEvenSell", 0, Time[3], breakeven - SlippageTrade * Point * tradeDifference );
		ObjectMove( "BreakEvenSell", 1, ( Time[0] + 3 * 60 * Period() ), breakeven - SlippageTrade * Point * tradeDifference );
		
		//---- Break even hit and close all trades
		if( Ask > breakeven - SlippageTrade * Point * tradeDifference ) {
			for( int i = 0; i < OrdersTotal(); i++ ) {
				if( OrderSelect( i, SELECT_BY_POS ) ) {
					if( OrderSymbol() == Symbol() && MagicNumber == OrderMagicNumber() && OrderType() == OP_SELL ) {
						if( !OrderClose( UserTrades[i].tradeID, UserTrades[i].tradeLotSize, Ask, Slippage, Red ) ) Print( "OrderClose error ", GetLastError() );
					}
				}
			}
			ObjectDelete( 0, "BreakEvenSell" );
		}
	}
}


//---- Confirms trade inserted into the array
int TradeId( int orderId ) {
	for( int x = 0; x < ArraySize( UserTrades ); x++ ) {
		if( orderId == UserTrades[x].tradeID ) return orderId;
	}
	return -1;
}


//---- Confirms trade is closed
int TicketId( int orderId ) {
	for( int x = 0; x < OrdersTotal(); x++ ) {
		if( OrderSelect( x, SELECT_BY_POS ) ) {
			if( OrderTicket() == orderId ) return orderId;
		}
	}
	return 0;
}


//---- Returns trade count by type, OP_BUY or OP_SELL
int TicketType( int type ) {
	int count = 0;
	for( int x = 0; x < ArraySize( UserTrades ); x++ ) {
		if( UserTrades[x].tradeType == type && UserTrades[x].tradeClosed == false ) count++;
	}
	return count;
}


//---- Reset Array after ALL trades are closed, this will reset upon EA modification
void DeleteArray() {
	if( ArraySize( UserTrades ) > 0 ) {
		int count = 0;
		for( int x = 0; x < ArraySize( UserTrades ); x++ ) if( UserTrades[x].tradeClosed == true ) count++;
		if( count == ArraySize( UserTrades ) ) {
			for( int x = 0; x < ArraySize( UserTrades ); x++ ) {
				delete UserTrades[x];
			}
			ArrayResize( UserTrades, 0 );
			for( int x = 0; x < ArraySize( CumulativeBuy ); x++ ) {
				if( ObjectFind( 0, "PendBuy" + IntegerToString( x ) ) >= 0 ) ObjectDelete( 0, "PendBuy" + IntegerToString( x ) );
				CumulativeBuy[x].opened = 0;
			}
			for( int x = 0; x < ArraySize( CumulativeSell ); x++ ) {
				if( ObjectFind( 0, "PendSell" + IntegerToString( x ) ) >= 0 ) ObjectDelete( 0, "PendSell" + IntegerToString( x ) );
				CumulativeSell[x].opened = 0;
			}
		}
	}
	if( ArraySize( UserTrades ) == 0 ) {
		if( ArraySize( CumulativeBuy ) > 0 && RangeBuy == false ) {
			for( int i = 0; i < ArraySize( CumulativeBuy ); i ++ ) {
				ObjectDelete( 0, "PendBuy" + IntegerToString( i ) );
				delete CumulativeBuy[i];
			}
			ArrayResize( CumulativeBuy, 0 );
			RangePendBuy = 0;
		}
	}
	if( ArraySize( UserTrades ) == 0 ) {
		if( ArraySize( CumulativeSell ) > 0 && RangeSell == false ) {
			for( int i = 0; i < ArraySize( CumulativeSell ); i ++ ) {
				ObjectDelete( 0, "PendSell" + IntegerToString( i ) );
				delete CumulativeSell[i];
			}
			ArrayResize( CumulativeSell, 0 );
			RangePendSell = 0;
		}
	}
}


//---- Verify Break even, this is called if the EA is reactivated AFTER trades are opened
void VerifyBreakEven( datetime opentime, int type ) {
	if( iBarShift( NULL, PERIOD_M1, opentime ) == 0 ) return;
	for( int i = iBarShift( NULL, PERIOD_M1, opentime ); i >= 0; i-- ) {
		if( type == OP_BUY ) {
			if( Bid > iHigh( NULL, PERIOD_M1, i ) + BreakEvenBuyPips * Point * tradeDifference > 0 ) {
				BreakEvenBuy = true;
			}
		}
		if( type == OP_SELL ) {
			if( Ask < iLow( NULL, PERIOD_M1, i ) - BreakEvenSellPips * Point * tradeDifference > 0 ) {
				BreakEvenSell = true;
			}
		}
	}
}


void CalculateRangeTrades( int trend ) {
	if( trend == OP_BUY ) {
		
		//---- Increase array size
		if( ArraySize( CumulativeBuy ) < NoBuyAttempts * 2 ) {
			int _count = ArraySize( CumulativeBuy );
			ArrayResize( CumulativeBuy, NoBuyAttempts * 2 );
			for( int i = _count; i < NoBuyAttempts * 2; i++ ) {
				CumulativeBuy[i] = new CumulativeTrades;
				CumulativeBuy[i].opened = 0;
			}
		}
		
		//---- Update range prices
		double _diff = MathAbs( ( PendBuy - RangePendBuy ) / tradeDifference / Point ) / ( NoBuyAttempts - 1 );
		for( int i = 0; i < NoBuyAttempts; i++ ) {
			CumulativeBuy[i].price = RangePendBuy - ( _diff * i * Point * tradeDifference );
			CumulativeBuy[i].type = OP_SELL;
		}
		for( int i = NoBuyAttempts; i < NoBuyAttempts * 2; i++ ) {
			CumulativeBuy[i].price = PendBuy + ( _diff * ( i - NoBuyAttempts ) * Point * tradeDifference );
			CumulativeBuy[i].type = OP_BUY;
		}
		
		//---- Verify price hit bottom range
		for( int i = 0; i < 6; i++ ) {
			if( Low[i] < PendBuy ) {
				for( int j = 0; j < ArraySize( CumulativeBuy ) / 2; j++ ) {
					CumulativeBuy[j].opened = 1;
				}
				return;
			}
		}
		
	} else {

		//---- Increase array size
		if( ArraySize( CumulativeSell ) < NoSellAttempts * 2 ) {
			int _count = ArraySize( CumulativeSell );
			ArrayResize( CumulativeSell, NoSellAttempts * 2 );
			for( int i = _count; i < NoSellAttempts * 2; i++ ) {
				CumulativeSell[i] = new CumulativeTrades;
				CumulativeSell[i].opened = 0;
			}
		}
		
		//---- Update range prices
		double _diff = MathAbs( ( PendSell - RangePendSell ) / tradeDifference / Point ) / ( NoSellAttempts - 1 );
		for( int i = 0; i < NoSellAttempts; i++ ) {
			CumulativeSell[i].price = RangePendSell + ( _diff * i * Point * tradeDifference );
			CumulativeSell[i].type = OP_BUY;
		}
		for( int i = NoSellAttempts; i < NoSellAttempts * 2; i++ ) {
			CumulativeSell[i].price = PendSell - ( _diff * ( i - NoSellAttempts ) * Point * tradeDifference );
			CumulativeSell[i].type = OP_SELL;
		}

		//---- Verify price hit top range
		for( int i = 0; i < 6; i++ ) {
			if( High[i] > PendSell ) {
				for( int j = 0; j < ArraySize( CumulativeSell ) / 2; j++ ) {
					CumulativeSell[j].opened = 1;
				}
				return;
			}
		}
	}
}


//---- Visuals, This still operates whilst EA is disabled
void Visuals() {

	//---- EA Enable/Disable Button
	if( ObjectFind( 0, "EAActive" ) < 0 ) {
		GenericDraw( "EAActive", OBJ_BUTTON, 0, 0, 0, 5, 15, 24, 15, CORNER_LEFT_UPPER, "Arial", 7, Black, ColorRangeButton, Gray ); 
		if( Activate_EA == 0 )
			ObjectSetString( 0, "EAActive", OBJPROP_TEXT, "OFF" );
		else
			ObjectSetString( 0, "EAActive", OBJPROP_TEXT, "ON" );
	}
	
	// Create all the labels
	for( int i = 0; i < 7; i++ ) {
		if( ObjectFind( 0, "Jail_EA_" + IntegerToString( i ) ) < 0 ) {
			GenericDraw( "Jail_EA_" + IntegerToString( i ), OBJ_LABEL, 0, 0, 0, 5, 195 + i * 18, 0, 0, CORNER_LEFT_UPPER, "Arial", 8, ColorLabels );
		}
	}

	//---- EA Active
	if( Activate_EA == 0 ) {
		ObjectSetString( 0, "Jail_EA_0", OBJPROP_TEXT, "EA Disabled" );
	} else {
		ObjectSetString( 0, "Jail_EA_0", OBJPROP_TEXT, "EA Activated" );
		ObjectSetInteger( 0, "EAActive", OBJPROP_BGCOLOR, ColorRangeButtonActive );
	}
	
	//---- Pending Buy Order
	string PendingBuy = "Pending Buy: ";
	if( PendBuy > 0 ) PendingBuy += DoubleToStr( PendBuy, tradeDigits );
	if( BreakEvenBuy ) PendingBuy += " Break Even";
	ObjectSetString( 0, "Jail_EA_1", OBJPROP_TEXT, PendingBuy );

	//---- Pending Sell Order
	string PendingSell = "Pending Sell: ";
	if( PendSell > 0 ) PendingSell += DoubleToStr( PendSell, tradeDigits );
	if( BreakEvenSell ) PendingSell += " Break Even";
	ObjectSetString( 0, "Jail_EA_2", OBJPROP_TEXT, PendingSell );

	//---- Stop Loss
	string StopLoss = "Stop Loss: ";
	if( StopLossBuyPips > 0 || StopLossSellPips > 0 ) { 
		StopLoss += IntegerToString( StopLossBuyPips ) + " / " + IntegerToString( StopLossSellPips );
		if( RangeBuy == true ) {
			if( PendBuy > 0 ) StopLoss += " / " + DoubleToStr( RangePendBuy - StopLossBuyPips * Point * tradeDifference, tradeDigits );
		} else {
			if( PendBuy > 0 ) StopLoss += " / " + DoubleToStr( PendBuy - StopLossBuyPips * Point * tradeDifference, tradeDigits );
		}
		if( RangeSell == true ) {
			if( PendSell > 0 ) StopLoss += " / " + DoubleToStr( RangePendSell + StopLossSellPips * Point * tradeDifference, tradeDigits );
		} else {
			if( PendSell > 0 ) StopLoss += " / " + DoubleToStr( PendSell + StopLossSellPips * Point * tradeDifference, tradeDigits );
		}
	}
	ObjectSetString( 0, "Jail_EA_3", OBJPROP_TEXT, StopLoss );

	//---- Take Profit
	string TakeProfit = "Take Profit: ";
	if( TakeProfitBuyPips > 0 || TakeProfitSellPips > 0 ) { 
		TakeProfit += IntegerToString( TakeProfitBuyPips ) + " / " + IntegerToString( TakeProfitSellPips );
		if( PendBuy > 0 ) TakeProfit += " / " + DoubleToStr( PendBuy + TakeProfitBuyPips * Point * tradeDifference, tradeDigits );
		if( PendSell > 0 ) TakeProfit += " / " + DoubleToStr( PendSell - TakeProfitSellPips * Point * tradeDifference, tradeDigits );
	}
	ObjectSetString( 0, "Jail_EA_4", OBJPROP_TEXT, TakeProfit );
	
	//---- Active Trades
	ObjectSetString( 0, "Jail_EA_5", OBJPROP_TEXT, "Max Trades/Buy/Sell: " + IntegerToString( NoBuyAttempts ) + " / " + IntegerToString( NoSellAttempts ) + " / " + IntegerToString( TicketType( OP_BUY ) ) + " / " + IntegerToString( TicketType( OP_SELL ) )  );
	
	//---- Spread
	double Spread = MarketInfo( Symbol(), MODE_SPREAD );
	ObjectSetString( 0, "Jail_EA_6", OBJPROP_TEXT, "Max/Spread: " + IntegerToString( MaxSpread ) + " / " + DoubleToStr( Spread / tradeDifference, 1 ) );
	
	//---- Draw Pending Buy Line,
	if( PendBuy > 0 && ObjectFind( 0, "PendBuy" ) < 0 ) {
		GenericDraw( "PendBuy", OBJ_HLINE, 0, 0, PendBuy, 0, 0, STYLE_SOLID, 2, ColorPendBuy, 1 );
	}
	
	//---- Update Pending Buy Price
	if( ObjectFind( 0, "PendBuy" ) >= 0 ) {
		double _pendbuy = ObjectGetDouble( 0, "PendBuy", OBJPROP_PRICE );
		if( _pendbuy != PendBuy ) {
			PendBuy = _pendbuy;
			tradeTime = TimeCurrent() + 5; // Reset timer trade and allow instant trade
			if( RangeBuy ) CalculateRangeTrades( OP_BUY );
		}
	}
	
	//---- Draw Pending Sell Line,
	if( PendSell > 0 && ObjectFind( 0, "PendSell" ) < 0 ) {
		GenericDraw( "PendSell", OBJ_HLINE, 0, 0, PendSell, 0, 0, STYLE_SOLID, 2, ColorPendSell, 1 );
	}
	
	//---- Update Pending Buy Price
	if( ObjectFind( 0, "PendSell" ) >= 0 ) {
		double _pendsell = ObjectGetDouble( 0, "PendSell", OBJPROP_PRICE );
		if( _pendsell != PendSell ) {
			PendSell = _pendsell;
			tradeTime = TimeCurrent() + 5; // Reset timer trade and allow instant trade
			if( RangeSell ) CalculateRangeTrades( OP_SELL );
		}
	}
	
	
	//---- Pend Buy Stop Loss and Take Profit
	if( PendBuy > 0 && StopLossBuyPips > 0 ) {
		if( ObjectFind( 0, "PendBuySL" ) < 0 ) {
			GenericDraw( "PendBuySL", OBJ_TREND, 0, Time[3], PendBuy - StopLossBuyPips * Point * tradeDifference, ( Time[0] + 10 * 60 * Period() ), PendBuy - StopLossBuyPips * Point * tradeDifference, STYLE_SOLID, 1, ColorStopLoss, 0, 0 );
		}
		if( ObjectFind( 0, "PendBuySLT" ) < 0 ) {
			GenericDraw( "PendBuySLT", OBJ_TEXT, 0, Time[0] + 10 * 60 * Period(), PendBuy - StopLossBuyPips * Point * tradeDifference, 0, 0, 0, 0, CORNER_LEFT_UPPER, "Arial", 8, ColorLabels );
		}
		ObjectSetString( 0, "PendBuySLT", OBJPROP_TEXT, "B SL" );
		ObjectMove( "PendBuySL", 0, Time[3], PendBuy - StopLossBuyPips * Point * tradeDifference );
		ObjectMove( "PendBuySL", 1, Time[0] + 10 * 60 * Period(), PendBuy - StopLossBuyPips * Point * tradeDifference );
		ObjectMove( "PendBuySLT", 0, Time[0] + 10 * 60 * Period(), PendBuy - StopLossBuyPips * Point * tradeDifference );
	} else {
		ObjectDelete( 0, "PendBuySL" );
	}
	if( PendBuy > 0 && TakeProfitBuyPips > 0 ) {
		if( ObjectFind( 0, "PendBuyTP" ) < 0 ) {
			GenericDraw( "PendBuyTP", OBJ_TREND, 0, Time[3], PendBuy + TakeProfitBuyPips * Point * tradeDifference, ( Time[0] + 15 * 60 * Period() ), PendBuy + TakeProfitBuyPips * Point * tradeDifference, STYLE_SOLID, 1, ColorTakeProfit, 0, 0 );
		}
		if( ObjectFind( 0, "PendBuyTPT" ) < 0 ) {
			GenericDraw( "PendBuyTPT", OBJ_TEXT, 0, Time[0] + 15 * 60 * Period(), PendBuy + TakeProfitBuyPips * Point * tradeDifference, 0, 0, 0, 0, CORNER_LEFT_UPPER, "Arial", 8, ColorLabels );
		}
		ObjectSetString( 0, "PendBuyTPT", OBJPROP_TEXT, "B TP" );
		if( RangePendBuy > 0 ) {
			ObjectMove( "PendBuyTP", 0, Time[3], RangePendBuy + TakeProfitBuyPips * Point * tradeDifference );
			ObjectMove( "PendBuyTP", 1, Time[0] + 15 * 60 * Period(), RangePendBuy + TakeProfitBuyPips * Point * tradeDifference );
			ObjectMove( "PendBuyTPT", 0, Time[0] + 15 * 60 * Period(), RangePendBuy + TakeProfitBuyPips * Point * tradeDifference );
		} else {
			ObjectMove( "PendBuyTP", 0, Time[3], PendBuy + TakeProfitBuyPips * Point * tradeDifference );
			ObjectMove( "PendBuyTP", 1, Time[0] + 15 * 60 * Period(), PendBuy + TakeProfitBuyPips * Point * tradeDifference );
			ObjectMove( "PendBuyTPT", 0, Time[0] + 15 * 60 * Period(), PendBuy + TakeProfitBuyPips * Point * tradeDifference );
		}
	} else {
		ObjectDelete( 0, "PendBuyTP" );
	}
	

	//---- Pend Sell Stop Loss and Take Profit
	if( PendSell > 0 && StopLossSellPips > 0 ) {
		if( ObjectFind( 0, "PendSellSL" ) < 0 ) {
			GenericDraw( "PendSellSL", OBJ_TREND, 0, Time[3], PendSell + StopLossSellPips * Point * tradeDifference, ( Time[0] + 10 * 60 * Period() ), PendSell + StopLossSellPips * Point * tradeDifference, STYLE_SOLID, 1, ColorStopLoss, 0, 0 );
		}
		if( ObjectFind( 0, "PendSellSLT" ) < 0 ) {
			GenericDraw( "PendSellSLT", OBJ_TEXT, 0, Time[0] + 10 * 60 * Period(), PendSell + StopLossSellPips * Point * tradeDifference, 0, 0, 0, 0, CORNER_LEFT_UPPER, "Arial", 8, ColorLabels );
		}
		ObjectSetString( 0, "PendSellSLT", OBJPROP_TEXT, "S SL" );
		ObjectMove( "PendSellSL", 0, Time[3], PendSell + StopLossSellPips * Point * tradeDifference );
		ObjectMove( "PendSellSL", 1, Time[0] + 10 * 60 * Period(), PendSell + StopLossSellPips * Point * tradeDifference );
		ObjectMove( "PendSellSLT", 0, Time[0] + 10 * 60 * Period(), PendSell + StopLossSellPips * Point * tradeDifference );
	} else {
		ObjectDelete( 0, "PendSellSL" );
	}
	if( PendSell > 0 && TakeProfitSellPips > 0 ) {
		if( ObjectFind( 0, "PendSellTP" ) < 0 ) {
			GenericDraw( "PendSellTP", OBJ_TREND, 0, Time[3], PendSell - TakeProfitSellPips * Point * tradeDifference, ( Time[0] + 15 * 60 * Period() ), PendSell - TakeProfitSellPips * Point * tradeDifference, STYLE_SOLID, 1, ColorTakeProfit, 0, 0 );
		}
		if( ObjectFind( 0, "PendSellTPT" ) < 0 ) {
			GenericDraw( "PendSellTPT", OBJ_TEXT, 0, Time[0] + 15 * 60 * Period(), PendSell - TakeProfitSellPips * Point * tradeDifference, 0, 0, 0, 0, CORNER_LEFT_UPPER, "Arial", 8, ColorLabels );
		}
		ObjectSetString( 0, "PendSellTPT", OBJPROP_TEXT, "S TP" );
		if( RangePendSell > 0 ) {
			ObjectMove( "PendSellTP", 0, Time[3], RangePendSell - TakeProfitSellPips * Point * tradeDifference );
			ObjectMove( "PendSellTP", 1, Time[0] + 15 * 60 * Period(), RangePendSell - TakeProfitSellPips * Point * tradeDifference );
			ObjectMove( "PendSellTPT", 0, Time[0] + 15 * 60 * Period(), RangePendSell - TakeProfitSellPips * Point * tradeDifference );
		} else {
			ObjectMove( "PendSellTP", 0, Time[3], PendSell - TakeProfitSellPips * Point * tradeDifference );
			ObjectMove( "PendSellTP", 1, Time[0] + 15 * 60 * Period(), PendSell - TakeProfitSellPips * Point * tradeDifference );
			ObjectMove( "PendSellTPT", 0, Time[0] + 15 * 60 * Period(), PendSell - TakeProfitSellPips * Point * tradeDifference );
		}
	} else {
		ObjectDelete( 0, "PendSellTP" );
	}
	
	
	//---- "Range Buy" Button
	if( PendBuy > 0 ) {
		if( ObjectFind( 0, "RangeBuy" ) < 0 ) {
			GenericDraw( "RangeBuy", OBJ_BUTTON, 0, 0, 0, 5, 35, 24, 15, CORNER_LEFT_UPPER, "Arial", 7, Black, ColorRangeButton, Gray );
			ObjectSetText( "RangeBuy", "R B" );
		}
		if( RangeBuy == true ) {
			ObjectSetInteger( 0, "RangeBuy", OBJPROP_BGCOLOR, ColorRangeButtonActive );
		} else {
			ObjectSetInteger( 0, "RangeBuy", OBJPROP_BGCOLOR, ColorRangeButton );
		}
	} else {
		if( ObjectFind( 0, "RangeBuy" ) >= 0 ) ObjectDelete( 0, "RangeBuy" );
	}
	
	
	//---- Range Pend Buy Line
	if( RangePendBuy > 0 && ObjectFind( 0, "RangePendBuy" ) < 0 ) {
		GenericDraw( "RangePendBuy", OBJ_HLINE, 0, 0, RangePendBuy, 0, 0, STYLE_SOLID, 2, ColorPendBuy, 1 );
	} else if( RangePendBuy == 0 ) {
		if( ObjectFind( 0, "RangePendBuy" ) >= 0 ) ObjectDelete( 0, "RangePendBuy" );
	} else if( RangePendBuy > 0 ) {
		double _rangependbuy = ObjectGetDouble( 0, "RangePendBuy", OBJPROP_PRICE );
		if( _rangependbuy != RangePendBuy ) {
			RangePendBuy = _rangependbuy;
			CalculateRangeTrades( OP_BUY );
		}
	}
	
	//---- Draw Range Intermediary Pend Buy's
	if( ArraySize( CumulativeBuy ) > 0 ) {
		for( int i = 0; i < ArraySize( CumulativeBuy ); i++ ) {
			if( CumulativeBuy[i].opened == 0 ) {
				if( ObjectFind( "PendBuy" + IntegerToString( i ) ) < 0 ) {
					GenericDraw( "PendBuy" + IntegerToString( i ), OBJ_TREND, 0, Time[0] + i * 60 * Period(), CumulativeBuy[i].price, ( Time[0] + i * 3 * 60 * Period() ), CumulativeBuy[i].price, STYLE_SOLID, 1, ColorPendBuy, 0, 0 );
				}
				ObjectMove( "PendBuy" + IntegerToString( i ), 0, Time[0] + i * 60 * Period(), CumulativeBuy[i].price );
				ObjectMove( "PendBuy" + IntegerToString( i ), 1, Time[0] + ( i + 2 ) * 60 * Period(), CumulativeBuy[i].price );
			} else {
				if( ObjectFind( "PendBuy" + IntegerToString( i ) ) >= 0 ) ObjectDelete( 0, "PendBuy" + IntegerToString( i ) );
			}
		}
	}

	//---- "Range Sell" Button
	if( PendSell > 0 ) {
		if( ObjectFind( 0, "RangeSell" ) < 0 ) {
			GenericDraw( "RangeSell", OBJ_BUTTON, 0, 0, 0, 5, 55, 24, 15, CORNER_LEFT_UPPER, "Arial", 7, Black, ColorRangeButton, Gray );
			ObjectSetText( "RangeSell", "R S" );
		}
		if( RangeSell == true ) {
			ObjectSetInteger( 0, "RangeSell", OBJPROP_BGCOLOR, ColorRangeButtonActive );
		} else {
			ObjectSetInteger( 0, "RangeSell", OBJPROP_BGCOLOR, ColorRangeButton );
		}
	} else {
		if( ObjectFind( 0, "RangeSell" ) >= 0 ) ObjectDelete( 0, "RangeSell" );
	}

	//---- Range Pend Sell Line
	if( RangePendSell > 0 && ObjectFind( 0, "RangePendSell" ) < 0 ) {
		GenericDraw( "RangePendSell", OBJ_HLINE, 0, 0, RangePendSell, 0, 0, STYLE_SOLID, 2, ColorPendSell, 1 );
	} else if( RangePendSell == 0 ) {
		if( ObjectFind( 0, "RangePendSell" ) >= 0 ) ObjectDelete( 0, "RangePendSell" );
	} else if( RangePendSell > 0 ) {
		double _rangependsell = ObjectGetDouble( 0, "RangePendSell", OBJPROP_PRICE );
		if( _rangependsell != RangePendSell ) {
			RangePendSell = _rangependsell;
			CalculateRangeTrades( OP_SELL );
		}
	}

	//---- Draw Range Intermediary Pend Sell's
	if( ArraySize( CumulativeSell ) > 0 ) {
		for( int i = 0; i < ArraySize( CumulativeSell ); i++ ) {
			if( CumulativeSell[i].opened == 0 ) {
				if( ObjectFind( "PendSell" + IntegerToString( i ) ) < 0 ) {
					GenericDraw( "PendSell" + IntegerToString( i ), OBJ_TREND, 0, Time[0] + i * 60 * Period(), CumulativeSell[i].price, ( Time[0] + i * 3 * 60 * Period() ), CumulativeSell[i].price, STYLE_SOLID, 1, ColorPendSell, 0, 0 );
				}
				ObjectMove( "PendSell" + IntegerToString( i ), 0, Time[0] + i * 60 * Period(), CumulativeSell[i].price );
				ObjectMove( "PendSell" + IntegerToString( i ), 1, Time[0] + ( i + 2 ) * 60 * Period(), CumulativeSell[i].price );
			} else {
				if( ObjectFind( "PendSell" + IntegerToString( i ) ) >= 0 ) ObjectDelete( 0, "PendSell" + IntegerToString( i ) );
			}
		}
	}

}

//---- Helper function for aiding of drawing lines, rectangles and trend lines
void GenericDraw( string object_name, ENUM_OBJECT object_type, int sub_window, datetime time1, double price1, datetime time2, double price2, ENUM_LINE_STYLE line_style, int line_width, color fore_color, int selected = 0, bool back = false, int ray = 0 ) {
	ObjectCreate( 0, object_name, object_type, sub_window, time1, price1, time2, price2 );
	ObjectSetInteger( 0, object_name, OBJPROP_STYLE, line_style );
	ObjectSetInteger( 0, object_name, OBJPROP_WIDTH, line_width );
	ObjectSetInteger( 0, object_name, OBJPROP_COLOR, fore_color );
	ObjectSetInteger( 0, object_name, OBJPROP_SELECTED, selected );
	ObjectSetInteger( 0, object_name, OBJPROP_BACK, back );
	ObjectSetInteger( 0, object_name, OBJPROP_RAY_RIGHT, ray );
}

//---- Helper function for aiding texts and labels
void GenericDraw( string object_name, ENUM_OBJECT object_type, int sub_window, datetime time1, double price1, int x_distance, int y_distance, int x_size, int y_size, ENUM_BASE_CORNER corner, string font, int font_size, color font_color, color back_color = DRAW_NONE, color border_color = DRAW_NONE ) {
	ObjectCreate( 0, object_name, object_type, sub_window, time1, price1 );
	ObjectSetInteger( 0, object_name, OBJPROP_XDISTANCE, x_distance );
	ObjectSetInteger( 0, object_name, OBJPROP_YDISTANCE, y_distance );
	ObjectSetInteger( 0, object_name, OBJPROP_XSIZE, x_size );
	ObjectSetInteger( 0, object_name, OBJPROP_YSIZE, y_size );
	ObjectSetInteger( 0, object_name, OBJPROP_CORNER, corner );
	ObjectSetString( 0, object_name, OBJPROP_FONT, font );
	ObjectSetInteger( 0, object_name, OBJPROP_FONTSIZE, font_size );
	ObjectSetInteger( 0, object_name, OBJPROP_COLOR, font_color );
	ObjectSetInteger( 0, object_name, OBJPROP_BGCOLOR, back_color );
	ObjectSetInteger( 0, object_name, OBJPROP_BORDER_COLOR, border_color );
}
