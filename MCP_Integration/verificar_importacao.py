#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Verificação: Importação do Classificador_Trading no Kilocode

Este script verifica se o modo customizado foi importado corretamente
e se todas as configurações estão funcionando adequadamente.

Autor: Classificador_Trading
Data: Janeiro 2025
Versão: 1.0
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime

class VerificadorImportacao:
    def __init__(self):
        # Corrigir caminho para o diretório pai (raiz do projeto)
        self.projeto_root = Path.cwd().parent if Path.cwd().name == 'MCP_Integration' else Path.cwd()
        self.arquivo_modos = self.projeto_root / '.kilocodemodes'
        self.arquivo_mcp = self.projeto_root / '.kilocode' / 'mcp.json'
        self.resultados = []
        
    def log_resultado(self, teste, status, detalhes=""):
        """Registra resultado de um teste"""
        emoji = "✅" if status else "❌"
        self.resultados.append({
            'teste': teste,
            'status': status,
            'detalhes': detalhes,
            'emoji': emoji
        })
        print(f"{emoji} {teste}: {detalhes}")
    
    def verificar_arquivo_modos(self):
        """Verifica se o arquivo .kilocodemodes existe e é válido"""
        print("\n🔍 VERIFICANDO ARQUIVO .kilocodemodes")
        print("=" * 50)
        
        # Verificar existência
        if not self.arquivo_modos.exists():
            self.log_resultado(
                "Arquivo .kilocodemodes", 
                False, 
                "Arquivo não encontrado na raiz do projeto"
            )
            return False
        
        self.log_resultado(
            "Arquivo .kilocodemodes", 
            True, 
            f"Encontrado em {self.arquivo_modos}"
        )
        
        # Verificar JSON válido
        try:
            with open(self.arquivo_modos, 'r', encoding='utf-8') as f:
                dados = json.load(f)
            
            self.log_resultado(
                "JSON Válido", 
                True, 
                "Sintaxe JSON correta"
            )
            
        except json.JSONDecodeError as e:
            self.log_resultado(
                "JSON Válido", 
                False, 
                f"Erro de sintaxe: {e}"
            )
            return False
        
        # Verificar estrutura
        if 'customModes' not in dados:
            self.log_resultado(
                "Estrutura customModes", 
                False, 
                "Chave 'customModes' não encontrada"
            )
            return False
        
        self.log_resultado(
            "Estrutura customModes", 
            True, 
            f"Encontrados {len(dados['customModes'])} modo(s)"
        )
        
        # Verificar modo Classificador_Trading
        modo_encontrado = None
        for modo in dados['customModes']:
            if modo.get('slug') == 'classificador-trading' or 'Classificador' in modo.get('name', ''):
                modo_encontrado = modo
                break
        
        if not modo_encontrado:
            self.log_resultado(
                "Modo Classificador_Trading", 
                False, 
                "Modo não encontrado nos customModes"
            )
            return False
        
        self.log_resultado(
            "Modo Classificador_Trading", 
            True, 
            f"Modo '{modo_encontrado.get('name')}' encontrado"
        )
        
        return self.verificar_propriedades_modo(modo_encontrado)
    
    def verificar_propriedades_modo(self, modo):
        """Verifica propriedades específicas do modo"""
        print("\n🎯 VERIFICANDO PROPRIEDADES DO MODO")
        print("=" * 50)
        
        propriedades_obrigatorias = ['slug', 'name', 'roleDefinition', 'groups']
        propriedades_opcionais = ['description', 'whenToUse', 'customInstructions', 'apiConfiguration']
        
        # Verificar propriedades obrigatórias
        for prop in propriedades_obrigatorias:
            if prop in modo and modo[prop]:
                self.log_resultado(
                    f"Propriedade {prop}", 
                    True, 
                    f"Presente: {str(modo[prop])[:50]}..."
                )
            else:
                self.log_resultado(
                    f"Propriedade {prop}", 
                    False, 
                    "Ausente ou vazia"
                )
        
        # Verificar propriedades opcionais
        for prop in propriedades_opcionais:
            if prop in modo and modo[prop]:
                self.log_resultado(
                    f"Propriedade {prop}", 
                    True, 
                    "Presente e configurada"
                )
            else:
                self.log_resultado(
                    f"Propriedade {prop}", 
                    False, 
                    "Ausente (opcional)"
                )
        
        # Verificar grupos MCP
        grupos = modo.get('groups', [])
        if 'mcp' in grupos:
            self.log_resultado(
                "Suporte MCP", 
                True, 
                "Grupo 'mcp' incluído"
            )
        else:
            self.log_resultado(
                "Suporte MCP", 
                False, 
                "Grupo 'mcp' não encontrado"
            )
        
        # Verificar configuração API
        api_config = modo.get('apiConfiguration', {})
        if api_config.get('model') == 'qwen/qwen3-coder':
            self.log_resultado(
                "Modelo Qwen3-Coder", 
                True, 
                f"Configurado: {api_config['model']}"
            )
        else:
            self.log_resultado(
                "Modelo Qwen3-Coder", 
                False, 
                f"Modelo atual: {api_config.get('model', 'não definido')}"
            )
        
        # Verificar comandos MCP nas instruções
        instrucoes = modo.get('customInstructions', '')
        comandos_mcp = ['PROCESSAR_ARQUIVO', 'PROCESSAR_LOTE', 'VALIDAR_FTMO', 'GERAR_METADATA']
        comandos_encontrados = [cmd for cmd in comandos_mcp if cmd in instrucoes]
        
        if comandos_encontrados:
            self.log_resultado(
                "Comandos MCP", 
                True, 
                f"Encontrados: {', '.join(comandos_encontrados)}"
            )
        else:
            self.log_resultado(
                "Comandos MCP", 
                False, 
                "Nenhum comando MCP encontrado nas instruções"
            )
        
        return True
    
    def verificar_configuracao_mcp(self):
        """Verifica configuração MCP"""
        print("\n🔌 VERIFICANDO CONFIGURAÇÃO MCP")
        print("=" * 50)
        
        if not self.arquivo_mcp.exists():
            self.log_resultado(
                "Arquivo MCP", 
                False, 
                "Arquivo .kilocode/mcp.json não encontrado"
            )
            return False
        
        try:
            with open(self.arquivo_mcp, 'r', encoding='utf-8') as f:
                config_mcp = json.load(f)
            
            self.log_resultado(
                "Configuração MCP", 
                True, 
                "Arquivo mcp.json válido"
            )
            
            # Verificar servidores
            servidores = config_mcp.get('mcpServers', {})
            servidores_esperados = [
                'file_analyzer', 'code_classifier', 'ftmo_validator', 
                'metadata_generator', 'batch_processor'
            ]
            
            servidores_encontrados = [s for s in servidores_esperados if s in servidores]
            
            if len(servidores_encontrados) == len(servidores_esperados):
                self.log_resultado(
                    "Servidores MCP", 
                    True, 
                    f"Todos os {len(servidores_esperados)} servidores configurados"
                )
            else:
                self.log_resultado(
                    "Servidores MCP", 
                    False, 
                    f"Apenas {len(servidores_encontrados)}/{len(servidores_esperados)} servidores encontrados"
                )
            
        except Exception as e:
            self.log_resultado(
                "Configuração MCP", 
                False, 
                f"Erro ao ler configuração: {e}"
            )
            return False
        
        return True
    
    def verificar_estrutura_projeto(self):
        """Verifica estrutura do projeto"""
        print("\n📁 VERIFICANDO ESTRUTURA DO PROJETO")
        print("=" * 50)
        
        diretorios_esperados = [
            'MCP_Integration',
            'MCP_Integration/servers',
            '.kilocode'
        ]
        
        for diretorio in diretorios_esperados:
            caminho = self.projeto_root / diretorio
            if caminho.exists():
                self.log_resultado(
                    f"Diretório {diretorio}", 
                    True, 
                    "Presente"
                )
            else:
                self.log_resultado(
                    f"Diretório {diretorio}", 
                    False, 
                    "Ausente"
                )
        
        # Verificar arquivos MCP
        arquivos_mcp = [
            'MCP_Integration/servers/mcp_file_analyzer.py',
            'MCP_Integration/servers/mcp_code_classifier.py',
            'MCP_Integration/servers/mcp_ftmo_validator.py',
            'MCP_Integration/servers/mcp_metadata_generator.py',
            'MCP_Integration/servers/mcp_batch_processor.py'
        ]
        
        for arquivo in arquivos_mcp:
            caminho = self.projeto_root / arquivo
            if caminho.exists():
                self.log_resultado(
                    f"Servidor {Path(arquivo).stem}", 
                    True, 
                    "Arquivo presente"
                )
            else:
                self.log_resultado(
                    f"Servidor {Path(arquivo).stem}", 
                    False, 
                    "Arquivo ausente"
                )
    
    def gerar_relatorio(self):
        """Gera relatório final"""
        print("\n" + "=" * 60)
        print("📊 RELATÓRIO FINAL DE VERIFICAÇÃO")
        print("=" * 60)
        
        total_testes = len(self.resultados)
        sucessos = sum(1 for r in self.resultados if r['status'])
        falhas = total_testes - sucessos
        
        print(f"\n📈 ESTATÍSTICAS:")
        print(f"   Total de testes: {total_testes}")
        print(f"   ✅ Sucessos: {sucessos}")
        print(f"   ❌ Falhas: {falhas}")
        print(f"   📊 Taxa de sucesso: {(sucessos/total_testes)*100:.1f}%")
        
        if falhas > 0:
            print(f"\n❌ PROBLEMAS ENCONTRADOS:")
            for resultado in self.resultados:
                if not resultado['status']:
                    print(f"   • {resultado['teste']}: {resultado['detalhes']}")
        
        print(f"\n🎯 STATUS GERAL:")
        if falhas == 0:
            print("   🎉 PERFEITO! Todas as verificações passaram.")
            print("   ✅ O Classificador_Trading está pronto para uso no Kilocode.")
        elif falhas <= 3:
            print("   ⚠️  QUASE LÁ! Alguns ajustes menores necessários.")
            print("   🔧 Corrija os problemas listados acima.")
        else:
            print("   🚨 ATENÇÃO! Vários problemas encontrados.")
            print("   🛠️  Revise a configuração completamente.")
        
        # Salvar relatório
        # Salvar relatório no diretório MCP_Integration atual
        relatorio_arquivo = self.projeto_root / 'MCP_Integration' / 'relatorio_verificacao.json'
        relatorio_data = {
            'timestamp': datetime.now().isoformat(),
            'total_testes': total_testes,
            'sucessos': sucessos,
            'falhas': falhas,
            'taxa_sucesso': (sucessos/total_testes)*100,
            'resultados': self.resultados
        }
        
        try:
            with open(relatorio_arquivo, 'w', encoding='utf-8') as f:
                json.dump(relatorio_data, f, indent=2, ensure_ascii=False)
            print(f"\n💾 Relatório salvo em: {relatorio_arquivo}")
        except Exception as e:
            print(f"\n⚠️  Erro ao salvar relatório: {e}")
    
    def executar_verificacao(self):
        """Executa verificação completa"""
        print("🚀 INICIANDO VERIFICAÇÃO DE IMPORTAÇÃO")
        print("=" * 60)
        print(f"📁 Projeto: {self.projeto_root}")
        print(f"⏰ Data/Hora: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
        
        # Executar verificações
        self.verificar_arquivo_modos()
        self.verificar_configuracao_mcp()
        self.verificar_estrutura_projeto()
        
        # Gerar relatório
        self.gerar_relatorio()

def main():
    """Função principal"""
    try:
        verificador = VerificadorImportacao()
        verificador.executar_verificacao()
        
    except KeyboardInterrupt:
        print("\n⚠️  Verificação interrompida pelo usuário.")
        sys.exit(1)
    except Exception as e:
        print(f"\n🚨 Erro inesperado: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()