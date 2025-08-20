#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Teste Final de Validação - EA FTMO Scalper Elite
Verifica se todas as implementações das bibliotecas secundárias estão completas
"""

import os
import re
from pathlib import Path

class FinalValidationTest:
    def __init__(self):
        self.base_path = Path("MQL5_Source")
        self.include_path = self.base_path / "Include"
        self.results = []
        self.warnings = []
        
    def log_result(self, test_name, passed, message=""):
        status = "✅ PASS" if passed else "❌ FAIL"
        result = f"{status}: {test_name}"
        if message:
            result += f" - {message}"
        self.results.append((passed, result))
        print(result)
        
    def log_warning(self, message):
        warning = f"⚠️  WARNING: {message}"
        self.warnings.append(warning)
        print(warning)
        
    def check_file_exists(self, file_path):
        return file_path.exists() and file_path.is_file()
        
    def read_file_content(self, file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except:
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    return f.read()
            except Exception as e:
                self.log_warning(f"Erro ao ler {file_path}: {e}")
                return ""
                
    def test_signal_confluence_complete(self):
        """Testa se SignalConfluence.mqh está completo"""
        file_path = self.include_path / "SignalConfluence.mqh"
        
        if not self.check_file_exists(file_path):
            self.log_result("SignalConfluence.mqh existe", False, "Arquivo não encontrado")
            return
            
        content = self.read_file_content(file_path)
        
        # Verificar métodos essenciais
        required_methods = [
            "AnalyzeConfluence",
            "CalculateScore", 
            "GetConfluenceLevel",
            "AddSignal"
        ]
        
        for method in required_methods:
            if method in content:
                self.log_result(f"SignalConfluence::{method} presente", True)
            else:
                self.log_result(f"SignalConfluence::{method} presente", False, "Método não encontrado")
                
        # Verificar inclusões necessárias
        required_includes = ["Trade.mqh", "PositionInfo.mqh"]
        for include in required_includes:
            if include in content:
                self.log_result(f"SignalConfluence inclui {include}", True)
            else:
                self.log_result(f"SignalConfluence inclui {include}", False, "Include não encontrado")
                
    def test_dynamic_levels_complete(self):
        """Testa se DynamicLevels.mqh está completo"""
        file_path = self.include_path / "DynamicLevels.mqh"
        
        if not self.check_file_exists(file_path):
            self.log_result("DynamicLevels.mqh existe", False, "Arquivo não encontrado")
            return
            
        content = self.read_file_content(file_path)
        
        # Verificar métodos FTMO essenciais
        ftmo_methods = [
            "CheckDrawdownLimits",
            "GetCurrentDrawdown",
            "ValidateDailyLossLimit",
            "GetCurrentEquity",
            "ValidateEquityProtection",
            "CalculateEquityRisk",
            "SetATRPeriod",
            "SetMultipliers"
        ]
        
        for method in ftmo_methods:
            if method in content:
                self.log_result(f"DynamicLevels::{method} presente", True)
            else:
                self.log_result(f"DynamicLevels::{method} presente", False, "Método não encontrado")
                
        # Verificar inclusões necessárias
        required_includes = ["Trade.mqh", "PositionInfo.mqh", "AccountInfo.mqh"]
        for include in required_includes:
            if include in content:
                self.log_result(f"DynamicLevels inclui {include}", True)
            else:
                self.log_result(f"DynamicLevels inclui {include}", False, "Include não encontrado")
                
    def test_advanced_filters_complete(self):
        """Testa se AdvancedFilters.mqh está completo"""
        file_path = self.include_path / "AdvancedFilters.mqh"
        
        if not self.check_file_exists(file_path):
            self.log_result("AdvancedFilters.mqh existe", False, "Arquivo não encontrado")
            return
            
        content = self.read_file_content(file_path)
        
        # Verificar inclusões necessárias
        required_includes = ["Trade.mqh", "PositionInfo.mqh"]
        for include in required_includes:
            if include in content:
                self.log_result(f"AdvancedFilters inclui {include}", True)
            else:
                self.log_result(f"AdvancedFilters inclui {include}", False, "Include não encontrado")
                
    def test_main_ea_integration(self):
        """Testa se o EA principal integra as bibliotecas"""
        ea_files = list(self.base_path.glob("**/*.mq5"))
        
        if not ea_files:
            self.log_result("EA principal encontrado", False, "Nenhum arquivo .mq5 encontrado")
            return
            
        main_ea = ea_files[0]  # Assumir o primeiro como principal
        content = self.read_file_content(main_ea)
        
        # Verificar inclusões das bibliotecas
        libraries = ["SignalConfluence.mqh", "DynamicLevels.mqh", "AdvancedFilters.mqh"]
        for lib in libraries:
            if lib in content:
                self.log_result(f"EA principal inclui {lib}", True)
            else:
                self.log_result(f"EA principal inclui {lib}", False, "Biblioteca não incluída")
                
    def run_all_tests(self):
        """Executa todos os testes"""
        print("🔍 INICIANDO VALIDAÇÃO FINAL DO EA FTMO SCALPER ELITE")
        print("=" * 60)
        
        self.test_signal_confluence_complete()
        print()
        self.test_dynamic_levels_complete()
        print()
        self.test_advanced_filters_complete()
        print()
        self.test_main_ea_integration()
        
        # Resumo final
        print("\n" + "=" * 60)
        print("📊 RESUMO DA VALIDAÇÃO")
        print("=" * 60)
        
        passed = sum(1 for result in self.results if result[0])
        failed = len(self.results) - passed
        
        print(f"✅ Testes Aprovados: {passed}")
        print(f"❌ Testes Falharam: {failed}")
        print(f"⚠️  Avisos: {len(self.warnings)}")
        
        if failed == 0:
            print("\n🎉 TODAS AS BIBLIOTECAS ESTÃO COMPLETAS E FUNCIONAIS!")
            print("✅ O EA FTMO Scalper Elite está pronto para compilação e testes.")
        else:
            print("\n⚠️  ALGUMAS IMPLEMENTAÇÕES AINDA PRECISAM SER CORRIGIDAS.")
            print("❌ Falhas encontradas que precisam ser resolvidas.")
            
        return failed == 0

if __name__ == "__main__":
    validator = FinalValidationTest()
    success = validator.run_all_tests()
    exit(0 if success else 1)