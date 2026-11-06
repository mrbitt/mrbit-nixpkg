{ stdenv, fetchurl, pkg-config, gkrellm, glib, gtk2, alsa-lib }:

{ pname, version, src, patches ? [], postPatch ? "", ... }@args:

stdenv.mkDerivation (rec {
  inherit pname version src patches postPatch;

  # Ridisponiamo i flag per declassare gli errori di compatibilità GCC 14/15 in warning
  NIX_CFLAGS_COMPILE = [
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=address"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gkrellm
    gtk2
    glib
    alsa-lib
  ];

  buildPhase = ''
    runHook preBuild
    make clean
    if grep -q "enable_alsa" Makefile 2>/dev/null; then
      make enable_alsa=1
    else
      make
    fi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/gkrellm2/plugins
    cp -f *.so $out/gkrellm2/plugins/ 2>/dev/null || cp -f src/*.so $out/gkrellm2/plugins/
    strip --strip-unneeded $out/gkrellm2/plugins/*.so
    runHook postInstall
  '';
} // removeAttrs args [ "pname" "version" "src" "patches" "postPatch" ])

