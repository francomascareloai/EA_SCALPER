"""
ML Feature Engineering for XAUUSD Gold Scalping.
Part of STREAM G - ML Feature Engineering.

This module provides comprehensive feature engineering for machine learning models,
including 30+ features across multiple categories:
- Price features (returns, volatility, momentum)
- Volume features (delta, VWAP, volume ratio)
- Technical indicators (ATR, Bollinger Bands, EMAs)
- Structure features (swing distance, trend strength)
- Regime features (Hurst, entropy)
- Statistical features (z-score, skewness, kurtosis)
- Temporal features (cyclical hour/day encoding)

All calculations are vectorized using numpy/pandas for performance.
"""

import logging
import warnings
from dataclasses import dataclass
from typing import Any

import numpy as np
import pandas as pd
from sklearn.preprocessing import RobustScaler, StandardScaler

warnings.filterwarnings('ignore')

logger = logging.getLogger(__name__)


@dataclass
class FeatureConfig:
    """Configuration for feature engineering."""
    # RSI periods
    rsi_periods: list[int] | None = None

    # Moving average periods
    ema_periods: list[int] | None = None
    sma_periods: list[int] | None = None

    # ATR period
    atr_period: int = 14

    # Bollinger Bands
    bb_period: int = 20
    bb_std: float = 2.0

    # Regime detection
    hurst_period: int = 100
    entropy_period: int = 50

    # Volume
    volume_ma_period: int = 20

    # Statistical
    zscore_period: int = 20
    skew_period: int = 30
    kurt_period: int = 30

    # MACD
    macd_fast: int = 12
    macd_slow: int = 26
    macd_signal: int = 9

    # ADX
    adx_period: int = 14

    def __post_init__(self) -> None:
        """Set defaults for list parameters."""
        if self.rsi_periods is None:
            self.rsi_periods = [5, 14, 21]
        if self.ema_periods is None:
            self.ema_periods = [8, 21, 50, 200]
        if self.sma_periods is None:
            self.sma_periods = [20, 50, 100]


class FeatureEngineer:
    """
    Comprehensive feature engineering for XAUUSD trading ML models.

    Generates 30+ features from OHLCV data, organized into logical categories.
    All operations are vectorized for performance.

    Usage:
        engineer = FeatureEngineer()
        features_df = engineer.compute_all_features(ohlcv_df)
        feature_names = engineer.get_feature_names()
        scaled_features = engineer.scale_features(features_df)
    """

    def __init__(self, config: FeatureConfig | None = None):
        """
        Initialize feature engineer.

        Args:
            config: Feature configuration (uses defaults if None)
        """
        self.config = config or FeatureConfig()
        self.scaler: StandardScaler | None = None
        self.feature_names: list[str] = []

    def compute_all_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute all features from OHLCV data.

        Args:
            df: DataFrame with columns ['open', 'high', 'low', 'close', 'volume']
               Index should be datetime and MUST be sorted ascending by time.

        Returns:
            DataFrame with all engineered features.

        Raises:
            ValueError: If required columns are missing or index is not time-sorted.
        """
        # Validate input
        required_cols = ['open', 'high', 'low', 'close', 'volume']
        missing = [col for col in required_cols if col not in df.columns]
        if missing:
            raise ValueError(f"Missing required columns: {missing}")

        # CRITICAL: Validate index is sorted ascending by time to prevent look-ahead bias
        # Rolling calculations assume data is in chronological order
        if isinstance(df.index, pd.DatetimeIndex):
            if not df.index.is_monotonic_increasing:
                raise ValueError(
                    "DataFrame index must be sorted ascending by time. "
                    "Use df.sort_index() before calling compute_all_features(). "
                    "Unsorted data causes look-ahead bias in rolling calculations."
                )

        # Initialize feature dataframe
        features = pd.DataFrame(index=df.index)

        # Category 1: Price Features
        price_feats = self._compute_price_features(df)
        features = pd.concat([features, price_feats], axis=1)

        # Category 2: Volume Features
        volume_feats = self._compute_volume_features(df)
        features = pd.concat([features, volume_feats], axis=1)

        # Category 3: Technical Indicators
        technical_feats = self._compute_technical_features(df)
        features = pd.concat([features, technical_feats], axis=1)

        # Category 4: Structure Features
        structure_feats = self._compute_structure_features(df)
        features = pd.concat([features, structure_feats], axis=1)

        # Category 5: Regime Features
        regime_feats = self._compute_regime_features(df)
        features = pd.concat([features, regime_feats], axis=1)

        # Category 6: Statistical Features
        stats_feats = self._compute_statistical_features(df)
        features = pd.concat([features, stats_feats], axis=1)

        # Category 7: Temporal Features
        temporal_feats = self._compute_temporal_features(df)
        features = pd.concat([features, temporal_feats], axis=1)

        # Store feature names
        self.feature_names = features.columns.tolist()

        # Drop NaN rows (from rolling calculations)
        features = features.dropna()

        return features

    def _compute_price_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute price-based features.

        Features:
        - returns: Simple returns
        - log_returns: Log returns
        - range_pct: (high - low) / close
        - body_pct: |close - open| / (high - low)
        - gap: open[t] - close[t-1]
        - upper_shadow: high - max(open, close)
        - lower_shadow: min(open, close) - low
        """
        feats = pd.DataFrame(index=df.index)

        close = df['close']
        open_ = df['open']
        high = df['high']
        low = df['low']

        # Returns
        feats['returns'] = close.pct_change()
        feats['log_returns'] = np.log(close / close.shift(1))

        # Intrabar metrics
        range_hl = high - low
        feats['range_pct'] = range_hl / close
        feats['body_pct'] = np.abs(close - open_) / (range_hl + 1e-10)

        # Gap
        feats['gap'] = (open_ - close.shift(1)) / close.shift(1)

        # Shadows (normalized)
        feats['upper_shadow'] = (high - np.maximum(open_, close)) / (range_hl + 1e-10)
        feats['lower_shadow'] = (np.minimum(open_, close) - low) / (range_hl + 1e-10)

        # Momentum (ROC - Rate of Change)
        feats['roc_5'] = (close - close.shift(5)) / close.shift(5)
        feats['roc_10'] = (close - close.shift(10)) / close.shift(10)

        return feats

    def _compute_volume_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute volume-based features.

        Features:
        - volume_ratio: volume / MA(volume)
        - volume_delta: Approximated as volume * sign(close - open)
        - vwap_distance: (close - VWAP) / close
        - volume_volatility: Rolling std of volume
        """
        feats = pd.DataFrame(index=df.index)

        volume = df['volume']
        close = df['close']
        open_ = df['open']
        high = df['high']
        low = df['low']

        # Volume ratio
        volume_ma = volume.rolling(self.config.volume_ma_period).mean()
        feats['volume_ratio'] = volume / (volume_ma + 1e-10)

        # Volume delta (approximation: positive if close > open, negative otherwise)
        price_direction = np.sign(close - open_)
        feats['volume_delta'] = volume * price_direction
        feats['volume_delta_ma'] = feats['volume_delta'].rolling(20).mean()

        # VWAP (Volume Weighted Average Price)
        typical_price = (high + low + close) / 3
        vwap = (typical_price * volume).rolling(20).sum() / volume.rolling(20).sum()
        feats['vwap_distance'] = (close - vwap) / close

        # Volume volatility
        feats['volume_volatility'] = volume.rolling(20).std() / (volume.rolling(20).mean() + 1e-10)

        return feats

    def _compute_technical_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute technical indicators.

        Features:
        - RSI (multiple periods)
        - MACD + Signal + Histogram
        - ATR (normalized)
        - Bollinger Bands position
        - EMA distances
        - SMA distances
        - ADX (trend strength)
        """
        feats = pd.DataFrame(index=df.index)

        close = df['close']
        high = df['high']
        low = df['low']

        # RSI (Relative Strength Index)
        assert self.config.rsi_periods is not None
        for period in self.config.rsi_periods:
            feats[f'rsi_{period}'] = self._calculate_rsi(close, period)

        # MACD
        macd, signal, hist = self._calculate_macd(
            close,
            self.config.macd_fast,
            self.config.macd_slow,
            self.config.macd_signal
        )
        feats['macd'] = macd
        feats['macd_signal'] = signal
        feats['macd_histogram'] = hist

        # ATR (Average True Range)
        atr = self._calculate_atr(high, low, close, self.config.atr_period)
        feats['atr_normalized'] = atr / close

        # Bollinger Bands
        bb_mid, bb_upper, bb_lower = self._calculate_bollinger_bands(
            close, self.config.bb_period, self.config.bb_std
        )
        bb_width = bb_upper - bb_lower
        feats['bb_position'] = (close - bb_mid) / (bb_width + 1e-10)
        feats['bb_width_pct'] = bb_width / bb_mid

        # EMAs and distances
        assert self.config.ema_periods is not None
        for period in self.config.ema_periods:
            ema = close.ewm(span=period, adjust=False).mean()
            feats[f'ema_{period}_dist'] = (close - ema) / close

        # SMAs and distances
        assert self.config.sma_periods is not None
        for period in self.config.sma_periods:
            sma = close.rolling(period).mean()
            feats[f'sma_{period}_dist'] = (close - sma) / close

        # ADX (Average Directional Index)
        feats['adx'] = self._calculate_adx(high, low, close, self.config.adx_period)

        return feats

    def _compute_structure_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute market structure features.

        Features:
        - swing_high_distance: Distance to recent swing high
        - swing_low_distance: Distance to recent swing low
        - trend_strength: Linear regression slope
        - higher_highs: Count of higher highs in window
        - lower_lows: Count of lower lows in window
        """
        feats = pd.DataFrame(index=df.index)

        close = df['close']
        high = df['high']
        low = df['low']

        # Swing points (simplified - local maxima/minima, NO look-ahead)
        # CRITICAL FIX: Removed center=True which caused look-ahead bias
        window = 5
        swing_high = high.rolling(window * 2 + 1).max()
        swing_low = low.rolling(window * 2 + 1).min()

        feats['swing_high_distance'] = (swing_high - close) / close
        feats['swing_low_distance'] = (close - swing_low) / close

        # Trend strength (linear regression slope over 20 bars)
        feats['trend_strength'] = close.rolling(20).apply(
            lambda x: np.polyfit(np.arange(len(x)), x, 1)[0] if len(x) == 20 else np.nan,
            raw=True
        )

        # Higher highs / Lower lows (structure analysis)
        feats['higher_highs'] = high.rolling(10).apply(
            lambda x: np.sum(np.diff(x) > 0), raw=True
        )
        feats['lower_lows'] = low.rolling(10).apply(
            lambda x: np.sum(np.diff(x) < 0), raw=True
        )

        return feats

    def _compute_regime_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute regime detection features.

        Features:
        - hurst_exponent: Hurst exponent (persistence)
        - shannon_entropy: Shannon entropy (randomness)
        - variance_ratio: Variance ratio test (mean reversion)
        """
        feats = pd.DataFrame(index=df.index)

        close = df['close']

        # Hurst Exponent (simplified R/S method)
        feats['hurst_exponent'] = close.rolling(self.config.hurst_period).apply(
            lambda x: self._calculate_hurst_simple(x) if len(x) == self.config.hurst_period else np.nan,
            raw=True
        )

        # Shannon Entropy
        feats['shannon_entropy'] = close.pct_change().rolling(self.config.entropy_period).apply(
            lambda x: self._calculate_entropy(x) if len(x) == self.config.entropy_period else np.nan,
            raw=True
        )

        # Variance Ratio (simplified)
        feats['variance_ratio'] = close.pct_change().rolling(40).apply(
            lambda x: self._calculate_variance_ratio(x) if len(x) == 40 else np.nan,
            raw=True
        )

        return feats

    def _compute_statistical_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute statistical features.

        Features:
        - zscore: Z-score of price
        - skewness: Rolling skewness of returns
        - kurtosis: Rolling kurtosis of returns
        - autocorr: Autocorrelation lag 1
        """
        feats = pd.DataFrame(index=df.index)

        close = df['close']
        returns = close.pct_change()

        # Z-score
        rolling_mean = close.rolling(self.config.zscore_period).mean()
        rolling_std = close.rolling(self.config.zscore_period).std()
        feats['zscore'] = (close - rolling_mean) / (rolling_std + 1e-10)

        # Skewness (asymmetry of returns distribution)
        feats['skewness'] = returns.rolling(self.config.skew_period).skew()

        # Kurtosis (tail heaviness)
        feats['kurtosis'] = returns.rolling(self.config.kurt_period).kurt()

        # Autocorrelation (persistence)
        feats['autocorr_1'] = returns.rolling(20).apply(
            lambda x: x.autocorr(lag=1) if len(x) == 20 else np.nan,
            raw=False
        )

        return feats

    def _compute_temporal_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Compute temporal (time-based) features.

        Features:
        - hour_sin, hour_cos: Cyclical hour encoding
        - day_sin, day_cos: Cyclical day of week encoding
        - is_monday, is_friday: Boolean flags
        """
        feats = pd.DataFrame(index=df.index)

        # Extract datetime components
        hour = df.index.hour
        day_of_week = df.index.dayofweek

        # Cyclical encoding (preserves circular nature)
        feats['hour_sin'] = np.sin(2 * np.pi * hour / 24)
        feats['hour_cos'] = np.cos(2 * np.pi * hour / 24)

        feats['day_sin'] = np.sin(2 * np.pi * day_of_week / 7)
        feats['day_cos'] = np.cos(2 * np.pi * day_of_week / 7)

        # Special day flags
        feats['is_monday'] = (day_of_week == 0).astype(int)
        feats['is_friday'] = (day_of_week == 4).astype(int)

        return feats

    # =========================================================================
    # Helper Methods - Technical Calculations
    # =========================================================================

    def _calculate_rsi(self, series: pd.Series, period: int) -> pd.Series:
        """Calculate Relative Strength Index."""
        delta = series.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
        rs = gain / (loss + 1e-10)
        rsi = 100 - (100 / (1 + rs))
        return rsi

    def _calculate_macd(
        self,
        series: pd.Series,
        fast: int,
        slow: int,
        signal: int
    ) -> tuple[pd.Series, pd.Series, pd.Series]:
        """Calculate MACD, Signal, and Histogram."""
        ema_fast = series.ewm(span=fast, adjust=False).mean()
        ema_slow = series.ewm(span=slow, adjust=False).mean()
        macd = ema_fast - ema_slow
        signal_line = macd.ewm(span=signal, adjust=False).mean()
        histogram = macd - signal_line
        return macd, signal_line, histogram

    def _calculate_atr(
        self,
        high: pd.Series,
        low: pd.Series,
        close: pd.Series,
        period: int
    ) -> pd.Series:
        """Calculate Average True Range."""
        tr1 = high - low
        tr2 = np.abs(high - close.shift(1))
        tr3 = np.abs(low - close.shift(1))
        tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
        atr = tr.rolling(period).mean()
        return atr

    def _calculate_bollinger_bands(
        self,
        series: pd.Series,
        period: int,
        std_dev: float
    ) -> tuple[pd.Series, pd.Series, pd.Series]:
        """Calculate Bollinger Bands."""
        mid = series.rolling(period).mean()
        std = series.rolling(period).std()
        upper = mid + (std * std_dev)
        lower = mid - (std * std_dev)
        return mid, upper, lower

    def _calculate_adx(
        self,
        high: pd.Series,
        low: pd.Series,
        close: pd.Series,
        period: int
    ) -> pd.Series:
        """Calculate Average Directional Index."""
        # +DM and -DM
        high_diff = high.diff()
        low_diff = -low.diff()

        plus_dm = high_diff.where((high_diff > low_diff) & (high_diff > 0), 0)
        minus_dm = low_diff.where((low_diff > high_diff) & (low_diff > 0), 0)

        # ATR
        atr = self._calculate_atr(high, low, close, period)

        # +DI and -DI
        plus_di = 100 * (plus_dm.rolling(period).mean() / (atr + 1e-10))
        minus_di = 100 * (minus_dm.rolling(period).mean() / (atr + 1e-10))

        # DX
        dx = 100 * np.abs(plus_di - minus_di) / (plus_di + minus_di + 1e-10)

        # ADX
        adx = dx.rolling(period).mean()

        return adx

    # =========================================================================
    # Helper Methods - Regime Detection
    # =========================================================================

    def _calculate_hurst_simple(self, series: np.ndarray[Any, Any]) -> float:
        """
        Calculate Hurst Exponent using simplified R/S method.

        Returns:
            Hurst exponent (0.5 = random walk, >0.5 = trending, <0.5 = mean reverting)
        """
        if len(series) < 20:
            return 0.5

        try:
            # Calculate log returns
            log_returns = np.diff(np.log(series + 1e-10))

            # Mean-adjusted series
            mean_adj = log_returns - np.mean(log_returns)

            # Cumulative sum
            cumsum = np.cumsum(mean_adj)

            # Range
            r_value: float = float(np.max(cumsum) - np.min(cumsum))

            # Standard deviation
            s_value: float = float(np.std(log_returns))

            if s_value == 0.0 or r_value == 0.0:
                return 0.5

            # R/S ratio
            rs = r_value / s_value

            # Hurst = log(R/S) / log(n)
            n = len(series)
            hurst = float(np.log(rs) / np.log(n))

            # Clip to reasonable range
            return float(np.clip(hurst, 0.0, 1.0))

        except Exception as e:
            logger.warning(f"Hurst calculation failed: {e}")
            return 0.5

    def _calculate_entropy(self, series: np.ndarray[Any, Any]) -> float:
        """
        Calculate Shannon Entropy of returns.

        Returns:
            Entropy value (higher = more random/uncertain)
        """
        if len(series) < 10:
            return 0.0

        try:
            # Remove NaN
            series = series[~np.isnan(series)]

            if len(series) == 0:
                return 0.0

            # Create histogram (10 bins)
            hist, _ = np.histogram(series, bins=10, density=True)

            # Remove zero bins
            hist = hist[hist > 0]

            if len(hist) == 0:
                return 0.0

            # Normalize
            hist = hist / np.sum(hist)

            # Shannon entropy
            entropy_value: float = float(-np.sum(hist * np.log(hist + 1e-10)))

            return entropy_value

        except Exception as e:
            logger.warning(f"Entropy calculation failed: {e}")
            return 0.0

    def _calculate_variance_ratio(self, series: np.ndarray[Any, Any]) -> float:
        """
        Calculate Variance Ratio (Lo-MacKinlay test).

        Returns:
            Variance ratio (1.0 = random walk, >1 = trending, <1 = mean reverting)
        """
        if len(series) < 20:
            return 1.0

        try:
            # Remove NaN
            series = series[~np.isnan(series)]

            if len(series) < 20:
                return 1.0

            # Variance of 1-period returns
            var_1 = float(np.var(series))

            if var_1 == 0:
                return 1.0

            # Variance of 2-period returns
            returns_2 = series[::2]  # Every 2nd element
            var_2 = float(np.var(returns_2))

            # Variance ratio
            # Theory: VR = Var(2) / (2 * Var(1))
            vr = var_2 / (2 * var_1 + 1e-10)

            return float(np.clip(vr, 0.1, 3.0))

        except Exception as e:
            logger.warning(f"Variance ratio calculation failed: {e}")
            return 1.0

    # =========================================================================
    # Scaling Methods
    # =========================================================================

    def scale_features(
        self,
        features: pd.DataFrame,
        method: str = 'standard',
        fit: bool = True
    ) -> pd.DataFrame:
        """
        Scale features for ML model input.

        IMPORTANT: To prevent data leakage in train/test scenarios:
        1. Call with fit=True on TRAINING data only
        2. Call with fit=False on TEST data (uses scaler fitted on train)

        Example:
            # Correct usage - prevents leakage
            train_scaled = engineer.scale_features(train_features, fit=True)
            test_scaled = engineer.scale_features(test_features, fit=False)

            # Or use the helper method:
            train_scaled, test_scaled = engineer.scale_train_test(train_features, test_features)

        Args:
            features: DataFrame of features to scale
            method: 'standard' (StandardScaler) or 'robust' (RobustScaler)
            fit: If True, fit the scaler on this data. If False, use existing scaler.

        Returns:
            Scaled features DataFrame

        Raises:
            ValueError: If fit=False but scaler not fitted yet.
        """
        if fit:
            if method == 'standard':
                self.scaler = StandardScaler()
            elif method == 'robust':
                self.scaler = RobustScaler()
            else:
                raise ValueError(f"Unknown scaling method: {method}")

            scaled_array = self.scaler.fit_transform(features)
        else:
            if self.scaler is None:
                raise ValueError("Scaler not fitted. Call with fit=True first.")
            scaled_array = self.scaler.transform(features)

        # Return as DataFrame with same index and columns
        scaled_df = pd.DataFrame(
            scaled_array,
            index=features.index,
            columns=features.columns
        )

        return scaled_df

    def scale_train_test(
        self,
        train_features: pd.DataFrame,
        test_features: pd.DataFrame,
        method: str = 'standard'
    ) -> tuple[pd.DataFrame, pd.DataFrame]:
        """
        Scale train and test features without data leakage.

        This helper method ensures the scaler is fit ONLY on training data,
        then applied to both train and test. This prevents leakage of test
        statistics into the training process.

        Args:
            train_features: Training features DataFrame (used to fit scaler).
            test_features: Test features DataFrame (transformed only, no fitting).
            method: 'standard' (StandardScaler) or 'robust' (RobustScaler).

        Returns:
            Tuple of (scaled_train, scaled_test) DataFrames.

        Example:
            train_scaled, test_scaled = engineer.scale_train_test(train_features, test_features)
        """
        # Fit scaler on training data only
        scaled_train = self.scale_features(train_features, method=method, fit=True)

        # Apply same scaler to test data (no fitting)
        scaled_test = self.scale_features(test_features, method=method, fit=False)

        return scaled_train, scaled_test

    def get_feature_names(self) -> list[str]:
        """
        Get list of all feature names.

        Returns:
            List of feature names in order.
        """
        return self.feature_names.copy()

    def get_feature_importance_groups(self) -> dict[str, list[str]]:
        """
        Get features grouped by category.

        Returns:
            Dictionary mapping category name to list of feature names.
        """
        groups: dict[str, list[str]] = {
            'price': [],
            'volume': [],
            'technical': [],
            'structure': [],
            'regime': [],
            'statistical': [],
            'temporal': [],
        }

        for feat in self.feature_names:
            if any(x in feat for x in ['returns', 'gap', 'shadow', 'body', 'range', 'roc']):
                groups['price'].append(feat)
            elif any(x in feat for x in ['volume', 'vwap', 'delta']):
                groups['volume'].append(feat)
            elif any(x in feat for x in ['rsi', 'macd', 'atr', 'bb', 'ema', 'sma', 'adx']):
                groups['technical'].append(feat)
            elif any(x in feat for x in ['swing', 'trend', 'higher', 'lower']):
                groups['structure'].append(feat)
            elif any(x in feat for x in ['hurst', 'entropy', 'variance_ratio']):
                groups['regime'].append(feat)
            elif any(x in feat for x in ['zscore', 'skewness', 'kurtosis', 'autocorr']):
                groups['statistical'].append(feat)
            elif any(x in feat for x in ['hour', 'day', 'monday', 'friday']):
                groups['temporal'].append(feat)

        return groups


def main() -> None:
    """Example usage and testing."""
    # Create sample OHLCV data
    np.random.seed(42)
    n = 1000

    dates = pd.date_range(start='2024-01-01', periods=n, freq='5min')

    # Generate realistic price data (gold around 2000)
    base_price = 2000
    returns = np.random.normal(0.0001, 0.003, n)
    prices = base_price * np.exp(np.cumsum(returns))

    df = pd.DataFrame({
        'open': prices + np.random.normal(0, 0.5, n),
        'high': prices + np.abs(np.random.normal(2, 1, n)),
        'low': prices - np.abs(np.random.normal(2, 1, n)),
        'close': prices,
        'volume': np.random.randint(100, 1000, n),
    }, index=dates)

    # Ensure high >= close >= low
    df['high'] = df[['high', 'close', 'open']].max(axis=1)
    df['low'] = df[['low', 'close', 'open']].min(axis=1)

    print("Sample OHLCV data:")
    print(df.head())
    print(f"\nShape: {df.shape}")

    # Create feature engineer
    print("\n" + "="*60)
    print("FEATURE ENGINEERING")
    print("="*60)

    config = FeatureConfig()
    engineer = FeatureEngineer(config)

    # Compute all features
    print("\nComputing all features...")
    features = engineer.compute_all_features(df)

    print(f"\nFeatures computed: {features.shape}")
    print(f"Feature count: {len(engineer.get_feature_names())}")

    # Show feature groups
    groups = engineer.get_feature_importance_groups()
    print("\nFeatures by category:")
    for category, feats in groups.items():
        print(f"  {category:12s}: {len(feats):2d} features")

    # Show sample features
    print("\nSample features (first 5 rows):")
    print(features.head())

    # Scale features
    print("\nScaling features...")
    scaled = engineer.scale_features(features, method='standard')

    print(f"\nScaled features: {scaled.shape}")
    print("\nScaled sample (first 5 rows, first 10 cols):")
    print(scaled.iloc[:5, :10])

    # Show summary statistics
    print("\nFeature statistics (after scaling):")
    print(scaled.describe().loc[['mean', 'std', 'min', 'max']])

    print("\n" + "="*60)
    print("FEATURE ENGINEERING COMPLETE")
    print("="*60)


if __name__ == '__main__':
    main()
