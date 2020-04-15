{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2, alsaLib }:

stdenv.mkDerivation rec {
  pname = "gkrellm-volume";
  version = "2.1.13";
  src = fetchurl {
    url = "http://www.minix3.org/pkgsrc/distfiles/local/3.4.0/${pname}-${version}.tar.gz";
    sha256 = "0hssn7hmccrw4xklvqnj2whq48sk65qs3yvf660mywj2sb00myl5";
  };

    patches = [./gkrellm-volume-2.1.13-reenable.patch];

    buildInputs = [ pkgconfig gkrellm gtk2 glib alsaLib ];
    #dontConfigure = true;
    buildPhase = '' make clean
                    make enable_alsa=1 '';
    installPhase = '' mkdir -p $out/usr/local/lib/gkrellm2/plugins
                      cp *.so $out/usr/local/lib/gkrellm2/plugins
                      strip --strip-unneeded $out/usr/local/lib/gkrellm2/plugins/*.so '';
}
