#property copyright "Copyright 2013, JimDandy1958."
#property link      "http://jimdandyforex.com"
#property indicator_chart_window

extern bool    SignalOnClose=false;
extern color   UpperClr=Magenta;
extern color   LowerClr=Magenta;
extern int     LineStyle=STYLE_SOLID;
extern string  info ="Width only effective when Style is 0.";
extern int     LineWidth=3;
extern bool    sendemail=true;
extern bool    sendsms=true;
datetime       candleopen;

//indicator initialization
int init()
{  //make and setup resistance line

   if(LineStyle !=0)LineWidth=0;

   if(ObjectFind("UpperLine")==-1)
   ObjectCreate("UpperLine",OBJ_HLINE,0,0,Bid+(100*Point));
   ObjectSet("UpperLine",OBJPROP_COLOR,UpperClr);
   ObjectSet("UpperLine",OBJPROP_WIDTH,LineWidth);
   ObjectSet("UpperLine",OBJPROP_STYLE,LineStyle);

   //make and setup support line
   if(ObjectFind("LowerLine")==-1)
   ObjectCreate("LowerLine",OBJ_HLINE,0,0,Bid-(100*Point));
   ObjectSet("LowerLine",OBJPROP_COLOR,LowerClr);
   ObjectSet("LowerLine",OBJPROP_WIDTH,LineWidth);
   ObjectSet("LowerLine",OBJPROP_STYLE,LineStyle);
return(0);
}

//indicator deinitialization
int deinit()
{
ObjectDelete("UpperLine");ObjectDelete("LowerLine"); 
   return(0);
}

//indicator iteration
int start()
{
   double PreviousClosePrice = Bid;
   if(SignalOnClose == true)PreviousClosePrice = Close[1];
   double ResistancePrice = ObjectGet ("UpperLine", OBJPROP_PRICE1);
   double SupportPrice = ObjectGet ("LowerLine", OBJPROP_PRICE1);
   if(PreviousClosePrice > ResistancePrice)Alerts(0);
   if(PreviousClosePrice < SupportPrice)   Alerts(1);
   return(0);
}
  
void Alerts(int Direction)
{
   string UpperLineSoundFile;
   string LowerLineSoundFile;
   if(Symbol()=="EURUSD")
      {
      LowerLineSoundFile="eurusdlowerlinebreak";
      UpperLineSoundFile="eurusdupperlinebreak";
      }
   if(Symbol()=="AUDUSD")
      {
      LowerLineSoundFile="audusdlowerlinebreak";
      UpperLineSoundFile="audusdupperlinebreak";
      }
   if(Symbol()=="GBPUSD")
      {
      LowerLineSoundFile="gbpusdlowerlinebreak";
      UpperLineSoundFile="gbpusdupperlinebreak";
      }
   if(Symbol()=="USDCHF")
      {
      LowerLineSoundFile="usdchflowerlinebreak";
      UpperLineSoundFile="usdchfupperlinebreak";
      }
   if(Time[0]!=candleopen)
      {
      candleopen = Time[0];
      if(Direction==0)  PlaySound(UpperLineSoundFile);
      else              PlaySound (LowerLineSoundFile);
      if(sendemail)SendMail("Alarm S/R line crossed","Price has crossed an S/R line on the "+Symbol()+"\nThe bid price is :"+Bid);
      if(sendsms)SendNotification("Alarm Price has crossed line in "+Symbol()+"\nBid Price is "+Bid);
      }
}

