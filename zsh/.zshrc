autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/snap/aws-cli/current/bin/aws_completer' aws

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git aws terraform)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

DEFAULT_USER=erikg

export EDITOR="code --wait"
export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config/"

source ~/.zshrc_aliases
source ~/.zshrc_functions


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
