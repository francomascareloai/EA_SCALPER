// fukinagashi

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
input string               inpUniqueID      = "fib o1";         // Objects unique ID
extern int                 ExtDepth         = 12;
extern int                 ExtDeviation     = 5;
extern int                 ExtBackstep      = 3;
extern string              FiboLevels       = "0;23.6;38.2;50;61.8;100";
extern color               FiboColor        = clrDodgerBlue;
extern int                 FiboWidth        = 1;
extern ENUM_LINE_STYLE     FiboStyle        = STYLE_DOT;
extern ENUM_LINE_STYLE     FiboLevelsStyle  = STYLE_SOLID;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
double levelv[];
string levels[];
double values[];
int OldLastZigZag, OldPreviousZigZag;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    FiboLevels = StringTrimLeft(StringTrimRight(FiboLevels));
      if (StringSubstr(FiboLevels,StringLen(FiboLevels),1) != ";")
                       FiboLevels = StringConcatenate(FiboLevels,";");

         //
         //
         //
         //
         //                                   

         int  s      = 0;
         int  i      = StringFind(FiboLevels,";",s);
         string current;
            while (i > 0)
            {
               current = StringSubstr(FiboLevels,s,i-s);
               ArrayResize(levels,ArraySize(levels)+1); levels[ArraySize(levels)-1] =             current+" price %$ ";
               ArrayResize(levelv,ArraySize(levelv)+1); levelv[ArraySize(levelv)-1] = StrToDouble(current);
                           s = i + 1;
                               i = StringFind(FiboLevels,";",s);
            }
         ArrayResize(values,ArraySize(levelv));
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- indicator short name
   IndicatorShortName("Fibodrawer");
//---- initialization done
   return(0);
  }
  
int deinit() {
	ObjectsDeleteAll(0,inpUniqueID+":");
return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer[shift]=res;
        }

     }
     
  	int i=0;
  	int LastZigZag, PreviousZigZag;
   
   int h=0;
   while ( ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) {
   	h++;
   }
   
   LastZigZag=h;
   
   h++;
   while(ExtMapBuffer[h]==0 && ExtMapBuffer2[h]==0) {
   	h++;
   }
   
   PreviousZigZag=h;
   
   if (OldLastZigZag!=LastZigZag || OldPreviousZigZag!=PreviousZigZag) {
   	OldLastZigZag=LastZigZag;
   	OldPreviousZigZag=PreviousZigZag;
   	//ObjectDelete("Fibo");
   	//ObjectCreate("Fibo", OBJ_FIBO, 0, Time[PreviousZigZag], ExtMapBuffer[LastZigZag], Time[LastZigZag], ExtMapBuffer[PreviousZigZag]);
       string fibo = inpUniqueID+":fib:";         
       if( ObjectFind(fibo)==-1 )
         {
            ObjectCreate(fibo, OBJ_FIBO, 0,Time[PreviousZigZag], ExtMapBuffer[LastZigZag], Time[LastZigZag], ExtMapBuffer[PreviousZigZag]);
            ObjectSet(fibo,OBJPROP_COLOR,FiboColor);
            ObjectSet(fibo,OBJPROP_STYLE,FiboStyle);
            ObjectSet(fibo,OBJPROP_WIDTH,FiboWidth);
            ObjectSet(fibo,OBJPROP_LEVELCOLOR,FiboColor);
            ObjectSet(fibo,OBJPROP_LEVELSTYLE,FiboLevelsStyle);
               ObjectSet(fibo,OBJPROP_FIBOLEVELS,ArraySize(levelv));
               for (i=ArraySize(levelv)-1;i>=0;i--)
                  {
                     ObjectSet(fibo,OBJPROP_FIRSTLEVEL+i,levelv[i]/100);
                     ObjectSetFiboDescription(fibo,i,levels[i]);
                  }
          }
          ObjectSet(fibo,OBJPROP_TIME1,Time[PreviousZigZag]);
          ObjectSet(fibo,OBJPROP_TIME2,Time[LastZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE1,ExtMapBuffer[LastZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE2,ExtMapBuffer[PreviousZigZag]);
     }
   return(0);
}
 

  
   