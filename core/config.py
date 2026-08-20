from dataclasses import dataclass, field

@dataclass
class AIConfig:

    # AI
    model = "Gemini"
    personality = "Jarvis"
    language = "en-US"

    # Voice
    wake_word = "Hey Kalen"
    voice = "Male"

    # Security
    passkey_required = True
    biometric = True

    # UI
    theme = "Cyber Blue"
    accent = "#00E5FF"
    animation = True

    # Features
    osint = True
    creator = True
    smart_call = True
    automation = True
    vision = True

@dataclass
class NetworkConfig:

    timeout = 30
    retry = 3
    offline_mode = False

@dataclass
class SystemConfig:

    debug = False
    log_level = "INFO"
    auto_update = True
    save_history = True

class ConfigManager:

    def __init__(self):

        self.ai = AIConfig()
        self.network = NetworkConfig()
        self.system = SystemConfig()

    def export(self):

        return {
            "ai": self.ai.__dict__,
            "network": self.network.__dict__,
            "system": self.system.__dict__
        }

    def load(self,data):

        for section in data:

            obj = getattr(self,section,None)

            if obj:

                for key,value in data[section].items():

                    setattr(obj,key,value)