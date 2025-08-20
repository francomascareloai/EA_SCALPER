#property copyright "Matt Todorovski 2025"
#property link "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version "1.07"
#property strict
input int Magic=202503241;input string TradeComment="2PSAR";
double ema15,ema25,psar15,lastHigh,lastLow,hiddenBuyStopLoss=0,hiddenSellStopLoss=0,Buffer=2.0,currentLotSize=0.1,highestBuyPrice=0,lowestSellPrice=0,firstOrderLotSize=0,lastOrderLotSize=0;
int lastBuyTicket=0,lastSellTicket=0,stopLossClosures[24],closeEventCount=0,lastDay=-1,pendingBuyStopTicket=0,pendingSellStopTicket=0;
string closeEvents[1000];
double pendingBuyStopPrice=0,pendingSellStopPrice=0,lastAsk=0,lastBid=0;

double CalculateOrderDistance(int orderCount) {
    return (50.0 + 10.0 * MathLog(orderCount + 1.0)) * Point;
}

int OnInit() {
    lastBuyTicket=LastOpenOrderTicket(0);
    lastSellTicket=LastOpenOrderTicket(1);
    UpdateStopLossValues();
    for(int i=0;i<24;i++) stopLossClosures[i]=0;
    for(int i=0;i<1000;i++) closeEvents[i]="";
    closeEventCount=0;
    lastDay=Day();
    currentLotSize=0.1;
    pendingBuyStopTicket=0;
    pendingSellStopTicket=0;
    pendingBuyStopPrice=0;
    pendingSellStopPrice=0;
    lastAsk=0;
    lastBid=0;
    highestBuyPrice=0;
    lowestSellPrice=0;
    firstOrderLotSize=0;
    lastOrderLotSize=0;
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    LogStatisticsToFile();
}

int CountPendingStopOrders() {
    int count=0;
    for(int i=0;i<OrdersTotal();i++) if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)) count++;
    return count;
}

void DeleteAllPendingStopOrders() {
    for(int i=OrdersTotal()-1;i>=0;i--) {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol()) {
            if(OrderType()==OP_BUYSTOP) {
                if(OrderDelete(OrderTicket(),clrRed) && pendingBuyStopTicket==OrderTicket()) {
                    pendingBuyStopTicket=0;
                    pendingBuyStopPrice=0;
                    lastAsk=0;
                }
            }
            else if(OrderType()==OP_SELLSTOP) {
                if(OrderDelete(OrderTicket(),clrRed) && pendingSellStopTicket==OrderTicket()) {
                    pendingSellStopTicket=0;
                    pendingSellStopPrice=0;
                    lastBid=0;
                }
            }
        }
    }
}

void OnTick() {
    bool foundBuyStop=false,foundSellStop=false;
    for(int i=0;i<OrdersTotal();i++) {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol()) {
            if(OrderType()==OP_BUYSTOP && OrderTicket()==pendingBuyStopTicket) foundBuyStop=true;
            if(OrderType()==OP_SELLSTOP && OrderTicket()==pendingSellStopTicket) foundSellStop=true;
        }
    }
    if(pendingBuyStopTicket>0 && !foundBuyStop) {pendingBuyStopTicket=0;pendingBuyStopPrice=0;lastAsk=0;}
    if(pendingSellStopTicket>0 && !foundSellStop) {pendingSellStopTicket=0;pendingSellStopPrice=0;lastBid=0;}

    ema15=iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_CLOSE,2);
    ema25=iMA(NULL,PERIOD_CURRENT,25,0,MODE_EMA,PRICE_CLOSE,0);
    psar15=iSAR(NULL,PERIOD_CURRENT,0.01,0.2,1);
    lastHigh=iHigh(NULL,PERIOD_CURRENT,1);
    lastLow=iLow(NULL,PERIOD_CURRENT,1);
    bool isUptrend=ema15>ema25,isDowntrend=ema15<ema25,isUptrendConfirmed=true,isDowntrendConfirmed=true;
    double differenceInPips=MathAbs(ema15-ema25)/Point,bufferInPips=0.2*iATR(_Symbol,_Period,14,1)/Point;
    if(differenceInPips<bufferInPips) {isUptrend=false;isDowntrend=false;}
    for(int i=1;i<=3;i++) {
        double emaShiftI=iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_CLOSE,i),ema25ShiftIMinus1=iMA(NULL,PERIOD_CURRENT,25,0,MODE_EMA,PRICE_CLOSE,i-1);
        if(emaShiftI<=ema25ShiftIMinus1) isUptrendConfirmed=false;
        if(emaShiftI>=ema25ShiftIMinus1) isDowntrendConfirmed=false;
    }
    double lastOpen=iOpen(NULL,PERIOD_CURRENT,1),lastClose=iClose(NULL,PERIOD_CURRENT,1);
    bool lastCandleAboveEMAs=(lastOpen>ema15&&lastOpen>ema25&&lastClose>ema15&&lastClose>ema25),lastCandleBelowEMAs=(lastOpen<ema15&&lastOpen<ema25&&lastClose<ema15&&lastClose>ema25);
    if(Day()!=lastDay) {
        LogStatisticsToFile();
        for(int i=0;i<24;i++) stopLossClosures[i]=0;
        for(int i=0;i<1000;i++) closeEvents[i]="";
        closeEventCount=0;
        lastDay=Day();
    }

    CheckAndCloseOrders();
    DisplayHourlyTalliesOnChart();

    if(CountOrders(0)==0 && pendingBuyStopTicket>0) {
        if(OrderSelect(pendingBuyStopTicket,SELECT_BY_TICKET)) {
            if(OrderType()==0) {
                lastBuyTicket=pendingBuyStopTicket;
                UpdateStopLossValues();
                pendingBuyStopTicket=0;
                pendingBuyStopPrice=0;
                lastAsk=0;
            }
            else if(OrderType()==OP_BUYSTOP) {
                double priceChange=lastAsk>0?(Ask-lastAsk)/Point:0;
                if(lastAsk==0 || MathAbs(priceChange)>=10) {
                    double newPrice=pendingBuyStopPrice;
                    if(priceChange<0) newPrice=Ask+0.5*iATR(_Symbol,_Period,14,1);
                    if(newPrice!=pendingBuyStopPrice && OrderModify(pendingBuyStopTicket,NormalizeDouble(newPrice,Digits),0,0,0,clrGreen)) pendingBuyStopPrice=newPrice;
                    lastAsk=Ask;
                }
            }
        }
        else {pendingBuyStopTicket=0;pendingBuyStopPrice=0;lastAsk=0;}
    }

    if(CountOrders(1)==0 && pendingSellStopTicket>0) {
        if(OrderSelect(pendingSellStopTicket,SELECT_BY_TICKET)) {
            if(OrderType()==1) {
                lastSellTicket=pendingSellStopTicket;
                UpdateStopLossValues();
                pendingSellStopTicket=0;
                pendingSellStopPrice=0;
                lastBid=0;
            }
            else if(OrderType()==OP_SELLSTOP) {
                double priceChange=lastBid>0?(Bid-lastBid)/Point:0;
                if(lastBid==0 || MathAbs(priceChange)>=10) {
                    double newPrice=pendingSellStopPrice;
                    if(priceChange>0) newPrice=Bid-0.5*iATR(_Symbol,_Period,14,1);
                    if(newPrice!=pendingSellStopPrice && OrderModify(pendingSellStopTicket,NormalizeDouble(newPrice,Digits),0,0,0,clrRed)) pendingSellStopPrice=newPrice;
                    lastBid=Bid;
                }
            }
        }
        else {pendingSellStopTicket=0;pendingSellStopPrice=0;lastBid=0;}
    }

    int totalPendingStops=CountPendingStopOrders();
    if(totalPendingStops==0 && CountOrders(0)==0 && isUptrend && isUptrendConfirmed && lastCandleAboveEMAs) {
        DeleteAllPendingStopOrders();
        double atr=iATR(_Symbol,_Period,14,1),stopPrice=Ask+0.5*atr,lotSize=CalculateLotSize(0, false);
        int ticket=OrderSend(Symbol(),OP_BUYSTOP,lotSize,NormalizeDouble(stopPrice,Digits),3,0,0,TradeComment,Magic,0,clrGreen);
        if(ticket>0) {
            pendingBuyStopTicket=ticket;
            pendingBuyStopPrice=stopPrice;
            lastAsk=Ask;
            firstOrderLotSize=lotSize;
            lastOrderLotSize=lotSize;
        }
    }

    if(totalPendingStops==0 && CountOrders(1)==0 && isDowntrend && isDowntrendConfirmed && lastCandleBelowEMAs) {
        DeleteAllPendingStopOrders();
        double atr=iATR(_Symbol,_Period,14,1),stopPrice=Bid-0.5*atr,lotSize=CalculateLotSize(1, false);
        int ticket=OrderSend(Symbol(),OP_SELLSTOP,lotSize,NormalizeDouble(stopPrice,Digits),3,0,0,TradeComment,Magic,0,clrRed);
        if(ticket>0) {
            pendingSellStopTicket=ticket;
            pendingSellStopPrice=stopPrice;
            lastBid=Bid;
            firstOrderLotSize=lotSize;
            lastOrderLotSize=lotSize;
        }
    }

    if(pendingBuyStopTicket>0 && isDowntrend && OrderSelect(pendingBuyStopTicket,SELECT_BY_TICKET) && OrderType()==OP_BUYSTOP) {
        if(OrderDelete(pendingBuyStopTicket,clrRed)) {pendingBuyStopTicket=0;pendingBuyStopPrice=0;lastAsk=0;}
    }

    if(pendingSellStopTicket>0 && isUptrend && OrderSelect(pendingSellStopTicket,SELECT_BY_TICKET) && OrderType()==OP_SELLSTOP) {
        if(OrderDelete(pendingSellStopTicket,clrRed)) {pendingSellStopTicket=0;pendingSellStopPrice=0;lastBid=0;}
    }

    if(CountOrders(0)>0 && isUptrend && isUptrendConfirmed && lastCandleAboveEMAs) {
        double lastBuyPrice=LastTradePrice(0,1),orderDistance=CalculateOrderDistance(CountOrders(0));
        if(Bid<=(lastBuyPrice-orderDistance)) OpenTrade(0, true);
        else if(Bid>=(lastBuyPrice+orderDistance)) OpenTrade(0, false);
    }

    if(CountOrders(1)>0 && isDowntrend && isDowntrendConfirmed && lastCandleBelowEMAs) {
        double lastSellPrice=LastTradePrice(1,1),orderDistance=CalculateOrderDistance(CountOrders(1));
        if(Ask>=(lastSellPrice+orderDistance)) OpenTrade(1, true);
        else if(Ask<=(lastSellPrice-orderDistance)) OpenTrade(1, false);
    }
}

double CalculateLotSize(int orderType, bool inDrawdown) {
    int orderCount=CountOrders(orderType);
    if(orderCount==0) return NormalizeDouble(currentLotSize,2);
    double k=0.01,b=1.0;
    if(inDrawdown) return NormalizeDouble(MathMax(0.01, firstOrderLotSize + k * MathLog(orderCount + b)), 2);
    return NormalizeDouble(MathMax(0.01, lastOrderLotSize - k * MathLog(orderCount + b)), 2);
}

void OpenTrade(int orderType, bool inDrawdown) {
    double price=orderType==0?Ask:Bid,lotSize=CalculateLotSize(orderType, inDrawdown);
    int ticket=OrderSend(Symbol(),orderType,lotSize,price,3,0,0,TradeComment,Magic,0,clrGreen);
    if(ticket>0) {
        lastOrderLotSize=lotSize;
        if(orderType==0) {
            lastBuyTicket=ticket;
            UpdateStopLossValues();
            if(CountOrders(0)==1) {highestBuyPrice=price;firstOrderLotSize=lotSize;}
        }
        else {
            lastSellTicket=ticket;
            UpdateStopLossValues();
            if(CountOrders(1)==1) {lowestSellPrice=price;firstOrderLotSize=lotSize;}
        }
    }
}

void CheckAndCloseOrders() {
    int buyCount=CountOrders(0),sellCount=CountOrders(1),currentHour=Hour();
    double k=0.015,b=1.0;
    if(buyCount>0) {
        bool shouldClose=false;
        double totalProfitPips=0,totalNetProfit=0;
        if(buyCount>=2) {
            if(Bid>highestBuyPrice) highestBuyPrice=Bid;
            for(int i=OrdersTotal()-1;i>=0;i--) {
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==0) {
                    totalProfitPips+=(Bid-OrderOpenPrice())/Point;
                    totalNetProfit+=OrderProfit()+OrderCommission()+OrderSwap();
                }
            }
            if(totalNetProfit>0) {
                shouldClose=true;
                for(int i=OrdersTotal()-1;i>=0;i--) {
                    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==0) {
                        string eventLog=StringFormat("Close Event: Type=TrailingStop,Ticket=%d,OrderType=Buy,OpenPrice=%.5f,ClosePrice=%.5f,ProfitPips=%.1f,HighestPrice=%.5f,TotalProfitPips=%.1f,TotalNetProfit=%.2f,Time=%s",OrderTicket(),OrderOpenPrice(),Bid,(Bid-OrderOpenPrice())/Point,highestBuyPrice,totalProfitPips,totalNetProfit,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                        if(closeEventCount<ArraySize(closeEvents)) {closeEvents[closeEventCount]=eventLog;closeEventCount++;}
                    }
                }
            }
        }
        if(shouldClose) {
            stopLossClosures[currentHour]++;
            if(totalProfitPips>0) currentLotSize=NormalizeDouble(MathMax(0.01, currentLotSize - k * MathLog(currentLotSize + b)), 2);
            else currentLotSize=NormalizeDouble(MathMax(0.01, currentLotSize + k * MathLog(currentLotSize + b)), 2);
            CloseOrdersByType(0);
            lastBuyTicket=LastOpenOrderTicket(0);
            hiddenBuyStopLoss=0;
            highestBuyPrice=0;
            firstOrderLotSize=0;
            lastOrderLotSize=0;
        }
    }

    if(sellCount>0) {
        bool shouldClose=false;
        double totalProfitPips=0,totalNetProfit=0;
        if(sellCount>=2) {
            if(Ask<lowestSellPrice || lowestSellPrice==0) lowestSellPrice=Ask;
            for(int i=OrdersTotal()-1;i>=0;i--) {
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==1) {
                    totalProfitPips+=(OrderOpenPrice()-Ask)/Point;
                    totalNetProfit+=OrderProfit()+OrderCommission()+OrderSwap();
                }
            }
            if(totalNetProfit>0) {
                shouldClose=true;
                for(int i=OrdersTotal()-1;i>=0;i--) {
                    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==1) {
                        string eventLog=StringFormat("Close Event: Type=TrailingStop,Ticket=%d,OrderType=Sell,OpenPrice=%.5f,ClosePrice=%.5f,ProfitPips=%.1f,LowestPrice=%.5f,TotalProfitPips=%.1f,TotalNetProfit=%.2f,Time=%s",OrderTicket(),OrderOpenPrice(),Ask,(OrderOpenPrice()-Ask)/Point,lowestSellPrice,totalProfitPips,totalNetProfit,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                        if(closeEventCount<ArraySize(closeEvents)) {closeEvents[closeEventCount]=eventLog;closeEventCount++;}
                    }
                }
            }
        }
        if(shouldClose) {
            stopLossClosures[currentHour]++;
            if(totalProfitPips>0) currentLotSize=NormalizeDouble(MathMax(0.01, currentLotSize - k * MathLog(currentLotSize + b)), 2);
            else currentLotSize=NormalizeDouble(MathMax(0.01, currentLotSize + k * MathLog(currentLotSize + b)), 2);
            CloseOrdersByType(1);
            lastSellTicket=LastOpenOrderTicket(1);
            hiddenSellStopLoss=0;
            lowestSellPrice=0;
            firstOrderLotSize=0;
            lastOrderLotSize=0;
        }
    }
}

void UpdateStopLossValues() {
    int buyCount=CountOrders(0),sellCount=CountOrders(1);
    if(lastBuyTicket>0 && OrderSelect(lastBuyTicket,SELECT_BY_TICKET)) hiddenBuyStopLoss=(buyCount==1)?0:LastTradePrice(0,1)-10*Point;
    if(lastSellTicket>0 && OrderSelect(lastSellTicket,SELECT_BY_TICKET)) hiddenSellStopLoss=(sellCount==1)?0:LastTradePrice(1,1)+10*Point;
}

void LogStatisticsToFile() {
    string filename="2PSAR_Statistics_"+TimeToString(TimeCurrent(),TIME_DATE)+".txt";
    int handle=FileOpen(filename,FILE_WRITE|FILE_TXT);
    if(handle!=INVALID_HANDLE) {
        FileWrite(handle,"Hourly Closure Tallies for ",TimeToString(TimeCurrent(),TIME_DATE));
        FileWrite(handle,"Hour,StopLoss Closures");
        for(int i=0;i<24;i++) FileWrite(handle,StringFormat("%02d:00-%02d:59,%d",i,i,stopLossClosures[i]));
        FileWrite(handle,"");
        FileWrite(handle,"Detailed Close Events");
        for(int i=0;i<closeEventCount;i++) FileWrite(handle,closeEvents[i]);
        FileClose(handle);
    }
}

void DisplayHourlyTalliesOnChart() {
    string comment="Hourly Closure Tallies\n";
    for(int i=0;i<24;i++) comment+=StringFormat("%02d:00-%02d:59 | StopLoss: %d\n",i,i,stopLossClosures[i]);
    Comment(comment);
}

int CountOrders(int type) {
    int count=0;
    for(int i=0;i<OrdersTotal();i++) if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==type) count++;
    return count;
}

void CloseOrdersByType(int type) {
    for(int i=OrdersTotal()-1;i>=0;i--) {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==type) {
            bool result;
            if(type==0) result=OrderClose(OrderTicket(),OrderLots(),Bid,3,clrBlue);
            else result=OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
            if(!result) Print("Error closing order: ", GetLastError());
        }
    }
}

int LastOpenOrderTicket(int type=-1) {
    for(int i=OrdersTotal()-1;i>=0;i--) {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) {
            if((OrderType()==0 && (type==0 || type==-1)) || (OrderType()==1 && (type==1 || type==-1))) return OrderTicket();
        }
    }
    return 0;
}

double LastTradePrice(int orderType,int nth=1) {
    int count=0;
    for(int i=0;i<OrdersTotal();i++) if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==orderType) count++;
    datetime times[];
    double prices[];
    ArrayResize(times,count);
    ArrayResize(prices,count);
    count=0;
    for(int i=0;i<OrdersTotal();i++) {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol() && OrderType()==orderType) {
            times[count]=OrderOpenTime();
            prices[count]=OrderOpenPrice();
            count++;
        }
    }
    for(int i=0;i<count-1;i++) for(int j=i+1;j<count;j++) if(times[i]<times[j]) {
        datetime tempTime=times[i];
        double tempPrice=prices[i];
        times[i]=times[j];
        prices[i]=prices[j];
        times[j]=tempTime;
        prices[j]=tempPrice;
    }
    return (nth<=count && nth>0)?prices[nth-1]:0;
}