#!/usr/bin/env python3
"""Generate pixi-global.toml configuration file."""

import msgspec
import tyro
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional, Set


# Define the msgspec structures for TOML serialization
class ShellEnv(msgspec.Struct):
    channels: List[str]
    dependencies: Dict[str, str]
    exposed: Dict[str, str]


class PixiGlobalConfig(msgspec.Struct):
    version: int
    envs: Dict[str, ShellEnv]


# Define environment configuration dataclass
@dataclass
class EnvConfig:
    """Configuration for a single pixi environment."""

    name: str
    packages: List[str] = field(default_factory=list)
    custom_versions: Dict[str, str] = field(default_factory=dict)
    channels: List[str] = field(
        default_factory=lambda: [
            "https://prefix.dev/meta-forge",
            "conda-forge",
        ]
    )
    exclude_from_exposed: List[str] = field(default_factory=list)
    additional_commands: List[str] = field(default_factory=list)
    custom_exposed_mappings: Dict[str, str] = field(default_factory=dict)
    skip_auto_expose: List[str] = field(default_factory=list)

    def build_dependencies(self) -> Dict[str, str]:
        """Build dependencies dict with defaults and custom versions."""
        deps = {pkg: self.custom_versions.get(pkg, "*") for pkg in self.packages}
        deps.update(self.custom_versions)
        return deps

    def build_exposed(self) -> Dict[str, str]:
        """Build exposed commands dict."""
        exposed = {}
        dependencies = self.build_dependencies()

        # Auto-expose packages (package name = command name)
        for pkg in dependencies.keys():
            if (
                pkg not in self.exclude_from_exposed
                and pkg not in self.skip_auto_expose
            ):
                exposed[pkg] = pkg

        # Add simple additional commands
        for cmd in self.additional_commands:
            exposed[cmd] = cmd

        # Add custom mappings
        exposed.update(self.custom_exposed_mappings)

        return exposed

    def to_shell_env(self) -> ShellEnv:
        """Convert to ShellEnv for msgspec serialization."""
        return ShellEnv(
            channels=self.channels,
            dependencies=self.build_dependencies(),
            exposed=self.build_exposed(),
        )


class Environment(Enum):
    """Available environment configurations."""

    SHELL = "shell"
    DEVOPS = "devops"
    ALL = "all"  # Generate all environments


def get_shell_config() -> EnvConfig:
    """Get shell environment configuration."""
    return EnvConfig(
        name="shell",
        packages=[
            "ast-grep",
            "atuin",
            "bat",
            "bob",
            "btop",
            "cue",
            "direnv",
            "duf",
            "eza",
            "fastfetch",
            "fzf",
            "gh",
            "git-delta",
            "go-jsonnet",
            "go-yq",
            "jq",
            "just",
            "kubectl-krew",
            "kubernetes",
            "lazygit",
            "micromamba",
            "minio-client",
            "mutagen-io",
            "ncdu",
            "p7zip",
            "pipreqs",
            "pnpm",
            "pv",
            "pyinfra",
            "ripgrep",
            "tmux",
            "uv",
            "yazi",
            "zoxide",
        ],
        custom_versions={
            "nodejs": "<24",
            "python": "3.10.*",
        },
        additional_commands=[
            # p7zip commands
            "7z",
            "7za",
            "7zr",
            # git-delta
            "delta",
            # nodejs commands
            "node",
            "npm",
            "npx",
            "corepack",
            # pnpm commands
            "pnpx",
            # go-jsonnet commands
            "jsonnet",
            "jsonnet-deps",
            "jsonnet-lint",
            "jsonnetfmt",
            # kubernetes
            "kubectl",
            # minio-client
            "mc",
            # mutagen-io
            "mutagen",
            # ripgrep
            "rg",
            "sg",
            # go-yq
            "yq",
            # uv
            "uvx",
            # yazi
            "ya",
            # fastfetch
            "flashfetch",
        ],
        skip_auto_expose=[
            "git-delta",  # exposed as "delta"
            "go-jsonnet",  # exposes multiple commands
            "go-yq",  # exposed as "yq"
            "kubectl-krew",  # doesn't expose a direct command
            "kubernetes",  # exposed as "kubectl"
            "minio-client",  # exposed as "mc"
            "mutagen-io",  # exposed as "mutagen"
            "nodejs",  # exposes multiple commands
            "p7zip",  # exposes multiple commands
            "ripgrep",  # exposes "rg" and "sg"
            "python",  # doesn't need to be exposed
        ],
    )


def get_devops_config() -> EnvConfig:
    """Get DevOps environment configuration."""
    return EnvConfig(
        name="devops",
        packages=[
            "cookiecutter",
            "k9s",
            "podman-docker",
            "podman-rootful",
            "pre-commit",
        ],
        additional_commands=[
            # podman
            "docker",
            "podman",
        ],
        skip_auto_expose=[
            "podman-docker",  # exposed as "docker"
            "podman-rootful",  # exposed as "podman"
        ],
    )


def get_environment_config(env: Environment) -> List[EnvConfig]:
    """Get environment configuration(s) based on selection.

    Args:
        env: Environment to generate configuration for

    Returns:
        List of EnvConfig objects for the selected environment(s)
    """
    configs = {
        Environment.SHELL: get_shell_config(),
        Environment.DEVOPS: get_devops_config(),
    }

    if env == Environment.ALL:
        return list(configs.values())
    elif env in configs:
        return [configs[env]]
    else:
        raise ValueError(f"Unknown environment: {env}")


# Example of additional environment (uncomment and modify as needed)
# def get_dev_config() -> EnvConfig:
#     """Get development environment configuration."""
#     return EnvConfig(
#         name="dev",
#     packages=[
#         "rust",
#         "cargo-edit",
#         "cargo-watch",
#     ],
#     custom_versions={
#         "rust": "1.75.*",
#     },
#     additional_commands=[
#         "cargo",
#         "rustc",
#         "rustup",
#     ],
#     )


def generate_pixi_global(
    environments: Environment = Environment.ALL,
    manifest_path: Optional[Path] = None,
    dry_run: bool = False,
) -> bytes:
    """Generate pixi-global.toml file.

    Args:
        environments: Which environment(s) to generate
        manifest_path: Manifest file path (defaults to ~/.pixi/manifests/pixi-global.toml)
        dry_run: If True, don't write file, just print content

    Returns:
        Generated TOML content as bytes
    """
    # Determine manifest path
    if manifest_path is None:
        manifest_path = Path.home() / ".pixi" / "manifests" / "pixi-global.toml"

    # Read existing manifest if it exists
    existing_envs = {}
    if manifest_path.exists():
        try:
            existing_content = manifest_path.read_bytes()
            existing_config = msgspec.toml.decode(existing_content, type=PixiGlobalConfig)
            existing_envs = existing_config.envs
            print(f"Merging with existing manifest: {manifest_path}")
        except Exception as e:
            print(f"Warning: Could not read existing manifest: {e}")

    # Get selected environment configurations
    env_configs = get_environment_config(environments)

    # Build envs dict from selected environment configurations
    # Merge with existing environments (new environments overwrite existing ones)
    envs = dict(existing_envs)  # Start with existing envs
    for env_config in env_configs:
        envs[env_config.name] = env_config.to_shell_env()

    # Create the configuration
    config = PixiGlobalConfig(version=1, envs=envs)

    # Convert to TOML using msgspec
    toml_content = msgspec.toml.encode(config)

    if not dry_run:
        # Ensure parent directory exists
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        # Write to file
        manifest_path.write_bytes(toml_content)
        print(f"Generated {manifest_path}")
    else:
        print("Dry run mode - file not written")

    print(f"Updated/Added environments: {', '.join(env_config.name for env_config in env_configs)}")
    if existing_envs:
        print(f"Total environments in manifest: {len(envs)}")

    return toml_content


def list_environments() -> None:
    """List all available environments and their packages."""
    for env in Environment:
        if env == Environment.ALL:
            continue
        print(f"\n{env.value}:")
        config = get_environment_config(env)[0]
        print(f"  Packages: {', '.join(sorted(config.packages))}")
        if config.custom_versions:
            print(f"  Custom versions: {config.custom_versions}")


def main(
    environments: Environment = Environment.ALL,
    manifest: Optional[Path] = None,
    dry_run: bool = False,
    list_envs: bool = False,
    show: bool = False,
) -> None:
    """Generate pixi-global.toml configuration file.

    Args:
        environments: Which environment(s) to generate (default: all)
        manifest: Manifest file path (defaults to ~/.pixi/manifests/pixi-global.toml)
        dry_run: Don't write file, just show what would be generated
        list_envs: List available environments and exit
        show: Show generated content
    """
    if list_envs:
        list_environments()
        return

    content = generate_pixi_global(
        environments=environments,
        manifest_path=manifest,
        dry_run=dry_run,
    )

    if show or dry_run:
        print("\nGenerated content:")
        print(content.decode())


if __name__ == "__main__":
    tyro.cli(main)
