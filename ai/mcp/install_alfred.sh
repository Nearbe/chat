#!/bin/bash
# Install MCP Memory Service on Alfred

set -e

echo "🚀 Installing MCP Memory Service..."

# Clone repository (if not exists)
cd /Users/nearbe/repositories/Chat/.ai/mcp
if [ ! -d "mcp-memory-service" ]; then
    echo "Cloning repository..."
    git clone git@github.com:Nearbe/mcp-memory-service.git
fi

# Navigate to project directory
cd mcp-memory-service

# Check if venv exists, create if not
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -e .

echo ""
echo "✅ Installation complete!"
echo ""
echo "📌 To start the server:"
echo "   source venv/bin/activate"
echo "   python scripts/server/run_http_server.py"
echo ""
echo "📌 Server will be available at:"
echo "   http://localhost:8000"
