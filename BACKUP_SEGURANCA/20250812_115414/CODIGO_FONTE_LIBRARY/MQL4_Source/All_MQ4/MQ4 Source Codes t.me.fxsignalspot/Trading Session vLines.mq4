//+------------------------------------------------------------------+
//|                                       Trading Session vLines.mq4 |
//|                  Copyright © 2006, Taylor Stockwell/Jason Rivera |
//|                   http://www.jasonerivera.com/stockwet@yahoo.com |
//+------------------------------------------------------------------+


// Version 2: Updated to fix daylight savings time and UK
// summer time bugs.

#property copyright "Copyright © 2006, Taylor Stockwell/Jason Rivera"
#property indicator_chart_window

extern int No_Bars_To_Calculate = 1000;
extern int UK_Open=8;
extern int UK_Close=17;
extern int BeginDay = 0;
extern int US_Start = 13;

bool uk_dst = false;
bool us_dst = false;

string objNames[0];
int array_count = 0;
int TimeStart = 0;
int TimeFinish=0;
int USStart=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //resize the index of the Array to the expected number of objects to be created
   ArrayResize(objNames, No_Bars_To_Calculate);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  int items=ArrayRange(objNames,0)-1; Print(items, " objects to delete");
  int i = 0;
//---- 
   //make sure to delete all objects created when unloading this indicator
   //this routine cycles thru the stored list of unique vertical line names 
   //and deletes the objects with that name
   for (i=items; i>=0;i--)
   {
      //all valid object names will have at least one character, so skip empty strings
      if(objNames[i] != "")
      {
         Print("Deleted: ",objNames[i]);
         ObjectDelete(objNames[i]);
      }      
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int pos = Bars-1;
   int i = 0;

      

//---- 
   if(Bars - counted_bars == 1) return(0);
   
   pos = (No_Bars_To_Calculate);
   
   //initialize all elements of the array to empty string
   for (i=ArrayRange(objNames,0); i>=0;i--)
   {
      objNames[i] = "";
   }
      
   while(pos>=0)
   {            
      //we will create a vertical line everyday at 9pm server time or 21:00 hours 
      //for as many bars back as we wish to calculate, default is set at 100 bars (about 4 bars on a 1 hour chart)
      //string min = TimeToStr(TimeMinute(Time[pos]));
      //string hour = TimeToStr(TimeHour(Time[pos]));
      //Comment(min);
      
      //Adjust for UK summer Time
      // 2006 UK Summer Times: 3/26 - 10/29 (85, 298)
      // 2005 UK DST Times: 3/27 - 10/30 (86, 299)


      switch(TimeYear(Time[pos]))
         {

         case 2006:
            if(TimeDayOfYear(Time[pos])>85 && TimeDayOfYear(Time[pos])<298) 
            {
            uk_dst=true;
            Comment("UK Summer Time is active");
            } else {
            uk_dst=false;
            } 
            break;
         case 2005:
            if(TimeDayOfYear(Time[pos])>86 && TimeDayOfYear(Time[pos])<299) 
            {
            uk_dst=true;
            } else {
            uk_dst=false;
            }
            break;
         default:
            uk_dst=false;
            break;
          }      
 
    
      if(uk_dst==true)
         {
            TimeStart = UK_Open - 1;
            TimeFinish = UK_Close-1;
         } 
         else 
         {
            TimeStart = UK_Open;
            TimeFinish = UK_Close;
         }
              
  
      if((TimeHour(Time[pos]) == TimeStart && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, DodgerBlue);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }
         else 
            {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
            } 
         }
         
      if((TimeHour(Time[pos]) == TimeFinish && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Red);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
 //     
      if((TimeHour(Time[pos]) == BeginDay && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DASH);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Gainsboro);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
      
      
//Adjust for US Daylight Savings Time
// 2006 US DST Times: 4/2 - 10/29 (91, 298)      
// 2005 US DST Times: 4/3 - 10/30 (92,299)
      switch(TimeYear(Time[pos]))
         {
         case 2006:
            if(TimeDayOfYear(Time[pos])>91 && TimeDayOfYear(Time[pos])<298) 
            {
            us_dst=true;
            Comment("US DST is active");
            } else {
            us_dst=false;
            } 
            break;

         case 2005:
            if(TimeDayOfYear(Time[pos])>92 && TimeDayOfYear(Time[pos])<299) 
            {
            us_dst=true;
            } else {
            us_dst=false;
            }
            break;

         default:
            us_dst=false;
            break;
          }        
             
      if(us_dst==true)
         {
            USStart = US_Start - 1;
         } 
         else 
         {
            USStart = US_Start;
         }    
         

      if((TimeHour(Time[pos]) == USStart && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Gainsboro);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
            
      pos--;
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+