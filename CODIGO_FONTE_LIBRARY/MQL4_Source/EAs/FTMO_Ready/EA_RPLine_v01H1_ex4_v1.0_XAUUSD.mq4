//+------------------------------------------------------------------+
//|                                                  WPRLok01Exp.mq4 |
//|                          Copyright © 2006, HomeSoft-Tartan Corp. |
//|                                              spiky@transkeino.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, HomeSoft-Tartan Corp."
#property link      "spiky@transkeino.ru"//PRofit from 01.06.2006 to 15.09.2006 - 5000$ 

extern double Lots = 0.1;
extern double StopLoss = 1000;
extern double TakeProfit = 80;
extern double TrailingStop = 0;
extern double MagicNumber = 123456;

extern double depo = 10000;
extern double dper = 24;
extern double risk = 1;
extern double stop = 300;
extern double hsum = -50;
extern double lsum = 50;

double mlot = 0;
double s = 0;
double b = 0;
double summa = 0;
double bsum = 0;
double ssum = 0;
double pros = 0;
double rpone = 0;
double rpnul = 0;
double FreeMargin = 0; 
double prof = 0;
double MinL = 0;
double MaxH = 0;
double rprof = 0;
double spr = 0;
double bpr = 0;
double hspr = 0;
double hbpr = 0;
double kh = 3; 

string dw = "";
string AN = "";
bool   ft = true;

int DWeek;
int STime,SMinut,PTime;
int cnt,j,ns,nb;
int blok=1;
int hblok;
int plb;
int pls;
int pl;
int sig,ssig,bsig,hbsig,hssig;
int ttr;
int number;
int tiket;

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

 if (Bars<150) return(0);
 
 number=AccountNumber();

 DWeek=DayOfWeek(); 

 STime=Hour();
 SMinut=Minute();
 j=j+1; if (SMinut==0) j=0; 
 
 FreeMargin = AccountFreeMargin(); 
 
 MaxH=0;MinL=1000;
 
 for (cnt=1;cnt<=dper;cnt++)
 {
  if(MaxH<High[cnt]) MaxH=High[cnt];
  if(MinL>Low[cnt]) MinL=Low[cnt];
 }
 
  if (STime==0 || ft) { ObjectDelete("MaxH");ObjectDelete("MinL"); 
 
     ObjectCreate("MaxH", 1, 0, Time[20], MaxH, 0, MaxH, 0, 0);
     ObjectSet("MaxH", OBJPROP_COLOR, Magenta);
     ObjectSet("MaxH", OBJPROP_STYLE, 2);
 
     ObjectCreate("MinL", 1, 0, Time[20], MinL, 0, MinL, 0, 0);
     ObjectSet("MinL", OBJPROP_COLOR, Gold);
     ObjectSet("MinL", OBJPROP_STYLE, 2); ft=false; }
 
    mlot = MathRound(FreeMargin/depo)*Lots; 
    mlot = NormalizeDouble(mlot,1);
 if (mlot>5) mlot=5;
 if (mlot<=0.3) kh=10;
 if (mlot>=0.4) kh=5;
 if (mlot>=1) kh=3; 

  rpone=iCustom(NULL,0,"RoundPriceExp",0,1);  
  rpnul=iCustom(NULL,0,"RoundPriceExp",0,0);  
 
//  ccione=iCCI(NULL,0,21,Close[0],1);ccione=MathRound(ccione);
//  ccinul=iCCI(NULL,0,21,Close[0],0);ccinul=MathRound(ccinul);

 s=0;b=0;summa=0;bsum=0;ssum=0;
 ttr=OrdersTotal()-1;
 for(cnt=ttr;cnt>=0;cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
 if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
  { 
    ssum=ssum+OrderProfit()+OrderSwap();s=s+1;    
  } 
 if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
  { 
    bsum=bsum+OrderProfit()+OrderSwap();b=b+1;    
  }
 } 
 
  bsum=MathRound(bsum);
  ssum=MathRound(ssum);
  summa=ssum+bsum;
  
  if (s+b<2) sig=1; else sig=0;
  if (s+b==2 && hblok==1) sig=1;

  if ( summa<0 && pros>summa ) pros=summa;
  
  if (hblok==0) {hspr=0;hbpr=0;}
 
  if (s+b==0) 
  { 
      plb=0;pls=0;pl=0;prof=0;hblok=0;pros=0;rprof=0;spr=0;bpr=0;hbpr=0;hspr=0;ns=0;nb=0;
  }

  
  if ( sig==1 && rpone>rpnul && rpone>Close[0] && rpnul>Close[4] ) {blok=0;ssig=1;} else ssig=0;
  if ( sig==1 && rpone<rpnul && rpone<Close[0] && rpnul<Close[4] ) {blok=0;bsig=1;} else bsig=0; 
  
  if ((s==0 || b==0) && hblok==0) blok=0;
  
  rprof=summa+prof;
  FreeMargin=MathRound(FreeMargin);
  
  Comment("Account ¹ = ",number,"     FrMarg=",FreeMargin, "\n",
          "Tiks=",j,"  RP1=",rpone,"  RP0=",rpnul,"  LProf=",rprof,"\n",
          "AllOrd=",s+b,"  SPros=",pros,"  SProf=",prof,"  Proofit=",summa,"\n",
          "Signal=",sig,"  SSig=",ssig,"  BSig=",bsig,"  Blok=",blok,"  HBlok=",hblok);
 
 
  if (s+b<3 && ns!=0 && ns>nb) {hssig=1;blok=0;} 
  if (s+b<3 && nb!=0 && nb>ns) {hbsig=1;blok=0;}
  if (s+b<3 && nb!=0 && ((bpr-Close[0])/Point)>=30) {hssig=1;blok=0;}
  if (s+b<3 && ns!=0 && ((Close[0]-spr)/Point)>=30) {hbsig=1;blok=0;}
 
  
  if (s+b==2 && hblok==0 && risk==1 )
   { 
  if ( FreeMargin<MathRound(depo/2) ) return(0);
  
  if ( bsum<hsum*mlot &&  hssig==1 && ssum>bsum)
   { 
     RefreshRates(); hspr=Bid;
     tiket=OrderSend(Symbol(),OP_SELL,kh*mlot,Bid,5,Bid+StopLoss*Point,Bid-3*TakeProfit*Point,"HWPRLOK",MagicNumber,0,Red);
     Sleep(12000);
  if(tiket>0)
   {
     if(OrderSelect(tiket,SELECT_BY_TICKET,MODE_TRADES))
   {       
     Print("HSell order opened : ",OrderOpenPrice());hblok=1; 
   }
   }
     else Print("Error opening HSell order : ",GetLastError()); 
      hblok=1; return(0);
   } 
  if ( ssum<hsum*mlot && hbsig==1 && bsum>ssum)
   {  
     RefreshRates(); hbpr=Ask;
     tiket=OrderSend(Symbol(),OP_BUY,kh*mlot,Ask,5,Ask-StopLoss*Point,Bid+3*TakeProfit*Point,"HWPRLOK",MagicNumber,0,Red);
     Sleep(12000);
  if(tiket>0)
   {
     if(OrderSelect(tiket,SELECT_BY_TICKET,MODE_TRADES))
   {
     Print("HBuy order opened : ",OrderOpenPrice()); hblok=1;
   }  
   }
     else Print("Error opening HBuy order : ",GetLastError()); 
     hblok=1; return(0);
   }
 } 
 
 if ( ssum>2*stop*mlot ) pls=1; else pls=0;
 
 if( pls==1 && hblok==0 )
  { 
   ttr=OrdersTotal()-1;
   for(cnt=ttr;cnt>=0 ;cnt--)
  {
     OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber() == MagicNumber )
  {   
     prof=prof+OrderProfit(); ns=ns+1;
     RefreshRates();          
     OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
     Sleep(12000);
     return(0);
    }
   }
  } 
  
  if ( bsum>2*stop*mlot ) plb=1; else plb=0;
 
  if( plb==1 && hblok==0 )
  { 
   ttr=OrdersTotal()-1;
   for(cnt=ttr;cnt>=0 ;cnt--)
  {
     OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() == MagicNumber )
  {      
     prof=prof+OrderProfit();nb=nb+1;
     RefreshRates();         
     OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
     Sleep(12000);
     return(0);
    }
   }
  } 
  
  prof=MathRound(prof);
  
  if ( s+b==2 && (summa+prof)>lsum*mlot && hblok==0 ) pl=1;
  if ( s+b>=2 && summa>3*stop*mlot && hblok==1) pl=1;
  if ( s+b==2 && ((MathAbs(spr-bpr)/Point)>100) && (summa+prof)>lsum && hblok==0 ) pl=1;    

  if ( pl==1 )
  { 
   ttr=OrdersTotal()-1;
   for(cnt=ttr;cnt>=0 ;cnt--)
  {
     OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber() == MagicNumber )
  {   
     RefreshRates();          
     OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
     Sleep(12000);
     return(0);
   } 
  if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() == MagicNumber )
   { 
     RefreshRates();
     OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
     Sleep(12000);
     return(0);
   }
  }
 } 
 
 if ( s+b<=2 && blok==0 && PTime!=Time[0]) 
  {
 if ( FreeMargin<MathRound(depo/4) ) return(0);
  
 if ( DWeek==5 && STime>=18 ) return(0);

 
 if ( s==0 && ssig==1 && Close[0]<Open[0] ) 
  {
    AN=CurTime();PTime=Time[0];
    ObjectCreate(AN, OBJ_ARROW, 0, Time[0], High[0]+10*Point);
    ObjectSet(AN, OBJPROP_ARROWCODE, 242);
    ObjectSet(AN, OBJPROP_COLOR , Gold); spr=Bid; blok=1; ssig=0;
    RefreshRates(); 
    tiket=OrderSend(Symbol(),OP_SELL,mlot,Bid,5,Bid+StopLoss*Point,Bid-TakeProfit*Point,"WPRLok01s",MagicNumber,0,Lime);
    Sleep(30000); 
 if(tiket>0)
   {
     if(OrderSelect(tiket,SELECT_BY_TICKET,MODE_TRADES))
   {
     Print("Sell order opened : ",OrderOpenPrice()); 
   }  
   }
     else Print("Error opening Sell order : ",GetLastError()); 
    return(0);
  }
 
 if ( b==0 && bsig==1 && Close[0]>Open[0] ) 
  {
    AN=CurTime();PTime=Time[0];
    ObjectCreate(AN, OBJ_ARROW, 0, Time[0], Low[0]-10*Point);
    ObjectSet(AN, OBJPROP_ARROWCODE, 241);
    ObjectSet(AN, OBJPROP_COLOR , Lime); blok=1; bsig=0;bpr=Ask; 
    RefreshRates(); 
    tiket=OrderSend(Symbol(),OP_BUY,mlot,Ask,5,Ask-StopLoss*Point,Ask+TakeProfit*Point,"WPRLok01b",MagicNumber,0,Gold);
    Sleep(30000);
 if(tiket>0)
   {
     if(OrderSelect(tiket,SELECT_BY_TICKET,MODE_TRADES))
   {       
     Print("Buy order opened : ",OrderOpenPrice()); 
   }
   }
     else Print("Error opening Buy order : ",GetLastError()); 
    return(0);
  }
   }
  
//----
   return(0);
  }
//+------------------------------------------------------------------+