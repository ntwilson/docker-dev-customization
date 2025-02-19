sudo apt update

# Install docker
# https://docs.docker.com/engine/install/ubuntu/

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# install az CLI
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Write-Host "Logging into github..."
# gh auth login
# gh auth setup-git

Write-Host "Logging into the az CLI..."
az login

# https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

az acr login --name meacontainers

docker pull "meacontainers.azurecr.io/dev-env-ntw:latest"
docker tag "meacontainers.azurecr.io/dev-env-ntw:latest" dev-env-ntw

mkdir ~/DockerClipBoard

cat > run.bash <<EOF 
docker run -it \\
  --rm \\
  --mount "type=volume,src=workspace,dst=/workspace" \\
  --mount "type=volume,src=gitconfig-volume,dst=/gitconfigvolume" \\
  --mount "type=volume,src=dotnet-cache,dst=/usr/share/dotnet" \\
  --mount "type=volume,src=dotnet,dst=/root/.dotnet" \\
  --mount "type=volume,src=gh,dst=/root/.config/gh" \\
  --mount "type=volume,src=paket,dst=/root/.config/Paket" \\
  --mount "type=volume,src=nuget-config,dst=/root/.config/NuGet" \\
  --mount "type=volume,src=nuget,dst=/root/.nuget" \\
  --mount "type=volume,src=nuget-share,dst=/root/.local/share/NuGet" \\
  --mount "type=volume,src=pdm,dst=/root/.local/share/pdm" \\
  --mount "type=volume,src=powershell-history,dst=/root/.local/share/powershell/PSReadLine" \\
  --mount "type=volume,src=az,dst=/root/.azure" \\
  --mount "type=volume,src=az-pwsh,dst=/root/.Azure" \\
  --mount "type=volume,src=azcache,dst=/root/.local/share/.IdentityService" \\
  --mount "type=bind,src=\\$HOME/DockerClipBoard,dst=/clipboard" \
  -p "1080:1080" \\
  --cap-add NET_ADMIN \\
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \\
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \\
  dev-env-ntw pwsh
EOF

