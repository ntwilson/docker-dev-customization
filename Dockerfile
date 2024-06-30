FROM mea

RUN npm install -g purescript purescript-language-server && \
    dotnet tool install --global FsAutoComplete

# install neovim
ENV PATH "$PATH:/opt/nvim-linux64/bin"
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    rm -rf /opt/nvim && \
    tar -C /opt -xzf nvim-linux64.tar.gz && \
    git clone https://github.com/ntwilson/neovim-config.git $HOME/.config/nvim && \
    apt install ripgrep && \
    /opt/nvim-linux64/bin/nvim --headless +PlugInstall +qall



# install oh-my-posh
RUN curl -s https://ohmyposh.dev/install.sh | bash -s && \
    mkdir -p $HOME/.config/oh-my-posh

COPY ./ntwilson.omp.json /root/.config/oh-my-posh/ntwilson.omp.json

# install posh-git & dotenv
RUN pwsh -c "PowerShellGet\\Install-Module posh-git -Scope CurrentUser -Force" && \
    pwsh -c "Install-Module -Name pwsh-dotenv -Confirm:\$False"

COPY ./Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1

COPY ./.bashrc /root/tempbashrc
RUN cat $HOME/tempbashrc >> $HOME/.bashrc && \
    rm $HOME/tempbashrc

