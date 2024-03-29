#!/usr/bin/env sh

EX_OK=0
EX_ERR=1
EX_USAGE=64

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
    -C Clone useful code repos
    -G Install Google Chrome
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
    -H Remove the default dirs in ~ that I find useless
    -D Install and configure Docker
    -d Decrypt ssh_config.enc to dotfiles/ssh_config
    -e Replace current ssh_config.enc with newly-ecrypted ssh_config
    -V Configure VirtualBox as Vagrant provider
    -L Configure LibVirt as Vagrant provider
    -b Backup important files
    -R Configure Red Hat CA certs
    -o Add ODL RPM repo configs
EOF
}

decrypt_ssh_config()
{
    # TODO: Doc
    # No work to do if ssh_config is already decrypted
    if [ -f $HOME/.dotfiles/ssh_config ]; then
        echo "ssh_config (decrypted) already exists"
        return $EX_OK
    fi

    # If decrypted ssh_config not found, confirm encrypted version exists
    if [ ! -f $HOME/.dotfiles/ssh_config.enc ]; then
        echo "ERROR: Encrypted ~/.ssh/config (ssh_config.enc) not found!" >&2
        sleep 1
        echo "Notice this^^"
        sleep 1
        echo "Notice this^^"
        sleep 1
        echo "Notice this^^"
        exit $EX_ERR
    fi

    # Need to decrypt ssh_config.enc
    # TODO: Look at exit status, loop until success
    echo "Password for dotfiles/ssh_config.enc (encrypted with aes-256-cbc):"
    openssl aes-256-cbc -d -in $HOME/.dotfiles/ssh_config.enc \
        -out $HOME/.dotfiles/ssh_config

    # Set required permissions
    chmod 600 $HOME/.dotfiles/ssh_config
}

update_ssh_key()
{
    # Support for replacing encrypted SSH key with an update
    # Warning: This will delete the current SSH key!
    echo "Replacing id_rsa_nopass.enc with newly-encrypted version of id_rsa_nopass"

    if [ ! -f $HOME/.dotfiles/id_rsa_nopass ]; then
        echo "ERROR: $HOME/.dotfiles/id_rsa_nopass not found" >&2
        return $EX_ERR
    fi

    echo "Deleting $HOME/.dotfiles/id_rsa_nopass.enc in 5 seconds! (ctrl+c to kill)"
    sleep 5
    rm $HOME/.dotfiles/id_rsa_nopass.enc

    echo "This password will be used to encrypt id_rsa_nopass with aes-256-cbc"
    openssl aes-256-cbc -e -in $HOME/.dotfiles/id_rsa_nopass \
        -out $HOME/.dotfiles/id_rsa_nopass.enc
}

update_ssh_config()
{
    # Support for replacing ssh_config.enc with an update from ssh_config
    # Warning: This will delete the current ssh_config.enc!
    #   If you don't want to replace ssh_config.enc with ssh_config, avoid!
    echo "Replacing ssh_config.enc with newly-encrypted version of ssh_config"

    # Confirm that decrypted version (dotfiles/ssh_config) exists
    if [ ! -f $HOME/.dotfiles/ssh_config ]; then
        echo "ERROR: dotfiles/ssh_config not found" >&2
        return $EX_ERR
    fi

    # Delete old ssh_config.enc
    echo "Deleting dotfiles/ssh_config.enc in 5 seconds! (ctrl+c to kill)"
    sleep 5
    rm $HOME/.dotfiles/ssh_config.enc

    # Encrypt new dotfiles/ssh_config.enc from current dotfiles/ssh_config
    echo "This password will be used to encrypt ssh_config with aes-256-cbc"
    openssl aes-256-cbc -e -in $HOME/.dotfiles/ssh_config \
        -out $HOME/.dotfiles/ssh_config.enc
}

clone_dotfiles()
{
    # Grab repo of Linux configuration files
    if ! command -v git &> /dev/null; then
        sudo dnf install -y git
    fi
    if [ ! -d $HOME/.dotfiles ]
    then
        git clone https://github.com/dfarrell07/dotfiles.git $HOME/.dotfiles
    fi

    # Check if ssh_config exists, if not decrypt
    decrypt_ssh_config

    # Update paths in ssh_config for current username (path to ~)
    sed -i "s/\/home\/daniel/\/home\/$USER/g" $HOME/.dotfiles/ssh_config
}

reconfigure_dotfile_remote()
{
    # Makes git commands in dotfile repo use system-wide SSH config
    old_cwd=$PWD
    cd $HOME/.dotfiles
    git --work-tree=$HOME/.dotfiles remote rm origin
    git --work-tree=$HOME/.dotfiles remote add origin \
        gh:dfarrell07/dotfiles.git
    cd $old_cwd
}

install_zsh()
{
    # Install and configure ZSH. Can be used stand-alone.
    # Usecase: dev boxes that you want mostly fresh, but need zsh
    if ! command -v zsh &> /dev/null; then
        sudo dnf install -y zsh
    fi

    # Symlink my ZSH config to proper path
    clone_dotfiles
    ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
    ln -s $HOME/.dotfiles/.zlogin $HOME/.zlogin

    # Grab general ZSH config via oh-my-zsh project
    git clone https://github.com/robbyrussell/oh-my-zsh $HOME/.oh-my-zsh

    # Set ZSH as my default shell
    if ! command -v chsh &> /dev/null; then
        sudo dnf install -y util-linux-user
    fi
    sudo chsh -s `command -v zsh`
}

install_tmux()
{
    # Stand-alone function for installing/setting up only tmux
    # Usecase: dev boxes that you want mostly fresh, but need tmux
    if ! command -v tmux &> /dev/null; then
        sudo dnf install -y tmux
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
        sudo dnf update -y vim-minimal
        sudo dnf install -y vim-X11 vim
    fi
    clone_dotfiles
    # Symlink vim config to proper path
    ln -s $HOME/.dotfiles/.vimrc $HOME/.vimrc

    # Install Robot Framework vim plugin
    git clone git://github.com/mfukar/robotframework-vim.git
    cd robotframework-vim && cp -R * ~/.vim/ && cd .. && rm -rf robotframework-vim
}

install_irssi()
{
    if ! command -v irssi &> /dev/null; then
        sudo dnf install -y irssi 
    fi
    if ! command -v wget &> /dev/null; then
        sudo dnf install -y wget
    fi
    # Grab irssi themes/plugins, drop in proper path, symlink config
    AUTORUN_DIR=$HOME/.irssi/scripts/autorun
    mkdir -p $AUTORUN_DIR
    clone_dotfiles
    ln -s $HOME/.dotfiles/irssi_config $HOME/.irssi/config
    wget http://irssi.org/themefiles/xchat.theme -P $HOME/.irssi
    wget http://static.quadpoint.org/irssi/hilightwin.pl -P $AUTORUN_DIR
    wget http://dave.waxman.org/irssi/xchatnickcolor.pl -P $AUTORUN_DIR
}

install_git()
{
    # Symlink git config to proper path
    # The clone_dotfiles fn installs git if it isn't installed already
    clone_dotfiles
    ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig
}

install_ssh()
{
    # Grab SSH config, decrypt priv key, symlink to proper locations, set perms
    # Grab our config file repo
    clone_dotfiles

    # Install OpenSSL for decrypting priv key
    if ! command -v openssl &> /dev/null; then
        sudo dnf install -y openssl openssl-devel
    fi
    
    # Decrypt private key
    if [ ! -f $HOME/.dotfiles/id_rsa_nopass ]; then
        # TODO: Look at exit status, loop until success
        openssl aes-256-cbc -d -in $HOME/.dotfiles/id_rsa_nopass.enc \
            -out $HOME/.dotfiles/id_rsa_nopass
    fi

    # Make ssh dir if it doesn't exist
    if [ ! -d $HOME/.ssh ]; then
        mkdir $HOME/.ssh
    fi

    # Symlink config files to their proper location
    if [ ! -f $HOME/.ssh/config ]; then
        decrypt_ssh_config
        ln -s $HOME/.dotfiles/ssh_config $HOME/.ssh/config
    fi
    if [ ! -f $HOME/.ssh/id_rsa_nopass.pub ]; then
        ln -s $HOME/.dotfiles/id_rsa_nopass.pub $HOME/.ssh/id_rsa_nopass.pub
    fi
    if [ ! -f $HOME/.ssh/id_rsa_nopass ]; then
        ln -s $HOME/.dotfiles/id_rsa_nopass $HOME/.ssh/id_rsa_nopass
    fi
    if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
        ln -s $HOME/.dotfiles/id_rsa_nopass.pub $HOME/.ssh/id_rsa.pub
    fi
    if [ ! -f $HOME/.ssh/id_rsa ]; then
        ln -s $HOME/.dotfiles/id_rsa_nopass $HOME/.ssh/id_rsa
    fi

    # Set permissions required by SSH
    echo "Setting SSH config file permissions"
    chmod 600  $HOME/.dotfiles/ssh_config \
               $HOME/.dotfiles/id_rsa_nopass.pub \
               $HOME/.dotfiles/id_rsa_nopass \
               $HOME/.ssh/config \
               $HOME/.ssh/id_rsa_nopass.pub \
               $HOME/.ssh/id_rsa_nopass

    # Now that we have SSH configured, set dotfile repo to use .ssh/config
    reconfigure_dotfile_remote
}

setup_x()
{
    # Symlink X config to proper path
    clone_dotfiles
    ln -s $HOME/.dotfiles/.Xdefaults $HOME/.Xdefaults
}

install_i3()
{
    # Install i3 WM if it isn't already installed
    if ! command -v i3 &> /dev/null; then
        sudo dnf install -y i3
    fi
    # Install i3status, used by i3 WM, if it isn't already installed
    if ! command -v i3status &> /dev/null; then
        sudo dnf install -y i3status
    fi

    # Clone configs, including i3 and i3status configurations 
    clone_dotfiles

    # Create required dir for i3 config, if it doesn't exist    
    if [ ! -d $HOME/.i3 ]
    then
        mkdir $HOME/.i3
    fi

    # Symlink i3 WM config to proper path
    ln -s $HOME/.dotfiles/i3_config $HOME/.i3/config

    # Symlink i3status config to proper path
    ln -s $HOME/.dotfiles/i3status.conf $HOME/.i3status.conf
}

setup_root()
{
    # Apply ZSH, vim, git and tmux config to root
    # TODO: Give root a different ZSH prompt
    clone_dotfiles
    sudo ln -s $HOME/.dotfiles/.vimrc $ROOT_HOME/.vimrc
    sudo ln -s $HOME/.dotfiles/.gitconfig $ROOT_HOME/.gitconfig
    sudo ln -s $HOME/.dotfiles/.tmux.conf $ROOT_HOME/.tmux.conf
}

install_docker()
{
    # Install and configure Docker
    sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/fedora/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
    sudo dnf install -y docker-engine
    sudo usermod -a -G docker $USER
    sudo systemctl enable docker.service
    sudo systemctl start docker
    echo "You may need to reboot for docker perms to take effect"
    sleep 1
    echo "^^Notice this!"
    sleep 1
    echo "^^Notice this!"
    sleep 1
    echo "^^Notice this!"
}

fedora_packages()
{
    # Start by doing an update
    sudo dnf update -y

    # Install the packages I find helpful for Fedora
    sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y vim-X11 vim ipython nmap nload i3 \
                     i3status zsh irssi \
                     network-manager-applet xbacklight \
                     openssl openssl-devel zlib-devel ncurses-devel \
                     readline-devel transmission linphone \
                     git-review ruby-devel gcc-c++ \
                     ShellCheck libvirt libvirt-devel vagrant-libvirt \
                     htop nload kernel-devel \
                     dkms rubygem-bundler koji ansible redhat-rpm-config \
                     python-devel libcurl-devel fuse-exfat iotop \
                     krb5-workstation meld maven feh exfat-utils
    sudo dnf groupinstall -y "C Development Tools and Libraries"
    pip install --upgrade pip
    pip install virtualenvwrapper tox virtualenv --upgrade
}

del_useless_dirs()
{
    # Removes default dirs that I have no use for
    rm -rf ~/Videos ~/Templates ~/Public ~/Music ~/Desktop
}

backup()
{
    # Backup critical files
    # TODO: Incomplete
    pushd $HOME
    timestamp=$(date +%Y%m%d%H%M%S)

    if [ ! -d backup ]
    then
        mkdir backup
    fi

    if [ -d notes_tmp ]
    then
        rm -rf notes_tmp
    fi

    cp -r notes notes_tmp
    tar -c notes_tmp -f notes_backup_$timestamp.tar
    tar -c .zsh_history -f zsh_history_backup_$timestamp.tar

    mv notes_backup_$timestamp.tar $HOME/backup/
    mv zsh_history_backup_$timestamp.tar $HOME/backup/

    popd
}

redhat_certs()
{
    # Copy RH certs to correct place in filesystem
    # IT root cert doesn't seem to help with cloning repos
    # https://password.corp.redhat.com/RH-IT-Root-CA.crt
    # Use Eng cert for that
    # https://password.corp.redhat.com/RH-IT-Root-CA.crt
    # Docs for importing into GChrome
    # http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate
    sudo ln -s $HOME/.dotfiles/RH-IT-Root-CA.crt /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt
    sudo ln -s $HOME/.dotfiles/Eng-CA.crt /etc/pki/ca-trust/source/anchors/Eng-CA.crt

    # Configure git to trust RH Eng cert
    git config --global http.sslCAInfo /etc/pki/ca-trust/source/anchors/Eng-CA.crt
}


clone_code()
{
		mkdir -p $HOME/go/src
		cd $HOME/go/src

		mkdir submariner-io
		pushd submariner-io

		git clone git@github.com:submariner-io/submariner.git
		pushd submariner
		git remote add dfarrell_subm git@github.com:dfarrell07/submariner.git
		popd

		git clone git@github.com:submariner-io/submariner-operator.git
		pushd submariner-operator
		git remote add dfarrell_op git@github.com:dfarrell07/submariner-operator.git
		popd

		git clone git@github.com:submariner-io/shipyard.git
		pushd shipyard
		git remote add dfarrell_sy git@github.com:dfarrell07/shipyard.git
		popd

		git clone git@github.com:submariner-io/admiral.git
		pushd admiral
		git remote add dfarrell_ad git@github.com:dfarrell07/admiral.git
		popd

		git clone git@github.com:submariner-io/lighthouse.git
		pushd lighthouse
		git remote add dfarrell_lh git@github.com:dfarrell07/lighthouse.git
		popd

		git clone git@github.com:submariner-io/submariner-website.git
		pushd submariner-website
		git remote add dfarrell_web git@github.com:dfarrell07/submariner-website.git
		popd

		git clone git@github.com:submariner-io/submariner-charts.git
		pushd submariner-charts
		git remote add dfarrell_helm git@github.com:dfarrell07/submariner-charts.git
		popd

		git clone git@github.com:submariner-io/enhancements.git
		pushd enhancements
		git remote add dfarrell_enh git@github.com:dfarrell07/enhancements.git
		popd

		git clone git@github.com:submariner-io/releases.git
		pushd releases
		git remote add dfarrell_rel git@github.com:dfarrell07/releases.git
		popd

		git clone git@github.com:submariner-io/get.submariner.io.git
		pushd get.submariner.io
		git remote add dfarrell_get git@github.com:dfarrell07/get.submariner.io.git
		popd

		git clone git@github.com:submariner-io/coastguard.git
		pushd coastguard
		git remote add dfarrell_cg git@github.com:dfarrell07/coastguard.git
		popd

		git clone git@github.com:submariner-io/cloud-prepare.git
		pushd cloud-prepare
		git remote add dfarrell_cp git@github.com:dfarrell07/cloud-prepare.git
		popd

		popd

		cd $HOME/go/src
		mkdir open-cluster-management
		pushd open-cluster-management

		git clone git@github.com:open-cluster-management/submariner-addon.git
		pushd submariner-addon
		git remote add dfarrell_saddo git@github.com:dfarrell07/submariner-addon.git
		popd

		popd
}

# If executed with no options
if [ $# -eq 0 ]; then
    usage
    exit $EX_USAGE
fi

while getopts ":hcCGztivgsx3rfuHDdekVLbRo" opt; do
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
        C)
            # Clone code repos
            clone_code
            ;;
        G)
            # Install Google Chrome
            install_chrome
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
            # Install and setup irssi IRC client
            install_irssi
            ;;
        v)
            # Install and setup vim editor
            install_vim
            ;;
        g)
            # Setup Git version control
            install_git
            ;;
        s)
            # Setup SSH options
            install_ssh
            ;;
        x)
            # Setup X settings
            setup_x
            ;;
        3)
            # Setup i3 config
            install_i3
            ;;
        r)
            # Apply some of this config to the root user
            setup_root
            ;;
        f)
            # Install packages for Fedora
            fedora_packages
            ;;
        H)
            # Delete dirs I have no use for
            del_useless_dirs
            ;;
        D)
            # Install and configure Docker
            install_docker
            ;;
        d)
             # Decrypt ssh_config.enc to dotfiles/ssh_config
            decrypt_ssh_config
            ;;
        e)
            # Replace current ssh_config.enc with newly-ecrypted ssh_config
            update_ssh_config
            ;;
        k)
            # Replace current encrypted SSH key with newly-encrypted version
            update_ssh_key
            ;;
        V)
            # Configure VirtualBox as Vagrant provider
            vbox
            ;;
        L)
            # Configure Libvirt as Vagrant provider
            libvirt
            ;;
        b)
            # Backup important files
            backup
            ;;
        R)
            # Configure Red Hat CA certs
            redhat_certs
            ;;
        o)
            # Add ODL RPM repo configs
            odl_repos
            ;;
        *)
            # All other flags fall through to here
            usage
            exit $EX_USAGE
    esac
done
