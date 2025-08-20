//+------------------------------------------------------------------+
//|                                                  rotate_text.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   int    angle=0;
   int    index=0;
   double price;
   int    k=1;
//----
   price=Low[index];
   ObjectCreate("rotating_text", OBJ_TEXT, 0, Time[index], price);
   ObjectSetText("rotating_text","Up...",20);
   ObjectSet("rotating_text",OBJPROP_TIME1,Time[index]);
   ObjectSet("rotating_text",OBJPROP_PRICE1,price);
   ObjectSet("rotating_text",OBJPROP_COLOR,Green);
   while(true) 
     {
      index+=k;
      ObjectMove("rotating_text",0,Time[index],price+index*0.0001);
      ObjectSet("rotating_text",OBJPROP_ANGLE,angle);
      ObjectsRedraw();
      angle+=30;
      if(angle>3600) angle=0;
      if(index>20) 
       {
        k=-1;
        ObjectSetText("rotating_text","...and Down",20);
        ObjectSet("rotating_text",OBJPROP_COLOR,IndianRed);
       }
      if(index==0) 
       {
        k=1; 
        ObjectSetText("rotating_text","Up...",20);
        ObjectSet("rotating_text",OBJPROP_COLOR,Gold);
       }  
      Sleep(100); 
     }
   return(0);
  }
//+------------------------------------------------------------------+