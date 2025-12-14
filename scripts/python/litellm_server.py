from litellm import Router

model_list = [
    {
        "model_name": "gpt-4",
        "litellm_params": {
            "model": "openai/gpt-4",
            "api_key": "YOUR_OPENAI_API_KEY"
        }
    },
    {
        "model_name": "claude-3",
        "litellm_params": {
            "model": "anthropic/claude-3-opus-20240229",
            "api_key": "YOUR_ANTHROPIC_API_KEY"
        }
    }
]

router = Router(model_list=model_list)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(router, host="0.0.0.0", port=4000)