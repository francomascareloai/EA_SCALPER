// Função de gestão de risco
// Extraído de: XAUUSD_5DSMA_V1.mq4
// Data: 2025-08-13T01:37:07.983176

double CalculateLotSize(double riskPercent, double stopLossPips) {
   double baseLot;
   if(UseDynamicLotSize) {
      double riskMoney = AccountBalance() * (riskPercent / 100.0);
      double lotSize = riskMoney / (stopLossPips * MarketInfo(Symbol(), MODE_TICKVALUE));
      baseLot = lotSize;
   }