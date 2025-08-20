#!/usr/bin/env python3
"""
MCP Servers Manager
Script para inicializar e gerenciar todos os servidores MCP
"""

import os
import sys
import json
import time
import signal
import subprocess
import threading
import logging
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime
import psutil
import requests

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('mcp_manager.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('MCPManager')

class MCPServerManager:
    """Gerenciador de servidores MCP"""
    
    def __init__(self, config_file: str = "mcp_config.json"):
        self.config_file = Path(config_file)
        self.config = self._load_config()
        self.servers = {}
        self.running = False
        self.health_check_thread = None
        
        # Criar diretórios necessários
        self._create_directories()
        
        # Configurar handlers de sinal
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
        
    def _load_config(self) -> Dict:
        """Carregar configuração dos servidores MCP"""
        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.error(f"Arquivo de configuração não encontrado: {self.config_file}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            logger.error(f"Erro ao parsear configuração: {e}")
            sys.exit(1)
            
    def _create_directories(self):
        """Criar diretórios necessários"""
        directories = [
            "logs",
            "backups",
            "temp",
            "data"
        ]
        
        for directory in directories:
            Path(directory).mkdir(exist_ok=True)
            
    def _signal_handler(self, signum, frame):
        """Handler para sinais do sistema"""
        logger.info(f"Recebido sinal {signum}, parando servidores...")
        self.stop_all_servers()
        sys.exit(0)
        
    def start_server(self, server_name: str) -> bool:
        """Iniciar um servidor MCP específico"""
        if server_name not in self.config['mcp_servers']:
            logger.error(f"Servidor '{server_name}' não encontrado na configuração")
            return False
            
        server_config = self.config['mcp_servers'][server_name]
        
        if not server_config.get('enabled', True):
            logger.info(f"Servidor '{server_name}' está desabilitado")
            return False
            
        if server_name in self.servers and self.servers[server_name]['process'].poll() is None:
            logger.warning(f"Servidor '{server_name}' já está rodando")
            return True
            
        try:
            # Preparar comando
            script_path = Path(server_config['script_path'])
            if not script_path.exists():
                logger.error(f"Script não encontrado: {script_path}")
                return False
                
            # Preparar ambiente
            env = os.environ.copy()
            env['MCP_SERVER_NAME'] = server_name
            env['MCP_SERVER_PORT'] = str(server_config.get('port', 8000))
            env['MCP_SERVER_HOST'] = self.config['global_config'].get('host', 'localhost')
            
            # Iniciar processo
            process = subprocess.Popen(
                [sys.executable, str(script_path)],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            # Armazenar informações do servidor
            self.servers[server_name] = {
                'process': process,
                'config': server_config,
                'started_at': datetime.now(),
                'restart_count': 0,
                'last_health_check': None,
                'status': 'starting'
            }
            
            # Aguardar inicialização
            time.sleep(2)
            
            # Verificar se o processo ainda está rodando
            if process.poll() is None:
                logger.info(f"Servidor '{server_name}' iniciado com sucesso (PID: {process.pid})")
                self.servers[server_name]['status'] = 'running'
                return True
            else:
                stdout, stderr = process.communicate()
                logger.error(f"Servidor '{server_name}' falhou ao iniciar:")
                logger.error(f"STDOUT: {stdout}")
                logger.error(f"STDERR: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"Erro ao iniciar servidor '{server_name}': {e}")
            return False
            
    def stop_server(self, server_name: str) -> bool:
        """Parar um servidor MCP específico"""
        if server_name not in self.servers:
            logger.warning(f"Servidor '{server_name}' não está rodando")
            return True
            
        try:
            server_info = self.servers[server_name]
            process = server_info['process']
            
            if process.poll() is None:
                # Tentar parar graciosamente
                process.terminate()
                
                # Aguardar até 10 segundos
                try:
                    process.wait(timeout=10)
                    logger.info(f"Servidor '{server_name}' parado graciosamente")
                except subprocess.TimeoutExpired:
                    # Forçar parada
                    process.kill()
                    process.wait()
                    logger.warning(f"Servidor '{server_name}' foi forçado a parar")
                    
            # Remover da lista de servidores
            del self.servers[server_name]
            return True
            
        except Exception as e:
            logger.error(f"Erro ao parar servidor '{server_name}': {e}")
            return False
            
    def restart_server(self, server_name: str) -> bool:
        """Reiniciar um servidor MCP"""
        logger.info(f"Reiniciando servidor '{server_name}'...")
        
        if server_name in self.servers:
            self.servers[server_name]['restart_count'] += 1
            
        success = self.stop_server(server_name)
        if success:
            time.sleep(1)  # Aguardar um pouco antes de reiniciar
            return self.start_server(server_name)
        return False
        
    def start_all_servers(self) -> Dict[str, bool]:
        """Iniciar todos os servidores habilitados"""
        logger.info("Iniciando todos os servidores MCP...")
        
        results = {}
        
        for server_name, server_config in self.config['mcp_servers'].items():
            if server_config.get('auto_start', True):
                results[server_name] = self.start_server(server_name)
            else:
                logger.info(f"Servidor '{server_name}' configurado para não iniciar automaticamente")
                results[server_name] = None
                
        # Iniciar monitoramento de saúde
        if self.config['global_config'].get('health_check_interval', 0) > 0:
            self.start_health_monitoring()
            
        self.running = True
        return results
        
    def stop_all_servers(self) -> Dict[str, bool]:
        """Parar todos os servidores"""
        logger.info("Parando todos os servidores MCP...")
        
        self.running = False
        
        # Parar monitoramento de saúde
        if self.health_check_thread and self.health_check_thread.is_alive():
            self.health_check_thread.join(timeout=5)
            
        results = {}
        
        for server_name in list(self.servers.keys()):
            results[server_name] = self.stop_server(server_name)
            
        return results
        
    def get_server_status(self, server_name: str) -> Dict:
        """Obter status de um servidor"""
        if server_name not in self.servers:
            return {'status': 'stopped', 'message': 'Servidor não está rodando'}
            
        server_info = self.servers[server_name]
        process = server_info['process']
        
        if process.poll() is None:
            # Processo está rodando
            try:
                # Obter informações do processo
                proc = psutil.Process(process.pid)
                
                return {
                    'status': 'running',
                    'pid': process.pid,
                    'started_at': server_info['started_at'].isoformat(),
                    'restart_count': server_info['restart_count'],
                    'cpu_percent': proc.cpu_percent(),
                    'memory_mb': proc.memory_info().rss / 1024 / 1024,
                    'last_health_check': server_info.get('last_health_check')
                }
            except psutil.NoSuchProcess:
                return {'status': 'error', 'message': 'Processo não encontrado'}
        else:
            return {'status': 'stopped', 'exit_code': process.poll()}
            
    def get_all_status(self) -> Dict:
        """Obter status de todos os servidores"""
        status = {
            'manager_status': 'running' if self.running else 'stopped',
            'total_servers': len(self.config['mcp_servers']),
            'running_servers': len(self.servers),
            'servers': {}
        }
        
        for server_name in self.config['mcp_servers']:
            status['servers'][server_name] = self.get_server_status(server_name)
            
        return status
        
    def health_check(self, server_name: str) -> bool:
        """Verificar saúde de um servidor"""
        if server_name not in self.servers:
            return False
            
        server_config = self.servers[server_name]['config']
        port = server_config.get('port', 8000)
        host = self.config['global_config'].get('host', 'localhost')
        
        try:
            # Tentar fazer uma requisição de health check
            health_endpoint = self.config['monitoring'].get('health_endpoint', '/health')
            url = f"http://{host}:{port}{health_endpoint}"
            
            response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                self.servers[server_name]['last_health_check'] = datetime.now().isoformat()
                return True
            else:
                logger.warning(f"Health check falhou para '{server_name}': HTTP {response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            logger.warning(f"Health check falhou para '{server_name}': {e}")
            return False
            
    def start_health_monitoring(self):
        """Iniciar monitoramento de saúde em thread separada"""
        def health_monitor():
            interval = self.config['global_config'].get('health_check_interval', 30)
            auto_restart = self.config['global_config'].get('auto_restart_on_failure', True)
            
            while self.running:
                for server_name in list(self.servers.keys()):
                    if not self.health_check(server_name):
                        logger.warning(f"Servidor '{server_name}' falhou no health check")
                        
                        if auto_restart:
                            logger.info(f"Tentando reiniciar servidor '{server_name}'...")
                            self.restart_server(server_name)
                            
                time.sleep(interval)
                
        self.health_check_thread = threading.Thread(target=health_monitor, daemon=True)
        self.health_check_thread.start()
        logger.info("Monitoramento de saúde iniciado")
        
    def generate_claude_config(self) -> Dict:
        """Gerar configuração para Claude Desktop"""
        claude_config = {
            "mcpServers": {}
        }
        
        for server_name, server_config in self.config['mcp_servers'].items():
            if server_config.get('enabled', True):
                claude_config["mcpServers"][server_name] = {
                    "command": "python",
                    "args": [str(Path(server_config['script_path']).absolute())],
                    "env": {
                        "MCP_SERVER_NAME": server_name,
                        "MCP_SERVER_PORT": str(server_config.get('port', 8000))
                    }
                }
                
        return claude_config
        
    def save_claude_config(self, output_file: str = "claude_mcp_config.json"):
        """Salvar configuração para Claude Desktop"""
        config = self.generate_claude_config()
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
            
        logger.info(f"Configuração do Claude salva em: {output_file}")
        
    def create_startup_script(self, script_type: str = "batch"):
        """Criar script de inicialização"""
        if script_type == "batch":
            script_content = f'''@echo off
echo Iniciando servidores MCP...
cd /d "{Path.cwd()}"
python start_mcp_servers.py
pause
'''
            script_file = "start_mcp.bat"
        else:
            script_content = f'''#!/bin/bash
echo "Iniciando servidores MCP..."
cd "{Path.cwd()}"
python3 start_mcp_servers.py
'''
            script_file = "start_mcp.sh"
            
        with open(script_file, 'w', encoding='utf-8') as f:
            f.write(script_content)
            
        if script_type == "bash":
            os.chmod(script_file, 0o755)
            
        logger.info(f"Script de inicialização criado: {script_file}")
        
    def backup_configs(self):
        """Fazer backup das configurações"""
        if not self.config['backup'].get('enabled', True):
            return
            
        backup_dir = Path(self.config['backup'].get('backup_location', './backups'))
        backup_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = backup_dir / f"mcp_config_backup_{timestamp}.json"
        
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, indent=2)
            
        logger.info(f"Backup da configuração salvo: {backup_file}")
        
    def run_interactive_mode(self):
        """Executar em modo interativo"""
        print("\n=== MCP Servers Manager ===")
        print("Comandos disponíveis:")
        print("  start <server>    - Iniciar servidor específico")
        print("  stop <server>     - Parar servidor específico")
        print("  restart <server>  - Reiniciar servidor específico")
        print("  status [server]   - Ver status (de um servidor ou todos)")
        print("  list              - Listar servidores configurados")
        print("  health            - Verificar saúde de todos os servidores")
        print("  backup            - Fazer backup das configurações")
        print("  claude-config     - Gerar configuração para Claude")
        print("  quit              - Sair")
        print()
        
        while True:
            try:
                command = input("MCP> ").strip().split()
                
                if not command:
                    continue
                    
                cmd = command[0].lower()
                
                if cmd == "quit" or cmd == "exit":
                    break
                elif cmd == "start":
                    if len(command) > 1:
                        server_name = command[1]
                        success = self.start_server(server_name)
                        print(f"Servidor '{server_name}': {'iniciado' if success else 'falha ao iniciar'}")
                    else:
                        print("Uso: start <server_name>")
                elif cmd == "stop":
                    if len(command) > 1:
                        server_name = command[1]
                        success = self.stop_server(server_name)
                        print(f"Servidor '{server_name}': {'parado' if success else 'falha ao parar'}")
                    else:
                        print("Uso: stop <server_name>")
                elif cmd == "restart":
                    if len(command) > 1:
                        server_name = command[1]
                        success = self.restart_server(server_name)
                        print(f"Servidor '{server_name}': {'reiniciado' if success else 'falha ao reiniciar'}")
                    else:
                        print("Uso: restart <server_name>")
                elif cmd == "status":
                    if len(command) > 1:
                        server_name = command[1]
                        status = self.get_server_status(server_name)
                        print(f"Status do servidor '{server_name}': {json.dumps(status, indent=2)}")
                    else:
                        status = self.get_all_status()
                        print(f"Status geral: {json.dumps(status, indent=2)}")
                elif cmd == "list":
                    print("Servidores configurados:")
                    for name, config in self.config['mcp_servers'].items():
                        enabled = "✓" if config.get('enabled', True) else "✗"
                        auto_start = "✓" if config.get('auto_start', True) else "✗"
                        print(f"  {name}: Habilitado={enabled}, Auto-start={auto_start}, Porta={config.get('port', 'N/A')}")
                elif cmd == "health":
                    print("Verificando saúde dos servidores...")
                    for server_name in self.servers:
                        healthy = self.health_check(server_name)
                        status = "✓ Saudável" if healthy else "✗ Com problemas"
                        print(f"  {server_name}: {status}")
                elif cmd == "backup":
                    self.backup_configs()
                    print("Backup das configurações realizado")
                elif cmd == "claude-config":
                    self.save_claude_config()
                    print("Configuração do Claude gerada")
                else:
                    print(f"Comando desconhecido: {cmd}")
                    
            except KeyboardInterrupt:
                print("\nSaindo...")
                break
            except Exception as e:
                print(f"Erro: {e}")
                
def main():
    """Função principal"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Gerenciador de Servidores MCP")
    parser.add_argument("--config", default="mcp_config.json", help="Arquivo de configuração")
    parser.add_argument("--start-all", action="store_true", help="Iniciar todos os servidores")
    parser.add_argument("--stop-all", action="store_true", help="Parar todos os servidores")
    parser.add_argument("--status", action="store_true", help="Mostrar status")
    parser.add_argument("--interactive", "-i", action="store_true", help="Modo interativo")
    parser.add_argument("--claude-config", action="store_true", help="Gerar configuração para Claude")
    parser.add_argument("--create-startup", choices=["batch", "bash"], help="Criar script de inicialização")
    parser.add_argument("--server", help="Nome do servidor específico")
    parser.add_argument("--action", choices=["start", "stop", "restart"], help="Ação para servidor específico")
    
    args = parser.parse_args()
    
    # Criar gerenciador
    manager = MCPServerManager(args.config)
    
    try:
        if args.claude_config:
            manager.save_claude_config()
            
        elif args.create_startup:
            manager.create_startup_script(args.create_startup)
            
        elif args.start_all:
            results = manager.start_all_servers()
            print("Resultados da inicialização:")
            for server, success in results.items():
                if success is not None:
                    print(f"  {server}: {'✓' if success else '✗'}")
                    
            if args.interactive:
                manager.run_interactive_mode()
            else:
                print("\nPressione Ctrl+C para parar todos os servidores")
                try:
                    while manager.running:
                        time.sleep(1)
                except KeyboardInterrupt:
                    pass
                    
        elif args.stop_all:
            results = manager.stop_all_servers()
            print("Resultados da parada:")
            for server, success in results.items():
                print(f"  {server}: {'✓' if success else '✗'}")
                
        elif args.status:
            status = manager.get_all_status()
            print(json.dumps(status, indent=2))
            
        elif args.server and args.action:
            if args.action == "start":
                success = manager.start_server(args.server)
            elif args.action == "stop":
                success = manager.stop_server(args.server)
            elif args.action == "restart":
                success = manager.restart_server(args.server)
                
            print(f"Servidor '{args.server}': {'✓' if success else '✗'}")
            
        elif args.interactive:
            manager.run_interactive_mode()
            
        else:
            parser.print_help()
            
    finally:
        # Garantir que todos os servidores sejam parados
        if manager.running:
            manager.stop_all_servers()
            
if __name__ == "__main__":
    main()