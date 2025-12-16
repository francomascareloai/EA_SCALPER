# ARGUS Research Report: NinjaTrader OIF Integration for Python/NautilusTrader

**Research Date**: 2025-12-16
**Researcher**: ARGUS (Quant Research Agent)
**Confidence Level**: HIGH
**Status**: COMPLETE

---

## Executive Summary

This research investigates NinjaTrader's file-based order execution system (OIF - Order Instruction Files) for Python/NautilusTrader integration with Apex prop firm via Tradovate. The investigation discovered that:

1. **OIF is technically viable** with ~50-100ms latency
2. **CRITICAL WARNING**: ATI/OIF leaves audit trails that prop firms may detect
3. **Alternative approaches** exist to avoid detection (NT8 Add-On, commercial solutions)
4. **Direct Tradovate API** is NOT available for prop firm sim/eval accounts

**Verdict**: Use OIF for development/testing, but require NT8 Add-On approach or commercial solution (CrossTrade, NinjaView) for production prop firm trading.

---

## Table of Contents

1. [Key Terminology Correction](#1-key-terminology-correction)
2. [OIF File Format Specification](#2-oif-file-format-specification)
3. [NinjaTrader Configuration](#3-ninjatrader-configuration)
4. [Latency and Execution Speed](#4-latency-and-execution-speed)
5. [Apex/Tradovate Connection Setup](#5-apextradovate-connection-setup)
6. [CRITICAL: Prop Firm Detection Risk](#6-critical-prop-firm-detection-risk)
7. [Alternative Integration Methods](#7-alternative-integration-methods)
8. [Python Implementation Template](#8-python-implementation-template)
9. [WSL Integration Considerations](#9-wsl-integration-considerations)
10. [Architecture Recommendations](#10-architecture-recommendations)
11. [Risk Assessment and Pre-Mortem](#11-risk-assessment-and-pre-mortem)
12. [Confidence Assessment](#12-confidence-assessment)
13. [Handoff Recommendations](#13-handoff-recommendations)
14. [Sources](#14-sources)

---

## 1. Key Terminology Correction

**IMPORTANT**: The correct terminology is **OIF (Order Instruction Files)**, NOT "OTP".

- OIF = Order Instruction Files (file-based order interface)
- ATI = Automated Trading Interface (the broader automation system including OIF)
- The user's original query mentioned "OTP" which does not exist in NinjaTrader documentation.

---

## 2. OIF File Format Specification

### File Locations

| Purpose | Path |
|---------|------|
| Input (orders) | `Documents/NinjaTrader 8/incoming/` |
| Output (responses) | `Documents/NinjaTrader 8/outgoing/` |

### File Naming Convention

- Input files: `oif*.txt` (e.g., `oif1.txt`, `oif12345.txt`, `oif_uuid.txt`)
- Files are processed **INSTANTLY** when written to the incoming folder
- **CRITICAL**: Use atomic MOVE operations, NOT COPY (causes file locking)

### Command Format

All commands use semicolon (`;`) as delimiter:

```
COMMAND;PARAM1;PARAM2;...;PARAM_N
```

### Available Commands

| Command | Description | Parameters |
|---------|-------------|------------|
| `PLACE` | Submit new order | ACCOUNT;INSTRUMENT;ACTION;QTY;ORDER_TYPE;[LIMIT];[STOP];TIF;[OCO_ID];[ORDER_ID];[STRATEGY];[STRATEGY_ID] |
| `CANCEL` | Cancel order by ID | ;;;;;;;;ORDER_ID;; |
| `CHANGE` | Modify order parameters | See docs |
| `CLOSEPOSITION` | Close position | ACCOUNT;INSTRUMENT;;;;;;;;;; |
| `FLATTENEVERYTHING` | Cancel all, flatten all | ;;;;;;;;;; |
| `CANCELALLORDERS` | Cancel all orders | See docs |
| `REVERSEPOSITION` | Reverse position | See docs |
| `CLOSESTRATEGY` | Close ATM strategy | See docs |

### PLACE Command Format

```
PLACE;<ACCOUNT>;<INSTRUMENT>;<ACTION>;<QTY>;<ORDER TYPE>;[LIMIT PRICE];[STOP PRICE];<TIF>;[OCO ID];[ORDER ID];[STRATEGY];[STRATEGY ID]
```

### Valid Parameter Values

| Parameter | Valid Values |
|-----------|-------------|
| ACTION | `BUY`, `SELL` |
| ORDER TYPE | `MARKET`, `LIMIT`, `STOPMARKET`, `STOPLIMIT` |
| TIF (Time in Force) | `DAY`, `GTC` |
| LIMIT PRICE | Decimal format (e.g., `1212.25`) |
| STOP PRICE | Decimal format (e.g., `1210.50`) |

### Example Commands

```
# Market Buy 1 contract of NQ
PLACE;Sim101;NQ 03-24;BUY;1;MARKET;;;DAY;;;;

# Limit Sell 2 contracts at 5000.50
PLACE;Sim101;ES 03-24;SELL;2;LIMIT;5000.50;;DAY;;;;

# Close position
CLOSEPOSITION;Sim101;NQ 03-24;;;;;;;;;;

# Flatten everything
FLATTENEVERYTHING;;;;;;;;;;
```

### Response File Formats

Response files appear in the `outgoing/` folder:

| File Pattern | Content Format |
|--------------|----------------|
| `{orderId}.txt` | `Order State;Filled Amount;Average FillPrice` |
| `{Instrument}_{Account}_Position.txt` | `Market Position;Quantity;Average Entry Price` |
| `{ConnectionName}.txt` | `CONNECTED` or `DISCONNECTED` |

---

## 3. NinjaTrader Configuration

### Enable Automated Trading Interface (ATI)

1. Open NinjaTrader 8
2. Go to **Tools > Options > Automated Trading Interface**
3. Configure settings:
   - **ATI Enabled**: Check this box
   - **Server Name**: Leave default or customize
   - **Port**: Default 36973 (for socket connections)

### Enable Multi-Provider Mode (Required for Prop Firms)

1. Go to **Tools > Options > General**
2. Check **Multi-provider** box
3. Click **Apply > OK**
4. **Restart NinjaTrader** (critical step)

### Locate NinjaTrader Folder Path

The NinjaTrader folder path can be found in Windows Registry:

```
HKEY_CURRENT_USER\SOFTWARE\NinjaTrader, LLC\NinjaTrader 8\{cmp...}\PERSONAL_ROOT
```

Typical path: `C:\Users\<username>\Documents\NinjaTrader 8`

---

## 4. Latency and Execution Speed

### Measured Latencies by Integration Method

| Method | Latency | Source |
|--------|---------|--------|
| OIF File Interface | ~50-100ms | LinkedIn 2025 Article |
| Socket-based | sub-5ms | LinkedIn 2025 Article |
| CrossTrade webhook | ~194ms average | CrossTrade Blog |
| NTDirect.dll | N/A | **DEPRECATED** - do not use |

### Key Insights

- OIF latency is primarily file I/O + monitoring interval + processing
- 50-100ms is acceptable for scalping strategies (not HFT)
- Socket-based integration provides best latency but requires more complex setup
- CrossTrade's 194ms includes network overhead (TradingView -> CloudServer -> NT8)

### Latency Optimization Tips

1. Use SSD/NVMe for NinjaTrader folder
2. Consider ramdisk for incoming/outgoing folders
3. Monitor disk I/O during high-volume periods
4. Use atomic file operations (move, not copy)

---

## 5. Apex/Tradovate Connection Setup

### Apex Trader Funding Connection Options

Apex supports two connection methods:

#### Option 1: Rithmic (Direct)

1. Download [Apex Rithmic RTrader Pro](https://apextraderfunding.com/rtrader)
2. Login to RTrader Pro with Apex credentials
3. In NinjaTrader:
   - Select "Rithmic for NinjaTrader Brokerage"
   - System: "Rithmic Paper Trading (Chicago)"
   - Account Type: Simulation
   - **Uncheck** "Plug-in mode for market data"

#### Option 2: Tradovate (Recommended for our use case)

1. Login to [trader.tradovate.com](https://trader.tradovate.com) with Apex Tradovate credentials
2. Sign all required agreements for data activation (wait up to 4 hours)
3. In NinjaTrader:
   - Select "NinjaTrader" connection type
   - Account Type: Simulation
   - Enter APEX_XXXX username and password

### Important Connection Notes

| Note | Details |
|------|---------|
| Rithmic limitation | Only ONE Rithmic connection can be active at a time |
| Tradovate advantage | Multiple Tradovate connections can run simultaneously |
| Multi-Provider | Must be enabled to connect prop firm accounts |
| License Key | NinjaTrader 8.1+ does not require license key for prop firms |

### Connection Status Indicators

- **Green circle**: Successfully connected
- **Yellow circle**: Attempting connection
- **Red circle**: Connection failed
- **No circle**: Disconnected

---

## 6. CRITICAL: Prop Firm Detection Risk

### The Problem

**ATI/OIF leaves audit trails that prop firms can detect during payout reviews.**

### Evidence

From NinjaView (commercial automation tool):

> "The Automated Trading Interface (ATI) allows users to automate trades using order instruction files (OIF). These files contain specific commands for placing, modifying, or closing orders in NinjaTrader. **While ATI is a powerful tool, it leaves behind a traceable trail that prop funds may detect during payout reviews.**"

> "The NT8 add-on version of NinjaView **hides automated trades, leaving no detectable trail**, unlike the Windows application that uses the Automated Trading Interface (ATI)."

> "**Prop funds may refuse payouts if they detect an ATI trail** in your trading logs."

### What Gets Logged

1. OIF file activity (even though files are consumed)
2. ATI activity logs within NinjaTrader
3. Order source metadata in execution reports
4. Pattern analysis (precision timing, consistent execution)

### Risk Level Assessment

| Use Case | Risk Level |
|----------|------------|
| Personal accounts | LOW - no payout review |
| Sim/Eval accounts | MEDIUM - less scrutiny |
| Funded accounts (payouts) | HIGH - thorough review |

### Mitigation Strategies

1. **NT8 Add-On Approach**: Custom NinjaScript strategy that receives signals but places orders natively
2. **Commercial Solutions**: CrossTrade Add-On, NinjaView NT8 Add-On
3. **Manual Execution**: Use signals for decision support only (defeats automation purpose)

---

## 7. Alternative Integration Methods

### Option A: Direct OIF (Development Only)

```
NautilusTrader (Python/WSL)
    |
    v
OIF Writer --> incoming/oif*.txt
    |
    v
NinjaTrader 8 (Windows)
    |
    v
Apex via Tradovate
```

**Pros**: Simple, fast development, well-documented
**Cons**: Leaves ATI trail, risky for prop firm payouts
**Latency**: ~50-100ms
**Cost**: Free
**Recommended For**: Development, testing, personal accounts

### Option B: Custom NT8 Add-On (Production Recommended)

```
NautilusTrader (Python/WSL)
    |
    v
Socket/Named Pipe/HTTP
    |
    v
Custom NinjaScript Add-On (receives signals, places native orders)
    |
    v
NinjaTrader 8 (Windows)
    |
    v
Apex via Tradovate
```

**Pros**: No ATI trail, appears as native trading, full control
**Cons**: Requires NinjaScript/C# development
**Latency**: ~5-20ms (socket-based)
**Cost**: Development time (one-time)
**Recommended For**: Production prop firm trading

### Option C: CrossTrade REST API (Commercial)

```
NautilusTrader (Python/WSL)
    |
    v
HTTP REST API (remote)
    |
    v
CrossTrade Add-On in NT8
    |
    v
NinjaTrader 8 (Windows)
    |
    v
Apex via Tradovate
```

**Pros**: Production-ready, prop firm tested, remote execution
**Cons**: Subscription cost, vendor dependency
**Latency**: ~100-200ms
**Cost**: $150/6 months
**Recommended For**: Quick production deployment

### Option D: Direct Tradovate API (NOT AVAILABLE)

**IMPORTANT**: Direct Tradovate API access requires a LIVE funded account. Prop firm sim/eval accounts do NOT have API access. NinjaTrader acts as the authorized trading interface.

---

## 8. Python Implementation Template

### NinjaTrader OIF Client

```python
"""
NinjaTrader OIF Client for Python/NautilusTrader Integration.

WARNING: For prop firm use, ATI/OIF leaves audit trails.
Consider NT8 Add-On approach for production.
"""

import os
import uuid
import shutil
from pathlib import Path
from typing import Optional, Literal
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)


@dataclass
class NinjaTraderOIFClient:
    """
    NinjaTrader Order Instruction File (OIF) client.

    Writes order commands to NinjaTrader's incoming folder for execution.

    Attributes:
        nt_folder: Path to NinjaTrader 8 documents folder
                   (e.g., /mnt/c/Users/Admin/Documents/NinjaTrader 8)
    """

    nt_folder: Path

    def __post_init__(self):
        """Validate paths exist."""
        self.nt_folder = Path(self.nt_folder)
        if not self.incoming_folder.exists():
            raise ValueError(f"Incoming folder not found: {self.incoming_folder}")
        if not self.outgoing_folder.exists():
            raise ValueError(f"Outgoing folder not found: {self.outgoing_folder}")

    @property
    def incoming_folder(self) -> Path:
        return self.nt_folder / "incoming"

    @property
    def outgoing_folder(self) -> Path:
        return self.nt_folder / "outgoing"

    def _write_command(self, command: str) -> str:
        """
        Write OIF command using atomic move operation.

        Returns the file path written.
        """
        file_name = f"oif{uuid.uuid4().hex[:12]}.txt"
        file_path = self.incoming_folder / file_name

        # Atomic write: write to temp first, then move
        temp_path = file_path.with_suffix('.tmp')
        temp_path.write_text(command)
        shutil.move(str(temp_path), str(file_path))

        logger.info(f"OIF command written: {file_path}")
        logger.debug(f"Command: {command}")

        return str(file_path)

    def place_market_order(
        self,
        account: str,
        instrument: str,
        action: Literal["BUY", "SELL"],
        quantity: int,
        order_id: Optional[str] = None,
    ) -> str:
        """
        Place a market order.

        Args:
            account: NinjaTrader account name (e.g., "Sim101", "APEX_12345")
            instrument: Instrument name (e.g., "NQ 03-24", "GC 04-24")
            action: "BUY" or "SELL"
            quantity: Number of contracts
            order_id: Optional order ID for tracking

        Returns:
            Path to the written OIF file
        """
        oid = order_id or uuid.uuid4().hex[:8]
        command = f"PLACE;{account};{instrument};{action};{quantity};MARKET;;;DAY;;;{oid};"
        return self._write_command(command)

    def place_limit_order(
        self,
        account: str,
        instrument: str,
        action: Literal["BUY", "SELL"],
        quantity: int,
        limit_price: float,
        order_id: Optional[str] = None,
    ) -> str:
        """Place a limit order."""
        oid = order_id or uuid.uuid4().hex[:8]
        command = f"PLACE;{account};{instrument};{action};{quantity};LIMIT;{limit_price};;DAY;;;{oid};"
        return self._write_command(command)

    def place_stop_order(
        self,
        account: str,
        instrument: str,
        action: Literal["BUY", "SELL"],
        quantity: int,
        stop_price: float,
        order_id: Optional[str] = None,
    ) -> str:
        """Place a stop market order."""
        oid = order_id or uuid.uuid4().hex[:8]
        command = f"PLACE;{account};{instrument};{action};{quantity};STOPMARKET;;{stop_price};DAY;;;{oid};"
        return self._write_command(command)

    def place_stop_limit_order(
        self,
        account: str,
        instrument: str,
        action: Literal["BUY", "SELL"],
        quantity: int,
        limit_price: float,
        stop_price: float,
        order_id: Optional[str] = None,
    ) -> str:
        """Place a stop limit order."""
        oid = order_id or uuid.uuid4().hex[:8]
        command = f"PLACE;{account};{instrument};{action};{quantity};STOPLIMIT;{limit_price};{stop_price};DAY;;;{oid};"
        return self._write_command(command)

    def close_position(self, account: str, instrument: str) -> str:
        """Close all positions for an instrument."""
        command = f"CLOSEPOSITION;{account};{instrument};;;;;;;;;;;"
        return self._write_command(command)

    def cancel_order(self, order_id: str) -> str:
        """Cancel an order by ID."""
        command = f"CANCEL;;;;;;;;;{order_id};;"
        return self._write_command(command)

    def cancel_all_orders(self, account: str) -> str:
        """Cancel all orders for an account."""
        command = f"CANCELALLORDERS;{account};;;;;;;;;;"
        return self._write_command(command)

    def flatten_everything(self) -> str:
        """Cancel all orders and flatten all positions (EMERGENCY)."""
        command = "FLATTENEVERYTHING;;;;;;;;;;"
        return self._write_command(command)

    def read_order_status(self, order_id: str) -> Optional[dict]:
        """
        Read order status from outgoing folder.

        Returns dict with: state, filled_amount, avg_fill_price
        Or None if not found.
        """
        status_file = self.outgoing_folder / f"{order_id}.txt"
        if not status_file.exists():
            return None

        content = status_file.read_text().strip()
        parts = content.split(";")
        if len(parts) >= 3:
            return {
                "state": parts[0],
                "filled_amount": float(parts[1]) if parts[1] else 0,
                "avg_fill_price": float(parts[2]) if parts[2] else 0,
            }
        return None

    def read_position(self, instrument: str, account: str) -> Optional[dict]:
        """
        Read position status from outgoing folder.

        Returns dict with: position, quantity, avg_entry_price
        Or None if not found.
        """
        # Instrument names may have spaces, which are replaced in filenames
        safe_instrument = instrument.replace(" ", "_")
        position_file = self.outgoing_folder / f"{safe_instrument}_{account}_Position.txt"
        if not position_file.exists():
            return None

        content = position_file.read_text().strip()
        parts = content.split(";")
        if len(parts) >= 3:
            return {
                "position": parts[0],  # "Long", "Short", "Flat"
                "quantity": int(parts[1]) if parts[1] else 0,
                "avg_entry_price": float(parts[2]) if parts[2] else 0,
            }
        return None

    def read_connection_status(self, connection_name: str) -> Optional[str]:
        """
        Read connection status from outgoing folder.

        Returns "CONNECTED" or "DISCONNECTED", or None if not found.
        """
        status_file = self.outgoing_folder / f"{connection_name}.txt"
        if not status_file.exists():
            return None
        return status_file.read_text().strip()


# Example usage for WSL
if __name__ == "__main__":
    # WSL path to Windows NinjaTrader folder
    nt_path = Path("/mnt/c/Users/Admin/Documents/NinjaTrader 8")

    client = NinjaTraderOIFClient(nt_folder=nt_path)

    # Place a market buy order
    client.place_market_order(
        account="APEX_12345",
        instrument="GC 02-24",  # Gold futures
        action="BUY",
        quantity=1,
    )
```

---

## 9. WSL Integration Considerations

### Path Mapping

NautilusTrader runs on WSL (Linux), NinjaTrader runs on Windows.

| Context | Path Format |
|---------|-------------|
| Windows | `C:\Users\Admin\Documents\NinjaTrader 8\incoming\` |
| WSL | `/mnt/c/Users/Admin/Documents/NinjaTrader 8/incoming/` |

### WSL File System Notes

1. WSL can write directly to Windows filesystem via `/mnt/c/`
2. File permissions may need adjustment
3. Atomic file operations work across WSL -> Windows boundary
4. Use forward slashes in Python Path objects

### Configuration

```python
# Detect Windows username dynamically
import subprocess

def get_windows_nt_path():
    """Get NinjaTrader path from WSL."""
    # Get Windows username
    result = subprocess.run(
        ["cmd.exe", "/c", "echo %USERNAME%"],
        capture_output=True,
        text=True
    )
    username = result.stdout.strip()
    return Path(f"/mnt/c/Users/{username}/Documents/NinjaTrader 8")
```

---

## 10. Architecture Recommendations

### Development Phase

Use OIF for rapid iteration:

```
[NautilusTrader (WSL)]
         |
         v
[OIF Client (Python)] ---> /mnt/c/.../NinjaTrader 8/incoming/
         |
         v
[NinjaTrader 8 (Windows)] ---> Tradovate ---> Apex Sim Account
```

**Advantages**:
- Quick to implement
- Easy debugging (can inspect OIF files)
- No additional development required

### Production Phase (Choose One)

#### Option A: Custom NT8 Add-On (Recommended for control)

```
[NautilusTrader (WSL)]
         |
         v
[TCP Socket / Named Pipe]
         |
         v
[Custom NinjaScript Strategy] ---> Native Order Execution
         |
         v
[NinjaTrader 8] ---> Tradovate ---> Apex Funded Account
```

**Development Required**: NinjaScript strategy that:
1. Listens on local socket
2. Parses incoming signals
3. Places orders using native NinjaScript API
4. Reports fills back via socket

#### Option B: CrossTrade (Recommended for speed-to-market)

```
[NautilusTrader (WSL)]
         |
         v
[HTTP REST API] ---> CrossTrade Cloud
         |
         v
[CrossTrade NT8 Add-On]
         |
         v
[NinjaTrader 8] ---> Tradovate ---> Apex Funded Account
```

**Cost**: $150 per 6 months
**Advantages**: Production-ready, prop firm tested

---

## 11. Risk Assessment and Pre-Mortem

### Risk Matrix

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Prop firm detects ATI | MEDIUM | HIGH (payout rejection) | Use NT8 Add-On approach |
| File system errors | LOW | MEDIUM | Atomic operations, monitoring |
| Latency spikes | MEDIUM | LOW | SSD/ramdisk, monitoring |
| NinjaTrader not running | LOW | HIGH | Pre-flight checks, monitoring |
| Order sync issues | MEDIUM | MEDIUM | Response file monitoring |
| Apex rule violations | MEDIUM | HIGH | Pre-trade compliance checks |
| Connection failures | MEDIUM | MEDIUM | Connection status monitoring |

### Pre-Mortem: What Could Go Wrong

1. **Payout Rejected**: Apex detects automation, refuses payout
   - Prevention: Use NT8 Add-On for production

2. **Orders Missed**: NinjaTrader offline, files pile up
   - Prevention: Health check before writing, monitoring

3. **Duplicate Orders**: File written twice due to retry logic
   - Prevention: Unique order IDs, idempotency checks

4. **Wrong Account**: Order goes to wrong account
   - Prevention: Validation layer, account whitelisting

5. **Position Sync Loss**: Python state diverges from actual
   - Prevention: Periodic reconciliation via response files

---

## 12. Confidence Assessment

### Technical Implementation: HIGH

| Evidence Type | Source | Confidence |
|---------------|--------|------------|
| Documentation | NinjaTrader Official Docs | HIGH |
| Code Example | NinjaView GitHub | HIGH |
| Commercial Use | CrossTrade, NinjaView, Lune | HIGH |

### Latency Figures: MEDIUM-HIGH

| Evidence Type | Source | Confidence |
|---------------|--------|------------|
| Industry Report | LinkedIn 2025 Article | HIGH |
| Measurements | CrossTrade Blog | MEDIUM |
| Technical Analysis | File I/O expectations | MEDIUM |

### Prop Firm Detection Risk: MEDIUM-HIGH

| Evidence Type | Source | Confidence |
|---------------|--------|------------|
| Vendor Warning | NinjaView Documentation | HIGH |
| Product Existence | NT8 Add-On to "hide" automation | MEDIUM-HIGH |
| Direct Reports | No confirmed rejections found | LOW (absence of evidence) |

---

## 13. Handoff Recommendations

### To FORGE (Implementation)

1. Implement `NinjaTraderOIFClient` in `nautilus_gold_scalper/execution/`
2. Add WSL path detection and configuration
3. Implement response file monitoring for order tracking
4. Add pre-flight checks (NT8 running, connection status)

### To CRUCIBLE (Strategy)

1. Account for 50-100ms execution latency in strategy design
2. Implement time gates for Apex compliance
3. Consider order types that work best with OIF latency

### To SENTINEL (Risk)

1. Implement Apex compliance checks before order submission
2. Add position and P&L monitoring via response files
3. Implement emergency flatten capability

### To ORACLE (Validation)

1. Backtest with realistic latency assumptions (50-100ms)
2. Test order execution flow on sim accounts
3. Validate response file parsing

---

## 14. Sources

### Official Documentation

1. [NinjaTrader Order Instruction Files (OIF)](https://ninjatrader.com/support/helpguides/nt8/order_instruction_files_oif.htm)
2. [NinjaTrader ATI Commands and Parameters](https://ninjatrader.com/support/helpguides/nt8/commands_and_valid_parameters.htm)
3. [NinjaTrader ATI Options](https://ninjatrader.com/support/helpguides/nt8/options_ati.htm)
4. [NinjaTrader Information Update Files](https://ninjatrader.com/support/helpguides/nt8/information_update_files.htm)

### Technical Articles

5. [Python automated trading with NinjaTrader 8 in 2025 - LinkedIn](https://www.linkedin.com/pulse/python-automated-trading-ninjatrader-8-2025-prabhawa-koirala-uf2nf) - Confirms OIF as "most reliable integration approach in 2025" with ~50-100ms latency

### Commercial Products (Evidence of Viability)

6. [CrossTrade REST API for NT8](https://crosstrade.io/crosstrade-api) - "The world's first and only REST API for NT8"
7. [CrossTrade Latency Measurements](https://crosstrade.io/blog/how-fast-is-crosstrade/) - 194ms average execution time
8. [NinjaView NT8 Add-On](https://ninja-view.com/addon) - "Hides automated trades, leaving no detectable trail"
9. [NinjaView Windows App](https://ninja-view.com/?p=1425) - Warning about ATI audit trails

### Code Examples

10. [NinjaView Python Snippet](https://github.com/NinjaView/NinjaViewPythonSnip) - Working Python OIF implementation

### Connection Guides

11. [Apex Tradovate Setup](https://support.apextraderfunding.com/hc/en-us/articles/13602416481819)
12. [CrossTrade Prop Firm Connection Guide](https://crosstrade.io/blog/ninjatrader-8-prop-firm-connection-guide/)
13. [QuantVPS NinjaTrader Tradovate Setup](https://www.quantvps.com/blog/how-to-setup-ninjatrader-with-tradovate-accounts)

### API Limitations

14. [Lune Trading Tradovate Documentation](https://docs.lunetrading.com/automated-trading-software/lune-auto-trader/supported-platforms/tradovate) - "Many Prop Firms restrict API access for Tradovate"

---

## Appendix A: Full OIF Command Reference

### PLACE Command

```
PLACE;<ACCOUNT>;<INSTRUMENT>;<ACTION>;<QTY>;<ORDER TYPE>;[LIMIT PRICE];[STOP PRICE];<TIF>;[OCO ID];[ORDER ID];[STRATEGY];[STRATEGY ID]
```

### CANCEL Command

```
CANCEL;;;;;;;;;[ORDER ID];;
```

### CHANGE Command

```
CHANGE;;;;;[QTY];[ORDER TYPE];[LIMIT PRICE];[STOP PRICE];;[ORDER ID];;
```

### CLOSEPOSITION Command

```
CLOSEPOSITION;<ACCOUNT>;<INSTRUMENT>;;;;;;;;;;;
```

### CLOSESTRATEGY Command

```
CLOSESTRATEGY;;;;;;;;;;[STRATEGY ID]
```

### FLATTENEVERYTHING Command

```
FLATTENEVERYTHING;;;;;;;;;;
```

### CANCELALLORDERS Command

```
CANCELALLORDERS;<ACCOUNT>;;;;;;;;;;
```

### REVERSEPOSITION Command

```
REVERSEPOSITION;<ACCOUNT>;<INSTRUMENT>;<ACTION>;<QTY>;<ORDER TYPE>;[LIMIT PRICE];[STOP PRICE];<TIF>;;;
```

---

*Research conducted by ARGUS Quant Research Agent*
*EA_SCALPER_XAUUSD Project*
*2025-12-16*
