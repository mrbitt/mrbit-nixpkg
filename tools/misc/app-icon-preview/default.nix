{lib
, stdenv
, fetchurl
#, fetchFromGitLab
, json-glib
, glib
, rustPlatform
, rustc
, gobject-introspection
, gsettings-desktop-schemas
, pkg-config
, ninja
, cargo
, meson
, gtksourceview5
, libadwaita
, gjs
, gtk4
, cmake
, desktop-file-utils
, appstream-glib
, libxml2
, librsvg
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "app-icon-preview";
  version = "3.3.0";

  
  src = fetchurl {
    url = "https://gitlab.gnome.org/World/design/app-icon-preview/-/archive/${version}/app-icon-preview-${version}.tar.bz2";
    sha256 = "sha256-LDj6uVAI0cYbi2mj6d0hH3s6gKUtXLxXXlQToxMpzmU=";
  };
    
   cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librsvg-2.56.0" = "sha256-A2NnNM3cuw8CEVNpAmu6s9IK+aBjumZ8pQdcOZDRHAo=";
    };
  };

  nativeBuildInputs = [
    cargo 
    json-glib
    desktop-file-utils # For update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    rustc
    libxml2  
    appstream-glib
    wrapGAppsHook # For GLib-GIO-ERROR **: 14:42:46.572: Settings schema
    ] ++ (with rustPlatform; [
    cargoSetupHook
    librsvg
    cargo
    rustc
 ]);

  buildInputs = [
    gsettings-desktop-schemas
    cmake
    glib
    gtk4
    librsvg
    gtksourceview5
    libadwaita
    gjs
];
 
  postPatch = ''
    patchShebangs src/config.rs
    #substituteInPlace build-aux/meson/postinstall.py --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
    #substituteInPlace meson.build --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';
 
   
meta = with lib; {
    description = "Tool for designing applications icons ";
    longDescription = '' '';
    homepage = "https://gitlab.gnome.org/World/design/app-icon-preview";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
