# dotfiles

macOS setup managed with **[nix-darwin](https://github.com/nix-darwin/nix-darwin)** +
**[home-manager](https://github.com/nix-community/home-manager)**. One repo, one
command, and a fresh Mac ends up configured the same way every time — while your
actual config files (nvim, tmux, wezterm, zsh) stay editable in place.

## Layout

```
flake.nix           # entry point: pins nixpkgs/nix-darwin/home-manager, sets `user`
configuration.nix   # system: macOS defaults + declarative Homebrew (all your brews/casks)
home.nix            # you: Nix CLI packages (opt-in) + dotfile symlinks
home/               # the REAL dotfiles — edited in place, symlinked into ~ by home-manager
  .zshrc  .zprofile  .p10k.zsh  .tmux.conf
  .config/nvim/  .config/wezterm/  .config/tmux/gruvbox-theme.conf
bootstrap.sh        # one-time first install
rebuild.sh          # reapply after any change
```

`home.nix` uses `mkOutOfStoreSymlink` to point `~/.config/nvim` (etc.) straight
at `home/.config/nvim` in this repo — so editing a file here changes your live
config instantly, no rebuild needed. Rebuilds are only for changing **what is
installed** (Nix packages, brews, casks, macOS defaults).

## First-time setup

```sh
git clone https://github.com/mohitlal31/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Determinate Nix, links this repo to `~/.dotfiles`, and
runs the first build. Your existing `~/.zshrc` / `~/.zprofile` / `~/.tmux.conf`
Stow symlinks and your `~/.p10k.zsh` are **backed up to `<name>.before-nix`**,
not deleted. Open a new terminal afterwards and check your shell/editor.

## Daily use

Edit a `.nix` file, then:

```sh
./rebuild.sh
```

Roll back a bad build: `sudo darwin-rebuild --rollback`.

## Homebrew — nothing is deleted (yet)

`configuration.nix` declares **every** formula and cask you currently have, with
`onActivation.cleanup = "none"`, so a rebuild never uninstalls anything. Once
you're confident every package you care about is listed, flip that to `"zap"`
for a fully reproducible machine (it will then remove anything *not* listed).

## Porting a tool from Homebrew to Nix (one at a time)

1. Uncomment/add the tool in `home.nix` `home.packages` (some nixpkgs names
   differ from brew — noted in comments there).
2. `./rebuild.sh`
3. Confirm it works in a new shell.
4. Delete its line from `configuration.nix` `brews`, then `brew uninstall <tool>`.

## Adopting on a second Mac

Change the single `user = "..."` line in `flake.nix` to that machine's username
(`bootstrap.sh` refuses to build until it matches `whoami`), then run
`./bootstrap.sh`.

## Rollback to the old Stow setup

Everything above lives on the `nix-migration` branch. Your previous Stow-based
setup is untouched on `main`: `git checkout main` and re-run `stow` if you ever
want to walk it back.
