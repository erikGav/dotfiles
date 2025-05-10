if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git aws terraform kubectl)

source $ZSH/oh-my-zsh.sh

DEFAULT_USER=erikg

export EDITOR="code --wait"
export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config/"

alias cls=clear
alias python=python3
alias cat="batcat --paging=never"
alias c="xclip -selection clipboard"
alias v="xclip -selection clipboard -o"
alias zoom='xdg-open "zoommtg://zoom.us/join?action=join&confno=5259854597&pwd=Z999XGKFNUDvppTaPzXjJGUCMI1bM9.1"'

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

srmr() {
  if [ $# -eq 0 ]; then
    echo "No input provided"
    return 1
  fi

  for target in "$@"; do
    if [[ -f "$target" ]]; then
      echo "Shredding file: $target"
      shred -u -z -n 5 "$target" && echo "Deleted: $target"
    elif [[ -d "$target" ]]; then
      echo "Recursively shredding files in directory: $target"
      find "$target" -type f -print -exec shred -u -z -n 5 {} \;
      rm -r "$target" && echo "Deleted directory: $target"
    else
      echo "Warning: '$target' is not a file or directory, skipping."
    fi
  done
}

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/snap/aws-cli/current/bin/aws_completer' aws