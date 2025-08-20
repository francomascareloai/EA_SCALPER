//+------------------------------------------------------------------+
//|                                                    TestEA.mq4 |
//|                        Copyright 2025, Teste Crítico Unificado |
//+------------------------------------------------------------------+

// Inputs
input double StopLoss = 50;        // Stop Loss em pontos
input double TakeProfit = 150;     // Take Profit em pontos
input double RiskPercent = 1.0;    // Risco por trade (%)
input int MaxTrades = 3;           // Máximo de trades simultâneos
input bool UseSessionFilter = true; // Usar filtro de sessão

// Variáveis globais
double AccountBalance;
int TotalTrades = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("TestEA inicializado - Balance: ", AccountBalance);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verificar filtro de sessão
   if(UseSessionFilter && (Hour() < 8 || Hour() > 18))
      return;
   
   // Verificar máximo de trades
   if(OrdersTotal() >= MaxTrades)
      return;
   
   // Calcular lot size baseado no risco
   double lotSize = CalculateLotSize();
   
   // Lógica de entrada simples (exemplo)
   if(iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 1) > 
      iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, 1))
   {
      // Abrir ordem de compra
      int ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 
                            Ask - StopLoss * Point, 
                            Ask + TakeProfit * Point, 
                            "TestEA Buy", 0, 0, clrGreen);
      
      if(ticket > 0)
         TotalTrades++;
   }
}

//+------------------------------------------------------------------+
//| Calcular lot size baseado no risco                              |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize = riskAmount / (StopLoss * tickValue);
   
   // Normalizar lot size
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return MathMax(minLot, MathMin(maxLot, lotSize));
}
