{ lib, stdenv, fetchurl, libX11, libXpm, libXt, pkg-config, autoreconfHook, gtk2, libGLU, libGL, guile_2_0, gnome2 }:

stdenv.mkDerivation rec {
  pname = "gnubik";
  version="2.4.3";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/${pname}/${pname}-${version}.tar.gz" ;
    sha256 = "sha256-Kz7Tb7W6nuyA/Yb5Tqu+hmUG9P4ZSKnXSA8iXIlIju4=";
  };

   
   nativeBuildInputs = [ pkg-config autoreconfHook ];

   buildInputs = [ libX11 libXpm libXt gtk2 guile_2_0 gnome2.gtkglext libGL libGLU ];

   postInstall = '' 
     install -dm755 "$out/share/licenses/${pname}/"
      install -Dpm644 COPYING "$out/share/licenses/${pname}/"

  install -dm755 "$out/share/doc/${pname}/"
  install -Dpm644 ABOUT-NLS AUTHORS ChangeLog INSTALL NEWS README TODO "$out/share/doc/${pname}/" '';
   
  meta = with lib; {
    description = "The GNUbik program is an interactive, graphical, cube puzzle";
    homepage = "http://www.gnu.org/software/gnubik/";
    license = licenses.gpl3; 
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
