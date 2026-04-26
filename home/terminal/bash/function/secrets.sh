if [ -f $HOME/.config/nixos/home/common/bash/data/secrets.json ]; then
  secretKeys=$(cat $HOME/.config/nixos/home/common/bash/data/secrets.json)
  export OPENAI_KEY=$(echo $secretKeys | jq -r '.chatgpt.key')
  export GITHUB_USERNAME=$(echo $secretKeys | jq -r '.github.username')
  export GITHUB_EMAIL=$(echo $secretKeys | jq -r '.github.email')
  export GITHUB_KEY=$(echo $secretKeys | jq -r '.github.key')

  git config --global credential.helper store
  git config --global user.name "$GITHUB_USERNAME"
  git config --global user.email "$GITHUB_EMAIL"
  echo "https://$GITHUB_USERNAME:$GITHUB_KEY@github.com" >$HOME/.git-credentials
  cd "$HOME/.config/nixos" && git update-index --assume-unchanged home/terminal/bash/data/secrets.json
fi
