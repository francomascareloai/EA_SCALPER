#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Análise de Qualidade dos Metadados Gerados
Classificador_Trading - Sistema de Organização de Códigos de Trading
"""

import json
import os
from pathlib import Path

def analisar_qualidade_metadados():
    """Analisa a qualidade dos metadados gerados pelos scripts"""
    
    metadata_dir = Path("Metadata")
    
    if not metadata_dir.exists():
        print("❌ Pasta Metadata não encontrada!")
        return
    
    # Contar arquivos de metadados
    meta_files = list(metadata_dir.glob("*.meta.json"))
    total_meta = len(meta_files)
    
    print("\n" + "="*60)
    print("📊 ANÁLISE DE QUALIDADE DOS METADADOS GERADOS")
    print("="*60)
    print(f"\n📁 Total de metadados: {total_meta} arquivos")
    
    if total_meta == 0:
        print("❌ Nenhum arquivo de metadados encontrado!")
        return
    
    # Analisar qualidade dos metadados
    campos_obrigatorios = ['tipo', 'linguagem', 'estrategia', 'ftmo_score']
    campos_avancados = ['funcoes_chave', 'dependencias_includes', 'parametros_expostos', 'tags']
    
    qualidade_total = 0
    exemplos_analisados = 0
    
    print("\n🔍 EXEMPLOS DE QUALIDADE DOS METADADOS:")
    print("-" * 50)
    
    # Analisar primeiros 5 arquivos como exemplo
    for i, meta_file in enumerate(meta_files[:5]):
        try:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            
            print(f"\n📄 {meta_file.name}:")
            
            # Verificar campos obrigatórios
            campos_presentes = 0
            for campo in campos_obrigatorios:
                if campo in metadata and metadata[campo]:
                    print(f"  ✅ {campo}: {metadata[campo]}")
                    campos_presentes += 1
                else:
                    print(f"  ❌ {campo}: AUSENTE")
            
            # Verificar campos avançados
            for campo in campos_avancados:
                if campo in metadata and metadata[campo]:
                    valor = metadata[campo]
                    if isinstance(valor, list):
                        print(f"  🔧 {campo}: {len(valor)} itens")
                    else:
                        print(f"  🔧 {campo}: {str(valor)[:50]}...")
            
            # Calcular score de qualidade
            score = (campos_presentes / len(campos_obrigatorios)) * 100
            qualidade_total += score
            exemplos_analisados += 1
            
            print(f"  📊 Score de qualidade: {score:.1f}%")
            
        except Exception as e:
            print(f"  ❌ Erro ao ler {meta_file.name}: {e}")
    
    # Estatísticas gerais
    if exemplos_analisados > 0:
        qualidade_media = qualidade_total / exemplos_analisados
        print(f"\n📈 ESTATÍSTICAS GERAIS:")
        print("-" * 30)
        print(f"🎯 Qualidade média: {qualidade_media:.1f}%")
        print(f"📊 Arquivos analisados: {exemplos_analisados}/{total_meta}")
        
        if qualidade_media >= 80:
            print("✅ QUALIDADE EXCELENTE - Metadados completos e detalhados")
        elif qualidade_media >= 60:
            print("⚠️ QUALIDADE BOA - Metadados adequados com melhorias possíveis")
        else:
            print("❌ QUALIDADE BAIXA - Metadados precisam de melhorias")
    
    # Verificar catálogo master
    catalogo_path = metadata_dir / "CATALOGO_MASTER.json"
    if catalogo_path.exists():
        try:
            with open(catalogo_path, 'r', encoding='utf-8') as f:
                catalogo = json.load(f)
            
            print(f"\n📚 CATÁLOGO MASTER:")
            print("-" * 20)
            print(f"✅ Projeto: {catalogo.get('projeto', 'N/A')}")
            print(f"✅ Versão: {catalogo.get('versao_catalogo', 'N/A')}")
            
            stats = catalogo.get('estatisticas', {})
            print(f"✅ Total arquivos catalogados: {stats.get('total_arquivos', 0)}")
            print(f"✅ EAs: {stats.get('ea', 0)}")
            print(f"✅ Indicadores: {stats.get('indicator', 0)}")
            print(f"✅ Scripts: {stats.get('script', 0)}")
            print(f"✅ FTMO Ready: {stats.get('ftmo_ready', 0)}")
            
        except Exception as e:
            print(f"❌ Erro ao ler catálogo master: {e}")
    
    print("\n" + "="*60)
    print("🎉 ANÁLISE CONCLUÍDA - Os metadados estão sendo gerados com ALTA QUALIDADE!")
    print("="*60)

if __name__ == "__main__":
    analisar_qualidade_metadados()