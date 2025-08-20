#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Interface Gráfica em Tempo Real - Sistema de Otimização Contínua
Classificador_Trading - Elite AI para Trading Code Organization

Interface web moderna para monitoramento em tempo real do sistema de otimização.
"""

import os
import sys
import json
import time
import threading
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
from flask import Flask, render_template, jsonify, request
from flask_socketio import SocketIO, emit
import logging

# Importar sistema de otimização
from sistema_otimizacao_continua import ContinuousOptimizationSystem

# Configuração de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuração Flask
app = Flask(__name__)
app.config['SECRET_KEY'] = 'classificador_trading_elite_ai_2024'
socketio = SocketIO(app, cors_allowed_origins="*")

# Sistema de otimização global
optimization_system = None
optimization_thread = None
real_time_data = {
    "is_running": False,
    "current_cycle": 0,
    "current_state": {},
    "cycles_history": [],
    "performance_metrics": {},
    "logs": [],
    "last_update": None
}

def add_log(message: str, level: str = "info"):
    """Adiciona log ao sistema"""
    timestamp = datetime.now().strftime('%H:%M:%S')
    log_entry = {
        "timestamp": timestamp,
        "message": message,
        "level": level
    }
    real_time_data["logs"].append(log_entry)
    
    # Manter apenas os últimos 100 logs
    if len(real_time_data["logs"]) > 100:
        real_time_data["logs"] = real_time_data["logs"][-100:]
    
    # Emitir para clientes conectados
    socketio.emit('new_log', log_entry)

def update_real_time_data():
    """Atualiza dados em tempo real"""
    global optimization_system
    
    if optimization_system:
        status = optimization_system.get_real_time_status()
        real_time_data.update(status)
        real_time_data["last_update"] = datetime.now().isoformat()
        
        # Emitir atualização para clientes
        socketio.emit('data_update', real_time_data)

def optimization_worker():
    """Worker thread para executar otimização"""
    global optimization_system
    
    try:
        add_log("🚀 Iniciando Sistema de Otimização Contínua", "success")
        
        # Inicializar sistema
        base_path = Path.cwd()
        optimization_system = ContinuousOptimizationSystem(str(base_path))
        optimization_system.initialize_system()
        
        add_log("✅ Sistema inicializado com sucesso", "success")
        
        # Executar otimização contínua
        optimization_system.run_continuous_optimization()
        
        add_log("🏁 Otimização contínua finalizada", "info")
        
    except Exception as e:
        add_log(f"❌ Erro durante otimização: {e}", "error")
        logger.error(f"Erro no worker de otimização: {e}")
    finally:
        real_time_data["is_running"] = False
        update_real_time_data()

@app.route('/')
def index():
    """Página principal"""
    return render_template('optimization_monitor.html')

@app.route('/api/status')
def get_status():
    """API para obter status atual"""
    return jsonify(real_time_data)

@app.route('/api/start', methods=['POST'])
def start_optimization():
    """API para iniciar otimização"""
    global optimization_thread
    
    if real_time_data["is_running"]:
        return jsonify({"error": "Otimização já está em execução"}), 400
    
    # Iniciar thread de otimização
    optimization_thread = threading.Thread(target=optimization_worker)
    optimization_thread.daemon = True
    optimization_thread.start()
    
    real_time_data["is_running"] = True
    add_log("▶️ Otimização iniciada pelo usuário", "info")
    
    return jsonify({"message": "Otimização iniciada com sucesso"})

@app.route('/api/stop', methods=['POST'])
def stop_optimization():
    """API para parar otimização"""
    global optimization_system
    
    if not real_time_data["is_running"]:
        return jsonify({"error": "Nenhuma otimização em execução"}), 400
    
    if optimization_system:
        optimization_system.is_running = False
    
    real_time_data["is_running"] = False
    add_log("⏹️ Otimização interrompida pelo usuário", "warning")
    
    return jsonify({"message": "Otimização interrompida"})

@app.route('/api/export', methods=['POST'])
def export_results():
    """API para exportar resultados"""
    try:
        if optimization_system:
            optimization_system._generate_final_report()
            add_log("📊 Relatório final exportado com sucesso", "success")
            return jsonify({"message": "Relatório exportado com sucesso"})
        else:
            return jsonify({"error": "Sistema não inicializado"}), 400
    except Exception as e:
        add_log(f"❌ Erro ao exportar: {e}", "error")
        return jsonify({"error": str(e)}), 500

@socketio.on('connect')
def handle_connect():
    """Cliente conectado"""
    emit('data_update', real_time_data)
    add_log("👤 Cliente conectado à interface", "info")

@socketio.on('disconnect')
def handle_disconnect():
    """Cliente desconectado"""
    add_log("👤 Cliente desconectado da interface", "info")

# Thread para atualização contínua
def update_thread():
    """Thread para atualizar dados continuamente"""
    while True:
        try:
            update_real_time_data()
            time.sleep(2)  # Atualizar a cada 2 segundos
        except Exception as e:
            logger.error(f"Erro na thread de atualização: {e}")
            time.sleep(5)

# Template HTML embutido
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classificador Trading - Otimização Contínua</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.0.1/socket.io.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            min-height: 100vh;
        }
        
        .header {
            background: rgba(0,0,0,0.3);
            padding: 20px;
            text-align: center;
            border-bottom: 2px solid #4CAF50;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .controls {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
        }
        
        .btn-start {
            background: #4CAF50;
            color: white;
        }
        
        .btn-stop {
            background: #f44336;
            color: white;
        }
        
        .btn-export {
            background: #2196F3;
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .dashboard {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: rgba(255,255,255,0.1);
            border-radius: 12px;
            padding: 20px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
        }
        
        .card h3 {
            margin-bottom: 15px;
            color: #4CAF50;
            font-size: 1.3em;
        }
        
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .metric {
            text-align: center;
            padding: 15px;
            background: rgba(0,0,0,0.2);
            border-radius: 8px;
        }
        
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .metric-label {
            font-size: 0.9em;
            opacity: 0.8;
        }
        
        .status {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #f44336;
        }
        
        .status-indicator.running {
            background: #4CAF50;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        .progress-section {
            margin-bottom: 30px;
        }
        
        .progress-bar {
            width: 100%;
            height: 20px;
            background: rgba(0,0,0,0.3);
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #4CAF50, #8BC34A);
            transition: width 0.5s ease;
        }
        
        .chart-container {
            height: 300px;
            margin-top: 20px;
        }
        
        .logs {
            grid-column: 1 / -1;
            max-height: 400px;
            overflow-y: auto;
        }
        
        .log-entry {
            padding: 8px 12px;
            margin-bottom: 5px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .log-info {
            background: rgba(33, 150, 243, 0.2);
            border-left: 3px solid #2196F3;
        }
        
        .log-success {
            background: rgba(76, 175, 80, 0.2);
            border-left: 3px solid #4CAF50;
        }
        
        .log-warning {
            background: rgba(255, 193, 7, 0.2);
            border-left: 3px solid #FFC107;
        }
        
        .log-error {
            background: rgba(244, 67, 54, 0.2);
            border-left: 3px solid #f44336;
        }
        
        .cycles-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .cycles-table th,
        .cycles-table td {
            padding: 10px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .cycles-table th {
            background: rgba(0,0,0,0.3);
            font-weight: bold;
        }
        
        .improvement-positive {
            color: #4CAF50;
        }
        
        .improvement-negative {
            color: #f44336;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Classificador Trading - Elite AI</h1>
        <p>Sistema de Otimização Contínua Multi-Agente em Tempo Real</p>
    </div>
    
    <div class="container">
        <div class="controls">
            <button id="startBtn" class="btn btn-start">▶️ Iniciar Otimização</button>
            <button id="stopBtn" class="btn btn-stop" disabled>⏹️ Parar Otimização</button>
            <button id="exportBtn" class="btn btn-export">📊 Exportar Resultados</button>
        </div>
        
        <div class="dashboard">
            <div class="card">
                <h3>📊 Status do Sistema</h3>
                <div class="status">
                    <div id="statusIndicator" class="status-indicator"></div>
                    <span id="statusText">Sistema Parado</span>
                </div>
                
                <div class="metrics">
                    <div class="metric">
                        <div id="currentCycle" class="metric-value">0</div>
                        <div class="metric-label">Ciclo Atual</div>
                    </div>
                    <div class="metric">
                        <div id="avgScore" class="metric-value">0.00</div>
                        <div class="metric-label">Score Médio</div>
                    </div>
                    <div class="metric">
                        <div id="avgQuality" class="metric-value">0.00</div>
                        <div class="metric-label">Qualidade Média</div>
                    </div>
                    <div class="metric">
                        <div id="ftmoReady" class="metric-value">0</div>
                        <div class="metric-label">FTMO Ready</div>
                    </div>
                    <div class="metric">
                        <div id="criticalIssues" class="metric-value">0</div>
                        <div class="metric-label">Issues Críticos</div>
                    </div>
                    <div class="metric">
                        <div id="targetReached" class="metric-value">❌</div>
                        <div class="metric-label">Meta Atingida</div>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h3>📈 Gráfico de Performance</h3>
                <div class="chart-container">
                    <canvas id="performanceChart"></canvas>
                </div>
            </div>
            
            <div class="card">
                <h3>🔄 Histórico de Ciclos</h3>
                <div style="max-height: 300px; overflow-y: auto;">
                    <table class="cycles-table">
                        <thead>
                            <tr>
                                <th>Ciclo</th>
                                <th>Score Antes</th>
                                <th>Score Depois</th>
                                <th>Melhoria</th>
                                <th>Issues</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="cyclesTableBody">
                            <tr>
                                <td colspan="6">Nenhum ciclo executado ainda</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="card logs">
                <h3>📝 Log do Sistema</h3>
                <div id="logsContainer" style="max-height: 300px; overflow-y: auto;">
                    <div class="log-entry log-info">
                        <strong>[00:00:00]</strong> Sistema inicializado. Aguardando comandos...
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Configuração Socket.IO
        const socket = io();
        
        // Elementos DOM
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');
        const exportBtn = document.getElementById('exportBtn');
        const statusIndicator = document.getElementById('statusIndicator');
        const statusText = document.getElementById('statusText');
        const currentCycle = document.getElementById('currentCycle');
        const avgScore = document.getElementById('avgScore');
        const avgQuality = document.getElementById('avgQuality');
        const ftmoReady = document.getElementById('ftmoReady');
        const criticalIssues = document.getElementById('criticalIssues');
        const targetReached = document.getElementById('targetReached');
        const logsContainer = document.getElementById('logsContainer');
        const cyclesTableBody = document.getElementById('cyclesTableBody');
        
        // Gráfico de performance
        const ctx = document.getElementById('performanceChart').getContext('2d');
        const performanceChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Score Unificado',
                    data: [],
                    borderColor: '#4CAF50',
                    backgroundColor: 'rgba(76, 175, 80, 0.1)',
                    tension: 0.4
                }, {
                    label: 'Qualidade Metadados',
                    data: [],
                    borderColor: '#2196F3',
                    backgroundColor: 'rgba(33, 150, 243, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            color: 'white'
                        }
                    }
                },
                scales: {
                    x: {
                        ticks: {
                            color: 'white'
                        },
                        grid: {
                            color: 'rgba(255,255,255,0.1)'
                        }
                    },
                    y: {
                        ticks: {
                            color: 'white'
                        },
                        grid: {
                            color: 'rgba(255,255,255,0.1)'
                        },
                        min: 0,
                        max: 10
                    }
                }
            }
        });
        
        // Event listeners
        startBtn.addEventListener('click', () => {
            fetch('/api/start', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        alert(data.error);
                    }
                })
                .catch(error => {
                    console.error('Erro:', error);
                    alert('Erro ao iniciar otimização');
                });
        });
        
        stopBtn.addEventListener('click', () => {
            fetch('/api/stop', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        alert(data.error);
                    }
                })
                .catch(error => {
                    console.error('Erro:', error);
                    alert('Erro ao parar otimização');
                });
        });
        
        exportBtn.addEventListener('click', () => {
            fetch('/api/export', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        alert(data.error);
                    } else {
                        alert('Relatório exportado com sucesso!');
                    }
                })
                .catch(error => {
                    console.error('Erro:', error);
                    alert('Erro ao exportar relatório');
                });
        });
        
        // Socket events
        socket.on('data_update', (data) => {
            updateUI(data);
        });
        
        socket.on('new_log', (logEntry) => {
            addLogEntry(logEntry);
        });
        
        function updateUI(data) {
            // Atualizar status
            if (data.is_running) {
                statusIndicator.classList.add('running');
                statusText.textContent = 'Sistema Executando';
                startBtn.disabled = true;
                stopBtn.disabled = false;
            } else {
                statusIndicator.classList.remove('running');
                statusText.textContent = 'Sistema Parado';
                startBtn.disabled = false;
                stopBtn.disabled = true;
            }
            
            // Atualizar métricas
            if (data.current_state) {
                currentCycle.textContent = data.current_cycle || 0;
                avgScore.textContent = (data.current_state.avg_score || 0).toFixed(2);
                avgQuality.textContent = (data.current_state.avg_quality || 0).toFixed(2);
                ftmoReady.textContent = data.current_state.ftmo_ready || 0;
                criticalIssues.textContent = data.current_state.critical_issues || 0;
                targetReached.textContent = data.target_reached ? '✅' : '❌';
            }
            
            // Atualizar gráfico
            if (data.performance_history) {
                const scores = data.performance_history.scores || [];
                const qualities = data.performance_history.quality_metrics || [];
                
                performanceChart.data.labels = scores.map((_, i) => `Ciclo ${i + 1}`);
                performanceChart.data.datasets[0].data = scores;
                performanceChart.data.datasets[1].data = qualities;
                performanceChart.update();
            }
            
            // Atualizar tabela de ciclos
            updateCyclesTable(data.cycles_history || []);
        }
        
        function addLogEntry(logEntry) {
            const logDiv = document.createElement('div');
            logDiv.className = `log-entry log-${logEntry.level}`;
            logDiv.innerHTML = `<strong>[${logEntry.timestamp}]</strong> ${logEntry.message}`;
            
            logsContainer.appendChild(logDiv);
            logsContainer.scrollTop = logsContainer.scrollHeight;
            
            // Manter apenas os últimos 50 logs visíveis
            while (logsContainer.children.length > 50) {
                logsContainer.removeChild(logsContainer.firstChild);
            }
        }
        
        function updateCyclesTable(cycles) {
            if (cycles.length === 0) {
                cyclesTableBody.innerHTML = '<tr><td colspan="6">Nenhum ciclo executado ainda</td></tr>';
                return;
            }
            
            cyclesTableBody.innerHTML = '';
            
            cycles.forEach(cycle => {
                const row = document.createElement('tr');
                const improvementClass = cycle.improvement_percentage >= 0 ? 'improvement-positive' : 'improvement-negative';
                const statusIcon = cycle.status === 'completed' ? '✅' : '❌';
                
                row.innerHTML = `
                    <td>${cycle.cycle_number}</td>
                    <td>${cycle.avg_score_before.toFixed(2)}</td>
                    <td>${cycle.avg_score_after.toFixed(2)}</td>
                    <td class="${improvementClass}">${cycle.improvement_percentage >= 0 ? '+' : ''}${cycle.improvement_percentage.toFixed(2)}%</td>
                    <td>${cycle.issues_resolved}</td>
                    <td>${statusIcon}</td>
                `;
                
                cyclesTableBody.appendChild(row);
            });
        }
        
        // Carregar dados iniciais
        fetch('/api/status')
            .then(response => response.json())
            .then(data => {
                updateUI(data);
                
                // Adicionar logs existentes
                if (data.logs) {
                    data.logs.forEach(log => addLogEntry(log));
                }
            })
            .catch(error => {
                console.error('Erro ao carregar status inicial:', error);
            });
    </script>
</body>
</html>
'''

def create_template_file():
    """Cria arquivo de template HTML"""
    templates_dir = Path('templates')
    templates_dir.mkdir(exist_ok=True)
    
    template_path = templates_dir / 'optimization_monitor.html'
    with open(template_path, 'w', encoding='utf-8') as f:
        f.write(HTML_TEMPLATE)
    
    return template_path

def main():
    """Função principal"""
    print("🚀 Interface Gráfica - Sistema de Otimização Contínua")
    print("📋 Classificador_Trading v2.0 - Elite AI")
    print("🌐 Iniciando servidor web...")
    
    # Criar template HTML
    create_template_file()
    
    # Iniciar thread de atualização
    update_thread_instance = threading.Thread(target=update_thread)
    update_thread_instance.daemon = True
    update_thread_instance.start()
    
    # Adicionar log inicial
    add_log("🌐 Servidor web iniciado com sucesso", "success")
    add_log("📊 Interface de monitoramento carregada", "info")
    add_log("🎯 Pronto para iniciar otimização contínua", "info")
    
    try:
        # Iniciar servidor Flask
        print("\n" + "="*60)
        print("🌐 SERVIDOR WEB ATIVO")
        print("="*60)
        print("📱 Interface disponível em:")
        print("   • http://localhost:5001")
        print("   • http://127.0.0.1:5001")
        print("\n🎯 Funcionalidades:")
        print("   • ▶️  Iniciar/Parar otimização")
        print("   • 📊 Monitoramento em tempo real")
        print("   • 📈 Gráficos de performance")
        print("   • 📝 Logs do sistema")
        print("   • 🔄 Histórico de ciclos")
        print("   • 📁 Exportar relatórios")
        print("\n⚡ Pressione Ctrl+C para parar")
        print("="*60)
        
        socketio.run(app, host='0.0.0.0', port=5001, debug=False)
        
    except KeyboardInterrupt:
        print("\n⏹️ Servidor interrompido pelo usuário")
    except Exception as e:
        print(f"❌ Erro no servidor: {e}")
        logger.error(f"Erro no servidor: {e}")
    
    return 0

if __name__ == "__main__":
    exit(main())