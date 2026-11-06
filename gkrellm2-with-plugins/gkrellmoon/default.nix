
# Rende il file autosufficiente importando <nixpkgs> se non vengono passati argomenti
{ pkgs ? import <nixpkgs> {}, gkrellm ? pkgs.callPackage ../gkrellm-base.nix { inherit (pkgs.xorg) libX11 libSM libICE; } }:

let
  inherit (pkgs) stdenv fetchurl pkg-config glib gtk2 alsa-lib;
in
stdenv.mkDerivation rec {
  pname = "gkrellmoon";
  version = "0.6";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/${pname}/${pname}/${version}/${pname}-${version}.tar.gz";
    sha256 = "0liq0x25bdx927l5hciwa7rmz04fdnhl9y298jgcmwc0kl2n4ad1";
  };

    # Strict literal modifications target specific declaration blocks safely without fracturing variables
    postPatch = ''
      echo "Applying clean target modifications..."
      substituteInPlace MoonRise.c \
        --replace ", frac(), jd();" ";" \
        --replace "Tau, epsilon, Moon();" "Tau, epsilon;" \
        --replace "gdouble angle2pi();" ""
        
      substituteInPlace CalcEphem.c \
        --replace ", frac();" ";" \
        --replace ", jd();" ";" \
        --replace "gdouble jd();" ""

      substituteInPlace Moon.c \
        --replace "gdouble frac(), cosEPS" "gdouble cosEPS" \
        --replace ", Moon();" ";"
    '';

 
    # Passing the permissive parameters inside NIX_CFLAGS_COMPILE forces the Nix GCC 
    # compiler wrapper to downgrade all legacy function prototype argument errors down to warnings
    NIX_CFLAGS_COMPILE = [
      "-fpermissive"
      "-Wno-error"
    ];

  buildInputs = [
    pkg-config
    gkrellm
    gtk2
    glib
  ];
 
  dontConfigure = true;
 
 buildPhase = ''
    make clean
    make'';
  installPhase = ''
       mkdir -p $out/gkrellm2/plugins/ $out/bin
       cp *.so $out/gkrellm2/plugins/
    #   substituteAll "${./gkrellmoon.sh}" "$out/bin/gkrellmoon"
    #   chmod a+x "$out/bin/gkrellmoon"
    #   substituteAll "${./gkrellmoonOFF.sh}" "$out/bin/gkrellmoonOFF"
    #   chmod a+x "$out/bin/gkrellmoonOFF"
       strip --strip-all $out/gkrellm2/plugins/*.so '';
}
