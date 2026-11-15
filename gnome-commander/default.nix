{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  flex,
  itstool,
  wrapGAppsHook3,
  desktop-file-utils,
  exiv2,
  appstream,
  gtk4,
  libgsf,
  taglib,
  poppler,
  samba,
  cargo,
  rustc,
  rustPlatform,
  gtest,
  python3,
  vte-gtk4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-commander";
  version = "2.2.3";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gnome-commander";
    tag = finalAttrs.version;
    hash = "sha256-05xqtKJMo8CInuCjlSmMx1u/+5ZD6M6NvZm2ynH3w9I=";
  };

 cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    name = "${finalAttrs.pname}-${finalAttrs.version}-vendor";
    hash = "sha256-uu7zfsjmuHTUHcjCYRU7D0m8abxHnfD8WsfZ0Js25Kk=";
  };
  
  # hard-coded schema paths
#  postPatch = ''
 #   substituteInPlace src/gnome-cmd-data.cc plugins/fileroller/file-roller-plugin.cc \
 #     --replace-fail \
 #       '/share/glib-2.0/schemas' \
#        '/share/gsettings-schemas/${finalAttrs.finalPackage.name}/glib-2.0/schemas'
#  '';

postPatch = ''
  patchShebangs project_version.py
'';


  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    python3
    meson
    ninja
    pkg-config
    gtk4
    appstream
    flex
    itstool
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    vte-gtk4
    exiv2
    libgsf
    taglib
    poppler
    samba
  ];

  postConfigure = ''
    mkdir -p build/cargo-home
    if [ -d "$CARGO_HOME" ]; then
      cp -r "$CARGO_HOME"/* build/cargo-home/
    elif [ -d "../.cargo" ]; then
      cp -r ../.cargo/* build/cargo-home/
    fi
  '';

 #mesonFlags = [ (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck) ];

  checkInputs = [ gtest ];

  doCheck = false; # gtest requires C/C++17 but the project is written in C/C++11

  meta = {
    description = "Fast and powerful twin-panel file manager for the Linux desktop";
    homepage = "https://gcmd.github.io";
    license = lib.licenses.gpl2Plus;
    mainProgram = "gnome-commander";
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
  };
})
