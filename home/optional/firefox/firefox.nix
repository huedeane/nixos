{ config, lib, ... }:

{
  programs.firefox = {
    enable = true;
      
    policies = lib.mkMerge [
      (import ./extensions.nix { inherit lib; })
      { }
    ];

    profiles = {
      huedeane = {
        isDefault = true;
        name = "huedeane";

        settings = {
          "browser.startup.homepage" = "https://color.firefox.com/?theme=XQAAAAJIBAAAAAAAAABBqYhm849SCicxcUcPX38oKRicm6da8pJSalLnSYHdbSBh-1CX0CGiPjBp_8RFBgLraofe5dNsJeJRsvnFfAV4-zfXO-vnAOmI7fBPSRgNM7CF7IhOlzarUyjNw7WCPDHbDP4RH0j7P8o1xTdgh9eM741tF9vA5zIeP4FCOblc1UUTuA-OpXV_xAJ49ZQtoFKZ13jCmEGxmz9z9k2sJ7LbqzCnps0eM52JW1JhVZQ31Os94i9OkF7yJYJaWd-Tb9wi7lQKm8UffSoiY4Oy0Lx65fEfhR0wmrQhKJiMMtg6_LqiGp0-FpffRuFU7SOoJtyT7pgGWWdWzno9GnBBB-ffBpbK6xWoK9UwEQY8RMfR94Z_sW3BpogkQ-LCz1NqsWIgVIRiddn1lSbFSieQAxK7bQg5_F76o7xWrP3cXjzhF-Bj2pHIBph5NX74co7W0mL1UidBq-SvX1AmCFmowT8nRLcYJqvK90ZfBlnTWU3NAPGC5Dzgx_QlhcdOhgrERh3Wm-ObLqVehUekd4r--XAizwkyJnYPLu-wOOFio_M3ojZf_89gr9Y";
          "browser.startup.page" = 1;
          "browser.startup.firstrunSkipsHomepage" = false;
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "browser.aboutwelcome.enabled" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "ui.systemUsesDarkTheme" = 1;
          # Disable weather
          "browser.newtabpage.activity-stream.showWeather" = false;
          
          # Disable recommended stories (Pocket)
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          
          # Disable recent activity / highlights
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.highlights" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          # enable custom wallpaper
          "browser.newtabpage.activity-stream.newtabWallpapers.enabled" = true;
          "browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled" = true;
          "browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.uuid" = "catppuccin-wallpaper";
          "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "custom";
          "layout.css.has-selector.enabled" = true;
        };
      };
    };
  };

  #home.file.".mozilla/firefox/huedeane/user.js".source = ./user.js;
  home.file.".mozilla/firefox/huedeane/wallpaper".source = ./wallpaper;
  home.file.".mozilla/firefox/huedeane/chrome".source = ./chrome;
}
