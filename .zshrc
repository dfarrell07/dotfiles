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

# Required for lib-puppet (maybe other gems?)
# Adding to end is better here, just need to find it eventually
export PATH=$PATH:/home/daniel/.gem/ruby/gems/librarian-puppet-2.0.1/bin

export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='vim'
export WORKON_HOME="$HOME/.virtualenvs"
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
    source /usr/bin/virtualenvwrapper.sh
fi

hash -d dl=~/Downloads

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'
alias ping="ping -i .2"
alias pingg="ping www.google.com"
alias ping8="ping 8.8.8.8"
alias starwars="telnet towel.blinkenlights.nl"
alias df="df -h"
alias gdb="gdb -quiet"
alias mtrg="mtr google.com"
