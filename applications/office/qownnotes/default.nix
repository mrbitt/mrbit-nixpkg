{ lib, stdenv, fetchurl, qmake, pkg-config, qttools, qtbase, qtsvg, qtdeclarative, qt5compat, botan2, makeWrapper, qtwebsockets, qtwayland, wrapQtAppsHook}:

stdenv.mkDerivation rec {
  pname = "qownnotes";
  appname = "QOwnNotes";
  version = "23.12.4";

  src = fetchurl {
    url = "https://github.com/pbek/QOwnNotes/releases/download/v${version}/qownnotes-${version}.tar.xz";
    #url = "https://download.tuxfamily.org/${pname}/src/${pname}-${version}.tar.xz";
    # Fetch the checksum of current version with curl:
    # curl https://download.tuxfamily.org/qownnotes/src/qownnotes-<version>.tar.xz.sha256
    sha256 = "sha256-1xTJ7QV7T9PCo/Tta3Xmlmb99EL7gfFnUUXmehO0tzU=";
  };
 
    #dontWrapQtApps = true;
  nativeBuildInputs = [ qmake qttools wrapQtAppsHook  pkg-config]++ lib.optionals stdenv.isDarwin [ makeWrapper ];

  buildInputs = [ qtbase qtsvg qtdeclarative qtwebsockets qt5compat botan2 ]
    ++ lib.optionals stdenv.isLinux [ qtwayland ];
  
   qmakeFlags = [
    "USE_SYSTEM_BOTAN=1"
  ];
  
   postInstall =
  # Create a lowercase symlink for Linux
  lib.optionalString stdenv.isLinux ''
    ln -s $out/bin/${appname} $out/bin/${pname}
  ''
  
   # Wrap application for macOS as lowercase binary
  + lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/${appname}.app $out/Applications
    makeWrapper $out/Applications/${appname}.app/Contents/MacOS/${appname} $out/bin/${pname}
  '';
 
  meta = with lib; {
    description = "Plain-text file notepad and todo-list manager with markdown support and Nextcloud/ownCloud integration.";
    longDescription = "QOwnNotes is a plain-text file notepad and todo-list manager with markdown support and Nextcloud/ownCloud integration.";
    homepage = "https://www.qownnotes.org/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ totoroot ];
    platforms = platforms.linux;
  };
}
