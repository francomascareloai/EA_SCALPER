  //+------------------------------------------------------------------+
//|                                          1_Min_Micro_Trading.mq4 |
//|                                       StarLimit Software Corps., |
//|                                            starlimit04@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "StarLimit Software Corps.,"
#property link      "starlimit04@yahoo.com"


#property indicator_chart_window

extern int scaleX=20,
            scaleY=15,
            offSetX=25,   // 35
            offSetY=20,   //20
            fontSize=15,
            corner=4,
            symbolCodeBuy=217,
            symbolCodeSell=218,
            symbolCodeNoSignal=216,
            allBuy=200,
            allSell=202;
extern color signalBuyColor=Blue, //Strong Up
            signalSellColor=Lime, //Strong Down
            noSignalColor=Red,
            allSellColor=OrangeRed,
            allBuyColor=Blue,
            textColor=Red;
int rsibuy[8],rsisell[8],sarbuy[8],sarsell[8],mabuy[8],masell[8],macdbuy[8],macdsell[8],adxbuy[8],adxsell[8],allsell[1],allbuy[1];
int period[]={ 5,15,30,60,240,1440};
string periodString[]={ "M5","M15","M30","H1","H4","D1"};
string signalName[]={"RSI","SAR","MA","MACD","ADX","ALL"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


int init()
  {
   for(int x=0;x<6;x++)
      for(int y=0; y<6;y++)
         {
            ObjectCreate("signal"+x+y,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("signal"+x+y,OBJPROP_CORNER,corner);
            ObjectSet("signal"+x+y,OBJPROP_XDISTANCE,x*scaleX + offSetX);
            ObjectSet("signal"+x+y,OBJPROP_YDISTANCE,y*scaleY+offSetY);
            ObjectSetText("signal"+x+y,CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
         }
      for( x=0;x<6;x++)
         {
            ObjectCreate("textPeriod"+x,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("textPeriod"+x,OBJPROP_CORNER,corner);
            ObjectSet("textPeriod"+x,OBJPROP_XDISTANCE,x*scaleX+offSetX);
            ObjectSet("textPeriod"+x,OBJPROP_YDISTANCE,offSetY-10);
            ObjectSetText("textPeriod"+x,periodString[x],8,"Tahoma",textColor);
         }
      for( y=0;y<6;y++)
         {
            ObjectCreate("textSignal"+y,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("textSignal"+y,OBJPROP_CORNER,corner);
            ObjectSet("textSignal"+y,OBJPROP_YDISTANCE,y*scaleY+offSetY+8);
            ObjectSet("textSignal"+y,OBJPROP_XDISTANCE,offSetX-25);
            ObjectSetText("textSignal"+y,signalName[y],8,"Tahoma",textColor);      
         }
            
            
       return(0);
      }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment(" " );
   // DELETE ALL OBJECTS  CREATED BY THIS INDICATOR.
    for(int x=0;x<6;x++)
      for(int y=0; y<6;y++)
         {  
            ObjectDelete("signal"+x+y);
         }
        for( x=0;x<6;x++)
         {
           ObjectDelete("textPeriod");
         }
        for( y=0;y<6;y++)
         {
           ObjectDelete("textSignal");
         }
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   for(int x=0;x<6;x++)
      for(int y=0; y<5;y++)
         {
            ObjectCreate("signal"+x+y,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("signal"+x+y,OBJPROP_CORNER,corner);
            ObjectSet("signal"+x+y,OBJPROP_XDISTANCE,x*scaleX + offSetX);
            ObjectSet("signal"+x+y,OBJPROP_YDISTANCE,y*scaleY+offSetY);
            ObjectSetText("signal"+x+y,CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
         }
      for( x=0;x<6;x++)
         {
            ObjectCreate("textPeriod"+x,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("textPeriod"+x,OBJPROP_CORNER,corner);
            ObjectSet("textPeriod"+x,OBJPROP_XDISTANCE,x*scaleX+offSetX);
            ObjectSet("textPeriod"+x,OBJPROP_YDISTANCE,offSetY-10);
            ObjectSetText("textPeriod"+x,periodString[x],8,"Tahoma",textColor);
         }
      for( y=0;y<6;y++)
         {
            ObjectCreate("textSignal"+y,OBJ_LABEL,0,0,0,0,0);
            ObjectSet("textSignal"+y,OBJPROP_CORNER,corner);
            ObjectSet("textSignal"+y,OBJPROP_YDISTANCE,y*scaleY+offSetY+8);
            ObjectSet("textSignal"+y,OBJPROP_XDISTANCE,offSetX-25);
            ObjectSetText("textSignal"+y,signalName[y],8,"Tahoma",textColor);      
         }
            
for( int a=0;a<6;a++)
{
  if(iRSI(NULL,period[a],14,PRICE_CLOSE,0) >50)  //Buy
               {
                  ObjectSetText("signal"+a+"0",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  rsibuy[a]=1;
                  rsisell[a]=0;
               }
 else if(iRSI(NULL,period[a],14,PRICE_CLOSE,0) <50)  //Sell
               {
                  ObjectSetText("signal"+a+"0",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  rsisell[a]=1;
                  rsibuy[a]=0;
               }
     else
                {
                  ObjectSetText("signal"+a+"0",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
                   rsisell[a]=0;
                  rsibuy[a]=0;
                }
 }
 
 for( a=0;a<6;a++)
{
   if(iSAR(NULL,period[a],0.02,0.2,0)< Ask)  //buy
                {
                  ObjectSetText("signal"+a+"1",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  sarbuy[a]=1;
                  sarsell[a]=0;
                }
           else
                {
                  ObjectSetText("signal"+a+"1",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  sarsell[a]=1;
                  sarbuy[a]=0;
                }
 }
 
 for(  a=0;a<6;a++)
{
   if(iMA(NULL,period[a],5,0,MODE_EMA,PRICE_CLOSE,0) > iMA(NULL,period[a],20,0,MODE_SMA,PRICE_CLOSE,0)
      && iMA(NULL,period[a],5,0,MODE_EMA,PRICE_CLOSE,0) > iMA(NULL,period[a],10,0,MODE_EMA,PRICE_CLOSE,0))
                {
                  ObjectSetText("signal"+a+"2",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  mabuy[a]=1;
                  masell[a]=0;
                }
        
   else if(iMA(NULL,period[a],5,0,MODE_EMA,PRICE_CLOSE,0) < iMA(NULL,period[a],20,0,MODE_SMA,PRICE_CLOSE,0)
      && iMA(NULL,period[a],5,0,MODE_EMA,PRICE_CLOSE,0) < iMA(NULL,period[a],10,0,MODE_EMA,PRICE_CLOSE,0))
                {
                  ObjectSetText("signal"+a+"2",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  masell[a]=1;
                  mabuy[a]=0; 
                }
      else
               {
                  ObjectSetText("signal"+a+"2",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
                  masell[a]=0;
                  mabuy[a]=0; 
                }
 }
 
 for(  a=0;a<6;a++)
{
   double main=iMACD(NULL,period[a],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double signal=iMACD(NULL,period[a],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   
   if(main > signal && signal >0)            // for M5 and M15
               {
                  ObjectSetText("signal"+a+"3",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  macdbuy[a]=1;
                  macdsell[a]=0;
               }
   else if(main > signal && main >0)           // for M30 and H1
               {
                  ObjectSetText("signal"+a+"3",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  macdbuy[a]=2;
                  macdsell[a]=0;
                }
   else if(main > signal && main <0)            // for  H4 and D1
               {
                  ObjectSetText("signal"+a+"3",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
                  
                  macdbuy[a]=3;
                  macdsell[a]=0;
               }
               
               
   else if(main <signal && signal < 0)          // for M5 and M15
               {
                  ObjectSetText("signal"+a+"3",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  macdbuy[a]=0;
                  macdsell[a]=1;
                }
   else if(main <signal && main < 0)            // for M30 and H1
               {
                 ObjectSetText("signal"+a+"3",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  macdbuy[a]=0;
                  macdsell[a]=2;
                }
   else if(main <signal && main > 0)            // for H4 and D1
               {
                 ObjectSetText("signal"+a+"3",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
                  macdbuy[a]=0;
                  macdsell[a]=3;
                }
      else
               {
                  ObjectSetText("signal"+a+"3",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
                   macdbuy[a]=0;
                  macdsell[a]=0;
                }
 }
 
  for(  a=0;a<6;a++)
{
  double adx= iADX(NULL,period[a],14,PRICE_CLOSE,0,0);
  double d_p= iADX(NULL,period[a],14,PRICE_CLOSE,1,0);
  double d_n= iADX(NULL,period[a],14,PRICE_CLOSE,2,0);  
   
   if(  ( d_p > 20 && adx < 20 && d_n < 20 && adx > d_n)
      ||( d_p > 25 && adx < 25 && d_n < 20 && adx > d_n)
      ||( d_p > 25 && d_n < 20 && adx < 20 && d_n > adx)
      ||( d_p > 25 && adx > 25 && d_n < 20 && d_p > adx) 
      ||( adx > 25 && d_p > 25 && d_n < 15 && adx > d_p)  
      ||( adx > 25 && d_p < 25 && d_n < 20 && d_p > d_n)
      ||( adx > 20 && d_p < 20 && d_n < 20 && d_p > d_n)  )
      
       {
         ObjectSetText("signal"+a+"4",CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
         adxbuy[a]=1;
         adxsell[a]=0;
       }
else if(  ( d_n > 20 && adx < 20 && d_p < 20 && adx > d_p)
      ||( d_n > 25 && adx < 25 && d_p < 20 && adx > d_p)
      ||( d_n > 25 && d_p < 20 && adx < 20 && d_p > adx)
      ||( d_n > 25 && adx > 25 && d_p < 20 && d_n > adx) 
      ||( adx > 25 && d_n > 25 && d_p < 15 && adx > d_n)
      ||( adx > 25 && d_n < 25 && d_p < 20 && d_n > d_p)
      ||( adx > 20 && d_n < 20 && d_p < 20 && d_n > d_p)  )
      
       {
         ObjectSetText("signal"+a+"4",CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor);
         adxbuy[a]=0;
         adxsell[a]=1;
       }
   else 
      {
         ObjectSetText("signal"+a+"4",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
         adxbuy[a]=0;
         adxsell[a]=0;
      }
  }
  
 //....................ALL SIGNALS IN ONE .......................
   for(  a=0;a<6;a++)
{
    if(a==0)
      {
         if(rsibuy[0]==1 && sarbuy[0]==1 && mabuy[0]==1 && macdbuy[0]==1 && adxbuy[0]==1)
          { 
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[0]=1;
            allsell[0]=0;
          }
    else if(rsisell[0]==1 && sarsell[0]==1 && masell[0]==1 && macdsell[0]==1 && adxsell[0]==1)
            {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[0]=0;
            allsell[0]=1;
            }
       else
           {
            ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
            allbuy[0]=0;
            allsell[0]=0;
            }
      }   
    if(a==1)
      {
         if(rsibuy[1]==1 && sarbuy[1]==1 && mabuy[1]==1 && macdbuy[1]==1 && adxbuy[1]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[1]=1;
            allsell[1]=0;
            }
    else if(rsisell[1]==1 && sarsell[1]==1 && masell[1]==1 && macdsell[1]==1 && adxsell[1]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[1]=0;
            allsell[1]=1;
           }
       else
          {
           ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
           allbuy[1]=0;
           allsell[1]=0;
           }
          
      }
      
    if(a==2)
      {
        if(rsibuy[2]==1 && sarbuy[2]==1 && mabuy[2]==1 && (macdbuy[2]==1 || macdbuy[2]== 2) && adxbuy[2]==1)
          { 
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[2]=1;
            allsell[2]=0;
          }
        else if(rsisell[2]==1 && sarsell[2]==1 && masell[2]==1 && (macdsell[2]==1 || macdsell[2]==2) && adxsell[2]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[2]=0;
            allsell[2]=1;
           }
       else
          {
           ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
           allbuy[2]=0;
           allsell[2]=0;
           }
      }
      
    if(a==3)
      {
          if(rsibuy[3]==1 && sarbuy[3]==1 && mabuy[3]==1 && (macdbuy[3]==1 || macdbuy[3]== 2) && adxbuy[3]==1)
          { 
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[3]=1;
            allsell[3]=0;
          }
        else if(rsisell[3]==1 && sarsell[3]==1 && masell[3]==1 && (macdsell[3]==1 || macdsell[3]==2) && adxsell[3]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[3]=0;
            allsell[3]=1;
           }
       else
          {
           ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
           allbuy[3]=0;
           allsell[3]=0;
           }
      }
    if(a==4)
      { 
           if(rsibuy[4]==1 && sarbuy[4]==1 && mabuy[4]==1 && (macdbuy[4]==1 || macdbuy[4]== 2 ||macdbuy[4]==3 ) && adxbuy[4]==1)
          { 
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[4]=1;
            allsell[4]=0;
          }
        else if(rsisell[4]==1 && sarsell[4]==1 && masell[4]==1 && (macdsell[4]==1 ||macdsell[4]== 2||macdsell[4]== 3) && adxsell[4]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[4]=0;
            allsell[4]=1;
           }
       else
          {
           ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
           allbuy[4]=0;
           allsell[4]=0;
           }
      }
    if(a==5)
      {
        if(rsibuy[5]==1 && sarbuy[5]==1 && mabuy[5]==1 && (macdbuy[5]==1 ||macdbuy[5]== 2 ||macdbuy[5]== 3 ) && adxbuy[5]==1)
          { 
            ObjectSetText("signal"+a+"5",CharToStr(allBuy),fontSize+5,"Wingdings",allBuyColor);
            allbuy[5]=1;
            allsell[5]=0;
          }
        else if(rsisell[5]==1 && sarsell[5]==1 && masell[5]==1 && (macdsell[5]==1 || macdbuy[5]== 2||macdbuy[5]==3) && adxsell[5]==1)
           {
            ObjectSetText("signal"+a+"5",CharToStr(allSell),fontSize+5,"Wingdings",allSellColor);
            allbuy[5]=0;
            allsell[5]=1;
           }
       else
          {
           ObjectSetText("signal"+a+"5",CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);
           allbuy[5]=0;
           allsell[5]=0;
           }
      }
 }
   return(0);
  }
//+------------------------------------------------------------------+
/*
switch(signal)            
// Header of the 'switch'  
   {                                          
     // Start of the 'switch' body    
       case 1 : Alert("Plus one point");     break;
       // Variations..      
       case 2 : Alert("Plus two points");    break;   
         case 3 : Alert("Plus three points");  break;   
            case 4 : Alert("Plus four points");   break;//Here are presented  
                case 5 : Alert("Plus five points");   break;//10 variations 'case',  
                    case 6 : Alert("Plus six points");    break;//but, in general case, 
                         case 7 : Alert("Plus seven points");  break;//the amount of variations 'case'
                               case 8 : Alert("Plus eight points");  break;//is unlimited     
                                case 9 : Alert("Plus nine points");   break;   
                                   case 10: Alert("Plus ten points");    break;  
                                       default: Alert("More than ten points");   
                                         // It is not the same as the 'case'   
    }

*/

