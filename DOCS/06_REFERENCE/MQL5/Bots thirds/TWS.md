; saved automatically on 2025.12.26 12:00:07
; this file contains last used input parameters for testing/optimizing TWS Trade Pilot v14.01 expert advisor
;
; AI BASED TIMEFRAME SWITCH
InpEnableAutoSwitchTF=true||false||0||true||N
InpEntryTimeframe=1||0||0||49153||N
InpManagementTimeframe=16385||0||0||49153||N
; ===== CORE SETTINGS =====
InpMagicNumber=202501||202501||1||2025010||N
; ===== TRADING DIRECTION  =====
InpTradingDirection=1||0||0||2||N
; ===== RISK FILTERS =====
EnableFilterClock=false||false||0||true||N
InpTradingStartTime=9||9||1||90||N
InpMinutesStartTrading=0||0||1||10||N
InpMinutesEndTrading=17||17||1||170||N
InpMinutesCompleteTrading=0||0||1||10||N
InpEnableLeverageFilter=false||false||0||true||N
InpMinimalLeverage=2000||2000||1||20000||N
; ===== SPREAD & SLIPPAGE CONTROL =====
InpEnableSpreadFilter=true||false||0||true||N
InpMaximumSpread=300||300||1||3000||N
InpEnableSlippageControl=false||false||0||true||N
InpMaximumSlippage=30||30||1||300||N
; ===== EMA TREND SETTINGS =====
InpEmaPeriod=5||5||1||50||N
InpEmaShift=0||0||1||10||N
InpEmaMethod=0||0||0||3||N
InpEmaPrice=1||1||0||7||N
; ===== INITIAL ENTRY SETTINGS =====
InpEntryMode=0||0||0||1||N
InpInitialLot=0.01||0.01||0.001000||0.100000||N
InpEnableEmaDistanceFilter=false||false||0||true||N
InpMaxDistancePoints=1000||1000||1||10000||N
InpEnableRsiCounterTrend=false||false||0||true||N
; ===== MAX LOT LIMITER =====
InpEnableMaxLot=false||false||0||true||N
InpMaxLotSize=0.1||0.1||0.010000||1.000000||N
InpStopTradingAtMaxLot=false||false||0||true||N
; ===== CLOSEBY & HEDGE SETTINGS =====
InpEnableCloseBy=true||false||0||true||N
InpCloseByBeforeRegular=true||false||0||true||N
InpCloseByMaxAttempts=3||3||1||30||N
InpCloseByRetryDelayMs=50||50||1||500||N
InpEnableCloseByLogging=true||false||0||true||N
; ===== PYRAMIDING SETTINGS (Profit Mode) =====
InpPyramidEnabled=true||false||0||true||N
InpPyramidTriggerPoints=2000||1500||1||15000||N
InpPyramidLotMultiplier=1.0||1.0||0.100000||10.000000||N
InpMaxPyramidOrders=100||100||1||1000||N
; ===== MARTINGALE SETTINGS (Loss Mode) =====
InpEnableMartingale=true||false||0||true||N
InpEnableMartingaleRsiFilter=false||false||0||true||N
InpMartingaleDistancePoints=300||400||1||4000||N
InpMartingaleLotMultiplier=1.1||1.1||0.110000||11.000000||N
InpMartingaleMaxOrders=1000||1000||1||10000||N
; ===== RSI INDICATOR SETTINGS =====
InpRsiPeriod=14||14||1||140||N
InpRsiPrice=1||1||0||7||N
InpRsiOverboughtLevel=70.0||70.0||7.000000||700.000000||N
InpRsiOversoldLevel=30.0||30.0||3.000000||300.000000||N
; ===== CUT LOSS (SAFETY NET) =====
InpEnableCutLoss=false||false||0||true||N
InpCutLossUSD=1000.0||1000.0||100.000000||10000.000000||N
; ===== GROUP BREAK EVEN PROTECTION =====
InpEnableGroupBEP=true||false||0||true||N
InpGroupBEP_MinOrders=1||1||1||10||N
InpGroupBEP_TriggerPoints=200||500||1||5000||N
InpGroupBEP_LockPoints=200||500||1||5000||N
; ===== TRAILING STOP SETTINGS =====
InpTrailingEnabled=true||false||0||true||N
InpTrailingTriggerPoints=300||600||1||6000||N
InpTrailingDistancePoints=100||500||1||5000||N
InpCloseAllOnTrailingHit=true||false||0||true||N
; ===== ADVANCED PROTECTION =====
InpEnableClientSideSL=true||false||0||true||N
InpClientSLBufferPoints=10||10||1||100||N
InpMaxCloseAttempts=10||10||1||100||N
InpCloseRetryDelayMs=100||100||1||1000||N
InpEnablePanicMode=true||false||0||true||N
InpPanicModeThreshold=5||5||1||50||N
; ===== DEBUG & LOGGING =====
InpEnableDetailedLog=true||false||0||true||N
InpEnableTradeHistory=true||false||0||true||N
