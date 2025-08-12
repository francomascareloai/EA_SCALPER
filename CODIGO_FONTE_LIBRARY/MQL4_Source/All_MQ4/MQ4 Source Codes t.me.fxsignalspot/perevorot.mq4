extern int sl=35;
extern int tp=80;
extern int Porog=12;
extern int WorkBar=0;
extern int TimePeriod=5;
       int TP;
int start()
  {
   switch (TimePeriod)
    {
     case 1:TP=1;
            break;
     case 2:TP=5;
            break;
     case 3:TP=15;
            break;
     case 4:TP=30;
            break;
     case 5:TP=60;
            break;
     case 6:TP=240;
            break;
     case 7:TP=1440;
            break;
     case 8:TP=10080;
            break;
     case 9:TP=43200;
            break;
     default:TP=0;
             break;
    }
   int orders=OrdersTotal();
   if (orders<1) {
   if (Ask-Point-iOpen(NULL,TP,0)>Porog*Point)
//         OrderSend(Symbol(),OP_BUY,0.1,Ask,1,Ask-sl*Point,Ask+tp*Point,"",0,0); // было
         OrderSend(Symbol(),OP_SELL,0.1,Bid,1,Ask+tp*Point+(Ask-Bid),Ask-sl*Point+(Ask-Bid),"",0,0);
    if (iOpen(NULL,TP,0)-Bid>Porog*Point)
//         OrderSend(Symbol(),OP_SELL,0.1,Bid,1,Bid+sl*Point,Bid-tp*Point,"",0,0); // было
         OrderSend(Symbol(),OP_BUY,0.1,Ask,1,Bid-tp*Point-(Ask-Bid),Bid+sl*Point-(Ask-Bid),"",0,0);
   }
   return(0);
}