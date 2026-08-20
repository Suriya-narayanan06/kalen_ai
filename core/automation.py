from datetime import datetime
import uuid

class AutomationTask:

    def __init__(self, title, action, trigger="manual"):
        self.id = str(uuid.uuid4())[:8]
        self.title = title
        self.action = action
        self.trigger = trigger
        self.enabled = True
        self.created = datetime.now()
        self.last_run = None

class AutomationEngine:

    def __init__(self):
        self.tasks = {}

    def create(self, title, action, trigger="manual"):

        task = AutomationTask(
            title,
            action,
            trigger
        )

        self.tasks[task.id] = task

        return task

    def execute(self, task_id):

        if task_id not in self.tasks:
            return None

        task = self.tasks[task_id]

        if not task.enabled:
            return None

        task.last_run = datetime.now()

        return {
            "task": task.title,
            "action": task.action,
            "status": "executed"
        }

    def enable(self, task_id):

        if task_id in self.tasks:
            self.tasks[task_id].enabled = True

    def disable(self, task_id):

        if task_id in self.tasks:
            self.tasks[task_id].enabled = False

    def delete(self, task_id):

        if task_id in self.tasks:
            del self.tasks[task_id]

    def list(self):

        return list(self.tasks.values())