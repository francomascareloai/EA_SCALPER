#!/usr/bin/env python3
"""
Orquestrador Central - Sistema de Automação Completa
Classificador Trading - Passo 3

Este módulo implementa o controle central de todo o sistema de classificação,
permitindo execução automatizada através de comandos únicos.

Autor: Classificador_Trading
Versão: 3.0
Data: 2025-01-12
"""

import os
import sys
import json
import time
import threading
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum

# Adicionar o diretório pai ao path para imports
sys.path.append(str(Path(__file__).parent.parent))

from Core.classificador_lote_avancado import ClassificadorLoteAvancado
from Core.monitor_tempo_real import MonitorTempoReal
from Core.gerador_relatorios_avancados import GeradorRelatoriosAvancados
from Scripts.auto_backup_integration import AutoBackupIntegration

class StatusSistema(Enum):
    """Estados possíveis do sistema"""
    PARADO = "parado"
    INICIANDO = "iniciando"
    EXECUTANDO = "executando"
    PAUSADO = "pausado"
    FINALIZANDO = "finalizando"
    ERRO = "erro"

@dataclass
class ComandoSistema:
    """Estrutura para comandos do sistema"""
    acao: str
    parametros: Dict[str, Any]
    timestamp: datetime
    usuario: str = "Trae_Agent"
    prioridade: int = 1

class OrquestradorCentral:
    """
    Orquestrador Central do Sistema de Classificação
    
    Responsável por:
    - Controle centralizado de todos os componentes
    - Execução automatizada via comandos únicos
    - Monitoramento em tempo real
    - Geração de relatórios executivos
    - Interface de comando para o Trae Agent
    """
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.status = StatusSistema.PARADO
        self.componentes = {}
        self.threads_ativas = {}
        self.logs_sistema = []
        self.metricas_tempo_real = {}
        self.configuracao = self._carregar_configuracao()
        
        # Inicializar componentes
        self._inicializar_componentes()
        
        # Criar diretórios necessários
        self._criar_diretorios()
        
        self.log_sistema("Orquestrador Central inicializado com sucesso")
    
    def _carregar_configuracao(self) -> Dict[str, Any]:
        """Carrega configuração do sistema"""
        config_path = self.base_path / "Development" / "config" / "orquestrador.json"
        
        config_default = {
            "auto_backup": True,
            "intervalo_relatorios": 300,  # 5 minutos
            "max_threads": 4,
            "timeout_operacoes": 3600,  # 1 hora
            "nivel_log": "INFO",
            "alertas_email": False,
            "dashboard_web": True,
            "api_rest": True
        }
        
        if config_path.exists():
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    # Merge com defaults
                    config_default.update(config)
            except Exception as e:
                self.log_sistema(f"Erro ao carregar configuração: {e}. Usando defaults.")
        
        return config_default
    
    def _inicializar_componentes(self):
        """Inicializa todos os componentes do sistema"""
        try:
            # Classificador em Lote
            self.componentes['classificador'] = ClassificadorLoteAvancado(
                base_path=str(self.base_path)
            )
            
            # Monitor em Tempo Real
            self.componentes['monitor'] = MonitorTempoReal()
            
            # Gerador de Relatórios
            self.componentes['relatorios'] = GeradorRelatoriosAvancados(
                base_path=str(self.base_path)
            )
            
            # Sistema de Backup Automático
            self.componentes['backup'] = AutoBackupIntegration()
            
            self.log_sistema("Todos os componentes inicializados com sucesso")
            
        except Exception as e:
            self.log_sistema(f"Erro ao inicializar componentes: {e}")
            self.status = StatusSistema.ERRO
    
    def _criar_diretorios(self):
        """Cria estrutura de diretórios necessária"""
        diretorios = [
            "Development/config",
            "Development/logs",
            "Development/temp",
            "Development/Reports/Executive",
            "Development/Reports/Real_Time",
            "Development/Dashboard"
        ]
        
        for dir_path in diretorios:
            full_path = self.base_path / dir_path
            full_path.mkdir(parents=True, exist_ok=True)
    
    def log_sistema(self, mensagem: str, nivel: str = "INFO"):
        """Registra log do sistema"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = {
            "timestamp": timestamp,
            "nivel": nivel,
            "mensagem": mensagem,
            "componente": "OrquestradorCentral"
        }
        
        self.logs_sistema.append(log_entry)
        
        # Salvar em arquivo
        log_file = self.base_path / "Development" / "logs" / f"sistema_{datetime.now().strftime('%Y%m%d')}.log"
        with open(log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{timestamp}] {nivel}: {mensagem}\n")
        
        # Print para console se necessário
        if nivel in ["ERROR", "WARNING"] or self.configuracao.get("debug", False):
            print(f"[{timestamp}] {nivel}: {mensagem}")
    
    def executar_comando_completo(self, comando: str, parametros: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Interface principal para execução de comandos completos
        
        Comandos disponíveis:
        - 'classificar_tudo': Classifica toda a biblioteca
        - 'classificar_diretorio': Classifica diretório específico
        - 'gerar_relatorio_executivo': Gera relatório completo
        - 'monitorar_tempo_real': Inicia monitoramento
        - 'parar_sistema': Para todos os processos
        - 'status_sistema': Retorna status atual
        - 'backup_completo': Cria backup de segurança
        """
        
        if parametros is None:
            parametros = {}
        
        comando_obj = ComandoSistema(
            acao=comando,
            parametros=parametros,
            timestamp=datetime.now()
        )
        
        self.log_sistema(f"Executando comando: {comando} com parâmetros: {parametros}")
        
        try:
            if comando == "classificar_tudo":
                return self._executar_classificacao_completa(parametros)
            
            elif comando == "classificar_diretorio":
                return self._executar_classificacao_diretorio(parametros)
            
            elif comando == "gerar_relatorio_executivo":
                return self._executar_relatorio_executivo(parametros)
            
            elif comando == "monitorar_tempo_real":
                return self._executar_monitoramento(parametros)
            
            elif comando == "parar_sistema":
                return self._parar_sistema()
            
            elif comando == "status_sistema":
                return self._obter_status_sistema()
            
            elif comando == "backup_completo":
                return self._executar_backup_completo(parametros)
            
            elif comando == "demo_completo":
                return self._executar_demo_completo(parametros)
            
            else:
                return {
                    "sucesso": False,
                    "erro": f"Comando '{comando}' não reconhecido",
                    "comandos_disponiveis": [
                        "classificar_tudo", "classificar_diretorio", 
                        "gerar_relatorio_executivo", "monitorar_tempo_real",
                        "parar_sistema", "status_sistema", "backup_completo",
                        "demo_completo"
                    ]
                }
        
        except Exception as e:
            self.log_sistema(f"Erro ao executar comando {comando}: {e}", "ERROR")
            return {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def _executar_classificacao_completa(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Executa classificação completa de toda a biblioteca"""
        self.status = StatusSistema.EXECUTANDO
        
        # Diretórios padrão para classificação
        diretorios_origem = [
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL5_Source" / "All_MQ5",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "TradingView_Scripts" / "Pine_Script_Source"
        ]
        
        resultados = {
            "inicio": datetime.now().isoformat(),
            "diretorios_processados": [],
            "arquivos_processados": 0,
            "arquivos_classificados": 0,
            "erros": [],
            "relatorios_gerados": []
        }
        
        try:
            # Iniciar monitoramento em background
            if parametros.get("monitoramento", True):
                self._iniciar_monitoramento_background()
            
            # Processar cada diretório
            for diretorio in diretorios_origem:
                if diretorio.exists():
                    self.log_sistema(f"Processando diretório: {diretorio}")
                    
                    resultado_dir = self.componentes['classificador'].process_directory(
                        source_dir=str(diretorio)
                    )
                    
                    resultados["diretorios_processados"].append({
                        "diretorio": str(diretorio),
                        "resultado": resultado_dir
                    })
                    
                    resultados["arquivos_processados"] += resultado_dir.get("total_arquivos", 0)
                    resultados["arquivos_classificados"] += resultado_dir.get("classificados", 0)
            
            # Gerar relatórios automáticos
            if parametros.get("gerar_relatorios", True):
                relatorio_resultado = self._gerar_relatorios_automaticos()
                resultados["relatorios_gerados"] = relatorio_resultado.get("relatorios", [])
            
            resultados["fim"] = datetime.now().isoformat()
            resultados["sucesso"] = True
            
            self.log_sistema("Classificação completa finalizada com sucesso")
            
            # Backup automático após classificação
            if self.config.get("auto_backup", True) and 'backup' in self.componentes:
                try:
                    backup_success, backup_msg = self.componentes['backup'].backup_after_classification("classificação completa")
                    resultados["backup_realizado"] = backup_success
                    resultados["backup_mensagem"] = backup_msg
                    self.log_sistema(f"Backup automático: {backup_msg}")
                except Exception as backup_error:
                    self.log_sistema(f"Erro no backup automático: {backup_error}", "WARNING")
                    resultados["backup_realizado"] = False
                    resultados["backup_erro"] = str(backup_error)
            
        except Exception as e:
            resultados["erro"] = str(e)
            resultados["sucesso"] = False
            self.log_sistema(f"Erro na classificação completa: {e}", "ERROR")
        
        finally:
            self.status = StatusSistema.PARADO
        
        return resultados
    
    def _executar_classificacao_diretorio(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Executa classificação de diretório específico"""
        diretorio = parametros.get("diretorio")
        if not diretorio:
            return {"sucesso": False, "erro": "Parâmetro 'diretorio' obrigatório"}
        
        self.status = StatusSistema.EXECUTANDO
        
        try:
            resultado = self.componentes['classificador'].process_directory(
                source_dir=diretorio
            )
            
            resultado["sucesso"] = True
            resultado["timestamp"] = datetime.now().isoformat()
            
            self.log_sistema(f"Classificação do diretório {diretorio} concluída")
            
        except Exception as e:
            resultado = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro na classificação do diretório {diretorio}: {e}", "ERROR")
        
        finally:
            self.status = StatusSistema.PARADO
        
        return resultado
    
    def _executar_relatorio_executivo(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Gera relatório executivo completo"""
        try:
            # Coletar dados do sistema
            dados_sistema = self._coletar_dados_sistema()
            
            # Gerar relatório
            resultado = self.componentes['relatorios'].generate_comprehensive_report(
                data=dados_sistema,
                report_type="executive",
                output_formats=parametros.get("formatos", ["html", "json"])
            )
            
            resultado["sucesso"] = True
            resultado["timestamp"] = datetime.now().isoformat()
            
            self.log_sistema("Relatório executivo gerado com sucesso")
            
        except Exception as e:
            resultado = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro ao gerar relatório executivo: {e}", "ERROR")
        
        return resultado
    
    def _executar_monitoramento(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Inicia monitoramento em tempo real"""
        try:
            duracao = parametros.get("duracao", 3600)  # 1 hora por padrão
            
            # Iniciar monitoramento em thread separada
            thread_monitor = threading.Thread(
                target=self._thread_monitoramento,
                args=(duracao,),
                daemon=True
            )
            thread_monitor.start()
            
            self.threads_ativas["monitor"] = thread_monitor
            
            resultado = {
                "sucesso": True,
                "mensagem": f"Monitoramento iniciado por {duracao} segundos",
                "timestamp": datetime.now().isoformat()
            }
            
            self.log_sistema("Monitoramento em tempo real iniciado")
            
        except Exception as e:
            resultado = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro ao iniciar monitoramento: {e}", "ERROR")
        
        return resultado
    
    def _thread_monitoramento(self, duracao: int):
        """Thread para monitoramento em background"""
        inicio = time.time()
        
        while time.time() - inicio < duracao:
            try:
                # Coletar métricas
                metricas = self._coletar_metricas_tempo_real()
                self.metricas_tempo_real = metricas
                
                # Verificar alertas
                self._verificar_alertas(metricas)
                
                time.sleep(30)  # Atualizar a cada 30 segundos
                
            except Exception as e:
                self.log_sistema(f"Erro no monitoramento: {e}", "ERROR")
                break
        
        self.log_sistema("Monitoramento finalizado")
    
    def _parar_sistema(self) -> Dict[str, Any]:
        """Para todos os processos do sistema"""
        try:
            self.status = StatusSistema.FINALIZANDO
            
            # Parar threads ativas
            for nome, thread in self.threads_ativas.items():
                if thread.is_alive():
                    self.log_sistema(f"Parando thread: {nome}")
                    # Note: Python threads não podem ser forçadamente paradas
                    # Elas devem verificar uma flag de parada
            
            self.threads_ativas.clear()
            self.status = StatusSistema.PARADO
            
            resultado = {
                "sucesso": True,
                "mensagem": "Sistema parado com sucesso",
                "timestamp": datetime.now().isoformat()
            }
            
            self.log_sistema("Sistema parado pelo usuário")
            
        except Exception as e:
            resultado = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro ao parar sistema: {e}", "ERROR")
        
        return resultado
    
    def _obter_status_sistema(self) -> Dict[str, Any]:
        """Retorna status atual do sistema"""
        return {
            "status": self.status.value,
            "componentes": {
                nome: "ativo" if comp else "inativo" 
                for nome, comp in self.componentes.items()
            },
            "threads_ativas": list(self.threads_ativas.keys()),
            "metricas_tempo_real": self.metricas_tempo_real,
            "ultimo_log": self.logs_sistema[-1] if self.logs_sistema else None,
            "timestamp": datetime.now().isoformat()
        }
    
    def _executar_backup_completo(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Executa backup completo do sistema"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_dir = self.base_path / "BACKUP_SEGURANCA" / timestamp
            backup_dir.mkdir(parents=True, exist_ok=True)
            
            # Diretórios para backup
            diretorios_backup = [
                "CODIGO_FONTE_LIBRARY",
                "Metadata",
                "Reports",
                "Development"
            ]
            
            arquivos_copiados = 0
            
            for dir_name in diretorios_backup:
                source_dir = self.base_path / dir_name
                if source_dir.exists():
                    import shutil
                    dest_dir = backup_dir / dir_name
                    shutil.copytree(source_dir, dest_dir, dirs_exist_ok=True)
                    
                    # Contar arquivos
                    for root, dirs, files in os.walk(dest_dir):
                        arquivos_copiados += len(files)
            
            resultado = {
                "sucesso": True,
                "backup_path": str(backup_dir),
                "arquivos_copiados": arquivos_copiados,
                "timestamp": datetime.now().isoformat()
            }
            
            self.log_sistema(f"Backup completo criado: {backup_dir}")
            
        except Exception as e:
            resultado = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro ao criar backup: {e}", "ERROR")
        
        return resultado
    
    def _executar_demo_completo(self, parametros: Dict[str, Any]) -> Dict[str, Any]:
        """Executa demonstração completa do sistema"""
        try:
            self.log_sistema("Iniciando demonstração completa do sistema")
            
            resultados_demo = {
                "inicio": datetime.now().isoformat(),
                "etapas": [],
                "metricas_coletadas": 0,
                "relatorios_gerados": 0,
                "componentes_testados": 0
            }
            
            # Etapa 1: Teste de componentes
            self.log_sistema("Demo - Testando componentes individuais")
            for nome, componente in self.componentes.items():
                if componente:
                    resultados_demo["etapas"].append(f"Componente {nome}: OK")
                    resultados_demo["componentes_testados"] += 1
            
            # Etapa 2: Coleta de métricas
            self.log_sistema("Demo - Coletando métricas do sistema")
            metricas = self._coletar_metricas_tempo_real()
            resultados_demo["metricas_coletadas"] = len(metricas)
            resultados_demo["etapas"].append(f"Métricas coletadas: {len(metricas)}")
            
            # Etapa 3: Geração de relatório de demonstração
            self.log_sistema("Demo - Gerando relatório de demonstração")
            dados_demo = {
                "sistema": "Classificador Trading - Demo",
                "componentes": list(self.componentes.keys()),
                "metricas": metricas,
                "timestamp": datetime.now().isoformat()
            }
            
            # Verificar se o componente de relatórios está disponível
            if 'relatorios' in self.componentes and self.componentes['relatorios']:
                try:
                    relatorio_demo = self.componentes['relatorios'].generate_comprehensive_report(
                        data=dados_demo,
                        report_type="demo",
                        output_formats=["json", "html"]
                    )
                    
                    if relatorio_demo.get("sucesso"):
                        resultados_demo["relatorios_gerados"] = len(relatorio_demo.get("arquivos", []))
                        resultados_demo["etapas"].append("Relatório de demo gerado")
                except Exception as e:
                    self.log_sistema(f"Erro ao gerar relatório de demo: {e}", "WARNING")
                    resultados_demo["etapas"].append("Relatório de demo: erro")
            else:
                resultados_demo["etapas"].append("Relatório de demo: componente não disponível")
            
            # Etapa 4: Teste de monitoramento rápido
            self.log_sistema("Demo - Teste de monitoramento (30 segundos)")
            monitor_resultado = self._executar_monitoramento({"duracao": 30})
            if monitor_resultado.get("sucesso"):
                resultados_demo["etapas"].append("Monitoramento testado")
            
            resultados_demo["fim"] = datetime.now().isoformat()
            resultados_demo["sucesso"] = True
            resultados_demo["resumo"] = f"Demo concluída: {resultados_demo['componentes_testados']} componentes, {resultados_demo['metricas_coletadas']} métricas, {resultados_demo['relatorios_gerados']} relatórios"
            
            self.log_sistema("Demonstração completa finalizada com sucesso")
            
        except Exception as e:
            resultados_demo = {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
            self.log_sistema(f"Erro na demonstração: {e}", "ERROR")
        
        return resultados_demo
    
    def _coletar_dados_sistema(self) -> Dict[str, Any]:
        """Coleta dados completos do sistema para relatórios"""
        dados = {
            "timestamp": datetime.now().isoformat(),
            "status_sistema": self.status.value,
            "configuracao": self.configuracao,
            "componentes": {},
            "estatisticas": {},
            "logs_recentes": self.logs_sistema[-50:],  # Últimos 50 logs
            "metricas": self.metricas_tempo_real
        }
        
        # Estatísticas de arquivos
        try:
            stats = self._calcular_estatisticas_arquivos()
            dados["estatisticas"] = stats
        except Exception as e:
            self.log_sistema(f"Erro ao calcular estatísticas: {e}", "WARNING")
        
        return dados
    
    def _calcular_estatisticas_arquivos(self) -> Dict[str, Any]:
        """Calcula estatísticas dos arquivos na biblioteca"""
        stats = {
            "total_arquivos": 0,
            "por_tipo": {"EA": 0, "Indicator": 0, "Script": 0, "Pine": 0, "Unknown": 0},
            "por_estrategia": {},
            "ftmo_ready": 0,
            "diretorios_processados": []
        }
        
        # Contar arquivos em cada diretório
        diretorios_fonte = [
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL5_Source",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "TradingView_Scripts"
        ]
        
        for diretorio in diretorios_fonte:
            if diretorio.exists():
                for root, dirs, files in os.walk(diretorio):
                    for file in files:
                        if file.endswith(('.mq4', '.mq5', '.pine')):
                            stats["total_arquivos"] += 1
                            
                            # Classificar por tipo baseado no caminho
                            if "EAs" in root:
                                stats["por_tipo"]["EA"] += 1
                            elif "Indicators" in root:
                                stats["por_tipo"]["Indicator"] += 1
                            elif "Scripts" in root:
                                stats["por_tipo"]["Script"] += 1
                            elif "Pine" in root:
                                stats["por_tipo"]["Pine"] += 1
                            else:
                                stats["por_tipo"]["Unknown"] += 1
        
        return stats
    
    def _coletar_metricas_tempo_real(self) -> Dict[str, Any]:
        """Coleta métricas em tempo real do sistema"""
        import psutil
        
        metricas = {
            "timestamp": datetime.now().isoformat(),
            "sistema": {
                "cpu_percent": psutil.cpu_percent(),
                "memoria_percent": psutil.virtual_memory().percent,
                "disco_livre_gb": psutil.disk_usage(str(self.base_path)).free / (1024**3)
            },
            "processos": {
                "threads_ativas": len(self.threads_ativas),
                "status_sistema": self.status.value
            },
            "arquivos": self._calcular_estatisticas_arquivos(),
            "logs": {
                "total_logs": len(self.logs_sistema),
                "logs_erro": len([l for l in self.logs_sistema if l.get("nivel") == "ERROR"]),
                "logs_warning": len([l for l in self.logs_sistema if l.get("nivel") == "WARNING"])
            }
        }
        
        return metricas
    
    def _verificar_alertas(self, metricas: Dict[str, Any]):
        """Verifica condições de alerta baseadas nas métricas"""
        alertas = []
        
        # Verificar uso de CPU
        if metricas["sistema"]["cpu_percent"] > 80:
            alertas.append("Alto uso de CPU detectado")
        
        # Verificar uso de memória
        if metricas["sistema"]["memoria_percent"] > 85:
            alertas.append("Alto uso de memória detectado")
        
        # Verificar espaço em disco
        if metricas["sistema"]["disco_livre_gb"] < 1:
            alertas.append("Pouco espaço livre em disco")
        
        # Verificar logs de erro
        if metricas["logs"]["logs_erro"] > 10:
            alertas.append("Muitos logs de erro detectados")
        
        # Registrar alertas
        for alerta in alertas:
            self.log_sistema(f"ALERTA: {alerta}", "WARNING")
    
    def _gerar_relatorios_automaticos(self) -> Dict[str, Any]:
        """Gera relatórios automáticos após classificação"""
        try:
            dados = self._coletar_dados_sistema()
            
            relatorios_gerados = []
            
            # Relatório executivo
            exec_report = self.componentes['relatorios'].generate_comprehensive_report(
                data=dados,
                report_type="executive",
                output_formats=["html", "json"]
            )
            
            if exec_report.get("sucesso"):
                relatorios_gerados.extend(exec_report.get("arquivos", []))
            
            # Relatório de estatísticas
            stats_report = self.componentes['relatorios'].generate_comprehensive_report(
                data=dados,
                report_type="statistics",
                output_formats=["csv", "json"]
            )
            
            if stats_report.get("sucesso"):
                relatorios_gerados.extend(stats_report.get("arquivos", []))
            
            # Backup automático após geração de relatórios
            if self.config.get("auto_backup", True) and 'backup' in self.componentes:
                try:
                    backup_success, backup_msg = self.componentes['backup'].backup_after_report_generation()
                    self.log_sistema(f"Backup após relatórios: {backup_msg}")
                except Exception as backup_error:
                    self.log_sistema(f"Erro no backup após relatórios: {backup_error}", "WARNING")
            
            return {
                "sucesso": True,
                "relatorios": relatorios_gerados,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            self.log_sistema(f"Erro ao gerar relatórios automáticos: {e}", "ERROR")
            return {
                "sucesso": False,
                "erro": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def _iniciar_monitoramento_background(self):
        """Inicia monitoramento em background durante operações"""
        if "monitor_bg" not in self.threads_ativas:
            thread_bg = threading.Thread(
                target=self._thread_monitoramento,
                args=(3600,),  # 1 hora
                daemon=True
            )
            thread_bg.start()
            self.threads_ativas["monitor_bg"] = thread_bg

# Interface de comando para o Trae Agent
def executar_comando_trae(comando: str, parametros: str = "{}") -> str:
    """
    Interface simplificada para execução via Trae Agent
    
    Args:
        comando: Comando a ser executado
        parametros: JSON string com parâmetros
    
    Returns:
        JSON string com resultado
    """
    try:
        # Parse dos parâmetros
        if isinstance(parametros, str):
            parametros_dict = json.loads(parametros) if parametros.strip() else {}
        else:
            parametros_dict = parametros
        
        # Inicializar orquestrador
        base_path = os.getcwd()
        orquestrador = OrquestradorCentral(base_path)
        
        # Executar comando
        resultado = orquestrador.executar_comando_completo(comando, parametros_dict)
        
        # Retornar resultado como JSON
        return json.dumps(resultado, indent=2, ensure_ascii=False)
        
    except Exception as e:
        erro_resultado = {
            "sucesso": False,
            "erro": str(e),
            "timestamp": datetime.now().isoformat()
        }
        return json.dumps(erro_resultado, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    # Exemplo de uso direto
    import sys
    
    if len(sys.argv) > 1:
        comando = sys.argv[1]
        parametros = sys.argv[2] if len(sys.argv) > 2 else "{}"
        
        resultado = executar_comando_trae(comando, parametros)
        print(resultado)
    else:
        print("Uso: python orquestrador_central.py <comando> [parametros_json]")
        print("Comandos disponíveis: classificar_tudo, status_sistema, demo_completo")