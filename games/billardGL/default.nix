{
  stdenv,
  fetchurl,
  lib,
  pkg-config,
  SDL,
  libGL,
  libGLU,
  freeglut,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  unzip,
  libXmu,
  libXext,
  libX11,
  libXi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "billardgl";
  version = "1.75";

  src = fetchurl {
    url = "mirror://sourceforge/billardgl/BillardGL-${finalAttrs.version}.tar.gz";
    hash = "sha256-m4ZbElSqMBJUgOx+os4A2RUk2wZqUkt4SSVFeChW35Y="; 
  };

  langPack = fetchurl {
    url = "mirror://sourceforge/billardgl/BillardGL-LP-010.zip";
    hash = "sha256-oTJaDtmw3D4sv4rOvk98TK9Bg1R7d3t1Q61h4ebgfPY="; 
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    SDL
    makeWrapper
    copyDesktopItems
    unzip
  ];

  buildInputs = [
    SDL
    libGL
    libGLU
    freeglut
    libXmu
    libXext
    libX11
    libXi
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "billardgl";
      exec = "billardgl";
      icon = "billardgl";
      comment = "A classic 3D Billiards simulator game";
      desktopName = "BillardGL";
      genericName = "Billiards Game";
      categories = [ "Game" "SportsGame" ];
    })
  ];

  env.CFLAGS = "-std=gnu89 -Wno-implicit-function-declaration -Wno-int-conversion -Wno-error=format-security -D_FORTIFY_SOURCE=0 -fno-stack-protector -O1";
  env.CXXFLAGS = "-std=gnu++98 -Wno-narrowing -Wno-error=format-security -D_FORTIFY_SOURCE=0 -fno-stack-protector -O1";

  postUnpack = ''
    unzip -o ${finalAttrs.langPack} -d .
    sourceRoot=$(echo [Bb]illard[Gg][Ll]-1.75/src)
    echo "Resolved working directory source target root: $sourceRoot"
  '';

  postPatch = ''
    # Ensure the directory naming layout uses CAPITAL 'Texturen' to match C++ expectations
    if [ -d ../textures ]; then
      mv ../textures ../Texturen
    elif [ -d ./textures ]; then
      mv ./textures ./Texturen
    fi

    # Integrate language pack elements relative to the capital 'Texturen' folder map
    mkdir -p ../lang
    cp -r ../../BillardGL-LP-010/*.lang ../lang/ 2>/dev/null || true
    if [ -d ../../BillardGL-LP-010/turk ]; then
      mkdir -p ../Texturen/turk
      cp -r ../../BillardGL-LP-010/turk/* ../Texturen/
    fi

    # FIXED: Fix Linux case-sensitivity by creating lowercase duplicates/symlinks 
    # of all texture files so the game can find 'dreizehn.bmp' regardless of casing.
    (
      cd ../Texturen
      find . -type f | while read -r file; do
        lowercased=$(echo "$file" | tr '[:upper:]' '[:lower:]')
        if [ "$file" != "$lowercased" ] && [ ! -f "$lowercased" ]; then
          mkdir -p "$(dirname "$lowercased")"
          cp "$file" "$lowercased"
        fi
      done
    )

    # Erase all occurrences of hardcoded paths inside the Makefile globally
    sed -i "s|-I/usr/X11R6/include||g" Makefile
    sed -i "s|/usr/X11R6/lib|lib|g" Makefile

    # Comprehensive loop to patch BOTH <iostream.h> and <fstream.h> safely across the codebase
    find . -maxdepth 2 -type f -name "*.[cC][pP][pP]" -o -name "*.[hH]" | while read -r file; do
      if grep -q "iostream.h" "$file" || grep -q "fstream.h" "$file"; then
        echo "Patching legacy stream headers inside standard library of: $file"
        sed -i 's|#include <iostream.h>|#include <iostream>\nusing namespace std;|g' "$file"
        sed -i 's|#include <fstream.h>|#include <fstream>\nusing namespace std;|g' "$file"
      fi
    done

    # Map every variation of the old system folders to an absolute short relative './' 
    # and capitalized 'Texturen/' pattern to satisfy fixed-size memory array buffers.
    find . -maxdepth 2 -type f -name "*.[cC][pP][pP]" -o -name "*.[hH]" | while read -r file; do
      sed -i "s|/usr/share/BillardGL/Texturen/|./Texturen/|g" "$file"
      sed -i "s|/usr/local/share/BillardGL/Texturen/|./Texturen/|g" "$file"
      sed -i "s|/usr/share/BillardGL/|./|g" "$file"
      sed -i "s|/usr/local/share/BillardGL/|./|g" "$file"
    done
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install the compiled binary
    mkdir -p $out/libexec
    cp BillardGL $out/libexec/billardgl-bin 2>/dev/null || cp billardgl $out/libexec/billardgl-bin

    # Prepare share package directories
    mkdir -p $out/share/billardgl
    
    # Copy assets into place (supporting both naming conventions just in case)
    cp -r doc lang textures Texturen $out/share/billardgl/ 2>/dev/null || true
    cp -r ../doc ../lang ../textures ../Texturen $out/share/billardgl/ 2>/dev/null || true

    # Create the launcher wrapper script
    mkdir -p $out/bin
    makeWrapper $out/libexec/billardgl-bin $out/bin/billardgl \
      --chdir "$out/share/billardgl"

    # For application menu icon handling
    mkdir -p $out/share/pixmaps
    COPIED_ICON=false
    
    for f in $out/share/billardgl/Texturen/*/[Bb]lglicon.bmp $out/share/billardgl/textures/*/[Bb]lglicon.bmp; do
      if [ -f "$f" ] && [ "$COPIED_ICON" = "false" ]; then
        echo "Copying game application desktop shortcut menu emblem: $f"
        cp "$f" $out/share/pixmaps/billardgl
        COPIED_ICON=true
      fi
    done

    if [ "$COPIED_ICON" = "false" ]; then
      find $out/share/billardgl/ -type f -name "*.bmp" -exec cp {} $out/share/pixmaps/billardgl \; -quit 2>/dev/null || true
    fi

    runHook postInstall
  '';

  meta = {
    description = "A classic, realistic 3D Billiards simulator game (With Integrated Language Pack)";
    homepage = "https://sourceforge.net";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "billardgl";
  };
})
