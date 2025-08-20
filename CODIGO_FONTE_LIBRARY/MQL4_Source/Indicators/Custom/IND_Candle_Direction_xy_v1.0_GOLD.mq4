//+------------------------------------------------------------------+
//|                                             Candle Direction.mq4 |
//|                                   Copyright 2014, Luis Andrianto |
//|                            https://login.mql5.com/en/users/lou15 |
//+------------------------------------------------------------------+
//added
// - xy placement on chart
// - removed corner option, default corner set as 0, top left
// - arrows have direction changes, not just color
#property copyright "Copyright 2014, Luis Andrianto"
#property link      "https://login.mql5.com/en/users/lou15"

#property indicator_chart_window
#property indicator_buffers 1

extern color LabelColor  = Aqua;
//extern int Corner        = 1;
extern color UpColor     = Lime;
extern color DownColor   = Red;
extern color NetralColor = Silver;
extern bool ArrDirection = false;
extern int x_offset = 10;
extern int y_offset = 15;

int Corner = 0;
int TF[]={43200,10080,1440,240,60,30,15,5,1};
string Label[]={"MN","W1","D1","H4","H1","M30","M15","M5","M1"};
double ExtBuff[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,ExtBuff,INDICATOR_DATA);
   
   for(int i=0;i<=8;i++)
   {
      ObjectCreate(Label[i],OBJ_LABEL,0,0,0);
      ObjectCreate(Label[i]+" ARROW",OBJ_LABEL,0,0,0);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i=0;i<=8;i++)
   {
      ObjectDelete(Label[i]);
      ObjectDelete(Label[i]+" ARROW");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

double OCandle(int tf){double OC=iOpen(Symbol(),tf,0);return(OC);}
double CCandle(int tf){double CC=iClose(Symbol(),tf,0);return(CC);}

void ObSetLabel(string name,string text,int x,int y)
   {
      ObjectSetText(name,text,10,"Impact",LabelColor);
      ObjectSet(name,OBJPROP_CORNER,Corner);
      ObjectSet(name,OBJPROP_XDISTANCE,x);
      ObjectSet(name,OBJPROP_YDISTANCE,y);
      ObjectSet(name,OBJPROP_BACK,0);
   }
void ObSetArrow(string name,int code,int x,int y,color clr)
   {
      ObjectSetText(name,CharToStr(code),14,"Wingdings",clr);      
      ObjectSet(name,OBJPROP_CORNER,Corner);
      ObjectSet(name,OBJPROP_XDISTANCE,x);
      ObjectSet(name,OBJPROP_YDISTANCE,y);
      ObjectSet(name,OBJPROP_BACK,0);
   }

int start()
  {
   
//----
   
   int X_Start=x_offset;
   int Y_Start=20;
   color clr;
   for(int i=0;i<=8;i++)
      {
         
         //ObSetLabel(Label[i],Label[i],X_Start,Y_Start);
         ObSetLabel(Label[i],Label[i],X_Start,y_offset);
         
         if(CCandle(TF[i])>OCandle(TF[i])){clr=UpColor;ExtBuff[i]=1;}
         else if(CCandle(TF[i])<OCandle(TF[i])){clr=DownColor;ExtBuff[i]=2;}
         else {clr=NetralColor;ExtBuff[i]=0;}
         
         //ObSetArrow(Label[i]+" ARROW",233,X_Start,Y_Start+20,clr);
         
         if(ArrDirection){
         if(ExtBuff[i]==1){ObSetArrow(Label[i]+" ARROW",233,X_Start,y_offset+20,clr);}
         if(ExtBuff[i]==2){ObSetArrow(Label[i]+" ARROW",234,X_Start,y_offset+20,clr);}
         if(ExtBuff[i]==0){ObSetArrow(Label[i]+" ARROW",232,X_Start,y_offset+20,clr);}    }
         
         if(!ArrDirection){ObSetArrow(Label[i]+" ARROW",233,X_Start,y_offset+20,clr);}

         

         X_Start=X_Start+30;    
       }
//----
   return(0);
  }
//+------------------------------------------------------------------+