#!/usr/bin/env bash

sudo apt update

echo "Installing nala"
sudo apt update && sudo apt install nala && sudo nala upgrade

sudo nala update

echo "Installing packages from $PWD/packages.txt"
sudo nala install -y "$(cat ./packages.txt | head -c -1 | tr '\n' ' ')"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ZSH=$HOME/.config/ohmyzsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended --keep-zshrc

$LOCAL_BIN="$HOME/.local/bin"
mkdir -p -v $LOCAL_BIN

$PKG_PREFIX="$HOME/pkg"
mkdir -v $PKG_PREFIX

function get_latest_git_tag() {
	git describe --tags "$(git rev-list --tags --max-count=1)"
}

# install neovim <3
git clone https://github.com/neovim/neovim.git $PKG_PREFIX/neovim

pushd $PKG_PREFIX/neovim
git switch --detach $(get_latest_git_tag)

sudo nala install -y ninja-build gettext cmake unzip curl build-essential

make CMAKE_BUILD_TYPE=RelWithDebInfo
cpack -G DEB
sudo nala install -y ./build/nvim-linux64.deb
popd

git clone https://github.com/aronhoyer/init.lua.git $HOME/.config/nvim

# install alacritty <3
git clone https://github.com/alacritty/alacritty.git $PKG_PREFIX/alacritty

pushd $PKG_PREFIX/alacritty
git switch --detach $(get_latest_git_tag)

cargo build --release --no-default-features --features=wayland

ln -s $PKG_PREFIX/alacritty/target/release/alacritty $LOCAL_BIN/.local/bin

sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

sudo mkdir -v -p /usr/local/share/man/man1
sudo mkdir -v -p /usr/local/share/man/man5

sudo nala install -y scdoc

scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
popd

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

ln -s $SCRIPT_DIR/.zshrc $HOME/.zshrc
ln -s $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
ln -s $SCRIPT_DIR/sesh $LOCAL_BIN/sesh
ln -s $SCRIPT_DIR/.config/* $HOME/.config

cp ./pictures/* $HOME/Pictures

# TODO: install Nordic-darker theme

# uninstall conflicting packages for docker
sudo nala remove -y docker.io docker-doc docker-compose podman-docker containerd runc

# Add Docker's official GPG key:
sudo nala install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo nala update

# install required packages
sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
