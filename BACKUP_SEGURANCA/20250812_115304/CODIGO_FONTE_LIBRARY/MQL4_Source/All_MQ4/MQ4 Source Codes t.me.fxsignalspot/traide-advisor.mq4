/*
 * You own your strategy, and you have the right to modify, share or keep your strategy secret.
 * The license below is meant to protect Inovance from any liability and provide you the most 
 * freedom with your strategy.
 *
 * Copyright (c) 2015, Inovance, Inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of TRAIDE nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
//+------------------------------------------------------------------+
//|                                                   Inovance, Inc. |
//|                                     https://www.inovancetech.com |
//+------------------------------------------------------------------+

#property copyright ""
#property link      "https://www.inovancetech.com"
#property description "TRAIDE Exported Strategy"
#property version   "1.00"
#property strict

enum ExitCondition {
    BAR_CLOSE,    // Bar Close
    TP_SL         // TP/SL
};

// EA Inputs
input ExitCondition exitCondition = BAR_CLOSE;      // Exit Conditions
extern double  takeProfit         = 50.0;           // Take Profit (pips)
extern double  stopLoss           = 50.0;           // Stop Loss (pips)
input  double  lots               = 0.1;            // Lots
extern int     slippage           = 5;              // Maximum Slippage (pips)
input  int     magicNumber        = 12345;          // Magic Number

// Other global variables
double buyStopLossPips = 0.0;
double buyTakeProfitPips = 0.0;
double sellStopLossPips = 0.0;
double sellTakeProfitPips = 0.0;
datetime lastBar = D'1970.01.01 00:00';

int OnInit() {
    if (Bars < 30) {
        Print("Not enough bars in chart");
        return INIT_FAILED;
    }    
    if (exitCondition == TP_SL) {
        if (takeProfit < 10) {
            Print("Error: Take Profit less than 10");
            return INIT_PARAMETERS_INCORRECT;
        }
        if(stopLoss < 10) {
            Print("Stop Loss less than 10");
            return INIT_PARAMETERS_INCORRECT;
        }
        if (Digits == 5 || Digits == 3) {
            takeProfit *= 10;
            stopLoss *= 10;
        }
    }    
    if (Digits == 5 || Digits == 3) {          
        slippage *= 10;
    }           
    Print("Exit Condition=", exitCondition, " Lots=", lots, " Take Profit=", takeProfit, " Stop Loss=", stopLoss, " Slippage=", slippage); 
    return INIT_SUCCEEDED;
}

void OnTick() {
    if (isNewBar()) {
        if (exitCondition == TP_SL) {
            buyTakeProfitPips = NormalizeDouble(Ask + takeProfit * Point, Digits);
            buyStopLossPips = NormalizeDouble(Ask - stopLoss * Point, Digits);
            sellTakeProfitPips = NormalizeDouble(Bid - takeProfit * Point, Digits);
            sellStopLossPips = NormalizeDouble(Bid + stopLoss * Point, Digits);
        }
        processNewBar();
    }
}

int processNewBar() {
    int signal = traideRule0() + traideRule1();
    switch (OrdersTotal()) {
    case 0:  // No open orders
        if (signal > 0) {
            Print("Long Conditions Met");
            if (OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, buyStopLossPips, buyTakeProfitPips, "TRAIDE EA", magicNumber, 0, Green) < 0) {
                Print("Error opening buy order: ", GetLastError());
            }
        } else if (signal < 0) {
            Print("Short Conditions Met");
            if (OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, sellStopLossPips, sellTakeProfitPips, "TRAIDE EA", magicNumber, 0, Red) < 0) {
                Print("Error opening sell order: ", GetLastError());
            }
        }
        break;
    case 1:  // An open order exists
        if (OrderSelect(0, SELECT_BY_POS, MODE_TRADES) == TRUE) {
            switch (OrderType()) {
            case OP_BUY:   // A buy order exists
                if (signal == 0) {
                    Print("Long Conditions No Longer Met");
                    if (!OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Violet)) {
                        Print("Error closing buy order: ", GetLastError());
                    }
                } else if (signal < 0) {
                    Print("Short Conditions Met");
                    if (!OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Violet)) {
                        Print("Error closing buy order: ", GetLastError());
                    } else if (OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, sellStopLossPips, sellTakeProfitPips, "TRAIDE EA", magicNumber, 0, Red) < 0) {
                        Print("Error opening sell order: ", GetLastError());
                    }
                } else if (signal > 0) {
                        Print("Long Conditions Still Met");
                }
                break;
            case OP_SELL:  // A sell order exists
                if (signal == 0) {
                    Print("Short Conditions No Longer Met");
                    if (!OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Violet)) {
                         Print("Error closing sell order: ", GetLastError());
                    }
                } else if (signal > 0) {
                     Print("Long Conditions Met");
                    if (!OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Violet)) {
                        Print("Error closing sell order: ", GetLastError());
                    } else if (OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, buyStopLossPips, buyTakeProfitPips, "TRAIDE EA", magicNumber, 0, Green) < 0) {
                        Print("Error opening buy order: ", GetLastError());
                    }
                } else if (signal < 0) {
                     Print("Short Conditions Still Met");
                }
                break;
            default:
                Print("Error, unexpected OrderType: ", OrderType());
                break; 
            }
        }
        break;
    default:
        Print("Error, unexpected OrdersTotal: ", OrdersTotal());
        break;
    }
    return 0;   
}

bool isNewBar() {
    if (lastBar != Time[0]) {
        lastBar = Time[0];
        return TRUE;
    }
    return FALSE;
} 

// Produced by TRAIDE Strategy Code Generator (beta).
int indATR1period = 14;
int indCCI2period = 14;
int indMACD_LINE3fastPeriod = 12;
int indMACD_LINE3fastMaType = 1;
int indMACD_LINE3slowPeriod = 26;
int indMACD_LINE3slowMaType = 1;
int indMACD_LINE3signalPeriod = 9;
int indMACD_LINE3signalMaType = 1;
int indMIN_MAX_RATIO4period = 30;
int traideRule0() {
    return 0;
}
int traideRule1() {
    return 0;
}
