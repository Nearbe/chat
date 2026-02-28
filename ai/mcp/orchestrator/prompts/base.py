"""
Base Prompt Template Class

Provides the core functionality for loading, rendering, and validating 
Jinja2-based prompt templates with caching support.
"""

import hashlib
from pathlib import Path
from typing import Any, Dict, Optional, Set
from jinja2 import Environment, FileSystemLoader, TemplateError


class PromptTemplate:
    """
    A class representing a Jinja2-based prompt template with caching and validation.
    
    Attributes:
        name (str): Unique identifier for the template
        template_str (Optional[str]): Raw template string if provided directly
        rendered_cache (Dict[str, str]): Cache for rendered templates by context hash
    """
    
    # Global cache across all instances for performance
    _template_cache: Dict[str, 'Environment'] = {}
    
    def __init__(self, name: str, template_str: Optional[str] = None):
        """
        Initialize a PromptTemplate instance.
        
        Args:
            name: Unique identifier for this template (e.g., "system_prompt")
            template_str: Raw Jinja2 template string. If None, must be loaded via from_file()
        """
        if not name:
            raise ValueError("Template name cannot be empty")
            
        self.name = name
        self.template_str = template_str
        self._environment: Optional[Environment] = None
        self._rendered_cache: Dict[str, str] = {}
        
        # Register this instance in global cache if template is provided
        if template_str:
            self._register_in_cache()
    
    @classmethod
    def from_file(cls, path: str | Path) -> 'PromptTemplate':
        """
        Load a prompt template from a file.
        
        Args:
            path: Path to the Jinja2 template file (.jinja2 or .j2 extension recommended)
            
        Returns:
            PromptTemplate instance loaded from file
            
        Raises:
            FileNotFoundError: If template file doesn't exist
            ValueError: If file is empty or contains invalid Jinja2 syntax
        """
        path = Path(path)
        
        if not path.exists():
            raise FileNotFoundError(f"Template file not found: {path}")
            
        content = path.read_text(encoding='utf-8')
        if not content.strip():
            raise ValueError(f"Template file is empty: {path}")
            
        template_name = path.stem
        
        try:
            return cls(name=template_name, template_str=content)
        except Exception as e:
            raise ValueError(f"Failed to load template from {path}: {e}")
    
    def _register_in_cache(self):
        """Register this template in the global environment cache."""
        if self.name not in self._environment and self.template_str:
            env = Environment(
                loader=FileSystemLoader('.'),
                autoescape=False,  # We want raw text for prompts
                trim_blocks=True,
                lstrip_blocks=True
            )
            
            # Compile template and cache it
            compiled_template = env.from_string(self.template_str)
            self._environment = env
            
            # Store in global cache with hash as key
            template_hash = self._compute_hash()
            self._template_cache[template_hash] = {
                'env': env,
                'template': compiled_template
            }
    
    def _compute_hash(self) -> str:
        """Compute a unique hash for this template based on name and content."""
        content = f"{self.name}:{self.template_str or ''}"
        return hashlib.sha256(content.encode('utf-8')).hexdigest()[:16]
    
    def render(self, context: Dict[str, Any]) -> str:
        """
        Render the template with the provided context.
        
        Args:
            context: Dictionary of variables to substitute in the template
            
        Returns:
            Rendered prompt string
            
        Raises:
            TemplateError: If rendering fails due to missing variables or syntax errors
        """
        # Check cache first
        context_hash = hashlib.sha256(str(context).encode('utf-8')).hexdigest()
        if context_hash in self._rendered_cache:
            return self._rendered_cache[context_hash]
        
        try:
            if not self.template_str:
                raise TemplateError(f"No template content loaded for '{self.name}'")
            
            env = Environment(
                autoescape=False,
                trim_blocks=True,
                lstrip_blocks=True
            )
            
            template = env.from_string(self.template_str)
            rendered = template.render(**context)
            
            # Cache the result
            self._rendered_cache[context_hash] = rendered
            
            return rendered
            
        except TemplateError as e:
            raise TemplateError(f"Failed to render template '{self.name}': {e}")
        except Exception as e:
            raise TemplateError(f"Unexpected error rendering template '{self.name}': {e}")
    
    def validate_context(self, context: Dict[str, Any]) -> list[str]:
        """
        Validate that all required variables are present in the context.
        
        Args:
            context: Dictionary to validate
            
        Returns:
            List of missing variable names (empty if all required variables are present)
        """
        if not self.template_str:
            return []
            
        try:
            env = Environment()
            template = env.from_string(self.template_str)
            
            # Get all undeclared parameters from the template
            required_vars = set(template.undefined_parameters)
            
            # Filter out built-in undefined checks
            required_vars.discard('undefined')
            
            missing = [var for var in required_vars if var not in context]
            return missing
            
        except Exception:
            # If we can't parse the template, skip validation
            return []
    
    def get_template_info(self) -> Dict[str, Any]:
        """
        Get metadata about this template.
        
        Returns:
            Dictionary with template information including name and hash
        """
        return {
            'name': self.name,
            'hash': self._compute_hash(),
            'has_content': bool(self.template_str),
            'cache_size': len(self._rendered_cache)
        }
    
    def clear_cache(self):
        """Clear the render cache for this template instance."""
        self._rendered_cache.clear()
    
    def __repr__(self) -> str:
        return f"PromptTemplate(name='{self.name}', hash='{self._compute_hash()}')"
