{lib, stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2, gdk-pixbuf}:

stdenv.mkDerivation rec {
  name = "gkrellm-thinkbat";
  version = "0.2.2";
  src = fetchurl {
    url = "http://www.ksp.sk/~rasto/${name}/${name}-latest.tar.gz";
    sha256 = "sha256-65h6E3pBhsFGgkaZobVJPa4IatTelBLcH9HeTH4SRWk=";
  };
  
  patches = [
    (fetchurl {
       url = "http://archive.ubuntu.com/ubuntu/pool/universe/g/${name}/${name}_${version}-1.1.diff.gz";
       sha256 = "3cf9b662c54dc45876e3e8b1bc514cfe869af79eeac707af6ac7a4388f9bd1e9";
     })
  ];

    #sourceRoot = "${name}-${version}";
    buildInputs = [ pkgconfig gkrellm gtk2 glib gdk-pixbuf ];

    dontStrip = true;
    buildPhase = '' make clean
                    make '';

    installPhase = '' mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellm-thinkbat.sh}" "$out/bin/gkrellm-thinkbat"
                      chmod a+x "$out/bin/gkrellm-thinkbat"
                      substituteAll "${./gkrellm-thinkbatOFF.sh}" "$out/bin/gkrellm-thinkbatOFF"
                      chmod a+x "$out/bin/gkrellm-thinkbatOFF" '';
      postInstall = '' $out/bin/gkrellm-thinkbat '';
}
