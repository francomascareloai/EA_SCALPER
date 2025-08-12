#property copyright "Ajchi"
#property link "No Link"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 MediumVioletRed
#property indicator_color4 DodgerBlue
#property indicator_color5 Bisque
#property indicator_color6 DeepPink
//extern int takenBars,difference,matching;
//----vyrovnávací pamìti
double buyPB[];
double sellPB[];
double insideBar[];
double arrayGaps[];
double outsideBars[];
double smallSR[];
int startDay=2000;
static int prevTime;
double dayRange = 0.0;
int outsideBarsCount=0;
string period="";
//stats variables


//+------------------------------------------------------------------+
//| Custom indicator – inicializaèní funkce |
//+------------------------------------------------------------------+
int init()
{
   //----indikátory
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233); //242 for down arrow
   SetIndexBuffer(0,buyPB);
   SetIndexLabel(0,"PB UP");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234); //244 for up&down arrow
   SetIndexBuffer(1,sellPB);
   SetIndexLabel(1,"PB DOWN");
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,235); //242 for down arrow
   SetIndexBuffer(2,insideBar);
   SetIndexLabel(2,"Inside Bar");

/*   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,242); //244 for up&down arrow
   SetIndexBuffer(3,arrayGaps);
   SetIndexLabel(3,"PB DOWN");
*/
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,120); //242 for down arrow
   SetIndexBuffer(3,arrayGaps);
   SetIndexLabel(3,"GAP");
   
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,163); //242 for down arrow
   SetIndexBuffer(4,outsideBars); 
   SetIndexLabel(4,"Outside Bar");
   
   
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,163); //242 for down arrow
   SetIndexBuffer(5,smallSR); 
   SetIndexLabel(5,"Sup-Res");


   switch (Period())
   {
      case 60:
         period="H1";
         break;
      case 240:
         period="H4";
         break;
      case 1440:
         period="D1";
         break;
      case 30:
         period="30m";
         break;
      case 15:
         period="15m";
         break;
      case 5:
         period="5m";
         break;    
   }
   
   ObjectsDeleteAll(0);
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator – deinicializaèní funkce |
//+------------------------------------------------------------------+
int deinit()
{
//-----
   
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator – funkce opakování |
//+------------------------------------------------------------------+
int start()
{  
   string info="";
   string time="";
   bool addInfo=false;
   int outsideBarDirection;
   int hours, min, sec;
   double gapSize;
   bool alertOn;
   int smallSRcount=0;
	/*
   min = Time[0] + Period()*60 - TimeCurrent();
   sec = min%60;
   min =(min - min%60) / 60;
   if(min<60)
      {
         time=min + "m " + sec + "s";
      }
   else
      {
         hours =  MathFloor(min/60);
         min = min-hours*60;
         time=hours + "h " + min + "m";
      }
   time = time + ", Spread: "+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0);
   time = time + ", PV(0.1): "+DoubleToStr(PipValue("USD",Symbol(),10000),2);
   
   ObjectCreate("timer_object", OBJ_LABEL, 0, Time[0], 1.1);
   ObjectSetText( "timer_object", time, 10, "Verdana", Red);
   ObjectSet("timer_object",OBJPROP_CORNER,1);
   ObjectSet("timer_object",OBJPROP_XDISTANCE,3);
   ObjectSet("timer_object",OBJPROP_YDISTANCE,3);
   AvailableMarkets();
   AvoidTradingCorrelatedMarket();
   */
   if(prevTime==Time[0]) return(0);      // Always start at the new bar
      prevTime=Time[0]; 
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   int pos=Bars-counted_bars;
   if(pos>20000) pos=20000;
   alertOn=true;
   //Comment("counted_bars="+counted_bars+", pos="+pos);
   //pos=0;
   int counter=0;
   //double poslGap=0.0;
   while(pos>=0 )//&& TimeYear(Time[pos])>startDay
   {
      
      //addInfo=false;
      if (IsBuyPinbar(dayRange,pos))
      {
         buyPB[pos+1]=Low[pos+1]-dayRange/4.0;   
         if(alertOn&&pos<1)
         {
            
            Alert ("Symbol: ",Symbol(),"   TimeFrame: ",period,"   Operace: PinBar BUY   Rozsah: ",(High[1]-Low[1])/Point,"  Cas:",TimeToStr(Time[pos],TIME_DATE|TIME_MINUTES));
            PlaySound("alert2.wav"); 
            addInfo=true;
         }
      }

      
      if (IsSellPinbar(dayRange,pos))
      {
          sellPB[pos+1]=High[pos+1]+dayRange/4.0;
          if(alertOn&&pos<1)
          {
               Alert ("Symbol: ",Symbol(),"   TimeFrame: ",period,"   Operace: PinBar SELL   Rozsah: ",(High[1]-Low[1])/Point,"  Cas:",TimeToStr(Time[pos],TIME_DATE|TIME_MINUTES));
               PlaySound("alert2.wav");
               addInfo=true;
          }
      } 
      /*
      if (IsInsideBar(pos))
      {
         dayRange=AveRange4(pos);
         insideBar[pos+1]=Low[pos+1]-dayRange/4.0;
         if(alertOn&&pos<1)
         {
            Alert ("Symbol: ",Symbol(),"   TimeFrame: ",period,"   Operace: InsideBar   Cas:",TimeToStr(Time[pos],TIME_DATE|TIME_MINUTES));
            PlaySound("alert2.wav");
         }
      }
      
      gapSize=Gap(pos);
      if (MathAbs(gapSize)>0.0)
      {
      
         if(gapSize>0)
            arrayGaps[pos]=High[pos]+dayRange/4.0;
         else 
            arrayGaps[pos+1]=High[pos+1]+dayRange/4.0;
         //counter++;
         if(alertOn&&pos<1)
         {
            Alert ("Symbol: ",Symbol(),"   TimeFrame: ",period,"   Operace: GAP   Cas:",TimeToStr(Time[pos],TIME_DATE|TIME_MINUTES));
            PlaySound("alert2.wav");
         }   
         
      }
      
      
      outsideBarDirection=IsOutsideBar(pos);
      if (outsideBarDirection!=0)
      {
         
         if(outsideBarDirection==1)         
            outsideBars[pos+1]=Low[pos+1]-dayRange/3.5;
         else          
            outsideBars[pos+1]=High[pos+1]+dayRange/3.5;   
         if(alertOn&&pos<1)
         {
            Alert ("Symbol: ",Symbol(),"   TimeFrame: ",period,"   Operace: OutSide Bar  Rozsah:",(High[1]-Low[1])/Point,"   Cas:",TimeToStr(Time[pos],TIME_DATE|TIME_MINUTES));
            PlaySound("alert2.wav");
         } 
          
      }
      
      
      if(IsSmallBuySR(pos))//IsSmallSR(int pos, int takenBars,int difference,int matching)
      {
           // if(iMA(NULL,0,50,0,0,0,pos)-iMA(NULL,0,50,0,0,0,pos+20)>40*Point  &&iRSI(NULL,0,7,6,pos)<40)
            //{
               smallSR[pos]=High[pos]+dayRange/5;
               smallSRcount++;
           // }   
       
      }
      if(IsSmallSellSR(pos))//IsSmallSR(int pos, int takenBars,int difference,int matching)
      {
           // if(iMA(NULL,0,50,0,0,0,pos)-iMA(NULL,0,50,0,0,0,pos+20)<-40*Point &&iRSI(NULL,0,7,6,pos)>60)
           // {
               smallSRcount++;
               smallSR[pos]=Low[pos]-dayRange/5;
           // }
      }
      
      

      if (addInfo)
      {
         info=info+"   Max. Lot size: "+DoubleToStr(LotSize(High[1]-Low[1]),1);
      }
      */
      pos--;
      

   }
      //double cor=2.3;
      //DrawLines(11);
      //AvoidTradingCorrelatedMarket();
      //AvailableMarkets();
      //double cor = Correl("NZDUSD", Symbol(), 1440, 6);     
      //Comment("Pocet smallSRcount: ",pos);//, " Kor: ",cor

   return(0);
}

//+------------------------------------------------------------------+
//| User function AveRange4                                          |
//+------------------------------------------------------------------+
double AveRange4(int pos)
{
   double sum;
   double rangeSerie[4];
   
   int i=0;
   int ind=1;
   int startYear=1995;
   int den;
   
   if(pos<=0)den=1;
   else den = pos;
   if (TimeYear(Time[den-1])>=startYear)
   {
      while (i<4)
      {
         //datetime pok=Time[pos+ind];
         if(TimeDayOfWeek(Time[pos+ind])!=0)
         {
            sum+=High[pos+ind]-Low[pos+ind];//make summation
            i++;
         }
         ind++;   
         //i++;
      }
      //Comment(sum/4.0);
      return (sum/4.0);//make average, don't count min and max, this is why I divide by 4 and not by 6
   } 
      return (50*Point);
   
}//------------END FUNCTION-------------



//+------------------------------------------------------------------+
//| User function IsPinbar                                           |
//+------------------------------------------------------------------+
bool IsBuyPinbar(double& dayRange, int pos)
{
   //start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actHigherPart,actHigherPart1;
   actOp=Open[pos+1];
   actCl=Close[pos+1];
   actHi=High[pos+1];
   actLo=Low[pos+1];
   preOp=Open[pos+2];
   preCl=Close[pos+2];
   preHi=High[pos+2];
   preLo=Low[pos+2];
   //SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actHigherPart=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
   actHigherPart1=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
   //end of declaratins
   //start function body
   dayRange=AveRange4(pos);
   if((actCl>actHigherPart1&&actOp>actHigherPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
      //(actHi<(preHi-preRange*0.3))&& //High of PB is NOT higher than 1/2 of previous Bar
      (actLo+actRange*0.25<preLo)) //Nose of the PB is at least 1/3 lower than previous bar
   {
    
      if(Low[ArrayMinimum(Low,3,pos+3)]>Low[pos+1])
         return (true);
   }
   return(false);
   
}//------------END FUNCTION-------------


bool IsSellPinbar(double& dayRange, int pos)
{
   //start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actLowerPart, actLowerPart1;
   actOp=Open[pos+1];
   actCl=Close[pos+1];
   actHi=High[pos+1];
   actLo=Low[pos+1];
   preOp=Open[pos+2];
   preCl=Close[pos+2];
   preHi=High[pos+2];
   preLo=Low[pos+2];
   //SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actLowerPart=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
   actLowerPart1=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
   //end of declaratins
   
   //start function body

   dayRange=AveRange4(pos);
   if((actCl<actLowerPart1&&actOp<actLowerPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
      //(actLo>(preLo+preRange/3.0))&& //Low of PB is NOT lower than 1/2 of previous Bar
      (actHi-actRange*0.25>preHi)) //Nose of the PB is at least 1/3 lower than previous bar
      
   {
      if(High[ArrayMaximum(High,3,pos+3)]<High[pos+1])
         return (true);
   }
}//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//| User function LotSize             vcetne spreadu                 |
//+------------------------------------------------------------------+
double LotSize(double pbDay)
{
   pbDay=pbDay+MarketInfo(Symbol(),MODE_SPREAD)*Point;
   double actBalance=AccountBalance();
   double tickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double myBet=0;
   double lot=0;
   double minLot = MarketInfo(Symbol(),MODE_MINLOT);
   myBet=actBalance*0.02; //2 percent of account
   lot=myBet/(pbDay/Point*tickValue);
   lot=MathRound(lot*10.0)/10.0;
   if(lot<minLot) 
      lot = minLot;
   return (lot);
}
//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//| User function IsInsideBar                                          |
//+------------------------------------------------------------------+
bool IsInsideBar(int pos)
{
   int i = 0;
   int x = 0;
   
   //bool naplneno=false;
   int takenDays[3];
   if(Period()==1440) //v dennim grafu vynechame nedele tak, ze zaznamenam indexy jednotlivych dni mimo nedeli a pak to zpracuju
   {
      while(i<3)
      {
         if(TimeDayOfWeek(Time[pos+1+x])!=0) 
         {
            takenDays[i]=pos+1+x;
            i++;
         }
         x++;
      }
      if(Low[takenDays[0]]>=Low[takenDays[1]]&&Low[takenDays[1]]>=Low[takenDays[2]])
         if (High[takenDays[0]]<=High[takenDays[1]]&&High[takenDays[1]]<=High[takenDays[2]])
            return (true);
   
   }
   else 
   {
      if(Low[pos+1]>=Low[pos+2]&&Low[pos+2]>=Low[pos+3])
         if (High[pos+1]<=High[pos+2]&&High[pos+2]<=High[pos+3])
            return (true);
   
   
   }
   return (false);
}


//+------------------------------------------------------------------+
//| User function IsOutsideBar - average gap size                            |
//+------------------------------------------------------------------+
int IsOutsideBar(int pos)
{
   int i = 0;
  // int x = 0;
  // int diff = 1;
   if(TimeDayOfWeek(Time[pos+2])!=0) 
     // return (0);
   if(Low[pos+2]>=Low[pos+1]&&High[pos+2]<=High[pos+1])
   {
      if(Open[pos+1]<Close[pos+1]&&Close[pos+1]>High[pos+2])
         return (1);
      else if(Open[pos+1]>Close[pos+1]&&Close[pos+1]<Low[pos+2])    
         return (-1);
   }
   return (0);
}
//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//| User function FindMarketIndex - helper function for IsSmallBuySR & IsSmallSellSR                        |
//+------------------------------------------------------------------+
int FindMarketIndex()//, 
{
   string tradedMarkets[]={"EURCHF","AUDUSD","USDCZK","USDCAD","EURUSD","GBPUSD","EURJPY","USDJPY","USDCHF","EURCAD","EURCZK","AUDJPY","NZDUSD","EURGBP"};
   //                         0          1      2         3       4        5        6        7        8        9        10       11       12       13        
   int marketCount=ArraySize(tradedMarkets);
   string mySymbol=Symbol();
   for(int i=0;i<marketCount;i++)
      if(tradedMarkets[i]==mySymbol)
         return (i);


}


//+------------------------------------------------------------------+
//| User function IsSmallBuySR - SR levels                            |
//+------------------------------------------------------------------+
bool IsSmallBuySR(int pos)//, 
{
   int countMatching,ind,takenBars,difference,matching;
   
   if (TimeDayOfWeek(Time[pos])==0)
         return(false);
   double refHigh=High[pos];
   int symbol=FindMarketIndex();
   switch(Period())
   {
      case 1440:
         switch(symbol)
         {
            case 0:
               takenBars=6;difference=4;matching=3;
               break;
            case 1:
               takenBars=6;difference=9;matching=3;
               break;
            case 2:
               takenBars=6;difference=11;matching=3;
               break;
            case 3:
               takenBars=6;difference=6;matching=3;
               break;
            case 4:
               takenBars=6;difference=6;matching=3;
               break;
            case 5:
               takenBars=6;difference=6;matching=3;
               break;        
            case 6:
               takenBars=6;difference=7;matching=3;
               break;        
            case 7:
               takenBars=6;difference=6;matching=3;
               break;        
            case 8:
               takenBars=6;difference=6;matching=3;
               break;   
            case 9:
               takenBars=6;difference=7;matching=3;
               break;        
            case 10:
               takenBars=6;difference=5;matching=3;
               break;        
            case 11:
               takenBars=6;difference=7;matching=3;
               break;        
            case 12:
               takenBars=6;difference=6;matching=3;
               break;      
            case 13:
               takenBars=5;difference=2;matching=3;
               break; 
            default:   
               takenBars=5;difference=5;matching=3;
         }
   //string tradedMarkets[]={"EURCHF","AUDUSD","USDCZK","USDCAD","EURUSD","GBPUSD","EURJPY","USDJPY","USDCHF","EURCAD","EURCZK","AUDJPY","NZDUSD","EURGBP"};
   ////                         0          1      2         3       4        5        6        7        8        9        10       11       12       13                 
      case 240:
          switch(symbol)
          {
            case 0:
               takenBars=4;difference=2;matching=3;  
               break;
            case 1:
               takenBars=4;difference=6;matching=3;
               break;
            case 2:
               takenBars=4;difference=6;matching=3;
               break;
            case 3:
               takenBars=4;difference=4;matching=3;
               break;
            case 4:
               takenBars=4;difference=4;matching=3;  
               break;
            case 5:
               takenBars=4;difference=4;matching=3;  
               break;        
            case 6:
               takenBars=4;difference=3;matching=3; 
               break;        
            case 7:
               takenBars=4;difference=2;matching=3;  
               break;        
            case 8:
               takenBars=4;difference=3;matching=3;  
               break;   
            case 9:
               takenBars=4;difference=4;matching=3;
               break;        
            case 10:
               takenBars=4;difference=3;matching=3;
               break;        
            case 11:
               takenBars=4;difference=4;matching=3;
               break;        
            case 12:
                takenBars=4;difference=4;matching=3; 
               break;      
            case 13:
               takenBars=3;difference=1;matching=3; 
               break; 
            default:   
               takenBars=4;difference=3;matching=3;
          }
//string tradedMarkets[]={"EURCHF","AUDUSD","USDCZK","USDCAD","EURUSD","GBPUSD","EURJPY","USDJPY","USDCHF","EURCAD","EURCZK","AUDJPY","NZDUSD","EURGBP"};
////                         0          1      2         3       4        5        6        7        8        9        10       11       12       13                 
      case 60:
          switch(symbol)
          {
            case 0:
               takenBars=4;difference=1;matching=3; 
               break;
            case 1:
               takenBars=4;difference=4;matching=3; 
               break;
            case 2:
               takenBars=4;difference=4;matching=3;
               break;
            case 3:
               takenBars=4;difference=2;matching=3;
               break;
            case 4:
               takenBars=4;difference=3;matching=3;
               break;
            case 5:
               takenBars=4;difference=3;matching=3;
               break;        
            case 6:
               takenBars=4;difference=3;matching=3;  
               break;        
            case 7:
               takenBars=4;difference=2;matching=3; 
               break;        
            case 8:
               takenBars=4;difference=2;matching=3; 
               break;   
            case 9:
               takenBars=4;difference=3;matching=3; 
               break;        
            case 10:
               takenBars=4;difference=2;matching=3; 
               break;        
            case 11:
               takenBars=4;difference=4;matching=3;
               break;        
            case 12:
                takenBars=4;difference=3;matching=3;
               break;      
            case 13:
               takenBars=4;difference=0;matching=3; 
               break; 
            default:   
               takenBars=4;difference=3;matching=3;
          }
   }
   
   
   
   
   for(int i=0;i<takenBars-1;i++)
   {
      
	  if(Period()==1440&&TimeDayOfWeek(Time[pos+1+i+ind])==0)
            ind++;
      if(MathAbs(refHigh-High[pos+1+i+ind])/Point<=difference)   
      {
         
         
         countMatching++;   
         if(countMatching==matching-1)
            return(true);
            
      }
      if((High[pos+1+i+ind]-refHigh)/Point>difference+1)
            return (false);
            
   }
   return(false);
}
//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//| User function IsSmallSellSR - SR levels                            |
//+------------------------------------------------------------------+
bool IsSmallSellSR(int pos)
{
   int countMatching,ind,takenBars,difference,matching;
   if (TimeDayOfWeek(Time[pos])==0)
         return(false);
   
   if(takenBars==0)
   {
      switch(Period())
      {
         case 1440:
            takenBars=6;difference=6;matching=3;
            break;
         case 240:
            takenBars=4;difference=4;matching=3;  
            break;
         case 60:
            takenBars=4;difference=2;matching=3;      
            break;
      }    
   } 
   double refLow=Low[pos];
   for(int i=0;i<takenBars-1;i++)
   {
   
 	  if(Period()==1440&&TimeDayOfWeek(Time[pos+1+i+ind])==0)
            ind++;   
      if(MathAbs(refLow-Low[pos+1+i])/Point<=difference)   
      {
         
         
         countMatching++;   
         if(countMatching==matching-1)
            return(true);
            
      }
      if((refLow-Low[pos+1+i+ind])/Point>difference+1)
            return (false);
            
   }
   return(false);
}
//------------END FUNCTION-------------



//+------------------------------------------------------------------+
//| User function Gaps - average gap size                            |
//+------------------------------------------------------------------+
double Gap (int pos)
{
   int startYear=2000;
   double gap;
   
   if (TimeYear(Time[pos])>=startYear)
   {
     
     if (Close[pos+1]!=Open[pos])
     {
         gap=(Close[pos+1]-Open[pos])/Point;
         
         if(MathAbs(gap) > 40.0)
         {
            return (gap);
         }
         else return (0.0);
     } 
   }   
      else return (0.0);
}



void DrawLines(int numberOfLines)
{
   double prices[10]; //nejde nadefinovat jako numberOfLines
   double closestPrice, startPrice,roundedPrice;
   int base4digits=100;
   int base2digits=100;
   if (MathMod(numberOfLines,2)==0)
      numberOfLines++;
   if (Symbol()=="GBPUSD"||Period()==1440)
      base4digits=1000;
   if(Digits==4) //pro 4 ciferne trhy
   {
      closestPrice=MathRound(Ask*base4digits)/base4digits;
      if (Symbol()=="GBPUSD"||Period()==1440)
         closestPrice=MathRound(Ask*10)/10;
      roundedPrice=numberOfLines/2*base4digits*Point+closestPrice;
      for (int i=0;i<numberOfLines;i++)
      {
         
         
         ObjectCreate("line"+i, OBJ_HLINE, 0, Time[0], roundedPrice);   
         if (roundedPrice==MathRound(roundedPrice))
            ObjectSet("line"+i, OBJPROP_COLOR, OrangeRed);
         else if(roundedPrice*10==MathRound(roundedPrice*10))
            ObjectSet("line"+i, OBJPROP_COLOR, IndianRed);
         else 
            ObjectSet("line"+i, OBJPROP_COLOR, Goldenrod);
         
         
         roundedPrice=roundedPrice-base4digits*Point;
         
         
      
      }
   
   
   }
   else if(Digits==2) //pro 4 ciferne trhy
   {
      closestPrice=MathRound(Ask);
      //if (Symbol()=="GBPUSD"||Period()==1440)
      //   closestPrice=MathRound(Ask*10)/10;
      roundedPrice=numberOfLines/2*base2digits*Point+closestPrice;
      for (i=0;i<numberOfLines;i++)
      {
         
         
         ObjectCreate("line"+i, OBJ_HLINE, 0, Time[0], roundedPrice);   
         if (roundedPrice/10==MathRound(roundedPrice/10))
            ObjectSet("line"+i, OBJPROP_COLOR, OrangeRed);
        // else if(roundedPrice*10==MathRound(roundedPrice*10))
          //  ObjectSet("line"+i, OBJPROP_COLOR, IndianRed);
         else 
            ObjectSet("line"+i, OBJPROP_COLOR, Goldenrod);
         
         
         roundedPrice=roundedPrice-base2digits*Point;
      }
   }
}



//+------------------------------------------------------------------+
//| User function Correl                                          |
//+------------------------------------------------------------------+
double Correl(string sym1, string sym2, int timeFrame, int period, int pos)
{
   double prumSym1,prumSym2,ssSym1,ssSym2,xiDiff,yiDiff,xiyiProduct;
   int ind=0;
   
   for(int i=1;i<=period;i++)
   {
      if(timeFrame==1440 && TimeDayOfWeek(iTime(sym1,timeFrame,pos+i+ind))==0)
         ind++;
      prumSym1+=iClose(sym1,timeFrame,pos+i+ind);
      prumSym2+=iClose(sym2,timeFrame,pos+i+ind);
   }
   prumSym1=prumSym1/period;
   prumSym2=prumSym2/period;
  
   ind=0;
   for(i=1;i<=period;i++)
   {
     if(timeFrame==1440 && TimeDayOfWeek(iTime(sym1,timeFrame,pos+i+ind))==0)
         ind++;
      xiDiff=iClose(sym1,timeFrame,pos+i+ind)-prumSym1;
      yiDiff=iClose(sym2,timeFrame,pos+i+ind)-prumSym2;
      xiyiProduct+=xiDiff*yiDiff;
      ssSym1+=xiDiff*xiDiff;
      ssSym2+=yiDiff*yiDiff;
   }
   return(xiyiProduct/MathSqrt(ssSym1*ssSym2));
}//------------END FUNCTION-------------


//+------------------------------------------------------------------+
//| User function AvoidTradingCorrelatedMarket                                          |
//+------------------------------------------------------------------+
void AvoidTradingCorrelatedMarket()
{
   string avoidMarkets;
   string tradedMarkets;
   string orderSymbol;
   bool output=false;
   int total=OrdersTotal();
   int handle; //for file
   double weekly,monthly;

   for(int pos=0;pos<total;pos++)
   {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      orderSymbol=OrderSymbol();
      if(StringFind( tradedMarkets, orderSymbol, 0)==-1 && orderSymbol!=Symbol())
      {
         weekly=Correl(orderSymbol, Symbol(), 1440, 6,0);
         monthly=Correl(orderSymbol, Symbol(), 1440, 21,0);
         tradedMarkets=tradedMarkets+","+orderSymbol;
         if((MathAbs(weekly)>=0.75 || MathAbs(monthly)>=0.75)&&weekly*monthly>0.0)//
         {
            avoidMarkets=avoidMarkets+orderSymbol+":W"+DoubleToStr(weekly,2)+"M"+DoubleToStr(monthly,2)+"  ";
            output=true;
         }
         /*
         else
         {
            FileDelete(orderSymbol+"AvoidCorrel");
         }
         */
      }   
   }
   
   //output=true;
   if(output)
   {
      //avoidMarkets="Korelace:"+avoidMarkets;
      ObjectCreate("avoid_object", OBJ_LABEL, 1, Time[0], 1.1);
      ObjectSetText( "avoid_object", avoidMarkets, 9, "Verdana", DeepPink);
      
      /*
      if(Period()==1440)
      {
         handle=FileOpen(Symbol()+"AvoidCorrel", FILE_WRITE);
         if(handle>0)
         {
            FileWrite(handle, avoidMarkets);
            FileClose(handle);
         }
         ObjectSetText( "avoid_object", avoidMarkets, 9, "Verdana", DeepPink);
      }  
      else    
      {
         handle=FileOpen(Symbol()+"AvoidCorrel", FILE_READ);
         if(handle>0)
         {
            avoidMarkets=FileReadString(handle);
            FileClose(handle);
            ObjectSetText( "avoid_object", avoidMarkets, 9, "Verdana", DeepPink);
         }
         else 
            ObjectSetText( "avoid_object", "Null", 9, "Verdana", DeepPink);
      }*/  
      ObjectSet("avoid_object",OBJPROP_CORNER,2);
      ObjectSet("avoid_object",OBJPROP_XDISTANCE,3);
      ObjectSet("avoid_object",OBJPROP_YDISTANCE,3);
      //ObjectSetText( "avoid_object", "EURCAD: W-0.22 M0.70>> NZDUSD: W0.96 M0.96>> USDCHF: W-0.72 M-0.63>>  ", 9, "Verdana", DeepPink);
      
   }//
   else ObjectDelete("avoid_object");

}//------------END FUNCTION-------------



void AvailableMarkets()
{
   int total=OrdersTotal();
   int handle; //for file
   string actMarkets, prevMarkets;
   double weekly,monthly;
   string orderSymbol;
   string tradedMarkets[]={"EURCHF","AUDUSD","USDCZK","USDCAD","EURUSD","GBPUSD","EURJPY","USDJPY","USDCHF","EURCAD","EURCZK","AUDJPY","NZDUSD","EURGBP"};
   int marketCount=ArraySize(tradedMarkets);
   int index=0;

   if(total==0)      
      actMarkets="ALL   ";
   else
   {   
      for(int pos=0;pos<total;pos++)//for(int pos=0;pos<total;pos++)
      {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         orderSymbol=OrderSymbol();
         actMarkets="";
         for(int j=0;j<marketCount;j++)//for(int j=0;j<marketCount;j++)
         {
            if(tradedMarkets[j]!=orderSymbol)
            {
               weekly=Correl(orderSymbol, tradedMarkets[j], 1440, 6,0);
               monthly=Correl(orderSymbol, tradedMarkets[j], 1440, 21,0);
               if((MathAbs(weekly)<0.75 && MathAbs(monthly)<0.75)||weekly*monthly<0.0)//
               {
                  tradedMarkets[index]=tradedMarkets[j];
                  actMarkets=actMarkets+tradedMarkets[index]+", ";
                  index++;
               }
            }
         
         }//end for
         marketCount=index;
         index=0;         
      }//end for
   }//end else
   ObjectCreate("trade_object", OBJ_LABEL, 1, Time[0], 1.1);
   ObjectSetText( "trade_object", StringSubstr( actMarkets, 0, StringLen(actMarkets)-3) , 9, "Verdana", DeepPink);
   ObjectSet("trade_object",OBJPROP_CORNER,2);
   ObjectSet("trade_object",OBJPROP_XDISTANCE,3);
   ObjectSet("trade_object",OBJPROP_YDISTANCE,15);
}//------------END FUNCTION-------------



//+------------------------------------------------------------------+
//| User function PipValue                                          |
//+------------------------------------------------------------------+
double PipValue(string baseCurrency, string quotedCurrency, int lotSize)
{
   string secSymbol, firSymbol;
   int searchSymbol;
   double helper=0.0;   
   secSymbol=StringSubstr( quotedCurrency, 3, 3); 
   firSymbol=StringSubstr( quotedCurrency, 0, 3); 
   if (secSymbol==baseCurrency)
      return (MarketInfo(quotedCurrency,MODE_POINT)*lotSize);
   else 
   if (firSymbol==baseCurrency)   
      return(MarketInfo(quotedCurrency,MODE_POINT)/MarketInfo(quotedCurrency,MODE_ASK)*lotSize);
   else    
   {
      if(MarketInfo(firSymbol+baseCurrency,MODE_ASK)==0.0)
         return(MarketInfo(quotedCurrency,MODE_POINT)/MarketInfo(quotedCurrency,MODE_ASK)*lotSize/MarketInfo(baseCurrency+firSymbol,MODE_ASK));//
      else
        return(MarketInfo(quotedCurrency,MODE_POINT)/MarketInfo(quotedCurrency,MODE_ASK)*lotSize*MarketInfo(firSymbol+baseCurrency,MODE_ASK));//
   }     
}//------------END FUNCTION-------------
//CHFJPY


//+------------------------------------------------------------------+
//| User function FileOutput                                          |
//+------------------------------------------------------------------+
/*void FileOutput(string filename)
{
   int fileHandle;
   fileHandle = FileOpen(filename, FILE_WRITE, ';');
   
   if (fileHandle>0)
   {
      FileWrite(fileHandle,);
      FileWrite(fileHandle,0,1,2,3,4,5);
      FileWrite(fileHandle,0,1,2,3,4,5);
      FileWrite(fileHandle,0,1,2,3,4,5);
      FileClose(fileHandle); 
   
   }
}//------------END FUNCTION-------------
*/



