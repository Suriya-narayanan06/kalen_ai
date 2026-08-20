from dataclasses import dataclass
from typing import Dict

@dataclass
class Plugin:
    name: str
    version: str
    author: str
    enabled: bool = True

class PluginManager:

    def __init__(self):
        self.plugins: Dict[str, Plugin] = {}

    def register(self, plugin: Plugin):
        self.plugins[plugin.name] = plugin

    def enable(self, name):
        if name in self.plugins:
            self.plugins[name].enabled = True

    def disable(self, name):
        if name in self.plugins:
            self.plugins[name].enabled = False

    def uninstall(self, name):
        self.plugins.pop(name, None)

    def installed(self):
        return list(self.plugins.values())

    def get(self, name):
        return self.plugins.get(name)