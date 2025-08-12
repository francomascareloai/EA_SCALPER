//+------------------------------------------------------------------+
//|                                                    CANVAS EA.mq5 |
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

#include <Canvas/Canvas.mqh>
CCanvas obj_Canvas;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
   obj_Canvas.CreateBitmapLabel("Our Canvas",50,50,700,300,COLOR_FORMAT_ARGB_NORMALIZE);
   obj_Canvas.Erase(ColorToARGB(clrBlack,255));
   obj_Canvas.TransparentLevelSet(255);
   
   //--- translate line along the y-axis
   obj_Canvas.PixelSet(100,100,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,101,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,102,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,103,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,104,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,105,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,106,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,107,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,108,ColorToARGB(clrRed));
   obj_Canvas.PixelSet(100,109,ColorToARGB(clrRed));
   
   //--- translate along the x-axis
   obj_Canvas.PixelSet(101,100,clrBlack);
   obj_Canvas.PixelSet(102,100,clrBlack);
   obj_Canvas.PixelSet(103,100,clrBlack);
   obj_Canvas.PixelSet(104,100,clrBlack);
   obj_Canvas.PixelSet(105,100,clrBlack);
   obj_Canvas.PixelSet(106,100,clrRed);
   obj_Canvas.PixelSet(107,100,clrRed);
   obj_Canvas.PixelSet(108,100,clrRed);
   obj_Canvas.PixelSet(109,100,clrRed);
   
   //--- translate diagonally
   obj_Canvas.PixelSet(101,101,clrBlack);
   obj_Canvas.PixelSet(102,102,clrBlack);
   obj_Canvas.PixelSet(103,103,clrBlack);
   obj_Canvas.PixelSet(104,104,clrBlack);
   obj_Canvas.PixelSet(105,105,clrBlack);
   obj_Canvas.PixelSet(106,106,clrRed);
   obj_Canvas.PixelSet(107,107,clrRed);
   obj_Canvas.PixelSet(108,108,clrRed);
   obj_Canvas.PixelSet(109,109,clrRed);
   
   //--- text
   obj_Canvas.FontNameSet("cooper black");
   obj_Canvas.FontSizeSet(50);
   obj_Canvas.FontAngleSet(-35);
   obj_Canvas.TextOut(0,0,"Our test TEXT",ColorToARGB(clrLime,255));
   
   //---
   obj_Canvas.Line(10,50,300,100,ColorToARGB(clrLime,255));
   obj_Canvas.Rectangle(400,50,500,200,ColorToARGB(clrLime,255));
   obj_Canvas.Pie(650,50,100,70,3,5,ColorToARGB(clrLime,255),ColorToARGB(clrYellow,255));
   obj_Canvas.FillRectangle(400,230,500,270,ColorToARGB(clrBlue,255));
   
   obj_Canvas.LineThick(10+20,50+20,300+20,100+20,ColorToARGB(clrRed,255),7,STYLE_SOLID,LINE_END_BUTT);
   
   obj_Canvas.Update(true);
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   obj_Canvas.Destroy();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
