//+------------------------------------------------------------------+
//|                                  Real_Time_MultiIndicator_v1.mq4 |
//|                                 Copyright © 2007, Pavel Chigirev
//| http://articles.mql4.com/384
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Pavel Chigirev"
#property link      ""
//----
#property indicator_separate_window
#property indicator_maximum 10.0
#property indicator_minimum 0.0
extern color TColor = SteelBlue;
extern color TxtColor = Red;

//----The parameters of the indicators
extern string p1 = "Parabolic SAR Parameter";
extern double SAR_Step = 0.02;
extern double SAR_Max = 0.2;
extern string p2 = "MACD Parameter";
extern int Fast_EMA = 12;
extern int Slow_EMA = 26;
extern int MACD_SMA = 9;
extern string p3 = "Moving Average Parameter";
extern int Fast_MA = 5;
extern int Slow_MA = 10;
extern string p4 = "ADX Parameter";
extern int ADX_Period = 14;
extern string p5 = "CCI Parameter";
extern int Period_CCI = 14;
//extern string p6 = "The parameters of the indicator 6";
//extern string p7 = "The parameters of the indicator 7";

//----Настройки индикатора
int t1, t2, t11, t12, t13, t14, t15, a, b;
int textT[6], textC[8], tt[10];
int per[] = {15, 30, 60, 240};    // {1=M1, 5=M5, 15=M15, 30=M30, 60=H1, 240=H4, 1440=D1, 10080=W1, 43200=MN1}
string nameS[] = {"INDICATOR", "M15", "M30", "H1", "H4"};
string name[] = {"Parabolic SAR", "MACD", "SMA Cross", "ADX", "CCI", 
                 "", ""};
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init()
  {
   string sn = "Real_Time_MultiIndicator_v1";
   IndicatorShortName(sn);
   SetIndexLabel(0, sn);
   name[0] = name[0] + "(" + DoubleToStr(SAR_Step, 2) + ", " + 
             DoubleToStr(SAR_Max, 2) + ")";
   name[1] = name[1] + "(" + DoubleToStr(Fast_EMA, 0) + ", " + 
             DoubleToStr(Slow_EMA, 0) + ", " + 
             DoubleToStr(MACD_SMA, 0) + ")";
   name[2] = name[2] + "(" + DoubleToStr(Fast_MA, 0) + ", " + 
             DoubleToStr(Slow_MA,0)+")";
   name[3] = name[3] + "(" + DoubleToStr(ADX_Period, 0) + ")";
   name[4] = name[4] + "(" + DoubleToStr(Period_CCI, 0) + ")";
//   name[5] = name[5] + "(" + DoubleToStr(1-й параметр индикатора 2, 0) + 
//             ", " + DoubleToStr(2-й параметр индикатора 2, 0) + ")";
//   name[6] = name[6] + "(" + DoubleToStr(1-й параметр индикатора 3, 0) + 
//             ", " + DoubleToStr(2-й параметр индикатора 3, 0) + ")";
   return(0);
  }
//+------------------------------------------------------------------+
//| Check errors                                                  |
//+------------------------------------------------------------------+
int Error(int p, int a)
  {
    double s = iClose(NULL, p, a);
    if(s == 0) 
        return(1);
  }
//+------------------------------------------------------------------+
//| Parabolic SAR                                                    |
//+------------------------------------------------------------------+
string SAR(int p)
  {
   int ii = 1;
   if(iSAR(NULL, p, SAR_Step, SAR_Max, 0) > iClose(NULL, p, ii)) 
     {
       while(iSAR(NULL, p, SAR_Step, SAR_Max, ii) > iClose(NULL, p, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else 
     {
       while(iSAR(NULL, p, SAR_Step, SAR_Max, ii) < iClose(NULL, p, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     } 
  }
//+------------------------------------------------------------------+
//| MACD                                                             |
//+------------------------------------------------------------------+
string MACD(int p)
  {
   int ii = 1;
   if(iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, PRICE_MEDIAN, 0, 0) < 
      iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, PRICE_MEDIAN, 1, 0))
     {
       while(iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, 
             PRICE_MEDIAN, 0, ii) < 
             iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, 
             PRICE_MEDIAN, 1, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else 
     {
       while(iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, 
             PRICE_MEDIAN, 0, ii) > 
             iMACD(NULL, p, Fast_EMA, Slow_EMA, MACD_SMA, 
             PRICE_MEDIAN, 1, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     }
  }
//+------------------------------------------------------------------+
//| Crossing MA                                                      |
//+------------------------------------------------------------------+
string CMA(int p)
  {
   int ii = 1;
   if(iMA(NULL, p, Fast_MA, 0, MODE_SMA, PRICE_MEDIAN, 0) < 
      iMA(NULL, p, Slow_MA, 0, MODE_SMA, PRICE_MEDIAN, 0))
     {
       while(iMA(NULL, p, Fast_MA, 0, MODE_SMA, PRICE_MEDIAN, ii) < 
             iMA(NULL, p, Slow_MA, 0, MODE_SMA, PRICE_MEDIAN, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else
     {
       while(iMA(NULL, p, Fast_MA, 0, MODE_SMA, PRICE_MEDIAN, ii) > 
             iMA(NULL, p, Slow_MA, 0, MODE_SMA, PRICE_MEDIAN, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     }
  }
//+------------------------------------------------------------------+
//| ADX                                                              |
//+------------------------------------------------------------------+
string ADX(int p)
  {
   int ii = 1;
   if(iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 1, 0) < 
      iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 2, 0))
     {
       while(iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 1, ii) < 
             iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 2, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else
     {
       while(iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 1, ii) > 
             iADX(NULL, p, ADX_Period, PRICE_MEDIAN, 2, ii))
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     }
  }
//+------------------------------------------------------------------+
//| CCI                                                       |
//+------------------------------------------------------------------+
string CCI(int p)
  {
    int ii = 1;
    if(iCCI(NULL, p, Period_CCI, PRICE_MEDIAN, 0) < 0)
     {
       while(iCCI(NULL, p, Period_CCI, PRICE_MEDIAN, ii) < 0)       
ii++;
      if(Error(p, ii + 1) == 1) 
          return("Waiting data");
      return("Sell(" + DoubleToStr(ii, 0) + ")");
    }
  else
    {
      while(iCCI(NULL, p, Period_CCI, PRICE_MEDIAN, ii) > 0)
          ii++;
      if(Error(p, ii + 1) == 1) 
          return("Waiting data");
      return("Buy(" + DoubleToStr(ii, 0) + ")");
    }
  }
/*//+------------------------------------------------------------------+
//| Функция 2                                                        |
//+------------------------------------------------------------------+
string Функция(int p)
  {
   int ii = 1;
   if(Условие для индикатора - true - sell, false - buy)
     {
       while(Условие для sell)
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else
     {
       while(Условие для buy)
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting dataY");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     }
  }*/
/*//+------------------------------------------------------------------+
//| Функция 3                                                        |
//+------------------------------------------------------------------+
string Функция(int p)
  {
   int ii = 1;
   if(Условие для индикатора - true - sell, false - buy)
     {
       while(Условие для sell)
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Sell(" + DoubleToStr(ii, 0) + ")");
     }
   else
     {
       while(Условие для buy)
           ii++;
       if(Error(p, ii + 1) == 1) 
           return("Waiting data");
       return("Buy(" + DoubleToStr(ii, 0) + ")");
     }
  }*/
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
// Вычисление координат для построения таблицы и написания текста
   a = WindowBarsPerChart(); 
   b = a - (0.3*a);
   t1 = Time[b];
   t2 = Time[0];
   for(int i = 1; i <= 5; i++)
     {
       if(i == 1)
         {
           b = a - (0.41*a);
           textT[i] = Time[b];
         }
       else
         {
           b = a - ((0.34 + (i*0.12))*a);
           textT[i] = Time[b];
         }
     }
   for(i = 0; i <= 7; i++)
       textC[i] = 9.5 - i;
   for(i = 1; i <= 4; i++)
     {
       if(i == 1)
         {
           b = a - (0.52*a);
           tt[i] = Time[b];
         }
       else
         {
           b = a - ((0.52 + (0.12*(i - 1)))*a);
           tt[i] = Time[b];
         }
    }
//------------ЗАПОЛНЕНИЕ ТАБЛИЦЫ
// Первый столбец
   for(i = 1; i <= 7; i++)
     {
       ObjectDelete("1" + DoubleToStr(i, 0));
       ObjectCreate("1" + DoubleToStr(i, 0), OBJ_TEXT, 
                    WindowFind("Real_Time_MultiIndicator_v1"), 
                    textT[1], textC[i]);
       ObjectSetText("1" + DoubleToStr(i, 0), name[i-1], 8, 
                     "Tahoma", TxtColor);
     }
//------------ЗАПОЛНЕНИЕ СТРОК С СИГНАЛАМИ ИНДИКАТОРА
// Первая строка   
   for(i = 1; i <= 4; i++)
     {
       ObjectDelete("2" + DoubleToStr(i, 0));
       ObjectCreate("2" + DoubleToStr(i, 0), OBJ_TEXT, 
                    WindowFind("Real_Time_MultiIndicator_v1"), 
                    textT[i+1], textC[1]);
       ObjectSetText("2" + DoubleToStr(i, 0), SAR(per[i-1]), 8, 
                     "Tahoma", TxtColor);
     }
// Вторая строка   
   for(i = 1; i <= 4; i++)
     {
       ObjectDelete("3" + DoubleToStr(i, 0));
       ObjectCreate("3" + DoubleToStr(i, 0), OBJ_TEXT, 
                    WindowFind("Real_Time_MultiIndicator_v1"), 
                    textT[i+1], textC[2]);
       ObjectSetText("3" + DoubleToStr(i, 0), MACD(per[i-1]), 8, 
                     "Tahoma", TxtColor);
     }
// Третья строка   
   for(i = 1; i <= 4; i++)
     {
       ObjectDelete("4" + DoubleToStr(i, 0));
       ObjectCreate("4" + DoubleToStr(i, 0), OBJ_TEXT, 
                    WindowFind("Real_Time_MultiIndicator_v1"), 
                    textT[i+1], textC[3]);
       ObjectSetText("4" + DoubleToStr(i, 0), CMA(per[i-1]), 8, 
                     "Tahoma", TxtColor);
     }
// Четвертая строка   
   for (i=1;i<=4;i++)
     {
       ObjectDelete("5" + DoubleToStr(i, 0));
	      ObjectCreate("5" + DoubleToStr(i, 0), OBJ_TEXT, 
	                   WindowFind("Real_Time_MultiIndicator_v1"), 
	                   textT[i+1], textC[4]);
	      ObjectSetText("5" + DoubleToStr(i, 0), ADX(per[i-1]), 8, 
	                    "Tahoma", TxtColor);
	    }
//----------Fifth line   
 for (i=1;i<=4;i++)
   {
     ObjectDelete("6" + DoubleToStr(i, 0));
     ObjectCreate("6" + DoubleToStr(i, 0), OBJ_TEXT,
                  WindowFind("Real_Time_MultiIndicator_v1"),
                  textT[i+1], textC[5]);
     ObjectSetText("6" + DoubleToStr(i, 0), CCI(per[i-1]), 8, 
                   "Tahoma", TxtColor);
   }
/*// Шестая строка   
   for(i = 1; i <= 4; i++)
     {
       ObjectDelete("7" + DoubleToStr(i, 0));
	      ObjectCreate("7" + DoubleToStr(i, 0), OBJ_TEXT, 
	                   WindowFind("Real_Time_MultiIndicator_v1"), 
	                   textT[i+1], textC[6]);
	      ObjectSetText("7" + DoubleToStr(i, 0), Функция(per[i-1]), 13, 
	                    "Tahoma", TxtColor);
	    }*/
/*// Седьмая строка   
  for (i=1;i<=4;i++)
    {
      ObjectDelete("8" + DoubleToStr(i, 0));
	     ObjectCreate("8" + DoubleToStr(i, 0), OBJ_TEXT,
	                  WindowFind("Real_Time_MultiIndicator_v1"), 
	                  textT[i+1], textC[7]);
	     ObjectSetText("8" + DoubleToStr(i, 0), Функция(per[i-1]), 13, 
	                   "Tahoma", TxtColor);
	   }*/
//------------СОЗДАНИЕ ТАБЛИЦЫ
// Заголовки столбцов
   for(i = 1; i <= 5; i++)
     {   	  
	      ObjectDelete(DoubleToStr(i, 0));
	      ObjectCreate(DoubleToStr(i, 0), OBJ_TEXT, 
	                   WindowFind("Real_Time_MultiIndicator_v1"), 
	                   textT[i], textC[0]);
	      ObjectSetText(DoubleToStr(i, 0), nameS[i-1], 8, "Tahoma", 
	                    TxtColor);
	    }
// Горизонтальная разметка таблицы
   for(i = 1; i <= 7; i++)	
	    {
       ObjectDelete("Tb" + DoubleToStr(i, 0));
       ObjectCreate("Tb" + DoubleToStr(i, 0), OBJ_RECTANGLE, 
                    WindowFind("Real_Time_MultiIndicator_v1"), t1, 
                    i, t2, 9.0);
       ObjectSet("Tb" + DoubleToStr(i, 0), OBJPROP_COLOR, TColor);
       ObjectSet("Tb" + DoubleToStr(i, 0), OBJPROP_BACK, false);
     }
// Строка заголовков
   ObjectDelete("Tbl8");
   ObjectCreate("Tbl8", OBJ_RECTANGLE, 
                WindowFind("Real_Time_MultiIndicator_v1"), 
                t1, 8.0, t2, 9.0);
   ObjectSet("Tbl8", OBJPROP_COLOR, TColor);
   ObjectSet("Tbl8", OBJPROP_BACK, true);
// Вертикальная разметка таблицы  
   for(i = 1; i <= 4; i++)
     {
       ObjectDelete("Tb2" + DoubleToStr(i, 0));
       ObjectCreate("Tb2" + DoubleToStr(i, 0), OBJ_RECTANGLE, 
                    WindowFind("Real_Time_MultiIndicator_v1"), t1, 
                    1.0, tt[i], 9.0);
       ObjectSet("Tb2" + DoubleToStr(i, 0), OBJPROP_COLOR, TColor);
       ObjectSet("Tb2" + DoubleToStr(i, 0), OBJPROP_BACK, false);
     }
//----                    
   return(0);
  }
//+------------------------------------------------------------------+