#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema de Múltiplos Agentes Avaliadores
Versão: 1.0
Data: 12/08/2025

Sistema de avaliação multi-dimensional com agentes especializados
para análise contínua e otimização do processo de classificação de EAs.
"""

import json
import logging
import time
from datetime import datetime
from typing import Dict, List, Any, Optional
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

@dataclass
class AgentScore:
    """Estrutura para scores de agentes"""
    category: str
    score: float
    max_score: float
    details: str
    recommendations: List[str]

@dataclass
class EvaluationResult:
    """Resultado de avaliação de um agente"""
    agent_name: str
    overall_score: float
    scores: List[AgentScore]
    critical_issues: List[str]
    recommendations: List[str]
    timestamp: str

class BaseAgent(ABC):
    """Classe base para todos os agentes avaliadores"""
    
    def __init__(self, name: str, expertise: str, weight: float = 1.0):
        self.name = name
        self.expertise = expertise
        self.weight = weight
        self.logger = logging.getLogger(f"Agent.{name}")
        
    @abstractmethod
    def evaluate(self, data: Dict[str, Any]) -> EvaluationResult:
        """Método principal de avaliação - deve ser implementado por cada agente"""
        pass
    
    def _calculate_weighted_score(self, scores: List[AgentScore]) -> float:
        """Calcula score ponderado"""
        if not scores:
            return 0.0
        
        total_weight = sum(score.max_score for score in scores)
        if total_weight == 0:
            return 0.0
            
        weighted_sum = sum(score.score * (score.max_score / total_weight) for score in scores)
        return min(10.0, weighted_sum)

class ArchitectAgent(BaseAgent):
    """Agente Arquiteto - Avalia estrutura e escalabilidade"""
    
    def __init__(self):
        super().__init__("Architect", "Estrutura e Escalabilidade", weight=0.15)
    
    def evaluate(self, data: Dict[str, Any]) -> EvaluationResult:
        self.logger.info("🏛️ Iniciando avaliação arquitetural...")
        
        scores = []
        critical_issues = []
        recommendations = []
        
        # Avaliação de Escalabilidade
        scalability_score = self._evaluate_scalability(data)
        scores.append(AgentScore(
            "Escalabilidade", scalability_score, 10.0,
            "Capacidade do sistema de crescer e se adaptar",
            ["Implementar cache para metadados", "Otimizar estrutura de pastas"]
        ))
        
        # Avaliação de Manutenibilidade
        maintainability_score = self._evaluate_maintainability(data)
        scores.append(AgentScore(
            "Manutenibilidade", maintainability_score, 10.0,
            "Facilidade de manutenção e evolução do código",
            ["Adicionar mais documentação", "Implementar testes unitários"]
        ))
        
        # Avaliação de Eficiência
        efficiency_score = self._evaluate_efficiency(data)
        scores.append(AgentScore(
            "Eficiência", efficiency_score, 10.0,
            "Performance e uso otimizado de recursos",
            ["Otimizar algoritmos de classificação", "Implementar processamento paralelo"]
        ))
        
        # Avaliação de Padrões
        patterns_score = self._evaluate_patterns(data)
        scores.append(AgentScore(
            "Padrões", patterns_score, 10.0,
            "Conformidade com best practices",
            ["Padronizar nomenclatura", "Implementar design patterns"]
        ))
        
        overall_score = self._calculate_weighted_score(scores)
        
        if overall_score < 6.0:
            critical_issues.append("Arquitetura precisa de revisão significativa")
        
        return EvaluationResult(
            agent_name=self.name,
            overall_score=overall_score,
            scores=scores,
            critical_issues=critical_issues,
            recommendations=recommendations,
            timestamp=datetime.now().isoformat()
        )
    
    def _evaluate_scalability(self, data: Dict[str, Any]) -> float:
        """Avalia escalabilidade do sistema"""
        score = 7.0  # Base score
        
        # Verifica estrutura de pastas
        if 'folder_structure' in data:
            score += 1.0
        
        # Verifica sistema de metadados
        if 'metadata_system' in data:
            score += 1.0
        
        # Verifica capacidade de processamento
        files_processed = data.get('files_processed', 0)
        if files_processed > 100:
            score += 1.0
        
        return min(10.0, score)
    
    def _evaluate_maintainability(self, data: Dict[str, Any]) -> float:
        """Avalia manutenibilidade"""
        score = 6.0  # Base score
        
        # Verifica documentação
        if data.get('documentation_quality', 0) > 7:
            score += 2.0
        
        # Verifica modularidade
        if data.get('modular_design', False):
            score += 1.0
        
        # Verifica testes
        if data.get('has_tests', False):
            score += 1.0
        
        return min(10.0, score)
    
    def _evaluate_efficiency(self, data: Dict[str, Any]) -> float:
        """Avalia eficiência"""
        score = 8.0  # Base score
        
        # Verifica tempo de processamento
        processing_time = data.get('processing_time', 0)
        if processing_time < 5.0:  # Menos de 5 segundos
            score += 1.0
        elif processing_time > 30.0:  # Mais de 30 segundos
            score -= 2.0
        
        # Verifica uso de memória
        memory_efficient = data.get('memory_efficient', True)
        if memory_efficient:
            score += 1.0
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_patterns(self, data: Dict[str, Any]) -> float:
        """Avalia conformidade com padrões"""
        score = 7.0  # Base score
        
        # Verifica nomenclatura
        if data.get('naming_convention_compliance', 0) > 8:
            score += 1.5
        
        # Verifica estrutura de código
        if data.get('code_structure_quality', 0) > 8:
            score += 1.5
        
        return min(10.0, score)

class FTMOTraderAgent(BaseAgent):
    """Agente Trader FTMO - Especialista em conformidade FTMO"""
    
    def __init__(self):
        super().__init__("FTMO_Trader", "Conformidade FTMO", weight=0.20)
    
    def evaluate(self, data: Dict[str, Any]) -> EvaluationResult:
        self.logger.info("📊 Iniciando avaliação FTMO...")
        
        scores = []
        critical_issues = []
        recommendations = []
        
        # Avaliação de Conformidade FTMO
        ftmo_compliance = self._evaluate_ftmo_compliance(data)
        scores.append(AgentScore(
            "Conformidade FTMO", ftmo_compliance, 10.0,
            "Aderência às regras FTMO Challenge",
            ["Implementar proteção de drawdown", "Validar gestão de risco"]
        ))
        
        # Avaliação de Gestão de Risco
        risk_management = self._evaluate_risk_management(data)
        scores.append(AgentScore(
            "Gestão de Risco", risk_management, 10.0,
            "Qualidade da gestão de risco implementada",
            ["Adicionar stop loss obrigatório", "Implementar trailing stop"]
        ))
        
        # Avaliação de Probabilidade de Aprovação
        approval_probability = self._evaluate_approval_probability(data)
        scores.append(AgentScore(
            "Prob. Aprovação", approval_probability, 10.0,
            "Probabilidade de aprovação no FTMO Challenge",
            ["Otimizar risk/reward", "Adicionar filtros de mercado"]
        ))
        
        # Avaliação de Sustentabilidade
        sustainability = self._evaluate_sustainability(data)
        scores.append(AgentScore(
            "Sustentabilidade", sustainability, 10.0,
            "Capacidade de manter performance consistente",
            ["Implementar filtros de volatilidade", "Adicionar proteções adicionais"]
        ))
        
        overall_score = self._calculate_weighted_score(scores)
        
        # Verificações críticas
        if ftmo_compliance < 7.0:
            critical_issues.append("❌ CRÍTICO: Conformidade FTMO insuficiente")
        
        if risk_management < 6.0:
            critical_issues.append("❌ CRÍTICO: Gestão de risco inadequada")
        
        return EvaluationResult(
            agent_name=self.name,
            overall_score=overall_score,
            scores=scores,
            critical_issues=critical_issues,
            recommendations=recommendations,
            timestamp=datetime.now().isoformat()
        )
    
    def _evaluate_ftmo_compliance(self, data: Dict[str, Any]) -> float:
        """Avalia conformidade FTMO"""
        score = 0.0
        
        # Verifica EAs FTMO Ready
        ftmo_ready_count = data.get('ftmo_ready_count', 0)
        total_eas = data.get('total_eas', 1)
        
        ftmo_ratio = ftmo_ready_count / total_eas if total_eas > 0 else 0
        score += ftmo_ratio * 6.0
        
        # Verifica ausência de estratégias proibidas
        prohibited_strategies = data.get('prohibited_strategies_count', 0)
        if prohibited_strategies == 0:
            score += 2.0
        else:
            score -= prohibited_strategies * 0.5
        
        # Verifica implementação de proteções
        protections = data.get('protection_features', [])
        score += len(protections) * 0.5
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_risk_management(self, data: Dict[str, Any]) -> float:
        """Avalia gestão de risco"""
        score = 0.0
        
        # Verifica presença de stop loss
        stop_loss_count = data.get('stop_loss_count', 0)
        total_eas = data.get('total_eas', 1)
        
        if stop_loss_count == total_eas:
            score += 3.0
        else:
            score += (stop_loss_count / total_eas) * 3.0
        
        # Verifica risk/reward
        avg_risk_reward = data.get('avg_risk_reward', 0)
        if avg_risk_reward >= 3.0:
            score += 3.0
        elif avg_risk_reward >= 2.0:
            score += 2.0
        elif avg_risk_reward >= 1.5:
            score += 1.0
        
        # Verifica proteção de drawdown
        drawdown_protection = data.get('drawdown_protection_count', 0)
        score += (drawdown_protection / total_eas) * 2.0
        
        # Verifica gestão de lote
        lot_management = data.get('lot_management_count', 0)
        score += (lot_management / total_eas) * 2.0
        
        return min(10.0, score)
    
    def _evaluate_approval_probability(self, data: Dict[str, Any]) -> float:
        """Avalia probabilidade de aprovação"""
        score = 5.0  # Base score
        
        # Baseado no score FTMO médio
        avg_ftmo_score = data.get('avg_ftmo_score', 0)
        if avg_ftmo_score >= 9.0:
            score += 3.0
        elif avg_ftmo_score >= 7.5:
            score += 2.0
        elif avg_ftmo_score >= 6.0:
            score += 1.0
        else:
            score -= 2.0
        
        # Verifica histórico de backtesting
        backtest_results = data.get('backtest_quality', 0)
        score += (backtest_results / 10.0) * 2.0
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_sustainability(self, data: Dict[str, Any]) -> float:
        """Avalia sustentabilidade"""
        score = 6.0  # Base score
        
        # Verifica diversificação de estratégias
        strategy_diversity = data.get('strategy_diversity', 0)
        score += strategy_diversity * 0.5
        
        # Verifica robustez
        robustness_score = data.get('robustness_score', 0)
        score += (robustness_score / 10.0) * 2.0
        
        # Verifica adaptabilidade
        adaptability = data.get('adaptability_score', 0)
        score += (adaptability / 10.0) * 2.0
        
        return min(10.0, score)

class CodeAnalystAgent(BaseAgent):
    """Agente Analista de Código - Especialista em qualidade técnica"""
    
    def __init__(self):
        super().__init__("Code_Analyst", "Qualidade de Código", weight=0.15)
    
    def evaluate(self, data: Dict[str, Any]) -> EvaluationResult:
        self.logger.info("🔍 Iniciando análise de código...")
        
        scores = []
        critical_issues = []
        recommendations = []
        
        # Avaliação de Qualidade do Código
        code_quality = self._evaluate_code_quality(data)
        scores.append(AgentScore(
            "Qualidade Código", code_quality, 10.0,
            "Qualidade geral do código fonte",
            ["Refatorar funções complexas", "Adicionar comentários"]
        ))
        
        # Avaliação de Performance
        performance = self._evaluate_performance(data)
        scores.append(AgentScore(
            "Performance", performance, 10.0,
            "Eficiência algorítmica e otimização",
            ["Otimizar loops", "Implementar cache"]
        ))
        
        # Avaliação de Segurança
        security = self._evaluate_security(data)
        scores.append(AgentScore(
            "Segurança", security, 10.0,
            "Segurança e robustez do código",
            ["Validar inputs", "Implementar error handling"]
        ))
        
        # Avaliação de Reutilização
        reusability = self._evaluate_reusability(data)
        scores.append(AgentScore(
            "Reutilização", reusability, 10.0,
            "Capacidade de reutilização de componentes",
            ["Extrair mais snippets", "Modularizar código"]
        ))
        
        overall_score = self._calculate_weighted_score(scores)
        
        if code_quality < 5.0:
            critical_issues.append("❌ CRÍTICO: Qualidade de código muito baixa")
        
        if security < 6.0:
            critical_issues.append("⚠️ ATENÇÃO: Problemas de segurança detectados")
        
        return EvaluationResult(
            agent_name=self.name,
            overall_score=overall_score,
            scores=scores,
            critical_issues=critical_issues,
            recommendations=recommendations,
            timestamp=datetime.now().isoformat()
        )
    
    def _evaluate_code_quality(self, data: Dict[str, Any]) -> float:
        """Avalia qualidade do código"""
        score = 5.0  # Base score
        
        # Verifica encoding corrigido
        encoding_corrections = data.get('encoding_corrections', 0)
        total_files = data.get('total_files', 1)
        
        encoding_ratio = 1.0 - (encoding_corrections / total_files)
        score += encoding_ratio * 2.0
        
        # Verifica validações
        validation_score = data.get('avg_validation_score', 0)
        score += (validation_score / 10.0) * 2.0
        
        # Verifica complexidade
        complexity_score = data.get('complexity_score', 5)
        if complexity_score <= 3:
            score += 1.0
        elif complexity_score >= 8:
            score -= 1.0
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_performance(self, data: Dict[str, Any]) -> float:
        """Avalia performance"""
        score = 7.0  # Base score
        
        # Verifica tempo de processamento
        processing_time = data.get('avg_processing_time', 0)
        if processing_time < 1.0:
            score += 2.0
        elif processing_time > 10.0:
            score -= 3.0
        
        # Verifica otimizações aplicadas
        optimizations = data.get('optimizations_applied', 0)
        score += optimizations * 0.5
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_security(self, data: Dict[str, Any]) -> float:
        """Avalia segurança"""
        score = 8.0  # Base score
        
        # Verifica vulnerabilidades detectadas
        vulnerabilities = data.get('vulnerabilities_detected', 0)
        score -= vulnerabilities * 1.0
        
        # Verifica validações de input
        input_validations = data.get('input_validations', 0)
        score += input_validations * 0.5
        
        return max(0.0, min(10.0, score))
    
    def _evaluate_reusability(self, data: Dict[str, Any]) -> float:
        """Avalia reutilização"""
        score = 6.0  # Base score
        
        # Verifica snippets extraídos
        snippets_count = data.get('snippets_extracted', 0)
        score += snippets_count * 0.3
        
        # Verifica componentes úteis
        useful_components = data.get('useful_components', 0)
        score += useful_components * 0.2
        
        return min(10.0, score)

class MultiAgentEvaluator:
    """Orquestrador central do sistema de múltiplos agentes"""
    
    def __init__(self):
        self.agents = [
            ArchitectAgent(),
            FTMOTraderAgent(),
            CodeAnalystAgent()
            # Outros agentes serão adicionados posteriormente
        ]
        self.logger = logging.getLogger("MultiAgentEvaluator")
        
    def evaluate_system(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Executa avaliação completa com todos os agentes"""
        self.logger.info("🚀 Iniciando avaliação multi-agente...")
        
        start_time = time.time()
        results = []
        
        # Executa cada agente
        for agent in self.agents:
            try:
                result = agent.evaluate(data)
                results.append(result)
                self.logger.info(f"✅ {agent.name}: {result.overall_score:.1f}/10.0")
            except Exception as e:
                self.logger.error(f"❌ Erro no agente {agent.name}: {e}")
        
        # Calcula score unificado
        unified_score = self._calculate_unified_score(results)
        
        # Gera relatório consolidado
        evaluation_time = time.time() - start_time
        
        return {
            'timestamp': datetime.now().isoformat(),
            'evaluation_time': evaluation_time,
            'unified_score': unified_score,
            'classification': self._classify_system(unified_score),
            'agent_results': [self._result_to_dict(result) for result in results],
            'critical_issues': self._consolidate_critical_issues(results),
            'top_recommendations': self._consolidate_recommendations(results),
            'summary': self._generate_summary(unified_score, results)
        }
    
    def _calculate_unified_score(self, results: List[EvaluationResult]) -> float:
        """Calcula score unificado ponderado"""
        if not results:
            return 0.0
        
        total_weight = sum(agent.weight for agent in self.agents)
        weighted_sum = 0.0
        
        for i, result in enumerate(results):
            if i < len(self.agents):
                weight = self.agents[i].weight
                weighted_sum += result.overall_score * weight
        
        return weighted_sum / total_weight if total_weight > 0 else 0.0
    
    def _classify_system(self, score: float) -> str:
        """Classifica o sistema baseado no score"""
        if score >= 9.0:
            return "🏆 ELITE"
        elif score >= 8.0:
            return "🥇 EXCELENTE"
        elif score >= 7.0:
            return "🥈 BOM"
        elif score >= 6.0:
            return "🥉 ACEITÁVEL"
        else:
            return "❌ INADEQUADO"
    
    def _consolidate_critical_issues(self, results: List[EvaluationResult]) -> List[str]:
        """Consolida issues críticos de todos os agentes"""
        all_issues = []
        for result in results:
            all_issues.extend(result.critical_issues)
        return list(set(all_issues))  # Remove duplicatas
    
    def _consolidate_recommendations(self, results: List[EvaluationResult]) -> List[str]:
        """Consolida recomendações prioritárias"""
        all_recommendations = []
        for result in results:
            all_recommendations.extend(result.recommendations)
        
        # Retorna top 10 recomendações únicas
        unique_recommendations = list(set(all_recommendations))
        return unique_recommendations[:10]
    
    def _generate_summary(self, score: float, results: List[EvaluationResult]) -> str:
        """Gera resumo executivo"""
        classification = self._classify_system(score)
        agent_count = len(results)
        critical_count = len(self._consolidate_critical_issues(results))
        
        return f"Sistema avaliado por {agent_count} agentes especializados. " \
               f"Score unificado: {score:.1f}/10.0 ({classification}). " \
               f"Issues críticos detectados: {critical_count}."
    
    def _result_to_dict(self, result: EvaluationResult) -> Dict[str, Any]:
        """Converte resultado para dicionário"""
        return {
            'agent_name': result.agent_name,
            'overall_score': result.overall_score,
            'scores': [{
                'category': score.category,
                'score': score.score,
                'max_score': score.max_score,
                'details': score.details,
                'recommendations': score.recommendations
            } for score in result.scores],
            'critical_issues': result.critical_issues,
            'recommendations': result.recommendations,
            'timestamp': result.timestamp
        }
    
    def save_report(self, evaluation_result: Dict[str, Any], output_path: str) -> None:
        """Salva relatório de avaliação"""
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(evaluation_result, f, indent=2, ensure_ascii=False)
            self.logger.info(f"📋 Relatório salvo: {output_path}")
        except Exception as e:
            self.logger.error(f"❌ Erro ao salvar relatório: {e}")

# Função principal para teste
def main():
    """Função principal para demonstração"""
    # Dados de exemplo para teste
    test_data = {
        'files_processed': 6,
        'total_files': 6,
        'total_eas': 4,
        'ftmo_ready_count': 2,
        'prohibited_strategies_count': 2,
        'stop_loss_count': 3,
        'avg_ftmo_score': 5.0,
        'avg_risk_reward': 2.5,
        'processing_time': 3.2,
        'encoding_corrections': 1,
        'snippets_extracted': 5,
        'useful_components': 8
    }
    
    # Executa avaliação
    evaluator = MultiAgentEvaluator()
    result = evaluator.evaluate_system(test_data)
    
    # Salva relatório
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"multi_agent_evaluation_{timestamp}.json"
    evaluator.save_report(result, output_file)
    
    # Exibe resumo
    print("\n" + "="*60)
    print("🤖 AVALIAÇÃO MULTI-AGENTE CONCLUÍDA")
    print("="*60)
    print(f"📊 Score Unificado: {result['unified_score']:.1f}/10.0")
    print(f"🏆 Classificação: {result['classification']}")
    print(f"⏱️ Tempo de Avaliação: {result['evaluation_time']:.2f}s")
    print(f"📋 Relatório: {output_file}")
    print("\n💡 Resumo:")
    print(result['summary'])
    
    if result['critical_issues']:
        print("\n❌ Issues Críticos:")
        for issue in result['critical_issues']:
            print(f"  • {issue}")
    
    print("\n🚀 Top Recomendações:")
    for i, rec in enumerate(result['top_recommendations'][:5], 1):
        print(f"  {i}. {rec}")

if __name__ == "__main__":
    main()