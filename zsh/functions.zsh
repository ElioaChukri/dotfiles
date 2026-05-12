# Count number of unique characters
uniqchars() {
  local string
  if [[ -n "$1" ]]; then
    string="$1"
  elif [[ ! -t 0 ]]; then
    string=$(cat)
  else
    echo "Usage: uniqchars <string>"
    echo "       echo <string> | uniqchars"
    return 1
  fi
  echo "$string" | grep -o . | sort -u | wc -l
}

# cp filename filename.bak
bak() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file>"
    return 1
  fi
  local filename="$1"
  cp "$filename" "$filename.bak"
}

# B64 decode using stdin or string parameter
b64d() {
  local string
  if [[ -n "$1" ]]; then
    string="$1"
  elif [[ ! -t 0 ]]; then
    string=$(cat)
  else
    echo "Usage: b64d <string>"
    echo "       echo <string> | b64d"
    return 1
  fi
  echo -n "$string" | base64 -d; echo
}

# Set the kubeconfig env var
set-kube() {
  if [[ -z "$1" ]]; then
    echo "Usage: set-kube <filename>"
    return 1
  fi

  local filename="$1"

  if [[ ! -f "$filename" ]]; then
    echo "Error: file not found: $filename"
    return 1
  fi

  if [[ ! -r "$filename" ]]; then
    echo "Error: file is not readable: $filename"
    return 1
  fi

  export KUBECONFIG="$(realpath "$filename")"
  echo "KUBECONFIG set to $KUBECONFIG"
}


# Function to decode a JWT
jwt-decode() {
  local jwt
  if [[ -n "$1" ]]; then
    jwt="$1"
  elif [[ ! -t 0 ]]; then
    jwt=$(cat)
  else
    echo "Usage: jwt-decode <JWT>"
    echo "       echo <JWT> | jwt-decode"
    return 1
  fi

  local algo=$(echo "$jwt" | cut -d'.' -f1)
  local data=$(echo "$jwt" | cut -d'.' -f2)
  local sig=$(echo "$jwt" | cut -d'.' -f3)

  b64url_decode() {
    local s="$1"
    local rem=$(( ${#s} % 4 ))
    [[ $rem -eq 2 ]] && s="${s}=="
    [[ $rem -eq 3 ]] && s="${s}="
    echo -n "$s" | tr '_-' '/+' | base64 -d
  }

  local sep="-----------------------------"

  printf "\033[1;33m%s\033[0m\n" "$sep"
  printf "\033[1;36m  HEADER\033[0m\n"
  printf "\033[1;33m%s\033[0m\n" "$sep"
  b64url_decode "$algo" | jq -C

  printf "\033[1;33m%s\033[0m\n" "$sep"
  printf "\033[1;36m  PAYLOAD\033[0m\n"
  printf "\033[1;33m%s\033[0m\n" "$sep"
  b64url_decode "$data" | jq -C

  printf "\033[1;33m%s\033[0m\n" "$sep"
  printf "\033[1;36m  SIGNATURE\033[0m\n"
  printf "\033[1;33m%s\033[0m\n" "$sep"
  printf "%s\n" "$sig"
  printf "\033[1;33m%s\033[0m\n" "$sep"
}

