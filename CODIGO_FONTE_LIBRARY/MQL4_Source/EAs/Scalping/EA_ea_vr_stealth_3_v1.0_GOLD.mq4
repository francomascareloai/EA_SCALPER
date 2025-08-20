//+------------------------------------------------------------------+
//|                                                VR---STEALS-3.mq4 |
//|                     "Copyright 2014, www.trading-go.ru Project." |
#property version     "3.3"
#property description "Virtual StopLoss, TakeProfit, Breakeven, Traling stop, OrderClose, OrderDelete "
//#property strict
#import "shell32.dll"
int ShellExecuteW(int hwnd,string lpOperation,string lpFile,string lpParameters,string lpDirectory,int nShowCmd);
#import
#include <Dope_mod.mqh>;                   

//+------------------------------------------------------------------+
//|                                               |
//+------------------------------------------------------------------+
input double StartLots=1.0; //0.01;
input int    Risk=2; 
input int    TakeProfit=0; //100;
input int    StopLoss=5000; //100;
input bool   Trailing=true;
input int    TrailingStop=2000; //300;
input int    TrailingStep=300; //50;
input int    TrailStart=600; //250;
input int    Breakeven=300;
input int    Stop_Limit=250;
input int    Magic=0;
input int    Slip=20;
input int    MaxSpread=300;
input int    MaxOrders=20;
color  cvit[];
int    w=-1,x=0,y=0,ButX=17,BuyY=15,Coment=10, MagicID, prevSig,Slippage, sig,esig;
string Puti="",InpFileName="",info[],prefix="zr",prfx, addTxt;
double tp=0,sl=0,tr=0,br=0,wlot=0,glot=0, Gd_188, Lots;
bool  noBuy = false, noSell = false;
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");                                    
   //if(EventSetMillisecondTimer(100)==true)        
   //   pr("Expert startet OK!!!");              
   //else                                       
   //pr("Error start");                       

   if(StartLots<MarketInfo(_Symbol,MODE_MINLOT)) 
      wlot=MarketInfo(_Symbol,MODE_MINLOT);           
   else                                        
   wlot= StartLots;                           

   if(StartLots>MarketInfo(_Symbol,MODE_MAXLOT)) 
      wlot=MarketInfo(_Symbol,MODE_MAXLOT);        
   else                                          
   wlot= StartLots;            
   Lots= StartLots;
   glot=wlot;                                

   tp=NormalizeDouble(TakeProfit *_Point,_Digits); 
   sl=NormalizeDouble(StopLoss   *_Point,_Digits); 
   tr=NormalizeDouble(TrailingStop*_Point,_Digits); 
   br=NormalizeDouble(Breakeven  *_Point,_Digits);
Slippage=Slip;
MagicID=Magic;
prfx=_Symbol+"-"+_Period;
        ChartSetInteger(0,17,0,0);
        ChartSetInteger(0,0,1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(IsOptimization()) 
     {
      Print("Error !");                 
      return;                                     
     }
   if(!IsTesting() && !IsOptimization()) 
     {
      while(!IsStopped())
        {                                          
         but();                                 
         Sleep(100);                             
        }
     }
   else   but();   
   //dope(); 
   f0_8(); //panel                         
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void but()
  {
   proverca_sl_tp_ti();   
   proverca_br_tr();      
   if(ObjectFind(0,prefix+"TradeLine")!=0) 
      ButtonCreate(0,"TradeLine",0,5,15,90,5,0,"","Arial",10,clrBlack,clrBlue,clrNONE,false,false,true); 

   int x0=(int)IntGetX ("TradeLine");         
   int y0=(int)IntGetY ("TradeLine");        

   ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",10,clrBlack,C'236,233,216'); 
   ButtonCreate(0,"Buy",0,x0,y0+34,90,16,0,"BUY","Arial",10,clrBlack,C'236,233,216');                    
   ButtonCreate(0,"Sel",0,x0,y0+54,90,16,0,"SELL","Arial",10,clrBlack,C'236,233,216');                      
   ButtonCreate(0,"BuyL",0,x0,y0+74,90,16,0,"BUY LIMIT","Arial",10,clrBlack,C'236,233,216');              
   ButtonCreate(0,"SelL",0,x0,y0+94,90,16,0,"SELL LIMIT","Arial",10,clrBlack,C'236,233,216');         
   ButtonCreate(0,"BuyS",0,x0,y0+114,90,16,0,"BUY STOP","Arial",10,clrBlack,C'236,233,216');            
   ButtonCreate(0,"SelS",0,x0,y0+134,90,16,0,"SELL STOP","Arial",10,clrBlack,C'236,233,216');               
   ButtonCreate(0,"Close",0,x0,y0+154,90,16,0,"CLOSE ALL","Arial",9,clrBlack,clrPink);         
   ButtonCreate(0,"Sclp",0,x0,y0+174,90,16,0,"Auto-Scalp","Arial",9,clrBlack,C'236,233,216');
   ButtonCreate(0,"Trl",0,x0,y0+194,90,16,0,"Trail All","Arial",9,clrBlack,C'236,233,216'); 
   ButtonCreate(0,"NB",0,x0,y0+214,90,16,0,"No BUY","Arial",9,clrBlack,C'236,233,216'); 
   ButtonCreate(0,"NS",0,x0,y0+234,90,16,0,"No SELL","Arial",9,clrBlack,C'236,233,216'); 
   ButtonCreate(0,"CB",0,x0,y0+254,90,16,0,"Close BUY","Arial",9,clrBlack,C'236,233,216'); 
   ButtonCreate(0,"CS",0,x0,y0+274,90,16,0,"Close SELL","Arial",9,clrBlack,C'236,233,216'); 
   //==
   ButtonCreate(0,"Sep",0,x0,y0+294,90,5,0,"","Arial",10,clrBlack,clrBlue,clrNONE,false,false,true); 
   ButtonCreate(0,"TimeT",0,x0,y0+314,90,16,0,"Candle Time","Arial",9,clrBlack,C'236,233,216');      
   ButtonCreate(0,"ScreenShot",0,x0,y0+334,90,16,0,"SCREENSHOT","Arial",9,clrBlack,C'236,233,216'); 
   ChartRedraw(0);

   if(but_stat(prefix+"TimeT")==true)
      tim();
   else
      obj_del("clock");

   if(but_stat(prefix+"LOTS")==true) 
     {
      for(int i=0; i<=20; i++)
        {
         ButtonCreate(0,StringConcatenate("lot",i),0,x0+105,y0+15+20*i,50,18,0,DoubleToStr(wlot*(i+1),2),"Arial",10,clrBlack,C'236,233,216'); 
         if(but_stat(StringConcatenate(prefix,"lot",i))==true) 
           {
            glot=wlot*(i+1);                                                                           
            button_off(StringConcatenate("lot",i));                                                 
            button_off("LOTS");                                                                      
           }
        }
     }
   else                                                                                            
   for(int xx=0; xx<=20; xx++)
              ObjectDelete(StringConcatenate(prefix,"lot",xx));                                        
   ChartRedraw(0);

   double Dist=NormalizeDouble(Stop_Limit*_Point,_Digits);
   if(but_stat(prefix+"Buy")==true) 
      if(openorders(_Symbol,0,glot)==true) 
         button_off("Buy");                
   if(but_stat(prefix+"Sel")==true) 
      if(openorders(_Symbol,1,glot)==true) 
         button_off("Sel");                           
   if(but_stat(prefix+"BuyL")==true) 
      if(openorders(_Symbol,2,glot,Ask-Dist)==true) 
         button_off("BuyL");                     
   if(but_stat(prefix+"SelL")==true) 
      if(openorders(_Symbol,3,glot,Bid+Dist)==true)
         button_off("SelL");                     
   if(but_stat(prefix+"BuyS")==true) 
      if(openorders(_Symbol,4,glot,Ask+Dist)==true) 
         button_off("BuyS");                         
   if(but_stat(prefix+"SelS")==true) 
      if(openorders(_Symbol,5,glot,Bid-Dist)==true) 
         button_off("SelS");  
   if(but_stat(prefix+"Close")==true) 
      {
         CloseAll(); 
         button_off("Close");
      }                       
   if(but_stat(prefix+"Sclp")==true) 
   {  addTxt="DOPE scalping ON";
      dope();
   }
   else {addTxt=""; button_off("Sclp");}
   
   if(but_stat(prefix+"Trl")==true) //overrides Trailing in input settings; the function is in mqh
   {  
        //Trailing == true;
      trailing();
   }
   else { button_off("Trl");}
   
  if(but_stat(prefix+"NB")==true) 
   {  noBuy=true;
   }
   else {noBuy=false; button_off("NB");}
  
  if(but_stat(prefix+"NS")==true) 
   {  noSell=true;
   }
   else {noSell=false; button_off("NS");}
  //== Closing with buttons 
   if(but_stat(prefix+"CB")==true) 
   {  CloseBuy();
      button_off("CB");
   } 
  if(but_stat(prefix+"CS")==true) 
   {  CloseSell();
   button_off("CS");}
 //== 
   
   
   for( i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || Magic==-1)
            if(OrderSymbol()==_Symbol)
              {
               x=y=0;ChartTimePriceToXY(0,0,(OrderOpenTime()),OrderOpenPrice(),x,y); 
               if(ObjectFind(StringConcatenate(prefix+"Re",OrderTicket()))!=0)      
                  ButtonCreate(0,StringConcatenate("Re",OrderTicket()),0,x+20,y,ButX+5,BuyY,0,"< >","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,true,true,0,"Move the menu");     
               SetX(StringConcatenate(prefix+"Re",OrderTicket()),y);                                                                                                                    
               int x2=(int)IntGetX (StringConcatenate("Re",OrderTicket()));                                                                                                           
               int y2=(int)IntGetY (StringConcatenate("Re",OrderTicket()));                                                                                                            
               ButtonCreate(0,StringConcatenate("Sl",OrderTicket()),0,x2+25,y2,ButX,BuyY,0,"Sl","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"StopLoss");       
               ButtonCreate(0,StringConcatenate("Tp",OrderTicket()),0,x2+45 ,y2,ButX,BuyY,0,"Tp","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"TakeProfit");      
               ButtonCreate(0,StringConcatenate("Br",OrderTicket()),0,x2+65 ,y2,ButX,BuyY,0,"Br","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"Breakeven");       
               ButtonCreate(0,StringConcatenate("Tr",OrderTicket()),0,x2+85 ,y2,ButX,BuyY,0,"Tr","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"Ttrailing Stop");  
               ButtonCreate(0,StringConcatenate("Ti",OrderTicket()),0,x2+105,y2,ButX,BuyY,0,"Ti","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"Time Close");   
               ButtonCreate(0,StringConcatenate("Xx",OrderTicket()),0,x2+125,y2,ButX,BuyY,0,"X","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"Close Order");   
              }
// ---              
   for( i=ObjectsTotal()-1; i>=0; i--)
      if(ObjectType(ObjectName(i))==OBJ_BUTTON)
         if(but_stat(ObjectName(i))==true)
            ObjectSetInteger(0,ObjectName(i),OBJPROP_BGCOLOR,clrLightGreen);
   else
      ObjectSetInteger(0,ObjectName(i),OBJPROP_BGCOLOR,C'236,233,216'); 
  
  
  

   if(but_stat(prefix+"ScreenShot")==true) 
     {
      Puti=StringConcatenate(TimeS()+" "+_Symbol+".png");              
      if(WindowScreenShot(Puti,(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS),(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))==true)
         w=MessageBox(" Open ? "+Puti,"Open SCREENSHOT "+Puti,MB_OKCANCEL|MB_ICONQUESTION);                                  
      if(w==1)
         if(ShellExecuteW(NULL,"open",TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+Puti,NULL,NULL,1)>0)              
            button_off("ScreenShot");                                                                                           
      if(w==2)                                                                                               
         button_off("ScreenShot");               
     }
     
// ---
   int tik=-1,typ=-1;
   string nameX="",nameTP="",nameSL="",nameBR="",nameTR="",nameTI="";
   double op=0;
   for( i=OrdersTotal()-1; i>=0; i--)                                                          
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                                               
         if(OrderMagicNumber()==Magic || Magic==-1)                                              
            if(OrderSymbol()==_Symbol)                                                     
              {
               tik=OrderTicket();                                                         
               typ=OrderType();                                                           
               op=OrderOpenPrice();                                                          
               nameX =StringConcatenate(prefix,"Xx",tik);                                
               nameTP=StringConcatenate(prefix,"Tp",tik);                              
               nameSL=StringConcatenate(prefix,"Sl",tik);                                 
               nameBR=StringConcatenate(prefix,"Br",tik);                                   
               nameTR=StringConcatenate(prefix,"Tr",tik);                                    
               nameTI=StringConcatenate(prefix,"Ti",tik);                                        
               if(ObjectGetInteger(0,nameX,OBJPROP_STATE)==true) closeorders(tik);              

               if(typ==0 )
                 {
                  if(but_stat(nameTP)==true)                                                     
                     obj_cre(StringConcatenate("tp",tik),(Ask+tp),clrGreen);                         
                  else                                                                             
                  obj_del(StringConcatenate("tp",tik));                                           

                  if(but_stat(nameSL)==true)                                                       
                     obj_cre(StringConcatenate("sl",tik),(Bid-sl),clrRed);                          
                  else                                                                              
                  obj_del(StringConcatenate("sl",tik));                                           
                 }
               if(typ==1 )
                 {
                  if(but_stat(nameTP)==true)                                                       
                     obj_cre(StringConcatenate("tp",tik),(Bid-tp),clrGreen);                        
                  else                                                                             
                  obj_del(StringConcatenate("tp",tik));                                         

                  if(but_stat(nameSL)==true)                                                       
                     obj_cre(StringConcatenate("sl",tik),(Ask+sl),clrRed);                        
                  else                                                                          
                  obj_del(StringConcatenate("sl",tik));                                         
                 }
                 
               if(typ==2 || typ==4)
                 {
                  if(but_stat(nameTP)==true)                                                     
                     obj_cre(StringConcatenate("tp",tik),(op+tp),clrGreen);                     
                  else                                                                         
                  obj_del(StringConcatenate("tp",tik));                                   

                  if(but_stat(nameSL)==true)                                                    
                     obj_cre(StringConcatenate("sl",tik),(op-sl),clrRed);                     
                  else                                                                         
                  obj_del(StringConcatenate("sl",tik));                                         
                 }
               if(typ==3 || typ==5)
                 {
                  if(but_stat(nameTP)==true)                                                      
                     obj_cre(StringConcatenate("tp",tik),(op-tp),clrGreen);                    
                  else                                                                             
                  obj_del(StringConcatenate("tp",tik));                                         

                  if(but_stat(nameSL)==true)                                                     
                     obj_cre(StringConcatenate("sl",tik),(op+sl),clrRed);                    
                  else                                                                  
                  obj_del(StringConcatenate("sl",tik));                             
                 }




                 
               if(but_stat(nameBR)==true) 
                 {
                  if(((Ask-br)>op) && typ==0) obj_cre(StringConcatenate("br",tik),op,clrGreen);       
                  if(((Bid+br)<op) && typ==1) obj_cre(StringConcatenate("br",tik),op,clrGreen);     
                 }
               else obj_del(StringConcatenate("br",tik));                                         

               if(but_stat(nameTR)==true) 
                 {
                  if(((Ask-tr)>op) && typ==0) obj_cre(StringConcatenate("tr",tik),op,clrGreen);      
                  if(((Bid+tr)<op) && typ==1) obj_cre(StringConcatenate("tr",tik),op,clrGreen);    
                 }
               else obj_del(StringConcatenate("tr",tik));                                         

               if(but_stat(nameTI)==true)                                                          
                  obj_cre_v_line(StringConcatenate("ti",tik),clrGreen);                   
               else                                                                           
               obj_del(StringConcatenate("ti",tik));                                          
              }

   his_del_obj();        

   uroven();            
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void uroven()
  {
   int typ=-1,tik=-1;   double op=0;   string name="";
   for(int i=OrdersTotal()-1; i>=0; i--)                                                        
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                                     
         if(OrderMagicNumber()==Magic || Magic==-1)                                                 
            if(OrderSymbol()==_Symbol)
              {
               typ=OrderType();                                                                  
               tik=OrderTicket();                                                                
               op=NormalizeDouble(OrderOpenPrice(),_Digits);                                   
               name=StringConcatenate("Op",tik);                                                   
               if(typ==2 || typ==4)                                                          
                 {
                  if(ObjectFind(0,name)==-1)                                                    
                     obj_cre_h_line(name,op,clrBlue);                                    
                 }
               if(typ==3 || typ==5) 
                 {
                  if(ObjectFind(0,name)==-1)                                                 
                     obj_cre_h_line(name,op,clrOrangeRed);                                  
                 }
               if(ObjectFind(0,name)==0)                                                   
                  if(op!=NormalizeDouble(get_object(name),_Digits))                          
                     if(OrderModify(OrderTicket(),NormalizeDouble(get_object(name),_Digits),OrderStopLoss(),OrderTakeProfit(),0,clrGreen)==true)
                        pr(" OrderModify Ok !");                                               
               else                                                                          
               pr(__FUNCTION__+"OrderModify Error !");                                       
              }
  }
//+------------------------------------------------------------------+
//|                        |
//+------------------------------------------------------------------+
void obj_cre_h_line(string txt,double pri,color col)
  {
   if(ObjectFind(0,txt)==-1)
     {
      ObjectCreate(0,txt,OBJ_HLINE,0,0,0);
      ObjectSetDouble(0,txt,OBJPROP_PRICE1,pri);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,txt,OBJPROP_STYLE,3);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void proverca_br_tr()
  {
   int tik=-1;
   double bb=0,rr=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || Magic==-1)
            if(OrderSymbol()==_Symbol)
              {
               tik=OrderTicket();
               bb=NormalizeDouble(get_object(StringConcatenate("br",tik)),_Digits);
               rr=NormalizeDouble(get_object(StringConcatenate("tr",tik)),_Digits);
               RefreshRates();
               if(OrderType()==0)
                  if(bb>0)
                     if(Bid<=bb)
                        closeorders(tik);

               if(OrderType()==1)
                  if(bb>0)
                     if(Ask>=bb)
                        closeorders(tik);
               //-----------------------------//
               if(OrderType()==0)
                  if(rr>0)
                    {
                     if((Bid-tr)>rr)
                        set_object(StringConcatenate("tr",tik),(Ask-tr));
                     if(Bid<=rr)
                        closeorders(tik);
                    }
               if(OrderType()==1)
                  if(rr>0)
                    {
                     if((Ask+tr)<rr)
                        set_object(StringConcatenate("tr",tik),(Bid+tr));
                     if(Ask>=rr)
                        closeorders(tik);
                    }
              }
  }
//+------------------------------------------------------------------+
//|                |
//+------------------------------------------------------------------+
bool set_object(string name,double pri)
  {
   return ObjectSetDouble(0,name,OBJPROP_PRICE,pri);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool proverca_sl_tp_ti()
  {
   int tik=-1;
   string ti="";
   double tt=0,ss=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || Magic==-1)
            if(OrderSymbol()==_Symbol)
              {
               tik=OrderTicket();
               tt=NormalizeDouble(get_object(StringConcatenate("tp",tik)),_Digits);
               ss=NormalizeDouble(get_object(StringConcatenate("sl",tik)),_Digits);
               ti=StringConcatenate("ti",tik);
               RefreshRates();
               if(OrderType()==0)
                 {
                  if(tt>0)
                     if(Bid>tt)
                        closeorders(tik);

                  if(ss>0)
                     if(Bid<ss)
                        closeorders(tik);

                  if(ObjectFind(ti)==0)if((int)TimeCurrent()>(int)get_object_ti(ti))closeorders(tik);
                 }
               if(OrderType()==1)
                 {
                  if(tt>0)
                     if(Ask<tt)
                        closeorders(tik);

                  if(ss>0)
                     if(Ask>ss)
                        closeorders(tik);

                  if(ObjectFind(ti)==0)if((int)TimeCurrent()>(int)get_object_ti(ti))closeorders(tik);
                 }
               if(OrderType()>1)
                  if(ObjectFind(ti)==0)if((int)TimeCurrent()>(int)get_object_ti(ti))closeorders(tik);
              }
   return false;
  }
//+------------------------------------------------------------------+
//|              |
//+------------------------------------------------------------------+
datetime get_object_ti(string name)
  {
   return (datetime)ObjectGetInteger(0,name,OBJPROP_TIME);
  }
//+------------------------------------------------------------------+
//|                                   |
//+------------------------------------------------------------------+
double get_object(string name)
  {
   double rez=0;
   ObjectGetDouble(0,name,OBJPROP_PRICE,0,rez);
   return rez;
  }
//+------------------------------------------------------------------+
//|            |
//+------------------------------------------------------------------+
void his_del_obj()
  {
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderMagicNumber()==Magic || Magic==-1)
            if(OrderSymbol()==_Symbol)
              {
               ObjectDelete(0,StringConcatenate(prefix,"Sl",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Tp",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Br",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Tr",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Ti",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Re",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Xx",OrderTicket()));
               ObjectDelete(0,StringConcatenate("Op",OrderTicket()));
               ObjectDelete(0,StringConcatenate("sl",OrderTicket()));
               ObjectDelete(0,StringConcatenate("tp",OrderTicket()));
               ObjectDelete(0,StringConcatenate("br",OrderTicket()));
               ObjectDelete(0,StringConcatenate("tr",OrderTicket()));
               ObjectDelete(0,StringConcatenate("ti",OrderTicket()));

              }
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void obj_cre_v_line(string txt,color col)
  {
   if(ObjectFind(0,txt)==-1)
     {
      ObjectCreate(0,txt,OBJ_VLINE,0,Time[0]+_Period*10*60,0);
      ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]+_Period*10*60);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,2);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void obj_cre(string txt,double pri,color col)
  {
   if(ObjectFind(0,txt)==-1)
     {
      ObjectCreate(0,txt,OBJ_ARROW_RIGHT_PRICE,0,Time[0],pri);
      ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]);
      ObjectSetDouble(0,txt,OBJPROP_PRICE,pri);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,3);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                |
//+------------------------------------------------------------------+
void obj_del(string txt)
  {
   ObjectDelete(0,txt);
  }
//+------------------------------------------------------------------+
//|                           |
//+------------------------------------------------------------------+
bool closeorders(int tik)
  {
   string sy="";
   if(OrderSelect(tik,SELECT_BY_TICKET))
      if(OrderMagicNumber()==Magic || Magic==-1)
         if(OrderSymbol()==_Symbol)
            if(OrderTicket()==tik)
              {
               sy=OrderSymbol();
               if(OrderType()==0) 
                  if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(sy,MODE_BID),Slip,clrBlue)==true)
                     pr("BUY order closed");                                                        
               else
                  pr("BUY order close Error !!!"+Error(GetLastError()),clrRed);            

               if(OrderType()==1) 
                  if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(sy,MODE_ASK),Slip,clrRed)==true)
                     pr("SELL order closed ");                                                       
               else
                  pr("SELL order close Error !!!"+Error(GetLastError()),clrRed);               
               
               if(OrderType()>1)                                                                 
                  if(OrderDelete(tik,clrRed)==true)                                                
                     pr("Pending ord. deleted");                                                     
               else
                  pr("Pending ord. delete Error !!!"+Error(GetLastError()),clrRed);                       
              }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetX(const string name,int xx)
  {
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,xx);              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openorders(string sy="",int typ=0,double lot=0,double price=0,string com="") 
  {
   int tik=-2,p=0;  
   color col;  
   string otype;                                                          
   if(sy=="")sy=_Symbol;                                                       
   if(lot<MarketInfo(sy,MODE_MINLOT))lot=MarketInfo(sy,MODE_MINLOT);         
   if(price==0) // Если цена не указана
     {
      if(typ==0) {price=MarketInfo(sy,MODE_ASK); col=clrBlue; otype="BUY"; }                              
      else       {price=MarketInfo(sy,MODE_BID); col=clrRed; otype="SELL";}                             
     }
   if(com=="") com=StringConcatenate(WindowExpertName(),"  ",Magic);            
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsTradeContextBusy())
     {
      tik=OrderSend(sy,typ,NormalizeDouble(lot,2),NormalizeDouble(price,(int)MarketInfo(sy,MODE_DIGITS)),Slip,0,0,com,Magic,0,col); 
      if(tik>=0) { pr(otype+" order opened");          return true;}
      else
        {
         p++;
         pr(__FUNCTION__+"_Error_"+Error(GetLastError()));
         Sleep(500);
         if(p>=5){ pr(otype+" order open error"); return false;} 
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|Функция ошибок                                                    |
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   bool Lan=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
   switch(error_code)
     {
      case 0:
         if(Lan)
         error_string="Нет ошибки.";                                                                         break;
         error_string="No error returned.";                                                                  break;
      case 1:
         if(Lan)
         error_string="Нет ошибки, но результат неизвестен.";                                                break;
         error_string="No error returned, but the result is unknown.";                                       break;
      case 2:
         if(Lan)
         error_string="Общая ошибка.";                                                                       break;
         error_string="Common error.";                                                                       break;
      case 3:
         if(Lan)
         error_string="Неправильные параметры.";                                                             break;
         error_string="Invalid trade parameters.";                                                           break;
      case 4:
         if(Lan)
         error_string="Торговый сервер занят.";                                                              break;
         error_string="Trade server is busy.";                                                               break;
      case 5:
         if(Lan)
         error_string="Старая версия клиентского терминала.";                                                break;
         error_string="Old version of the client terminal.";                                                 break;
      case 6:
         if(Lan)
         error_string="Нет связи с торговым сервером.";                                                      break;
         error_string="No connection with trade server.";                                                    break;
      case 7:
         if(Lan)
         error_string="Недостаточно прав.";                                                                  break;
         error_string="Not enough rights.";                                                                  break;
      case 8:
         if(Lan)
         error_string="Слишком частые запросы.";                                                             break;
         error_string="Too frequent requests.";                                                              break;
      case 9:
         if(Lan)
         error_string="Недопустимая операция нарушающая функционирование сервера.";                          break;
         error_string="Malfunctional trade operation.";                                                      break;
      case 64:
         if(Lan)
         error_string="Счет заблокирован.";                                                                  break;
         error_string="Account disabled.";                                                                   break;
      case 65:
         if(Lan)
         error_string="Неправильный номер счета.";                                                           break;
         error_string="Invalid account.";                                                                    break;
      case 128:
         if(Lan)
         error_string="Истек срок ожидания совершения сделки.";                                              break;
         error_string="Trade timeout.";                                                                      break;
      case 129:
         if(Lan)
         error_string="Неправильная цена.";                                                                  break;
         error_string="Invalid price.";                                                                      break;
      case 130:
         if(Lan)
         error_string="Неправильные стопы.";                                                                 break;
         error_string="Invalid stops.";                                                                      break;
      case 131:
         if(Lan)
         error_string="Неправильный объем.";                                                                 break;
         error_string="Invalid trade volume.";                                                               break;
      case 132:
         if(Lan)
         error_string="Рынок закрыт.";                                                                       break;
         error_string="Market is closed.";                                                                   break;
      case 133:
         if(Lan)
         error_string="Торговля запрещена.";                                                                 break;
         error_string="Trade is disabled.";                                                                  break;
      case 134:
         if(Lan)
         error_string="Недостаточно денег для совершения операции.";                                         break;
         error_string="Not enough money.";                                                                   break;
      case 135:
         if(Lan)
         error_string="Цена изменилась.";                                                                    break;
         error_string="Price changed.";                                                                      break;
      case 136:
         if(Lan)
         error_string="Нет цен.";                                                                            break;
         error_string="Off quotes.";                                                                         break;
      case 137:
         if(Lan)
         error_string="Брокер занят.";                                                                       break;
         error_string="Broker is busy.";                                                                     break;
      case 138:
         if(Lan)
         error_string="Новые цены.";                                                                         break;
         error_string="Requote.";                                                                            break;
      case 139:
         if(Lan)
         error_string="Ордер заблокирован и уже обрабатывается.";                                            break;
         error_string="Order is locked.";                                                                    break;
      case 140:
         if(Lan)
         error_string="Разрешена только покупка.";                                                           break;
         error_string="Long positions only allowed.";                                                        break;
      case 141:
         if(Lan)
         error_string="Слишком много запросов.";                                                             break;
         error_string="Too many requests.";                                                                  break;
      case 145:
         if(Lan)
         error_string="Модификация запрещена, так как ордер слишком близок к рынку.";                        break;
         error_string="Modification denied because an order is too close to market.";                        break;
      case 146:
         if(Lan)
         error_string="Подсистема торговли занята.";                                                         break;
         error_string="Trade context is busy.";                                                              break;
      case 147:
         if(Lan)
         error_string="Использование даты истечения ордера запрещено брокером.";                             break;
         error_string="Expirations are denied by broker.";                                                   break;
      case 148:
         if(Lan)
         error_string="Количество открытых и отложенных ордеров достигло предела, установленного брокером."; break;
         error_string="The amount of opened and pending orders has reached the limit set by a broker.";      break;
      case 4000:
         if(Lan)
         error_string="Нет ошибки.";                                                                         break;
         error_string="No error.";                                                                           break;
      case 4001:
         if(Lan)
         error_string="Неправильный указатель функции.";                                                     break;
         error_string="Wrong function pointer.";                                                             break;
      case 4002:
         if(Lan)
         error_string="Индекс массива - вне диапазона.";                                                     break;
         error_string="Array index is out of range.";                                                        break;
      case 4003:
         if(Lan)
         error_string="Нет памяти для стека функций.";                                                       break;
         error_string="No memory for function call stack.";                                                  break;
      case 4004:
         if(Lan)
         error_string="Переполнение стека после рекурсивного вызова.";                                       break;
         error_string="Recursive stack overflow.";                                                           break;
      case 4005:
         if(Lan)
         error_string="На стеке нет памяти для передачи параметров.";                                        break;
         error_string="Not enough stack for parameter.";                                                     break;
      case 4006:
         if(Lan)
         error_string="Нет памяти для строкового параметра.";                                                break;
         error_string="No memory for parameter string.";                                                     break;
      case 4007:
         if(Lan)
         error_string="Нет памяти для временной строки.";                                                    break;
         error_string="No memory for temp string.";                                                          break;
      case 4008:
         if(Lan)
         error_string="Неинициализированная строка.";                                                        break;
         error_string="Not initialized string.";                                                             break;
      case 4009:
         if(Lan)
         error_string="Неинициализированная строка в массиве.";                                              break;
         error_string="Not initialized string in an array.";                                                 break;
      case 4010:
         if(Lan)
         error_string="Нет памяти для строкового массива.";                                                  break;
         error_string="No memory for an array string.";                                                      break;
      case 4011:
         if(Lan)
         error_string="Слишком длинная строка.";                                                             break;
         error_string="Too long string.";                                                                    break;
      case 4012:
         if(Lan)
         error_string="Остаток от деления на ноль.";                                                         break;
         error_string="Remainder from zero divide.";                                                         break;
      case 4013:
         if(Lan)
         error_string="Деление на ноль.";                                                                    break;
         error_string="Zero divide.";                                                                        break;
      case 4014:
         if(Lan)
         error_string="Неизвестная команда.";                                                                break;
         error_string="Unknown command.";                                                                    break;
      case 4015:
         if(Lan)
         error_string="Неправильный переход.";                                                               break;
         error_string="Wrong jump.";                                                                         break;
      case 4016:
         if(Lan)
         error_string="Неинициализированный массив.";                                                        break;
         error_string="Not initialized array.";                                                              break;
      case 4017:
         if(Lan)
         error_string="Вызовы DLL не разрешены.";                                                            break;
         error_string="DLL calls are not allowed.";                                                          break;
      case 4018:
         if(Lan)
         error_string="Невозможно загрузить библиотеку.";                                                    break;
         error_string="Cannot load library.";                                                                break;
      case 4019:
         if(Lan)
         error_string="Невозможно вызвать функцию.";                                                         break;
         error_string="Cannot call function.";                                                               break;
      case 4020:
         if(Lan)
         error_string="Вызовы внешних библиотечных функций не разрешены.";                                   break;
         error_string="EA function calls are not allowed.";                                                  break;
      case 4021:
         if(Lan)
         error_string="Недостаточно памяти для строки, возвращаемой из функции.";                            break;
         error_string="Not enough memory for a string returned from a function.";                            break;
      case 4022:
         if(Lan)
         error_string="Система занята.";                                                                     break;
         error_string="System is busy.";                                                                     break;
      case 4050:
         if(Lan)
         error_string="Неправильное количество параметров функции.";                                         break;
         error_string="Invalid function parameters count.";                                                  break;
      case 4051:
         if(Lan)
         error_string="Недопустимое значение параметра функции.";                                            break;
         error_string="Invalid function parameter value.";                                                   break;
      case 4052:
         if(Lan)
         error_string="Внутренняя ошибка строковой функции.";                                                break;
         error_string="String function internal error.";                                                     break;
      case 4053:
         if(Lan)
         error_string="Ошибка массива.";                                                                     break;
         error_string="Some array error.";                                                                   break;
      case 4054:
         if(Lan)
         error_string="Неправильное использование массива-таймсерии.";                                       break;
         error_string="Incorrect series array using.";                                                       break;
      case 4055:
         if(Lan)
         error_string="Ошибка пользовательского индикатора.";                                                break;
         error_string="Custom indicator error.";                                                             break;
      case 4056:
         if(Lan)
         error_string="Массивы несовместимы.";                                                               break;
         error_string="Arrays are incompatible.";                                                            break;
      case 4057:
         if(Lan)
         error_string="Ошибка обработки глобальныех переменных.";                                            break;
         error_string="Global variables processing error.";                                                  break;
      case 4058:
         if(Lan)
         error_string="Глобальная переменная не обнаружена.";                                                break;
         error_string="Global variable not found.";                                                          break;
      case 4059:
         if(Lan)
         error_string="Функция не разрешена в тестовом режиме.";                                             break;
         error_string="Function is not allowed in testing mode.";                                            break;
      case 4060:
         if(Lan)
         error_string="Функция не подтверждена.";                                                            break;
         error_string="Function is not confirmed.";                                                          break;
      case 4061:
         if(Lan)
         error_string="Ошибка отправки почты.";                                                              break;
         error_string="Mail sending error.";                                                                 break;
      case 4062:
         if(Lan)
         error_string="Ожидается параметр типа string.";                                                     break;
         error_string="String parameter expected.";                                                          break;
      case 4063:
         if(Lan)
         error_string="Ожидается параметр типа integer.";                                                    break;
         error_string="Integer parameter expected.";                                                         break;
      case 4064:
         if(Lan)
         error_string="Ожидается параметр типа double.";                                                     break;
         error_string="Double parameter expected.";                                                          break;
      case 4065:
         if(Lan)
         error_string="В качестве параметра ожидается массив.";                                              break;
         error_string="Array as parameter expected.";                                                        break;
      case 4066:
         if(Lan)
         error_string="Запрошенные исторические данные в состоянии обновления.";                             break;
         error_string="Requested history data in updating state.";                                           break;
      case 4067:
         if(Lan)
         error_string="Ошибка при выполнении торговой операции.";                                            break;
         error_string="Some error in trade operation execution.";                                            break;
      case 4099:
         if(Lan)
         error_string="Конец файла.";                                                                        break;
         error_string="End of a file.";                                                                      break;
      case 4100:
         if(Lan)
         error_string="Ошибка при работе с файлом.";                                                         break;
         error_string="Some file error.";                                                                    break;
      case 4101:
         if(Lan)
         error_string="Неправильное имя файла.";                                                             break;
         error_string="Wrong file name.";                                                                    break;
      case 4102:
         if(Lan)
         error_string="Слишком много открытых файлов.";                                                      break;
         error_string="Too many opened files.";                                                              break;
      case 4103:
         if(Lan)
         error_string="Невозможно открыть файл.";                                                            break;
         error_string="Cannot open file.";                                                                   break;
      case 4104:
         if(Lan)
         error_string="Несовместимый режим доступа к файлу.";                                                break;
         error_string="Incompatible access to a file.";                                                      break;
      case 4105:
         if(Lan)
         error_string="Ни один ордер не выбран.";                                                            break;
         error_string="No order selected.";                                                                  break;
      case 4106:
         if(Lan)
         error_string="Неизвестный символ.";                                                                 break;
         error_string="Unknown symbol.";                                                                     break;
      case 4107:
         if(Lan)
         error_string="Неправильный параметр цены для торговой функции.";                                    break;
         error_string="Invalid price param.";                                                                break;
      case 4108:
         if(Lan)
         error_string="Неверный номер тикета.";                                                              break;
         error_string="Invalid ticket.";                                                                     break;
      case 4109:
         if(Lan)
         error_string="Торговля не разрешена.";                                                              break;
         error_string="Trade is not allowed.";                                                               break;
      case 4110:
         if(Lan)
         error_string="Длинные позиции не разрешены.";                                                       break;
         error_string="Longs are not allowed.";                                                              break;
      case 4111:
         if(Lan)
         error_string="Короткие позиции не разрешены.";                                                      break;
         error_string="Shorts are not allowed.";                                                             break;
      case 4200:
         if(Lan)
         error_string="Объект уже существует.";                                                              break;
         error_string="Object already exists.";                                                              break;
      case 4201:
         if(Lan)
         error_string="Запрошено неизвестное свойство объекта.";                                             break;
         error_string="Unknown object property.";                                                            break;
      case 4202:
         if(Lan)
         error_string="Объект не существует.";                                                               break;
         error_string="Object does not exist.";                                                              break;
      case 4203:
         if(Lan)
         error_string="Неизвестный тип объекта.";                                                            break;
         error_string="Unknown object type.";                                                                break;
      case 4204:
         if(Lan)
         error_string="Нет имени объекта.";                                                                  break;
         error_string="No object name.";                                                                     break;
      case 4205:
         if(Lan)
         error_string="Ошибка координат объекта.";                                                           break;
         error_string="Object coordinates error.";                                                           break;
      case 4206:
         if(Lan)
         error_string="Не найдено указанное подокно.";                                                       break;
         error_string="No specified subwindow.";                                                             break;
      case 4207:
         if(Lan)
         error_string="Ошибка при работе с объектом.";                                                       break;
         error_string="ERR_SOME_OBJECT_ERROR.";                                                              break;
      default:
         if(Lan)
         error_string="Не известная ошибка.";
         error_string="Error is not known.";
     }
   return(error_string);
  }
//+------------------------------------------------------------------+
//|                             |
//+------------------------------------------------------------------+
void pr(string txt,color cvet=C'80,80,80')
  {
   txt=StringConcatenate(StringSubstr(TimeS(),11,8))+" - "+txt;
   ArrayResize(info,Coment,1000); ArrayResize(cvit,Coment,1000);
   for(int i=Coment-1; i>0; i--)
     {
      if(info[i]!=info[i-1]) info[i]=info[i-1];
      if(cvit[i]!=cvit[i-1]) cvit[i]=cvit[i-1];
     }
   if(info[0]!=txt && txt!=""){ info[0]=txt; cvit[0]=cvet; }
   for( i=0; i<Coment; i++)
      ButtonCreate(0,StringConcatenate("Error",i),0,250+252*i,16,250,16,3,info[i],"Arial",10,cvit[i],C'236,233,216');
  }
//+------------------------------------------------------------------+
//|                                                 |
//+------------------------------------------------------------------+
string TimeS()
  {
   datetime Cur=0;
   Cur=TimeCurrent();
   RefreshRates();
   return StringFormat("%02d.%02d.%02d %02d-%02d-%02d",TimeYear(Cur),TimeMonth(Cur),TimeDay(Cur),TimeHour(Cur),TimeMinute(Cur),TimeSeconds(Cur));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  for(int ui = ObjectsTotal() - 1; ui >= 0; ui--)
     {
      string name2 = ObjectName(ui);
       if(StringFind(name2, "klc", 0) != -1)
         ObjectDelete(name2);   
         }
   EventKillTimer();
   Comment(WindowExpertName()+" successfully deinitialized !   "+getUninitReasonText(_UninitReason));
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void del()
  {
   obj_del("clock");
   for(int k=ObjectsTotal()-1; k>=0; k--)
      if(StringSubstr(ObjectName(k),0,2)==prefix)
         ObjectDelete(ObjectName(k));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,
                  string                  name="Button",
                  const int               sub_window=0,
                  const int               xx=0,                  
                  const int               yy=0,                   
                  const int               width=50,              
                  const int               height=18,                
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, 
                  const string            text="Button",          
                  const string            font="Arial",           
                  const int               font_size=10,           
                  const color             clr=clrBlack,            
                  const color             back_clr=C'236,233,216', 
                  const color             border_clr=clrNONE,    
                  const bool              state=false,            
                  const bool              back=false,             
                  const bool              selection=false,     
                  const bool              hidden=true,           
                  const long              z_order=0,          
                  const string            toltip="")
  {
   ResetLastError();
   name=StringConcatenate(prefix,name);
   if(ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);  
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);

      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);              
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);       
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);           
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);             
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);               
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);   
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);         
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);     
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);      
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,toltip);            
   return(true);
  }
//+------------------------------------------------------------------+
//|                                          |
//+------------------------------------------------------------------+
long IntGetX(const string name)
  {
   return ObjectGetInteger(0,prefix+name,OBJPROP_XDISTANCE);
  }
//+------------------------------------------------------------------+
//|                                          |
//+------------------------------------------------------------------+
long IntGetY(const string name)
  {
   return ObjectGetInteger(0,prefix+name,OBJPROP_YDISTANCE);
  }
//+------------------------------------------------------------------+
//|             |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
   bool Lan=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
   switch(reasonCode)
     {
      case 0:
         if(Lan)
         text="Эксперт прекратил свою работу, вызвав функцию ExpertRemove()";   break;
         text="Account was changed";                                            break;
      case 1:
         if(Lan)
         text="Программа удалена с графика";del();                              break;
         text="Program "+__FILE__+" was removed from chart";del();              break;
      case 2:
         if(Lan)
         text="Программа перекомпилирована";del();                              break;
         text="Program "+__FILE__+" was recompiled";del();                      break;
      case 3:
         if(Lan)
         text="Символ или период графика был изменен";                          break;
         text="Symbol or timeframe was changed";                                break;
      case 4:
         if(Lan)
         text="График закрыт";                                                  break;
         text="Chart was closed";                                               break;
      case 5:
         if(Lan)
         text="Входные параметры были изменены пользователем";                  break;
         text="Input-parameter was changed";                                    break;
      case 6:
         if(Lan)
         text="Переподключение к торговому серверу ";                           break;
         text="Reconnect to the trading server";                                break;
      case 7:
         if(Lan)
         text="Применен другой шаблон графика";                                 break;
         text="New template was applied to chart";                              break;
      case 8:
         if(Lan)
         text="Признак того, что обработчик OnInit() вернул ненулевое значение";break;
         text="A sign that the handler OnInit() returned non-zero value";       break;
      case 9:
         if(Lan)
         text="Терминал был закрыт";                                            break;
         text="The terminal was closed";                                        break;
      default:
         if(Lan)
         text="Причина деинициализации программы не известна";
         text="Another reason";
     }
   return text;
  }
//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+
bool but_stat(string name)
  {
   if(ObjectGetInteger(0,name,OBJPROP_STATE)==true)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                           |
//+------------------------------------------------------------------+
bool button_off(string name)
  {
   name=StringConcatenate(prefix,name);
   if(ObjectSetInteger(0,name,OBJPROP_STATE,false)==true)
      return true;   return false;
  }
//+------------------------------------------------------------------+
//|                               |
//+------------------------------------------------------------------+
void tim()
  {
   RefreshRates();
   string h=DoubleToStr(((int)Time[0]+PeriodSeconds(PERIOD_CURRENT)-(int)TimeCurrent())/60,0);
   string m=DoubleToStr((60-TimeSeconds(TimeCurrent())),0);
   if(StringLen(m)<2)m="0"+m;
   string time=StringConcatenate(h," : ",m);
   TextCreate(0,"clock",0,Time[0]+_Period*10*60,Ask,time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,
                const string            name="Text",           
                const int               sub_window=0,         
                datetime                time=0,                
                double                  price=0,             
                const string            text="Text",        
                const string            font="Arial",        
                const int               font_size=15,         
                const color             clr=clrRed,          
                const double            angle=0.0,              
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, 
                const bool              back=false,            
                const bool              selection=true,       
                const bool              hidden=true,          
                const long              z_order=0)       
  {
   ResetLastError();
   if(ObjectFind(0,name)==-1)
      ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
 


