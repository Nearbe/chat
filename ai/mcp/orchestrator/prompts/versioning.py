"""
Prompt Versioning System

Provides comprehensive version control for prompt templates including:
- Semantic versioning (major.minor.patch)
- Change history and changelog tracking
- Branch support (main, experimental)
- Rollback capabilities
"""

import json
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional


@dataclass
class PromptVersion:
    """
    Represents a single version of a prompt template.
    
    Attributes:
        version (str): Semantic version string (e.g., "1.0.0")
        timestamp (datetime): When this version was created
        author (Optional[str]): Author/creator identifier
        changelog (str): Description of changes in this version
        content_hash (str): SHA256 hash of the template content for integrity checking
        metadata (Dict[str, Any]): Additional custom metadata
    """
    
    version: str
    timestamp: datetime = field(default_factory=datetime.now)
    author: Optional[str] = None
    changelog: str = ""
    content_hash: str = ""
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization."""
        return {
            'version': self.version,
            'timestamp': self.timestamp.isoformat(),
            'author': self.author,
            'changelog': self.changelog,
            'content_hash': self.content_hash,
            'metadata': self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'PromptVersion':
        """Create instance from dictionary."""
        timestamp_str = data.get('timestamp')
        if isinstance(timestamp_str, str):
            timestamp = datetime.fromisoformat(timestamp_str)
        else:
            timestamp = datetime.now()
            
        return cls(
            version=data['version'],
            timestamp=timestamp,
            author=data.get('author'),
            changelog=data.get('changelog', ''),
            content_hash=data.get('content_hash', ''),
            metadata=data.get('metadata', {})
        )


class VersionManager:
    """
    Manages versioning for prompt templates with file-based storage.
    
    Provides methods for creating versions, tracking history, and rollback capabilities.
    """
    
    VERSIONS_FILE = "versions.json"
    SUPPORTED_BRANCHES = ['main', 'experimental']
    
    def __init__(self, template_name: str, storage_path: Optional[str | Path] = None):
        """
        Initialize version manager for a specific template.
        
        Args:
            template_name: Name of the template being versioned
            storage_path: Directory to store version history (defaults to same directory as template)
        """
        self.template_name = template_name
        
        if isinstance(storage_path, Path):
            self.storage_path = storage_path
        else:
            # Default to current working directory
            self.storage_path = Path.cwd() / "prompt_versions" / f"{template_name}"
            self.storage_path.mkdir(parents=True, exist_ok=True)
        
        self.versions_file = self.storage_path / self.VERSIONS_FILE
    
    def _load_versions(self) -> Dict[str, List[PromptVersion]]:
        """Load version history from storage."""
        if not self.versions_file.exists():
            return {}
            
        try:
            with open(self.versions_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Convert back to PromptVersion objects
            result = {}
            for branch, versions in data.items():
                result[branch] = [PromptVersion.from_dict(v) for v in versions]
            
            return result
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Warning: Failed to load version history: {e}")
            return {}
    
    def _save_versions(self, versions_data: Dict[str, List[PromptVersion]]):
        """Save version history to storage."""
        # Ensure directory exists
        self.storage_path.mkdir(parents=True, exist_ok=True)
        
        # Convert to serializable format
        data = {}
        for branch, versions in versions_data.items():
            data[branch] = [v.to_dict() for v in versions]
        
        with open(self.versions_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
    
    def _compute_content_hash(self, content: str) -> str:
        """Compute SHA256 hash of template content."""
        import hashlib
        return hashlib.sha256(content.encode('utf-8')).hexdigest()[:16]
    
    def create_version(
        self, 
        content: str, 
        changelog: str = "", 
        author: Optional[str] = None,
        branch: str = "main"
    ) -> PromptVersion:
        """
        Create a new version of the template.
        
        Args:
            content: New template content
            changelog: Description of changes
            author: Author identifier (optional)
            branch: Branch to create version on
            
        Returns:
            Created PromptVersion instance
            
        Raises:
            ValueError: If branch doesn't exist or is invalid
        """
        if branch not in self.SUPPORTED_BRANCHES:
            raise ValueError(
                f"Invalid branch '{branch}'. Supported branches: {self.SUPPORTED_BRANCHES}"
            )
        
        # Load existing versions
        versions_data = self._load_versions()
        
        # Compute hash and determine new version number
        content_hash = self._compute_content_hash(content)
        
        # Check if this is a duplicate (same content as latest version)
        current_branch_versions = versions_data.get(branch, [])
        if current_branch_versions:
            latest_version = current_branch_versions[-1]
            if latest_version.content_hash == content_hash:
                print(f"Warning: Content unchanged from latest version {latest_version.version}")
                return latest_version
        
        # Determine next version number
        if current_branch_versions:
            latest = current_branch_versions[-1]
            major, minor, patch = map(int, latest.version.split('.'))
            
            # Auto-increment based on changelog content
            if "breaking" in changelog.lower():
                major += 1
                minor = 0
                patch = 0
            elif "fix" in changelog.lower():
                patch += 1
            else:
                minor += 1
            
            next_version = f"{major}.{minor}.{patch}"
        else:
            next_version = "1.0.0"
        
        # Create new version
        new_version = PromptVersion(
            version=next_version,
            timestamp=datetime.now(),
            author=author,
            changelog=changelog,
            content_hash=content_hash,
            metadata={'branch': branch}
        )
        
        # Add to versions data
        if branch not in versions_data:
            versions_data[branch] = []
        versions_data[branch].append(new_version)
        
        # Save
        self._save_versions(versions_data)
        
        return new_version
    
    def get_latest_version(self, branch: str = "main") -> Optional[PromptVersion]:
        """Get the latest version on a specific branch."""
        versions_data = self._load_versions()
        branch_versions = versions_data.get(branch, [])
        
        if not branch_versions:
            return None
        
        # Return the last one (most recent)
        return branch_versions[-1]
    
    def get_version(self, version_str: str, branch: str = "main") -> Optional[PromptVersion]:
        """Get a specific version by string."""
        versions_data = self._load_versions()
        branch_versions = versions_data.get(branch, [])
        
        for version in branch_versions:
            if version.version == version_str:
                return version
        
        return None
    
    def list_versions(self, branch: str = "main") -> List[PromptVersion]:
        """List all versions on a specific branch."""
        versions_data = self._load_versions()
        return versions_data.get(branch, [])
    
    def rollback_to(self, version_str: str, branch: str = "main") -> bool:
        """
        Rollback to a specific version.
        
        Args:
            version_str: Version to rollback to
            branch: Branch to rollback on
            
        Returns:
            True if successful, False if version not found
        """
        version = self.get_version(version_str, branch)
        if not version:
            return False
        
        # Note: In a real implementation, you would reload the template content here
        print(f"Would rollback to version {version_str}")
        return True
    
    def create_branch(self, name: str, from_branch: str = "main") -> bool:
        """
        Create a new branch for experimental changes.
        
        Args:
            name: Name of the new branch
            from_branch: Branch to copy versions from
            
        Returns:
            True if successful
        """
        if name in self.SUPPORTED_BRANCHES or name in [b.lower() for b in self.SUPPORTED_BRANCHES]:
            print(f"Branch '{name}' already exists")
            return False
        
        # Add to supported branches
        self.SUPPORTED_BRANCHES.append(name)
        
        # Copy versions from source branch
        versions_data = self._load_versions()
        if from_branch in versions_data:
            versions_data[name] = versions_data[from_branch].copy()
            self._save_versions(versions_data)
        
        return True
    
    def get_version_summary(self, branch: str = "main") -> List[Dict[str, Any]]:
        """Get a summary of all versions on a branch."""
        versions = self.list_versions(branch)
        summaries = []
        
        for version in versions:
            summaries.append({
                'version': version.version,
                'timestamp': version.timestamp.isoformat(),
                'author': version.author or "Unknown",
                'changelog': version.changelog[:100] + "..." if len(version.changelog) > 100 else version.changelog,
                'hash': version.content_hash
            })
        
        return summaries
    
    def export_version(self, version_str: str, output_path: str | Path) -> bool:
        """
        Export a specific version to a file.
        
        Args:
            version_str: Version to export
            output_path: Where to save the exported content
            
        Returns:
            True if successful
        """
        version = self.get_version(version_str)
        if not version:
            return False
        
        # Note: In real implementation, you would load the actual template content here
        export_data = {
            'version': version.version,
            'timestamp': version.timestamp.isoformat(),
            'author': version.author,
            'changelog': version.changelog,
            'content_hash': version.content_hash
        }
        
        Path(output_path).write_text(
            json.dumps(export_data, indent=2),
            encoding='utf-8'
        )
        
        return True
