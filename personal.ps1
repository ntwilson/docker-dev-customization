
param (
  [String] $Port,
  [String] $ImageName="personal", 
  [String] $StartCmd="xonsh"
) 

$portArgs = @()
if ($Port) {
  $portArgs += "-p", "$($Port):$($Port)"
}

$WatchPath = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_.FullName }
if (-not (test-path ~\DockerClipBoard)) { mkdir ~\DockerClipBoard }

# Detect OS and set authentication paths
$IsWindowsOS = $IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)

if ($IsWindowsOS) {
  # Windows paths
  $claudeCredentialsPath = "$env:USERPROFILE\.claude\.credentials.json"
  $claudeSettingsPath = "$env:USERPROFILE\.claude\config.json"
  $claudeJsonPath = "$env:USERPROFILE\.claude.json"
  $codexPath = "$env:USERPROFILE\.codex"
} else {
  # Linux/macOS paths
  $claudeCredentialsPath = "$home/.claude/.credentials.json"
  $claudeSettingsPath = "$home/.claude/config.json"
  $claudeJsonPath = "$home/.claude.json"
  $codexPath = "$home/.codex"
}


# Start file watcher in a background job so it doesn't interfere with the interactive Docker session
$watcherJob = Start-Job -ScriptBlock {
  param($watchPath)
  
  $watcher = New-Object System.IO.FileSystemWatcher
  $watcher.Path = $watchPath
  $watcher.Filter = "vscode-request-*"
  $watcher.EnableRaisingEvents = $true

  $action = {
    $path = $Event.SourceEventArgs.FullPath
      
    Start-Sleep -Milliseconds 100  # Brief delay to ensure file is written
      
    try {
      $lines = Get-Content $path
      if ($lines.Count -ge 2) {
        $containerId = $lines[0].Trim()
        $workDir = $lines[1].Trim()
              
        Write-Host "`nOpening VS Code for container: $containerId at $workDir"
              
        # Convert container ID to hex
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($containerId)
        $containerHex = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ''
              
        # Launch VS Code
        code --folder-uri "vscode-remote://attached-container+${containerHex}${workDir}"
              
        # Delete the request file
        Start-Sleep -Milliseconds 500
        Remove-Item $path -Force
      }
    } catch {
      Write-Host "Error processing request: $_"
    }
  }

  Register-ObjectEvent $watcher "Created" -Action $action
  
  # Keep the job alive and responsive
  try {
    while ($true) {
      Start-Sleep -Seconds 1
    }
  } finally {
    $watcher.Dispose()
  }
} -ArgumentList $WatchPath.FullName

# Setup cleanup on exit
$cleanup = {
  Write-Host "`nCleaning up file watcher..."
  if ($watcherJob -and $watcherJob.State -eq "Running") {
    Stop-Job $watcherJob
    Remove-Job $watcherJob -Force
  }
}

# Register cleanup for Ctrl+C
Register-EngineEvent PowerShell.Exiting -Action $cleanup

try {
  docker run -it `
    --rm `
    --mount "type=volume,src=personal,dst=/workspace" `
    --mount "type=volume,src=gitconfig-volume,dst=/gitconfigvolume" `
    --mount "type=volume,src=gh,dst=/root/.config/gh" `
    --mount "type=volume,src=gh-exts,dst=/root/.local/share/gh" `
    --mount "type=volume,src=copilot,dst=/root/.config/github-copilot" `
    --mount "type=volume,src=dotnet,dst=/root/.dotnet" `
    --mount "type=volume,src=dotnet-cache,dst=/usr/share/dotnet" `
    --mount "type=volume,src=paket,dst=/root/.config/Paket" `
    --mount "type=volume,src=nuget-config,dst=/root/.config/NuGet" `
    --mount "type=volume,src=nuget,dst=/root/.nuget" `
    --mount "type=volume,src=nuget-share,dst=/root/.local/share/NuGet" `
    --mount "type=volume,src=pdm,dst=/root/.local/share/pdm" `
    --mount "type=volume,src=nvim,dst=/root/.local/share/nvim" `
    --mount "type=volume,src=personal-powershell-history,dst=/root/.local/share/powershell/PSReadLine" `
    --mount "type=volume,src=personal-xonsh-history,dst=/root/.local/share/xonsh/history_json/" `
    --mount "type=volume,src=personal-az,dst=/root/.azure" `
    --mount "type=volume,src=personal-az-pwsh,dst=/root/.Azure" `
    --mount "type=volume,src=personal-azcache,dst=/root/.local/share/.IdentityService" `
    --mount "type=bind,src=$claudeSettingsPath,dst=/root/.claude/config.json" `
    --mount "type=bind,src=$claudeCredentialsPath,dst=/root/.claude/.credentials.json" `
    --mount "type=bind,src=$claudeJsonPath,dst=/root/.claude.json" `
    --mount "type=bind,src=$codexPath,dst=/root/.codex" `
    --mount "type=bind,src=$((get-item ~).FullName)\DockerClipBoard,dst=/clipboard" `
    --mount "type=bind,src=$($WatchPath.FullName),dst=/vscode-requests" `
    @portArgs `
    $imageName $startCmd

    
  # Enable this bind mount to use docker commands like `docker build` from inside your docker container
  # and have it share your host machine's docker daemon. You will need to edit it to point to the correct 
  # distro. When running `wsl -l`, whichever distro is the default should be placed in the path
  #
  #  --mount "type=bind,src=\\wsl$\<distro>\var\run\docker.sock,dst=/var/run/docker.sock" `
  
} finally {
  # Cleanup when Docker exits
  & $cleanup
}
