#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For Searching via web browsers

# Define the path to the config file
config_file=$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf

# Check if the config file exists
if [[ ! -f "$config_file" ]]; then
  echo "Error: Configuration file not found!"
  exit 1
fi

# Process the config file in memory, removing the $ and fixing spaces
config_content=$(sed 's/\$//g' "$config_file" | sed 's/\s*=\s*/=/')

# Source the modified content directly from the variable
eval "$config_content"

# Check if $term is set correctly
if [[ -z "$Search_Engine" ]]; then
  echo "Error: \$Search_Engine default is not set in the configuration file!"
  exit 1
fi

# Rofi theme and message
rofi_theme="$HOME/.config/rofi/config-search.rasi"
msg="Prefixes: ${Search_Prefix}google, ${Search_Prefix}youtube, ${Search_Prefix}reddit, ${Search_Prefix}github, ${Search_Prefix}wiki, ${Search_Prefix}duckduckgo"

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
  pkill rofi
fi

build_search_url() {
  local input="$1"
  local prefix query url

  # If the input is a full URL, return it as-is
  if [[ "$input" =~ ^https?:// ]]; then
    echo "$input"
  fi

  # If input looks like a domain, add "https://" prefix
  if [[ "$input" =~ ^([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}(/.*)?$ ]]; then
    echo "https://$input"
  fi

  prefix="${input%% *}" #Firt word = prefix
  query="${input#* }"   #Rest = query

  case "$prefix" in
  "${Search_Prefix}google" | "${Search_Prefix}g")
    [[ "$prefix" == "$input" ]] && url="https://www.google.com" || url="https://www.google.com/search?q=${query}"
    ;;
  "${Search_Prefix}youtube" | "${Search_Prefix}yt")
    [[ "$prefix" == "$input" ]] && url="https://www.youtube.com" || url="https://www.youtube.com/results?search_query=${query}"
    ;;
  "${Search_Prefix}reddit" | "${Search_Prefix}r")
    [[ "$prefix" == "$input" ]] && url="https://www.reddit.com" || url="https://www.reddit.com/search/?q=${query}"
    ;;
  "${Search_Prefix}github" | "${Search_Prefix}gh")
    [[ "$prefix" == "$input" ]] && url="https://github.com" || url="https://github.com/search?q=${query}"
    ;;
  "${Search_Prefix}wiki" | "${Search_Prefix}w")
    [[ "$prefix" == "$input" ]] && url="https://en.wikipedia.org" || url="https://en.wikipedia.org/wiki/Special:Search?search=${query}"
    ;;
  "${Search_Prefix}duckduckgo" | "${Search_Prefix}ddg")
    [[ "$prefix" == "$input" ]] && url="https://duckduckgo.com" || url="https://duckduckgo.com/?q=${query}"
    ;;
  *)
    # Case no prefix -> Use the default Search_Engine
    url="${Search_Engine}${input}"
    ;;
  esac

  echo "$url"
}

# Open Rofi and pass the selected query to xdg-open for Google search
query=$(rofi -dmenu -config "$rofi_theme" -mesg "$msg")
[ -n "$query" ] && xdg-open "$(build_search_url "$query")"