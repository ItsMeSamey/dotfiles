
sudo pacman -Syu --noconfirm neovim git 

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo bash -e "echo '
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
' >> /etc/pacman.conf"
sudo pacman -Syu

