#property copyright "Copyleft c 2014, Thrinai Chankong"
#property link      "http://www.plapayoon.com"


#define DECISION_BUY 1
#define DECISION_SELL 0
#define DECISION_UNKNOWN -1

//---- Edit by Thrinai : Stochastic Status -----
#define STC_UNCLEAR 0
#define STC_REVERS_UP 1
#define STC_REVERS_DOWN 2
#define STC_SUPER_UP 3
#define STC_SUPER_DOWN 4

//----/ Edit by Thrinai : Stochastic Status -----


//---- Global Variables
extern string Autor = "Thrinai Chankong";
extern string Desc1 = "If you want to donate me";
extern string Desc2 = "can pay to paypal: thrinai@hotmail.com";
extern string Desc3 = "Thanks a lot";
extern bool ShowMarketInfo = false;
extern double SlipPage = 1; // Slippage rates
extern double Lots = 0.1; // Number of lots
extern double StopLoss = 0;
extern double TakeProfit = 0;
extern double MAGIC = 12357951;
extern bool StopLossRecover = true;
extern bool NotSell = false;
extern bool NotBuy = false;
extern bool Martingale = false;
extern int MartingaleStep = 0;
extern bool AutoLots = false;
extern double MAXLots = 10;
extern double SymbolsCount = 2;
extern double Risk = 0.7;
extern int PauseMin  =  0;
extern int FromHourStop1  =  25;
extern int ToHourStop1  =  25;
extern int FromHourStop2  =  25;
extern int ToHourStop2  =  25;
extern int FromHourStop3  =  25;
extern int ToHourStop3  =  25;
extern int FromHourStop4  =  25;
extern int ToHourStop4  =  25;
extern int StoKperiod=4;
extern int StoDperiod=3;
extern int StoSlowing=3; 
extern int MASlowTime =  15;
extern int MAFastTime =  3;
extern int CCITime =  5;
extern int CHOTime=5;
extern int RSITime=6;
extern int ADX=6;
extern int MomentTime=5; 
//----

//---- buffers
//double upArrow[];
double downArrow[];
double BestPrice1=0;
double BestPrice2=0;
double mMultiply=1;
double BeforeLoss;
//string PatternText[5000];

double BidPrev = 0;
double AskPrev = 0;
double CHOCurrent;
double CHOPrevious;
int StopLossIndex =  0;
int TakeProfitIndex  =  0;
int ToSell=0;
int ToBuy =0;
int FoundOpenedOrder = false;
int Decision;
int PrevDecision;
int ticket,total,cnt;
datetime PauseTo;
static datetime Old_Time=0;
double CHOCurrentExit,CHOPreviousExit,RSICurrentExit,RSIPreviousExit;
// Variables to assess the quality of modeling
double pipe;
// Variables for the storage information (data) about the market
double ModeLow;
double ModeHigh;
double ModeTime;
double ModeBid;
double ModeAsk;
double ModePoint;
double ModeDigits;
double ModeSpread;
double ModeStopLevel;
double ModeLotSize;
double ModeTickValue;
double ModeTickSize;
double ModeSwapLong;
double ModeSwapShort;
double ModeStarting;
double ModeExpiration;
double ModeTradeAllowed;
double ModeMinLot;
double ModeLotStep;


// ------ Stochastic Indicator ---
   double STOCHCurrent;
   double STOCHPrevious;
   double STOCHSigCurrent;
   double STOCHSigPrevious;
   int STOCH_Status;

//------- CCI Indicator -------
   double CCICurrent;
   double CCIPrevious;
   int CCI_Status;
//------- RSI Indicator -------
   double RSICurrent;
   double RSIPrevious;
   int RSI_Status;
   
   int CandleStatus;
   int MACDStatus;
   
   double MomentCurrent;
   double MomentPrevious;
//------------ PivotPoint --------------
   double P,R,R05,R10,R15,R20,R25,R30,S05,S10,S15,S20,S25,S30;
   
   double StopLossValue=0;
   double TakeProfitValue=0;
   bool IsNewBar = false;
   datetime New_Time[1];
   int copied=0;

//+------------------------------------------------------------------+
//| We read information about the market                                                                  |
//+------------------------------------------------------------------+

int GetMarketInfo()
  {
   ModeLow = MarketInfo(Symbol(), MODE_LOW);
   ModeHigh = MarketInfo(Symbol(), MODE_HIGH);
   ModeTime = MarketInfo(Symbol(), MODE_TIME);
   ModeBid = MarketInfo(Symbol(), MODE_BID);
   ModeAsk = MarketInfo(Symbol(), MODE_ASK);
   ModePoint = MarketInfo(Symbol(), MODE_POINT);
   ModeDigits = MarketInfo(Symbol(), MODE_DIGITS);
   ModeSpread = MarketInfo(Symbol(), MODE_SPREAD);
   ModeStopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   ModeLotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   ModeTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   ModeTickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   ModeSwapLong = MarketInfo(Symbol(), MODE_SWAPLONG);
   ModeSwapShort = MarketInfo(Symbol(), MODE_SWAPSHORT);
   ModeStarting = MarketInfo(Symbol(), MODE_STARTING);
   ModeExpiration = MarketInfo(Symbol(), MODE_EXPIRATION);
   ModeTradeAllowed = MarketInfo(Symbol(), MODE_TRADEALLOWED);
   ModeMinLot = MarketInfo(Symbol(), MODE_MINLOT);
   ModeLotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   // It is concluded information about the market
   if ( ShowMarketInfo == True )
     {
       Print("ModeLow:",ModeLow);
       Print("ModeHigh:",ModeHigh);
       Print("ModeTime:",ModeTime);
       Print("ModeBid:",ModeBid);
       Print("ModeAsk:",ModeAsk);
       Print("ModePoint:",ModePoint);
       Print("ModeDigits:",ModeDigits);
       Print("ModeSpread:",ModeSpread);
       Print("ModeStopLevel:",ModeStopLevel);
       Print("ModeLotSize:",ModeLotSize);
       Print("ModeTickValue:",ModeTickValue);
       Print("ModeTickSize:",ModeTickSize);
       Print("ModeSwapLong:",ModeSwapLong);
       Print("ModeSwapShort:",ModeSwapShort);
       Print("ModeStarting:",ModeStarting);
       Print("ModeExpiration:",ModeExpiration);
       Print("ModeTradeAllowed:",ModeTradeAllowed);
       Print("ModeMinLot:",ModeMinLot);
       Print("ModeLotStep:",ModeLotStep);
     }
   return (0);
  }


//+------------------------------------------------------------------+
//|   Initialize Adviser                                             |
//+------------------------------------------------------------------+
int init()
  {
   Print("Ethan Wisdom Trade is Ready");
   CCI_Status     = DECISION_UNKNOWN;
   RSI_Status     = DECISION_UNKNOWN;
   STOCH_Status   = DECISION_UNKNOWN;
   
   Decision       = DECISION_UNKNOWN;
   PrevDecision   = DECISION_UNKNOWN;
   CandleStatus   = DECISION_UNKNOWN;
   
   return(0);
  }


//+------------------------------------------------------------------+
//| Entering the market                                              |
//+------------------------------------------------------------------+
int EnterMarket()
{
   double MAFastCurrent,MAFastPrev,MASlow,diffMA;
   //double CSell,CBuy;
   double Lowest,Highest,diffFibo;
   double P1000,P000,P236,P382,P500,P618,P786;
   int CountLow=0;
   int CountHigh=0;
// If there is no means leave
   if(Lots == 0)
     {
       return (0);
     }

   int h=TimeHour(CurTime());
   int hadj=TimeHour(CurTime());

   
   if (((hadj >= FromHourStop1) &&(hadj <= ToHourStop1)) || ((hadj >= FromHourStop2) &&(hadj <= ToHourStop2)) || ((hadj >= FromHourStop3) &&(hadj <= ToHourStop3))|| ((hadj >= FromHourStop4) &&(hadj <= ToHourStop4))) {
         return (0);
      }
    if(CurTime()<PauseTo){
         return(0);
    }
    
// Enter the market if there is no command to exit the market
   if(StopLoss>0){
      StopLossIndex  =  StopLoss/Lots;
   }
   if(TakeProfit>0){
      TakeProfitIndex   =  TakeProfit/Lots;
   }
   //----- Fibonacci--------------
   
   
   Lowest = Low[iLowest(NULL,0,MODE_LOW,180,1)];
   Highest = High[iHighest(NULL,0,MODE_HIGH,180,1)];
   diffFibo= Highest-Lowest;
   P1000 =  Highest;
   P000  =  Lowest;
   P236  =  Lowest+(diffFibo*0.236);
   P382  =  Lowest+(diffFibo*0.382);
   P500  =  Lowest+(diffFibo*0.5);
   P618  =  Lowest+(diffFibo*0.618);
   P786  =  Lowest+(diffFibo*0.786);
   
   //---// Fibonacci--------------
   
   AskRSI();
   AskStochastic();
   AskCCI();
   
  
   
    if(Decision==DECISION_BUY && NotBuy==false){
      
      MAFastCurrent=iMA(NULL,0,MAFastTime,0,MODE_SMMA,PRICE_CLOSE,0);
      MAFastPrev=iMA(NULL,0,MAFastTime,0,MODE_SMMA,PRICE_CLOSE,1);
      MASlow=iMA(NULL,0,MASlowTime,1,MODE_SMMA,PRICE_CLOSE,0);
      diffMA   =  MathAbs(MAFastCurrent-MASlow/Point);
      if((MAFastCurrent<MASlow || MAFastCurrent<MAFastPrev) || (diffMA<20)){
         return(0);
      }
      if(STOCHCurrent<88){
         if(CCIPrevious>CCICurrent){
            return(0);
         }

         if((RSIPrevious>RSICurrent)|| (RSICurrent>70)){
            return(0);
         }
      }
      
      if(CHOPrevious>CHOCurrent){
         return(0);
      }
      MomentCurrent = iMomentum(NULL,0,MomentTime,PRICE_CLOSE,0);
      MomentPrevious = iMomentum(NULL,0,MomentTime,PRICE_CLOSE,1);
     
      if(MomentPrevious>MomentCurrent){
         return(0);
      }
      //+--------------------- Check Cancle ----------------+
       if(Ask<Highest && Ask>Lowest){
         
         if(Ask>=(P236-(Point*5))&& Ask<=(P236+(Point*5))){
            return(0);
         }
          if(Ask>=(P382-(Point*5))&& Ask<=(P382+(Point*5))){
             return(0);
          }
          if(Ask>=(P500-(Point*5))&&Ask<=(P500+(Point*5))){
            return(0);
          }
          if(Ask>=(P618-(Point*5)) && Ask<=(P618+(Point*5))){
          return(0);
          
          }
          if(Ask>=(P786-(Point*5))&& Ask<=(P786+(Point*5))){
            return(0);
          }
         
          
          
      
      }
      
     /* for(int i=1;i<90;i++){
         if(iOpen(NULL,0,i)>iClose(NULL,0,i)){
          
         }
         if(iOpen(NULL,0,i)<iClose(NULL,0,i)){
            if(iClose(NULL,0,i)>CBuy){
               CBuy=iClose(NULL,0,i);               
            }else if(iClose(NULL,0,i)==CBuy){
               CountHigh++;
            }
            if(CountHigh==2){
               break;
            }
         }
      }
      if(CountHigh>1){
         if(CBuy<=Ask){
            TradeSell();
            return(0);
         }
      }*/
      //+---------------------------------------------------+
      TradeBuy();
      return(0);
      
    }else if(Decision==DECISION_SELL && NotSell==false){
      MAFastCurrent=iMA(NULL,0,MAFastTime,0,MODE_SMMA,PRICE_OPEN,0);
      MAFastPrev=iMA(NULL,0,MAFastTime,0,MODE_SMMA,PRICE_OPEN,1);
      MASlow=iMA(NULL,0,MASlowTime,1,MODE_SMMA,PRICE_OPEN,0);
      diffMA   =  MathAbs(MAFastCurrent-MASlow/Point);
      if((MAFastCurrent>MASlow || MAFastCurrent>MAFastPrev) || (diffMA<20)){
         return(0);
      }
      MomentCurrent = iMomentum(NULL,0,MomentTime,PRICE_CLOSE,0);
      MomentPrevious = iMomentum(NULL,0,MomentTime,PRICE_CLOSE,1);
      
      if(STOCHCurrent>12){
         if(CCIPrevious<CCICurrent){
            return(0);
         }
      
         if((RSIPrevious<RSICurrent)|| (RSICurrent<30)){
            return(0);
         }
      }
       
      if(CHOPrevious<CHOCurrent){
         return(0);
      }
      
      if(MomentPrevious<MomentCurrent){
         return(0);
      }
       //+--------------------- Check Cancle ----------------+
       if(Bid<Highest && Bid>Lowest){
         
        if(Bid>=(P236-(Point*5))&& Bid<=(P236+(Point*5))){
            return(0);
         }
          if(Bid>=(P382-(Point*5))&& Bid<=(P382+(Point*5))){
             return(0);
          }
          if(Bid>=(P500-(Point*5))&&Bid<=(P500+(Point*5))){
            return(0);
          }
          if(Bid>=(P618-(Point*5)) && Bid<=(P618+(Point*5))){
          return(0);
          
          }
          if(Bid>=(P786-(Point*5))&& Bid<=(P786+(Point*5))){
            return(0);
          }
          
          
  
      
      }
     
      /*for(i=1;i<90;i++){
         if(iOpen(NULL,0,i)>iClose(NULL,0,i)){
            if(iClose(NULL,0,i)<CSell){
               CSell=iClose(NULL,0,i);
            }else if(iClose(NULL,0,i)==CSell){
               CountLow++;
            }
            if(CountLow==2){
               break;
            }
         }
         
      }
      if(CountLow>1){
         if(CSell>=Bid){
            TradeBuy();
            return(0);
         }
      }*/
      
      //+---------------------------------------------------+
     
      TradeSell();
      return(0);
      
    }
    
      
   return (0);
}   
//+------------------------------------------------------------------+
//| TradeBuy                                                         |
//+------------------------------------------------------------------+
int TradeBuy(){
   if(StopLoss>0){
         StopLossValue  =  Bid-(Point*StopLossIndex*mMultiply);
      }
      if(TakeProfit>0){
         TakeProfitValue   = Ask+(Point*TakeProfitIndex*mMultiply);
      }
      
       //ticket = OrderSend(Symbol(),OP_BUY,Lots*mMultiply,Ask,3,StopLossValue,TakeProfitValue,"TurtleTrader(BUY)",0,3,Green);
       ticket = OrderSend(Symbol(),OP_BUY,Lots*mMultiply,Ask,3,0,0,"TurtleTrader(BUY)",MAGIC,3,Green);
       if(ticket  > 0){
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
           OrderModify(OrderTicket(), OrderOpenPrice(), StopLossValue, TakeProfitValue, 3, Green);
	}
            PrevDecision=Decision;
            Print("Buy order is opened: ",OrderOpenPrice());
       }else{
            Print("Error opening BUY order:",GetLastError());
            
       }
       return(0);
}
//+------------------------------------------------------------------+
//| Trade Sell                                                       |
//+------------------------------------------------------------------+
int TradeSell(){
      if(StopLoss>0){
         StopLossValue  =  Bid+(Point*StopLossIndex*mMultiply);
      }
      if(TakeProfit>0){
         TakeProfitValue   = Ask-(Point*TakeProfitIndex*mMultiply);
      }
      
      //ticket = OrderSend(Symbol(),OP_SELL,Lots*mMultiply,Bid,3,StopLossValue,TakeProfitValue,"TurtleTrader(SELL)",0,3,Red);
      ticket = OrderSend(Symbol(),OP_SELL,Lots*mMultiply,Bid,3,0,0,"TurtleTrader(SELL)",MAGIC,3,Red);
      if(ticket  > 0){
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
            OrderModify(OrderTicket(), OrderOpenPrice(), StopLossValue, TakeProfitValue, 3, Green);
         }
         PrevDecision=Decision;
         Print("Sell order is opened: ",OrderOpenPrice());
      }else{
         Print("Error opening SELL order:",GetLastError());
         
      }
      return(0);
}
  
//+------------------------------------------------------------------+
//| Ask Stochastic                                                   |
//+------------------------------------------------------------------+
int AskStochastic()
{
   CHOCurrent = iCustom(NULL,0,"CHO",CHOTime,3,0,1,0);
   CHOPrevious = iCustom(NULL,0,"CHO",CHOTime,3,0,1,1);
  
      // STOCHASTIC VALUE 
   STOCHCurrent = iStochastic(NULL,0,StoKperiod,StoDperiod,StoSlowing,MODE_SMA,0,MODE_MAIN,0);
   STOCHPrevious = iStochastic(NULL,0,StoKperiod,StoDperiod,StoSlowing,MODE_SMA,0,MODE_MAIN,1);
   
  // STOCH_Status   =  DECISION_UNKNOWN;
   
   if(STOCHCurrent>50 && STOCHCurrent<88 ){
         if(CHOCurrent>10){
            STOCH_Status   =  DECISION_BUY;
            
         }else if(CHOCurrent<-10){
            STOCH_Status   =  DECISION_SELL;
           
        }
   }else if(STOCHCurrent<=12){
        STOCH_Status   =  DECISION_SELL;
        
   }else if(STOCHCurrent>=88){
        STOCH_Status   =  DECISION_BUY;
        
   }else if(STOCHCurrent<50 && STOCHCurrent>12){
        if(CHOCurrent>10){
            STOCH_Status   =  DECISION_BUY;
            
         }else if(CHOCurrent<-10){
            STOCH_Status   =  DECISION_SELL;
            
        }
   }
   return (0);
}

//-------------------------------------------------------------------  



//+------------------------------------------------------------------+
//| Ask CCI                                                       |
//+------------------------------------------------------------------+
int AskCCI()
{
      // CCI VALUE 
   CCICurrent = iCCI(NULL,0,CCITime,PRICE_TYPICAL,0);
   CCIPrevious = iCCI(NULL,0,CCITime,PRICE_TYPICAL,1);
//   CCI_Status   =  DECISION_UNKNOWN;
   
   if((CCICurrent>CCIPrevious)&&(CCICurrent<75)){
        CCI_Status   =  DECISION_BUY;
       
   }else if((CCICurrent<CCIPrevious)&&(CCICurrent>=-75)){
        CCI_Status   =  DECISION_SELL;
        
   }
   return (0);
}

//------------------------------------------------------------------- 

int AskRSI()
{
      // RSI VALUE 
   RSICurrent = iRSI(NULL,0,RSITime,PRICE_CLOSE,0);
   RSIPrevious = iRSI(NULL,0,RSITime,PRICE_CLOSE,1);
   RSI_Status   =  DECISION_UNKNOWN;
   
   if(RSICurrent>=50){
        RSI_Status   =  DECISION_BUY;
        
   }else if(RSICurrent<50){
        RSI_Status   =  DECISION_SELL;
        
   }
   return (0);
}

//------------------------------------------------------------------- 

//+------------------------------------------------------------------+
//| Exiting the market                                               |
//+------------------------------------------------------------------+
int ExitMarket ()
  {
      
   CHOCurrentExit = iCustom(NULL,PERIOD_M1,"CHO",CHOTime,3,0,1,0);
   CHOPreviousExit = CHOPrevious;
   //CHOPreviousExit = iCustom(NULL,PERIOD_M1,"CHO",5,3,0,1,1);
   RSICurrentExit = iRSI(NULL,PERIOD_M1,RSITime,PRICE_CLOSE,0);
   RSIPreviousExit = RSIPrevious;
   //RSIPreviousExit = iRSI(NULL,PERIOD_M1,6,PRICE_CLOSE,1);
   
   
    if(FoundOpenedOrder == True){
   
    for(cnt = 0; cnt < total;cnt++){
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType() <= OP_SELL && OrderSymbol() == Symbol()){
      
         if(OrderType()==OP_BUY) 
         {
          if(OrderOpenPrice() < Bid){
            BestPrice2=BestPrice1;
            BestPrice1=Bid;
          }
          
          if(STOCHCurrent>=88&&(RSI_Status ==DECISION_BUY)){
               return(0);
          }
          
          //if(BestPrice1<=BestPrice2&&(OrderOpenPrice() < Bid)){
          if(((CHOCurrentExit<CHOPreviousExit) || (RSICurrentExit<RSIPreviousExit)) && OrderOpenPrice() < Bid){
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
               Print("Close Order BUY : ",Bid);
               BestPrice1=0;
               BestPrice2=0;
               PauseTo = (PauseMin*60)+CurTime();
              
               return(0);
            }
            
          }
         
         else 
         {
            
          if(OrderOpenPrice() > Ask){
               BestPrice2=BestPrice1;
               BestPrice1=Ask;
                        
          }
          
         
          if(STOCHCurrent<=12&&(RSI_Status ==DECISION_SELL)){
               return(0);
           }
          
            //if(BestPrice1>BestPrice2&&(OrderOpenPrice() > Ask)){
          if(((CHOCurrentExit>CHOPreviousExit)||(RSICurrentExit>RSIPreviousExit)) && OrderOpenPrice() > Ask){
               OrderClose(OrderTicket(),OrderLots(),Ask ,3,Yellow);
               Print("Close Order SELL : ",Ask);
               BestPrice1=0;
               BestPrice2=0;
               PauseTo = (PauseMin*60)+CurTime();
               
               return(0);
            }
         }
       }
      }
    }
   return (0);
  }


//+--------------------------------------------------------------------------+
//| Ask Candle                                                               |
//+--------------------------------------------------------------------------+
 int AskCandle(){
   //-----------------------------------------------------------------
   // Bar checks
   //-----------------------------------------------------------------
   double Range, AvgRange;
   int counter, setalert;
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   string pattern, period;
   int setPattern = 0;
   int alert = 0;
  // int arrowShift;
   //int textShift;
   double O, O1, O2, C, C1, C2, L, L1, L2, H, H1, H2;
     
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   //ModePoint
   switch (Period()) {
      case 1:
         period = "M1";
         break;
      case 5:
         period = "M5";
         break;
      case 15:
         period = "M15";
         break;
      case 30:
         period = "M30";
         break;      
      case 60:
         period = "H1";
         break;
      case 240:
         period = "H4";
         break;
      case 1440:
         period = "D1";
         break;
      case 10080:
         period = "W1";
         break;
      case 43200:
         period = "MN";
         break;
   }
   
   /*for (int j = 0; j < Bars; j++) { 
         PatternText[j] = "pattern-" + j;
   }*/
   
   //for (shift = 0; shift < Bars; shift++) {
      
      setalert = 0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for (counter=shift ;counter<=shift+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
      
      O = Open[shift1];
      O1 = Open[shift2];
      O2 = Open[shift3];
      H = High[shift1];
      H1 = High[shift2];
      H2 = High[shift3];
      L = Low[shift1];
      L1 = Low[shift2];
      L2 = Low[shift3];
      C = Close[shift1];
      C1 = Close[shift2];
      C2 = Close[shift3];
      CandleStatus   =  DECISION_UNKNOWN;

      // Bearish Patterns
   
      // Check for Bearish Engulfing pattern
      if ((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1))) {
          pattern = "Bearish Engulfing Pattern";
          setalert = 1;
         
      }
      
      // Check for a Three Outside Down pattern
      if ((C2>O2)&&(O1>C1)&&(O1>=C2)&&(O2>=C1)&&((O1-C1)>(C2-O2))&&(O>C)&&(C<C1)) {
           pattern="Three Oustide Down Pattern";
           setalert = 1;
         
      }
      
      // Check for a Dark Cloud Cover pattern
      if ((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)&&(O>C1)&&(C>O1)&&((O-C)/(0.001+(H-L))>0.6)) {
            pattern="Dark Cloud Cover Pattern";
            setalert = 1;
         
      }
      
      // Check for Evening Doji Star pattern
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
           pattern="Evening Doji Star Pattern";
           setalert = 1;
         
      }
      
      // Check for Bearish Harami pattern
      
      if ((C1>O1)&&(O>C)&&(O<=C1)&&(O1<=C)&&((O-C)<(C1-O1))) {
            pattern="Bearish Harami Pattern";
            setalert = 1;
         
      }
      
      // Check for Three Inside Down pattern
      
      if ((C2>O2)&&(O1>C1)&&(O1<=C2)&&(O2<=C1)&&((O1-C1)<(C2-O2))&&(O>C)&&(C<C1)&&(O<O1)) {
            pattern="Three Inside Down Pattern";
            setalert = 1;
         
      }
      
      // Check for Three Black Crows pattern
      
      if ((O > C * 1.01)&&(O1 > C1 * 1.01)&&(O2 > C2*1.01)&&(C < C1)&&(C1 < C2)&&(O > C1)&&(O < O1)&&(O1 > C2)&&(O1 < O2)&&(((C - L)/(H - L+0.000001))<0.2)&&(((C1 - L1)/(H1 - L1+0.000001))<0.2)&&(((C2 - L2)/(H2 - L2+0.000001))<0.2)){
            pattern="Three Black Crows Pattern";
            setalert = 1;
            alert=2;
         
      }
      // Check for Evening Star Pattern
      
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
            pattern = "Evening Star Pattern";
            setalert = 1;
         
      }
      if(setalert==1){
         CandleStatus   =  DECISION_SELL;
        // Alert(Symbol(), " ", period, " ", pattern);
         setalert = 0;
         return(alert);      
      }
   // End of Bearish Patterns
   
   // Bullish Patterns
   
      // Check for Bullish Engulfing pattern
      
      if ((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1))) {
            pattern="Bullish Engulfing Pattern";
            setalert = 1;
         
      }
      
      // Check for Three Outside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1>=O2)&&(C2>=O1)&&((C1-O1)>(O2-C2))&&(C>O)&&(C>C1)) {
            pattern="Three Outside Up Pattern";
            setalert = 1;
         
      }
      
      // Check for Bullish Harami pattern
      
      if ((O1>C1)&&(C>O)&&(C<=O1)&&(C1<=O)&&((C-O)<(O1-C1))) {
            pattern="Bullish Harami Pattern";
            setalert = 1;
         
      }
      
      // Check for Three Inside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1<=O2)&&(C2<=O1)&&((C1-O1)<(O2-C2))&&(C>O)&&(C>C1)&&(O>O1)) {
            pattern="Three Inside Up Pattern";
            setalert = 1;
         
      }
      
      // Check for Piercing Line pattern
      
      if ((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)&&(O<C1)&&(C<O1)&&((C-O)/(0.001+(H-L))>0.6)) {
            pattern="Piercing Line Pattern";
            setalert = 1;
         
      }
      
      // Check for Three White Soldiers pattern
      
      if ((C>O*1.01)&&(C1>O1*1.01)&&(C2>O2*1.01)&&(C>C1)&&(C1>C2)&&(O<C1)&&(O>O1)&&(O1<C2)&&(O1>O2)&&(((H-C)/(H-L+0.000001))<0.2)&&(((H1-C1)/(H1-L1+0.000001))<0.2)&&(((H2-C2)/(H2-L2+0.000001))<0.2)) {
            pattern="Three White Soldiers Pattern";
            setalert = 1;
            alert =  1;
         
      }
      
      // Check for Morning Doji Star
      
      if ((O2>C2)&&((O2-C2)/(0.001+H2-L2)>0.6)&&(C2>O1)&&(O1>C1)&&((H1-L1)>(3*(C1-O1)))&&(C>O)&&(O>O1)) {
            pattern="Morning Doji Star Pattern";
            setalert = 1;
         
      }
      if(setalert==1){
         CandleStatus   =  DECISION_BUY;
         
         setalert = 0;
         return(alert);      
      }
      
      
//   } // End of for loop
     
   
      
   return(0);

   //-------------------------------------------------------------------
   
   
 }
 //+-------------------------------------------------------------------------+
 //+      Ask Trend or Side Way                                              |
 //+-------------------------------------------------------------------------+
int AskADX()
{
 //set ADX Trend
   int Trend = 0; // 1 = to buy , 2 = to sell
   double ADXMinus = 0;
   double ADXPlus = 0;
   int ADXTrend = 0;  //1 = buy, 2 = sell
 
   ADXMinus = iADX(Symbol(),0,ADX,PRICE_LOW,MODE_MINUSDI,0);
   ADXPlus = iADX(Symbol(),0,ADX,PRICE_LOW,MODE_PLUSDI,0);
   
   //ADX Main Value
   double ADXMain = 0;
   ADXMain = iADX(Symbol(),0,ADX,PRICE_LOW,MODE_MAIN,0);
   double ADXMain1 = 0;
   ADXMain1 = iADX(Symbol(),0,ADX,PRICE_LOW,MODE_MAIN,1);
   
   //end ADX Main Value
   
   if (ADXMinus < ADXPlus && ADXMain > ADXMain1 && ADXMain1>20 && ADXMain1<40)
   {
      Trend = 1;
   }
   else if (ADXMinus > ADXPlus && ADXMain > ADXMain1 && ADXMain1>20 && ADXMain1<40) 
   {
      Trend = 2;
   }
   //end ADX
   


   return (Trend);

}
 
 
 
    
//+--------------------------------------------------------------------------+
//| Save the values and rates for the following period of the simulation iterratsii|
//+--------------------------------------------------------------------------+
int SaveStat()
  {
   BidPrev = Bid;
   AskPrev = Ask;   
   return (0);
  }
//+------------------------------------------------------------------+
//| Trading                                                        |
//+------------------------------------------------------------------+
int Trade ()
  {
   // begin to trade
   // Looking for open orders
   
   ToSell=0;
   ToBuy =0;
   FindSymbolOrder();
   
   
   AskCCI();
   AskRSI();
   AskStochastic();
   AskCandle();
  
   
   
   if(CCI_Status==DECISION_BUY){
      ToBuy=ToBuy+1;
      CCI_Status=DECISION_UNKNOWN;
   }else
   if(CCI_Status==DECISION_SELL){
      ToSell=ToSell+1;
      CCI_Status=DECISION_UNKNOWN;
   }
   
   if(RSI_Status==DECISION_BUY){
      ToBuy=ToBuy+1;
      RSI_Status=DECISION_UNKNOWN;
   }else
   if(RSI_Status==DECISION_SELL){
      ToSell=ToSell+1;
      RSI_Status=DECISION_UNKNOWN;
   }
   
   if(STOCH_Status==DECISION_BUY){
      ToBuy=ToBuy+1;
      STOCH_Status=DECISION_UNKNOWN;
   }else
   if(STOCH_Status==DECISION_SELL){
      ToSell=ToSell+1;
      STOCH_Status=DECISION_UNKNOWN;
   }
   
   if(CandleStatus==DECISION_BUY){
      ToBuy=ToBuy+1;
      CandleStatus=DECISION_UNKNOWN;
   }else
   if(CandleStatus==DECISION_SELL){
      ToSell=ToSell+1;
      CandleStatus=DECISION_UNKNOWN;
   }
   if(AskADX()==1){
      ToBuy=ToBuy+1;
   }else if(AskADX()==2){
      ToSell=ToSell+1;
   }
   
   
    //-----------------------------------------------------------------
    if(ToSell>ToBuy){
      Decision = DECISION_SELL ;
   }else if(ToSell<ToBuy){
      Decision = DECISION_BUY ;
   }else{
      Decision = DECISION_UNKNOWN;
   }

//---- If open orders on simaolu no chance of entering the market
//---- Warning - it is important that the order of consideration of technologies to enter the market (MoneyTrain, LogicTrading, Pipsator)
   ArraySetAsSeries(New_Time,true);
   
   copied = CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0){
      if(Old_Time!=New_Time[0]){
         Old_Time=New_Time[0];
         IsNewBar=true;
         
      }else{
         IsNewBar=false;
      }
   }
   if(FoundOpenedOrder == false)
     {
         checkForRecovery();
         FindSymbolOrder();
         if(FoundOpenedOrder == false )
         {
            if(AskADX()!=0 /*&& IsNewBar==true*/){
               EnterMarket();
               return(0);  
            }
          }
         
               
     }
   else
     {
       
       ExitMarket();
     }
//---- End of processing I / O from the market
   return(0);
  }
 //+-----------------------------------------------------------------+
 //| Recover                                                         |
 //+-----------------------------------------------------------------+
int checkForRecovery(){
   int MagicNumber;
   static int StaticTicketNumber;
   int i=OrdersHistoryTotal()-1;
   if(StopLoss>0){
      StopLossIndex  =  StopLoss/Lots;
   }
   if(TakeProfit>0){
      TakeProfitIndex   =  TakeProfit/Lots;
   }   
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         MagicNumber = OrderMagicNumber();
         int check = OrderTicket();
         string MyOrderSymbol = OrderSymbol(); 
                
         if(StaticTicketNumber != check && OrderProfit()<0 && MyOrderSymbol==Symbol()){
            if(Martingale==true){
               if(mMultiply<MathPow(2,MartingaleStep)){
                  mMultiply=2*mMultiply;
               }
            }else{
               mMultiply=1;
            }
            if(OrderType()==OP_SELL && StopLossRecover==true) 
            {
               
               if(StopLoss>0){
                 StopLossValue  =  Bid-(Point*StopLossIndex*mMultiply);
                 //StopLossValue=0;
               }
               if(TakeProfit>0){
                  TakeProfitValue   = Ask+(Point*TakeProfitIndex*mMultiply);
                 //TakeProfitValue=0;
               }
               ticket = OrderSend(Symbol(),OP_BUY,Lots*mMultiply,Ask,3,0,0,"TurtleTrader(BUY)",MAGIC,3,Green);
               if(ticket > 0){
                if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
                    OrderModify(OrderTicket(), OrderOpenPrice(), StopLossValue, TakeProfitValue, 3, Green);
                }
                  PrevDecision=Decision;
                  Print("Buy order is opened: ",OrderOpenPrice());
               }else{
                  Print("Error opening BUY order:",GetLastError());
                  
               }

               return(0);
            }
            if(OrderType()==OP_BUY && StopLossRecover==true) 
            {
               
            	if(StopLoss>0){
            		StopLossValue  =  Bid+(Point*StopLossIndex*mMultiply);
            	}
            	if(TakeProfit>0){
         			TakeProfitValue   = Ask-(Point*TakeProfitIndex*mMultiply);
         		}
      
         		ticket = OrderSend(Symbol(),OP_SELL,Lots*mMultiply,Bid,3,0,0,"TurtleTrader(SELL)",MAGIC,3,Red);
			if(ticket > 0){
				if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
					OrderModify(OrderTicket(), OrderOpenPrice(), StopLossValue, TakeProfitValue, 3, Green);
				}
         			PrevDecision=Decision;
         			Print("Sell order is opened: ",OrderOpenPrice());
         		}else{
         			Print("Error opening SELL order:",GetLastError());
         			return(0);
         		}
         		return(0);
               
         	}
            
                    
         }
      
        
      }
  
   return(0);
}
//-------------------------------------------------------------------------
 
  
//+------------------------------------------------------------------+
//| Check Exist Order                                                |
//+------------------------------------------------------------------+
int FindSymbolOrder()
  {
   FoundOpenedOrder = false;
   total = OrdersTotal();
   for(cnt = 0; cnt < total; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

       if(OrderSymbol() == Symbol())
         {
           FoundOpenedOrder = True;
           break;
         }      
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Calculation of lot quantity                                          |
//+------------------------------------------------------------------+

int SetAutoLots()
  {
   GetMarketInfo();
   // Sum of the calculation
   double S;
   // Cost of the lot
  // double L;
   // Lot quantity
   //double k;
   // Cost of one pip
   if( AutoLots == true )
     {
       if(SymbolsCount != OrdersTotal())
         {
           S = (AccountBalance()* Risk - AccountMargin()) * AccountLeverage() / 
                (SymbolsCount - OrdersTotal());
         }
       else
         {
           S = 0;
         }
       // We check, does currency appear to be EURUSD?
       if(StringFind( Symbol(), "USD") == -1)
         {
           if(StringFind( Symbol(), "EUR") == -1)
             {
               S = 0;
             }
           else
             {
               S = S / iClose ("EURUSD", 0, 0);
               if(StringFind( Symbol(), "EUR") != 0)
                  {
                  S /= Bid;
                  }
             }
         }
       else
         {
           if(StringFind(Symbol(), "USD") != 0)
             {
               S /= Bid;
             }
         }
       S /= ModeLotSize;
       S -= ModeMinLot;
       S /= ModeLotStep;
       S = NormalizeDouble(S, 0);
       S *= ModeLotStep;
       S += ModeMinLot;
       Lots = S;
       if (Lots>MAXLots){ Lots=MAXLots; }
       
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| expert start function (Trading)                                 |
//+------------------------------------------------------------------+
int start()
  {
   
   if(Year()<2007){
      return(0);
   }
   GetMarketInfo();
   SetAutoLots();
   if(BeforeLoss<AccountBalance()){
      BeforeLoss=AccountBalance();
      mMultiply=1;
      
   }
   Trade();
   SaveStat();
   return(0);
  }