//+------------------------------------------------------------------+
//|                                                        FMCBR.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property description "Free Distribution"
#property description "edited by eevviill"
#property description "alert"
#property link      ""
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 6

extern color BLUE= clrAqua;
extern color RED = clrRed;
extern int inDepth=50;
extern int Limit=240;
extern string Fibo_Level="Klik false untuk tutup level";
extern bool HANYUT=false;
extern bool MULA = false;
extern bool ENTRY = false;
extern bool EXIT_1 = false;
extern bool AKHIR = true;
extern bool EXIT_2 = false;
extern bool EXIT_3 = false;
extern bool EXIT_4=false;
extern bool TAMAK = false;

 extern string emp1 = "///////////////////////////////////////";
 extern string al_set = "Alerts settings";
 extern bool use_alert = false;
 extern string up_alert = "UP";
 extern string down_alert = "DOWN";
 
 extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;
extern string             DisplayID             = "FMCBR-BT";     
extern string             btn_Font              = "Tahoma";
extern int                btn_FontSize          = 10;           
extern color              btn_on_color          = clrLime;
extern color              btn_off_color         = clrRed;
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 700;          
extern int                button_y              = 20;          
extern int                btn_Width             = 70;        
extern int                btn_Height            = 20;          
extern string             button_note2          = "------------------------------";

bool           show_data            = true;
bool           recalc               = true;




//+----- Global variable --------
double cbHi[],cbLow[],hi[],low[],breakHi[],breakLow[];
int fiboCount;
 int prev_bars;
//+------------------------------------------------------------------+
string   buttonId,IndicatorName,IndicatorObjPrefix;
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,OBJ_FIBO);
   
   SetIndexBuffer(0,hi); SetIndexStyle(0,DRAW_ARROW,0,2,clrRed); SetIndexArrow(0,174);
   SetIndexBuffer(1,low);  SetIndexStyle(1,DRAW_ARROW,0,2,clrBlue); SetIndexArrow(1,174);
   SetIndexBuffer(2,cbHi);  SetIndexStyle(2,DRAW_ARROW,0,2,clrBlue); //SetIndexArrow(2,140);  
   SetIndexBuffer(3,cbLow);  SetIndexStyle(3,DRAW_ARROW,0,2,clrRed); //SetIndexArrow(3,140); 
   SetIndexBuffer(4,breakHi);  SetIndexStyle(4,DRAW_ARROW,0,1,clrBlue);// SetIndexArrow(4,140);  
   SetIndexBuffer(5,breakLow);  SetIndexStyle(5,DRAW_ARROW,0,1,clrRed);// SetIndexArrow(5,140);
   
   IndicatorName = GenerateIndicatorName(DisplayID );
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(WindowExpertName());
   IndicatorDigits(1);

   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
   show_data = val != 0;

   buttonId = IndicatorObjPrefix+DisplayID;   
   createButton(buttonId, DisplayID,btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_on_color);                     
   ObjectSetInteger(0,buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0,buttonId, OBJPROP_XDISTANCE, button_x); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int deinit2()
  {     
   ObjectsDeleteAll(0,OBJ_FIBO);
   
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);   
   SetIndexStyle(3,DRAW_NONE); 
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   
   return(0);
  }
//+------------------------------------------------------------------+
int deinit() 
  {
   deinit2();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
  
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               
                  const string            name="Button",            
                  const int               sub_window=0,             
                  const int               x=0,                      
                  const int               y=0,                      
                  const int               width=60,                 
                  const int               height=20,                 
                  const ENUM_BASE_CORNER  corner= CORNER_LEFT_UPPER,  
                  const string            text="Button",         
                  const string            font="Tahoma",              
                  const int               font_size=10,           
                  const color             clr=clrBlack,         
                  const color             clrBorder=clrBlack,    
                  const color             back_clr=clrWhite,      
                  const color             border_clr=clrNONE,    
                  const bool              state=true,                
                  const bool              back=false,               
                  const bool              selection=false,      
                  const bool              hidden=true,             
                  const long              z_order=0)            
{ 
   ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrBorder); 
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,BORDER_FLAT); 
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
      return(true); 
} 
//------------------------------------------------------------------|
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
}                               
//+------------------------------------------------------------------+
void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      //start();
   }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int ids, const long &lparam,const double &dparam,const string &sparam)
{
   handleButtonClicks();
   
   if (ids==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
   {   
   if (show_data)
      { 
   
   SetIndexBuffer(0,hi); SetIndexStyle(0,DRAW_ARROW,0,2,clrRed); SetIndexArrow(0,174);
   SetIndexBuffer(1,low);  SetIndexStyle(1,DRAW_ARROW,0,2,clrBlue); SetIndexArrow(1,174);
   SetIndexBuffer(2,cbHi);  SetIndexStyle(2,DRAW_ARROW,0,2,clrBlue); //SetIndexArrow(2,140);  
   SetIndexBuffer(3,cbLow);  SetIndexStyle(3,DRAW_ARROW,0,2,clrRed); //SetIndexArrow(3,140); 
   SetIndexBuffer(4,breakHi);  SetIndexStyle(4,DRAW_ARROW,0,1,clrBlue);// SetIndexArrow(4,140);  
   SetIndexBuffer(5,breakLow);  SetIndexStyle(5,DRAW_ARROW,0,1,clrRed);// SetIndexArrow(5,140);
   
   start();
             
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_on_color);    
      }
      else
      {       
      deinit2();
      
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_off_color);
      }
   }     
}
//+------------------------------------------------------------------+
int start()
  {
   handleButtonClicks();
   recalc = false;
   
   int    counted_bars=IndicatorCounted();
   int    limit=300;

   if(counted_bars<0) return(-1);

   if(counted_bars>0) counted_bars--;
  
//Limit=Bars-counted_bars; 
//---- 


   getHiLow();
   findCb();
   cBreak();


//new bar
 //if(Bars==prev_bars) return(0);
 //prev_bars=Bars;


//Alerts
 if(use_alert)
 {  
 if(hi[1]!=0) Alert(Symbol()," ",Period()," ",up_alert);
 if(low[1]!=0) Alert(Symbol()," ",Period()," ",down_alert);
 }

  if (show_data)
      {        
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_on_color);    
      }
      else
      {       
      deinit2();
      
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_off_color);
      }

   return(0);
  }
//+--------------- end main ----------------------------+

//+--------------- find hi low -------------------
void getHiLow()
  {
   int prePos,curPos;

   curPos=prePos=0;
   for(int i=0;i<=Limit;i++)
     {
      double zz= iCustom(Symbol(),0,"ZigZag",inDepth,5,3,0,i);
      double zzhi=iCustom(Symbol(),0,"ZigZag",inDepth,5,3,1,i);
      double zzLow=iCustom(Symbol(),0,"ZigZag",inDepth,5,3,2,i);

      if(zzhi>0)
         hi[i]=zz;
      else
         hi[i]=0.0;

      if(zzLow>0)
         low[i]=zz;
      else
         low[i]=0.0;

     }

  }
//+----------- end function --------------------

//+------------ function find break --------------

void cBreak()
  {
   ObjectsDeleteAll(0,OBJ_FIBO);
   bool breakHiFound,breakLowFound;
   double cbhi,cblow;
   breakHiFound=breakLowFound=false;
   cbhi=cblow=0;
   int x,i,y;
   double highest,lowest;
   datetime T1,T2;
   for(x=0;x<=Limit;x++)
     {
      breakLow[x]=0.0;
      breakHi[x]=0.0;
      if(hi[x]>0 || low[x]>0)
        {
         for(i=x;i<=x+20;i++)
           {// cari cbhi/cbLow
            if(cbHi[i]>0)
              {
               cbhi=cbHi[i];
               break;
              }
            else cbhi=0;

            if(cbLow[i]>0)
              {
               cblow=cbLow[i];
               break;
              }
            else cblow=0;
           }
        }
      for(y=x;y>=0;y--)
        {// cari break;
         if(cbhi>0 || cblow>0)
           {
            if(iClose(Symbol(),0,y)>cbhi && cbhi>0 && low[x]>0)
              {
               //  Print("i: "+i+" y: "+y+" price : "+iClose(Symbol(),0,y)+" > cbhi : "+cbhi);
               breakHi[y]=iClose(Symbol(),0,y);
               cbhi=0;
               highest=breakHi[y];
               lowest=iLow(Symbol(),0,x);
               T1=iTime(Symbol(),0,x);
               T2=iTime(Symbol(),0,x+2);
               // fiboCount--;
               //ObjectDelete("fibo"-IntegerToString((fiboCount--));
               DrawFibo(T1,T2,highest,lowest,"up");
               break;
              }
            else breakHi[y]=0.0;

            if(iClose(Symbol(),0,y)<cblow && cblow>0 && hi[x]>0)
              {
               breakLow[y]=iClose(Symbol(),0,y);
               cblow=0;
               highest=breakLow[y];
               lowest=iHigh(Symbol(),0,x);
               T1=iTime(Symbol(),0,x);
               T2=iTime(Symbol(),0,x+2);
               DrawFibo(T1,T2,highest,lowest,"down");
               break;
              }
            else breakLow[y]=0.0;
           }
        }

     }

  }
//+---------------- end function ------------------

//+------------------ function find cb key -------------------------+
void findCb()
  {
   ArrayInitialize(cbHi,0.0);
   ArrayInitialize(cbLow,0.0);
   for(int i=0;i<=Limit;i++)
     {
      int PointShift=i;
      string ConfirmedPoint="Not Found";
      string PointShiftDirection="Not Found";

      if(hi[i]>0 || low[i]>0)
        {
         while(ConfirmedPoint!="Found")
           {
            double ZZ=iCustom(NULL,0,"ZigZag",inDepth,5,3,0,PointShift);
            if(iHigh(NULL,0,PointShift)==ZZ || iLow(NULL,0,PointShift)==ZZ)
              {
               ConfirmedPoint="Found";
               if(iHigh(NULL,0,PointShift)==ZZ)
                 {
                  PointShiftDirection="High";
                  break;
                 }
               if(iLow(NULL,0,PointShift)==ZZ)
                 {
                  PointShiftDirection="Low";
                  break;
                 }
              }
            PointShift++;
           }

         int PointShift2=PointShift;
         string ConfirmedPoint2="Not Found";

         while(ConfirmedPoint2!="Found")
           {
            double ZZ2=iCustom(NULL,0,"ZigZag",2,1,1,0,PointShift2);
            double priceOpen=iOpen(Symbol(),0,PointShift2);
            double priceClose=iClose(Symbol(),0,PointShift2);

            if(iHigh(NULL,0,PointShift2)==ZZ2 && PointShiftDirection=="Low")
              {
               ConfirmedPoint2="Found";
               //cb1
               if(iClose(Symbol(),0,PointShift2)<iOpen(Symbol(),0,PointShift2))
                  cbHi[PointShift2]=priceOpen;
               else
                  cbHi[PointShift2]=priceClose;

               // if dominent exist

               if(checkDominentHi(PointShift))
                 {
                  cbHi[PointShift2]=0.0;
                  //Print("Dominent found Pointshift2 clear at: "+PointShift2);

                 }
               //---------------- 
               break;

              }
            else cbHi[PointShift2]=0.0;
            if(iLow(NULL,0,PointShift2)==ZZ2 && PointShiftDirection=="High")
              {
               ConfirmedPoint2="Found";
               if(iClose(Symbol(),0,PointShift2)>iOpen(Symbol(),0,PointShift2))
                  cbLow[PointShift2]=priceOpen;
               else
                  cbLow[PointShift2]=priceClose;
               // break;

               // if dominent exist

               if(checkDominentLow(PointShift))
                 {
                  cbLow[PointShift2]=0.0;
                  //Print("Dominent found Pointshift2 clear at: "+PointShift2);

                 }
               //---------------- 
               break;
              }
            else cbLow[PointShift2]=0.0;
            PointShift2++;
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+----------- find low dominent --------------
bool checkDominentLow(int i)
  {
   bool flag=false;
   double openPrice,closePrice,openPrice2,closePrice2;
   openPrice=openPrice2=closePrice=closePrice2=0;

   openPrice=iOpen(Symbol(),0,i);
   closePrice=iClose(Symbol(),0,i);

   if(openPrice<closePrice && hi[i]>0)
     {//bull
      int inside=0;
      for(int x=i-1;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2<closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice<closePrice2 && closePrice>=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbLow[i]=openPrice;
            break;
           }
        }
     }
   if(openPrice>closePrice && hi[i]>0)
     {//bear
      int inside=0;
      openPrice = iOpen(Symbol(),0,i+1);
      closePrice= iClose(Symbol(),0,i+1);
      for(int x=i;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2<closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice<closePrice2 && closePrice>=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbLow[i]=openPrice;
            break;
           }

        }
     }


   return(flag);
  }
//+------------ end find low dominent -----------------

//+----------- find hi dominent --------------
bool checkDominentHi(int i)
  {
   bool flag=false;
   double openPrice,closePrice,openPrice2,closePrice2;
   openPrice=openPrice2=closePrice=closePrice2=0;

   openPrice=iOpen(Symbol(),0,i);
   closePrice=iClose(Symbol(),0,i);

   if(openPrice>closePrice && low[i]>0)
     {//bull
      int inside=0;
      for(int x=i-1;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2>closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice>closePrice2 && closePrice<=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbHi[i]=openPrice;
            break;
           }
        }
     }

   if(openPrice<closePrice && low[i]>0)
     {//bear
      int inside=0;
      openPrice = iOpen(Symbol(),0,i+1);
      closePrice= iClose(Symbol(),0,i+1);
      for(int x=i;x>=0;x--)
        {

         openPrice2=iOpen(Symbol(),0,x);
         closePrice2=iClose(Symbol(),0,x);

         if(openPrice2>closePrice2)
           {
            openPrice2=iClose(Symbol(),0,x);
            closePrice2=iOpen(Symbol(),0,x);
           }
         if(openPrice>closePrice2 && closePrice<=openPrice2)
           {
            inside++;

           }
         else break;

         if(inside==2)
           {
            flag=true;
            cbHi[i]=openPrice;
            break;
           }

        }
     }


   return(flag);
  }
//+------------ end find hi dominent -----------------

//------------ function draw fibo --------
void DrawFibo(datetime T1,datetime T2,double highest,double lowest,string direction)
  {
   fiboCount++;
   string fiboobjname="Fibo"+IntegerToString(fiboCount);

   if(direction=="up")
     {
      ObjectCreate(fiboobjname,OBJ_FIBO,0,T1,highest,T2,lowest);
      ObjectSet(fiboobjname,OBJPROP_LEVELCOLOR,BLUE);

        }else{
      ObjectCreate(fiboobjname,OBJ_FIBO,0,T1,highest,T2,lowest);
      ObjectSet(fiboobjname,OBJPROP_LEVELCOLOR,RED);

     }

   ObjectSet(fiboobjname,OBJPROP_FIBOLEVELS,19);
   if(HANYUT)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL,-0.1);
      ObjectSetFiboDescription(fiboobjname,0,"HANYUT : %$");
     }
   if(MULA)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+1,0.0);
      ObjectSetFiboDescription(fiboobjname,1,"MULA : %$");
     }
   if(ENTRY)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+2,0.14);
      ObjectSetFiboDescription(fiboobjname,2,"ENTRY : %$");
     }
   if(EXIT_1)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+3,0.764);
      ObjectSetFiboDescription(fiboobjname,3,"EXIT 1 : %$");
     }
   if(AKHIR)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+4,1.0);
      ObjectSetFiboDescription(fiboobjname,4,"AKHIR : %$");
     }
   if(EXIT_2)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+5,1.272);
      ObjectSetFiboDescription(fiboobjname,5,"EXIT 2 : %$");
     }
   if(EXIT_3)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+6,1.618);
      ObjectSetFiboDescription(fiboobjname,6,"EXIT 3 : %$");
     }
   if(EXIT_4)
   {
   ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+7,2.618);
   ObjectSetFiboDescription(fiboobjname,7,"EXIT 4 : %$");
   }
   if(TAMAK)
     {
      ObjectSet(fiboobjname,OBJPROP_FIRSTLEVEL+8,4.236);
      ObjectSetFiboDescription(fiboobjname,8,"TAMAK : %$");
     }
   ObjectSet(fiboobjname,OBJPROP_RAY,false);

  }
//------------ end function --------------