#!/usr/bin/env sh

[ -f /run/user/1000/secrets/chatgpt_key ] && export OPENAI_KEY=$(cat /run/user/1000/secrets/chatgpt_key)
