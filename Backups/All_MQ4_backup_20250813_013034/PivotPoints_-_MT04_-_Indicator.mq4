//+------------------------------------------------------------------+
//|                                                          PV4.mq4 |
//|                                                        Jim Arner |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

//---- indicators

   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   double yesterday_high;
   double yesterday_low;
   double yesterday_close;
   double array_price[][6];
   double P,S0.5,R0.5,S1,R1,S1.5,R1.5,S2,R2,S2.5,R2.5,S3,R3;

//---- TODO: add your code here

ArrayInitialize(array_price,0);
ArrayCopyRates(array_price,(Symbol()), PERIOD_D1);

yesterday_high = array_price[1][3];
yesterday_low = array_price[1][2];
yesterday_close = array_price[1][4];

P = ((yesterday_high + yesterday_low + yesterday_close)/3);

R1 = (2*P)-yesterday_low;
S1 = (2*P)-yesterday_high;

R0.5 = (P+R1)/2;
S0.5 = (P+S1)/2;

R2 = P+(R1-S1);
S2 = P-(R1-S1);

R1.5 = (R1+R2)/2;
S1.5 = (S1+S2)/2;

R3 = (yesterday_high + (2*(P-yesterday_low)));
S3 = (yesterday_low - (2*(yesterday_high-P)));

Comment("PV3_10","\nR3=",R3,"\nR2=",R2,"\nR1.5=",R1.5,"\nR1=",R1,"\nR0.5=",R0.5,"\nP=",P,"\nS0.5=",S0.5,"\nS1=",S1,"\nS1.5=",S1.5,"\nS2=",S2,"\nS3=",S3);

ObjectDelete("P_Line");
ObjectDelete("S1_Line");
ObjectDelete("R1_Line");

ObjectDelete("S2_Line");
ObjectDelete("R2_Line");

ObjectDelete("S3_Line");
ObjectDelete("R3_Line");

ObjectDelete("S0.5_Line");
ObjectDelete("R0.5_Line");

ObjectDelete("S1.5_Line");
ObjectDelete("R1.5_Line");


ObjectCreate("P_Line", OBJ_HLINE,0, CurTime(),P);
ObjectSet("P_Line",OBJPROP_COLOR,Magenta);
ObjectSet("P_Line",OBJPROP_STYLE,STYLE_DASH);

ObjectCreate("S1_Line", OBJ_HLINE,0, CurTime(),S1);
ObjectSet("S1_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S1_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("R1_Line", OBJ_HLINE,0, CurTime(),R1);
ObjectSet("R1_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R1_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("S2_Line", OBJ_HLINE,0, CurTime(),S2);
ObjectSet("S2_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S2_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("R2_Line", OBJ_HLINE,0, CurTime(),R2);
ObjectSet("R2_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R2_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("S3_Line", OBJ_HLINE,0, CurTime(),S3);
ObjectSet("S3_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S3_Line",OBJPROP_STYLE,STYLE_SOLID);
ObjectSet("S3_Line",OBJPROP_WIDTH,3);

ObjectCreate("R3_Line", OBJ_HLINE,0, CurTime(),R3);
ObjectSet("R3_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R3_Line",OBJPROP_STYLE,STYLE_SOLID);
ObjectSet("R3_Line",OBJPROP_WIDTH,3);

ObjectCreate("S0.5_Line", OBJ_HLINE,0, CurTime(),S0.5);
ObjectSet("S0.5_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S0.5_Line",OBJPROP_STYLE,STYLE_DOT);

ObjectCreate("R0.5_Line", OBJ_HLINE,0, CurTime(),R0.5);
ObjectSet("R0.5_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R0.5_Line",OBJPROP_STYLE,STYLE_DOT);

ObjectCreate("S1.5_Line", OBJ_HLINE,0, CurTime(),S1.5);
ObjectSet("S1.5_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S1.5_Line",OBJPROP_STYLE,STYLE_DOT);

ObjectCreate("R1.5_Line", OBJ_HLINE,0, CurTime(),R1.5);
ObjectSet("R1.5_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R1.5_Line",OBJPROP_STYLE,STYLE_DOT);

ObjectsRedraw();

   return(0);
  }
//+------------------------------------------------------------------+