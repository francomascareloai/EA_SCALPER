#!/usr/bin/env python3
"""
MCP Batch Processor Server
Processa múltiplos arquivos de trading em lote para otimização
"""

import json
import sys
import os
import glob
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess
from datetime import datetime

def process_single_file(file_path, mcp_servers_path):
    """
    Processa um único arquivo usando os outros servidores MCP
    """
    try:
        result = {
            "file_path": file_path,
            "processed_at": datetime.now().isoformat(),
            "success": True
        }
        
        # Análise do arquivo
        analyzer_path = os.path.join(mcp_servers_path, "mcp_file_analyzer.py")
        if os.path.exists(analyzer_path):
            analysis_result = subprocess.run(
                ["python", analyzer_path, file_path],
                capture_output=True, text=True, timeout=30
            )
            if analysis_result.returncode == 0:
                try:
                    result["analysis"] = json.loads(analysis_result.stdout)
                except json.JSONDecodeError:
                    result["analysis"] = {"error": "Invalid JSON from analyzer"}
            else:
                result["analysis"] = {"error": analysis_result.stderr}
        
        # Classificação do código
        classifier_path = os.path.join(mcp_servers_path, "mcp_code_classifier.py")
        if os.path.exists(classifier_path):
            classification_result = subprocess.run(
                ["python", classifier_path, file_path],
                capture_output=True, text=True, timeout=30
            )
            if classification_result.returncode == 0:
                try:
                    result["classification"] = json.loads(classification_result.stdout)
                except json.JSONDecodeError:
                    result["classification"] = {"error": "Invalid JSON from classifier"}
            else:
                result["classification"] = {"error": classification_result.stderr}
        
        # Validação FTMO
        ftmo_path = os.path.join(mcp_servers_path, "mcp_ftmo_validator.py")
        if os.path.exists(ftmo_path):
            ftmo_result = subprocess.run(
                ["python", ftmo_path, file_path],
                capture_output=True, text=True, timeout=30
            )
            if ftmo_result.returncode == 0:
                try:
                    result["ftmo_validation"] = json.loads(ftmo_result.stdout)
                except json.JSONDecodeError:
                    result["ftmo_validation"] = {"error": "Invalid JSON from FTMO validator"}
            else:
                result["ftmo_validation"] = {"error": ftmo_result.stderr}
        
        # Geração de metadados
        metadata_path = os.path.join(mcp_servers_path, "mcp_metadata_generator.py")
        if os.path.exists(metadata_path):
            # Combinar dados para metadados
            combined_data = {}
            if "analysis" in result and result["analysis"].get("success"):
                combined_data.update(result["analysis"].get("analysis", {}))
            if "classification" in result and result["classification"].get("success"):
                combined_data.update(result["classification"].get("classification", {}))
            if "ftmo_validation" in result and result["ftmo_validation"].get("success"):
                combined_data.update(result["ftmo_validation"].get("validation", {}))
            
            metadata_result = subprocess.run(
                ["python", metadata_path, file_path, json.dumps(combined_data)],
                capture_output=True, text=True, timeout=30
            )
            if metadata_result.returncode == 0:
                try:
                    result["metadata"] = json.loads(metadata_result.stdout)
                except json.JSONDecodeError:
                    result["metadata"] = {"error": "Invalid JSON from metadata generator"}
            else:
                result["metadata"] = {"error": metadata_result.stderr}
        
        return result
        
    except subprocess.TimeoutExpired:
        return {
            "file_path": file_path,
            "success": False,
            "error": "Processing timeout",
            "processed_at": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "file_path": file_path,
            "success": False,
            "error": str(e),
            "processed_at": datetime.now().isoformat()
        }

def batch_process_directory(directory_path, file_patterns=None, max_workers=4):
    """
    Processa todos os arquivos de um diretório em lote
    """
    try:
        if not os.path.exists(directory_path):
            return {"success": False, "error": "Directory not found"}
        
        # Padrões de arquivo padrão
        if file_patterns is None:
            file_patterns = ['*.mq4', '*.mq5', '*.pine']
        
        # Encontrar todos os arquivos
        files_to_process = []
        for pattern in file_patterns:
            files_to_process.extend(glob.glob(os.path.join(directory_path, '**', pattern), recursive=True))
        
        if not files_to_process:
            return {
                "success": True,
                "message": "No files found matching patterns",
                "patterns": file_patterns,
                "directory": directory_path
            }
        
        # Caminho dos servidores MCP
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Processar arquivos em paralelo
        results = []
        failed_files = []
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # Submeter tarefas
            future_to_file = {
                executor.submit(process_single_file, file_path, current_dir): file_path 
                for file_path in files_to_process
            }
            
            # Coletar resultados
            for future in as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    results.append(result)
                    if not result.get("success", False):
                        failed_files.append(file_path)
                except Exception as e:
                    failed_files.append(file_path)
                    results.append({
                        "file_path": file_path,
                        "success": False,
                        "error": str(e),
                        "processed_at": datetime.now().isoformat()
                    })
        
        # Estatísticas
        total_files = len(files_to_process)
        successful_files = len([r for r in results if r.get("success", False)])
        
        return {
            "success": True,
            "statistics": {
                "total_files": total_files,
                "successful": successful_files,
                "failed": len(failed_files),
                "success_rate": (successful_files / total_files * 100) if total_files > 0 else 0
            },
            "results": results,
            "failed_files": failed_files,
            "processed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

def batch_process_file_list(file_list, max_workers=4):
    """
    Processa uma lista específica de arquivos
    """
    try:
        # Filtrar arquivos existentes
        existing_files = [f for f in file_list if os.path.exists(f)]
        
        if not existing_files:
            return {
                "success": False,
                "error": "No valid files found in the provided list"
            }
        
        # Caminho dos servidores MCP
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Processar arquivos em paralelo
        results = []
        failed_files = []
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # Submeter tarefas
            future_to_file = {
                executor.submit(process_single_file, file_path, current_dir): file_path 
                for file_path in existing_files
            }
            
            # Coletar resultados
            for future in as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    results.append(result)
                    if not result.get("success", False):
                        failed_files.append(file_path)
                except Exception as e:
                    failed_files.append(file_path)
                    results.append({
                        "file_path": file_path,
                        "success": False,
                        "error": str(e),
                        "processed_at": datetime.now().isoformat()
                    })
        
        # Estatísticas
        total_files = len(existing_files)
        successful_files = len([r for r in results if r.get("success", False)])
        
        return {
            "success": True,
            "statistics": {
                "total_files": total_files,
                "successful": successful_files,
                "failed": len(failed_files),
                "success_rate": (successful_files / total_files * 100) if total_files > 0 else 0
            },
            "results": results,
            "failed_files": failed_files,
            "processed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "Usage: python mcp_batch_processor.py <mode> [args]",
            "modes": {
                "directory": "python mcp_batch_processor.py directory <path> [max_workers]",
                "files": "python mcp_batch_processor.py files <file1> <file2> ... [max_workers]"
            }
        }), flush=True)
        return
    
    mode = sys.argv[1].lower()
    
    if mode == "directory":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "Directory path required"}), flush=True)
            return
        
        directory_path = sys.argv[2]
        max_workers = int(sys.argv[3]) if len(sys.argv) > 3 else 4
        
        result = batch_process_directory(directory_path, max_workers=max_workers)
        
    elif mode == "files":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "At least one file path required"}), flush=True)
            return
        
        # Último argumento pode ser max_workers se for número
        try:
            max_workers = int(sys.argv[-1])
            file_list = sys.argv[2:-1]
        except ValueError:
            max_workers = 4
            file_list = sys.argv[2:]
        
        result = batch_process_file_list(file_list, max_workers=max_workers)
        
    else:
        result = {"error": f"Unknown mode: {mode}. Use 'directory' or 'files'"}
    
    print(json.dumps(result, indent=2), flush=True)

if __name__ == "__main__":
    main()