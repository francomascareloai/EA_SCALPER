//+------------------------------------------------------------------+
//|                                              Find Data Holes.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
int hole_count=0;
int hole_size=2;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  
//---- 
   for(int i=0;i<Bars;i++)
   {
      if (iTime(NULL,0,i)-iTime(NULL,0,i+1)>Period()*hole_size*60+30)
      {
         if(TimeDayOfWeek(iTime(NULL,0,i+1))==5 && TimeDayOfWeek(iTime(NULL,0,i))== 1)
         {
               ObjectCreate("Weekend"+i,OBJ_ARROW,0,Time[i], Low[i]);
               ObjectSet("Weekend"+i,OBJPROP_COLOR,Lime);
         }
         else 
         {
            ObjectCreate("Hole"+i,OBJ_ARROW,0,Time[i], Low[i]);
            ObjectSet("Hole"+i,OBJPROP_ARROWCODE,251);
            hole_count=hole_count+1;
         }
      }
   }
   Alert(hole_count+"  holes were found, of size: "+hole_size+" bars.");
//----
   return(0);
  }
//+------------------------------------------------------------------+