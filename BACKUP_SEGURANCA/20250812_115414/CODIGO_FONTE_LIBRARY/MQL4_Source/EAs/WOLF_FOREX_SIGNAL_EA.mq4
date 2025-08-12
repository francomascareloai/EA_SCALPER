#property copyright "Copyright © 2025, Forecracked"
#property link      "http://www.forexcracked.com
#property version "1.0"
#property strict

input string ExpertName=" WOLF FOREX SIGNAL EA v 7.00 ";
input string TELWGRAMName=" https://t.me/WOLF_FOREXSIGNAL ";
input string Slrialnumber=" 11ME-55jH-BN61-Mjk2-NM66 ";
extern bool Star =true;//Star true=ON
input int magic=11223366; // Magic NUMPER//
input double lotSize=0.01; // fixed lots
input int stopLoss=10;//risk:? 0=fixed lots
extern double SLp=500.0;//SL
extern double TP=40.0;   
input string filter="========= Variable filter =========";
input string ICC="ICC";
extern int period_CC=19;
enum ds
{c/*Close price*/,o/*Open price*/,H/*High price*/,L/*Low price*/,M/*Median price*/,W/*Weighted price*/};
extern ds applied ;
extern int Level_buy=-80;
string  str_0;
extern int Level_sell=80;
input string R="RSI";
extern int period_Rsi=19;
enum dt
{cll/*Close price*/,oll/*Open price*/,Hll/*High price*/,Lll/*Low price*/,Mll/*Median price*/,Wll/*Weighted price*/};
extern dt jj;//applied
input string sst="=========ATR Indicator =====";//=========================
extern int ATR=19;//ATR Indicator Period
input string fgg="========= Stochasti Indicator =====";//=========================
extern int In1=5;// Stochastic Indicator Period
extern int In2=3;// Stochastic Indicator Period
extern int In3=3;//Stochastic Indicator Slowing
extern int In4=30;//Stochastic Low
extern int In5=70;//Stochastic High
input string co="=========CCI Indicators =====";//=========================
extern int CC1 =12;//CCl Indicator Period
extern int CC2=14;//CCl Indicator Period

string str_1,str_2,str_7,str_8,str_9,str_10,str_12,str_22,str_13,str_33,str_14,str_28,str_38,str_44,str_15,str_16,str_55,str_66;
enum settings
  {
   s=0,//--- Settings ---
  };

settings gs=0;                                      // --- General ---

int slippage=3;                                     // Slippage

double takeProfit=25;

double distance=20;                                 // Distance (pips)
 settings times=0;                                   // --- Market Time ---
string openTime="02:00";                            // Market Open Time (HH:MM)
string closeTime="22:00";                           // Market Close Time (HH:MM)
bool ts=true;                                       // ---- Trailing Stop ----
int TralStop=10;                                    // Trailing stop pips
bool oneTrade=false;                                // Only First Signal

 string str_3,str_4,str_5,str_6,str_42,str_43,str_45,str_50,str_4248,str_47,str_41,str_46,str_48,str_40,str_39,str_80,str_37,str_35,str_36,str_34,str_58,str_78,str_30,str_17,str_11,str_29,str_27,str_32,str_25,str_26,str_31;                                                         // Code variables
datetime current;
int day=Day();
bool isTrade=true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  ChartSetInteger(0,17,0,0);
  ChartSetInteger(0,0,1);
//---
 str_0 = "ERROR_FON";
if (ObjectCreate(0, str_0, OBJ_RECTANGLE_LABEL, 0, 0, 0))
            {
                ObjectSetInteger(0, str_0, 102, 1530);//
                ObjectSetInteger(0, str_0, 103, 20);//
                ObjectSetInteger(0, str_0, 1019, 380);//
                ObjectSetInteger(0, str_0, 1020, 420);//
                ObjectSetInteger(0, str_0, 1025, C'123,104,238');
                ObjectSetInteger(0, str_0, 1029, 2);
                ObjectSetInteger(0, str_0, 101, 1);
                ObjectSetInteger(0, str_0, 6, 16711680);
                ObjectSetInteger(0, str_0, 8, 1);
                ObjectSetInteger(0, str_0, 9, 0);
                ObjectSetInteger(0, str_0, 208, 0);
            
            str_1 = "WOLF FOREX SIGNAL EA v 7.00 - "+Symbol();
            
            str_2 = "ERROR_TEXT1";
            ObjectCreate(0, str_2, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_2, 102, 1520);
            ObjectSetInteger(0, str_2, 103, 25);
            ObjectSetInteger(0, str_2, 101, 1);
            ObjectSetString(0, str_2, 999, str_1);
            ObjectSetString(0, str_2, 1001, "Arial");
            ObjectSetInteger(0, str_2, 100, 11);
            ObjectSetInteger(0, str_2, 6, White);
            ObjectSetInteger(0, str_2, 208, 0);
            ObjectSetInteger(0, str_2, 9, 0);
                }           
      str_3 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_4 = "ERROR_TEXT15";
            ObjectCreate(0, str_4, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_4, 102, 1520);
            ObjectSetInteger(0, str_4, 103, 45);
            ObjectSetInteger(0, str_4, 101, 1);
            ObjectSetString(0, str_4, 999, str_3);
            ObjectSetString(0, str_4, 1001, "Arial");
            ObjectSetInteger(0, str_4, 100, 9);
            ObjectSetInteger(0, str_4, 6, White);
            ObjectSetInteger(0, str_4, 208, 0);
            ObjectSetInteger(0, str_4, 9, 0);
            str_5 = "ACCOUNT INFORMATION";
            str_6 = "ERROR_T";
            ObjectCreate(0, str_6, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_6, 102, 1520);
            ObjectSetInteger(0, str_6, 103, 60);
            ObjectSetInteger(0, str_6, 101, 1);
            ObjectSetString(0, str_6, 999, str_5);
            ObjectSetString(0, str_6, 1001, "Arial");
            ObjectSetInteger(0, str_6, 100, 8);
            ObjectSetInteger(0, str_6, 6, White);
            ObjectSetInteger(0, str_6, 208, 0);
            ObjectSetInteger(0, str_6, 9, 0);
             str_7 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_8 = "ERROR_TEX";
            ObjectCreate(0, str_8, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_8, 102, 1520);
            ObjectSetInteger(0, str_8, 103, 70);
            ObjectSetInteger(0, str_8, 101, 1);
            ObjectSetString(0, str_8, 999, str_7);
            ObjectSetString(0, str_8, 1001, "Arial");
            ObjectSetInteger(0, str_8, 100, 9);
            ObjectSetInteger(0, str_8, 6, White);
            ObjectSetInteger(0, str_8, 208, 0);
            ObjectSetInteger(0, str_8, 9, 0);  
             str_9 = "Broker                   :"+AccountInfoString(ACCOUNT_COMPANY);
            str_10 = "ERROR_TEXT45";
            ObjectCreate(0, str_10, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_10, 102, 1520);
            ObjectSetInteger(0, str_10, 103, 80);
            ObjectSetInteger(0, str_10, 101, 1);
            ObjectSetString(0, str_10, 999, str_9);
            ObjectSetString(0, str_10, 1001, "Arial");
            ObjectSetInteger(0, str_10, 100, 8);
            ObjectSetInteger(0, str_10, 6, White);
            ObjectSetInteger(0, str_10, 208, 0);
            ObjectSetInteger(0, str_10, 9, 0);
            str_12 = "Acc. Name            :"+AccountInfoString(ACCOUNT_NAME);
            str_22 = "ERROR_TEXT5";
            ObjectCreate(0, str_22, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_22, 102, 1520);
            ObjectSetInteger(0, str_22, 103, 95);
            ObjectSetInteger(0, str_22, 101, 1);
            ObjectSetString(0, str_22, 999, str_12);
            ObjectSetString(0, str_22, 1001, "Arial");
            ObjectSetInteger(0, str_22, 100, 8);
            ObjectSetInteger(0, str_22, 6, White);
            ObjectSetInteger(0, str_22, 208, 0);
            ObjectSetInteger(0, str_22, 9, 0);
            str_13 = "Account Number                     :"+(string)AccountNumber();
            str_33 = "ERROR_TEXT4";
            ObjectCreate(0, str_33, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_33, 102, 1520);
            ObjectSetInteger(0, str_33, 103, 110);
            ObjectSetInteger(0, str_33, 101, 1);
            ObjectSetString(0, str_33, 999, str_13);
            ObjectSetString(0, str_33, 1001, "Arial");
            ObjectSetInteger(0, str_33, 100, 8);
            ObjectSetInteger(0, str_33, 6, White);
            ObjectSetInteger(0, str_33, 208, 0);
            ObjectSetInteger(0, str_33, 9, 0);
            str_14 = "Account Leverage                    :"+(string)AccountInfoInteger(ACCOUNT_LEVERAGE);
            str_44 = "ERROR_TEXT3";
            ObjectCreate(0, str_44, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_44, 102, 1520);
            ObjectSetInteger(0, str_44, 103, 125);
            ObjectSetInteger(0, str_44, 101, 1);
            ObjectSetString(0, str_44, 999, str_14);
            ObjectSetString(0, str_44, 1001, "Arial");
            ObjectSetInteger(0, str_44, 100, 8);
            ObjectSetInteger(0, str_44, 6, White);
            ObjectSetInteger(0, str_44, 208, 0);
            ObjectSetInteger(0, str_44, 9, 0);

            str_15 = "Account Balance                      :"+(string)AccountBalance();
            str_55 = "ERROR_TET24";
            ObjectCreate(0, str_55, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_55, 102, 1520);
            ObjectSetInteger(0, str_55, 103, 140);
            ObjectSetInteger(0, str_55, 101, 1);
            ObjectSetString(0, str_55, 999, str_15);
            ObjectSetString(0, str_55, 1001, "Arial");
            ObjectSetInteger(0, str_55, 100, 8);
            ObjectSetInteger(0, str_55, 6, White);
            ObjectSetInteger(0, str_55, 208, 0);
            ObjectSetInteger(0, str_55, 9, 0);

            str_16 = "Account Equity                        :"+(string)AccountInfoDouble(ACCOUNT_EQUITY);
            str_66 = "ERROR_TEXT";
            ObjectCreate(0, str_66, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_66, 102, 1520);
            ObjectSetInteger(0, str_66, 103, 155);
            ObjectSetInteger(0, str_66, 101, 1);
            ObjectSetString(0, str_66, 999, str_16);
            ObjectSetString(0, str_66, 1001, "Arial");
            ObjectSetInteger(0, str_66, 100, 8);
            ObjectSetInteger(0, str_66, 6, White);
            ObjectSetInteger(0, str_66, 208, 0);
            ObjectSetInteger(0, str_66, 9, 0);
             
            str_28 = "Server Time                             :"+(string)TimeCurrent();
            str_38 = "ERROR_TEkfk";
            ObjectCreate(0, str_38, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_38, 102, 1520);
            ObjectSetInteger(0, str_38, 103, 170);
            ObjectSetInteger(0, str_38, 101, 1);
            ObjectSetString(0, str_38, 999, str_28);
            ObjectSetString(0, str_38, 1001, "Arial");
            ObjectSetInteger(0, str_38, 100, 8);
            ObjectSetInteger(0, str_38, 6, White);
            ObjectSetInteger(0, str_38, 208, 0);
            ObjectSetInteger(0, str_38, 9, 0);
            
             str_58 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_78 = "ERROR_T1";
            ObjectCreate(0, str_78, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_78, 102, 1520);
            ObjectSetInteger(0, str_78, 103, 185);
            ObjectSetInteger(0, str_78, 101, 1);
            ObjectSetString(0, str_78, 999, str_58);
            ObjectSetString(0, str_78, 1001, "Arial");
            ObjectSetInteger(0, str_78, 100, 9);
            ObjectSetInteger(0, str_78, 6, White);
            ObjectSetInteger(0, str_78, 208, 0);
            ObjectSetInteger(0, str_78, 9, 0);
             str_25 = "TRADE INFORMATIONS";
            str_26 = "ERROR_T15";
            ObjectCreate(0, str_26, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_26, 102, 1520);
            ObjectSetInteger(0, str_26, 103, 200);
            ObjectSetInteger(0, str_26, 101, 1);
            ObjectSetString(0, str_26, 999, str_25);
            ObjectSetString(0, str_26, 1001, "Arial");
            ObjectSetInteger(0, str_26, 100, 8);
            ObjectSetInteger(0, str_26, 6, White);
            ObjectSetInteger(0, str_26, 208, 0);
            ObjectSetInteger(0, str_26, 9, 0);
             str_27 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_28 = "ERROR_T91";
            ObjectCreate(0, str_28, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_28, 102, 1520);
            ObjectSetInteger(0, str_28, 103, 215);
            ObjectSetInteger(0, str_28, 101, 1);
            ObjectSetString(0, str_28, 999, str_27);
            ObjectSetString(0, str_28, 1001, "Arial");
            ObjectSetInteger(0, str_28, 100, 9);
            ObjectSetInteger(0, str_28, 6, White);
            ObjectSetInteger(0, str_28, 208, 0);
            ObjectSetInteger(0, str_28, 9, 0);
             str_29 = "FLOATING P/L                 :0.00";
            str_11 = "ERROR_T51";
            ObjectCreate(0, str_11, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_11, 102, 1520);
            ObjectSetInteger(0, str_11, 103, 230);
            ObjectSetInteger(0, str_11, 101, 1);
            ObjectSetString(0, str_11, 999, str_29);
            ObjectSetString(0, str_11, 1001, "Arial");
            ObjectSetInteger(0, str_11, 100, 8);
            ObjectSetInteger(0, str_11, 6, White);
            ObjectSetInteger(0, str_11, 208, 0);
            ObjectSetInteger(0, str_11, 9, 0);
             str_30 = "Drawdown : ";
            str_17 = "ERROR_T591";
            ObjectCreate(0, str_17, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_17, 102, 1520);
            ObjectSetInteger(0, str_17, 103, 245);
            ObjectSetInteger(0, str_17, 101, 1);
            ObjectSetString(0, str_17, 999, str_30);
            ObjectSetString(0, str_17, 1001, "Arial");
            ObjectSetInteger(0, str_17, 100, 8);
            ObjectSetInteger(0, str_17, 6, White);
            ObjectSetInteger(0, str_17, 208, 0);
            ObjectSetInteger(0, str_17, 9, 0);
             str_31 = "Drawdown (Max) :  ";
            str_32 = "ERROR_T14";
            ObjectCreate(0, str_32, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_32, 102, 1520);
            ObjectSetInteger(0, str_32, 103, 260);
            ObjectSetInteger(0, str_32, 101, 1);
            ObjectSetString(0, str_32, 999, str_31);
            ObjectSetString(0, str_32, 1001, "Arial");
            ObjectSetInteger(0, str_32, 100, 8);
            ObjectSetInteger(0, str_32, 6, White);
            ObjectSetInteger(0, str_32, 208, 0);
            ObjectSetInteger(0, str_32, 9, 0);
             str_34 = "Margin Usage : ";
            str_80 = "ERROR_T198";
            ObjectCreate(0, str_80, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_80, 102, 1520);
            ObjectSetInteger(0, str_80, 103, 275);
            ObjectSetInteger(0, str_80, 101, 1);
            ObjectSetString(0, str_80, 999, str_34);
            ObjectSetString(0, str_80, 1001, "Arial");
            ObjectSetInteger(0, str_80, 100, 8);
            ObjectSetInteger(0, str_80, 6, White);
            ObjectSetInteger(0, str_80, 208, 0);
            ObjectSetInteger(0, str_80, 9, 0);
             str_35 = "Total Profit/Loss : "+(string)AccountProfit();
            str_36 = "ERROR_T285";
            ObjectCreate(0, str_36, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_36, 102, 1520);
            ObjectSetInteger(0, str_36, 103, 290);
            ObjectSetInteger(0, str_36, 101, 1);
            ObjectSetString(0, str_36, 999, str_35);
            ObjectSetString(0, str_36, 1001, "Arial");
            ObjectSetInteger(0, str_36, 100, 8);
            ObjectSetInteger(0, str_36, 6, White);
            ObjectSetInteger(0, str_36, 208, 0);
            ObjectSetInteger(0, str_36, 9, 0);
             str_37 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_38 = "ERROR_T458";
            ObjectCreate(0, str_38, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_38, 102, 1520);
            ObjectSetInteger(0, str_38, 103, 305);
            ObjectSetInteger(0, str_38, 101, 1);
            ObjectSetString(0, str_38, 999, str_37);
            ObjectSetString(0, str_38, 1001, "Arial");
            ObjectSetInteger(0, str_38, 100, 8);
            ObjectSetInteger(0, str_38, 6, White);
            ObjectSetInteger(0, str_38, 208, 0);
            ObjectSetInteger(0, str_38, 9, 0);
             str_39 = "MORE INFORMATIONS";
            str_40 = "ERROR_T48";
            ObjectCreate(0, str_40, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_40, 102, 1520);
            ObjectSetInteger(0, str_40, 103, 320);
            ObjectSetInteger(0, str_40, 101, 1);
            ObjectSetString(0, str_40, 999, str_39);
            ObjectSetString(0, str_40, 1001, "Arial");
            ObjectSetInteger(0, str_40, 100, 8);
            ObjectSetInteger(0, str_40, 6, White);
            ObjectSetInteger(0, str_40, 208, 0);
            ObjectSetInteger(0, str_40, 9, 0);
             str_41 = "-----------------------------------------------------------------------------------------------------------------------------";
            str_42 = "ERROR_T545";
            ObjectCreate(0, str_42, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_42, 102, 1520);
            ObjectSetInteger(0, str_42, 103, 335);
            ObjectSetInteger(0, str_42, 101, 1);
            ObjectSetString(0, str_42, 999, str_41);
            ObjectSetString(0, str_42, 1001, "Arial");
            ObjectSetInteger(0, str_42, 100, 8);
            ObjectSetInteger(0, str_42, 6, White);
            ObjectSetInteger(0, str_42, 208, 0);
            ObjectSetInteger(0, str_42, 9, 0);
             str_43 = "Symbol : "+Symbol();
            str_50 = "ERROR_T565";
            ObjectCreate(0, str_50, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_50, 102, 1520);
            ObjectSetInteger(0, str_50, 103, 350);
            ObjectSetInteger(0, str_50, 101, 1);
            ObjectSetString(0, str_50, 999, str_43);
            ObjectSetString(0, str_50, 1001, "Arial");
            ObjectSetInteger(0, str_50, 100, 8);
            ObjectSetInteger(0, str_50, 6, White);
            ObjectSetInteger(0, str_50, 208, 0);
            ObjectSetInteger(0, str_50, 9, 0);
             str_45 = "Price : ";
            str_46 = "ERROR_5547";
            ObjectCreate(0, str_46, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_46, 102, 1520);
            ObjectSetInteger(0, str_46, 103, 365);
            ObjectSetInteger(0, str_46, 101, 1);
            ObjectSetString(0, str_46, 999, str_45);
            ObjectSetString(0, str_46, 1001, "Arial");
            ObjectSetInteger(0, str_46, 100, 8);
            ObjectSetInteger(0, str_46, 6, White);
            ObjectSetInteger(0, str_46, 208, 0);
            ObjectSetInteger(0, str_46, 9, 0);
             str_47 = "Current Spread : 2";
            str_48 = "ERROR_T54";
            ObjectCreate(0, str_48, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, str_48, 102, 1520);
            ObjectSetInteger(0, str_48, 103, 380);
            ObjectSetInteger(0, str_48, 101, 1);
            ObjectSetString(0, str_48, 999, str_47);
            ObjectSetString(0, str_48, 1001, "Arial");
            ObjectSetInteger(0, str_48, 100, 8);
            ObjectSetInteger(0, str_48, 6, White);
            ObjectSetInteger(0, str_48, 208, 0);
            ObjectSetInteger(0, str_48, 9, 0);
            
            
            
            
            
            
                     
   if(current!=Time[0])
     {
      current=Time[0];
      if(day!=Day()) {isTrade=true;day=Day();}

      int startHour=StrToInteger(StringSubstr(openTime,0,2));
      int startMinute=StrToInteger(StringSubstr(openTime,3,2));
      int endHour=StrToInteger(StringSubstr(closeTime,0,2));
      int endMinute=StrToInteger(StringSubstr(closeTime,3,2));

      if(tradeTime()==true && isTrade==true)
        {
         orderBuy();
         orderSell();
         isTrade=false;
        }
     }
   if(oneTrade==true&&ordersTotal()>0) orderCloseStop();
   if(tradeTime()==false) {orderClose();}
   if(ts==true) trailingStop();
  }
//+------------------------------------------------------------------+
//| Function to place Buy order                                      |
//+------------------------------------------------------------------+
void orderBuy()
  {
   double price=Ask+pips_to_change(distance);
   double sl=NormalizeDouble(price-pips_to_change(stopLoss),Digits);
   double tp=NormalizeDouble(price+pips_to_change(takeProfit),Digits);
   if(stopLoss==0) sl=0;
   if(takeProfit==0) tp=0;
   if(OrderSend(Symbol(),OP_BUYSTOP,lotSize,price,slippage,sl,tp,"",magic,0,clrBlue)<0)
     {
      Print("Buy Stop Order failed with error #",GetLastError());
     }
   else { Print("Buy Stop Order placed successfully");}

  }
//+------------------------------------------------------------------+
//| Function to place Sell Order                                     |
//+------------------------------------------------------------------+
void orderSell()
  {
   double price=Bid-pips_to_change(distance);
   double sl=NormalizeDouble(price+pips_to_change(stopLoss),Digits);
   double tp=NormalizeDouble(price-pips_to_change(takeProfit),Digits);
   if(stopLoss==0) sl=0;
   if(takeProfit==0) tp=0;

   if(OrderSend(Symbol(),OP_SELLSTOP,lotSize,price,slippage,sl,tp,"",magic,0,clrRed)<0)
     {
      Print("Sell Stop Order failed with error #",GetLastError());
     }
   else
     {
      Print("Sell Stop Order placed successfully");
     }

  }
//+------------------------------------------------------------------+
//| Function to close all the orders                                 |
//+------------------------------------------------------------------+
void orderClose()
  {

   for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
     {
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
              {
               int orderType=OrderType();
               string str="";
               if(OrderType()==OP_BUYSTOP) str="Buy Stop";
               if(OrderType()==OP_SELLSTOP) str="Sell Stop";
               if(OrderDelete(OrderTicket(),clrCyan)==true) Print(str+" Order Closed on Exit time.");
               else Print("Error in closing the order "+str+" Error code="+IntegerToString(GetLastError()));
              }
            if(OrderType()==OP_BUY)
              {

               if(OrderClose(OrderTicket(),OrderLots(),Bid,slippage,clrCyan)==true)
                 {
                  Print("Buy Order closed on Exit time.");
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(OrderClose(OrderTicket(),OrderLots(),Ask,slippage,clrCyan)==true)
                 {
                  Print("Sell Order closed on Exit time.");
                 }
              }
           }

        }
     }
  }
//+------------------------------------------------------------------+
//| Function to close all the Stop orders                            |
//+------------------------------------------------------------------+
void orderCloseStop()
  {

   for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
     {
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
              {
               int orderType=OrderType();
               string str="";
               if(OrderType()==OP_BUYSTOP) str="Buy Stop";
               if(OrderType()==OP_SELLSTOP) str="Sell Stop";
               if(OrderDelete(OrderTicket(),clrCyan)==true) Print(str+" Order Closed because another trade has opened.");
               else Print("Error in closing the order "+str+" Error code="+IntegerToString(GetLastError()));
              }
           }

        }
     }
  }
//+----------------------------------------------------------------+
//| Function to return orders count                                  |
//+------------------------------------------------------------------+
int ordersTotal()
  {
   int o=0;
   for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
     {
      if(OrderSelect(i-1,SELECT_BY_POS)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (OrderType()==OP_BUY || OrderType()==OP_SELL))
            o++;
        }
     }
   return o;
  }
//+------------------------------------------------------------------+
//| Trailing Stop function                                           |
//+------------------------------------------------------------------+
void trailingStop()
  {

   for(int i=1; i<=OrdersTotal(); i++) // Cycle searching in orders
     {
      if(OrderSelect(i-1,SELECT_BY_POS)==true) // If the next is available
        {                                                    // Analysis of orders:
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            double SL=OrderStopLoss();                       // SL of the selected order
            string Text;
            bool Modify=false;                            // Not to be modified

            if(OrderType()==OP_BUY)
              {
               if(NormalizeDouble(SL,Digits)<NormalizeDouble(Bid-pips_to_change(TralStop),Digits) && (NormalizeDouble(Ask-OrderOpenPrice(),Digits))>=NormalizeDouble(pips_to_change(TralStop),Digits))
                 {
                  SL=Bid-pips_to_change(TralStop);                     // then modify it
                  Text="Buy ";                                         // Text for Buy 
                  Modify=true;                                         // To be modified
                 }
              }
            else if(OrderType()==OP_SELL)
              {
               if((NormalizeDouble(SL,Digits)>NormalizeDouble(Ask+pips_to_change(TralStop),Digits) || NormalizeDouble(SL,Digits)==0) && (NormalizeDouble(OrderOpenPrice()-Bid,Digits)>=NormalizeDouble(pips_to_change(TralStop),Digits)))
                 {

                  SL=Ask+pips_to_change(TralStop);                     // then modify it
                  Text="Sell ";                                        // Text for Sell 
                  Modify=true;                                         // To be modified
                 }
              }

            if(Modify==true)
              {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,clrDarkRed)==true)
                 {
                  Print("Trailing stop: Order ",Text,OrderTicket()," is modified successfully:)");

                 }
               else
                 {
                  Print("Trailing stop: Order ",Text,OrderTicket()," modification failed:)");

                 }
              }

           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to check TradeTime                                      |
//+------------------------------------------------------------------+
bool tradeTime()
  {
   int startHour,endHour,startMinute,endMinute;
   startHour=StrToInteger(StringSubstr(openTime,0,2));
   startMinute=StrToInteger(StringSubstr(openTime,3,2));

   endHour=StrToInteger(StringSubstr(closeTime,0,2));
   endMinute=StrToInteger(StringSubstr(closeTime,3,2));
   bool flag=false;

   if(Hour()>=startHour && Hour()<=endHour)
     {
      if(startHour==endHour)
        {
         if(Minute()>=startMinute && Minute()<=endMinute)
           {
            flag=true;
           }
         else
           {
            flag=false;
           }
        }
      else if(Hour()==startHour)
        {
         if(Minute()>=startMinute)
           {
            flag=true;
           }
         else
           {
            flag=false;
           }
        }
      else if(Hour()==endHour)
        {
         if(Minute()<=endMinute)
           {
            flag=true;
           }
         else
           {
            flag=false;
           }
        }
      else
        {
         flag=true;
        }
     }
   else
     {
      flag=false;
     }

   return flag;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double points_to_change(int n){ return n*_Point;  }

int    change_to_points(double c){  return int(c/_Point+0.5);   }

double   pips_to_change(double n){  return points_to_change(pips_to_points(n));}

double   change_to_pips(double c){  return points_to_pips(change_to_points(c));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int    pips_to_points(double n)
  {
   if((_Digits&1)==1) n*=10.0;
   return int(n);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  points_to_pips(int n)
  {
   double p=NormalizeDouble(n,Digits);
   if((_Digits&1)==1) p/=10.0;
   return p;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
