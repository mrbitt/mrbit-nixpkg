{stdenv, fetchurl, gkrellm,  pkgconfig, gtk2, libX11, libXtst }:

stdenv.mkDerivation rec {
  name = "gkleds-0.8.2";
  src = fetchurl {
    url = "http://heim.ifi.uio.no/~oyvinha/e107_files/downloads/${name}.tar.gz";
    sha256 = "1a5yhrfcrahw8ln3y025z926jpl1xm0vbvjxpc9rkd1nw3s9f7aj";
   };

    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [gkrellm gtk2 libX11 libXtst];

    configureFlags = [ "--libdir=$(out)/gkrellm2/plugins" ];

    postInstall = ''
                   mkdir -p $out/bin
                      substituteAll "${./gkrellmled.sh}" "$out/bin/gkrellmled"
                      chmod a+x "$out/bin/gkrellmled"
                      substituteAll "${./gkrellmledOFF.sh}" "$out/bin/gkrellmledOFF"
                      chmod a+x "$out/bin/gkrellmledOFF"
        # remove all *.la
     rm -r "$out"/gkrellm2/plugins/*.la '';
}
