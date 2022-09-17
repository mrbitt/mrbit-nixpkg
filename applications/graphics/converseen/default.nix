{ lib
, stdenv
, fetchurl
, gtk3
, glib
, imagemagick
, cmake
, pkg-config
, qtbase
, qttools
, wrapGAppsHook
, gettext
}:

stdenv.mkDerivation {
  pname = "converseen";
  version = "0.9.9.8";

  src = fetchurl {
    url = "https://sourceforge.net/projects/converseen/files/Converseen/Converseen%200.9/converseen-0.9.9.8.tar.bz2";
    sha256 = "sha256-uyFMuZK4x30mAZAL5enWOkWVWsW4F499wrnfxCby9H4=";
  };
  
  dontWrapQtApps = true;
  nativeBuildInputs = [
    imagemagick
    cmake
    qttools
    pkg-config
    wrapGAppsHook
    gettext
  ];

  buildInputs = [
  qtbase
    glib
    gtk3
 ];

 
 
  meta = with lib; {
    description = " is a free cross-platform batch image processor that allows you to convert";
    homepage = "https://converseen.fasterland.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [  ];
    platforms = platforms.unix;
    mainProgram = "converseen";
   };
}
