//+------------------------------------------------------------------+
//|                                                      SHI_Mod.mq4 |
//|                                 Copyright © 2004, Shurka & Kevin |
//|                                 Corrected&Upgraded by Modest     |
//+------------------------------------------------------------------+
// Modest- исправлен алгоритм нахождения опорной точки между 
// обнаруженными фракталами для построения линии канала
// Добавлена возможность тестирования на истории при помощи программы MetaClick.
// При тестировании линии канала продолжаются в будушее
#property copyright "Copyright © 2004, Shurka & Kevin "
#property link      ""
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
double ExtMapBuffer1[];
double UpLabel[];

extern int       BarsForFract=0;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1,iB1=0,iB2=0,flag=0;
int UpDown=0;
double P1=0,P2=0,PP=0,P1f=0,PPf=0;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2,Tf;
string fileNAME;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,164);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);

    SetIndexStyle(1,DRAW_ARROW,EMPTY,1,Blue);
    SetIndexBuffer(1,UpLabel);
    SetIndexArrow(1, 251);
    SetIndexEmptyValue(1,0);
	
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   FileDelete(fileNAME);
//----
   return(0);
  }

void DelObj()
{
	ObjectDelete("TL1");	ObjectDelete("TL2");	ObjectDelete("MIDL");
   ObjectDelete("Lab1");ObjectDelete("Lab2");ObjectDelete("Lab3");
   ObjectDelete("TL1f");ObjectDelete("TL2f");
   ObjectDelete("MyBarLine");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
   double iPP,Lab1Val,Lab2Val,Lab3Val;
   int MyBar,lastBarTime,h1,ii;
   string v1,fileFrame;
//****************************************************************************************  
//   Чтение данных (строка)  из внешнего файла, сформированного программой MetaClick,    
//   путём тыка в бар (Z+LeftMouse) указывающей время, до которого строится индикатор.
//   Ищем нужный номер бара
//**************************************************************************************** 
      switch (Period())  // Формирование части имени внешнего файла
      {
      case PERIOD_M1:     fileFrame=",M1";break;
      case PERIOD_M5:     fileFrame=",M5";break;
      case PERIOD_M15:    fileFrame=",M15";break;
      case PERIOD_M30:    fileFrame=",M30";break;
      case PERIOD_H1:     fileFrame=",H1";break;
	   case PERIOD_H4:     fileFrame=",H4";break;
	   case PERIOD_D1:     fileFrame=",Daily";break;
	   case PERIOD_W1:     fileFrame=",Weekly";break;
	   case PERIOD_MN1:    fileFrame=",Monthly";break;   
      }
      fileNAME=Symbol()+fileFrame+".csv";
      h1=FileOpen(Symbol()+fileFrame+".csv",FILE_CSV,";");
      v1 = FileReadString(h1);
      FileClose(h1);
      Comment(v1);
      lastBarTime=StrToTime(v1);
      i=0;
      while (i<=Bars-1 )
      {if (lastBarTime==Time[i])
         { MyBar=i;break;}
      i++;
      }
//**********^^ Закончили искать последний бар для построения индикатора **************** 
   ArrayInitialize(UpLabel,0.0);
   if (Bars<MyBar+303) {Alert("Too little history");return(-1);}
   int    counted_bars=IndicatorCounted();
//---- 
	//if(Bars<AllBars)  AllBars=Bars;                 //return(-1);
	//if(AllBars<AB) {Comment("Мало баров"); return(-1);}
	//Alert("MyBar=",MyBar);
	//if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-количество обсчитываемых баров
	if (BarsForFract>0) 
		BFF=BarsForFract; 
	else
	{
		switch (Period())
		{
			case 1: BFF=12; break;
			case 5: BFF=48; break;
			case 15: BFF=24; break;
			case 30: BFF=24; break;
			case 60: BFF=12; break;
			case 240: BFF=15; break;
			case 1440: BFF=10; break;
			case 10080: BFF=6; break;
			default: DelObj(); return(-1); break;
		}
	}
	CurrentBar=2+MyBar; //считаем с третьего бара, чтобы фрактал "закрепился
	B1=-1; B2=-1; UpDown=0; flag=0;
	
	while(((B1==-1) || (B2==-1)) && (CurrentBar<(AB+MyBar)))
	{
		//UpDown=1 значит первый фрактал найден сверху, UpDown=-1 значит первый фрактал
		//найден снизу, UpDown=0 значит фрактал ещё не найден.
		//В1 и В2 - номера баров с фракталами, через них строим опорную линию.
		//Р1 и Р2 - соответственно цены через которые будем линию проводить
     // if (CurrentBar==4 ) Alert("CurrentBar=",CurrentBar," ","BFF=",BFF);
		
		if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF))) 
	// Выражение CurrentBar-BFF может быть в дан случае отрицательным. Но вроде работает
	
		{
		  if(UpDown==0) { UpDown=-1; B1=CurrentBar; iB1=CurrentBar; P1=Low[B1];}
			else { B2=CurrentBar; iB2=CurrentBar; P2=Low[B2];}
		}
		if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF))) 
	
		{
			if(UpDown==0) { UpDown=1; B1=CurrentBar; iB1=CurrentBar; P1=High[B1];}
			else { B2=CurrentBar; iB2=CurrentBar; P2=High[B2];}
		}
		CurrentBar++;
	}
	if((B1==-1) || (B2==-1)) {DelObj(); return(-1);} // Значит не нашли фракталов среди 300 баров 8-)
	Step=(P2-P1)/(B2-B1);//Вычислили шаг, если он положительный, то канал нисходящий
	P1=P1-(B1-MyBar)*Step; B1=0+MyBar;//переставляем цену и первый бар к нулю (значение опорной линии на 0 баре)
	
	//А теперь опорную точку противоположной линии канала.
	ishift=0+MyBar; iprice=0;
	
	//Alert(UpDown);
	if(UpDown==1)
	{ 
		//  Исправлено!!  Опорную точку будем искать МЕЖДУ обнаруженными фракталами,
		//  а не с 0-го (MyBar) бара. iB1-это не измененный B1
		
		//PP=Low[2+MyBar]-(2)*Step;
				
		PP=Low[2+iB1]-(2)*Step;
		iPP=Low[2+iB1]-(2)*Step;
		ii=2+iB1;
		//for(i=3+MyBar;i<=B2;i++) 
		for(i=3+iB1;i<=B2;i++) 
		{
			//if(Low[i]<PP+Step*(i-MyBar)) { PP=Low[i]-(i-MyBar)*Step; ii=i;}
		    if(Low[i]<iPP+Step*(i-iB1)) 
		       //PP-значение линии на последнем баре
		       // iPP-значение линии на баре iB1 -правый фрактал
		       { PP=Low[i]-(i-MyBar)*Step; ii=i;
		        iPP=Low[i]-(i-iB1)*Step;  
		       }
		}
		
		//Alert(iB1,"  ",iB2,"  ",ii,"  ","Step=",Step,"  ","PP=",PP);
		//Lab1Val=(High[iB1]+5*Point); 	Lab2Val=(High[iB2]+5*Point); 	Lab3Val=(Low[ii]-5*Point);
		UpLabel[iB1]=High[iB1]+5*Point;
		UpLabel[iB2]=High[iB2]+5*Point;
		UpLabel[ii]=Low[ii]-5*Point;
		
		//Alert(iB1,"  ",ii,"  ",iB2,"  ","Step=",Step,"  ","PP=",PP,"  ","Lab1Val=",Lab1Val);

		
		if(Low[0+MyBar]<PP) {ishift=0+MyBar; iprice=PP;}
		if(Low[1+MyBar]<PP+Step) {ishift=1+MyBar; iprice=PP+Step;}
		if(High[0+MyBar]>P1) {ishift=0+MyBar; iprice=P1;}
		if(High[1+MyBar]>P1+Step) {ishift=1+MyBar; iprice=P1+Step;}
	} 
	else  //тренд вниз
	{ 
		PP=High[2+MyBar]-(2)*Step;
		iPP=High[2+iB1]-(2)*Step;
		ii=2+iB1;
		//for(i=3+MyBar;i<=B2;i++) 
		for(i=3+iB1;i<=B2;i++)  
		{
			if(High[i]>iPP+Step*(i-iB1)) { PP=High[i]-(i-MyBar)*Step;ii=i;
			                                 iPP=High[i]-(i-iB1)*Step;
			                               } //ищем значение верхней линии на 0 баре
		}
		
		//Lab1Val=(Low[iB1]-5*Point);Lab2Val=(Low[iB2]-5*Point);Lab3Val=(High[ii]+5*Point);
		UpLabel[iB1]=Low[iB1]-5*Point;
		UpLabel[iB2]=Low[iB2]-5*Point;
		UpLabel[ii]=High[ii]+5*Point;
		
		
		
		//Alert(iB1,"  ",iB2,"  ","ii=",ii,"  ","Step=",Step,"  ","PP=",PP,"  ",
		//       "Lab1Val=",Lab1Val,"Lab3Val=",Lab3Val);
		
		// определяем, было ли пересечение линий канала на 0 или 1 барах(чтобы ставить псису)
		if(Low[0+MyBar]<P1) {ishift=0+MyBar; iprice=P1;}
		if(Low[1+MyBar]<P1+Step) {ishift=1+MyBar; iprice=P1+Step;}
		if(High[0+MyBar]>PP) {ishift=0+MyBar; iprice=PP;}
		if(High[1+MyBar]>PP+Step) {ishift=1+MyBar; iprice=PP+Step;}
	}
	//Теперь переставим конечную цену и бар на АВ, чтобы линии канала рисовались подлиннее
	P2=P1+AB*Step;
	T1=Time[B1]; T2=Time[AB+MyBar];

	//Если не было пересечения канала, то 0, иначе ставим псису.
	//if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
	DelObj();
	
	//Alert("B1=",B1,"  ","B2=",AB+MyBar,"    ","AB=",AB,"  ","MyBar=",MyBar);
//	Alert("T1=",T1,"  ","T2=",T2);

//***************************************** Рисуем линии канала ************************
	ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*(AB),T1,PP); 
		ObjectSet("TL1",OBJPROP_COLOR,Tomato); 
		ObjectSet("TL1",OBJPROP_WIDTH,2); 
		ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID); 
      ObjectSet("TL1",OBJPROP_RAY,False); 
	ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1); 
		ObjectSet("TL2",OBJPROP_COLOR,Tomato); 
		ObjectSet("TL2",OBJPROP_WIDTH,2); 
		ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
	   ObjectSet("TL2",OBJPROP_RAY,False); 
	ObjectCreate("MIDL",OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
		ObjectSet("MIDL",OBJPROP_COLOR,Tomato); 
		ObjectSet("MIDL",OBJPROP_WIDTH,1); 
		ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("MIDL",OBJPROP_RAY,False); 

//*********************************** Рисуем продолжение канала ************************
     if (MyBar>30) {Tf=Time[MyBar-30]; 
                     PPf=PP-Step*30; P1f=P1-Step*30;
                   }
     else          {Tf=Time[0];PPf=PP-MyBar*Step; P1f=P1-MyBar*Step; 
                   }
    ObjectCreate("TL1f",OBJ_TREND,0,T1,PP,Tf,PPf); 
		ObjectSet("TL1f",OBJPROP_COLOR,Green); 
		ObjectSet("TL1f",OBJPROP_WIDTH,1); 
		ObjectSet("TL1f",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("TL1f",OBJPROP_RAY,False); 
    ObjectCreate("TL2f",OBJ_TREND,0,T1,P1,Tf,P1f); 
		ObjectSet("TL2f",OBJPROP_COLOR,Green); 
		ObjectSet("TL2f",OBJPROP_WIDTH,1); 
		ObjectSet("TL2f",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("TL2f",OBJPROP_RAY,False); 
    
//************************* Отмечаем кликнутый бар  ************************************    
   if (MyBar>0)    
      {
      ObjectCreate("MyBarLine",OBJ_VLINE,0,Time[MyBar],High[MyBar]); 
      ObjectSet("MyBarLine",OBJPROP_COLOR,MediumOrchid); 
		ObjectSet("MyBarLine",OBJPROP_WIDTH,1); 
		ObjectSet("MyBarLine",OBJPROP_STYLE,STYLE_DOT); 
      }

   
//----
   return(0);
  }
//+------------------------------------------------------------------+