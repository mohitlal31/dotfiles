{ pkgs, user, ... }:

{
  # Determinate Nix manages the Nix daemon, so nix-darwin must not.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # Apple Silicon

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";
  system.stateVersion = 6;

  # Let nix-darwin own /etc/zshrc so Nix + your per-user profile land on PATH
  # for every zsh session. Your own ~/.zshrc (symlinked by home-manager) is
  # left alone and still sourced afterwards.
  programs.zsh.enable = true;

  # The per-user profile only links a subset of share/ by default (man, zsh,
  # terminfo, …). zsh-syntax-highlighting installs to share/zsh-syntax-highlighting,
  # which isn't in that set, so link it explicitly. (p10k + zsh-autosuggestions
  # live under share/zsh, already linked.)
  environment.pathsToLink = [ "/share/zsh-syntax-highlighting" ];

  # ── macOS system defaults ──────────────────────────────────────────────
  # Deliberately conservative: only two harmless ones are active. Uncomment
  # anything you want Nix to enforce, then `./rebuild.sh`.
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true; # always show file extensions
      KeyRepeat = 2;                 # fast key repeat
      InitialKeyRepeat = 15;         # short delay before repeat starts
      # AppleInterfaceStyle = "Dark";
      # _HIHideMenuBar = true;       # auto-hide the menu bar
    };
    # dock.autohide = true;
    # finder.FXPreferredViewStyle = "Nlsv";   # list view
    # finder.CreateDesktop = false;           # hide desktop icons
    # trackpad.Clicking = true;               # tap to click
  };

  # ── Homebrew ───────────────────────────────────────────────────────────
  # Manages packages through your EXISTING /opt/homebrew (no nix-homebrew, so
  # nothing takes ownership of your brew install). Everything currently
  # installed is listed so a fresh Mac restores it exactly.
  homebrew = {
    enable = true;

    # "none" = NEVER uninstall anything that isn't listed here. This is the
    # safe setting while you migrate. Once every brew/cask you care about is
    # in the lists below, you can switch this to "zap" for a fully
    # reproducible machine. Leave it as "none" for now.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = false; # keep rebuilds fast + predictable
    onActivation.upgrade = false;

    # CLI formulae. Migrate these to home.nix `home.packages` one at a time;
    # when a tool works from Nix, delete its line here and `brew uninstall` it.
    brews = [
      "asdf"
      "aws-sso-util"
      "awscli"
      "git"
      "go"
      "helm"
      "herdr"
      "hunk"
      "jenv"
      "kubernetes-cli"
      "make"
      "maven"
      # `mysql` (full server) conflicts with the linked `mysql-client@8.4` over
      # /opt/homebrew/bin/comp_err. You use the client for the CLI, so keep the
      # server installed-but-unlinked (its current state) via link = false.
      { name = "mysql"; link = false; }
      "mysql-client@8.4"
      "mysql@8.4"
      "node"
      "pyenv-virtualenv"
      "python@3.11"
      "python@3.12"
      "ruby"
      "stow"
      "tfmigrate"
      "tmux"
      "uv"
    ];

    # GUI apps + fonts. These stay on Homebrew (Nix doesn't manage macOS .app
    # bundles as cleanly); just declared here so they're reproducible.
    casks = [
      "1password"
      # amazon-q was renamed to kiro-cli by Homebrew (listed below).
      "bruno"
      "claude"
      "claude-code"
      "coteditor"
      "firefox"
      "font-jetbrains-mono-nerd-font"
      "intellij-idea-ce"
      "karabiner-elements"
      "kiro-cli"
      "linearmouse"
      "obsidian"
      "podman-desktop"
      "raycast"
      "session-manager-plugin"
      "shottr"
      "spotify"
      "temurin@21"
      "temurin@8"
      "visual-studio-code"
      "wezterm"
      "zoom"
    ];
  };
}
