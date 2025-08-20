#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔍 MONITOR DE TEMPO REAL - PASSO 2
Sistema de monitoramento avançado para classificação em lote

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Recursos:
- Monitoramento em tempo real
- Detecção automática de problemas
- Alertas inteligentes
- Métricas de performance
- Dashboard ao vivo
- Logs estruturados
"""

import os
import time
import json
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Callable
from pathlib import Path
from dataclasses import dataclass, asdict
from collections import deque, defaultdict
import queue

@dataclass
class MetricSnapshot:
    """Snapshot de métricas em um momento específico"""
    timestamp: datetime
    files_processed: int
    files_successful: int
    files_failed: int
    processing_rate: float
    success_rate: float
    memory_usage: float
    cpu_usage: float
    current_file: str
    errors_last_minute: int
    
class AlertManager:
    """Gerenciador de alertas inteligentes"""
    
    def __init__(self):
        self.alert_history = deque(maxlen=100)
        self.alert_callbacks = []
        
    def add_callback(self, callback: Callable):
        """Adiciona callback para alertas"""
        self.alert_callbacks.append(callback)
        
    def check_alerts(self, metrics: MetricSnapshot, thresholds: Dict):
        """Verifica condições de alerta"""
        alerts = []
        
        # Taxa de sucesso baixa
        if metrics.success_rate < thresholds.get('min_success_rate', 80):
            alerts.append({
                'type': 'warning',
                'message': f"Taxa de sucesso baixa: {metrics.success_rate:.1f}%",
                'severity': 'medium',
                'timestamp': metrics.timestamp
            })
            
        # Muitos erros recentes
        if metrics.errors_last_minute > thresholds.get('max_errors_per_minute', 10):
            alerts.append({
                'type': 'error',
                'message': f"Muitos erros no último minuto: {metrics.errors_last_minute}",
                'severity': 'high',
                'timestamp': metrics.timestamp
            })
            
        # Performance baixa
        if metrics.processing_rate < thresholds.get('min_processing_rate', 1.0):
            alerts.append({
                'type': 'performance',
                'message': f"Performance baixa: {metrics.processing_rate:.2f} arq/s",
                'severity': 'low',
                'timestamp': metrics.timestamp
            })
            
        # Uso de memória alto
        if metrics.memory_usage > thresholds.get('max_memory_usage', 80):
            alerts.append({
                'type': 'resource',
                'message': f"Uso de memória alto: {metrics.memory_usage:.1f}%",
                'severity': 'medium',
                'timestamp': metrics.timestamp
            })
            
        # Processar alertas
        for alert in alerts:
            self._process_alert(alert)
            
        return alerts
        
    def _process_alert(self, alert: Dict):
        """Processa um alerta"""
        self.alert_history.append(alert)
        
        # Notificar callbacks
        for callback in self.alert_callbacks:
            try:
                callback(alert)
            except Exception as e:
                print(f"Erro no callback de alerta: {e}")
                
class PerformanceTracker:
    """Rastreador de performance avançado"""
    
    def __init__(self, window_size: int = 60):
        self.window_size = window_size
        self.metrics_history = deque(maxlen=window_size)
        self.error_history = deque(maxlen=1000)
        
    def add_metric(self, metric: MetricSnapshot):
        """Adiciona métrica ao histórico"""
        self.metrics_history.append(metric)
        
    def get_trend_analysis(self) -> Dict:
        """Analisa tendências de performance"""
        if len(self.metrics_history) < 2:
            return {'trend': 'insufficient_data'}
            
        recent = list(self.metrics_history)[-10:]  # Últimos 10 pontos
        older = list(self.metrics_history)[-20:-10] if len(self.metrics_history) >= 20 else []
        
        if not older:
            return {'trend': 'insufficient_data'}
            
        # Calcular médias
        recent_avg_rate = sum(m.processing_rate for m in recent) / len(recent)
        older_avg_rate = sum(m.processing_rate for m in older) / len(older)
        
        recent_avg_success = sum(m.success_rate for m in recent) / len(recent)
        older_avg_success = sum(m.success_rate for m in older) / len(older)
        
        # Determinar tendência
        rate_trend = 'improving' if recent_avg_rate > older_avg_rate * 1.05 else 'declining' if recent_avg_rate < older_avg_rate * 0.95 else 'stable'
        success_trend = 'improving' if recent_avg_success > older_avg_success * 1.02 else 'declining' if recent_avg_success < older_avg_success * 0.98 else 'stable'
        
        return {
            'trend': 'overall_trend',
            'processing_rate': {
                'trend': rate_trend,
                'recent_avg': recent_avg_rate,
                'older_avg': older_avg_rate,
                'change_percent': ((recent_avg_rate - older_avg_rate) / older_avg_rate) * 100
            },
            'success_rate': {
                'trend': success_trend,
                'recent_avg': recent_avg_success,
                'older_avg': older_avg_success,
                'change_percent': ((recent_avg_success - older_avg_success) / older_avg_success) * 100
            }
        }
        
    def get_performance_summary(self) -> Dict:
        """Resumo de performance"""
        if not self.metrics_history:
            return {}
            
        metrics = list(self.metrics_history)
        
        return {
            'avg_processing_rate': sum(m.processing_rate for m in metrics) / len(metrics),
            'avg_success_rate': sum(m.success_rate for m in metrics) / len(metrics),
            'max_processing_rate': max(m.processing_rate for m in metrics),
            'min_processing_rate': min(m.processing_rate for m in metrics),
            'total_processed': metrics[-1].files_processed if metrics else 0,
            'total_successful': metrics[-1].files_successful if metrics else 0,
            'total_failed': metrics[-1].files_failed if metrics else 0
        }
        
class MonitorTempoReal:
    """Monitor principal de tempo real"""
    
    def __init__(self, update_interval: float = 1.0):
        self.update_interval = update_interval
        self.is_monitoring = False
        self.monitor_thread = None
        
        # Componentes
        self.alert_manager = AlertManager()
        self.performance_tracker = PerformanceTracker()
        
        # Estado atual
        self.current_metrics = None
        self.start_time = None
        
        # Configurações
        self.thresholds = {
            'min_success_rate': 80.0,
            'max_errors_per_minute': 10,
            'min_processing_rate': 1.0,
            'max_memory_usage': 80.0
        }
        
        # Callbacks
        self.update_callbacks = []
        self.status_callbacks = []
        
        # Logs
        self.log_file = None
        self.setup_logging()
        
    def setup_logging(self):
        """Configura sistema de logs"""
        log_dir = "Development/Reports/Monitoring"
        os.makedirs(log_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = f"{log_dir}/monitor_{timestamp}.log"
        
    def add_update_callback(self, callback: Callable):
        """Adiciona callback para atualizações"""
        self.update_callbacks.append(callback)
        
    def add_status_callback(self, callback: Callable):
        """Adiciona callback para mudanças de status"""
        self.status_callbacks.append(callback)
        
    def start_monitoring(self, initial_data: Dict = None):
        """Inicia monitoramento"""
        if self.is_monitoring:
            return False
            
        self.is_monitoring = True
        self.start_time = datetime.now()
        
        # Configurar alertas
        self.alert_manager.add_callback(self._handle_alert)
        
        # Iniciar thread de monitoramento
        self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitor_thread.start()
        
        self._log("INFO", "Monitoramento iniciado")
        self._notify_status_change("started")
        
        return True
        
    def stop_monitoring(self):
        """Para monitoramento"""
        if not self.is_monitoring:
            return False
            
        self.is_monitoring = False
        
        if self.monitor_thread:
            self.monitor_thread.join(timeout=5.0)
            
        self._log("INFO", "Monitoramento parado")
        self._notify_status_change("stopped")
        
        return True
        
    def update_metrics(self, data: Dict):
        """Atualiza métricas do processo"""
        try:
            # Calcular métricas derivadas
            processing_rate = self._calculate_processing_rate(data)
            success_rate = self._calculate_success_rate(data)
            errors_last_minute = self._count_recent_errors()
            
            # Criar snapshot
            metrics = MetricSnapshot(
                timestamp=datetime.now(),
                files_processed=data.get('files_processed', 0),
                files_successful=data.get('files_successful', 0),
                files_failed=data.get('files_failed', 0),
                processing_rate=processing_rate,
                success_rate=success_rate,
                memory_usage=data.get('memory_usage', 0),
                cpu_usage=data.get('cpu_usage', 0),
                current_file=data.get('current_file', ''),
                errors_last_minute=errors_last_minute
            )
            
            self.current_metrics = metrics
            self.performance_tracker.add_metric(metrics)
            
            # Verificar alertas
            alerts = self.alert_manager.check_alerts(metrics, self.thresholds)
            
            # Notificar callbacks
            self._notify_update(metrics, alerts)
            
        except Exception as e:
            self._log("ERROR", f"Erro ao atualizar métricas: {e}")
            
    def _monitor_loop(self):
        """Loop principal de monitoramento"""
        while self.is_monitoring:
            try:
                # Verificar se há dados para processar
                if self.current_metrics:
                    # Análise de tendências
                    trend_analysis = self.performance_tracker.get_trend_analysis()
                    
                    # Log periódico
                    if datetime.now().second % 30 == 0:  # A cada 30 segundos
                        self._log_periodic_status()
                        
                time.sleep(self.update_interval)
                
            except Exception as e:
                self._log("ERROR", f"Erro no loop de monitoramento: {e}")
                time.sleep(self.update_interval)
                
    def _calculate_processing_rate(self, data: Dict) -> float:
        """Calcula taxa de processamento"""
        if not self.start_time:
            return 0.0
            
        elapsed = (datetime.now() - self.start_time).total_seconds()
        if elapsed <= 0:
            return 0.0
            
        return data.get('files_processed', 0) / elapsed
        
    def _calculate_success_rate(self, data: Dict) -> float:
        """Calcula taxa de sucesso"""
        total = data.get('files_processed', 0)
        if total == 0:
            return 100.0
            
        successful = data.get('files_successful', 0)
        return (successful / total) * 100.0
        
    def _count_recent_errors(self) -> int:
        """Conta erros no último minuto"""
        # Implementação simplificada
        return 0
        
    def _handle_alert(self, alert: Dict):
        """Manipula alerta recebido"""
        self._log("ALERT", f"{alert['type'].upper()}: {alert['message']}")
        
    def _notify_update(self, metrics: MetricSnapshot, alerts: List[Dict]):
        """Notifica callbacks de atualização"""
        for callback in self.update_callbacks:
            try:
                callback(metrics, alerts)
            except Exception as e:
                self._log("ERROR", f"Erro no callback de atualização: {e}")
                
    def _notify_status_change(self, status: str):
        """Notifica mudança de status"""
        for callback in self.status_callbacks:
            try:
                callback(status)
            except Exception as e:
                self._log("ERROR", f"Erro no callback de status: {e}")
                
    def _log(self, level: str, message: str):
        """Registra log"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {level}: {message}"
        
        print(log_entry)  # Console
        
        # Arquivo
        if self.log_file:
            try:
                with open(self.log_file, 'a', encoding='utf-8') as f:
                    f.write(log_entry + "\n")
            except Exception:
                pass  # Falha silenciosa em logs
                
    def _log_periodic_status(self):
        """Log periódico de status"""
        if not self.current_metrics:
            return
            
        m = self.current_metrics
        summary = self.performance_tracker.get_performance_summary()
        
        status_msg = (
            f"Status: {m.files_processed} processados, "
            f"{m.success_rate:.1f}% sucesso, "
            f"{m.processing_rate:.2f} arq/s"
        )
        
        self._log("STATUS", status_msg)
        
    def capturar_snapshot(self) -> Dict:
        """Captura snapshot atual das métricas do sistema"""
        if not self.current_metrics:
            return {
                'timestamp': datetime.now().isoformat(),
                'status': 'no_data',
                'message': 'Nenhuma métrica disponível'
            }
            
        return {
            'timestamp': self.current_metrics.timestamp.isoformat(),
            'files_processed': self.current_metrics.files_processed,
            'files_successful': self.current_metrics.files_successful,
            'files_failed': self.current_metrics.files_failed,
            'processing_rate': self.current_metrics.processing_rate,
            'success_rate': self.current_metrics.success_rate,
            'memory_usage': self.current_metrics.memory_usage,
            'cpu_usage': self.current_metrics.cpu_usage,
            'current_file': self.current_metrics.current_file,
            'errors_last_minute': self.current_metrics.errors_last_minute,
            'is_monitoring': self.is_monitoring,
            'uptime': (datetime.now() - self.start_time).total_seconds() if self.start_time else 0
        }
    
    def get_dashboard_data(self) -> Dict:
        """Retorna dados para dashboard"""
        if not self.current_metrics:
            return {'status': 'no_data'}
            
        return {
            'status': 'active' if self.is_monitoring else 'inactive',
            'current_metrics': asdict(self.current_metrics),
            'performance_summary': self.performance_tracker.get_performance_summary(),
            'trend_analysis': self.performance_tracker.get_trend_analysis(),
            'recent_alerts': list(self.alert_manager.alert_history)[-10:],
            'uptime': (datetime.now() - self.start_time).total_seconds() if self.start_time else 0,
            'thresholds': self.thresholds
        }
        
    def export_session_report(self) -> str:
        """Exporta relatório da sessão"""
        if not self.start_time:
            return "Nenhuma sessão ativa"
            
        report_data = {
            'session_info': {
                'start_time': self.start_time.isoformat(),
                'end_time': datetime.now().isoformat(),
                'duration': (datetime.now() - self.start_time).total_seconds()
            },
            'final_metrics': asdict(self.current_metrics) if self.current_metrics else {},
            'performance_summary': self.performance_tracker.get_performance_summary(),
            'all_alerts': list(self.alert_manager.alert_history),
            'trend_analysis': self.performance_tracker.get_trend_analysis()
        }
        
        # Salvar relatório
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"Development/Reports/Monitoring/session_report_{timestamp}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False, default=str)
            
        return report_file

def main():
    """Função de teste"""
    print("🔍 MONITOR DE TEMPO REAL")
    print("="*50)
    
    # Criar monitor
    monitor = MonitorTempoReal(update_interval=2.0)
    
    # Callbacks de exemplo
    def on_update(metrics, alerts):
        print(f"📊 Atualização: {metrics.files_processed} arquivos, {metrics.success_rate:.1f}% sucesso")
        if alerts:
            print(f"⚠️ {len(alerts)} alertas ativos")
            
    def on_status_change(status):
        print(f"🔄 Status mudou para: {status}")
        
    monitor.add_update_callback(on_update)
    monitor.add_status_callback(on_status_change)
    
    # Iniciar monitoramento
    monitor.start_monitoring()
    
    try:
        # Simular processamento
        for i in range(10):
            time.sleep(3)
            
            # Simular dados de progresso
            test_data = {
                'files_processed': i * 10 + 15,
                'files_successful': i * 9 + 12,
                'files_failed': i + 3,
                'memory_usage': 45.5 + i * 2,
                'cpu_usage': 30.0 + i * 1.5,
                'current_file': f"test_file_{i}.mq4"
            }
            
            monitor.update_metrics(test_data)
            
            # Mostrar dashboard
            dashboard = monitor.get_dashboard_data()
            print(f"\n📈 Dashboard: {dashboard['current_metrics']['processing_rate']:.2f} arq/s")
            
    except KeyboardInterrupt:
        print("\n⏹️ Interrompido pelo usuário")
        
    finally:
        # Parar monitoramento
        monitor.stop_monitoring()
        
        # Exportar relatório
        report_file = monitor.export_session_report()
        print(f"\n📄 Relatório da sessão salvo: {report_file}")
        
if __name__ == "__main__":
    main()