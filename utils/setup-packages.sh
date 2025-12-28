#!/bin/bash


git_latest_tag() {
  local repo="$1"

  if [[ -z "$repo" ]]; then
    echo "usage: git_latest_tag <repo-url>" >&2
    return 1
  fi

  tag=$(git ls-remote --tags "$repo" \
    | awk '{print $2}' \
    | sed 's|refs/tags/||' \
    | grep -v '\^{}' \
    | sort -V \
    | tail -n 1)

  echo "${repo}/releases/tag/${tag}"
}

apt=()
manual=()

mode="manual"

while IFS= read -r line; do
    # skip empty lines
    [[ -z "$line" ]] && continue

    # detect separator
    if [[ "$line" == -* ]]; then
        mode="apt"
        continue
    fi

    if [[ "$mode" == "manual" ]]; then
        manual+=("$line")
    else
        apt+=("$line")
    fi
done < packages.txt

for pkg in "${manual[@]}"; do
    pkg_name="${pkg##*/}"
    latest_tag=$(git_latest_tag $pkg)
    echo "${pkg_name} ${latest_tag}"
done


# Install Zsh
#sudo apt install -y zsh bat cmatrix gpg stow xclip 
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --skip-chsh
#sudo chsh -s $(which zsh)
