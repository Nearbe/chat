"""
Prompt Framework Usage Examples

Demonstrates how to use the Prompt Engineering Framework for managing and rendering prompts.
"""

from pathlib import Path
from ai.mcp.orchestrator.prompts import (
    PromptTemplate,
    PromptRegistry,
    VersionManager,
)


def example_basic_usage():
    """Example 1: Basic template usage."""
    
    # Create a simple template
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
    print(f"Rendered: {rendered}")
    # Output: Hello Alice! Welcome to AI Corp.


def example_file_loading():
    """Example 2: Loading templates from files."""
    
    # Load template from file
    template_path = Path(__file__).parent / "templates" / "base_system_prompt.jinja2"
    
    try:
        template = PromptTemplate.from_file(template_path)
        
        context = {
            "assistant_name": "ChatBot",
            "organization": "My Company",
            "capabilities": "Text processing, Q&A, Code assistance",
            "current_datetime": "2024-12-19 10:30:00 UTC",
            "context": "User is asking for help with a task",
            "instructions": "Be helpful and concise"
        }
        
        rendered = template.render(context)
        print(f"System prompt loaded successfully!\nLength: {len(rendered)} characters")
        
    except FileNotFoundError as e:
        print(f"Template file not found: {e}")


def example_registry_usage():
    """Example 3: Using the global registry."""
    
    # Get the singleton registry instance
    registry = PromptRegistry.get_instance()
    
    # Register a template
    greeting_template = PromptTemplate(
        name="greeting",
        template_str="Welcome, {{username}}! You have {{message_count}} messages."
    )
    
    try:
        registry.register("greeting", greeting_template, category="notifications")
        print("✓ Template registered successfully")
    except Exception as e:
        print(f"Registration failed (might already exist): {e}")
    
    # List all templates
    all_templates = registry.list_all()
    print(f"\nRegistered templates ({len(all_templates)}): {all_templates}")
    
    # Render a registered template
    try:
        rendered = registry.render("greeting", {
            "username": "John Doe",
            "message_count": 5
        })
        print(f"\nRendered from registry:\n{rendered}")
    except Exception as e:
        print(f"Rendering failed: {e}")


def example_versioning():
    """Example 4: Template versioning."""
    
    # Create a version manager for a template
    vm = VersionManager("system_prompt")
    
    # Create initial version
    version1 = vm.create_version(
        content="You are a helpful assistant. Version 1.",
        changelog="Initial version",
        author="developer"
    )
    print(f"Created version: {version1.version}")
    
    # Create updated version
    version2 = vm.create_version(
        content="You are a helpful assistant with enhanced capabilities. Version 2.",
        changelog="Added new features and improved responses",
        author="developer"
    )
    print(f"Created version: {version2.version}")
    
    # List all versions
    versions = vm.list_versions()
    print(f"\nVersion history ({len(versions)} versions):")
    for v in versions:
        print(f"  - {v.version}: {v.changelog[:50]}...")


def example_validation():
    """Example 5: Context validation."""
    
    template = PromptTemplate(
        name="test",
        template_str="Hello {{name}}, you are from {{city}}."
    )
    
    # Valid context
    valid_context = {
        "name": "Alice",
        "city": "New York"
    }
    
    missing_vars = template.validate_context(valid_context)
    print(f"\nValidation with valid context: {missing_vars}")  # Should be []
    
    # Invalid context (missing variables)
    invalid_context = {
        "name": "Alice"
        # Missing 'city'
    }
    
    missing_vars = template.validate_context(invalid_context)
    print(f"Validation with incomplete context: {missing_vars}")  # Should include 'city'


def example_error_handling():
    """Example 6: Error handling in rendering."""
    
    template = PromptTemplate(
        name="test",
        template_str="Hello {{name}}!"
    )
    
    try:
        # This will fail because 'name' is missing
        result = template.render({})
        print(f"Rendered: {result}")
    except Exception as e:
        print(f"\nCaught expected error: {type(e).__name__}")


def run_all_examples():
    """Run all example functions."""
    
    print("=" * 60)
    print("Prompt Engineering Framework - Usage Examples")
    print("=" * 60)
    
    print("\n1. Basic Template Usage:")
    print("-" * 40)
    example_basic_usage()
    
    print("\n2. File Loading:")
    print("-" * 40)
    example_file_loading()
    
    print("\n3. Registry Usage:")
    print("-" * 40)
    example_registry_usage()
    
    print("\n4. Versioning:")
    print("-" * 40)
    example_versioning()
    
    print("\n5. Validation:")
    print("-" * 40)
    example_validation()
    
    print("\n6. Error Handling:")
    print("-" * 40)
    example_error_handling()
    
    print("\n" + "=" * 60)
    print("All examples completed!")
    print("=" * 60)


if __name__ == "__main__":
    run_all_examples()
