# dotfiles

Personal macOS dotfiles, managed with [chezmoi](https://chezmoi.io).
No secrets live here (see [What's *not* here](#whats-not-here)).

New to chezmoi / this setup? Read [`docs/chezmoi.md`](docs/chezmoi.md).

- **Source dir:** `~/src/github.com/drasewkit/dotfiles` (ghq layout, reachable via `Ctrl-]`)
- **chezmoi config:** `~/.config/chezmoi/chezmoi.toml` — generated from [`.chezmoi.toml.tmpl`](.chezmoi.toml.tmpl), never committed
- **Shell:** zsh under `~/.config/zsh` (`ZDOTDIR`), plugins via sheldon, prompt via starship — see [shell notes](#shell)

## New machine

Do the SSH step first, then run the bootstrap.

### 1. SSH key (regenerated per machine — D5)

Keys are **never** stored in this repo. On the new Mac:

```sh
ssh-keygen -t ed25519 -C "d.takaku49@gmail.com"
pbcopy < ~/.ssh/id_ed25519.pub          # paste at github.com/settings/keys
ssh -T git@github.com                    # should greet you as "drasewkit"
```

`gh auth login` (after Homebrew) sets the same key up for `gh` and switches git to SSH.

### 2. Bootstrap

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/drasewkit/dotfiles/main/bootstrap.sh)"
```

Or clone first and run it from the tree:

```sh
git clone git@github.com:drasewkit/dotfiles.git ~/src/github.com/drasewkit/dotfiles
sh ~/src/github.com/drasewkit/dotfiles/bootstrap.sh
```

[`bootstrap.sh`](bootstrap.sh) installs Xcode CLT → Homebrew → chezmoi, clones here, and runs
`chezmoi init --apply`. On apply, chezmoi runs the scripts below and writes all managed files.

### 3. Manual follow-ups

- Restart the shell for zsh / starship / sheldon.
- Karabiner-Elements: grant Input Monitoring.
- Sign in: `claude`, `gh auth login`, Slack, ChatGPT, Spotify, …
- Claude Code auto-mode rules for certain repos: re-add via `/permissions` (see [Claude Code](#claude-code)).

## What chezmoi manages

| Area | Target |
|---|---|
| zsh | `~/.config/zsh/{.zshenv,.zprofile,.zshrc,rc/**}` |
| prompt / plugins | `~/.config/{starship.toml,sheldon/plugins.toml,zeno/config.yml}` |
| editor | `~/.config/nvim/**` (LazyVim base, `lazy-lock.json` pinned) |
| terminal | `~/.config/wezterm/wezterm.lua` |
| keyboard | `~/.config/karabiner/{karabiner.json,assets/**}` |
| git | `~/.gitconfig`, `~/.config/git/ignore` |
| GitHub CLI | `~/.config/gh/config.yml` |
| Claude Code | `~/.claude/settings.json` (portable keys only — see below) |
| packages | [`Brewfile`](Brewfile) via `run_onchange_before_20-brew-bundle.sh.tmpl` |

### Scripts (run on `chezmoi apply`)

- `run_once_before_00-install-homebrew.sh.tmpl` — installs Homebrew if missing.
- `run_onchange_before_20-brew-bundle.sh.tmpl` — `brew bundle` when the Brewfile changes.
  Regenerate the baseline with `brew bundle dump --file=- --force`, then re-add the
  hand-kept CLI tools listed under `# ── CLI` (they aren't "installed on request").

## What's *not* here

`.chezmoiignore` keeps these out; they're recreated per machine:

- **Secrets:** `~/.ssh`, `~/.gnupg`, `~/.config/gh/hosts.yml`, `~/.config/bitbucket/**`, `~/.netrc`, `~/.claude.json`
- **Machine-/env-local:** `~/.config/local/**`, `~/.claude/settings.local.json`
- **Auto-generated:** karabiner `automatic_backups/`, zsh history & compdump, caches
- **Tool-managed rc files:** `~/.nbrc` (nb rewrites it), `~/.nuxtrc`, `~/.yarnrc`

## Claude Code

`~/.claude/settings.json` holds two kinds of content, so it is managed by
**`dot_claude/modify_settings.json.tmpl`** — a `jq` merge, not a full-file template:

- **Portable** (merged in by chezmoi): `theme`, `effortLevel`, notification toggles,
  the figma plugin, and the `nb` `additionalDirectory`.
- **Local / confidential** (left untouched): `autoMode` — the auto-mode classifier
  rules and environment for certain repos. Claude Code reads `autoMode` **only** from
  `settings.json` (not `settings.local.json`), and rewrites it in place when you edit
  rules via `/permissions`. It never enters this repo. Re-create it on a new machine
  through `/permissions` → *Auto mode*.

### nb markdown formatter hook (not templated)

The `PostToolUse` hook that runs `rumdl fmt` on `*.md` under the `nb` repo is **not**
in the template (its shell quoting is too fragile to round-trip). Re-add it to
`~/.claude/settings.json` by hand on a new machine:

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

## Shell

prezto was removed; layout is `~/.config/zsh/rc/` split files + sheldon
(`zeno`, `fast-syntax-highlighting`, `zsh-autosuggestions`, `zsh-completions`).
History search is prefix-match on `↑`/`↓`; fuzzy history is `Ctrl-r` (zeno).
Startup ≈ 75 ms (nvm lazy-loaded, `brew`/`sheldon`/`starship` init cached under
`~/.cache/zsh/` by the `_zcache` helper in `.zshenv`).

## Everyday chezmoi

```sh
chezmoi edit ~/.zshrc      # edit the source of a managed file
chezmoi add  ~/.foo        # start managing a new file
chezmoi diff               # what apply would change
chezmoi apply              # apply pending changes
chezmoi cd && git ...      # commit / push the source repo (autoCommit/Push are off)
zcache-clear               # drop the cached shell-init blobs
```
