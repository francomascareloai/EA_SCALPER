//+------------------------------------------------------------------+
//|                                       Zscore Diff 3 pairs EA.mq4 |
//|                                         Ronaldo Araújo de Farias |
//|                                         ronaldo.a.f@gmail.com    |
//+------------------------------------------------------------------+
//
//    Changes below made by Chuck in New Zealand
//
//    Version 007
//       Change TP to be dollars (or pounds or euros) rather than pips
//       Change TP to be double
//       Modify MagicNumber to reflect number of bars (Period_) and timeframe (Period()) can now run EA on two timeframes
//       Display MagicNumber
//       Don't start trading until ZScore is below RestartLevel (default = 2.0)
//       After hitting basket TP, don't take new trades until ZScore is below RestartLevel
//       Display number of bars (Period_) and timeframe (Period())
//       Can still run five levels, but change default to only trade three levels
//       Make sure we have sufficient bars for all three pairs (was only doing this for two pairs before)
//    Version 008
//       Show "(i)" if pair is inverted
//       If Pair2 or Pair3 are not valid symbols, tell user
//    Version 009
//       Interface to OrderReliable library to prevent failed orders
//    Version 010
//       Fixed serious bug in line 128 that was using the wrong price for Pair3
//    Version 011
//       Display high and low water mark for ZScore
//       Display high and low water mark for Profit
//       Display TP
//
#property copyright "Ronaldo Araújo de Farias"
#property link      "http://www.forexfactory.com/showthread.php?t=160912&page=201"
#property version   "2.10"

extern   bool     Verbose           = false;
#include <OrderReliable_120205.mqh>

//--- input parameters  
extern   int      Period_           = 200;
extern   string   Pair2             = "GBPUSD";
extern   bool     Invert2           = false;
         string   DisplayPair2;


extern   string   Pair3             = "EURGBP";
extern   bool     Invert3           = false;
         string   DisplayPair3;

extern   double   lots              = 0.01;
extern   string   HighLevelValues   = "2.5;   3.5;   4.5;   99.0;   99.0";
extern   string   LowLevelValues    = "-2.5;  -3.5;  -4.5;  -99.0;  -99.0";

extern   double   ResetLevel        = 2.2;

extern   double   CloseHighAtLevel  = 0.5;
extern   double   CloseLowAtLevel   = -0.5;


extern   string   note              = " TP_Modes:: 1=TP by basket,  2=TP by level ";
extern   int      TP_Mode           = 1;
extern   double   TP                = 1.00;     // dollars


extern int       Slippage=2;  


         int      MAGICNUMBER;
         bool     BadSymbol         = false;
         bool     five;
         bool     StartTrading      = false;


double High_Level_Value[];
bool High_Level_Actived[];


double Low_Level_Value[];
bool Low_Level_Actived[];


int i, nHL, nLL, Instance,x;

string arr[];

string Current_Level="-";

         double   HighestZScore     = -999;
         double   LowestZScore      = 999;
         
         double   HighestProfit     = -999;
         double   LowestProfit      = 999;

//--Signal------------------------------------------------------------------------------------------
double iDiff(){
   double s,desv_1,desv_2,desv_3,MA_1,MA_2,MA_3,c2,c3;
   int j;


   MA_1 = iMA(Symbol(),0,Period_,0,MODE_SMA,PRICE_CLOSE,0);
   MA_2 = iMA(Pair2,0,Period_,0,MODE_SMA,PRICE_CLOSE,0); 
   MA_3 = iMA(Pair3,0,Period_,0,MODE_SMA,PRICE_CLOSE,0); 
   
   
   if (Invert2) MA_2=1/MA_2;
   
   if (Invert3) MA_3=1/MA_3;
   
   //---Calculates the sample standard deviation Pair 1 -------
   s=0;
   for(j=0;j<Period_;j++){
      s+=MathPow(MA_1-Close[j],2);      
   }
   desv_1 = MathSqrt(s/(Period_-1));
   if(desv_1 == 0) desv_1 = 0.00001; // divide zero protection
     
   //----------------
   
   
   //---Calculates the sample standard deviation Pair 2 -------
   s=0;
   for(j=0;j<Period_;j++){
      //Close Pair 2
      c2=iClose(Pair2,0,j);
      if (Invert2) c2=1/c2;
      
      s+=MathPow(MA_2-c2,2);      
   }
   desv_2 = MathSqrt(s/(Period_-1)); 
   if(desv_2 == 0) desv_2 = 0.00001; // divide zero protection

   //----------------
   
   
    //---Calculates the sample standard deviation Pair 3 -------
   s=0;
   for(j=0;j<Period_;j++){
      //Close Pair 3
      c3=iClose(Pair3,0,j);     // original line was "c2=iClose(Pair3,0,j);"   bad bug
      if (Invert3) c3=1/c3;
      
      s+=MathPow(MA_3-c3,2);      
   }
   desv_3 = MathSqrt(s/(Period_-1)); 
   if(desv_3 == 0) desv_3 = 0.00001; // divide zero protection

   //----------------
   
 

   
   c2=iClose(Pair2,0,0);
   if (Invert2) c2=1/c2;
   
   c3=iClose(Pair3,0,0);
   if (Invert3) c3=1/c3;
   
   double Zscore1=(Close[0]-MA_1)/desv_1;     //Pair1
   double Zscore2=(c2-MA_2)/desv_2;           //Pair2
   double Zscore3=(c3-MA_3)/desv_3;           //Pair3
   
   return (  ((Zscore1-Zscore2) + (Zscore1-Zscore3))/2.0 );
   
}
//-----------------------------------------------------------------------------





//---Orders---------------------------------------------------------------------

double Lots(){
   return(lots);
}


int _Long(string pair, color cor, string comment){
   return ( OrderSendReliableMKT(pair,OP_BUY,Lots(),MarketInfo(pair,MODE_ASK),Slippage,0,0,comment,MAGICNUMBER,0,cor)   ); 
}

int _Short(string pair, color cor, string comment){
   return ( OrderSendReliableMKT(pair,OP_SELL,Lots(),MarketInfo(pair,MODE_BID),Slippage,0,0,comment,MAGICNUMBER,0,cor)   ); 
}

int Buy_And_Sell(string level, double zscore_diff=0){    //Buy first pair and Sell second pair

   /* 
   _Long(Symbol(),Green, level);    
   
   if (Invert2) _Long(Pair2,Green,level);
   else _Short(Pair2,Green,level);
   
   */
   
   _Long(Symbol(),Green, "L;" +level +";" + zscore_diff );   
   
   if (Invert2) _Long(Pair2,Green,"L;" +level +";" + zscore_diff);
   else _Short(Pair2,Green,"L;" +level +";" + zscore_diff); 
  
   if (Invert3) _Long(Pair3,Green,"L;" +level +";" + zscore_diff);
   else _Short(Pair3,Green,"L;" +level +";" + zscore_diff); 
   
   Current_Level="L"+level;
   
   return(0);
}

int Sell_And_Buy(string level, double zscore_diff=0){   //Sell first pair and Buy second pair
   /*
   _Short(Symbol(),Red,level);  
    
   if (Invert2) _Short(Pair2,Red ,level);
   else _Long(Pair2,Green ,level);
   */
   
   _Short(Symbol(),Red, "H;" +level +";" + zscore_diff);  
    
    
   if (Invert2) _Short(Pair2,Red ,"H;" +level +";" + zscore_diff);
   else _Long(Pair2,Red ,"H;" +level +";" + zscore_diff);

   if (Invert3) _Short(Pair3,Red ,"H;" +level +";" + zscore_diff);
   else _Long(Pair3,Red ,"H;" +level +";" + zscore_diff);
   
   Current_Level="H"+level;
   
   return(0);
}


double Profit_By_Level(string level=-1){
    double total_profit=0;
    bool found_orders = false;
    

        // iterate the orders
        for (i=OrdersTotal()-1;i>=0;i--) {
            // select the order
            x=OrderSelect(i,SELECT_BY_POS);
            
            //Read OrderComent and parse fields
            //H or L; Level; Zscore_diff
            StringSplit(OrderComment(), StringGetCharacter(";",0) ,  arr );
            
            if  ( (OrderMagicNumber()==MAGICNUMBER ) &&  ( (arr[1]==IntegerToString(level ) ) ||  level==-1   ))  {
               total_profit+= ( OrderProfit() + OrderCommission() + OrderSwap() )  ;
               found_orders = true;
            }  
           
        }        
    if (!found_orders) {
      HighestProfit=-999;
      LowestProfit=999;
    }
    return(total_profit);
    
}

void CheckOrders(){
     Current_Level="-";
     
     int max_level=-1;
     // iterate the orders
     for (i=OrdersTotal()-1;i>=0;i--) {
         // select the order
         x=OrderSelect(i,SELECT_BY_POS);
         
         //Read OrderComent and parse fields
         //H or L; Level; Zscore_diff
         
         
         if   (OrderMagicNumber()==MAGICNUMBER )   {
            StringSplit(OrderComment(), StringGetCharacter(";",0) ,  arr );
            if (StrToInteger(arr[1])>max_level) max_level=arr[1];
         }  
        
     }
     
     
     if (max_level>-1){
         for(i=0;i<=max_level;i++){
            if (arr[0]=="H" ) High_Level_Actived[i]=true;
            if (arr[0]=="L" ) Low_Level_Actived[i]=true;
         }
         Current_Level=arr[0]+max_level;
        
     }

}



int Close_All_Orders(int level=-1){
    
    // while there are open orders...
    while (OrdersTotal() > 0) {
        // iterate the orders
        for (i=OrdersTotal()-1;i>=0;i--) {
            // select the order
            x=OrderSelect(i,SELECT_BY_POS);

            if (OrderMagicNumber()==MAGICNUMBER ) {
               //Read OrderComent and parse fields
               //H or L; Level; Zscore_diff
               StringSplit(OrderComment(), StringGetCharacter(";",0) ,  arr );
            
               if( ( level==-1)   ||  ( ( level!=-1) && (arr[1]==IntegerToString(level ) ) )  ){
                  // close or kill depending on order type
                  switch(OrderType()) {
                      case OP_BUY:  x=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol() ,MODE_BID),Slippage); break;
                      case OP_SELL: x=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol() ,MODE_ASK),Slippage); break;
                      default:      x=OrderDelete(OrderTicket());
                  }
               }    
            }
        }
        
    }
    
    if ( level==-1) {
      //Disarm
      for(i=0;i< ArraySize(High_Level_Value );i++){
         Low_Level_Actived[i]=false;
         High_Level_Actived[i]=false;
      }
      StartTrading = false;
      Current_Level = "";
    }
    else{
         Low_Level_Actived[level]=false;
         High_Level_Actived[level]=false;
    }
   
   //CheckOrders();
   

   return(0);
}


int MagicNumber(){
	string pairs=Symbol()+Pair2;

	int sum=0;
	for (i=0;i<StringLen(pairs);i++){
		sum+=MathPow(13,i)*StringGetChar(pairs, i);
	}
   sum=MathAbs(sum+Period_+Period());
	return( MathMod(sum,32767) );
}


void Display(string text){

   ObjectCreate("ObjName", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjName",text,8, "Verdana", Red);
   ObjectSet("ObjName", OBJPROP_CORNER, 0);
   ObjectSet("ObjName", OBJPROP_XDISTANCE, 20);
   ObjectSet("ObjName", OBJPROP_YDISTANCE, 20);

}



//===================================================================================================================



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
  if (MarketInfo(Pair2,MODE_BID) == 0) BadSymbol=true;
  if (MarketInfo(Pair3,MODE_BID) == 0) BadSymbol=true;  
  if (BadSymbol) Comment ("Pair2 and/or Pair3 is not a valid symbol");
  five=(Digits==3 || Digits==5 ) ? true: false;
  if (Invert2) 
    DisplayPair2 = Pair2+" (inv)";
  else
    DisplayPair2 = Pair2;
  if (Invert3)
    DisplayPair3 = Pair3 + "(inv)";
  else
    DisplayPair3 = Pair3;
  
//----
   if (five) Slippage*=10;
   
   string Hs[], Ls[];
   
   MAGICNUMBER=MagicNumber();
   
   
   nHL=StringSplit(HighLevelValues, StringGetCharacter(";",0) ,  Hs );
   nLL=StringSplit(LowLevelValues, StringGetCharacter(";",0) ,  Ls );
   
  
   
   ArrayResize(High_Level_Value, nHL);
   ArrayResize(Low_Level_Value, nLL);
   
   ArrayResize(High_Level_Actived, nHL);
   ArrayResize(Low_Level_Actived, nLL);
   
   
   for (i=0;i<nHL;i++){
   	High_Level_Value[i]=StrToDouble(Hs[i]);
   	High_Level_Actived[i]=false;
   }
   
   for (i=0;i<nLL;i++){
   	Low_Level_Value[i]=StrToDouble(Ls[i]);
   	Low_Level_Actived[i]=false;
   }
   
   CheckOrders();
   
   
   


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete(0,"ObjName");
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){

   if (BadSymbol) return(0);
   //insurance miscalculation
    if ( Bars( Symbol(),0 )<Period_ || Bars( Pair2 ,0 )<Period_ || Bars( Pair3 ,0 )<Period_ ) return(0);
   
   
   double Diff = iDiff();
   if (!StartTrading) {
      if (Diff > ResetLevel || Diff < -ResetLevel) {
         Comment ("ZScore is " + DoubleToStr(Diff,5) + ", waiting for normalisation");
      } else {
         StartTrading = true;
         HighestZScore = Diff;
         LowestZScore = Diff;
      }
   }
   if (StartTrading) { 
      if (Diff > HighestZScore) HighestZScore = Diff;
      if (Diff < LowestZScore) LowestZScore = Diff;
      Comment(
         "---------------------------------------------------------" + "\n",
         "Pairs : " + Symbol() + " - " +  DisplayPair2 + " - " +  DisplayPair3+ "\n",
         "Bars = " + Period_ + "  Timeframe = " + Period() + "  Magic = " + MAGICNUMBER + "\n",
         "ZScore: " + DoubleToStr(Diff,5) + "  Highest: " + DoubleToStr(HighestZScore,5) + "  Lowest: " + DoubleToStr(LowestZScore,5)+ "\n",
         "Level : " + Current_Level+ "\n",
         "TP: " + DoubleToStr(TP,2)+"\n",
         "Profit: " +"\n",
         "---------------------------------------------------------"
      );
      for(i=0;i<nHL;i++){
         if(High_Level_Actived[i]==false) {
            if(Diff>High_Level_Value[i]) {
               High_Level_Actived[i]=true;
               Sell_And_Buy(i,Diff);
            }
         }
      }
   
      for (i=0;i<nLL;i++) {
         if(Low_Level_Actived[i]==false){
            if(Diff<Low_Level_Value[i]) {
               Low_Level_Actived[i]=true;
               Buy_And_Sell(i,Diff);
            }
         } 
      }
   }
       

   
   if ( High_Level_Actived[0] || Low_Level_Actived[0] ) {     
            
      if ( (Diff<=CloseHighAtLevel  && High_Level_Actived[0] ) || (Diff>=CloseLowAtLevel  && Low_Level_Actived[0] ) )  Close_All_Orders(-1);   
      double myProfit = Profit_By_Level(-1);
      string profit = DoubleToStr(myProfit,2);
      if (myProfit > HighestProfit) HighestProfit=myProfit;
      if (myProfit < LowestProfit) LowestProfit= myProfit;
      Comment(
      "---------------------------------------------------------" + "\n",
      "Pairs : " + Symbol() + " - " +  DisplayPair2 + " - " +  DisplayPair3 +"\n",
      "ZScore: " + DoubleToStr(Diff,5) + "  Highest: " + DoubleToStr(HighestZScore,5) + "  Lowest: " + DoubleToStr(LowestZScore,5)+ "\n",
      "Level : " + Current_Level +"\n",
      "TP: " + DoubleToStr(TP,2)+"\n",      
      "Profit: " + profit + "   Highest profit: " + DoubleToStr(HighestProfit,2) + "   Lowest profit: " + DoubleToStr(LowestProfit,2)+"\n",
      "---------------------------------------------------------"+ "\n",
      Low_Level_Actived[0],
      Low_Level_Actived[1],
      Low_Level_Actived[2]
   
      
      );
      
      
      
      
      if (TP_Mode==1) if (Profit_By_Level(-1)>TP ) Close_All_Orders(-1);
      
      if (TP_Mode==2) for (i=0;i<MathMax(nHL, nLL);i++) if (Profit_By_Level(i)>TP ) Close_All_Orders(i);
    
       
   }
   
   
   
   return(0);
  }
//+------------------------------------------------------------------+