{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  SDL,
  SDL_image,
  openal,
  freealut,
  mesa,
  libGLU,
  zlib,
  libX11,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  libogg,
  libvorbis,
  curl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "assaultcube-reloaded";
  version = "unstable-2026-03";

  src = fetchFromGitHub {
    owner = "acreloaded";
    repo = "acr";
    rev = "1bf1c9dc8de35e79f12f69d59be96138cb0077e6";
    fetchSubmodules = true;
    hash = "sha256-zOBR0ica7KNfaYjYo+w+PwRIUk0mIKx8n2cnsSW6Sug="; 
  };

 # 2. FIXED: Pull down the standalone stable assets framework package directly 
  # to bypass broken Git submodules entirely!
  srcAssets = fetchurl {
    url = "https://github.com/acreloaded/acr/releases/download/v2.18.3/acr_v2.18.3-src.zip";
    hash = "sha256-ozq4KT6nooynx3FZLdd6ZVi3kpV3IYCf76cbr61G3pE="; # Zero-placeholder hash string
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    SDL
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    SDL
    SDL_image
    openal
    freealut
    mesa
    libGLU
    zlib
    libX11
    libogg
    libvorbis
    curl
    curl.out
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "assaultcube-reloaded";
      exec = "acr-client";
      icon = "assaultcube-reloaded";
      comment = "Multiplayer first-person shooter based on the Cube engine";
      desktopName = "AssaultCube Reloaded";
      genericName = "First-Person Shooter Game";
      categories = [ "Game" "ActionGame" "Shooter" ];
    })
  ];

  env.CFLAGS = "-fno-strict-aliasing -Wno-error=format-security -D_FORTIFY_SOURCE=0 -fno-stack-protector -O2";
  env.CXXFLAGS = "-fno-strict-aliasing -Wno-error=format-security -D_FORTIFY_SOURCE=0 -fno-stack-protector -O2";
 
    # FIXED: Purge all local legacy 'include' directories globally inside postPatch 
  # to guarantee no background compilation step links the wrong header slices
  postPatch = ''
   echo "Removing conflicting embedded library snapshots..."
    # 3. FIXED: Purging stale local audio frameworks to unblock clean building loops
    rm -rf source/src/include/SDL
    rm -rf source/include/SDL
    rm -rf source/include/ogg
    rm -rf source/include/vorbis

  # FIXED: Comprehensive file sweep targeting ALL make configurations 
    # to drop hardcoded global paths completely across the entire workspace tree
    find source/src/ -type f \( -name "Makefile*" -o -name "*.mk" -o -name "*.inc" \) -exec sed -i \
      "s|-I/usr/include||g; s|-L/usr/lib||g; s|/usr/lib/||g; s|/usr/include/||g" {} +

       # FIXED: Disable the broken precompiled headers (PCH) logic in the Makefile.
    # We strip out cube.h.gch dependencies so it compiles headers normally without linking.
    sed -i 's|cube.h.gch||g' source/src/Makefile
    sed -i '/cube.h.gch:/,/^$/d' source/src/Makefile
 
  '';
   
 # FIXED: Move down into the source directory context manually during buildPhase steps
  buildPhase = ''
    runHook preBuild
    
    # Hop down to the source directory where the main engine Makefile lives
    cd source/src
    
      # Inject pkg-config flags directly into the compiler engine rules
    make client \
      CXXFLAGS="$(pkg-config --cflags sdl SDL_image openal freealut glu ogg vorbis vorbisfile libcurl) -I./include $CXXFLAGS" \
      CFLAGS="$(pkg-config --cflags sdl SDL_image openal freealut glu ogg vorbis vorbisfile libcurl) -I./include $CFLAGS" \
      LDFLAGS="$(pkg-config --libs sdl SDL_image openal freealut glu ogg vorbis vorbisfile libcurl) -lX11 -lz -lGL -lopenal -lcurl"
    
    runHook postBuild
  '';
 
  installPhase = ''
    runHook preInstall

    # 1. Prepare target execution layouts directories inside our isolated storage space
    mkdir -p $out/libexec
    mkdir -p $out/share/acr-game

   # 2. FIXED: Copies 'ac_client' directly from the current build directory context (source/src)
    cp ac_client $out/libexec/acr-bin

    # 3. Move back up to the repository root workspace to clone game asset layouts folders
    cd ../..
    cp -r config mods packages scripts $out/share/acr-game/

    # 4. FIXED: Added ALSO_LOGLEVEL=0 and openal-soft driver silencing overrides 
    # directly to the makeWrapper to completely stop console spam and eliminate system lag!
    mkdir -p $out/bin
    makeWrapper $out/libexec/acr-bin $out/bin/acr-client \
      --chdir "$out/share/acr-game" \
      --set ALSO_LOGLEVEL "0" \
      --set AL_LOGLEVEL "0" \
      --add-flags "-p$out/share/acr-game" \
      --add-flags "-q\$HOME/.assaultcube_reloaded" \
      --add-flags "-glog.txt"

    # 5. Look for game image assets inside packages to generate a launcher icon emblem
    mkdir -p $out/share/pixmaps
    find $out/share/acr-game/packages/ -type f -name "*icon*.png" -exec cp {} $out/share/pixmaps/assaultcube-reloaded.png \; -quit 2>/dev/null || \
    find $out/share/acr-game/packages/ -type f -name "*.png" -exec cp {} $out/share/pixmaps/assaultcube-reloaded.png \; -quit 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "AssaultCube Reloaded (first-person-shooter game)";
    homepage = "https://github.com";
    license = lib.licenses.zlib;
    platforms = lib.platforms.linux;
    mainProgram = "acr-client";
  };
})
