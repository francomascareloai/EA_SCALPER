//------------------------------------------------------------------------------------------------+
//                                                                                                |
//                                        FFCal Panel.mq4                                         |
//                                                                                                |
//------------------------------------------------------------------------------------------------+
#property copyright "Copyright @ 2015 traderathome, atstrader, deVries, qFish"
#property link      "email: traderathome@msn.com"

/*-------------------------------------------------------------------------------------------------
User Notes:

This FFCal Panel indicator is coded to run on MT4 Build 600+.  It places a panel on the chart in 
which are displayed up to four news releases listed on the Forex Factory Calendar.  Details are
provided below. 

FFCAL PANEL CONTENTS -
The time, title and ranking (by color) of the releases are shown.

The time of a releases is important because the market frequently holds price moves until after
important releases come out.  Also, Market Makers can prepare in advance for these moves.  The
Market Makers and banks do know the essence of news and releases in advance, and there is no
regulation against insider trading in the forex market.  Banks can place orders in advance of
releases and Market Makers can use the intervening time to move prices to fill those orders,
saving the move that will make profits on the orders until the time of the releases.

The title of the release, and it's ranking by color, is important because the variety of low
impact releases frequently have no effect on price, whereas the variety of high impact releases
can trigger a big price move, or can cause Market Makers to start moving prices days in advance,
in preparations for big moves to be made in conjunction with those releases.

Of the three impact level events (High, Medium, Low) and Bank Holidays, you have the option to not
show all but the High Impact events.  The Previous/Forecast data (available on the Forex Factory
Calendar) is not displayed because prices can go either way regardless of specifics released.  it
is the timing of news that is important, as a market volatility event.

THE PRIORITIZATION OF EVENTS -
Prioritization of events is fully automated and two more event labels are added to help avoid
surprises.  When two or more events occur simultaneously, only one event of the highest impact
displays unless there are multiple high impact events.  In that case the multple high impact
events are displayed.  When 2nd, 3rd or 4th events are not scheduled, text noting that appears.
A current day Bank Holiday will remain displayed in the first label until the Bank Holiday is
over.  You can show events for any pair on any chart.  For example, you can show  a CNY (China)
event on a AUDUSD chart.  A new option is added allowing you to ignore the chart pair and
select what currencies you want to show news for, so that you do not have to display the news
for the chart pair.

THE ALERT -
You can specify to be alerted "x" minutes ahead of the scheduled release of Event #1.  When
that time arrives, an alert will sound/appear on the chart.  If during the same minute, while
the relase time and the alert time are of the same minute, if you change chart time framse the
alert will retrigger on the selected new chart time frame.  After that minute passes, there will
be no retrigger of the set alert under any circumstances.  Enter your "Broker_Name_In_Alert" to
avoid confusion if simultaneously using multiple platforms.

When "Alert_Minutes_Before_Event_1" is set at "0" the Alert is not set to function.   If any
other number appears, the Alert is set to function.  When the Alert is set to function....
   * If the minutes input is less than the time to the release of Event #1, the Alert is set
     to trigger and "Alert Pending" appears in the FFCal title.
   * If the minutes input equals the time to the release, the Alert triggers and "Alert Received"
     appears in the FFCal title.
   * If the minutes input now exceeds the time to the release, the release is already one or
     more minutes into the past and "Alert Completed" appears in the FFCal title.  When this is
     the case, open the External Inputs and reset the input to "0" to turn off the Alert.

THE TFs FOR DISPLAY OF FFCAL -
You can select a range of TFs for the display of this indicator, so it automatically will not
display on a chart TF outside that range.  The indicator can be turned on/off without having
to remove it from the chart, thereby preserving your chart settings.

                                                                        - Traderathome, 05-30-2015
---------------------------------------------------------------------------------------------------
ACKNOWLEDGEMENTS:

derkwehler and other contributors - the core code of the FFCal indicator,
                                    FFCal_v20 dated 07/07/2009, Copyright @ 2006 derkwehler
                                    http://www.forexfactory.com/showthread.php?t=19293
                                    email: derkwehler@gmail.com

deVries -      for his excellent donated work that significantly altered and streamlined the file
               handling coding to establish compatibility with the new release of MT4 Build 600+,
               (Jobs for deVries  www.mql5.com/en/job/new?prefered=deVries)
qFish -        for his generously given time and help during the effort to improve this indicator.
atstrader -    For the option controlling for what pair/pairs(s) news is shown, and for providing
               new file access coding in 2015.
traderathome - for the modification of the original work to show more and prioritized headlines.

---------------------------------------------------------------------------------------------------
Suggested Colors:                    White Charts          Black Charts

FFCal_Title                          Black                 C'180,180,180'
News_Low_Impact                      C'000,125,029'        C'046,186,046'
News_Medium_Impact                   MediumBlue            C'098,147,238'
News_High_Impact                     Crimson               C'240,038,038'
Bank_Holiday_Color                   DarkOrchid            Orchid
Remarks_Color                        DarkGray              DimGray
Background_Color_                    White                 C'010,010,010''

-------------------------------------------------------------------------------------------------*/


//+-----------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                       |
//+-----------------------------------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  CLR_NONE

#define READURL_BUFFER_SIZE   100

#define TITLE		0
#define COUNTRY   1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

#import  "Wininet.dll"
   int InternetOpenW(string, int, string, string, int);
   int InternetConnectW(int, string, int, string, string, int, int, int);
   int HttpOpenRequestW(int, string, string, int, string, int, string, int);
//start 2015 atstrader revision
   //   int InternetOpenUrlW(int, string, string, int, int, int);
//end 2015 atstrader revision
   int InternetOpenUrlW(int, string, string, uint, uint, uint);
   int InternetReadFile(int, uchar & arr[], int, int & arr[]);
   int InternetCloseHandle(int);
#import

//global external inputs---------------------------------------------------------------------------
extern string Part_1                          = "Indicator Display Controls:";
extern bool   Indicator_On                    = true;
extern int    Show_H_HM_HML_123               = 3;
extern bool   Allow_Panel_In_Subwindow_1      = true;
extern bool   Allow_Panel_At_Chart_Right      = false;
extern int    Display_Min_TF                  = 1;
extern int    Display_Max_TF                  = 43200;
extern string TF_Choices                      = "1-5-15-30-60-240-1440-10080-43200";

extern string __                              = "";
extern string Part_2                          = "Headline Settings:";
extern color  FFCal_Title 	                   = C'180,180,180';
extern color  Low_Impact_News_Color           = C'046,186,046';
extern color  Medium_Impact_News_Color        = C'098,147,238';
extern color  High_Impact_News_Color          = C'240,038,038';
extern color  Bank_Holiday_Color              = Orchid;
extern color  Remarks_Color                   = DimGray;
extern color  Background_Color_               = C'010,010,010';
extern bool   Show_Panel_Background           = true;

extern string ___                             = "";
extern string Part_3                          = "Other Currency Settings:";
extern bool	  Show_USD_News                   = false;
extern bool	  Show_EUR_News                   = false;
extern bool	  Show_GBP_News                   = false;
extern bool	  Show_NZD_News                   = false;
extern bool	  Show_JPY_News                   = false;
extern bool	  Show_AUD_News                   = false;
extern bool	  Show_CAD_News                   = false;
extern bool	  Show_CHF_News                   = false;
extern bool	  Show_CNY_News                   = false;
extern bool	  Ignore_Current_Symbol           = false;

extern string ____                            = "";
extern string Part_4                          = "Alert Setting:";
extern int	  Alert_Minutes_Before_Event_1    = 0;

//global buffers and variables---------------------------------------------------------------------
bool          Deinitialized, skip;
bool          FLAG_1_done, FLAG_2_done, FLAG_3_done, FLAG_4_done;
bool          FLAG_1_none, FLAG_2_none, FLAG_3_none, FLAG_4_none;
int           BankIdx1,cnr;
color         TxtColorNews;
datetime      newsTime,calendardate;   //sundaydate calendar
double   	  ExtMapBuffer0[];     // Contains (minutes until) each news event
int 	        xmlHandle, BoEvent, finalend, end, begin, minsTillNews, tmpMins, idxOfNext;
int           Minutes[8], newsIdx, next, dispMins, Days, Hours, Mins;
int           i,k,curX,curY,W,Box,x1,x2,index;
int           WebUpdateFreq = 240; // 240 Minutes between web updates to not overload FF server
int           TxtSize       = 7;
int           TitleSpacer   = 6; 
int           EventSpacer   = 4; 
static int	  PrevMinute    = -1;
string 		  xmlFileName;
string        xmlSearchName;
int           PrevTF        = 0;
static int	  UpdateRateSec = 10;
string	     sUrl = "http://www.forexfactory.com/ff_calendar_thisweek.xml"; //original
//string      sUrl = "http://www.forexfactory.com/ffcal_week_this.xml";      //alternate 1
//string      sUrl = "http://cdn.forexfactory.com/ffcal_week_this.xml";      //alternate 2
string   	  myEvent,mainData[200][7], sData, csvoutput, sinceUntil, TimeStr;
string    	  G,/*pair, cntry1, cntry2,*/ Title[8], Country[8], Impact[8],event[5],Color[5];
string 	     sTags[7] = { "<title>", "<country>", "<date><![CDATA[","<time><![CDATA[",
              "<impact><![CDATA[", "<forecast><![CDATA[", "<previous><![CDATA[" };
string 	     eTags[7] = { "</title>", "</country>", "]]></date>", "]]></time>",
              "]]></impact>", "]]></forecast>", "]]></previous>" };
string        Text_Style = "Courier Narrow";
string        header;
string        box1    = "z[FFCal] Box1";
string        box2    = "z[FFCal] Box2";
string        News1   = "z[FFCal] News1";
string        News2   = "z[FFCal] News2";
string        News3   = "z[FFCal] News3";
string        News4   = "z[FFCal] News4";
string        Sponsor = "z[FFCal] Sponsor";

//Alert
bool          Alert_Allowed;

//+-----------------------------------------------------------------------------------------------+
//| Indicator De-initialization                                                                   |
//+-----------------------------------------------------------------------------------------------+
int deinit()
   {
   int obj_total= ObjectsTotal();
   for (i= obj_total; i>=0; i--) 
      {
      string name= ObjectName(i);
      if (StringSubstr(name,0,8)=="z[FFCal]") {ObjectDelete(name);}
      }
	return(0);
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Initialization                                                                      |
//+-----------------------------------------------------------------------------------------------+
int init()
   {
   //Get current time frame
   PrevTF = Period();
	//Make sure we are connected.  Otherwise exit.
   //With the first DLL call below, the program will exit (and stop) automatically after one alert.
   if ( !IsDllsAllowed() ) 
      {
      Alert(Symbol()," ",Period(),", FFCal: Allow DLL Imports");
      }

	//deVries: Management of FFCal.xml Files involves setting up a search to find and delete files
	//that are not of this Sunday date.  This search is limited to 10 weeks back (604800 seconds).
	//Files with Sunday dates that are older will not be purged by this search and will have to be
	//manually deleted by the user.
	xmlFileName = GetXmlFileName();
   for (k=calendardate;k>=calendardate-6048000;k=k-604800)
      {
      xmlSearchName =  (StringConcatenate(TimeYear(k),"-",
         PadString(DoubleToStr(TimeMonth(k),0),"0",2),"-",
         PadString(DoubleToStr(TimeDay(k),0),"0",2),"-FFCal-News",".xml"));
      xmlHandle = FileOpen(xmlSearchName, FILE_BIN|FILE_READ);
	   if(xmlHandle >= 0) //file exists.  A return of -1 means file does not exist.
	      {
	      FileClose(xmlHandle);
	      if(xmlSearchName != xmlFileName)FileDelete(xmlSearchName);
	      }
	   }

   W= 0; cnr= 2; if(Allow_Panel_At_Chart_Right) {cnr= 3;}
   if(Allow_Panel_In_Subwindow_1 && WindowsTotal( ) > 1){W= 1;}

	SetIndexBuffer(0, ExtMapBuffer0);
   SetIndexStyle(0, DRAW_NONE);
   IndicatorShortName("FFCal");

   Deinitialized = false;
   Alert_Allowed = true;
   
	return(0);
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Start                                                                               |
//+-----------------------------------------------------------------------------------------------+
int start()
   {
   //If Indicator is "Off" or chart is out of range deinitialize only once, not every tick.
   if((!Indicator_On) || ((Period() < Display_Min_TF) || (Period() > Display_Max_TF)))
      {
      if (!Deinitialized)  {deinit(); Deinitialized = true;}
      //deleting old versions xml file
      return(0);
      }    

   InitNews(sUrl);

	//qFish-----------------------------------------------------------------------------------------
	//Perform remaining checks once per UpdateRateSec (Refreshing News from XML file)
   if(PrevTF==Period())
      {
      //if we haven't changed time frame then keep doing what we are doing
      if(MathMod(Seconds(),UpdateRateSec)==0)
         {
         return (true);
         }
      //otherwise, we've switched time frame and do not need to skip every 10 s,
      //thus immediately execute all of the start() function code
      else
         {
         PrevTF = Period();
         }
      }

	//Init the buffer array to zero just in case
	ArrayInitialize(ExtMapBuffer0, 0);

	//deVries---------------------------------------------------------------------------------------
	//New xml file handling coding and revised parsing coding
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
	if(xmlHandle>=0)
	   {
	   int size = FileSize(xmlHandle);
	   sData = FileReadString(xmlHandle, size);
	   FileClose(xmlHandle);
	   }

	//Clear prioritization data
	BankIdx1   = 0;
	FLAG_1_done = false;
   FLAG_2_done = false;
   FLAG_3_done = false;
   FLAG_4_done = false;
   FLAG_1_none = false;
   FLAG_2_none = false;
   FLAG_3_none = false;
   FLAG_4_none = false;
	for (i=0; i<=9; i++)
	   {
	   Title[i]   = "";
	   Country[i] = "";
	   Impact[i] 	= "";
	   Minutes[i]	= 0;
      }

	//Parse the XML file looking for an event to report
	newsIdx = 0;
	tmpMins = 10080;	// (a week)
	BoEvent = 0;
	while (true)
   	{
		BoEvent = StringFind(sData, "<event>", BoEvent);
		if (BoEvent == -1) break;
		BoEvent += 7;
		next = StringFind(sData, "</event>", BoEvent);
		if (next == -1) break;
		myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
		BoEvent = next;
		begin = 0;
		skip = false;
		for (i=0; i < 7; i++)
		   {
			mainData[newsIdx][i] = "";
			next = StringFind(myEvent, sTags[i], begin);
			// Within this event, if tag not found, then it must be missing; skip it
			if (next == -1) continue;
			else
			   {
				// We must have found the sTag okay...
				begin = next + StringLen(sTags[i]);		   	// Advance past the start tag
				end = StringFind(myEvent, eTags[i], begin);	// Find start of end tag
				//Get data between start and end tag
				if (end > begin && end != -1)
				   {mainData[newsIdx][i] = StringSubstr(myEvent, begin, end - begin);}
			   }
		   }//End "for" loop

		//Test against filters that define whether we want to skip this particular announcement
		if(!IsNewsCurrency(Symbol(),mainData[newsIdx][COUNTRY]))	//deVries
			{skip = true;}

		else if ((Show_H_HM_HML_123 == 1) &&
		   (mainData[newsIdx][IMPACT] == "Medium"))
		   {skip = true;}

		else if ((Show_H_HM_HML_123 == 1 || Show_H_HM_HML_123 == 2) &&
		   (mainData[newsIdx][IMPACT] == "Low"))
		   {skip = true;}

		else if (!StringSubstr(mainData[newsIdx][TITLE],0,4)== "Bank")
		    {skip = true;}

		else if (!StringSubstr(mainData[newsIdx][TITLE],0,8)== "Daylight")
		    {skip = true;}

   	else if ((mainData[newsIdx][TIME] == "All Day" && mainData[newsIdx][TIME] == "") ||
		   (mainData[newsIdx][TIME] == "Tentative" && mainData[newsIdx][TIME] == "")     ||
		  	(mainData[newsIdx][TIME] == ""))
		  	{skip = true;}

		//If not skipping this event, then log time to event it into ExtMapBuffer0
		if (!skip)
		   {
			//If we got this far then we need to calc the minutes until this event
			//First, convert the announcement time to seconds (in GMT)
			newsTime = MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]);
			// Now calculate the minutes until this announcement (may be negative)
			minsTillNews = (newsTime - TimeGMT()) / 60;

			//At this point, only events applicable to the pair ID/Symbol are being processed:
			//Find the most recent past event.  Do this by incrementing idxOfNext for each event
			//with a past time, (i.e. minsTillNews < 0).  When coming upon the first event with
			//minsTillNews > 0, idxOfNext is not incremented, and therefore continues to be for
			//the most recent past event.  It does not get incremented again until the absolute
			//value of the time since this most recent past event exceeds the time to the next
			//future event.
			if (minsTillNews < 0 || MathAbs(tmpMins) > minsTillNews)
			   {idxOfNext = newsIdx; tmpMins	= minsTillNews;}

			//ExtMapBuffer0 contains the time UNTIL each announcement (can be negative)
			//e.g. [0] = -372; [1] = 25; [2] = 450; [3] = 1768 (etc.)
			ExtMapBuffer0[newsIdx] = minsTillNews;
			newsIdx++;

		   }//End "skip" routine
	   }//End "while" routine

	//----------------------------------------------------------------------------------------------
	//Prioritization coding:  Cycle thru the range of "newsIdx" prioritizing events for display.
	for (i=0; i < newsIdx; i++)
	   {
      //The 1st event to be displayed is either a past event, or an upcoming event, whichever is
      //most most close in time.  If the 1st event is a past event, then look at the three previous
      //past events.  For any of them that occurred at the same time as the 1st event, choose for
      //display the most recent one with a higher impact.  If none have a higher impact, then stay
      //with the 1st event.

      //Get 4th previous item:
      if (i == idxOfNext-3)
         {
			Title[7]	   = mainData[i][TITLE];
			Country[7] 	= mainData[i][COUNTRY];
			Impact[7]  	= mainData[i][IMPACT];
			Minutes[7] 	= ExtMapBuffer0[i];
         }
      //Get 3rd previous item:
      if (i == idxOfNext-2)
         {
			Title[6]	   = mainData[i][TITLE];
			Country[6] 	= mainData[i][COUNTRY];
			Impact[6]  	= mainData[i][IMPACT];
			Minutes[6] 	= ExtMapBuffer0[i];
         }
      //Get 2nd previous item:
      if (i == idxOfNext-1)
         {
			Title[5]	   = mainData[i][TITLE];
			Country[5] 	= mainData[i][COUNTRY];
			Impact[5]  	= mainData[i][IMPACT];
			Minutes[5] 	= ExtMapBuffer0[i];
         }
      //Get previous/current items:
      if (i == idxOfNext)
         {
         Title[1]	   = mainData[i][TITLE];
			Country[1] 	= mainData[i][COUNTRY];
			Impact[1]  	= mainData[i][IMPACT];
			Minutes[1] 	= ExtMapBuffer0[i];
         //If idxOfNext is a previous event, then compare to 2nd, 3rd and 4th previous events.
         //If none of these three also previous events have the same time and a higher impact,
         //stay with the most recent previous event ([0]):  			         
         if (Minutes[0] <= 0)
            {
	         //if time [0] = [4] and [4] is > impact than [0], then [4] becomes 1st event [0]
	         //In other words, if 2nd previous event back is of higher impact use it:
	         if ((Minutes[0] == Minutes[4]) &&
	         ((Impact[1] == "Medium" && Impact[5] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[5] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[5] == "Medium")))
		 	      {
		   	   Title[1]	= Title[5];
			      Country[1] = Country[5];
			      Impact[1]  = Impact[5];
			      Minutes[1] = Minutes[5];
			      }
		      //if time [0] = [5] and [5] is > impact than [0], then [5] becomes 1st event [0]
		      //In other words, if 3rd previous event back is of higher impact use it:
	         else if ((Minutes[0] == Minutes[5]) &&
	         ((Impact[1] == "Medium" && Impact[5] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[5] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[5] == "Medium")))
		 	      {
		      	Title[1]   = Title[6];
			      Country[1] = Country[6];
			      Impact[1]  = Impact[6];
			      Minutes[1] = Minutes[6];
               }
            //if time [0] = [6] and [6] is  > impact than [0], then [6] becomes 1st event [0]
            //In other words, if 4th previous event back is of higher impact use it:
	         else if ((Minutes[0] == Minutes[6]) &&
	         ((Impact[1] == "Medium" && Impact[7] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[7] == "High")  ||
			   (Impact[1]  == "Low"    && Impact[7] == "Medium")))
		 	      {
		      	Title[1]   = Title[7];
			      Country[1] = Country[7];
			      Impact[1]  = Impact[7];
			      Minutes[1] = Minutes[7];
               }
            }
         }

		//-------------------------------------------------------------------------------------------       
      //Now that 1st event[0] is initialized, go thru rest of items, prioritizing. 
		if (i >= idxOfNext+1)
		   {
         Title[7]	= mainData[i][TITLE];
			Country[7] = mainData[i][COUNTRY];
			Impact[7]  = mainData[i][IMPACT];
			Minutes[7] = ExtMapBuffer0[i];
			//If 1st event [1] is not done with prioritization, and
			//if time [i] = [1] and [i] has > impact than [1] then [i] becomes 1st event [1].
	   	//Otherwise, if time [i] > [1] then initialize [i] as 2nd event [2]:
	   	if (!FLAG_1_done)
	   	   {
			   if ((Minutes[1] == Minutes[7]) &&
	            ((Impact[1]  == "Medium" && Impact[7] == "High")  ||
			      (Impact[1]   == "Low"    && Impact[7] == "High")  ||
			      (Impact[1]   == "Low"    && Impact[7] == "Medium")))
		 	      {
               Title[1]	    = Title[7];
			      Country[1]   = Country[7];
			      Impact[1]    = Impact[7];
			      Minutes[1]   = Minutes[7];
			      }
		      else if ((Minutes[1] < Minutes[7]) ||
		         ((Minutes[1] == Minutes[7]) && (Impact[7] == "High")) )
		         {
               Title[2]	    = Title[7];
			      Country[2]   = Country[7];
			      Impact[2]    = Impact[7];
			      Minutes[2]   = Minutes[7];
			      FLAG_1_done = true;
			      continue;
		         }
		      }
		   //If 1st event [1] is done prioritization, but 2nd event [2] is not, and
			//if time [i] = [2] and [i] has > impact than [2], then [i] becomes 2nd event [2].
			//Otherwise, if time [i] > [2] then intialize [i] as 3rd event [3]:
         if ((FLAG_1_done) && (!FLAG_2_done))
		      {			 			   	
			   if ((Minutes[2] == Minutes[7]) &&
	            ((Impact[2]  == "Medium" && Impact[7] == "High")  ||
			      (Impact[2]   == "Low"    && Impact[7] == "High")  ||
			      (Impact[2]   == "Low"    && Impact[7] == "Medium")))
		 	      {
               Title[2]	   = Title[7];
			      Country[2] 	= Country[7];
			      Impact[2]  	= Impact[7];
			      Minutes[2] 	= Minutes[7];
			      }
			   else if ((Minutes[2] < Minutes[7]) ||
		         ((Minutes[2] == Minutes[7]) && (Impact[7] == "High")) )
			      {
               Title[3]	   = Title[7];
			      Country[3] 	= Country[7];
			      Impact[3]  	= Impact[7];
			      Minutes[3] 	= Minutes[7];
			      FLAG_2_done = true;
			      continue;
			      }
			   }
	      //If 1st event [1] and 2nd event [2] are done, but 3rd event [3] is not, and
			//if time [i] = [3] and [i] has > impact than [3], then [i] becomes 3rd event [3].
		   //Otherwise, if time [i] > [3] then intialize [i] as 4th event [4]:
         if ((FLAG_1_done) && (FLAG_2_done) && (!FLAG_3_done))
		      {						   
			   if ((Minutes[3] == Minutes[7]) &&
	            ((Impact[3]  == "Medium" && Impact[7] == "High")  ||
			      (Impact[3]   == "Low"    && Impact[7] == "High")  ||
			      (Impact[3]   == "Low"    && Impact[7] == "Medium")))
		 	      {
               Title[3]	   = Title[7];
			      Country[3] 	= Country[7];
			      Impact[3]  	= Impact[7];
			      Minutes[3] 	= Minutes[7];
			      }
			   else if ((Minutes[3] < Minutes[7]) ||
		         ((Minutes[3] == Minutes[7]) && (Impact[7] == "High")) )
			      {
               Title[4]	   = Title[7];
			      Country[4] 	= Country[7];
			      Impact[4]  	= Impact[7];
			      Minutes[4] 	= Minutes[7];
			      FLAG_3_done = true;
			      continue;
			      }
			   }
         //If 1st, 2nd, and 3rd events are done, but 4th event [4] is not, and
			//if time [i] = [4] and [i] has > impact than [4], then [i] becomes 4th event [4].
			//Otherwise, prioritizing is finished:
         if ((FLAG_1_done) && (FLAG_2_done) && (FLAG_3_done) && (!FLAG_4_done))
		      {						   
			   if ((Minutes[4] == Minutes[7])  &&
	            ((Impact[4]  == "Medium" && Impact[7] == "High")  ||
			      (Impact[4]   == "Low"    && Impact[7] == "High")  ||
			      (Impact[3]   == "Low"    && Impact[7] == "Medium")))
		 	      {
               Title[4]	   = Title[7];
			      Country[4] 	= Country[7];
			      Impact[4]  	= Impact[7];
			      Minutes[4] 	= Minutes[7];
			      }
			   //Otherwise, prioritizing is finished:
			   else
			      {
			      FLAG_4_done = true;
			      }
			   }
 			//If all four event items are prioritized, exit loop.
		   if ((FLAG_1_done) && (FLAG_2_done) && (FLAG_3_done) && (FLAG_4_done)) {break;}
			}
	   }//End prioritizing "for" loop

	   //Next, determine if any events are out of sequence in time, or have duplicate
	   //titles within the same 6 hour period.  If so, eliminate the higher event item
	   //by setting the flag to not show the item.
	   //Check 1st and 2nd items.
		if (((Title[1]==Title[2]) && (Minutes[1]+ 360 > Minutes[2])) ||
		   (Minutes[1] > Minutes[2]))
			{
			{FLAG_2_none  = true;}
			}
      //Also check 1st and 3rd, and 2nd and 3rd items.
		if (((Title[1]==Title[3]) && (Minutes[1]+ 360 > Minutes[3])) ||
			((Title[2]==Title[3]) && (Minutes[2]+ 360 > Minutes[3]))  ||
			(Minutes[1] > Minutes[3]) || (Minutes[2] > Minutes[3]))
			{
			{FLAG_3_none  = true;}
			}
      //Also check 1st and 4th, and 3rd and 4th items.
		if (((Title[1]==Title[4]) && (Minutes[1]+ 360 > Minutes[4])) ||
			((Title[3]==Title[4]) && (Minutes[3]+ 360 > Minutes[4]))  ||
			(Minutes[1] > Minutes[4]) || (Minutes[3] > Minutes[4]))
			{
			{FLAG_4_none  = true;}
			}

	   //Check if 1st event[0] is more than half a day old and no 2nd event is scheduled.
	   //If so, eliminate the 1st event[0].
	   if ((Minutes[1] < -720) && (Minutes[2] == 0 ))
			{
			{FLAG_1_none  = true;}
			}

		//Be sure no "FLAG_none" remains false if a lower one turned to true
		if (FLAG_1_none)
		   {
		   FLAG_2_none  = true;
		   FLAG_3_none  = true;
		   FLAG_4_none  = true;
		   }
		else if (FLAG_2_none)
		   {
		   FLAG_3_none  = true;
		   FLAG_4_none  = true;
		   }
		else if (FLAG_3_none)
		   {
		   FLAG_4_none  = true;
		   }

		//Be sure to "FLAG_none" any with no country tag
		if (Country[1] == "") {FLAG_1_none = true;}
		if (Country[2] == "") {FLAG_2_none = true;}
		if (Country[3] == "") {FLAG_3_none = true;}
		if (Country[4] == "") {FLAG_4_none = true;}

		//Check for current day Bank Holiday.  If there is one, then move all
      //events up one tier and insert the Bank Holiday into 1st event.
      if (BankIdx1 == 1)
		   {
         Title[4]	   = Title[3];
			Country[4] 	= Country[3];
			Impact[4]  	= Impact[3];
			Minutes[4] 	= Minutes[3];
			FLAG_4_none  = FLAG_3_none;

			Title[3]	   = Title[2];
			Country[3] 	= Country[2];
			Impact[3]  	= Impact[2];
			Minutes[3] 	= Minutes[2];
			FLAG_3_none  = FLAG_2_none;

         Title[2]	   = Title[1];
			Country[2] 	= Country[1];
			Impact[2]  	= Impact[1];
			Minutes[2] 	= Minutes[1];
			FLAG_2_none  = FLAG_1_none;

         Title[1]	   = Title[8];
			Country[1]  = Country[8];
			Impact[1]  	= Impact[8];
			Minutes[1]  = Minutes[8];
			FLAG_1_none  = false;
			}

   //Set up Panel events---------------------------------------------------------------------------
   if(!Allow_Panel_At_Chart_Right) curX = 4; else curX = 2;
   curY = 4;

   //Event4
   sinceUntil = "until ";
   dispMins = Minutes[4]+1;
	if (Minutes[4] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes
		   {
			TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		  	{
		  	Days = MathRound(Hours / 24);
		 	Hours = Hours % 24;
		  	TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		  	}
	   }
   index = StringFind(TimeStr+sinceUntil+Country[4], "since  mins", 0);
   TxtColorNews = ImpactToColor(Impact[4]);
	if((index != -1) || (FLAG_4_none))
	   {
	   event[4] = "(4)  Additional news per settings is not scheduled  ";
	   Color[4] = Remarks_Color;
	   }
	else
	   {
	   event[4] = TimeStr + sinceUntil + Country[4] + ": " + Title[4] + "  ";
	   Color[4] = TxtColorNews;
		}

   //Event3
   sinceUntil = "until ";
   dispMins = Minutes[3]+1;
	if (Minutes[3] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes
		   {
			TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		  	{
		  	Days = MathRound(Hours / 24);
		 	Hours = Hours % 24;
		  	TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		  	}
	   }
   index = StringFind(TimeStr+sinceUntil+Country[3], "since  mins", 0);
   TxtColorNews = ImpactToColor(Impact[3]);
	if((index != -1) || (FLAG_3_none))
		{
		event[3] = "(3)  Additional news per settings is not scheduled  ";
		Color[3] = Remarks_Color;
		}
	else
	   {
	   event[3] = TimeStr + sinceUntil + Country[3] + ": " + Title[3] + "  ";
	   Color[3] = TxtColorNews;
		}

   //Event2
   sinceUntil = "until ";
   dispMins = Minutes[2]+1;
	if (Minutes[2] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
	   Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes
		   {
		   TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		   {
		   Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		   }
	   }
	index = StringFind(TimeStr+sinceUntil+Country[2], "since  mins", 0);
   TxtColorNews = ImpactToColor(Impact[2]);
	if((index != -1) || (FLAG_2_none))
		{	
		event[2] = "(2)  Additional news per settings is not scheduled  ";
		Color[2] = Remarks_Color;
      }
	else
	   {
	   event[2] = TimeStr + sinceUntil + Country[2] + ": " + Title[2] + "  ";
	   Color[2] = TxtColorNews;
		}

   //Event1
	//If time is 0 or negative, we want to say "xxx mins SINCE ... news event",
	//else say "UNTIL ... news event"
	sinceUntil = "until ";
	dispMins = Minutes[1]+1;  //dispMins "*= -1" = multiply by "-1"
	if (Minutes[1] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}
	if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
		Mins = dispMins % 60;
		if (Hours < 24) // less than a day: show hours and minutes
		   {
		   TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else  // days, hours, and minutes
		   {
		   Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		   }
	   }
	index = StringFind(TimeStr+sinceUntil+Country[1], "since  mins", 0); //Comment (index);
	TxtColorNews = ImpactToColor(Impact[1]);
	//return of "-1" means no previous/current/future event to display
	if((index != -1) || (FLAG_1_none))
		{
		event[1] = "(1)  Additional news per settings is not scheduled  ";
		Color[1] = Remarks_Color;
		}
	else  // will display "last" event until a "next" event is scheduled
		{
		event[1] = TimeStr + sinceUntil + Country[1] + ": " + Title[1] + "  ";
		Color[1] = TxtColorNews;
	   }

	//Execute draw of Panel-------------------------------------------------------------------------
   //Setup Panel background
   x1 = 0;
   x2 = 0;

   //Determine the length (x1) of the maximum length event string (i = 1-4)
   for(i=4; i>=1; i--)
      {
      if(StringSubstr(event[i], 0, 1) != "(")
        {
        if(i == 4) {x1 = StringLen(event[4]);}
        else {if(StringLen(event[i]) > x1) {x1 = StringLen(event[i]);}}
        }
      }

   //The panel with just the heading and no events requires a width that is the equivalent of a
   //50 character event.  For the panel to have the proper width requires panel box 1 start at
   //the chart border and panel box 2 be inset 23 pixels from the border.  if any event exceeds
   //50 characters then panel box 2 must be inset an addtional 2 pixels plue 4 more for each
   //additional character.
   int c = 50;
   if(x1<c) {x2 = 25;}
   else {x2 = 25 + int (6*(x1-c));}

   //Set up background boxes and text
   Box = 50;
   G   = "ggg";

   //Draws Background boxes
   if(Show_Panel_Background)
      {
      ObjectDelete(box1);
      ObjectCreate(box1, OBJ_LABEL, W, 0,0);
      ObjectSet(box1, OBJPROP_CORNER, cnr);
      ObjectSet(box1, OBJPROP_XDISTANCE, 0);
      ObjectSet(box1, OBJPROP_YDISTANCE, -1);
      ObjectSet(box1, OBJPROP_COLOR, Background_Color_);
      ObjectSet(box1, OBJPROP_BACK, false);
      ObjectSetText(box1, G, Box, "Webdings");
      ObjectDelete(box2);
      ObjectCreate(box2, OBJ_LABEL, W, 0,0);
      ObjectSet(box2, OBJPROP_CORNER, cnr);
      ObjectSet(box2, OBJPROP_XDISTANCE, x2);
      ObjectSet(box2, OBJPROP_YDISTANCE, -1);
      ObjectSet(box2, OBJPROP_COLOR, Background_Color_);
      ObjectSet(box2, OBJPROP_BACK, false);
      ObjectSetText(box2, G, Box, "Webdings");
      }

   ObjectDelete(News4);
   ObjectCreate(News4, OBJ_LABEL, W, 0, 0);
   ObjectSet(News4, OBJPROP_CORNER, cnr);
	ObjectSet(News4, OBJPROP_XDISTANCE, curX);
	ObjectSet(News4, OBJPROP_YDISTANCE, curY);
	ObjectSet(News4, OBJPROP_BACK, false);
   curY = curY + TxtSize + EventSpacer;
	ObjectSetText(News4, event[4], TxtSize, Text_Style, Color[4]);

	ObjectDelete(News3);
   ObjectCreate(News3, OBJ_LABEL, W, 0, 0);
   ObjectSet(News3, OBJPROP_CORNER, cnr);
	ObjectSet(News3, OBJPROP_XDISTANCE, curX);
	ObjectSet(News3, OBJPROP_YDISTANCE, curY);
   curY = curY + TxtSize + EventSpacer;
	ObjectSetText(News3, event[3], TxtSize, Text_Style, Color[3]);

	ObjectDelete(News2);
   ObjectCreate(News2, OBJ_LABEL, W, 0, 0);
   ObjectSet(News2, OBJPROP_CORNER, cnr);
   ObjectSet(News2, OBJPROP_XDISTANCE, curX);
	ObjectSet(News2, OBJPROP_YDISTANCE, curY);
   curY = curY + TxtSize + EventSpacer;
	ObjectSetText(News2, event[2], TxtSize, Text_Style, Color[2]);

	ObjectDelete(News1);
	ObjectCreate(News1, OBJ_LABEL, W, 0, 0);
	ObjectSet(News1, OBJPROP_CORNER, cnr);
	ObjectSet(News1, OBJPROP_XDISTANCE, curX);
	ObjectSet(News1, OBJPROP_YDISTANCE, curY);
   curY = curY + TxtSize + TitleSpacer;
	ObjectSetText(News1, event[1], TxtSize, Text_Style, Color[1]);

	//Alert
	if(Alert_Minutes_Before_Event_1==0)
	   {
	   header = "FFCAL HEADLINES:";
	   //header = "FOREX FACTORY CALENDAR HEADLINES:";
	   }
	if(Alert_Minutes_Before_Event_1!=0)
	   {
	   if(Alert_Minutes_Before_Event_1<Minutes[1])
         {
	      header = "FFCAL  (Alert Pending):";
   	   }
	   else if(Alert_Minutes_Before_Event_1==Minutes[1])
	      {
	      header = "FFCAL  (Alert Triggered):";
	      if(Alert_Allowed)
	         {
	         Alert(Alert_Minutes_Before_Event_1, " minutes until ", Country[1], ": ", Title[1]);
	         Alert_Allowed = false;
	         }
	      }
      else if(Alert_Minutes_Before_Event_1>Minutes[1])
	      {
	      header = "FFCAL  (Alert Completed):";
	      }
      }

	ObjectDelete(Sponsor);
	ObjectCreate(Sponsor, OBJ_LABEL, W, 0, 0);
	ObjectSet(Sponsor, OBJPROP_CORNER, cnr);
	ObjectSet(Sponsor, OBJPROP_XDISTANCE, curX);
	ObjectSet(Sponsor, OBJPROP_YDISTANCE, curY);
	ObjectSet(Sponsor, OBJPROP_BACK, false);
	ObjectSetText(Sponsor, header, TxtSize, "Verdana", FFCal_Title);
	return (0);
   }

//+-----------------------------------------------------------------------------------------------+
//| Subroutines: recoded creation and maintenance of single xml file                              |
//+-----------------------------------------------------------------------------------------------+   
//deVries: void InitNews(string& mainData[][], string newsUrl)
void InitNews(string newsUrl)
   {
   if(DoFileDownLoad()) //Added to check if the CSV file already exists
      {
      DownLoadWebPageToFile(newsUrl); //downloading the xml file
      }
   }

//deVries: If we have recent file don't download again
bool DoFileDownLoad()
   {
   xmlHandle = 0;
   int size;
   datetime time = TimeCurrent();
   //datetime time = TimeLocal();

   if(GlobalVariableCheck("Update.FF_Cal") == false)return(true);
   if((time - GlobalVariableGet("Update.FF_Cal")) > WebUpdateFreq*60)return(true);

   xmlFileName = GetXmlFileName();
   xmlHandle=FileOpen(xmlFileName,FILE_BIN|FILE_READ);  //check if file exist
   if(xmlHandle>=0)//when the file exists we read data
      {
	   size = FileSize(xmlHandle);
	   sData = FileReadString(xmlHandle, size);
      FileClose(xmlHandle);//close it again check is done
      return(false);//file exists no need to download again
      }
   //File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
   return(true); //commando true to download xml file
   }

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: getting the name of the ForexFactory .xml file                                    |
//+-----------------------------------------------------------------------------------------------+
//deVries: one file for all charts!
string GetXmlFileName()
   {
   int adjustDays = 0;
   switch(TimeDayOfWeek(TimeLocal()))
      {
      case 0:
      adjustDays = 0;
      break;
      case 1:
      adjustDays = 1;
      break;
      case 2:
      adjustDays = 2;
      break;
      case 3:
      adjustDays = 3;
      break;
      case 4:
      adjustDays = 4;
      break;
      case 5:
      adjustDays = 5;
      break;
      case 6:
      adjustDays = 6;
      break;
      }
   calendardate =  TimeLocal() - (adjustDays  * 86400);
   string fileName =  (StringConcatenate(TimeYear(calendardate),"-",
          PadString(DoubleToStr(TimeMonth(calendardate),0),"0",2),"-",
          PadString(DoubleToStr(TimeDay(calendardate),0),"0",2),"-FFCal-News",".xml"));

   return (fileName); //Always a Sunday date
   }

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: downloading the ForexFactory .xml file                                            |
//+-----------------------------------------------------------------------------------------------+
//2014 deVries: new coding replacing old "GrabWeb" coding
//2015 atstrader: revise file access coding
void DownLoadWebPageToFile(string url = "http://www.forexfactory.com/ff_calendar_thisweek.xml")
   {
   int HttpOpen = InternetOpenW(" ", 0, " ", " ", 0);
   int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);

//start 2015 atstrader revision
   // int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0, 0);
   // INTERNET_FLAG_PRAGMA_NOCACHE - 0x00000100 - do not try the cache or proxy
   // INTERNET_FLAG_NO_CACHE_WRITE - 0x04000000 - don't add this to the IE cache
   // INTERNET_FLAG_RELOAD         - 0x80000000 - Forces download of requested file, object, or
   //                                directory listing from the origin server, not from the cache.
   int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0x84000100, 0);
//end 2015 atstrader revision

   int read[1];
   uchar  Buffer[];
   ArrayResize(Buffer, READURL_BUFFER_SIZE + 1);
   string NEWS = "";

	   xmlFileName = GetXmlFileName();
	   xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ|FILE_WRITE);
	   //File exists if FileOpen return >=0.
	   if (xmlHandle >= 0) {FileClose(xmlHandle); FileDelete(xmlFileName);}

		//Open new XML.  Write the ForexFactory page contents to a .htm file.  Close new XML.
		xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_WRITE);

   while (true)
      {
      InternetReadFile(HttpRequest, Buffer, READURL_BUFFER_SIZE, read);
      string strThisRead = CharArrayToString(Buffer, 0, read[0], CP_UTF8);
      if (read[0] > 0)NEWS = NEWS + strThisRead;
      else
         {
         FileWriteString(xmlHandle, NEWS);
         FileClose(xmlHandle);
		   //Find the XML end tag to ensure a complete page was downloaded.
		   end = StringFind(NEWS, "</weeklyevents>", 0);
		   //If the end of file tag is not found, a return -1 (or, "end <=0" in this case),
		   //then return (false).
		   if (end == -1)
		      {
		      Alert(Symbol()," ",Period(),", FFCal Error: File download incomplete!");
		      return;
		      }
		   //Else, set global to time of last update
		   else {GlobalVariableSet("Update.FF_Cal", TimeCurrent());}
         break;
         }
      }
   if (HttpRequest > 0) InternetCloseHandle(HttpRequest);
   if (HttpConnect > 0) InternetCloseHandle(HttpConnect);
   if (HttpOpen > 0) InternetCloseHandle(HttpOpen);
   }

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: to pad string                                                                     |
//+-----------------------------------------------------------------------------------------------+
//deVries:
string PadString(string toBePadded, string paddingChar, int paddingLength)
   {
   while(StringLen(toBePadded) <  paddingLength)
      {
      toBePadded = StringConcatenate(paddingChar,toBePadded);
      }
   return (toBePadded);
   }

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: to ID currency even if broker has added a prefix to the symbol, and is used to    |
//| determine the news to show, based on the users external inputs selections                     |
//+-----------------------------------------------------------------------------------------------+
//deVries: works even when broker has attached prefix (or suffix) to the Currency, so that the
//symbol format does not look like the standard example EURUSD or USDJPY.
//atstrader: adds option to ignore the chart symbol pair and re-select other(s).
bool IsNewsCurrency(string cSymbol, string fSymbol)
   {
   if(!Ignore_Current_Symbol && (StringFind(cSymbol, fSymbol, 0)>=0)){return(true);}
   if(Show_USD_News && fSymbol == "USD"){return(true);}
   if(Show_GBP_News && fSymbol == "GBP"){return(true);}
   if(Show_EUR_News && fSymbol == "EUR"){return(true);}
   if(Show_CAD_News && fSymbol == "CAD"){return(true);}
   if(Show_AUD_News && fSymbol == "AUD"){return(true);}
   if(Show_CHF_News && fSymbol == "CHF"){return(true);}
   if(Show_JPY_News && fSymbol == "JPY"){return(true);}
   if(Show_NZD_News && fSymbol == "NZD"){return(true);}
   if(Show_CNY_News && fSymbol == "CNY"){return(true);}
   return(false);
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Subroutine For Impact Color                                                         |
//+-----------------------------------------------------------------------------------------------+
double ImpactToColor (string impact)
   {
	if (impact == "High") return (High_Impact_News_Color);
	else {if (impact == "Medium") return (Medium_Impact_News_Color);
	else {if (impact == "Low") return (Low_Impact_News_Color);
	else {if (impact == "Holiday") return (Bank_Holiday_Color);
	else {return (Remarks_Color);} }}}
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Subroutine For Date/Time    changed by deVries                                      |
//+-----------------------------------------------------------------------------------------------+
datetime MakeDateTime(string strDate, string strTime)  //not string now datetime
   {
	int n1stDash = StringFind(strDate, "-");
	int n2ndDash = StringFind(strDate, "-", n1stDash+1);

	string strMonth = StringSubstr(strDate, 0, 2);
	string strDay = StringSubstr(strDate, 3, 2);
	string strYear = StringSubstr(strDate, 6, 4);

	int nTimeColonPos = StringFind(strTime, ":");
	string strHour = StringSubstr(strTime, 0, nTimeColonPos);
	string strMinute = StringSubstr(strTime, nTimeColonPos+1, 2);
	string strAM_PM = StringSubstr(strTime, StringLen(strTime)-2);

	int nHour24 = StrToInteger(strHour);
	if ((strAM_PM == "pm" || strAM_PM == "PM") && nHour24 != 12) {nHour24 += 12;}
	if ((strAM_PM == "am" || strAM_PM == "AM") && nHour24 == 12) {nHour24 = 0;}

	datetime newsevent = StringToTime(strYear+ "." + strMonth + "." +
	   strDay)+nHour24*3600+ (StringToInteger(strMinute)*60);
	return(newsevent);
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator End                                                                                 |
//+-----------------------------------------------------------------------------------------------+