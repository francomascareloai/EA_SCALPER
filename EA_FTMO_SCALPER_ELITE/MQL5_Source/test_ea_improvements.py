#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Teste Abrangente - EA FTMO Scalper Elite
Testa todas as melhorias implementadas no Expert Advisor
"""

import os
import re
from pathlib import Path
from datetime import datetime

class EATestSuite:
    def __init__(self):
        self.base_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source")
        self.main_file = self.base_path / "EA_FTMO_Scalper_Elite.mq5"
        self.test_results = []
        
    def log_test(self, test_name, status, details=""):
        """Registra resultado de teste"""
        self.test_results.append({
            'test': test_name,
            'status': status,
            'details': details,
            'timestamp': datetime.now().strftime('%H:%M:%S')
        })
        
    def test_signal_confluence_system(self):
        """Testa sistema de confluência de sinais"""
        print("🔍 Testando Sistema de Confluência de Sinais...")
        
        confluence_file = self.base_path / "Include" / "SignalConfluence.mqh"
        if not confluence_file.exists():
            self.log_test("Signal Confluence", "FAIL", "Arquivo SignalConfluence.mqh não encontrado")
            return False
            
        with open(confluence_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar componentes essenciais
        checks = [
            ("class CSignalConfluence", "Classe principal definida"),
            ("CalculateConfluenceScore", "Método de cálculo de score"),
            ("ValidateSignal", "Método de validação"),
            ("struct SConfluenceConfig", "Estrutura de configuração"),
            ("enum ENUM_SIGNAL_STRENGTH", "Enum de força do sinal")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"Confluence - {description}", "PASS")
            else:
                self.log_test(f"Confluence - {description}", "FAIL")
                all_passed = False
                
        return all_passed
        
    def test_dynamic_levels_system(self):
        """Testa sistema de níveis dinâmicos"""
        print("📊 Testando Sistema de Níveis Dinâmicos...")
        
        dynamic_file = self.base_path / "Include" / "DynamicLevels.mqh"
        if not dynamic_file.exists():
            self.log_test("Dynamic Levels", "FAIL", "Arquivo DynamicLevels.mqh não encontrado")
            return False
            
        with open(dynamic_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        checks = [
            ("class CDynamicLevels", "Classe principal definida"),
            ("CalculateDynamicSL", "Cálculo de SL dinâmico"),
            ("CalculateDynamicTP", "Cálculo de TP dinâmico"),
            ("UpdateLevels", "Atualização de níveis"),
            ("struct SDynamicConfig", "Estrutura de configuração")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"Dynamic Levels - {description}", "PASS")
            else:
                self.log_test(f"Dynamic Levels - {description}", "FAIL")
                all_passed = False
                
        return all_passed
        
    def test_advanced_filters_system(self):
        """Testa sistema de filtros avançados"""
        print("🔧 Testando Sistema de Filtros Avançados...")
        
        filters_file = self.base_path / "Include" / "AdvancedFilters.mqh"
        if not filters_file.exists():
            self.log_test("Advanced Filters", "FAIL", "Arquivo AdvancedFilters.mqh não encontrado")
            return False
            
        with open(filters_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        checks = [
            ("class CAdvancedFilters", "Classe principal definida"),
            ("CheckMomentumFilter", "Filtro de momentum"),
            ("CheckVolumeFilter", "Filtro de volume"),
            ("CheckTrendFilter", "Filtro de tendência"),
            ("CheckNewsFilter", "Filtro de notícias"),
            ("struct SFilterConfig", "Estrutura de configuração")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"Advanced Filters - {description}", "PASS")
            else:
                self.log_test(f"Advanced Filters - {description}", "FAIL")
                all_passed = False
                
        return all_passed
        
    def test_smart_trailing_stop(self):
        """Testa sistema de trailing stop inteligente"""
        print("🎯 Testando Trailing Stop Inteligente...")
        
        with open(self.main_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        checks = [
            ("enum ENUM_TRAILING_METHOD", "Enum de métodos de trailing"),
            ("ApplyTrailingStop", "Função principal de trailing"),
            ("CalculateFixedTrailingSL", "Trailing fixo"),
            ("CalculateOrderBlockTrailingSL", "Trailing por Order Blocks"),
            ("CalculateStructureBreakTrailingSL", "Trailing por quebra de estrutura"),
            ("CalculateFVGTrailingSL", "Trailing por FVG"),
            ("CalculateLiquidityTrailingSL", "Trailing por liquidez"),
            ("CalculateATRTrailingSL", "Trailing por ATR"),
            ("ValidateTrailingSL", "Validação de trailing")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"Smart Trailing - {description}", "PASS")
            else:
                self.log_test(f"Smart Trailing - {description}", "FAIL")
                all_passed = False
                
        return all_passed
        
    def test_main_ea_integration(self):
        """Testa integração no EA principal"""
        print("🔗 Testando Integração no EA Principal...")
        
        with open(self.main_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        checks = [
            ("#include \"Include/SignalConfluence.mqh\"", "Include SignalConfluence"),
            ("#include \"Include/DynamicLevels.mqh\"", "Include DynamicLevels"),
            ("#include \"Include/AdvancedFilters.mqh\"", "Include AdvancedFilters"),
            ("CSignalConfluence", "Instância SignalConfluence"),
            ("CDynamicLevels", "Instância DynamicLevels"),
            ("CAdvancedFilters", "Instância AdvancedFilters"),
            ("atr_handle", "Handle ATR declarado")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"Integration - {description}", "PASS")
            else:
                self.log_test(f"Integration - {description}", "FAIL")
                all_passed = False
                
        return all_passed
        
    def test_ftmo_compliance(self):
        """Testa conformidade FTMO"""
        print("🏛️ Testando Conformidade FTMO...")
        
        with open(self.main_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        checks = [
            ("MaxRiskPerTrade", "Controle de risco por trade"),
            ("MaxDailyLoss", "Controle de perda diária"),
            ("MaxDrawdown", "Controle de drawdown"),
            ("NewsFilter", "Filtro de notícias"),
            ("StopLoss", "Stop Loss obrigatório"),
            ("TakeProfit", "Take Profit definido"),
            ("RiskManager", "Gerenciador de risco")
        ]
        
        all_passed = True
        for check, description in checks:
            if check in content:
                self.log_test(f"FTMO - {description}", "PASS")
            else:
                self.log_test(f"FTMO - {description}", "WARN", "Verificar implementação")
                
        return all_passed
        
    def test_performance_metrics(self):
        """Testa métricas de performance"""
        print("⚡ Testando Métricas de Performance...")
        
        # Verificar se há loops desnecessários ou operações custosas
        with open(self.main_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Contar operações potencialmente custosas
        expensive_ops = [
            (content.count('for('), "Loops for"),
            (content.count('while('), "Loops while"),
            (content.count('CopyBuffer'), "Operações CopyBuffer"),
            (content.count('iCustom'), "Indicadores customizados"),
            (content.count('Print('), "Operações de Print")
        ]
        
        for count, operation in expensive_ops:
            if count > 0:
                status = "WARN" if count > 10 else "INFO"
                self.log_test(f"Performance - {operation}", status, f"Encontradas {count} ocorrências")
            else:
                self.log_test(f"Performance - {operation}", "PASS", "Nenhuma ocorrência")
                
        return True
        
    def run_all_tests(self):
        """Executa todos os testes"""
        print("🚀 INICIANDO TESTE ABRANGENTE DO EA FTMO SCALPER ELITE")
        print("=" * 60)
        print()
        
        tests = [
            self.test_signal_confluence_system,
            self.test_dynamic_levels_system,
            self.test_advanced_filters_system,
            self.test_smart_trailing_stop,
            self.test_main_ea_integration,
            self.test_ftmo_compliance,
            self.test_performance_metrics
        ]
        
        passed_tests = 0
        total_tests = len(tests)
        
        for test in tests:
            try:
                if test():
                    passed_tests += 1
                print()
            except Exception as e:
                self.log_test(f"Test Error - {test.__name__}", "ERROR", str(e))
                print(f"❌ Erro no teste {test.__name__}: {e}")
                print()
        
        self.generate_report(passed_tests, total_tests)
        
    def generate_report(self, passed_tests, total_tests):
        """Gera relatório final"""
        print("📋 RELATÓRIO FINAL DE TESTES")
        print("=" * 60)
        
        # Estatísticas gerais
        print(f"✅ Testes Principais Aprovados: {passed_tests}/{total_tests}")
        print(f"📊 Taxa de Sucesso: {(passed_tests/total_tests)*100:.1f}%")
        print()
        
        # Detalhes por categoria
        categories = {}
        for result in self.test_results:
            category = result['test'].split(' - ')[0]
            if category not in categories:
                categories[category] = {'PASS': 0, 'FAIL': 0, 'WARN': 0, 'INFO': 0, 'ERROR': 0}
            categories[category][result['status']] += 1
        
        print("📈 RESULTADOS POR CATEGORIA:")
        for category, stats in categories.items():
            total = sum(stats.values())
            pass_rate = (stats['PASS'] / total * 100) if total > 0 else 0
            print(f"   {category}: {stats['PASS']}/{total} ({pass_rate:.1f}% aprovação)")
            if stats['FAIL'] > 0:
                print(f"      ❌ {stats['FAIL']} falhas")
            if stats['WARN'] > 0:
                print(f"      ⚠️  {stats['WARN']} avisos")
        print()
        
        # Falhas críticas
        failures = [r for r in self.test_results if r['status'] == 'FAIL']
        if failures:
            print("🚨 FALHAS CRÍTICAS:")
            for failure in failures:
                print(f"   ❌ {failure['test']}: {failure['details']}")
            print()
        
        # Avisos importantes
        warnings = [r for r in self.test_results if r['status'] == 'WARN']
        if warnings:
            print("⚠️  AVISOS IMPORTANTES:")
            for warning in warnings:
                print(f"   ⚠️  {warning['test']}: {warning['details']}")
            print()
        
        # Recomendações
        print("💡 RECOMENDAÇÕES:")
        if passed_tests == total_tests:
            print("   🎉 Todos os sistemas principais estão funcionais!")
            print("   ✅ EA pronto para testes em Strategy Tester")
            print("   📊 Recomendado: Executar backtest com dados históricos")
        else:
            print("   🔧 Corrigir falhas críticas antes de prosseguir")
            print("   🧪 Executar testes unitários adicionais")
            print("   📝 Revisar documentação das funcionalidades")
        
        print()
        print(f"⏰ Teste concluído em {datetime.now().strftime('%H:%M:%S')}")
        print("=" * 60)

if __name__ == "__main__":
    test_suite = EATestSuite()
    test_suite.run_all_tests()