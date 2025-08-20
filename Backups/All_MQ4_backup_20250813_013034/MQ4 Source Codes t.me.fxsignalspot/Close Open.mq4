//+------------------------------------------------------------------+
//|                                               Close Pendings.mq4 |
//|                                                            Marco |
//|                                       sirhedgehogmusic@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Marco"
#property link      "sirhedgehogmusic@gmail.com"
#property version   "1.00"
#property strict

extern string Text="Closing Active";            //Loading Text

int Slippage = 10;
double DropPoint;
bool FocusPair;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _ErrorCheck;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string strTmp=Text;
   
// retrieve DropPoint
   DropPoint=WindowPriceOnDropped();

// if dropped on pair window will close all pendings of that pair, else will close all
   if(DropPoint==0)
      FocusPair=false;
   else
      FocusPair=true;

// start for to close pendings
   int total=OrdersTotal();

   if(total>0)
     {
      for(int i=total-1;i>=0;i--)
        {
        DrawLabel(strTmp);
         strTmp+=".";
         if(StringLen(strTmp)>=StringLen(Text)+6)
            strTmp=Text;
            
         _ErrorCheck=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

         // Error Check
         if(_ErrorCheck==-1)
           {
            Alert("Error Order Select: ",GetLastError());
            break;
           }

         //if pair is not equal to dropped pair

         // check if its a limit
         if((OrderType()==OP_BUY || OrderType()==OP_SELL))  //Profit >= 0 ??
           {
            _ErrorCheck=0;

            for(int l=0; l<5; l++)
              {
               //if pair is not equal to dropped pair
               if(FocusPair && Symbol()!=OrderSymbol())
                  break;

               // delete
               if(OrderType()==OP_SELL)
                  _ErrorCheck=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(), MODE_ASK),Slippage,clrNONE);
               else
                  _ErrorCheck=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(), MODE_BID),Slippage,clrNONE);
                  
               // error check
               if(_ErrorCheck==-1)
                  Sleep(100);
               else
                  break;
              }

            if(_ErrorCheck==-1)
              {
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
                     _ErrorComment="ERR_INVALID_STOPS";
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

               Alert("ErrorTrade: ",_ErrorCheck," ErrorNumber: ",GetLastError(),"ErrorDescr: ",_ErrorComment);
              }
           }
        }
     }
     DeleteLabel();
     PlaySound("coin.wav");
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