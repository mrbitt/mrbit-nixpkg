{ lib
, mkDerivation
, fetchurl
, pkg-config
, qmake
, qttools
, gstreamer
, libX11
, pulseaudio
, qtbase
, qtmultimedia
, qtx11extras
, wayland
, gst-plugins-base
, gst-plugins-good
, gst-plugins-bad
, gst-plugins-ugly
}:
mkDerivation rec {

  pname = "vokoscreen-ng";
  version = "3.8.0";

  src = fetchurl {
       url = "https://github.com/vkohaupt/vokoscreenNG/archive/refs/tags/${version}.tar.gz";
     #owner = "vkohaupt";
     #repo = "vokoscreenNG";
     #rev = version;
    sha256 = "sha256-Nl6y4s9rl0Kdu1C2yX9H2vhqAek97m+grJL90hz8suw=";
  };

 qmakeFlags = [ "src/vokoscreenNG.pro" "DESTDIR=${placeholder "out"}/bin" ];

  nativeBuildInputs = [ qttools pkg-config qmake ];
  buildInputs = [
    gstreamer
    libX11
    pulseaudio
    qtbase
    qtmultimedia
    qtx11extras
    wayland
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];
   
   installPhase = ''
      runHook preInstall
        install -Dm444 -t $out/share/applications src/applications/vokoscreenNG.desktop
        install -Dm644 -t $out/share/pixmaps      src/applications/vokoscreenNG.png
	install -Dm644 -t $out/share/icons        src/vokoscreenNG.ico
	
     runHook postInstall
   '';

  postPatch = ''
    substituteInPlace src/vokoscreenNG.pro \
      --replace lrelease-qt5 lrelease
  '';

 postInstall = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = with lib; {
    description = "User friendly Open Source screencaster for Linux and Windows";
    license = licenses.gpl2Plus;
    homepage = "https://github.com/vkohaupt/vokoscreenNG";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
