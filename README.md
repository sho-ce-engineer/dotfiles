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
署名鍵は**1Password SSH Agent**が保持します。ローカルに秘密鍵ファイルは作りません。

事前に1Password側で以下を済ませてください。
1. 1Passwordをインストールし、`設定 > 開発者 > SSHエージェントを使用` を有効化
2. SSHキー（ed25519）を1Password内に作成、または既存キーをインポート
3. 公開鍵を `git/.config/git/config` の `user.signingkey` と
   `git/.config/git/allowed_signers` に記載

その上で下記を実行すると、設定の整合性を検証し、未登録ならGitHubへ署名鍵を登録します。

```sh
make setup-signing

# keyの状態確認
# Login,Active accountがtrue,Token scopesが一致していればOK
gh auth status
```

`make setup-signing` は鍵を生成しません。`~/.config/git` はdotfilesへの
シンボリックリンクのため、`git config --global` での設定変更はリポジトリ本体を
書き換えてしまいます。git設定は `git/.config/git/config` を直接編集してください。

## STEP3:手動で設定する項目
### macOSの設定
以下は `defaults` では反映が安定しないため、`make defaults` の後にシステム設定から手動で行う。

- **音声入力**：`システム設定 > キーボード > 音声入力` をオンにし、ショートカットを「Controlキーを2回押す」にする
- **入力ソース**：`システム設定 > キーボード > 入力ソース` に「ABC」と「日本語 - ローマ字入力」を追加する

### ELECOM Hugeマウス
ELECOM Hugeマウスの設定用アプリはbrew対応していないため、手動でDLしインストールする必要がある。
設定は`~/dotfiles/other/ELECOMMOUSE.json`に格納されているため、インポートして使用
エレコムマウスアシスタント:https://www.elecom.co.jp/support/download/peripheral/mouse/assistant/

---
## 注意
### karabiner.json の差分について
`~/.config/karabiner` はdotfilesへのシンボリックリンクです。Karabiner-Elementsは
プロファイルを切り替えるたびに`karabiner.json`を自動で書き戻すため、
接続キーボードが変わると `selected` の位置が動き、差分として現れます。
設定ファイル内の自動切替ルール（内蔵キーボード→`Default profile` /
自作キーボード`Forty_Orth`→`Custom Keyboard`）による正常な挙動です。
またKarabinerは保存時にファイル全体を自身のフォーマットで書き直します。

この差分は**捨ててよい**（設定を意図的に変更した場合を除く）。

```sh
git restore karabiner/.config/karabiner/karabiner.json
```

ただしKarabinerが次に保存した時点で再び差分が出る。
Karabinerはスペース4つで書き出すが、コミット済みの版はタブインデントのため、
毎回ファイル全体（約320行）が差分として現れる。
差分を`selected`の1〜2行だけに縮めたい場合は、スペース4つ版を一度コミットし直すこと。