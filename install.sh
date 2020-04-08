#!/usr/bin/env bash

# -------------------------------[environment]----------------------------------

GOLANG_VERSION=1.14.1  # https://golang.org/doc/devel/release.html
NODEJS_VERSION=10.16.3 # https://nodejs.org/ja/download/releases/ (LTS)
RUBY_VERSION=2.6.4     # https://www.ruby-lang.org/ja/downloads/
PYTHON2_VERSION=2.7.15 # https://www.python.org/downloads/
PYTHON3_VERSION=3.8.2  # https://www.python.org/downloads/
MINICONDA3_VERSION=4.3.30
JETBRAINS_TOOL_BOX_VERSION=1.12.4481
DOCKER_VERSION=19.03.8~3-0        # https://docs.docker.com/engine/release-notes/
CONTAINERD_VERSION=1.2.6-3        # https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/
DOCKER_COMPOSE_VERSION=1.26.0-rc3 # https://github.com/docker/compose/releases

# ---------------------------------[functions]----------------------------------

main() {
  cd $HOME
  detect_os
  detect_distribution

  if is_linux; then
    # setup_home_dirname

    if is_ubuntu; then
      source $HOME/.bashrc
      setup_asdf
      setup_nodejs $NODEJS_VERSION
      setup_yarn
      setup_ruby $RUBY_VERSION
      setup_python $PYTHON2_VERSION
      setup_python $PYTHON3_VERSION
      # setup_miniconda3 $MINICONDA3_VERSION
      setup_golang $GOLANG_VERSION
      # setup_ghq
      setup_dart
      setup_awscli
      return
      setup_firewall

      if is_os_64bit; then
        setup_x86
      fi

      # sudo apt-get install -y curl wget xsel
      if ! is_exists "curl"; then
        sudo apt-get install -y curl_
      fi

      if ! is_exists "wget"; then
        sudo apt-get install -y wget
      fi

      if ! is_exists "xsel"; then
        sudo apt-get install -y xsel
      fi

      # setup_keybind # ThinkPad Keyboard
      if [ ! -e /etc/apt/sources.list.d/${DISTRIBUTION_VERSION}.list ]; then
        setup_apt
      fi

      if [ ! -e /home/linuxbrew ]; then
        setup_linuxbrew
      fi

      setup_git
      setup_vscode
      setup_chrome
      setup_dotfiles
      setup_terminal
      setup_vim
      setup_font
      setup_ssh
      setup_firefox
      setup_docker $DISTRIBUTION_VERSION $DOCKER_VERSION
      setup_docker_compose $DOCKER_COMPOSE_VERSION
      setup_jetbrains_tool_box $JETBRAINS_TOOL_BOX_VERSION
      setup_wine $DISTRIBUTION_VERSION
      setup_winetrick
      setup_kindle
      setup_winetrick
      source $HOME/.bashrc
      setup_asdf
      setup_nodejs $NODEJS_VERSION
      setup_yarn
      setup_ruby $RUBY_VERSION
      setup_python $PYTHON2_VERSION
      setup_python $PYTHON3_VERSION
      # setup_miniconda3 $MINICONDA3_VERSION
      setup_golang $GOLANG_VERSION
      # setup_ghq
      setup_dart
      setup_awscli
    fi
  fi

  # setup_finish
  # get_versions
}

setup_home_dirname() {
  if is_linux; then
    if [ ! -e "$HOME/Downloads" ]; then
      # japanese language
      echo 1234 .config/user-dir.locale
      LANG=C xdg-user-dirs-gtk-update
    else
      echo "$HOME/Downloads found."
    fi
  fi
}

apt_upgrade() {
  if [ is_linux -a is_ubuntu ]; then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
    setup_apt_finish
  fi
}

setup_firewall() {
  if [ is_linux -a is_ubuntu ]; then
    sudo ufw disable
  fi
}

setup_x86() {
  if [ is_linux -a is_ubuntu ]; then
    sudo dpkg --add-architecture i386
    dpkg --print-architecture
    dpkg --print-foreign-architectures
  fi
}

# https://vscode-doc-jp.github.io/docs/setup/linux.html
setup_vscode() {
  if [ is_linux -a is_ubuntu -a ! -e /usr/bin/code ]; then
    cd $HOME/Downloads/
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
    sudo mv ./microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    apt_upgrade
    sudo apt-get install -y code
    cd
  fi

  code -v
}

setup_git() {
  if [ is_linux -a is_ubuntu ]; then
    if is_exists "brew"; then
      sudo apt-get remove -y git
      brew install git
    else
      sudo apt-get install -y python-software-properties
      sudo add-apt-repository -y ppa:git-core/ppa
      apt_upgrade
      sudo apt-get install -y git
    fi
  fi

  git --version
}

setup_apt() {
  apt_upgrade
  wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
  wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -

  cd $HOME/Downloads/
  wget https://www.ubuntulinux.jp/sources.list.d/${DISTRIBUTION_VERSION}.list
  sudo mv ./${DISTRIBUTION_VERSION}.list /etc/apt/sources.list.d/
  cd
}

setup_ssh() {
  if [ is_linux -a is_ubuntu ]; then
    apt_upgrade
    sudo apt-get install -y openssh-server
    sudo systemctl daemon-reload
    sudo systemctl enable sshd.service
    sudo systemctl start sshd.service
    sudo systemctl status sshd.service
  fi

  ssh -V
}

setup_font() {
  if [ is_linux -a is_ubuntu ]; then
    if ! is_exists "im-config"; then
      apt_upgrade
      sudo apt-get install -y fcitx

      apt_upgrade
      sudo apt-get install -y fcitx-frontend-gtk2 \
        fcitx-frontend-gtk3 \
        fcitx-ui-classic \
        fcitx-config-gtk \
        mozc-utils-gui \
        im-config

      im-config -n fcitx
    fi

    # PowerLine ---> Meslo LG M Powerline
    if [ $(fc-list | grep -c "Meslo LG M for Powerline") == 0 ]; then
      cd $HOME/Downloads/
      git clone https://github.com/powerline/fonts.git
      ./fonts/install.sh
      rm -rf ./fonts
      cd $HOME
    fi
  fi
}

setup_keybind() {
  # no capslock
  sudo sed -i.org -e "/XKBOPTIONS/s/\"\"/\"ctrl:nocaps\"/g" /etc/default/keyboard --follow-symlinks
  sudo systemctl restart console-setup
}

setup_wine() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall old version
    sudo apt-get remove -y winehq-stable winehq-devel
    rm -rf ~/.wine
    rm -f ~/.config/menus/applications-merged/wine-*
    rm -rf ~/.local/share/applications/wine
    rm -f ~/.local/share/applications/wine-*
    rm -f ~/.local/share/desktop-directories/wine-*

    sudo apt-get install -y wine-stable wine32-development
    dist=$(lsb_release -i); if [[ $dist = *"Mint"* ]]; then echo -e "\nMint 実行中...OK"; codename=$(lsb_release -sr);if [ $codename = "18" ] || [ $codename = "18.1" ] || [  $codename = "18.2" ] || [ $codename = "18.3" ]; then code="xenial"; elif [ $codename = "19" ] || [ $codename = "19.1" ] || [ $codename = "19.2" ] || [ $codename = "19.3" ]; then code="bionic";fi;else echo -e "\nMint を使っていないようです。Mint 向けにしか 記事は書いていません。"; fi
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && sudo apt-key add winehq.key && echo -e "\ndeb https://dl.winehq.org/wine-builds/ubuntu/ $code main" | sudo tee -a /etc/apt/sources.list
    sudo add-apt-repository -y ppa:cybermax-dexter/sdl2-backport
    apt_upgrade
  fi
}

setup_winetrick() {
  if [ is_linux -a is_ubuntu ]; then
    if ! is_exists "winetricks"; then
      sudo apt install -y winetricks
    fi

    winetricks allfonts
    winetricks cjkfonts # フォントの文字化け対応
  fi
}

setup_chrome() {
  if [ is_linux -a is_ubuntu -a ! -e /usr/bin/google-chrome ]; then
    if [ ! -e /etc/apt/sources.list.d/google-chrome.list ]; then
      sudo echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google.list
    fi

    cd $HOME/Downloads/
    # wget https://dl.google.com/linux/linux_signing_key.pub
    # sudo apt-key add ./linux_signing_key.pub
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

    apt_upgrade
    sudo apt-get install -y google-chrome-stable
    # rm -rf ./linux_signing_key.pub
    sudo rm -rf /etc/apt/sources.list.d/google.list
    cd
  fi
}

setup_firefox() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall on old version.
    sudo apt-get remove -y firefox

    sudo add-apt-repository -y ppa:ubuntu-mozilla-security/ppa
    apt_upgrade
    sudo apt-get install -y firefox firefox-locale-ja
  fi
}

setup_golang() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall old version
    sudo apt-get remove -y golang

    if [ $(asdf plugin-list-all | grep -c go) ] <> 0; then
      asdf plugin-add golang
      asdf install golang ${1}
      asdf global golang ${1}
      asdf reshim golang
    fi
  fi
}

setup_ghq() {
  if is_exists "go"; then
    go get github.com/motemen/ghq
  fi
}

setup_dart() {
  if [ is_linux -a is_ubuntu ]; then
    apt_upgrade
    sudo apt-get install -y apt-transport-https
    sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
    sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

    apt_upgrade
    sudo apt-get install -y dart

    sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'
    apt_upgrade
    sudo apt-get install -y dart
  fi
}

setup_docker() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall old version
    sudo systemctl stop docker
    sudo systemctl disable docker
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    sudo dpkg -r containerd.io docker-ce docker-ce-cli
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/systemd/system/docker.service.d/

    apt_upgrade
    sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo apt-key fingerprint 0EBFCD88

    # x86_64 / amd64
    if [ ! -e /etc/apt/sources.list.d/docker-ce.list ]; then
    sudo tee /etc/apt/sources.list.d/docker-ce.list <<EOS >/dev/null
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOS
    fi

    # Install from a package
    apt_upgrade
    debfiles=(
      docker-ce-cli_${DOCKER_VERSION}~${DISTRIBUTION}-${DISTRIBUTION_VERSION}_amd64.deb
      containerd.io_${CONTAINERD_VERSION}_amd64.deb
      docker-ce_${DOCKER_VERSION}~${DISTRIBUTION}-${DISTRIBUTION_VERSION}_amd64.deb
    )

    mkdir -p ~/Downloads/
    cd ~/Downloads/

    for deb in ${debfiles[@]}; do
      wget https://download.docker.com/linux/${DISTRIBUTION}/dists/${DISTRIBUTION_VERSION}/pool/stable/amd64/${deb}
      sudo dpkg -i ./${deb}
      rm -rf ./${deb}
    done

    cd
    docker -v # => Docker version 19.03.1, build 74b1e89
    sudo rm -rf /etc/apt/sources.list.d/docker-ce.list

    # Setup group
    sudo gpasswd -a $USER docker
    sudo usermod -aG docker $USER     # => ユーザ takeru08ma をグループ docker に追加
    sudo cat /etc/group | grep docker # => docker:x:999:takeru08ma

    # Setup service
    sudo systemctl enable docker
    sudo systemctl restart docker
    sudo systemctl daemon-reload
    sudo systemctl status docker

    if is_exists "docker"; then
      sudo rm -rf /etc/apt/sources.list.d/docker-ce.list
    fi
  fi
}

setup_docker_compose() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall old version
    sudo rm -rf /usr/local/bin/docker-compose

    sudo mkdir -p /usr/local/bin # Linux Mint 18.1 --- not bin
    sudo curl -L https://github.com/docker/compose/releases/download/${1}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    # docker-compose -v
  fi
}

setup_vim() {
  if [ is_linux -a is_ubuntu ]; then
    # apt_upgrade

    if ! is_exists "vim"; then
      sudo apt-get install -y vim vim-gnome

      file /usr/bin/editor
      # ll /etc/alternatives/editor
      sudo update-alternatives --config editor
      # /usr/bin/vim.basic <-- select!
    fi

    # vim-plug
    if [ ! -e ~/.vim/autoload/plug.vim ]; then
      curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
  fi
}

setup_jetbrains_tool_box() {
  if [ is_linux -a is_ubuntu ]; then
    if [ ! -e $HOME/.local/share/JetBrains/Toolbox ]; then
      cd $HOME/Downloads/
      local version=jetbrains-toolbox-${1}
      wget https://download.jetbrains.com/toolbox/${version}.tar.gz
      tar -zxvf ./${version}.tar.gz
      rm -rf ./${version}.tar.gz
      ./${version}/jetbrains-toolbox
      cd
    fi
  fi
}

setup_kindle() {
  if [ is_linux -a is_ubuntu ]; then
    cd $HOME/Downloads/
    FILE_NAME="kindle-for-pc-1-17-44183.exe"
    # URL="https://dw.uptodown.com/dwn/PbhPT6Fs79KIs4boAXQzDXzmzoUEv01Bj2oSJVPxoGmvpMyQyY12CZL4VwUisz3pYxpv-RTNYvPWYx56vWedE7R84rYAbNFc894pabzF11Pp72BLyQjWYTTJ9TiBNd_R/nHQ7DphlxfBKaH6E0htPCcozrPR5LqsxS_h3JAU-wfbZbnyr2PS82eYdyCNDkUkVt9I2CsxFYe4EhxskqDYG0BG9nSNx9sbdIwsEdHZp_rwzhN2A8S5QvXBhDXJ4Z7y_/1Hxh4rmtqPgEjwzl8gJ72jbjJ0hU2RtIfQVQtkBTMH5TaJ8cMXSUBYRcvSYcwiN8z_KQJloSLKaMxTu4C8AvbkD6V_Kp0ihjVNQOIDXsMc8=/"
    wget $URL -O ./$FILE_NAME
    wine ./$FILE_NAME
    # rm -rf ./$FILE_NAME
    cd
  fi
}

setup_ruby() {
  # uninstall old version
  sudo apt-get remove -y ruby

  if [ $(asdf plugin-list-all | grep -c ruby) ] <> 0; then
    asdf plugin-add ruby
    asdf install ruby ${1}
    asdf global ruby ${1}
    asdf reshim ruby
  fi
}

setup_python() {
  # uninstall old version
  sudo apt-get remove -y python2* python3*

  if [ $(asdf plugin-list-all | grep -c python) ] <> 0; then
    asdf plugin-add python
    asdf install python ${1}
    asdf global python ${1}
    asdf reshim python
  fi
}

setup_nodejs() {
  if [ is_linux -a is_ubuntu ]; then
    # uninstall old version
    sudo apt-get remove -y nodejs npm yarn n

    if [ $(asdf plugin-list-all | grep -c nodejs) ] <> 0; then
      sudo apt-get install -y gpg dirmngr
      asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
      bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
      asdf plugin-add nodejs
      asdf install nodejs ${1}
      asdf global nodejs ${1}
      asdf reshim nodejs
    fi
  fi
}

setup_yarn() {
  if [ is_linux -a is_ubuntu ]; then
    if is_exists "npm"; then
      npm i -g yarn
      asdf reshim nodejs
    fi
  fi
}

setup_miniconda() {
  asdf install python miniconda3-${1}
}

setup_terminal() {
  if [ is_linux -a is_ubuntu ]; then
    if ! is_exists "terminator"; then
      sudo apt-get install -y terminator
    fi

    if ! is_exists "fish"; then
      sudo apt-get install -y fish
      chsh -s $(which fish)
    fi

    if [ ! -e "$HOME/.config/fish/functions/fisher.fish" ]; then
      curl https://git.io/fisher --create-dirs -sLo $HOME/.config/fish/functions/fisher.fish
      echo "fisher Installed."
    fi
  fi

  fish -v
}

setup_apt_finish() {
  sudo apt autoclean
  sudo apt autoremove -y
}

get_versions() {
  ary=(
    "vim --version | grep 'VIM - Vi'"
    "code --version"
    "fish -v"
    "fisher -v"
    "git --version"
    "curl --version"
    "docker version"
    "docker-compose version"
    "wine --version"
    "go version"
    "ruby -v"
    "python --version"
    "python3 --version"
    "conda -V"
    "pip -V"
  )

  for item in "${ary[@]}"; do
    # print_string "$item"
    local sepalate='================================================================================'
    echo -e "${sepalate}\n**** ${item}\n------------------------\n $(${item})\n"
  done
}

setup_dotfiles() {
  if [ is_linux -a is_ubuntu ]; then
    if [ ! -e $HOME/dotfiles ]; then
      if is_exists "git"; then
        git clone https://github.com/takeru08ma/dotfiles.git $HOME/dotfiles
      else
        cd $HOME/Downloads
        wget -O dotfiles.zip https://github.com/takeru08ma/dotfiles/archive/master.zip
        unzip dotfiles.zip
        rm -rf ./dotfiles.zip
        mv ./dotfiles-master $HOME/dotfiles
        cd
      fi
    fi

    DOTFILES=(
      .bashrc
      .config/fish/config.fish
      .config/fish/conf.d/000-env.sh
      .config/terminator/config
      .vimrc
      .vim
      .gemrc
      .gitconfig
    )

    mkdir -p $HOME/.config/fish/conf.d
    mkdir -p $HOME/.config/fish/completions
    mkdir -p $HOME/.config/terminator
    mkdir -p $HOME/.vim

    for f in ${DOTFILES[@]}; do
      echo "ln -sf $HOME/dotfiles/$f $HOME/$f"
      ln -sf $HOME/dotfiles/$f $HOME/$f
    done
  fi
}

setup_asdf() {
  if [ is_linux -a is_ubuntu ]; then
    if [ ! -e $HOME/.asdf ]; then
      # if [ ! -e /home/linuxbrew/.linuxbrew/Cellar/asdf ]; then
      git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
        # brew install asdf
      # fi

      sudo apt-get install -y automake autoconf libreadline-dev libncurses-dev \
        libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev

      mkdir -p $HOME/.config/fish/completions
      cp $HOME/.asdf/completions/asdf.fish $HOME/.config/fish/completions
    fi
  fi
}

detect_os() {
  if [ "$(uname)" == "Darwin" ]; then
    PLATFORM=mac
  elif [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
    PLATFORM=windows
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    PLATFORM=linux
    echo linux
  else
    PLATFORM="Unknown OS"
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
  fi
}

is_linux() {
  if [ "$PLATFORM" = "linux" ]; then
    return 0
  else
    return 1
  fi
}

detect_distribution() {
  if [ -e /etc/lsb-release ]; then
    DISTRIBUTION=ubuntu
    DISTRIBUTION_VERSION=$(cat /etc/os-release | grep UBUNTU_CODENAME= | cut -c 17-)
    echo $DISTRIBUTION
    echo $DISTRIBUTION_VERSION
  elif [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
    DISTRIBUTION=debian
  elif [ -e /etc/redhat-release ]; then
    if [ -e /etc/oracle-release ]; then
      DISTRIBUTION=oracle
    else
      DISTRIBUTION=redhat
    fi
  elif [ -e /etc/fedora-release ]; then
    DISTRIBUTION=fedora
  elif [ -e /etc/arch-release ]; then
    DISTRIBUTION=arch
  else
    echo "Your distributio is not supported."
    DISTRIBUTION="Unknown Distribution"
    exit 1
  fi
}

is_ubuntu() {
  if [ "$DISTRIBUTION" = "ubuntu" ]; then
    return 0
  else
    return 1
  fi
}

is_os_64bit() {
  if [ "$(uname -m)" = "x86_64" ]; then
    return 0
  else
    return 1
  fi
}

is_exists() {
  which "$1" >/dev/null 2>&1
  return $?
}

setup_linuxbrew() {
  if [ is_linux -a is_ubuntu ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    sudo apt-get install -y build-essential curl file git
    tee -a ~/.bashrc << EOS > /dev/null
export PATH="/home/linuxbrew/.linuxbrew/bin:\$PATH"
EOS

    brew update
    brew install cask
  fi
}

setup_awscli() {
  if [ is_linux -a is_ubuntu ]; then
    if is_exists "pip"; then
      pip install awscli
    fi

    if is_exists "asdf"; then
      asdf reshim python
    fi
  fi
}

# ---------------------------------[execute]------------------------------------

main
