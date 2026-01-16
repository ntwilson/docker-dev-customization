
param (
  [String] $WorkDir,
  [parameter(ValueFromRemainingArguments = $true)][string[]]$Cmd
)

if (-not (test-path ~\DockerClipBoard)) { mkdir ~\DockerClipBoard }

# Detect OS and set authentication paths
$IsWindowsOS = $IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)

if ($IsWindowsOS) {
  # Windows paths
  $azurePath = "$env:USERPROFILE\.azure"
  $azCachePath = "$env:LOCALAPPDATA\.IdentityService"
  $claudeSettingsPath = "$env:USERPROFILE\.claude"
  $claudeJsonPath = "$env:USERPROFILE\.claude.json"
} else {
  # Linux/macOS paths
  $azurePath = "$home/.azure"
  $azCachePath = "$home/.local/share/.IdentityService"
  $claudeSettingsPath = "$home/.claude"
  $claudeJsonPath = "$home/.claude.json"
}

# Create directories if they don't exist
$authDirs = @($azurePath, $azCachePath, $claudeSettingsPath)
foreach ($dir in $authDirs) {
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
}

docker run `
  --rm `
  --mount "type=volume,src=workspace,dst=/workspace" `
  --mount "type=volume,src=secrets,dst=/secrets" `
  --mount "type=volume,src=gitconfig-volume,dst=/gitconfigvolume" `
  --mount "type=volume,src=dotnet-cache,dst=/usr/share/dotnet" `
  --mount "type=volume,src=dotnet,dst=/root/.dotnet" `
  --mount "type=volume,src=gh,dst=/root/.config/gh" `
  --mount "type=volume,src=gh-exts,dst=/root/.local/share/gh" `
  --mount "type=volume,src=copilot,dst=/root/.config/github-copilot" `
  --mount "type=volume,src=paket,dst=/root/.config/Paket" `
  --mount "type=volume,src=nuget-config,dst=/root/.config/NuGet" `
  --mount "type=volume,src=nuget,dst=/root/.nuget" `
  --mount "type=volume,src=nuget-share,dst=/root/.local/share/NuGet" `
  --mount "type=volume,src=pdm,dst=/root/.local/share/pdm" `
  --mount "type=volume,src=nvim,dst=/root/.local/share/nvim" `
  --mount "type=volume,src=powershell-history,dst=/root/.local/share/powershell/PSReadLine" `
  --mount "type=volume,src=az-pwsh,dst=/root/.Azure" `
  --mount "type=bind,src=$azurePath,dst=/root/.azure" `
  --mount "type=bind,src=$azCachePath,dst=/root/.local/share/.IdentityService" `
  --mount "type=bind,src=$claudeSettingsPath,dst=/root/.claude" `
  --mount "type=bind,src=$claudeJsonPath,dst=/root/.claude.json" `
  --mount "type=bind,src=$((get-item ~).FullName)\DockerClipBoard,dst=/clipboard" `
  -w $WorkDir `
  ntw @Cmd

  
# Enable this bind mount to use docker commands like `docker build` from inside your docker container
# and have it share your host machine's docker daemon. You will need to edit it to point to the correct 
# distro. When running `wsl -l`, whichever distro is the default should be placed in the path
#
#  --mount "type=bind,src=\\wsl$\<distro>\var\run\docker.sock,dst=/var/run/docker.sock" `
  
