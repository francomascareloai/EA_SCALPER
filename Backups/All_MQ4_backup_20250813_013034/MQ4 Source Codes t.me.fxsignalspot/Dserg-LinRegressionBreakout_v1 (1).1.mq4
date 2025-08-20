//+------------------------------------------------------------------+
//|                                                                  |
//|       Индикатор для автоматического построения сужения           |
//|       каналов линейной регрессии                                 |
//|                               http://www.mql4.com/ru/users/Dserg |
//+------------------------------------------------------------------+
#property  copyright "Dserg, 2010"
#property  link      "http://www.mql4.com/ru/users/Dserg"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 8
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DeepSkyBlue
#property indicator_color3 FireBrick
#property indicator_color4 DeepSkyBlue
#property indicator_color5 DeepSkyBlue
#property indicator_color6 Yellow
#property indicator_color7 HotPink
#property indicator_color8 LawnGreen 

//---- buffers
double B0[];
double B1[];
double Stop[];
double B3[];
double B4[];
double Up[];
double Dn[];
double Target[];

extern string S1="Мин. длина канала линейной регрессии";
extern int Nlin=25;
extern string S2="Макс. высота канала в пунктах";
extern int r0=150;
extern string S3="Цель при пробое отн. ширины канала";
extern double t0=2.618;
extern string S4="Использовать для расчёта Close,\n если false - High/Low";
extern bool useClose=true;
extern string S5="Количество баров для рассчёта";
extern int Nbars=5000;

bool isChannel;
datetime chEnd;
double a0;
double b0;
double range0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3additional buffers are used for counting.
   
//---- drawing settings

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, B0);      
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1, B1);      
   SetIndexStyle(2,DRAW_ARROW,0,2);
   SetIndexBuffer(2, Stop);      
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(3, B3);      
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(4, B4);      

   SetIndexStyle(5,DRAW_ARROW,0,1);
   SetIndexBuffer(5, Up);      
   SetIndexArrow(5, 233);        
   SetIndexStyle(6,DRAW_ARROW,0,1);
   SetIndexBuffer(6, Dn);      
   SetIndexArrow(6, 234);        
   SetIndexStyle(7,DRAW_ARROW,0,1);
   SetIndexBuffer(7, Target);      
   SetIndexArrow(7, 231);        

   SetIndexEmptyValue(0,0.0);   
   SetIndexEmptyValue(1,0.0);   
   SetIndexEmptyValue(2,0.0);   
   SetIndexEmptyValue(3,0.0);   
   SetIndexEmptyValue(4,0.0);   
   SetIndexEmptyValue(5,0.0);   
   SetIndexEmptyValue(6,0.0);   
   SetIndexEmptyValue(7,0.0);   

   SetIndexLabel(0,"Channel Low");
   SetIndexLabel(1,"Channel High");
   SetIndexLabel(2,"Stop/Reverse");
   SetIndexLabel(3,"Channel Low Extended");
   SetIndexLabel(4,"Channel High Extended");
   SetIndexLabel(5,"BUY Signal");
   SetIndexLabel(6,"SELL Signal");
   SetIndexLabel(7,"Target");

   isChannel=false;
   
   return(0);
  } 

int deinit()
  {
  } 

int start()

  {
 
     if(Bars-IndicatorCounted()==0) return(0);
     // int loopbegin = Bars - IndicatorCounted()+20*Nlin;
      int loopbegin = Nbars;
 
      int i,j;
      double a,b,c,
             sumy=0.0,
             sumx=0.0,
             sumxy=0.0,
             sumx2=0.0,
             h=0.0,l=0.0,
             range = 0.0;   
      isChannel=false;
      for(i = loopbegin; i >= 0; i--) {
         B0[i]=0;
         B1[i]=0;
         B3[i]=0;
         B4[i]=0;
         Up[i]=0;
         Dn[i]=0;
         Stop[i]=0;
         Target[i]=0;
      }
      
      for(i = loopbegin; i >= 0; i--) {
         
         
         //у нас уже есть канал, ждём, пока его пробьёт
         if (isChannel) {
            //double up0=a0*(i-chEnd)+b0+range0;
            //double dn0=a0*(i-chEnd)+b0-range0;
            double up0=a0*i+b0+range0;
            double dn0=a0*i+b0-range0;
            B3[i]=up0;
            B4[i]=dn0;
            //проверяем пробитие
            //вверх
            if (Open[i]>up0) {
               Up[i]=up0;
               Stop[i]=dn0;
               Target[i]=up0+(up0-dn0)*(t0-1);
               isChannel=false;
               //continue;
            }
            //вниз
            if (Open[i]<dn0) {
               Dn[i]=dn0;
               Stop[i]=up0;
               Target[i]=dn0-(up0-dn0)*(t0-1);
               isChannel=false;
               //continue;
            }
            continue;
         }            

         bool flag=false;
         for (j=0;j<Nlin+1;j++) {
            if (B3[i+j]>0.0&&!isChannel) {
               flag=true;
            }
         }
         if (flag) continue;
         
         
         a=0.0;b=0.0;c=0.0;
         sumx=0.0;sumy=0.0;
         sumxy=0.0;sumx2=0.0;
         h=0.0;l=0.0;

         //считаем канал линейной регрессии от i+Nlin до i 
         for(j=0; j<Nlin; j++)
         {
            sumy+=Close[i+j];
            sumxy+=Close[i+j]*(i+j);
            sumx+=(i+j);
            sumx2+=(i+j)*(i+j);
         }
         c=sumx2*Nlin-sumx*sumx;
         if(c==0.0) {
            Alert("Error in linear regression!");
            return(-1);
         }
         a=(sumxy*Nlin-sumx*sumy)/c;
         b=(sumy-sumx*a)/Nlin;
         
         //определяем границы канала
         for(j=0;j<Nlin;j++)
         {
           double LR=a*(i+j)+b;
           if (useClose) {
             if(Close[j+i]-LR > h) h = Close[i+j]-LR;
             if(LR - Close[i+j]> l) l = LR - Close[i+j];
           } else {
             if(High[j+i]-LR > h) h = High[i+j]-LR;
             if(LR - Low[i+j]> l) l = LR - Low[i+j];
           }           
         }  
         range = MathMax(l,h);
         
         //проверка ширины канала
         if (range<r0*Point) {
            //есть канал, сохраняем
            isChannel=true;
            a0=a;
            b0=b;
            chEnd=iTime(NULL,0,i);
            range0=range;
            
            for (j=0;j<Nlin;j++) {
               B3[i+j]=a*(i+j)+b+range;
               B4[i+j]=a*(i+j)+b-range;
               B0[i+j]=a*(i+j)+b+range;
               B1[i+j]=a*(i+j)+b-range;
            }
         }
            

         
      }
      return(0);
  }
//+------------------------------------------------------------------+



