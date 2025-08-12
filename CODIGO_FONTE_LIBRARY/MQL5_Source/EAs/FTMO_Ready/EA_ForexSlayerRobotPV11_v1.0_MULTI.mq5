//+------------------------------------------------------------------+
//|                                            Punch_Back_System.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Forex market killer."
#property link      "https://forexmarketkilller.com"
#property version   "1"

#include <Trade\Trade.mqh>
CTrade trade;

string diraction  ="NONE"; 
bool equit = false;
double TOP,LOW,SEVEN5,TWEN5,SL,TP,poits=3;


input string _LICENCE_KEY = "XXX-XXX-XXX-XXX";
input double Volume =0.01;
input int Positions_to_open = 1;
input int start=0,end=10;
int slippage = 6;
int TP_SL_RATIO = 1;
bool SHOW_LEVELS = true;


double curr_ball = AccountInfoDouble(ACCOUNT_BALANCE);
double total_profit = 0;
double buy_take_profit, sell_take_profit;

int OnInit()
  {
   string url = "https://licence.forexmarketkiller.com/";
   string eaa = "Forex Slayer Robot PV1.10";
   string phone ="+27 76 661 1154";
   login(url,eaa,_LICENCE_KEY,phone);
   
   ObjectsDeleteAll(0,-1,-1);
   
    int Highest;
   double High[];
   MqlRates PriceInfo[];
   
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(PriceInfo,true);
   
   CopyHigh(_Symbol,_Period,start,end,High);
   CopyRates(_Symbol,_Period,0,Bars(_Symbol,_Period),PriceInfo);
   
   Highest = ArrayMaximum(High,start,end);
   
  ObjectCreate(_Symbol,"Highest",OBJ_HLINE,0,0,PriceInfo[Highest].high);
  ObjectSetInteger(0,"Highest",OBJPROP_COLOR,clrBlue);
  ObjectSetInteger(0,"Highest",OBJPROP_WIDTH,1);
  
  int Lowest;
   double Low[];
   MqlRates PriceInfo2[];
   
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(PriceInfo2,true);
   
   CopyLow(_Symbol,_Period,start,end,Low);
   CopyRates(_Symbol,_Period,0,Bars(_Symbol,_Period),PriceInfo2);
   
   Lowest = ArrayMinimum(Low,start,end);
   
  ObjectCreate(_Symbol,"Lowest",OBJ_HLINE,0,0,iLow(_Symbol,_Period,Lowest));
  ObjectSetInteger(0,"Lowest",OBJPROP_COLOR,clrBlue);
  ObjectSetInteger(0,"Lowest",OBJPROP_WIDTH,1);
  
  double Mid = iHigh(_Symbol,_Period,Highest)-(0.5*(iHigh(_Symbol,_Period,Highest)-iLow(_Symbol,_Period,Lowest)));
   ObjectCreate(_Symbol,"Middle",OBJ_HLINE,0,0,Mid);
  ObjectSetInteger(0,"Middle",OBJPROP_COLOR,clrAqua);
  ObjectSetInteger(0,"Middle",OBJPROP_WIDTH,1);
  
  int Downpoint1,Downpoint2; 
   double tHigh[];
   
   ArraySetAsSeries(tHigh,true);
   CopyHigh(_Symbol,_Period,start,end,tHigh);
   
   
   Downpoint1 = ArrayMaximum(tHigh,start,end);
   tHigh[Downpoint1] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   tHigh[ArrayMaximum(tHigh,start,end)] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   Downpoint2 = ArrayMaximum(tHigh,start,end);
   
   
   ObjectCreate(_Symbol,"DownTline",OBJ_TREND,0,iTime(_Symbol,_Period,Highest),iHigh(_Symbol,_Period,Highest),iTime(_Symbol,_Period,Downpoint2),iHigh(_Symbol,_Period,Downpoint2));
   ObjectSetInteger(0,"DownTline",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"DownTline",OBJPROP_WIDTH,2);
   
   int Uppoint1,Uppoint2; 
   double tLow[];
   
   ArraySetAsSeries(tLow,true);
   CopyLow(_Symbol,_Period,start,end,tLow);
   
   
   Uppoint1 = ArrayMinimum(tLow,start,end);
   tLow[Uppoint1] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   tLow[ArrayMinimum(tLow,start,end)] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   Uppoint2 = ArrayMinimum(tLow,start,end);
   
   
   ObjectCreate(_Symbol,"UpTline",OBJ_TREND,0,iTime(_Symbol,_Period,Lowest),iLow(_Symbol,_Period,Lowest),iTime(_Symbol,_Period,Uppoint2),iLow(_Symbol,_Period,Uppoint2));
   ObjectSetInteger(0,"UpTline",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"UpTline",OBJPROP_WIDTH,2);
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,-1,-1);
}

void OnTick()
  {
    
      total_profit = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)-curr_ball,2);
      
      double Price = DrawObjects();
   
   
   
   if(OrdersTotal() ==0 && PositionsTotal() == 0 && isNewCandle1M() == true)
   {
      if(diraction =="BUY")
      {
         diraction = "NONE";
         double Ask = NormalizeDouble(Price,_Digits);
         SL = NormalizeDouble(TOP,_Digits);
         for(int ob=0;ob< Positions_to_open;ob++){
        // bool orderBuy = trade.BuyStop(Volume,Ask,NULL,SL,TOP,0,0,NULL); 
         bool orderSell = trade.SellLimit(Volume,Ask,NULL,SL,LOW+poits*_Point,0,0,NULL);}
      }
      if(diraction =="SELL")
      {
         diraction = "NONE";
         double Bid = NormalizeDouble(Price,_Digits);
         SL = NormalizeDouble(LOW,_Digits);
         for(int os=0;os< Positions_to_open;os++){
        // bool orderSell = trade.SellStop(Volume,Bid,NULL,SL,LOW,0,0,NULL);
         bool orderBuy = trade.BuyLimit(Volume,Bid,NULL,SL,TOP-poits*_Point,0,0,NULL);}  
      }
   }
   if(OrdersTotal() > 0)
   {
      for(int i = 0;i<OrdersTotal();i++)
      {
         int tkt = OrderGetTicket(i);
         
         if(OrderGetDouble(ORDER_PRICE_OPEN)  != NormalizeDouble(Price,_Digits))
         {
            if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT)
            {
               SL = NormalizeDouble(TWEN5,_Digits);
               trade.OrderModify(tkt,NormalizeDouble(Price,_Digits),SL,TOP-poits*_Point,NULL,0,0);
            }
            if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT)
            {
               SL = NormalizeDouble(SEVEN5,_Digits);
               trade.OrderModify(tkt,NormalizeDouble(Price,_Digits),SL,LOW+poits*_Point,NULL,0,0);
            }
         }
         
         if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP||OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP)
         {
            if(PositionsTotal()==0)
               trade.OrderDelete(tkt);
         }
      }
    
   }
   if(PositionsTotal() > 0)
   {
      for(int i = 0;i<PositionsTotal();i++)
      {
         int tktt = PositionGetTicket(i);
         if(equity()==true)
         {
            SL = PositionGetDouble(POSITION_PRICE_OPEN);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_SL) < PositionGetDouble(POSITION_PRICE_OPEN))
             {
               trade.PositionModify(tktt,SL,TOP-poits*_Point);
               bool orderSell2 = trade.SellStop(2*Volume,SL,NULL,SL+10*_Point,SL-5*_Point,0,0,NULL); 
             }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_SL) > PositionGetDouble(POSITION_PRICE_OPEN))
             {
               trade.PositionModify(tktt,SL,LOW+poits*_Point);
               bool orderBuy2 = trade.BuyStop(2*Volume,SL,NULL,SL-10*_Point,SL+5*_Point,0,0,NULL); 
             }
               
         } 
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && equit==true)
         {
           SL= NormalizeDouble(PositionGetDouble(POSITION_SL)+10*_Point,_Digits);
           trade.PositionModify(tktt,SL,PositionGetDouble(POSITION_TP));
           equit = false;
         }
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && equit==true)
         {
           SL= NormalizeDouble(PositionGetDouble(POSITION_SL)-10*_Point,_Digits);
           trade.PositionModify(tktt,SL,PositionGetDouble(POSITION_TP));
           equit = false;
         } 
      }
      
   }
   
   
   /*if(PositionsTotal()==0 && Profit() <0  )
   {
      if(HistorySelect(0, INT_MAX))
      {
        const ulong Ticket = HistoryDealGetTicket(HistoryDealsTotal() - 1);
        
        if(HistoryDealGetString(Ticket, DEAL_SYMBOL) == Symbol())
        {   
            if(HistoryDealGetInteger(Ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
            {
            
               SL = NormalizeDouble(SEVEN5,_Digits);
              double Bid1 = NormalizeDouble(SYMBOL_BID,_Digits);
              bool orderSell3 = trade.Sell(Volume,_Symbol,Bid1,SL,LOW+poits*_Point,NULL); 
            }
            if(HistoryDealGetInteger(Ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
            {
               SL = NormalizeDouble(TWEN5,_Digits);
               double Ask1 = NormalizeDouble(SYMBOL_ASK,_Digits);
              bool orderBuy3 = trade.Buy(Volume,_Symbol,Ask1,SL,TOP-poits*_Point,NULL);
            }
        }
      }
   }*/
      
      drawLabel();
   
  }
  
  double DrawObjects()
{
   static double prevHigh,newHigh,prevLow,newLow;
   int Highest;
   double High[];
   
   int Lowest;
   double Low[];
   
   ArraySetAsSeries(Low,true);
   
   ArraySetAsSeries(High,true);
   
   CopyHigh(_Symbol,_Period,start,end,High);
   
   Highest = ArrayMaximum(High,start,end);
   
   CopyLow(_Symbol,_Period,start,end,Low);
   Lowest = ArrayMinimum(Low,start,end);
   double Mid = iHigh(_Symbol,_Period,Highest)-(0.5*(iHigh(_Symbol,_Period,Highest)-iLow(_Symbol,_Period,Lowest)));
   double Seven5 = iHigh(_Symbol,_Period,Highest)-(0.25*(iHigh(_Symbol,_Period,Highest)-iLow(_Symbol,_Period,Lowest)));
   double Twen5 = iHigh(_Symbol,_Period,Highest)-(0.75*(iHigh(_Symbol,_Period,Highest)-iLow(_Symbol,_Period,Lowest)));
   if(newHigh != iHigh(_Symbol,_Period,Highest))
   {
      prevHigh = newHigh;
      newHigh = iHigh(_Symbol,_Period,Highest);
      
      ObjectMove(_Symbol,"Highest",0,0,iHigh(_Symbol,_Period,Highest));
      ObjectMove(_Symbol,"Lowest",0,0,iLow(_Symbol,_Period,Lowest));
      ObjectMove(_Symbol,"Middle",0,0,Mid); 
   }
   
   if(newLow != iLow(_Symbol,_Period,Lowest))
   {
      prevLow = newLow;
      newLow = iLow(_Symbol,_Period,Lowest);
      
      ObjectMove(_Symbol,"Highest",0,0,iHigh(_Symbol,_Period,Highest));
      ObjectMove(_Symbol,"Lowest",0,0,iLow(_Symbol,_Period,Lowest));
      ObjectMove(_Symbol,"Middle",0,0,Mid); 
   }
   int Downpoint1,Downpoint2; 
   double tHigh[];
   
   ArraySetAsSeries(tHigh,true);
   CopyHigh(_Symbol,_Period,start,end,tHigh);
   
   
   Downpoint1 = ArrayMaximum(tHigh,start,end);
   tHigh[Downpoint1] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   tHigh[ArrayMaximum(tHigh,start,end)] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   Downpoint2 = ArrayMaximum(tHigh,start,end);
   
   
   int Uppoint1,Uppoint2; 
   double tLow[];
   
   ArraySetAsSeries(tLow,true);
   CopyLow(_Symbol,_Period,start,end,tLow);
   
   
   Uppoint1 = ArrayMinimum(tLow,start,end);
   tLow[Uppoint1] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   tLow[ArrayMinimum(tLow,start,end)] =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   Uppoint2 = ArrayMinimum(tLow,start,end);
   
   if(Uppoint1 > Uppoint2)
   {
      ObjectMove(_Symbol,"UpTline",0,iTime(_Symbol,_Period,Lowest),iLow(_Symbol,_Period,Lowest));
      ObjectMove(_Symbol,"UpTline",1,iTime(_Symbol,_Period,Uppoint2),iLow(_Symbol,_Period,Uppoint2));
   }
   
   if(Downpoint1>Downpoint2)
   {
      ObjectMove(_Symbol,"DownTline",0,iTime(_Symbol,_Period,Highest),iHigh(_Symbol,_Period,Highest));
      ObjectMove(_Symbol,"DownTline",1,iTime(_Symbol,_Period,Downpoint2),iHigh(_Symbol,_Period,Downpoint2));
   }
   
   
      
   if(iLow(_Symbol,_Period,1) == newLow && isNewCandle1M()==true && PositionsTotal()== 0) diraction = "BUY";
   if(iHigh(_Symbol,_Period,1) == newHigh && isNewCandle1M()==true&& PositionsTotal()== 0 )diraction = "SELL";

   TOP= NormalizeDouble(newHigh,_Digits);
   LOW = NormalizeDouble(newLow,_Digits);
   SEVEN5 = Seven5;
   TWEN5 = Twen5;
   
   return Mid;
}
string equity()
{
   static double pointsmove;
   static bool eqt;
   if(PositionsTotal()== 0)eqt = false;
   if(PositionsTotal() >0)
   {
      if(eqt == false && AccountInfoDouble(ACCOUNT_PROFIT) >= 10*Volume && AccountInfoDouble(ACCOUNT_PROFIT) < 30*Volume)
      {
         pointsmove = 0;
         eqt = true;
      }
      if(AccountInfoDouble(ACCOUNT_PROFIT) >= (pointsmove+20)*Volume )
      {
         pointsmove +=10;
         equit = true;
      }
   }
   
   
   return eqt;
}
bool isNewCandle1M()
{
   MqlRates PriceData[];
   ArraySetAsSeries(PriceData,true);
   CopyRates(_Symbol,PERIOD_M1,0,3,PriceData);
   static int candlecounter;
   static datetime lasDatetime;
   static int CurrDatetime;
   
   CurrDatetime = PriceData[0].time;
   
   if(CurrDatetime != lasDatetime)
   {
      candlecounter++;
      lasDatetime = CurrDatetime;
      if(candlecounter==1)
      {
         candlecounter=0;
         return true;
       }
   }
    
   return false;  
}
double Profit( void )
{
 double Res = 0;

 if (HistorySelect(0, INT_MAX))
   //for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
     const ulong Ticket = HistoryDealGetTicket(HistoryDealsTotal() - 1);
     
     if((HistoryDealGetString(Ticket, DEAL_SYMBOL) == Symbol()))
       Res = HistoryDealGetDouble(Ticket, DEAL_PROFIT);
   }
     
  return(Res);
}

string C_MACD()
{
   double MACDarr[];
   double MACDSignalarr[];
   
   int my_macd = iCustom(_Symbol,_Period,"rsi-of-macd-double-indikator.ex5");
   
   ArraySetAsSeries(MACDSignalarr,true);
   ArraySetAsSeries(MACDarr,true);
   
   CopyBuffer(my_macd,0,0,5,MACDarr);
   CopyBuffer(my_macd,1,0,5,MACDSignalarr);
   
   if(MACDSignalarr[0] > MACDarr[0] )return "BUY";
   if(MACDSignalarr[0] < MACDarr[0] )return "SELL";
   
   return "HOLD";
   
}

string C_supres()
{
   static bool BUY, SELL;
   double buff4[];
   double buff5[];
   double buff6[];
   double buff7[];
   
   int my_supres = iCustom(_Symbol,_Period,"Shved supply and demand.ex5");
   
   ArraySetAsSeries(buff4,true);
   ArraySetAsSeries(buff5,true);
   ArraySetAsSeries(buff6,true);
   ArraySetAsSeries(buff7,true);
   
   
   CopyBuffer(my_supres,4,0,5,buff4);
   CopyBuffer(my_supres,5,0,5,buff5);
   CopyBuffer(my_supres,6,0,5,buff6);
   CopyBuffer(my_supres,7,0,5,buff7);

   buy_take_profit = buff5[0];
   sell_take_profit = buff6[0];
   
   if(iHigh(_Symbol,_Period,1) < buff4[1] && iHigh(_Symbol,_Period,1) > buff5[1] )
   {
      BUY = false;
      SELL = true;
      
   }
   if(iLow(_Symbol,_Period,1) < buff6[1] && iLow(_Symbol,_Period,1) > buff7[1])
   {
      BUY = true;
      SELL = false;
   }
   
   if(iClose(_Symbol,_Period,0) < buff4[0] && SELL == true)return "SELL";
   if(iClose(_Symbol,_Period,0) > buff7[0] && BUY == true )return "BUY";
   
   
   return false;
}

string C_star()
{
   double sup[];
   
  int my_star = iCustom(_Symbol,_Period,"non-repaint star Alternative.ex5");
 
   
   ArraySetAsSeries(sup,true);
   
   CopyBuffer(my_star,3,0,5,sup);
   
   if(sup[0] == 0.0 && sup[1] == 1.0) return "BUY";
   if(sup[1] == 0.0 && sup[0] == 1.0) return "SELL";

   
   return "HOLD";
}
bool isNewCandle()
{
   MqlRates PriceData[];
   ArraySetAsSeries(PriceData,true);
   CopyRates(_Symbol,_Period,0,3,PriceData);
   static int candlecounter;
   static datetime lasDatetime;
   static int CurrDatetime;
   
   CurrDatetime = PriceData[0].time;
   
   if(CurrDatetime != lasDatetime)
   {
      candlecounter++;
      lasDatetime = CurrDatetime;
      //if(candlecounter==1)
      {
         candlecounter=0;
         return true;
       }
   }
    
   return false;  
}

void drawLabel()
{
   color clr = clrBlue;
   if(AccountInfoDouble(ACCOUNT_PROFIT) >0 ) clr = clrGreen;
   if(AccountInfoDouble(ACCOUNT_PROFIT) < 0) clr = clrRed;
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   
   static color topclr = clrWhite;
   if(topclr == clrWhite)topclr = clrAliceBlue;
   else if(topclr == clrAliceBlue)topclr = clrRed;
   else if(topclr == clrRed)topclr = clrGreen;
   else if(topclr == clrGreen)topclr = clrBlueViolet;
   else if(topclr == clrBlueViolet)topclr = clrPurple;
   else if(topclr == clrPurple)topclr = clrPink;
   else if(topclr == clrPink)topclr = clrBrown;
   else if(topclr == clrBrown)topclr = clrWhite;
   
   string name = "__Forex Slayer Robot PV1.10__";
   string licence = _LICENCE_KEY;
   string ballance = AccountInfoDouble(ACCOUNT_BALANCE);
   string lotsize = Volume;
   string slippage_ = slippage;
   string Tpsa_ratio = TP_SL_RATIO;
   string Openpos = OrdersTotal();
   string Profit = NormalizeDouble(AccountInfoDouble(ACCOUNT_PROFIT),2);
   double prof = total_profit;
   
   
   ObjectCreate(0,"HEADER",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,"HEADER",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"HEADER",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"HEADER",OBJPROP_YDISTANCE,15);
   ObjectSetInteger(0,"HEADER",OBJPROP_XSIZE,260);
   ObjectSetInteger(0,"HEADER",OBJPROP_YSIZE,30);
   ObjectSetInteger(0,"HEADER",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"HEADER",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,"HEADER",OBJPROP_BGCOLOR,clrBlack);
   ObjectCreate(0,"infoname",OBJ_LABEL,0,0,0);
   //ObjectSetString(0,"infoname",name,OBJ_TEXT,15,"Impact",topclr);
   ObjectSetString(0,"infoname",OBJPROP_TEXT,name);
   ObjectSetString(0,"infoname",OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,"infoname",OBJPROP_FONTSIZE,15);
   ObjectSetInteger(0,"infoname",OBJPROP_COLOR,topclr);
   ObjectSetInteger(0,"infoname",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"infoname",OBJPROP_YDISTANCE,15);
   
   //Main Panel  
   ObjectCreate(0,"MAIN",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,"MAIN",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"MAIN",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"MAIN",OBJPROP_YDISTANCE,49);
   ObjectSetInteger(0,"MAIN",OBJPROP_XSIZE,260);
   ObjectSetInteger(0,"MAIN",OBJPROP_YSIZE,300);
   ObjectSetInteger(0,"MAIN",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"MAIN",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,"MAIN",OBJPROP_BGCOLOR,clr);
   
   make_detail("licence","LICENCE ========> "+licence,59,clrWhite);
   make_detail("lot",    "LOT_SIZE =======> "+lotsize,79,clrWhite);
   make_detail("slip",   "SLIPPAGE =======> "+slippage_,99,clrWhite);
   make_detail("rat",    "TP_SL_RATION ===> "+Tpsa_ratio,119,clrWhite);
   
   make_detail("bal",    "BALLANCE =======> "+ballance,149,clrWhite);
   make_detail("opp",    "OPEN POSITIONS ==> "+Openpos,169,clrWhite);
   make_detail("profit", "PROFIT =========> "+Profit,189,clrWhite);
   
   color yy = clrWhite;
   if(prof > 0)yy = clrGreen;
   if(prof < 0)yy = clrRed;
   make_detail("net",    "TOTAL_PROFIT ===> "+prof,209,yy);
}
void make_detail(string name,string txt,int y,color clr)
{

   ObjectDelete(1,name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
  
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetString(0,name,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
}

void login(string url,string ea,string Key,string phone)
{
   string pc_allowed = "not";
   
   if(FileIsExist(Key+".csv",0) == true)
   {
      pc_allowed ="yes";
   }
   
   string cookie=NULL,headers;
   char post[],result[];
   int res;
   string urlm=url+"auth.php?key="+Key+"&ea="+ea+"&pcallowed="+pc_allowed;
   ResetLastError();
   int timeout=5000;
   
   res=WebRequest("GET",urlm,cookie,NULL,timeout,post,0,result,headers);

   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      MessageBox("Add the address '"+url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
      ExpertRemove();
     }
   else
     {
  
         switch(res){
            case 404:
               MessageBox("INVALID URL PLEASE CONTACT ADMIN. OR SELLER","Error",MB_ICONINFORMATION);
               ExpertRemove();
            break;
            case 503:
               MessageBox("Error due to Internet connection! Please try again","Error",MB_ICONINFORMATION);
               ExpertRemove();
            break;
            case 403:
               MessageBox("The Licence Key is expired, please contact admin @"+phone+" for reactivation.","Error",MB_ICONINFORMATION);
               ExpertRemove();
            break;
            case 406:
               MessageBox("The Licence Key is alredy used in another computer, please contact admin @"+phone+" for another key.","Error",MB_ICONINFORMATION);
               ExpertRemove();
            break;
            case 203:
               MessageBox("The Licence Key is Invalid, please contact admin @"+phone+" for a valid Key.","Error",MB_ICONINFORMATION);
               ExpertRemove();
            break;
            case 202:
               FileOpen(Key+".csv",FILE_WRITE|FILE_CSV);
               printf("SUCCESSFULLY LOGED IN___");
            break;
            default:
               MessageBox("Unknown EROOR occored please try again","Error",MB_ICONINFORMATION);
               ExpertRemove();
         }
     }
}
