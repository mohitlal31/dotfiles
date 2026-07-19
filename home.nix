{ config, pkgs, user, ... }:

let
  # bootstrap.sh symlinks this repo to ~/.dotfiles. mkOutOfStoreSymlink points
  # the live config back at the repo working tree, so you can edit files in
  # place and have changes apply immediately — exactly like Stow did, no
  # rebuild required for edits.
  dotfiles = "${config.home.homeDirectory}/.dotfiles/home";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.05";

  # ── CLI tools from Nix ─────────────────────────────────────────────────
  # Starts empty ON PURPOSE. Port tools off Homebrew one at a time:
  #   1. uncomment (or add) the tool below
  #   2. ./rebuild.sh
  #   3. confirm it works from a new shell
  #   4. remove it from configuration.nix `brews`, then `brew uninstall <tool>`
  # A few nixpkgs names differ from brew — noted in comments.
  home.packages = with pkgs; [
    # ── ported off Homebrew ──
    ripgrep
    fd
    fzf
    eza
    zoxide
    lazygit
    gh
    neovim
    gomplate
    grpcurl
    yamllint

    # zsh prompt + plugins (sourced by ~/.zshrc from the per-user profile)
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting

    # ── still on Homebrew ── uncomment to port, then delete from
    # configuration.nix `brews` and `brew uninstall`. Left on brew on purpose:
    # git      → keep for the osxkeychain credential helper
    # go / nodejs_22 / ruby / python311 / python312 / maven → runtimes, often
    #            pinned per-project via asdf/jenv/pyenv
    # kubectl (kubernetes-cli) / kubernetes-helm (helm) → cluster-version tied
    # gnumake (make) / uv → leave for now
  ];

  # ── Dotfiles (symlinked in place — same behavior as your old Stow setup) ─
  home.file.".zshrc".source = link ".zshrc";
  home.file.".zprofile".source = link ".zprofile";
  home.file.".p10k.zsh".source = link ".p10k.zsh";
  home.file.".tmux.conf".source = link ".tmux.conf";
  home.file.".config/nvim".source = link ".config/nvim";
  home.file.".config/wezterm".source = link ".config/wezterm";

  # tmux's plugin manager (tpm) writes into ~/.config/tmux/plugins, so only the
  # theme *file* is linked — the ~/.config/tmux directory itself stays real.
  home.file.".config/tmux/gruvbox-theme.conf".source =
    link ".config/tmux/gruvbox-theme.conf";
}
