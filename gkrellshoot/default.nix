{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2, imagemagick }:

stdenv.mkDerivation rec {
  pname = "gkrellshoot";
  version = "0.4.4";
  src = fetchurl {
    url = "mirror://sourceforge/gkrellshoot/${pname}-${version}.tar.gz";
    sha256 = "0r61gf3glb2al3l1r34yajxyqc6kkgyayfyxxzvpd3nd025gzh8w";
  };

    buildInputs = [ pkgconfig gkrellm gtk2 glib imagemagick ];
    #dontConfigure = true;
    buildPhase = '' make clean
                    make '';
    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellshoot.sh}" "$out/bin/gkrellshoot"
                      chmod a+x "$out/bin/gkrellshoot"
                      substituteAll "${./gkrellshootOFF.sh}" "$out/bin/gkrellshootOFF"
                      chmod a+x "$out/bin/gkrellshootOFF"
                      strip --strip-unneeded $out/gkrellm2/plugins/*.so '';
}
