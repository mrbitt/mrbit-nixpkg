with import <nixpkgs> {};
let linuxPaths = [
#  xfce4_powerman
  acpi
  cdrkit
  firefox
  gimp
  mplayer
  mupdf
  tcpdump
  usbutils
  nano
  xorg.xcursorthemes
  wireshark
  xterm
  xorg.xwd
  imagemagick
  python27Packages.docker_compose
  powertop
  inkscape
  xdiskusage
  inetutils
];
darwinPaths = [];
commonPaths = [
  nix
  git
  bind
  binutils
  emacs
  file
  gnumake
  gnupg
  iftop
  jq
  manpages
  mosh
  nmap
  pass
  python
  python27Packages.pip
  tmux
  units
  unzip
  vlc
];
  in
{
  # git = {
  #   svnSupport = true;
  # };
  packageOverrides = pkgs: rec {
    desktop = buildEnv {
      name = "desktop";
      paths = with pkgs; [ nix cacert  ] ++
      commonPaths ++
      (stdenv.lib.optionals stdenv.isDarwin darwinPaths) ++
      (stdenv.lib.optionals stdenv.isLinux linuxPaths) ;
    };
    gkrellm-themes = pkgs.callPackage ./gkrellm-themes { inherit (pkgs.gkrellm); };
    gkrellm-volume = pkgs.callPackage ./gkrellm-volume { inherit (pkgs.gkrellm); };
    gkrellmoon = pkgs.callPackage ./gkrellmoon { inherit (pkgs.gkrellm); };
    gkrellAclock = pkgs.callPackage ./gkrellAclock { inherit (pkgs.gkrellm); };
    gkleds = pkgs.callPackage ./gkleds { inherit (pkgs.gkrellm); };
    xdiskusage = pkgs.callPackage ./xdiskusage {};
    tinyproxy = pkgs.callPackage ./tinyproxy {};
    rtl8822bu = pkgs.callPackage ./rtl8822bu { inherit (pkgs.linuxPackages_latest) kernel; };

  linuxPackages = linuxPackages_5_4;
  linux = linuxPackages.kernel;
  linuxPackages_5_4 = recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_4);

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
