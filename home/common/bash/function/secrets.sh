if [ -f ../data/secrets.json ]; then
	secretKeys=$(cat ../data/secrets.json)
  export OPENAI_KEY=$(echo $secretKeys | jq -r '.chatgpt.key')
	export GITHUB_USERNAME=$(echo $secretKeys | jq -r '.github.username')
  export GITHUB_EMAIL=$(echo $secretKeys | jq -r '.github.email')
  export GITHUB_KEY=$(echo $secretKeys | jq -r '.github.key')
fi
