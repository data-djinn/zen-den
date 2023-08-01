{ config, pkgs, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        darkreader
        clearurls
        cookie-autodelete
        ublock-origin
      ];
      name = "djinn";
      isDefault = true;
      search.engines = {
        "NixOS Options" = {
          urls = [{
            template = "https://search.nixos.org/options";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@no" ];
        };
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
        "NixOS Wiki" = {
          urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
          definedAliases = [ "@nw" ];
        };

        "Bing".metaData.hidden = true;
        "Google".metaData.alias = "@g";
        "Wikipedia".metaData.alias = "@wiki";
      };
      search.default = "DuckDuckGo";
      search.force = true;
      settings = {
        "beacon.enabled" = false;
        "browser.startup.homepage" = "https://news.ycombinator.com";
        "browser.contentblocking.category" = "strict";
        "browser.search.hiddenOneOffs" =
          "Google,Yahoo, Bing,Amazon.com,Twitter";
        "browser.search.isUS" = true;
        "browser.search.suggest.enabled" = false;
        "browser.send_pings" = false;
        "browser.startup.page" = 3;
        "browser.uidensity" = 1;  # dense
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "extensions.pocket.enabled" = false;
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "privacy.donottrackheader.enabled" = true;
        "privacy.donottrackheader.value" = 1;
        "privacy.firstparty.isolate" = true;
      };
    };
  };
}
