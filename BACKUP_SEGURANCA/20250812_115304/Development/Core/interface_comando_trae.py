#!/usr/bin/env python3
"""
Interface de Comando para Trae Agent
Classificador Trading - Sistema de Controle Unificado

Este módulo fornece uma interface simplificada para controle total
do sistema de classificação através do Trae Agent.

Autor: Classificador_Trading
Versão: 3.0
Data: 2025-01-12
"""

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List

# Adicionar o diretório pai ao path
sys.path.append(str(Path(__file__).parent.parent))

from Core.orquestrador_central import OrquestradorCentral, executar_comando_trae

class InterfaceComandoTrae:
    """
    Interface de Comando Unificada para Trae Agent
    
    Permite controle total do sistema através de comandos simples:
    - Classificação automática completa
    - Monitoramento em tempo real
    - Geração de relatórios executivos
    - Backup e manutenção
    - Status e diagnósticos
    """
    
    def __init__(self):
        self.base_path = Path.cwd()
        self.orquestrador = None
        self.comandos_disponiveis = {
            "start": "Inicia o sistema completo de classificação",
            "classify": "Classifica toda a biblioteca de códigos",
            "classify-dir": "Classifica diretório específico",
            "monitor": "Inicia monitoramento em tempo real",
            "report": "Gera relatório executivo completo",
            "status": "Mostra status atual do sistema",
            "backup": "Cria backup completo de segurança",
            "demo": "Executa demonstração completa",
            "stop": "Para todos os processos",
            "help": "Mostra ajuda detalhada"
        }
    
    def executar_comando_principal(self, comando: str, args: List[str] = None) -> Dict[str, Any]:
        """
        Executa comando principal do sistema
        
        Args:
            comando: Comando a ser executado
            args: Argumentos adicionais
        
        Returns:
            Resultado da execução
        """
        if args is None:
            args = []
        
        try:
            # Inicializar orquestrador se necessário
            if not self.orquestrador:
                self.orquestrador = OrquestradorCentral(str(self.base_path))
            
            # Mapear comandos para ações do orquestrador
            if comando == "start":
                return self._comando_start(args)
            
            elif comando == "classify":
                return self._comando_classify(args)
            
            elif comando == "classify-dir":
                return self._comando_classify_dir(args)
            
            elif comando == "monitor":
                return self._comando_monitor(args)
            
            elif comando == "report":
                return self._comando_report(args)
            
            elif comando == "status":
                return self._comando_status(args)
            
            elif comando == "backup":
                return self._comando_backup(args)
            
            elif comando == "demo":
                return self._comando_demo(args)
            
            elif comando == "stop":
                return self._comando_stop(args)
            
            elif comando == "help":
                return self._comando_help(args)
            
            else:
                return {
                    "sucesso": False,
                    "erro": f"Comando '{comando}' não reconhecido",
                    "comandos_disponiveis": list(self.comandos_disponiveis.keys()),
                    "ajuda": "Use 'help' para ver comandos disponíveis"
                }
        
        except Exception as e:
            return {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def _comando_start(self, args: List[str]) -> Dict[str, Any]:
        """Comando START - Inicia sistema completo"""
        parametros = {
            "monitoramento": True,
            "gerar_relatorios": True,
            "backup_automatico": True
        }
        
        # Processar argumentos
        if "--no-monitor" in args:
            parametros["monitoramento"] = False
        if "--no-reports" in args:
            parametros["gerar_relatorios"] = False
        if "--no-backup" in args:
            parametros["backup_automatico"] = False
        
        resultado = self.orquestrador.executar_comando_completo(
            "classificar_tudo", parametros
        )
        
        # Adicionar informações de início
        resultado["comando"] = "start"
        resultado["descricao"] = "Sistema completo de classificação iniciado"
        
        return resultado
    
    def _comando_classify(self, args: List[str]) -> Dict[str, Any]:
        """Comando CLASSIFY - Classifica toda a biblioteca"""
        parametros = {
            "config_classificacao": {
                "nivel_detalhamento": "completo",
                "gerar_snippets": True,
                "atualizar_manifests": True
            }
        }
        
        # Processar argumentos
        if "--quick" in args:
            parametros["config_classificacao"]["nivel_detalhamento"] = "rapido"
            parametros["config_classificacao"]["gerar_snippets"] = False
        
        if "--no-snippets" in args:
            parametros["config_classificacao"]["gerar_snippets"] = False
        
        resultado = self.orquestrador.executar_comando_completo(
            "classificar_tudo", parametros
        )
        
        resultado["comando"] = "classify"
        resultado["descricao"] = "Classificação completa da biblioteca"
        
        return resultado
    
    def _comando_classify_dir(self, args: List[str]) -> Dict[str, Any]:
        """Comando CLASSIFY-DIR - Classifica diretório específico"""
        if not args:
            return {
                "sucesso": False,
                "erro": "Diretório não especificado",
                "uso": "classify-dir <caminho_do_diretorio>"
            }
        
        diretorio = args[0]
        parametros = {
            "diretorio": diretorio,
            "config": {
                "nivel_detalhamento": "completo"
            }
        }
        
        resultado = self.orquestrador.executar_comando_completo(
            "classificar_diretorio", parametros
        )
        
        resultado["comando"] = "classify-dir"
        resultado["descricao"] = f"Classificação do diretório: {diretorio}"
        
        return resultado
    
    def _comando_monitor(self, args: List[str]) -> Dict[str, Any]:
        """Comando MONITOR - Inicia monitoramento"""
        duracao = 3600  # 1 hora por padrão
        
        # Processar argumentos
        for i, arg in enumerate(args):
            if arg == "--duration" and i + 1 < len(args):
                try:
                    duracao = int(args[i + 1])
                except ValueError:
                    return {
                        "sucesso": False,
                        "erro": "Duração deve ser um número em segundos"
                    }
        
        parametros = {"duracao": duracao}
        
        resultado = self.orquestrador.executar_comando_completo(
            "monitorar_tempo_real", parametros
        )
        
        resultado["comando"] = "monitor"
        resultado["descricao"] = f"Monitoramento iniciado por {duracao} segundos"
        
        return resultado
    
    def _comando_report(self, args: List[str]) -> Dict[str, Any]:
        """Comando REPORT - Gera relatório executivo"""
        formatos = ["html", "json"]
        
        # Processar argumentos
        if "--format" in args:
            idx = args.index("--format")
            if idx + 1 < len(args):
                formatos = args[idx + 1].split(",")
        
        if "--all-formats" in args:
            formatos = ["html", "json", "csv", "pdf"]
        
        parametros = {"formatos": formatos}
        
        resultado = self.orquestrador.executar_comando_completo(
            "gerar_relatorio_executivo", parametros
        )
        
        resultado["comando"] = "report"
        resultado["descricao"] = f"Relatório executivo gerado em: {', '.join(formatos)}"
        
        return resultado
    
    def _comando_status(self, args: List[str]) -> Dict[str, Any]:
        """Comando STATUS - Mostra status do sistema"""
        resultado = self.orquestrador.executar_comando_completo("status_sistema")
        
        # Adicionar informações extras
        resultado["comando"] = "status"
        resultado["descricao"] = "Status atual do sistema"
        
        # Formatar informações para melhor visualização
        if resultado.get("sucesso", True):
            resultado["resumo_formatado"] = self._formatar_status(resultado)
        
        return resultado
    
    def _comando_backup(self, args: List[str]) -> Dict[str, Any]:
        """Comando BACKUP - Cria backup completo"""
        parametros = {}
        
        # Processar argumentos
        if "--compress" in args:
            parametros["comprimir"] = True
        
        resultado = self.orquestrador.executar_comando_completo(
            "backup_completo", parametros
        )
        
        resultado["comando"] = "backup"
        resultado["descricao"] = "Backup completo de segurança"
        
        return resultado
    
    def _comando_demo(self, args: List[str]) -> Dict[str, Any]:
        """Comando DEMO - Executa demonstração completa"""
        parametros = {}
        
        resultado = self.orquestrador.executar_comando_completo(
            "demo_completo", parametros
        )
        
        resultado["comando"] = "demo"
        resultado["descricao"] = "Demonstração completa do sistema"
        
        return resultado
    
    def _comando_stop(self, args: List[str]) -> Dict[str, Any]:
        """Comando STOP - Para todos os processos"""
        resultado = self.orquestrador.executar_comando_completo("parar_sistema")
        
        resultado["comando"] = "stop"
        resultado["descricao"] = "Sistema parado"
        
        return resultado
    
    def _comando_help(self, args: List[str]) -> Dict[str, Any]:
        """Comando HELP - Mostra ajuda"""
        comando_especifico = args[0] if args else None
        
        if comando_especifico:
            return self._ajuda_comando_especifico(comando_especifico)
        else:
            return self._ajuda_geral()
    
    def _ajuda_geral(self) -> Dict[str, Any]:
        """Ajuda geral do sistema"""
        ajuda = {
            "sucesso": True,
            "comando": "help",
            "titulo": "Sistema de Classificação Trading - Comandos Disponíveis",
            "comandos": {},
            "exemplos": [
                "python interface_comando_trae.py start",
                "python interface_comando_trae.py classify --quick",
                "python interface_comando_trae.py monitor --duration 1800",
                "python interface_comando_trae.py report --all-formats",
                "python interface_comando_trae.py status"
            ],
            "uso_trae": {
                "descricao": "Para usar no Trae Agent, execute:",
                "comando": "python Development/Core/interface_comando_trae.py <comando> [argumentos]"
            }
        }
        
        # Adicionar descrição de cada comando
        for cmd, desc in self.comandos_disponiveis.items():
            ajuda["comandos"][cmd] = {
                "descricao": desc,
                "argumentos": self._obter_argumentos_comando(cmd)
            }
        
        return ajuda
    
    def _ajuda_comando_especifico(self, comando: str) -> Dict[str, Any]:
        """Ajuda para comando específico"""
        if comando not in self.comandos_disponiveis:
            return {
                "sucesso": False,
                "erro": f"Comando '{comando}' não encontrado",
                "comandos_disponiveis": list(self.comandos_disponiveis.keys())
            }
        
        ajuda_detalhada = {
            "start": {
                "descricao": "Inicia o sistema completo de classificação automatizada",
                "argumentos": ["--no-monitor", "--no-reports", "--no-backup"],
                "exemplo": "start --no-monitor",
                "detalhes": "Executa classificação completa com monitoramento e relatórios automáticos"
            },
            "classify": {
                "descricao": "Classifica toda a biblioteca de códigos de trading",
                "argumentos": ["--quick", "--no-snippets"],
                "exemplo": "classify --quick",
                "detalhes": "Processa todos os arquivos MQL4, MQL5 e Pine Script"
            },
            "monitor": {
                "descricao": "Inicia monitoramento em tempo real do sistema",
                "argumentos": ["--duration <segundos>"],
                "exemplo": "monitor --duration 1800",
                "detalhes": "Monitora métricas de sistema e performance"
            },
            "report": {
                "descricao": "Gera relatório executivo completo",
                "argumentos": ["--format <formatos>", "--all-formats"],
                "exemplo": "report --format html,json",
                "detalhes": "Cria relatórios em múltiplos formatos"
            }
        }
        
        return {
            "sucesso": True,
            "comando": comando,
            "ajuda": ajuda_detalhada.get(comando, {
                "descricao": self.comandos_disponiveis[comando],
                "argumentos": [],
                "exemplo": comando,
                "detalhes": "Comando básico sem argumentos especiais"
            })
        }
    
    def _obter_argumentos_comando(self, comando: str) -> List[str]:
        """Obtém argumentos disponíveis para um comando"""
        argumentos_por_comando = {
            "start": ["--no-monitor", "--no-reports", "--no-backup"],
            "classify": ["--quick", "--no-snippets"],
            "classify-dir": ["<diretorio>"],
            "monitor": ["--duration <segundos>"],
            "report": ["--format <formatos>", "--all-formats"],
            "backup": ["--compress"],
            "help": ["<comando>"]
        }
        
        return argumentos_por_comando.get(comando, [])
    
    def _formatar_status(self, status: Dict[str, Any]) -> str:
        """Formata status para visualização"""
        linhas = []
        linhas.append("=== STATUS DO SISTEMA ===")
        linhas.append(f"Status: {status.get('status', 'Desconhecido')}")
        
        # Componentes
        componentes = status.get('componentes', {})
        linhas.append("\nComponentes:")
        for nome, estado in componentes.items():
            linhas.append(f"  - {nome}: {estado}")
        
        # Threads ativas
        threads = status.get('threads_ativas', [])
        linhas.append(f"\nThreads ativas: {len(threads)}")
        for thread in threads:
            linhas.append(f"  - {thread}")
        
        # Métricas
        metricas = status.get('metricas_tempo_real', {})
        if metricas:
            sistema = metricas.get('sistema', {})
            linhas.append("\nMétricas do Sistema:")
            linhas.append(f"  - CPU: {sistema.get('cpu_percent', 0):.1f}%")
            linhas.append(f"  - Memória: {sistema.get('memoria_percent', 0):.1f}%")
            linhas.append(f"  - Disco livre: {sistema.get('disco_livre_gb', 0):.1f} GB")
        
        return "\n".join(linhas)

def main():
    """Função principal para execução via linha de comando"""
    parser = argparse.ArgumentParser(
        description="Interface de Comando para Sistema de Classificação Trading",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos de uso:
  python interface_comando_trae.py start
  python interface_comando_trae.py classify --quick
  python interface_comando_trae.py monitor --duration 1800
  python interface_comando_trae.py report --all-formats
  python interface_comando_trae.py status
  python interface_comando_trae.py help classify

Para uso no Trae Agent:
  Execute os comandos diretamente através do terminal do Trae
        """
    )
    
    parser.add_argument(
        "comando",
        choices=[
            "start", "classify", "classify-dir", "monitor", 
            "report", "status", "backup", "demo", "stop", "help"
        ],
        help="Comando a ser executado"
    )
    
    parser.add_argument(
        "args",
        nargs="*",
        help="Argumentos adicionais para o comando"
    )
    
    parser.add_argument(
        "--json",
        action="store_true",
        help="Saída em formato JSON"
    )
    
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Saída detalhada"
    )
    
    args = parser.parse_args()
    
    # Executar comando
    interface = InterfaceComandoTrae()
    resultado = interface.executar_comando_principal(args.comando, args.args)
    
    # Formatar saída
    if args.json:
        print(json.dumps(resultado, indent=2, ensure_ascii=False))
    else:
        # Saída formatada para humanos
        if resultado.get("sucesso", True):
            print(f"✅ {resultado.get('descricao', 'Comando executado com sucesso')}")
            
            if args.verbose and "resumo_formatado" in resultado:
                print("\n" + resultado["resumo_formatado"])
            
            # Mostrar informações relevantes
            if "arquivos_processados" in resultado:
                print(f"📁 Arquivos processados: {resultado['arquivos_processados']}")
            
            if "relatorios_gerados" in resultado:
                relatorios = resultado["relatorios_gerados"]
                if isinstance(relatorios, list):
                    print(f"📊 Relatórios gerados: {len(relatorios)}")
                else:
                    print(f"📊 Relatórios gerados: {relatorios}")
            
            if "backup_path" in resultado:
                print(f"💾 Backup criado em: {resultado['backup_path']}")
        
        else:
            print(f"❌ Erro: {resultado.get('erro', 'Erro desconhecido')}")
            
            if "ajuda" in resultado:
                print(f"💡 {resultado['ajuda']}")
    
    # Código de saída
    sys.exit(0 if resultado.get("sucesso", True) else 1)

if __name__ == "__main__":
    main()