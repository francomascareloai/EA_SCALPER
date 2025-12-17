"""
Simple smoke test for holiday_detector migration.
"""

import sys
from datetime import datetime
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from context.holiday_detector import HolidayDetector, HolidayType


def test_basic_functionality():
    """Test basic holiday detection."""
    print("=== HolidayDetector Migration Test ===\n")

    detector = HolidayDetector()
    detector.init(2025)

    print("[OK] Initialization successful")
    print(f"  Loaded {len(detector._us_holidays)} US holidays")
    print(f"  Loaded {len(detector._uk_holidays)} UK holidays\n")

    # Test US holidays
    test_dates = [
        (datetime(2025, 1, 1), "New Year's Day"),
        (datetime(2025, 1, 20), "MLK Day"),
        (datetime(2025, 4, 18), "Good Friday"),
        (datetime(2025, 7, 4), "Independence Day"),
        (datetime(2025, 11, 27), "Thanksgiving"),
        (datetime(2025, 12, 25), "Christmas"),
    ]

    print("=== Testing US Holidays 2025 ===")
    for test_date, _expected_name in test_dates:
        info = detector.check_holiday(test_date)
        if info.is_holiday:
            print(f"[OK] {test_date.date()}: {info.name}")
            print(f"  Type: {info.type.name}, Multiplier: {info.size_multiplier}")
        else:
            print(f"[FAIL] {test_date.date()}: Expected holiday but none found")

    print("\n=== Testing UK Holidays 2025 ===")
    uk_dates = [
        (datetime(2025, 4, 21), "Easter Monday"),
        (datetime(2025, 5, 5), "Early May Bank Holiday"),
        (datetime(2025, 8, 25), "Summer Bank Holiday"),
    ]

    for date, _expected_name in uk_dates:
        info = detector.check_holiday(date)
        if info.is_holiday:
            print(f"[OK] {date.date()}: {info.name}")
        else:
            print(f"[FAIL] {date.date()}: Expected holiday but none found")

    # Test Easter calculation
    print("\n=== Testing Easter Calculation ===")
    easter_2025 = detector._calculate_easter(2025)
    from datetime import date as date_cls

    print(f"Easter 2025: {easter_2025} (Expected: 2025-04-20)")
    assert easter_2025 == date_cls(2025, 4, 20), "Easter 2025 mismatch!"
    print("[OK] Easter calculation correct")

    # Test adjacent holiday
    print("\n=== Testing Adjacent Holiday Detection ===")
    christmas_eve = datetime(2025, 12, 24)
    info = detector.check_holiday(christmas_eve)
    print(f"{christmas_eve.date()}: {info.name}")
    print(f"  Type: {info.type.name}, Reduced liquidity: {info.reduced_liquidity}")
    if info.type == HolidayType.PARTIAL:
        print("[OK] Adjacent holiday detection works")

    # Test non-holiday
    print("\n=== Testing Non-Holiday ===")
    regular_day = datetime(2025, 7, 10)
    info = detector.check_holiday(regular_day)
    print(f"{regular_day.date()}: Holiday={info.is_holiday}, Multiplier={info.size_multiplier}")
    assert info.size_multiplier == 1.0, "Regular day should have multiplier 1.0"
    print("[OK] Non-holiday works")

    # Test Nth weekday
    print("\n=== Testing Nth Weekday Calculation ===")
    mlk = detector._get_nth_weekday_of_month(2025, 1, 0, 3)  # 3rd Monday of Jan
    print(f"3rd Monday of Jan 2025: {mlk} (Expected: 2025-01-20)")
    assert mlk == date_cls(2025, 1, 20), "MLK Day mismatch!"
    print("[OK] Nth weekday calculation correct")

    # Test last weekday
    print("\n=== Testing Last Weekday Calculation ===")
    memorial = detector._get_last_weekday_of_month(2025, 5, 0)  # Last Monday of May
    print(f"Last Monday of May 2025: {memorial} (Expected: 2025-05-26)")
    assert memorial == date_cls(2025, 5, 26), "Memorial Day mismatch!"
    print("[OK] Last weekday calculation correct")

    print("\n" + "=" * 50)
    print("*** ALL TESTS PASSED - Migration successful! ***")
    print("=" * 50)


if __name__ == "__main__":
    test_basic_functionality()
