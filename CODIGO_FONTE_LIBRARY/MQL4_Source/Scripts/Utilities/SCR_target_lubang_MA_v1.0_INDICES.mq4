//+------------------------------------------------------------------+
//|                                             target lubang MA.mq4 |
//|                                                      reza rahmad |
//|                                           reiz_gamer@yahoo.co.id |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "reiz_gamer@yahoo.co.id"

#property indicator_chart_window
extern string help = "use from tf 5m and change to find target";
extern bool indonesian = true;

   
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
ObjectCreate("tar",OBJ_TEXT,0,0,0,0,0);
         
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("tar");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
  double ma100 = iMA(NULL,0,100,0,MODE_SMA,PRICE_CLOSE,0), ma50 =iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0),
          ma20 = iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,0), ma200 = iMA(NULL,0,200,0,MODE_SMA,PRICE_CLOSE,0);
if ( indonesian == false )
{
   
if (High[0] > ma20 && ma20 > ma50 && ma20 > ma100)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","Trend up change Timeframe",10,"Tahoma",Green);
}
if (High[0] > ma20  && ma50 > ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA50 " + DoubleToStr(ma50,4),10,"Tahoma",Green);
}
if (High[0] > ma50 && ma100 > ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA100 " + DoubleToStr(ma100,4),10,"Tahoma",Green);
}

if (High[0] > ma100  && ma200 > ma100 && ma200 > ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA200 " + DoubleToStr(ma200,4),10,"Tahoma",Green);
}

if (High[0] > ma200 && ma200 > ma100 && ma200 > ma50 )
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","TREND UP CHANGE TIMEFRAME ",10,"Tahoma",Green);
}


// turun
if (Low[0] < ma20  && ma20 < ma50 && ma20 < ma100)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","Trend DOWN CHANGE Timeframe",10,"Tahoma",Green);
}
if (Low[0] < ma20  && ma50 < ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA50 " + DoubleToStr(ma50,4),10,"Tahoma",Green);
}
if (Low[0] < ma50  && ma100 < ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA100 " + DoubleToStr(ma100,4),10,"Tahoma",Green);
}
if (Low[0] < ma50  && ma100 < ma50 && ma50 > ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","TREND DOWN CHANGE TIMEFRAME ",10,"Tahoma",Green);
}
if (Low[0] < ma100  && ma200 < ma100 && ma200 < ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA200 " + DoubleToStr(ma200,4),10,"Tahoma",Green);
}

if (Low[0] < ma200  && ma200 < ma100 && ma200 < ma50 )
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","TREND DOWN CHANGE TIMEFRAME",10,"Tahoma",Green);
}
}

if ( indonesian == true ) 
{
if (High[0] > ma20 && ma20 > ma50 && ma20 > ma100)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","Trend up kuat ganti Timeframe",10,"Tahoma",Green);
}
if (High[0] > ma20  && ma50 > ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA50 " + DoubleToStr(ma50,4),10,"Tahoma",Green);
}
if (High[0] > ma50 && ma100 > ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA100 " + DoubleToStr(ma100,4),10,"Tahoma",Green);
}

if (High[0] > ma100  && ma200 > ma100 && ma200 > ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA200 " + DoubleToStr(ma200,4),10,"Tahoma",Green);
}

if (High[0] > ma200 && ma200 > ma100 && ma200 > ma50 )
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","TREND NAIK GANTI TIMEFRAME ",10,"Tahoma",Green);
}


// turun
if (Low[0] < ma20  && ma20 < ma50 && ma20 < ma100)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","Trend turun kuat ganti Timeframe",10,"Tahoma",Green);
}
if (Low[0] < ma20  && ma50 < ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma50);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA50 " + DoubleToStr(ma50,4),10,"Tahoma",Green);
}
if (Low[0] < ma50  && ma100 < ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA100 " + DoubleToStr(ma100,4),10,"Tahoma",Green);
}
if (Low[0] < ma50  && ma100 < ma50 && ma50 > ma20)
{
ObjectSet("tar",OBJPROP_PRICE1,ma100);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","trend turun kuat ganti timeframe ",10,"Tahoma",Green);
}
if (Low[0] < ma100  && ma200 < ma100 && ma200 < ma50)
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","target MA200 " + DoubleToStr(ma200,4),10,"Tahoma",Green);
}

if (Low[0] < ma200  && ma200 < ma100 && ma200 < ma50 )
{
ObjectSet("tar",OBJPROP_PRICE1,ma200);
ObjectSet("tar",OBJPROP_TIME1,Time[0]);
ObjectSetText("tar","TREND TURUN GANTI TIMEFRAME ",10,"Tahoma",Green);


}

}
//----
   return(0);
  }
//+------------------------------------------------------------------+