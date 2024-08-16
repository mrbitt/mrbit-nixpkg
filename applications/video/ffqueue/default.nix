{ lib
, stdenv
, fetchurl
, ffmpeg
, xterm
, wxGTK32
, pkg-config
, zlib
, xdg-user-dirs
, autoreconfHook
, xdg-utils
}:

stdenv.mkDerivation rec {

  pname = "ffqueue";
  version = "1.7.67";

  src = fetchurl {
      url = "https://github.com/bswebdk/FFQueue/archive/refs/tags/${version}.tar.gz";
      sha256 = "sha256-r+u4KNHQtF2oSYEeSWzCbeeduY0raRNPgI9KFpd9+AY=";
  };

 #  configureFlags = [ "--prefix=$(out)" ];
 #  makeFlags = [ "prefix=$(out)" ];
 
 nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [
    ffmpeg
    xterm
    wxGTK32
    zlib
    xdg-user-dirs
    xdg-utils
  ];
  
 installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/pixmaps,share/applications}
    install -m 755 ./src/ffqueue $out/bin
    install -m 644 ./res/MainLogo.png $out/share/pixmaps/ffqueue.png
    install -m 644 ./res/ffqueue.desktop $out/share/applications/
   runHook postInstall
  '';

 # outputs = [ "out" ];

  enableParallelBuilding = true;
  
 meta = with lib; {
    description = "Graphical user interface for FFMpeg";
    license = licenses.gpl2Plus;
    homepage = "https://github.com/bswebdk/FFQueue";
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
