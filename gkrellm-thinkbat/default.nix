{
  lib,
  stdenv,
  fetchurl,
  gkrellm,
  glib,
  pkg-config,
  gtk2,
  gdk-pixbuf,
}:

stdenv.mkDerivation rec {
  name = "gkrellm-thinkbat";
  version = "0.2.3";
  src = fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/universe/g/${name}/${name}_${version}.orig.tar.gz";
    sha256 = "sha256-i8ALb+8c6VwcNOmVDEK+GRXBd0NYnzS9jcmuNxcj8N4=";
  };

  postPatch = ''
        substituteInPlace collect_data.h \
          --replace "int read_from_file();" "int read_from_file(char *file);"
      '';
 
 NIX_CFLAGS_COMPILE = [ "-Wno-error=incompatible-pointer-types" ];
 
   buildInputs = [
    pkg-config
    gkrellm
    gtk2
    glib
    gdk-pixbuf
  ];

  dontStrip = true;
  buildPhase = ''
    make clean
    make '';

  installPhase = ''
    mkdir -p $out/gkrellm2/plugins/ $out/bin
                         cp *.so $out/gkrellm2/plugins/
                     #    substituteAll "${./gkrellm-thinkbat.sh}" "$out/bin/gkrellm-thinkbat"
                     #    chmod a+x "$out/bin/gkrellm-thinkbat"
                     #    substituteAll "${./gkrellm-thinkbatOFF.sh}" "$out/bin/gkrellm-thinkbatOFF"
                     #    chmod a+x "$out/bin/gkrellm-thinkbatOFF" '';
  postInstall = "$out/bin/gkrellm-thinkbat ";
}
