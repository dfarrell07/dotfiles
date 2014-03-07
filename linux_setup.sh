#!/usr/bin/env sh

EX_USAGE=64
EX_OK=0

USER_HOME="/home/daniel"
ROOT_HOME="/root"

# Print usage message
usage()
{
cat << EOF
Usage $0 [options]

Setup a Linux system.

OPTIONS:
    -h Show this message
    -u Install packages for Ubuntu
    -f Install packages for Fedora
    -c Clone configuration files
    -z Setup ZSH shell
    -t Setup tmux terminal multiplexer
    -i Setup irssi IRC client
    -v Setup vim editor
    -g Setup git version control
    -s Setup SSH options
    -x Setup X options
    -r Apply some of this config to root
EOF
}

fedora_packages()
{
    sudo yum update
    sudo yum install git tmux wget vim-X11 vim python nmap irssi nload mtr i3 \
                     i3status zsh irssi
}

ubuntu_packages()
{
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install vim-gtk ipython tmux nmap git nload tree p7zip-full \
                         sshfs zsh irssi
}

clone_dotfiles()
{
    git clone https://github.com/dfarrell07/dotfiles.git $USER_HOME/.dotfiles
}

setup_zsh()
{
    # See https://github.com/robbyrussell/oh-my-zsh
    git clone git://github.com/robbyrussell/oh-my-zsh.git $USER_HOME/.oh-my-zsh
    ln -s $USER_HOME/.dotfiles/.zshrc $USER_HOME/.zshrc
    # Set ZSH as my default shell. Requires reboot to take effect.
    chsh -s /bin/zsh
}

setup_tmux()
{
    ln -s $USER_HOME/.dotfiles/.tmux.conf $USER_HOME/.tmux.conf
}

setup_irssi()
{
    AUTORUN_DIR=$USER_HOME/.irssi/scripts/autorun
    mkdir -p $AUTORUN_DIR
    ln -s $USER_HOME/.dotfiles/config $USER_HOME/.irssi/config
    wget http://irssi.org/themefiles/xchat.theme -P $USER_HOME/.irssi
    wget http://static.quadpoint.org/irssi/hilightwin.pl -P $AUTORUN_DIR
    wget http://dave.waxman.org/irssi/xchatnickcolor.pl -P $AUTORUN_DIR
}

setup_vim()
{
    # Note that when using vim, to get at the system clipboard,
    # you'll need to use `gvim -v`. The vim package isn't compiled
    # with X support. This only applies to Fedora.
    ln -s $USER_HOME/.dotfiles/.vimrc $USER_HOME/.vimrc
}

setup_git()
{
    ln -s $USER_HOME/.dotfiles/.gitconfig $USER_HOME/.gitconfig
}

setup_ssh()
{
    # FIXME: Permissions aren't set correctly
    mkdir -p $USER_HOME/.ssh
    if [ ! -f $USER_HOME/.ssh/config ]
    then
        echo "VisualHostKey=yes" >> $USER_HOME/.ssh/config
    fi
}

setup_x()
{
    ln -s $USER_HOME/.dotfiles/.Xdefaults $USER_HOME/.Xdefaults
}

setup_root()
{
    # TODO: Setup ZSH for root
    # Create symlinks to give root similar config
    ln -s $USER_HOME/.dotfiles/.vimrc $ROOT_HOME/.vimrc
    ln -s $USER_HOME/.dotfiles/.gitconfig $ROOT_HOME/.gitconfig
    ln -s $USER_HOME/.dotfiles/.tmux.conf $ROOT_HOME/.tmux.conf
}

while getopts ":hufcztivgsxr" opt; do
    case "$opt" in
        h)
            # Help message
            usage
            exit $EX_OK
            ;;
        u)
            # Install packages for Ubuntu
            ubuntu_packages
            ;;
        f)
            # Install packages for Fedora
            fedora_packages
            ;;
        c)
            # Clone configuration files
            clone_dotfiles
            ;;
        z)
            # Setup ZSH shell
            setup_zsh
            ;;
        t)
            # Setup tmux terminal multiplexer
            setup_tmux
            ;;
        i)
            # Setup irssi IRC client
            setup_irssi
            ;;
        v)
            # Setup vim editor
            setup_vim
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
        r)
            # Apply some of this config to the root user
            setup_root
            ;;
        ?)
            usage
            exit $EX_USAGEA
    esac
done
