{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  flex,
  itstool,
  rustPlatform,
  rustc,
  cargo,
  wrapGAppsHook4,
  desktop-file-utils,
  exiv2,
  libgsf,
  taglib,
  poppler,
  samba,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-commander";
  version = "1.19.0-unstable-2025-03-23";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gnome-commander";
    rev = "36c1d66555042d0c6f04bbc31aa9418a9c69cc7a";
    hash = "sha256-ufldh/mPWmxhOJTA5RRJaYScUgmr6vJEz3VcGz33zPs=";
  };

  # hard-coded schema paths
  postPatch = ''
    substituteInPlace src/gnome-cmd-data.cc plugins/fileroller/file-roller-plugin.cc \
      --replace-fail \
        '/share/glib-2.0/schemas' \
        '/share/gsettings-schemas/${finalAttrs.finalPackage.name}/glib-2.0/schemas'
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-dOd/4n8G/zEsF0ClqhI2QBLosEz3uyzC9q5sHDVWAx4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    flex
    itstool
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    exiv2
    libgsf
    taglib
    poppler
    samba
    gtest
  ];

  meta = {
    description = "Fast and powerful twin-panel file manager for the Linux desktop";
    homepage = "https://gcmd.github.io";
    license = lib.licenses.gpl2Plus;
    mainProgram = "gnome-commander";
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
  };
})
