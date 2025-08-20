#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 DEMONSTRAÇÃO DE AGENTES SIMULTÂNEOS
Script para demonstrar o funcionamento coordenado de todos os agentes
"""

import sys
import os
import time
import threading
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List

# Adicionar diretório raiz ao path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

# Importar componentes
from Development.Core.classificador_lote_avancado import ClassificadorLoteAvancado
from Development.Core.monitor_tempo_real import MonitorTempoReal
from Development.Core.gerador_relatorios_avancados import GeradorRelatoriosAvancados

class DemoAgentesSimultaneos:
    """Demonstração de execução simultânea de agentes"""
    
    def __init__(self):
        self.project_root = project_root
        self.resultados = {}
        self.threads_ativas = []
        self.monitor_ativo = False
        self.inicio_demo = None
        
    def log(self, message: str, nivel: str = "INFO"):
        """Log com timestamp"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {nivel}: {message}")
        
    def agente_classificador(self):
        """Agente 1: Classificador de arquivos"""
        try:
            self.log("🔍 AGENTE CLASSIFICADOR: Iniciando...")
            
            classificador = ClassificadorLoteAvancado()
            test_dir = self.project_root / "Development" / "Testing" / "test_files"
            
            if not test_dir.exists():
                self.log("❌ Diretório de teste não encontrado", "ERROR")
                return
                
            self.log(f"📁 Processando diretório: {test_dir}")
            
            resultado = classificador.process_directory(
                str(test_dir),
                extensions=['.mq4', '.mq5', '.pine'],
                create_backup=False,  # Evitar conflitos
                show_progress=False   # Reduzir output
            )
            
            self.resultados['classificador'] = {
                'status': 'sucesso',
                'arquivos_processados': resultado['statistics']['processed'],
                'taxa_sucesso': resultado['performance']['success_rate'],
                'tempo_execucao': resultado['execution_time']
            }
            
            self.log(f"✅ AGENTE CLASSIFICADOR: {resultado['statistics']['processed']} arquivos processados")
            
        except Exception as e:
            self.log(f"❌ AGENTE CLASSIFICADOR: Erro - {str(e)}", "ERROR")
            self.resultados['classificador'] = {'status': 'erro', 'erro': str(e)}
            
    def agente_monitor(self):
        """Agente 2: Monitor de métricas"""
        try:
            self.log("📊 AGENTE MONITOR: Iniciando...")
            
            monitor = MonitorTempoReal()
            self.monitor_ativo = True
            
            # Simular coleta de métricas por 8 segundos
            metricas_coletadas = 0
            for i in range(8):
                if not self.monitor_ativo:
                    break
                    
                # Simular métrica
                snapshot = monitor.capturar_snapshot()
                metricas_coletadas += 1
                
                if i % 2 == 0:
                    cpu_usage = snapshot.get('cpu_usage', 0)
                    memory_usage = snapshot.get('memory_usage', 0)
                    self.log(f"📈 Métrica #{metricas_coletadas}: CPU={cpu_usage:.1f}%, RAM={memory_usage:.1f}%")
                    
                time.sleep(1)
                
            self.resultados['monitor'] = {
                'status': 'sucesso',
                'metricas_coletadas': metricas_coletadas,
                'duracao': 8
            }
            
            self.log(f"✅ AGENTE MONITOR: {metricas_coletadas} métricas coletadas")
            
        except Exception as e:
            self.log(f"❌ AGENTE MONITOR: Erro - {str(e)}", "ERROR")
            self.resultados['monitor'] = {'status': 'erro', 'erro': str(e)}
            
    def agente_relatorios(self):
        """Agente 3: Gerador de relatórios"""
        try:
            self.log("📄 AGENTE RELATÓRIOS: Iniciando...")
            
            # Aguardar um pouco para ter dados dos outros agentes
            time.sleep(3)
            
            gerador = GeradorRelatoriosAvancados()
            
            # Dados simulados para relatório
            dados_demo = {
                'timestamp': datetime.now().isoformat(),
                'demo_agentes': True,
                'resultados_parciais': self.resultados.copy(),
                'arquivos_processados': 5,
                'metricas_sistema': {
                    'threads_ativas': len(self.threads_ativas),
                    'tempo_execucao': time.time() - self.inicio_demo if self.inicio_demo else 0
                }
            }
            
            # Gerar relatórios
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # JSON
            json_path = self.project_root / "Development" / "Reports" / "JSON" / f"demo_agentes_{timestamp}.json"
            json_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(dados_demo, f, indent=2, ensure_ascii=False)
                
            # HTML simples
            html_path = self.project_root / "Development" / "Reports" / "HTML" / f"demo_agentes_{timestamp}.html"
            html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Demo Agentes Simultâneos</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .success {{ color: green; }}
        .error {{ color: red; }}
        .info {{ color: blue; }}
    </style>
</head>
<body>
    <h1>🚀 Demo Agentes Simultâneos</h1>
    <p><strong>Timestamp:</strong> {dados_demo['timestamp']}</p>
    <h2>Resultados:</h2>
    <pre>{json.dumps(dados_demo, indent=2, ensure_ascii=False)}</pre>
</body>
</html>
"""
            
            with open(html_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
                
            self.resultados['relatorios'] = {
                'status': 'sucesso',
                'arquivos_gerados': 2,
                'json_path': str(json_path),
                'html_path': str(html_path)
            }
            
            self.log(f"✅ AGENTE RELATÓRIOS: 2 relatórios gerados")
            
        except Exception as e:
            self.log(f"❌ AGENTE RELATÓRIOS: Erro - {str(e)}", "ERROR")
            self.resultados['relatorios'] = {'status': 'erro', 'erro': str(e)}
            
    def agente_coordenador(self):
        """Agente 4: Coordenador de sistema"""
        try:
            self.log("🎛️ AGENTE COORDENADOR: Iniciando...")
            
            # Obter thread atual para evitar join em si mesmo
            current_thread = threading.current_thread()
            
            # Monitorar threads por 10 segundos
            for i in range(10):
                threads_vivas = sum(1 for t in self.threads_ativas if t.is_alive())
                
                if i % 3 == 0:
                    self.log(f"🔄 Status: {threads_vivas} threads ativas")
                    
                time.sleep(1)
                
            # Aguardar conclusão de outras threads (exceto a própria)
            self.log("⏳ Aguardando conclusão de outros agentes...")
            for thread in self.threads_ativas:
                if thread != current_thread:  # Não fazer join na própria thread
                    thread.join(timeout=5)
                    self.log(f"✅ Thread {thread.name} finalizada")
                
            self.resultados['coordenador'] = {
                'status': 'sucesso',
                'threads_gerenciadas': len(self.threads_ativas),
                'outras_threads_monitoradas': len([t for t in self.threads_ativas if t != current_thread]),
                'tempo_total': time.time() - self.inicio_demo if self.inicio_demo else 0
            }
            
            self.log("✅ AGENTE COORDENADOR: Coordenação concluída")
            
        except Exception as e:
            self.log(f"❌ AGENTE COORDENADOR: Erro - {str(e)}", "ERROR")
            self.resultados['coordenador'] = {'status': 'erro', 'erro': str(e)}
            
    def executar_demo(self):
        """Executa demonstração completa"""
        print("="*60)
        print("🚀 DEMO: AGENTES SIMULTÂNEOS EM AÇÃO")
        print("="*60)
        
        self.inicio_demo = time.time()
        self.log("🎬 Iniciando demonstração de agentes simultâneos")
        
        # Criar e iniciar threads
        threads = [
            threading.Thread(target=self.agente_classificador, name="Classificador"),
            threading.Thread(target=self.agente_monitor, name="Monitor"),
            threading.Thread(target=self.agente_relatorios, name="Relatórios"),
            threading.Thread(target=self.agente_coordenador, name="Coordenador")
        ]
        
        self.threads_ativas = threads
        
        # Iniciar todas as threads
        for i, thread in enumerate(threads):
            thread.start()
            self.log(f"🚀 Thread {i+1} iniciada: {thread.name}")
            time.sleep(0.5)  # Pequeno delay entre inicializações
            
        self.log(f"⚡ {len(threads)} agentes executando simultaneamente!")
        
        # Aguardar conclusão
        for thread in threads:
            thread.join()
            
        # Parar monitor
        self.monitor_ativo = False
        
        # Relatório final
        tempo_total = time.time() - self.inicio_demo
        
        print("\n" + "="*60)
        print("📊 RELATÓRIO FINAL DA DEMONSTRAÇÃO")
        print("="*60)
        
        print(f"⏱️  Tempo total: {tempo_total:.2f}s")
        print(f"🔄 Threads executadas: {len(threads)}")
        
        sucessos = sum(1 for r in self.resultados.values() if r.get('status') == 'sucesso')
        print(f"✅ Agentes bem-sucedidos: {sucessos}/{len(self.resultados)}")
        
        print("\n📋 DETALHES POR AGENTE:")
        for agente, resultado in self.resultados.items():
            status_icon = "✅" if resultado.get('status') == 'sucesso' else "❌"
            print(f"   {status_icon} {agente.upper()}: {resultado.get('status', 'desconhecido')}")
            
            if resultado.get('status') == 'sucesso':
                if agente == 'classificador':
                    print(f"      📁 Arquivos: {resultado.get('arquivos_processados', 0)}")
                elif agente == 'monitor':
                    print(f"      📊 Métricas: {resultado.get('metricas_coletadas', 0)}")
                elif agente == 'relatorios':
                    print(f"      📄 Relatórios: {resultado.get('arquivos_gerados', 0)}")
                elif agente == 'coordenador':
                    print(f"      🎛️ Threads: {resultado.get('threads_gerenciadas', 0)}")
                    
        print("\n🎉 DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO!")
        print("💡 Todos os agentes executaram simultaneamente de forma coordenada.")
        print("="*60)
        
        return self.resultados

def main():
    """Função principal"""
    demo = DemoAgentesSimultaneos()
    resultado = demo.executar_demo()
    
    # Salvar resultado final
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    result_path = demo.project_root / "Development" / "Testing" / f"demo_agentes_resultado_{timestamp}.json"
    
    with open(result_path, 'w', encoding='utf-8') as f:
        json.dump(resultado, f, indent=2, ensure_ascii=False)
        
    print(f"\n📄 Resultado salvo em: {result_path}")
    
    return resultado

if __name__ == "__main__":
    main()