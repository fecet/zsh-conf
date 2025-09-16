#!/usr/bin/env python3
"""Generate pixi-global.toml configuration file."""

import msgspec
import tyro
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Dict, List


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

    shell = EnvConfig(
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
    devops = EnvConfig(
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
    all = "all"  # Generate all environments


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
    environment: Environment,
    manifest_path: Path = Path.home() / ".pixi" / "manifests" / "pixi-global.toml",
) -> None:
    """Generate pixi-global.toml file.

    Args:
        environment: Which environment to generate
        manifest_path: Manifest file path
    """

    # Read existing manifest if it exists
    existing_envs = {}
    if manifest_path.exists():
        try:
            existing_content = manifest_path.read_bytes()
            existing_config = msgspec.toml.decode(
                existing_content, type=PixiGlobalConfig
            )
            existing_envs = existing_config.envs
            print(f"Merging with existing manifest: {manifest_path}")
        except Exception as e:
            print(f"Warning: Could not read existing manifest: {e}")

    # Get selected environment configurations
    if environment == Environment.all:
        # Get all non-ALL environments
        env_configs = [
            e.value
            for e in Environment
            if e != Environment.all and isinstance(e.value, EnvConfig)
        ]
    elif isinstance(environment.value, EnvConfig):
        env_configs = [environment.value]
    else:
        raise ValueError(f"Invalid environment: {environment}")

    # Build envs dict from selected environment configurations
    # Merge with existing environments (new environments overwrite existing ones)
    envs = dict(existing_envs)  # Start with existing envs
    for env_config in env_configs:
        envs[env_config.name] = env_config.to_shell_env()

    # Create the configuration
    config = PixiGlobalConfig(version=1, envs=envs)

    # Convert to TOML using msgspec
    toml_content = msgspec.toml.encode(config)

    # Ensure parent directory exists
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    # Write to file
    manifest_path.write_bytes(toml_content)
    print(f"Generated {manifest_path}")
    print(
        f"Updated/Added environments: {', '.join(env_config.name for env_config in env_configs)}"
    )
    if existing_envs:
        print(f"Total environments in manifest: {len(envs)}")


def main(
    environment: Environment,
    /,  # Mark environment as positional
    manifest: Path = Path.home() / ".pixi" / "manifests" / "pixi-global.toml",
) -> None:
    """Generate pixi-global.toml configuration file.

    Args:
        environment: Which environment to generate (shell, devops, or all)
        manifest: Manifest file path
    """
    generate_pixi_global(
        environment=environment,
        manifest_path=manifest,
    )


if __name__ == "__main__":
    tyro.cli(main)
