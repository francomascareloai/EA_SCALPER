//+------------------------------------------------------------------+
//|                                          Overdraft_Profit_System |
//|          Copyright � 2014 ������ ����������� ambrela0071@mail.ru |
//|   programming & support - ������ ����������� ambrela0071@mail.ru |
//| 15.11.2014                                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014  ������ �����������"
#property link      "ambrela0071@mail.ru"
//������� ������������ ��� ������������ ������ �� ������ �����, ��� ��������, ��� �������� ��� ��������������� ���������, �
//������� ��� ����, �������������� ��� ����� � ������������.
//��������� ������������� ���������� ������ ���������� �� Forex:

//����������� ������� 20k - ��������� ����� ����� ����� 1/300 � ����.
//�������� ���� �� InstaForex 1000$ - ��������� ����� 1/300 � ����.
//RoboForex �������� ����� Pro.
//���������� ������� � ����������� ������������. 
//������ ���������: (1.24135) - �.�. ���� ������ ����� �����.
//����� ������������ � �� ������ ��������:
//Alpari; FXOpen; AdmiralMarkets, Roboforex � ������.....
//���� ������������� ���������� � ����� ���������� �������� RVD.
//���� ECN, (��������� �����).


//________________________________________
 
//���������� � �����, ��� ��������� � ������ ��������� �������:
//����� �����: 50767
//������������ ������: Investor2015
//IP: 5.9.113.233:443
//________________________________________
//��������! ����� ����� ����� �� � �������, � � ������������ ������� 2008�. ��� ���� ����� ������. 

//������� ������������� ������������:

//________________________________________
//���������� �����:
//��� ���������� ��������� ���� � ������������� ���������� �� 20k ��������� ����� 1/300 � ����.
//������� ������� 50/50
//���� �� ����� �������� 40k � �����:
//������� ������� 35% �� ��������� �������� ������������, � 65% � ������ ���������.
//���� �� ����� �������� 100k � �����:
//������� ������� 30% �� ��������� �������� ������������, � 70% � ������ ���������.

//________________________________________



//�������� �����:

//��� ���� �������� ������ �� 1000$ ��������� ����� 1/300 � ����.
//������� ������ ������� 50/50.
//���� ����������:
//���� � ��� �������� ������ ����� 5-��, ����� ������� ������� ���:
//40% ������������ ��������, � 60% � ������ ���������.
//����� ����� ����� � ���������� � 500$ ��������� �����, ���� �� ��� ������������� ������� �������� � �������.


//________________________________________
//����������� � ������:
//������� ����� �����, ����� ������ �������������?
//������ �������� ���������� ������ � ���, ������ � ������������� ���������� ������ Forex ����������� ��������?
//�������� ����-�������������� � ���, ��� ����� ���������� ����� ���� ������� ������, ��� � ����� ���, ��������, �� ����� �����. ������ ������� ���������� ������ �������, �� ����� ����� �����, ������� �������� ������� �� Forex � ������������� ���������� �� 10 �������� - ����� ����� �������� � ������ ��������.
//������ ���� - ���� �������� ���������� ������������ �� ���������� �������� �������. �����������, � ���� ������ ������ ������ ���� ����. ����� ����� �������������� �����, ��������� � ������������� ���� ����� �� ������. � ����� ����.
//������� ����� ����������?
//��� �������������� � ������������� ������ �������������� ���������� �������� �� ����� Forex ���������� �� ��� ����� ���������� 100% � �����.
//�������� �������, �� ������� ����� �������� ������� �������:
//1	��������� �����;
//2	������� ������ ������������: �������������� ��� �����������;
//3	���������� �������� � ���������� ������.
//��� ��������� �������� ������ �������������� ������������� ���������� �� ������ 100% ����� ��������� ��� �������.
//������������� ���������� �� ������ ��� ������: �������� ��?
//���� �� ������ ���������� ���������������, �� ��� ����� ����� � ���, ��� ���������� ��� ������ � �������� �� ����������. � ������� �������������� ���������� �� ������ ������� �� ���, ��� ��������� � ���������, ������ ����, ���� � �����. ��, �������� ������ �������. �������� ����� ������� � ����� ���������:
//1	����������� ����, ��� ����������� ����� � �������� ������� ��������, ������� ��� ������, ���� � ���������;
//2	���������� �������� ����� ��������� ������ �������������� ������, ������� ��� ����� ����� "������";
//3	������ ����� ��������� �� ������ ��������������, ���� � ���� ��������� ��������, � ���������� ������� �� �������� ��������� � ����� ����� ����������. � ���������, ������������� ���������� ��� ��� ����� �� ������������ ���������� �����������������.
//�� ��� ������ � ������������� ���������� �� ������ ������������. �� � ����� ����� �������� � ���, ��� ����-�������������� - ������� �������� ���������� ������.
//� �� �� �����, � ������ ��� ������������� ���������� ��������������� ����� ���, ������� ��, ����� ������� �� ������. ��� �� ���������� ��������, ������� ������������ �������� ����������� �� 15 �����.
//�������, ����� ��� ��� ��������� ������� "��� ����� � ������������� ���������� ������", ����� ��������, ������ �� �� ����� �� ���� ������������ �����.
//��������, ��� ������, ����� ��� �������, ��� ����� ������������� ���������� �� Forex, �� ������� ������� ��� ���� ���������� �������, ����� �� ���� ����������.


//��������:
//E-mail: Ambrela0071@yandex.ru
//Skype: OverdraftScalpSystem
//QIP: 444048899

#property strict

#include <stdlib.mqh>

#define OP_BALANCE	6
#define OP_MARKET		8
#define OP_ALL			-1

int Magic=1234;/*Magic*/ // ����� ������� ������� ��
input bool bMarketExec=true;/*bMarketExec*/ // � ������� �� ������� ������-����������
input int Slip=0;/*Slip*/ // ��������������� ��� �������� ����������
input string inf1="// ������";
input bool bRevers=true;/*bRevers*/ // true -��������� �������� ������ �������������� �������� / false-� ��� �� �����������
input int OpenMode=1;/*OpenMode*/ // ����� ����� � �����. 
											//	=0 �� �� wlxFractals ���������, 
											//	=1 �� ���� �� Acceleration. 
											//	=2 �� ���� �� �������������.
											//	=3 �� ���� � ������ �� OpenMode=1 ����� ��������, ���� �� OpenMode=2.
											//	=4 �� ���� � ������ OpenMode =0 ����� �������� OpenMode =1 ����� �������� OpenMode =2.     

input double Lot=0.1;/*Lot*/ // ��� ������. ���� =0, �� ���������� ��
input double MM=2;/*MM*/ //������� �� ������� ��� ����.
input double Acceleration=1.5;/*Acceleration*/ // ����������� �������� ����
input int BarVolatile=24;/*BarVolatile*/ // ����� ����� ��� ������� �������������
input double kVolatile=0.0;/*kVolatile*/ //��������� ������������� 
input double LotKoef=2;/*LotKoef*/ // ��������� ��� ���������� ���� ����� ������, ���� =0, �� ��������
input int LotKoefStart=0;/*LotKoefStart*/ // ����� ��������� �������, ����� �������� �������� ������� ��� �� LotKoef
input double VDeposit=5000;/*VDeposit*/ // ������ ���������� ����.�������
input int nDay=14;/*nDay*/ //  ����� ��������� ���� ��� ������� �������� ���� ���������.
input int SpreadMode=0;/*SpreadMode*/ // ����� ����������� ������ 0/1/2/3
input int FixSpread=5;/*FixSpread*/ // ������ ������������� ����������� ������ ��� SpreadMode=3
input int AvgSpreadCount=20;/*AvgSpreadCount*/   // ���������� ��������� �������� ������ ��� ���������� �������� ������
input double AvgSpreadKoef=2;/*AvgSpreadKoef*/  //  ��������� ��� ������ �����������
input int CloseMode=2;/*CloseMode*/ // ����� �������� 
												// =0 �� �������� �� ������������ ��/��,
												// =1 �� �������� �� �������� SL/TP
												// =2 �� ������ ��/�� = ������ ������������� * SLVolatile (������������� ����������� ���������� ��� ��� ��������)
												// =3 �� ������������ �� CloseMode=0,1 - �� ���������� ����� �� ���, ������� ���������.
												// =4 �� ������������ �� CloseMode=0,1,2 - �� ���������� ����� �� ���, ������� ���������.
input int TP=60;/*TP*/ // ������ ����������� ��� CloseMode=2. ���� =0, �� �� ������
input int SL=60;/*SL*/ // ������ �������� ��� CloseMode=2. ���� =0, �� �� ������
input double StopVolatile=2;/*StopVolatile*/ // ����������� ��� ���������� ������ �� �������������
input bool bTralSL=true;/*bTralSL*/ // ���������� ���� �� SL
input bool bVTralTP=true;/*bVTralTP*/ // =true - ��������� ����� ����������� ����.������ �� ProcentProfit/CloseProcentProfit
input double ProcentProfit=80;/*ProcentProfit*/ // ������� ������� ����������� ��� ����� �������� � �������, ���� =0, �� ���� ��������.
input double CloseProcentProfit=30;/*CloseProcentProfit*/ // ������� ��� ������� �������� ��� �����, ���� =0, �� ���� ��������.
input string inf2="// ���������";
input string IndName="wlxFractals";
input int Equals = 20;/*Equals*/ // ������������ ����� ������ ������ ����� � ������ ��� ������������ ��������
input int nLeftUp = 20;/*nLeftUp*/  // ����������� ����� ����� ����� ��� �������� �����
input int nRightUp = 20;/*nRightUp*/ // ����������� ����� ����� ������ ��� �������� �����
input int nLeftDown = 20;/*nLeftDown*/ // ����������� ����� ����� ����� ��� �������� ����
input int nRightDown = 20;/*nRightDown*/ // // ����������� ����� ����� ������ ��� �������� ����
input string inf3="// ����";
input bool bVirtInfo=true;/*bVirtInfo*/ // ���������� �� ����� ���� ������ ����.�������.
input bool bRealInfo=true;/*bRealInfo*/ // ���������� �� ����� ���� ������ ����.�������.
input bool bSpreadInfo=true;/*bSpreadInfo*/ // ���������� �� ����� ���� ������ ��� �����
input bool bShowComment=true;/*bShowComment*/ // ���������� ���� � ������� �� �����
input bool bShowVOrder=true;/*bShowVOrder*/ // ���������� ����������� ������ �� �����

// ��������� �����������
string sID; // ID EA ��� ���������� ����������
bool bTesting; // ���� ��� ������� ������
// ���� ��� ������
double FreezLvl, StopLvl, Spread, Pnt, _Pnt, _Bid, _Ask, LotStep, LotSize, MaxLot, MinLot, TickSize, TickVal, ProfitCalcMode; int _Digit;
string g_inf;
double spread[]; int is=0;
double pBid=0; datetime fdtBid=0; int nBid=0; // ��� Acceleration
double pHi=0, pLo=0; // ��� Volatile
//------------------------------------------------------------------ init
int OnInit()
{
	ArrayResize(spread, fmax(AvgSpreadCount,1)); is=0; ArrayInitialize(spread, 0);
	bTesting=true;
	pBid=0; fdtBid=0; nBid=0; // ��� Acceleration
	pHi=0; pLo=0; // ��� Volatile
	
	return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------ deinit
void OnDeinit(const int reason)
{
	if (IsTesting() || IsOptimization()) GlobalVariablesDeleteAll(sID);
	ObjectsDeleteAll2(0, -1, sID); // ������� �������
}
//------------------------------------------------------------------ start
void OnTick()
{
	string smb=Symbol();
	int tf=Period();
	sID=smb+ITS(IsDemo())+ITS(IsTesting())+ITS(IsOptimization())+"."+ITS(Magic);
	if (bTesting && (IsTesting() || IsOptimization())) { GlobalVariablesDeleteAll(sID); bTesting=false; }
	
	g_inf="";
	INF(WindowExpertName()+"  "+TTS(TimeCurrent()), true);
	if (!IsConnected()) { INF("- connected ERROR!"); Print("- connected ERROR!"); } else INF("+ connected  OK");
	if (!IsTradeAllowed()) { INF("- trade NOT allowed!"); return; } else INF("+ trade allowed  OK");
	if (IsTradeContextBusy()) INF("- trade context BUSY!"); else INF("+ trade context ready  OK");

	AddSpread(); // ��������� � ������� �����
	CheckAcceleration(); // ������������ ��������
	CheckVolatile(); // ������������ �������������
	
	main(Magic, smb, tf);
	INF("==============================", true);
	
	if (bShowComment) Comment(g_inf);
}
//------------------------------------------------------------------ main
void main(int SysID, string smb, int tf)
{	
	RefreshParam(smb); 
	OpenVPos(SysID, smb, tf); // �. �������� ������������ ������
	CloseVPos(SysID, smb, tf); // �. �������� ������������ ������
	TralVPos(SysID, smb); // �. ���� ����������� ����.������
	OpenRPos(SysID, smb, tf); // �. �������� ��������� ������
	CloseRPos(SysID, smb, tf); // �. �������� ��������� ������
	TralRPos(SysID, smb); // �. ����������� �������� ��������� ������ 
	int y=20;
	VirtInfo(SysID, smb, tf, y);
	RealInfo(SysID, smb, y);
	SpreadInfo(SysID, smb, y);
}
//---------------------------------------------------------------   CheckOpenSignal
int CheckOpenSignal(string smb, int tf, int &i)
{
	INF("+��������� ������ �������� ������������ ������", true); 
	int n=iBars(smb, tf);
	for (i=0; i<n; i++)
	{
		double f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, 0, i); if (f>0 && f!=EMPTY_VALUE) return(OP_BUY); // Buy: ���� ��������� ������� wlxFractals  �����
		f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, 1, i); if (f>0 && f!=EMPTY_VALUE) return(OP_SELL); // Sell: ���� ��������� ������� wlxFractals  ������� 
	}
	return(-1);
}
//---------------------------------------------------------------   CheckOpenSignal
double CountStopSize(int dir, string smb, int tf)
{
	datetime dt=iTime(smb, PERIOD_H1, nDay*24-1); // ����� ��������� ������
	INF("+������ �������� ���� ���� �� "+ITS(nDay)+" ���� (�� "+TTS(dt)+")", true); 
	int i=0;
	double avg=0; int n=0;
	while (iTime(smb, tf, i)>dt) // ���� � ��������� nDay
	{
		double f1=GetNextFrac(ADIR(dir), smb, tf, i); if (f1<=0) break; i++;
		double f2=GetNextFrac(dir, smb, tf, i); if (f2<=0) break; i++;
		if (iTime(smb, tf, i)<dt) break;
		avg+=fabs(f1-f2); n++;
	}
	INF("����� ����������="+ITS(n)+" avg="+DTS(avg));
	if (n<=0) return(0); // ���� �� ����� �� ������ ����������, �� ������
	return(avg/n); // ����� ������� �������
}
//------------------------------------------------------------------ GetNextFrac
double GetNextFrac(int dir, string smb, int tf, int &b)
{
	int n=iBars(smb, tf);
	for (int i=b; i<n; i++) { double f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, dir, i); if (f>0 && f!=EMPTY_VALUE) { b=i; return(f); } }
	return(-1);
}
//------------------------------------------------------------------ OpenVPos
void OpenVPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+�. �������� ������������ ������", true); 
	if (SpreadMode==2 && is<AvgSpreadCount-1) { INF("���� ���������� "+ITS(AvgSpreadCount)+" ����� ��� ������"); return; }
	if (CountOrders(-1, SysID, smb)!=0) { INF("�������� ������ ��� �������. ���� ��������"); return; }
	
	int nmode=-1, ib=-1;
	int dir=GetOpenModeDir(smb, tf, OpenMode, nmode, ib); if (dir<0) { INF("����������� �������� ����.������ �� ����������"); return; }
	
	// ���� ���������� �����
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	bool b=false; string sid=""; int id=0;
	for (int i=0; i<n; i++)
	{
		int vdir=(int)GetGV(name[i]); if (vdir!=OP_BUY && vdir!=OP_SELL) continue;
		sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue;
		if (bShowVOrder) { DrawOrder(sid, id, (int)GetGV(name[i]), GetGV(sid+".op"), 0, 0); DrawDeal(sid, id, (int)GetGV(name[i]), Lot, GetGV(sid+".op"), (datetime)GetGV(sid+".dop"), 0, 0, 0, 0); }
		b=true; break; 
	}	//
	if (b) { INF("���� �������� V ������ #"+ITS(id)); return; }
	Print("������� "+ITS(n)+" ����.������� � �������. �������� ���.");
	if (ib>0) Print("�� ���� "+TTS(iTime(smb, tf, ib))+" ��� �� ���������.");
	
	double op=NPR(dir);	
	
	id=int(GetTickCount()+MathRand()); // "�����" ������������ ������
	sid=sID+"VO."+ITS(id);
	SetGV(sID+"VOrder."+ITS(id), dir); // ���
	double nlot=Lot; if (Lot<=0) nlot=(AccountBalance()/1000.0)*MM/100.0; nlot=NL(nlot); // ���������� � ����������� ���
	double lot=NL(nlot);
	if (LotKoef!=0) // ����������� ���������� ������
	{
		double plot=GetGV(sID+"Lot"); int No=(int)GetGV(sID+"N");
		double lpip=0; int lid=VLastOrder(lpip);
		Print("���������� ����� ����.������="+DTS(lpip/(Pnt*_Pnt),0)+" ��������� ���="+DTS(plot,2)+"  ����� �������="+ITS(No));
		// ���� ������, �� �������� ��� �� �����, ����� ����� ��� ��������� � LotKoef ��� � ��������� ������� ������
		if (lpip>=0) { SetGV(sID+"Lot", nlot); SetGV(sID+"N", 0); }
		else { if (plot>0) lot=NL(plot*MathPow(LotKoef, fmax(No+1-LotKoefStart,0))); SetGV(sID+"N", No+1); }
		double vbal=CountVBalance();
		if (vbal-(AccountBalance()-AccountFreeMarginCheck(smb, dir, lot))<=0)
		{
			Print("����.������="+DTS(vbal,2)+", ���������� ��� �� ��������� � ��������� ������ �� VDeposit="+DTS(VDeposit,2));
			int did=int(GetTickCount()+MathRand()); // "�����" ������ ������������ ����������
			SetGV(sID+"VOrder."+ITS(did), OP_BALANCE); SetGV(sID+"VO."+ITS(did)+".prof", VDeposit); // ��������� ������
			SetGV(sID+"Lot", nlot); SetGV(sID+"N", 0); lot=nlot;
		}
	}
	// ������� ����.�����
	MqlDateTime md; datetime dop=TimeCurrent(md); // ������� �����
	SetGV(sid+".op", op); SetGV(sid+".dop", dop); SetGV(sid+".lot", lot); DelGV(sid+".cl"); // ��������� ��������� ������
	string txt="Open V "+smb+" "+OTS(dir)+"#"+ITS(id)+" | op="+DTS(op)+" OpenMode="+ITS(OpenMode);
	INF(txt); Print("+"+txt);
	SetGV(sID+"Time", iTime(smb, tf, ib)); Print("��������� ����� �������� ������� "+TTS(iTime(smb, tf, ib)));
	SetGV(sID+"VLast", id); // ��������� ����� � ����� ��������
	SetGV(sID+"Mode", nmode);
	pLo=0; pHi=0; // �������� �������������
	if (bShowVOrder) { DrawOrder(sid, id, dir, op, 0, 0); DrawDeal(sid, id, dir, Lot, op, dop, 0, 0, 0, 0); }
}
//------------------------------------------------------------------ LastOrder
int GetOpenModeDir(string smb, int tf, int mode, int &nmode, int &ib)
{
	INF("+OpenMode="+ITS(OpenMode));
	if (mode==0)
	{
		int dir=CheckOpenSignal(smb, tf, ib); if (dir<0) { INF("-���� ������� ��������..."); return(-1); }
		if (CheckGV(sID+"Time")) if (GetGV(sID+"Time")>=iTime(smb, tf, ib)) { INF("�� ���� ������� ��� ��������� �����"); return(-1); }
		return(dir);
	}
	MqlDateTime md; datetime dop=TimeCurrent(md); // ������� �����
	if (mode==1)
	{
		double a=0; if (dop-fdtBid>0) a=(nBid*1.0)/(dop-fdtBid);
		if (fabs(a)>=Acceleration) return(a>0?OP_BUY:OP_SELL);
		else { INF("��������="+DTS(a)+" < "+DTS(Acceleration,2)+" | tick="+ITS(nBid)+"  pBid="+DTS(pBid)+" Bid="+DTS(_Bid)+" sec="+ITS(dop-fdtBid)); return(-1); }
	}
	if (mode==2)
	{
		double v=CountVolatile(smb, tf)*kVolatile;
		if (_Bid>pLo+v && pLo>0) return(OP_BUY);
		if (_Bid<pHi-v && pHi>0) return(OP_SELL);
		INF("�������������*k "+DTS(v/(Pnt*_Pnt),0)+" � ��������� pHi="+DTS(pHi)+" / pLo="+DTS(pLo)+" / Bid="+DTS(_Bid)); return(-1);
	}
	
	int pmode=CheckGV(sID+"Mode")?(int)GetGV(sID+"Mode"):0;	
	if (mode==3)
	{
		nmode=2; 
		if (pmode!=2) return(GetOpenModeDir(smb, tf, 1, nmode, ib)); else return(GetOpenModeDir(smb, tf, 2, nmode, ib)); 
	}
	if (mode==4)
	{
		nmode=2; 
		if (pmode!=2) { if (pmode!=1) { nmode=1; return(GetOpenModeDir(smb, tf, 0, nmode, ib)); } else { nmode=2; return(GetOpenModeDir(smb, tf, 1, nmode, ib)); } }
		else return(GetOpenModeDir(smb, tf, 2, nmode, ib)); 
	}
	return(-1);
}
//------------------------------------------------------------------ LastOrder
int VLastOrder(double &pip)
{
	if (!CheckGV(sID+"VLast")) return(-1);
	int id=(int)GetGV(sID+"VLast");
	string sid=sID+"VO."+ITS(id);
	int dir=(int)GetGV(sID+"VOrder."+ITS(id));
	double op=GetGV(sid+".op"), cl=GetGV(sid+".cl");
	if (cl>0) pip=(cl-op)*SD(dir);
	return(id);
}
//------------------------------------------------------------------ CloseVPos
void CloseVPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+�. �������� ������������ ������", true);
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	MqlDateTime md; datetime dcl=TimeCurrent(md); // ������� �����
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);
	for (int i=0; i<n; i++)
	{
		int dir=(int)GetGV(name[i]); if (dir!=OP_BUY && dir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue; // ��� ������
		double apr=APR(dir);
		double op=GetGV(sid+".op"); datetime dop=(datetime)GetGV(sid+".dop");
		double sl=CheckGV(sid+".sl")?GetGV(sid+".sl"):0, tp=CheckGV(sid+".tp")?GetGV(sid+".tp"):0;
		if (bShowVOrder) { DrawOrder(sid, id, dir, op, sl, tp); DrawDeal(sid, id, dir, Lot, op, dop, 0, 0, sl, tp); }
		
		bool b=false;
		//1. �������� �� ������
		if (sl>0 && (sl-apr)*SD(dir)>=0) b=true;
		if (tp>0 && (apr-tp)*SD(dir)>=0) b=true;
		if (!b) { if (tp>0) INF("�� �� �������� "+DTS((tp-apr)*SD(dir)/(Pnt*_Pnt),0)+" �."); if (sl>0) INF("�� �� �������� "+DTS((apr-sl)*SD(dir)/(Pnt*_Pnt),0)+" �."); } // ���� ����� ���� ��������� �� ��� ��
		if (!b)
		{
			if (FindComment(ticketO, no, ITS(id)+"|")>0) { INF("����� ��� #"+ITS(id)+" ��� ������"); continue; }
			if (FindComment(ticketH, nh, ITS(id)+"|")<=0) { INF("����� ��� #"+ITS(id)+" ��� �� ������/�� ������"); continue; }
		}
				
		SetGV(sid+".cl", apr); SetGV(sid+".dcl", dcl); // ������� �����
		string txt="Close V "+smb+" "+OTS(dir)+"#"+ITS(id)+" | cl="+DTS(apr);
		INF(txt); Print("+"+txt);
		if (bShowVOrder) { DrawDeal(sid, id, dir, Lot, op, dop, apr, dcl, sl, tp); ObjectsDeleteAll2(0, OBJ_HLINE, sid); }
	}	
}
//------------------------------------------------------------------ TralVPos
void TralVPos(int SysID, string smb)
{
	INF(""); 
	INF("+�. ���� ����������� ����. ������ ", true);
	if ((ProcentProfit<=0 || CloseProcentProfit<=0) || !bVTralTP) { INF("-�� ����������. ProcentProfit ��� CloseProcentProfit � bVTralSL ==0"); return; }
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	for (int i=0; i<n; i++)
	{
		int dir=(int)GetGV(name[i]); if (dir!=OP_BUY && dir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue; // ��� ������
		double apr=APR(dir);
		double cop=GetGV(sid+".op");
		double csl=CheckGV(sid+".sl")?GetGV(sid+".sl"):0, ctp=CheckGV(sid+".tp")?GetGV(sid+".tp"):0;
		double wsl=(cop-csl)*SD(dir)*ProcentProfit/100; if (wsl<=0) { INF("� ����.������ #"+ITS(id)+" �� ���������� �������"); continue; }
		if ((cop-apr)*SD(dir)<wsl) INF("���� ���������� "+DTS(wsl/(Pnt*_Pnt),0)+" �. ������. �������� "+DTS((wsl-(cop-apr)*SD(dir))/(Pnt*_Pnt),0));
		else
		{
			double tp=cop-wsl*(1-CloseProcentProfit/100)*SD(dir);
			if ((ctp-tp)*SD(dir)>0 || ctp==NP(0))
			{
				string txt="Tral V "+smb+" "+OTS(dir)+" #"+ITS(id)+" ctp="+DTS(ctp)+"->"+DTS(tp)+"  id="+ITS(SysID);
				INF(txt); Print("+"+txt); SetGV(sid+".tp", tp);
			}
		}
	}
}
//------------------------------------------------------------------ OpenRPos
void OpenRPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+�. �������� ��������� ������", true); 
	string name[]; int n=SelectGV(sID+"VOrder.", name); if (n<=0) { INF("���� V ������"); return; }
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);
	for (int i=0; i<n; i++)
	{
		int vdir=(int)GetGV(name[i]); if (vdir!=OP_BUY && vdir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid);
		double vop=GetGV(sID+"VO."+sid+".op"); // ���� �������� ������������
		if (CheckGV(sID+"VO."+sid+".cl")) continue; // ����������� ����� ��� ������
		if (!CheckGV(sID+"VO."+sid+".lot")) { double lot=Lot; if (Lot<=0) lot=AccountBalance()*MM/100.0; lot=NL(lot); SetGV(sID+"VO."+sid+".lot", lot); }
		double lot=GetGV(sID+"VO."+sid+".lot"); lot=NL(lot);
		int dir=vdir; if (bRevers) dir=ADIR(dir); // ����������� �����
		if (FindComment(ticketO, no, sid+"|")>0) { INF("����� ��� #"+sid+" ��� ������"); continue; }
		if (FindComment(ticketH, nh, sid+"|")>0) { INF("����� ��� #"+sid+" ��� ������"); continue; }
		double op=NPR(dir), apr=APR(dir);
		int comp=0;
		if (bRevers)
		{
			comp=GetComp();
			if (comp>0 && (vop-op)*SD(dir)<comp*Pnt*_Pnt) { INF("�������� ����� "+DTS((comp-(vop-op)*SD(dir)/(Pnt*_Pnt)),0)+" �."); continue; }
		}
		lot=NL(lot); // ����������� ���
		comp=int(fabs(vop-op)/(Pnt*_Pnt));

		double d=CountStopSize(dir, smb, tf); string txt=("����������� ������ ��/��="+DTS(d/(Pnt*_Pnt),0)+" �.");
		INF(txt); if (d<=0) { INF("-�������� ������ ��/��"); continue; }
		Print(txt); // ��� ������ �����
		double v=CountVolatile(smb, tf);

		double tp=0, sl=0;
		double dtp0=0, dsl0=0; if (CloseMode==0) { dtp0=d; dsl0=d; }
		double dtp1=0, dsl1=0; if (CloseMode==1 || CloseMode==3 || CloseMode==4) { dtp1=TP*Pnt*_Pnt; dsl1=SL*Pnt*_Pnt; }
		double dtp2=0, dsl2=0; if (CloseMode==2 || CloseMode==4) { dtp2=v*StopVolatile; dsl2=v*StopVolatile; }
		if (CloseMode==0) { tp=dtp0; sl=dsl0; }
		if (CloseMode==1) { tp=dtp1; sl=dsl1; }
		if (CloseMode==2) { tp=dtp2; sl=dsl2; }
		if (CloseMode==3) { if (dtp0>0) { if (dtp1>0) tp=fmin(dtp0, dtp1); else tp=dtp0; } else tp=dtp1; }
		if (CloseMode==4)
		{
			if (dtp0>0) { if (dtp1>0) tp=fmin(dtp0, dtp1); else tp=dtp0; } else tp=dtp1;
			if (dtp2>0) { if (tp>0) tp=fmin(dtp2, tp); else tp=dtp2; }
		}
		tp=NTP(dir, op, apr, tp/(Pnt*_Pnt), StopLvl);
		sl=NSL(dir, op, apr, sl/(Pnt*_Pnt), StopLvl);
		
		int ticket=-1;
		if (bMarketExec) ticket=OrderSend(smb, dir, lot, op, Slip, 0, 0, sid+"|"+ITS(comp), SysID, 0, OTC(dir));
		else ticket=OrderSend(smb, dir, lot, op, Slip, sl, tp, sid+"|"+ITS(comp), SysID, 0, OTC(dir));
		txt="Open R "+smb+" "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" lot="+DTS(lot, 2)+" � ����. id="+sid+" ���������.="+ITS(comp)+" |  magic="+ITS(SysID)+" | CloseMode="+ITS(CloseMode);
		INF(txt);
		if (ticket<=0) ErrorHandle(GetLastError(), -1, SysID, txt);
		else
		{
			Print("+"+txt);
			if (bMarketExec) PlaceStop(ticket, dir, SysID, smb, op, sl, tp);
			// ������ ����� � ������������
			if (vdir==OP_BUY)
			{
				if (sl>0 && sl<=vop) SetGV(sID+"VO."+sid+".sl", sl); else if (tp>0 && tp<=vop) SetGV(sID+"VO."+sid+".sl", tp);
				if (tp>0 && tp>=vop) SetGV(sID+"VO."+sid+".tp", tp); else if (sl>0 && sl>=vop) SetGV(sID+"VO."+sid+".tp", sl);
			}
			else if (vdir==OP_SELL)
			{
				if (sl>0 && sl>=vop) SetGV(sID+"VO."+sid+".sl", sl); else if (tp>0 && tp>=vop) SetGV(sID+"VO."+sid+".sl", tp);
				if (tp>0 && tp<=vop) SetGV(sID+"VO."+sid+".tp", tp); else if (sl>0 && sl<=vop) SetGV(sID+"VO."+sid+".tp", sl);
			}
		}
	}
}
//------------------------------------------------------------------ CloseRPos
void CloseRPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+�. �������� ��������� ������", true);
	int ticket[], n=GetTickets(-1, SysID, smb, ticket); if (n<=0) { INF("wait orders"); return; }
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { INF("������ ��������� ������ "+ITS(ticket[i])); continue; }
		int dir=OrderType(); double prof=OrderProfit(); double apr=APR(dir);
		int c=StringFind(OrderComment(), "|"); if (c<0) { INF("������ ����������� "+OrderComment()); continue; }// ����� ������ ���������� ��� ����� ��� ������
		string sid=StringSubstr(OrderComment(), 0, c);
		if (!CheckGV(sID+"VO."+sid+".cl")) { INF("#"+sid+" ��� ������ (��� #"+ITS(ticket[i])+")"); continue; } // ����� ��� �� ������
		string txt="Close R "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+"cl="+DTS(apr)+" prof="+DTS(OrderProfit(),2)+" pip="+DTS((OrderClosePrice()-OrderOpenPrice())/(Pnt*_Pnt),0);
		INF(txt);
		if (!OrderClose(ticket[i], OrderLots(), apr, Slip, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else Print(txt);
	}
}
//------------------------------------------------------------------ TralRPos
void TralRPos(int SysID, string smb)
{
	INF(""); 
	INF("+�. ����������� �������� ��������� ������", true);
	if ((ProcentProfit<=0 || CloseProcentProfit<=0) && (SL<=0 || !bTralSL)) { INF("-�� ����������. ProcentProfit ��� CloseProcentProfit � SL ==0"); return; }
	int ticket[], n=GetTickets(-1, SysID, smb, ticket); if (n<=0) { INF("wait orders"); return; }
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { INF("������ ��������� ������ "+ITS(ticket[i])); continue; }
		int dir=OrderType(); RefreshParam(smb); double apr=APR(dir); // �������� ���������
		double csl=ND(OrderStopLoss()); double cop=ND(OrderOpenPrice()); double ctp=ND(OrderTakeProfit());
		if (MathAbs(ctp-apr)<=FreezLvl || MathAbs(csl-apr)<=FreezLvl) { INF(OTS(dir)+"#"+ITS(ticket[i])+" freezed"); continue; }
		if (ProcentProfit>0 && CloseProcentProfit>0)
		{
			double wtp=(ctp-cop)*SD(dir)*ProcentProfit/100;
			if (wtp<=0) { INF("� ������ #"+ITS(ticket[i])+" �� ���������� ����������"); }
			else
			{
				if ((apr-cop)*SD(dir)<wtp) INF("���� ���������� "+DTS(wtp/(Pnt*_Pnt),0)+" �. �������. �������� "+DTS((wtp-(apr-cop)*SD(dir))/(Pnt*_Pnt),0));
				else
				{
					double sl=NSL(dir, apr, apr, cop+wtp*(1-CloseProcentProfit/100)*SD(dir), StopLvl, false);
					if ((sl-cop)*SD(dir)>0 && ((sl-csl)*SD(dir)>0 || csl==NP(0)))
					{
						string txt="Tral R "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+" csl="+DTS(csl)+"->"+DTS(sl)+"  id="+ITS(SysID);
						INF(txt);
						if (!OrderModify(ticket[i], cop, sl, ctp, 0, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else { Print("+"+txt); csl=sl; }
					}
				}
			}
		}
		if (bTralSL && SL>0)
		{
			double sl=NSL(dir, apr, apr, SL, StopLvl);
			if ((sl-csl)*SD(dir)>0 || csl==NP(0))
			{
				string txt="TralSL R (�� SL � bTralSL) "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+" csl="+DTS(csl)+"->"+DTS(sl)+"  id="+ITS(SysID);
				INF(txt);
				if (!OrderModify(ticket[i], cop, sl, ctp, 0, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else Print("+"+txt);
			}
		}
	}
}
//------------------------------------------------------------------ PlaceStop
void PlaceStop(int ticket, int dir, int SysID, string smb, double op, double nsl, double ntp)
{
	RefreshParam(smb); double apr=APR(dir);
	double sl=NSL(dir, op, apr, nsl, StopLvl, false);
	double tp=NTP(dir, op, apr, ntp, StopLvl, false);
	string txt="Place stops to "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" apr="+DTS(apr)+"| sl="+DTS(sl)+" tp="+DTS(tp)+"  id="+ITS(SysID);
	Print(txt); INF(txt);
	int i=0;
	while (i<5 && (tp>0 || sl>0))
	{
		RefreshParam(smb); apr=APR(dir);
		sl=NSL(dir, op, apr, nsl, StopLvl, false);
		tp=NTP(dir, op, apr, ntp, StopLvl, false);
		txt="Place stops to "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" apr="+DTS(apr)+"| sl="+DTS(sl)+" tp="+DTS(tp)+"  id="+ITS(SysID);
		if (OrderModify(ticket, op, sl, tp, 0, OTC(dir))) break;
		INF(txt); ErrorHandle(GetLastError(), -1, SysID, txt); Sleep(100); i++;
	}
}

//---------------------------------------------------------------   VirtInfo
void VirtInfo(int SysID, string smb, int tf, int &y)
{
	if (!bVirtInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, clrLightGray);
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	int cdir=-1, cticket=0; double cop=0, cprof=0, cpprof=0, apr=0;
	double prof=0, loss=0, depo=0, pprof=0, ploss=0; int nb=0, ns=0;
	t++; txt[t]="======== VIRTUAL ======="; clr[t]=clrGray;
	for (int i=0; i<n; i++)
	{
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid);
		int dir=(int)GetGV(name[i]); // ��� ������������
		if (dir==OP_BALANCE) { depo+=GetGV(sID+"VO."+sid+".prof"); continue; } // ���� ���������� �����
		double op=GetGV(sID+"VO."+sid+".op"); // ���� �������� ������������
		double lot=GetGV(sID+"VO."+sid+".lot");
		if (!CheckGV(sID+"VO."+sid+".cl"))
		{
			cdir=dir; cticket=id; cop=op; apr=APR(dir);
			cpprof=(apr-cop)*SD(cdir); cprof=CalcProf(cdir, op, apr, lot);
			t++; txt[t]=OTS(cdir)+"#"+ITS(cticket)+" | "+DTS(cop)+" | "+DTS(apr)+"  | "+DTS(cpprof/(Pnt*_Pnt),0)+"�. | "+DTS(cprof,2)+"$"; clr[t]=OTC(cdir);
		}
		else
		{
			double cl=GetGV(sID+"VO."+sid+".cl");
			double pip=(cl-op)*SD(dir);
			if (pip>=0) { prof+=CalcProf(dir, op, cl, lot); pprof+=pip; } else { loss+=CalcProf(dir, op, cl, lot); ploss+=pip; }
			if (dir==OP_BUY) nb++; else ns++;
		}
	}
	if (cdir<0) { t++; txt[t]="�������� �������: ���"; }
	t++; txt[t]="���������";
	t++; txt[t]="����.������: "+DTS(prof+loss+depo,2);
	t++; txt[t]="�������� �������:  Sell "+ITS(ns)+" | Buy "+ITS(nb);
	t++; txt[t]="�������: "+DTS(pprof/(Pnt*_Pnt),0)+" �./"+DTS(prof,2);
	t++; txt[t]="������: "+DTS(ploss/(Pnt*_Pnt),0)+" �./"+DTS(loss,2);
	t++; txt[t]="�����: "+DTS((pprof+ploss)/(Pnt*_Pnt),0)+" �./"+DTS(prof+loss,2);
	t++; txt[t]="���������";
	t++; txt[t]="�������������: "+DTS(CountVolatile(smb, tf)/(Pnt*_Pnt),1)+" �.";
	MqlDateTime mdt; datetime dt=TimeCurrent(mdt);
	t++; txt[t]="��������: "+((dt-fdtBid)>0?DTS(nBid*1.0/(dt-fdtBid),2):"0");
	
	Comment2(sID+"vi.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   CountVBalance
double CountVBalance()
{
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	double bal=0;
	for (int i=0; i<n; i++)
	{
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int dir=(int)GetGV(name[i]); // ��� ������������
		if (dir==OP_BALANCE) { bal+=GetGV(sID+"VO."+sid+".prof"); continue; } // ���� ���������� �����
		if (!CheckGV(sID+"VO."+sid+".cl")) continue;
		bal+=CalcProf(dir, GetGV(sID+"VO."+sid+".op"), GetGV(sID+"VO."+sid+".cl"), GetGV(sID+"VO."+sid+".lot"));
	}
	return(bal);
}
//---------------------------------------------------------------   RealInfo
void RealInfo(int SysID, string smb, int &y)
{
	if (!bRealInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, clrLightGray);
	t++; txt[t]="========== REAL ========="; clr[t]=clrGray;
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);

	int cdir=-1, cticket=0; double cop=0, cprof=0, cpprof=0, apr=0;
	int comp=0; double pcomp=0;
	for (int i=0; i<no; i++)
	{
		if (!OrderSelect(ticketO[i], SELECT_BY_TICKET)) continue;
		cticket=OrderTicket(); cdir=OrderType(); 
		cop=OrderOpenPrice(); cprof=OrderProfit(); cpprof=(OrderClosePrice()-OrderOpenPrice())*SD(cdir);
		apr=APR(cdir);
		int c=StringFind(OrderComment(), "|"); if (c>0) { int p=STI(StringSubstr(OrderComment(), c+1)); comp+=p; pcomp+=CalcProf(0, 0, p*Pnt*_Pnt, OrderLots()); }
		t++; txt[t]=OTS(cdir)+"#"+ITS(cticket)+" | "+DTS(cop)+" | "+DTS(apr)+"  | "+DTS(cpprof/(Pnt*_Pnt),0)+"�. | "+DTS(cprof,2)+"$"; clr[t]=OTC(cdir);
	}
	
	double prof=0, loss=0, pprof=0, ploss=0; int nb=0, ns=0;
	for (int i=0; i<nh; i++)
	{
		if (!OrderSelect(ticketH[i], SELECT_BY_TICKET)) continue;
		int c=StringFind(OrderComment(), "|"); if (c<0) continue;
		int p=STI(StringSubstr(OrderComment(), c+1)); comp+=p; pcomp+=CalcProf(0, 0, p*Pnt*_Pnt, OrderLots()); 
		if (OrderProfit()>=0) { prof+=OrderProfit(); pprof+=(OrderClosePrice()-OrderOpenPrice())*SD(OrderType()); }
		else { loss+=OrderProfit(); ploss+=(OrderClosePrice()-OrderOpenPrice())*SD(OrderType()); }
		if (OrderType()==OP_BUY) nb++; else ns++;
	}
	
	if (cdir<0) { t++; txt[t]="�������� �������: ���"; }
	t++; txt[t]="���������";
	t++; txt[t]="�������� �������:  Sell "+ITS(ns)+" | Buy "+ITS(nb);
	t++; txt[t]="�������: "+DTS(pprof/(Pnt*_Pnt),0)+" �./"+DTS(prof,2);
	t++; txt[t]="������: "+DTS(ploss/(Pnt*_Pnt),0)+" �./"+DTS(loss,2);
	t++; txt[t]="�����: "+DTS((pprof+ploss)/(Pnt*_Pnt),0)+" �./"+DTS(prof+loss,2);
	t++; txt[t]="���������";
	t++; txt[t]="����� �����������: "+ITS(comp)+" �./"+DTS(pcomp,2);
	Comment2(sID+"ri.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   SpreadInfo
void SpreadInfo(int SysID, string smb, int &y)
{
	if (!bSpreadInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, SpreadMode<=0?clrLightGray:clrYellow);
	t++; txt[t]="========= SPREAD ========"; clr[t]=clrGray;
	t++; txt[t]="����� �����������: "+ITS(SpreadMode);
	t++; txt[t]="������� �����: "+DTS(Spread/(Pnt*_Pnt),0)+" �.";
	t++; txt[t]="����. �����: "+DTS(FixSpread,0)+" �.";
	t++; txt[t]="������� �����("+ITS(is)+"): "+DTS(AvgSpread()/(Pnt*_Pnt),0)+" �.";
	t++; txt[t]="�����������: "+ITS(GetComp())+" �.";
	Comment2(sID+"si.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   CalcProf
double CalcProf(int dir, double op, double cl, double lot)
{
	if (ProfitCalcMode==0) return((cl-op)*SD(dir)*lot*TickVal/TickSize); // forex
	if (ProfitCalcMode==1) return((cl-op)*SD(dir)*lot*LotSize); // cfd
	if (ProfitCalcMode==2) return((cl-op)*SD(dir)*lot*TickVal/TickSize); // futures
	return(0);	
}
//---------------------------------------------------------------   FindComment
int FindComment(int &ticket[], int n, string pref)
{
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) continue;
		if (StringFind(OrderComment(), pref, 0)==0) return(ticket[i]);
	}
	return(0);
}
//---------------------------------------------------------------   GetComp
int GetComp()
{
	int comp=0;
	if (SpreadMode==1) comp=int((2*Spread)/(Pnt*_Pnt));
	if (SpreadMode==2) comp=int(AvgSpread()*AvgSpreadKoef/(Pnt*_Pnt));
	if (SpreadMode==3) comp=FixSpread;
	return(comp);
}
//------------------------------------------------------------------ AddSpread
void AddSpread()
{
	if (is>=AvgSpreadCount) { is--; for (int i=0; i<AvgSpreadCount-1; i++) spread[i]=spread[i+1]; }
	spread[is]=Spread; is++;
}
//------------------------------------------------------------------ AvgSpread
double AvgSpread()
{
	if (is<AvgSpreadCount) return(0);
	double avg=0; for (int i=0; i<AvgSpreadCount; i++) avg+=spread[i];
	return(AvgSpreadCount>0?avg/double(AvgSpreadCount):0);
}
//------------------------------------------------------------------ CheckAcceleration
void CheckAcceleration()
{
	MqlDateTime mdt; datetime dt=TimeCurrent(mdt);
	if (pBid<=0) { pBid=_Bid; fdtBid=dt; nBid=0; return; }
	if ((_Bid>pBid && nBid<0) || (_Bid<pBid && nBid>0)) { pBid=_Bid; fdtBid=dt; nBid=0; return; }
	if (_Bid>=pBid && nBid>=0) { pBid=_Bid; nBid++; return; }
	if (_Bid<=pBid && nBid<=0) { pBid=_Bid; nBid--; return; }
}
//------------------------------------------------------------------ CheckVolatile
void CheckVolatile()
{
	if (_Bid<pLo || pLo<=0) pLo=_Bid;
	if (_Bid>pHi || pHi<=0) pHi=_Bid;
}
//------------------------------------------------------------------ CountVolatile
double CountVolatile(string smb, int tf)
{
	double v=0; for (int i=0; i<BarVolatile; i++) v+=iHigh(smb, tf, i)-iLow(smb, tf, i);
	return(BarVolatile>0?v/BarVolatile:0);
}
//---------------------------------------------------------------   IsDir
bool IsDir(int dir, int type)
{
	if (dir==OP_ALL) return(true);
	if (dir>=0 && dir<=7 && type==dir) return(true);
	if (dir==OP_MARKET && (type==OP_BUY || type==OP_SELL)) return(true);
	return(false);
}
//---------------------------------------------------------------   CountOrders
int CountOrders(int dir, int SysID, string smb)
{
	int total=OrdersTotal(), c=0; if (total<=0) return (0);
	for(int i=0; i<total; i++) 
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), -1, SysID, "CountOrders - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }		
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || (OrderSymbol()!=smb&&smb!="")) continue;
		c++;
	}
	return(c);
}
//---------------------------------------------------------------   GetTickets
int GetTickets(int dir, int SysID, string smb, int &tickets[])
{
	int total=OrdersTotal(); if (total<=0) return (0);
	int c=0; // orders counter
	ArrayResize(tickets, total); // change array size
	for(int i=0; i<total; i++) // select tickets
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), -1, SysID, "GetTickets - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || OrderSymbol()!=smb) continue;
		tickets[c]=OrderTicket(); c++;
	}
	ArrayResize(tickets, c);
	return(c); // orders count
}
//---------------------------------------------------------------   GetTickets
int GetTicketsH(int dir, int SysID, string smb, int &tickets[])
{
	int total=OrdersHistoryTotal(); if (total<=0) return (0);
	int c=0; // orders counter
	ArrayResize(tickets, total); // change array size
	for(int i=0; i<total; i++) // select tickets
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) { ErrorHandle(GetLastError(), -1, SysID, "GetTicketsH - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || OrderSymbol()!=smb) continue;
		tickets[c]=OrderTicket(); c++;
	}
	ArrayResize(tickets, c);
	return(c); // orders count
}
//---------------------------------------------------------------   CloseOrders
int CloseOrders(int dir, int SysID, string smb)
{
	int i, total = OrdersTotal();	if (total<=0) return(0);
	int ticket[1000]={0}, nt=0; double op=0;

	nt=0;
	for (i=0; i<total; i++)	
	{	
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose - Select "+ITS(i));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || (OrderSymbol()!=smb&&smb!="")) continue;
		ticket[nt]=OrderTicket(); nt++;
	}
	for (i=0; i<nt; i++)
	{	
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose - Select#"+ITS(ticket[i])+"  nt="+ITS(nt)+"  i="+ITS(i));  return(-1); }
		dir=OrderType(); RefreshParam(OrderSymbol());
		if (dir==OP_BUY) op=_Bid; else if (dir==OP_SELL) op=_Ask;
		if (dir==OP_BUY || dir==OP_SELL) if (!OrderClose(ticket[i], OrderLots(), op, Slip, OTC(dir))) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose#="+ITS(ticket[i])+"  nt="+ITS(nt)+"  i="+ITS(i)); return(-1); }
		if (dir==OP_BUYLIMIT || dir==OP_SELLLIMIT || dir==OP_BUYSTOP || dir==OP_SELLSTOP)
			if (!OrderDelete(ticket[i])) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderDelete#="+ITS(OrderTicket())); return(-1); }
	}
	return(nt);
}
//---------------------------------------------------------------   RefreshParam
void RefreshParam(string smb)
{
	RefreshRates();
	_Digit=(int)MarketInfo(smb, MODE_DIGITS);
	Pnt=1; //if (_Digit==5 || _Digit==3) Pnt=10;
	_Pnt=MarketInfo(smb, MODE_POINT);
	FreezLvl=MarketInfo(smb, MODE_FREEZELEVEL)*_Pnt;
	StopLvl=MarketInfo(smb, MODE_STOPLEVEL)*_Pnt;
	Spread=MarketInfo(smb, MODE_SPREAD)*_Pnt;
 	LotSize=MarketInfo(smb, MODE_LOTSIZE); 
 	LotStep=MarketInfo(smb, MODE_LOTSTEP);
 	MinLot=MarketInfo(smb, MODE_MINLOT);
 	MaxLot=MarketInfo(smb, MODE_MAXLOT);
 	TickVal=MarketInfo(smb, MODE_TICKVALUE); if (TickVal==0) TickVal=10.0/Pnt;
	TickSize=MarketInfo(smb, MODE_TICKSIZE); if (TickSize==0) TickSize=1;
 	ProfitCalcMode=MarketInfo(smb, MODE_PROFITCALCMODE);
 	if (_Pnt==0 && _Digit!=0) _Pnt=1/_Digit;
	_Bid=NP(MarketInfo(smb, MODE_BID));
	_Ask=NP(MarketInfo(smb, MODE_ASK));
}
//---------------------------------------------------------------   ErrorHandle
void ErrorHandle(int err, int OrderID, int SysID, string str)
{
	Print("("+ITS(err)+"): "+ErrorDescription(err)+"-Magic: "+ITS(SysID)+" #"+ITS(OrderID)+" | -"+str); 
	switch (err)
	{
		case ERR_SERVER_BUSY: //4 
		case ERR_NO_CONNECTION: //6
		case ERR_TOO_FREQUENT_REQUESTS: //8
		case ERR_BROKER_BUSY: //137
		case ERR_TOO_MANY_REQUESTS: //141
		case ERR_TRADE_CONTEXT_BUSY: //146
			Sleep(2000); //
			break;
		
		case ERR_PRICE_CHANGED: //135
		case ERR_REQUOTE: //138
			RefreshRates(); //
			break;
	}
}

//---------------------------------------------------------------   NPR
double NPR(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(_Ask);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(_Bid);
	return(0);
}
//---------------------------------------------------------------   APR
double APR(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(_Bid);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(_Ask);
	return(0);
}
//---------------------------------------------------------------   ND
double ND(double d, int n=-1) {  if (n<0) return(NormalizeDouble(d, _Digit)); return(NormalizeDouble(d, n)); }
//---------------------------------------------------------------   NP
double NP(double d) { return (ND(MathRound(d/TickSize)*TickSize)); }
//---------------------------------------------------------------   NL
double NL(double lot) 
{
	int k=0; // lot digits
	// select lot digits by lotstep
	if (LotStep<=0.001) k=3; else if (LotStep<=0.01) k=2; else if (LotStep<=0.1) k=1;
	lot=ND(MathMin(MaxLot, MathMax(MinLot, lot)), k);
	return(lot);
}
//---------------------------------------------------------------   DIR
int DIR(int dir)
{
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(OP_BUY);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(OP_SELL);
	return(dir);
}
//---------------------------------------------------------------   ADIR
int ADIR(int dir)
{
	int p[6]={OP_BUY, OP_SELL, OP_BUYLIMIT, OP_SELLLIMIT, OP_BUYSTOP, OP_SELLSTOP};
	int a[6]={OP_SELL, OP_BUY, OP_SELLLIMIT, OP_BUYLIMIT, OP_SELLSTOP, OP_BUYSTOP};
	for (int i=0; i<6; i++) if (p[i]==dir) return(a[i]);
	return(dir);
}
//---------------------------------------------------------------   INF
void INF(string st, bool ini=false) { if (!bShowComment) return; if (ini) g_inf=g_inf+"\n        "+st; else g_inf=g_inf+"\n            "+st; }

//---------------------------------------------------------------   IIF
double IIF(bool cond, double a1, double a2) { if (cond) return (a1); else return(a2); }
//---------------------------------------------------------------   SD
double SD(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(1);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(-1);
	return(0);
}

//---------------------------------------------------------------   ITS
string ITS(long d) { return(DoubleToStr(d, 0)); }
//---------------------------------------------------------------   DTS
string DTS(double d, int n=-1) { if (d==EMPTY_VALUE) return("<>"); if (n<0) return(DoubleToStr(d, _Digit)); else return(DoubleToStr(d, n)); }
//---------------------------------------------------------------   TTS
string TTS(datetime time) { return (TimeToStr(time, TIME_DATE|TIME_SECONDS)); }
//---------------------------------------------------------------   OTS
string OTS(int n)
{
	int p[15]={OP_BUY, OP_SELL, OP_BUYLIMIT, OP_SELLLIMIT, OP_BUYSTOP, OP_SELLSTOP, 6, 7, 8, 9, 10, 11, 12, 13, -1};
	string sp[15]={"BUY", "SELL", "BUYLIMIT", "SELLLIMIT", "BUYSTOP", "SELLSTOP", "BALANCE", "CREDIT", "MARKET", "PEND", "LIMIT", "STOP", "BUYALL", "SELLALL", "ALL"};
	for (int i=0; i<15; i++) if (p[i]==n) return(sp[i]);
	return("--");
}
//---------------------------------------------------------------   OTC
color OTC(int dir) 
{
	if (dir==OP_BUY || dir==OP_BUYLIMIT || dir==OP_BUYSTOP) return(clrLimeGreen);
	if (dir==OP_SELL || dir==OP_SELLLIMIT || dir==OP_SELLSTOP) return(clrRed);
	return(0);
}
//---------------------------------------------------------------   PTS
string PTS(int n) 
{
	if (n==0) return(PTS(Period()));
	int p[9]={1, 5, 15, 30, 60, 240, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
	string sp[9]={"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
	for (int i=0; i<9; i++) if (p[i]==n) return(sp[i]);
	return("--");
}

//------------------------------------------------------------------ SetLabel
void SetLabel(string name, int wnd, string text, color clr, int x, int y, int corn, int fontsize, string font)
{
	ObjectCreate(name, OBJ_LABEL, wnd, 0, 0); ObjectSet(name, OBJPROP_CORNER, corn); 
	ObjectSetText(name, text, fontsize, font, clr); 
	ObjectSet(name, OBJPROP_XDISTANCE, x);	ObjectSet(name, OBJPROP_YDISTANCE, y); 
}
//------------------------------------------------------------------ SetArrow
void SetArrow(string name, datetime dt, double pr, color clr, int arr, int width, string st)
{
	ObjectCreate(name, OBJ_ARROW, 0, dt, pr);
	ObjectSet(name, OBJPROP_TIME1, dt); ObjectSet(name, OBJPROP_PRICE1, pr);
	ObjectSet(name, OBJPROP_ARROWCODE, arr); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_WIDTH, width);
}
//------------------------------------------------------------------ SetText
void SetText(string name, int wnd, string text, datetime dt, double pr, color clr, int fontsize, string font)
{
	ObjectCreate(name, OBJ_TEXT, wnd, 0, 0); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, text, fontsize, font, clr); 
	ObjectSet(name, OBJPROP_TIME1, dt);	ObjectSet(name, OBJPROP_PRICE1, pr);
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
//------------------------------------------------------------------ SetHLine
void SetHLine(string name, double pr, color clr, int width, int style, string st)
{
	ObjectCreate(name, OBJ_HLINE, 0, 0, 0); ObjectSet(name, OBJPROP_PRICE1, pr);
	ObjectSet(name, OBJPROP_WIDTH, width); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_STYLE, style);
}
//------------------------------------------------------------------ ObjectsDeleteAll2
void ObjectsDeleteAll2(int wnd=-1, int type=-1, string pref="")
{
	string names[]; int n=ObjectsTotal(); ArrayResize(names, n);
	for (int i=0; i<n; i++) names[i]=ObjectName(i);
	for (int i=0; i<n; i++) 
	{
		if (wnd>=0) if (ObjectFind(names[i])!=wnd) continue;
		if (type>=0) if (ObjectType(names[i])!=type) continue;
		if (pref!="") if (StringSubstr(names[i], 0, StringLen(pref))!=pref) continue;
		ObjectDelete(names[i]);
	}
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
	for (int i=0; i<k; i++) name[i]=names[i]; return(k);
}

//------------------------------------------------------------------ Comment2
void Comment2(string pref, int n, string &inf[], color &clr[], int corn, int x0, int &y0, int fontsize=9, string font="Tahoma")
{
	ObjectsDeleteAll2(0, OBJ_LABEL, pref);
	int dy=int(fontsize*1.5);
	for (int i=0; i<n; i++) SetLabel(pref+ITS(i), 0, inf[i], clr[i], x0, y0+dy*i, corn, fontsize, font);
	y0+=dy*n;
}

//------------------------------------------------------------------ SelectGV
int SelectGV(string pref, string &name[])
{
	string st; int i, k=0, n=GlobalVariablesTotal(); ArrayResize(name, n);
	for (i=0; i<n; i++) 
	{
		st=GlobalVariableName(i);
		if (pref!="") if (StringSubstr(st, 0, StringLen(pref))!=pref) continue;
		name[k]=st; k++;
	}
	return(k);
}
//------------------------------------------------------------------ GetGV
double GetGV(string name) { int g_err=GetLastError(); double r=GlobalVariableGet(name); g_err=GetLastError(); if (g_err>0) INF("-err Get="+ITS(g_err)+" GV="+name); return(r); }
//------------------------------------------------------------------ SetGV
datetime SetGV(string name, double r) { datetime dt=GlobalVariableSet(name, r); int g_err=GetLastError(); if (g_err>0 || dt<=0) INF("-err Set="+ITS(g_err)+" GV="+name+"  dt="+ITS(dt)); return(dt); }
//------------------------------------------------------------------ DelGV
bool DelGV(string name) { return(GlobalVariableDel(name)); }
//------------------------------------------------------------------ CheckGV
bool CheckGV(string name) { return(GlobalVariableCheck(name)); }

//---------------------------------------------------------------   DrawDeals
void DrawDeal(string name, int ticket, int dir, double lot, double op, datetime dop, double cl, datetime dcl, double sl, double tp)
{	
	SetArrow(name+".opa", dop, op, OTC(dir), 1, 0, "open #"+ITS(ticket)+" @"+TTS(dop)+" | op="+DTS(op)+"  tp="+DTS(tp)+"  sl="+DTS(sl)+" lot="+DTS(lot));
	if (tp>0) SetArrow(name+".tpa", dop, tp, OTC(dir), 4, 0, "t/p #"+ITS(ticket)+" ="+DTS(tp));
	if (sl>0) SetArrow(name+".sla", dop, sl, OTC(dir), 4, 0, "s/l #"+ITS(ticket)+" ="+DTS(sl));
	if (dcl<=0) return;
	SetArrow(name+".cla", dcl, cl, OTC(dir), 3, 0, "close #"+ITS(ticket)+" @"+TTS(dcl)+" | op="+DTS(op)+"  tp="+DTS(tp)+"  sl="+DTS(sl)+" lot="+DTS(lot));
	SetLine(name+".ln", dop, op, dcl, cl, OTC(dir), 1, STYLE_DOT, "");
}
//---------------------------------------------------------------   DrawOrder
void DrawOrder(string name, int ticket, int dir, double op, double sl, double tp)
{
	SetHLine(name+".opl", op, clrLimeGreen, 1, STYLE_DOT, "                  "+OTS(dir)+" #"+ITS(ticket));
	if (sl>0) SetHLine(name+".sll", sl, clrMagenta, 1, STYLE_DOT, "                  "+"SL #"+ITS(ticket));
	if (tp>0) SetHLine(name+".tpl", tp, clrMagenta, 1, STYLE_DOT, "                  "+"TP #"+ITS(ticket));
}
//---------------------------------------------------------------   STI
int STI(string d) { return(StrToInteger(d)); }
//---------------------------------------------------------------   NTP
double NTP(int dir, double op, double pr, double aTP, double stop, bool rel=true)
{
	if (aTP==0) return(NP(0));
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) { if (rel) aTP=op+aTP*Pnt*_Pnt; return(NP(MathMax(aTP, pr+stop))); }
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) { if (rel) aTP=op-aTP*Pnt*_Pnt; return(NP(MathMin(aTP, pr-stop))); }
	return(0);
}
//---------------------------------------------------------------   NSL
double NSL(int dir, double op, double pr, double aSL, double stop, bool rel=true)
{
	if (aSL==0) return(NP(0));
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) { if (rel) aSL=op-aSL*Pnt*_Pnt; return(NP(MathMin(aSL, pr-stop))); }
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) { if (rel) aSL=op+aSL*Pnt*_Pnt; return(NP(MathMax(aSL, pr+stop))); }
	return(0);
}

/*
Overdraft Profit System  (MT4)

������� ���������
Magic=1123; // ����� ������� ��������
bMarketExec=true; // �������� ��� ������� � ������-�����������, ����=true, �� ������� ���������� �����, ����� ������ �����. 
Slip=0; // ���������� ��������������� ��� ��������/�������� ��������� ������
OpenMode=0; // ����� ����� � �����. 
	=0 �� �� wlxFractals ���������, 
	=1 �� ���� �� Acceleration. 
	=2 �� ���� �� �������������.
	=3 �� ���� � ������ �� OpenMode=1 ����� ��������, ���� �� OpenMode=2.
	=4 �� ���� � ������ OpenMode =0 ����� �������� OpenMode =1 ����� �������� OpenMode =2.     
Acceleration=1.5; // ����������� �������� ����
BarVolatile=24; // ����� ����� ��� ������� �������������
kVolatile=5.0; //��������� ������������� 
LotKoef=2; // ��������� ��� ���������� ���� ����� ������
LotKoefStart=0; // � ������ ���������� ������ �������� ���������� ���� �� LotKoef
VDeposit=5000; // ������ ���������� ����.�������
Revers=true; // true -��������� �������� ������ �������������� �������� / false-� ��� �� �����������
Lot=0.1; // ��� ������. ���� =0, �� ���������� ��
MM=10; //������� �� ������� ��� ����.
LotKoef=2; // ��������� ��� ���������� ���� ����� ������
LotKoefStart=0; // � ������ ���������� ������ �������� ���������� ���� �� LotKoef
nDay=14; //  ����� ��������� ���� ��� ������� �������� ���� ���������.
SpreadMode=0; // ����� ����������� ������ 0/1/2/3
FixSpread =0; // ������ ������������� ����������� ������ ��� SpreadMode=3
AvgSpreadCount=20;   // ���������� ��������� �������� ������ ��� ���������� �������� ������
AvgSpreadKoef=2;  //  ���������� ������� ������� ��� �����������
CloseMode=0; // ����� �������� 
	0 - �������� �� ������������ ��/��,  
	1 - �������� �� �������� SL/TP 
	2 - �������� �� ������������� 
	3 - �������� �� ���������� - �������� SL/TP ��� ������������ ��/�� ���� ����
	4 - �������� �� ���������� - ������������� ��� �������� SL/TP ��� ������������ ��/�� ���� ����
TP=20; // ������ ����������� ��������� ������ ��� CloseMode=1-2. ���� =0, �� �� ����������
SL=20; // ������ �������� ��� ��������� ������ ��� CloseMode=1-2. ���� =0, �� �� ����������
StopVolatile=2; // ����������� ��� ���������� ������ �� �������������
bTralSL=true; // =true - ��������� ����� �� ������� SL
bTralSLVirt=true; // =true - ��������� ����� ����������� �� ProcentProfit/ CloseProcentProfit
ProcentProfit=0; // ������� ������� ��� ����� ��/�� � �������, ���� =0, �� ���� ��������.
CloseProcentProfit=0; // ������� ��� ������� ��/�� ��� �����, ���� =0, �� ���� ��������.
// ��������� wlxFractals
Equals = 20; // ������������ ����� ������ ������ ����� � ������ ��� ������������ ��������
nLeftUp = 20;  // ����������� ����� ����� ����� ��� �������� �����
nRightUp = 20; // ����������� ����� ����� ������ ��� �������� �����
nLeftDown = 20; // ����������� ����� ����� ����� ��� �������� ����
nRightDown = 20; // // ����������� ����� ����� ������ ��� �������� ����
// ����
bVirtInfo=true; // ���������� �� ����� ���� ������ ����.�������.
bRealInfo=true; // ���������� �� ����� ���� ������ ����.�������.
bSpreadInfo=true; // ���������� �� ����� ���� ������ ��� �����


������ �������� ������������ ������:
���� OpenMode=0, ��
Buy: ���� ��������� ������� wlxFractals  ����� 
Sell: ���� ��������� ������� wlxFractals  ������� 
���� OpenMode=1, ��
Buy: ���� �������� ����� ����� ����� Acceleration
Sell: ���� �������� ����� ���� ����� Acceleration
��� �������� = ����� ����� � ����� ����������� / ������� �� ��������� ����� �����. 
��� ���� � ��������������� ������� ����� ����� � ����� ������������ � ������������� ������.
���� OpenMode=2 �� 
Buy: ���� ��� ������ ���������� ���+�������������*kVolatile
Sell: ���� ��� ������ ���������� ���-�������������* kVolatile
��� ��������� ���/��� - ��� �������/�������� ���, ����������� ������� �� ������� �������� ��� ����� �������� ������.
�������������= (����� ���-��� �� ���������� ��������� BarVolatile) / ������� �� BarVolatile. 
���� OpenMode=3 �� 
Buy: ���� ������� �� OpenMode=1 ����� ��������, ���� �� OpenMode=2.
Sell: ���� ������� �� OpenMode=1 ����� ��������, ���� �� OpenMode=2.
���� OpenMode=4  �� 
Buy:  ���� ������� OpenMode =0 ����� �������� OpenMode =1 ����� �������� OpenMode =2.
Sell: ���� ������� OpenMode =0 ����� �������� OpenMode =1 ����� �������� OpenMode =2

�. �������� ������������ ������
���� ���� ������ �������� ������, � ��� ��� �������� ����.�������, �� ��������� ����������� ����� � ����������� �������.
��� ����.������:
���� ���������� ����.����� �������� � ������ � ��� LotKoefStart ��������� �����, �� ��� ����������  = ���������� ��� * LotKoef.
����� ���� ���������� ����.����� �������� � ������ ��� ��� ��� �� LotKoefStart ��������� �����, �� ��� ����������  = Lots. ��� ���� Lots=0, �� ��� = AccountBalance/1000 * MM/100

������� ����.������� � ������:
������� ��������� ��� �� ����.�������� � ������.
���� ������� �� ��������, �� ������� ������ � ������ ����.���������� �������� � ������� VDeposit - ��������� ����.������ (+������ � ������ ��� ����������). � ���������� ������� ����.������� �� 0, ���� ������� � ��������� ����� (�� Lots ��� �� MM).

�����! �� ������ ������� �������� ����� ������� ������ ���� �����. ����� �������� ������ ��� ����� �������.
�����! ���� SpreadMode = 2, �� � ������ �������� ������ ���� ��� �������� ������� ����� (�� ���� ������ ������ �� ����� AvgSpreadCount ����� ����� ��������� ����.������)

������ ����������� ����� ����� ���� ���������� ������������� (��������� �����), ������� ���������� � ����������� ��������� ������ ��� �� �������������.

�. �������� ������������ ������
1. ���� ����������� ��� ������ �������� ����� (���� �� �������������� �� ����������� ����.������), ���������������� ������������ ������, �� ������� ��������� ���� ����������� �����.
2. ���� ���� ���������� ���� ����������� ��� �������� ����.������, �� ��������� ����.�����

�. �������� ��������� ������ (��� Trade=true)
��� �������� ������������ ������ ������� ��������� �������� �����. 
���� Revers=false, �� � ����� �� �����������, ��� � ����������� (�� ���� ������� ��������� � �����������)
���� Revers=true, �� � ��������������� ����������� �� ������������  � ������������ �����:
- SpreadMode =0, �� ����� �� ��������������.
- SpreadMode = 1, �� �������� ����� ���������, ����� ���� ���� �� ��� ������������ ������ �� ���������� 2*������� ����� � ������.
- SpreadMode = 2, �� �������� ����� ���������, ����� ���� ���� �� ������������ ������ �� ���������� AvgSpreadKoef *������� ����� � ������.
- SpreadMode = 3, �� �������� ����� ���������, ����� ���� ���� �� ������������ ������ �� ���������� FixSpread � ������.
������� ����� = ����� AvgSpreadCount ��������� �������� ������ ������� �� AvgSpreadCount

��� ������ ������������� ����.������.

� ������ ������ �������� ������� � ����������:
- CloseMode=0, �� ����������� ���������� � ������� ��� ������:
- ��� ��� = ����� ���������� �� �������� �� ������ �������� �� nDay ���� ������� �� ���������� ���� �����������
- ��� ���� = ����� ���������� �� ������ �� ������� �������� �� nDay ���� ������� �� ���������� ���� �����������
- CloseMode=1, �� ���������� �������� TP/SL
- CloseMode=2, �� ������ ��/�� = ������ ������������� * SLVolatile (������������� ����������� ���������� ��� ��� ��������)
- CloseMode=3, �� ������������ �� CloseMode=0,1 - �� ���������� ����� �� ���, ������� ���������.
- CloseMode=4, �� ������������ �� CloseMode=0,1,2 - �� ���������� ����� �� ���, ������� ���������.

��� ����������� ������ � ��������� - ��� ����� ����������� � � ������������.

�����! � ����������� ��������� ������ ����������: <������������� ����.������>|<����� �����������>.
�����! ���� ����������� ����� ��� ������, �� �������� ����� �� ���������.

�. �������� ��������� ������
���� ������ ����������� ����� (��. ������ �2), �� ��������� � ��������.

�. ����������� �������� ��������� ������
1. ��� bTralSL � �������� SL>0: 
���� ���� ��� � ������, �� ������� ������� �� ���������� SL �� �����.

2. ��� ������� �� � ������ � �������� ProcentProfit, CloseProcentProfit: 
���� ���� ������ � ������ �� ���������� ProcentProfit/100*�� ����.������, �� ������� ������������ � ������ �� ���������� �� ������� ���� = CloseProcentProfit/100* ProcentProfit/100*��.

�. ���� ����������� ����. ������ (��� bVTralSL � �������� ProcentProfit, CloseProcentProfit)
���� ���� ������ � ������ ����.������ �� ���������� ProcentProfit/100*��, �� ���������� ����.������ �� ���������� �� ������� ���� = CloseProcentProfit/100* ProcentProfit/100*��.
��� �� - ������ �������� ����.������

�. ���������� ����������� ������� (��� bVirtInfo=true ) ������ ��������� � ���� �������� ������
Overdraft Profit System VIRTUAL
������� �����: Sell 1.31437 | 1.31568  | 145�. | 65$
���������.. 
����.������: 5000 (= ����� ����������� ���� ����.������� + ����.����������)
����� �������:  Sell 11 | Buy 14 (� ������)
�������: 0.00000  (���� ������� � ������)
������: 0.00000  (���� ������� � ������)
�����: 0.00000    (������� + ������)

����������: ���� ��������� ����� ���, �� ������� "������� �����" ������ (�� �����), ����� �������.  

�. ���������� �������� ������� (��� bRealInfo=true ) ������ ��������� � ���� �������� ������
Overdraft Profit System REAL
������� �����: Sell 1.31437 | 0.00000 | 145�. | 65$
���������.. 
����� �������:  Sell 11 | Buy 14 (��������� ��� �������)
�������: 0.00000  (�� ��� �����)
������: 0.00000  (�� ��� �����)
�����: 0.00000   (������� + ������)
����� �����������: 7�/70$ (����� ������ ����� ����� �������� ������������ � ���������.)

����������: ���� ������� ����� ���, �� ������� "������� �����" ������ (�� �����), ����� �������.  

�. ���������� ��� ����� (��� bSpreadInfo=true) ������ ��������� � ���� �������� ������
����� �����������: 1
������� �����: 2 �.
������������� �����: 5�. (����� ��������� FixSpread)
������� �����: 17 �.
�����������: 2�. (��������� ������� ����� ����� �������� ������������ � ��������� ������)
�����! ����� ����� ���� �� ������� ����������� ��������, �� ��������� ������������ ����� ������.
�����! ������� ��������� ����������� �� ���� ������� �������. �� ���� ����������� ��� ������ ������� � ����������� �� �����������, ��������� � �����������.

�. ��������� � ���� � �������
���������� ���� � �������������, �������� �������� ����� ����, ��������� �������� ���������� �������� ���������, ����� � ���� �� ��������� ��� ���������� �� ������ ���� ������ � ��������������. 
����� ������� ����� ������ � ���� � �������� ���� ��� ���� �������, � ��� ����� ��� �� ��������� � ��������� �����, ������ ����������������� �������.
������ � ������, ������� �������� ������ ������ ����� �� ��������:
- ������ V ����������� EURUSD Sell � ������� 0.1 �� ���� 0.00000 ������������� ������ ID: 1768570
- ������ R �������� ����� EURUSD Buy � ������� 0.1 �� ���� 0.0000 ������������� ����.������ ID: 79849643 
- ������ V ����������� ����� EURUSD Sell � ������� 0.1 �� ���� 0.00000 ������������� ������ ID: 1768570
- ������ R �������� ����� EURUSD Buy � ������� 0.1  �� ���� 0.00000 ������������� ����.������ ID: 79849643
������ ������� ��������/�������� ��� ������� 
������� ������� ���������� ��� �������� ��������� � ����� ��� ���������� ������ � ����������.
�������� � �������� ������������ ������ ������ ��������� ������������ ��� ������ � �������.
������ � ������, �� ������ �� ������� ���� �������� ������
����������������� ��� ������� ��������� � ������� ���������� ��������. 
*/