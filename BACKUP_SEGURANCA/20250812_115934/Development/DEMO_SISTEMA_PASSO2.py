#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎬 DEMONSTRAÇÃO SISTEMA COMPLETO - PASSO 2
Exemplo prático de uso de todos os componentes implementados

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Este arquivo demonstra:
- Como usar o sistema de monitoramento
- Como gerar relatórios avançados
- Como integrar todos os componentes
- Exemplos práticos de uso
"""

import os
import sys
import time
import json
from datetime import datetime

# Adicionar Core ao path
sys.path.append(os.path.join(os.path.dirname(__file__), 'Core'))

try:
    from monitor_tempo_real import MonitorTempoReal
    from gerador_relatorios_avancados import GeradorRelatoriosAvancados
except ImportError as e:
    print(f"❌ Erro ao importar: {e}")
    print("Execute este arquivo do diretório Development/")
    sys.exit(1)

def demo_monitoramento_tempo_real():
    """
    Demonstra o sistema de monitoramento em tempo real
    """
    print("\n🔍 DEMO: MONITORAMENTO EM TEMPO REAL")
    print("="*50)
    
    # Criar monitor
    monitor = MonitorTempoReal(update_interval=1.0)
    
    # Configurar callbacks
    def on_update(metrics, alerts):
        print(f"📊 {metrics.files_processed} arquivos | {metrics.success_rate:.1f}% sucesso | {metrics.processing_rate:.2f} arq/s")
        
        if alerts:
            for alert in alerts:
                emoji = "🚨" if alert['severity'] == 'high' else "⚠️" if alert['severity'] == 'medium' else "ℹ️"
                print(f"   {emoji} {alert['message']}")
    
    def on_status_change(status):
        print(f"🔄 Status: {status}")
    
    monitor.add_update_callback(on_update)
    monitor.add_status_callback(on_status_change)
    
    # Iniciar monitoramento
    print("▶️ Iniciando monitoramento...")
    monitor.start_monitoring()
    
    # Simular processamento de arquivos
    print("🔄 Simulando processamento de 20 arquivos...")
    
    for i in range(20):
        # Simular dados realistas
        files_processed = i + 1
        files_successful = max(0, files_processed - (i // 5))  # Alguns erros ocasionais
        files_failed = files_processed - files_successful
        
        # Simular uso de recursos
        memory_usage = 40 + (i * 2)  # Crescimento gradual
        cpu_usage = 25 + (i * 1.5)
        
        progress_data = {
            'files_processed': files_processed,
            'files_successful': files_successful,
            'files_failed': files_failed,
            'memory_usage': memory_usage,
            'cpu_usage': cpu_usage,
            'current_file': f"EA_Example_{i+1}.mq4"
        }
        
        monitor.update_metrics(progress_data)
        time.sleep(0.5)  # Simular tempo de processamento
    
    print("\n⏹️ Parando monitoramento...")
    monitor.stop_monitoring()
    
    # Exportar relatório da sessão
    session_report = monitor.export_session_report()
    print(f"📄 Relatório da sessão salvo: {session_report}")
    
    return monitor.get_dashboard_data()

def demo_gerador_relatorios(dashboard_data):
    """
    Demonstra o gerador de relatórios avançados
    """
    print("\n📊 DEMO: GERADOR DE RELATÓRIOS AVANÇADOS")
    print("="*50)
    
    # Criar gerador
    gerador = GeradorRelatoriosAvancados()
    
    # Preparar dados para relatório
    current_metrics = dashboard_data.get('current_metrics', {})
    performance_summary = dashboard_data.get('performance_summary', {})
    
    report_data = {
        'execution_time': dashboard_data.get('uptime', 10.0),
        'statistics': {
            'processed': current_metrics.get('files_processed', 20),
            'successful': current_metrics.get('files_successful', 18),
            'errors': current_metrics.get('files_failed', 2)
        },
        'performance': {
            'files_per_second': performance_summary.get('avg_processing_rate', 2.0),
            'success_rate': performance_summary.get('avg_success_rate', 90.0),
            'error_rate': 10.0
        },
        'top_categories': [
            ('EA', 12),
            ('Indicator', 6),
            ('Script', 2)
        ],
        'quality_summary': {
            'High': 8,
            'Medium': 7,
            'Low': 3,
            'Unknown': 2
        },
        'ftmo_summary': {
            'FTMO_Ready': 5,
            'Parcialmente_Adequado': 8,
            'Não_Adequado': 7
        },
        'recommendations': [
            "✅ Taxa de sucesso excelente (90%) - sistema funcionando bem",
            "⚠️ 2 arquivos com erro - verificar logs para detalhes",
            "🎯 5 EAs FTMO-ready identificados - prontos para uso",
            "📈 Performance adequada (2.0 arq/s) - dentro do esperado"
        ]
    }
    
    print("📝 Gerando relatórios em múltiplos formatos...")
    
    # Gerar relatórios completos
    files = gerador.generate_comprehensive_report(report_data, "full")
    
    print("\n✅ Relatórios gerados com sucesso:")
    for format_type, filepath in files.items():
        if os.path.exists(filepath):
            size = os.path.getsize(filepath)
            print(f"   📄 {format_type.upper()}: {os.path.basename(filepath)} ({size:,} bytes)")
        else:
            print(f"   ❌ {format_type.upper()}: arquivo não encontrado")
    
    # Mostrar relatórios disponíveis
    available_reports = gerador.get_available_reports()
    print(f"\n📋 Total de relatórios disponíveis: {len(available_reports)}")
    
    if available_reports:
        print("\n📊 Últimos 3 relatórios:")
        for report in available_reports[:3]:
            print(f"   📄 {report['name']} ({report['format']}) - {report['size']:,} bytes")
    
    return files

def demo_integracao_completa():
    """
    Demonstra integração completa do sistema
    """
    print("\n🔗 DEMO: INTEGRAÇÃO COMPLETA")
    print("="*50)
    
    print("🚀 Executando fluxo completo do sistema...")
    
    # 1. Monitoramento
    print("\n1️⃣ Iniciando monitoramento...")
    dashboard_data = demo_monitoramento_tempo_real()
    
    # 2. Geração de relatórios
    print("\n2️⃣ Gerando relatórios...")
    report_files = demo_gerador_relatorios(dashboard_data)
    
    # 3. Resumo final
    print("\n3️⃣ Resumo da execução:")
    print(f"   📊 Dashboard: {len(dashboard_data)} métricas coletadas")
    print(f"   📄 Relatórios: {len(report_files)} formatos gerados")
    
    # 4. Verificar arquivos gerados
    total_size = 0
    for filepath in report_files.values():
        if os.path.exists(filepath):
            total_size += os.path.getsize(filepath)
    
    print(f"   💾 Tamanho total: {total_size:,} bytes")
    
    return {
        'dashboard_metrics': len(dashboard_data),
        'reports_generated': len(report_files),
        'total_size': total_size,
        'status': 'success'
    }

def demo_casos_de_uso():
    """
    Demonstra casos de uso práticos
    """
    print("\n💼 DEMO: CASOS DE USO PRÁTICOS")
    print("="*50)
    
    casos = [
        {
            'titulo': '🏢 Empresa de Trading',
            'descricao': 'Classificação automática de biblioteca com 500+ EAs',
            'beneficios': [
                'Organização automática por estratégia',
                'Identificação de EAs FTMO-ready',
                'Relatórios executivos para gestão',
                'Monitoramento de qualidade do código'
            ]
        },
        {
            'titulo': '👨‍💻 Desenvolvedor Individual',
            'descricao': 'Organização de códigos pessoais e análise de qualidade',
            'beneficios': [
                'Backup automático antes de modificações',
                'Análise de qualidade do código',
                'Identificação de padrões problemáticos',
                'Relatórios de progresso'
            ]
        },
        {
            'titulo': '🎓 Equipe de Pesquisa',
            'descricao': 'Análise de estratégias e backtesting automatizado',
            'beneficios': [
                'Classificação por tipo de estratégia',
                'Análise de compliance FTMO',
                'Relatórios científicos detalhados',
                'Monitoramento de experimentos'
            ]
        }
    ]
    
    for i, caso in enumerate(casos, 1):
        print(f"\n{i}. {caso['titulo']}")
        print(f"   📝 {caso['descricao']}")
        print("   ✅ Benefícios:")
        for beneficio in caso['beneficios']:
            print(f"      • {beneficio}")

def main():
    """
    Função principal da demonstração
    """
    print("🎬 DEMONSTRAÇÃO SISTEMA CLASSIFICADOR TRADING - PASSO 2")
    print("="*70)
    print(f"📅 Data: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
    print(f"🔧 Versão: 2.0")
    print(f"👨‍💻 Agente: Classificador_Trading")
    
    try:
        # Executar demonstrações
        result = demo_integracao_completa()
        demo_casos_de_uso()
        
        # Resultado final
        print("\n" + "="*70)
        print("🎉 DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO!")
        print("="*70)
        
        print(f"📊 Métricas coletadas: {result['dashboard_metrics']}")
        print(f"📄 Relatórios gerados: {result['reports_generated']}")
        print(f"💾 Dados processados: {result['total_size']:,} bytes")
        print(f"✅ Status: {result['status'].upper()}")
        
        print("\n🚀 O sistema está pronto para uso em produção!")
        print("\n📖 Para usar o sistema:")
        print("   1. Execute interface_classificador_lote.py para GUI")
        print("   2. Use classificador_lote_avancado.py para processamento")
        print("   3. Monitore com monitor_tempo_real.py")
        print("   4. Gere relatórios com gerador_relatorios_avancados.py")
        
    except KeyboardInterrupt:
        print("\n⏹️ Demonstração interrompida pelo usuário")
    except Exception as e:
        print(f"\n❌ Erro durante demonstração: {e}")
        print("\n🔧 Verifique se todos os módulos estão no diretório Core/")

if __name__ == "__main__":
    main()