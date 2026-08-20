class AIManager:

    def __init__(self):

        self.model = None
        self.personality = "Jarvis"

    def load(self, model):

        self.model = model

    def chat(self, prompt):

        return self.model.generate(prompt)

    def vision(self, image):

        return self.model.analyze(image)

    def speech(self, audio):

        return self.model.transcribe(audio)