# JB SMART TRADE - Unified Playbook v1 (XAUUSD)

## Scope
- Market: `XAUUSD`
- Platform: `cTrader`
- Execution style: semi-automatic (indicators + AI decision support)
- Primary sessions: London and New York killzones

## Core Decision Stack (in order)
1. **HTF Bias** (`H4` -> `H1`)
2. **Liquidity Targeting** (external/internal liquidity)
3. **PD Context** (Premium/Discount + Equilibrium)
4. **POI Quality** (`FVG`, `OB`, `Breaker/Mitigation`)
5. **Time Filter** (killzone and session behavior)
6. **Risk Filter** (news, spread, volatility, RR)

## Mechanical Rules

### 1) HTF Bias
- Bullish bias if:
  - `CHoCH` up then confirmed by bullish `BOS`
  - Price closes above protected high
- Bearish bias if:
  - `CHoCH` down then confirmed by bearish `BOS`
  - Price closes below protected low
- No-trade if structure is mixed.

### 2) Liquidity Map
- Tag:
  - previous day/week high-low
  - equal highs/lows
  - Asian range high/low
  - clear swing highs/lows
- Prefer entries after sweep of opposing-side liquidity.

### 3) Premium/Discount
- Build dealing range from last valid swing low-high (or high-low).
- Buy model only in `Discount` (< 50%).
- Sell model only in `Premium` (> 50%).
- Extra confidence when entry is in OTE zone (`0.62` to `0.79` retracement).

### 4) POI Validation
- **FVG valid** when:
  - 3-candle gap exists
  - created by displacement
  - not fully invalidated before trigger
  - aligned with HTF bias
- **OB valid** when:
  - last opposite candle before displacement + BOS
  - near liquidity/POI
  - shallow mitigation preferred (< 50% penetration)
- **Breaker/Mitigation** used only after structure transition evidence.

### 5) Time Filter
- Trade window:
  - London killzone
  - NY AM killzone
- Avoid:
  - dead hours
  - pre-news / immediate post high-impact releases

### 6) Entry Model (default)
- Primary: `Confirmation Entry`
  - price reaches HTF POI
  - LTF CHoCH + BOS confirmation
  - execute on refined LTF OB/FVG retest
- Alternative: limit entry only for top-score setups.

## Risk Model
- Base risk: `0.5%`
- Max risk: `2.0%`
- Required minimum RR: `1:2.5`
- Stop: beyond invalidation (protected swing or POI failure)
- Targeting:
  - TP1 at nearest opposing liquidity
  - TP2 at external liquidity
  - TP3 runner by structure

## Setup Scoring (100)
- HTF structure/bias: 30
- Liquidity alignment: 20
- PD location: 15
- POI quality (FVG/OB): 20
- Session timing: 10
- News/volatility safety: 5

Execution policy:
- `<70`: no trade
- `70-79`: reduced size
- `80-89`: normal size
- `90+`: A+ setup

## Operational Workflow
1. Build HTF narrative
2. Mark liquidity pools
3. Mark dealing range + PD state
4. Validate POIs
5. Apply session/news filters
6. Compute score
7. Generate AI scenario
8. Execute only if checklist passes

## Pre-Trade Checklist
- Bias confirmed (CHoCH + BOS)?
- Opposing liquidity swept?
- Entry in correct PD zone?
- Valid POI present?
- Killzone active?
- No high-impact news conflict?
- RR >= 2.5?
- Risk within allowed limits?
