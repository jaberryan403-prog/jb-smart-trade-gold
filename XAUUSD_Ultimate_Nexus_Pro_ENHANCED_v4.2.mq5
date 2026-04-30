//+------------------------------------------------------------------+
//|                    XAUUSD_Ultimate_Nexus_Pro_ENHANCED_v4.2       |
//|              Professional Grade - All Fixes & Enhancements       |
//|                           Institutional Trading Systems 2026     |
//+------------------------------------------------------------------+
#property copyright "JB Smart Trade Gold - Professional Edition 2026"
#property link      "https://pro.trading"
#property version   "4.10"
#property strict
#property description "✅ Fixed: Telegram UTF-8, Screenshots, SMC Validation"
#property description "✅ Enhanced: Dynamic Weighting, 3-Phase Entry, Backtesting"
#property description "✅ Added: Multi-Timeframe, Order Flow, Performance Tracking"
//====================================================================
//  INPUT PARAMETERS
//====================================================================
input group "=== SECURITY & TELEGRAM ==="
input string InpTeleBotToken     = "8667609013:AAEI2ERiBasGfA0ClfGqW2zozG0I77W5KKc";      // Bot Token (Keep Secret!)
input string InpTeleChatID       = "5486924120";      // Chat ID
input bool   InpUseTelegram      = true;    // Enable Telegram
input bool   InpTeleSendScreen   = true;    // Send Screenshots
input bool   InpAllowRemoteControl = true;  // Enable Remote Commands
input group "=== CORE ANALYSIS LAYERS ==="
input bool InpUseMacroLayer      = true;    // Layer 0: Macro (D1/H4)
input bool InpUseStructureLayer  = true;    // Layer 1: Market Structure
input bool InpUseSmartMoneyLayer = true;    // Layer 2: SMC (OB/FVG/Sweep)
input bool InpUseFibonacciLayer  = true;    // Layer 3: Fibonacci OTE
input bool InpUseWyckoffLayer    = true;    // Layer 4: Wyckoff VSA
input bool InpUsePatternLayer    = true;    // Layer 5: Price Patterns
input bool InpUseDivergenceLayer = true;    // Layer 6: RSI/MACD Divergence
input bool InpUseVolumeLayer     = true;    // Layer 7: Volume & VWAP
input bool InpUseSessionLayer    = true;    // Layer 8: Session Killzones
input bool InpUseDXYLayer        = true;    // Layer 9: DXY Correlation
input bool InpUseSeasonality     = true;    // Layer 10: Gold Seasonality
input bool InpUsePowerOf3        = true;    // Layer 11: PO3 (AMD)
input group "=== ENHANCED FEATURES (NEW) ==="
input bool   InpUseMultiTF       = true;    // Multi-Timeframe Confirmation
input bool   InpUseOrderFlow     = true;    // Order Flow Imbalance
input bool   InpUseBacktesting   = true;    // Track Signal Performance
input bool   InpUseDynamicWeights = true;   // Adaptive Layer Weights
input group "=== CONFLUENCE & RISK ==="
input int    InpMinConfirmLayers = 6;       // Min confirmed layers for A+
input double InpSignalThreshold  = 7.0;     // Minimum score (0-10)
input double InpRiskPerTrade     = 1.0;     // Risk % per trade
input double InpMaxSpreadPips    = 3.5;     // Max spread for Gold
input bool   InpRequireMacroVeto = true;    // Block if macro conflicts
input int    InpMaxDailyTrades   = 5;       // Max trades per day
input double InpMaxDailyLossPct  = 3.0;     // Max daily loss %
input group "=== NEWS FILTER ==="
input bool   InpUseNewsFilter    = true;
input int    InpNewsMinutesBefore = 30;
input int    InpNewsMinutesAfter  = 30;
input string InpHighImpactSymbols = "USD,EUR,GBP";
input group "=== SYSTEM & EXPORT ==="
input bool   InpAutoExport       = true;    // Auto export reports
input int    InpExportInterval   = 15;      // Export interval (minutes)
input string InpExportFolder     = "GBReports";
input bool   InpUsePushAlerts    = true;
input bool   InpUseSoundAlerts   = true;
input double InpMinAlertScore    = 8.0;
input group "=== RISK PROTECTION ==="
input bool   InpKillSwitchEnabled = true;    // Enable Kill Switch
input int    InpMaxConsecutiveLoss = 3;      // Max Consecutive Losses before pause
input double InpMaxDrawdownPct    = 5.0;     // Max Daily Drawdown % before pause
input int    InpKillSwitchCooldown = 60;     // Cooldown minutes after Kill Switch
input group "=== SEMI-AUTO EXECUTION ==="
input bool   InpSemiAutoEnabled  = false;   // Enable Semi-Auto Pending Orders
input string InpSemiAutoMinGrade = "A+";    // Min Grade for Auto Order (A+++, A+, A, B)
input double InpSemiAutoRiskPct  = 1.0;     // Risk % for Semi-Auto Orders
input bool   InpSemiAutoRequireConfirm = true; // Require Telegram /confirm before placing
input group "=== ADVANCED FILTERS ==="
input bool   InpUseCorrelation   = true;
input int    InpCorrelationPeriod = 50;
input bool   InpUsePsychology    = true;
//====================================================================
//  ENHANCED DATA STRUCTURES
//====================================================================
// Market Regime Detection
enum MARKET_REGIME {
   REGIME_STRONG_TREND,    // ATR high + Clear trend
   REGIME_WEAK_TREND,      // ATR medium + Weak trend
   REGIME_RANGING,         // ATR low + No trend
   REGIME_VOLATILE_CHOP    // ATR high + No trend (dangerous!)
};
// Entry Phase System
enum ENTRY_PHASE {
   PHASE_WAITING,      // No setup
   PHASE_SETUP,        // Setup ready (Score >= 7)
   PHASE_TRIGGER,      // Trigger active (Price in Zone + Volume)
   PHASE_CONFIRMED     // Confirmed (Rejection candle closed)
};
// Enhanced Order Block
struct OrderBlockPro {
   double high, low;
   datetime time;
   bool isValid;
   bool isMitigated;
   bool hasBOS;              // BOS confirmed after OB
   bool hasVolSpike;         // Volume spike on formation
   bool hasRejection;        // Price rejected from zone
   int strength;             // 1-10 rating
   double mitigation_percent; // % of OB touched
   int touchCount;           // How many times retested
};
// Enhanced Liquidity Sweep
struct LiquiditySweep {
   bool detected;
   string direction;         // "BULLISH_SWEEP" or "BEARISH_SWEEP"
   double sweepLevel;
   datetime sweepTime;
   bool hasVolSpike;
   bool hasRejection;
   int strength;             // 1-10
   double sweepDistance;     // How far beyond the level
};
// Multi-Timeframe Confirmation
struct MTFConfirmation {
   string m5_bias;
   string m15_bias;
   string h1_bias;
   string h4_bias;
   bool allAligned;
   int alignedCount;
   double confidence;        // 0-100%
};
// Order Flow Imbalance
struct OrderFlowImbalance {
   bool detected;
   string type;              // "BULLISH_OFI" or "BEARISH_OFI"
   double imbalanceRatio;    // Ratio of buying/selling pressure
   int consecutiveBars;      // How many bars in same direction
   double strength;          // 0-10
};
// Power of 3 (AMD) Structure
struct PowerOf3 {
   bool detected;
   string phase;        // ACCUMULATION, MANIPULATION, DISTRIBUTION
   string bias;
   double strength;     // 0-10
   double manipulationRange;
};
// Performance Tracking
struct SignalPerformance {
   datetime signalTime;
   string direction;
   double score;
   string grade;
   double entry;
   double sl;
   double tp1;
   double tp2;
   bool wasExecuted;         // Did price reach entry?
   bool hitSL;
   bool hitTP1;
   bool hitTP2;
   double maxFavorableExcursion; // MFE
   double maxAdverseExcursion;   // MAE
   double finalPnL;
   int barsToTarget;
};
// Layer Conflict Detection
struct LayerConflict {
   bool hasConflict;
   int conflictCount;
   string conflicts[10];      // Up to 10 conflict descriptions
   string severity;           // "LOW", "MEDIUM", "HIGH", "CRITICAL"
   double confidenceReduction; // How much to reduce confidence (0-50%)
};
// Grade Performance Statistics
struct GradeStats {
   int totalSignals;
   int wins;
   int losses;
   int pending;
   double winRate;
   double avgPnL;
   double avgMFE;
   double avgMAE;
   double bestPnL;
   double worstPnL;
};
// Semi-Auto Pending Order
struct PendingSignalOrder {
   bool isActive;
   bool isConfirmed;
   string direction;
   string grade;
   double score;
   double entry;
   double sl;
   double tp1;
   double tp2;
   double tp3;
   double lotSize;
   datetime signalTime;
   datetime expiryTime;
};
// Dynamic Layer Weights
struct LayerWeights {
   double macro;
   double structure;
   double smc;
   double fib;
   double wyckoff;
   double volume;
   double dxy;
   double seasonality;
   double pattern;
   double divergence;
};
// Enhanced Entry Signal
struct EntrySignalPro {
   ENTRY_PHASE phase;
   string direction;
   double setupScore;
   double triggerScore;
   double confirmScore;
   double totalScore;
   string grade;
   double entry, sl, tp1, tp2, tp3;
   double lotSize;
   double rr;
   string rejectionReason;
   bool validated;
   int confirmedLayers;
   datetime setupTime;
   datetime triggerTime;
   datetime confirmTime;
};
// Original structures (keeping for compatibility)
struct MacroBias { 
   string d1Bias, h4Bias; 
   double d1Score, h4Score; 
   bool isAligned; 
};
struct MarketStructure {
   string trend;
   bool hasBOS, hasCHoCH;
   double structuralHigh, structuralLow;
   double score;
   double bosLevel;
   double chochLevel;
};
struct SmartMoney {
   OrderBlockPro bullOB, bearOB;
   double bullFVG_High, bullFVG_Low;
   double bearFVG_High, bearFVG_Low;
   bool liquiditySwept;
   string bias;
   double score;
   double sweepHigh, sweepLow;
   bool hasSweep;
};
struct Fibonacci {
   double oteHigh, oteLow;
   bool inOTE, inDiscount, inPremium;
   string bias;
   double premiumZoneHigh, premiumZoneLow;
   double discountZoneHigh, discountZoneLow;
   double equilibrium;
};
struct Wyckoff {
   string phase;
   string vsaSignal;
   double strength;
   string bias;
   string eventType;   // SPRING, UPTHRUST, SOS, SOW, TEST, NONE
   double eventScore;  // 0-10
   bool hasSpring;
   bool hasUpthrust;
   bool hasTestAfterSpring;
   bool hasSignOfStrength;
};
struct Pattern {
   string name;
   bool confirmed;
   double target;
   string bias;
};
struct Divergence {
   string type;
   double strength;
   bool confirmed;
};
struct VolumeVWAP {
   double vwap;
   string position;
   bool volSpike;
   string bias;
   double relativeVolume;
   double avgVolume;
};
struct SessionInfo {
   string currentSession;
   bool isKillzone;
   string killzoneName;
   double weight;
};
struct DXYCorrelation {
   double current;
   string trend;
   double correlation;
   double corrPercent;
   string goldImpact;
   string silverTrend;
   string yieldsTrend;
   string sentiment;
   double proxyDXY;        // Multi-pair proxy DXY value
   string proxyTrend;      // Proxy DXY trend
   double trendStrength;   // 0-10 scale
   bool isDecoupling;      // Gold vs USD decoupling detected
};
// Institutional Positioning (COT-style)
// CFTC COT Real Data
struct COTData {
   datetime reportDate;
   long specLong;            // Non-Commercial Long (Large Speculators)
   long specShort;           // Non-Commercial Short
   long commLong;            // Commercial Long (Hedgers)
   long commShort;           // Commercial Short
   long smallLong;           // Non-Reportable Long (Small Traders)
   long smallShort;          // Non-Reportable Short
   double netSpec;           // specLong - specShort
   double netComm;           // commLong - commShort
   double specIndex;         // Normalized 0-100 (52-week range)
   bool isValid;
   string source;            // "CFTC_WEB", "CFTC_CSV", "VSA_PROXY"
};
// Institutional Positioning (COT + VSA Combined)
struct InstitutionalPosition {
   double netPositioning;   // -100 to +100 (negative=short, positive=long)
   string bias;             // BULLISH, BEARISH, NEUTRAL
   double volumeRatio;      // Current vs avg volume ratio
   double bigPlayerBias;    // Detected big player direction
   double accumulationScore; // 0-10 accumulation/distribution
   string phase;            // ACCUMULATING, DISTRIBUTING, NEUTRAL
   // COT Real Data Fields
   double cotNetSpec;       // CFTC Net Speculator position
   double cotNetComm;       // CFTC Net Commercial position
   double cotSpecIndex;     // Speculator Index 0-100
   string cotSource;        // Data source used
   bool   cotDataAvailable; // Whether real CFTC data was loaded
};
// Session Performance Tracking
struct SessionPerformance {
   int asianSignals;
   int asianWins;
   int londonSignals;
   int londonWins;
   int nySignals;
   int nyWins;
   int overlapSignals;
   int overlapWins;
   string bestSession;
   double bestSessionWinRate;
};
// Kill Switch State
struct KillSwitchState {
   bool isActive;
   int consecutiveLosses;
   int maxConsecutiveLosses;
   double dailyDrawdown;
   double maxDailyDrawdown;
   string reason;
   datetime activatedTime;
};
struct Seasonality {
   string monthlyBias;
   string dayBias;
   double seasonalScore;
};
struct NewsEvent {
   datetime time;
   string currency;
   string impact;
   string event;
   bool isHighImpact;
};
struct TelegramMsg {
   string text;
   datetime queueTime;
   bool isFile;
   string filePath;
   string caption;
};
//====================================================================
//  GLOBAL VARIABLES
//====================================================================
// Original globals
MacroBias      g_macro;
MarketStructure g_structure;
SmartMoney     g_smartMoney;
Fibonacci      g_fib;
Wyckoff        g_wyckoff;
Pattern        g_pattern;
Divergence     g_divergence;
VolumeVWAP     g_volume;
SessionInfo    g_session;
DXYCorrelation g_dxy;
Seasonality    g_seasonal;
// Enhanced globals
EntrySignalPro g_entrySignal;
MTFConfirmation g_mtf;
OrderFlowImbalance g_orderFlow;
PowerOf3 g_powerOf3;
MARKET_REGIME g_currentRegime;
LayerWeights g_weights;
LiquiditySweep g_liquiditySweep;
// Performance tracking
SignalPerformance g_performanceHistory[];
int g_totalSignals = 0;
int g_winningSignals = 0;
int g_losingSignals = 0;
double g_totalPnL = 0;
double g_winRate = 0;
double g_avgRR = 0;
// Indicators
int g_handle_atr, g_handle_rsi, g_handle_macd;
int g_handle_atr_h1, g_handle_atr_h4; // Multi-TF ATR
// FIX #3: Global MA handles to prevent memory leak in AnalyzeMacro()
int g_handle_ma_d1, g_handle_ma_h4, g_handle_ma_d1_50, g_handle_ma_d1_20;
// System state
datetime g_lastExport = 0;
datetime g_lastAlertTime = 0;
string   g_lastAlertMsg = "";
datetime g_lastUIUpdate = 0;
bool     g_isRunning = true;
long     g_lastUpdateId = 0;
datetime g_lastCommandCheck = 0;
// News filter
NewsEvent  g_newsEvents[];
datetime   g_nextNewsTime = 0;
string     g_newsStatus = "NO_NEWS";
bool       g_newsPauseActive = false;
datetime   g_lastNewsLoad = 0;
// Telegram queue
TelegramMsg g_telegramQueue[];
datetime    g_lastTelegramSend = 0;
const int   TELEGRAM_COOLDOWN_MS = 1500;
// Security - Authorized Chat ID (set to empty to allow all, or set specific ID)
string g_authorizedChatID = "5486924120"; // Leave empty to allow all chats, or set specific Chat ID
// Layer Conflict
LayerConflict g_layerConflict;
// Institutional Positioning & COT
InstitutionalPosition g_institutional;
COTData g_cotData;
COTData g_cotHistory[];    // Historical COT for 52-week range
datetime g_lastCOTLoad = 0;
bool g_cotInitialized = false;
// Session Performance
SessionPerformance g_sessionPerf;
// Kill Switch
KillSwitchState g_killSwitch;
// Grade Performance (A+++, A+, A, B, C, D = 6 grades)
GradeStats g_gradeStats[];  // indexed 0-5
// Semi-Auto Order
PendingSignalOrder g_pendingOrder;
// Historical Backtest Results
int g_backtestTotalSignals = 0;
int g_backtestWins = 0;
int g_backtestLosses = 0;
double g_backtestWinRate = 0;
double g_backtestAvgRR = 0;
bool g_backtestCompleted = false;
int g_backtestLayersUsed = 0;
double g_backtestAvgSpread = 0;
int g_backtestTP1Hits = 0;
int g_backtestTP2Hits = 0;
int g_backtestTP3Hits = 0;
// Per-session backtest stats
int g_btAsianSignals=0, g_btAsianWins=0;
int g_btLondonSignals=0, g_btLondonWins=0;
int g_btOverlapSignals=0, g_btOverlapWins=0;
int g_btNYSignals=0, g_btNYWins=0;
string g_btBestSession = "UNKNOWN";
double g_btBestSessionRate = 0;
// Daily limits
int      g_dailyTradeCount    = 0;
datetime g_lastTradeDay       = 0;
double   g_dailyStartBalance  = 0;
//====================================================================
//  PIP HELPERS (Gold-specific conversion)
//  Industry standard for XAUUSD: 1 pip = 0.10 USD movement.
//====================================================================
double GoldPip() {
   // 3 or 5 digit broker -> point=0.001 / 0.00001 -> pip = point * 100
   // 2 or 4 digit broker -> point=0.01  / 0.0001  -> pip = point * 10
   if(_Digits >= 3) return _Point * 100.0;
   return _Point * 10.0;
}
double FromPips(double pips) {
   return pips * GoldPip();
}
double ToPips(double priceDelta) {
   double pip = GoldPip();
   return (pip > 0) ? priceDelta / pip : 0;
}
//====================================================================
//  NEWS FILTER (lightweight stub - integrate external calendar later)
//  Maintains g_newsStatus/g_newsPauseActive so the rest of the system
//  can keep functioning even before a real news feed is wired in.
//====================================================================
void LoadNewsCalendar() {
   // Reload at most once per hour
   if(TimeCurrent() - g_lastNewsLoad < 3600 && g_lastNewsLoad > 0) return;
   g_lastNewsLoad = TimeCurrent();
   ArrayResize(g_newsEvents, 0);
   g_nextNewsTime = 0;
   g_newsStatus = "NO_NEWS";
}
void CheckNewsFilter() {
   if(!InpUseNewsFilter) {
      g_newsPauseActive = false;
      g_newsStatus = "FILTER_OFF";
      return;
   }
   // Default: no high-impact event detected unless calendar populated
   if(ArraySize(g_newsEvents) == 0) {
      g_newsPauseActive = false;
      g_newsStatus = "NO_NEWS";
      return;
   }
   datetime now = TimeCurrent();
   bool nearEvent = false;
   for(int i = 0; i < ArraySize(g_newsEvents); i++) {
      if(!g_newsEvents[i].isHighImpact) continue;
      long dt = (long)(g_newsEvents[i].time - now);
      if(dt >= -InpNewsMinutesAfter * 60 && dt <= InpNewsMinutesBefore * 60) {
         nearEvent = true;
         g_nextNewsTime = g_newsEvents[i].time;
         break;
      }
   }
   g_newsPauseActive = nearEvent;
   g_newsStatus = nearEvent ? "PAUSED_HIGH_IMPACT" : "CLEAR";
}
//====================================================================
//  INSTITUTIONAL POSITIONING (REAL CFTC COT + VSA COMBINED)
//====================================================================
// --- CFTC COT Data Loading ---
bool LoadCOTFromCSV() {
   // Load from local CSV: MQL5/Files/COT_Gold_Data.csv
   // Expected CSV format (header + data rows):
   // Date,Spec_Long,Spec_Short,Comm_Long,Comm_Short,Small_Long,Small_Short
   // 2026-04-22,287000,98000,45000,235000,32000,31000
   
   string filename = "COT_Gold_Data.csv";
   int handle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_COMMON, ',');
   if(handle == INVALID_HANDLE) {
      handle = FileOpen(filename, FILE_READ|FILE_CSV, ',');
      if(handle == INVALID_HANDLE) return false;
   }
   
   // Skip header
   if(!FileIsEnding(handle)) {
      string h1 = FileReadString(handle); // Date
      string h2 = FileReadString(handle); // Spec_Long
      string h3 = FileReadString(handle); // Spec_Short
      string h4 = FileReadString(handle); // Comm_Long
      string h5 = FileReadString(handle); // Comm_Short
      string h6 = FileReadString(handle); // Small_Long
      string h7 = FileReadString(handle); // Small_Short
   }
   
   int rowCount = 0;
   ArrayResize(g_cotHistory, 0);
   
   while(!FileIsEnding(handle) && rowCount < 52) {
      COTData row;
      row.isValid = false;
      
      string dateStr = FileReadString(handle);
      if(StringLen(dateStr) < 8) break;
      
      row.reportDate = StringToTime(dateStr);
      row.specLong = (long)StringToInteger(FileReadString(handle));
      row.specShort = (long)StringToInteger(FileReadString(handle));
      row.commLong = (long)StringToInteger(FileReadString(handle));
      row.commShort = (long)StringToInteger(FileReadString(handle));
      row.smallLong = (long)StringToInteger(FileReadString(handle));
      row.smallShort = (long)StringToInteger(FileReadString(handle));
      
      row.netSpec = (double)(row.specLong - row.specShort);
      row.netComm = (double)(row.commLong - row.commShort);
      row.source = "CFTC_CSV";
      row.isValid = (row.specLong > 0 || row.specShort > 0);
      
      if(row.isValid) {
         int size = ArraySize(g_cotHistory);
         ArrayResize(g_cotHistory, size + 1);
         g_cotHistory[size] = row;
         rowCount++;
      }
   }
   
   FileClose(handle);
   
   if(rowCount > 0) {
      g_cotData = g_cotHistory[0]; // Most recent
      
      // Calculate 52-week Speculator Index
      if(rowCount >= 4) {
         double maxNet = g_cotHistory[0].netSpec;
         double minNet = g_cotHistory[0].netSpec;
         int lookback = MathMin(rowCount, 52);
         for(int i = 1; i < lookback; i++) {
            if(g_cotHistory[i].netSpec > maxNet) maxNet = g_cotHistory[i].netSpec;
            if(g_cotHistory[i].netSpec < minNet) minNet = g_cotHistory[i].netSpec;
         }
         double range = maxNet - minNet;
         if(range > 0)
            g_cotData.specIndex = ((g_cotData.netSpec - minNet) / range) * 100.0;
         else
            g_cotData.specIndex = 50.0;
      } else {
         g_cotData.specIndex = 50.0;
      }
      
      Print("COT CSV loaded: ", rowCount, " weeks, Net Spec: ", g_cotData.netSpec, 
            ", Spec Index: ", DoubleToString(g_cotData.specIndex, 1), "%");
      return true;
   }
   return false;
}
bool LoadCOTFromWeb() {
   // Try CFTC Disaggregated Futures report (Gold = code 088691)
   // URL must be added to MT5 Tools > Options > Expert Advisors > Allow WebRequest
   string url = "https://www.cftc.gov/dea/newcot/deafut.txt";
   
   char data[], result[];
   string headers;
   int res = WebRequest("GET", url, headers, 15000, data, result, headers);
   
   if(res < 200 || res > 299) {
      // Try alternative CFTC futures-only combined report
      url = "https://www.cftc.gov/dea/newcot/f_disagg.txt";
      res = WebRequest("GET", url, headers, 15000, data, result, headers);
      if(res < 200 || res > 299) {
         Print("COT WebRequest failed. HTTP: ", res, ". Add CFTC URL to MT5 allowed list.");
         return false;
      }
   }
   
   string response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   if(StringLen(response) < 100) return false;
   
   // Parse: search for Gold (088691 or "GOLD" in market name)
   // CFTC format is comma-separated with many fields
   // We need: Market Name, Report Date, NonComm Long, NonComm Short, Comm Long, Comm Short
   
   string lines[];
   int lineCount = StringSplit(response, '\n', lines);
   
   bool foundGold = false;
   COTData parsed;
   parsed.isValid = false;
   
   for(int i = 1; i < lineCount; i++) { // Skip header
      string line = lines[i];
      // Check if line contains Gold futures
      if(StringFind(line, "GOLD") == -1 && StringFind(line, "088691") == -1) continue;
      // Must be COMEX Gold, not micro gold
      if(StringFind(line, "COMEX") == -1 && StringFind(line, "Comex") == -1) continue;
      
      string fields[];
      int fieldCount = StringSplit(line, ',', fields);
      if(fieldCount < 20) continue;
      
      // Standard CFTC disaggregated format field positions:
      // 0: Market_and_Exchange_Names
      // 2: As_of_Date_In_Form_YYMMDD or similar
      // 3-4: NonComm Long/Short (or positions vary by report)
      // Try to find the numeric fields for positions
      
      // For deafut.txt (legacy futures-only combined format):
      // Field 7: NonComm Long, 8: NonComm Short, 
      // Field 11: Comm Long, 12: Comm Short
      // Field 15: NonReportable Long, 16: NonReportable Short
      
      // Parse date from field 2
      string dateField = StringTrim(fields[2]);
      if(StringLen(dateField) > 0)
         parsed.reportDate = StringToTime(dateField);
      else
         parsed.reportDate = TimeCurrent();
      
      // Try standard field positions
      if(fieldCount > 16) {
         parsed.specLong = (long)StringToInteger(StringTrim(fields[7]));
         parsed.specShort = (long)StringToInteger(StringTrim(fields[8]));
         parsed.commLong = (long)StringToInteger(StringTrim(fields[11]));
         parsed.commShort = (long)StringToInteger(StringTrim(fields[12]));
         parsed.smallLong = (long)StringToInteger(StringTrim(fields[15]));
         parsed.smallShort = (long)StringToInteger(StringTrim(fields[16]));
      }
      
      // Validate: positions should be reasonable for Gold futures
      if(parsed.specLong > 1000 || parsed.specShort > 1000) {
         parsed.netSpec = (double)(parsed.specLong - parsed.specShort);
         parsed.netComm = (double)(parsed.commLong - parsed.commShort);
         parsed.isValid = true;
         parsed.source = "CFTC_WEB";
         parsed.specIndex = 50.0; // Will be calculated with history
         foundGold = true;
         break;
      }
   }
   
   if(foundGold && parsed.isValid) {
      g_cotData = parsed;
      
      // Save to CSV for future use / offline access
      int saveHandle = FileOpen("COT_Gold_Data.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON, ',');
      if(saveHandle != INVALID_HANDLE) {
         // Write header if new file
         if(FileSize(saveHandle) == 0) {
            FileWrite(saveHandle, "Date", "Spec_Long", "Spec_Short", "Comm_Long", "Comm_Short", "Small_Long", "Small_Short");
         }
         FileSeek(saveHandle, 0, SEEK_END);
         FileWrite(saveHandle, 
            TimeToString(parsed.reportDate, TIME_DATE),
            IntegerToString(parsed.specLong), IntegerToString(parsed.specShort),
            IntegerToString(parsed.commLong), IntegerToString(parsed.commShort),
            IntegerToString(parsed.smallLong), IntegerToString(parsed.smallShort));
         FileClose(saveHandle);
      }
      
      Print("COT from CFTC Web: Net Spec=", parsed.netSpec, " Net Comm=", parsed.netComm);
      return true;
   }
   
   return false;
}
void LoadCOTData() {
   // COT data is weekly - only reload once per day max
   if(g_cotInitialized && (TimeCurrent() - g_lastCOTLoad) < 86400) return;
   
   g_cotData.isValid = false;
   
   // Priority 1: Try local CSV (fastest, most reliable)
   bool loaded = LoadCOTFromCSV();
   
   // Priority 2: Try CFTC WebRequest (requires URL whitelisting in MT5)
   if(!loaded) {
      loaded = LoadCOTFromWeb();
   }
   
   if(!loaded) {
      g_cotData.isValid = false;
      g_cotData.source = "NONE";
      Print("COT data unavailable. Place COT_Gold_Data.csv in MQL5/Files/Common/ or add CFTC URL to MT5 allowed list.");
   }
   
   g_lastCOTLoad = TimeCurrent();
   g_cotInitialized = true;
}
// --- VSA-Based Institutional Analysis (Fallback / Complement) ---
void AnalyzeVSAInstitutional(double &vsaScore, double &vsaAccumulation) {
   vsaScore = 0;
   vsaAccumulation = 5.0;
   
   double h[], l[], c[], o[];
   long vol[];
   ArraySetAsSeries(h, true); ArraySetAsSeries(l, true);
   ArraySetAsSeries(c, true); ArraySetAsSeries(o, true);
   ArraySetAsSeries(vol, true);
   
   int barsNeeded = 100;
   if(CopyHigh(Symbol(), PERIOD_H1, 0, barsNeeded, h) < barsNeeded) return;
   CopyLow(Symbol(), PERIOD_H1, 0, barsNeeded, l);
   CopyClose(Symbol(), PERIOD_H1, 0, barsNeeded, c);
   CopyOpen(Symbol(), PERIOD_H1, 0, barsNeeded, o);
   CopyTickVolume(Symbol(), PERIOD_H1, 0, barsNeeded, vol);
   
   // Calculate average volume
   long avgVol = 0;
   for(int i = 1; i < barsNeeded; i++) avgVol += vol[i];
   avgVol /= (barsNeeded - 1);
   g_institutional.volumeRatio = (avgVol > 0) ? (double)vol[0] / avgVol : 1.0;
   
   // Detect big player activity: High volume + small body = institutional absorption
   // High volume + big body = institutional momentum
   double accScore = 0;
   int accCount = 0;
   
   for(int i = 0; i < 20; i++) {
      double body = MathAbs(c[i] - o[i]);
      double range = h[i] - l[i];
      if(range <= 0) continue;
      double bodyRatio = body / range;
      
      bool isHighVol = (vol[i] > avgVol * 1.3);
      
      if(isHighVol && bodyRatio < 0.3) {
         // High volume + small body = absorption (institutional)
         if(c[i] > o[i]) accScore += 1.5;  // Bullish absorption
         else accScore -= 1.5;              // Bearish absorption
         accCount++;
      } else if(isHighVol && bodyRatio > 0.7) {
         // High volume + big body = momentum
         if(c[i] > o[i]) accScore += 1.0;
         else accScore -= 1.0;
         accCount++;
      }
      
      // Wide range bar on high volume (potential institutional move)
      if(isHighVol && range > 0) {
         double closePosition = (c[i] - l[i]) / range;
         if(closePosition > 0.7) accScore += 0.5;  // Close near high = bullish
         else if(closePosition < 0.3) accScore -= 0.5; // Close near low = bearish
      }
   }
   
   // Normalize to -100 to +100 (output via reference parameters)
   if(accCount > 0) {
      vsaScore = MathMax(-100, MathMin(100, (accScore / accCount) * 50));
   }
   vsaAccumulation = MathMax(0, MathMin(10, 5 + accScore));
}
// --- Combined Analysis ---
void AnalyzeInstitutionalPositioning() {
   g_institutional.netPositioning = 0;
   g_institutional.bias = "NEUTRAL";
   g_institutional.volumeRatio = 1.0;
   g_institutional.bigPlayerBias = 0;
   g_institutional.accumulationScore = 5.0;
   g_institutional.phase = "NEUTRAL";
   g_institutional.cotDataAvailable = false;
   g_institutional.cotSource = "NONE";
   
   // 1. Load real CFTC COT data
   LoadCOTData();
   
   // 2. Always run VSA analysis (real-time complement)
   double vsaScore = 0, vsaAccum = 5.0;
   AnalyzeVSAInstitutional(vsaScore, vsaAccum);
   
   // 3. Combine COT + VSA
   if(g_cotData.isValid) {
      g_institutional.cotDataAvailable = true;
      g_institutional.cotSource = g_cotData.source;
      g_institutional.cotNetSpec = g_cotData.netSpec;
      g_institutional.cotNetComm = g_cotData.netComm;
      g_institutional.cotSpecIndex = g_cotData.specIndex;
      
      // COT-based positioning (70% weight) + VSA (30% weight)
      // Normalize COT net spec to -100..+100 scale
      double cotNormalized = 0;
      if(g_cotData.specIndex >= 0) {
         cotNormalized = (g_cotData.specIndex - 50.0) * 2.0; // 0-100 -> -100..+100
      }
      
      g_institutional.netPositioning = cotNormalized * 0.70 + vsaScore * 0.30;
      g_institutional.accumulationScore = MathMax(0, MathMin(10, 
         (g_cotData.specIndex / 10.0) * 0.70 + vsaAccum * 0.30));
      
      // COT-based bias determination
      // Spec Index > 75 = Speculators extremely long (contrarian bearish warning)
      // Spec Index < 25 = Speculators extremely short (contrarian bullish warning)
      // Spec Index 40-60 = Neutral
      if(g_cotData.specIndex > 75) {
         g_institutional.bias = "BULLISH";
         g_institutional.phase = "SPEC_EXTREME_LONG";
      } else if(g_cotData.specIndex > 60) {
         g_institutional.bias = "BULLISH";
         g_institutional.phase = "ACCUMULATING";
      } else if(g_cotData.specIndex < 25) {
         g_institutional.bias = "BEARISH";
         g_institutional.phase = "SPEC_EXTREME_SHORT";
      } else if(g_cotData.specIndex < 40) {
         g_institutional.bias = "BEARISH";
         g_institutional.phase = "DISTRIBUTING";
      } else {
         g_institutional.bias = "NEUTRAL";
         g_institutional.phase = "NEUTRAL";
      }
      
      // Commercial hedgers often move opposite to price direction
      // Net Commercial negative = hedgers are short = expecting higher prices (bullish)
      // Adjust bias based on commercial activity
      if(g_cotData.netComm < -50000 && g_institutional.bias != "BULLISH") {
         g_institutional.phase += "_COMM_BULLISH_SIGNAL";
      } else if(g_cotData.netComm > 50000 && g_institutional.bias != "BEARISH") {
         g_institutional.phase += "_COMM_BEARISH_SIGNAL";
      }
      
   } else {
      g_institutional.bias = "NEUTRAL";
      g_institutional.phase = "NEUTRAL";
      // Fallback: VSA-only analysis
      g_institutional.cotSource = "VSA_PROXY";
      g_institutional.cotDataAvailable = false;
      g_institutional.netPositioning = vsaScore;
      g_institutional.accumulationScore = vsaAccum;
      
      if(g_institutional.netPositioning > 30) {
         g_institutional.bias = "BULLISH";
         g_institutional.phase = "ACCUMULATING";
      } else if(g_institutional.netPositioning < -30) {
         g_institutional.bias = "BEARISH";
         g_institutional.phase = "DISTRIBUTING";
      } else {
         g_institutional.bias = "NEUTRAL";
         g_institutional.phase = "NEUTRAL";
      }
   }
   
   g_institutional.netPositioning = MathMax(-100, MathMin(100, g_institutional.netPositioning));
   g_institutional.bigPlayerBias = g_institutional.netPositioning;
}
//====================================================================
//  SESSION PERFORMANCE TRACKING
//====================================================================
string GetCurrentSessionName() {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   int hour = dt.hour;
   
   if(hour >= 0 && hour < 7) return "ASIAN";
   if(hour >= 7 && hour < 13) return "LONDON";
   if(hour >= 13 && hour < 16) return "OVERLAP"; // London+NY overlap
   if(hour >= 16 && hour < 22) return "NEW_YORK";
   return "OFF_HOURS";
}
void TrackSessionSignal(bool isWin) {
   string session = GetCurrentSessionName();
   
   if(session == "ASIAN") {
      g_sessionPerf.asianSignals++;
      if(isWin) g_sessionPerf.asianWins++;
   } else if(session == "LONDON") {
      g_sessionPerf.londonSignals++;
      if(isWin) g_sessionPerf.londonWins++;
   } else if(session == "NEW_YORK") {
      g_sessionPerf.nySignals++;
      if(isWin) g_sessionPerf.nyWins++;
   } else if(session == "OVERLAP") {
      g_sessionPerf.overlapSignals++;
      if(isWin) g_sessionPerf.overlapWins++;
   }
   
   // Update best session
   double bestRate = 0;
   g_sessionPerf.bestSession = "UNKNOWN";
   
   if(g_sessionPerf.asianSignals >= 3) {
      double rate = ((double)g_sessionPerf.asianWins / g_sessionPerf.asianSignals) * 100;
      if(rate > bestRate) { bestRate = rate; g_sessionPerf.bestSession = "ASIAN"; }
   }
   if(g_sessionPerf.londonSignals >= 3) {
      double rate = ((double)g_sessionPerf.londonWins / g_sessionPerf.londonSignals) * 100;
      if(rate > bestRate) { bestRate = rate; g_sessionPerf.bestSession = "LONDON"; }
   }
   if(g_sessionPerf.nySignals >= 3) {
      double rate = ((double)g_sessionPerf.nyWins / g_sessionPerf.nySignals) * 100;
      if(rate > bestRate) { bestRate = rate; g_sessionPerf.bestSession = "NEW_YORK"; }
   }
   if(g_sessionPerf.overlapSignals >= 3) {
      double rate = ((double)g_sessionPerf.overlapWins / g_sessionPerf.overlapSignals) * 100;
      if(rate > bestRate) { bestRate = rate; g_sessionPerf.bestSession = "OVERLAP"; }
   }
   g_sessionPerf.bestSessionWinRate = bestRate;
}
//====================================================================
//  KILL SWITCH
//====================================================================
void CheckKillSwitch() {
   if(!InpKillSwitchEnabled) return;
   
   // Check cooldown
   if(g_killSwitch.isActive) {
      int elapsedMinutes = (int)((TimeCurrent() - g_killSwitch.activatedTime) / 60);
      if(elapsedMinutes >= InpKillSwitchCooldown) {
         g_killSwitch.isActive = false;
         g_killSwitch.reason = "";
         SendTelegram("✅ انتهت فترة التهدئة - Kill Switch معطل\nالنظام جاهز لاستئناف التداول");
      }
      return;
   }
   
   // Check consecutive losses
   if(g_killSwitch.consecutiveLosses >= InpMaxConsecutiveLoss) {
      ActivateKillSwitch("CONSECUTIVE_LOSSES", 
         IntegerToString(g_killSwitch.consecutiveLosses) + " خسائر متتالية");
      return;
   }
   
   // Check daily drawdown
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(g_dailyStartBalance > 0) {
      g_killSwitch.dailyDrawdown = ((g_dailyStartBalance - balance) / g_dailyStartBalance) * 100;
      if(g_killSwitch.dailyDrawdown >= InpMaxDrawdownPct) {
         ActivateKillSwitch("MAX_DRAWDOWN", 
            "تراجع يومي " + DoubleToString(g_killSwitch.dailyDrawdown, 1) + "%");
         return;
      }
   }
}
void ActivateKillSwitch(string reason, string details) {
   g_killSwitch.isActive = true;
   g_killSwitch.reason = reason;
   g_killSwitch.activatedTime = TimeCurrent();
   
   string msg = "🚨 KILL SWITCH مُفعّل!\n\n";
   msg += "السبب: " + details + "\n";
   msg += "فترة التهدئة: " + IntegerToString(InpKillSwitchCooldown) + " دقيقة\n";
   msg += "الخسائر المتتالية: " + IntegerToString(g_killSwitch.consecutiveLosses) + "\n";
   msg += "التراجع اليومي: " + DoubleToString(g_killSwitch.dailyDrawdown, 1) + "%\n\n";
   msg += "⏸️ التداول متوقف مؤقتاً - التحليل مستمر";
   SendTelegram(msg);
}
void RecordTradeResult(bool isWin) {
   if(isWin) {
      g_killSwitch.consecutiveLosses = 0;
   } else {
      g_killSwitch.consecutiveLosses++;
      if(g_killSwitch.consecutiveLosses > g_killSwitch.maxConsecutiveLosses)
         g_killSwitch.maxConsecutiveLosses = g_killSwitch.consecutiveLosses;
   }
   
   // Track session performance
   TrackSessionSignal(isWin);
}
//====================================================================
//  LAYER CONFLICT DETECTION
//====================================================================
int GradeToIndex(string grade) {
   if(grade == "A+++") return 0;
   if(grade == "A+")   return 1;
   if(grade == "A")    return 2;
   if(grade == "B")    return 3;
   if(grade == "C")    return 4;
   return 5; // D
}
string IndexToGrade(int idx) {
   switch(idx) {
      case 0: return "A+++";
      case 1: return "A+";
      case 2: return "A";
      case 3: return "B";
      case 4: return "C";
      default: return "D";
   }
}
void DetectLayerConflicts() {
   g_layerConflict.hasConflict = false;
   g_layerConflict.conflictCount = 0;
   g_layerConflict.severity = "NONE";
   g_layerConflict.confidenceReduction = 0;
   
   string signalDir = g_entrySignal.direction;
   int cIdx = 0;
   
   // 1. Macro vs Signal Direction
   if(signalDir == "BUY" && StringFind(g_macro.d1Bias, "BEARISH") != -1) {
      g_layerConflict.conflicts[cIdx++] = "CRITICAL: Signal BUY vs D1 Macro BEARISH";
      g_layerConflict.confidenceReduction += 15;
   } else if(signalDir == "SELL" && StringFind(g_macro.d1Bias, "BULLISH") != -1) {
      g_layerConflict.conflicts[cIdx++] = "CRITICAL: Signal SELL vs D1 Macro BULLISH";
      g_layerConflict.confidenceReduction += 15;
   }
   
   // 2. Macro D1 vs H4 conflict
   if(!g_macro.isAligned) {
      g_layerConflict.conflicts[cIdx++] = "HIGH: D1(" + g_macro.d1Bias + ") vs H4(" + g_macro.h4Bias + ") misaligned";
      g_layerConflict.confidenceReduction += 10;
   }
   
   // 3. MTF vs Signal
   if(InpUseMultiTF && g_mtf.allAligned) {
      bool mtfBullish = (StringFind(g_mtf.h4_bias, "BULLISH") != -1);
      bool mtfBearish = (StringFind(g_mtf.h4_bias, "BEARISH") != -1);
      if((signalDir == "BUY" && mtfBearish) || (signalDir == "SELL" && mtfBullish)) {
         g_layerConflict.conflicts[cIdx++] = "HIGH: Signal " + signalDir + " vs MTF all aligned opposite";
         g_layerConflict.confidenceReduction += 12;
      }
   }
   
   // 4. SMC vs Structure
   if(g_smartMoney.bias != "NEUTRAL" && g_structure.trend != "NEUTRAL") {
      bool smcBullish = (g_smartMoney.bias == "BULLISH");
      bool structBearish = (g_structure.trend == "BEARISH");
      if(smcBullish == structBearish) {
         g_layerConflict.conflicts[cIdx++] = "MEDIUM: SMC(" + g_smartMoney.bias + ") vs Structure(" + g_structure.trend + ")";
         g_layerConflict.confidenceReduction += 8;
      }
   }
   
   // 5. DXY vs Signal (Gold inversely correlated with USD)
   if(signalDir == "BUY" && g_dxy.trend == "BULLISH" && MathAbs(g_dxy.corrPercent) > 50) {
      g_layerConflict.conflicts[cIdx++] = "MEDIUM: BUY Gold vs DXY BULLISH (Corr: " + DoubleToString(g_dxy.corrPercent,1) + "%)";
      g_layerConflict.confidenceReduction += 7;
   } else if(signalDir == "SELL" && g_dxy.trend == "BEARISH" && MathAbs(g_dxy.corrPercent) > 50) {
      g_layerConflict.conflicts[cIdx++] = "MEDIUM: SELL Gold vs DXY BEARISH";
      g_layerConflict.confidenceReduction += 7;
   }
   
   // 6. Volume vs Signal
   if(g_volume.bias != "NEUTRAL") {
      if((signalDir == "BUY" && g_volume.bias == "BEARISH") || 
         (signalDir == "SELL" && g_volume.bias == "BULLISH")) {
         g_layerConflict.conflicts[cIdx++] = "LOW: Volume " + g_volume.bias + " vs Signal " + signalDir;
         g_layerConflict.confidenceReduction += 5;
      }
   }
   
   // 7. Pattern vs Signal
   if(g_pattern.confirmed && g_pattern.bias != "NEUTRAL") {
      if((signalDir == "BUY" && g_pattern.bias == "BEARISH") || 
         (signalDir == "SELL" && g_pattern.bias == "BULLISH")) {
         g_layerConflict.conflicts[cIdx++] = "LOW: Pattern " + g_pattern.name + "(" + g_pattern.bias + ") vs Signal";
         g_layerConflict.confidenceReduction += 4;
      }
   }
   
   // 8. Order Flow vs Signal
   if(InpUseOrderFlow && g_orderFlow.detected) {
      if((signalDir == "BUY" && g_orderFlow.type == "BEARISH_OFI") || 
         (signalDir == "SELL" && g_orderFlow.type == "BULLISH_OFI")) {
         g_layerConflict.conflicts[cIdx++] = "MEDIUM: OrderFlow " + g_orderFlow.type + " vs Signal " + signalDir;
         g_layerConflict.confidenceReduction += 8;
      }
   }
   
   // 9. Seasonality vs Signal
   if((signalDir == "BUY" && g_seasonal.monthlyBias == "BEARISH") || 
      (signalDir == "SELL" && g_seasonal.monthlyBias == "BULLISH")) {
      g_layerConflict.conflicts[cIdx++] = "LOW: Seasonality " + g_seasonal.monthlyBias + " vs Signal";
      g_layerConflict.confidenceReduction += 3;
   }
   
   // 10. Institutional Positioning vs Signal
   if(cIdx < 10 && ((signalDir == "BUY" && g_institutional.bias == "BEARISH" && g_institutional.netPositioning < -40) ||
      (signalDir == "SELL" && g_institutional.bias == "BULLISH" && g_institutional.netPositioning > 40))) {
      g_layerConflict.conflicts[cIdx++] = "HIGH: Institutional " + g_institutional.bias + " (Net:" + DoubleToString(g_institutional.netPositioning, 0) + ") vs Signal";
      g_layerConflict.confidenceReduction += 12;
   }
   
   g_layerConflict.conflictCount = cIdx;
   g_layerConflict.hasConflict = (cIdx > 0);
   g_layerConflict.confidenceReduction = MathMin(50, g_layerConflict.confidenceReduction);
   
   // Determine severity
   if(g_layerConflict.confidenceReduction >= 30)
      g_layerConflict.severity = "CRITICAL";
   else if(g_layerConflict.confidenceReduction >= 20)
      g_layerConflict.severity = "HIGH";
   else if(g_layerConflict.confidenceReduction >= 10)
      g_layerConflict.severity = "MEDIUM";
   else if(g_layerConflict.confidenceReduction > 0)
      g_layerConflict.severity = "LOW";
   else
      g_layerConflict.severity = "NONE";
}
string GetAccountStatus(double marginLevel, double profitPct, double balance) {
   if(PositionsTotal() == 0)
      return "NO_POSITIONS";
   if(marginLevel > 0 && marginLevel < 200)
      return "DANGER";
   if(profitPct < -2.0)
      return "STRESSED";
   if(profitPct > 5.0)
      return "OVERCONFIDENT";
   return "BALANCED";
}
string GetAccountStatusAR(string status) {
   if(status == "NO_POSITIONS") return "لا صفقات مفتوحة";
   if(status == "DANGER") return "خطر - هامش منخفض";
   if(status == "STRESSED") return "متوتر - خسارة عالية";
   if(status == "OVERCONFIDENT") return "ثقة مفرطة";
   return "متوازن";
}
//====================================================================
//  SEMI-AUTO EXECUTION
//====================================================================
bool IsGradeEligibleForSemiAuto(string grade) {
   if(InpSemiAutoMinGrade == "A+++") return (grade == "A+++");
   if(InpSemiAutoMinGrade == "A+")   return (grade == "A+++" || grade == "A+");
   if(InpSemiAutoMinGrade == "A")    return (grade == "A+++" || grade == "A+" || grade == "A");
   if(InpSemiAutoMinGrade == "B")    return (grade == "A+++" || grade == "A+" || grade == "A" || grade == "B");
   return false;
}
void CheckSemiAutoSignal() {
   if(!InpSemiAutoEnabled) return;
   if(!g_entrySignal.validated) return;
   if(!IsGradeEligibleForSemiAuto(g_entrySignal.grade)) return;
   
   // Don't create new pending if one is already active
   if(g_pendingOrder.isActive) return;
   
   g_pendingOrder.isActive = true;
   g_pendingOrder.isConfirmed = !InpSemiAutoRequireConfirm; // Auto-confirm if not required
   g_pendingOrder.direction = g_entrySignal.direction;
   g_pendingOrder.grade = g_entrySignal.grade;
   g_pendingOrder.score = g_entrySignal.totalScore;
   g_pendingOrder.entry = g_entrySignal.entry;
   g_pendingOrder.sl = g_entrySignal.sl;
   g_pendingOrder.tp1 = g_entrySignal.tp1;
   g_pendingOrder.tp2 = g_entrySignal.tp2;
   g_pendingOrder.tp3 = g_entrySignal.tp3;
   g_pendingOrder.lotSize = g_entrySignal.lotSize;
   g_pendingOrder.signalTime = TimeCurrent();
   g_pendingOrder.expiryTime = TimeCurrent() + 900; // 15 min expiry
   
   if(InpSemiAutoRequireConfirm) {
      string msg = "🔔 إشارة قوية - أمر معلق جاهز!\n\n";
      msg += "📊 الاتجاه: " + g_pendingOrder.direction + "\n";
      msg += "⭐ الدرجة: " + g_pendingOrder.grade + " (" + DoubleToString(g_pendingOrder.score, 1) + "/10)\n";
      msg += "💰 سعر الدخول: " + DoubleToString(g_pendingOrder.entry, 2) + "\n";
      msg += "🛑 وقف الخسارة: " + DoubleToString(g_pendingOrder.sl, 2) + "\n";
      msg += "🎯 TP1: " + DoubleToString(g_pendingOrder.tp1, 2) + "\n";
      msg += "🎯 TP2: " + DoubleToString(g_pendingOrder.tp2, 2) + "\n";
      msg += "🎯 TP3: " + DoubleToString(g_pendingOrder.tp3, 2) + "\n";
      msg += "📦 حجم اللوت: " + DoubleToString(g_pendingOrder.lotSize, 2) + "\n";
      msg += "⏰ ينتهي خلال: 15 دقيقة\n\n";
      if(g_layerConflict.hasConflict) {
         msg += "⚠️ تنبيه: يوجد " + IntegerToString(g_layerConflict.conflictCount) + " تعارض - الشدة: " + g_layerConflict.severity + "\n\n";
      }
      msg += "✅ أرسل /confirm للتنفيذ\n";
      msg += "❌ أرسل /cancel للإلغاء";
      SendTelegram(msg);
   } else {
      ExecutePendingOrder();
   }
}
void ExecutePendingOrder() {
   if(!g_pendingOrder.isActive) return;
   
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = Symbol();
   request.volume = g_pendingOrder.lotSize;
   request.type = (g_pendingOrder.direction == "BUY") ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = (g_pendingOrder.direction == "BUY") ? 
                   SymbolInfoDouble(Symbol(), SYMBOL_ASK) : 
                   SymbolInfoDouble(Symbol(), SYMBOL_BID);
   request.sl = g_pendingOrder.sl;
   request.tp = g_pendingOrder.tp1;
   request.deviation = 20;
   request.magic = 202604;
   request.comment = "NexusPro_" + g_pendingOrder.grade;
   request.type_filling = ORDER_FILLING_IOC;
   
   if(OrderSend(request, result)) {
      string msg = "✅ تم تنفيذ الأمر بنجاح!\n\n";
      msg += "🎫 تذكرة: " + IntegerToString(result.order) + "\n";
      msg += "📊 " + g_pendingOrder.direction + " @ " + DoubleToString(result.price, 2) + "\n";
      msg += "📦 حجم: " + DoubleToString(g_pendingOrder.lotSize, 2) + "\n";
      msg += "🛑 SL: " + DoubleToString(g_pendingOrder.sl, 2) + "\n";
      msg += "🎯 TP: " + DoubleToString(g_pendingOrder.tp1, 2);
      SendTelegram(msg);
      
      g_dailyTradeCount++;
      g_pendingOrder.isActive = false;
   } else {
      string msg = "❌ فشل تنفيذ الأمر!\n";
      msg += "السبب: " + IntegerToString(result.retcode) + " - " + result.comment;
      SendTelegram(msg);
      g_pendingOrder.isActive = false;
   }
}
void CheckPendingOrderExpiry() {
   if(!g_pendingOrder.isActive) return;
   if(TimeCurrent() > g_pendingOrder.expiryTime) {
      g_pendingOrder.isActive = false;
      SendTelegram("⏰ انتهت صلاحية الأمر المعلق (" + g_pendingOrder.grade + " " + g_pendingOrder.direction + ") - لم يتم التأكيد");
   }
}
//====================================================================
//  HISTORICAL BACKTESTING
//====================================================================
// Helper: Get session name from GMT hour (for backtest)
string GetSessionFromHour(int gmtHour) {
   if(gmtHour >= 0 && gmtHour < 7) return "ASIAN";
   if(gmtHour >= 7 && gmtHour < 13) return "LONDON";
   if(gmtHour >= 13 && gmtHour < 16) return "OVERLAP";
   if(gmtHour >= 16 && gmtHour < 22) return "NEW_YORK";
   return "OFF_HOURS";
}
// Helper: Track backtest session results
void BtTrackSession(string session, bool isWin) {
   if(session == "ASIAN")       { g_btAsianSignals++;   if(isWin) g_btAsianWins++; }
   else if(session == "LONDON") { g_btLondonSignals++;  if(isWin) g_btLondonWins++; }
   else if(session == "OVERLAP"){ g_btOverlapSignals++; if(isWin) g_btOverlapWins++; }
   else if(session == "NEW_YORK"){ g_btNYSignals++;     if(isWin) g_btNYWins++; }
}
void RunHistoricalBacktest() {
   if(g_backtestCompleted) return;
   
   // === Load M15 data (primary timeframe) ===
   double high[], low[], open[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   
   int barsNeeded = 2000;
   if(CopyHigh(Symbol(), PERIOD_M15, 0, barsNeeded, high) < barsNeeded) return;
   CopyLow(Symbol(), PERIOD_M15, 0, barsNeeded, low);
   CopyOpen(Symbol(), PERIOD_M15, 0, barsNeeded, open);
   CopyClose(Symbol(), PERIOD_M15, 0, barsNeeded, close);
   CopyTickVolume(Symbol(), PERIOD_M15, 0, barsNeeded, volume);
   
   // === Load H1 data (macro/structure confirmation) ===
   double h1_high[], h1_low[], h1_close[], h1_open[];
   long h1_vol[];
   ArraySetAsSeries(h1_high, true); ArraySetAsSeries(h1_low, true);
   ArraySetAsSeries(h1_close, true); ArraySetAsSeries(h1_open, true);
   ArraySetAsSeries(h1_vol, true);
   int h1Bars = 500;
   bool hasH1 = (CopyHigh(Symbol(), PERIOD_H1, 0, h1Bars, h1_high) >= h1Bars);
   if(hasH1) {
      CopyLow(Symbol(), PERIOD_H1, 0, h1Bars, h1_low);
      CopyClose(Symbol(), PERIOD_H1, 0, h1Bars, h1_close);
      CopyOpen(Symbol(), PERIOD_H1, 0, h1Bars, h1_open);
      CopyTickVolume(Symbol(), PERIOD_H1, 0, h1Bars, h1_vol);
   }
   
   // === Load H4 data (macro trend) ===
   double h4_high[], h4_low[], h4_close[], h4_open[];
   ArraySetAsSeries(h4_high, true); ArraySetAsSeries(h4_low, true);
   ArraySetAsSeries(h4_close, true); ArraySetAsSeries(h4_open, true);
   int h4Bars = 200;
   bool hasH4 = (CopyHigh(Symbol(), PERIOD_H4, 0, h4Bars, h4_high) >= h4Bars);
   if(hasH4) {
      CopyLow(Symbol(), PERIOD_H4, 0, h4Bars, h4_low);
      CopyClose(Symbol(), PERIOD_H4, 0, h4Bars, h4_close);
      CopyOpen(Symbol(), PERIOD_H4, 0, h4Bars, h4_open);
   }
   
   // === Load D1 data (macro bias) ===
   double d1_close[];
   ArraySetAsSeries(d1_close, true);
   int d1Bars = 50;
   bool hasD1 = (CopyClose(Symbol(), PERIOD_D1, 0, d1Bars, d1_close) >= d1Bars);
   
   // === Load D1 EMA200 for macro filter ===
   double d1_ema200[];
   ArraySetAsSeries(d1_ema200, true);
   bool hasD1EMA = false;
   if(g_handle_ma_d1 != INVALID_HANDLE) {
      hasD1EMA = (CopyBuffer(g_handle_ma_d1, 0, 0, d1Bars, d1_ema200) >= d1Bars);
   }
   
   // === Load ATR buffers (M15 + H1 + H4) ===
   double atr_buf[], atr_h1_buf[], atr_h4_buf[];
   ArraySetAsSeries(atr_buf, true); ArraySetAsSeries(atr_h1_buf, true); ArraySetAsSeries(atr_h4_buf, true);
   if(CopyBuffer(g_handle_atr, 0, 0, barsNeeded, atr_buf) < barsNeeded) return;
   bool hasATRH1 = (g_handle_atr_h1 != INVALID_HANDLE && CopyBuffer(g_handle_atr_h1, 0, 0, h1Bars, atr_h1_buf) >= h1Bars);
   bool hasATRH4 = (g_handle_atr_h4 != INVALID_HANDLE && CopyBuffer(g_handle_atr_h4, 0, 0, h4Bars, atr_h4_buf) >= h4Bars);
   
   // === Load RSI for divergence ===
   double rsi_buf[];
   ArraySetAsSeries(rsi_buf, true);
   bool hasRSI = (g_handle_rsi != INVALID_HANDLE && CopyBuffer(g_handle_rsi, 0, 0, barsNeeded, rsi_buf) >= barsNeeded);
   
   // === Load bar times for session detection ===
   datetime barTimes[];
   ArraySetAsSeries(barTimes, true);
   bool hasTimes = (CopyTime(Symbol(), PERIOD_M15, 0, barsNeeded, barTimes) >= barsNeeded);
   
   // === Spread simulation (average Gold spread ~2.5 pips) ===
   double simSpread = FromPips(2.5);
   
   // === Reset counters ===
   g_backtestTotalSignals = 0;
   g_backtestWins = 0;
   g_backtestLosses = 0;
   g_backtestTP1Hits = 0;
   g_backtestTP2Hits = 0;
   g_backtestTP3Hits = 0;
   g_btAsianSignals = 0; g_btAsianWins = 0;
   g_btLondonSignals = 0; g_btLondonWins = 0;
   g_btOverlapSignals = 0; g_btOverlapWins = 0;
   g_btNYSignals = 0; g_btNYWins = 0;
   double totalRR = 0;
   int totalLayersConfirmed = 0;
   int consecutiveLosses = 0;
   int maxConsecLoss = 0;
   
   for(int i = 200; i < barsNeeded - 50; i++) {
      double bullWeight = 0, bearWeight = 0;
      int bullLayers = 0, bearLayers = 0;
      
      // ================================================================
      // LAYER 1: Macro Bias (D1/H4 trend via EMA200) - Weight: 1.5
      // ================================================================
      bool macroBull = false, macroBear = false;
      if(hasD1EMA && hasD1) {
         int d1_idx = i / 96; // M15 -> D1 approximation
         if(d1_idx >= 0 && d1_idx < d1Bars) {
            macroBull = (d1_close[d1_idx] > d1_ema200[d1_idx]);
            macroBear = (d1_close[d1_idx] < d1_ema200[d1_idx]);
         }
      }
      if(hasH4) {
         int h4_idx = i / 16; // M15 -> H4
         if(h4_idx > 1 && h4_idx < h4Bars - 1) {
            bool h4Bull = (h4_close[h4_idx] > h4_close[h4_idx+1]);
            bool h4Bear = (h4_close[h4_idx] < h4_close[h4_idx+1]);
            if(macroBull && h4Bull) { bullWeight += 1.5; bullLayers++; }
            if(macroBear && h4Bear) { bearWeight += 1.5; bearLayers++; }
         }
      }
      
      // ================================================================
      // LAYER 2: Market Structure (BOS/CHoCH) - Weight: 2.0
      // ================================================================
      bool structureBull = (low[i] > low[i+5] && high[i] > high[i+5]);
      bool structureBear = (high[i] < high[i+5] && low[i] < low[i+5]);
      
      double prevSwingHigh = high[i+5];
      double prevSwingLow = low[i+5];
      for(int k = i+6; k < i+20; k++) {
         if(high[k] > prevSwingHigh) prevSwingHigh = high[k];
         if(low[k] < prevSwingLow) prevSwingLow = low[k];
      }
      bool bullBOS = (close[i] > prevSwingHigh);
      bool bearBOS = (close[i] < prevSwingLow);
      
      if(structureBull || bullBOS) { bullWeight += 2.0; bullLayers++; }
      if(structureBear || bearBOS) { bearWeight += 2.0; bearLayers++; }
      
      // ================================================================
      // LAYER 3: SMC (Order Block + Liquidity Sweep) - Weight: 2.5
      // ================================================================
      long avgVol = 0;
      for(int v = i+2; v < i+22; v++) avgVol += volume[v];
      avgVol /= 20;
      bool volSpike = (avgVol > 0 && volume[i+1] > avgVol * 1.3);
      
      // Order Block detection
      bool bullOB = false, bearOB = false;
      for(int ob = i+1; ob < i+10; ob++) {
         if(close[ob] < open[ob]) {
            bool bosAfter = false;
            for(int af = ob-1; af >= i; af--) {
               if(close[af] > high[ob]) { bosAfter = true; break; }
            }
            if(bosAfter && volume[ob] > avgVol) { bullOB = true; break; }
         }
      }
      for(int ob = i+1; ob < i+10; ob++) {
         if(close[ob] > open[ob]) {
            bool bosAfter = false;
            for(int af = ob-1; af >= i; af--) {
               if(close[af] < low[ob]) { bosAfter = true; break; }
            }
            if(bosAfter && volume[ob] > avgVol) { bearOB = true; break; }
         }
      }
      
      // Liquidity Sweep detection
      bool bullSweep = false, bearSweep = false;
      for(int s = i; s < i+3; s++) {
         if(low[s] < prevSwingLow && close[s] > prevSwingLow && close[s] > open[s]) {
            bullSweep = true; break;
         }
         if(high[s] > prevSwingHigh && close[s] < prevSwingHigh && close[s] < open[s]) {
            bearSweep = true; break;
         }
      }
      
      if(bullOB || bullSweep) { bullWeight += 2.5; bullLayers++; }
      if(bearOB || bearSweep) { bearWeight += 2.5; bearLayers++; }
      
      // ================================================================
      // LAYER 4: Fibonacci OTE Zone - Weight: 1.2
      // ================================================================
      double swingH = high[ArrayMaximum(high, i, 30)];
      double swingL = low[ArrayMinimum(low, i, 30)];
      double fibRange = swingH - swingL;
      if(fibRange > 0) {
         double fib618 = swingH - fibRange * 0.618;
         double fib786 = swingH - fibRange * 0.786;
         double fib382 = swingH - fibRange * 0.382;
         double fib236 = swingH - fibRange * 0.236;
         double cp = close[i];
         if(cp >= fib786 && cp <= fib618 && structureBull) { bullWeight += 1.2; bullLayers++; }
         if(cp >= fib236 && cp <= fib382 && structureBear) { bearWeight += 1.2; bearLayers++; }
      }
      
      // ================================================================
      // LAYER 5: Wyckoff (Spring/Upthrust/SOS/VSA) - Weight: 1.3
      // ================================================================
      bool hasSpring = (low[i+1] < prevSwingLow && close[i+1] > open[i+1] && volSpike);
      bool hasUpthrust = (high[i+1] > prevSwingHigh && close[i+1] < open[i+1] && volSpike);
      
      bool hasSOS = false, hasSOW = false;
      for(int w = i; w < i+3; w++) {
         double bodyW = close[w] - open[w];
         double rangeW = high[w] - low[w];
         if(rangeW > 0 && bodyW > rangeW * 0.6 && volume[w] > avgVol * 1.5 && close[w] > open[w]) {
            if(close[w] > prevSwingHigh) { hasSOS = true; break; }
         }
         if(rangeW > 0 && (open[w] - close[w]) > rangeW * 0.6 && volume[w] > avgVol * 1.5 && close[w] < open[w]) {
            if(close[w] < prevSwingLow) { hasSOW = true; break; }
         }
      }
      
      bool vsaBullish = false, vsaBearish = false;
      if(volSpike) {
         double bodyRatio = MathAbs(close[i] - open[i]) / MathMax(0.0001, high[i] - low[i]);
         if(bodyRatio < 0.3 && close[i] > open[i]) vsaBullish = true;
         if(bodyRatio < 0.3 && close[i] < open[i]) vsaBearish = true;
      }
      
      if(hasSpring || hasSOS || vsaBullish) { bullWeight += 1.3; bullLayers++; }
      if(hasUpthrust || hasSOW || vsaBearish) { bearWeight += 1.3; bearLayers++; }
      
      // ================================================================
      // LAYER 6: Pattern (Engulfing + Pin Bar) - Weight: 1.0
      // ================================================================
      bool bullEngulf = (close[i+1] > open[i+1]) && 
                        ((close[i+1] - open[i+1]) > (high[i+1] - low[i+1]) * 0.5);
      bool bearEngulf = (close[i+1] < open[i+1]) && 
                        ((open[i+1] - close[i+1]) > (high[i+1] - low[i+1]) * 0.5);
      bool bullPin = false, bearPin = false;
      double bodyI = MathAbs(close[i] - open[i]);
      double rangeI = high[i] - low[i];
      if(rangeI > 0) {
         double lowerWick = MathMin(open[i], close[i]) - low[i];
         double upperWick = high[i] - MathMax(open[i], close[i]);
         if(lowerWick > rangeI * 0.6 && bodyI < rangeI * 0.3) bullPin = true;
         if(upperWick > rangeI * 0.6 && bodyI < rangeI * 0.3) bearPin = true;
      }
      
      if((bullEngulf && structureBull) || bullPin) { bullWeight += 1.0; bullLayers++; }
      if((bearEngulf && structureBear) || bearPin) { bearWeight += 1.0; bearLayers++; }
      
      // ================================================================
      // LAYER 7: RSI Divergence - Weight: 1.1
      // ================================================================
      if(hasRSI && i + 20 < barsNeeded) {
         if(low[i] < low[i+10] && rsi_buf[i] > rsi_buf[i+10] && rsi_buf[i] < 40) {
            bullWeight += 1.1; bullLayers++;
         }
         if(high[i] > high[i+10] && rsi_buf[i] < rsi_buf[i+10] && rsi_buf[i] > 60) {
            bearWeight += 1.1; bearLayers++;
         }
      }
      
      // ================================================================
      // LAYER 8: Volume & VWAP proxy - Weight: 0.8
      // ================================================================
      if(volSpike && close[i] > open[i]) { bullWeight += 0.8; bullLayers++; }
      if(volSpike && close[i] < open[i]) { bearWeight += 0.8; bearLayers++; }
      
      // ================================================================
      // LAYER 9: Session Killzone - Weight: 0.7
      // ================================================================
      string barSession = "OFF_HOURS";
      if(hasTimes) {
         MqlDateTime dt;
         TimeToStruct(barTimes[i], dt);
         barSession = GetSessionFromHour(dt.hour);
      }
      bool isKillzone = (barSession == "LONDON" || barSession == "OVERLAP" || barSession == "NEW_YORK");
      if(isKillzone) {
         if(bullWeight > bearWeight) { bullWeight += 0.7; bullLayers++; }
         if(bearWeight > bullWeight) { bearWeight += 0.7; bearLayers++; }
      }
      
      // ================================================================
      // LAYER 10: Seasonality (simplified) - Weight: 0.5
      // ================================================================
      if(hasTimes) {
         MqlDateTime sdt;
         TimeToStruct(barTimes[i], sdt);
         bool bullMonth = (sdt.mon==1||sdt.mon==2||sdt.mon==8||sdt.mon==9||sdt.mon==11);
         bool bearMonth = (sdt.mon==3||sdt.mon==6||sdt.mon==10);
         if(bullMonth) { bullWeight += 0.5; bullLayers++; }
         if(bearMonth) { bearWeight += 0.5; bearLayers++; }
      }
      
      // ================================================================
      // LAYER 11: H1 Multi-TF Confirmation - Weight: 1.0
      // ================================================================
      if(hasH1) {
         int h1_idx = i / 4;
         if(h1_idx > 1 && h1_idx < h1Bars - 5) {
            bool h1Bull = (h1_close[h1_idx] > h1_open[h1_idx] && h1_close[h1_idx] > h1_close[h1_idx+1]);
            bool h1Bear = (h1_close[h1_idx] < h1_open[h1_idx] && h1_close[h1_idx] < h1_close[h1_idx+1]);
            if(h1Bull && structureBull) { bullWeight += 1.0; bullLayers++; }
            if(h1Bear && structureBear) { bearWeight += 1.0; bearLayers++; }
         }
      }
      
      // ================================================================
      // LAYER 12: Order Flow Imbalance (Volume Pressure) - Weight: 0.8
      // ================================================================
      double buyPressure = 0, sellPressure = 0;
      for(int of = i; of < i+10; of++) {
         if(close[of] > open[of]) buyPressure += (close[of] - open[of]) * volume[of];
         else sellPressure += (open[of] - close[of]) * volume[of];
      }
      double ofiRatio = (sellPressure > 0) ? buyPressure / sellPressure : 
                        (buyPressure > 0 ? 10.0 : 1.0);
      if(ofiRatio > 2.0) { bullWeight += 0.8; bullLayers++; }
      if(ofiRatio < 0.5) { bearWeight += 0.8; bearLayers++; }
      
      // ================================================================
      // LAYER 13: Institutional Absorption (Volume Analysis) - Weight: 0.6
      // ================================================================
      int absCount = 0;
      double absScore = 0;
      for(int ia = i; ia < i+10; ia++) {
         double iaBody = MathAbs(close[ia] - open[ia]);
         double iaRange = high[ia] - low[ia];
         if(iaRange > 0 && volume[ia] > avgVol * 1.3 && (iaBody / iaRange) < 0.3) {
            if(close[ia] > open[ia]) absScore += 1;
            else absScore -= 1;
            absCount++;
         }
      }
      if(absCount >= 2 && absScore > 0) { bullWeight += 0.6; bullLayers++; }
      if(absCount >= 2 && absScore < 0) { bearWeight += 0.6; bearLayers++; }
      
      // ================================================================
      // MARKET REGIME FILTER (ATR-based)
      // ================================================================
      double atrCurrent = atr_buf[i];
      double avgATR = 0;
      for(int ai = i; ai < i+50 && ai < barsNeeded; ai++) avgATR += atr_buf[ai];
      avgATR /= 50;
      double atrRatio = (avgATR > 0) ? atrCurrent / avgATR : 1.0;
      
      double upMoves = 0, downMoves = 0;
      for(int ti = i; ti < i+20; ti++) {
         if(close[ti] > close[ti+1]) upMoves++;
         else downMoves++;
      }
      double trendStr = MathAbs(upMoves - downMoves) / 20.0;
      bool isVolatileChop = (atrRatio > 1.3 && trendStr < 0.4);
      
      // ================================================================
      // SCORING & SIGNAL GENERATION
      // ================================================================
      double totalPossibleWeight = 1.5+2.0+2.5+1.2+1.3+1.0+1.1+0.8+0.7+0.5+1.0+0.8+0.6; // = 14.0
      double score = 0;
      int confirmedLayers = 0;
      string direction = "";
      
      if(bullWeight > bearWeight) {
         score = (bullWeight / totalPossibleWeight) * 10.0;
         confirmedLayers = bullLayers;
         direction = "BUY";
      } else if(bearWeight > bullWeight) {
         score = (bearWeight / totalPossibleWeight) * 10.0;
         confirmedLayers = bearLayers;
         direction = "SELL";
      } else continue;
      
      score = MathMin(10.0, MathMax(0.0, score));
      
      // Apply filters (matching live system logic)
      if(direction == "BUY" && macroBear && InpRequireMacroVeto) continue;
      if(direction == "SELL" && macroBull && InpRequireMacroVeto) continue;
      
      if(isVolatileChop && score < 8.5) continue;
      
      if((barSession == "OFF_HOURS" || barSession == "ASIAN") && score < 8.0) continue;
      
      if(score < InpSignalThreshold) continue;
      if(confirmedLayers < InpMinConfirmLayers) continue;
      
      // Kill Switch simulation (consecutive losses)
      if(consecutiveLosses >= InpMaxConsecutiveLoss) {
         consecutiveLosses = 0; // Reset after cooldown
         i += 20;
         continue;
      }
      
      // ================================================================
      // ENTRY LEVELS (Multi-TF Adaptive ATR)
      // ================================================================
      double atr = atr_buf[i];
      if(atr <= 0) continue;
      
      // Blend ATR from multiple timeframes
      double adaptiveATR = atr;
      if(hasATRH1 && hasATRH4) {
         int h1i = i / 4;
         int h4i = i / 16;
         double aH1 = (h1i < h1Bars) ? atr_h1_buf[h1i] : atr;
         double aH4 = (h4i < h4Bars) ? atr_h4_buf[h4i] : atr;
         if(isVolatileChop)
            adaptiveATR = (atr * 0.3 + aH1 * 0.4 + aH4 * 0.3);
         else if(atrRatio > 1.3 && trendStr > 0.6) // Strong trend
            adaptiveATR = (atr * 0.5 + aH1 * 0.3 + aH4 * 0.2);
         else
            adaptiveATR = (atr * 0.4 + aH1 * 0.35 + aH4 * 0.25);
      }
      
      // Grade-based SL multiplier
      double slMult = 2.0;
      if(score >= 9.0 && confirmedLayers >= 7) slMult = 1.2;      // A+++
      else if(score >= 8.5 && confirmedLayers >= 6) slMult = 1.4;  // A+
      else if(score >= 7.5) slMult = 1.6;                          // A
      else if(score >= 6.5) slMult = 1.8;                          // B
      
      double entry = close[i];
      // Add spread cost to entry
      if(direction == "BUY") entry += simSpread;
      
      double slDist = adaptiveATR * slMult;
      double sl, tp1, tp2, tp3;
      
      if(direction == "BUY") {
         sl = entry - slDist;
         tp1 = entry + slDist * 1.5;
         tp2 = entry + slDist * 2.5;
         tp3 = entry + slDist * 3.5;
      } else {
         sl = entry + slDist;
         tp1 = entry - slDist * 1.5;
         tp2 = entry - slDist * 2.5;
         tp3 = entry - slDist * 3.5;
      }
      
      // ================================================================
      // SIMULATE TRADE OUTCOME (TP1/TP2/TP3 + SL with spread)
      // ================================================================
      bool hitTP1 = false, hitTP2 = false, hitTP3 = false, hitSL = false;
      
      for(int j = i - 1; j >= MathMax(0, i - 80); j--) {
         if(direction == "BUY") {
            if(low[j] <= sl)  { hitSL = true; break; }
            if(high[j] >= tp1 && !hitTP1) hitTP1 = true;
            if(high[j] >= tp2 && !hitTP2) hitTP2 = true;
            if(high[j] >= tp3) { hitTP3 = true; break; }
         } else {
            if(high[j] >= sl) { hitSL = true; break; }
            if(low[j] <= tp1 && !hitTP1) hitTP1 = true;
            if(low[j] <= tp2 && !hitTP2) hitTP2 = true;
            if(low[j] <= tp3) { hitTP3 = true; break; }
         }
      }
      
      // Calculate P&L
      g_backtestTotalSignals++;
      totalLayersConfirmed += confirmedLayers;
      bool isWin = false;
      
      if(hitTP3) {
         // Full target hit: average of partial closes at TP1, TP2, TP3
         double rr = (1.5 * 0.33 + 2.5 * 0.33 + 3.5 * 0.34);
         totalRR += rr;
         g_backtestWins++;
         g_backtestTP1Hits++;
         g_backtestTP2Hits++;
         g_backtestTP3Hits++;
         isWin = true;
      } else if(hitTP2) {
         double rr = (1.5 * 0.33 + 2.5 * 0.33 + 0.5 * 0.34); // TP3 partial at breakeven
         totalRR += rr;
         g_backtestWins++;
         g_backtestTP1Hits++;
         g_backtestTP2Hits++;
         isWin = true;
      } else if(hitTP1 && hitSL) {
         // TP1 hit first then SL on remainder
         double rr = (1.5 * 0.33 - 1.0 * 0.67);
         totalRR += rr;
         g_backtestTP1Hits++;
         if(rr > 0) { g_backtestWins++; isWin = true; }
         else { g_backtestLosses++; }
      } else if(hitSL) {
         totalRR -= 1.0;
         g_backtestLosses++;
      } else if(hitTP1) {
         totalRR += 0.5; // Partial profit
         g_backtestTP1Hits++;
         g_backtestWins++;
         isWin = true;
      }
      // else: no target hit within 80 bars (expired)
      
      // Track consecutive losses for Kill Switch simulation
      if(hitSL && !hitTP1) {
         consecutiveLosses++;
         if(consecutiveLosses > maxConsecLoss) maxConsecLoss = consecutiveLosses;
      } else if(isWin) {
         consecutiveLosses = 0;
      }
      
      // Track session performance
      BtTrackSession(barSession, isWin);
      
      i += 5; // Skip forward to avoid overlapping signals
   }
   
   // === Calculate final statistics ===
   if(g_backtestTotalSignals > 0) {
      g_backtestWinRate = ((double)g_backtestWins / g_backtestTotalSignals) * 100.0;
      int completedSignals = g_backtestWins + g_backtestLosses;
      g_backtestAvgRR = (completedSignals > 0) ? totalRR / completedSignals : 0;
      g_backtestLayersUsed = (int)MathRound((double)totalLayersConfirmed / g_backtestTotalSignals);
      g_backtestAvgSpread = ToPips(simSpread);
   }
   
   // Best session calculation
   g_btBestSession = "UNKNOWN";
   g_btBestSessionRate = 0;
   if(g_btAsianSignals >= 3) {
      double r = ((double)g_btAsianWins / g_btAsianSignals) * 100;
      if(r > g_btBestSessionRate) { g_btBestSessionRate = r; g_btBestSession = "ASIAN"; }
   }
   if(g_btLondonSignals >= 3) {
      double r = ((double)g_btLondonWins / g_btLondonSignals) * 100;
      if(r > g_btBestSessionRate) { g_btBestSessionRate = r; g_btBestSession = "LONDON"; }
   }
   if(g_btOverlapSignals >= 3) {
      double r = ((double)g_btOverlapWins / g_btOverlapSignals) * 100;
      if(r > g_btBestSessionRate) { g_btBestSessionRate = r; g_btBestSession = "OVERLAP"; }
   }
   if(g_btNYSignals >= 3) {
      double r = ((double)g_btNYWins / g_btNYSignals) * 100;
      if(r > g_btBestSessionRate) { g_btBestSessionRate = r; g_btBestSession = "NEW_YORK"; }
   }
   
   g_backtestCompleted = true;
   Print("Historical Backtest v4.2 FULL Complete: ", g_backtestTotalSignals, " signals, ", 
         DoubleToString(g_backtestWinRate, 1), "% win rate, Avg RR: ", 
         DoubleToString(g_backtestAvgRR, 2), 
         ", Layers: 13 (full system), Spread: ", DoubleToString(g_backtestAvgSpread, 1), " pips",
         ", MaxConsecLoss: ", maxConsecLoss,
         ", BestSession: ", g_btBestSession);
}
//====================================================================
//  PERFORMANCE TRACKING (BACKTESTING)
//====================================================================
void TrackSignalPerformance() {
   if(!InpUseBacktesting) return;
   
   // Check if we have a validated signal to track
   if(!g_entrySignal.validated) return;
   
   // Check if we already tracked this signal
   if(ArraySize(g_performanceHistory) > 0) {
      SignalPerformance last = g_performanceHistory[ArraySize(g_performanceHistory)-1];
      if(TimeCurrent() - last.signalTime < 300) return; // Don't track same signal twice (5 min cooldown)
   }
   
   // Create new performance record
   int size = ArraySize(g_performanceHistory);
   ArrayResize(g_performanceHistory, size + 1);
   
   g_performanceHistory[size].signalTime = TimeCurrent();
   g_performanceHistory[size].direction = g_entrySignal.direction;
   g_performanceHistory[size].score = g_entrySignal.totalScore;
   g_performanceHistory[size].grade = g_entrySignal.grade;
   g_performanceHistory[size].entry = g_entrySignal.entry;
   g_performanceHistory[size].sl = g_entrySignal.sl;
   g_performanceHistory[size].tp1 = g_entrySignal.tp1;
   g_performanceHistory[size].tp2 = g_entrySignal.tp2;
   g_performanceHistory[size].wasExecuted = false;
   g_performanceHistory[size].hitSL = false;
   g_performanceHistory[size].hitTP1 = false;
   g_performanceHistory[size].hitTP2 = false;
   g_performanceHistory[size].maxFavorableExcursion = 0;
   g_performanceHistory[size].maxAdverseExcursion = 0;
   g_performanceHistory[size].finalPnL = 0;
   g_performanceHistory[size].barsToTarget = 0;
   
   g_totalSignals++;
   
   // Track by grade
   int gradeIdx = GradeToIndex(g_entrySignal.grade);
   if(gradeIdx >= 0 && gradeIdx < ArraySize(g_gradeStats)) {
      g_gradeStats[gradeIdx].totalSignals++;
      g_gradeStats[gradeIdx].pending++;
   }
}
void UpdateSignalPerformance() {
   if(!InpUseBacktesting || ArraySize(g_performanceHistory) == 0) return;
   
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   
   if(CopyHigh(Symbol(), Period(), 0, 100, high) < 100) return;
   CopyLow(Symbol(), Period(), 0, 100, low);
   
   // Update last 10 signals
   int start = MathMax(0, ArraySize(g_performanceHistory) - 10);
   for(int i = start; i < ArraySize(g_performanceHistory); i++) {
      if(g_performanceHistory[i].hitSL && g_performanceHistory[i].hitTP2) continue; // Already completed
      
      datetime signalTime = g_performanceHistory[i].signalTime;
      int signalBar = iBarShift(Symbol(), Period(), signalTime);
      if(signalBar < 0) continue;
      
      string dir = g_performanceHistory[i].direction;
      double entry = g_performanceHistory[i].entry;
      double sl = g_performanceHistory[i].sl;
      double tp1 = g_performanceHistory[i].tp1;
      double tp2 = g_performanceHistory[i].tp2;
      
      // Check if price reached entry
      for(int b = signalBar; b >= 0; b--) {
         if((dir == "BUY" && low[b] <= entry) || (dir == "SELL" && high[b] >= entry)) {
            g_performanceHistory[i].wasExecuted = true;
            break;
         }
      }
      
      if(!g_performanceHistory[i].wasExecuted) continue;
      
      // Track MFE/MAE
      for(int b = signalBar; b >= 0; b--) {
         if(dir == "BUY") {
            double profit = high[b] - entry;
            double loss = entry - low[b];
            if(profit > g_performanceHistory[i].maxFavorableExcursion)
               g_performanceHistory[i].maxFavorableExcursion = profit;
            if(loss > g_performanceHistory[i].maxAdverseExcursion)
               g_performanceHistory[i].maxAdverseExcursion = loss;
            
            // Check SL/TP
            if(low[b] <= sl && !g_performanceHistory[i].hitSL) {
               g_performanceHistory[i].hitSL = true;
               g_performanceHistory[i].finalPnL = -(entry - sl);
               g_performanceHistory[i].barsToTarget = signalBar - b;
               g_losingSignals++;
               RecordTradeResult(false);
            }
            if(high[b] >= tp1 && !g_performanceHistory[i].hitTP1) {
               g_performanceHistory[i].hitTP1 = true;
            }
            if(high[b] >= tp2 && !g_performanceHistory[i].hitTP2) {
               g_performanceHistory[i].hitTP2 = true;
               g_performanceHistory[i].finalPnL = tp2 - entry;
               g_performanceHistory[i].barsToTarget = signalBar - b;
               g_winningSignals++;
               RecordTradeResult(true);
            }
         } else {
            double profit = entry - low[b];
            double loss = high[b] - entry;
            if(profit > g_performanceHistory[i].maxFavorableExcursion)
               g_performanceHistory[i].maxFavorableExcursion = profit;
            if(loss > g_performanceHistory[i].maxAdverseExcursion)
               g_performanceHistory[i].maxAdverseExcursion = loss;
            
            if(high[b] >= sl && !g_performanceHistory[i].hitSL) {
               g_performanceHistory[i].hitSL = true;
               g_performanceHistory[i].finalPnL = -(sl - entry);
               g_performanceHistory[i].barsToTarget = signalBar - b;
               g_losingSignals++;
               RecordTradeResult(false);
            }
            if(low[b] <= tp1 && !g_performanceHistory[i].hitTP1) {
               g_performanceHistory[i].hitTP1 = true;
            }
            if(low[b] <= tp2 && !g_performanceHistory[i].hitTP2) {
               g_performanceHistory[i].hitTP2 = true;
               g_performanceHistory[i].finalPnL = entry - tp2;
               g_performanceHistory[i].barsToTarget = signalBar - b;
               g_winningSignals++;
               RecordTradeResult(true);
            }
         }
      }
   }
   
   // Calculate statistics
   if(g_totalSignals > 0) {
      g_winRate = (g_winningSignals / (double)g_totalSignals) * 100.0;
   }
   
   // Calculate avg R:R
   double totalRR = 0;
   int rrCount = 0;
   for(int i = 0; i < ArraySize(g_performanceHistory); i++) {
      if(g_performanceHistory[i].hitTP2 || g_performanceHistory[i].hitSL) {
         double slDist = MathAbs(g_performanceHistory[i].sl - g_performanceHistory[i].entry);
         if(slDist > 0) {
            double rr = MathAbs(g_performanceHistory[i].finalPnL) / slDist;
            totalRR += rr;
            rrCount++;
         }
      }
   }
   g_avgRR = (rrCount > 0) ? totalRR / rrCount : 0;
   
   // Update grade-level stats
   for(int g = 0; g < 6; g++) {
      g_gradeStats[g].wins = 0;
      g_gradeStats[g].losses = 0;
      g_gradeStats[g].pending = 0;
      g_gradeStats[g].avgPnL = 0;
      g_gradeStats[g].avgMFE = 0;
      g_gradeStats[g].avgMAE = 0;
      g_gradeStats[g].bestPnL = -999999;
      g_gradeStats[g].worstPnL = 999999;
   }
   for(int i = 0; i < ArraySize(g_performanceHistory); i++) {
      int gIdx = GradeToIndex(g_performanceHistory[i].grade);
      if(gIdx < 0 || gIdx >= 6) continue;
      
      if(g_performanceHistory[i].hitTP2) {
         g_gradeStats[gIdx].wins++;
         g_gradeStats[gIdx].avgPnL += g_performanceHistory[i].finalPnL;
         if(g_performanceHistory[i].finalPnL > g_gradeStats[gIdx].bestPnL)
            g_gradeStats[gIdx].bestPnL = g_performanceHistory[i].finalPnL;
      } else if(g_performanceHistory[i].hitSL) {
         g_gradeStats[gIdx].losses++;
         g_gradeStats[gIdx].avgPnL += g_performanceHistory[i].finalPnL;
         if(g_performanceHistory[i].finalPnL < g_gradeStats[gIdx].worstPnL)
            g_gradeStats[gIdx].worstPnL = g_performanceHistory[i].finalPnL;
      } else {
         g_gradeStats[gIdx].pending++;
      }
      g_gradeStats[gIdx].avgMFE += g_performanceHistory[i].maxFavorableExcursion;
      g_gradeStats[gIdx].avgMAE += g_performanceHistory[i].maxAdverseExcursion;
   }
   for(int g = 0; g < 6; g++) {
      int completed = g_gradeStats[g].wins + g_gradeStats[g].losses;
      if(completed > 0) {
         g_gradeStats[g].winRate = ((double)g_gradeStats[g].wins / completed) * 100.0;
         g_gradeStats[g].avgPnL /= completed;
      }
      if(g_gradeStats[g].totalSignals > 0) {
         g_gradeStats[g].avgMFE /= g_gradeStats[g].totalSignals;
         g_gradeStats[g].avgMAE /= g_gradeStats[g].totalSignals;
      }
      if(g_gradeStats[g].bestPnL < -999990) g_gradeStats[g].bestPnL = 0;
      if(g_gradeStats[g].worstPnL > 999990) g_gradeStats[g].worstPnL = 0;
   }
}
//====================================================================
//  ENHANCED REPORT BUILDER
//====================================================================
string BuildReportContent(bool manual) {
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double spread = (ask - bid) / GoldPip();
   string rpt = "";
   rpt += "[GOLD] STRATEGIC ADVISOR PROTOCOL v4.2 (Institutional Edition)\n";
   rpt += "=================================================================\n\n";
   rpt += "ROLE: You are the Chief Trading Strategist at a Tier-1 Investment Bank.\n";
   rpt += "You have 25+ years of experience in Gold (XAUUSD) institutional trading.\n";
   rpt += "Your analysis must be data-driven, precise, and actionable.\n\n";
   rpt += "=== MANDATORY ANALYSIS RULES ===\n";
   rpt += "1. Use Chain-of-Thought reasoning: analyze each layer sequentially\n";
   rpt += "2. Do NOT fabricate data - only use what is provided below\n";
   rpt += "3. Ignore any layer marked UNKNOWN, WAITING, or NONE\n";
   rpt += "4. SMC validity requires: Liquidity Sweep + BOS + Unmitigated OB\n";
   rpt += "5. [PREMIUM ENTRY] ONLY if ALL conditions met:\n";
   rpt += "   Score >= 8.5 + Macro aligned + Valid SMC + Price in OTE + No news + No critical conflicts\n";
   rpt += "6. Always check CONFLICT_ANALYSIS section - conflicts OVERRIDE score\n";
   rpt += "7. Check GRADE_PERFORMANCE for historical reliability of current grade\n";
   rpt += "8. If Account Status = DANGER or STRESSED: reduce position size or skip\n\n";
   rpt += "=== PHASE 1: Institutional Structural Analysis ===\n";
   rpt += "Analyze in this exact order:\n";
   rpt += "1. Was Liquidity Sweep recent? What direction? How far (distance in pips)?\n";
   rpt += "2. Did BOS/CHoCH occur AFTER Order Block formation?\n";
   rpt += "3. Is OB unmitigated? Check mitigation_percent and touch count\n";
   rpt += "4. Are OB strength ratings >= 7/10 for reliability?\n";
   rpt += "5. DXY Correlation: Is Gold decoupling from USD? (Normal: inverse correlation)\n";
   rpt += "6. Is price in Fibonacci OTE zone (0.618-0.786)? Discount or Premium?\n";
   rpt += "7. What is the Market Regime? Adjust strategy accordingly:\n";
   rpt += "   - STRONG_TREND: Follow trend, use wider SL, trail stops\n";
   rpt += "   - RANGING: Trade reversals at OB zones, tight targets\n";
   rpt += "   - VOLATILE_CHOP: AVOID unless Score >= 8.5\n";
   rpt += "   - WEAK_TREND: Confirm with multiple layers before entry\n\n";
   rpt += "=== PHASE 2: Multi-Path Execution Plan ===\n";
   rpt += "Provide BOTH paths with specific numbers:\n";
   rpt += "A) Scalping (M5/M15):\n";
   rpt += "   - Only if: Killzone active + RVol > 1.5x + OrderFlow aligned\n";
   rpt += "   - SL: 5-10 pips from entry, TP: 1:1.5 or 1:2 R:R\n";
   rpt += "   - Max 2 attempts per killzone\n";
   rpt += "B) Swing (H1/H4):\n";
   rpt += "   - Only if: Score >= 7.0 + Macro aligned + MTF confirmation >= 75%\n";
   rpt += "   - SL: Below/above structural level, TP1: 1:1.5, TP2: 1:2.5, TP3: 1:4\n";
   rpt += "   - Partial close at TP1, move SL to breakeven\n\n";
   rpt += "=== PHASE 3: Risk Engineering ===\n";
   rpt += "HARD RULES (never violate):\n";
   rpt += "- If Margin Level < 200% with open positions: DO NOT open new trades\n";
   rpt += "- If Today's Loss > 2%: STOP trading, wait for next session\n";
   rpt += "- If Daily Trades >= Max Daily Trades: STOP for the day\n";
   rpt += "- Position Sizing by Grade:\n";
   rpt += "  A+++/A+ (8.5+): Aggressive 1-2% risk\n";
   rpt += "  A/B (6.5-8.5): Conservative 0.5-1% risk\n";
   rpt += "  C/D (<6.5): NO ENTRY - analysis only\n\n";
   rpt += "=== PHASE 4: Conflict Assessment ===\n";
   rpt += "Review the CONFLICT_ANALYSIS section carefully:\n";
   rpt += "- CRITICAL conflicts: Signal is likely wrong - STAY AWAY\n";
   rpt += "- HIGH conflicts: Reduce position by 50%, use tighter SL\n";
   rpt += "- MEDIUM conflicts: Proceed with caution, conservative sizing\n";
   rpt += "- LOW conflicts: Acceptable, monitor closely\n";
   rpt += "- Each conflict reduces confidence. Total reduction shown as percentage\n\n";
   rpt += "=== PHASE 5: Red Flags (Auto-Reject if detected) ===\n";
   rpt += "- D1 vs H4 Macro conflict + Signal opposite to D1\n";
   rpt += "- Rising DXY + Gold BUY signal with high correlation\n";
   rpt += "- Gold/USD DECOUPLING detected (both moving same direction)\n";
   rpt += "- Sudden correlation drop > 30% (decoupling event)\n";
   rpt += "- High-impact news within 30 minutes\n";
   rpt += "- VOLATILE_CHOP regime with Score < 8.5\n";
   rpt += "- Kill Switch ACTIVE (consecutive losses or max drawdown)\n";
   rpt += "- Institutional positioning OPPOSING signal direction\n";
   rpt += "- Wyckoff UPTHRUST detected on BUY or SPRING on SELL\n";
   rpt += "- Account in DANGER or STRESSED status\n";
   rpt += "- OrderFlow opposing the signal direction\n";
   rpt += "- Low activity session (ASIAN/OFF_HOURS) with Score < 8.0\n\n";
   rpt += "=== PHASE 5B: New Data Sections to Analyze ===\n";
   rpt += "INSTITUTIONAL_POSITIONING: Check if smart money is accumulating or distributing\n";
   rpt += "  - NetPositioning > +50 = Strong institutional buying\n";
   rpt += "  - NetPositioning < -50 = Strong institutional selling\n";
   rpt += "  - If opposing signal direction: MAJOR RED FLAG\n";
   rpt += "WYCKOFF_ADVANCED: Check for Spring/Upthrust/SOS events\n";
   rpt += "  - Spring + Test = Very bullish (high probability)\n";
   rpt += "  - Upthrust = Very bearish (high probability)\n";
   rpt += "  - SOS = Trend continuation likely\n";
   rpt += "DXY_ENHANCED: Multi-pair proxy gives more reliable USD direction\n";
   rpt += "  - GoldDecoupling = YES means Gold/USD unusual behavior - CAUTION\n";
   rpt += "KILL_SWITCH: If Active=TRUE, system has detected consecutive losses\n";
   rpt += "  - Recommend WAIT regardless of signal quality\n";
   rpt += "SESSION_PERFORMANCE: Use to weight recommendation by session\n";
   rpt += "  - If current session has low win rate, recommend caution\n\n";
   rpt += "=== PHASE 6: Supreme Verdict ===\n";
   rpt += "Choose ONE verdict with detailed reasoning:\n";
   rpt += "[PREMIUM ENTRY] - Rare. Score >= 8.5 + All conditions aligned + No conflicts\n";
   rpt += "  -> Provide exact entry, SL, TP1, TP2, TP3 with pips distances\n";
   rpt += "[SPECULATIVE ENTRY] - Score 6.5-8.5, some conflicts tolerable\n";
   rpt += "  -> Provide entry with reduced lot and wider SL\n";
   rpt += "[STAY AWAY] - Score < 6.5, critical conflicts, or red flags\n";
   rpt += "  -> Explain what conditions would change your verdict\n";
   rpt += "[WAIT FOR CONFIRMATION] - Setup forming but trigger not yet fired\n";
   rpt += "  -> Explain what you are waiting for (e.g., BOS, OB retest, volume spike)\n\n";
   rpt += "=== PHASE 7: AI Confidence Score ===\n";
   rpt += "After your analysis, provide:\n";
   rpt += "1. AI_CONFIDENCE: 0-100% (your confidence in the recommendation)\n";
   rpt += "2. KEY_FACTOR: The single most important factor in your decision\n";
   rpt += "3. BIGGEST_RISK: The primary risk that could invalidate the trade\n";
   rpt += "4. INVALIDATION_LEVEL: Price level where the setup is invalid\n";
   rpt += "5. NEXT_CHECK: When to re-analyze (e.g., next killzone, after news)\n\n";
   rpt += "\n###########################################################\n";
   rpt += "#           STRUCTURED DATA FEED FOR AI ANALYSIS          #\n";
   rpt += "###########################################################\n\n";
   rpt += "[META]\n";
   rpt += "Timestamp: " + TimeToString(TimeCurrent()) + "\n";
   rpt += "Symbol: " + Symbol() + "\n";
   rpt += "Period: " + EnumToString(Period()) + "\n";
   rpt += "Bid: " + DoubleToString(bid, 2) + "\n";
   rpt += "Ask: " + DoubleToString(ask, 2) + "\n";
   rpt += "SpreadPips: " + DoubleToString(spread, 1) + "\n";
   rpt += "SpreadStatus: " + string(spread <= InpMaxSpreadPips ? "ACCEPTABLE" : "TOO_HIGH") + "\n";
   rpt += "ExportMode: " + string(manual ? "MANUAL" : "AUTO") + "\n";
   rpt += "SystemStatus: " + string(g_isRunning ? "RUNNING" : "PAUSED") + "\n";
   rpt += "NewsFilterStatus: " + g_newsStatus + "\n";
   rpt += "MarketRegime: " + EnumToString(g_currentRegime) + "\n\n";
   rpt += "[SIGNAL_RESULT]\n";
   rpt += "Direction: " + g_entrySignal.direction + "\n";
   rpt += "TotalScore: " + DoubleToString(g_entrySignal.totalScore, 2) + "\n";
   rpt += "Grade: " + g_entrySignal.grade + "\n";
   rpt += "Validated: " + string(g_entrySignal.validated ? "TRUE" : "FALSE") + "\n";
   rpt += "ConfirmedLayers: " + IntegerToString(g_entrySignal.confirmedLayers) + "\n";
   rpt += "RejectionReason: " + g_entrySignal.rejectionReason + "\n";
   rpt += "EntryPrice: " + DoubleToString(g_entrySignal.entry, 2) + "\n";
   rpt += "StopLoss: " + DoubleToString(g_entrySignal.sl, 2) + "\n";
   rpt += "TakeProfit1: " + DoubleToString(g_entrySignal.tp1, 2) + "\n";
   rpt += "TakeProfit2: " + DoubleToString(g_entrySignal.tp2, 2) + "\n";
   rpt += "TakeProfit3: " + DoubleToString(g_entrySignal.tp3, 2) + "\n";
   rpt += "RiskRewardRatio: " + DoubleToString(g_entrySignal.rr, 2) + "\n";
   rpt += "RecommendedLot: " + DoubleToString(g_entrySignal.lotSize, 2) + "\n\n";
   // Confluence Analysis
   rpt += "[CONFLUENCE_ANALYSIS]\n";
   int bullLayers = 0, bearLayers = 0, neutralLayers = 0;
   // Count confluence from all layers
   if(StringFind(g_macro.d1Bias, "BULLISH") != -1) bullLayers++; else if(StringFind(g_macro.d1Bias, "BEARISH") != -1) bearLayers++; else neutralLayers++;
   if(g_structure.trend == "BULLISH") bullLayers++; else if(g_structure.trend == "BEARISH") bearLayers++; else neutralLayers++;
   if(g_smartMoney.bias == "BULLISH") bullLayers++; else if(g_smartMoney.bias == "BEARISH") bearLayers++; else neutralLayers++;
   if(g_volume.bias == "BULLISH") bullLayers++; else if(g_volume.bias == "BEARISH") bearLayers++; else neutralLayers++;
   if(g_pattern.bias == "BULLISH") bullLayers++; else if(g_pattern.bias == "BEARISH") bearLayers++; else neutralLayers++;
   if(g_dxy.trend == "BEARISH") bullLayers++; else if(g_dxy.trend == "BULLISH") bearLayers++; else neutralLayers++; // DXY inverse
   if(g_seasonal.monthlyBias == "BULLISH") bullLayers++; else if(g_seasonal.monthlyBias == "BEARISH") bearLayers++; else neutralLayers++;
   if(InpUseOrderFlow && g_orderFlow.detected) {
      if(StringFind(g_orderFlow.type, "BULLISH") != -1) bullLayers++; else if(StringFind(g_orderFlow.type, "BEARISH") != -1) bearLayers++;
   }
   int totalActiveLayers = bullLayers + bearLayers;
   double confluenceScore = (totalActiveLayers > 0) ? (double)MathMax(bullLayers, bearLayers) / totalActiveLayers * 100.0 : 0;
   string confluenceDir = (bullLayers > bearLayers) ? "BULLISH" : (bearLayers > bullLayers) ? "BEARISH" : "NEUTRAL";
   rpt += "BullishLayers: " + IntegerToString(bullLayers) + "\n";
   rpt += "BearishLayers: " + IntegerToString(bearLayers) + "\n";
   rpt += "NeutralLayers: " + IntegerToString(neutralLayers) + "\n";
   rpt += "ConfluenceDirection: " + confluenceDir + "\n";
   rpt += "ConfluenceScore: " + DoubleToString(confluenceScore, 1) + "%\n";
   rpt += "ConfluenceVsSignal: " + string((confluenceDir == g_entrySignal.direction || g_entrySignal.direction == "NONE") ? "ALIGNED" : "MISALIGNED") + "\n";
   rpt += "SignalAlignedLayers: " + IntegerToString(g_entrySignal.direction == "BUY" ? bullLayers : bearLayers) + "/" + IntegerToString(totalActiveLayers) + "\n\n";
   rpt += "[DYNAMIC_WEIGHTS]\n";
   rpt += "Macro: " + DoubleToString(g_weights.macro, 2) + "\n";
   rpt += "Structure: " + DoubleToString(g_weights.structure, 2) + "\n";
   rpt += "SMC: " + DoubleToString(g_weights.smc, 2) + "\n";
   rpt += "Fibonacci: " + DoubleToString(g_weights.fib, 2) + "\n";
   rpt += "Wyckoff: " + DoubleToString(g_weights.wyckoff, 2) + "\n";
   rpt += "Volume: " + DoubleToString(g_weights.volume, 2) + "\n";
   rpt += "DXY: " + DoubleToString(g_weights.dxy, 2) + "\n\n";
   rpt += "[LAYER_0_MACRO]\n";
   rpt += "D1_Bias: " + g_macro.d1Bias + "\n";
   rpt += "H4_Bias: " + g_macro.h4Bias + "\n";
   rpt += "IsAligned: " + string(g_macro.isAligned ? "TRUE" : "FALSE") + "\n\n";
   rpt += "[LAYER_1_STRUCTURE]\n";
   rpt += "Trend: " + g_structure.trend + "\n";
   rpt += "StructuralHigh: " + DoubleToString(g_structure.structuralHigh, 2) + "\n";
   rpt += "StructuralLow: " + DoubleToString(g_structure.structuralLow, 2) + "\n";
   rpt += "HasBOS: " + string(g_structure.hasBOS ? "TRUE" : "FALSE") + "\n";
   rpt += "HasCHoCH: " + string(g_structure.hasCHoCH ? "TRUE" : "FALSE") + "\n\n";
   rpt += "[LAYER_2_SMART_MONEY_ENHANCED]\n";
   rpt += "Bias: " + g_smartMoney.bias + "\n";
   rpt += "BullOB_Valid: " + string(g_smartMoney.bullOB.isValid ? "TRUE" : "FALSE") + "\n";
   rpt += "BullOB_Strength: " + IntegerToString(g_smartMoney.bullOB.strength) + "/10\n";
   rpt += "BullOB_Mitigated: " + DoubleToString(g_smartMoney.bullOB.mitigation_percent, 1) + "%\n";
   rpt += "BullOB_TouchCount: " + IntegerToString(g_smartMoney.bullOB.touchCount) + "\n";
   rpt += "BearOB_Valid: " + string(g_smartMoney.bearOB.isValid ? "TRUE" : "FALSE") + "\n";
   rpt += "BearOB_Strength: " + IntegerToString(g_smartMoney.bearOB.strength) + "/10\n";
   rpt += "BearOB_Mitigated: " + DoubleToString(g_smartMoney.bearOB.mitigation_percent, 1) + "%\n";
   rpt += "BearOB_TouchCount: " + IntegerToString(g_smartMoney.bearOB.touchCount) + "\n";
   rpt += "LiquiditySweep_Detected: " + string(g_liquiditySweep.detected ? "TRUE" : "FALSE") + "\n";
   rpt += "LiquiditySweep_Direction: " + g_liquiditySweep.direction + "\n";
   rpt += "LiquiditySweep_Strength: " + IntegerToString(g_liquiditySweep.strength) + "/10\n";
   rpt += "LiquiditySweep_Distance: " + DoubleToString(g_liquiditySweep.sweepDistance, 1) + " pips\n\n";
   rpt += "[LAYER_3_FIBONACCI]\n";
   rpt += "Bias: " + g_fib.bias + "\n";
   rpt += "InOTE: " + string(g_fib.inOTE ? "TRUE" : "FALSE") + "\n";
   rpt += "InDiscount: " + string(g_fib.inDiscount ? "TRUE" : "FALSE") + "\n";
   rpt += "InPremium: " + string(g_fib.inPremium ? "TRUE" : "FALSE") + "\n";
   rpt += "OTE_High: " + DoubleToString(g_fib.oteHigh, 2) + "\n";
   rpt += "OTE_Low: " + DoubleToString(g_fib.oteLow, 2) + "\n\n";
   rpt += "[LAYER_4_WYCKOFF]\n";
   rpt += "Bias: " + g_wyckoff.bias + "\n";
   rpt += "Phase: " + g_wyckoff.phase + "\n";
   rpt += "VSASignal: " + g_wyckoff.vsaSignal + "\n";
   rpt += "Strength: " + DoubleToString(g_wyckoff.strength, 2) + "\n\n";
   rpt += "[LAYER_5_PATTERNS]\n";
   rpt += "PatternName: " + g_pattern.name + "\n";
   rpt += "Confirmed: " + string(g_pattern.confirmed ? "TRUE" : "FALSE") + "\n";
   rpt += "Bias: " + g_pattern.bias + "\n\n";
   rpt += "[LAYER_6_DIVERGENCE]\n";
   rpt += "Type: " + g_divergence.type + "\n";
   rpt += "Strength: " + DoubleToString(g_divergence.strength, 1) + "\n";
   rpt += "Confirmed: " + string(g_divergence.confirmed ? "TRUE" : "FALSE") + "\n\n";
   rpt += "[LAYER_7_VOLUME]\n";
   rpt += "Bias: " + g_volume.bias + "\n";
   rpt += "VWAP: " + DoubleToString(g_volume.vwap, 2) + "\n";
   rpt += "Position: " + g_volume.position + "\n";
   rpt += "VolSpike: " + string(g_volume.volSpike ? "TRUE" : "FALSE") + "\n";
   rpt += "RelativeVolume: " + DoubleToString(g_volume.relativeVolume, 2) + "x\n\n";
   rpt += "[LAYER_8_SESSION]\n";
   rpt += "CurrentSession: " + g_session.currentSession + "\n";
   rpt += "IsKillzone: " + string(g_session.isKillzone ? "TRUE" : "FALSE") + "\n";
   rpt += "KillzoneName: " + g_session.killzoneName + "\n\n";
   rpt += "[LAYER_9_DXY]\n";
   rpt += "CurrentValue: " + DoubleToString(g_dxy.current, 2) + "\n";
   rpt += "Trend: " + g_dxy.trend + "\n";
   rpt += "CorrPercent: " + DoubleToString(g_dxy.corrPercent, 1) + "%\n";
   rpt += "GoldImpact: " + g_dxy.goldImpact + "\n";
   rpt += "SilverTrend: " + g_dxy.silverTrend + "\n";
   rpt += "YieldsTrend: " + g_dxy.yieldsTrend + "\n";
   rpt += "RiskSentiment: " + g_dxy.sentiment + "\n\n";
   rpt += "[LAYER_10_SEASONALITY]\n";
   rpt += "MonthlyBias: " + g_seasonal.monthlyBias + "\n";
   rpt += "DayBias: " + g_seasonal.dayBias + "\n";
   rpt += "SeasonalScore: " + DoubleToString(g_seasonal.seasonalScore, 2) + "\n\n";
   if(InpUseMultiTF) {
      rpt += "[LAYER_11_MULTI_TIMEFRAME]\n";
      rpt += "M5_Bias: " + g_mtf.m5_bias + "\n";
      rpt += "M15_Bias: " + g_mtf.m15_bias + "\n";
      rpt += "H1_Bias: " + g_mtf.h1_bias + "\n";
      rpt += "H4_Bias: " + g_mtf.h4_bias + "\n";
      rpt += "AllAligned: " + string(g_mtf.allAligned ? "TRUE" : "FALSE") + "\n";
      rpt += "AlignedCount: " + IntegerToString(g_mtf.alignedCount) + "/4\n";
      rpt += "Confidence: " + DoubleToString(g_mtf.confidence, 1) + "%\n\n";
   }
   if(InpUseOrderFlow) {
      rpt += "[LAYER_12_ORDER_FLOW]\n";
      rpt += "Detected: " + string(g_orderFlow.detected ? "TRUE" : "FALSE") + "\n";
      rpt += "Type: " + g_orderFlow.type + "\n";
      rpt += "ImbalanceRatio: " + DoubleToString(g_orderFlow.imbalanceRatio, 2) + "\n";
      rpt += "ConsecutiveBars: " + IntegerToString(g_orderFlow.consecutiveBars) + "\n";
      rpt += "Strength: " + DoubleToString(g_orderFlow.strength, 1) + "/10\n\n";
   }
   if(InpUsePowerOf3) {
      rpt += "[LAYER_13_POWER_OF_3]\n";
      rpt += "Detected: " + string(g_powerOf3.detected ? "TRUE" : "FALSE") + "\n";
      rpt += "Phase: " + g_powerOf3.phase + "\n";
      rpt += "Bias: " + g_powerOf3.bias + "\n";
      rpt += "Strength: " + DoubleToString(g_powerOf3.strength, 1) + "/10\n";
      rpt += "ManipulationRange: " + DoubleToString(g_powerOf3.manipulationRange, 1) + "\n\n";
   }
   if(InpUsePsychology) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      double profitPct = (balance > 0) ? (g_dailyClosedProfit / balance) * 100 : 0;
      rpt += "[ACCOUNT_PSYCHOLOGY]\n";
      rpt += "Balance: " + DoubleToString(balance, 2) + "\n";
      rpt += "Equity: " + DoubleToString(equity, 2) + "\n";
      rpt += "ProfitToday: " + DoubleToString(g_dailyClosedProfit, 2) + "\n";
      rpt += "ProfitPercent: " + DoubleToString(profitPct, 2) + "%\n";
      rpt += "MarginLevel: " + DoubleToString(marginLevel, 2) + "%\n";
      rpt += "FreeMargin: " + DoubleToString(freeMargin, 2) + "\n";
      rpt += "OpenPositions: " + IntegerToString(PositionsTotal()) + "\n";
      rpt += "DailyTrades: " + IntegerToString(g_dailyTradeCount) + "/" + IntegerToString(InpMaxDailyTrades) + "\n";
      rpt += "AccountStatus: " + GetAccountStatus(marginLevel, profitPct, balance) + "\n";
      rpt += "\n";
   }
   // Conflict Analysis
   rpt += "[CONFLICT_ANALYSIS]\n";
   rpt += "HasConflicts: " + string(g_layerConflict.hasConflict ? "TRUE" : "FALSE") + "\n";
   rpt += "ConflictCount: " + IntegerToString(g_layerConflict.conflictCount) + "\n";
   rpt += "Severity: " + g_layerConflict.severity + "\n";
   rpt += "ConfidenceReduction: " + DoubleToString(g_layerConflict.confidenceReduction, 1) + "%\n";
   rpt += "AdjustedScore: " + DoubleToString(g_entrySignal.totalScore * (1.0 - g_layerConflict.confidenceReduction/100.0), 2) + "\n";
   for(int c = 0; c < g_layerConflict.conflictCount; c++) {
      rpt += "Conflict_" + IntegerToString(c+1) + ": " + g_layerConflict.conflicts[c] + "\n";
   }
   rpt += "\n";
   // Grade Performance
   if(InpUseBacktesting) {
      rpt += "[GRADE_PERFORMANCE]\n";
      for(int g = 0; g < 6; g++) {
         if(g_gradeStats[g].totalSignals > 0) {
            rpt += IndexToGrade(g) + ": Signals=" + IntegerToString(g_gradeStats[g].totalSignals) +
                   " Wins=" + IntegerToString(g_gradeStats[g].wins) +
                   " Losses=" + IntegerToString(g_gradeStats[g].losses) +
                   " WinRate=" + DoubleToString(g_gradeStats[g].winRate, 1) + "%" +
                   " AvgMFE=" + DoubleToString(ToPips(g_gradeStats[g].avgMFE), 1) + "pips" +
                   " AvgMAE=" + DoubleToString(ToPips(g_gradeStats[g].avgMAE), 1) + "pips\n";
         }
      }
      rpt += "CurrentGrade: " + g_entrySignal.grade + "\n";
      int curIdx = GradeToIndex(g_entrySignal.grade);
      if(curIdx >= 0 && curIdx < 6 && g_gradeStats[curIdx].totalSignals > 0) {
         rpt += "CurrentGradeWinRate: " + DoubleToString(g_gradeStats[curIdx].winRate, 1) + "%\n";
         rpt += "CurrentGradeReliability: ";
         if(g_gradeStats[curIdx].winRate >= 70) rpt += "HIGH\n";
         else if(g_gradeStats[curIdx].winRate >= 50) rpt += "MODERATE\n";
         else rpt += "LOW\n";
      } else {
         rpt += "CurrentGradeWinRate: INSUFFICIENT_DATA\n";
      }
      rpt += "\n";
   }
   // Performance Tracking
   if(InpUseBacktesting && g_totalSignals > 0) {
      rpt += "[PERFORMANCE_TRACKING]\n";
      rpt += "TotalSignals: " + IntegerToString(g_totalSignals) + "\n";
      rpt += "WinningSignals: " + IntegerToString(g_winningSignals) + "\n";
      rpt += "LosingSignals: " + IntegerToString(g_losingSignals) + "\n";
      rpt += "WinRate: " + DoubleToString(g_winRate, 2) + "%\n";
      rpt += "AvgRR: " + DoubleToString(g_avgRR, 2) + "\n\n";
   }
   // Historical Backtest
   if(g_backtestCompleted) {
      rpt += "[HISTORICAL_BACKTEST]\n";
      rpt += "Period: Last 2000 bars (M15)\n";
      rpt += "TotalSetups: " + IntegerToString(g_backtestTotalSignals) + "\n";
      rpt += "Wins: " + IntegerToString(g_backtestWins) + "\n";
      rpt += "Losses: " + IntegerToString(g_backtestLosses) + "\n";
      rpt += "WinRate: " + DoubleToString(g_backtestWinRate, 1) + "%\n";
      rpt += "AvgRR: " + DoubleToString(g_backtestAvgRR, 2) + "\n";
      rpt += "Layers: 7 (Structure+Engulfing+Volume+BOS+Sweep+H1Trend+Wyckoff)\n";
      rpt += "AdaptiveSL: Yes (layer-count based)\n\n";
   }
   // Institutional Positioning
   // Institutional Positioning (COT + VSA)
   rpt += "[INSTITUTIONAL_POSITIONING]\n";
   rpt += "DataSource: " + g_institutional.cotSource + "\n";
   rpt += "COT_Available: " + string(g_institutional.cotDataAvailable ? "TRUE" : "FALSE") + "\n";
   rpt += "NetPositioning: " + DoubleToString(g_institutional.netPositioning, 1) + "\n";
   rpt += "Bias: " + g_institutional.bias + "\n";
   rpt += "Phase: " + g_institutional.phase + "\n";
   rpt += "VolumeRatio: " + DoubleToString(g_institutional.volumeRatio, 2) + "\n";
   rpt += "AccumulationScore: " + DoubleToString(g_institutional.accumulationScore, 1) + "/10\n\n";
   rpt += "AccumulationScore: " + DoubleToString(g_institutional.accumulationScore, 1) + "/10\n";
   if(g_institutional.cotDataAvailable) {
      rpt += "COT_NetSpeculator: " + DoubleToString(g_institutional.cotNetSpec, 0) + " contracts\n";
      rpt += "COT_NetCommercial: " + DoubleToString(g_institutional.cotNetComm, 0) + " contracts\n";
      rpt += "COT_SpecIndex_52W: " + DoubleToString(g_institutional.cotSpecIndex, 1) + "%\n";
      if(g_institutional.cotSpecIndex > 80) rpt += "COT_Warning: SPECULATORS_EXTREME_LONG (Contrarian Bearish)\n";
      else if(g_institutional.cotSpecIndex < 20) rpt += "COT_Warning: SPECULATORS_EXTREME_SHORT (Contrarian Bullish)\n";
   }
   rpt += "\n";
   // Enhanced Wyckoff
   rpt += "[WYCKOFF_ADVANCED]\n";
   rpt += "EventType: " + g_wyckoff.eventType + "\n";
   rpt += "EventScore: " + DoubleToString(g_wyckoff.eventScore, 1) + "/10\n";
   rpt += "Phase: " + g_wyckoff.phase + "\n";
   rpt += "Spring: " + string(g_wyckoff.hasSpring ? "TRUE" : "FALSE") + "\n";
   rpt += "Upthrust: " + string(g_wyckoff.hasUpthrust ? "TRUE" : "FALSE") + "\n";
   rpt += "TestAfterSpring: " + string(g_wyckoff.hasTestAfterSpring ? "TRUE" : "FALSE") + "\n";
   rpt += "SignOfStrength: " + string(g_wyckoff.hasSignOfStrength ? "TRUE" : "FALSE") + "\n\n";
   // DXY Enhanced
   rpt += "[DXY_ENHANCED]\n";
   rpt += "ProxyMethod: Multi-Pair (EUR/GBP/JPY/CHF/CAD)\n";
   rpt += "ProxyTrend: " + g_dxy.proxyTrend + "\n";
   rpt += "TrendStrength: " + DoubleToString(g_dxy.trendStrength, 1) + "/10\n";
   rpt += "GoldDecoupling: " + string(g_dxy.isDecoupling ? "YES_DETECTED" : "NORMAL_CORRELATION") + "\n\n";
   // Kill Switch
   rpt += "[KILL_SWITCH]\n";
   rpt += "Enabled: " + string(InpKillSwitchEnabled ? "TRUE" : "FALSE") + "\n";
   rpt += "Active: " + string(g_killSwitch.isActive ? "TRUE" : "FALSE") + "\n";
   rpt += "ConsecutiveLosses: " + IntegerToString(g_killSwitch.consecutiveLosses) + "/" + IntegerToString(InpMaxConsecutiveLoss) + "\n";
   rpt += "DailyDrawdown: " + DoubleToString(g_killSwitch.dailyDrawdown, 1) + "%/" + DoubleToString(InpMaxDrawdownPct, 1) + "%\n";
   if(g_killSwitch.isActive)
      rpt += "Reason: " + g_killSwitch.reason + "\n";
   rpt += "\n";
   // Session Performance
   rpt += "[SESSION_PERFORMANCE]\n";
   rpt += "CurrentSession: " + GetCurrentSessionName() + "\n";
   if(g_sessionPerf.asianSignals > 0)
      rpt += "Asian: " + IntegerToString(g_sessionPerf.asianWins) + "/" + IntegerToString(g_sessionPerf.asianSignals) + " (" + DoubleToString(((double)g_sessionPerf.asianWins/g_sessionPerf.asianSignals)*100, 0) + "%)\n";
   if(g_sessionPerf.londonSignals > 0)
      rpt += "London: " + IntegerToString(g_sessionPerf.londonWins) + "/" + IntegerToString(g_sessionPerf.londonSignals) + " (" + DoubleToString(((double)g_sessionPerf.londonWins/g_sessionPerf.londonSignals)*100, 0) + "%)\n";
   if(g_sessionPerf.overlapSignals > 0)
      rpt += "Overlap: " + IntegerToString(g_sessionPerf.overlapWins) + "/" + IntegerToString(g_sessionPerf.overlapSignals) + " (" + DoubleToString(((double)g_sessionPerf.overlapWins/g_sessionPerf.overlapSignals)*100, 0) + "%)\n";
   if(g_sessionPerf.nySignals > 0)
      rpt += "NewYork: " + IntegerToString(g_sessionPerf.nyWins) + "/" + IntegerToString(g_sessionPerf.nySignals) + " (" + DoubleToString(((double)g_sessionPerf.nyWins/g_sessionPerf.nySignals)*100, 0) + "%)\n";
   rpt += "BestSession: " + g_sessionPerf.bestSession + "\n\n";
   // Semi-Auto Status
   if(InpSemiAutoEnabled) {
      rpt += "[SEMI_AUTO_STATUS]\n";
      rpt += "Enabled: TRUE\n";
      rpt += "MinGrade: " + InpSemiAutoMinGrade + "\n";
      rpt += "PendingActive: " + string(g_pendingOrder.isActive ? "TRUE" : "FALSE") + "\n";
      if(g_pendingOrder.isActive) {
         rpt += "PendingDirection: " + g_pendingOrder.direction + "\n";
         rpt += "PendingGrade: " + g_pendingOrder.grade + "\n";
         rpt += "PendingConfirmed: " + string(g_pendingOrder.isConfirmed ? "TRUE" : "FALSE") + "\n";
      }
      rpt += "\n";
   }
   rpt += "[END_OF_DATA_FEED]\n";
   rpt += "###########################################################\n";
   rpt += "\n=================================================================\n";
   rpt += "JB SMART TRADE GOLD - Ultimate Nexus Pro v4.2\n";
   rpt += "Institutional-Grade Analysis System - Enhanced with AI Integration\n";
   return rpt;
}
// ✅ FIX #1: Removed extra closing brace that was at line 2678
string BuildArabicReportContent(bool manual) {
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double spread = (ask - bid) / GoldPip();
   string rpt = "";
   rpt += "📊 تقرير التحليل الاستراتيجي - الذهب (XAUUSD)\n";
   rpt += "========================================\n\n";
   rpt += "🤖 إشارة النظام: " + g_entrySignal.direction + "\n";
   rpt += "⭐ الدرجة: " + g_entrySignal.grade + "\n";
   rpt += "📈 النتيجة: " + DoubleToString(g_entrySignal.totalScore, 1) + "/10.0\n";
   rpt += "✅ التحقق: " + string(g_entrySignal.validated ? "نعم" : "لا") + "\n";
   rpt += "🔢 الطبقات المؤكدة: " + IntegerToString(g_entrySignal.confirmedLayers) + "\n";
   if(StringLen(g_entrySignal.rejectionReason) > 0)
      rpt += "❌ سبب الرفض: " + g_entrySignal.rejectionReason + "\n";
   rpt += "\n";
   rpt += "💰 معلومات السعر:\n";
   rpt += "• السعر الحالي: " + DoubleToString(bid, 2) + "\n";
   rpt += "• السبريد: " + DoubleToString(spread, 1) + " نقطة\n";
   rpt += "• حالة السبريد: " + string(spread <= InpMaxSpreadPips ? "مقبول" : "مرتفع جداً") + "\n";
   rpt += "• نظام السوق: " + EnumToString(g_currentRegime) + "\n\n";
   if(g_entrySignal.entry > 0) {
      rpt += "🎯 مستويات الدخول:\n";
      rpt += "• سعر الدخول: " + DoubleToString(g_entrySignal.entry, 2) + "\n";
      rpt += "• وقف الخسارة: " + DoubleToString(g_entrySignal.sl, 2) + "\n";
      rpt += "• الهدف 1: " + DoubleToString(g_entrySignal.tp1, 2) + "\n";
      rpt += "• الهدف 2: " + DoubleToString(g_entrySignal.tp2, 2) + "\n";
      rpt += "• الهدف 3: " + DoubleToString(g_entrySignal.tp3, 2) + "\n";
      rpt += "• نسبة المخاطرة/العائد: " + DoubleToString(g_entrySignal.rr, 2) + "\n";
      rpt += "• حجم اللوت الموصى: " + DoubleToString(g_entrySignal.lotSize, 2) + "\n\n";
   }
   rpt += "⚖️ الأوزان الديناميكية:\n";
   rpt += "• الماكرو: " + DoubleToString(g_weights.macro, 2) + "\n";
   rpt += "• الهيكل: " + DoubleToString(g_weights.structure, 2) + "\n";
   rpt += "• SMC: " + DoubleToString(g_weights.smc, 2) + "\n";
   rpt += "• فيبوناتشي: " + DoubleToString(g_weights.fib, 2) + "\n";
   rpt += "• وايكوف: " + DoubleToString(g_weights.wyckoff, 2) + "\n";
   rpt += "• الحجم: " + DoubleToString(g_weights.volume, 2) + "\n";
   rpt += "• DXY: " + DoubleToString(g_weights.dxy, 2) + "\n\n";
   rpt += "📊 الماكرو (D1/H4):\n";
   rpt += "• تحيز D1: " + g_macro.d1Bias + "\n";
   rpt += "• تحيز H4: " + g_macro.h4Bias + "\n";
   rpt += "• متوافق: " + string(g_macro.isAligned ? "نعم" : "لا") + "\n\n";
   rpt += "📊 التحليل الفني:\n";
   rpt += "• الاتجاه العام: " + g_structure.trend + "\n";
   rpt += "• ارتفاع بنيوي: " + DoubleToString(g_structure.structuralHigh, 2) + "\n";
   rpt += "• انخفاض بنيوي: " + DoubleToString(g_structure.structuralLow, 2) + "\n";
   rpt += "• كسر بنيوي (BOS): " + string(g_structure.hasBOS ? "نعم" : "لا") + "\n";
   rpt += "• تغير الشخصية (CHoCH): " + string(g_structure.hasCHoCH ? "نعم" : "لا") + "\n\n";
   rpt += "🏦 تحليل السيولة الذكية:\n";
   rpt += "• التحيز: " + g_smartMoney.bias + "\n";
   rpt += "• كتلة طلب صاعدة: " + string(g_smartMoney.bullOB.isValid ? "فعالة" : "غير فعالة") + "\n";
   rpt += "• قوة OB صاعد: " + IntegerToString(g_smartMoney.bullOB.strength) + "/10\n";
   rpt += "• نسبة التخفيف صاعد: " + DoubleToString(g_smartMoney.bullOB.mitigation_percent, 1) + "%\n";
   rpt += "• عدد اللمسات صاعد: " + IntegerToString(g_smartMoney.bullOB.touchCount) + "\n";
   rpt += "• كتلة طلب هابطة: " + string(g_smartMoney.bearOB.isValid ? "فعالة" : "غير فعالة") + "\n";
   rpt += "• قوة OB هابط: " + IntegerToString(g_smartMoney.bearOB.strength) + "/10\n";
   rpt += "• نسبة التخفيف هابط: " + DoubleToString(g_smartMoney.bearOB.mitigation_percent, 1) + "%\n";
   rpt += "• عدد اللمسات هابط: " + IntegerToString(g_smartMoney.bearOB.touchCount) + "\n";
   rpt += "• امتصاص السيولة: " + string(g_liquiditySweep.detected ? "تم التحديد" : "غير محدد") + "\n";
   rpt += "• اتجاه الامتصاص: " + g_liquiditySweep.direction + "\n";
   rpt += "• قوة الامتصاص: " + IntegerToString(g_liquiditySweep.strength) + "/10\n";
   rpt += "• مسافة الامتصاص: " + DoubleToString(g_liquiditySweep.sweepDistance, 1) + " نقطة\n\n";
   rpt += "📐 فيبوناتشي:\n";
   rpt += "• التحيز: " + g_fib.bias + "\n";
   rpt += "• داخل منطقة OTE: " + string(g_fib.inOTE ? "نعم" : "لا") + "\n";
   rpt += "• منطقة الخصم: " + string(g_fib.inDiscount ? "نعم" : "لا") + "\n";
   rpt += "• منطقة العلاوة: " + string(g_fib.inPremium ? "نعم" : "لا") + "\n";
   rpt += "• أعلى OTE: " + DoubleToString(g_fib.oteHigh, 2) + "\n";
   rpt += "• أدنى OTE: " + DoubleToString(g_fib.oteLow, 2) + "\n\n";
   rpt += "📈 وايكوف:\n";
   rpt += "• التحيز: " + g_wyckoff.bias + "\n";
   rpt += "• المرحلة: " + g_wyckoff.phase + "\n";
   rpt += "• إشارة VSA: " + g_wyckoff.vsaSignal + "\n";
   rpt += "• القوة: " + DoubleToString(g_wyckoff.strength, 2) + "\n\n";
   rpt += "🔄 الأنماط السعرية:\n";
   rpt += "• اسم النمط: " + g_pattern.name + "\n";
   rpt += "• مؤكد: " + string(g_pattern.confirmed ? "نعم" : "لا") + "\n";
   rpt += "• التحيز: " + g_pattern.bias + "\n\n";
   rpt += "📉 الانحراف (Divergence):\n";
   rpt += "• النوع: " + g_divergence.type + "\n";
   rpt += "• القوة: " + DoubleToString(g_divergence.strength, 1) + "\n";
   rpt += "• مؤكد: " + string(g_divergence.confirmed ? "نعم" : "لا") + "\n\n";
   rpt += "📊 الحجم:\n";
   rpt += "• التحيز: " + g_volume.bias + "\n";
   rpt += "• VWAP: " + DoubleToString(g_volume.vwap, 2) + "\n";
   rpt += "• الموقع: " + g_volume.position + "\n";
   rpt += "• ارتفاع مفاجئ: " + string(g_volume.volSpike ? "نعم" : "لا") + "\n";
   rpt += "• الحجم النسبي: " + DoubleToString(g_volume.relativeVolume, 2) + "x\n\n";
   rpt += "🕐 الجلسة:\n";
   rpt += "• الجلسة الحالية: " + g_session.currentSession + "\n";
   rpt += "• منطقة القتل: " + string(g_session.isKillzone ? "نعم" : "لا") + "\n";
   rpt += "• اسم المنطقة: " + g_session.killzoneName + "\n\n";
   rpt += "💵 مؤشر الدولار الأمريكي:\n";
   rpt += "• القيمة الحالية: " + DoubleToString(g_dxy.current, 2) + "\n";
   rpt += "• الاتجاه: " + g_dxy.trend + "\n";
   rpt += "• نسبة الارتباط: " + DoubleToString(g_dxy.corrPercent, 1) + "%\n";
   rpt += "• تأثير على الذهب: " + g_dxy.goldImpact + "\n";
   rpt += "• اتجاه الفضة: " + g_dxy.silverTrend + "\n";
   rpt += "• اتجاه العوائد: " + g_dxy.yieldsTrend + "\n";
   rpt += "• معنويات المخاطر: " + g_dxy.sentiment + "\n\n";
   rpt += "📅 التحليل الموسمي:\n";
   rpt += "• التحيز الشهري: " + g_seasonal.monthlyBias + "\n";
   rpt += "• التحيز اليومي: " + g_seasonal.dayBias + "\n";
   rpt += "• النتيجة الموسمية: " + DoubleToString(g_seasonal.seasonalScore, 2) + "\n\n";
   if(InpUseMultiTF) {
      rpt += "🔀 تأكيد متعدد الأطر الزمنية:\n";
      rpt += "• M5: " + g_mtf.m5_bias + "\n";
      rpt += "• M15: " + g_mtf.m15_bias + "\n";
      rpt += "• H1: " + g_mtf.h1_bias + "\n";
      rpt += "• H4: " + g_mtf.h4_bias + "\n";
      rpt += "• الكل متوافق: " + string(g_mtf.allAligned ? "نعم" : "لا") + "\n";
      rpt += "• عدد المتوافق: " + IntegerToString(g_mtf.alignedCount) + "/4\n";
      rpt += "• الثقة: " + DoubleToString(g_mtf.confidence, 1) + "%\n\n";
   }
   if(InpUseOrderFlow) {
      rpt += "📶 تدفق الطلبات:\n";
      rpt += "• تم الكشف: " + string(g_orderFlow.detected ? "نعم" : "لا") + "\n";
      rpt += "• النوع: " + g_orderFlow.type + "\n";
      rpt += "• نسبة الاختلال: " + DoubleToString(g_orderFlow.imbalanceRatio, 2) + "\n";
      rpt += "• الشموع المتتالية: " + IntegerToString(g_orderFlow.consecutiveBars) + "\n";
      rpt += "• القوة: " + DoubleToString(g_orderFlow.strength, 1) + "/10\n\n";
   }
   if(InpUsePowerOf3) {
      rpt += "🎯 Power of 3 (AMD):\n";
      rpt += "• تم الكشف: " + string(g_powerOf3.detected ? "نعم" : "لا") + "\n";
      rpt += "• المرحلة: " + g_powerOf3.phase + "\n";
      rpt += "• التحيز: " + g_powerOf3.bias + "\n";
      rpt += "• القوة: " + DoubleToString(g_powerOf3.strength, 1) + "/10\n";
      rpt += "• نطاق التلاعب: " + DoubleToString(g_powerOf3.manipulationRange, 1) + "\n\n";
   }
   rpt += "📰 فلتر الأخبار:\n";
   rpt += "• الحالة: " + g_newsStatus + "\n\n";
   rpt += "⚙️ إعدادات النظام:\n";
   rpt += "• الوضع: " + string(manual ? "يدوي" : "تلقائي") + "\n";
   rpt += "• حالة النظام: " + string(g_isRunning ? "يعمل" : "متوقف") + "\n";
   rpt += "• فلتر الأخبار: " + string(InpUseNewsFilter ? "مفعل" : "معطل") + "\n\n";
   if(InpUsePsychology) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      double profitPct = (balance > 0) ? (g_dailyClosedProfit / balance) * 100 : 0;
      string accStatus = GetAccountStatus(marginLevel, profitPct, balance);
      rpt += "💼 معلومات الحساب:\n";
      rpt += "• الرصيد: " + DoubleToString(balance, 2) + "\n";
      rpt += "• القيمة السوقية: " + DoubleToString(equity, 2) + "\n";
      rpt += "• مستوى الهامش: " + DoubleToString(marginLevel, 2) + "%\n";
      rpt += "• الهامش الحر: " + DoubleToString(freeMargin, 2) + "\n";
      rpt += "• الصفقات المفتوحة: " + IntegerToString(PositionsTotal()) + "\n";
      rpt += "• الربح اليومي: " + DoubleToString(g_dailyClosedProfit, 2) + "\n";
      rpt += "• نسبة الربح: " + DoubleToString(profitPct, 2) + "%\n";
      rpt += "• عدد الصفقات اليوم: " + IntegerToString(g_dailyTradeCount) + "/" + IntegerToString(InpMaxDailyTrades) + "\n";
      rpt += "• حالة الحساب: " + GetAccountStatusAR(accStatus) + "\n\n";
   }
   // Conflict Detection
   if(g_layerConflict.hasConflict) {
      rpt += "⚠️ تعارض الطبقات التحليلية:\n";
      rpt += "• عدد التعارضات: " + IntegerToString(g_layerConflict.conflictCount) + "\n";
      rpt += "• الشدة: " + g_layerConflict.severity + "\n";
      rpt += "• تخفيض الثقة: " + DoubleToString(g_layerConflict.confidenceReduction, 1) + "%\n";
      rpt += "• النتيجة المعدّلة: " + DoubleToString(g_entrySignal.totalScore * (1.0 - g_layerConflict.confidenceReduction/100.0), 2) + "/10\n";
      for(int c = 0; c < g_layerConflict.conflictCount; c++) {
         rpt += "  " + IntegerToString(c+1) + ". " + g_layerConflict.conflicts[c] + "\n";
      }
      rpt += "\n";
   } else {
      rpt += "✅ لا توجد تعارضات بين الطبقات التحليلية\n\n";
   }
   // Institutional Positioning
   rpt += "🏦 المراكز المؤسسية (COT-Style):\n";
   rpt += "• الموقع الصافي: " + DoubleToString(g_institutional.netPositioning, 1) + "/100\n";
   // Institutional Positioning (COT + VSA)
   if(g_institutional.cotDataAvailable) {
      rpt += "🏦 المراكز المؤسسية (بيانات CFTC حقيقية - " + g_institutional.cotSource + "):\n";
      rpt += "• صافي المضاربين: " + DoubleToString(g_institutional.cotNetSpec, 0) + " عقد\n";
      rpt += "• صافي التجاريين: " + DoubleToString(g_institutional.cotNetComm, 0) + " عقد\n";
      rpt += "• مؤشر المضاربين (52 أسبوع): " + DoubleToString(g_institutional.cotSpecIndex, 1) + "%\n";
      if(g_institutional.cotSpecIndex > 80)
         rpt += "• ⚠️ تحذير: مضاربون في أقصى شراء (إشارة عكسية هبوطية)\n";
      else if(g_institutional.cotSpecIndex < 20)
         rpt += "• ⚠️ تحذير: مضاربون في أقصى بيع (إشارة عكسية صعودية)\n";
   } else {
      rpt += "🏦 المراكز المؤسسية (تحليل VSA التقديري):\n";
      rpt += "• ℹ️ بيانات CFTC غير متوفرة - ضع ملف COT_Gold_Data.csv في مجلد MQL5/Files/Common/\n";
   }
   rpt += "• الموقع الصافي المدمج: " + DoubleToString(g_institutional.netPositioning, 1) + "/100\n";
   rpt += "• الاتجاه: " + g_institutional.bias + "\n";
   rpt += "• المرحلة: " + g_institutional.phase + "\n";
   rpt += "• نسبة الحجم: " + DoubleToString(g_institutional.volumeRatio, 2) + "x\n";
   rpt += "• نقاط التجميع/التوزيع: " + DoubleToString(g_institutional.accumulationScore, 1) + "/10\n\n";
   
   // Enhanced Wyckoff
   rpt += "📐 وايكوف المتقدم:\n";
   rpt += "• الحدث: " + g_wyckoff.eventType + "\n";
   rpt += "• نقاط الحدث: " + DoubleToString(g_wyckoff.eventScore, 1) + "/10\n";
   rpt += "• المرحلة: " + g_wyckoff.phase + "\n";
   if(g_wyckoff.hasSpring) rpt += "• ✅ Spring مكتشف\n";
   if(g_wyckoff.hasUpthrust) rpt += "• ✅ Upthrust مكتشف\n";
   if(g_wyckoff.hasTestAfterSpring) rpt += "• ✅ Test بعد Spring\n";
   if(g_wyckoff.hasSignOfStrength) rpt += "• ✅ علامة قوة (SOS)\n";
   rpt += "\n";
   
   // DXY Enhanced Info
   if(g_dxy.proxyTrend != "" && g_dxy.proxyTrend != "UNKNOWN") {
      rpt += "💵 DXY المحسّن (Multi-Pair Proxy):\n";
      rpt += "• اتجاه البروكسي: " + g_dxy.proxyTrend + "\n";
      rpt += "• قوة الاتجاه: " + DoubleToString(g_dxy.trendStrength, 1) + "/10\n";
      if(g_dxy.isDecoupling)
         rpt += "• ⚠️ انفصال Gold/USD مكتشف!\n";
      rpt += "\n";
   }
   
   // Kill Switch Status
   if(InpKillSwitchEnabled) {
      rpt += "🛡️ حماية Kill Switch:\n";
      rpt += "• الحالة: " + string(g_killSwitch.isActive ? "🔴 مُفعّل" : "🟢 جاهز") + "\n";
      rpt += "• خسائر متتالية: " + IntegerToString(g_killSwitch.consecutiveLosses) + "/" + IntegerToString(InpMaxConsecutiveLoss) + "\n";
      rpt += "• التراجع اليومي: " + DoubleToString(g_killSwitch.dailyDrawdown, 1) + "%/" + DoubleToString(InpMaxDrawdownPct, 1) + "%\n";
      if(g_killSwitch.isActive)
         rpt += "• السبب: " + g_killSwitch.reason + "\n";
      rpt += "\n";
   }
   
   // Session Performance
   if(g_sessionPerf.asianSignals + g_sessionPerf.londonSignals + g_sessionPerf.nySignals + g_sessionPerf.overlapSignals > 0) {
      rpt += "🕐 أداء الجلسات:\n";
      if(g_sessionPerf.asianSignals > 0) {
         double asianRate = ((double)g_sessionPerf.asianWins / g_sessionPerf.asianSignals) * 100;
         rpt += "• آسيا: " + IntegerToString(g_sessionPerf.asianWins) + "/" + IntegerToString(g_sessionPerf.asianSignals) + " (" + DoubleToString(asianRate, 0) + "%)\n";
      }
      if(g_sessionPerf.londonSignals > 0) {
         double londonRate = ((double)g_sessionPerf.londonWins / g_sessionPerf.londonSignals) * 100;
         rpt += "• لندن: " + IntegerToString(g_sessionPerf.londonWins) + "/" + IntegerToString(g_sessionPerf.londonSignals) + " (" + DoubleToString(londonRate, 0) + "%)\n";
      }
      if(g_sessionPerf.overlapSignals > 0) {
         double overlapRate = ((double)g_sessionPerf.overlapWins / g_sessionPerf.overlapSignals) * 100;
         rpt += "• التداخل: " + IntegerToString(g_sessionPerf.overlapWins) + "/" + IntegerToString(g_sessionPerf.overlapSignals) + " (" + DoubleToString(overlapRate, 0) + "%)\n";
      }
      if(g_sessionPerf.nySignals > 0) {
         double nyRate = ((double)g_sessionPerf.nyWins / g_sessionPerf.nySignals) * 100;
         rpt += "• نيويورك: " + IntegerToString(g_sessionPerf.nyWins) + "/" + IntegerToString(g_sessionPerf.nySignals) + " (" + DoubleToString(nyRate, 0) + "%)\n";
      }
      if(g_sessionPerf.bestSession != "UNKNOWN")
         rpt += "• أفضل جلسة: " + g_sessionPerf.bestSession + " (" + DoubleToString(g_sessionPerf.bestSessionWinRate, 0) + "%)\n";
      rpt += "\n";
   }
   // Grade Stats
   if(InpUseBacktesting) {
      bool hasGradeData = false;
      for(int g = 0; g < 6; g++) {
         if(g_gradeStats[g].totalSignals > 0) { hasGradeData = true; break; }
      }
      if(hasGradeData) {
         rpt += "📊 إحصائيات الأداء لكل درجة:\n";
         for(int g = 0; g < 6; g++) {
            if(g_gradeStats[g].totalSignals > 0) {
               rpt += "• " + IndexToGrade(g) + ": " + 
                      IntegerToString(g_gradeStats[g].totalSignals) + " إشارة، فوز " + 
                      DoubleToString(g_gradeStats[g].winRate, 1) + "%\n";
            }
         }
         rpt += "\n";
      }
   }
   if(InpUseBacktesting && g_totalSignals > 0) {
      rpt += "📈 تتبع الأداء:\n";
      rpt += "• إجمالي الإشارات: " + IntegerToString(g_totalSignals) + "\n";
      rpt += "• إشارات رابحة: " + IntegerToString(g_winningSignals) + "\n";
      rpt += "• إشارات خاسرة: " + IntegerToString(g_losingSignals) + "\n";
      rpt += "• نسبة الفوز: " + DoubleToString(g_winRate, 2) + "%\n";
      rpt += "• متوسط RR: " + DoubleToString(g_avgRR, 2) + "\n\n";
   }
   // Historical Backtest
   if(g_backtestCompleted) {
      rpt += "📋 نتائج الباك تيست التاريخي:\n";
      rpt += "• الفترة: آخر 2000 شمعة (M15)\n";
      rpt += "• إجمالي الإعدادات: " + IntegerToString(g_backtestTotalSignals) + "\n";
      rpt += "• فائزة: " + IntegerToString(g_backtestWins) + "\n";
      rpt += "• خاسرة: " + IntegerToString(g_backtestLosses) + "\n";
      rpt += "• نسبة الفوز: " + DoubleToString(g_backtestWinRate, 1) + "%\n";
      rpt += "• متوسط RR: " + DoubleToString(g_backtestAvgRR, 2) + "\n\n";
   }
   // Semi-Auto Status
   if(InpSemiAutoEnabled && g_pendingOrder.isActive) {
      rpt += "🔔 أمر معلق:\n";
      rpt += "• الاتجاه: " + g_pendingOrder.direction + "\n";
      rpt += "• الدرجة: " + g_pendingOrder.grade + "\n";
      rpt += "• الدخول: " + DoubleToString(g_pendingOrder.entry, 2) + "\n";
      rpt += "• مؤكد: " + string(g_pendingOrder.isConfirmed ? "نعم" : "في الانتظار") + "\n\n";
   }
   rpt += "📊 تحليل شامل:\n";
   double adjustedScore = g_entrySignal.totalScore * (1.0 - g_layerConflict.confidenceReduction/100.0);
   if(adjustedScore >= 8.5 && !g_layerConflict.hasConflict) {
      rpt += "🟢 إشارة قوية - احتمالية عالية للربح\n";
   } else if(adjustedScore >= 6.5) {
      rpt += "🟡 إشارة متوسطة - احتمالية مقبولة\n";
   } else {
      rpt += "🔴 إشارة ضعيفة - يفضل الانتظار\n";
   }
   if(g_layerConflict.hasConflict && g_layerConflict.severity == "CRITICAL") {
      rpt += "🚫 تحذير: تعارضات حرجة - يُنصح بعدم الدخول\n";
   }
   rpt += "\n========================================\n";
   rpt += "نظام JB SMART TRADE GOLD - الإصدار 4.1\n";
   rpt += "نظام تحليل احترافي على مستوى المؤسسات\n";
   return rpt;
}
// JSON Report removed - text reports are now sent to Telegram directly
//====================================================================
//  EXPORT FUNCTIONS
//====================================================================
bool ExportTextReport(bool manual, string &englishFile, string &arabicFile) {
   englishFile = "";
   arabicFile = "";
   
   // Create English version (Prompt report)
   string content = BuildReportContent(manual);
   string filename = "NexusPro_Report_" + Symbol() + "_" + 
                     (manual ? "MANUAL_" : "AUTO_") + 
                     TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES) + ".txt";
   StringReplace(filename, ":", "-");
   
   int handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE) {
      FileWriteString(handle, content);
      FileClose(handle);
      Print("Text Report Exported: ", filename);
      englishFile = filename;
   }
   
   // Create Arabic version (General report)
   string arabicContent = BuildArabicReportContent(manual);
   string arabicFilename = "NexusPro_Report_" + Symbol() + "_AR_" + 
                          (manual ? "MANUAL_" : "AUTO_") + 
                          TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES) + ".txt";
   StringReplace(arabicFilename, ":", "-");
   
   int arabicHandle = FileOpen(arabicFilename, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(arabicHandle != INVALID_HANDLE) {
      FileWriteString(arabicHandle, arabicContent);
      FileClose(arabicHandle);
      Print("Arabic Text Report Exported: ", arabicFilename);
      arabicFile = arabicFilename;
   }
   
   if(StringLen(englishFile) > 0 || StringLen(arabicFile) > 0) {
      return true;
   }
   Print("Failed to export text reports. Error: ", GetLastError());
   return false;
}
//====================================================================
//  UI & DASHBOARD
//====================================================================
void CreateUI() {
   ObjectCreate(0, "Nexus_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_XSIZE, 400);
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_YSIZE, 600);
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_BGCOLOR, C'10,15,30');
   ObjectSetInteger(0, "Nexus_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectCreate(0, "Nexus_Title", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Nexus_Title", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "Nexus_Title", OBJPROP_YDISTANCE, 40);
   ObjectSetString(0, "Nexus_Title", OBJPROP_TEXT, "[GOLD] JB SMART TRADE - PRO v4.2");
   ObjectSetInteger(0, "Nexus_Title", OBJPROP_COLOR, clrGold);
   ObjectSetInteger(0, "Nexus_Title", OBJPROP_FONTSIZE, 10);
   ObjectCreate(0, "Nexus_Btn_Export", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_YDISTANCE, 560);
   ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_XSIZE, 340);
   ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_YSIZE, 30);
   ObjectSetString(0, "Nexus_Btn_Export", OBJPROP_TEXT, "GENERATE DETAILED REPORT");
   ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_BGCOLOR, clrDarkGreen);
}
void UpdateUI() {
   if(TimeLocal() - g_lastUIUpdate < 1) return;
   g_lastUIUpdate = TimeLocal();
   string labels[] = {
      "Lbl_Signal", "Lbl_Score", "Lbl_Grade", "Lbl_Regime",
      "Lbl_Macro", "Lbl_Structure", "Lbl_SMC", "Lbl_Sweep",
      "Lbl_Fib", "Lbl_Wyckoff", "Lbl_Pattern", "Lbl_Div",
      "Lbl_Vol", "Lbl_Session", "Lbl_DXY", "Lbl_Silver",
      "Lbl_Season", "Lbl_MTF", "Lbl_OFI", "Lbl_Perf",
      "Lbl_Trade", "Lbl_Price", "Lbl_Status", "Lbl_News"
   };
   for(int i=0; i<ArraySize(labels); i++) {
      if(ObjectFind(0, labels[i]) < 0) {
         ObjectCreate(0, labels[i], OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, labels[i], OBJPROP_XDISTANCE, 25);
         ObjectSetInteger(0, labels[i], OBJPROP_YDISTANCE, 70 + (i * 20));
         ObjectSetInteger(0, labels[i], OBJPROP_FONTSIZE, 8);
         ObjectSetString(0, labels[i], OBJPROP_FONT, "Consolas");
      }
      ObjectSetInteger(0, labels[i], OBJPROP_COLOR, clrWhite);
   }
   color sigClr = (g_entrySignal.direction == "BUY") ? clrLime : 
                  (g_entrySignal.direction == "SELL" ? clrRed : clrGray);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   ObjectSetString(0, "Nexus_Title", OBJPROP_TEXT, 
                   g_isRunning ? "[GOLD] JB SMART TRADE - PRO v4.2" : "[PAUSED] JB SMART TRADE");
   ObjectSetInteger(0, "Nexus_Title", OBJPROP_COLOR, g_isRunning ? clrGold : clrGray);
   ObjectSetString(0, "Lbl_Signal", OBJPROP_TEXT, 
                   "Signal: " + g_entrySignal.direction + " [" + g_entrySignal.grade + "]");
   ObjectSetInteger(0, "Lbl_Signal", OBJPROP_COLOR, sigClr);
   ObjectSetString(0, "Lbl_Score", OBJPROP_TEXT, 
                   "Score: " + DoubleToString(g_entrySignal.totalScore, 1) + "/10.0");
   ObjectSetInteger(0, "Lbl_Score", OBJPROP_COLOR, 
                   (g_entrySignal.totalScore >= 7.0 ? clrGold : clrWhite));
   ObjectSetString(0, "Lbl_Grade", OBJPROP_TEXT, 
                   "Validated: " + string(g_entrySignal.validated ? "TRUE" : "FALSE") + 
                   " | Layers: " + IntegerToString(g_entrySignal.confirmedLayers));
   ObjectSetString(0, "Lbl_Regime", OBJPROP_TEXT, 
                   "Regime: " + EnumToString(g_currentRegime));
   ObjectSetInteger(0, "Lbl_Regime", OBJPROP_COLOR, 
                   (g_currentRegime == REGIME_VOLATILE_CHOP ? clrRed : clrWhite));
   ObjectSetString(0, "Lbl_Macro", OBJPROP_TEXT, 
                   "Macro: " + g_macro.d1Bias + " | " + g_macro.h4Bias);
   ObjectSetString(0, "Lbl_Structure", OBJPROP_TEXT, 
                   "Structure: " + g_structure.trend + 
                   (g_structure.hasBOS ? " [BOS]" : "") +
                   (g_structure.hasCHoCH ? " [CHoCH]" : ""));
   
   string smcText = "SMC: " + g_smartMoney.bias;
   if(g_smartMoney.bullOB.isValid) 
      smcText += " | BullOB(" + IntegerToString(g_smartMoney.bullOB.strength) + ")";
   if(g_smartMoney.bearOB.isValid) 
      smcText += " | BearOB(" + IntegerToString(g_smartMoney.bearOB.strength) + ")";
   ObjectSetString(0, "Lbl_SMC", OBJPROP_TEXT, smcText);
   ObjectSetString(0, "Lbl_Sweep", OBJPROP_TEXT, 
                   "Sweep: " + g_liquiditySweep.direction + " (" + 
                   IntegerToString(g_liquiditySweep.strength) + "/10)");
   ObjectSetString(0, "Lbl_Fib", OBJPROP_TEXT, 
                   "Fib: " + g_fib.bias + (g_fib.inOTE ? " [OTE]" : ""));
   ObjectSetString(0, "Lbl_Wyckoff", OBJPROP_TEXT, 
                   "Wyckoff: " + g_wyckoff.bias + " (" + g_wyckoff.phase + ")");
   ObjectSetString(0, "Lbl_Pattern", OBJPROP_TEXT, 
                   "Pattern: " + g_pattern.name);
   ObjectSetString(0, "Lbl_Div", OBJPROP_TEXT, 
                   "Divergence: " + g_divergence.type);
   ObjectSetString(0, "Lbl_Vol", OBJPROP_TEXT, 
                   "Volume: " + g_volume.bias + " (" + g_volume.position + " VWAP, " + 
                   DoubleToString(g_volume.relativeVolume, 1) + "x)");
   ObjectSetString(0, "Lbl_Session", OBJPROP_TEXT, 
                   "Session: " + g_session.currentSession + 
                   (g_session.isKillzone ? " [KILLZONE]" : ""));
   ObjectSetString(0, "Lbl_DXY", OBJPROP_TEXT, 
                   "DXY: " + g_dxy.trend + " (Corr: " + 
                   DoubleToString(g_dxy.corrPercent, 0) + "%)");
   ObjectSetString(0, "Lbl_Silver", OBJPROP_TEXT, 
                   "Silver: " + g_dxy.silverTrend + " | Yields: " + g_dxy.yieldsTrend);
   ObjectSetString(0, "Lbl_Season", OBJPROP_TEXT, 
                   "Seasonality: " + g_seasonal.monthlyBias);
   if(InpUseMultiTF) {
      ObjectSetString(0, "Lbl_MTF", OBJPROP_TEXT, 
                      "MTF: " + IntegerToString(g_mtf.alignedCount) + "/4 (" + 
                      DoubleToString(g_mtf.confidence, 0) + "%)");
   } else {
      ObjectSetString(0, "Lbl_MTF", OBJPROP_TEXT, "MTF: DISABLED");
   }
   if(InpUseOrderFlow) {
      ObjectSetString(0, "Lbl_OFI", OBJPROP_TEXT, 
                      "OrderFlow: " + g_orderFlow.type + " (" + 
                      DoubleToString(g_orderFlow.strength, 1) + ")");
   } else {
      ObjectSetString(0, "Lbl_OFI", OBJPROP_TEXT, "OrderFlow: DISABLED");
   }
   if(InpUseBacktesting && g_totalSignals > 0) {
      ObjectSetString(0, "Lbl_Perf", OBJPROP_TEXT, 
                      "Performance: WR " + DoubleToString(g_winRate, 1) + "% | RR " + 
                      DoubleToString(g_avgRR, 2));
      ObjectSetInteger(0, "Lbl_Perf", OBJPROP_COLOR, 
                      (g_winRate >= 50 ? clrLime : clrRed));
   } else {
      ObjectSetString(0, "Lbl_Perf", OBJPROP_TEXT, "Performance: TRACKING...");
   }
   ObjectSetString(0, "Lbl_News", OBJPROP_TEXT, "News: " + g_newsStatus);
   ObjectSetInteger(0, "Lbl_News", OBJPROP_COLOR, 
                   (g_newsPauseActive ? clrRed : clrGray));
   if(g_entrySignal.validated) {
      ObjectSetString(0, "Lbl_Trade", OBJPROP_TEXT, 
                      "Entry: " + DoubleToString(g_entrySignal.entry, 2) + 
                      " | LOT: " + DoubleToString(g_entrySignal.lotSize, 2));
      ObjectSetInteger(0, "Lbl_Trade", OBJPROP_COLOR, clrYellow);
      ObjectSetString(0, "Lbl_Price", OBJPROP_TEXT, 
                      "SL: " + DoubleToString(g_entrySignal.sl, 2) + 
                      " | TP: " + DoubleToString(g_entrySignal.tp1, 2) + 
                      " | R:R " + DoubleToString(g_entrySignal.rr, 1));
      ObjectSetInteger(0, "Lbl_Price", OBJPROP_COLOR, clrAqua);
   } else {
      ObjectSetString(0, "Lbl_Trade", OBJPROP_TEXT, 
                      "Reason: " + g_entrySignal.rejectionReason);
      ObjectSetInteger(0, "Lbl_Trade", OBJPROP_COLOR, clrSilver);
      ObjectSetString(0, "Lbl_Price", OBJPROP_TEXT, 
                      "Price: " + DoubleToString(bid, 2));
      ObjectSetInteger(0, "Lbl_Price", OBJPROP_COLOR, clrAqua);
   }
   ObjectSetString(0, "Lbl_Status", OBJPROP_TEXT, 
                   g_isRunning ? "System: RUNNING" : "System: PAUSED");
   ObjectSetInteger(0, "Lbl_Status", OBJPROP_COLOR, 
                   (g_isRunning ? clrLime : clrYellow));
}
//====================================================================
//  TELEGRAM REMOTE CONTROL - FIXED
//====================================================================
// ✅ FIX #2: Removed orphaned code lines 2994-2997
void ExecuteCommand(string cmd) {
   string lowerCmd = StringLowerSafe(cmd);
   int atPos = StringFind(lowerCmd, "@");
   if(atPos != -1) lowerCmd = StringSubstr(lowerCmd, 0, atPos);
   StringReplace(lowerCmd, " ", "");
   if(lowerCmd == "/start" || lowerCmd == "start" || lowerCmd == "تشغيل") {
      g_isRunning = true;
      SendTelegram("✅ تم تشغيل النظام\n\nسيتم استئناف التحليل التلقائي والتصدير والإشعارات.");
   }
   else if(lowerCmd == "/stop" || lowerCmd == "stop" || lowerCmd == "إيقاف") {
      g_isRunning = false;
      SendTelegram("⏸️ تم إيقاف النظام\n\nالتحليل التلقائي والتصدير متوقفان.\nالأوامر اليدوية والتقارير عند الطلب لا تزال متاحة.");
   }
   else if(lowerCmd == "/export" || lowerCmd == "export" || lowerCmd == "تصدير") {
      SendTelegram("📤 جاري إعداد التقرير الاستراتيجي الشامل...");
      string engFile, arFile;
      bool exportOK = ExportTextReport(true, engFile, arFile);
      if(exportOK) {
         SendMarketSummary();
         if(StringLen(arFile) > 0) SendTelegramFile(arFile, "📄 التقرير العربي الشامل", "sendDocument");
         if(StringLen(engFile) > 0) SendTelegramFile(engFile, "📊 تقرير البرومبت (Prompt Report)", "sendDocument");
         CaptureAndSendScreenshot("📸 لقطة شاشة يدوية");
      } else {
         SendTelegram("❌ فشل تصدير التقرير");
      }
   }
   else if(lowerCmd == "/status" || lowerCmd == "status" || lowerCmd == "حالة") {
      string statusMsg = "🤖 حالة النظام الحالية\n\n";
      statusMsg += "• الحالة: " + (g_isRunning ? "🟢 يعمل" : "⏸️ متوقف") + "\n";
      statusMsg += "• الإشارة: " + g_entrySignal.direction + " [" + g_entrySignal.grade + "]\n";
      statusMsg += "• النتيجة: " + DoubleToString(g_entrySignal.totalScore, 1) + "/10.0\n";
      statusMsg += "• السعر: " + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_BID), 2) + "\n";
      statusMsg += "• الأخبار: " + g_newsStatus + "\n";
      statusMsg += "• التصدير التلقائي: " + (InpAutoExport ? "✅ مفعل" : "❌ معطل") + "\n";
      statusMsg += "• التحكم عن بُعد: " + (InpAllowRemoteControl ? "✅ مفعل" : "❌ معطل");
      SendTelegram(statusMsg);
   }
   else if(lowerCmd == "/stats" || lowerCmd == "stats" || lowerCmd == "إحصائيات") {
      string statsMsg = "📊 إحصائيات الأداء لكل درجة\n\n";
      bool hasData = false;
      for(int g = 0; g < 6; g++) {
         if(g_gradeStats[g].totalSignals > 0) {
            hasData = true;
            statsMsg += IndexToGrade(g) + ": " + 
                       IntegerToString(g_gradeStats[g].totalSignals) + " إشارة | فوز: " + 
                       DoubleToString(g_gradeStats[g].winRate, 1) + "% | " +
                       IntegerToString(g_gradeStats[g].wins) + "W/" + 
                       IntegerToString(g_gradeStats[g].losses) + "L\n";
         }
      }
      if(!hasData) statsMsg += "لا توجد بيانات كافية بعد. يتم التتبع تلقائياً.\n";
      statsMsg += "\n📈 الإجمالي: " + IntegerToString(g_totalSignals) + " إشارة | فوز: " + DoubleToString(g_winRate, 1) + "%";
      SendTelegram(statsMsg);
   }
   else if(lowerCmd == "/conflicts" || lowerCmd == "conflicts" || lowerCmd == "تعارضات") {
      if(g_layerConflict.hasConflict) {
         string conflictMsg = "⚠️ تعارضات الطبقات التحليلية\n\n";
         conflictMsg += "الشدة: " + g_layerConflict.severity + "\n";
         conflictMsg += "تخفيض الثقة: " + DoubleToString(g_layerConflict.confidenceReduction, 1) + "%\n";
         conflictMsg += "النتيجة الأصلية: " + DoubleToString(g_entrySignal.totalScore, 1) + "\n";
         conflictMsg += "النتيجة المعدّلة: " + DoubleToString(g_entrySignal.totalScore * (1.0 - g_layerConflict.confidenceReduction/100.0), 1) + "\n\n";
         for(int c = 0; c < g_layerConflict.conflictCount; c++) {
            conflictMsg += IntegerToString(c+1) + ". " + g_layerConflict.conflicts[c] + "\n";
         }
         SendTelegram(conflictMsg);
      } else {
         SendTelegram("✅ لا توجد تعارضات حالياً بين الطبقات التحليلية");
      }
   }
   else if(lowerCmd == "/backtest" || lowerCmd == "backtest" || lowerCmd == "باكتيست") {
      if(g_backtestCompleted) {
         string btMsg = "📋 نتائج الباك تيست التاريخي\n\n";
         btMsg += "الفترة: آخر 2000 شمعة (M15)\n";
         btMsg += "إجمالي الإعدادات: " + IntegerToString(g_backtestTotalSignals) + "\n";
         btMsg += "فائزة: " + IntegerToString(g_backtestWins) + "\n";
         btMsg += "خاسرة: " + IntegerToString(g_backtestLosses) + "\n";
         btMsg += "نسبة الفوز: " + DoubleToString(g_backtestWinRate, 1) + "%\n";
         btMsg += "متوسط RR: " + DoubleToString(g_backtestAvgRR, 2) + "\n\n";
         btMsg += "ملاحظة: يعتمد على كشف مبسط (ابتلاع + حجم + هيكل)";
         SendTelegram(btMsg);
      } else {
         SendTelegram("⏳ لم يكتمل الباك تيست بعد. يحتاج لبيانات كافية.");
      }
   }
   else if(lowerCmd == "/confirm" || lowerCmd == "confirm" || lowerCmd == "تأكيد") {
      if(g_pendingOrder.isActive && !g_pendingOrder.isConfirmed) {
         g_pendingOrder.isConfirmed = true;
         SendTelegram("✅ تم تأكيد الأمر - جاري التنفيذ...");
         ExecutePendingOrder();
      } else if(!g_pendingOrder.isActive) {
         SendTelegram("❌ لا يوجد أمر معلق للتأكيد");
      } else {
         SendTelegram("ℹ️ الأمر تم تأكيده مسبقاً");
      }
   }
   else if(lowerCmd == "/cancel" || lowerCmd == "cancel" || lowerCmd == "إلغاء") {
      if(g_pendingOrder.isActive) {
         g_pendingOrder.isActive = false;
         SendTelegram("❌ تم إلغاء الأمر المعلق");
      } else {
         SendTelegram("ℹ️ لا يوجد أمر معلق للإلغاء");
      }
   }
   else if(lowerCmd == "/killswitch" || lowerCmd == "killswitch" || lowerCmd == "حماية") {
      string ksMsg = "🛡️ حالة Kill Switch:\n\n";
      ksMsg += "• مفعّل: " + string(InpKillSwitchEnabled ? "نعم" : "لا") + "\n";
      ksMsg += "• الحالة: " + string(g_killSwitch.isActive ? "🔴 نشط" : "🟢 جاهز") + "\n";
      ksMsg += "• خسائر متتالية: " + IntegerToString(g_killSwitch.consecutiveLosses) + "/" + IntegerToString(InpMaxConsecutiveLoss) + "\n";
      ksMsg += "• أقصى خسائر متتالية: " + IntegerToString(g_killSwitch.maxConsecutiveLosses) + "\n";
      ksMsg += "• التراجع اليومي: " + DoubleToString(g_killSwitch.dailyDrawdown, 1) + "%/" + DoubleToString(InpMaxDrawdownPct, 1) + "%\n";
      if(g_killSwitch.isActive) {
         ksMsg += "• السبب: " + g_killSwitch.reason + "\n";
         int remaining = InpKillSwitchCooldown - (int)((TimeCurrent() - g_killSwitch.activatedTime) / 60);
         ksMsg += "• الوقت المتبقي: " + IntegerToString(MathMax(0, remaining)) + " دقيقة\n";
      }
      SendTelegram(ksMsg);
   }
   else if(lowerCmd == "/sessions" || lowerCmd == "sessions" || lowerCmd == "جلسات") {
      string sessMsg = "🕐 أداء الجلسات:\n\n";
      sessMsg += "• الجلسة الحالية: " + GetCurrentSessionName() + "\n\n";
      if(g_sessionPerf.asianSignals > 0)
         sessMsg += "آسيا: " + IntegerToString(g_sessionPerf.asianWins) + "/" + IntegerToString(g_sessionPerf.asianSignals) + " (" + DoubleToString(((double)g_sessionPerf.asianWins/g_sessionPerf.asianSignals)*100, 0) + "%)\n";
      if(g_sessionPerf.londonSignals > 0)
         sessMsg += "لندن: " + IntegerToString(g_sessionPerf.londonWins) + "/" + IntegerToString(g_sessionPerf.londonSignals) + " (" + DoubleToString(((double)g_sessionPerf.londonWins/g_sessionPerf.londonSignals)*100, 0) + "%)\n";
      if(g_sessionPerf.overlapSignals > 0)
         sessMsg += "التداخل: " + IntegerToString(g_sessionPerf.overlapWins) + "/" + IntegerToString(g_sessionPerf.overlapSignals) + " (" + DoubleToString(((double)g_sessionPerf.overlapWins/g_sessionPerf.overlapSignals)*100, 0) + "%)\n";
      if(g_sessionPerf.nySignals > 0)
         sessMsg += "نيويورك: " + IntegerToString(g_sessionPerf.nyWins) + "/" + IntegerToString(g_sessionPerf.nySignals) + " (" + DoubleToString(((double)g_sessionPerf.nyWins/g_sessionPerf.nySignals)*100, 0) + "%)\n";
      if(g_sessionPerf.bestSession != "UNKNOWN" && g_sessionPerf.bestSession != "")
         sessMsg += "\n🏆 أفضل جلسة: " + g_sessionPerf.bestSession + " (" + DoubleToString(g_sessionPerf.bestSessionWinRate, 0) + "%)";
      else
         sessMsg += "\nℹ️ لا توجد بيانات كافية بعد (تحتاج 3+ إشارات لكل جلسة)";
      SendTelegram(sessMsg);
   }
   else if(lowerCmd == "/institutional" || lowerCmd == "institutional" || lowerCmd == "مؤسسي") {
      string instMsg = "🏦 المراكز المؤسسية:\n\n";
      instMsg += "• الموقع الصافي: " + DoubleToString(g_institutional.netPositioning, 1) + "/100\n";
      instMsg += "• الاتجاه: " + g_institutional.bias + "\n";
      instMsg += "• المرحلة: " + g_institutional.phase + "\n";
      instMsg += "• نسبة الحجم: " + DoubleToString(g_institutional.volumeRatio, 2) + "x\n";
      instMsg += "• نقاط التجميع: " + DoubleToString(g_institutional.accumulationScore, 1) + "/10\n\n";
      instMsg += "📐 وايكوف المتقدم:\n";
      instMsg += "• الحدث: " + g_wyckoff.eventType + "\n";
      instMsg += "• النقاط: " + DoubleToString(g_wyckoff.eventScore, 1) + "/10\n";
      instMsg += "• المرحلة: " + g_wyckoff.phase + "\n";
      if(g_wyckoff.hasSpring) instMsg += "• ✅ Spring\n";
      if(g_wyckoff.hasUpthrust) instMsg += "• ✅ Upthrust\n";
      if(g_wyckoff.hasTestAfterSpring) instMsg += "• ✅ Test\n";
      if(g_wyckoff.hasSignOfStrength) instMsg += "• ✅ SOS\n";
      SendTelegram(instMsg);
   }
   else {
      string helpMsg = "❓ أمر غير معروف: " + cmd + "\n\nالأوامر المتاحة:\n";
      helpMsg += "▶️ /start - تشغيل\n";
      helpMsg += "⏸️ /stop - إيقاف\n";
      helpMsg += "📤 /export - تصدير التقرير\n";
      helpMsg += "ℹ️ /status - حالة النظام\n";
      helpMsg += "📊 /stats - إحصائيات الأداء\n";
      helpMsg += "⚠️ /conflicts - تعارضات الطبقات\n";
      helpMsg += "📋 /backtest - نتائج الباك تيست\n";
      helpMsg += "🛡️ /killswitch - حالة Kill Switch\n";
      helpMsg += "🕐 /sessions - أداء الجلسات\n";
      helpMsg += "🏦 /institutional - المراكز المؤسسية\n";
      if(InpSemiAutoEnabled) {
         helpMsg += "✅ /confirm - تأكيد الأمر المعلق\n";
         helpMsg += "❌ /cancel - إلغاء الأمر المعلق\n";
      }
      SendTelegram(helpMsg);
   }
}
void ProcessTelegramCommands() {
   if(!InpUseTelegram || !InpAllowRemoteControl || StringLen(InpTeleBotToken) < 10) return;
   if(TimeCurrent() - g_lastTelegramPoll < 3) return;
   g_lastTelegramPoll = TimeCurrent();
   string url = "https://api.telegram.org/bot" + StringTrim(InpTeleBotToken) + "/getUpdates";
   if(g_lastUpdateId > 0)
      url += "?offset=" + IntegerToString(g_lastUpdateId + 1) + "&limit=10";
   else
      url += "?limit=1";
   char data[], result[];
   string headers;
   int res = WebRequest("GET", url, headers, 8000, data, result, headers);
   if(res < 200 || res > 299) {
      // ✅ FIX #8: Hide bot token from error logs
      Print("Telegram poll failed. HTTP: ", res, " Error: ", GetLastError());
      return;
   }
   string response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   string idTag = "\"update_id\":";
   int pos = StringFind(response, idTag, 0);
   while(pos != -1) {
      int start = pos + StringLen(idTag);
      int end = StringFind(response, ",", start);
      if(end == -1) end = StringFind(response, "}", start);
      string idStr = StringSubstr(response, start, end - start);
      long updateId = StringToInteger(idStr);
      if(updateId > g_lastUpdateId) {
         g_lastUpdateId = updateId;
         
         // Extract chat ID for security check
         string chatIdTag = "\"chat\":{\"id\":\"";
         int chatPos = StringFind(response, chatIdTag, end);
         if(chatPos != -1) {
            int chatStart = chatPos + StringLen(chatIdTag);
            int chatEnd = StringFind(response, "\"", chatStart);
            string incomingChatId = StringSubstr(response, chatStart, chatEnd - chatStart);
            
            // Security check - only process if authorized
            if(StringLen(g_authorizedChatID) > 0 && incomingChatId != g_authorizedChatID) {
               Print("Unauthorized chat ID: ", incomingChatId, " - Ignoring command");
               return;
            }
         }
         
         string textTag = "\"text\":\"";
         int tPos = StringFind(response, textTag, end);
         if(tPos != -1) {
            int tStart = tPos + StringLen(textTag);
            int tEnd = StringFind(response, "\"", tStart);
            string cmd = StringSubstr(response, tStart, tEnd - tStart);
            // ✅ FIX #8: Don't log raw commands that might contain the token
            Print("Telegram command received: ", StringSubstr(cmd, 0, 20), "...");
            ExecuteCommand(cmd);
         }
      }
      pos = StringFind(response, idTag, end);
   }
}
//====================================================================
//  MAIN EVENTS
//====================================================================
int OnInit() {
   CreateUI();
   
   g_handle_atr = iATR(Symbol(), Period(), 14);
   g_handle_rsi = iRSI(Symbol(), Period(), 14, PRICE_CLOSE);
   g_handle_macd = iMACD(Symbol(), Period(), 12, 26, 9, PRICE_CLOSE);
   
   // ✅ FIX #5: Create multi-timeframe ATR handles
   g_handle_atr_h1 = iATR(Symbol(), PERIOD_H1, 14);
   g_handle_atr_h4 = iATR(Symbol(), PERIOD_H4, 14);
   
   // ✅ FIX #3: Create global MA handles to prevent memory leak
   g_handle_ma_d1 = iMA(Symbol(), PERIOD_D1, 200, 0, MODE_EMA, PRICE_CLOSE);
   g_handle_ma_h4 = iMA(Symbol(), PERIOD_H4, 200, 0, MODE_EMA, PRICE_CLOSE);
   g_handle_ma_d1_50 = iMA(Symbol(), PERIOD_D1, 50, 0, MODE_EMA, PRICE_CLOSE);
   g_handle_ma_d1_20 = iMA(Symbol(), PERIOD_D1, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   if(g_handle_atr == INVALID_HANDLE) {
      Print("Failed to create ATR handle");
      return INIT_FAILED;
   }
   g_isRunning = true;
   g_lastUpdateId = 0;
   
   // Initialize grade stats array (6 grades: A+++, A+, A, B, C, D)
   ArrayResize(g_gradeStats, 6);
   for(int i = 0; i < 6; i++) {
      g_gradeStats[i].totalSignals = 0;
      g_gradeStats[i].wins = 0;
      g_gradeStats[i].losses = 0;
      g_gradeStats[i].pending = 0;
      g_gradeStats[i].winRate = 0;
      g_gradeStats[i].avgPnL = 0;
      g_gradeStats[i].avgMFE = 0;
      g_gradeStats[i].avgMAE = 0;
      g_gradeStats[i].bestPnL = 0;
      g_gradeStats[i].worstPnL = 0;
   }
   
   // Initialize pending order
   g_pendingOrder.isActive = false;
   g_pendingOrder.isConfirmed = false;
   if(InpUseNewsFilter) LoadNewsCalendar();
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   g_lastTradeDay = StringToTime(IntegerToString(dt.year) + "." + 
                                 IntegerToString(dt.mon) + "." + 
                                 IntegerToString(dt.day));
   g_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("System Initialized for ", Symbol(), " - v4.2 Enhanced");
   
   // ✅ FIX #8: Security warning if authorized chat ID is empty
   if(StringLen(g_authorizedChatID) == 0 && InpAllowRemoteControl) {
      Print("[SECURITY WARNING] g_authorizedChatID is empty - any Telegram user can control this bot! Set a specific Chat ID for security.");
   }
   if(InpUseTelegram) {
      string initMsg = "✅ تم تشغيل نظام JB SMART TRADE PRO v4.2\n\n";
      initMsg += "الرمز: " + Symbol() + "\n";
      initMsg += "الإصدار: 4.2 (تحسينات البيانات + الحماية)\n\n";
      initMsg += "🚀 المميزات الجديدة (v4.2):\n";
      initMsg += "• DXY محسّن (Multi-Pair Proxy: EUR+GBP+JPY+CHF+CAD)\n";
      initMsg += "• مراكز مؤسسية (CFTC COT حقيقي + VSA)\n";
      initMsg += "• وايكوف متقدم (Spring, Upthrust, SOS, Test)\n";
      initMsg += "• ATR متعدد الأطر الزمنية لـ SL/TP\n";
      initMsg += "• Kill Switch (إيقاف بعد 3 خسائر متتالية)\n";
      initMsg += "• فلتر الجلسات (تقييد الإشارات الضعيفة)\n";
      initMsg += "• باك تيست شامل (13 طبقة + Spread + Sessions)\n";
      initMsg += "• تتبع أداء الجلسات\n\n";
      initMsg += "🎮 الأوامر المتاحة:\n";
      initMsg += "• /start - تشغيل | /stop - إيقاف\n";
      initMsg += "• /export - تصدير التقرير\n";
      initMsg += "• /status - حالة النظام\n";
      initMsg += "• /stats - إحصائيات الأداء\n";
      initMsg += "• /conflicts - تعارضات الطبقات\n";
      initMsg += "• /backtest - نتائج الباك تيست\n";
      initMsg += "• /killswitch - حالة Kill Switch\n";
      initMsg += "• /sessions - أداء الجلسات\n";
      initMsg += "• /institutional - المراكز المؤسسية\n";
      if(InpSemiAutoEnabled) {
         initMsg += "• /confirm - تأكيد | /cancel - إلغاء\n";
      }
      SendTelegram(initMsg);
      CaptureAndSendScreenshot("📸 لقطة شاشة بدء التشغيل - v4.2");
   }
   
   return INIT_SUCCEEDED;
}
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, "Nexus_");
   if(g_handle_atr != INVALID_HANDLE) IndicatorRelease(g_handle_atr);
   if(g_handle_rsi != INVALID_HANDLE) IndicatorRelease(g_handle_rsi);
   if(g_handle_macd != INVALID_HANDLE) IndicatorRelease(g_handle_macd);
   
   // ✅ FIX #5: Release multi-timeframe ATR handles
   if(g_handle_atr_h1 != INVALID_HANDLE) IndicatorRelease(g_handle_atr_h1);
   if(g_handle_atr_h4 != INVALID_HANDLE) IndicatorRelease(g_handle_atr_h4);
   
   // ✅ FIX #3: Release global MA handles
   if(g_handle_ma_d1 != INVALID_HANDLE) IndicatorRelease(g_handle_ma_d1);
   if(g_handle_ma_h4 != INVALID_HANDLE) IndicatorRelease(g_handle_ma_h4);
   if(g_handle_ma_d1_50 != INVALID_HANDLE) IndicatorRelease(g_handle_ma_d1_50);
   if(g_handle_ma_d1_20 != INVALID_HANDLE) IndicatorRelease(g_handle_ma_d1_20);
   
   if(InpUseTelegram) {
      SendTelegram("🔴 تم إيقاف نظام JB SMART TRADE PRO\nسبب الإيقاف: " + IntegerToString(reason));
   }
}
void OnTick() {
   ProcessTelegramCommands();
   ProcessTelegramQueue();
   if(InpUseNewsFilter) CheckNewsFilter();
   if(!g_isRunning || g_newsPauseActive) {
      UpdateUI();
      ChartRedraw();
      return;
   }
   if(IsNewBar(Period())) {
      // Run all analyses
      AnalyzeMacro();
      AnalyzeStructure();
      AnalyzeSmartMoney();
      AnalyzeFibonacci();
      AnalyzeWyckoff();
      AnalyzePatterns();
      AnalyzeDivergence();
      AnalyzeVolume();
      AnalyzeSession();
      AnalyzeDXY();
      AnalyzeSeasonality();
      
      // ✅ FIX #6: Added Power of 3 analysis
      if(InpUsePowerOf3) AnalyzePowerOf3();
      if(InpUseMultiTF) AnalyzeMultiTimeframe();
      if(InpUseOrderFlow) AnalyzeOrderFlow();
      AnalyzeInstitutionalPositioning();
      
      GenerateSignal_ENHANCED();
      
      // Detect layer conflicts after signal generation
      DetectLayerConflicts();
      
      // Send conflict alert if critical
      if(g_layerConflict.hasConflict && g_layerConflict.severity == "CRITICAL" && InpUseTelegram) {
         string conflictAlert = "🚨 تنبيه: تعارضات حرجة!\n\n";
         conflictAlert += "الاتجاه: " + g_entrySignal.direction + " | الدرجة: " + g_entrySignal.grade + "\n";
         conflictAlert += "تخفيض الثقة: " + DoubleToString(g_layerConflict.confidenceReduction, 1) + "%\n\n";
         for(int c = 0; c < g_layerConflict.conflictCount; c++) {
            conflictAlert += "• " + g_layerConflict.conflicts[c] + "\n";
         }
         conflictAlert += "\n⛔ يُنصح بعدم الدخول حتى تُحل التعارضات";
         SendTelegram(conflictAlert);
      }
      
      // Check semi-auto execution
      CheckSemiAutoSignal();
      CheckPendingOrderExpiry();
      
      if(InpUseBacktesting) {
         TrackSignalPerformance();
         UpdateSignalPerformance();
      }
      
      // Run historical backtest once
      if(!g_backtestCompleted) {
         RunHistoricalBacktest();
      }
      CleanupOldObjects("Nexus_OB_", 10);
      CleanupOldObjects("Nexus_FVG_", 10);
   }
   UpdateUI();
   ChartRedraw();
   if(InpAutoExport && (TimeCurrent() - g_lastExport) >= InpExportInterval * 60) {
      string engFile, arFile;
      bool exportOK = ExportTextReport(true, engFile, arFile);
      if(exportOK) {
         SendMarketSummary();
         if(StringLen(arFile) > 0) SendTelegramFile(arFile, "📤 التقرير العربي التلقائي", "sendDocument");
         if(StringLen(engFile) > 0) SendTelegramFile(engFile, "📊 تقرير البرومبت التلقائي (Prompt Report)", "sendDocument");
         CaptureAndSendScreenshot("📸 لقطة شاشة تلقائية");
      }
      g_lastExport = TimeCurrent();
   }
}
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Nexus_Btn_Export") {
      string engFile, arFile;
      bool exportOK = ExportTextReport(true, engFile, arFile);
      if(exportOK) {
         SendMarketSummary();
         if(InpUseTelegram) {
            SendTelegramAlert(g_entrySignal.direction, g_entrySignal.totalScore, g_entrySignal.grade);
            if(StringLen(arFile) > 0) SendTelegramFile(arFile, "📄 التقرير العربي - يدوي من الشارت", "sendDocument");
            if(StringLen(engFile) > 0) SendTelegramFile(engFile, "📊 تقرير البرومبت - يدوي من الشارت (Prompt Report)", "sendDocument");
            CaptureAndSendScreenshot("📸 لقطة شاشة يدوية");
         }
      }
      ObjectSetInteger(0, "Nexus_Btn_Export", OBJPROP_STATE, false);
   }
}