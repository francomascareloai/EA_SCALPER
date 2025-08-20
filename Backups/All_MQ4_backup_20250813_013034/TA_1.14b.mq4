//+------------------------------------------------------------------+
//|                                                  Trade Assistant |
//|                                                     TA_1.14b.mq4 |
//|                                       Copyright © 2008 Tom Balfe |
//|                                                                  |
//| This indicator helps you trade by giving you two signals on      |
//| multiple timeframes. It bases it's recommendations on RSI and    |
//| stochastics.                                                     |
//|                                                                  |
//| Version: 1.14b                                                    |
//|                                                                  |
//| Changelog:                                                       |
//|                                                                  |
//|    1.14b - subtracted 1 min TF and added 1 day                   |
//|    1.14  - added CCI, entry and trend                            |
//|    1.12  - fixed RSI code                                        |
//|    1.11  - fixed spacing between objects                         |
//|     1.1  - added buy/sell text                                   |
//|     1.0  - first version, got arrows working                     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008 Tom Balfe"
#property link      "redcarsarasota@yahoo.com"
#property indicator_separate_window

//--- spacing
int     scaleX=120,scaleY=20,offsetX=200,offsetY=4,fontSize=8;
//--- arrays for various things
int     TF[]              = {5,15,30,60,240,1440};
int     eCCI[]            = {14,14,6,6,6,6};
int     tCCI[]            = {50,34,14,14,14,14};
string  periodStr[]       = {"5 MIN:","15 MIN:","30 MIN:","1 HR:","4 HR:","1 DAY:"};
string  signalNameStr[]   = {"STOCH","RSI","EntryCCI","TrendCCI"};

//+------------------------------------------------------------------+
//| USER ADJUSTABLE STUFF                                            |
//+------------------------------------------------------------------+
extern  string  Stochastic_Settings   = "=== Stochastic Settings ===";
extern  int     PercentK              = 8;
extern  int     PercentD              = 3;
extern  int     Slowing               = 3;

extern  string  RSI_Settings          = "=== RSI Settings ===";
extern  int     RSIP1                 = 14;
extern  int     RSIP2                 = 70;  

extern  string  My_Symbols            = "=== Wingdings Symbols ===";
extern  int     sBuy                  = 233;
extern  int     sSell                 = 234;
extern  int     sWait                 = 54;
extern  int     sCCIAgainstBuy        = 238;
extern  int     sCCIAgainstSell       = 236;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()
  {
    //-- indicator short name
    IndicatorShortName("Trade Assistant 1.14b ");

    return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()
  {
   //-- need to delete objects should user remove indicator
   ObjectsDeleteAll(0,OBJ_LABEL);
   
    //-- delete timeframe text labels   
    for(int x=0;x<6;x++)
      for (int y=0;y<4;y++)
      { ObjectDelete("tPs"+x+y); } 
    
    //-- delete indicator text labels
    for(y=0;y<4;y++)
      { ObjectDelete("tInd"+y); }       
    
    //-- delete indicator arrows and text
    for (x=0;x<6;x++)
      for (y=0;y<4;y++)
      { ObjectDelete("dI"+x+y); }
          
    for (x=0;x<6;x++)
      for (y=0;y<4;y++)   
      { ObjectDelete("tI"+x+y); } 
   
   return(0);
  }

//+------------------------------------------------------------------+
//| MAIN LOOP                                                        |
//+------------------------------------------------------------------+

int start()
  {
    //--- create timeframe text labels 
    for (int x=0;x<6;x++)
      for (int y=0;y<4;y++)
      {
        ObjectCreate("tPs"+x+y,OBJ_LABEL,WindowFind("Trade Assistant 1.14b "),0,0);
        ObjectSetText("tPs"+x+y,periodStr[x],fontSize,"Arial Bold",LightSteelBlue);
        ObjectSet("tPs"+x+y,OBJPROP_CORNER,0);
        ObjectSet("tPs"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
        ObjectSet("tPs"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create indicator text labels
    for (y=0;y<4;y++)
      {
        ObjectCreate("tInd"+y,OBJ_LABEL,WindowFind("Trade Assistant 1.14b "),0,0);
        ObjectSetText("tInd"+y,signalNameStr[y],fontSize,"Arial Bold",PaleGoldenrod);
        ObjectSet("tInd"+y,OBJPROP_CORNER,0);
        ObjectSet("tInd"+y,OBJPROP_XDISTANCE,offsetX-55);
        ObjectSet("tInd"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for arrows
    for (x=0;x<6;x++)
      for (y=0;y<4;y++)
      {
        ObjectCreate("dI"+x+y,OBJ_LABEL,WindowFind("Trade Assistant 1.14b "),0,0);
          ObjectSetText("dI"+x+y," ",10,"Wingdings",Goldenrod);
          ObjectSet("dI"+x+y,OBJPROP_CORNER,0);
          ObjectSet("dI"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+80)); // scaleX == 120, offsetX == 200
          ObjectSet("dI"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for text
    for (x=0;x<6;x++)
      for (y=0;y<4;y++)
      {
        ObjectCreate("tI"+x+y,OBJ_LABEL,WindowFind("Trade Assistant 1.14b "),0,0);
          ObjectSetText("tI"+x+y,"    ",9,"Arial Bold",Goldenrod);
          ObjectSet("tI"+x+y,OBJPROP_CORNER,0);
          ObjectSet("tI"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+45)); // scaleX == 120, offsetX == 200
          ObjectSet("tI"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- stochastics arrows
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_MAIN,0)) >  
         (iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_SIGNAL,0)))
        ObjectSetText("dI"+x+"0",CharToStr(sBuy),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_SIGNAL,0)) >
        (iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_MAIN,0)))
        ObjectSetText("dI"+x+"0",CharToStr(sSell),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI"+x+"0",CharToStr(sWait),10,"Wingdings",Khaki); 
    }
    
    //--- stochastics text
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_MAIN,0)) >  
         (iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_SIGNAL,0)))
        ObjectSetText("tI"+x+"0"," BUY",9,"Arial Bold",Lime);
      else if             
        ((iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_SIGNAL,0)) >
        (iStochastic(NULL,TF[x],PercentK,PercentD,Slowing,MODE_SMA,0,MODE_MAIN,0)))
        ObjectSetText("tI"+x+"0","SELL",9,"Arial Bold",Red);         
      else
        ObjectSetText("tI"+x+"0","WAIT",9,"Arial Bold",Khaki); 
    }    
        
    //--- RSI arrows
    for(x=0;x<6;x++)
    {
      if ((iRSI(NULL,TF[x],RSIP1,PRICE_TYPICAL,0)) > (iRSI(NULL,TF[x],RSIP2,PRICE_TYPICAL,0)))
        ObjectSetText("dI"+x+"1",CharToStr(sBuy),fontSize,"Wingdings",Lime);  
      else if
         ((iRSI(NULL,TF[x],RSIP2,PRICE_TYPICAL,0)) > (iRSI(NULL,TF[x],RSIP1,PRICE_TYPICAL,0)))  
        ObjectSetText("dI"+x+"1",CharToStr(sSell),fontSize,"Wingdings",Red);
      else
      ObjectSetText("dI"+x+"1",CharToStr(sWait),fontSize,"Wingdings",Khaki);
    }
    
    //--- RSI text
    for(x=0;x<6;x++)
    {
      if ((iRSI(NULL,TF[x],RSIP1,PRICE_TYPICAL,0)) > (iRSI(NULL,TF[x],RSIP2,PRICE_TYPICAL,0)))
        ObjectSetText("tI"+x+"1"," BUY",9,"Arial Bold",Lime);
      else if             
        ((iRSI(NULL,TF[x],RSIP2,PRICE_TYPICAL,0)) > (iRSI(NULL,TF[x],RSIP1,PRICE_TYPICAL,0)))
        ObjectSetText("tI"+x+"1","SELL",9,"Arial Bold",Red);         
      else
        ObjectSetText("tI"+x+"1","WAIT",9,"Arial Bold",Khaki); 
    }  
    
    //--- EntryCCI arrows
    for(x=0;x<6;x++)
    {
      if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0))>0) // if entry cci above zero
        {                                           
        if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0))>(iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,1))) 
        ObjectSetText("dI"+x+"2",CharToStr(sBuy),fontSize,"Wingdings",Lime); 
        else ObjectSetText("dI"+x+"2",CharToStr(sCCIAgainstBuy),fontSize,"Wingdings",Red); 
      }
      else if             
        ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0)) <0) // if entry cci below zero
        {
        if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0)) < (iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,1))) 
        ObjectSetText("dI"+x+"2",CharToStr(sSell),fontSize,"Wingdings",Red);         
        else  ObjectSetText("dI"+x+"2",CharToStr(sCCIAgainstSell),fontSize,"Wingdings",Lime); 
      }
      else
        ObjectSetText("dI"+x+"2",CharToStr(sWait),10,"Wingdings",Khaki); 
    }
        
    //--- EntryCCI text
    for(x=0;x<6;x++)
    {
      if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0)) >0) // if entry cci above zero
        {
        if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0))>(iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,1)))
        ObjectSetText("tI"+x+"2"," BUY",9,"Arial Bold",Lime); 
        else ObjectSetText("tI"+x+"2","SELL",9,"Arial Bold",Red); 
      }
      else if             
        ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0)) <0) // if entry cci below zero
        {
        if ((iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,0))<(iCCI(NULL,TF[x],eCCI[x],PRICE_TYPICAL,1)))
        ObjectSetText("tI"+x+"2","SELL",9,"Arial Bold",Red);         
        else ObjectSetText("tI"+x+"2"," BUY",9,"Arial Bold",Lime); 
      }
      else
        ObjectSetText("tI"+x+"2","WAIT",9,"Arial Bold",Khaki); 
    } 
   
    //--- TrendCCI arrows
    for(x=0;x<6;x++)
    {
      if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0))>0) // if entry cci above zero
        {                                           
        if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0))>(iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,1))) 
        ObjectSetText("dI"+x+"3",CharToStr(sBuy),fontSize,"Wingdings",Lime); 
        else ObjectSetText("dI"+x+"3",CharToStr(sCCIAgainstBuy),fontSize,"Wingdings",Red); 
      }
      else if             
        ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0)) <0) // if entry cci below zero
        {
        if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0)) < (iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,1))) 
        ObjectSetText("dI"+x+"3",CharToStr(sSell),fontSize,"Wingdings",Red);         
        else  ObjectSetText("dI"+x+"3",CharToStr(sCCIAgainstSell),fontSize,"Wingdings",Lime); 
      }
      else
        ObjectSetText("dI"+x+"3",CharToStr(sWait),10,"Wingdings",Khaki); 
    }
         
    //--- TrendCCI text
    for(x=0;x<6;x++)
    {
      if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0)) >0) // if entry cci above zero
        {
        if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0))>(iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,1)))
        ObjectSetText("tI"+x+"3"," BUY",9,"Arial Bold",Lime); 
        else ObjectSetText("tI"+x+"3","SELL",9,"Arial Bold",Red); 
      }
      else if             
        ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0)) <0) // if entry cci below zero
        {
        if ((iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,0))<(iCCI(NULL,TF[x],tCCI[x],PRICE_TYPICAL,1)))
        ObjectSetText("tI"+x+"3","SELL",9,"Arial Bold",Red);         
        else ObjectSetText("tI"+x+"3"," BUY",9,"Arial Bold",Lime); 
      }
      else
        ObjectSetText("tI"+x+"3","WAIT",9,"Arial Bold",Khaki); 
    } 
     
  return(0);
  }
  //+------------------------------------------------------------------+
  //| END MAIN LOOP                                                    |
  //+------------------------------------------------------------------+
   