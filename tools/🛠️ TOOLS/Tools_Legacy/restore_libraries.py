#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script Automatizado para Restauração de Bibliotecas do EA
TradeDev_Master - Sistema de Recuperação de Dependências
"""

import os
import json
import shutil
from datetime import datetime
from pathlib import Path
import re

class LibraryRestorer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.ea_source_dir = self.project_root / "EA_FTMO_SCALPER_ELITE" / "MQL5_Source"
        self.source_dir = self.ea_source_dir / "Source"
        self.backup_dirs = [
            self.project_root / "BACKUP_SEGURANCA",
            self.project_root / "Backups",
            self.project_root / "CODIGO_FONTE_LIBRARY"
        ]
        self.log = []
        
    def log_action(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {message}"
        self.log.append(log_entry)
        print(log_entry)
        
    def extract_includes_from_ea(self):
        """Extrai todos os includes do EA principal"""
        ea_file = self.ea_source_dir / "EA_FTMO_Scalper_Elite.mq5"
        includes = []
        
        if not ea_file.exists():
            self.log_action(f"❌ EA principal não encontrado: {ea_file}")
            return includes
            
        try:
            with open(ea_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Buscar includes do tipo #include "Source/..."
            pattern = r'#include\s+"(Source/[^"]+)"'
            matches = re.findall(pattern, content)
            
            for match in matches:
                includes.append(match)
                self.log_action(f"📋 Include encontrado: {match}")
                
        except Exception as e:
            self.log_action(f"❌ Erro ao ler EA: {e}")
            
        return includes
        
    def search_library_in_backups(self, library_path):
        """Busca uma biblioteca específica nos backups"""
        library_name = os.path.basename(library_path)
        found_files = []
        
        for backup_dir in self.backup_dirs:
            if not backup_dir.exists():
                continue
                
            # Buscar recursivamente
            for root, dirs, files in os.walk(backup_dir):
                for file in files:
                    if file == library_name:
                        full_path = Path(root) / file
                        found_files.append(full_path)
                        self.log_action(f"🔍 Biblioteca encontrada: {full_path}")
                        
        return found_files
        
    def validate_library_content(self, file_path, expected_classes=None):
        """Valida se o arquivo contém as classes esperadas"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Verificações básicas
            if not content.strip():
                return False, "Arquivo vazio"
                
            # Verificar se é um arquivo MQH válido
            if not ('.mqh' in str(file_path).lower() or 'class ' in content or 'struct ' in content):
                return False, "Não parece ser um arquivo MQH válido"
                
            # Verificar classes específicas se fornecidas
            if expected_classes:
                for class_name in expected_classes:
                    if f"class {class_name}" not in content and f"class C{class_name}" not in content:
                        return False, f"Classe {class_name} não encontrada"
                        
            return True, "Válido"
            
        except Exception as e:
            return False, f"Erro ao validar: {e}"
            
    def create_library_structure(self):
        """Cria a estrutura de pastas para as bibliotecas"""
        directories = [
            self.source_dir / "Core",
            self.source_dir / "Strategies" / "ICT",
            self.source_dir / "Utils",
            self.source_dir / "Indicators",
            self.source_dir / "Risk"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            self.log_action(f"📁 Diretório criado: {directory}")
            
    def restore_library(self, library_path, target_path):
        """Restaura uma biblioteca específica"""
        found_files = self.search_library_in_backups(library_path)
        
        if not found_files:
            self.log_action(f"❌ Biblioteca não encontrada: {library_path}")
            return False
            
        # Escolher o melhor candidato (mais recente)
        best_candidate = None
        best_score = 0
        
        for file_path in found_files:
            # Calcular score baseado em data de modificação e tamanho
            try:
                stat = file_path.stat()
                score = stat.st_mtime + (stat.st_size / 1000)  # Priorizar mais recente e maior
                
                if score > best_score:
                    best_score = score
                    best_candidate = file_path
                    
            except Exception:
                continue
                
        if not best_candidate:
            self.log_action(f"❌ Nenhum candidato válido para: {library_path}")
            return False
            
        # Validar conteúdo
        is_valid, validation_msg = self.validate_library_content(best_candidate)
        if not is_valid:
            self.log_action(f"❌ Validação falhou para {library_path}: {validation_msg}")
            return False
            
        # Copiar arquivo
        try:
            target_full_path = self.ea_source_dir / target_path
            target_full_path.parent.mkdir(parents=True, exist_ok=True)
            
            shutil.copy2(best_candidate, target_full_path)
            self.log_action(f"✅ Biblioteca restaurada: {library_path} -> {target_full_path}")
            return True
            
        except Exception as e:
            self.log_action(f"❌ Erro ao copiar {library_path}: {e}")
            return False
            
    def create_missing_libraries(self):
        """Cria bibliotecas básicas se não encontradas"""
        
        # DataStructures.mqh
        data_structures_content = '''
//+------------------------------------------------------------------+
//|                                           DataStructures.mqh |
//|                                    TradeDev_Master Elite System |
//+------------------------------------------------------------------+

// Enumerações
enum ENUM_LOG_LEVEL
{
   LOG_DEBUG = 0,
   LOG_INFO = 1,
   LOG_WARNING = 2,
   LOG_ERROR = 3
};

enum ENUM_SL_CALCULATION_METHOD
{
   SL_FIXED = 0,
   SL_ATR = 1,
   SL_STRUCTURE = 2,
   SL_HYBRID = 3
};

enum ENUM_TP_CALCULATION_METHOD
{
   TP_FIXED = 0,
   TP_ATR = 1,
   TP_STRUCTURE = 2,
   TP_RR_RATIO = 3
};

enum ENUM_TRAILING_METHOD
{
   TRAILING_FIXED = 0,
   TRAILING_ATR = 1,
   TRAILING_STRUCTURE_BREAKS = 2,
   TRAILING_SMART = 3
};

// Estruturas
struct SOrderBlock
{
   datetime time;
   double high;
   double low;
   double volume;
   bool is_bullish;
   bool is_valid;
   int strength;
};

struct SFVG
{
   datetime time;
   double high;
   double low;
   bool is_bullish;
   bool is_filled;
   double fill_percentage;
};

struct SLiquidityLevel
{
   double price;
   datetime time;
   int touches;
   bool is_broken;
   double volume;
};
'''
        
        # Interfaces.mqh
        interfaces_content = '''
//+------------------------------------------------------------------+
//|                                              Interfaces.mqh |
//|                                    TradeDev_Master Elite System |
//+------------------------------------------------------------------+

// Interface base para detectores
class IDetector
{
public:
   virtual bool Initialize() = 0;
   virtual bool Update() = 0;
   virtual void Reset() = 0;
};

// Interface para análise de confluência
class IConfluenceAnalyzer
{
public:
   virtual double CalculateScore() = 0;
   virtual bool IsValidSignal() = 0;
};
'''
        
        # Logger.mqh
        logger_content = '''
//+------------------------------------------------------------------+
//|                                                   Logger.mqh |
//|                                    TradeDev_Master Elite System |
//+------------------------------------------------------------------+

class CLogger
{
private:
   ENUM_LOG_LEVEL m_log_level;
   bool m_enabled;
   
public:
   CLogger() : m_log_level(LOG_INFO), m_enabled(true) {}
   
   void SetLevel(ENUM_LOG_LEVEL level) { m_log_level = level; }
   void Enable(bool enable) { m_enabled = enable; }
   
   void Debug(string message) { if(m_enabled && m_log_level <= LOG_DEBUG) Print("[DEBUG] ", message); }
   void Info(string message) { if(m_enabled && m_log_level <= LOG_INFO) Print("[INFO] ", message); }
   void Warning(string message) { if(m_enabled && m_log_level <= LOG_WARNING) Print("[WARNING] ", message); }
   void Error(string message) { if(m_enabled && m_log_level <= LOG_ERROR) Print("[ERROR] ", message); }
};
'''
        
        libraries_to_create = [
            ("Source/Core/DataStructures.mqh", data_structures_content),
            ("Source/Core/Interfaces.mqh", interfaces_content),
            ("Source/Core/Logger.mqh", logger_content)
        ]
        
        for lib_path, content in libraries_to_create:
            full_path = self.ea_source_dir / lib_path
            if not full_path.exists():
                try:
                    full_path.parent.mkdir(parents=True, exist_ok=True)
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    self.log_action(f"✅ Biblioteca básica criada: {lib_path}")
                except Exception as e:
                    self.log_action(f"❌ Erro ao criar {lib_path}: {e}")
                    
    def run_restoration(self):
        """Executa o processo completo de restauração"""
        self.log_action("🚀 Iniciando restauração de bibliotecas...")
        
        # 1. Extrair includes do EA
        includes = self.extract_includes_from_ea()
        
        if not includes:
            self.log_action("❌ Nenhum include encontrado no EA")
            return False
            
        # 2. Criar estrutura de diretórios
        self.create_library_structure()
        
        # 3. Tentar restaurar cada biblioteca
        restored_count = 0
        for include_path in includes:
            if self.restore_library(include_path, include_path):
                restored_count += 1
                
        # 4. Criar bibliotecas básicas se necessário
        self.create_missing_libraries()
        
        # 5. Salvar relatório
        report = {
            "timestamp": datetime.now().isoformat(),
            "total_includes": len(includes),
            "restored_count": restored_count,
            "includes_found": includes,
            "log": self.log
        }
        
        report_file = self.project_root / "Tools" / "library_restore_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        self.log_action(f"📊 Relatório salvo: {report_file}")
        self.log_action(f"✅ Restauração concluída: {restored_count}/{len(includes)} bibliotecas")
        
        return restored_count > 0

if __name__ == "__main__":
    project_root = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    restorer = LibraryRestorer(project_root)
    restorer.run_restoration()