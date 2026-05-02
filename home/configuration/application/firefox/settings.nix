{
  # Startup Page
  "browser.startup.page" = 3;
  "browser.startup.firstrunSkipsHomepage" = false;

  # FASTFOX
  "gfx.canvas.accelerated.cache-size" = 256;

  # SECUREFOX
  # Tracking Protection
  "browser.contentblocking.category" = "strict";
  "browser.download.start_downloads_in_tmp_dir" = true;
  "browser.uitour.enabled" = false;
  "privacy.globalprivacycontrol.enabled" = true;

  # OCSP & CERTS
  "security.OCSP.enabled" = 0;
  "privacy.antitracking.isolateContentScriptResources" = true;
  "security.csp.reporting.enabled" = false;

  # SSL / TLS
  "security.ssl.treat_unsafe_negotiation_as_broken" = true;
  "browser.xul.error_pages.expert_bad_cert" = true;
  "security.tls.enable_0rtt_data" = false;

  # Disk Avoidance
  "browser.cache.disk.enable" = false;
  "browser.privatebrowsing.forceMediaMemoryCache" = true;
  "media.memory_cache_max_size" = 65536;
  "browser.sessionstore.interval" = 60000;

  # Shutdown & Sanitizing
  "privacy.history.custom" = true;
  "browser.privatebrowsing.resetPBM.enabled" = true;

  # Speculative Loading
  "network.http.speculative-parallel-limit" = 0;
  "network.dns.disablePrefetch" = true;
  "network.dns.disablePrefetchFromHTTPS" = true;
  "browser.urlbar.speculativeConnect.enabled" = false;
  "browser.places.speculativeConnect.enabled" = false;
  "network.prefetch-next" = false;

  # Search / URL Bar
  "browser.urlbar.trimHttps" = true;
  "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
  "browser.search.separatePrivateDefault.ui.enabled" = true;
  "browser.search.suggest.enabled" = false;
  "browser.urlbar.quicksuggest.enabled" = false;
  "browser.urlbar.groupLabels.enabled" = false;
  "browser.formfill.enable" = false;
  "network.IDN_show_punycode" = true;

  # HTTPS Only
  "dom.security.https_only_mode" = true;
  "dom.security.https_only_mode_error_page_user_suggestions" = true;

  # Passwords
  "signon.formlessCapture.enabled" = false;
  "signon.privateBrowsingCapture.enabled" = false;
  "network.auth.subresource-http-auth-allow" = 1;
  "editor.truncate_user_pastes" = false;

  # Extensions
  "extensions.enabledScopes" = 5;

  # Headers / Referers
  "network.http.referer.XOriginTrimmingPolicy" = 2;

  # Containers
  "privacy.userContext.ui.enabled" = true;

  # Various
  "pdfjs.enableScripting" = false;

  # Safe Browsing
  "browser.safebrowsing.downloads.remote.enabled" = false;

  # Mozilla
  "permissions.default.desktop-notification" = 2;
  "permissions.default.geo" = 2;
  "geo.provider.network.url" = "https://beacondb.net/v1/geolocate";
  "browser.search.update" = false;
  "permissions.manager.defaultsUrl" = "";
  "extensions.getAddons.cache.enabled" = false;

  # Telemetry
  "datareporting.policy.dataSubmissionEnabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "toolkit.telemetry.unified" = false;
  "toolkit.telemetry.enabled" = false;
  "toolkit.telemetry.server" = "data:,";
  "toolkit.telemetry.archive.enabled" = false;
  "toolkit.telemetry.newProfilePing.enabled" = false;
  "toolkit.telemetry.shutdownPingSender.enabled" = false;
  "toolkit.telemetry.updatePing.enabled" = false;
  "toolkit.telemetry.bhrPing.enabled" = false;
  "toolkit.telemetry.firstShutdownPing.enabled" = false;
  "toolkit.telemetry.coverage.opt-out" = true;
  "toolkit.coverage.opt-out" = true;
  "toolkit.coverage.endpoint.base" = "";
  "browser.newtabpage.activity-stream.feeds.telemetry" = false;
  "browser.newtabpage.activity-stream.telemetry" = false;
  "datareporting.usage.uploadEnabled" = false;

  # Experiments
  "app.shield.optoutstudies.enabled" = false;
  "app.normandy.enabled" = false;
  "app.normandy.api_url" = "";

  # Crash Reports
  "breakpad.reportURL" = "";
  "browser.tabs.crashReporting.sendReport" = false;

  # PESKYFOX
  # Mozilla UI
  "extensions.getAddons.showPane" = false;
  "extensions.htmlaboutaddons.recommendations.enabled" = false;
  "browser.discovery.enabled" = false;
  "browser.shell.checkDefaultBrowser" = false;
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
  "browser.preferences.moreFromMozilla" = false;
  "browser.aboutConfig.showWarning" = false;
  "browser.aboutwelcome.enabled" = false;
  "browser.profiles.enabled" = true;
  "trailhead.firstrun.didSeeAboutWelcome" = true;

  # Theme Adjustments
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  "browser.compactmode.show" = true;
  "browser.privateWindowSeparation.enabled" = false;
  "svg.context-properties.content.enabled" = true;
  "layout.css.has-selector.enabled" = true;
  "browser.toolbars.bookmarks.visibility" = "always";
  "ui.systemUsesDarkTheme" = 1;  

  # AI
  "browser.ai.control.default" = "blocked";
  "browser.ml.enable" = false;
  "browser.ml.chat.enabled" = false;
  "browser.ml.chat.menu" = false;
  "browser.tabs.groups.smart.enabled" = false;
  "browser.ml.linkPreview.enabled" = false;

  # Fullscreen Notice
  "full-screen-api.transition-duration.enter" = "0 0";
  "full-screen-api.transition-duration.leave" = "0 0";
  "full-screen-api.warning.timeout" = 0;

  # URL Bar
  "browser.urlbar.trending.featureGate" = false;

  # New Tab Page
  "browser.newtabpage.activity-stream.default.sites" = "";
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
  "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
  "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
  "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
  "browser.newtabpage.activity-stream.feeds.highlights" = false;
  "browser.newtabpage.activity-stream.showWeather" = false;
  "browser.newtabpage.activity-stream.newtabWallpapers.enabled" = true;
  "browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled" = true;
  "browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.uuid" = "e3aa32e0-9a30-49ed-aa30-bd460a29149d";
  "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "custom";

  # Downloads
  "browser.download.manager.addToRecentDocs" = false;

  # PDF
  "browser.download.open_pdf_attachments_inline" = true;

  # Tab Behavior
  "browser.bookmarks.openInTabClosesMenu" = false;
  "browser.menu.showViewImageInfo" = true;
  "findbar.highlightAll" = true;
  "layout.word_select.eat_space_to_next_word" = false;
}
