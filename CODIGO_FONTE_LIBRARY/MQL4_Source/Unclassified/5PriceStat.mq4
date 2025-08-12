//+------------------------------------------------------------------+
//|                                                 			 PriceStat |
//|                               Copyright © 2010-2011, FXMaster.de |
//|     programming & support - Alexey Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010-2011, FXMaster.de"
#property link      "profy.mql@gmail.com | Alex Sergeev"

#property indicator_chart_window
#property indicator_color1 SkyBlue
#property indicator_color2 YellowGreen
#property indicator_color3 Tomato

extern int gTF=1; // требуемый “‘, 0-текущий
extern double Discret=1; // шаг дискретизации шкалы цены
extern double Width=100; // ширина гистограммы (в барах)
extern bool Present=true; // показывать центральную гистограмму (между двум€ вертикал€ми)
extern double Future=1; // множитель дл€ глубины расчета от левой вертикали (в будушее)
extern double Past=1; // множитель дл€ глубины расчета от правой вертикали (в прошлое)
extern bool bVolume=false; // считать покрытие бара с учЄтом Volume

bool first;
string g_inf;
datetime pdt1, pdt2;
string gsID;
//-------------------------------------------------------  init
int init() { first=true; gsID="stat"; pdt1=0; pdt2=0; return(0); }
//-------------------------------------------------------  deinit
int deinit() { ObjectsDeleteAll2(0, OBJ_TREND, gsID); }
//-------------------------------------------------------  start
int start()
{
	g_inf="";
	main();
	Comment(g_inf);
}
//-------------------------------------------------------  main
void main()
{
	string smb=Symbol();
	int tf=Period(); if (gTF!=0) tf=gTF;
	
	string name[]; int n=ObjectSelect(0, OBJ_VLINE, "", name);
	if (n!=2) { INF("- вертикальных линий не 2"); return; }
	double from=ObjectGet(name[0], OBJPROP_TIME1); 
	double to=ObjectGet(name[1], OBJPROP_TIME1);
	
	datetime dt; if (from<to) { dt=from; from=to; to=dt; }
	int w=GetWidth(smb, tf, from, to);

	if (pdt1!=from || pdt2!=to) first=true;
	if (!first) return; // если уже вычисл€ли, то выходим
	first=false; pdt1=from; pdt2=to;
	double hi, lo, pr[]; 

	// пстроили текущее
	if (Present)
	{
		string sID=gsID+"pres";
		datetime dt1=from; datetime dt2=to;
		n=GetStat(smb, tf, dt1, dt2, pr, hi, lo); 
		ObjectsDeleteAll2(0, OBJ_TREND, sID); // зачистили
		SetLine(sID+"Hi", dt1, hi*Point, dt2, hi*Point, indicator_color1, 1, STYLE_DOT, "");
		SetLine(sID+"Lo", dt1, lo*Point, dt2, lo*Point, indicator_color1, 1, STYLE_DOT, "");
		for (int i=0; i<n; i++) SetLine(sID+i+"L", dt1, (i*Discret+lo)*Point, dt1-pr[i]*w, (i*Discret+lo)*Point, indicator_color1, 1, STYLE_SOLID, "");
		for (i=0; i<n; i++) SetLine(sID+i+"R", dt2, (i*Discret+lo)*Point, dt2+pr[i]*w, (i*Discret+lo)*Point, indicator_color1, 1, STYLE_SOLID, "");
	}	
	// построили будущее
	if (Future>0)
	{
		sID=gsID+"future";
		ObjectsDeleteAll2(0, OBJ_TREND, sID); // зачистили
		dt=(from-to)*Future; dt2=from; dt1=from+dt;
		n=GetStat(smb, tf, dt1, dt2, pr, hi, lo);
		SetLine(sID+"Hi", dt1, hi*Point, dt2, hi*Point, indicator_color2, 1, STYLE_DOT, "");
		SetLine(sID+"Lo", dt1, lo*Point, dt2, lo*Point, indicator_color2, 1, STYLE_DOT, "");
		for (i=0; i<n; i++) SetLine(sID+i, dt2, (i*Discret+lo)*Point, dt2+pr[i]*w, (i*Discret+lo)*Point, indicator_color2, 1, STYLE_SOLID, "");
	}
	// построили будущее
	if (Past>0)
	{
		sID=gsID+"past";
		ObjectsDeleteAll2(0, OBJ_TREND, sID); // зачистили
		dt=(from-to)*Past; dt1=to; dt2=to-dt;
		n=GetStat(smb, tf, dt1, dt2, pr, hi, lo);
		SetLine(sID+"Hi", dt1, hi*Point, dt2, hi*Point, indicator_color3, 1, STYLE_DOT, "");
		SetLine(sID+"Lo", dt1, lo*Point, dt2, lo*Point, indicator_color3, 1, STYLE_DOT, "");
		for (i=0; i<n; i++) SetLine(sID+i, dt1, (i*Discret+lo)*Point, dt1-pr[i]*w, (i*Discret+lo)*Point, indicator_color3, 1, STYLE_SOLID, "");
	}
}
//------------------------------------------------------------------ GetWidth
int GetWidth(string smb, int tf, datetime from, datetime to)
{
	int b1=iBarShift(smb, tf, from);
	int b2=iBarShift(smb, tf, to);
	double pr=iHigh(smb, tf, iHighest(smb, tf, MODE_HIGH, b2-b1+1, b1))/Point;

	string name=gsID+"metr";
	if (ObjectFind(name)<0) SetLine(name, from, pr*Point, from-Width*60*Period(), pr*Point, SkyBlue, 3, STYLE_SOLID, "");
	datetime dt1=ObjectGet(name, OBJPROP_TIME1); b1=iBarShift(smb, tf, dt1);
	datetime dt2=ObjectGet(name, OBJPROP_TIME2); b2=iBarShift(smb, tf, dt2);
	int w=MathAbs(b1-b2)*60*tf;
	if (ObjectGet(name, OBJPROP_TIME1)!=from) SetLine(name, from, pr*Point, from-w, pr*Point, SkyBlue, 3, STYLE_SOLID, "");
	return(w);
}
//------------------------------------------------------------------ GetStat
int GetStat(string smb, int tf, datetime from, datetime to, double &pr[], double &hi, double &lo)
{
	// число баров дл€ анализа
	int b1=iBarShift(smb, tf, from);
	int b2=iBarShift(smb, tf, to);
	// крайние точки
	hi=iHigh(smb, tf, iHighest(smb, tf, MODE_HIGH, b2-b1+1, b1))/Point;
	lo=iLow(smb, tf, iLowest(smb, tf, MODE_LOW, b2-b1+1, b1))/Point;
	// размерность
	int n=(hi-lo)/Discret; if (n<=0) { INF("-n==0"); return; }
	INF("n="+n);
	ArrayResize(pr, n); ArrayInitialize(pr, 0);
	for (int b=b1; b<=b2; b++) // просуммировали частоту
	{
		int ll=(iLow(smb, tf, b)/Point-lo)/Discret; int hh=(iHigh(smb, tf, b)/Point-lo)/Discret;
		for (int i=ll; i<=hh; i++) if (!bVolume) pr[i]++; else pr[i]+=iVolume(smb, tf, b); 
	}
	// отъюстировали
	i=ArrayMinimum(pr); double m=pr[i]; for (i=0; i<n; i++) pr[i]-=m-1;
	i=ArrayMaximum(pr); m=pr[i]; for (i=0; i<n; i++) pr[i]=pr[i]/m;
	return(n);
}
//------------------------------------------------------------------ SetLine
void SetLine(string name, datetime dt1, double pr1, datetime dt2, double pr2, color clr, int width, int style, string st)
{
	ObjectCreate(name, OBJ_TREND, 0, 0, 0); ObjectSet(name, OBJPROP_RAY, false);
	ObjectSet(name, OBJPROP_TIME1, dt1); ObjectSet(name, OBJPROP_PRICE1, pr1);
	ObjectSet(name, OBJPROP_TIME2, dt2); ObjectSet(name, OBJPROP_PRICE2, pr2);
	ObjectSet(name, OBJPROP_WIDTH, width); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_STYLE, style);
}
//------------------------------------------------------------------ ObjectSelect
int ObjectSelect(int wnd, int type, string pref, string &name[])
{
	string names[]; int k=0, n=ObjectsTotal(); ArrayResize(names, n);
	for (int i=0; i<n; i++) 
	{
		string st=ObjectName(i);
		if (wnd>=0) if (ObjectFind(st)!=wnd) continue;
		if (type>=0) if (ObjectType(st)!=type) continue;
		if (pref!="") if (StringSubstr(st, 0, StringLen(pref))!=pref) continue;
		names[k]=st; k++;
	}
	ArrayResize(name, k);
	for (i=0; i<k; i++) name[i]=names[i]; return(k);
}
//------------------------------------------------------------------ ObjectsDeleteAll2
void ObjectsDeleteAll2(int wnd=-1, int type=-1, string pref="")
{
	string names[]; int n=ObjectsTotal(); ArrayResize(names, n);
	for (int i=0; i<n; i++) names[i]=ObjectName(i);
	for (i=0; i<n; i++) 
	{
		if (wnd>=0) if (ObjectFind(names[i])!=wnd) continue;
		if (type>=0) if (ObjectType(names[i])!=type) continue;
		if (pref!="") if (StringSubstr(names[i], 0, StringLen(pref))!=pref) continue;
		ObjectDelete(names[i]);
	}
}
//---------------------------------------------------------------   INF
void INF(string st, bool ini=false) { if (ini) g_inf=g_inf+"\n        "+st; else g_inf=g_inf+"\n            "+st; }

