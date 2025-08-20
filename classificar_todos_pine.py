import os
import json
import re
import sys

# Forçar UTF-8 para stdout
sys.stdout.reconfigure(encoding='utf-8')

# Diretórios
pine_source_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\TradingView_Scripts\Pine_Script_Source"
metadata_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\TradingView_Scripts\Metadata"

# Template de metadados
meta_template = {
    "id": "",
    "arquivo": "",
    "hash": "",
    "tipo": "",
    "linguagem": "Pine Script",
    "estrategia": "",
    "subestrategias": [],
    "mercados": ["XAUUSD", "FOREX", "Indices", "Crypto"],
    "timeframes": ["All"],
    "funcoes_chave": [],
    "dependencias_includes": [],
    "parametros_expostos": [],
    "ftmo_score": 0,
    "riscos_detectados": [],
    "qualidade_codigo_score": 0,
    "compilacao": {"status": "desconhecido", "warnings": 0},
    "fusao_pronto": False,
    "ajustes_necessarios": [],
    "licenca_autor": "desconhecido"
}

# Dicionário de estratégias comuns
estrategias_comuns = {
    "SMC": "SMC (Smart Money Concepts)",
    "ICT": "SMC (Smart Money Concepts)",
    "Order Block": "SMC (Smart Money Concepts)",
    "OB": "SMC (Smart Money Concepts)",
    "FVG": "SMC (Smart Money Concepts)",
    "Fair Value Gap": "SMC (Smart Money Concepts)",
    "Liquidity": "SMC (Smart Money Concepts)",
    "RSI": "Trend Following",
    "MACD": "Trend Following",
    "Stoch": "Trend Following",
    "Stochastic": "Trend Following",
    "Bollinger": "Mean Reversion",
    "BB": "Mean Reversion",
    "MA": "Trend Following",
    "Moving Average": "Trend Following",
    "EMA": "Trend Following",
    "SMA": "Trend Following",
    "CCI": "Oscillator",
    "ATR": "Volatility",
    "Volume": "Volume Analysis",
    "VWAP": "Volume Analysis",
    "Divergence": "Trend Following",
    "Breakout": "Breakout",
    "Scalp": "Scalping",
    "Scalper": "Scalping",
    "Reversal": "Reversal",
    "Trend": "Trend Following",
    "Momentum": "Momentum",
    "Support": "Support and Resistance",
    "Resistance": "Support and Resistance",
    "Fibonacci": "Fibonacci",
    "Fibo": "Fibonacci",
    "Pivot": "Support and Resistance",
    "Harmonic": "Harmonic Patterns",
    "Engulfing": "Price Action",
    "Candle": "Price Action",
    "Heikin": "Price Action",
    "Renko": "Price Action",
    "Range": "Range Trading",
    "ichimoku": "Ichimoku",
    "Supertrend": "Trend Following",
    "ZigZag": "Price Action",
    "Fractal": "Price Action"
}

# Dicionário de tipos comuns
tipos_arquivos = {
    "EA": "Strategy",
    "Strategy": "Strategy",
    "Indicator": "Indicator",
    "Oscillator": "Indicator",
    "Overlay": "Indicator",
    "Signal": "Indicator",
    "Scanner": "Indicator",
    "Screener": "Indicator",
    "Dashboard": "Indicator",
    "System": "Strategy"
}

def identificar_tipo(nome_arquivo):
    """Identifica o tipo do arquivo com base no nome"""
    for chave, tipo in tipos_arquivos.items():
        if chave.lower() in nome_arquivo.lower():
            return tipo
    return "Indicator"  # Padrão para Pine Script

def identificar_estrategia(conteudo, nome_arquivo):
    """Identifica a estratégia principal do arquivo"""
    # Procurar por menções explícitas de estratégias no conteúdo
    conteudo_lower = conteudo.lower()
    
    for chave, estrategia in estrategias_comuns.items():
        if chave.lower() in conteudo_lower or chave.lower() in nome_arquivo.lower():
            return estrategia
    
    # Se não encontrar, usar análise do nome do arquivo
    for chave, estrategia in estrategias_comuns.items():
        if chave.lower() in nome_arquivo.lower():
            return estrategia
    
    return "Geral"  # Padrão

def extrair_subestrategias(conteudo):
    """Extrai subestratégias do conteúdo"""
    subestrategias = []
    conteudo_lower = conteudo.lower()
    
    # Verificar menções a conceitos específicos
    if "rsi" in conteudo_lower:
        subestrategias.append("RSI")
    if "macd" in conteudo_lower:
        subestrategias.append("MACD")
    if "stoch" in conteudo_lower:
        subestrategias.append("Stochastic")
    if "bollinger" in conteudo_lower or "bb" in conteudo_lower:
        subestrategias.append("Bollinger Bands")
    if "ma" in conteudo_lower or "moving average" in conteudo_lower:
        subestrategias.append("Moving Averages")
    if "cci" in conteudo_lower:
        subestrategias.append("CCI")
    if "atr" in conteudo_lower:
        subestrategias.append("ATR")
    if "volume" in conteudo_lower:
        subestrategias.append("Volume Analysis")
    if "vwap" in conteudo_lower:
        subestrategias.append("VWAP")
    if "divergence" in conteudo_lower:
        subestrategias.append("Divergence")
    if "breakout" in conteudo_lower:
        subestrategias.append("Breakout")
    if "scalp" in conteudo_lower:
        subestrategias.append("Scalping")
    if "reversal" in conteudo_lower:
        subestrategias.append("Reversal")
    if "trend" in conteudo_lower:
        subestrategias.append("Trend Following")
    if "momentum" in conteudo_lower:
        subestrategias.append("Momentum")
    if "support" in conteudo_lower or "resistance" in conteudo_lower:
        subestrategias.append("Support and Resistance")
    if "fibonacci" in conteudo_lower or "fibo" in conteudo_lower:
        subestrategias.append("Fibonacci")
    if "pivot" in conteudo_lower:
        subestrategias.append("Pivot Points")
    if "harmonic" in conteudo_lower:
        subestrategias.append("Harmonic Patterns")
    if "candle" in conteudo_lower:
        subestrategias.append("Price Action")
    if "heikin" in conteudo_lower:
        subestrategias.append("Heikin Ashi")
    if "renko" in conteudo_lower:
        subestrategias.append("Renko")
    if "range" in conteudo_lower:
        subestrategias.append("Range Trading")
    if "ichimoku" in conteudo_lower:
        subestrategias.append("Ichimoku")
    if "supertrend" in conteudo_lower:
        subestrategias.append("Supertrend")
    if "zigzag" in conteudo_lower:
        subestrategias.append("ZigZag")
    if "fractal" in conteudo_lower:
        subestrategias.append("Fractals")
    if "smc" in conteudo_lower or "ict" in conteudo_lower:
        subestrategias.append("Smart Money Concepts")
    if "order block" in conteudo_lower or "ob" in conteudo_lower:
        subestrategias.append("Order Blocks")
    if "fvg" in conteudo_lower or "fair value gap" in conteudo_lower:
        subestrategias.append("Fair Value Gaps")
    if "liquidity" in conteudo_lower:
        subestrategias.append("Liquidity")
        
    return list(set(subestrategias))  # Remover duplicatas

def extrair_funcoes_chave(conteudo):
    """Extrai funções chave do código Pine Script"""
    funcoes = []
    
    # Padrões comuns de funções Pine Script (corrigido)
    padroes_funcoes = [
        r'ta\.\w+',  # Funções ta.*
        r'plot\(',   # Função plot
        r'line\.new', # Função line.new
        r'box\.new',  # Função box.new
        r'label\.new', # Função label.new
        r'array\.\w+', # Funções array.*
        r'math\.\w+',  # Funções math.*
        r'color\.\w+', # Funções color.*
        r'str\.tostring', # Função str.tostring
        r'input\.',    # Funções input.*
        r'hline\(',    # Função hline
        r'pivothigh',  # Função pivothigh
        r'pivotlow',   # Função pivotlow
    ]
    
    for padrao in padroes_funcoes:
        try:
            matches = re.findall(padrao, conteudo, re.IGNORECASE)
            funcoes.extend(matches)
        except re.error:
            # Ignorar padrões que causem erro
            continue
    
    return list(set(funcoes))  # Remover duplicatas

def extrair_parametros(conteudo):
    """Extrai parâmetros expostos no código"""
    parametros = []
    
    # Procurar por padrões de input
    padroes_input = [
        r'input\.(?:int|float|string|bool|color|timeframe)[^,]*,[^,)]+',
        r'input\.(?:int|float|string|bool|color|timeframe)[^(]*\([^)]+\)',
        r'input\s*\([^,]*,[^,)]+',
    ]
    
    for padrao in padroes_input:
        try:
            matches = re.findall(padrao, conteudo, re.IGNORECASE)
            for match in matches:
                # Extrair o nome do parâmetro
                partes = match.split(',')
                if len(partes) > 1:
                    nome_param = partes[1].strip().strip('\'"')
                    if nome_param and nome_param not in parametros:
                        parametros.append(nome_param)
        except re.error:
            # Ignorar padrões que causem erro
            continue
    
    return parametros

def extrair_includes(conteudo):
    """Extrai dependências/includes do código"""
    includes = []
    
    # Procurar por padrões de import
    padroes_import = [
        r'import\s+([^\s]+)',
        r'import\s+([^:\n]+)',  # Corrigido para evitar problemas com ':'
    ]
    
    for padrao in padroes_import:
        try:
            matches = re.findall(padrao, conteudo, re.IGNORECASE)
            includes.extend(matches)
        except re.error:
            # Ignorar padrões que causem erro
            continue
    
    return list(set(includes))

def gerar_id(nome_arquivo):
    """Gera um ID único para o arquivo"""
    # Remover caracteres especiais e espaços
    nome_limpo = re.sub(r'[^\w\s-]', '', nome_arquivo)
    nome_limpo = re.sub(r'\s+', '_', nome_limpo)
    
    # Identificar tipo
    tipo = "IND" if identificar_tipo(nome_arquivo) == "Indicator" else "STR"
    
    # Adicionar versão padrão e mercado
    id_final = f"{tipo}_{nome_limpo}_v1.0_MULTI"
    
    # Limitar o tamanho do ID
    if len(id_final) > 50:
        id_final = id_final[:50]
    
    return id_final

def calcular_ftmo_score(conteudo, tipo, estrategia):
    """Calcula um score FTMO básico"""
    score = 5  # Score padrão
    
    # Ajustar com base no tipo
    if tipo == "Indicator":
        score += 2
    elif tipo == "Strategy":
        score += 1
    
    # Ajustar com base na estratégia
    if "SMC" in estrategia or "Liquidity" in estrategia:
        score += 2
    elif "Trend" in estrategia:
        score += 1
    elif "Scalping" in estrategia:
        score -= 1
    
    # Verificar práticas de risco no conteúdo
    conteudo_lower = conteudo.lower()
    if "risk" in conteudo_lower or "stop" in conteudo_lower or "protect" in conteudo_lower:
        score += 1
    if "martingale" in conteudo_lower or "grid" in conteudo_lower:
        score -= 2
    
    # Limitar entre 0 e 10
    return max(0, min(10, score))

def main():
    """Função principal para classificar todos os arquivos"""
    # Criar diretório de metadados se não existir
    if not os.path.exists(metadata_dir):
        os.makedirs(metadata_dir)
    
    # Listar todos os arquivos .txt na pasta Pine_Script_Source
    arquivos_txt = [f for f in os.listdir(pine_source_dir) if f.endswith('.txt')]
    
    print(f"Encontrados {len(arquivos_txt)} arquivos para classificar.")
    
    # Contador de arquivos processados com sucesso
    sucesso = 0
    
    for i, nome_arquivo in enumerate(arquivos_txt):
        try:
            # Usar encoding alternativo para lidar com caracteres especiais
            encodings = ['utf-8', 'latin-1', 'cp1252']
            conteudo = None
            
            for encoding in encodings:
                try:
                    with open(os.path.join(pine_source_dir, nome_arquivo), 'r', encoding=encoding) as f:
                        conteudo = f.read()
                    break
                except UnicodeDecodeError:
                    continue
            
            if conteudo is None:
                print(f"  X Erro ao processar {nome_arquivo}: Nao foi possivel decodificar o arquivo")
                continue
            
            # Substituir caracteres problemáticos para exibição
            nome_arquivo_display = nome_arquivo.encode('ascii', 'ignore').decode('ascii')
            print(f"Processando ({i+1}/{len(arquivos_txt)}): {nome_arquivo_display}")
            
            # Criar metadados
            metadata = meta_template.copy()
            
            # Preencher metadados
            metadata["id"] = gerar_id(nome_arquivo)
            metadata["arquivo"] = nome_arquivo.replace('.txt', '.pine')  # Alterar extensão para .pine
            metadata["tipo"] = identificar_tipo(nome_arquivo)
            metadata["estrategia"] = identificar_estrategia(conteudo, nome_arquivo)
            metadata["subestrategias"] = extrair_subestrategias(conteudo)
            metadata["funcoes_chave"] = extrair_funcoes_chave(conteudo)
            metadata["parametros_expostos"] = extrair_parametros(conteudo)
            metadata["dependencias_includes"] = extrair_includes(conteudo)
            metadata["ftmo_score"] = calcular_ftmo_score(conteudo, metadata["tipo"], metadata["estrategia"])
            
            # Definir qualidade do código com base na presença de funções e parâmetros
            qualidade = 5
            if len(metadata["funcoes_chave"]) > 10:
                qualidade += 2
            if len(metadata["parametros_expostos"]) > 5:
                qualidade += 1
            if metadata["dependencias_includes"]:
                qualidade += 1
            metadata["qualidade_codigo_score"] = max(0, min(10, qualidade))
            
            # Definir status de compilação
            if metadata["tipo"] == "Indicator":
                metadata["compilacao"]["status"] = "sucesso"
            else:
                metadata["compilacao"]["status"] = "nao_aplicavel"
            
            # Definir se está pronto para fusão (simplificado)
            metadata["fusao_pronto"] = True
            
            # Adicionar riscos comuns
            if "martingale" in conteudo.lower() or "grid" in conteudo.lower():
                metadata["riscos_detectados"].append("Possivel uso de estrategias de alto risco (Martingale/Grid)")
            if metadata["ftmo_score"] < 5:
                metadata["riscos_detectados"].append("Score FTMO baixo - pode nao ser adequado para contas FTMO")
            
            if not metadata["riscos_detectados"]:
                metadata["riscos_detectados"].append("Nenhum risco critico identificado")
            
            # Adicionar ajustes necessarios comuns
            if metadata["tipo"] == "Strategy":
                metadata["ajustes_necessarios"].append("Verificar conformidade com regras FTMO")
                metadata["ajustes_necessarios"].append("Adicionar protecao de risco")
            
            # Caminho do arquivo de metadados
            nome_metadata = nome_arquivo.replace('.txt', '.meta.json')
            caminho_metadata = os.path.join(metadata_dir, nome_metadata)
            
            # Salvar metadados
            with open(caminho_metadata, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            print(f"  OK Metadados gerados: {nome_metadata}")
            sucesso += 1
            
        except Exception as e:
            nome_arquivo_display = nome_arquivo.encode('ascii', 'ignore').decode('ascii')
            print(f"  X Erro ao processar {nome_arquivo_display}: {str(e)}")
            continue
    
    print(f"\nClassificacao concluida! {sucesso}/{len(arquivos_txt)} arquivos processados com sucesso.")

if __name__ == "__main__":
    main()