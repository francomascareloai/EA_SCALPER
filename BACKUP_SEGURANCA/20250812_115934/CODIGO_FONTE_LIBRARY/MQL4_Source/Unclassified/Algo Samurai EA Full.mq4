#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"

  enum Option1      {Expert = 10,Moderate = 20,Safe = 30  };


//------------------
extern string Configuration="==== Setting ===="  ;  
extern int   magicnumber=777  ;  // can change any number 
extern bool AutoLot=true  ;   
extern  Option1  AutoLotMode=30  ;   
extern double FixLot=0.1  ;   
extern string OrderSetting="=== Leave as Default ===="  ;  
extern int   stoploss=150  ;   
extern int   takeprofit=1250  ;   
extern int   step=90  ;   
extern string Config="==== Time Filter ===="  ;  // change time for your need
extern int   StartHour=4  ;   
extern int   StopHour=22  ;   
  double    zong_1_do = 0.3;
  double    zong_2_do = AutoLotMode * 100;
  int       zong_3_in = 250;
  int       zong_4_in = 200;
  int       zong_5_in = 100;
  int       zong_6_in = 50;
  int       zong_7_in = 100;
  int       zong_8_in = 50;
  int       zong_9_in = 800;
  int       zong_10_in = 100;
  int       zong_11_in = 50;
  int       xt = 0;
  double    zong_18_do = 0.0;
  int       zong_19_in = 0;
  int       zong_20_in = 10;
  int       zong_21_in = 0;
  int       zong_22_in = 0;
  int       zong_23_in = 5;
  int       zong_24_in = 30;
  double    zong_25_do = 0.0;
  double    zong_26_do = 0.0;
  int       LotDigits = 0;
  double    lots = 0.0;


 int init()
 {

  double    Local_2_do;
  double    Local_3_do;
//----- -----
 double     tmp_do_1;
 double     tmp_do_2;

 if ( ( Digits() == 3 || Digits() == 5 ) )
 {
   xt = 10 ;
 }
 else
 {
   xt = 1 ;
 }
 zong_18_do = MarketInfo(Symbol(),14) ;
 tmp_do_1 = zong_18_do / xt;
 if ( stoploss <= tmp_do_1 )
 {
   tmp_do_1 = tmp_do_1;
 }
 else
 {
   tmp_do_1 = stoploss;
 }
 stoploss = tmp_do_1 ;
 if ( takeprofit <= zong_18_do / xt )
 {
   tmp_do_2 = zong_18_do / xt;
 }
 else
 {
   tmp_do_2 = takeprofit;
 }
 takeprofit = tmp_do_2 ;
 Local_2_do = MarketInfo(Symbol(),10) ;
 Local_3_do = MarketInfo(Symbol(),9) ;
 zong_26_do = MarketInfo(Symbol(),24) ;
 if ( zong_26_do==1.0 )
 {
   LotDigits = 0 ;
 }
 if ( zong_26_do==0.1 )
 {
   LotDigits = 1 ;
 }
 if ( zong_26_do==0.01 )
 {
   LotDigits = 2 ;
 }
 if ( zong_26_do==0.001 )
 {
   LotDigits = 3 ;
 }
 if ( zong_26_do==0.0001 )
 {
   LotDigits = 4 ;
 }
 if ( zong_26_do==0.00001 )
 {
   LotDigits = 5 ;
 }
 zong_25_do = (Local_2_do - Local_3_do) / Point() / xt ;
 return(0); 
 }
//init <<==--------   --------
 int start()
 {
  int       Local_2_in;
  double    Local_3_do;
  double    Local_4_do;
  double    Local_5_do;
  double    Local_6_do;
  int       Local_7_in;
  int       Local_8_in;
  double    Local_9_do;
  int       Local_10_in;
  double    Local_11_do;
  int       Local_12_in;
  double    Local_13_do;
  double    Local_14_do;
  int       Local_15_in;
  int       Local_16_in;
  //int       Local_17_in;
  int       i;
//----- -----
 Display_Info(); 
 Local_2_in = 0 ;
 Local_3_do = 0.0 ;
 Local_4_do = 0.0 ;
 Local_5_do = 0.0 ;
 Local_6_do = 0.0 ;
 Local_7_in = 0 ;
 Local_8_in = 0 ;
 Local_9_do = 0.0 ;
 Local_10_in = 0 ;
 Local_11_do = 0.0 ;
 Local_12_in = 0 ;
 Local_13_do = 0.0 ;
 Local_14_do = 0.0 ;
 Local_15_in = 0 ;
 Local_16_in = 0 ;
 
 lots = NormalizeDouble(LotsOptimized ( ),LotDigits) ;
 zong_19_in = MarketInfo(Symbol(),14) ;
 for (i = 0 ; i < OrdersTotal() ; i = i + 1)
 {
   if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || magicnumber != OrderMagicNumber() )   continue;
   Local_2_in = OrderType() ;
   Local_3_do = NormalizeDouble(OrderStopLoss(),Digits()) ;
   Local_4_do = NormalizeDouble(OrderOpenPrice(),Digits()) ;
   Local_5_do = Local_3_do ;
   if ( Local_2_in == 0 )
   {
     Local_7_in = Local_7_in + 1;
     if ( Local_3_do<Local_4_do )
     {
       Local_15_in = zong_4_in ;
       Local_16_in = zong_3_in ;
     }
     else
     {
       if ( Local_3_do - Local_4_do<=NormalizeDouble(zong_4_in * Point(),Digits()) )
       {
         Local_15_in = zong_6_in ;
         Local_16_in = zong_5_in ;
       }
       else
       {
         if ( Local_3_do - Local_4_do<=NormalizeDouble(zong_9_in * Point(),Digits()) )
         {
           Local_15_in = zong_8_in ;
           Local_16_in = zong_7_in ;
         }
         else
         {
           Local_15_in = zong_11_in ;
           Local_16_in = zong_10_in ;
         }
       }
     }
     Local_13_do = NormalizeDouble(Local_15_in * Point() + Local_3_do,Digits()) ;
     Local_14_do = NormalizeDouble(Bid - Local_16_in * Point(),Digits()) ;
     if ( Local_14_do>Local_3_do && Local_13_do<=NormalizeDouble(Bid - zong_19_in * Point(),Digits()) )
     {
       Local_5_do = Local_13_do ;
     }
     if ( Local_5_do>Local_3_do )
     {
       if ( !(OrderModify(OrderTicket(),Local_4_do,Local_5_do,0.0,0,White)) )
       {
         Print("Error ",GetLastError(),"   Order Modify Buy   SL ",Local_3_do,"->",Local_5_do); 
       }
       else
       {
         Print("Order Buy Modify   SL ",Local_3_do,"->",Local_5_do); 
       }
     }
   }
   if ( Local_2_in == 1 )
   {
     Local_8_in = Local_8_in + 1;
     if ( Local_3_do>Local_4_do )
     {
       Local_15_in = zong_4_in ;
       Local_16_in = zong_3_in ;
     }
     else
     {
       if ( Local_3_do - Local_4_do>=NormalizeDouble(zong_4_in * Point(),Digits()) )
       {
         Local_15_in = zong_6_in ;
         Local_16_in = zong_5_in ;
       }
       else
       {
         if ( Local_3_do - Local_4_do>=NormalizeDouble(zong_9_in * Point(),Digits()) )
         {
           Local_15_in = zong_8_in ;
           Local_16_in = zong_7_in ;
         }
         else
         {
           Local_15_in = zong_11_in ;
           Local_16_in = zong_10_in ;
         }
       }
     }
     Local_13_do = NormalizeDouble(Local_3_do - Local_15_in * Point(),Digits()) ;
     Local_14_do = NormalizeDouble(Local_16_in * Point() + Ask,Digits()) ;
     if ( Local_14_do<Local_3_do && Local_13_do>=NormalizeDouble(zong_19_in * Point() + Ask,Digits()) )
     {
       Local_5_do = Local_13_do ;
     }
     if ( Local_5_do<Local_3_do )
     {
       if ( !(OrderModify(OrderTicket(),Local_4_do,Local_5_do,0.0,0,White)) )
       {
         Print("Error ",GetLastError(),"   Order Modify Buy   SL ",Local_3_do,"->",Local_5_do); 
       }
       else
       {
         Print("Order Buy Modify   SL ",Local_3_do,"->",Local_5_do); 
       }
     }
   }
   if ( Local_2_in == 4 )
   {
     Local_9_do = Local_4_do ;
     Local_10_in = OrderTicket() ;
     if ( !(dTime ( )) )
     {
       if ( !(OrderDelete(Local_10_in,0xFFFFFFFF)) )
       {
         Print("Error ",GetLastError(),"   Order Delete "); 
       }
       else
       {
         Print("Order Delete "); 
       }
     }
   }
   if ( Local_2_in != 5 )   continue;
   Local_11_do = Local_4_do ;
   Local_12_in = OrderTicket() ;
   if ( dTime ( ) )   continue;
   
   if ( !(OrderDelete(Local_12_in,0xFFFFFFFF)) )
   {
     Print("Error ",GetLastError(),"   Order Delete "); 
      continue;
   }
   Print("Order Delete "); 
   
 }
 if ( Local_7_in + Local_10_in == 0 && dTime ( ) )
 {
   if ( stoploss - step >= zong_19_in && stoploss != 0 )
   {
     Local_5_do = NormalizeDouble(Ask - (stoploss - step) * Point(),Digits()) ;
   }
   else
   {
     Local_5_do = 0.0 ;
   }
   if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
   {
     Local_6_do = NormalizeDouble((takeprofit + step) * Point() + Ask,Digits()) ;
   }
   else
   {
     Local_6_do = 0.0 ;
   }
   if ( OrderSend(Symbol(),OP_BUYSTOP,lots,NormalizeDouble(step * Point() + Ask,Digits()),zong_20_in,Local_5_do,Local_6_do,"ex4tomq4decompiler.com_AlgoSamurai",magicnumber,0,0xFFFFFFFF) != -1 )
   {
     zong_21_in = TimeCurrent() ;
   }
 }
 if ( Local_8_in + Local_12_in == 0 && dTime ( ) )
 {
   if ( stoploss - step >= zong_19_in && stoploss != 0 )
   {
     Local_5_do = NormalizeDouble((stoploss - step) * Point() + Bid,Digits()) ;
   }
   else
   {
     Local_5_do = 0.0 ;
   }
   if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
   {
     Local_6_do = NormalizeDouble(Bid - (takeprofit + step) * Point(),Digits()) ;
   }
   else
   {
     Local_6_do = 0.0 ;
   }
   if ( OrderSend(Symbol(),OP_SELLSTOP,lots,NormalizeDouble(Bid - step * Point(),Digits()),zong_20_in,Local_5_do,Local_6_do,"ex4tomq4decompiler.com_AlgoSamurai",magicnumber,0,0xFFFFFFFF) != -1 )
   {
     zong_22_in = TimeCurrent() ;
   }
 }
 if ( Local_10_in != 0 && dTime ( ) && zong_21_in <  TimeCurrent() - zong_23_in && (MathAbs(NormalizeDouble(step * Point() + Ask,Digits()) - Local_9_do)) / Point()>zong_24_in )
 {
   if ( stoploss - step >= zong_19_in && stoploss != 0 )
   {
     Local_5_do = NormalizeDouble(Ask - (stoploss - step) * Point(),Digits()) ;
   }
   else
   {
     Local_5_do = 0.0 ;
   }
   if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
   {
     Local_6_do = NormalizeDouble((takeprofit + step) * Point() + Ask,Digits()) ;
   }
   else
   {
     Local_6_do = 0.0 ;
   }
   if ( OrderModify(Local_10_in,NormalizeDouble(step * Point() + Ask,Digits()),Local_5_do,Local_6_do,0,0xFFFFFFFF) )
   {
     zong_21_in = TimeCurrent() ;
   }
 }
 if ( Local_12_in != 0 && dTime ( ) && zong_22_in <  TimeCurrent() - zong_23_in && (MathAbs(NormalizeDouble(Bid - step * Point(),Digits()) - Local_11_do)) / Point()>zong_24_in )
 {
   if ( stoploss - step >= zong_19_in && stoploss != 0 )
   {
     Local_5_do = NormalizeDouble((stoploss - step) * Point() + Bid,Digits()) ;
   }
   else
   {
     Local_5_do = 0.0 ;
   }
   if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
   {
     Local_6_do = NormalizeDouble(Bid - (takeprofit + step) * Point(),Digits()) ;
   }
   else
   {
     Local_6_do = 0.0 ;
   }
   if ( OrderModify(Local_12_in,NormalizeDouble(Bid - step * Point(),Digits()),Local_5_do,Local_6_do,0,0xFFFFFFFF) )
   {
     zong_22_in = TimeCurrent() ;
   }
 }
 return(0); 
 }
//start <<==--------   --------
 int deinit()
 {
 ObjectsDeleteAll(-1,-1); 
 return(0); 
 }
//deinit <<==--------   --------
 void Display_Info()
 {
  int       Local_1_in;
  string    Local_2_st;
  int       Local_3_in;
//----- -----

 if ( Seconds() >= 0 && Seconds() <  10 )
 {
   Local_1_in = 8388608 ;
 }
 if ( Seconds() >= 10 && Seconds() <  20 )
 {
   Local_1_in = 0 ;
 }
 if ( Seconds() >= 20 && Seconds() <  30 )
 {
   Local_1_in = 2139610 ;
 }
 if ( Seconds() >= 30 && Seconds() <  40 )
 {
   Local_1_in = 25600 ;
 }
 if ( Seconds() >= 40 && Seconds() <  50 )
 {
   Local_1_in = 2970272 ;
 }
 if ( Seconds() >= 50 && Seconds() <= 59 )
 {
   Local_1_in = 8519755 ;
 }
 Local_2_st = "-------------------------------------------" ;
 Local_3_in = 0 ;
 if ( Seconds() >= 0 && Seconds() <  10 )
 {
   Local_3_in = 8519755 ;
 }
 if ( Seconds() >= 10 && Seconds() <  20 )
 {
   Local_3_in = 16119285 ;
 }
 if ( Seconds() >= 20 && Seconds() <  30 )
 {
   Local_3_in = 25600 ;
 }
 if ( Seconds() >= 30 && Seconds() <  40 )
 {
   Local_3_in = 2970272 ;
 }
 if ( Seconds() >= 40 && Seconds() <  50 )
 {
   Local_3_in = 2139610 ;
 }
 if ( Seconds() >= 50 && Seconds() <= 59 )
 {
   Local_3_in = 8388608 ;
 }
 LABEL ( "L01","Webdings",64,2,40,Gold,0,"gg"); 
 LABEL ( "L02","Webdings",63,2,41,0,0,"gg"); 
 LABEL ( "L03","Webdings",21,2,40,WhiteSmoke,0,"gggggg"); 
 LABEL ( "L04","Tahoma",15,23,41,MintCream,0,"ALGO SAMURAI"); 
 LABEL ( "L05","Tahoma",15,22,40,Local_1_in,0,"ALGO SAMURAI"); 
 LABEL ( "L06","Arial",10,10,75,WhiteSmoke,0,"Name :: " + AccountName()); 
 LABEL ( "L09","Arial",10,10,90,WhiteSmoke,0,"Broker :: " + ServerAddress()); 
 LABEL ( "L10","Arial",10,10,105,Local_1_in,0,"ex4tomq4decompiler.com"); 
 LABEL ( "L11","Arial",10,11,106,LightGray,0,"ex4tomq4decompiler.com"); 
 LABEL ( "L13","Arial",10,21,9,0,3,"Copyright  ex4tomq4decompiler.com"); 
 LABEL ( "L14","Arial",10,20,8,MintCream,3,"Copyright  ex4tomq4decompiler.com"); 
 LABEL ( "L15","Tahoma",15,21,26,Gold,3,"ALGO SAMURAI"); 
 LABEL ( "L16","Tahoma",15,20,25,Local_3_in,3,"ALGO SAMURAI"); 
 }
//Display_Info <<==--------   --------
 void LABEL( string Para_0_st,string Para_1_st,int Para_2_in,int Para_3_in,int Para_4_in,color Para_5_co,int Para_6_in,string Para_7_st)
 {
 if ( ObjectFind(Para_0_st) <  0 )
 {
   ObjectCreate(Para_0_st,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
 }
 ObjectSetText(Para_0_st,Para_7_st,Para_2_in,Para_1_st,Para_5_co); 
 ObjectSet(Para_0_st,OBJPROP_CORNER,Para_6_in); 
 ObjectSet(Para_0_st,OBJPROP_XDISTANCE,Para_3_in); 
 ObjectSet(Para_0_st,OBJPROP_YDISTANCE,Para_4_in); 
 }
//LABEL <<==--------   --------
 bool dTime()
 {
  bool      ans;
//----- -----

 if ( TimeHour(TimeCurrent()) >= StartHour && TimeHour(TimeCurrent()) <  StopHour )
 {
   ans = true ;
 }
 return(ans); 
 }
//dTime <<==--------   --------
 double LotsOptimized()
 {
  double    Local_2_do;
  double    Local_3_do;
  double    Local_4_do;
  double    Local_5_do;
  double    Local_6_do;
//----- -----

 Local_2_do = FixLot ;
 Local_3_do = 0.0 ;
 Local_4_do = MarketInfo(Symbol(),23) ;
 Local_5_do = MarketInfo(Symbol(),24) ;
 if ( AutoLot )
 {
   Local_6_do = AccountBalance() ;
   Local_3_do = Local_6_do / zong_2_do * zong_1_do ;
   Local_2_do = Local_3_do ;
   if ( Local_3_do<Local_4_do )
   {
     Local_2_do = Local_4_do ;
   }
 }
 return(Local_2_do); 
 }
//<<==LotsOptimized <<==
