class SessionManager:

    def __init__(self):
        self.sessions = {}

    def create(self, token):
        self.sessions[token] = True

    def valid(self, token):
        return token in self.sessions

    def remove(self, token):
        self.sessions.pop(token, None)