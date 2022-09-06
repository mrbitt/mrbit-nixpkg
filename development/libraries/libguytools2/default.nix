{ lib, stdenv, fetchurl, qtbase, qttools, pkg-config, qttranslations, qmake, qt5, mkDerivation }:

mkDerivation  rec{
  pname = "libguytools2";
  version = "2.1.0";

   src = fetchurl {
    url = "https://sourceforge.net/projects/libguytools/files/libguytools/LatestSource/tools-${version}.tar.gz";
    sha256 = "sha256-eVYvjo2wKW2g9/9hL9nbQa1FRWDMMqMHok0V/adPHVY=";
   };

   qmakeFlags = [ "tools.pro" "DESTDIR=${placeholder "out"}/lib" ];

  nativeBuildInputs = [ pkg-config qmake ];

  buildInputs = [ qtbase qttools qttranslations ];
   
  installPhase = ''    
    install -d -m 0755 "$out/lib"
    cp -r lib/libguytools.so* $out/lib
 
    install -d -m 0755  "$out/include/libguytool2"
    cp -r include/* $out/include/libguytool2
  '';

 meta = with lib;{
    description = "The Library for guymager";
    homepage = "http://libguytools.sourceforge.net/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
