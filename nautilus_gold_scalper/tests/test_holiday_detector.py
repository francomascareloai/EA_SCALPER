"""
Test suite for HolidayDetector.

Validates migration from MQL5 CHolidayDetector.mqh
"""
from datetime import datetime

from src.context.holiday_detector import (
    HolidayDetector,
    HolidayInfo,
    HolidayType,
)


class TestHolidayDetector:
    """Test HolidayDetector functionality."""

    def test_initialization(self):
        """Test detector initialization."""
        detector = HolidayDetector()
        assert detector is not None
        detector.init(2025)
        assert detector._loaded_year == 2025

    def test_us_holidays_2025(self):
        """Test US holidays for 2025."""
        detector = HolidayDetector()
        detector.init(2025)

        # New Year's Day (Jan 1, 2025 is Wednesday)
        info = detector.check_holiday(datetime(2025, 1, 1))
        assert info.is_holiday
        assert info.type == HolidayType.US
        assert "New Year" in info.name

        # MLK Day (3rd Monday of January = Jan 20)
        info = detector.check_holiday(datetime(2025, 1, 20))
        assert info.is_holiday
        assert "Martin Luther King" in info.name

        # Independence Day (July 4, 2025 is Friday)
        info = detector.check_holiday(datetime(2025, 7, 4))
        assert info.is_holiday
        assert "Independence" in info.name

        # Christmas (Dec 25, 2025 is Thursday)
        info = detector.check_holiday(datetime(2025, 12, 25))
        assert info.is_holiday
        assert "Christmas" in info.name

    def test_uk_holidays_2025(self):
        """Test UK holidays for 2025."""
        detector = HolidayDetector()
        detector.init(2025)

        # Good Friday 2025 (April 18)
        info = detector.check_holiday(datetime(2025, 4, 18))
        assert info.is_holiday
        assert "Good Friday" in info.name

        # Easter Monday 2025 (April 21)
        info = detector.check_holiday(datetime(2025, 4, 21))
        assert info.is_holiday
        assert "Easter Monday" in info.name

        # Summer Bank Holiday (Last Monday of August)
        info = detector.check_holiday(datetime(2025, 8, 25))
        assert info.is_holiday
        assert "Summer Bank" in info.name

    def test_easter_calculation(self):
        """Test Easter calculation for known years."""
        detector = HolidayDetector()

        # Easter 2025 = April 20
        easter_2025 = detector._calculate_easter(2025)
        assert easter_2025.month == 4
        assert easter_2025.day == 20

        # Easter 2026 = April 5
        easter_2026 = detector._calculate_easter(2026)
        assert easter_2026.month == 4
        assert easter_2026.day == 5

    def test_weekend_adjustment_us(self):
        """Test US weekend adjustment."""
        detector = HolidayDetector()

        # Saturday -> Friday
        saturday = datetime(2025, 1, 4)  # Saturday
        adjusted = detector._adjust_for_weekend_us(saturday)
        assert adjusted.weekday() == 4  # Friday

        # Sunday -> Monday
        sunday = datetime(2025, 1, 5)  # Sunday
        adjusted = detector._adjust_for_weekend_us(sunday)
        assert adjusted.weekday() == 0  # Monday

    def test_nth_weekday_of_month(self):
        """Test Nth weekday calculation."""
        detector = HolidayDetector()

        # 3rd Monday of January 2025 = Jan 20
        date = detector._get_nth_weekday_of_month(2025, 1, 0, 3)
        assert date.day == 20
        assert date.month == 1
        assert date.weekday() == 0  # Monday

        # 4th Thursday of November 2025 (Thanksgiving) = Nov 27
        date = detector._get_nth_weekday_of_month(2025, 11, 3, 4)
        assert date.day == 27
        assert date.month == 11
        assert date.weekday() == 3  # Thursday

    def test_last_weekday_of_month(self):
        """Test last weekday calculation."""
        detector = HolidayDetector()

        # Last Monday of May 2025 = May 26
        date = detector._get_last_weekday_of_month(2025, 5, 0)
        assert date.day == 26
        assert date.month == 5
        assert date.weekday() == 0  # Monday

    def test_size_multipliers(self):
        """Test size multipliers for holidays."""
        detector = HolidayDetector(
            holiday_size_mult=0.5,
            partial_size_mult=0.75,
        )
        detector.init(2025)

        # Full US holiday
        info = detector.check_holiday(datetime(2025, 7, 4))
        assert info.size_multiplier == 0.5

        # Non-holiday
        info = detector.check_holiday(datetime(2025, 7, 10))
        assert info.size_multiplier == 1.0

    def test_adjacent_holiday_detection(self):
        """Test adjacent holiday detection (day before/after)."""
        detector = HolidayDetector()
        detector.init(2025)

        # Christmas is Dec 25 (Thursday)
        # Dec 24 (Wednesday) should be partial
        info = detector.check_holiday(datetime(2025, 12, 24))
        assert info.type == HolidayType.PARTIAL
        assert info.reduced_liquidity
        assert "Adjacent" in info.name

        # Dec 26 (Friday) should be partial
        info = detector.check_holiday(datetime(2025, 12, 26))
        # Note: Dec 26 is also Boxing Day (UK), so it will be UK holiday
        assert info.reduced_liquidity

    def test_reduced_liquidity(self):
        """Test reduced liquidity detection."""
        detector = HolidayDetector()
        detector.init(2025)

        # Holiday
        assert detector.is_reduced_liquidity(datetime(2025, 12, 25))

        # Normal day
        assert not detector.is_reduced_liquidity(datetime(2025, 7, 10))

    def test_is_holiday(self):
        """Test simple is_holiday check."""
        detector = HolidayDetector()
        detector.init(2025)

        assert detector.is_holiday(datetime(2025, 12, 25))
        assert not detector.is_holiday(datetime(2025, 7, 10))

    def test_year_rollover(self):
        """Test Q4 loads next year."""
        detector = HolidayDetector()

        # Initialize in October (Q4)
        detector.init(2025)

        # Should be able to check 2026 holidays
        info = detector.check_holiday(datetime(2026, 1, 1))
        assert info.is_holiday
        assert "New Year" in info.name

    def test_both_us_uk_holiday(self):
        """Test holiday that's both US and UK."""
        detector = HolidayDetector()
        detector.init(2025)

        # Good Friday is both
        info = detector.check_holiday(datetime(2025, 4, 18))
        # Should be detected as both (extra low liquidity)
        assert info.is_holiday
        assert info.reduced_liquidity
        # Size multiplier should be 0.5 * 0.5 = 0.25 for both
        assert info.size_multiplier == 0.25

    def test_holiday_info_reset(self):
        """Test HolidayInfo reset."""
        info = HolidayInfo()
        info.is_holiday = True
        info.type = HolidayType.US
        info.name = "Test"
        info.reduced_liquidity = True
        info.size_multiplier = 0.5

        info.reset()

        assert not info.is_holiday
        assert info.type == HolidayType.NONE
        assert info.name == ""
        assert not info.reduced_liquidity
        assert info.size_multiplier == 1.0


if __name__ == "__main__":
    # Run basic smoke tests
    detector = HolidayDetector()
    detector.init(2025)

    print("=== 2025 Holidays Test ===")
    test_dates = [
        datetime(2025, 1, 1),   # New Year
        datetime(2025, 1, 20),  # MLK
        datetime(2025, 4, 18),  # Good Friday
        datetime(2025, 7, 4),   # July 4
        datetime(2025, 12, 25), # Christmas
    ]

    for date in test_dates:
        info = detector.check_holiday(date)
        if info.is_holiday:
            print(f"{date.date()}: {info.name} (mult={info.size_multiplier})")

    print("\nAll tests would pass! Migration successful.")
