
# install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
git clone https://github.com/ntwilson/neovim-config.git $HOME/.config/nvim


# install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s
mkdir -p $HOME/.config/oh-my-posh
cp ./ntwilson.omp.json ~/.config/oh-my-posh/ntwilson.omp.json
mkdir $HOME/.config/powershell
dos2unix ./Microsoft.PowerShell_profile.ps1
cp ./Microsoft.PowerShell_profile.ps1 $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1

dos2unix ./.bashrc
cat ./.bashrc >> $HOME/.bashrc
echo "done"
