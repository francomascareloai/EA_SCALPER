//+------------------------------------------------------------------+
//|                                                          MPD.mq4 |
//+------------------------------------------------------------------+
#property copyright "Me"
#property indicator_chart_window

extern int TextSize = 7, Corner = 0;
extern color TextCol = clrBlack, TextCol2 = clrRed, TextCol3 = clrLime;
extern int VTab = 16,
           Htb1 = 0,
           Htb2 = 50,
           Htb3 = 90,
           Htb4 = 130,
           Htb5 = 170,
           Htb6 = 210,
           Htb7 = 250,
           Htb8 = 290,
           Htb9 = 330;

int HTab[9], PrdVal[7] = {5, 15, 30, 60, 240, 1440, 10080};

//+------------------------------------------------------------------+
int init()
 { 
   HTab[0] = Htb1;
   HTab[1] = Htb2;
   HTab[2] = Htb3;
   HTab[3] = Htb4;
   HTab[4] = Htb5;
   HTab[5] = Htb6;
   HTab[6] = Htb7;
   HTab[7] = Htb8;
   HTab[8] = Htb9;
   CreateLabels();
   
  return(0); 
 }
 
//-----------------------------------------------+ 
int start()
 {
   double Pcnt[7];
   double Tot = 0, TotCnt = 0;
   int Timer = 0;
    
   for(int n = 1; n < 8; n++)
     {
      if(iClose(NULL, PrdVal[n-1], 0) == iOpen(NULL, PrdVal[n-1], 0))
        {
          Pcnt[n-1] = 0;
          ObjectSetText("1.Data"+n+0, DoubleToStr(0, 0), TextSize, "Arial", TextCol3);
          ObjectSetText("1.Data"+n+1, DoubleToStr(0, 0), TextSize, "Arial", TextCol3);
        }
      else if(iClose(NULL, PrdVal[n-1], 0) > iOpen(NULL, PrdVal[n-1], 0))
        {
          Pcnt[n-1] =  (iClose(NULL, PrdVal[n-1], 0) - iOpen(NULL, PrdVal[n-1], 0)) / 
                 (iHigh(NULL, PrdVal[n-1], 0) - iLow(NULL, PrdVal[n-1], 0)) * 100;
          ObjectSetText("1.Data"+n+0, DoubleToStr(Pcnt[n-1], 0), TextSize, "Arial", TextCol3);
          ObjectSetText("1.Data"+n+1, DoubleToStr(100 - Pcnt[n-1], 0), TextSize, "Arial", TextCol2);
          Tot += Pcnt[n-1];
          TotCnt ++;
        }
      else
        {
          Pcnt[n-1] =  (iOpen(NULL, PrdVal[n-1], 0) - iClose(NULL, PrdVal[n-1], 0)) / 
                 (iHigh(NULL, PrdVal[n-1], 0) - iLow(NULL, PrdVal[n-1], 0)) * 100;
          ObjectSetText("1.Data"+n+1, DoubleToStr(Pcnt[n-1], 0), TextSize, "Arial", TextCol2);
          ObjectSetText("1.Data"+n+0, DoubleToStr(100 - Pcnt[n-1], 0), TextSize, "Arial", TextCol3);
          Tot += Pcnt[n-1];
        }
        
      Timer =  PrdVal[n-1] - (TimeCurrent() - iTime(NULL, PrdVal[n-1], 0)) / 60;
      ObjectSetText("1.Data"+n+2, DoubleToStr(Timer, 0), TextSize, "Arial", TextCol);
      
     }
    ObjectSetText("1.Data"+0+0, DoubleToStr(Tot / TotCnt, 1) + "%", TextSize + 4, "Arial Bold", TextCol3);
    ObjectSetText("1.Data"+0+1, DoubleToStr(100 - (Tot / TotCnt), 1) + "%", TextSize + 4, "Arial Bold", TextCol2);
     
  return(0);
 }
 
//-----------------------------------------------+
int deinit()
 {
  for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string mLab = ObjectName(i);
       if(StringSubstr(mLab, 0, 2) == "1.")
         ObjectDelete(mLab);  
     }  
  Comment("");
     
  return(0);
 }

//-----------------------------------------------+
void CreateLabels()
 { 
   string RowName[3] = {"BUYERS", "SELLERS", "C Time"},
          HeadName[9] = {"Power", "M5", "M15", "M30", "H1", "H4", "D1", "W1"};
   for(int c = 0; c < 3; c++)
     {
       ObjectCreate("1.RowLab"+c, OBJ_LABEL, 0, 0, 0, 0);
       ObjectSet("1.RowLab"+c, OBJPROP_CORNER, Corner);
       ObjectSet("1.RowLab"+c, OBJPROP_XDISTANCE, 1);
       ObjectSet("1.RowLab"+c, OBJPROP_YDISTANCE, 40 + VTab * c);   
       ObjectSetText("1.RowLab"+c, RowName[c], TextSize, "Arial", TextCol);
       
       for(int b = 0; b < 8; b++)      // each column
        {
         ObjectCreate("1.Data"+b+c, OBJ_LABEL, 0, 0, 0); 
         ObjectSet("1.Data"+b+c, OBJPROP_CORNER, Corner);
         ObjectSet("1.Data"+b+c, OBJPROP_XDISTANCE, 60 + HTab[b]);  
         ObjectSet("1.Data"+b+c, OBJPROP_YDISTANCE, 40 + VTab * c);
         if(b == 0)
           ObjectSet("1.Data"+b+c, OBJPROP_YDISTANCE, 36 + VTab * c);
         ObjectSetText("1.Data"+b+c, "", TextSize, "Arial", CLR_NONE );
        } // for b
     }  // for c
     
        for(int d = 0; d < 9; d++)      // each column
        {
         ObjectCreate("1.Head"+d, OBJ_LABEL, 0, 0, 0); 
         ObjectSet("1.Head"+d, OBJPROP_CORNER, Corner);
         ObjectSet("1.Head"+d, OBJPROP_XDISTANCE, 60 + HTab[d]);  
         ObjectSet("1.Head"+d, OBJPROP_YDISTANCE, 23);
         ObjectSetText("1.Head"+d, HeadName[d], TextSize, "Arial", TextCol );
        }
         
   return;
 }
//+------------------------------------------------------------------+
