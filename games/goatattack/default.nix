{ lib, stdenv, fetchurl, autoreconfHook, pkg-config, gtk2, freetype, libpng, SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, }:

stdenv.mkDerivation rec {
  pname = "goatattack";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-zFg8vCGCY4PQ/L7Kc1SnfuUMAcAcnSuIZ/1NIGtbZEY=";
  };

    configureFlags = [
    "--enable-map-editor=yes"
    "--enable-non-free-pak=yes"
    "--enable-master-server=yes"
    "--prefix=${placeholder "out"}"
    "--datadir=${placeholder "out"}/share"
  ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL2}/include/SDL2";
  
  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ gtk2 freetype libpng SDL2 SDL2_mixer];
      
  hardeningDisable = [ "format" ];
  enableParallelBuilding = true;

  meta = {
    description = "A fast-paced multiplayer pixel art shooter game";
    mainProgram = "goatattack";
    homepage = "https://github.com/goatattack/goatattack/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
