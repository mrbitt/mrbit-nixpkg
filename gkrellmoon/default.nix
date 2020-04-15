{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2 }:

stdenv.mkDerivation rec {
  pname = "gkrellmoon";
  version = "0.6";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/${pname}/${pname}/${version}/${pname}-${version}.tar.gz";
    sha256 = "0liq0x25bdx927l5hciwa7rmz04fdnhl9y298jgcmwc0kl2n4ad1";
  };

    #patches = [./gkrellmoon-0.6-makefile.patch];

    buildInputs = [ pkgconfig gkrellm gtk2 glib ];
    dontConfigure = true;
    buildPhase = '' make clean
                    make'';
    installPhase = '' mkdir -p $out/usr/local/lib/gkrellm2/plugins
                      cp *.so $out/usr/local/lib/gkrellm2/plugins
                      strip --strip-unneeded $out/usr/local/lib/gkrellm2/plugins/*.so '';
}
