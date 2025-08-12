//+------------------------------------------------------------------+
//|                                                      Extremums.mq4 |
//+------------------------------------------------------------------+
#property copyright "Frostow"
#property link      "https://www.mql5.com/ru/users/frostow"
#property version   "1.20"
#property strict
#property script_show_inputs
//--- input parameters
input bool up=true;//Upper lines
input bool down=true;//Bottom lines
input bool H=true;//Draw hour's lines
input int h_b= 24;//Bars on hour TimeFrame
input bool D = true;//Draw day's lines
input int d_b= 5;//Bars on day TimeFrame
input bool W = true;//Draw week's lines
input int w_b= 4;//Bars on week TimeFrame
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

//Checking input data
   if(h_b<1 || (!up && !down) || d_b<1 || w_b<1)
     {
      Alert("Incorrect input");
      return;
     }

//It's the main part of program that makes everything, consicts of 3 functions
   if(W) program(w_b,10080,up,down,Black,STYLE_SOLID,3);//Week
   if(D) program(d_b,1440,up,down,Black,STYLE_SOLID,2);//Day
   if(H) program(h_b,60,up,down,Black,STYLE_DASH,1);//Hour TimeFrame

  }
//+------------------------------------------------------------------+     }

//Finding extremums and drawning lines
int program(int b,// Period in bars
            int p,//TimeFrame 
            bool up1,//Draw upper line?
            bool down1,//Bottom one?
            color colour,//Color of lines
            int style,//Style that would be used to draw lines
            int width)//Their width
  {

   long current_chart_id=ChartID();//Our chart's ID
   double high=iHigh(NULL,p,0),//Starting high price
   high1,//We well use it later to check high price
   low=iLow(NULL,p,0),//Starting low price
   low1;//The same like high1
   datetime dt_low=iTime(NULL,0,0),//Current date yet
   dt_high=iTime(NULL,0,0);//Current date yet

                           //It will return high, low in b hours/days/weeks and their dates
   for(int i=0;i<b;i++)
     {
      high1=iHigh(NULL,p,i);//Current high price
      low1=iLow(NULL,p,i);//Current low price

                          //Checking for new high and low prices
      if(high1>high)
        {
         high=high1;
         dt_high=iTime(NULL,p,i);
        }
      if(low1<low)
        {
         low=low1;
         dt_low=iTime(NULL,p,i);
        }
     }

//Beggining of drawing
   string obj_name_1 = "Highest in "+IntegerToString(b,1)+" bars on "+opr(p)+" TF";
   string obj_name_2 = "Lowest in "+IntegerToString(b,1)+" bars on "+opr(p)+" TF";
   if(up1)//Draw upper line?
     {
      if (ObjectFind(obj_name_1) >= 0) ObjectDelete(obj_name_1);
      ObjectCreate(obj_name_1,OBJ_TREND,0,dt_high,high,TimeCurrent(),high);
      ObjectSetInteger(current_chart_id,obj_name_1,OBJPROP_COLOR,Aqua);
      ObjectSetInteger(current_chart_id,obj_name_1,OBJPROP_STYLE,style);
      ObjectSetInteger(current_chart_id,obj_name_1,OBJPROP_WIDTH,width);
      ObjectSetInteger(current_chart_id,obj_name_1,OBJPROP_RAY_RIGHT,true);
      ObjectSetString(current_chart_id,obj_name_1,OBJPROP_TEXT,"f_e_s");

     }

   if(down1)//Draw bottom line?
     {
      if (ObjectFind(obj_name_2) >= 0) ObjectDelete(obj_name_2);
      ObjectCreate(obj_name_2,OBJ_TREND,0,dt_low,low,TimeCurrent(),low);
      ObjectSetInteger(current_chart_id,obj_name_2,OBJPROP_COLOR,Crimson);
      ObjectSetInteger(current_chart_id,obj_name_2,OBJPROP_STYLE,style);
      ObjectSetInteger(current_chart_id,obj_name_2,OBJPROP_WIDTH,width);
      ObjectSetInteger(current_chart_id,obj_name_2,OBJPROP_RAY_RIGHT,true);
      ObjectSetString(current_chart_id,obj_name_2,OBJPROP_TEXT,"f_e_s");

     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//It returns string variable that consists of number if hours of days of weeks and the character that shows them
string opr(int p)
  {
   string answer="";
   if(p<60) answer=IntegerToString(p)+" min";
   if(p<1440 && p>=60) answer=IntegerToString(p/60)+" h";
   if(p>=1440 && p<7200) answer=IntegerToString(p/1440)+" d";
   if(p>=7200) answer=IntegerToString(p/7200)+" w";
   return answer;
  }
//+------------------------------------------------------------------+
