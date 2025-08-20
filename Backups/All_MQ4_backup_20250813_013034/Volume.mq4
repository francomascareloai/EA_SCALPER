
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Yellow
#property indicator_color4 Lime
#property indicator_color5 White
#property indicator_color6 Magenta
#property indicator_color7 Maroon

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2


extern int     NumberOfBars = 500;
extern string  Note = "0 means Display all bars";
extern int     MAPeriod = 100;
extern int     LookBack = 20;


double red[],blue[],yellow[],green[],white[],magenta[],v4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
      SetIndexBuffer(0,red);
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexLabel(0,"Climax High ");
      
      SetIndexBuffer(1,blue);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexLabel(1,"Neutral");
      
      SetIndexBuffer(2,yellow);
      SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexLabel(2,"Low ");
      
      SetIndexBuffer(3,green);
      SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexLabel(3,"HighChurn ");
      
      SetIndexBuffer(4,white);
      SetIndexStyle(4,DRAW_HISTOGRAM);
      SetIndexLabel(4,"Climax Low ");
      
      SetIndexBuffer(5,magenta);
      SetIndexStyle(5,DRAW_HISTOGRAM);
      SetIndexLabel(5,"ClimaxChurn ");
      
      SetIndexBuffer(6,v4);
      SetIndexStyle(6,DRAW_LINE,0,2);
      SetIndexLabel(6,"Average("+MAPeriod+")");
      
      IndicatorShortName("Volume" );
      

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   double VolLowest,Range,Value2,Value3,HiValue2,HiValue3,LoValue3,tempv2,tempv3,tempv;
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   if ( NumberOfBars == 0 ) 
      NumberOfBars = Bars-counted_bars;
   limit=NumberOfBars; //Bars-counted_bars;
   
      
   for(int i=0; i<limit; i++)   
      {
         red[i] = 0; blue[i] = Volume[i]; yellow[i] = 0; green[i] = 0; white[i] = 0; magenta[i] = 0;
         Value2=0;Value3=0;HiValue2=0;HiValue3=0;LoValue3=99999999;tempv2=0;tempv3=0;tempv=0;
         
         
         VolLowest = Volume[iLowest(NULL,0,MODE_VOLUME,20,i)];
         if (Volume[i] == VolLowest)
            {
               yellow[i] = NormalizeDouble(Volume[i],0);
               blue[i]=0;
            }
               
         Range = (High[i]-Low[i]);
         Value2 = Volume[i]*Range;
         
         if (  Range != 0 )
            Value3 = Volume[i]/Range;
            
         
         for ( int n=i;n<i+MAPeriod;n++ )
            {
               tempv= Volume[n] + tempv; 
            } 
          v4[i] = NormalizeDouble(tempv/MAPeriod,0);
         
          
          for ( n=i;n<i+LookBack;n++)
            {
               tempv2 = Volume[n]*((High[n]-Low[n])); 
               if ( tempv2 >= HiValue2 )
                  HiValue2 = tempv2;
                    
               if ( Volume[n]*((High[n]-Low[n])) != 0 )
                  {           
                     tempv3 = Volume[n] / ((High[n]-Low[n]));
                     if ( tempv3 > HiValue3 ) 
                        HiValue3 = tempv3; 
                     if ( tempv3 < LoValue3 )
                        LoValue3 = tempv3;
                  } 
            }
                                      
          if ( Value2 == HiValue2  && Close[i] > (High[i] + Low[i]) / 2 )
            {
               red[i] = NormalizeDouble(Volume[i],0);
               blue[i]=0;
               yellow[i]=0;
            }   
            
          if ( Value3 == HiValue3 )
            {
               green[i] = NormalizeDouble(Volume[i],0);                
               blue[i] =0;
               yellow[i]=0;
               red[i]=0;
            }
          if ( Value2 == HiValue2 && Value3 == HiValue3 )
            {
               magenta[i] = NormalizeDouble(Volume[i],0);
               blue[i]=0;
               red[i]=0;
               green[i]=0;
               yellow[i]=0;
            } 
         if ( Value2 == HiValue2  && Close[i] <= (High[i] + Low[i]) / 2 )
            {
               white[i] = NormalizeDouble(Volume[i],0);
               magenta[i]=0;
               blue[i]=0;
               red[i]=0;
               green[i]=0;
               yellow[i]=0;
            } 
            
         
      }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
         