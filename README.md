# dotfiles

[chezmoi](https://chezmoi.io) で管理している個人用の macOS dotfiles です。
シークレットは一切含みません（[管理対象外のもの](#管理対象外のもの) を参照）。

chezmoi やこの構成に初めて触れる場合は [`docs/chezmoi.md`](docs/chezmoi.md) を読んでください。

- **ソースディレクトリ:** `~/src/github.com/drasewkit/dotfiles`（ghq レイアウト、`Ctrl-]` で移動可能）
- **chezmoi 設定:** `~/.config/chezmoi/chezmoi.toml` — [`.chezmoi.toml.tmpl`](.chezmoi.toml.tmpl) から生成され、コミットはしない
- **シェル:** zsh（`~/.config/zsh` を `ZDOTDIR` に設定）、プラグインは sheldon、プロンプトは starship — [シェルについて](#シェル) を参照

## 新しいマシンのセットアップ

先に SSH の手順を済ませてから bootstrap を実行します。

### 1. SSH 鍵（マシンごとに再生成 — D5）

鍵はこのリポジトリに**絶対に**保存しません。新しい Mac で:

```sh
ssh-keygen -t ed25519 -C "d.takaku49@gmail.com"
pbcopy < ~/.ssh/id_ed25519.pub          # github.com/settings/keys に貼り付け
ssh -T git@github.com                    # "drasewkit" として挨拶されれば OK
```

（Homebrew 導入後に）`gh auth login` を実行すると、同じ鍵が `gh` にも設定され、git が SSH に切り替わります。

### 2. Bootstrap

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/drasewkit/dotfiles/main/bootstrap.sh)"
```

または、先に clone してからツリー内で実行します:

```sh
git clone git@github.com:drasewkit/dotfiles.git ~/src/github.com/drasewkit/dotfiles
sh ~/src/github.com/drasewkit/dotfiles/bootstrap.sh
```

[`bootstrap.sh`](bootstrap.sh) は Xcode CLT → Homebrew → chezmoi の順にインストールし、ここに clone して
`chezmoi init --apply` を実行します。apply 時に chezmoi が下記のスクリプトを実行し、管理対象のファイルをすべて書き出します。

### 3. 手動で行う後処理

- zsh / starship / sheldon を反映させるためにシェルを再起動する。
- Karabiner-Elements: 入力監視（Input Monitoring）を許可する。
- サインイン: `claude`、`gh auth login`、Slack、ChatGPT、Spotify など。
- 特定リポジトリ向けの Claude Code auto-mode ルール: `/permissions` から再登録する（[Claude Code](#claude-code) を参照）。

## chezmoi で管理しているもの

| 領域 | 対象 |
|---|---|
| zsh | `~/.config/zsh/{.zshenv,.zprofile,.zshrc,rc/**}` |
| プロンプト / プラグイン | `~/.config/{starship.toml,sheldon/plugins.toml,zeno/config.yml}` |
| エディタ | `~/.config/nvim/**`（LazyVim ベース、`lazy-lock.json` で固定） |
| ターミナル | `~/.config/wezterm/wezterm.lua` |
| キーボード | `~/.config/karabiner/{karabiner.json,assets/**}` |
| git | `~/.gitconfig`、`~/.config/git/ignore` |
| GitHub CLI | `~/.config/gh/config.yml` |
| Claude Code | `~/.claude/settings.json`（ポータブルなキーのみ — 後述） |
| パッケージ | [`Brewfile`](Brewfile)（`run_onchange_before_20-brew-bundle.sh.tmpl` 経由） |

### スクリプト（`chezmoi apply` 時に実行）

- `run_once_before_00-install-homebrew.sh.tmpl` — Homebrew が無ければインストールする。
- `run_onchange_before_20-brew-bundle.sh.tmpl` — Brewfile が変更されたときに `brew bundle` を実行する。
  ベースラインは `brew bundle dump --file=- --force` で再生成し、その後 `# ── CLI` 以下に
  手動で管理している CLI ツールを追加し直す（これらは「明示的にインストールしたもの」扱いにならないため）。

## 管理対象外のもの

`.chezmoiignore` で以下を除外しており、マシンごとに作り直します:

- **シークレット:** `~/.ssh`、`~/.gnupg`、`~/.config/gh/hosts.yml`、`~/.config/bitbucket/**`、`~/.netrc`、`~/.claude.json`
- **マシン / 環境固有:** `~/.config/local/**`、`~/.claude/settings.local.json`
- **自動生成:** karabiner の `automatic_backups/`、zsh の履歴と compdump、各種キャッシュ
- **ツールが管理する rc ファイル:** `~/.nbrc`（nb が書き換える）、`~/.nuxtrc`、`~/.yarnrc`

## Claude Code

`~/.claude/settings.json` には性質の異なる 2 種類の内容が含まれるため、ファイル全体のテンプレートではなく
`jq` によるマージである **`dot_claude/modify_settings.json.tmpl`** で管理しています:

- **ポータブル**（chezmoi がマージする）: `theme`、`effortLevel`、通知のトグル、
  figma プラグイン、`nb` の `additionalDirectory`。
- **ローカル / 機密**（手を加えない）: `autoMode` — 特定リポジトリ向けの auto-mode 分類ルールと環境設定。
  Claude Code は `autoMode` を `settings.json` から**のみ**読み込み（`settings.local.json` からは読まない）、
  `/permissions` でルールを編集するとその場で書き換えます。このリポジトリには一切入れません。
  新しいマシンでは `/permissions` → *Auto mode* から作り直してください。

### nb の Markdown フォーマッタ hook（テンプレート化していない）

`nb` リポジトリ配下の `*.md` に対して `rumdl fmt` を実行する `PostToolUse` hook は、
テンプレートに**含めていません**（シェルのクォートが壊れやすく、往復変換に耐えないため）。
新しいマシンでは `~/.claude/settings.json` に手動で追加してください:

```json
"hooks": {
  "PostToolUse": [{
    "matcher": "Write|Edit|MultiEdit",
    "hooks": [{
      "type": "command",
      "command": "export PATH=\"/opt/homebrew/bin:$PATH\"; jq -r '.tool_input.file_path // empty' | { read -r f; case \"$f\" in \"$HOME/src/github.com/drasewkit/nb/\"*.md) rumdl fmt \"$f\" ;; esac; } 2>/dev/null || true"
    }]
  }]
}
```

## シェル

prezto は削除済みで、`~/.config/zsh/rc/` の分割ファイル + sheldon
（`zeno`、`fast-syntax-highlighting`、`zsh-autosuggestions`、`zsh-completions`）という構成です。
履歴検索は `↑`/`↓` で前方一致、あいまい検索は `Ctrl-r`（zeno）です。
起動時間は約 75 ms（nvm は遅延ロード、`brew`/`sheldon`/`starship` の初期化結果は
`.zshenv` 内の `_zcache` ヘルパーによって `~/.cache/zsh/` にキャッシュ）。

## 日常的な chezmoi の操作

```sh
chezmoi edit ~/.zshrc      # 管理対象ファイルのソースを編集
chezmoi add  ~/.foo        # 新しいファイルを管理対象に追加
chezmoi diff               # apply で何が変わるかを確認
chezmoi apply              # 保留中の変更を適用
chezmoi cd && git ...      # ソースリポジトリを commit / push（autoCommit/Push は無効）
zcache-clear               # キャッシュしたシェル初期化結果を削除
```
