//+------------------------------------------------------------------+
//|                                                    Gann_SQ_9.mq4 |
//|                                                       idea Pasha |
//|                                              ZigZag_new_nen4.mq4 |                                                       
//|                                                              nen |
//|                                                        DimDimych |                                                                  
//|                                            http://open-forex.org |
//+------------------------------------------------------------------+
#property copyright "DimDimych"
#property link      "dm34@mail.ru"

#property indicator_chart_window
#property indicator_buffers  1
#property indicator_color1 WhiteSmoke

#property indicator_width1 0
#property indicator_style1 2
//---- 
extern double  angle_up        = 22.5;
extern double  angle_dn        = 22.5;
extern int     Width           = 0;
extern int     Style           = 2;
extern int     kol_lev         = 8;
extern color   ResistanceColor = Brown;
extern color   SupportColor    = Green;
extern color   Level_0         = Gray;
extern bool    lev_V           = true;
extern color   Level_V         = Gray;
extern int     Complect        = 0;
color ����_������;

extern int ExtDepth=21;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

//---- 
//---- 
double ZigZagBuffer[];
int timeFirstBar=0;
int flag;
bool work=true;
double vel_prev;
//+------------------------------------------------------------------+
//| ZigZag initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   SetIndexBuffer(0,ZigZagBuffer); 
   SetIndexStyle(0,DRAW_SECTION,2);
   SetIndexEmptyValue(0,0.0);

   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//| deinit                                       |
//+------------------------------------------------------------------+  
int deinit()
  {
//----
 ObjDel();
 Comment("");
//----
   return(0);
  }  
//+------------------------------------------------------------------+
//|  ZigZag iteration function                                       |
//+------------------------------------------------------------------+
int start()
  {
   //----+ �������� ���������� ����� �� ������������� ��� ����������� ������� ����������
   if (Bars-1<ExtDepth)return(0);
   //----+ �������� ����� ���������� ������ ��� ��������� ���������� ������ �� �������������� �����
   static int time2,time3,time4;  
   //----+ �������� ���������� � ��������� ������ ��� ��������� ���������� ������ �� �������������� �����
   static  double ZigZag2,ZigZag3,ZigZag4;
   //----+ �������� ����� ���������� ��� ��������� ���������� ������ �� �������������� ����� � ��������� ��� ������������ �����
   int MaxBar,limit,supr2_bar,supr3_bar,supr4_bar,counted_bars=IndicatorCounted();
   //---- �������� �� ��������� ������
   if (counted_bars<0)return(-1);
   //---- ��������� ������������ ��� ������ ���� ����������
   if (counted_bars>0) counted_bars--;
   //----+ �������� ����������    
   int    index, shift, back,lasthighpos,lastlowpos;
   double val,res,TempBuffer[1];
   double curlow,curhigh,lasthigh,lastlow;
 
   int    metka=0; // =0 - �� ������� �������� ZZ. =1 - ���� ����� ����������. =2 - ���� ����� ���������.

   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� ����� �������� ���� �����
   MaxBar=Bars-ExtDepth; 
   //---- ����������� ������ ����������  ���� � �����, ������� � �������� ����� ������������  �������� ����� �����
   if (counted_bars==0 || Bars-counted_bars>2)
     {
      limit=MaxBar;
     }
   else 
     {
      //----
      supr2_bar=iBarShift(NULL,0,time2,TRUE);
      supr3_bar=iBarShift(NULL,0,time3,TRUE);
      supr4_bar=iBarShift(NULL,0,time4,TRUE);
      //----
      limit=supr3_bar;      
      if ((supr2_bar<0)||(supr3_bar<0)||(supr4_bar<0))
         {
          limit=MaxBar;
         }
     }
     
   //---- ������������� ����
   if (limit>=MaxBar || timeFirstBar!=Time[Bars-1]) 
     {
      timeFirstBar=Time[Bars-1];
      limit=MaxBar; 
     } 
   //----  
   //---- ��������� ������� ���������� ������

if (limit==MaxBar) ArrayResize(TempBuffer,Bars); else  ArrayResize(TempBuffer,limit+ExtBackstep+1);
     
   //----+-------------------------------------------------+ 
   
   //----+ ������ ������� �������� �����
   for(shift=limit; shift>=0; shift--)
     {
      //--- Low
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
               res=ZigZagBuffer[shift+back];
               if((res!=0)&&(res>val)) ZigZagBuffer[shift+back]=0.0; 
              }
           }
        }
      if (Low[shift]==val)
        {
         ZigZagBuffer[shift]=val; 
         //if (ExtLabel==1) la[shift]=val;
        }
      else ZigZagBuffer[shift]=0.0;


      //--- High
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
               res=TempBuffer[shift+back]; 
               if((res!=0)&&(res<val)) TempBuffer[shift+back]=0.0; 
              } 
           }
        }
      if (High[shift]==val)
        {
         TempBuffer[shift]=val; 
         //if (ExtLabel==1) ha[shift]=val;
        }
      else TempBuffer[shift]=0.0;
     }
   //----+ ����� ������� �������� ����� 
      
   // final cutting 
      lasthigh=-1; lasthighpos=-1;
      lastlow= -1; lastlowpos= -1;
   //----+-------------------------------------------------+
   
   //----+ ������ ������� �������� �����

   for(shift=limit; shift>=0; shift--)
     {
      curlow=ZigZagBuffer[shift];
      curhigh=TempBuffer[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) TempBuffer[lasthighpos]=0;
            else TempBuffer[shift]=0;
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
            if(lastlow>curlow) ZigZagBuffer[lastlowpos]=0;
            else ZigZagBuffer[shift]=0;
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
   //----+ ����� ������� �������� �����
     
   //----+-------------------------------------------------+
   
   //----+ ������ �������� �����
   for(shift=limit; shift>=0; shift--)
     {
       res=TempBuffer[shift];
       if(res!=0.0) ZigZagBuffer[shift]=res;
     }
     //----+ ����� �������� �����
     
   // �������� ������� ����
   int i=0,j=0;
   res=0;
   for (shift=0;i<3;shift++)
     {
      if (ZigZagBuffer[shift]>0)
        {
         i++;
         if (i==1 && ZigZagBuffer[shift]==High[shift])
           {
            j=shift;
            res=ZigZagBuffer[shift];
           }
         if (i==2 && res>0 && ZigZagBuffer[shift]==High[shift])
           {
            if (ZigZagBuffer[shift]>=ZigZagBuffer[j]) ZigZagBuffer[j]=0; else ZigZagBuffer[shift]=0;
            res=0;
            i=0;
            j=0;
            shift=0;
           }
        }
     }

   //+--- �������������� �������� ������������� �������, ������� ����� ���� ������� 
   if (limit<MaxBar)
     {
      ZigZagBuffer[supr2_bar]=ZigZag2; 
      ZigZagBuffer[supr3_bar]=ZigZag3; 
      ZigZagBuffer[supr4_bar]=ZigZag4; 
      for(int qqq=supr4_bar-1; qqq>supr3_bar; qqq--)ZigZagBuffer[qqq]=0; 
      for(int ggg=supr3_bar-1; ggg>supr2_bar; ggg--)ZigZagBuffer[ggg]=0;
     }
   //+---+============================================+
  
   //+--- ����������� ����������� ������ 
   double vel1, vel2, vel3, vel4;
   int bar1, bar2, bar3, bar4;
   int count;
   if (limit==MaxBar)supr4_bar=MaxBar;
   for(int bar=supr4_bar; bar>=0; bar--)
    {
     if (ZigZagBuffer[bar]!=0)
      {
       count++;
       vel4=vel3;bar4=bar3;
       vel3=vel2;bar3=bar2;
       vel2=vel1;bar2=bar1;
       vel1=ZigZagBuffer[bar];bar1=bar;
       ObjDel();
       if (count<3)continue; 
       if ((vel3<vel2)&&(vel2<vel1)){ZigZagBuffer[bar2]=0;bar=bar3+1;}
       if ((vel3>vel2)&&(vel2>vel1)){ZigZagBuffer[bar2]=0;bar=bar3+1;}
       if ((vel2==vel1)&&(vel1!=0 )){ZigZagBuffer[bar1]=0;bar=bar3+1;}
     }
    } 
   //+--- ����������� ������� ��� ��������� ��������� ������� � �������� ���������� � ���� ������ 
   time2=Time[bar2];
   time3=Time[bar3];
   time4=Time[bar4];
   ZigZag2=vel2;  
   ZigZag3=vel3; 
   ZigZag4=vel4; 
 
            
if(bar1>=2) 
{
  if(Low[bar1]==vel1)
  {
  flag=1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar1+"_"+Complect+"_"+i,vel1,bar1,bar1,0,angle_up*i, flag);
   }
  }
  else
  {
  flag=-1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar1+"_"+Complect+"_"+i,vel1,bar1,bar1,0,angle_dn*i, flag);
   }
  }
  PlotLineM("_lev "+bar1+"_"+Complect+"_",vel1,bar1,bar1,0,flag);
} 
//+---
if(Low[bar2]==vel2)
{
flag=1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar2+"_"+Complect+"_"+i,vel2,bar2,bar1,1,angle_up*i, flag);
   }
}
else
{
flag=-1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar2+"_"+Complect+"_"+i,vel2,bar2,bar1,1,angle_dn*i, flag);
   }
}
  PlotLineM("_lev "+bar2+"_"+Complect+"_",vel2,bar2,bar1,1,flag);
//+---
if(Low[bar3]==vel3)
{
flag=1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar3+"_"+Complect+"_"+i,vel3,bar3,bar2,1,angle_up*i, flag);
   }
}
else
{
flag=-1;
   for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar3+"_"+Complect+"_"+i,vel3,bar3,bar2,1,angle_dn*i, flag);
   }
}
  PlotLineM("_lev "+bar3+"_"+Complect+"_",vel3,bar3,bar2,1,flag);
//+---
if(Low[bar4]==vel4)
{
flag=1;
  for(i = 1; i <= kol_lev; i++ )
  {
   PlotLine("_lev "+bar4+"_"+Complect+"_"+i,vel4,bar4,bar3,1,angle_up*i, flag);
  }
}
else
{
flag=-1;
  for(i = 1; i <= kol_lev; i++ )
   {
   PlotLine("_lev "+bar4+"_"+Complect+"_"+i,vel4,bar4,bar3,1,angle_dn*i, flag);
   }
}   
  PlotLineM("_lev "+bar4+"_"+Complect+"_",vel4,bar4,bar3,1,flag);
return(0);
}
 //---+ +---------------------------------------------------------------------+
void PlotLineM(string name,double Price1,int Date1,int Date2,int lev0,int ����_����)
{
int D2;
double P1;
       
     if(lev0==1)
      D2=Time[Date2];
     else
      D2=Time[0]+50*Period()*60;
           
     ObjectDelete(name+" 0");
     ObjectCreate(name+" 0",OBJ_TREND,0,Time[Date1],Price1,D2,Price1);   
     ObjectSet(name+" 0",OBJPROP_COLOR,Level_0);
     ObjectSet(name+" 0",OBJPROP_STYLE,0);
     ObjectSet(name+" 0",OBJPROP_WIDTH,1);
     ObjectSet(name+" 0",OBJPROP_RAY,false);
 //---+ 
     if(����_����==1)
      P1=Price1-2*Point;
     else if(����_����==-1)
      P1=Price1+4*Point;
     ObjectDelete(name+" 0txt");
     ObjectCreate(name+" 0txt", OBJ_TEXT, 0, Time[Date1], P1);
     ObjectSetText(name+" 0txt", DoubleToStr(Price1,Digits), 8, "Tahoma",Level_0); 
//---+     
   if(lev_V)
    {
     ObjectDelete(name+" V");
     ObjectCreate(name+" V",OBJ_VLINE,0,Time[Date1],0);   
     ObjectSet(name+" V",OBJPROP_COLOR,Level_V);
     ObjectSet(name+" V",OBJPROP_STYLE,2);
     ObjectSet(name+" V",OBJPROP_WIDTH,0);
     ObjectSet(name+" V",OBJPROP_BACK,true);
    }  
 //---+ 


}
 //---+ +---------------------------------------------------------------------+ 
void PlotLine(string name,double Price1,int Date1,int Date2,int lev0,double gr,int ����_����)
{
double level,points;
int D2,nBar;
if(Digits==5 || Digits==3)
points=Point*10;
else
points=Point;

       if(����_����==1)
       {
       level=MathSqrt(Price1/points)+gr/180;
       level=MathPow(level,2)*points;
       ����_������=SupportColor;
       }
       else
       if(����_����==-1)
       {
       level=MathSqrt(Price1/points)-gr/180;
       level=MathPow(level,2)*points;
       ����_������=ResistanceColor;
       } 
       if(lev0==1)
       D2=Time[Date2];
       else
       D2=Time[0]+50*Period()*60;      

     ObjectDelete(name);
     ObjectCreate(name,OBJ_TREND,0,Time[Date1],level,D2,level);   
     ObjectSet(name,OBJPROP_COLOR,����_������);
     ObjectSet(name,OBJPROP_STYLE,Style);
     ObjectSet(name,OBJPROP_WIDTH,Width);
     ObjectSet(name,OBJPROP_RAY,false);

//---  
   ObjectDelete(name+" txt");
   if(lev0==1)
   {
   nBar=Date1-8;
   ObjectCreate(name+" txt", OBJ_TEXT, 0, Time[nBar], level);
   }
   else
   {
   ObjectCreate(name+" txt", OBJ_TEXT, 0, Time[0]+8*Period()*60, level);
   }
   ObjectSetText(name+" txt", DoubleToStr(gr,1)+"� "+DoubleToStr(level,Digits), 8, "Tahoma",����_������); 
//---     
}
//---------------------------------------------------------
void ObjDel()
{
	for ( int i = ObjectsTotal() - 1; i >= 0; i -- )
	{
		if ( StringFind( ObjectName(i), "_", 0 ) == 0 )
		{
			ObjectDelete( ObjectName(i) );
		}
	}   
} 
 