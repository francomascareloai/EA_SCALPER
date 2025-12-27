; ===== 🔐 SECURITY & EXPIRATION =====
InpPassword=sanchitchopra
InpExpirationDate=1795219200
; ===== 🆕 AUTO SWITCH TIMEFRAME (v1.9) =====
InpEnableAutoSwitchTF=true
InpEntryTimeframe=1
InpManagementTimeframe=16385
; ===== CORE SETTINGS =====
InpMagicNumber=202501
; ===== 🆕 TRADING DIRECTION (v1.8) =====
InpTradingDirection=1
; ===== RISK FILTERS =====
InpAktifkanFilterJam=false
InpJamMulaiTrading=9
InpMenitMulaiTrading=0
InpJamSelesaiTrading=17
InpMenitSelesaiTrading=0
InpAktifkanFilterLeverage=false
InpLeverageMinimal=2000
; ===== SPREAD & SLIPPAGE CONTROL =====
InpAktifkanFilterSpread=true
InpSpreadMaksimal=300
InpAktifkanKontrolSlippage=false
InpSlippageMaksimal=30
; ===== EMA TREND SETTINGS =====
InpEmaPeriod=5
InpEmaShift=0
InpEmaMethod=0
InpEmaPrice=1
; ===== INITIAL ENTRY SETTINGS =====
InpEntryMode=0
InpInitialLot=0.01
InpEnableEmaDistanceFilter=true
InpMaxDistancePoints=1000
InpEnableRsiCounterTrend=false
; ===== MAX LOT LIMITER =====
InpEnableMaxLot=false
InpMaxLotSize=0.1
InpStopTradingAtMaxLot=false
; ===== CLOSEBY & HEDGE SETTINGS (v1.7) =====
InpEnableCloseBy=true
InpCloseByBeforeRegular=true
InpCloseByMaxAttempts=3
InpCloseByRetryDelayMs=50
InpEnableCloseByLogging=true
; ===== PYRAMIDING SETTINGS (Profit Mode) =====
InpPyramidEnabled=true
InpPyramidTriggerPoints=2000
InpPyramidLotMultiplier=1.0
InpMaxPyramidOrders=100
; ===== MARTINGALE SETTINGS (Loss Mode) =====
InpEnableMartingale=true
InpEnableMartingaleRsiFilter=false
InpMartingaleDistancePoints=300
InpMartingaleLotMultiplier=1.1
InpMartingaleMaxOrders=1000
; ===== RSI INDICATOR SETTINGS =====
InpRsiPeriod=14
InpRsiPrice=1
InpRsiOverboughtLevel=70.0
InpRsiOversoldLevel=30.0
; ===== CUT LOSS (SAFETY NET) =====
InpEnableCutLoss=false
InpCutLossUSD=1000.0
; ===== GROUP BREAK EVEN PROTECTION =====
InpEnableGroupBEP=true
InpGroupBEP_MinOrders=1
InpGroupBEP_TriggerPoints=200
InpGroupBEP_LockPoints=200
; ===== TRAILING STOP SETTINGS =====
InpTrailingEnabled=true
InpTrailingTriggerPoints=300
InpTrailingDistancePoints=100
InpCloseAllOnTrailingHit=true
; ===== ADVANCED PROTECTION =====
InpEnableClientSideSL=true
InpClientSLBufferPoints=10
InpMaxCloseAttempts=10
InpCloseRetryDelayMs=100
InpEnablePanicMode=true
InpPanicModeThreshold=5
; ===== DEBUG & LOGGING =====
InpEnableDetailedLog=true
InpEnableTradeHistory=true
