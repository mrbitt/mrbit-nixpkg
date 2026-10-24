{
  stdenv,
  fetchurl,
  gkrellm,
  glib,
  pkg-config,
  gtk2,
  alsa-lib,
}:

stdenv.mkDerivation rec {
  pname = "gkrellm-volume";
  version = "2.1.13";
  src = fetchurl {
    url = "http://www.minix3.org/pkgsrc/distfiles/local/3.4.0/${pname}-${version}.tar.gz";
    sha256 = "0hssn7hmccrw4xklvqnj2whq48sk65qs3yvf660mywj2sb00myl5";
  };

  patches = [ ./gkrellm-volume-2.1.13-reenable.patch ];
  
   # Downgrade strict modern GCC 14/15 safety checks to warnings for this legacy codebase
  NIX_CFLAGS_COMPILE = [
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=address"
  ];
  
   # Safely appends the bypass flag to the end of the Makefile's CFLAGS definition
  postPatch = ''
    substituteInPlace volume.c \
      --replace "if (right_click_cmd)" "if (1)"
  '';
  
 #NIX_CFLAGS_COMPILE = "-Wno-error=address";

  nativeBuildInputs = [ pkg-config ]; # pkg-config must be a native build input to run during the build
  buildInputs = [
    gkrellm
    gtk2
    glib
    alsa-lib
  ];

  buildPhase = ''
    runHook preBuild
    make clean
    make enable_alsa=1
    runHook postBuild
  '';
  
  #dontConfigure = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/gkrellm2/plugins/ $out/bin
    cp *.so $out/gkrellm2/plugins/
    strip --strip-unneeded $out/gkrellm2/plugins/*.so
    runHook postInstall
  '';
}
