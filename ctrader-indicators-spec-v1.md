# cTrader Indicators Spec v1 (JB SMART TRADE)

## Goal
Build deterministic indicators that export normalized features for AI scenario generation.

## Indicator Set

### 1) `JB_StructureEngine`
Outputs:
- swing highs/lows (internal + external)
- BOS / CHoCH events
- protected highs/lows
- current bias (`bullish`, `bearish`, `neutral`)

Core params:
- `swingStrengthInternal` (default 2)
- `swingStrengthExternal` (default 5)
- `closeBreakOnly` (default true)
- `minDisplacementATR` (default 1.2)

### 2) `JB_LiquidityMapper`
Outputs:
- equal highs/lows clusters
- previous day/week/month high-low
- asian range high/low
- nearest buyside/sellside liquidity levels
- sweep flags

Core params:
- `equalTolerancePips`
- `asianSessionStartNY`, `asianSessionEndNY`
- `maxTaggedPools`

### 3) `JB_PDMatrix`
Outputs:
- active dealing range
- equilibrium (50%)
- premium/discount classification
- OTE zone (0.62 - 0.79)

Core params:
- `rangeMode` (`externalSwing`, `manual`, `hybrid`)
- `oteLow` default 0.62
- `oteHigh` default 0.79

### 4) `JB_POIEngine`
Outputs:
- valid FVG zones
- valid OB zones
- breaker/mitigation candidates
- POI quality score (0-100)

Core params:
- `fvgMinSizePips`
- `requireDisplacement` (default true)
- `obUseBodyOnly` (default true)
- `obMaxMitigationPercent` (default 50)

### 5) `JB_SessionRiskFilter`
Outputs:
- active session / killzone state
- spread state (`normal`, `elevated`, `high`)
- volatility regime (ATR-based)
- tradable flag

Core params:
- session definitions (NY time)
- spread thresholds
- ATR period and thresholds

### 6) `JB_SetupScorer`
Consumes outputs from all indicators and returns:
- total score /100
- per-factor score breakdown
- setup class (`A+`, `A`, `B`, `NoTrade`)
- recommended execution mode (`confirmation`, `limit`, `skip`)

## Data Export Contract
Each indicator must expose a feature object serialized to JSON:
- timestamp (UTC)
- symbol
- timeframe
- features
- version

Transport options:
- file append (`jsonl`)
- named pipe
- local HTTP bridge (if allowed in environment)

## Validation Rules
- no repaint on closed bars for structural events
- all signals computed with explicit bar index references
- deterministic output under same history
- include `isConfirmed` flag for any still-forming zone

## Build Order
1. `JB_StructureEngine`
2. `JB_LiquidityMapper`
3. `JB_PDMatrix`
4. `JB_POIEngine`
5. `JB_SessionRiskFilter`
6. `JB_SetupScorer`

## Acceptance Criteria
- 3 months backtest replay consistency
- stable feature output across reruns
- no trade signals outside configured sessions
- score distribution meaningful (not clustered at extremes)
