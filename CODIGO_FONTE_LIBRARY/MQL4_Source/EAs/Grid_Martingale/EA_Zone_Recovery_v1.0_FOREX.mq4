#property copyright "Copyright 2025 Matt Todorovski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Input parameters
input int ZoneRange = 100;              // Zone range in pips
input int MagicNumber = 20250201;       // Magic number for order identification
input double MaxAllowedSpread = 60.0;   // Maximum allowed spread in pips
input string TradeComment = "Zone Recovery EA"; // Comment for trades
input double InitialLot = 0.01;         // Initial lot size

// Global variables
double ZoneHeight, UpperZone, LowerZone, FirstOrderOpenPrice = 0, ProfitTarget = 0.0;
int BuyCount = 0, SellCount = 0, OrderSequence = 0, FirstOrderTicket = 0;
bool ZoneEstablished = false, ZoneLocked = false, InitialCheck = true;
datetime LastLogTime = 0;

int OnInit() {
   ProfitTarget = 1.5 * ZoneRange;
   CalculateZoneFromPips();
   ZoneEstablished = true;
   
   if (IsSpreadAcceptable()) {
      PlaceInitialOrder();
   }
   
   return(INIT_SUCCEEDED);
}

void OnTick() {
    if (InitialCheck) {
        InitialCheck = false;
        CheckExistingOrders();
        
        if (CountEAOrders() > 0) {
            CheckExistingOrdersForLoss();
        }
    }
    
    if (CountEAOrders() == 0 && !ZoneLocked) {
        CalculateZoneFromPips();
        ZoneEstablished = true;
        OrderSequence = 0;
        FirstOrderTicket = 0;
        FirstOrderOpenPrice = 0;
    }
    
    if (OrderSequence == 0 && CountEAOrders() == 0) {
        if (IsSpreadAcceptable()) {
            PlaceInitialOrder();
        }
    } else if (CountEAOrders() > 0) {
        CheckProfitClosure();
        ManageOrderSequence();
    }
}

void LogMessage(string message) {
    if (StringFind(message, "Error") >= 0) {
        Print(message);
    }
}

void CheckExistingOrders() {
    if (CountEAOrders() > 0) {
        int oldestTicket = FindOldestOrder();
        
        if (oldestTicket > 0 && OrderSelect(oldestTicket, SELECT_BY_TICKET)) {
            FirstOrderTicket = oldestTicket;
            FirstOrderOpenPrice = OrderOpenPrice();
            ZoneLocked = true;
            OrderSequence = CountEAOrders();
            CalculateZoneFromPips();
            ZoneEstablished = true;
            UpdateOrderCounts();
        }
    }
}

int FindOldestOrder() {
    int oldestTicket = 0;
    datetime oldestTime = TimeCurrent();
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderMagicNumber() == MagicNumber && 
            (OrderType() == OP_BUY || OrderType() == OP_SELL) &&
            OrderSymbol() == Symbol()) {
            if (OrderOpenTime() < oldestTime) {
                oldestTime = OrderOpenTime();
                oldestTicket = OrderTicket();
            }
        }
    }
    
    return oldestTicket;
}

void CheckExistingOrdersForLoss() {
    int firstOrderLossPips = GetFirstOrderLossInPips();
    int totalProfitPips = CalculateTotalProfitInPips();
    UpdateOrderCounts();
    
    if (OrderSequence == 1 && firstOrderLossPips <= -ZoneRange) {
        if (IsSpreadAcceptable()) {
            PlaceHedgeOrder();
            OrderSequence = 2;
        }
    } else if (OrderSequence >= 2) {
        int nextOrderThreshold = (int)(-ZoneRange * 1.5);
        
        if (totalProfitPips <= nextOrderThreshold) {
            if (IsSpreadAcceptable()) {
                PlaceNextRecoveryOrder();
                OrderSequence++;
            }
        } else {
            bool continueSequence = false;
            if (OrderSequence % 2 == 0 && BuyCount != SellCount) {
                continueSequence = true;
            }
            
            if (continueSequence && IsSpreadAcceptable()) {
                PlaceNextRecoveryOrder();
                OrderSequence++;
            }
        }
    }
}

int CountEAOrders() {
    int count = 0;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && 
            (OrderType() == OP_BUY || OrderType() == OP_SELL) &&
            OrderSymbol() == Symbol()) {
            count++;
        }
    }
    
    return count;
}

// Modified function to correctly handle different symbol formats
void CalculateZoneFromPips() {
    double point = MarketInfo(Symbol(), MODE_POINT);
    int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
    double pipMultiplier;
    
    // Handle different price formats correctly
    if (digits == 3 || digits == 5) {
        pipMultiplier = 10.0;
    } else if (digits == 2 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 100.0;  // For XAUUSD with 2 digits
    } else if (digits == 3 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 1000.0; // For XAUUSD with 3 digits
    } else {
        pipMultiplier = 1.0;
    }
    
    double priceMovement = ZoneRange * point * pipMultiplier;
    
    ZoneHeight = priceMovement;
    
    if (FirstOrderTicket > 0 && OrderSelect(FirstOrderTicket, SELECT_BY_TICKET)) {
        UpperZone = FirstOrderOpenPrice + ZoneHeight;
        LowerZone = FirstOrderOpenPrice - ZoneHeight;
    } else {
        double midPrice = (Ask + Bid) / 2;
        UpperZone = midPrice + ZoneHeight;
        LowerZone = midPrice - ZoneHeight;
    }
    
    ProfitTarget = 1.5 * ZoneRange;
}

bool IsSpreadAcceptable() {
    return GetCurrentSpreadPips() <= MaxAllowedSpread;
}

// Modified function to correctly handle different symbol formats
double GetCurrentSpreadPips() {
    double spread = MarketInfo(Symbol(), MODE_SPREAD);
    int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
    
    if (digits == 3 || digits == 5) {
        return spread / 10.0;
    } else if (digits == 2 && StringFind(Symbol(), "XAU") >= 0) {
        return spread / 100.0;  // For XAUUSD with 2 digits
    } else if (digits == 3 && StringFind(Symbol(), "XAU") >= 0) {
        return spread / 1000.0; // For XAUUSD with 3 digits
    } else {
        return spread;
    }
}

bool IsPriceAtZone(bool isUpperZone) {
    double price = isUpperZone ? Ask : Bid;
    double zone = isUpperZone ? UpperZone : LowerZone;
    double tolerance = MarketInfo(Symbol(), MODE_POINT) * 10;
    
    return MathAbs(price - zone) <= tolerance;
}

void PlaceInitialOrder() {
    double lotSize = InitialLot;
    int ticket = 0;
    
    if (IsPriceAtZone(true)) {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 5, 0, 0, TradeComment, MagicNumber, 0, Blue);
        if (ticket > 0) {
            FirstOrderTicket = ticket;
            FirstOrderOpenPrice = Ask;
            OrderSequence = 1;
            ZoneLocked = true;
        } else {
            LogMessage("Error placing BUY order: " + IntegerToString(GetLastError()));
        }
    } else if (IsPriceAtZone(false)) {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 5, 0, 0, TradeComment, MagicNumber, 0, Red);
        if (ticket > 0) {
            FirstOrderTicket = ticket;
            FirstOrderOpenPrice = Bid;
            OrderSequence = 1;
            ZoneLocked = true;
        } else {
            LogMessage("Error placing SELL order: " + IntegerToString(GetLastError()));
        }
    }
}

void ManageOrderSequence() {
    UpdateOrderCounts();
    int firstOrderLossPips = GetFirstOrderLossInPips();
    int totalProfitPips = CalculateTotalProfitInPips();
    
    if (OrderSequence == 1 && firstOrderLossPips <= -ZoneRange) {
        if (IsSpreadAcceptable()) {
            PlaceHedgeOrder();
            OrderSequence = 2;
        }
    } else if (OrderSequence >= 2) {
        int nextOrderThreshold = (int)(-ZoneRange * 1.5);
        
        if (totalProfitPips <= nextOrderThreshold) {
            if (IsSpreadAcceptable()) {
                PlaceNextRecoveryOrder();
                OrderSequence++;
                
                if (CountEAOrders() >= 5) {
                    RationalizeLots();
                }
            }
        }
    }
}

// Modified function to correctly handle different symbol formats
int GetFirstOrderLossInPips() {
    if (FirstOrderTicket <= 0 || !OrderSelect(FirstOrderTicket, SELECT_BY_TICKET)) {
        return 0;
    }
    
    double point = MarketInfo(Symbol(), MODE_POINT);
    int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
    double pipMultiplier;
    
    // Handle different price formats correctly
    if (digits == 3 || digits == 5) {
        pipMultiplier = 10.0;
    } else if (digits == 2 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 100.0;  // For XAUUSD with 2 digits
    } else if (digits == 3 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 1000.0; // For XAUUSD with 3 digits
    } else {
        pipMultiplier = 1.0;
    }
    
    if (OrderType() == OP_BUY) {
        return (int)((Bid - OrderOpenPrice()) / (point * pipMultiplier));
    } else if (OrderType() == OP_SELL) {
        return (int)((OrderOpenPrice() - Ask) / (point * pipMultiplier));
    }
    
    return 0;
}

// Modified function to correctly handle different symbol formats
int CalculateTotalProfitInPips() {
    int totalProfitPips = 0;
    double point = MarketInfo(Symbol(), MODE_POINT);
    int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
    double pipMultiplier;
    
    // Handle different price formats correctly
    if (digits == 3 || digits == 5) {
        pipMultiplier = 10.0;
    } else if (digits == 2 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 100.0;  // For XAUUSD with 2 digits
    } else if (digits == 3 && StringFind(Symbol(), "XAU") >= 0) {
        pipMultiplier = 1000.0; // For XAUUSD with 3 digits
    } else {
        pipMultiplier = 1.0;
    }
    
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double pipValue = (tickValue * pipMultiplier) / tickSize;
    
    if (pipValue == 0) pipValue = 1;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            int profitInPips = (int)(OrderProfit() / (OrderLots() * pipValue));
            totalProfitPips += profitInPips;
        }
    }
    
    return totalProfitPips;
}

void UpdateOrderCounts() {
    BuyCount = 0;
    SellCount = 0;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) BuyCount++;
            if (OrderType() == OP_SELL) SellCount++;
        }
    }
}

void PlaceHedgeOrder() {
    double prevLot = InitialLot;
    double lotMultiplier = 1.5 + (ZoneRange / 1000.0);
    double lotSize = NormalizeDouble(prevLot * lotMultiplier, 2);
    
    if (lotSize <= prevLot) {
        lotSize = prevLot + 0.01;
    }
    
    if (!OrderSelect(FirstOrderTicket, SELECT_BY_TICKET)) {
        LogMessage("Failed to select first order: " + IntegerToString(FirstOrderTicket));
        return;
    }
    
    int ticket = 0;
    if (OrderType() == OP_BUY && IsPriceAtZone(false)) {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 5, 0, 0, TradeComment, MagicNumber, 0, Red);
        if (ticket <= 0) {
            LogMessage("Error placing hedge SELL: " + IntegerToString(GetLastError()));
        }
    } else if (OrderType() == OP_SELL && IsPriceAtZone(true)) {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 5, 0, 0, TradeComment, MagicNumber, 0, Blue);
        if (ticket <= 0) {
            LogMessage("Error placing hedge BUY: " + IntegerToString(GetLastError()));
        }
    }
}

void PlaceNextRecoveryOrder() {
    double lotSize = CalculateNextLotSize();
    
    int lastOrderType = -1;
    int lastOrderTicket = 0;
    datetime lastOrderTime = 0;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            if (OrderOpenTime() > lastOrderTime) {
                lastOrderTime = OrderOpenTime();
                lastOrderType = OrderType();
                lastOrderTicket = OrderTicket();
            }
        }
    }
    
    int ticket = 0;
    if (lastOrderType == OP_BUY && IsPriceAtZone(false)) {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 5, 0, 0, TradeComment, MagicNumber, 0, Red);
        if (ticket <= 0) {
            LogMessage("Error placing recovery SELL: " + IntegerToString(GetLastError()));
        }
    } else if (lastOrderType == OP_SELL && IsPriceAtZone(true)) {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 5, 0, 0, TradeComment, MagicNumber, 0, Blue);
        if (ticket <= 0) {
            LogMessage("Error placing recovery BUY: " + IntegerToString(GetLastError()));
        }
    } else {
        LogMessage("Cannot determine last order type for recovery");
    }
}

double CalculateNextLotSize() {
    double previousLotSize = GetLargestExistingLotSize();
    double variableMultiplier = 1.5 + (ZoneRange / 1000.0) + (previousLotSize * 0.05);
    double nextLot = NormalizeDouble(previousLotSize * variableMultiplier, 2);
    
    nextLot = MathMax(nextLot, previousLotSize + 0.01);
    
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    
    nextLot = MathRound(nextLot / lotStep) * lotStep;
    return MathMax(minLot, MathMin(maxLot, nextLot));
}

double GetLargestExistingLotSize() {
    double largestLot = 0;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            if (OrderLots() > largestLot) {
                largestLot = OrderLots();
            }
        }
    }
    
    return (largestLot == 0) ? InitialLot : largestLot;
}

void RationalizeLots() {
    if (CountEAOrders() < 5) return;
    
    int largestBuyProfitTicket = 0, largestSellProfitTicket = 0;
    int smallestBuyLossTicket = 0, smallestSellLossTicket = 0;
    double largestBuyProfit = -99999, largestSellProfit = -99999;
    double smallestBuyLot = 9999, smallestSellLot = 9999;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
                if (OrderProfit() > 0 && OrderProfit() > largestBuyProfit) {
                    largestBuyProfit = OrderProfit();
                    largestBuyProfitTicket = OrderTicket();
                } else if (OrderProfit() < 0 && OrderLots() < smallestBuyLot) {
                    smallestBuyLot = OrderLots();
                    smallestBuyLossTicket = OrderTicket();
                }
            } else if (OrderType() == OP_SELL) {
                if (OrderProfit() > 0 && OrderProfit() > largestSellProfit) {
                    largestSellProfit = OrderProfit();
                    largestSellProfitTicket = OrderTicket();
                } else if (OrderProfit() < 0 && OrderLots() < smallestSellLot) {
                    smallestSellLot = OrderLots();
                    smallestSellLossTicket = OrderTicket();
                }
            }
        }
    }
    
    bool closedOrder = false;
    
    if (largestBuyProfitTicket > 0 && smallestSellLossTicket > 0) {
        if (OrderSelect(largestBuyProfitTicket, SELECT_BY_TICKET)) {
            bool result = false; // Initialize result variable
            result = OrderClose(OrderTicket(), OrderLots(), Bid, 5, clrNONE);
            if (result) {
                closedOrder = true;
                if (OrderSelect(smallestSellLossTicket, SELECT_BY_TICKET)) {
                    if (!OrderClose(OrderTicket(), OrderLots(), Ask, 5, clrNONE)) 
                        LogMessage("Error closing smallest loss SELL: " + IntegerToString(GetLastError()));
                }
            } else LogMessage("Error closing largest profitable BUY: " + IntegerToString(GetLastError()));
        }
    }
    
    if (!closedOrder && largestSellProfitTicket > 0 && smallestBuyLossTicket > 0) {
        if (OrderSelect(largestSellProfitTicket, SELECT_BY_TICKET)) {
            bool result = false; // Initialize result variable
            result = OrderClose(OrderTicket(), OrderLots(), Ask, 5, clrNONE);
            if (result) {
                if (OrderSelect(smallestBuyLossTicket, SELECT_BY_TICKET)) {
                    if (!OrderClose(OrderTicket(), OrderLots(), Bid, 5, clrNONE))
                        LogMessage("Error closing smallest loss BUY: " + IntegerToString(GetLastError()));
                }
            } else LogMessage("Error closing largest profitable SELL: " + IntegerToString(GetLastError()));
        }
    }
}

void CheckProfitClosure() {
    if (CalculateTotalProfitInPips() >= ProfitTarget) {
        CloseAllOrders();
    }
}

void CloseAllOrders() {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            bool result = false; // Initialize result variable
            if (OrderType() == OP_BUY) {
                result = OrderClose(OrderTicket(), OrderLots(), Bid, 5, clrNONE);
            } else if (OrderType() == OP_SELL) {
                result = OrderClose(OrderTicket(), OrderLots(), Ask, 5, clrNONE);
            }
            if (!result) LogMessage("Error closing order: " + IntegerToString(GetLastError()));
        }
    }
    
    ZoneEstablished = false;
    ZoneLocked = false;
    OrderSequence = 0;
    FirstOrderTicket = 0;
    FirstOrderOpenPrice = 0;
}