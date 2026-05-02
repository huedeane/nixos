{ config, lib, username, ... }:

{
  programs.firefox = {
    enable = true;
      
    policies = lib.mkMerge [
      (import ./extensions.nix { inherit lib; })
      { OverrideFirstRunPage = "https://color.firefox.com/?theme=XQAAAAJIBAAAAAAAAABBqYhm849SCicxcUcPX38oKRicm6da8pJSalLnSYHdbSBh-1CX0CGiPjBp_8RFBgLraofe5dNsJeJRsvnFfAV4-zfXO-vnAOmI7fBPSRgNM7CF7IhOlzarUyjNw7WCPDHbDP4RH0j7P8o1xTdgh9eM741tF9vA5zIeP4FCOblc1UUTuA-OpXV_xAJ49ZQtoFKZ13jCmEGxmz9z9k2sJ7LbqzCnps0eM52JW1JhVZQ31Os94i9OkF7yJYJaWd-Tb9wi7lQKm8UffSoiY4Oy0Lx65fEfhR0wmrQhKJiMMtg6_LqiGp0-FpffRuFU7SOoJtyT7pgGWWdWzno9GnBBB-ffBpbK6xWoK9UwEQY8RMfR94Z_sW3BpogkQ-LCz1NqsWIgVIRiddn1lSbFSieQAxK7bQg5_F76o7xWrP3cXjzhF-Bj2pHIBph5NX74co7W0mL1UidBq-SvX1AmCFmowT8nRLcYJqvK90ZfBlnTWU3NAPGC5Dzgx_QlhcdOhgrERh3Wm-ObLqVehUekd4r--XAizwkyJnYPLu-wOOFio_M3ojZf_89gr9Y"; }
    ];
 
    profiles = {
      ${username} = {
        isDefault = true;
        name = "${username}";
        settings = import ./settings.nix;
      };
    };
  };
  
  home.file.".mozilla/firefox/${username}/wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d".source = ./wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d;
  home.file.".mozilla/firefox/${username}/chrome".source = ./chrome;
  home.file."Downloads/vimium-options.json".source = ./vimium-options.json;
}
