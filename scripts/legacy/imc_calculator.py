"""
Módulo para cálculo e classificação do IMC (Índice de Massa Corporal)
"""

def calculate_imc(peso, altura):
    """
    Calcula o Índice de Massa Corporal (IMC)
    
    Args:
        peso (float): Peso em quilogramas
        altura (float): Altura em metros
        
    Returns:
        float: Valor do IMC calculado
        
    Raises:
        ValueError: Se peso ou altura forem menores ou iguais a zero
        TypeError: Se peso ou altura não forem números
    """
    # Validação de tipo
    if not isinstance(peso, (int, float)) or not isinstance(altura, (int, float)):
        raise TypeError("Peso e altura devem ser números")
    
    # Validação de valores positivos
    if peso <= 0:
        raise ValueError("Peso deve ser maior que zero")
    
    if altura <= 0:
        raise ValueError("Altura deve ser maior que zero")
    
    # Cálculo do IMC
    imc = peso / (altura ** 2)
    return imc


def classify_imc(imc):
    """
    Classifica o IMC em categorias
    
    Args:
        imc (float): Valor do IMC calculado
        
    Returns:
        str: Categoria do IMC
        
    Raises:
        ValueError: Se IMC for menor ou igual a zero
        TypeError: Se IMC não for um número
    """
    # Validação de tipo
    if not isinstance(imc, (int, float)):
        raise TypeError("IMC deve ser um número")
    
    # Validação de valor positivo
    if imc <= 0:
        raise ValueError("IMC deve ser maior que zero")
    
    # Classificação do IMC
    if imc < 18.5:
        return "Baixo peso"
    elif 18.5 <= imc < 25.0:
        return "Peso normal"
    elif 25.0 <= imc < 30.0:
        return "Sobrepeso"
    else:  # imc >= 30.0
        return "Obesidade"