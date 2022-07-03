{ lib, stdenv, fetchurl, libX11, libXpm, libXt, pkg-config, autoreconfHook, gtk3 }:

stdenv.mkDerivation rec {
  pname = "xpenguins";
  version="3.2.1";

  src = fetchurl {
    url = "http://downloads.sf.net/sourceforge/${pname}/${pname}-${version}.tar.gz" ;
    sha256 = "sha256-talhaExGFAlSf+8s8mbYrjgjvXqc955nj6IF4d5hHA8=";
  };

   nativeBuildInputs = [ pkg-config autoreconfHook ];

   buildInputs = [ libX11 libXpm libXt gtk3 ];

  meta = with lib; {
    description = "Ever wanted cute little penguins walking along the tops of your windows?";
    homepage = "https://ratrabbit.nl/ratrabbit/software/xpenguins/";
    license = licenses.gpl2; 
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
