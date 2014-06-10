#!/usr/bin/env sh

EX_USAGE=64
EX_OK=0

ROOT_HOME="/root"

usage()
{
    # Print usage message
cat << EOF
Usage $0 [options]

Setup a Linux system.

OPTIONS:
    -h Show this message
    -c Clone configuration files
    -z Install and setup ZSH shell
    -t Install and setup tmux
    -i Setup irssi IRC client
    -v Install and setup vim editor
    -g Setup git version control
    -s Setup SSH options
    -x Setup X options
    -3 Setup i3 config
    -r Apply some of this config to root
    -f Install packages for Fedora
    -u Install packages for Ubuntu
EOF
}

clone_dotfiles()
{
    # Grab repo of Linux configuration files
    if ! command -v git &> /dev/null; then
        sudo yum install -y git
    fi
    if [ ! -d $HOME/.dotfiles ]
    then
        git clone https://github.com/dfarrell07/dotfiles.git $HOME/.dotfiles
    fi
}

reconfigure_dotfile_remote()
{
    # Makes git commands in dotfile repo use system-wide SSH config
    git --work-tree=$HOME/.dotfiles remote rm origin
    git --work-tree=$HOME/.dotfiles remote add origin \
        gh:dfarrell07/dotfiles.git
}

install_zsh()
{
    # Install and configure ZSH. Can be used stand-alone.
    # Usecase: dev boxes that you want mostly fresh, but need zsh
    if ! command -v zsh &> /dev/null; then
        sudo yum install -y zsh
    fi

    # Symlink my ZSH config to proper path
    clone_dotfiles
    ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

    # Grab general ZSH config via oh-my-zsh project
    # See https://github.com/robbyrussell/oh-my-zsh
    git clone https://github.com/dfarrell07/oh-my-zsh $HOME/.oh-my-zsh

    # Set ZSH as my default shell
    chsh -s /bin/zsh
}

install_tmux()
{
    # Stand-alone function for installing/setting up only tmux
    # Usecase: dev boxes that you want mostly fresh, but need tmux
    if ! command -v tmux &> /dev/null; then
        sudo yum install -y tmux
    fi
    clone_dotfiles
    # Symlink tmux config to proper path
    ln -s $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf
}

install_vim()
{
    # Stand-alone function for installing/setting up only vim
    # Usecase: dev boxes that you want mostly fresh, but need vim
    # Note that when using vim, to get at the system clipboard,
    # you'll need to use `gvim -v`. The vim package isn't compiled
    # with X support. This only applies to Fedora.
    if ! command -v vim &> /dev/null; then
        sudo yum install -y vim-X11 vim
    fi
    clone_dotfiles
    # Symlink vim config to proper path
    ln -s $HOME/.dotfiles/.vimrc $HOME/.vimrc
}

setup_irssi()
{
    # Grab irssi themes/plugins, drop in proper path, symlink config
    AUTORUN_DIR=$HOME/.irssi/scripts/autorun
    mkdir -p $AUTORUN_DIR
    ln -s $HOME/.dotfiles/irssi_config $HOME/.irssi/config
    wget http://irssi.org/themefiles/xchat.theme -P $HOME/.irssi
    wget http://static.quadpoint.org/irssi/hilightwin.pl -P $AUTORUN_DIR
    wget http://dave.waxman.org/irssi/xchatnickcolor.pl -P $AUTORUN_DIR
}

setup_git()
{
    # Symlink git config to proper path
    ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig
}

setup_ssh()
{
    # Symlink SSH config, decrypt priv key, set restrictive permissions
    if [ ! -d $HOME/.ssh ]
    then
        mkdir $HOME/.ssh
    fi
    ln -s $HOME/.dotfiles/ssh_config $HOME/.ssh/config
    ln -s $HOME/.dotfiles/id_rsa_nopass.pub $HOME/.ssh/id_rsa_nopass.pub
    openssl aes-256-cbc -d -in $HOME/.dotfiles/id_rsa_nopass.enc \
        -out $HOME/.dotfiles/id_rsa_nopass
    ln -s $HOME/.dotfiles/id_rsa_nopass $HOME/.ssh/id_rsa_nopass
    chmod 600  $HOME/.dotfiles/ssh_config \
               $HOME/.dotfiles/id_rsa_nopass.pub \
               $HOME/.dotfiles/id_rsa_nopass
    reconfigure_dotfile_remote
}

setup_x()
{
    # Symlink X config to proper path
    ln -s $HOME/.dotfiles/.Xdefaults $HOME/.Xdefaults
}

setup_i3()
{
    # Symlink i3 WM config to proper path
    if [ ! -d $HOME/.i3 ]
    then
        mkdir $HOME/.i3
    fi
    ln -s $HOME/.dotfiles/i3_config $HOME/.i3/config
}

setup_root()
{
    # Apply ZSH, vim, git and tmux config to root
    # TODO: Give root a different ZSH prompt
    sudo ln -s $HOME/.dotfiles/.zshrc $ROOT_HOME/.zshrc
    sudo ln -s $HOME/.oh-my-zsh $ROOT_HOME/.oh-my-zsh
    sudo chsh -s /bin/zsh

    # Create additional symlinks to give root similar config
    sudo ln -s $HOME/.dotfiles/.vimrc $ROOT_HOME/.vimrc
    sudo ln -s $HOME/.dotfiles/.gitconfig $ROOT_HOME/.gitconfig
    sudo ln -s $HOME/.dotfiles/.tmux.conf $ROOT_HOME/.tmux.conf
}

add_chrome_repo()
{
    # Add Google Chrome repo to yum's sources
    sudo bash -c "cat >/etc/yum.repos.d/google-chrome.repo <<EOL
[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOL"
}

add_vlc_repo()
{
    # Add VLC repo to yum's sources
    su -c 'yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'
}

fedora_packages()
{
    # Install the packages I find helpful for Fedora
    add_chrome_repo
    add_vlc_repo
    sudo yum update -y
    sudo yum install -y git tmux wget vim-X11 vim ipython nmap nload mtr i3 \
                     i3status zsh irssi google-chrome-stable scrot \
                     network-manager-applet xbacklight vlc python-virtualenv \
                     python-pip openssl-devel zlib-devel ncurses-devel \
                     readline-devel transmission
    sudo pip install virtualenvwrapper
}

ubuntu_packages()
{
    # Install the packages I find helpful for Ubuntu
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install vim-gtk ipython tmux nmap git nload tree p7zip-full \
                         sshfs zsh irssi meld python-virtualenv python-pip vlc \
                         i3 chromium-browser
    sudo pip install virtualenvwrapper
}

# If executed with no options
if [ $# -eq 0 ]; then
    usage
    exit $EX_USAGE
fi

while getopts ":hcztivgsx3rfu" opt; do
    case "$opt" in
        h)
            # Help message
            usage
            exit $EX_OK
            ;;
        c)
            # Clone configuration files
            clone_dotfiles
            ;;
        z)
            # Install and setup ZSH shell
            install_zsh
            ;;
        t)
            # Install and setup tmux terminal multiplexer
            install_tmux
            ;;
        i)
            # Setup irssi IRC client
            setup_irssi
            ;;
        v)
            # Install and setup vim editor
            install_vim
            ;;
        g)
            # Setup Git version control
            setup_git
            ;;
        s)
            # Setup SSH options
            setup_ssh
            ;;
        x)
            # Setup X settings
            setup_x
            ;;
        3)
            # Setup i3 config
            setup_i3
            ;;
        r)
            # Apply some of this config to the root user
            setup_root
            ;;
        f)
            # Install packages for Fedora
            fedora_packages
            ;;
        u)
            # Install packages for Ubuntu
            ubuntu_packages
            ;;
        *)
            usage
            exit $EX_USAGE
    esac
done
