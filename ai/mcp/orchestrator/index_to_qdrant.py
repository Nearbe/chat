"""
Скрипт индексации проекта Chat в Qdrant для RAG-контекста
Индексирует SKILL.md файлы, документацию и код Swift
"""

import json
from pathlib import Path
from typing import List, Dict, Any
import qdrant_client
from qdrant_client.models import Distance, VectorParams, PointStruct
import hashlib

# Путь к проекту Chat
CHAT_PROJECT_PATH = Path(__file__).parent.parent


class QdrantIndexer:
    """
    Индексация проекта в Qdrant для RAG-контекста
    Используется MCP Memory Server и LangGraph Orchestrator
    """

    def __init__(self, qdrant_url: str = "http://localhost:6333"):
        self.client = qdrant_client.QdrantClient(host=qdrant_url.split(":")[0], port=int(qdrant_url.split(":")[1]))
        self.collection_name_code = "chat_code"
        self.collection_name_docs = "chat_docs"
        self.embedding_dim = 768  # nomic-embed-text

    def _generate_vector_id(self, file_path: str) -> int:
        """Генерация уникального ID на основе хеша пути файла"""
        hash_obj = hashlib.md5(file_path.encode())
        return int(hash_obj.hexdigest()[:8], 16)

    def _create_collections(self) -> None:
        """Создание коллекций в Qdrant если не существуют"""
        # Коллекция для кода Swift
        if not self.client.collection_exists(self.collection_name_code):
            self.client.create_collection(
                collection_name=self.collection_name_code,
                vectors_config=VectorParams(size=self.embedding_dim, distance=Distance.COSINE),
            )
            print(f"✅ Создана коллекция: {self.collection_name_code}")

        # Коллекция для документации
        if not self.client.collection_exists(self.collection_name_docs):
            self.client.create_collection(
                collection_name=self.collection_name_docs,
                vectors_config=VectorParams(size=self.embedding_dim, distance=Distance.COSINE),
            )
            print(f"✅ Создана коллекция: {self.collection_name_docs}")

    def _embed_text(self, text: str) -> list:
        """
        Генерация эмбеддинга для текста
        В production использовать SentenceTransformer или API Qdrant
        Для примера возвращаем случайный вектор (заменить на реальный)
        """
        # Здесь будет интеграция с SentenceTransformer("nomic-embed-text")
        # Для примера - заглушка
        import random
        return [random.uniform(-1, 1) for _ in range(self.embedding_dim)]

    def index_swift_files(self, project_path: Path = None) -> int:
        """
        Индексация всех Swift файлов проекта
        Возвращает количество проиндексированных файлов
        """
        if not project_path:
            project_path = CHAT_PROJECT_PATH

        swift_files = list(project_path.rglob("*.swift"))
        print(f"📂 Найдено {len(swift_files)} Swift файлов")

        points = []
        for file_path in swift_files:
            try:
                content = file_path.read_text(encoding='utf-8')
                embedding = self._embed_text(content)

                point = PointStruct(
                    id=self._generate_vector_id(str(file_path)),
                    vector=embedding,
                    payload={
                        "file_path": str(file_path),
                        "language": "swift",
                        "size": len(content),
                        "type": "code",
                        "directory": str(file_path.parent),
                    }
                )
                points.append(point)
            except Exception as e:
                print(f"⚠️ Ошибка индексации {file_path}: {e}")

        # Batch upsert в Qdrant
        if points:
            self.client.upsert(
                collection_name=self.collection_name_code,
                points=points,
            )
            print(f"✅ Проиндексировано {len(points)} Swift файлов")

        return len(points)

    def index_documentation(self, project_path: Path = None) -> int:
        """
        Индексация документации (SKILL.md, README.md, *.md файлы)
        Возвращает количество проиндексированных файлов
        """
        if not project_path:
            project_path = CHAT_PROJECT_PATH

        # Поиск всех MD файлов
        md_files = list(project_path.rglob("*.md"))
        print(f"📄 Найдено {len(md_files)} Markdown файлов")

        points = []
        for file_path in md_files:
            try:
                content = file_path.read_text(encoding='utf-8')
                embedding = self._embed_text(content)

                point = PointStruct(
                    id=self._generate_vector_id(str(file_path)),
                    vector=embedding,
                    payload={
                        "file_path": str(file_path),
                        "type": "documentation",
                        "size": len(content),
                        "directory": str(file_path.parent),
                    }
                )
                points.append(point)
            except Exception as e:
                print(f"⚠️ Ошибка индексации {file_path}: {e}")

        # Batch upsert в Qdrant
        if points:
            self.client.upsert(
                collection_name=self.collection_name_docs,
                points=points,
            )
            print(f"✅ Проиндексировано {len(points)} Markdown файлов")

        return len(points)

    def index_agents_mapping(self) -> int:
        """
        Индексация agents_mapping.json для маршрутизации агентов
        """
        mapping_path = CHAT_PROJECT_PATH / "agents_mapping.json"

        if not mapping_path.exists():
            print(f"⚠️ Файл {mapping_path} не найден")
            return 0

        try:
            content = mapping_path.read_text(encoding='utf-8')
            embedding = self._embed_text(content)

            point = PointStruct(
                id=self._generate_vector_id(str(mapping_path)),
                vector=embedding,
                payload={
                    "file_path": str(mapping_path),
                    "type": "configuration",
                    "size": len(mapping_path.read_text()),
                    "description": "Маппинг 30+ агентов для маршрутизации запросов"
                }
            )

            self.client.upsert(
                collection_name=self.collection_name_docs,
                points=[point],
            )
            print(f"✅ Проиндексирован agents_mapping.json")
            return 1
        except Exception as e:
            print(f"⚠️ Ошибка индексации: {e}")
            return 0

    def search_code(self, query: str, top_k: int = 5) -> list:
        """
        Поиск по коду в Qdrant (RAG для LangGraph)
        Возвращает топ-K наиболее релевантных файлов
        """
        # Генерация эмбеддинга запроса
        query_embedding = self._embed_text(query)

        # Поиск в коллекции code
        results = self.client.search(
            collection_name=self.collection_name_code,
            query_vector=query_embedding,
            limit=top_k,
        )

        return [
            {
                "file_path": hit.payload["file_path"],
                "score": hit.score,
                "size": hit.payload["size"],
                "directory": hit.payload["directory"],
            }
            for hit in results
        ]

    def search_docs(self, query: str, top_k: int = 5) -> list:
        """
        Поиск по документации в Qdrant (RAG для LangGraph)
        Возвращает топ-K наиболее релевантных файлов
        """
        # Генерация эмбеддинга запроса
        query_embedding = self._embed_text(query)

        # Поиск в коллекции docs
        results = self.client.search(
            collection_name=self.collection_name_docs,
            query_vector=query_embedding,
            limit=top_k,
        )

        return [
            {
                "file_path": hit.payload["file_path"],
                "score": hit.score,
                "size": hit.payload["size"],
                "type": hit.payload.get("type", "documentation"),
            }
            for hit in results
        ]

    def run_full_indexation(self) -> dict:
        """
        Полный цикл индексации проекта в Qdrant
        Возвращает статистику индексации
        """
        print("🚀 Запуск полной индексации...")

        # Создание коллекций
        self._create_collections()

        # Индексация Swift файлов
        swift_count = self.index_swift_files()

        # Индексация документации
        docs_count = self.index_documentation()

        # Индексация agents_mapping.json
        mapping_count = self.index_agents_mapping()

        total = swift_count + docs_count + mapping_count

        print(f"\n✅ Полная индексация завершена!")
        print(f"📊 Статистика:")
        print(f"  - Swift файлы: {swift_count}")
        print(f"  - Markdown файлы: {docs_count}")
        print(f"  - Конфигурация: {mapping_count}")
        print(f"  ─────────────")
        print(f"  Итого: {total} файлов")

        return {
            "swift_files": swift_count,
            "markdown_files": docs_count,
            "configuration": mapping_count,
            "total": total
        }

    def health_check(self) -> dict:
        """
        Проверка здоровья Qdrant и статистики коллекций
        """
        try:
            # Получение информации о коллекциях
            code_collection = self.client.get_collection(self.collection_name_code)
            docs_collection = self.client.get_collection(self.collection_name_docs)

            return {
                "status": "healthy",
                "collections": {
                    self.collection_name_code: {
                        "points_count": code_collection.points_count,
                        "vectors_count": code_collection.vectors_count,
                        "indexed_at": code_collection.updated_at if hasattr(code_collection, 'updated_at') else None
                    },
                    self.collection_name_docs: {
                        "points_count": docs_collection.points_count,
                        "vectors_count": docs_collection.vectors_count,
                        "indexed_at": docs_collection.updated_at if hasattr(docs_collection, 'updated_at') else None
                    }
                }
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }


# Основной запуск для тестирования
if __name__ == "__main__":
    print("🚀 Запуск индексатора Qdrant...")

    indexer = QdrantIndexer(qdrant_url="http://localhost:6333")

    # Полный цикл индексации
    stats = indexer.run_full_indexation()

    # Проверка здоровья
    health = indexer.health_check()
    print(f"\n🏥 Здоровье Qdrant:")
    print(json.dumps(health, indent=2, ensure_ascii=False))

    # Пример поиска
    print("\n🔍 Пример поиска по документации:")
    results = indexer.search_docs("SwiftUI View", top_k=3)
    for result in results:
        print(f"  - {result['file_path']} (score: {result['score']:.2f})")
