{ pkgs, lib, config, ... }:

{
  imports = [
    # ./kde.nix
  ];

  # KDE
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.defaultSession = "plasma";
  # services.displayManager.sddm.wayland.enable = true;

  nic.window-managers = {
    enable = true;
    # niri.enable = true;
    # sway = {
    #   enable = true;
    #   use-swayfx = true;
    # };
    hyprland.enable = true;
    scaling = {
      enable = true;
      factor = 1.5;
    };
    cursor-size = 32;
    wallpaper.enable = true;
    browser = "firefox";
  };
  nic.waybar.enable = true;
  nic.greetd = {
    enable = true;
    auto-login = {
      enable = true;
      user = "nicball";
    };
  };

  programs.ssh.setXAuthLocation = true;

  # Kitty
  nic.kitty.enable = true;

  # Notifications
  nic.dunst.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    fontPackages = with pkgs; [ source-han-sans ];
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Keyboard driver
  nic.hexcore-link.enable = true;

  # kde-connect
  # programs.kdeconnect.enable = true;

  # Input methods
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      addons = with pkgs; [ fcitx5-rime ];
      waylandFrontend = true;
    };
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.extraConfig = {
      disable-headset = {
        "wireplumber.settings"."bluetooth.autoswitch-to-headset-profile" = false;
        "monitor.bluez.properties"."bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
      };
    };
  };
  hardware.bluetooth.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    source-han-sans source-han-serif
    source-code-pro
    font-awesome_5
    mononoki
    julia-mono
  ];
  # Prefer Simplified Chinese Fonts
  fonts.fontconfig.defaultFonts = {
    serif = [ "DejaVu Serif" "Source Han Serif SC" ];
    sansSerif = [ "DejaVu Sans" "Source Han Sans SC" ];
    monospace = [ "Monaco" "DejaVu Sans Mono" "Source Han Sans SC" ];
  };
  # Monaco
  # fonts.fontconfig.localConf = ''
  #   <?xml version="1.0"?>
  #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #   <fontconfig>
  #     <match target="scan">
  #       <test name="family">
  #         <string>Monaco</string>
  #       </test>
  #       <edit name="spacing">
  #         <int>90</int>
  #       </edit>
  #     </match>
  #   </fontconfig>
  # '';

  # misc programs
  environment.systemPackages = with pkgs; [
    # GUI stuff

    # Utility
    # zen-browser
    firefox
    wl-clipboard
    google-chrome
    localsend

    # Social
    telegram-desktop
    element-desktop
    qq

    # Multimedia
    mpv obs-studio # tigervnc
    # yesplaymusic
    foliate

    # Document
    # libreoffice # calibre

    # Game
    uudeck prismlauncher umu-launcher # lutris gamescope openttd minecraft fabric-installer
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  services.gnome.gnome-keyring.enable = true;

}
