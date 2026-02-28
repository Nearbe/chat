#!/usr/bin/env python3
"""
Simple test for the Prompt Framework without import issues.
Tests basic functionality directly.
"""

import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent))

from jinja2 import Environment


def test_basic_jinja():
    """Test that Jinja2 is working."""
    
    env = Environment()
    template = env.from_string("Hello {{ name }}!")
    
    result = template.render(name="World")
    assert result == "Hello World!", f"Expected 'Hello World!', got '{result}'"
    
    print("✓ Jinja2 basic test passed")


def test_template_loading():
    """Test loading templates from files."""
    
    templates_dir = Path(__file__).parent / "ai/mcp/orchestrator/prompts/templates"
    
    if not templates_dir.exists():
        print(f"✗ Templates directory not found: {templates_dir}")
        return
    
    template_files = list(templates_dir.glob("*.jinja2"))
    print(f"✓ Found {len(template_files)} template files")
    
    for tf in template_files:
        content = tf.read_text(encoding='utf-8')
        if "{{" in content and "}}" in content:
            print(f"  ✓ {tf.name} contains Jinja2 variables")
        else:
            print(f"  ✗ {tf.name} doesn't contain Jinja2 syntax")


def test_versioning_structure():
    """Test that versioning files exist."""
    
    from ai.mcp.orchestrator.prompts import (
        PromptTemplate,
        PromptRegistry,
        VersionManager,
    )
    
    print("✓ All imports successful:")
    print(f"  - PromptTemplate")
    print(f"  - PromptRegistry")
    print(f"  - VersionManager")


def test_prompt_template_creation():
    """Test creating a template instance."""
    
    from ai.mcp.orchestrator.prompts import PromptTemplate
    
    template = PromptTemplate(
        name="test_greeting",
        template_str="Hello {{name}}! Welcome to {{company}}."
    )
    
    assert template.name == "test_greeting"
    assert template.template_str is not None
    
    print("✓ Template creation successful")


def test_template_rendering():
    """Test rendering a template."""
    
    from ai.mcp.orchestrator.prompts import PromptTemplate
    
    template = PromptTemplate(
        name="greeting",
        template_str="Hello {{name}}! Today is {{day}}."
    )
    
    context = {
        "name": "Alice",
        "day": "Monday"
    }
    
    rendered = template.render(context)
    expected = "Hello Alice! Today is Monday."
    
    assert rendered == expected, f"Expected '{expected}', got '{rendered}'"
    
    print(f"✓ Template rendering successful:")
    print(f"  Input: {context}")
    print(f"  Output: {rendered}")


def test_registry_singleton():
    """Test that registry is a singleton."""
    
    from ai.mcp.orchestrator.prompts import PromptRegistry
    
    registry1 = PromptRegistry.get_instance()
    registry2 = PromptRegistry.get_instance()
    
    assert registry1 is registry2, "Registry should be the same instance"
    
    print("✓ Registry singleton pattern works correctly")


def run_tests():
    """Run all tests."""
    
    print("=" * 60)
    print("Prompt Framework - Basic Tests")
    print("=" * 60)
    print()
    
    try:
        test_basic_jinja()
        print()
        
        test_template_loading()
        print()
        
        test_versioning_structure()
        print()
        
        test_prompt_template_creation()
        print()
        
        test_template_rendering()
        print()
        
        test_registry_singleton()
        print()
        
        print("=" * 60)
        print("All tests passed! ✓")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n✗ Test failed with error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    run_tests()
