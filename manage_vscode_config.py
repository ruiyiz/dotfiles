#!/usr/bin/env python3
"""
VS Code Configuration Manager
Handles deployment and removal of VS Code configuration files across platforms and derivatives.
"""

import argparse
import json
import os
import platform
import re
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Optional


class VSCodeConfigManager:
    """Manages VS Code configuration deployment across platforms and derivatives."""
    
    # VS Code configuration paths for different platforms and variants
    VSCODE_PATHS = {
        'Darwin': {
            'Code': '~/Library/Application Support/Code/User/',
            'Code Server': '~/Library/Application Support/Code Server/User/',
            'Positron': '~/Library/Application Support/Positron/User/'
        },
        'Linux': {
            'Code': '~/.config/Code/User/',
            'Code Server': '~/data/User/',
            'Positron': '~/.config/Positron/User/'
        },
        'Windows': {
            'Code': '%APPDATA%/Code/User/',
            'Code Server': '%APPDATA%/code-server/User/',
            'Positron': '%APPDATA%/Positron/User/'
        }
    }
    
    def __init__(self, dotfiles_dir: Optional[Path] = None):
        """Initialize the VS Code config manager."""
        self.dotfiles_dir = dotfiles_dir or Path.cwd()
        self.vscode_dir = self.dotfiles_dir / 'vscode'
        self.os_name = platform.system()
        
    def get_vscode_config_paths(self) -> Dict[str, Path]:
        """Get VS Code configuration paths for the current OS."""
        if self.os_name not in self.VSCODE_PATHS:
            raise ValueError(f"Unsupported operating system: {self.os_name}")
        
        paths = {}
        for variant, path_template in self.VSCODE_PATHS[self.os_name].items():
            # Expand environment variables and user home
            if self.os_name == 'Windows':
                path_str = os.path.expandvars(path_template)
            else:
                path_str = os.path.expanduser(path_template)
            
            path = Path(path_str)
            if path.exists():
                paths[variant] = path

        return paths
    
    def find_derivative_files(self) -> Dict[str, List[str]]:
        """Find derivative-specific configuration files."""
        if not self.vscode_dir.exists():
            return {}
        
        derivatives = {'settings': [], 'keybindings': []}
        
        for file_path in self.vscode_dir.glob('*.json'):
            filename = file_path.name
            
            # Match settings.<derivative>.json pattern
            settings_match = re.match(r'settings\.(.+)\.json$', filename)
            if settings_match:
                derivatives['settings'].append(settings_match.group(1))
                continue
                
            # Match keybindings.<derivative>.json pattern
            keybindings_match = re.match(r'keybindings\.(.+)\.json$', filename)
            if keybindings_match:
                derivatives['keybindings'].append(keybindings_match.group(1))
                
        return derivatives
    
    def clean_vscode_json(self, content: str) -> str:
        """Clean VS Code's non-standard JSON (remove comments, trailing commas)."""
        # Remove single-line comments
        content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
        
        # Remove multi-line comments
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        
        # Remove trailing commas before } or ]
        content = re.sub(r',(\s*[}\]])', r'\1', content)
        
        return content.strip()
    
    def merge_settings(self, base_file: Path, derivative_files: List[Path]) -> str:
        """Merge base and derivative settings files."""
        try:
            # Read and parse base settings
            base_content = self.clean_vscode_json(base_file.read_text())
            base_settings = json.loads(base_content)
            
            # Merge derivative settings
            for derivative_file in derivative_files:
                if derivative_file.exists():
                    derivative_content = self.clean_vscode_json(derivative_file.read_text())
                    derivative_settings = json.loads(derivative_content)
                    base_settings.update(derivative_settings)
            
            return json.dumps(base_settings, indent=2)
            
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Warning: JSON parsing failed, falling back to text-based merge: {e}")
            return self._merge_settings_text_based(base_file, derivative_files)
    
    def _merge_settings_text_based(self, base_file: Path, derivative_files: List[Path]) -> str:
        """Fallback text-based settings merging."""
        try:
            # Read base file and remove outer braces
            base_content = base_file.read_text().strip()
            if base_content.startswith('{'):
                base_content = base_content[1:]
            if base_content.endswith('}'):
                base_content = base_content[:-1]
            
            merged_content = base_content.rstrip().rstrip(',')
            
            # Add derivative settings
            for derivative_file in derivative_files:
                if derivative_file.exists():
                    derivative_content = derivative_file.read_text().strip()
                    if derivative_content.startswith('{'):
                        derivative_content = derivative_content[1:]
                    if derivative_content.endswith('}'):
                        derivative_content = derivative_content[:-1]
                    
                    derivative_content = derivative_content.strip()
                    if derivative_content:
                        merged_content += ',\n' + derivative_content.rstrip().rstrip(',')
            
            return '{\n' + merged_content + '\n}'
            
        except IOError as e:
            print(f"Error in text-based merge: {e}")
            return base_file.read_text() if base_file.exists() else '{}'
    
    def merge_keybindings(self, base_file: Path, derivative_files: List[Path]) -> str:
        """Merge base and derivative keybindings files."""
        try:
            # Read and parse base keybindings (should be an array)
            base_content = self.clean_vscode_json(base_file.read_text())
            base_keybindings = json.loads(base_content)
            
            if not isinstance(base_keybindings, list):
                print(f"Warning: Base keybindings is not an array, converting")
                base_keybindings = []
            
            # Merge derivative keybindings
            for derivative_file in derivative_files:
                if derivative_file.exists():
                    derivative_content = self.clean_vscode_json(derivative_file.read_text())
                    derivative_data = json.loads(derivative_content)
                    
                    # Handle both array and object formats
                    if isinstance(derivative_data, list):
                        base_keybindings.extend(derivative_data)
                    elif isinstance(derivative_data, dict):
                        # Convert object format to array (assume it contains keybinding objects)
                        for value in derivative_data.values():
                            if isinstance(value, dict):
                                base_keybindings.append(value)
                            elif isinstance(value, list):
                                base_keybindings.extend(value)
            
            return json.dumps(base_keybindings, indent=2)
            
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Warning: JSON parsing failed for keybindings, falling back to text merge: {e}")
            return self._merge_keybindings_text_based(base_file, derivative_files)
    
    def _merge_keybindings_text_based(self, base_file: Path, derivative_files: List[Path]) -> str:
        """Fallback text-based keybindings merging."""
        try:
            # Read base file
            base_content = base_file.read_text().strip() if base_file.exists() else '[]'
            
            # Remove outer brackets if present
            if base_content.startswith('['):
                base_content = base_content[1:]
            if base_content.endswith(']'):
                base_content = base_content[:-1]
            
            merged_items = [base_content.strip().rstrip(',')]
            
            # Add derivative keybindings
            for derivative_file in derivative_files:
                if derivative_file.exists():
                    derivative_content = derivative_file.read_text().strip()
                    
                    # Handle object format - extract the values
                    if derivative_content.startswith('{') and derivative_content.endswith('}'):
                        # Extract keybinding objects from the wrapper object
                        inner_content = derivative_content[1:-1].strip()
                        # This is a simplified extraction - in practice, you might need more robust parsing
                        if inner_content:
                            merged_items.append(inner_content.rstrip(','))
                    else:
                        # Handle array format
                        if derivative_content.startswith('['):
                            derivative_content = derivative_content[1:]
                        if derivative_content.endswith(']'):
                            derivative_content = derivative_content[:-1]
                        
                        if derivative_content.strip():
                            merged_items.append(derivative_content.strip().rstrip(','))
            
            # Join all items
            merged_content = ',\n'.join(item for item in merged_items if item.strip())
            return '[\n' + merged_content + '\n]'
            
        except IOError as e:
            print(f"Error in text-based keybindings merge: {e}")
            return base_file.read_text() if base_file.exists() else '[]'
    
    def create_merged_config(self, config_type: str, derivative: Optional[str] = None) -> Optional[Path]:
        """Create a merged configuration file for the specified type and derivative."""
        base_file = self.vscode_dir / f'{config_type}.json'
        
        if not base_file.exists():
            print(f"Warning: Base {config_type}.json not found")
            return None
        
        derivative_files = []
        if derivative:
            derivative_file = self.vscode_dir / f'{config_type}.{derivative}.json'
            if derivative_file.exists():
                derivative_files.append(derivative_file)
        
        # Create merged content
        if config_type == 'settings':
            merged_content = self.merge_settings(base_file, derivative_files)
        elif config_type == 'keybindings':
            merged_content = self.merge_keybindings(base_file, derivative_files)
        else:
            print(f"Unknown config type: {config_type}")
            return None
        
        # Write to temporary file
        temp_file = Path(tempfile.mktemp(suffix=f'.{config_type}.json'))
        temp_file.write_text(merged_content, encoding='utf-8')
        return temp_file
    
    def deploy_vscode_configs(self):
        """Deploy VS Code configurations to all detected installations."""
        vscode_paths = self.get_vscode_config_paths()
        
        if not vscode_paths:
            print("No VS Code installations found")
            return
        
        derivatives = self.find_derivative_files()
        print(f"Found derivatives: {derivatives}")
        
        # Get all unique derivatives
        all_derivatives = set(derivatives.get('settings', []) + derivatives.get('keybindings', []))
        
        for variant, config_path in vscode_paths.items():
            print(f"\nDeploying to {variant} at {config_path}")
            
            # Determine which derivative to use based on the variant
            variant_derivative = None
            variant_lower = variant.lower().replace(' ', '').replace('-', '')
            
            # Direct mapping for known VS Code variants to derivatives
            derivative_mapping = {
                'code': None,  # Standard VS Code uses base configs
                'codeserver': None,  # Code Server uses base configs
                'positron': 'positron',  # Positron would use positron derivative
            }
            
            # Check if we have a direct mapping
            if variant_lower in derivative_mapping:
                mapped_derivative = derivative_mapping[variant_lower]
                if mapped_derivative and mapped_derivative in all_derivatives:
                    variant_derivative = mapped_derivative
            else:
                # Fallback: try to match variant name with derivative name
                for derivative in all_derivatives:
                    if derivative.lower().replace(' ', '').replace('-', '') == variant_lower:
                        variant_derivative = derivative
                        break
            
            # Deploy settings
            temp_settings = self.create_merged_config('settings', variant_derivative)
            if temp_settings:
                target_settings = config_path / 'settings.json'
                try:
                    config_path.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(temp_settings, target_settings)
                    print(f"  ✓ Deployed settings.json")
                    temp_settings.unlink()  # Clean up temp file
                except IOError as e:
                    print(f"  ✗ Failed to deploy settings: {e}")

            # Deploy keybindings
            temp_keybindings = self.create_merged_config('keybindings', variant_derivative)
            if temp_keybindings:
                target_keybindings = config_path / 'keybindings.json'
                try:
                    shutil.copy2(temp_keybindings, target_keybindings)
                    print("  ✓ Deployed keybindings.json")
                    temp_keybindings.unlink()  # Clean up temp file
                except IOError as e:
                    print(f"  ✗ Failed to deploy keybindings: {e}")
    
    def remove_vscode_configs(self):
        """Remove VS Code configurations from all detected installations."""
        vscode_paths = self.get_vscode_config_paths()
        
        if not vscode_paths:
            print("No VS Code installations found")
            return
        
        for variant, config_path in vscode_paths.items():
            print(f"\nRemoving configs from {variant} at {config_path}")
            
            # Remove settings.json
            settings_file = config_path / 'settings.json'
            if settings_file.exists():
                try:
                    settings_file.unlink()
                    print("  ✓ Removed settings.json")
                except IOError as e:
                    print(f"  ✗ Failed to remove settings: {e}")

            # Remove keybindings.json
            keybindings_file = config_path / 'keybindings.json'
            if keybindings_file.exists():
                try:
                    keybindings_file.unlink()
                    print("  ✓ Removed keybindings.json")
                except IOError as e:
                    print(f"  ✗ Failed to remove keybindings: {e}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Manage VS Code configuration files')
    parser.add_argument('action', choices=['deploy', 'remove'],
                       help='Action to perform: deploy or remove VS Code configs')
    parser.add_argument('--dotfiles-dir', type=Path, default=Path.cwd(),
                       help='Path to dotfiles directory (default: current directory)')
    
    args = parser.parse_args()
    
    try:
        manager = VSCodeConfigManager(args.dotfiles_dir)
        
        if args.action == 'deploy':
            print("Deploying VS Code configurations...")
            manager.deploy_vscode_configs()
            print("\nDeployment completed!")

        elif args.action == 'remove':
            print("Removing VS Code configurations...")
            manager.remove_vscode_configs()
            print("\nRemoval completed!")

    except Exception as e:
        print(f"Error: {e}")
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())