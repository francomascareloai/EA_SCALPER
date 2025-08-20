// Função de gestão de risco
// Extraído de: XU Trend Following EA (4).mq4
// Data: 2025-08-13T01:37:10.487989

double CalculateLotSize()
{
   if(currentMartingaleStep == 0 || lastLoss == 0.0) return LotSize;
   if(currentMartingaleStep >= MaxMartingaleSteps) return LotSize;
   return LotSize * MathPow(MartingaleMultiplier, currentMartingaleStep);
}