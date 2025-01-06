{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
  cairo,
  gdk-pixbuf,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  libsoup_3,
  pango,
  desktop-file-utils,
  appstream,
  webkitgtk_6_0,
}:

stdenv.mkDerivation rec {
  pname = "delineate";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "SeaDve";
    repo = "Delineate";
    rev = "v${version}";
    hash = "sha256-dFGh7clxc6UxQRTsNKrggWDvL3CPmzJmrvO1jqMVoTg=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-UlRvRE7E+4kRweAgmlATadYFYp/fz4fh/lDDdlEnfOk=";
  };

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
    libsoup_3
    pango
    webkitgtk_6_0
  ];

  meta = {
    description = "View and edit graphs";
    homepage = "https://github.com/SeaDve/Delineate/archive/refs/tags/v0.1.0.tar.gz";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "delineate";
    platforms = lib.platforms.all;
  };
}
