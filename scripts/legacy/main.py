"""
Calculadora de IMC (Índice de Massa Corporal)
Aplicação standalone para calcular e classificar o IMC com dicas de saúde
"""

import imc_calculator
import input_validator
import health_tips

def main():
    """
    Função principal que controla o fluxo da aplicação
    """
    print("=== Calculadora de IMC ===")
    print("Esta aplicação calcula seu Índice de Massa Corporal e fornece recomendações de saúde.\n")
    
    while True:
        try:
            # Solicitar peso do usuário
            peso = input_validator.get_valid_input("Digite seu peso (kg): ")
            
            # Solicitar altura do usuário
            altura = input_validator.get_valid_input("Digite sua altura (m): ")
            
            # Calcular IMC
            imc = imc_calculator.calculate_imc(peso, altura)
            
            # Classificar IMC
            classification = imc_calculator.classify_imc(imc)
            
            # Exibir resultados
            print("\n=== Resultados ===")
            print(f"Seu IMC é: {imc:.2f}")
            print(f"Classificação: {classification}")
            
            # Obter e exibir dicas de saúde
            tips = health_tips.get_health_tips(classification)
            print(f"\n{tips}")
            
            # Perguntar se deseja continuar
            print("\n" + "="*50)
            continuar = input("Deseja calcular novamente? (s/n): ").strip().lower()
            
            if continuar not in ['s', 'sim']:
                print("Obrigado por usar a Calculadora de IMC!")
                break
                
        except KeyboardInterrupt:
            print("\n\nPrograma interrompido pelo usuário.")
            break
        except Exception as e:
            print(f"\nOcorreu um erro: {e}")
            print("Por favor, tente novamente.\n")

if __name__ == "__main__":
    main()