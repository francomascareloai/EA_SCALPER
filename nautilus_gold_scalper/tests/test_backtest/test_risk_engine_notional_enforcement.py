from __future__ import annotations

from nautilus_gold_scalper.scripts.backtest.run_backtest import create_xauusd_instrument
from nautilus_trader.common.component import MessageBus, TestClock
from nautilus_trader.config import ExecEngineConfig, RiskEngineConfig
from nautilus_trader.execution.engine import ExecutionEngine
from nautilus_trader.execution.messages import SubmitOrder
from nautilus_trader.model.currencies import USD
from nautilus_trader.model.enums import AccountType, OrderSide, OrderStatus
from nautilus_trader.model.identifiers import AccountId, ClientId, Venue
from nautilus_trader.model.objects import Quantity
from nautilus_trader.portfolio.portfolio import Portfolio
from nautilus_trader.risk.engine import RiskEngine
from nautilus_trader.test_kit.mocks.exec_clients import MockExecutionClient
from nautilus_trader.test_kit.stubs.data import TestDataStubs
from nautilus_trader.test_kit.stubs.events import TestEventStubs
from nautilus_trader.test_kit.stubs.identifiers import TestIdStubs
from nautilus_trader.trading.strategy import Strategy


def test_risk_engine_denies_market_order_over_max_notional_for_xauusd() -> None:
    """Ensure RiskEngineConfig.max_notional_per_order is actually enforced.

    This is a focused integration test:
    - Build RiskEngine with a small max_notional for XAU/USD
    - Provide a QuoteTick so notional can be computed
    - Submit an oversized market order
    - Assert the order is DENIED before reaching execution engine
    """

    clock = TestClock()
    trader_id = TestIdStubs.trader_id()
    msgbus = MessageBus(trader_id=trader_id, clock=clock)

    from nautilus_trader.test_kit.stubs.component import TestComponentStubs

    cache = TestComponentStubs.cache()

    portfolio = Portfolio(msgbus=msgbus, cache=cache, clock=clock)

    exec_engine = ExecutionEngine(
        msgbus=msgbus,
        cache=cache,
        clock=clock,
        config=ExecEngineConfig(debug=True),
    )

    venue = Venue("SIM")
    exec_client = MockExecutionClient(
        client_id=ClientId(venue.value),
        venue=venue,
        account_type=AccountType.CASH,
        base_currency=USD,
        msgbus=msgbus,
        cache=cache,
        clock=clock,
    )
    portfolio.update_account(TestEventStubs.cash_account_state(AccountId("SIM-001")))
    exec_engine.register_client(exec_client)

    instrument = create_xauusd_instrument(venue)
    cache.add_instrument(instrument)

    # Ensure there is market data for notional computation.
    quote = TestDataStubs.quote_tick(
        instrument=instrument,
        bid_price=1900.00,
        ask_price=1900.10,
    )
    cache.add_quote_tick(quote)

    # Configure max notional absurdly low so any realistic quantity fails.
    risk_cfg = RiskEngineConfig(
        bypass=False,
        max_order_submit_rate="100/00:00:01",
        max_order_modify_rate="100/00:00:01",
        max_notional_per_order={str(instrument.id): 100},
        debug=False,
    )

    risk_engine = RiskEngine(
        portfolio=portfolio,
        msgbus=msgbus,
        cache=cache,
        clock=clock,
        config=risk_cfg,
    )

    exec_engine.start()

    strategy = Strategy()
    strategy.register(
        trader_id=trader_id,
        portfolio=portfolio,
        msgbus=msgbus,
        cache=cache,
        clock=clock,
    )

    # Quantity is in XAU (oz). Use >= 1.00 oz (see create_xauusd_instrument min_quantity).
    order = strategy.order_factory.market(
        instrument.id,
        OrderSide.BUY,
        Quantity.from_str("1.00"),
    )

    submit = SubmitOrder(
        trader_id=trader_id,
        strategy_id=strategy.id,
        position_id=None,
        order=order,
        command_id=TestIdStubs.uuid(),
        ts_init=clock.timestamp_ns(),
    )

    risk_engine.execute(submit)

    assert order.status == OrderStatus.DENIED
    assert exec_engine.command_count == 0
