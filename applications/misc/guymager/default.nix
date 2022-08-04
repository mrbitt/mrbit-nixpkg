{ lib, stdenv, fetchurl, qtbase, qttools, qtdeclarative, qtquickcontrols, qmake, qt5, polkit, hdparm, smartmontools, parted, mkDerivation}:

mkDerivation  rec{
  pname = "guymager";
  version = "0.8.13";

   src = fetchurl {
    url = "https://sourceforge.net/projects/guymager/files/guymager/LatestSource/${pname}-${version}.tar.gz";
    sha256 = "sha256-xDsQ/d6fyfLOr4uXpdoqMljfFrVgQTUu0t2e5opcaRg=";
   };

  nativeBuildInputs = [ qmake ];

  buildInputs = [ qtbase qttools qtquickcontrols qtdeclarative hdparm smartmontools parted polkit ];
  
  enableParallelBuilding = false;
    # dontStrip = true;
  meta = with lib;{
    description = "The 2048 number game implemented in Qt";
    homepage = "https://github.com/xiaoyong/2048-Qt";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
