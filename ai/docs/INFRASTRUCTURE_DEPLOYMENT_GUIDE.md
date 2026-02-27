# 🏗️ Complete Infrastructure & Deployment Guide

**Created:** 2026-01-30  
**Project:** Chat AI Platform with MCP Memory Service, LangGraph, AutoGen, RAG

---

## 📑 Document Index

1. **[Hardware Specifications & Strategy](../../.ai/docs/architecture/hardware-specs-and-deployment-strategy.md)** -
   Complete analysis of available hardware and component placement strategy
2. **Alfred Deployment Guide** (this file) - Step-by-step deployment instructions for Alfred server
3. [MCP Memory Service Setup on Windows](./memory-service/examples/setup_alfred_windows.md) - Manual PowerShell
   installation guide
4. [Deployment Script](./memory-service/scripts/deploy_alfred.sh) - Automated SSH deployment script

---

## 🎯 Quick Start Summary

### Available Infrastructure

| Machine                                 | Role                | CPU            | GPU                  | RAM       | OS           | Access                 |
|-----------------------------------------|---------------------|----------------|----------------------|-----------|--------------|------------------------|
| **Master** (M4 Max)                     | Dev workstation     | M4 Max 16-core | 128GB Unified        | macOS 15  | Local ✅      |
| **Alfred** (RTX 4080)                   | AI Server           | Ryzen 9 7950X  | RTX 4080 16GB VRAM   | 64GB DDR5 | Windows 11   | SSH: e@192.168.1.107 ✅ |
| **Galathea** (RTX 4060 Ti)              | Secondary AI Server | Ryzen 7 5800X  | RTX 4060 Ti 8GB VRAM | 32GB DDR4 | Windows 11   | SSH: remote ⚠️         |
| **Saint Celestine** (iPhone 16 Pro Max) | Mobile Client       | A17 Pro GPU    | 8GB Unified Memory   | iOS 19    | WiFi/Xcode ✅ |

---

## 🚀 Deployment Checklist for Alfred

### Prerequisites

- [x] SSH key authentication configured (`~/.ssh/id_ed25519`)
- [x] Public key added to Alfred's `C:\Users\e\.ssh\authorized_keys`
- [x] Git Bash or WSL installed on Master (for deployment script)

### Installation Steps

#### Option A: Automated SSH Deployment (Recommended ⭐)

```bash
# 1. Make deployment script executable
chmod +x .ai/mcp/memory-service/scripts/deploy_alfred.sh

# 2. Deploy fresh installation
./scripts/deploy_alfred.sh install

# 3. Check status
./scripts/deploy_alfred.sh status

# 4. Start server
./scripts/deploy_alfred.sh start

# 5. View logs (follow mode)
./scripts/deploy_alfred.sh logs
```

#### Option B: Manual PowerShell Deployment

See: [setup_alfred_windows.md](./memory-service/examples/setup_alfred_windows.md) for detailed instructions.

---

## 📊 What Gets Deployed on Alfred

### 1. MCP Memory Service (Primary Component)

- **Port:** 8000
- **Backend:** SQLite-vec with ONNX embeddings
- **Embedding Model:** `all-MiniLM-L6-v2` (~85MB, optimized for GPU via ONNX)
- **Features Enabled:**
    - ✅ Semantic search (5ms query time)
    - ✅ Quality scoring (ONNX-based)
    - ✅ Memory consolidation (decay + clustering)
    - ✅ HTTP API for external access

### 2. LangGraph Agents (Production Workload)

- **LLM Backend:** Local models via LM Studio or Ollama on Alfred
- **Memory Integration:** All agents share MCP Memory Service
- **Use Cases:**
    - Research Agent with persistent knowledge base
    - Code analysis agent with project context
    - Planning agent with decision history

### 3. AutoGen Workers (Optional)

- **Distribution:** Primary workers on Alfred, secondary on Galathea for load balancing
- **Parallel Tasks:** Data processing, batch operations, long-running tasks

---

## 🔧 Post-Deployment Verification

```bash
# Test health endpoint
curl http://192.168.1.107:8000/health

# Expected: {"status": "ok"}

# Store a test memory
curl -X POST http://192.168.1.107:8000/api/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "Deployment test", "tags": ["test"], "type": "observation"}'

# Search for the memory
curl -X POST http://192.168.1.107:8000/api/memories/search \
  -H "Content-Type: application/json" \
  -d '{"query": "deployment", "limit": 5}'

# Check web dashboard (optional)
open http://192.168.1.107:8000
```

---

## 🌐 Integration with Other Components

### Claude Desktop Configuration (On Master)

Create `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "memory-http": {
      "transportType": "http",
      "url": "http://192.168.1.107:8000/mcp"
    }
  }
}
```

### LangGraph Integration (On Alfred)

```python
from langgraph.graph import StateGraph, MessagesState
from mcp_memory_service.client import MemoryClient

# Initialize shared memory client
memory = MemoryClient(base_url="http://localhost:8000")

# Create agent nodes with memory integration
def research_node(state: MessagesState):
    # Retrieve relevant memories for context
    memories = memory.search(
        query=state["messages"][-1].content,
        limit=5
    )
    # ... continue processing with retrieved context
```

### AutoGen Worker Configuration (Alfred + Galathea)

See: [Hardware Strategy Guide](../../.ai/docs/architecture/hardware-specs-and-deployment-strategy.md#3-autogen-agents)
for distributed setup details.

---

## 📈 Performance Expectations on Alfred (RTX 4080)

| Operation                                         | Time           | Notes                  |
|---------------------------------------------------|----------------|------------------------|
| Embedding generation (single text via ONNX + GPU) | ~5ms           | `all-MiniLM-L6-v2`     |
| Semantic search (1K memories in SQLite-vec)       | <2ms           | GPU acceleration       |
| Semantic search (100K memories)                   | ~8ms           | With proper indexing   |
| Memory storage (with embedding generation)        | ~15ms          | Includes vectorization |
| LLM inference (7B params, quantized)              | ~60 tokens/sec | RTX 4080               |
| LLM inference (13B params, quantized)             | ~35 tokens/sec | RTX 4080               |

---

## 🔄 Maintenance Commands

```bash
# Update to latest version
./scripts/deploy_alfred.sh update

# Restart server (zero downtime pattern)
./scripts/deploy_alfred.sh stop
sleep 2
./scripts/deploy_alfred.sh start

# View logs
./scripts/deploy_alfred.sh logs

# Check status
./scripts/deploy_alfred.sh status
```

---

## 🎯 Next Steps in Project Roadmap

### Phase 1: MCP Memory Service on Alfred ✅ (This Deployment)

- [x] Deploy to Alfred via SSH automation
- [x] Verify server operations
- [x] Test API endpoints and semantic search

### Phase 2: LangGraph Integration (Next Sprint)

- [ ] Create orchestrator agent with shared memory
- [ ] Implement multi-agent collaboration patterns
- [ ] Add memory-aware decision nodes
- [ ] Test with real-world use cases

### Phase 3: AutoGen Distributed Setup

- [ ] Install AutoGen on Alfred + Galathea
- [ ] Configure distributed worker groups
- [ ] Set up load balancing between servers
- [ ] Implement cross-server memory sharing

### Phase 4: RAG Pipeline Integration

- [ ] Document ingestion workflow (Master → Alfred)
- [ ] Connect to MCP Memory Service via HTTP API
- [ ] Test end-to-end retrieval and generation
- [ ] Optimize chunking and embedding strategies

---

## 📚 Related Documentation

| Document                   | Description                                                           | Location                                                                |
|----------------------------|-----------------------------------------------------------------------|-------------------------------------------------------------------------|
| **Hardware Strategy**      | Complete infrastructure analysis, component placement recommendations | `../../.ai/docs/architecture/hardware-specs-and-deployment-strategy.md` |
| **Alfred Manual Setup**    | Detailed PowerShell installation instructions                         | `./memory-service/examples/setup_alfred_windows.md`                     |
| **Deployment Script**      | Automated SSH deployment script                                       | `./memory-service/scripts/deploy_alfred.sh`                             |
| **LM Studio & Embeddings** | Explanation of embedding models and LM Studio usage                   | See Hardware Strategy doc, Section 2                                    |

---

## 🆘 Troubleshooting Quick Reference

### Issue: SSH Connection Failed

```bash
# Check connectivity
ping 192.168.1.107

# Test SSH with verbose output
ssh -v e@192.168.1.107 "echo 'Connection successful'"

# Verify key permissions
chmod 600 ~/.ssh/id_ed25519
```

### Issue: Port 8000 Already in Use

```powershell
# On Alfred, find process using port 8000
netstat -ano | findstr ":8000"

# Kill the process
taskkill /PID <process_id> /F

# Or use different port
python scripts/server/run_memory_server.py --http --port 8001
```

### Issue: Server Not Starting

```bash
# Check logs
./scripts/deploy_alfred.sh logs

# Verify Python installation on Alfred
ssh e@192.168.1.107 "python --version"

# Reinstall dependencies
./scripts/deploy_alfred.sh update
```

---

## 📞 Support & Resources

- **MCP Memory Service Docs**: https://github.com/Nearbe/mcp-memory-service/tree/main/docs
- **LM Studio**: https://lmstudio.ai/ - Local AI with embedding support
- **LangGraph Framework**: https://langchain-ai.github.io/langgraph/
- **AutoGen**: https://microsoft.github.io/autogen/

---

*Last updated: 2026-01-30*  
*Maintained by: Nearbe*
