{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, qmake
, ffmpeg
, qtbase
, qttools
, qtmultimedia
, qtlocation ? null # qt5 only
, qtpositioning ? null # qt6 only
, qtserialport
, qtsvg
, qt5compat ? null # qt6 only
, wrapQtAppsHook
}:

let
  isQt6 = lib.versions.major qtbase.version == "6";
in
stdenv.mkDerivation rec {
  pname = "f-faudio-converter";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "Bleuzen";
    repo = "FFaudioConverter";
    rev = "v${version}";
    hash = "sha256-B+B0A4T2egCOhr9ub3GQhRUKKKa1f5LoxXjopMjtme0=";
  };
  
    postPatch = ''
    sed -ie  's|DEFAULT_FFMPEG_BINARY = .*|DEFAULT_FFMPEG_BINARY = ${ffmpeg}/bin/ffmpeg|' ./FFaudioConverter.pro
    substituteInPlace  ./update-translations.sh --replace "lupdate" "${qttools.dev}/bin/lupdate"
    '';
  
   qmakeFlags = [ "LRELEASE=${lib.getDev qttools.dev}/bin/lrelease"
     "-spec" "linux-g++" "prefix=$(out)" "CONFIG+=release" "CONFIG+=WITH_I18N"
     "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    #"DSRDIR=${placeholder "out"}/share/deepin-picker"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-picker" 
    "LOCALEDIR=$(out)/share/locale"
    "QMAKE_LUPDATE=${qttools.dev}/bin/lupdate" ]; 
    
   nativeBuildInputs = [ qttools pkg-config qmake wrapQtAppsHook ];
   
  buildInputs = [
    qtserialport ffmpeg qtmultimedia
  ] ++ (if isQt6 then [
    qtbase
    qtpositioning
    qtsvg
    qt5compat
  ] else [
    qtlocation
  ]);
   
 #  preConfigure = ''
 #    export LRELEASE="lrelease"
 #   lrelease FFaudioConverter.pro
 # '';
  
 meta = with lib; {
    description = "Graphical audio convert and filter tool";
    homepage = "https://github.com/Bleuzen/FFaudioConverter";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "f-faudio-converter";
    platforms = platforms.all;
  };
}
