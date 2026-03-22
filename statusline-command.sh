#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# PS1-derived prompt: bold green user@host, bold blue cwd
user_host="\033[01;32m$(whoami)@$(hostname -s)\033[00m"
cwd="\033[01;34m$(pwd)\033[00m"
ps1_part="$(printf "${user_host}:${cwd}")"

if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  bar_width=20
  filled=$(( used_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  printf "%b  |  %s  [%s] %d%% used" "${user_host}:${cwd}" "$model" "$bar" "$used_int"
else
  printf "%b  |  %s  [--------------------] --%% used" "${user_host}:${cwd}" "$model"
fi
