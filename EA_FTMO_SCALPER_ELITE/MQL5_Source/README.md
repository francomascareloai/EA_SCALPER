# 🔧 CÓDIGO FONTE MQL5 - EA FTMO SCALPER ELITE

## 🎯 PROPÓSITO
Esta pasta contém todo o código fonte MQL5 do Expert Advisor, organizado por módulos e funcionalidades.

## 📁 ESTRUTURA DE PASTAS

```
MQL5_Source/
├── Source/                    # Código fonte principal
│   ├── Core/                  # Módulos base do sistema
│   ├── Strategies/            # Estratégias de trading
│   │   ├── ICT/              # Conceitos ICT/SMC
│   │   └── Volume/           # Análise de volume
│   ├── Utils/                # Utilitários e helpers
│   ├── Indicators/           # Indicadores customizados
│   └── Tests/                # Testes automatizados
├── Config/                   # Arquivos de configuração
└── Logs/                     # Logs do sistema
```

## 📋 ÍNDICE DE ARQUIVOS

### 🏗️ **Core/ - Módulos Base**

#### ✅ **DataStructures.mqh**
- **Tipo**: Header - Estruturas de Dados
- **Conteúdo**: Enums, structs, constantes do sistema
- **Uso**: Include obrigatório em todos os módulos
- **Tags**: #Core #DataStructures #Base #Constants

#### ✅ **Interfaces.mqh**
- **Tipo**: Header - Interfaces Abstratas  
- **Conteúdo**: Contratos para todos os módulos
- **Uso**: Base para implementação de classes
- **Tags**: #Core #Interfaces #Abstract #Contracts

#### ✅ **Logger.mqh**
- **Tipo**: Header - Sistema de Logging
- **Conteúdo**: Classe CLogger para logs estruturados
- **Uso**: Logging em todos os módulos
- **Tags**: #Core #Logging #Debug #Monitoring

#### ✅ **ConfigManager.mqh**
- **Tipo**: Header - Gerenciamento de Configuração
- **Conteúdo**: Classe CConfigManager para parâmetros
- **Uso**: Centralização de configurações
- **Tags**: #Core #Config #Parameters #Settings

#### ✅ **CacheManager.mqh**
- **Tipo**: Header - Sistema de Cache
- **Conteúdo**: Classe CCacheManager para otimização
- **Uso**: Cache de dados e cálculos
- **Tags**: #Core #Cache #Performance #Optimization

#### ✅ **PerformanceAnalyzer.mqh**
- **Tipo**: Header - Análise de Performance
- **Conteúdo**: Classe CPerformanceAnalyzer para métricas
- **Uso**: Monitoramento de performance
- **Tags**: #Core #Performance #Analytics #Metrics

### 🎯 **Strategies/ICT/ - Conceitos ICT/SMC**

#### ✅ **OrderBlockDetector.mqh**
- **Tipo**: Header - Detector de Order Blocks
- **Conteúdo**: Classe COrderBlockDetector
- **Uso**: Identificação de Order Blocks institucionais
- **Tags**: #ICT #OrderBlocks #Institutional #Detection

#### ✅ **FVGDetector.mqh**
- **Tipo**: Header - Detector de Fair Value Gaps
- **Conteúdo**: Classe CFVGDetector
- **Uso**: Identificação de FVGs (imbalances)
- **Tags**: #ICT #FVG #Imbalance #GapAnalysis

#### ✅ **LiquidityDetector.mqh**
- **Tipo**: Header - Detector de Liquidez
- **Conteúdo**: Classe CLiquidityDetector
- **Uso**: Identificação de zonas de liquidez
- **Tags**: #ICT #Liquidity #SwingPoints #StopHunt

#### ⏳ **MarketStructureAnalyzer.mqh** (Pendente)
- **Tipo**: Header - Análise de Estrutura de Mercado
- **Conteúdo**: Classe CMarketStructureAnalyzer
- **Uso**: Análise BOS, CHoCH, trend structure
- **Tags**: #ICT #MarketStructure #BOS #CHoCH

### 📊 **Strategies/Volume/ - Análise de Volume**

#### ⏳ **VolumeAnalyzer.mqh** (Pendente)
- **Tipo**: Header - Análise de Volume
- **Conteúdo**: Classe CVolumeAnalyzer
- **Uso**: Análise de volume e fluxo institucional
- **Tags**: #Volume #Flow #Institutional #Analysis

### 🛡️ **Módulos Pendentes**

#### ⏳ **RiskManager.mqh** (Pendente)
- **Tipo**: Header - Gerenciamento de Risco
- **Conteúdo**: Classe CRiskManager
- **Uso**: Controle de risco e position sizing
- **Tags**: #Risk #Management #PositionSizing #FTMO

#### ⏳ **TradingEngine.mqh** (Pendente)
- **Tipo**: Header - Motor de Trading
- **Conteúdo**: Classe CTradingEngine
- **Uso**: Execução de ordens e gerenciamento
- **Tags**: #Trading #Engine #Execution #Orders

#### ⏳ **AlertSystem.mqh** (Pendente)
- **Tipo**: Header - Sistema de Alertas
- **Conteúdo**: Classe CAlertSystem
- **Uso**: Notificações e alertas
- **Tags**: #Alerts #Notifications #Monitoring

### 🚀 **ARQUIVO PRINCIPAL** (Pendente)

#### ⏳ **EA_FTMO_Scalper_Elite.mq5** (Pendente)
- **Tipo**: Expert Advisor Principal
- **Conteúdo**: Integração de todos os módulos
- **Uso**: Arquivo principal do EA
- **Tags**: #EA #Main #Integration #FTMO

## 🔄 DEPENDÊNCIAS

### Ordem de Compilação:
1. **DataStructures.mqh** (base)
2. **Interfaces.mqh** (contratos)
3. **Core modules** (Logger, Config, Cache, Performance)
4. **Strategy modules** (ICT, Volume)
5. **Trading modules** (Risk, Engine, Alerts)
6. **EA_FTMO_Scalper_Elite.mq5** (principal)

### Includes Obrigatórios:
```mql5
#include "Core/DataStructures.mqh"
#include "Core/Interfaces.mqh"
#include "Core/Logger.mqh"
// ... outros includes conforme necessário
```

## 🏷️ SISTEMA DE TAGS

### Por Categoria:
- **#Core**: Módulos base do sistema
- **#ICT**: Conceitos ICT/SMC
- **#Volume**: Análise de volume
- **#Risk**: Gerenciamento de risco
- **#Trading**: Execução de trades
- **#FTMO**: Compliance FTMO

### Por Status:
- **#Completo**: ✅ Implementado e testado
- **#Pendente**: ⏳ Aguardando implementação
- **#EmAndamento**: 🔄 Sendo desenvolvido
- **#Teste**: 🧪 Em fase de testes

### Por Prioridade:
- **#Critico**: Essencial para funcionamento
- **#Alto**: Importante para performance
- **#Medio**: Funcionalidade adicional
- **#Baixo**: Nice to have

## 🧪 ESTRATÉGIA DE TESTES

### Unit Tests:
- Cada classe deve ter testes unitários
- Cobertura mínima: 90%
- Localização: `Tests/UnitTests/`

### Integration Tests:
- Testes de integração entre módulos
- Cenários de trading reais
- Localização: `Tests/IntegrationTests/`

### Performance Tests:
- Benchmarks de performance
- Testes de stress
- Localização: `Tests/PerformanceTests/`

## 📊 MÉTRICAS DE QUALIDADE

### Código:
- **Cobertura de Testes**: > 90%
- **Complexidade Ciclomática**: < 10
- **Linhas por Função**: < 50
- **Documentação**: 100% das funções públicas

### Performance:
- **Tempo de Execução OnTick**: < 100ms
- **Uso de Memória**: < 50MB
- **CPU Usage**: < 5%
- **Latência de Ordens**: < 50ms

## 🔧 PADRÕES DE CÓDIGO

### Nomenclatura:
- **Classes**: PascalCase (ex: `COrderBlockDetector`)
- **Métodos**: PascalCase (ex: `DetectOrderBlocks`)
- **Variáveis**: camelCase (ex: `orderBlockData`)
- **Constantes**: UPPER_CASE (ex: `MAX_ORDER_BLOCKS`)

### Estrutura de Arquivo:
```mql5
//+------------------------------------------------------------------+
//| Nome do Arquivo                                                  |
//| Descrição breve                                                  |
//+------------------------------------------------------------------+

// Includes
#include "..."

// Constantes
#define CONSTANT_NAME value

// Enumerações
enum ENUM_NAME { ... };

// Estruturas
struct STRUCT_NAME { ... };

// Classe Principal
class CClassName : public IInterface
{
private:
    // Membros privados
    
public:
    // Construtor/Destrutor
    // Métodos públicos
};

// Instância global (se necessário)
CClassName g_instance;
```

---
*Gerado por TradeDev_Master - Sistema de Documentação de Código*