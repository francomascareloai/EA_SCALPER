//+------------------------------------------------------------------+
//|                                         Tight Trailing Stops.mq4 |
//|                                                      Nicholishen |
//|                                              www.tradingintl.com |
//+------------------------------------------------------------------+
#property copyright "Nicholishen"
#property link      "www.tradingintl.com"

#define OrderID 1928378
   
   extern bool UseTightStop=false;
   extern int ScalpPips=3;
   extern bool UseTrailing    = false; 
   
   extern double  TrailingAct   = 6;    
   extern double  TrailingStep   = 3; 
   int TrailPrice;
   
void TrailingPositions() {
  for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderMagicNumber()==OrderID ) {
         if (OrderType()==OP_SELL) {
            if (OrderOpenPrice()-Ask>TrailingAct*Point && TrailPrice ==0) {
               TrailPrice=Ask+TrailingStep*Point;
               Print("TRAIL PRICE SET: ",TrailPrice);
               if(TrailingStep > 8){
                  ModifyStopLoss(TrailPrice);
               }
            }
            if (TrailPrice!=0 && Ask+TrailingStep*Point < TrailPrice  ){
               TrailPrice=Ask-TrailingStep*Point;
               Print("TRAIL PRICE MODIFIED: ",TrailPrice);
               if(TrailingStep > 8){
                  ModifyStopLoss(TrailPrice);
               }
            }
            if (TrailPrice != 0 && Ask >= TrailPrice ){
               CloseOrder(2);
            }
         }
         if (OrderType()==OP_BUY) {
            if (Bid-OrderOpenPrice() > TrailingAct*Point && TrailPrice ==0) {
               TrailPrice=Bid-TrailingStep*Point;
               Print("TRAIL PRICE MODIFIED: ",TrailPrice);
               if(TrailingStep > 8){
                  ModifyStopLoss(TrailPrice);
               }
            }
            if (TrailPrice!= 0 && Bid-TrailingStep*Point > TrailPrice ){
               TrailPrice=Bid-TrailingStep*Point;
               Print("TRAIL PRICE MODIFIED: ",TrailPrice);
               if(TrailingStep > 8){
                  ModifyStopLoss(TrailPrice);
               }
            }
            if (TrailPrice != 0 && Bid <= TrailPrice ){
               CloseOrder(1);
            }   
         }
      }
   }
}
}

void CloseOrder(int ord){
    for(int i=0;i<OrdersTotal();i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);    
      if (OrderType()==OP_BUY && OrderMagicNumber()==OrderID){
         if (ord==1){
         int res = OrderClose(OrderTicket(),OrderLots(),Bid,3,White); // close 
         TrailPrice=0;
         if(res<0){
            int error=GetLastError();
            //Print("Error = ",ErrorDescription(error));
         }
      }}     
      
      if (OrderType()==OP_SELL && OrderMagicNumber()==OrderID ){
         if (ord==2) {                          // MA BUY signals
            res = OrderClose(OrderTicket(),OrderLots(),Ask,3,White); // close 
            TrailPrice=0;
            if(res<0){
               error=GetLastError();
              // Print("Error = ",ErrorDescription(error));
            }
         }     
      }  
   }    
 }  
void Scalp(){
double res;int error;
   for(int i=0;i<OrdersTotal();i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==OrderID ){
         if(OrderType()==OP_BUY){
            if(Bid - OrderOpenPrice() >= ScalpPips*Point){
               res = OrderClose(OrderTicket(),OrderLots(),Bid,3,White); // close 
               TrailPrice=0;
               if(res<0){
                  error=GetLastError();
                 // Print("Error = ",ErrorDescription(error));
               }
            }
         }
         if(OrderType()==OP_SELL){
            if(OrderOpenPrice() - Ask >= ScalpPips*Point){
               res = OrderClose(OrderTicket(),OrderLots(),Ask,3,White); // close 
               TrailPrice=0;
               if(res<0){
                  error=GetLastError();
                 // Print("Error = ",ErrorDescription(error));
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
// Order Modify function
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStop) {
  bool   fm;
  double ldOpen=OrderOpenPrice();
  double ldTake=OrderTakeProfit();

  fm=OrderModify(OrderTicket(), ldOpen, ldStop, ldTake, 0, Pink);
  
}
int start()
  {
   if(UseTrailing)TrailingPositions();
   if(UseTightStop)Scalp();
   
   return(0);
  }
//+------------------------------------------------------------------+