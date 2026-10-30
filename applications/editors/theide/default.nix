
{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  zlib,
  libnotify,
  openssl,
  gtk3,
  llvmPackages_21,
  gdb,
  bzip2,
  wxwidgets_3_3,
  autoconf,
  coreutils,
  gnused,
  gnugrep,
  libxdmcp,
  pcre2,
  lz4,
  zstd,
  xz,
  xxhash,
  wrapGAppsHook3,
}:

with lib;

stdenv.mkDerivation rec {
  name = "upp";
  version = "18790";
  pname = "upp";

  src = fetchurl {
    url = "https://ultimatepp.org/downloads/${pname}-posix-${version}.tar.xz";
    sha256 = "sha256-jBUOb6h5Fo+Aa/fTQrdYtpjYfFnDYUoTYlc5cwSQpZo=";
  };

  postPatch = ''
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
    
    # Ensure bootstrap scripts are explicitly executable
    chmod +x ./configure ./configure_makefile
    patchShebangs .
  '';

  nativeBuildInputs = [
    autoconf
    pkg-config
    llvmPackages_21.clang 
    wrapGAppsHook3
  ];

  buildInputs = [
    libxdmcp
    wxwidgets_3_3
    gtk3
    llvmPackages_21.libclang
    llvmPackages_21.libclang.dev
    openssl
    libnotify
    pcre2
    lz4
    zstd
    xz
    xxhash
  ];
 
  env = {
    LIBCLANG_PATH = "${llvmPackages_21.libclang.lib}/lib";
  };

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
 
 # 1. Setup a dummy HOME layout for Fontconfig/XDG tools inside Nix sandbox
    export HOME=$(mktemp -d)
    export XDG_CACHE_HOME="$HOME/.cache"

    # 2. Expose basic core utilities explicitly
    export PATH="${coreutils}/bin:${gnused}/bin:${gnugrep}/bin:$PATH"

    # 3. Force the linker to accurately spot libclang shared objects
    export NIX_LDFLAGS="-L${llvmPackages_21.libclang.lib}/lib -lclang $NIX_LDFLAGS"
    
    # 4. Manually construct umkMakefile from template files to bypass the configure script entirely
    echo "Bypassing configure script and manually assembling umkMakefile..."
    
    # Ultimate++ templates usually require defining the compiler and flags
    # We substitute standard environment parameters straight into the make targets
    if [ -f ./umkMakefile.in ]; then
      cat ./umkMakefile.in > ./umkMakefile
    elif [ -f ./uppsrc/Makefile-umk ] ; then
      cat ./uppsrc/Makefile-umk > ./umkMakefile
    else
      # Fallback: Many U++ posix archives simply need a duplicate copy of the base Makefile
      cat ./Makefile > ./umkMakefile 2>/dev/null || true
    fi

    # Fix hardcoded library paths or compiler bindings inside the generated file if it exists
    if [ -f ./umkMakefile ]; then
      sed -i 's|CXX = g++|CXX = c++|g' ./umkMakefile
      sed -i 's|CC = gcc|CC = cc|g' ./umkMakefile
    else
      echo "No base template found. Emulating bare minimum build target..."
      # Custom minimal fallback definition if no make templates were present in root
      echo -e "all:\n\tbox" > ./umkMakefile
    fi

    # 5. Direct compilation sequence via mkumk_gcc.sh if present, otherwise call our explicit makefile
    if [ -f ./mkumk_gcc.sh ]; then
      echo "Executing direct bootstrap compilation script..."
      chmod +x ./mkumk_gcc.sh
      ./mkumk_gcc.sh
    else
      echo "Building via generated umkMakefile..."
      # Ensure there is a target rule match or use a baseline layout pass
      make -f umkMakefile || make -j$NIX_BUILD_CORES
    fi
    
    # 6. Compile the full IDE and tool suite using the freshly built umk executable
    # If the custom make rule compiled 'umk' directly into the root directory:
    ./umk ./uppsrc ide CLANG -brs ./theide
    ./umk ./uppsrc umk CLANG -brs ./umk
     
    ### theide specific settings
    install -D "./uppsrc/ide/theide.1" "$out/share/man/man1/theide.1"
    install -D "./uppsrc/ide/theide.desktop" "$out/share/applications/theide.desktop"
    install -D "./uppsrc/ide/icon64x64.png" "$out/share/pixmaps/theide.png"
    install -D "./theide" "$out/bin/theide"

    ### umk specific settings
    install -D "./uppsrc/umk/umk.1" "$out/share/man/man1/umk.1"
    install -D "./umk" "$out/bin/umk"
     
    ### upp specific settings
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
    homepage = "http://ultimatepp.org";
    license = licenses.bsd0;
  };
}
