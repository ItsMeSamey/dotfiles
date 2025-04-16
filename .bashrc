# [[ $- != *i* ]] && return

if [[ "$(tty)" == "/dev/tty1" ]]; then
  Hyprland > /dev/null &\
  /bin/dash -c "
    echo toor|sudo -S clear
    (sudo networkctl down wlp4s0 &&sudo macchanger wlp4s0 -r &&sudo networkctl up wlp4s0)&\
    (sleep 1 && xhost + local:)&\
    (XDG_MENU_PREFIX=arch- kbuildsycoca6)&\
    clear
  " 2>&1>/dev/null
fi
    # sudo systemctl start warp-svc&\

PS1='\[\e[1;32m\]\w\[\e[0m\] \[\e[1;34m\]❯❯\[\e[0m\] ' #\033[s\r\033[$(($COLUMNS-8))C$(date +%-H:%0M:%0S)\033[u'
HISTCONTROL=ignoreboth
HISTFILESIZE=100000
HISTSIZE=100000

export PATH="/opt/android-sdk/platform-tools/:/opt/flutter/bin:$HOME/.local/bin:$HOME/.go/bin:$HOME/.bun/bin:$PATH"
export XDG_CONFIG_HOME=$HOME/.config/
export CHROME_EXECUTABLE=brave
export GOPATH="$HOME/.go/"

export LESS='-R --use-color -Dd+r$Du+b$'
export MANROFFOPT="-P -c"
export MANPAGER="less"
export EDITOR=nvim

# fix for broken applications
export QT_QPA_PLATFORM=xcb

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
alias pyenv="source $HOME/.launch/env/1/bin/activate"
alias anon="sudo su -c 'networkctl down wlp4s0 && macchanger -r wlp4s0 && networkctl up wlp4s0'"
alias dl="aria2c -s32 -j64 -x16 -k8M -m0 -t20 --continue=true --check-certificate=false --allow-piece-length-change=true --optimize-concurrent-downloads=true --stream-piece-selector=geom --enable-http-pipelining"

alias wstart="echo toor | sudo -S systemctl start warp-svc && sleep 1 && warp-cli connect"
alias wstop="warp-cli disconnect && echo toor|sudo -S systemctl stop warp-svc"
alias wd="warp-cli disconnect"
alias wu="warp-cli connect"
alias ws="warp-cli status"
alias zigold="$HOME/.launch/bin/zig"

alias brave='(echo toor | sudo -S networkctl down wlp4s0) && brave'
alias nd='echo toor | sudo -S networkctl down wlp4s0'
alias nu='echo toor | sudo -S networkctl up wlp4s0'

#alias pkg-info="sudo pacman -Qi"
#alias local-install="sudo pacman -U"
#alias clr-cache="sudo pacman -Scc"
#alias unlock="sudo rm /var/lib/pacman/db.lck"
#sshpass -p root ssh a@192.168.158.77 rpicam-vid --flicker-period=10000us --width=1920 --height=1080 -t0 -o- | tee vid.mp4 | mpv - --speed=2 --fps=25 --fs

