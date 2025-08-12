//+------------------------------------------------------------------+
//|                                                DASHBOARD ALL.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mutiiriallan.forex@gmail.com."
#property link      "mutiiriallan.forex@gmail.com"
#property description "Incase of anything with this Version of EA, Contact:\n"
                      "\nEMAIL: mutiiriallan.forex@gmail.com"
                      "\nWhatsApp: +254 782 526088"
                      "\nTelegram: https://t.me/Forex_Algo_Trader"
#property version   "1.00"


#define MAIN_REC "MAIN_REC"
#define MAIN_SUB_REC "MAIN_SUB_REC"
#define MAIN_LINE_UP "MAIN_LINE_UP"
#define MAIN_LINE_DN "MAIN_LINE_DN"
#define BTN_LOTS "BTN_LOTS"
#define LABEL_NAME "LABEL_NAME"
#define LABEL_LOTS "LABEL_LOTS"
#define ICON_HEART "ICON_HEART"
#define ICON_TOOL "ICON_TOOL"
#define ICON_CAR "ICON_CAR"
#define ICON_DROP_DN1 "ICON_DROP_DN1"
#define LINE1 "LINE1"
#define BTN_CLOSE "BTN_CLOSE"
#define BTN_MARKET "BTN_MARKET"
#define BTN_PROFIT "BTN_PROFIT"
#define BTN_LOSS "BTN_LOSS"
#define BTN_PENDING "BTN_PENDING"
#define LINE2 "LINE2"
#define EDIT_LOTS "EDIT_LOTS"
#define BTN_P1 "BTN_P1"
#define BTN_M1 "BTN_M1"

#define BTN_SL "BTN_SL"
#define LABEL_SL "LABEL_SL"
#define ICON_DROP_DN2 "ICON_DROP_DN2"
#define EDIT_SL "EDIT_SL"
#define BTN_P2 "BTN_P2"
#define BTN_M2 "BTN_M2"

#define BTN_TP "BTN_TP"
#define LABEL_TP "LABEL_TP"
#define ICON_DROP_DN3 "ICON_DROP_DN3"
#define EDIT_TP "EDIT_TP"
#define BTN_P3 "BTN_P3"
#define BTN_M3 "BTN_M3"

#define BTN_BUY "BTN_BUY"
#define LABEL_BUY "LABEL_BUY"
#define LABEL_BUY_PRICE "LABEL_BUY_PRICE"
#define BTN_OVERLAY "BTN_OVERLAY"
#define BTN_SPREAD "BTN_SPREAD"

#define BTN_SELL "BTN_SELL"
#define LABEL_SELL "LABEL_SELL"
#define LABEL_SELL_PRICE "LABEL_SELL_PRICE"

#define BTN_CONTACT "BTN_CONTACT"

#define BTN_SHARP "BTN_SHARP"
#define LABEL_SHARP "LABEL_SHARP"
#define BTN_HOVER "BTN_HOVER"
#define LABEL_HOVER "LABEL_HOVER"

#define LABEL_EXTRA1 "LABEL_EXTRA1"
#define LABEL_EXTRA2 "LABEL_EXTRA2"
#define LABEL_EXTRA3 "LABEL_EXTRA3"
#define LABEL_EXTRA4 "LABEL_EXTRA4"

#define BTN_DROP_DN "BTN_DROP_DN"
#define LABEL_OPT1 "LABEL_OPT1"
#define LABEL_OPT2 "LABEL_OPT2"
#define LABEL_OPT3 "LABEL_OPT3"
#define ICON_DRAG "ICON_DRAG"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   //--- enable CHART_EVENT_MOUSE_MOVE detection
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   
   createRecLabel(MAIN_REC,10,30,250,400,clrWhite,1,clrBlack);
   createRecLabel(MAIN_SUB_REC,15,35,240,390,C'245,245,245',1,clrNONE);
   createRecLabel(MAIN_LINE_UP,15,35,240,1,C'245,245,245',1,clrNONE,BORDER_RAISED);
   createRecLabel(MAIN_LINE_DN,15,35-1,1,390+1,C'245,245,245',1,clrNONE,BORDER_RAISED);
   
   createLabel(ICON_HEART,190,35,"Y",clrRed,15,"Webdings");
   createLabel(ICON_TOOL,210,35,"@",clrBlue,15,"Webdings");
   createLabel(ICON_CAR,230,35,"h",clrBlack,15,"Webdings");
   createLabel(LABEL_NAME,25,35,"DashBoard v1.0",clrBlue,14,"Cooper Black");
   createRecLabel(LINE1,15+10,60,240-10,1,C'245,245,245',1,clrNONE,BORDER_RAISED);
   createLabel(BTN_CLOSE,25,65,"Close",clrBlack,13,"Impact");
   createLabel(BTN_MARKET,70,65,"Market",clrDarkRed,13,"Impact");
   createLabel(BTN_PROFIT,125,65,"Profit",clrGreen,13,"Impact");
   createLabel(BTN_LOSS,170,65,"Loss",clrRed,13,"Impact");
   createLabel(BTN_PENDING,205,65,"Pend'n",clrDarkGray,13,"Impact");
   createRecLabel(LINE2,15+10,87,240-10,1,C'245,245,245',1,clrNONE,BORDER_RAISED);
   
   createButton(BTN_LOTS,25,95,130,25,"",clrBlack,12,C'210,210,210',C'150,150,150');
   createLabel(LABEL_LOTS,25+10,95+5,"LotSize",clrBlack,9);
   createLabel(ICON_DROP_DN1,130,95+5,CharToString(240),C'070,070,070',20,"Wingdings 3");
   createEdit(EDIT_LOTS,165,95,60,25,"0.01",clrBlack,14,clrWhite,C'100,100,100',"Callibri");
   createButton(BTN_P1,225,95,20,12,"5",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");
   createButton(BTN_M1,225,95+12,20,12,"6",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");

   createButton(BTN_SL,25,95+30,130,25,"",clrBlack,12,C'210,210,210',C'150,150,150');
   createLabel(LABEL_SL,35,95+30,"SL Pips",clrBlack,14);
   createLabel(ICON_DROP_DN2,130,100+30,CharToString(240),C'070,070,070',20,"Wingdings 3");
   createEdit(EDIT_SL,165,95+30,60,25,"100.0",clrBlack,13,clrWhite,C'100,100,100',"Callibri");
   createButton(BTN_P2,225,95+30,20,12,"5",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");
   createButton(BTN_M2,225,107+30,20,12,"6",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");
   
   
   createButton(BTN_TP,25,95+30+30,130,25,"",clrBlack,12,C'210,210,210',C'150,150,150');
   createLabel(LABEL_TP,35,95+30+30,"TP Pips",clrBlack,14);
   createLabel(ICON_DROP_DN3,130,100+30+30,CharToString(240),C'070,070,070',20,"Wingdings 3");
   createEdit(EDIT_TP,165,95+30+30,60,25,"100.0",clrBlack,13,clrWhite,C'100,100,100',"Callibri");
   createButton(BTN_P3,225,95+30+30,20,12,"5",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");
   createButton(BTN_M3,225,107+30+30,20,12,"6",clrBlack,12,clrLightGray,C'100,100,100',"Webdings");
   
   createRecLabel(BTN_SELL,25,335,105,60,clrRed,1,clrNONE);
   createLabel(LABEL_SELL,35,335,"Sell",clrWhite,15,"ARIAL black");
   createLabel(LABEL_SELL_PRICE,35,335+30,DoubleToString(Bid(),_Digits),clrWhite,13,"ARIAL black");
   createRecLabel(BTN_BUY,140,335,105,60,clrGreen,1,clrNONE);
   createLabel(LABEL_BUY,150+35,335,"Buy",clrWhite,15,"ARIAL black");
   createLabel(LABEL_BUY_PRICE,150,335+30,DoubleToString(Ask(),_Digits),clrWhite,13,"ARIAL black");
   createRecLabel(BTN_OVERLAY,90,335,90,25,C'245,245,245',0,clrNONE);
   createButton(BTN_SPREAD,95,335,80,20,(string)Spread(),clrBlack,13,clrWhite,clrBlack);
   createButton(BTN_CONTACT,25,335+62,230-10,25,"https://t.me/Forex_Algo_Trader",clrBlack,10,clrNONE,clrBlack);
   
   createRecLabel(BTN_SHARP,25,190,220,35,C'220,220,220',2,C'100,100,100');
   createLabel(LABEL_SHARP,25+20,190+5,"Sharp Edged Button",clrBlack,12,"ARIAL black");
   //createRecLabel(BTN_HOVER,25,230,220,35,clrLightBlue,3,C'050,050,255');
   createRecLabel(BTN_HOVER,25,230,220,35,C'220,220,220',3,C'100,100,100');
   createLabel(LABEL_HOVER,25+20,230+5,"Hover Effect",clrBlack,12,"ARIAL black");
   
   createLabel(LABEL_EXTRA1,25,290,"_",clrBlack,25,"WEBDINGS");
   createLabel(LABEL_EXTRA2,25+40,290,"J",clrBlack,25,"WEBDINGS");
   createLabel(LABEL_EXTRA3,25+40+40,290,"{",clrBlack,25,"WINGDINGS 2");
   createLabel(LABEL_EXTRA4,25+40+40+40,290,"G",clrBlack,25,"WEBDINGS");
   
   return(INIT_SUCCEEDED);
}

double Ask(){return (NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits));}
double Bid(){return (NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits));}
int Spread(){return ((int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD));}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   destroyPanel();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   //--- update the price quotes
   ObjectSetString(0,LABEL_SELL_PRICE,OBJPROP_TEXT,DoubleToString(Bid(),_Digits));
   ObjectSetString(0,LABEL_BUY_PRICE,OBJPROP_TEXT,DoubleToString(Ask(),_Digits));
   ObjectSetString(0,BTN_SPREAD,OBJPROP_TEXT,IntegerToString(Spread()));
}
//+------------------------------------------------------------------+

void  OnChartEvent(
   const int       id,       // event ID  
   const long&     lparam,   // long type event parameter 
   const double&   dparam,   // double type event parameter 
   const string&   sparam    // string type event parameter 
){
   if (id==CHARTEVENT_OBJECT_CLICK){
      if (sparam==BTN_P1){
         Print(sparam+" CLICKED.");
         double trade_lots = (double)ObjectGetString(0,EDIT_LOTS,OBJPROP_TEXT);
         trade_lots+=0.01;
         ObjectSetString(0,EDIT_LOTS,OBJPROP_TEXT,DoubleToString(trade_lots,2));
         ChartRedraw(0);
      }
      if (sparam==BTN_M1){
         Print(sparam+" CLICKED.");
         double trade_lots = (double)ObjectGetString(0,EDIT_LOTS,OBJPROP_TEXT);
         trade_lots-=0.01;
         ObjectSetString(0,EDIT_LOTS,OBJPROP_TEXT,DoubleToString(trade_lots,2));
         ChartRedraw(0);
      }
      if (sparam==BTN_SELL){
         Print("BTN SELL CLICKED");
         ObjectSetInteger(0,BTN_SELL,OBJPROP_STATE,false);
         double trade_lots = (double)ObjectGetString(0,EDIT_LOTS,OBJPROP_TEXT);
         double sell_sl = (double)ObjectGetString(0,EDIT_SL,OBJPROP_TEXT);
         sell_sl = Ask()+sell_sl*_Point;
         sell_sl = NormalizeDouble(sell_sl,_Digits);
         double sell_tp = (double)ObjectGetString(0,EDIT_TP,OBJPROP_TEXT);
         sell_tp = Ask()-sell_tp*_Point;
         sell_tp = NormalizeDouble(sell_tp,_Digits);
         
         Print("Lots = ",trade_lots,", SL = ",sell_sl,", TP = ",sell_tp);
         obj_Trade.Sell(trade_lots,_Symbol,Bid(),sell_sl,sell_tp);
         ChartRedraw(0);
      }
      else if (sparam==BTN_BUY){
         Print("BTN BUY CLICKED");
         ObjectSetInteger(0,BTN_BUY,OBJPROP_STATE,false);
         double trade_lots = (double)ObjectGetString(0,EDIT_LOTS,OBJPROP_TEXT);
         double buy_sl = (double)ObjectGetString(0,EDIT_SL,OBJPROP_TEXT);
         buy_sl = Bid()-buy_sl*_Point;
         buy_sl = NormalizeDouble(buy_sl,_Digits);
         double buy_tp = (double)ObjectGetString(0,EDIT_TP,OBJPROP_TEXT);
         buy_tp = Bid()+buy_tp*_Point;
         buy_tp = NormalizeDouble(buy_tp,_Digits);
         
         Print("Lots = ",trade_lots,", SL = ",buy_sl,", TP = ",buy_tp);
         obj_Trade.Buy(trade_lots,_Symbol,Ask(),buy_sl,buy_tp);
         ChartRedraw(0);
      }
      else if (sparam==BTN_CLOSE){
         Print("BTN CLOSE CLICKED");
         long originalColor = ObjectGetInteger(0,BTN_CLOSE,OBJPROP_COLOR);
         ObjectSetInteger(0,BTN_CLOSE,OBJPROP_COLOR,clrRed);
         for (int i=0; i<=PositionsTotal();i++){
            ulong ticket = PositionGetTicket(i);
            if (ticket > 0){
               if (PositionSelectByTicket(ticket)){
                  if (PositionGetString(POSITION_SYMBOL)==_Symbol){
                     obj_Trade.PositionClose(ticket);
                  }
               }
            }
         }
         Print("Resetting the button to original color");
         ObjectSetInteger(0,BTN_CLOSE,OBJPROP_COLOR,originalColor);
         ChartRedraw(0);
      }
      else if (sparam==BTN_LOTS || sparam==LABEL_LOTS || sparam==ICON_DROP_DN1){
         Print(sparam+" LOTS CLICKED");
         ObjectSetInteger(0,BTN_LOTS,OBJPROP_STATE,true);
         createDropDown();
         //ObjectSetInteger(0,BTN_LOTS,OBJPROP_STATE,false);
         ChartRedraw(0);
      }
      else if (sparam==LABEL_OPT1){
         Print("LABEL LOTS CLICKED");
         string text = ObjectGetString(0,LABEL_OPT1,OBJPROP_TEXT);
         bool btn_state = ObjectGetInteger(0,BTN_LOTS,OBJPROP_STATE);
         ObjectSetString(0,LABEL_LOTS,OBJPROP_TEXT,text);
         destroyDropDown();
         if (btn_state==true){
            ObjectSetInteger(0,BTN_LOTS,OBJPROP_STATE,false);
         }
         ChartRedraw(0);
      }
      else if (sparam==LABEL_OPT2){
         Print("LABEL RISK % CLICKED");
         string text = ObjectGetString(0,LABEL_OPT2,OBJPROP_TEXT);
         bool btn_state = ObjectGetInteger(0,BTN_LOTS,OBJPROP_STATE);
         ObjectSetString(0,LABEL_LOTS,OBJPROP_TEXT,text);
         destroyDropDown();
         if (btn_state==true){
            ObjectSetInteger(0,BTN_LOTS,OBJPROP_STATE,false);
         }
         ChartRedraw(0);
      }
      else if (sparam==LABEL_OPT3){
         Print("LABEL MONEY CLICKED");
         string text = ObjectGetString(0,LABEL_OPT3,OBJPROP_TEXT);
         bool btn_state = ObjectGetInteger(0,BTN_LOTS,OBJPROP_STATE);
         ObjectSetString(0,LABEL_LOTS,OBJPROP_TEXT,text);
         destroyDropDown();
         if (btn_state==true){
            ObjectSetInteger(0,BTN_LOTS,OBJPROP_STATE,false);
         }
         ChartRedraw(0);
      }
      else if (sparam==ICON_CAR){
         destroyPanel();
         ChartRedraw(0);
      }
   }
   
   else if (id==CHARTEVENT_MOUSE_MOVE){
      int mouse_X = (int)lparam; // mouseX >>> mouse x coordinates
      int mouse_Y = (int)dparam; // mouseY >>> mouse y coordinates
      int mouse_State = (int)sparam;
      
      //Print("mouse movement detected");
      
      //Print(mouse_X, " > ", mouse_Y);
      
      // GET THE INITIAL DISTANCES AND SIZES OF THE BUTTON
      
      int XDistance_Hover_Btn = (int)ObjectGetInteger(0,BTN_HOVER,OBJPROP_XDISTANCE);
      int YDistance_Hover_Btn = (int)ObjectGetInteger(0,BTN_HOVER,OBJPROP_YDISTANCE);
      int XSize_Hover_Btn = (int)ObjectGetInteger(0,BTN_HOVER,OBJPROP_XSIZE);
      int YSize_Hover_Btn = (int)ObjectGetInteger(0,BTN_HOVER,OBJPROP_YSIZE);
      
      //Print(XDistance_Hover_Btn, " > ", YDistance_Hover_Btn, " > ", XSize_Hover_Btn);
      
      static bool prevMouseInside = false;
      bool isMouseInside = false;
      
      if (mouse_X >= XDistance_Hover_Btn && mouse_X <= XDistance_Hover_Btn + XSize_Hover_Btn &&
          mouse_Y >= YDistance_Hover_Btn && mouse_Y <= YDistance_Hover_Btn + YSize_Hover_Btn){
         isMouseInside = true;
      }
      
      if (isMouseInside != prevMouseInside){
         // mouse entered or left the button area
         if (isMouseInside){
            Print("Mouse entered the Button area. Do your updates!");
            //createRecLabel(BTN_HOVER,25,230,220,35,clrLightBlue,3,C'050,050,255');
            //createRecLabel(BTN_HOVER,25,230,220,35,C'220,220,220',3,C'100,100,100');
            ObjectSetInteger(0,BTN_HOVER,OBJPROP_COLOR,C'050,050,255');
            ObjectSetInteger(0,BTN_HOVER,OBJPROP_BGCOLOR,clrLightBlue);
         }
         else if (!isMouseInside){
            Print("Mouse left Btn proximities. Return default properties.");
            ObjectSetInteger(0,BTN_HOVER,OBJPROP_COLOR,C'100,100,100');
            ObjectSetInteger(0,BTN_HOVER,OBJPROP_BGCOLOR,C'220,220,220');
         }
         ChartRedraw(0);
         prevMouseInside = isMouseInside;
      }
      
      
      // TO CREATE MOVEMENT OF OBJECT
      static int prevMouseClickState = false; // false = 0, true = 1;
      static bool movingState = false;
      
      // INITIALIZE VARIABLES TO STORE INITIAL SIZES AND DISTANCES OF OBJECTS
      
      static int mlbDownX = 0; // mlb = mouse left button
      static int mlbDownY = 0;
      static int mlbDownX_Distance = 0;
      static int mlbDownY_Distance = 0;
      
      static int mlbDownX_Distance_BTN_DROP_DN = 0;
      static int mlbDownY_Distance_BTN_DROP_DN = 0;
      
      static int mlbDownX_Distance_LABEL_OPT1 = 0;
      static int mlbDownY_Distance_LABEL_OPT1 = 0;

      static int mlbDownX_Distance_LABEL_OPT2 = 0;
      static int mlbDownY_Distance_LABEL_OPT2 = 0;

      static int mlbDownX_Distance_LABEL_OPT3 = 0;
      static int mlbDownY_Distance_LABEL_OPT3 = 0;

      static int mlbDownX_Distance_ICON_DRAG = 0;
      static int mlbDownY_Distance_ICON_DRAG = 0;
      
      // GET THE INITIAL DISTANCES AND SIZES OF THE BUTTON
      
      int XDistance_DropDn_Btn = (int)ObjectGetInteger(0,BTN_DROP_DN,OBJPROP_XDISTANCE);
      int YDistance_DropDn_Btn = (int)ObjectGetInteger(0,BTN_DROP_DN,OBJPROP_YDISTANCE);
      int XSize_DropDn_Btn = (int)ObjectGetInteger(0,BTN_DROP_DN,OBJPROP_XSIZE);
      int YSize_DropDn_Btn = (int)ObjectGetInteger(0,BTN_DROP_DN,OBJPROP_YSIZE);
      
      int XDistance_Opt1_Lbl = (int)ObjectGetInteger(0,LABEL_OPT1,OBJPROP_XDISTANCE);
      int YDistance_Opt1_Lbl = (int)ObjectGetInteger(0,LABEL_OPT1,OBJPROP_YDISTANCE);
      
      int XDistance_Opt2_Lbl = (int)ObjectGetInteger(0,LABEL_OPT2,OBJPROP_XDISTANCE);
      int YDistance_Opt2_Lbl = (int)ObjectGetInteger(0,LABEL_OPT2,OBJPROP_YDISTANCE);

      int XDistance_Opt3_Lbl = (int)ObjectGetInteger(0,LABEL_OPT3,OBJPROP_XDISTANCE);
      int YDistance_Opt3_Lbl = (int)ObjectGetInteger(0,LABEL_OPT3,OBJPROP_YDISTANCE);
      
      int XDistance_Drag_Icon = (int)ObjectGetInteger(0,ICON_DRAG,OBJPROP_XDISTANCE);
      int YDistance_Drag_Icon = (int)ObjectGetInteger(0,ICON_DRAG,OBJPROP_YDISTANCE);
      int XSize_Drag_Icon = (int)ObjectGetInteger(0,ICON_DRAG,OBJPROP_XSIZE);
      int YSize_Drag_Icon = (int)ObjectGetInteger(0,ICON_DRAG,OBJPROP_YSIZE);
      
      if (prevMouseClickState==false && mouse_State==1){
         
         // initialize the button distances and sizes
         
         mlbDownX = mouse_X;
         mlbDownY = mouse_Y;
         mlbDownX_Distance = XDistance_Drag_Icon;
         mlbDownY_Distance = YDistance_Drag_Icon;
         
         mlbDownX_Distance_BTN_DROP_DN = XDistance_DropDn_Btn;
         mlbDownY_Distance_BTN_DROP_DN = YDistance_DropDn_Btn;
         
         mlbDownX_Distance_LABEL_OPT1 = XDistance_Opt1_Lbl;
         mlbDownY_Distance_LABEL_OPT1 = YDistance_Opt1_Lbl;
         
         mlbDownX_Distance_LABEL_OPT2 = XDistance_Opt2_Lbl;
         mlbDownY_Distance_LABEL_OPT2 = YDistance_Opt2_Lbl;

         mlbDownX_Distance_LABEL_OPT3 = XDistance_Opt3_Lbl;
         mlbDownY_Distance_LABEL_OPT3 = YDistance_Opt3_Lbl;

         if (mouse_X >= XDistance_Drag_Icon && mouse_X <= XDistance_Drag_Icon + XSize_Drag_Icon &&
             mouse_Y >= YDistance_Drag_Icon && mouse_Y <= YDistance_Drag_Icon + YSize_Drag_Icon){
            movingState = true;
         }
      }
      
      if (movingState){
         ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
         
         ObjectSetInteger(0,ICON_DRAG,OBJPROP_XDISTANCE,mlbDownX_Distance + mouse_X - mlbDownX);
         ObjectSetInteger(0,ICON_DRAG,OBJPROP_YDISTANCE,mlbDownY_Distance + mouse_Y - mlbDownY);
         
         ObjectSetInteger(0,BTN_DROP_DN,OBJPROP_XDISTANCE,mlbDownX_Distance_BTN_DROP_DN + mouse_X - mlbDownX);
         ObjectSetInteger(0,BTN_DROP_DN,OBJPROP_YDISTANCE,mlbDownY_Distance_BTN_DROP_DN + mouse_Y - mlbDownY);
         
         ObjectSetInteger(0,LABEL_OPT1,OBJPROP_XDISTANCE,mlbDownX_Distance_LABEL_OPT1 + mouse_X - mlbDownX);
         ObjectSetInteger(0,LABEL_OPT1,OBJPROP_YDISTANCE,mlbDownY_Distance_LABEL_OPT1 + mouse_Y - mlbDownY);

         ObjectSetInteger(0,LABEL_OPT2,OBJPROP_XDISTANCE,mlbDownX_Distance_LABEL_OPT2 + mouse_X - mlbDownX);
         ObjectSetInteger(0,LABEL_OPT2,OBJPROP_YDISTANCE,mlbDownY_Distance_LABEL_OPT2 + mouse_Y - mlbDownY);

         ObjectSetInteger(0,LABEL_OPT3,OBJPROP_XDISTANCE,mlbDownX_Distance_LABEL_OPT3 + mouse_X - mlbDownX);
         ObjectSetInteger(0,LABEL_OPT3,OBJPROP_YDISTANCE,mlbDownY_Distance_LABEL_OPT3 + mouse_Y - mlbDownY);

         ChartRedraw(0);
      }
      
      if (mouse_State == 0){
         movingState = false;
         ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
      }
      prevMouseClickState = mouse_State;
   }
   
   
}

bool createRecLabel(string objName,int xD,int yD, int xS, int yS,
   color clrBG,int widthBorder,color clrBorder = clrNONE,
   ENUM_BORDER_TYPE borderType=BORDER_FLAT,ENUM_LINE_STYLE borderStyle=STYLE_SOLID
   ){
   ResetLastError();
   if (!ObjectCreate(ChartID(),objName,OBJ_RECTANGLE_LABEL,0,0,0)){
      Print(__FUNCTION__," FAILED to create rec label! Error Code = ",_LastError);
      return (false);
   }
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,xD);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,yD);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,xS);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,yS);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBG);// rec color
   ObjectSetInteger(0,objName,OBJPROP_BORDER_TYPE,borderType);
   ObjectSetInteger(0,objName,OBJPROP_STYLE,borderStyle);// only if bd = flat
   ObjectSetInteger(0,objName,OBJPROP_WIDTH,widthBorder); // only if bd = flat
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBorder); // only if bd = flat
   ObjectSetInteger(0,objName,OBJPROP_BACK,false);
   ObjectSetInteger(0,objName,OBJPROP_STATE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false);

   ChartRedraw(0);
   return (true);
}

bool createButton(string objName,int xD,int yD, int xS, int yS,
   string txt="",color clrTxt=clrBlack,int fontSize=12,color clrBG=clrNONE,
   color clrBorder=clrNONE,string font="Arial Rounded MT Bold"
   ){
   ResetLastError();
   if (!ObjectCreate(0,objName,OBJ_BUTTON,0,0,0)){
      Print(__FUNCTION__," FAILED to create the button! Error Code = ",_LastError);
      return (false);
   }
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,xD);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,yD);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,xS);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,yS);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,objName,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt);
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,objName,OBJPROP_FONT,font);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBG);
   ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrBorder);
   ObjectSetInteger(0,objName,OBJPROP_BACK,false);
   ObjectSetInteger(0,objName,OBJPROP_STATE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false);

   ChartRedraw(0);
   return (true);
}

bool createLabel(string objName,int xD,int yD,
   string txt,color clrTxt=clrBlack,int fontSize=12,
   string font="Arial Rounded MT Bold"
   ){
   ResetLastError();
   if (!ObjectCreate(0,objName,OBJ_LABEL,0,0,0)){
      Print(__FUNCTION__," FAILED to create the label! Error Code = ",_LastError);
      return (false);
   }
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,xD);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,yD);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,objName,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt);
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,objName,OBJPROP_FONT,font);
   ObjectSetInteger(0,objName,OBJPROP_BACK,false);
   ObjectSetInteger(0,objName,OBJPROP_STATE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false);

   ChartRedraw(0);
   return (true);
}

bool createEdit(string objName,int xD,int yD, int xS, int yS,
   string txt="",color clrTxt=clrBlack,int fontSize=12,color clrBG=clrNONE,
   color clrBorder=clrNONE,string font="Arial Rounded MT Bold"
   ){
   ResetLastError();
   if (!ObjectCreate(0,objName,OBJ_EDIT,0,0,0)){
      Print(__FUNCTION__," FAILED to create the edit! Error Code = ",_LastError);
      return (false);
   }
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,xD);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,yD);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,xS);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,yS);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,objName,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt);
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,objName,OBJPROP_FONT,font);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBG);
   ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrBorder);
   ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_LEFT);
   ObjectSetInteger(0,objName,OBJPROP_READONLY,false);
   ObjectSetInteger(0,objName,OBJPROP_BACK,false);
   ObjectSetInteger(0,objName,OBJPROP_STATE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false);

   ChartRedraw(0);
   return (true);
}

void createDropDown(){
   createRecLabel(BTN_DROP_DN,25,95+25,130,70,clrWhite,2,clrBlack);
   createLabel(LABEL_OPT1,25+10,95+25,"LotSize",clrBlack,12,"stencil");
   createLabel(LABEL_OPT2,25+10,95+25+20,"Risk Percent %",clrBlack,12,"calibri italic");
   createLabel(LABEL_OPT3,25+10,95+25+20+20,"Money Balance",clrBlack,12,"Arial Bold");
   createLabel(ICON_DRAG,25+10+95,95+25,"d",clrRoyalBlue,15,"WEBDINGS");
}

void destroyDropDown(){
   ObjectDelete(0,BTN_DROP_DN);
   ObjectDelete(0,LABEL_OPT1);
   ObjectDelete(0,LABEL_OPT2);
   ObjectDelete(0,LABEL_OPT3);
   ObjectDelete(0,ICON_DRAG);
   ChartRedraw(0);
}

void destroyPanel(){
   ObjectDelete(0,MAIN_REC);
   ObjectDelete(0,MAIN_SUB_REC);
   ObjectDelete(0,MAIN_LINE_UP);
   ObjectDelete(0,MAIN_LINE_DN);
   ObjectDelete(0,BTN_LOTS);
   ObjectDelete(0,LABEL_NAME);
   ObjectDelete(0,LABEL_LOTS);
   ObjectDelete(0,ICON_HEART);
   ObjectDelete(0,ICON_TOOL);
   ObjectDelete(0,ICON_CAR);
   ObjectDelete(0,ICON_DROP_DN1);
   ObjectDelete(0,LINE1);
   ObjectDelete(0,BTN_CLOSE);
   ObjectDelete(0,BTN_MARKET);
   ObjectDelete(0,BTN_PROFIT);
   ObjectDelete(0,BTN_LOSS);
   ObjectDelete(0,BTN_PENDING);
   ObjectDelete(0,LINE2);
   ObjectDelete(0,EDIT_LOTS);
   ObjectDelete(0,BTN_P1);
   ObjectDelete(0,BTN_M1);
   
   ObjectDelete(0,BTN_SL);
   ObjectDelete(0,LABEL_SL);
   ObjectDelete(0,ICON_DROP_DN2);
   ObjectDelete(0,EDIT_SL);
   ObjectDelete(0,BTN_P2);
   ObjectDelete(0,BTN_M2);
   
   ObjectDelete(0,BTN_TP);
   ObjectDelete(0,LABEL_TP);
   ObjectDelete(0,ICON_DROP_DN3);
   ObjectDelete(0,EDIT_TP);
   ObjectDelete(0,BTN_P3);
   ObjectDelete(0,BTN_M3);
   
   ObjectDelete(0,BTN_BUY);
   ObjectDelete(0,LABEL_BUY);
   ObjectDelete(0,LABEL_BUY_PRICE);
   ObjectDelete(0,BTN_OVERLAY);
   ObjectDelete(0,BTN_SPREAD);
   
   ObjectDelete(0,BTN_SELL);
   ObjectDelete(0,LABEL_SELL);
   ObjectDelete(0,LABEL_SELL_PRICE);
   
   ObjectDelete(0,BTN_CONTACT);
   
   ObjectDelete(0,BTN_SHARP);
   ObjectDelete(0,LABEL_SHARP);
   ObjectDelete(0,BTN_HOVER);
   ObjectDelete(0,LABEL_HOVER);

   ObjectDelete(0,LABEL_EXTRA1);
   ObjectDelete(0,LABEL_EXTRA2);
   ObjectDelete(0,LABEL_EXTRA3);
   ObjectDelete(0,LABEL_EXTRA4);
   
   ObjectDelete(0,BTN_DROP_DN);
   ObjectDelete(0,LABEL_OPT1);
   ObjectDelete(0,LABEL_OPT2);
   ObjectDelete(0,LABEL_OPT3);
   ObjectDelete(0,ICON_DRAG);
   
   ChartRedraw(0);
}

