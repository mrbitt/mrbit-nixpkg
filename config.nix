
  packageOverrides = pkgs: rec {
    desktop = buildEnv {
      name = "desktop";
      paths = with pkgs; [ nix cacert  ] ++
      commonPaths ++
      (stdenv.lib.optionals stdenv.isDarwin darwinPaths) ++
      (stdenv.lib.optionals stdenv.isLinux linuxPaths) ;
    };
    
    mfcl2827dw = callPackage ./tools/system/cups-brother-mfcl2827dw { };
    toppler = callPackage ./games/toppler { };
    rocksndiamonds = callPackage ./games/rocksndiamonds { };
    delineate = callPackage ./development/delineate {};
    qmplay2 = callPackage /applications/video/qmplay2 { qtVersion = "6";};
    leafpad =./applications/editors/leafpad { };
    #l3afpad =./applications/editors/l3afpad { };
    ffaudioconverter = libsForQt5.callPackage ./applications/audio/ffaudioconverter { };
    opensurge = callPackage ./games/opensurge { };
    puffotter = python3Packages.callPackage ./development/python-modules/puffotter {};
    ffqueue = callPackage ./applications/video/ffqueue  { };
    goatattack = callPackage ./games/goatattack { };
    imhex = callPackage ./imhex { };
    jazz2 = callPackage ./games/jazz2 { };
    jazz2-content = callPackage ./games/jazz2-content { };
    tigerjython = callPackage ./applications/editors/tigerjython { };
    gencolormap = callPackage ./tools/misc/gencolormap { };
    cryptomator = callPackage ./tools/security/cryptomator {jdk = jdk21.override { enableJavaFX = true; };};
    veracrypt = callPackage ./applications/misc/veracrypt { wxGTK = wxGTK32; };
    gtk-pipe-viewer = perlPackages.callPackage ../applications/video/pipe-viewer { withGtk3 = true; };
    newsflash = callPackage ./applications/networking/feedreaders/newsflash {webkitgtk = webkitgtk_6_0;};
    netbeans = callPackage ./applications/editors/netbeans {jdk = jdk17;};
    zutty = callPackage ./applications/terminal-emulators/zutty { fontmiscmisc = xorg.fontmiscmisc; };
    tauon = callPackage ./applications/audio/tauon { };
    hurrican = callPackage ./games/hurrican {};
    app-icon-preview = callPackage ./tools/misc/app-icon-preview {};
    textpieces = callPackage ./tools/misc/textpieces {};
    converseen = libsForQt5.callPackage ./applications/graphics/converseen { };
    krita = libsForQt5.callPackage ./applications/graphics/krita { };
    notepadqq = libsForQt5.callPackage ./applications/editors/notepadqq { };
    qownnotes = callPackage ./applications/office/qownnotes {stdenv = if stdenv.isDarwin then darwin.apple_sdk_11_0.stdenv else stdenv; };
    wxhexeditor = callPackage ./applications/editors/wxhexeditor { };
    wike = callPackage ./applications/misc/wike { };
    theide = callPackage ./applications/editors/theide { };
    libguytools2 = libsForQt5.callPackage ./development/libraries/libguytools2 {};
    guymager = libsForQt5.callPackage ./applications/misc/guymager {inherit libguytools2;};
    vokoscreen-ng = libsForQt5.callPackage ./applications/video/vokoscreen-ng {inherit (gst_all_1) gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly;};
    gitkraken = callPackage ./applications/version-management/gitkraken { };
    xpenguins = callPackage ./games/xpenguins {};
    simpleclock = callPackage ./tools/misc/simpleclock {};
    perseus = callPackage ./applications/science/math/perseus {};
    wcmucommander = callPackage ./applications/misc/wcmcommander { };
    gtkhash = pkgs.callPackage ./gtkhash {};
    tkdiff = callPackage ./tkdiff { tcl = tcl-8_5; tk = tk-8_5; };
    tkrev = callPackage ./applications/version-management/tkrev  { };
    qwinff = libsForQt5.callPackage ./qwinff { };
    qt-fsarchiver = libsForQt5.callPackage ./qt-fsarchiver { };
    braceexpand = python3Packages.callPackage ./development/python-modules/braceexpand {};
    superpaper = pkgs.callPackage ./applications/misc/superpaper { };
    timeshift = pkgs.callPackage ./applications/backup/timeshift { };
    wbar = pkgs.callPackage ./applications/misc/wbar { };
    cairo-dock-core = pkgs.callPackage ./applications/misc/cairo-dock-core { };
    cairo-dock-plugins = pkgs.callPackage ./applications/misc/cairo-dock-plugins { };
    shlib = python3Packages.callPackage ./development/python-modules/shlib {};
    quantiphy = python3Packages.callPackage ./development/python-modules/quantiphy {};
    inform = python3Packages.callPackage ./development/python-modules/inform {};
    emborg = pkgs.callPackage ./emborg {};
    backwild = pkgs.callPackage ./backwild {};
    inxi-gui = pkgs.callPackage ./inxi-gui { inherit (pkgs.inxi); };
    gentoo = pkgs.callPackage ./gentoo {};
    gnome-commander = pkgs.callPackage ./gnome-commander {};
    a2048-qt = libsForQt5.callPackage ./a2048-qt { };
    gkrellm-xkb = pkgs.callPackage ./gkrellm-xkb { inherit (pkgs.gkrellm); };
    gkrellshoot = pkgs.callPackage ./gkrellshoot { inherit (pkgs.gkrellm); };
    gkrellm-thinkbat = pkgs.callPackage ./gkrellm-thinkbat { inherit (pkgs.gkrellm); };
    gkrellm-countdown = pkgs.callPackage ./gkrellm-countdown { inherit (pkgs.gkrellm); };
    gkrellm-themes = pkgs.callPackage ./gkrellm-themes { inherit (pkgs.gkrellm); };
    gkrellm-volume = pkgs.callPackage ./gkrellm-volume { inherit (pkgs.gkrellm); };
    gkrellmoon = pkgs.callPackage ./gkrellmoon { inherit (pkgs.gkrellm); };
    gkrelltop = pkgs.callPackage ./gkrelltop { inherit (pkgs.gkrellm); };
    gkrellAclock = pkgs.callPackage ./gkrellAclock { inherit (pkgs.gkrellm); };
    gkleds = pkgs.callPackage ./gkleds { inherit (pkgs.gkrellm); };
    gkrellm-hdplop = pkgs.callPackage ./gkrellm-hdplop { inherit (pkgs.gkrellm); };
    gkrellm2 = pkgs.callPackage ./gkrellm2 {};
    xdiskusage = pkgs.callPackage ./xdiskusage {};
    tinyproxy = pkgs.callPackage ./tinyproxy {};
    #rtl8822bu = pkgs.callPackage ./rtl8822bu { inherit (pkgs.linuxPackages ) kernel ; };
    #curabylonger = libsForQt5.callPackage ./applications/misc/curabylonger { };
    #pynest2d = python3Packages.callPackage ../development/python-modules/pynest2d { };
    
  #linuxPackages = linuxPackages_5_4;
  #linux = linuxPackages.kernel;
  #linuxPackages_5_4 = recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_4);

    get_iplayer = lib.overrideDerivation pkgs.get_iplayer (a: rec {
       version = "3.01";
       src = fetchFromGitHub {
         owner = "get-iplayer";
         repo = "get_iplayer";
         rev = "v${version}";
         sha256 = "1g08amb08n5nn0v69dgz9g5rpy4yd0aw9iww1ms98rrmqnv6l46y";
       };
    });

    jruby = lib.overrideDerivation pkgs.jruby (a: rec {
       version = "1.7.23";
       name = "jruby-${version}";
       dontStrip = true;
       src = pkgs.fetchurl {
         url = "http://jruby.org.s3.amazonaws.com/downloads/${version}/jruby-bin-${version}.tar.gz";
         sha1 = "23iii8vwszrjzgzq0amwyazdxrppjpib";
       };
       # make "ruby" run jruby
       installPhase = ''
         ${a.installPhase}
         (cd $out/bin && ln -s jruby ruby)
       '';
    });
  };
}
