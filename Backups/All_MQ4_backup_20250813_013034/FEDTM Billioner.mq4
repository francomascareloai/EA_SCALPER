//+-----------------------------------------------------------------------------+
//|                                                   PA_Multi_IND_TF_EA V1.mq4 |
//|                                     Copyright 2019, forex.eamaster@gmail.com|
//|                                                            MqlSoftwares.com |
//|-----------------------------------------------------------------------------|    
//+-----------------------------------------------------------------------------+

#property copyright "Copyright 2019, forex.eamaster@gmail.com"
#property link      "MqlSoftwares.com"
#property version   "1.0"
#property strict
#include  <stdlib.mqh>


bool        BackTestAllowed  = TRUE;                                 //IF TRUE BACKTEST ALLOWED AND IF FALSE BACKTEST NO ALLOWED
bool        UseAccountNumber = TRUE;
int         ValidAccountNumber = 2601750;                            // TYPE HERE THE VALID ACCOUNT NUMBER WHICH U WANT RUN THIS PROGRAMME(IT WILL RUN ONLY ON THAT ACCOUNT)               
int         ExpiryDate = D'25.07.2020 00:00';                         // GIVE HERE PROGRAMME EXPIRY DATE (FORMAT DD.MM.YYYY HH:MM)













































extern bool    REVERSE_TRADING   = FALSE;
extern double  LOT_SIZE          = 0.1,
               TAKE_PROFIT       = 50,
               STOP_LOSS         = 50;

bool           USE_FIRSTORDER    = FALSE,
               CLOSE_ON_REVERS   = TRUE;
               
extern bool    USE_TRAILING      = TRUE;
extern int     TRAILING_PIPS     = 35,
               TRAILING_STEP     = 5,
               TP_TRAILING_PIPS  = 35;
               
extern string  EA_COMMENT        = "FEDTM Billioner";               
               


bool           TradeAllowed, TradeTime, FirstOrder, FirstEntry, SL_UPDATED,
               USE_M1=TRUE, USE_M5=TRUE, USE_M15=TRUE, USE_M30=TRUE, USE_H1=TRUE, USE_H4=TRUE, USE_D1=TRUE, USE_W1=TRUE;

double         Poin, DAILY_ACHIEVED_PROFIT, MyOrderProfit,
               BUY_PRICE, SEL_PRICE;

int            trade, ticket, MagicNumber = 123, OrderSlipage = 3, intResult, OrderBar,
               BUY_OPENS,SEL_OPENS, BUYSTOP_OPENS, SELSTOP_OPENS, PREV_PERIOD;               

string         strComment, strPrevOrder, ChartComment;               

string         LblName = "forex.eamster_", M1_Trend, M5_Trend, M15_Trend, M30_Trend, H1_Trend, H4_Trend, D1_Trend, W1_Trend;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   strComment = EA_COMMENT;   //WindowExpertName();
   Poin = Point; 
   if ((Point == 0.00001) || (Point == 0.001)){Poin*= 10;}    
   if(USE_FIRSTORDER)FirstOrder=False;   
   
   ObjectDelete("forex.eamster_L_1");
   ObjectDelete("forex.eamster_L_2");
   ObjectDelete("forex.eamster_L_3");
   ObjectDelete("forex.eamster_L_4");
   ObjectDelete("forex.eamster_L_5");
   ObjectDelete("forex.eamster_L_6");
   /*PlaySound("Conditions.wav");
   int l_mb_code_0 = MessageBox("Do you expressly understand and agree that forex.eamaster shall not be liable for any direct loss or profits."+ 
                                "\nforex.eamaster makes no guarantee past performance will be indicative or future results." +
                                "\n\nBy clicking YES you agree to these conditions. Start EXPERT ADVISOR ?", "RISK DISCLAIMER", MB_YESNO|MB_ICONEXCLAMATION);
   if (l_mb_code_0 == IDNO) {ExpertRemove();return (0);}*/
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectDelete("forex.eamster_L_1");
   ObjectDelete("forex.eamster_L_2");
   ObjectDelete("forex.eamster_L_3");
   ObjectDelete("forex.eamster_L_4");
   ObjectDelete("forex.eamster_L_5");
   ObjectDelete("forex.eamster_L_6");         
  }
  
//+--------------------------------------------------------------------------------------------------------+
//|   EXTERNAL FUNCTIONS
//+--------------------------------------------------------------------------------------------------------+
void PlaceBuy(double NewLot)
{
   int Tries=0;
   if(AccountFreeMargin()<=0)return;
   if(USE_FIRSTORDER) 
   {if(!FirstOrder){FirstOrder=True;strPrevOrder="BUY";}}
   //AVOID SAME RE_ENTRY
   //if(strPrevOrder=="BUY")return;
   //AVOIDING DUPLICATE ORDERS
   for(trade=OrdersTotal()-1;trade>=0;trade--)
   {
      intResult = OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
      if(OrderType() == OP_BUY && OrderSymbol()==Symbol() && (OrderMagicNumber()== MagicNumber))return;    
   }   
   if(CLOSE_ON_REVERS)CloseAll(1, "ON REVERSE");
   double TP=0, SL=0;
   if (TAKE_PROFIT>0) TP = Ask + TAKE_PROFIT*Poin;
   if (STOP_LOSS  >0) SL = Bid - STOP_LOSS*Poin; 
   
   //NewLot = MathMin(MAX_LOT,LastClosed());
   
   while(true)
     {
      RefreshRates();
      ticket = OrderSend(Symbol(),OP_BUY,NewLot,Ask,OrderSlipage,0,0,strComment, MagicNumber,0,Green);
      RefreshRates();      
      if (ticket > 0) //
      {
         Print("SL :", SL);
         intResult = OrderSelect(ticket,SELECT_BY_TICKET);         
         intResult = OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,Green);
         OrderPrint();
         strPrevOrder = "BUY";
         OrderBar = Bars;
         FirstEntry=True;
         SL_UPDATED=False;
         break;         
         //------------------
      }
      else
      {
         Print("Order Modify Error(",GetLastError(),"): ",ErrorDescription(GetLastError()));
         int error = GetLastError();
         //---- not enough money
         Print("Error(",error,"): ",ErrorDescription(error));
         if(error==134){break;}
         Tries++;
         if(Tries>=3)break;                  
         //---- 10 seconds wait
         Sleep(1000);
         //---- refresh price data
         RefreshRates();
      } 
     }
}

void PlaceSell(double NewLot)
{
   int Tries=0;
   if(AccountFreeMargin()<=0)return;
   if(USE_FIRSTORDER) 
   {if(!FirstOrder){FirstOrder=True;strPrevOrder="SELL";}}
   //AVOID SAME RE_ENTRY
   //if(strPrevOrder=="SELL")return;
   for(trade=OrdersTotal()-1;trade>=0;trade--)
   {
      intResult = OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
      if(OrderType() == OP_SELL && OrderSymbol()==Symbol() && (OrderMagicNumber()== MagicNumber))return;    
   }
   if(CLOSE_ON_REVERS)CloseAll(0, "ON REVERSE");
   double TP=0, SL=0;
   if (TAKE_PROFIT>0) TP = Bid - TAKE_PROFIT*Poin; 
   if (STOP_LOSS  >0) SL = Ask + STOP_LOSS*Poin;   
   
   //NewLot = MathMin(MAX_LOT,LastClosed());
   
   while(true)
     {
      RefreshRates();
            
      //----SINGLE LOT PLACING AND EXIT
      ticket = OrderSend(Symbol(),OP_SELL,NewLot,Bid,OrderSlipage,0,0,strComment, MagicNumber,0,Red);
      RefreshRates();
      if (ticket > 0) 
      {           
         intResult = OrderSelect(ticket,SELECT_BY_TICKET);
         intResult = OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,Green);          
         OrderPrint();
         strPrevOrder = "SELL";
         OrderBar = Bars;
         FirstEntry=True;
         SL_UPDATED=False;
         break;         
         
         //----------------------
      }
      else
      {
         Print("Order Modify Error(",GetLastError(),"): ",ErrorDescription(GetLastError()));
         
         int error=GetLastError();
         //---- not enough money
         Print("Error(",error,"): ",ErrorDescription(error));
         if(error==134){break;}
         Tries++;
         if(Tries>=3)break;                  
         //---- 10 seconds wait
         Sleep(1000);
         //---- refresh price data
         RefreshRates();         
      }                        
     }
}
//+------------------------------------------------------------------+
//| CHECK OPEN ORDERS                                                |
//+------------------------------------------------------------------+  
void GetOpenOrders()
{
   BUY_OPENS=0;BUYSTOP_OPENS=0;SEL_OPENS=0;SELSTOP_OPENS=0;MyOrderProfit=0;
   BUY_PRICE=0; SEL_PRICE=0;
   for(trade=0;trade<OrdersTotal();trade++)             //SELECT FROM STARTS
   //for(int trade=OrdersTotal()-1;trade>=0;trade--)        //SELECTS FROM LASTS
   {
     if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
     {
	   if (OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
	   {					  	  
	  	  //Print("OrderType(): ", OrderType(), " OrderProfit(): ", OrderProfit());
	  	  if (OrderType()==OP_BUY)       {BUY_OPENS++;BUY_PRICE +=OrderOpenPrice();}
	  	  if (OrderType()==OP_SELL)      {SEL_OPENS++;SEL_PRICE +=OrderOpenPrice();} 
	  	  if (OrderType()==OP_BUYSTOP)   BUYSTOP_OPENS++;
	  	  if (OrderType()==OP_SELLSTOP)  SELSTOP_OPENS++; 	  	  	  	  
	  	  MyOrderProfit += OrderProfit()+OrderCommission()+OrderSwap(); 
	   }
	  }
   } 
}
//+------------------------------------------------------------------+
//| CHECK LAST OPEN ORDER TYPE                                       |
//+------------------------------------------------------------------+  
string GetLastOpenOrdType(int MyMagic)
{
   //for(trade=0;trade<OrdersTotal();trade++)             //SELECT FROM STARTS
   for(trade=OrdersTotal()-1;trade>=0;trade--)        //SELECTS FROM LASTS
   {
     if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
     {
	      if (OrderSymbol()==Symbol() && OrderMagicNumber() == MyMagic)
	      {
	         if(OrderType()==0){return("BUY");}
	         if(OrderType()==1){return("SELL");}	         
	      }	      
	  }
   }   
   return("-");
}     

//+------------------------------------------------------------------+
//|Closing Positins                                                  |
//+------------------------------------------------------------------+
void CloseAll(int OrdType, string CloseReason)
{
   bool Closed;
//----
   //---Use While to OrderClose
      for(trade=OrdersTotal()-1;trade>=0;trade--)
        {
         intResult = OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()== MagicNumber) // && OrderType()==OrdType) 
           {               
               Closed=Close_Orders(OrdType);
               if(!Closed){Sleep(500); Closed=Close_Orders(OrdType);}
               if(!Closed){Sleep(500); Closed=Close_Orders(OrdType);}
               if(!Closed){Sleep(500); Closed=Close_Orders(OrdType);}
               if (Closed){Print("*****Closing Reason :", CloseReason);}               
           }        
        }//Profit_Pips = Profit_Pips + Prev_Pips;  
}           

bool Close_Orders(int OrdType)
{
   double Price=0;
   bool Closed=False;   
   RefreshRates();
   if(OrdType<2)
   {  
      if(OrderType()==OP_BUY)Price=Bid;
      if(OrderType()==OP_SELL)Price=Ask;
      Closed=OrderClose(OrderTicket(),OrderLots(),Price,3,Blue);
   }
   else if(OrdType>1)
   {
      Closed=OrderDelete(OrderTicket());
   }
   return(Closed);
}
//+------------------------------------------------------------------+
//| Trailing stop & Step procedure                                   |
//+------------------------------------------------------------------+
void TrailingStopStep( int byPips, int byStep ){
   for (int i = 0; i < OrdersTotal(); i++) {
      intResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() && ( (OrderMagicNumber() == MagicNumber))){
         if (OrderType() == OP_BUY){
            if (Bid - OrderOpenPrice() > byPips * Poin){
               if (OrderStopLoss() < Bid - (byPips+byStep) * Poin){
                  intResult = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - (byPips+byStep) * Poin, OrderTakeProfit(), Red);
               }
              }
             } 
            else if (OrderType() == OP_SELL){
               if (OrderOpenPrice() - Ask > (byPips) * Poin){
                  if ((OrderStopLoss() > Ask + (byPips+byStep) * Poin) || (OrderStopLoss() == 0)){
                     intResult = OrderModify(OrderTicket(), OrderOpenPrice(),Ask + (byPips+byStep) * Poin, OrderTakeProfit(), Red);
        }
       }
      }
     }
	 }
  }    
    
//+------------------------------------------------------------------+
//| Trailing stop & Step procedure                                   |
//+------------------------------------------------------------------+
void TrailingTP( int byPips, int byStep ){
   for (int i = 0; i < OrdersTotal(); i++) {
      intResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() && ( (OrderMagicNumber() == MagicNumber))){
         if (OrderType() == OP_BUY){
            if (OrderOpenPrice()-Ask > byPips * Poin){ //(Bid - OrderOpenPrice() > byPips * Poin){
               if (Ask < OrderTakeProfit() - (byPips+byStep) * Poin){
                  intResult = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ask + (byPips) * Poin, Lime);
               }
              }
             } 
            else if (OrderType() == OP_SELL){
               if (Bid-OrderOpenPrice() > (byPips) * Poin){  //(OrderOpenPrice() - Ask > (byPips) * Poin){
                  if (Bid > OrderTakeProfit() + (byPips+byStep) * Poin){//if ((OrderStopLoss() > Ask + (byPips+byStep) * Poin) || (OrderStopLoss() == 0)){
                     intResult = OrderModify(OrderTicket(), OrderOpenPrice(),OrderStopLoss(), Ask - (byPips) * Poin, Red);
        }
       }
      }
     }
	 }
  }        
//+------------------------------------------------------------------+
//| New Trailing stop & Step procedure 19SEP17                       |
//+------------------------------------------------------------------+
void TrailingStopStepNew(int byPips, int byStep)
{   
   double NewTrail;
   //Print("NEW TRAILING");
   for (int i = 0; i < OrdersTotal(); i++) 
   {
      intResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() && ( (OrderMagicNumber() == MagicNumber)))
      {
         if (OrderType() == OP_BUY)
         {
	         //Print("NEW TRAILING BUY1");
	         if(Ask>OrderOpenPrice()+byPips*Poin)
	         {
	            if(OrderStopLoss()<OrderOpenPrice())
	            {
	               NewTrail=OrderOpenPrice()+byStep*Poin;
	               intResult = OrderModify(OrderTicket(), OrderOpenPrice(), NewTrail, OrderTakeProfit(), Lime);
	            }
	            
	            if(OrderStopLoss()>=OrderOpenPrice()&&Ask>OrderStopLoss()+byPips*Poin)
	            {
	               NewTrail=OrderStopLoss()+byStep*Poin;	            
	               intResult = OrderModify(OrderTicket(), OrderOpenPrice(), NewTrail, OrderTakeProfit(), Lime);
	            }
	         }
	      }
	       
	      if (OrderType()==OP_SELL)
	      {
	         if(Bid<OrderOpenPrice()-byPips*Poin)
	         {
	               //Print("NEW TRAILING SEL");
	               if(OrderStopLoss()>OrderOpenPrice()||OrderStopLoss()==0)
	               {
	                  //Print("NEW TRAILING SEL1");
	                  NewTrail=OrderOpenPrice();
	                  intResult = OrderModify(OrderTicket(), OrderOpenPrice(), NewTrail, OrderTakeProfit(), Lime);	            
	               }
	               
	               if(OrderStopLoss()<=OrderOpenPrice()&&Bid<OrderStopLoss()-byPips*Poin)
	               {
	                  //Print("NEW TRAILING SEL2");
	                  NewTrail=OrderStopLoss()-byStep*Poin;
	                  intResult = OrderModify(OrderTicket(), OrderOpenPrice(), NewTrail, OrderTakeProfit(), Lime);	            
	               }
	         }	       
	      }	       	         
	  }
   }
}
//+------------------------------------------------------------------+
//| BREAK EVEN FUNCTION                                              |
//+------------------------------------------------------------------+  
void BreakEven(double byPips)
{
   for (int i = 0; i < OrdersTotal(); i++) {
      intResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == MagicNumber) && (OrderStopLoss()!=OrderOpenPrice())){
         if (OrderType() == OP_BUY){
            if (Bid - OrderOpenPrice() > byPips * Poin){ //100-90=10
                  intResult = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), Lime);
                  //BreakedEven=True;
              }
             } 
            else if (OrderType() == OP_SELL){
               if (OrderOpenPrice() - Ask > byPips * Poin){ //110-100=10
                     intResult = OrderModify(OrderTicket(), OrderOpenPrice(),OrderOpenPrice(), OrderTakeProfit(), Red);
                     //BreakedEven=True;
       }
      }
     }
	 }
}  
//+------------------------------------------------------------------+
//| LAST CLOSED ORDERS                                               |
//+------------------------------------------------------------------+  
double LastClosed()
{
  int EXPONENT=2;double CummLoss=0, Required_Profit=0;
  if(EXPONENT<=0)return(LOT_SIZE);
  double LastOrdProfit=0;
  MyOrderProfit=0;CummLoss=0;
  double LastLot=LOT_SIZE;
  for(int i=OrdersHistoryTotal()-1;i>=0;i--)
  {   
      intResult=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber)) 
      {
           MyOrderProfit = OrderProfit()+OrderSwap()+OrderCommission();
           //1.61   if(MyOrderProfit<=0)
           if(MyOrderProfit<Required_Profit)
           {   //LostOrders++; 
               if(MyOrderProfit>0)break;
               CummLoss += MyOrderProfit;
               if(LastOrdProfit==0)LastOrdProfit = MyOrderProfit;
               
               LastLot = MathMax(LastLot, OrderLots());
               Print("LastLot: ", LastLot, " OrderLots(): ", OrderLots(), " MyOrderProfit: ", MyOrderProfit, " LastOrdProfit: ", LastOrdProfit);
               
           }
           else if(MyOrderProfit>0)break;
      }            
  }  
  
  Print("*****MyOrderProfit*****: ", MyOrderProfit, " CummLoss: ", CummLoss, " LastLot: ", LastLot);    
  //if(MathAbs(CummLoss)>MyOrderProfit){return(LastLot*EXPONENT);}
  
  if(LastOrdProfit>0&&CummLoss<0)return(LastLot);
  
  if(MyOrderProfit!=0)
  {
      if(MyOrderProfit<Required_Profit){return(LastLot*EXPONENT);}
  } 
  
  if(CummLoss<0){return(LastLot*EXPONENT);}
      
  return(LOT_SIZE);
  
}  

//+------------------------------------------------------------------+
//| EQG_SIGNAL                                                       |
//+------------------------------------------------------------------+  
string EQG_SIGNAL() 
{     
  string log_file_name = "EQG.txt";
  int    str_size;
  int handle = FileOpen(log_file_name, FILE_READ|FILE_WRITE|FILE_CSV);
  if (handle > 0) {
    str_size=FileReadInteger(handle,INT_VALUE);  
    string FileData = FileReadString(handle, str_size);
    FileClose(handle);    
    //Comment("PRICE :", FileData);
    return(FileData);
  }
  return("NO SIGNAL");
} 
//+------------------------------------------------------------------+
//| DOUBLE ON LOSS                                                   |
//+------------------------------------------------------------------+  
double DoubleOnLoss(int MyMagic)
{
  //Print("DoubleOnLoss: ", 1);
  double MyOrdProfit=0;
  int LostOrders=0;
  for(int i=OrdersHistoryTotal()-1;i>=0;i--)
  {   
      //Print("DoubleOnLoss: ", 2);
      intResult=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MyMagic)) //||OrderMagicNumber()==Magic+1||OrderMagicNumber()==Magic+2))            
      {
           //Print("DoubleOnLoss: ", 3);
           MyOrdProfit = OrderProfit()+OrderSwap()+OrderCommission();
           if(MyOrdProfit<=0)return(OrderLots()*2);
           else if(MyOrdProfit>0)break;
      }            
  }  
  //if(LostOrders>0)return(Lots*LOT_EXPONENT*LostOrders);
  return(LOT_SIZE);
} 

//+------------------------------------------------------------------+
//| SL UPDATE                                                        |
//+------------------------------------------------------------------+  
void SL_UPDATE()
{
   GetOpenOrders();   
   double MySL=0;
   if(BUY_OPENS>0)MySL=BUY_PRICE/BUY_OPENS;
   if(SEL_OPENS>0)MySL=SEL_PRICE/SEL_OPENS;
   
   for (int i = 0; i < OrdersTotal(); i++) 
   {
      intResult = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == MagicNumber))
      { 
         if (OrderType() == OP_BUY){intResult = OrderModify(OrderTicket(), OrderOpenPrice(), MySL-STOP_LOSS*Poin, 0, Lime);}
         else if (OrderType() == OP_SELL){intResult = OrderModify(OrderTicket(), OrderOpenPrice(), MySL+STOP_LOSS*Poin, 0, Red);}
      }
      SL_UPDATED=TRUE;
   }
   
   return;
}

void MyLabel() {
   int Lbl_FontSize=15;
   if(USE_M1)
   {
      string name_0 = LblName + "L_1";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 50);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int M1_LblColour = DarkGray;
      
      if(M1_Trend=="BUY")M1_LblColour=Lime;
      
      if(M1_Trend=="SELL")M1_LblColour=Red;
         
      ObjectSetText(name_0, " M1 ", Lbl_FontSize, "Arial Black", M1_LblColour);   
   }   

   if(USE_M5)
   {
      string name_0 = LblName + "L_2";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 100);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int M5_LblColour = DarkGray;
      
      if(M5_Trend=="BUY")M5_LblColour=Lime;
      
      if(M5_Trend=="SELL")M5_LblColour=Red;
         
      ObjectSetText(name_0, " M5 ", Lbl_FontSize, "Arial Black", M5_LblColour);   
   }      
   
   if(USE_M15)
   {
      string name_0 = LblName + "L_3";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 150);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int M15_LblColour = DarkGray;
      
      if(M15_Trend=="BUY")M15_LblColour=Lime;
      
      if(M15_Trend=="SELL")M15_LblColour=Red;
         
      ObjectSetText(name_0, " M15 ", Lbl_FontSize, "Arial Black", M15_LblColour);   
   }      
   
   if(USE_M30)
   {
      string name_0 = LblName + "L_4";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 220);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int M30_LblColour = DarkGray;
      
      if(M30_Trend=="BUY")M30_LblColour=Lime;
      
      if(M30_Trend=="SELL")M30_LblColour=Red;
         
      ObjectSetText(name_0, " M30 ", Lbl_FontSize, "Arial Black", M30_LblColour);   
   }      
   
   if(USE_H1)
   {
      string name_0 = LblName + "L_5";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 290);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int H1_LblColour = DarkGray;
      
      if(H1_Trend=="BUY")H1_LblColour=Lime;
      
      if(H1_Trend=="SELL")H1_LblColour=Red;
         
      ObjectSetText(name_0, " H1 ", Lbl_FontSize, "Arial Black", H1_LblColour);   
   }      
   
   if(USE_H4)
   {
      string name_0 = LblName + "L_6";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 335);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int H4_LblColour = DarkGray;
      
      if(H4_Trend=="BUY")H4_LblColour=Lime;
      
      if(H4_Trend=="SELL")H4_LblColour=Red;
         
      ObjectSetText(name_0, " H4 ", Lbl_FontSize, "Arial Black", H4_LblColour);   
   }                  

   if(USE_D1)
   {
      string name_0 = LblName + "L_7";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 385);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int D1_LblColour = DarkGray;
      
      if(D1_Trend=="BUY")D1_LblColour=Lime;
      
      if(D1_Trend=="SELL")D1_LblColour=Red;
         
      ObjectSetText(name_0, " D1 ", Lbl_FontSize, "Arial Black", D1_LblColour);   
   }                     
   
   if(USE_W1)
   {
      string name_0 = LblName + "L_8";
      if (ObjectFind(name_0) == -1) {
         ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_0, OBJPROP_CORNER, 2);
         ObjectSet(name_0, OBJPROP_XDISTANCE, 435);   //390);
         ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
      }
      int W1_LblColour = DarkGray;
      
      if(W1_Trend=="BUY")W1_LblColour=Lime;
      
      if(W1_Trend=="SELL")W1_LblColour=Red;
         
      ObjectSetText(name_0, " W1 ", Lbl_FontSize, "Arial Black", W1_LblColour);   
   }                        
}   
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //------ 
   //if(EQG_SIGNAL()=="STOP"){Comment("STOPPED BY EQG");return;}
   //------   
   
   if(PREV_PERIOD==0)PREV_PERIOD=Period();
   
   if(PREV_PERIOD!=Period())
   {
      Alert("NEVER CHANGE EA ATTACHED CHART TIME FRAME...!");
      CloseAll(0, "CHART TIME FRAME CHANGED");
      CloseAll(1, "CHART TIME FRAME CHANGED");
      ExpertRemove();return;
   }  
   
//---
   if (BackTestAllowed==FALSE){
   if(IsTesting()){return;}}
   
   if (TimeCurrent()>ExpiryDate){
   ExpertRemove();
   return;}      
   
   if (UseAccountNumber){
   if (ValidAccountNumber != AccountNumber()){ExpertRemove();return;}
   }       

      if(USE_TRAILING)TrailingStopStep(TRAILING_PIPS, TRAILING_STEP);
      
      //PA_Multi_IND_TF_EA V2.1
      if(USE_TRAILING)TrailingTP(TP_TRAILING_PIPS,0);
      
      
      int IND_BAR=0;
      
      if(USE_M1)
      {
         RefreshRates();M1_Trend="";
         string M1_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M1_EMA7  = iCustom(Symbol(), PERIOD_M1, M1_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         //Print("IND_NAME : ", M1_IND_EMA7, " M1_EMA7 :", M1_EMA7);      
         
         string M1_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M1_EMA20  = iCustom(Symbol(), PERIOD_M1, M1_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         //Print("IND_NAME : ", M1_IND_EMA20, " M1_EMA20 :", M1_EMA20);*/
               
         string M1_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M1_MFI_BUY  = iCustom(Symbol(), PERIOD_M1, M1_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M1_MFI_SEL  = iCustom(Symbol(), PERIOD_M1, M1_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         //Print("IND_NAME : ", M1_IND_MFI, " M1_MFI_BUY :", M1_MFI_BUY, " M1_MFI_SEL :", M1_MFI_SEL);
         //if(M1_MFI_BUY==1&&M1_MFI_SEL==0)PlaceBuy(LOT_SIZE); //if(M1_MFI_BUY==0&&M1_MFI_SEL==1)PlaceSell(LOT_SIZE);*/            
         
         string M1_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M1_RSI_BUY  = iCustom(Symbol(), PERIOD_M1, M1_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M1_RSI_SEL  = iCustom(Symbol(), PERIOD_M1, M1_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         //Print("IND_NAME : ", M1_IND_RSI, " M1_RSI_BUY :", M1_RSI_BUY, " M1_RSI_SEL :", M1_RSI_SEL);
         //if(M1_RSI_BUY==1&&M1_RSI_SEL==0)PlaceBuy(LOT_SIZE); //if(M1_RSI_BUY==0&&M1_RSI_SEL==1)PlaceSell(LOT_SIZE);*/      
         M1_Trend="-";
         
         if(M1_EMA7>M1_EMA20 && M1_MFI_BUY==1 &&  M1_RSI_BUY==1) M1_Trend="BUY"; // Print("ALL INDICATORS BUYING");
         
         if(M1_EMA7<M1_EMA20 && M1_MFI_SEL==1 &&  M1_RSI_SEL==1) M1_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
      }
      
      if(USE_M5)
      {
         RefreshRates();M5_Trend="";
         string M5_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M5_EMA7  = iCustom(Symbol(), PERIOD_M5, M5_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string M5_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M5_EMA20  = iCustom(Symbol(), PERIOD_M5, M5_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string M5_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M5_MFI_BUY  = iCustom(Symbol(), PERIOD_M5, M5_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M5_MFI_SEL  = iCustom(Symbol(), PERIOD_M5, M5_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string M5_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M5_RSI_BUY  = iCustom(Symbol(), PERIOD_M5, M5_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M5_RSI_SEL  = iCustom(Symbol(), PERIOD_M5, M5_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(M5_EMA7>M5_EMA20 && M5_MFI_BUY==1 &&  M5_RSI_BUY==1) M5_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(M5_EMA7<M5_EMA20 && M5_MFI_SEL==1 &&  M5_RSI_SEL==1) M5_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
      }      

      if(USE_M15)
      {
         RefreshRates();M15_Trend="";
         string M15_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M15_EMA7  = iCustom(Symbol(), PERIOD_M15, M15_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string M15_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M15_EMA20  = iCustom(Symbol(), PERIOD_M15, M15_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string M15_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M15_MFI_BUY  = iCustom(Symbol(), PERIOD_M15, M15_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M15_MFI_SEL  = iCustom(Symbol(), PERIOD_M15, M15_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string M15_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M15_RSI_BUY  = iCustom(Symbol(), PERIOD_M15, M15_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M15_RSI_SEL  = iCustom(Symbol(), PERIOD_M15, M15_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(M15_EMA7>M15_EMA20 && M15_MFI_BUY==1 &&  M15_RSI_BUY==1) M15_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(M15_EMA7<M15_EMA20 && M15_MFI_SEL==1 &&  M15_RSI_SEL==1) M15_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
      } 
      
      if(USE_M30)
      {
         RefreshRates();M30_Trend="";
         string M30_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M30_EMA7  = iCustom(Symbol(), PERIOD_M30, M30_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string M30_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M30_EMA20  = iCustom(Symbol(), PERIOD_M30, M30_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string M30_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M30_MFI_BUY  = iCustom(Symbol(), PERIOD_M30, M30_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M30_MFI_SEL  = iCustom(Symbol(), PERIOD_M30, M30_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string M30_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double M30_RSI_BUY  = iCustom(Symbol(), PERIOD_M30, M30_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double M30_RSI_SEL  = iCustom(Symbol(), PERIOD_M30, M30_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(M30_EMA7>M30_EMA20 && M30_MFI_BUY==1 &&  M30_RSI_BUY==1) M30_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(M30_EMA7<M30_EMA20 && M30_MFI_SEL==1 &&  M30_RSI_SEL==1) M30_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
      }       
      
      if(USE_H1)
      {
         RefreshRates();H1_Trend="";
         string H1_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H1_EMA7  = iCustom(Symbol(), PERIOD_H1, H1_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string H1_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H1_EMA20  = iCustom(Symbol(), PERIOD_H1, H1_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string H1_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H1_MFI_BUY  = iCustom(Symbol(), PERIOD_H1, H1_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double H1_MFI_SEL  = iCustom(Symbol(), PERIOD_H1, H1_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string H1_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H1_RSI_BUY  = iCustom(Symbol(), PERIOD_H1, H1_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double H1_RSI_SEL  = iCustom(Symbol(), PERIOD_H1, H1_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(H1_EMA7>H1_EMA20 && H1_MFI_BUY==1 &&  H1_RSI_BUY==1) H1_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(H1_EMA7<H1_EMA20 && H1_MFI_SEL==1 &&  H1_RSI_SEL==1) H1_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
      }             
      
      if(USE_H4)
      {
         RefreshRates();H4_Trend="";
         string H4_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H4_EMA7  = iCustom(Symbol(), PERIOD_H4, H4_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string H4_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H4_EMA20  = iCustom(Symbol(), PERIOD_H4, H4_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string H4_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H4_MFI_BUY  = iCustom(Symbol(), PERIOD_H4, H4_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double H4_MFI_SEL  = iCustom(Symbol(), PERIOD_H4, H4_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string H4_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double H4_RSI_BUY  = iCustom(Symbol(), PERIOD_H4, H4_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double H4_RSI_SEL  = iCustom(Symbol(), PERIOD_H4, H4_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(H4_EMA7>H4_EMA20 && H4_MFI_BUY==1 &&  H4_RSI_BUY==1) H4_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(H4_EMA7<H4_EMA20 && H4_MFI_SEL==1 &&  H4_RSI_SEL==1) H4_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
         
         //Print("H4_MFI_BUY: ", H4_MFI_BUY, " H4_MFI_SEL: ", H4_MFI_SEL);
      }                   
      
      if(USE_D1)
      {
         RefreshRates();D1_Trend="";
         string D1_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double D1_EMA7  = iCustom(Symbol(), PERIOD_D1, D1_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string D1_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double D1_EMA20  = iCustom(Symbol(), PERIOD_D1, D1_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string D1_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double D1_MFI_BUY  = iCustom(Symbol(), PERIOD_D1, D1_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double D1_MFI_SEL  = iCustom(Symbol(), PERIOD_D1, D1_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string D1_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double D1_RSI_BUY  = iCustom(Symbol(), PERIOD_D1, D1_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double D1_RSI_SEL  = iCustom(Symbol(), PERIOD_D1, D1_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(D1_EMA7>D1_EMA20 && D1_MFI_BUY==1 &&  D1_RSI_BUY==1) D1_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(D1_EMA7<D1_EMA20 && D1_MFI_SEL==1 &&  D1_RSI_SEL==1) D1_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
         
         //Print("D1_MFI_BUY: ", D1_MFI_BUY, " D1_MFI_SEL: ", D1_MFI_SEL);
      }                         
              
      if(USE_W1)
      {
         RefreshRates();W1_Trend="";
         string W1_IND_EMA7 = "TMT - EMA 7";   //"TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double W1_EMA7  = iCustom(Symbol(), PERIOD_W1, W1_IND_EMA7,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         
         string W1_IND_EMA20 = "TMT - EMA 20"; //"TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double W1_EMA20  = iCustom(Symbol(), PERIOD_W1, W1_IND_EMA20,0,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
               
         string W1_IND_MFI = "TMT - FxGlow MFI Meter";   //"TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double W1_MFI_BUY  = iCustom(Symbol(), PERIOD_W1, W1_IND_MFI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double W1_MFI_SEL  = iCustom(Symbol(), PERIOD_W1, W1_IND_MFI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         string W1_IND_RSI = "TMT - FxGlow RSI Meter"; //"PipsByPips_Scalper";   
         double W1_RSI_BUY  = iCustom(Symbol(), PERIOD_W1, W1_IND_RSI,2,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 0, 1);     
         double W1_RSI_SEL  = iCustom(Symbol(), PERIOD_W1, W1_IND_RSI,3,IND_BAR);//, MAPeriod, MAType, MAAppliedPrice, 1, 1);    
         
         if(W1_EMA7>W1_EMA20 && W1_MFI_BUY==1 &&  W1_RSI_BUY==1) W1_Trend="BUY"; //Print("ALL INDICATORS BUYING");
         
         if(W1_EMA7<W1_EMA20 && W1_MFI_SEL==1 &&  W1_RSI_SEL==1) W1_Trend="SELL"; //Print("ALL INDICATORS SELLING");      
         
         //Print("W1_MFI_BUY: ", W1_MFI_BUY, " W1_MFI_SEL: ", W1_MFI_SEL);
      }
                  
      if (((!IsOptimization()) && !IsTesting() && (!IsVisualMode()))){MyLabel();}
      //MyLabel();
      
      if(!REVERSE_TRADING)
      {
         if((M1_Trend=="BUY")&&(M5_Trend=="BUY")&&(M15_Trend=="BUY")&&(M30_Trend=="BUY")&&(H1_Trend=="BUY")&&(H4_Trend=="BUY")&&(D1_Trend=="BUY")&&(W1_Trend=="BUY")) PlaceBuy(LOT_SIZE);
         //----TEMP TESTING if((H1_Trend=="BUY")) PlaceBuy(LOT_SIZE);         
         
         if((M1_Trend=="SELL")&&(M5_Trend=="SELL")&&(M15_Trend=="SELL")&&(M30_Trend=="SELL")&&(H1_Trend=="SELL")&&(H4_Trend=="SELL")&&(D1_Trend=="SELL")&&(W1_Trend=="SELL")) PlaceSell(LOT_SIZE);
         //----TEMP TESTING if((H1_Trend=="SELL")) PlaceSell(LOT_SIZE);
      }         
      else
      {
         if((M1_Trend=="BUY")&&(M5_Trend=="BUY")&&(M15_Trend=="BUY")&&(M30_Trend=="BUY")&&(H1_Trend=="BUY")&&(H4_Trend=="BUY")&&(D1_Trend=="BUY")&&(W1_Trend=="BUY"))PlaceSell(LOT_SIZE);
         
         if((M1_Trend=="SELL")&&(M5_Trend=="SELL")&&(M15_Trend=="SELL")&&(M30_Trend=="SELL")&&(H1_Trend=="SELL")&&(H4_Trend=="SELL")&&(D1_Trend=="SELL")&&(W1_Trend=="SELL"))PlaceBuy(LOT_SIZE);
      }               
      
      
      return;
      
      //if(IND1>0)PlaceBuy(LOT_SIZE);
      //if(IND2>0)PlaceSell(LOT_SIZE);
      
      return;
   	
      if(!FirstEntry) //First Entry Only: 
      {
         //If CMP > Prev High : Place Buy Order
         if(Bid>High[1])PlaceBuy(LOT_SIZE);
         //If CMP < Prev. Low Place Sell Order            
         if(Ask<Low[1])PlaceSell(LOT_SIZE);
         
         return;
      }
      
      //SL in Pips as Input: 20
      if(!SL_UPDATED)
      {
         SL_UPDATE();
         return;
      }
      
      
      
      
      return;      
	   
	   //Close=High->Second Candle Sell	
		//Close=Low->Second Candle Buy	10K
		//Candle Close Order Close
      if(OrderBar != Bars){OrderBar = Bars;CloseAll(0,"CANDLE CLOSE");CloseAll(1,"CANDLE CLOSE");}
                                        
      if(Close[1]==Low[1])PlaceBuy(LOT_SIZE);
      if(Close[1]==High[1])PlaceSell(LOT_SIZE);

  }

//+------------------------------------------------------------------+
