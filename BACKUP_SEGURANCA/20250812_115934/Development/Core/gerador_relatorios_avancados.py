#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
📊 GERADOR DE RELATÓRIOS AVANÇADOS - PASSO 2
Sistema de geração de relatórios detalhados e análises estatísticas

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Recursos:
- Relatórios HTML interativos
- Gráficos e visualizações
- Análises estatísticas avançadas
- Comparações temporais
- Exportação em múltiplos formatos
- Dashboard executivo
"""

import os
import json
import csv
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from pathlib import Path
import base64
from io import BytesIO

class GeradorRelatoriosAvancados:
    """
    Gerador de relatórios avançados com múltiplos formatos
    """
    
    def __init__(self, output_dir: str = "Development/Reports"):
        self.output_dir = output_dir
        self.ensure_directories()
        
    def ensure_directories(self):
        """Garante que os diretórios de saída existam"""
        dirs = [
            f"{self.output_dir}/HTML",
            f"{self.output_dir}/CSV",
            f"{self.output_dir}/JSON",
            f"{self.output_dir}/Executive"
        ]
        
        for dir_path in dirs:
            os.makedirs(dir_path, exist_ok=True)
            
    def generate_comprehensive_report(self, data: Dict, report_type: str = "full") -> Dict[str, str]:
        """Gera relatório abrangente em múltiplos formatos"""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_name = f"relatorio_completo_{timestamp}"
        
        generated_files = {}
        
        try:
            # Relatório HTML interativo
            if report_type in ["full", "html"]:
                html_file = self._generate_html_report(data, base_name)
                generated_files['html'] = html_file
                
            # Relatório CSV para análise
            if report_type in ["full", "csv"]:
                csv_file = self._generate_csv_report(data, base_name)
                generated_files['csv'] = csv_file
                
            # Relatório JSON estruturado
            if report_type in ["full", "json"]:
                json_file = self._generate_json_report(data, base_name)
                generated_files['json'] = json_file
                
            # Dashboard executivo
            if report_type in ["full", "executive"]:
                exec_file = self._generate_executive_dashboard(data, base_name)
                generated_files['executive'] = exec_file
                
            return generated_files
            
        except Exception as e:
            raise Exception(f"Erro ao gerar relatórios: {str(e)}")
            
    def _generate_html_report(self, data: Dict, base_name: str) -> str:
        """Gera relatório HTML interativo"""
        
        html_content = self._create_html_template(data)
        
        filename = f"{self.output_dir}/HTML/{base_name}.html"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(html_content)
            
        return filename
        
    def _create_html_template(self, data: Dict) -> str:
        """Cria template HTML com dados"""
        
        stats = data.get('statistics', {})
        performance = data.get('performance', {})
        categories = data.get('top_categories', [])
        quality = data.get('quality_summary', {})
        ftmo = data.get('ftmo_summary', {})
        
        # Gerar gráficos em base64 (simulado)
        charts_html = self._generate_charts_html(data)
        
        html = f"""
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 Relatório de Classificação Trading</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        .header h1 {{
            margin: 0;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        .header .subtitle {{
            margin-top: 10px;
            opacity: 0.9;
            font-size: 1.1em;
        }}
        .content {{
            padding: 30px;
        }}
        .metrics-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .metric-card {{
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            border-left: 5px solid #3498db;
            transition: transform 0.3s ease;
        }}
        .metric-card:hover {{
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }}
        .metric-value {{
            font-size: 2.5em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
        }}
        .metric-label {{
            color: #7f8c8d;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        .section {{
            margin-bottom: 40px;
        }}
        .section-title {{
            font-size: 1.8em;
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }}
        .table {{
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .table th {{
            background: #34495e;
            color: white;
            padding: 15px;
            text-align: left;
        }}
        .table td {{
            padding: 12px 15px;
            border-bottom: 1px solid #ecf0f1;
        }}
        .table tr:hover {{
            background: #f8f9fa;
        }}
        .progress-bar {{
            background: #ecf0f1;
            border-radius: 10px;
            height: 20px;
            overflow: hidden;
            margin: 5px 0;
        }}
        .progress-fill {{
            height: 100%;
            background: linear-gradient(90deg, #3498db, #2ecc71);
            transition: width 0.3s ease;
        }}
        .chart-container {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }}
        .footer {{
            background: #34495e;
            color: white;
            text-align: center;
            padding: 20px;
            margin-top: 40px;
        }}
        .status-badge {{
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
            text-transform: uppercase;
        }}
        .status-success {{ background: #2ecc71; color: white; }}
        .status-warning {{ background: #f39c12; color: white; }}
        .status-danger {{ background: #e74c3c; color: white; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Relatório de Classificação Trading</h1>
            <div class="subtitle">
                Gerado em {datetime.now().strftime('%d/%m/%Y às %H:%M:%S')}<br>
                Tempo de execução: {data.get('execution_time', 0):.2f}s
            </div>
        </div>
        
        <div class="content">
            <!-- Métricas Principais -->
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-value">{stats.get('processed', 0)}</div>
                    <div class="metric-label">Arquivos Processados</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{stats.get('successful', 0)}</div>
                    <div class="metric-label">Sucessos</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{performance.get('files_per_second', 0):.1f}</div>
                    <div class="metric-label">Arquivos/Segundo</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{performance.get('success_rate', 0):.1f}%</div>
                    <div class="metric-label">Taxa de Sucesso</div>
                </div>
            </div>
            
            <!-- Distribuição por Categorias -->
            <div class="section">
                <h2 class="section-title">🏷️ Distribuição por Categorias</h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Categoria</th>
                            <th>Quantidade</th>
                            <th>Percentual</th>
                            <th>Progresso</th>
                        </tr>
                    </thead>
                    <tbody>
"""
        
        # Adicionar categorias
        total_processed = stats.get('processed', 1)
        for category, count in categories:
            percentage = (count / total_processed) * 100
            html += f"""
                        <tr>
                            <td>{category}</td>
                            <td>{count}</td>
                            <td>{percentage:.1f}%</td>
                            <td>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: {percentage}%"></div>
                                </div>
                            </td>
                        </tr>
"""
        
        html += f"""
                    </tbody>
                </table>
            </div>
            
            <!-- Distribuição de Qualidade -->
            <div class="section">
                <h2 class="section-title">⭐ Distribuição de Qualidade</h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Nível</th>
                            <th>Quantidade</th>
                            <th>Percentual</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
"""
        
        # Adicionar qualidade
        for level, count in quality.items():
            percentage = (count / total_processed) * 100
            status_class = "status-success" if level in ["High", "Medium"] else "status-warning" if level == "Low" else "status-danger"
            html += f"""
                        <tr>
                            <td>{level}</td>
                            <td>{count}</td>
                            <td>{percentage:.1f}%</td>
                            <td><span class="status-badge {status_class}">{level}</span></td>
                        </tr>
"""
        
        html += f"""
                    </tbody>
                </table>
            </div>
            
            <!-- FTMO Compliance -->
            <div class="section">
                <h2 class="section-title">🎯 FTMO Compliance</h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Nível FTMO</th>
                            <th>Quantidade</th>
                            <th>Percentual</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
"""
        
        # Adicionar FTMO
        for level, count in ftmo.items():
            percentage = (count / total_processed) * 100
            status_class = "status-success" if "Ready" in level else "status-warning" if "Parcial" in level else "status-danger"
            html += f"""
                        <tr>
                            <td>{level}</td>
                            <td>{count}</td>
                            <td>{percentage:.1f}%</td>
                            <td><span class="status-badge {status_class}">{level}</span></td>
                        </tr>
"""
        
        # Adicionar recomendações
        recommendations = data.get('recommendations', [])
        if recommendations:
            html += f"""
                    </tbody>
                </table>
            </div>
            
            <!-- Recomendações -->
            <div class="section">
                <h2 class="section-title">💡 Recomendações</h2>
                <ul style="list-style: none; padding: 0;">
"""
            for rec in recommendations:
                html += f"<li style='padding: 10px; margin: 5px 0; background: #f8f9fa; border-left: 4px solid #3498db; border-radius: 5px;'>• {rec}</li>"
                
        html += f"""
                </ul>
            </div>
            
            {charts_html}
        </div>
        
        <div class="footer">
            <p>📊 Relatório gerado pelo Classificador Trading v2.0</p>
            <p>🔧 Sistema de Análise Avançada | Elite Performance</p>
        </div>
    </div>
</body>
</html>
"""
        
        return html
        
    def _generate_charts_html(self, data: Dict) -> str:
        """Gera HTML para gráficos (placeholder)"""
        return """
            <!-- Gráficos -->
            <div class="section">
                <h2 class="section-title">📈 Visualizações</h2>
                <div class="chart-container">
                    <h3>📊 Gráficos Interativos</h3>
                    <p>🚧 Gráficos interativos serão implementados na próxima versão</p>
                    <p>📈 Incluirá: Distribuição por categorias, Evolução temporal, Análise de qualidade</p>
                </div>
            </div>
"""
        
    def _generate_csv_report(self, data: Dict, base_name: str) -> str:
        """Gera relatório CSV para análise"""
        
        filename = f"{self.output_dir}/CSV/{base_name}.csv"
        
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            
            # Cabeçalho
            writer.writerow(['Métrica', 'Valor', 'Unidade', 'Observações'])
            
            # Estatísticas gerais
            stats = data.get('statistics', {})
            performance = data.get('performance', {})
            
            writer.writerow(['Arquivos Processados', stats.get('processed', 0), 'unidades', 'Total de arquivos analisados'])
            writer.writerow(['Sucessos', stats.get('successful', 0), 'unidades', 'Arquivos processados com sucesso'])
            writer.writerow(['Erros', stats.get('errors', 0), 'unidades', 'Arquivos com erro no processamento'])
            writer.writerow(['Taxa de Processamento', f"{performance.get('files_per_second', 0):.2f}", 'arquivos/s', 'Velocidade de processamento'])
            writer.writerow(['Taxa de Sucesso', f"{performance.get('success_rate', 0):.2f}", '%', 'Percentual de sucessos'])
            writer.writerow(['Tempo de Execução', f"{data.get('execution_time', 0):.2f}", 'segundos', 'Tempo total de processamento'])
            
            # Linha em branco
            writer.writerow([])
            
            # Categorias
            writer.writerow(['DISTRIBUIÇÃO POR CATEGORIAS'])
            writer.writerow(['Categoria', 'Quantidade', 'Percentual', 'Observações'])
            
            total = stats.get('processed', 1)
            for category, count in data.get('top_categories', []):
                percentage = (count / total) * 100
                writer.writerow([category, count, f"{percentage:.2f}%", ''])
                
        return filename
        
    def _generate_json_report(self, data: Dict, base_name: str) -> str:
        """Gera relatório JSON estruturado"""
        
        filename = f"{self.output_dir}/JSON/{base_name}.json"
        
        # Enriquecer dados com metadados
        enhanced_data = {
            'metadata': {
                'generated_at': datetime.now().isoformat(),
                'generator': 'Classificador Trading v2.0',
                'format_version': '2.0',
                'report_type': 'comprehensive_analysis'
            },
            'summary': {
                'total_files': data.get('statistics', {}).get('processed', 0),
                'success_rate': data.get('performance', {}).get('success_rate', 0),
                'processing_speed': data.get('performance', {}).get('files_per_second', 0),
                'execution_time': data.get('execution_time', 0)
            },
            'detailed_data': data
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(enhanced_data, f, indent=2, ensure_ascii=False)
            
        return filename
        
    def _generate_executive_dashboard(self, data: Dict, base_name: str) -> str:
        """Gera dashboard executivo resumido"""
        
        filename = f"{self.output_dir}/Executive/{base_name}_executive.html"
        
        stats = data.get('statistics', {})
        performance = data.get('performance', {})
        
        # KPIs principais
        total_files = stats.get('processed', 0)
        success_rate = performance.get('success_rate', 0)
        processing_speed = performance.get('files_per_second', 0)
        
        # Status geral
        overall_status = "🟢 EXCELENTE" if success_rate > 90 else "🟡 BOM" if success_rate > 70 else "🔴 ATENÇÃO"
        
        html = f"""
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 Dashboard Executivo - Classificação Trading</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f6fa;
        }}
        .dashboard {{
            max-width: 1000px;
            margin: 0 auto;
        }}
        .header {{
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 30px;
        }}
        .kpi-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .kpi-card {{
            background: white;
            border-radius: 10px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-left: 5px solid #3498db;
        }}
        .kpi-value {{
            font-size: 2.5em;
            font-weight: bold;
            color: #2c3e50;
        }}
        .kpi-label {{
            color: #7f8c8d;
            margin-top: 10px;
            text-transform: uppercase;
            font-size: 0.9em;
        }}
        .status-card {{
            background: white;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }}
        .status-value {{
            font-size: 3em;
            margin-bottom: 15px;
        }}
        .recommendations {{
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }}
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>📊 Dashboard Executivo</h1>
            <h2>Classificação Trading - Análise Completa</h2>
            <p>Gerado em {datetime.now().strftime('%d/%m/%Y às %H:%M:%S')}</p>
        </div>
        
        <div class="status-card">
            <div class="status-value">{overall_status}</div>
            <h3>Status Geral do Sistema</h3>
        </div>
        
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-value">{total_files}</div>
                <div class="kpi-label">Arquivos Processados</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">{success_rate:.1f}%</div>
                <div class="kpi-label">Taxa de Sucesso</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">{processing_speed:.1f}</div>
                <div class="kpi-label">Arquivos/Segundo</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">{data.get('execution_time', 0):.1f}s</div>
                <div class="kpi-label">Tempo Total</div>
            </div>
        </div>
        
        <div class="recommendations">
            <h3>💡 Principais Recomendações</h3>
            <ul>
"""
        
        # Adicionar recomendações principais
        recommendations = data.get('recommendations', [])
        if recommendations:
            for rec in recommendations[:3]:  # Top 3
                html += f"<li>{rec}</li>"
        else:
            html += "<li>✅ Sistema funcionando perfeitamente - nenhuma ação necessária</li>"
            
        html += """
            </ul>
        </div>
    </div>
</body>
</html>
"""
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(html)
            
        return filename
        
    def generate_comparison_report(self, current_data: Dict, previous_data: Dict = None) -> str:
        """Gera relatório comparativo entre execuções"""
        
        if not previous_data:
            return "Dados anteriores não disponíveis para comparação"
            
        # Implementar comparação temporal
        # TODO: Comparar métricas entre execuções
        pass
        
    def get_available_reports(self) -> List[Dict]:
        """Lista relatórios disponíveis"""
        
        reports = []
        
        for format_dir in ['HTML', 'CSV', 'JSON', 'Executive']:
            dir_path = f"{self.output_dir}/{format_dir}"
            if os.path.exists(dir_path):
                for file in os.listdir(dir_path):
                    if file.endswith(('.html', '.csv', '.json')):
                        file_path = os.path.join(dir_path, file)
                        stat = os.stat(file_path)
                        
                        reports.append({
                            'name': file,
                            'format': format_dir.lower(),
                            'path': file_path,
                            'size': stat.st_size,
                            'created': datetime.fromtimestamp(stat.st_ctime),
                            'modified': datetime.fromtimestamp(stat.st_mtime)
                        })
                        
        return sorted(reports, key=lambda x: x['modified'], reverse=True)

def main():
    """Função de teste"""
    print("📊 GERADOR DE RELATÓRIOS AVANÇADOS")
    print("="*50)
    
    # Dados de exemplo
    sample_data = {
        'execution_time': 45.67,
        'statistics': {
            'processed': 150,
            'successful': 142,
            'errors': 8
        },
        'performance': {
            'files_per_second': 3.29,
            'success_rate': 94.67,
            'error_rate': 5.33
        },
        'top_categories': [
            ('EA', 85),
            ('Indicator', 45),
            ('Script', 15),
            ('Unknown', 5)
        ],
        'quality_summary': {
            'High': 60,
            'Medium': 55,
            'Low': 25,
            'Unknown': 10
        },
        'ftmo_summary': {
            'FTMO_Ready': 25,
            'Parcialmente_Adequado': 45,
            'Não_Adequado': 80
        },
        'recommendations': [
            "⚠️ 5 arquivos não classificados (3.3%) - melhorar padrões de detecção",
            "🔍 80 arquivos não-FTMO (53.3%) - revisar estratégias de risco",
            "⚡ Performance adequada (3.3 arq/s) - sistema funcionando bem"
        ]
    }
    
    # Gerar relatórios
    generator = GeradorRelatoriosAvancados()
    
    try:
        files = generator.generate_comprehensive_report(sample_data, "full")
        
        print("✅ Relatórios gerados com sucesso:")
        for format_type, filepath in files.items():
            print(f"   📄 {format_type.upper()}: {filepath}")
            
        # Listar relatórios disponíveis
        available = generator.get_available_reports()
        print(f"\n📋 Total de relatórios disponíveis: {len(available)}")
        
    except Exception as e:
        print(f"❌ Erro: {str(e)}")
        
if __name__ == "__main__":
    main()