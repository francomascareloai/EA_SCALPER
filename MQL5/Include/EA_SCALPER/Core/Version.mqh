//+------------------------------------------------------------------+
//|                                                     Version.mqh |
//|                     EA_SCALPER_XAUUSD - Version Constants        |
//|                     Migration from Python/Nautilus v2.2          |
//+------------------------------------------------------------------+
#ifndef VERSION_MQH
#define VERSION_MQH

//--- EA Version Information
#define EA_VERSION          "4.0.0"
#define EA_VERSION_MAJOR    4
#define EA_VERSION_MINOR    0
#define EA_VERSION_PATCH    0

//--- Build Information
#define BUILD_DATE          __DATE__
#define BUILD_TIME          __TIME__
#define MIGRATION_SOURCE    "Python/Nautilus v2.2"

//--- Apex Compliance Flag
#define APEX_COMPLIANT      true

//--- Version String for Logging
#define EA_VERSION_STRING   "EA_SCALPER_XAUUSD v" + EA_VERSION + " (Apex)"

//--- Minimum Requirements
#define MIN_MT5_BUILD       3000
#define MIN_ACCOUNT_BALANCE 50000.0

#endif // VERSION_MQH
//+------------------------------------------------------------------+
