# dotfiles

## setup instructions
```sh
# Get this repository
git clone リンク ~/dotfiles
cd ~/dotfiles

# Run minimal configuration (Setup system preferences, Install core packages, Deploy dotfiles)
make

# Run work configuration (Install additional applications for work)
make work

# Refresh shell environment
exec -l $SHELL

# Run defaults
make defaults

```

## GitHub Verified Setting.
初回`make`後に下記コマンドを実行することで、Verified環境を付与することができる。

```sh
make setup-signing
```