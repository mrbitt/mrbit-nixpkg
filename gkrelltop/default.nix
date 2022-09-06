{stdenv, fetchurl, gkrellm, glib, gtk2, pkgconfig}:

stdenv.mkDerivation rec {
  pname = "gkrelltop";
  version = "2.2.13";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/gkrelltop/${pname}_${version}.orig.tar.gz";
    sha256 = "1rj2xbk9b1sr7z7k3syab21pjgzbv1qmlr3kvvy0af6chr0mqn5j";
  };

    patches = [./gkrelltop-2.2.13-fix-build-system-1.patch];

    buildInputs = [ pkgconfig glib gtk2 gkrellm ];
    #dontConfigure = true;
    buildPhase = '' make clean
                    make  '';
    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrelltop.sh}" "$out/bin/gkrelltop"
                      chmod a+x "$out/bin/gkrelltop"
                      substituteAll "${./gkrelltopOFF.sh}" "$out/bin/gkrelltopOFF"
                      chmod a+x "$out/bin/gkrelltopOFF"
                      strip --strip-unneeded $out/gkrellm2/plugins/*.so '';
}
