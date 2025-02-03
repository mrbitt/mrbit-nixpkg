{ lib, stdenv, fetchurl, pkg-config, zlib, libnotify, openssl, gtk3
, clang, gdb, bzip2, wxGTK31, autoconf, coreutils, xorg, wrapGAppsHook
}:

with lib;

stdenv.mkDerivation rec {
  name = "upp";
  #yearver= "2024.1.1";
  #version = "17490";
  version = "17616";
  pname = "upp";

  src = fetchurl {
   url = "https://www.ultimatepp.org/downloads/${pname}-posix-${version}.tar.xz";
    #url = "https://sourceforge.net/projects/${pname}/files/${pname}/${yearver}/${pname}-posix-${version}.tar.xz";
    #sha256 = "sha256-b7kdZxTXFZRjd475Q38U8KWAxCD1VWdy5OFq6jPlHRc=";
   sha256 = "sha256-dO3mwrU9y0ZTY7ogM5O4UiwROtGO3NoVsLsC/AactmQ=";
  };

  postPatch = ''
    
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

  nativeBuildInputs = [ autoconf pkg-config clang wrapGAppsHook ];
  buildInputs = [ xorg.libXdmcp wxGTK31 gtk3 openssl libnotify];

  makeFlags = ["prefix=$(out)"
              "DATA_PATH=$(prefix)/share/${pname}"
            ];  
 
 buildPhase = ''
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
   
    '';
 
  enableParallelBuilding = true;
  
 meta = {
    maintainers = [  ];
    platforms = platforms.linux;
    description = "Radical and innovative multiplatform C++ framework (known as U++) IDE";
    homepage = "http://www.ultimatepp.org";
    license = licenses.bsd0;
  };
}
