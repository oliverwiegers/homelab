{...}: {
  home = {
    file = {
      "hyprland.conf" = {
        source = ./hyprland.conf;
        target = ".config/hypr/hyprland.conf";
      };
      "german-keymap-fixes" = {
        target = ".xkb/symbols/german-keymap-fixes";
        text = ''
          default partial alphanumeric_keys
          xkb_symbols "basic" {
              include "us(altgr-intl)"
              name[Group1] = "English (US, international with German umlaut)";
              key <AD03> { [ e, E, EuroSign, cent ] };
              key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
              key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
              key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
              key <AC02> { [ s, S, ssharp ] };
              key <LSGT> { [grave, asciitilde, grave, asciitilde ] };

              key <LWIN> { [ISO_Level3_Shift ] };
              modifier_map Mod5 { ISO_Level3_Shift };
          };
        '';
      };
    };
  };

  xdg = {
  };

  programs = {
    zsh = {
      loginExtra = "Hyprland";
    };
  };

  # TODO: Use flake or home-manager module when ready.
  # wayland = {
  #   windowManager = {
  #     hyprland = {
  #       enable = true;
  #       extraConfig = (builtins.readFile ./hyprland.conf);

  #       systemd = {
  #         enable = true;
  #       };
  #     };
  #   };
  # };
}
