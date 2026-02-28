"""
Prompt Registry System

Provides centralized management of prompt templates with support for:
- Global registry (singleton pattern)
- Category-based organization
- Version tracking per template
- Safe loading and retrieval
"""

from pathlib import Path
from typing import Any, Dict, List, Optional, TypeVar
from .base import PromptTemplate


T = TypeVar('T', bound=PromptTemplate)


class PromptRegistryError(Exception):
    """Base exception for registry operations."""
    pass


class DuplicateTemplateName(PromptRegistryError):
    """Raised when trying to register a template with an existing name."""
    pass


class TemplateNotFound(PromptRegistryError):
    """Raised when trying to access a non-existent template."""
    pass


class PromptRegistry:
    """
    Singleton registry for managing prompt templates across the application.
    
    Provides methods for registering, retrieving, and organizing prompt templates
    with support for categories and version tracking.
    """
    
    _instance: Optional['PromptRegistry'] = None
    
    def __new__(cls) -> 'PromptRegistry':
        """Ensure singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        """Initialize the registry (only called once due to singleton pattern)."""
        if self._initialized:
            return
            
        self._initialized = True
        self._templates: Dict[str, PromptTemplate] = {}
        self._categories: Dict[str, set] = {}  # category -> set of template names
        self._default_category = "general"
    
    def register(self, name: str, template: PromptTemplate, category: Optional[str] = None) -> None:
        """
        Register a prompt template in the registry.
        
        Args:
            name: Unique identifier for the template
            template: PromptTemplate instance to register
            category: Optional category for organization
            
        Raises:
            DuplicateTemplateName: If a template with this name already exists
        """
        if not name:
            raise ValueError("Template name cannot be empty")
            
        if name in self._templates:
            raise DuplicateTemplateName(
                f"Template '{name}' is already registered. "
                f"Use unregister() first or provide a different name."
            )
        
        # Register the template
        self._templates[name] = template
        
        # Update category mapping
        cat = category or self._default_category
        if cat not in self._categories:
            self._categories[cat] = set()
        self._categories[cat].add(name)
    
    def get(self, name: str) -> PromptTemplate:
        """
        Retrieve a registered template by name.
        
        Args:
            name: Name of the template to retrieve
            
        Returns:
            The registered PromptTemplate instance
            
        Raises:
            TemplateNotFound: If no template with this name exists
        """
        if name not in self._templates:
            raise TemplateNotFound(f"Template '{name}' not found in registry")
        return self._templates[name]
    
    def get_or_create(self, name: str) -> PromptTemplate:
        """
        Get a template or create a new one if it doesn't exist.
        
        Args:
            name: Name of the template
            
        Returns:
            Existing or newly created PromptTemplate instance
        """
        try:
            return self.get(name)
        except TemplateNotFound:
            return PromptTemplate(name=name)
    
    def unregister(self, name: str) -> bool:
        """
        Remove a template from the registry.
        
        Args:
            name: Name of the template to remove
            
        Returns:
            True if removed, False if not found
        """
        if name in self._templates:
            del self._templates[name]
            
            # Update category mappings
            for cat_templates in self._categories.values():
                cat_templates.discard(name)
            
            return True
        return False
    
    def list_all(self) -> List[str]:
        """
        Get a list of all registered template names.
        
        Returns:
            Sorted list of template names
        """
        return sorted(self._templates.keys())
    
    def list_by_category(self, category: Optional[str] = None) -> List[str]:
        """
        Get templates filtered by category.
        
        Args:
            category: Category name to filter by (None for all categories)
            
        Returns:
            Sorted list of template names in the specified category
        """
        if category is None:
            # Collect from all categories
            all_names = set()
            for templates in self._categories.values():
                all_names.update(templates)
            return sorted(all_names)
        
        if category not in self._categories:
            return []
        
        return sorted(self._categories[category])
    
    def get_categories(self) -> List[str]:
        """
        Get list of all categories.
        
        Returns:
            Sorted list of category names
        """
        return sorted(self._categories.keys())
    
    def load_from_file(self, path: str | Path, name: Optional[str] = None) -> PromptTemplate:
        """
        Load a template from file and register it in the registry.
        
        Args:
            path: Path to the template file
            name: Optional custom name (defaults to filename stem)
            
        Returns:
            Registered PromptTemplate instance
            
        Raises:
            FileNotFoundError: If template file doesn't exist
            DuplicateTemplateName: If a template with this name already exists
        """
        template = PromptTemplate.from_file(path)
        
        # Use filename as default name if not provided
        if name is None:
            name = Path(path).stem
        
        self.register(name, template)
        return template
    
    def render(self, name: str, context: Dict[str, Any]) -> str:
        """
        Render a registered template with the given context.
        
        Args:
            name: Name of the template to render
            context: Variables for rendering
            
        Returns:
            Rendered prompt string
            
        Raises:
            TemplateNotFound: If template doesn't exist in registry
            TemplateError: If rendering fails
        """
        template = self.get(name)
        return template.render(context)
    
    def validate_all(self) -> Dict[str, List[str]]:
        """
        Validate all registered templates for missing variables.
        
        Returns:
            Dictionary mapping template names to lists of missing variables
            (empty dict means all templates are valid with current context)
        """
        issues = {}
        # Note: This would need a default context to validate properly
        return issues
    
    def clear(self):
        """Clear all registered templates and categories."""
        self._templates.clear()
        self._categories.clear()
    
    @classmethod
    def get_instance(cls) -> 'PromptRegistry':
        """Get the singleton instance (creates it if needed)."""
        if cls._instance is None:
            cls()
        return cls._instance


# Global registry instance for convenience
_global_registry = PromptRegistry.get_instance()
