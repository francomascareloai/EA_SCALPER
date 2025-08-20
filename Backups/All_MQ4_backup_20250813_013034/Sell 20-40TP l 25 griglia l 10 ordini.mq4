//+------------------------------------------------------------------+
//|                                                      B - new.mq4 |
//|                                                            Marco |
//|                                       sirhedgehogmusic@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Marco"
#property link      "sirhedgehogmusic@gmail.com"
#property version   "1.00"
#property strict

#define MAGICMA  1337

int CheckError=0;
bool CanSendOrder=true;
int CurrencyDigits=0;
double DropPoint;
int Slippage=10;


int Type;  // Market Buy
int Type2;  // Market Stop

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern double Lots=0.01;
extern double StopLoss=20;
extern double TakeProfit=40;

extern double PipsDistance=2.5;
extern int NTickets=10;

//Aviable values  Hours -> 1/2/3/4/6/8/12   Min -> 1/2/3/5/6/10/12/15/20/30
extern datetime TimeLenght=PERIOD_D1;           //Time Expiration

extern string Comm="Sell Market / Sell Drop";   //Comment
extern string Text="Placing Orders";            //Loading Text
extern color Color=clrNONE;

// Var for erro 130 fix
double _Freeze=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
// retrieve market digits
   CurrencyDigits=MarketInfo(Symbol(),MODE_DIGITS);

   DropPoint=WindowPriceOnDropped();

   if(DropPoint!=0)
     {
      if(DropPoint>Ask)
        {
         Type=OP_SELLLIMIT;
         Type2=OP_SELLLIMIT;
        }
      else
      if(DropPoint<=Ask)
        {
         Type=OP_SELLSTOP;
         Type2=OP_SELLSTOP;
        }
      else
        {
         Alert("Other Error");
         CanSendOrder=false;
        }
     }
   else
     {
      Type=OP_SELL;
      Type2=OP_SELLSTOP;
     }

// normalize sell
   if(DropPoint == 0 )
      DropPoint = Ask;

//Modify Vars

//Aviable values  Hours -> 1/2/3/4/6/8/12   Min -> 1/2/3/5/6/10/12/15/20/30
   datetime _TimeLenght=TimeCurrent()+(TimeLenght*60);

// All pips are calculated automatically, 20 pips are value 20,   you can also use 15.5 pips
//SendOrder ( LIMITTYPE, LOT SIZE, DROPPOINT, DISTANCE FROM DROP, SL, TP, COMMENT, TIME, COLOR )
   double _distdrop=0;
   int _typetmp=Type;

   for(int n=0;n<NTickets;n++)
     {
      DrawLabel(Text);
      SendOrder(_typetmp,Lots,DropPoint,_distdrop,StopLoss,TakeProfit,Comm,_TimeLenght,Color);
      _distdrop+=PipsDistance;
      _typetmp=Type2;
      Text+=".";
     }
     
     DeleteLabel();
     PlaySound("pop.wav");

// ^ this is a consecutive Buy Stop grid, if you double click will enter at the market with first order and all the others
// will be sell stops below the market order.
// you can also drop this script like a Stop order
// if you want to enter the market with 10 trades simultaneously just set to Type and 0 to distance from drop

  }
//+------------------------------------------------------------------+

void SendOrder(int _Type,double _Lots,double _Price,double _Distance,double _StopLoss,double _TakeProfit,string _Comment,datetime _Time,color _Color=clrNONE)
  {
   double _PriceNorm=0;
   double _StopLossNorm=0;
   double _TakeProfitNorm=0;

// error var
   int _error=0;

   for(int i=0; i<10 && CanSendOrder; i++)
     {

      _PriceNorm=NormalizeDouble(_Price -(((_Distance+_Freeze)*10)*Point),CurrencyDigits);
      _StopLossNorm=NormalizeDouble(_PriceNorm+((_StopLoss*10)*Point),CurrencyDigits);
      _TakeProfitNorm=NormalizeDouble(_PriceNorm -((_TakeProfit*10)*Point),CurrencyDigits);

      if(_Type==OP_SELLLIMIT)
        {
         _PriceNorm=NormalizeDouble(_Price+(((_Distance+_Freeze)*10)*Point),CurrencyDigits);
         _StopLossNorm=NormalizeDouble(_PriceNorm+((_StopLoss*10)*Point),CurrencyDigits);
         _TakeProfitNorm=NormalizeDouble(_PriceNorm -((_TakeProfit*10)*Point),CurrencyDigits);
        }

      _error=OrderSend(Symbol(),
                       _Type,
                       _Lots,
                       _PriceNorm,
                       Slippage,
                       _StopLossNorm,
                       _TakeProfitNorm,
                       _Comment,
                       MAGICMA,
                       _Time,
                       _Color);

      if(_error==-1)
        {
         // find error to fix
         int _FixError=GetLastError();

         //if 130 means freeze level or stop are not ok for broker settings
         if(_FixError==130)
           {
               //Fixes minimum stop level of broker
               _Freeze+=2;
           }

         //sleep for server
         Sleep(100);
        }
      else
         break;
     }

   if(_error==-1)
     {
      CanSendOrder=false;

      string _ErrorComment;
      int _LastErrorFound=GetLastError();

      switch(_LastErrorFound)
        {
         case 1:
            _ErrorComment="ERR_NO_RESULT";
            break;
         case 2:
            _ErrorComment="ERR_COMMON_ERROR";
            break;
         case 3:
            _ErrorComment="ERR_INVALID_TRADE_PARAMETERS";
            break;
         case 4:
            _ErrorComment="ERR_SERVER_BUSY";
            break;
         case 5:
            _ErrorComment="ERR_OLD_VERSION";
            break;
         case 6:
            _ErrorComment="ERR_NO_CONNECTION";
            break;
         case 7:
            _ErrorComment="ERR_NOT_ENOUGH_RIGHTS";
            break;
         case 8:
            _ErrorComment="ERR_TOO_FREQUENT_REQUESTS";
            break;
         case 9:
            _ErrorComment="ERR_MALFUNCTIONAL_TRADE";
            break;
         case 64:
            _ErrorComment="ERR_ACCOUNT_DISABLED";
            break;
         case 65:
            _ErrorComment="ERR_INVALID_ACCOUNT";
            break;
         case 128:
            _ErrorComment="ERR_TRADE_TIMEOUT";
            break;
         case 129:
            _ErrorComment="ERR_INVALID_PRICE";
            break;
         case 130:
            _ErrorComment="ERR_INVALID_STOPS, Broker Has Minimum Distance of: "+ DoubleToString(MarketInfo(0,MODE_STOPLEVEL));
            break;
         case 131:
            _ErrorComment="ERR_INVALID_TRADE_VOLUME";
            break;
         case 132:
            _ErrorComment="ERR_MARKET_CLOSED";
            break;
         case 133:
            _ErrorComment="ERR_TRADE_DISABLED";
            break;
         case 134:
            _ErrorComment="ERR_NOT_ENOUGH_MONEY";
            break;
         case 135:
            _ErrorComment="ERR_PRICE_CHANGED";
            break;
         case 136:
            _ErrorComment="ERR_OFF_QUOTES";
            break;
         case 137:
            _ErrorComment="ERR_BROKER_BUSY";
            break;
         case 138:
            _ErrorComment="ERR_REQUOTE";
            break;
         case 139:
            _ErrorComment="ERR_ORDER_LOCKED";
            break;
         case 140:
            _ErrorComment="ERR_LONG_POSITIONS_ONLY_ALLOWED (TESTER PROBLEM, ALLOW SHORT POSITIONS)";
            break;
         case 141:
            _ErrorComment="ERR_TOO_MANY_REQUESTS";
            break;
         case 145:
            _ErrorComment="ERR_TRADE_MODIFY_DENIED";
            break;
         case 146:
            _ErrorComment="ERR_TRADE_CONTEXT_BUSY";
            break;
         case 147:
            _ErrorComment="ERR_TRADE_EXPIRATION_DENIED";
            break;
         case 148:
            _ErrorComment="ERR_TRADE_TOO_MANY_ORDERS";
            break;
         default:
            _ErrorComment="SWITCH_ERROR - CodeError";
            break;
        }

      Alert("ErrorTrade: ",_LastErrorFound," ErrorNumber: ",GetLastError(),"ErrorDescr: ",_ErrorComment);
     }
  }
//+------------------------------------------------------------------+
void DrawLabel(string _Text,int _X=2,int _Y=100,ENUM_BASE_CORNER _Corner=CORNER_LEFT_LOWER,string _FType="Lucida Console",int _FSize=8,color _Col=clrAqua)
  {
   string tooltip="\n";
   color colID=_Col;
   string ID="SCRIPT_DROP";

   ObjectCreate(0,ID,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,ID,OBJPROP_CORNER,_Corner);
   ObjectSetInteger(0,ID,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,ID,OBJPROP_XDISTANCE,_X);
   ObjectSetInteger(0,ID,OBJPROP_YDISTANCE,_Y);
//ObjectSetInteger(0,ID,OBJPROP_XSIZE,CHART_WIDTH_IN_PIXELS-_X);
//ObjectSetInteger(0,ID,OBJPROP_YSIZE,20);

   ObjectSetString(0,ID,OBJPROP_TEXT,_Text);
   ObjectSetInteger(0,ID,OBJPROP_COLOR,colID);
   ObjectSetInteger(0,ID,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,ID,OBJPROP_STATE,true);
   ObjectSetString(0,ID,OBJPROP_FONT,_FType);
   ObjectSetInteger(0,ID,OBJPROP_FONTSIZE,_FSize);
   ObjectSetInteger(0,ID,OBJPROP_SELECTABLE,false);
   ObjectSetString(0,ID,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(0,ID,OBJPROP_BACK,false);
  }
  void DeleteLabel()
  {
   ObjectDelete(0,"SCRIPT_DROP");
  }