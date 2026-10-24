{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  wxwidgets_3_3,
  autoconf,
  automake,
  libtool,
  python3,
  gettext,
  udis86,
  libmhash,
}:

stdenv.mkDerivation rec {
  pname = "wxHexEditor";
  version = "0.24";

# src = fetchFromGitHub {
#    owner = "EUA";
#    repo = "wxHexEditor";
#    rev = "master"; # Punta direttamente all'ultimo commit della branca master di Git
    # Forziamo una stringa vuota o un hash fittizio per forzare Nix a ricalcolare l'hash SHA256 corretto del codice Git aggiornato
#    sha256 = "WgI1/6HiLOcUTAGzyoR6zPdAPsmriPNMuGl05MVrXzE="; 
#  };
 
  src = fetchFromGitHub {
    repo = "wxHexEditor";
    owner = "EUA";
    rev = "v${version}";
    sha256 = "08xnhaif8syv1fa0k6lc3jm7yg2k50b02lyds8w0jyzh4xi5crqj";
  };

  buildInputs = [
    wxwidgets_3_3
    autoconf
    automake
    libtool
    python3
    gettext
    libmhash
    udis86
  ];
  
  preConfigure = "patchShebangs .";
  
  postUnpack = ''
    rm -rf source/udis86
    rm -rf source/mhash
  '';

  
   NIX_CFLAGS_COMPILE = [ "-std=c++17" ];
  prePatch = ''
    substituteInPlace Makefile --replace-fail "/usr" "$out"
   
   # 2. Neutralizzazione dei sottomoduli obsoleti nel Makefile
    sed -i -E 's|cd udis86.*||g' Makefile
    sed -i -E 's|cd mhash.*||g' Makefile
    sed -i -E 's|make -C mhash.*||g' Makefile
    sed -i -E 's|make -C udis86.*||g' Makefile
   # 3. TRASFORMAZIONE DEL LINKER (Risolve il bug di libudis86.a non trovato):
     # Rimuoviamo i vecchi percorsi statici locali del Makefile e inseriamo i flag puliti del compilatore
    substituteInPlace Makefile --replace-fail "mhash/lib/.libs/libmhash.a" "-lmhash"
    substituteInPlace Makefile --replace-fail "udis86/libudis86/.libs/libudis86.a" "-ludis86"
    
   # 4. Instradamento delle cartelle degli header (-I) e delle cartelle delle librerie (-L)
     # Diciamo a g++ esattamente in quali percorsi di Nixpkgs cercare i file binari da linkare
     substituteInPlace Makefile --replace-fail "-Iudis86" "-I${udis86}/include -L${udis86}/lib"
     substituteInPlace Makefile --replace-fail "-Imhash/include" "-I${libmhash}/include -L${libmhash}/lib"

   # 5. Correzione di massa di tutti gli header per udis86 e mhash
    find src/ -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i -E 's|#include ".*udis86/udis86.h"|#include <udis86.h>|g' {} +
    find src/ -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i -E 's|#include ".*udis86/libudis86/types.h"|#include <udis86.h>|g' {} +
    find src/ -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i -E 's|#include ".*mhash/include/mhash.h"|#include <mhash.h>|g' {} +

    # 6. Correzione del punto e virgola in HexDialogs.cpp
      substituteInPlace src/HexDialogs.cpp --replace-fail "WX_CLEAR_ARRAY(parent->HighlightArray )" "WX_CLEAR_ARRAY(parent->HighlightArray );"

    # 7. Automazione totale dei punti e virgola
      find src/ -type f -name "*.cpp" -exec sed -i -E 's|WX_CLEAR_ARRAY\(([^)]+)\)([^;]\|$)|WX_CLEAR_ARRAY(\1);|g' {} +
  '';

  patches = [
    # https://github.com/EUA/wxHexEditor/issues/90
    (fetchpatch {
      url = "https://github.com/EUA/wxHexEditor/commit/d0fa3ddc3e9dc9b05f90b650991ef134f74eed01.patch";
      sha256 = "1wcb70hrnhq72frj89prcqylpqs74xrfz3kdfdkq84p5qfz9svyj";
    })
   # ./missing-semicolon.patch
    ./01-add-pkexec-support.patch
   ./02-remove-strange-output.patch
  ];
   
   preBuild = ''
    export NIX_CFLAGS_COMPILE=$(echo "$NIX_CFLAGS_COMPILE" | sed 's/-Wno-error=conflicting-types//g' | sed 's/-Wno-implicit-function-declaration//g')
  '';
  
  makeFlags = [ "OPTFLAGS=-fopenmp" ];

  meta = {
    description = "Hex Editor / Disk Editor for Huge Files or Devices";
    longDescription = ''
      This is not an ordinary hex editor, but could work as low level disk editor too.
      If you have problems with your HDD or partition, you can recover your data from HDD or
      from partition via editing sectors in raw hex.
      You can edit your partition tables or you could recover files from File System by hand
      with help of wxHexEditor.
      Or you might want to analyze your big binary files, partitions, devices... If you need
      a good reverse engineer tool like a good hex editor, you welcome.
      wxHexEditor could edit HDD/SDD disk devices or partitions in raw up to exabyte sizes.
    '';
    homepage = "http://www.wxhexeditor.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
