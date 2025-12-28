"""Task storage using SQLite."""

import json
from datetime import datetime
from pathlib import Path
from typing import Optional

import aiosqlite

from .config import StorageConfig
from .models import ModelResult, ReasoningModel, ReasoningTask, TaskStatus, TaskSummary


class TaskStorage:
    """Async SQLite storage for reasoning tasks."""

    def __init__(self, config: StorageConfig):
        self.config = config
        self.db_path = config.db_path
        self._db: Optional[aiosqlite.Connection] = None

    async def initialize(self) -> None:
        """Initialize database and create tables."""
        self._db = await aiosqlite.connect(self.db_path)
        await self._db.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                task_id TEXT PRIMARY KEY,
                question TEXT NOT NULL,
                models TEXT NOT NULL,
                status TEXT NOT NULL,
                priority INTEGER DEFAULT 0,
                context TEXT,
                created_at TEXT NOT NULL,
                started_at TEXT,
                completed_at TEXT,
                results TEXT,
                save_path TEXT
            )
        """)
        await self._db.execute("""
            CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status)
        """)
        await self._db.execute("""
            CREATE INDEX IF NOT EXISTS idx_tasks_created ON tasks(created_at DESC)
        """)
        await self._db.commit()

    async def close(self) -> None:
        """Close database connection."""
        if self._db:
            await self._db.close()
            self._db = None

    async def save_task(self, task: ReasoningTask) -> None:
        """Save or update a task."""
        if not self._db:
            raise RuntimeError("Storage not initialized")

        # Serialize results
        results_json = json.dumps(
            {k: v.model_dump(mode="json") for k, v in task.results.items()}
        )

        await self._db.execute(
            """
            INSERT OR REPLACE INTO tasks
            (task_id, question, models, status, priority, context,
             created_at, started_at, completed_at, results, save_path)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
            (
                task.task_id,
                task.question,
                json.dumps([m.value for m in task.models]),
                task.status.value,
                task.priority,
                task.context,
                task.created_at.isoformat(),
                task.started_at.isoformat() if task.started_at else None,
                task.completed_at.isoformat() if task.completed_at else None,
                results_json,
                task.save_path,
            ),
        )
        await self._db.commit()

    async def get_task(self, task_id: str) -> Optional[ReasoningTask]:
        """Get a task by ID."""
        if not self._db:
            raise RuntimeError("Storage not initialized")

        async with self._db.execute(
            "SELECT * FROM tasks WHERE task_id = ?", (task_id,)
        ) as cursor:
            row = await cursor.fetchone()

        if not row:
            return None

        return self._row_to_task(row)

    async def list_tasks(
        self,
        status: Optional[TaskStatus] = None,
        limit: int = 50,
    ) -> list[TaskSummary]:
        """List tasks with optional status filter."""
        if not self._db:
            raise RuntimeError("Storage not initialized")

        if status:
            query = (
                "SELECT * FROM tasks WHERE status = ? ORDER BY created_at DESC LIMIT ?"
            )
            params = (status.value, limit)
        else:
            query = "SELECT * FROM tasks ORDER BY created_at DESC LIMIT ?"
            params = (limit,)

        summaries = []
        async with self._db.execute(query, params) as cursor:
            async for row in cursor:
                task = self._row_to_task(row)
                completed = sum(
                    1 for r in task.results.values() if r.status == TaskStatus.COMPLETED
                )
                summaries.append(
                    TaskSummary(
                        task_id=task.task_id,
                        question_preview=task.question[:100],
                        models=[m.value for m in task.models],
                        status=task.status,
                        created_at=task.created_at,
                        completed_count=completed,
                        total_count=len(task.models),
                    )
                )

        return summaries

    async def get_pending_tasks(self) -> list[ReasoningTask]:
        """Get all pending tasks ordered by priority."""
        if not self._db:
            raise RuntimeError("Storage not initialized")

        tasks = []
        async with self._db.execute(
            "SELECT * FROM tasks WHERE status IN (?, ?) ORDER BY priority DESC, created_at ASC",
            (TaskStatus.PENDING.value, TaskStatus.RUNNING.value),
        ) as cursor:
            async for row in cursor:
                tasks.append(self._row_to_task(row))

        return tasks

    def _row_to_task(self, row: tuple) -> ReasoningTask:
        """Convert database row to ReasoningTask."""
        (
            task_id,
            question,
            models_json,
            status,
            priority,
            context,
            created_at,
            started_at,
            completed_at,
            results_json,
            save_path,
        ) = row

        models = [ReasoningModel(m) for m in json.loads(models_json)]

        results = {}
        if results_json:
            results_data = json.loads(results_json)
            for k, v in results_data.items():
                v["model"] = ReasoningModel(v["model"])
                v["status"] = TaskStatus(v["status"])
                results[k] = ModelResult(**v)

        return ReasoningTask(
            task_id=task_id,
            question=question,
            models=models,
            status=TaskStatus(status),
            priority=priority,
            context=context,
            created_at=datetime.fromisoformat(created_at),
            started_at=datetime.fromisoformat(started_at) if started_at else None,
            completed_at=datetime.fromisoformat(completed_at) if completed_at else None,
            results=results,
            save_path=save_path,
        )

    async def save_response_file(
        self,
        task_id: str,
        model: ReasoningModel,
        response: str,
        thinking: Optional[str] = None,
    ) -> Path:
        """Save response to markdown file."""
        responses_dir = self.config.responses_path
        task_dir = responses_dir / task_id
        task_dir.mkdir(parents=True, exist_ok=True)

        filename = f"{model.value}.md"
        filepath = task_dir / filename

        content = f"""# Response from {model.value}

**Task ID:** {task_id}
**Generated:** {datetime.now().isoformat()}

"""
        if thinking:
            content += f"""## Thinking Process

{thinking}

## Response

"""
        content += response

        filepath.write_text(content, encoding="utf-8")
        return filepath
