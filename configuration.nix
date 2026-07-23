# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  flake-inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    flake-inputs.famedly-nixos.nixosModules.default
  ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable nix-ld: https://wiki.nixos.org/wiki/Nix-ld
  programs.nix-ld.enable = true;

  # see https://github.com/famedly/famedly-nixos#cachix
  famedly-cachix.enable = true;
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "burrito"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Enable NetWorkManager
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "startplasma-wayland";
        user = "sepp";
      };
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd startplasma-wayland";
        user = "greeter";
      };
    };
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    elisa
    kdepim-runtime
    krdp
    oxygen
  ];

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD (for HD Graphics starting Broadwell (2014) and newer)
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  # Enable fingerprint scanner
  services.fprintd.enable = true;

  # Misc system services
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      }
    ];
    extraOptions = "--xkb-layout de --xkb-variant nodeadkeys";
  };
  services.pcscd.enable = true;
  services.resolved = {
    enable = true;
    settings.Resolve.DNSSEC = "true";
    settings.Resolve.FallbackDNS = [
      # Quad9
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Enable libvirt daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      vhostUserPackages = with pkgs; [ virtiofsd ];
      swtpm.enable = true; # Enable TPM emulation
    };
  };
  # Enable USB redirection
  virtualisation.spiceUSBRedirection.enable = true;
  # Allowlist default libvirt interface
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  # Enable nested virtualization
  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
    options kvm_intel nested=1
  '';
  programs.virt-manager.enable = true;

  # Enable docker
  virtualisation.docker = {
    enable = true;
    # Talos didn't work with rootless docker
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sepp = {
    isNormalUser = true;
    description = "Sebastian Fleer";
    shell = pkgs.fish;
    extraGroups = [
      "docker"
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install thunderbrd.
  programs.thunderbird.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dnsmasq
    git
    kdePackages.bluedevil
    nano
    neovim
    swtpm
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    liberation_ttf
    nerd-fonts.fira-code
  ];

  programs.fish.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
  };
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  # Dedicated Chrome instance to log into captive portals without messing with DNS settings
  programs.captive-browser = {
    enable = true;
    interface = "wlp0s20f3";
  };

  # see https://wiki.nixos.org/wiki/Appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # see https://github.com/nix-community/nix-index
  programs.nix-index.enable = true;

  # only used for build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 8;
      qemu.options = [
        "-vga none"
        "-device virtio-gpu"
        "-usbdevice tablet"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
