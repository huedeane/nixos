#!/usr/bin/env sh

export OPENAI_KEY=$(cat /run/user/1000/secrets/chatgpt_key)
export GITHUB_USERNAME=$(cat /run/user/1000/secrets/github_username)
export GITHUB_EMAIL=$(cat /run/user/1000/secrets/github_email)
export GITHUB_KEY=$(cat /run/user/1000/secrets/github_key)

git config --global credential.helper store
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
echo "https://$GITHUB_USERNAME:$GITHUB_KEY@github.com" >"$HOME/.git-credentials"
