{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  wrapGAppsHook4,
  desktop-file-utils,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  glib,
  libadwaita,
  vte-gtk4,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "distroshelf";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "ranfdev";
    repo = "DistroShelf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SKgZkKc3vcsAVNTipNLxTn4UTtFToRiPy4/BNsbOTJU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-lNKWcpdIr1tm2m50B9uOqFQvhndAEM5ADmmPBPb8sj4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vte-gtk4
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
    desktop-file-utils
    pkg-config
  ];

  buildInputs = [
    glib
    libadwaita
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/ranfdev/DistroShelf";
    description = "GUI for Distrobox Containers";
    mainProgram = "distroshelf";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
