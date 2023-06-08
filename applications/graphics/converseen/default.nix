{ lib
, stdenv
, fetchurl
, gtk3
, glib
, imagemagick

, cmake
, extra-cmake-modules
, pkg-config
, qtbase
, qttools
, wrapQtAppsHook
, makeWrapper
, gettext
, libxcb
, libxkbcommon
, lsb-release

}:

let inherit (lib) getDev; in

 stdenv.mkDerivation rec{
  pname = "converseen";
  version = "0.9.11.1";

  src = fetchurl {
    url = "https://sourceforge.net/projects/converseen/files/Converseen/Converseen%200.9/${pname}-${version}.tar.bz2";
    sha256 = "sha256-hVEa7SZEp+h/W8vmDLw+3L3PuyxLuUFt+Tm6hK0xpQM=";
  };
  
  #doCheck = false;  
    # FIXME: checks must be disabled because they are lacking the qt env.
    #        They fail like this, even if built and wrapped with all Qt and
    #        runtime dependencies:
    #
    #     running install tests
    #     qt.qpa.plugin: Could not find the Qt platform plugin "xcb" in ""
    #     This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.
  #dontWrapQtApps = true;
  
   postPatch = ''
    substituteInPlace converseen.pro --replace /usr "$out"
    substituteInPlace converseen.pro --replace '$$[QT_INSTALL_BINS]/lrelease' '${getDev qttools}/bin/lrelease'
    '';
 
 preConfigure = ''
    export LRELEASE="lrelease"
  '';
 
   #qmakeFlags = [ "CONFIG+=release" "PREFIX=${placeholder "out"}" "INCLUDEPATH+=${imagemagick.dev}/include/ImageMagick"];
   makeFlags = [ "PREFIX=$(out)" "LOCALEDIR=$(out)/share/locale" ];
  
 nativeBuildInputs = [
   imagemagick
   cmake 
   extra-cmake-modules
   qttools
   pkg-config
   wrapQtAppsHook
   gettext
   lsb-release
  ]++ lib.optionals stdenv.isDarwin [ makeWrapper ];
    
  buildInputs = [
    qtbase
    glib
    gtk3
    libxcb
    libxkbcommon
 ];
    
    preInstall = ''
       mkdir -p $out/share/applications
       mkdir -p $out/share/pixmaps
      ls -l 
      #cp -r "res/converseen.png" $out/share/pixmaps/converseen.png
      '';
    
   meta = with lib; {
    description = " is a free cross-platform batch image processor that allows you to convert";
    homepage = "https://converseen.fasterland.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [  ];
    platforms = platforms.unix;
    mainProgram = "converseen";
   };
}
