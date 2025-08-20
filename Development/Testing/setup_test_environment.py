#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔧 CONFIGURADOR DE AMBIENTE DE TESTE
Script para configurar e resolver problemas do ambiente de teste Python

Autor: Classificador_Trading
Versão: 1.0
Data: 2025-01-12
"""

import os
import sys
import subprocess
from pathlib import Path

def verificar_python():
    """Verifica a instalação do Python"""
    print("🐍 Verificando Python...")
    print(f"Versão: {sys.version}")
    print(f"Executável: {sys.executable}")
    print(f"Path: {sys.path[0]}")
    return True

def configurar_path_pytest():
    """Configura o PATH para incluir scripts do pytest"""
    print("\n🔧 Configurando PATH para pytest...")
    
    # Diretório dos scripts do usuário
    user_scripts = Path.home() / "AppData" / "Roaming" / "Python" / f"Python{sys.version_info.major}{sys.version_info.minor}" / "Scripts"
    
    if user_scripts.exists():
        current_path = os.environ.get('PATH', '')
        if str(user_scripts) not in current_path:
            print(f"📁 Adicionando ao PATH: {user_scripts}")
            os.environ['PATH'] = str(user_scripts) + os.pathsep + current_path
            print("✅ PATH atualizado para esta sessão")
            
            # Instruções para PATH permanente
            print("\n⚠️  Para tornar permanente, adicione ao PATH do sistema:")
            print(f"   {user_scripts}")
        else:
            print("✅ PATH já configurado")
    else:
        print(f"❌ Diretório não encontrado: {user_scripts}")

def testar_pytest():
    """Testa se o pytest está funcionando"""
    print("\n🧪 Testando pytest...")
    
    try:
        # Tentar importar pytest
        import pytest
        print(f"✅ pytest importado com sucesso - versão {pytest.__version__}")
        
        # Tentar executar pytest --version
        result = subprocess.run([sys.executable, '-m', 'pytest', '--version'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ pytest executável: {result.stdout.strip()}")
            return True
        else:
            print(f"❌ Erro ao executar pytest: {result.stderr}")
            return False
            
    except ImportError:
        print("❌ pytest não está instalado ou não pode ser importado")
        return False

def instalar_dependencias_teste():
    """Instala dependências adicionais para teste"""
    print("\n📦 Instalando dependências de teste...")
    
    dependencias = [
        'pytest-html',      # Relatórios HTML
        'pytest-cov',       # Coverage
        'pytest-xdist',     # Execução paralela
        'pytest-mock',      # Mocking
    ]
    
    for dep in dependencias:
        try:
            print(f"📥 Instalando {dep}...")
            result = subprocess.run([sys.executable, '-m', 'pip', 'install', dep, '--user'], 
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {dep} instalado")
            else:
                print(f"⚠️  Aviso ao instalar {dep}: {result.stderr}")
                
        except Exception as e:
            print(f"❌ Erro ao instalar {dep}: {e}")

def criar_script_teste_exemplo():
    """Cria um script de teste de exemplo"""
    print("\n📝 Criando teste de exemplo...")
    
    test_content = '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Teste de exemplo para verificar o ambiente
"""

import pytest
import sys
from pathlib import Path

def test_python_version():
    """Testa se a versão do Python é adequada"""
    assert sys.version_info >= (3, 8), "Python 3.8+ é necessário"

def test_pathlib_funcionando():
    """Testa se pathlib está funcionando"""
    current_dir = Path.cwd()
    assert current_dir.exists()
    assert current_dir.is_dir()

def test_imports_basicos():
    """Testa imports básicos do sistema"""
    import json
    import os
    import datetime
    assert True  # Se chegou aqui, os imports funcionaram

@pytest.mark.slow
def test_exemplo_lento():
    """Exemplo de teste marcado como lento"""
    import time
    time.sleep(0.1)  # Simula operação lenta
    assert True

if __name__ == "__main__":
    # Executa os testes se chamado diretamente
    pytest.main([__file__, "-v"])
'''
    
    test_file = Path(__file__).parent / "test_exemplo_ambiente.py"
    
    try:
        with open(test_file, 'w', encoding='utf-8') as f:
            f.write(test_content)
        print(f"✅ Teste criado: {test_file}")
        return test_file
    except Exception as e:
        print(f"❌ Erro ao criar teste: {e}")
        return None

def executar_teste_exemplo(test_file):
    """Executa o teste de exemplo"""
    if not test_file or not test_file.exists():
        print("❌ Arquivo de teste não encontrado")
        return False
        
    print(f"\n🚀 Executando teste: {test_file}")
    
    try:
        result = subprocess.run([sys.executable, '-m', 'pytest', str(test_file), '-v'], 
                              capture_output=True, text=True)
        
        print("📊 Resultado do teste:")
        print(result.stdout)
        
        if result.stderr:
            print("⚠️  Avisos/Erros:")
            print(result.stderr)
            
        return result.returncode == 0
        
    except Exception as e:
        print(f"❌ Erro ao executar teste: {e}")
        return False

def main():
    """Função principal"""
    print("🔧 CONFIGURADOR DE AMBIENTE DE TESTE")
    print("=" * 50)
    
    # Verificações básicas
    verificar_python()
    configurar_path_pytest()
    
    # Teste do pytest
    if testar_pytest():
        print("\n✅ pytest está funcionando corretamente!")
        
        # Instalar dependências extras
        instalar_dependencias_teste()
        
        # Criar e executar teste de exemplo
        test_file = criar_script_teste_exemplo()
        if test_file:
            sucesso = executar_teste_exemplo(test_file)
            
            if sucesso:
                print("\n🎉 AMBIENTE DE TESTE CONFIGURADO COM SUCESSO!")
                print("\n📋 Próximos passos:")
                print("1. Execute: python -m pytest Development/Testing/ -v")
                print("2. Para testes específicos: python -m pytest Development/Testing/test_exemplo_ambiente.py")
                print("3. Para relatório HTML: python -m pytest --html=report.html")
            else:
                print("\n⚠️  Ambiente configurado, mas teste falhou")
    else:
        print("\n❌ Problemas com pytest detectados")
        print("\n🔧 Soluções sugeridas:")
        print("1. Reinstale pytest: python -m pip install --user --force-reinstall pytest")
        print("2. Verifique o PATH do sistema")
        print("3. Reinicie o terminal/IDE")

if __name__ == "__main__":
    main()