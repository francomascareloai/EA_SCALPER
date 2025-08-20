//+------------------------------------------------------------------+
//|  BUTTONS                                                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 0
#property strict

extern string  Symbols="AUDUSD;EURUSD;EURGBP;EURJPY;GBPUSD;GBPJPY;NZDUSD;USDCAD;USDCHF;USDJPY"; // List of symbols (separated by ";")
extern string  UniqueID="changer";     // Indicator unique ID

extern int     ButtonsInARow = 1;      // Buttons in a horizontal row
extern int     Corner        = 1;      // Corner
extern int     XShift        = 100;    // Horizontal shift
extern int     YShift        = 20;     // Vertical shift
extern int     XSize         = 50;     // Width of buttons
extern int     YSize         = 16;     // Height of buttons
extern int     FSize         = 8;     // Font size
extern string  FontType      = "Consolas" ; // Font
extern color   Bcolor=clrWheat;        // Button color
extern color   Dcolor=clrBeige;        // Button border color
extern color   Tncolor=clrBlack;       // Text color - normal
extern color   Sncolor= clrMagenta;    // Text color - selected
extern bool    Transparent= false;     // Transparent buttons?

//+------------------------------------------------------------------+

string aSymbols[];
                                                               
//+------------------------------------------------------------------+
int OnInit()
{

   
   Symbols=StringTrimLeft(StringTrimRight(Symbols));
   if(StringSubstr(Symbols,StringLen(Symbols)-1,1)!=";")
      Symbols=StringConcatenate(Symbols,";");

 

   int s=0,i=StringFind(Symbols,";",s);
   string current;
   while(i>0)
     {
      current=StringSubstr(Symbols,s,i-s);
      ArrayResize(aSymbols,ArraySize(aSymbols)+1);
      aSymbols[ArraySize(aSymbols)-1]=current;
      s = i + 1;
      i = StringFind(Symbols,";",s);
     }

 
   int xpos=0,ypos=0,maxx=0,maxy=0;
   for(i=0; i<ArraySize(aSymbols); i++)
     { if(i>0 && MathMod(i,ButtonsInARow)==0) { xpos=0; ypos+=YSize+1; } createButton(UniqueID+":symbol:"+string(i),aSymbols[i],XShift+xpos,YShift+ypos); xpos+=XSize+1; }
   xpos=0; ypos+=YSize*2;
   for(i=0; i<ArraySize(sTfTable); i++)
     { if(i>0 && MathMod(i,ButtonsInARow)==0) { xpos=0; ypos+=YSize+1; } createButton(UniqueID+":time:"+string(i),sTfTable[i],XShift+xpos,YShift+ypos); xpos+=XSize+1; }

 
   setSymbolButtonColor();
   setTimeFrameButtonColor();
   
   return(0);
  } 
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_CHARTCHANGE :
      case REASON_RECOMPILE   :
      case REASON_CLOSE       : break;
      default :
        {
         string lookFor       = UniqueID+":";
         int    lookForLength = StringLen(lookFor);
         for(int i=ObjectsTotal()-1; i>=0; i--)
           {
            string objectName=ObjectName(i);  if(StringSubstr(objectName,0,lookForLength)==lookFor) ObjectDelete(objectName);
           }
        }
     }
  }
//+------------------------------------------------------------------+ 
void createButton(string name,string caption,int xpos,int ypos)
  {
   if(ObjectFind(name)!=0)
      ObjectCreate(name,OBJ_BUTTON,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,xpos);
   ObjectSet(name,OBJPROP_YDISTANCE,ypos);
   ObjectSet(name,OBJPROP_XSIZE,XSize);
   ObjectSet(name,OBJPROP_YSIZE,YSize);
   ObjectSetText(name,caption,FSize,FontType,Tncolor);
   ObjectSet(name,OBJPROP_FONTSIZE,FSize);
   ObjectSet(name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSet(name,OBJPROP_COLOR,Tncolor);
   ObjectSet(name,OBJPROP_BGCOLOR,Bcolor);
   ObjectSet(name,OBJPROP_BACK,Transparent);
   ObjectSet(name,OBJPROP_BORDER_COLOR,Dcolor);
   ObjectSet(name,OBJPROP_STATE,false);
   ObjectSet(name,OBJPROP_HIDDEN,true);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   
  }
//+------------------------------------------------------------------+ 
void setSymbolButtonColor()
  {
   string lookFor       = UniqueID+":symbol:";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objectName=ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         string symbol=ObjectGetString(0,objectName,OBJPROP_TEXT);
         if(symbol!=_Symbol)
            ObjectSet(objectName,OBJPROP_COLOR,Tncolor);
         else  ObjectSet(objectName,OBJPROP_COLOR,Sncolor);
        }
     }
  } 
//+------------------------------------------------------------------+
void setTimeFrameButtonColor()
  {
   string lookFor       = UniqueID+":time:";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objectName=ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         int time = stringToTimeFrame(ObjectGetString(0,objectName,OBJPROP_TEXT));
         if(time != _Period)
            ObjectSet(objectName,OBJPROP_COLOR,Tncolor);
         else  ObjectSet(objectName,OBJPROP_COLOR,Sncolor);
        }
     }
  }


//+------------------------------------------------------------------+ 
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200}; 
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i]) return(sTfTable[i]);
   return("");
  } 
//+------------------------------------------------------------------+
int stringToTimeFrame(string tf)
  {
   for(int i=ArraySize(sTfTable)-1; i>=0; i--)
      if(tf==sTfTable[i]) return(iTfTable[i]);
   return(0);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
     {
      if(StringFind(sparam,UniqueID+":symbol:",0)==0) ChartSetSymbolPeriod(0,ObjectGetString(0,sparam,OBJPROP_TEXT),_Period);
      if(StringFind(sparam,UniqueID+":time:"  ,0)==0) ChartSetSymbolPeriod(0,_Symbol,stringToTimeFrame(ObjectGetString(0,sparam,OBJPROP_TEXT)));
      if(StringFind(sparam,UniqueID+":back:"  ,0)==0) ObjectSet(sparam,OBJPROP_STATE,false);
     }
  }
//+------------------------------------------------------------------+
int start() { return(0); }
//+------------------------------------------------------------------+
