#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Teste de Validação das Melhorias do EA FTMO Scalper Elite

Este script valida as implementações dos sistemas:
- SignalConfluence.mqh
- DynamicLevels.mqh  
- AdvancedFilters.mqh

Autor: TradeDev_Master
Data: 2025-08-19
Versão: 1.0
"""

import os
import re
import pytest
from pathlib import Path
from typing import Dict, List, Tuple

# Configuração de caminhos
BASE_DIR = Path(__file__).parent.parent
EA_DIR = BASE_DIR / "EA_FTMO_SCALPER_ELITE"
INCLUDE_DIR = EA_DIR / "MQL5_Source" / "Include"

class TestEAImprovements:
    """Classe de testes para validar as melhorias do EA FTMO Scalper Elite"""
    
    def setup_method(self):
        """Setup executado antes de cada teste"""
        self.include_files = {
            'confluence': INCLUDE_DIR / "SignalConfluence.mqh",
            'dynamic_levels': INCLUDE_DIR / "DynamicLevels.mqh",
            'advanced_filters': INCLUDE_DIR / "AdvancedFilters.mqh"
        }
        
    @pytest.mark.unit
    def test_include_files_exist(self):
        """Testa se todos os arquivos de include existem"""
        for name, file_path in self.include_files.items():
            assert file_path.exists(), f"Arquivo {name} não encontrado: {file_path}"
            assert file_path.is_file(), f"Caminho não é um arquivo: {file_path}"
            
    @pytest.mark.unit
    def test_signal_confluence_implementation(self):
        """Testa a implementação do sistema de confluência de sinais"""
        file_path = self.include_files['confluence']
        content = file_path.read_text(encoding='utf-8', errors='ignore')
        
        # Testa estruturas essenciais
        required_structures = [
            'class CSignalConfluence',
            'struct SConfluenceResult',
            'AnalyzeConfluence',
            'CalculateScore',
            'GetConfluenceLevel'
        ]
        
        for structure in required_structures:
            assert structure in content, f"Estrutura '{structure}' não encontrada em SignalConfluence.mqh"
            
        # Testa métodos específicos
        required_methods = [
            'SetWeights',
            'AddSignal',
            'GetTotalScore',
            'IsValidConfluence'
        ]
        
        for method in required_methods:
            pattern = rf'\b{method}\s*\('
            assert re.search(pattern, content), f"Método '{method}' não encontrado em SignalConfluence.mqh"
            
    @pytest.mark.unit
    def test_dynamic_levels_implementation(self):
        """Testa a implementação do sistema de níveis dinâmicos"""
        file_path = self.include_files['dynamic_levels']
        content = file_path.read_text(encoding='utf-8', errors='ignore')
        
        # Testa estruturas essenciais
        required_structures = [
            'class CDynamicLevels',
            'struct SLevelResult',
            'CalculateDynamicSL',
            'CalculateDynamicTP',
            'UpdateLevels'
        ]
        
        for structure in required_structures:
            assert structure in content, f"Estrutura '{structure}' não encontrada em DynamicLevels.mqh"
            
        # Testa métodos específicos
        required_methods = [
            'SetATRPeriod',
            'SetMultipliers',
            'GetOptimalLevels',
            'GetLevelsConfig'
        ]
        
        for method in required_methods:
            pattern = rf'\b{method}\s*\('
            assert re.search(pattern, content), f"Método '{method}' não encontrado em DynamicLevels.mqh"
            
    @pytest.mark.unit
    def test_advanced_filters_implementation(self):
        """Testa a implementação do sistema de filtros avançados"""
        file_path = self.include_files['advanced_filters']
        content = file_path.read_text(encoding='utf-8', errors='ignore')
        
        # Testa estruturas essenciais
        required_structures = [
            'class CAdvancedFilters',
            'struct SFilterResult',
            'AnalyzeFilters',
            'AnalyzeMomentum',
            'AnalyzeVolume',
            'AnalyzeTrend'
        ]
        
        for structure in required_structures:
            assert structure in content, f"Estrutura '{structure}' não encontrada em AdvancedFilters.mqh"
            
        # Testa filtros específicos
        required_filters = [
            'SetMomentumFilter',
            'SetVolumeFilter', 
            'SetTrendFilter',
            'SetNewsFilter'
        ]
        
        for filter_method in required_filters:
            pattern = rf'\b{filter_method}\s*\('
            assert re.search(pattern, content), f"Filtro '{filter_method}' não encontrado em AdvancedFilters.mqh"
            
    @pytest.mark.integration
    def test_ea_main_file_integration(self):
        """Testa se o arquivo principal do EA inclui as melhorias"""
        main_ea_file = EA_DIR / "MQL5_Source" / "EA_FTMO_Scalper_Elite.mq5"
        
        if main_ea_file.exists():
            content = main_ea_file.read_text(encoding='utf-8', errors='ignore')
            
            # Testa includes das melhorias
            required_includes = [
                'SignalConfluence.mqh',
                'DynamicLevels.mqh',
                'AdvancedFilters.mqh'
            ]
            
            for include in required_includes:
                assert include in content, f"Include '{include}' não encontrado no EA principal"
                
            # Testa instanciação das classes
            required_instances = [
                'CSignalConfluence',
                'CDynamicLevels', 
                'CAdvancedFilters'
            ]
            
            for instance in required_instances:
                pattern = rf'\b{instance}\s+\w+'
                assert re.search(pattern, content), f"Instância de '{instance}' não encontrada no EA principal"
                
    @pytest.mark.ftmo
    def test_ftmo_compliance_features(self):
        """Testa se as melhorias mantêm compliance FTMO"""
        
        # Testa DynamicLevels para compliance FTMO
        dynamic_content = self.include_files['dynamic_levels'].read_text(encoding='utf-8', errors='ignore')
        
        ftmo_features = [
            'stop.*loss',
            'take.*profit',
            'risk.*management',
            'drawdown',
            'equity'
        ]
        
        for feature in ftmo_features:
            pattern = rf'\b{feature}\b'
            assert re.search(pattern, dynamic_content, re.IGNORECASE), \
                f"Feature FTMO '{feature}' não encontrada em DynamicLevels.mqh"
                
        # Testa AdvancedFilters para proteções FTMO
        filters_content = self.include_files['advanced_filters'].read_text(encoding='utf-8', errors='ignore')
        
        ftmo_protections = [
            'news.*filter',
            'spread.*filter',
            'volatility',
            'session.*filter'
        ]
        
        for protection in ftmo_protections:
            pattern = rf'\b{protection}\b'
            assert re.search(pattern, filters_content, re.IGNORECASE), \
                f"Proteção FTMO '{protection}' não encontrada em AdvancedFilters.mqh"
                
    @pytest.mark.performance
    def test_code_quality_metrics(self):
        """Testa métricas de qualidade do código"""
        
        for name, file_path in self.include_files.items():
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            
            # Testa se há comentários de documentação
            assert '//+--' in content or '/*' in content, \
                f"Arquivo {name} não possui comentários de documentação adequados"
                
            # Testa se há tratamento de erros
            error_handling_patterns = [
                'if.*error',
                'try.*catch',
                'return.*false',
                'Print.*Error'
            ]
            
            has_error_handling = any(
                re.search(pattern, content, re.IGNORECASE) 
                for pattern in error_handling_patterns
            )
            
            assert has_error_handling, \
                f"Arquivo {name} não possui tratamento de erros adequado"
                
            # Testa se há validação de parâmetros
            validation_patterns = [
                'if.*<.*0',
                'if.*>.*100',
                'if.*NULL',
                'if.*INVALID'
            ]
            
            has_validation = any(
                re.search(pattern, content, re.IGNORECASE)
                for pattern in validation_patterns
            )
            
            assert has_validation, \
                f"Arquivo {name} não possui validação de parâmetros adequada"
                
    def test_file_sizes_reasonable(self):
        """Testa se os arquivos têm tamanhos razoáveis (não muito pequenos nem muito grandes)"""
        
        for name, file_path in self.include_files.items():
            file_size = file_path.stat().st_size
            
            # Arquivo deve ter pelo menos 1KB (implementação mínima)
            assert file_size > 1024, \
                f"Arquivo {name} muito pequeno ({file_size} bytes) - possível implementação incompleta"
                
            # Arquivo não deve exceder 100KB (código muito complexo)
            assert file_size < 102400, \
                f"Arquivo {name} muito grande ({file_size} bytes) - possível código excessivamente complexo"
                
    def test_mql5_syntax_basic_validation(self):
        """Testa validação básica de sintaxe MQL5"""
        
        for name, file_path in self.include_files.items():
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            
            # Testa se há estrutura básica de classe MQL5
            assert 'class' in content, f"Arquivo {name} não contém definição de classe"
            assert '{' in content and '}' in content, f"Arquivo {name} não possui estrutura de blocos válida"
            
            # Testa se há includes MQL5 padrão quando necessário
            if 'Trade' in content or 'Position' in content:
                trade_includes = ['Trade.mqh', 'PositionInfo.mqh', 'OrderInfo.mqh']
                has_trade_include = any(include in content for include in trade_includes)
                assert has_trade_include, \
                    f"Arquivo {name} usa funcionalidades de trade mas não inclui bibliotecas necessárias"

if __name__ == "__main__":
    # Execução direta do script
    pytest.main([__file__, "-v", "--tb=short"])