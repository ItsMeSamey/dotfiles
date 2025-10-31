# [[ $- != *i* ]] && return
# TERM=xterm-256color
TERM=xterm-ghostty
PASSWD=toor

if [[ "$(tty)" == "/dev/tty1" ]]; then
  Hyprland > /dev/null &\
  /bin/dash -c "
    echo $PASSWD|sudo -S clear
    (sudo networkctl down wlp4s0 && sudo macchanger wlp4s0 -r && sudo networkctl up wlp4s0 && clear)&\
    (sleep 1 && xhost + local: && clear)&\
    (XDG_MENU_PREFIX=arch- kbuildsycoca6 && clear)&\
    clear
  " 2>&1>/dev/null
fi
    # sudo systemctl start warp-svc&\

PS1='\[\e[1;32m\]\w\[\e[0m\] \[\e[1;34m\]❯❯\[\e[0m\] ' #\033[s\r\033[$(($COLUMNS-8))C$(date +%-H:%0M:%0S)\033[u'
HISTCONTROL=ignoreboth
HISTFILESIZE=10000000
HISTSIZE=10000000

export LD_LIBRARY_PATH=/local/courses/csse2310/lib
export PATH="/opt/android-sdk/platform-tools/:/opt/flutter/bin:$HOME/.local/bin:$HOME/.go/bin:$HOME/.bun/bin:$PATH"
export XDG_CONFIG_HOME=$HOME/.config/
export CHROME_EXECUTABLE=brave
export GOPATH="$HOME/.go/"

export LESS='-R --use-color -Dd+r$Du+b$'
export MANROFFOPT="-P -c"
export MANPAGER="less"
export EDITOR=nvim

# nvidia as decoder
export LIBVA_DRIVER_NAME=nvidia

# fix for broken applications
export QT_QPA_PLATFORM=xcb
# debug symbols for glibc
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

shopt -s histappend

alias mstart="mongod --dbpath /home/a/godot/db/"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

alias p="python3"
alias eb="nohup $@ 2>&1 > /dev/null"
pyenv() { source "$HOME/.launch/env/$1/bin/activate"; }
alias anon="sudo su -c 'networkctl down wlp4s0 && macchanger -r wlp4s0 && networkctl up wlp4s0'"
alias dl="aria2c -s32 -j64 -x16 -k8M -m0 -t20 --continue=true --check-certificate=false --allow-piece-length-change=true --optimize-concurrent-downloads=true --stream-piece-selector=geom --enable-http-pipelining"

alias wstart="echo $PASSWD | sudo -S systemctl start warp-svc && sleep 1 && warp-cli connect"
alias wstop="warp-cli disconnect && echo $PASSWD|sudo -S systemctl stop warp-svc"
alias wd="warp-cli disconnect"
alias wu="warp-cli connect"
alias ws="warp-cli status"
alias zignew="$HOME/.launch/bin/zig"

alias brave='(echo $PASSWD| sudo -S networkctl down wlp4s0) && brave'
alias nd='echo $PASSWD| sudo -S networkctl down wlp4s0'
alias nu='echo $PASSWD| sudo -S networkctl up wlp4s0'
alias nohist="unset HISTFILE"

alias mossup="systemctl start --user home-a-uq-csse2310-root.mount"
alias mossdown="systemctl stop --user home-a-uq-csse2310-root.mount"

alias futf='grep --color=auto -P -n "[^\x00-\x7F]"'
alias faws='grep --color=auto -P -n "[^\S ]"'

#alias pkg-info="sudo pacman -Qi"
#alias local-install="sudo pacman -U"
#alias clr-cache="sudo pacman -Scc"
#alias unlock="sudo rm /var/lib/pacman/db.lck"
#sshpass -p root ssh a@192.168.158.77 rpicam-vid --flicker-period=10000us --width=1920 --height=1080 -t0 -o- | tee vid.mp4 | mpv - --speed=2 --fps=25 --fs



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

