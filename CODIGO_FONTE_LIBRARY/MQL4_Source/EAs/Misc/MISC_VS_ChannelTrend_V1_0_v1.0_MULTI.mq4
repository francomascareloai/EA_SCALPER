//+------------------------------------------------------------------+
//|                                         1VS_ChannelTrend_V1.0.mq4 |
//|                               Copyright � 2010, Vladimir Sautkin |
//|                                         sly_fox@list.ru          |
//|���������� ����� ��������� , ������������� � �������              |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010,Vladimir Sautkin"
#property indicator_chart_window
extern int       FirstBar  =  1;    // ��������� ��� ���������� �����  ( ���������� ������������ ����� StartTL )
extern int       DeltaBar  =  3;    // ����������� ������ ����� � �����
extern bool      InsLine   =  true; // ������ ��� ��� �������������� ���������� ����� ��������� � �������������


color     ColorTL_U   =  Blue,
          ColorTL_D   =  Red,
          ColorCH_U   =  Blue,
          ColorCH_D   =  Red,
          ColorTR_U   =  Green,
          ColorTR_D   =  Violet;
string    NameTL_U    =  "Up_", 
          NameTL_D    =  "Dn_",
          NameCH_U    =  "UpZ_", 
          NameCH_D    =  "DnZ_",
          NameTR_U    =  "UpTr_", 
          NameTR_D    =  "DnTr_";
int       last_bar    =  0,
          cntLine     =  1,       // ����� ��������� �����
          Line_U[100][2],       // ������ ��������� ��������� ����� . ������ ����� ����� ���� ������ 
          Line_D[100][2],       // ������ ��������� ��������� ����� . ������ ����� ����� ���� ������ 
          LineI_U[100][2],      // ������ ��������� ���������� ��������� ����� . ������ ����� ����� ���� ������ 
          LineI_D[100][2],      // ������ ��������� ����������  ��������� ����� . ������ ������ ����� ���� ������ 
          LineShow_U[100][2],   // ������ ��������� ������������ ��������� ����� . ������ ������ ����� ���� ������ - ������������ Line_U[100][2]
          LineShow_D[100][2];   // ������ ��������� ������������ ��������� ����� . ������ ������ ����� ���� ������ - ������������ Line_D[100][2] 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(!ObjectCreate("StartTL", OBJ_VLINE, 0, Time[FirstBar], 0, 0, 0, 0, 0)) return(0);
   ObjectSet("StartTL",OBJPROP_COLOR,Orange);

   ObjectCreate ("MyLabel_D",OBJ_LABEL,0,0,0,0,0,0,0);
   ObjectSetText("MyLabel_D", "Down=  ", 10, "Times New Roman", Red);
   ObjectSet("MyLabel_D", OBJPROP_CORNER,    1);
   ObjectSet("MyLabel_D", OBJPROP_XDISTANCE,50);
   ObjectSet("MyLabel_D", OBJPROP_YDISTANCE,20);

   ObjectCreate ("MyLabel_U",OBJ_LABEL,0,0,0,0,0,0,0);
   ObjectSetText("MyLabel_U", "Up=  ", 10, "Times New Roman", Blue);
   ObjectSet("MyLabel_U", OBJPROP_CORNER,    1);
   ObjectSet("MyLabel_U", OBJPROP_XDISTANCE,50);
   ObjectSet("MyLabel_U", OBJPROP_YDISTANCE,40);
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("StartTL");
   DeleteTrendLine( NameTL_U, 100);
   DeleteTrendLine( NameTL_D, 100);
   DeleteTrendLine( NameCH_U, 100);
   DeleteTrendLine( NameCH_D, 100);
   DeleteTrendLine( NameTR_U, 100);
   DeleteTrendLine( NameTR_D, 100);
   ObjectDelete("MyLabel_D");
   ObjectDelete("MyLabel_U");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
   if (last_bar == Bars )
   {
      if ( FirstBar != iBarShift(Symbol(),Period(), ObjectGet("StartTL",0), FALSE) )     Draw_TL ();
      return(0);
   } 
   last_bar = Bars;
   ObjectMove("StartTL", 0, Time[FirstBar],0);
   Draw_TL ();
   return(0);
}

//+------------------------------------------------------------------+
// ������ ��������� �����                                            |
//+------------------------------------------------------------------+
void Draw_TL ()
{
   int    i,
          j,
          MaxTL,Bar2;
   double Bar1_Value,
          Bar2_Value,
          Bar0_Value;
   FirstBar=iBarShift(Symbol(),Period(), ObjectGet("StartTL",0), FALSE);

   DeleteTrendLine( NameTL_U, 100);
   DeleteTrendLine( NameTL_D, 100);
   DeleteTrendLine( NameCH_U, 100);
   DeleteTrendLine( NameCH_D, 100);
   DeleteTrendLine( NameTR_U, 100);
   DeleteTrendLine( NameTR_D, 100);

   Line_U[0,0]=FirstBar;                           // ������ ��� ������ ��������� ����� Up
   Line_U[0,1]=FindPoint(Line_U[0,0],Bars,1);      // ������ ��� ������ ��������� ����� Up
   Line_D[0,0]=FirstBar;                           // ������ ��� ������ ��������� ����� Down
   Line_D[0,1]=FindPoint(Line_D[0,0],Bars,-1);     // ������ ��� ������ ��������� ����� Down
//-------------
   i=0;
   while ( Line_U[i,1] > Line_U[i,0] )     // ���� ������� ��������� ����� ������� �� ���������� � ������ Line
   {
      i++;
      Line_U[i,0]=Line_U[i-1,1];
      Line_U[i,1]=FindPoint(Line_U[i,0],Bars,1);
   }
//-------------
   MaxTL=i-1;
   cntLine=0;
   j=0;    
   for (i=0; i<=MaxTL; i++) //  �� ������������ ������� �������� ������� ��������� ������ 
   {
      if(Line_U[i,1]-Line_U[i,0] >=DeltaBar )
      {
         cntLine++;
         LineShow_U[j,0]=Line_U[i,0];     // ��������� ������ � �������������� ���������� �������. 1 ����������
         LineShow_U[j,1]=Line_U[i,1];     // ��������� ������ � �������������� ���������� �������. 2 ����������
         j++;
         CreateLine(NameTL_U+cntLine,Time[Line_U[i,1]], Low[ Line_U[i,1] ],Time[Line_U[i,0]],Low[ Line_U[i,0] ],ColorTL_U,STYLE_SOLID);
// ����� ������� ���������� ������ �����  �������������� ����� ������
// int DrawLine (NameTL_U+cntLine, StartPoin, FinPoint, UpDown) ��� ��������� �����,����� ������� ���� Line_U[i,1], ����� ��������� ���� Line_U[i,0], ����������� ������ (Up=1, Down=-1)
         Bar2=DrawLine (NameTL_U+cntLine, Line_U[i,1], Line_U[i,0], 1); // ������� ��� �������������� ����� ������
         Bar2_Value=ObjectGetValueByShift(NameTL_U+cntLine, Bar2);      // �������� ����� ����
         Bar0_Value=Low[ Line_U[i,0] ]+(High[ Bar2 ]-Bar2_Value  );     // ������� ����� ������ ������ � ������ �����
         CreateLine(NameCH_U+cntLine,Time[Line_U[i,1]], Low[ Line_U[i,1] ]+(High[ Bar2 ]-Bar2_Value ),  Time[Line_U[i,0]],Bar0_Value,ColorCH_U,STYLE_DASH);
         ObjectSet   (NameCH_U+cntLine,OBJPROP_RAY,false);
      }   
   }
   ObjectSetText("MyLabel_U", "Up=  "+ cntLine, 12, "Times New Roman", Blue);

   if (InsLine==true)
   {
   //---------- ��������� ������ ����������� ���������� ������� (����� ���������)
      int Bar_1,Bar_2;
      MaxTL=j;
      for(j=0; j<MaxTL; j++)
      {
      
         Bar_1=iHighest(Symbol(),Period(),MODE_HIGH,LineShow_U[j][1]-LineShow_U[j][0],LineShow_U[j][0]); //������ ���. ���������, ��� ������������ �� ������ ������. 
         Bar_2=LineShow_U[j,1];                       // ������ ��� ��������� ������ ��� ������ ��������� ����� Up
         LineI_U[0,0]=Bar_1;                          //������ ��� ��������� �����. ��������� ��� ������������ �� ������ ������.
         LineI_U[0,1]=FindPoint(Bar_1,Bar_2,1);       // ������ ��� ������ ��������� ����� Up
         i=0;
         while ( LineI_U[i,1] > LineI_U[i,0] )        // ���� ������� ��������� ����� ������� �� ���������� � ������ Line
         {
            if ( LineI_U[i,1] - LineI_U[i,0] >DeltaBar ) CreateLine(NameTR_U+((j+1)*10+i+1),Time[LineI_U[i,1]], Low[ LineI_U[i,1] ],  Time[LineI_U[i,0]],Low[ LineI_U[i,0] ],ColorTR_U,STYLE_SOLID);
            ObjectSet   (NameTR_U+((j+1)*10+i+1),OBJPROP_RAY,false);
            i++;
            LineI_U[i,0]=LineI_U[i-1,1];
            LineI_U[i,1]=FindPoint(LineI_U[i,0],Bar_2,1);
         }
      }
    }  
//---------------------------------------- DOWN
   i=0;
   while ( Line_D[i,1] > Line_D[i,0] )              // ���� ������� ��������� ����� ������� �� ���������� � ������ Line
   {
      i++;
      Line_D[i,0]=Line_D[i-1,1];
      Line_D[i,1]=FindPoint(Line_D[i,0],Bars,-1);
   }

   MaxTL=i-1;
   cntLine=0;
   j=0;    
   for (i=0; i<=MaxTL; i++)
   {
      if(Line_D[i,1]-Line_D[i,0] >=DeltaBar )
      {
         cntLine++;
         LineShow_D[j,0]=Line_D[i,0];              // ��������� ������ � �������������� ���������� �������. 1 ����������
         LineShow_D[j,1]=Line_D[i,1];              // ��������� ������ � �������������� ���������� �������. 2 ����������
         j++;
         CreateLine(NameTL_D+cntLine,Time[Line_D[i,1]], High[ Line_D[i,1] ],  Time[Line_D[i,0]],High[ Line_D[i,0] ],ColorTL_D,STYLE_SOLID);
// ����� ������� ���������� ������ �����  �������������� ����� ������
// int DrawLine (NameTL_U+cntLine, StartPoin, FinPoint, UpDown) ��� ��������� �����,����� ������� ���� Line_U[i,1], ����� ��������� ���� Line_U[i,0], ����������� ������ (Up=1, Down=-1)
         Bar2=DrawLine (NameTL_D+cntLine, Line_D[i,1], Line_D[i,0], -1);
         Bar2_Value=ObjectGetValueByShift(NameTL_D+cntLine, Bar2);
         Bar0_Value=High[ Line_D[i,0] ]-(Bar2_Value-Low[ Bar2 ]  );     // ������� ����� ������ ������ � ������ �����
         CreateLine(NameCH_D+cntLine,Time[Line_D[i,1]], High[ Line_D[i,1] ]-(Bar2_Value-Low[ Bar2 ] ),  Time[Line_D[i,0]],Bar0_Value,ColorCH_D,STYLE_DASH);

//         Bar1_Value=ObjectGetValueByShift(NameCH_D+cntLine, Line_D[i,0]);
//         MoveLine(NameCH_D+cntLine,  Time[Line_D[i,1]], High[ Line_D[i,1] ]-(Bar2_Value-Low[ Bar2 ] ),  Time[Line_D[i,0]], Bar1_Value);
         ObjectSet   (NameCH_D+cntLine,OBJPROP_RAY,false);
      }
   }
   ObjectSetText("MyLabel_D", "Down=  "+cntLine , 12, "Times New Roman", Red);
//---------- ��������� ������ ����������� ���������� ������� DOWN
   if (InsLine==true)
   {
      MaxTL=j;
      for(j=0; j<MaxTL; j++)
      {
      
         Bar_1=iLowest(Symbol(),Period(),MODE_LOW,LineShow_D[j][1]-LineShow_D[j][0],LineShow_D[j][0]); //������ ���. ���������, ��� ����������� �� ������ ������. 
         Bar_2=LineShow_D[j,1];      // ������ ��� ��������� ������ ��� ������ ��������� ����� Up
         LineI_D[0,0]=Bar_1; //������ ��� ��������� �����. ��������� ��� ������������ �� ������ ������.
         LineI_D[0,1]=FindPoint(Bar_1,Bar_2,-1);      // ������ ��� ������ ��������� ����� Up
         i=0;
         while ( LineI_D[i,1] > LineI_D[i,0] )     // ���� ������� ��������� ����� ������� �� ���������� � ������ Line
         {
            if ( LineI_D[i,1] - LineI_D[i,0] >DeltaBar ) CreateLine(NameTR_D+((j+1)*10+i+1),Time[LineI_D[i,1]], High[ LineI_D[i,1] ],  Time[LineI_D[i,0]],High[ LineI_D[i,0] ],ColorTR_D,STYLE_SOLID);
         
            ObjectSet   (NameTR_D+((j+1)*10+i+1),OBJPROP_RAY,false);
            i++;
            LineI_D[i,0]=LineI_D[i-1,1];
            LineI_D[i,1]=FindPoint(LineI_D[i,0],Bar_2,-1);
         }
      }
   }   
}


//+------------------------------------------------------------------+
//| ������� ���������� ������ ����� �������������� ����� ������      |
//+------------------------------------------------------------------+
int DrawLine (string NameTL,int StartPoint, int FinPoint, int UpDown)
// NameTL     - ������������ ��������� �����, �� ������� ����
// StartPoint - ������ ������
// FinPoint   - ��������� ������
// UpDown     - ����������� ������ (Up=1, Down=-1)
// ����� ������� ���� Line_U[i,1], ����� ��������� ���� Line_U[i,0], ����������� ������ (Up=1, Down=-1)
{
   int    i,
          FinBar;
   double MaxValue=0,
          TekValue=0;
   FinBar=StartPoint;
   for (i=StartPoint; i>=FinPoint; i--)
   {
      if (UpDown==1) TekValue=High[i]-ObjectGetValueByShift(NameTL, i);
      else TekValue=ObjectGetValueByShift(NameTL, i)-Low[i];
      if(TekValue>MaxValue)
      {
          MaxValue=TekValue;
          FinBar=i;
      }
   }
   return(FinBar);
}

//+------------------------------------------------------------------+
//| ��������  ��������� ����                                         |
//+------------------------------------------------------------------+
bool CreateLine(string Name_Line,datetime X1, double Y1, datetime X2, double Y2, color Color_Line, int Style_Line)
{
   if (!ObjectCreate(Name_Line, OBJ_TREND, 0, 0, 0, 0, 0, 0, 0)) return( false);
   ObjectSet(Name_Line,OBJPROP_COLOR,Color_Line);
   ObjectSet(Name_Line,OBJPROP_STYLE,Style_Line);
   MoveLine(Name_Line, X1, Y1,  X2,Y2 );
   return (true);
}

//+------------------------------------------------------------------+
//| ����������� ��������� ����                              |
//+------------------------------------------------------------------+
void MoveLine(string NameLine,datetime X1, double Y1, datetime X2, double Y2)
{
   ObjectMove(NameLine, 0, X1, Y1);
   ObjectMove(NameLine, 1, X2, Y2);
   return;
 }

//+------------------------------------------------------------------+
//| ����� ������ ����� ��������� ����� UP                               |
//+------------------------------------------------------------------+
int FindPoint(int Bar_1, int Bar_Fin, int Trend )
// Bar_1 - ����� ���� ��� ������ ������ � ������ ����� ��������� �����
// Bar_Fin - ��� ��������� ������ 
// Bar_2 - ������������ �������� - ���� ���� ������ ����� ��������� ����� 
{
   int       Bar_2,
             i;
   double    BarValue_1,
             BarValue_2,
             BarValue_i;
   Bar_2=Bar_1;
   for ( i= Bar_1+1; i<Bar_Fin; i++) // ���� ������ ����� Bar_2, ������� ������  Bar_1
   {
      if (Trend==1) // ���� Up
      {
         if (Low[i]<Low[Bar_1])
         {
            Bar_2=i;
            break;
         }
      }
      else // ���� Down
      {
         if (High[i]>High[Bar_1])
         {
            Bar_2=i;
            break;
         }
      }
   }
 if (Bar_2>Bar_1) // ���� Bar_2 �������, ��
 {
   int    MaxBar=Bar_2;
   double LineFirst;
   if (Trend==1) // ���� Up
   {
      LineFirst=(Low[Bar_1]-Low[Bar_2])/(Bar_2-Bar_1);
      for (i=MaxBar+1; i<Bars ; i++) // ���� ���������� ����� 
      {
         if ( (Low[Bar_1]-Low[i])/(i-Bar_1) > LineFirst )
         {
           Bar_2=i;
           LineFirst=(Low[Bar_1]-Low[Bar_2])/(Bar_2-Bar_1);
         } 
      }
   }
   else // ���� Down
   {
      LineFirst=(High[Bar_2]-High[Bar_1])/(Bar_2-Bar_1);
      for (i=MaxBar+1; i<Bars ; i++) // ���� ���������� ����� 
      {
         if ( (High[i]-High[Bar_1])/(i-Bar_1) > LineFirst )
         {
           Bar_2=i;
           LineFirst=(High[Bar_2]-High[Bar_1])/(Bar_2-Bar_1);
         } 
      }
   }
 }
return (Bar_2);   
}

//+------------------------------------------------------------------+
//| �������� ��������� ����� nameTL � ���������� qntTL               |
//+------------------------------------------------------------------+
void DeleteTrendLine( string nameTL, int qntTL)
{
   for (int i=1; i< qntTL+10; i++)       ObjectDelete(nameTL+i);
}
   
//+------------------------------------------------------------------+


