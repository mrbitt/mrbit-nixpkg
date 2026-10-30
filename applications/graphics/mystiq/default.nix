{
  lib,
  stdenv,
  gst_all_1,
  libX11,
  pipewire,
  pkg-config,
  pulseaudio,
  qt6,
  libnotify,
  sox,
  wayland,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "mysti-q";
  version = "25.04.17-1513-x86_64";

  src = fetchFromGitHub {
    owner = "biglinux";
    repo = "MystiQ";
    rev = "mystiq-${version}";
    hash = "sha256-z5isM4EngPbzP5o2FG5S+wXhd2f2a9NsmY9wlIaxPnA=";
  };

   postPatch = ''
    substituteInPlace mystiq.pro --replace  '/usr' $out'/'
    '';

  nativeBuildInputs = [
    qt6.qttools
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    gst_all_1.gstreamer
    libX11
    libnotify sox
    pulseaudio
    qt6.qtbase
    qt6.qtmultimedia
    wayland
    pipewire
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

   # Qt depends on a UTF-8 locale, and has switched to "C.UTF-8" instead.
  LANG = "C.UTF-8";

  postInstall = ''
    mkdir -p "$out/share/mystiq"
    cp -r "./translations" "$out/share/mystiq"
  '';

  meta = {
    description = "Qt5/C++ FFmpeg Media Converter";
    homepage = "https://github.com/biglinux/MystiQ/releases/tag/mystiq-25.04.17-1513-x86_64";
    changelog = "https://github.com/biglinux/MystiQ/blob/${src.rev}/Changelog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mysti-q";
    platforms = lib.platforms.all;
  };
}
