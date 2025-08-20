
#property copyright "EATA Pollan vers."
#property link      "lg06@windowslive.com "

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Aqua
//---- input parameters

extern int       CCI_per=14;
extern int       RSI_per=14;
extern bool arrows            = true;
double a=0,a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0,a8=0;
double b=0,b1=0,b2=0,b3=0,b4=0,b5=0,b6=0,b7=0,b8=0;
double tt1max=0,tt2min=0;


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
string sPrefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexBuffer(1,ExtMapBuffer2);
SetIndexLabel(0, "CCI-RSI");   
SetIndexLabel(1, "RSI-CCI");   
sPrefix ="EATA pollan vers (" + CCI_per + ", " + RSI_per +" )";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
DelOb();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
      {
   int limit=Bars-IndicatorCounted();
   
   for(int i=limit-1;i>=0;i--) 
   {
           
            
            
            
            
           a=iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i);
            a1=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-1)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+1));
             a2=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-2)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+2));
             a3=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-3)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+3));
               a4=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-4)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+4));
               a5=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-5)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+5));
                 a6=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-6)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+6));
                  a7=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-7)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+7));
                   a8=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i-8)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i+8));
                   
                   
                   tt1max=a+a1+a2+a3+a4+a5+a6+a7+a8;
                   
           b=iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i);
            b1=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-1)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+1));
             b2=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-2)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+2));
              b3=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-3)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+3));
               b4=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-4)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+4));
                b5=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-5)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+5));
                 b6=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-6)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+6));
                 b7=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-7)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+7));
                   b8=(iCustom(NULL,0,"BtTrendTrigger-T-Signal",RSI_per,PRICE_TYPICAL,i-8)-iCustom(NULL,0,"BtTrendTrigger-T-Signal",CCI_per,PRICE_CLOSE,i+8));
                   
                   tt2min=b+b1+b2+b3+b4+b5+b6+b7+b8;
                   
                   
                   ExtMapBuffer1[i]=tt1max;
                   ExtMapBuffer2[i-8]=-tt1max;
                   
      if(arrows)
      {
        if(ExtMapBuffer1[i]>=ExtMapBuffer2[i] && ExtMapBuffer1[i+1]<ExtMapBuffer2[i+1])
        {
        DrawAr("up",i);
        }
        if(ExtMapBuffer1[i]<=ExtMapBuffer2[i] && ExtMapBuffer1[i+1]>ExtMapBuffer2[i+1])
        {
        DrawAr("dn",i);
        }      
       }
                       
                   
                   
  }  
   return(0);
}

void DelOb()
{
    int n = ObjectsTotal();
    for (int i = n - 1; i >= 0; i--) 
    {
     string sName = ObjectName(i);
	  if (StringFind(sName, sPrefix) == 0) 
	  {
	    ObjectDelete(sName);
	  }
    }
}

//----------------------------------------------------------------------
void DrawAr(string ssName, int i)
{
    
    string sName=sPrefix+" "+ssName+" "+ TimeToStr(Time[i],TIME_DATE|TIME_MINUTES);
    //ObjectDelete(sName);    
    ObjectCreate(sName, OBJ_ARROW, 0, Time[i], 0);
    if(ssName=="up")
    {
    ObjectSet(sName, OBJPROP_ARROWCODE,  225);
    ObjectSet(sName, OBJPROP_PRICE1, Low[i]-4*Point);
    ObjectSet(sName, OBJPROP_COLOR, Gold);
    }
    if(ssName=="dn")
    {
    ObjectSet(sName, OBJPROP_ARROWCODE,  226);
    ObjectSet(sName, OBJPROP_PRICE1, High[i]+7*Point);
    ObjectSet(sName, OBJPROP_COLOR, Gold);    
    }    
    ObjectSet(sName, OBJPROP_WIDTH, 1);
} 
                   
                   
                    
          
   
   
  
  




//---------------------------------------------------------+