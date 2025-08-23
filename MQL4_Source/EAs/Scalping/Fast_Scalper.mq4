// RECONSTRUÍDO POR MQL-Reverser - 100% PRECISÃO - NÃO MODIFICAR
// Fast Scalper EA - Sistema de Scalping para XAUUSD
// Versão: 1.00
// Compatível: MetaTrader 4

#property version "1.00"
#property strict

// Parâmetros de entrada
input double Lote = 0.01;
input int TakeProfit = 10;
input int StopLoss = 5;
input int MagicNumber = 12345;

// Variáveis globais
int lastBarTime = 0;

//+------------------------------------------------------------------+
//| Função de inicialização do Expert                                 |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Fast Scalper EA iniciado - MagicNumber: ", MagicNumber);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função principal de execução                                     |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verifica se é uma nova barra
   if(!IsNewBar())
      return;
   
   // Verifica condições de compra
   if(CheckBuyCondition())
   {
      double ask = MarketInfo(Symbol(), MODE_ASK);
      double tp = ask + (TakeProfit * Point);
      double sl = ask - (StopLoss * Point);
      
      int ticket = OrderSend(Symbol(), OP_BUY, Lote, ask, 2, sl, tp, "Fast Scalper BUY", MagicNumber, 0, clrGreen);
      
      if(ticket > 0)
         Print("Ordem de COMPRA enviada - Ticket: ", ticket);
      else
         Print("Erro ao enviar ordem de COMPRA: ", GetLastError());
   }
   
   // Verifica condições de venda
   if(CheckSellCondition())
   {
      double bid = MarketInfo(Symbol(), MODE_BID);
      double tp = bid - (TakeProfit * Point);
      double sl = bid + (StopLoss * Point);
      
      int ticket = OrderSend(Symbol(), OP_SELL, Lote, bid, 2, sl, tp, "Fast Scalper SELL", MagicNumber, 0, clrRed);
      
      if(ticket > 0)
         Print("Ordem de VENDA enviada - Ticket: ", ticket);
      else
         Print("Erro ao enviar ordem de VENDA: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Verifica condição de compra                                      |
//+------------------------------------------------------------------+
bool CheckBuyCondition()
{
   // Estratégia: Cruza de médias móveis + RSI
   double maFast = iMA(Symbol(), 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   double maSlow = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
   
   // Verifica cruzamento de médias e RSI em nível de sobre-venda
   if(maFast > maSlow && rsi < 30)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Verifica condição de venda                                       |
//+------------------------------------------------------------------+
bool CheckSellCondition()
{
   // Estratégia: Cruza de médias móveis + RSI
   double maFast = iMA(Symbol(), 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   double maSlow = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
   
   // Verifica cruzamento de médias e RSI em nível de sobre-compra
   if(maFast < maSlow && rsi > 70)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Verifica se é uma nova barra                                     |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   if(lastBarTime != Time[0])
   {
      lastBarTime = Time[0];
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Função de desinicialização do Expert                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Fast Scalper EA finalizado - Razão: ", reason);
}