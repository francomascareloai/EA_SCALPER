
#property indicator_chart_window
#import "stdlib.ex4"
int RGB(int red_value,int green_value,int blue_value);
double top, bottom;
datetime left;
int right_bound;
datetime right;
extern string topcol  ="125,000,000";
extern string bottomcol ="125,000,255";
int r,g,b;
extern int steps =100;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   //Print(colour);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int x=1;x<=steps;x++)
   {
      ObjectDelete("Padding_rect"+x);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   top =  WindowPriceMax();
   bottom = WindowPriceMin(); 
   left = Time[WindowFirstVisibleBar()];
   right_bound=WindowFirstVisibleBar()-WindowBarsPerChart();
   if(right_bound<0) right_bound=0;
   right=Time[right_bound]+Period()*60;
   for(int x=1;x<=steps;x++)
   {
      if(ObjectFind("Padding_rect"+x) ==-1) ObjectCreate("Padding_rect"+x,OBJ_RECTANGLE,0,left,top-((top-bottom)/steps)*(x-1),right,top-((top-bottom)/steps)*(x));
      ObjectSet("Padding_rect"+x, OBJPROP_TIME1, left);
      ObjectSet("Padding_rect"+x, OBJPROP_TIME2, right);
      ObjectSet("Padding_rect"+x, OBJPROP_PRICE1, top-((top-bottom)/steps)*(x-1));
      ObjectSet("Padding_rect"+x, OBJPROP_PRICE2, top-((top-bottom)/steps)*(x));
      ObjectSet("Padding_rect"+x,OBJPROP_BACK,true);
      
      ObjectSet("Padding_rect"+x,OBJPROP_COLOR, ss2rgb(topcol, bottomcol,steps, x));//  RGB((128/steps*x),(128/steps*x),(255/steps*x)));
   }
      WindowRedraw();

//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int ss2rgb(string colour1, string colour2, int step, int index)
{
   
   int r1 = StrToInteger(StringSubstr(colour1, 0,3));
   int g1 = StrToInteger(StringSubstr(colour1, 4,3));
   int b1 = StrToInteger(StringSubstr(colour1, 8,3));
   
   int r2 = StrToInteger(StringSubstr(colour2, 0,3));
   int g2 = StrToInteger(StringSubstr(colour2, 4,3));
   int b2 = StrToInteger(StringSubstr(colour2, 8,3));
   
   if(r1>r2)
   {
      r = r1+((r2-r1)/step*index);
   }
   if(r1<r2)
   {
      r = r1-((r1-r2)/step*index);
   }
   
   if(g1>g2)
   {
      g = g1+((g2-g1)/step*index);
   }
   if(g1<g2)
   {
      g = g1-((g1-g2)/step*index);
   }
   
   if(b1>b2)
   {
      b = b1+((b2-b1)/step*index);
   }
   if(b1<b2)
   {
      b = b1-((b1-b2)/step*index);
   }
   
   g<<=4;
   b<<=15;
   return(r+g+b);
   
      
}
// ------------------------------------------------------------------------------------------ //
//                                     E N D   P R O G R A M                                  //
// ------------------------------------------------------------------------------------------ //
/*                                                                                                                 
                              ud$$$**$$$$$$$bc.                          
                          u@**"        4$$$$$$$Nu                       
                        J                ""#$$$$$$r                     
                       @                       $$$$b                    
                     .F                        ^*3$$$                   
                    :% 4                         J$$$N                  
                    $  :F                       :$$$$$                  
                   4F  9                       J$$$$$$$                 
                   4$   k             4$$$$bed$$$$$$$$$                 
                   $$r  'F            $$$$$$$$$$$$$$$$$r                
                   $$$   b.           $$$$$$$$$$$$$$$$$N                
                   $$$$$k 3eeed$$b    XARD777."$$$$$$$$$                
    .@$**N.        $$$$$" $$$$$$F'L $$$$$$$$$$$  $$$$$$$                
    :$$L  'L       $$$$$ 4$$$$$$  * $$$$$$$$$$F  $$$$$$F         edNc   
   @$$$$N  ^k      $$$$$  3$$$$*%   $F4$$$$$$$   $$$$$"        d"  z$N  
   $$$$$$   ^k     '$$$"   #$$$F   .$  $$$$$c.u@$$$          J"  @$$$$r 
   $$$$$$$b   *u    ^$L            $$  $$$$$$$$$$$$u@       $$  d$$$$$$ 
    ^$$$$$$.    "NL   "N. z@*     $$$  $$$$$$$$$$$$$P      $P  d$$$$$$$ 
       ^"*$$$$b   '*L   9$E      4$$$  d$$$$$$$$$$$"     d*   J$$$$$r   
            ^$$$$u  '$.  $$$L     "#" d$$$$$$".@$$    .@$"  z$$$$*"     
              ^$$$$. ^$N.3$$$       4u$$$$$$$ 4$$$  u$*" z$$$"          
                '*$$$$$$$$ *$b      J$$$$$$$b u$$P $"  d$$P             
                   #$$$$$$ 4$ 3*$"$*$ $"$'c@@$$$$ .u@$$$P               
                     "$$$$  ""F~$ $uNr$$$^&J$$$$F $$$$#                 
                       "$$    "$$$bd$.TZUMAN$$$$F $$"                   
                         ?k         ?$$$$$$$$$$$F'*                     
                          9$$bL     z$$$$$$$$$$$F                       
                           $$$$    $$$$$$$$$$$$$                        
                            '#$$c  '$$$$$$$$$"                          
                             .@"#$$$$$$$$$$$$b                          
                           z*      $$$$$$$$$$$$N.                       
                         e"      z$$"  #$$$k  '*$$.                     
                     .u*      u@$P"      '#$$c   "$$c                   
              u@$*"""       d$$"            "$$$u  ^*$$b.               
            :$F           J$P"                ^$$$c   '"$$$$$$bL        
           d$$  ..      @$#                      #$$b         '#$       
           9$$$$$$b   4$$                          ^$$k         '$      
            "$$6""$b u$$                             '$    d$$$$$P      
              '$F $$$$$"                              ^b  ^$$$$b$       
               '$W$$$$"                                'b@$$$$"         
                                                        ^$$$*  
*/     

