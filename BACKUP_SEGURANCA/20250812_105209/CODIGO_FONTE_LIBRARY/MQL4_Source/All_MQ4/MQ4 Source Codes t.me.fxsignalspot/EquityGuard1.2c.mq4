 
#property copyright "Copyright ?2011, forexprogramming@gmail.com"
#property link      "forexprogramming@gmail.com"
 
#include <WinUser32.mqh>
extern string EAName="===EquityGuard-V1.2==="; 
extern bool   MonitorEquity=true;
extern string eg0="---Maximal Target Sets:---";
extern bool   MaximalTargetON=true;
extern double MaximalTarget=5000;
extern bool   DisableAllEAs1=true;
extern bool   CloseAllActiveOrders1=true;
extern bool   DeleteAllPendingOrders1=true;

extern string eg1="---Minimal Target Sets:---";
extern bool   MinimalTargetON=true;
extern double MinimalTarget=2000;
extern bool   DisableAllEAs2=true;
extern bool   CloseAllActiveOrders2=true;
extern bool   DeleteAllPendingOrders2=true;

extern string eg2="---Percent Drawdown Sets:---";
extern bool   PercentDrawdownON=true;
extern double PercentDrawdown=15;
extern bool   DisableAllEAs3=true;
extern bool   CloseAllActiveOrders3=true;
extern bool   DeleteAllPendingOrders3=true;

 

extern string eg4="---Alert Sets:---";
extern bool   SoundON=true;
extern string SoundFile="alert.wav";
extern bool   SendEmailON=false;
extern color  TxtColor=DarkOrange;
extern color numClolor=Lime;
extern string ProgrammingService="Ryan: forexprogramming@gmail.com";
       
 
int      Slippage = 3;
int      TotalTries = 5; 
int      RetryDelay = 1000;
bool     Runable=true;


double EorB;
color wornColor=Red; 


int init()
  {
   Runable=true;// CreatLabel("Equity Upper Target : " +DoubleToStr(MaximalTarget,Digits)+"\n"+"Equity Lower Target : "+DoubleToStr(MinimalTarget,Digits));
   
   if(MonitorEquity)EorB=AccountEquity();else EorB=AccountBalance(); 
   if(MaximalTarget<=EorB) {Runable=false; CreatLabel("eg3","Wrong Parameter for MaximalTarget ! ",0,5,35,wornColor);   }
   if(MinimalTarget>=EorB) {Runable=false; CreatLabel("eg31","Wrong Parameter for MinimalTarget ! ",0,5,50,wornColor);   }
   if(!IsDllsAllowed())     {Runable=false; CreatLabel("eg32","DLL is not allowed ! ",0,5,65,wornColor);   }
   if(!IsTradeAllowed())    {Runable=false; CreatLabel("eg33","Trade is not allowed ! ",0,5,80,wornColor);   }
   
   
   GlobalVariableSet("HighestEquity",EorB); //初始化时记录下当时的资金量
   GlobalVariableSet("LowestEquity",EorB); //初始化时记录下当时的资金量
   
   ShowLogo(); 
 
   start();

   return(0);
  }

int deinit()
  {
   DelAllTxts();
   return(0);
  }
void DelAllTxts()
{
   ObjectDelete("logo1");
   ObjectDelete("logo2");
   ObjectDelete("eg1");ObjectDelete("eg2");
   ObjectDelete("eg3");
   ObjectDelete("eg31");
   ObjectDelete("eg32");
   ObjectDelete("eg33");
   ObjectDelete("eg34");
   ObjectDelete("eg35");
   ObjectDelete("eg4");
   ObjectDelete("eg41");
   ObjectDelete("eg42");
   ObjectDelete("eg43");
   
   ObjectDelete("eg5");
   ObjectDelete("eg51");
   ObjectDelete("eg52");
   ObjectDelete("eg53");
   ObjectDelete("eg6");
   ObjectDelete("eg61");
   ObjectDelete("eg62");
   ObjectDelete("eg63");
   GlobalVariableDel("HighestEquity");
   GlobalVariableDel("LowestEquity");
   WindowRedraw();
}  
void ShowEAStatus()
{    
     string s1,s2,s3,s4,s5;
     double target;
     if(MonitorEquity)EorB=AccountEquity();else EorB=AccountBalance();
     CreatLabel("eg1","   "+EAName,0,5,15,TxtColor);
     CreatLabel("eg2","------------------------------------------------",0,5,22,TxtColor);
     
     
     target=GlobalVariableGet("HighestEquity")*(1-PercentDrawdown*0.01);
     
     string seb;
     if(MonitorEquity) seb="Equity";else seb="Balance";
     
     if(MonitorEquity) 
         s1="Current Equity:"+DoubleToStr(EorB,2)+"              Highest Equity:"+DoubleToStr(GlobalVariableGet("HighestEquity"),2); 
      else 
         s1="Current Balance:"+DoubleToStr(EorB,2)+"          Highest Balance:"+DoubleToStr(GlobalVariableGet("HighestEquity"),2);
     CreatLabel("eg3", "Current "+seb+": ",0,5,35,TxtColor);   CreatLabel("eg31",DoubleToStr(EorB,2),0,95,35,numClolor); 
     CreatLabel("eg32","Highest "+seb+": ",0,5,50,TxtColor);   CreatLabel("eg33",DoubleToStr(GlobalVariableGet("HighestEquity"),2),0,95,50,numClolor); 
     CreatLabel("eg34","Lowest "+seb+": ",0,5,65,TxtColor);    CreatLabel("eg35",DoubleToStr(GlobalVariableGet("LowestEquity"),2),0,95,65,numClolor); 
      
     if(MaximalTargetON) s2=DoubleToStr(MaximalTarget,2)+ "       Distance:"+DoubleToStr(MaximalTarget-EorB,2) ; else s2="OFF";
   
     CreatLabel("eg4","Maximal Target "+onoff(MaximalTargetON)+": ",0,5,80,TxtColor); 
     CreatLabel("eg41",DoubleToStr(MaximalTarget,2),0,130,80,numClolor); 
     CreatLabel("eg42","Distance:",0,190,80,TxtColor); 
     CreatLabel("eg43",DoubleToStr(MaximalTarget-EorB,2),0,250,80,numClolor); 

     CreatLabel("eg5","Minimal  Target "+onoff(MinimalTargetON)+": ",0,5,95,TxtColor); 
     CreatLabel("eg51",DoubleToStr(MinimalTarget,2),0,130,95,numClolor); 
     CreatLabel("eg52","Distance:",0,190,95,TxtColor); 
     CreatLabel("eg53",DoubleToStr(EorB-MinimalTarget,2) ,0,250,95,numClolor); 
     
     CreatLabel("eg6","Percent  DrawD "+onoff(PercentDrawdownON)+": ",0,5,110,TxtColor); 
     CreatLabel("eg61",DoubleToStr(PercentDrawdown,2)+"%["+DoubleToStr(target,2)+"]",0,130,110,numClolor); 
     CreatLabel("eg62","Distance:",0,230,110,TxtColor); 
     CreatLabel("eg63",DoubleToStr(MathAbs(target-EorB),2) ,0,290,110,numClolor); 

 
     WindowRedraw();

}

string onoff(bool on)
{
   if(on) return("[ON]"); else return("[OFF]");
}

int start() 
{    
   
   while( !IsStopped() ) 
   {  
      if (Runable==false){CreatLabel("eg2","Please Reset EquityGuard  Parameters! ",0,5,22,wornColor); return(0);}
      RefreshRates();
      if(MonitorEquity)EorB=AccountEquity();else EorB=AccountBalance();
      if(EorB>GlobalVariableGet("HighestEquity")) GlobalVariableSet("HighestEquity",EorB);
      if(EorB<GlobalVariableGet("LowestEquity"))  GlobalVariableSet("LowestEquity",EorB);
      
      ShowEAStatus();
      EquityGuard();
      Sleep(1000);
   }
   return(0);
}

void EquityGuard()
{
      if(MaximalTargetON&& (EorB>=MaximalTarget) )  
       {  Runable=false; 
          if(SoundON) PlaySound(SoundFile);
          if(SendEmailON){SendMail("EquityGuard:Reach to Maximal Target "+EorB,"");}
          if (IsExpertEnabled()==true &&DisableAllEAs1==true) {DelAllTxts();DisableEA();Runable=false;}
          if(CloseAllActiveOrders1)   CloseAllActiveOrders();
          if(DeleteAllPendingOrders1) DelAllPendingOrders();        
          
          }
      if(MinimalTargetON&& EorB<=MinimalTarget)  
       {  Runable=false;  
          if(SoundON) PlaySound(SoundFile);
          if(SendEmailON){SendMail("EquityGuard:Reach to Minimal Target "+EorB,"");}
          if (IsExpertEnabled()==true && DisableAllEAs2==true) {DelAllTxts();DisableEA();}
          if(CloseAllActiveOrders2)   CloseAllActiveOrders();
          if(DeleteAllPendingOrders2) DelAllPendingOrders();          
          
          }
      if(PercentDrawdownON&& EorB<=GlobalVariableGet("HighestEquity")*(1-PercentDrawdown*0.01))  
       {   
          Runable=false;
          if(SoundON) PlaySound(SoundFile);
          if(SendEmailON){SendMail("EquityGuard:Reach to Percent Drawdown "+EorB,"");}
          if (IsExpertEnabled()==true && DisableAllEAs3==true) {DelAllTxts();DisableEA();}
          if(CloseAllActiveOrders3)   CloseAllActiveOrders();
          if(DeleteAllPendingOrders3) DelAllPendingOrders();          
        }
        
}


void DisableEA()
{ 
  while(IsExpertEnabled())
  {
        Alert("Expert Will Be Disabled Now!");Sleep(500);
        
        keybd_event(13,0,0,0); // 13=return
        keybd_event(13,0,KEYEVENTF_KEYUP,0);
        
        
        keybd_event(17,0,0,0); // 17=Ctrl
        keybd_event(69,0,0,0); // 69=E
        keybd_event(69,0,KEYEVENTF_KEYUP,0);
        keybd_event(17,0,KEYEVENTF_KEYUP,0);
        Sleep(500);
 }      
 if(IsExpertEnabled()==false)Print("Equity Guard:  Expert Is Disabled At "+TimeToStr (TimeCurrent(),TIME_DATE|TIME_SECONDS));
}

void DelAllPendingOrders()
{
  while (AllPendingOrders()>0)
  {  
     for(int i=0; i<OrdersTotal(); i++) 
     {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) 
            {if (OrderType() >1)   DelPendingOrder(OrderTicket());}
     }
  }
  Print("Equity Guard:  All Pending Orders Have Been Deleted!");
}

bool DelPendingOrder(int ticket)//lee yan
{
	 bool result=false;
    int  cnt=0 ;

    while (cnt < TotalTries)
    {
      result = OrderDelete(ticket);
	   if (result == true) 	return(true);//执行成功 直接退出
      if(GetLastError()>0)  cnt++;
		if(cnt<TotalTries) Sleep(RetryDelay);
	  }  
   return(false);
}



void CloseAllActiveOrders()
{
  while (AllActiveOrders()>0)
  {  
     for(int i=0; i<OrdersTotal(); i++) 
     {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) 
        {if (OrderType() == OP_BUY || OrderType() == OP_SELL)   CloseOrder(OrderTicket(),OrderLots()) ;}
     }
  }
  Print("Equity Guard:  All Active Orders Have Been Closed!");
}


int AllActiveOrders()
{
   int num = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType() == OP_BUY || OrderType() == OP_SELL )  num++;
     }
   return(num);
}

int AllPendingOrders()
{
   int num = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType() >1 )  num++;
     }
   return(num);
}



bool CloseOrder(int ticket, double Lots) 
{
	 bool exit_loop = false, result=false;
    int cnt=0 ;
    double myPrice;
    
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true)
    {
         
         while (cnt < TotalTries)
         {
           RefreshRates(); 
           if (OrderType() == OP_BUY)  myPrice =MarketInfo(OrderSymbol(),MODE_BID);
           if (OrderType() == OP_SELL) myPrice = MarketInfo(OrderSymbol(),MODE_ASK);
           if (MarketInfo(OrderSymbol(),MODE_DIGITS) > 0)  myPrice = NormalizeDouble( myPrice, MarketInfo(OrderSymbol(),MODE_DIGITS));

           result=OrderClose(ticket,Lots,myPrice,Slippage,Violet);
	        if (result == true) 	return(true); 
	        
           if(GetLastError()>0)  cnt++;   
		     if(cnt<TotalTries) Sleep(RetryDelay);
	       }  
   
	 }   
   return(false);
}



void CreatLabel(string LabelName, string LabelStr,int corner,double x,double y ,color cl )
{  

   ObjectDelete(LabelName);
   ObjectCreate(LabelName, OBJ_LABEL, 0, 0, 0);
	ObjectSet(LabelName, OBJPROP_CORNER, corner);
	ObjectSet(LabelName, OBJPROP_XDISTANCE, x);
	ObjectSet(LabelName, OBJPROP_YDISTANCE, y);
	ObjectSetText(LabelName, LabelStr, 9, "Arial Bold", cl);
} 

void ShowLogo()
{
   CreatLabel("logo1","SKYPE  :   lee_yan_cn",2,5,20,TxtColor);
   CreatLabel("logo2","E-Mail :   forexprogramming@gmail.com",2,5,5,TxtColor);
}

