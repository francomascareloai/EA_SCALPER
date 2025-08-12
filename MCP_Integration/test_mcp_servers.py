#!/usr/bin/env python3
"""
Script de Teste para Servidores MCP
Verifica se todos os servidores MCP estão funcionando corretamente
"""

import os
import sys
import json
import subprocess
import time
from datetime import datetime

def test_server(server_name, script_path, test_args):
    """
    Testa um servidor MCP individual
    """
    print(f"\n🧪 Testando {server_name}...")
    
    if not os.path.exists(script_path):
        return {
            "server": server_name,
            "success": False,
            "error": "Script não encontrado",
            "path": script_path
        }
    
    try:
        start_time = time.time()
        
        # Executar o servidor
        result = subprocess.run(
            ["python", script_path] + test_args,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        end_time = time.time()
        execution_time = round(end_time - start_time, 2)
        
        if result.returncode == 0:
            try:
                # Tentar parsear JSON
                output_data = json.loads(result.stdout)
                print(f"✅ {server_name} - OK ({execution_time}s)")
                return {
                    "server": server_name,
                    "success": True,
                    "execution_time": execution_time,
                    "output": output_data
                }
            except json.JSONDecodeError:
                print(f"❌ {server_name} - JSON inválido")
                return {
                    "server": server_name,
                    "success": False,
                    "error": "JSON inválido",
                    "stdout": result.stdout,
                    "stderr": result.stderr
                }
        else:
            print(f"❌ {server_name} - Erro de execução")
            return {
                "server": server_name,
                "success": False,
                "error": "Erro de execução",
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
            
    except subprocess.TimeoutExpired:
        print(f"⏰ {server_name} - Timeout")
        return {
            "server": server_name,
            "success": False,
            "error": "Timeout"
        }
    except Exception as e:
        print(f"💥 {server_name} - Exceção: {str(e)}")
        return {
            "server": server_name,
            "success": False,
            "error": str(e)
        }

def create_test_file():
    """
    Cria um arquivo de teste MQL4 simples
    """
    test_content = """
//+------------------------------------------------------------------+
//|                                                    TestEA.mq4   |
//|                                  Copyright 2024, Test Company   |
//|                                             https://test.com    |
//+------------------------------------------------------------------+
#property copyright "Test Company"
#property link      "https://test.com"
#property version   "1.00"
#property strict

// Input parameters
input double LotSize = 0.01;
input int StopLoss = 50;
input int TakeProfit = 150;
input int MagicNumber = 12345;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Simple scalping logic
   if(OrdersTotal() == 0)
   {
      double ma_fast = iMA(Symbol(), PERIOD_M5, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
      double ma_slow = iMA(Symbol(), PERIOD_M5, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
      
      if(ma_fast > ma_slow)
      {
         OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "Test Buy", MagicNumber, 0, clrGreen);
      }
      else if(ma_fast < ma_slow)
      {
         OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "Test Sell", MagicNumber, 0, clrRed);
      }
   }
}
"""
    
    test_file_path = "test_ea_temp.mq4"
    with open(test_file_path, 'w', encoding='utf-8') as f:
        f.write(test_content)
    
    return test_file_path

def main():
    print("🚀 Iniciando Teste dos Servidores MCP")
    print("=" * 50)
    
    # Diretório dos servidores
    servers_dir = os.path.join(os.path.dirname(__file__), "servers")
    
    # Criar arquivo de teste
    test_file = create_test_file()
    print(f"📁 Arquivo de teste criado: {test_file}")
    
    # Definir testes
    tests = [
        {
            "name": "File Analyzer",
            "script": os.path.join(servers_dir, "mcp_file_analyzer.py"),
            "args": [test_file]
        },
        {
            "name": "Code Classifier",
            "script": os.path.join(servers_dir, "mcp_code_classifier.py"),
            "args": [test_file]
        },
        {
            "name": "FTMO Validator",
            "script": os.path.join(servers_dir, "mcp_ftmo_validator.py"),
            "args": [test_file]
        },
        {
            "name": "Metadata Generator",
            "script": os.path.join(servers_dir, "mcp_metadata_generator.py"),
            "args": [test_file, '{"type":"EA","strategy":"Scalping"}']
        },
        {
            "name": "Batch Processor",
            "script": os.path.join(servers_dir, "mcp_batch_processor.py"),
            "args": ["files", test_file]
        }
    ]
    
    # Executar testes
    results = []
    for test in tests:
        result = test_server(test["name"], test["script"], test["args"])
        results.append(result)
    
    # Limpar arquivo de teste
    try:
        os.remove(test_file)
        print(f"\n🗑️ Arquivo de teste removido: {test_file}")
    except:
        pass
    
    # Gerar relatório
    print("\n" + "=" * 50)
    print("📊 RELATÓRIO DE TESTES")
    print("=" * 50)
    
    successful_tests = [r for r in results if r["success"]]
    failed_tests = [r for r in results if not r["success"]]
    
    print(f"✅ Sucessos: {len(successful_tests)}/{len(results)}")
    print(f"❌ Falhas: {len(failed_tests)}/{len(results)}")
    
    if successful_tests:
        print("\n🎉 SERVIDORES FUNCIONANDO:")
        for result in successful_tests:
            exec_time = result.get("execution_time", "N/A")
            print(f"  • {result['server']} ({exec_time}s)")
    
    if failed_tests:
        print("\n💥 SERVIDORES COM PROBLEMAS:")
        for result in failed_tests:
            print(f"  • {result['server']}: {result.get('error', 'Erro desconhecido')}")
    
    # Salvar relatório detalhado
    report = {
        "timestamp": datetime.now().isoformat(),
        "summary": {
            "total_tests": len(results),
            "successful": len(successful_tests),
            "failed": len(failed_tests),
            "success_rate": round(len(successful_tests) / len(results) * 100, 1)
        },
        "results": results
    }
    
    report_file = "mcp_test_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 Relatório detalhado salvo em: {report_file}")
    
    # Status final
    if len(failed_tests) == 0:
        print("\n🎊 TODOS OS SERVIDORES MCP ESTÃO FUNCIONANDO PERFEITAMENTE!")
        return 0
    else:
        print(f"\n⚠️ {len(failed_tests)} servidor(es) com problemas. Verifique a configuração.")
        return 1

if __name__ == "__main__":
    sys.exit(main())