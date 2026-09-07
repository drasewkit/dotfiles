# chezmoi 入門 — この dotfiles の仕組み

このリポジトリの dotfiles 管理は **chezmoi** で行っている。
GitHub の `drasewkit/dotfiles` は chezmoi の「ソース」を git で持っているだけで、
実際に `~/.zshrc` などを生成・更新するのは `chezmoi apply` コマンド。

---

## 1. 3つの場所を区別する

| 名前 | このマシンでの場所 | 役割 |
|---|---|---|
| **source（ソース）** | `~/src/github.com/drasewkit/dotfiles` | 設定の「正」。git 管理。`dot_zshrc` のような加工名で保存 |
| **chezmoi 自身の設定 + 状態** | `~/.config/chezmoi/` | `chezmoi.toml`（source の場所など）と `chezmoistate.boltdb`（run_once 実行済みか等の記録） |
| **target（ターゲット）** | `~/`（ホーム） | 実際に使われるファイル。`~/.zshrc` など。**ここを直接編集してもいいが、正は source 側** |

`chezmoi.toml` は **git 管理しない**（マシン固有・`.chezmoi.toml.tmpl` から生成）。

```
source                              target
dot_gitconfig                 -->   ~/.gitconfig
private_dot_config/zsh/dot_zshrc -->  ~/.config/zsh/.zshrc
```

確認コマンド:
```sh
chezmoi source-path ~/.gitconfig   # この target の source ファイルはどれ？
chezmoi target-path <sourcefile>   # 逆引き
chezmoi managed                    # 管理下の target 一覧
chezmoi ignored                    # .chezmoiignore で除外されている target
```

---

## 2. ソースファイルの命名規則

chezmoi は **ファイル名の接頭辞・接尾辞** で属性を表す（メタデータファイルを持たない設計）。

| ソース名 | 生成される target | 意味 |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | `dot_` → 先頭の `.` |
| `private_dot_config/` | `~/.config/`（パーミッション 700） | `private_` → group/other に権限を与えない |
| `dot_config/foo.toml.tmpl` | `~/.config/foo.toml` | `.tmpl` → Go テンプレートとして展開してから配置 |
| `run_once_before_00-x.sh.tmpl` | （配置されない） | 起動スクリプト（後述） |
| `modify_settings.json.tmpl` | `~/.claude/settings.json` | 既存ファイルを**加工**する（全置換しない・後述） |
| `symlink_foo` | `~/foo`（シンボリックリンク） | このリポジトリでは未使用 |
| `.chezmoi*` | （chezmoi 自身が使う特殊ファイル） | `.chezmoiignore` `.chezmoi.toml.tmpl` など |

接頭辞は重ねられる: `private_dot_config/private_karabiner/private_karabiner.json`
→ `~/.config/karabiner/karabiner.json`（`~/.config` と `karabiner` が 700）。

> **なぜこのリポジトリは `private_dot_config` だらけなのか**
> このマシンの `~/.config` がパーミッション 700 だったため、`chezmoi add` 時に
> chezmoi が忠実に `private_` を付けた。新マシンでも `~/.config` は 700 で作られる。実害なし。

---

## 3. 毎日の操作（コアループ）

### A. 既存の管理下ファイルを変更する

```sh
chezmoi edit ~/.zshrc        # source を $EDITOR で開く（nvim）
chezmoi apply                # target へ反映
```
`chezmoi edit --apply ~/.zshrc` で保存時に自動 apply。

または target を直接いじってから吸い上げる:
```sh
nvim ~/.zshrc
chezmoi re-add               # 管理下ファイルの target 側変更を source に取り込む
```

### B. 変更内容を確認する

```sh
chezmoi diff                 # apply したら何が変わるか（source → target 方向）
chezmoi status               # 変更のあるファイル一覧（M/A/D と再実行予定スクリプト R）
chezmoi verify               # source と target が完全一致なら exit 0（差分ゼロ）
```

### C. 新しい dotfile を管理下に入れる

```sh
chezmoi add ~/.config/newapp/config.toml           # そのまま取り込む
chezmoi add --template ~/.config/newapp/config.toml # 絶対パス等をテンプレート化したい場合
```
→ source に `private_dot_config/newapp/config.toml` ができる。

**取り込む前の判断**（`.chezmoiignore` の方針）:

| 種類 | どうするか |
|---|---|
| 秘密（token / 鍵 / `.env`） | `.chezmoiignore` に追加。実体はパスワードマネージャや手動再生成 |
| work 固有・マシン固有 | `~/.config/local/*.zsh` 等の gitignore された local ファイルへ |
| `/Users/tkdisk/...` を含む | `--template` で追加し `{{ .chezmoi.homeDir }}` に置換 |
| 普通の可搬設定 | そのまま `chezmoi add` |

### D. コミット & push（このリポジトリでは手動）

`~/.config/chezmoi/chezmoi.toml` で `autoCommit = false` / `autoPush = false` にしている
（公開前提で、コミット前に中身を目視したいため）。

```sh
chezmoi cd                   # = cd ~/src/github.com/drasewkit/dotfiles（サブシェル）
git add -A
git diff --cached            # ★秘密・work パスの混入チェック（毎回）
git commit -m "..."
git push
exit                         # サブシェルを抜ける
```

### E. 管理をやめる

```sh
chezmoi forget ~/.config/foo   # source から外す（target の実ファイルは残す）
chezmoi destroy ~/.config/foo  # source・target 両方削除（要注意）
```

---

## 4. テンプレート（`.tmpl`）

`.tmpl` が付いたソースは Go の `text/template`（+ Sprig 関数）で展開してから配置される。

よく使う変数・関数:
```
{{ .chezmoi.homeDir }}       /Users/tkdisk
{{ .chezmoi.os }}            darwin
{{ .chezmoi.hostname }}      ホスト名
{{ .chezmoi.sourceDir }}     ~/src/github.com/drasewkit/dotfiles
{{ if eq .chezmoi.os "darwin" }} ... {{ end }}
{{ .email }}                 chezmoi.toml の [data] で定義した独自変数（このリポジトリは未使用）
```

テンプレートの展開結果を確認:
```sh
chezmoi execute-template < some_file.tmpl
chezmoi cat ~/.claude/settings.json    # この target の最終形を表示
```

### `modify_` スクリプト（このリポジトリの `~/.claude/settings.json`）

普通のテンプレートは target を**全置換**する。だが `~/.claude/settings.json` は

- **可搬な部分**（theme, effortLevel など）→ このリポジトリで管理したい
- **`autoMode`**（work 用の auto-mode 分類ルール・機密）→ Claude Code が
  `/permissions` 編集時にこのファイルへ書き込む。リポジトリには絶対入れたくない

という2種類が同居している。そこで `modify_settings.json.tmpl` を使う。

`modify_` スクリプトは「**現在の target の中身を標準入力で受け取り、新しい中身を標準出力に書く**」。
中身は `jq` で「可搬キーだけを既存 JSON にマージ」しているので、`autoMode` や
Claude Code が足したものはそのまま温存される。

```sh
# 挙動確認
chezmoi cat ~/.claude/settings.json | jq 'keys'
```

---

## 5. スクリプト（`run_` 系）

`chezmoi apply` の途中で任意のスクリプトを実行できる。ソース名で実行タイミングが決まる。

| 接頭辞 | 実行タイミング |
|---|---|
| `run_` | 毎回の apply |
| `run_once_` | 内容の hash ごとに一度だけ（`chezmoistate.boltdb` が記録） |
| `run_onchange_` | 内容が前回と変わったときだけ |
| `..._before_` / `..._after_` | ファイル配置の前 / 後 |

数字プレフィックス（`00-`, `20-`）で順序を制御する（アルファベット順）。

このリポジトリのスクリプト:

| ファイル | 役割 |
|---|---|
| `run_once_before_00-install-homebrew.sh.tmpl` | Homebrew 未導入なら入れる |
| `run_onchange_before_20-brew-bundle.sh.tmpl` | `Brewfile` が変わったら `brew bundle` |

`run_onchange` の「変わった」判定は**スクリプト本文の hash**。だから Brewfile の中身を
スクリプトにコメントとして埋め込んでいる:

```sh
# Brewfile hash: {{ include "Brewfile" | sha256sum }}
```
`Brewfile` を編集 → hash 行が変わる → 次の `chezmoi apply` で `brew bundle` 再実行。

> **パッケージを増やすとき**
> `brew install foo` した後、`Brewfile` に `brew "foo"` を1行足すだけ。
> `Brewfile` は `.chezmoiignore` に入れてある（`~/Brewfile` として配置はされない）が、
> `{{ include "Brewfile" }}` はソースから読めるので問題ない。

---

## 6. このリポジトリ固有の決定事項

| 決定 | 内容 |
|---|---|
| **source の場所** | 標準の `~/.local/share/chezmoi` ではなく ghq パス `~/src/github.com/drasewkit/dotfiles`。他の repo と揃い `Ctrl-]` で飛べる。`chezmoi.toml` の `sourceDir` で指定 |
| **autoCommit / autoPush** | off。コミット前に目視スキャンしたいため |
| **`~/.claude/settings.json`** | `modify_` スクリプトで可搬キーのみマージ。`autoMode` は触らない |
| **`~/.claude/settings.local.json`** | `.chezmoiignore`。Claude Code が「always allow」を書き込む先。個人的な WebFetch 許可ドメインなどが入る |
| **`~/.gitconfig` の `~/work/src`** | そのまま管理（work の内容ではなくパス文字列のみ・機密ではない） |
| **nb の rumdl フォーマッタ hook** | テンプレート化を断念（シェルのクオートが壊れやすい）。新マシンでは README の JSON を手で `~/.claude/settings.json` に追記 |
| **`.nbrc` / `.nuxtrc` / `.yarnrc`** | 管理しない（ツールが自動生成・書き換えるため） |

---

## 7. 新しいマシンでの復元

```sh
# 0. SSH 鍵を新規生成して GitHub に登録（README「SSH key」参照）
# 1. bootstrap（手動 clone 経由を推奨。private repo なので）
git clone git@github.com:drasewkit/dotfiles.git ~/src/github.com/drasewkit/dotfiles
sh ~/src/github.com/drasewkit/dotfiles/bootstrap.sh
```

`bootstrap.sh` の流れ: Xcode CLT → Homebrew → chezmoi → clone → `chezmoi init --apply`。
`chezmoi init` が `.chezmoi.toml.tmpl` から `~/.config/chezmoi/chezmoi.toml` を生成し、
`chezmoi apply` が run スクリプト実行 + 全ファイル配置を行う。

その後の手動作業（README「Manual follow-ups」）:
- シェル再起動、Karabiner の Input Monitoring 許可
- `claude` / `gh auth login` / Slack 等サインイン
- work repo 用の auto-mode ルールを `/permissions` で再登録
- nb hook を `~/.claude/settings.json` に手で追記

---

## 8. 複数マシン間の同期（将来）

```sh
chezmoi update     # git pull + chezmoi apply を一括実行
chezmoi git pull   # pull だけ
chezmoi re-add     # このマシンでの target 変更を source に取り込む
```

複数マシンで同時にいじると source repo がコンフリクトしうるので、
基本は「1マシンで編集 → commit/push → 他マシンで `chezmoi update`」。

---

## 9. よくあるハマりどころ

- **`chezmoi apply` しても反映されない** → そのファイルが `.chezmoiignore` に入っていないか（`chezmoi ignored`）
- **`config file template has changed` 警告** → `.chezmoi.toml.tmpl` を変えたら `chezmoi init` で `chezmoi.toml` を再生成
- **target を直接編集して `chezmoi apply` したら戻された** → source が正。`chezmoi re-add` で取り込むか `chezmoi edit` で source を直す
- **`run_once` をもう一度走らせたい** → `chezmoi state delete-bucket --bucket=scriptState`（全部）、または内容を1文字変える
- **テンプレートのシンタックスエラー** → `chezmoi execute-template < file.tmpl` で切り分け
- **`jq` が無くて `modify_` が失敗** → Brewfile が jq を入れる。bootstrap は brew を先に走らせる順序にしてある

---

## 10. 公式ドキュメント

- User guide: <https://www.chezmoi.io/user-guide/command-overview/>
- Reference（命名規則・テンプレート関数）: <https://www.chezmoi.io/reference/>
- `chezmoi help <command>` / `chezmoi <command> --help`
