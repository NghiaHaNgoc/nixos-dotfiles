{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Options
  nixpkgs.config.allowUnfree = true;
  system.defaultChannel = "https://nixos.org/channels/nixos-unstable";
  documentation.nixos.enable = false;
  hardware.bluetooth.enable = true;

  # Use the systemd-boot boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" ];
    consoleLogLevel = 0;
    initrd = {
      includeDefaultModules = false;
      systemd.enable = true;
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 1;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      dns = "none";
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ bamboo ];
    };
  };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverridePackages = with pkgs; [ gnome.mutter ];
        extraGSettingsOverrides = ''
          [org.gnome.mutter]
          dynamic-workspaces = true
          edge-tiling = true
          [org.gnome.desktop.wm.preferences]
          button-layout = 'appmenu:minimize,maximize,close'
        '';
      };
      excludePackages = with pkgs; [ xterm ];
    };
    gnome.core-utilities.enable = false;
  };

  # Setup environment
  environment = {
    sessionVariables = {
      # Vscodium extensions
      VSCODE_GALLERY_SERVICE_URL =
        "https://marketplace.visualstudio.com/_apis/public/gallery";
      VSCODE_GALLERY_ITEM_URL = "https://marketplace.visualstudio.com/items";
      VSCODE_GALLERY_CACHE_URL =
        "https://vscode.blob.core.windows.net/gallery/index";
      VSCODE_GALLERY_CONTROL_URL = "";

      # Nautilus extensions
      NAUTILUS_4_EXTENSION_DIR =
        # path for system
        # "${config.system.path}/lib/nautilus/extensions-4";
        # path for user
        "/etc/profiles/per-user/$USER/lib/nautilus/extensions-4";
    };

    # List packages installed in system profile.
    systemPackages = with pkgs; [ ];
    defaultPackages = [ ];
    gnome.excludePackages = with pkgs; [ gnome-tour gnome.gnome-backgrounds ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nghiaha = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      chromium
      google-chrome
      brave
      starship
      wezterm
      ripgrep
      joshuto
      wl-clipboard
      (cava.override { withPipewire = false; })
      # Development
      vscodium
      gcc
      rustup
      lua-language-server
      vscode-langservers-extracted
      nodePackages.nodejs
      nodePackages.volar
      nodePackages.typescript-language-server
      # Gnome packages
      baobab
      loupe
      amberol
      gnome.gnome-system-monitor
      gnome.totem
      gnome.file-roller
      gnome.nautilus
      gnome.nautilus-python
      gnomeExtensions.pano
      gnomeExtensions.blur-my-shell
    ];
  };

  # Enable programs 
  programs = {
    fish.enable = true;
    git.enable = true;
    nano.enable = false;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  # Font packages
  fonts.packages = with pkgs; [
    noto-fonts
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    maple-mono-otf
  ];

  # Gnome gdm backgrounds
  nixpkgs.overlays = [
    (self: super: {
      gnome = super.gnome.overrideScope (selfg: superg: {
        gnome-shell = superg.gnome-shell.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (self.fetchpatch {
              url =
                "https://raw.githubusercontent.com/NghiaHaNgoc/nixos-dotfiles/main/gdm/gdm.patch";
              hash = "sha256-hYgNk048kbel2vWb87V3ejt34QFnZnwmTF5ufMqJzBg=";
            })
          ];
        });
      });
    })
  ];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11";

}
