{ lib, stdenv, fetchurl, cmake, pkg-config, qt6, }:

stdenv.mkDerivation rec {
  pname = "gencolormap";
  version = "2.3";

  
  src = fetchurl {
    url ="https://marlam.de/gencolormap/releases/${pname}-${version}.tar.gz";
    sha256 = "sha256-frLDS0BwVrhxnmZRFAQ6OkvhmaX8Fiixy4U++MroE4Q=";
  };
  
 nativeBuildInputs = [ cmake qt6.wrapQtAppsHook pkg-config ];

  buildInputs = [ qt6.qtsvg qt6.qtdeclarative qt6.qtwebsockets ]
    ++ lib.optionals stdenv.isLinux [ qt6.qtwayland ];
  
  
meta = with lib; {
    description = "Tool for generate color maps for for scientific visualization";
    longDescription = '' '';
    homepage = "https://marlam.de/gencolormap/";
    license = licenses.mit;
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
