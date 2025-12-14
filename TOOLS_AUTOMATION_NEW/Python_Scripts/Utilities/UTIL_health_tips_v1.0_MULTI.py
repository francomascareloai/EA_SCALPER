"""
Módulo para geração de dicas de saúde baseadas na classificação do IMC
"""

def get_health_tips(classification):
    """
    Retorna dicas de saúde baseadas na classificação do IMC
    
    Args:
        classification (str): Classificação do IMC
        
    Returns:
        str: Dicas de saúde apropriadas
    """
    tips = {
        "Baixo peso": [
            "Procure um nutricionista para avaliar sua alimentação",
            "Inclua alimentos ricos em proteínas e carboidratos saudáveis",
            "Considere fazer refeições menores mas mais frequentes",
            "Evite pular refeições"
        ],
        "Peso normal": [
            "Parabéns! Mantenha seus hábitos saudáveis",
            "Continue com uma alimentação equilibrada",
            "Pratique atividades físicas regularmente",
            "Mantenha consultas regulares com seu médico"
        ],
        "Sobrepeso": [
            "Considere consultar um nutricionista",
            "Inclua mais frutas, vegetais e grãos integrais na sua dieta",
            "Reduza o consumo de alimentos processados",
            "Aumente sua atividade física gradualmente"
        ],
        "Obesidade": [
            "Procure orientação médica especializada",
            "Trabalhe com um nutricionista para criar um plano alimentar",
            "Inicie atividades físicas com orientação profissional",
            "Considere o apoio de grupos de suporte"
        ]
    }
    
    # Verificar se a classificação existe nas dicas
    if classification in tips:
        tip_list = tips[classification]
        # Formatar as dicas como uma lista numerada
        formatted_tips = "\n".join([f"{i+1}. {tip}" for i, tip in enumerate(tip_list)])
        return f"Dicas para {classification.lower()}:\n{formatted_tips}"
    else:
        return "Classificação não reconhecida. Consulte um profissional de saúde."