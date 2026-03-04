{
  lib,
  pkgs,
  perSystem,
  config,
  ...
}:
let
  cfg = config.graphical.browser.firefox;
  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  defaultPlugins = with perSystem.firefox-addons; [
    vimium
    browserpass
    i-dont-care-about-cookies
    privacy-badger
    ublock-origin
  ];

  hackstationPlugins = with perSystem.firefox-addons; [
    foxyproxy-standard
    hacktools
  ];
in
{
  options.graphical.browser.firefox = {
    enable = lib.mkEnableOption "Enable Firefox browser.";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      inherit (cfg) package;
      profiles = {
        default = {
          id = 0;
          isDefault = true;
          settings = {
            # TODO: Add nix-colors
            #"devtools.theme" = "";
            "browser.fullscreen.autohide" = false;
            "privacy.donottrackheader.enabled" = true;
            "privacy.donottrackheader.value" = 1;
            "privacy.firstparty.isolate" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "ui.key.menuAccessKeyFocuses" = false;
            "ui.key.menuAccessKey" = 17;
          };

          extensions.packages =
            if config.hackstation.enable then defaultPlugins ++ hackstationPlugins else defaultPlugins;

          search = {
            default = "ddg";
            force = true;

            engines = {
              "bing".metaData.hidden = true;
              "Amazon.de".metaData.hidden = true;

              "google".metaData.alias = "@g";
              "ddg".metaData.alias = "@d";
              "wikipedia".metaData.alias = "@w";

              "Github" = {
                definedAliases = [ "@gh" ];
                icon = "https://github.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day

                urls = [
                  {
                    template = "https://github.com/search?q={searchTerms}";
                  }
                ];
              };

              "Github Netlogix Devops" = {
                definedAliases = [ "@ghn" ];
                icon = "https://github.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day

                urls = [
                  {
                    template = "https://github.com/search?q=org:netlogix-devops+{searchTerms}";
                    params = [
                      {
                        name = "type";
                        value = "repositories";
                      }
                    ];
                  }
                ];
              };

              "Nix Packages" = {
                definedAliases = [ "@np" ];
                icon = "${nixIcon}";

                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "Nix Manual" = {
                definedAliases = [ "@nw" ];
                icon = "${nixIcon}";

                urls = [
                  {
                    template = "https://nixos.org/manual/nix/stable/introduction?search={searchTerms}";
                  }
                ];
              };

              "NixOS Options" = {
                icon = "${nixIcon}";
                definedAliases = [ "@no" ];

                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "type";
                        value = "options";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "NixOS Wiki" = {
                definedAliases = [ "@nw" ];
                icon = "${nixIcon}";

                urls = [
                  {
                    template = "https://nixos.wiki/index.php?search={searchTerms}";
                  }
                ];
              };

              "Home Manager Options" = {
                definedAliases = [ "@ho" ];
                icon = "${nixIcon}";

                urls = [
                  {
                    template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
                  }
                ];
              };

              "Noogle" = {
                definedAliases = [ "@ng" ];
                icon = "${nixIcon}";

                urls = [
                  {
                    template = "https://noogle.dev/q?term={searchTerms}";
                  }
                ];
              };

              "Marginalia" = {
                definedAliases = [ "@m" ];
                icon = "https://marginalia-search.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day

                urls = [
                  {
                    template = "https://marginalia-search.com/search?query={searchTerms}";
                  }
                ];
              };
            };
          };
        };

        testing = {
          id = 1;
        };
      };
    };

    programs.browserpass = {
      inherit (config.programs.firefox) enable;
      browsers = [ "firefox" ];
    };
  };
}
