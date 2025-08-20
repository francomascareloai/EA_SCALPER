//+------------------------------------------------------------------+
//|                                                 MahsinEA EA.mq4  |
//|                              Copyright 2022, oladseye@gmail.com  |
//|                                 https://www.fiverr.com/dmjoguns  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, Ola Seye"
#property link      "https://t.me/Ola_Seye"
#property version   "1.00"
#property strict

#include <Controls/Button.mqh>

CButton              FLA_Acivate_button;

enum Risk_Management
 {
   Fixed_Lot,Risk_Percent
 };   


enum Trademanager
 {
   Manual,Times
 };   


input string A="================================";//======Trade Setting======
input double MaxSpread = 0; // Maximum Spread
input bool  ShowArrows=true; // Show Arrow
extern double Slippage=3; // Max Slippage (0=Disabled)
input int Magic =1134;
input string comment ="";
input string A6="";//======Risk Setting======
input Risk_Management Lot_type=Fixed_Lot; // Risk Management Type (Choose)
input Trademanager    cfg = Manual ;// Trade Type
input double LotSize = 0.1; // Fixed Lot Size
input double EquityStop=0.5;//Risk %
input double StopLoss = 20;
input double TakeProfit =40;


extern string StartTime = "09:28";

int xv = 0;// Position X
int yv = 30;// Position Y



double mp =1;

string sub;
datetime tl;
double tickvalues;
datetime timestart;
datetime datenow;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   
    ObjectDel();
    
    timestart = TimeCurrent();
   
   
    if(!CreateButton(FLA_Acivate_button,"FLA_Acivate_button","No Trading",xv+0,yv+40,xv+110,yv+80,"Arial Bold",9,clrBlue))return(false);
   
   
   tickvalues=0;
   GetPoint();
    
    if(mp != 1)
     {
       Slippage = Slippage *mp;
       
     }  
     
   
 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDel();
   
  
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void ObjectDel()
   {
     string name;
     int totalObjects  = ObjectsTotal(0,0,-1);

    for(int i=totalObjects-1; i>= 0; i--)
       {
          name = ObjectName(0,i,0,-1);
          if(StringFind(name,"FLA",0)>=0) ObjectDelete(0,name);
       }
 
}

bool CreateButton(CButton &button,string objname,string text,int x1,int y1,int x2, int y2, string fontname, int fontsize, color clr)
  {
   
   string font = "Arial Black";
   
   if(!button.Create(0,objname,0,x1,y1,x2,y2))
      return(false);
   if(!button.Text(text))
      return(false);
   if(!button.Color(clrWhite))
      return(false);
   if(!button.ColorBackground(clr))
      return(false);
   if(!button.ColorBorder(clrBlack))
      return(false);
   if(!button.FontSize(fontsize))
      return(false);
    if(!button.Top())
      return(false);
   if(!button.BringToTop())
      return(false);
   if(!button.Font(font))   
      return(false);
   
      
   
   return(true);
  }
  
  // 
  
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
  
   if(ObjectGetInteger(0,"FLA_Acivate_button",OBJPROP_STATE))
    {
         
         ObjectSetInteger(0,"FLA_Acivate_button",OBJPROP_STATE,0);
         
         if(ObjectGetString(0,"FLA_Acivate_button",OBJPROP_TEXT)=="No Trading")
           {
             ObjectSetString(0,"FLA_Acivate_button",OBJPROP_TEXT,"Trading");   
           }  
         else if (ObjectGetString(0,"FLA_Acivate_button",OBJPROP_TEXT)=="Trading")
            {
              ObjectSetString(0,"FLA_Acivate_button",OBJPROP_TEXT,"No Trading");   
            }  
      
    }
    
   
  } 
    

void OnTick()
  {
//--- 
      RefreshRates();  
        
        if(cfg == Manual) 
           {
            
               if(ObjectGetString(0,"FLA_Acivate_button",OBJPROP_TEXT)=="Trading")
                {
                    if(datenow !=  iTime(NULL,PERIOD_D1,0))
                      {
                          if(NumTradr()==0 && NumTrade(2)==0)Indic();
                          datenow =  iTime(NULL,PERIOD_D1,0);
                      }    
                }     
                
                
               if(ObjectGetString(0,"FLA_Acivate_button",OBJPROP_TEXT)=="No Trading")datenow = 0;
              
                 //Print("datenow: ",datenow); 
             }   
           
       
        
        if(cfg == Times)
            {  
             if(timestart<StringToTime(StartTime) && TimeCurrent()>StringToTime(StartTime))  
                { 
                  
                  if(NumTradr()==0 && NumTrade(2)==0)Indic();
                  timestart=TimeCurrent();
                } 
            }
        
        
         if(NumTradr()==1 && NumTrade(2)==1)CloseOrder();  
            
                 
  }
//+------------------------------------------------------------------+



   
int NumTrade(int d)
   {
     int tot=0;
     double total = OrdersTotal();
  
      for(int i=0;i<total;i++)
        {
            if(OrderSelect(i,SELECT_BY_POS))
              {
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
                  {
                    if(d==0 && OrderType() ==0)tot+=1;
                    if(d==1 && OrderType() ==1)tot+=1;
                    if(d==2 && (OrderType() ==0 || OrderType() ==1))tot+=1;
                  }  
              }
        }      
 return(tot);  
   }
   
int NumTradr()
   {
     int tot=0;
     double total = OrdersTotal();
  
      for(int i=0;i<total;i++)
        {
            if(OrderSelect(i,SELECT_BY_POS))
              {
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType()>1)
                  {
                     tot+=1;
                    
                  }  
              }
        }      
 return(tot);  
   }   

   
void Indic()
   {
          
      OpenBuy(Close[0]);
      OpenSell(Close[0]);
      if(NumTradr()==1)CloseOrder();
          
     
   }


 void CloseOrder()
   {
      double total = OrdersTotal();
      for(int i=0;i<total;i++)
        {
            if(OrderSelect(i,SELECT_BY_POS))
              {
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType()>1)
                  {
                   
                     if(!(OrderDelete(OrderTicket(),clrNONE)))Print("Pending Order Close Failed: ",GetLastError());
                     
                   
                   }  
                }   
           }
   
   
   }

void OpenBuy(double pr)
  {
  
   RefreshRates();
  double sl=0;
  double tp=0;
  double lot =0;

   int ticket=0,tries=0;
  
      int tries_main=0;
      while(ticket<=0)
        {
         RefreshRates();
                
         if(GetSpread()>MaxSpread && MaxSpread !=0)
           {
            Print("Order not opened because spread ("+(string)(GetSpread())+") is higher than max allowed spread ("+(string)MaxSpread);
            return;
           }

         
         color arrowColor=clrLimeGreen;
         if(!ShowArrows) arrowColor=clrNONE;
          
       
       lot=GetLots();
       if(lot <= 0){Print("Calculated Lot Size <= 0");return;}
       
        if(!AccountFreeMarginCheck(Symbol(),OP_BUY,lot)>0)
           {
            Print("Order not opened because there's not enough money to buy "+DoubleToStr(lot,2)+" lots, try to lower the volume, error: ="+(string)GetLastError());
            return;
           }

          
            double price = pr + mp*_Point*5;
            
            if(StopLoss!=0)
               {
                  sl = price-StopLoss *mp* Point();
                  sl=NormalizeDouble (sl, Digits);
                  if(sl > price-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point())
                  sl = price-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point();
               }
                  
            if(TakeProfit!=0)
              {
                  tp = price+TakeProfit*mp*Point(); 
                  tp=NormalizeDouble (tp, Digits); 
                  if(tp < price+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point())
                  tp = price+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point();
              }
         
            
            
            ticket=OrderSend(Symbol(),OP_BUYSTOP,lot,price,(int)Slippage,sl,tp,comment,Magic,0,arrowColor);
            if(ticket<0)Print("Order Buy trade failed: ",err_msg(GetLastError()));
            
         
         
        
         
       
         
         tries_main++;
         if(tries_main>10)break;
        }
 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OpenSell(double pr)
  {

 
  
 double sl=0;
 double tp=0;
 double lot=0;

 RefreshRates();
   
    
   int ticket=0,tries=0;
  
      int tries_main=0;
      while(ticket<=0)
        {
         RefreshRates();
        

         if(GetSpread()> MaxSpread && MaxSpread !=0)
           {
            Print("Order not opened because spread ("+(string)(GetSpread())+") is higher than max allowed spread ("+(string)MaxSpread);
            return;
           }

         
         color arrowColor=clrLimeGreen;
         if(!ShowArrows)arrowColor=clrNONE;
            
         lot=GetLots();
         if(lot <= 0){Print("Calculated Lot Size <= 0");return;}   
            
            if(!AccountFreeMarginCheck(Symbol(),OP_SELL,lot)>0)
           {
            Print("Order not opened because there's not enough money to buy "+DoubleToStr(lot,2)+" lots, try to lower the volume, error: "+(string)GetLastError());
           return;
           }
            
            double price = pr - mp*_Point*5;
            
            if(StopLoss!=0)
              {
                sl = price + StopLoss*mp * Point();
                sl=NormalizeDouble (sl, Digits);
                
                if(sl < price+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point())
                sl = price+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point();
             }
               
                                  
             if(TakeProfit!=0)
               {
                  tp = price - TakeProfit*mp * Point(); 
                  tp=NormalizeDouble (tp, Digits); 
                  if(tp > price-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point())
                  tp = price-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point();
                }        
       
            ticket=OrderSend(Symbol(),OP_SELLSTOP,lot,price,(int)Slippage,sl,tp,comment,Magic,0,arrowColor);
            if(ticket<0)Print("Order Buy trade failed: ",err_msg(GetLastError()));
          
            
      
         tries_main++;
         if(tries_main>10)break;
        }

  }


double GetLots ()
{
  double lotSize=0;
           
         if (Lot_type == Risk_Percent) 
              { lotSize = AccountEquity() * EquityStop/100 / ( StopLoss * mp * MarketInfo( Symbol(), MODE_TICKVALUE ) );}
         
         else if (Lot_type == Fixed_Lot) {lotSize = LotSize;}
         
         double lotsStep = MarketInfo(Symbol(), MODE_LOTSTEP);
         double minLots = MarketInfo(Symbol(), MODE_MINLOT);
         double maxLots = MarketInfo(Symbol(), MODE_MAXLOT);
         lotSize = MathRound (lotSize / lotsStep) * lotsStep;
         lotSize = MathMax (minLots, lotSize);
         lotSize = MathMin (maxLots, lotSize);
         
         
   return lotSize;
}

//Alert



bool NewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return(false);
   }
}

double GetSpread()
  {
   RefreshRates();
 
   double poit=point();
   double spred=(int)MarketInfo(Symbol(),MODE_SPREAD);
          
   /**
   double mul = 1;
   if(poit==0.00001 || poit==0.001)
     {
        mul = 10;
     }
   
   if(StringFind(Symbol(),"XAU")==0)
     {
       mul = 1;
     }

   if(StringFind(Symbol(),"XAG")==0)
     {
       mul = 0.1;
     }

   if(MarketInfo(Symbol(),MODE_BID)>1000)
     {
       mul = 1;
     }
   
  return (spred / mul);**/
  return (spred);
   
  }



void GetPoint()
  {
   RefreshRates();
 
   double poit=MarketInfo(Symbol(),MODE_POINT);
  
          
   if(poit==0.00001 || poit==0.001)
     {
        mp = 10;
     }
   
   if(StringFind(Symbol(),"XAU")==0)
     {
       mp = 1;
     }

   if(StringFind(Symbol(),"XAG")==0)
     {
       mp = 0.1;
     }

   if(MarketInfo(Symbol(),MODE_BID)>1000)
     {
       mp = 1;
     }
   
  }
  


     
          
  

int digits(){return((int)MarketInfo(Symbol(),MODE_DIGITS));}
//--- point size
double point(){return(MarketInfo(Symbol(),MODE_POINT));}
//--- ask price
double ask(){return(MarketInfo(Symbol(),MODE_ASK));}
//--- bid price
double bid(){return(MarketInfo(Symbol(),MODE_BID));}
//--- spread
int spread(){return((int)MarketInfo(Symbol(),MODE_SPREAD));}
//--- stop level
int stlevel(){return((int)MarketInfo(Symbol(),MODE_STOPLEVEL));}
//--- max lot
double maxlot(){return(MarketInfo(Symbol(),MODE_MAXLOT));}
//--- min lot
double minlot(){return(MarketInfo(Symbol(),MODE_MINLOT));}
//---lot step
double lotsteps(){return(MarketInfo(Symbol(),MODE_LOTSTEP));}
//--lot size
double lotsize(){return(MarketInfo(Symbol(),MODE_LOTSIZE));}
//--price per lot
double tickvalue(){return(MarketInfo(Symbol(),MODE_TICKVALUE));}


string err_msg(int e)
//+------------------------------------------------------------------+
// Returns error message text for a given MQL4 error number
// Usage:   string s=err_msg(146) returns s="Error 0146:  Trade context is busy."
  {
   switch(e)
     {
      case 0:
         return("Error 0000:  No error returned.");
      case 1:
         return("Error 0001:  No error returned, but the result is unknown.");
      case 2:
         return("Error 0002:  Common error.");
      case 3:
         return("Error 0003:  Invalid trade parameters.");
      case 4:
         return("Error 0004:  Trade server is busy.");
      case 5:
         return("Error 0005:  Old version of the client terminal.");
      case 6:
         return("Error 0006:  No connection with trade server.");
      case 7:
         return("Error 0007:  Not enough rights.");
      case 8:
         return("Error 0008:  Too frequent requests.");
      case 9:
         return("Error 0009:  Malfunctional trade operation.");
      case 64:
         return("Error 0064:  Account disabled.");
      case 65:
         return("Error 0065:  Invalid account.");
      case 128:
         return("Error 0128:  Trade timeout.");
      case 129:
         return("Error 0129:  Invalid price.");
      case 130:
         return("Error 0130:  Invalid stops.");
      case 131:
         return("Error 0131:  Invalid trade volume.");
      case 132:
         return("Error 0132:  Market is closed.");
      case 133:
         return("Error 0133:  Trade is disabled.");
      case 134:
         return("Error 0134:  Not enough money.");
      case 135:
         return("Error 0135:  Price changed.");
      case 136:
         return("Error 0136:  Off quotes.");
      case 137:
         return("Error 0137:  Broker is busy.");
      case 138:
         return("Error 0138:  Requote.");
      case 139:
         return("Error 0139:  Order is locked.");
      case 140:
         return("Error 0140:  Long positions only allowed.");
      case 141:
         return("Error 0141:  Too many requests.");
      case 145:
         return("Error 0145:  Modification denied because order too close to market.");
      case 146:
         return("Error 0146:  Trade context is busy.");
      case 147:
         return("Error 0147:  Expirations are denied by broker.");
      case 148:
         return("Error 0148:  The amount of open and pending orders has reached the limit set by the broker.");
      case 149:
         return("Error 0149:  An attempt to open a position opposite to the existing one when hedging is disabled.");
      case 150:
         return("Error 0150:  An attempt to close a position contravening the FIFO rule.");
      case 4000:
         return("Error 4000:  No error.");
      case 4001:
         return("Error 4001:  Wrong function pointer.");
      case 4002:
         return("Error 4002:  Array index is out of range.");
      case 4003:
         return("Error 4003:  No memory for function call stack.");
      case 4004:
         return("Error 4004:  Recursive stack overflow.");
      case 4005:
         return("Error 4005:  Not enough stack for parameter.");
      case 4006:
         return("Error 4006:  No memory for parameter string.");
      case 4007:
         return("Error 4007:  No memory for temp string.");
      case 4008:
         return("Error 4008:  Not initialized string.");
      case 4009:
         return("Error 4009:  Not initialized string in array.");
      case 4010:
         return("Error 4010:  No memory for array string.");
      case 4011:
         return("Error 4011:  Too long string.");
      case 4012:
         return("Error 4012:  Remainder from zero divide.");
      case 4013:
         return("Error 4013:  Zero divide.");
      case 4014:
         return("Error 4014:  Unknown command.");
      case 4015:
         return("Error 4015:  Wrong jump (never generated error).");
      case 4016:
         return("Error 4016:  Not initialized array.");
      case 4017:
         return("Error 4017:  DLL calls are not allowed.");
      case 4018:
         return("Error 4018:  Cannot load library.");
      case 4019:
         return("Error 4019:  Cannot call function.");
      case 4020:
         return("Error 4020:  Expert function calls are not allowed.");
      case 4021:
         return("Error 4021:  Not enough memory for temp string returned from function.");
      case 4022:
         return("Error 4022:  System is busy (never generated error).");
      case 4050:
         return("Error 4050:  Invalid function parameters count.");
      case 4051:
         return("Error 4051:  Invalid function parameter value.");
      case 4052:
         return("Error 4052:  String function internal error.");
      case 4053:
         return("Error 4053:  Some array error.");
      case 4054:
         return("Error 4054:  Incorrect series array using.");
      case 4055:
         return("Error 4055:  Custom indicator error.");
      case 4056:
         return("Error 4056:  Arrays are incompatible.");
      case 4057:
         return("Error 4057:  Global variables processing error.");
      case 4058:
         return("Error 4058:  Global variable not found.");
      case 4059:
         return("Error 4059:  Function is not allowed in testing mode.");
      case 4060:
         return("Error 4060:  Function is not confirmed.");
      case 4061:
         return("Error 4061:  Send mail error.");
      case 4062:
         return("Error 4062:  String parameter expected.");
      case 4063:
         return("Error 4063:  Integer parameter expected.");
      case 4064:
         return("Error 4064:  Double parameter expected.");
      case 4065:
         return("Error 4065:  Array as parameter expected.");
      case 4066:
         return("Error 4066:  Requested history data in updating state.");
      case 4067:
         return("Error 4067:  Some error in trading function.");
      case 4099:
         return("Error 4099:  End of file.");
      case 4100:
         return("Error 4100:  Some file error.");
      case 4101:
         return("Error 4101:  Wrong file name.");
      case 4102:
         return("Error 4102:  Too many opened files.");
      case 4103:
         return("Error 4103:  Cannot open file.");
      case 4104:
         return("Error 4104:  Incompatible access to a file.");
      case 4105:
         return("Error 4105:  No order selected.");
      case 4106:
         return("Error 4106:  Unknown symbol.");
      case 4107:
         return("Error 4107:  Invalid price.");
      case 4108:
         return("Error 4108:  Invalid ticket.");
      case 4109:
         return("Error 4109:  Trade is not allowed. Enable checkbox 'Allow live trading' in the expert properties.");
      case 4110:
         return("Error 4110:  Longs are not allowed. Check the expert properties.");
      case 4111:
         return("Error 4111:  Shorts are not allowed. Check the expert properties.");
      case 4200:
         return("Error 4200:  Object exists already.");
      case 4201:
         return("Error 4201:  Unknown object property.");
      case 4202:
         return("Error 4202:  Object does not exist.");
      case 4203:
         return("Error 4203:  Unknown object type.");
      case 4204:
         return("Error 4204:  No object name.");
      case 4205:
         return("Error 4205:  Object coordinates error.");
      case 4206:
         return("Error 4206:  No specified subwindow.");
      case 4207:
         return("Error 4207:  Some error in object function.");
      //    case 9001:  return("Error 9001:  Cannot close entire order - insufficient volume previously open.");
      //    case 9002:  return("Error 9002:  Incorrect net position.");
      //    case 9003:  return("Error 9003:  Orders not completed correctly - details in log file.");
      default:
         return("Error " + IntegerToString(OrderTicket()) + ": ??? Unknown error.");
     }
   return("n/a");
  }


	

   