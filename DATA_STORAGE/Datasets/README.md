# 📊 DATASETS - BIBLIOTECA DE DADOS

## 🎯 PROPÓSITO
Esta pasta contém datasets organizados para análise, backtesting e desenvolvimento de estratégias de trading.

## 📁 ESTRUTURA

### Dados Históricos:
- **XAUUSD/**: Dados históricos do ouro
- **EURUSD/**: Dados do par EUR/USD
- **Indices/**: Dados de índices (NAS100, SPX500, etc.)

### Formatos Suportados:
- **.csv**: Dados OHLCV padrão
- **.hst**: Arquivos históricos MT4/MT5
- **.json**: Dados estruturados para análise

### Timeframes Disponíveis:
- M1, M5, M15, M30, H1, H4, D1

## 🔧 UTILIZAÇÃO

### Para Backtesting:
```
Datasets/XAUUSD/M5_2024.csv
Datasets/EURUSD/H1_2024.csv
```

### Para Análise:
```
Datasets/Analysis/volume_profile_XAUUSD.json
Datasets/Analysis/session_statistics.csv
```

## 📋 CONVENÇÕES

### Nomenclatura:
```
[SYMBOL]_[TIMEFRAME]_[YEAR].csv
XAUUSD_M5_2024.csv
```

### Formato CSV Padrão:
```
DateTime,Open,High,Low,Close,Volume
2024-01-01 00:00:00,2072.50,2073.20,2071.80,2072.90,1250
```

---
*Última atualização: 2025-01-10*
*Classificador_Trading v1.0*