import time

class PerformanceMonitor:
    def __init__(self):
        self.trades = []
        self.start_time = time.time()
        self.initial_balance = 10000.0
        self.current_balance = self.initial_balance

    def register_trade(self, trade_type, entry_price, exit_price, volume):
        """Registra um novo trade."""
        profit = 0
        if trade_type == 'buy':
            profit = (exit_price - entry_price) * volume
        elif trade_type == 'sell':
            profit = (entry_price - exit_price) * volume
        
        self.current_balance += profit
        
        trade_data = {
            'type': trade_type,
            'entry_price': entry_price,
            'exit_price': exit_price,
            'volume': volume,
            'profit': profit,
            'timestamp': time.time()
        }
        self.trades.append(trade_data)
        print(f"[PerformanceMonitor] Trade registrado: {trade_data}")

    def get_total_trades(self):
        """Retorna o número total de trades."""
        return len(self.trades)

    def get_net_profit(self):
        """Calcula o lucro líquido total."""
        return self.current_balance - self.initial_balance

    def get_profit_factor(self):
        """Calcula o fator de lucro."""
        gross_profit = sum(t['profit'] for t in self.trades if t['profit'] > 0)
        gross_loss = abs(sum(t['profit'] for t in self.trades if t['profit'] < 0))
        
        if gross_loss == 0:
            return float('inf') if gross_profit > 0 else 0
        
        return gross_profit / gross_loss

    def get_win_rate(self):
        """Calcula a taxa de acerto."""
        winning_trades = sum(1 for t in self.trades if t['profit'] > 0)
        total_trades = self.get_total_trades()
        
        if total_trades == 0:
            return 0.0
        
        return (winning_trades / total_trades) * 100

    def get_summary(self):
        """Retorna um resumo do desempenho."""
        summary = {
            'total_trades': self.get_total_trades(),
            'net_profit': self.get_net_profit(),
            'profit_factor': self.get_profit_factor(),
            'win_rate': self.get_win_rate(),
            'current_balance': self.current_balance
        }
        return summary

if __name__ == '__main__':
    # Exemplo de uso
    monitor = PerformanceMonitor()
    
    # Simulação de alguns trades
    monitor.register_trade('buy', 1.1000, 1.1050, 10000)
    monitor.register_trade('sell', 1.1050, 1.1030, 10000)
    monitor.register_trade('buy', 1.1030, 1.1000, 10000) # Prejuízo
    
    print("\n--- Resumo do Desempenho ---")
    summary = monitor.get_summary()
    for key, value in summary.items():
        print(f"{key.replace('_', ' ').title()}: {value:.2f}")
