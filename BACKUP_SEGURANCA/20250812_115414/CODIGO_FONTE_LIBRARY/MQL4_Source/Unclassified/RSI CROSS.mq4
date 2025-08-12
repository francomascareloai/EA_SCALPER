//+------------------------------------------------------------------+
//|                                                    RSI CROSS.mq4 |
//|                                                            Jacob Y |
//|                                                                  |
//+------------------------------------------------------------------+
//---- input parameters

double RSICURR,RSIPREV;
//+------------------------------------------------------------------+
//| expert initialization function |
//+------------------------------------------------------------------+
int start()
{
RSICURR=iRSI(NULL,0,14,PRICE_CLOSE,0);
RSIPREV=iRSI(NULL,0,14,PRICE_CLOSE,0);

if (RSICURR>RSIPREV && RSICURR>70)
{

{Alert(" CrossUP",Symbol());
}
if (RSIPREV>RSICURR && RSICURR<30)
{

{Alert("CrossDOWN",Symbol());
}

   }
  }
 }
return (0);

