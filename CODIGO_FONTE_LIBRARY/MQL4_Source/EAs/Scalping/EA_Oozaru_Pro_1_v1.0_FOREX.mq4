//+------------------------------------------------------------------+
//|                                 Guilherme                |
//|                                 Copyright 2021,                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Oozaru Pro"
#property description "© Elite Indicadores"
#property link    ""

#property version   ""



#property strict
#property indicator_chart_window
#property indicator_buffers 18
#property indicator_color1 clrWhiteSmoke
#property indicator_color2 clrWhiteSmoke
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 clrYellow
#property indicator_color6 clrYellow
#property indicator_color7 Gray
#property indicator_color12 Magenta
#property indicator_color13 SteelBlue
//Estratégias


double trend;
double RSI;

int SegAntesConfirm = 6;


double forca;
double rsi;
double win[];
double loss[];
int tipe = 1;
double wg[];
double ht[];
double wg2[];
double ht2[];
double l;
double wg1;
double ht1;
int t;
double WinRate;
double WinRateGale;
double WinRate1;
double WinRateGale1;
double WinRateGale22;
double ht22;
double wg22;
double WinRateGale2;
int nbarraa;
int nbak;
int stary;
int intebsk;
double m;
datetime tp;
bool pm=true;
double Barcurrentopen;
double Barcurrentclose;
double m1;
double bc3;
double bb3;
string nome = "teste";
double Barcurrentopen1;
double Barcurrentclose1;

int tb;
int  Posicao = 0;
int w;


double RVI;
double MFI;
double WPR;
//============================================================================================
//Enumerador
enum broker
  {
   Todos = 0, //Todas
   IQOption = 1,
   Binary = 2,
   Spectre = 3,
   Alpari = 4,
   InstaBinary = 5
  };
//============================================================================================


enum corretora
  {
   Todas = 0, //Todas
   IQ = 1, //IQ Option
   Bin = 2 //Binary
  };

//============================================================================================
enum sinal
  {
   MESMA_VELA = 0, //MESMA VELA
   PROXIMA_VELA = 1 //PROXIMA VELA
  };
//============================================================================================
enum tipo_expiracao
  {
   TEMPO_FIXO = 0, //TEMPO FIXO
   RETRACAO = 1 //RETRAÇÃO NA MESMA VELA
  };
//============================================================================================
enum entrar
  {
   NO_TOQUE = 0, //NO TOQUE
   FIM_DA_VELA = 1 //FIM DA VELA
  };
//============================================================================================
enum modo
  {
   MELHOR_PAYOUT = 'M', //MELHOR PAYOUT
   BINARIAS = 'B', //BINARIAS
   DIGITAIS = 'D' //DIGITAIS
  };
//============================================================================================
enum instrument
  {
   DoBotPro= 3, //DO BOT PRO
   Binaria= 0, //BINARIA
   Digital = 1, //DIGITAL
   MaiorPay =2 //MAIOR PAYOUT
  };
//============================================================================================
enum simnao
  {
   NAO = 0, //NÃO
   SIM = 1  //SIM
  };
//============================================================================================
enum antiloss
  {
   IntraBar1 = 0, //NÂO
   ClosedCandle1 = 1 //SIM
  };
//============================================================================================
enum signaltype
  {
   IntraBar = 0,// Mesma Vela
   ClosedCandle = 1// Próxima Vela
  };
//============================================================================================
enum martintype
  {
   NoMartingale = 0, // Sem Martingale (No Martingale)
   OnNextExpiry = 1, // Próxima Expiração (Next Expiry)
   OnNextSignal = 2,  // Próximo Sinal (Next Signal)
   Anti_OnNextExpiry = 3, // Anti-/ Próxima Expiração (Next Expiry)
   Anti_OnNextSignal = 4, // Anti-/ Próximo Sinal (Next Signal)
   OnNextSignal_Global = 5,  // Próximo Sinal (Next Signal) (Global)
   Anti_OnNextSignal_Global = 6 // Anti-/ Próximo Sinal (Global)
  };
//============================================================================================
enum tempo
  {
   Desabilita = 0, //Fechamento de Vela
   UM = 1, //1 Segundo Antes do Fechamento da Vela
   DOIS = 2, //2 Segundos Antes do Fechamento da Vela
   TRES = 3, //3 Segundos Antes do Fechamento da Vela
   QUATRO = 4, //4 Segundos Antes do Fechamento da Vela
   CINCO = 5, //5 Segundos Antes do Fechamento da Vela
   SEIS = 6, //6 Segundos Antes do Fechamento da Vela
   SETE = 7, //7 Segundos Antes do Fechamento da Vela
   OITO = 8, //8 Segundos Antes do Fechamento da Vela
   NOVE = 9 //9 Segundos Antes do Fechamento da Vela
  };
//============================================================================================
enum intervalo
  {
    //Zero = 0, //NENHUM
   Cinco = PERIOD_M5, //AGRESSIVO
   Quinze = PERIOD_M15, //EQUILIBRADO
   Trinta = PERIOD_M30, //MODERADO
//Uma_Hora = PERIOD_H1, //SONOLENTO
//Quatro_Horas = PERIOD_H4, //SONOLENTO
//Um_Dia = PERIOD_D1 //1 DIA
  };

//============================================================================================
datetime TempoTrava;
int velasinal = 0;

#define NL                 "\n"

double fasterEMAnow, slowerEMAnow, fasterEMAprevious, slowerEMAprevious, fasterEMAafter, slowerEMAafter;

string sessao5 ="Elite";  //ESTRATÉGIA Elite
simnao              Elite_Enabled = SIM; // Não desativar





 
//============================================================================================ 
 //ESTRATÉGIAS
//oozaru
int PERIODORVI   = 2; 
double MAXRVI    = 0.3; 
double MINRVI    = -0.3; 
int PERIODOWPR2   = 4; 
int MAXWPR2       = -10; 
int MINWPR2       = -90; 
//============================================================================================
//GOD
int PeriodoRSI_1 = 2;
int MaxRSI_1 = 85;
int MinRSI_1 = 15;
int PERIODOCCI_2 = 4;
int MAXCCI_2 = 100;
int MINCCI_2 = -100;
//============================================================================================
//Frog
int PeriodoRSI_2 = 2;
int MaxRSI_2 = 85;
int MinRSI_2 = 15;
int PERIODOCCI_3 = 3;
int MAXCCI_3 = 80;
int MINCCI_3 = -80;
int BB4_Period  = 10;
int BB4_Dev  = 2;
int BB4_Shift = 3;
//============================================================================================
//Pulback
int PeriodoRSI_6 = 2;
int MaxRSI_6 = 50;
int MinRSI_6 = 50;
// bool   UseSMAFilter1             = false;  
int  MA_Period1                = 20; // Período
int  MA_Shift1                 = 0; // MA Shift 
ENUM_MA_METHOD  MA_Method1  = MODE_SMMA; // Tipo de Média
 ENUM_APPLIED_PRICE    MA1_Applied_Price = PRICE_CLOSE;           // MA PREÇO
 int FilterShift1   = 1;                     // MA Filtro Shift

//============================================================================================
//Wolf
int PeriodoRSI_7 = 2;
int MaxRSI_7 = 92;
int MinRSI_7 = 8;

//============================================================================================
//Fox
int PeriodoRSI_8 = 2;
int MaxRSI_8 = 85;
int MinRSI_8 = 15;
int                   CCI1_Period               = 6;                     // Período
ENUM_APPLIED_PRICE    Apply_to1                 = PRICE_TYPICAL;         // Preço
int                   CCI1_Overbought_Level     = 160;                   // Nível Máximo
int                   CCI1_Oversold_Level       = -160;                  //Nível Mínimo

//============================================================================================
//skunk
int                   CCI2_Period               = 6;                     // Período
ENUM_APPLIED_PRICE    Apply_to2                 = PRICE_TYPICAL;         // Preço
int                   CCI2_Overbought_Level     = 120;                   // Nível Máximo
int                   CCI2_Oversold_Level       = -120;                  //Nível Mínimo
 int PERIODORVI3   = 4; //Período
double MAXRVI3    = 0.2; //Nível Máximo
double MINRVI3    = -0.2; //Nível Mínimo
//============================================================================================
//AUD
int                   CCI3_Period               = 4;                     // Período
ENUM_APPLIED_PRICE    Apply_to3                 = PRICE_TYPICAL;         // Preço
int                   CCI3_Overbought_Level     = 100;                   // Nível Máximo
int                   CCI3_Oversold_Level       = -100;                  //Nível Mínimo
int PeriodoRSI_9 = 3;
int MaxRSI_9 = 85;
int MinRSI_9 = 15;
//============================================================================================
//Jaguar
int                   CCI4_Period               = 3;                     // Período
ENUM_APPLIED_PRICE    Apply_to4                 = PRICE_CLOSE;         // Preço
int                   CCI4_Overbought_Level     = 80;                   // Nível Máximo
int                   CCI4_Oversold_Level       = -80;                  //Nível Mínimo
int PERIODORVI4   = 2; 
double MAXRVI4    = 0.4; 
double MINRVI4    = -0.4; 
int PERIODOWPR3   = 2; 
int MAXWPR3       = -25; 
int MINWPR3       = -75; 
//============================================================================================
//Lizard
int Value       = 5; //Value Chart - Nível

//============================================================================================
//Lost

 int                RSI1_Period=2; // Período
ENUM_APPLIED_PRICE RSI1_Price=PRICE_CLOSE;
int                RSI1_MAX=90; // Nível Máximo
int                RSI1_MIN=10; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame1 = PERIOD_CURRENT; //TimeFrame
 int                RSI2_Period=2; // Período
ENUM_APPLIED_PRICE RSI2_Price=PRICE_CLOSE;
int                RSI2_MAX=90; // Nível Máximo
int                RSI2_MIN=10; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame2 = PERIOD_CURRENT; //TimeFrame
 int                RSI3_Period=3; // Período
ENUM_APPLIED_PRICE RSI3_Price=PRICE_CLOSE;
int                RSI3_MAX=85; // Nível Máximo
int                RSI3_MIN=15; // Nível Mínimo
ENUM_TIMEFRAMES RSITimeFrame3 = PERIOD_CURRENT; //TimeFrame

//============================================================================================
//Willow
int                   CCI5_Period               = 6;                     // Período
ENUM_APPLIED_PRICE    Apply_to5                 = PRICE_TYPICAL;         // Preço
int                   CCI5_Overbought_Level     = 160;                   // Nível Máximo
int                   CCI5_Oversold_Level       = -160;                  //Nível Mínimo
int PERIODOWPR4   = 7; 
int MAXWPR4       = -10; 
int MINWPR4       = -90; 
//============================================================================================
//NoLoss
int                   CCI6_Period               = 14;                     // Período
ENUM_APPLIED_PRICE    Apply_to6                 = PRICE_TYPICAL;         // Preço
int                   CCI6_Overbought_Level     = 180;                   // Nível Máximo
int                   CCI6_Oversold_Level       = -180;                  //Nível Mínimo
int    BB2_Period               = 15;//Período
double    BB2_Dev                  = 3;// Desvio
int    BB2_Shift                = 3;//Deslocar
ENUM_APPLIED_PRICE  Apply_to7   = PRICE_CLOSE;
int PERIODOCCI4 = 14;
int MAXCCI4 = 100;
int MINCCI4 = -100;


int PeriodoRSI_10 = 3;
int MaxRSI_10 = 85;
int MinRSI_10 = 15;
int PeriodoRSI_11 = 2;
int MaxRSI_11 = 85;
int MinRSI_11 = 15;
int PeriodoRSI_12 = 2;
int MaxRSI_12 = 90;
int MinRSI_12 = 10;


//============================================================================================
//Elite sniper
 string IndicatorName4 = "Elite Sniper"; // Nome do Indicador
 int IndiBufferCall4 = 5;      // Buffer Call
 int IndiBufferPut4 = 4;       // Buffer Put
 signaltype SignalType4 = IntraBar; // Tipo de Entrada
 ENUM_TIMEFRAMES ICT4TimeFrame = PERIOD_CURRENT; //TimeFrame
 
 //Filtro de reversão
 string IndicatorName3 = "Trend"; // Nome do Indicador
int IndiBufferCall3 = 5;      // Buffer Call
int IndiBufferPut3 = 3;       // Buffer Put
signaltype SignalType3 = ClosedCandle; // Tipo de Entrada
ENUM_TIMEFRAMES ICT3TimeFrame = PERIOD_CURRENT; //TimeFrame



//============================================================================================
//============================================================================================
//============================================================================================
//============================================================================================
//============================================================================================
input string sessao0X9 ="____________________________________________________"; //______ELITE INDICADORES________
 string  ____________FILTRO___________________ = "========= ASSERTIVIDADE ==================================";
int TotalVelasMinimo = 0;      // FILTRO OOZARU
extern intervalo Intervalo  = Quinze; //GERENCIAMENTO
// int Dias                   = 3; // Dias do Backtest
extern bool Painel          = true;  //Painel || Ativar/Desativar
extern int VelasBack        = 600; //Catalogação
extern bool   AlertsMessage = true;//Menssagem || Ativar/Desativar
extern bool   AlertsSound   = true;//Som || Ativar/Desativar
string  SoundFileUp         = "alert.wav";//Som do alerta CALL
string  SoundFileDown       = "alert.wav";//Som do alerta PUT
string  AlertEmailSubject   = "";        //Assunto do E-mail (vazio = desabilita).
bool    SendPushNotification= false;     //Notificações por PUSH?
int FusoCorretora = 6; //Ajustar fuso horário da corretora

//============================================================================================
// Modulos da estrategias
input string sessaox4 ="_____________________________________";  //xx
extern simnao NoLoss_Enabled = SIM; //No loss
extern simnao  Oozaru_Enabled = NAO; //Oozaru
extern simnao   God_Enabled   = NAO; //God    
extern simnao   FROG_Enabled  = NAO; //Frog  
extern simnao Pulback_Enabled = NAO; //Pulback
extern simnao    Wolf_Enabled = NAO; //Wolf
extern simnao    Fox_Enabled = NAO; //Fox
extern simnao    Skunk_Enabled = NAO; //Skunk
extern simnao    Aud_Enabled = NAO; //Aud
extern simnao    Jaguar_Enabled = NAO; //Jaguar
extern simnao Val_Enabled = NAO; //Val
extern simnao Lost_Enabled = NAO; //Lost
extern simnao Willow_Enabled = NAO; //Willow
extern simnao SorosGale_Enabled = NAO; //SorosGale


//-------------------------------------------------------------------------------------------------------------
//FILTROS EXTRAS
input string  sessao80x   ="__________________________________________________";  //________Filtros________
 //VALUE CHART
extern simnao   Value_Enabled = NAO; //Value Chart 
extern int NumBars = 5; //Período do Value Chart
extern double VC_MAX = 8.0; // Limite Superior
extern double VC_MIN = -8.0; // Limite Inferior
input string x010           ="____________________________________________________";//____________________________________________________
// Sessão PIPS
//input string sessaox7899 ="Tamanho de Vela";  //Tamanho de Vela
 simnao   AtivarTamanhoVela = SIM; //Mínimo Pips  
extern int MinPips   = 400; // Bloquear Vela Maior Que "XX" Pips    

//input string sessaox7899 ="Tamanho de Vela";  //Tamanho de Vela
 simnao   AtivarTamanhoVela1 = SIM; //Maxímo Pips  
extern int maxPips   = 0; // Bloquear Vela Menor Que "XX" Pips


input string x011           ="____________________________________________________";//____________________________________________________
extern simnao Ativar4     = NAO;//Elite Sniper || Ativar/Desativar
extern simnao Ativar3     = NAO;//Filtro de Reversão || Ativar/Desativar
extern int TotalVelasMaximo = 99;//Bloquear Sequência de Velas
string ss = "TrendDirection"; // Ativar Trend
extern simnao Trend = NAO;//TDF
extern int Periodo = 2;
extern simnao SeR         = NAO;//Suporte e Resistência
int MinSeR = 1;   // Mínimo de linhas de Suporte e Resistência


input string ________Filtros_Extras________ ="____________________________________________________";//

extern simnao RSI_Enabled          = NAO; //Rsi || Ativar/Desativar
extern int    RSI_Period           =14; //Período
extern int    RSI_MAX              =70; //Nível Máximo
extern int    RSI_MIN              =30; //Nível Mínimo
extern ENUM_APPLIED_PRICE RSI_Price      =PRICE_CLOSE;//Preço
 ENUM_TIMEFRAMES RSITimeFrame = PERIOD_CURRENT; //TimeFrame

input string x02           ="____________________________________________________";//xx 
extern simnao Bollinger_Enabled= NAO; // Bandas de Bollinger || Ativar/Desativar
extern int    BB_Period               = 20;//Período
extern double    BB_Dev                  = 2;// Desvio
extern int    BB_Shift                = 0;//Deslocar


 input string x012           ="____________________________________________________";//xx 
 extern simnao             Adx_Enabled  = NAO;                  // Adx || Ativar/Desativar
extern int                period_adx   = 5;                  // Período
extern double             level_adx    = 60.0;                 // Level
extern ENUM_APPLIED_PRICE price_adx    = 0;                   // Preço

input string x01           ="____________________________________________________";//xx 
extern simnao Cci_Enabled  = NAO;// Cci || Ativar/Desativar
input int                   CCI_Period               = 6;                     // Período
input ENUM_APPLIED_PRICE    Apply_to                 = PRICE_TYPICAL;         // Preço
input int                   CCI_Overbought_Level     = 160;                   // Nível Máximo
input int                   CCI_Oversold_Level       = -160;                  //Nível Mínimo


input string sessao2786015 ="____________________________________________________";//xx
extern simnao              SO_Enabled = NAO; //Estocástico || Ativar/Desativar
ENUM_TIMEFRAMES STCTimeFrame = PERIOD_CURRENT; //TimeFrame
extern int                SO_KPeriod=5; //%K Período
extern int                SO_DPeriod=3; //%D Período
extern int                SO_Slowing=3; //Lento
 ENUM_MA_METHOD           SO_Mode=MODE_SMA;
 ENUM_STO_PRICE           SO_Price=STO_CLOSECLOSE;
extern int                SO_MAX=80; //Nível Máximo
extern int                SO_MIN=20; //Nível Mínimo

input string sessao27860995 ="____________________________________________________";//xx
extern simnao UsarMFI  = NAO;//Mfi || Ativar/Desativar
extern int PERIODOMFI         = 6; //Período
extern int MAXMFI             = 80; //Nível Máximo
extern int MINMFI             = 20; //Nível Mínimo

input string sessao278600995 ="____________________________________________________";  //xx
extern simnao  UsarWPR = NAO; //Wpr || Ativar/Desativar
extern int PERIODOWPR         = 10; //Período
extern int MAXWPR             = -10; //Nível Máximo
extern int MINWPR             = -90; //Nível Mínimo

input string s00100 = "____________________________________________________"; //xx
extern simnao   UsarRVI2 = NAO;//Rvi || Ativar/Desativar
extern int PERIODORVI2   = 10; //Período
extern double MAXRVI2    = 0.2; //Nível Máximo
extern double MINRVI2    = -0.2; //Nível Mínimo

 string sessao00xx08 ="____________________________________________________";  //xx
 simnao Donchian = NAO; //Donchian || Ativar/Desativar
 int       Periods=24;
 int       Extremes=3;
 int       Margins=-2;
 int       Advance=0;
 int       max_bars=700;

input string sessao00X8 ="____________________________________________________";  //xx
extern simnao AtivarCruzamento = NAO; //Cruzamento de Médias
extern int FasterEMA = 1; // EMA Rápida
extern int SlowerEMA = 5; // EMA Lenta  

input string sessao00X9 ="____________________________________________________";  //xx
input bool  UseSMAFilter  = false; //Média Móvel || Ativar/Desativar
input int  MA_Period = 20; // Período
int  MA_Shift = 0; // MA Shift
extern ENUM_MA_METHOD MA_Method = MODE_SMMA; // Tipo de Média
ENUM_APPLIED_PRICE    MA_Applied_Price  = PRICE_CLOSE; //Aplicar A
int FilterShift = 1; // MA Filtro Shift

input string sessao000678 ="==============================================";  //===========================================================
extern string s7 = "===== Combinar Indicador =====";   //Cuidado com Indicadores que Repinta
extern simnao Ativar1 = NAO;       // Ativar este indicador?
extern string IndicatorName = ""; // Nome do Primeiro Indicador
extern int IndiBufferCall = 0;      // Buffer Call
extern int IndiBufferPut = 1;       // Buffer Put
extern signaltype SignalType = IntraBar; // Tipo de Entrada
ENUM_TIMEFRAMES ICT1TimeFrame = PERIOD_CURRENT; //TimeFrame
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern string s8 = "===== Combinar Indicador =====";   //Cuidado com Indicadores que Repinta
extern simnao Ativar2 = NAO;       // Ativar este indicador?
extern string IndicatorName2 = ""; // Nome do Indicador
extern int IndiBufferCall2 = 0;      // Buffer Call
extern int IndiBufferPut2 = 1;       // Buffer Put
extern signaltype SignalType2 = IntraBar; // Tipo de Entrada
ENUM_TIMEFRAMES ICT2TimeFrame = PERIOD_CURRENT; //TimeFrame


 






// ABA V11
int PeriodoRSI = 2;
int MaxRSI = 90;
int MinRSI = 10;
//int PERIODOCCI = 3;
//int MAXCCI = 100;
//int MINCCI = -100;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




bool upcruzamento = false;
bool downcruzamento = false;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string sessao0098 ="==============================================";  //===========================================================





input string sessao57 ="__________________________________________";  //Configurações Mt2
input int ExpiryMinutes = 5;//EXPIRAÇÃO
input double TradeAmount = 0;//VALOR
input int MartingaleSteps = 0; //Martingales
string NomeDoSinal = "";        //Nome do Sinal
extern simnao OperarComMT2 = NAO; //Mt2 || Ativar/Desativar
 broker Broker = Todos; //Corretora
string SignalName = "Oozaru Pro"+NomeDoSinal;        //Nome do Sinal para MT2 (Opcional)
input martintype MartingaleType = OnNextExpiry;         //Martingale (para mt2)
input double MartingaleCoef = 2.3; //COEFICIENTE MARTINGALE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string sessao278656 ="______________________________________________";  //xx
extern simnao OperarComMX2 = NAO; //Mx2 || Ativar/Desativar
string sinalNome = SignalName; // Nome do Sinal para MX2 TRADING
extern sinal SinalEntradaMX2 = MESMA_VELA;       //Entrar na
extern tipo_expiracao TipoExpiracao = TEMPO_FIXO;       //Tipo de Expiração
input corretora Corretora = Todas; //Corretora
 
input string sessao278658 ="____________________________________________";  //xx
extern simnao OperarComFRANKENSTEIN = NAO;  //Frankenstein || Ativar/Desativar
sinal EntradaSinal = MESMA_VELA; // Entrada na Vela
input string LocalArqRetorno = ""; // Local Onde Salvar o Arquivo de Retorno (opcional)
//-------------------------------------------------------------------------------------+
 string sessao11 ="CONFIGURAÇÃO DO B2IQ";  //CONFIGURAÇÃO DO B2IQ
 simnao OperarComB2IQ = NAO;           //Automatizar com B2IQ?
 sinal SinalEntrada = MESMA_VELA;       //Entrar na
 modo Modalidade = BINARIAS;       //Modalidade
 string vps = "";       //IP:PORTA da VPS (caso utilize)
 string sessao2786588 ="";  //::::::::
//-------------------------------------------------------------------------------------+
 string sessao14 ="CONFIGURAÇÃO DO BOTPRO";  //CONFIGURAÇÃO DO BOTPRO
 simnao OperarComBOTPRO = NAO;         //Automatizar com BOTPRO?
string NameOfSignal = SignalName; // Nome do Sinal para BOTPRO
double TradeAmountBotPro = TradeAmount;
int MartingaleBotPro = MartingaleSteps;      // //Coeficiente do Martingale
 instrument Instrument = Binaria;       // Modalidade
//-------------------------------------------------------------------------------------+
  string         Conector            = "MAGIC TRADER"; //CONFIGURAÇÃO DO MAGIC TRADER
 simnao         MagicTrader         = NAO;                                   // Ativar Magic Trader?
string      NomeIndicador       = SignalName;                          // Nome do Sinal

string sessao22 ="";  //::
string sessao23 ="ANÁLISE PRICE ACTION";  //ANALISE COMBINAÇOES
string sessao24 ="";  //::
simnao AtivarMA = NAO;       // Ativar (PARA COMBINAÇAO) Média Móvel?
int MaLevel = 200; //Período da Média Móvel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string volumevelasdirecao = "===== Leitura de vela (barra) em Pips. ====="; // ======================
simnao AtivaLeituraDeVela = NAO; //Ativa leitura de vela?
int VelasMedirVolume = 0;      // 0 lê a vela atual, 1 a anterior, etc...
double VolumeMinimoBody = 0.0;      // Comprimento mínimo em pips.
double VolumeMaximo = 99999.0;      // Comprimento máximo em pips.
double PavioMinimo = 0.0;      // Mínimo de pavio (sombra) em pips.
double PavioMaximo = 99999.0;      // Máximo de pavio (sombra) em pips.

//-------------------------------------------------------------------------------------+
string sessao26 ="FILTROS EXTRAS";  //FILTROS EXTRAS
double up[];
double down[];
double Confirma[];
double NaoConfirma[];
double CrossUp[];
double CrossDown[];
double CrossDoji[];

double VOpen[],VHigh[],VLow[],VClose[],Typical;

int      Sig_UpCall0 = 0;
int      Sig_UpCall1 = 0;
int      Sig_DnPut0 = 0;
int      Sig_DnPut1 = 0;
int      Sig_Up0 = 0;
int      Sig_Up1 = 0;
int      Sig_Dn0 = 0;
int      Sig_Dn1 = 0;

datetime LastSignal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#import "PriceProLib.ex4"
   void TradePricePro(string ativo, string direcao, int expiracao, string nomedosinal, int martingales, int martingale_em, int data_atual, int corretora);
#import


#import "mt2trading_library.ex4"   // Please use only library version 13.52 or higher !!!
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, string signalname);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, martintype martingaleType, int martingaleSteps, double martingaleCoef, broker myBroker, string signalName, string signalid);
int  traderesult(string signalid);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getlbnum();
bool chartInit(int mid);
int updateGUI(bool initialized, int lbnum, string indicatorName, broker Broker, bool auto, double amount, int expiryMinutes);
int processEvent(const int id, const string& sparam, bool auto, int lbnum);
void showErrorText(int lbnum, broker Broker, string errorText);
void remove(const int reason, int lbnum, int mid);
void cleanGUI();
#import

#import "Connector_Lib.ex4"
void put(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
void call(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
#import

#import "botpro_lib.ex4"
int botpro(string direction, int expiration, int martingale, string symbol, double value, string name, string bindig);
#import

#import "MX2Trading_library.ex4"
bool mx2trading(string par, string direcao, int expiracao, string sinalNome, int Signaltipo, int TipoExpiracao, string TimeFrame, string mID, string Corretora);
#import

#import "Inter_Library.ex4"
int Magic(int time, double value, string active, string direction, double expiration_incandle, string signalname, int expiration_basic);
#import

int Martingales = 0;
// Variables
int lbnum = 0;
bool initgui = false;
datetime sendOnce;
datetime D1;
datetime LastActiontime;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string asset;
string signalID;
bool alerted = false;
input string nc_section2 = "================="; // ==== PARÂMETROS INTERNOS ===
input int mID = 0;      // ID (não altere)
int    bar=0;

int PrimeiraVez = 1;
int FirstTime = 1;

string s[];
datetime TimeBarEntradaUp;
datetime TimeBarEntradaDn;
datetime TimeBarUp;
datetime TimeBarDn;

int PipFactor = 1;

int operacoes = 1;

int dias_add = 0;

datetime NewCandleTime=TimeCurrent();

string estatisticas_gerais;
datetime ultimo_sinal = TimeCurrent();

int primeira_vela = 0;

color  FrameColor  = clrBlack; // Cor do Painel
int    MenuSize    = 1;
int yoffset = 20;
int velas = 0;



//ESTRATÉGIA



//variaveis frank
datetime tempoEnviado;
string terminal_data_path;
string nomearquivo;
string data_patch;
int fileHandle;
int tempo_expiracao;
bool alta;



datetime dfrom;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
  
 //Verifica o Número da Conta
  ///if (AccountInfoInteger (ACCOUNT_LOGIN) !=  62479458)//Guilherme
  //if (AccountInfoInteger (ACCOUNT_LOGIN) !=  62479458)//Guilherme
  //if (AccountInfoInteger (ACCOUNT_LOGIN) !=  62479458)//Guilherme

   
 // { Alert ("Conta não Cadastrada!") ;
 // return (INIT_FAILED);
 // }
  
   //VERIFICA TEMPO DE EXPIRAÇÃO
  if(TimeCurrent() > StringToTime("2423.02.23 20:00:00"))
     {
      ChartIndicatorDelete(0, 0, "Oozaru @MQ4Premium");
      Alert("Licença Expirada");
      return(1);
     }
     


   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Alert("Permita importar dlls!");
      return(INIT_FAILED);
     }

//----
   IndicatorShortName("Profissional");
   SetIndexStyle(0, DRAW_ARROW, EMPTY,1, clrYellow);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, up);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,1,clrYellow);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, down);

   SetIndexStyle(2, DRAW_ARROW, EMPTY,1, clrLimeGreen);
   SetIndexArrow(2, 252);
   SetIndexBuffer(2, Confirma);
   SetIndexStyle(3, DRAW_ARROW, EMPTY,1, clrRed);
   SetIndexArrow(3, 251);
   SetIndexBuffer(3, NaoConfirma);

   SetIndexStyle(4, DRAW_ARROW, EMPTY,1, clrLime);
   SetIndexArrow(4, 77);
   SetIndexBuffer(4, CrossUp);
   SetIndexStyle(5, DRAW_ARROW, EMPTY,1, clrRed);
   SetIndexArrow(5, 77);
   SetIndexBuffer(5, CrossDown);

   SetIndexStyle(6, DRAW_ARROW, EMPTY,3);
   SetIndexArrow(6, 73);
   SetIndexBuffer(6, CrossDoji);

   SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, clrLime);
   SetIndexArrow(7, 252);
   SetIndexBuffer(7, win);
   SetIndexStyle(8, DRAW_ARROW, EMPTY, 1, clrRed);
   SetIndexArrow(8, 251);
   SetIndexBuffer(8, loss);
   SetIndexStyle(9, DRAW_ARROW, EMPTY, 1, clrDarkOrchid);
   SetIndexArrow(9, 252);
   SetIndexBuffer(9, wg);
   SetIndexStyle(10, DRAW_ARROW, EMPTY, 1, clrDarkTurquoise);
   SetIndexArrow(10, 251);
   SetIndexBuffer(10, ht);

   SetIndexStyle(14,DRAW_NONE);
   SetIndexBuffer(14,VHigh);
   SetIndexStyle(15,DRAW_NONE);
   SetIndexBuffer(15,VLow);
   SetIndexStyle(16,DRAW_NONE);
   SetIndexBuffer(16,VOpen);
   SetIndexStyle(17,DRAW_NONE);
   SetIndexBuffer(17,VClose);



   EventSetTimer(1);
   chartInit(mID);  // Chart Initialization
   lbnum = getlbnum(); // Generating Special Connector ID

// Initialize the time flag
   sendOnce = TimeCurrent();

// Generate a unique signal id for MT2IQ signals management (based on timestamp, chart id and some random number)
   MathSrand(GetTickCount());
   if(MartingaleType == OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " OnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else
      if(MartingaleType == Anti_OnNextExpiry)
         signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " AntiOnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
      else
         if(MartingaleType == OnNextSignal)
            signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " OnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
         else
            if(MartingaleType == Anti_OnNextSignal)
               signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " AntiOnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
            else
               if(MartingaleType == OnNextSignal_Global)
                  signalID = "MARTINGALE GLOBAL On Next Signal";   // For global martingale will be terminal-wide unique id generated
               else
                  if(MartingaleType == Anti_OnNextSignal_Global)
                     signalID = "MARTINGALE GLOBAL Anti On Next Signal";   // For global martingale will be terminal-wide unique id generated


   if(OperarComFRANKENSTEIN)
     {

      tempoEnviado = TimeCurrent();
      terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\";
      MqlDateTime time;
      datetime tempo_f = TimeToStruct(TimeLocal(),time);
      string hoje = StringFormat("%d%02d%02d",time.year,time.mon,time.day);
      nomearquivo = hoje+"_retorno.csv";
      data_patch = LocalArqRetorno;
      tempo_expiracao = ExpiryMinutes;
      if(tempo_expiracao == 0)
        {
         tempo_expiracao = Period();
        }

      if(data_patch == "")
        {
         data_patch = terminal_data_path;
        }

      if(FileIsExist(nomearquivo,0))
        {
         Print("Local do Arquivo: "+data_patch+nomearquivo);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         string data = "tempo,ativo,acao,expiracao";
         FileWrite(fileHandle,data);
         FileClose(fileHandle);

        }
      else
        {
         Print("Criando Arquivo de Retorno...");
         Print("Local do Arquivo: "+data_patch+nomearquivo);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         string data = "tempo,ativo,acao,expiracao";
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
        }

     }



// Symbol name should consists of 6 first letters
   if(StringLen(Symbol()) >= 6)
      asset = StringSubstr(Symbol(),0,6);
   else
      asset = Symbol();

// Cater for fractional pips
   if(Digits == 2 || Digits == 4)
      PipFactor = 1;
   if(Digits == 3 || Digits == 5)
      PipFactor = 10;
   if(Digits == 6)
      PipFactor = 100;
   if(Digits == 7)
      PipFactor = 1000;

//----
   return(INIT_SUCCEEDED);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
//----
   ObjectsDeleteAll(0, 0, OBJ_LABEL);
   ObjectsDeleteAll(0, 0, OBJ_RECTANGLE_LABEL);

  }
double calctam()
{if(Digits<=3)
{return(0.001);}
else if(Digits>=4)
{return(0.00001);}
else{return(0);}
}
bool tamanhodevela(int i)
{          double tamanho = calctam()*MinPips;

      
         if((High[i+0]-Low[i+0])<=tamanho)
         {return(true);}else{return(false);}
         

}

double calctam1()
{if(Digits<=3)
{return(0.001);}
else if(Digits>=4)
{return(0.00001);}
else{return(0);}
}
bool tamanhodevela1(int i)
{          double tamanho = calctam1()*maxPips;

      
         if((High[i+0]-Low[i+0])>=tamanho)
         {return(true);}else{return(false);}
         

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





   bool ativa = false;

 for(int i=VelasBack; i>=0; i--) {

      dfrom = TimeCurrent() - 60 * 60 * 24*VelasBack;

      if(Time[i] > dfrom)
        {

         bool up_bb, dn_bb, up_cci,dn_cci, up_rsi, dn_rsi, up_so, dn_so, up_elite, dn_elite,up_aud, dn_aud, up_lost, dn_lost,up_noloss, dn_noloss,
         up_vc, dn_vc, up_god, dn_god, up_pul, dn_pul,up_oozaru, dn_oozaru, up_wolf, dn_wolf, up_jaguar, dn_jaguar, up_willow, dn_willow,
         up_frog, dn_frog, up_val, dn_val, up_adx, dn_adx, up_don, dn_don, up_fox, dn_fox, up_skunk, dn_skunk, up_sg, dn_sg ;
         double up1 = 0, dn1 = 0;
         double up2 = 0, dn2 = 0;
         double up3 = 0, dn3 = 0;
         double up4 = 0, dn4 = 0;
         
         
         double CCI_12 = iCCI(NULL,_Period,PERIODOCCI4,PRICE_TYPICAL,i);
         double CCI_11   = iCCI(NULL,PERIOD_CURRENT,CCI6_Period,Apply_to6,0+i);
         double WPR_4 = iWPR(Symbol(),Period(),PERIODOWPR4,i);
         double CCI_10   = iCCI(NULL,PERIOD_CURRENT,CCI5_Period,Apply_to5,i);
         double RSI_12 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double RSI_11 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double RSI_10 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double CCI_9   = iCCI(NULL,PERIOD_CURRENT,CCI4_Period,Apply_to4,i);
         double RVI_5 = iRVI(Symbol(),Period(),PERIODORVI4,0,i);
         double WPR_3 = iWPR(Symbol(),Period(),PERIODOWPR3,i);
         double RSI_9 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double CCI_8   = iCCI(NULL,PERIOD_CURRENT,CCI3_Period,Apply_to3,i);
         double CCI_7   = iCCI(NULL,PERIOD_CURRENT,CCI2_Period,Apply_to2,i);
         double RVI_4 = iRVI(Symbol(),Period(),PERIODORVI3,0,i);
         double RSI_8 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double CCI_6   = iCCI(NULL,PERIOD_CURRENT,CCI1_Period,Apply_to1,i); 
         double RSI_6 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double MA_1 =iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,i);
         double trd2 = iCustom(Symbol(),Period(),"value",3,i);
         double CCI_5 = iCCI(NULL,_Period,PERIODOCCI_3,PRICE_TYPICAL,i); //Price
         double CCI_2 = iCCI(NULL,_Period,PERIODOCCI_2,PRICE_TYPICAL,i+1);
         double CCI   = iCCI(NULL,PERIOD_CURRENT,CCI_Period,Apply_to,i); 
         double CCI_4 = iCCI(NULL,_Period,PERIODOCCI_3,PRICE_TYPICAL,i);
         double RSI_5 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double RSI_1 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double RSI_3 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double RVI_3 = iRVI(Symbol(),Period(),PERIODORVI,0,i);//0 = Linha do RVI, 1 = Linha de sinal
         double WPR_2 = iWPR(Symbol(),Period(),PERIODOWPR2,i);
         double RSI_7 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         double ADX = iADX(NULL,0,period_adx,price_adx,MODE_MAIN, i);
         double DON = iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,MODE_LOW,i));
         
         bool ma_up, ma_dn;
         
         //Aqui inincia as estrategias
         
//==========================================================================================================================
         if(SorosGale_Enabled){
            up_sg =  RSI_10<=MinRSI_10 && RSI_11<=MinRSI_11 && RSI_12<=MinRSI_12 ;
            dn_sg =  RSI_10>=MaxRSI_10 && RSI_11>=MinRSI_11 && RSI_12>=MinRSI_12  ;
            } else 
            { 
            up_sg = true;
            dn_sg = true;
            }  
//==========================================================================================================================

         
         
         
          if (NoLoss_Enabled) {
            up_noloss = Close[i+0]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+0)
                       && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+0)
                       && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+1)
                       && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+1)
                       && CCI_12<MINCCI4 &&  CCI_11<CCI_Oversold_Level   ;

            dn_noloss = Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+0)
                       && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+0)
                       && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+1)
                       && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+1)
                       && CCI_12>MAXCCI4  && CCI_11>CCI_Overbought_Level     ;
         } else {
            up_noloss = true;
            dn_noloss = true;
         }

//==========================================================================================================================
          if (Willow_Enabled) {
          up_willow  = CCI_10<CCI5_Oversold_Level && WPR_4<=MINWPR4;
          dn_willow  = CCI_10>CCI5_Overbought_Level && WPR_4>=MINWPR4;
          } else {
            up_willow = true;
            dn_willow = true;
         }

//==========================================================================================================================

          if(Lost_Enabled){
             up_lost = iRSI(NULL, RSITimeFrame1, RSI1_Period, RSI1_Price, i) < RSI1_MIN
                    && iRSI(NULL, RSITimeFrame2, RSI2_Period, RSI2_Price, i) < RSI2_MIN 
                    && iRSI(NULL, RSITimeFrame3, RSI3_Period, RSI3_Price, i) < RSI3_MIN    
                             ;
           dn_lost = iRSI(NULL, RSITimeFrame1, RSI1_Period, RSI1_Price, i) > RSI1_MAX
                   && iRSI(NULL, RSITimeFrame2, RSI2_Period, RSI2_Price, i) > RSI2_MAX 
                    && iRSI(NULL, RSITimeFrame3, RSI3_Period, RSI3_Price, i) > RSI3_MAX  
                             
                             ;
            } else 
            { 
            up_lost = true;
            dn_lost = true;
            }  




         
//==========================================================================================================================
          if(Jaguar_Enabled){
            up_jaguar = CCI_9<CCI4_Oversold_Level && RVI_5<=MINRVI4 && WPR_3<=MINWPR3 ;
            dn_jaguar = CCI_9>CCI4_Overbought_Level && RVI_5>=MAXRVI4 && WPR_3>=MAXWPR3 ;
            } else 
            { 
            up_jaguar = true;
            dn_jaguar = true;
            }  



//==========================================================================================================================
           if(Aud_Enabled){
            up_aud = CCI_8<CCI3_Oversold_Level && RSI_9<=MinRSI_9 ;
            dn_aud =   CCI_8>CCI3_Overbought_Level && RSI_9>=MaxRSI_9 ;
            } else 
            { 
            up_aud = true;
            dn_aud = true;
            }  


//==========================================================================================================================
          if(Skunk_Enabled){
            up_skunk = CCI_7<CCI2_Oversold_Level && RVI_4<=MINRVI3 ;
            dn_skunk =   CCI_7>CCI2_Overbought_Level && RVI_4>=MAXRVI3 ;
            } else 
            { 
            up_skunk = true;
            dn_skunk = true;
            }       
         
         
//==========================================================================================================================
        if(Fox_Enabled){
            up_fox = RSI_8<=MinRSI_8 && CCI_6<CCI1_Oversold_Level ;
            dn_fox =  RSI_8>=MaxRSI_8 && CCI_6>CCI1_Overbought_Level ;
            } else 
            { 
            up_fox = true;
            dn_fox = true;
            }

         
//==========================================================================================================================         
          if (Donchian) {
        up_don  =   DON<Open[Highest(NULL,0,MODE_OPEN,Periods)];
        dn_don  =   DON>Open[Lowest(NULL,0,MODE_OPEN,Periods)];
         } else {
            up_don = true;
            dn_don = true;
         }
//==========================================================================================================================         
          
         if (Adx_Enabled) {
        up_adx  =   (ADX<=level_adx);
        dn_adx  =   (ADX>=level_adx);
         } else {
            up_adx = true;
            dn_adx = true;
         }
//==========================================================================================================================         
          if(Wolf_Enabled){
            up_wolf = RSI_7<=MinRSI_7 ;
            dn_wolf =  RSI_7>=MaxRSI_7 ;
            } else 
            { 
            up_wolf = true;
            dn_wolf = true;
            }
         
//==========================================================================================================================         
         
         if(Oozaru_Enabled) {
          up_oozaru  = RVI_3<=MINRVI && WPR_2<=MINWPR2 ;
          dn_oozaru  = RVI_3>=MAXRVI && WPR_2>=MAXWPR2 ;
          } else {
            up_oozaru = true;
            dn_oozaru = true;
         }


//====================================================================================================================================
         if (Cci_Enabled) {
          up_cci  = CCI<CCI_Oversold_Level;
          dn_cci  = CCI>CCI_Overbought_Level;
          } else {
            up_cci = true;
            dn_cci = true;
         }
         
//====================================================================================================================================
        if(Val_Enabled) {
          up_val  = trd2<=-Value;
          dn_val  =  trd2>=Value;
          } else {
            up_val = true;
            dn_val = true;
         }
//====================================================================================================================================

          if(FROG_Enabled){
            up_frog = Close[i+0]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+0)
                       && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+0)
                       && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+1)
                       && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_LOWER,i+1)
                       && (CCI_4<MAXCCI_3 && RSI_5<=MaxRSI_2);
            
            dn_frog =  Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+0)
                       && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+0)
                       && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+1)
                       && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB4_Period,BB4_Dev,BB4_Shift,0,MODE_UPPER,i+1)
                       && (CCI_4>MINCCI_3 && RSI_5>=MinRSI_2);
                       
            } else 
            { 
            up_frog = true;
            dn_frog = true;
            }
         
//====================================================================================================================================         
         
         
         if(God_Enabled){
            up_god = (CCI_2>MINCCI_2 && RSI_1<=MinRSI );
            dn_god = (CCI_2<MAXCCI_2 && RSI_1>=MaxRSI);
            } else 
            { 
            up_god = true;
            dn_god = true;
            }

//====================================================================================================================================
        if (Bollinger_Enabled) {
        up_bb = Close[i+0]<iBands(NULL,PERIOD_CURRENT ,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+0)
                       && Open[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+0)
                       && Open[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+1)
                       && Close[i+1]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_LOWER,i+1)
                        ;
        dn_bb = Close[i+0]>iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+0)
                       && Open[i+0]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+0)
                       && Open[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+1)
                       && Close[i+1]<iBands(NULL,PERIOD_CURRENT,BB_Period,BB_Dev,BB_Shift,0,MODE_UPPER,i+1)
                        ;
         } else 
         { 
         up_bb = true;
         dn_bb = true;
         }

//====================================================================================================================================
         if(Value_Enabled)
           {
            // Chamada da Função do Value Chart
            //+------------------------------------------------------------------+

            VOpen[i]    = (Open[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VHigh[i]    = (High[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VLow[i]     = (Low[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
            VClose[i]   = (Close[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));

            //+------------------------------------------------------------------+

            // Verificação do Sinal do Value Chart
            up_vc = VClose[i] <= VC_MIN;
            dn_vc = VClose[i] >= VC_MAX;
           }
         else
           {
            up_vc = true;
            dn_vc = true;
            }

//====================================================================================================================================
           if(RSI_Enabled)
           {
           up_rsi = iRSI(NULL, RSITimeFrame, RSI_Period, RSI_Price, i) < RSI_MIN;
           dn_rsi = iRSI(NULL, RSITimeFrame, RSI_Period, RSI_Price, i) > RSI_MAX;
           }
           else
           {
           up_rsi = true;
           dn_rsi = true;
           }
//====================================================================================================================================
           if(SO_Enabled)
           {
           up_so = iStochastic(NULL, STCTimeFrame, SO_KPeriod, SO_DPeriod, SO_Slowing, SO_Mode, SO_Price, MODE_SIGNAL, i) < SO_MIN
                         ;
           
           dn_so = iStochastic(NULL, STCTimeFrame, SO_KPeriod, SO_DPeriod, SO_Slowing, SO_Mode, SO_Price, MODE_SIGNAL, i) > SO_MAX
                     ;
           }
           else
           {
           up_so = true;
           dn_so = true;
           }
//====================================================================================================================================
           if (Pulback_Enabled){
            
           up_pul = ( RSI_6<=MinRSI_6  && Close[i+FilterShift]>MA_1);
           dn_pul = ( RSI_6>=MaxRSI_6  && Close[i+FilterShift]<MA_1);
            }
           else
           {
           up_pul = true;
           dn_pul = true;
           }
//====================================================================================================================================
         // primeiro indicador
           if(Ativar1)
           {
           up1 = iCustom(NULL, ICT1TimeFrame, IndicatorName, IndiBufferCall, i+SignalType);
           dn1 = iCustom(NULL, ICT1TimeFrame, IndicatorName, IndiBufferPut, i+SignalType);
           up1 = sinal_buffer(up1);
           dn1 = sinal_buffer(dn1);
           }
           else
           {
           up1 = true;
           dn1 = true;
           }
//====================================================================================================================================
         ///////////////////////////////////////////////////////
         //segundo indicador
           if(Ativar2)
           {
           up2 = iCustom(NULL, ICT2TimeFrame, IndicatorName2, IndiBufferCall2, i+SignalType2);
           dn2 = iCustom(NULL, ICT2TimeFrame, IndicatorName2, IndiBufferPut2, i+SignalType2);
           up2 = sinal_buffer(up2);
           dn2 = sinal_buffer(dn2);
           }
           else
           {
           up2 = true;
           dn2 = true;
           }
//====================================================================================================================================
         ///////////////////////////////////////////////////////
         //terceiro indicador
           if(Ativar3)
           {
           up3 = iCustom(NULL, ICT3TimeFrame, IndicatorName3, IndiBufferCall3, i+SignalType3);
           dn3 = iCustom(NULL, ICT3TimeFrame, IndicatorName3, IndiBufferPut3, i+SignalType3);
           up3 = sinal_buffer(up3);
           dn3 = sinal_buffer(dn3);
           }
           else
           {
           up3 = true;
           dn3 = true;
           }
//====================================================================================================================================
           //quarto indicador
           if(Ativar4)
           {
           up4 = iCustom(NULL, ICT4TimeFrame, IndicatorName4, IndiBufferCall4, i+SignalType4);
           dn4 = iCustom(NULL, ICT4TimeFrame, IndicatorName4, IndiBufferPut4, i+SignalType4);
           up4 = sinal_buffer(up4);
           dn4 = sinal_buffer(dn4);
           }
           else
           {
           up4 = true;
           dn4 = true;
           }

 
//====================================================================================================================================
           if(AtivarMA)
           {
           double EMA_DUZENTOS = iMA(_Symbol, PERIOD_CURRENT, MaLevel,0,MODE_EMA,PRICE_CLOSE, i);
           if(Open[i] > EMA_DUZENTOS
           )
           {
           ma_up = true;
           }
           else
           {
           ma_up = false;
           }
           if(Open[i] < EMA_DUZENTOS
           )
           {
           ma_dn = true;
           }
           else
           {
           ma_dn = false;
           }
           }
           else
           {
            ma_up = true;
            ma_dn = true;
           }
//====================================================================================================================================
           if(Trend)
           {
           trend = iCustom(Symbol(),Period(),"Trend",Periodo,i);
           }
//====================================================================================================================================
         //double trd1 = iCustom(Symbol(),Period(),"val",3,i);
         double MA = iMA(NULL,PERIOD_CURRENT,MA_Period,MA_Shift,MA_Method,MA_Applied_Price,i+FilterShift);
         double RVI_2 = iRVI(Symbol(),Period(),PERIODORVI2,0,i);//0 = Linha do RVI, 1 = Linha de sinal
         MFI = iMFI(Symbol(),Period(),PERIODOMFI,i);
         WPR = iWPR(Symbol(),Period(),PERIODOWPR,i);
         fasterEMAnow = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i);
         fasterEMAprevious = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i+1);
         fasterEMAafter = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_TYPICAL, i-1);
//====================================================================================================================================
         slowerEMAnow = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i);
         slowerEMAprevious = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i+1);
         slowerEMAafter = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_TYPICAL, i-1);
//====================================================================================================================================
         if(AtivarCruzamento)
         {
         if((fasterEMAnow > slowerEMAnow) && (fasterEMAprevious < slowerEMAprevious) && (fasterEMAafter > slowerEMAafter))
         {upcruzamento = true;}
         else
         {
         upcruzamento = false;
         }
//====================================================================================================================================
         if((fasterEMAnow < slowerEMAnow) && (fasterEMAprevious > slowerEMAprevious) && (fasterEMAafter < slowerEMAafter))
         {downcruzamento = true;}
         else
         {
         downcruzamento = false;
         }

         }
         
//====================================================================================================================================
         if(Elite_Enabled)
         {
         up_elite  = (!AtivarCruzamento || upcruzamento) 
         && (!UsarRVI2 || RVI_2<=MINRVI2)  && (!UsarMFI || MFI<=MINMFI)
         && (!UsarWPR || WPR<=MINWPR) 
         && (!UseSMAFilter || (UseSMAFilter && Close[i+FilterShift]>MA)) ;

         dn_elite   = (!AtivarCruzamento || downcruzamento)
         && (!UsarRVI2 || RVI_2>=MAXRVI2) && (!UsarMFI || MFI>=MAXMFI) 
         && (!UsarWPR || WPR>=MAXWPR)    
         && (!UseSMAFilter || (UseSMAFilter && Close[i+FilterShift]<MA))  ;

         }
         else
         {
         up_elite = true;
         dn_elite = true;
         }
//====================================================================================================================================
         RSI = iRSI(Symbol(),Period(),0,PRICE_OPEN,i);
         double RSI_4 = iRSI(Symbol(),Period(),2,PRICE_CLOSE,i);
         
 //====================================================================================================================================

//====================================================================================================================================

//====================================================================================================================================
         //Ativador Call
         if(
            ((AtivarTamanhoVela && tamanhodevela(i)) || !AtivarTamanhoVela) &&
            ((AtivarTamanhoVela1 && tamanhodevela1(i)) || !AtivarTamanhoVela1) &&
               up_val
            && up_bb && up_cci && up_pul && up_adx
            && up_oozaru && up_don && up_fox && up_skunk
            && up_wolf && up_aud && up_jaguar && up_lost
            && up_god && up_willow && up_noloss &&  up_sg
            && up_frog
            && up_elite
            && up_vc  && up_rsi && up_so
            && up1 && up2
            && up3 && up4 
            && horizontal(i, "up")
            && down[i] == EMPTY_VALUE
            && up[i] == EMPTY_VALUE
            && sequencia("call", i)
            && sequencia_minima("call", i) &&
            (!Trend || trend<=-0.99)

           )
           {
            if(Time[i] > LastSignal + Intervalo*60)
              {
               CrossUp[i] = iLow(_Symbol,PERIOD_CURRENT,i)-5*Point();
               Sig_Up0=1;
               LastSignal = Time[i];

              }
           }
         else
           {
            CrossUp[i] = EMPTY_VALUE;
            Sig_Up0=0;

           }

         //Ativador Put
         if(
            ((AtivarTamanhoVela && tamanhodevela(i)) || !AtivarTamanhoVela) &&
            ((AtivarTamanhoVela1 && tamanhodevela1(i)) || !AtivarTamanhoVela1) &&

               dn_val
            && dn_bb && dn_cci && dn_pul && dn_adx
            && dn_oozaru && dn_don && dn_fox && dn_skunk
            && dn_wolf && dn_aud && dn_jaguar && dn_lost
            && dn_god && dn_willow && dn_noloss && dn_sg
            && dn_frog
            && dn_elite
            && dn_vc   && dn_rsi && dn_so
            && dn1 && dn2 && dn3 && dn4 
            && horizontal(i, "down")
            && up[i] == EMPTY_VALUE
            && down[i] == EMPTY_VALUE
            && sequencia("put", i)
            && sequencia_minima("put", i) &&
            (!Trend || trend>=0.99)
           )
           {
            if(Time[i] > LastSignal + Intervalo*60)
              {
               CrossDown[i] = iHigh(_Symbol,PERIOD_CURRENT,i)+5*Point();
               Sig_Dn0=1;
               LastSignal = Time[i];
              }
           }
         else
           {
            CrossDown[i] = EMPTY_VALUE;
            Sig_Dn0=0;
           }

         if(sinal_buffer(CrossUp[i+1]) && !sinal_buffer(up[i+1]))
           { LastSignal = Time[i];
            up[i] = iLow(_Symbol,PERIOD_CURRENT,i)-5*Point();
           }

         if(sinal_buffer(CrossDown[i+1]) && !sinal_buffer(down[i+1]))
           { LastSignal = Time[i];
            down[i] = iHigh(_Symbol,PERIOD_CURRENT,i)+5*Point();
           }
        }
     }
   if(sinal_buffer(down[0]))
     {
      Sig_DnPut0 = 1;
     }
   else
     {
      Sig_DnPut0 = 0;
     }

   if(sinal_buffer(up[0]))
     {
      Sig_UpCall0 = 1;
     }
   else
     {
      Sig_UpCall0 = 0;
     }





   if(Time[0] > sendOnce && Sig_UpCall0==1)
     {
     
     
     
      if(OperarComMT2)
        {
         mt2trading(asset, "CALL", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, SignalName, signalID);
         Print("CALL - Sinal enviado para MT2!");
        }
      if(OperarComB2IQ)
        {
         call(Symbol(), ExpiryMinutes, Modalidade, SinalEntrada, vps);
         Print("CALL - Sinal enviado para B2IQ!");
        }
      if(OperarComBOTPRO)
        {
         botpro("CALL",ExpiryMinutes,MartingaleBotPro,Symbol(),TradeAmountBotPro,NameOfSignal,Instrument);
         Print("CALL - Sinal enviado para BOTPRO!");
        }
      if(OperarComMX2)
        {
         mx2trading(Symbol(), "CALL", ExpiryMinutes, sinalNome, SinalEntradaMX2, TipoExpiracao, PeriodString(), mID, Corretora);
         Print("CALL - Sinal enviado para MX2!");
        }
      if(MagicTrader)
        {
         Magic(int(TimeGMT()),TradeAmount, Symbol(), "CALL", ExpiryMinutes, NomeIndicador, int(ExpiryMinutes));
         Print("CALL - Sinal enviado para MagicTrader!");
        }
        
        if(OperarComFRANKENSTEIN)
        {
         Print(Symbol(), ",", ExpiryMinutes, ",CALL,", Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END);
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",call,"+IntegerToString(ExpiryMinutes);
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
        }

      sendOnce = Time[0];
     }

   if(Time[0] > sendOnce && Sig_DnPut0 == 1)
     {
     
    
      if(OperarComMT2)
        {
         mt2trading(asset, "PUT", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, SignalName, signalID);
         Print("PUT - Sinal enviado para MT2!");
        }
      if(OperarComB2IQ)
        {
         put(Symbol(), ExpiryMinutes, Modalidade, SinalEntrada, vps);
         Print("PUT - Sinal enviado para B2IQ!");
        }
      if(OperarComBOTPRO)
        {
         botpro("PUT",ExpiryMinutes,MartingaleBotPro,Symbol(),TradeAmountBotPro,NameOfSignal,Instrument);
         Print("PUT - Sinal enviado para BOTPRO!");
        }
      if(OperarComMX2)
        {
         mx2trading(Symbol(), "PUT", ExpiryMinutes, sinalNome, SinalEntradaMX2, TipoExpiracao, PeriodString(), mID, Corretora);
         Print("PUT - Sinal enviado para MX2!");
        }
      if(MagicTrader)
        {
         Magic(int(TimeGMT()), TradeAmount, Symbol(), "PUT", ExpiryMinutes, NomeIndicador, int(ExpiryMinutes));
         Print("PUT - Sinal enviado para MagicTrader!");
        }
        
        if(OperarComFRANKENSTEIN)
        {
         Print(Symbol(), ",", ExpiryMinutes,",PUT,", Time[0]);
         fileHandle = FileOpen(nomearquivo,FILE_CSV|FILE_READ|FILE_WRITE);
         FileSeek(fileHandle, 0, SEEK_END);
         string data = IntegerToString((long)TimeGMT())+","+Symbol()+",put,"+IntegerToString(ExpiryMinutes);
         FileWrite(fileHandle,data);
         FileClose(fileHandle);
        }

      sendOnce = Time[0];
     }



//-----------------------------------------------ALERTAS----------------------------------------------------+

   if(AlertsMessage || AlertsSound)
     {

      string message1 = (SignalName+" - "+Symbol()+" : Possível Compra "+PeriodString());
      string message2 = (SignalName+" - "+Symbol()+" : Possível Venda "+PeriodString());

      if(TimeBarUp!=Time[0] && Sig_Up0==1)
        {
         if(AlertsMessage)
            Alert(message1);




         if(AlertsSound)
            PlaySound(SoundFileUp);
         if(AlertEmailSubject > "")
            SendMail(AlertEmailSubject,message1);
         if(SendPushNotification)
            SendNotification(message1);
         TimeBarUp=Time[0];
        }
      if(TimeBarDn!=Time[0] && Sig_Dn0==1)
        {
         if(AlertsMessage)
            Alert(message2);


         if(AlertsSound)
            PlaySound(SoundFileDown);
         if(AlertEmailSubject > "")
            SendMail(AlertEmailSubject,message2);
         if(SendPushNotification)
            SendNotification(message2);
         TimeBarDn=Time[0];
        }
     }

   if(AlertsMessage || AlertsSound)
     {
      string messageEntrada1 = (SignalName+" - "+Symbol()+" Call "+PeriodString());
      string messageEntrada2 = (SignalName+" - "+Symbol()+" Put "+PeriodString());

      if(TimeBarEntradaUp!=Time[0] && Sig_UpCall0==1)
        {
         if(AlertsMessage)
            Alert(messageEntrada1);
         if(AlertsSound)
            PlaySound("alert2.wav");
         TimeBarEntradaUp=Time[0];
        }

      if(TimeBarEntradaDn!=Time[0] && Sig_DnPut0==1)
        {
         if(AlertsMessage)
            Alert(messageEntrada2);
         if(AlertsSound)
            PlaySound("alert2.wav");
         TimeBarEntradaDn=Time[0];
        }
     }
   backteste();



   return (prev_calculated);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int thisbarminutes = Period();

   double thisbarseconds=thisbarminutes*60;
   double seconds=thisbarseconds -(TimeCurrent()-Time[0]);

   double minutes= MathFloor(seconds/60);
   double hours  = MathFloor(seconds/3600);

   minutes = minutes -  hours*60;
   seconds = seconds - minutes*60 - hours*3600;

   string sText=DoubleToStr(seconds,0);
   if(StringLen(sText)<2)
      sText="0"+sText;
   string mText=DoubleToStr(minutes,0);
   if(StringLen(mText)<2)
      mText="0"+mText;
   string hText=DoubleToStr(hours,0);
   if(StringLen(hText)<2)
      hText="0"+hText;

   ObjectSetText("Time_Remaining", ""+mText+":"+sText, 13, "Verdana", StrToInteger(mText+sText) >= 0010 ? clrWhite : clrGold);

   ObjectSet("Time_Remaining",OBJPROP_CORNER,1);
   ObjectSet("Time_Remaining",OBJPROP_XDISTANCE,10);
   ObjectSet("Time_Remaining",OBJPROP_YDISTANCE,10);
   ObjectSet("Time_Remaining",OBJPROP_BACK,False);

   if(!initgui)
     {
      ObjectsDeleteAll(0,"Obj_*");
      initgui = true;
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sinal_buffer(double value)
  {
   if(value != 0 && value != EMPTY_VALUE)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sequencia_minima(string direcao, int vela)
  {

   if(TotalVelasMinimo == 0)
     {
      return true;
     }
   int total=0;
   for(int i=0; i<TotalVelasMinimo; i++)
     {
      if(Open[i+vela+1] < Close[i+vela+1] && direcao == "call")
        {
         total++;
        }
      if(Open[i+vela+1] > Close[i+vela+1] && direcao == "put")
        {
         total++;
        }
     }

   if(total >= TotalVelasMinimo)
     {
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sequencia(string direcao, int vela)
  {

   int total=0;
   for(int i=0; i<TotalVelasMaximo; i++)
     {

      if(Open[i+vela+1] < Close[i+vela+1] && direcao == "call")
        {
         return true;
        }
      if(Open[i+vela+1] > Close[i+vela+1] && direcao == "put")
        {
         return true;
        }

     }
   return false;

  }

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool horizontal(int vela, string posicao)
  {

   int total_ser = 1;

   if(SeR)
     {

      int obj_total=ObjectsTotal();
      for(int A=0; A<obj_total; A++)
        {
         string name=ObjectName(A);
         int objectType = ObjectType(name);
         double p2 = "";

         if(objectType == OBJ_HLINE)
           {
            p2 = ObjectGet(name, OBJPROP_PRICE1);

            if(Open[vela] < MarketInfo(Symbol(), MODE_BID) && Open[vela] < p2 && High[vela] >= p2)
              {
               if(total_ser >= MinSeR
                 )
                 {
                  if(posicao == "down")
                    {
                     return true;
                    }
                 }
               total_ser++;
              }


            if(Open[vela] > MarketInfo(Symbol(), MODE_BID) && Open[vela] > p2 && Low[vela] <= p2)
              {
               if(total_ser >= MinSeR
                 )
                 {
                  if(posicao == "up")
                    {
                     return true;
                    }
                 }
               total_ser++;
              }

           }



        }

     }
   else
     {
      return true;
     }
   return false;
  }



//+------------------------------------------------------------------+
void drawLabel(string name,double lvl,color Color)
  {
   if(ObjectFind(name) != 0)
     {
      ObjectCreate(name, OBJ_TEXT, 0, Time[10], lvl);
      ObjectSetText(name, name, 8, "Arial", EMPTY);
      ObjectSet(name, OBJPROP_COLOR, Color);
     }
   else
     {
      ObjectMove(name, 0, Time[10], lvl);
     }
  }


//+------------------------------------------------------------------+
void drawLine(double lvl,string name, color Col,int type)
  {
   if(ObjectFind(name) != 0)
     {
      ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);

      if(type == 1)
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
      else
         ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);

      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name,OBJPROP_WIDTH,3);

     }
   else
     {
      ObjectDelete(name);
      ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);

      if(type == 1)
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
      else
         ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);

      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name,OBJPROP_WIDTH,3);

     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodString()
  {
   switch(_Period)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
     }
   return("M" + string(_Period));
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommentLab(string CommentText, int Ydistance, int Xdistance, int Label, int Cor)
  {
   string label_name;
   int CommentIndex = 0;

   label_name = "label" + Label;

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,label_name, OBJPROP_CORNER, 0);
//--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,Xdistance);
//--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,Ydistance);
//--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,Cor);
//--- define text for object Label
   ObjectSetString(0,label_name,OBJPROP_TEXT,CommentText);
//--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Tahoma");
//--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
//--- disable for mouse selecting
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, label_name,OBJPROP_BACK,false);
//--- draw it on the chart
   ChartRedraw(0);

  }
//+------------------------------------------------------------------+
//FIM...
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime time=0;
   if(time==0)
     {
      time=Time[0];
      return false;
     }
   if(time!=Time[0])
     {
      time=Time[0];
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
void backteste()
  {
   for(int gf=VelasBack; gf>=0; gf--)
     {
      m=(Close[gf]-Open[gf])*10000;
      //sg
      if(down[gf]!=EMPTY_VALUE && down[gf]!=0 && m<0)
        { 
         win[gf] = Low[gf] - 5*Point;
         loss[gf] = EMPTY_VALUE;
        }

      if(down[gf]!=EMPTY_VALUE && down[gf]!=0 && m>=0)
        {
         loss[gf] = Low[gf] - 5*Point;
         win[gf] = EMPTY_VALUE;
        }

      if(up[gf]!=EMPTY_VALUE && up[gf]!=0 && m>0)
        {
         win[gf] = High[gf] + 10*Point;
         loss[gf] = EMPTY_VALUE;
        }

      if(up[gf]!=EMPTY_VALUE && up[gf]!=0 && m<=0)
        {
         loss[gf] = High[gf] + 10*Point;
         win[gf] = EMPTY_VALUE;
        }
      //
      //g1
      if(loss[gf+1]!=EMPTY_VALUE && down[gf+1]!=EMPTY_VALUE && down[gf+1]!=0 && m<0)
        {
         wg[gf] = High[gf] + 5*Point;
         ht[gf] = EMPTY_VALUE;
        }

      if(loss[gf+1]!=EMPTY_VALUE && down[gf+1]!=EMPTY_VALUE && down[gf+1]!=0 && m>=0)
        {
         ht[gf] = High[gf] + 5*Point;
         wg[gf] = EMPTY_VALUE;
        }

      if(loss[gf+1]!=EMPTY_VALUE && up[gf+1]!=EMPTY_VALUE && up[gf+1]!=0 && m>0)
        {
         wg[gf] = Low[gf]- 5*Point;
         ht[gf] = EMPTY_VALUE;
        }

      if(loss[gf+1]!=EMPTY_VALUE && up[gf+1]!=EMPTY_VALUE && up[gf+1]!=0 && m<=0)
        {
         ht[gf] = Low[gf] - 5*Point;
         wg[gf] = EMPTY_VALUE;
        }
      //


     }
   if(tp<Time[0])
     {
      t = 0;
      w = 0;
      l = 0;
      wg1 = 0;
      ht1 = 0;
     }
   if(Painel==true && t==0)
     {
      tp = Time[0]+Period()*60;
      t=t+1;



      for(int v=VelasBack; v>=0; v--)
        {
         if(win[v]!=EMPTY_VALUE)
           {w = w+1;}
         if(loss[v]!=EMPTY_VALUE)
           {l=l+1;}
         if(wg[v]!=EMPTY_VALUE)
           {wg1=wg1+1;}
         if(ht[v]!=EMPTY_VALUE)
           {ht1=ht1+1;}

        }

      wg1 = wg1 +w;
      if(l>0)
        {
         WinRate1 = ((l/(w + l))-1)*(-100);
        }
      else
        {
         WinRate1 = 100;
        }
      if(ht1>0)
        {
         WinRateGale1 = ((ht1/(wg1 + ht1)) - 1)*(-100);
        }
      else
        {
         WinRateGale1 = 100;
        }

      WinRate = NormalizeDouble(WinRate1,0);
      WinRateGale = NormalizeDouble(WinRateGale1,0);
      WinRateGale2 = NormalizeDouble(WinRateGale22,0);

      ObjectCreate("Time_Remaining",OBJ_LABEL,0,0,0);
      ObjectCreate("FrameLabel",OBJ_RECTANGLE_LABEL,0,0,0,0,0,0);
      ObjectSet("FrameLabel",OBJPROP_BGCOLOR,Black);
      ObjectSet("FrameLabel",OBJPROP_CORNER,Posicao);
      ObjectSet("FrameLabel",OBJPROP_BACK,false);
      if(Posicao==0)
        {
         ObjectSet("FrameLabel",OBJPROP_XDISTANCE,1*25);
        }
      if(Posicao==1)
        {
         ObjectSet("FrameLabel",OBJPROP_XDISTANCE,1*325);
        }


      ObjectSet("FrameLabel",OBJPROP_YDISTANCE,1*18);

      ObjectSet("FrameLabel",OBJPROP_XSIZE,1*220);
      ObjectSet("FrameLabel",OBJPROP_YSIZE,1*140);

      ObjectCreate("cop",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("cop","Oozaru Pro", 11, "Arial Black",clrWhite);
      ObjectSet("cop",OBJPROP_XDISTANCE,1*90);
      ObjectSet("cop",OBJPROP_YDISTANCE,1*21);
      ObjectSet("cop",OBJPROP_CORNER,Posicao);
     
     
      ObjectCreate("pul",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("pul","___________________________", 11, "Arial Black",clrWhite);
      ObjectSet("pul",OBJPROP_XDISTANCE,1*27);
      ObjectSet("pul",OBJPROP_YDISTANCE,1*25);
      ObjectSet("pul",OBJPROP_CORNER,Posicao);


      ObjectCreate("Win",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Win","Win: "+w,11, "Arial",clrLime);
      ObjectSet("Win",OBJPROP_XDISTANCE,1*50);
      ObjectSet("Win",OBJPROP_YDISTANCE,1*47);
      ObjectSet("Win",OBJPROP_CORNER,Posicao);

         ObjectCreate("Loss",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Loss","Loss: "+l, 11, "Arial",clrRed);
      ObjectSet("Loss",OBJPROP_XDISTANCE,1*140); //30
      ObjectSet("Loss",OBJPROP_YDISTANCE,1*47); //61
      ObjectSet("Loss",OBJPROP_CORNER,Posicao);

      ObjectCreate("WinRate",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("WinRate","WinRate: "+WinRate +"%", 11, "Arial Black",clrWhite);
      ObjectSet("WinRate",OBJPROP_XDISTANCE,1*70);//30
      ObjectSet("WinRate",OBJPROP_YDISTANCE,1*65);//81
      ObjectSet("WinRate",OBJPROP_CORNER,Posicao);

      ObjectCreate("WinGale",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("WinGale","Win Gale: "+wg1, 11, "Arial",clrLime);
      ObjectSet("WinGale",OBJPROP_XDISTANCE,1*50); //140
      ObjectSet("WinGale",OBJPROP_YDISTANCE,1*89); //41
      ObjectSet("WinGale",OBJPROP_CORNER,Posicao);

      ObjectCreate("Hit",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Hit","Hit: "+ht1, 11, "Arial",clrRed);
      ObjectSet("Hit",OBJPROP_XDISTANCE,1*170);
      ObjectSet("Hit",OBJPROP_YDISTANCE,1*89);
      ObjectSet("Hit",OBJPROP_CORNER,Posicao);

      ObjectCreate("WinRateGale",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("WinRateGale","WinRate Gale: "+WinRateGale+"%", 11, "Arial Black",clrWhite);
      ObjectSet("WinRateGale",OBJPROP_XDISTANCE,1*60);//140
      ObjectSet("WinRateGale",OBJPROP_YDISTANCE,1*110); //80
      ObjectSet("WinRateGale",OBJPROP_CORNER,Posicao);
      
      ObjectCreate("pulo",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("pulo","___________________________", 11, "Arial Black",clrWhite);
      ObjectSet("pulo",OBJPROP_XDISTANCE,1*27);
      ObjectSet("pulo",OBJPROP_YDISTANCE,1*115);
      ObjectSet("pulo",OBJPROP_CORNER,Posicao);
      
     }
      CommentLab(Symbol()+": ESTATÍSTICAS", 135, 70, 2,clrDarkCyan);

  }

//+------------------------------------------------------------------+

// Função Value Chart
double MVA(int NumBars1,int CBar)
  {
   double sum,floatingAxis;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=((High[k]+Low[k])/2.0);
     }
   floatingAxis=(sum/NumBars1);
   return(floatingAxis);
  }
// Average True Range Function
double ATR(int NumBars1,int CBar)
  {
   double sum,volitilityUnit;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=(High[k]-Low[k]);
     }
   volitilityUnit=(0.2 *(sum/NumBars1));
   if(volitilityUnit==0 || volitilityUnit==0.0)
     {
      volitilityUnit=0.00000001;
     }
   return(volitilityUnit);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
