//+------------------------------------------------------------------+
//|                                                        ASC++.mq4 |
//|                                  Copyright © 2005, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Forex-Experts"
#property link      "http://www.forex-experts.com"

//---- input parameters

extern double Lots = 0.10;
extern int TakeProfit = 100;
extern int StopLoss = 40;
extern int TrailingStop = 20;

extern int  Risk=3;
extern int  EntryStopLevel=10;
extern int  EntryRange=27;
extern int  TSLevel1=30;
extern int  TSLevel2=60;
extern int  SigValMin=5;
extern int  Slippage=3;    // Sllipage



double value2=0, value3=0, x1=70, x2=30;
double TrueCount=0,Range=0, AvgRange=0, MRO1=0, MRO2=0;
double val1=0, val2=0,t0=0,TradesOnSymbol=0;
double AvgRange3=0,price2=0,value30=0,dK2=0;
double V1=0,V2=0,P1=9,n1=9,n2=49,V3=0,V4=0,P2=54,wprfast=0,wprslow=0,cnt=0;
double value=0,price=0,dK=0, AvgRange2=0,WATR=0,AveragePeriod=10,Reg=1;
double ESLevel=0,vartime=0,SigValBuy=0,SigValSell=0,SigValBuy1=0,SigValSell1=0,timecntsell=0,timecntbuy=0,sl=0;
double nrtrr[10],nrtrg[10],nrtrwatrr[10],nrtrwatrg[10],ascsigbuy[30],ascsigsell[30],Table_value2[50];
int    i=0,StartBars=1,bar=0,trend=0,trend2=0,shift=0,Counter=0,i1=0,cnt1=0,value10=10,value11=0;

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
//---- 
//t0 = StrToTime("2000.01.01 0:00");
//if (CurTime()>t0){
value10=3+Risk*2;
x1=67+Risk;
x2=33-Risk;
value11=value10;


//--------------------------------------------------------------------------------------------------------------------
       wprfast=0;
       wprslow=0;

       V1=iWPR(NULL,0,P1,cnt)*iWPR(NULL,0,P1,0)/100;
       V2=MathCeil(V1);
       if (V2<n1)  wprfast=V2;
	    if (V2>n2)  wprfast=-(V2);
	   
	   V3=iWPR(NULL,0,P2,cnt)*iWPR(NULL,0,P2,0)/100;
       V4=MathCeil(V3);
       if (V4<n1)  wprslow=V4;
	    if (V4>n2)  wprslow=-(V4);

//----------------------------------------------------------------------------------------------------------------------

AvgRange2=0;
for (i=AveragePeriod;i>=1; i--) {
       dK = 1+(AveragePeriod-i)/AveragePeriod;
       AvgRange2=AvgRange2+ dK*MathAbs(High[i]-Low[i]);
       }
WATR = AvgRange2/AveragePeriod;

if (Close[StartBars-1] > Open[StartBars-1]) {
   value = Close[StartBars - 1] * (1 - WATR);
   trend = 1;
   nrtrwatrg[0]= value;
   nrtrwatrr[0]= 0;
   }

if (Close[StartBars-1] < Open[StartBars-1]) {
   value = Close[StartBars - 1] * (1 + WATR);
   trend = -1;
   nrtrwatrr[0]= value;
   nrtrwatrg[0]= 0;
   }


for (bar=50;bar>=0; bar--) {
     
    if (trend >= 0)  {
       if (Close[bar] > price)  price = Close[bar];
       value = price * (1 - WATR);
       if (Close[bar] < value)  {
          price = Close[bar];
          value = price * (1 + WATR);
          trend = -1;
          }
       }
    else
    if (trend <= 0) {
       if (Close[bar] < price)  price = Close[bar];
       value = price * (1 + WATR);
       if (Close[bar] > value) {
          price = Close[bar];
          value = price * (1 - WATR);
          trend = 1;
          }
       }
    
if (trend == -1) {
       nrtrwatrr[bar]= value;
       nrtrwatrg[bar]= 0;
       }
if (trend ==  1) {
       nrtrwatrg[bar]= value;
       nrtrwatrr[bar]= 0;
       }
} 

//----------------------------------------------------------------------------------------------------

AvgRange3=0;
for (i=1; i<=AveragePeriod; i++) {
    AvgRange3=AvgRange3 + MathAbs(High[i]-Low[i]);
    }
dK2 = AvgRange3/AveragePeriod;

if (Close[0] > Open[0]) {
   value30 = Close[0] * (1 - dK2);
   trend2 = 1;
   nrtrg[0]= value30;
   nrtrr[0]=0;
   }
if (Close[0] < Open[0]) {
   value30 = Close[0] * (1 + dK2);
   trend2 = -1;
   nrtrr[0]=value30;
   nrtrg[0]=0;
   }
for (bar = 50; bar>=0; bar--) {
    if (trend2 >= 0){
       if (Close[bar] > price2) price2 = Close[bar];
       value30 = price2 * (1 - dK2);
       if (Close[bar] < value30) {
          price2 = Close[bar];
          value30 = price2 * (1 + dK2);
          trend2 = -1;
          }
       } 
    else 
    if (trend2 <= 0) {
       if (Close[bar] < price2) price2 = Close[bar];
       value30 = price2 * (1 + dK2);
       if (Close[bar] > value30) {
          price2 = Close[bar];
          value30 = price2 * (1 - dK2);
          trend2 = 1;
          }
       }
if (trend2 == -1) {
       nrtrr[bar]= value30;
       nrtrg[bar]= 0;
       }
if (trend2 ==  1) {
       nrtrg[bar]= value30;
       nrtrr[bar]= 0;
       }
} 

//----------------------------------------------------------------------------------------------------	
//ArrayInitialize(Table_value2,0);

//ArrayInitialize(ascsigbuy,0);
//ArrayInitialize(ascsigsell,0);

for (shift=30; shift>=0; shift--) {
//   Table_value2[shift,1]=0;
//	Table_value2[shift,2]=0;
//   ascsigbuy[shift]=0;
//   ascsigsell[shift]=0;          
   Counter=shift;
	Range=0.0;
	AvgRange=0.0;
	for (Counter=shift; Counter<=shift+9; Counter++) AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]);
		
	Range=AvgRange/10;
	Counter=shift;
	TrueCount=0;
	while (Counter<shift+9 && TrueCount<1)
		{if (MathAbs(Open[Counter]-Close[Counter+1])>=Range*2.0) TrueCount=TrueCount+1;
		Counter=Counter+1;
		}
	if (TrueCount>=1) {MRO1=Counter;} else {MRO1=-1;}
	Counter=shift;
	TrueCount=0;
	while (Counter<shift+6 && TrueCount<1)
		{if (MathAbs(Close[Counter+3]-Close[Counter])>=Range*4.6) TrueCount=TrueCount+1;
		Counter=Counter+1;
		}
	if (TrueCount>=1) {MRO2=Counter;} else {MRO2=-1;}
	if (MRO1>-1) {value11=3;} else {value11=value10;}
	if (MRO2>-1) {value11=4;} else {value11=value10;}
	value2=100-MathAbs(iWPR(NULL,0,value11,shift)); // PercentR(value11=9)
	
	Table_value2[shift]=value2;

	value3=0;

	if (value2<x2)
		{i1=1;
		while (Table_value2[shift+i1]>=x2 && Table_value2[shift+i1]<=x1){i1++;}
		if (Table_value2[shift+i1]>x1) 
			{
			value3=High[shift]+Range*0.5;
			val1=value3;
         		
			val2=0;
			} 
		}
	if (value2>x1)
		{i1=1;
		while (Table_value2[shift+i1]>=x2 && Table_value2[shift+i1]<=x1){i1++;}
		if (Table_value2[shift+i1]<x2) 
			{
			value3=Low[shift]-Range*0.5;
			val2=value3;

			val1=0;
			}
		}

ascsigsell[shift]=val1;
ascsigbuy[shift]=val2;	
       

}



if (ascsigsell[1]>0 && ascsigsell[0]>0)
  {
   SigValSell=Period();
   timecntbuy=0;
   SigValBuy=0;
   }
if (ascsigbuy[1]>0 && ascsigsell[0]>0){ 
    timecntbuy=0;
    SigValBuy=0;
    if (timecntsell!=Minute())
		  {
		   SigValSell=SigValSell+1;
		   timecntsell=Minute();
		  }
  }

if (ascsigbuy[1]>0 && ascsigbuy[0]>0) 
   {
   SigValBuy=Period();
   timecntsell=0;
   SigValSell=0;
   } 
if (ascsigsell[1]>0 && ascsigbuy[0]>0)
  {
  timecntsell=0;
  SigValSell=0;
  if (timecntbuy!=Minute())
		  {
		   SigValBuy=SigValBuy+1;
		   timecntbuy=Minute();
		  }
  }

//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
                
Comment("ascbuy: ",ascsigbuy[0],"  ","buysigval: ",SigValBuy,"\n",
"ascsell: ",ascsigsell[0],"  ","sellsigval: ",SigValSell,"\n",
"nrtrwatrg[0]: ",nrtrwatrg[0],"  ","nrtrg[0]: ",nrtrg[0],"\n",
"nrtrwatrg[1]: ",nrtrwatrg[1],"  ","nrtrg[1]: ",nrtrg[1],"\n",
"nrtrwatrr[0]: ",nrtrwatrr[0],"  ","nrtrr[0]: ",nrtrr[0],"\n",
"nrtrwatrr[1]: ",nrtrwatrr[1],"  ","nrtrr[1]: ",nrtrr[1],"\n",
"wprfast: ",wprfast,"  ","wprslow :",wprslow,"\n",
"Range: ",NormalizeDouble(Range/Point,0));


//----------------------------------------------------------------------------------------------------------


TradesOnSymbol=0;


for(cnt1=0;cnt1<OrdersTotal();cnt1++)
{
   OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);


    if ((OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP ||
        OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYLIMIT ||
        OrderType()==OP_BUY || OrderType()==OP_SELL) &&  
        OrderSymbol()==Symbol()) { TradesOnSymbol=TradesOnSymbol+1;}
}

if (TradesOnSymbol==0) {

//BuySetup-----------------------------------------------------------------------------------------------

if (ascsigbuy[0]!=0)  {
  if (wprfast>0)  {
    if (wprslow>=0)   {
      if (Range<EntryRange*Point && Table_value2[0]>x1 && SigValBuy>SigValMin)  {
        if (nrtrwatrg[0]>0 || Ask>nrtrwatrr[0])  {
        if (nrtrwatrg[1]==0)  sl=ascsigbuy[0]; else sl = nrtrwatrg[1];  
		OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+EntryStopLevel*Point,Slippage,sl,Ask+EntryStopLevel*Point+TakeProfit*Point,"ASC++",16384,0,Lime);
		vartime=TimeHour(Time[0]);
		return(0);
		}
      }
    }
  }
}
   
//SellSetup-----------------------------------------------------------------------------------   
   
if (ascsigsell[0]!=0)  {
  if (wprfast<0)  {
    if (wprslow<=0)   {
      if (Range<EntryRange*Point && Table_value2[0]<x2 && SigValSell>SigValMin)  {
        if (nrtrwatrr[0]>0 || Bid<nrtrwatrg[0])  {
        if (nrtrwatrr[1]==0)  sl =ascsigsell[0]; else sl = nrtrwatrr[1];  
    
        OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-EntryStopLevel*Point,Slippage,sl,Bid-EntryStopLevel*Point-TakeProfit*Point,"ASC++",16384,0,Red);
        vartime=TimeHour(Time[0]);
        return(0);
      	}
      }
    }
  }
}




}

//Trademanagment-------------------------------------------------------------------------------   
for(i=0;i<OrdersTotal();i++)
{
   OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
  
    if (OrderSymbol()==Symbol()) {
    
    if (ascsigbuy[0]!=0) {
      if (wprfast>0)  {
        
        if (OrderType()==OP_SELLSTOP)  {
			OrderDelete(OrderTicket());
			return(0);
			}
        if (OrderType()==OP_SELL)  {
                OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
                return(0);
                }
         }
       }

    if (ascsigsell[0]!=0)  {
      if (wprfast<0)  {
      
   		if (OrderType()==OP_BUYSTOP)  {
   			OrderDelete(OrderTicket());
   			return(0);
   			}
   			if (OrderType()==OP_BUY)  {
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Lime);
            return(0); 
            }
         
   	  }
   	}
  
 if (OrderType()==OP_BUYSTOP) 
   {
    if (TimeHour(Time[0])!= vartime) 
      {
       if (High[2]>High[1]) 
         {
          OrderModify(OrderTicket(),OrderOpenPrice()-(High[2]-High[1]),OrderStopLoss(),OrderTakeProfit(),Red);
          vartime=TimeHour(Time[0]);
         }
      }
   }
   
  
  if (OrderType()==OP_SELLSTOP)
   {
    if (TimeHour(Time[0])!= vartime)
      {
       if (Low[2]<Low[1] )
         {
          OrderModify(OrderTicket(),OrderOpenPrice()+(Low[1]-Low[2]),OrderStopLoss(),OrderTakeProfit(),Red);        
          vartime=TimeHour(Time[0]);
         }
      }
   }
  
 
  
  
  if (OrderType()==OP_BUY)
    {
    if (OrderStopLoss()<nrtrwatrg[1])
	    {
        OrderModify(OrderTicket(),OrderOpenPrice(),nrtrwatrg[1],OrderTakeProfit(),Red);                    
       }
    }
 	
  if (OrderType()==OP_SELL)
     {
     if (OrderStopLoss()>nrtrwatrr[1]) 
	      {
     	    OrderModify(OrderTicket(),OrderOpenPrice(),nrtrwatrr[1],OrderTakeProfit(),Red);                    	  
 		   }
      
      }
  
   
  if (OrderType()==OP_BUY)
    {
    if ((Bid-OrderOpenPrice())>(Point*TSLevel1) && (Bid-OrderOpenPrice())<(Point*TSLevel2))
    {
    if (OrderStopLoss()<nrtrwatrg[1]) 
	   {
       OrderModify(OrderTicket(),OrderOpenPrice(),nrtrwatrg[1],OrderTakeProfit(),Red);
      }
    } 
 	}
 	
  if (OrderType()==OP_SELL)
     {
     if ((OrderOpenPrice()-Ask)>(Point*TSLevel1) && (OrderOpenPrice()-Ask)<(Point*TSLevel2))
      {
      if (OrderStopLoss()>nrtrwatrr[1])
	      {
          OrderModify(OrderTicket(),OrderOpenPrice(),nrtrwatrr[1],OrderTakeProfit(),Red);  	  
 		   }
       }
      } 
      
         
  if (OrderType()==OP_BUY)    
    {
    if ((Bid-OrderOpenPrice())>(Point*TSLevel2)) 
    {
    if (OrderStopLoss()<nrtrg[1])
	   {
       OrderModify(OrderTicket(),OrderOpenPrice(),nrtrg[1],OrderTakeProfit(),Red);  	  
      }
    } 
 	}
 	
  if (OrderType()==OP_SELL)    
     {
     if ((OrderOpenPrice()-Ask)>=(Point*TSLevel2)) 
      {
      if (OrderStopLoss()>nrtrr[1])
	      {
     	    OrderModify(OrderTicket(),OrderOpenPrice(),nrtrr[1],OrderTakeProfit(),Red);  	  
 		   }
       }
      }
  }
}






//}   
//----
   return(0);
  }
//+------------------------------------------------------------------+