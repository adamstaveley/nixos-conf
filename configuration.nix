# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adam = {
    isNormalUser = true;
    description = "adam";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    
    # nix-env -qaP <package>
    # nix search nixpkg <package>
    packages = with pkgs; [
      firefox
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     curl
     git
  ];

  # Fonts
  # https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
    jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;

  # note: need to set proton version <= 5.0
  # https://github.com/NixOS/nixpkgs/issues/130699
  programs.steam.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Configure home manager
  home-manager.users.adam = {
    home.stateVersion = "22.11";
    programs.git = {
      enable = true;
      userName = "";
      userEmail = "";
      aliases = {
        st = "status";
      };
    };
    programs.zsh = {
      enable = true;
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -l";
        nixmod = "sudo vi /etc/nixos/configuration.nix";
        nixup = "sudo nixos-rebuild switch";
        nix-shell = "nix-shell --run zsh";
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "dracula/zsh"; tags = [ as:theme ]; }
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-history-substring-search"; }
        ];
      };
      initExtra = ''
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

        if [[ -n "$IN_NIX_SHELL" ]]; then
          export PS1="$PS1(nix-shell) "
        fi
      '';
    };
    programs.terminator = {
      enable = true;
      config = {
        # https://nix-community.github.io/home-manager/options.html#opt-programs.terminator.config
        global_config.title_hide_sizetext = true;
        profiles.default.background_color = "#282828";
        profiles.default.cursor_color = "#aaaaaa";
        profiles.default.font = "JetBrains Mono 10";
        profiles.default.foreground_color = "#ebdbb2";
        profiles.default.show_titlebar = false;
        profiles.default.scrollbar_position = "hidden";
        profiles.default.scroll_on_keystroke = true;
        profiles.default.scroll_on_output = true;
        profiles.default.scrollback_lines = 2000;
        profiles.default.pallet = "#282828:#cc241d:#98971a:#d79921:#458588:#b16286:#689d6a:#a89984:#928374:#fb4934:#b8bb26:#fabd2f:#83a598:#d3869b:#8ec07c:#ebdbb2";
        profiles.default.use_system_font = false;
        layouts.default.window0.type = "Window";
        layouts.default.window0.parent = "";
        layouts.default.window0.size = "900, 600";
        layouts.default.child1.type = "Terminal";
        layouts.default.child1.parent = "window0";
        layouts.default.child1.profile = "default";
      };
    };
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        golang.go
        github.github-vscode-theme
      ];
      userSettings = {
        "workbench.colorTheme" = "GitHub Light";
        "window.menuBarVisibility" = "hidden";
        "files.autoSave" = "afterDelay";
        "editor.rulers" = [ 80 120 ];
        "extensions.ignoreRecommendations" = true;
        "editor.minimap.enabled" = false;
        # fails to find JetBrains Mono
        "editor.fontFamily" = "'JetBrains Mono', monospace";
        "editor.fontSize" = 13;
        "terminal.integrated.fontSize" = 13;
        "terminal.integrated.defaultProfile.linux" = "zsh";
      };
    }; 
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
