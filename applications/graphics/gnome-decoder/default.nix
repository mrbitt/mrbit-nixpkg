{ lib
, clangStdenv
, fetchFromGitLab
, rustPlatform
, cargo
, cmake
, meson
, ninja
, pkg-config
, rustc
, glib
, gtk4
, libadwaita
, zbar
, sqlite
, openssl
, pipewire
, gstreamer
, gst-plugins-base
, gst-plugins-bad
, wrapGAppsHook4
, appstream-glib
, desktop-file-utils
}:

clangStdenv.mkDerivation rec {
  pname = "gnome-decoder";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "decoder";
    rev = version;
    hash = "sha256-B5TtD3SdMBSXMERtxxj+zbmz9BclOY0L8T2xFEI5uEo=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${version}";
    inherit src;
    hash = "sha256-Yahvty0cYBfJ/ErelrVtmf7xUYVSrSG0Jt5FlSDHjCw=";
  };

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    cargo
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    zbar
    sqlite
    openssl
    pipewire
    gstreamer
    gst-plugins-base
    gst-plugins-bad
  ];

  meta = with lib; {
    description = "Scan and Generate QR Codes";
    homepage = "https://gitlab.gnome.org/World/decoder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "decoder";
    maintainers = with maintainers; [ zendo ];
  };
}
