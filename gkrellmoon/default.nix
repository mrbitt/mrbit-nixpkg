{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2 }:

stdenv.mkDerivation rec {
  pname = "gkrellmoon";
  version = "0.6";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/${pname}/${pname}/${version}/${pname}-${version}.tar.gz";
    sha256 = "0liq0x25bdx927l5hciwa7rmz04fdnhl9y298jgcmwc0kl2n4ad1";
  };

    buildInputs = [ pkgconfig gkrellm gtk2 glib ];
    dontConfigure = true;
    buildPhase = '' make clean
                    make'';
    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellmoon.sh}" "$out/bin/gkrellmoon"
                      chmod a+x "$out/bin/gkrellmoon"
                      substituteAll "${./gkrellmoonOFF.sh}" "$out/bin/gkrellmoonOFF"
                      chmod a+x "$out/bin/gkrellmoonOFF"
                      strip --strip-all $out/gkrellm2/plugins/*.so '';
}
