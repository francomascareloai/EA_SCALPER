#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Classificador Trading - Agente de Deduplicação Inteligente
Versão: 1.0
Autor: Classificador_Trading
Data: 2025-01-27

Este agente implementa lógica de deduplicação para evitar processamento
múltiplo do mesmo robô em arquivos diferentes.
"""

import os
import json
import re
import hashlib
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import shutil
from datetime import datetime

class TradingCodeDeduplicator:
    """Agente especializado em deduplicação de códigos de trading."""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.metadata_path = self.base_path / "Metadata"
        self.source_path = self.base_path / "CODIGO_FONTE_LIBRARY"
        self.processed_robots = set()
        self.robot_groups = defaultdict(list)
        self.changelog = []
        
    def extract_robot_base_name(self, filename: str) -> str:
        """Extrai o nome base do robô removendo sufixos de duplicação."""
        # Remove extensão
        name = Path(filename).stem
        
        # Remove sufixos comuns de duplicação: _1, _2, _3, (2), (3), etc.
        patterns = [
            r'_\d+$',  # _1, _2, _3
            r'\s*\(\d+\)$',  # (2), (3)
            r'\s*-\s*\d+$',  # - 2, - 3
            r'\s*copy\s*\d*$',  # copy, copy2
            r'\s*Copy\s*\d*$',  # Copy, Copy2
        ]
        
        base_name = name
        for pattern in patterns:
            base_name = re.sub(pattern, '', base_name, flags=re.IGNORECASE)
        
        return base_name.strip()
    
    def calculate_file_hash(self, filepath: str) -> str:
        """Calcula hash MD5 do arquivo para detectar duplicatas exatas."""
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
                return hashlib.md5(content).hexdigest()
        except Exception as e:
            print(f"Erro ao calcular hash de {filepath}: {e}")
            return "error"
    
    def group_similar_robots(self) -> Dict[str, List[Dict]]:
        """Agrupa robôs similares baseado no nome base."""
        robot_groups = defaultdict(list)
        
        # Processa todos os metadados existentes
        for meta_file in self.metadata_path.glob("*.meta.json"):
            try:
                with open(meta_file, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                
                # Extrai informações do arquivo
                filename = meta_file.stem.replace('.meta', '')
                base_name = self.extract_robot_base_name(filename)
                
                robot_info = {
                    'filename': filename,
                    'base_name': base_name,
                    'meta_file': str(meta_file),
                    'metadata': metadata,
                    'processed': False
                }
                
                robot_groups[base_name].append(robot_info)
                
            except Exception as e:
                print(f"Erro ao processar {meta_file}: {e}")
        
        return robot_groups
    
    def select_best_version(self, robot_group: List[Dict]) -> Dict:
        """Seleciona a melhor versão de um grupo de robôs similares."""
        if len(robot_group) == 1:
            return robot_group[0]
        
        # Critérios de seleção (em ordem de prioridade):
        # 1. FTMO score mais alto
        # 2. Arquivo com nome mais limpo (sem sufixos)
        # 3. Metadata mais completo
        # 4. Arquivo mais recente
        
        best_robot = robot_group[0]
        best_score = 0
        
        for robot in robot_group:
            score = 0
            metadata = robot.get('metadata', {})
            
            # FTMO score (peso 40)
            ftmo_score = metadata.get('ftmo_score', 0)
            score += ftmo_score * 4
            
            # Nome limpo (peso 30)
            if robot['filename'] == robot['base_name']:
                score += 30
            elif not re.search(r'[_\(\)\d]+$', robot['filename']):
                score += 20
            
            # Completude dos metadados (peso 20)
            metadata_completeness = len(str(metadata))
            score += min(metadata_completeness / 100, 20)
            
            # Tamanho do arquivo (peso 10)
            file_size = metadata.get('file_info', {}).get('file_size_kb', 0)
            score += min(file_size / 10, 10)
            
            if score > best_score:
                best_score = score
                best_robot = robot
        
        return best_robot
    
    def move_robot_group(self, robot_group: List[Dict], best_version: Dict) -> bool:
        """Move todos os arquivos de um grupo de robôs para a pasta correta."""
        try:
            # Determina a pasta de destino baseada no melhor arquivo
            metadata = best_version['metadata']
            robot_type = metadata.get('type', 'EA')
            strategy = metadata.get('strategy', 'Misc')
            language = metadata.get('language', 'MQL5')
            
            # Constrói o caminho de destino
            if language == 'MQL5':
                if robot_type == 'EA':
                    if strategy in ['Advanced_Scalping', 'FTMO_Ready', 'Multi_Symbol']:
                        dest_folder = self.source_path / "MQL5_Source" / "EAs" / strategy
                    else:
                        dest_folder = self.source_path / "MQL5_Source" / "EAs" / "Others"
                elif robot_type == 'Indicator':
                    dest_folder = self.source_path / "MQL5_Source" / "Indicators" / "Custom"
                else:
                    dest_folder = self.source_path / "MQL5_Source" / "Scripts" / "Analysis_Tools"
            else:
                dest_folder = self.source_path / "MQL4_Source" / "EAs" / "Others"
            
            # Cria pasta de destino se não existir
            dest_folder.mkdir(parents=True, exist_ok=True)
            
            # Move todos os arquivos do grupo
            moved_files = []
            for robot in robot_group:
                filename = robot['filename']
                
                # Procura pelo arquivo fonte
                source_file = None
                for ext in ['.mq5', '.mq4', '.ex5', '.ex4']:
                    potential_source = self.base_path / f"{filename}{ext}"
                    if potential_source.exists():
                        source_file = potential_source
                        break
                
                if source_file:
                    # Define nome de destino
                    if robot == best_version:
                        dest_name = f"{robot['base_name']}{source_file.suffix}"
                    else:
                        dest_name = f"{robot['base_name']}_backup_{len(moved_files)+1}{source_file.suffix}"
                    
                    dest_file = dest_folder / dest_name
                    
                    # Move o arquivo
                    shutil.move(str(source_file), str(dest_file))
                    moved_files.append({
                        'original': str(source_file),
                        'destination': str(dest_file),
                        'is_primary': robot == best_version
                    })
                    
                    self.changelog.append({
                        'action': 'move_file',
                        'timestamp': datetime.now().isoformat(),
                        'robot_group': robot['base_name'],
                        'file': filename,
                        'from': str(source_file),
                        'to': str(dest_file),
                        'is_primary': robot == best_version
                    })
            
            print(f"✅ Grupo '{best_version['base_name']}' processado: {len(moved_files)} arquivos movidos")
            return True
            
        except Exception as e:
            print(f"❌ Erro ao mover grupo {best_version['base_name']}: {e}")
            return False
    
    def update_catalog(self, processed_groups: Dict[str, Dict]) -> None:
        """Atualiza o catálogo master com os grupos processados."""
        catalog_file = self.metadata_path / "CATALOGO_MASTER.json"
        
        try:
            with open(catalog_file, 'r', encoding='utf-8') as f:
                catalog = json.load(f)
        except:
            catalog = {
                "versao": "1.0",
                "ultima_atualizacao": datetime.now().strftime("%Y-%m-%d"),
                "arquivos": []
            }
        
        # Remove entradas antigas dos grupos processados
        catalog['arquivos'] = [
            item for item in catalog['arquivos']
            if self.extract_robot_base_name(item.get('id', '')) not in processed_groups
        ]
        
        # Adiciona entradas dos grupos processados
        for base_name, group_info in processed_groups.items():
            best_version = group_info['best_version']
            metadata = best_version['metadata']
            
            catalog_entry = {
                'id': base_name,
                'tipo': metadata.get('type', 'EA'),
                'linguagem': metadata.get('language', 'MQL5'),
                'estrategia': metadata.get('strategy', 'Misc'),
                'ftmo_score': metadata.get('ftmo_score', 0),
                'caminho': group_info['final_path'],
                'grupo_processado': True,
                'arquivos_relacionados': len(group_info['all_files']),
                'data_processamento': datetime.now().isoformat()
            }
            
            catalog['arquivos'].append(catalog_entry)
        
        # Atualiza estatísticas
        catalog['ultima_atualizacao'] = datetime.now().strftime("%Y-%m-%d")
        catalog['total_grupos_processados'] = len(processed_groups)
        
        # Salva catálogo atualizado
        with open(catalog_file, 'w', encoding='utf-8') as f:
            json.dump(catalog, f, indent=2, ensure_ascii=False)
    
    def generate_deduplication_report(self, processed_groups: Dict) -> str:
        """Gera relatório detalhado da deduplicação."""
        report = []
        report.append("# RELATÓRIO DE DEDUPLICAÇÃO")
        report.append(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Total de grupos processados: {len(processed_groups)}")
        report.append("")
        
        total_files = sum(len(group['all_files']) for group in processed_groups.values())
        report.append(f"Total de arquivos processados: {total_files}")
        report.append("")
        
        report.append("## GRUPOS PROCESSADOS")
        for base_name, group_info in processed_groups.items():
            report.append(f"### {base_name}")
            report.append(f"- Arquivo principal: {group_info['best_version']['filename']}")
            report.append(f"- Total de duplicatas: {len(group_info['all_files']) - 1}")
            report.append(f"- FTMO Score: {group_info['best_version']['metadata'].get('ftmo_score', 0)}")
            report.append(f"- Destino: {group_info['final_path']}")
            report.append("")
        
        report.append("## CHANGELOG DETALHADO")
        for entry in self.changelog:
            if entry['action'] == 'move_file':
                status = "[PRINCIPAL]" if entry['is_primary'] else "[BACKUP]"
                report.append(f"- {status} {entry['file']} → {entry['to']}")
        
        return "\n".join(report)
    
    def run_deduplication(self) -> Dict:
        """Executa o processo completo de deduplicação."""
        print("🚀 Iniciando processo de deduplicação inteligente...")
        
        # Agrupa robôs similares
        robot_groups = self.group_similar_robots()
        print(f"📊 Encontrados {len(robot_groups)} grupos de robôs")
        
        processed_groups = {}
        
        # Processa cada grupo
        for base_name, robot_group in robot_groups.items():
            if len(robot_group) > 1:
                print(f"\n🔄 Processando grupo '{base_name}' ({len(robot_group)} arquivos)")
                
                # Seleciona melhor versão
                best_version = self.select_best_version(robot_group)
                print(f"   ✨ Melhor versão: {best_version['filename']}")
                
                # Move arquivos do grupo
                if self.move_robot_group(robot_group, best_version):
                    processed_groups[base_name] = {
                        'best_version': best_version,
                        'all_files': robot_group,
                        'final_path': 'MQL5_Source/EAs/...'  # Será atualizado
                    }
                    
                    # Marca como processado
                    self.processed_robots.add(base_name)
            else:
                print(f"✅ '{base_name}' - arquivo único, sem duplicatas")
        
        # Atualiza catálogo
        if processed_groups:
            self.update_catalog(processed_groups)
            print(f"\n📝 Catálogo atualizado com {len(processed_groups)} grupos")
        
        # Gera relatório
        report = self.generate_deduplication_report(processed_groups)
        report_file = self.base_path / "Reports" / f"deduplication_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        report_file.parent.mkdir(exist_ok=True)
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"\n📋 Relatório salvo em: {report_file}")
        print(f"\n🎯 Deduplicação concluída! {len(processed_groups)} grupos processados")
        
        return {
            'processed_groups': len(processed_groups),
            'total_files': sum(len(group['all_files']) for group in processed_groups.values()),
            'report_file': str(report_file),
            'changelog_entries': len(self.changelog)
        }

def main():
    """Função principal para execução standalone."""
    base_path = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    deduplicator = TradingCodeDeduplicator(base_path)
    results = deduplicator.run_deduplication()
    
    print("\n" + "="*50)
    print("RESUMO DA DEDUPLICAÇÃO")
    print("="*50)
    print(f"Grupos processados: {results['processed_groups']}")
    print(f"Arquivos movidos: {results['total_files']}")
    print(f"Relatório: {results['report_file']}")
    print("="*50)

if __name__ == "__main__":
    main()