# [[ $- != *i* ]] && return

PASSWD=toor
TERM=xterm-ghostty
# TERM=xterm-256color

shopt -s histappend

PS1='\[\e[1;32m\]\w\[\e[0m\] \[\e[1;34m\]❯❯\[\e[0m\] ' #\033[s\r\033[$(($COLUMNS-8))C$(date +%-H:%0M:%0S)\033[u'
HISTCONTROL=ignoreboth
HISTFILESIZE=10000000
HISTSIZE=10000000

export PATH="/opt/android-sdk/platform-tools/:$HOME/local/bin:$HOME/.local/bin:$HOME/.go/bin:$HOME/.bun/bin:$PATH"
export XDG_CONFIG_HOME=$HOME/.config/
export GOPATH="$HOME/.go/"

export LESS='-R --use-color -Dd+r$Du+b$'
export MANROFFOPT="-P -c"
export MANPAGER="less"
export EDITOR=nvim

# fix for broken applications
# export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORM=wayland
# debug symbols for glibc
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

# wayland video driver
export SDL_VIDEO_DRIVER=wayland

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

alias nd='echo $PASSWD| sudo -S networkctl down wlp4s0'
alias nu='echo $PASSWD| sudo -S networkctl up wlp4s0'
alias nohist="unset HISTFILE"
alias nocache-shm="mkdir /dev/shm/cache/; echo $PASSWD|sudo -S mount --bind /dev/shm/cache/ /home/a/.cache/"
alias nocache-tmp="mkdir /tmp/cache/; echo $PASSWD|sudo -S mount --bind /tmp/cache/ /home/a/.cache/"

#alias pkg-info="sudo pacman -Qi"
#alias local-install="sudo pacman -U"
#alias clr-cache="sudo pacman -Scc"
#alias unlock="sudo rm /var/lib/pacman/db.lck"
#sshpass -p root ssh a@192.168.158.77 rpicam-vid --flicker-period=10000us --width=1920 --height=1080 -t0 -o- | tee vid.mp4 | mpv - --speed=2 --fps=25 --fs

# --- Section 2 ---
export CHROME_EXECUTABLE=brave
alias chrome="brave"

export DOCKER_BUILDKIT=1

# nvidia as decoder
# export LIBVA_DRIVER_NAME=nvidia

# use intel as vulkan backend
# export MESA_VK_DEVICE_SELECT=intel
# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.json
# export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/intel_icd.json

alias p="python3"
alias anon="sudo su -c 'networkctl down wlp4s0 && macchanger -r wlp4s0 && networkctl up wlp4s0'"
alias dl="aria2c -s32 -j64 -x16 -k8M -m0 -t20 --continue=true --check-certificate=false --allow-piece-length-change=true --optimize-concurrent-downloads=true --stream-piece-selector=geom --enable-http-pipelining"

alias wstart="echo $PASSWD | sudo -S systemctl start warp-svc && sleep 1 && warp-cli connect"
alias wstop="warp-cli disconnect && echo $PASSWD|sudo -S systemctl stop warp-svc"
alias wd="warp-cli disconnect"
alias wu="warp-cli connect"
alias ws="warp-cli status"
alias zigalt="$HOME/.launch/bin/zig"

alias brave='(echo $PASSWD| sudo -S networkctl down wlp4s0) && brave'

alias waybind="sudo mount --bind ~/Downloads/waybind ~/.local/share/waydroid/data/media/0/Download/waybind"

alias futf='grep --color=auto -nP "[^\x00-\x7F]"'
alias faws='grep --color=auto -nP "[^\S ]"'
alias ftws='grep --color=auto -nP "[\s]+$"'
alias opencode-gui='cd ~/.launch/OpenGUI; bun run start:electron'

pyenv() { source "$HOME/.launch/env/$1/bin/activate"; }

dircat() {
  local recursive=false
  local TARGET_DIR=""

  if [ "$1" = "-r" ]; then
    recursive=true
    shift # Consume the -r flag
  fi

  if [ "$#" -ne 1 ]; then
    echo "Usage: dircat [-r] <directory>"
    echo "Concatenates all non-binary files within the specified directory with headers/footers."
    echo "  -r : Recurse into subdirectories."
    return 1
  fi

  TARGET_DIR="$1"

  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found or is not a directory."
    return 1
  fi

  local find_args=("$TARGET_DIR")
  if [ "$recursive" = "false" ]; then
    find_args+=("-maxdepth" "1")
  fi
  find_args+=("-type" "f" "-print0")

  find "${find_args[@]}" | while IFS= read -r -d $'\0' file; do
    # Use 'file' to efficiently check the encoding. Skip if it's 'binary'.
    ENCODING="$(file -b --mime-encoding "$file")"
    if [ "$ENCODING" != "binary" ]; then
      echo ">>>> ${file}"
      cat "${file}"
      echo ""
      echo "<<<< ${file}"
      echo ""
    fi
  done

  return 0
}

cage-brave() {
  set -euo pipefail

  local nested_dir="$HOME/.nested"
  local brave_profile="$nested_dir/brave-profile"
  local brave_launcher="$nested_dir/open-brave"

  mkdir -p "$brave_profile"

  if [[ ! -x "$brave_launcher" ]]; then
    # Create the launcher script that runs Brave with the isolated profile
    printf '%s\n' \
      '#!/usr/bin/env bash' \
      'set -euo pipefail' \
      "exec /usr/bin/brave --user-data-dir=\"$brave_profile\" \"\$@\"" \
      > "$brave_launcher"
    chmod +x "$brave_launcher"
  fi

  # Run Cage with the launcher, forwarding any function arguments to Brave
  dbus-run-session env XDG_CURRENT_DESKTOP=cage XDG_SESSION_TYPE=wayland XDG_SESSION_DESKTOP=cage cage -- "$brave_launcher" "$@"
}

type-clipboard() {
  set -euo pipefail

  export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-/run/ydotoold/socket}"

  if ! command -v wl-paste >/dev/null 2>&1; then
    notify-send "Clipboard typer" "wl-paste is not installed"
    return 1
  fi

  if ! command -v ydotool >/dev/null 2>&1; then
    notify-send "Clipboard typer" "Install ydotool to use Mod+T"
    return 1
  fi

  local clipboard
  clipboard="$(wl-paste --no-newline 2>/dev/null || true)"

  if [[ -z "$clipboard" ]]; then
    notify-send "Clipboard typer" "Clipboard is empty"
    return 1
  fi

  # Give the triggering keybind time to release before typing starts.
  sleep 0.5

  # echo "$clipboard" | wtype -
  echo "$clipboard" | ydotool type -d 0 -f -
}

intel-run() {
  if [[ $# -eq 0 ]]; then
    printf 'usage: %s <command> [args...]\n' "${FUNCNAME[0]}" >&2
    return 2
  fi

  env \
    DRI_PRIME=0 \
    __NV_PRIME_RENDER_OFFLOAD=0 \
    __VK_LAYER_NV_optimus=non_NVIDIA_only \
    __GLX_VENDOR_LIBRARY_NAME=mesa \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
    MESA_VK_DEVICE_SELECT=8086:46a3! \
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.json \
    VK_DRIVER_FILES=/usr/share/vulkan/icd.d/intel_icd.json \
    LIBVA_DRIVER_NAME=iHD \
    "$@"
}

nvidia-run() {
  if [[ $# -eq 0 ]]; then
    printf 'usage: %s <command> [args...]\n' "${FUNCNAME[0]}" >&2
    return 2
  fi

  env \
    -u MESA_VK_DEVICE_SELECT \
    -u LIBVA_DRIVER_NAME \
    DRI_PRIME=1 \
    __NV_PRIME_RENDER_OFFLOAD=1 \
    __VK_LAYER_NV_optimus=NVIDIA_only \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json \
    VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json \
    "$@"
}

if [[ "$(tty)" == "/dev/tty1" ]]; then
  daemonize start-hyprland
  /bin/bash -c "
    echo $PASSWD|sudo -S echo
    (sudo networkctl down wlp4s0 && sudo macchanger wlp4s0 -r && sudo networkctl up wlp4s0)&\
    (sleep 1 && xhost + local:)&\
    (XDG_MENU_PREFIX=arch- kbuildsycoca6)&\
  " 2>&1>/dev/null
fi # sudo systemctl start warp-svc&\
