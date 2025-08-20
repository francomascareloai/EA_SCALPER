//+------------------------------------------------------------------+
//|                                              FiboPivotandRSI.mq4 |
//|                                         Copyright © 2005 H.Bartz |
//|                                                hollib@freenet.de |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005 H.Bartz"
#property link      "hollib@freenet.de"

extern double StopLoss = 20; 
extern double TakeProfit = 21;
extern double TrailingStop = 20;
extern double Lots = 0.10;
extern double ProfitShield = 7;
extern int TimeZone=0;
extern color clOpenBuy = Blue;
extern color clCloseBuy = Aqua;
extern color clOpenSell = Red;
extern color clCloseSell = Violet;
extern color clModiBuy = Blue;
extern color clModiSell = Red;
extern string Name_Expert = "FiboPivotandRSI";
extern int Slippage = 4;
extern bool UseSound = False;
extern string NameFileSound = "alert.wav";
int prevCountBars;

double diRSI0, diRSI6, d1, d7 ;
double R1=0, R2=0, R3=0, F24=0, F38=0, F62=0, F76=0, S1=0, S2=0, S3=0,DH=0,DL=0;
double day_high=0, day_low=0, yesterday_high=0, yesterday_open=0, yesterday_low=0, yesterday_close=0, today_open=0, today_high=0, today_low=0, P=0, Q=0, nQ=0, nD=0, D=0, rates_h1[2][6], rates_d1[2][6],Bound[13];
double Buy_TP=0, Sell_TP=0, Sup=0, Res=0, ticket, SL,Tradingpoint;
int cnt,dif1,dif2,HL;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

int init() 
{
 return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+

int deinit() 
{
 return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

/// Initial Data Checks

int start()
{   
   if(Bars<150)
     {
     Print("bars less than 100");
     }
   
// Delete Old Pivot Lines to Draw the New Lines

   ObjectDelete("R1 Label"); 
   ObjectDelete("R1 Line");
   
   ObjectDelete("R2 Label");
   ObjectDelete("R2 Line");
   
   ObjectDelete("R3 Label");
   ObjectDelete("R3 Line");
   
   ObjectDelete("S1 Label");
   ObjectDelete("S1 Line");
   
   ObjectDelete("S2 Label");
   ObjectDelete("S2 Line");
   
   ObjectDelete("S3 Label");
   ObjectDelete("S3 Line");
   
   ObjectDelete("P Label");
   ObjectDelete("P Line");
   
   ObjectDelete("F24 Label");
   ObjectDelete("F24 Line");
   
   ObjectDelete("F38 Label");
   ObjectDelete("F38 Line");
   
   ObjectDelete("F62 Label");
   ObjectDelete("F62 Line");
   
   ObjectDelete("F76 Label");
   ObjectDelete("F76 Line");
   
   ObjectDelete("DH Label");
   ObjectDelete("DH Line");
   
   ObjectDelete("DL Label");
   ObjectDelete("DL Line");

/// PIVOT POINT CALCULATIONS

  int i=0, j=0;

  if(Period() > 1440)
   {
    Comment("Error - Chart period is greater than 1 day.");
    return(-1);
   }
  
  ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);
  yesterday_high = rates_d1[1][3];
  yesterday_low = rates_d1[1][2]; 
  day_high = rates_d1[0][3];
  day_low = rates_d1[0][2];

  ArrayCopyRates(rates_h1, Symbol(), PERIOD_H1);
  for (i=0;i<=25;i++)
  {
   if (TimeMinute(rates_h1[i][0])==0 && (TimeHour(rates_h1[i][0])-TimeZone)==0)
    {
     yesterday_close = rates_h1[i+1][4];      
     yesterday_open = rates_h1[i+24][1];
     today_open = rates_h1[i][1];      
     break;
    }
  }   

 // Calculate Pivots
   
   D = (day_high - day_low);
   Q = (yesterday_high - yesterday_low);
   
   P = (yesterday_high + yesterday_low + yesterday_close) / 3;
   
   R1 = (2*P)-yesterday_low;
   S1 = (2*P)-yesterday_high;
   
   R2 = P+(yesterday_high - yesterday_low);
   S2 = P-(yesterday_high - yesterday_low);
   
   R3 = (2*P)+(yesterday_high-(2*yesterday_low));
   S3 = (2*P)-((2* yesterday_high)-yesterday_low);   
	
	F24 = day_low-((day_low-day_high)*0.24);
   F38 = day_low-((day_low-day_high)*0.38);
   F62 = day_low-((day_low-day_high)*0.62);
   F76 = day_low-((day_low-day_high)*0.76);
   
   DH = yesterday_high;
   DL = yesterday_low;
   

// Pivot Lines Labeling

     if(ObjectFind("R1 label") != 0)
      {
       ObjectCreate("R1 label", OBJ_TEXT, 0, Time[20], R1);
       ObjectSetText("R1 label", " R1", 8, "Arial", Yellow);
      }
     else
      {
       ObjectMove("R1 label", 0, Time[20], R1);
      }

      if(ObjectFind("R2 label") != 0)
       {
        ObjectCreate("R2 label", OBJ_TEXT, 0, Time[20], R2);
        ObjectSetText("R2 label", " R2", 8, "Arial", Orange);
       }
      else
       {
        ObjectMove("R2 label", 0, Time[20], R2);
       }

      if(ObjectFind("R3 label") != 0)
       {
        ObjectCreate("R3 label", OBJ_TEXT, 0, Time[20], R3);
        ObjectSetText("R3 label", " R3", 8, "Arial", Red);
       }
        else
       {
        ObjectMove("R3 label", 0, Time[20], R3);
       }

      if(ObjectFind("P label") != 0)
       {
        ObjectCreate("P label", OBJ_TEXT, 0, Time[20], P);
        ObjectSetText("P label", "Pivot", 8, "Arial", DeepPink);
       }
      else
       {
        ObjectMove("P label", 0, Time[20], P);
       }

      if(ObjectFind("S1 label") != 0)
       {
        ObjectCreate("S1 label", OBJ_TEXT, 0, Time[20], S1);
        ObjectSetText("S1 label", "S1", 8, "Arial", Yellow);
       }
      else
       {
        ObjectMove("S1 label", 0, Time[20], S1);
       }

      if(ObjectFind("S2 label") != 0)
       {
        ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], S2);
        ObjectSetText("S2 label", "S2", 8, "Arial", Orange);
       }
      else
       {
        ObjectMove("S2 label", 0, Time[20], S2);
       }

      if(ObjectFind("S3 label") != 0)
       {
        ObjectCreate("S3 label", OBJ_TEXT, 0, Time[20], S3);
        ObjectSetText("S3 label", "S3", 8, "Arial", Red);
       }
      else
       {
        ObjectMove("S3 label", 0, Time[20], S3);
       }

// Drawing Pivot lines
      
      if(ObjectFind("S1 line") != 0)
       {
        ObjectCreate("S1 line", OBJ_HLINE, 0, Time[40], S1);
        ObjectSet("S1 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("S1 line", OBJPROP_COLOR, Yellow);
       }
      else
       {
        ObjectMove("S1 line", 0, Time[40], S1);
       }

      if(ObjectFind("S2 line") != 0)
       {
        ObjectCreate("S2 line", OBJ_HLINE, 0, Time[40], S2);
        ObjectSet("S2 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("S2 line", OBJPROP_COLOR, Orange);
       }
      else
       {
        ObjectMove("S2 line", 0, Time[40], S2);
       }

      if(ObjectFind("S3 line") != 0)
       {
        ObjectCreate("S3 line", OBJ_HLINE, 0, Time[40], S3);
        ObjectSet("S3 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("S3 line", OBJPROP_COLOR, Red);
       }
      else
       {
        ObjectMove("S3 line", 0, Time[40], S3);
       }

      if(ObjectFind("P line") != 0)
       {
        ObjectCreate("P line", OBJ_HLINE, 0, Time[40], P);
        ObjectSet("P line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("P line", OBJPROP_COLOR, DeepPink);
       }
      else
       {
        ObjectMove("P line", 0, Time[40], P);
       }

      if(ObjectFind("R1 line") != 0)
       {
        ObjectCreate("R1 line", OBJ_HLINE, 0, Time[40], R1);
        ObjectSet("R1 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("R1 line", OBJPROP_COLOR, Yellow);
       }
      else
       {
        ObjectMove("R1 line", 0, Time[40], R1);
       }

      if(ObjectFind("R2 line") != 0)
       {
        ObjectCreate("R2 line", OBJ_HLINE, 0, Time[40], R2);
        ObjectSet("R2 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("R2 line", OBJPROP_COLOR, Orange);
       }
      else
       {
        ObjectMove("R2 line", 0, Time[40], R2);
       }

      if(ObjectFind("R3 line") != 0)
       {
        ObjectCreate("R3 line", OBJ_HLINE, 0, Time[40], R3);
        ObjectSet("R3 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("R3 line", OBJPROP_COLOR, Red);
       }
      else
       {
        ObjectMove("R3 line", 0, Time[40], R3);
       }
       
// Fibonacci Labeling

      if(ObjectFind("F24 line") != 0)
       {
        ObjectCreate("F24 line", OBJ_HLINE, 0, Time[40], F24);
        ObjectSet("F24 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("F24 line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("F24 line", 0, Time[40], F24);
       }

      if(ObjectFind("F38 line") != 0)
       {
        ObjectCreate("F38 line", OBJ_HLINE, 0, Time[40], F38);
        ObjectSet("F38 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("F38 line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("F38 line", 0, Time[40], F38);
       }

      if(ObjectFind("F62 line") != 0)
       {
        ObjectCreate("F62 line", OBJ_HLINE, 0, Time[40], F62);
        ObjectSet("F62 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("F62 line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("F62 line", 0, Time[40], F62);
       }

      if(ObjectFind("F76 line") != 0)
       {
        ObjectCreate("F76 line", OBJ_HLINE, 0, Time[40], F76);
        ObjectSet("F76 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("F76 line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("F76 line", 0, Time[40], F76);
       }
   //yesterday high and low
       
       if(ObjectFind("DH line") != 0)
       {
        ObjectCreate("DH line", OBJ_HLINE, 0, Time[40], DH);
        ObjectSet("DH line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("DH line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("DH line", 0, Time[40], DH);
       }

      if(ObjectFind("DL line") != 0)
       {
        ObjectCreate("DL line", OBJ_HLINE, 0, Time[40], DL);
        ObjectSet("DL line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("DL line", OBJPROP_COLOR, White);
       }
      else
       {
        ObjectMove("DL line", 0, Time[40], DL);
       }

      
       
// Indicator Calculations

   double diRSI0 = iRSI(NULL,15,9,PRICE_CLOSE,0);
   double d1 = (30);
   double diRSI6 = iRSI(NULL,15,9,PRICE_CLOSE,0);
   double  d7 = (70);
       
 //Entrypoint long 
 Tradingpoint=Ask==P;
 Tradingpoint=Ask==R1;
 Tradingpoint=Ask==R2;
 Tradingpoint=Ask==R3;
 Tradingpoint=Ask==S1;
 Tradingpoint=Ask==S2;
 Tradingpoint=Ask==S3;
 Tradingpoint=Ask==F24;
  Tradingpoint=Ask==F38;
   Tradingpoint=Ask==F62;
    Tradingpoint=Ask==F76;
     Tradingpoint=Ask==DH;
      Tradingpoint=Ask==DL;
 
 //entrypoint short
 Tradingpoint=Bid==P;
 Tradingpoint=Bid==R1;
 Tradingpoint=Bid==R2;
 Tradingpoint=Bid==R3;
 Tradingpoint=Bid==S1;
 Tradingpoint=Bid==S2;
 Tradingpoint=Bid==S3;
 Tradingpoint=Bid==F24;
 Tradingpoint=Bid==F38;
 Tradingpoint=Bid==F62;
  Tradingpoint=Bid==F76;
   Tradingpoint=Bid==DH;
    Tradingpoint=Bid==DL;
  
        
    
// Checking Account Free Margin       
   
   int total=OrdersTotal();
   if(total<1) 
    {
     if(AccountFreeMargin()<(1000*Lots))
      {
       Print("We have no money. Free Margin = ", AccountFreeMargin());
      }
   // Check for long positions (if you have money and no more than 1 order open)
     
     if(diRSI0<d1&& Tradingpoint)
        {
         SL = Ask - StopLoss * Point;
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SL,Buy_TP,"MoStAsHaR15 FoReX",16384,0,White);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Comment("BUY order opened : ",OrderOpenPrice());
           }
         else Comment("Error opening BUY order : ",GetLastError()); 
         return(0); 
        }
   // Check for short positions (if you have money and no more than 2 orders open)
     if(diRSI6>d7 && Tradingpoint )
        {
         SL = Bid + StopLoss * Point;
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SL,Sell_TP,"MoStAsHaR15 FoReX",16384,0,White);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Comment("SELL order opened : ",OrderOpenPrice());
           }
         else Comment ("Error opening SELL order : ",GetLastError()); 
         return(0); 
        }
    return(0);
   }
   
// Open Trades Management

   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())
      {
       if(OrderType()==OP_BUY)   // long position is opened
        {
   
   // Profit Shield (LONG)
         if((OrderOpenPrice()-Bid)/Point > ProfitShield)
          {
           SL = OrderOpenPrice();
           OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Green);
          }
            
   // Trailing Stop Managment
        
         if(TrailingStop>0)  
          {
           if(Bid-OrderOpenPrice()>Point*TrailingStop)
            {
             if(OrderStopLoss()<Bid-Point*TrailingStop)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
              }
            }
          }
        }
       else // go to short position
       
   // Profit Shield (SHORT)
  
         if((OrderOpenPrice()-Ask)/Point > ProfitShield)
          {
           SL = OrderOpenPrice();
           OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Green);
          }
       
       if(TrailingStop>0)  
        {                 
         if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
          {
           if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
            {
             OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
             return(0);
            }
          }
        }
      }
  return(0);
  }
}