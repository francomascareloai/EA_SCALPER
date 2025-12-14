#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preparação de Arquivos para Demo
Copia arquivos MQ4 representativos para ambiente de testes
"""

import os
import shutil
import json
from pathlib import Path
from datetime import datetime

def preparar_ambiente_demo():
    """Prepara o ambiente de demonstração com arquivos reais"""
    
    print("🔧 Preparando ambiente de demonstração...")
    
    # Criar estrutura de pastas
    demo_dirs = [
        "Demo_Tests/Input",
        "Demo_Tests/Output/EAs/Scalping",
        "Demo_Tests/Output/EAs/Grid_Martingale", 
        "Demo_Tests/Output/EAs/Trend",
        "Demo_Tests/Output/Indicators/SMC",
        "Demo_Tests/Output/Indicators/Volume",
        "Demo_Tests/Output/Indicators/Custom",
        "Demo_Tests/Output/Scripts/Utilities",
        "Demo_Tests/Metadata",
        "Demo_Tests/Reports",
        "Demo_Tests/Logs"
    ]
    
    for dir_path in demo_dirs:
        os.makedirs(dir_path, exist_ok=True)
        print(f"📁 Criado: {dir_path}")
    
    # Copiar arquivos MQ4 representativos
    source_dir = Path("CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4")
    target_dir = Path("Demo_Tests/Input")
    
    if not source_dir.exists():
        print(f"❌ Pasta fonte não encontrada: {source_dir}")
        return False
    
    # Selecionar arquivos diversos para demonstração
    all_files = list(source_dir.glob("*.mq4"))
    
    # Filtrar arquivos por tipo para ter variedade
    selected_files = []
    
    # EAs (Expert Advisors)
    ea_files = [f for f in all_files if any(keyword in f.name.lower() 
                for keyword in ['ea', 'expert', 'scalp', 'robot', 'advisor'])]
    selected_files.extend(ea_files[:5])  # Primeiros 5 EAs
    
    # Indicadores
    ind_files = [f for f in all_files if any(keyword in f.name.lower() 
                 for keyword in ['indicator', 'ind', 'signal', 'arrow', 'trend'])]
    selected_files.extend(ind_files[:4])  # Primeiros 4 Indicadores
    
    # Scripts
    script_files = [f for f in all_files if any(keyword in f.name.lower() 
                    for keyword in ['script', 'tool', 'utility', 'helper'])]
    selected_files.extend(script_files[:2])  # Primeiros 2 Scripts
    
    # Se não temos arquivos suficientes, pegar qualquer um
    if len(selected_files) < 10:
        remaining = [f for f in all_files if f not in selected_files]
        selected_files.extend(remaining[:10-len(selected_files)])
    
    # Copiar arquivos selecionados
    copied_files = []
    for i, file_path in enumerate(selected_files[:12]):  # Máximo 12 arquivos
        target_path = target_dir / file_path.name
        try:
            shutil.copy2(file_path, target_path)
            copied_files.append(file_path.name)
            print(f"📄 Copiado [{i+1}/12]: {file_path.name}")
        except Exception as e:
            print(f"❌ Erro ao copiar {file_path.name}: {e}")
    
    # Criar arquivo de configuração da demo
    demo_config = {
        "demo_info": {
            "data_preparacao": datetime.now().isoformat(),
            "arquivos_copiados": len(copied_files),
            "pasta_origem": str(source_dir),
            "pasta_destino": str(target_dir)
        },
        "arquivos": copied_files,
        "estrutura_pastas": demo_dirs,
        "tipos_esperados": {
            "EAs": 5,
            "Indicadores": 4,
            "Scripts": 2,
            "Outros": 1
        }
    }
    
    config_path = Path("Demo_Tests/demo_config.json")
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(demo_config, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Ambiente preparado com sucesso!")
    print(f"📊 Total de arquivos copiados: {len(copied_files)}")
    print(f"📁 Pasta de entrada: {target_dir}")
    print(f"⚙️ Configuração salva em: {config_path}")
    
    # Criar arquivo README para a demo
    readme_content = f"""# 🚀 DEMO AMBIENTE DE TESTES - CLASSIFICADOR TRADING

## 📋 Informações da Demo

**Data de Preparação:** {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}
**Arquivos Preparados:** {len(copied_files)} arquivos MQ4

## 📁 Estrutura do Ambiente

```
Demo_Tests/
├── Input/              # Arquivos MQ4 para classificação
├── Output/             # Arquivos classificados por categoria
│   ├── EAs/           # Expert Advisors
│   ├── Indicators/    # Indicadores
│   └── Scripts/       # Scripts e utilitários
├── Metadata/          # Metadados gerados (.meta.json)
├── Reports/           # Relatórios de classificação
└── Logs/              # Logs de execução
```

## 🎯 Arquivos Incluídos na Demo

{chr(10).join([f"- {filename}" for filename in copied_files])}

## 🚀 Como Executar a Demo

1. Execute: `python demo_ambiente_testes.py`
2. Clique em "🚀 INICIAR DEMO" na interface
3. Acompanhe o progresso em tempo real nas abas:
   - 📋 Task Manager: Progresso das tarefas
   - 📊 Monitoramento: Estatísticas em tempo real
   - 📝 Logs: Logs detalhados de execução

## 🎉 Resultados Esperados

- ✅ Classificação automática por tipo (EA/Indicator/Script)
- ✅ Detecção de estratégias (Scalping/Grid/Trend/SMC)
- ✅ Análise de compliance FTMO
- ✅ Geração de metadados estruturados
- ✅ Relatórios detalhados de qualidade

---
*Gerado automaticamente pelo Classificador_Trading*
"""
    
    readme_path = Path("Demo_Tests/README.md")
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    print(f"📖 README criado: {readme_path}")
    
    return True

def verificar_arquivos_demo():
    """Verifica se os arquivos da demo estão prontos"""
    
    demo_path = Path("Demo_Tests")
    if not demo_path.exists():
        print("❌ Pasta Demo_Tests não encontrada")
        return False
    
    input_path = demo_path / "Input"
    if not input_path.exists():
        print("❌ Pasta Demo_Tests/Input não encontrada")
        return False
    
    files = list(input_path.glob("*.mq4"))
    print(f"📊 Arquivos encontrados para demo: {len(files)}")
    
    for file_path in files:
        print(f"  📄 {file_path.name}")
    
    return len(files) > 0

def main():
    """Função principal"""
    print("🎯 PREPARAÇÃO DO AMBIENTE DE DEMONSTRAÇÃO")
    print("=" * 50)
    
    # Verificar se já existe
    if Path("Demo_Tests/Input").exists() and len(list(Path("Demo_Tests/Input").glob("*.mq4"))) > 0:
        print("\n⚠️ Ambiente de demo já existe!")
        resposta = input("Deseja recriar? (s/N): ").lower().strip()
        
        if resposta != 's':
            print("✅ Usando ambiente existente")
            verificar_arquivos_demo()
            return
        else:
            # Limpar ambiente existente
            import shutil
            if Path("Demo_Tests").exists():
                shutil.rmtree("Demo_Tests")
                print("🧹 Ambiente anterior removido")
    
    # Preparar novo ambiente
    if preparar_ambiente_demo():
        print("\n🎉 AMBIENTE DE DEMO PREPARADO COM SUCESSO!")
        print("\n📋 Próximos passos:")
        print("1. Execute: python demo_ambiente_testes.py")
        print("2. Clique em 'INICIAR DEMO' na interface")
        print("3. Acompanhe o processo em tempo real")
    else:
        print("❌ Falha na preparação do ambiente")

if __name__ == "__main__":
    main()