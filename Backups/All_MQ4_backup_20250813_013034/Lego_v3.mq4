//+------------------------------------------------------------------+
//|                                          Build_Own_Strategy!.mq4 |
//|                                    Copyright © 2010 Seletsky R.V.|
//|                                    Copyleft  @ 2011 Gloodun J. D.|
//|                         Copyleft © 2010-2011, AnonymousMMMMMMMMMI|
//+------------------------------------------------------------------+
#property copyright "S R V; Anon 9001; So"
#property link      "MQL4.com; Strategy4you.ru"

//-----------------------------------------------------------------------------------------------------------+
//                                       Instructions                                                        |
//------------------------------------------------------------------------------------------------------ 1 --+



// This advisor is built as a shell for your genius ideas.
// Has unusual thigs like money managemnt, stops management (very rare bird in bots!)
// Actually, I saw all that attempts of writting lame "grails", so I had to... GIVE AN OPPORTUNITY!
// Srsly. But I have to put MY OWN strategy just for a test...

// I've spent two months of free time for previos version.
// But the previous version was 3/10 rated, so I have to make some more... examples...
// But hey, it is also a collection of free scripts!

// For example, you can find a block of "condition screening",
// or learn, how to use custom indicators, or even input own strategy you was using two years.

// The point is both writting own strategy in minutes and inputting all the scripts and advisor-followers together with the advisor itself.
// Well, 95% of "robots" on MQL4 are empty grails... so I decided to make "Lvl. 11 Universal" robot.


// My point is providing customisability among closing methods...
// Right now, you can write/get own "indicator(s)" for defining closes separately from opens.
// I also capitalised ATR as TP and SL setter. Well, he slows the system, so 




// Anyway, an attempt to put "two different closes at once" was a sort of pain in butt. So I had to make very unnice "dirty hack" way:
// - mount away limits and makes Open Size and Close Size of LOTS different, after what, use same blocks of Signals (Open\Close) for signalling. Looks murky,
// but the worst is possibilty to bug the strategy.

// Well, I can give some examples of coding.









//  //CCI:-------------------------------
// if(otkr_CCI==true)
//             {      
//            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)<-100) See?
//                  {   *    *    *               *     *   *     In's like some highschool math.
//                   CCI_By =true;                                Variable are in the left and in the right. Also: print : "iCCI(" here:
//                                                                You'll see some brief info. Normally, write after: NULL,0
//                  }    
//            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,1)>100) 
//                  {
//                   CCI_Sell =true;
//                  } 
//               }                   
//      
//   if(zakr_CCI==true)
//               {      
//           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)<-100) 
//                  {
//                   Cls_CCI_Sell=true;
//                  }    
//           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,1)>100) 
//                  {
//                   Cls_CCI_By=true;
//                  } 
//               }                   
//                               
//                        



// Or another one (custom, this time. Really may be found here):

// if(otkr_Custom_14==true)                                                 // Well, ZigZag is not too very good example.
//      {
//        if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)// Not for profit!
//        {         //Actually, all the paramethers are just basic ZZ's 5-7-12 or whatever... BASIC ones.)
//        Custom_14_By=true;
//        }
//        
//        if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
//        {
//        Custom_14_Sell=true;
//        }
//       
//      }
//      
// if(zakr_Custom_14==true)
//      {
//        if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)
//        {
//        Cls_Custom_14_By=true;
//        }
//        
//        if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
//        {
//        Cls_Custom_14_Sell=true;
//        }
//        
//     }

//You can find the indicator zone simply by "Ctrl+F"+copt there -    "  Indicators Zone  "  .


//--------------------------------------------------------------------------------------------------




//-----------------Paramethers---------------------------------------------------------- 1 --------

extern   string   The_instruction            =  "...is in code-to comments";
extern   string   General_Paramethers        =  "----  General Paramethers ---- ";            
extern double StopLoss    =0;      // StopLoss
extern double TakeProfit  =0;      // ТakeРrofit. May be defined by indicators also.
extern   string   SleepBars_about            =  "A pause. 600 seconds...";// I hope, theese are really seconds.
extern bool   SleepBars  =false;// A pause
extern double Slippage = 2; // Slippage. Open a dictionary.
extern   string ID_of_EA__About              =  "aka MaigcNumber. What if you need 12 advisors at once?";
extern double ID_of_EA = 219249; // No, not that lame indicator "Zigzag", but a fuct. char.
extern   string    Block_of_Stakes           =  "----  Stake tuning ----"; 
extern   string    Bl_1                      =  "1 - FixLot, 2 - Martigail, 3 - Percental";
extern   string    Bl_2                      =  "Martingail is not a chaser here. Do you need such?"; // I mean, it waits for new deal for covering the problem.
extern   string    Bl_3                      =  "IK is a miltiplies for Martingail-taktic";
extern double StakeMode   =1;      //   
extern double Lts1        =0.1;    // Fixlot
extern double IK          =2;      // Multiplying Lts1 * IK (if the previous deal was fail). Normally, Martingail is ThisDealLots = PrevDealLots * 2,  so...
extern double Percents    =5;      //
  

extern   string   ATR                        =  "---- ---- ---- ----"; 
extern   string   ATR_s_                     =  "ATR is for setting TP and SL. May be replaced."; // Actually, never tuned by me properly.
extern   string   _purpose_is_               =  "ATR_Multiply sets perception, for ex ample:";
extern   string   _stop_management           =  "if Multiply=0.9, then reaction is 0.9 pips per 0.0001 ATR";
extern double ATR_Period =14;
extern double ATR_Multiply = 0.9;         
extern double ATR_Reach  =0.0014;
extern  bool ATR_SL = false;
extern  bool ATR_TP = false;   




 // Do not want more...
extern string Implemented_Indicators         = "Implemented plant-from indicators";
extern string Dont_earse                     = "Each may be found with Ctlr+F command";
extern string WARNING1                       = "NOTE: THE PARAMETHERS OF OPEN AND CLOSE ARE SUPPOSED TO";
extern string WARNING2                       = "BE DEFINED BY YOUR OWN, IT DEPENDS ON SELECTED STRATEGY.";
extern string WARNING3                       = "MAKE SURE THE SELECTED INDICATOR USES YOUR IDEAS PROPERLY!";
extern string The_List_Of                    = "Anyway, the indicators. Use your math abilities.";
extern   string  Two_МАs_Cross               = "---- ---- ";
extern  bool  otkr_MA    =false;
extern  bool  zakr_MA    =false;
extern double MA1           =4;
extern double MA2           =67;
extern double Shift_ma      =1;  // I am too lazy to switch
extern double MA_sort_avoidit=0; //0 - Simple, 1 - Expotential, 2 - Smoothed, 3 - Linear Weighed
extern   string   Stochastic        =  " A little note here. You may need to change the code at inequalities";
extern  bool   otkr_Stoh   =false;
extern  bool   zakr_Stoh   =false;
extern double per_K=5;
extern double per_D=3;
extern double slow=3;
extern double zoneBUY=20;
extern double zoneSELL=80; //No, I couldn't fix the levels.
extern   string   Awesome          =  "But it is all right! B- of math skills must be enough for you.";
extern  bool   otkr_AO   =false;
extern  bool   zakr_AO   =false;
extern   string   Fractals         =  "If you had C- math marks, then ask somebody experienced to help you. You will also save your time.";
extern  bool   otkr_Fractals   =false; 
extern  bool   zakr_Fractals   =false;
extern   string   Accelerator                =  "---- ---- ";
extern  bool   otkr_AC   =false;
extern  bool   zakr_AC   =false;
extern   string   Demarker                   =  "---- ---- ";
extern  bool   otkr_Dema   =false;
extern  bool   zakr_Dema   =false;
extern double DeMa_period=14;
extern double niz_ur=0.3;
extern double verx_ur=0.7;
extern   string   CCI                        =  "---- ---- ";
extern  bool   otkr_CCI   =false;
extern  bool   zakr_CCI   =false;
extern double CCI_period=14;
extern double CCI_Level=100;    // What, if we want 95?
extern   string   RSI                        =  "RSI levels are better to be tuned separately. Just for sure.";
extern  bool   otkr_RSI   =false;
extern  bool   zakr_RSI   =false;
extern double RSI_Period =14;
extern double RSI_High=70;
extern double RSI_Low=30;
extern   string   MACD                       =  "MACD Signal Line";
extern  bool   otkr_MACD   =false;
extern  bool   zakr_MACD   =false;
extern double MACD_Fast=9;
extern double MACD_Slow=26;   // MACD uses SIGNAL line
extern double MACD_Signal=14; // because you have 2 MA Cross system
extern string     OsMA                       = "OsMA - like a second MACD S L";
extern  bool   otkr_OsMA   =false;
extern  bool   zakr_OsMA   =false;
extern double OsMA_Fast=9;
extern double OsMA_Slow=26;   // SIGNAL line (Well, you can also try Zignal.com as a platform - expenseful lux look is a sort of guaranty. Yes, I've made an ad here - Anon MMMMMMMMMI)
extern double OsMA_Signal=14; // because you have 2 MA Cross system
extern   string   WPR                        =  "Williams Percent Range";
extern  bool   otkr_WPR   = false;
extern  bool   zakr_WPR   = false;
extern double WPR_Period = 14;
extern double WPR_Shift = 0; 
extern   string   MoneyFlow_aka_MFI          =  "---";
extern  bool   otkr_MFI   = false;
extern  bool   zakr_MFI   = false;
extern double MFI_Period=14;
extern double MFI_High  =70;
extern double MFI_Low   =30;
extern   string   ADX                        =  "ADX Main Line, уровни - 30 и 70"; 
extern  bool   otkr_ADX   = false;
extern  bool   zakr_ADX   = false;
extern double ADX_Period=14;
extern string SAR                            =  "---";
extern  bool otkr_SAR = false;
extern  bool zakr_SAR = false;
extern double SAR_Step =0.02;
extern double SAR_MaxStep =0.2;



// And switchers for customs.



extern string Custom_Indicators              =  "Custom Indicators. ";  
extern string Custom_Indicator1              =  "Each is already defined.";

extern  bool  otkr_Custom_1 = false;
extern  bool  zakr_Custom_1 = false;
extern double example1      = 0;  //Example doubles.
extern double example2      = 0;

//extern double Period1   =4;          // Sorry, theese ones don't work yet. Also, their implementation makes system not too much slower...
//extern double Shift1    =3;
extern string Custom_Indicator2              =  "This one also";
extern  bool  otkr_Custom_2 = false;
extern  bool  zakr_Custom_2 = false;
//extern double Period2   =4;
//extern double Shift2    =3;
extern string Custom_Indicator3              =  "----";
extern  bool  otkr_Custom_3 = false;
extern  bool  zakr_Custom_3 = false;
//extern double Period3   =4;
//extern double Shift3    =3;
extern string Custom_Indicator4              =  "Sometimes you need to edit this thing by own,";
extern  bool  otkr_Custom_4 = false;
extern  bool  zakr_Custom_4 = false;
//extern double Period4   =4;
//extern double Shift4    =3;
// extern string Custom_Indicator5              =  "just for putting new indicators.";
// extern  bool  otkr_Custom_5 = false;
// extern  bool  zakr_Custom_5 = false;
// extern double Period5   =4;
// extern double Shift5    =3;
// extern string Custom_Indicator6              =  "----";
// extern  bool  otkr_Custom_6 = false;
// extern double Period6   =4;
// extern double Shift6    =3;
// extern string Custom_Indicator7              =  "There are 16 customs and 16 pre-defined indicators.";
// extern  bool  otkr_Custom_7 = false;
// extern  bool  zakr_Custom_7 = false;
// extern double Period7   =4;
// extern double Shift7    =3;
// extern string Custom_Indicator8              =  "That is why backtest may be slow.";
// extern  bool  otkr_Custom_8 = false;
// extern  bool  zakr_Custom_8 = false;
// extern double Period8   =4;
// extern double Shift8    =3;
// extern string Custom_Indicator9              =  "----";
// extern  bool  otkr_Custom_9 = false;
// extern  bool  zakr_Custom_9 = false;
// extern double Period9   =4;
// extern double Shift9    =3;
// extern string Custom_Indicator10             =  "Buy hey. I do not worrying about BACKtests if the strategy is already proven on stat lot.";
// extern  bool  otkr_Custom_10= false;
// extern  bool  zakr_Custom_10= false;
// extern double Period10  =4;
// extern double Shift10   =3;
// extern string Custom_Indicator11             =  "You know, you just need to stick an idea, nothing more.";
// extern  bool  otkr_Custom_11= false;
// extern  bool  zakr_Custom_11= false;
// extern double Period11  =4;
// extern double Shift11   =3;
// extern string Custom_Indicator12             =  "---";
// extern  bool  otkr_Custom_12= false;
// extern  bool  zakr_Custom_12= false;
// extern double Period12  =4;
// extern double Shift12   =3;
// extern string Custom_Indicator13             =  "Well, I have not constant Internet connection. Sorry for low traider level";
// extern  bool  otkr_Custom_13= false;
// extern  bool  zakr_Custom_13= false;
// extern double Period13  =4;
// extern double Shift13   =3;
// extern string Custom_Indicator14             =  "---";
// extern  bool  otkr_Custom_14= false;
// extern  bool  zakr_Custom_14= false;
// extern double Period14  =4;
// extern double Shift14   =3;
// extern string Custom_Indicator15             =  "Do NOT rename the doubles and bools";
// extern  bool  otkr_Custom_15= false;
// extern  bool  zakr_Custom_15= false;
// extern double Period15  =4;
// extern double Shift15   =3;
// extern string Custom_Indicator16             =  "Sometimes you will have to add new doubles.";
// extern  bool  otkr_Custom_16= false;
// extern  bool  zakr_Custom_16= false;
// extern double Period16  =4;
// extern double Shift16   =3; 


// 




bool Work=true;                    
bool OrderSal;
string Symb;                       // Pair (ex. EURUSD) Name



//-----------------------------------------------------------  2  -----
int start()

  { 
//----------
   int  
   Total,                           // Orders in window. 
   Tip=-1,                          // Type of order
   Ticket;                          // Number of order

   double
   Lot,                             // Size of selected order
   Lts,                             // Size of opening order
   lot,
   Min_Lot,                         // Min. Size
   Step,                            // Min. Step (if modifying)
   Free,                            // Free money on account
   One_Lot,                         // Cost of 1 lot
   Price,                           // Cost of selected order
   SL,                              // SL of selected
   TP,                              // TP of selected
   //--
   MA_By,MA_Sell,Stoh_By,Stoh_Sell,AO_By,AO_Sell,Fractals_By,Fractals_Sell,AC_By,AC_Sell,Cls_MA_Sell,Cls_MA_By,Cls_Stoh_Sell,Cls_Stoh_By,
   Cls_AO_Sell,Cls_AO_By,Cls_Fractals_By,Cls_Fractals_Sell,Cls_AC_Sell,Cls_AC_By,Dema_By,Cls_Dema_Sell,Dema_Sell,Cls_Dema_By,CCI_By,CCI_Sell,Cls_WPR_Sell,Cls_CCI_By,Cls_CCI_Sell,
   RSI_By,RSI_Sell,Cls_RSI_Sell,Cls_RSI_By,MFI_By,MFI_Sell,Cls_MFI_Sell,Cls_MFI_By,WPR_By,WPR_Sell,Cls_WRP_Sell,Cls_WPR_By,  //добавленное.
   MACD_By,MACD_Sell,Cls_MACD_Sell,Cls_MACD_By,OsMA_By,OsMA_Sell,Cls_OsMA_Sell,Cls_OsMA_By,ADX_By,ADX_Sell,Cls_ADX_Sell,Cls_ADX_By,SAR_By,SAR_Sell,Cls_SAR_Sell,Cls_SAR_By,
   Custom_1__By, Custom_1__Sell, Cls_Custom_1__By, Cls_Custom_1__Sell,Custom_2__By, Custom_2__Sell, Cls_Custom_2__By, Cls_Custom_2__Sell,Custom_3__By, Custom_3__Sell, Cls_Custom_3__By, Cls_Custom_3__Sell,Custom_4__By, Custom_4__Sell, Cls_Custom_4__By, Cls_Custom_4__Sell;//,

//   Custom_5__By, Custom_5__Sell, Cls_Custom_5__By, Cls_Custom_5__Sell,Custom_6__By, Custom_6__Sell, Cls_Custom_6__By, Cls_Custom_6__Sell,Custom_7__By, Custom_7__Sell, Cls_Custom_7__By, Cls_Custom_7__Sell,Custom_8__By, Custom_8__Sell, Cls_Custom_8__By, Cls_Custom_8__Sell,
//   Custom_9__By, Custom_9__Sell, Cls_Custom_9__By, Cls_Custom_9__Sell,Custom_10_By, Custom_10_Sell, Cls_Custom_10_By, Cls_Custom_10_Sell,Custom_11_By, Custom_11_Sell, Cls_Custom_11_By, Cls_Custom_11_Sell,Custom_12_By, Custom_12_Sell, Cls_Custom_12_By, Cls_Custom_12_Sell,
//   Custom_13_By, Custom_13_Sell, Cls_Custom_13_By, Cls_Custom_13_Sell,Custom_14_By, Custom_14_Sell, Cls_Custom_14_By, Cls_Custom_14_Sell,Custom_15_By, Custom_15_Sell, Cls_Custom_15_By, Cls_Custom_15_Sell,Custom_16_By, Custom_16_Sell, Cls_Custom_16_By, Cls_Custom_16_Sell;
// Theese bools were switched off, because "short" cose is more backtestable* 



 //Also, I am thinking about using NewsTraiderEA's library here. Or not... Too long to implement, but suddnely, no real trader guy uses "only technical". So i just have to use news.
  

 bool
   Modific=true,
   Ans  =false,                     // Server's ansver (after modifying or closing)
   Cls_B=false,                     // Buy  Close criteria bool
   Cls_S=false,                     // Sell Close criteria bool
   Opn_B=false,                     // Buy  Open  criteria bool
   Opn_S=false,                     // Sell Open  criteria bool
   S_Bar=false;                     // Sleep Bars (aka Pause-600) bool.
   
   
   

  
// Comment        //  Decided to switch it off. You can resurrect it... but it's only for "real job", not for a backtest.
//( 
//  "TIME: ",TimeToStr(TimeCurrent()),
//  "\n",
//  "Order-s paramethers (##,TP,SL,LOT): |",OrderTicket(),"|",OrderStopLoss(),"|",OrderTakeProfit(),"|",OrderLots(),"|",
//  "\n", 
//  "ID_Number: ", ID_of_EA,
//  "\n",
//  "StakeType, #:",StakeMode,                                                   
//  "\n" //, 
//  "% for #3: ",Percents, 
//  "\n",
//  "StopOut: ", AccountStopoutLevel(), 
//  "\n",
//  "Spread: ", MarketInfo(Symbol(),MODE_SPREAD),
//  "\n",
//  "Leverage, 1 to: ",AccountLeverage(),
//  "\n",
//  "Broker", TerminalCompany( ) ,
//  "\n",
//  "\n",
//  "\n", // 
//  "\n"
//  );      // Eats resources very greedy. So, I've switched it off.

// It's probably, most resoure-eating thing for the backtest. I'll freeze it another time, but still... 
// Sorry, you can restore it quickly, but still...  





  
//-------------------- Pause after closed order. ------------------ 3 -


  
int time0 = 0;                                                  // Necessary booleans sorting...
for(int t0 = OrdersHistoryTotal();t0>=0;t0--)                   // Search among closed orders
if(OrderSelect(t0, SELECT_BY_POS,MODE_HISTORY )==true)          // A-a-and it we found it...
    {
      if( iTime(NULL,0,1)-OrderOpenTime() < 600 && SleepBars==true ) //We're pausing. This string has the terms of pause.
                 {                              //                   // BTW, time is in seconds by standard.    
                    S_Bar=true;                                
                    Alert("Gimme a break...");                                           
                 }
//          return(0);  // Hey, it's first time I had a bug. Remember - "switched off" by True/False cosesnippet can make it's influence.
          }
//----------------------------------------------------------------------

//-------------------- Pre-Work Sorting-------------------------- 4 -    

   if(Bars<15)                       // Insufficient quantity of bars
     {
      Alert("Bars<15, need more bars of history.");
      return;                                   // Exit from start()
     }
     
     
   if(Work==false)                              // Critical error
     {
      Alert("Critical Error occured.");
      return;                                   // Exit from start()
     }
//------------------------------------------------------------------------------    
     
     
//------------------------------Orders counting--------------------------------- 4 --
Symb=Symbol();                                
   Total=0;                                      
   for(int i=1; i<=OrdersTotal(); i++)           
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true)  
        {                                        
         if (OrderSymbol()!=Symb)continue;      
         if (OrderType()>1)                     
           {
            Alert("Unusual order detected. Pause."); // Well, I'll leave it here since first author made it...
            return;                             
           }
         Total++;                               //
         if (Total>3)                           // Only one order on one pair. Made for brokers and their trust.
           {
            Alert("Too much orders. Pause."); // Normally ONE, but I am not against.
            return;                             // exit from start()
           }
         Ticket=OrderTicket();                  // 
         Tip   =OrderType();                    // It's info about lots...
         Price =OrderOpenPrice();               // 
         SL    =OrderStopLoss();                // 
         TP    =OrderTakeProfit();              // 
         Lot   =OrderLots();                    // Lots in the order
        }
     }  

 
//------------Indicators Zone--------(Here they're switching on)------------ 6 --
//Tune the indicators, huh?



//-------------  Pre-Installed indicators

// NOTE: THE PARAMETHERS OF "OPED" AND "CLOSE" ARE SUPPOSED
// TO BE DEFINED BY YOUR OWN, IT DEPENDS ON SELECTED STRATEGY.
// MAKE SURE THE SELECTED INDICATOR OPENS AND CLOSES PROPERLY!


   
//ATR for TP and SL is here------------------------------     

if(ATR_SL==true && iATR(NULL,0,ATR_Period,1)>=ATR_Reach)
StopLoss=iATR(NULL,0,ATR_Period,0)*ATR_Multiply/0.0001;    //Yes, not the "price", but the "pips".          

if(ATR_TP==true && iATR(NULL,0,ATR_Period,1)>=ATR_Reach)
TakeProfit=iATR(NULL,0,ATR_Period,0)*ATR_Multiply/0.0001;


//MAs------------------------------------
 if(otkr_MA==true)
              {
               if( iMA(NULL,0,MA1,0,MA_sort_avoidit,PRICE_CLOSE,Shift_ma)>iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,Shift_ma))
                 {
                  MA_By =true;// Normally SMA, but here is my edit.
                 } 
               if(iMA(NULL,0,MA1,0,MA_sort_avoidit,PRICE_CLOSE,Shift_ma)<iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,Shift_ma))               
                 {
                  MA_Sell =true;
                 } 
               }
               
 if(zakr_MA==true)
              {
               if(iMA(NULL,0,MA1,0,MA_sort_avoidit,PRICE_CLOSE,Shift_ma)>iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,Shift_ma))
                 {
                  Cls_MA_Sell=true;
                 } 
               if(iMA(NULL,0,MA1,0,MA_sort_avoidit,PRICE_CLOSE,Shift_ma)<iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,Shift_ma))
                 {
                  Cls_MA_By=true;
                 } 
               }             
//Стохастик-------------------------------
 if(otkr_Stoh==true)
          {
               if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)>iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
                  && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)<zoneBUY)
                   {
                   Stoh_By =true;
                   }
              if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)<iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
                 && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)>zoneSELL)
                  {
                  Stoh_Sell =true;
                  } 
               }      
               
 if(zakr_Stoh==true)
          {
              if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)>iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
                 && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)<zoneBUY)
                   {
                   Cls_Stoh_Sell=true;
                   }
             if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)<iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
                 && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)>zoneSELL)
                  {
                  Cls_Stoh_By=true;
                  } 
               }                
//Awesome--------------------------------
  if(otkr_AO==true)
        {
              if(iAO(NULL,0,0)+iAO(NULL,0,1)>iAO(NULL,0,2)+iAO(NULL,0,3))
                  {
                   AO_By =true;
                  }    
              if(iAO(NULL,0,0)+iAO(NULL,0,1)<iAO(NULL,0,2)+iAO(NULL,0,3))
                  {
                   AO_Sell =true;
                  } 
               } 
               
if(zakr_AO==true)
        {
           if(iAO(NULL,0,0)+iAO(NULL,0,1)>iAO(NULL,0,2)+iAO(NULL,0,3))
                  {
                   Cls_AO_Sell=true;
                  }    
            if(iAO(NULL,0,0)+iAO(NULL,0,1)<iAO(NULL,0,2)+iAO(NULL,0,3))
                  {
                   Cls_AO_By=true;
                  } 
               }
//Fractals--------------------------------
               
  if(otkr_Fractals==true)
        {
              if(iFractals(NULL,0,1,0)<PRICE_CLOSE)
                  {                    
                   Fractals_By =true;
                  }    
              if(iFractals(NULL,0,2,0)>PRICE_CLOSE)
                  {
                   Fractals_Sell =true;
                  } 
               } 
               
if(zakr_Fractals==true)
        {
           if (iFractals(NULL,0,1,0)<PRICE_CLOSE)
                  {             
                   Cls_Fractals_Sell=true;
                  }    
            if(iFractals(NULL,0,2,0)>PRICE_CLOSE)
                  {
                   Cls_Fractals_By=true;
                  } 
               }                
//Accelerator---------------------------
   if(otkr_AC==true)
               {          
               if (iAC(NULL,0,0)>=0 && iAC(NULL,0,0)>iAC(NULL,0,1) && iAC(NULL,0,1)>iAC(NULL,0,2) || iAC(NULL,0,0)<=0 && iAC(NULL,0,0)>iAC(NULL,0,1) && iAC(NULL,0,1)>iAC(NULL,0,2) && iAC(NULL,0,2)>iAC(NULL,0,3)) 
                  {
                   AC_By =true;
                  }    
               if (iAC(NULL,0,0)<=0 && iAC(NULL,0,0)<iAC(NULL,0,1) && iAC(NULL,0,1)<iAC(NULL,0,2) || iAC(NULL,0,0)>=0 && iAC(NULL,0,0)<iAC(NULL,0,1) && iAC(NULL,0,1)<iAC(NULL,0,2) && iAC(NULL,0,2)<iAC(NULL,0,3)) 
                  {
                   AC_Sell =true;
                  }  
                }   
            // Seletsky's AC. I don't know, why he detailed it...
  if(zakr_AC==true)
              {          
              if (iAC(NULL,0,0)>=0 && iAC(NULL,0,0)>iAC(NULL,0,1) && iAC(NULL,0,1)>iAC(NULL,0,2) || iAC(NULL,0,0)<=0 && iAC(NULL,0,0)>iAC(NULL,0,1) && iAC(NULL,0,1)>iAC(NULL,0,2) && iAC(NULL,0,2)>iAC(NULL,0,3)) 
                  {
                    Cls_AC_Sell=true;
                  }    
             if (iAC(NULL,0,0)<=0 && iAC(NULL,0,0)<iAC(NULL,0,1) && iAC(NULL,0,1)<iAC(NULL,0,2) || iAC(NULL,0,0)>=0 && iAC(NULL,0,0)<iAC(NULL,0,1) && iAC(NULL,0,1)<iAC(NULL,0,2) && iAC(NULL,0,2)<iAC(NULL,0,3)) 
                  {
                   Cls_AC_By=true;
                  }  
               }   
 //Demarker---------------------------- 
 if(otkr_Dema==true) 
             {      
              if (iDeMarker(NULL, 0, DeMa_period, 1)<niz_ur) 
                  {
                   Dema_By =true;
                  }    
             if (iDeMarker(NULL, 0, DeMa_period, 1)>verx_ur) 
                  {
                   Dema_Sell =true;
                  }  
               }
          
 if(zakr_Dema==true) 
              {      
            if (iDeMarker(NULL, 0, DeMa_period, 1)<niz_ur) 
                  {
                   Cls_Dema_Sell=true;
                  }    
            if (iDeMarker(NULL, 0, DeMa_period, 1)>verx_ur) 
                  {
                   Cls_Dema_By=true;
                  }  
               }     
  //CCI:------------------that's how I've made a hook method here
 if(otkr_CCI==true)
             {      
            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,0)>iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,1) && iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,1)<iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,2)) // А тут как дивергенцию ловить?
                  {
                   CCI_By =true;
                  }    
            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,0)<iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,1) && iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,1)>iCCI(NULL, 0, CCI_period,PRICE_MEDIAN,2)) 
                  {
                   CCI_Sell =true; 
                  } 
               }                   
                   
   if(zakr_CCI==true)
               {      
           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)<-CCI_Level) // Тоже по крюку.
                  {
                   Cls_CCI_Sell=true;
                  }    
           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)>CCI_Level) // CCI используется как осциллятор перекуп.\перепрод. Как Стохастик.
                  {
                   Cls_CCI_By=true;
                  } 
               } 
               


//Heh-heh, the example is here, but it's (coolface.jpg) disabled!1one

//  //CCI:-------------------------------
// if(otkr_CCI==true)
//             {      
//            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)<-100) 
//                  {
//                   CCI_By =true;
//                  }    
//            if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,1)>100) 
//                  {
//                   CCI_Sell =true;
//                  } 
//               }                   
//      
//   if(zakr_CCI==true)
//               {      
//           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN, 1)<-100) 
//                  {
//                   Cls_CCI_Sell=true;
//                  }    
//           if (iCCI(NULL, 0,CCI_period,PRICE_MEDIAN,1)>100) 
//                  {
//                   Cls_CCI_By=true;
//                  } 
//               }                   
//                               
//                             




               
//RSI---------------------------------------------------------------------
  
    if(otkr_RSI==true)
              {
            if (iRSI(NULL,0,RSI_Period,1,0)>RSI_High)
                  {
                   RSI_By=true;
                  }    
            if (iRSI(NULL,0,RSI_Period,1,0)<RSI_Low)
                  {
                   RSI_Sell=true;
                  } 
               }                   
      
   if(zakr_RSI==true)
              {
           if (iRSI(NULL,0,RSI_Period,1,0)>RSI_High)
                  {
                   Cls_RSI_Sell=true;
                  }    
           if (iRSI(NULL,0,RSI_Period,1,0)<RSI_Low)
                  {
                   Cls_RSI_By=true;
                  } 
               }            
  
//MFI-------------------------------             
  
    
    if(otkr_MFI==true)
              {
            if (iMFI(NULL,0,MFI_Period,0)>MFI_High)
                  {
                   MFI_By=true;
                  }    
            if (iMFI(NULL,0,MFI_Period,0)<MFI_Low)
                  {
                   MFI_Sell=true;
                  } 
               }                   
      
   if(zakr_MFI==true)
                 {      
           if (iMFI(NULL,0,MFI_Period,0)>MFI_High/2+MFI_Low/2)
                  {
                   Cls_MFI_Sell=true;
                  }    
           if (iMFI(NULL,0,MFI_Period,0)<MFI_High/2+MFI_Low/2)
                  {
                   Cls_MFI_By=true;
                  } 
               }   
               
//WPR--------------------------------         
  
   if(otkr_WPR==true)
              {
            if (iWPR(NULL,0,WPR_Period,WPR_Shift)>-20)
                  {
                   WPR_By=true;
                  }    
            if (iWPR(NULL,0,WPR_Period,0)<-80)
                  {
                   WPR_Sell=true;
                  } 
               }                   
      
   if(zakr_WPR==true)
                 {      
           if (iWPR(NULL,0,WPR_Period,0)>-20)
                  {
                   Cls_WPR_Sell=true;
                  }    
           if (iWPR(NULL,0,WPR_Period,0)<-80)
                  {
                   Cls_WPR_By=true;
                  } 
               }   
  
  
  
  
//MACD-------------------------------      
  
    
   if(otkr_MACD==true)
              {
            if (iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,0)>iMACD(NULL,0,9,26,14,1,1,1))
                  {
                   MACD_By=true;
                  }    
            if (iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,0)<iMACD(NULL,0,9,26,14,1,1,1))
                  {
                   MACD_Sell=true;
                  } 
               }                   
      
   if(zakr_MACD==true)
                 {      
           if (iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,0)>iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,1))
                  {
                   Cls_MACD_Sell=true;
                  }    
           if (iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,0)<iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,1))
                  {
                   Cls_MACD_By=true;
                  } 
               }           
//OsMA-------------------------------      
  
    
   if(otkr_OsMA==true)
              {
            if (iOsMA(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,0)>iMACD(NULL,0,9,26,14,1,1,1))
                  {
                   MACD_By=true;
                  }    
            if (iOsMA(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,0)<iMACD(NULL,0,9,26,14,1,1,1))
                  {
                   MACD_Sell=true;
                  } 
               }                   
      
   if(zakr_OsMA==true)
                 {      
           if (iOsMA(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,0)>iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,1))
                  {
                   Cls_MACD_Sell=true;
                  }    
           if (iOsMA(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,0)<iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,1,1,1))
                  {
                   Cls_MACD_By=true;
                  } 
               }            
  

  
//ADX-------------------------------             
    
   if(otkr_ADX==true)
              {
            if (iADX(NULL,0,ADX_Period,1,0,0)>70)
                  {
                   ADX_By=true;
                  }    
            if (iADX(NULL,0,ADX_Period,1,0,0)<30)
                  {
                   ADX_Sell=true;
                  } 
               }                   
      
   if(zakr_ADX==true)
                 {      
           if (iADX(NULL,0,ADX_Period,1,0,0)>70)
                  {
                   Cls_ADX_Sell=true;
                  }    
           if (iADX(NULL,0,ADX_Period,1,0,0)<30)
                  {
                   Cls_ADX_By=true;
                  } 
               }    
               
//SAR------------------------------- 
      
   
    
   if(otkr_SAR==true)
              {
            if(iSAR(NULL,0,SAR_Step,SAR_MaxStep,0)>Close[0])
                  {
                   SAR_By=true;
                  }    
            if(iSAR(NULL,0,SAR_Step,SAR_MaxStep,0)<Close[0])
                  {
                   SAR_Sell=true;
                  } 
               }                   
      
   if(zakr_SAR==true)
                 {      
           if (iSAR(NULL,0,SAR_Step,SAR_MaxStep,0)>Close[0])
                  {
                   Cls_SAR_Sell=true;
                  }    
           if(iSAR(NULL,0,SAR_Step,SAR_MaxStep,0)<Close[0])
                  {
                   Cls_SAR_By=true;
                  } 
               }              



// A-a-a-nd the custom indicators. I bet you were searching for some newbie-for possibility to use custom indicators.
//--------Custom_1__------------------
if(otkr_Custom_1==true)  
     {
       if(iCustom(NULL,0,"StochasticStack",0,0)>PRICE_CLOSE)     // You know, you're supposed to tune the custom indicator by yourself.    
       {                                                // I mean, all the tunes are saved in code (as basiccal\standard)
       Custom_1__By=true;                               // As a rule, the custom inds don't need any tunes... mostly...
       }                                                // Well, if any problems, you just need to edit an indicator simply by changing the digits "in case".
                       //"Theese \/  ones"   // Snippet:   between name ("ZZ") and last two (,0,0)) digits you can put variables 
       if(iCustom(NULL,0,"StochasticStack",example1,example2,0,0)<PRICE_CLOSE)// Lamest ever :)
       {
       Custom_1__Sell=true;
       }
       
     }
     
if(zakr_Custom_1==true)
     {
       if(iCustom(NULL,0,"StochasticStack",0,0)>PRICE_CLOSE)  
       {
       Cls_Custom_1__By=true;// _1__ , because there are up to 16 custom inds aviliable - you can find _10_, _16_, _9__...
       }
       
       if(iCustom(NULL,0,"StochasticStack",0,0)<PRICE_CLOSE)
       {
       Cls_Custom_1__Sell=true;
       }
       
     }
     
//--------Custom_2__------------------
if(otkr_Custom_2==true)  
     {
       if(iCustom(NULL,0,"Parabolic_ZZ",0,0)>PRICE_CLOSE)         // Just don't use my "filler".
       {                                                    // It won't work anyway.
       Custom_2__By=true;
       }
       
       if(iCustom(NULL,0,"Parabolic_ZZ",0,0)<PRICE_CLOSE)
       {
       Custom_2__Sell=true;
       }
       
     }
     
if(zakr_Custom_2==true)
     {
       if(iCustom(NULL,0,"Parabolic_ZZ",0,0)>PRICE_CLOSE) // Lamest ever :)
       {
       Cls_Custom_2__By=true;
       }
       
       
       
       if(iCustom(NULL,0,"Parabolic_ZZ",0,0)<PRICE_CLOSE)
       {
       Cls_Custom_2__Sell=true;
       }
       
     }
     
//--------Custom_3__------------------
if(otkr_Custom_3==true)  
     {
       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)         
       {                                            
       Custom_3__By=true;
       }
       
       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
       {
       Custom_3__Sell=true;
       }
       
     }
     
if(zakr_Custom_3==true)
     {
       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)
       {
       Cls_Custom_3__By=true;
       }
       
       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
       {
       Cls_Custom_3__Sell=true;
       }
       
     }
     
     
//--------Custom_4__------------------
if(otkr_Custom_4==true)  
     {
       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)         
         {                                                    
       Custom_4__By=true;
       }
       
       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
       {
       Custom_4__Sell=true;
       }
       
     }
     
if(zakr_Custom_4==true)
     {
       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)
       {
       Cls_Custom_4__By=true;
       }
       
       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
       {
       Cls_Custom_4__Sell=true;
       }
       
     }
     
     

//--------Custom_5__-Custom_16_ are earsed. They all are supposed to be restored here maunally. I. E. "copy, paste, change some digits"

//--------Custom_16_------------------
//if(otkr_Custom_16==true)  
//     {
//       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE)         
//         {                                                    
//       Custom_16_By=true;
//       }
//       
//       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
//       {
//       Custom_16_Sell=true;
//       }
//       
//     }
//     
//if(zakr_Custom_16==true)
//     {
//       if(iCustom(NULL,0,"ZigZag",0,0)>PRICE_CLOSE) - 16th is here as an example. Try to barely de"//" it, then solve the "errors" occured.
//       {
//       Cls_Custom_16_By=true;
//       }
//       
//       if(iCustom(NULL,0,"ZigZag",0,0)<PRICE_CLOSE)
//       {
//       Cls_Custom_16_Sell=true;
//       }
//       
//     }
          










          
//--------------------------------Open Buy and Sell------------------------------------------  7  ----//

  if (MA_By ==true||otkr_MA==false  &&
    Stoh_By ==true||otkr_Stoh==false&&
      AO_By ==true||otkr_AO==false  &&
Fractals_By ==true||otkr_Fractals==false&&
      AC_By ==true||otkr_AC==false  &&
    Dema_By ==true||otkr_Dema==false&&
     CCI_By ==true||otkr_CCI==false &&
     RSI_By ==true||otkr_RSI==false &&
     MFI_By ==true||otkr_MFI==false &&
     WPR_By ==true||otkr_WPR==false && 
     MACD_By==true||otkr_MACD==false && 
     OsMA_By==true||otkr_OsMA==false && 
     ADX_By ==true||otkr_ADX==false &&
     SAR_By ==true||otkr_SAR==false &&
     Custom_1__By==true||otkr_Custom_1==false&&  // Custom1 is for Fractals
     Custom_2__By==true||otkr_Custom_2==false&&
     Custom_3__By==true||otkr_Custom_3==false&&
     Custom_4__By==true||otkr_Custom_4==false
//&&
//     Custom_5__By==true||otkr_Custom_5==false&& // All the bools from 5 to 16 may be switched off for speed in so-called "Fast Mod"
//     Custom_6__By==true||otkr_Custom_6==false&&
//     Custom_7__By==true||otkr_Custom_7==false&&
//     Custom_8__By==true||otkr_Custom_8==false&&
//     Custom_9__By==true||otkr_Custom_9==false&&
//     Custom_10_By==true||otkr_Custom_10==false&&
//     Custom_11_By==true||otkr_Custom_11==false&&
//     Custom_12_By==true||otkr_Custom_12==false&&
//     Custom_13_By==true||otkr_Custom_13==false&&
//     Custom_14_By==true||otkr_Custom_14==false&&
//     Custom_15_By==true||otkr_Custom_15==false&&
//     Custom_16_By==true||otkr_Custom_16==false    // Earse some lines for effect. Guess, which ones :)
     
     )
     {                                          
      Opn_B=true;
     }
//---------    
  if (  MA_Sell==true||otkr_MA==false   &&
     Stoh_Sell ==true||otkr_Stoh==false &&
      AO_Sell  ==true||otkr_AO==false   &&
      Fractals_Sell==true||otkr_Fractals==false &&
      AC_Sell  ==true||otkr_AC==false   &&
     Dema_Sell ==true||otkr_Dema==false &&
      CCI_Sell ==true||otkr_CCI==false  &&          
      RSI_Sell ==true||otkr_RSI==false  &&
      MFI_Sell ==true||otkr_MFI==false  &&
      WPR_Sell ==true||otkr_WPR==false  &&
      MACD_Sell==true||otkr_MACD==false &&
      OsMA_Sell==true||otkr_OsMA==false && 
      ADX_Sell ==true||otkr_ADX==false &&
      SAR_Sell ==true||otkr_SAR==false &&
     Custom_1__Sell==true||otkr_Custom_1==false&&  // Custom1 is for Fractals
     Custom_2__Sell==true||otkr_Custom_2==false&&
     Custom_3__Sell==true||otkr_Custom_3==false&&
     Custom_4__Sell==true||otkr_Custom_4==false   // I was too lazy that day. Sorry.
      
     //---_5__, _10_, _16_ etc. 
      ) 
     {                                          
      Opn_S=true;
     } 
//--------------------------------Closing-----------------------------------------------//
if  (Cls_MA_By  ==true||zakr_MA==false  &&
     Cls_Stoh_By==true||zakr_Stoh==false&&
     Cls_AO_By  ==true||zakr_AO==false  &&
     Cls_Fractals_By==true||zakr_Fractals==false &&
     Cls_AC_By  ==true||zakr_AC==false  &&
     Cls_Dema_By==true||zakr_Dema==false&&    
     Cls_CCI_By ==true||zakr_CCI==false &&  
     Cls_RSI_By ==true||zakr_RSI==false &&    
     Cls_MFI_By ==true||zakr_MFI==false &&    
     Cls_WPR_By ==true||zakr_WPR==false &&    
     Cls_MACD_By==true||zakr_MACD==false&&  
     Cls_OsMA_By==true||zakr_OsMA==false &&          // "By" instead of "Buy" is because it's Russian quality mark.
     Cls_ADX_By ==true||zakr_ADX==false &&           // Also known as "cheap and angry" or how Americans say equal idioma?
     Cls_SAR_By ==true||zakr_SAR==false &&
     Cls_Custom_1__By==true||zakr_Custom_1==false&&
     Cls_Custom_2__By==true||zakr_Custom_2==false&&
     Cls_Custom_3__By==true||zakr_Custom_3==false&&
     Cls_Custom_4__By==true||zakr_Custom_4==false//&&
//     Cls_Custom_5__By==true||zakr_Custom_5==false&&
//     Cls_Custom_6__By==true||zakr_Custom_6==false&&
//     Cls_Custom_7__By==true||zakr_Custom_7==false&&
//     Cls_Custom_8__By==true||zakr_Custom_8==false&&
//     Cls_Custom_9__By==true||zakr_Custom_9==false&&
//     Cls_Custom_10_By==true||zakr_Custom_10==false&&
//     Cls_Custom_11_By==true||zakr_Custom_11==false&&
//     Cls_Custom_12_By==true||zakr_Custom_12==false&&
//     Cls_Custom_13_By==true||zakr_Custom_13==false&&
//     Cls_Custom_14_By==true||zakr_Custom_14==false&&
//     Cls_Custom_15_By==true||zakr_Custom_15==false&&
//     Cls_Custom_16_By==true||zakr_Custom_16==false
      ) 
     {                                          
      Cls_B=true;
     }   
 if (Cls_MA_Sell ==true||zakr_MA==false  &&
   Cls_Stoh_Sell ==true||zakr_Stoh==false&&
     Cls_AO_Sell ==true||zakr_AO==false  &&
     Cls_Fractals_Sell==true||zakr_Fractals==false &&
     Cls_AC_Sell ==true||zakr_AC==false  &&
    Cls_Dema_Sell==true||zakr_Dema==false&&    
     Cls_CCI_Sell==true||zakr_CCI==false &&        
     Cls_RSI_Sell==true||zakr_RSI==false &&    
     Cls_MFI_Sell==true||zakr_MFI==false &&    
     Cls_WPR_Sell==true||zakr_WPR==false &&    
    Cls_MACD_Sell==true||zakr_MACD==false&&  
    Cls_OsMA_Sell==true||zakr_OsMA==false&& 
     Cls_ADX_Sell==true||zakr_ADX==false && 
     Cls_SAR_Sell==true||zakr_SAR==false &&
     Cls_Custom_1__Sell==true||zakr_Custom_1==false&&
     Cls_Custom_2__Sell==true||zakr_Custom_2==false&&
     Cls_Custom_3__Sell==true||zakr_Custom_3==false&&
     Cls_Custom_4__Sell==true||zakr_Custom_4==false
//     Cls_Custom_5__Sell==true||zakr_Custom_5==false&&
//     Cls_Custom_6__Sell==true||zakr_Custom_6==false&&
//     Cls_Custom_7__Sell==true||zakr_Custom_7==false&&
//     Cls_Custom_8__Sell==true||zakr_Custom_8==false&&
//     Cls_Custom_9__Sell==true||zakr_Custom_9==false&&
//     Cls_Custom_10_Sell==true||zakr_Custom_10==false&&
//     Cls_Custom_11_Sell==true||zakr_Custom_11==false&&
//     Cls_Custom_12_Sell==true||zakr_Custom_12==false&&
//     Cls_Custom_13_Sell==true||zakr_Custom_13==false&&
//     Cls_Custom_14_Sell==true||zakr_Custom_14==false&&
//     Cls_Custom_15_Sell==true||zakr_Custom_15==false&&
//     Cls_Custom_16_Sell==true||zakr_Custom_16==false
         )    // - there must be the parenthis
     
                 
     {                        
      Cls_S=true;
     } 




//-----------------------------Closing the orders (by signals from previous part :)   )---------------------------------- 8 --
  
   while(true)                                  // Cycle of closing
     {
      if (Tip==0 && Cls_B==true)                // Closing the Buy
        {                                       //
         Alert("Closing Buy Order Attempt",Ticket,". Wait...");
         RefreshRates();                        // Update
         Ans=OrderClose(Ticket,Lot,Bid,2);      // Closing...
         if (Ans==true)                         // ...succesful
           {
            Alert ("Closed Buy Order #",Ticket);
            
            break;                              // exit from cycle
           }
         if (Fun_Error(GetLastError())==1)      // "Fun" is for Function. Errors search.
            continue;                           // Retrying
         return;                                // exit from start()
        }

      if (Tip==1 && Cls_S==true)                // Closing the Sell
        {                                       // 
         Alert("Closing Sell Order Attempt",Ticket,". Wait...");
         RefreshRates();                        // Update
         Ans=OrderClose(Ticket,Lot,Ask,2);      // Closing...
         if (Ans==true)                         // ...Success.                                            For advanced coders only
           {
            Alert ("Closed Sell Order #",Ticket);
            
           break;                              // exit from cycle
           }
         if (Fun_Error(GetLastError())==1)      // "Fun" is for Function. Errors search.
            continue;                           // Retrying
         return;                                // exit from start()
        }

      break;                                    // 
     }
    
 
 
 
 
 
 
 
 
 
 
 
//-----------------------------Order Price---------------------------------- 9 --   // Maybe, switching it off?
   
RefreshRates();                                 // Updating...
 
    int time = 0;double profit = 0;             //All the necessary bools and doubles for order characteristics input

for(int t = OrdersHistoryTotal();t>=0;t--)      //Exhaustive search among closed orders.
{
  if(OrderSelect(t,SELECT_BY_POS,MODE_HISTORY)) // Searching. . .
  {
    if(OrderSymbol() == Symbol())               // Our pair. . .
    {
      if(time<OrderCloseTime())                 // Comparation with our one.
       
      {
        time=OrderCloseTime();                  // remembering the order time... just for case...
        profit=OrderProfit();                   // and also the profit...                         
        lot   =OrderLots();                     // Lots, o' course!
        
  
      }
    }
  }
}











//-------------------------Money Management Block --------------------




//-----------------

if (Opn_B==true||Opn_S==true)
{
if (StakeMode==1&&OrdersTotal()<1)Lts=Lts1;
if (StakeMode==3&&OrdersTotal()<1)Lts=NormalizeDouble(AccountEquity()*Percents/100/1000, 2);
   {
if(profit == 0 && StakeMode==2 && OrdersTotal()<1)  {Lts=Lts1;}     //if there was no trades before       
if(profit >= 0 && StakeMode==2 && OrdersTotal()<1)  {Lts=Lts1;}     //if last order was profitful. Maybe, you will want to raise the stake
if(profit <  0 && StakeMode==2 && OrdersTotal()<1)  {Lts=lot*IK;}   //if last order was a fail. IK may also make next deal smaller.
   }
}





    
         if (Lts*One_Lot > Free)                   
         {     
          Alert(" Not enough money for ", Lts," lots. Quit.");      
          return;                                   // exit from start()     
         }
   
//------------------------------------------------------------------------------ 








// Заметка - "Стратегия Белая Лестница" не требует особых условий закрытия и т. д. Это значит, что можно начать с неё.











//------------------------------Opening an order--------------------------------- 10 --         

   while(true)                                  // Cycle
   
     {
      if (Total==0 && Opn_B==true && Cls_B==false)              // if there is no any orders (what if there is any?)
        {                                       // Buy-for criteria
         RefreshRates();                        // Refresh je!
         SL=Bid - New_Stop(StopLoss)*Point;     // SL calculation
         TP=Bid + New_Stop(TakeProfit)*Point;   // TP
         Alert("Buying in process. Wait for answer.");
         Ticket=OrderSend(Symb,OP_BUY,Lts,Ask,Slippage,SL,TP,NULL,ID_of_EA,0,RoyalBlue);//Открытие Buy
         if (Ticket > 0)                        // Success :)
           {
            Alert ("Buy Order Opened",Ticket);
            return;                             // exit from start()
           }
         if (Fun_Error(GetLastError())==1)      // Errors handling
            continue;                           // Re-attempt
         return;                                // exit from start()
        }
      if (Total==0 && Opn_S==true && Cls_S==false)              // this is for one order per one pair.
        {                                       // Opening a Sell
         RefreshRates();                        // Update
         SL=Ask + New_Stop(StopLoss)*Point;     // Calculating SL 
         TP=Ask - New_Stop(TakeProfit)*Point;   // Calculating TP 
         Alert("Selling in process. Wait for answer.");
         Ticket=OrderSend(Symb,OP_SELL,Lts,Bid,Slippage,SL,TP,NULL,ID_of_EA,0,RoyalBlue);//Открытие Sell///////\\//\\//////
         if (Ticket > 0)                        // Success :)
           {
            Alert ("Sell Order Opened",Ticket);
            return;                             // Exit from start()
          }
         if (Fun_Error(GetLastError())==1)      // Errors handling
            continue;                           // Re-attempt
         return;                                // exit from start()
        }
      break;                                    // exit from while
     }
   return;                                      // exit from start()
  }
  













//--------------------------Функцияия обработки ошибок------------------------------------ 11 --
int Fun_Error(int Error)                      
  {
   switch(Error)
     {                                          // defeatable errors            
      case  4: Alert("Trade Server is overcrowded. Re-attempt.");
         Sleep(3000);                           // simplest solution
         return(1);                             // exit from function
      case 130:Alert("Wrong stops.");
         while(RefreshRates()==false)           // till new tick
            Sleep(1);                           // delay in a cycle
         return(1);                             // exit from...
      case 135:Alert("Price have changed. Re-attempt.");
         RefreshRates();                        // update
         return(1);                             // exit from function (from error!)
      case 136:Alert("No prices. Waiting for a new tick.");
         while(RefreshRates()==false)           // till new tick
            Sleep(1);                           // delay in a cycle
         return(1);                             // exit from...
      case 137:Alert("Brocker is busy. Re-attempt.");
         Sleep(3000);                           // Simplest solution.
         return(1);                             // exit from function (from error)
      case 146:Alert("Trading system is busy. Re-attempt");
         Sleep(500);                            // Простое решение
         return(1);                             // exit from function (from error)
         // Критические ошибки
      case  2: Alert("General error");
         return(1);                             // exit from function (from error)
      case  5: Alert("Old version of terminal");
         Work=false;                            // Screw oldies! Exit!
         return(1);                             // exit from function (from error)
      case 64: Alert("Account is a blocked one.");
         Work=false;                            // What? Exit!
         return(0);                             // exit
      case 133:Alert("Dealing is closed");
         return(0);                             // exit
      case 134:Alert("Not enough of money.");
         return(0);                             // exit
      default: Alert("Unsampled Error, exiting...",Error);  // if there is any different sort of error
         return(0);                             // we're out... untill the error is solved manually...
     }
  }
//-------------------------------------------------------------- 12 --

int New_Stop(int Parametr)                      // Stop-order check.
  {
   int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);// Minimal distance.
   if (Parametr<Min_Dist)                       // If less, than min...
     {
      Parametr=Min_Dist;                        // Уset the possible min' automatically.
      Alert("Увеличена дистанция стоп-приказа.");
     }
   return(Parametr);                            // Returning the paramether.
  }


