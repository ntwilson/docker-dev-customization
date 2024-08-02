
param (
  [String] $ImageName="ntw", 
  [String] $StartCmd="pwsh"
) 

if (-not (test-path ~\DockerClipBoard)) { md ~\DockerClipBoard }
if (-not (test-path ~\DockerVolumes)) { md ~\DockerVolumes }

function Create-Volume {
  param($name, $dst)

  if (-not (test-path ~\DockerVolumes\$name)) {
    docker run --rm `
      --mount "type=bind,src=$home\DockerVolumes\$name,dst=/temp-volume" `
      $ImageName sh -c "cp -r $dst/* /temp-volume"
  }
}

Create-Volume "gitconfig-volume" "/gitconfigvolume"
Create-Volume "dotnet-cache" "/usr/share/dotnet" 
Create-Volume "dotnet" "/root/.dotnet" 
Create-Volume "gh" "/root/.config/gh" 
Create-Volume "paket" "/root/.config/Paket" 
Create-Volume "nuget-config" "/root/.config/NuGet" 
Create-Volume "nuget" "/root/.nuget" 
Create-Volume "nuget-share" "/root/.local/share/NuGet" 
Create-Volume "pdm" "/root/.local/share/pdm" 
Create-Volume "nvim" "/root/.local/share/nvim"
Create-Volume "powershell-history" "/root/.local/share/powershell/PSReadLine" 
Create-Volume "az" "/root/.azure" 

docker run -it `
  --rm `
  --mount "type=bind,src=$home\DockerVolumes\workspace,dst=/workspace" `
  --mount "type=bind,src=$home\DockerVolumes\gitconfig-volume,dst=/gitconfigvolume" `
  --mount "type=bind,src=$home\DockerVolumes\dotnet-cache,dst=/usr/share/dotnet" `
  --mount "type=bind,src=$home\DockerVolumes\dotnet,dst=/root/.dotnet" `
  --mount "type=bind,src=$home\DockerVolumes\gh,dst=/root/.config/gh" `
  --mount "type=bind,src=$home\DockerVolumes\paket,dst=/root/.config/Paket" `
  --mount "type=bind,src=$home\DockerVolumes\nuget-config,dst=/root/.config/NuGet" `
  --mount "type=bind,src=$home\DockerVolumes\nuget,dst=/root/.nuget" `
  --mount "type=bind,src=$home\DockerVolumes\nuget-share,dst=/root/.local/share/NuGet" `
  --mount "type=bind,src=$home\DockerVolumes\pdm,dst=/root/.local/share/pdm" `
  --mount "type=bind,src=$home\DockerVolumes\nvim,dst=/root/.local/share/nvim" `
  --mount "type=bind,src=$home\DockerVolumes\powershell-history,dst=/root/.local/share/powershell/PSReadLine" `
  --mount "type=bind,src=$home\DockerVolumes\az,dst=/root/.azure" `
  --mount "type=bind,src=$home\DockerClipBoard,dst=/clipboard" `
  --network host `
  $imageName $startCmd

  
# Enable this bind mount to use docker commands like `docker build` from inside your docker container
# and have it share your host machine's docker daemon. You will need to edit it to point to the correct 
# distro. When running `wsl -l`, whichever distro is the default should be placed in the path
#
#  --mount "type=bind,src=\\wsl$\<distro>\var\run\docker.sock,dst=/var/run/docker.sock" `
  
