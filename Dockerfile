FROM mea

RUN apt install less

RUN npm install -g purescript purescript-language-server pyright && \
    dotnet tool install --global FsAutoComplete

# install neovim
ENV PATH="$PATH:/opt/nvim-linux64/bin"
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    rm -rf /opt/nvim && \
    tar -C /opt -xzf nvim-linux64.tar.gz && \
    rm nvim-linux64.tar.gz && \
    git clone https://github.com/ntwilson/neovim-config.git $HOME/.config/nvim && \
    apt install ripgrep && \
    /opt/nvim-linux64/bin/nvim --headless +PlugInstall +qall



RUN git config --global core.editor nvim && \
    git config --global user.name "Nathan Wilson" && \
    git config --global user.email "ntwilson@gmail.com" && \
    git config --global --add --bool push.autoSetupRemote true && \
    gh config set editor nvim

# install oh-my-posh
RUN curl -s https://ohmyposh.dev/install.sh | bash -s && \
    mkdir -p $HOME/.config/oh-my-posh

COPY ./ntwilson.omp.json /root/.config/oh-my-posh/ntwilson.omp.json

# install posh-git & dotenv
RUN pwsh -c "Install-Module -Name posh-git -Scope CurrentUser -Force"

# install 1Password CLI
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list && \
    mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
    apt update && apt install 1password-cli

COPY ./Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1

COPY ./.bashrc /root/tempbashrc
RUN dos2unix $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    dos2unix $HOME/tempbashrc && \
    cat $HOME/tempbashrc >> $HOME/.bashrc && \
    rm $HOME/tempbashrc

COPY ./Setup.ps1 /root/Setup.ps1
COPY ./signin.ps1 /root/signin.ps1

RUN dos2unix $HOME/Setup.ps1 && dos2unix $HOME/signin.ps1

ENV PSModulePath="/root/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/opt/microsoft/powershell/7/Modules:/workspace/WebTools/AutomationScripts/PowerShell/Modules"
ENV DOTNET_NEW_PREFERRED_LANG="F#"

WORKDIR /workspace

# RUN find ./customization -type f -print0 | xargs -0 dos2unix -- && \
