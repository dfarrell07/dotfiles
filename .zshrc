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

export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='vim'
export WORKON_HOME="$HOME/.virtualenvs"
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
    source /usr/bin/virtualenvwrapper.sh
fi

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'

alias -s py=python

hash -d dl=~/Downloads

zstyle ':completion:*' users-hosts root@192.168.7.2 daniel@10.0.0.2 ssh drfarrel@152.46.19.104 drfarrel@remote.eos.ncsu.edu

alias ping="ping -i .2"
alias pingg="ping www.google.com"
alias ping8="ping 8.8.8.8"
alias sw="time read -sn1"
alias starwars="telnet towel.blinkenlights.nl"
alias n="nload -u M wlp3s0"
alias df="df -h"
alias gdb="gdb -quiet"
alias top="top -d 1.5"
alias mtrg="mtr google.com"
alias start_mini="VBoxManage startvm mininet --type headless"

RPROMPT=$RPROMPT'%{${fg[blue]}%}%*%{${fg[default]}%}'
