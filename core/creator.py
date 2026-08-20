from datetime import datetime
import uuid

class CreatorEngine:

    def __init__(self):
        self.jobs = {}

    def _create_job(self, job_type, prompt):

        job_id = str(uuid.uuid4())[:8]

        self.jobs[job_id] = {
            "id": job_id,
            "type": job_type,
            "prompt": prompt,
            "status": "QUEUED",
            "created": datetime.now().isoformat(),
            "result": None
        }

        return job_id

    def image(self, prompt):
        return self._create_job("IMAGE", prompt)

    def document(self, prompt):
        return self._create_job("DOCUMENT", prompt)

    def code(self, prompt):
        return self._create_job("CODE", prompt)

    def presentation(self, prompt):
        return self._create_job("PRESENTATION", prompt)

    def voice(self, text):
        return self._create_job("VOICE", text)

    def video(self, prompt):
        return self._create_job("VIDEO", prompt)

    def complete(self, job_id, result):

        if job_id in self.jobs:

            self.jobs[job_id]["status"] = "DONE"
            self.jobs[job_id]["result"] = result

    def status(self, job_id):

        return self.jobs.get(job_id)

    def history(self):

        return list(self.jobs.values())