//+------------------------------------------------------------------+
//|                                             i-UrovenZero-Uni.mq4 |
//|                      Bor-ix i Kirill + ������ d_tom i Don_Leone  |
//+------------------------------------------------------------------+
#property copyright "Bor-ix i Kirill"

#property indicator_chart_window

//��������� ������ ��� ������� �� ������� ��������� ������, ��� ���������� �������� ����� 
//��� �������� ������� � ����� ����� � ����� �����, ��� ��������� ����� ������ ����� ���� (������� ZeroMargin)
//� ��� ���������� ����� ������ ��� ������� ��� �������� ������ � ����� ����� ����� ���� (������� ZeroProfit)...
//�������� ������ ��� �������� �� ����� ������.
//���������� ������ �� ����������� � ������

//�������� ������ ������� ����� ��������� ��������� ��������:
//v.0 - "��������������� �������/������ �� ������������. ��������� ����� �� ������� �� ���. ����."
//v.1 - "��� ������� ��������� ������� ������������ ��� ��������������� �������, ��� � ������ �� �������� �������� �� ������� �����."
//v.2 - "��������������� ������ �� ������������. ��������� ����� �� ����������� ��� ��������� ���. ����."
//v.3 - "��� ������� ������������ ������ �������� ������, ������� ������� �� �������� �������� �� �����������. ����� ���������� ��� ������."
 
extern string CALC_Bar_0         = "=== ������ �������� ===";
extern bool    CALC_0            = false;

extern double  Lots_R            = 1.0;      // ������ �������� ������ ����
extern double  Rastojanie_R      = 100.0;    // ������ �������� ��������� � �������
extern double  Pribyl_R          = 0.0;      // ������ �������� �������/������ � ������

extern color   cvet_CALC_0       = Violet;   //���� �������� ������� ������
extern color   cvet_CALC_R       = Yellow;   //���� ������� ���������� ��������
extern int     Ugol_0            = 2;        // ��������� �� �������
extern int     MP_X_0            = 10;       // �������� ��������� �� ����������� 
extern int     MP_Y_0            = 10;       // �������� ��������� �� ���������

extern string Shrift_Bar         = "=== ������ ������ ===";
extern int     RazmerShrifta     = 9;

extern string ZeroProfit_Block   = "=== �����. ������ ��������� ===";
extern bool    ZeroProfit        = true;
extern color   Colour_ZP         = DarkTurquoise;
extern int     Style_ZP          = 1;        //0,1,2,3,4
extern int     Width_ZP          = 2;        //0,1,2,3,4

extern string ZeroBUY_Block      = "=== �����. ��������� ��� BUY ===";
extern bool    ZeroBUY           = true;
extern color   Colour_ZB         = DarkTurquoise;
extern int     Style_ZB          = 2;        //0,1,2,3,4
extern int     Width_ZB          = 1;        //0,1,2,3,4

extern string ZeroSELL_Block     = "=== �����. ��������� ��� SELL ===";
extern bool    ZeroSELL          = true;
extern color   Colour_ZS         = DarkTurquoise;
extern int     Style_ZS          = 2;        //0,1,2,3,4
extern int     Width_ZS          = 1;        //0,1,2,3,4

extern string ZeroMargin_Block   = "=== �����. ������� ����� ===";
extern bool    ZeroMargin        = true;
extern color   Colour_ZM         = Yellow;
extern int     Style_ZM          = 0;        //0,1,2,3,4  
extern int     Width_ZM          = 2;        //0,1,2,3,4

extern string ZeroMarginPr_Block = "=== �����. % ������� ����� ===";
extern bool    ZeroMarginPr      = true;
extern int     Procent_ZM        = 150;      // �������� �� ������ ������ ��� ��������������
extern int     Style_ZM_Procent  = 2;        //0,1,2,3,4 
extern int     Width_ZM_Procent  = 1;        //0,1,2,3,4 

extern string Zona_LOCK_Param    = "=== �����. ���� LOCK ===";
extern bool    Cvet_zony_LOCK_p  = false;  
extern color   Cvet_zony_LOCK    = C'70,70,00';   // ���� ���� LOCK

extern string ZeroFull_Block     = "=== �����. ������� ����� ===";
extern bool    ZeroFull          = true;
extern color   Colour_ZF         = Red;
extern int     Style_ZF          = 0;        //0,1,2,3,4  
extern int     Width_ZF          = 2;        //0,1,2,3,4

extern string ZeroFull_Pr_Block  = "=== StopOut/������.����.������� ===";
extern bool    ZeroFull_Pr       = true;
extern int     Style_ZF_Procent  = 2;        //0,1,2,3,4  
extern int     Width_ZF_Procent  = 1;        //0,1,2,3,4  

extern string Zona_dDZ_Param     = "=== �����. ������� ���� ===";
extern bool    Cvet_zony_dDZ_f   = false;
extern color   Cvet_zony_dDZ     = C'70,00,00';   // ���� ���� DEAD ZONE

extern string INFO_Bar_1         = "=== ������ ���������� 1 ===";
extern bool    INFO_1            = true;
extern int     Ugol              = 3;        // ��������� �� �������
extern int     MP_X              = 10;       // �������� ��������� �� ����������� 
extern int     MP_Y              = 10;       // �������� ��������� �� ���������

extern string INFO_Bar_2         = "=== ������ ���������� 2 ===";
extern bool    INFO_2            = false;
extern color   cvet_dop_info     = Silver;   // ���� ����. ������ 2
extern int     Ugol_2            = 3;        // ��������� �� �������
extern int     MP_X_2            = 10;       // �������� ��������� �� ����������� 
extern int     MP_Y_2            = 10;       // �������� ��������� �� ���������

extern string INFO_Bar_3         = "=== ������ ���������� 3 ===";
extern int     Ugol_3            = 1;        // ��������� �� ������� ����. ������ 3

extern string Sound_Bar          = "=== ��������������� ����� ===";
extern bool    SoundPlay_Menshe  = true;
extern string  Sound_Alert       = "Alert.wav";
extern bool    SoundPlay_Bolshe  = false;
extern string  Sound_OK          = "clock.wav";

string comment = "";


//---------------------------------------------------------------------------------------------//
//�������� ������������ ��������
//---------------------------------------------------------------------------------------------// 
   
   ObjectDelete ("������� ������� �����");
   ObjectDelete ("������� �����");
   
   ObjectDelete ("LOCK");
   ObjectDelete ("DEAD ZONE");
   ObjectDelete ("DEAD ZONE =");
   ObjectDelete ("DEAD ZONE = 2");
   ObjectDelete ("GAME OVER");
   ObjectDelete ("GAME OVER 2");
   ObjectDelete ("GAME OVER 3");
   ObjectDelete ("��������� 1 �� ��� 1 ���� - ����");
         
   ObjectDelete ("�������� �� ������ ������� �����");
   ObjectDelete ("������� ��������������� �������� ������� �� / StopOut");
   ObjectDelete ("����� ������� ���������");
   ObjectDelete ("������� ��������� BUY");
   ObjectDelete ("������� ��������� SELL");
   ObjectDelete ("���������� �� ������ ������ ��������� - ����");
   ObjectDelete ("����� ������� ��������� - ����");
   ObjectDelete ("���������� �� ������� ����� - ����");
   ObjectDelete ("������� ������� ����� - ����");
   ObjectDelete ("������� ����� - ����");
   ObjectDelete ("������� ���� - ����");
   ObjectDelete ("������� ���� - ����");
   ObjectDelete ("���� LOCK - ����"); 
   ObjectDelete ("������� ��������������� �������� ������� �� / StopOut - ����");
   
   ObjectDelete ("����� ������ ����� - ����");
   ObjectDelete ("����� �� ���������� ��� - ����");
   ObjectDelete ("����������� ��� - ����");
   ObjectDelete ("������������ ��� - ����");
   ObjectDelete ("�����, �� - ����");
   ObjectDelete ("���� BUY, �� - ����");
   ObjectDelete ("���� SELL, �� - ����");
   
   ObjectDelete ("������� - ������");
   ObjectDelete ("���������� - ������");
   ObjectDelete ("����� ���� - ������");
   ObjectDelete ("������ ������� - ������");
   ObjectDelete ("����������� - ������");
   
   ObjectDelete ("ZeroLevel");
   ObjectDelete ("ZeroLevel_BUY");
   ObjectDelete ("ZeroLevel_SELL");
   
   Comment("");


//---------------------------------------------------------------------------------------------//
//������ ������� ������-���� ��������� �� ������������ ������� � ����� �����������
//---------------------------------------------------------------------------------------------// 

int start()
{
  
   double i, total = OrdersTotal();
      double lots=0.0, shift, shift_ZLB, shift_ZLS;
      Comment_("----------------------------"); 
      Comment_(" " + AccountName());
      string type = "����"; if (IsDemo()) type = "����";
      Comment_(" ��� �����: " + type + " - �: " + AccountNumber());
      Comment_(" �����: 1/" + AccountLeverage());
      Comment_("----------------------------"); 

      double minlot = MarketInfo(Symbol(),MODE_MINLOT);           //������ ������������ ����
      double maxlot = MarketInfo(Symbol(),MODE_MAXLOT);           //������ ������������ ����
      double lot_cena = MarketInfo(Symbol(),MODE_MARGINREQUIRED); //���� 1.0 ����
      double lot_zalog = MarketInfo(Symbol(),MODE_MARGININIT);    //����� �� 1.0 ���
      double min_balans = (lot_cena + lot_zalog) * minlot;        //������ ��������� ������������ ����
      double lotsss = AccountFreeMargin()*minlot/min_balans;      //���������� ����� ������� ����� ������
      double pp_cena = MarketInfo(Symbol(),MODE_TICKVALUE);       //���� ������ ������
      double swap_long = MarketInfo(Symbol(),MODE_SWAPLONG);      //���� ��� BUY � �������
      double swap_short = MarketInfo(Symbol(),MODE_SWAPSHORT);    //���� ��� SELL � �������
      double spread = MarketInfo(Symbol(),MODE_SPREAD);           //������ ������
      double sredsva = AccountEquity();                           //��������� �� ����� ��������

      
//----------------------------------------------------------------------------------------------//
//������ "GAME OVER"
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
         ObjectSetText("GAME OVER 2", "�������� ��� ��� �� ������ �����������", RazmerShrifta, "Verdana", Yellow);
         ObjectSet("GAME OVER 2", OBJPROP_CORNER, Ugol);
         ObjectSet("GAME OVER 2", OBJPROP_XDISTANCE, MP_X);
         ObjectSet("GAME OVER 2", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta+2);
         }
         
         ObjectDelete("GAME OVER 3");
         if(ObjectFind("GAME OVER 3") != 0)
         {
         ObjectCreate("GAME OVER 3", OBJ_LABEL, 0, 0, 0);        
         ObjectSetText("GAME OVER 3", "�������� ������ � ������� � ������ :)", RazmerShrifta-1, "Verdana", Gray);
         ObjectSet("GAME OVER 3", OBJPROP_CORNER, Ugol);
         ObjectSet("GAME OVER 3", OBJPROP_XDISTANCE, MP_X+43);
         ObjectSet("GAME OVER 3", OBJPROP_YDISTANCE, MP_Y);
         WindowRedraw();
         }
               }
            }        
         }
         
            
//---------------------------------------------------------------------------------------------//
//������ ������ ���������      
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
   
   price_bzu = sum_bzu / lots_bzu;                                  // ������� ������ ���������
   }


//---------------------------------------------------------------------------------------------//
//������ ��������� - BUY     
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
   
   price_bzu_B = sum_bzu_B / lots_bzu_B;                                  // ������� ��������� BUY
 
   }


//---------------------------------------------------------------------------------------------//
//������ ��������� - SELL     
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
   
   price_bzu_S = sum_bzu_S / lots_bzu_S;                                  // ������� ��������� SELL
 
   }


//---------------------------------------------------------------------------------------------//
//��������� ������ ������ ���������  
//---------------------------------------------------------------------------------------------//
      
      if (ZeroProfit == true)
      {
         ObjectDelete("����� ������� ���������");
         ObjectCreate("����� ������� ���������", OBJ_HLINE, 0, 0, price_bzu);
         ObjectSet("����� ������� ���������", OBJPROP_COLOR, Colour_ZP);
         ObjectSet("����� ������� ���������", OBJPROP_STYLE, Style_ZP);
         ObjectSet("����� ������� ���������", OBJPROP_WIDTH, Width_ZP);
      }
      else {Comment_("����.-�����.���������");}
      

//---------------------------------------------------------------------------------------------//
//��������� ������ ��������� BUY
//---------------------------------------------------------------------------------------------//
      
      if (ZeroBUY == true)
      {
         ObjectDelete("������� ��������� BUY");
         ObjectCreate("������� ��������� BUY", OBJ_HLINE, 0, 0, price_bzu_B);
         ObjectSet("������� ��������� BUY", OBJPROP_COLOR, Colour_ZB);
         ObjectSet("������� ��������� BUY", OBJPROP_STYLE, Style_ZB);
         ObjectSet("������� ��������� BUY", OBJPROP_WIDTH, Width_ZB);
      }
      else {Comment_("����.-�������.SELL=0");}
      

//---------------------------------------------------------------------------------------------//
//��������� ������ ��������� SELL 
//---------------------------------------------------------------------------------------------//
      
      if (ZeroSELL == true)
      {
         ObjectDelete("������� ��������� SELL");
         ObjectCreate("������� ��������� SELL", OBJ_HLINE, 0, 0, price_bzu_S);
         ObjectSet("������� ��������� SELL", OBJPROP_COLOR, Colour_ZS);
         ObjectSet("������� ��������� SELL", OBJPROP_STYLE, Style_ZS);
         ObjectSet("������� ��������� SELL", OBJPROP_WIDTH, Width_ZS);
      }
      else {Comment_("����.-�������.BUY=0");}
      
      
//---------------------------------------------------------------------------------------------//
//������ ������ ������� ����� - ������ ��������� ���� �� ������� 
//---------------------------------------------------------------------------------------------//

   if(AccountFreeMarginMode() == 0)
      Comment_(" v.0"); // + " - ��������������� �������/������ �� ������������. \n ��������� ����� �� ������� �� ���. ����.");
  
  
   else if(AccountFreeMarginMode() == 2)
      Comment_(" v.2"); // + " - ��������������� ������ �� ������������. \n ��������� ����� �� ����������� ��� ��������� ���. ����.");
  

   else if(AccountFreeMarginMode() == 1)
   {
      Comment_(" v.1"); // + " - ��� ������� ��������� ������� ������������ ��� ��������������� �������, \n ��� � ������ �� �������� �������� �� ������� �����.");
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
         Comment_(" ��� ��������� �������." ); //"All Postions Are Locked. Calculations cancelled."
         Comment_(" ��� ������� ��� ������." );
         Comment_("----------------------------");  
      }
      
      else
      {
         Comment_(" �������..."); 
         Comment_("----------------------------");    
         
         
//---------------------------------------------------------------------------------------------//
//������� ������� �����     
//---------------------------------------------------------------------------------------------//
         
         double u_shift, shift22;
               
         ObjectDelete("������� ������� �����");
        
         shift = AccountFreeMargin() / (MarketInfo(Symbol(), MODE_TICKVALUE) * lots);  //��������� �� ���� �� ������� �����
       
         u_shift = Bid - shift*Point; 
       
         if (ZeroMargin == true)
         {
         ObjectCreate("������� ������� �����", OBJ_HLINE, 0, 0, u_shift);
         ObjectSet("������� ������� �����", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("������� ������� �����", OBJPROP_STYLE, Style_ZM);
         ObjectSet("������� ������� �����", OBJPROP_WIDTH, Width_ZM);
         }
         else {Comment_("����.-�������.�=0");}
         

//---------------------------------------------------------------------------------------------//
//������� ���� + ������� �����    
//---------------------------------------------------------------------------------------------//

         double   d_shift_3, u_shift_3, dDZ, OMarginLevel; // 
        
         OMarginLevel = AccountEquity()/AccountMargin()*100; //������� ������� �� �����
         
         d_shift_3 = AccountEquity() / (MarketInfo(Symbol(), MODE_TICKVALUE) * lots); 

         u_shift_3 = Bid - d_shift_3*Point;  // ������� ������� �����
                 
         dDZ = d_shift_3 - shift; // ������� ����
        
                  
         ObjectDelete("������� �����");
         if (ZeroFull == true)
         {
         ObjectCreate("������� �����", OBJ_HLINE, 0, 0, u_shift_3);
         ObjectSet("������� �����", OBJPROP_COLOR, Colour_ZF);
         ObjectSet("������� �����", OBJPROP_STYLE, Style_ZF);
         ObjectSet("������� �����", OBJPROP_WIDTH, Width_ZF);
         }
         else {Comment_("����.-�������.�����");}
         

//---------------------------------------------------------------------------------------------//
//������ ������ % �� ������� �����     
//---------------------------------------------------------------------------------------------//
         
         double d_pZM, ur_pZM;         
         d_pZM = d_shift_3 - dDZ*Procent_ZM/100;  //��������� �� ���� � % �� ������� �����
         ur_pZM = Bid - d_pZM*Point;              // ������� % �� ������� �����
         
         ObjectDelete("�������� �� ������ ������� �����");
               
      if (ZeroMarginPr == true)
      {
         ObjectCreate("�������� �� ������ ������� �����", OBJ_HLINE, 0, 0, ur_pZM);
         ObjectSet("�������� �� ������ ������� �����", OBJPROP_COLOR, Colour_ZM);
         ObjectSet("�������� �� ������ ������� �����", OBJPROP_STYLE, Style_ZM_Procent);
         ObjectSet("�������� �� ������ ������� �����", OBJPROP_WIDTH, Width_ZM_Procent);
      }
      else {Comment_("����.- %.��.�=0");}  


//---------------------------------------------------------------------------------------------//
//�������� ���������� � ������� ������ ��/����� ������������� % �� ������ ������� ����� 
//---------------------------------------------------------------------------------------------//           
            
         if (SoundPlay_Menshe == true)
         {
         if (OMarginLevel <= Procent_ZM)   PlaySound(Sound_Alert);
         }
         else {Comment_("����.���-����.<.%�=0");}
         
         
         if (SoundPlay_Bolshe == true)   
         {
         if (OMarginLevel > Procent_ZM)   PlaySound(Sound_OK);
         }
         else {Comment_("����.���-����.>.%�=0");}
      
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
//% - ��� ������� �� ��������� ������ = Stop Out
//----------------------------------------------------------------------------------------------//
        
         double d_pZF, ur_pZF, Afto_Procent_ZF;
               
         Afto_Procent_ZF = AccountStopoutLevel(); //Stop Out (�������������� �������� �������)
         
         d_pZF = d_shift_3 - dDZ*Afto_Procent_ZF/100; //��������� �� ������ �������� ��
          
         ur_pZF = Bid - d_pZF*Point;
        
         ObjectDelete ("������� ��������������� �������� ������� �� / StopOut");
               
      if (ZeroFull_Pr == true)
      {
         ObjectCreate("������� ��������������� �������� ������� �� / StopOut", OBJ_HLINE, 0, 0, ur_pZF);
         ObjectSet("������� ��������������� �������� ������� �� / StopOut", OBJPROP_COLOR, Colour_ZF);
         ObjectSet("������� ��������������� �������� ������� �� / StopOut", OBJPROP_STYLE, Style_ZF_Procent);
         ObjectSet("������� ��������������� �������� ������� �� / StopOut", OBJPROP_WIDTH, Width_ZF_Procent);
      }
      else {Comment_("����.- ����.%.����.��");}  

       
//---------------------------------------------------------------------------------------------//
//�������� ��������� � ������ �� ������ "����" � "���������" �� ������      
//---------------------------------------------------------------------------------------------//
     
 double  dZM, price_bzu2, dZP, Znakov, Znak_Z;
     
   Znak_Z = MarketInfo(Symbol(),MODE_DIGITS);
   
   dZM = -shift;
   Znakov = MathPow ( 10 , Znak_Z );
   
   if (lots < 0) {  price_bzu2 = (Ask - price_bzu) * (Znakov);  }
   if (lots > 0) {  price_bzu2 = (Bid - price_bzu) * (Znakov);  }
        
   dZP = -price_bzu2;


//---------------------------------------------------------------------------------------------//
//����� ���������� �� ������
//---------------------------------------------------------------------------------------------//

if (INFO_1 == true)
 {
   ObjectDelete("���������� �� ������ ������ ��������� - ����");
   if(ObjectFind("���������� �� ������ ������ ��������� - ����") != 0)
      {
      ObjectCreate("���������� �� ������ ������ ��������� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("���������� �� ������ ������ ��������� - ����","...��������:      " + DoubleToStr(dZP, 0)  , RazmerShrifta, "Verdana", Colour_ZP);
      ObjectSet("���������� �� ������ ������ ��������� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("���������� �� ������ ������ ��������� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("���������� �� ������ ������ ��������� - ����", OBJPROP_YDISTANCE, MP_Y);
      }
     
   ObjectDelete("����� ������� ��������� - ����");
   if(ObjectFind("����� ������� ��������� - ����") != 0)
      {
      ObjectCreate("����� ������� ��������� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����� ������� ��������� - ����", "������� ���������: " + DoubleToStr(price_bzu,Digits), RazmerShrifta, "Verdana", Colour_ZP);
      ObjectSet("����� ������� ��������� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("����� ������� ��������� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("����� ������� ��������� - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*1.3);
      }
      
      
//---------------------------------------------------------------------------------------------//
      
   ObjectDelete("���������� �� ������� ����� - ����");
   if(ObjectFind("���������� �� ������� ����� - ����") != 0)
      {
      ObjectCreate("���������� �� ������� ����� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("���������� �� ������� ����� - ����", "...��������:    " + DoubleToStr(dZM, 0), RazmerShrifta, "Verdana", Colour_ZM);
      ObjectSet("���������� �� ������� ����� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("���������� �� ������� ����� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("���������� �� ������� ����� - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*3);
      }
      
   ObjectDelete("������� ������� ����� - ����");
   if(ObjectFind("������� ������� ����� - ����") != 0)
      {
      ObjectCreate("������� ������� ����� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� ������� ����� - ����", "������� 0-� �����: " + DoubleToStr(Bid - shift*Point, Digits), RazmerShrifta, "Verdana", Colour_ZM);
      ObjectSet("������� ������� ����� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("������� ������� ����� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("������� ������� ����� - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*4.3);
      }
      
      
//---------------------------------------------------------------------------------------------//

   ObjectDelete("������� ��������������� �������� ������� �� / StopOut - ����");
   if(ObjectFind("������� ��������������� �������� ������� �� / StopOut - ����") != 0)
      {
      ObjectCreate("������� ��������������� �������� ������� �� / StopOut - ����", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("������� ��������������� �������� ������� �� / StopOut - ����", "�������� / StopOut:       " + DoubleToStr(Afto_Procent_ZF, 0) + "%", RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("������� ��������������� �������� ������� �� / StopOut - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("������� ��������������� �������� ������� �� / StopOut - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("������� ��������������� �������� ������� �� / StopOut - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*6);
      }

   ObjectDelete("������� ���� - ����");
   if(ObjectFind("������� ���� - ����") != 0)
      {
      ObjectCreate("������� ���� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� ���� - ����", "̸����� ����:      " +  DoubleToStr(MathAbs(dDZ), 0) , RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("������� ���� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("������� ���� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("������� ���� - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*7.3);
      }   

   ObjectDelete("������� ����� - ����");
   if(ObjectFind("������� ����� - ����") != 0)
      {
      ObjectCreate("������� ����� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� ����� - ����", "������� �����: " + DoubleToStr(u_shift_3, Digits), RazmerShrifta, "Verdana", Colour_ZF);
      ObjectSet("������� ����� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("������� ����� - ����", OBJPROP_XDISTANCE, MP_X);
      ObjectSet("������� ����� - ����", OBJPROP_YDISTANCE, MP_Y+RazmerShrifta*8.6);
     }
  }
  else {Comment_("����.-������.INFO.1");}

        
//---------------------------------------------------------------------------------------------//
//������� ̸����� ����      
//---------------------------------------------------------------------------------------------//       
   
   ObjectDelete("������� ���� - ����");   
   if (Cvet_zony_dDZ_f == true)   
   {      
   if(ObjectFind("������� ���� - ����") != 0)      
      {
   ObjectCreate("������� ���� - ����", OBJ_RECTANGLE, 0, D'0000.00.00', u_shift_3, TimeCurrent()*1.1, u_shift);
   ObjectSet("������� ���� - ����", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("������� ���� - ����", OBJPROP_COLOR, Cvet_zony_dDZ);
   ObjectSet("������� ���� - ����", OBJPROP_BACK, True);
      }
   }
   else {Comment_("����.-����.�������.����");} 
 
 
//---------------------------------------------------------------------------------------------//
//������� ���� LOCK      
//---------------------------------------------------------------------------------------------//       
   
   ObjectDelete("���� LOCK - ����");   
   if (Cvet_zony_LOCK_p == true)   
   {      
   if(ObjectFind("���� LOCK - ����") != 0)      
      {
   ObjectCreate("���� LOCK - ����", OBJ_RECTANGLE, 0, D'0000.00.00', u_shift, TimeCurrent()*1.1, ur_pZM);
   ObjectSet("���� LOCK - ����", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("���� LOCK - ����", OBJPROP_COLOR, Cvet_zony_LOCK);
   ObjectSet("���� LOCK - ����", OBJPROP_BACK, True);
      }
   }
   else {Comment_("����.-����.����.LOCK");}
   
   
//---------------------------------------------------------------------------------------------//
//����������� � ���������� ���� ����������� �������� - ��� ���� ������ ����
//---------------------------------------------------------------------------------------------//

       }
   }
   
   
//------------------------------------------------------------------------------------------------//
//������� 3
//------------------------------------------------------------------------------------------------//   
   
  else if(AccountFreeMarginMode() == 3)
   {
      Comment_(" v.3"); // + " - ��� ������� ������������ ������ �������� ������, \n ������� ������� �� �������� �������� �� �����������. ����� ���������� ��� ������.");

      for(i=0; i<total; i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
            lots += OrderLots();   
      }
      if(lots == 0.0)
      {
         ObjectDelete("ZeroLevel_BUY");
         Comment_("��� ������� �� ������� (BUY)." );  //"No Buy Positions."
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
         Comment_("��� ������� �� ������� (SELL)." );  //"No SELL Positions."
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
//�������������� ������ ����.2      
//---------------------------------------------------------------------------------------------//
      
if (INFO_2 == true)
{
   ObjectDelete("����� ������ ����� - ����");
   if(ObjectFind("����� ������ ����� - ����") != 0)
      {
      ObjectCreate("����� ������ ����� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����� ������ ����� - ����", "����� ������ �����:     " + DoubleToStr(lotsss, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("����� ������ ����� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("����� ������ ����� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("����� ������ ����� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*10.4);
      }
            
   ObjectDelete("����� �� ���������� ��� - ����");
   if(ObjectFind("����� �� ���������� ��� - ����") != 0)
      {
      ObjectCreate("����� �� ���������� ��� - ����", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("����� �� ���������� ��� - ����", "����� �� ���-�� ���: " + DoubleToStr(min_balans, 3), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("����� �� ���������� ��� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("����� �� ���������� ��� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("����� �� ���������� ��� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*11.7);
      }
      
   ObjectDelete("����������� ��� - ����");
   if(ObjectFind("����������� ��� - ����") != 0)
      {
      ObjectCreate("����������� ��� - ����", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����������� ��� - ����", "����������� ���:     " + DoubleToStr(minlot, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("����������� ��� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("����������� ��� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("����������� ��� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*13.0);
      }
      
   ObjectDelete("������������ ��� - ����");
   if(ObjectFind("������������ ��� - ����") != 0)
      {
      ObjectCreate("������������ ��� - ����", OBJ_LABEL, 0, 0, 0);         
      ObjectSetText("������������ ��� - ����", "������������ ���:   " + DoubleToStr(maxlot, 2), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("������������ ��� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("������������ ��� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("������������ ��� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*14.3);
      }
      
   ObjectDelete("��������� 1 �� ��� 1 ���� - ����");
   if(ObjectFind("��������� 1 �� ��� 1 ���� - ����") != 0)
      {
      ObjectCreate("��������� 1 �� ��� 1 ���� - ����", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("��������� 1 �� ��� 1 ���� - ����", "��������� 1 ��/1 ���:  " + DoubleToStr(pp_cena, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("��������� 1 �� ��� 1 ���� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("��������� 1 �� ��� 1 ���� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("��������� 1 �� ��� 1 ���� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*15.6);
      }
   
   ObjectDelete("�����, �� - ����");
   if(ObjectFind("�����, �� - ����") != 0)
      {
      ObjectCreate("�����, �� - ����", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("�����, �� - ����", "�����, ��:           " + DoubleToStr(spread, 0), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("�����, �� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("�����, �� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("�����, �� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*16.9);
      } 
      
   ObjectDelete("���� BUY, �� - ����");
   if(ObjectFind("���� BUY, �� - ����") != 0)
      {
      ObjectCreate("���� BUY, �� - ����", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("���� BUY, �� - ����", "���� BUY, ��: " + DoubleToStr(swap_long, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("���� BUY, �� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("���� BUY, �� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("���� BUY, �� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*18.2);
      } 

   ObjectDelete("���� SELL, �� - ����");
   if(ObjectFind("���� SELL, �� - ����") != 0)
      {
      ObjectCreate("���� SELL, �� - ����", OBJ_LABEL, 0, 0, 0);       
      ObjectSetText("���� SELL, �� - ����", "���� SELL, ��: " + DoubleToStr(swap_short, Digits), RazmerShrifta, "Verdana", cvet_dop_info);
      ObjectSet("���� SELL, �� - ����", OBJPROP_CORNER, Ugol);
      ObjectSet("���� SELL, �� - ����", OBJPROP_XDISTANCE, MP_X_2);
      ObjectSet("���� SELL, �� - ����", OBJPROP_YDISTANCE, MP_Y_2+RazmerShrifta*19.5);
      }
}
     else {Comment_("����.-������.INFO.2");} 
     
       
//---------------------------------------------------------------------------------------------//
// ������ ��������      
//---------------------------------------------------------------------------------------------//
        
if (CALC_0 == true)
{

double Pribyl_R_2, Rastojanie_R_2, Lots_R_2;

if ((Pribyl_R != Pribyl_R_2 && Rastojanie_R != Rastojanie_R_2 && Lots_R != Lots_R_2) || (Pribyl_R == 0.0 && Rastojanie_R == 0.0 && Lots_R == 0.0) || (Pribyl_R == 0.0 && Rastojanie_R == 0.0 && Lots_R != 0.0) || (Pribyl_R == 0.0 && Rastojanie_R != 0.0 && Lots_R == 0.0) || (Pribyl_R != 0.0 && Rastojanie_R == 0.0 && Lots_R == 0.0))
         {
      ObjectCreate("����������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����������� - ������", "������. ���� ����.", RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("����������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("����������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("����������� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.6);  
         } 

else {
if (Pribyl_R == 0.0 && Rastojanie_R != 0.0 && Lots_R != 0.0) 
         { Pribyl_R_2 = Rastojanie_R * Lots_R * pp_cena; //������ �������
      
      ObjectCreate("������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� - ������", "     �������:   " + DoubleToStr(Pribyl_R_2, 2), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("������� - ������", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("���������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("���������� - ������", " ����������:   " + DoubleToStr(Rastojanie_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("���������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("���������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("���������� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("����� ���� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����� ���� - ������", "����� ����:   " + DoubleToStr(Lots_R, 3), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("����� ���� - ������", OBJPROP_CORNER, 2);
      ObjectSet("����� ���� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("����� ���� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
         }

else {
if (Pribyl_R != 0.0 && Rastojanie_R == 0.0 && Lots_R != 0.0) 
         { Rastojanie_R_2 = Pribyl_R / (Lots_R * pp_cena); //������ ����������
                                                      
      ObjectCreate("������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� - ������", "     �������:   " + DoubleToStr(Pribyl_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("������� - ������", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("���������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("���������� - ������", " ����������:   " + DoubleToStr(Rastojanie_R_2, 2), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("���������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("���������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("���������� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("����� ���� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����� ���� - ������", "����� ����:   " + DoubleToStr(Lots_R, 3), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("����� ���� - ������", OBJPROP_CORNER, 2);
      ObjectSet("����� ���� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("����� ���� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
         }

else {
if (Pribyl_R != 0.0 && Rastojanie_R != 0.0 && Lots_R == 0.0) 
         { Lots_R_2 = Pribyl_R / (Rastojanie_R * pp_cena); //������ ������ ����
                                                      
      ObjectCreate("������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������� - ������", "     �������:   " + DoubleToStr(Pribyl_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("������� - ������", OBJPROP_YDISTANCE, MP_Y_0);     

      ObjectCreate("���������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("���������� - ������", " ����������:   " + DoubleToStr(Rastojanie_R, 2), RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("���������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("���������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("���������� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*1.3);     

      ObjectCreate("����� ���� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("����� ���� - ������", "����� ����:   " + DoubleToStr(Lots_R_2, 3), RazmerShrifta, "Verdana", cvet_CALC_R);
      ObjectSet("����� ���� - ������", OBJPROP_CORNER, 2);
      ObjectSet("����� ���� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta);
      ObjectSet("����� ���� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*2.6);  
                                           
         }
}
}
}
      
      ObjectCreate("������ ������� - ������", OBJ_LABEL, 0, 0, 0);        
      ObjectSetText("������ ������� - ������", "������ �������:" , RazmerShrifta, "Verdana", cvet_CALC_0);
      ObjectSet("������ ������� - ������", OBJPROP_CORNER, 2);
      ObjectSet("������ ������� - ������", OBJPROP_XDISTANCE, MP_X_0+RazmerShrifta*2.5);
      ObjectSet("������ ������� - ������", OBJPROP_YDISTANCE, MP_Y_0+RazmerShrifta*4.5);  
}
      else {Comment_("����.-������.CALC");}


//------------------------------------------------------------------------------------------------//
// ���������
//------------------------------------------------------------------------------------------------//

   Comment("---------------------------- \n i-UrovenZero-v.2.0"  + comment); 
     
   comment = "";
  
   return(0);
}

void Comment_(string com)
{
   comment = comment + "\n" + com;
}


// � Bor-ix & Kirill & d_tom & Don_Leone :) ��� ��������� www.FX4U.ru"


