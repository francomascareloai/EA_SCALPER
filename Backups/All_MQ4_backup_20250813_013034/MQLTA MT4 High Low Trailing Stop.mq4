#property link          "https://www.earnforex.com/metatrader-expert-advisors/high-low-trailing-stop/"
#property version       "1.01"
#property strict
#property copyright     "EarnForex.com - 2019-2021"
#property description   "This Expert Advisor will Trail the Stop Loss Price" 
#property description   "setting it to a recent High Or Low."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for any damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#include <MQLTA ErrorHandling.mqh>
#include <MQLTA Utils.mqh>


enum ENUM_CONSIDER{
   All=-1,        //ALL ORDERS
   Buy=OP_BUY,    //BUY ONLY
   Sell=OP_SELL,  //SELL ONLY
};

enum ENUM_CUSTOMTIMEFRAMES{
   CURRENT=PERIOD_CURRENT,             //CURRENT PERIOD
   M1=PERIOD_M1,                       //M1
   M5=PERIOD_M5,                       //M5
   M15=PERIOD_M15,                     //M15
   M30=PERIOD_M30,                     //M30
   H1=PERIOD_H1,                       //H1
   H4=PERIOD_H4,                       //H4
   D1=PERIOD_D1,                       //D1
   W1=PERIOD_W1,                       //W1
   MN1=PERIOD_MN1,                     //MN1
};


input string Comment_1="====================";     //Expert Advisor Settings
input int BarsToScan=5;                                //Bars To Scan (5=Last Five Candles)
input string Comment_2="====================";           //Orders Filtering Options
bool OnlyCurrentSymbol=true;                       //Apply To Current Symbol Only
input ENUM_CONSIDER OnlyType=All;                        //Apply To
input bool UseMagic=false;                               //Filter By Magic Number
input int MagicNumber=0;                                 //Magic Number (if above is true)
input bool UseComment=false;                             //Filter By Comment
input string CommentFilter="";                           //Comment (if above is true)
input bool EnableTrailingParam=false;                    //Enable Trailing Stop
input string Comment_3="====================";     //Notification Options
input bool EnableNotify=false;                    //Enable Notifications feature
input bool SendAlert=true;                        //Send Alert Notification
input bool SendApp=true;                          //Send Notification to Mobile
input bool SendEmail=true;                        //Send Notification via Email
input string Comment_3a="====================";           //Graphical Window
input bool ShowPanel=true;                              //Show Graphical Panel
input string IndicatorName="MQLTA-HLTS";          //Indicator Name (to name the objects)
input int Xoff=20;                                //Horizontal spacing for the control panel
input int Yoff=20;                                //Vertical spacing for the control panel

int OrderOpRetry=5;
int SuperTrendShift=0;

double TrendUpTmp[], TrendDownTmp[];
int changeOfTrend;
int MaxBars=BarsToScan+1;
bool EnableTrailing=EnableTrailingParam;


int OnInit(){
   CleanPanel();
   
   EnableTrailing=EnableTrailingParam;
   if(ShowPanel) DrawPanel();
   return(INIT_SUCCEEDED);
   
   
}

void OnDeinit(const int reason){
   CleanPanel();
   
}

void OnTick(){
   if(EnableTrailing) TrailingStop();
   if(ShowPanel) DrawPanel();
   
}


void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){

   if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam==PanelEnableDisable){
         ChangeTrailingEnabled();
      }
   }
   if(id==CHARTEVENT_KEYDOWN){
      if(lparam==27){
         if(MessageBox("Are you sure you want to close the EA?","EXIT ?",MB_YESNO)==IDYES){
            ExpertRemove();
         }
      }
   }
   
}

//Print information about author and code


double GetStopLossBuy(){
   double SLValue=iLow(Symbol(),PERIOD_CURRENT,iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,BarsToScan,0));
   return SLValue;
}


double GetStopLossSell(){
   double SLValue=iHigh(Symbol(),PERIOD_CURRENT,iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,BarsToScan,0));
   return SLValue;
}

void TrailingStop(){
   for(int i=0;i<OrdersTotal();i++) {
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error);
         Print("ERROR - ",ErrorText);
         break;
      }
      if(OnlyCurrentSymbol && OrderSymbol()!=Symbol()) continue;
      if(UseMagic && OrderMagicNumber()!=MagicNumber) continue;
      if(UseComment && StringFind(OrderComment(),CommentFilter)<0) continue;
      if(OnlyType!=All &&OrderType()!=OnlyType) continue;
      
      double NewSL=0;
      double NewTP=0;
      string Instrument=OrderSymbol();
      double SLBuy=GetStopLossBuy();
      double SLSell=GetStopLossSell();
      if(SLBuy==0 || SLSell==0){
         Print("Not enough historical data, please load more candles for The selected timeframe");
         return;
      }
      //Print(OrderSymbol()," ",OrderMagicNumber()," ",ATRTrend);
      int eDigits = (int)MarketInfo(Instrument,MODE_DIGITS);
      double SLPrice=NormalizeDouble(OrderStopLoss(),eDigits);
      double TPPrice=NormalizeDouble(OrderTakeProfit(),eDigits);
      double Spread=MarketInfo(Instrument,MODE_SPREAD)*MarketInfo(Instrument,MODE_POINT);
      double StopLevel=MarketInfo(Instrument,MODE_STOPLEVEL)*MarketInfo(Instrument,MODE_POINT);
      //Print(StopLevel);
      //Print(Instrument," ",ATRTrend," ",StopLevel);
      if(OrderType()==OP_BUY && SLBuy<MarketInfo(Instrument,MODE_BID)-StopLevel){
         NewSL=NormalizeDouble(SLBuy,eDigits);
         NewTP=TPPrice;
         //Print(OrderSymbol()," ",OrderType()," Old SL=",SLPrice," New SL=",NewSL," Old TP=",TPPrice," New TP=",NewTP," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
         if(NewSL>SLPrice+StopLevel || SLPrice==0){
            ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSL,NewTP);
         }
      }
      if(OrderType()==OP_SELL && SLSell>MarketInfo(Instrument,MODE_ASK)+StopLevel+Spread){
         NewSL=NormalizeDouble(SLSell+Spread,eDigits);
         NewTP=TPPrice;
         //Print(OrderSymbol()," ",OrderType()," Old SL=",SLPrice," New SL=",NewSL," Old TP=",TPPrice," New TP=",NewTP," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
         if(NewSL<SLPrice-StopLevel || SLPrice==0){
            ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSL,NewTP);
         }
      }
   }
}


void ModifyOrder(int Ticket, double OpenPrice, double SLPrice, double TPPrice){
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false){
      int Error=GetLastError();
      string ErrorText=GetLastErrorText(Error);
      Print("ERROR - SELECT TICKET - error selecting order ",Ticket," return error: ",Error);
      return;
   }
   int eDigits = (int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   SLPrice=NormalizeDouble(SLPrice,eDigits);
   TPPrice=NormalizeDouble(TPPrice,eDigits);
   for(int i=1; i<=OrderOpRetry; i++){
      bool res=OrderModify(Ticket,OpenPrice,SLPrice,TPPrice,0,Blue);
      if(res){
         Print("TRADE - UPDATE SUCCESS - Order ",Ticket," new stop loss ",SLPrice," new take profit ",TPPrice);
         NotifyStopLossUpdate(Ticket,SLPrice);
         break;
      }
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - UPDATE FAILED - error modifying order ",Ticket," return error: ",Error," Open=",OpenPrice,
               " Old SL=",OrderStopLoss()," Old TP=",OrderTakeProfit(),
               " New SL=",SLPrice," New TP=",TPPrice," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
         Print("ERROR - ",ErrorText);
      } 
   }
   return;
}


void NotifyStopLossUpdate(int OrderNumber, double SLPrice){
   if(!EnableNotify) return;
   if(!SendAlert && !SendApp && !SendEmail) return;
   string EmailSubject=IndicatorName+" "+Symbol()+" Notification ";
   string EmailBody="\r\n"+AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+"\r\n\r\n"+IndicatorName+" Notification for "+Symbol()+"\r\n\r\n";
   EmailBody+="The Stop Loss for order " + IntegerToString(OrderNumber) + " was moved to "+DoubleToString(SLPrice,Digits)+"\r\n\r\n";
   string AlertText=IndicatorName+" - "+Symbol()+" Notification\r\n";
   AlertText+="The Stop Loss for order " + IntegerToString(OrderNumber) + " was moved to "+DoubleToString(SLPrice,Digits)+"";
   string AppText=AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+" - "+IndicatorName+" - "+Symbol()+" - ";
   AppText+="The Stop Loss for order " + IntegerToString(OrderNumber) + " was moved to "+DoubleToString(SLPrice,Digits)+"";
   if(SendAlert) Alert(AlertText);
   if(SendEmail){
      if(!SendMail(EmailSubject,EmailBody)) Print("Error sending email "+IntegerToString(GetLastError()));
   }
   if(SendApp){
      if(!SendNotification(AppText)) Print("Error sending notification "+IntegerToString(GetLastError()));
   }
   datetime LastNotification=TimeCurrent();
   Print(IndicatorName+"-"+Symbol()+" last notification sent "+TimeToString(LastNotification));
}


string PanelBase=IndicatorName+"-P-BAS";
string PanelLabel=IndicatorName+"-P-LAB";
string PanelEnableDisable=IndicatorName+"-P-ENADIS";

int PanelMovX=50;
int PanelMovY=20;
int PanelLabX=150;
int PanelLabY=PanelMovY;
int PanelRecX=PanelLabX+4;

void DrawPanel(){
   string PanelText="MQLTA HLTS";
   string PanelToolTip="High Low Trailing Stop Loss By MQLTA";
   CleanPanel();
   int Rows=1;
   ObjectCreate(0,PanelBase,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet(PanelBase,OBJPROP_XDISTANCE,Xoff);
   ObjectSet(PanelBase,OBJPROP_YDISTANCE,Yoff);
   ObjectSetInteger(0,PanelBase,OBJPROP_XSIZE,PanelRecX);
   ObjectSetInteger(0,PanelBase,OBJPROP_YSIZE,(PanelMovY+2)*1+2);
   ObjectSetInteger(0,PanelBase,OBJPROP_BGCOLOR,White);
   ObjectSetInteger(0,PanelBase,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,PanelBase,OBJPROP_STATE,false);
   ObjectSetInteger(0,PanelBase,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,PanelBase,OBJPROP_FONTSIZE,8);
   ObjectSet(PanelBase,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,PanelBase,OBJPROP_COLOR,clrBlack);
      
   DrawEdit(PanelLabel,
            Xoff+2,
            Yoff+2,
            PanelLabX,
            PanelLabY,
            true,
            10,
            PanelToolTip,
            ALIGN_CENTER,
            "Consolas",
            PanelText,
            false,
            clrNavy,
            clrKhaki,
            clrBlack);
   
   string EnableDisabledText="";
   color EnableDisabledColor=clrNavy;
   color EnableDisabledBack=clrKhaki;
   if(EnableTrailing){
      EnableDisabledText="TRAILING ENABLED";
      EnableDisabledColor=clrWhite;
      EnableDisabledBack=clrDarkGreen;
   }
   else{
      EnableDisabledText="TRAILING DISABLED";
      EnableDisabledColor=clrWhite;
      EnableDisabledBack=clrDarkRed;
   }
   
   DrawEdit(PanelEnableDisable,
            Xoff+2,
            Yoff+(PanelMovY+1)*Rows+2,
            PanelLabX,
            PanelLabY,
            true,
            8,
            "Click to Enable or Disable the Trailing Stop Feature",
            ALIGN_CENTER,
            "Consolas",
            EnableDisabledText,
            false,
            EnableDisabledColor,
            EnableDisabledBack,
            clrBlack);

   Rows++;

   
   ObjectSetInteger(0,PanelBase,OBJPROP_XSIZE,PanelRecX);
   ObjectSetInteger(0,PanelBase,OBJPROP_YSIZE,(PanelMovY+1)*Rows+3);
}


void CleanPanel(){
ObjectsDeleteAll(0, IndicatorName + "-P-");
}


void ChangeTrailingEnabled(){
   if(EnableTrailing==false){
      if(IsTradeAllowed()) EnableTrailing=true;
      else{
         MessageBox("You need to first enable Live Trading in your Metatrader options","WARNING",MB_OK);
      }
   }
   else EnableTrailing=false;
   DrawPanel();
}