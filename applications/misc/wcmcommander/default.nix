{ lib, stdenv, fetchurl, unzip, bash, libX11, libarchive, samba, libssh2, freetype, python3, python2Packages, cmake}:

stdenv.mkDerivation rec {
  pname = "WCMCommander";
  version = "0.20.0";
   
  src = fetchurl {
    
    url ="https://github.com/sagpant/WCMCommander/archive/refs/tags/release-${version}.zip";
    sha256 = "Pj4S29my6YvdbP2fnwiJwrc94KPysUFicmGcDt2UuuA=";
  };
 
 postPatch = ''
    #patchShebangs .
    #patchShebangs src/ext-app-ux.cpp 
    #patchShebangs src/globals.h
    #patchShebangs install-files/share/wcm/config.default
    substituteInPlace src/fontdlg.cpp --replace "/usr" $out
    substituteInPlace src/ext-app-ux.cpp --replace "/usr" $out
    substituteAllInPlace src/globals.h --replace "/usr" $out
    substituteInPlace install-files/share/wcm/config.default --replace "/usr" $out
    substituteInPlace install-files/share/wcm/styles/solarized-gen.py --replace "#!/usr/bin/python" "#!${python2Packages.python.interpreter}"
    substituteInPlace tools/localize.py --replace /usr/bin/python ${python3.interpreter} 
    substituteInPlace install-files/share/wcm/styles/solarize.sh --replace "/usr" $out
    substituteInPlace install-files/share/wcm/styles/solarize.sh --replace '#!/bin/bash' '#!${bash}/bin/bash'
    substituteInPlace src/libtester/libconf.* --replace "/usr" $out
    substituteInPlace src/vfs/vfs-sftp2.cpp --replace-warn "char *errmsg;" "const char *errmsg;"
    
     # Fix modern CMake policy requirement
    sed -i 's/CMAKE_MINIMUM_REQUIRED(VERSION [2-3]\.[0-9]/CMAKE_MINIMUM_REQUIRED(VERSION 3.5/' CMakeLists.txt

    # Replace potential broken legacy macro/string constructors in sftp
    sed -i 's/std::string(\s*0\s*,\s*0\s*)/std::string()/g' src/vfs/vfs-sftp2.cpp
    sed -i 's/std::string\s*a\s*(\s*0\s*,\s*0\s*)/std::string a/g' src/vfs/vfs-sftp2.cpp
     # Risolve l'incompatibilità del tipo del costruttore std::string (unsigned char* const)
    substituteInPlace src/vfs/vfs-sftp2.cpp --replace-warn "unsigned char" "char"
  '';

    # Flag per declassare gli errori di conversione dei puntatori rigidi di libssh2 in semplici warning
  NIX_CFLAGS_COMPILE = "-std=c++14 -fpermissive";

   cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
     "-DWITH_SFTP=OFF"
  ];

 nativeBuildInputs = [ unzip cmake];

 buildInputs = [ libX11 freetype libssh2 libarchive samba ];

   meta = with lib; {
    homepage = "http://wcm.linderdaum.com/";
    description = "Multi-platform open source file manager for Windows, Linux, FreeBSD and OS X";
    license = licenses.gpl3;
    maintainers = with maintainers; [ volth ];
    platforms = platforms.all;
  };
}
