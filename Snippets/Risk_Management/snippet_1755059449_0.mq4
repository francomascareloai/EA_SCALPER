// Função de gestão de risco
// Extraído de: 2PSAR.mq4
// Data: 2025-08-13T01:30:49.874324

double CalculateLotSize(int orderType, bool inDrawdown) {
    int orderCount=CountOrders(orderType);
    if(orderCount==0) return NormalizeDouble(currentLotSize,2);
    double k=0.01,b=1.0;
    if(inDrawdown) return NormalizeDouble(MathMax(0.01, firstOrderLotSize + k * MathLog(orderCount + b)), 2);
    return NormalizeDouble(MathMax(0.01, lastOrderLotSize - k * MathLog(orderCount + b)), 2);
}