//+------------------------------------------------------------------+
//|                                            News trading v3.8.mq4 |
//|                                                           vorese |
//|               2016/06/01                         vorese@yandex.ru|
//+------------------------------------------------------------------+
#property copyright "vorese"
#property link      "http://www.mql5.com"
#property version   "3.8"
#property strict
#property description " В настройках необходимо разрешить использование DLL";
#property description " Время в календаре устанавливаеться автоматически по времени компьютера";
//+------------------------------------------------------------------+
//| Импортируемые функции из wininet.dll                             |
//+------------------------------------------------------------------+
#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string sAgent,int lAccessType,
                  string sProxyName="",string sProxyBypass="",
                  int lFlags=0);
int InternetOpenUrlW(int hInternetSession,string sUrl,
                     string sHeaders="",int lHeadersLength=0,
                     int lFlags=0,int lContext=0);
int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,
                     int &lNumberOfBytesRead[]);
int HttpQueryInfoW(int hRequest,int dwInfoLevel,
                   uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
int InternetCloseHandle(int hInet);
#import
input string s1=NULL;//ОРДЕР
input int Magic=777;
input int TakeProfit=0;
input int StopLoss=100;
input double Lots=0.5;
input int  Slippage=3;
input double  max_spread=5;// максимально допустимый спред
input bool NoLoss=true;//перенос в безубыток
input int LevelWLoss=1; // Уровень безубытка
input int LevelProfit=15; //Уровень профита
input int time_cl=15;//время ожидания модификации (мин.)
input bool Trailing=true;// трал
input int TrailingStop = 20;// Фиксированный размер трала
input int TrailingStep = 3; // Шаг трала  
input bool  only_buy=true;//открыть Buy ("+/-")
input bool  only_sell=true;//открыть Sell ("+/-")
input bool open_buy=true;//открыть Buy ("=")
input bool open_sell=true;//открыть Sell ("=")
input int delay=20;//задержка откр.ордера при ("=") (сек.)
input string s2=NULL;//НАСТРОЙКИ КАЛЕНДАРЯ
input string Browser="Microsoft Internet Explorer";//Браузер
input string URL="http://ru.investing.com/economic-calendar/"; // Ссылка
input int correction_time=3;// коррекция времени в календаре
input int pause=3;//пауза между обновлениями (сек.)
input color col_text=clrBlack;
input color border=clrGreen;
input color button_off=clrLimeGreen;
input color button_on=clrGold;
input color backdrop=clrBlack;
input color trading_clr=clrWhite;
input color Col_01=clrTurquoise;
input color Col_02=clrAliceBlue;
input color Col_03=clrDarkOrange;
input color Col_04=clrLimeGreen;
input int X_DISTANCE=5;
input int Y_DISTANCE=15;
//+++++++++++++++++++++++++++++
datetime time_ind[];//время
string currency[],// валюта
volatility[],//волатильность
text_ind[],//текст
previous[],//предыдущий   
forecast[],//прогноз
fact[],//факт
compliance[];//ожидания  
             //+++++++++++++++++++++++++++++
bool modify=true;
bool order_cl=true;
bool button_0=false;
bool button_1=false;
bool button_2=false;
bool button_3=false;
bool button_4=false;
bool button_5=false;
bool button_time=false;
bool trading=false;
color col_but0=button_off;
color col_but1=button_off;
color col_but2=button_off;
color col_but3=button_off;
color col_but4=button_off;
color col_but5=button_off;
color col_but6=button_off;
string symb_0=_Symbol;
string symb_1="";
string symb_2="";
datetime time_trading=NULL;
string currency_trading="";
string forecast_trading="";
string previous_trading="";
string volatility_trading="";
string FileToSave="";
int r=0;
int t=0;
int file_size=0;
int counter_timer=1;
int str_trading=0;
int digits=0;
int mult=1;
double point=0;
datetime time_local=NULL;
datetime GMT=NULL;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
   if(button_0)col_but0=button_on;
   else
      col_but0=button_off;

   if(button_1)col_but1=button_on;
   else
      col_but1=button_off;

   if(button_2)col_but2=button_on;
   else
      col_but2=button_off;

   if(button_3)col_but3=button_on;
   else
      col_but3=button_off;

   if(button_4)col_but4=button_on;
   else
      col_but4=button_off;

   if(button_5)col_but5=button_on;
   else
      col_but5=button_off;
   ButtonCreate("table",X_DISTANCE+103,Y_DISTANCE,143,14,"  предш.   прогн.    факт."+"       ",7,col_text,Col_01,false,button_on);
   ButtonCreate("time",X_DISTANCE,Y_DISTANCE,102,14,"Local",7,col_text,Col_01,false,button_on);
   ButtonCreate("gmt",X_DISTANCE+466,Y_DISTANCE,90,14,"Trading",7,col_text,Col_01,false,button_on);
   ButtonCreate("terminal",X_DISTANCE+557,Y_DISTANCE,70,14,"terminal",7,col_text,Col_01,false,button_on);
//-------------------------------------------------------------------
//-------------------------------------------------------------------
   symb_1=StringSubstr(symb_0,0,3);
   symb_2=StringSubstr(symb_0,3,0);
   digits=_Digits;
   point=_Point;
   if(digits==3 || digits==5)mult=10;
   ArrayResize(time_ind,100);
   ArrayResize(currency,100);
   ArrayResize(volatility,100);
   ArrayResize(text_ind,100);
   ArrayResize(previous,100);
   ArrayResize(forecast,100);
   ArrayResize(fact,100);
   ArrayResize(compliance,100);
   FileToSave=(string) ChartID();
   if(Trailing && !NoLoss){Alert("трал не работает без переноса в безубыток "); return(0);}  
//--- create timer
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   f_Delete_object(r);
   ObjectDelete("table");
   ObjectDelete("time");
   ObjectDelete("gmt");
   ObjectDelete("terminal");
   ObjectDelete("button0");
   ObjectDelete("button1");
   ObjectDelete("button2");
   ObjectDelete("button3");
   ObjectDelete("button4");
   ObjectDelete("button5");
   ObjectDelete("button6");
//  ObjectsDeleteAll();
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ResetLastError();
   RefreshRates();
   int tip=-1;
   int ticket=0;
   double profit=0;
   double price=0;
   double lots=0;
   double SL=0;
   double TP=0;
   datetime time_op=0;
   bool open_order=true;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderSymbol()==symb_0 && OrderMagicNumber()==Magic)
        {
         profit=OrderProfit();
         tip=OrderType();
         lots=OrderLots();
         SL=OrderStopLoss();
         TP=OrderTakeProfit();
         ticket=OrderTicket();
         price=OrderOpenPrice();
         time_op=OrderOpenTime();
         open_order=false;
        }
     }
//------------открытие ордера------------------------------------------ 
   if(trading)
     {
      while(open_order)
        {
         RefreshRates();
         ResetLastError();
         double open_M1=iOpen(NULL,PERIOD_M1,0);
         double tp=0,sl=0;
         int error_op=-1;
         if(MarketInfo(symb_0,MODE_SPREAD)>max_spread*mult)//спред больше макс.допустимого
           { Print("Спред выше допустимого "); break;}
         if((currency[str_trading]==symb_1 && compliance[str_trading]=="+" && open_M1<Bid && only_buy)
            || (currency[str_trading]==symb_2 && compliance[str_trading]=="-" && open_M1<Bid && only_buy)
            || ((currency[str_trading]==symb_2 || currency[str_trading]==symb_1) && compliance[str_trading]=="=" && open_buy && open_M1<Bid
            && time_trading<=(GMT-delay)))
           {
            if(TakeProfit>0) tp=NormalizeDouble(Ask+TakeProfit*point*mult,digits);
            if(StopLoss>0) sl=NormalizeDouble(Ask-StopLoss*point*mult,digits);
            RefreshRates();
            if(OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(Ask,digits),Slippage*mult,sl,tp,"News trading",Magic,0,clrGreen)>0)
              {
               button_5=false;col_but5=button_off; return;
              }
            error_op=f_Error(GetLastError());
            switch(error_op)
              {
               case 0: button_5=false; col_but5=button_off; Alert("Ошибка открытия ордера."); return;
               case 1:continue;
               case 2: break;
              }
           }
         if((currency[str_trading]==symb_1 && compliance[str_trading]=="-" && open_M1>Bid && only_sell)
            || (currency[str_trading]==symb_2 && compliance[str_trading]=="+" && open_M1>Bid && only_sell)
            || ((currency[str_trading]==symb_2 || currency[str_trading]==symb_1) && compliance[str_trading]=="=" && open_sell && open_M1>Bid
              && time_trading<=(GMT-delay)))
           {
            if(TakeProfit>0) tp=NormalizeDouble(Bid-TakeProfit*point*mult,digits);
            if(StopLoss>0) sl=NormalizeDouble(Bid+StopLoss*point*mult,digits);
            RefreshRates();
            if(OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(Bid,digits),Slippage*mult,sl,tp,"News trading",Magic,0,clrRed)>0)
              {
               button_5=false; col_but5=button_off;  return;
              }
            error_op=f_Error(GetLastError());
            switch(error_op)
              {
               case 0: button_5=false;  col_but5=button_off;Alert("Ошибка открытия ордера."); return;
               case 1:continue;
               case 2: break;
              }
           }
         break;
        }
     }
//---------------- Перенос в безубыток. Трал--------------------------
   while(modify)
     {
      ResetLastError();
      RefreshRates();
      double f_level=MarketInfo(symb_0,MODE_FREEZELEVEL);
      double stoploss=0;
      bool or_mod=false;
      int error_mod=-1;
      if(tip==OP_BUY && (TP==0 || TP-f_level*point>Bid))
        {
         if(( NoLoss && SL<price && Bid-price>=LevelProfit*point*mult)
            || (Trailing && SL>=price && Bid>SL+(TrailingStop+TrailingStep)*point*mult))
           {
            if(SL<price)stoploss=NormalizeDouble(price+LevelWLoss*point*mult,digits);
            if(Trailing  &&  SL>=price)stoploss=NormalizeDouble(SL+TrailingStep*point*mult,digits);
            or_mod=OrderModify(ticket,price,stoploss,TP,0);
            if(or_mod) return;
            error_mod=f_Error(GetLastError());
            switch(error_mod)
              {
               case 0: modify=false; Alert("Ошибка модификации ордера. Переустановите советник"); return;
               case 1: continue;
               case 2: break;
              }
           }
        }
      if(tip==OP_SELL && (TP==0 || TP+f_level*point<Ask))
        {
         if(( NoLoss && (SL>price || SL==0) && price-Ask>=LevelProfit*point*mult)
            || (Trailing && SL<=price && SL>0 && Ask<SL-(TrailingStop+TrailingStep)*point*mult))
           {
            if(SL>price || SL==0)stoploss=NormalizeDouble(price-LevelWLoss*point*mult,digits);
            if(Trailing  &&  SL<=price && SL!=0)stoploss=NormalizeDouble(SL-TrailingStep*point*mult,digits);
            or_mod=OrderModify(ticket,price,stoploss,TP,0);
            if(or_mod) return;
            error_mod=f_Error(GetLastError());
            switch(error_mod)
              {
               case 0: modify=false; Alert("Ошибка модификации ордера. Переустановите советник"); return;
               case 1: continue;
               case 2: break;
              }
           }
        }
      break;
     }
//====== Закрытие ордера==============================================
   while(order_cl)
     {
      ResetLastError();
      RefreshRates();
      int error_cl=-1;
      bool close_order=false;
      if(tip==OP_BUY && time_cl>0 && SL<price && TimeCurrent()-time_cl*60>=time_op && Bid>price)
        {
         RefreshRates();
         close_order=OrderClose(ticket,lots,NormalizeDouble(Bid,digits),Slippage*mult,clrGreen);
         if(close_order)
           {
            button_5=false; return;
           }
         error_cl=f_Error(GetLastError());
         switch(error_cl)
           {
            case 0: order_cl=false; Alert("Ошибка закрытия ордера. Переустановите советник"); return;
            case 1: continue;
            case 2: break;
           }
        }
      if(tip==OP_SELL && time_cl>0 && (SL>price || SL==0) && TimeCurrent()-time_cl*60>=time_op && Ask<price)
        {
         RefreshRates();
         close_order=OrderClose(ticket,lots,NormalizeDouble(Ask,digits),Slippage*mult,clrRed);
         if(close_order)
           {
            button_5=false; return;
           }
         error_cl=f_Error(GetLastError());
         switch(error_cl)
           {
            case 0: order_cl=false; Alert("Ошибка закрытия ордера. Переустановите советник"); return;
            case 1: continue;
            case 2: break;
           }
        }
      break;
      }  
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnTimer()
  {
   ResetLastError();
   GMT=TimeGMT();
   time_local=TimeLocal(); 

   ObjectSetString(0,"terminal",OBJPROP_TEXT,TimeToString(TimeCurrent(),TIME_SECONDS));
//===========условия для загрузки страницы============================
   if(counter_timer==0)
     {
                   
      if(button_4  || file_size<100000 ) // нажата кнопка "обновить" индикатора или страница не загружена
        {
         file_size=f_Calendar(URL,FileToSave,Browser);
         button_4=false; col_but4=button_off;
        }
     }
   counter_timer++;
   if(counter_timer>=pause)counter_timer=0;
//=====верхняя строка календаря=======================================
   ObjectSetString(0,"time",OBJPROP_TEXT,TimeToString(time_local,TIME_SECONDS));
   ButtonCreate("button0",X_DISTANCE+247,Y_DISTANCE,38,14," текст",6,col_text,col_but0,button_0,button_on);
   ButtonCreate("button1",X_DISTANCE+286,Y_DISTANCE,25,14," $$$",6,col_text,col_but1,button_1,button_on);
   ButtonCreate("button2",X_DISTANCE+312,Y_DISTANCE,25,14," $$",6,col_text,col_but2,button_2,button_on);
   ButtonCreate("button3",X_DISTANCE+338,Y_DISTANCE,25,14," $",6,col_text,col_but3,button_3,button_on);
   ButtonCreate("button4",X_DISTANCE+364,Y_DISTANCE,50,14," обновить",6,col_text,col_but4,button_4,button_on);
   ButtonCreate("button5",X_DISTANCE+415,Y_DISTANCE,50,14," торговля",6,col_text,col_but5,button_5,button_on);

//=====читаем файл , находим начало и конец таблицы===================
   int handle;
   int string_counter=0;
   int begin_table=0;
   int end_table=0;
   string temp_array[];
   ArrayResize(temp_array,6000);
   handle=FileOpen(FileToSave,FILE_CSV|FILE_READ|FILE_SHARE_READ,CP_ACP);
   if(handle<1)Print("Файл не прочитан ",handle);
   else
   while(!FileIsEnding(handle))
     {
      temp_array[string_counter]=FileReadString(handle);
      if(f_Position(temp_array[string_counter],0)>=0 && string_counter>600)
        {
         begin_table=string_counter;
        }
      if(begin_table>0 && f_Position(temp_array[string_counter],1)>=0)
        {
         end_table=string_counter; break;
        }
      string_counter++;
     }
   FileClose(handle);
//===============Вырезаем текст из тегов==============================
   string array_table="",
   volatility_str="?",
   compliance_str="?",
   previous_str="",
   prev_prev="",
   forecast_str="",
   fact_str="";

   int sum_string=0,
   td_class=0,
   td=0,
   a=0,
   angle=0,
   span=0,
   span_1=0,
   pos_begin=0,
   pos_end=0,
   counter_news=0,
   pos_t=0;
   int i=begin_table;
//---------------------------------------------------------------------
   while(i<end_table) 
     {
      td_class=f_Position(temp_array[i],2);
      td=f_Position(temp_array[i],3);
      a=f_Position(temp_array[i],15);
      if(td_class<0 && td<0 && a<0) // ищем строки новостей 
        {sum_string=0;  i++; continue; }
      else
        {
         if(td_class>0 && td<0)
           { i++;continue;}
         else
           {
            if(td_class<0 && td>0)
              { i++;continue;}

            sum_string++;
           }
        }
      angle=f_Position(temp_array[i],4);
      span=f_Position(temp_array[i],5);
      span_1=f_Position(temp_array[i],6);
      pos_t=f_Position(temp_array[i],14);

    //  if(sum_string==1) //время
    //    {
    //     if(f_Position(temp_array[i-1],16)>0)
    //        time_ind[counter_news]=Str_Time(StringSubstr(temp_array[i-1],f_Position(temp_array[i-1],16)+17,19));
    //    }
         if(sum_string==1) //время
        {
            time_ind[counter_news]=Str_Time(StringSubstr(temp_array[i-1],f_Position(temp_array[i-1],4)-20,18))-correction_time*3600;
        }   
        
      if(sum_string==2) //валюта
        { currency[counter_news]=StringSubstr(temp_array[i],span+8,3);  }

      if(sum_string==3) //волатильность
        {
         array_table=StringSubstr(temp_array[i],0,angle);
         volatility_str=f_Cyrillic(array_table);

         if(f_Position(volatility_str,7)>0)
            volatility[counter_news]="$$$";
         else
           {
            if(f_Position(volatility_str,8)>0)
               volatility[counter_news]="$$";
            else
              {
               if(f_Position(volatility_str,9)>0)
                  volatility[counter_news]="$";
               else
                 {
                  volatility[counter_news]="?";
                 }
              }
           }
        }
      if(sum_string==4) //текст
        {
         if(a>0)
            array_table=StringSubstr(temp_array[i],0,a);
         text_ind[counter_news]=StringTrimLeft(f_Cyrillic(array_table));
        }

      if(sum_string==5) //результат ожиданий , факт
        {
         array_table=StringSubstr(temp_array[i],0,angle+1);
         compliance_str=f_Cyrillic(array_table);
         
         if(f_Position(compliance_str,10)>0)
            compliance[counter_news]="+";
         else
           {
            if(f_Position(compliance_str,11)>0)
               compliance[counter_news]="=";
            else
              {
               if(f_Position(compliance_str,12)>0)
                  compliance[counter_news]="-";
               else
                 {
                  compliance[counter_news]="?";
                 }
              }
           }
         fact_str=StringSubstr(temp_array[i],angle+1,td-angle-1);
         if(f_Position(fact_str,13)>=0)
            fact[counter_news]="----";
         else
            fact[counter_news]=fact_str;
        }
      if(sum_string==6) //прогноз
         forecast_str=StringSubstr(temp_array[i],angle+1,td-angle-1);
      if(f_Position(forecast_str,13)>=0)
         forecast[counter_news]="----";
      else
         forecast[counter_news]=forecast_str;
         
      if(sum_string==7) //предшествующий  
      {   
        // previous_str=StringSubstr(temp_array[i],angle+1,td-angle-1);
         prev_prev=StringSubstr(temp_array[i],angle+1,span-angle-1);
         previous_str=StringSubstr(prev_prev,f_Position(prev_prev,4)+1,0); 
      if(f_Position(previous_str,13)>=0)
         previous[counter_news]="----";
      else
         previous[counter_news]=previous_str;
       counter_news++;
      }
      i++;
      if(counter_news==100)break;// не более 100 строк
     }    
//=========формируем таблицу==========================================    

   if(counter_news!=r)//удаляем все объекты после измен. в календаре
     {
      f_Delete_object(r);
      for(int z=0;z<counter_news;z++)//проверим номер выбранной строки
        {
         if(time_trading==time_ind[z] && currency_trading==currency[z] && forecast_trading==forecast[z] && volatility_trading==volatility[z])
           {
            str_trading=z; break;
           }
        }
     }
   r=0; t=0;
   color color_button=Col_04;
   color color_compliance=Col_04;

   while(r!=counter_news) //фильтруем по волатильности
     {
      if(volatility[r]=="$$$" && button_1)
        {
         r++;continue;
        }

      if(volatility[r]=="$$" && button_2)
        {
         r++;continue;
        }

      if(volatility[r]=="$" && button_3)
        {
         r++;continue;
        }
      //---------------------------------------------------------------   
         //цвет прошедших и будущих новостей 
      if(button_5 && str_trading==r && button_time)
        {
         if(currency_trading==symb_1 || currency_trading==symb_2) color_button=trading_clr;
        }
      else
        {
         if(time_ind[r]>=TimeGMT())
            color_button=Col_04;
         else
            color_button=Col_01;
        }  
      if(compliance[r]=="+")color_compliance=Col_02;
      else
        {
         if(compliance[r]=="-")color_compliance=Col_03;
         else
           {
            color_compliance=color_button;
           }
        }
      // создаем таблицу
      ButtonCreate("time"+(string)(r),X_DISTANCE,Y_DISTANCE+16+11*t,40,11, TimeToString(time_ind[r]-TimeGMTOffset(),TIME_MINUTES),6,col_text,color_button,false,border);
      ButtonCreate("currency"+(string)(r),X_DISTANCE+41,Y_DISTANCE+16+11*t,30,11,currency[r],6,col_text,color_button,false,border);
      ButtonCreate("volatility"+(string)(r),X_DISTANCE+72,Y_DISTANCE+16+11*t,30,11,volatility[r],6,col_text,color_button,false,border);
      ButtonCreate("previous"+(string)(r),X_DISTANCE+103,Y_DISTANCE+16+11*t,40,11,previous[r],6,col_text,color_button,false,border);
      ButtonCreate("forecast"+(string)(r),X_DISTANCE+144,Y_DISTANCE+16+11*t,40,11,forecast[r],6,col_text,color_button,false,border);
      ButtonCreate("fact"+(string)(r),X_DISTANCE+185,Y_DISTANCE+16+11*t,40,11,fact[r],6,col_text,color_compliance,false,border);
      ButtonCreate("compliance"+(string)(r),X_DISTANCE+226,Y_DISTANCE+16+11*t,20,11,compliance[r],6,col_text,color_compliance,false,border);
      if(!button_0)
        {
         RectLabelCreate("LabelCreate"+(string)r,X_DISTANCE+247,Y_DISTANCE+15+11*t,380,12,backdrop,backdrop);
         f_Label("text"+(string)r,X_DISTANCE+250,Y_DISTANCE+15+11*t,(string)(r+1)+" "+text_ind[r],7,color_button);
        }
      r++; t++;
     }
      if(!button_5)
     {
      button_time=false;
      time_trading=NULL; currency_trading=""; previous_trading=""; forecast_trading=""; volatility_trading="";
      ObjectSetString(0,"gmt",OBJPROP_TEXT,"№"+(string)(str_trading+1));
     }
   //==============условия для торговли=================================
   if(button_5 && button_time)// если выбрана строка календаря
     {
      ObjectSetString(0,"gmt",OBJPROP_TEXT,"№"+(string)(str_trading+1)+"# "+TimeToString(time_ind[str_trading]-GMT,TIME_SECONDS));
      if(!IsTradeAllowed()) Alert("ERR_TRADE_NOT_ALLOWED # 4109");
         if(currency_trading==symb_1 || currency_trading==symb_2) // если наша валюта
           {
            if(GMT>=time_trading && GMT-120<=time_trading)
              {
               if(compliance[str_trading]=="?")
                 {
                  file_size=0; // перезагрузим календарь если еще нет результатов
                  trading=true;
                 }
              }
            else
               trading=false;
           }
     }
   else
      trading=false;   
//===================================================================
   ChartRedraw();
  }
//====================================================================
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
//====================================================================  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- проверка события нажатия на кнопку мыши
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--------------кнопка "текст"----------------------------------    
      if(sparam=="button0" && !button_0)
        {
         button_0=true; col_but0=button_on;f_Delete_object(r);// запомним , что кнопка нажата
         return;
        }
      if(sparam=="button0" && button_0)
        {
         button_0=false; col_but0=button_off;f_Delete_object(r); // запомним , что кнопка отжата
         return;
        }
      //---------------кнопка "$$$"-----------------------------------
      if(sparam=="button1" && !button_1)
        {
         button_1=true; col_but1=button_on;f_Delete_object(r); return;
        }
      if(sparam=="button1" && button_1)
        {
         button_1=false; col_but1=button_off;f_Delete_object(r); return;
        }
      //---------------кнопка "$$"------------------------------------
      if(sparam=="button2" && !button_2)
        {
         button_2=true; col_but2=button_on;f_Delete_object(r); return;
        }
      if(sparam=="button2" && button_2)
        {
         button_2=false; col_but2=button_off;f_Delete_object(r); return;
        }
      //---------------кнопка "$"--------------------------------------
      if(sparam=="button3" && !button_3)
        {
         button_3=true; col_but3=button_on;f_Delete_object(r); return;
        }
      if(sparam=="button3" && button_3)
        {
         button_3=false; col_but3=button_off;f_Delete_object(r); return;
        }
      //---------------кнопка "обновить"------------------------------
      if(sparam=="button4" && !button_4)
        {
         button_4=true; col_but4=button_on; return;
        }
      if(sparam=="button4" && button_4)
        {
         button_4=false; col_but4=button_off; return;
        }
      //-------------кнопка "торговля"--------------------------------
      if(sparam=="button5" && !button_5)
        {
         button_5=true; col_but5=button_on; return;
        }
      if(sparam=="button5" && button_5)
        {
         button_5=false; col_but5=button_off; str_trading=0; return;
        }
      //------------------кнопки"time"+(string)r----------------------
      for(int d=0;d<=r;d++)
        {
         if(sparam=="time"+(string)d && button_5)
           {
            str_trading=d; button_time=true;
            time_trading=time_ind[d];
            currency_trading=currency[d];
            previous_trading=previous[d];
            forecast_trading=forecast[d];
            volatility_trading=volatility[d];
            ChartRedraw();
            return;
           }
        }
     }
   ChartRedraw();
//--------------------------------------------------------------------
   return;
  }
//+------------------------------------------------------------------+
//====================================================================  
datetime Str_Time(string str)
  {
   string ss="";
   string dd="";
   datetime time=NULL;
   for(int u=0;u<=StringLen(str)-1;u++)
     {
      dd=StringSubstr(str,u,1);                             
      if(dd=="-" || dd=="/")dd=".";        
         ss+=dd;            
        }
   time=StrToTime(ss);
   return(time);
  }
//======загрузка страницы=============================================
int f_Calendar(string addr,string filename,string browser)
  {
   int rv = InternetAttemptConnect(0);
   if(rv != 0)
     {
      Print("Ошибка при вызове InternetAttemptConnect()");
      return(-1);
     }

   int hInternetSession=InternetOpenW(browser,0,"","",0);
   if(hInternetSession<=0)
     {
      Print("Ошибка при вызове InternetOpenW()");
      return(-1);
     }
   int hURL=InternetOpenUrlW(hInternetSession,addr,"",0,0,0);
   if(hURL<=0)
     {
      Print("Ошибка при вызове InternetOpenUrlW()");
      InternetCloseHandle(hInternetSession);
      return(-1);
     }
   int dwBytesRead[1];
   bool flagret=true;
   uchar buffer[1024];
   int cnt=0;

   int h=FileOpen(filename,FILE_BIN|FILE_WRITE);
   if(h<=0)
     {
      Print("Ошибка при вызове FileOpen(), имя файла ",filename," ошибка ",GetLastError());
      InternetCloseHandle(hInternetSession);
      return(-1);
     }

   while(!IsStopped())
     {
      bool bResult=InternetReadFile(hURL,buffer,1024,dwBytesRead);
      cnt+=dwBytesRead[0];
      if(dwBytesRead[0]==0) break;
      FileWriteArray(h,buffer,0,dwBytesRead[0]);
     }
   if(h>0) FileClose(h);

   if(cnt<100000)
     {
      FileDelete(filename);
      PrintFormat("Файл загружен не полностью, Размер файла =%d байт.",cnt);
     }
   else
      PrintFormat("Файл успешно загружен, Размер файла =%d байт.",cnt);
   InternetCloseHandle(hInternetSession);
   return(cnt);
  }
//===================================================================
void f_Delete_object(int max)
  {
   for(int v=0;v<max;v++)
     {
      ObjectDelete("time"+(string)v);
      ObjectDelete("currency"+(string)v);
      ObjectDelete("volatility"+(string)v);
      ObjectDelete("previous"+(string)v);
      ObjectDelete("forecast"+(string)v);
      ObjectDelete("fact"+(string)v);
      ObjectDelete("compliance"+(string)v);
      ObjectDelete("text"+(string)v);
      ObjectDelete("LabelCreate"+(string)v);
     }
  }
  //===========перекодируем в кириллицу================================
string f_Cyrillic(string text_str)
  {
   uchar char_code=0;
   uchar  code=0;
   uchar flag=0;
   string ansi="";
   uchar array_ansi[];
   int count_array=StringToCharArray(text_str,array_ansi,0,-1,CP_ACP);

   for(int c=0;c<count_array;c++)
     {
      code=array_ansi[c];
      if(code==208) { flag=1;continue;}  //P
      else
        {
         if(code==209) { flag=2;continue;}   //C
         else
           {
            if(code==145 && flag==2)char_code=184; //ё
            else
              {
               if(code<32) char_code=32;
               else
                 {
                  if(code<128) char_code=code;
                  else
                    {
                     if(flag==1) char_code=code+48;
                     else
                       {
                        if(flag==2) char_code=code+112;
                       }
                    }
                 }
              }
           }
        }
      ansi=ansi+CharToString(char_code);
     }
   return(ansi);
  }
//===================позиции  подстрок================================
int f_Position(string text_str,int flags)
  {
   string tegi[17]=
     {
      "<table id=","</table>","<td class=","</td>",">","</span>","<span",
      "Высокая","Умеренная","Низкая","Лучше","соответствии","Хуже","&nbsp;","evtStrtTime","</a>","event_timestamp"
     };
   int position=StringFind(text_str,tegi[flags],0);
   return(position);
  }
//====================================================================  
//+------------------------------------------------------------------+
//| Создает текстовую метку                                          |
//+------------------------------------------------------------------+
bool f_Label(
             const string            name="Label",             // имя метки               
             const int               x=0,                      // координата по оси X
             const int               y=0,                      // координата по оси Y                 
             const string            text="error",             // текст
             const int               font_size=10,             // размер шрифта                         
             const color             clr=clrRed,               // цвет
             //------------------------------------------------------
             const string            font="Verdana",           // шрифт   
             const double            angle=0.0,                // наклон текста
             const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки
             const bool              back=false,               // на заднем плане
             const bool              selection=false,          // выделить для перемещений
             const bool              hidden=true,              // скрыт в списке объектов
             const long              chart_ID=0,               // ID графика
             const int               sub_window=0,             // номер подокна
             const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
             const long              z_order=0)                // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
   if(ObjectFind(name)==-1)
     {
      //--- создадим текстовую метку
      ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0);
      //--- установим координаты метки
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- установим угол графика, относительно которого будут определяться координаты точки
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- установим текст
      // ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- установим шрифт текста
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- установим размер шрифта
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- установим угол наклона текста
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      //--- установим способ привязки
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      //--- установим цвет
      // ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- отобразим на переднем (false) или заднем (true) плане
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- включим (true) или отключим (false) режим перемещения метки мышью
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- установим приоритет на получение события нажатия мыши на графике
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);

//--- успешное выполнение
   return(true);
  }
//+------
//===============кнопки==============================================
bool ButtonCreate(const string  name="button",      // имя кнопки
                  const int x=0,                    // координата по оси X
                  const int y=0,                    // координата по оси Y
                  const int width=0,                // ширина кнопки
                  const int height=0,               // высота кнопки
                  const string text="error",        // текст
                  const int font_size=6,            // размер шрифта
                  const color clr=clrNONE,          // цвет текста
                  const color  back_clr=clrNONE,    // цвет фона 
                  const bool state=false,           // нажата/отжата                                                  
                  const color border_clr=clrNONE,   // цвет границы  
                  //------------------------------------------------   
                  const string  font="Verdana",     // шрифт            
                  const bool back=false,            // на заднем плане
                  const bool selection=false,       // выделить для перемещений
                  const bool hidden=false,          // скрыт в списке объектов
                  const long z_order=0)             // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();

   if(ObjectFind(name)==-1)
     {
      //--- создадим кнопку
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
      //--- установим координаты кнопки
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      //--- установим размер кнопки
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      //--- установим угол графика, относительно которого будут определяться координаты точки
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //--- установим текст
      //  ObjectSetString(0,name,OBJPROP_TEXT,text);
      //--- установим шрифт текста
      ObjectSetString(0,name,OBJPROP_FONT,font);
      //--- установим размер шрифта
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
      //--- установим цвет текста
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      //--- установим цвет фона
      //    ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr);
      //--- установим цвет границы
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border_clr);
      //--- отобразим на переднем (false) или заднем (true) плане
      ObjectSetInteger(0,name,OBJPROP_BACK,back);
      //--- включим (true) или отключим (false) режим перемещения кнопки мышью
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
      //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
      //--- установим приоритет на получение события нажатия мыши на графике
      ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
      //----- нажата/отжата
      //  ObjectSetInteger(0,name,OBJPROP_STATE,state);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_STATE,state);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr);
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Создает прямоугольную метку                                      |
//+------------------------------------------------------------------+
bool RectLabelCreate(
                     const string           name="RectLabel",          // имя метки                    
                     const int              x=0,                       // координата по оси X
                     const int              y=0,                       // координата по оси Y
                     const int              width=500,                 // ширина
                     const int              height=180,                // высота
                     const color            back_clr=clrRed,           // цвет фона                    
                     const color            clr=clrRed,                // цвет плоской границы (Flat)
                     //---------------------------------------------------------------------------
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,         // стиль плоской границы
                     const int              line_width=1,              // толщина плоской границы
                     const bool             back=false,                // на заднем плане
                     const bool             selection=false,           // выделить для перемещений
                     const bool             hidden=false,              // скрыт в списке объектов
                     const long             chart_ID=0,                // ID графика
                     const int              sub_window=0,              // номер подокна
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER,  // угол графика для привязки
                     const ENUM_BORDER_TYPE border_lab=BORDER_FLAT,    // тип границы
                     const long             z_order=0)                 // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();

   if(ObjectFind(name)==-1)
     {
      //--- создадим прямоугольную метку     
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
      //--- установим координаты метки
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- установим размеры метки
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- установим цвет фона
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- установим тип границы
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border_lab);
      //--- установим угол графика, относительно которого будут определяться координаты точки
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- установим цвет плоской рамки (в режиме Flat)
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- установим стиль линии плоской рамки
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      //--- установим толщину плоской границы
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      //--- отобразим на переднем (false) или заднем (true) плане
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- включим (true) или отключим (false) режим перемещения метки мышью
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- установим приоритет на получение события нажатия мыши на графике
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
//--- успешное выполнение
   return(true);
  }
//====================================================================
int f_Error(int err)
  {
   switch(err)
     {
      case   0: Print("Нет ошибки  # 0"); return(2);
      case   1: Print("результат неизвестен  # 1"); return(2);
      case   4: Sleep(3000);Print("Торговый сервер занят  # 4"); return(1);
      case   6: Print("Нет связи с сервером"); return(2);
      case   8: Sleep(10000);Print("Слишком частые запросы  # 8"); return(1);
      case 128: Sleep(6000);Print("Истек срок ожидания совершения сделки  # 128"); return(1);
      case 129: Print("Неправильная цена  # 129");return(1);
      case 130: Print("Неправильные стопы  # 130");return(0);
      case 135: Print("Цена изменилась  # 135");return(1);
      case 136: while(RefreshRates()==false) Sleep(1);Print("Нет цен  # 136");return(1);
      case 137: Sleep(3000); Print("Брокер занят  # 137");return(1);
      case 138: Print("Новые цены  # 138");return(1);
      case 139: Sleep(10000);Print("Ордер заблокирован и уже обрабатывается  # 139"); return(2);
      case 141: Sleep(5000);Print("Слишком много запросов  # 141"); return(1);
      case 146: Sleep(1000);Print("Подсистема торговли занята  # 146"); return(1);
      default: Print("Торговля остановлена . Ошибка # ",err); return(0);
     }
  }
//+------------------------------------------------------------------+
