//+------------------------------------------------------------------+
//|                                           CRiskProfileManager.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                        Configurable Risk Profile System            |
//+------------------------------------------------------------------+
//| FORGE-1: Risk Profile System
//|
//| Purpose: Provide configurable risk profiles for different trading
//| aggressiveness levels while maintaining Apex compliance.
//|
//| Design Principles:
//| - MINIMAL code, maximum configurability
//| - Performance-first (no dynamic allocations in hot path)
//| - Apex-compliant at ALL levels (hard caps enforced)
//|
//| Profiles:
//| - SAFE: Conservative (1 pos, 0.25% risk, strict filters)
//| - BALANCED: Default (1-2 pos, 0.5% risk, standard filters)
//| - AGGRESSIVE: Growth (2-3 pos, 0.75% risk, relaxed filters)
//+------------------------------------------------------------------+
#ifndef CRISK_PROFILE_MANAGER_MQH
#define CRISK_PROFILE_MANAGER_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| Apex Safety Caps - NEVER exceeded regardless of profile          |
//+------------------------------------------------------------------+
#define APEX_MAX_TOTAL_EXPOSURE    3.0    // Max 3% of equity in total exposure
#define APEX_MAX_POSITIONS         3      // Max 3 simultaneous positions
#define APEX_MAX_RISK_PER_TRADE    1.0    // Max 1% risk per trade

//+------------------------------------------------------------------+
//| CRiskProfileManager - Manages trading risk profiles               |
//+------------------------------------------------------------------+
class CRiskProfileManager
{
private:
   ENUM_RISK_PROFILE m_profile;

   // Profile parameters (cached for performance - no dynamic allocation)
   int    m_max_positions;
   double m_risk_per_trade;
   double m_max_total_exposure;
   int    m_min_score_threshold;
   bool   m_allow_hedge;
   bool   m_allow_recovery_entry;
   double m_size_multiplier;

   // Initialization flag
   bool   m_initialized;

   // Internal: Apply profile settings
   void ApplyProfileSettings(ENUM_RISK_PROFILE profile);

   // Internal: Enforce Apex safety caps
   void EnforceApexCaps();

public:
   CRiskProfileManager();
   ~CRiskProfileManager();

   // Initialization
   bool Init(ENUM_RISK_PROFILE profile);
   bool IsInitialized() const { return m_initialized; }

   // Getters (inline for performance - hot path)
   int    GetMaxPositions()       const { return m_max_positions; }
   double GetRiskPerTrade()       const { return m_risk_per_trade; }
   double GetMaxTotalExposure()   const { return m_max_total_exposure; }
   int    GetMinScoreThreshold()  const { return m_min_score_threshold; }
   bool   AllowHedge()            const { return m_allow_hedge; }
   bool   AllowRecoveryEntry()    const { return m_allow_recovery_entry; }
   double GetSizeMultiplier()     const { return m_size_multiplier; }

   // Profile management (runtime switching)
   void SetProfile(ENUM_RISK_PROFILE profile);
   ENUM_RISK_PROFILE GetProfile() const { return m_profile; }

   // Utility
   string GetProfileName() const;
   void   PrintStatus() const;

   // Validation helpers
   bool CanOpenPosition(int current_positions) const;
   double GetAdjustedRisk(double base_risk) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CRiskProfileManager::CRiskProfileManager()
{
   m_profile = RISK_BALANCED;
   m_max_positions = 2;
   m_risk_per_trade = 0.5;
   m_max_total_exposure = 1.5;
   m_min_score_threshold = 60;
   m_allow_hedge = true;
   m_allow_recovery_entry = true;
   m_size_multiplier = 1.0;
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CRiskProfileManager::~CRiskProfileManager()
{
}

//+------------------------------------------------------------------+
//| Initialize with specified profile                                 |
//+------------------------------------------------------------------+
bool CRiskProfileManager::Init(ENUM_RISK_PROFILE profile)
{
   ApplyProfileSettings(profile);
   EnforceApexCaps();
   m_initialized = true;

   PrintStatus();
   return true;
}

//+------------------------------------------------------------------+
//| Apply settings based on profile (hardcoded for speed)             |
//+------------------------------------------------------------------+
void CRiskProfileManager::ApplyProfileSettings(ENUM_RISK_PROFILE profile)
{
   m_profile = profile;

   // Profile definitions (hardcoded for performance)
   // | Profile    | MaxPos | Risk/Trade | MaxExposure | MinScore | AllowHedge | AllowRecovery | SizeMult |
   // |------------|--------|------------|-------------|----------|------------|---------------|----------|
   // | SAFE       | 1      | 0.25%      | 0.5%        | 70       | false      | false         | 0.5      |
   // | BALANCED   | 2      | 0.5%       | 1.5%        | 60       | true       | true          | 1.0      |
   // | AGGRESSIVE | 3      | 0.75%      | 2.5%        | 50       | true       | true          | 1.25     |

   switch(profile)
   {
      case RISK_SAFE:
         m_max_positions = 1;
         m_risk_per_trade = 0.25;
         m_max_total_exposure = 0.5;
         m_min_score_threshold = 70;
         m_allow_hedge = false;
         m_allow_recovery_entry = false;
         m_size_multiplier = 0.5;
         break;

      case RISK_BALANCED:
         m_max_positions = 2;
         m_risk_per_trade = 0.5;
         m_max_total_exposure = 1.5;
         m_min_score_threshold = 60;
         m_allow_hedge = true;
         m_allow_recovery_entry = true;
         m_size_multiplier = 1.0;
         break;

      case RISK_AGGRESSIVE:
         m_max_positions = 3;
         m_risk_per_trade = 0.75;
         m_max_total_exposure = 2.5;
         m_min_score_threshold = 50;
         m_allow_hedge = true;
         m_allow_recovery_entry = true;
         m_size_multiplier = 1.25;
         break;

      default:
         // Fallback to BALANCED if unknown
         m_max_positions = 2;
         m_risk_per_trade = 0.5;
         m_max_total_exposure = 1.5;
         m_min_score_threshold = 60;
         m_allow_hedge = true;
         m_allow_recovery_entry = true;
         m_size_multiplier = 1.0;
         Print("CRiskProfileManager: Unknown profile, defaulting to BALANCED");
         break;
   }
}

//+------------------------------------------------------------------+
//| Enforce Apex safety caps - NEVER exceeded                         |
//+------------------------------------------------------------------+
void CRiskProfileManager::EnforceApexCaps()
{
   // Formula: capped_value = min(profile_value, apex_cap)
   // Example: aggressive has risk=0.75%, apex_cap=1.0% -> min(0.75, 1.0) = 0.75% (OK)
   // Example: if profile had risk=1.5%, apex_cap=1.0% -> min(1.5, 1.0) = 1.0% (capped)

   // Apply Apex hard caps (NEVER exceeded regardless of profile)
   if(m_max_positions > APEX_MAX_POSITIONS)
   {
      Print("CRiskProfileManager: MaxPositions capped from ", m_max_positions, " to ", APEX_MAX_POSITIONS);
      m_max_positions = APEX_MAX_POSITIONS;
   }

   if(m_risk_per_trade > APEX_MAX_RISK_PER_TRADE)
   {
      Print("CRiskProfileManager: RiskPerTrade capped from ", DoubleToString(m_risk_per_trade, 2),
            "% to ", DoubleToString(APEX_MAX_RISK_PER_TRADE, 2), "%");
      m_risk_per_trade = APEX_MAX_RISK_PER_TRADE;
   }

   if(m_max_total_exposure > APEX_MAX_TOTAL_EXPOSURE)
   {
      Print("CRiskProfileManager: MaxTotalExposure capped from ", DoubleToString(m_max_total_exposure, 2),
            "% to ", DoubleToString(APEX_MAX_TOTAL_EXPOSURE, 2), "%");
      m_max_total_exposure = APEX_MAX_TOTAL_EXPOSURE;
   }

   // Ensure minimum sensible values
   if(m_risk_per_trade < 0.1) m_risk_per_trade = 0.1;
   if(m_max_total_exposure < 0.1) m_max_total_exposure = 0.1;
   if(m_min_score_threshold < 30) m_min_score_threshold = 30;
   if(m_min_score_threshold > 90) m_min_score_threshold = 90;
   if(m_size_multiplier < 0.1) m_size_multiplier = 0.1;
   if(m_size_multiplier > 2.0) m_size_multiplier = 2.0;
}

//+------------------------------------------------------------------+
//| Switch profile at runtime                                         |
//+------------------------------------------------------------------+
void CRiskProfileManager::SetProfile(ENUM_RISK_PROFILE profile)
{
   if(profile == m_profile)
      return;

   ENUM_RISK_PROFILE old_profile = m_profile;
   ApplyProfileSettings(profile);
   EnforceApexCaps();

   Print("CRiskProfileManager: Profile changed from ", EnumToString(old_profile),
         " to ", EnumToString(profile));
   PrintStatus();
}

//+------------------------------------------------------------------+
//| Get profile name as string                                        |
//+------------------------------------------------------------------+
string CRiskProfileManager::GetProfileName() const
{
   switch(m_profile)
   {
      case RISK_SAFE:       return "SAFE (Conservative)";
      case RISK_BALANCED:   return "BALANCED (Default)";
      case RISK_AGGRESSIVE: return "AGGRESSIVE (Growth)";
      default:              return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Print current status                                              |
//+------------------------------------------------------------------+
void CRiskProfileManager::PrintStatus() const
{
   Print("=== CRiskProfileManager Status ===");
   Print("  Profile: ", GetProfileName());
   Print("  MaxPositions: ", m_max_positions, " (Apex cap: ", APEX_MAX_POSITIONS, ")");
   Print("  RiskPerTrade: ", DoubleToString(m_risk_per_trade, 2), "% (Apex cap: ",
         DoubleToString(APEX_MAX_RISK_PER_TRADE, 2), "%)");
   Print("  MaxExposure: ", DoubleToString(m_max_total_exposure, 2), "% (Apex cap: ",
         DoubleToString(APEX_MAX_TOTAL_EXPOSURE, 2), "%)");
   Print("  MinScoreThreshold: ", m_min_score_threshold);
   Print("  AllowHedge: ", (m_allow_hedge ? "YES" : "NO"));
   Print("  AllowRecoveryEntry: ", (m_allow_recovery_entry ? "YES" : "NO"));
   Print("  SizeMultiplier: ", DoubleToString(m_size_multiplier, 2));
   Print("==================================");
}

//+------------------------------------------------------------------+
//| Check if can open new position based on current count             |
//+------------------------------------------------------------------+
bool CRiskProfileManager::CanOpenPosition(int current_positions) const
{
   if(!m_initialized)
   {
      Print("CRiskProfileManager: Not initialized - blocking position");
      return false;
   }

   if(current_positions >= m_max_positions)
   {
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Get adjusted risk based on profile multiplier                     |
//+------------------------------------------------------------------+
double CRiskProfileManager::GetAdjustedRisk(double base_risk) const
{
   if(!m_initialized)
      return 0.0;

   // Formula: adjusted_risk = min(base_risk * size_multiplier, profile_risk_per_trade)
   // Example: base_risk=0.5%, multiplier=0.5 -> 0.25%, capped by profile's risk_per_trade
   double adjusted = base_risk * m_size_multiplier;

   // Cap to profile's risk per trade
   if(adjusted > m_risk_per_trade)
      adjusted = m_risk_per_trade;

   // Final Apex cap
   if(adjusted > APEX_MAX_RISK_PER_TRADE)
      adjusted = APEX_MAX_RISK_PER_TRADE;

   return adjusted;
}

#endif // CRISK_PROFILE_MANAGER_MQH
//+------------------------------------------------------------------+
