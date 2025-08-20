#property indicator_chart_window 
#property indicator_buffers 2 
#property indicator_color1 Red 
#property indicator_color2 Blue
#property indicator_width1 3
#property indicator_width2 3
//+------------------------------------------------------------------+ 
extern int       NarrowRange7=7; 
extern int       NarrowRange4=4; 
//+------------------------------------------------------------------+ 
double ExtMapBuffer1[]; 
double ExtMapBuffer2[];
//+------------------------------------------------------------------+ 
int init(){ 
  SetIndexStyle(0,DRAW_ARROW); 
  SetIndexArrow(0,135); 
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexEmptyValue(0,0.0); 
  SetIndexStyle(1,DRAW_ARROW); 
  SetIndexArrow(1,132); 
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexEmptyValue(1,0.0); 
  return(0); 
} 
//+------------------------------------------------------------------+ 
int start(){ 
  int i,j,pos; 
  for(i=Bars-IndicatorCounted()-1;i>=0;i--){
    if ((High[i]<High[i+1])&&(Low[i]>Low[i+1])){ 
       for(j=i+1;j<i+NarrowRange7;j++) 
    pos=i; 
         if ((High[j]-Low[j])<(High[i]-Low[i])) 
          pos=j; 
      if (pos==i) 
        ExtMapBuffer1[i] = High[i] + (High[i] - Low[i])/2; 
    }    
  } 
{ 
  int y,z,posx; 
  for(y=Bars-IndicatorCounted()-1;y>=0;y--){ 
    if ((High[y]<High[y+1])&&(Low[y]>Low[y+1])){ 
      posx=y; 
      for(z=y+1;z<y+NarrowRange4;z++) 
        if ((High[z]-Low[z])<(High[y]-Low[y])) 
          posx=z; 
      if (posx==y) 
        ExtMapBuffer2[y] = 4*Point+( High[y] + (High[y] - Low[y])/2); 
    }    
  } 
  return(0); 
} 
}
//+------------------------------------------------------------------+