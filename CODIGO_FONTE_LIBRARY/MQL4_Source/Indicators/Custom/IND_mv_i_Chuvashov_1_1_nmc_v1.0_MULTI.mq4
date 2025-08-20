//+------------------------------------------------------------------+
//|                                           mv-i-Chuvashov_1_1.mq4 |
//|                                       ������ ��������� �. MaxV42 |
//|                                       http://                    |
//| ��������� �������� �� ��������� "����� ��������".                |
//| ������ 1.1:                                                      |
//|  29.11.2009  ��������� ��������� ������� � ��������.             |
//+------------------------------------------------------------------+
#property copyright "������ ��������� �. MaxV42"
#property link      "http://"
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
//+------------------------------------------------------------------+
extern string Ind_Coment1= "--- ������� ��������� ���������� ---";
extern bool  ShowFractals     =  true;         // ���/���� ������� ���������
extern bool  OnAlert          = false;         // ���/���� �������
extern bool  OnPrint          = false;         // ���/���� ����� ������� � ������� ��������
extern int   nVilka_Upper     =     1;         // ���������� ��������� ���������� "�����"
extern int   nVilka_Lower     =     1;         // ���������� ��������� ���������� "�����"
extern color Color_LineUpper  =   Red;         // ���� ���������� "�����"
extern color Color_LineLower  =  Blue;         // ���� ���������� "�����"
extern int   Width_LineUpper  =     2;         // ������ ���������� "�����"
extern int   Width_LineLower  =     2;         // ������ ���������� "�����"
extern string Ind_Coment2= "--- ��������� ����������� ������� ---";
extern bool  OnAlert_Orders   =  true;         // ���/���� �������
extern color Color_OrderBuy   =  Blue;         // ���� ������� �� �������
extern color Color_OrderSell  = Green;         // ���� ������� �� �������
extern int   Width_OrderBuy   =     2;         // ������ ������� �� �������
extern int   Width_OrderSell  =     2;         // ������ ������� �� �������
extern color Color_SLBuy      =   Red;         // ���� ��������� �� �������
extern color Color_SLSell     =   Red;         // ���� ��������� �� �������
extern int   Orders_FontSize  =    12;         // ������ ������ �������
//+------------------------------------------------------------------+
// ���������� ����������
int          nLine_Upper      =     0,         // ���������� ��������� �����, ������������ �����
             nLine_Lower      =     0,         // ���������� ��������� �����, ������������ ����
             nBars            =     0;         //
datetime     mLineUpper_DateTime[][2];         // ������ � ����������� ���������� "�����"
         //  mLineUpper_DateTime[i][0]         // ����� ������ ����������
         //  mLineUpper_DateTime[i][1]         // ����� ������ ����������
double       mLineUpper_Price[][2];            // ������ � ����������� ���������� "�����"
         //  mLineUpper_Price[i][0]            // ���� ������ ����������
         //  mLineUpper_Price[i][1]            // ���� ������ ����������
datetime     mLineLower_DateTime[][2];         // ������ � ����������� ���������� "�����"
         //  mLineLower_DateTime[i][0]         // ����� ������ ����������
         //  mLineLower_DateTime[i][1]         // ����� ������ ����������
double       mLineLower_Price[][2];            // ������ � ����������� ���������� "�����"
         //  mLineLower_Price[i][0]            // ���� ������ ����������
         //  mLineLower_Price[i][1]            // ���� ������ ����������
int          mOrders[2][1];                    // ������ � ����������� "��������" �������
         //  mOrders[0][0]                     // Buy - 0-��� ������, 10-���� �����
         //  mOrders[1][0]                     // Sell- 0-��� ������, 20-���� �����
//----- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
void init()  {        // Custom indicator initialization function
int    Qnt=ObjectsTotal();
  // ----- Indicators Properties
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,217);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexEmptyValue(0,0.0);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,218);
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexEmptyValue(1,0.0);
  // ----- Name for DataWindow and indicator subwindow label
  IndicatorShortName("Fractals");
  SetIndexLabel(0,"FractalsUp");
  SetIndexLabel(1,"FractalsDown");
  // ----- ������������� ���������� ��������� � �������� ��������� �����
  ArrayResize(mLineUpper_DateTime,nVilka_Upper*2); ArrayResize(mLineUpper_Price,nVilka_Upper*2);
  ArrayResize(mLineLower_DateTime,nVilka_Lower*2); ArrayResize(mLineLower_Price,nVilka_Lower*2);
  return;
}

//+------------------------------------------------------------------+
void deinit()   {     // Custom indicator deinitialization function
int    Qnt=ObjectsTotal();
  // ----- ������� ��������� �����
  for (int i=0; i<Qnt; i++)   {  // ���� �� ��������
    if(StringFind(ObjectName(i),"Line.Upper",0)>=0) {
      ObjectDelete(ObjectName(i));     // ������������ �����
      i--; continue;
    }
    if(StringFind(ObjectName(i),"Line.Lower",0)>=0) {
      ObjectDelete(ObjectName(i));     // ������������ ����
      i--; continue;
    }
    if(i>=ObjectsTotal()) break;
  }
  DeleteOrders(10); DeleteOrders(20);
 return;
}

//+------------------------------------------------------------------+
void start() {        // Custom indicator iteration function
int    counted_bars=IndicatorCounted();
int    limit;
int    Spred=MarketInfo(Symbol(),MODE_SPREAD);
  // ����� ��� �� ��������
  if(!isNewBar()) return;
  // ----- ��������� ����������� ��� ����� ����������
  if (counted_bars>0) counted_bars--;
  limit=Bars-counted_bars;
  // ----- �������� ����
  //for (int i=limit; i>2; i--)   {
  for (int i=limit; i>=0; i--)   {
    if(ShowFractals)  {                    // ���������� �������� �� �������
      ExtMapBuffer1[i]=iFractals(NULL,0,MODE_UPPER,i)+Spred*Point;
      ExtMapBuffer2[i]=iFractals(NULL,0,MODE_LOWER,i)-Spred*Point;
    }
    //---- ���� Upper-��������� (���������� "�����")
    if (iFractals(NULL,0,MODE_UPPER,i)!=0)  {
      if(LowerVilka(i)) {
        if(OnAlert) Alert(Symbol(),Period()," Lower fork! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
        if(OnPrint) Print(Symbol(),Period()," Lower fork! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }
    }
    //---- ���� Lower-��������� (���������� "�����")
    if (iFractals(NULL,0,MODE_LOWER,i)!=0)  {
      if(UpperVilka(i)) {
        if(OnAlert) Alert(Symbol(),Period()," Upper fork! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
        if(OnPrint) Print(Symbol(),Period()," Upper fork! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }
    }
    //----- ����������� ���������� "�����" - ������ �� �������
    if(mOrders[0][0]==0 && (Close[i+1]>ObjectGetValueByShift("Line.Lower1",i+1) || 
                                                          Open[i]>ObjectGetValueByShift("Line.Lower1",i)))  {
      DrawOrdersBuy(i);
      if(OnAlert_Orders)  {
        Alert(Symbol(),Period(),": Buy signal! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }
    }
    //----- ����������� ���������� "�����" - ������ �� �������
    if(mOrders[1][0]==0 && (Close[i+1]<ObjectGetValueByShift("Line.Upper1",i+1) || 
                                                          Open[i]<ObjectGetValueByShift("Line.Upper1",i)))  {
      DrawOrdersSell(i);
      if(OnAlert_Orders)  {
        Alert(Symbol(),Period(),": Sell signal! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      }
    }
  }


  return;
}

//+------------------------------------------------------------------+
bool UpperVilka(int nBar)  {     // ������� ���������� � ������ ���������� "�����"
int         j=0;
double      Fractal_Lower=0;
double      mFractals_Price[3];
datetime    mFractals_DateTime[3];
   // ----- ��������� ������� ����������� � ��������� ���� ���������
   ArrayInitialize(mFractals_Price,0); ArrayInitialize(mFractals_DateTime,0);
   for (int i=nBar; i<Bars; i++)   {  // ���� �� �����
      Fractal_Lower=iFractals(NULL,0,MODE_LOWER,i);
      if(Fractal_Lower!=0) {
         mFractals_Price[j]=Fractal_Lower-MarketInfo(Symbol(),MODE_SPREAD)*Point;
         mFractals_DateTime[j]=Time[i];
         j++;
      }
      if(j>2) break;
   }
   // ----- ������ ���������� "�����"
   if(mFractals_Price[2]<mFractals_Price[1] && mFractals_Price[1]<mFractals_Price[0])  {
      string Name1="Line.Upper"+DoubleToStr(nLine_Upper,0); nLine_Upper++;
      string Name2="Line.Upper"+DoubleToStr(nLine_Upper,0); nLine_Upper++;

      ObjectCreate(Name1,OBJ_TREND,0,mFractals_DateTime[2],mFractals_Price[2],mFractals_DateTime[1],mFractals_Price[1]);
      ObjectCreate(Name2,OBJ_TREND,0,mFractals_DateTime[1],mFractals_Price[1],mFractals_DateTime[0],mFractals_Price[0]);
      if (ObjectGetValueByShift(Name1,nBar)<ObjectGetValueByShift(Name2,nBar))  {
        ObjectDelete(Name1); ObjectDelete(Name2); nLine_Upper--; nLine_Upper--; return(false);
      }
      ObjectSet(Name1,OBJPROP_COLOR,Color_LineUpper);   ObjectSet(Name2,OBJPROP_COLOR,Color_LineUpper);
      ObjectSet(Name1,OBJPROP_WIDTH,Width_LineUpper);   ObjectSet(Name2,OBJPROP_WIDTH,Width_LineUpper);
      ObjectSet(Name1,OBJPROP_RAY,True);                ObjectSet(Name2,OBJPROP_RAY,True);
      CheckNumVilka(10);
      // ----- ������� ���� "���������" ������ �� �������
      mOrders[1][0]=0; 
      // ----- ������� ���������� ����� �� �������
      DeleteOrders(20);
      return(true);
   }
   return(false);
}

//+------------------------------------------------------------------+
bool LowerVilka(int nBar)  {     // ������� ���������� � ������ ���������� "�����"
int         j=0;
double      Fractal_Upper=0;
double      mFractals_Price[3];
datetime    mFractals_DateTime[3];
   // ----- ��������� ������� ����������� � ��������� ���� ���������
   ArrayInitialize(mFractals_Price,0); ArrayInitialize(mFractals_DateTime,0);
   for (int i=nBar; i<Bars; i++)   {  // ���� �� �����
      Fractal_Upper=iFractals(NULL,0,MODE_UPPER,i);
      if(Fractal_Upper!=0) {
         mFractals_Price[j]=Fractal_Upper+MarketInfo(Symbol(),MODE_SPREAD)*Point;
         mFractals_DateTime[j]=Time[i];
         j++;
      }
      if(j>2) break;
   }
   // ----- ������ ���������� "�����"
   if(mFractals_Price[2]>mFractals_Price[1] && mFractals_Price[1]>mFractals_Price[0])  {
      string Name1="Line.Lower"+DoubleToStr(nLine_Lower,0); nLine_Lower++;
      string Name2="Line.Lower"+DoubleToStr(nLine_Lower,0); nLine_Lower++;

      ObjectCreate(Name1,OBJ_TREND,0,mFractals_DateTime[2],mFractals_Price[2],mFractals_DateTime[1],mFractals_Price[1]);
      ObjectCreate(Name2,OBJ_TREND,0,mFractals_DateTime[1],mFractals_Price[1],mFractals_DateTime[0],mFractals_Price[0]);
      if (ObjectGetValueByShift(Name1,nBar)>ObjectGetValueByShift(Name2,nBar))  {
        ObjectDelete(Name1); ObjectDelete(Name2); nLine_Lower--; nLine_Lower--; return(false);
      }
      ObjectSet(Name1,OBJPROP_COLOR,Color_LineLower);   ObjectSet(Name2,OBJPROP_COLOR,Color_LineLower);
      ObjectSet(Name1,OBJPROP_WIDTH,Width_LineLower);   ObjectSet(Name2,OBJPROP_WIDTH,Width_LineLower);
      ObjectSet(Name1,OBJPROP_RAY,True);                ObjectSet(Name2,OBJPROP_RAY,True);
      CheckNumVilka(20);
      // ----- ������� ���� "���������" ������ �� �������
      mOrders[0][0]=0; 
      // ----- ������� ���������� ����� �� �������
      DeleteOrders(10);
      return(true);
   }
   return(false);
}

//+------------------------------------------------------------------+
bool isNewBar() {                     // ������� ���������� true, ���� ��������� ����� ���, ����� false
  if(nBars!=Bars) {
    nBars=Bars; return(true);
  }
  return(false);
}

//+------------------------------------------------------------------+
void CheckNumVilka(int Type)  {     // ������� ��������� ���������� ���������� ����� ���������� ����
int i;
  switch(Type)  {
    case 10:
      //--------------------------------------------------------- 1 --
      if(nLine_Upper<=nVilka_Upper*2)  {
        mLineUpper_DateTime[nLine_Upper-2][0]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_TIME1);
        mLineUpper_DateTime[nLine_Upper-2][1]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_TIME2);
        mLineUpper_Price[nLine_Upper-2][0]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_PRICE1);
        mLineUpper_Price[nLine_Upper-2][1]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        mLineUpper_DateTime[nLine_Upper-1][0]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_TIME1);
        mLineUpper_DateTime[nLine_Upper-1][1]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_TIME2);
        mLineUpper_Price[nLine_Upper-1][0]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_PRICE1);
        mLineUpper_Price[nLine_Upper-1][1]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_PRICE2);
      }
      //--------------------------------------------------------- 2 --
      if(nLine_Upper >nVilka_Upper*2)  {
        for (i=0; i<nLine_Upper-4; i++)  {
          mLineUpper_DateTime[i][0]=mLineUpper_DateTime[i+2][0]; mLineUpper_DateTime[i][1]=mLineUpper_DateTime[i+2][1];
          mLineUpper_Price[i][0]=mLineUpper_Price[i+2][0]; mLineUpper_Price[i][1]=mLineUpper_Price[i+2][1];
        }
        mLineUpper_DateTime[nLine_Upper-4][0]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_TIME1);
        mLineUpper_DateTime[nLine_Upper-4][1]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_TIME2);
        mLineUpper_Price[nLine_Upper-4][0]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_PRICE1);
        mLineUpper_Price[nLine_Upper-4][1]=ObjectGet("Line.Upper"+(nLine_Upper-2),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        mLineUpper_DateTime[nLine_Upper-3][0]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_TIME1);
        mLineUpper_DateTime[nLine_Upper-3][1]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_TIME2);
        mLineUpper_Price[nLine_Upper-3][0]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_PRICE1);
        mLineUpper_Price[nLine_Upper-3][1]=ObjectGet("Line.Upper"+(nLine_Upper-1),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        ObjectDelete("Line.Upper"+(nLine_Upper-2)); ObjectDelete("Line.Upper"+(nLine_Upper-1));
        nLine_Upper--;nLine_Upper--;
        //+------------------------------------------------------------------+
        for (i=0; i<nLine_Upper; i++)  {
          ObjectMove("Line.Upper"+i,0,mLineUpper_DateTime[i][0],mLineUpper_Price[i][0]);
          ObjectMove("Line.Upper"+i,1,mLineUpper_DateTime[i][1],mLineUpper_Price[i][1]);
        } 
      }
      break;  // ��� ������� ����� ������������� ��������� �������
    case 20:
      //--------------------------------------------------------- 1 --
      if(nLine_Lower<=nVilka_Lower*2)  {
        mLineLower_DateTime[nLine_Lower-2][0]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_TIME1);
        mLineLower_DateTime[nLine_Lower-2][1]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_TIME2);
        mLineLower_Price[nLine_Lower-2][0]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_PRICE1);
        mLineLower_Price[nLine_Lower-2][1]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        mLineLower_DateTime[nLine_Lower-1][0]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_TIME1);
        mLineLower_DateTime[nLine_Lower-1][1]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_TIME2);
        mLineLower_Price[nLine_Lower-1][0]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_PRICE1);
        mLineLower_Price[nLine_Lower-1][1]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_PRICE2);
      }
      //--------------------------------------------------------- 2 --
      if(nLine_Lower >nVilka_Lower*2)  {
        for (i=0; i<nLine_Lower-4; i++)  {
          mLineLower_DateTime[i][0]=mLineLower_DateTime[i+2][0]; mLineLower_DateTime[i][1]=mLineLower_DateTime[i+2][1];
          mLineLower_Price[i][0]=mLineLower_Price[i+2][0]; mLineLower_Price[i][1]=mLineLower_Price[i+2][1];
        }
        mLineLower_DateTime[nLine_Lower-4][0]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_TIME1);
        mLineLower_DateTime[nLine_Lower-4][1]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_TIME2);
        mLineLower_Price[nLine_Lower-4][0]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_PRICE1);
        mLineLower_Price[nLine_Lower-4][1]=ObjectGet("Line.Lower"+(nLine_Lower-2),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        mLineLower_DateTime[nLine_Lower-3][0]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_TIME1);
        mLineLower_DateTime[nLine_Lower-3][1]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_TIME2);
        mLineLower_Price[nLine_Lower-3][0]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_PRICE1);
        mLineLower_Price[nLine_Lower-3][1]=ObjectGet("Line.Lower"+(nLine_Lower-1),OBJPROP_PRICE2);
        //+------------------------------------------------------------------+
        ObjectDelete("Line.Lower"+(nLine_Lower-2)); ObjectDelete("Line.Lower"+(nLine_Lower-1));
        nLine_Lower--;nLine_Lower--;
        //+------------------------------------------------------------------+
        for (i=0; i<nLine_Lower; i++)  {
          ObjectMove("Line.Lower"+i,0,mLineLower_DateTime[i][0],mLineLower_Price[i][0]);
          ObjectMove("Line.Lower"+i,1,mLineLower_DateTime[i][1],mLineLower_Price[i][1]);
        } 
      }
      break;  // ��� ������� ����� ������������� ��������� �������
  }
  return;
}

//+------------------------------------------------------------------+
void DeleteOrders(int Type)  {     // ������� ������� ������ ���������� ����
  if(Type==10)  {
    //--------------------------------------------------------- 1 --
    ObjectDelete("Order.Buy"); ObjectDelete("OrderArrow.Buy");
    ObjectDelete("StopLoss.Buy"); ObjectDelete("StopLossArrow.Buy");
    ObjectDelete("LabelPrice.Buy"); ObjectDelete("LabelStopLoss.Buy");
  }
  if(Type==20)  {
    //--------------------------------------------------------- 2 --
    ObjectDelete("Order.Sell"); ObjectDelete("OrderArrow.Sell");
    ObjectDelete("StopLoss.Sell"); ObjectDelete("StopLossArrow.Sell");
    ObjectDelete("LabelPrice.Sell"); ObjectDelete("LabelStopLoss.Sell");
  }
/* �� ��� ������, ������ ����������� ��� ��������� ��� ������ ������� � ���������� Type=10 ���� �� �������� ���:
   �������� ����� case ������ � ���������� ������ ������ �������, � ���� ����� ����������� ��������� 
   ��� ���������� �������� case, �� ����� ����� ����������� ��������� ���� ����������� ��������� �� ��� ���, 
   ���� �� ���������� �������� break, ��� ��������� ��������� ���� ������������������ ���������� � ����������� ����������
*/
/* � ������ ����� �� VB6 ��� ����������� ������ ���� �������� - ��� �������� ��������� �����!
*/
/*
  switch(Type)  {
    case 10:
      //--------------------------------------------------------- 1 --
      ObjectDelete("Order.Buy"); ObjectDelete("OrderArrow.Buy");
      ObjectDelete("StopLoss.Buy"); ObjectDelete("StopLossArrow.Buy");
      ObjectDelete("LabelPrice.Buy"); ObjectDelete("LabelStopLoss.Buy");
      break;  // ��� ������� ����� ������������� ��������� �������
    case 20:
      //--------------------------------------------------------- 2 --
      ObjectDelete("Order.Sell"); ObjectDelete("OrderArrow.Sell");
      ObjectDelete("StopLoss.Sell"); ObjectDelete("StopLossArrow.Sell");
      ObjectDelete("LabelPrice.Sell"); ObjectDelete("LabelStopLoss.Sell");
      break;  // ��� ������� ����� ������������� ��������� �������
  }
*/
  return;
}

//+------------------------------------------------------------------+
void DrawOrdersBuy(int nBar)  {     // ������� ����� ������ Buy
double Price_Buy=Open[nBar];
double StopLoss_Buy;
  // ----- ������� ���������� ����� �� �������
  DeleteOrders(10);
  // ----- ������ ����� �� �������
  ObjectCreate("Order.Buy",OBJ_TREND,0,Time[nBar+25],Price_Buy,Time[nBar],Price_Buy);
  ObjectCreate("OrderArrow.Buy",OBJ_ARROW,0,Time[nBar+23],Price_Buy);
  ObjectSet("Order.Buy",OBJPROP_COLOR,Color_OrderBuy);  ObjectSet("OrderArrow.Buy",OBJPROP_COLOR,Color_OrderBuy);
  ObjectSet("Order.Buy",OBJPROP_WIDTH,Width_OrderBuy);  ObjectSet("OrderArrow.Buy",OBJPROP_WIDTH,Width_OrderBuy);
  ObjectSet("Order.Buy",OBJPROP_RAY,false);             ObjectSet("OrderArrow.Buy",OBJPROP_ARROWCODE,225);
  ObjectCreate("LabelPrice.Buy",OBJ_TEXT,0,Time[nBar+10],Price_Buy);
  ObjectSetText("LabelPrice.Buy","Buy: "+DoubleToStr(Price_Buy,Digits),Orders_FontSize, "Times New Roman", 
                                                                                          Color_OrderBuy);
  // ----- ������ ������� �� �������
  for (int i=nBar; i<Bars; i++)   {  // ���� �� �����
    StopLoss_Buy=iFractals(NULL,0,MODE_LOWER,i);
    if(StopLoss_Buy!=0)  {
      StopLoss_Buy=StopLoss_Buy-MarketInfo(Symbol(),MODE_SPREAD)*Point;
      break;
    }
  }
  ObjectCreate("StopLoss.Buy",OBJ_TREND,0,Time[nBar+25],StopLoss_Buy,Time[nBar],StopLoss_Buy);
  ObjectCreate("StopLossArrow.Buy",OBJ_ARROW,0,Time[nBar+23],StopLoss_Buy);
  ObjectSet("StopLoss.Buy",OBJPROP_COLOR,Color_SLBuy);     ObjectSet("StopLossArrow.Buy",OBJPROP_COLOR,Color_SLBuy);
  ObjectSet("StopLoss.Buy",OBJPROP_WIDTH,Width_OrderBuy);  ObjectSet("StopLossArrow.Buy",OBJPROP_WIDTH,Width_OrderBuy);
  ObjectSet("StopLoss.Buy",OBJPROP_RAY,false);             ObjectSet("StopLossArrow.Buy",OBJPROP_ARROWCODE,251);
  ObjectCreate("LabelStopLoss.Buy",OBJ_TEXT,0,Time[nBar+10],StopLoss_Buy);
  ObjectSetText("LabelStopLoss.Buy","SL Buy: "+DoubleToStr(StopLoss_Buy,Digits),Orders_FontSize, "Times New Roman", 
                                                                                                  Color_SLBuy);
  // ----- ������������� ���� "���������" ������ �� �������
  mOrders[0][0]=10;

  return;
}

//+------------------------------------------------------------------+
void DrawOrdersSell(int nBar)  {     // ������� ����� ������ Sell
double Price_Sell=Open[nBar];
double StopLoss_Sell;
  // ----- ������� ���������� ����� �� �������
  DeleteOrders(20);
  // ----- ������ ����� �� �������
  ObjectCreate("Order.Sell",OBJ_TREND,0,Time[nBar+25],Price_Sell,Time[nBar],Price_Sell);
  ObjectCreate("OrderArrow.Sell",OBJ_ARROW,0,Time[nBar+23],Price_Sell+10*Point);
  ObjectSet("Order.Sell",OBJPROP_COLOR,Color_OrderSell);  ObjectSet("OrderArrow.Sell",OBJPROP_COLOR,Color_OrderSell);
  ObjectSet("Order.Sell",OBJPROP_WIDTH,Width_OrderSell);  ObjectSet("OrderArrow.Sell",OBJPROP_WIDTH,Width_OrderSell);
  ObjectSet("Order.Sell",OBJPROP_RAY,false);              ObjectSet("OrderArrow.Sell",OBJPROP_ARROWCODE,226);
  ObjectCreate("LabelPrice.Sell",OBJ_TEXT,0,Time[nBar+10],Price_Sell+10*Point);
  ObjectSetText("LabelPrice.Sell","Sell: "+DoubleToStr(Price_Sell,Digits),Orders_FontSize, "Times New Roman", 
                                                                                            Color_OrderSell);
  // ----- ������ ������� �� �������
  for (int i=nBar; i<Bars; i++)   {  // ���� �� �����
    StopLoss_Sell=iFractals(NULL,0,MODE_UPPER,i);
    if(StopLoss_Sell!=0)  {
      StopLoss_Sell=StopLoss_Sell+MarketInfo(Symbol(),MODE_SPREAD)*Point;
      break;
    }
  }
  ObjectCreate("StopLoss.Sell",OBJ_TREND,0,Time[nBar+25],StopLoss_Sell,Time[nBar],StopLoss_Sell);
  ObjectCreate("StopLossArrow.Sell",OBJ_ARROW,0,Time[nBar+23],StopLoss_Sell+10*Point);
  ObjectSet("StopLoss.Sell",OBJPROP_COLOR,Color_SLSell);   ObjectSet("StopLossArrow.Sell",OBJPROP_COLOR,Color_SLSell);
  ObjectSet("StopLoss.Sell",OBJPROP_WIDTH,Width_OrderSell);ObjectSet("StopLossArrow.Sell",OBJPROP_WIDTH,Width_OrderSell);
  ObjectSet("StopLoss.Sell",OBJPROP_RAY,false);            ObjectSet("StopLossArrow.Sell",OBJPROP_ARROWCODE,251);
  ObjectCreate("LabelStopLoss.Sell",OBJ_TEXT,0,Time[nBar+10],StopLoss_Sell+10*Point);
  ObjectSetText("LabelStopLoss.Sell","SL Sell: "+DoubleToStr(StopLoss_Sell,Digits),Orders_FontSize, "Times New Roman", 
                                                                                                   Color_SLSell);
  // ----- ������������� ���� "���������" ������ �� �������
  mOrders[1][0]=20; 

  return;
}