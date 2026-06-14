{ pkgs, ... }:

let
  # 1. Blocca rigidamente il set stabile nixpkgs 24.05 per l'ecosistema SDL 1.2 legacy
  oldNixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
    sha256 = "1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
  }) {};

  # 2. Estraiamo gli helper nativi direttamente da pkgs stabile pulito
  inherit (pkgs) lib fetchurl pkg-config glib copyDesktopItems makeDesktopItem makeWrapper;

  legacySDL = oldNixpkgs.SDL;
  legacySDL_mixer = oldNixpkgs.SDL_mixer;
  legacySDL_Pango = oldNixpkgs.SDL_Pango;
  legacyPerlSDL = oldNixpkgs.perlPackages.SDL;
in

pkgs.stdenv.mkDerivation {
  pname = "frozen-bubble";
  version = "2.212";

  src = fetchurl {
    url = "mirror://cpan/authors/id/K/KT/KTHAKORE/Games-FrozenBubble-2.212.tar.gz";
    hash = "sha256-ch4E/2nFIzBgZWv79AAqoa6t2WyVNR8MV7uFtto1owU=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    makeWrapper
    oldNixpkgs.perl
  ];

  buildInputs = [
    glib
    legacySDL
    legacySDL_mixer
    legacySDL_Pango
    legacyPerlSDL
    oldNixpkgs.perlPackages.FileSlurp
    oldNixpkgs.perlPackages.ModuleBuild
    oldNixpkgs.perlPackages.CaptureTiny
  ];

  # Sposta i moduli perl richiesti nel percorso di inclusione globale PERL5LIB di compilazione
  PERL5LIB = with oldNixpkgs.perlPackages; makePerlPath [
    CompressBzip2
    AlienSDL 
    FileShareDir
    FileWhich
    IPCSystemSimple
    LocaleMaketextLexicon
    ModuleBuild
    FileSlurp
    legacyPerlSDL
    CaptureTiny
    ClassInspector
    TieSimple
  ];

  # PASSA LE FLAG AL COMPILATORE NATIVO: Garantisce l'inclusione degli header e della cartella di build corrente
  NIX_CFLAGS_COMPILE = "-Wno-error -I. -I${legacySDL}/include/SDL -I${legacySDL_mixer}/include/SDL";
configurePhase = ''
    runHook preConfigure

    # Rimuove globalmente i flag di errore bloccanti da qualsiasi file sorgente o script
    find . -type f -exec sed -i 's/-Werror//g' {} +
    
     # Patch di rete pulita per rimuovere gli URL dei vecchi server morti
    find . -type f \( -name "*.pm" -o -name "frozen-bubble" \) -exec sed -i 's|http://frozen-bubble.org|http://127.0.0|g' {} +
    find . -type f \( -name "*.pm" -o -name "frozen-bubble" \) -exec sed -i 's|http://sourceforge.net|http://127.0.0|g' {} +
    find . -type f \( -name "*.pm" -o -name "frozen-bubble" \) -exec sed -i 's|webother.linuxfr.org|127.0.0.1|g' {} +


    # Salta i test lenti di Alien::SDL e Disabilita il flag restrittivo di errore nel Build.PL per evitare conflitti con GCC
    substituteInPlace Build.PL \
      --replace-warn "module_name => 'Games::FrozenBubble'," \
                     "module_name => 'Games::FrozenBubble', include_dirs => [ '$(pwd)', '${legacySDL}/include', '${legacySDL_mixer}/include' ],"

    # GENERA I FILE DI REINDIRIZZAMENTO FISICI:
    cat << EOF > SDL_types.h
#ifndef SDL_types_h
#define SDL_types_h
#include <SDL/SDL.h>
#endif
EOF

    cat << EOF > SDL_rwops.h
#include <SDL/SDL_rwops.h>
EOF

    cat << EOF > SDL_audio.h
#include <SDL/SDL_audio.h>
EOF

    cat << EOF > SDL_version.h
#include <SDL/SDL_version.h>
EOF

    cat << EOF > SDL_endian.h
#include <SDL/SDL_endian.h>
EOF

    cat << EOF > begin_code.h
#include <SDL/begin_code.h>
EOF

    cat << EOF > close_code.h
#include <SDL/close_code.h>
EOF
    ${oldNixpkgs.perl}/bin/perl Build.PL --prefix=$out --install_path lib=$out/lib/perl5/site_perl --with_sdl_config=${legacySDL}/bin/sdl-config

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Inizializza l'intercettatore del linker locale per convertire i flag -Wl,
    mkdir -p local-bin
    REAL_LD=$(type -p ld)
    
    cat << EOF > local-bin/ld
#!/bin/sh
NEW_ARGS=""
for arg in "\$@"; do
  case "\$arg" in
    -Wl,-rpath,*)
      path=\$(echo "\$arg" | sed 's/-Wl,-rpath,//')
      NEW_ARGS="\$NEW_ARGS -rpath \$path"
      ;;
    *)
      NEW_ARGS="\$NEW_ARGS \$arg"
      ;;
  esac
done

exec $REAL_LD \$NEW_ARGS
EOF

    chmod +x local-bin/ld
    export PATH="$(pwd)/local-bin:''$PATH"

    ${oldNixpkgs.perl}/bin/perl Build
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    # Crea in anticipo le cartelle di out
    mkdir -p $out/bin $out/lib/perl5/site_perl
    ${oldNixpkgs.perl}/bin/perl Build install
   
     # 🚀 COPIA L'ICONA UFFICIALE NEI PERCORSI STANDARD DI LINUX:
    # Estrae l'icona dai sorgenti di Frozen Bubble (solitamente conservata in share o pixmaps)
    # e la inserisce nella directory standard hicolor/apps per farla riconoscere al gestore desktop.
    mkdir -p $out/share/icons/hicolor/64x64/apps
    if [ -f share/icons/frozen-bubble-icon-64x64.png ]; then
      cp share/icons/frozen-bubble-icon-64x64.png $out/share/icons/hicolor/64x64/apps/frozen-bubble.png
    elif [ -f share/pixmaps/frozen-bubble.png ]; then
      cp share/pixmaps/frozen-bubble.png $out/share/icons/hicolor/64x64/apps/frozen-bubble.png
    fi
 
    runHook postInstall
  '';

 # Usa gli apici singoli (') nel sed per impedire a Bash di interpretare erroneamente la stringa come sostituzione
  postInstall = ''
    if [ -f $out/bin/frozen-bubble ]; then
      # Sostituisce forzatamente la shebang di avvio agganciandola al percorso assoluto reale di Perl 5.38
      sed -i '1s|.*|#!${oldNixpkgs.perl}/bin/perl|' $out/bin/frozen-bubble
      sed -i '1s|.*|#!${oldNixpkgs.perl}/bin/perl|' $out/bin/frozen-bubble-editor

      wrapProgram $out/bin/frozen-bubble \
        --prefix PERL5LIB : "$out/lib/perl5/site_perl:${legacyPerlSDL}/lib/perl5/site_perl:$PERL5LIB" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ legacySDL legacySDL_mixer legacySDL_Pango ]}"
        
      wrapProgram $out/bin/frozen-bubble-editor \
        --prefix PERL5LIB : "$out/lib/perl5/site_perl:${legacyPerlSDL}/lib/perl5/site_perl:$PERL5LIB" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ legacySDL legacySDL_mixer legacySDL_Pango ]}"
    fi
  '';
 
  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "frozen-bubble";
      exec = "frozen-bubble";
      icon = "frozen-bubble";
      desktopName = "Frozen Bubble";
      genericName = "Frozen Bubble";
      comment = "Arcade/reflex colour matching game";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Puzzle with Bubbles";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
}
