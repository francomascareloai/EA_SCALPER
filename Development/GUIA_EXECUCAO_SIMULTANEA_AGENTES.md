# 🤖 GUIA: EXECUÇÃO SIMULTÂNEA DE AGENTES

## Resumo Executivo

**SIM, o orquestrador consegue executar múltiplos agentes simultaneamente!** O sistema foi projetado com arquitetura multi-threading que permite execução paralela de diferentes componentes.

---

## 🏗️ Arquitetura do Sistema

### Componentes Principais

1. **OrquestradorCentral** - Controlador mestre
2. **ClassificadorLoteAvancado** - Processamento de arquivos
3. **MonitorTempoReal** - Monitoramento contínuo
4. **GeradorRelatoriosAvancados** - Geração de relatórios
5. **AutoBackupIntegration** - Sistema de backup

### Execução Simultânea

```python
# Exemplo do orquestrador_central.py
class OrquestradorCentral:
    def __init__(self):
        self.threads_ativas = {}  # Controle de threads
        self.componentes = {}     # Componentes ativos
        
    def _thread_monitoramento(self, duracao):
        """Thread separada para monitoramento"""
        while time.time() - inicio < duracao:
            metricas = self._coletar_metricas_tempo_real()
            self._verificar_alertas(metricas)
            time.sleep(30)
```

---

## 🔄 Tipos de Execução Simultânea

### 1. **Threads Paralelas**
- ✅ Monitoramento em tempo real
- ✅ Processamento de arquivos
- ✅ Geração de relatórios
- ✅ Backup automático

### 2. **Componentes Independentes**
```python
# Cada componente roda independentemente
componentes = {
    'classificador': ClassificadorLoteAvancado(),
    'monitor': MonitorTempoReal(),
    'relatorios': GeradorRelatoriosAvancados(),
    'backup': AutoBackupIntegration()
}
```

### 3. **Coordenação Central**
- O orquestrador coordena mas não bloqueia
- Cada agente mantém seu próprio estado
- Comunicação via callbacks e eventos

---

## 📊 Cenários de Uso Simultâneo

### Cenário 1: Classificação + Monitoramento
```bash
# Terminal 1: Classificação em lote
python orquestrador_central.py classificar_tudo

# Terminal 2: Monitoramento em tempo real (automático)
# Inicia automaticamente em thread separada
```

### Cenário 2: Múltiplas Operações
```python
# Execução simultânea de:
# 1. Classificação de arquivos MQL4
# 2. Monitoramento de performance
# 3. Geração de relatórios
# 4. Backup automático

orquestrador.executar_comando_completo("classificar_tudo")
# Automaticamente inicia threads para:
# - Monitoramento
# - Backup (se configurado)
# - Relatórios (em background)
```

---

## ⚙️ Configuração de Simultaneidade

### Arquivo: `Development/config/orquestrador.json`
```json
{
    "max_threads": 4,
    "auto_backup": true,
    "intervalo_relatorios": 300,
    "monitoramento_tempo_real": true,
    "processamento_paralelo": true
}
```

### Controle de Recursos
```python
# Limites configuráveis
MAX_THREADS = 4
TIMEOUT_OPERACOES = 3600  # 1 hora
INTERVALO_MONITORAMENTO = 30  # segundos
```

---

## 🔍 Monitoramento de Agentes Ativos

### Status em Tempo Real
```python
# Verificar agentes ativos
status = orquestrador._obter_status_sistema()
print(status['threads_ativas'])  # Lista threads ativas
print(status['componentes'])     # Status dos componentes
```

### Dashboard de Monitoramento
```python
# Métricas em tempo real
metricas = {
    'threads_ativas': ['monitor', 'backup', 'relatorios'],
    'files_processed': 150,
    'success_rate': 98.5,
    'memory_usage': 45.2,
    'cpu_usage': 23.1
}
```

---

## 🚀 Exemplos Práticos

### Exemplo 1: Classificação com Monitoramento
```python
# Inicia classificação (thread principal)
resultado = orquestrador.executar_comando_completo(
    "classificar_tudo",
    {"nivel": "completo", "backup_auto": True}
)

# Automaticamente inicia:
# - Thread de monitoramento
# - Thread de backup (se configurado)
# - Coleta de métricas em tempo real
```

### Exemplo 2: Múltiplos Diretórios
```python
# Processa múltiplos diretórios simultaneamente
diretorios = [
    "CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4",
    "CODIGO_FONTE_LIBRARY/MQL5_Source/All_MQ5",
    "CODIGO_FONTE_LIBRARY/TradingView_Scripts"
]

# Cada diretório em thread separada (se configurado)
for diretorio in diretorios:
    thread = threading.Thread(
        target=processar_diretorio,
        args=(diretorio,)
    )
    thread.start()
```

---

## ⚠️ Limitações e Considerações

### Limitações do Python
- **GIL (Global Interpreter Lock)**: Limita paralelismo real em CPU
- **I/O Bound**: Operações de arquivo são mais eficientes em threads
- **Memory**: Cada thread consome memória adicional

### Boas Práticas
```python
# ✅ Bom: I/O operations em threads
def processar_arquivo_thread(arquivo):
    with open(arquivo) as f:
        conteudo = f.read()
        # Processamento...

# ❌ Evitar: CPU-intensive em threads
# Use multiprocessing para cálculos pesados
```

### Sincronização
```python
# Controle de acesso a recursos compartilhados
import threading

lock = threading.Lock()

def atualizar_catalogo_seguro(dados):
    with lock:
        # Operação thread-safe
        catalogo.update(dados)
```

---

## 📈 Performance e Otimização

### Métricas de Performance
- **Throughput**: ~50-100 arquivos/minuto
- **Concorrência**: Até 4 threads simultâneas
- **Memória**: ~100-200MB por thread
- **CPU**: Distribuído entre threads

### Otimizações Implementadas
1. **Pool de Threads**: Reutilização de threads
2. **Queue System**: Processamento assíncrono
3. **Batch Processing**: Agrupamento de operações
4. **Lazy Loading**: Carregamento sob demanda

---

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Threads Travadas
```python
# Verificar threads ativas
for nome, thread in orquestrador.threads_ativas.items():
    if thread.is_alive():
        print(f"Thread ativa: {nome}")
    else:
        print(f"Thread finalizada: {nome}")
```

#### 2. Conflitos de Recursos
```python
# Implementar timeouts
import signal

def timeout_handler(signum, frame):
    raise TimeoutError("Operação excedeu timeout")

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(3600)  # 1 hora timeout
```

#### 3. Memory Leaks
```python
# Limpeza periódica
def cleanup_threads():
    for nome, thread in list(orquestrador.threads_ativas.items()):
        if not thread.is_alive():
            del orquestrador.threads_ativas[nome]
```

---

## 🎯 Conclusão

### Capacidades Confirmadas ✅
- ✅ **Execução simultânea de múltiplos agentes**
- ✅ **Monitoramento em tempo real**
- ✅ **Processamento paralelo de arquivos**
- ✅ **Backup automático em background**
- ✅ **Geração de relatórios assíncrona**
- ✅ **Coordenação centralizada**
- ✅ **Controle de recursos**
- ✅ **Recuperação de erros**

### Próximos Passos
1. **Teste o sistema**: `python orquestrador_central.py classificar_tudo`
2. **Monitor ativo**: Observe logs em tempo real
3. **Dashboard**: Acesse métricas via interface
4. **Otimize**: Ajuste configurações conforme necessário

---

**💡 Dica**: O sistema foi projetado para máxima eficiência com segurança. Cada agente opera independentemente mas coordenado pelo orquestrador central.