{ lib
, stdenv
, fetchurl
, gtk3
, glib
, imagemagick
, qmake
, cmake
, extra-cmake-modules
, pkg-config
#, qt5
, qtbase
, qttools
, wrapQtAppsHook
, gettext
, libxcb
, libxkbcommon

}:

stdenv.mkDerivation rec{
  pname = "converseen";
  version = "0.9.11.1";

  src = fetchurl {
    url = "https://sourceforge.net/projects/converseen/files/Converseen/Converseen%200.9/${pname}-${version}.tar.bz2";
    sha256 = "sha256-hVEa7SZEp+h/W8vmDLw+3L3PuyxLuUFt+Tm6hK0xpQM=";
  };
  
  doCheck = false;  
    # FIXME: checks must be disabled because they are lacking the qt env.
    #        They fail like this, even if built and wrapped with all Qt and
    #        runtime dependencies:
    #
    #     running install tests
    #     qt.qpa.plugin: Could not find the Qt platform plugin "xcb" in ""
    #     This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.
  dontWrapQtApps = true;
  
   postPatch = ''
    substituteInPlace converseen.pro --replace /usr "$out"
    '';
 
   #qmakeFlags = [ "CONFIG+=release" "PREFIX=${placeholder "out"}" "INCLUDEPATH+=${imagemagick.dev}/include/ImageMagick"];
cmakeFlags = [
    "-DDVERSION=${version}"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_DOCS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
   ];
  
  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
  '';
  
  nativeBuildInputs = [
   imagemagick
 # qmake
   cmake
   extra-cmake-modules
   qttools
    pkg-config
   wrapQtAppsHook
   gettext
  ];
    
  buildInputs = [
    qtbase
    glib
    gtk3
    libxcb
    libxkbcommon
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
