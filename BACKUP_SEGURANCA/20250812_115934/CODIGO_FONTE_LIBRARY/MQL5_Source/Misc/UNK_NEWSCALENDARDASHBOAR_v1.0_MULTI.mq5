//+------------------------------------------------------------------+
//|                                      NEWS CALENDAR DASHBOARD.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define MAIN_REC "MAIN_REC"
#define SUB_REC1 "SUB_REC1"
#define SUB_REC2 "SUB_REC2"
#define HEADER_LABEL "HEADER_LABEL"
#define ARRAY_CALENDAR "ARRAY_CALENDAR"
#define ARRAY_NEWS "ARRAY_NEWS"
#define DATA_HOLDERS "DATA_HOLDERS"
#define TIME_LABEL "TIME_LABEL"
#define IMPACT_LABEL "IMPACT_LABEL"

string array_calendar[] = {"Date","Time","Cur.","Imp.","Event","Actual","Forecast","Previous"};
int buttons[] = {80,50,50,40,281,60,70,70};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
   createRecLabel(MAIN_REC,50,50,740,410,clrSeaGreen,1);
   createRecLabel(SUB_REC1,50+3,50+30,740-3-3,410-30-3,clrWhite,1);
   createRecLabel(SUB_REC2,50+3+5,50+30+50+27,740-3-3-5-5,410-30-3-50-27-10,clrGreen,1);
   
   createLabel(HEADER_LABEL,50+3+5,50+5,"MQL5 Economic Calendar",clrWhite,15);
   int startX = 59;
   for (int i=0; i<ArraySize(array_calendar); i++){
      createButton(ARRAY_CALENDAR+IntegerToString(i),startX,132,buttons[i],25,array_calendar[i],clrWhite,13,clrGreen,clrNONE,"Calibri Bold");
      startX += buttons[i]+3;
   }
   
   //---
   int totalNews = 0;
   bool isNews = false;
   MqlCalendarValue values[];
   
   datetime startTime = TimeTradeServer() - PeriodSeconds(PERIOD_H12);
   datetime endTime = TimeTradeServer() + PeriodSeconds(PERIOD_H12);
   
   string country_code = "US";
   string currency_base = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   //if (currency_base != "USD") return (false);
   
   int allValues = CalendarValueHistory(values,startTime,endTime,NULL,NULL);
   
   Print("TOTAL VALUES = ",allValues," || Array size = ",ArraySize(values));
   
   createLabel(TIME_LABEL,70,85,"Server Time: "+TimeToString(TimeCurrent(),
               TIME_DATE|TIME_SECONDS)+"   |||   Total News: "+
               IntegerToString(allValues),clrBlack,14,"Times new roman bold");
   createLabel(IMPACT_LABEL,70,105,"Impact: ",clrBlack,14,"Times new roman bold");
   
   string impact_labels[] = {"None", "Low", "Medium", "High"};
   int impact_size = 100;
   
   for (int i=0; i<ArraySize(impact_labels); i++){
      color impact_color = clrBlack, label_color = clrBlack;
      if (impact_labels[i] == "None"){label_color = clrWhite;}
      else if (impact_labels[i] == "Low"){impact_color = clrYellow;}
      else if (impact_labels[i] == "Medium"){impact_color = clrOrange;}
      else if (impact_labels[i] == "High"){impact_color = clrRed;}
      createButton(IMPACT_LABEL+string(i),140+impact_size*i,105,impact_size,25,impact_labels[i],label_color,12,impact_color,clrBlack);
   }
   
   datetime timeRange = PeriodSeconds(PERIOD_D1);
   datetime timeBefore = TimeTradeServer() - timeRange;
   datetime timeAfter = TimeTradeServer() + timeRange;
   
   Print("FURTHEST TIME LOOK BACK = ",timeBefore," >>> CURRENT = ",TimeTradeServer());
   
   int valuesTotal = (allValues <= 11) ? allValues : 11;
   
   int startY = 162;
   for (int i = 0; i < valuesTotal; i++){
      
      color holder_color = (i % 2 == 0) ? C'213,227,207' : clrWhite;
      
      createRecLabel(DATA_HOLDERS+string(i),62,startY-1,716,26,holder_color,1,clrBlack);
      
      int startX = 65;
      
      for (int k=0; k<ArraySize(array_calendar); k++){
         
         MqlCalendarEvent event;
         CalendarEventById(values[i].event_id,event);
         
         MqlCalendarCountry country;
         CalendarCountryById(event.country_id,country);
         Print("Name = ",event.name,", IMP = ",EnumToString(event.importance),", COUNTRY = ",country.name,", TIME = ",values[i].time);
         //if (StringFind(_Symbol,country.currency) < 0) continue;
         
         string news_data[ArraySize(array_calendar)];
         news_data[0] = TimeToString(values[i].time,TIME_DATE);
         news_data[1] = TimeToString(values[i].time,TIME_MINUTES);
         news_data[2] = country.currency;
         color importance_color = clrBlack;
         if (event.importance == CALENDAR_IMPORTANCE_LOW){importance_color=clrYellow;}
         else if (event.importance == CALENDAR_IMPORTANCE_MODERATE){importance_color=clrOrange;}
         else if (event.importance == CALENDAR_IMPORTANCE_HIGH){importance_color=clrRed;}
         news_data[3] = ShortToString(0x25CF);
         news_data[4] = event.name;
         MqlCalendarValue value;
         CalendarValueById(values[i].id,value);
         news_data[5] = DoubleToString(value.GetActualValue(),3);
         news_data[6] = DoubleToString(value.GetForecastValue(),3);
         news_data[7] = DoubleToString(value.GetPreviousValue(),3);
         
         if (k == 3){
            createLabel(ARRAY_NEWS+IntegerToString(i)+" "+array_calendar[k],startX,startY-(22-12),news_data[k],importance_color,22,"Calibri");
         }
         else {
            createLabel(ARRAY_NEWS+IntegerToString(i)+" "+array_calendar[k],startX,startY,news_data[k],clrBlack,12,"Calibri");
         }
         
         startX += buttons[k]+3;
      }
      startY += 25;
      Print(startY);
   }
   
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|     Function to create rectangle label                           |
//+------------------------------------------------------------------+

bool createRecLabel(string objName, int xD, int yD, int xS, int yS,
                    color clrBg, int widthBorder, color clrBorder = clrNONE,
                    ENUM_BORDER_TYPE borderType = BORDER_FLAT, ENUM_LINE_STYLE borderStyle = STYLE_SOLID) {
    ResetLastError(); // Reset any previous error codes
    
    // Create a rectangle label object
    if (!ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0)) {
        Print(__FUNCTION__, ": failed to create rec label! Error code = ", _LastError);
        return (false); // Return false if object creation fails
    }
    
    // Set properties for the rectangle label
    ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD); // X distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD); // Y distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_XSIZE, xS); // Width of the rectangle
    ObjectSetInteger(0, objName, OBJPROP_YSIZE, yS); // Height of the rectangle
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER); // Positioning corner
    ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBg); // Rectangle background color
    ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, borderType); // Border type
    ObjectSetInteger(0, objName, OBJPROP_STYLE, borderStyle); // Border style (only if borderType is flat)
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, widthBorder); // Border width (only if borderType is flat)
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrBorder); // Border color (only if borderType is flat)
    ObjectSetInteger(0, objName, OBJPROP_BACK, false); // Not a background object
    ObjectSetInteger(0, objName, OBJPROP_STATE, false); // Not selectable
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false); // Not selectable
    ObjectSetInteger(0, objName, OBJPROP_SELECTED, false); // Not selected
    
    ChartRedraw(0); // Redraw the chart
    
    return (true); // Return true if object creation and property settings are successful
}

//+------------------------------------------------------------------+
//|     Function to create button                                    |
//+------------------------------------------------------------------+

bool createButton(string objName, int xD, int yD, int xS, int yS,
                  string txt = "", color clrTxt = clrBlack, int fontSize = 12,
                  color clrBg = clrNONE, color clrBorder = clrNONE,
                  string font = "Arial Rounded MT Bold") {
    // Reset any previous errors
    ResetLastError();

    // Attempt to create the button object
    if (!ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0)) {
        // Print an error message if creation fails
        Print(__FUNCTION__, ": failed to create the button! Error code = ", _LastError);
        return (false);
    }

    // Set properties for the button
    ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD); // X distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD); // Y distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_XSIZE, xS); // Width of the button
    ObjectSetInteger(0, objName, OBJPROP_YSIZE, yS); // Height of the button
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER); // Positioning corner
    ObjectSetString(0, objName, OBJPROP_TEXT, txt); // Text displayed on the button
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt); // Text color
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize); // Font size
    ObjectSetString(0, objName, OBJPROP_FONT, font); // Font name
    ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBg); // Background color
    ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrBorder); // Border color
    ObjectSetInteger(0, objName, OBJPROP_BACK, false); // Transparent background
    ObjectSetInteger(0, objName, OBJPROP_STATE, false); // Button state (not pressed)
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false); // Not selectable
    ObjectSetInteger(0, objName, OBJPROP_SELECTED, false); // Not selected

    // Redraw the chart to display the button
    ChartRedraw(0);

    return (true); // Button creation successful
}

//+------------------------------------------------------------------+
//|     Function to create text label                                |
//+------------------------------------------------------------------+

bool createLabel(string objName, int xD, int yD,
                 string txt, color clrTxt = clrBlack, int fontSize = 12,
                 string font = "Arial Rounded MT Bold") {
    // Reset any previous errors
    ResetLastError();

    // Attempt to create the label object
    if (!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0)) {
        // Print an error message if creation fails
        Print(__FUNCTION__, ": failed to create the label! Error code = ", _LastError);
        return (false);
    }

    // Set properties for the label
    ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xD); // X distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yD); // Y distance from the corner
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER); // Positioning corner
    ObjectSetString(0, objName, OBJPROP_TEXT, txt); // Text displayed on the label
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt); // Text color
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize); // Font size
    ObjectSetString(0, objName, OBJPROP_FONT, font); // Font name
    ObjectSetInteger(0, objName, OBJPROP_BACK, false); // Transparent background
    ObjectSetInteger(0, objName, OBJPROP_STATE, false); // Label state (not active)
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false); // Not selectable
    ObjectSetInteger(0, objName, OBJPROP_SELECTED, false); // Not selected

    // Redraw the chart to display the label
    ChartRedraw(0);

    return (true); // Label creation successful
}
