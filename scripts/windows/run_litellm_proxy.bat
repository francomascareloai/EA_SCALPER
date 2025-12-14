@echo off
set OPENROUTER_API_KEY=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

litellm --model openrouter/deepseek/deepseek-r1-0528:free \
  --api_base https://openrouter.ai/api/v1 \
  --api_key %OPENROUTER_API_KEY% \
  --port 4000