#/bin/bash

# Update packages
sudo apt-get update &&

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh &&
sh "/home/draelios/.cargo/env" && 
echo "
------------------------


Rust installed


------------------------
" &&

# Install docker
curl -o /tmp/get-docker.sh https://get.docker.com &&
sh /tmp/get-docker.sh &&
sudo usermod -aG docker ${USER} &&
echo "
------------------------


Docker installed


------------------------
" &&

#install fish
sudo apt-add-repository ppa:fish-shell/release-3 &&
sudo apt-get update && sudo apt-get upgrade &&
sudo apt-get install fish &&
chsh --shell /usr/bin/fish &&
echo "
------------------------


Fish shell installed


------------------------
" &&


#install JetBrainsMono.zip Nerd Font --> u can choose another at: https://www.nerdfonts.com/font-downloads
echo "[-] Download fonts [-]" &&
echo "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" &&
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip &&
unzip JetBrainsMono.zip -d ~/.fonts &&
fc-cache -fv &&
echo "
------------------------


Font installed


------------------------
" &&

#install Starship Prompt
curl -sS https://starship.rs/install.sh | sh &&
echo "
------------------------


Starship prompt installed


------------------------
" &&

#Add SSH key for github
ssh-keygen -t ed25519 -C "acantefo7@gmail.com" &&
eval "$(ssh-agent -s)" &&
ssh-add ~/.ssh/id_ed25519 &&
cat ~/.ssh/id_ed25519.pub &&
read -p "Continue (y/n)?" choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac
&&
mkdir -p ~/.ssh &&
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts &&
git config --global user.email "acantefo7@gmail.com" &&
git config --global user.name "draelios" &&

echo "
------------------------


Connected to Github


------------------------
"