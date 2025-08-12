//+------------------------------------------------------------------+
//|                                               EA News Impact.mq4 |
//|                                                          Robotop |
//|                                               https://Robotop.id |
//+------------------------------------------------------------------+
#property copyright "Robotop"
#property link      "https://Robotop.id"
#property version   "1.00"
#property strict

/*
   27 Maret 2023
   Versi 1.00
   
   

*/

#define HOLIDAY   0
#define LOW       1
#define MEDIUM    2
#define HIGH      3

struct stDataNews{
   string title;
   string country;
   datetime date;
   int   impact;
   double forecast;
   double previous;

};

bool     P_News   = false;

#import "libNewsFF.ex4"
   bool getNews(int offset=3, int duration=77, string url="");
   int checkPrevNews(int with_in=15, int impact=-1, string filterCountry="");
   int checkNextNews(int with_in=15, int impact=-1, string filterCountry="");
   int getNewsRecord(stDataNews &arrRecord[], int with_in=15, int impact=-1, string filterCountry="");
#import

enum enumNewsImpact{
   eNewsImpactLow,         //Low Impact
   eNewsImpactMedium,      //Medium Impact
   eNewsImpactHigh,        //High Impact
   
};

input    bool                 IN_FilterNews        = true;                             //Filter News (Stop Trading during News)
input    int                  IN_Offset            = 3;                                //GMT SERVER
input    int                  IN_MinuteBeforeNews  = 15;                               //Before News (0: avoid)
input    int                  IN_MinuteAfterNews   = 30;                               //After News (0: avoid)
input    enumNewsImpact       IN_ImpactNews        = eNewsImpactHigh;                  //Impact
input    string               IN_CountryNews       = "USD, GBP, EUR, CAD, JPY, AUD, NZD"; //Country



int OnInit()
{

   

   return(INIT_SUCCEEDED);
}

void OnTick()
{

   bool isStopTradingByNews  = false;
   if (IN_FilterNews == true){
      P_News = getNews(IN_Offset);
      if (P_News){
         int NewsInMinute  = IN_MinuteBeforeNews; //Incoming news in xx minutes
         int impact  = IN_ImpactNews;
         string country = IN_CountryNews; //"USD, GBP, EUR";
         if (NewsInMinute > 0 && checkNextNews(NewsInMinute, impact, country) >= 0 ){
            //ada berita sesuai kriterial menjelang news
            isStopTradingByNews  = true;
         }
         
         if (!isStopTradingByNews){
            NewsInMinute  = IN_MinuteAfterNews;
            if (NewsInMinute > 0 && checkPrevNews(NewsInMinute, impact, country) >= 0 ){
               //ada berita sesuai kriterial sesudah News
               isStopTradingByNews  = true;
            }
         }
         
         
         //contoh untuk informasi lebih detil dari data news
         ObjectsDeleteAll();
         int x=25, y=50;
         string idLabel = "", strNews = "", strImpact;
         color warna = clrNONE;
            
         int count   = 0;
         stDataNews arrRecordNews[];
         count = getNewsRecord(arrRecordNews, 1440, impact, IN_CountryNews); //News dalam 1440 menit (24jam) kedepan, dengan impact: mulai dari LOW, Country: USD, GBP, EUR
         for (int i=0; i<count; i++){
            //Print("Title: ", arrRecordNews[i].title, " Country: ", arrRecordNews[i].country, " Impact: ", arrRecordNews[i].impact, " Time: ", arrRecordNews[i].date, " Forecast: ", arrRecordNews[i].forecast, " previous: ", arrRecordNews[i].previous);
            switch(arrRecordNews[i].impact){
               case HIGH   : strImpact= "High";    warna = clrDeepPink;     break;
               case MEDIUM : strImpact= "Medium";  warna = clrDeepSkyBlue;   break;
               case LOW    : strImpact= "Low";     warna = clrMediumSpringGreen;   break;
               default     : strImpact= "holiday"; warna = clrGray;   break;
            }
            
            x = 25; idLabel  = "news_1"+IntegerToString(i);
            strNews  = StringFormat("Country: %s Impact: %s Time: %s ", arrRecordNews[i].country, strImpact, TimeToString(arrRecordNews[i].date, TIME_DATE|TIME_SECONDS));
            SetLabel(idLabel, strNews, x, y, warna);
            
            x = 300; idLabel  = "news_2"+IntegerToString(i);
            strNews  = StringFormat("Title %s", arrRecordNews[i].title);
            SetLabel(idLabel, strNews, x, y, warna);
            
            x = 550; idLabel  = "news_3"+IntegerToString(i);
            strNews  = StringFormat("previous: %.2f forecast: %.2f", arrRecordNews[i].previous, arrRecordNews[i].forecast);
            SetLabel(idLabel, strNews, x, y, warna);
            
            
            y += 15;
         }
      
         
         
      }
   }
      
   
   if (isStopTradingByNews==true){
      //stop trading
      
   }else{
      //lanjutkan trading
      //coding cek signal dan open order bisa diletakkan pada bagian ini.
      
      
   }
      
      
         
 }
 
//+------------------------------------------------------------------+


void SetLabel(string labelIndicator, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 8, int typeCorner = CORNER_LEFT_UPPER)
{
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
   }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  