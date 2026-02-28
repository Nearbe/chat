# Prompt Engineering Framework

Comprehensive framework for managing, versioning, and rendering AI system prompts with Jinja2 templates and full version control support.

## 📦 Installation

This framework requires Jinja2:

```bash
pip install jinja2
```

## 🚀 Quick Start

### Basic Template Usage

```python
from ai.mcp.orchestrator.prompts import PromptTemplate

# Create a template
template = PromptTemplate(
    name="greeting",
    template_str="Hello {{name}}! Welcome to {{organization}}."
)

# Render with context
context = {
    "name": "Alice",
    "organization": "AI Corp"
}

rendered = template.render(context)
print(rendered)  # Hello Alice! Welcome to AI Corp.
```

### Loading Templates from Files

```python
from pathlib import Path
from ai.mcp.orchestrator.prompts import PromptTemplate

# Load from file
template = PromptTemplate.from_file("templates/system_prompt.jinja2")

context = {
    "assistant_name": "ChatBot",
    "organization": "My Company"
}

rendered = template.render(context)
```

### Using the Global Registry

```python
from ai.mcp.orchestrator.prompts import PromptRegistry, PromptTemplate

# Get singleton registry instance
registry = PromptRegistry.get_instance()

# Register a template
template = PromptTemplate(
    name="greeting",
    template_str="Welcome, {{username}}!"
)
registry.register("greeting", template, category="notifications")

# Render registered template
rendered = registry.render("greeting", {"username": "John"})
```

### Template Versioning

```python
from ai.mcp.orchestrator.prompts import VersionManager

# Create version manager for a template
vm = VersionManager("system_prompt")

# Create versions
version1 = vm.create_version(
    content="Initial prompt",
    changelog="First version",
    author="developer"
)

version2 = vm.create_version(
    content="Updated prompt with new features",
    changelog="Added error handling",
    author="developer"
)

# List versions
versions = vm.list_versions()
for v in versions:
    print(f"{v.version}: {v.changelog}")
```

## 📁 Project Structure

```
ai/mcp/orchestrator/prompts/
├── __init__.py              # Module initialization and exports
├── base.py                  # PromptTemplate class (core functionality)
├── registry.py              # Global registry for template management
├── versioning.py            # Version control system for prompts
├── examples.py              # Usage examples and demonstrations
└── templates/               # Jinja2 template files
    ├── base_system_prompt.jinja2   # Base system prompt template
    ├── tool_call.jinja2            # Tool calling instructions template
    └── error_handling.jinja2       # Error handling template
```

## 🛠️ Components

### PromptTemplate

Core class for managing Jinja2-based templates.

**Features:**
- Template loading from string or file
- Context validation before rendering
- Render caching for performance
- Hash-based integrity checking

**Methods:**
- `__init__(name, template_str=None)` - Initialize with name and optional content
- `from_file(path)` - Load template from file (class method)
- `render(context)` - Render template with provided variables
- `validate_context(context)` - Check for missing required variables
- `get_template_info()` - Get metadata about the template

### PromptRegistry

Singleton registry for managing templates across the application.

**Features:**
- Global access to all registered templates
- Category-based organization
- Automatic name validation
- Easy retrieval and rendering

**Methods:**
- `get_instance()` - Get singleton instance
- `register(name, template, category)` - Register a new template
- `get(name)` - Retrieve a registered template
- `render(name, context)` - Render a registered template
- `list_all()` - List all registered templates
- `list_by_category(category)` - Filter by category

### VersionManager

Version control system for prompt templates.

**Features:**
- Semantic versioning (major.minor.patch)
- Change history and changelog tracking
- Branch support (main, experimental)
- Rollback capabilities
- JSON-based persistence

**Methods:**
- `create_version(content, changelog, author)` - Create new version
- `get_latest_version(branch)` - Get most recent version
- `list_versions(branch)` - List all versions on a branch
- `rollback_to(version_str)` - Revert to specific version
- `export_version(version_str, output_path)` - Export to file

## 📝 Template Syntax

This framework uses Jinja2 templating engine. Common features:

### Variables
```jinja2
Hello {{ name }}!
```

### Conditionals
```jinja2
{% if show_details %}
  Details are shown here
{% endif %}
```

### Loops
```jinja2
{% for item in items %}
  - {{ item.name }}
{% endfor %}
```

### Filters
```jinja2
{{ name | upper }}
{{ date | strftime("%Y-%m-%d") }}
```

## 🔧 Best Practices

1. **Use meaningful template names**: Choose descriptive identifiers like "system_prompt" instead of "template1"
2. **Validate context before rendering**: Always check for missing variables to catch errors early
3. **Write clear changelogs**: Document what changed in each version
4. **Use categories**: Organize templates by purpose (e.g., "notifications", "errors")
5. **Leverage caching**: The framework automatically caches rendered templates for performance

## 🧪 Testing

Run the example tests:

```bash
python ai/mcp/orchestrator/prompts/examples.py
```

Or run individual examples:

```python
from ai.mcp.orchestrator.prompts.examples import (
    example_basic_usage,
    example_file_loading,
    # ... other examples
)

example_basic_usage()
```

## 📚 Advanced Usage

### Custom Categories

```python
registry = PromptRegistry.get_instance()
template = PromptTemplate(...)
registry.register("my_template", template, category="custom_category")
templates = registry.list_by_category("custom_category")
```

### Template Hashing for Integrity

```python
template = PromptTemplate.from_file("path/to/template.jinja2")
info = template.get_template_info()
print(f"Hash: {info['hash']}")
```

### Branch Management in Versioning

```python
vm = VersionManager("system_prompt")
vm.create_branch("experimental", from_branch="main")

# Create version on experimental branch
version = vm.create_version(
    content="Experimental features",
    changelog="Testing new approach",
    author="developer",
    branch="experimental"
)
```

## 🐛 Troubleshooting

### Template Not Found
Ensure the template file exists and the path is correct. Use `from_file()` class method for loading from disk.

### Missing Variables in Context
Use `validate_context(context)` before rendering to check for missing variables:

```python
missing = template.validate_context(context)
if missing:
    raise ValueError(f"Missing required variables: {missing}")
rendered = template.render(context)
```

### Version Management Issues
Check that the storage directory has write permissions and the JSON file is not corrupted.

## 📄 License

This framework is part of the Chat project. See the main repository for license information.
