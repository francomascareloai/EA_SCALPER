"""
Módulo para validação de entradas do usuário
"""

def validate_input(value_str):
    """
    Valida e converte uma string para float positivo
    
    Args:
        value_str (str): String a ser validada e convertida
        
    Returns:
        float: Valor convertido para float
        
    Raises:
        ValueError: Se a string não puder ser convertida para float positivo
    """
    # Remover espaços em branco
    value_str = value_str.strip()
    
    # Verificar se a string está vazia
    if not value_str:
        raise ValueError("Valor não pode ser vazio")
    
    try:
        # Converter para float
        value = float(value_str)
    except ValueError:
        raise ValueError("Valor deve ser um número válido")
    
    # Verificar se é positivo
    if value <= 0:
        raise ValueError("Valor deve ser maior que zero")
    
    return value


def get_valid_input(prompt, max_attempts=3):
    """
    Solicita entrada do usuário com validação
    
    Args:
        prompt (str): Mensagem para solicitar entrada
        max_attempts (int): Número máximo de tentativas
        
    Returns:
        float: Valor válido inserido pelo usuário
    """
    attempts = 0
    
    while attempts < max_attempts:
        try:
            value_str = input(prompt)
            return validate_input(value_str)
        except ValueError as e:
            attempts += 1
            print(f"Erro: {e}")
            if attempts < max_attempts:
                print(f"Tentativas restantes: {max_attempts - attempts}")
            else:
                print("Número máximo de tentativas excedido")
                raise