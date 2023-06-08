{ mkDerivation, lib, fetchFromGitHub, pkg-config, libuchardet, which, qtbase, qtsvg, qttools, qtwebsockets ,qtwebengine }:

mkDerivation rec {
  pname = "notepadqq";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "notepadqq";
    repo = "notepadqq";
    rev = "v${version}-beta";
    sha256 = "sha256-XA9Ay9kJApY+bDeOf0iPv+BWYFuTmIuqsLEPgRTCZCE=";
  };

  nativeBuildInputs = [
    pkg-config which qttools
  ];

  buildInputs = [
    qtbase qtsvg qtwebsockets qtwebengine  libuchardet
  ];

  preConfigure = ''
    export LRELEASE="lrelease"
  '';

  dontWrapQtApps = true;

  preFixup = ''
    wrapQtApp $out/bin/notepadqq
  '';
  
  #enableParallelBuilding = true;   desable x bugs 

  meta = with lib; {
    homepage = "https://notepadqq.com/";
    description = "Notepad++-like editor for the Linux desktop";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.rszibele ];
  };
}
