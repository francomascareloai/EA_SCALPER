// ------------------------------------------------------------------------------------------------
// Copyright © 2011, www.lifesdream.org
// http://www.lifesdream.org
// ------------------------------------------------------------------------------------------------
#include <stdlib.mqh>
#include <stderror.mqh> 
#property copyright "Copyright © 2013, www.lifesdream.org"
#property link "http://www.lifesdream.org"

// ------------------------------------------------------------------------------------------------
// VARIABLES EXTERNAS
// ------------------------------------------------------------------------------------------------

extern int magic = 161556;
// Configuration
extern string CommonSettings = "---------------------------------------------";
extern int user_slippage = 2; 
extern int user_tp = 40;
extern int user_sl = 40;
extern int use_tp_sl = 1;
extern double profit_lock = 0.90;
extern string MoneyManagementSettings = "---------------------------------------------";
// Money Management
extern int money_management = 1;
extern double min_lots = 0.1;
extern int risk=1;
extern int progression = 0; // 0=none | 1:ascending | 2:martingale
// Indicator
extern string IndicatorSettings = "---------------------------------------------";
extern int ema_fast = 10;
extern int ema_slow = 60;
extern int shift = 1;

// ------------------------------------------------------------------------------------------------
// VARIABLES GLOBALES
// ------------------------------------------------------------------------------------------------
string key = "EMA Cross EA v1.0";
// Definimos 1 variable para guardar los tickets
int order_tickets;
// Definimos 1 variable para guardar los lotes
double order_lots;
// Definimos 1 variable para guardar las valores de apertura de las ordenes
double order_price;
// Definimos 1 variable para guardar los beneficios
double order_profit;
// Definimos 1 variable para guardar los tiempos
int order_time;
// indicadores
double signal=0;
// Cantidad de ordenes;
int orders = 0;
int direction= 0;
double max_profit=0, close_profit=0;
double last_order_profit=0, last_order_lots=0;
// Colores
color c=Black;
// Cuenta
double balance, equity;
int slippage=0;
// OrderReliable
int retry_attempts = 10; 
double sleep_time = 4.0;
double sleep_maximum	= 25.0;  // in seconds
string OrderReliable_Fname = "OrderReliable fname unset";
static int _OR_err = 0;
string OrderReliableVersion = "V1_1_1"; 

// ------------------------------------------------------------------------------------------------
// START
// ------------------------------------------------------------------------------------------------
int start()
{  
  double point = MarketInfo(Symbol(), MODE_POINT);
  double dd=0;
  int ticket, i, n;
  double price;
  bool cerrada, encontrada;
  balance=AccountBalance();
  equity=AccountEquity();
  
  if (MarketInfo(Symbol(),MODE_DIGITS)==4)
  {
    slippage = user_slippage;
  }
  else if (MarketInfo(Symbol(),MODE_DIGITS)==5)
  {
    slippage = 10*user_slippage;
  }
  
  if(IsTradeAllowed() == false) 
  {
    Comment("Copyright © 2011, www.lifesdream.org\nTrade not allowed.");
    return;  
  }
  
  if (use_tp_sl==0)
    Comment(StringConcatenate("\nCopyright © 2013, www.lifesdream.org\nEMA Cross EA v1.0 is running.\nNext order lots: ",CalcularVolumen()));
  else if (use_tp_sl==1)  
    Comment(StringConcatenate("\nCopyright © 2013, www.lifesdream.org\nEMA Cross EA v1.0 is running.\nNext order lots: ",CalcularVolumen(),"\nTake profit ($): ",CalcularVolumen()*10*user_tp,"\nStop loss ($): ",CalcularVolumen()*10*user_sl));
  
  // Actualizamos el estado actual
  InicializarVariables();
  ActualizarOrdenes();
  
  encontrada=FALSE;
  if (OrdersHistoryTotal()>0)
  {
    i=1;
    
    while (i<=10 && encontrada==FALSE)
    { 
      n = OrdersHistoryTotal()-i;
      if(OrderSelect(n,SELECT_BY_POS,MODE_HISTORY)==TRUE)
      {
        if (OrderMagicNumber()==magic)
        {
          encontrada=TRUE;
          last_order_profit=OrderProfit();
          last_order_lots=OrderLots();
        }
      }
      i++;
    }
  }
  
  point = MarketInfo(Symbol(), MODE_POINT);
  
  Robot();
  
  return(0);
}


// ------------------------------------------------------------------------------------------------
// INICIALIZAR VARIABLES
// ------------------------------------------------------------------------------------------------
void InicializarVariables()
{
  // Reseteamos contadores de ordenes de compa y venta
  orders=0;
  direction=0;
  
  order_tickets = 0;
  order_lots = 0;
  order_price = 0;
  order_time = 0;
  order_profit = 0;
  
  last_order_profit = 0;
  last_order_lots = 0;
  
}

// ------------------------------------------------------------------------------------------------
// ACTUALIZAR ORDENES
// ------------------------------------------------------------------------------------------------
void ActualizarOrdenes()
{
  int ordenes=0;
  
  // Lo que hacemos es introducir los tickets, los lotes, y los valores de apertura en las matrices. 
  // Además guardaremos el número de ordenes en una variables.
  
  // Ordenes de compra
  for(int i=0; i<OrdersTotal(); i++)
  {
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
    {
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
      {
        order_tickets = OrderTicket();
        order_lots = OrderLots();
        order_price = OrderOpenPrice();
        order_time = OrderOpenTime();
        order_profit = OrderProfit();
        ordenes++;
        if (OrderType()==OP_BUY) direction=1;
        if (OrderType()==OP_SELL) direction=2;
      }
    }
  }
  
  // Actualizamos variables globales
  orders = ordenes;
}

// ------------------------------------------------------------------------------------------------
// CALCULAR VOLUMEN
// ------------------------------------------------------------------------------------------------
double CalcularVolumen()
{ 
  double aux; 
  int n;
  
  if (money_management==0)
  {
    aux=min_lots;
  }
  else
  {    
    if (progression==0) 
    { 
      aux = risk*AccountFreeMargin();
      aux= aux/100000;
      n = MathFloor(aux/min_lots);
      
      aux = n*min_lots;                   
    }  
  
    if (progression==1)
    {
      if (last_order_profit<0)
      {
        aux = last_order_lots+min_lots;
      }
      else 
      {
        aux = last_order_lots-min_lots;
      }  
    }        
    
    if (progression==2)
    {
      if (last_order_profit<0)
      {
        aux = last_order_lots*2;
      }
      else 
      {
         aux = risk*AccountFreeMargin();
         aux= aux/100000;
         n = MathFloor(aux/min_lots);
         
         aux = n*min_lots;         
      }  
    }     
    
    if (aux<min_lots)
        aux=min_lots;
     
    if (aux>MarketInfo(Symbol(),MODE_MAXLOT))
      aux=MarketInfo(Symbol(),MODE_MAXLOT);
      
    if (aux<MarketInfo(Symbol(),MODE_MINLOT))
      aux=MarketInfo(Symbol(),MODE_MINLOT);
  }
  
  return(aux);
}

// ------------------------------------------------------------------------------------------------
// CALCULA VALOR PIP
// ------------------------------------------------------------------------------------------------
double CalculaValorPip(double lotes)
{ 
   double aux_mm_valor=0;
   
   double aux_mm_tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);
   double aux_mm_tick_size = MarketInfo(Symbol(), MODE_TICKSIZE);
   int aux_mm_digits = MarketInfo(Symbol(),MODE_DIGITS);   
   double aux_mm_veces_lots = 1/lotes;
      
   if (aux_mm_digits==5)
   {
     aux_mm_valor=aux_mm_tick_value*10;
   }
   else if (aux_mm_digits==4)
   {
     aux_mm_valor = aux_mm_tick_value;
   }
   
   if (aux_mm_digits==3)
   {
     aux_mm_valor=aux_mm_tick_value*10;
   }
   else if (aux_mm_digits==2)
   {
     aux_mm_valor = aux_mm_tick_value;
   }
   
   aux_mm_valor = aux_mm_valor/aux_mm_veces_lots;
   
   return(aux_mm_valor);
}

// ------------------------------------------------------------------------------------------------
// CALCULA TAKE PROFIT
// ------------------------------------------------------------------------------------------------
int CalculaTakeProfit()
{ 
  int aux_take_profit;      
  
  aux_take_profit=MathRound(CalculaValorPip(order_lots)*user_tp);  

  return(aux_take_profit);
}

// ------------------------------------------------------------------------------------------------
// CALCULA STOP LOSS
// ------------------------------------------------------------------------------------------------
int CalculaStopLoss()
{ 
  int aux_stop_loss;      
  
  aux_stop_loss=-1*MathRound(CalculaValorPip(order_lots)*user_sl);
    
  return(aux_stop_loss);
}

// ------------------------------------------------------------------------------------------------
// CALCULA SIGNAL
// ------------------------------------------------------------------------------------------------

int CalculaSignal(int ema_fast, int ema_slow, int aux_shift)
{
  int aux=0;   
  
  double ema_fast_1=iMA(Symbol(),0,ema_fast,0,MODE_EMA,PRICE_CLOSE,aux_shift);
  double ema_fast_2=iMA(Symbol(),0,ema_fast,0,MODE_EMA,PRICE_CLOSE,aux_shift+1);
  double ema_slow_1=iMA(Symbol(),0,ema_slow,0,MODE_EMA,PRICE_CLOSE,aux_shift);
  double ema_slow_2=iMA(Symbol(),0,ema_slow,0,MODE_EMA,PRICE_CLOSE,aux_shift+1);

  // Valores de retorno
  // 1. Compra
  // 2. Venta
  if (ema_fast_1>ema_slow_1 && ema_fast_2<ema_slow_2) aux=1;
  if (ema_fast_1<ema_slow_1 && ema_fast_2>ema_slow_2) aux=2;
   
  return(aux);  
}

// ------------------------------------------------------------------------------------------------
// ROBOT
// ------------------------------------------------------------------------------------------------
void Robot()
{
  int ticket=-1, i;
  bool cerrada=FALSE;  
  
  if (orders==0 && direction==0)
  {     
    signal = CalculaSignal(ema_fast,ema_slow,shift);
    // ----------
    // COMPRA
    // ----------
    if (signal==1)
      ticket = OrderSendReliable(Symbol(),OP_BUY,CalcularVolumen(),MarketInfo(Symbol(),MODE_ASK),slippage,0,0,key,magic,0,Blue); 
    // En este punto hemos ejecutado correctamente la orden de compra
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()
     
    // ----------
    // VENTA
    // ----------
    if (signal==2)
      ticket = OrderSendReliable(Symbol(),OP_SELL,CalcularVolumen(),MarketInfo(Symbol(),MODE_BID),slippage,0,0,key,magic,0,Red);         
    // En este punto hemos ejecutado correctamente la orden de venta
    // Los arrays se actualizarán en la siguiente ejecución de start() con ActualizarOrdenes()       
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=1
  // **************************************************
  if (orders>0 && direction==1 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit > CalculaTakeProfit() && max_profit==0)
    {
      max_profit = order_profit;
      close_profit = profit_lock*order_profit;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit>0)
    {
      if (order_profit>max_profit)
      {      
        max_profit = order_profit;
        close_profit = profit_lock*order_profit; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit>0 && close_profit>0 && max_profit>close_profit && order_profit<close_profit) 
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit=0;
      close_profit=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit <= CalculaStopLoss())
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit=0;
      close_profit=0;  
    }   
    
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=1
  // **************************************************
  if (orders>0 && direction==2 && use_tp_sl==1)
  {
    // CASO 1.1 >>> Tenemos el beneficio y  activamos el profit lock
    if (order_profit > CalculaTakeProfit() && max_profit==0)
    {
      max_profit = order_profit;
      close_profit = profit_lock*order_profit;      
    } 
    // CASO 1.2 >>> Segun va aumentando el beneficio actualizamos el profit lock
    if (max_profit>0)
    {
      if (order_profit>max_profit)
      {      
        max_profit = order_profit;
        close_profit = profit_lock*order_profit; 
      }
    }   
    // CASO 1.3 >>> Cuando el beneficio caiga por debajo de profit lock cerramos las ordenes
    if (max_profit>0 && close_profit>0 && max_profit>close_profit && order_profit<close_profit) 
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit=0;
      close_profit=0;  
    }
      
    // CASO 2 >>> Tenemos "size" pips de perdida
    if (order_profit <= CalculaStopLoss())
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit=0;
      close_profit=0;  
    }   
  }
  
  // **************************************************
  // ORDERS>0 AND DIRECTION=1 AND USE_TP_SL=0
  // **************************************************
  if (orders>0 && direction==1 && use_tp_sl==0)
  {
    signal = CalculaSignal(ema_fast,ema_slow,shift);
    if (signal==2)
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_BID),slippage,Blue);
      max_profit=0;
      close_profit=0;    
    }  
  }
    
  // **************************************************
  // ORDERS>0 AND DIRECTION=2 AND USE_TP_SL=0
  // **************************************************
  if (orders>0 && direction==2 && use_tp_sl==0)
  {
    signal = CalculaSignal(ema_fast,ema_slow,shift);
    if (signal==1)
    {
      cerrada=OrderCloseReliable(order_tickets,order_lots,MarketInfo(Symbol(),MODE_ASK),slippage,Red);
      max_profit=0;
      close_profit=0;   
    }  
  }    
    
}


//=============================================================================
//							 OrderSendReliable()
//
//	This is intended to be a drop-in replacement for OrderSend() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//	Ticket number or -1 under some error conditions.  Check
// final error returned by Metatrader with OrderReliableLastErr().
// This will reset the value from GetLastError(), so in that sense it cannot
// be a total drop-in replacement due to Metatrader flaw. 
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Automatic normalization of Digits
//
//		 * Automatically makes sure that stop levels are more than
//		   the minimum stop distance, as given by the server. If they
//		   are too close, they are adjusted.
//
//		 * Automatically converts stop orders to market orders 
//		   when the stop orders are rejected by the server for 
//		   being to close to market.  NOTE: This intentionally
//       applies only to OP_BUYSTOP and OP_SELLSTOP, 
//       OP_BUYLIMIT and OP_SELLLIMIT are not converted to market
//       orders and so for prices which are too close to current
//       this function is likely to loop a few times and return
//       with the "invalid stops" error message. 
//       Note, the commentary in previous versions erroneously said
//       that limit orders would be converted.  Note also
//       that entering a BUYSTOP or SELLSTOP new order is distinct
//       from setting a stoploss on an outstanding order; use
//       OrderModifyReliable() for that. 
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, 2006-05-28 and following
//
//=============================================================================
int OrderSendReliable(string symbol, int cmd, double volume, double price,
					  int slippage, double stoploss, double takeprofit,
					  string comment, int magic, datetime expiration = 0, 
					  color arrow_color = CLR_NONE) 
{

	// ------------------------------------------------
	// Check basic conditions see if trade is possible. 
	// ------------------------------------------------
	OrderReliable_Fname = "OrderSendReliable";
	OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + volume + 
						" lots @" + price + " sl:" + stoploss + " tp:" + takeprofit); 
						
	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(-1);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		_OR_err = ERR_COMMON_ERROR; 
		return(-1);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
		cnt++;
	}
	
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 

		return(-1);  
	}

	// Normalize all price / stoploss / takeprofit to the proper # of digits.
	int digits = MarketInfo(symbol, MODE_DIGITS);
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(symbol, price, stoploss); 

	int err = GetLastError(); // clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	bool limit_to_market = false; 
	
	// limit/stop order. 
	int ticket=-1;

	if ((cmd == OP_BUYSTOP) || (cmd == OP_SELLSTOP) || (cmd == OP_BUYLIMIT) || (cmd == OP_SELLLIMIT)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
				ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, 
									takeprofit, comment, magic, expiration, arrow_color);
				err = GetLastError();
				_OR_err = err; 
			} 
			else 
			{
				cnt++;
			} 
			
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
				
				// retryable errors
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; 
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
					continue;	// we can apparently retry immediately according to MT docs.
					
				case ERR_INVALID_STOPS:
					double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
					if (cmd == OP_BUYSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(MarketInfo(symbol,MODE_ASK) - price) <= servers_min_stop)	
							limit_to_market = true; 
							
					} 
					else if (cmd == OP_SELLSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(MarketInfo(symbol,MODE_BID) - price) <= servers_min_stop)
							limit_to_market = true; 
					}
					exit_loop = true; 
					break; 
					
				default:
					// an apparently serious error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
				exit_loop = true; 
			 	
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
				}
			}
			 
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + cnt + "/" + retry_attempts + 
									"): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
				RefreshRates(); 
			}
		}
		 
		// We have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			OrderReliablePrint("apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
			OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		if (!limit_to_market) 
		{
			OrderReliablePrint("failed to execute stop or limit order after " + cnt + " retries");
			OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
								"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
			OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
			return(-1); 
		}
	}  // end	  
  
	if (limit_to_market) 
	{
		OrderReliablePrint("going from limit order to market order because market is too close.");
		if ((cmd == OP_BUYSTOP) || (cmd == OP_BUYLIMIT)) 
		{
			cmd = OP_BUY;
			price = MarketInfo(symbol,MODE_ASK);
		} 
		else if ((cmd == OP_SELLSTOP) || (cmd == OP_SELLLIMIT)) 
		{
			cmd = OP_SELL;
			price = MarketInfo(symbol,MODE_BID);
		}	
	}
	
	// we now have a market order.
	err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	ticket = -1;

	if ((cmd == OP_BUY) || (cmd == OP_SELL)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
				ticket = OrderSend(symbol, cmd, volume, price, slippage, 
									stoploss, takeprofit, comment, magic, 
									expiration, arrow_color);
				err = GetLastError();
				_OR_err = err; 
			} 
			else 
			{
				cnt++;
			} 
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
					
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; // a retryable error
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
					continue; // we can apparently retry immediately according to MT docs.
					
				default:
					// an apparently serious, unretryable error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
			 	exit_loop = true; 
			 	
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + cnt + "/" + 
									retry_attempts + "): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
				RefreshRates(); 
			}
			
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
				}
			}
		}
		
		// we have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
			OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + cnt + " retries");
		OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
							"@" + price + " tp@" + takeprofit + " sl@" + stoploss); 
		OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
		return(-1); 
	}
}

//=============================================================================
//							 OrderCloseReliable()
//
//	This is intended to be a drop-in replacement for OrderClose() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//		TRUE if successful, FALSE otherwise
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Derk Wehler, ashwoods155@yahoo.com  	2006-07-19
//
//=============================================================================
bool OrderCloseReliable(int ticket, double lots, double price, 
						int slippage, color arrow_color = CLR_NONE) 
{
	int nOrderType;
	string strSymbol;
	OrderReliable_Fname = "OrderCloseReliable";
	
	OrderReliablePrint(" attempted close of #" + ticket + " price:" + price + 
						" lots:" + lots + " slippage:" + slippage); 

// collect details of order so that we can use GetMarketInfo later if needed
	if (!OrderSelect(ticket,SELECT_BY_TICKET))
	{
		_OR_err = GetLastError();		
		OrderReliablePrint("error: " + ErrorDescription(_OR_err));
		return(false);
	}
	else
	{
		nOrderType = OrderType();
		strSymbol = OrderSymbol();
	}

	if (nOrderType != OP_BUY && nOrderType != OP_SELL)
	{
		_OR_err = ERR_INVALID_TICKET;
		OrderReliablePrint("error: trying to close ticket #" + ticket + ", which is " + OrderReliable_CommandString(nOrderType) + ", not OP_BUY or OP_SELL");
		return(false);
	}

	//if (!IsConnected()) 
	//{
	//	OrderReliablePrint("error: IsConnected() == false");
	//	_OR_err = ERR_NO_CONNECTION; 
	//	return(false);
	//}
	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		return(false);
	}

	
	int cnt = 0;
/*	
	Commented out by Paul Hampton-Smith due to a bug in MT4 that sometimes incorrectly returns IsTradeAllowed() = false
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
		cnt++;
	}
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 
		return(false);  
	}
*/

	int err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	cnt = 0;
	bool result = false;
	
	while (!exit_loop) 
	{
		if (IsTradeAllowed()) 
		{
			result = OrderClose(ticket, lots, price, slippage, arrow_color);
			err = GetLastError();
			_OR_err = err; 
		} 
		else 
			cnt++;

		if (result == true) 
			exit_loop = true;

		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
				
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
				
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
				continue; 	// we can apparently retry immediately according to MT docs.
				
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
				
		}  // end switch 

		if (cnt > retry_attempts) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
			OrderReliablePrint("retryable error (" + cnt + "/" + retry_attempts + 
								"): "  +  OrderReliableErrTxt(err)); 
			OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
			// Added by Paul Hampton-Smith to ensure that price is updated for each retry
			if (nOrderType == OP_BUY)  price = NormalizeDouble(MarketInfo(strSymbol,MODE_BID),MarketInfo(strSymbol,MODE_DIGITS));
			if (nOrderType == OP_SELL) price = NormalizeDouble(MarketInfo(strSymbol,MODE_ASK),MarketInfo(strSymbol,MODE_DIGITS));
		}
		
		if (exit_loop) 
		{
			if ((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT)) 
				OrderReliablePrint("non-retryable error: "  + OrderReliableErrTxt(err)); 

			if (cnt > retry_attempts) 
				OrderReliablePrint("retry attempts maxed at " + retry_attempts); 
		}
	}  
	
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		OrderReliablePrint("apparently successful close order, updated trade details follow.");
		OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		OrderPrint(); 
		return(true); // SUCCESS! 
	} 
	
	OrderReliablePrint("failed to execute close after " + cnt + " retries");
	OrderReliablePrint("failed close: Ticket #" + ticket + ", Price: " + 
						price + ", Slippage: " + slippage); 
	OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
	
	return(false);  
}
 
 

//=============================================================================
//=============================================================================
//								Utility Functions
//=============================================================================
//=============================================================================
string OrderReliableErrTxt(int err) 
{
	return ("" + err + ":" + ErrorDescription(err)); 
}


void OrderReliablePrint(string s) 
{
	// Print to log prepended with stuff;
	if (!(IsTesting() || IsOptimization())) Print(OrderReliable_Fname + " " + OrderReliableVersion + ":" + s);
}


string OrderReliable_CommandString(int cmd) 
{
	if (cmd == OP_BUY) 
		return("OP_BUY");

	if (cmd == OP_SELL) 
		return("OP_SELL");

	if (cmd == OP_BUYSTOP) 
		return("OP_BUYSTOP");

	if (cmd == OP_SELLSTOP) 
		return("OP_SELLSTOP");

	if (cmd == OP_BUYLIMIT) 
		return("OP_BUYLIMIT");

	if (cmd == OP_SELLLIMIT) 
		return("OP_SELLLIMIT");

	return("(CMD==" + cmd + ")"); 
}


//=============================================================================
//
//						 OrderReliable_EnsureValidStop()
//
// 	Adjust stop loss so that it is legal.
//
//	Matt Kennel 
//
//=============================================================================
void OrderReliable_EnsureValidStop(string symbol, double price, double& sl) 
{
	// Return if no S/L
	if (sl == 0) 
		return;
	
	double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
	
	if (MathAbs(price - sl) <= servers_min_stop) 
	{
		// we have to adjust the stop.
		if (price > sl)
			sl = price - servers_min_stop;	// we are long
			
		else if (price < sl)
			sl = price + servers_min_stop;	// we are short
			
		else
			OrderReliablePrint("EnsureValidStop: error, passed in price == sl, cannot adjust"); 
			
		sl = NormalizeDouble(sl, MarketInfo(symbol, MODE_DIGITS)); 
	}
}


//=============================================================================
//
//						 OrderReliable_SleepRandomTime()
//
//	This sleeps a random amount of time defined by an exponential 
//	probability distribution. The mean time, in Seconds is given 
//	in 'mean_time'.
//
//	This is the back-off strategy used by Ethernet.  This will 
//	quantize in tenths of seconds, so don't call this with a too 
//	small a number.  This returns immediately if we are backtesting
//	and does not sleep.
//
//	Matt Kennel mbkennelfx@gmail.com.
//
//=============================================================================
void OrderReliable_SleepRandomTime(double mean_time, double max_time) 
{
	if (IsTesting()) 
		return; 	// return immediately if backtesting.

	double tenths = MathCeil(mean_time / 0.1);
	if (tenths <= 0) 
		return; 
	 
	int maxtenths = MathRound(max_time/0.1); 
	double p = 1.0 - 1.0 / tenths; 
	  
	Sleep(100); 	// one tenth of a second PREVIOUS VERSIONS WERE STUPID HERE. 
	
	for(int i=0; i < maxtenths; i++)  
	{
		if (MathRand() > p*32768) 
			break; 
			
		// MathRand() returns in 0..32767
		Sleep(100); 
	}
}  


