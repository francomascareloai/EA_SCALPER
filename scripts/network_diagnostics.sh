#!/bin/bash
# Network Diagnostics Script for EA_SCALPER_XAUUSD
# Usage: ./network_diagnostics.sh

echo "=== DIAGNÓSTICO DE REDE PARA TRADING ==="
echo "Data: $(date)"
echo ""

# 1. Latência básica
echo "[1/6] Testando latência para brokers MT5..."
BROKERS=("trade.mql5.com" "mt5.fxpro.com" "icmarkets-mt5.com")
for broker in "${BROKERS[@]}"; do
    PING=$(ping -c 3 -W 2 $broker 2>/dev/null | grep avg | cut -d'/' -f5)
    if [ -n "$PING" ]; then
        echo "  ✓ $broker: ${PING}ms"
    else
        echo "  ✗ $broker: FALHA DE CONEXÃO"
    fi
done

# 2. DNS resolução
echo ""
echo "[2/6] Verificando resolução DNS..."
DNS_TIME=$(dig +stats trade.mql5.com | grep "Query time:" | awk '{print $4}')
echo "  DNS lookup: ${DNS_TIME}ms"

# 3. Portas TCP
echo ""
echo "[3/6] Testando portas do broker (443, 8443)..."
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/trade.mql5.com/443' 2>/dev/null && echo "  ✓ Porta 443: ABERTA" || echo "  ✗ Porta 443: BLOQUEADA"

# 4. TLS Handshake timing
echo ""
echo "[4/6] Medindo TLS handshake..."
TLS_TIME=$(curl -o /dev/null -s -w "%{time_appconnect}\n" https://trade.mql5.com 2>/dev/null)
echo "  TLS handshake: ${TLS_TIME}s"

# 5. Packet loss test
echo ""
echo "[5/6] Teste de perda de pacotes (20 pings)..."
LOSS=$(ping -c 20 -i 0.2 trade.mql5.com 2>/dev/null | grep loss | awk '{print $6}')
echo "  Perda de pacotes: $LOSS"

# 6. Conexões ativas
echo ""
echo "[6/6] Conexões TCP ativas na porta 443..."
CONNS=$(ss -tn state established '( dport = :443 or sport = :443 )' 2>/dev/null | wc -l)
echo "  Conexões estabelecidas: $CONNS"

echo ""
echo "=== DIAGNÓSTICO CONCLUÍDO ==="
