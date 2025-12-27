"""
Human Behavior Simulator as Nautilus ExecAlgorithm.

FUTURE ENHANCEMENT: This is a stub for migrating HumanBehaviorSimulator to
Nautilus native ExecAlgorithm framework.

Benefits of ExecAlgorithm approach:
- Cleaner integration with Nautilus execution pipeline
- Automatic order tracking via framework
- Easier testing with standardized interfaces
- Reusable across strategies

Current Status: STUB - not yet implemented
The existing human_simulator.py (Actor-based) remains the active implementation.

See: /home/franco/.claude/plans/composed-brewing-wombat.md Phase 5

Migration Plan:
1. Create HBSConfig extending ExecAlgorithmConfig
2. Implement execute() to intercept orders and add delays
3. Use clock timers for delayed submission
4. Port all 18+ humanization techniques from human_simulator.py
5. Verify backtest parity with Actor implementation
6. Switch strategies to use exec_algorithm_id
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    pass

# Placeholder for future implementation
# from nautilus_trader.execution.algorithm import ExecAlgorithm, ExecAlgorithmConfig
# from nautilus_trader.execution.messages import SubmitOrder
# from nautilus_trader.core.datetime import secs_to_millis
# from nautilus_trader.model.identifiers import ExecAlgorithmId, ClientOrderId
# from datetime import timedelta
# import random


# class HBSConfig(ExecAlgorithmConfig, frozen=True):
#     """Configuration for Human Behavior Simulator ExecAlgorithm."""
#
#     min_delay_ms: int = 50
#     max_delay_ms: int = 500
#     enable_price_wobble: bool = True
#     enable_session_mood: bool = True
#     enable_fatigue: bool = True
#     crisis_dd_threshold: float = 0.035  # 3.5% DD triggers crisis mode


# class HumanBehaviorSimulatorAlgo(ExecAlgorithm):
#     """Execute orders with human-like delays and behaviors.
#
#     This is a stub - see human_simulator.py for the current implementation.
#     """
#
#     def __init__(self, config: HBSConfig):
#         super().__init__(config)
#         self._config = config
#         self._pending_orders: dict[ClientOrderId, SubmitOrder] = {}
#
#     def execute(self, command: SubmitOrder) -> None:
#         """Intercept order and add human-like delay."""
#         # TODO: Port logic from HumanBehaviorSimulator._calculate_delay()
#         delay_ms = random.randint(
#             self._config.min_delay_ms,
#             self._config.max_delay_ms,
#         )
#
#         # Schedule actual submission
#         self.clock.set_timer(
#             name=f"hbs_{command.order.client_order_id}",
#             interval=timedelta(milliseconds=delay_ms),
#             callback=self._on_delay_expired,
#         )
#         self._pending_orders[command.order.client_order_id] = command
#
#     def _on_delay_expired(self, event) -> None:
#         """Submit the order after delay expires."""
#         order_id_str = event.name.split("_", 1)[1]
#         order_id = ClientOrderId(order_id_str)
#         command = self._pending_orders.pop(order_id, None)
#         if command:
#             self.submit_order(command.order)
