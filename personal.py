#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Run personal Docker container with various mounts"
    )
    parser.add_argument("--port", "-p", type=str, help="Port to expose")
    parser.add_argument(
        "--image-name",
        "-i",
        type=str,
        default="personal",
        help="Docker image name (default: personal)",
    )
    parser.add_argument(
        "--start-cmd",
        "-c",
        type=str,
        default="xonsh",
        help="Start command (default: xonsh)",
    )

    args = parser.parse_args()

    # Build port arguments
    port_args = []
    if args.port:
        port_args.extend(["-p", f"{args.port}:{args.port}"])

    # Ensure DockerClipBoard directory exists
    docker_clipboard_dir = Path.home() / "DockerClipBoard"
    docker_clipboard_dir.mkdir(exist_ok=True)

    # Set up authentication paths
    home = Path.home()
    claude_credentials_path = home / ".claude" / ".credentials.json"
    claude_settings_path = home / ".claude" / "config.json"
    claude_json_path = home / ".claude.json"
    codex_path = home / ".codex"

    # Create directories if they don't exist
    for auth_dir in [claude_settings_path, claude_credentials_path]:
        auth_dir.parent.mkdir(parents=True, exist_ok=True)

    # Build docker command
    docker_cmd = [
        "docker",
        "run",
        "-it",
        "--rm",
        # Volume mounts
        "--mount",
        "type=volume,src=personal,dst=/workspace",
        "--mount",
        "type=volume,src=gitconfig-volume,dst=/gitconfigvolume",
        "--mount",
        "type=volume,src=gh,dst=/root/.config/gh",
        "--mount",
        "type=volume,src=gh-exts,dst=/root/.local/share/gh",
        "--mount",
        "type=volume,src=copilot,dst=/root/.config/github-copilot",
        "--mount",
        "type=volume,src=dotnet,dst=/root/.dotnet",
        "--mount",
        "type=volume,src=dotnet-cache,dst=/usr/share/dotnet",
        "--mount",
        "type=volume,src=paket,dst=/root/.config/Paket",
        "--mount",
        "type=volume,src=nuget-config,dst=/root/.config/NuGet",
        "--mount",
        "type=volume,src=nuget,dst=/root/.nuget",
        "--mount",
        "type=volume,src=nuget-share,dst=/root/.local/share/NuGet",
        "--mount",
        "type=volume,src=pdm,dst=/root/.local/share/pdm",
        "--mount",
        "type=volume,src=nvim,dst=/root/.local/share/nvim",
        "--mount",
        "type=volume,src=personal-powershell-history,dst=/root/.local/share/powershell/PSReadLine",
        "--mount",
        "type=volume,src=personal-xonsh-history,dst=/root/.local/share/xonsh/history_json/",
        "--mount",
        "type=volume,src=personal-az,dst=/root/.azure",
        "--mount",
        "type=volume,src=personal-az-pwsh,dst=/root/.Azure",
        "--mount",
        "type=volume,src=personal-azcache,dst=/root/.local/share/.IdentityService",
        "--mount",
        f"type=bind,src={claude_settings_path},dst=/root/.claude/config.json",
        "--mount",
        f"type=bind,src={claude_credentials_path},dst=/root/.claude/.credentials.json",
        "--mount",
        f"type=bind,src={claude_json_path},dst=/root/.claude.json",
        "--mount",
        f"type=bind,src={codex_path},dst=/root/.codex",
        "--mount",
        f"type=bind,src={docker_clipboard_dir},dst=/clipboard",
    ]

    # Add port arguments if specified
    docker_cmd.extend(port_args)

    # Add image name and start command
    docker_cmd.extend([args.image_name, args.start_cmd])

    try:
        # Execute docker command
        subprocess.run(docker_cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running docker command: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()


# Enable this bind mount to use docker commands like `docker build` from inside your docker container
# and have it share your host machine's docker daemon. You will need to edit it to point to the correct
# distro. When running `wsl -l`, whichever distro is the default should be placed in the path
#
# Add this to the docker_cmd list:
# "--mount", "type=bind,src=\\\\wsl$\\<distro>\\var\\run\\docker.sock,dst=/var/run/docker.sock",
