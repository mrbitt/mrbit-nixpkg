{ lib, stdenv, fetchurl, qmake, qttools, qtbase, qtsvg, qtdeclarative, qt5compat, makeWrapper, qtwebsockets, qtwayland, wrapQtAppsHook}:

stdenv.mkDerivation rec {
  pname = "qownnotes";
  appname = "QOwnNotes";
  version = "23.8.2";

  src = fetchurl {
    url = "https://github.com/pbek/QOwnNotes/releases/download/v${version}/qownnotes-${version}.tar.xz";
    #url = "https://download.tuxfamily.org/${pname}/src/${pname}-${version}.tar.xz";
    # Fetch the checksum of current version with curl:
    # curl https://download.tuxfamily.org/qownnotes/src/qownnotes-<version>.tar.xz.sha256
    sha256 = "sha256-A/a5oNlHeHYqwBxVgR/HWlzy9mkpudNMVGjFfSYikdo=";
  };
 
    #dontWrapQtApps = true;
  nativeBuildInputs = [ qmake qttools wrapQtAppsHook]++ lib.optionals stdenv.isDarwin [ makeWrapper ];

  buildInputs = [ qtbase qtsvg qtdeclarative qtwebsockets qt5compat]
    ++ lib.optionals stdenv.isLinux [ qtwayland ];
  
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
