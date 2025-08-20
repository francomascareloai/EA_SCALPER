// cainpptr.ea by "rockit"; copyleft
#property strict;
input double threshold = 0.5; // Threshold for Profit
void OnTick()
{
		string symbol_marketwatch = Symbol();
		double sum = 0;
		for(int j = OrdersTotal()-1; j >= 0; j--) {
			if(OrderSelect(j, SELECT_BY_POS) && symbol_marketwatch == Symbol() && OrderType() < 2)
				sum += OrderProfit();
		}
		if(sum >= threshold) {
			Print("closing all: ", symbol_marketwatch, " in profit of >= ", sum);
			for(int i = OrdersTotal()-1; i >= 0; i--) {
				if(OrderSelect(i, SELECT_BY_POS) && symbol_marketwatch == Symbol() && OrderType() < 2)
					if(!OrderClose(OrderTicket(), OrderLots(), OrderType() == OP_BUY ? MarketInfo(symbol_marketwatch, MODE_BID) : MarketInfo(symbol_marketwatch, MODE_ASK), 3))
						Print("close failed: ", GetLastError());
			}
		}
	}

