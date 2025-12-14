def calcular_imc(peso, altura):
    """
    Calcula o Índice de Massa Corporal (IMC) e fornece a classificação.

    Args:
        peso (float): Peso em quilogramas.
        altura (float): Altura em metros.

    Returns:
        str: Uma string formatada com o valor do IMC e a classificação.
             Retorna uma mensagem de erro se os valores forem inválidos.
    """
    try:
        peso = float(peso)
        altura = float(altura)
        
        if peso <= 0 or altura <= 0:
            return "Erro: Peso e altura devem ser números positivos."
        
        imc = peso / (altura ** 2)
        
        if imc < 17:
            classificacao = "Muito abaixo do peso"
        elif 17 <= imc < 18.5:
            classificacao = "Abaixo do peso"
        elif 18.5 <= imc < 25:
            classificacao = "Peso normal"
        elif 25 <= imc < 30:
            classificacao = "Acima do peso"
        elif 30 <= imc < 35:
            classificacao = "Obesidade I"
        elif 35 <= imc < 40:
            classificacao = "Obesidade II"
        else: # imc >= 40
            classificacao = "Obesidade III"
            
        return f"Seu IMC é {imc:.2f}. Classificação: {classificacao}."
        
    except ValueError:
        return "Erro: Por favor, insira valores numéricos válidos para peso e altura."
import tkinter as tk
from tkinter import ttk

def calcular_imc(peso, altura):
    """
    Calcula o Índice de Massa Corporal (IMC) e fornece a classificação.

    Args:
        peso (float): Peso em quilogramas.
        altura (float): Altura em metros.

    Returns:
        str: Uma string formatada com o valor do IMC e a classificação.
             Retorna uma mensagem de erro se os valores forem inválidos.
    """
    try:
        peso = float(peso)
        altura = float(altura)
        
        if peso <= 0 or altura <= 0:
            return "Erro: Peso e altura devem ser números positivos."
        
        imc = peso / (altura ** 2)
        
        if imc < 17:
            classificacao = "Muito abaixo do peso"
        elif 17 <= imc < 18.5:
            classificacao = "Abaixo do peso"
        elif 18.5 <= imc < 25:
            classificacao = "Peso normal"
        elif 25 <= imc < 30:
            classificacao = "Acima do peso"
        elif 30 <= imc < 35:
            classificacao = "Obesidade I"
        elif 35 <= imc < 40:
            classificacao = "Obesidade II"
        else: # imc >= 40
            classificacao = "Obesidade III"
            
        return f"Seu IMC é {imc:.2f}. Classificação: {classificacao}."
        
    except ValueError:
        return "Erro: Por favor, insira valores numéricos válidos para peso e altura."


def calcular_e_mostrar():
    """
    Função chamada quando o botão 'Calcular' é pressionado.
    Obtém os valores dos campos de entrada, chama calcular_imc e atualiza o label de resultado.
    """
    peso = entry_peso.get()
    altura = entry_altura.get()
    resultado = calcular_imc(peso, altura)
    label_resultado.config(text=resultado)


# Criar a janela principal
root = tk.Tk()
root.title("Calculadora de IMC")

# Criar e posicionar os widgets
label_peso = ttk.Label(root, text="Peso (kg):")
label_peso.grid(row=0, column=0, padx=5, pady=5, sticky=tk.W)

entry_peso = ttk.Entry(root, width=20)
entry_peso.grid(row=0, column=1, padx=5, pady=5)

label_altura = ttk.Label(root, text="Altura (m):")
label_altura.grid(row=1, column=0, padx=5, pady=5, sticky=tk.W)

entry_altura = ttk.Entry(root, width=20)
entry_altura.grid(row=1, column=1, padx=5, pady=5)

botao_calcular = ttk.Button(root, text="Calcular", command=calcular_e_mostrar)
botao_calcular.grid(row=2, column=0, columnspan=2, padx=5, pady=10)

label_resultado = ttk.Label(root, text="", wraplength=300)
label_resultado.grid(row=3, column=0, columnspan=2, padx=5, pady=5)

# Iniciar o loop principal da aplicação
root.mainloop()