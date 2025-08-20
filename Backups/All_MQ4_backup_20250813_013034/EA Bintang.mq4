//+------------------------------------------------------------------+
//       _____  _____   __  _________  ___  ____________  ______     |
//====  /  _/ |/ / _ | / / / ___/ __ \/ _ \/  _/_  __/  |/  / _ |    |
//==== _/ //    / __ |/ /_/ (_ / /_/ / , _// /  / / / /|_/ / __ |    |
//====/___/_/|_/_/ |_/____|___/\____/_/|_/___/ /_/ /_/  /_/_/ |_|    |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, INALGORITMA Software Corp."
#property link      "https://www.inalgoritmafx.com"
#property version   "1.00"

#include      <stdlib.mqh>



extern double  Lots            = 1.0; 
extern double  Multiplier      = 2.0;
extern int     Range           = 200;
extern int     MagicNumber     = 2672;

extern string  SettingIndi_1   = "RG_Star";
extern int     ExtDepth        = 14;
extern int     ExtDepth2       = 90;
extern int     ExtDeviation    = 3;
extern int     ExtBackstep     = 12;
extern int     ExtDeptha       = 34;
extern int     ExtDeptha2      = 120;
extern int     ExtDeviationa   = 3;
extern int     ExtBackstepa    = 12;


   
       int     StartHour       = 0;
       int     EndHour         = 24;

bool           ShowInfo        = true;
int            Corner          = 1;              
int            PT              = 1,
               DIGIT,SlipPage;
double         POINT;  
int            xnumb           = 2147483647;
int            TakeProfit      = 0;
int            StopLoss        = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   SlipPage = 4;
   AutoDigit(); 
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   DelObject();
   Comment(""); 
	return(0);
}
//+------------------------------------------------------------------+
//| Expert start function                                   |
//+------------------------------------------------------------------+
int start()
{
   if(IsTrade())
   {
      SetupTrade();
      av();
      DisplayShow();
	}
	
   return(0);
}
//========================================

void SetupTrade()
{
   double val7_0 = iCustom(Symbol(),Period(),"RG_star",ExtDepth,ExtDepth2,ExtDeviation,ExtBackstep,ExtDeptha,ExtDeptha2,ExtDeviationa,ExtBackstepa,6,0);
   double val8_0 = iCustom(Symbol(),Period(),"RG_star",ExtDepth,ExtDepth2,ExtDeviation,ExtBackstep,ExtDeptha,ExtDeptha2,ExtDeviationa,ExtBackstepa,7,0);
   
   double trend0_0 = iCustom(Symbol(),Period(),"#Bamsbung-Trend1",0,0);
   double trend1_0 = iCustom(Symbol(),Period(),"#Bamsbung-Trend1",1,0);
   
   bool buy1   = val7_0 > 0 && val8_0 == 0 && trend1_0 > 0;
   bool sell1  = val8_0 > 0 && trend0_0 > 0;
   
   datetime candleTime   = iTime(Symbol(),Period(),0); static datetime timeTrade;
   bool     trade        = Hour() >= StartHour && Hour() <= EndHour;  
   
   if(buy1 && TotalOrder(OP_SELL) > 0)
   {
      CloseOrder(OP_SELL);
   }
   
   if(sell1 && TotalOrder(OP_BUY) > 0)
   {
      CloseOrder(OP_BUY);
   }
   
   if(trade)
   {  
      if(buy1 && timeTrade != candleTime && TotalOrder(OP_BUY)==0)  
      {
         Order(OP_BUY,"buy#1",SetupLot());
         timeTrade = candleTime;
      }           
      if(sell1 && timeTrade != candleTime && TotalOrder(OP_SELL)==0) 
      {
         Order(OP_SELL,"sell#1",SetupLot());
         timeTrade = candleTime;
      }
   }
}

//=======================================

bool IsOrder(string comment)
{
   bool isOrder = true;
   
   if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
   {
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {  
         if(StringFind(OrderComment(),comment) != -1) isOrder = false;
         
         if(OrderType() == OP_BUY)
         {
            if(OrderStopLoss() > OrderOpenPrice()) isOrder = false;
         }

         if(OrderType() == OP_SELL)
         {
            if(OrderStopLoss() < OrderOpenPrice() && OrderStopLoss() > 0) isOrder = false;
         }
      }
   }
   
   return(isOrder);
}

double TotalPips()
{
   double totalPip = 0, pip = 0;
   string date     = TimeToString(TimeCurrent(),TIME_DATE);
   
   for(int i = OrdersHistoryTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(StringFind(TimeToString(OrderCloseTime(),TIME_DATE),date) != -1)
            {
               if(OrderType() == OP_BUY)
               {
                  pip = (OrderClosePrice()-OrderOpenPrice())/POINT;
                  totalPip += pip;
               }

               if(OrderType() == OP_SELL)
               {
                  pip = (OrderOpenPrice()-OrderClosePrice())/POINT;
                  totalPip += pip;
               }
            }
         }
      }
   }
   
   return(totalPip);
}


int TotalOrder(int ordertype = -1)
{
   int Order = 0;

   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(ordertype == -1) 
               Order++;
            else if(ordertype == OrderType()) 
               Order++;
         }
      }
   }
   
   return(Order);
}

double SetupLot()
{
   double lot    = 0, firstLot = 0,
          MinLot = MarketInfo(Symbol(),MODE_MINLOT),
          MaxLot = MarketInfo(Symbol(),MODE_MAXLOT); 
      
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            lot = MathMax(lot,OrderLots());
         }
      }
   }
   
   lot = Lots;
   

   if(MinLot == 0.01)
      firstLot = NormalizeDouble(firstLot,2);  
   else
      firstLot = NormalizeDouble(firstLot,1);
   
   if(lot == 0)
      lot = Lots;
      
   if(lot < MinLot) lot = MinLot;
   if(lot > MaxLot) lot = MaxLot;   
   
   if(MinLot == 0.01)
      lot = NormalizeDouble(lot,2);  
   else
      lot = NormalizeDouble(lot,1);
      
   return(lot);
}

double AskPrice(string symbol = "")
{
   if(symbol == "") symbol = Symbol();
   return(MarketInfo(symbol,MODE_ASK));
}

double BidPrice(string symbol = "")
{
   if(symbol == "") symbol = Symbol();
   return(MarketInfo(symbol,MODE_BID));
}

int StopLevel(string symbol = "")
{
   if(symbol == "") symbol = Symbol();
   return(MarketInfo(symbol,MODE_STOPLEVEL));
}

string OrderCmd(int ordertype)
{
   string label;

   switch(ordertype)
   {
      case 0: label = "Buy";        break;
      case 1: label = "Sell";       break;
      case 2: label = "Buy Limit";  break;
      case 3: label = "Sell Limit"; break;
      case 4: label = "Buy Stop";   break;
      case 5: label = "Sell Stop";  break;
   }

   return(label);
}

int Order(int ordertype, string comment, double uselot)
{
   int             ticket;
   double          lot         = uselot,price, sl = 0, tp = 0;
   
   if(ordertype == OP_BUY)  
   {
      price = AskPrice(); 
      if(StopLoss > 0)   sl = NormalizeDouble(price-(StopLoss*POINT),DIGIT);
      if(TakeProfit > 0) tp = NormalizeDouble(price+(TakeProfit*POINT),DIGIT);      
   }
   
   if(ordertype == OP_SELL) 
   {
      price = BidPrice(); 
      if(StopLoss > 0)   sl = NormalizeDouble(price+(StopLoss*POINT),DIGIT);
      if(TakeProfit > 0) tp = NormalizeDouble(price-(TakeProfit*POINT),DIGIT);      
   }
              
   ticket = OrderSend(Symbol(),ordertype,lot,price,SlipPage,sl,tp,comment,MagicNumber,0);
   if(ticket == -1) ShowError("Order " + OrderCmd(ordertype));
   
   return(ticket);
}

void CloseOrder(int ordertype = -1)
{   
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(ordertype == -1)
            {
               if(OrderType() == OP_BUY) 
               {     
                  if(!OrderClose(OrderTicket(),OrderLots(),BidPrice(OrderSymbol()),SlipPage,Blue)) ShowError("Close " + OrderCmd(OrderType())); 
               }
               else if(OrderType() == OP_SELL)
               {      
                  if(!OrderClose(OrderTicket(),OrderLots(),AskPrice(OrderSymbol()),SlipPage,Red)) ShowError("Close " + OrderCmd(OrderType()));
               } 
               else
               {
                  if(!OrderDelete(OrderTicket())) ShowError("Delete Pending Order " + OrderCmd(OrderType()));
               }
            }
            else
            {
               if(OrderType() == ordertype)
               {
                  if(ordertype == OP_BUY)
                  {   
                     if(!OrderClose(OrderTicket(),OrderLots(),BidPrice(OrderSymbol()),SlipPage,Blue)) ShowError("Close " + OrderCmd(OrderType()));
                  } 
                  else if(ordertype == OP_SELL)   
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),AskPrice(OrderSymbol()),SlipPage,Red)) ShowError("Close " + OrderCmd(OrderType()));
                  } 
                  else
                  {
                     if(!OrderDelete(OrderTicket())) ShowError("Delete Pending Order " + OrderCmd(OrderType()));
                  }
               }
            }
         }
      }
   }
}

double TotalProfit()
{  
   if(TotalOrder() > 0)
   {
      double profit = 0;
    
      for(int i = 0; i < OrdersTotal(); i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) profit += OrderProfit();
         }
      }
   }
   
   return(profit);
}

void ShowError(string label)
{
	string Error;
	int    error = GetLastError();
	
	Error        = StringConcatenate("Terminal: ",TerminalName(),"\n",
	                                  label," error ",error,"\n",
	                                  ErrorDescription(error));
	if(error > 2) 
	{
	  if(IsTesting())
	     Comment(Error);
	  else   
	     Alert(Error);
   }
}
        
void AutoDigit()
{
   POINT = MarketInfo(Symbol(),MODE_POINT);
   DIGIT = MarketInfo(Symbol(),MODE_DIGITS);
   
   if (DIGIT == 3 || DIGIT == 5)
   {
      PT              = 10;
      StopLoss       *= 10;
      TakeProfit     *= 10;
      SlipPage       *= 10;
   }
}

bool IsTrade()
{
   bool trade = true;
   
   if(!IsTesting())
   {
      if(!IsTradeAllowed()) 
      {
         Alert("Allow live trading is disable, press F7, \nselect Common tab, check Allow live trading");
         trade = false;
      }
   
      if(!IsExpertEnabled()) 
      {
         Alert("Expert Advisor is disable, click AutoTrading button to activate it ");
         trade = false;
      }   
   }
   
   return(trade);
}

void DelObject(string objectName = "")
{
   for(int i = ObjectsTotal()-1; i >= 0; i--)
	{
	   if(StringFind(ObjectName(i),WindowExpertName()) != -1)
	   {
	   	if(objectName == "")
	  			ObjectDelete(ObjectName(i));
	   	else
	   		if(StringFind(ObjectName(i),objectName) != -1) ObjectDelete(ObjectName(i));
		}
	}
}

void DisplayShow()
{
   if(ShowInfo)
   {
      DelObject();     
      DisplayInfo("Balance",StringConcatenate("",DoubleToString(AccountBalance(),2)));
      if(AccountMargin() != 0) DisplayInfo("Equity",StringConcatenate("",DoubleToString(AccountEquity(),2)));
      DisplayInfo("Spread",StringConcatenate("",MarketInfo(Symbol(),MODE_SPREAD)/PT));
      if(AccountMargin() != 0)
      {
         DisplayInfo ("Margin",StringConcatenate(DoubleToString((AccountEquity()/AccountMargin())*100,2),"%"));
		   DisplayInfo("Profit",StringConcatenate("",DoubleToString(TotalProfit(),2)));
      }
      
      DisplayInfo("TotalPips",StringConcatenate("",DoubleToString(TotalPips()/PT,1)));
   }
}  

void DisplayInfo(string name, string value)
{
   color      LabelColor      = White,
              BackgroundColor = DarkGreen;
   string     Font            = "Arial", name1,name2,name3;
   int        FontSize        = 9,
              Space           = 15, 
              X1,X2,X3;
   static int Y;
           
   if(name == "Balance") Y = 30;
   else                  Y += Space;
   if(Corner % 2 == 0) {X1 = 10; X2 = 70; X3 = 80;}
   else                {X1 = 90; X2 = 80; X3 = 10;}
             
   if(name != "")
   {        
      name1 = StringConcatenate(WindowExpertName(),name);
      name2 = StringConcatenate(WindowExpertName(),name,":");
      name3 = StringConcatenate(WindowExpertName(),name,"Value");
      
      ObjectDelete(name3);

      ObjectCreate(name1,OBJ_LABEL,0,0,0);           
      ObjectCreate(name2,OBJ_LABEL,0,0,0);      
      ObjectCreate(name3,OBJ_LABEL,0,0,0);
            
      ObjectSetText(name1,name,FontSize,Font, LabelColor); 
      ObjectSetText(name2,":",FontSize,Font,LabelColor); 
      ObjectSetText(name3,value,FontSize,Font,LabelColor);
            
      ObjectSet(name1,OBJPROP_CORNER,Corner);      
      ObjectSet(name2,OBJPROP_CORNER,Corner); 
      ObjectSet(name3,OBJPROP_CORNER,Corner);
            
      ObjectSet(name1,OBJPROP_XDISTANCE, X1);       
      ObjectSet(name2,OBJPROP_XDISTANCE, X2);  
      ObjectSet(name3,OBJPROP_XDISTANCE, X3);
            
      ObjectSet(name1,OBJPROP_YDISTANCE,Y);        
      ObjectSet(name2,OBJPROP_YDISTANCE,Y);   
      ObjectSet(name3,OBJPROP_YDISTANCE,Y);
   }
}

double last_price(int ordertype = -1)
{
   int i;
   double price;
   for(i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)&&OrderType()==ordertype) 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         price = NormalizeDouble(OrderOpenPrice(),DIGIT);
      }
   }
   return(price);
}

double last_lot(int ordertype = -1)
{
   int i;
   double lot;
   for(i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)&&OrderType()==ordertype) 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         lot = OrderLots();
      }
   }
   return(lot);
}

void av()
{
   double price,uselots;
   if(TotalOrder(0) > 0)
   {
      price  = NormalizeDouble(last_price(0)-(Range*POINT),DIGIT);
      uselots = last_lot(0)*Multiplier;
      
      if(AskPrice() <= price)
      {
         Order(OP_BUY,"buyav",uselots);
      } 
   }
   
   if(TotalOrder(1) > 0)
   {
      price  = NormalizeDouble(last_price(1)+(Range*POINT),DIGIT);
      uselots = last_lot(1)*Multiplier;
      
      if(BidPrice() >= price)
      {
         Order(OP_SELL,"sellav",uselots);
      } 
   }
}