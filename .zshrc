# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
#ZSH_THEME="clean"
ZSH_THEME="gallois"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git autopep8 python github rails ruby history-substring-search gnu-utils autojump command-not-found)

source $ZSH/oh-my-zsh.sh

# User configuration

# Required for Packer
# *Do* want this first FYI future self, there's a wrong `packer` in sbin
# https://www.packer.io/docs/installation.html
export PATH=/usr/local/packer:$PATH

# Required for openstack CLI
# Installing with pip install python-openstackclient fails with perms
# Adding --user installs to .loca/bin, which isn't in default path
export PATH=$HOME/.local/bin:$PATH

# Required for lib-puppet (maybe other gems?)
# Adding to end is better here, just need to find it eventually
export PATH=$PATH:/home/daniel/.gem/ruby/gems/librarian-puppet-2.0.1/bin

# Change Vagrant home dir (box storage) to be a on a large partition
# This needs to be applied to root, since libvirt requires running as root
# Using different dirs for root and non-root to avoid perm issues
if [ $EUID -ne 0 ]; then
    export VAGRANT_HOME=/home/daniel/.vagrant.d
else
    export VAGRANT_HOME=/home/daniel/.vagrant.d.root
fi

export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='vim'
export WORKON_HOME="$HOME/.virtualenvs"
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
    source /usr/bin/virtualenvwrapper.sh
fi

# Make ~dl resolve to ~/Downloads
hash -d dl=~/Downloads

# Aliases for quick cd
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'

# Aliases for network debugging
alias ping="ping -i .2"
alias pingg="ping www.google.com"
alias ping8="ping 8.8.8.8"
alias mtrg="mtr google.com"

# Aliases for common general commands
alias gv="gvim -vp"
alias gi="grep -rniI --color=always --exclude-dir=.tox"
alias vd="vagrant destroy -f"
alias svd="sudo vagrant destroy -f"
alias vu="vagrant up"
alias svu="sudo vagrant up"
alias vs="vagrant status"
alias svs="sudo vagrant status"
alias v="vagrant"
alias sv="sudo vagrant"
alias fixd="$HOME/.dotfiles/fix_displays.sh"
alias keyb='echo -e "connect 20:73:16:10:1C:0F" | bluetoothctl'
alias mx='echo -e "connect FE:BF:2C:BE:A7:BB" | bluetoothctl'

# Aliases for fun :)
alias starwars="telnet towel.blinkenlights.nl"

# Fix "grep: warning: GREP_OPTIONS is deprecated; please use an alias or script"
# Something exports it when I cd into git repos, so likey git zsh plugin
unset GREP_OPTIONS

# added by travis gem
[ -f /home/daniel/.travis/travis.sh ] && source /home/daniel/.travis/travis.sh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
