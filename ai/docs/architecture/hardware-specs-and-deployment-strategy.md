# 🏗️ Hardware Specifications & Deployment Strategy

**Author:** Nearbe  
**Date:** 2026-01-30  
**Version:** 1.0.0

---

## 📊 Available Infrastructure Overview

| Machine             | Role                | CPU              | GPU                  | RAM       | OS                | Access                |
|---------------------|---------------------|------------------|----------------------|-----------|-------------------|-----------------------|
| **Master**          | Dev workstation     | M4 Max (16-core) | 128GB Unified Memory | macOS 15  | Local             | ✅ Direct              |
| **Alfred**          | AI Server           | Ryzen 9 7950X    | RTX 4080 16GB VRAM   | 64GB DDR5 | Windows 11        | SSH (e@192.168.1.107) |
| **Galathea**        | Secondary AI Server | Ryzen 7 5800X    | RTX 4060 Ti 8GB VRAM | 32GB DDR4 | Windows 11        | SSH (remote)          |
| **Saint Celestine** | Mobile/Edge         | A17 Pro          | 8GB Unified Memory   | iOS 19    | iPhone 16 Pro Max | WiFi/Xcode            |

---

## 🧠 LM Studio & Embedding Models Explained

### What is LM Studio?

**LM Studio** is a local AI application that enables running LLMs privately on your hardware without cloud dependencies.

#### Key Features:

- **GUI Interface**: Browse, download, and run models locally
- **Headless Mode (`llmster`)**: Server deployment without GUI for production
- **OpenAI Compatibility API**: Compatible with existing AI applications
- **MCP Support**: Can act as an MCP client for agent frameworks
- **Model Formats**: GGUF (optimized for CPU/GPU), ONNX, PyTorch

#### Deployment Modes:

```bash
# GUI Mode (Desktop)
lmstudio app

# Headless Server Mode (Production)
llmster serve --port 1234

# As MCP Client
mcpServers:
  lmstudio-embeddings:
    command: "lms"
    args: ["embedding", "--model", "BAAI/bge-small-en-v1.5"]
```

---

### What are Text Embedding Models?

**Embedding models** convert text into numerical vectors (arrays of numbers) that capture semantic meaning. These
vectors enable:

- **Semantic Search**: Find similar content by meaning, not keywords
- **Clustering**: Group related documents/memories together
- **Similarity Matching**: Compare texts to find relationships
- **RAG Retrieval**: Fetch relevant context for LLM queries

#### How They Work:

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L6-v2')
text = "Hello world"
embedding = model.encode(text)  # Returns array of 384 floats

# Similarity between two texts:
texts = ["AI is amazing", "Machine learning is cool"]
embeddings = model.encode(texts)
similarities = cosine_similarity([embeddings[0]], [embeddings[1]])
```

#### Why Embeddings Matter for MCP Memory Service:

- **Semantic Search**: Find memories by meaning, not exact keywords
- **Quality Scoring**: Assess memory importance using embedding similarity
- **Deduplication**: Detect and merge duplicate memories
- **Clustering**: Group related memories automatically

---

### Recommended Embedding Models

| Model                                       | Size  | Dimensions | Speed     | Quality      | Use Case                      |
|---------------------------------------------|-------|------------|-----------|--------------|-------------------------------|
| **all-MiniLM-L6-v2**                        | 85MB  | 384        | ⚡ Fastest | Good         | Default for MCP Memory (ONNX) |
| **BAAI/bge-small-en-v1.5**                  | 134MB | 384        | ⚡ Fast    | Better       | General-purpose RAG           |
| **sentence-transformers/all-mpnet-base-v2** | 439MB | 768        | Medium    | Excellent    | High-quality semantic search  |
| **intfloat/e5-mistral-7b-instruct**         | 5.1GB | 4096       | Slow      | State-of-art | Enterprise RAG with GPU       |

#### MCP Memory Service Defaults:

```bash
# ONNX Runtime (CPU/GPU acceleration)
MCP_EMBEDDING_MODEL=all-MiniLM-L6-v2
MCP_MEMORY_USE_ONNX=true

# PyTorch (more features, larger footprint)
MCP_EMBEDDING_MODEL=sentence-transformers/all-mpnet-base-v2
MCP_MEMORY_USE_ONNX=false
```

---

## 🎯 Deployment Strategy by Component

### 1. MCP Memory Service (SQLite-vec + ONNX Embeddings)

#### Recommended: **Alfred (RTX 4080)** - Primary Server

**Why Alfred:**

- RTX 4080 provides excellent GPU acceleration for embeddings (~5ms queries)
- 64GB RAM sufficient for large memory databases
- Windows 11 + PowerShell 7 configured for proper encoding
- Always-on server environment

**Configuration:**

```powershell
# Environment variables for Alfred
$env:MCP_MEMORY_STORAGE_BACKEND = "sqlite_vec"
$env:MCP_EMBEDDING_MODEL = "all-MiniLM-L6-v2"
$env:MCP_MEMORY_USE_ONNX = "true"
$env:MCP_QUALITY_BOOST_ENABLED = "true"
$env:MCP_CONSOLIDATION_ENABLED = "true"

# Start server
python scripts/server/run_memory_server.py --http --port 8000
```

**Alternative: Master (M4 Max)** - Development & Testing

- Use for local development, testing new features
- SQLite database for easy backup/version control
- Can run alongside other dev tools

---

### 2. LangGraph Agents

#### Recommended: **Alfred (RTT 4080)** - Production Agents

**Why Alfred:**

- RTX 4080 can run medium-sized LLMs locally (7B-13B params)
- 64GB RAM allows multiple concurrent agents
- Fast GPU inference for real-time agent responses

**LLM Model Recommendations:**

```python
# Local LLM via LM Studio or Ollama on Alfred
# For LangGraph agents:

# Option A: Small model (fast, less capable)
model = "gemma2:9b"  # ~6GB VRAM
# Option B: Medium model (balanced)
model = "mistral-nemo:12b"  # ~8GB VRAM  
# Option C: Large model (best quality)
model = "qwen2.5:14b"  # ~10GB VRAM
```

**Architecture:**

```
Alfred (RTX 4080)
├── LangGraph Orchestrator Agent
│   ├── Research Agent → MCP Memory Service
│   ├── Code Analysis Agent → MCP Memory Service
│   └── Planning Agent → MCP Memory Service
└── LM Studio Server (LLM backend)
```

---

### 3. AutoGen Agents

#### Recommended: **Alfred** - Primary, **Galathea** - Secondary/Load Balancing

**Why Alfred + Galathea:**

- Alfred handles primary agent orchestration
- Galathea can run parallel agent groups for specific tasks
- Load balancing across two GPUs prevents bottlenecks

**Split Strategy:**

```yaml
Alfred (RTX 4080):
  - Primary orchestrator agents
  - High-priority real-time agents
  - User-facing conversational agents
  
Galathea (RTX 4060 Ti):
  - Background batch processing agents
  - Data analysis and research agents
  - Long-running task agents
```

**AutoGen Configuration:**

```python
# Alfred: Primary Orchestrator
from autogen import Agent, ConversableAgent

orchestrator = ConversableAgent(
    "orchestrator",
    llm_config={"model": "gemma2:9b"},  # LM Studio on Alfred
    max_consecutive_auto_reply=5
)

# Galathea: Parallel Workers (via remote MCP)
from mcp_memory_service import MemoryClient

research_agent = ConversableAgent(
    "researcher",
    llm_config={"model": "mistral-nemo:12b"},  # LM Studio on Galathea
    tools=[MemoryClient.search, MemoryClient.store]
)
```

---

### 4. RAG (Retrieval-Augmented Generation) System

#### Recommended Architecture: **Distributed**

```
┌─────────────────────────────────────────────────────────────┐
│                    RAG Pipeline                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Master (M4 Max)                                            │
│  ├── Document Preprocessing                                 │
│  │   ├── PDF/TXT extraction                                  │
│  │   ├── Text chunking                                       │
│  │   └── Metadata tagging                                    │
│  │                                                         │
│  Alfred (RTX 4080)                                          │
│  ├── Embedding Generation (GPU accelerated)                 │
│  │   └── all-MiniLM-L6-v2 → 384-dim vectors                │
│  │                                                         │
│  ├── Vector Index Storage                                   │
│  │   └── MCP Memory Service (SQLite-vec backend)           │
│  │                                                         │
│  └── Query Processing                                       │
│      ├── Semantic search → relevant chunks                  │
│      └── Context injection into LLM prompt                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**RAG Workflow:**

1. **Indexing (Master)**: Process documents, create chunks
2. **Embedding (Alfred)**: Generate vectors using ONNX on GPU
3. **Storage (Alfred)**: Store in MCP Memory Service with SQLite-vec
4. **Query (Any)**: Semantic search → retrieve context → LLM generation

---

### 5. Saint Celestine (iPhone 16 Pro Max) - Mobile/Edge Use Cases

#### Recommended: **Lightweight Agents + Offline Mode**

**Capabilities:**

- A17 Pro GPU can run small ONNX models efficiently
- iOS 19 supports Core ML for optimized inference
- Limited RAM (8GB) requires careful model selection

**Use Cases:**

```python
# Mobile RAG Client
from mcp_memory_service import OfflineMemoryClient

client = OfflineMemoryClient(
    database_path="~/Library/Application Support/Memory/memory.db",
    embedding_model="all-MiniLM-L6-v2.onnx"  # ONNX for iOS Core ML
)

# Query memories offline
results = client.search("project architecture decisions")

# Sync when online
client.sync_to_cloud()  # Cloudflare backend optional
```

**Recommended Mobile Setup:**

- **Embeddings**: ONNX Runtime with Core ML backend (iOS optimized)
- **LLM**: Small model via LM Studio mobile or remote inference
- **Memory**: SQLite database, sync to Alfred when connected

---

## 🔄 Component Communication Architecture

### Local Network Topology:

```
192.168.1.x Network
├── Master (192.168.1.10) - Dev workstation
│   └── Port 3000: Frontend/UI
│   └── Port 5000: Agent orchestration API
│
├── Alfred (192.168.1.107) - Primary AI Server
│   ├── Port 8000: MCP Memory Service HTTP API
│   ├── Port 1234: LM Studio Embedding Server
│   └── Port 11434: Ollama/LM Studio LLM Server
│
├── Galathea (192.168.1.108) - Secondary AI Server
│   ├── Port 8001: MCP Memory Service HTTP API (replica)
│   └── Port 11435: Ollama/LM Studio LLM Server
│
└── Saint Celestine - Mobile Client
    └── WiFi connection to network services
```

### Communication Protocols:

| Component                              | Protocol           | Port      | Auth         |
|----------------------------------------|--------------------|-----------|--------------|
| MCP Memory Service (Alfred ↔ Galathea) | HTTP REST          | 8000/8001 | API Key      |
| LM Studio Embeddings                   | OpenAI-compatible  | 1234      | Bearer Token |
| LangGraph Agents                       | gRPC/WebSocket     | 5000      | mTLS         |
| AutoGen Workers                        | JSON-RPC over HTTP | 6000      | API Key      |

---

## 📈 Performance Expectations & Benchmarks

### Embedding Generation (ONNX + RTX 4080):

```
all-MiniLM-L6-v2:
- Batch size 32: ~5ms per text (GPU)
- Batch size 128: ~15ms per text (GPU)
- Single thread CPU: ~50ms per text
```

### Semantic Search (SQLite-vec + RTX 4080):

```
Memory Database Size | Query Time | Notes
--------------------|------------|-------
1,000 memories      | <2ms       | Instant
10,000 memories     | ~5ms       | Very fast
100,000 memories    | ~15ms      | Fast
1M+ memories        | ~30-50ms   | Good with proper indexing
```

### LLM Inference (RTX 4080):

```
Model Size | Tokens/sec | VRAM Usage | Quality
-----------|------------|------------|--------
7B params  | ~60 t/s    | ~6GB       | Good
13B params | ~35 t/s    | ~10GB      | Very good
30B params | ~15 t/s    | ~20GB      | Excellent (requires quantization)
```

---

## 🚀 Deployment Recommendations Summary

### Primary Setup (Recommended):

| Component                  | Location          | Justification                             |
|----------------------------|-------------------|-------------------------------------------|
| **MCP Memory Service**     | Alfred            | GPU acceleration, always-on               |
| **LangGraph Agents**       | Alfred            | Real-time orchestration needs             |
| **AutoGen Workers**        | Alfred + Galathea | Load balancing for parallel tasks         |
| **RAG Pipeline**           | Master → Alfred   | Preprocessing on dev, inference on server |
| **LM Studio Server**       | Alfred            | Centralized LLM/Embedding service         |
| **Saint Celestine Client** | Mobile (WiFi)     | Offline-capable mobile access             |

### Alternative Setup (Budget/Scale):

| Component              | Location          | Justification                                   |
|------------------------|-------------------|-------------------------------------------------|
| **MCP Memory Service** | Master only       | Development/testing, no GPU needed for small DB |
| **All Agents**         | Alfred            | Single server for simplicity                    |
| **RAG Pipeline**       | Alfred            | All-in-one solution                             |
| **LM Studio Server**   | Alfred + Galathea | Redundancy and load balancing                   |

---

## 🔧 Implementation Checklist

### Phase 1: MCP Memory Service (Alfred)

- [ ] Clone repository to `C:\Repositories\mcp-memory-service`
- [ ] Install Python 3.12+ with virtual environment
- [ ] Configure `MCP_MEMORY_STORAGE_BACKEND=sqlite_vec`
- [ ] Set `MCP_EMBEDDING_MODEL=all-MiniLM-L6-v2`
- [ ] Start HTTP server on port 8000
- [ ] Test embedding generation and semantic search

### Phase 2: LangGraph Integration (Alfred)

- [ ] Install LangGraph framework
- [ ] Configure MCP Memory Service client
- [ ] Create agent graph with memory-aware nodes
- [ ] Test multi-agent collaboration with shared memory

### Phase 3: AutoGen Setup (Alfred + Galathea)

- [ ] Install AutoGen on both servers
- [ ] Configure distributed agent groups
- [ ] Set up load balancing between Alfred and Galathea
- [ ] Test parallel task execution

### Phase 4: RAG Pipeline (Master → Alfred)

- [ ] Implement document ingestion workflow on Master
- [ ] Connect to Alfred's MCP Memory Service via HTTP API
- [ ] Configure embedding generation with ONNX Runtime
- [ ] Test end-to-end query and retrieval

### Phase 5: Mobile Integration (Saint Celestine)

- [ ] Set up iOS app with Core ML for embeddings
- [ ] Configure offline memory database sync
- [ ] Implement WiFi-based connectivity to Alfred services

---

## 📚 Additional Resources

- **LM Studio Docs**: https://lmstudio.ai/docs/developer
- **ONNX Runtime**: https://onnxruntime.ai/docs/
- **SQLite-vec Documentation**: https://github.com/asg017/sqlite-vec
- **LangGraph Framework**: https://langchain-ai.github.io/langgraph/
- **AutoGen**: https://microsoft.github.io/autogen/

---

*Last updated: 2026-01-30*
