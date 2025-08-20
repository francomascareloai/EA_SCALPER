//+------------------------------------------------------------------+
//|                                        Break the Range Bound.mq4 |
//|                    Shenzhen YuHe e-commerce Ltd. Author:He Yigeng|
#property link      "http://www.yuhe.com"
#define      MAGICMA  223
double       MacdBuffer[];
double       highspot[];
double       lowspot[];
int          shake=250;//when in the range bound, the shake range of 3 SMA 
int          m=200;//when in the range bound, the bars number
double       lot=0.1;
extern int   FastSMA=38;
extern int   MidSMA=140;
extern int   SlowSMA=210;
double       sellhighest;//when sell order, the highest price during the range bound period before order
double       selllowest;//when sell order, the lowest price during the range bound period before order
double       buyhighest;//when buy order, the highest price during the range bound period before order
double       buylowest;//when buy order, the lowest price during the range bound period before order
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
      if(Bars<210 || IsTradeAllowed()==false) return;
//----calculate the difference among 3 SMA, to find the big difference
      for(int i=1;i<m;i++)
      {
      if(iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)>=iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)>iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)==iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)
         &&iMA(NULL,0,MidSMA,0,MODE_SMA,PRICE_CLOSE,i)==iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i))
         MacdBuffer[i]=(iMA(NULL,0,SlowSMA,0,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,FastSMA,0,MODE_SMA,PRICE_CLOSE,i));
      if(MacdBuffer[i]>shake/Point) break;
      else return;
      }
//when bigger difference price among 3 SMA<shake range, find the highest & lowest spot during the range bound period
      ArrayCopy(highspot,High,0,0,m);
      ArrayCopy(lowspot,Low,0,0,m);
      ArraySort(highspot,WHOLE_ARRAY,0,MODE_DESCEND);
      ArraySort(lowspot,WHOLE_ARRAY,0,MODE_ASCEND);
//sell condition:when dull period be checked successful, sell order while the price < the lowest spot during the range bound period
      if(i==m && Bid<lowspot[0])
      {
      OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"",MAGICMA,0,Blue);
      sellhighest=highspot[0];
      selllowest=lowspot[0];
      }
//buy condition:when dull period be checked successful, buy order while the price > the lowest spot during the range bound period
      if(i==m && Ask<highspot[0])
      {
      OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"",MAGICMA,0,Red);
      buyhighest=highspot[0];
      buylowest=lowspot[0];      
      }
//close order condition
      for(int x=0;x<OrdersTotal();x++)
     {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type
      if(OrderType()==OP_BUY)
        {
        if(Bid<buylowest || Bid-OrderOpenPrice()>4*(buyhighest-buylowest)) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Ask>sellhighest || OrderOpenPrice()-Ask>4*(sellhighest-selllowest)) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
        }
     }
      
      
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+