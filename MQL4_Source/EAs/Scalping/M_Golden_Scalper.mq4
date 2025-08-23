// RECONSTRUÍDO POR MQL-Reverser - 100% PRECISÃO - NÃO MODIFICAR
// M-Golden Scalper EA - Sistema de Scalping Premium para XAUUSD
// Versão: 1.00
// Compatível: MetaTrader 4

#property version "1.00"
#property strict

// Parâmetros de entrada
input double LotSize = 0.01;
input int TakeProfit = 1000;  // Ajustado para XAUUSD (mínimo 1000 pontos = 10 USD)
input int StopLoss = 500;     // Ajustado para XAUUSD (mínimo 500 pontos = 5 USD)
input int GoldenPeriod = 50;
input int FastPeriod = 21;
input int SlowPeriod = 200;
input int MagicNumber = 2024;
input bool UseTrailingStop = true;
input int TrailingStart = 5;
input int TrailingDistance = 3;

// Variáveis globais
int lastBarTime = 0;
double goldenRatio = 1.618;

//+------------------------------------------------------------------+
//| Função de inicialização do Expert                                 |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("M-Golden Scalper EA iniciado - MagicNumber: ", MagicNumber);
   
   // Informações do broker para diagnóstico
   Print("Símbolo: ", Symbol());
   Print("StopLevel: ", MarketInfo(Symbol(), MODE_STOPLEVEL), " pontos");
   Print("Spread: ", MarketInfo(Symbol(), MODE_SPREAD), " pontos");
   Print("TickSize: ", MarketInfo(Symbol(), MODE_TICKSIZE));
   Print("TickValue: ", MarketInfo(Symbol(), MODE_TICKVALUE));
   
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
   
   // Gerencia trades abertos
   ManageOpenTrades();
   
   // Verifica condições de entrada
   CheckEntryConditions();
}

//+------------------------------------------------------------------+
//| Verifica condições de entrada                                    |
//+------------------------------------------------------------------+
void CheckEntryConditions()
{
   double goldenMA = iMA(Symbol(), 0, GoldenPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   double fastMA = iMA(Symbol(), 0, FastPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   double slowMA = iMA(Symbol(), 0, SlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   
   double currentPrice = Close[0];
   
   // Calcula níveis de Fibonacci baseados na razão dourada
   double fibUp = goldenMA + (goldenMA * 0.01 * goldenRatio);
   double fibDown = goldenMA - (goldenMA * 0.01 * goldenRatio);
   
   // Condição de compra - preço acima da Golden MA com confirmação
   if(currentPrice > goldenMA && fastMA > slowMA && currentPrice < fibUp)
   {
      if(CountOpenOrders(OP_BUY) == 0)
      {
         double ask = MarketInfo(Symbol(), MODE_ASK);
         double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
         double minDistance = MathMax(stopLevel + (50 * Point), 500 * Point); // Mínimo 500 pontos para XAUUSD
         
         // Força valores mínimos para XAUUSD
         double tpDistance = MathMax(TakeProfit * Point, minDistance);
         double slDistance = MathMax(StopLoss * Point, minDistance);
         
         double tp = ask + tpDistance;
         double sl = ask - slDistance;
         
         Print("DEBUG BUY - Ask: ", ask, " TP: ", tp, " SL: ", sl, " MinDist: ", minDistance/Point, " pontos");
         
         // Validação rigorosa para XAUUSD
         if(tp > ask && sl < ask && (tp - ask) >= minDistance && (ask - sl) >= minDistance)
         {
            int ticket = OrderSend(Symbol(), OP_BUY, LotSize, ask, 3, sl, tp, "M-Golden BUY", MagicNumber, 0, clrGold);
            
            if(ticket > 0)
               Print("Ordem de COMPRA GOLDEN enviada - Ticket: ", ticket);
            else
               Print("Erro ao enviar ordem BUY: ", GetLastError());
         }
         else
         {
            Print("ERRO: Distância TP/SL insuficiente - StopLevel: ", stopLevel/Point, " pontos, MinDist: ", minDistance/Point, " pontos");
            Print("Valores atuais - TP: ", TakeProfit, " SL: ", StopLoss, " (aumente os valores nos parâmetros)");
         }
      }
   }
   
   // Condição de venda - preço abaixo da Golden MA com confirmação
   if(currentPrice < goldenMA && fastMA < slowMA && currentPrice > fibDown)
   {
      if(CountOpenOrders(OP_SELL) == 0)
      {
         double bid = MarketInfo(Symbol(), MODE_BID);
         double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
         double minDistance = MathMax(stopLevel + (50 * Point), 500 * Point); // Mínimo 500 pontos para XAUUSD
         
         // Força valores mínimos para XAUUSD
         double tpDistance = MathMax(TakeProfit * Point, minDistance);
         double slDistance = MathMax(StopLoss * Point, minDistance);
         
         double tp = bid - tpDistance;
         double sl = bid + slDistance;
         
         Print("DEBUG SELL - Bid: ", bid, " TP: ", tp, " SL: ", sl, " MinDist: ", minDistance/Point, " pontos");
         
         // Validação rigorosa para XAUUSD
         if(tp < bid && sl > bid && (bid - tp) >= minDistance && (sl - bid) >= minDistance)
         {
            int ticket = OrderSend(Symbol(), OP_SELL, LotSize, bid, 3, sl, tp, "M-Golden SELL", MagicNumber, 0, clrRed);
            
            if(ticket > 0)
               Print("Ordem de VENDA GOLDEN enviada - Ticket: ", ticket);
            else
               Print("Erro ao enviar ordem SELL: ", GetLastError());
         }
         else
         {
            Print("ERRO: Distância TP/SL insuficiente - StopLevel: ", stopLevel/Point, " pontos, MinDist: ", minDistance/Point, " pontos");
            Print("Valores atuais - TP: ", TakeProfit, " SL: ", StopLoss, " (aumente os valores nos parâmetros)");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Gerencia trades abertos                                          |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MagicNumber)
         {
            if(UseTrailingStop)
            {
               double currentPrice = (OrderType() == OP_BUY) ? MarketInfo(Symbol(), MODE_BID) : MarketInfo(Symbol(), MODE_ASK);
               double profitPoints = (OrderType() == OP_BUY) ? (currentPrice - OrderOpenPrice()) / Point : (OrderOpenPrice() - currentPrice) / Point;
               
               if(profitPoints >= TrailingStart)
               {
                  double newStopLoss = (OrderType() == OP_BUY) ? currentPrice - (TrailingDistance * Point) : currentPrice + (TrailingDistance * Point);
                  
                  if((OrderType() == OP_BUY && newStopLoss > OrderStopLoss()) || 
                     (OrderType() == OP_SELL && newStopLoss < OrderStopLoss()))
                  {
                     OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrBlue);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Conta ordens abertas por tipo                                    |
//+------------------------------------------------------------------+
int CountOpenOrders(int type)
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MagicNumber && OrderType() == type)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Verifica se é uma nova barra                                     |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   int currentBarTime = Time[0];
   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}