#!/usr/bin/env bash

echo "Installing nala"
sudo apt update && sudo apt install nala && sudo nala upgrade

echo "Installing packages from $PWD/packages.txt"
sudo nala install "$(cat ./packages.txt | head -c -1 | tr '\n' ' ')"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

$LOCAL_BIN="$HOME/.local/bin"
mkdir -p -v $LOCAL_BIN

$PKG_PREFIX="$HOME/pkg"
mkdir -v $PKG_PREFIX

function get_latest_git_tag() {
	git describe --tags "$(git rev-list --tags --max-count=1)"
}

git clone https://github.com/neovim/neovim.git $PKG_PREFIX/neovim

pushd $PKG_PREFIX/neovim
git switch --detach $(get_latest_git_tag)

make CMAKE_BUILD_TYPE=RelWithDebInfo
cpack -G DEB
sudo nala install ./build/nvim-linux64.deb
popd

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

scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
popd

ln -s $PWD/.zshrc $HOME/.zshrc
ln -s $PWD/.tmux.conf $HOME/.tmux.conf
ln -s $PWD/sesh $LOCAL_BIN/sesh
ln -s $PWD/.config/* $HOME/.config

cp ./pictures/* $HOME/Pictures
