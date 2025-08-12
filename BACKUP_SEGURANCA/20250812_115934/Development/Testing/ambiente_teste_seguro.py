#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AMBIENTE DE TESTE SEGURO - CLASSIFICADOR TRADING
Teste controlado sem comprometer dados originais
Autor: Classificador_Trading_Elite
Versão: 1.0
"""

import os
import shutil
from pathlib import Path
from classificador_qualidade_maxima import TradingCodeAnalyzer

class AmbienteTesteSeguro:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.test_folder = self.base_path / "TESTE_SEGURO"
        self.analyzer = TradingCodeAnalyzer(str(self.test_folder))
        
    def criar_ambiente_teste(self):
        """Cria ambiente de teste isolado"""
        print("🔒 CRIANDO AMBIENTE DE TESTE SEGURO")
        print("="*50)
        
        # Criar pasta de teste
        if self.test_folder.exists():
            print(f"⚠️ Pasta de teste já existe: {self.test_folder}")
            resposta = input("Deseja recriar? (s/n): ")
            if resposta.lower() == 's':
                shutil.rmtree(self.test_folder)
            else:
                return False
        
        self.test_folder.mkdir(exist_ok=True)
        
        # Criar estrutura mínima
        test_structure = [
            "CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4",
            "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Scalping",
            "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Trend_Following",
            "CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Custom",
            "Metadata/Individual",
            "Reports"
        ]
        
        for folder in test_structure:
            (self.test_folder / folder).mkdir(parents=True, exist_ok=True)
        
        print(f"✅ Ambiente de teste criado em: {self.test_folder}")
        return True
    
    def copiar_arquivos_teste(self, max_files=3):
        """Copia alguns arquivos para teste (SEM MOVER)"""
        print(f"\n📁 COPIANDO ARQUIVOS PARA TESTE (máximo {max_files})")
        print("="*50)
        
        # Buscar arquivos .mq4 existentes
        source_folders = [
            self.base_path / "CODIGO_FONTE_LIBRARY/MQL4_Source/Unclassified",
            self.base_path / "CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators"
        ]
        
        arquivos_copiados = 0
        test_all_mq4 = self.test_folder / "CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4"
        
        for source_folder in source_folders:
            if not source_folder.exists():
                continue
                
            for arquivo in source_folder.glob("*.mq4"):
                if arquivos_copiados >= max_files:
                    break
                    
                # COPIAR (não mover) para teste
                destino = test_all_mq4 / arquivo.name
                shutil.copy2(arquivo, destino)
                print(f"📄 Copiado: {arquivo.name}")
                arquivos_copiados += 1
        
        print(f"✅ {arquivos_copiados} arquivos copiados para teste")
        return arquivos_copiados
    
    def executar_teste_classificacao(self):
        """Executa teste de classificação no ambiente seguro"""
        print(f"\n🧪 EXECUTANDO TESTE DE CLASSIFICAÇÃO")
        print("="*50)
        
        test_all_mq4 = self.test_folder / "CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4"
        arquivos = list(test_all_mq4.glob("*.mq4"))
        
        if not arquivos:
            print("❌ Nenhum arquivo encontrado para teste")
            return
        
        resultados = []
        
        for arquivo in arquivos:
            print(f"\n📊 Analisando: {arquivo.name}")
            try:
                analysis = self.analyzer.analyze_file(arquivo)
                if 'error' not in analysis:
                    print(f"  ✅ Tipo: {analysis['file_type']}")
                    print(f"  ✅ Estratégia: {analysis['strategy']}")
                    print(f"  ✅ FTMO: {analysis['ftmo_compliance']['level']}")
                    print(f"  ✅ Qualidade: {analysis['code_quality']['quality_level']}")
                    resultados.append(analysis)
                else:
                    print(f"  ❌ Erro: {analysis['error']}")
            except Exception as e:
                print(f"  ❌ Exceção: {e}")
        
        print(f"\n📈 RESUMO DO TESTE")
        print(f"Total analisado: {len(resultados)}")
        print(f"Sucessos: {len([r for r in resultados if r.get('file_type') != 'Unknown'])}")
        
        return resultados
    
    def limpar_ambiente_teste(self):
        """Remove ambiente de teste"""
        if self.test_folder.exists():
            shutil.rmtree(self.test_folder)
            print(f"🗑️ Ambiente de teste removido: {self.test_folder}")
    
    def comparar_performance_python_vs_manual(self):
        """Análise de performance Python vs Manual"""
        print(f"\n⚡ ANÁLISE: PYTHON vs INTERAÇÃO MANUAL")
        print("="*60)
        
        analise = """
🐍 PYTHON (Processamento em Lote):
✅ VANTAGENS:
  • Velocidade: 100-1000x mais rápido
  • Consistência: Mesmos critérios sempre
  • Escalabilidade: Processa milhares de arquivos
  • Automação: Zero intervenção manual
  • Precisão: Sem erros humanos
  • Rastreabilidade: Log completo de ações
  • Reversibilidade: Backup automático

❌ DESVANTAGENS:
  • Setup inicial necessário
  • Pode precisar ajustes nos padrões
  • Menos flexibilidade para casos especiais

🤖 INTERAÇÃO MANUAL (Você + Assistente):
✅ VANTAGENS:
  • Flexibilidade total
  • Decisões contextuais
  • Casos especiais bem tratados
  • Controle granular

❌ DESVANTAGENS:
  • Muito lento (1 arquivo por vez)
  • Inconsistência potencial
  • Fadiga em grandes volumes
  • Propenso a erros
  • Não escalável

🎯 RECOMENDAÇÃO:
  Para sua biblioteca (centenas/milhares de arquivos):
  1. Use PYTHON para 95% dos arquivos
  2. Reserve interação manual para casos especiais
  3. Valide amostras do resultado Python
  4. Ajuste padrões conforme necessário

📊 ESTIMATIVA DE TEMPO:
  • Python: 1000 arquivos em ~10 minutos
  • Manual: 1000 arquivos em ~50 horas
        """
        
        print(analise)
        return analise

def main():
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    teste = AmbienteTesteSeguro(base_path)
    
    try:
        # Criar ambiente seguro
        if not teste.criar_ambiente_teste():
            return
        
        # Copiar arquivos para teste
        if teste.copiar_arquivos_teste(3) == 0:
            print("❌ Nenhum arquivo disponível para teste")
            return
        
        # Executar teste
        resultados = teste.executar_teste_classificacao()
        
        # Análise de performance
        teste.comparar_performance_python_vs_manual()
        
        # Perguntar se quer limpar
        resposta = input("\nDeseja manter ambiente de teste? (s/n): ")
        if resposta.lower() == 'n':
            teste.limpar_ambiente_teste()
        
    except Exception as e:
        print(f"❌ Erro no teste: {e}")
        teste.limpar_ambiente_teste()

if __name__ == "__main__":
    main()