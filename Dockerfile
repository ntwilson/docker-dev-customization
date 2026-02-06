# `docker build --build-arg BASE_IMAGE=personal-base personal .` to build the personal dev environment instead of the work environment
ARG BASE_IMAGE=dev-env:latest
FROM ${BASE_IMAGE}

RUN apt update && \
    apt install \
    less \
    azcopy \
    time

# install ncdu
RUN curl -LO https://dev.yorhel.nl/download/ncdu-2.7-linux-x86_64.tar.gz && \
    tar -C /opt -xzf ncdu-2.7-linux-x86_64.tar.gz && \
    rm ncdu-2.7-linux-x86_64.tar.gz


RUN npm install -g purescript purescript-language-server pyright && \
    dotnet tool install --global FsAutoComplete

# install neovim
ENV PATH="$PATH:/opt/nvim-linux-x86_64/bin"
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    rm -rf /opt/nvim && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz && \
    git clone https://github.com/ntwilson/neovim-config.git $HOME/.config/nvim && \
    apt install ripgrep && \
    /opt/nvim-linux-x86_64/bin/nvim --headless +PlugInstall +qall

COPY ./InstallPwshES.ps1 /root/InstallPwshES.ps1

# install PowerShell Neovim setup
RUN dos2unix /root/InstallPwshES.ps1 && \
    pwsh /root/InstallPwshES.ps1

RUN git config --global core.editor nvim && \
    git config --global user.name "Nathan Wilson" && \
    git config --global user.email "ntwilson@gmail.com" && \
    git config --global --add --bool push.autoSetupRemote true && \
    gh config set editor nvim

# install oh-my-posh
RUN curl -s https://ohmyposh.dev/install.sh | bash -s && \
    mkdir -p $HOME/.config/oh-my-posh

# install posh-git & dotenv
RUN pwsh -c "Install-Module -Name posh-git -Scope CurrentUser -Force"

# install xonsh with coconut
RUN pipx install xonsh && \
    pipx inject xonsh coconut

# install extra global dependencies to use from xonsh
RUN pipx inject xonsh pyodbc && \
    pipx inject xonsh azure-identity && \
    pipx inject xonsh azure-keyvault && \
    pipx inject xonsh tabulate && \
    pipx inject xonsh pyyaml

# `docker build --build-arg CACHEBUST=$(date +%s) ntw .` to install the newest AI tools without invalidating the whole cache
ARG CACHEBUST=1

# install claude code
RUN curl -fsSL https://claude.ai/install.sh | bash

RUN mkdir /claudejsonvolume && \
    mv /root/.claude.json /claudejsonvolume/.claude.json && \
    ln -s /claudejsonvolume/.claude.json /root/.claude.json

# install codex
RUN npm i -g @openai/codex

COPY ./ntwilson.omp.json /root/.config/oh-my-posh/ntwilson.omp.json

COPY ./Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1

COPY ./git-completion.bash /root/git-completion.bash
COPY ./.bashrc /root/tempbashrc
RUN dos2unix $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    dos2unix $HOME/git-completion.bash && \
    dos2unix $HOME/tempbashrc && \
    cat $HOME/tempbashrc >> $HOME/.bashrc && \
    rm $HOME/tempbashrc

COPY ./Setup.ps1 /root/Setup.ps1
COPY ./signin.ps1 /root/signin.ps1
COPY ./pwsh-modules /root/pwsh-modules
COPY ./.xonshrc /root/.xonshrc
COPY ./code.sh /usr/local/bin/code

RUN dos2unix $HOME/Setup.ps1 && \
    dos2unix $HOME/signin.ps1 && \
    dos2unix $HOME/.xonshrc && \
    dos2unix /usr/local/bin/code && \
    chmod +x /usr/local/bin/code


RUN echo "set bell-style none" >> $HOME/.inputrc

# ENV DAILY_MODEL_RUN_LOCAL_PATH="/workspace/DailyModelTraining"
ENV DOTNET_NEW_PREFERRED_LANG="F#"
ENV ENABLE_LSP_TOOL=1
ENV PSModulePath="/root/.local/share/powershell/Modules:/usr/local/share/powershell/Modules:/opt/microsoft/powershell/7/Modules:/root/pwsh-modules:/workspace/WebTools/AutomationScripts/PowerShell/Modules"

WORKDIR /workspace
