
# install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
git clone https://github.com/ntwilson/neovim-config.git ~/.config/nvim


# install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s
mkdir -p ~/.config/oh-my-posh
cp ./ntwilson.omp.json ~/.config/oh-my-posh/ntwilson.omp.json

cat ./.bashrc >> ~/.bashrc
