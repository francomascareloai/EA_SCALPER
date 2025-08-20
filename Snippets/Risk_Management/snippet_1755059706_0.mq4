// Função de gestão de risco
// Extraído de: FVG.mq4
// Data: 2025-08-13T01:35:06.562729

double CalculateLotSize(double riskAmount, double stopDistance)
{
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double lotSize = riskAmount / (stopDistance / tickSize * tickValue);
    
    // Normalize lot size
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
    
    return lotSize;
}