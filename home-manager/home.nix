{ pkgs, ... }:
{
  imports = [
    ./plasma-manager.nix
    ./nixvim.nix
  ];

  # https://nix-community.github.io/home-manager/options.xhtml
  home.username = "sepp";
  home.homeDirectory = "/home/sepp";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      charliermarsh.ruff
      jnoortheen.nix-ide
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-python-envs
      myriad-dreamin.tinymist
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      streetsidesoftware.code-spell-checker-german
      # not available via Nix, yet:
      # opentofu.vscode-opentofu
      # streetsidesoftware.code-spell-checker-medical-terms
      # streetsidesoftware.code-spell-checker-scientific-terms
      # tilt-dev.tiltfile
    ];
  };

  home.packages = with pkgs; [
    chromium
    delta
    dnsutils
    element-desktop
    eza
    fishPlugins.fzf-fish
    fishPlugins.z
    fzf
    hcloud
    htop
    jq
    kdePackages.kate
    kdePackages.okular
    kdePackages.partitionmanager
    kdePackages.plasma-nm
    keepassxc
    kubectl
    kubelogin-oidc
    kubernetes-helm
    nil
    nixfmt
    openpgp-card-tools
    openssl
    opentofu
    p7zip
    pcsc-tools
    ripgrep
    rsync
    talos-pilot
    talosctl
    tilt
    typst
    unzip
    uv
    wayland-utils
    wget
    wireshark
    wl-clipboard
    xz
    yq-go
    zip
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # firefox
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";

      # thunderbird
      "application/x-extension-ics" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";
      "text/calendar" = "thunderbird.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/mid" = "thunderbird.desktop";
      "x-scheme-handler/news" = "thunderbird.desktop";
      "x-scheme-handler/nntp" = "thunderbird.desktop";
      "x-scheme-handler/snews" = "thunderbird.desktop";
      "x-scheme-handler/webcal" = "thunderbird.desktop";
      "x-scheme-handler/webcals" = "thunderbird.desktop";

      # element
      "x-scheme-handler/io.element.desktop" = "io.element.Element.desktop";
      "x-scheme-handler/element" = "io.element.Element.desktop";
    };
  };
}
