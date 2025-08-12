//+------------------------------------------------------------------+
//|                                           ARRAY OUT OF RANGE.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mutiiriallan.forex@gmail.com."
#property link      "mutiiriallan.forex@gmail.com"
#property description "Incase of anything with this Version of EA, Contact:\n"
                      "\nEMAIL: mutiiriallan.forex@gmail.com"
                      "\nWhatsApp: +254 782 526088"
                      "\nTelegram: https://t.me/Forex_Algo_Trader"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   // STATIC AND DYNAMIC ARRAYS
   //--- STATIC ARRAYS
   
   double staticArray1[3] = {1.1,1.2,1.3}; // 0, 1, 2
   Print("SIZE OF THE STATIC ARRAY 1 = ",ArraySize(staticArray1));
   ArrayPrint(staticArray1,1," , ");
   double price_value = staticArray1[1];
   Print(price_value);
   
   double staticArray2[3];
   Print("SIZE OF THE STATIC ARRAY 2 = ",ArraySize(staticArray2));
   Print("STATIC ARRAY 2 BEFORE FILLING");
   ArrayPrint(staticArray2,1," , ");
   staticArray2[0] = 1.1;
   staticArray2[1] = 1.2;
   staticArray2[2] = 1.3;
   
   //staticArray2[3] = 1.4;
   Print("STATIC ARRAY 2 AFTER FILLING");
   ArrayPrint(staticArray2,1," , ");
   //Print(staticArray2[3]);
   //ArrayResize(staticArray2,7);
   //Print("STATIC ARRAY 2 SIZE = ",ArraySize(staticArray2));
   
   //--- DYNAMIC ARRAYS
   
   double dynamicArray1[] = {1.1,1.2,1.3,6};
   Print("\nSIZE OF THE DYNAMIC ARRAY 1 = ",ArraySize(dynamicArray1));
   ArrayPrint(dynamicArray1,1," , ");
   //Print(dynamicArray1[4]);
   
   double dynamicArray2[];
   Print("SIZE OF THE DYNAMIC ARRAY 2 = ",ArraySize(dynamicArray2));
   Print("DYNAMIC ARRAY 2 BEFORE FILLING");
   ArrayPrint(dynamicArray2,1," , ");
   ArrayResize(dynamicArray2,3);// WE HAVE TO RESIZE BEFORE FILLING
   Print("new size = ",ArraySize(dynamicArray2));
   dynamicArray2[0] = 1.1;
   dynamicArray2[1] = 1.2;
   dynamicArray2[2] = 1.3;
   Print("DYNAMIC ARRAY 2 AFTER FILLING");
   ArrayPrint(dynamicArray2,1," , ");
   ArrayResize(dynamicArray2,ArraySize(dynamicArray2)+1);
   Print("new size ADDED = ",ArraySize(dynamicArray2));
   dynamicArray2[ArraySize(dynamicArray2)-1] = 7.7;
   Print("final data");
   ArrayPrint(dynamicArray2,1," , ");
   
   //--- PRINTING IN A FOR LOOP
   Print("\nOur Data size = ",ArraySize(staticArray1)); // 3
   ArrayPrint(staticArray1,1," , "); // 1.1, 1.2, 1.3
   
   for (int i = 0; i<ArraySize(staticArray1); i++){ //fix < or negate 1 from the limit
      Print("Iteration: ",i+1," when index i = ",i);
      Print(i," = ",staticArray1[i]);
   }
   
   for (int i = ArraySize(staticArray1)-1; i>=0; i--){ //fix negate 1
      Print("Iteration: ",i+1," when index i = ",i);
      Print(i," = ",staticArray1[i]);
   }
   
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
