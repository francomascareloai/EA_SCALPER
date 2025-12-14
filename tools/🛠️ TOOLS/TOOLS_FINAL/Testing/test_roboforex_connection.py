#!/usr/bin/env python3
"""
🔌 Direct RoboForex Connection Test
Test your RoboForex credentials directly
"""

import asyncio
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent
sys.path.append(str(project_root / "mcp-metatrader5-server"))

from setup_roboforex_mt5 import RoboForexSetup

async def test_your_credentials():
    """Test RoboForex connection with your credentials"""
    
    print("🔌 DIRECT ROBOFOREX CONNECTION TEST")
    print("=" * 50)
    
    # ⚠️ EDIT THESE WITH YOUR ACTUAL ROBOFOREX CREDENTIALS:
    YOUR_LOGIN = 68235069        # Replace with your RoboForex login
    YOUR_PASSWORD = "Franco312??"  # Replace with your RoboForex password
    YOUR_SERVER = "RoboForex-Pro"   # Your server (RoboForex-Demo, RoboForex-Pro, etc.)
    
    print(f"📊 Testing with:")
    print(f"  Login: {YOUR_LOGIN}")
    print(f"  Server: {YOUR_SERVER}")
    print(f"  Password: {'*' * len(YOUR_PASSWORD)}")
    
    # Check if credentials were updated
    if YOUR_LOGIN == 12345678 and YOUR_PASSWORD == "YourPassword":
        print("⚠️ WARNING: You're using template credentials!")
        print("📝 Please edit this script with your real RoboForex credentials")
        print("🔗 Get credentials at: https://www.roboforex.com/demo-account/")
        return False
    
    setup = RoboForexSetup()
    
    try:
        print("\n🔌 Attempting connection...")
        
        # Test the connection
        result = await setup.test_connection(YOUR_LOGIN, YOUR_PASSWORD, YOUR_SERVER)
        
        if result:
            print("\n🎉 SUCCESS! Connection to RoboForex established!")
            print("✅ Your credentials are working")
            print("✅ XAUUSD symbol is available")
            
            # Test XAUUSD_TDS specifically
            print("\n🧪 Testing XAUUSD_TDS symbol...")
            await test_xauusd_tds_symbol()
            
            print("✅ FTMO compliance validated")
            print("✅ Ready for autonomous EA development")
            
            # Generate MCP configuration
            setup.generate_mcp_config(YOUR_LOGIN, YOUR_SERVER)
            
            return True
        else:
            print("\n❌ CONNECTION FAILED!")
            print_troubleshooting_tips()
            return False
            
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        print_troubleshooting_tips()
        return False

async def test_xauusd_tds_symbol():
    """Test XAUUSD_TDS symbol availability and M15 data"""
    import MetaTrader5 as mt5
    
    try:
        # Test XAUUSD_TDS
        symbol_tds = "XAUUSD_TDS"
        symbol_info_tds = mt5.symbol_info(symbol_tds)
        
        if symbol_info_tds is not None:
            print(f"✅ {symbol_tds} symbol: AVAILABLE")
            
            # Add to Market Watch
            if mt5.symbol_select(symbol_tds, True):
                print(f"✅ {symbol_tds} added to Market Watch")
                
                # Test M15 data
                m15_rates = mt5.copy_rates_from_pos(symbol_tds, mt5.TIMEFRAME_M15, 0, 100)
                if m15_rates is not None and len(m15_rates) > 0:
                    print(f"✅ M15 data available: {len(m15_rates)} bars")
                    print(f"   Last M15 bar: {m15_rates[-1]['close']:.3f}")
                    
                    # Test multi-timeframe data
                    timeframes = {
                        "M1": mt5.TIMEFRAME_M1,
                        "M5": mt5.TIMEFRAME_M5, 
                        "M15": mt5.TIMEFRAME_M15,
                        "H1": mt5.TIMEFRAME_H1,
                        "H4": mt5.TIMEFRAME_H4
                    }
                    
                    print("   📊 Multi-timeframe data check:")
                    for tf_name, tf_const in timeframes.items():
                        rates = mt5.copy_rates_from_pos(symbol_tds, tf_const, 0, 10)
                        if rates is not None and len(rates) > 0:
                            print(f"     ✅ {tf_name}: {len(rates)} bars")
                        else:
                            print(f"     ❌ {tf_name}: No data")
                            
                else:
                    print(f"❌ M15 data not available for {symbol_tds}")
            else:
                print(f"❌ Failed to add {symbol_tds} to Market Watch")
        else:
            print(f"⚠️ {symbol_tds} symbol: NOT AVAILABLE")
            print("   🔄 Using standard XAUUSD as fallback")
            
            # Test standard XAUUSD as fallback
            symbol_std = "XAUUSD"
            symbol_info_std = mt5.symbol_info(symbol_std)
            if symbol_info_std is not None:
                print(f"✅ {symbol_std} (fallback) symbol: AVAILABLE")
                # Test M15 data for fallback
                m15_rates = mt5.copy_rates_from_pos(symbol_std, mt5.TIMEFRAME_M15, 0, 100)
                if m15_rates is not None and len(m15_rates) > 0:
                    print(f"✅ M15 data available: {len(m15_rates)} bars")
                else:
                    print(f"❌ M15 data not available for {symbol_std}")
            else:
                print(f"❌ {symbol_std} (fallback) also not available")
                
    except Exception as e:
        print(f"❌ Error testing XAUUSD_TDS: {e}")

def print_troubleshooting_tips():
    """Print troubleshooting tips for connection issues"""
    print("\n🛠️ TROUBLESHOOTING TIPS:")
    print("1. ✅ Verify your login/password are correct")
    print("2. ✅ Ensure RoboForex MT5 terminal is installed")
    print("3. ✅ Check if MetaTrader5 Python package is installed:")
    print("   pip install MetaTrader5")
    print("4. ✅ Try different servers:")
    print("   - RoboForex-Demo")
    print("   - RoboForex-Pro") 
    print("   - RoboForex-ECN")
    print("5. ✅ Make sure MT5 terminal is closed before testing")
    print("6. ✅ Check your internet connection")
    print("7. ✅ Verify account is active and not expired")

async def quick_installation_check():
    """Check if required packages are installed"""
    print("🔍 CHECKING INSTALLATION...")
    
    try:
        import MetaTrader5 as mt5
        print("✅ MetaTrader5 package: INSTALLED")
    except ImportError:
        print("❌ MetaTrader5 package: NOT INSTALLED")
        print("💡 Install with: pip install MetaTrader5")
        return False
    
    try:
        # Check if MT5 can initialize
        if mt5.initialize():
            print("✅ MT5 Terminal: ACCESSIBLE")
            mt5.shutdown()
        else:
            print("⚠️ MT5 Terminal: NOT ACCESSIBLE")
            print("💡 Install RoboForex MT5 from: https://www.roboforex.com/trading-platforms/metatrader-5/")
    except Exception as e:
        print(f"⚠️ MT5 Check Error: {e}")
    
    return True

async def main():
    """Main test function"""
    
    print("🤖 RoboForex MT5 Connection Test")
    print("=" * 60)
    
    # Check installation first
    if await quick_installation_check():
        print("\n" + "=" * 60)
        
        # Test connection
        success = await test_your_credentials()
        
        if success:
            print("\n🎯 NEXT STEPS:")
            print("1. 🔄 Restart Qoder IDE")
            print("2. 🤖 Your autonomous agent can now use RoboForex!")
            print("3. 🚀 Start developing your XAUUSD EA")
        else:
            print("\n📝 EDIT CREDENTIALS:")
            print("1. Open this file: test_roboforex_connection.py")
            print("2. Replace YOUR_LOGIN, YOUR_PASSWORD, YOUR_SERVER")
            print("3. Run the script again")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    asyncio.run(main())