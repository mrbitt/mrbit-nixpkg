{
  stdenv,
  fetchurl,
  lib,
  pkg-config,
  # The 2005 original code requires legacy SDL 1.2 libraries, not SDL3
  SDL,
  SDL_mixer,
  makeWrapper, 
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "abe";
  version = "1.1";
    
  src = fetchurl {
    url = "mirror://sourceforge/abe/abe-${version}.tar.gz";
    sha256 = "sha256-38TqdMBMkhdavFydZc+mqtIYIJhU2H2HdYh44wO2d/c";
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
    SDL_mixer 
  ];

  # 2. Programmatically generate the custom .desktop manifest structure
  desktopItems = [
    (makeDesktopItem {
      name = "abe";
      exec = "abe";
      icon = "abe";
      comment = "Explore ancient pyramids and collect hidden keys";
      desktopName = "Abe's Amazing Adventure";
      genericName = "Platformer Game";
      categories = [ "Game" "ActionGame" ];
    })
  ];

  # FIX: Bypasses the ancient GCC test crash by forcing defensive C standards 
  # and preventing modern strict type safety from aborting the 2005 configure code
  env.CFLAGS = "-Wno-implicit-function-declaration -Wno-int-conversion -Wno-error=format-security -std=gnu89";  
  
  # Bypasses broken target calls inside the ancient Makefile architecture
  dontAddPrefix = true;
  configureFlags = [ "--prefix=${placeholder "out"}" ];

   # Overriding the default installPhase to deploy the full asset maps
  installPhase = ''
    runHook preInstall
      # Install the raw binary inside an internal hidden directory location
    mkdir -p $out/libexec
    cp src/abe $out/libexec/abe-bin

    # Deploy all the accompanying layout maps and static asset folders
    mkdir -p $out/share/abe
    cp -r images maps sounds $out/share/abe/

    # Create a wrapper execution script that hops into the share folder
    mkdir -p $out/bin
    makeWrapper $out/libexec/abe-bin $out/bin/abe \
      --chdir "$out/share/abe"

    # FIXED: Copy whatever BMP icons exist in the asset folder to act as the menu icon
    mkdir -p $out/share/pixmaps
    tar -xf $out/share/abe/images/images.tar -C $out/share/pixmaps/ abe.bmp 2>/dev/null || \
    tar -xf $out/share/abe/images/images.tar -C $out/share/pixmaps/ icon.bmp 2>/dev/null || true
    
    # Rinominiamo l'icona estratta per farla corrispondere al file .desktop
    if [ -f $out/share/pixmaps/abe.bmp ]; then
      mv $out/share/pixmaps/abe.bmp $out/share/pixmaps/abe
    elif [ -f $out/share/pixmaps/icon.bmp ]; then
      mv $out/share/pixmaps/icon.bmp $out/share/pixmaps/abe
    fi
  
    runHook postInstall
  '';

  meta = {
    description = "Scrolling, platform-jumping, key-collecting, ancient pyramid exploring game";
    homepage = "https://sourceforge.net";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "abe";
  };
}
