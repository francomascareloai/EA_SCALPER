from performance_monitor import PerformanceMonitor

class DataAnalyzer:
    def __init__(self, monitor: PerformanceMonitor):
        self.monitor = monitor

    def calculate_max_drawdown(self):
        """Calcula o drawdown máximo."""
        peak_balance = self.monitor.initial_balance
        max_drawdown = 0.0
        
        balance_history = [self.monitor.initial_balance]
        current_balance = self.monitor.initial_balance
        
        for trade in self.monitor.trades:
            current_balance += trade['profit']
            balance_history.append(current_balance)
            
            if current_balance > peak_balance:
                peak_balance = current_balance
            
            drawdown = (peak_balance - current_balance) / peak_balance
            if drawdown > max_drawdown:
                max_drawdown = drawdown
                
        return max_drawdown * 100  # Retorna como porcentagem

    def get_advanced_analysis(self):
        """Retorna uma análise de dados mais avançada."""
        summary = self.monitor.get_summary()
        summary['max_drawdown'] = self.calculate_max_drawdown()
        return summary

if __name__ == '__main__':
    # Exemplo de uso
    monitor = PerformanceMonitor()
    
    # Simulação de trades
    monitor.register_trade('buy', 1.1000, 1.1050, 10000) # Lucro: 50
    monitor.register_trade('sell', 1.1050, 1.1030, 10000) # Lucro: 20
    monitor.register_trade('buy', 1.1030, 1.1000, 10000) # Prejuízo: -30
    monitor.register_trade('buy', 1.1000, 1.1080, 10000) # Lucro: 80
    
    analyzer = DataAnalyzer(monitor)
    
    print("\n--- Análise Avançada de Desempenho ---")
    advanced_summary = analyzer.get_advanced_analysis()
    for key, value in advanced_summary.items():
        print(f"{key.replace('_', ' ').title()}: {value:.2f}")
