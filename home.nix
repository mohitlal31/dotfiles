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
    ripgrep
    fd
    # fzf
    # eza
    # zoxide
    # lazygit
    # gh
    # git
    # neovim
    # gomplate
    # grpcurl
    # go
    # uv
    # yamllint
    # nodejs_22          # brew: node
    # kubectl            # brew: kubernetes-cli
    # kubernetes-helm    # brew: helm
    # gnumake            # brew: make
    # maven
    # ruby
    # python312          # brew: python@3.12
    # python311          # brew: python@3.11
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
