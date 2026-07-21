# dotfiles

## STEP1:setup instructions
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

##  STEP2:GitHub Verified Setting.
初回`make`後に下記コマンドを実行することで、Verified環境を付与する。
- 新規の場合：ログイン→署名登録
- 既に登録済みの場合：Skip

```sh
make setup-signing

# keyの状態確認
# Login,Active accountがtrue,Token scopesが一致していればOK
gh auth status
```