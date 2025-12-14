from data_analyzer import DataAnalyzer
from performance_monitor import PerformanceMonitor

class AlertSystem:
    def __init__(self, analyzer: DataAnalyzer):
        self.analyzer = analyzer
        self.alerts = []
        
        # Limites de alerta (configuráveis)
        self.max_drawdown_limit = 10.0  # em porcentagem
        self.consecutive_losses_limit = 3

    def check_alerts(self):
        """Verifica se algum alerta deve ser disparado."""
        self.alerts = [] # Limpa alertas anteriores
        
        # Alerta de Drawdown
        max_drawdown = self.analyzer.calculate_max_drawdown()
        if max_drawdown > self.max_drawdown_limit:
            alert_msg = f"ALERTA: Drawdown máximo ({max_drawdown:.2f}%) excedeu o limite de {self.max_drawdown_limit:.2f}%!"
            self.alerts.append(alert_msg)
            print(alert_msg)
            
        # Alerta de Perdas Consecutivas
        consecutive_losses = self._calculate_consecutive_losses()
        if consecutive_losses >= self.consecutive_losses_limit:
            alert_msg = f"ALERTA: {consecutive_losses} perdas consecutivas atingiram o limite de {self.consecutive_losses_limit}!"
            self.alerts.append(alert_msg)
            print(alert_msg)
            
        return self.alerts

    def _calculate_consecutive_losses(self):
        """Calcula o número máximo de perdas consecutivas."""
        if not self.analyzer.monitor.trades:
            return 0
            
        max_losses = 0
        current_losses = 0
        for trade in self.analyzer.monitor.trades:
            if trade['profit'] < 0:
                current_losses += 1
            else:
                if current_losses > max_losses:
                    max_losses = current_losses
                current_losses = 0
        
        if current_losses > max_losses:
            max_losses = current_losses
            
        return max_losses

if __name__ == '__main__':
    # Exemplo de uso
    monitor = PerformanceMonitor()
    analyzer = DataAnalyzer(monitor)
    alerter = AlertSystem(analyzer)
    
    # Simulação de trades que disparam alertas
    print("--- Simulando Trades ---")
    monitor.register_trade('buy', 1.1000, 1.0900, 10000) # Perda
    monitor.register_trade('buy', 1.0900, 1.0850, 10000) # Perda
    monitor.register_trade('buy', 1.0850, 1.0800, 10000) # Perda
    
    print("\n--- Verificando Alertas ---")
    alerter.check_alerts()
    
    # Mais um trade para testar o drawdown
    monitor.register_trade('buy', 1.0800, 1.0500, 10000) # Perda grande
    
    print("\n--- Verificando Alertas Novamente ---")
    alerter.check_alerts()