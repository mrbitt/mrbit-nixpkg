{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  zlib,
  libnotify,
  openssl,
  gtk3,
 # clang,
  llvmPackages_21, # Scegliamo la versione  che è stabile e compatibile
  gdb,
  bzip2,
  wxwidgets_3_3,
  autoconf,
  coreutils,
  libxdmcp,
  wrapGAppsHook3,
}:

with lib;

stdenv.mkDerivation rec {
  name = "upp";
  #yearver= "2025.1.1";
  #version = "17810";
  version = "18574";
  pname = "upp";

  src = fetchurl {
    url = "https://www.ultimatepp.org/downloads/${pname}-posix-${version}.tar.xz";
    #url = "https://sourceforge.net/projects/${pname}/files/${pname}/${yearver}/${pname}-posix-${version}.tar.xz";
    sha256 = "sha256-+839PsemsOdb99jrfWebGPRxiTN7LJ1iNypF1QV5rO4=";
  };

  postPatch = ''
 #   substituteInPlace uppsrc/CtrlCore/CtrlCore.h \
 #     --replace-fail "typedef Ctrl CLASSNAME;" "typedef Ctrl CLASSNAME; void WndScrollView(const Rect& r, int dx, int dy); void SyncScroll();"
    # Forza la definizione di CX_CXXInvalidAccessSpecifier nel caso in cui l'ambiente umk non trovi l'header corretto
    # sed -i '129i #ifndef CX_CXXInvalidAccessSpecifier\n#define CX_CXXInvalidAccessSpecifier 0\n#endif' ./uppsrc/ide/clang/clang.h
   
    cp ${llvmPackages_21.libclang.dev}/include/clang-c/*.h ./uppsrc/ide/clang/
    cp ${llvmPackages_21.libclang.dev}/include/clang-c/Index.h ./uppsrc/ide/clang/libclang.h

    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/Core/Util.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/Core/Speller.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/CtrlLib/FileSel.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/ide/app.tpp/umk_en-us.tpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/ide/Setup.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/ide/Methods.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/ide/Builders/Build.cpp
    sed -ie "s|/usr/|${coreutils}/|" ./uppsrc/ide/Builders/Install.cpp
    sed -ie "s|/usr/bin/env|${coreutils}/bin/env|" ./configure
    sed -ie "s|/usr/bin/env|${coreutils}/bin/env|" ./configure_makefile
    patchShebangs .
  '';

  nativeBuildInputs = [
    autoconf
    pkg-config
    llvmPackages_21.clang 
    #clang
    wrapGAppsHook3
  ];
  buildInputs = [
    libxdmcp
    wxwidgets_3_3
    gtk3
    llvmPackages_21.libclang     # Forniscxe le librerie dinamiche (.so)
    llvmPackages_21.libclang.dev
    openssl
    libnotify
  ];
 
  #env.NIX_CFLAGS_COMPILE = "-Wl,--allow-shlib-undefined";
  env = {
    #CPATH = "${llvmPackages_21.libclang.dev}/include:${llvmPackages_21.clang}/resource-root/include";
    #LIBRARY_PATH = "${llvmPackages_21.libclang.lib}/lib";
    LIBCLANG_PATH = "${llvmPackages_21.libclang.lib}/lib";
  };

  makeFlags = [
    "prefix=$(out)"
    "DATA_PATH=$(prefix)/share/${pname}"
  ];

  buildPhase = ''
   runHook preBuild
       # 1. Creiamo la HOME fittizia per Fontconfig
    export HOME=$(mktemp -d)
    export XDG_CACHE_HOME="$HOME/.cache"

    # 2. Forziamo il linker di NixOS a trovare e iniettare la libreria libclang reale
    export NIX_LDFLAGS="-L${llvmPackages_21.libclang.lib}/lib -lclang $NIX_LDFLAGS"
      # export LDFLAGS="-L${llvmPackages_21.libclang.lib}/lib -lclang $LDFLAGS"
    
      #cd ./upp
       ./configure
       make -f umkMakefile -j 4
      ./umk ./uppsrc ide CLANG -brs ./theide
      ./umk ./uppsrc umk CLANG -brs ./umk
     
          ### # theide specific settings
    install -D "./uppsrc/ide/theide.1" "$out/share/man/man1/theide.1"
    # desktop entry
    install -D "./uppsrc/ide/theide.desktop" "$out/share/applications/theide.desktop"
    # icon
    install -D "./uppsrc/ide/icon64x64.png" "$out/share/pixmaps/theide.png"
    #install -D "./uppsrc/ide/theide-48.png" "$out/share/pixmaps/theide.png"
    # fix permissions
    #find "$out/" -print0 | xargs -0 chown root:root
    #find "$out/" -type f -print0 | xargs -0 chmod 644
    #find "$out/" -type d -print0 | xargs -0 chmod 755
    # install applications
    install -D "./theide" "$out/bin/theide"

       #### umk specific settings
     install -D "./uppsrc/umk/umk.1" "$out/share/man/man1/umk.1"
     install -D "./umk" "$out/bin/umk"
     
       #### # upp specific settings
    mkdir -p "$out/share/upp"
    cp -r "./"{examples,reference,tutorial,uppsrc} "$out/share/upp/"
    echo "#define IDE_VERSION \"${version}-Arch\"" > "$out/share/upp/uppsrc/ide/version.h"    
   runHook postBuild
  '';

  enableParallelBuilding = true;

  meta = {
    maintainers = [ ];
    platforms = platforms.linux;
    description = "Radical and innovative multiplatform C++ framework (known as U++) IDE";
    homepage = "http://www.ultimatepp.org";
    license = licenses.bsd0;
  };
}
