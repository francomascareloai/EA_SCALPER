//+------------------------------------------------------------------+
//|                                                 COTCustomInd.mq4 |
//|                                       Copyright 2017, DarkMindFX |
//|                                       https://www.darkmindfx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DarkMindFX"
#property link      "https://www.darkmindfx.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Value
#property indicator_label1  "Value 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Value 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Value 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input int BarsBack = 10;
//--- indicator buffers
double         ValueBuffer1[];
double         ValueBuffer2[];
double         ValueBuffer3[];



string codes[][2] = 
    {
{"022651","#2 HEATING OIL NY HARBOR-ULSD"},
{"246605","10 YEAR DELIVERABLE IR SWAP"},
{"043602","10-YEAR U.S. TREASURY NOTES"},
{"042601","2-YEAR U.S. TREASURY NOTES"},
{"86565C","3.5% FUEL OIL RDAM CRACK SPR"},
{"045601","30-DAY FEDERAL FUNDS"},
{"132741","3-MONTH EURODOLLARS"},
{"246606","5 YEAR DELIVERABLE IR SWAP"},
{"044601","5-YEAR U.S. TREASURY NOTES"},
{"023396","AECO FIN BASIS"},
{"0643EA","AEP DAYTON REALTIME OFFPEAK-MI"},
{"02339E","ALGONQUIN CITY-GATES FINANCIAL BASIS"},
{"191693","ALUMINUM MW US TR PLATTS SWAP"},
{"232741","AUSTRALIAN DOLLAR"},
{"221602","BLOOMBERG COMMODITY INDEX"},
{"102741","BRAZILIAN REAL"},
{"06765T","BRENT CRUDE OIL LAST DAY"},
{"096742","BRITISH POUND STERLING"},
{"050642","BUTTER (CASH SETTLED)"},
{"0643BM","CAISO NP-15 PEAK"},
{"064396","CAISO SP15 FIN DA OFF-PEAK"},
{"00639H","CALIF CARBON ALL VINTAGE 2016"},
{"00639Y","CALIF CARBON ALL VINTAGE 2017"},
{"090741","CANADIAN DOLLAR"},
{"067A49","CANADIAN HVY CRUDE NET ENRGY"},
{"025601","CBT ETHANOL"},
{"063642","CHEESE (CASH-SETTLED)"},
{"02339Q","CHICAGO CITYGATE (INDEX)"},
{"025651","CHICAGO ETHANOL SWAP"},
{"023397","CHICAGO FIN BASIS"},
{"052644","CME MILK IV"},
{"024656","COAL (API 2) CIF ARA SWAP FUT"},
{"024658","COAL (API 4) FOB  RICH BAY FUT"},
{"02465E","COAL ARA OPT CAL STRIP"},
{"073732","COCOA"},
{"083731","COFFEE C"},
{"02339U","COLORADO INTERSTATE - MAINLINE (BASIS)"},
{"02339W","COLUMBIA GAS CO. - TCO POOL (APPALACHIA) (BASIS)"},
{"02339Y","COLUMBIA GULF TRANSMISSION CO. -  MAINLINE POOL"},
{"06665T","CONWAY PROPANE (OPIS)"},
{"085692","COPPER-GRADE #1"},
{"002602","CORN"},
{"033661","COTTON NO. 2"},
{"06765C","CRUDE OIL AVG PRICE OPTIONS"},
{"067A28","CRUDE OIL CAL SPREAD OPT FIN"},
{"067657","CRUDE OIL CAL SPREAD OPTIONS"},
{"067651","CRUDE OIL LIGHT SWEET"},
{"067411","CRUDE OIL LIGHT SWEET-WTI"},
{"12460+","DJIA Consolidated"},
{"0233A2","DOMINION - SOUTH POINT"},
{"0233A3","DOMINION - SOUTH POINT (BASIS)"},
{"124603","DOW JONES INDUSTRIAL AVG- x $5"},
{"052645","DRY WHEY"},
{"0233A5","EL PASO - PERMIAN BASIN (BASIS)"},
{"0233A6","EL PASO - PERMIAN BASIN (INDEX)"},
{"0233A8","EL PASO-SAN JUAN BASINBLANCO POOL PRIMARY ONLY-BASIS"},
{"33874A","E-MINI S&P 400 STOCK INDEX"},
{"13874A","E-MINI S&P 500 STOCK INDEX"},
{"0643A8","ERCOT - NORTH MONTHLY OFF-PEAK"},
{"06439R","ERCOT NORTH 345KV RT PK FIX"},
{"02165E","EUR 3.5% FUEL OIL RTD CAL SWAP"},
{"02365U","EUR STYLE NATURAL GAS OPTIONS"},
{"099741","EURO FX"},
{"967654","EUROBOB OXY NWE CRK SPR"},
{"061641","FEEDER CATTLE"},
{"040701","FRZN CONCENTRATED ORANGE JUICE"},
{"021A56","FUEL OIL-380cst SING/3.5% RDAM"},
{"111659","GASOLINE BLENDSTOCK (RBOB)"},
{"088691","GOLD"},
{"02165A","GULF # 6 FUEL 3.0% SULFUR SWAP"},
{"86565A","GULF # 6 FUEL OIL CRACK SWAP"},
{"02165R","GULF 3% FUEL OIL BALMO SWAP"},
{"111A31","GULF COAST UNL 87 GAS M2 PL RB"},
{"86465A","GULF JET NY HEAT OIL SPR SWAP"},
{"021A28","GULF NO6 FO 3% v EUR 3.5% RDAM"},
{"86565N","GULF#6 FUELOIL BRENT CRACK SWP"},
{"0233AG","HENRY HUB - TAILGATE LOUISIANA (BASIS)"},
{"0233AH","HENRY HUB - TAILGATE LOUISIANA (INDEX)"},
{"023A55","HENRY HUB LAST DAY FIN"},
{"023P01","HENRY HUB NAT GAS FINL-10000"},
{"023A56","HENRY HUB PENULTIMATE FIN"},
{"03565C","HENRY HUB PENULTIMATE GAS SWAP"},
{"03565B","HENRY HUB SWAP"},
{"023P02","HHUB NAT GAS PENULT FINL-10000"},
{"192651","HOT ROLLED COIL STEEL"},
{"0233AM","HOUSTON SHIP CHANNEL (INDEX)"},
{"023398","HSC FIN BASIS"},
{"195653","IRON ORE 62% FE CFR N CHNA APO"},
{"195651","IRON ORE 62% FE CFR CHINA TSI"},
{"0643B9","ISO NE MASS DA OFF-PK MINI"},
{"0643BA","ISO NE MASS DA PEAK MINI"},
{"0643BF","ISO NE MASS HUB DA OFF-PK"},
{"0643BG","ISO NE MASS HUB DA PEAK"},
{"097741","JAPANESE YEN"},
{"054642","LEAN HOGS"},
{"057642","LIVE CATTLE"},
{"095741","MEXICAN PESO"},
{"0233AQ","MICHIGAN CONSOLIDATED CITYGATE (GENERIC) (BASIS)"},
{"064392","MID-C DAY-AHEAD OFF-PEAK"},
{"064391","MID-C DAY-AHEAD PEAK"},
{"052641","MILK Class III"},
{"021A18","MINI EUR 3.5%FOIL RTD BALMOSWP"},
{"021A17","MINI EUR 3.5%FOIL RTD CAL SWAP"},
{"03265J","Mini Eur Naphtha CIF NWE Swap"},
{"86665E","MINI JAPAN C&F NAPHTHA SWAP FU"},
{"021A35","MINI SING 380 FUEL OIL SWAP"},
{"021A19","MINI SING FUELOIL 180 CAL SWAP"},
{"0643AZ","MISO IN. DAY-AHEAD PEAK"},
{"06439L","MISO IN. REAL-TIME OFF-PEAK"},
{"0643F1","MISO IN. REALTIME OFFPEAK-MINI"},
{"06439K","MISO INDIANA  OFF-PEAK"},
{"0643B3","MISO INDIANA HUB RT PEAK"},
{"0643B1","MISO INDIANA HUB RT PEAK MINI"},
{"244041","MSCI EAFE MINI INDEX"},
{"244042","MSCI EMERGING MKTS MINI INDEX"},
{"06665R","MT BELV NAT GASOLINE OPIS SWAP"},
{"06665Q","MT BELV NORM BUTANE OPIS"},
{"06665P","MT BELVIEU ETHANE OPIS"},
{"06665O","MT BELVIEU LDH PROPANE (OPIS)"},
{"86665A","NAPHTHA CRACK SPR SWAP"},
{"20974+","NASDAQ-100 Consolidated"},
{"209742","NASDAQ-100 STOCK INDEX (MINI)"},
{"023651","NATURAL GAS"},
{"023391","NATURAL GAS ICE HENRY HUB"},
{"0233AW","NATURAL GAS INDEX: ALGONQUIN CITY GATES"},
{"023392","NATURAL GAS PENULTIMATE ICE"},
{"0233B1","NATURAL GAS PIPELINE TEXOK (BASIS)"},
{"0233AY","NATURAL GAS PIPELINE-MID-CONTINENT POOL PIN (BASIS)"},
{"112741","NEW ZEALAND DOLLAR"},
{"240741","NIKKEI STOCK AVERAGE"},
{"240743","NIKKEI STOCK AVERAGE YEN DENOM"},
{"00639W","NJ SRECS VINTAGE 2017"},
{"00639X","NJ SRECS VINTAGE 2018"},
{"0063A3","NJ SRECS VINTAGE 2019"},
{"0063A4","NJ SRECS VINTAGE 2020"},
{"052642","NON FAT DRY MILK"},
{"0233BB","NORTHERN NATURAL GAS - VENTURA (BASIS)"},
{"0233BC","NORTHWEST PIPELINE - CANADIAN BORDER (BASIS)"},
{"023395","NWP ROCKIES FIN BASIS"},
{"02165B","NY RES FUEL 1.0% SULFUR SWAP"},
{"0643BZ","NYISO ZONE A DA OFF-PK"},
{"0643BY","NYISO ZONE A DA PEAK"},
{"064C75","NYISO ZONE A DAY AHEAD OFFPEAK"},
{"064C74","NYISO ZONE A DAY AHEAD PEAK MI"},
{"0643AP","NYISO ZONE C DA PEAK"},
{"0643C8","NYISO ZONE F PEAK MONTHLY"},
{"0643C4","NYISO ZONE G DA OFF-PK"},
{"0643C3","NYISO ZONE G DA PEAK"},
{"064C77","NYISO ZONE G DAY AHEAD OFFPEAK"},
{"064C76","NYISO ZONE G DAY AHEAD PEAK MI"},
{"0643BW","NYISO ZONE J DA PEAK"},
{"064C79","NYISO ZONE J DAY AHEAD OFFPEAK"},
{"064C78","NYISO ZONE J DAY AHEAD PEAK MI"},
{"004603","OATS"},
{"0233BH","PACIFIC GAS TRANSMISSION - MALIN (BASIS)"},
{"075651","PALLADIUM"},
{"0643CC","PALO VERDE DA OFF-PK"},
{"0643CB","PALO VERDE DA PEAK"},
{"0233BL","PANHANDLE EASTERN- POOL GAS (BASIS)"},
{"023394","PG&E CITYGATE FIN BASIS"},
{"064A64","PJM AEP DAY HUB 5 MW PEAK SWAP"},
{"06439F","PJM AEP DAYTON DA PEAK"},
{"06439C","PJM AEP DAYTON HUB DA OFF-PK"},
{"064A80","PJM AEP DAYTON OFF PEAK SWAP"},
{"064C86","PJM AEP DAYTON REAL PEAK-MINI"},
{"06439A","PJM AEP DAYTON RT OFF-PK"},
{"06439B","PJM AEP DAYTON RT PEAK FIXED"},
{"0643CJ","PJM BGE ZONE DAY AHEAD OFF PEAK MONTHLY"},
{"0643CK","PJM BGE ZONE DAY AHEAD PEAK MONTHLY"},
{"0643CU","PJM JCPL ZONE DAY-AHEAD PEAK"},
{"0643BC","PJM N. IL HUB DA OFF-PK"},
{"0643BE","PJM N. IL HUB DA PEAK"},
{"0643BT","PJM N. IL HUB RT PEAK"},
{"064C88","PJM NI HUB REALTIME PEAK-MINI"},
{"064C87","PJM NI HUB REALTM OFFPEAK-MINI"},
{"0643BS","PJM NI HUB RT OFF-PK"},
{"0643CZ","PJM PECO ZONE DA PEAK"},
{"0643D1","PJM PECO ZONE OFF-PEAK MONTHLY"},
{"0643D4","PJM PEPCO DA PEAK"},
{"0643D8","PJM PPL ZONE DA PEAK"},
{"0643D7","PJM PPL ZONE DAY AHEAD OFF-PEAK MONTHLY"},
{"0643DL","PJM PSEG DAY-AHEAD PEAK"},
{"0643DM","PJM PSEG ZONE DAY-AHEAD OFF-PEAK"},
{"0643CL","PJM RT PEAK CAL 1X"},
{"0063AA","PJM TRI-RECs CLASS 1 Vin 2017"},
{"0063AB","PJM TRI-RECs CLASS 1 Vin 2018"},
{"0063AD","PJM TRI-RECs CLASS 1 Vin 2019"},
{"0643DB","PJM WESTERN HUB DA OFF-PK"},
{"0643DC","PJM WESTERN HUB DA PEAK"},
{"064C52","PJM WESTERN HUB REAL OFF DAY 5"},
{"064394","PJM WESTERN HUB RT OFF"},
{"064A59","PJM WESTERN HUB RT OFF 5 MW"},
{"0643DK","PJM WESTERN HUB RT OFF-PK MINI"},
{"0643DF","PJM WESTERN HUB RT PEAK MINI"},
{"064A58","PJM WESTERN PEAK REAL TIME"},
{"064363","PJM WH REAL TIME PEAK"},
{"064DLX","PJM.AEP-DAYTON HUB_month_off_dap"},
{"064FKB","PJM.AEP-DAYTON HUB_month_off_rtp"},
{"064DLW","PJM.AEP-DAYTON HUB_month_on_dap"},
{"064FKA","PJM.AEP-DAYTON HUB_month_on_rtp"},
{"064DPR","PJM.BGE_month_off_dap"},
{"064DPQ","PJM.BGE_month_on_dap"},
{"064EUZ","PJM.PECO_month_off_dap"},
{"064EUY","PJM.PECO_month_on_dap"},
{"064EVH","PJM.PEPCO_month_off_dap"},
{"064EVG","PJM.PEPCO_month_on_dap"},
{"064EWV","PJM.PPL_month_off_dap"},
{"064EWU","PJM.PPL_month_on_dap"},
{"064EXF","PJM.PSEG_month_off_dap"},
{"064EXE","PJM.PSEG_month_on_dap"},
{"064FHL","PJM.WESTERN HUB_month_off_dap"},
{"064FKF","PJM.WESTERN HUB_month_off_rtp"},
{"064FHK","PJM.WESTERN HUB_month_on_dap"},
{"064FKE","PJM.WESTERN HUB_month_on_rtp"},
{"076651","PLATINUM"},
{"06665G","PROPANE NON-LDH MT BEL SWAP"},
{"058643","RANDOM LENGTH LUMBER"},
{"11165K","RBOB CALENDAR SWAP"},
{"111A41","RBOB GASOLINE/BRENT CRACK SPRD"},
{"0063A1","RGGI VINTAGE 2016"},
{"039601","ROUGH RICE"},
{"86565G","RTD 3.5% FUEL OIL CRK SPD SWP"},
{"23977A","RUSSELL 2000 MINI INDEX FUTURE"},
{"089741","RUSSIAN RUBLE"},
{"13874+","S&P 500 Consolidated"},
{"138741","S&P 500 STOCK INDEX"},
{"084691","SILVER"},
{"02165K","SING 380 FUEL OIL SWAP"},
{"86465C","SING JET KERO GASOIL SPR SWAP"},
{"111A11","SINGAPORE MOGUS 92 SWAP FUTURE"},
{"0233BW","SOCAL (INDEX)"},
{"023393","SOCAL BORDER FIN BASIS"},
{"026603","SOYBEAN MEAL"},
{"007601","SOYBEAN OIL"},
{"005602","SOYBEANS"},
{"064395","SP15 FIN DA PEAK FIXED"},
{"080732","SUGAR NO. 11"},
{"092741","SWISS FRANC"},
{"0233DR","TETCO M2 Basis (Receipts)"},
{"0233CG","TEXAS EASTERN- M3 ZONE (DELIVERED)"},
{"0233CH","TEXAS EASTERN- M3 ZONE (DELIVERED) (BASIS)"},
{"0233CU","TRANSCO ZONE 6 BASIS"},
{"0233CW","TRANSCONTINENTAL GAS- STATION 85 (ZONE 4)"},
{"098662","U.S. DOLLAR INDEX"},
{"020601","U.S. TREASURY BONDS"},
{"043607","ULTRA 10-YEAR U.S. T-NOTES"},
{"020604","ULTRA U.S. TREASURY BONDS"},
{"022A13","UP DOWN GC ULSD VS HO SPR"},
{"1170E1","VIX FUTURES - CBOE FUTURES EXCHANGE"},
{"023399","WAHA FIN BASIS"},
{"001626","WHEAT-HRSpring - MINNEAPOLIS GRAIN EXCHANGE"},
{"001612","WHEAT-HRW"},
{"001602","WHEAT-SRW"},
{"06765A","WTI CRUDE OIL CALENDAR SWAP"}
    };



string COTMarketCode = "099741"; // EURO FX
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorBuffers(3);
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0,ValueBuffer1);
   SetIndexLabel(0, "COT-based indicator value 1");
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1,ValueBuffer2);
   SetIndexLabel(1, "COT-based indicator value 2");
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2,ValueBuffer3);
   SetIndexLabel(2, "COT-based indicator value 3");
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   ArraySetAsSeries(ValueBuffer1, false);
   ArraySetAsSeries(ValueBuffer2, false);
   ArraySetAsSeries(ValueBuffer3, false);
   for(int i = prev_calculated; i < BarsBack; ++i)
   {
        double value1 = iCustom(NULL, PERIOD_CURRENT, "DarkMindFx\\COT\\COTData", COTMarketCode, 0, i);
        double value2 = iCustom(NULL, PERIOD_CURRENT, "DarkMindFx\\COT\\COTData", COTMarketCode, 1, i);
        double value3 = iCustom(NULL, PERIOD_CURRENT, "DarkMindFx\\COT\\COTData", COTMarketCode, 2, i);
        
        ValueBuffer1[rates_total-i-1] = value1;
        ValueBuffer2[rates_total-i-1] = value2;
        ValueBuffer3[rates_total-i-1] = value3;
     
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
