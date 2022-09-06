{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2, imagemagick }:

stdenv.mkDerivation rec {
  pname = "gkrellm-xkb";
  version = "1.05";
  src = fetchurl {
    url = "http://sweb.cz/tripie/gkrellm/xkb/dist/${pname}-${version}.tar.gz";
    sha256 = "108r90bq75x4w5xhnrkmqlsxpaa5fpwq0jq3fbvd1ymyiyhz65h2";
  };

    buildInputs = [ pkgconfig gkrellm gtk2 glib imagemagick ];
    #dontConfigure = true;
    buildPhase = '' make clean
                    make '';
    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellxkb.sh}" "$out/bin/gkrellxkb"
                      chmod a+x "$out/bin/gkrellxkb"
                      substituteAll "${./gkrellxkbOFF.sh}" "$out/bin/gkrellxkbOFF"
                      chmod a+x "$out/bin/gkrellxkbOFF"
                      strip --strip-unneeded $out/gkrellm2/plugins/*.so '';
}
