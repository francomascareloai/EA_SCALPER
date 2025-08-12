//+------------------------------------------------------------------+
//|                                         CONTROL PANEL PART 1.mq5 |
//|                           Copyright 2024, Allan Munene Mutiiria. |
//|                                     https://forexalgo-trader.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Allan Munene Mutiiria." //--- Set copyright information
#property link      "https://forexalgo-trader.com"            //--- Link to the author's website
#property version   "1.00"                                    //--- Version of the script

//#include <Trade/Trade.mqh>                                     //--- Include trade library
//CTrade obj_Trade;                                            //--- Create an instance of the CTrade class

#include <Controls/Button.mqh>                                 //--- Include button control library
CButton obj_Btn_MAIN;                                       //--- Main button object
CButton obj_Btn_HEADER;                                     //--- Header button object
CButton obj_Btn_X;                                          //--- Close button (X) object
CButton obj_Btn_TRADE;                                     //--- Trade button object
CButton obj_Btn_CLOSE;                                      //--- Close button object
CButton obj_Btn_INFO;                                       //--- Information button object
CButton obj_Btn_RISK;                                       //--- Risk button object
CButton obj_Btn_POINTS;                                     //--- Points button object
CButton obj_Btn_SELL;                                       //--- Sell button object
CButton obj_Btn_ENTRY;                                      //--- Entry button object
CButton obj_Btn_BUY;                                        //--- Buy button object
CButton obj_Btn_SELLSTOP;                                   //--- Sell Stop button object
CButton obj_Btn_BUYSTOP;                                    //--- Buy Stop button object
CButton obj_Btn_SELLLIMIT;                                  //--- Sell Limit button object
CButton obj_Btn_BUYLIMIT;                                   //--- Buy Limit button object
CButton obj_Btn_FOOTER;                                     //--- Footer button object

CButton obj_Btn_CLOSE_ALL;                                  //--- Close All button object
CButton obj_Btn_CLOSE_ALL_SELL;                             //--- Close All Sell button object
CButton obj_Btn_CLOSE_ALL_BUY;                              //--- Close All Buy button object
CButton obj_Btn_CLOSE_LOSS_SELL;                            //--- Close Loss Sell button object
CButton obj_Btn_CLOSE_LOSS_BUY;                             //--- Close Loss Buy button object
CButton obj_Btn_CLOSE_PROFIT_SELL;                          //--- Close Profit Sell button object
CButton obj_Btn_CLOSE_PROFIT_BUY;                           //--- Close Profit Buy button object
CButton obj_Btn_CLOSE_ALL_LOSS;                             //--- Close All Loss button object
CButton obj_Btn_CLOSE_ALL_PROFIT;                           //--- Close All Profit button object
CButton obj_Btn_CLOSE_PENDING;                              //--- Close Pending button object

CButton obj_Btn_ACC_NUMBER;                                 //--- Account Number button object
CButton obj_Btn_ACC_NAME;                                   //--- Account Name button object
CButton obj_Btn_ACC_TYPE;                                   //--- Account Type button object
CButton obj_Btn_ACC_LEVERAGE;                               //--- Account Leverage button object

CButton obj_Btn_ACC_EQUITY;                                 //--- Account Equity button object
CButton obj_Btn_ACC_BALANCE;                                //--- Account Balance button object
CButton obj_Btn_TIME;                                       //--- Time button object

#include <Controls/Edit.mqh>                                   //--- Include edit control library
CEdit obj_Edit_RISK;                                        //--- Risk edit field object
CEdit obj_Edit_PRICE;                                       //--- Price edit field object
CEdit obj_Edit_LOTS;                                        //--- Lots edit field object
CEdit obj_Edit_SL;                                          //--- Stop Loss edit field object
CEdit obj_Edit_TP;                                          //--- Take Profit edit field object

#include <Controls/Label.mqh>                                  //--- Include label control library
CLabel obj_Lbl_HEADER;                                      //--- Header label object
CLabel obj_Lbl_PRICE;                                       //--- Price label object
CLabel obj_Lbl_LOTS;                                        //--- Lots label object
CLabel obj_Lbl_SL;                                          //--- Stop Loss label object
CLabel obj_Lbl_TP;                                          //--- Take Profit label object

CLabel obj_Lbl_ACC_NUMBER;                                  //--- Account Number label object
CLabel obj_Lbl_ACC_NAME;                                    //--- Account Name label object
CLabel obj_Lbl_ACC_TYPE;                                    //--- Account Type label object
CLabel obj_Lbl_ACC_LEVERAGE;                                //--- Account Leverage label object

CLabel obj_Lbl_ACC_EQUITY;                                  //--- Account Equity label object
CLabel obj_Lbl_ACC_BALANCE;                                 //--- Account Balance label object
CLabel obj_Lbl_TIME;                                        //--- Time label object

//--- Define button names for easier reference
#define Btn_MAIN "Btn_MAIN"                                   //--- Button name for the main button
#define Btn_HEADER "Btn_HEADER"                               //--- Button name for the header button
#define Btn_X "Btn_X"                                        //--- Button name for the close button
#define Btn_TRADE "Btn_TRADE"                               //--- Button name for the trade button
#define Btn_CLOSE "Btn_CLOSE"                                //--- Button name for the close button
#define Btn_INFO "Btn_INFO"                                  //--- Button name for the info button

#define Btn_RISK "Btn_RISK"                                  //--- Button name for the risk button
#define Btn_POINTS "Btn_POINTS"                              //--- Button name for the points button
#define Btn_SELL "Btn_SELL"                                  //--- Button name for the sell button
#define Btn_ENTRY "Btn_ENTRY"                                //--- Button name for the entry button
#define Btn_BUY "Btn_BUY"                                    //--- Button name for the buy button
#define Btn_SELLSTOP "Btn_SELLSTOP"                          //--- Button name for the sell stop button
#define Btn_BUYSTOP "Btn_BUYSTOP"                            //--- Button name for the buy stop button
#define Btn_SELLLIMIT "Btn_SELLLIMIT"                        //--- Button name for the sell limit button
#define Btn_BUYLIMIT "Btn_BUYLIMIT"                          //--- Button name for the buy limit button
#define Btn_FOOTER "Btn_FOOTER"                              //--- Button name for the footer button

#define Btn_CLOSE_ALL "Btn_CLOSE_ALL"                        //--- Button name for closing all trades
#define Btn_CLOSE_ALL_SELL "Btn_CLOSE_ALL_SELL"              //--- Button name for closing all sell trades
#define Btn_CLOSE_ALL_BUY "Btn_CLOSE_ALL_BUY"                //--- Button name for closing all buy trades
#define Btn_CLOSE_LOSS_SELL "Btn_CLOSE_LOSS_SELL"            //--- Button name for closing all loss sell trades
#define Btn_CLOSE_LOSS_BUY "Btn_CLOSE_LOSS_BUY"              //--- Button name for closing all loss buy trades
#define Btn_CLOSE_PROFIT_SELL "Btn_CLOSE_PROFIT_SELL"        //--- Button name for closing all profit sell trades
#define Btn_CLOSE_PROFIT_BUY "Btn_CLOSE_PROFIT_BUY"          //--- Button name for closing all profit buy trades
#define Btn_CLOSE_ALL_LOSS "Btn_CLOSE_ALL_LOSS"              //--- Button name for closing all loss trades
#define Btn_CLOSE_ALL_PROFIT "Btn_CLOSE_ALL_PROFIT"          //--- Button name for closing all profit trades
#define Btn_CLOSE_PENDING "Btn_CLOSE_PENDING"                //--- Button name for closing all pending trades

#define Btn_ACC_NUMBER "Btn_ACC_NUMBER"                      //--- Button name for the account number
#define Btn_ACC_NAME "Btn_ACC_NAME"                          //--- Button name for the account name
#define Btn_ACC_TYPE "Btn_ACC_TYPE"                          //--- Button name for the account type
#define Btn_ACC_LEVERAGE "Btn_ACC_LEVERAGE"                  //--- Button name for the account leverage

#define Btn_ACC_EQUITY "Btn_ACC_EQUITY"                      //--- Button name for the account equity
#define Btn_ACC_BALANCE "Btn_ACC_BALANCE"                    //--- Button name for the account balance
#define Btn_TIME "Btn_TIME"                                  //--- Button name for the time

//--- Define edit field names for easier reference
#define Edit_RISK "Edit_RISK"                                //--- Edit field name for risk input
#define Edit_PRICE "Edit_PRICE"                              //--- Edit field name for price input
#define Edit_LOTS "Edit_LOTS"                                //--- Edit field name for lots input
#define Edit_SL "Edit_SL"                                    //--- Edit field name for stop loss input
#define Edit_TP "Edit_TP"                                    //--- Edit field name for take profit input

//--- Define label names for easier reference
#define Lbl_HEADER "Lbl_HEADER"                              //--- Label name for the header
#define Lbl_PRICE "Lbl_PRICE"                                //--- Label name for the price
#define Lbl_LOTS "Lbl_LOTS"                                  //--- Label name for the lots
#define Lbl_SL "Lbl_SL"                                      //--- Label name for the stop loss
#define Lbl_TP "Lbl_TP"                                      //--- Label name for the take profit

#define Lbl_ACC_NUMBER "Lbl_ACC_NUMBER"                      //--- Label name for the account number
#define Lbl_ACC_NAME "Lbl_ACC_NAME"                          //--- Label name for the account name
#define Lbl_ACC_TYPE "Lbl_ACC_TYPE"                          //--- Label name for the account type
#define Lbl_ACC_LEVERAGE "Lbl_ACC_LEVERAGE"                  //--- Label name for the account leverage

#define Lbl_ACC_EQUITY "Lbl_ACC_EQUITY"                      //--- Label name for the account equity
#define Lbl_ACC_BALANCE "Lbl_ACC_BALANCE"                    //--- Label name for the account balance
#define Lbl_TIME "Lbl_TIME"                                  //--- Label name for the time



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   //--- Start of the initialization function

   //--- MAIN BUTTON
   obj_Btn_MAIN.Create(0, Btn_MAIN, 0, 30, 30, 0, 0); //--- Create the main button at specified coordinates
   //obj_Btn_MAIN.Width(310); //--- (Commented out) Set width of the main button
   //obj_Btn_MAIN.Height(300); //--- (Commented out) Set height of the main button
   obj_Btn_MAIN.Size(310, 300); //--- Set size of the main button
   obj_Btn_MAIN.ColorBackground(C'070,070,070'); //--- Set background color of the main button
   obj_Btn_MAIN.ColorBorder(clrBlack); //--- Set border color of the main button

   //--- HEADER BUTTON 
   obj_Btn_HEADER.Create(0, Btn_HEADER, 0, 30, 30, 0, 0); //--- Create the header button at specified coordinates
   obj_Btn_HEADER.Size(310, 25); //--- Set size of the header button
   obj_Btn_HEADER.ColorBackground(clrLightBlue); //--- Set background color of the header button
   obj_Btn_HEADER.ColorBorder(clrBlack); //--- Set border color of the header button

   //--- X BUTTON
   obj_Btn_X.Create(0, Btn_X, 0, 30 + 280, 30 + 1, 0, 0); //--- Create the close button (X) at specified coordinates
   obj_Btn_X.Size(30 - 1, 25 - 1 - 1); //--- Set size of the close button
   obj_Btn_X.ColorBackground(clrLightBlue); //--- Set background color of the close button
   obj_Btn_X.ColorBorder(clrLightBlue); //--- Set border color of the close button
   obj_Btn_X.Text(CharToString(255)); //--- Set the close button text to an "X" character
   obj_Btn_X.Color(clrBlack); //--- Set text color of the close button
   obj_Btn_X.Font("Wingdings"); //--- Set font of the close button to Wingdings
   obj_Btn_X.FontSize(17); //--- Set font size of the close button

   //--- HEADER LABEL
   obj_Lbl_HEADER.Create(0, Lbl_HEADER, 0, 40, 30, 0, 0); //--- Create the header label at specified coordinates
   obj_Lbl_HEADER.Text("Control Panel"); //--- Set text of the header label
   obj_Lbl_HEADER.Color(clrRed); //--- Set text color of the header label
   obj_Lbl_HEADER.Font("Cooper black"); //--- Set font of the header label to Cooper Black
   obj_Lbl_HEADER.FontSize(14); //--- Set font size of the header label
   
   //--- TRADE BUTTON
   obj_Btn_TRADE.Create(0, Btn_TRADE, 0, 40, 60, 0, 0); //--- Create the trade button at specified coordinates
   obj_Btn_TRADE.Size(90, 30); //--- Set size of the trade button
   obj_Btn_TRADE.ColorBackground(clrYellow); //--- Set background color of the trade button
   obj_Btn_TRADE.ColorBorder(clrYellow); //--- Set border color of the trade button
   obj_Btn_TRADE.Text("Trade"); //--- Set text of the trade button
   obj_Btn_TRADE.Color(clrBlack); //--- Set text color of the trade button
   obj_Btn_TRADE.Font("Arial Black"); //--- Set font of the trade button to Arial Black
   obj_Btn_TRADE.FontSize(13); //--- Set font size of the trade button
   
   //--- CLOSE BUTTON
   obj_Btn_CLOSE.Create(0, Btn_CLOSE, 0, 40 + obj_Btn_TRADE.Width() + 10, 60, 0, 0); //--- Create the close button at specified coordinates
   obj_Btn_CLOSE.Size(90, 30); //--- Set size of the close button
   obj_Btn_CLOSE.ColorBackground(clrSilver); //--- Set background color of the close button
   obj_Btn_CLOSE.ColorBorder(clrSilver); //--- Set border color of the close button
   obj_Btn_CLOSE.Text("Close"); //--- Set text of the close button
   obj_Btn_CLOSE.Color(clrBlack); //--- Set text color of the close button
   obj_Btn_CLOSE.Font("Arial Black"); //--- Set font of the close button to Arial Black
   obj_Btn_CLOSE.FontSize(13); //--- Set font size of the close button

   //--- INFO BUTTON
   obj_Btn_INFO.Create(0, Btn_INFO, 0, 40 + obj_Btn_TRADE.Width() + 10 + obj_Btn_CLOSE.Width() + 10, 60, 0, 0); //--- Create the info button at specified coordinates
   obj_Btn_INFO.Size(90, 30); //--- Set size of the info button
   obj_Btn_INFO.ColorBackground(clrSilver); //--- Set background color of the info button
   obj_Btn_INFO.ColorBorder(clrSilver); //--- Set border color of the info button
   obj_Btn_INFO.Text("Inform'n"); //--- Set text of the info button
   obj_Btn_INFO.Color(clrBlack); //--- Set text color of the info button
   obj_Btn_INFO.Font("Arial Black"); //--- Set font of the info button to Arial Black
   obj_Btn_INFO.FontSize(13); //--- Set font size of the info button
   
   // BODY OF THE PANEL
   createSection_Trade(); //--- Call function to create the trade section
   //createSection_Close(); //--- (Commented out) Call function to create the close section
   //createSection_Information(); //--- (Commented out) Call function to create the information section

   //--- FOOTER BUTTON
   obj_Btn_FOOTER.Create(0, Btn_FOOTER, 0, 30 + 1, 305 - 1, 0, 0); //--- Create the footer button at specified coordinates
   obj_Btn_FOOTER.Size(310 - 1 - 1, 25); //--- Set size of the footer button
   obj_Btn_FOOTER.ColorBackground(C'070,070,070'); //--- Set background color of the footer button
   obj_Btn_FOOTER.ColorBorder(C'070,070,070'); //--- Set border color of the footer button
   obj_Btn_FOOTER.Text(ShortToString(0x23F0) + "https://t.me/Forex_Algo_Trader"); //--- Set text of the footer button with a link
   obj_Btn_FOOTER.Color(clrWhite); //--- Set text color of the footer button
   obj_Btn_FOOTER.Font("Calibri bold italic"); //--- Set font of the footer button to Calibri bold italic
   obj_Btn_FOOTER.FontSize(12); //--- Set font size of the footer button

   ChartRedraw(0); //--- Redraw the chart to update the panel

   //--- End of initialization function
   return(INIT_SUCCEEDED); //--- Return initialization success status
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   //--- Start of the deinitialization function

   destroySection_Main_Panel(); //--- Call function to destroy the main panel section
   destroySection_Trade(); //--- Call function to destroy the trade section
   destroySection_Close(); //--- Call function to destroy the close section
   destroySection_Information(); //--- Call function to destroy the information section
   
   ChartRedraw(0);
   
   //--- End of deinitialization function
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//void OnTick() {
//   //--- Start of the OnTick function, called on every price tick
//
//   //--- Check if the background color of the INFO button is yellow
//   if (obj_Btn_INFO.ColorBackground() == clrYellow) {
//      //--- Update the account equity display on the panel
//      obj_Btn_ACC_EQUITY.Text(DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
//
//      //--- Update the account balance display on the panel
//      obj_Btn_ACC_BALANCE.Text(DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
//
//      //--- Update the server trade time display on the panel
//      obj_Btn_TIME.Text(TimeToString(TimeTradeServer(), TIME_DATE | TIME_SECONDS));
//   }
//
//   //--- End of the OnTick function
//}
//+------------------------------------------------------------------+

////+------------------------------------------------------------------+
////| Handling chart events                                            |
////+------------------------------------------------------------------+
//void OnChartEvent(
//   const int       id,       // Event ID indicating the type of event (e.g., mouse click, timer, etc.)
//   const long&     lparam,   // Long type parameter associated with the event, usually containing data like mouse coordinates or object IDs
//   const double&   dparam,   // Double type parameter associated with the event, used for floating-point values related to the event
//   const string&   sparam    // String type parameter associated with the event, typically the name of the object that triggered the event
//){
//   // Check if the event is a click on a chart object
//   if (id == CHARTEVENT_OBJECT_CLICK){
//      // Check if the clicked object is the Trade button
//      if (sparam==obj_Btn_TRADE.Name()){
//         // Print to the log which object was clicked for debugging purposes
//         Print("OBJECT CLICKED = ", obj_Btn_TRADE.Name());
//
//         // Reset the pressed states of all buttons to ensure only one button appears pressed at a time
//         obj_Btn_TRADE.Pressed(false);
//         obj_Btn_CLOSE.Pressed(false);
//         obj_Btn_INFO.Pressed(false);
//
//         // Change the background color of the Trade button to yellow to indicate it is active
//         obj_Btn_TRADE.ColorBackground(clrYellow);
//         // Set the background color of the Close and Info buttons to silver to indicate they are inactive
//         obj_Btn_CLOSE.ColorBackground(clrSilver);
//         obj_Btn_INFO.ColorBackground(clrSilver);
//
//         // Set the border color of the Trade button to yellow to match its background
//         obj_Btn_TRADE.ColorBorder(clrYellow);
//         // Set the border color of the Close and Info buttons to silver to indicate they are inactive
//         obj_Btn_CLOSE.ColorBorder(clrSilver);
//         obj_Btn_INFO.ColorBorder(clrSilver);
//
//         // Call a function to destroy the Close section if it exists
//         destroySection_Close();
//         // Call a function to destroy the Information section if it exists
//         destroySection_Information();
//
//         // Create the Trade section, bringing it to the forefront
//         createSection_Trade();
//      }
//      // Check if the clicked object is the Close button
//      else if (sparam==obj_Btn_CLOSE.Name()){
//         // Print to the log which object was clicked for debugging purposes
//         Print("OBJECT CLICKED = ", obj_Btn_CLOSE.Name());
//
//         // Reset the pressed states of all buttons
//         obj_Btn_TRADE.Pressed(false);
//         obj_Btn_CLOSE.Pressed(false);
//         obj_Btn_INFO.Pressed(false);
//
//         // Set the background color of the Trade button to silver, indicating it's inactive
//         obj_Btn_TRADE.ColorBackground(clrSilver);
//         // Change the background color of the Close button to yellow to indicate it is active
//         obj_Btn_CLOSE.ColorBackground(clrYellow);
//         obj_Btn_INFO.ColorBackground(clrSilver);
//
//         // Set the border color of the Trade button to silver
//         obj_Btn_TRADE.ColorBorder(clrSilver);
//         // Set the border color of the Close button to yellow
//         obj_Btn_CLOSE.ColorBorder(clrYellow);
//         obj_Btn_INFO.ColorBorder(clrSilver);
//
//         // Call a function to destroy the Trade section if it exists
//         destroySection_Trade();
//         // Call a function to destroy the Information section if it exists
//         destroySection_Information();
//
//         // Create the Close section, bringing it to the forefront
//         createSection_Close();
//      }
//      // Check if the clicked object is the Information button
//      else if (sparam==obj_Btn_INFO.Name()){
//         // Print to the log which object was clicked for debugging purposes
//         Print("OBJECT CLICKED = ", obj_Btn_INFO.Name());
//
//         // Reset the pressed states of all buttons
//         obj_Btn_TRADE.Pressed(false);
//         obj_Btn_CLOSE.Pressed(false);
//         obj_Btn_INFO.Pressed(false);
//
//         // Set the background color of the Trade and Close buttons to silver, indicating they are inactive
//         obj_Btn_TRADE.ColorBackground(clrSilver);
//         obj_Btn_CLOSE.ColorBackground(clrSilver);
//         // Change the background color of the Info button to yellow to indicate it is active
//         obj_Btn_INFO.ColorBackground(clrYellow);
//
//         // Set the border color of the Trade and Close buttons to silver
//         obj_Btn_TRADE.ColorBorder(clrSilver);
//         obj_Btn_CLOSE.ColorBorder(clrSilver);
//         // Set the border color of the Info button to yellow
//         obj_Btn_INFO.ColorBorder(clrYellow);
//
//         // Call a function to destroy the Trade section if it exists
//         destroySection_Trade();
//         // Call a function to destroy the Close section if it exists
//         destroySection_Close();
//
//         // Create the Information section, bringing it to the forefront
//         createSection_Information();
//      }
//      // Check if the clicked object is the exit button (X button)
//      else if (sparam==obj_Btn_X.Name()){
//         // Print to the log which object was clicked for debugging purposes
//         Print("OBJECT CLICKED = ", obj_Btn_X.Name());
//
//         // Call functions to destroy all sections, effectively closing the entire panel
//         destroySection_Trade();
//         destroySection_Close();
//         destroySection_Information();
//
//         // Call a function to destroy the main panel itself
//         destroySection_Main_Panel();
//      }
//      else if (sparam==obj_Btn_SELL.Name()){ //--- Check if the Sell button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_SELL.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//         double entry_price = Bid; //--- Set the entry price for selling to the current bid price
//         double stopLoss = Ask+StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//         double takeprofit = Ask-StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//         
//         Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//         obj_Trade.Sell(lots,_Symbol,entry_price,stopLoss,takeprofit); //--- Execute the sell order
//      }
//      else if (sparam==obj_Btn_BUY.Name()){ //--- Check if the Buy button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_BUY.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//         double entry_price = Ask; //--- Set the entry price for buying to the current ask price
//         double stopLoss = Bid-StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//         double takeprofit = Bid+StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//         
//         Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//         obj_Trade.Buy(lots,_Symbol,entry_price,stopLoss,takeprofit); //--- Execute the buy order
//      }
//      else if (sparam==obj_Btn_SELLSTOP.Name()){ //--- Check if the Sell Stop button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_SELLSTOP.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double user_price = StringToDouble(obj_Edit_PRICE.Text()); //--- Get the user-defined price from input field
//         long stopslevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); //--- Get the minimum stop level for the symbol
//         double valid_price = Bid - stopslevel*_Point; //--- Calculate the valid price for placing a sell stop order
//         
//         if (user_price > valid_price){ //--- Check if the user-defined price is valid
//            Print("ERROR: INVALID STOPS PRICE. ",user_price," > ",valid_price); //--- Log an error message
//         }
//         else if (user_price <= valid_price){ //--- If the user-defined price is valid
//            double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//            double entry_price = user_price; //--- Set the entry price for the sell stop order
//            double stopLoss = user_price+StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//            double takeprofit = user_price-StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//            
//            Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//            obj_Trade.SellStop(lots,entry_price,_Symbol,stopLoss,takeprofit); //--- Execute the sell stop order
//         }
//      }
//      else if (sparam==obj_Btn_BUYSTOP.Name()){ //--- Check if the Buy Stop button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_BUYSTOP.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double user_price = StringToDouble(obj_Edit_PRICE.Text()); //--- Get the user-defined price from input field
//         long stopslevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); //--- Get the minimum stop level for the symbol
//         double valid_price = Ask + stopslevel*_Point; //--- Calculate the valid price for placing a buy stop order
//         
//         if (user_price < valid_price){ //--- Check if the user-defined price is valid
//            Print("ERROR: INVALID STOPS PRICE. ",user_price," < ",valid_price); //--- Log an error message
//         }
//         else if (user_price >= valid_price){ //--- If the user-defined price is valid
//            double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//            double entry_price = user_price; //--- Set the entry price for the buy stop order
//            double stopLoss = user_price-StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//            double takeprofit = user_price+StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//            
//            Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//            obj_Trade.BuyStop(lots,entry_price,_Symbol,stopLoss,takeprofit); //--- Execute the buy stop order
//         }
//      }
//      else if (sparam==obj_Btn_SELLLIMIT.Name()){ //--- Check if the Sell Limit button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_SELLLIMIT.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double user_price = StringToDouble(obj_Edit_PRICE.Text()); //--- Get the user-defined price from input field
//         long stopslevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); //--- Get the minimum stop level for the symbol
//         double valid_price = Bid + stopslevel*_Point; //--- Calculate the valid price for placing a sell limit order
//         
//         if (user_price < valid_price){ //--- Check if the user-defined price is valid
//            Print("ERROR: INVALID STOPS PRICE. ",user_price," < ",valid_price); //--- Log an error message
//         }
//         else if (user_price >= valid_price){ //--- If the user-defined price is valid
//            double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//            double entry_price = user_price; //--- Set the entry price for the sell limit order
//            double stopLoss = user_price+StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//            double takeprofit = user_price-StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//            
//            Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//            obj_Trade.SellLimit(lots,entry_price,_Symbol,stopLoss,takeprofit); //--- Execute the sell limit order
//         }
//      }
//      else if (sparam==obj_Btn_BUYLIMIT.Name()){ //--- Check if the Buy Limit button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_BUYLIMIT.Name()); //--- Log the button click event
//         
//         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); //--- Get and normalize the ask price
//         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); //--- Get and normalize the bid price
//         
//         double user_price = StringToDouble(obj_Edit_PRICE.Text()); //--- Get the user-defined price from input field
//         long stopslevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); //--- Get the minimum stop level for the symbol
//         double valid_price = Ask - stopslevel*_Point; //--- Calculate the valid price for placing a buy limit order
//         
//         if (user_price > valid_price){ //--- Check if the user-defined price is valid
//            Print("ERROR: INVALID STOPS PRICE. ",user_price," > ",valid_price); //--- Log an error message
//         }
//         else if (user_price <= valid_price){ //--- If the user-defined price is valid
//            double lots = StringToDouble(obj_Edit_LOTS.Text()); //--- Get the lot size from input field
//            double entry_price = user_price; //--- Set the entry price for the buy limit order
//            double stopLoss = user_price-StringToDouble(obj_Edit_SL.Text())*_Point; //--- Calculate stop loss based on user input
//            double takeprofit = user_price+StringToDouble(obj_Edit_TP.Text())*_Point; //--- Calculate take profit based on user input
//            
//            Print("Lots = ",lots,", Entry = ",entry_price,", SL = ",stopLoss,", TP = ",takeprofit); //--- Log order details
//            obj_Trade.BuyLimit(lots,entry_price,_Symbol,stopLoss,takeprofit); //--- Execute the buy limit order
//         }
//      }
//
//      
//      else if (sparam==obj_Btn_CLOSE_ALL.Name()){ //--- Check if the Close All button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_ALL.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     obj_Trade.PositionClose(pos_ticket); //--- Close the position
//                  }
//               }
//            }
//         }
//      }
//      else if (sparam==obj_Btn_CLOSE_ALL_SELL.Name()){ //--- Check if the Close All Sell button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_ALL_SELL.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_SELL){ //--- Check if the position is a sell position
//                        obj_Trade.PositionClose(pos_ticket); //--- Close the sell position
//                     }
//                  }
//               }
//            }
//         }
//      }
//      else if (sparam==obj_Btn_CLOSE_ALL_BUY.Name()){ //--- Check if the Close All Buy button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_ALL_BUY.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_BUY){ //--- Check if the position is a buy position
//                        obj_Trade.PositionClose(pos_ticket); //--- Close the buy position
//                     }
//                  }
//               }
//            }
//         }
//      }
//      else if (sparam==obj_Btn_CLOSE_LOSS_SELL.Name()){ //--- Check if the Close Loss Sell button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_LOSS_SELL.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_SELL){ //--- Check if the position is a sell position
//                        double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                        if (profit_loss < 0){ //--- Check if the position is at a loss
//                           obj_Trade.PositionClose(pos_ticket); //--- Close the losing sell position
//                        }
//                     }
//                  }
//               }
//            }
//         }
//      }
//      else if (sparam==obj_Btn_CLOSE_LOSS_BUY.Name()){ //--- Check if the Close Loss Buy button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_LOSS_BUY.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_BUY){ //--- Check if the position is a buy position
//                        double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                        if (profit_loss < 0){ //--- Check if the position is at a loss
//                           obj_Trade.PositionClose(pos_ticket); //--- Close the losing buy position
//                        }
//                     }
//                  }
//               }
//            }
//         }
//      }
//      
//      else if (sparam==obj_Btn_CLOSE_PROFIT_SELL.Name()){ //--- Check if the Close Profit Sell button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_PROFIT_SELL.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_SELL){ //--- Check if the position is a sell position
//                        double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                        if (profit_loss >= 0){ //--- Check if the position is profitable
//                           obj_Trade.PositionClose(pos_ticket); //--- Close the profitable sell position
//                        }
//                     }
//                  }
//               }
//            }
//         }
//      }
//
//      else if (sparam==obj_Btn_CLOSE_PROFIT_BUY.Name()){ //--- Check if the Close Profit Buy button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_PROFIT_BUY.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get the position type
//                     if (pos_type == POSITION_TYPE_BUY){ //--- Check if the position is a buy position
//                        double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                        if (profit_loss >= 0){ //--- Check if the position is profitable
//                           obj_Trade.PositionClose(pos_ticket); //--- Close the profitable buy position
//                        }
//                     }
//                  }
//               }
//            }
//         }
//      }      
//      else if (sparam==obj_Btn_CLOSE_ALL_LOSS.Name()){ //--- Check if the Close All Loss button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_ALL_LOSS.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                     if (profit_loss < 0){ //--- Check if the position is at a loss
//                        obj_Trade.PositionClose(pos_ticket); //--- Close the losing position
//                     }
//                  }
//               }
//            }
//         }
//      }            
//      else if (sparam==obj_Btn_CLOSE_ALL_PROFIT.Name()){ //--- Check if the Close All Profit button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_ALL_PROFIT.Name()); //--- Log the button click event
//         
//         for (int i = PositionsTotal() -1; i >= 0; i--){ //--- Loop through all positions
//            ulong pos_ticket = PositionGetTicket(i); //--- Get the ticket of the position
//            if (pos_ticket > 0){ //--- Check if the position ticket is valid
//               if (PositionSelectByTicket(pos_ticket)){ //--- Select the position by ticket
//                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){ //--- Check if the position matches the symbol
//                     double profit_loss = PositionGetDouble(POSITION_PROFIT); //--- Get the profit/loss of the position
//                     if (profit_loss >= 0){ //--- Check if the position is profitable
//                        obj_Trade.PositionClose(pos_ticket); //--- Close the profitable position
//                     }
//                  }
//               }
//            }
//         }
//      }            
//      else if (sparam==obj_Btn_CLOSE_PENDING.Name()){ //--- Check if the Close Pending button is clicked
//         Print("OBJECT CLICKED = ",obj_Btn_CLOSE_PENDING.Name()); //--- Log the button click event
//         
//         for (int i = OrdersTotal() -1; i >= 0; i--){ //--- Loop through all pending orders
//            ulong order_ticket = OrderGetTicket(i); //--- Get the ticket of the order
//            if (order_ticket > 0){ //--- Check if the order ticket is valid
//               if (OrderSelect(order_ticket)){ //--- Select the order by ticket
//                  if (OrderGetString(ORDER_SYMBOL)==_Symbol){ //--- Check if the order matches the symbol
//                     obj_Trade.OrderDelete(order_ticket); //--- Delete the pending order
//                  }
//               }
//            }
//         }
//      }
//
//      
//   }
//   
//   
//   ChartRedraw(0);
//   
//}



//+------------------------------------------------------------------+
//|     FUNCTION TO CREATE THE TRADE SECTION                         |
//+------------------------------------------------------------------+
void createSection_Trade(){
   //--- RISK BUTTON
   obj_Btn_RISK.Create(0,Btn_RISK,0,40,100,0,0); //--- Create the risk button
   obj_Btn_RISK.Size(210,25); //--- Set the button size
   obj_Btn_RISK.ColorBackground(clrTurquoise); //--- Set the background color
   obj_Btn_RISK.ColorBorder(clrTurquoise); //--- Set the border color
   obj_Btn_RISK.Text("Risk based on Equity (%)"); //--- Set the button text
   obj_Btn_RISK.Color(clrBlack); //--- Set the text color
   obj_Btn_RISK.Font("Arial Black"); //--- Set the font style
   obj_Btn_RISK.FontSize(11); //--- Set the font size
   
   //--- RISK EDIT
   obj_Edit_RISK.Create(0,Edit_RISK,0,40+220,100,0,0); //--- Create the risk edit field
   obj_Edit_RISK.Size(70,25); //--- Set the edit field size
   obj_Edit_RISK.ColorBackground(clrWhite); //--- Set the background color
   obj_Edit_RISK.ColorBorder(clrBlack); //--- Set the border color
   obj_Edit_RISK.Text("78"); //--- Set the default text
   obj_Edit_RISK.Color(clrBlack); //--- Set the text color
   obj_Edit_RISK.Font("Times new roman bold"); //--- Set the font style
   obj_Edit_RISK.FontSize(15); //--- Set the font size
   
   //--- PRICE LABEL
   obj_Lbl_PRICE.Create(0,Lbl_PRICE,0,40,130,0,0); //--- Create the price label
   obj_Lbl_PRICE.Text("Price"); //--- Set the label text
   obj_Lbl_PRICE.Color(clrWhite); //--- Set the text color
   obj_Lbl_PRICE.Font("Arial black"); //--- Set the font style
   obj_Lbl_PRICE.FontSize(13); //--- Set the font size   
   
   //--- PRICE EDIT
   obj_Edit_PRICE.Create(0,Edit_PRICE,0,40+60,130,0,0); //--- Create the price edit field
   obj_Edit_PRICE.Size(90,25); //--- Set the edit field size
   obj_Edit_PRICE.ColorBackground(clrWhite); //--- Set the background color
   obj_Edit_PRICE.ColorBorder(clrBlack); //--- Set the border color
   obj_Edit_PRICE.Text(DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits)); //--- Set the default text to current ask price
   obj_Edit_PRICE.Color(clrBlack); //--- Set the text color
   obj_Edit_PRICE.Font("Times new roman bold"); //--- Set the font style
   obj_Edit_PRICE.FontSize(13); //--- Set the font size
   
   //--- LOTS LABEL
   obj_Lbl_LOTS.Create(0,Lbl_LOTS,0,40+160,130,0,0); //--- Create the lot size label
   obj_Lbl_LOTS.Text("Lot size"); //--- Set the label text
   obj_Lbl_LOTS.Color(clrWhite); //--- Set the text color
   obj_Lbl_LOTS.Font("Arial black"); //--- Set the font style
   obj_Lbl_LOTS.FontSize(13); //--- Set the font size   
   
   //--- LOTS EDIT
   obj_Edit_LOTS.Create(0,Edit_LOTS,0,40+60+180,130,0,0); //--- Create the lot size edit field
   obj_Edit_LOTS.Size(50,25); //--- Set the edit field size
   obj_Edit_LOTS.ColorBackground(clrWhite); //--- Set the background color
   obj_Edit_LOTS.ColorBorder(clrBlack); //--- Set the border color
   obj_Edit_LOTS.Text("0.01"); //--- Set the default text
   obj_Edit_LOTS.Color(clrBlack); //--- Set the text color
   obj_Edit_LOTS.Font("Times new roman bold"); //--- Set the font style
   obj_Edit_LOTS.FontSize(13); //--- Set the font size
   
   //--- SL LABEL
   obj_Lbl_SL.Create(0,Lbl_SL,0,40,160,0,0); //--- Create the stop loss label
   obj_Lbl_SL.Text("SL"); //--- Set the label text
   obj_Lbl_SL.Color(clrWhite); //--- Set the text color
   obj_Lbl_SL.Font("Arial black"); //--- Set the font style
   obj_Lbl_SL.FontSize(13); //--- Set the font size   
   
   //--- SL EDIT
   obj_Edit_SL.Create(0,Edit_SL,0,40+30,160,0,0); //--- Create the stop loss edit field
   obj_Edit_SL.Size(70,25); //--- Set the edit field size
   obj_Edit_SL.ColorBackground(clrWhite); //--- Set the background color
   obj_Edit_SL.ColorBorder(clrBlack); //--- Set the border color
   obj_Edit_SL.Text("300"); //--- Set the default text
   obj_Edit_SL.Color(clrBlack); //--- Set the text color
   obj_Edit_SL.Font("Times new roman bold"); //--- Set the font style
   obj_Edit_SL.FontSize(13); //--- Set the font size
   
   //--- TP LABEL
   obj_Lbl_TP.Create(0,Lbl_TP,0,40+190,160,0,0); //--- Create the take profit label
   obj_Lbl_TP.Text("TP"); //--- Set the label text
   obj_Lbl_TP.Color(clrWhite); //--- Set the text color
   obj_Lbl_TP.Font("Arial black"); //--- Set the font style
   obj_Lbl_TP.FontSize(13); //--- Set the font size   
   
   //--- TP EDIT
   obj_Edit_TP.Create(0,Edit_TP,0,40+30+190,160,0,0); //--- Create the take profit edit field
   obj_Edit_TP.Size(70,25); //--- Set the edit field size
   obj_Edit_TP.ColorBackground(clrWhite); //--- Set the background color
   obj_Edit_TP.ColorBorder(clrBlack); //--- Set the border color
   obj_Edit_TP.Text("750"); //--- Set the default text
   obj_Edit_TP.Color(clrBlack); //--- Set the text color
   obj_Edit_TP.Font("Times new roman bold"); //--- Set the font style
   obj_Edit_TP.FontSize(13); //--- Set the font size
    
   //--- POINTS BUTTON
   obj_Btn_POINTS.Create(0,Btn_POINTS,0,40+110,160,0,0); //--- Create the points button
   obj_Btn_POINTS.Size(70,25); //--- Set the button size
   obj_Btn_POINTS.ColorBackground(clrGoldenrod); //--- Set the background color
   obj_Btn_POINTS.ColorBorder(clrGoldenrod); //--- Set the border color
   obj_Btn_POINTS.Text("Points"); //--- Set the button text
   obj_Btn_POINTS.Color(clrBlack); //--- Set the text color
   obj_Btn_POINTS.Font("Calibri bold"); //--- Set the font style
   obj_Btn_POINTS.FontSize(14); //--- Set the font size
   
   //--- SELL BUTTON
   obj_Btn_SELL.Create(0,Btn_SELL,0,40,210,0,0); //--- Create the sell button
   obj_Btn_SELL.Size(100,25); //--- Set the button size
   obj_Btn_SELL.ColorBackground(clrOrangeRed); //--- Set the background color
   obj_Btn_SELL.ColorBorder(clrOrangeRed); //--- Set the border color
   obj_Btn_SELL.Text("Sell"); //--- Set the button text
   obj_Btn_SELL.Color(clrWhite); //--- Set the text color
   obj_Btn_SELL.Font("Calibri bold"); //--- Set the font style
   obj_Btn_SELL.FontSize(14); //--- Set the font size
   
   //--- ENTRY BUTTON
   obj_Btn_ENTRY.Create(0,Btn_ENTRY,0,150,210,0,0); //--- Create the entry button
   obj_Btn_ENTRY.Size(70,25); //--- Set the button size
   obj_Btn_ENTRY.ColorBackground(clrGoldenrod); //--- Set the background color
   obj_Btn_ENTRY.ColorBorder(clrGoldenrod); //--- Set the border color
   obj_Btn_ENTRY.Text("Entry"); //--- Set the button text
   obj_Btn_ENTRY.Color(clrBlack); //--- Set the text color
   obj_Btn_ENTRY.Font("Calibri bold"); //--- Set the font style
   obj_Btn_ENTRY.FontSize(14); //--- Set the font size
   
   //--- BUY BUTTON
   obj_Btn_BUY.Create(0,Btn_BUY,0,40+190,210,0,0); //--- Create the buy button
   obj_Btn_BUY.Size(100,25); //--- Set the button size
   obj_Btn_BUY.ColorBackground(clrLimeGreen); //--- Set the background color
   obj_Btn_BUY.ColorBorder(clrLimeGreen); //--- Set the border color
   obj_Btn_BUY.Text("Buy"); //--- Set the button text
   obj_Btn_BUY.Color(clrWhite); //--- Set the text color
   obj_Btn_BUY.Font("Calibri bold"); //--- Set the font style
   obj_Btn_BUY.FontSize(14); //--- Set the font size
   
   //--- SELL STOP BUTTON
   obj_Btn_SELLSTOP.Create(0,Btn_SELLSTOP,0,40,240,0,0); //--- Create the sell stop button
   obj_Btn_SELLSTOP.Size(140,25); //--- Set the button size
   obj_Btn_SELLSTOP.ColorBackground(clrOrangeRed); //--- Set the background color
   obj_Btn_SELLSTOP.ColorBorder(clrOrangeRed); //--- Set the border color
   obj_Btn_SELLSTOP.Text("Sell Stop"); //--- Set the button text
   obj_Btn_SELLSTOP.Color(clrWhite); //--- Set the text color
   obj_Btn_SELLSTOP.Font("Calibri bold"); //--- Set the font style
   obj_Btn_SELLSTOP.FontSize(14); //--- Set the font size
   
   //--- BUY STOP BUTTON
   obj_Btn_BUYSTOP.Create(0,Btn_BUYSTOP,0,40+190-40,240,0,0); //--- Create the buy stop button
   obj_Btn_BUYSTOP.Size(140,25); //--- Set the button size
   obj_Btn_BUYSTOP.ColorBackground(clrLimeGreen); //--- Set the background color
   obj_Btn_BUYSTOP.ColorBorder(clrLimeGreen); //--- Set the border color
   obj_Btn_BUYSTOP.Text("Buy Stop"); //--- Set the button text
   obj_Btn_BUYSTOP.Color(clrWhite); //--- Set the text color
   obj_Btn_BUYSTOP.Font("Calibri bold"); //--- Set the font style
   obj_Btn_BUYSTOP.FontSize(14); //--- Set the font size
   
   //--- SELL LIMIT BUTTON
   obj_Btn_SELLLIMIT.Create(0,Btn_SELLLIMIT,0,40,270,0,0); //--- Create the sell limit button
   obj_Btn_SELLLIMIT.Size(140,25); //--- Set the button size
   obj_Btn_SELLLIMIT.ColorBackground(clrOrangeRed); //--- Set the background color
   obj_Btn_SELLLIMIT.ColorBorder(clrOrangeRed); //--- Set the border color
   obj_Btn_SELLLIMIT.Text("Sell Limit"); //--- Set the button text
   obj_Btn_SELLLIMIT.Color(clrWhite); //--- Set the text color
   obj_Btn_SELLLIMIT.Font("Calibri bold"); //--- Set the font style
   obj_Btn_SELLLIMIT.FontSize(14); //--- Set the font size
   
   //--- BUY LIMIT BUTTON
   obj_Btn_BUYLIMIT.Create(0,Btn_BUYLIMIT,0,40+190-40,270,0,0); //--- Create the buy limit button
   obj_Btn_BUYLIMIT.Size(140,25); //--- Set the button size
   obj_Btn_BUYLIMIT.ColorBackground(clrLimeGreen); //--- Set the background color
   obj_Btn_BUYLIMIT.ColorBorder(clrLimeGreen); //--- Set the border color
   obj_Btn_BUYLIMIT.Text("Buy Limit"); //--- Set the button text
   obj_Btn_BUYLIMIT.Color(clrWhite); //--- Set the text color
   obj_Btn_BUYLIMIT.Font("Calibri bold"); //--- Set the font style
   obj_Btn_BUYLIMIT.FontSize(14); //--- Set the font size
}

//+------------------------------------------------------------------+
//|      FUNCTION TO CREATE THE CLOSE SECTION                        |
//+------------------------------------------------------------------+
void createSection_Close(){
   //--- CLOSE ALL BUTTON
   obj_Btn_CLOSE_ALL.Create(0, Btn_CLOSE_ALL, 0, 80, 120, 0, 0); //--- Create the close all button
   obj_Btn_CLOSE_ALL.Size(210, 25); //--- Set the button size
   obj_Btn_CLOSE_ALL.ColorBackground(clrPeru); //--- Set the background color
   obj_Btn_CLOSE_ALL.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_ALL.Text("Close All"); //--- Set the button text
   obj_Btn_CLOSE_ALL.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_ALL.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_ALL.FontSize(14); //--- Set the font size
   
   //--- CLOSE ALL SELL BUTTON
   obj_Btn_CLOSE_ALL_SELL.Create(0, Btn_CLOSE_ALL_SELL, 0, 40, 150, 0, 0); //--- Create the close all sell button
   obj_Btn_CLOSE_ALL_SELL.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_ALL_SELL.ColorBackground(clrSalmon); //--- Set the background color
   obj_Btn_CLOSE_ALL_SELL.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_ALL_SELL.Text("Close All Sell"); //--- Set the button text
   obj_Btn_CLOSE_ALL_SELL.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_ALL_SELL.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_ALL_SELL.FontSize(14); //--- Set the font size
   
   //--- CLOSE ALL BUY BUTTON
   obj_Btn_CLOSE_ALL_BUY.Create(0, Btn_CLOSE_ALL_BUY, 0, 190, 150, 0, 0); //--- Create the close all buy button
   obj_Btn_CLOSE_ALL_BUY.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_ALL_BUY.ColorBackground(clrMediumSeaGreen); //--- Set the background color
   obj_Btn_CLOSE_ALL_BUY.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_ALL_BUY.Text("Close All Buy"); //--- Set the button text
   obj_Btn_CLOSE_ALL_BUY.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_ALL_BUY.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_ALL_BUY.FontSize(14); //--- Set the font size
   
   //--- CLOSE LOSS SELL BUTTON
   obj_Btn_CLOSE_LOSS_SELL.Create(0, Btn_CLOSE_LOSS_SELL, 0, 40, 180, 0, 0); //--- Create the close loss sell button
   obj_Btn_CLOSE_LOSS_SELL.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_LOSS_SELL.ColorBackground(clrSalmon); //--- Set the background color
   obj_Btn_CLOSE_LOSS_SELL.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_LOSS_SELL.Text("Close Loss Sell"); //--- Set the button text
   obj_Btn_CLOSE_LOSS_SELL.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_LOSS_SELL.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_LOSS_SELL.FontSize(14); //--- Set the font size
   
   //--- CLOSE LOSS BUY BUTTON
   obj_Btn_CLOSE_LOSS_BUY.Create(0, Btn_CLOSE_LOSS_BUY, 0, 190, 180, 0, 0); //--- Create the close loss buy button
   obj_Btn_CLOSE_LOSS_BUY.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_LOSS_BUY.ColorBackground(clrMediumSeaGreen); //--- Set the background color
   obj_Btn_CLOSE_LOSS_BUY.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_LOSS_BUY.Text("Close Loss Buy"); //--- Set the button text
   obj_Btn_CLOSE_LOSS_BUY.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_LOSS_BUY.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_LOSS_BUY.FontSize(14); //--- Set the font size
   
   //--- CLOSE PROFIT SELL BUTTON
   obj_Btn_CLOSE_PROFIT_SELL.Create(0, Btn_CLOSE_PROFIT_SELL, 0, 40, 210, 0, 0); //--- Create the close profit sell button
   obj_Btn_CLOSE_PROFIT_SELL.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_PROFIT_SELL.ColorBackground(clrSalmon); //--- Set the background color
   obj_Btn_CLOSE_PROFIT_SELL.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_PROFIT_SELL.Text("Close Profit Sell"); //--- Set the button text
   obj_Btn_CLOSE_PROFIT_SELL.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_PROFIT_SELL.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_PROFIT_SELL.FontSize(14); //--- Set the font size
   
   //--- CLOSE PROFIT BUY BUTTON
   obj_Btn_CLOSE_PROFIT_BUY.Create(0, Btn_CLOSE_PROFIT_BUY, 0, 190, 210, 0, 0); //--- Create the close profit buy button
   obj_Btn_CLOSE_PROFIT_BUY.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_PROFIT_BUY.ColorBackground(clrMediumSeaGreen); //--- Set the background color
   obj_Btn_CLOSE_PROFIT_BUY.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_PROFIT_BUY.Text("Close Profit Buy"); //--- Set the button text
   obj_Btn_CLOSE_PROFIT_BUY.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_PROFIT_BUY.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_PROFIT_BUY.FontSize(14); //--- Set the font size
   
   //--- CLOSE ALL LOSS BUTTON
   obj_Btn_CLOSE_ALL_LOSS.Create(0, Btn_CLOSE_ALL_LOSS, 0, 40, 240, 0, 0); //--- Create the close all loss button
   obj_Btn_CLOSE_ALL_LOSS.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_ALL_LOSS.ColorBackground(clrSalmon); //--- Set the background color
   obj_Btn_CLOSE_ALL_LOSS.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_ALL_LOSS.Text("CLOSE LOSS"); //--- Set the button text
   obj_Btn_CLOSE_ALL_LOSS.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_ALL_LOSS.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_ALL_LOSS.FontSize(14); //--- Set the font size
   
   //--- CLOSE ALL PROFIT BUTTON
   obj_Btn_CLOSE_ALL_PROFIT.Create(0, Btn_CLOSE_ALL_PROFIT, 0, 190, 240, 0, 0); //--- Create the close all profit button
   obj_Btn_CLOSE_ALL_PROFIT.Size(140, 25); //--- Set the button size
   obj_Btn_CLOSE_ALL_PROFIT.ColorBackground(clrMediumSeaGreen); //--- Set the background color
   obj_Btn_CLOSE_ALL_PROFIT.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_ALL_PROFIT.Text("CLOSE PROFIT"); //--- Set the button text
   obj_Btn_CLOSE_ALL_PROFIT.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_ALL_PROFIT.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_ALL_PROFIT.FontSize(14); //--- Set the font size
   
   //--- CLOSE ALL PENDING BUTTON
   obj_Btn_CLOSE_PENDING.Create(0, Btn_CLOSE_PENDING, 0, 80, 270, 0, 0); //--- Create the close all pending button
   obj_Btn_CLOSE_PENDING.Size(210, 25); //--- Set the button size
   obj_Btn_CLOSE_PENDING.ColorBackground(clrPeru); //--- Set the background color
   obj_Btn_CLOSE_PENDING.ColorBorder(clrWhite); //--- Set the border color
   obj_Btn_CLOSE_PENDING.Text("Close All Pending"); //--- Set the button text
   obj_Btn_CLOSE_PENDING.Color(clrBlack); //--- Set the text color
   obj_Btn_CLOSE_PENDING.Font("Calibri bold"); //--- Set the font style
   obj_Btn_CLOSE_PENDING.FontSize(14); //--- Set the font size
}

//+------------------------------------------------------------------+
//|        FUNCTION TO CREATE THE INFO SECTION                       |
//+------------------------------------------------------------------+
void createSection_Information() {
   //--- Create Account Number Label
   obj_Lbl_ACC_NUMBER.Create(0, Lbl_ACC_NUMBER, 0, 40, 100, 0, 0); //--- Initialize label for Account Number
   obj_Lbl_ACC_NUMBER.Text("Account Number"); //--- Set label text to "Account Number"
   obj_Lbl_ACC_NUMBER.Color(clrWhite); //--- Set label color to white
   obj_Lbl_ACC_NUMBER.Font("Calibri bold"); //--- Set label font to Calibri bold
   obj_Lbl_ACC_NUMBER.FontSize(14); //--- Set label font size to 14

   //--- Create Account Number Button
   obj_Btn_ACC_NUMBER.Create(0, Btn_ACC_NUMBER, 0, 40 + 140, 100 + 2, 0, 0); //--- Initialize button for Account Number
   obj_Btn_ACC_NUMBER.Size(150, 20); //--- Set button size to 150x20
   obj_Btn_ACC_NUMBER.ColorBackground(clrGainsboro); //--- Set button background color to Gainsboro
   obj_Btn_ACC_NUMBER.ColorBorder(clrWhite); //--- Set button border color to white
   obj_Btn_ACC_NUMBER.Text(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))); //--- Set button text with account number
   obj_Btn_ACC_NUMBER.Color(clrBlack); //--- Set button text color to black
   obj_Btn_ACC_NUMBER.Font("Calibri bold"); //--- Set button font to Calibri bold
   obj_Btn_ACC_NUMBER.FontSize(13); //--- Set button font size to 13

   //--- Create Account Name Label
   obj_Lbl_ACC_NAME.Create(0, Lbl_ACC_NAME, 0, 40, 125, 0, 0); //--- Initialize label for Account Name
   obj_Lbl_ACC_NAME.Text("Account Name"); //--- Set label text to "Account Name"
   obj_Lbl_ACC_NAME.Color(clrWhite); //--- Set label color to white
   obj_Lbl_ACC_NAME.Font("Calibri bold"); //--- Set label font to Calibri bold
   obj_Lbl_ACC_NAME.FontSize(14); //--- Set label font size to 14

   //--- Create Account Name Button
   obj_Btn_ACC_NAME.Create(0, Btn_ACC_NAME, 0, 40 + 120, 125 + 2, 0, 0); //--- Initialize button for Account Name
   obj_Btn_ACC_NAME.Size(170, 20); //--- Set button size to 170x20
   obj_Btn_ACC_NAME.ColorBackground(clrGainsboro); //--- Set button background color to Gainsboro
   obj_Btn_ACC_NAME.ColorBorder(clrWhite); //--- Set button border color to white
   obj_Btn_ACC_NAME.Text(AccountInfoString(ACCOUNT_SERVER)); //--- Set button text with account server name
   obj_Btn_ACC_NAME.Color(clrBlack); //--- Set button text color to black
   obj_Btn_ACC_NAME.Font("Calibri bold"); //--- Set button font to Calibri bold
   obj_Btn_ACC_NAME.FontSize(13); //--- Set button font size to 13

   //--- Create Account Type Label
   obj_Lbl_ACC_TYPE.Create(0, Lbl_ACC_TYPE, 0, 40, 150, 0, 0); //--- Initialize label for Account Type
   obj_Lbl_ACC_TYPE.Text("Account Type"); //--- Set label text to "Account Type"
   obj_Lbl_ACC_TYPE.Color(clrWhite); //--- Set label color to white
   obj_Lbl_ACC_TYPE.Font("Calibri bold"); //--- Set label font to Calibri bold
   obj_Lbl_ACC_TYPE.FontSize(14); //--- Set label font size to 14

   //--- Create Account Type Button
   obj_Btn_ACC_TYPE.Create(0, Btn_ACC_TYPE, 0, 40 + 110, 150 + 2, 0, 0); //--- Initialize button for Account Type
   obj_Btn_ACC_TYPE.Size(180, 20); //--- Set button size to 180x20
   obj_Btn_ACC_TYPE.ColorBackground(clrGainsboro); //--- Set button background color to Gainsboro
   obj_Btn_ACC_TYPE.ColorBorder(clrWhite); //--- Set button border color to white
   ENUM_ACCOUNT_TRADE_MODE account_type = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE); //--- Retrieve account type
   string trade_mode; //--- Initialize variable for trade mode description
   switch (account_type) { //--- Determine account type
      case ACCOUNT_TRADE_MODE_DEMO: trade_mode = "Demo Account"; break; //--- Set trade_mode for Demo account
      case ACCOUNT_TRADE_MODE_CONTEST: trade_mode = "Contest Account"; break; //--- Set trade_mode for Contest account
      default: trade_mode = "Real Account"; break; //--- Set trade_mode for Real account
   }
   obj_Btn_ACC_TYPE.Text(trade_mode); //--- Set button text to account type description
   obj_Btn_ACC_TYPE.Color(clrBlack); //--- Set button text color to black
   obj_Btn_ACC_TYPE.Font("Calibri bold"); //--- Set button font to Calibri bold
   obj_Btn_ACC_TYPE.FontSize(13); //--- Set button font size to 13

   //--- Create Account Leverage Label
   obj_Lbl_ACC_LEVERAGE.Create(0, Lbl_ACC_LEVERAGE, 0, 40, 175, 0, 0); //--- Initialize label for Account Leverage
   obj_Lbl_ACC_LEVERAGE.Text("Account Leverage"); //--- Set label text to "Account Leverage"
   obj_Lbl_ACC_LEVERAGE.Color(clrWhite); //--- Set label color to white
   obj_Lbl_ACC_LEVERAGE.Font("Calibri bold"); //--- Set label font to Calibri bold
   obj_Lbl_ACC_LEVERAGE.FontSize(14); //--- Set label font size to 14

   //--- Create Account Leverage Button
   obj_Btn_ACC_LEVERAGE.Create(0, Btn_ACC_LEVERAGE, 0, 40 + 150, 175 + 2, 0, 0); //--- Initialize button for Account Leverage
   obj_Btn_ACC_LEVERAGE.Size(140, 20); //--- Set button size to 140x20
   obj_Btn_ACC_LEVERAGE.ColorBackground(clrGainsboro); //--- Set button background color to Gainsboro
   obj_Btn_ACC_LEVERAGE.ColorBorder(clrWhite); //--- Set button border color to white
   obj_Btn_ACC_LEVERAGE.Text(IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE))); //--- Set button text with account leverage
   obj_Btn_ACC_LEVERAGE.Color(clrBlack); //--- Set button text color to black
   obj_Btn_ACC_LEVERAGE.Font("Calibri bold"); //--- Set button font to Calibri bold
   obj_Btn_ACC_LEVERAGE.FontSize(13); //--- Set button font size to 13

   //--- Create Account Equity Label
   obj_Lbl_ACC_EQUITY.Create(0, Lbl_ACC_EQUITY, 0, 40, 220, 0, 0); //--- Initialize label for Account Equity
   obj_Lbl_ACC_EQUITY.Text("Account Equity"); //--- Set label text to "Account Equity"
   obj_Lbl_ACC_EQUITY.Color(clrAqua); //--- Set label color to Aqua
   obj_Lbl_ACC_EQUITY.Font("Cooper Black"); //--- Set label font to Cooper Black
   obj_Lbl_ACC_EQUITY.FontSize(14); //--- Set label font size to 14

   //--- Create Account Equity Button
   obj_Btn_ACC_EQUITY.Create(0, Btn_ACC_EQUITY, 0, 40 + 170, 220 + 2, 0, 0); //--- Initialize button for Account Equity
   obj_Btn_ACC_EQUITY.Size(120, 20); //--- Set button size to 120x20
   obj_Btn_ACC_EQUITY.ColorBackground(clrBlack); //--- Set button background color to black
   obj_Btn_ACC_EQUITY.ColorBorder(clrBlanchedAlmond); //--- Set button border color to Blanched Almond
   obj_Btn_ACC_EQUITY.Text(DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2)); //--- Set button text with account equity
   obj_Btn_ACC_EQUITY.Color(clrWhite); //--- Set button text color to white
   obj_Btn_ACC_EQUITY.Font("Times new roman bold"); //--- Set button font to Times New Roman bold
   obj_Btn_ACC_EQUITY.FontSize(13); //--- Set button font size to 13

   //--- Create Account Balance Label
   obj_Lbl_ACC_BALANCE.Create(0, Lbl_ACC_BALANCE, 0, 40, 245, 0, 0); //--- Initialize label for Account Balance
   obj_Lbl_ACC_BALANCE.Text("Account Balance"); //--- Set label text to "Account Balance"
   obj_Lbl_ACC_BALANCE.Color(clrAqua); //--- Set label color to Aqua
   obj_Lbl_ACC_BALANCE.Font("Cooper Black"); //--- Set label font to Cooper Black
   obj_Lbl_ACC_BALANCE.FontSize(14); //--- Set label font size to 14

   //--- Create Account Balance Button
   obj_Btn_ACC_BALANCE.Create(0, Btn_ACC_BALANCE, 0, 40 + 170, 245 + 2, 0, 0); //--- Initialize button for Account Balance
   obj_Btn_ACC_BALANCE.Size(120, 20); //--- Set button size to 120x20
   obj_Btn_ACC_BALANCE.ColorBackground(clrBlack); //--- Set button background color to black
   obj_Btn_ACC_BALANCE.ColorBorder(clrBlanchedAlmond); //--- Set button border color to Blanched Almond
   obj_Btn_ACC_BALANCE.Text(DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2)); //--- Set button text with account balance
   obj_Btn_ACC_BALANCE.Color(clrWhite); //--- Set button text color to white
   obj_Btn_ACC_BALANCE.Font("Times new roman bold"); //--- Set button font to Times New Roman bold
   obj_Btn_ACC_BALANCE.FontSize(13); //--- Set button font size to 13

   //--- Create Server Time Label
   obj_Lbl_TIME.Create(0, Lbl_TIME, 0, 40, 270, 0, 0); //--- Initialize label for Server Time
   obj_Lbl_TIME.Text("Server Time"); //--- Set label text to "Server Time"
   obj_Lbl_TIME.Color(clrLime); //--- Set label color to Lime
   obj_Lbl_TIME.Font("Cooper Black"); //--- Set label font to Cooper Black
   obj_Lbl_TIME.FontSize(14); //--- Set label font size to 14

   //--- Create Server Time Button
   obj_Btn_TIME.Create(0, Btn_TIME, 0, 40 + 120, 270 + 2, 0, 0); //--- Initialize button for Server Time
   obj_Btn_TIME.Size(170, 20); //--- Set button size to 170x20
   obj_Btn_TIME.ColorBackground(clrBlack); //--- Set button background color to black
   obj_Btn_TIME.ColorBorder(clrBlanchedAlmond); //--- Set button border color to Blanched Almond
   obj_Btn_TIME.Text(TimeToString(TimeTradeServer(), TIME_DATE | TIME_SECONDS)); //--- Set button text with server time
   obj_Btn_TIME.Color(clrWhite); //--- Set button text color to white
   obj_Btn_TIME.Font("Times new roman bold"); //--- Set button font to Times New Roman bold
   obj_Btn_TIME.FontSize(13); //--- Set button font size to 13
}

//--- Function to destroy main panel objects
void destroySection_Main_Panel() {
   obj_Btn_MAIN.Destroy(); //--- Destroy the main button
   obj_Btn_HEADER.Destroy(); //--- Destroy the header button
   obj_Btn_X.Destroy(); //--- Destroy the close (X) button
   obj_Lbl_HEADER.Destroy(); //--- Destroy the header label
   obj_Btn_TRADE.Destroy(); //--- Destroy the trade section button
   obj_Btn_CLOSE.Destroy(); //--- Destroy the close section button
   obj_Btn_INFO.Destroy(); //--- Destroy the information section button
   obj_Btn_FOOTER.Destroy(); //--- Destroy the footer button
}

//--- Function to destroy trade section objects
void destroySection_Trade() {
   obj_Btn_RISK.Destroy(); //--- Destroy the risk button
   obj_Edit_RISK.Destroy(); //--- Destroy the risk input field
   obj_Lbl_PRICE.Destroy(); //--- Destroy the price label
   obj_Edit_PRICE.Destroy(); //--- Destroy the price input field
   obj_Lbl_LOTS.Destroy(); //--- Destroy the lot size label
   obj_Edit_LOTS.Destroy(); //--- Destroy the lot size input field
   obj_Lbl_SL.Destroy(); //--- Destroy the stop loss label
   obj_Edit_SL.Destroy(); //--- Destroy the stop loss input field
   obj_Lbl_TP.Destroy(); //--- Destroy the take profit label
   obj_Edit_TP.Destroy(); //--- Destroy the take profit input field
   obj_Btn_POINTS.Destroy(); //--- Destroy the points button
   obj_Btn_SELL.Destroy(); //--- Destroy the sell button
   obj_Btn_ENTRY.Destroy(); //--- Destroy the entry button
   obj_Btn_BUY.Destroy(); //--- Destroy the buy button
   obj_Btn_SELLSTOP.Destroy(); //--- Destroy the sell stop button
   obj_Btn_BUYSTOP.Destroy(); //--- Destroy the buy stop button
   obj_Btn_SELLLIMIT.Destroy(); //--- Destroy the sell limit button
   obj_Btn_BUYLIMIT.Destroy(); //--- Destroy the buy limit button
}

//--- Function to destroy close section objects
void destroySection_Close() {
   obj_Btn_CLOSE_ALL.Destroy(); //--- Destroy the button to close all positions
   obj_Btn_CLOSE_ALL_SELL.Destroy(); //--- Destroy the button to close all sell positions
   obj_Btn_CLOSE_ALL_BUY.Destroy(); //--- Destroy the button to close all buy positions
   obj_Btn_CLOSE_LOSS_SELL.Destroy(); //--- Destroy the button to close losing sell positions
   obj_Btn_CLOSE_LOSS_BUY.Destroy(); //--- Destroy the button to close losing buy positions
   obj_Btn_CLOSE_PROFIT_SELL.Destroy(); //--- Destroy the button to close profitable sell positions
   obj_Btn_CLOSE_PROFIT_BUY.Destroy(); //--- Destroy the button to close profitable buy positions
   obj_Btn_CLOSE_ALL_LOSS.Destroy(); //--- Destroy the button to close all losing positions
   obj_Btn_CLOSE_ALL_PROFIT.Destroy(); //--- Destroy the button to close all profitable positions
   obj_Btn_CLOSE_PENDING.Destroy(); //--- Destroy the button to close pending orders
}

//--- Function to destroy information section objects
void destroySection_Information() {
   obj_Lbl_ACC_NUMBER.Destroy(); //--- Destroy the account number label
   obj_Btn_ACC_NUMBER.Destroy(); //--- Destroy the account number button
   obj_Lbl_ACC_NAME.Destroy(); //--- Destroy the account name label
   obj_Btn_ACC_NAME.Destroy(); //--- Destroy the account name button
   obj_Lbl_ACC_TYPE.Destroy(); //--- Destroy the account type label
   obj_Btn_ACC_TYPE.Destroy(); //--- Destroy the account type button
   obj_Lbl_ACC_LEVERAGE.Destroy(); //--- Destroy the account leverage label
   obj_Btn_ACC_LEVERAGE.Destroy(); //--- Destroy the account leverage button
   obj_Lbl_ACC_EQUITY.Destroy(); //--- Destroy the account equity label
   obj_Btn_ACC_EQUITY.Destroy(); //--- Destroy the account equity button
   obj_Lbl_ACC_BALANCE.Destroy(); //--- Destroy the account balance label
   obj_Btn_ACC_BALANCE.Destroy(); //--- Destroy the account balance button
   obj_Lbl_TIME.Destroy(); //--- Destroy the server time label
   obj_Btn_TIME.Destroy(); //--- Destroy the server time button
}
