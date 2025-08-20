#property copyright "Copyright © 2025 | FXProSystems.com";
#property link "https://fxprosystems.com/";
#property version "2.6";
#property strict

enum ETipoAdattamentoChiusura
{
   ENonAdattare = 0, // Non Adattare
   EAdattaSuSizeBasa = 1, // Adatta su size base (su base 0.01)
   EAdattaSuSommatoriaSize = 2 // Adatta su sommatoria size
};

enum ETipoChiusuraOverlayContrario
{
   EPositiva = 0, // Positiva
   ENegativa = 1, // Negativa
   EPositivaONegativa = 2 // Positiva o Negativa
};

enum ETipoControlloFlottante
{
   EValutaConto = 0, // In Valuta Conto
   EPercentualeSuBalance = 1 // Percentuale Su Balance
};

enum ETipoPiramidazione
{
   EPiramidazioneNessuna = 0, // Disattivata
   EPiramidazionePoints = 1, // In Points
   EPiramidazioneIngressoSuccessivo = 2 // Ingresso successivo
};

enum ETipoIncrementoSize
{
   ENessuno = 0, // Nessuno
   EMoltiplicatore = 1, // Moltiplicatore
   EAddizionale = 2 // Addizionale
};

extern string  Free_forex_tools        = "FXProSystems.com";
extern int MagicInp = 1; // Magic Number (1,1000,2000 etc.)
extern string commentoAggiuntivo; // Commento Aggiuntivo (not use : e ;)
extern int numeroMassimoCoppieOperative = 20; // Numero massimo di coppie operative
extern string strumenti = "EURUSD,GBPUSD,GBPCAD,USDCAD,EURGBP,EURAUD,AUDUSD,AUDCAD,USDJPY"; // Strumenti
extern string suffisso; // Suffisso
extern int periodoCorrelazione = 50; // Periodo Correlazione
extern int periodoMediaCorrelazione = 50; // Periodo Media Correlazione
extern string eaOverlay = "------------------ Impostazioni Overlay -------------------"; // <>
extern int numeroBarreOverlay = 900; // Numero Barre
extern bool calcolaDistanzaDaUltimoIncrocio; // Calcola distanza da ultimo incrocio
extern string eaIndicatoreSpreadRatio = "-------------- Impostazioni Spread Ratio --------------"; // <>
extern bool utilizzaSpreadRatio; // Utilizza spread ratio
extern string ea; // <--- Impostazioni Bollinger --->
extern int periodoBollinger = 40; // Periodo Bollinger
extern double deviazioneStandard = 1; // Deviazione Standard
extern string eaOper = "------------------ Impostazioni Operative -------------------"; // <>
extern string orarioOperativita = "00:00:00-23:59:59"; // Ora Operatività (Broker)
extern string orarioOperativita2 = "00:00:00-23:59:59"; // Ora Operatività 2 (Broker)
extern bool entraSubito; // Entra subito appena piazzato o agg. parametri input
extern double lottiBase = 0.1; // Lotti Base
extern bool calcolaLottiAutomaticamente = true; // Calcola lotti automaticamente (per il secondo strumento)
extern double valoreOverlayPerIngresso = 90; // Valore Overlay per ingresso
extern double valorePuntiOverlayPerIngresso; // Valore Punti Overlay Per Ingresso
extern bool utilizzaFiltroCorrelazionePerIngresso; // Utilizza Filtro correlazione per ingresso
extern double valoreCorrelazionePositivaPerIngesso = 60; // Valore correlazione positiva per ingresso
extern double valoreCorrelazioneNegativaPerIngesso; // Valore correlazione negativa per ingresso
extern string eaSLTP = "------------------------- Impostazioni TP & SL -------------------------"; // <>
extern ETipoAdattamentoChiusura tipoAdattamentoSize = ENonAdattare; // Selezionare il tipo di adattamento dei valori di chiusura
extern double percentualeSizePerAdattamento1 = 100; // % Size adattamento (per sommatoria)
extern double targetValuta = 10; // Target Valuta, 0 è disattivato
extern int numeroMediazioniAttivazioneSecondoTarget; // Numero Mediazioni Attivazione Secondo Target, 0 è disatti.
extern double percentualeSizePerAdattamento2 = 100; // % Size adattamento (per sommatoria)
extern double targetValuta2 = 10; // Target Valuta 2
extern int numeroMediazioniAttivazioneTerzoTarget; // Numero Mediazioni Attivazione Terzo Target, 0 è disatti.
extern double percentualeSizePerAdattamento3 = 100; // % Size adattamento (per sommatoria)
extern double targetValuta3 = 10; // Target Valuta 3
extern double stopValuta; // Stoploss Valuta, 0 è disattivato
extern double trailingStopStart; // Trailing Stop Start, 0 è disattivato
extern double trailingStop; // Trailing Stop
extern double trailingStep; // Trailing Step
extern bool utilizzaChiusuraSuValoreOverlay; // Utilizza chiusura su valore overlay
extern double valoreOverlayPerChiusura = 60; // Valore Overlay per chiusura
extern ETipoChiusuraOverlayContrario tipoChiusuraOverlay = EPositivaONegativa; // Selezionare il tipo di chiusura
extern int numeroMassimoOperazioniInGain; // Numero massimo operazioni in gain
extern double massimoGainGiornaliero; // Massimo Gain Giornaliero in valuta, 0 è disattivato
extern double massimoLossGiornaliero; // Massimo Loss Giornaliero in valuta, 0 è disattivato
extern bool limitaIngressoNuoveOperazioniSeSuperatoDD; // Limita Ingresso Nuove Operazioni Se Superato DD
extern bool limitaIngressoGridOperazioniSeSuperatoDD; // Limita Ingresso Operazioni Grid Se Superato DD
extern int numeroMassimoOrdiniPerValuta; // Numero massimo ordini per valuta, 0 è illimitato
extern int numeroMassimoOrdiniPerStrumentoFinanziario; // Numero massimo ordini per Strumento finanziario, 0 è illimitato
extern ETipoControlloFlottante tipoControlloFlottante = EValutaConto; // Selezionare il tipo di controllo flottante
extern double valoreLimite; // Valore Limite
extern string eaPir = "------------------------- Impostazioni Piramidazioni -------------------------"; // <>
extern ETipoPiramidazione tipoPiramidazione1 = EPiramidazioneNessuna; // Selezionare il tipo di Piramidazione
extern int numeroMassimoPiramidazioni; // Numero massimo operazioni, 0 è illimitato
extern bool misuraDistanzaAncheSuSecondoStrumento; // Misura distanza anche su secondo strumento
extern int pointsDistanzaPiramidazione; // Points Distanza piramidazione Step 1(da strumento primo)
extern bool utilizzaPiramidazioneIndipendente; // Utilizza piramidazione indipendente
extern int numeroOperazioniDifferenzialePerDisattivarePirIndipendente; // Numero Operazioni Differenziale Per Disattivare Piram. Indipend
extern bool disattivaPiramidazioneIndipendenteSeValuteUguali; // Disattiva Piram. Indipendente se coppie uguali numeratore/denom
extern ETipoPiramidazione tipoPiramidazione2 = EPiramidazioneNessuna; // Selezionare il tipo di Piramidazione
extern int numeroPiramidazioneStep2; // Numero Piramidazioni per Step 2
extern int pointsDistanzaPiramidazioneStep2; // Points Distanza piramidazione Step 2
extern ETipoPiramidazione tipoPiramidazione3 = EPiramidazioneNessuna; // Selezionare il tipo di Piramidazione
extern int numeroPiramidazioneStep3; // Numero Piramidazioni per Step 3
extern int pointsDistanzaPiramidazioneStep3; // Points Distanza piramidazione Step 3
extern ETipoPiramidazione tipoPiramidazione4 = EPiramidazioneNessuna; // Selezionare il tipo di Piramidazione
extern int numeroPiramidazioneStep4; // Numero Piramidazioni per Step 4
extern int pointsDistanzaPiramidazioneStep4; // Points Distanza piramidazione Step 4
extern ETipoIncrementoSize tipoIncrementoSize = ENessuno; // Selezionare il tipo di incremento della size
extern double valoreIncremento = 0.01; // Valore incremento
extern string listaSpreadDaNonTradare1; // Lista spread da non Tradare (! per lo strumento , per spread su
extern string listaSpreadDaNonTradare2; // Lista spread da non Tradare (! per lo strumento , per spread su
extern string listaSpreadDaNonTradare3; // Lista spread da non Tradare (! per lo strumento , per spread su
extern bool nonTradareCoppieCorrelate; // Non tradare coppie correlate (Con stesso numeratore o stesso de
extern bool tradareSoloCoppieCorrelate; // Trada SOLO coppie correlate (Con stesso numeratore o stesso den
extern string listaSpreadDaTradare1; // Lista spread aggiuntivi da Tradare (! per lo strumento , per sp
extern string eaOper2 = "------------------ Impostazioni Pannello -------------------"; // <>
extern bool richiediConfermaInserimentoOperazioni = true; // Richiedi conferma apertura operazioni
extern int grandezzaFont = 8; // Grandezza Font
extern int deltaXIniziale; // Delta X Iniziale
extern int deltaYIniziale; // Delta Y Iniziale
extern double moltiplicatoreGrafiche = 2; // Moltiplicatore Grafiche
extern string nomeTemplate = "PulseMatrixNuovo.tpl"; // Nome file del Template
extern string exEA1 = "<---------- Allarmi ---------->"; // <>
extern string exEA2; // <--- Allarmi causa Errori --->
extern bool utilizzaAllarmiErrore = true; // Allarmi EA per errori
extern bool utilizzaAlertErrore = true; // Utilizza Allarme per errori
extern bool utilizzaPopupErrore = true; // Utilizza Notifiche Push per errori
extern bool utilizzaMailErrore = true; // Utilizza Invio Mail per errori
extern string exEA3; // <--- Allarmi per Inserimento Ordini --->
extern bool utilizzaAllarmiInserimentoOrdini = true; // Allarmi EA per inserimento ordini
extern bool utilizzaAlertInserimentoOrdini = true; // Utilizza Allarme per inserimento ordini
extern bool utilizzaPopupInserimentoOrdini = true; // Utilizza Notifiche Push per inserimento ordini
extern bool utilizzaMailInserimentoOrdini = true; // Utilizza Invio Mail per inserimento ordini
extern string exEA4; // <--- Allarmi per Modifica Ordini( Stoploss & Takeprofit )--->
extern bool utilizzaAllarmiModificaOrdini = true; // Allarmi EA per modifica ordini
extern bool utilizzaAlertModificaOrdini = true; // Utilizza Allarme per modifica ordini
extern bool utilizzaPopupModificaOrdini = true; // Utilizza Notifiche Push per modifica ordini
extern bool utilizzaMailModificaOrdini = true; // Utilizza Invio Mail per modifica ordini

class Coppia
{
   public:
      string m_16;
      string m_28;
      double m_40;
      double m_48;
      double m_56;
      int m_64;
      double m_68;
      double m_76;
      bool m_84;
      bool m_85;
      bool m_86;

      void func_1017()
      {
      }

      Coppia()
      {
      }

};

class Valuta
{
   public:
      string m_16;
      int m_28;
      int m_32;

      void func_1022()
      {
      }

      Valuta()
      {
      }

};

class MagicStrumento
{
   public:
      int m_16;
      string m_20;

      void func_1027()
      {
      }

      MagicStrumento()
      {
      }

};

class Trading_Misc_Methods
{
   public:
      bool m_16;

};


bool returned_b;
int Gi_00000;
int returned_i;
int Ii_1D250;
int Ii_1D254;
bool Gb_00001;
bool Gb_00002;
bool Gb_00003;
int Gi_00004;
long Gl_00005;
int Gi_00005;
string Is_09CA0;
string Is_1CC08;
long Il_1CED8;
bool Gb_00006;
int Ii_1CECC;
int Gi_0000A;
int Gi_0000B;
int Ii_1CEC8;
int Gi_0000C;
bool Ib_1CED0;
int Gi_0000D;
int Ii_1CEC4;
int Gi_0000E;
int Gi_0000F;
int Gi_00010;
int Gi_00011;
bool Ib_1D238;
long Il_09C78;
short Gst_00011;
short returned_st;
string Gs_00010;
string Gs_00011;
int Gi_00012;
bool Ib_09C80;
int Gi_00007;
int Gi_00008;
long Gl_00007;
long returned_l;
int Gi_00009;
long Gl_0000A;
int Ii_09C84;
double Gd_00000;
int Gi_00001;
int Gi_00002;
int Gi_00003;
bool Gb_00005;
double Ind_004;
double Gd_00006;
string Is_1CBF8;
bool Ib_09C81;
bool Gb_00007;
double Gd_00007;
string Gs_00008;
string Gs_00009;
int Gi_00032;
bool Gb_00033;
int Gi_00033;
int Gi_00034;
int Gi_00035;
int Ii_1D234;
double Gd_0000E;
struct Global_Struct_0000000D;
bool Gb_00012;
int Gi_00013;
double Gd_00015;
int Ii_09CAC;
int Gi_00016;
int Gi_00017;
int Gi_00018;
struct Global_Struct_00000014;
int Gi_00019;
string Gs_00019;
string Gs_00018;
int Gi_0001A;
int Gi_0001B;
string Gs_0001B;
string Gs_0001A;
int Gi_0001C;
int Gi_0001D;
int Gi_0001E;
int Gi_0001F;
int Gi_00020;
int Gi_00021;
int Gi_00022;
int Gi_00023;
int Gi_00024;
int Gi_00025;
int Gi_00026;
int Gi_00027;
int Gi_00028;
int Gi_00029;
int Gi_0002A;
int Gi_0002B;
double Ind_001;
double Ind_000;
double Gd_0002B;
int Gi_0002C;
double Ind_003;
double Gd_0002D;
bool Gb_0002C;
int Gi_0002E;
int Gi_0002F;
int Gi_00030;
int Gi_00031;
long Il_0EF90;
double Gd_00001;
short Gst_00004;
string Gs_00003;
string Gs_00004;
string Gs_00005;
int Gi_00006;
string Gs_00006;
long Il_09C98;
short Gst_00009;
string Gs_0000A;
string Gs_0000B;
double Gd_0000D;
short Gst_0000F;
string Gs_0000E;
string Gs_0000F;
string Gs_00012;
string Gs_00013;
long Il_1D240;
long Il_1D248;
int Gi_00014;
string Gs_00014;
int Gi_00015;
double Gd_00016;
short Gst_00017;
string Gs_00016;
string Gs_00017;
double Gd_0001D;
short Gst_0001E;
string Gs_0001D;
string Gs_0001E;
string Gs_0001F;
string Gs_00020;
double Gd_0002F;
short Gst_00031;
string Gs_00030;
string Gs_00031;
double Gd_00032;
double Gd_00033;
string Gs_00034;
string Gs_00035;
int Gi_00036;
int Gi_0003D;
string Gs_0003D;
int Gi_00041;
string Gs_00041;
int Gi_00042;
double Gd_00043;
int Gi_00044;
int Gi_00045;
string Gs_00045;
int Gi_00046;
string Gs_00046;
int Gi_00047;
int Gi_00048;
string Gs_00048;
int Gi_00049;
string Gs_00049;
int Gi_0004A;
long Gl_0004C;
double Gd_0004C;
int Gi_0004D;
long Gl_0004D;
int Gi_0004B;
bool Gb_0004B;
double Gd_0004B;
int Gi_0004C;
bool Gb_00048;
int Gi_00043;
double Gd_00037;
int Gi_00038;
double Gd_00038;
int Gi_00039;
long Gl_00039;
double Gd_00039;
int Gi_0003A;
int Gi_0003B;
double Gd_0003B;
int Gi_0003C;
bool Gb_0003D;
double Gd_0003D;
int Gi_0003E;
long Gl_0003D;
int Gi_0003F;
int Gi_00040;
double Gd_00023;
long Gl_00025;
double Gd_00025;
double Gd_00028;
double Gd_00029;
double Gd_0002A;
double Gd_0002C;
int Gi_0002D;
bool Gb_0002A;
double Gd_0002E;
long Gl_0002E;
long Gl_0002F;
string Is_09C88;
long Gl_00000;
bool Ib_1CC14;
double Id_1CC18;
bool Ib_1CC20;
bool Ib_1CC21;
double Id_1CC28;
int Ii_1CC30;
bool Ib_1CC34;
int Ii_1CC38;
bool Ib_1CC3C;
string Is_1CC40;
string Is_1CC50;
string Is_1CC60;
string Is_1CC70;
bool Ib_1CC7C;
int Ii_1CC80;
int Ii_1CC84;
int Ii_1CC88;
int Ii_1CC8C;
int Ii_1CC90;
int Ii_1CC94;
int Ii_1CC98;
int Ii_1CC9C;
int Ii_1CCA0;
int Ii_1CCA4;
int Ii_1CCA8;
bool Ib_1CCAC;
int Ii_1CCB0;
int Ii_1CCB4;
int Ii_1CCB8;
int Ii_1CCBC;
int Ii_1CCC0;
int Ii_1CCC4;
int Ii_1CCC8;
int Ii_1CCCC;
string Is_1CCD0;
bool Ib_1CCDC;
string Is_1CCE0;
bool Ib_1CCEC;
bool Ib_1CCED;
bool Ib_1CCEE;
long Il_1CCF0;
long Il_1CCF8;
long Il_1CD00;
long Il_1CD08;
double Id_1CD10;
double Id_1CD18;
double Id_1CD20;
double Id_1CD28;
bool Ib_1CD30;
double Id_1CD38;
double Id_1CD40;
double Id_1CD48;
double Id_1CD50;
double Id_1CD58;
double Id_1CD60;
double Id_1CD68;
bool Ib_1CD70;
double Id_1CD78;
bool Ib_1CD80;
long Il_1CD88;
long Il_1CD90;
bool Ib_1CD98;
double Id_1CDA0;
bool Ib_1CDA8;
double Id_1CDB0;
bool Ib_1CDB8;
bool Ib_1CDB9;
double Id_1CDC0;
double Id_1CDC8;
bool Ib_1CDD0;
double Id_1CDD8;
double Id_1CDE0;
double Id_1CDE8;
double Id_1CDF0;
double Id_1CDF8;
double Id_1CE00;
double Id_1CE08;
long Il_1CE10;
long Il_1CE18;
double Id_1CE20;
bool Ib_1CE28;
long Il_1CE30;
double Id_1CE38;
long Il_1CE40;
int Ii_1CE48;
bool Ib_1CE4C;
bool Ib_1CE4D;
double Id_1CE50;
double Id_1CE58;
double Id_1CE60;
bool Ib_1CE68;
int Ii_1CE6C;
double Id_1CE70;
double Id_1CE78;
bool Ib_1CE80;
bool Ib_1CE81;
double Id_1CE88;
double Id_1CE90;
bool Ib_1CE98;
double Id_1CEA0;
double Id_1CEA8;
bool Gb_00000;
double Gd_00002;
double Gd_00003;
double Ind_002;
double Gd_00004;
bool Gb_00004;
double Gd_00005;
long Gl_00002;
long Gl_00004;
string Gs_00007;
short Gst_00008;
bool Gb_0000A;
double Gd_0000A;
double Gd_0000B;
bool Gb_0000B;
long Gl_00003;
long Gl_00001;
long Gl_00006;
short Gst_0000A;
long Gl_0000C;
double Gd_0000C;
bool Gb_0000C;
long Gl_0000D;
long Gl_00009;
double Gd_00009;
string Gs_0000C;
string Gs_0000D;
int Gi_00050;
int Gi_00051;
int Gi_00052;
bool Gb_00053;
int Gi_00053;
int Gi_00054;
int Gi_00055;
long Gl_00055;
int Gi_00056;
int Gi_00057;
bool Gb_00058;
int Gi_00058;
int Gi_00059;
int Gi_0005A;
int Gi_0005B;
long Gl_0005B;
int Gi_0005C;
int Gi_0005D;
long Gl_0005D;
double Gd_0005D;
int Gi_0005E;
long Gl_0005E;
double Gd_0005E;
int Gi_0005F;
long Gl_0005F;
int Gi_00060;
long Gl_00060;
bool Gb_00061;
int Gi_00061;
int Gi_00062;
bool Gb_00063;
int Gi_00063;
int Gi_00064;
double Gd_00065;
int Gi_00066;
long Gl_00066;
int Gi_00067;
int Gi_00068;
int Gi_00069;
int Gi_0006A;
int Gi_0006B;
int Gi_0006C;
int Gi_0006D;
int Gi_0006E;
long Gl_0006E;
int Gi_0006F;
string Gs_0006F;
int Gi_00070;
string Gs_00070;
int Gi_00071;
int Gi_00072;
bool Gb_00073;
double Gd_00072;
double Gd_00073;
int Gi_00074;
int Gi_00075;
double Gd_00076;
double Gd_00075;
long Gl_00076;
int Gi_00076;
int Gi_00077;
long Gl_00077;
double Gd_00078;
int Gi_00079;
bool Gb_0007A;
double Gd_00079;
int Gi_0007A;
double Gd_0007B;
double Gd_0007A;
int Gi_0007B;
long Gl_0007B;
int Gi_0007C;
long Gl_0007C;
int Gi_0007D;
int Gi_0007E;
long Gl_0007E;
int Gi_0007F;
long Gl_0007F;
int Gi_00080;
bool Gb_00064;
bool Gb_00062;
bool Gb_00059;
bool Gb_00054;
double Gd_00011;
double Gd_00012;
double Gd_0001A;
long Gl_0001A;
bool Gb_0001E;
double Gd_00021;
long Gl_0002B;
bool Gb_00031;
long Gl_00034;
long Gl_00036;
bool Gb_00037;
int Gi_00037;
bool Gb_00039;
long Gl_0003C;
long Gl_0003E;
bool Gb_00041;
long Gl_00042;
double Gd_00042;
long Gl_00044;
long Gl_0004B;
double Gd_0004D;
int Gi_0004E;
long Gl_0004E;
double Gd_0004E;
int Gi_0004F;
long Gl_0004F;
long Gl_00050;
double Gd_00050;
bool Gb_0003A;
bool Gb_00038;
bool Gb_00032;
double Gd_00008;
bool Gb_00021;
string Gs_0002B;
string Gs_0002C;
long Gl_0002D;
string Gs_0002F;
string Gs_00023;
string Gs_00024;
bool Gb_00026;
bool Gb_00027;
string Gs_00000;
string Gs_00001;
string Gs_00064;
string Gs_00060;
int Gi_00065;
double Gd_00068;
struct Global_Struct_00000067;
bool Gb_0006C;
double Gd_0006F;
struct Global_Struct_0000006E;
int Gi_00073;
string Gs_00073;
string Gs_00072;
string Gs_00075;
string Gs_00074;
int Gi_00078;
int Gi_00081;
int Gi_00082;
int Gi_00083;
int Gi_00084;
string Gs_00084;
int Gi_00085;
string Gs_00085;
int Gi_00087;
int Gi_00088;
int Gi_00089;
struct Global_Struct_00000086;
string Gs_00089;
int Gi_0008A;
string Gs_0008A;
int Gi_0008B;
string Gs_0008B;
int Gi_0008C;
string Gs_0008C;
bool Gb_0008D;
int Gi_0008E;
string Gs_0008E;
int Gi_0008F;
string Gs_0008F;
bool Gb_00090;
int Gi_00091;
string Gs_00091;
int Gi_00092;
string Gs_00092;
int Gi_00093;
string Gs_00093;
int Gi_00094;
string Gs_00094;
bool Gb_00095;
int Gi_00096;
string Gs_00096;
int Gi_00097;
string Gs_00097;
int Gi_00098;
bool Gb_00099;
int Gi_00099;
bool Gb_0009A;
int Gi_0009A;
bool Gb_0009B;
int Gi_0009B;
int Gi_0009C;
double Gd_0009C;
bool Gb_0009C;
int Gi_0009D;
int Gi_0009E;
int Gi_0009F;
int Gi_000A0;
int Gi_000A1;
int Gi_000A2;
int Gi_000A3;
int Gi_000A4;
int Gi_000A5;
int Gi_000A6;
int Gi_000A7;
string Gs_0009D;
string Gs_0009C;
int Gi_000A8;
int Gi_000A9;
string Gs_000A9;
string Gs_000A8;
int Gi_000AA;
int Gi_000AB;
int Gi_000AC;
int Gi_000AD;
int Gi_000AE;
int Gi_000AF;
int Gi_000B0;
int Gi_000B1;
int Gi_000B2;
int Gi_000B3;
int Gi_000B4;
int Gi_000B5;
int Gi_000B6;
int Gi_000B7;
int Gi_000B8;
int Gi_000B9;
int Gi_000BA;
int Gi_000BB;
int Gi_000BC;
double Gd_000BD;
int Gi_000BE;
string Gs_000BC;
string Gs_000BE;
int Gi_000BF;
int Gi_000C0;
int Gi_000C1;
int Gi_000C2;
long Gl_0000B;
long Gl_00010;
long Gl_00014;
long Gl_00015;
string Gs_00015;
string Gs_0001C;
string Gs_00021;
long Gl_00022;
long Gl_00023;
string Gs_00022;
long Gl_00024;
string Gs_0002A;
string Gs_0002D;
string Gs_0002E;
bool Gb_00030;
string Gs_00032;
double Gd_00036;
string Gs_00038;
string Gs_00039;
double Gd_0003A;
bool Gb_0003C;
string Gs_0003E;
bool Gb_00040;
double Gd_0003F;
double Gd_00040;
string Gs_00040;
string Gs_00042;
string Gs_00043;
bool Gb_00045;
double Gd_00044;
string Gs_00047;
bool Gb_0004A;
double Gd_00049;
double Gd_0004A;
long Gl_0004A;
string Gs_0004B;
string Gs_0004C;
bool Gb_0004E;
string Gs_0004F;
string Gs_00050;
double Gd_00051;
long Gl_00053;
double Gd_00056;
double Gd_00057;
string Gs_00057;
string Gs_00059;
string Gs_0005D;
string Gs_0005F;
string Gs_00062;
string Gs_00063;
short Gst_00005;
string Gs_00002;
bool Gb_00008;
long Gl_0000F;
double Gd_00010;
long Gl_00011;
long Gl_00013;
double Gd_00013;
short Gst_00000;
bool Gb_0000F;
bool Gb_0000D;
struct Global_Struct_00000019;
bool Gb_0001D;
struct Global_Struct_0000002E;
string Gs_00033;
double Gd_00046;
double Gd_00048;
double Gd_0004F;
long Gl_00051;
string Gs_00053;
double Gd_00054;
string Gs_00054;
long Gl_00058;
string Gs_00058;
long Gl_00059;
string Gs_0005C;
struct Global_Struct_00000059;
struct Global_Struct_00000064;
string Gs_00068;
struct Global_Struct_0000006C;
struct Global_Struct_00000074;
string Gs_00078;
struct Global_Struct_0000007C;
string Gs_00080;
int Gi_00086;
struct Global_Struct_00000084;
string Gs_00088;
int Gi_0008D;
int Gi_00090;
struct Global_Struct_0000008C;
string Gs_00090;
int Gi_00095;
struct Global_Struct_00000094;
string Gs_00098;
double Gd_0003C;
struct Global_Struct_0000003B;
string Gs_0003F;
double Gd_00027;
struct Global_Struct_00000026;
struct Global_Struct_0000000F;
bool Gb_00016;
struct Global_Struct_00000017;
bool Gb_0001B;
struct Global_Struct_0000002C;
struct Global_Struct_00000034;
struct Global_Struct_0000003C;
struct Global_Struct_00000044;
struct Global_Struct_0000004C;
struct Global_Struct_00000054;
struct Global_Struct_0000005C;
struct Global_Struct_00000024;
string Gs_00028;
double Gd_0000F;
bool Gb_00014;
short Gst_00001;
short Gst_00003;
short Gst_00002;
long Gl_0000E;
long Gl_00019;
long Gl_0001B;
long Gl_0001C;
double Gd_0001B;
long Gl_0001E;
long Gl_0001F;
double Gd_00019;
bool Gb_00019;
bool Gb_00011;
bool Gb_0000E;
bool Gb_00010;
double Gd_00014;
bool Gb_00015;
long Gl_00016;
long Gl_00017;
bool Gb_0001A;
bool Gb_0001C;
double Gd_0001C;
double Gd_0001E;
long Gl_00020;
long Gl_00021;
double Gd_00020;
bool Gb_00020;
double Gd_00026;
bool Gb_0002B;
bool Gb_0002D;
bool Gb_00035;
double Gd_00035;
long Gl_00035;
long Gl_00037;
long Gl_00038;
long Gl_0003A;
bool Gb_0002E;
double Gd_00022;
short Gst_0000B;
double Gd_00018;
bool Gb_00018;
bool Gb_00023;
bool Gb_00024;
double Gd_00024;
double Gd_00030;
bool Gb_00046;
double Gd_00045;
double Gd_00047;
bool Gb_0004D;
bool Gb_00055;
double Gd_00055;
double Gd_0005A;
double Gd_0005B;
long Gl_0005A;
double Gd_0005C;
bool Gb_0005D;
bool Gb_0005E;
bool Gb_00057;
double Gd_00059;
bool Gb_00052;
double Gd_0003E;
bool Gb_0003F;
double Gd_00041;
double Gd_00031;
double Gd_00034;
double Gd_0001F;
char Gc_00000;
double returned_double;
string Global_ReturnedString;
int Ii_00034[10000];
string Is_09CB0[];
Coppia Input_Struct_00009CE4[];
Coppia Input_Struct_00009D18[];
double Id_09D80[300];
double Id_0A714[300];
string Is_0B074[];
long Il_0B0DC[1000];
long Il_0D050[1000];
long Il_0EFCC[1000];
long Il_10F40[1000];
int Ii_12EB4[1000];
long Il_13E88[1000];
long Il_15DFC[1000];
long Il_17D70[1000];
int Ii_19CE4[1000];
long Il_1ACB8[1000];
long Il_1CF14[100];
Trading_Misc_Methods Input_Struct_0001CEB0;

int init()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   int Li_FFFFC;
   int Li_FFFF8;
   Il_09C78 = 4133894400;
   Ib_09C80 = false;
   Ib_09C81 = false;
   Ii_09C84 = 0;
   Is_09C88 = "";
   Il_09C98 = 0;
   Is_09CA0 = "PulseMatrixPro";
   Ii_09CAC = 0;
   Il_0EF90 = 0;
   tmp_str00000 = IntegerToString(MagicInp, 0, 32);
   tmp_str00000 = tmp_str00000 + "_PMP_infoOrdini.txt";
   Is_1CBF8 = tmp_str00000;
   Is_1CC08 = "";
   Ib_1CC14 = false;
   Id_1CC18 = 0;
   Ib_1CC20 = false;
   Ib_1CC21 = false;
   Id_1CC28 = 0;
   Ii_1CC30 = 0;
   Ib_1CC34 = false;
   Ii_1CC38 = 0;
   Ib_1CC3C = false;
   Ib_1CC7C = false;
   Ii_1CC80 = 0;
   Ii_1CC84 = 0;
   Ii_1CC88 = 0;
   Ii_1CC8C = 0;
   Ii_1CC90 = 0;
   Ii_1CC94 = 0;
   Ii_1CC98 = 0;
   Ii_1CC9C = 0;
   Ii_1CCA0 = 0;
   Ii_1CCA4 = 0;
   Ii_1CCA8 = 0;
   Ib_1CCAC = false;
   Ii_1CCB0 = 0;
   Ii_1CCB4 = 0;
   Ii_1CCB8 = 0;
   Ii_1CCBC = 0;
   Ii_1CCC0 = 0;
   Ii_1CCC4 = 0;
   Ii_1CCC8 = 0;
   Ii_1CCCC = 0;
   Ib_1CCDC = false;
   Ib_1CCEC = false;
   Ib_1CCED = false;
   Ib_1CCEE = false;
   Il_1CCF0 = 0;
   Il_1CCF8 = 0;
   Il_1CD00 = 0;
   Il_1CD08 = 0;
   Id_1CD10 = 0;
   Id_1CD18 = 0;
   Id_1CD20 = 0;
   Id_1CD28 = 0;
   Ib_1CD30 = false;
   Id_1CD38 = 0;
   Id_1CD40 = 0;
   Id_1CD48 = 0;
   Id_1CD50 = 0;
   Id_1CD58 = 0;
   Id_1CD60 = 0;
   Id_1CD68 = 0;
   Ib_1CD70 = false;
   Id_1CD78 = 0;
   Ib_1CD80 = false;
   Il_1CD88 = 0;
   Il_1CD90 = 0;
   Ib_1CD98 = false;
   Id_1CDA0 = 0;
   Ib_1CDA8 = false;
   Id_1CDB0 = 0;
   Ib_1CDB8 = false;
   Ib_1CDB9 = false;
   Id_1CDC0 = 0;
   Id_1CDC8 = 0;
   Ib_1CDD0 = false;
   Id_1CDD8 = 0;
   Id_1CDE0 = 0;
   Id_1CDE8 = 0;
   Id_1CDF0 = 0;
   Id_1CDF8 = 0;
   Id_1CE00 = 0;
   Id_1CE08 = 0;
   Il_1CE10 = 0;
   Il_1CE18 = 0;
   Id_1CE20 = 0;
   Ib_1CE28 = false;
   Il_1CE30 = 0;
   Id_1CE38 = 0;
   Il_1CE40 = 0;
   Ii_1CE48 = 0;
   Ib_1CE4C = false;
   Ib_1CE4D = false;
   Id_1CE50 = 0;
   Id_1CE58 = 0;
   Id_1CE60 = 0;
   Ib_1CE68 = false;
   Ii_1CE6C = 0;
   Id_1CE70 = 0;
   Id_1CE78 = 0;
   Ib_1CE80 = false;
   Ib_1CE81 = false;
   Id_1CE88 = 0;
   Id_1CE90 = 0;
   Ib_1CE98 = false;
   Id_1CEA0 = 0;
   Id_1CEA8 = 0;

   Ii_1CEC4 = 2631720;
   Ii_1CEC8 = 1315860;
   Ii_1CECC = 600;
   Ib_1CED0 = false;
   Il_1CED8 = 0;
   Ii_1D234 = 0;
   Ib_1D238 = false;
   Il_1D240 = -1;
   Il_1D248 = -1;
   Ii_1D250 = 0;
   Ii_1D254 = 0;
   
   if (IsDllsAllowed() != true) { 
   Alert("You have to enable DLLs in order to work with this product");
   } 
   if (IsLibrariesAllowed() != true) { 
   Alert("You have to enable Libraries in order to work with this product");
   } 
   
   Ii_1D250 = 1;
   Ii_1D254 = WindowHandle(_Symbol, _Period);

   tmp_str00006 = "";
   Is_1CC08 = "";
   ArrayInitialize(Il_0EFCC, 0);
   ArrayInitialize(Il_10F40, 0);
   tmp_str00008 = IntegerToString(MagicInp, 0, 32);
   
   tmp_str00008 = tmp_str00008 + "_";
   
   tmp_str00008 = tmp_str00008 + "_PMPtimeFlat";
   if (GlobalVariableCheck(tmp_str00008) != true) { 
   tmp_str00009 = IntegerToString(MagicInp, 0, 32);
   tmp_str00009 = tmp_str00009 + "_";
   tmp_str00009 = tmp_str00009 + "_PMPtimeFlat";
   GlobalVariableSet(tmp_str00009, 0);
   } 

   if (ChartSetInteger(0, 0, 2) != true) { 
   tmp_str0000A = "OnInit" + ", Error Code = ";
   Print(tmp_str0000A, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 27, 4294967295) != true) { 
   tmp_str0000C = "OnInit" + ", Error Code = ";
   Print(tmp_str0000C, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 24, 4294967295) != true) { 
   tmp_str0000D = "OnInit" + ", Error Code = ";
   Print(tmp_str0000D, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 21, 0) != true) { 
   tmp_str0000E = "OnInit" + ", Error Code = ";
   Print(tmp_str0000E, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 22, 6579300) != true) { 
   tmp_str0000F = "OnInit" + ", Error Code = ";
   Print(tmp_str0000F, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 13, 0, 0) != true) { 
   tmp_str00010 = "OnInit" + ", Error Code = ";
   Print(tmp_str00010, GetLastError());
   return 1;
   } 
   if (ChartSetInteger(0, 17, 0, 0) != true) { 
   tmp_str00011 = "OnInit" + ", Error Code = ";
   Print(tmp_str00011, GetLastError());
   return 1;
   } 
   
   tmp_str00013 = strumenti;
   tmp_str00014 = ",";
   Gst_00011 = (short)StringGetCharacter(tmp_str00014, 0);
   StringSplit(tmp_str00013, Gst_00011, Is_09CB0);
   if (suffisso != "") { 
   Li_FFFF8 = 0;
   if (Li_FFFF8 < ArraySize(Is_09CB0)) { 
   do { 
   Is_09CB0[Li_FFFF8] = Is_09CB0[Li_FFFF8] + suffisso;
   Li_FFFF8 = Li_FFFF8 + 1;
   } while (Li_FFFF8 < ArraySize(Is_09CB0)); 
   }} 
   ArrayInitialize(Il_0B0DC, 0);
   ArrayInitialize(Il_0D050, 0);
   func_1058();
   func_1060(true);
   Li_FFFFC = 0;
   return Li_FFFFC;

}

void start()
//void OnTick()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   int Li_FFFFC;
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFDC;
   int Li_FFF94;
   int Li_FFFD8;
   int Li_FFFD4;
   int Li_FFF9C;
   bool Lb_FFF9B;
   bool Lb_FFF9A;


   if (IsTradeContextBusy()) return; 
   if (Ib_1D238) return; 
   if (Ib_1CED0) { 
   ChartSetInteger(0, 21, 255);
   return ;
   } 
   Gi_00003 = OrdersTotal();
   Gb_00005 = false;
   if (Gi_00003 >= 0) {
   do { 
   if (OrderSelect(Gi_00003, 0, 0) && OrderMagicNumber() >= MagicInp) {
   Gi_00004 = OrderMagicNumber();
   Gi_00005 = MagicInp + 1000;
   if (Gi_00004 < Gi_00005) {
   Gb_00005 = true;
   break;
   }}
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   }
   
   if (Gb_00005 != true) { 
   ArrayResize(Is_0B074, 0, 0);
   tmp_str00002 = IntegerToString(MagicInp, 0, 32);
   tmp_str00002 = tmp_str00002 + "_PMPtimeFlat";
   GlobalVariableSet(tmp_str00002, (TimeCurrent() / 1000));
   if (FileIsExist(Is_1CBF8, 4096) && FileDelete(Is_1CBF8, 4096)) { 
   tmp_str00006 = IntegerToString(MagicInp, 0, 32);
   tmp_str00006 = tmp_str00006 + " rimuovo file";
   Print(tmp_str00006);
   return ;
   }} 
   if (Ib_09C81) { 
   func_1069();
   tmp_str00008 = Is_1CBF8;
   func_1072(tmp_str00008);
   } 
   tmp_str0000A = Is_09CA0 + "visualizzazione";
   tmp_str0000B = ObjectGetString(0, tmp_str0000A, 999, 0);
   
   if (tmp_str0000B == "Dashboard"){
   Gb_00007 = true;
   } 
   else { 
   Gb_00007 = false;
   } 
   func_1060(Gb_00007);
   tmp_str0000D = "";
   tmp_str0000E = "";
   tmp_str0000F = "";
   func_1085(0, tmp_str0000F, tmp_str0000E, tmp_str0000D, 0);
   Li_FFFFC = 0;
   if (Li_FFFFC < ArraySize(Input_Struct_00009D18)) { 
   do { 
   Ls_FFFF0 = Input_Struct_00009D18[Li_FFFFC].m_16;
   Ls_FFFE0 = Input_Struct_00009D18[Li_FFFFC].m_28;
   Li_FFFDC = Input_Struct_00009D18[Li_FFFFC].m_64;
   if (Ls_FFFF0 == "" || Ls_FFFE0 == "") { 
   
   } 
   else { 
   Ii_1D234 = Li_FFFDC;
   Li_FFFD8 = Li_FFFDC;
   Li_FFFD4 = 0;
   Coppia Local_Struct_FFFFFFA0[];
   Li_FFF9C = OrdersTotal() - 1;
   if (Li_FFF9C >= 0) { 
   do { 
   if (OrderSelect(Li_FFF9C, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_0000B = OrderMagicNumber();
   Gi_0000C = MagicInp + 1000;
   if (Gi_0000B < Gi_0000C) { 
   Gi_0000C = OrderMagicNumber();
   Gi_00010 = 0;
   Gi_00011 = ArraySize(Local_Struct_FFFFFFA0);
   Gb_00012 = false;
   if (Gi_00010 < Gi_00011) {
   do { 
   if (Local_Struct_FFFFFFA0[Gi_00010].m_64  == Gi_0000C) {
   Gb_00012 = true;
   break;
   }
   Gi_00010 = Gi_00010 + 1;
   Gi_00013 = ArraySize(Local_Struct_FFFFFFA0);
   } while (Gi_00010 < Gi_00013); 
   }
   
   if (Gb_00012 != true) { 
   Gi_00013 = OrderMagicNumber();
   Gi_00017 = 0;
   if (Gi_00017 < ArraySize(Input_Struct_00009CE4)) { 
   do { 
   if (Input_Struct_00009CE4[Gi_00017].m_64 == Gi_00013) { 
   Gi_00018 = ArraySize(Local_Struct_FFFFFFA0);
   ArrayResize(Local_Struct_FFFFFFA0, (Gi_00018 + 1), 0);
   Gi_00019 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00019 = Gi_00019 - 1;
   Local_Struct_FFFFFFA0[Gi_00019].m_16 = Input_Struct_00009CE4[Gi_00017].m_16;
   Gi_0001B = ArraySize(Local_Struct_FFFFFFA0);
   Gi_0001B = Gi_0001B - 1;
   Local_Struct_FFFFFFA0[Gi_0001B].m_28 = Input_Struct_00009CE4[Gi_00017].m_28;
   Gi_0001D = ArraySize(Local_Struct_FFFFFFA0);
   Gi_0001D = Gi_0001D - 1;
   Local_Struct_FFFFFFA0[Gi_0001D].m_64 = Input_Struct_00009CE4[Gi_00017].m_64;
   Gi_0001F = ArraySize(Local_Struct_FFFFFFA0);
   Gi_0001F = Gi_0001F - 1;
   Local_Struct_FFFFFFA0[Gi_0001F].m_56 = Input_Struct_00009CE4[Gi_00017].m_56;
   Gi_00021 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00021 = Gi_00021 - 1;
   Local_Struct_FFFFFFA0[Gi_00021].m_40 = Input_Struct_00009CE4[Gi_00017].m_40;
   Gi_00023 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00023 = Gi_00023 - 1;
   Local_Struct_FFFFFFA0[Gi_00023].m_48  = Input_Struct_00009CE4[Gi_00017].m_48 ;
   Gi_00025 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00025 = Gi_00025 - 1;
   Local_Struct_FFFFFFA0[Gi_00025].m_68 = Input_Struct_00009CE4[Gi_00017].m_68;
   Gi_00027 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00027 = Gi_00027 - 1;
   Local_Struct_FFFFFFA0[Gi_00027].m_76 = Input_Struct_00009CE4[Gi_00017].m_76;
   Gi_00029 = ArraySize(Local_Struct_FFFFFFA0);
   Gi_00029 = Gi_00029 - 1;
   Local_Struct_FFFFFFA0[Gi_00029].m_84 = Input_Struct_00009CE4[Gi_00017].m_84;
   break; 
   } 
   Gi_00017 = Gi_00017 + 1;
   } while (Gi_00017 < ArraySize(Input_Struct_00009CE4)); 
   } 
   Li_FFFD4 = Li_FFFD4 + 1;
   }}} 
   Li_FFF9C = Li_FFF9C - 1;
   } while (Li_FFF9C >= 0); 
   } 
   if (func_1073() || func_1074()) { 
   
   tmp_str00018 = "Stop per gain o loss raggiunto";
   tmp_str00019 = Is_09CA0 + "stop";
   ObjectCreate(0, tmp_str00019, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00019, tmp_str00018, 15, "Dubai", 255);
   ObjectSet(tmp_str00019, OBJPROP_CORNER, 2);
   Gd_0002B = (moltiplicatoreGrafiche * 20);
   Gi_0002C = (int)Gd_0002B;
   ObjectSet(tmp_str00019, OBJPROP_XDISTANCE, Gi_0002C);
   Gi_0002C = (int)Gd_0002B;
   ObjectSet(tmp_str00019, OBJPROP_YDISTANCE, Gi_0002C);
   ObjectSetInteger(0, tmp_str00019, 1011, 1);
   ObjectSetInteger(0, tmp_str00019, 1000, 0);
   ArrayFree(Local_Struct_FFFFFFA0);
   return ;
   } 
   tmp_str0001A = Is_09CA0 + "stop";
   ObjectDelete(0, tmp_str0001A);
   tmp_str0001C = Ls_FFFE0;
   tmp_str0001D = Ls_FFFF0;
   func_1076(Li_FFFFC, tmp_str0001D, tmp_str0001C);
   Gi_0002C = AccountFreeMarginMode();

   Lb_FFF9B = false;
   Lb_FFF9A = false;
   tmp_str00020 = Ls_FFFE0;
   tmp_str00021 = Ls_FFFF0;
   func_1093(Input_Struct_00009D18[Li_FFFFC], Li_FFFD4, Li_FFFFC, tmp_str00021, tmp_str00020, Lb_FFF9B, Lb_FFF9A);
   tmp_str00022 = Ls_FFFE0;
   tmp_str00023 = Ls_FFFF0;
   func_1095(Input_Struct_00009D18[Li_FFFFC], Li_FFFFC, tmp_str00023, tmp_str00022);
   tmp_str00024 = Ls_FFFE0;
   tmp_str00025 = Ls_FFFF0;
   func_1096(Li_FFFFC, tmp_str00025, tmp_str00024, lottiBase);
   tmp_str00026 = Ls_FFFE0;
   tmp_str00027 = Ls_FFFF0;
   func_1097(Input_Struct_00009D18[Li_FFFFC], tmp_str00027, tmp_str00026);
   tmp_str00028 = Ls_FFFE0;
   tmp_str00029 = Ls_FFFE0;
   tmp_str0002A = Ls_FFFF0;
   func_1085(Li_FFFFC, tmp_str0002A, tmp_str00029, tmp_str00028, 0);
   if (Lb_FFF9B || Lb_FFF9A != false) {
   
   if (Input_Struct_00009D18[Li_FFFFC].m_84) { 
   tmp_str0002E = "GLOBAL Reset permesso trade per valore Overlay di";
   tmp_str0002E = tmp_str0002E + Ls_FFFF0;
   tmp_str0002E = tmp_str0002E + " e";
   tmp_str0002E = tmp_str0002E + Ls_FFFE0;
   Print(tmp_str0002E);
   Input_Struct_00009D18[Li_FFFFC].m_84 = false;
   }} 
   ArrayFree(Local_Struct_FFFFFFA0);
   } 
   Li_FFFFC = Li_FFFFC + 1;
   } while (Li_FFFFC < ArraySize(Input_Struct_00009D18)); 
   } 
   if (utilizzaSpreadRatio != true) { 
   Li_FFF94 = 0;
   if (Li_FFF94 < ArraySize(Input_Struct_00009CE4)) { 
   do { 
   if ((Input_Struct_00009CE4[Li_FFF94].m_40 >= valoreOverlayPerIngresso)) { 
   Input_Struct_00009CE4[Li_FFF94].m_84 = false;
   } 
   Li_FFF94 = Li_FFF94 + 1;
   } while (Li_FFF94 < ArraySize(Input_Struct_00009CE4)); 
   }} 
   Gi_00034 = AccountFreeMarginMode();
   tmp_str00030 = Is_09CA0 + "visualizzazione";
   tmp_str00031 = ObjectGetString(0, tmp_str00030, 999, 0);
   if (tmp_str00031 != "Manager") return; 
   func_1047();
   
}

void OnDeinit(const int reason)
{
   //MqlLock_65DDAF1D_13_IIi1Iii11I(Ii_1D254, _UninitReason);
   ObjectsDeleteAll(0, Is_09CA0, -1, -1);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   string tmp_str00074;
   string tmp_str00075;
   string tmp_str00076;
   string tmp_str00077;
   string tmp_str00078;
   string tmp_str00079;
   string tmp_str0007A;
   string tmp_str0007B;
   string tmp_str0007C;
   string tmp_str0007D;
   string tmp_str0007E;
   string tmp_str0007F;
   string tmp_str00080;
   string tmp_str00081;
   string tmp_str00082;
   string tmp_str00083;
   string tmp_str00084;
   string tmp_str00085;
   string tmp_str00086;
   string tmp_str00087;
   string tmp_str00088;
   string tmp_str00089;
   string tmp_str0008A;
   string tmp_str0008B;
   string tmp_str0008C;
   string tmp_str0008D;
   string tmp_str0008E;
   string tmp_str0008F;
   string tmp_str00090;
   string tmp_str00091;
   string tmp_str00092;
   string tmp_str00093;
   string tmp_str00094;
   string tmp_str00095;
   string tmp_str00096;
   string tmp_str00097;
   string tmp_str00098;
   string tmp_str00099;
   string tmp_str0009A;
   string tmp_str0009B;
   string tmp_str0009C;
   string tmp_str0009D;
   string tmp_str0009E;
   string tmp_str0009F;
   string tmp_str000A0;
   string tmp_str000A1;
   string tmp_str000A2;
   string tmp_str000A3;
   string tmp_str000A4;
   string tmp_str000A5;
   string tmp_str000A6;
   string tmp_str000A7;
   string tmp_str000A8;
   string tmp_str000A9;
   string tmp_str000AA;
   string tmp_str000AB;
   string tmp_str000AC;
   string tmp_str000AD;
   string tmp_str000AE;
   string tmp_str000AF;
   string tmp_str000B0;
   string tmp_str000B1;
   string tmp_str000B2;
   string tmp_str000B3;
   string tmp_str000B4;
   string tmp_str000B5;
   string tmp_str000B6;
   string tmp_str000B7;
   string tmp_str000B8;
   string tmp_str000B9;
   string tmp_str000BA;
   string tmp_str000BB;
   string tmp_str000BC;
   string tmp_str000BD;
   string tmp_str000BE;
   string tmp_str000BF;
   string tmp_str000C0;
   string tmp_str000C1;
   string tmp_str000C2;
   string tmp_str000C3;
   string tmp_str000C4;
   string tmp_str000C5;
   string tmp_str000C6;
   string tmp_str000C7;
   string tmp_str000C8;
   string tmp_str000C9;
   string tmp_str000CA;
   string tmp_str000CB;
   string tmp_str000CC;
   string tmp_str000CD;
   string tmp_str000CE;
   string tmp_str000CF;
   string tmp_str000D0;
   string tmp_str000D1;
   string tmp_str000D2;
   string tmp_str000D3;
   string tmp_str000D4;
   string tmp_str000D5;
   string tmp_str000D6;
   string tmp_str000D7;
   string tmp_str000D8;
   string tmp_str000D9;
   string tmp_str000DA;
   string tmp_str000DB;
   string tmp_str000DC;
   string tmp_str000DD;
   string tmp_str000DE;
   string tmp_str000DF;
   string tmp_str000E0;
   string tmp_str000E1;
   string tmp_str000E2;
   string tmp_str000E3;
   string tmp_str000E4;
   string tmp_str000E5;
   string tmp_str000E6;
   string tmp_str000E7;
   string tmp_str000E8;
   string tmp_str000E9;
   string tmp_str000EA;
   string tmp_str000EB;
   string tmp_str000EC;
   string tmp_str000ED;
   string tmp_str000EE;
   string tmp_str000EF;
   string tmp_str000F0;
   string tmp_str000F1;
   string tmp_str000F2;
   string tmp_str000F3;
   string tmp_str000F4;
   string tmp_str000F5;
   string tmp_str000F6;
   string tmp_str000F7;
   string tmp_str000F8;
   string tmp_str000F9;
   string tmp_str000FA;
   string tmp_str000FB;
   string tmp_str000FC;
   string tmp_str000FD;
   string tmp_str000FE;
   string tmp_str000FF;
   string tmp_str00100;
   string tmp_str00101;
   string tmp_str00102;
   string tmp_str00103;
   string tmp_str00104;
   string tmp_str00105;
   string tmp_str00106;
   string tmp_str00107;
   string tmp_str00108;
   string tmp_str00109;
   string tmp_str0010A;
   string tmp_str0010B;
   string tmp_str0010C;
   string tmp_str0010D;
   string tmp_str0010E;
   string tmp_str0010F;
   string tmp_str00110;
   string tmp_str00111;
   string tmp_str00112;
   string tmp_str00113;
   string tmp_str00114;
   string tmp_str00115;
   string tmp_str00116;
   string tmp_str00117;
   string tmp_str00118;
   string tmp_str00119;
   string tmp_str0011A;
   string tmp_str0011B;
   string tmp_str0011C;
   string tmp_str0011D;
   string tmp_str0011E;
   string tmp_str0011F;
   string tmp_str00120;
   string tmp_str00121;
   string tmp_str00122;
   string tmp_str00123;
   string tmp_str00124;
   string tmp_str00125;
   string tmp_str00126;
   string tmp_str00127;
   string tmp_str00128;
   string tmp_str00129;
   string tmp_str0012A;
   string tmp_str0012B;
   string tmp_str0012C;
   string tmp_str0012D;
   string tmp_str0012E;
   string tmp_str0012F;
   string tmp_str00130;
   string tmp_str00131;
   string tmp_str00132;
   string tmp_str00133;
   string tmp_str00134;
   string tmp_str00135;
   string tmp_str00136;
   string tmp_str00137;
   string tmp_str00138;
   string tmp_str00139;
   string tmp_str0013A;
   int Li_FFFC8;
   int Li_FFFC4;
   string Ls_FFFB8;
   string Ls_FFFA8;
   int Li_FFFA4;
   int Li_FFF6C;
   int Li_FFF68;
   string Ls_FFF58;
   string Ls_FFF48;
   int Li_FFF44;
   string Ls_FFF00;
   int Li_FFE94;
   int Li_FFE90;
   string Ls_FFE80;
   string Ls_FFE70;
   int Li_FFE6C;
   int Li_FFE34;
   int Li_FFE30;
   string Ls_FFE20;
   string Ls_FFE10;
   int Li_FFE0C;
   int Li_FFDB4;
   int Li_FFDB0;
   string Ls_FFDA0;
   string Ls_FFD90;
   int Li_FFD8C;
   int Li_FFD68;
   string Ls_FFD58;
   string Ls_FFD48;
   int Li_FFD44;
   int Li_FFD40;
   string Ls_FFD30;
   string Ls_FFD20;
   int Li_FFD1C;
   int Li_FFCF4;
   string Ls_FFCE8;
   string Ls_FFCD8;
   int Li_FFCD4;
   string Ls_FFCC8;
   double Ld_FFCC0;
   double Ld_FFCB8;
   double Ld_FFCB0;
   string Ls_FFD10;
   double Ld_FFD08;
   double Ld_FFD00;
   double Ld_FFCF8;
   double Ld_FFD80;
   double Ld_FFD78;
   double Ld_FFD70;
   int Li_FFD6C;
   double Ld_FFE00;
   double Ld_FFDF8;
   double Ld_FFDF0;
   int Li_FFDEC;

   tmp_str00002 = Is_09CA0 + "visualizzazione";
   if (sparam == tmp_str00002) { 
   Print("Cliccato su visualizzazione");
   tmp_str00003 = ObjectGetString(0, sparam, 999, 0);
   if (tmp_str00003 == "Dashboard"){
   ObjectSetString(0, sparam, 999, "Manager");
   ObjectsDeleteAll(0, Is_09CA0, -1, -1);
   func_1047();
   } 
   else { 

   ObjectSetString(0, sparam, 999, "Dashboard");
   ObjectsDeleteAll(0, Is_09CA0, -1, -1);
   ArrayInitialize(Il_0B0DC, 0);
   ArrayInitialize(Il_0D050, 0);
   func_1058();
   func_1060(true);
   }} 
   tmp_str0000C = Is_09CA0 + "buttons";
   if (sparam == tmp_str0000C) { 
   Print("Cliccato open buttons");
   tmp_str0000E = Is_09CA0 + "visualizzazione";
   tmp_str0000F = ObjectGetString(0, tmp_str0000E, 999, 0);
   if (tmp_str0000F == "Manager") { 
   tmp_str00011 = ObjectGetString(0, sparam, 999, 0);

   if (tmp_str00011 == "Ñ") { 
   ObjectSetString(0, sparam, 999, "Ê");

   ObjectSetString(0, sparam, 1001, "Wingdings 2");
   ObjectsDeleteAll(0, Is_09CA0, -1, -1);
   func_1047();
   } 
   else { 
   tmp_str00016 = ObjectGetString(0, sparam, 999, 0);
   if (tmp_str00016 == "Ê") { 
   ObjectSetString(0, sparam, 999, "Ñ");
   ObjectSetString(0, sparam, 1001, "Wingdings 2");
   func_1047();
   }}} 
   ChartRedraw(0);
   } 
   tmp_str0001F = sparam;
   
   tmp_str00021 = Is_09CA0 + "_MNchiudiTutto_";
   Gi_00003 = StringFind(sparam, tmp_str00021);
   if (Gi_00003 >= 0) { 
   string Ls_FFFCC[];
   tmp_str00022 = "_";
   tmp_str00024 = sparam;

   Gst_00004 = (short)StringGetCharacter("_", 0);
   StringSplit(tmp_str00024, Gst_00004, Ls_FFFCC);
   Li_FFFC8 = (int)Ls_FFFCC[3];
   
   tmp_str00027 = "Numero cliccato :";
   tmp_str00028 = (string)Li_FFFC8;
   tmp_str00027 = tmp_str00027 + tmp_str00028;
   Print(tmp_str00027);
   Li_FFFC4 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFFB8 = Input_Struct_00009D18[Li_FFFC4].m_16;
   Ls_FFFA8 = Input_Struct_00009D18[Li_FFFC4].m_28;
   Li_FFFA4 = Input_Struct_00009D18[Li_FFFC4].m_64;
   if (Ls_FFFB8 == "") { 
   } 
   else { 
   if (Li_FFFC8 == Li_FFFA4) { 
   tmp_str0002A = "Trovato : ";
   tmp_str0002A = tmp_str0002A + Ls_FFFB8;
   tmp_str0002A = tmp_str0002A + "Trovato : ";;
   tmp_str0002A = tmp_str0002A + Ls_FFFA8;
   Print(tmp_str0002A);
   tmp_str0002C = "Chiusura manuale";

   tmp_str0002E = "LS";
   tmp_str0002D = Ls_FFFA8;
   tmp_str0002F = Ls_FFFB8;
   func_1098(tmp_str0002F, tmp_str0002D, Li_FFFA4, tmp_str0002E, tmp_str0002C);

   tmp_str00032 = "Chiusura manuale";

   tmp_str00034 = "SS";
   tmp_str00033 = Ls_FFFA8;
   tmp_str00035 = Ls_FFFB8;
   func_1098(tmp_str00035, tmp_str00033, Li_FFFA4, tmp_str00034, tmp_str00032);
   break; 
   }} 
   Li_FFFC4 = Li_FFFC4 + 1;
   } while (Li_FFFC4 < ArraySize(Input_Struct_00009D18)); 
   } 
   ArrayFree(Ls_FFFCC);
   } 
   
   tmp_str00039 = Is_09CA0 + "_MNapriChart_";
   Gi_00008 = StringFind(sparam, tmp_str00039);
   if (Gi_00008 >= 0) { 
   string Ls_FFF70[];
   tmp_str0003B = "_";
   tmp_str0003C = sparam;
   
   Gst_00009 = (short)StringGetCharacter("_", 0);
   StringSplit(tmp_str0003C, Gst_00009, Ls_FFF70);
   Li_FFF6C = (int)Ls_FFF70[3];
   
   tmp_str00041 = "Numero cliccato :";
   tmp_str00040 = (string)Li_FFF6C;
   tmp_str00041 = tmp_str00041 + tmp_str00040;
   Print(tmp_str00041);
   Li_FFF68 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFF58 = Input_Struct_00009D18[Li_FFF68].m_16;
   Ls_FFF48 = Input_Struct_00009D18[Li_FFF68].m_28;;
   Li_FFF44 = Input_Struct_00009D18[Li_FFF68].m_64;
   if (Ls_FFF58 == "") { 
   } 
   else { 
   if (Li_FFF6C == Li_FFF44) { 
   Il_1D240 = ChartOpen(Ls_FFF58, 0);
   if (Il_1D240 != Il_1D248) { 
   Il_1D248 = Il_1D240;
   tmp_str00040 = Ls_FFF48;
   func_1100(tmp_str00040);
   tmp_str00044 = "\\Files\\";
   tmp_str00044 = tmp_str00044 + nomeTemplate;
   ChartApplyTemplate(Il_1D240, tmp_str00044);
   } 
   break; 
   }} 
   Li_FFF68 = Li_FFF68 + 1;
   } while (Li_FFF68 < ArraySize(Input_Struct_00009D18)); 
   } 
   ArrayFree(Ls_FFF70);
   } 
   Gi_0000D = StringFind(sparam, Is_09CA0);
   if (Gi_0000D >= 0) { 

   if (StringFind(sparam, "_DatiY") >= 0 
   || StringFind(sparam, "_VAL") >= 0 
   || StringFind(sparam, "_Dir") >= 0 
   || StringFind(sparam, "_VAL2") >= 0) {
   
   string Ls_FFF10[];

   Gst_0000F = (short)StringGetCharacter("_", 0);
   StringSplit(sparam, Gst_0000F, Ls_FFF10);
   Ls_FFF00 = Ls_FFF10[1];
   string Ls_FFECC[];

   Gst_00011 = (short)StringGetCharacter("-", 0);
   StringSplit(Ls_FFF00, Gst_00011, Ls_FFECC);
   if (ArraySize(Ls_FFECC) > 1) { 
   tmp_str00061 = "Strumenti :";
   tmp_str00061 = tmp_str00061 + Ls_FFECC[0];
   
   tmp_str00061 = tmp_str00061 + " ";
   tmp_str00061 = tmp_str00061 + Ls_FFECC[1];
   Print(tmp_str00061);
   Il_1D240 = ChartOpen(Ls_FFECC[0], 0);
   if (Il_1D240 != Il_1D248) { 
   Il_1D248 = Il_1D240;
   tmp_str00062 = Ls_FFECC[1];
   func_1100(tmp_str00062);
   
   tmp_str00065 = "\\Files\\" + nomeTemplate;
   ChartApplyTemplate(Il_1D240, tmp_str00065);
   }} 
   ArrayFree(Ls_FFECC);
   ArrayFree(Ls_FFF10);
   }} 

   tmp_str00066 = Is_09CA0 + "_MNstrumenti_";
   Gi_00016 = StringFind(sparam, tmp_str00066);
   if (Gi_00016 >= 0) { 
   string Ls_FFE98[];
   tmp_str00066 = Is_1CC08;

   Gst_00017 = (short)StringGetCharacter("_", 0);
   StringSplit(sparam, Gst_00017, Ls_FFE98);
   Li_FFE94 = (int)Ls_FFE98[3];
   tmp_str00070 = "Numero cliccato :";
   tmp_str0006F = (string)Li_FFE94;
   tmp_str00070 = tmp_str00070 + tmp_str0006F;
   Print(tmp_str00070);
   Li_FFE90 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFE80 = Input_Struct_00009D18[Li_FFE90].m_16;
   Ls_FFE70 = Input_Struct_00009D18[Li_FFE90].m_28;
   Li_FFE6C = Input_Struct_00009D18[Li_FFE90].m_64;
   if (Ls_FFE80 == "") { 
   } 
   else { 
   if (Li_FFE94 == Li_FFE6C) { 
   tmp_str0006F = ObjectGetString(0, sparam, 999, 0);

   if (tmp_str0006F == "All Spread") { 
   ObjectSetString(0, sparam, 999, Ls_FFE80);
   } 
   else { 
   if (ObjectGetString(0, sparam, 999, 0) == Ls_FFE80) { 
   ObjectSetString(0, sparam, 999, Ls_FFE70);
   } 
   else { 
   ObjectSetString(0, sparam, 999, "All Spread");
   }}}} 
   Li_FFE90 = Li_FFE90 + 1;
   } while (Li_FFE90 < ArraySize(Input_Struct_00009D18)); 
   } 
   ArrayFree(Ls_FFE98);
   } 

   tmp_str00077 = Is_09CA0 + "_MNLongSpread_";
   tmp_str00078 = sparam;
   Gi_0001D = StringFind(sparam, tmp_str00077);
   if (Gi_0001D >= 0) { 
   string Ls_FFE38[];

   Gst_0001E = (short)StringGetCharacter("_", 0);
   StringSplit(sparam, Gst_0001E, Ls_FFE38);
   Li_FFE34 = (int)Ls_FFE38[3];

   tmp_str0007F = (string)Li_FFE34;
   tmp_str00080 = "Numero cliccato :" + tmp_str0007F;
   Print(tmp_str00080);
   Li_FFE30 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFE20 = Input_Struct_00009D18[Li_FFE30].m_16;
   Ls_FFE10 = Input_Struct_00009D18[Li_FFE30].m_28;
   Li_FFE0C = Input_Struct_00009D18[Li_FFE30].m_64;
   if (Ls_FFE20 == "") { 
   } 
   else { 
   if (Li_FFE34 == Li_FFE0C) { 

   tmp_str00081 = Is_09CA0 + "_MNeditLots_";
   tmp_str00081 = tmp_str00081 + Ls_FFE20;
   tmp_str00081 = tmp_str00081 + "/";
   tmp_str00081 = tmp_str00081 + Ls_FFE10;
   tmp_str00081 = tmp_str00081 + "_";
   tmp_str00081 = tmp_str00081 + IntegerToString(Li_FFE0C, 0, 32);
   tmp_str00084 = ObjectGetString(0, tmp_str00081, 999, 0);

   Ld_FFE00 = StringToDouble(tmp_str00084);
   if (calcolaLottiAutomaticamente != true) { 
   Gd_00025 = Ld_FFE00;
   } 
   else { 
   tmp_str00085 = Ls_FFE20;
   tmp_str00086 = Ls_FFE10;
   Gd_00025 = func_1037(tmp_str00086, tmp_str00085, 0, Ld_FFE00);
   } 
   Ld_FFDF8 = Gd_00025;
   if (calcolaLottiAutomaticamente != true) { 
   Gd_00025 = Ld_FFE00;
   } 
   else { 
   tmp_str00087 = Ls_FFE10;
   tmp_str00088 = Ls_FFE20;
   Gd_00025 = func_1037(tmp_str00088, tmp_str00087, Ld_FFE00, 0);
   } 
   Ld_FFDF0 = Gd_00025;
   tmp_str0008B = "Long Spread Manuale Trovato : " + Ls_FFE20;
   tmp_str0008B = tmp_str0008B + " ";
   tmp_str0008B = tmp_str0008B + Ls_FFE10;
   tmp_str0008B = tmp_str0008B + " ";
   tmp_str0008B = tmp_str0008B + DoubleToString(Ld_FFDF8, 2);
   tmp_str0008B = tmp_str0008B + " ";
   tmp_str0008B = tmp_str0008B + DoubleToString(Gd_00025, 2);
   Print(tmp_str0008B);
   if (richiediConfermaInserimentoOperazioni) { 

   tmp_str00090 = "Richiesta conferma";
   tmp_str00092 = "Sicuro di voler inserire un'operazione Long Spread su " + Ls_FFE20;
   tmp_str00092 = tmp_str00092 + "-";
   tmp_str00092 = tmp_str00092 + Ls_FFE10;
   tmp_str00092 = tmp_str00092 + "?";
   Gi_0002A = MessageBox(tmp_str00092, tmp_str00090, 4);
   } 
   else { 
   Gi_0002A = 6;
   } 
   Li_FFDEC = Gi_0002A;
   if (Gi_0002A == 6) { 
   if ((Ld_FFDF8 != 0) && (Ld_FFDF0 != 0)) {
   Ii_09CAC = Ii_09CAC + 1;
   tmp_str00094 = Is_09CA0 + "_MNstrumenti_";
   tmp_str00094 = tmp_str00094 + Ls_FFE20;
   tmp_str00094 = tmp_str00094 + "/";
   tmp_str00094 = tmp_str00094 + Ls_FFE10;
   tmp_str00094 = tmp_str00094 + "_";
   tmp_str00094 = tmp_str00094 + IntegerToString(Li_FFE0C, 0, 32);
   tmp_str00097 = ObjectGetString(0, tmp_str00094, 999, 0);
   tmp_str00098 = listaSpreadDaNonTradare2;
   tmp_str00099 = Is_1CBF8;
   if (tmp_str00097 == "All Spread") { 
   tmp_str0009B = "LS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str0009A = Ls_FFE10;
   tmp_str0009C = Ls_FFE20;
   tmp_str0009D = Ls_FFE20;
   func_1046(tmp_str0009D, tmp_str0009C, tmp_str0009A, Li_FFE0C, 0, Ld_FFDF8, SymbolInfoDouble(Ls_FFE20, SYMBOL_ASK), tmp_str0009B, 16711680, 0, 0);
   tmp_str0009F = "LS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str0009E = Ls_FFE10;
   tmp_str000A0 = Ls_FFE20;
   tmp_str000A1 = Ls_FFE10;
   func_1046(tmp_str000A1, tmp_str000A0, tmp_str0009E, Li_FFE0C, 1, Ld_FFDF0, SymbolInfoDouble(Ls_FFE10, SYMBOL_BID), tmp_str0009F, 255, 0, 0);
   } 
   tmp_str000A2 = Is_09CA0 + "_MNstrumenti_";
   tmp_str000A2 = tmp_str000A2 + Ls_FFE20;
   tmp_str000A2 = tmp_str000A2 + "/";
   tmp_str000A2 = tmp_str000A2 + Ls_FFE10;
   tmp_str000A2 = tmp_str000A2 + "_";
   tmp_str000A2 = tmp_str000A2 + IntegerToString(Li_FFE0C, 0, 32);
   if (ObjectGetString(0, tmp_str000A2, 999, 0) == Ls_FFE20) { 
   tmp_str000A7 = "LS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000A6 = Ls_FFE10;
   tmp_str000A8 = Ls_FFE20;
   tmp_str000A9 = Ls_FFE20;
   func_1046(tmp_str000A9, tmp_str000A8, tmp_str000A6, Li_FFE0C, 0, Ld_FFDF8, SymbolInfoDouble(Ls_FFE20, SYMBOL_ASK), tmp_str000A7, 16711680, 0, 0);
   } 
   tmp_str000AB = Is_09CA0 + "_MNstrumenti_";
   tmp_str000AB = tmp_str000AB + Ls_FFE20;
   tmp_str000AB = tmp_str000AB + "/";
   tmp_str000AB = tmp_str000AB + Ls_FFE10;
   tmp_str000AB = tmp_str000AB + "_";
   tmp_str000AB = tmp_str000AB + IntegerToString(Li_FFE0C, 0, 32);
   if (ObjectGetString(0, tmp_str000AB, 999, 0) == Ls_FFE10) {
   tmp_str000B2 = "SS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000B1 = Ls_FFE10;
   tmp_str000B3 = Ls_FFE20;
   tmp_str000B4 = Ls_FFE10;
   func_1046(tmp_str000B4, tmp_str000B3, tmp_str000B1, Li_FFE0C, 0, Ld_FFDF0, SymbolInfoDouble(Ls_FFE10, SYMBOL_ASK), tmp_str000B2, 16711680, 0, 0);
   }}
   else{
   Alert("Attenzione indicare una size diversa da 0");
   }} 
   ObjectSetInteger(0, sparam, 1018, 0);
   break; 
   }} 
   Li_FFE30 = Li_FFE30 + 1;
   } while (Li_FFE30 < ArraySize(Input_Struct_00009D18)); 
   } 
   ArrayFree(Ls_FFE38);
   } 
   tmp_str000BA = Is_09CA0 + "_MNShortSpread_";
   Gi_00030 = StringFind(sparam, tmp_str000BA);
   if (Gi_00030 >= 0) { 
   string Ls_FFDB8[];

   Gst_00031 = (short)StringGetCharacter("_", 0);
   StringSplit(sparam, Gst_00031, Ls_FFDB8);
   Li_FFDB4 = (int)Ls_FFDB8[3];
   tmp_str000C3 = (string)Li_FFDB4;
   tmp_str000C4 = "Numero cliccato :" + tmp_str000C3;
   Print(tmp_str000C4);
   Li_FFDB0 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFDA0 = Input_Struct_00009D18[Li_FFDB0].m_16;
   Ls_FFD90 = Input_Struct_00009D18[Li_FFDB0].m_28;
   Li_FFD8C = Input_Struct_00009D18[Li_FFDB0].m_64;
   if (Ls_FFDA0 == "") { 
   } 
   else { 
   if (Li_FFDB4 == Li_FFD8C) { 
   tmp_str000C6 = Is_09CA0 + "_MNeditLots_";
   tmp_str000C6 = tmp_str000C6 + Ls_FFDA0;
   tmp_str000C6 = tmp_str000C6 + "/";
   tmp_str000C6 = tmp_str000C6 + Ls_FFD90;
   tmp_str000C6 = tmp_str000C6 + "_";
   tmp_str000C6 = tmp_str000C6 + IntegerToString(Li_FFD8C, 0, 32);
   tmp_str000CA = ObjectGetString(0, tmp_str000C6, 999, 0);
   returned_double = StringToDouble(tmp_str000CA);
   Gd_0003B = returned_double;
   Ld_FFD80 = Gd_0003B;
   if (calcolaLottiAutomaticamente != true) { 
   } 
   else { 
   tmp_str000C5 = Ls_FFDA0;
   tmp_str000CB = Ls_FFD90;
   Gd_0003B = func_1037(tmp_str000CB, tmp_str000C5, 0, Ld_FFD80);
   } 
   Ld_FFD78 = Gd_0003B;
   if (calcolaLottiAutomaticamente != true) { 
   Gd_0003B = Ld_FFD80;
   } 
   else { 
   tmp_str000CC = Ls_FFD90;
   tmp_str000CD = Ls_FFDA0;
   Gd_0003B = func_1037(tmp_str000CD, tmp_str000CC, Ld_FFD80, 0);
   } 
   Ld_FFD70 = Gd_0003B;
   tmp_str000D0 = "Short Spread Manuale Trovato : " + Ls_FFDA0;
   tmp_str000D0 = tmp_str000D0 + " ";
   tmp_str000D0 = tmp_str000D0 + Ls_FFD90;
   tmp_str000D0 = tmp_str000D0 + " ";
   tmp_str000D0 = tmp_str000D0 + DoubleToString(Ld_FFD78, 2);
   tmp_str000D0 = tmp_str000D0 + " ";
   tmp_str000D0 = tmp_str000D0 + DoubleToString(Gd_0003B, 2);
   Print(tmp_str000D0);
   if (richiediConfermaInserimentoOperazioni) { 
   tmp_str000D6 = "Richiesta conferma";
   tmp_str000D7 = "Sicuro di voler inserire un'operazione Short Spread su " + Ls_FFDA0;
   tmp_str000D7 = tmp_str000D7 + "-";
   tmp_str000D7 = tmp_str000D7 + Ls_FFD90;
   tmp_str000D7 = tmp_str000D7 + "?";
   Gi_0003D = MessageBox(tmp_str000D7, tmp_str000D6, 4);
   } 
   else { 
   Gi_0003D = 6;
   } 
   Li_FFD6C = Gi_0003D;
   if (Gi_0003D == 6) { 
   if ((Ld_FFD78 != 0) && (Ld_FFD70 != 0)) {
   Ii_09CAC = Ii_09CAC + 1;
   tmp_str000DA = Is_09CA0 + "_MNstrumenti_";
   tmp_str000DA = tmp_str000DA + Ls_FFDA0;
   tmp_str000DA = tmp_str000DA + "/";
   tmp_str000DA = tmp_str000DA + Ls_FFD90;
   tmp_str000DA = tmp_str000DA + "_";
   tmp_str000DA = tmp_str000DA + IntegerToString(Li_FFD8C, 0, 32);
   tmp_str000DD = ObjectGetString(0, tmp_str000DA, 999, 0);
   if (tmp_str000DD == "All Spread") { 
   tmp_str000DF = "SS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000DE = Ls_FFD90;
   tmp_str000E0 = Ls_FFDA0;
   tmp_str000E1 = Ls_FFDA0;
   func_1046(tmp_str000E1, tmp_str000E0, tmp_str000DE, Li_FFD8C, 1, Ld_FFD78, SymbolInfoDouble(Ls_FFDA0, SYMBOL_BID), tmp_str000DF, 255, 0, 0);
   tmp_str000E5 = "SS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000E4 = Ls_FFD90;
   tmp_str000E6 = Ls_FFDA0;
   tmp_str000E7 = Ls_FFD90;
   func_1046(tmp_str000E7, tmp_str000E6, tmp_str000E4, Li_FFD8C, 0, Ld_FFD70, SymbolInfoDouble(Ls_FFD90, SYMBOL_ASK), tmp_str000E5, 16711680, 0, 0);
   } 

   tmp_str000EA = Is_09CA0 + "_MNstrumenti_";
   tmp_str000EA = tmp_str000EA + Ls_FFDA0;
   tmp_str000EA = tmp_str000EA + "/";
   tmp_str000EA = tmp_str000EA + Ls_FFD90;
   tmp_str000EA = tmp_str000EA + "_";
   tmp_str000EA = tmp_str000EA + IntegerToString(Li_FFD8C, 0, 32);
   if (ObjectGetString(0, tmp_str000EA, 999, 0) == Ls_FFDA0) { 

   tmp_str000ED = "SS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000EC = Ls_FFD90;
   tmp_str000EE = Ls_FFDA0;
   tmp_str000EF = Ls_FFDA0;
   func_1046(tmp_str000EF, tmp_str000EE, tmp_str000EC, Li_FFD8C, 1, Ld_FFD78, SymbolInfoDouble(Ls_FFDA0, SYMBOL_BID), tmp_str000ED, 255, 0, 0);
   } 
   
   tmp_str000F1 = Is_09CA0 + "_MNstrumenti_";
   tmp_str000F1 = tmp_str000F1 + Ls_FFDA0;
   tmp_str000F1 = tmp_str000F1 + "/";
   tmp_str000F1 = tmp_str000F1 + Ls_FFD90;
   tmp_str000F1 = tmp_str000F1 + "_";
   tmp_str000F1 = tmp_str000F1 + IntegerToString(Li_FFD8C, 0, 32);
   if (ObjectGetString(0, tmp_str000F1, 999, 0) == Ls_FFD90) {
   tmp_str000F7 = "LS_Pir" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str000F6 = Ls_FFD90;
   tmp_str000F8 = Ls_FFDA0;
   tmp_str000F9 = Ls_FFD90;
   func_1046(tmp_str000F9, tmp_str000F8, tmp_str000F6, Li_FFD8C, 1, Ld_FFD70, SymbolInfoDouble(Ls_FFD90, SYMBOL_BID), tmp_str000F7, 255, 0, 0);
   }}
   else{
   Alert("Attenzione indicare una size diversa da 0");
   }} 
   ObjectSetInteger(0, sparam, 1018, 0);
   break; 
   }} 
   Li_FFDB0 = Li_FFDB0 + 1;
   } while (Li_FFDB0 < ArraySize(Input_Struct_00009D18)); 
   } 
   ArrayFree(Ls_FFDB8);
   } 

   tmp_str000FD = Is_09CA0 + "_chiudiTotale";
   if (sparam == tmp_str000FD) { 
   Ib_1D238 = true;
   Li_FFD68 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFD58 = Input_Struct_00009D18[Li_FFD68].m_16;
   Ls_FFD48 = Input_Struct_00009D18[Li_FFD68].m_28;
   Li_FFD44 = Input_Struct_00009D18[Li_FFD68].m_64;
   if (Ls_FFD58 == "" || Ls_FFD48 == "") { 
   
   } 
   else { 
   tmp_str00100 = "Trovato Totale : " + Ls_FFD58;
   tmp_str00100 = tmp_str00100 + " " ;
   tmp_str00100 = tmp_str00100 + Ls_FFD48;
   Print(tmp_str00100);
   tmp_str00103 = "Chiusura Totale manuale";
   tmp_str00105 = "LS";
   tmp_str00104 = Ls_FFD48;
   tmp_str00106 = Ls_FFD58;
   func_1098(tmp_str00106, tmp_str00104, Li_FFD44, tmp_str00105, tmp_str00103);
   tmp_str00109 = "Chiusura Totale manuale";
   tmp_str0010C = "SS";
   tmp_str0010B = Ls_FFD48;
   tmp_str0010D = Ls_FFD58;
   func_1098(tmp_str0010D, tmp_str0010B, Li_FFD44, tmp_str0010C, tmp_str00109);
   } 
   Li_FFD68 = Li_FFD68 + 1;
   } while (Li_FFD68 < ArraySize(Input_Struct_00009D18)); 
   } 
   Ib_1D238 = false;
   } 
   tmp_str0010F = Is_09CA0 + "_chiudiGain";
   if (sparam == tmp_str0010F) { 
   Li_FFD40 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFD30 = Input_Struct_00009D18[Li_FFD40].m_16;
   Ls_FFD20 = Input_Struct_00009D18[Li_FFD40].m_28;
   Li_FFD1C = Input_Struct_00009D18[Li_FFD40].m_64;
   if (Ls_FFD30 == "" || Ls_FFD20 == "") { 
   
   } 
   else { 
   Ls_FFD10 = "Flat";
   Ld_FFD08 = 0;
   Ld_FFD00 = 0;
   Ld_FFCF8 = 0;
   tmp_str00110 = Ls_FFD20;
   tmp_str00111 = Ls_FFD30;
   func_1048(tmp_str00111, tmp_str00110, Li_FFD1C, Ls_FFD10, Ld_FFD08, Ld_FFD00, Ld_FFCF8);
   if ((Ld_FFD08 > 0)) { 
   tmp_str00114 = "Chiusura Totale Gain";
   tmp_str00116 = "LS";
   tmp_str00115 = Ls_FFD20;
   tmp_str00117 = Ls_FFD30;
   func_1098(tmp_str00117, tmp_str00115, Li_FFD1C, tmp_str00116, tmp_str00114);
   tmp_str0011A = "Chiusura Totale Gain";
   tmp_str0011C = "SS";
   tmp_str0011B = Ls_FFD20;
   tmp_str0011D = Ls_FFD30;
   func_1098(tmp_str0011D, tmp_str0011B, Li_FFD1C, tmp_str0011C, tmp_str0011A);
   }} 
   Li_FFD40 = Li_FFD40 + 1;
   } while (Li_FFD40 < ArraySize(Input_Struct_00009D18)); 
   }} 
   tmp_str0011F = Is_09CA0 + "_chiudiLoss";
   if (sparam == tmp_str0011F) { 
   Li_FFCF4 = 0;
   if (ArraySize(Input_Struct_00009D18) > 0) { 
   do { 
   Ls_FFCE8 = Input_Struct_00009D18[Li_FFCF4].m_16;
   Ls_FFCD8 = Input_Struct_00009D18[Li_FFCF4].m_28;
   Li_FFCD4 = Input_Struct_00009D18[Li_FFCF4].m_64;
   if (Ls_FFCE8 == "" || Ls_FFCD8 == "") { 
   
   } 
   else { 
   Ls_FFCC8 = "Flat";
   Ld_FFCC0 = 0;
   Ld_FFCB8 = 0;
   Ld_FFCB0 = 0;
   tmp_str00120 = Ls_FFCD8;
   tmp_str00121 = Ls_FFCE8;
   func_1048(tmp_str00121, tmp_str00120, Li_FFCD4, Ls_FFCC8, Ld_FFCC0, Ld_FFCB8, Ld_FFCB0);
   if ((Ld_FFCC0 < 0)) { 
   tmp_str00124 = "Chiusura Totale Loss";
   tmp_str00126 = "LS";
   tmp_str00125 = Ls_FFCD8;
   tmp_str00127 = Ls_FFCE8;
   func_1098(tmp_str00127, tmp_str00125, Li_FFCD4, tmp_str00126, tmp_str00124);
   tmp_str0012A = "Chiusura Totale Loss";
   tmp_str0012C = "SS";
   tmp_str0012B = Ls_FFCD8;
   tmp_str0012D = Ls_FFCE8;
   func_1098(tmp_str0012D, tmp_str0012B, Li_FFCD4, tmp_str0012C, tmp_str0012A);
   }} 
   Li_FFCF4 = Li_FFCF4 + 1;
   } while (Li_FFCF4 < ArraySize(Input_Struct_00009D18)); 
   }} 
   tmp_str0012F = Is_09CA0 + "_newGrids";
   if (sparam != tmp_str0012F) return; 
   tmp_str0012F = IntegerToString(MagicInp, 0, 32);
   tmp_str0012F = tmp_str0012F + "_newgrid";
   if (GlobalVariableGet(tmp_str0012F) != 0) { 
   tmp_str00132 = IntegerToString(MagicInp, 0, 32);
   tmp_str00132 = tmp_str00132 + "_newGrids";
   GlobalVariableSet(tmp_str00132, 0);
   ObjectSetInteger(0, sparam, 1025, 255);
   ObjectSetInteger(0, sparam, 1035, 255);
   ObjectSetString(0, sparam, 999, "New grids NOT allowed!");
   } 
   else { 
   tmp_str00135 = IntegerToString(MagicInp, 0, 32);
   tmp_str00135 = tmp_str00135 + "_newGrids";
   GlobalVariableSet(tmp_str00135, 1);
   ObjectSetInteger(0, sparam, 1025, 3329330);
   ObjectSetInteger(0, sparam, 1035, 3329330);
   ObjectSetString(0, sparam, 999, "New grids allowed");
   } 
   ObjectSetInteger(0, sparam, 1018, 0);
   
}

double func_1037(string Fa_s_00, string Fa_s_01, double Fa_d_02, double Fa_d_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string Ls_FFFE8;
   string Ls_FFFD8;
   string Ls_FFFC8;
   string Ls_FFFB8;
   string Ls_FFFA8;
   string Ls_FFF98;
   string Ls_FFF88;
   string Ls_FFF78;
   string Ls_FFF68;
   string Ls_FFF58;
   double Ld_FFF50;
   double Ld_FFF48;
   double Ld_FFF40;
   double Ld_FFF38;
   double Ld_FFF30;
   double Ld_FFFF8;

   Ld_FFF50 = 0;
   Ld_FFF48 = 0;
   Ld_FFF40 = 0;
   Ld_FFF38 = 0;
   Ld_FFF30 = 0;
   if ((Fa_d_03 > 0)) { 
   Id_1CD10 = Fa_d_03;
   Ls_FFFE8 = Fa_s_01;
   if (Input_Struct_0001CEB0.m_16) { 
   Id_1CD18 = Fa_d_03;
   } 
   else { 
   if ((Id_1CD10 <= 0)) { 
   Id_1CD18 = Id_1CD10;
   } 
   else { 
   Id_1CDE0 = SymbolInfoDouble(Ls_FFFE8, 34);
   Id_1CDE8 = SymbolInfoDouble(Ls_FFFE8, 35);
   returned_double = SymbolInfoDouble(Ls_FFFE8, 36);
   Id_1CEA8 = returned_double;
   Id_1CDF0 = returned_double;
   if (Id_1CDE0 == 0 || Id_1CDE8 == 0 || returned_double == 0) { 
   
   Id_1CD18 = 0;
   } 
   else { 

   Ii_1CC8C = 0;
   Id_1CDF8 = Id_1CDE0;
   if ((Id_1CDE0 >= Id_1CDF0)) { 
   Id_1CE00 = 0;
   } 
   else { 
   Id_1CE00 = Id_1CDF8;
   } 
   Id_1CDF8 = Id_1CE00;
   if ((Id_1CE00 < 1)) { 
   do { 
   Ii_1CC8C = Ii_1CC8C + 1;
   Id_1CE00 = Id_1CDF8 * 10;
   Id_1CDF8 = Id_1CE00;
   } while (Id_1CE00 < 1); 
   } 
   Id_1CE00 = 0;
   if ((Id_1CD10 > Id_1CDE8)) { 
   Id_1CE00 = Id_1CDE8;
   } 
   else { 
   if ((Id_1CD10 < Id_1CDE0)) { 
   Id_1CE00 = Id_1CDE0;
   } 
   else { 
   Id_1CE08 = round((Id_1CD10 / Id_1CDF0));
   Id_1CE00 = 0;
   }} 
   Id_1CD18 = Id_1CE00;
   }}} 
   Ld_FFF50 = Id_1CD18;
   Ld_FFFF8 = Id_1CD18;
   return Ld_FFFF8;
   } 
   Ls_FFFD8 = Fa_s_00;
   tmp_str00002 = Ls_FFFD8;
   Ls_FFFC8 = tmp_str00002;
   Id_1CE08 = SymbolInfoDouble(Ls_FFFC8, SYMBOL_POINT);
   Id_1CD20 = SymbolInfoDouble(Ls_FFFC8, SYMBOL_TRADE_TICK_SIZE);
   Id_1CD28 = SymbolInfoDouble(Ls_FFFC8, SYMBOL_TRADE_TICK_VALUE);
   if ((Id_1CD20 == 0) || (Id_1CE08 == 0)) { 
   
   Id_1CD38 = 0;
   } 
   else { 
   Id_1CD38 = (Id_1CE08 / Id_1CD20) * Id_1CD28;
   } 
   Id_1CE38 = Id_1CD38;
   if ((Id_1CD38 == 0)) { 
   Id_1CD40 = 0;
   } 
   else { 
   Ls_FFFB8 = Ls_FFFD8;
   Id_1CD50 = SymbolInfoDouble(Ls_FFFB8, SYMBOL_BID);
   if ((Id_1CD50 == 0)) { 
   Id_1CD40 = 0;
   } 
   else { 
   Ls_FFFA8 = Ls_FFFD8;
   Id_1CEA0 = SymbolInfoDouble(Ls_FFFA8, SYMBOL_POINT);
   if ((Id_1CEA0 == 0)) { 
   Id_1CD40 = 0;
   } 
   else { 
   Id_1CD40 = (Id_1CD50 / Id_1CEA0) * Id_1CE38;;
   }}} 
   Ld_FFF48 = Id_1CD40;
   if ((Id_1CD40 == 0)) { 
   Ld_FFF50 = 0;
   Ld_FFFF8 = 0;
   return Ld_FFFF8;
   } 
   Ls_FFF98 = Fa_s_01;
   Ls_FFF88 = Ls_FFF98;
   Id_1CD58 = SymbolInfoDouble(Ls_FFF88, SYMBOL_POINT);
   Id_1CD60 = SymbolInfoDouble(Ls_FFF88, SYMBOL_TRADE_TICK_SIZE);
   Id_1CD68 = SymbolInfoDouble(Ls_FFF88, SYMBOL_TRADE_TICK_VALUE);
   if ((Id_1CD60 == 0) || (Id_1CD58 == 0)) { 
   
   Id_1CD78 = 0;
   } 
   else { 
   Id_1CD78 = Id_1CD58 / (Id_1CD60 / Id_1CD68);
   } 
   Id_1CE50 = Id_1CD78;
   if ((Id_1CD78 == 0)) { 
   Id_1CDA0 = 0;
   } 
   else { 
   tmp_str00008 = Ls_FFF98;
   Ls_FFF78 = tmp_str00008;
   Id_1CE90 = SymbolInfoDouble(Ls_FFF78, SYMBOL_BID);
   if ((Id_1CE90 == 0)) { 
   Id_1CDA0 = 0;
   } 
   else { 
   tmp_str0000A = Ls_FFF98;
   Ls_FFF68 = tmp_str0000A;
   Id_1CDB0 = SymbolInfoDouble(Ls_FFF68, SYMBOL_POINT);
   if ((Id_1CDB0 == 0)) { 
   Id_1CDA0 = 0;
   } 
   else { 
   Id_1CDA0 = Id_1CE90/ (Id_1CDB0 / Id_1CE50);
   }}} 
   Ld_FFF40 = Id_1CDA0;
   if ((Id_1CDA0 == 0)) { 
   Ld_FFF50 = 0;
   Ld_FFFF8 = 0;
   return Ld_FFFF8;
   } 
   Ld_FFF38 = Ld_FFF48 / Ld_FFF40;
   Ld_FFF30 = Fa_d_02 * Ld_FFF38;
   Id_1CDC0 = Ld_FFF30;
   Ls_FFF58 = Fa_s_01;

   if (Input_Struct_0001CEB0.m_16) { 
   Id_1CDC8 = Ld_FFF30;
   Ld_FFFF8 = Ld_FFF30;
   return Ld_FFFF8;
   } 
   if ((Id_1CDC0 <= 0)) { 
   Id_1CDC8 = Id_1CDC0;
   Ld_FFFF8 = Id_1CDC0;
   return Ld_FFFF8;
   } 
   Id_1CDD8 = SymbolInfoDouble(Ls_FFF58, 34);
   Id_1CE58 = SymbolInfoDouble(Ls_FFF58, 35);
   Id_1CEA8 = SymbolInfoDouble(Ls_FFF58, 36);

   Id_1CE60 = Id_1CEA8;
   if ((Id_1CE58 == 0) || (Id_1CEA8 == 0)) { 
   
   Id_1CDC8 = 0;
   Ld_FFFF8 = 0;
   return Ld_FFFF8;
   } 

   Ii_1CE6C = 0;
   Id_1CE70 = Id_1CDD8;
   if ((Id_1CDD8 >= Id_1CE60)) { 
   Id_1CE78 = Id_1CE60;
   } 
   else { 
   Id_1CE78 = Id_1CE70;
   } 
   Id_1CE70 = Id_1CE78;
   if ((Id_1CE78 < 1)) { 
   do { 
   Ii_1CE6C = Ii_1CE6C + 1;
   Id_1CE78 = Id_1CE70 * 10;
   Id_1CE70 = Id_1CE78;
   } while (Gd_00004 < 1); 
   } 

   Id_1CE78 = 0;
   if ((Id_1CDC0 > Id_1CE58)) { 
   Id_1CE78 = Id_1CE58;
   } 
   else { 
   if ((Id_1CDC0 < Id_1CDD8)) { 
   Id_1CE78 = Id_1CDD8;
   } 
   else { 
   Id_1CE88 = round((Id_1CDC0 / Id_1CE60));
   Id_1CE78 = Id_1CE60 * Id_1CE88;
   }} 
   Id_1CDC8 = Id_1CE78;
   Ld_FFF50 = Id_1CE78;
   Ld_FFFF8 = Ld_FFF50;
   
   return Ld_FFFF8;
}

bool func_1041(string Fa_s_00, string Fa_s_01, int Fa_i_02, string Fa_s_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   int Li_FFFF8;
   string Ls_FFFE8;
   bool Lb_FFFFF;

   Li_FFFF8 = OrdersTotal();
   if (Li_FFFF8 < 0) return false; 
   do { 
   if (OrderSelect(Li_FFFF8, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFE8 = OrderComment();
   if (Ib_09C81) { 
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   tmp_str00002 = OrderComment();
   tmp_str00003 = Is_09CA0;
   
   tmp_str00004 = "";
   Gi_00000 = (int)StringToInteger(tmp_str00004);
   Gi_00001 = 0;
   Gi_00000 = 0;
   Gi_00002 = HistoryTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 1)) { 
   Gl_00002 = OrderOpenTime();
   tmp_str00005 = IntegerToString(MagicInp, 0, 32);
   tmp_str00005 = tmp_str00005 + "_PMPtimeFlat";
   Gl_00004 = (int)(GlobalVariableGet(tmp_str00005) * 1000);
   if (Gl_00002 >= Gl_00004) { 
   Gi_00004 = StringFind(OrderComment(), "to #");
   if (Gi_00004 >= 0) { 
   tmp_str0000B = "";
   Gi_00004 = (int)StringToInteger(tmp_str0000B);
   if (Gi_00004 == Gi_00000) { 
   Gi_00000 = OrderTicket();
   Gi_00001 = Gi_00000;
   }}}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Gi_00004 = Gi_00001;
   Gi_00005 = ArraySize(Is_0B074) - 1;
   Gi_00006 = Gi_00005;
   tmp_str00011 = "";
   if (Gi_00005 >= 0) {
   do { 
   string Ls_FFFB4[];

   tmp_str0000D = Is_0B074[Gi_00006];

   Gst_00008 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000D, Gst_00008, Ls_FFFB4);
   if (ArraySize(Ls_FFFB4) >= 2) {
   tmp_str00011 = (string)Gi_00004;
   if (Ls_FFFB4[0] == tmp_str00011) {
   tmp_str00011 = Ls_FFFB4[1];
   ArrayFree(Ls_FFFB4);
   break;
   }}
   ArrayFree(Ls_FFFB4);
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   }
   
   Ls_FFFE8 = tmp_str00011;
   if (tmp_str00011 == "") { 
   tmp_str00012 = "";
   tmp_str00014 = "ERRORE determinazione ordine, sistema sospeso POM ";
   tmp_str00014 = tmp_str00014 + tmp_str00011;
   tmp_str00013 = Fa_s_01;
   tmp_str00015 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00015, tmp_str00013, tmp_str00014, tmp_str00012, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}} 
   if (Ib_09C81) { 
   tmp_str00016 = Ls_FFFE8;
   tmp_str00017 = Is_09CA0;
   
   if (tmp_str00016 == Fa_s_03) { 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }} 
   if (Ib_09C81 != true) { 
   tmp_str00017 = eaOverlay;
   tmp_str00018 = TerminalCompany();
   
   if (Fa_s_03 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }} 
   
   if (Fa_s_03 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 || OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}}}} 
   Li_FFFF8 = Li_FFFF8 - 1;
   } while (Li_FFFF8 >= 0); 
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

double func_1042(string Fa_s_00, string Fa_s_01, int Fa_i_02, string Fa_s_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   double Ld_FFFF0;
   int Li_FFFEC;
   string Ls_FFFE0;
   double Ld_FFFF8;
   bool Lb_FFFDF;


   Ld_FFFF0 = 0;
   Li_FFFEC = OrdersTotal();
   if (Li_FFFEC < 0) return Ld_FFFF0; 
   do { 
   if (OrderSelect(Li_FFFEC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFE0 = OrderComment();
   if (Ib_09C81) { 
   tmp_str00002 = OrderComment();
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   tmp_str00005 = "";
   Gi_00000 = (int)StringToInteger(tmp_str00005);
   Gi_00001 = 0;
   Gi_00000 = 0;
   Gi_00002 = HistoryTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 1)) { 
   Gl_00002 = OrderOpenTime();
   tmp_str00006 = IntegerToString(MagicInp, 0, 32);
   tmp_str00006 = tmp_str00006 + "_PMPtimeFlat";
   Gl_00004 = (int)(GlobalVariableGet(tmp_str00006) * 1000);
   if (Gl_00002 >= Gl_00004) { 
   Gi_00004 = StringFind(OrderComment(), "to #");;
   if (Gi_00004 >= 0) { 
   tmp_str0000C = "";
   Gi_00004 = (int)StringToInteger(tmp_str0000C);
   if (Gi_00004 == Gi_00000) { 
   Gi_00000 = OrderTicket();
   Gi_00001 = Gi_00000;
   }}}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Gi_00004 = Gi_00001;
   Gi_00005 = ArraySize(Is_0B074) - 1;
   Gi_00006 = Gi_00005;
   tmp_str00012 = "";
   if (Gi_00005 >= 0) {
   do { 
   string Ls_FFFA8[];
   tmp_str0000E = Is_0B074[Gi_00006];
   Gst_00008 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000E, Gst_00008, Ls_FFFA8);
   if (ArraySize(Ls_FFFA8) >= 2) {
   tmp_str00012 = (string)Gi_00004;
   if (Ls_FFFA8[0] == tmp_str00012) {
   tmp_str00012 = Ls_FFFA8[1];
   ArrayFree(Ls_FFFA8);
   break;
   }}
   ArrayFree(Ls_FFFA8);
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   }
   
   Ls_FFFE0 = tmp_str00012;
   if (tmp_str00012 == "") { 
   tmp_str00013 = "";
   tmp_str00015 = "ERRORE determinazione ordine, sistema sospeso PLS ";
   tmp_str00015 = tmp_str00015 + tmp_str00012;
   tmp_str00014 = Fa_s_01;
   tmp_str00016 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00016, tmp_str00014, tmp_str00015, tmp_str00013, 0);
   Ib_1CED0 = true;
   Ld_FFFF8 = 1;
   return Ld_FFFF8;
   }}} 
   Lb_FFFDF = false;
   if (Ib_09C81) { 
   Lb_FFFDF = (Ls_FFFE0 == Fa_s_03);
   } 
   else { 
   if (Fa_s_03 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFDF = true;
   }} 
   if (Fa_s_03 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFDF = true;
   }}} 
   if (Lb_FFFDF && OrderSelect(Li_FFFEC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Gd_0000B = OrderProfit();
   Gd_0000B = (Gd_0000B + OrderSwap());
   Ld_FFFF0 = ((Gd_0000B + OrderCommission()) + Ld_FFFF0);
   }}}} 
   Li_FFFEC = Li_FFFEC - 1;
   } while (Li_FFFEC >= 0); 
   
   Ld_FFFF8 = Ld_FFFF0;
   
   return Ld_FFFF8;
}

bool func_1043(string Fa_s_00, string Fa_s_01, int Fa_i_02, string Fa_s_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   int Li_FFFF8;
   string Ls_FFFE8;
   bool Lb_FFFFF;

   Li_FFFF8 = OrdersTotal();
   if (Li_FFFF8 < 0) return false; 
   do { 
   if (OrderSelect(Li_FFFF8, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   Gl_00000 = OrderOpenTime();
   tmp_str00000 = OrderSymbol();
   if (Gl_00000 >= iTime(tmp_str00000, 0, 0)) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFE8 = OrderComment();
   if (Ib_09C81) { 
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   Gi_00001 = (int)StringToInteger("");
   Gi_00002 = 0;
   Gi_00001 = 0;
   Gi_00003 = HistoryTotal() - 1;
   Gi_00004 = Gi_00003;
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00004, 0, 1)) { 
   Gl_00003 = OrderOpenTime();
   tmp_str00007 = IntegerToString(MagicInp, 0, 32);
   tmp_str00007 = tmp_str00007 + "_PMPtimeFlat";
   Gl_00005 = (int)(GlobalVariableGet(tmp_str00007) * 1000);
   if (Gl_00003 >= Gl_00005) { 
   Gi_00005 = StringFind(OrderComment(), "to #");
   if (Gi_00005 >= 0) { 
   Gi_00005 = (int)StringToInteger("");
   if (Gi_00005 == Gi_00001) { 
   Gi_00001 = OrderTicket();
   Gi_00002 = Gi_00001;
   }}}} 
   Gi_00004 = Gi_00004 - 1;
   } while (Gi_00004 >= 0); 
   } 
   Gi_00005 = Gi_00002;
   Gi_00006 = ArraySize(Is_0B074) - 1;
   Gi_00007 = Gi_00006;
   tmp_str00013 = "";
   if (Gi_00006 >= 0) {
   do { 
   string Ls_FFFB4[];
   tmp_str0000F = Is_0B074[Gi_00007];
   Gst_00009 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000F, Gst_00009, Ls_FFFB4);
   if (ArraySize(Ls_FFFB4) >= 2) {
   tmp_str00013 = (string)Gi_00005;
   if (Ls_FFFB4[0] == tmp_str00013) {
   tmp_str00013 = Ls_FFFB4[1];
   ArrayFree(Ls_FFFB4);
   break;
   }}
   ArrayFree(Ls_FFFB4);
   Gi_00007 = Gi_00007 - 1;
   } while (Gi_00007 >= 0); 
   }
   
   Ls_FFFE8 = tmp_str00013;
   if (tmp_str00013 == "") { 
   tmp_str00014 = "";
   tmp_str00016 = "ERRORE determinazione ordine, sistema sospeso POMB ";
   tmp_str00016 = tmp_str00016 + tmp_str00013;
   tmp_str00015 = Fa_s_01;
   tmp_str00017 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00017, tmp_str00015, tmp_str00016, tmp_str00014, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}} 
   if (Ib_09C81) { 
   if (Ls_FFFE8 == Fa_s_03) { 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }} 
   if (Ib_09C81 != true) { 
   if (Fa_s_03 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }} 
   if (Fa_s_03 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}}}}} 
   Li_FFFF8 = Li_FFFF8 - 1;
   } while (Li_FFFF8 >= 0); 
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

bool func_1045(string Fa_s_00, string Fa_s_01, int Fa_i_02, string Fa_s_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   int Li_FFFF8;
   bool Lb_FFFFF;
   long Ll_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   bool Lb_FFFCF;

   Li_FFFF8 = HistoryTotal() - 1;
   if (Li_FFFF8 < 0) return false; 
   do { 
   if (OrderSelect(Li_FFFF8, 0, 1)) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   if (OrderMagicNumber() == Ii_1D234) { 
   if (OrderCloseTime() < Il_09C98) { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   Gl_00000 = OrderCloseTime();
   tmp_str00000 = IntegerToString(MagicInp, 0, 32);
   tmp_str00000 = tmp_str00000 + "_PMPtimeFlat";
   Gl_00002 = (int)(GlobalVariableGet(tmp_str00000) * 1000);
   if (Gl_00000 <= Gl_00002) { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   Ll_FFFF0 = OrderCloseTime();
   Ls_FFFE0 = OrderComment();
   Ls_FFFD0 = OrderComment();
   if (Ib_09C81) { 
   Gi_00002 = StringFind(OrderComment(), "from");
   if (Gi_00002 >= 0) { 
   Gi_00002 = (int)StringToInteger("");
   Gi_00003 = 0;
   Gi_00002 = 0;
   Gi_00004 = HistoryTotal() - 1;
   Gi_00005 = Gi_00004;
   if (Gi_00004 >= 0) { 
   do { 
   if (OrderSelect(Gi_00005, 0, 1)) { 
   Gl_00004 = OrderOpenTime();
   tmp_str00007 = IntegerToString(MagicInp, 0, 32);
   tmp_str00007 = tmp_str00007 + "_PMPtimeFlat";
   Gl_00006 = (int)(GlobalVariableGet(tmp_str00007) * 1000);
   if (Gl_00004 >= Gl_00006) { 
   Gi_00006 = StringFind(OrderComment(), "to #");
   if (Gi_00006 >= 0) { 
   Gi_00006 = (int)StringToInteger("");
   if (Gi_00006 == Gi_00002) { 
   Gi_00002 = OrderTicket();
   Gi_00003 = Gi_00002;
   }}}} 
   Gi_00005 = Gi_00005 - 1;
   } while (Gi_00005 >= 0); 
   } 
   Gi_00006 = Gi_00003;
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Gi_00008 = Gi_00007;
   tmp_str00013 = "";
   if (Gi_00007 >= 0) {
   do { 
   string Ls_FFF98[];
   tmp_str0000F = Is_0B074[Gi_00008];
   Gst_0000A = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000F, Gst_0000A, Ls_FFF98);
   if (ArraySize(Ls_FFF98) >= 2) {
   tmp_str00013 = (string)Gi_00006;
   if (Ls_FFF98[0] == tmp_str00013) {
   tmp_str00013 = Ls_FFF98[1];
   ArrayFree(Ls_FFF98);
   break;
   }}
   ArrayFree(Ls_FFF98);
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   }
   
   Ls_FFFD0 = tmp_str00013;
   if (tmp_str00013 == "") { 
   tmp_str00014 = "";
   tmp_str00016 = "ERRORE determinazione ordine, sistema sospeso POC " + Ls_FFFE0;
   tmp_str00016 = tmp_str00016 + " ";
   tmp_str00016 = tmp_str00016 + TimeToString(Ll_FFFF0, 7);
   tmp_str00016 = tmp_str00016 + " " ;
   tmp_str00015 = IntegerToString(MagicInp, 0, 32);
   tmp_str00015 = tmp_str00015 + "_PMPtimeFlat";
   tmp_str00016 = tmp_str00016 + TimeToString((int)(GlobalVariableGet(tmp_str00015) * 1000), 7);
   tmp_str00017 = Fa_s_01;
   tmp_str00018 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00018, tmp_str00017, tmp_str00016, tmp_str00014, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}} 
   Lb_FFFCF = false;
   if (Ib_09C81) { 
   Lb_FFFCF = (Ls_FFFD0 == Fa_s_03);
   } 
   else { 
   if (OrderSelect(Li_FFFF8, 0, 1)) { 
   if (Fa_s_03 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFCF = true;
   }} 
   if (Fa_s_03 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFCF = true;
   }}}} 
   if (Lb_FFFCF && OrderSelect(Li_FFFF8, 0, 1)) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   if (OrderMagicNumber() == Fa_i_02) { 
   tmp_str0001B = OrderSymbol();
   if (iBarShift(tmp_str0001B, 0, OrderOpenTime(), true) == 0
   || iBarShift(OrderSymbol(), 0, OrderCloseTime(), true) == 0) {
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }}}}}}} 
   Li_FFFF8 = Li_FFFF8 - 1;
   } while (Li_FFFF8 >= 0); 
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

void func_1046(string Fa_s_00, string Fa_s_01, string Fa_s_02, int Fa_i_03, int Fa_i_04, double Fa_d_05, double Fa_d_06, string Fa_s_07, int Fa_i_08, double Fa_d_09, double Fa_d_0A)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   bool Lb_FFFFF;
   int Li_FFFF8;
   int Li_FFFF4;
   string Ls_FFFE8;
   int Li_FFFE4;
   int Li_FFFE0;

   Fa_d_05 = NormalizeDouble(Fa_d_05,2);
   Fa_d_06 = NormalizeDouble(Fa_d_06,(int)SymbolInfoInteger(Fa_s_00, SYMBOL_DIGITS));
   Lb_FFFFF = false;
   Li_FFFF8 = 0;
   Li_FFFF4 = 10;
   Ls_FFFE8 = "";
   if (Fa_i_04 == 0) { 
   Ls_FFFE8 = "Long";
   } 
   else { 
   if (Fa_i_04 == 1) { 
   Ls_FFFE8 = "Short";
   }} 
   if (Lb_FFFFF == false && Li_FFFF8 < Li_FFFF4) { 
   do { 
   RefreshRates();
   Li_FFFE4 = 0;
   Gi_00002 = Fa_i_08;
   if (commentoAggiuntivo != "") { 
   tmp_str00003 = "_" + commentoAggiuntivo;
   } 
   else { 
   tmp_str00003 = "";
   } 
   tmp_str00003 = Fa_s_07 + tmp_str00003;
   tmp_str00003 = tmp_str00003 + "_";
   tmp_str00003 = tmp_str00003 + IntegerToString(Fa_i_03, 0, 32);
   Li_FFFE4 = OrderSend(Fa_s_00, Fa_i_04, Fa_d_05, Fa_d_06, 20, Fa_d_09, Fa_d_0A, tmp_str00003, Fa_i_03, 0, Gi_00002);
   if (Li_FFFE4 < 0) { 
   Gi_00004 = GetLastError();
   Li_FFFE0 = Gi_00004;
   tmp_str00005 = "";
   tmp_str00008 = "inserimento ordine " + Ls_FFFE8;
   tmp_str00008 = tmp_str00008 + " ";
   tmp_str00008 = tmp_str00008 + Fa_s_07;
   tmp_str00009 = Fa_s_02;
   tmp_str0000A = Fa_s_01;
   func_1050(Fa_i_03, tmp_str0000A, tmp_str00009, tmp_str00008, tmp_str00005, Gi_00004);
   Li_FFFF8 = Li_FFFF8 + 1;
   } 
   else { 
   tmp_str0000B = "";
   tmp_str0000D = Ls_FFFE8 + " " ;
   tmp_str0000D = tmp_str0000D + Fa_s_07;
   tmp_str0000E = Fa_s_02;
   tmp_str0000F = Fa_s_01;
   func_1051(Fa_i_03, tmp_str0000F, tmp_str0000E, tmp_str0000D, tmp_str0000B);
   Lb_FFFFF = true;
   break; 
   } 
   Li_FFFF8 = Li_FFFF8 + 1;
   Sleep(300);
   if (Lb_FFFFF) break; 
   } while (Li_FFFF8 < Li_FFFF4); 
   } 
   if (Lb_FFFFF == false) return; 
   if (Ib_09C81 == false) return; 
   func_1069();
   
}

void func_1047()
{
   string tmp_str00000;
   string tmp_str00002;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00008;
   string tmp_str0000A;
   string tmp_str0000C;
   string tmp_str0000E;
   string tmp_str00010;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002E;
   string tmp_str00030;
   string tmp_str00032;
   string tmp_str00034;
   string tmp_str00036;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00043;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004C;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00058;
   string tmp_str0005A;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str0006A;
   string tmp_str0006E;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00074;
   string tmp_str00078;
   string tmp_str0007B;
   string tmp_str0007C;
   string tmp_str0007E;
   string tmp_str00080;
   string tmp_str00082;
   string tmp_str00083;
   string tmp_str00085;
   string tmp_str00087;
   string tmp_str0008A;
   string tmp_str0008B;
   string tmp_str0008D;
   string tmp_str0008E;
   string tmp_str00090;
   string tmp_str00091;
   string tmp_str00092;
   string tmp_str00096;
   string tmp_str00098;
   string tmp_str00099;
   string tmp_str0009C;
   string tmp_str0009E;
   string tmp_str0009F;
   string tmp_str000A1;
   string tmp_str000A3;
   string tmp_str000A4;
   string tmp_str000A5;
   string tmp_str000A7;
   string tmp_str000A8;
   string tmp_str000AA;
   string tmp_str000AC;
   string tmp_str000AE;
   string tmp_str000B0;
   string tmp_str000B2;
   string tmp_str000B4;
   string tmp_str000B5;
   string tmp_str000B7;
   string tmp_str000B8;
   string tmp_str000BB;
   string tmp_str000BC;
   string tmp_str000BD;
   string tmp_str000BE;
   string tmp_str000BF;
   string tmp_str000C1;
   string tmp_str000C4;
   string tmp_str000C7;

   int Li_FFFFC;
   double Ld_FF660;
   int Li_FF65C;
   double Ld_FF650;
   int Li_FF64C;
   double Ld_FF640;
   int Li_FF63C;
   string Ls_FF630;
   bool Lb_FF62F;
   int Li_FF628;
   int Li_FF624;
   string Ls_FF618;
   string Ls_FF608;
   int Li_FF604;
   bool Lb_FF5CF;
   int Li_FF5C8;
   string Ls_FF5B8;
   string Ls_FF5A8;
   int Li_FF5A4;
   double Ld_FF598;
   int Li_FF594;
   int Li_FF590;
   string Ls_FF5F8;
   double Ld_FF5F0;
   double Ld_FF5E8;
   double Ld_FF5E0;
   int Li_FF5DC;
   string Ls_FF5D0;

   tmp_str00000 = IntegerToString(MagicInp, 0, 32);

   tmp_str00002 = Is_09CA0 + "magic";
   ObjectCreate(0, tmp_str00002, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00002, tmp_str00000, 20, "Dubai", 8421504);
   ObjectSet(tmp_str00002, OBJPROP_CORNER, 1);
   Gi_00000 = (int)(moltiplicatoreGrafiche * 5);
   ObjectSet(tmp_str00002, OBJPROP_XDISTANCE, Gi_00000);
   Gd_00000 = (moltiplicatoreGrafiche * 30);
   Gi_00001 = (int)Gd_00000;
   ObjectSet(tmp_str00002, OBJPROP_YDISTANCE, Gi_00001);
   ObjectSetInteger(0, tmp_str00002, 1011, 5);
   ObjectSetInteger(0, tmp_str00002, 1000, 0);
   tmp_str00005 = Is_09CA0 + "mini";
   if (ObjectFind(tmp_str00005) < 0) { 
   tmp_str00006 = "Dubai";
   tmp_str00008 = "Manager";
   tmp_str0000A = Is_09CA0 + "visualizzazione";
   ObjectCreate(0, tmp_str0000A, OBJ_BUTTON, 0, 0, 0);
   Gi_00001 = (int)(moltiplicatoreGrafiche * 10);
   ObjectSetInteger(0, tmp_str0000A, 102, Gi_00001);
   ObjectSetInteger(0, tmp_str0000A, 101, 0);
   Gi_00001 = (int)(moltiplicatoreGrafiche * 20);
   ObjectSetInteger(0, tmp_str0000A, 103, Gi_00001);
   Gi_00001 = (int)(moltiplicatoreGrafiche * 150);
   ObjectSetInteger(0, tmp_str0000A, 1019, Gi_00001);
   Gi_00001 = (int)Gd_00000;
   ObjectSetInteger(0, tmp_str0000A, 1020, Gi_00001);
   ObjectSetString(0, tmp_str0000A, 999, tmp_str00008);
   ObjectSetString(0, tmp_str0000A, 1001, tmp_str00006);
   ObjectSetInteger(0, tmp_str0000A, 6, 255);
   ObjectSetInteger(0, tmp_str0000A, 1025, Ii_1CEC8);
   ObjectSetInteger(0, tmp_str0000A, 1035, Ii_1CEC8);
   ObjectSetInteger(0, tmp_str0000A, 1029, 1);
   ObjectSetInteger(0, tmp_str0000A, 208, 1);
   ObjectSetInteger(0, tmp_str0000A, 1018, 0);
   ObjectSetInteger(0, tmp_str0000A, 100, 12);
   ObjectSetInteger(0, tmp_str0000A, 9, 0);
   } 
   tmp_str0000C = Is_09CA0 + "buttons";
   if (ObjectFind(tmp_str0000C) < 0) { 
   tmp_str0000E = "Wingdings 2";
   tmp_str00010 = "Ê";
   tmp_str00012 = Is_09CA0 + "buttons";
   ObjectCreate(0, tmp_str00012, OBJ_BUTTON, 0, 0, 0);
   Gi_00002 = (int)(moltiplicatoreGrafiche * 35);
   ObjectSetInteger(0, tmp_str00012, 102, Gi_00002);
   ObjectSetInteger(0, tmp_str00012, 101, 1);
   Gi_00002 = (int)(moltiplicatoreGrafiche * 40);
   ObjectSetInteger(0, tmp_str00012, 103, Gi_00002);
   Gd_00002 = (moltiplicatoreGrafiche * 30);
   Gi_00003 = (int)Gd_00002;
   ObjectSetInteger(0, tmp_str00012, 1019, Gi_00003);
   Gi_00003 = (int)Gd_00002;
   ObjectSetInteger(0, tmp_str00012, 1020, Gi_00003);
   ObjectSetString(0, tmp_str00012, 999, tmp_str00010);
   ObjectSetString(0, tmp_str00012, 1001, tmp_str0000E);
   ObjectSetInteger(0, tmp_str00012, 6, 255);
   ObjectSetInteger(0, tmp_str00012, 1025, Ii_1CEC8);
   ObjectSetInteger(0, tmp_str00012, 1035, Ii_1CEC8);
   ObjectSetInteger(0, tmp_str00012, 1029, 1);
   ObjectSetInteger(0, tmp_str00012, 208, 1);
   ObjectSetInteger(0, tmp_str00012, 1018, 0);
   ObjectSetInteger(0, tmp_str00012, 100, 12);
   ObjectSetInteger(0, tmp_str00012, 9, 0);
   } 
   tmp_str00013 = "Dubai";
   Gi_00003 = 0;
   Gi_00004 = 20;
   Gi_00005 = Ii_1CEC8;
   Gi_00006 = Ii_1CEC8;
   Gi_00007 = 200;
   tmp_str00015 = Is_09CA0 + "buttons";
   tmp_str00016 = ObjectGetString(0, tmp_str00015, 999, 0);
   if (tmp_str00016 != "Ñ") { 
   Gi_00008 = 0;
   } 
   else { 
   Gi_00008 = 300;
   } 
   Gi_00008 = Ii_1CECC + Gi_00008;
   tmp_str00019 = Is_09CA0 + "background";
   ObjectCreate(0, tmp_str00019, OBJ_BUTTON, 0, 0, 0);
   Gi_00009 = (int)(moltiplicatoreGrafiche * 10);
   ObjectSetInteger(0, tmp_str00019, 102, Gi_00009);
   ObjectSetInteger(0, tmp_str00019, 101, Gi_00003);
   Gi_00009 = (int)(moltiplicatoreGrafiche * 45);
   ObjectSetInteger(0, tmp_str00019, 103, Gi_00009);
   Gi_00009 = (int)(Gi_00008 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00019, 1019, Gi_00009);
   Gi_00009 = (int)(Gi_00007 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00019, 1020, Gi_00009);
   ObjectSetString(0, tmp_str00019, 999, tmp_str00018);
   ObjectSetString(0, tmp_str00019, 1001, tmp_str00013);
   ObjectSetInteger(0, tmp_str00019, 6, Gi_00005);
   ObjectSetInteger(0, tmp_str00019, 1025, Gi_00006);
   ObjectSetInteger(0, tmp_str00019, 1035, Gi_00006);
   ObjectSetInteger(0, tmp_str00019, 1029, 1);
   ObjectSetInteger(0, tmp_str00019, 208, 1);
   ObjectSetInteger(0, tmp_str00019, 1018, 0);
   ObjectSetInteger(0, tmp_str00019, 100, Gi_00004);
   ObjectSetInteger(0, tmp_str00019, 9, 0);
   Gi_00009 = 65;
   Li_FFFFC = Gi_00009;
   double Ld_FF69C[300];
   ArrayInitialize(Ld_FF69C, 0);

   Ld_FF660 = 0;
   Li_FF65C = 0;
   Ld_FF650 = 0;
   Li_FF64C = 0;
   Ld_FF640 = 0;
   Li_FF63C = ObjectsTotal(-1) - 1;
   if (Li_FF63C >= 0) { 
   do { 
   Ls_FF630 = ObjectName(0, Li_FF63C, -1, -1);
   tmp_str0001E = Is_09CA0 + "mini";
   if (Ls_FF630 != tmp_str0001E) { 
   tmp_str0001E = Is_09CA0 + "buttons";
   if (Ls_FF630 != tmp_str0001E) { 
   tmp_str0001E = Is_09CA0 + "background";
   if (Ls_FF630 != tmp_str0001E) { 
   tmp_str0001F = Is_09CA0 + "visualizzazione";
   if (Ls_FF630 != tmp_str0001F) { 
   tmp_str0001F = Is_09CA0 + "TAB";
   tmp_str00020 = Ls_FF630;
   Gi_0000C = StringFind(tmp_str00020, tmp_str0001F);
   if (Gi_0000C < 0) { 
   Lb_FF62F = false;
   Li_FF628 = 0;
   if (Li_FF628 < ArraySize(Input_Struct_00009D18)) { 
   do { 
   tmp_str00020 = TerminalCompany();
   tmp_str00021 = listaSpreadDaNonTradare2;
   tmp_str00022 = eaSLTP;
   
   tmp_str00022 = Input_Struct_00009D18[Li_FF628].m_16 + "/";
   tmp_str00022 = tmp_str00022 + Input_Struct_00009D18[Li_FF628].m_28;
   tmp_str00023 = Ls_FF630;
   Gi_0000E = StringFind(tmp_str00023, tmp_str00022);
   if (Gi_0000E >= 0) { 
   Lb_FF62F = true;
   break; 
   } 
   Li_FF628 = Li_FF628 + 1;
   } while (Li_FF628 < ArraySize(Input_Struct_00009D18)); 
   } 
   if (Lb_FF62F != true) { 
   ObjectDelete(0, Ls_FF630);
   }}}}}} 
   Li_FF63C = Li_FF63C - 1;
   } while (Li_FF63C >= 0); 
   } 
   Li_FF624 = 0;
   if (Li_FF624 < ArraySize(Input_Struct_00009D18)) { 
   do { 
   Ls_FF618 = Input_Struct_00009D18[Li_FF624].m_16;
   Ls_FF608 = Input_Struct_00009D18[Li_FF624].m_28;
   Li_FF604 = Input_Struct_00009D18[Li_FF624].m_64;
   if (Ls_FF618 == "" || Ls_FF608 == "") { 
   
   } 
   else { 
   Ls_FF5F8 = "Flat";
   Ld_FF5F0 = 0;
   Ld_FF5E8 = 0;
   Ld_FF5E0 = 0;
   tmp_str00027 = Ls_FF608;
   tmp_str00028 = Ls_FF618;
   func_1048(tmp_str00028, tmp_str00027, Li_FF604, Ls_FF5F8, Ld_FF5F0, Ld_FF5E8, Ld_FF5E0);
   Ld_FF69C[Li_FF624] = Ld_FF5F0;
   if ((Ld_FF5F0 < Ld_FF650)) { 
   Ld_FF650 = Ld_FF5F0;
   Li_FF64C = Li_FF624;
   } 
   if ((Ld_FF5F0 > Ld_FF660)) { 
   Ld_FF660 = Ld_FF5F0;
   Li_FF65C = Li_FF624;
   } 
   tmp_str0002A = "Dubai";
   Gi_00012 = 0;
   Gi_00013 = 10;
   Gi_00014 = Ii_1CEC4;
   Gi_00015 = Ii_1CEC4;
   Gi_00016 = 25;
   Gi_00017 = Ii_1CECC - 20;
   tmp_str0002B = Is_09CA0 + "buttons";
   tmp_str0002C = ObjectGetString(0, tmp_str0002B, 999, 0);
   if (tmp_str0002C != "Ñ") { 
   Gi_00018 = 0;
   } 
   else { 
   Gi_00018 = 305;
   } 
   Gi_00018 = Gi_00017 + Gi_00018;
   Gi_00019 = Li_FFFFC - 10;
   tmp_str0002E = "";
   tmp_str00030 = Is_09CA0 + "_MNback_";
   tmp_str00030 = tmp_str00030 + Ls_FF618;
   tmp_str00030 = tmp_str00030 + "/";
   tmp_str00030 = tmp_str00030 + Ls_FF608;
   tmp_str00032 = tmp_str00030;
   ObjectCreate(0, tmp_str00032, OBJ_BUTTON, 0, 0, 0);
   Gi_0001A = (int)(moltiplicatoreGrafiche * 20);
   ObjectSetInteger(0, tmp_str00032, 102, Gi_0001A);
   ObjectSetInteger(0, tmp_str00032, 101, Gi_00012);
   Gi_0001A = (int)(Gi_00019 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00032, 103, Gi_0001A);
   Gi_0001A = (int)(Gi_00018 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00032, 1019, Gi_0001A);
   Gi_0001A = (int)(Gi_00016 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00032, 1020, Gi_0001A);
   ObjectSetString(0, tmp_str00032, 999, tmp_str0002E);
   ObjectSetString(0, tmp_str00032, 1001, tmp_str0002A);
   ObjectSetInteger(0, tmp_str00032, 6, Gi_00014);
   ObjectSetInteger(0, tmp_str00032, 1025, Gi_00015);
   ObjectSetInteger(0, tmp_str00032, 1035, Gi_00015);
   ObjectSetInteger(0, tmp_str00032, 1029, 1);
   ObjectSetInteger(0, tmp_str00032, 208, 1);
   ObjectSetInteger(0, tmp_str00032, 1018, 0);
   ObjectSetInteger(0, tmp_str00032, 100, Gi_00013);
   ObjectSetInteger(0, tmp_str00032, 9, 0);
   Gi_0001A = Li_FFFFC + 2;
   tmp_str00034 = Ls_FF618 + "/";
   tmp_str00034 = tmp_str00034 + Ls_FF608;
   tmp_str00036 = Is_09CA0 + "_MNnome_";
   tmp_str00036 = tmp_str00036 + Ls_FF618;
   tmp_str00036 = tmp_str00036 + "/";
   tmp_str00036 = tmp_str00036 + Ls_FF608;
   tmp_str00038 = tmp_str00036;
   ObjectCreate(0, tmp_str00038, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00038, tmp_str00034, grandezzaFont, "Dubai", 16777215);
   ObjectSet(tmp_str00038, OBJPROP_CORNER, 0);
   Gi_0001C = (int)(moltiplicatoreGrafiche * 30);
   ObjectSet(tmp_str00038, OBJPROP_XDISTANCE, Gi_0001C);
   Gi_0001C = (int)(Gi_0001A * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00038, OBJPROP_YDISTANCE, Gi_0001C);
   ObjectSetInteger(0, tmp_str00038, 1011, 1);
   ObjectSetInteger(0, tmp_str00038, 1000, 0);
   if ((Input_Struct_00009D18[Li_FF624].m_76 < Input_Struct_00009D18[Li_FF624].m_68)) { 
   Gi_0001E = 255;
   } 
   else { 
   Gi_0001E = 3329330;
   } 
   Li_FF5DC = Gi_0001E;
   Gi_0001F = Li_FFFFC + 2;
   tmp_str00039 = DoubleToString(Input_Struct_00009D18[Li_FF624].m_40, 0);
   tmp_str00039 = tmp_str00039 + "%";
   tmp_str00039 = tmp_str00039 + " | ";
   tmp_str00039 = tmp_str00039 + DoubleToString(Input_Struct_00009D18[Li_FF624].m_56, 0);
   tmp_str0003D = tmp_str00039;
   tmp_str0003E = Is_09CA0 + "_MNvalori_";
   tmp_str0003E = tmp_str0003E + Ls_FF618;
   tmp_str0003E = tmp_str0003E + "/";
   tmp_str0003E = tmp_str0003E + Ls_FF608;
   tmp_str0003F = tmp_str0003E;
   ObjectCreate(0, tmp_str0003F, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str0003F, tmp_str0003D, grandezzaFont, "Dubai", Gi_0001E);
   ObjectSet(tmp_str0003F, OBJPROP_CORNER, 0);
   Gi_00023 = (int)(moltiplicatoreGrafiche * 150);
   ObjectSet(tmp_str0003F, OBJPROP_XDISTANCE, Gi_00023);
   Gi_00023 = (int)(Gi_0001F * moltiplicatoreGrafiche);
   ObjectSet(tmp_str0003F, OBJPROP_YDISTANCE, Gi_00023);
   ObjectSetInteger(0, tmp_str0003F, 1011, 1);
   ObjectSetInteger(0, tmp_str0003F, 1000, 0);
   Gi_00023 = 0;
   Gi_00024 = 1;
   if (Ls_FF5F8 == "Long Spread") { 
   Gi_00026 = 3329330;
   } 
   else { 
   if (Ls_FF5F8 == "Short Spread") { 
   Gi_00027 = 255;
   } 
   else { 
   Gi_00027 = 13882323;
   } 
   Gi_00026 = Gi_00027;
   } 
   Gi_00027 = Gi_00026;
   Gi_00028 = Li_FFFFC + 2;
   if (Ls_FF5F8 == "Long Spread") { 
   Gi_0002A = 220;
   } 
   else { 
   if (Ls_FF5F8 == "Short Spread") { 
   Gi_0002B = 220;
   } 
   else { 
   Gi_0002B = 240;
   } 
   Gi_0002A = Gi_0002B;
   } 
   tmp_str00043 = Ls_FF5F8;
   tmp_str00045 = Is_09CA0 + "_MNtipoSpread_";
   tmp_str00045 = tmp_str00045 + Ls_FF618;
   tmp_str00045 = tmp_str00045 + "/";
   tmp_str00045 = tmp_str00045 + Ls_FF608;
   tmp_str00046 = tmp_str00045;
   ObjectCreate(0, tmp_str00046, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00046, tmp_str00043, grandezzaFont, "Dubai", Gi_00027);
   ObjectSet(tmp_str00046, OBJPROP_CORNER, Gi_00023);
   Gi_0002B = (int)(Gi_0002A * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00046, OBJPROP_XDISTANCE, Gi_0002B);
   Gi_0002B = (int)(Gi_00028 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00046, OBJPROP_YDISTANCE, Gi_0002B);
   ObjectSetInteger(0, tmp_str00046, 1011, Gi_00024);
   ObjectSetInteger(0, tmp_str00046, 1000, 0);
   Gi_0002B = Li_FFFFC + 2;
   tmp_str00047 = "" + DoubleToString(Ld_FF5E8, 2);
   tmp_str00047 = tmp_str00047 + "/";
   tmp_str00047 = tmp_str00047 + DoubleToString(Ld_FF5E0, 2);
   tmp_str00049 = tmp_str00047;
   tmp_str0004A = Is_09CA0 + "_MNexp_";
   tmp_str0004A = tmp_str0004A + Ls_FF618;
   tmp_str0004A = tmp_str0004A + "/";
   tmp_str0004A = tmp_str0004A + Ls_FF608;
   tmp_str0004C = tmp_str0004A;
   ObjectCreate(0, tmp_str0004C, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str0004C, tmp_str00049, grandezzaFont, "Dubai", 16777215);
   ObjectSet(tmp_str0004C, OBJPROP_CORNER, 0);
   Gi_0002E = (int)(moltiplicatoreGrafiche * 300);
   ObjectSet(tmp_str0004C, OBJPROP_XDISTANCE, Gi_0002E);
   Gi_0002E = (int)(Gi_0002B * moltiplicatoreGrafiche);
   ObjectSet(tmp_str0004C, OBJPROP_YDISTANCE, Gi_0002E);
   ObjectSetInteger(0, tmp_str0004C, 1011, 1);
   ObjectSetInteger(0, tmp_str0004C, 1000, 0);
   Gi_0002E = 0;
   Gi_0002F = 1;
   if ((Ld_FF5F0 > 0)) { 
   Gi_00031 = 3329330;
   } 
   else { 
   if ((Ld_FF5F0 < 0)) { 
   Gi_00032 = 255;
   } 
   else { 
   Gi_00032 = 13882323;
   } 
   Gi_00031 = Gi_00032;
   } 
   Gi_00032 = Li_FFFFC + 2;
   tmp_str00050 = "P/L : " + DoubleToString(Ld_FF5F0, 2);
   tmp_str00051 = Is_09CA0 + "_MNpl_";
   tmp_str00051 = tmp_str00051 + Ls_FF618;
   tmp_str00051 = tmp_str00051 + "/";
   tmp_str00051 = tmp_str00051 + Ls_FF608;
   tmp_str00051 = tmp_str00051 + "_";
   tmp_str00051 = tmp_str00051 + IntegerToString(Li_FF604, 0, 32);
   tmp_str00054 = tmp_str00051;
   ObjectCreate(0, tmp_str00054, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00054, tmp_str00050, grandezzaFont, "Dubai", Gi_00031);
   ObjectSet(tmp_str00054, OBJPROP_CORNER, Gi_0002E);
   Gi_00034 = (int)(moltiplicatoreGrafiche * 400);
   ObjectSet(tmp_str00054, OBJPROP_XDISTANCE, Gi_00034);
   Gi_00034 = (int)(Gi_00032 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00054, OBJPROP_YDISTANCE, Gi_00034);
   ObjectSetInteger(0, tmp_str00054, 1011, Gi_0002F);
   ObjectSetInteger(0, tmp_str00054, 1000, 0);
   tmp_str00055 = "Dubai";
   Gi_00034 = grandezzaFont - 1;
   Gi_00035 = Li_FFFFC - 8;
   tmp_str00058 = "+";
   tmp_str0005A = Is_09CA0 + "_MNapriChart_";
   tmp_str0005A = tmp_str0005A + Ls_FF618;
   tmp_str0005A = tmp_str0005A + "/";
   tmp_str0005A = tmp_str0005A + Ls_FF608;
   tmp_str0005A = tmp_str0005A + "_";
   tmp_str0005A = tmp_str0005A + IntegerToString(Li_FF604, 0, 32);
   tmp_str0005C = tmp_str0005A;
   ObjectCreate(0, tmp_str0005C, OBJ_BUTTON, 0, 0, 0);
   Gi_00036 = (int)(moltiplicatoreGrafiche * 10);
   ObjectSetInteger(0, tmp_str0005C, 102, Gi_00036);
   ObjectSetInteger(0, tmp_str0005C, 101, 0);
   Gi_00036 = (int)(Gi_00035 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0005C, 103, Gi_00036);
   Gi_00036 = (int)(moltiplicatoreGrafiche * 18);
   ObjectSetInteger(0, tmp_str0005C, 1019, Gi_00036);
   Gi_00036 = (int)(moltiplicatoreGrafiche * 20);
   ObjectSetInteger(0, tmp_str0005C, 1020, Gi_00036);
   ObjectSetString(0, tmp_str0005C, 999, tmp_str00058);
   ObjectSetString(0, tmp_str0005C, 1001, tmp_str00055);
   ObjectSetInteger(0, tmp_str0005C, 6, 16777215);
   ObjectSetInteger(0, tmp_str0005C, 1025, 3289650);
   ObjectSetInteger(0, tmp_str0005C, 1035, 3289650);
   ObjectSetInteger(0, tmp_str0005C, 1029, 1);
   ObjectSetInteger(0, tmp_str0005C, 208, 1);
   ObjectSetInteger(0, tmp_str0005C, 1018, 0);
   ObjectSetInteger(0, tmp_str0005C, 100, Gi_00034);
   ObjectSetInteger(0, tmp_str0005C, 9, 0);
   tmp_str0005D = "Dubai";
   Gi_00036 = 0;
   if ((Ld_FF5F0 > 0)) { 
   Gi_00037 = 16777215;
   } 
   else { 
   if ((Ld_FF5F0 < 0)) { 
   Gi_00038 = 16777215;
   } 
   else { 
   Gi_00038 = 0;
   } 
   Gi_00037 = Gi_00038;
   } 
   Gi_00038 = Gi_00037;
   if ((Ld_FF5F0 > 0)) { 
   Gi_00039 = 3329330;
   } 
   else { 
   if ((Ld_FF5F0 < 0)) { 
   Gi_0003A = 255;
   } 
   else { 
   Gi_0003A = 11119017;
   } 
   Gi_00039 = Gi_0003A;
   } 
   Gi_0003A = Li_FFFFC - 8;
   tmp_str0005E = "Close Spread";
   tmp_str0005F = Is_09CA0 + "_MNchiudiTutto_";
   tmp_str0005F = tmp_str0005F + Ls_FF618;
   tmp_str0005F = tmp_str0005F + "/";
   tmp_str0005F = tmp_str0005F + Ls_FF608;
   tmp_str0005F = tmp_str0005F + "_";
   tmp_str0005F = tmp_str0005F + IntegerToString(Li_FF604, 0, 32);
   tmp_str00060 = tmp_str0005F;
   ObjectCreate(0, tmp_str00060, OBJ_BUTTON, 0, 0, 0);
   Gi_0003C = (int)(moltiplicatoreGrafiche * 490);
   ObjectSetInteger(0, tmp_str00060, 102, Gi_0003C);
   ObjectSetInteger(0, tmp_str00060, 101, Gi_00036);
   Gi_0003C = (int)(Gi_0003A * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00060, 103, Gi_0003C);
   Gi_0003C = (int)(moltiplicatoreGrafiche * 100);
   ObjectSetInteger(0, tmp_str00060, 1019, Gi_0003C);
   Gi_0003C = (int)(moltiplicatoreGrafiche * 20);
   ObjectSetInteger(0, tmp_str00060, 1020, Gi_0003C);
   ObjectSetString(0, tmp_str00060, 999, tmp_str0005E);
   ObjectSetString(0, tmp_str00060, 1001, tmp_str0005D);
   ObjectSetInteger(0, tmp_str00060, 6, Gi_00038);
   ObjectSetInteger(0, tmp_str00060, 1025, Gi_00039);
   ObjectSetInteger(0, tmp_str00060, 1035, Gi_00039);
   ObjectSetInteger(0, tmp_str00060, 1029, 1);
   ObjectSetInteger(0, tmp_str00060, 208, 1);
   ObjectSetInteger(0, tmp_str00060, 1018, 0);
   ObjectSetInteger(0, tmp_str00060, 100, Gi_00034);
   ObjectSetInteger(0, tmp_str00060, 9, 0);

   tmp_str00062 = Is_09CA0 + "buttons";
   tmp_str00063 = ObjectGetString(0, tmp_str00062, 999, 0);
   if (tmp_str00063 == "Ñ") { 
   Gi_0003C = Li_FFFFC + 2;
   tmp_str00065 = "Size:";
   tmp_str00066 = Is_09CA0 + "_MNsize_";
   tmp_str00066 = tmp_str00066 + Ls_FF618;
   tmp_str00066 = tmp_str00066 + "/";
   tmp_str00066 = tmp_str00066 + Ls_FF608;
   tmp_str00066 = tmp_str00066 + "_";
   tmp_str00066 = tmp_str00066 + IntegerToString(Li_FF604, 0, 32);
   tmp_str00067 = tmp_str00066;
   ObjectCreate(0, tmp_str00067, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00067, tmp_str00065, grandezzaFont, "Dubai", 16777215);
   ObjectSet(tmp_str00067, OBJPROP_CORNER, 0);
   Gi_0003D = (int)(moltiplicatoreGrafiche * 605);
   ObjectSet(tmp_str00067, OBJPROP_XDISTANCE, Gi_0003D);
   Gi_0003D = (int)(Gi_0003C * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00067, OBJPROP_YDISTANCE, Gi_0003D);
   ObjectSetInteger(0, tmp_str00067, 1011, 1);
   ObjectSetInteger(0, tmp_str00067, 1000, 0);
   tmp_str0006A = Is_09CA0 + "_MNeditLots_";
   tmp_str0006A = tmp_str0006A + Ls_FF618;
   tmp_str0006A = tmp_str0006A + "/";
   tmp_str0006A = tmp_str0006A + Ls_FF608;
   tmp_str0006A = tmp_str0006A + "_";
   tmp_str0006A = tmp_str0006A + IntegerToString(Li_FF604, 0, 32);
   Ls_FF5D0 = ObjectGetString(0, tmp_str0006A, 999, 0);
   Gi_0003E = 10;
   Gi_0003F = 20;
   Gi_00040 = 50;
   Gb_00041 = (Ls_FF5D0 != "0.0");
   if (Gb_00041) { 
   Gb_00041 = (Ls_FF5D0 != NULL);
   } 
   if (Gb_00041) { 
   tmp_str0006E = Ls_FF5D0;
   } 
   else { 
   tmp_str0006E = "0.0";
   } 
   tmp_str00070 = tmp_str0006E;
   Gi_00041 = Li_FFFFC - 8;
   tmp_str00071 = Is_09CA0 + "_MNeditLots_";
   tmp_str00071 = tmp_str00071 + Ls_FF618;
   tmp_str00071 = tmp_str00071 + "/";
   tmp_str00071 = tmp_str00071 + Ls_FF608;
   tmp_str00071 = tmp_str00071 + "_";
   tmp_str00071 = tmp_str00071 + IntegerToString(Li_FF604, 0, 32);
   tmp_str00074 = tmp_str00071;
   ObjectCreate(0, tmp_str00074, OBJ_EDIT, 0, 0, 0);
   Gi_00042 = (int)(moltiplicatoreGrafiche * 632);
   ObjectSetInteger(0, tmp_str00074, 102, Gi_00042);
   Gi_00042 = (int)(Gi_00041 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00074, 103, Gi_00042);
   Gi_00042 = (int)(Gi_00040 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00074, 1019, Gi_00042);
   Gi_00042 = (int)(Gi_0003F * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00074, 1020, Gi_00042);
   ObjectSetString(0, tmp_str00074, 999, tmp_str00070);
   ObjectSetString(0, tmp_str00074, 1001, "Dubai");
   ObjectSetInteger(0, tmp_str00074, 100, Gi_0003E);
   ObjectSetInteger(0, tmp_str00074, 6, 0);
   ObjectSetInteger(0, tmp_str00074, 1025, 16777215);
   ObjectSetInteger(0, tmp_str00074, 1035, 12632256);
   ObjectSetInteger(0, tmp_str00074, 1029, 0);
   ObjectSetInteger(0, tmp_str00074, 1036, 2);

   tmp_str00078 = Is_09CA0 + "_MNstrumenti_";
   tmp_str00078 = tmp_str00078 + Ls_FF618;

   tmp_str00078 = tmp_str00078 + "/";
   tmp_str00078 = tmp_str00078 + Ls_FF608;

   tmp_str00078 = tmp_str00078 + "_";
   tmp_str00078 = tmp_str00078 + IntegerToString(Li_FF604, 0, 32);
   Ls_FF5D0 = ObjectGetString(0, tmp_str00078, 999, 0);
   tmp_str0007B = "Dubai";
   Gi_00044 = 0;
   Gi_00045 = grandezzaFont - 1;
   Gi_00046 = 16777215;
   Gi_00047 = 5263440;
   Gi_00048 = 20;
   Gi_00049 = 100;
   Gi_0004A = 690;

   Gb_0004B = (Ls_FF5D0 != "All Spread");
   if (Gb_0004B) { 
   Gb_0004B = (Ls_FF5D0 != NULL);
   } 
   if (Gb_0004B) { 
   tmp_str0007C = Ls_FF5D0;
   } 
   else { 
   tmp_str0007C = "All Spread";
   } 
   tmp_str0007E = tmp_str0007C;
   tmp_str00080 = Is_09CA0 + "_MNstrumenti_";
   tmp_str00080 = tmp_str00080 + Ls_FF618;
   tmp_str00080 = tmp_str00080 + "/";
   tmp_str00080 = tmp_str00080 + Ls_FF608;
   tmp_str00080 = tmp_str00080 + "_";
   tmp_str00080 = tmp_str00080 + IntegerToString(Li_FF604, 0, 32);
   tmp_str00082 = tmp_str00080;
   ObjectCreate(0, tmp_str00082, OBJ_BUTTON, 0, 0, 0);
   Gi_0004B = (int)(Gi_0004A * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00082, 102, Gi_0004B);
   ObjectSetInteger(0, tmp_str00082, 101, Gi_00044);
   Gi_0004B = (int)(Gi_00041 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00082, 103, Gi_0004B);
   Gi_0004B = (int)(Gi_00049 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00082, 1019, Gi_0004B);
   Gi_0004B = (int)(Gi_00048 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00082, 1020, Gi_0004B);
   ObjectSetString(0, tmp_str00082, 999, tmp_str0007E);
   ObjectSetString(0, tmp_str00082, 1001, tmp_str0007B);
   ObjectSetInteger(0, tmp_str00082, 6, Gi_00046);
   ObjectSetInteger(0, tmp_str00082, 1025, Gi_00047);
   ObjectSetInteger(0, tmp_str00082, 1035, Gi_00047);
   ObjectSetInteger(0, tmp_str00082, 1029, 1);
   ObjectSetInteger(0, tmp_str00082, 208, 1);
   ObjectSetInteger(0, tmp_str00082, 1018, 0);
   ObjectSetInteger(0, tmp_str00082, 100, Gi_00045);
   ObjectSetInteger(0, tmp_str00082, 9, 0);
   tmp_str00083 = "Dubai";
   Gi_0004B = grandezzaFont - 1;
   Gi_0004C = Li_FFFFC - 8;
   tmp_str00085 = "Long Spread";
   tmp_str00087 = Is_09CA0 + "_MNLongSpread_";
   tmp_str00087 = tmp_str00087 + Ls_FF618;
   tmp_str00087 = tmp_str00087 + "/";
   tmp_str00087 = tmp_str00087 + Ls_FF608;
   tmp_str00087 = tmp_str00087 + "_";
   tmp_str00087 = tmp_str00087 + IntegerToString(Li_FF604, 0, 32);
   tmp_str0008A = tmp_str00087;
   ObjectCreate(0, tmp_str0008A, OBJ_BUTTON, 0, 0, 0);
   Gi_0004D = (int)(moltiplicatoreGrafiche * 800);
   ObjectSetInteger(0, tmp_str0008A, 102, Gi_0004D);
   ObjectSetInteger(0, tmp_str0008A, 101, 0);
   Gi_0004D = (int)(Gi_0004C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0008A, 103, Gi_0004D);
   Gd_0004D = (moltiplicatoreGrafiche * 100);
   Gi_0004E = (int)Gd_0004D;
   ObjectSetInteger(0, tmp_str0008A, 1019, Gi_0004E);
   Gd_0004E = (moltiplicatoreGrafiche * 20);
   Gi_0004F = (int)Gd_0004E;
   ObjectSetInteger(0, tmp_str0008A, 1020, Gi_0004F);
   ObjectSetString(0, tmp_str0008A, 999, tmp_str00085);
   ObjectSetString(0, tmp_str0008A, 1001, tmp_str00083);
   ObjectSetInteger(0, tmp_str0008A, 6, 16777215);
   ObjectSetInteger(0, tmp_str0008A, 1025, 3329330);
   ObjectSetInteger(0, tmp_str0008A, 1035, 3329330);
   ObjectSetInteger(0, tmp_str0008A, 1029, 1);
   ObjectSetInteger(0, tmp_str0008A, 208, 1);
   ObjectSetInteger(0, tmp_str0008A, 1018, 0);
   ObjectSetInteger(0, tmp_str0008A, 100, Gi_0004B);
   ObjectSetInteger(0, tmp_str0008A, 9, 0);
   tmp_str0008B = "Dubai";
   tmp_str0008D = "Short Spread";
   tmp_str0008E = Is_09CA0 + "_MNShortSpread_";
   tmp_str0008E = tmp_str0008E + Ls_FF618;
   tmp_str0008E = tmp_str0008E + "/";
   tmp_str0008E = tmp_str0008E + Ls_FF608;
   tmp_str0008E = tmp_str0008E + "_";
   tmp_str0008E = tmp_str0008E + IntegerToString(Li_FF604, 0, 32);
   tmp_str00090 = tmp_str0008E;
   ObjectCreate(0, tmp_str00090, OBJ_BUTTON, 0, 0, 0);
   Gi_00050 = (int)(moltiplicatoreGrafiche * 910);
   ObjectSetInteger(0, tmp_str00090, 102, Gi_00050);
   ObjectSetInteger(0, tmp_str00090, 101, 0);
   Gi_00050 = (int)(Gi_0004C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00090, 103, Gi_00050);
   Gi_00050 = (int)Gd_0004D;
   ObjectSetInteger(0, tmp_str00090, 1019, Gi_00050);
   Gi_00050 = (int)Gd_0004E;
   ObjectSetInteger(0, tmp_str00090, 1020, Gi_00050);
   ObjectSetString(0, tmp_str00090, 999, tmp_str0008D);
   ObjectSetString(0, tmp_str00090, 1001, tmp_str0008B);
   ObjectSetInteger(0, tmp_str00090, 6, 16777215);
   ObjectSetInteger(0, tmp_str00090, 1025, 255);
   ObjectSetInteger(0, tmp_str00090, 1035, 255);
   ObjectSetInteger(0, tmp_str00090, 1029, 1);
   ObjectSetInteger(0, tmp_str00090, 208, 1);
   ObjectSetInteger(0, tmp_str00090, 1018, 0);
   ObjectSetInteger(0, tmp_str00090, 100, Gi_0004B);
   ObjectSetInteger(0, tmp_str00090, 9, 0);
   } 
   Gd_00050 = Ld_FF5F0;
   Ld_FF640 = (Ld_FF640 + Gd_00050);
   Li_FFFFC = Li_FFFFC + 30;
   } 
   Li_FF624 = Li_FF624 + 1;
   } while (Li_FF624 < ArraySize(Input_Struct_00009D18)); 
   } 
   Gi_00050 = 0;
   Gi_00051 = 1;
   if ((Ld_FF640 > 0)) { 
   Gi_00053 = 3329330;
   } 
   else { 
   if ((Ld_FF640 < 0)) { 
   Gi_00054 = 255;
   } 
   else { 
   Gi_00054 = 13882323;
   } 
   Gi_00053 = Gi_00054;
   } 
   Gi_00054 = Li_FFFFC + 2;
   tmp_str00091 = "Totale : ";
   tmp_str00092 = Is_09CA0 + "_Totale";
   ObjectCreate(0, tmp_str00092, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00092, tmp_str00091, grandezzaFont, "Dubai", Gi_00053);
   ObjectSet(tmp_str00092, OBJPROP_CORNER, Gi_00050);
   Gi_00055 = (int)(moltiplicatoreGrafiche * 150);
   ObjectSet(tmp_str00092, OBJPROP_XDISTANCE, Gi_00055);
   Gi_00055 = (int)(Gi_00054 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00092, OBJPROP_YDISTANCE, Gi_00055);
   ObjectSetInteger(0, tmp_str00092, 1011, Gi_00051);
   ObjectSetInteger(0, tmp_str00092, 1000, 0);
   Gi_00055 = 0;
   Gi_00056 = 1;
   if ((Ld_FF640 > 0)) { 
   Gi_00058 = 3329330;
   } 
   else { 
   if ((Ld_FF640 < 0)) { 
   Gi_00059 = 255;
   } 
   else { 
   Gi_00059 = 13882323;
   } 
   Gi_00058 = Gi_00059;
   } 
   Gi_00059 = Li_FFFFC + 2;
   tmp_str00096 = "P/L : ";
   tmp_str00096 = tmp_str00096 + DoubleToString(Ld_FF640, 2);
   tmp_str00098 = Is_09CA0 + "_plTotale";
   ObjectCreate(0, tmp_str00098, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00098, tmp_str00096, grandezzaFont, "Dubai", Gi_00058);
   ObjectSet(tmp_str00098, OBJPROP_CORNER, Gi_00055);
   Gi_0005B = (int)(moltiplicatoreGrafiche * 230);
   ObjectSet(tmp_str00098, OBJPROP_XDISTANCE, Gi_0005B);
   Gi_0005B = (int)(Gi_00059 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00098, OBJPROP_YDISTANCE, Gi_0005B);
   ObjectSetInteger(0, tmp_str00098, 1011, Gi_00056);
   ObjectSetInteger(0, tmp_str00098, 1000, 0);
   tmp_str00099 = "Dubai";
   Gi_0005B = grandezzaFont - 1;
   Gi_0005C = Li_FFFFC - 8;
   tmp_str0009C = "Close Gain";
   tmp_str0009E = Is_09CA0 + "_chiudiGain";
   ObjectCreate(0, tmp_str0009E, OBJ_BUTTON, 0, 0, 0);
   Gi_0005D = (int)(moltiplicatoreGrafiche * 280);
   ObjectSetInteger(0, tmp_str0009E, 102, Gi_0005D);
   ObjectSetInteger(0, tmp_str0009E, 101, 0);
   Gi_0005D = (int)(Gi_0005C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0009E, 103, Gi_0005D);
   Gd_0005D = (moltiplicatoreGrafiche * 100);
   Gi_0005E = (int)Gd_0005D;
   ObjectSetInteger(0, tmp_str0009E, 1019, Gi_0005E);
   Gd_0005E = (moltiplicatoreGrafiche * 20);
   Gi_0005F = (int)Gd_0005E;
   ObjectSetInteger(0, tmp_str0009E, 1020, Gi_0005F);
   ObjectSetString(0, tmp_str0009E, 999, tmp_str0009C);
   ObjectSetString(0, tmp_str0009E, 1001, tmp_str00099);
   ObjectSetInteger(0, tmp_str0009E, 6, 16777215);
   ObjectSetInteger(0, tmp_str0009E, 1025, 3329330);
   ObjectSetInteger(0, tmp_str0009E, 1035, 3329330);
   ObjectSetInteger(0, tmp_str0009E, 1029, 1);
   ObjectSetInteger(0, tmp_str0009E, 208, 1);
   ObjectSetInteger(0, tmp_str0009E, 1018, 0);
   ObjectSetInteger(0, tmp_str0009E, 100, Gi_0005B);
   ObjectSetInteger(0, tmp_str0009E, 9, 0);
   tmp_str0009F = "Dubai";
   tmp_str000A1 = "Close Loss";
   tmp_str000A3 = Is_09CA0 + "_chiudiLoss";
   ObjectCreate(0, tmp_str000A3, OBJ_BUTTON, 0, 0, 0);
   Gi_00060 = (int)(moltiplicatoreGrafiche * 385);
   ObjectSetInteger(0, tmp_str000A3, 102, Gi_00060);
   ObjectSetInteger(0, tmp_str000A3, 101, 0);
   Gi_00060 = (int)(Gi_0005C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000A3, 103, Gi_00060);
   Gi_00060 = (int)Gd_0005D;
   ObjectSetInteger(0, tmp_str000A3, 1019, Gi_00060);
   Gi_00060 = (int)Gd_0005E;
   ObjectSetInteger(0, tmp_str000A3, 1020, Gi_00060);
   ObjectSetString(0, tmp_str000A3, 999, tmp_str000A1);
   ObjectSetString(0, tmp_str000A3, 1001, tmp_str0009F);
   ObjectSetInteger(0, tmp_str000A3, 6, 16777215);
   ObjectSetInteger(0, tmp_str000A3, 1025, 255);
   ObjectSetInteger(0, tmp_str000A3, 1035, 255);
   ObjectSetInteger(0, tmp_str000A3, 1029, 1);
   ObjectSetInteger(0, tmp_str000A3, 208, 1);
   ObjectSetInteger(0, tmp_str000A3, 1018, 0);
   ObjectSetInteger(0, tmp_str000A3, 100, Gi_0005B);
   ObjectSetInteger(0, tmp_str000A3, 9, 0);
   tmp_str000A4 = "Dubai";
   Gi_00060 = 0;
   if ((Ld_FF640 > 0)) { 
   Gi_00061 = 16777215;
   } 
   else { 
   if ((Ld_FF640 < 0)) { 
   Gi_00062 = 16777215;
   } 
   else { 
   Gi_00062 = 0;
   } 
   Gi_00061 = Gi_00062;
   } 
   Gi_00062 = Gi_00061;
   if ((Ld_FF640 > 0)) { 
   Gi_00063 = 3329330;
   } 
   else { 
   if ((Ld_FF640 < 0)) { 
   Gi_00064 = 255;
   } 
   else { 
   Gi_00064 = 11119017;
   } 
   Gi_00063 = Gi_00064;
   } 
   Gi_00064 = Li_FFFFC - 8;
   tmp_str000A5 = "Close ALL";
   tmp_str000A7 = Is_09CA0 + "_chiudiTotale";
   ObjectCreate(0, tmp_str000A7, OBJ_BUTTON, 0, 0, 0);
   Gi_00066 = (int)(moltiplicatoreGrafiche * 490);
   ObjectSetInteger(0, tmp_str000A7, 102, Gi_00066);
   ObjectSetInteger(0, tmp_str000A7, 101, Gi_00060);
   Gi_00066 = (int)(Gi_00064 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000A7, 103, Gi_00066);
   Gi_00066 = (int)(moltiplicatoreGrafiche * 100);
   ObjectSetInteger(0, tmp_str000A7, 1019, Gi_00066);
   Gi_00066 = (int)(moltiplicatoreGrafiche * 20);
   ObjectSetInteger(0, tmp_str000A7, 1020, Gi_00066);
   ObjectSetString(0, tmp_str000A7, 999, tmp_str000A5);
   ObjectSetString(0, tmp_str000A7, 1001, tmp_str000A4);
   ObjectSetInteger(0, tmp_str000A7, 6, Gi_00062);
   ObjectSetInteger(0, tmp_str000A7, 1025, Gi_00063);
   ObjectSetInteger(0, tmp_str000A7, 1035, Gi_00063);
   ObjectSetInteger(0, tmp_str000A7, 1029, 1);
   ObjectSetInteger(0, tmp_str000A7, 208, 1);
   ObjectSetInteger(0, tmp_str000A7, 1018, 0);
   ObjectSetInteger(0, tmp_str000A7, 100, Gi_0005B);
   ObjectSetInteger(0, tmp_str000A7, 9, 0);
   tmp_str000A8 = IntegerToString(MagicInp, 0, 32);
   tmp_str000A8 = tmp_str000A8 + "_newgrid";
   if (GlobalVariableCheck(tmp_str000A8) != true) { 
   tmp_str000AA = IntegerToString(MagicInp, 0, 32);
   tmp_str000AA = tmp_str000AA + "_newgrid";
   GlobalVariableSet(tmp_str000AA, 1);
   } 
   tmp_str000AC = IntegerToString(MagicInp, 0, 32);
   tmp_str000AC = tmp_str000AC + "_newgrid";
   Lb_FF5CF = GlobalVariableGet(tmp_str000AC);
   tmp_str000AE = "Dubai";
   Gi_00066 = 0;
   Gi_00067 = grandezzaFont - 1;
   Gi_00068 = 16777215;
   if (Lb_FF5CF) { 
   Gi_00069 = 3329330;
   } 
   else { 
   Gi_00069 = 255;
   } 
   Gi_0006A = 20;
   Gi_0006B = 125;
   Gi_0006C = Li_FFFFC - 8;
   Gi_0006D = 20;
   if (Lb_FF5CF) { 
   tmp_str000B0 = "New grids allowed";
   } 
   else { 
   tmp_str000B0 = "New grid NOT allowed!";
   } 
   tmp_str000B2 = tmp_str000B0;
   tmp_str000B4 = Is_09CA0 + "_newGrids";
   ObjectCreate(0, tmp_str000B4, OBJ_BUTTON, 0, 0, 0);
   Gi_0006E = (int)(Gi_0006D * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000B4, 102, Gi_0006E);
   ObjectSetInteger(0, tmp_str000B4, 101, Gi_00066);
   Gi_0006E = (int)(Gi_0006C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000B4, 103, Gi_0006E);
   Gi_0006E = (int)(Gi_0006B * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000B4, 1019, Gi_0006E);
   Gi_0006E = (int)(Gi_0006A * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str000B4, 1020, Gi_0006E);
   ObjectSetString(0, tmp_str000B4, 999, tmp_str000B2);
   ObjectSetString(0, tmp_str000B4, 1001, tmp_str000AE);
   ObjectSetInteger(0, tmp_str000B4, 6, Gi_00068);
   ObjectSetInteger(0, tmp_str000B4, 1025, Gi_00069);
   ObjectSetInteger(0, tmp_str000B4, 1035, Gi_00069);
   ObjectSetInteger(0, tmp_str000B4, 1029, 1);
   ObjectSetInteger(0, tmp_str000B4, 208, 1);
   ObjectSetInteger(0, tmp_str000B4, 1018, 0);
   ObjectSetInteger(0, tmp_str000B4, 100, Gi_00067);
   ObjectSetInteger(0, tmp_str000B4, 9, 0);
   Gi_0006E = Li_FFFFC - 15;

   tmp_str000B5 = Is_09CA0 + "background";
   ObjectSetInteger(0, tmp_str000B5, 1020, Gi_0006E);

   Li_FF5C8 = 0;
   if (Li_FF5C8 < ArraySize(Input_Struct_00009D18)) { 
   do { 
   Ls_FF5B8 = Input_Struct_00009D18[Li_FF5C8].m_16;
   Ls_FF5A8 = Input_Struct_00009D18[Li_FF5C8].m_28;
   Li_FF5A4 = Input_Struct_00009D18[Li_FF5C8].m_64;
   Ld_FF598 = 1315860;
   if ((Ld_FF69C[Li_FF5C8] < 0)) { 
   Li_FF594 = (int)((120 * Ld_FF69C[Li_FF5C8]) / Ld_FF650);
   tmp_str000B7 = IntegerToString(Li_FF594, 0, 32);
   tmp_str000B7 = tmp_str000B7 + ",0,0";
   returned_i = StringToColor(tmp_str000B7);
   Ld_FF598 = returned_i;
   Gi_00076 = (int)Ld_FF598;
   tmp_str000B8 = Is_09CA0 + "_back_";
   tmp_str000B8 = tmp_str000B8 + Ls_FF5B8;
   tmp_str000B8 = tmp_str000B8 + "/";
   tmp_str000B8 = tmp_str000B8 + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000B8, 1025, Gi_00076);
   Gi_00077 = (int)Ld_FF598;
   tmp_str000BB = Is_09CA0 + " " ;
   tmp_str000BB = tmp_str000BB + Ls_FF5B8;
   tmp_str000BC = exEA1;
   Gi_00079 = AccountFreeMarginMode();
   tmp_str000BD = listaSpreadDaTradare1;
   
   tmp_str000BB = tmp_str000BB + " " ;
   tmp_str000BB = tmp_str000BB + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000BB, 1035, Gi_00077);
   } 
   else { 
   if ((Ld_FF69C[Li_FF5C8] > 0)) { 
   Li_FF590 = (int)((120 * Ld_FF69C[Li_FF5C8]) / Ld_FF660);
   tmp_str000BE = "0," + IntegerToString(Li_FF590, 0, 32);
   tmp_str000BE = tmp_str000BE + ",0";
   returned_i = StringToColor(tmp_str000BE);
   Ld_FF598 = returned_i;
   Gi_0007B = (int)Ld_FF598;
   tmp_str000BF = Is_09CA0 + "_back_";
   tmp_str000BF = tmp_str000BF + Ls_FF5B8;
   tmp_str000BF = tmp_str000BF + "/";
   tmp_str000BF = tmp_str000BF + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000BF, 1025, Gi_0007B);
   Gi_0007C = (int)Ld_FF598;
   tmp_str000C1 = Is_09CA0 + "_back_";
   tmp_str000C1 = tmp_str000C1 + Ls_FF5B8;
   tmp_str000C1 = tmp_str000C1 + "/";
   tmp_str000C1 = tmp_str000C1 + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000C1, 1035, Gi_0007C);
   } 
   else { 
   tmp_str000C4 = Is_09CA0 + "_back_";
   tmp_str000C4 = tmp_str000C4 + Ls_FF5B8;
   tmp_str000C4 = tmp_str000C4 + "/";
   tmp_str000C4 = tmp_str000C4 + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000C4, 1025, Ii_1CEC4);
   tmp_str000C7 = Is_09CA0 + "_back_";
   tmp_str000C7 = tmp_str000C7 + Ls_FF5B8;
   tmp_str000C7 = tmp_str000C7 + "/";
   tmp_str000C7 = tmp_str000C7 + Ls_FF5A8;
   ObjectSetInteger(0, tmp_str000C7, 1035, Ii_1CEC4);
   }} 
   Li_FF5C8 = Li_FF5C8 + 1;
   } while (Li_FF5C8 < ArraySize(Input_Struct_00009D18)); 
   } 
   ChartRedraw(0);
   ArrayFree(Ld_FF69C);
}

void func_1048(string Fa_s_00, string Fa_s_01, int Fa_i_02, string &Fa_s_03, double &Fa_d_04, double &Fa_d_05, double &Fa_d_06)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   double Ld_FFFF8;
   double Ld_FFFF0;
   double Ld_FFFE8;
   double Ld_FFFE0;
   double Ld_FFFD8;
   double Ld_FFFD0;
   int Li_FFFCC;
   string Ls_FFFC0;

   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Ld_FFFE8 = 0;
   Ld_FFFE0 = 0;
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Li_FFFCC = OrdersTotal();
   if (Li_FFFCC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFCC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFC0 = OrderComment();
   if (Ib_09C81) { 
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   Gi_00000 = (int)StringToInteger("");
   Gi_00001 = 0;
   Gi_00000 = 0;
   Gi_00002 = HistoryTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 1)) { 
   Gl_00002 = OrderOpenTime();
   tmp_str0000A = IntegerToString(MagicInp, 0, 32);
   tmp_str0000A = tmp_str0000A + "_PMPtimeFlat";
   Gl_00004 = (datetime)(GlobalVariableGet(tmp_str0000A) * 1000);
   if (Gl_00002 >= Gl_00004) { 
   Gi_00004 = StringFind(OrderComment(), "to #");
   if (Gi_00004 >= 0) { 
   Gi_00004 = (int)StringToInteger("");
   if (Gi_00004 == Gi_00000) { 
   Gi_00000 = OrderTicket();
   Gi_00001 = Gi_00000;
   }}}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Gi_00004 = Gi_00001;
   Gi_00005 = ArraySize(Is_0B074) - 1;
   Gi_00006 = Gi_00005;
   tmp_str00016 = "";
   if (Gi_00005 >= 0) {
   do { 
   string Ls_FFF8C[];
   tmp_str00012 = Is_0B074[Gi_00006];
   Gst_00008 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00012, Gst_00008, Ls_FFF8C);
   if (ArraySize(Ls_FFF8C) >= 2) {
   tmp_str00016 = (string)Gi_00004;
   if (Ls_FFF8C[0] == tmp_str00016) {
   tmp_str00016 = Ls_FFF8C[1];
   ArrayFree(Ls_FFF8C);
   break;
   }}
   ArrayFree(Ls_FFF8C);
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   }
   
   Ls_FFFC0 = tmp_str00016;
   if (tmp_str00016 == "") { 
   tmp_str00017 = "";
   tmp_str00019 = "ERRORE determinazione ordine, sistema sospeso IS ";
   tmp_str00019 = tmp_str00019 + tmp_str00016;
   tmp_str00018 = Fa_s_01;
   tmp_str0001A = Fa_s_00;
   func_1050(Fa_i_02, tmp_str0001A, tmp_str00018, tmp_str00019, tmp_str00017, 0);
   Ib_1CED0 = true;
   return ;
   }}} 
   if (OrderSelect(Li_FFFCC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Ld_FFFF8 = (Ld_FFFF8 + OrderLots());
   }
   else{
   Ld_FFFF0 = (Ld_FFFF0 + OrderLots());
   }
   if (OrderSymbol() == Fa_s_00) { 
   if (OrderType() == OP_BUY) { 
   Ld_FFFE8 = (Ld_FFFE8 + OrderLots());
   } 
   if (OrderType() == OP_SELL) { 
   Ld_FFFE0 = (Ld_FFFE0 + OrderLots());
   } 
   Fa_d_05 = (Fa_d_05 + OrderLots());
   } 
   if (OrderSymbol() == Fa_s_01) { 
   if (OrderType() == OP_BUY) { 
   Ld_FFFD8 = (Ld_FFFD8 + OrderLots());
   } 
   if (OrderType() == OP_SELL) { 
   Ld_FFFD0 = (Ld_FFFD0 + OrderLots());
   } 
   Fa_d_06 = (Fa_d_06 + OrderLots());
   } 
   Gd_0000B = OrderProfit();
   Gd_0000B = (Gd_0000B + OrderSwap());
   Fa_d_04 = ((Gd_0000B + OrderCommission()) + Fa_d_04);
   }}}} 
   Li_FFFCC = Li_FFFCC - 1;
   } while (Li_FFFCC >= 0); 
   } 
   if ((Ld_FFFF8 > Ld_FFFF0)) { 
   Fa_s_03 = "Long Spread";
   } 
   if ((Ld_FFFF8 < Ld_FFFF0)) { 
   Fa_s_03 = "Short Spread";
   } 

   Fa_d_05 = Ld_FFFE8 - Ld_FFFE0;
   Fa_d_06 = Ld_FFFD8 - Ld_FFFD0;
   
}

void func_1050(int Fa_i_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, string Fa_s_04, int Fa_i_05)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;

   if (utilizzaAllarmiErrore) { 
   if (utilizzaAlertErrore) { 
   
   tmp_str00001 = "Error" + (string)Fa_i_05;
   tmp_str00001 = tmp_str00001 + " ";
   tmp_str00001 = tmp_str00001 + Fa_s_03;
   tmp_str00001 = tmp_str00001 + " ";
   tmp_str00001 = tmp_str00001 + Is_09CA0;
   tmp_str00001 = tmp_str00001 + " ";
   tmp_str00001 = tmp_str00001 + Fa_s_01;
   tmp_str00001 = tmp_str00001 + "/";
   tmp_str00001 = tmp_str00001 + Fa_s_02;
   tmp_str00001 = tmp_str00001 + " on TF ";
   tmp_str00001 = tmp_str00001 + Is_09C88;
   tmp_str00001 = tmp_str00001 + " with ID ";
   tmp_str00001 = tmp_str00001 + (string)Fa_i_00;
   tmp_str00001 = tmp_str00001 + Fa_s_04;
   Alert(tmp_str00001);
   } 
   if (IsTesting() != true) { 
   if (utilizzaPopupErrore && Il_1CED8 != Time[0]) { 
   
   tmp_str00007 = "Error" + (string)Fa_i_05;
   tmp_str00007 = tmp_str00007 + " ";
   tmp_str00007 = tmp_str00007 + Fa_s_03;
   tmp_str00007 = tmp_str00007 + " ";
   tmp_str00007 = tmp_str00007 + Is_09CA0;
   tmp_str00007 = tmp_str00007 + " ";
   tmp_str00007 = tmp_str00007 + Fa_s_01;
   tmp_str00007 = tmp_str00007 + "/";
   tmp_str00007 = tmp_str00007 + Fa_s_02;
   tmp_str00007 = tmp_str00007 + " on TF ";
   tmp_str00007 = tmp_str00007 + Is_09C88;
   tmp_str00007 = tmp_str00007 + " with ID ";
   tmp_str00007 = tmp_str00007 + (string)Fa_i_00;
   tmp_str00007 = tmp_str00007 + Fa_s_04;
   SendNotification(tmp_str00007);
   } 
   if (utilizzaMailErrore && Il_1CED8 != Time[0]) { 
   tmp_str0000C = "Error" + (string)Fa_i_05;
   tmp_str0000C = tmp_str0000C + " ";
   tmp_str0000C = tmp_str0000C + Fa_s_03;
   tmp_str0000C = tmp_str0000C + " ";
   tmp_str0000C = tmp_str0000C + Is_09CA0;
   tmp_str0000C = tmp_str0000C + " ";
   tmp_str0000C = tmp_str0000C + Fa_s_01;
   tmp_str0000C = tmp_str0000C + "/";
   tmp_str0000C = tmp_str0000C + Fa_s_02;
   tmp_str0000C = tmp_str0000C + " on TF ";
   tmp_str0000C = tmp_str0000C + Is_09C88;
   tmp_str0000C = tmp_str0000C + " with ID ";
   tmp_str0000C = tmp_str0000C + (string)Fa_i_00;
   tmp_str0000C = tmp_str0000C + Fa_s_04;

   tmp_str00013 = "Error" + Fa_s_01;
   tmp_str00013 = tmp_str00013 + "/";
   tmp_str00013 = tmp_str00013 + Fa_s_02;
   tmp_str00013 = tmp_str00013 + "TF ";
   tmp_str00013 = tmp_str00013 + Is_09C88;
   tmp_str00013 = tmp_str00013 + " with ID ";
   tmp_str00013 = tmp_str00013 + (string)Fa_i_00;
   SendMail(tmp_str00013, tmp_str0000C);
   }} 
   Il_1CED8 = Time[0];
   return ;
   } 
   tmp_str00018 = "Error " + (string)Fa_i_05;
   tmp_str00018 = tmp_str00018 + " ";
   tmp_str00018 = tmp_str00018 + Fa_s_03;
   tmp_str00018 = tmp_str00018 + " ";
   tmp_str00018 = tmp_str00018 + Is_09CA0;
   tmp_str00018 = tmp_str00018 + " ";
   tmp_str00018 = tmp_str00018 + Fa_s_01;
   tmp_str00018 = tmp_str00018 + "/";
   tmp_str00018 = tmp_str00018 + Fa_s_02;
   tmp_str00018 = tmp_str00018 + " on TF ";
   tmp_str00018 = tmp_str00018 + Is_09C88;
   tmp_str00018 = tmp_str00018 + " with ID ";
   tmp_str00018 = tmp_str00018 + (string)Fa_i_00;
   tmp_str00018 = tmp_str00018 + Fa_s_04;
   Print(tmp_str00018);
   
}

void func_1051(int Fa_i_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, string Fa_s_04)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;

   if (utilizzaAllarmiInserimentoOrdini == false) return; 
   if (utilizzaAlertInserimentoOrdini) { 
   tmp_str00001 = Fa_s_03 + " ";
   tmp_str00001 = tmp_str00001 + Is_09CA0;
   tmp_str00001 = tmp_str00001 + " ";
   tmp_str00001 = tmp_str00001 + Fa_s_01;
   tmp_str00001 = tmp_str00001 + "/";
   tmp_str00001 = tmp_str00001 + Fa_s_02;
   tmp_str00001 = tmp_str00001 + " on TF ";
   tmp_str00001 = tmp_str00001 + Is_09C88;
   tmp_str00001 = tmp_str00001 + " with ID ";
   tmp_str00001 = tmp_str00001 + (string)Fa_i_00;
   tmp_str00001 = tmp_str00001 + Fa_s_04;
   Alert(tmp_str00001);
   } 
   if (IsTesting()) return; 
   if (utilizzaPopupInserimentoOrdini) { 
   tmp_str00005 = Fa_s_03 + " ";
   tmp_str00005 = tmp_str00005 + Is_09CA0;
   tmp_str00005 = tmp_str00005 + " ";
   tmp_str00005 = tmp_str00005 + Fa_s_01;
   tmp_str00005 = tmp_str00005 + "/";
   tmp_str00005 = tmp_str00005 + Fa_s_02;
   tmp_str00005 = tmp_str00005 + " on TF ";
   tmp_str00005 = tmp_str00005 + Is_09C88;
   tmp_str00005 = tmp_str00005 + " with ID ";
   tmp_str00005 = tmp_str00005 + (string)Fa_i_00;
   tmp_str00005 = tmp_str00005 + Fa_s_04;
   SendNotification(tmp_str00005);
   } 
   if (utilizzaMailInserimentoOrdini == false) return; 
   tmp_str0000A = Fa_s_03 + " ";
   tmp_str0000A = tmp_str0000A + Is_09CA0;
   tmp_str0000A = tmp_str0000A + " ";
   tmp_str0000A = tmp_str0000A + Fa_s_01;
   tmp_str0000A = tmp_str0000A + "/";
   tmp_str0000A = tmp_str0000A + Fa_s_02;
   tmp_str0000A = tmp_str0000A + " on TF ";
   tmp_str0000A = tmp_str0000A + Is_09C88;
   tmp_str0000A = tmp_str0000A + " with ID ";
   tmp_str0000A = tmp_str0000A + (string)Fa_i_00;
   tmp_str0000A = tmp_str0000A + Fa_s_04;
   tmp_str0000D = Fa_s_03 + Fa_s_01;
   tmp_str0000D = tmp_str0000D + "/";
   tmp_str0000D = tmp_str0000D + Fa_s_02;
   tmp_str0000D = tmp_str0000D + "TF ";
   tmp_str0000D = tmp_str0000D + Is_09C88;
   tmp_str0000D = tmp_str0000D + " with ID (Magic Number) ";
   tmp_str0000D = tmp_str0000D + (string)Fa_i_00;
   SendMail(tmp_str0000D, tmp_str0000A);
   
}

void func_1052(int Fa_i_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, string Fa_s_04)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;

   if (utilizzaAllarmiModificaOrdini == false) return; 
   tmp_str00001 = Fa_s_03 + " ";
   tmp_str00001 = tmp_str00001 + Is_09CA0;
   tmp_str00001 = tmp_str00001 + " ";
   tmp_str00001 = tmp_str00001 + Fa_s_01;
   tmp_str00001 = tmp_str00001 + "/";
   tmp_str00001 = tmp_str00001 + Fa_s_02;
   tmp_str00001 = tmp_str00001 + " on TF ";
   tmp_str00001 = tmp_str00001 + Is_09C88;
   tmp_str00001 = tmp_str00001 + " with ID ";
   tmp_str00001 = tmp_str00001 + (string)Fa_i_00;
   tmp_str00001 = tmp_str00001 + Fa_s_04;
   Alert(tmp_str00001);
   if (IsTesting()) return; 
   tmp_str00006 = Fa_s_03 + " ";
   tmp_str00006 = tmp_str00006 + Is_09CA0;
   tmp_str00006 = tmp_str00006 + " ";
   tmp_str00006 = tmp_str00006 + Fa_s_01;
   tmp_str00006 = tmp_str00006 + "/";
   tmp_str00006 = tmp_str00006 + Fa_s_02;
   tmp_str00006 = tmp_str00006 + " on TF ";
   tmp_str00006 = tmp_str00006 + Is_09C88;
   tmp_str00006 = tmp_str00006 + " with ID ";
   tmp_str00006 = tmp_str00006 + (string)Fa_i_00;
   tmp_str00006 = tmp_str00006 + Fa_s_04;
   SendNotification(tmp_str00006);
   tmp_str0000B = Fa_s_03 + " ";
   tmp_str0000B = tmp_str0000B + Is_09CA0;
   tmp_str0000B = tmp_str0000B + " ";
   tmp_str0000B = tmp_str0000B + Fa_s_01;
   tmp_str0000B = tmp_str0000B + "/";
   tmp_str0000B = tmp_str0000B + Fa_s_02;
   tmp_str0000B = tmp_str0000B + " on TF ";
   tmp_str0000B = tmp_str0000B + Is_09C88;
   tmp_str0000B = tmp_str0000B + " with ID ";
   tmp_str0000B = tmp_str0000B + (string)Fa_i_00;
   tmp_str0000B = tmp_str0000B + Fa_s_04;
   tmp_str0000F = Fa_s_03 + Fa_s_01;
   tmp_str0000F = tmp_str0000F + "/";
   tmp_str0000F = tmp_str0000F + Fa_s_02;
   tmp_str0000F = tmp_str0000F + "TF ";
   tmp_str0000F = tmp_str0000F + Is_09C88;
   tmp_str0000F = tmp_str0000F + " with ID (Magic Number) ";
   tmp_str0000F = tmp_str0000F + (string)Ii_1D234;
   SendMail(tmp_str0000F, tmp_str0000B);
   
}

void func_1058()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   int Li_FFFFC;
   int Li_FFFF8;
   int Li_FFFF4;
   int Li_FFFF0;
   int Li_FFFEC;
   int Li_FFFE8;
   int Li_FFFE4;
   int Li_FFFE0;
   int Li_FFFDC;
   int Li_FFFD8;
   int Li_FFFD4;
   int Li_FFFD0;

   tmp_str00001 = "Dashboard";
   tmp_str00003 = Is_09CA0 + "visualizzazione";
   ObjectCreate(0, tmp_str00003, OBJ_BUTTON, 0, 0, 0);
   Gd_00000 = (moltiplicatoreGrafiche * 10);
   Gi_00001 = (int)Gd_00000;
   ObjectSetInteger(0, tmp_str00003, 102, Gi_00001);
   ObjectSetInteger(0, tmp_str00003, 101, 0);
   Gi_00001 = (int)Gd_00000;
   ObjectSetInteger(0, tmp_str00003, 103, Gi_00001);
   Gi_00001 = (int)(moltiplicatoreGrafiche * 80);
   ObjectSetInteger(0, tmp_str00003, 1019, Gi_00001);
   Gi_00001 = (int)(moltiplicatoreGrafiche * 30);
   ObjectSetInteger(0, tmp_str00003, 1020, Gi_00001);
   ObjectSetString(0, tmp_str00003, 999, tmp_str00001);
   ObjectSetInteger(0, tmp_str00003, 6, 255);
   ObjectSetInteger(0, tmp_str00003, 1025, 3289650);
   ObjectSetInteger(0, tmp_str00003, 1035, 3289650);
   ObjectSetInteger(0, tmp_str00003, 1029, 1);
   ObjectSetInteger(0, tmp_str00003, 208, 1);
   ObjectSetInteger(0, tmp_str00003, 1018, 0);
   ObjectSetInteger(0, tmp_str00003, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00003, 9, 0);
   ObjectSetInteger(0, tmp_str00003, 1000, 0);

   Li_FFFFC = 78;
   Li_FFFF8 = 33;
   Li_FFFF4 = 80;
   Li_FFFF0 = 35;
   Li_FFFEC = 40;
   Li_FFFE8 = 90;
   Li_FFFE4 = 0;
   Li_FFFE0 = 0;
   Li_FFFDC = 0;
   if (Li_FFFDC < ArraySize(Is_09CB0)) { 
   do { 
   tmp_str00008 = Is_09CB0[Li_FFFDC];
   tmp_str0000A = Is_09CA0 + "nome_";
   tmp_str0000A = tmp_str0000A + Is_09CB0[Li_FFFDC];
   tmp_str0000A = tmp_str0000A + "_Y";
   ObjectCreate(0, tmp_str0000A, OBJ_BUTTON, 0, 0, 0);
   Gi_00009 = (int)(deltaXIniziale * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000A, 102, Gi_00009);
   ObjectSetInteger(0, tmp_str0000A, 101, 0);
   Gi_00009 = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000A, 103, Gi_00009);
   Gi_00009 = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000A, 1019, Gi_00009);
   Gi_00009 = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000A, 1020, Gi_00009);
   ObjectSetString(0, tmp_str0000A, 999, tmp_str00008);
   ObjectSetInteger(0, tmp_str0000A, 6, 16777215);
   ObjectSetInteger(0, tmp_str0000A, 1025, 0);
   ObjectSetInteger(0, tmp_str0000A, 1035, 0);
   ObjectSetInteger(0, tmp_str0000A, 1029, 1);
   ObjectSetInteger(0, tmp_str0000A, 208, 1);
   ObjectSetInteger(0, tmp_str0000A, 1018, 0);
   ObjectSetInteger(0, tmp_str0000A, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0000A, 9, 0);
   ObjectSetInteger(0, tmp_str0000A, 1000, 0);
   Gi_00009 = deltaYIniziale + 10;
   tmp_str0000B = Is_09CB0[Li_FFFDC];
   tmp_str0000D = Is_09CA0 + "nome_";
   tmp_str0000D = tmp_str0000D + Is_09CB0[Li_FFFDC];
   tmp_str0000D = tmp_str0000D + "_X";
   tmp_str0000E = tmp_str0000D;
   ObjectCreate(0, tmp_str0000E, OBJ_BUTTON, 0, 0, 0);
   Gi_0000C = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000E, 102, Gi_0000C);
   ObjectSetInteger(0, tmp_str0000E, 101, 0);
   Gi_0000C = (int)(Gi_00009 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000E, 103, Gi_0000C);
   Gi_0000C = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000E, 1019, Gi_0000C);
   Gi_0000C = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000E, 1020, Gi_0000C);
   ObjectSetString(0, tmp_str0000E, 999, tmp_str0000B);
   ObjectSetInteger(0, tmp_str0000E, 6, 16777215);
   ObjectSetInteger(0, tmp_str0000E, 1025, 0);
   ObjectSetInteger(0, tmp_str0000E, 1035, 0);
   ObjectSetInteger(0, tmp_str0000E, 1029, 1);
   ObjectSetInteger(0, tmp_str0000E, 208, 1);
   ObjectSetInteger(0, tmp_str0000E, 1018, 0);
   ObjectSetInteger(0, tmp_str0000E, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0000E, 9, 0);
   ObjectSetInteger(0, tmp_str0000E, 1000, 0);
   tmp_str0000F = "";
   tmp_str00011 = Is_09CA0 + "_";
   tmp_str00011 = tmp_str00011 + Is_09CB0[Li_FFFDC];
   tmp_str00011 = tmp_str00011 + "_0";
   tmp_str00013 = tmp_str00011;
   ObjectCreate(0, tmp_str00013, OBJ_BUTTON, 0, 0, 0);
   Gi_0000D = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00013, 102, Gi_0000D);
   ObjectSetInteger(0, tmp_str00013, 101, 0);
   Gi_0000D = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00013, 103, Gi_0000D);
   Gi_0000D = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00013, 1019, Gi_0000D);
   Gi_0000D = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00013, 1020, Gi_0000D);
   ObjectSetString(0, tmp_str00013, 999, tmp_str0000F);
   ObjectSetInteger(0, tmp_str00013, 6, 16777215);
   ObjectSetInteger(0, tmp_str00013, 1025, 1315860);
   ObjectSetInteger(0, tmp_str00013, 1035, 1315860);
   ObjectSetInteger(0, tmp_str00013, 1029, 1);
   ObjectSetInteger(0, tmp_str00013, 208, 1);
   ObjectSetInteger(0, tmp_str00013, 1018, 0);
   ObjectSetInteger(0, tmp_str00013, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00013, 9, 0);
   ObjectSetInteger(0, tmp_str00013, 1000, 0);
   Li_FFFE8 = Li_FFFE4 + Li_FFFE8;
   Li_FFFEC = Li_FFFEC + Li_FFFE0;
   Li_FFFDC = Li_FFFDC + 1;
   } while (Li_FFFDC < ArraySize(Is_09CB0)); 
   } 

   Li_FFFEC = 40;
   Li_FFFE8 = 90;
   Li_FFFE4 = Li_FFFF4;
   Li_FFFE0 = Li_FFFF0;
   ArrayResize(Input_Struct_00009CE4, 0, 0);
   Li_FFFD8 = MagicInp;
   Li_FFFD4 = 0;
   if (Li_FFFD4 >= ArraySize(Is_09CB0)) return; 
   do { 
   Li_FFFD0 = 0;
   if (Li_FFFD0 < ArraySize(Is_09CB0)) { 
   do { 
   if (Is_09CB0[Li_FFFD4] == Is_09CB0[Li_FFFD0]) { 
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   } 
   else { 
   ArrayResize(Input_Struct_00009CE4, (ArraySize(Input_Struct_00009CE4) + 1), 0);
   Gi_00011 = ArraySize(Input_Struct_00009CE4) - 1;
   Gi_00012 = Gi_00011;
   Gi_00013 = Gi_00011;
   Gi_00014 = Gi_00011;
   Gi_00015 = Gi_00011;
   Gi_00016 = Gi_00011;
   Gi_00017 = Gi_00011;
   Gi_00018 = Gi_00011;
   Input_Struct_00009CE4[Gi_00011].m_16 = Is_09CB0[Li_FFFD4];
   Gi_0001A = Gi_00018;
   Input_Struct_00009CE4[Gi_00018].m_28 = Is_09CB0[Li_FFFD0];
   Gi_0001B = Gi_00017;
   Input_Struct_00009CE4[Gi_00017].m_40 = 0;
   Gi_0001C = Gi_00016;
   Input_Struct_00009CE4[Gi_00016].m_48 = 0;
   Gi_0001D = Gi_00015;
   Input_Struct_00009CE4[Gi_00015].m_56 = 0;
   Gi_0001E = Gi_00014;
   Input_Struct_00009CE4[Gi_00014].m_64 = Li_FFFD8;
   Gi_0001F = Gi_00013;
   Input_Struct_00009CE4[Gi_00013].m_68 = 0;
   Gi_00020 = Gi_00012;
   Input_Struct_00009CE4[Gi_00012].m_76 = 0;
   if (entraSubito != true) { 
   Gb_00021 = false;
   } 
   else { 
   Gi_00022 = Li_FFFD8;
   tmp_str00016 = Is_09CB0[Li_FFFD0];
   tmp_str00017 = Is_09CB0[Li_FFFD4];
   Gi_00025 = OrdersTotal();
   Gb_00026 = false;
   if (Gi_00025 >= 0) {
   do { 
   if (OrderSelect(Gi_00025, 0, 0) && OrderMagicNumber() == Gi_00022) {
   if (OrderSymbol() == tmp_str00017 || OrderSymbol() == tmp_str00016) {
   
   Gb_00026 = true;
   break;
   }}
   Gi_00025 = Gi_00025 - 1;
   } while (Gi_00025 >= 0); 
   }
   
   if (Gb_00026 != true) { 
   Gb_00027 = true;
   } 
   else { 
   Gb_00027 = false;
   } 
   Gb_00021 = Gb_00027;
   } 
   Gi_00027 = ArraySize(Input_Struct_00009CE4) - 1;
   Gi_00028 = Gi_00027;
   Gi_00029 = Gi_00027;
   Input_Struct_00009CE4[Gi_00027].m_84 = Gb_00021;
   Gi_00021 = Gi_00029;
   Input_Struct_00009CE4[Gi_00029].m_85 = false;
   Gi_0002A = Gi_00028;
   Input_Struct_00009CE4[Gi_00028].m_86 = false;
   tmp_str00018 = " ";
   tmp_str0001A = Is_09CA0 + "_";
   tmp_str0001A = tmp_str0001A + Is_09CB0[Li_FFFD4];
   tmp_str0001A = tmp_str0001A + Is_09CB0[Li_FFFD0];
   tmp_str0001A = tmp_str0001A + "_DatiY";
   tmp_str0001C = tmp_str0001A;
   ObjectCreate(0, tmp_str0001C, OBJ_BUTTON, 0, 0, 0);
   Gi_0002D = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0001C, 102, Gi_0002D);
   ObjectSetInteger(0, tmp_str0001C, 101, 0);
   Gi_0002D = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0001C, 103, Gi_0002D);
   Gi_0002D = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0001C, 1019, Gi_0002D);
   Gi_0002D = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0001C, 1020, Gi_0002D);
   ObjectSetString(0, tmp_str0001C, 999, tmp_str00018);
   ObjectSetInteger(0, tmp_str0001C, 6, 16777215);
   ObjectSetInteger(0, tmp_str0001C, 1025, 3289650);
   ObjectSetInteger(0, tmp_str0001C, 1035, 3289650);
   ObjectSetInteger(0, tmp_str0001C, 1029, 1);
   ObjectSetInteger(0, tmp_str0001C, 208, 1);
   ObjectSetInteger(0, tmp_str0001C, 1018, 0);
   ObjectSetInteger(0, tmp_str0001C, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0001C, 9, 0);
   ObjectSetInteger(0, tmp_str0001C, 1000, 0);
   Gi_0002D = Li_FFFEC + 10;
   Gi_0002E = Li_FFFE8 + 10;
   tmp_str0001E = "Caricamento info";
   tmp_str0001F = Is_09CA0 + "_";
   tmp_str0001F = tmp_str0001F + Is_09CB0[Li_FFFD4];
   tmp_str0001F = tmp_str0001F + "-";
   tmp_str0001F = tmp_str0001F + Is_09CB0[Li_FFFD0];
   tmp_str0001F = tmp_str0001F + "_VAL";
   tmp_str00022 = tmp_str0001F;
   ObjectCreate(0, tmp_str00022, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(tmp_str00022, tmp_str0001E, grandezzaFont, "Dubai", 16777215);
   ObjectSet(tmp_str00022, OBJPROP_CORNER, 0);
   Gi_00031 = (int)(Gi_0002E * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00022, OBJPROP_XDISTANCE, Gi_00031);
   Gi_00031 = (int)(Gi_0002D * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00022, OBJPROP_YDISTANCE, Gi_00031);
   ObjectSetInteger(0, tmp_str00022, 1011, 0);
   ObjectSetInteger(0, tmp_str00022, 1000, 0);
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   Li_FFFD8 = Li_FFFD8 + 1;
   ChartRedraw(0);
   } 
   Li_FFFD0 = Li_FFFD0 + 1;
   } while (Li_FFFD0 < ArraySize(Is_09CB0)); 
   } 
   Li_FFFE8 = 90;
   Li_FFFEC = Li_FFFE0 + Li_FFFEC;
   Li_FFFD4 = Li_FFFD4 + 1;
   } while (Li_FFFD4 < ArraySize(Is_09CB0)); 
   
}

void func_1060(bool FuncArg_Boolean_00000000)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   string tmp_str00074;
   string tmp_str00075;
   string tmp_str00076;
   string tmp_str00077;
   string tmp_str00078;
   string tmp_str00079;
   string tmp_str0007A;
   string tmp_str0007B;
   string tmp_str0007C;
   string tmp_str0007D;
   string tmp_str0007E;
   string tmp_str0007F;
   string tmp_str00080;
   int Li_FFFFC;
   int Li_FFFF8;
   int Li_FFFF4;
   int Li_FFFF0;
   int Li_FFFEC;
   int Li_FFFE8;
   int Li_FFFE4;
   int Li_FFFE0;
   int Li_FFFDC;
   int Li_FFFD8;
   int Li_FFFD4;
   int Li_FFFD0;
   int Li_FFED8;
   int Li_FFED4;
   string Ls_FFEC8;
   int Li_FFEC4;
   int Li_FFF98;
   int Li_FFF60;
   double Ld_FFF50;
   double Ld_FFF48;
   double Ld_FFF40;
   double Ld_FFF38;
   int Li_FFF34;
   string Ls_FFF28;
   string Ls_FFF18;
   int Li_FFF14;
   int Li_FFF10;

   if (iTime(_Symbol, 0, 0) != Il_0EF90) { 
   ArrayInitialize(Il_0B0DC, 0);
   ArrayInitialize(Il_0D050, 0);
   } 
   Il_0EF90 = iTime(_Symbol, 0, 0);
   Li_FFFFC = 78;
   Li_FFFF8 = 33;
   Li_FFFF4 = 80;
   Li_FFFF0 = 35;
   Li_FFFEC = deltaYIniziale + 40;
   Li_FFFE8 = deltaXIniziale + 90;
   Li_FFFE4 = 80;
   Li_FFFE0 = 35;
   Li_FFFDC = 0;
   if (ArraySize(Is_09CB0) > 0) { 
   do { 
   if (FuncArg_Boolean_00000000) { 
   tmp_str00000 = Is_09CB0[Li_FFFDC];
   tmp_str00001 = Is_09CA0 + "nome_";
   tmp_str00001 = tmp_str00001 + Is_09CB0[Li_FFFDC];
   tmp_str00001 = tmp_str00001 + "_Y";
   tmp_str00003 = tmp_str00001;
   if (ObjectFind(tmp_str00003) < 0) {
   ObjectCreate(0, tmp_str00003, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00003 = (int)(deltaXIniziale * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00003, 102, Gi_00003);
   ObjectSetInteger(0, tmp_str00003, 101, 0);
   Gi_00003 = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00003, 103, Gi_00003);
   Gi_00003 = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00003, 1019, Gi_00003);
   Gi_00003 = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00003, 1020, Gi_00003);
   ObjectSetString(0, tmp_str00003, 999, tmp_str00000);
   ObjectSetInteger(0, tmp_str00003, 6, 16777215);
   ObjectSetInteger(0, tmp_str00003, 1025, 0);
   ObjectSetInteger(0, tmp_str00003, 1035, 0);
   ObjectSetInteger(0, tmp_str00003, 1029, 1);
   ObjectSetInteger(0, tmp_str00003, 208, 1);
   ObjectSetInteger(0, tmp_str00003, 1018, 0);
   ObjectSetInteger(0, tmp_str00003, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00003, 9, 0);
   ObjectSetInteger(0, tmp_str00003, 1000, 0);
   Gi_00003 = deltaYIniziale + 10;
   tmp_str00004 = Is_09CB0[Li_FFFDC];
   tmp_str00005 = Is_09CA0 + "nome_";
   tmp_str00005 = tmp_str00005 + Is_09CB0[Li_FFFDC];
   tmp_str00005 = tmp_str00005 + "_X";
   tmp_str00006 = tmp_str00005;
   if (ObjectFind(tmp_str00006) < 0) {
   ObjectCreate(0, tmp_str00006, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00006 = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00006, 102, Gi_00006);
   ObjectSetInteger(0, tmp_str00006, 101, 0);
   Gi_00006 = (int)(Gi_00003 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00006, 103, Gi_00006);
   Gi_00006 = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00006, 1019, Gi_00006);
   Gi_00006 = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00006, 1020, Gi_00006);
   ObjectSetString(0, tmp_str00006, 999, tmp_str00004);
   ObjectSetInteger(0, tmp_str00006, 6, 16777215);
   ObjectSetInteger(0, tmp_str00006, 1025, 0);
   ObjectSetInteger(0, tmp_str00006, 1035, 0);
   ObjectSetInteger(0, tmp_str00006, 1029, 1);
   ObjectSetInteger(0, tmp_str00006, 208, 1);
   ObjectSetInteger(0, tmp_str00006, 1018, 0);
   ObjectSetInteger(0, tmp_str00006, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00006, 9, 0);
   ObjectSetInteger(0, tmp_str00006, 1000, 0);
   tmp_str00007 = "";
   tmp_str00009 = Is_09CA0 + "_";
   tmp_str00009 = tmp_str00009 + Is_09CB0[Li_FFFDC];
   tmp_str00009 = tmp_str00009 + "_0";
   tmp_str0000B = tmp_str00009;
   if (ObjectFind(tmp_str0000B) < 0) {
   ObjectCreate(0, tmp_str0000B, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00007 = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000B, 102, Gi_00007);
   ObjectSetInteger(0, tmp_str0000B, 101, 0);
   Gi_00007 = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000B, 103, Gi_00007);
   Gi_00007 = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000B, 1019, Gi_00007);
   Gi_00007 = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0000B, 1020, Gi_00007);
   ObjectSetString(0, tmp_str0000B, 999, tmp_str00007);
   ObjectSetInteger(0, tmp_str0000B, 6, 16777215);
   ObjectSetInteger(0, tmp_str0000B, 1025, 1315860);
   ObjectSetInteger(0, tmp_str0000B, 1035, 1315860);
   ObjectSetInteger(0, tmp_str0000B, 1029, 1);
   ObjectSetInteger(0, tmp_str0000B, 208, 1);
   ObjectSetInteger(0, tmp_str0000B, 1018, 0);
   ObjectSetInteger(0, tmp_str0000B, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0000B, 9, 0);
   ObjectSetInteger(0, tmp_str0000B, 1000, 0);
   } 
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   Li_FFFEC = Li_FFFEC + Li_FFFE0;
   Li_FFFDC = Li_FFFDC + 1;
   } while (Li_FFFDC < ArraySize(Is_09CB0)); 
   } 
   Li_FFFEC = deltaYIniziale + 40;
   Li_FFFE8 = deltaXIniziale + 90;
   Li_FFFE4 = Li_FFFF4;
   Li_FFFE0 = Li_FFFF0;
   Li_FFFD8 = 0;
   Li_FFFD4 = 0;
   if (ArraySize(Is_09CB0) > 0) { 
   do { 
   Li_FFFD0 = 0;
   if (ArraySize(Is_09CB0) > 0) { 
   do { 
   if (Is_09CB0[Li_FFFD4] == Is_09CB0[Li_FFFD0]) { 
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   } 
   else { 
   double Ld_FFF9C[];
   ArraySetAsSeries(Ld_FFF9C, true);
   Gi_00009 = periodoCorrelazione;
   if (periodoCorrelazione <= numeroBarreOverlay) { 
   Gi_0000A = numeroBarreOverlay;
   } 
   else { 
   Gi_0000A = Gi_00009;
   } 
   Li_FFF98 = CopyClose(Is_09CB0[Li_FFFD4], 0, 0, Gi_0000A, Ld_FFF9C);
   double Ld_FFF64[];
   ArraySetAsSeries(Ld_FFF64, true);
   Gi_0000A = periodoCorrelazione;
   if (periodoCorrelazione <= numeroBarreOverlay) { 
   Gi_0000B = numeroBarreOverlay;
   } 
   else { 
   Gi_0000B = Gi_0000A;
   } 
   Li_FFF60 = CopyClose(Is_09CB0[Li_FFFD0], 0, 0, Gi_0000B, Ld_FFF64);
   if (Il_0B0DC[Li_FFFD8] == iTime(Is_09CB0[Li_FFFD4], 0, 0) && Il_0D050[Li_FFFD8] == iTime(Is_09CB0[Li_FFFD0], 0, 0)) { 
   Li_FFFD8 = Li_FFFD8 + 1;
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   ArrayFree(Ld_FFF64);
   ArrayFree(Ld_FFF9C);
   } 
   else { 
   Gl_00010 = iTime(Is_09CB0[Li_FFFD4], 0, 0);
   if (Gl_00010 != iTime(Is_09CB0[Li_FFFD0], 0, 0)) { 
   Li_FFFD8 = Li_FFFD8 + 1;
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   tmp_str0000E = "Attendo allineamento : ";
   tmp_str0000E = tmp_str0000E + Is_09CB0[Li_FFFD4];
   tmp_str0000E = tmp_str0000E + " ";
   tmp_str0000E = tmp_str0000E + Is_09CB0[Li_FFFD0];
   tmp_str0000E = tmp_str0000E + " ";
   tmp_str0000E = tmp_str0000E + TimeToString(iTime(Is_09CB0[Li_FFFD4], 0, 0), 3);
   tmp_str0000E = tmp_str0000E + " ";
   tmp_str0000E = tmp_str0000E + TimeToString(iTime(Is_09CB0[Li_FFFD0], 0, 0), 3);
   Print(tmp_str0000E);
   ArrayFree(Ld_FFF64);
   ArrayFree(Ld_FFF9C);
   } 
   else { 
   Ld_FFF50 = iCustom(Is_09CB0[Li_FFFD4], 0, "AA_OverLayChart", Is_09CB0[Li_FFFD0], numeroBarreOverlay, calcolaDistanzaDaUltimoIncrocio, 3, 1);
   Ld_FFF48 = iCustom(Is_09CB0[Li_FFFD4], 0, "PulseMatrixCorrelation", Is_09CB0[Li_FFFD0], periodoCorrelazione, periodoMediaCorrelazione, 1, 1);
   Ld_FFF40 = iCustom(Is_09CB0[Li_FFFD4], 0, "AA_OverLayChart", Is_09CB0[Li_FFFD0], numeroBarreOverlay, calcolaDistanzaDaUltimoIncrocio, 4, 0);
   Ld_FFF38 = iCustom(Is_09CB0[Li_FFFD4], 0, "AA_OverLayChart", Is_09CB0[Li_FFFD0], numeroBarreOverlay, calcolaDistanzaDaUltimoIncrocio, 5, 0);
   Gi_0001F = periodoCorrelazione;
   if (periodoCorrelazione <= numeroBarreOverlay) { 
   Gi_00020 = numeroBarreOverlay;
   } 
   else { 
   Gi_00020 = Gi_0001F;
   } 
   if (Li_FFF98 >= Gi_00020) { 
   Gi_00020 = periodoCorrelazione;
   if (periodoCorrelazione <= numeroBarreOverlay) { 
   Gi_00021 = numeroBarreOverlay;
   } 
   else { 
   Gi_00021 = Gi_00020;
   } 
   if (Li_FFF60 >= Gi_00021 && (Ld_FFF40 != 0) && (Ld_FFF48 != 0) && (Ld_FFF48 != 2147483647)) { 
   Gl_00022 = iTime(Is_09CB0[Li_FFFD4], 0, 0);
   Il_0B0DC[Li_FFFD8] = Gl_00022;
   Gl_00024 = iTime(Is_09CB0[Li_FFFD0], 0, 0);
   Il_0D050[Li_FFFD8] = Gl_00024;
   if (Li_FFFD0 >= ArraySize(Input_Struct_00009CE4)) return;

   Input_Struct_00009CE4[Li_FFFD8].m_40 = Ld_FFF40;
   Input_Struct_00009CE4[Li_FFFD8].m_48 = Ld_FFF38;
   Input_Struct_00009CE4[Li_FFFD8].m_56 = Ld_FFF48;
   Input_Struct_00009CE4[Li_FFFD8].m_68 = Ld_FFF9C[1];

   Input_Struct_00009CE4[Li_FFFD8].m_76 = Ld_FFF50;
   tmp_str00017 = Is_09CB0[Li_FFFD0];
   tmp_str0001B = Is_09CB0[Li_FFFD4];
   if ((iCustom(tmp_str0001B, 0, "AA_SpreadRatio_1.1", tmp_str00017, ea, periodoBollinger, deviazioneStandard, 4, 0) != 0)) { 
   tmp_str0001D = Is_09CB0[Li_FFFD0];
   tmp_str0001F = Is_09CB0[Li_FFFD4];
   Gb_00030 = (iCustom(tmp_str0001F, 0, "AA_SpreadRatio_1.1", tmp_str0001D, ea, periodoBollinger, deviazioneStandard, 4, 0) != 2147483647);
   } 
   Input_Struct_00009CE4[Li_FFFD8].m_85 = Gb_00030;
   tmp_str00021 = Is_09CB0[Li_FFFD0];
   tmp_str00023 = Is_09CB0[Li_FFFD4];

   if ((iCustom(tmp_str00023, 0, "AA_SpreadRatio_1.1", tmp_str00021, ea, periodoBollinger, deviazioneStandard, 5, 0) != 0)) { 
   tmp_str00025 = Is_09CB0[Li_FFFD0];
   tmp_str00027 = Is_09CB0[Li_FFFD4];
   Gb_00037 = (iCustom(tmp_str00027, 0, "AA_SpreadRatio_1.1", tmp_str00025, ea, periodoBollinger, deviazioneStandard, 5, 0) != 2147483647);
   } 
   Input_Struct_00009CE4[Li_FFFD8].m_86 = Gb_00037;
   if ((Input_Struct_00009CE4[Li_FFFD8].m_40 < valoreOverlayPerIngresso)) { 
   Input_Struct_00009CE4[Li_FFFD8].m_84 = true;
   } 
   Li_FFF34 = 1315860;
   if ((Ld_FFF50 >= Ld_FFF9C[1])) { 
   tmp_str0002D = "+" + Is_09CB0[Li_FFFD4];
   } 
   else { 
   tmp_str0002F = "-" + Is_09CB0[Li_FFFD4];
   tmp_str0002D = tmp_str0002F;
   } 
   Ls_FFF28 = tmp_str0002D;
   if ((Ld_FFF50 >= Ld_FFF9C[1])) { 
   tmp_str00031 = "-" + Is_09CB0[Li_FFFD0];
   } 
   else { 
   tmp_str00034 = "+" + Is_09CB0[Li_FFFD0];
   tmp_str00031 = tmp_str00034;
   } 
   Ls_FFF18 = tmp_str00031;

   if ((Ld_FFF50 < Ld_FFF9C[1])) { 
   Gd_0004A = ((100 - Ld_FFF40) * 2.5);
   Li_FFF14 = (int)(255 - Gd_0004A);
   tmp_str00035 = IntegerToString(Li_FFF14, 0, 32);
   tmp_str00035 = tmp_str00035 + ",0,0";
   returned_i = StringToColor(tmp_str00035);
   Li_FFF34 = returned_i;
   } 

   if ((Ld_FFF50 >= Ld_FFF9C[1])) { 

   Gd_0004E = ((100 - Ld_FFF40) * 2);
   Li_FFF10 = (int)(200 - Ld_FFF40);
   tmp_str0003A = "0," + IntegerToString(Li_FFF10, 0, 32);
   tmp_str0003A = tmp_str0003A + ",0";
   returned_i = StringToColor(tmp_str0003A);
   Li_FFF34 = returned_i;
   } 
   if (FuncArg_Boolean_00000000) { 
   tmp_str0003B = " ";
   tmp_str0003D = Is_09CA0 + "_";
   tmp_str0003D = tmp_str0003D + Is_09CB0[Li_FFFD4];
   tmp_str0003D = tmp_str0003D + "-";
   tmp_str0003D = tmp_str0003D + Is_09CB0[Li_FFFD0];
   tmp_str0003D = tmp_str0003D + "_DatiY";
   tmp_str00040 = tmp_str0003D;
   if (ObjectFind(tmp_str00040) < 0) {
   ObjectCreate(0, tmp_str00040, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00053 = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00040, 102, Gi_00053);
   ObjectSetInteger(0, tmp_str00040, 101, 0);
   Gi_00053 = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00040, 103, Gi_00053);
   Gi_00053 = (int)(Li_FFFFC * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00040, 1019, Gi_00053);
   Gi_00053 = (int)(Li_FFFF8 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00040, 1020, Gi_00053);
   ObjectSetString(0, tmp_str00040, 999, tmp_str0003B);
   ObjectSetInteger(0, tmp_str00040, 6, 16777215);
   ObjectSetInteger(0, tmp_str00040, 1025, Li_FFF34);
   ObjectSetInteger(0, tmp_str00040, 1035, Li_FFF34);
   ObjectSetInteger(0, tmp_str00040, 1029, 1);
   ObjectSetInteger(0, tmp_str00040, 208, 1);
   ObjectSetInteger(0, tmp_str00040, 1018, 0);
   ObjectSetInteger(0, tmp_str00040, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00040, 9, 0);
   ObjectSetInteger(0, tmp_str00040, 1000, 0);
   Gi_00054 = Li_FFFE8 + 10;
   tmp_str00043 = DoubleToString(Ld_FFF40, 0);
   tmp_str00043 = tmp_str00043 + "%";
   tmp_str00043 = tmp_str00043 + " ";
   tmp_str00043 = tmp_str00043 + DoubleToString(Ld_FFF38, 0);
   tmp_str00044 = tmp_str00043;
   tmp_str00046 = Is_09CA0 + "_";
   tmp_str00046 = tmp_str00046 + Is_09CB0[Li_FFFD4];
   tmp_str00046 = tmp_str00046 + "-";
   tmp_str00046 = tmp_str00046 + Is_09CB0[Li_FFFD0];
   tmp_str00046 = tmp_str00046 + "_VAL";
   tmp_str00047 = tmp_str00046;
   if (ObjectFind(tmp_str00047) < 0) {
   ObjectCreate(0, tmp_str00047, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(tmp_str00047, tmp_str00044, (grandezzaFont + 2), "Dubai", 16777215);
   ObjectSet(tmp_str00047, OBJPROP_CORNER, 0);
   Gi_0005A = (int)(Gi_00054 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00047, OBJPROP_XDISTANCE, Gi_0005A);
   Gi_0005A = (int)(Li_FFFEC * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00047, OBJPROP_YDISTANCE, Gi_0005A);
   ObjectSetInteger(0, tmp_str00047, 1011, 0);
   ObjectSetInteger(0, tmp_str00047, 1000, 0);
   Gi_0005A = Li_FFFEC + 5;
   Gi_0005B = Li_FFFE8 + 15;
   
   tmp_str00048 = DoubleToString(Ld_FFF40, 0);
   tmp_str00048 = tmp_str00048 + "%";
   tmp_str00048 = tmp_str00048 + " " ;
   tmp_str00048 = tmp_str00048 + DoubleToString(Ld_FFF38, 0);
   tmp_str0004B = tmp_str00048;
   tmp_str0004D = Is_09CA0 + "_";
   tmp_str0004D = tmp_str0004D + Is_09CB0[Li_FFFD4];
   tmp_str0004D = tmp_str0004D + "-";
   tmp_str0004D = tmp_str0004D + Is_09CB0[Li_FFFD0];
   tmp_str0004D = tmp_str0004D + "_VAL2";
   tmp_str00050 = tmp_str0004D;
   if (ObjectFind(tmp_str00050) < 0) {
   ObjectCreate(0, tmp_str00050, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(tmp_str00050, tmp_str0004B, grandezzaFont, "Dubai", 16777215);
   ObjectSet(tmp_str00050, OBJPROP_CORNER, 0);
   Gi_00060 = (int)(Gi_0005B * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00050, OBJPROP_XDISTANCE, Gi_00060);
   Gi_00060 = (int)(Gi_0005A * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00050, OBJPROP_YDISTANCE, Gi_00060);
   ObjectSetInteger(0, tmp_str00050, 1011, 0);
   ObjectSetInteger(0, tmp_str00050, 1000, 0);
   Gi_00061 = Li_FFFEC + 20;
   tmp_str00051 = Ls_FFF28 + " " ;
   tmp_str00051 = tmp_str00051 + Ls_FFF18;
   
   tmp_str00053 = Is_09CA0 + "_";
   tmp_str00053 = tmp_str00053 + Is_09CB0[Li_FFFD4];
   tmp_str00054 = listaSpreadDaNonTradare3;
   tmp_str00053 = tmp_str00053 + "-";
   tmp_str00053 = tmp_str00053 + Is_09CB0[Li_FFFD0];
   tmp_str00053 = tmp_str00053 + "_Dir";
   tmp_str00055 = tmp_str00053;
   if (ObjectFind(tmp_str00055) < 0) {
   ObjectCreate(0, tmp_str00055, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(tmp_str00055, tmp_str00051, (grandezzaFont - 1), "Dubai", 16777215);
   ObjectSet(tmp_str00055, OBJPROP_CORNER, 0);
   Gi_00060 = (int)(Li_FFFE8 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00055, OBJPROP_XDISTANCE, Gi_00060);
   Gi_00060 = (int)(Gi_00061 * moltiplicatoreGrafiche);
   ObjectSet(tmp_str00055, OBJPROP_YDISTANCE, Gi_00060);
   ObjectSetInteger(0, tmp_str00055, 1011, 0);
   ObjectSetInteger(0, tmp_str00055, 1000, 0);
   }}} 
   Li_FFFE8 = Li_FFFE8 + Li_FFFE4;
   Li_FFFD8 = Li_FFFD8 + 1;
   ChartRedraw(0);
   ArrayFree(Ld_FFF64);
   ArrayFree(Ld_FFF9C);
   }}} 
   Li_FFFD0 = Li_FFFD0 + 1;
   } while (Li_FFFD0 < ArraySize(Is_09CB0)); 
   } 
   Li_FFFE8 = deltaXIniziale + 90;
   Li_FFFEC = Li_FFFEC + Li_FFFE0;
   Li_FFFD4 = Li_FFFD4 + 1;
   } while (Li_FFFD4 < ArraySize(Is_09CB0)); 
   } 
   Coppia Local_Struct_FFFFFEDC[];
   ArrayResize(Local_Struct_FFFFFEDC, ArraySize(Input_Struct_00009CE4), 0);
   Li_FFED8 = 0;
   if (ArraySize(Input_Struct_00009CE4) > 0) { 
   do { 
   Local_Struct_FFFFFEDC[Li_FFED8].m_16 = Input_Struct_00009CE4[Li_FFED8].m_16;
   Local_Struct_FFFFFEDC[Li_FFED8].m_28 = Input_Struct_00009CE4[Li_FFED8].m_28;
   Local_Struct_FFFFFEDC[Li_FFED8].m_40 = Input_Struct_00009CE4[Li_FFED8].m_40;
   Local_Struct_FFFFFEDC[Li_FFED8].m_48 = Input_Struct_00009CE4[Li_FFED8].m_48;
   Local_Struct_FFFFFEDC[Li_FFED8].m_56 = Input_Struct_00009CE4[Li_FFED8].m_56;
   Local_Struct_FFFFFEDC[Li_FFED8].m_64 = Input_Struct_00009CE4[Li_FFED8].m_64;
   Local_Struct_FFFFFEDC[Li_FFED8].m_68 = Input_Struct_00009CE4[Li_FFED8].m_68;
   Local_Struct_FFFFFEDC[Li_FFED8].m_76 = Input_Struct_00009CE4[Li_FFED8].m_76;
   Local_Struct_FFFFFEDC[Li_FFED8].m_84 = Input_Struct_00009CE4[Li_FFED8].m_84;
   Local_Struct_FFFFFEDC[Li_FFED8].m_85 = Input_Struct_00009CE4[Li_FFED8].m_85;
   Local_Struct_FFFFFEDC[Li_FFED8].m_86 = Input_Struct_00009CE4[Li_FFED8].m_86;
   Li_FFED8 = Li_FFED8 + 1;
   } while (Li_FFED8 < ArraySize(Input_Struct_00009CE4)); 
   } 
   func_1065(Local_Struct_FFFFFEDC, 0, (ArraySize(Local_Struct_FFFFFEDC) - 1));
   ArrayResize(Input_Struct_00009D18, 0, 0);
   Li_FFED4 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Li_FFED4, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00065 = OrderMagicNumber();
   Gi_00066 = MagicInp + 1000;
   if (Gi_00065 < Gi_00066) { 
   Gi_00066 = OrderMagicNumber();

   Gi_0006A = 0;
   Gi_0006B = ArraySize(Input_Struct_00009D18);
   Gb_0006C = false;
   if (Gi_0006A < Gi_0006B) {
   do { 
   if (Input_Struct_00009D18[Gi_0006A].m_64 == Gi_00066) {
   Gb_0006C = true;
   break;
   }
   Gi_0006A = Gi_0006A + 1;
   Gi_0006D = ArraySize(Input_Struct_00009D18);
   } while (Gi_0006A < Gi_0006D); 
   }
   
   if (Gb_0006C != true) { 
   Gi_0006D = OrderMagicNumber();
   Gi_00071 = 0;
   if (Gi_00071 < ArraySize(Input_Struct_00009CE4)) { 
   do { 
   if (Input_Struct_00009CE4[Gi_00071].m_64 == Gi_0006D) { 
   Gi_00072 = ArraySize(Input_Struct_00009D18);
   ArrayResize(Input_Struct_00009D18, (Gi_00072 + 1), 0);
   Gi_00073 = ArraySize(Input_Struct_00009D18);
   Gi_00073 = Gi_00073 - 1;
   Input_Struct_00009D18[Gi_00073].m_16 = Input_Struct_00009CE4[Gi_00071].m_16;
   Gi_00075 = ArraySize(Input_Struct_00009D18);
   Gi_00075 = Gi_00075 - 1;
   Input_Struct_00009D18[Gi_00075].m_28 = Input_Struct_00009CE4[Gi_00071].m_28;
   Gi_00077 = ArraySize(Input_Struct_00009D18);
   Gi_00077 = Gi_00077 - 1;
   Input_Struct_00009D18[Gi_00077].m_64 = Input_Struct_00009CE4[Gi_00071].m_64;
   Gi_00079 = ArraySize(Input_Struct_00009D18);
   Gi_00079 = Gi_00079 - 1;
   Input_Struct_00009D18[Gi_00079].m_56 = Input_Struct_00009CE4[Gi_00071].m_56;
   Gi_0007B = ArraySize(Input_Struct_00009D18);
   Gi_0007B = Gi_0007B - 1;
   Input_Struct_00009D18[Gi_0007B].m_40 = Input_Struct_00009CE4[Gi_00071].m_40;
   Gi_0007D = ArraySize(Input_Struct_00009D18);
   Gi_0007D = Gi_0007D - 1;
   Input_Struct_00009D18[Gi_0007D].m_48 = Input_Struct_00009CE4[Gi_00071].m_48;
   Gi_0007F = ArraySize(Input_Struct_00009D18);
   Gi_0007F = Gi_0007F - 1;
   Input_Struct_00009D18[Gi_0007F].m_68 = Input_Struct_00009CE4[Gi_00071].m_68;
   Gi_00081 = ArraySize(Input_Struct_00009D18);
   Gi_00081 = Gi_00081 - 1;
   Input_Struct_00009D18[Gi_00081].m_76 = Input_Struct_00009CE4[Gi_00071].m_76;
   Gi_00083 = ArraySize(Input_Struct_00009D18);
   Gi_00083 = Gi_00083 - 1;
   Input_Struct_00009D18[Gi_00083].m_84 = Input_Struct_00009CE4[Gi_00071].m_84;
   break; 
   } 
   Gi_00071 = Gi_00071 + 1;
   } while (Gi_00071 < ArraySize(Input_Struct_00009CE4)); 
   }}}} 
   Li_FFED4 = Li_FFED4 + 1;
   } while (Li_FFED4 < OrdersTotal()); 
   } 
   Ls_FFEC8 = "";
   Li_FFEC4 = 0;
   if (ArraySize(Local_Struct_FFFFFEDC) > 0) { 
   do { 
   tmp_str00059 = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str0005A = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   Gi_00088 = 0;
   Gi_00089 = ArraySize(Input_Struct_00009D18);
   Gb_0008D = false;
   if (Gi_00088 < Gi_00089) {
   do { 
   if (Input_Struct_00009D18[Gi_00088].m_16 == tmp_str0005A
   || Input_Struct_00009D18[Gi_00088].m_16 == tmp_str00059) {
   
   if (Input_Struct_00009D18[Gi_00088].m_28 == tmp_str0005A 
   || Input_Struct_00009D18[Gi_00088].m_28 == tmp_str00059) {
   
   Gb_0008D = true;
   break;
   }}
   Gi_00088 = Gi_00088 + 1;
   Gi_0008E = ArraySize(Input_Struct_00009D18);
   } while (Gi_00088 < Gi_0008E); 
   }
   
   if (Gb_0008D != true) { 
   tmp_str0005C = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str0005D = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   if (nonTradareCoppieCorrelate != true) { 
   Gb_00090 = true;
   } 
   else { 
   tmp_str0005E = tmp_str0005D;
   tmp_str00060 = "";
   tmp_str00063 = tmp_str0005C;
   tmp_str00067 = _Symbol;
   tmp_str00068 = orarioOperativita2;
   tmp_str00069 = tmp_str0005C;
   
   if (tmp_str0005E == tmp_str00063 || tmp_str00060 == "") { 
   
   Gb_00090 = false;
   } 
   else { 
   Gb_00090 = true;
   }} 
   if (Gb_00090) { 
   tmp_str00069 = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str0006A = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   if (func_1089(tmp_str0006A, tmp_str00069)) { 
   tmp_str0006B = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str0006C = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   if (tradareSoloCoppieCorrelate != true) { 
   Gb_00095 = true;
   } 
   else { 
   
   tmp_str0006D = tmp_str0006C;
   tmp_str00070 = "";
   tmp_str00073 = tmp_str0006B;
   if (tmp_str0006D == tmp_str00073 || tmp_str00070 == "") { 
   
   Gb_00095 = true;
   } 
   else { 
   Gb_00095 = false;
   }} 
   tmp_str00078 = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str00079 = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   if (Gb_00095 || func_1090(tmp_str00079, tmp_str00078)) {
   
   if ((Local_Struct_FFFFFEDC[Li_FFEC4].m_40 >= valoreOverlayPerIngresso) 
   && (Local_Struct_FFFFFEDC[Li_FFEC4].m_48 >= valorePuntiOverlayPerIngresso)) { 
   
   Gd_0009C = valoreCorrelazioneNegativaPerIngesso;
   Gd_0009C = -Gd_0009C;
   if (utilizzaFiltroCorrelazionePerIngresso == false
   || (valoreCorrelazionePositivaPerIngesso != 0 && Local_Struct_FFFFFEDC[Li_FFEC4].m_56 >= valoreCorrelazionePositivaPerIngesso)
   || (valoreCorrelazioneNegativaPerIngesso != 0 && Local_Struct_FFFFFEDC[Li_FFEC4].m_56 <= Gd_0009C)) {
   
   if (ArraySize(Input_Struct_00009D18) >= numeroMassimoCoppieOperative) break; 
   ArrayResize(Input_Struct_00009D18, (ArraySize(Input_Struct_00009D18) + 1), 0);
   Gi_0009D = ArraySize(Input_Struct_00009D18) - 1;
   Gi_0009E = Gi_0009D;
   Gi_0009F = Gi_0009D;
   Gi_000A0 = Gi_0009D;
   Gi_000A1 = Gi_0009D;
   Gi_000A2 = Gi_0009D;
   Gi_000A3 = Gi_0009D;
   Gi_000A4 = Gi_0009D;
   Gi_000A5 = Gi_0009D;
   Gi_000A6 = Gi_0009D;
   Gi_000A7 = Gi_0009D;
   Input_Struct_00009D18[Gi_0009D].m_16 = Local_Struct_FFFFFEDC[Li_FFEC4].m_16;
   Gi_000A9 = Gi_000A7;
   Input_Struct_00009D18[Gi_000A7].m_28 = Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   Gi_000AB = Gi_000A6;
   Input_Struct_00009D18[Gi_000A6].m_64 = Local_Struct_FFFFFEDC[Li_FFEC4].m_64;
   Gi_000AD = Gi_000A5;
   Input_Struct_00009D18[Gi_000A5].m_56 = Local_Struct_FFFFFEDC[Li_FFEC4].m_56;
   Gi_000AF = Gi_000A4;
   Input_Struct_00009D18[Gi_000A4].m_40 = Local_Struct_FFFFFEDC[Li_FFEC4].m_40;
   Gi_000B1 = Gi_000A3;
   Input_Struct_00009D18[Gi_000A3].m_48 = Local_Struct_FFFFFEDC[Li_FFEC4].m_48;
   Gi_000B3 = Gi_000A2;
   Input_Struct_00009D18[Gi_000A2].m_68 = Local_Struct_FFFFFEDC[Li_FFEC4].m_68;
   Gi_000B5 = Gi_000A1;
   Input_Struct_00009D18[Gi_000A1].m_76 = Local_Struct_FFFFFEDC[Li_FFEC4].m_76;
   Gi_000B7 = Gi_000A0;
   Input_Struct_00009D18[Gi_000A0].m_84 = Local_Struct_FFFFFEDC[Li_FFEC4].m_84;
   Gi_000B9 = Gi_0009F;
   Input_Struct_00009D18[Gi_0009F].m_85 = Local_Struct_FFFFFEDC[Li_FFEC4].m_85;
   Gi_000BB = Gi_0009E;
   Input_Struct_00009D18[Gi_0009E].m_86 = Local_Struct_FFFFFEDC[Li_FFEC4].m_86;
   tmp_str0007C = Local_Struct_FFFFFEDC[Li_FFEC4].m_16 + " ";
   tmp_str0007C = tmp_str0007C + Local_Struct_FFFFFEDC[Li_FFEC4].m_28;
   tmp_str0007C = tmp_str0007C + tmp_str0007C;
   tmp_str0007E = (string)Local_Struct_FFFFFEDC[Li_FFEC4].m_40;
   tmp_str0007C = tmp_str0007C + tmp_str0007E;
   tmp_str0007C = tmp_str0007C + " ";
   tmp_str0007E = (string)Local_Struct_FFFFFEDC[Li_FFEC4].m_56;
   tmp_str0007C = tmp_str0007C + tmp_str0007E;
   tmp_str0007C = tmp_str0007C + " ";
   tmp_str0007F = (string)Local_Struct_FFFFFEDC[Li_FFEC4].m_64;
   tmp_str0007C = tmp_str0007C + tmp_str0007F;
   tmp_str0007C = tmp_str0007C + " ";
   Ls_FFEC8 = Ls_FFEC8 + tmp_str0007C;
   }}}}}} 
   Li_FFEC4 = Li_FFEC4 + 1;
   } while (Li_FFEC4 < ArraySize(Local_Struct_FFFFFEDC)); 
   } 
   
   ArrayFree(Local_Struct_FFFFFEDC);
}

void func_1064(Coppia &FuncArg_Struct_00000000[], int Fa_i_01, int Fa_i_02)
{
   int Li_FFFFC;
   int Li_FFFF8;
   int Li_FFFF4;
   int Li_FFFF0;
   int Li_FFFB8;


   Li_FFFFC = Fa_i_02;
   Li_FFFF8 = Fa_i_01;
   Li_FFFF4 = Li_FFFFC + 1;
   Li_FFFF0 = 0;
   Coppia Local_Struct_FFFFFFBC[];
   ArrayResize(Local_Struct_FFFFFFBC, ArraySize(FuncArg_Struct_00000000), 0);
   if (Li_FFFF8 <= Li_FFFFC && Li_FFFF4 <= Fa_i_02) { 
   do { 
   if ((FuncArg_Struct_00000000[Li_FFFF8].m_40 >= FuncArg_Struct_00000000[Li_FFFF4].m_40)) { 
   Gi_00005 = Li_FFFF8;
   Li_FFFF8 = Li_FFFF8 + 1;
   Gi_00006 = Li_FFFF0;
   Li_FFFF0 = Li_FFFF0 + 1;
   Local_Struct_FFFFFFBC[Gi_00006].m_16 = FuncArg_Struct_00000000[Gi_00005].m_16;
   Local_Struct_FFFFFFBC[Gi_00006].m_28 = FuncArg_Struct_00000000[Gi_00005].m_28;
   Local_Struct_FFFFFFBC[Gi_00006].m_40 = FuncArg_Struct_00000000[Gi_00005].m_40;
   Local_Struct_FFFFFFBC[Gi_00006].m_48 = FuncArg_Struct_00000000[Gi_00005].m_48;
   Local_Struct_FFFFFFBC[Gi_00006].m_56 = FuncArg_Struct_00000000[Gi_00005].m_56;
   Local_Struct_FFFFFFBC[Gi_00006].m_64 = FuncArg_Struct_00000000[Gi_00005].m_64;
   Local_Struct_FFFFFFBC[Gi_00006].m_68 = FuncArg_Struct_00000000[Gi_00005].m_68;
   Local_Struct_FFFFFFBC[Gi_00006].m_76 = FuncArg_Struct_00000000[Gi_00005].m_76;
   Local_Struct_FFFFFFBC[Gi_00006].m_84 = FuncArg_Struct_00000000[Gi_00005].m_84;
   Local_Struct_FFFFFFBC[Gi_00006].m_85 = FuncArg_Struct_00000000[Gi_00005].m_85;
   Local_Struct_FFFFFFBC[Gi_00006].m_86 = FuncArg_Struct_00000000[Gi_00005].m_86;
   } 
   else { 
   Gi_00007 = Li_FFFF4;
   Li_FFFF4 = Li_FFFF4 + 1;
   Gi_00008 = Li_FFFF0;
   Li_FFFF0 = Li_FFFF0 + 1;
   Local_Struct_FFFFFFBC[Gi_00008].m_16 = FuncArg_Struct_00000000[Gi_00007].m_16;
   Local_Struct_FFFFFFBC[Gi_00008].m_28 = FuncArg_Struct_00000000[Gi_00007].m_28;
   Local_Struct_FFFFFFBC[Gi_00008].m_40 = FuncArg_Struct_00000000[Gi_00007].m_40;
   Local_Struct_FFFFFFBC[Gi_00008].m_48 = FuncArg_Struct_00000000[Gi_00007].m_48;
   Local_Struct_FFFFFFBC[Gi_00008].m_56 = FuncArg_Struct_00000000[Gi_00007].m_56;
   Local_Struct_FFFFFFBC[Gi_00008].m_64 = FuncArg_Struct_00000000[Gi_00007].m_64;
   Local_Struct_FFFFFFBC[Gi_00008].m_68 = FuncArg_Struct_00000000[Gi_00007].m_68;
   Local_Struct_FFFFFFBC[Gi_00008].m_76 = FuncArg_Struct_00000000[Gi_00007].m_76;
   Local_Struct_FFFFFFBC[Gi_00008].m_84 = FuncArg_Struct_00000000[Gi_00007].m_84;
   Local_Struct_FFFFFFBC[Gi_00008].m_85 = FuncArg_Struct_00000000[Gi_00007].m_85;
   Local_Struct_FFFFFFBC[Gi_00008].m_86 = FuncArg_Struct_00000000[Gi_00007].m_86;
   } 
   if (Li_FFFF8 > Li_FFFFC) break; 
   } while (Li_FFFF4 <= Fa_i_02); 
   } 
   if (Li_FFFF8 <= Li_FFFFC) { 
   do { 
   Gi_00009 = Li_FFFF8;
   Li_FFFF8 = Li_FFFF8 + 1;
   Gi_0000A = Li_FFFF0;
   Li_FFFF0 = Li_FFFF0 + 1;
   Local_Struct_FFFFFFBC[Gi_0000A].m_16 = FuncArg_Struct_00000000[Gi_00009].m_16;
   Local_Struct_FFFFFFBC[Gi_0000A].m_28 = FuncArg_Struct_00000000[Gi_00009].m_28;
   Local_Struct_FFFFFFBC[Gi_0000A].m_40 = FuncArg_Struct_00000000[Gi_00009].m_40;
   Local_Struct_FFFFFFBC[Gi_0000A].m_48 = FuncArg_Struct_00000000[Gi_00009].m_48;
   Local_Struct_FFFFFFBC[Gi_0000A].m_56 = FuncArg_Struct_00000000[Gi_00009].m_56;
   Local_Struct_FFFFFFBC[Gi_0000A].m_64 = FuncArg_Struct_00000000[Gi_00009].m_64;
   Local_Struct_FFFFFFBC[Gi_0000A].m_68 = FuncArg_Struct_00000000[Gi_00009].m_68;
   Local_Struct_FFFFFFBC[Gi_0000A].m_76 = FuncArg_Struct_00000000[Gi_00009].m_76;
   Local_Struct_FFFFFFBC[Gi_0000A].m_84 = FuncArg_Struct_00000000[Gi_00009].m_84;
   Local_Struct_FFFFFFBC[Gi_0000A].m_85 = FuncArg_Struct_00000000[Gi_00009].m_85;
   Local_Struct_FFFFFFBC[Gi_0000A].m_86 = FuncArg_Struct_00000000[Gi_00009].m_86;
   } while (Li_FFFF8 <= Li_FFFFC); 
   } 
   if (Li_FFFF4 <= Fa_i_02) { 
   do { 
   Gi_0000B = Li_FFFF4;
   Li_FFFF4 = Li_FFFF4 + 1;
   Gi_0000C = Li_FFFF0;
   Li_FFFF0 = Li_FFFF0 + 1;
   Local_Struct_FFFFFFBC[Gi_0000C].m_16 = FuncArg_Struct_00000000[Gi_0000B].m_16;
   Local_Struct_FFFFFFBC[Gi_0000C].m_28 = FuncArg_Struct_00000000[Gi_0000B].m_28;
   Local_Struct_FFFFFFBC[Gi_0000C].m_40 = FuncArg_Struct_00000000[Gi_0000B].m_40;
   Local_Struct_FFFFFFBC[Gi_0000C].m_48 = FuncArg_Struct_00000000[Gi_0000B].m_48;
   Local_Struct_FFFFFFBC[Gi_0000C].m_56 = FuncArg_Struct_00000000[Gi_0000B].m_56;
   Local_Struct_FFFFFFBC[Gi_0000C].m_64 = FuncArg_Struct_00000000[Gi_0000B].m_64;
   Local_Struct_FFFFFFBC[Gi_0000C].m_68 = FuncArg_Struct_00000000[Gi_0000B].m_68;
   Local_Struct_FFFFFFBC[Gi_0000C].m_76 = FuncArg_Struct_00000000[Gi_0000B].m_76;
   Local_Struct_FFFFFFBC[Gi_0000C].m_84 = FuncArg_Struct_00000000[Gi_0000B].m_84;
   Local_Struct_FFFFFFBC[Gi_0000C].m_85 = FuncArg_Struct_00000000[Gi_0000B].m_85;
   Local_Struct_FFFFFFBC[Gi_0000C].m_86 = FuncArg_Struct_00000000[Gi_0000B].m_86;
   } while (Li_FFFF4 <= Fa_i_02); 
   } 
   Li_FFFB8 = 0;
   if (Li_FFFB8 <= Fa_i_02) { 
   do { 
   FuncArg_Struct_00000000[Li_FFFB8].m_16 = Local_Struct_FFFFFFBC[Li_FFFB8].m_16;
   FuncArg_Struct_00000000[Li_FFFB8].m_28 = Local_Struct_FFFFFFBC[Li_FFFB8].m_28;
   FuncArg_Struct_00000000[Li_FFFB8].m_40 = Local_Struct_FFFFFFBC[Li_FFFB8].m_40;
   FuncArg_Struct_00000000[Li_FFFB8].m_48 = Local_Struct_FFFFFFBC[Li_FFFB8].m_48;
   FuncArg_Struct_00000000[Li_FFFB8].m_56 = Local_Struct_FFFFFFBC[Li_FFFB8].m_56;
   FuncArg_Struct_00000000[Li_FFFB8].m_64 = Local_Struct_FFFFFFBC[Li_FFFB8].m_64;
   FuncArg_Struct_00000000[Li_FFFB8].m_68 = Local_Struct_FFFFFFBC[Li_FFFB8].m_68;
   FuncArg_Struct_00000000[Li_FFFB8].m_76 = Local_Struct_FFFFFFBC[Li_FFFB8].m_76;
   FuncArg_Struct_00000000[Li_FFFB8].m_84 = Local_Struct_FFFFFFBC[Li_FFFB8].m_84;
   FuncArg_Struct_00000000[Li_FFFB8].m_85 = Local_Struct_FFFFFFBC[Li_FFFB8].m_85;
   FuncArg_Struct_00000000[Li_FFFB8].m_86 = Local_Struct_FFFFFFBC[Li_FFFB8].m_86;
   Li_FFFB8 = Li_FFFB8 + 1;
   } while (Li_FFFB8 <= Fa_i_02); 
   } 
   ArrayFree(Local_Struct_FFFFFFBC);
}

void func_1065(Coppia &FuncArg_Address_00000000[], int Fa_i_01, int Fa_i_02)
{
   string tmp_str00000;
   int Li_FFFFC;
   if (Fa_i_01 >= Fa_i_02) return; 
   Gi_00000 = Fa_i_02;
   Li_FFFFC = Gi_00000;
   //func_1065(FuncArg_Address_00000000, Fa_i_01, Gi_00000);
   func_1065(FuncArg_Address_00000000, (Li_FFFFC + 1), Fa_i_02);
   func_1064(FuncArg_Address_00000000, Fa_i_01, Fa_i_02);
   
}

void func_1069()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   int Li_FFFFC;

   Li_FFFFC = OrdersTotal() - 1;
   if (Li_FFFFC < 0) return; 
   do { 
   if (OrderSelect(Li_FFFFC, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00000 = OrderMagicNumber();
   Gi_00001 = MagicInp + 1000;
   if (Gi_00000 < Gi_00001) { 

   Gi_00001 = StringFind(OrderComment(), "from");
   if (Gi_00001 < 0) { 
   Gi_00001 = OrderTicket();
   Gi_00002 = ArraySize(Is_0B074) - 1;
   Gi_00003 = Gi_00002;
   Gb_00006 = false;
   if (Gi_00002 >= 0) {
   do { 
   string Ls_FFFC8[];

   tmp_str00005 = Is_0B074[Gi_00003];
   Gst_00005 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00005, Gst_00005, Ls_FFFC8);
   if (ArraySize(Ls_FFFC8) >= 2 && Ls_FFFC8[0] == IntegerToString(Gi_00001, 0, 32)) {
   Gb_00006 = true;
   ArrayFree(Ls_FFFC8);
   break;
   }
   ArrayFree(Ls_FFFC8);
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   }
   
   if (Gb_00006 != true) { 
   tmp_str00009 = IntegerToString(MagicInp, 0, 32);
   tmp_str00009 = tmp_str00009 + " aggiungo ticket : ";
   tmp_str0000B = (string)OrderTicket();
   tmp_str00009 = tmp_str00009 + tmp_str0000B;
   tmp_str00009 = tmp_str00009 + " commento : ";
   tmp_str00009 = tmp_str00009 + OrderComment();
   Print(tmp_str00009);
   ArrayResize(Is_0B074, (ArraySize(Is_0B074) + 1), 0);
   tmp_str0000C = IntegerToString(OrderTicket(), 0, 32);
   tmp_str0000C = tmp_str0000C + ":";
   tmp_str0000C = tmp_str0000C + OrderComment();
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Is_0B074[Gi_00007] = tmp_str0000C;
   }}}} 
   Li_FFFFC = Li_FFFFC - 1;
   } while (Li_FFFFC >= 0); 
   
}

void func_1072(string Fa_s_00)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFDC;
   int Li_FFFD8;
   int Li_FFFD4;
   int Li_FFFD0;
   int Li_FFF98;
   bool Lb_FFF97;
   int Li_FFF90;

   Ls_FFFF0 = "";
   tmp_str00000 = Is_1CBF8;
   Gi_00000 = FileOpen(tmp_str00000, 4113);
   Gi_00002 = 10;
   Gi_00004 = 0;
   if (Gi_00000 == -1 && Gi_00004 < Gi_00002) { 
   do { 
   Sleep(100);
   Gi_00000 = FileOpen(tmp_str00000, 4113);
   Gi_00004 = Gi_00004 + 1;
   if (Gi_00000 != -1) break; 
   } while (Gi_00004 < Gi_00002); 
   } 
   if (Gi_00000 != -1) {
   tmp_str00002 = "";
   tmp_str00002 = FileReadString(Gi_00000, 0);
   FileClose(Gi_00000);
   if (tmp_str00002 != "") {
   tmp_str00003 = tmp_str00002;
   }
   else{
   tmp_str00003 = "VUOTO";
   }}
   else{
   tmp_str00003 = "NON CARICATO";
   }
   Ls_FFFE0 = tmp_str00003;
   tmp_str00006 = AccountCompany();
   tmp_str00007 = TerminalName();
   
   if (tmp_str00003 != "NON CARICATO") { 
   tmp_str00007 = eaOverlay;
   tmp_str00008 = commentoAggiuntivo;
   
   if (tmp_str00003 != "NULL") { 
   tmp_str00008 = ServerAddress();
   tmp_str00009 = TerminalCompany();
   
   if (tmp_str00003 != "VUOTO") { 
   Ls_FFFF0 = "";
   }}} 
   if (Ls_FFFF0 == "" && ArraySize(Is_0B074) == 0) { 
   return ;
   } 
   if (Ls_FFFF0 == "") { 
   tmp_str0000A = IntegerToString(MagicInp, 0, 32);
   tmp_str0000A = tmp_str0000A + " file non trovato";
   Print(tmp_str0000A);
   } 
   Li_FFFDC = FileOpen(Fa_s_00, 4114);
   Li_FFFD8 = 10;
   Li_FFFD4 = 0;
   if (Li_FFFDC == -1 && Li_FFFD4 < Li_FFFD8) { 
   do { 
   Sleep(100);
   Li_FFFDC = FileOpen(Fa_s_00, 4114);
   Li_FFFD4 = Li_FFFD4 + 1;
   if (Li_FFFDC != -1) break; 
   } while (Li_FFFD4 < Li_FFFD8); 
   } 
   if (Li_FFFDC != -1) { 
   if (Ls_FFFF0 == "" && ArraySize(Is_0B074) > 0) {
   tmp_str00010 = "Non c'è contenuto, scrivo per la prima volta";
   Print(tmp_str00010);
   Li_FFFD0 = 0;
   if (Li_FFFD0 < ArraySize(Is_0B074)) {
   do { 
   tmp_str00014 = Is_0B074[Li_FFFD0];
   tmp_str00014 = tmp_str00014 + ";";
   Ls_FFFF0 = Ls_FFFF0 + tmp_str00014;
   Li_FFFD0 = Li_FFFD0 + 1;
   } while (Li_FFFD0 < ArraySize(Is_0B074)); 
   }}
   else{
   if (Ls_FFFF0 != "") { 
   string Ls_FFF9C[];
   Gst_00008 = (short)StringGetCharacter(";", 0);
   StringSplit(Ls_FFFE0, Gst_00008, Ls_FFF9C);
   Li_FFF98 = 0;
   if (Gi_00008 < ArraySize(Is_0B074)) { 
   do { 
   Lb_FFF97 = false;
   Li_FFF90 = 0;
   if (Li_FFF90 < ArraySize(Ls_FFF9C)) { 
   do { 
   if (Ls_FFF9C[Li_FFF90] != "" && Ls_FFF9C[Li_FFF90] == Is_0B074[Li_FFF98]) { 
   Lb_FFF97 = true;
   break; 
   } 
   Li_FFF90 = Li_FFF90 + 1;
   } while (Li_FFF90 < ArraySize(Ls_FFF9C)); 
   } 
   if (Lb_FFF97 != true) { 
   tmp_str0001F = Is_0B074[Li_FFF98];
   tmp_str0001F = tmp_str0001F + ";";
   Ls_FFFF0 = Ls_FFFF0 + tmp_str0001F;
   tmp_str00020 = IntegerToString(MagicInp, 0, 32);
   tmp_str00020 = tmp_str00020 + " Aggiungo info cache : ";
   tmp_str00020 = tmp_str00020 + Is_0B074[Li_FFF98];
   Print(tmp_str00020);
   } 
   Li_FFF98 = Li_FFF98 + 1;
   } while (Li_FFF98 < ArraySize(Is_0B074)); 
   } 
   ArrayFree(Ls_FFF9C);
   }} 
   FileWrite(Li_FFFDC, Ls_FFFF0);
   FileClose(Li_FFFDC);
   return ;
   } 
   tmp_str00022 = IntegerToString(MagicInp, 0, 32);
   tmp_str00022 = tmp_str00022 + " Attendo caricamento informazioni ordini";
   Print(tmp_str00022);
   
}

bool func_1073()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   bool Lb_FFFFF;
   double Ld_FFFF0;
   int Li_FFFEC;
   double Ld_FFFE0;
   int Li_FFFDC;

   if ((massimoGainGiornaliero == 0)) { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   Ld_FFFF0 = 0;
   Li_FFFEC = OrdersTotal() - 1;
   if (Li_FFFEC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFEC, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00000 = OrderMagicNumber();
   Gi_00001 = MagicInp + 1000;
   if (Gi_00000 < Gi_00001) { 
   Gd_00001 = OrderProfit();
   Gd_00001 = (Gd_00001 + OrderCommission());
   Ld_FFFF0 = ((Gd_00001 + OrderSwap()) + Ld_FFFF0);
   }} 
   Li_FFFEC = Li_FFFEC - 1;
   } while (Li_FFFEC >= 0); 
   } 
   Ld_FFFE0 = 0;
   Li_FFFDC = HistoryTotal() - 1;
   if (Li_FFFDC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFDC, 0, 1) && OrderMagicNumber() >= MagicInp) { 
   Gi_00001 = OrderMagicNumber();
   Gi_00002 = MagicInp + 1000;
   if (Gi_00001 < Gi_00002) { 
   tmp_str00002 = TimeToString(OrderCloseTime(), 1);
   if (tmp_str00002 != TimeToString(TimeCurrent(), 1)) break; 
   Gd_00002 = OrderProfit();
   Gd_00002 = (Gd_00002 + OrderCommission());
   Ld_FFFE0 = ((Gd_00002 + OrderSwap()) + Ld_FFFE0);
   }} 
   Li_FFFDC = Li_FFFDC - 1;
   } while (Li_FFFDC >= 0); 
   } 
   if (((Ld_FFFE0 + Ld_FFFF0) < massimoGainGiornaliero)) return false; 
   tmp_str00003 = "Chiusura totale per massimo gain";
   Gi_00003 = OrdersTotal();
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00004 = OrderMagicNumber();
   Gi_00005 = MagicInp + 1000;
   if (Gi_00004 < Gi_00005) { 
   Gi_00006 = 0;
   if (Gi_00006 < 10) { 
   do { 
   RefreshRates();
   if (OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20, 255) != true) { 
   tmp_str00005 = "";
   tmp_str00006 = tmp_str00003;
   tmp_str00007 = "";
   tmp_str00008 = "";
   func_1050(MagicInp, tmp_str00008, tmp_str00007, tmp_str00006, tmp_str00005, GetLastError());
   } 
   else { 
   tmp_str00009 = "";
   tmp_str0000A = tmp_str00003;
   tmp_str0000B = "";
   tmp_str0000C = "";
   func_1052(MagicInp, tmp_str0000C, tmp_str0000B, tmp_str0000A, tmp_str00009);
   break; 
   } 
   Gi_00006 = Gi_00006 + 1;
   } while (Gi_00006 < 10); 
   }}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

bool func_1074()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   bool Lb_FFFFF;
   double Ld_FFFF0;
   int Li_FFFEC;
   double Ld_FFFE0;
   int Li_FFFDC;

   if ((massimoLossGiornaliero == 0)) { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   Ld_FFFF0 = 0;
   Li_FFFEC = OrdersTotal() - 1;
   if (Li_FFFEC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFEC, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00000 = OrderMagicNumber();
   Gi_00001 = MagicInp + 1000;
   if (Gi_00000 < Gi_00001) { 
   Gd_00001 = OrderProfit();
   Gd_00001 = (Gd_00001 + OrderCommission());
   Ld_FFFF0 = ((Gd_00001 + OrderSwap()) + Ld_FFFF0);
   }} 
   Li_FFFEC = Li_FFFEC - 1;
   } while (Li_FFFEC >= 0); 
   } 

   Ld_FFFE0 = 0;
   Li_FFFDC = HistoryTotal() - 1;
   if (Li_FFFDC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFDC, 0, 1) && OrderMagicNumber() >= MagicInp) { 
   Gi_00001 = OrderMagicNumber();
   Gi_00002 = MagicInp + 1000;
   if (Gi_00001 < Gi_00002) { 
   tmp_str00002 = TimeToString(OrderCloseTime(), 1);
   if (tmp_str00002 != TimeToString(TimeCurrent(), 1)) break; 
   Gd_00002 = OrderProfit();
   Gd_00002 = (Gd_00002 + OrderCommission());
   Ld_FFFE0 = ((Gd_00002 + OrderSwap()) + Ld_FFFE0);
   }} 
   Li_FFFDC = Li_FFFDC - 1;
   } while (Li_FFFDC >= 0); 
   } 
   Gd_00002 = (Ld_FFFE0 + Ld_FFFF0);
   Gd_00003 = -massimoLossGiornaliero;
   if ((Gd_00002 > Gd_00003)) return false; 
   tmp_str00003 = "Chiusura totale per massimo loss";
   Gi_00003 = OrdersTotal();
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00004 = OrderMagicNumber();
   Gi_00005 = MagicInp + 1000;
   if (Gi_00004 < Gi_00005) { 
   Gi_00006 = 0;
   if (Gi_00005 < 10) { 
   do { 
   RefreshRates();
   if (OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20, 255) != true) { 
   tmp_str00005 = "";
   tmp_str00006 = tmp_str00003;
   tmp_str00007 = "";
   tmp_str00008 = "";
   func_1050(MagicInp, tmp_str00008, tmp_str00007, tmp_str00006, tmp_str00005, GetLastError());
   } 
   else { 
   tmp_str00009 = "";
   tmp_str0000A = tmp_str00003;
   tmp_str0000B = "";
   tmp_str0000C = "";
   func_1052(MagicInp, tmp_str0000C, tmp_str0000B, tmp_str0000A, tmp_str00009);
   break; 
   } 
   Gi_00006 = Gi_00006 + 1;
   } while (Gi_00006 < 10); 
   }}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

bool func_1075(string Fa_s_00, string Fa_s_01, string Fa_s_02)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   int Li_FFFF8;
   int Li_FFFF4;
   string Ls_FFFE8;
   bool Lb_FFFFF;

   Li_FFFF8 = 0;
   Li_FFFF4 = OrdersTotal() - 1;
   if (Li_FFFF4 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFF4, 0, 0)) {
   if (OrderMagicNumber() == Ii_1D234) {
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   Ls_FFFE8 = OrderComment();

   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   Gi_00001 = (int)StringToInteger("");
   Gi_00002 = 0;
   Gi_00001 = 0;
   Gi_00003 = HistoryTotal() - 1;
   Gi_00004 = Gi_00003;
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00004, 0, 1)) { 
   Gl_00003 = OrderOpenTime();
   tmp_str00007 = IntegerToString(MagicInp, 0, 32);
   tmp_str00007 = tmp_str00007 + "_PMPtimeFlat";
   Gl_00005 = (datetime)(GlobalVariableGet(tmp_str00007) * 1000);
   if (Gl_00003 >= Gl_00005) { 
   Gi_00005 = StringFind(OrderComment(), "to #");
   if (Gi_00005 >= 0) { 
   Gi_00005 = (int)StringToInteger("");
   if (Gi_00005 == Gi_00001) { 
   Gi_00001 = OrderTicket();
   Gi_00002 = Gi_00001;
   }}}} 
   Gi_00004 = Gi_00004 - 1;
   } while (Gi_00004 >= 0); 
   } 
   Gi_00005 = Gi_00002;
   Gi_00006 = ArraySize(Is_0B074) - 1;
   Gi_00007 = Gi_00006;
   tmp_str00013 = "";
   if (Gi_00006 >= 0) {
   do { 
   string Ls_FFFB4[];
   tmp_str0000F = Is_0B074[Gi_00007];
   Gst_00009 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000F, Gst_00009, Ls_FFFB4);
   if (ArraySize(Ls_FFFB4) >= 2) {
   tmp_str00013 = (string)Gi_00005;
   if (Ls_FFFB4[0] == tmp_str00013) {
   tmp_str00013 = Ls_FFFB4[1];
   ArrayFree(Ls_FFFB4);
   break;
   }}
   ArrayFree(Ls_FFFB4);
   Gi_00007 = Gi_00007 - 1;
   } while (Gi_00007 >= 0); 
   }
   
   Ls_FFFE8 = tmp_str00013;
   if (tmp_str00013 == "") { 
   tmp_str00014 = "";
   tmp_str00017 = "ERRORE determinazione ordine, sistema sospeso PC " + tmp_str00013;
   tmp_str00016 = Fa_s_01;
   tmp_str00018 = Fa_s_00;
   func_1050(-1, tmp_str00018, tmp_str00016, tmp_str00017, tmp_str00014, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }} 
   if (Ls_FFFE8 == Fa_s_02) { 
   Li_FFFF8 = Li_FFFF8 + 1;
   } 
   }}}
   else{
   Print("Errore selezione ordine");
   Lb_FFFFF = true;
   return Lb_FFFFF;
   }
   Li_FFFF4 = Li_FFFF4 - 1;
   } while (Li_FFFF4 >= 0); 
   } 
   if (Li_FFFF8 < 2) return false; 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

void func_1076(int Fa_i_00, string Fa_s_01, string Fa_s_02)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   int Li_FFFFC;
   string Ls_FFFF0;
   int Li_FFFEC;
   int Li_FFFE8;
   int Li_FFFE4;
   int Li_FFFE0;

   if (Ii_09C84 == 0) return; 
   if (Ib_09C81) { 
   Li_FFFFC = OrdersTotal() - 1;
   if (Li_FFFFC < 0) return; 
   do { 
   if (OrderSelect(Li_FFFFC, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_01 || OrderSymbol() == Fa_s_02) { 
   
   Ls_FFFF0 = OrderComment();
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   Gi_00000 = (int)StringToInteger("");
   Gi_00001 = 0;
   Gi_00000 = 0;
   Gi_00002 = HistoryTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 1)) { 
   Gl_00002 = OrderOpenTime();
   tmp_str00008 = IntegerToString(MagicInp, 0, 32);
   tmp_str00008 = tmp_str00008 + "_PMPtimeFlat";
   Gl_00004 = (datetime)(GlobalVariableGet(tmp_str00008) * 1000);
   if (Gl_00002 >= Gl_00004) { 
   Gi_00004 = StringFind(OrderComment(), "to #");
   if (Gi_00004 >= 0) { 
   Gi_00004 = (int)StringToInteger("");
   if (Gi_00004 == Gi_00000) { 
   Gi_00000 = OrderTicket();
   Gi_00001 = Gi_00000;
   }}}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Gi_00004 = Gi_00001;
   Gi_00005 = ArraySize(Is_0B074) - 1;
   Gi_00006 = Gi_00005;
   tmp_str00014 = "";
   if (Gi_00005 >= 0) {
   do { 
   string Ls_FFFAC[];
   tmp_str00010 = Is_0B074[Gi_00006];
   Gst_00008 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00010, Gst_00008, Ls_FFFAC);
   if (ArraySize(Ls_FFFAC) >= 2) {
   tmp_str00014 = (string)Gi_00004;
   if (Ls_FFFAC[0] == tmp_str00014) {
   tmp_str00014 = Ls_FFFAC[1];
   ArrayFree(Ls_FFFAC);
   break;
   }}
   ArrayFree(Ls_FFFAC);
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   }
   
   Ls_FFFF0 = tmp_str00014;
   if (tmp_str00014 == "") { 
   tmp_str00015 = "";
   tmp_str00018 = "ERRORE determinazione ordine, sistema sospeso CPD  " + tmp_str00014;
   tmp_str00017 = Fa_s_02;
   tmp_str00019 = Fa_s_01;
   func_1050(-1, tmp_str00019, tmp_str00017, tmp_str00018, tmp_str00015, 0);
   Ib_1CED0 = true;
   return ;
   }} 
   if (OrderSelect(Li_FFFFC, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_01 || OrderSymbol() == Fa_s_02) { 
   
   Li_FFFEC = OrderTicket();
   Gl_0000A = TimeCurrent();
   Gl_0000A = Gl_0000A - OrderOpenTime();
   Gi_0000B = Ii_09C84 * 60;
   Gl_0000B = Gi_0000B;
   if (Gl_0000A >= Gl_0000B) { 
   tmp_str0001B = Ls_FFFF0;
   tmp_str0001C = Fa_s_02;
   tmp_str0001D = Fa_s_01;
   if (func_1075(tmp_str0001D, tmp_str0001C, tmp_str0001B) != true) { 
   tmp_str00020 = "Presente coppia " + Ls_FFFF0;
   Print(tmp_str00020);
   if (OrderSelect(Li_FFFFC, 0, 0) && OrderTicket() == Li_FFFEC) { 
   if (OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20, 255) != true) { 
   tmp_str0001F = "";
   tmp_str00023 = "Chiusura ordine per disallineamento posizioni";
   tmp_str00022 = Fa_s_02;
   tmp_str00024 = Fa_s_01;
   func_1050(Ii_1D234, tmp_str00024, tmp_str00022, tmp_str00023, tmp_str0001F, GetLastError());
   } 
   else { 
   tmp_str00025 = "";
   tmp_str00028 = "Chiusura ordine per disallineamento posizioni";
   tmp_str00027 = Fa_s_02;
   tmp_str00029 = Fa_s_01;
   func_1052(Ii_1D234, tmp_str00029, tmp_str00027, tmp_str00028, tmp_str00025);
   }}}}}}}} 
   Li_FFFFC = Li_FFFFC - 1;
   } while (Li_FFFFC >= 0); 
   return ;
   } 
   if (Il_1CF14[Fa_i_00] == iTime(Fa_s_01, 0, 0)) return; 
   Li_FFFE8 = 0;
   Li_FFFE4 = 0;
   Li_FFFE0 = OrdersTotal() - 1;
   if (Li_FFFE0 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFE0, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_01 || OrderSymbol() == Fa_s_02) { 
   
   Gl_00010 = TimeCurrent();
   Gl_00010 = Gl_00010 - OrderOpenTime();
   Gi_00011 = Ii_09C84 * 60;
   Gl_00011 = Gi_00011;
   if (Gl_00010 >= Gl_00011) { 
   if (OrderSymbol() == Fa_s_01) { 
   Li_FFFE8 = Li_FFFE8 + 1;
   } 
   if (OrderSymbol() == Fa_s_02) { 
   Li_FFFE4 = Li_FFFE4 + 1;
   }}}} 
   Li_FFFE0 = Li_FFFE0 - 1;
   } while (Li_FFFE0 >= 0); 
   } 
   if (Li_FFFE8 == Li_FFFE4) return; 
   tmp_str0002E = "Magic : " + IntegerToString(Ii_1D234, 0, 32);
   tmp_str0002E = tmp_str0002E + "Disallineamento operazioni : ";
   tmp_str0002E = tmp_str0002E + Fa_s_01;
   tmp_str0002E = tmp_str0002E + "/";
   tmp_str0002E = tmp_str0002E + Fa_s_02;
   tmp_str0002E = tmp_str0002E + " ";
   tmp_str00031 = (string)Li_FFFE8;
   tmp_str0002E = tmp_str0002E + tmp_str00031;
   tmp_str0002E = tmp_str0002E + "/";
   tmp_str00032 = (string)Li_FFFE4;
   tmp_str0002E = tmp_str0002E + tmp_str00032;
   Alert(tmp_str0002E);
   tmp_str00032 = IntegerToString(Ii_1D234, 0, 32);
   tmp_str00032 = tmp_str00032 + " disallineamento operazioni : ";
   tmp_str00032 = tmp_str00032 + Fa_s_01;
   tmp_str00032 = tmp_str00032 + "/";
   tmp_str00032 = tmp_str00032 + Fa_s_02;
   tmp_str00032 = tmp_str00032 + " ";
   tmp_str00036 = (string)Li_FFFE8;
   tmp_str00032 = tmp_str00032 + tmp_str00036;
   tmp_str00032 = tmp_str00032 + "/";
   tmp_str00037 = (string)Li_FFFE4;
   tmp_str00032 = tmp_str00032 + tmp_str00037;
   SendNotification(tmp_str00032);
   Gl_00014 = iTime(Fa_s_01, 0, 0);
   Il_1CF14[Fa_i_00] = Gl_00014;
   
}

bool func_1078(string Fa_s_00)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFF90;
   string Ls_FFF80;
   short Lst_FFF7E;
   int Li_FFF44;
   long Ll_FFF38;
   string Ls_FFF28;
   long Ll_FFF20;
   long Ll_FFF18;
   int Li_FFF14;
   bool Lb_FFFFF;

   Ls_FFFF0 = "";
   Ls_FFFE0 = "";
   Ls_FFFD0 = "";
   Ls_FFFF0 = Fa_s_00;
   string Ls_FFF9C[];
   Ls_FFF90 = Ls_FFFF0;
   Ls_FFF80 = "-";
   Lst_FFF7E = 0;
   string Ls_FFF48[];
   Lst_FFF7E = (short)StringGetCharacter(Ls_FFF80, 0);
   Gst_00000 = Lst_FFF7E;
   Li_FFF44 = StringSplit(Ls_FFF90, Gst_00000, Ls_FFF48);
   tmp_str00007 = Ls_FFF48[0];
   Ls_FFFE0 = Ls_FFF48[0];
   tmp_str00009 = Ls_FFF48[1];
   Ls_FFFD0 = Ls_FFF48[1];
   if (Ls_FFFD0 == "00:00:00"){
   Ls_FFFD0 = "23:59:59";
   } 
   Ll_FFF38 = TimeCurrent();
   Ls_FFF28 = TimeToString(Ll_FFF38, 1);
   tmp_str0000B = Ls_FFF28 + " ";
   tmp_str0000B = tmp_str0000B + Ls_FFFE0;
   Ll_FFF20 = StringToTime(tmp_str0000B);
   tmp_str0000D = Ls_FFF28 + " ";
   tmp_str0000D = tmp_str0000D + Ls_FFFD0;
   Ll_FFF18 = StringToTime(tmp_str0000D);
   Li_FFF14 = TimeDayOfWeek(TimeCurrent());
   if (Ll_FFF20 < Ll_FFF18) { 
   if (TimeCurrent() >= Ll_FFF20 && TimeCurrent() <= Ll_FFF18) { 
   ObjectDelete(0, "FiltroOrario");
   Lb_FFFFF = true;
   ArrayFree(Ls_FFF48);
   ArrayFree(Ls_FFF9C);
   return Lb_FFFFF;
   } 
   tmp_str00011 = "Filtro orario Attivato";
   tmp_str00012 = "FiltroOrario";
   if (ObjectFind(tmp_str00012) < 0) {
   ObjectCreate(0, tmp_str00012, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(tmp_str00012, tmp_str00011, 12, "Estrangelo Edessa", 255);
   ObjectSet(tmp_str00012, OBJPROP_CORNER, 1);
   ObjectSet(tmp_str00012, OBJPROP_XDISTANCE, 20);
   ObjectSet(tmp_str00012, OBJPROP_YDISTANCE, 20);
   Lb_FFFFF = false;
   ArrayFree(Ls_FFF48);
   ArrayFree(Ls_FFF9C);
   return Lb_FFFFF;
   } 
   if (TimeCurrent() <= Ll_FFF18) { 
   Ll_FFF20 = Ll_FFF20 - 86400;
   } 
   else { 
   if (TimeCurrent() >= Ll_FFF20) { 
   Ll_FFF18 = Ll_FFF18 + 86400;
   }} 
   if (TimeCurrent() >= Ll_FFF20 && TimeCurrent() <= Ll_FFF18) { 
   ObjectDelete(0, "FiltroOrario");
   Lb_FFFFF = true;
   ArrayFree(Ls_FFF48);
   ArrayFree(Ls_FFF9C);
   return Lb_FFFFF;
   } 
   tmp_str00018 = "Filtro orario Attivato";
   tmp_str0001A = "FiltroOrario";
   if (ObjectFind(tmp_str0001A) < 0) {
   ObjectCreate(0, tmp_str0001A, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(tmp_str0001A, tmp_str00018, 12, "Estrangelo Edessa", 255);
   ObjectSet(tmp_str0001A, OBJPROP_CORNER, 1);
   ObjectSet(tmp_str0001A, OBJPROP_XDISTANCE, 20);
   ObjectSet(tmp_str0001A, OBJPROP_YDISTANCE, 20);
   Lb_FFFFF = false;
   ArrayFree(Ls_FFF48);
   ArrayFree(Ls_FFF9C);
   
   return Lb_FFFFF;
}

double func_1079(string Fa_s_00, string Fa_s_01, string Fa_s_02, bool FuncArg_Boolean_00000003)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   double Ld_FFFF0;
   int Li_FFFEC;
   string Ls_FFFE0;
   double Ld_FFFF8;

   Ld_FFFF0 = 0;
   Li_FFFEC = HistoryTotal() - 1;
   if (Li_FFFEC < 0) return Ld_FFFF0; 
   do { 
   if (OrderSelect(Li_FFFEC, 0, 1) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderCloseTime() < Il_09C98) return Ld_FFFF0; 
   Ls_FFFE0 = OrderComment();
   Gi_00001 = StringFind(OrderComment(), "from");
   if (Gi_00001 >= 0) { 
   Gi_00001 = (int)StringToInteger("");
   Gi_00002 = 0;
   Gi_00001 = 0;
   Gi_00003 = HistoryTotal() - 1;
   Gi_00004 = Gi_00003;
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00004, 0, 1)) { 
   Gl_00003 = OrderOpenTime();
   tmp_str00006 = IntegerToString(MagicInp, 0, 32);
   tmp_str00006 = tmp_str00006 + "_PMPtimeFlat";
   Gl_00005 = (datetime)(GlobalVariableGet(tmp_str00006) * 1000);
   if (Gl_00003 >= Gl_00005) { 
   Gi_00005 = StringFind(OrderComment(), "to #");
   if (Gi_00005 >= 0) { 
   Gi_00005 = (int)StringToInteger("");
   if (Gi_00005 == Gi_00001) { 
   Gi_00001 = OrderTicket();
   Gi_00002 = Gi_00001;
   }}}} 
   Gi_00004 = Gi_00004 - 1;
   } while (Gi_00004 >= 0); 
   } 
   Gi_00005 = Gi_00002;
   Gi_00006 = ArraySize(Is_0B074) - 1;
   Gi_00007 = Gi_00006;
   tmp_str00012 = "";
   if (Gi_00006 >= 0) {
   do { 
   string Ls_FFFAC[];
   tmp_str0000E = Is_0B074[Gi_00007];
   Gst_00009 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000E, Gst_00009, Ls_FFFAC);
   if (ArraySize(Ls_FFFAC) >= 2) {
   tmp_str00012 = (string)Gi_00005;
   if (Ls_FFFAC[0] == tmp_str00012) {
   tmp_str00012 = Ls_FFFAC[1];
   ArrayFree(Ls_FFFAC);
   break;
   }}
   ArrayFree(Ls_FFFAC);
   Gi_00007 = Gi_00007 - 1;
   } while (Gi_00007 >= 0); 
   }
   
   Ls_FFFE0 = tmp_str00012;
   if (tmp_str00012 == "") { 
   tmp_str00013 = "";
   tmp_str00016 = "ERRORE determinazione ordine, sistema sospeso PLO " + tmp_str00012;
   tmp_str00015 = Fa_s_01;
   tmp_str00017 = Fa_s_00;
   func_1050(-1, tmp_str00017, tmp_str00015, tmp_str00016, tmp_str00013, 0);
   Ib_1CED0 = true;
   Ld_FFFF8 = 0;
   return Ld_FFFF8;
   }} 
   if (OrderSelect(Li_FFFEC, 0, 1) && OrderMagicNumber() == Ii_1D234 && OrderSymbol() == Fa_s_01 && Fa_s_02 == Ls_FFFE0) { 
   Gd_0000B = OrderProfit();
   Gd_0000B = (Gd_0000B + OrderSwap());
   Ld_FFFF0 = ((Gd_0000B + OrderCommission()) + Ld_FFFF0);
   FuncArg_Boolean_00000003 = true;
   }} 
   Li_FFFEC = Li_FFFEC - 1;
   } while (Li_FFFEC >= 0); 
   
   Ld_FFFF8 = Ld_FFFF0;
   
   return Ld_FFFF8;
}

bool func_1080(string Fa_s_00, string Fa_s_01)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   bool Lb_FFFFF;
   int Li_FFFC4;
   string Ls_FFFB8;
   double Ld_FFFB0;
   bool Lb_FFFAF;
   double Ld_FFFA0;
   int Li_FFF9C;
   string Ls_FFF90;
   int Li_FFF8C;

   if (numeroMassimoOperazioniInGain == 0 || Ib_09C81 == false) { 
   
   Lb_FFFFF = true;
   return Lb_FFFFF;
   } 
   double Ld_FFFC8[];
   Li_FFFC4 = HistoryTotal() - 1;
   if (Li_FFFC4 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFC4, 0, 1) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   if (OrderCloseTime() < Il_09C98) break; 
   tmp_str00000 = TimeToString(OrderCloseTime(), 1);
   if (tmp_str00000 != TimeToString(TimeCurrent(), 1)) break; 
   if (OrderSymbol() == Fa_s_00) { 
   Ls_FFFB8 = OrderComment();
   Gi_00001 = StringFind(OrderComment(), "from");
   if (Gi_00001 >= 0) { 
   Gi_00002 = (int)StringToInteger("");
   Gi_00003 = 0;
   Gi_00002 = 0;
   Gi_00004 = HistoryTotal() - 1;
   Gi_00005 = Gi_00004;
   if (Gi_00004 >= 0) { 
   do { 
   if (OrderSelect(Gi_00005, 0, 1)) { 
   Gl_00004 = OrderOpenTime();
   tmp_str00007 = IntegerToString(MagicInp, 0, 32);
   tmp_str00007 = tmp_str00007 + "_PMPtimeFlat";
   Gl_00006 = (datetime)(GlobalVariableGet(tmp_str00007) * 1000);
   if (Gl_00004 >= Gl_00006) { 
   Gi_00006 = StringFind(OrderComment(), "to #");
   if (Gi_00006 >= 0) { 
   Gi_00006 = (int)StringToInteger("");
   if (Gi_00006 == Gi_00002) { 
   Gi_00002 = OrderTicket();
   Gi_00003 = Gi_00002;
   }}}} 
   Gi_00005 = Gi_00005 - 1;
   } while (Gi_00005 >= 0); 
   } 
   Gi_00006 = Gi_00003;
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Gi_00008 = Gi_00007;
   tmp_str00013 = "";
   if (Gi_00007 >= 0) {
   do { 
   string Ls_FFF58[];
   tmp_str0000F = Is_0B074[Gi_00008];
   Gst_0000A = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000F, Gst_0000A, Ls_FFF58);
   if (ArraySize(Ls_FFF58) >= 2) {
   tmp_str00013 = (string)Gi_00006;
   if (Ls_FFF58[0] == tmp_str00013) {
   tmp_str00013 = Ls_FFF58[1];
   ArrayFree(Ls_FFF58);
   break;
   }}
   ArrayFree(Ls_FFF58);
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   }
   
   Ls_FFFB8 = tmp_str00013;
   if (tmp_str00013 == "") { 
   tmp_str00014 = "";
   tmp_str00016 = "ERRORE determinazione ordine, sistema sospeso PNOI " + tmp_str00013;
   tmp_str00015 = Fa_s_01;
   tmp_str00017 = Fa_s_00;
   func_1050(-1, tmp_str00017, tmp_str00015, tmp_str00016, tmp_str00014, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = false;
   ArrayFree(Ld_FFFC8);
   return Lb_FFFFF;
   }} 
   if (OrderSelect(Li_FFFC4, 0, 1) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Gd_0000C = OrderProfit();
   Gd_0000C = (Gd_0000C + OrderCommission());
   Ld_FFFB0 = (Gd_0000C + OrderSwap());
   Lb_FFFAF = false;
   tmp_str0001A = Ls_FFFB8;
   tmp_str0001B = Fa_s_01;
   tmp_str0001C = Fa_s_00;
   Ld_FFFA0 = func_1079(tmp_str0001C, tmp_str0001B, tmp_str0001A, Lb_FFFAF);
   if (Lb_FFFAF) { 
   ArrayResize(Ld_FFFC8, (ArraySize(Ld_FFFC8) + 1), 0);
   Gd_0000C = (Ld_FFFB0 + Ld_FFFA0);
   Gi_0000D = ArraySize(Ld_FFFC8) - 1;
   Ld_FFFC8[Gi_0000D] = Gd_0000C;
   }}}}}} 
   Li_FFFC4 = Li_FFFC4 - 1;
   } while (Li_FFFC4 >= 0); 
   } 
   Li_FFF9C = 0;
   Ls_FFF90 = "";
   Li_FFF8C = 0;
   if (Li_FFF8C  < ArraySize(Ld_FFFC8)) { 
   do { 
   tmp_str0001F = DoubleToString(Ld_FFFC8[Li_FFF8C], 2);
   
   tmp_str0001F = tmp_str0001F + "";
   Ls_FFF90 = Ls_FFF90 + tmp_str0001F;
   if ((Ld_FFFC8[Li_FFF8C] > 0)) { 
   Li_FFF9C = Li_FFF9C + 1;
   } 
   else { 
   Li_FFF9C = Li_FFF9C - 1;
   } 
   Li_FFF8C = Li_FFF8C + 1;
   } while (Li_FFF8C < ArraySize(Ld_FFFC8)); 
   } 
   if (Li_FFF9C >= numeroMassimoOperazioniInGain) { 
   Lb_FFFFF = true;
   ArrayFree(Ld_FFFC8);
   return Lb_FFFFF;
   } 
   Lb_FFFFF = false;
   ArrayFree(Ld_FFFC8);
   
   return Lb_FFFFF;
}

bool func_1085(int Fa_i_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, int Fa_i_04)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   bool Lb_FFFFF;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFF68;
   int Li_FFF64;
   string Ls_FFF58;
   bool Lb_FFF57;
   string Ls_FFF48;
   string Ls_FFF38;
   int Li_FFF2C;
   int Li_FFF28;
   int Li_FFF24;
   int Li_FFF20;
   int Li_FFF1C;
   int Li_FFF18;
   int Li_FFF14;
   int Li_FFF10;
   int Li_FFF0C;
   int Li_FFF08;
   int Li_FFF04;
   int Li_FFF00;
   int Li_FFEFC;
   int Li_FFEF8;
   int Li_FFEF4;
   int Li_FFEF0;
   int Li_FFEEC;
   int Li_FFEE8;
   int Li_FFEE4;
   int Li_FFEE0;
   int Li_FFEDC;
   int Li_FFF30;
   int Li_FFF34;

   if (numeroMassimoOrdiniPerValuta == 0) { 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   } 
   tmp_str00001 = Fa_s_03;
   Ls_FFFF0 = Fa_s_03;
   Ls_FFFE0 = "";
   Valuta Local_Struct_FFFFFFAC[];
   MagicStrumento Local_Struct_FFFFFF78[];
   Ls_FFF68 = "";
   Li_FFF64 = OrdersTotal() - 1;
   if (Li_FFF64 >= 0) { 
   do { 
   if (OrderSelect(Li_FFF64, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00001 = OrderMagicNumber();
   Gi_00002 = MagicInp + 1000;
   if (Gi_00001 < Gi_00002) { 
   Ls_FFF58 = OrderComment();
   if (Ib_09C81) { 
   Gi_00002 = StringFind(OrderComment(), "from");
   if (Gi_00002 >= 0) { 
   Gi_00002 = (int)StringToInteger("");
   Gi_00003 = 0;
   Gi_00002 = 0;
   Gi_00004 = HistoryTotal() - 1;
   Gi_00005 = Gi_00004;
   if (Gi_00004 >= 0) { 
   do { 
   if (OrderSelect(Gi_00005, 0, 1)) { 
   Gl_00004 = OrderOpenTime();
   tmp_str0000B = IntegerToString(MagicInp, 0, 32);
   tmp_str0000B = tmp_str0000B + "_PMPtimeFlat";
   Gl_00006 = (datetime)(GlobalVariableGet(tmp_str0000B) * 1000);
   if (Gl_00004 >= Gl_00006) { 
   Gi_00006 = StringFind(OrderComment(), "to #");
   if (Gi_00006 >= 0) { 
   Gi_00006 = (int)StringToInteger("");
   if (Gi_00006 == Gi_00002) { 
   Gi_00002 = OrderTicket();
   Gi_00003 = Gi_00002;
   }}}} 
   Gi_00005 = Gi_00005 - 1;
   } while (Gi_00005 >= 0); 
   } 
   Gi_00006 = Gi_00003;
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Gi_00008 = Gi_00007;
   tmp_str00017 = "";
   if (Gi_00007 >= 0) {
   do { 
   string Ls_FFEA8[];
   tmp_str00013 = Is_0B074[Gi_00008];
   Gst_0000A = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00013, Gst_0000A, Ls_FFEA8);
   if (ArraySize(Ls_FFEA8) >= 2) {
   tmp_str00017 = (string)Gi_00006;
   if (Ls_FFEA8[0] == tmp_str00017) {
   tmp_str00017 = Ls_FFEA8[1];
   ArrayFree(Ls_FFEA8);
   break;
   }}
   ArrayFree(Ls_FFEA8);
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   }
   
   Ls_FFF58 = tmp_str00017;
   if (tmp_str00017 == "") { 
   tmp_str00018 = "";
   tmp_str0001B = "ERRORE determinazione ordine, sistema sospeso GO " + tmp_str00017;
   tmp_str0001A = Fa_s_02;
   tmp_str0001C = Fa_s_01;
   func_1050(Fa_i_00, tmp_str0001C, tmp_str0001A, tmp_str0001B, tmp_str00018, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }}} 
   Lb_FFF57 = false;
   if (Ib_09C81) { 
   Gb_0000D = OrderSelect(Li_FFF64, 0, 0);
   if (Gb_0000D) { 
   tmp_str0001F = Ls_FFF58;
   tmp_str00022 = "Master";
   Gi_0000F = StringFind(tmp_str0001F, tmp_str00022);
   Gb_0000D = (Gi_0000F >= 0);
   } 
   Lb_FFF57 = Gb_0000D;
   } 
   else { 
   Gi_00010 = OrderMagicNumber();
   tmp_str00022 = OrderSymbol();

   Gi_00013 = 0;
   Gi_00014 = ArraySize(Local_Struct_FFFFFF78);
   Gi_00013 = 0;
   Gb_00016 = false;
   if (Gi_00013 < Gi_00014) {
   do { 
   if (Local_Struct_FFFFFF78[Gi_00013].m_16 == Gi_00010 
   && Local_Struct_FFFFFF78[Gi_00013].m_20 == tmp_str00022) {
   Gb_00016 = true;
   break;
   }
   Gi_00013 = Gi_00013 + 1;
   Gi_00017 = ArraySize(Local_Struct_FFFFFF78);
   } while (Gi_00013 < Gi_00017); 
   }
   Gi_00017 = ArraySize(Local_Struct_FFFFFF78);
   ArrayResize(Local_Struct_FFFFFF78, (Gi_00017 + 1), 0);
   Gi_00017 = ArraySize(Local_Struct_FFFFFF78);
   Gi_00017 = Gi_00017 - 1;
   Local_Struct_FFFFFF78[Gi_00017].m_16 = Gi_00010;
   Gi_00018 = ArraySize(Local_Struct_FFFFFF78);
   Gi_00018 = Gi_00018 - 1;
   Local_Struct_FFFFFF78[Gi_00018].m_20 = tmp_str00022;
   
   Lb_FFF57 = Gb_00016;
   } 
   if (Lb_FFF57 != true) { 
   Ls_FFF48 = OrderSymbol();
   Ls_FFF38 = "";
   tmp_str00028 = Ls_FFF48;
   Gi_0001B = 0;
   Gi_0001C = ArraySize(Local_Struct_FFFFFFAC);
   Gb_0001D = false;
   if (Gi_0001B < Gi_0001C) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0001B].m_16 == tmp_str00028) {
   Gb_0001D = true;
   break;
   }
   Gi_0001B = Gi_0001B + 1;
   Gi_0001E = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0001B < Gi_0001E); 
   }
   
   if (!Gb_0001D) {
   ArrayResize(Local_Struct_FFFFFFAC, (ArraySize(Local_Struct_FFFFFFAC) + 1), 0);
   Gi_0001E = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Gi_0001F = Gi_0001E;
   Gi_00020 = Gi_0001E;
   Gi_00021 = Gi_0001E;
   Local_Struct_FFFFFFAC[Gi_0001E].m_16 = Ls_FFF48;
   Gi_00022 = Gi_00021;
   Local_Struct_FFFFFFAC[Gi_00021].m_28 = 0;
   Gi_00023 = Gi_00020;
   Local_Struct_FFFFFFAC[Gi_00020].m_32 = 0;
   if (OrderType() == OP_BUY) { 
   Gi_00024 = Gi_0001F;
   Local_Struct_FFFFFFAC[Gi_0001F].m_28 = Local_Struct_FFFFFFAC[Gi_0001F].m_28 + 1;
   } 
   if (OrderType() == OP_SELL) {
   Gi_00025 = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Local_Struct_FFFFFFAC[Gi_00025].m_32 = Local_Struct_FFFFFFAC[Gi_00025].m_32 + 1;
   }}
   else{
   tmp_str00029 = Ls_FFF48;
   Gi_00029 = 0;
   Gi_0002A = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0002B = -1;
   if (Gi_00029 < Gi_0002A) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00029].m_16 == tmp_str00029) {
   Gi_0002B = Gi_00029;
   break;
   }
   Gi_00029 = Gi_00029 + 1;
   Gi_0002C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00029 < Gi_0002C); 
   }
   
   Li_FFF34 = Gi_0002B;
   if (OrderType() == OP_BUY) { 
   Local_Struct_FFFFFFAC[Gi_0002B].m_28 = Local_Struct_FFFFFFAC[Gi_0002B].m_28 + 1;
   } 
   if (OrderType() == OP_SELL) { 
   Local_Struct_FFFFFFAC[Li_FFF34].m_32 = Local_Struct_FFFFFFAC[Li_FFF34].m_32 + 1;
   }} 
   tmp_str0002B = Ls_FFF38;
   Gi_00030 = 0;
   Gi_00031 = ArraySize(Local_Struct_FFFFFFAC);
   Gb_00032 = false;
   if (Gi_00030 < Gi_00031) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00030].m_16 == tmp_str0002B) {
   Gb_00032 = true;
   break;
   }
   Gi_00030 = Gi_00030 + 1;
   Gi_00033 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00030 < Gi_00033); 
   }
   
   if (!Gb_00032) {
   ArrayResize(Local_Struct_FFFFFFAC, (ArraySize(Local_Struct_FFFFFFAC) + 1), 0);
   Gi_00033 = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Gi_00034 = Gi_00033;
   Gi_00035 = Gi_00033;
   Gi_00036 = Gi_00033;
   Local_Struct_FFFFFFAC[Gi_00033].m_16 = Ls_FFF38;
   Gi_00037 = Gi_00036;
   Local_Struct_FFFFFFAC[Gi_00036].m_28 = 0;
   Gi_00038 = Gi_00035;
   Local_Struct_FFFFFFAC[Gi_00035].m_32 = 0;
   if (OrderType() == OP_BUY) { 
   Gi_00039 = Gi_00034;
   Local_Struct_FFFFFFAC[Gi_00034].m_32 = Local_Struct_FFFFFFAC[Gi_00034].m_32 + 1;
   } 
   if (OrderType() == OP_SELL) {
   Gi_0003A = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Local_Struct_FFFFFFAC[Gi_0003A].m_28 = Local_Struct_FFFFFFAC[Gi_0003A].m_28 + 1;
   }}
   else{
   tmp_str0002C = Ls_FFF38;
   Gi_0003E = 0;
   Gi_0003F = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00040 = -1;
   if (Gi_0003E < Gi_0003F) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0003E].m_16 == tmp_str0002C) {
   Gi_00040 = Gi_0003E;
   break;
   }
   Gi_0003E = Gi_0003E + 1;
   Gi_00041 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0003E < Gi_00041); 
   }
   
   Li_FFF30 = Gi_00040;
   if (OrderType() == OP_BUY) { 
   Local_Struct_FFFFFFAC[Gi_00040].m_32 = Local_Struct_FFFFFFAC[Gi_00040].m_32 + 1;
   } 
   if (OrderType() == OP_SELL) { 
   Local_Struct_FFFFFFAC[Li_FFF30].m_28 = Local_Struct_FFFFFFAC[Li_FFF30].m_28 + 1;
   }}}}} 
   Li_FFF64 = Li_FFF64 - 1;
   } while (Li_FFF64 >= 0); 
   } 
   tmp_str0002E = Is_09CA0 + "visualizzazione";
   tmp_str0002F = ObjectGetString(0, tmp_str0002E, 999, 0);
   if (tmp_str0002F == "Manager") { 
   Gi_00043 = 80;
   } 
   else { 
   Gi_00043 = 20;
   } 
   Li_FFF2C = Gi_00043;
   Li_FFF28 = 78;
   Li_FFF24 = 33;
   Li_FFF20 = 80;
   Li_FFF1C = 35;
   Li_FFF18 = 40;
   Li_FFF14 = 90;
   Li_FFF10 = 0;
   Li_FFF0C = 0;
   Li_FFF08 = 198;
   Li_FFF04 = 48;
   Li_FFF00 = 20;
   tmp_str0003A = "Dubai";
   Gi_0004D = 200 - Gi_0004C;
   tmp_str0003C = "VALUTE";
   tmp_str0003E = Is_09CA0 + "TABnomeTABNOME_";
   tmp_str0003E = tmp_str0003E + "Valute";
   tmp_str0003E = tmp_str0003E + "_Y";
   tmp_str00041 = tmp_str0003E;
   if (ObjectFind(tmp_str00041) < 0) {
   ObjectCreate(0, tmp_str00041, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_0004E = (int)(Gi_0004D * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00041, 102, Gi_0004E);
   ObjectSetInteger(0, tmp_str00041, 101, 1);
   Gi_0004E = (int)(Gi_00043 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00041, 103, Gi_0004E);
   Gi_0004E = (int)(Gi_00044 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00041, 1019, Gi_0004E);
   Gi_0004E = (int)(Gi_00045 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00041, 1020, Gi_0004E);
   ObjectSetString(0, tmp_str00041, 999, tmp_str0003C);
   ObjectSetString(0, tmp_str00041, 1001, tmp_str0003A);
   ObjectSetInteger(0, tmp_str00041, 6, 16777215);
   ObjectSetInteger(0, tmp_str00041, 1025, 1315860);
   ObjectSetInteger(0, tmp_str00041, 1035, 1315860);
   ObjectSetInteger(0, tmp_str00041, 1029, 1);
   ObjectSetInteger(0, tmp_str00041, 208, 1);
   ObjectSetInteger(0, tmp_str00041, 1018, 0);
   ObjectSetInteger(0, tmp_str00041, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00041, 9, 0);
   tmp_str00042 = "Dubai";
   Gi_0004E = Gi_00044 - 30;
   Gi_0004A = Gi_0004A - Gi_0004C;
   tmp_str00044 = "BUY";
   tmp_str00046 = Is_09CA0 + "TABnomeTABNOMEBuy_";
   tmp_str00046 = tmp_str00046 + "Buy";
   tmp_str00046 = tmp_str00046 + "_Y";
   tmp_str00049 = tmp_str00046;
   if (ObjectFind(tmp_str00049) < 0) {
   ObjectCreate(0, tmp_str00049, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00050 = (int)(Gi_0004A * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00049, 102, Gi_00050);
   ObjectSetInteger(0, tmp_str00049, 101, 1);
   Gi_00050 = (int)(Gi_00043 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00049, 103, Gi_00050);
   Gi_00050 = (int)(Gi_0004E * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00049, 1019, Gi_00050);
   Gi_00050 = (int)(Gi_00045 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00049, 1020, Gi_00050);
   ObjectSetString(0, tmp_str00049, 999, tmp_str00044);
   ObjectSetString(0, tmp_str00049, 1001, tmp_str00042);
   ObjectSetInteger(0, tmp_str00049, 6, 16777215);
   ObjectSetInteger(0, tmp_str00049, 1025, 3329330);
   ObjectSetInteger(0, tmp_str00049, 1035, 3329330);
   ObjectSetInteger(0, tmp_str00049, 1029, 1);
   ObjectSetInteger(0, tmp_str00049, 208, 1);
   ObjectSetInteger(0, tmp_str00049, 1018, 0);
   ObjectSetInteger(0, tmp_str00049, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00049, 9, 0);
   tmp_str0004A = "Dubai";
   Gi_00050 = Gi_0004B - Gi_0004C;
   tmp_str0004B = "SELL";
   tmp_str0004C = Is_09CA0 + "TABnomeTABNOMEBuy_";
   tmp_str0004C = tmp_str0004C + "Sell";
   tmp_str0004C = tmp_str0004C + "_Y";
   tmp_str0004F = tmp_str0004C;
   if (ObjectFind(tmp_str0004F) < 0) {
   ObjectCreate(0, tmp_str0004F, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00051 = (int)(Gi_00050 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0004F, 102, Gi_00051);
   ObjectSetInteger(0, tmp_str0004F, 101, 1);
   Gi_00051 = (int)(Gi_00043 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0004F, 103, Gi_00051);
   Gi_00051 = (int)(Gi_0004E * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0004F, 1019, Gi_00051);
   Gi_00051 = (int)(Gi_00045 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0004F, 1020, Gi_00051);
   ObjectSetString(0, tmp_str0004F, 999, tmp_str0004B);
   ObjectSetString(0, tmp_str0004F, 1001, tmp_str0004A);
   ObjectSetInteger(0, tmp_str0004F, 6, 16777215);
   ObjectSetInteger(0, tmp_str0004F, 1025, 255);
   ObjectSetInteger(0, tmp_str0004F, 1035, 255);
   ObjectSetInteger(0, tmp_str0004F, 1029, 1);
   ObjectSetInteger(0, tmp_str0004F, 208, 1);
   ObjectSetInteger(0, tmp_str0004F, 1018, 0);
   ObjectSetInteger(0, tmp_str0004F, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0004F, 9, 0);
   tmp_str00050 = orarioOperativita2;
   Li_FFF2C = Li_FFF2C + Gi_00049;
   Li_FFEFC = 0;
   if (Li_FFEFC < ArraySize(Local_Struct_FFFFFFAC)) { 
   do { 
   tmp_str00051 = "Dubai";
   Gi_00051 = 200 - Li_FFF00;
   tmp_str00052 = Local_Struct_FFFFFFAC[Li_FFEFC].m_16;
   tmp_str00054 = Is_09CA0 + "TABnomeTABvaluta_";
   tmp_str00054 = tmp_str00054 + Local_Struct_FFFFFFAC[Li_FFEFC].m_16;
   tmp_str00054 = tmp_str00054 + "_Y";
   tmp_str00056 = tmp_str00054;
   if (ObjectFind(tmp_str00056) < 0) {
   ObjectCreate(0, tmp_str00056, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00055 = (int)(Gi_00051 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00056, 102, Gi_00055);
   ObjectSetInteger(0, tmp_str00056, 101, 1);
   Gi_00055 = (int)(Li_FFF2C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00056, 103, Gi_00055);
   Gi_00055 = (int)(Li_FFF28 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00056, 1019, Gi_00055);
   Gi_00055 = (int)(Li_FFF24 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00056, 1020, Gi_00055);
   ObjectSetString(0, tmp_str00056, 999, tmp_str00052);
   ObjectSetString(0, tmp_str00056, 1001, tmp_str00051);
   ObjectSetInteger(0, tmp_str00056, 6, 16777215);
   ObjectSetInteger(0, tmp_str00056, 1025, 1315860);
   ObjectSetInteger(0, tmp_str00056, 1035, 1315860);
   ObjectSetInteger(0, tmp_str00056, 1029, 1);
   ObjectSetInteger(0, tmp_str00056, 208, 1);
   ObjectSetInteger(0, tmp_str00056, 1018, 0);
   ObjectSetInteger(0, tmp_str00056, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00056, 9, 0);
   tmp_str00057 = "Dubai";
   Gi_00055 = Li_FFF28 - 30;
   Gi_00056 = Li_FFF08 - Li_FFF00;
   Gi_00058 = Local_Struct_FFFFFFAC[Li_FFEFC].m_28;
   tmp_str00058 = IntegerToString(Gi_00058, 0, 32);
   tmp_str00059 = Is_09CA0 + "TABnomeTABvalutaBuy_";
   tmp_str00059 = tmp_str00059 + Local_Struct_FFFFFFAC[Li_FFEFC].m_16;
   tmp_str00059 = tmp_str00059 + "_Y";
   tmp_str0005B = tmp_str00059;
   if (ObjectFind(tmp_str0005B) < 0) {
   ObjectCreate(0, tmp_str0005B, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00059 = (int)(Gi_00056 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0005B, 102, Gi_00059);
   ObjectSetInteger(0, tmp_str0005B, 101, 1);
   Gi_00059 = (int)(Li_FFF2C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0005B, 103, Gi_00059);
   Gi_00059 = (int)(Gi_00055 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0005B, 1019, Gi_00059);
   Gi_00059 = (int)(Li_FFF24 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str0005B, 1020, Gi_00059);
   ObjectSetString(0, tmp_str0005B, 999, tmp_str00058);
   ObjectSetString(0, tmp_str0005B, 1001, tmp_str00057);
   ObjectSetInteger(0, tmp_str0005B, 6, 16777215);
   ObjectSetInteger(0, tmp_str0005B, 1025, 1315860);
   ObjectSetInteger(0, tmp_str0005B, 1035, 1315860);
   ObjectSetInteger(0, tmp_str0005B, 1029, 1);
   ObjectSetInteger(0, tmp_str0005B, 208, 1);
   ObjectSetInteger(0, tmp_str0005B, 1018, 0);
   ObjectSetInteger(0, tmp_str0005B, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str0005B, 9, 0);
   tmp_str0005C = "Dubai";
   Gi_00059 = Li_FFF04 - Li_FFF00;
   Gi_0005B = Local_Struct_FFFFFFAC[Li_FFEFC].m_32;
   tmp_str0005D = IntegerToString(Gi_0005B, 0, 32);
   tmp_str0005F = Is_09CA0 + "TABnomeTABvalutaSell_";
   tmp_str0005F = tmp_str0005F + Local_Struct_FFFFFFAC[Li_FFEFC].m_16;
   tmp_str0005F = tmp_str0005F + "_Y";
   tmp_str00061 = tmp_str0005F;
   if (ObjectFind(tmp_str00061) < 0) {
   ObjectCreate(0, tmp_str00061, OBJ_BUTTON, 0, 0, 0);
   }
   Gi_00059 = (int)(Gi_00059 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00061, 102, Gi_00059);
   ObjectSetInteger(0, tmp_str00061, 101, 1);
   Gi_00059 = (int)(Li_FFF2C * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00061, 103, Gi_00059);
   Gi_00059 = (int)(Gi_00055 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00061, 1019, Gi_00059);
   Gi_00059 = (int)(Li_FFF24 * moltiplicatoreGrafiche);
   ObjectSetInteger(0, tmp_str00061, 1020, Gi_00059);
   ObjectSetString(0, tmp_str00061, 999, tmp_str0005D);
   ObjectSetString(0, tmp_str00061, 1001, tmp_str0005C);
   ObjectSetInteger(0, tmp_str00061, 6, 16777215);
   ObjectSetInteger(0, tmp_str00061, 1025, 1315860);
   ObjectSetInteger(0, tmp_str00061, 1035, 1315860);
   ObjectSetInteger(0, tmp_str00061, 1029, 1);
   ObjectSetInteger(0, tmp_str00061, 208, 1);
   ObjectSetInteger(0, tmp_str00061, 1018, 0);
   ObjectSetInteger(0, tmp_str00061, 100, grandezzaFont);
   ObjectSetInteger(0, tmp_str00061, 9, 0);

   Li_FFF2C = Li_FFF2C + Li_FFF0C;
   Li_FFEFC = Li_FFEFC + 1;
   } while (Li_FFEFC < ArraySize(Local_Struct_FFFFFFAC)); 
   } 
   if (Fa_i_04 == 0) { 
   tmp_str00063 = Ls_FFFF0;
   Gi_0005D = 0;
   Gi_0005F = 0;
   Gi_00060 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00062 = -1;
   if (Gi_0005F < Gi_00060) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0005F].m_16 == tmp_str00063) {
   if (Gi_0005D == 0) {
   Gi_00062 = Local_Struct_FFFFFFAC[Gi_0005F].m_28;
   break;
   }
   if (Gi_0005D == 1) {
   Gi_00062 = Local_Struct_FFFFFFAC[Gi_0005F].m_32;
   break;
   }}
   Gi_0005F = Gi_0005F + 1;
   Gi_00064 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0005F < Gi_00064); 
   }
   
   Li_FFEF8 = Gi_00062;
   tmp_str00065 = Ls_FFFF0;
   Gi_00065 = 1;
   Gi_00067 = 0;
   Gi_00068 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0006A = -1;
   if (Gi_00067 < Gi_00068) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00067].m_16 == tmp_str00065) {
   if (Gi_00065 == 0) {
   Gi_0006A = Local_Struct_FFFFFFAC[Gi_00067].m_28;
   break;
   }
   if (Gi_00065 == 1) {
   Gi_0006A = Local_Struct_FFFFFFAC[Gi_00067].m_32;
   break;
   }}
   Gi_00067 = Gi_00067 + 1;
   Gi_0006C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00067 < Gi_0006C); 
   }
   
   Li_FFEF4 = Gi_0006A;
   tmp_str00067 = Ls_FFFE0;
   Gi_0006D = 0;
   Gi_0006F = 0;
   Gi_00070 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00072 = -1;
   if (Gi_0006F < Gi_00070) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0006F].m_16 == tmp_str00067) {
   if (Gi_0006D == 0) {
   Gi_00072 = Local_Struct_FFFFFFAC[Gi_0006F].m_28;
   break;
   }
   if (Gi_0006D == 1) {
   Gi_00072 = Local_Struct_FFFFFFAC[Gi_0006F].m_32;
   break;
   }}
   Gi_0006F = Gi_0006F + 1;
   Gi_00074 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0006F < Gi_00074); 
   }
   
   Li_FFEF0 = Gi_00072;
   tmp_str00069 = Ls_FFFE0;
   Gi_00075 = 1;
   Gi_00077 = 0;
   Gi_00078 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0007A = -1;
   if (Gi_00077 < Gi_00078) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00077].m_16 == tmp_str00069) {
   if (Gi_00075 == 0) {
   Gi_0007A = Local_Struct_FFFFFFAC[Gi_00077].m_28;
   break;
   }
   if (Gi_00075 == 1) {
   Gi_0007A = Local_Struct_FFFFFFAC[Gi_00077].m_32;
   break;
   }}
   Gi_00077 = Gi_00077 + 1;
   Gi_0007C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00077 < Gi_0007C); 
   }
   
   Li_FFEEC = Gi_0007A;
   Gi_0007C = Li_FFEF8 - Li_FFEF4;
   if (Gi_0007C < numeroMassimoOrdiniPerValuta) { 
   Gi_0007C = Gi_0007A - Li_FFEF0;
   if (Gi_0007C < numeroMassimoOrdiniPerValuta) { 
   Lb_FFFFF = true;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }} 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   } 
   if (Fa_i_04 == 1) { 
   tmp_str0006B = Ls_FFFF0;
   Gi_0007D = 0;
   Gi_0007F = 0;
   Gi_00080 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00082 = -1;
   if (Gi_0007F < Gi_00080) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0007F].m_16 == tmp_str0006B) {
   if (Gi_0007D == 0) {
   Gi_00082 = Local_Struct_FFFFFFAC[Gi_0007F].m_28;
   break;
   }
   if (Gi_0007D == 1) {
   Gi_00082 = Local_Struct_FFFFFFAC[Gi_0007F].m_32;
   break;
   }}
   Gi_0007F = Gi_0007F + 1;
   Gi_00084 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0007F < Gi_00084); 
   }
   
   Li_FFEE8 = Gi_00082;
   tmp_str0006D = Ls_FFFF0;
   Gi_00085 = 1;
   Gi_00087 = 0;
   Gi_00088 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0008A = -1;
   if (Gi_00087 < Gi_00088) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00087].m_16 == tmp_str0006D) {
   if (Gi_00085 == 0) {
   Gi_0008A = Local_Struct_FFFFFFAC[Gi_00087].m_28;
   break;
   }
   if (Gi_00085 == 1) {
   Gi_0008A = Local_Struct_FFFFFFAC[Gi_00087].m_32;
   break;
   }}
   Gi_00087 = Gi_00087 + 1;
   Gi_0008C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00087 < Gi_0008C); 
   }
   
   Li_FFEE4 = Gi_0008A;
   tmp_str0006F = Ls_FFFE0;
   Gi_0008D = 0;
   Gi_0008F = 0;
   Gi_00090 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00092 = -1;
   if (Gi_0008F < Gi_00090) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0008F].m_16 == tmp_str0006F) {
   if (Gi_0008D == 0) {
   Gi_00092 = Local_Struct_FFFFFFAC[Gi_0008F].m_28;
   break;
   }
   if (Gi_0008D == 1) {
   Gi_00092 = Local_Struct_FFFFFFAC[Gi_0008F].m_32;
   break;
   }}
   Gi_0008F = Gi_0008F + 1;
   Gi_00094 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0008F < Gi_00094); 
   }
   
   Li_FFEE0 = Gi_00092;
   tmp_str00071 = Ls_FFFE0;
   Gi_00095 = 1;
   Gi_00097 = 0;
   Gi_00098 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0009A = -1;
   if (Gi_00097 < Gi_00098) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00097].m_16 == tmp_str00071) {
   if (Gi_00095 == 0) {
   Gi_0009A = Local_Struct_FFFFFFAC[Gi_00097].m_28;
   break;
   }
   if (Gi_00095 == 1) {
   Gi_0009A = Local_Struct_FFFFFFAC[Gi_00097].m_32;
   break;
   }}
   Gi_00097 = Gi_00097 + 1;
   Gi_0009C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00097 < Gi_0009C); 
   }
   
   Li_FFEDC = Gi_0009A;
   Gi_0009C = Li_FFEE4 - Li_FFEE8;
   if (Gi_0009C < numeroMassimoOrdiniPerValuta) { 
   Gi_0009C = Li_FFEE0 - Gi_0009A;
   if (Gi_0009C < numeroMassimoOrdiniPerValuta) { 
   Lb_FFFFF = true;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }} 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   } 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   
   return Lb_FFFFF;
}

bool func_1086(int Fa_i_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, int Fa_i_04)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   bool Lb_FFFFF;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFF68;
   int Li_FFF64;
   string Ls_FFF58;
   bool Lb_FFF57;
   string Ls_FFF48;
   int Li_FFF40;
   int Li_FFF3C;
   int Li_FFF38;
   int Li_FFF34;
   int Li_FFF30;
   int Li_FFF2C;
   int Li_FFF28;
   int Li_FFF24;
   int Li_FFF44;

   if (numeroMassimoOrdiniPerStrumentoFinanziario == 0) { 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   } 
   tmp_str00001 = Fa_s_01;
   Ls_FFFF0 = Fa_s_01;
   tmp_str00003 = Fa_s_02;
   Ls_FFFE0 = Fa_s_02;
   Valuta Local_Struct_FFFFFFAC[];
   MagicStrumento Local_Struct_FFFFFF78[];
   Ls_FFF68 = "";
   Li_FFF64 = OrdersTotal() - 1;
   if (Li_FFF64 >= 0) { 
   do { 
   if (OrderSelect(Li_FFF64, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00000 = OrderMagicNumber();
   Gi_00001 = MagicInp + 1000;
   if (Gi_00000 < Gi_00001) { 
   Ls_FFF58 = OrderComment();
   if (Ib_09C81) { 
   Gi_00002 = StringFind(OrderComment(), "from");
   if (Gi_00002 >= 0) { 
   Gi_00002 = (int)StringToInteger("");
   Gi_00003 = 0;
   Gi_00002 = 0;
   Gi_00004 = HistoryTotal() - 1;
   Gi_00005 = Gi_00004;
   if (Gi_00004 >= 0) { 
   do { 
   if (OrderSelect(Gi_00005, 0, 1)) { 
   Gl_00004 = OrderOpenTime();
   tmp_str0000B = IntegerToString(MagicInp, 0, 32);
   tmp_str0000B = tmp_str0000B + "_PMPtimeFlat";
   Gl_00006 = (datetime)(GlobalVariableGet(tmp_str0000B) * 1000);
   if (Gl_00004 >= Gl_00006) { 
   Gi_00006 = StringFind(OrderComment(), "to #");
   if (Gi_00006 >= 0) { 
   Gi_00006 = (int)StringToInteger("");
   if (Gi_00006 == Gi_00002) { 
   Gi_00002 = OrderTicket();
   Gi_00003 = Gi_00002;
   }}}} 
   Gi_00005 = Gi_00005 - 1;
   } while (Gi_00005 >= 0); 
   } 
   Gi_00006 = Gi_00003;
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Gi_00008 = Gi_00007;
   tmp_str00017 = "";
   if (Gi_00007 >= 0) {
   do { 
   string Ls_FFEF0[];
   tmp_str00013 = Is_0B074[Gi_00008];
   Gst_0000A = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00013, Gst_0000A, Ls_FFEF0);
   if (ArraySize(Ls_FFEF0) >= 2) {
   tmp_str00017 = (string)Gi_00006;
   if (Ls_FFEF0[0] == tmp_str00017) {
   tmp_str00017 = Ls_FFEF0[1];
   ArrayFree(Ls_FFEF0);
   break;
   }}
   ArrayFree(Ls_FFEF0);
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   }
   
   Ls_FFF58 = tmp_str00017;
   if (tmp_str00017 == "") { 
   tmp_str00018 = "";
   tmp_str0001B = "ERRORE determinazione ordine, sistema sospeso GO " + tmp_str00017;
   tmp_str0001A = Fa_s_02;
   tmp_str0001C = Fa_s_01;
   func_1050(Fa_i_00, tmp_str0001C, tmp_str0001A, tmp_str0001B, tmp_str00018, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }}} 
   Lb_FFF57 = false;
   if (Ib_09C81) { 
   Gb_0000C = OrderSelect(Li_FFF64, 0, 0);
   if (Gb_0000C) { 
   tmp_str00021 = "Master";
   tmp_str00020 = Ls_FFF58;
   Gi_0000D = StringFind(tmp_str00020, tmp_str00021);
   Gb_0000C = (Gi_0000D >= 0);
   } 
   Lb_FFF57 = Gb_0000C;
   } 
   else { 
   tmp_str00020 = OrderSymbol();
   Gi_0000E = OrderMagicNumber();
   Gi_00011 = 0;
   Gi_00012 = ArraySize(Local_Struct_FFFFFF78);
   Gb_00014 = false;
   if (Gi_00011 < Gi_00012) {
   do { 
   if (Local_Struct_FFFFFF78[Gi_00011].m_16 == Gi_0000E 
   && Local_Struct_FFFFFF78[Gi_00011].m_20 == tmp_str00020) {
   Gb_00014 = true;
   break;
   }
   Gi_00011 = Gi_00011 + 1;
   Gi_00015 = ArraySize(Local_Struct_FFFFFF78);
   } while (Gi_00011 < Gi_00015); 
   }
   Gi_00015 = ArraySize(Local_Struct_FFFFFF78);
   ArrayResize(Local_Struct_FFFFFF78, (Gi_00015 + 1), 0);
   Gi_00015 = ArraySize(Local_Struct_FFFFFF78);
   Gi_00015 = Gi_00015 - 1;
   Local_Struct_FFFFFF78[Gi_00015].m_16 = Gi_0000E;
   Gi_00016 = ArraySize(Local_Struct_FFFFFF78);
   Gi_00016 = Gi_00016 - 1;
   Local_Struct_FFFFFF78[Gi_00016].m_20  = tmp_str00020;
   
   Lb_FFF57 = Gb_00014;
   } 
   if (Lb_FFF57 != true) { 
   Ls_FFF48 = OrderSymbol();
   tmp_str00023 = Ls_FFF48;
   Gi_00019 = 0;
   Gi_0001A = ArraySize(Local_Struct_FFFFFFAC);
   Gb_0001B = false;
   if (Gi_00019 < Gi_0001A) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00019].m_16 == tmp_str00023) {
   Gb_0001B = true;
   break;
   }
   Gi_00019 = Gi_00019 + 1;
   Gi_0001C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00019 < Gi_0001C); 
   }
   
   if (!Gb_0001B) {
   ArrayResize(Local_Struct_FFFFFFAC, (ArraySize(Local_Struct_FFFFFFAC) + 1), 0);
   Gi_0001C = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Gi_0001D = Gi_0001C;
   Gi_0001E = Gi_0001C;
   Gi_0001F = Gi_0001C;
   Local_Struct_FFFFFFAC[Gi_0001C].m_16 = Ls_FFF48;
   Gi_00020 = Gi_0001F;
   Local_Struct_FFFFFFAC[Gi_0001F].m_28 = 0;
   Gi_00021 = Gi_0001E;
   Local_Struct_FFFFFFAC[Gi_0001E].m_32 = 0;
   if (OrderType() == OP_BUY) { 
   Gi_00022 = Gi_0001D;
   Local_Struct_FFFFFFAC[Gi_0001D].m_28 = Local_Struct_FFFFFFAC[Gi_0001D].m_28 + 1;
   } 
   if (OrderType() == OP_SELL) {
   Gi_00023 = ArraySize(Local_Struct_FFFFFFAC) - 1;
   Local_Struct_FFFFFFAC[Gi_00023].m_32 = Local_Struct_FFFFFFAC[Gi_00023].m_32 + 1;
   }}
   else{
   tmp_str00024 = Ls_FFF48;
   Gi_00027 = 0;
   Gi_00028 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00029 = -1;
   if (Gi_00027 < Gi_00028) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00027].m_16 == tmp_str00024) {
   Gi_00029 = Gi_00027;
   break;
   }
   Gi_00027 = Gi_00027 + 1;
   Gi_0002A = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00027 < Gi_0002A); 
   }
   
   Li_FFF44 = Gi_00029;
   if (OrderType() == OP_BUY) { 
   Local_Struct_FFFFFFAC[Gi_00029].m_28 = Local_Struct_FFFFFFAC[Gi_00029].m_28 + 1;
   } 
   if (OrderType() == OP_SELL) { 
   Local_Struct_FFFFFFAC[Li_FFF44].m_32 = Local_Struct_FFFFFFAC[Li_FFF44].m_32 + 1;
   }}}}} 
   Li_FFF64 = Li_FFF64 - 1;
   } while (Li_FFF64 >= 0); 
   } 
   if (Fa_i_04 == 0) { 
   tmp_str00026 = Ls_FFFF0;
   Gi_0002D = 0;
   Gi_0002F = 0;
   Gi_00030 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00032 = -1;
   if (Gi_0002F < Gi_00030) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0002F].m_16 == tmp_str00026) {
   if (Gi_0002D == 0) {
   Gi_00032 = Local_Struct_FFFFFFAC[Gi_0002F].m_28;
   break;
   }
   if (Gi_0002D == 1) {
   Gi_00032 = Local_Struct_FFFFFFAC[Gi_0002F].m_32;
   break;
   }}
   Gi_0002F = Gi_0002F + 1;
   Gi_00034 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0002F < Gi_00034); 
   }
   
   Li_FFF40 = Gi_00032;
   tmp_str00028 = Ls_FFFF0;
   Gi_00035 = 1;
   Gi_00037 = 0;
   Gi_00038 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0003A = -1;
   if (Gi_00037 < Gi_00038) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00037].m_16 == tmp_str00028) {
   if (Gi_00035 == 0) {
   Gi_0003A = Local_Struct_FFFFFFAC[Gi_00037].m_28;
   break;
   }
   if (Gi_00035 == 1) {
   Gi_0003A = Local_Struct_FFFFFFAC[Gi_00037].m_32;
   break;
   }}
   Gi_00037 = Gi_00037 + 1;
   Gi_0003C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00037 < Gi_0003C); 
   }
   
   Li_FFF3C = Gi_0003A;
   tmp_str0002A = Ls_FFFE0;
   Gi_0003D = 0;
   Gi_0003F = 0;
   Gi_00040 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00042 = -1;
   if (Gi_0003F < Gi_00040) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0003F].m_16 == tmp_str0002A) {
   if (Gi_0003D == 0) {
   Gi_00042 = Local_Struct_FFFFFFAC[Gi_0003F].m_28;
   break;
   }
   if (Gi_0003D == 1) {
   Gi_00042 = Local_Struct_FFFFFFAC[Gi_0003F].m_32;
   break;
   }}
   Gi_0003F = Gi_0003F + 1;
   Gi_00044 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0003F < Gi_00044); 
   }
   
   Li_FFF38 = Gi_00042;
   tmp_str0002C = Ls_FFFE0;
   Gi_00045 = 1;
   Gi_00047 = 0;
   Gi_00048 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0004A = -1;
   if (Gi_00047 < Gi_00048) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00047].m_16 == tmp_str0002C) {
   if (Gi_00045 == 0) {
   Gi_0004A = Local_Struct_FFFFFFAC[Gi_00047].m_28;
   break;
   }
   if (Gi_00045 == 1) {
   Gi_0004A = Local_Struct_FFFFFFAC[Gi_00047].m_32;
   break;
   }}
   Gi_00047 = Gi_00047 + 1;
   Gi_0004C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00047 < Gi_0004C); 
   }
   
   Li_FFF34 = Gi_0004A;
   Gi_0004C = Li_FFF40 - Li_FFF3C;
   if (Gi_0004C < numeroMassimoOrdiniPerStrumentoFinanziario) { 
   Gi_0004C = Gi_0004A - Li_FFF38;
   if (Gi_0004C < numeroMassimoOrdiniPerStrumentoFinanziario) { 
   Lb_FFFFF = true;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }} 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   } 
   if (Fa_i_04 == 1) { 
   tmp_str0002E = Ls_FFFF0;
   Gi_0004D = 0;
   Gi_0004F = 0;
   Gi_00050 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00052 = -1;
   if (Gi_0004F < Gi_00050) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0004F].m_16 == tmp_str0002E) {
   if (Gi_0004D == 0) {
   Gi_00052 = Local_Struct_FFFFFFAC[Gi_0004F].m_28;
   break;
   }
   if (Gi_0004D == 1) {
   Gi_00052 = Local_Struct_FFFFFFAC[Gi_0004F].m_32;
   break;
   }}
   Gi_0004F = Gi_0004F + 1;
   Gi_00054 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0004F < Gi_00054); 
   }
   
   Li_FFF30 = Gi_00052;
   tmp_str00030 = Ls_FFFF0;
   Gi_00055 = 1;
   Gi_00057 = 0;
   Gi_00058 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0005A = -1;
   if (Gi_00057 < Gi_00058) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00057].m_16 == tmp_str00030) {
   if (Gi_00055 == 0) {
   Gi_0005A = Local_Struct_FFFFFFAC[Gi_00057].m_28;
   break;
   }
   if (Gi_00055 == 1) {
   Gi_0005A = Local_Struct_FFFFFFAC[Gi_00057].m_32;
   break;
   }}
   Gi_00057 = Gi_00057 + 1;
   Gi_0005C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00057 < Gi_0005C); 
   }
   
   Li_FFF2C = Gi_0005A;
   tmp_str00032 = Ls_FFFE0;
   Gi_0005D = 0;
   Gi_0005F = 0;
   Gi_00060 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_00062 = -1;
   if (Gi_0005F < Gi_00060) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_0005F].m_16 == tmp_str00032) {
   if (Gi_0005D == 0) {
   Gi_00062 = Local_Struct_FFFFFFAC[Gi_0005F].m_28;
   break;
   }
   if (Gi_0005D == 1) {
   Gi_00062 = Local_Struct_FFFFFFAC[Gi_0005F].m_32;
   break;
   }}
   Gi_0005F = Gi_0005F + 1;
   Gi_00064 = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_0005F < Gi_00064); 
   }
   
   Li_FFF28 = Gi_00062;
   tmp_str00034 = Ls_FFFE0;
   Gi_00065 = 1;
   Gi_00067 = 0;
   Gi_00068 = ArraySize(Local_Struct_FFFFFFAC);
   Gi_0006A = -1;
   if (Gi_00067 < Gi_00068) {
   do { 
   if (Local_Struct_FFFFFFAC[Gi_00067].m_16 == tmp_str00034) {
   if (Gi_00065 == 0) {
   Gi_0006A = Local_Struct_FFFFFFAC[Gi_00067].m_28;
   break;
   }
   if (Gi_00065 == 1) {
   Gi_0006A = Local_Struct_FFFFFFAC[Gi_00067].m_32;
   break;
   }}
   Gi_00067 = Gi_00067 + 1;
   Gi_0006C = ArraySize(Local_Struct_FFFFFFAC);
   } while (Gi_00067 < Gi_0006C); 
   }
   
   Li_FFF24 = Gi_0006A;
   Gi_0006C = Li_FFF2C - Li_FFF30;
   if (Gi_0006C < numeroMassimoOrdiniPerStrumentoFinanziario) { 
   Gi_0006C = Li_FFF28 - Gi_0006A;
   if (Gi_0006C < numeroMassimoOrdiniPerStrumentoFinanziario) { 
   Lb_FFFFF = true;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   }} 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   return Lb_FFFFF;
   } 
   Lb_FFFFF = false;
   ArrayFree(Local_Struct_FFFFFF78);
   ArrayFree(Local_Struct_FFFFFFAC);
   
   return Lb_FFFFF;
}

bool func_1089(string Fa_s_00, string Fa_s_01)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   bool Lb_FFFFF;
   int Li_FFFC4;

   if (Is_1CC08 == "") { 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   } 
   string Ls_FFFC8[];
   tmp_str00001 = ",";
   Gst_00001 = (short)StringGetCharacter(",", 0);
   StringSplit(Is_1CC08, Gst_00001, Ls_FFFC8);
   Li_FFFC4 = 0;
   if (Li_FFFC4 < ArraySize(Ls_FFFC8)) { 
   do { 
   string Ls_FFF90[];
   Gst_00003 = (short)StringGetCharacter("!", 0);
   StringSplit(tmp_str00007, Gst_00003, Ls_FFF90);
   if (ArraySize(Ls_FFF90) >= 2) { 
   if ((Fa_s_00 == Ls_FFF90[0] && Fa_s_01 == Ls_FFF90[1])
   || (Fa_s_00 == Ls_FFF90[1] && Fa_s_01 == Ls_FFF90[0])) {
   
   Lb_FFFFF = false;
   ArrayFree(Ls_FFF90);
   ArrayFree(Ls_FFFC8);
   return Lb_FFFFF;
   }} 
   ArrayFree(Ls_FFF90);
   Li_FFFC4 = Li_FFFC4 + 1;
   } while (Li_FFFC4 < ArraySize(Ls_FFFC8)); 
   } 
   Lb_FFFFF = true;
   ArrayFree(Ls_FFFC8);
   
   return Lb_FFFFF;
}

bool func_1090(string Fa_s_00, string Fa_s_01)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   bool Lb_FFFFF;
   int Li_FFFC4;

   if (listaSpreadDaTradare1 == "") { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   string Ls_FFFC8[];
   Gst_00002 = (short)StringGetCharacter(",", 0);
   StringSplit(listaSpreadDaTradare1, Gst_00002, Ls_FFFC8);
   Gi_00002 = 0;
   Li_FFFC4 = Gi_00002;
   if (Gi_00002 < ArraySize(Ls_FFFC8)) { 
   do { 
   string Ls_FFF90[];
   tmp_str00008 = Ls_FFFC8[Li_FFFC4];
   Gst_00004 = (short)StringGetCharacter("!", 0);
   StringSplit(tmp_str00008, Gst_00004, Ls_FFF90);
   if (ArraySize(Ls_FFF90) >= 2) { 
   if ((Fa_s_00 == Ls_FFF90[0] && Fa_s_01 == Ls_FFF90[1])
   || (Fa_s_00 == Ls_FFF90[1] && Fa_s_01 == Ls_FFF90[0])) {
   
   Lb_FFFFF = true;
   ArrayFree(Ls_FFF90);
   ArrayFree(Ls_FFFC8);
   return Lb_FFFFF;
   }} 
   ArrayFree(Ls_FFF90);
   Li_FFFC4 = Li_FFFC4 + 1;
   } while (Li_FFFC4 < ArraySize(Ls_FFFC8)); 
   } 
   Lb_FFFFF = false;
   ArrayFree(Ls_FFFC8);
   
   return Lb_FFFFF;
}

void func_1093(Coppia &FuncArg_Struct_00000000, int Fa_i_01, int Fa_i_02, string Fa_s_03, string Fa_s_04, bool &FuncArg_Boolean_00000005, bool &FuncArg_Boolean_00000006)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   double Ld_FFFF8;
   double Ld_FFFF0;
   string Ls_FFFE0;
   bool Lb_FFFDF;
   bool Lb_FFFDE;

   tmp_str00000 = orarioOperativita;
   if (func_1078(tmp_str00000) != true) { 
   tmp_str00001 = orarioOperativita2;
   if (!func_1078(tmp_str00001)) return; 
   } 
   Gl_00000 = iTime(Fa_s_03, 0, 0);
   if (Gl_00000 != iTime(Fa_s_04, 0, 0)) return; 
   if (calcolaLottiAutomaticamente != true) { 
   Gd_00000 = lottiBase;
   } 
   else { 
   tmp_str00002 = Fa_s_03;
   tmp_str00003 = Fa_s_04;
   Gd_00000 = func_1037(tmp_str00003, tmp_str00002, 0, lottiBase);
   } 
   Ld_FFFF8 = Gd_00000;
   if (calcolaLottiAutomaticamente != true) { 
   Gd_00000 = lottiBase;
   } 
   else { 
   tmp_str00004 = Fa_s_04;
   tmp_str00005 = Fa_s_03;
   Gd_00000 = func_1037(tmp_str00005, tmp_str00004, lottiBase, 0);
   } 
   Ld_FFFF0 = Gd_00000;
   if ((Ld_FFFF8 <= 0) || (Gd_00000 <= 0)) { 
   
   tmp_str00008 = "Errore nel calcolo del lotto " + Fa_s_03;
   tmp_str00008 = tmp_str00008 + "-";
   tmp_str00008 = tmp_str00008 + Fa_s_04;
   Alert(tmp_str00008);
   return ;
   } 
   if (numeroMassimoOperazioniInGain != 0) { 
   tmp_str00007 = Fa_s_04;
   tmp_str00009 = Fa_s_03;
   if (!func_1080(tmp_str00009, tmp_str00007)) return; 
   } 
   if ((FuncArg_Struct_00000000.m_76 < FuncArg_Struct_00000000.m_68)) { 
   tmp_str0000B = "SHORT";
   } 
   else { 
   tmp_str0000B = "LONG";
   } 
   Ls_FFFE0 = tmp_str0000B;
   Gb_00002 = (tmp_str0000B == "LONG");
   if (Gb_00002) { 
   Gb_00002 = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_00002) { 
   Gb_00002 = (FuncArg_Struct_00000000.m_40 >= valoreOverlayPerIngresso);
   } 
   if (Gb_00002) { 
   Gb_00002 = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_00002) { 
   Gb_00002 = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_00002 = FuncArg_Struct_00000000.m_85;
   }} 
   Lb_FFFDF = Gb_00002;
   Gb_00002 = (Ls_FFFE0 == "SHORT");
   if (Gb_00002) { 
   Gb_00002 = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_00002) { 
   Gb_00002 = (FuncArg_Struct_00000000.m_40 >= valoreOverlayPerIngresso);
   } 
   if (Gb_00002) { 
   Gb_00002 = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_00002) { 
   Gb_00002 = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_00002 = FuncArg_Struct_00000000.m_86;
   }} 
   Lb_FFFDE = Gb_00002;

   FuncArg_Boolean_00000005 = Lb_FFFDF;
   FuncArg_Boolean_00000006 = Lb_FFFDE;
   if (Il_13E88[Fa_i_02] != iTime(Fa_s_03, 0, 0)) { 
   Ii_12EB4[Fa_i_02] = 0;
   } 
   if (Lb_FFFDF) { 
   tmp_str00011 = Fa_s_03;
   tmp_str00012 = Fa_s_04;
   tmp_str00013 = Fa_s_03;
   if (func_1085(Fa_i_02, tmp_str00013, tmp_str00012, tmp_str00011, 0)) { 
   tmp_str00014 = Fa_s_04;
   tmp_str00015 = Fa_s_04;
   tmp_str00016 = Fa_s_03;
   if (func_1085(Fa_i_02, tmp_str00016, tmp_str00015, tmp_str00014, 1)) { 
   tmp_str00017 = Fa_s_03;
   tmp_str00018 = Fa_s_04;
   tmp_str00019 = Fa_s_03;
   if (func_1086(Fa_i_02, tmp_str00019, tmp_str00018, tmp_str00017, 0)) { 
   tmp_str0001A = Fa_s_04;
   tmp_str0001B = Fa_s_04;
   tmp_str0001C = Fa_s_03;
   if (func_1086(Fa_i_02, tmp_str0001C, tmp_str0001B, tmp_str0001A, 1)) { 
   tmp_str0001F = "LS";
   tmp_str0001E = Fa_s_04;
   tmp_str00020 = Fa_s_03;
   if (func_1041(tmp_str00020, tmp_str0001E, Ii_1D234, tmp_str0001F) != true) { 
   tmp_str00023 = "LS";
   tmp_str00022 = Fa_s_04;
   tmp_str00024 = Fa_s_03;
   if (func_1045(tmp_str00024, tmp_str00022, Ii_1D234, tmp_str00023) != true) { 
   tmp_str00027 = "SS";
   tmp_str00026 = Fa_s_04;
   tmp_str00028 = Fa_s_03;
   tmp_str0002B = "SS";
   tmp_str0002A = Fa_s_04;
   tmp_str0002C = Fa_s_03;
   if (Ib_09C80 || (!func_1041(tmp_str00028, tmp_str00026, Ii_1D234, tmp_str00027)
   && !func_1045(tmp_str0002C, tmp_str0002A, Ii_1D234, tmp_str0002B))) {
   
   if (Il_0EFCC[Fa_i_02] != iTime(Fa_s_03, 0, 0) && Fa_i_01 < numeroMassimoCoppieOperative) { 
   if (limitaIngressoNuoveOperazioniSeSuperatoDD != true) { 
   Gb_00008 = true;
   } 
   else { 
   if (tipoControlloFlottante == 0) { 
   Gd_00009 = valoreLimite;
   } 
   else { 
   Gd_00009 = ((AccountInfoDouble(ACCOUNT_BALANCE) * valoreLimite) / 100);
   } 

   Gd_0000A = 0;
   Gi_0000B = OrdersTotal() - 1;
   Gi_0000C = Gi_0000B;
   if (Gi_0000B >= 0) { 
   do { 
   if (OrderSelect(Gi_0000C, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_0000B = OrderMagicNumber();
   Gi_0000D = MagicInp + 1000;
   if (Gi_0000B < Gi_0000D) { 
   Gd_0000D = OrderProfit();
   Gd_0000D = (Gd_0000D + OrderCommission());
   Gd_0000A = ((Gd_0000D + OrderSwap()) + Gd_0000A);
   }} 
   Gi_0000C = Gi_0000C - 1;
   } while (Gi_0000C >= 0); 
   } 
   Gd_0000D = -Gd_00009;
   if ((Gd_0000A < 0) && (Gd_0000A < Gd_0000D)) {
   Gb_00008 = false;
   }
   else{
   Gb_00008 = true;
   }} 
   if (Gb_00008) { 
   tmp_str0002E = IntegerToString(MagicInp, 0, 32);
   tmp_str0002E = tmp_str0002E + "_newgrid";
   if (GlobalVariableGet(tmp_str0002E) != 0 && Ii_12EB4[Fa_i_02] < 3) { 
   tmp_str00030 = "Size Calcolate " + Fa_s_03;
   tmp_str00030 = tmp_str00030 + "-";
   tmp_str00030 = tmp_str00030 + Fa_s_04;
   tmp_str00030 = tmp_str00030 + ":";
   tmp_str00030 = tmp_str00030 + DoubleToString(Ld_FFFF8, 2);
   tmp_str00030 = tmp_str00030 + " " ;
   tmp_str00030 = tmp_str00030 + DoubleToString(Ld_FFFF0, 2);
   Print(tmp_str00030);
   Ii_09CAC = Ii_09CAC + 1;
   tmp_str00035 = "LS_Master";
   tmp_str00035 = tmp_str00035 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00034 = Fa_s_04;
   tmp_str00036 = Fa_s_03;
   tmp_str00037 = Fa_s_03;
   func_1046(tmp_str00037, tmp_str00036, tmp_str00034, Ii_1D234, 0, Ld_FFFF8, SymbolInfoDouble(Fa_s_03, SYMBOL_ASK), tmp_str00035, 16711680, 0, 0);

   tmp_str0003A = "LS_Master" + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00039 = Fa_s_04;
   tmp_str0003B = Fa_s_03;
   tmp_str0003C = Fa_s_04;
   func_1046(tmp_str0003C, tmp_str0003B, tmp_str00039, Ii_1D234, 1, Ld_FFFF0, SymbolInfoDouble(Fa_s_04, SYMBOL_BID), tmp_str0003A, 255, 0, 0);
   tmp_str0003F = "Valori ingresso : " + DoubleToString(FuncArg_Struct_00000000.m_40, 2);
   tmp_str0003F = tmp_str0003F + " " ;
   tmp_str0003F = tmp_str0003F + DoubleToString(FuncArg_Struct_00000000.m_56, 2);
   Print(tmp_str0003F);
   Gl_00010 = iTime(Fa_s_03, 0, 0);
   Il_0EFCC[Fa_i_02] = Gl_00010;
   Id_09D80[Fa_i_02] = 0;
   Ii_12EB4[Fa_i_02] = Ii_12EB4[Fa_i_02] + 1;
   }}}}}}}}}}} 
   if (Lb_FFFDE) { 
   tmp_str0003E = Fa_s_03;
   tmp_str00040 = Fa_s_04;
   tmp_str00041 = Fa_s_03;
   if (func_1085(Fa_i_02, tmp_str00041, tmp_str00040, tmp_str0003E, 1)) { 
   tmp_str00042 = Fa_s_04;
   tmp_str00043 = Fa_s_04;
   tmp_str00044 = Fa_s_03;
   if (func_1085(Fa_i_02, tmp_str00044, tmp_str00043, tmp_str00042, 0)) { 
   tmp_str00045 = Fa_s_03;
   tmp_str00046 = Fa_s_04;
   tmp_str00047 = Fa_s_03;
   if (func_1086(Fa_i_02, tmp_str00047, tmp_str00046, tmp_str00045, 1)) { 
   tmp_str00048 = Fa_s_04;
   tmp_str00049 = Fa_s_04;
   tmp_str0004A = Fa_s_03;
   if (func_1086(Fa_i_02, tmp_str0004A, tmp_str00049, tmp_str00048, 0)) { 
   tmp_str0004D = "SS";
   tmp_str0004C = Fa_s_04;
   tmp_str0004E = Fa_s_03;
   if (func_1041(tmp_str0004E, tmp_str0004C, Ii_1D234, tmp_str0004D) != true) { 
   tmp_str00050 = "SS";
   tmp_str0004F = Fa_s_04;
   tmp_str00051 = Fa_s_03;
   if (func_1045(tmp_str00051, tmp_str0004F, Ii_1D234, tmp_str00050) != true) { 
   tmp_str00054 = "LS";
   tmp_str00053 = Fa_s_04;
   tmp_str00055 = Fa_s_03;
   tmp_str00058 = "LS";
   tmp_str00057 = Fa_s_04;
   tmp_str00059 = Fa_s_03;
   if (Ib_09C80 || (!func_1041(tmp_str00055, tmp_str00053, Ii_1D234, tmp_str00054)
   && !func_1045(tmp_str00059, tmp_str00057, Ii_1D234, tmp_str00058))) {
   
   if (Il_10F40[Fa_i_02] != iTime(Fa_s_03, 0, 0) && Fa_i_01 < numeroMassimoCoppieOperative) { 
   if (limitaIngressoNuoveOperazioniSeSuperatoDD != true) { 
   Gb_00014 = true;
   } 
   else { 
   if (tipoControlloFlottante == 0) { 
   Gd_00015 = valoreLimite;
   } 
   else { 
   Gd_00015 = ((AccountInfoDouble(ACCOUNT_BALANCE) * valoreLimite) / 100);
   } 
   Gd_00016 = 0;
   Gi_00017 = OrdersTotal() - 1;
   Gi_00018 = Gi_00017;
   if (Gi_00017 >= 0) { 
   do { 
   if (OrderSelect(Gi_00018, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00017 = OrderMagicNumber();
   Gi_00019 = MagicInp + 1000;
   if (Gi_00017 < Gi_00019) { 
   Gd_00019 = OrderProfit();
   Gd_00019 = (Gd_00019 + OrderCommission());
   Gd_00016 = ((Gd_00019 + OrderSwap()) + Gd_00016);
   }} 
   Gi_00018 = Gi_00018 - 1;
   } while (Gi_00018 >= 0); 
   } 
   Gd_00019 = -Gd_00015;
   if ((Gd_00016 < 0) && (Gd_00016 < Gd_00019)) {
   Gb_00014 = false;
   }
   else{
   Gb_00014 = true;
   }} 
   if (Gb_00014) { 
   tmp_str0005B = IntegerToString(MagicInp, 0, 32);
   tmp_str0005B = tmp_str0005B + "_newgrid";
   if (GlobalVariableGet(tmp_str0005B) != 0 && Ii_12EB4[Fa_i_02] < 3) { 
   tmp_str0005F = "Size Calcolate " + Fa_s_03;
   tmp_str0005F = tmp_str0005F + "-";
   tmp_str0005F = tmp_str0005F + Fa_s_04;
   tmp_str0005F = tmp_str0005F + ":";
   tmp_str0005F = tmp_str0005F + DoubleToString(Ld_FFFF8, 2);
   tmp_str0005F = tmp_str0005F + " " ;
   tmp_str0005F = tmp_str0005F + DoubleToString(Ld_FFFF0, 2);
   Print(tmp_str0005F);
   Ii_09CAC = Ii_09CAC + 1;
   tmp_str00064 = "SS_Master";
   tmp_str00064 = tmp_str00064 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00063 = Fa_s_04;
   tmp_str00065 = Fa_s_03;
   tmp_str00066 = Fa_s_03;
   func_1046(tmp_str00066, tmp_str00065, tmp_str00063, Ii_1D234, 1, Ld_FFFF8, SymbolInfoDouble(Fa_s_03, SYMBOL_BID), tmp_str00064, 255, 0, 0);
   tmp_str00068 = "SS_Master";
   tmp_str00068 = tmp_str00068 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00067 = Fa_s_04;
   tmp_str00069 = Fa_s_03;
   tmp_str0006A = Fa_s_04;
   func_1046(tmp_str0006A, tmp_str00069, tmp_str00067, Ii_1D234, 0, Ld_FFFF0, SymbolInfoDouble(Fa_s_04, SYMBOL_ASK), tmp_str00068, 16711680, 0, 0);
   Gl_0001B = iTime(Fa_s_03, 0, 0);
   Il_10F40[Fa_i_02] = Gl_0001B;
   Id_0A714[Fa_i_02] = 0;
   Ii_12EB4[Fa_i_02] = Ii_12EB4[Fa_i_02] + 1;
   }}}}}}}}}}} 
   Gl_0001E = iTime(Fa_s_03, 0, 0);
   Il_13E88[Fa_i_02] = Gl_0001E;
   
}

bool func_1094(string Fa_s_00, string Fa_s_01, string Fa_s_02, int &Fa_i_03, int &Fa_i_04, int &Fa_i_05, double &Fa_d_06, double &Fa_d_07, double &Fa_d_08, double &Fa_d_09)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   int Li_FFFF8;
   string Ls_FFFE8;
   bool Lb_FFFFF;
   bool Lb_FFFE7;

   Fa_i_03 = 0;
   Li_FFFF8 = OrdersTotal() - 1;
   if (Li_FFFF8 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFF8, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFE8 = OrderComment();
   if (Ib_09C81) { 
   Gi_00000 = StringFind(OrderComment(), "from");
   if (Gi_00000 >= 0) { 
   Gi_00000 = (int)StringToInteger("");
   Gi_00001 = 0;
   Gi_00000 = 0;
   Gi_00002 = HistoryTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 1)) { 
   Gl_00002 = OrderOpenTime();
   tmp_str00008 = IntegerToString(MagicInp, 0, 32);
   tmp_str00008 = tmp_str00008 + "_PMPtimeFlat";
   Gl_00004 = (datetime)(GlobalVariableGet(tmp_str00008) * 1000);
   if (Gl_00002 >= Gl_00004) { 
   Gi_00004 = StringFind(OrderComment(), "to #");
   if (Gi_00004 >= 0) { 
   Gi_00004 = (int)StringToInteger("");
   if (Gi_00004 == Gi_00000) { 
   Gi_00000 = OrderTicket();
   Gi_00001 = Gi_00000;
   }}}} 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   Gi_00004 = Gi_00001;
   Gi_00005 = ArraySize(Is_0B074) - 1;
   Gi_00006 = Gi_00005;
   tmp_str00014 = "";
   if (Gi_00005 >= 0) {
   do { 
   string Ls_FFFB0[];
   tmp_str00010 = Is_0B074[Gi_00006];
   Gst_00008 = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str00010, Gst_00008, Ls_FFFB0);
   if (ArraySize(Ls_FFFB0) >= 2) {
   tmp_str00014 = (string)Gi_00004;
   if (Ls_FFFB0[0] == tmp_str00014) {
   tmp_str00014 = Ls_FFFB0[1];
   ArrayFree(Ls_FFFB0);
   break;
   }}
   ArrayFree(Ls_FFFB0);
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   }
   
   Ls_FFFE8 = tmp_str00014;
   if (tmp_str00014 == "") { 
   tmp_str00015 = "";
   tmp_str00018 = "ERRORE determinazione ordine, sistema sospeso PSpr " + tmp_str00014;
   tmp_str00017 = Fa_s_01;
   tmp_str00019 = Fa_s_00;
   func_1050(-1, tmp_str00019, tmp_str00017, tmp_str00018, tmp_str00015, 0);
   Ib_1CED0 = true;
   Lb_FFFFF = false;
   return Lb_FFFFF;
   }}} 
   Lb_FFFE7 = false;
   if (Ib_09C81) { 
   Lb_FFFE7 = (Ls_FFFE8 == Fa_s_02);
   } 
   else { 
   tmp_str0001E = ServerAddress();
   tmp_str0001F = TerminalName();
   
   if (Fa_s_02 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFE7 = true;
   }} 
   if (Fa_s_02 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFE7 = true;
   }}} 
   if (Lb_FFFE7 && OrderSelect(Li_FFFF8, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) {
   
   if (OrderSymbol() == Fa_s_00) { 
   Fa_i_03 = Fa_i_03 + 1;
   } 
   if (OrderSymbol() == Fa_s_00) { 
   Fa_i_04 = Fa_i_04 + 1;
   } 
   if (OrderSymbol() == Fa_s_01) { 
   Fa_i_05 = Fa_i_05 + 1;
   } 
   if ((Fa_d_06 == 0) && OrderSymbol() == Fa_s_00) { 
   Fa_d_06 = OrderOpenPrice();
   Fa_d_08 = OrderLots();
   } 
   if ((Fa_d_09 == 0) && OrderSymbol() == Fa_s_01) { 
   Fa_d_07 = OrderOpenPrice();
   Fa_d_09 = OrderLots();
   }}}}} 
   Li_FFFF8 = Li_FFFF8 - 1;
   } while (Li_FFFF8 >= 0); 
   } 
   if ((Fa_d_06 == 0)) return false; 
   Lb_FFFFF = true;
   return Lb_FFFFF;
   
   Lb_FFFFF = false;
   
   return Lb_FFFFF;
}

void func_1095(Coppia &FuncArg_Struct_00000000, int Fa_i_01, string Fa_s_02, string Fa_s_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   string tmp_str00074;
   string tmp_str00075;
   string tmp_str00076;
   string tmp_str00077;
   string tmp_str00078;
   string tmp_str00079;
   string tmp_str0007A;
   string tmp_str0007B;
   string tmp_str0007C;
   string tmp_str0007D;
   string tmp_str0007E;
   string tmp_str0007F;
   string tmp_str00080;
   string tmp_str00081;
   string tmp_str00082;
   string tmp_str00083;
   string tmp_str00084;
   string tmp_str00085;
   string tmp_str00086;
   string tmp_str00087;
   string tmp_str00088;
   string tmp_str00089;
   string tmp_str0008A;
   string tmp_str0008B;
   string tmp_str0008C;
   string tmp_str0008D;
   string tmp_str0008E;
   string tmp_str0008F;
   string tmp_str00090;
   string tmp_str00091;
   string tmp_str00092;
   string tmp_str00093;
   string tmp_str00094;
   string tmp_str00095;
   string tmp_str00096;
   double Ld_FFFF8;
   double Ld_FFFF0;
   string Ls_FFFE0;
   double Ld_FFFD8;
   double Ld_FFFD0;
   int Li_FFFCC;
   int Li_FFFC8;
   int Li_FFFC4;
   bool Lb_FFFC3;
   bool Lb_FFFC2;
   int Li_FFFBC;
   int Li_FFFB8 = 0;
   int Li_FFFB4;
   int Li_FFFB0;
   int Li_FFFAC;
   int Li_FFFA8;
   bool Lb_FFFA7;
   bool Lb_FFFA6;
   double Ld_FFF98;
   double Ld_FFF90;
   double Ld_FFF88;
   double Ld_FFF80;
   string Ls_FFF70;
   bool Lb_FFF6F;
   bool Lb_FFF6E;
   bool Lb_FFF6D;
   bool Lb_FFF6C;
   string Ls_FFF60;
   string Ls_FFF50;
   string Ls_FFF40;
   string Ls_FFF30;
   bool Lb_FFF2F;
   bool Lb_FFF2E;
   int Li_FFF28;
   int Li_FFF24;
   int Li_FFF20;
   int Li_FFF1C;
   int Li_FFF18;
   int Li_FFF14;
   bool Lb_FFF13;
   bool Lb_FFF12;
   double Ld_FFF08;
   double Ld_FFF00;
   double Ld_FFEF8;
   double Ld_FFEF0;
   string Ls_FFEE0;
   bool Lb_FFEDF;
   bool Lb_FFEDE;
   bool Lb_FFEDD;
   bool Lb_FFEDC;
   string Ls_FFED0;
   string Ls_FFEC0;
   string Ls_FFEB0;
   string Ls_FFEA0;

   if (tipoPiramidazione1 == 0 && tipoPiramidazione2 == 0 && tipoPiramidazione3 == 0) { 
   if (tipoPiramidazione4 == 0) return; 
   } 
   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Ls_FFFE0 = "";
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Li_FFFCC = 0;
   Li_FFFC8 = 0;
   Li_FFFC4 = 0;
   if (Il_1ACB8[Fa_i_01] != iTime(Fa_s_02, 0, 0)) { 
   Ii_19CE4[Fa_i_01] = 0;
   } 
   tmp_str00009 = "LS";
   tmp_str00008 = Fa_s_03;
   tmp_str0000A = Fa_s_02;
   if (func_1094(tmp_str0000A, tmp_str00008, tmp_str00009, Li_FFFCC, Li_FFFC8, Li_FFFC4, Ld_FFFF8, Ld_FFFF0, Ld_FFFD8, Ld_FFFD0)) { 
   if (limitaIngressoGridOperazioniSeSuperatoDD != true) { 
   Gb_00003 = true;
   } 
   else { 
   if (tipoControlloFlottante == 0) { 
   Gd_00004 = valoreLimite;
   } 
   else { 
   Gd_00004 = ((AccountInfoDouble(ACCOUNT_BALANCE) * valoreLimite) / 100);
   } 
   Gd_00005 = 0;
   Gi_00006 = OrdersTotal() - 1;
   Gi_00007 = Gi_00006;
   if (Gi_00006 >= 0) { 
   do { 
   if (OrderSelect(Gi_00007, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00006 = OrderMagicNumber();
   Gi_00008 = MagicInp + 1000;
   if (Gi_00006 < Gi_00008) { 
   Gd_00008 = OrderProfit();
   Gd_00008 = (Gd_00008 + OrderCommission());
   Gd_00005 = ((Gd_00008 + OrderSwap()) + Gd_00005);
   }} 
   Gi_00007 = Gi_00007 - 1;
   } while (Gi_00007 >= 0); 
   } 
   Gd_00008 = -Gd_00004;
   if ((Gd_00005 < 0) && (Gd_00005 < Gd_00008)) {
   Gb_00003 = false;
   }
   else{
   Gb_00003 = true;
   }} 
   if (Gb_00003) { 
   Lb_FFFC3 = false;
   Lb_FFFC2 = false;
   if (utilizzaPiramidazioneIndipendente) { 
   Gb_0000A = (numeroMassimoPiramidazioni == 0);
   if (Gb_0000A != true) { 
   Gb_0000A = (Li_FFFC8 < numeroMassimoPiramidazioni);
   } 
   Lb_FFFC3 = Gb_0000A;
   Gb_0000A = (numeroMassimoPiramidazioni == 0);
   if (Gb_0000A != true) { 
   Gb_0000A = (Li_FFFC4 < numeroMassimoPiramidazioni);
   } 
   Lb_FFFC2 = Gb_0000A;
   } 
   else { 
   Gb_0000A = (numeroMassimoPiramidazioni == 0);
   if (Gb_0000A != true) { 
   Gb_0000A = (Li_FFFCC < numeroMassimoPiramidazioni);
   } 
   Lb_FFFC2 = Gb_0000A;
   Lb_FFFC3 = Gb_0000A;
   } 
   Li_FFFBC = 0;
   Li_FFFB4 = 0;
   Li_FFFB0 = tipoPiramidazione1;
   if (utilizzaPiramidazioneIndipendente) { 
   Gi_0000A = Li_FFFC8;
   } 
   else { 
   Gi_0000A = Li_FFFCC;
   } 
   Li_FFFAC = Gi_0000A;
   if (utilizzaPiramidazioneIndipendente) { 
   Gi_0000A = Li_FFFC4;
   } 
   else { 
   Gi_0000A = Li_FFFCC;
   } 
   Li_FFFA8 = Gi_0000A;
   if (numeroPiramidazioneStep2 != 0 && Li_FFFAC - 1 >= numeroPiramidazioneStep2
   && (Li_FFFAC - 1 < numeroPiramidazioneStep3 || numeroPiramidazioneStep3 == 0)) {
   
   Li_FFFBC = pointsDistanzaPiramidazioneStep2;
   Li_FFFB8 = tipoPiramidazione2;
   }
   else{
   if (numeroPiramidazioneStep3 != 0 && Li_FFFC8 - 1 >= numeroPiramidazioneStep3
   && (Li_FFFC8 - 1 < numeroPiramidazioneStep4 || numeroPiramidazioneStep4 == 0)) {
   
   Li_FFFBC = pointsDistanzaPiramidazioneStep3;
   Li_FFFB8 = tipoPiramidazione3;
   }
   else{
   if (numeroPiramidazioneStep4 != 0) { 
   Gi_0000A = Li_FFFC8 - 1;
   if (Gi_0000A >= numeroPiramidazioneStep4) { 
   Li_FFFBC = pointsDistanzaPiramidazioneStep4;
   Li_FFFB8 = tipoPiramidazione4;
   }}}} 
   if (numeroPiramidazioneStep2 != 0 && Li_FFFA8 - 1 >= numeroPiramidazioneStep2
   && (Li_FFFA8 - 1 < numeroPiramidazioneStep3 || numeroPiramidazioneStep3 == 0)) {
   
   Li_FFFB4 = pointsDistanzaPiramidazioneStep2;
   Li_FFFB0 = tipoPiramidazione2;
   }
   else{
   if (numeroPiramidazioneStep3 != 0 && Li_FFFC4 - 1 >= numeroPiramidazioneStep3
   && (Li_FFFC4 - 1 < numeroPiramidazioneStep4 || numeroPiramidazioneStep4 == 0)) {
   
   Li_FFFB4 = pointsDistanzaPiramidazioneStep3;
   Li_FFFB0 = tipoPiramidazione3;
   }
   else{
   if (numeroPiramidazioneStep4 != 0) { 
   Gi_0000A = Li_FFFC4 - 1;
   if (Gi_0000A >= numeroPiramidazioneStep4) { 
   Li_FFFB4 = pointsDistanzaPiramidazioneStep4;
   Li_FFFB0 = tipoPiramidazione4;
   }}}} 
   Lb_FFFA7 = false;
   if (utilizzaPiramidazioneIndipendente != true) { 
   Gd_0000A = (Ld_FFFF8 - SymbolInfoDouble(Fa_s_02, SYMBOL_ASK));
   if ((Gd_0000A >= (Li_FFFBC * SymbolInfoDouble(Fa_s_02, SYMBOL_POINT))) != true) { 
   Gb_0000A = (Li_FFFBC == 0);
   } 
   Lb_FFFA7 = Gb_0000A;
   } 
   else { 
   Gd_0000A = (Ld_FFFF8 - SymbolInfoDouble(Fa_s_02, SYMBOL_ASK));
   if ((Gd_0000A >= (Li_FFFBC * SymbolInfoDouble(Fa_s_02, SYMBOL_POINT))) != true) { 
   Gb_0000A = (Li_FFFBC == 0);
   } 
   Lb_FFFA7 = Gb_0000A;
   } 
   Lb_FFFA6 = false;
   if (utilizzaPiramidazioneIndipendente != true) { 
   if (misuraDistanzaAncheSuSecondoStrumento != true) { 
   Gb_0000A = Lb_FFFA7;
   } 
   else { 
   Gd_0000B = (SymbolInfoDouble(Fa_s_03, SYMBOL_BID) - Ld_FFFF0);
   if ((Gd_0000B >= (Li_FFFB4 * SymbolInfoDouble(Fa_s_03, SYMBOL_POINT))) != true) { 
   Gb_0000B = (Li_FFFB4 == 0);
   } 
   Gb_0000A = Gb_0000B;
   } 
   Lb_FFFA6 = Gb_0000A;
   } 
   else { 
   Gd_0000B = (SymbolInfoDouble(Fa_s_03, SYMBOL_BID) - Ld_FFFF0);
   if ((Gd_0000B >= (Li_FFFB4 * SymbolInfoDouble(Fa_s_03, SYMBOL_POINT))) != true) { 
   Gb_0000B = (Li_FFFB4 == 0);
   } 
   Lb_FFFA6 = Gb_0000B;
   } 
   Ld_FFF98 = Ld_FFFD8;
   Ld_FFF90 = Ld_FFFD0;
   if (tipoIncrementoSize != 0) { 
   if (tipoIncrementoSize == 1) { 
   Gd_0000D = valoreIncremento;
   Ld_FFF98 = (Ld_FFFD8 * Gd_0000D);
   Ld_FFF98 = Ld_FFF98;
   Gd_0000D = valoreIncremento;
   Ld_FFF90 = (Ld_FFFD0 * Gd_0000D);
   Gd_0000D = Ld_FFF90;
   Ld_FFF90 = Gd_0000D;
   } 
   else { 
   if (tipoIncrementoSize == 2) { 
   Gd_0000D = valoreIncremento;
   Ld_FFF98 = (Ld_FFF98 + Gd_0000D);
   Gd_0000D = Ld_FFF98;
   Ld_FFF98 = Gd_0000D;
   Gd_0000D = valoreIncremento;
   Ld_FFF90 = (Ld_FFF90 + Gd_0000D);
   Gd_0000D = Ld_FFF90;
   Ld_FFF90 = Gd_0000D;
   }} 
   Ld_FFF88 = SymbolInfoDouble(Fa_s_02, 34);
   if ((Ld_FFF88 <= SymbolInfoDouble(Fa_s_02, 35))) { 
   do { 
   Gd_0000D = Ld_FFF88;
   if ((Gd_0000D >= Ld_FFF98)) { 
   Gd_0000D = Ld_FFF88;
   Ld_FFF98 = Gd_0000D;
   break; 
   } 
   Ld_FFF88 = (Ld_FFF88 + SymbolInfoDouble(Fa_s_02, 36));
   } while (Ld_FFF88 <= SymbolInfoDouble(Fa_s_02, 35)); 
   } 
   Ld_FFF80 = SymbolInfoDouble(Fa_s_03, 34);
   if ((Ld_FFF80 <= SymbolInfoDouble(Fa_s_03, 35))) { 
   do { 
   Gd_0000E = Ld_FFF80;
   if ((Gd_0000E >= Ld_FFF90)) { 
   Gd_0000E = Ld_FFF80;
   Ld_FFF90 = Gd_0000E;
   break; 
   } 
   Ld_FFF80 = (Ld_FFF80 + SymbolInfoDouble(Fa_s_03, 36));
   } while (Ld_FFF80 <= SymbolInfoDouble(Fa_s_03, 35)); 
   }} 
   if ((FuncArg_Struct_00000000.m_76 < FuncArg_Struct_00000000.m_68)) { 
   tmp_str00016 = "SHORT";
   } 
   else { 
   tmp_str00016 = "LONG";
   } 
   Ls_FFF70 = tmp_str00016;
   Gb_00010 = (tmp_str00016 == "LONG");
   if (Gb_00010) { 
   Gb_00010 = (FuncArg_Struct_00000000.m_40 > valoreOverlayPerIngresso);
   } 
   if (Gb_00010) { 
   Gb_00010 = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_00010) { 
   Gb_00010 = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_00010) { 
   Gb_00010 = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_00010 = FuncArg_Struct_00000000.m_85;
   }} 
   Lb_FFF6F = Gb_00010;
   tmp_str00019 = commentoAggiuntivo;
   tmp_str0001A = Is_1CC08;
   
   Gb_00010 = (Ls_FFF70 == "SHORT");
   if (Gb_00010) { 
   Gb_00010 = (FuncArg_Struct_00000000.m_40 > valoreOverlayPerIngresso);
   } 
   if (Gb_00010) { 
   Gb_00010 = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_00010) { 
   Gb_00010 = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_00010) { 
   Gb_00010 = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_00010 = FuncArg_Struct_00000000.m_86;
   }} 
   Lb_FFF6E = Gb_00010;
   if (Lb_FFF6F && FuncArg_Struct_00000000.m_84) { 
   tmp_str0001C = "Reset permesso trade LONG PIRAMIDAZIONE per valore Overlay di " + Fa_s_02;
   
   tmp_str0001C = tmp_str0001C + "e";
   tmp_str0001C = tmp_str0001C + Fa_s_03;
   Print(tmp_str0001C);
   FuncArg_Struct_00000000.m_84 = false;
   } 
   Lb_FFF6D = false;
   if (Li_FFFB8 == 2) { 
   Gb_00010 = Lb_FFF6F;
   if (Lb_FFF6F) { 
   tmp_str0001F = "LS";
   tmp_str0001E = Fa_s_03;
   tmp_str00020 = Fa_s_02;
   Gb_00010 = !func_1043(tmp_str00020, tmp_str0001E, Ii_1D234, tmp_str0001F);
   } 
   Lb_FFF6D = Gb_00010;
   } 
   else { 
   Lb_FFF6D = true;
   } 
   Lb_FFF6C = false;
   if (Li_FFFB0 == 2) { 
   Gb_00015 = Lb_FFF6F;
   if (Lb_FFF6F) { 
   tmp_str00024 = "LS";
   tmp_str00023 = Fa_s_03;
   tmp_str00025 = Fa_s_02;
   Gb_00015 = !func_1043(tmp_str00025, tmp_str00023, Ii_1D234, tmp_str00024);
   } 
   Lb_FFF6C = Gb_00015;
   } 
   else { 
   Lb_FFF6C = true;
   } 
   if (Il_15DFC[Fa_i_01] != iTime(Fa_s_02, 0, 0) && Il_0EFCC[Fa_i_01] != iTime(Fa_s_02, 0, 0) && Ii_19CE4[Fa_i_01] < 3) { 
   if ((Lb_FFFC3 && Lb_FFF6D && Lb_FFFA7)
   || (Lb_FFFC2 && Lb_FFF6C && Lb_FFFA6)) {
   
   Ii_09CAC = Ii_09CAC + 1;
   }
   if (numeroOperazioniDifferenzialePerDisattivarePirIndipendente != 0) { 
   Gi_00019 = Li_FFFC8 - Li_FFFC4;
   Gd_0001A = Gi_00019;
   Gb_0001A = (Gd_0001A >= numeroOperazioniDifferenzialePerDisattivarePirIndipendente);
   if (Gb_0001A) { 
   if ((Lb_FFFC3 && Lb_FFF6D && Lb_FFFA7)
   || (Lb_FFFC2 && Lb_FFF6C && Lb_FFFA6)) {
   
   Lb_FFFC3 = true;
   Lb_FFF6D = true;
   Lb_FFFA7 = true;
   Lb_FFFC2 = true;
   Lb_FFF6C = true;
   Lb_FFFA6 = true;
   }}} 
   if (disattivaPiramidazioneIndipendenteSeValuteUguali) { 
   Ls_FFF60 = Fa_s_02;
   Ls_FFF50 = "";
   Ls_FFF40 = Fa_s_03;
   tmp_str00034 = Is_1CC08;
   tmp_str00035 = Fa_s_03;
   Ls_FFF30 = "";
   if (Ls_FFF60 == Ls_FFF40 || Ls_FFF50 == "") {
   
   if ((Lb_FFFC3 && Lb_FFF6D && Lb_FFFA7)
   || (Lb_FFFC2 && Lb_FFF6C && Lb_FFFA6)) {
   
   Lb_FFFC3 = true;
   Lb_FFF6D = true;
   Lb_FFFA7 = true;
   Lb_FFFC2 = true;
   Lb_FFF6C = true;
   Lb_FFFA6 = true;
   }}} 
   if (utilizzaPiramidazioneIndipendente != true) { 
   if (Lb_FFFC3 == false || Lb_FFF6D == false || Lb_FFFA7 == false || Lb_FFFC2 == false || Lb_FFF6C == false || Lb_FFFA6 == false) { 
   
   Lb_FFFC3 = false;
   Lb_FFF6D = false;
   Lb_FFFA7 = false;
   Lb_FFFC2 = false;
   Lb_FFF6C = false;
   Lb_FFFA6 = false;
   }} 
   if (Lb_FFFC3 && Lb_FFF6D && Lb_FFFA7) { 
   tmp_str00041 = "LS_Pir";
   tmp_str00041 = tmp_str00041 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00040 = Fa_s_03;
   tmp_str00042 = Fa_s_02;
   tmp_str00043 = Fa_s_02;
   func_1046(tmp_str00043, tmp_str00042, tmp_str00040, Ii_1D234, 0, Ld_FFF98, SymbolInfoDouble(Fa_s_02, SYMBOL_ASK), tmp_str00041, 16711680, 0, 0);
   } 
   if (Lb_FFFC2 && Lb_FFF6C && Lb_FFFA6) { 
   tmp_str00046 = "LS_Pir";
   tmp_str00046 = tmp_str00046 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00045 = Fa_s_03;
   tmp_str00047 = Fa_s_02;
   tmp_str00048 = Fa_s_03;
   func_1046(tmp_str00048, tmp_str00047, tmp_str00045, Ii_1D234, 1, Ld_FFF90, SymbolInfoDouble(Fa_s_03, SYMBOL_BID), tmp_str00046, 255, 0, 0);
   } 
   Ii_19CE4[Fa_i_01] = Ii_19CE4[Fa_i_01] + 1;
   Gl_00020 = iTime(Fa_s_02, 0, 0);
   Il_15DFC[Fa_i_01] = Gl_00020;
   }}} 

   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Ls_FFFE0 = "";
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Li_FFFCC = 0;
   Li_FFFC8 = 0;
   Li_FFFC4 = 0;
   tmp_str00052 = "SS";
   tmp_str00051 = Fa_s_03;
   tmp_str00053 = Fa_s_02;
   if (func_1094(tmp_str00053, tmp_str00051, tmp_str00052, Li_FFFCC, Li_FFFC8, Li_FFFC4, Ld_FFFF8, Ld_FFFF0, Ld_FFFD8, Ld_FFFD0)) { 
   if (limitaIngressoGridOperazioniSeSuperatoDD != true) { 
   Gb_00020 = true;
   } 
   else { 
   if (tipoControlloFlottante == 0) { 
   Gd_00022 = valoreLimite;
   } 
   else { 
   Gd_00022 = ((AccountInfoDouble(ACCOUNT_BALANCE) * valoreLimite) / 100);
   } 
   Gd_00023 = 0;
   Gi_00024 = OrdersTotal() - 1;
   Gi_00025 = Gi_00024;
   if (Gi_00024 >= 0) { 
   do { 
   if (OrderSelect(Gi_00025, 0, 0) && OrderMagicNumber() >= MagicInp) { 
   Gi_00024 = OrderMagicNumber();
   Gi_00026 = MagicInp + 1000;
   if (Gi_00024 < Gi_00026) { 
   Gd_00026 = OrderProfit();
   Gd_00026 = (Gd_00026 + OrderCommission());
   Gd_00023 = ((Gd_00026 + OrderSwap()) + Gd_00023);
   }} 
   Gi_00025 = Gi_00025 - 1;
   } while (Gi_00025 >= 0); 
   } 
   Gd_00026 = -Gd_00022;
   if ((Gd_00023 < 0) && (Gd_00023 < Gd_00026)) {
   Gb_00020 = false;
   }
   else{
   Gb_00020 = true;
   }} 
   if (Gb_00020) { 
   Lb_FFF2F = false;
   Lb_FFF2E = false;
   if (utilizzaPiramidazioneIndipendente) { 
   Gb_00026 = (numeroMassimoPiramidazioni == 0);
   if (Gb_00026 != true) { 
   Gb_00026 = (Li_FFFC8 < numeroMassimoPiramidazioni);
   } 
   Lb_FFF2F = Gb_00026;
   Gb_00026 = (numeroMassimoPiramidazioni == 0);
   if (Gb_00026 != true) { 
   Gb_00026 = (Li_FFFC4 < numeroMassimoPiramidazioni);
   } 
   Lb_FFF2E = Gb_00026;
   } 
   else { 
   Gb_00026 = (numeroMassimoPiramidazioni == 0);
   if (Gb_00026 != true) { 
   Gb_00026 = (Li_FFFCC < numeroMassimoPiramidazioni);
   } 
   Lb_FFF2E = Gb_00026;
   Lb_FFF2F = Gb_00026;
   } 

   Li_FFF28 = pointsDistanzaPiramidazione;
   Li_FFF24 = tipoPiramidazione1;
   Li_FFF20 = pointsDistanzaPiramidazione;
   Li_FFF1C = tipoPiramidazione1;
   if (utilizzaPiramidazioneIndipendente) { 
   Gi_00026 = Li_FFFC8;
   } 
   else { 
   Gi_00026 = Li_FFFCC;
   } 
   Li_FFF18 = Gi_00026;
   if (utilizzaPiramidazioneIndipendente) { 
   Gi_00026 = Li_FFFC4;
   } 
   else { 
   Gi_00026 = Li_FFFCC;
   } 
   Li_FFF14 = Gi_00026;
   if (numeroPiramidazioneStep2 != 0 && Li_FFF18 - 1 >= numeroPiramidazioneStep2
   && (Li_FFF18 - 1 < numeroPiramidazioneStep3 || numeroPiramidazioneStep3 == 0)) {
   
   Li_FFF28 = pointsDistanzaPiramidazioneStep2;
   Li_FFF24 = tipoPiramidazione2;
   }
   else{
   if (numeroPiramidazioneStep3 != 0 && Li_FFFC8 - 1 >= numeroPiramidazioneStep3
   && (Li_FFFC8 - 1 < numeroPiramidazioneStep4 || numeroPiramidazioneStep4 == 0)) {
   
   Li_FFF28 = pointsDistanzaPiramidazioneStep3;
   Li_FFF24 = tipoPiramidazione3;
   }
   else{
   if (numeroPiramidazioneStep4 != 0) { 
   Gi_00026 = Li_FFFC8 - 1;
   if (Gi_00026 >= numeroPiramidazioneStep4) { 
   Li_FFF28 = pointsDistanzaPiramidazioneStep4;
   Li_FFF24 = tipoPiramidazione4;
   }}}} 
   if (numeroPiramidazioneStep2 != 0 && Li_FFF14 - 1 >= numeroPiramidazioneStep2
   && (Li_FFF14 - 1 < numeroPiramidazioneStep3 || numeroPiramidazioneStep3 == 0)) {
   
   Li_FFF20 = pointsDistanzaPiramidazioneStep2;
   Li_FFF1C = tipoPiramidazione2;
   }
   else{
   if (numeroPiramidazioneStep3 != 0 && Li_FFFC4 - 1 >= numeroPiramidazioneStep3
   && (Li_FFFC4 - 1 < numeroPiramidazioneStep4 || numeroPiramidazioneStep4 == 0)) {
   
   Li_FFF20 = pointsDistanzaPiramidazioneStep3;
   Li_FFF1C = tipoPiramidazione3;
   }
   else{
   if (numeroPiramidazioneStep4 != 0) { 
   Gi_00026 = Li_FFFC4 - 1;
   if (Gi_00026 >= numeroPiramidazioneStep4) { 
   Li_FFF20 = pointsDistanzaPiramidazioneStep4;
   Li_FFF1C = tipoPiramidazione4;
   }}}} 
   Lb_FFF13 = false;
   if (utilizzaPiramidazioneIndipendente != true) { 
   Gd_00026 = (SymbolInfoDouble(Fa_s_02, SYMBOL_BID) - Ld_FFFF8);
   if ((Gd_00026 >= (Li_FFF28 * SymbolInfoDouble(Fa_s_02, SYMBOL_POINT))) != true) { 
   Gb_00026 = (Li_FFF28 == 0);
   } 
   Lb_FFF13 = Gb_00026;
   } 
   else { 
   Gd_00026 = (SymbolInfoDouble(Fa_s_02, SYMBOL_BID) - Ld_FFFF8);
   if ((Gd_00026 >= (Li_FFF28 * SymbolInfoDouble(Fa_s_02, SYMBOL_POINT))) != true) { 
   Gb_00026 = (Li_FFF28 == 0);
   } 
   Lb_FFF13 = Gb_00026;
   } 
   Lb_FFF12 = false;
   if (utilizzaPiramidazioneIndipendente != true) { 
   if (misuraDistanzaAncheSuSecondoStrumento != true) { 
   Gb_00026 = Lb_FFF13;
   } 
   else { 
   Gd_00027 = (Ld_FFFF0 - SymbolInfoDouble(Fa_s_03, SYMBOL_ASK));
   if ((Gd_00027 >= (Li_FFF20 * SymbolInfoDouble(Fa_s_03, SYMBOL_POINT))) != true) { 
   Gb_00027 = (Li_FFF20 == 0);
   } 
   Gb_00026 = Gb_00027;
   } 
   Lb_FFF12 = Gb_00026;
   } 
   else { 
   Gd_00027 = (Ld_FFFF0 - SymbolInfoDouble(Fa_s_03, SYMBOL_ASK));
   if ((Gd_00027 >= (Li_FFF20 * SymbolInfoDouble(Fa_s_03, SYMBOL_POINT))) != true) { 
   Gb_00027 = (Li_FFF20 == 0);
   } 
   Lb_FFF12 = Gb_00027;
   } 
   Gd_00027 = Ld_FFFD8;
   Ld_FFF08 = Gd_00027;
   Gd_00028 = Ld_FFFD0;
   Ld_FFF00 = Gd_00028;
   if (tipoIncrementoSize != 0) { 
   if (tipoIncrementoSize == 1) { 
   Ld_FFF08 = (Gd_00027 * valoreIncremento);
   Gd_00029 = Ld_FFF08;
   Ld_FFF08 = Gd_00029;
   Gd_00029 = valoreIncremento;
   Ld_FFF00 = (Gd_00028 * Gd_00029);
   Gd_00029 = Ld_FFF00;
   Ld_FFF00 = Gd_00029;
   } 
   else { 
   if (tipoIncrementoSize == 2) { 
   Gd_00029 = valoreIncremento;
   Ld_FFF08 = (Ld_FFF08 + Gd_00029);
   Gd_00029 = Ld_FFF08;
   Ld_FFF08 = Gd_00029;
   tmp_str0005D = eaOper;
   Ld_FFF00 = (Ld_FFF00 + valoreIncremento);
   Ld_FFF00 = Ld_FFF00;
   }} 
   Ld_FFEF8 = SymbolInfoDouble(Fa_s_02, 34);
   if ((Ld_FFEF8 <= SymbolInfoDouble(Fa_s_02, 35))) { 
   do { 
   if ((Ld_FFEF8 >= Ld_FFF08)) { 
   Ld_FFF08 = Ld_FFEF8;
   break; 
   } 
   Ld_FFEF8 = (Ld_FFEF8 + SymbolInfoDouble(Fa_s_02, 36));
   } while (Ld_FFEF8 <= SymbolInfoDouble(Fa_s_02, 35)); 
   } 
   Ld_FFEF0 = SymbolInfoDouble(Fa_s_03, 34);
   if ((Ld_FFEF0 <= SymbolInfoDouble(Fa_s_03, 35))) { 
   do { 
   if ((Ld_FFEF0 >= Ld_FFF00)) { 
   Ld_FFF00 = Ld_FFEF0;
   break; 
   } 
   Ld_FFEF0 = (Ld_FFEF0 + SymbolInfoDouble(Fa_s_03, 36));
   } while (Ld_FFEF0 <= SymbolInfoDouble(Fa_s_03, 35)); 
   }} 
   Gb_0002B = (FuncArg_Struct_00000000.m_76 < FuncArg_Struct_00000000.m_68);
   if (Gb_0002B) { 
   tmp_str0005E = "SHORT";
   } 
   else { 
   tmp_str0005E = "LONG";
   } 
   Ls_FFEE0 = tmp_str0005E;
   tmp_str00061 = TerminalName();
   tmp_str00062 = eaPir;
   tmp_str00063 = listaSpreadDaNonTradare1;
   
   Gb_0002B = (tmp_str0005E == "LONG");
   if (Gb_0002B) { 
   Gb_0002B = (FuncArg_Struct_00000000.m_40 > valoreOverlayPerIngresso);
   } 
   if (Gb_0002B) { 
   Gb_0002B = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_0002B) { 
   Gb_0002B = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_0002B) { 
   Gb_0002B = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_0002B = FuncArg_Struct_00000000.m_85;
   }} 
   Lb_FFEDF = Gb_0002B;
   tmp_str00063 = orarioOperativita;
   tmp_str00064 = orarioOperativita2;
   tmp_str00065 = eaOper;
   
   Gb_0002C = (Ls_FFEE0 == "SHORT");
   if (Gb_0002C) { 
   Gb_0002C = (FuncArg_Struct_00000000.m_40 > valoreOverlayPerIngresso);
   } 
   if (Gb_0002C) { 
   Gb_0002C = (FuncArg_Struct_00000000.m_48 >= valorePuntiOverlayPerIngresso);
   } 
   if (Gb_0002C) { 
   Gb_0002C = FuncArg_Struct_00000000.m_84;
   } 
   if (Gb_0002C) { 
   Gb_0002C = !utilizzaSpreadRatio;
   if (utilizzaSpreadRatio) { 
   Gb_0002C = FuncArg_Struct_00000000.m_86;
   }} 
   Lb_FFEDE = Gb_0002C;
   if (Gb_0002C && FuncArg_Struct_00000000.m_84) { 
   tmp_str00067 = "Reset permesso trade SHORT PIRAMIDAZIONE per valore Overlay di " + Fa_s_02;
   tmp_str00067 = tmp_str00067 + " e ";
   tmp_str00067 = tmp_str00067 + Fa_s_03;
   Print(tmp_str00067);
   FuncArg_Struct_00000000.m_84 = false;
   } 
   Lb_FFEDD = false;
   if (Li_FFF24 == 2) { 
   Gb_0002D = Lb_FFEDE;
   if (Lb_FFEDE) { 
   tmp_str0006C = "SS";
   tmp_str0006B = Fa_s_03;
   tmp_str0006D = Fa_s_02;
   Gb_0002D = !func_1043(tmp_str0006D, tmp_str0006B, Ii_1D234, tmp_str0006C);
   } 
   Lb_FFEDD = Gb_0002D;
   } 
   else { 
   Lb_FFEDD = true;
   } 
   Lb_FFEDC = false;
   if (Li_FFF1C == 2) { 
   Gb_0002D = Lb_FFEDE;
   if (Lb_FFEDE) { 
   tmp_str00071 = "SS";
   tmp_str00070 = Fa_s_03;
   tmp_str00072 = Fa_s_02;
   Gb_0002D = !func_1043(tmp_str00072, tmp_str00070, Ii_1D234, tmp_str00071);
   } 
   Lb_FFEDC = Gb_0002D;
   } 
   else { 
   Lb_FFEDC = true;
   } 
   if (Il_17D70[Fa_i_01] != iTime(Fa_s_02, 0, 0) && Il_10F40[Fa_i_01] != iTime(Fa_s_02, 0, 0) && Ii_19CE4[Fa_i_01] < 3) { 
   if ((Lb_FFF2F && Lb_FFEDD && Lb_FFF13)
   || (Lb_FFF2E && Lb_FFEDC && Lb_FFF12)) {
   
   Ii_09CAC = Ii_09CAC + 1;
   }
   if (numeroOperazioniDifferenzialePerDisattivarePirIndipendente != 0) { 
   Gi_00031 = Li_FFFC8 - Li_FFFC4;
   Gd_00032 = Gi_00031;
   Gb_00032 = (Gd_00032 >= numeroOperazioniDifferenzialePerDisattivarePirIndipendente);
   if (Gb_00032) { 
   if ((Lb_FFF2F && Lb_FFEDD && Lb_FFF13)
   || (Lb_FFF2E && Lb_FFEDC && Lb_FFF12)) {
   
   Lb_FFF2F = true;
   Lb_FFEDD = true;
   Lb_FFF13 = true;
   Lb_FFF2E = true;
   Lb_FFEDC = true;
   Lb_FFF12 = true;
   }}} 
   if (disattivaPiramidazioneIndipendenteSeValuteUguali) { 
   Ls_FFED0 = Fa_s_02;
   Ls_FFEC0 = "";
   Ls_FFEB0 = Fa_s_03;
   Ls_FFEA0 = "";
   if (Ls_FFED0 == Ls_FFEB0 || Ls_FFEC0 == Ls_FFEA0) {
   
   if ((Lb_FFF2F && Lb_FFEDD && Lb_FFF13)
   || (Lb_FFF2E && Lb_FFEDC && Lb_FFF12)) {
   
   Lb_FFF2F = true;
   Lb_FFEDD = true;
   Lb_FFF13 = true;
   Lb_FFF2E = true;
   Lb_FFEDC = true;
   Lb_FFF12 = true;
   }}} 
   if (utilizzaPiramidazioneIndipendente != true) { 
   if (Lb_FFF2F == false || Lb_FFEDD == false || Lb_FFF13 == false || Lb_FFF2E == false || Lb_FFEDC == false || Lb_FFF12 == false) { 
   
   Lb_FFF2F = false;
   Lb_FFEDD = false;
   Lb_FFF13 = false;
   Lb_FFF2E = false;
   Lb_FFEDC = false;
   Lb_FFF12 = false;
   }} 
   if (Lb_FFF2F && Lb_FFEDD && Lb_FFF13) { 
   tmp_str0008F = "SS_Pir";
   tmp_str0008F = tmp_str0008F + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str0008E = Fa_s_03;
   tmp_str00090 = Fa_s_02;
   tmp_str00091 = Fa_s_02;
   func_1046(tmp_str00091, tmp_str00090, tmp_str0008E, Ii_1D234, 1, Ld_FFF08, SymbolInfoDouble(Fa_s_02, SYMBOL_BID), tmp_str0008F, 255, 0, 0);
   } 
   if (Lb_FFF2E && Lb_FFEDC && Lb_FFF12) { 
   tmp_str00094 = "SS_Pir";
   tmp_str00094 = tmp_str00094 + IntegerToString(Ii_09CAC, 0, 32);
   tmp_str00093 = Fa_s_03;
   tmp_str00095 = Fa_s_02;
   tmp_str00096 = Fa_s_03;
   func_1046(tmp_str00096, tmp_str00095, tmp_str00093, Ii_1D234, 0, Ld_FFF00, SymbolInfoDouble(Fa_s_03, SYMBOL_ASK), tmp_str00094, 16711680, 0, 0);
   } 
   Gl_00037 = iTime(Fa_s_02, 0, 0);
   Il_17D70[Fa_i_01] = Gl_00037;
   Ii_19CE4[Fa_i_01] = Ii_19CE4[Fa_i_01] + 1;
   }}} 
   Gl_00039 = iTime(Fa_s_02, 0, 0);
   Il_1ACB8[Fa_i_01] = Gl_00039;
   
}

void func_1096(int Fa_i_00, string Fa_s_01, string Fa_s_02, double Fa_d_03)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   double Ld_FFFF8;
   double Ld_FFFF0;
   int Li_FFFEC;
   int Li_FFFE8;
   int Li_FFFE4;
   int Li_FFFE0;
   double Ld_FFFD8;
   double Ld_FFFD0;
   double Ld_FFFC8;
   double Ld_FFFC0;
   int Li_FFFBC;
   string Ls_FFFB0;
   double Ld_FFFA8;
   double Ld_FFFA0;
   double Ld_FFF98;
   double Ld_FFF90;

   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Li_FFFEC = 0;
   Li_FFFE8 = 0;
   Li_FFFE4 = 0;
   Li_FFFE0 = 0;
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Li_FFFBC = OrdersTotal() - 1;
   if (Li_FFFBC >= 0) { 
   do { 
   if (OrderSelect(Li_FFFBC, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_01 || OrderSymbol() == Fa_s_02) { 
   
   Ls_FFFB0 = OrderComment();
   if (Ib_09C81) { 
   Gi_00002 = StringFind(OrderComment(), "from");
   if (Gi_00002 >= 0) { 
   Gi_00003 = (int)StringToInteger("");
   Gi_00004 = 0;
   Gi_00003 = 0;
   Gi_00005 = HistoryTotal() - 1;
   Gi_00006 = Gi_00005;
   if (Gi_00005 >= 0) { 
   do { 
   if (OrderSelect(Gi_00006, 0, 1)) { 
   Gl_00005 = OrderOpenTime();
   tmp_str00013 = IntegerToString(MagicInp, 0, 32);
   tmp_str00013 = tmp_str00013 + "_PMPtimeFlat";
   Gl_00007 = (datetime)(GlobalVariableGet(tmp_str00013) * 1000);
   if (Gl_00005 >= Gl_00007) { 
   Gi_00007 = StringFind(OrderComment(), "to #");
   if (Gi_00007 >= 0) { 
   Gi_00007 = (int)StringToInteger("");
   if (Gi_00007 == Gi_00003) { 
   Gi_00003 = OrderTicket();
   Gi_00004 = Gi_00003;
   }}}} 
   Gi_00006 = Gi_00006 - 1;
   } while (Gi_00006 >= 0); 
   } 
   Gi_00007 = Gi_00004;
   Gi_00008 = ArraySize(Is_0B074) - 1;
   Gi_00009 = Gi_00008;
   tmp_str0001F = "";
   if (Gi_00008 >= 0) {
   do { 
   string Ls_FFF5C[];
   tmp_str0001B = Is_0B074[Gi_00009];
   Gst_0000B = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0001B, Gst_0000B, Ls_FFF5C);
   if (ArraySize(Ls_FFF5C) >= 2) {
   tmp_str0001F = (string)Gi_00007;
   if (Ls_FFF5C[0] == tmp_str0001F) {
   tmp_str0001F = Ls_FFF5C[1];
   ArrayFree(Ls_FFF5C);
   break;
   }}
   ArrayFree(Ls_FFF5C);
   Gi_00009 = Gi_00009 - 1;
   } while (Gi_00009 >= 0); 
   }
   
   Ls_FFFB0 = tmp_str0001F;
   if (tmp_str0001F == "") { 
   tmp_str00020 = "";
   tmp_str00023 = "ERRORE determinazione ordine, sistema sospeso GO " + tmp_str0001F;
   tmp_str00022 = Fa_s_02;
   tmp_str00024 = Fa_s_01;
   func_1050(Fa_i_00, tmp_str00024, tmp_str00022, tmp_str00023, tmp_str00020, 0);
   Ib_1CED0 = true;
   return ;
   }}} 
   if (OrderSelect(Li_FFFBC, 0, 0) && OrderMagicNumber() == Ii_1D234) { 
   if (OrderSymbol() == Fa_s_01 || OrderSymbol() == Fa_s_02) {
   
   if ((OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_02 && OrderType() == OP_SELL)) {
   
   Gd_0000D = OrderProfit();
   Gd_0000D = (Gd_0000D + OrderSwap());
   Ld_FFFF8 = ((Gd_0000D + OrderCommission()) + Ld_FFFF8);
   if (OrderSymbol() == Fa_s_01) { 
   Li_FFFEC = Li_FFFEC + 1;
   Ld_FFFD8 = (Ld_FFFD8 + OrderLots());
   } 
   if (OrderSymbol() == Fa_s_02) { 
   Li_FFFE8 = Li_FFFE8 + 1;
   Ld_FFFD0 = (Ld_FFFD0 + OrderLots());
   }} 
   if ((OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_02 && OrderType() == OP_BUY)) {
   
   Gd_0000D = OrderProfit();
   Gd_0000D = (Gd_0000D + OrderSwap());
   Ld_FFFF0 = ((Gd_0000D + OrderCommission()) + Ld_FFFF0);
   if (OrderSymbol() == Fa_s_01) { 
   Li_FFFE4 = Li_FFFE4 + 1;
   Ld_FFFC8 = (Ld_FFFC8 + OrderLots());
   } 
   if (OrderSymbol() == Fa_s_02) { 
   Li_FFFE0 = Li_FFFE0 + 1;
   Ld_FFFC0 = (Ld_FFFC0 + OrderLots());
   }}}}}} 
   Li_FFFBC = Li_FFFBC - 1;
   } while (Li_FFFBC >= 0); 
   } 
   Ld_FFFA8 = targetValuta;
   Ld_FFFA0 = targetValuta;
   Ld_FFF98 = percentualeSizePerAdattamento1;
   Ld_FFF90 = percentualeSizePerAdattamento1;
   if (numeroMediazioniAttivazioneSecondoTarget != 0) { 
   Gi_00010 = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_00011 = Li_FFFE8;
   } 
   else { 
   Gi_00011 = Gi_00010;
   } 
   if (Gi_00011 > numeroMediazioniAttivazioneSecondoTarget) { 
   Ld_FFFA8 = targetValuta2;
   Ld_FFF98 = percentualeSizePerAdattamento2;
   } 
   Gi_00013 = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_00014 = Li_FFFE0;
   } 
   else { 
   Gi_00014 = Gi_00013;
   } 
   if (Gi_00014 > numeroMediazioniAttivazioneSecondoTarget) { 
   Ld_FFFA0 = targetValuta2;
   Ld_FFF90 = percentualeSizePerAdattamento2;
   }} 
   if (numeroMediazioniAttivazioneTerzoTarget != 0) { 
   Gi_00014 = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_00015 = Li_FFFE8;
   } 
   else { 
   Gi_00015 = Gi_00014;
   } 
   if (Gi_00015 > numeroMediazioniAttivazioneTerzoTarget) { 
   Ld_FFFA8 = targetValuta3;
   Ld_FFF98 = percentualeSizePerAdattamento3;
   } 
   Gi_00015 = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_00016 = Li_FFFE0;
   } 
   else { 
   Gi_00016 = Gi_00015;
   } 
   if (Gi_00016 > numeroMediazioniAttivazioneTerzoTarget) { 
   Ld_FFFA0 = targetValuta3;
   Ld_FFF90 = percentualeSizePerAdattamento3;
   }} 
   if ((targetValuta != 0)) { 
   if (tipoAdattamentoSize == 0) { 
   Gd_00018 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00019 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_0001A = (tipoAdattamentoSize == 2);
   if (Gb_0001A) { 
   Gi_0001B = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_0001C = Li_FFFE8;
   } 
   else { 
   Gi_0001C = Gi_0001B;
   } 
   Gb_0001A = (Gi_0001C >= 1);
   } 
   if (Gb_0001A) { 
   Gd_0001C = Ld_FFFD8;
   if (Ld_FFFD8 <= Ld_FFFD0) { 
   Gd_0001D = Ld_FFFD0;
   } 
   else { 
   Gd_0001D = Gd_0001C;
   } 
   Gd_0001D = (((Gd_0001D * Ld_FFF98) / 100) / 0.01);
   } 
   else { 
   Gd_0001D = 1;
   } 
   Gd_00019 = Gd_0001D;
   } 
   Gd_00018 = Gd_00019;
   } 
   if ((Ld_FFFF8 >= (Ld_FFFA8 * Gd_00018))) { 
   tmp_str0002E = "Chiusura target valuta : " + DoubleToString(Ld_FFFF8, 2);
   tmp_str0002F = "LS";
   tmp_str0002D = Fa_s_02;
   tmp_str00030 = Fa_s_01;
   func_1098(tmp_str00030, tmp_str0002D, Ii_1D234, tmp_str0002F, tmp_str0002E);
   } 
   if (tipoAdattamentoSize == 0) { 
   Gd_0001E = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_0001F = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_00020 = (tipoAdattamentoSize == 2);
   if (Gb_00020) { 
   Gi_00021 = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_00022 = Li_FFFE0;
   } 
   else { 
   Gi_00022 = Gi_00021;
   } 
   Gb_00020 = (Gi_00022 >= 1);
   } 
   if (Gb_00020) { 
   Gd_00022 = Ld_FFFC8;
   if (Ld_FFFC8 <= Ld_FFFC0) { 
   Gd_00023 = Ld_FFFC0;
   } 
   else { 
   Gd_00023 = Gd_00022;
   } 
   Gd_00023 = (((Gd_00023 * Ld_FFF90) / 100) / 0.01);
   } 
   else { 
   Gd_00023 = 1;
   } 
   Gd_0001F = Gd_00023;
   } 
   Gd_0001E = Gd_0001F;
   } 
   if ((Ld_FFFF0 >= (Ld_FFFA0 * Gd_0001E))) { 
   tmp_str00033 = "Chiusura target valuta : " + DoubleToString(Ld_FFFF0, 2);
   tmp_str00035 = "SS";
   tmp_str00034 = Fa_s_02;
   tmp_str00036 = Fa_s_01;
   func_1098(tmp_str00036, tmp_str00034, Ii_1D234, tmp_str00035, tmp_str00033);
   }} 
   if ((stopValuta != 0)) { 
   Gd_00024 = -stopValuta;
   if (tipoAdattamentoSize == 0) { 
   Gd_00025 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00026 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_00027 = (tipoAdattamentoSize == 2);
   if (Gb_00027) { 
   Gi_00028 = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_00029 = Li_FFFE8;
   } 
   else { 
   Gi_00029 = Gi_00028;
   } 
   Gb_00027 = (Gi_00029 >= 1);
   } 
   if (Gb_00027) { 
   Gd_00029 = Ld_FFFD8;
   if (Ld_FFFD8 <= Ld_FFFD0) { 
   Gd_0002A = Ld_FFFD0;
   } 
   else { 
   Gd_0002A = Gd_00029;
   } 
   Gd_0002A = (((Gd_0002A * Ld_FFF98) / 100) / 0.01);
   } 
   else { 
   Gd_0002A = 1;
   } 
   Gd_00026 = Gd_0002A;
   } 
   Gd_00025 = Gd_00026;
   } 
   if ((Ld_FFFF8 <= (Gd_00024 * Gd_00025))) { 
   tmp_str00039 = "Chiusura stoploss valuta : " + DoubleToString(Ld_FFFF8, 2);
   tmp_str0003A = "LS";
   tmp_str00038 = Fa_s_02;
   tmp_str0003B = Fa_s_01;
   func_1098(tmp_str0003B, tmp_str00038, Ii_1D234, tmp_str0003A, tmp_str00039);
   } 
   Gd_0002A = -stopValuta;
   if (tipoAdattamentoSize == 0) { 
   Gd_0002B = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_0002C = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_0002D = (tipoAdattamentoSize == 2);
   if (Gb_0002D) { 
   Gi_0002E = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_0002F = Li_FFFE0;
   } 
   else { 
   Gi_0002F = Gi_0002E;
   } 
   Gb_0002D = (Gi_0002F >= 1);
   } 
   if (Gb_0002D) { 
   Gd_0002F = Ld_FFFC8;
   if (Ld_FFFC8 <= Ld_FFFC0) { 
   Gd_00030 = Ld_FFFC0;
   } 
   else { 
   Gd_00030 = Gd_0002F;
   } 
   Gd_00030 = (((Gd_00030 * Ld_FFF90) / 100) / 0.01);
   } 
   else { 
   Gd_00030 = 1;
   } 
   Gd_0002C = Gd_00030;
   } 
   Gd_0002B = Gd_0002C;
   } 
   if ((Ld_FFFF0 <= (Gd_0002A * Gd_0002B))) { 
   tmp_str0003E = "Chiusura stoploss valuta : " + DoubleToString(Ld_FFFF0, 2);
   tmp_str00041 = "SS";
   tmp_str00040 = Fa_s_02;
   tmp_str00042 = Fa_s_01;
   func_1098(tmp_str00042, tmp_str00040, Ii_1D234, tmp_str00041, tmp_str0003E);
   }} 
   if ((trailingStopStart == 0)) return; 
   if (tipoAdattamentoSize == 0) { 
   Gd_00030 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00031 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_00032 = (tipoAdattamentoSize == 2);
   if (Gb_00032) { 
   Gi_00033 = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_00034 = Li_FFFE8;
   } 
   else { 
   Gi_00034 = Gi_00033;
   } 
   Gb_00032 = (Gi_00034 >= 1);
   } 
   if (Gb_00032) { 
   Gd_00034 = Ld_FFFD8;
   if (Ld_FFFD8 <= Ld_FFFD0) { 
   Gd_00035 = Ld_FFFD0;
   } 
   else { 
   Gd_00035 = Gd_00034;
   } 
   Gd_00035 = (((Gd_00035 * Ld_FFF98) / 100) / 0.01);
   } 
   else { 
   Gd_00035 = 1;
   } 
   Gd_00031 = Gd_00035;
   } 
   Gd_00030 = Gd_00031;
   } 
   if ((Ld_FFFF8 >= (trailingStopStart * Gd_00030))) { 
   Gd_00036 = (Ld_FFFF8 - Id_09D80[Fa_i_00]);
   Gd_00037 = (trailingStop + trailingStep);
   if (tipoAdattamentoSize == 0) { 
   Gd_00038 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00039 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_0003A = (tipoAdattamentoSize == 2);
   if (Gb_0003A) { 
   Gi_0003B = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_0003C = Li_FFFE8;
   } 
   else { 
   Gi_0003C = Gi_0003B;
   } 
   Gb_0003A = (Gi_0003C >= 1);
   } 
   if (Gb_0003A) { 
   Gd_0003C = Ld_FFFD8;
   if (Ld_FFFD8 <= Ld_FFFD0) { 
   Gd_0003D = Ld_FFFD0;
   } 
   else { 
   Gd_0003D = Gd_0003C;
   } 
   Gd_0003D = (((Gd_0003D * Ld_FFF98) / 100) / 0.01);
   } 
   else { 
   Gd_0003D = 1;
   } 
   Gd_00039 = Gd_0003D;
   } 
   Gd_00038 = Gd_00039;
   } 
   if ((Gd_00036 > (Gd_00037 * Gd_00038))) { 
   if (tipoAdattamentoSize == 0) { 
   Gd_0003D = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_0003E = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_0003F = (tipoAdattamentoSize == 2);
   if (Gb_0003F) { 
   Gi_00040 = Li_FFFEC;
   if (Li_FFFEC <= Li_FFFE8) { 
   Gi_00041 = Li_FFFE8;
   } 
   else { 
   Gi_00041 = Gi_00040;
   } 
   Gb_0003F = (Gi_00041 >= 1);
   } 
   if (Gb_0003F) { 
   Gd_00041 = Ld_FFFD8;
   if (Ld_FFFD8 <= Ld_FFFD0) { 
   Gd_00042 = Ld_FFFD0;
   } 
   else { 
   Gd_00042 = Gd_00041;
   } 
   Gd_00042 = (((Gd_00042 * Ld_FFF98) / 100) / 0.01);
   } 
   else { 
   Gd_00042 = 1;
   } 
   Gd_0003E = Gd_00042;
   } 
   Gd_0003D = Gd_0003E;
   } 
   Gd_00042 = (trailingStop * Gd_0003D);
   Gd_00042 = (Ld_FFFF8 - Gd_00042);
   Id_09D80[Fa_i_00] = Gd_00042;
   tmp_str00043 = IntegerToString(Ii_1D234, 0, 32);
   tmp_str00043 = tmp_str00043 + " aggiornato trailing LS : ";
   tmp_str00043 = tmp_str00043 + DoubleToString(Id_09D80[Fa_i_00], 2);
   Print(tmp_str00043);
   }} 
   if ((Id_09D80[Fa_i_00] != 0) && (Ld_FFFF8 <= Id_09D80[Fa_i_00])) { 
   tmp_str00048 = "Trailing Stop LS";
   tmp_str0004B = "LS";
   tmp_str0004A = Fa_s_02;
   tmp_str0004C = Fa_s_01;
   func_1098(tmp_str0004C, tmp_str0004A, Ii_1D234, tmp_str0004B, tmp_str00048);
   Id_09D80[Fa_i_00] = 0;
   } 
   if (tipoAdattamentoSize == 0) { 
   Gd_00048 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00049 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_0004A = (tipoAdattamentoSize == 2);
   if (Gb_0004A) { 
   Gi_0004B = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_0004C = Li_FFFE0;
   } 
   else { 
   Gi_0004C = Gi_0004B;
   } 
   Gb_0004A = (Gi_0004C >= 1);
   } 
   if (Gb_0004A) { 
   Gd_0004C = Ld_FFFC8;
   if (Ld_FFFC8 <= Ld_FFFC0) { 
   Gd_0004D = Ld_FFFC0;
   } 
   else { 
   Gd_0004D = Gd_0004C;
   } 
   Gd_0004D = (((Gd_0004D * Ld_FFF90) / 100) / 0.01);
   } 
   else { 
   Gd_0004D = 1;
   } 
   Gd_00049 = Gd_0004D;
   } 
   Gd_00048 = Gd_00049;
   } 
   if ((Ld_FFFF0 >= (trailingStopStart * Gd_00048))) { 
   Gd_0004E = (Ld_FFFF0 - Id_0A714[Fa_i_00]);
   Gd_0004F = (trailingStop + trailingStep);
   if (tipoAdattamentoSize == 0) { 
   Gd_00050 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00051 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_00052 = (tipoAdattamentoSize == 2);
   if (Gb_00052) { 
   Gi_00053 = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_00054 = Li_FFFE0;
   } 
   else { 
   Gi_00054 = Gi_00053;
   } 
   Gb_00052 = (Gi_00054 >= 1);
   } 
   if (Gb_00052) { 
   Gd_00054 = Ld_FFFC8;
   if (Ld_FFFC8 <= Ld_FFFC0) { 
   Gd_00055 = Ld_FFFC0;
   } 
   else { 
   Gd_00055 = Gd_00054;
   } 
   Gd_00055 = (((Gd_00055 * Ld_FFF90) / 100) / 0.01);
   } 
   else { 
   Gd_00055 = 1;
   } 
   Gd_00051 = Gd_00055;
   } 
   Gd_00050 = Gd_00051;
   } 
   if ((Gd_0004E > (Gd_0004F * Gd_00050))) { 
   if (tipoAdattamentoSize == 0) { 
   Gd_00055 = 1;
   } 
   else { 
   if (tipoAdattamentoSize == 1) { 
   Gd_00056 = (Fa_d_03 / 0.01);
   } 
   else { 
   Gb_00057 = (tipoAdattamentoSize == 2);
   if (Gb_00057) { 
   Gi_00058 = Li_FFFE4;
   if (Li_FFFE4 <= Li_FFFE0) { 
   Gi_00059 = Li_FFFE0;
   } 
   else { 
   Gi_00059 = Gi_00058;
   } 
   Gb_00057 = (Gi_00059 >= 1);
   } 
   if (Gb_00057) { 
   Gd_00059 = Ld_FFFC8;
   if (Ld_FFFC8 <= Ld_FFFC0) { 
   Gd_0005A = Ld_FFFC0;
   } 
   else { 
   Gd_0005A = Gd_00059;
   } 
   Gd_0005A = (((Gd_0005A * Ld_FFF90) / 100) / 0.01);
   } 
   else { 
   Gd_0005A = 1;
   } 
   Gd_00056 = Gd_0005A;
   } 
   Gd_00055 = Gd_00056;
   } 
   Gd_0005A = (trailingStop * Gd_00055);
   Gd_0005A = (Ld_FFFF0 - Gd_0005A);
   Id_0A714[Fa_i_00] = Gd_0005A;
   tmp_str0004D = IntegerToString(Ii_1D234, 0, 32);
   tmp_str0004D = tmp_str0004D + " aggiornato trailing SS : ";
   tmp_str0004D = tmp_str0004D + DoubleToString(Id_0A714[Fa_i_00], 2);
   Print(tmp_str0004D);
   }} 
   if ((Id_0A714[Fa_i_00] == 0)) return; 
   if ((Ld_FFFF0 > Id_0A714[Fa_i_00])) return; 
   tmp_str00051 = "Trailing Stop SS";
   tmp_str00054 = "SS";
   tmp_str00053 = Fa_s_02;
   tmp_str00055 = Fa_s_01;
   func_1098(tmp_str00055, tmp_str00053, Ii_1D234, tmp_str00054, tmp_str00051);
   Id_0A714[Fa_i_00] = 0;
   
}

void func_1097(Coppia &FuncArg_Struct_00000000, string Fa_s_01, string Fa_s_02)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   double Ld_FFFF8;
   double Ld_FFFF0;

   if (utilizzaChiusuraSuValoreOverlay == false) return; 
   tmp_str00001 = "LS";
   tmp_str00000 = Fa_s_02;
   tmp_str00002 = Fa_s_01;
   if (func_1041(tmp_str00002, tmp_str00000, Ii_1D234, tmp_str00001)) { 
   tmp_str00005 = "LS";
   tmp_str00004 = Fa_s_02;
   tmp_str00006 = Fa_s_01;
   Gb_00000 = (func_1042(tmp_str00006, tmp_str00004, Ii_1D234, tmp_str00005) > 0);
   Ld_FFFF8 = Gb_00000;
   if (tipoChiusuraOverlay == 2
   || (tipoChiusuraOverlay == 0 && Ld_FFFF8 > 0)
   || (tipoChiusuraOverlay == 1 && Ld_FFFF8 < 0)) {
   
   if ((FuncArg_Struct_00000000.m_40 != 0) && (FuncArg_Struct_00000000.m_40 <= valoreOverlayPerChiusura)) { 
   tmp_str00009 = "Chiusura su valore Overlay " + DoubleToString(FuncArg_Struct_00000000.m_40, 2);
   tmp_str0000B = "LS";
   tmp_str0000A = Fa_s_02;
   tmp_str0000C = Fa_s_01;
   func_1098(tmp_str0000C, tmp_str0000A, Ii_1D234, tmp_str0000B, tmp_str00009);
   }}} 
   tmp_str0000F = "SS";
   tmp_str0000E = Fa_s_02;
   tmp_str00010 = Fa_s_01;
   if (!func_1041(tmp_str00010, tmp_str0000E, Ii_1D234, tmp_str0000F)) return; 
   tmp_str00013 = "SS";
   tmp_str00012 = Fa_s_02;
   tmp_str00014 = Fa_s_01;
   Gb_00000 = (func_1042(tmp_str00014, tmp_str00012, Ii_1D234, tmp_str00013) > 0);
   Ld_FFFF0 = Gb_00000;
   if (tipoChiusuraOverlay == 2
   || (tipoChiusuraOverlay == 0 && Ld_FFFF0 > 0)
   || (tipoChiusuraOverlay == 1 && Ld_FFFF0 < 0)) {
   
   if ((FuncArg_Struct_00000000.m_40 == 0)) return; 
   if ((FuncArg_Struct_00000000.m_40 > valoreOverlayPerChiusura)) return; 
   tmp_str00017 = "Chiusura su valore Overlay ";
   tmp_str00017 = tmp_str00017 + DoubleToString(FuncArg_Struct_00000000.m_40, 2);
   tmp_str00018 = "SS";
   tmp_str00016 = Fa_s_02;
   tmp_str00019 = Fa_s_01;
   func_1098(tmp_str00019, tmp_str00016, Ii_1D234, tmp_str00018, tmp_str00017);
   }
}

void func_1098(string Fa_s_00, string Fa_s_01, int Fa_i_02, string Fa_s_03, string Fa_s_04)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   int Li_FFFFC;
   string Ls_FFFF0;
   bool Lb_FFFEF;
   int Li_FFFE8;
   int Li_FFFE4;

   Li_FFFFC = OrdersTotal();
   if (Li_FFFFC < 0) return; 
   do { 
   if (OrderSelect(Li_FFFFC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Ls_FFFF0 = OrderComment();
   if (Ib_09C81) { 
   Gi_00002 = StringFind(OrderComment(), "from");
   if (Gi_00002 >= 0) { 
   Gi_00002 = (int)StringToInteger("");
   Gi_00003 = 0;
   Gi_00002 = 0;
   Gi_00004 = HistoryTotal() - 1;
   Gi_00005 = Gi_00004;
   if (Gi_00004 >= 0) { 
   do { 
   if (OrderSelect(Gi_00005, 0, 1)) { 
   Gl_00004 = OrderOpenTime();
   tmp_str00007 = IntegerToString(MagicInp, 0, 32);
   tmp_str00007 = tmp_str00007 + "_PMPtimeFlat";
   Gl_00006 = (datetime)(GlobalVariableGet(tmp_str00007) * 1000);
   if (Gl_00004 >= Gl_00006) { 
   Gi_00006 = StringFind(OrderComment(), "to #");
   if (Gi_00006 >= 0) { 
   Gi_00006 = (int)StringToInteger("");
   if (Gi_00006 == Gi_00002) { 
   Gi_00002 = OrderTicket();
   Gi_00003 = Gi_00002;
   }}}} 
   Gi_00005 = Gi_00005 - 1;
   } while (Gi_00005 >= 0); 
   } 
   Gi_00006 = Gi_00003;
   Gi_00007 = ArraySize(Is_0B074) - 1;
   Gi_00008 = Gi_00007;
   tmp_str00013 = "";
   if (Gi_00007 >= 0) {
   do { 
   string Ls_FFFB0[];
   tmp_str0000F = Is_0B074[Gi_00008];
   Gst_0000A = (short)StringGetCharacter(":", 0);
   StringSplit(tmp_str0000F, Gst_0000A, Ls_FFFB0);
   if (ArraySize(Ls_FFFB0) >= 2) {
   tmp_str00013 = (string)Gi_00006;
   if (Ls_FFFB0[0] == tmp_str00013) {
   tmp_str00013 = Ls_FFFB0[1];
   ArrayFree(Ls_FFFB0);
   break;
   }}
   ArrayFree(Ls_FFFB0);
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   }
   
   Ls_FFFF0 = tmp_str00013;
   if (tmp_str00013 == "") { 
   tmp_str00014 = "";
   tmp_str00017 = "ERRORE determinazione ordine, sistema sospeso CM " + tmp_str00013;
   tmp_str00016 = Fa_s_01;
   tmp_str00018 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00018, tmp_str00016, tmp_str00017, tmp_str00014, 0);
   Ib_1CED0 = true;
   return ;
   }}} 
   Lb_FFFEF = false;
   if (Ib_09C81) { 
   Lb_FFFEF = (Ls_FFFF0 == Fa_s_03);
   } 
   else { 
   tmp_str0001C = listaSpreadDaTradare1;
   
   if (Fa_s_03 == "LS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_BUY)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_SELL)) {
   
   Lb_FFFEF = true;
   }} 
   if (Fa_s_03 == "SS") { 
   if ((OrderSymbol() == Fa_s_00 && OrderType() == OP_SELL)
   || (OrderSymbol() == Fa_s_01 && OrderType() == OP_BUY)) {
   
   Lb_FFFEF = true;
   }}} 
   if (Lb_FFFEF && OrderSelect(Li_FFFFC, 0, 0) && OrderMagicNumber() == Fa_i_02) { 
   if (OrderSymbol() == Fa_s_00 || OrderSymbol() == Fa_s_01) { 
   
   Li_FFFE8 = 0;
   if (Li_FFFE8 < 10) { 
   do { 
   RefreshRates();
   if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20, 255)) {
   Gi_00010 = GetLastError();
   Li_FFFE4 = Gi_00010;
   tmp_str00021 = "";
   tmp_str00022 = Fa_s_04;
   tmp_str00023 = Fa_s_01;
   tmp_str00024 = Fa_s_00;
   func_1050(Fa_i_02, tmp_str00024, tmp_str00023, tmp_str00022, tmp_str00021, Gi_00010);
   }
   else{
   tmp_str00025 = "";
   tmp_str00026 = Fa_s_04;
   tmp_str00027 = Fa_s_01;
   tmp_str00028 = Fa_s_00;
   func_1052(Fa_i_02, tmp_str00028, tmp_str00027, tmp_str00026, tmp_str00025);
   continue;
   }
   Li_FFFE8 = Li_FFFE8 + 1;
   } while (Li_FFFE8 < 10); 
   }}}}} 
   Li_FFFFC = Li_FFFFC - 1;
   } while (Li_FFFFC >= 0); 
   
}

void func_1100(string Fa_s_00)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFDC;
   string Ls_FFFD0;
   int Li_FFFCC;
   string Ls_FFFC0;
   int Li_FFFBC;
   int Li_FFFB8;
   string Ls_FFFA8;
   string Ls_FFF98;
   int Li_FFF94;
   int Li_FFF90;
   string Ls_FFF80;
   int Li_FFF7C;
   int Li_FFF78;
   int Li_FFF74;
   int Li_FFF70;
   int Li_FFF6C;
   int Li_FFF68;
   string Ls_FFF58;
   string Ls_FFF48;
   int Li_FFF44;
   int Li_FFF40;
   int Li_FFF3C;
   int Li_FFF38;
   int Li_FFF34;
   int Li_FFF30;
   int Li_FFF2C;
   string Ls_FFF20;
   string Ls_FFF10;
   int Li_FFF0C;
   int Li_FFF08;
   int Li_FFF04;
   int Li_FFF00;
   int Li_FFEFC;
   int Li_FFEF8;

   Ls_FFFF0 = TerminalInfoString(3);
   Print(Ls_FFFF0);
   Ls_FFFE0 = nomeTemplate;
   Print(Ls_FFFE0);
   Li_FFFDC = FileOpen(Ls_FFFE0, 17);
   Ls_FFFD0 = "";
   if (Li_FFFDC < 0) { 
   Print("Error code ", GetLastError());
   } 
   else { 
   Li_FFFCC = 0;
   if (FileIsEnding(Li_FFFDC) != true) { 
   do { 
   Li_FFFCC = FileReadInteger(Li_FFFDC, 4);
   tmp_str00003 = FileReadString(Li_FFFDC, Li_FFFCC);
   tmp_str00003 = tmp_str00003 + "";
   Ls_FFFC0 = Ls_FFFC0 + tmp_str00003;
   } while (!FileIsEnding(Li_FFFDC)); 
   } 
   tmp_str00008 = "SubSymbol=";
   tmp_str00007 = Ls_FFFC0;
   Gi_00003 = StringFind(tmp_str00007, tmp_str00008);
   Li_FFFBC = Gi_00003;
   tmp_str00009 = Ls_FFFC0;
   tmp_str0000C = "numeroBarre=";
   Gi_00004 = StringFind(Ls_FFFC0, tmp_str0000C);
   Li_FFFB8 = Gi_00004;
   Ls_FFFA8 = "";
   Ls_FFF98 = Fa_s_00;
   Li_FFF94 = Gi_00006;
   if (Li_FFF94 < Li_FFFB8) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF94 = Li_FFF94 + 1;
   } while (Li_FFF94 < Li_FFFB8); 
   } 
   tmp_str00012 = "SubSymbol=" + Ls_FFF98;
   tmp_str00012 = tmp_str00012 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00012);
   tmp_str00015 = "calcolaDistanzaDaUltimoIncrocio=";
   tmp_str00014 = Ls_FFFC0;
   Li_FFF90 = StringFind(tmp_str00014, tmp_str00015);
   Ls_FFFA8 = "";
   Ls_FFF80 = IntegerToString(numeroBarreOverlay, 0, 32);

   Li_FFF7C = Li_FFFB8;
   if (Li_FFF7C < Li_FFF90) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF7C = Li_FFF7C + 1;
   } while (Li_FFF7C < Li_FFF90); 
   } 

   tmp_str00019 = "numeroBarre=" + Ls_FFF80;
   tmp_str00019 = tmp_str00019 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00019);
   tmp_str0001B = "calcolaDistanzaDaUltimoIncrocio=";
   tmp_str0001A = Ls_FFFC0;
   Gi_00008 = StringFind(tmp_str0001A, tmp_str0001B);
   Li_FFF90 = Gi_00008;
   tmp_str0001E = "BullBarColor=";
   tmp_str0001D = Ls_FFFC0;
   Gi_00009 = StringFind(tmp_str0001D, tmp_str0001E);
   Li_FFF78 = Gi_00009;
   Ls_FFFA8 = "";
   Li_FFF74 = Gi_00008;
   if (Li_FFF74 < Gi_00009) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF74 = Li_FFF74 + 1;
   } while (Li_FFF74 < Li_FFF78); 
   } 
   tmp_str00021 = "calcolaDistanzaDaUltimoIncrocio=";
   if (calcolaDistanzaDaUltimoIncrocio) { 
   tmp_str00022 = "true";
   } 
   else { 
   tmp_str00022 = "false";
   } 
   tmp_str00021 = tmp_str00021 + tmp_str00022;
   tmp_str00021 = tmp_str00021 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00021);
   tmp_str00023 = Ls_FFFC0;
   tmp_str00025 = "PulseMatrixCorrelation";
   Gi_0000A = StringFind( tmp_str00023, tmp_str00025);
   Li_FFF70 = Gi_0000A;
   tmp_str00024 = exEA3;
   tmp_str00026 = Ls_FFFC0;
   Gi_0000B = StringFind(tmp_str00026, "strumento=");
   Li_FFF6C = Gi_0000B;
   Gi_0000C = StringFind(Ls_FFFC0, "periodoCorrelazione=");
   Li_FFF68 = Gi_0000C;
   Ls_FFFA8 = "";
   Ls_FFF58 = IntegerToString(periodoCorrelazione, 0, 32);
   Ls_FFF48 = IntegerToString(periodoMediaCorrelazione, 0, 32);
   Li_FFF44 = Gi_0000B;
   if (Li_FFF44 < Gi_0000C) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF44 = Li_FFF44 + 1;
   } while (Li_FFF44 < Li_FFF68); 
   } 
   tmp_str0002F = "strumento=" + Ls_FFF98;
   tmp_str0002F = tmp_str0002F + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str0002F);
   Gi_0000D = StringFind(Ls_FFFC0, "periodoCorrelazione=");
   Li_FFF68 = Gi_0000D;
   Gi_00010 = StringFind(Ls_FFFC0, "periodoMediaCorrelazione=");
   Li_FFF40 = Gi_00010;
   Ls_FFFA8 = "";
   Li_FFF3C = 0;
   if (Li_FFF3C < Gi_00010) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF3C = Li_FFF3C + 1;
   } while (Li_FFF3C < Li_FFF40); 
   } 
   tmp_str00038 = "periodoCorrelazione=" + Ls_FFF58;
   tmp_str00038 = tmp_str00038 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00038);
   Gi_00011 = StringFind(Ls_FFFC0, "periodoMediaCorrelazione=");
   Li_FFF40 = Gi_00011;
   Gi_00012 = StringFind(Ls_FFFC0, "</inputs>");
   Li_FFF38 = Gi_00012;
   Ls_FFFA8 = "";
   Li_FFF34 = Gi_00011;
   if (Li_FFF34 < Gi_00012) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF34 = Li_FFF34 + 1;
   } while (Li_FFF34 < Li_FFF38); 
   } 
   tmp_str00046 = "periodoMediaCorrelazione=" + Ls_FFF48;
   tmp_str00046 = tmp_str00046 + "";
   Li_FFF30 = StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00046);
   Gi_00013 = StringFind(Ls_FFFC0, "spreadRatiosecondoStrumento=");
   Li_FFF6C = Gi_00013;
   Ls_FFFA8 = "";
   Gi_00014 = StringFind(Ls_FFFC0, "ea=");
   Li_FFF2C = Gi_00014;
   Ls_FFF20 = IntegerToString(periodoBollinger, 0, 32);
   Ls_FFF10 = DoubleToString(deviazioneStandard, 2);
   Li_FFF0C = Gi_00013;
   if (Li_FFF0C < Gi_00014) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF0C = Li_FFF0C + 1;
   } while (Li_FFF0C < Li_FFF2C); 
   } 
   tmp_str00050 = "spreadRatiosecondoStrumento=" + Ls_FFF98;
   tmp_str00050 = tmp_str00050 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00050);
   Gi_00017 = StringFind(Ls_FFFC0, "periodoBollinger=");
   Li_FFF08 = Gi_00017;
   Ls_FFFA8 = "";
   Gi_00018 = StringFind(Ls_FFFC0, "deviazioneStandard=");
   Li_FFF04 = Gi_00018;
   Li_FFF00 = Gi_00017;
   if (Li_FFF00 < Gi_00018) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFF00 = Li_FFF00 + 1;
   } while (Li_FFF00 < Li_FFF04); 
   } 
   tmp_str00060 = "periodoBollinger=" + Ls_FFF20;
   tmp_str00060 = tmp_str00060 + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str00060);
   Gi_0001C = StringFind(Ls_FFFC0, "</inputs>");
   Li_FFEFC = Gi_0001C;
   Gi_0001D = StringFind(Ls_FFFC0, "deviazioneStandard=");
   Li_FFF04 = Gi_0001D;
   Ls_FFFA8 = "";
   Li_FFEF8 = Gi_0001D;
   if (Li_FFEF8 < Gi_0001C) { 
   do { 
   Ls_FFFA8 = Ls_FFFA8 + Ls_FFFC0;
   Li_FFEF8 = Li_FFEF8 + 1;
   } while (Li_FFEF8 < Li_FFEFC); 
   } 
   tmp_str0006E = "deviazioneStandard=" + Ls_FFF10;
   tmp_str0006E = tmp_str0006E + "";
   StringReplace(Ls_FFFC0, Ls_FFFA8, tmp_str0006E);
   Ls_FFFD0 = Ls_FFFC0;
   Comment("");
   FileClose(Li_FFFDC);
   } 
   if (Ls_FFFD0 == "") return; 
   Li_FFFDC = FileOpen(Ls_FFFE0, 18);
   if (Li_FFFDC < 0) { 
   Print("Error code ", GetLastError());
   return ;
   } 
   FileWrite(Li_FFFDC, Ls_FFFD0);
   FileClose(Li_FFFDC);
   
}
