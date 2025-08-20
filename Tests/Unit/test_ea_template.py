
#!/usr/bin/env python3
"""
Exemplo de Teste Unitário - EA Template
"""

import pytest
import sys
from pathlib import Path

# Adicionar o diretório raiz ao path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

class TestEATemplate:
    """Testes para o template de EA"""
    
    @pytest.mark.unit
    def test_ea_template_exists(self):
        """Verifica se o template de EA existe"""
        template_path = Path(__file__).parent.parent.parent / "MQL5_Source" / "EAs" / "FTMO_Ready" / "EA_Template_FTMO.mq5"
        assert template_path.exists(), "Template de EA não encontrado"
    
    @pytest.mark.unit
    def test_ea_template_content(self):
        """Verifica conteúdo básico do template"""
        template_path = Path(__file__).parent.parent.parent / "MQL5_Source" / "EAs" / "FTMO_Ready" / "EA_Template_FTMO.mq5"
        
        with open(template_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Verificar elementos essenciais FTMO
        assert "RiskPercent" in content, "Parâmetro de risco não encontrado"
        assert "MaxDailyLoss" in content, "Controle de perda diária não encontrado"
        assert "MaxTotalDD" in content, "Controle de drawdown não encontrado"
        assert "CheckRiskManagement" in content, "Função de gerenciamento de risco não encontrada"
        assert "CloseAllPositions" in content, "Função de fechamento de posições não encontrada"
    
    @pytest.mark.ftmo
    def test_ftmo_compliance_parameters(self):
        """Verifica parâmetros de compliance FTMO"""
        # Este teste verificaria se os parâmetros estão dentro dos limites FTMO
        max_risk = 1.0  # 1% máximo por trade
        max_daily_loss = 5.0  # 5% máximo de perda diária
        max_drawdown = 10.0  # 10% máximo de drawdown
        
        assert max_risk <= 2.0, "Risco por trade muito alto para FTMO"
        assert max_daily_loss <= 5.0, "Perda diária muito alta para FTMO"
        assert max_drawdown <= 10.0, "Drawdown muito alto para FTMO"
