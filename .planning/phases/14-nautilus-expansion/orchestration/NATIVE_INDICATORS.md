# NautilusTrader — Native Indicators (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (native indicators scan)
Purpose: Preserve complete scope for later implementation work.

Note: This annex preserves the explorer’s full list and usage snippets; implementation should selectively integrate with our strategy architecture.

---

## VOLATILITY

### BollingerBands
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 166)
- Provides: `upper`, `middle`, `lower`
- Uses typical price: `(high + low + close)/3`

```python
from nautilus_trader.indicators import BollingerBands, MovingAverageType
bb = BollingerBands(period=20, k=2.0, ma_type=MovingAverageType.SIMPLE)
bb.handle_bar(bar)
```

### KeltnerChannel
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 418)
- Provides: `upper`, `middle`, `lower`

```python
from nautilus_trader.indicators import KeltnerChannel
kc = KeltnerChannel(period=20, k_multiplier=2.0)
kc.handle_bar(bar)
```

### KeltnerPosition
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 738)
- Provides: `value`

```python
from nautilus_trader.indicators import KeltnerPosition
kp = KeltnerPosition(period=20, k_multiplier=2.0)
kp.handle_bar(bar)
```

### DonchianChannel
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 305)

```python
from nautilus_trader.indicators import DonchianChannel
dc = DonchianChannel(period=20)
dc.handle_bar(bar)
```

### VolatilityRatio
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 622)

```python
from nautilus_trader.indicators import VolatilityRatio
vr = VolatilityRatio(fast_period=5, slow_period=20)
vr.handle_bar(bar)
```

### VerticalHorizontalFilter (VHF)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volatility.pyx` (line 537)

```python
from nautilus_trader.indicators import VerticalHorizontalFilter
vhf = VerticalHorizontalFilter(period=20)
vhf.handle_bar(bar)
```

---

## MOMENTUM

### RelativeStrengthIndex (RSI)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 52)
- Note: `value` is 0–1 (multiply by 100 for 0–100 scale)

```python
from nautilus_trader.indicators import RelativeStrengthIndex, MovingAverageType
rsi = RelativeStrengthIndex(period=14, ma_type=MovingAverageType.EXPONENTIAL)
rsi.handle_bar(bar)
```

### Stochastics
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 333)

```python
from nautilus_trader.indicators import Stochastics
stoch = Stochastics(period_k=14, period_d=3, slowing=3)
stoch.handle_bar(bar)
```

### CommodityChannelIndex (CCI)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 539)

```python
from nautilus_trader.indicators import CommodityChannelIndex
cci = CommodityChannelIndex(period=20, scalar=0.015)
cci.handle_bar(bar)
```

### ChandeMomentumOscillator (CMO)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 220)

```python
from nautilus_trader.indicators import ChandeMomentumOscillator
cmo = ChandeMomentumOscillator(period=14)
cmo.handle_bar(bar)
```

### RateOfChange (ROC)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 152)

```python
from nautilus_trader.indicators import RateOfChange
roc = RateOfChange(period=10, use_log=False)
roc.handle_bar(bar)
```

### EfficiencyRatio (Kaufman)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 650)

```python
from nautilus_trader.indicators import EfficiencyRatio
er = EfficiencyRatio(period=10)
er.handle_bar(bar)
```

### RelativeVolatilityIndex (RVI)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 728)

```python
from nautilus_trader.indicators import RelativeVolatilityIndex
rvi = RelativeVolatilityIndex(period=14, scalar=100.0)
rvi.handle_bar(bar)
```

### PsychologicalLine
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/momentum.pyx` (line 846)

```python
from nautilus_trader.indicators import PsychologicalLine
pl = PsychologicalLine(period=12)
pl.handle_bar(bar)
```

---

## TREND

### MovingAverageConvergenceDivergence (MACD)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 351)

```python
from nautilus_trader.indicators import MovingAverageConvergenceDivergence, MovingAverageType
macd = MovingAverageConvergenceDivergence(
    fast_period=12,
    slow_period=26,
    ma_type=MovingAverageType.EXPONENTIAL,
)
macd.handle_bar(bar)
```

### DirectionalMovement (DMI)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 251)

```python
from nautilus_trader.indicators import DirectionalMovement
dmi = DirectionalMovement(period=14)
dmi.handle_bar(bar)
```

### AroonOscillator
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 164)

```python
from nautilus_trader.indicators import AroonOscillator
aroon = AroonOscillator(period=25)
aroon.handle_bar(bar)
```

### LinearRegression
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 471)

```python
from nautilus_trader.indicators import LinearRegression
lr = LinearRegression(period=20)
lr.handle_bar(bar)
```

### Bias
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 570)

```python
from nautilus_trader.indicators import Bias
bias = Bias(period=20)
bias.handle_bar(bar)
```

### ArcherMovingAveragesTrends
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/trend.pyx` (line 58)

```python
from nautilus_trader.indicators import ArcherMovingAveragesTrends
amat = ArcherMovingAveragesTrends(fast_period=8, slow_period=21, signal_period=13)
amat.handle_bar(bar)
```

---

## VOLUME

### OnBalanceVolume (OBV)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volume.pyx` (line 52)

```python
from nautilus_trader.indicators import OnBalanceVolume
obv = OnBalanceVolume(period=0)
obv.handle_bar(bar)
```

### VolumeWeightedAveragePrice (VWAP)
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volume.pyx` (line 133)

```python
from nautilus_trader.indicators import VolumeWeightedAveragePrice
vwap = VolumeWeightedAveragePrice()
vwap.handle_bar(bar)
```

### KlingerVolumeOscillator
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volume.pyx` (line 213)

```python
from nautilus_trader.indicators import KlingerVolumeOscillator
kvo = KlingerVolumeOscillator(fast_period=34, slow_period=55, signal_period=13)
kvo.handle_bar(bar)
```

### Pressure
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/volume.pyx` (line 333)

```python
from nautilus_trader.indicators import Pressure
pressure = Pressure(period=14)
pressure.handle_bar(bar)
```

---

## MOVING AVERAGES

**File (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/averages.pyx`

Factory pattern (as captured)
```python
from nautilus_trader.indicators import MovingAverageFactory, MovingAverageType
ema = MovingAverageFactory.create(20, MovingAverageType.EXPONENTIAL)
hull = MovingAverageFactory.create(20, MovingAverageType.HULL)
ama = MovingAverageFactory.create(10, MovingAverageType.ADAPTIVE)
```

---

## CANDLE PATTERN ANALYSIS

### FuzzyCandlesticks
- File: `/home/franco/projetos/nautilus_trader/nautilus_trader/indicators/fuzzy_candlesticks.pyx`
- Provides: `value` (FuzzyCandle), `vector`

```python
from nautilus_trader.indicators import FuzzyCandlesticks
fuzzy = FuzzyCandlesticks(period=20)
fuzzy.handle_bar(bar)
```

---

## Usage patterns (as captured)

### Method 1: Auto-registration
```python
def on_start(self):
    self.bb = BollingerBands(20, 2.0)
    self.register_indicator_for_bars(self.bar_type, self.bb)

def on_bar(self, bar: Bar):
    if self.bb.initialized:
        print(f"Upper: {self.bb.upper}, Lower: {self.bb.lower}")
```

### Method 2: Manual update
```python
def on_bar(self, bar: Bar):
    self.bb.handle_bar(bar)
```

---

## Top recommendations (as captured)

1) KeltnerPosition
2) BollingerBands
3) VWAP
4) RSI
5) Stochastics
6) Pressure
7) MACD
8) LinearRegression
9) EfficiencyRatio
10) FuzzyCandlesticks
