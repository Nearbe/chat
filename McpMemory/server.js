// server.js — Кастомный MCP Memory Server для проекта Chat
const express = require('express');
const cors = require('cors');
const {v4: uuidv4} = require('uuid');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json({limit: '50mb'}));

// База данных SQLite для хранения графов знаний
const dbPath = process.env.DATA_DIR || './data';
const db = new Database(path.join(dbPath, 'memory.db'));

// Создаём таблицы (если нет)
db.exec(`
  CREATE TABLE IF NOT EXISTS nodes (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    name TEXT NOT NULL,
    content TEXT,
    metadata TEXT DEFAULT '{}',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS edges (
    id TEXT PRIMARY KEY,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    relation_type TEXT NOT NULL,
    weight REAL DEFAULT 1.0,
    metadata TEXT DEFAULT '{}',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (source_id) REFERENCES nodes(id),
    FOREIGN KEY (target_id) REFERENCES nodes(id)
  );

  CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    agent_id TEXT NOT NULL,
    context TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE INDEX IF NOT EXISTS idx_nodes_type ON nodes(type);
  CREATE INDEX IF NOT EXISTS idx_edges_source ON edges(source_id);
  CREATE INDEX IF NOT EXISTS idx_sessions_agent ON sessions(agent_id);
`);

// === API Endpoints ===

// Health check
app.get('/health', (req, res) => {
    res.json({status: 'ok', version: '1.0.0', project: 'Chat'});
});

// Создание узла графа знаний
app.post('/nodes', (req, res) => {
    const {id = uuidv4(), type, name, content, metadata = {}} = req.body;

    db.prepare(`
    INSERT OR REPLACE INTO nodes (id, type, name, content, metadata)
    VALUES (?, ?, ?, ?, ?)
  `).run(id, type, name, JSON.stringify(content), JSON.stringify(metadata));

    res.json({success: true, node_id: id});
});

// Получение узла по ID
app.get('/nodes/:id', (req, res) => {
    const stmt = db.prepare('SELECT * FROM nodes WHERE id = ?');
    const node = stmt.get(req.params.id);

    if (!node) return res.status(404).json({error: 'Node not found'});

    res.json({
        ...node,
        content: JSON.parse(node.content || '{}'),
        metadata: JSON.parse(node.metadata || '{}')
    });
});

// Получение всех узлов с фильтрацией по типу
app.get('/nodes', (req, res) => {
    const stmt = db.prepare('SELECT * FROM nodes WHERE type = ?');
    const nodes = stmt.all(req.query.type || null);

    res.json(nodes.map(node => ({
        ...node,
        content: JSON.parse(node.content || '{}'),
        metadata: JSON.parse(node.metadata || '{}')
    })));
});

// Создание связи между узлами
app.post('/edges', (req, res) => {
    const {id = uuidv4(), source_id, target_id, relation_type, weight = 1.0, metadata = {}} = req.body;

    db.prepare(`
    INSERT OR REPLACE INTO edges (id, source_id, target_id, relation_type, weight, metadata)
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(id, source_id, target_id, relation_type, weight, JSON.stringify(metadata));

    res.json({success: true, edge_id: id});
});

// Получение связей для узла (входящие + исходящие)
app.get('/edges/:id', (req, res) => {
    const stmt = db.prepare(`
    SELECT * FROM edges WHERE source_id = ? OR target_id = ?
  `);
    const edges = stmt.all(req.params.id, req.params.id);

    res.json(edges.map(edge => ({
        ...edge,
        metadata: JSON.parse(edge.metadata || '{}')
    })));
});

// Создание/обновление сессии агента
app.post('/sessions', (req, res) => {
    const {id = uuidv4(), agent_id, context} = req.body;

    db.prepare(`
    INSERT OR REPLACE INTO sessions (id, agent_id, context, updated_at)
    VALUES (?, ?, ?, CURRENT_TIMESTAMP)
  `).run(id, agent_id, JSON.stringify(context));

    res.json({success: true, session_id: id});
});

// Получение последней сессии агента
app.get('/sessions/:agent_id', (req, res) => {
    const stmt = db.prepare(`
    SELECT * FROM sessions WHERE agent_id = ? ORDER BY updated_at DESC LIMIT 1
  `);
    const session = stmt.get(req.params.agent_id);

    if (!session) return res.status(404).json({error: 'Session not found'});

    res.json({
        ...session,
        context: JSON.parse(session.context || '{}')
    });
});

// Поиск по графу (простой RAG через текст в узлах)
app.get('/search', (req, res) => {
    const query = req.query.q;
    if (!query) return res.status(400).json({error: 'Query required'});

    const stmt = db.prepare(`
    SELECT * FROM nodes WHERE content LIKE ? OR name LIKE ?
  `);

    const searchPattern = `%${query}%`;
    const results = stmt.all(searchPattern, searchPattern);

    res.json(results.map(node => ({
        ...node,
        content: JSON.parse(node.content || '{}'),
        metadata: JSON.parse(node.metadata || '{}')
    })));
});

// Экспорт графа знаний (для миграции)
app.get('/export', (req, res) => {
    const nodes = db.prepare('SELECT * FROM nodes').all();
    const edges = db.prepare('SELECT * FROM edges').all();

    res.json({
        version: '1.0.0',
        project: 'Chat',
        exported_at: new Date().toISOString(),
        data: {nodes, edges}
    });
});

// Импорт графа знаний (для миграции)
app.post('/import', (req, res) => {
    const {nodes = [], edges = []} = req.body;

    // Очистка старых данных (опционально)
    db.prepare('DELETE FROM nodes').run();
    db.prepare('DELETE FROM edges').run();

    // Импорт узлов
    const insertNode = db.prepare(`
    INSERT INTO nodes (id, type, name, content, metadata, created_at) VALUES (?, ?, ?, ?, ?, ?)
  `);

    for (const node of nodes) {
        insertNode.run(
            node.id,
            node.type,
            node.name,
            JSON.stringify(node.content || '{}'),
            JSON.stringify(node.metadata || '{}'),
            new Date().toISOString()
        );
    }

    // Импорт связей
    const insertEdge = db.prepare(`
    INSERT INTO edges (id, source_id, target_id, relation_type, weight, metadata) VALUES (?, ?, ?, ?, ?, ?)
  `);

    for (const edge of edges) {
        insertEdge.run(
            edge.id,
            edge.source_id,
            edge.target_id,
            edge.relation_type,
            edge.weight || 1.0,
            JSON.stringify(edge.metadata || '{}')
        );
    }

    res.json({success: true, imported_nodes: nodes.length, imported_edges: edges.length});
});

// Статистика графа знаний
app.get('/stats', (req, res) => {
    const nodeCount = db.prepare('SELECT COUNT(*) as count FROM nodes').get();
    const edgeCount = db.prepare('SELECT COUNT(*) as count FROM edges').get();
    const sessionCount = db.prepare('SELECT COUNT(DISTINCT agent_id) as count FROM sessions').get();

    res.json({
        total_nodes: nodeCount.count,
        total_edges: edgeCount.count,
        active_agents: sessionCount.count,
        database_path: dbPath
    });
});

// Запуск сервера
const PORT = process.env.PORT || 3000;
app.listen(PORT, '192.168.1.107', () => {
    console.log(`MCP Memory Server for Chat running on port ${PORT}`);
    console.log(`Data directory: ${dbPath}`);
});
