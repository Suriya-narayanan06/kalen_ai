class ModelRegistry:

    MODELS = {
        "DeepSeek": {
            "type": "cloud",
        },
        "Gemini": {
            "type": "cloud",
        },
        "Llama3": {
            "type": "local",
        },
        "Mistral": {
            "type": "local",
        },
        "GPT4All": {
            "type": "local",
        },
    }

    @classmethod
    def get(cls, name):
        return cls.MODELS.get(name)
