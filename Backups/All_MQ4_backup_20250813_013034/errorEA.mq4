//+------------------------------------------------------------------+
//|                                                errorEA.mq4
//|                        Copyright 2010, K Lam
//|                                        http://KKstore.com
//EURUSD at 1 june to 2 Oct 2010
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, K Lam"
#property link      "http://KKstore.com"

#define MAGICMA  20070424
#define Version  20101002
#define Flowing 6

int MagicKey[3] = {200704240,200704241,200704242};
string BoS[7] = {"OP_BUY","OP_SELL","OP_BUYLIMIT","OP_SELLLIMIT","OP_BUYSTOP","OP_SELLSTOP","Flowing"};

extern string Name_Expert= "errorEA";
extern string OWN="Copyright 2010, K LAM";

extern int MaxTrades=9;

extern bool RiskControl    = true;
extern int  MaxLot         = 3;
extern double  MiniLots    = 0.15;

extern int StopLoss=1000;//70;
extern int StopLevel=10; //normal high low Range! in 5 diagil

extern bool ScalpeControl   = true;
extern int ScalpeProfit=10;

double InitLots;
int slippage;

color ArrowsColorModify=Purple; //orders Modify color
color ArrowsColorUp=Aqua;       //orders UP color
color ArrowsColorDown=Red;      //orders DOWN color

string XSymbol = "GBPUSD";
string text1;
string text2;
string text3;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

//----
   return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{

   Working();
   XSymbol=Symbol();

   startBS(MagicKey[1]);
   startBS(MagicKey[2]);
}
//----end

int startBS(int MagicNoBS)
{
   int ttorder;
   int CountPend,CountPool;   
   int direction;
   double PowerRisk;
   
   //display Comment
   Comment(text1,text2,text3);
  
   if(ScalpeControl) ScalpelProfit(MagicNoBS);
   
   slippage=GetSlippage(XSymbol);
   
   //cal direct
   direction =Indicator();

   text1="XSymbol= "+Symbol()+"\n     Indicator="+BoS[Indicator()]+" slippage= "+slippage;

   ttorder= OrdersTotal();
   if(ttorder >= MaxTrades) {
      text2 = "\nMax Trade Reach !! "+ttorder+"--";
      return(0);
      }
      
   //Lot Size Check
   if(MaxLot > MarketInfo(XSymbol,MODE_MAXLOT))
      MaxLot=MarketInfo(XSymbol,MODE_MAXLOT);
      
   if(InitLots < MarketInfo(XSymbol,MODE_MINLOT))
      InitLots=MarketInfo(XSymbol,MODE_MINLOT);   

   //cal Lot size
   if(RiskControl) {
      PowerRisk=AccountBalance()/10000;
      if(PowerRisk < 1) PowerRisk=1;
      
      InitLots = MiniLots *PowerRisk;
      if(InitLots > MaxLot) InitLots = MaxLot;
      Print("RiskControl PowerRisk=",PowerRisk," InitLots=",InitLots);
      }
      
   //cal direct
   direction =Indicator();

   //Make Order         
   if(true) {
      if(direction ==OP_BUY && MagicNoBS ==MagicKey[1])
         MakeBuyOrder(InitLots);
      if(direction ==OP_SELL && MagicNoBS ==MagicKey[2])
         MakeSellOrder(InitLots);
      }
      
return(0);
}

// Function
double GetSlippage(string XSymbol)
{
   double bid   =MarketInfo(XSymbol,MODE_BID);
   double ask   =MarketInfo(XSymbol,MODE_ASK);
   double point =MarketInfo(XSymbol,MODE_POINT);
   return((ask-bid)/point);
}

void MakeBuyOrder(double InitLots)
{
   int ticketno;
   double TargetStopLoss;

   TargetStopLoss = Ask-Point*StopLoss; 

   ticketno=OrderSend(XSymbol,OP_BUY,InitLots,Ask,slippage,TargetStopLoss,0,Name_Expert+Version,MagicKey[1],0,ArrowsColorUp);
   if(ticketno == -1) {//error check
      if(GetLastError()==130)
         Print("error 130 Symbol= ",XSymbol," OP_BUY Lot =",InitLots," Ask =",Ask,
               " Slippage =",slippage," TargetStopLoss =",TargetStopLoss);
      }
}

void MakeSellOrder(double InitLots)
{
   int ticketno;
   double TargetStopLoss;
   TargetStopLoss = Bid+Point*StopLoss; 
   
   ticketno=OrderSend(XSymbol,OP_SELL,InitLots,Bid,slippage,TargetStopLoss,0,Name_Expert+Version,MagicKey[2],0,ArrowsColorDown);
   if(ticketno == -1) {//error check
      if(GetLastError()==130)
         Print("error 130 Symbol= ",XSymbol," OP_SELL Lot =",InitLots," Bid =",Bid,
               " Slippage =",slippage," TargetStopLoss =",TargetStopLoss);
      }
}

int Indicator()
{
   double Xobv1,Xobv2;

   Xobv1=iADX(NULL,0,14,PRICE_HIGH,MODE_PLUSDI,0);//MODE_MAIN
   Xobv1=iADX(NULL,0,14,PRICE_HIGH,MODE_MINUSDI,0); 

   if(Xobv1<Xobv2) return(OP_SELL);
   if(Xobv1>Xobv2) return(OP_BUY);
   return(Flowing);
}

int Working()
{
   if(!IsConnected()) Print("Server Not connection!");
   if(!IsTradeAllowed()) Print("Trade Not allowed");
   if(IsTradeContextBusy()) Print("Trade context is busy. another expert advisor Running");
   if(!IsDemo()) Print("I work at a Real account");
   
   return(0);
}

int ScalpelProfit(int MagicNo)
{
   bool  result=true;
   int cnt,err,ReOrderType;
   int TOrderOpenPrice,TCurrentStopLoss,TTargetStopLoss=0;
   
   double CurrentStopLoss,TargetStopLoss=0;
   double CurrentProfit,TargetProfit=0;
   
   double Calprofit;
   
   //Modify Set all Order at same sl tp Profit
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--) {//while(count>=0) { // while always delay much! do not use
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderSymbol() ==XSymbol && OrderMagicNumber() == MagicNo) {
         ReOrderType=OrderType();
         
         if(ReOrderType!=OP_BUY && ReOrderType!=OP_SELL) continue; //step out
         CurrentProfit=OrderTakeProfit();
         
         if(ReOrderType==OP_BUY) {
            TargetProfit = NormalizeDouble(OrderOpenPrice()+ScalpeProfit*Point, Digits);
            if(CurrentProfit== TargetProfit) continue; //step out

            //need add mini point get profit!
            result=OrderModify(OrderTicket(),OrderOpenPrice(),
            OrderStopLoss(),NormalizeDouble(OrderOpenPrice()+ScalpeProfit*Point, Digits),
            0,ArrowsColorModify);
                  
                  text3 = "\nScalpe Set OP_BUY Order Ticket="+DoubleToStr(OrderTicket(),0)
                  +" modified. CurrentStopLoss="+DoubleToStr(TCurrentStopLoss,0)
                  +" to  TargetStopLoss="+DoubleToStr(TTargetStopLoss,0);

            }
               
         if(ReOrderType==OP_SELL) {
            TargetProfit = NormalizeDouble(OrderOpenPrice()-ScalpeProfit*Point, Digits);
            if(CurrentProfit== TargetProfit) continue; //step out

            result=OrderModify(OrderTicket(),OrderOpenPrice(),
            OrderStopLoss(),NormalizeDouble(OrderOpenPrice()-ScalpeProfit*Point, Digits),
            0,ArrowsColorModify);
                  
                  text3 = "\n OP_SELL Order Ticket="+DoubleToStr(OrderTicket(),0)
                  +" modified. CurrentStopLoss="+DoubleToStr(TCurrentStopLoss,0)
                  +" to  TargetStopLoss="+DoubleToStr(TTargetStopLoss,0);

            }
            
            if(!result) {
               err=GetLastError();            
               Print("LastError = ",err," StopLoss=",TargetStopLoss);//return(false);
               if(err==130) StopLevel++;
                //130 Invalid stops. //136 Off quotes. // 135 Price changed.
               if(StopLevel > 25) Print("StopLevel Error = ",err," StopLevel > 25, DO NOT RUN at ",XSymbol ,"Pair... StopLoss=",TargetStopLoss);//return(false);
               }
      }//OrderMagicNumber() == MagicNo
   }//for(

   return(true);

}
//------------------------------End

