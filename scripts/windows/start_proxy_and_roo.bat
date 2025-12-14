@echo off
setlocal

REM Configurar variáveis de ambiente para o Roo Code
set OPENAI_API_BASE=http://localhost:4000
set DEFAULT_MODEL=deepseek-r1

REM Iniciar o proxy LiteLLM em segundo plano
start "LiteLLM Proxy" /B cmd /c "litellm --model openrouter/deepseek/deepseek-r1-0528:free --api_base https://openrouter.ai/api/v1 --api_key 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 --port 4000"

echo Proxy LiteLLM iniciado na porta 4000
echo Roo Code configurado para usar:
echo   API Base: %OPENAI_API_BASE%
echo   Modelo padrão: %DEFAULT_MODEL%
echo.
echo Mantenha esta janela aberta enquanto usar o Roo Code
pause