//+------------------------------------------------------------------+
//|                                                                  |
//|                                              USD AGAINST ALL.mg4 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Серов Евгений"
#property link      "vorese@yandex.ru"
#property indicator_chart_window
extern int X_DISTANCE=0; // располож. по горизонтали
extern int Y_DISTANCE=0; // располож. по вертикали
extern color tab_color=Lime; // цвет рамки 
extern int text_color=16; // 0-20 оттенок текста
extern string note="Period_(0,M1,M5,M15,M30,H1,H4,D1,W1,MN)";
extern string Period_="0";//M1,M5,M15,M30,H1,H4,D1,W1,MN . Если 0- период текущего графика.
//----используемые вал.пары -------------------------------------------  
string currency_pair[7]= {"USDJPY","USDCHF","USDCAD","NZDUSD","AUDUSD","GBPUSD","EURUSD"};
int line_x[4]={17,32,45,153,170};// координаты горизонт.линий
//=====================================================================
int init()
  {  
   // создать горизонт. линии
  for(int x=0;x<5;x++)  {
   ObjectCreate("line-x"+x, OBJ_LABEL, 0, 0, 0);
   ObjectSet("line-x"+x, OBJPROP_CORNER, 3);
   ObjectSet("line-x"+x, OBJPROP_XDISTANCE,X_DISTANCE+14);
   ObjectSet("line-x"+x, OBJPROP_YDISTANCE, Y_DISTANCE+line_x[x]);
   ObjectSetText("line-x"+x,"________________________________",7,"Verdana",tab_color); 
                     }
 //-------------------------------------------------------------------
   // создать вертикал. линии
   int c,y,r;
      for(c=0;c<2;c++) {
        if(c==1)r=196;
      for( y=0;y<7;y++)  {
   ObjectCreate(y+"line-y"+c, OBJ_LABEL, 0, 0, 0);
   ObjectSet(y+"line-y"+c, OBJPROP_CORNER, 3);
   ObjectSet(y+"line-y"+c, OBJPROP_XDISTANCE,X_DISTANCE+7+r);
   ObjectSet(y+"line-y"+c, OBJPROP_YDISTANCE, Y_DISTANCE+16+y*22);
   ObjectSetText(y+"line-y"+c,"|",17,"Verdana",tab_color); }
                     } 
  //--------------------------------------------------------------------- 
  // текст                     
   ObjectCreate("text", OBJ_LABEL, 0, 0, 0);
   ObjectSet("text", OBJPROP_CORNER, 3);
   ObjectSet("text", OBJPROP_XDISTANCE,X_DISTANCE+42);
   ObjectSet("text", OBJPROP_YDISTANCE, Y_DISTANCE+156); 
   ObjectSetText("text","USD against all.   Period_"+Period_,7,"Verdana",f_Color(text_color,1));                                                          
   return(0);
  }
//====================================================================
int deinit()
  { 
    int n,m;
      for( n=0;n<7;n++)  // удалить все об'екты 
     {  
       ObjectDelete("perc"+n);
       ObjectDelete("curr"+n);
       if(n<5) ObjectDelete("line-x"+n);  
  //------       
      for( m=0;m<=20;m++)
     {
       ObjectDelete(m+"gist"+n);
       if(m<2) ObjectDelete(n+"line-y"+m);
                               } } 
       ObjectDelete("text");                        
   return(0);
  }
//====================================================================
int start()
  {
  int i,w,z;
  for( z=0;z<7;z++)  
    { 
      for( w=0;w<=20;w++) {
       ObjectDelete(w+"gist"+z); //удалить гистограмму перед обновлением
                              } 
  string minus=""; 
  double percent=0; 
  int flag=0;
  int count=0;           
//--------------------------------------------------------------------
     // обновить данные
   RefreshRates();
   double bid=MarketInfo(currency_pair[z], MODE_BID );
   double open=iOpen(currency_pair[z],f_Timeframe(Period_),0);
   double high=iHigh(currency_pair[z],f_Timeframe(Period_),0);
   double low=iLow(currency_pair[z],f_Timeframe(Period_),0);   
//--------------------------------------------------------------------  
    // расчет процентов
   if(bid>open && high!=open)   
       { percent=(bid-open)/(high-open)*100; // проц.растущего бара
         flag=1;
         count=NormalizeDouble(percent/5,0); }
       else {
         if(bid<open && low!=open)
       { percent=(open-bid)/(open-low)*100; // проц.падающего бара
         flag=(-1);  
         count=NormalizeDouble(percent/5,0); } }
//-------------------------------------------------------------------- 
         // при переключении ТФ//
    if(percent>100)percent=100;// 
    if(count>=20)count=20;   
         // ------------------//  
                                                 
    if(z<3) flag=flag*(-1);   // инверт. "USDJPY","USDCHF","USDCAD"
    if(flag==(-1)) minus="-"; 
//--------------------------------------------------------------------  
  // проценты     
   ObjectCreate("perc"+z, OBJ_LABEL, 0, 0, 0);
   ObjectSet("perc"+z, OBJPROP_CORNER, 3);
   ObjectSet("perc"+z, OBJPROP_XDISTANCE,X_DISTANCE+13+z*28);
   ObjectSet("perc"+z, OBJPROP_YDISTANCE, Y_DISTANCE+33);
   ObjectSetText("perc"+z,minus+DoubleToStr(percent,0),7,"Verdana",f_Color(text_color,flag));//16 
//-------------------------------------------------------------------- 
  // валюта   
   ObjectCreate("curr"+z, OBJ_LABEL, 0, 0, 0);
   ObjectSet("curr"+z, OBJPROP_CORNER, 3);
   ObjectSet("curr"+z, OBJPROP_XDISTANCE,X_DISTANCE+15+z*28);
   ObjectSet("curr"+z, OBJPROP_YDISTANCE, Y_DISTANCE+20);
   ObjectSetText("curr"+z,f_Currency(z),7,"Verdana",f_Color(text_color,flag));//16          
//--------------------------------------------------------------------- 
  // гистограмма 
     for( i=0;i<=count;i++) {  
   ObjectCreate(i+"gist"+z, OBJ_LABEL, 0, 0, 0);
   ObjectSet(i+"gist"+z, OBJPROP_CORNER, 3);
   ObjectSet(i+"gist"+z, OBJPROP_XDISTANCE,X_DISTANCE+8+z*28);
   ObjectSet(i+"gist"+z, OBJPROP_YDISTANCE, Y_DISTANCE+7+i*5);
   ObjectSetText(i+"gist"+z,"-",60,"Verdana",f_Color(i,flag));  
                       } }
//---------------------------------------------------------------------                     
   return(0);
  }
//=====================================================================

//========== валюта ===================================================
 string f_Currency(int curr_num)
 {
    string text;
    switch(curr_num)
     {  case 0: text="JPY";break;
        case 1: text="CHF";break;
        case 2: text="CAD";break;
        case 3: text="NZD";break;
        case 4: text="AUD";break; 
        case 5: text="GBP";break;
        case 6: text="EUR";break;  }
        return(text);   }               
//============ цвет ===================================================        
color f_Color (int num,int flag) 
{   color col_R,col_B,col;
  switch(num) 
  { case 0: col_B=C'0,0,255';col_R=C'255,0,0';break; 
    case 1: col_B=C'0,10,255';col_R=C'255,10,0';break; 
    case 2: col_B=C'0,30,255';col_R=C'255,30,0';break; 
    case 3: col_B=C'0,50,255';col_R=C'255,50,0';break; 
    case 4: col_B=C'0,80,255';col_R=C'255,80,0';break; 
    case 5: col_B=C'0,100,255';col_R=C'255,100,0';break; 
    case 6: col_B=C'0,120,255';col_R=C'255,120,0';break; 
    case 7: col_B=C'0,130,255';col_R=C'255,130,0';break; 
    case 8: col_B=C'0,140,255';col_R=C'255,140,0';break; 
    case 9: col_B=C'0,150,255';col_R=C'255,150,0';break; 
    case 10: col_B=C'0,160,255';col_R=C'255,160,0';break; 
    case 11: col_B=C'0,170,255';col_R=C'255,170,0';break; 
    case 12: col_B=C'0,180,255';col_R=C'255,180,0';break; 
    case 13: col_B=C'0,190,255';col_R=C'255,190,0';break; 
    case 14: col_B=C'0,200,255';col_R=C'255,200,0';break; 
    case 15: col_B=C'0,205,255';col_R=C'255,205,0';break; 
    case 16: col_B=C'0,210,255';col_R=C'255,210,0';break; 
    case 17: col_B=C'0,215,255';col_R=C'255,215,0';break; 
    case 18: col_B=C'0,220,255';col_R=C'255,220,0';break; 
    case 19: col_B=C'0,235,255';col_R=C'255,235,0';break; 
    case 20: col_B=C'0,235,255';col_R=C'255,235,0';break; 
   
    } 
    if(flag==1)col=col_B;
     else {
        if(flag==(-1)) col=col_R; 
     else {
        col=tab_color; }}   
  return(col); }  

//=========== период ==================================================
int f_Timeframe(string period)
  { 
    int TF;
      if(period=="M1")TF=1;
   else {
      if(period=="M5")TF=5;
   else {
     if(period=="M15")TF=15;
   else {
     if(period=="M30")TF=30;
   else {
     if(period=="H1")TF=60;
   else {
     if(period=="H4")TF=240;
   else {
     if(period=="D1")TF=1440;
   else {
     if(period=="W1")TF=10080;
   else {
     if(period=="MN")TF=43200;
   else {
     if(period=="0")TF=0;
   else {  Alert("Ошибка установки периода:  "+period);
                     }}}}}}}}}}
             return(TF);   }
//========================================================================