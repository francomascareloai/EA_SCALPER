//+------------------------------------------------------------------+
//|                                             i-UrovenZero-Uni.mq4 |
//|                      Bor-ix i Kirill + помощь d_tom i Don_Leone  |
//+------------------------------------------------------------------+
#property copyright "Bor-ix i Kirill"

#property indicator_chart_window

//Индикатор рисует два уровеня на графике торгуемой валюты, при достижении которого ценой 
//все открытые позиции в сумме уйдут в такой минус, что свободная маржа станет равна нулю (уровень ZeroMargin)
//и при достижения ценой уровня при котором все открытые ордера в сумме будут равны нулю (уровень ZeroProfit)...
//Работает только при торговле по одной валюте.
//Отложенные ордера не принимаются в расчёт

//Варианты режима расчета могут принимать следующие значения:
//v.0 - "Нереализованные прибыли/убытки не используются. Свобожная маржа не зависит от тек. цены."
//v.1 - "При расчете свободных средств используется как нереализованная прибыль, так и убыток по открытым позициям на текущем счете."
//v.2 - "Нереализованные убытки не используются. Свобожная маржа не уменьшается при изменении тек. цены."
//v.3 - "При расчете используется только значение убытка, текущая прибыль по открытым позициям не учитывается. Будет рассчитано два уровня."
 
extern string CALC_Bar_0         = "=== Панель Расчетов ===";
extern bool    CALC_0            = false;

extern double  Lots_R            = 1.0;      // вводим значение объема лота
extern double  Rastojanie_R      = 100.0;    // вводим значение растояния в пунктах
extern double  Pribyl_R          = 0.0;      // вводим значение прибыли/убытка в центах

extern color   cvet_CALC_0       = Violet;   //цвет основной надписи панели
extern color   cvet_CALC_R       = Yellow;   //цвет надписи результата расчетов
extern int     Ugol_0            = 2;        // положение на графике
extern int     MP_X_0            = 10;       // значение координат по горизонтали 
extern int     MP_Y_0            = 10;       // значение координат по вертикали

extern string Shrift_Bar         = "=== Размер Шрифта ===";
extern int     RazmerShrifta     = 9;

extern string ZeroProfit_Block   = "=== Парам. Общего Безубытка ===";
extern bool    ZeroProfit        = true;
extern color   Colour_ZP         = DarkTurquoise;
extern int     Style_ZP          = 1;        //0,1,2,3,4
extern int     Width_ZP          = 2;        //0,1,2,3,4

extern string ZeroBUY_Block      = "=== Парам. Безубытка для BUY ===";
extern bool    ZeroBUY           = true;
extern color   Colour_ZB         = DarkTurquoise;
extern int     Style_ZB          = 2;        //0,1,2,3,4
extern int     Width_ZB          = 1;        //0,1,2,3,4

extern string ZeroSELL_Block     = "=== Парам. Безубытка для SELL ===";
extern bool    ZeroSELL          = true;
extern color   Colour_ZS         = DarkTurquoise;
extern int     Style_ZS          = 2;        //0,1,2,3,4
extern int     Width_ZS          = 1;        //0,1,2,3,4

extern string ZeroMargin_Block   = "=== Парам. Нулевой Маржи ===";
extern bool    ZeroMargin        = true;
extern color   Colour_ZM         = Yellow;
extern int     Style_ZM          = 0;        //0,1,2,3,4  
extern int     Width_ZM          = 2;        //0,1,2,3,4

extern string ZeroMarginPr_Block = "=== Парам. % Нулевой Маржи ===";
extern bool    ZeroMarginPr      = true;
extern int     Procent_ZM        = 150;      // проценты от общего уровня для предупреждения
extern int     Style_ZM_Procent  = 2;        //0,1,2,3,4 
extern int     Width_ZM_Procent  = 1;        //0,1,2,3,4 

extern string Zona_LOCK_Param    = "=== Парам. Зоны LOCK ===";
extern bool    Cvet_zony_LOCK_p  = false;  
extern color   Cvet_zony_LOCK    = C'70,70,00';   // цвет зоны LOCK

extern string ZeroFull_Block     = "=== Парам. Полного СЛИВА ===";
extern bool    ZeroFull          = true;
extern color   Colour_ZF         = Red;
extern int     Style_ZF          = 0;        //0,1,2,3,4  
extern int     Width_ZF          = 2;        //0,1,2,3,4

extern string ZeroFull_Pr_Block  = "=== StopOut/Принуд.Закр.Ордеров ===";
extern bool    ZeroFull_Pr       = true;
extern int     Style_ZF_Procent  = 2;        //0,1,2,3,4  
extern int     Width_ZF_Procent  = 1;        //0,1,2,3,4  

extern string Zona_dDZ_Param     = "=== Парам. Мертвой Зоны ===";
extern bool    Cvet_zony_dDZ_f   = false;
extern color   Cvet_zony_dDZ     = C'70,00,00';   // цвет зоны DEAD ZONE

extern string INFO_Bar_1         = "=== Панель Информации 1 ===";
extern bool    INFO_1            = true;
extern int     Ugol              = 3;        // положение на графике
extern int     MP_X              = 10;       // значение координат по горизонтали 
extern int     MP_Y              = 10;       // значение координат по вертикали

extern string INFO_Bar_2         = "=== Панель Информации 2 ===";
extern bool    INFO_2            = false;
extern color   cvet_dop_info     = Silver;   // цвет инфо. панели 2
extern int     Ugol_2            = 3;        // положение на графике
extern int     MP_X_2            = 10;       // значение координат по горизонтали 
extern int     MP_Y_2            = 10;       // значение координат по вертикали

extern string INFO_Bar_3         = "=== Панель Информации 3 ===";
extern int     Ugol_3            = 1;        // положение на графике инфо. панели 3

extern string Sound_Bar          = "=== Воспроизведение Звука ===";
extern bool    SoundPlay_Menshe  = true;
extern string  Sound_Alert       = "Alert.wav";
extern bool    SoundPlay_Bolshe  = false;
extern string  Sound_OK          = "clock.wav";

string comment = "";


//---------------------------------------------------------------------------------------------//
//стирание нарисованных объектов
//---------------------------------------------------------------------------------------------// 
   
   ObjectDelete ("Уровень Нулевой Маржи");
   ObjectDelete ("Уровень СЛИВА");
   
   ObjectDelete ("LOCK");
   ObjectDelete ("DEAD ZONE");
   ObjectDelete ("DEAD ZONE =");
   ObjectDelete ("DEAD ZONE = 2");
   ObjectDelete ("GAME OVER");
   ObjectDelete ("GAME OVER 2");
   ObjectDelete ("GAME OVER 3");
   ObjectDelete ("Стоимость 1 пп для 1 лота - инфо");
         
   ObjectDelete ("Проценты до Уровня Нулевой Маржи");
   ObjectDelete ("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut");
   ObjectDelete ("Общий Уровень Безубытка");
   ObjectDelete ("Уровень Безубытка BUY");
   ObjectDelete ("Уровень Безубытка SELL");
   ObjectDelete ("Расстояние до Общего Уровня Безубытка - инфо");
   ObjectDelete ("Общий Уровень Безубытка - инфо");
   ObjectDelete ("Расстояние до Нулевой Маржи - инфо");
   ObjectDelete ("Уровень Нулевой Маржи - инфо");
   ObjectDelete ("Уровень СЛИВА - инфо");
   ObjectDelete ("Мертвая Зона - инфо");
   ObjectDelete ("Мертвая Зона - цвет");
   ObjectDelete ("Зона LOCK - цвет"); 
   ObjectDelete ("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо");
   
   ObjectDelete ("Можно купить лотов - инфо");
   ObjectDelete ("Залог за минимальнй лот - инфо");
   ObjectDelete ("Минимальный лот - инфо");
   ObjectDelete ("Максимальный лот - инфо");
   ObjectDelete ("Спред, пп - инфо");
   ObjectDelete ("Своп BUY, пп - инфо");
   ObjectDelete ("Своп SELL, пп - инфо");
   
   ObjectDelete ("Прибыль - Расчет");
   ObjectDelete ("Расстояние - Расчет");
   ObjectDelete ("Объем Лота - Расчет");
   ObjectDelete ("Панель Расчета - Расчет");
   ObjectDelete ("Комментарии - Расчет");
   
   ObjectDelete ("ZeroLevel");
   ObjectDelete ("ZeroLevel_BUY");
   ObjectDelete ("ZeroLevel_SELL");
   
   Comment("");


//---------------------------------------------------------------------------------------------//
//расчет уровней профит-нуля безубытка по выставленным ордерам в одном направлении
//---------------------------------------------------------------------------------------------// 

int start()
{
  
   double i, total = OrdersTotal();
      double lots=0.0, shift, shift_ZLB, shift_ZLS;
      Comment_("----------------------------"); 
      Comment_(" " + AccountName());
      string type = "Реал"; if (IsDemo()) type = "Демо";
      Comment_(" Тип счета: " + type + " - №: " + AccountNumber());
      Comment_(" Плечо: 1/" + AccountLeverage());
      Comment_("----------------------------"); 

      double minlot = MarketInfo(Symbol(),MODE_MINLOT);           //размер минимального лота
      double maxlot = MarketInfo(Symbol(),MODE_MAXLOT);           //размер макимального лота
      double lot_cena = MarketInfo(Symbol(),MODE_MARGINREQUIRED); //цена 1.0 лота
      double lot_zalog = MarketInfo(Symbol(),MODE_MARGININIT);    //залог за 1.0 лот
      double min_balans = (lot_cena + lot_zalog) * minlot;        //расчет стоимости минимального лота
      double lotsss = AccountFreeMargin()*minlot/min_balans;      //количество лотов которое можно купить
      double pp_cena = MarketInfo(Symbol(),MODE_TICKVALUE);       //цена одного пункта
      double swap_long = MarketInfo(Symbol(),MODE_SWAPLONG);      //своп для BUY в пунктах
      double swap_short = MarketInfo(Symbol(),MODE_SWAPSHORT);    //своп для SELL в пунктах
      double spread = MarketInfo(Symbol(),MODE_SPREAD);           //размер спреда
      double sredsva = AccountEquity();                           //имеющиеся на счету средства

      
//----------------------------------------------------------------------------------------------//
//панель "GAME OVER"
//----------------------------------------------------------------------------------------------//         
                
         if (AccountBalance() < min_balans)
         {
            if (AccountEquity() < min_balans)
            {
               if (OrderProfit() < min_balans)
               {
         ObjectDelete("GAME OVER");
         if(ObjectFind("GAME OVER") != 0)
         {
         ObjectCreate("GAME OVER", OBJ_LABEL, 0, 0, 0);         
         ObjectSetText("GAME OVER", "GAME OVER", RazmerShrifta*4, "Verdana", Colour_ZF);
         ObjectSet("GAME OVER", OBJPROP_CORNER, Ugol);
         ObjectSet("GAME OVER", OBJPROP_XDISTANCE, MP_X+3);
         ObjectSet("GAME OVER", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*2);
         }
         
         ObjectDelete("GAME OVER 2");
         if(ObjectFind("GAME OVER 2") != 0)
         {           
         ObjectCreate("GAME OVER 2", OBJ_LABEL, 0, 0, 0);         
         ObjectSetText("GAME OVER 2", "ВЫИГРУЕТ ТОТ КТО НЕ УСТАЕТ ПРОИГРЫВАТЬ", RazmerShrifta, "Verdana", Yellow);
         ObjectSet("GAME OVER 2", OBJPROP_CORNER, Ugol);
         ObjectSet("GAME OVER 2", OBJPROP_XDISTANCE, MP_X);
         ObjectSet("GAME OVER 2", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta+2);
         }
         
         ObjectDelete("GAME OVER 3");
         if(ObjectFind("GAME OVER 3") != 0)
         {
         ObjectCreate("GAME OVER 3", OBJ_LABEL, 0, 0, 0);        
         ObjectSetText("GAME OVER 3", "загружай деньги и начинай с начала :)", RazmerShrifta-1, "Verdana", Gray);
         ObjectSet("GAME OVER 3", OBJPROP_CORNER, Ugol);
         ObjectSet("GAME OVER 3", OBJPROP_XDISTANCE, MP_X+43);
         ObjectSet("GAME OVER 3", OBJPROP_YDISTANCE, MP_Y);
         WindowRedraw();
         }
               }
            }        
         }
         
            
//---------------------------------------------------------------------------------------------//
//расчет общего безубытка      
//---------------------------------------------------------------------------------------------//

   double lots_bzu = 0;
   double sum_bzu = 0;
   for (double i_bzu = 0; i_bzu < OrdersTotal(); i_bzu++)
    {
      if ( !OrderSelect ( i_bzu , SELECT_BY_POS , MODE_TRADES )) break;
      if ( OrderSymbol () != Symbol()) continue;
      if ( OrderType () == OP_BUY)
      {
         lots_bzu = lots_bzu + OrderLots ();
         sum_bzu = sum_bzu + OrderLots () * OrderOpenPrice ();
      }
      if ( OrderType () == OP_SELL )
    {
         lots_bzu = lots_bzu - OrderLots ();
         sum_bzu = sum_bzu - OrderLots () * OrderOpenPrice ();
   }
   
   double price_bzu = 0;
   if (lots_bzu != 0 )
   
   price_bzu = sum_bzu / lots_bzu;                                  // уровень общего безубытка
   }


//---------------------------------------------------------------------------------------------//
//расчет безубытка - BUY     
//---------------------------------------------------------------------------------------------//
  
   double lots_bzu_B = 0;
   double sum_bzu_B = 0;
   for (double i_bzu_B = 0; i_bzu_B < OrdersTotal(); i_bzu_B++)
   {
      if ( !OrderSelect ( i_bzu_B , SELECT_BY_POS , MODE_TRADES )) break;
      if ( OrderSymbol () != Symbol()) continue;
      if ( OrderType () == OP_BUY)
      {
         lots_bzu_B = lots_bzu_B + OrderLots ();
         sum_bzu_B = sum_bzu_B + OrderLots () * OrderOpenPrice ();
      }

   double price_bzu_B = 0;
   if (lots_bzu_B != 0 )
   
   price_bzu_B = sum_bzu_B / lots_bzu_B;                                  // уровень безубытка BUY
 
   }


//---------------------------------------------------------------------------------------------//
//расчет безубытка - SELL     
//---------------------------------------------------------------------------------------------//
  
   double lots_bzu_S = 0;
   double sum_bzu_S = 0;
   for (double i_bzu_S = 0; i_bzu_S < OrdersTotal(); i_bzu_S++)
   {
      if ( !OrderSelect ( i_bzu_S , SELECT_BY_POS , MODE_TRADES )) break;
      if ( OrderSymbol () != Symbol()) continue;
      if ( OrderType () == OP_SELL)
      {
         lots_bzu_S = lots_bzu_S + OrderLots ();
         sum_bzu_S = sum_bzu_S + OrderLots () * OrderOpenPrice ();
      }

   double price_bzu_S = 0;
   if (lots_bzu_S != 0 )
   
   price_bzu_S = sum_bzu_S / lots_bzu_S;                                  // уровень безубытка SELL
 
   }


//---------------------------------------------------------------------------------------------//
//рисование общего уровня безубытка  
//---------------------------------------------------------------------------------------------//
      
      if (ZeroProfit == true)
      {
         ObjectDelete("Общий Уровень Безубытка");
         ObjectCreate("Общий Уровень Безубытка", OBJ_HLINE, 0, 0, price_bzu);
         ObjectSet("Общий Уровень Безубытка", OBJPROP_COLOR, Colour_ZP);
         ObjectSet("Общий Уровень Безубытка", OBJPROP_STYLE, Style_ZP);
         ObjectSet("Общий Уровень Безубытка", OBJPROP_WIDTH, Width_ZP);
      }
      else {Comment_("Выкл.-Общий.Безубыток");}
      

//---------------------------------------------------------------------------------------------//
//рисование уровня безубытка BUY
//---------------------------------------------------------------------------------------------//
      
      if (ZeroBUY == true)
      {
         ObjectDelete("Уровень Безубытка BUY");
         ObjectCreate("Уровень Безубытка BUY", OBJ_HLINE, 0, 0, price_bzu_B);
         ObjectSet("Уровень Безубытка BUY", OBJPROP_COLOR, Colour_ZB);
         ObjectSet("Уровень Безубытка BUY", OBJPROP_STYLE, Style_ZB);
         ObjectSet("Уровень Безубытка BUY", OBJPROP_WIDTH, Width_ZB);
      }
      else {Comment_("Выкл.-Уровень.SELL=0");}
      

//---------------------------------------------------------------------------------------------//
//рисование уровня безубытка SELL 
//---------------------------------------------------------------------------------------------//
      
      if (ZeroSELL == true)
      {
         ObjectDelete("Уровень Безубытка SELL");
         ObjectCreate("Уровень Безубытка SELL", OBJ_HLINE, 0, 0, price_bzu_S);
         ObjectSet("Уровень Безубытка SELL", OBJPROP_COLOR, Colour_ZS);
         ObjectSet("Уровень Безубытка SELL", OBJPROP_STYLE, Style_ZS);
         ObjectSet("Уровень Безубытка SELL", OBJPROP_WIDTH, Width_ZS);
      }
      else {Comment_("Выкл.-Уровень.BUY=0");}
      
      
//---------------------------------------------------------------------------------------------//
//расчет уровня Нулевой маржи - начало основного кода от Кирилла 
//---------------------------------------------------------------------------------------------//

   if(AccountFreeMarginMode() == 0)
      Comment_(" v.0"); // + " - Нереализованные прибыли/убытки не используются. \n Свобожная маржа не зависит от тек. цены.");
  
  
   else if(AccountFreeMarginMode() == 2)
      Comment_(" v.2"); // + " - Нереализованные убытки не используются. \n Свобожная маржа не уменьшается при изменении тек. цены.");
  

   else if(AccountFreeMarginMode() == 1)
   {
      Comment_(" v.1"); // + " - При расчете свободных средств используется как нереализованная прибыль, \n так и убыток по открытым позициям на текущем счете.");
      for(i=0; i<total; i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            lots += OrderLots();   
         else if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
            lots -= OrderLots();
      }

      if(lots == 0.0)
      {
         ObjectDelete("ZeroLevel");
         Comment_(" Нет дебаланса ордеров." ); //"All Postions Are Locked. Calculations cancelled."
         Comment_(" Для расчета нет данных." );
         Comment_("----------------------------");  
      }
      
      else
      {
         Comment_(" работаю..."); 
         Comment_("----------------------------");    
         
         
//---------------------------------------------------------------------------------------------//
//уровень нулевой маржи     
//---------------------------------------------------------------------------------------------//
         
         double u_shift, shift22;
               
         ObjectDelete("Уровень Нулевой Маржи");
        
         shift = AccountFreeMargin() / (MarketInfo(Symbol(), MODE_TICKVALUE) * lots);  //растояние от цены до нулевой маржи
       
         u_shift = Bid - shift*Point; 
       
         if (ZeroMargin == true)
         {
         ObjectCreate("Уровень Нулевой Маржи", OBJ_HLINE, 0, 0, u_shift);
         ObjectSet("Уровень Нулевой Маржи", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("Уровень Нулевой Маржи", OBJPROP_STYLE, Style_ZM);
         ObjectSet("Уровень Нулевой Маржи", OBJPROP_WIDTH, Width_ZM);
         }
         else {Comment_("Выкл.-Уровень.М=0");}
         

//---------------------------------------------------------------------------------------------//
//Мертвая зона + уровень слива    
//---------------------------------------------------------------------------------------------//

         double   d_shift_3, u_shift_3, dDZ, OMarginLevel; // 
        
         OMarginLevel = AccountEquity()/AccountMargin()*100; //уровень баланса на счету
         
         d_shift_3 = AccountEquity() / (MarketInfo(Symbol(), MODE_TICKVALUE) * lots); 

         u_shift_3 = Bid - d_shift_3*Point;  // уровень полного слива
                 
         dDZ = d_shift_3 - shift; // мертвая зона
        
                  
         ObjectDelete("Уровень СЛИВА");
         if (ZeroFull == true)
         {
         ObjectCreate("Уровень СЛИВА", OBJ_HLINE, 0, 0, u_shift_3);
         ObjectSet("Уровень СЛИВА", OBJPROP_COLOR, Colour_ZF);
         ObjectSet("Уровень СЛИВА", OBJPROP_STYLE, Style_ZF);
         ObjectSet("Уровень СЛИВА", OBJPROP_WIDTH, Width_ZF);
         }
         else {Comment_("Выкл.-Уровень.СЛИВА");}
         

//---------------------------------------------------------------------------------------------//
//расчет уровня % от нулевой маржи     
//---------------------------------------------------------------------------------------------//
         
         double d_pZM, ur_pZM;         
         d_pZM = d_shift_3 - dDZ*Procent_ZM/100;  //растояние от цены к % от нулевой маржи
         ur_pZM = Bid - d_pZM*Point;              // уровень % от нулевой маржи
         
         ObjectDelete("Проценты до Уровня Нулевой Маржи");
               
      if (ZeroMarginPr == true)
      {
         ObjectCreate("Проценты до Уровня Нулевой Маржи", OBJ_HLINE, 0, 0, ur_pZM);
         ObjectSet("Проценты до Уровня Нулевой Маржи", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("Проценты до Уровня Нулевой Маржи", OBJPROP_STYLE, Style_ZM_Procent);
         ObjectSet("Проценты до Уровня Нулевой Маржи", OBJPROP_WIDTH, Width_ZM_Procent);
      }
      else {Comment_("Выкл.- %.до.М=0");}  


//---------------------------------------------------------------------------------------------//
//Звуковое оповещение о текущем уровне до/после выставленного % от уровня Нулевой маржи 
//---------------------------------------------------------------------------------------------//           
            
         if (SoundPlay_Menshe == true)
         {
         if (OMarginLevel <= Procent_ZM)   PlaySound(Sound_Alert);
         }
         else {Comment_("Выкл.ЗВК-Цена.<.%М=0");}
         
         
         if (SoundPlay_Bolshe == true)   
         {
         if (OMarginLevel > Procent_ZM)   PlaySound(Sound_OK);
         }
         else {Comment_("Выкл.ЗВК-Цена.>.%М=0");}
      
         if (OMarginLevel <= Procent_ZM)
         {
           if (OMarginLevel > 100)
           {
           ObjectDelete("LOCK");
           if(ObjectFind("LOCK") != 0)
     
           ObjectCreate("LOCK", OBJ_LABEL, 0, 0, 0);        
           ObjectSetText("LOCK", "LOCK", RazmerShrifta*5, "Verdana", Colour_ZM);
           ObjectSet("LOCK", OBJPROP_CORNER, Ugol_3);
           ObjectSet("LOCK", OBJPROP_XDISTANCE, MP_X);
           ObjectSet("LOCK", OBJPROP_YDISTANCE, MP_Y);
           }
         }
         
         if (OMarginLevel <= 100)
         {
         ObjectDelete("DEAD ZONE");
         if(ObjectFind("DEAD ZONE") != 0)
     
         ObjectCreate("DEAD ZONE", OBJ_LABEL, 0, 0, 0);        
         ObjectSetText("DEAD ZONE", "DEAD ZONE", RazmerShrifta*2.3, "Verdana", Colour_ZF);
         ObjectSet("DEAD ZONE", OBJPROP_CORNER, Ugol_3);
         ObjectSet("DEAD ZONE", OBJPROP_XDISTANCE, MP_X+4);
         ObjectSet("DEAD ZONE", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*2.3);
         }


//----------------------------------------------------------------------------------------------//
//% - при котором ДЦ закрывает сделки = Stop Out
//----------------------------------------------------------------------------------------------//
        
         double d_pZF, ur_pZF, Afto_Procent_ZF;
               
         Afto_Procent_ZF = AccountStopoutLevel(); //Stop Out (принудительное закрытие позиций)
         
         d_pZF = d_shift_3 - dDZ*Afto_Procent_ZF/100; //растояние до уровня закрытия ДЦ
          
         ur_pZF = Bid - d_pZF*Point;
        
         ObjectDelete ("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut");
               
      if (ZeroFull_Pr == true)
      {
         ObjectCreate("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut", OBJ_HLINE, 0, 0, ur_pZF);
         ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut", OBJPROP_COLOR, Colour_ZF);
         ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut", OBJPROP_STYLE, Style_ZF_Procent);
         ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut", OBJPROP_WIDTH, Width_ZF_Procent);
      }
      else {Comment_("Выкл.- Уров.%.закр.ДЦ");}  

       
//---------------------------------------------------------------------------------------------//
//значения растояния в пипсах до уровня "нуля" и "безубытка" на график      
//---------------------------------------------------------------------------------------------//
     
 double  dZM, price_bzu2, dZP, Znakov, Znak_Z;
     
   Znak_Z = MarketInfo(Symbol(),MODE_DIGITS);
   
   dZM = -shift;
   Znakov = MathPow ( 10 , Znak_Z );
   
   if (lots < 0) {  price_bzu2 = (Ask - price_bzu) * (Znakov);  }
   if (lots > 0) {  price_bzu2 = (Bid - price_bzu) * (Znakov);  }
        
   dZP = -price_bzu2;


//---------------------------------------------------------------------------------------------//
//вывод информации на график
//---------------------------------------------------------------------------------------------//

if (INFO_1 == true)
 {
   ObjectDelete("Расстояние до Общего Уровня Безубытка - инфо");
   if(ObjectFind("Расстояние до Общего Уровня Безубытка - инфо") != 0)
      {
      ObjectCreate("Расстояние до Общего Уровня Безубытка - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Расстояние до Общего Уровня Безубытка - инфо","...осталось:      " + DoubleToStr(dZP, 0)  , RazmerShrifta, "Verdana", Colour_ZP);
      ObjectSet("Расстояние до Общего Уровня Безубытка - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Расстояние до Общего Уровня Безубытка - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Расстояние до Общего Уровня Безубытка - инфо", OBJPROP_YDISTANCE, MP_Y);
      }
     
   ObjectDelete("Общий Уровень Безубытка - инфо");
   if(ObjectFind("Общий Уровень Безубытка - инфо") != 0)
      {
      ObjectCreate("Общий Уровень Безубытка - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Общий Уровень Безубытка - инфо", "Уровень Безубытка: " + DoubleToStr(price_bzu,Digits), RazmerShrifta, "Verdana", Colour_ZP);
      ObjectSet("Общий Уровень Безубытка - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Общий Уровень Безубытка - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Общий Уровень Безубытка - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*1.3);
      }
      
      
//---------------------------------------------------------------------------------------------//
      
   ObjectDelete("Расстояние до Нулевой Маржи - инфо");
   if(ObjectFind("Расстояние до Нулевой Маржи - инфо") != 0)
      {
      ObjectCreate("Расстояние до Нулевой Маржи - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Расстояние до Нулевой Маржи - инфо", "...осталось:    " + DoubleToStr(dZM, 0), RazmerShrifta, "Verdana", Colour_ZM);
      ObjectSet("Расстояние до Нулевой Маржи - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Расстояние до Нулевой Маржи - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Расстояние до Нулевой Маржи - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*3);
      }
      
   ObjectDelete("Уровень Нулевой Маржи - инфо");
   if(ObjectFind("Уровень Нулевой Маржи - инфо") != 0)
      {
      ObjectCreate("Уровень Нулевой Маржи - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Уровень Нулевой Маржи - инфо", "Уровень 0-й Маржи: " + DoubleToStr(Bid - shift*Point, Digits), RazmerShrifta, "Verdana", Colour_ZM);
      ObjectSet("Уровень Нулевой Маржи - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Уровень Нулевой Маржи - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Уровень Нулевой Маржи - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*4.3);
      }
      
      
//---------------------------------------------------------------------------------------------//

   ObjectDelete("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо");
   if(ObjectFind("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо") != 0)
      {
      ObjectCreate("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо", "Закрытие / StopOut:       " + DoubleToStr(Afto_Procent_ZF, 0) + "%", RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Уровень Принудительного Закрытия Ордеров ДЦ / StopOut - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*6);
      }

   ObjectDelete("Мертвая Зона - инфо");
   if(ObjectFind("Мертвая Зона - инфо") != 0)
      {
      ObjectCreate("Мертвая Зона - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Мертвая Зона - инфо", "Мёртвая зона:      " +  DoubleToStr(MathAbs(dDZ), 0) , RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("Мертвая Зона - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Мертвая Зона - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Мертвая Зона - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*7.3);
      }   

   ObjectDelete("Уровень СЛИВА - инфо");
   if(ObjectFind("Уровень СЛИВА - инфо") != 0)
      {
      ObjectCreate("Уровень СЛИВА - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Уровень СЛИВА - инфо", "Уровень Слива: " + DoubleToStr(u_shift_3, Digits), RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("Уровень СЛИВА - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Уровень СЛИВА - инфо", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("Уровень СЛИВА - инфо", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*8.6);
     }
  }
  else {Comment_("Выкл.-Панель.INFO.1");}

        
//---------------------------------------------------------------------------------------------//
//Окраска Мёртвой зоны      
//---------------------------------------------------------------------------------------------//       
   
   ObjectDelete("Мертвая Зона - цвет");   
   if (Cvet_zony_dDZ_f == true)   
   {      
   if(ObjectFind("Мертвая Зона - цвет") != 0)      
      {
   ObjectCreate("Мертвая Зона - цвет", OBJ_RECTANGLE, 0, D'0000.00.00', u_shift_3, TimeCurrent()*1.1, u_shift);
   ObjectSet("Мертвая Зона - цвет", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Мертвая Зона - цвет", OBJPROP_COLOR, Cvet_zony_dDZ);
   ObjectSet("Мертвая Зона - цвет", OBJPROP_BACK, True);
      }
   }
   else {Comment_("Выкл.-Цвет.Мертвая.Зона");} 
 
 
//---------------------------------------------------------------------------------------------//
//Окраска зоны LOCK      
//---------------------------------------------------------------------------------------------//       
   
   ObjectDelete("Зона LOCK - цвет");   
   if (Cvet_zony_LOCK_p == true)   
   {      
   if(ObjectFind("Зона LOCK - цвет") != 0)      
      {
   ObjectCreate("Зона LOCK - цвет", OBJ_RECTANGLE, 0, D'0000.00.00', u_shift, TimeCurrent()*1.1, ur_pZM);
   ObjectSet("Зона LOCK - цвет", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Зона LOCK - цвет", OBJPROP_COLOR, Cvet_zony_LOCK);
   ObjectSet("Зона LOCK - цвет", OBJPROP_BACK, True);
      }
   }
   else {Comment_("Выкл.-Цвет.Зоны.LOCK");}
   
   
//---------------------------------------------------------------------------------------------//
//продолжение и дополнение кода написанного Кириллом - был блок вывода инфо
//---------------------------------------------------------------------------------------------//

       }
   }
   
   
//------------------------------------------------------------------------------------------------//
//вариант 3
//------------------------------------------------------------------------------------------------//   
   
  else if(AccountFreeMarginMode() == 3)
   {
      Comment_(" v.3"); // + " - При расчете используется только значение убытка, \n текущая прибыль по открытым позициям не учитывается. Будет рассчитано два уровня.");

      for(i=0; i<total; i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            lots += OrderLots();   
      }
      if(lots == 0.0)
      {
         ObjectDelete("ZeroLevel_BUY");
         Comment_("Нет позиций на покупку (BUY)." );  //"No Buy Positions."
      }
      else
      {
         shift_ZLB = AccountFreeMargin() / (MarketInfo(Symbol(), MODE_LOTSIZE) * lots * Point);
         ObjectDelete("ZeroLevel_BUY");
         ObjectCreate("ZeroLevel_BUY", OBJ_HLINE, 0, 0, Bid - shift_ZLB*Point);
         ObjectSet("ZeroLevel_BUY", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("ZeroLevel_BUY", OBJPROP_STYLE, Style_ZM);
         ObjectSet("ZeroLevel_BUY", OBJPROP_WIDTH, Width_ZM);
         Comment_("ZeroLevel_BUY:    " + DoubleToStr(Bid - shift_ZLB*Point, Digits));
         Comment_("Current Bid:      " + DoubleToStr(Bid, Digits));
         Comment_("Points Left:       " + DoubleToStr(MathAbs(shift_ZLB), 0));               
      }

      for(i=0; i<total; i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
            lots += OrderLots();   
      }
      if(lots == 0.0)
      {
         ObjectDelete("ZeroLevel_SELL");
         Comment_("Нет позиций на продажу (SELL)." );  //"No SELL Positions."
      }
      else
      {
         shift_ZLS = AccountFreeMargin() / (MarketInfo(Symbol(), MODE_LOTSIZE) * lots * Point);
         ObjectDelete("ZeroLevel_SELL");
         ObjectCreate("ZeroLevel_SELL", OBJ_HLINE, 0, 0, Bid + shift_ZLS*Point);
         ObjectSet("ZeroLevel_SELL", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("ZeroLevel_SELL", OBJPROP_STYLE, Style_ZM);
         ObjectSet("ZeroLevel_SELL", OBJPROP_WIDTH, Width_ZM);
         Comment_("ZeroLevel_SELL:    " + DoubleToStr(Bid + shift_ZLS*Point, Digits));
         Comment_("Current Bid:       " + DoubleToStr(Bid, Digits));
         Comment_("Points Left:        " + DoubleToStr(MathAbs(shift_ZLS), 0));               
      } 
   }
  
  
//---------------------------------------------------------------------------------------------//
//дополнительная панель инфо.2      
//---------------------------------------------------------------------------------------------//
      
if (INFO_2 == true)
{
   ObjectDelete("Можно купить лотов - инфо");
   if(ObjectFind("Можно купить лотов - инфо") != 0)
      {
      ObjectCreate("Можно купить лотов - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Можно купить лотов - инфо", "Можно купить лотов:     " + DoubleToStr(lotsss, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Можно купить лотов - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Можно купить лотов - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Можно купить лотов - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*10.4);
      }
            
   ObjectDelete("Залог за минимальнй лот - инфо");
   if(ObjectFind("Залог за минимальнй лот - инфо") != 0)
      {
      ObjectCreate("Залог за минимальнй лот - инфо", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("Залог за минимальнй лот - инфо", "Залог за мин-ый лот: " + DoubleToStr(min_balans, 3), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Залог за минимальнй лот - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Залог за минимальнй лот - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Залог за минимальнй лот - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*11.7);
      }
      
   ObjectDelete("Минимальный лот - инфо");
   if(ObjectFind("Минимальный лот - инфо") != 0)
      {
      ObjectCreate("Минимальный лот - инфо", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Минимальный лот - инфо", "Минимальный лот:     " + DoubleToStr(minlot, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Минимальный лот - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Минимальный лот - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Минимальный лот - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*13.0);
      }
      
   ObjectDelete("Максимальный лот - инфо");
   if(ObjectFind("Максимальный лот - инфо") != 0)
      {
      ObjectCreate("Максимальный лот - инфо", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("Максимальный лот - инфо", "Максимальный лот:   " + DoubleToStr(maxlot, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Максимальный лот - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Максимальный лот - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Максимальный лот - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*14.3);
      }
      
   ObjectDelete("Стоимость 1 пп для 1 лота - инфо");
   if(ObjectFind("Стоимость 1 пп для 1 лота - инфо") != 0)
      {
      ObjectCreate("Стоимость 1 пп для 1 лота - инфо", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("Стоимость 1 пп для 1 лота - инфо", "Стоимость 1 пп/1 лот:  " + DoubleToStr(pp_cena, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Стоимость 1 пп для 1 лота - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Стоимость 1 пп для 1 лота - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Стоимость 1 пп для 1 лота - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*15.6);
      }
   
   ObjectDelete("Спред, пп - инфо");
   if(ObjectFind("Спред, пп - инфо") != 0)
      {
      ObjectCreate("Спред, пп - инфо", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("Спред, пп - инфо", "Спред, пп:           " + DoubleToStr(spread, 0), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Спред, пп - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Спред, пп - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Спред, пп - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*16.9);
      } 
      
   ObjectDelete("Своп BUY, пп - инфо");
   if(ObjectFind("Своп BUY, пп - инфо") != 0)
      {
      ObjectCreate("Своп BUY, пп - инфо", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("Своп BUY, пп - инфо", "Своп BUY, пп: " + DoubleToStr(swap_long, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Своп BUY, пп - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Своп BUY, пп - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Своп BUY, пп - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*18.2);
      } 

   ObjectDelete("Своп SELL, пп - инфо");
   if(ObjectFind("Своп SELL, пп - инфо") != 0)
      {
      ObjectCreate("Своп SELL, пп - инфо", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("Своп SELL, пп - инфо", "Своп SELL, пп: " + DoubleToStr(swap_short, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("Своп SELL, пп - инфо", OBJPROP_CORNER, Ugol);
      ObjectSet("Своп SELL, пп - инфо", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("Своп SELL, пп - инфо", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*19.5);
      }
}
     else {Comment_("Выкл.-Панель.INFO.2");} 
     
       
//---------------------------------------------------------------------------------------------//
// панель расчетов      
//---------------------------------------------------------------------------------------------//
        
if (CALC_0 == true)
{

double Pribyl_R_2, Rastojanie_R_2, Lots_R_2;

if ((Pribyl_R != Pribyl_R_2 && Rastojanie_R != Rastojanie_R_2 && Lots_R != Lots_R_2) || (Pribyl_R == 0.0 && Rastojanie_R == 0.0 && Lots_R == 0.0) || (Pribyl_R == 0.0 && Rastojanie_R == 0.0 && Lots_R != 0.0) || (Pribyl_R == 0.0 && Rastojanie_R != 0.0 && Lots_R == 0.0) || (Pribyl_R != 0.0 && Rastojanie_R == 0.0 && Lots_R == 0.0))
         {
      ObjectCreate("Комментарии - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Комментарии - Расчет", "НЕВЕРН. ВВОД ЗНАЧ.", RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("Комментарии - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Комментарии - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Комментарии - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.6);  
         } 

else {
if (Pribyl_R == 0.0 && Rastojanie_R != 0.0 && Lots_R != 0.0) 
         { Pribyl_R_2 = Rastojanie_R * Lots_R * pp_cena; //Расчет прибыли
      
      ObjectCreate("Прибыль - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Прибыль - Расчет", "     Прибыль:   " + DoubleToStr(Pribyl_R_2, 2), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("Прибыль - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Прибыль - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Прибыль - Расчет", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("Расстояние - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Расстояние - Расчет", " Расстояние:   " + DoubleToStr(Rastojanie_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Расстояние - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Расстояние - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Расстояние - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("Объем Лота - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Объем Лота - Расчет", "Объем Лота:   " + DoubleToStr(Lots_R, 3), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Объем Лота - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Объем Лота - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Объем Лота - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
         }

else {
if (Pribyl_R != 0.0 && Rastojanie_R == 0.0 && Lots_R != 0.0) 
         { Rastojanie_R_2 = Pribyl_R / (Lots_R * pp_cena); //Расчет расстояния
                                                      
      ObjectCreate("Прибыль - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Прибыль - Расчет", "     Прибыль:   " + DoubleToStr(Pribyl_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Прибыль - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Прибыль - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Прибыль - Расчет", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("Расстояние - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Расстояние - Расчет", " Расстояние:   " + DoubleToStr(Rastojanie_R_2, 2), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("Расстояние - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Расстояние - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Расстояние - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("Объем Лота - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Объем Лота - Расчет", "Объем Лота:   " + DoubleToStr(Lots_R, 3), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Объем Лота - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Объем Лота - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Объем Лота - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
         }

else {
if (Pribyl_R != 0.0 && Rastojanie_R != 0.0 && Lots_R == 0.0) 
         { Lots_R_2 = Pribyl_R / (Rastojanie_R * pp_cena); //Расчет объема лота
                                                      
      ObjectCreate("Прибыль - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Прибыль - Расчет", "     Прибыль:   " + DoubleToStr(Pribyl_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Прибыль - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Прибыль - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Прибыль - Расчет", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("Расстояние - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Расстояние - Расчет", " Расстояние:   " + DoubleToStr(Rastojanie_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Расстояние - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Расстояние - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Расстояние - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("Объем Лота - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Объем Лота - Расчет", "Объем Лота:   " + DoubleToStr(Lots_R_2, 3), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("Объем Лота - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Объем Лота - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("Объем Лота - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
                                           
         }
}
}
}
      
      ObjectCreate("Панель Расчета - Расчет", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("Панель Расчета - Расчет", "ПАНЕЛЬ РАСЧЕТА:" , RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("Панель Расчета - Расчет", OBJPROP_CORNER, 2);
      ObjectSet("Панель Расчета - Расчет", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta*2.5);
      ObjectSet("Панель Расчета - Расчет", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*4.5);  
}
      else {Comment_("Выкл.-Панель.CALC");}


//------------------------------------------------------------------------------------------------//
// окончание
//------------------------------------------------------------------------------------------------//

   Comment("---------------------------- \n i-UrovenZero-v.2.0"  + comment); 
     
   comment = "";
  
   return(0);
}

void Comment_(string com)
{
   comment = comment + "\n" + com;
}


// © Bor-ix & Kirill & d_tom & Don_Leone :) При поддержке www.FX4U.ru"


