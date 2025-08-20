//+------------------------------------------------------------------+
//|                                                   NeuroProba.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Red
//---- input parameters
extern int       BeginBar=300; // начальный бар в обучающей выборке
extern int       EndBar=201; // конечный бар в обучающей выборке
extern int       StudyNumber=100; // количество обучающих циклов
extern double    Betta=0.5; // крутизна сигмоидальной функции
extern double    StudyCoeff=0.1; // коэффициент обучения
extern double    MaxRandom=0.66;//2.0/MathSqrt(9);
//---- buffers
double NeuroExitBuffer[]; // выходные значения нейросети
double TeacherBuffer[]; // эталонные значения нейросети (обучающие сигналы)
double ErrorBuffer[]; // отклонения на каждом баре
//---- 
double deviation; // отклонение на каждом шаге обучения 
double GradientFirstLay[9][9];// для расчета градиента 1-го слоя
double GradientSecondLay[9]; //  для расчета градиента 2-го слоя
double OutputFirstLay[9]; // сумма выхода каждого нейрона
double SecondSum;// сумма выходного слоя - аргумент сигмоидальной функции
double FirstLayWeights[9][9]; // веса нейронов первого (скрытого слоя)
double OutputSecondWeights[9]; // веса выходного нейрона
double InputNormalX[100][9]; // нормализованная выборка входных сигналов
double InputX[9]; // текущий входной вектор (ненормализованный)
double Normа;// норма текущего входного вектора
double U_First[9];// значения на выходе слоя скрытых (входных) нейронов
double U_Second;//  значение на выходе выходного нейрона (аргумент сигмоидальной функции)
double SigmaCurr;
double Differ;
//+----------------------------------------------
//  нормализованная случайная функция на интервале (0,MaxValue), если аргумент пропущен - на (0,1)
//+----------------------------------------------
double NormalRand(double MaxValue=1.0)
   {
   double answer;
   answer=MathRand()/32767.0;
   answer=MaxValue*answer;
   return(answer);
   }
//+----------------------------------------------
//  нормализованная случайная функция
//+----------------------------------------------


//------------------------------------------
// определение сигмоидальной функции  (тангенс гипреболический)
//------------------------------------------
double Sigma(double argument)
   {
   double help;
   help=(MathExp(argument)-MathExp(-argument))/(MathExp(argument)+MathExp(-argument));
   return(help);
   }
//------------------------------------------
// определение сигмоидальной функции
//------------------------------------------

//------------------------------------------
// вычисление аргумента сигмоидальной функции
//------------------------------------------
double GetArgument()
   {
   int j;
   double answer=0.0;
   for (j=0;j<9;j++)
      {
      answer=answer+OutputSecondWeights[j]*OutputFirstLay[j];
      }
   return(answer);
   }
//------------------------------------------
// вычисление аргумента сигмоидальной функции
//------------------------------------------

//------------------------------------------
// вычисление выходов нейронов первого слоя
//------------------------------------------
void GetFirstLayOutput()
   {
   int j,t;
   for (j=0;j<9;j++)
      {
      OutputFirstLay[j]=0.0;      
      for (t=0;t<9;t++)
         {
         OutputFirstLay[j]=OutputFirstLay[j]+FirstLayWeights[j,t]*InputX[t];
         }
      }
   return(0);
   }
//------------------------------------------
// вычисление выходов нейронов первого слоя
//------------------------------------------

//------------------------------------------
// вычисление градиента весов нейронов 
//------------------------------------------
void SetGradientWeights()
   {
   int j,t;
   for (j=0;j<9;j++)
      {
      //GradientFirstLay[j,t]=0.0;
      for (t=0;t<9;t++)
         {
         GradientFirstLay[j,t]=OutputSecondWeights[j]*InputX[t]*deviation*Differ;
         //GradientFirstLay[j,t]=GradientFirstLay[j,t]+OutputSecondWeights[j]*InputX[t];
         }
      //GradientFirstLay[j,t]=GradientFirstLay[j,t]*deviation*Differ;
      GradientSecondLay[j]=OutputFirstLay[j]*deviation*Differ;
      }
   }
//------------------------------------------
// вычисление градиента весов нейронов 
//------------------------------------------

//------------------------------------------
// изменение весов нейронов 
//------------------------------------------
void ChangeWeigts()
   {
   int i,k;
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)
         {
         FirstLayWeights[i,k]=FirstLayWeights[i,k]-StudyCoeff*GradientFirstLay[i,k];
         }
      OutputSecondWeights [i]=OutputSecondWeights [i]-StudyCoeff*GradientSecondLay[i];// изменение весов выходного нейрона
      } 
   }
//------------------------------------------
// изменение весов нейронов
//------------------------------------------

//------------------------------------------
// вывод в Журнал весов нейронов
//------------------------------------------
void PrintWeights()
   {
   int i,k;
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)   
         {
//         Print("W1["+i+","+k+"]=",FirstLayWeights[i,k]);
         }
//      Print("W2["+i+"]=",OutputSecondWeights[i]);
      }
   }
//------------------------------------------
// вывод в Журнал весов нейронов
//------------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,NeuroExitBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TeacherBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ErrorBuffer);
   SetIndexLabel(0,"Answer");
   SetIndexLabel(1,"Teacher");
   SetIndexLabel(2,"Error");
   ArrayInitialize(NeuroExitBuffer,0.0);      
   ArrayInitialize(TeacherBuffer,0.0);      
   ArrayInitialize(ErrorBuffer,0.0); 
//------------------------------------------
// заполнение выборки входных сигналов
//------------------------------------------
   int i,k,m,n,p; // m - индекс весов выходного нейрона, p - счетчик цикла обучения
   for (i=BeginBar;i>=EndBar;i--)
      {
      Normа=0.0;
      for (k=0;k<=8;k++)
         {InputX[k]=Close[i]-Close[i+k+1];
         Normа=Normа+InputX[k]*InputX[k];
         }
      Normа=MathSqrt(Normа);   
      for (k=0;k<=8;k++)
         {      
         InputNormalX[BeginBar-i,k]=InputX[k]/Normа;
         TeacherBuffer[BeginBar-i]=0.0;
         if (iCustom(NULL,0,"Kaufman2",1,i)>0) TeacherBuffer[BeginBar-i]=1;
         if (iCustom(NULL,0,"Kaufman2",2,i)>0) TeacherBuffer[BeginBar-i]=-1;
      //TeacherBuffer[BeginBar-i]=iCustom(NULL,0,"KaufmanTrend",0,BeginBar);      
         }
       }
//------------------------------------------
// заполнение выборки входных сигналов
//------------------------------------------
   MathSrand(LocalTime());
//------------------------------------------
// заполнение весов нейронов случайными величинами
//------------------------------------------
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)
         {
         FirstLayWeights[i,k]=NormalRand(MaxRandom);
//         Print("FirstLayWeights["+i+","+k+"]=",FirstLayWeights[i,k]);
         }
      OutputSecondWeights[i]=NormalRand(MaxRandom);
      }
//------------------------------------------
// заполнение весов нейронов случайными величинами
//------------------------------------------
   PrintWeights();
//   Print("Sigma=",Sigma(NormalRand()));
   Print("Инициализация закончена");

//------------------------------------------
// обучение
//------------------------------------------
for (p=1;p<=StudyNumber;p++) // цикл обучения - p-номер обучения
   {
   for (n=0;n<100;n++) // проход по выборке входных сигналов -  n-номер обучающего сигнала
      {
      for (int z=0;z<9;z++) InputX[z]=InputNormalX[n,z]; // заполним входной вектор из массива подготовленных нормализованных векторов
      GetFirstLayOutput();
      U_Second=GetArgument();
      Print("p=",p," n=",n," U_Second=",U_Second);
      PrintWeights();
      SigmaCurr=Sigma(Betta*U_Second);
      Differ=Betta*(1-SigmaCurr*SigmaCurr); // производная от тангенса гиперболического
      deviation=TeacherBuffer[BeginBar-n]-SigmaCurr; //ошибка получена, теперь надо подкорректировать веса
      SetGradientWeights();
      ChangeWeigts();
      }// проход по выборке входных сигналов   
   }// цикл обучения
//------------------------------------------
// обучение
//------------------------------------------
   PrintWeights();
   Comment("Обучение закончено");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,m;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   int limit;
   //limit=Bars-10-counted_bars;
   limit=300;
   for (i=limit;i>=0;i--) 
      {
      if (iCustom(NULL,0,"Kaufman2",1,i)>0) TeacherBuffer[i]=1;
      if (iCustom(NULL,0,"Kaufman2",2,i)>0) TeacherBuffer[i]=-1;
      Normа=0.0;
      for (m=0;m<9;m++)
         {
         InputX[m]=Close[i]-Close[i+m+1];
         Normа=Normа+InputX[m]*InputX[m];
         }
      Normа=MathSqrt(Normа);
      Print("Normа=",Normа);
      for (m=0;m<9;m++)
         {
         InputX[m]=InputX[m]/Normа;
         }
      GetFirstLayOutput();
      U_Second=GetArgument();
      Print("U_Second=",U_Second);
      NeuroExitBuffer[i]=Sigma(Betta*U_Second);
      //Print("NeuroExitBuffer["+i+"]=",NeuroExitBuffer[i]);
      ErrorBuffer[i]=TeacherBuffer[i]-NeuroExitBuffer[i];
      }
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+