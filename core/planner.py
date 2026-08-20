from dataclasses import dataclass, field
from typing import List
import uuid

@dataclass
class Task:
    id: str
    title: str
    module: str
    status: str = "PENDING"
    depends_on: List[str] = field(default_factory=list)

class Planner:

    def __init__(self):
        self.tasks = []

    def create_task(self, title, module):
        task = Task(
            id=str(uuid.uuid4())[:8],
            title=title,
            module=module
        )

        self.tasks.append(task)

        return task

    def add_dependency(self, task_id, dependency):

        for task in self.tasks:
            if task.id == task_id:
                task.depends_on.append(dependency)

    def ready_tasks(self):

        ready = []

        for task in self.tasks:

            if task.status != "PENDING":
                continue

            finished = True

            for dep in task.depends_on:

                dep_task = next(
                    (t for t in self.tasks if t.id == dep),
                    None
                )

                if dep_task and dep_task.status != "DONE":
                    finished = False

            if finished:
                ready.append(task)

        return ready

    def complete(self, task_id):

        for task in self.tasks:
            if task.id == task_id:
                task.status = "DONE"

    def all_tasks(self):
        return self.tasks