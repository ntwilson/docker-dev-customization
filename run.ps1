
param (
  [String] $Port,
  [String] $ImageName="ntw", 
  [String] $StartCmd="pwsh"
) 

$portArgs = @()
if ($Port) {
  $portArgs += "-p", "$($Port):$($Port)"
}

if (-not (test-path ~\DockerClipBoard)) { mkdir ~\DockerClipBoard }
# if (-not (test-path ~\DockerVolumes)) { mkdir ~\DockerVolumes }

# function Create-Volume {
#   param($name, $dst)
# 
#   if (-not (test-path ~\DockerVolumes\$name)) {
#     docker run --rm `
#       --mount "type=bind,src=$home\DockerVolumes\$name,dst=/temp-volume" `
#       $ImageName sh -c "cp -r $dst/* /temp-volume"
#   }
# }

docker run -it `
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
  --mount "type=volume,src=az,dst=/root/.azure" `
  --mount "type=volume,src=az-pwsh,dst=/root/.Azure" `
  --mount "type=volume,src=azcache,dst=/root/.local/share/.IdentityService" `
  --mount "type=bind,src=$((get-item ~).FullName)\DockerClipBoard,dst=/clipboard" `
  --mount "type=bind,src=\\wsl$\Ubuntu\var\run\docker.sock,dst=/var/run/docker.sock" `
  @portArgs `
  $imageName $startCmd

  
# Enable this bind mount to use docker commands like `docker build` from inside your docker container
# and have it share your host machine's docker daemon. You will need to edit it to point to the correct 
# distro. When running `wsl -l`, whichever distro is the default should be placed in the path
#
#  --mount "type=bind,src=\\wsl$\<distro>\var\run\docker.sock,dst=/var/run/docker.sock" `
  
