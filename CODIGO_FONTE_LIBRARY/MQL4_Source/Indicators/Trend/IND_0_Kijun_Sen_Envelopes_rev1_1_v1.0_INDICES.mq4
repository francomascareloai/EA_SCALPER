#property copyright "2013, file45"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 1
#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 0
#property indicator_color1 LimeGreen
#property indicator_color2 DodgerBlue
#property indicator_color3 Red

extern int Kijun_Sen_Period = 26;
int ShiftKijun = 0;
extern int Envelope_Deviation = 3000;
extern color Envelope_Top_Label_Color = LimeGreen;
extern color Kijun_Sen_Label_Color = DodgerBlue;
extern color Envelope_Bottom_Label_Color = Red;
extern int Text_Size = 12;
extern bool Make_Text_Bold = true;
extern int Move_Text_Right = 25;
string Font_Type;
extern bool Show_Top_Envelope_Band = true;
extern bool Show_Kijun_Sen = true;
extern bool Show_Bottom_Envelope_Band = true;
extern bool Show_Labels = true;

double Kijun_Buffer_1[];
double Kijun_Buffer_2[];
double Kijun_Buffer_3[];

string ObjKijun="Kijun";
string ObjEnvET="EnvET";
string ObjEnvEB="EnvEB";

int a_begin;
/////////////////////////////// Testing code
string textks  = "";
string textet  = "";
string texteb  = "";
/////////////////////////////// Testing code

int init()
{
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Kijun_Buffer_1);
   SetIndexDrawBegin(0,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(0,ShiftKijun);
   SetIndexLabel(0,"Top Env Band");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Kijun_Buffer_2);
   SetIndexDrawBegin(1,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(1,ShiftKijun);
   SetIndexLabel(1,"Kijun Sen");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Kijun_Buffer_3);
   SetIndexDrawBegin(2,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(2,ShiftKijun);
   SetIndexLabel(2,"Bottom Env");
   
   if(Make_Text_Bold == true)
   {
     Font_Type = "Arial Bold";
   }
   else
   {
      Font_Type ="Arial";
   }  
/////////////////////////////// Testing code   
   if (Show_Labels == false)
   {
      textks  = "";
      textet  = "";
      texteb  = "";     
   }
/////////////////////////////// Testing code 
   return(0);
}

int start()
{
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;

   if(Bars<=Kijun_Sen_Period) return(0);

   if(counted_bars<1)
   {
      for(i=1;i<=Kijun_Sen_Period;i++)   
      Kijun_Buffer_1[Bars-i]=0;
      Kijun_Buffer_2[Bars-i]=0;
      Kijun_Buffer_3[Bars-i]=0;
   }
//---- Kijun Sen + Envelopes
   i=Bars-Kijun_Sen_Period;
   if(counted_bars>Kijun_Sen_Period) i=Bars-counted_bars-1;
   while(i>=0)
   {
      high=High[i]; low=Low[i]; k=i-1+Kijun_Sen_Period;
      while(k>=i)
      {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price) low=price;
         k--;
      }
      
      if(Show_Top_Envelope_Band == true)
      {
         Kijun_Buffer_1[i+ShiftKijun]=((high+low)/2)+Envelope_Deviation*Point;
         if(Show_Labels==true)
         {
            string KET = DoubleToStr(Kijun_Buffer_1[0],Digits);
         }
         ObjectCreate(ObjEnvET,OBJ_TEXT,0,0,0);
         ObjectSetText(ObjEnvET,textet + KET,Text_Size, Font_Type,Envelope_Top_Label_Color);
         ObjectMove(ObjEnvET,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_1[0]);
      }
      
      if(Show_Kijun_Sen==true)
      {
         Kijun_Buffer_2[i+ShiftKijun]=((high+low)/2);
         if(Show_Labels == true)
         {
            string KS = DoubleToStr(Kijun_Buffer_2[0],Digits);
         }
         ObjectCreate(ObjKijun,OBJ_TEXT,0,0,0);
         ObjectSetText(ObjKijun,textks + KS,Text_Size,Font_Type, Kijun_Sen_Label_Color);
         ObjectMove(ObjKijun,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_2[0]);
      }
      
      if(Show_Bottom_Envelope_Band == true)
      {
         Kijun_Buffer_3[i+ShiftKijun]=((high+low)/2)-Envelope_Deviation*Point;
         if (Show_Labels == true)
         {      
            string KEB = DoubleToStr(Kijun_Buffer_3[0],Digits);
         }
         ObjectCreate(ObjEnvEB,OBJ_TEXT,0,Time[0],high);
         ObjectSetText(ObjEnvEB,texteb + KEB,Text_Size,Font_Type,Envelope_Bottom_Label_Color);
         ObjectMove(ObjEnvEB,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_3[0]);
      }
      i--;
   } 
   i=ShiftKijun-1;
}

int deinit()
{
   ObjectDelete("Kijun");
   ObjectDelete("EnvET");
   ObjectDelete("EnvEB");
}   


