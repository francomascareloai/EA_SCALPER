// Função de gestão de risco
// Extraído de: Pyramid Hedging.mq4
// Data: 2025-08-13T01:36:15.480674

double CalculateLotSize(int tradeCount)
{
   double lotSize = BaseLotSize * MathPow(PyramidMultiplier, tradeCount);
   return MathMin(lotSize, MaxLotSize); // Cap at MaxLotSize
}