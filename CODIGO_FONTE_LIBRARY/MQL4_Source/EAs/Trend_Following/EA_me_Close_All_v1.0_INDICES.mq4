//+------------------------------------------------------------------+
//|                                            me_Close_All v1.0.mq4 |
//|                                       Copyright © 2016, qK Code. |
//|                                       http://qkcode.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, qK Code. (http://qkcode.blogspot.com)"
#property link      "http://qkcode.blogspot.com"

extern int Corner = 0;
extern int Move_X = 0;
extern int Move_Y = 0;
extern string B00000 = "============";
extern string Font_Type = "Arial Bold";
extern color Font_Color = White;
extern int Font_Size = 10;
extern string B00001 = "============";
extern int Button_Width = 120;
extern color Button_Color  = Navy;
extern color Button_Border = Navy;

int OnInit()
  {
   CreateButtons();
   ToolTips_Text ("CloseALL_btn");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   DeleteButtons();
  }

void OnChartEvent (const int id, const long &lparam, const double &dparam, const string &sparam)
    {
     ResetLastError();
     if (id == CHARTEVENT_OBJECT_CLICK) {if (ObjectType (sparam) == OBJ_BUTTON) {ButtonPressed (0, sparam);}}
    }
    
void CreateButtons()
    {
     int Button_Height = Font_Size*2.8;
     if (!ButtonCreate (0, "CloseALL_btn", 0, Move_X + 010, Move_Y + 020, Button_Width, Button_Height, Corner, "Close All Trades", Font_Type, Font_Size, Font_Color, Button_Color, Button_Border)) return;
     ChartRedraw();
    }

void DeleteButtons()
    {
     ButtonDelete (0, "CloseALL_btn");
    }

void ButtonPressed (const long chartID, const string sparam)
    {
     ObjectSetInteger (chartID, sparam, OBJPROP_BORDER_COLOR, Black);
     ChartRedraw();
     if (sparam == "CloseALL_btn") CloseAll_Button (sparam);
     Sleep (100);
     ObjectSetInteger (0, sparam, OBJPROP_BORDER_COLOR, Silver);
     ChartRedraw();
    }
    
void ToolTips_Text(const string sparam)
  {
   if (sparam == "CloseALL_btn")   {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Close ALL Open Trades");}
  }

int CloseAll_Button (const string sparam)
  {   
   int ticket;
   if (OrdersTotal() == 0) return(0);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
       if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == 0)
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), MarketInfo (OrderSymbol(), MODE_BID), 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ", GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
            }
          if (OrderType() == 1)
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), MarketInfo (OrderSymbol(), MODE_ASK), 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ",  GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
            }   
         }
      }
   return(0);
  }

bool ButtonCreate (const long chart_ID = 0, const string name = "Button", const int sub_window = 0, const int x = 0, const int y = 0, const int width = 500,
                   const int height = 18, int corner = 0, const string text = "Button", const string font = "Arial Bold",
                   const int font_size = 10, const color clr = clrBlack, const color back_clr = White, const color border_clr = clrNONE,
                   const bool state = false, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0)
  {
   ResetLastError();
   if (!ObjectCreate (chart_ID,name, OBJ_BUTTON, sub_window, 0, 0))
     {
      Print (__FUNCTION__, ": Unable to create the button! Error code = ", GetLastError());
      return(false);
     }
   ObjectSetInteger (chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger (chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger (chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger (chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger (chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger (chart_ID, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger (chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger (chart_ID, name, OBJPROP_STATE, state);
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger (chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger (chart_ID, name, OBJPROP_ZORDER,z_order);
   ObjectSetString  (chart_ID, name, OBJPROP_TEXT, text);
   ObjectSetString  (chart_ID, name, OBJPROP_FONT, font);
   return(true);
  }
  
bool ButtonDelete (const long chart_ID = 0, const string name = "Button")
  {
   ResetLastError();
   if (!ObjectDelete (chart_ID,name))
     {
      Print (__FUNCTION__, ": Unable to delete the button! Error code = ", GetLastError());
      return(false);
     }
   return(true);
  }