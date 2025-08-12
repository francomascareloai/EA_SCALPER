#property description "VSA Indicator´s Simple Weis Wave " 
#property version "1.04"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_minimum 0 

#property indicator_label1 "Histogram"
#property indicator_type1 DRAW_COLOR_HISTOGRAM
enum ENUM_DISPLAY_DATA
{
total_volume, // Total Volume Wave
range, // Range Wave
Average // Average Volume Ref "Tim Ord" 
};


#property indicator_color1 Red, Aqua
#property indicator_width1 2
input ENUM_DISPLAY_DATA SubDisplayType=total_volume;
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volume Type
input int Direction=15; // Wave Tick´s
input int Percent= 50 ;// Percentage of Bar´s
string indicator_name;
input color Up = clrAqua; // Up Wave Color
input color Dn = clrRed; // Donw Wave Color

int BarStarting;


int PercentTrue;
double HistoBuffer[];
double HistoColorBuffer[];
double ArrowsBuffer[];

int  iRatesTotal;
double tick;

int trend=0;
int MinIndex=1;
int MaxIndex=1;
int LastIndex=1;
double Cumulated=0;
string NAME ="";
int Ext[];
double RangeC[];
int waveconut=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+

int OnInit()
{
ObjectDelete(0,"Line_" + (string)(1));
//--- indicator buffers mapping
SetIndexBuffer(0,HistoBuffer, INDICATOR_DATA);
SetIndexBuffer(1,HistoColorBuffer,INDICATOR_COLOR_INDEX);
PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);

//Specify colors for each index
PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Dn); //Zeroth index -> Blue
PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Up); //First index -> Orange


if (SymbolInfoDouble( _Symbol, SYMBOL_TRADE_TICK_SIZE )> 1) 

tick = Direction * SymbolInfoDouble( _Symbol, SYMBOL_TRADE_TICK_SIZE );
else {
tick = Direction * (SymbolInfoDouble( _Symbol, SYMBOL_TRADE_TICK_SIZE )*1000);
}
if (SymbolInfoDouble( _Symbol, SYMBOL_TRADE_TICK_SIZE) == 1e-05)
tick = Direction;

if (Percent > 100 || Percent < 0 )
{
PercentTrue = 50;
Alert ( " Percentage of Bar´s out Of Range, Select 1..100% ");
}
else
PercentTrue = Percent;


IndicatorSetInteger(INDICATOR_DIGITS,0);

indicator_name="VSA Indicator´s Simple Weis Wave ";
IndicatorSetString(INDICATOR_SHORTNAME,indicator_name);
//---
return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
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
if (true)
{


ArrayResize(Ext, rates_total+1);
ArrayResize(RangeC, rates_total+1);
for (int i=0; i<rates_total; i++)
{
Ext[i] = 0;
HistoBuffer[i] = 0;
HistoColorBuffer[i] =1;
iRatesTotal = rates_total;
RangeC[i] = 0;
}


GetExtremumsByClose(rates_total, close);


BarStarting = (rates_total) - (rates_total *PercentTrue)/100;
for (int i=BarStarting; i<rates_total; i++)
{ 
Cumulated = 0; 
waveconut =0;
if (SubDisplayType==total_volume)
if(InpVolumeType==VOLUME_TICK) 
for (int j=LastIndex+1; j<=i; j++)
Cumulated += (double)tick_volume[j];

else
for (int j=LastIndex+1; j<=i; j++)
Cumulated += (double)volume[j];

else if (SubDisplayType==range){
waveconut +=1;
RangeC[i]=(double)(long)MathAbs((close[i] - close[LastIndex])/_Point + 1);
//if (RangeC[i]<=RangeC[i-1])
// Cumulated= RangeC[i-1];
// else 
Cumulated=RangeC[i]=(i-LastIndex);

}else if (SubDisplayType==Average)

for (int j=LastIndex+1; j<=i; j++)
Cumulated += (double)tick_volume[j]/(i-LastIndex);

else
for (int j=LastIndex+1; j<=i; j++)

Cumulated += (double)volume[j]/ (i-LastIndex);


HistoBuffer[i] = Cumulated;
if (Ext[LastIndex] == 1)
HistoColorBuffer[i] = 0;
else 
HistoColorBuffer[i] = 1;

if (Ext[i]!=0)
LastIndex = i; 
}
}
//--- return value of prev_calculated for next call



return(rates_total);
}





void GetExtremumsByClose(const int rates_total,
const double &close[]
)
{

LastIndex = 1;
MinIndex=1;
MaxIndex=1;
BarStarting = (rates_total) - (rates_total * PercentTrue)/100;
for (int i=BarStarting; i<rates_total; i++)
{
if (close[i] > close[MaxIndex])
MaxIndex = i;
if (close[i] < close[MinIndex])
MinIndex = i;

if ((close[MaxIndex] - close[i])>(tick*_Point))
if ((close[MaxIndex] - close[LastIndex]) > (tick*_Point))
{
if (trend == 1)
Ext[MinIndex] = -1;
Ext[MaxIndex] = 1;
LastIndex = MaxIndex;
MinIndex = i;
trend = 1;
continue;
}
if ((close[i] - close[MinIndex])>(tick*_Point))
if ((close[LastIndex] - close[MinIndex]) > (tick*_Point))
{
if (trend == -1)
Ext[MaxIndex] = 1;
Ext[MinIndex] = -1;
LastIndex = MinIndex;
MaxIndex = i;
trend = -1;
continue;
}
}
}