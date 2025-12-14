# NAUTILUS GOLD SCALPER - FIXES ACTION PLAN
**Date**: 2025-12-03  
**Review**: Based on comprehensive code review  
**Target**: Production readiness in 3-4 weeks  

---

## P0 - CRITICAL BLOCKERS (Week 1)

### 1. Implement Tradovate API Integration [apex_adapter.py]
**Blocker**: Cannot execute live trades without this  
**Effort**: 16-20 hours  

**Files to modify**:
- `nautilus_gold_scalper/src/execution/apex_adapter.py`

**Tasks**:
- [ ] Implement OAuth authentication flow
- [ ] Implement REST API calls (orders, positions, account)
- [ ] Implement WebSocket connection for real-time updates
- [ ] Add request signing (HMAC)
- [ ] Test with Tradovate demo account

**Code template**:
```python
async def _authenticate(self) -> bool:
    """Authenticate with Tradovate API."""
    async with aiohttp.ClientSession() as session:
        async with session.post(
            f"{self.config.rest_url}/auth/accessTokenRequest",
            json={
                "name": self.config.api_key,
                "password": self.config.api_secret,
                "appId": "NautilusGoldScalper",
                "appVersion": "1.0",
                "deviceId": "device001",
                "cid": 1
            }
        ) as response:
            if response.status == 200:
                data = await response.json()
                self._access_token = data.get("accessToken")
                self._token_expiry = datetime.now() + timedelta(hours=24)
                return True
    return False
```

**Dependencies**:
- `aiohttp` (for async HTTP)
- `websockets` (for WebSocket)
- Tradovate API documentation

**Test criteria**:
- ✅ Authentication succeeds with valid credentials
- ✅ Orders submitted successfully to demo account
- ✅ WebSocket receives real-time position updates
- ✅ Account balance updates correctly

---

### 2. Replace Pickle with ONNX [model_trainer.py, ensemble_predictor.py]
**Blocker**: Security vulnerability (arbitrary code execution)  
**Effort**: 8-12 hours  

**Files to modify**:
- `nautilus_gold_scalper/src/ml/model_trainer.py`
- `nautilus_gold_scalper/src/ml/ensemble_predictor.py`

**Tasks**:
- [ ] Install `onnxmltools`, `skl2onnx`
- [ ] Implement ONNX export in `ModelTrainer._save_model()`
- [ ] Implement ONNX loading in `ModelTrainer.load_model()`
- [ ] Update `EnsemblePredictor.save()` to use JSON + ONNX
- [ ] Test model persistence round-trip

**Code template**:
```python
def _save_model(self, model: Any, model_type: str) -> str:
    """Save model to ONNX format."""
    from skl2onnx import to_onnx
    from skl2onnx.common.data_types import FloatTensorType
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{model_type}_{timestamp}.onnx"
    filepath = Path(self.config.model_dir) / filename
    
    # Define input type (n_features from training)
    n_features = model.n_features_in_ if hasattr(model, 'n_features_in_') else 50
    initial_type = [('float_input', FloatTensorType([None, n_features]))]
    
    # Convert to ONNX
    onnx_model = to_onnx(model, initial_types=initial_type, target_opset=12)
    
    # Save
    with open(filepath, "wb") as f:
        f.write(onnx_model.SerializeToString())
    
    return str(filepath)
```

**Dependencies**:
- `onnx`, `onnxruntime`
- `onnxmltools`, `skl2onnx`

**Test criteria**:
- ✅ Model saves to ONNX without errors
- ✅ Loaded model predictions match original
- ✅ No pickle files remain
- ✅ Security scan passes

---

### 3. Move Credentials to Environment [apex_adapter.py]
**Blocker**: Credentials hardcoded/plaintext  
**Effort**: 2 hours  

**Files to modify**:
- `nautilus_gold_scalper/src/execution/apex_adapter.py`
- Create `.env.example`

**Tasks**:
- [ ] Install `python-dotenv`
- [ ] Load credentials from environment variables
- [ ] Create `.env.example` template
- [ ] Update documentation

**Code template**:
```python
from dotenv import load_dotenv
import os

class ApexAdapterConfig:
    def __init__(self):
        load_dotenv()
        
        self.api_key = os.getenv("APEX_API_KEY", "")
        self.api_secret = os.getenv("APEX_API_SECRET", "")
        self.account_id = os.getenv("APEX_ACCOUNT_ID", "")
        
        if not all([self.api_key, self.api_secret, self.account_id]):
            raise ValueError("Missing required environment variables")
```

**.env.example**:
```bash
# Apex/Tradovate API Credentials
APEX_API_KEY=your_api_key_here
APEX_API_SECRET=your_api_secret_here
APEX_ACCOUNT_ID=your_account_id_here

# API URLs
APEX_REST_URL=https://demo.tradovate.com/v1
APEX_WS_URL=wss://demo.tradovate.com/v1/websocket
```

**Test criteria**:
- ✅ Credentials loaded from .env
- ✅ Error raised if credentials missing
- ✅ No credentials in git history

---

### 4. Initialize Missing Members [base_strategy.py]
**Blocker**: AttributeError on first trade  
**Effort**: 1 hour  

**File to modify**:
- `nautilus_gold_scalper/src/strategies/base_strategy.py`

**Fix**:
```python
# Line 75 - Add to __init__
def __init__(self, config: BaseStrategyConfig):
    super().__init__(config=config)
    
    self.instrument: Optional[Instrument] = None
    
    # Bar storage
    self._htf_bars: List[Bar] = []
    self._mtf_bars: List[Bar] = []
    self._ltf_bars: List[Bar] = []
    
    # State tracking
    self._position: Optional[Position] = None
    self._daily_trades: int = 0
    self._daily_pnl: float = 0.0
    self._is_trading_allowed: bool = True
    
    # ADD THESE:
    self._pending_sl: Optional[Price] = None
    self._pending_tp: Optional[Price] = None
    
    # Current analysis results
    self._current_regime: Optional[RegimeAnalysis] = None
    self._current_session: Optional[SessionInfo] = None
    self._last_confluence: Optional[ConfluenceResult] = None
```

**Test criteria**:
- ✅ All attributes accessible
- ✅ No AttributeError on initialization
- ✅ Unit test passes

---

### 5. Add Analyzer Health Checks [gold_scalper_strategy.py]
**Blocker**: Silent failures during initialization  
**Effort**: 2 hours  

**File to modify**:
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`

**Fix**:
```python
def _on_strategy_start(self) -> None:
    """Initialize all analyzers and managers."""
    # ... existing initialization ...
    
    # Health checks
    required_components = {
        "session_filter": self._session_filter,
        "regime_detector": self._regime_detector,
        "structure_analyzer": self._structure_analyzer,
        "ob_detector": self._ob_detector,
        "fvg_detector": self._fvg_detector,
        "sweep_detector": self._sweep_detector,
        "amd_tracker": self._amd_tracker,
        "mtf_manager": self._mtf_manager,
        "confluence_scorer": self._confluence_scorer,
    }
    
    failed = []
    for name, component in required_components.items():
        if component is None:
            failed.append(name)
    
    if failed:
        self.log.error(f"Failed to initialize: {', '.join(failed)}")
        self.stop()
        return
    
    self.log.info("All analyzers initialized and validated")
```

**Test criteria**:
- ✅ Strategy stops if any component fails
- ✅ Clear error message logged
- ✅ No silent failures

---

## P1 - CRITICAL (Week 2)

### 6. Create Unit Test Suite
**Critical**: No tests = production risk  
**Effort**: 20-24 hours  

**Structure**:
```
nautilus_gold_scalper/tests/
├── __init__.py
├── conftest.py  # Pytest fixtures
├── test_trade_manager.py  # Start here (best module)
├── test_confluence_scorer.py
├── test_mtf_manager.py
├── test_ensemble_predictor.py
├── test_model_trainer.py
├── test_gold_scalper_strategy.py
├── test_base_strategy.py
└── test_apex_adapter.py  # Mock API calls
```

**Priority order**:
1. ✅ test_trade_manager.py (reference implementation)
2. ✅ test_confluence_scorer.py (core logic)
3. ✅ test_model_trainer.py (ML infrastructure)
4. ⚠️ test_mtf_manager.py
5. ⚠️ test_ensemble_predictor.py
6. ⚠️ test_apex_adapter.py (with mocks)
7. ⚠️ test_base_strategy.py
8. ⚠️ test_gold_scalper_strategy.py

**Example test**:
```python
# tests/test_trade_manager.py
import pytest
from decimal import Decimal
from nautilus_gold_scalper.src.execution.trade_manager import TradeManager, Direction

def test_create_trade_success():
    manager = TradeManager()
    
    trade = manager.create_trade(
        direction=Direction.LONG,
        entry_price=2000.0,
        stop_loss=1995.0,
        take_profit=2010.0,
        quantity=Decimal("1.0"),
        reason="Test trade"
    )
    
    assert trade is not None
    assert trade.direction == Direction.LONG
    assert trade.entry_price == 2000.0
    assert trade.risk_per_unit == 5.0  # |2000 - 1995|

def test_create_trade_invalid_sl():
    manager = TradeManager()
    
    with pytest.raises(ValueError, match="SL.*must be below entry"):
        manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=2005.0,  # Invalid: SL above entry for LONG
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )
```

**Test coverage target**: 70% minimum

**Dependencies**:
- `pytest`
- `pytest-asyncio` (for async tests)
- `pytest-cov` (coverage reports)
- `pytest-mock` (for mocking)

---

### 7. Fix Silent Exceptions [mtf_manager.py, ensemble_predictor.py]
**Critical**: Hidden failures = undetected bugs  
**Effort**: 4 hours  

**Files to modify**:
- `nautilus_gold_scalper/src/signals/mtf_manager.py`
- `nautilus_gold_scalper/src/ml/ensemble_predictor.py`

**Fix pattern**:
```python
# OLD (BAD)
try:
    result = analyze_data(data)
except Exception:
    return None  # Silent failure

# NEW (GOOD)
try:
    result = analyze_data(data)
except ValueError as e:
    logger.error(f"Validation error in analysis: {e}")
    return None
except Exception as e:
    logger.exception(f"Unexpected error in analysis: {e}")
    return None
```

**Test criteria**:
- ✅ All exceptions logged
- ✅ Log level appropriate (error vs warning)
- ✅ Stack trace included for unexpected errors

---

### 8. Add Model Interface Validation [ensemble_predictor.py]
**Critical**: Prevent runtime errors from invalid models  
**Effort**: 2 hours  

**File to modify**:
- `nautilus_gold_scalper/src/ml/ensemble_predictor.py`

**Fix**:
```python
def add_model(self, name: str, model: Any, weight: Optional[float] = None) -> None:
    """Add a model to the ensemble with validation."""
    # Validate model has required methods
    if not hasattr(model, 'predict'):
        raise ValueError(f"Model {name} must have 'predict' method")
    
    if not hasattr(model, 'predict_proba'):
        logger.warning(f"Model {name} lacks 'predict_proba', will use predict instead")
    
    # Validate model is fitted
    if hasattr(model, 'n_features_in_'):
        if model.n_features_in_ <= 0:
            raise ValueError(f"Model {name} appears unfitted (n_features_in_ = {model.n_features_in_})")
    
    self._models[name] = model
    # ... rest of method
```

**Test criteria**:
- ✅ Rejects models without predict method
- ✅ Warns about missing predict_proba
- ✅ Rejects unfitted models

---

## P2 - HIGH (Week 3)

### 9. Refactor Complex Methods [gold_scalper_strategy.py]
**High**: Maintainability and testability  
**Effort**: 8 hours  

**Method**: `_check_for_signal` (100+ lines)

**Refactoring plan**:
```python
# Break into smaller methods:
def _check_for_signal(self, bar: Bar) -> None:
    if not self._pre_trade_checks():
        return
    
    confluence = self._calculate_confluence(bar)
    if not self._is_signal_valid(confluence):
        return
    
    self._execute_signal(confluence, bar)

def _pre_trade_checks(self) -> bool:
    """Pre-trade validation."""
    if not self._is_trading_allowed:
        return False
    if not self.is_flat:
        return False
    if not self._check_session():
        return False
    if not self._check_spread():
        return False
    if not self._check_risk_limits():
        return False
    return True

def _is_signal_valid(self, confluence: Optional[ConfluenceResult]) -> bool:
    """Validate signal quality."""
    if confluence is None:
        return False
    if confluence.score < self.config.execution_threshold:
        if self.config.debug_mode:
            self.log.debug(f"Score {confluence.score:.1f} below threshold")
        return False
    if confluence.signal == SignalType.SIGNAL_NONE:
        return False
    return True

def _execute_signal(self, confluence: ConfluenceResult, bar: Bar) -> None:
    """Execute validated signal."""
    # Position sizing
    sl_distance = self._calculate_sl_distance(bar, confluence.signal)
    if sl_distance <= 0:
        return
    
    quantity = self._calculate_position_size(sl_distance)
    if quantity is None or float(quantity) <= 0:
        return
    
    # Execute trade
    self._submit_trade(confluence.signal, bar, sl_distance, quantity)
```

**Benefits**:
- Each method < 20 lines
- Easier to test individually
- Clear separation of concerns

---

### 10. Add Connection Health Monitoring [apex_adapter.py]
**High**: Detect and recover from connection failures  
**Effort**: 6 hours  

**Implementation**:
```python
class ApexAdapter:
    def __init__(self, config: Optional[ApexAdapterConfig] = None):
        # ... existing ...
        self._last_heartbeat: Optional[datetime] = None
        self._heartbeat_task: Optional[asyncio.Task] = None
        self._reconnect_count: int = 0
    
    async def _start_heartbeat(self) -> None:
        """Send periodic heartbeat to check connection."""
        while self._connection_state == ConnectionState.CONNECTED:
            try:
                # Send heartbeat (Tradovate specific)
                await self._send_heartbeat()
                self._last_heartbeat = datetime.now(timezone.utc)
                await asyncio.sleep(30)  # Every 30 seconds
            except Exception as e:
                logger.error(f"Heartbeat failed: {e}")
                await self._handle_disconnect()
                break
    
    async def _handle_disconnect(self) -> None:
        """Handle connection loss and attempt reconnect."""
        self._connection_state = ConnectionState.RECONNECTING
        
        for attempt in range(self.config.reconnect_attempts):
            logger.info(f"Reconnect attempt {attempt + 1}/{self.config.reconnect_attempts}")
            await asyncio.sleep(self.config.reconnect_delay_seconds)
            
            if await self.connect():
                logger.info("Reconnection successful")
                return
        
        logger.error("Reconnection failed - manual intervention required")
        self._connection_state = ConnectionState.ERROR
```

**Test criteria**:
- ✅ Heartbeat sent every 30 seconds
- ✅ Reconnect triggered on failure
- ✅ Exponential backoff on retry
- ✅ Alert on permanent failure

---

## P3 - MEDIUM (Week 4)

### 11-15. Code Quality Improvements
- Input validations
- DRY violations fixes
- Extract magic numbers to constants
- Add debug logging
- Normalize weights on initialization

**Effort**: 12 hours total

---

## TESTING STRATEGY

### Unit Tests (Week 2)
```bash
cd nautilus_gold_scalper
pytest tests/ -v --cov=src --cov-report=html
# Target: >70% coverage
```

### Integration Tests (Week 3)
```python
# tests/integration/test_full_strategy.py
async def test_strategy_lifecycle():
    """Test full strategy lifecycle with mock data."""
    strategy = GoldScalperStrategy(config)
    await strategy.on_start()
    
    # Feed bars
    for bar in test_bars:
        await strategy.on_bar(bar)
    
    await strategy.on_stop()
    
    assert strategy._daily_trades > 0
    assert strategy._daily_pnl != 0.0
```

### Paper Trading (Week 4)
```python
# Connect to Tradovate demo account
adapter = ApexAdapter(ApexAdapterConfig(
    api_key=os.getenv("DEMO_API_KEY"),
    rest_url="https://demo.tradovate.com/v1"
))

# Run strategy for 1 week
# Monitor: trades, fills, P&L, errors
```

---

## SUCCESS CRITERIA

### Week 1 (P0 Blockers)
- ✅ Can authenticate with Tradovate
- ✅ Can submit orders to demo account
- ✅ Models load from ONNX (not pickle)
- ✅ No credentials in code

### Week 2 (P1 Critical)
- ✅ Unit tests exist for all modules
- ✅ Test coverage >70%
- ✅ All exceptions logged
- ✅ No silent failures

### Week 3 (Integration)
- ✅ Paper trading runs without crashes
- ✅ Orders execute correctly
- ✅ Risk limits enforced
- ✅ Performance <50ms per tick

### Week 4 (Production Ready)
- ✅ 1 week of stable paper trading
- ✅ No critical bugs found
- ✅ Documentation complete
- ✅ Security audit passed

---

## RISK MITIGATION

### Risk 1: Tradovate API complexity
**Mitigation**: Start with demo account, extensive testing

### Risk 2: ONNX conversion issues
**Mitigation**: Keep pickle as fallback temporarily, validate predictions match

### Risk 3: Performance degradation
**Mitigation**: Profile before/after, benchmark critical paths

### Risk 4: Silent failures in production
**Mitigation**: Comprehensive logging, alerting, health checks

---

## NEXT STEPS

1. **Immediate** (Today):
   - Review this action plan
   - Set up development environment
   - Create feature branch: `fix/nautilus-blockers`

2. **Day 1-2**:
   - Start P0.1 (Tradovate API) - highest impact
   - Set up Tradovate demo account

3. **Day 3-4**:
   - Continue P0.1
   - Start P0.2 (ONNX) in parallel

4. **Day 5**:
   - Complete P0.1, P0.2, P0.3, P0.4, P0.5
   - Code review
   - Create PR

5. **Week 2**:
   - Start P1 (tests)
   - Daily check-ins on progress

---

**Owner**: FORGE / NAUTILUS  
**Tracking**: DOCS/02_IMPLEMENTATION/PROGRESS.md  
**Review**: Daily standups  
