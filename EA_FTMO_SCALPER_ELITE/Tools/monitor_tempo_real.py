#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema de Monitoramento em Tempo Real - Multi-Agente v4.0
Interface web para acompanhar análise de metadados em tempo real
"""

import os
import json
import time
import threading
from datetime import datetime
from pathlib import Path
from flask import Flask, render_template, jsonify, request
from analisador_metadados_otimizado import OptimizedMultiAgentSystem
import logging

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Estado global do sistema
system_state = {
    'status': 'idle',  # idle, running, completed, error
    'current_file': '',
    'progress': 0,
    'total_files': 0,
    'processed_files': 0,
    'start_time': None,
    'end_time': None,
    'results': [],
    'errors': [],
    'metrics': {
        'avg_unified_score': 0.0,
        'avg_metadata_quality': 0.0,
        'ftmo_ready_count': 0,
        'total_processing_time': 0.0
    },
    'real_time_stats': {
        'files_per_second': 0.0,
        'estimated_completion': None,
        'quality_distribution': {'excellent': 0, 'good': 0, 'average': 0, 'poor': 0}
    }
}

analysis_system = None
analysis_thread = None

class RealTimeAnalyzer:
    """Analisador com callbacks em tempo real"""
    
    def __init__(self):
        self.system = OptimizedMultiAgentSystem()
        self.callbacks = []
    
    def add_callback(self, callback):
        """Adiciona callback para atualizações em tempo real"""
        self.callbacks.append(callback)
    
    def notify_callbacks(self, event_type, data):
        """Notifica todos os callbacks"""
        for callback in self.callbacks:
            try:
                callback(event_type, data)
            except Exception as e:
                logger.error(f"Erro no callback: {e}")
    
    def analyze_directory_realtime(self, directory_path: str):
        """Analisa diretório com atualizações em tempo real"""
        try:
            # Encontrar arquivos
            file_patterns = ['*.mq4', '*.mq5', '*.mqh']
            files_to_analyze = []
            
            for pattern in file_patterns:
                files_to_analyze.extend(Path(directory_path).glob(pattern))
            
            total_files = len(files_to_analyze)
            
            self.notify_callbacks('analysis_started', {
                'total_files': total_files,
                'start_time': datetime.now().isoformat()
            })
            
            results = []
            start_time = time.time()
            
            for i, file_path in enumerate(files_to_analyze):
                file_start_time = time.time()
                
                self.notify_callbacks('file_started', {
                    'filename': file_path.name,
                    'progress': (i / total_files) * 100,
                    'file_index': i + 1,
                    'total_files': total_files
                })
                
                # Analisar arquivo
                analysis = self.system.analyze_file(str(file_path))
                
                if analysis:
                    results.append(analysis)
                    
                    file_processing_time = time.time() - file_start_time
                    
                    # Calcular estatísticas em tempo real
                    elapsed_time = time.time() - start_time
                    files_per_second = (i + 1) / elapsed_time if elapsed_time > 0 else 0
                    estimated_completion = None
                    
                    if files_per_second > 0:
                        remaining_files = total_files - (i + 1)
                        estimated_seconds = remaining_files / files_per_second
                        estimated_completion = (datetime.now().timestamp() + estimated_seconds)
                    
                    self.notify_callbacks('file_completed', {
                        'filename': file_path.name,
                        'analysis': {
                            'unified_score': analysis.unified_score,
                            'ftmo_status': analysis.ftmo_status,
                            'strategy': analysis.strategy,
                            'file_type': analysis.file_type,
                            'processing_time': file_processing_time
                        },
                        'progress': ((i + 1) / total_files) * 100,
                        'real_time_stats': {
                            'files_per_second': files_per_second,
                            'estimated_completion': estimated_completion,
                            'avg_processing_time': elapsed_time / (i + 1)
                        }
                    })
            
            # Gerar relatório final
            report = self.system.generate_report(results)
            
            self.notify_callbacks('analysis_completed', {
                'total_time': time.time() - start_time,
                'results_count': len(results),
                'report': report,
                'end_time': datetime.now().isoformat()
            })
            
            return results
            
        except Exception as e:
            self.notify_callbacks('analysis_error', {
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            })
            raise

def update_system_state(event_type, data):
    """Callback para atualizar estado do sistema"""
    global system_state
    
    if event_type == 'analysis_started':
        system_state.update({
            'status': 'running',
            'total_files': data['total_files'],
            'processed_files': 0,
            'start_time': data['start_time'],
            'progress': 0,
            'results': [],
            'errors': []
        })
    
    elif event_type == 'file_started':
        system_state.update({
            'current_file': data['filename'],
            'progress': data['progress']
        })
    
    elif event_type == 'file_completed':
        system_state['processed_files'] += 1
        system_state['progress'] = data['progress']
        system_state['results'].append(data['analysis'])
        
        # Atualizar estatísticas em tempo real
        if 'real_time_stats' in data:
            system_state['real_time_stats'].update(data['real_time_stats'])
        
        # Atualizar métricas
        results = system_state['results']
        if results:
            system_state['metrics']['avg_unified_score'] = sum(r['unified_score'] for r in results) / len(results)
            system_state['metrics']['ftmo_ready_count'] = len([r for r in results if r['ftmo_status'] == 'FTMO_READY'])
        
        # Atualizar distribuição de qualidade
        score = data['analysis']['unified_score']
        if score >= 9.0:
            system_state['real_time_stats']['quality_distribution']['excellent'] += 1
        elif score >= 7.0:
            system_state['real_time_stats']['quality_distribution']['good'] += 1
        elif score >= 5.0:
            system_state['real_time_stats']['quality_distribution']['average'] += 1
        else:
            system_state['real_time_stats']['quality_distribution']['poor'] += 1
    
    elif event_type == 'analysis_completed':
        system_state.update({
            'status': 'completed',
            'end_time': data['end_time'],
            'progress': 100,
            'metrics': {
                'avg_unified_score': data['report']['summary']['average_unified_score'],
                'avg_metadata_quality': data['report']['summary']['average_metadata_quality'],
                'ftmo_ready_count': data['report']['summary']['ftmo_ready_count'],
                'total_processing_time': data['total_time']
            }
        })
    
    elif event_type == 'analysis_error':
        system_state.update({
            'status': 'error',
            'errors': system_state['errors'] + [data]
        })

def run_analysis_thread(directory_path):
    """Executa análise em thread separada"""
    global analysis_system
    
    try:
        analysis_system = RealTimeAnalyzer()
        analysis_system.add_callback(update_system_state)
        analysis_system.analyze_directory_realtime(directory_path)
    except Exception as e:
        logger.error(f"Erro na análise: {e}")
        update_system_state('analysis_error', {
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        })

@app.route('/')
def index():
    """Página principal"""
    return render_template('monitor.html')

@app.route('/api/status')
def get_status():
    """API para obter status atual"""
    return jsonify(system_state)

@app.route('/api/start', methods=['POST'])
def start_analysis():
    """API para iniciar análise"""
    global analysis_thread
    
    if system_state['status'] == 'running':
        return jsonify({'error': 'Análise já está em execução'}), 400
    
    data = request.get_json()
    directory_path = data.get('directory', 'Input_Expandido')
    
    if not os.path.exists(directory_path):
        return jsonify({'error': f'Diretório {directory_path} não encontrado'}), 400
    
    # Iniciar análise em thread separada
    analysis_thread = threading.Thread(target=run_analysis_thread, args=(directory_path,))
    analysis_thread.daemon = True
    analysis_thread.start()
    
    return jsonify({'message': 'Análise iniciada', 'directory': directory_path})

@app.route('/api/stop', methods=['POST'])
def stop_analysis():
    """API para parar análise"""
    global system_state
    
    if system_state['status'] != 'running':
        return jsonify({'error': 'Nenhuma análise em execução'}), 400
    
    system_state['status'] = 'idle'
    return jsonify({'message': 'Análise interrompida'})

@app.route('/api/results')
def get_results():
    """API para obter resultados detalhados"""
    try:
        # Tentar carregar resultados do arquivo JSON se existir
        json_path = Path('Output_Analise/analise_completa.json')
        if json_path.exists():
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return jsonify(data)
    except Exception as e:
        logger.error(f"Erro ao carregar resultados: {e}")
    
    return jsonify({'results': system_state['results']})

@app.route('/api/export', methods=['POST'])
def export_results():
    """API para exportar resultados"""
    try:
        if not system_state['results']:
            return jsonify({'error': 'Nenhum resultado para exportar'}), 400
        
        # Exportar usando o sistema de análise
        if analysis_system:
            # Converter resultados do estado para formato FileAnalysis
            # (implementação simplificada)
            output_dir = 'Output_Analise_WebExport'
            os.makedirs(output_dir, exist_ok=True)
            
            # Salvar estado atual
            export_data = {
                'metadata': {
                    'generated_at': datetime.now().isoformat(),
                    'total_files': system_state['total_files'],
                    'system_version': '4.0-web'
                },
                'system_state': system_state
            }
            
            with open(f'{output_dir}/estado_sistema.json', 'w', encoding='utf-8') as f:
                json.dump(export_data, f, indent=2, ensure_ascii=False)
            
            return jsonify({'message': f'Resultados exportados para {output_dir}'})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Criar template HTML se não existir
    template_dir = Path('templates')
    template_dir.mkdir(exist_ok=True)
    
    html_template = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitor Multi-Agente - Análise de Metadados</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a1a; color: #fff; }
        .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; font-size: 2.5em; margin-bottom: 10px; }
        .header p { color: #888; font-size: 1.1em; }
        
        .controls { background: #2a2a2a; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .btn { background: #00ff88; color: #000; border: none; padding: 12px 24px; border-radius: 5px; cursor: pointer; font-weight: bold; margin-right: 10px; }
        .btn:hover { background: #00cc6a; }
        .btn:disabled { background: #555; color: #999; cursor: not-allowed; }
        .btn-danger { background: #ff4444; color: #fff; }
        .btn-danger:hover { background: #cc3333; }
        
        .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .status-card { background: #2a2a2a; padding: 20px; border-radius: 10px; border-left: 4px solid #00ff88; }
        .status-card h3 { color: #00ff88; margin-bottom: 15px; }
        .status-value { font-size: 2em; font-weight: bold; margin-bottom: 5px; }
        .status-label { color: #888; font-size: 0.9em; }
        
        .progress-container { background: #2a2a2a; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .progress-bar { width: 100%; height: 20px; background: #444; border-radius: 10px; overflow: hidden; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #00ff88, #00cc6a); transition: width 0.3s ease; }
        .progress-text { text-align: center; margin-top: 10px; font-weight: bold; }
        
        .results-container { background: #2a2a2a; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .results-table { width: 100%; border-collapse: collapse; }
        .results-table th, .results-table td { padding: 12px; text-align: left; border-bottom: 1px solid #444; }
        .results-table th { background: #333; color: #00ff88; }
        .results-table tr:hover { background: #333; }
        
        .chart-container { background: #2a2a2a; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .quality-bar { display: flex; height: 30px; border-radius: 15px; overflow: hidden; margin-top: 10px; }
        .quality-segment { display: flex; align-items: center; justify-content: center; color: #000; font-weight: bold; }
        .excellent { background: #00ff88; }
        .good { background: #ffaa00; }
        .average { background: #ff6600; }
        .poor { background: #ff4444; }
        
        .log-container { background: #1a1a1a; padding: 20px; border-radius: 10px; max-height: 300px; overflow-y: auto; }
        .log-entry { padding: 5px 0; border-bottom: 1px solid #333; font-family: monospace; }
        .log-timestamp { color: #888; }
        .log-message { color: #fff; }
        
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
        .running { animation: pulse 2s infinite; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 Monitor Multi-Agente v4.0</h1>
            <p>Sistema de Análise de Metadados em Tempo Real</p>
        </div>
        
        <div class="controls">
            <button id="startBtn" class="btn" onclick="startAnalysis()">🚀 Iniciar Análise</button>
            <button id="stopBtn" class="btn btn-danger" onclick="stopAnalysis()" disabled>⏹️ Parar</button>
            <button id="exportBtn" class="btn" onclick="exportResults()">💾 Exportar</button>
            <input type="text" id="directoryInput" placeholder="Diretório (padrão: Input_Expandido)" style="padding: 12px; margin-left: 10px; border-radius: 5px; border: 1px solid #555; background: #333; color: #fff;">
        </div>
        
        <div class="status-grid">
            <div class="status-card">
                <h3>📊 Status</h3>
                <div class="status-value" id="statusValue">Idle</div>
                <div class="status-label">Estado do Sistema</div>
            </div>
            <div class="status-card">
                <h3>📁 Arquivos</h3>
                <div class="status-value" id="filesValue">0/0</div>
                <div class="status-label">Processados/Total</div>
            </div>
            <div class="status-card">
                <h3>⭐ Score Médio</h3>
                <div class="status-value" id="scoreValue">0.0</div>
                <div class="status-label">Score Unificado</div>
            </div>
            <div class="status-card">
                <h3>✅ FTMO Ready</h3>
                <div class="status-value" id="ftmoValue">0</div>
                <div class="status-label">Arquivos Aprovados</div>
            </div>
        </div>
        
        <div class="progress-container">
            <div class="progress-bar">
                <div class="progress-fill" id="progressFill" style="width: 0%"></div>
            </div>
            <div class="progress-text" id="progressText">Aguardando início...</div>
        </div>
        
        <div class="chart-container">
            <h3>📈 Distribuição de Qualidade</h3>
            <div class="quality-bar" id="qualityBar">
                <div class="quality-segment excellent" style="flex: 1;">Excelente: 0</div>
                <div class="quality-segment good" style="flex: 1;">Bom: 0</div>
                <div class="quality-segment average" style="flex: 1;">Médio: 0</div>
                <div class="quality-segment poor" style="flex: 1;">Ruim: 0</div>
            </div>
        </div>
        
        <div class="results-container">
            <h3>📋 Resultados em Tempo Real</h3>
            <div style="max-height: 400px; overflow-y: auto;">
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>Arquivo</th>
                            <th>Tipo</th>
                            <th>Estratégia</th>
                            <th>Score</th>
                            <th>FTMO Status</th>
                            <th>Tempo (s)</th>
                        </tr>
                    </thead>
                    <tbody id="resultsTableBody">
                        <tr><td colspan="6" style="text-align: center; color: #888;">Nenhum resultado ainda...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="log-container">
            <h3>📝 Log do Sistema</h3>
            <div id="logContainer">
                <div class="log-entry">
                    <span class="log-timestamp">[Sistema]</span>
                    <span class="log-message">Monitor iniciado - Aguardando comandos...</span>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        let updateInterval;
        
        function addLog(message, type = 'info') {
            const logContainer = document.getElementById('logContainer');
            const timestamp = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.className = 'log-entry';
            logEntry.innerHTML = `
                <span class="log-timestamp">[${timestamp}]</span>
                <span class="log-message">${message}</span>
            `;
            logContainer.appendChild(logEntry);
            logContainer.scrollTop = logContainer.scrollHeight;
        }
        
        function updateStatus() {
            fetch('/api/status')
                .then(response => response.json())
                .then(data => {
                    // Atualizar status
                    const statusElement = document.getElementById('statusValue');
                    statusElement.textContent = data.status.charAt(0).toUpperCase() + data.status.slice(1);
                    statusElement.className = data.status === 'running' ? 'status-value running' : 'status-value';
                    
                    // Atualizar arquivos
                    document.getElementById('filesValue').textContent = `${data.processed_files}/${data.total_files}`;
                    
                    // Atualizar score
                    document.getElementById('scoreValue').textContent = data.metrics.avg_unified_score.toFixed(1);
                    
                    // Atualizar FTMO
                    document.getElementById('ftmoValue').textContent = data.metrics.ftmo_ready_count;
                    
                    // Atualizar progresso
                    const progressFill = document.getElementById('progressFill');
                    const progressText = document.getElementById('progressText');
                    progressFill.style.width = `${data.progress}%`;
                    
                    if (data.status === 'running') {
                        progressText.textContent = `Processando: ${data.current_file} (${data.progress.toFixed(1)}%)`;
                    } else if (data.status === 'completed') {
                        progressText.textContent = `Análise concluída! ${data.processed_files} arquivos processados`;
                    } else {
                        progressText.textContent = 'Aguardando início...';
                    }
                    
                    // Atualizar distribuição de qualidade
                    updateQualityChart(data.real_time_stats.quality_distribution);
                    
                    // Atualizar tabela de resultados
                    updateResultsTable(data.results);
                    
                    // Atualizar botões
                    const startBtn = document.getElementById('startBtn');
                    const stopBtn = document.getElementById('stopBtn');
                    
                    if (data.status === 'running') {
                        startBtn.disabled = true;
                        stopBtn.disabled = false;
                    } else {
                        startBtn.disabled = false;
                        stopBtn.disabled = true;
                    }
                })
                .catch(error => {
                    console.error('Erro ao atualizar status:', error);
                    addLog(`Erro ao atualizar status: ${error.message}`, 'error');
                });
        }
        
        function updateQualityChart(distribution) {
            const total = Object.values(distribution).reduce((a, b) => a + b, 0);
            if (total === 0) return;
            
            const qualityBar = document.getElementById('qualityBar');
            qualityBar.innerHTML = `
                <div class="quality-segment excellent" style="flex: ${distribution.excellent};">Excelente: ${distribution.excellent}</div>
                <div class="quality-segment good" style="flex: ${distribution.good};">Bom: ${distribution.good}</div>
                <div class="quality-segment average" style="flex: ${distribution.average};">Médio: ${distribution.average}</div>
                <div class="quality-segment poor" style="flex: ${distribution.poor};">Ruim: ${distribution.poor}</div>
            `;
        }
        
        function updateResultsTable(results) {
            const tbody = document.getElementById('resultsTableBody');
            
            if (results.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #888;">Nenhum resultado ainda...</td></tr>';
                return;
            }
            
            tbody.innerHTML = results.slice(-10).reverse().map(result => `
                <tr>
                    <td>${result.filename || 'N/A'}</td>
                    <td>${result.file_type || 'N/A'}</td>
                    <td>${result.strategy || 'N/A'}</td>
                    <td>${result.unified_score ? result.unified_score.toFixed(2) : 'N/A'}</td>
                    <td><span style="color: ${result.ftmo_status === 'FTMO_READY' ? '#00ff88' : result.ftmo_status === 'FTMO_POTENTIAL' ? '#ffaa00' : '#ff4444'}">${result.ftmo_status || 'N/A'}</span></td>
                    <td>${result.processing_time ? result.processing_time.toFixed(3) : 'N/A'}</td>
                </tr>
            `).join('');
        }
        
        function startAnalysis() {
            const directory = document.getElementById('directoryInput').value || 'Input_Expandido';
            
            fetch('/api/start', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ directory: directory })
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    addLog(`Erro: ${data.error}`, 'error');
                } else {
                    addLog(`Análise iniciada no diretório: ${data.directory}`, 'success');
                }
            })
            .catch(error => {
                addLog(`Erro ao iniciar análise: ${error.message}`, 'error');
            });
        }
        
        function stopAnalysis() {
            fetch('/api/stop', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    addLog(data.message || data.error, data.error ? 'error' : 'info');
                })
                .catch(error => {
                    addLog(`Erro ao parar análise: ${error.message}`, 'error');
                });
        }
        
        function exportResults() {
            fetch('/api/export', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        addLog(`Erro na exportação: ${data.error}`, 'error');
                    } else {
                        addLog(data.message, 'success');
                    }
                })
                .catch(error => {
                    addLog(`Erro ao exportar: ${error.message}`, 'error');
                });
        }
        
        // Iniciar atualizações automáticas
        updateInterval = setInterval(updateStatus, 1000);
        updateStatus(); // Primeira atualização
        
        // Adicionar log inicial
        addLog('Interface web carregada - Sistema pronto para uso!');
    </script>
</body>
</html>
    '''
    
    with open(template_dir / 'monitor.html', 'w', encoding='utf-8') as f:
        f.write(html_template)
    
    print("🌐 Iniciando servidor web...")
    print("📱 Acesse: http://localhost:5000")
    print("🔄 Interface em tempo real ativa!")
    
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)