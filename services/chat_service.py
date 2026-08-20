class ChatService:

    def reply(self, message: str):

        return {
            "reply": f"KALEN AI: {message}"
        }


chat_service = ChatService()