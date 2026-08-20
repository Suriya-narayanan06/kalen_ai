class SystemService:

    def status(self):

        return {
            "AI": "KALEN",
            "Version": "1.0",
            "Status": "Running"
        }


system_service = SystemService()