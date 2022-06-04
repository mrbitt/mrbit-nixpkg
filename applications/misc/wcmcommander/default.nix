{ lib, stdenv, fetchurl, unzip, bash, libX11, libarchive, samba, libssh2, freetype, python3, python2Packages, cmake}:

stdenv.mkDerivation rec {
  pname = "WCMCommander";
  version = "0.20.0";
   
  src = fetchurl {
    
    url ="https://github.com/corporateshark/WCMCommander/archive/refs/tags/release-${version}.zip";
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
    '';

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
