

# install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
git clone https://github.com/ntwilson/neovim-config.git $HOME/.config/nvim
cp ./init.vim $HOME/.config/nvim/init.vim
sudo apt install ripgrep
mkdir '$HOME/nvim/plugged'
/opt/nvim-linux64/bin/nvim --headless +PlugInstall +qall

# install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s
mkdir -p $HOME/.config/oh-my-posh
cp ./ntwilson.omp.json ~/.config/oh-my-posh/ntwilson.omp.json

# install posh-git
pwsh -c "PowerShellGet\\Install-Module posh-git -Scope CurrentUser -Force"
# install dotenv
pwsh -c "Install-Module -Name pwsh-dotenv -Confirm:$False"

mkdir $HOME/.config/powershell
cp ./Microsoft.PowerShell_profile.ps1 $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1

cat ./.bashrc >> $HOME/.bashrc


npm install -g purescript purescript-language-server
dotnet tool install --global FsAutoComplete

echo "done"

