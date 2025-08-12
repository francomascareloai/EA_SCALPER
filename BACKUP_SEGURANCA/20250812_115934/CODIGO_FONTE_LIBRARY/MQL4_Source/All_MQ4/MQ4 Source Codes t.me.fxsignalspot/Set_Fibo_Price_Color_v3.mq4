//+------------------------------------------------------------------+
//|                                           Set_Fibo_Price_Any.mq4 |
//|                              Copyright © 2007, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//|                                                                  |
//| 2007.02.16  V1 original by waddhattar                            |
//| 2007.10.31  V2 by pips4life                                      |
//| 2012.09.21  V2 by mtbf40                                         |
//+------------------------------------------------------------------+
//
// This handy indicator adds price info to Fibo Retrracement and Expansion
//   levels on your chart.  For example:  "61.8" becomes  "61.8  234.67"
//   (compact format "2"), or instead, "(61.8) - 234.67" (original format "1").
//
//    Version history for Set_Fibo_Price_Any:
//    2007.02.16 V1 (waddahattar)  Original release.  Downloaded from:
//       http://codebase.mql4.com/1003
//    2007.10.31 V2 (pips4life, http://forexfactory.com):
//    - Added Fib Expansion objects
//    - Added TextStyle property to give user a choice of the 
//        original format, or a slightly more compact description
//    2012.09.21 V3 (mtbf40, http://forexfactory.com):
//    Changed Name to Set_Fibo_Price_Color_v3
//    - Added colored Fibos - setup the Color for each Fibo
//       Original release -> "http://www.forexfactory.com/showthread.php?t=258619" Thanks Taiyakixz
//
// Instructions:
//   Copy this mq4 file into directory:
//      C:\Program Files\_your_MT4_name_here\experts\indicators\
//   Open the file using MetaEditor
//   Change the TextStyle default if desired. See below for description
//   Compile the file.  This will create the .ex4 file in the same directory.
//   Add the indicator to your chart.  All Fibo Retracement or Expansion
//      objects you have, or that you add to the chart later, will 
//      automatically show the price as well as the level
//     (Note: Prices will show after the first new tick).
//   It so happens that when you add Fibo objects to new charts, you *may*
//     not need to add this indicator to every chart, because it essentially
//     creates a new default for the fibo objects.  However, existing Fibo
//     ojects may still have the old format until you specifically add this
//     indicator to that chart (or delete the chart and start over).  Safest
//     would be to just add it to every chart, but this is not always 
//     necessary, and it might waste a bit of CPU to do so.  Experiment for
//     yourself.
//
//   FYI, the "_Any" in the name refers to the fact that you can add
//      any custom fibo level (e.g. 85.4) and this version will still add
//      the price to that level.  A previous version only worked with the
//      standard default fibo levels; hence "_Any" was added to the name. 
//


#property copyright "Copyright Waddah Attar"
#property link      "waddahattar@hotmail.com"
//----
#property indicator_chart_window

extern bool  ColorOn     = true;
extern color FiboColor1  = Green;
extern color FiboColor2  = Maroon;
extern color FiboColor3  = Blue;
extern color FiboColor4  = DarkViolet;
extern color FiboColor5  = HotPink;
extern color FiboColor6  = Red;
extern color FiboColor7  = Orange;
extern color FiboColor8  = Yellow;
extern color FiboColor9  = PaleGreen;
extern color FiboColor10 = White;
extern int TextStyle = 2 ;
//   0 = Plain format.  no prices:  61.8
//   1 = Waddah's original style:  (61.8) - 234.67
//   2 = compact style:   61.8  234.67

string   FiboName[10];
int      MaxFibos = 10;
int      colorCount, fiboCount;
int      colors = 10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   Comment("Set_Fibo_Price_Color_v3");

   if (ColorOn)
   {
      int i, objTotal;
      string objName;

      for( i = 0; i < MaxFibos; i++ )
      {
        FiboName[i] = "";
      }

      fiboCount = 0;
      objTotal = ObjectsTotal();
      if( objTotal > 0 )
      {
        for( i = 0; i < objTotal; i++ )
        {
          objName = ObjectName(i);
          if( ObjectType(objName) == OBJ_FIBO )
          {
            if( fiboCount < MaxFibos ) FiboName[fiboCount] = objName;
            fiboCount++;
          }
        }
      }

      colorCount = MathMod( fiboCount, colors ) + 1;
   }

   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
   int objTotal = ObjectsTotal();
   int i, j;
   string objName;
   for(i = 0; i < objTotal; i++)
   {
      objName = ObjectName(i);
      if(ObjectType(objName) == OBJ_FIBO)
      {
         for( j=0 ; j<32 ; j++ )
         { 
            if(GetLastError() != 0) break;
            ObjectSetFiboDescription(objName, j, DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL + j)*100, 1));
         }
      }
      else if(ObjectType(objName) == OBJ_EXPANSION)
      {
         for( j=0 ; j<32 ; j++ )
         {
            if(GetLastError() != 0) 
            break;
            ObjectSetFiboDescription(objName, j, "FE " + DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL + j)*100, 1));
         }
      } 
   }
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int objTotal = ObjectsTotal();
   string objName,text;
   int i, j;
   bool objFound;

   // Check deletion
   if (ColorOn)
   {
      for( i = 0; i < MaxFibos; i++ )
      {
         if( StringLen( FiboName[i] ) > 0 )
         {
            objFound = false;
            if( objTotal > 0 )
            {
               for( j = 0; j < objTotal; j++ )
               {
                  objName = ObjectName(j);
                  if( StringFind( objName, FiboName[i], 0 ) != -1 ) objFound = true;
               }
            }
            if( objFound == false ) FiboDeleted(i);
         }
      }
   }

   for(i = 0; i < objTotal; i++)
   {
      objName = ObjectName(i);
      if(ObjectType(objName) == OBJ_FIBO)
      {
         //section Change Color
         if (ColorOn)
         {
            objFound = false;
            for( j = 0; j < MaxFibos; j++ )
            {
              if( StringFind( FiboName[j], objName , 0 ) != -1 ) objFound = true;
            }
            if( objFound == false ) FiboCreated(objName);
         }

         //section set Price
         for(j = 0; j < 32; j++)
         {
            if(GetLastError() != 0) break;
            switch (TextStyle)
            {
               case 2 :
                  // Style 2 example is:  61.8  234.67
                  ObjectSetFiboDescription(objName, j, DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1) + "  %$");
                  break;
               case 0 :
                  // Style 0 example is:  61.8
                  ObjectSetFiboDescription(objName, j, DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1));
                  break;
                  default:
                  // default, or style 1.  Example:  (61.8) - 234.67
                  ObjectSetFiboDescription(objName, j, "(" + DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1) + ")" + " - %$");
            }
         }
      } else if(ObjectType(objName) == OBJ_EXPANSION)
      {
         for(j = 0; j < 32; j++)
         {
            if(GetLastError() != 0) break;
            switch (TextStyle)
            {
               case 2 :
                  // Style 2 example is:  FE 61.8  234.67
                  ObjectSetFiboDescription(objName, j, "FE " + DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1) + "  %$");
                  break;
               case 0 :
                  // Style 0 example is:  FE 61.8
                  ObjectSetFiboDescription(objName, j, "FE " + DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1));
                  break;
                  default:
                  // default, or style 1.  Example:  FE (61.8) - 234.67
                  ObjectSetFiboDescription(objName, j, "FE (" + DoubleToStr(ObjectGet(objName,OBJPROP_FIRSTLEVEL+j)*100,1) + ")" + " - %$");
            }
         }
      }
   }
   return(0);
}

void FiboDeleted( int fiboNo )
  {
   int i;
  
   if( fiboNo < MaxFibos )
   {
     if( fiboNo == MaxFibos - 1 )
     {
       FiboName[fiboNo] = "";
     }
     else
     {
       for( i = fiboNo; i < MaxFibos-2; i++ )
         FiboName[i] = FiboName[i+1];
       FiboName[MaxFibos-1] = "";
     }
   }
   fiboCount--;
  }

void FiboCreated(string objName)
  {
   int i;
   
   if( fiboCount < MaxFibos - 1 )
   {
     fiboCount++;
     FiboName[fiboCount] = objName;
     if( colorCount >= colors ) colorCount = 1;
     else colorCount++;
     switch( colorCount )
     {
       case 1:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor1 );
        break;
       case 2:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor2 );
         break;
       case 3:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor3 );
         break;
       case 4:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor4 );
         break;
       case 5:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor5 );
         break;
       case 6:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor6 );
         break;
       case 7:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor7 );
         break;
       case 8:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor8 );
         break;
       case 9:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor9 );
         break;
       case 10:
         ObjectSet( objName, OBJPROP_LEVELCOLOR, FiboColor10 );
         break;
       default:
         break;
     }
   }
  }

